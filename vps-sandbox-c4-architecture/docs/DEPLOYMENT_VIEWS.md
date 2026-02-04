# Deployment Views

This document provides different deployment perspectives of the VPS Sandbox Platform, showing how the system is deployed across different environments and phases.

## 🎯 Deployment Perspectives

### Development Environment

**Location**: Local machine (WSL/Docker Desktop)
**Purpose**: Local development and testing
**Tools**: Docker Compose

```
┌─────────────────────────────────────┐
│   Developer Machine (WSL/Windows)   │
│                                     │
│  ┌──────────────────────────────┐  │
│  │   Docker Desktop             │  │
│  │                              │  │
│  │  ┌──────┐  ┌──────┐         │  │
│  │  │FastAPI│  │Postgres│       │  │
│  │  └──────┘  └──────┘         │  │
│  │  ┌──────┐  ┌──────────┐     │  │
│  │  │Redis │  │Prometheus│     │  │
│  │  └──────┘  └──────────┘     │  │
│  └──────────────────────────────┘  │
└─────────────────────────────────────┘
```

**Characteristics**:
- Hot reload for development
- Debug mode enabled
- Minimal security (localhost only)
- SQLite or local PostgreSQL
- Mock external services

---

## Phase 1: Docker-Based Deployment

### Production Environment (Contabo VPS)

**Location**: Contabo VPS (dedicated server)
**Purpose**: Production showcase and portfolio demonstration
**Tools**: Terraform, Ansible, Docker Compose

```
┌───────────────────────────────────────────────────────────┐
│                    Contabo VPS Server                      │
│                     Ubuntu 22.04 LTS                       │
│                                                            │
│  ┌──────────────────────────────────────────────────────┐ │
│  │              Security Layer (UFW + Fail2ban)         │ │
│  └──────────────────────────────────────────────────────┘ │
│                                                            │
│  ┌──────────────────────────────────────────────────────┐ │
│  │                   NGINX (Port 443)                   │ │
│  │         SSL/TLS, Reverse Proxy, Rate Limiting       │ │
│  └──────────────────────────────────────────────────────┘ │
│                           │                                │
│  ┌────────────────────────┼────────────────────────────┐  │
│  │        Docker Network (bridge/overlay)              │  │
│  │                        │                            │  │
│  │  ┌──────────┐  ┌───────▼─────┐  ┌──────────────┐  │  │
│  │  │ FastAPI  │  │  PostgreSQL │  │    Redis     │  │  │
│  │  │ Backend  │  │  (persistent)│  │   (cache)    │  │  │
│  │  │ Container│  │   Container  │  │  Container   │  │  │
│  │  └────┬─────┘  └──────────────┘  └──────────────┘  │  │
│  │       │                                             │  │
│  │  ┌────▼──────────┐  ┌────────────────────────────┐ │  │
│  │  │  Prometheus   │  │       Grafana              │ │  │
│  │  │  (metrics)    │  │   (visualization)          │ │  │
│  │  │   Container   │  │     Container              │ │  │
│  │  └───────────────┘  └────────────────────────────┘ │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                            │
│  ┌──────────────────────────────────────────────────────┐ │
│  │              Persistent Storage (Volumes)            │ │
│  │    /var/lib/docker/volumes/postgres-data            │ │
│  │    /var/lib/docker/volumes/grafana-data             │ │
│  └──────────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────────┘
```

**Network Configuration**:
- **Port 80**: HTTP (redirects to HTTPS)
- **Port 443**: HTTPS (public access)
- **Port 22**: SSH (restricted to known IPs)
- **Internal ports**: Docker network (not exposed)

