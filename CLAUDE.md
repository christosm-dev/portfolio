# Portfolio Project Structure - Instructions for Claude

This document provides context and guidelines for working on Christos's DevOps/SRE portfolio projects. These projects demonstrate skills for transitioning from telecommunications DevOps to industries such as aerospace, defense, fintech, healthcare and other sectors with longer time-to-market.

## 🎯 Career Goals Context

**Current Role**: Telecommunications DevOps/Release Management  
**Target Roles**: DevOps Engineer, SRE, Cloud Engineer, Platform Engineer, Infrastructure Engineer  
**Target Industries**: Aerospace/Defense (Surrey, UK), Financial Services, Healthcare Tech, Enterprise SaaS, Government  
**Location**: Surrey, UK  
**Work Preference**: Fully remote or hybrid roles  

**Certification Path**:
- HashiCorp Certified: Terraform Associate (in progress)
- Certified Kubernetes Administrator (CKA) (planned)
- Certified Kubernetes Application Developer (CKAD) (planned)
- Red Hat Certified Specialist in Ansible Automation (planned)

## 📁 Project Structure Overview

```
portfolio-root/
├── CLAUDE.md                                   # This file - context for Claude
├── README.md                                   # Portfolio overview and navigation
├── sync_docs.sh                                # Syncs all project READMEs to christosm.dev
├── setup-hooks.sh                              # One-shot hook + submodule setup
│
├── .github/
│   └── workflows/
│       ├── project5-ci-cd.yml                  # Project 5: test → build → deploy pipeline
│       └── project7-image-updater.yml          # Project 7: image tag writeback for ArgoCD
│
├── mini-projects/                              # Foundational learning projects
│   ├── project1-terraform-docker/             # Project 1: Terraform basics
│   ├── project2-k8s-python-app/               # Project 2: Kubernetes fundamentals
│   ├── project3-ansible-docker/               # Project 3: Ansible automation
│   ├── project4-monitoring-stack/             # Project 4: Prometheus + Grafana
│   ├── project5-cicd-github-actions/          # Project 5: GitHub Actions CI/CD
│   ├── project6-helm-chart/                   # Project 6: Helm chart packaging
│   └── project7-gitops-argocd/                # Project 7: GitOps with ArgoCD
│
├── christosm.dev/                             # Zensical static site (git submodule)
│
└── vps-demo-platform/                         # Advanced showcase project (planning)
```

## 📋 Project Descriptions

### 1. terraform-docker-nginx
**Purpose**: Demonstrate Terraform fundamentals and Infrastructure as Code  
**Technologies**: Terraform, Docker, NGINX  
**Complexity**: Beginner-friendly, foundational  
**Certification Alignment**: Terraform Associate  

**Key Concepts**:
- Terraform providers (Docker provider)
- Resource management (containers, networks, volumes)
- State management
- Variables and outputs
- Basic infrastructure provisioning

**Typical Tasks**:
- Create Terraform configurations for Docker containers
- Provision NGINX web servers
- Manage container lifecycle
- Document infrastructure decisions

### 2. k8s-python-app
**Purpose**: Demonstrate Kubernetes fundamentals and application deployment  
**Technologies**: Kubernetes (Minikube/K3s), Python (Flask/FastAPI), Docker  
**Complexity**: Intermediate  
**Certification Alignment**: CKA, CKAD  

**Key Concepts**:
- Kubernetes objects (Pods, Deployments, Services)
- ConfigMaps and Secrets
- Resource limits and requests
- Health checks (liveness/readiness probes)
- Ingress controllers
- Basic monitoring

**Typical Tasks**:
- Create Kubernetes manifests
- Deploy Python applications
- Configure service discovery
- Implement health checks
- Troubleshoot deployments

### 3. ansible-docker-demo
**Purpose**: Demonstrate Ansible automation and configuration management  
**Technologies**: Ansible, Docker, Linux  
**Complexity**: Beginner-intermediate  
**Certification Alignment**: Red Hat Ansible Automation  

**Key Concepts**:
- Ansible playbooks
- Inventory management
- Idempotent operations
- Jinja2 templating
- Role-based organization
- Container management with Ansible

**Typical Tasks**:
- Write Ansible playbooks
- Configure Docker hosts
- Manage container deployments
- Automate infrastructure tasks
- Document automation patterns

### 4. monitoring-stack
**Purpose**: Demonstrate observability fundamentals with dashboards as code
**Technologies**: Prometheus, Grafana, Node Exporter, Flask, Docker Compose
**Complexity**: Intermediate
**Certification Alignment**: CKA (monitoring)

**Key Concepts**:
- Metrics collection and time-series storage (Prometheus)
- Dashboard provisioning as code (Grafana JSON)
- Application instrumentation (prometheus_client)
- Node Exporter for host system metrics
- Docker Compose multi-service orchestration

### 5. cicd-github-actions
**Purpose**: Demonstrate CI/CD fundamentals with a real three-job pipeline
**Technologies**: GitHub Actions, Docker, GHCR, Kubernetes (Minikube), Python/Flask
**Complexity**: Intermediate
**Certification Alignment**: CKAD (CI/CD patterns)

