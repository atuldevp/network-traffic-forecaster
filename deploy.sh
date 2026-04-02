#!/bin/bash
# Deployment script for Network Traffic Forecaster on OpenShift

set -e

NAMESPACE="network-traffic-forecaster"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=================================="
echo "Network Traffic Forecaster"
echo "OpenShift Deployment Script"
echo "=================================="
echo ""

# Check prerequisites
echo "Checking prerequisites..."
if ! command -v oc &> /dev/null; then
    echo "Error: OpenShift CLI (oc) not found. Please install it first."
    exit 1
fi

if ! oc whoami &> /dev/null; then
    echo "Error: Not logged into OpenShift. Please run 'oc login' first."
    exit 1
fi

echo "✓ Prerequisites met"
echo ""

# Function to wait for deployment
wait_for_deployment() {
    local deployment=$1
    echo "Waiting for $deployment to be ready..."
    oc rollout status deployment/$deployment -n $NAMESPACE --timeout=300s
}

# Deploy infrastructure
echo "Step 1: Deploying infrastructure..."
oc apply -f $PROJECT_DIR/openshift-manifests/namespace.yaml
echo "✓ Namespace created"

oc apply -f $PROJECT_DIR/openshift-manifests/configmap.yaml
echo "✓ ConfigMap and Secrets created"

oc apply -f $PROJECT_DIR/openshift-manifests/postgres.yaml
echo "✓ PostgreSQL deployed"

oc apply -f $PROJECT_DIR/openshift-manifests/redis.yaml
echo "✓ Redis deployed"

echo ""
echo "Step 2: Waiting for infrastructure to be ready..."
wait_for_deployment postgres
wait_for_deployment redis
echo "✓ Infrastructure ready"

echo ""
echo "Step 3: Building and deploying microservices..."

# Option 1: Build locally and push to OpenShift registry
build_locally() {
    echo "Building Docker images locally..."
    
    # Get OpenShift registry URL
    REGISTRY=$(oc get route default-route -n openshift-image-registry --template='{{ .spec.host }}' 2>/dev/null || echo "image-registry.openshift-image-registry.svc:5000")
    
    # Build images
    cd $PROJECT_DIR
    
    docker build -t $REGISTRY/$NAMESPACE/data-ingestion:latest services/data-ingestion/
    docker build -t $REGISTRY/$NAMESPACE/forecasting-agent:latest services/forecasting-agent/
    docker build -t $REGISTRY/$NAMESPACE/alert-agent:latest services/alert-agent/
    docker build -t $REGISTRY/$NAMESPACE/llama-stack-agent:latest services/llama-stack-agent/
    docker build -t $REGISTRY/$NAMESPACE/api-gateway:latest services/api-gateway/
    
    # Login to OpenShift registry
    docker login -u $(oc whoami) -p $(oc whoami -t) $REGISTRY
    
    # Push images
    docker push $REGISTRY/$NAMESPACE/data-ingestion:latest
    docker push $REGISTRY/$NAMESPACE/forecasting-agent:latest
    docker push $REGISTRY/$NAMESPACE/alert-agent:latest
    docker push $REGISTRY/$NAMESPACE/llama-stack-agent:latest
    docker push $REGISTRY/$NAMESPACE/api-gateway:latest
    
    echo "✓ Images built and pushed"
}

# Option 2: Use OpenShift BuildConfigs
build_on_openshift() {
    echo "Building on OpenShift..."
    oc apply -f $PROJECT_DIR/openshift-manifests/buildconfig.yaml
    
    oc start-build data-ingestion --follow
    oc start-build forecasting-agent --follow
    oc start-build alert-agent --follow
    oc start-build llama-stack-agent --follow
    oc start-build api-gateway --follow
    
    echo "✓ Builds completed"
}

# Ask user for build method
echo "Choose build method:"
echo "1) Build locally and push to OpenShift registry"
echo "2) Build on OpenShift (requires Git repository access)"
read -p "Enter choice (1 or 2): " build_choice

if [ "$build_choice" = "1" ]; then
    build_locally
elif [ "$build_choice" = "2" ]; then
    build_on_openshift
else
    echo "Invalid choice. Exiting."
    exit 1
fi

# Deploy microservices
echo ""
echo "Step 4: Deploying microservices..."
oc apply -f $PROJECT_DIR/openshift-manifests/data-ingestion.yaml
oc apply -f $PROJECT_DIR/openshift-manifests/forecasting-agent.yaml
oc apply -f $PROJECT_DIR/openshift-manifests/alert-agent.yaml
oc apply -f $PROJECT_DIR/openshift-manifests/llama-stack-agent.yaml
oc apply -f $PROJECT_DIR/openshift-manifests/api-gateway.yaml

echo "✓ Microservices deployed"

echo ""
echo "Step 5: Waiting for microservices to be ready..."
wait_for_deployment data-ingestion
wait_for_deployment forecasting-agent
wait_for_deployment alert-agent
wait_for_deployment llama-stack-agent
wait_for_deployment api-gateway
echo "✓ All microservices ready"

echo ""
echo "Step 6: Initialize databases..."
# Initialize data ingestion database
oc exec deployment/data-ingestion -- python -c "from app import ingestion_service; ingestion_service.initialize_database()" 2>/dev/null || echo "Note: Database initialization may need to be done manually"

# Initialize alert database
oc exec deployment/alert-agent -- python -c "from app import alert_agent; alert_agent.initialize_database()" 2>/dev/null || echo "Note: Alert database initialization may need to be done manually"

echo ""
echo "=================================="
echo "Deployment Complete!"
echo "=================================="
echo ""

# Get route
API_ROUTE=$(oc get route api-gateway -n $NAMESPACE -o jsonpath='{.spec.host}' 2>/dev/null)
if [ -n "$API_ROUTE" ]; then
    echo "API Gateway URL: https://$API_ROUTE"
    echo ""
    echo "Health Check:"
    curl -s https://$API_ROUTE/health | jq . 2>/dev/null || echo "Health endpoint not yet available"
fi

echo ""
echo "Useful commands:"
echo "  - View logs: oc logs -f deployment/api-gateway"
echo "  - Scale: oc scale deployment/api-gateway --replicas=3"
echo "  - Status: oc get pods -n $NAMESPACE"
echo "  - Delete: oc delete project $NAMESPACE"
echo ""
echo "Default credentials:"
echo "  - Username: admin"
echo "  - Password: admin123"
echo ""
