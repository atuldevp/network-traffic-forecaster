<<<<<<< HEAD
# network-traffic-forecaster
=======
# Network Traffic Capacity Forecasting - Agentic App

An AI-powered network traffic capacity forecasting application for telecom service providers, built using Red Hat's Llama Stack framework and OpenShift AI.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           Network Traffic Forecaster                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐                  │
│  │   API        │    │   Llama      │    │  Forecasting │                  │
│  │   Gateway    │◄──►│   Stack      │◄──►│   Agent      │                  │
│  │   (Port 8080)│    │   Agent      │    │  (Port 5001) │                  │
│  └──────┬───────┘    │  (Port 5003) │    └──────┬───────┘                  │
│         │            └──────────────┘           │                          │
│         │                                       │                          │
│         │            ┌──────────────┐          │                          │
│         │            │   Alert      │          │                          │
│         └───────────►│   Agent      │◄─────────┘                          │
│                      │  (Port 5002) │                                     │
│                      └──────┬───────┘                                     │
│                             │                                             │
│         ┌───────────────────┼───────────────────┐                        │
│         │                   │                   │                        │
│  ┌──────▼───────┐    ┌──────▼───────┐    ┌──────▼───────┐               │
│  │   Data       │    │  PostgreSQL  │    │    Redis     │               │
│  │  Ingestion   │◄──►│   (Port      │◄──►│   (Port      │               │
│  │  (Port 5000) │    │    5432)     │    │    6379)     │               │
│  └──────────────┘    └──────────────┘    └──────────────┘               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Microservices

### 1. Data Ingestion Service (Port 5000)
- Handles batch processing of network traffic data
- Data validation and cleaning
- Anomaly detection
- Stores data in PostgreSQL

### 2. Forecasting Agent Service (Port 5001)
- Time-series forecasting using Prophet and ARIMA
- Capacity planning insights
- Multi-node forecasting
- Model management

### 3. Alert Agent Service (Port 5002)
- Intelligent alerting with configurable rules
- Slack and email notifications
- Alert suppression
- Auto-resolution

### 4. Llama Stack Agent Service (Port 5003)
- AI-powered insights using Llama Stack
- Natural language queries
- Forecast narrative generation
- Anomaly analysis

### 5. API Gateway (Port 8080)
- Central entry point for all services
- JWT authentication
- Rate limiting
- Request routing

## Prerequisites

- OpenShift 4.12+ cluster
- OpenShift CLI (oc)
- kubectl
- Access to Red Hat Container Registry

## Deployment on OpenShift

### 1. Create Namespace and Resources

```bash
# Login to OpenShift
oc login <your-openshift-cluster>

# Apply all manifests
oc apply -k openshift-manifests/
```

### 2. Build and Deploy Services

```bash
# Option 1: Use BuildConfigs (if Git repository is accessible)
oc apply -f openshift-manifests/buildconfig.yaml

# Start builds
oc start-build data-ingestion
oc start-build forecasting-agent
oc start-build alert-agent
oc start-build llama-stack-agent
oc start-build api-gateway

# Option 2: Build locally and push
# Build images using Docker/Podman
docker build -t your-registry/network-traffic-forecaster/data-ingestion:latest services/data-ingestion/
docker push your-registry/network-traffic-forecaster/data-ingestion:latest

# Update deployment to use your image
oc set image deployment/data-ingestion data-ingestion=your-registry/network-traffic-forecaster/data-ingestion:latest
```

### 3. Verify Deployment

```bash
# Check all pods are running
oc get pods -n network-traffic-forecaster

# Check service health
curl https://$(oc get route api-gateway -o jsonpath='{.spec.host}')/health
```

## API Documentation

### Authentication

```bash
# Get JWT token
curl -X POST https://<api-gateway>/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}'
```

### Data Ingestion

```bash
# Ingest traffic data
curl -X POST https://<api-gateway>/ingest \
  -H "Authorization: Bearer <token>" \
  -F "file=@traffic_data.csv" \
  -F "batch_id=batch-001"

# Get statistics
curl https://<api-gateway>/stats?hours=24 \
  -H "Authorization: Bearer <token>"
```

### Forecasting

```bash
# Generate forecast
curl -X POST https://<api-gateway>/forecast \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "node_id": "node-0001",
    "periods": 24,
    "history_days": 14
  }'

# Get capacity issues
curl https://<api-gateway>/capacity/issues \
  -H "Authorization: Bearer <token>"
```

### Alerts

```bash
# Get active alerts
curl https://<api-gateway>/alerts?status=active \
  -H "Authorization: Bearer <token>"

# Acknowledge alert
curl -X POST https://<api-gateway>/alerts/1/acknowledge \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"acknowledged_by": "operator1"}'
```

### AI Agent

```bash
# Query the AI agent
curl -X POST https://<api-gateway>/agent/query \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "What is the current network utilization?",
    "hours": 24
  }'

# Get forecast insights
curl -X POST https://<api-gateway>/agent/forecast \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "node_id": "node-0001",
    "periods": 24
  }'
```

## Synthetic Data Generation

```bash
# Generate sample data
cd services/data-ingestion
python synthetic_data_generator.py

# This will create:
# - datasets/historical_traffic.csv (30 days of data)
# - datasets/batches/ (24 hourly batch files)
```

## Llama Stack Integration

The application integrates with Red Hat Llama Stack for AI capabilities:

1. **Inference Server**: Connects to vLLM or Ollama for LLM inference
2. **Agent Framework**: Uses Llama Stack's Agent API for conversational AI
3. **Tools**: Custom tools for querying network data

### Configuration

Set the following environment variables:

```bash
LLAMA_STACK_URL=http://llama-stack:8321
LLAMA_STACK_MODEL=llama3.2:3b
```

## Monitoring

### Health Checks

All services expose `/health` endpoints:

```bash
# Check all services
curl https://<api-gateway>/health
```

### Metrics

Prometheus metrics are available at `/metrics` on each service.

### Logging

View logs:

```bash
# Get logs for a specific service
oc logs -f deployment/data-ingestion

# Get logs for all pods
oc logs -f -l app=data-ingestion
```

## Development

### Local Development

```bash
# Start PostgreSQL and Redis
docker run -d --name postgres -e POSTGRES_PASSWORD=password -p 5432:5432 postgres:15
docker run -d --name redis -p 6379:6379 redis:7

# Install dependencies and run services
cd services/data-ingestion
pip install -r requirements.txt
python app.py
```

### Testing

```bash
# Run unit tests
pytest tests/

# Run integration tests
pytest tests/integration/ --integration
```

## Security

- JWT-based authentication
- Rate limiting on all endpoints
- Network policies for inter-service communication
- Secrets management via OpenShift Secrets

## Troubleshooting

### Common Issues

1. **Pod not starting**
   ```bash
   oc describe pod <pod-name>
   oc logs <pod-name>
   ```

2. **Database connection issues**
   ```bash
   # Check PostgreSQL pod
   oc get pods -l app=postgres
   oc logs deployment/postgres
   ```

3. **Service unavailable**
   ```bash
   # Check service endpoints
   oc get endpoints
   ```

## License

MIT License - See LICENSE file for details

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## Support

For support, please contact:
- Email: support@telecom-provider.com
- Slack: #network-ops-support
>>>>>>> 1c9395f (Initial commit)