**Key Concepts**:
- Three-job dependency chain (test → build → deploy)
- Path-based trigger filters
- GHCR image publishing with SHA and latest tags
- Minikube deployment inside a GitHub Actions runner
- Smoke testing via port-forward

### 6. helm-chart
**Purpose**: Demonstrate Helm chart packaging and lifecycle management
**Technologies**: Helm 3, Kubernetes, Go templates
**Complexity**: Intermediate
**Certification Alignment**: CKAD (Helm)

**Key Concepts**:
- Chart.yaml metadata and versioning
- Parameterised templates with values overrides
- Environment-specific values files (dev/prod)
- Named templates in _helpers.tpl
- Conditional resources (HPA)
- ConfigMap checksum annotation for rolling restarts

### 7. gitops-argocd
**Purpose**: Demonstrate pull-based GitOps with self-healing cluster reconciliation
**Technologies**: ArgoCD, Kubernetes, Helm, GitHub Actions
**Complexity**: Intermediate-Advanced
**Certification Alignment**: CKAD (GitOps/CD patterns), CKA (cluster tooling)

**Key Concepts**:
- ArgoCD Application CRD
- Pull-based vs push-based CD (contrast with Project 5)
- Automated sync with selfHeal and prune
- Inline Helm values in Application manifests
- Image tag writeback workflow (workflow_run trigger)
- Self-healing demonstration

### 8. christosm.dev (Zensical)
**Purpose**: Static site generator for technical documentation and portfolio  
**Technologies**: Static Site Generator (Hugo/Jekyll/Next.js), Markdown, HTML/CSS  
**Complexity**: Varies  

**Key Concepts**:
- Static site generation
- Content management
- Documentation as code
- Responsive design
- Deployment pipelines

**Typical Tasks**:
- Generate documentation sites
- Create blog posts
- Maintain portfolio content
- Deploy to hosting platforms

### 5. vps-demo-platform
**Purpose**: Advanced showcase project demonstrating production-grade skills  
**Technologies**: Docker, Kubernetes, Terraform, FastAPI, Security hardening  
**Complexity**: Advanced  
**Certification Alignment**: All certifications  

**Key Concepts**:
- Multi-phase architecture (Docker → Kubernetes)
- Defense-in-depth security
- Production deployment patterns
- Resource management
- Monitoring and observability
- Enterprise patterns

**Typical Tasks**:
- Production-grade implementations
- Security hardening
- Performance optimization
- Comprehensive documentation
- Interview preparation materials

## 🎨 Documentation Standards

### Every Project Should Have:

1. **README.md** at root level containing:

    - Project overview and purpose
    - Technologies used
    - Quick start guide
    - Architecture overview
    - Links to detailed documentation

