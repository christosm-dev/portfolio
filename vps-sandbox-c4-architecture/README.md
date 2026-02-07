# VPS Sandbox Platform - C4 Architecture

**Status**: 🚧 Planning
**Project**: [VPS Sandbox Platform](../vps-sandbox-platform/)
**Purpose**: Define and visualize the architecture of the VPS Sandbox Platform using C4 model notation

## 🎯 Overview

This directory contains C4 (Context, Containers, Components) architecture diagrams and definitions for the VPS Sandbox Platform. The C4 model provides a hierarchical approach to visualizing software architecture at different levels of abstraction.

## 📐 C4 Model Levels

The C4 model provides different levels of abstraction for documenting architecture:

### Level 1: System Context
**File**: [`diagrams/01-context.py`](diagrams/01-context.py)

Shows how the VPS Sandbox Platform fits into the overall environment:
- External users and systems
- High-level system boundaries
- Key relationships and interactions

**Audience**: Everyone (technical and non-technical)

### Level 2: Container
**File**: [`diagrams/02-container.py`](diagrams/02-container.py)

Breaks down the system into containers (applications, services, data stores):
- FastAPI backend application
- Docker containers
- Kubernetes pods (future phase)
- Databases and storage
- Load balancers and ingress

**Audience**: Technical staff (developers, DevOps, architects)

### Level 3: Component
**File**: [`diagrams/03-component.py`](diagrams/03-component.py)

Zooms into individual containers to show components:
- API endpoints and routes
- Business logic modules
- Security components
- Monitoring and logging

**Audience**: Developers and architects

## 📁 Directory Structure

```
vps-sandbox-c4-architecture/
├── README.md                    # This file
│
├── diagrams/                    # C4 diagram definitions
│   ├── 01-context.py           # System Context diagram
│   ├── 02-container.py         # Container diagram
│   └── 03-component.py         # Component diagram
│
└── docs/                        # Supporting documentation
    ├── ARCHITECTURE_DECISIONS.md
    ├── DESIGN_PRINCIPLES.md
    └── DEPLOYMENT_VIEWS.md
```

## 🛠️ C4 DSL Approach

We're using Python-based C4 definitions (similar to the [C4 Literate Python](../c4-literate-python/) project) for several reasons:

**Benefits**:
- ✅ **Version control friendly**: Text-based definitions in Git
- ✅ **Programmatic**: Generate diagrams from code
- ✅ **Literate programming**: Combine documentation with definitions
- ✅ **Flexible**: Easy to maintain and update
- ✅ **Portfolio value**: Demonstrates Python and architecture skills

## 🚀 Getting Started

### 1. Define System Context

Start by identifying:
- Who uses the system? (DevOps engineers, developers, hiring managers)
- What external systems interact with it? (GitHub, Docker Hub, monitoring tools)
- What are the system boundaries?

### 2. Break Down Containers

Identify the major runtime components:
- Web applications
- API services
- Databases
- Message queues
- Caches

### 3. Detail Components

For each container, identify internal components:
- Controllers/Routes
- Services
- Repositories
- Security filters
- Middleware

## 🎨 Visualization Options

### Option 1: C4 Literate Python
Use the custom C4 DSL from the [c4-literate-python](../c4-literate-python/) submodule:

```python
from c4_literate import System, Container, Component, Relationship

# Define elements
vps_platform = System("VPS Sandbox Platform")
user = Person("DevOps Engineer")

# Define relationships
user.uses(vps_platform, "Deploys and manages containers")
```

### Option 2: Structurizr DSL
Use the official Structurizr DSL format:

```
workspace {
    model {
        user = person "DevOps Engineer"
        vpsPlatform = softwareSystem "VPS Sandbox Platform" {
            backend = container "FastAPI Backend"
            docker = container "Docker Engine"
        }
        user -> vpsPlatform "Uses"
    }
}
```

### Option 3: PlantUML C4
Use PlantUML with C4 extensions:

```plantuml
@startuml
!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Context.puml

Person(user, "DevOps Engineer")
System(vps, "VPS Sandbox Platform")

Rel(user, vps, "Uses")
@enduml
```

## 🎯 VPS Sandbox Platform Architecture Goals

### Phase 1: Docker-based (Current)

**Containers**:
- FastAPI backend application
- PostgreSQL database
- Redis cache
- NGINX reverse proxy
- Monitoring stack (Prometheus, Grafana)

**Security Layers**:
- UFW firewall
- Fail2ban
- SSL/TLS (Let's Encrypt)
- Container isolation
- Resource limits

### Phase 2: Kubernetes Migration (Planned)

**Containers** (become Kubernetes pods):
- Backend API (Deployment)
- Database (StatefulSet)
- Cache (StatefulSet)
- Ingress controller
- Service mesh (Istio/Linkerd)

**Additional Components**:
- Helm charts
- CI/CD pipelines
- GitOps (ArgoCD/Flux)

## 📊 Architecture Decisions

Key architectural decisions will be documented in [`docs/ARCHITECTURE_DECISIONS.md`](docs/ARCHITECTURE_DECISIONS.md) including:

1. **Why Docker first, then Kubernetes?**
   - Progressive complexity
   - Demonstrate understanding of both
   - Show migration patterns

2. **Why FastAPI for backend?**
   - Modern Python framework
   - Async capabilities
   - Built-in API documentation
   - Type safety

3. **Security-first approach**
   - Defense in depth
   - Suitable for aerospace/defense interviews
   - Demonstrates SC clearance suitability

4. **Infrastructure as Code**
   - Terraform for provisioning
   - Ansible for configuration
   - GitOps for deployment

## 📚 Resources

- [C4 Model Official Site](https://c4model.com/)
- [Structurizr](https://structurizr.com/)
- [PlantUML C4](https://github.com/plantuml-stdlib/C4-PlantUML)
- [C4 Literate Python Project](../c4-literate-python/)

## 🔗 Related Documentation

- [VPS Sandbox Platform](../vps-sandbox-platform/README.md)
- [C4 Literate Python](../c4-literate-python/README.md)
- [Portfolio Overview](../README.md)
- [Claude Instructions](../CLAUDE.md)

## 🎯 Success Criteria

- ✅ Clear visualization of system architecture at three levels (Context, Container, Component)
- ✅ Well-documented design decisions
- ✅ Version-controlled and maintainable
- ✅ Suitable for portfolio presentation
- ✅ Useful for interview discussions
- ✅ Demonstrates architecture skills

---

**Created**: February 4, 2026
**Last Updated**: February 4, 2026
**Owner**: Christos Michaelides
**Project**: VPS Sandbox Platform C4 Architecture
**Status**: 🚧 Planning - Ready for architecture definition