**Security Layers**:
1. UFW firewall (restrictive rules)
2. Fail2ban (intrusion prevention)
3. SSL/TLS (Let's Encrypt)
4. NGINX rate limiting
5. Container isolation
6. Non-root containers

**Resource Allocation**:
```
FastAPI:    CPU 1.0, RAM 512MB
PostgreSQL: CPU 1.0, RAM 1GB
Redis:      CPU 0.5, RAM 256MB
Prometheus: CPU 0.5, RAM 512MB
Grafana:    CPU 0.5, RAM 256MB
NGINX:      CPU 0.5, RAM 128MB
```

---

## Phase 2: Kubernetes-Based Deployment

### Production Environment (Kubernetes Cluster)

**Location**: Contabo VPS (K3s) or Cloud Provider
**Purpose**: Demonstrate Kubernetes skills and migration patterns
**Tools**: Terraform, Helm, ArgoCD

```
┌───────────────────────────────────────────────────────────┐
│              Kubernetes Cluster (K3s/K8s)                  │
│                                                            │
│  ┌──────────────────────────────────────────────────────┐ │
│  │              Ingress Controller (NGINX)              │ │
│  │         SSL/TLS, Load Balancing, Routing            │ │
│  └──────────────────────────────────────────────────────┘ │
│                           │                                │
│  ┌────────────────────────┼────────────────────────────┐  │
│  │          Kubernetes Services & Networking           │  │
│  │                        │                            │  │
│  │  ┌──────────────┐  ┌──▼────────────┐  ┌──────────┐ │  │
│  │  │   Backend    │  │  PostgreSQL   │  │  Redis   │ │  │
│  │  │ Deployment   │  │  StatefulSet  │  │Deployment│ │  │
│  │  │ (3 replicas) │  │  (persistent) │  │(2 replicas)│ │
│  │  └──────┬───────┘  └───────────────┘  └──────────┘ │  │
│  │         │                                           │  │
│  │  ┌──────▼─────────┐  ┌────────────────────────────┐ │  │
│  │  │  Prometheus    │  │      Grafana               │ │  │
│  │  │  Deployment    │  │    Deployment              │ │  │
│  │  │  (monitoring)  │  │  (visualization)           │ │  │
│  │  └────────────────┘  └────────────────────────────┘ │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                            │
│  ┌──────────────────────────────────────────────────────┐ │
│  │          Persistent Volumes (PV & PVC)               │ │
│  │      PostgreSQL: 10GB, Grafana: 5GB                 │ │
│  └──────────────────────────────────────────────────────┘ │
│                                                            │
│  ┌──────────────────────────────────────────────────────┐ │
│  │                 ConfigMaps & Secrets                 │ │
│  │    Application config, database credentials          │ │
│  └──────────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────────┘
```

**Kubernetes Resources**:

```yaml
# Namespaces
- vps-platform-prod
- vps-platform-monitoring

# Deployments
- backend-api (3 replicas)
- redis (2 replicas)
- grafana (1 replica)

# StatefulSets
- postgresql (1 replica, persistent)
- prometheus (1 replica, persistent)

# Services
- backend-api-service (ClusterIP)
- postgresql-service (ClusterIP)
- redis-service (ClusterIP)
- grafana-service (LoadBalancer)

# Ingress
- vps-platform-ingress (HTTPS routing)

# ConfigMaps
- backend-config
- prometheus-config

# Secrets
- database-credentials
- api-keys
- tls-certificates
```

**High Availability Features**:
- Multiple replicas for stateless services
- Rolling updates with zero downtime
- Health checks (liveness/readiness probes)
- Horizontal Pod Autoscaling (HPA)
- Resource limits and requests
- Pod disruption budgets

---

## 🔄 CI/CD Pipeline View

### Deployment Pipeline

```
┌─────────────────────────────────────────────────────────┐
│                     Developer                            │
└─────────────────┬───────────────────────────────────────┘
                  │ git push
                  ▼
┌─────────────────────────────────────────────────────────┐
│                   GitHub Repository                      │
│              (Code, IaC, Helm Charts)                   │
└─────────────────┬───────────────────────────────────────┘
                  │ webhook trigger
                  ▼
┌─────────────────────────────────────────────────────────┐
│                 GitHub Actions / CI                      │
│  1. Run Tests (pytest, linters)                         │
│  2. Build Docker Images                                 │
│  3. Security Scan (Trivy)                               │
│  4. Push Images to Docker Hub                           │
└─────────────────┬───────────────────────────────────────┘
                  │ artifacts ready
                  ▼
┌─────────────────────────────────────────────────────────┐
│           ArgoCD / GitOps Controller (Phase 2)          │
│              or Docker Compose (Phase 1)                │
│  1. Detect new image                                    │
│  2. Update deployment manifests                         │
│  3. Apply to cluster/server                             │
└─────────────────┬───────────────────────────────────────┘
                  │ deploy
                  ▼
┌─────────────────────────────────────────────────────────┐
│              Production Environment                      │
│         (Contabo VPS - Docker or K8s)                   │
│  1. Pull new images                                     │
│  2. Rolling update                                      │
│  3. Health checks pass                                  │
│  4. Monitor metrics                                     │
└─────────────────────────────────────────────────────────┘
```

---

## 🌍 Multi-Environment Strategy

### Environment Progression

```
Development → Staging → Production
(local)       (VPS)     (VPS)

Docker        Docker     Docker → Kubernetes
Compose       Compose    (Phase 1) (Phase 2)
```

### Environment Differences

| Aspect | Development | Staging | Production |
|--------|-------------|---------|------------|
| **Location** | Local (WSL) | VPS (separate namespace) | VPS |
| **Database** | SQLite/Postgres | PostgreSQL | PostgreSQL |
| **Replicas** | 1 | 1-2 | 2-3 |
| **SSL/TLS** | No | Yes | Yes |
| **Monitoring** | Optional | Yes | Yes |
| **Backups** | No | Daily | Hourly |
| **Resources** | Minimal | 50% of prod | Full |

---

## 🔐 Security Deployment View

### Network Security Zones

```
Internet (Untrusted)
         │
         ▼
┌──────────────────────┐
│   DMZ (NGINX)        │  ← Port 443 (HTTPS only)
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│  Application Zone    │  ← Backend API, Redis
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│   Data Zone          │  ← PostgreSQL (no external access)
└──────────────────────┘
```

**Security Controls**:
1. **Perimeter**: UFW + Fail2ban
2. **DMZ**: NGINX with SSL/TLS, rate limiting
3. **Application**: Container isolation, non-root
4. **Data**: Network segmentation, encrypted at rest

---

## 📊 Monitoring Deployment View

### Observability Stack

```
Application Containers
         │
         ├─ Logs ─────────────► Loki / ELK
         │
         ├─ Metrics ───────────► Prometheus ───► Grafana
         │
         └─ Traces ────────────► Jaeger (future)
```

**Monitored Metrics**:
- Container CPU/Memory usage
- API request rates and latency
- Database connections and query performance
- Cache hit/miss rates
- Error rates and types
- Network traffic

---

## 🎯 Interview Talking Points

This deployment documentation supports discussions about:

1. **Progressive Deployment**: Docker → Kubernetes migration
2. **Security Layers**: Defense-in-depth implementation
3. **High Availability**: Redundancy and failover strategies
4. **CI/CD**: Automated deployment pipelines
5. **Environment Management**: Dev/Staging/Prod strategy
6. **Monitoring**: Comprehensive observability
7. **Network Design**: Security zones and segmentation

---

**Last Updated**: February 4, 2026
**Owner**: Christos Michaelides
**Project**: VPS Sandbox Platform C4 Architecture
