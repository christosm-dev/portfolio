# VPS Demo Sandbox Platform

A secure, production-grade sandboxed code execution platform for portfolio demonstrations. This project showcases DevOps, SRE, and Platform Engineering skills through real-world infrastructure automation, containerization, and security practices.

## 🎯 Project Overview

This platform enables portfolio visitors to execute code examples in isolated, secure environments with:
- **Docker-based containerization** for strong isolation
- **Resource limits** (CPU, memory, execution time)
- **Network isolation** (no external access from sandboxes)
- **Rate limiting** to prevent abuse
- **Infrastructure as Code** with Terraform
- **Production-ready** architecture

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                       Internet                              │
│         *.christosm.dev (Cloudflare Proxied)                │
└──────────────────────┬──────────────────────────────────────┘
                       │ HTTPS (port 443)
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                    Contabo VPS                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Traefik (Reverse Proxy + Let's Encrypt TLS)          │  │
│  │  - Cloudflare DNS Challenge for certificates          │  │
│  │  - HTTP → HTTPS redirect                              │  │
│  │  - Basic auth on admin services                       │  │
│  └──┬──────────┬──────────┬──────────┬──────────┬────────┘  │
│     │          │          │          │          │            │
│     ▼          ▼          ▼          ▼          ▼            │
│  ┌──────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌─────────┐    │
│  │Sandbox│ │Grafana │ │Prometh.│ │Portain.│ │Traefik  │    │
│  │  API  │ │ :3000  │ │ :9090  │ │ :9000  │ │Dashboard│    │
│  └──┬───┘ └───┬────┘ └────────┘ └────────┘ └─────────┘    │
│     │         │                                             │
│     │         │ queries                                     │
│     │         ▼                                             │
│     │    ┌─────────┐    ┌──────────┐                       │
│     │    │  Loki   │◄───│ Promtail │ (container + host     │
│     │    │ (logs)  │    │ (agent)  │  log collection)       │
│     │    └─────────┘    └──────────┘                       │
│     │                                                       │
│     │  Creates sandboxes                                    │
│     ▼                                                       │
│  ┌───────────────────────────────────────┐                 │
│  │  Ephemeral Containers                 │                 │
│  │  - Python 3.11  - Node.js 18         │                 │
│  │  - Bash 5.2                          │                 │
│  │  Security: No network, read-only FS, │                 │
│  │  resource limits, dropped caps        │                 │
│  └───────────────────────────────────────┘                 │
└─────────────────────────────────────────────────────────────┘
```

## 🌐 Live Services

| Service | URL | Authentication |
|---------|-----|----------------|
| Sandbox API | https://api.christosm.dev | None (public) |
| Grafana | https://grafana.christosm.dev | Grafana login |
| Prometheus | https://prometheus.christosm.dev | Basic auth |
| Traefik Dashboard | https://traefik.christosm.dev | Basic auth |
| Portainer | https://portainer.christosm.dev | Portainer login |

## 🔐 Security Features

### Container Isolation
- **Network Isolation**: `network_mode: none` - containers have no network access
- **Read-only Root**: Filesystem is read-only except for `/tmp` (50MB limit)
- **Capability Dropping**: All Linux capabilities dropped with `cap_drop: ALL`
- **No New Privileges**: Prevents privilege escalation
- **Process Limits**: Maximum 50 processes per container

### Resource Constraints
- **CPU**: Limited to 50% of one core
- **Memory**: Hard limit of 256MB (no swap)
- **Execution Time**: 30-second timeout (configurable)
- **Output Size**: 10KB maximum output

### Application Security
- **Rate Limiting**: 10 requests per 60 seconds per IP address
- **Input Validation**: Code length limits, dangerous pattern detection
- **Automatic Cleanup**: Containers removed after execution
- **Logging**: All executions logged with metadata

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose installed
- Python 3.8+ (for test client)
- Terraform 1.5+ (for infrastructure provisioning)
- SSH access to your VPS (for deployment)

### Local Development

1. **Clone the repository**:
```bash
git clone <your-repo-url>
cd zensical-sandbox-platform
```

2. **Start the services**:
```bash
docker-compose up --build
```

3. **Verify the API is running**:
```bash
curl http://localhost:8000/health
```

4. **Run test examples**:
```bash
python3 test_client.py
```

### Interactive Testing

```bash
python3 test_client.py --interactive
```

Then try commands like:
```
>>> python print("Hello, World!")
>>> node console.log("Hello from Node!")
>>> bash echo "Hello from Bash!"
>>> health
>>> stats
```

## 📦 Deployment to VPS

### Step 1: Configure Terraform Variables

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your VPS details:
```hcl
vps_host             = "YOUR_VPS_IP"
vps_user             = "root"
ssh_private_key_path = "~/.ssh/id_rsa"
```

### Step 2: Initialize Terraform

```bash
terraform init
```

### Step 3: Review the Plan

```bash
terraform plan
```

This will show you:
- Docker installation steps
- Firewall configuration
- Application deployment
- Systemd service setup

### Step 4: Deploy

```bash
terraform apply
```

Type `yes` when prompted. Terraform will:
1. Install Docker and dependencies
2. Configure UFW firewall
3. Copy application files
4. Pull Docker images
5. Deploy the application
6. Configure systemd for auto-restart

### Step 5: Verify Deployment

```bash
# Check health endpoint
curl http://YOUR_VPS_IP:8000/health

# Or use the test client
python3 test_client.py
```

## 🔧 API Reference

### Base URL

Local: `http://localhost:8000`
Production: `https://api.christosm.dev`

### Endpoints

#### `GET /health`
Health check endpoint

**Response**:
```json
{
  "status": "healthy",
  "docker_available": true,
  "timestamp": "2024-02-04T10:30:00Z",
  "active_containers": 0
}
```

#### `GET /environments`
List supported execution environments

**Response**:
```json
{
  "environments": ["python", "node", "bash"],
  "details": {
    "python": {
      "image": "python:3.11-slim",
      "file_extension": "py"
    },
    "node": {
      "image": "node:18-alpine",
      "file_extension": "js"
    },
    "bash": {
      "image": "bash:5.2-alpine3.19",
      "file_extension": "sh"
    }
  }
}
```

#### `POST /execute`
Execute code in sandbox environment

**Request**:
```json
{
  "code": "print('Hello, World!')",
  "environment": "python",
  "timeout": 30
}
```

**Response** (Success):
```json
{
  "execution_id": "uuid-here",
  "status": "success",
  "output": "Hello, World!\n",
  "error": null,
  "execution_time": 0.523,
  "environment": "python",
  "timestamp": "2024-02-04T10:30:00Z"
}
```

**Response** (Error):
```json
{
  "execution_id": "uuid-here",
  "status": "error",
  "output": null,
  "error": "Error message here",
  "execution_time": 0.123,
  "environment": "python",
  "timestamp": "2024-02-04T10:30:00Z"
}
```

**Response** (Timeout):
```json
{
  "execution_id": "uuid-here",
  "status": "timeout",
  "output": "Partial output...",
  "error": null,
  "execution_time": 30.0,
  "environment": "python",
  "timestamp": "2024-02-04T10:30:00Z"
}
```

#### `GET /stats`
Platform statistics

**Response**:
```json
{
  "active_executions": 2,
  "total_containers": 5,
  "supported_environments": ["python", "node", "bash"],
  "rate_limit": {
    "window_seconds": 60,
    "max_requests": 10
  },
  "resource_limits": {
    "memory": "256m",
    "cpu_percent": 50.0,
    "timeout_seconds": 30
  },
  "timestamp": "2024-02-04T10:30:00Z"
}
```

## 🎨 Frontend Integration

### JavaScript/React Example

```javascript
const API_BASE_URL = 'https://api.christosm.dev';

async function executeSandbox(code, environment) {
  try {
    const response = await fetch(`${API_BASE_URL}/execute`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        code: code,
        environment: environment,
        timeout: 30
      })
    });
    
    if (!response.ok) {
      throw new Error(`API error: ${response.status}`);
    }
    
    const result = await response.json();
    return result;
  } catch (error) {
    console.error('Sandbox execution failed:', error);
    throw error;
  }
}

// Usage
executeSandbox('print("Hello!")', 'python')
  .then(result => {
    if (result.status === 'success') {
      console.log('Output:', result.output);
    } else {
      console.error('Error:', result.error);
    }
  });
```

### HTML/Vanilla JS Example

See `frontend-integration/example.html` for a complete working example.

## 📊 Monitoring and Observability

The platform runs a full observability stack accessible via Grafana:

| Component | Role | Retention |
|-----------|------|-----------|
| **Prometheus** | Metrics collection (Traefik, Sandbox API, Loki) | 15 days |
| **Loki** | Log aggregation (container + host logs) | 15 days (360h) |
| **Promtail** | Log collection agent (Docker SD + host syslog/auth) | N/A |
| **Grafana** | Visualization and dashboards | Persistent |

### Grafana Queries

```
# Container logs (all services)
{job="docker-sd"}

# Filter by service name
{service="sandbox-api"}

# Host syslog
{job="syslog"}

# SSH and authentication logs
{job="authlog"}
```

### Prometheus Scrape Targets

- `prometheus:9090` - Self-monitoring
- `traefik:8080` - Reverse proxy metrics
- `sandbox-api:8000` - Application metrics
- `loki:3100` - Log aggregation metrics

### Maintenance Commands

```bash
# View service logs
docker compose logs -f sandbox-api

# Check all service status
docker compose ps

# Restart a specific service
docker compose restart grafana

# Clean up stopped containers and unused images
docker container prune -f
docker image prune -a -f

# Check resource usage
docker stats
```

## 🛠️ Configuration

### Adjusting Resource Limits

Edit `docker-compose.yml`:

```yaml
services:
  sandbox-api:
    environment:
      - MEMORY_LIMIT=512m        # Increase memory
      - CPU_QUOTA=100000         # Increase CPU (100%)
      - EXECUTION_TIMEOUT=60     # Increase timeout
```

### Adding New Environments

Edit `backend/main.py`:

```python
SUPPORTED_ENVIRONMENTS = {
    "python": {...},
    "node": {...},
    "bash": {...},
    "ruby": {  # New environment
        "image": "ruby:3.2-alpine",
        "command_template": "ruby -e '{code}'",
        "file_extension": "rb"
    }
}
```

### SSL/TLS Configuration

TLS is handled by Traefik with Let's Encrypt certificates via Cloudflare DNS challenge:

- **Certificate Resolver**: Let's Encrypt (ACME) with Cloudflare DNS-01 challenge
- **Cloudflare Proxy**: All subdomains are proxied through Cloudflare (orange cloud)
- **HTTP Redirect**: All HTTP traffic is automatically redirected to HTTPS
- **Admin Auth**: Traefik dashboard and Prometheus are protected with basic auth middleware

Required environment variables (see `.env.example`):
```bash
CF_DNS_API_TOKEN=<cloudflare-api-token-with-dns-edit>
TRAEFIK_BASIC_AUTH=<htpasswd-generated-user:hash>
```

## 🎓 Learning Outcomes

This project demonstrates:

### DevOps Skills
- ✅ Container orchestration with Docker Compose
- ✅ Infrastructure as Code with Terraform
- ✅ CI/CD pipeline concepts (automated deployment)
- ✅ Security hardening and best practices

### SRE Skills
- ✅ Service reliability patterns (health checks, timeouts)
- ✅ Resource management and limits
- ✅ Monitoring and observability (logging, metrics)
- ✅ Incident prevention (rate limiting, input validation)

### Platform Engineering Skills
- ✅ Building developer-facing APIs
- ✅ Multi-tenancy and isolation
- ✅ Self-service infrastructure
- ✅ Production-grade architecture

### Cloud Engineering Skills
- ✅ VPS/cloud server management
- ✅ Network security configuration
- ✅ Automated provisioning
- ✅ Scalable system design

## Future Work

### Kubernetes Migration
- Namespace-based isolation
- ResourceQuotas and LimitRanges
- NetworkPolicies for enhanced security
- Horizontal Pod Autoscaling

### Advanced Security
- gVisor runtime for enhanced isolation
- Seccomp and AppArmor profiles
- Admission webhooks for policy enforcement
- Secret management with Vault

### Monitoring & Observability
- ~~Prometheus metrics~~ ✅ Implemented
- ~~Grafana dashboards~~ ✅ Implemented
- ~~Log aggregation~~ ✅ Implemented (Loki + Promtail)
- Distributed tracing with Jaeger
- Alertmanager for alert routing

### Developer Experience
- WebSocket for real-time output
- Multi-file execution support
- Package installation support
- Collaborative features

## Interview Talking Points

### For Aerospace/Defense Roles
- "Built a secure, sandboxed execution environment with defense-in-depth security"
- "Implemented network isolation, capability dropping, and resource constraints"
- "Demonstrated security-conscious development practices suitable for cleared environments"

### For Platform Engineering Roles
- "Created a multi-tenant developer platform with API-first design"
- "Implemented self-service infrastructure for code execution"
- "Built production-grade isolation with Docker and resource management"

### For DevOps/SRE Roles
- "Automated infrastructure provisioning with Terraform"
- "Implemented comprehensive monitoring, logging, and health checks"
- "Designed for reliability with timeouts, rate limiting, and graceful degradation"

### For Cloud Engineering Roles
- "Deployed containerized applications to cloud infrastructure"
- "Implemented scalable architecture suitable for cloud-native deployment"
- "Used IaC for reproducible, version-controlled infrastructure"

## Resources

- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Terraform Docker Provider](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs)
- [gVisor Container Security](https://gvisor.dev/)
- [Kubernetes Multi-tenancy](https://kubernetes.io/docs/concepts/security/multi-tenancy/)
- [Loki Documentation](https://grafana.com/docs/loki/latest/)
- Portfolio: [christosm.dev](https://christosm.dev)
