# Network Traffic Capacity Forecasting - Agentic App
## Project Summary

### Overview
This is a comprehensive AI-powered Network Traffic Capacity Forecasting application built for Telecom Service Providers using Red Hat's Llama Stack framework and OpenShift AI. The application uses microservices architecture with containerized agents for data ingestion, forecasting, alerting, and AI-powered insights.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           Network Traffic Forecaster                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐                  │
│  │   Frontend   │    │   API        │    │   Llama      │                  │
│  │   (React)    │◄──►│   Gateway    │◄──►│   Stack      │                  │
│  │   Port 8080  │    │   Port 8080  │    │   Agent      │                  │
│  └──────────────┘    └──────┬───────┘    │   Port 5003  │                  │
│                             │            └──────────────┘                  │
│                             │                                               │
│         ┌───────────────────┼───────────────────┐                          │
│         │                   │                   │                          │
│  ┌──────▼───────┐    ┌──────▼───────┐    ┌──────▼───────┐                 │
│  │   Data       │    │  Forecasting │    │   Alert      │                 │
│  │  Ingestion   │◄──►│   Agent      │◄──►│   Agent      │                 │
│  │  Port 5000   │    │  Port 5001   │    │  Port 5002   │                 │
│  └──────┬───────┘    └──────────────┘    └──────────────┘                 │
│         │                                                                   │
│  ┌──────┴──────────────────────────────────────────┐                      │
│  │              PostgreSQL + Redis                  │                      │
│  └──────────────────────────────────────────────────┘                      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Microservices

### 1. Data Ingestion Service (Port 5000)
- **File**: `services/data-ingestion/app.py`
- **Features**:
  - Batch processing of network traffic data
  - Data validation and cleaning
  - Anomaly detection using statistical methods
  - PostgreSQL storage with time-series partitioning
  - Hourly and daily aggregation
- **Dockerfile**: `services/data-ingestion/Dockerfile`

### 2. Forecasting Agent Service (Port 5001)
- **File**: `services/forecasting-agent/app.py`
- **Features**:
  - Time-series forecasting using Prophet and ARIMA
  - Capacity planning insights
  - Multi-node forecasting
  - Model persistence and caching
  - Confidence intervals and risk assessment
- **Dockerfile**: `services/forecasting-agent/Dockerfile`

### 3. Alert Agent Service (Port 5002)
- **File**: `services/alert-agent/app.py`
- **Features**:
  - Configurable alert rules
  - Slack and email notifications
  - Alert suppression windows
  - Auto-resolution for resolved issues
  - Alert acknowledgment workflow
- **Dockerfile**: `services/alert-agent/Dockerfile`

### 4. Llama Stack Agent Service (Port 5003)
- **File**: `services/llama-stack-agent/app.py`
- **Features**:
  - AI-powered insights using Llama Stack
  - Natural language query interface
  - Forecast narrative generation
  - Anomaly analysis with root cause suggestions
  - Fallback mode when Llama Stack unavailable
- **Dockerfile**: `services/llama-stack-agent/Dockerfile`

### 5. API Gateway (Port 8080)
- **File**: `services/api-gateway/app.py`
- **Features**:
  - Central entry point for all services
  - JWT authentication
  - Rate limiting
  - Request routing and load balancing
  - Dashboard aggregation endpoints
- **Dockerfile**: `services/api-gateway/Dockerfile`

### 6. Frontend Dashboard (Port 8080)
- **Framework**: React + TypeScript + Vite + Tailwind CSS
- **Features**:
  - Real-time traffic monitoring
  - Interactive charts (ECharts)
  - Alert management interface
  - AI chat interface
  - Responsive dark theme UI
- **Dockerfile**: `frontend/Dockerfile`

---

## Data Model

### Synthetic Data Generator
- **File**: `services/data-ingestion/synthetic_data_generator.py`
- Generates realistic network traffic with:
  - Daily and weekly seasonal patterns
  - Long-term growth trends
  - Random anomalies (spikes/drops)
  - 5-minute granularity
  - Multiple node types and regions

### Database Schema
- **network_traffic**: Main time-series data table (partitioned)
- **traffic_hourly_stats**: Aggregated hourly statistics
- **traffic_daily_stats**: Daily aggregates for trends
- **traffic_anomalies**: Detected anomalies
- **alerts**: Active and historical alerts
- **alert_rules**: Configurable alert rules
- **batch_processing_log**: Ingestion tracking

---

## OpenShift Deployment

### Prerequisites
- OpenShift 4.12+ cluster
- OpenShift CLI (oc)
- Access to Red Hat Container Registry

### Deployment Steps

```bash
# 1. Login to OpenShift
oc login <your-cluster>

# 2. Deploy all resources
oc apply -k openshift-manifests/

# 3. Or use the deployment script
chmod +x deploy.sh
./deploy.sh
```