2. **docs/** directory with:

    - Detailed documentation
    - Architecture diagrams (when applicable)
    - Deployment guides
    - Troubleshooting guides
    - Interview talking points

3. **Code quality**:

    - Clear comments explaining complex logic
    - Consistent formatting
    - Security best practices
    - Error handling
    - Logging where appropriate

4. **Configuration files**:

    - `.gitignore` (exclude secrets, temporary files)
    - Example configuration files (`.example` suffix)
    - Clear documentation of required variables

## 🔐 Security Guidelines

**Critical**: Never commit sensitive information to version control.

**Always exclude**:
- API keys, tokens, passwords
- Private SSH keys
- Cloud provider credentials
- `.tfstate` files (use remote backend)
- Personal information
- VPS IP addresses (unless necessary)

**Always include**:
- `.example` files for configuration templates
- Documentation on how to obtain/configure secrets
- Security best practices in documentation
- References to security features implemented

## 📝 Working with Claude Guidelines

### Context Provision
When starting work on a project, provide:
- Which project (by number/name)
- Current phase or goal
- Specific technologies involved
- Any blockers or issues

### Code Creation
- **Verbose explanations**: Christos prefers detailed explanations when introducing new concepts
- **Complete codebases**: Provide full, working code rather than snippets
- **Documentation**: Include README files with context
- **Progressive complexity**: Start simple, build up to advanced

### File Management
- Always use `/home/claude` as working directory
- Move final outputs to `/mnt/user-data/outputs/`
- Create zip files for multi-file projects
- Maintain project structure consistently

### Documentation Style
- Clear, professional tone
- Suitable for portfolio/interview use
- Include "why" not just "how"
- Career context and talking points
- Certification alignment notes

## 🎯 Career Alignment

### For Each Project, Consider:

**Interview Talking Points**:
- What problem does it solve?
- What technologies/patterns does it demonstrate?
- What decisions did you make and why?
- What would you do differently at scale?

**Certification Relevance**:
- Which exam topics does it cover?
- How can it be used as study material?
- What hands-on practice does it provide?

**Industry Relevance**:
- Aerospace/Defense: Emphasize security, reliability
- Financial Services: Highlight compliance, audit trails
- Healthcare: Focus on data protection, reliability
- Government: Showcase security clearance suitability

## 🔄 Project Evolution

Projects may evolve through phases:

1. **Phase 1: Foundation** - Basic working implementation
2. **Phase 2: Production** - Hardening, security, monitoring
3. **Phase 3: Advanced** - Scaling, optimization, advanced features

Document each phase separately to show progression and learning.

## 📊 Success Criteria

Each project should:
- ✅ Run successfully (locally and/or deployed)
- ✅ Have comprehensive documentation
- ✅ Demonstrate best practices
- ✅ Include security considerations
- ✅ Provide interview material
- ✅ Align with certification goals
- ✅ Be portfolio-ready (public GitHub)

## 🚀 Deployment Targets

**Development/Testing**:
- Local machine (WSL, Docker Desktop)
- Minikube (Kubernetes)
- Local Docker daemon

**Production/Demo**:
- Contabo VPS (primary)
- Cloud providers (AWS, GCP, Azure) - optional
- GitHub Pages (static sites)

## 📞 Communication Style

**Christos prefers**:
- Detailed technical explanations
- Complete working examples
- Comprehensive documentation
- Progressive learning approach
- Career-focused context
- Interview preparation insights

**Avoid**:
- Oversimplification without context
- Partial code snippets without full examples
- Assumptions about prior knowledge
- Generic advice without career relevance

## 🎓 Learning Philosophy

These projects serve multiple purposes:
1. **Hands-on learning** - Build real skills through practice
2. **Certification preparation** - Align with exam objectives
3. **Portfolio building** - Demonstrate capabilities to employers
4. **Interview preparation** - Provide discussion material
5. **Career transition** - Bridge from telecoms to target industries

Each project should support all five purposes where possible.

## 📖 Quick Reference Commands

### Starting a New Project Session
```bash
# Navigate to project
cd /home/claude/<project-name>

# Check project structure
ls -la

# Review README
cat README.md
```

### Completing Work
```bash
# Copy to outputs
cp -r /home/claude/<project-name> /mnt/user-data/outputs/

# Or create zip
cd /mnt/user-data/outputs
zip -r <project-name>.zip <project-name>/

# Present to user
# Use present_files tool
```

### File Organization
```bash
# Create standard structure
mkdir -p {terraform,k8s,ansible,docs,scripts}

# Create standard files
touch README.md .gitignore
```

## 🔄 Iterative Development

Projects will be developed iteratively:
1. **Initial implementation** - Get it working
2. **Documentation** - Explain what was built
3. **Enhancement** - Add features/complexity
4. **Optimization** - Improve performance/security
5. **Interview prep** - Add talking points

Each iteration should be clearly documented.

## 📝 Notes for Claude

- Christos is hands-on and wants to understand the "why" behind decisions
- Security is important (targeting SC clearance roles)
- Documentation should be interview-ready
- Code should be production-quality where possible
- Always think about how projects demonstrate skills for target roles
- Link concepts to certification exam topics when relevant

## 🎯 Current Focus

As of March 2026, the current priorities are:

1. **Mini projects (1-7)** - ✅ All complete and documented
2. **christosm.dev** - ✅ Auto-sync system live; docs published on every commit
3. **Future Work items** - Iterating on enhancements across all seven mini-projects
4. **vps-demo-platform** - Planning phase (not yet started)
5. **Terraform certification preparation** - Ongoing
6. **Kubernetes learning** - Preparing for CKA/CKAD

## 📊 Project Status Tracking

Use these markers in project READMEs:

- 🚧 **Planning** - Concept and architecture phase
- 🏗️ **In Development** - Active implementation
- ✅ **Complete** - Working and documented
- 🚀 **Deployed** - Live on VPS or cloud
- 📝 **Documented** - Interview-ready documentation
- 🎯 **Portfolio Ready** - Public and presentable

---

**Last Updated**: March 6, 2026
**Portfolio Owner**: Christos  
**Career Focus**: DevOps/SRE/Cloud/Platform Engineering  
**Geographic Focus**: UK (Surrey), Fully Remote  
**Target Industries**: Aerospace, Defense, FinTech, HealthTech, Enterprise SaaS

---

## Quick Project Reference

| Project | Status | Complexity | Primary Tech | Cert Alignment |
|---------|--------|------------|--------------|----------------|
| project1-terraform-docker | ✅ Complete | Beginner | Terraform, Docker | Terraform Associate |
| project2-k8s-python-app | ✅ Complete | Intermediate | Kubernetes, Python | CKA, CKAD |
| project3-ansible-docker | ✅ Complete | Beginner-Int | Ansible, Docker | RHCSA Ansible |
| project4-monitoring-stack | ✅ Complete | Intermediate | Prometheus, Grafana | CKA (monitoring) |
| project5-cicd-github-actions | ✅ Complete | Intermediate | GitHub Actions, Docker | CKAD |
| project6-helm-chart | ✅ Complete | Intermediate | Helm 3, K8s | CKAD (Helm) |
| project7-gitops-argocd | ✅ Complete | Int-Advanced | ArgoCD, K8s, Helm | CKAD, CKA |
| christosm.dev | ✅ Live | Varies | Zensical, Markdown | - |
| vps-demo-platform | 🚧 Planning | Advanced | All | All |

Use this table to quickly understand project status and focus areas.
