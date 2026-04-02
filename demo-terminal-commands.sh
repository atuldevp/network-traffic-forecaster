#!/bin/bash
# ============================================================
# Network Traffic Forecaster - demo.redhat.com Terminal Commands
# ============================================================
# 
# INSTRUCTIONS:
# 1. Login to demo.redhat.com and launch OpenShift sandbox
# 2. Click the '+' icon (top right) → 'Terminal'
# 3. Copy and paste these commands one by one
#
# ============================================================

# ----- STEP 1: Create Project -----
oc new-project network-traffic-forecaster

# ----- STEP 2: Deploy Infrastructure -----
oc apply -f https://raw.githubusercontent.com/YOUR_USERNAME/network-traffic-forecaster/main/openshift-manifests/namespace.yaml
oc apply -f https://raw.githubusercontent.com/YOUR_USERNAME/network-traffic-forecaster/main/openshift-manifests/configmap.yaml
oc apply -f https://raw.githubusercontent.com/YOUR_USERNAME/network-traffic-forecaster/main/openshift-manifests/postgres.yaml
oc apply -f https://raw.githubusercontent.com/YOUR_USERNAME/network-traffic-forecaster/main/openshift-manifests/redis.yaml

# ----- STEP 3: Wait for Database -----
oc wait --for=condition=available deployment/postgres --timeout=300s

# ----- STEP 4: Deploy Microservices -----
oc apply -f https://raw.githubusercontent.com/YOUR_USERNAME/network-traffic-forecaster/main/openshift-manifests/data-ingestion.yaml
oc apply -f https://raw.githubusercontent.com/YOUR_USERNAME/network-traffic-forecaster/main/openshift-manifests/forecasting-agent.yaml
oc apply -f https://raw.githubusercontent.com/YOUR_USERNAME/network-traffic-forecaster/main/openshift-manifests/alert-agent.yaml
oc apply -f https://raw.githubusercontent.com/YOUR_USERNAME/network-traffic-forecaster/main/openshift-manifests/llama-stack-agent.yaml
oc apply -f https://raw.githubusercontent.com/YOUR_USERNAME/network-traffic-forecaster/main/openshift-manifests/api-gateway.yaml
oc apply -f https://raw.githubusercontent.com/YOUR_USERNAME/network-traffic-forecaster/main/openshift-manifests/frontend.yaml

# ----- STEP 5: Wait for All Services -----
for d in data-ingestion forecasting-agent alert-agent llama-stack-agent api-gateway frontend; do
    oc wait --for=condition=available deployment/$d --timeout=300s
done

# ----- STEP 6: Get URLs -----
echo "=== DEPLOYMENT COMPLETE ==="
echo "Frontend:"
oc get route frontend -o jsonpath='https://{.spec.host}{"\n"}'
echo ""
echo "API Gateway:"
oc get route api-gateway -o jsonpath='https://{.spec.host}{"\n"}'

# ============================================================
# ALTERNATIVE: If you have files locally uploaded to /tmp/
# ============================================================
# cd /tmp/network-traffic-forecaster
# oc apply -k openshift-manifests/
# oc get routes