### Manifests
- **namespace.yaml**: Project namespace
- **configmap.yaml**: Configuration and secrets
- **postgres.yaml**: PostgreSQL database
- **redis.yaml**: Redis cache
- **data-ingestion.yaml**: Data ingestion service
- **forecasting-agent.yaml**: Forecasting service
- **alert-agent.yaml**: Alert service
- **llama-stack-agent.yaml**: AI agent service
- **api-gateway.yaml**: API gateway with route
- **frontend.yaml**: React frontend with route
- **llama-stack.yaml**: Optional Llama Stack inference server
- **buildconfig.yaml**: OpenShift build configurations
- **kustomization.yaml**: Kustomize configuration

---

## API Endpoints

### Authentication
- `POST /auth/login` - Get JWT token
- `GET /auth/verify` - Verify token

### Dashboard
- `GET /dashboard/summary` - Aggregated dashboard data
- `GET /dashboard/metrics` - Real-time metrics

### Traffic
- `GET /stats` - Traffic statistics
- `GET /recent` - Recent traffic data
- `GET /anomalies` - Detected anomalies
- `POST /ingest` - Ingest batch data

### Forecasting
- `POST /forecast` - Generate forecast
- `POST /forecast/multi` - Multi-node forecast
- `GET /capacity/issues` - Capacity issues

### Alerts
- `GET /alerts` - List alerts
- `GET /alerts/rules` - Alert rules
- `POST /alerts/:id/acknowledge` - Acknowledge alert
- `POST /alerts/:id/resolve` - Resolve alert
- `POST /alerts/evaluate` - Trigger evaluation

### AI Agent
- `POST /agent/query` - Natural language query
- `POST /agent/forecast` - AI forecast insights
- `POST /agent/insights` - General insights
- `POST /agent/chat` - Chat interface

---

## Local Development

### Using Docker Compose
```bash
# Start all services
docker-compose up -d

# Generate sample data
cd services/data-ingestion
python synthetic_data_generator.py

# Access services
# API Gateway: http://localhost:8080
# Frontend: http://localhost:8080
```

### Individual Services
```bash
# Data Ingestion
cd services/data-ingestion
pip install -r requirements.txt
python app.py

# Forecasting
cd services/forecasting-agent
pip install -r requirements.txt
python app.py

# Frontend
cd frontend
npm install
npm run dev
```

---

## Llama Stack Integration

The application integrates with Red Hat Llama Stack for AI capabilities:

### Configuration
```bash
LLAMA_STACK_URL=http://llama-stack:8321
LLAMA_STACK_MODEL=llama3.2:3b
```

### Features
- Natural language network queries
- AI-generated forecast narratives
- Intelligent anomaly analysis
- Context-aware recommendations

### Fallback Mode
When Llama Stack is unavailable, the agent falls back to rule-based responses using pattern matching.

---

## Monitoring & Observability

### Health Checks
All services expose `/health` endpoints for Kubernetes liveness/readiness probes.

### Logging
- Structured JSON logging
- Log aggregation via OpenShift
- Per-service log configuration

### Metrics
- Prometheus-compatible metrics
- Custom business metrics
- Infrastructure metrics

---

## Security

### Authentication
- JWT-based authentication
- Role-based access control (admin, operator, viewer)
- Token expiration and refresh

### Network Security
- Inter-service communication via internal networks
- TLS termination at OpenShift Router
- Network policies for pod isolation

### Secrets Management
- OpenShift Secrets for sensitive data
- Environment variable injection
- No hardcoded credentials

---

## Project Structure

```
network-traffic-forecaster/
├── services/
│   ├── data-ingestion/
│   │   ├── app.py
│   │   ├── synthetic_data_generator.py
│   │   ├── Dockerfile
│   │   └── requirements.txt
│   ├── forecasting-agent/
│   │   ├── app.py
│   │   ├── Dockerfile
│   │   └── requirements.txt
│   ├── alert-agent/
│   │   ├── app.py
│   │   ├── Dockerfile
│   │   └── requirements.txt
│   ├── llama-stack-agent/
│   │   ├── app.py
│   │   ├── Dockerfile
│   │   └── requirements.txt
│   └── api-gateway/
│       ├── app.py
│       ├── Dockerfile
│       └── requirements.txt
├── frontend/
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   ├── hooks/
│   │   ├── types/
│   │   └── App.tsx
│   ├── Dockerfile
│   └── nginx.conf
├── openshift-manifests/
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── postgres.yaml
│   ├── redis.yaml
│   ├── data-ingestion.yaml
│   ├── forecasting-agent.yaml
│   ├── alert-agent.yaml
│   ├── llama-stack-agent.yaml
│   ├── api-gateway.yaml
│   ├── frontend.yaml
│   ├── llama-stack.yaml
│   ├── buildconfig.yaml
│   └── kustomization.yaml
├── datasets/
├── deploy.sh
├── docker-compose.yml
└── README.md
```

---

## Future Enhancements

1. **Real-time Streaming**: Kafka integration for real-time data ingestion
2. **Advanced ML**: Deep learning models for anomaly detection
3. **Multi-tenancy**: Support for multiple telecom providers
4. **Geographic Visualization**: Map-based network visualization
5. **Mobile App**: React Native mobile application
6. **Voice Integration**: Voice-activated AI assistant

---

## License
MIT License

## Support
For support, contact: support@telecom-provider.com
