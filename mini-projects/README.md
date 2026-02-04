# Infrastructure as Code & DevOps Mini-Projects

A collection of hands-on projects for building expertise in modern infrastructure automation, container orchestration, and configuration management. These projects support certification preparation for HashiCorp Terraform Associate, Kubernetes (CKA/CKAD), and Red Hat Ansible Automation.

---

## 🎯 Project Goals

- Build practical skills in **Terraform**, **Kubernetes**, and **Ansible**
- Gain hands-on experience with infrastructure automation
- Prepare for industry-recognized certifications
- Create a portfolio demonstrating DevOps capabilities
- Target fully remote DevOps, SRE, Cloud Engineering, and Platform Engineering roles

---

## 📚 Project Structure

This repository contains 7 progressive projects organized into three skill areas:

### Beginner Projects (1-3)
Introduction to core concepts and basic workflows

### Intermediate Projects (4-6)
Integration of multiple tools and more complex scenarios

### Advanced Project (7)
Complete CI/CD pipeline combining all technologies

---

## 🗂️ Projects Overview

### Project 1: Terraform + Docker
**Status:** ✅ Complete  
**Difficulty:** Beginner  
**Technologies:** Terraform, Docker  
**Description:** Learn Terraform fundamentals by provisioning Docker containers locally.

**Key Concepts:**
- Terraform configuration language (HCL)
- Provider management
- Resource declaration and dependencies
- Variables, outputs, and state management
- Terraform workflow: init → plan → apply → destroy

**Certification Focus:** HashiCorp Certified: Terraform Associate

📁 **Location:** `/project1-terraform-docker/`

---

### Project 2: Kubernetes + Minikube
**Status:** ✅ Complete  
**Difficulty:** Beginner  
**Technologies:** Kubernetes, Docker, Minikube, Python, Flask  
**Description:** Deploy a containerized Python Flask application to a local Kubernetes cluster.

**Key Concepts:**
- Kubernetes architecture (Pods, Deployments, Services)
- Container orchestration and replica management
- kubectl command-line tool
- YAML manifests for declarative configuration
- Health checks (liveness and readiness probes)
- Service discovery and load balancing

**Certification Focus:** Certified Kubernetes Administrator (CKA) / CKAD

📁 **Location:** `/project2-k8s-python-app/`

---

### Project 3: Ansible + Docker
**Status:** ✅ Complete  
**Difficulty:** Beginner  
**Technologies:** Ansible, Docker, SSH  
**Description:** Use Ansible to automate configuration management across multiple Docker containers.

**Key Concepts:**
- Ansible inventory and playbooks
- Idempotent automation
- Configuration management at scale
- Jinja2 templating for dynamic configurations
- Handlers for service management
- Ad-hoc commands for quick tasks
- Variables and facts

**Certification Focus:** Red Hat Certified Specialist in Ansible Automation

📁 **Location:** `/project3-ansible-docker/`

---

### Project 4: Terraform + Kubernetes Integration
**Status:** 🔄 Planned  
**Difficulty:** Intermediate  
**Technologies:** Terraform, Kubernetes  
**Description:** Use Terraform to provision a Kubernetes cluster and deploy applications declaratively.

**Key Concepts:**
- Terraform Kubernetes provider
- Managing k8s resources as code
- Combining infrastructure and application deployment
- State management for k8s resources
- Terraform modules for reusability

**Certification Focus:** Terraform Associate + CKA/CKAD

📁 **Location:** `/project4-terraform-k8s/`

---

### Project 5: Ansible + Docker Advanced
**Status:** 🔄 Planned  
**Difficulty:** Intermediate  
**Technologies:** Ansible, Docker, Docker Compose  
**Description:** Create Ansible playbooks to automate Docker host setup and containerized application deployment.

**Key Concepts:**
- Ansible roles for organization
- Docker container management with Ansible
- Multi-container orchestration
- Ansible Vault for secrets management
- Dynamic inventories
- Advanced playbook patterns

**Certification Focus:** Ansible Automation

📁 **Location:** `/project5-ansible-docker-advanced/`

---

### Project 6: Full Stack - Terraform + Ansible + Kubernetes
**Status:** 🔄 Planned  
**Difficulty:** Intermediate  
**Technologies:** Terraform, Ansible, Kubernetes  
**Description:** Build a complete infrastructure solution integrating all three tools.

**Key Concepts:**
- Infrastructure provisioning with Terraform
- Configuration management with Ansible
- Application deployment to Kubernetes
- Tool integration and workflow orchestration
- End-to-end automation pipeline

**Certification Focus:** All three certifications

📁 **Location:** `/project6-full-stack/`

---

### Project 7: Complete CI/CD Pipeline
**Status:** 🔄 Planned  
**Difficulty:** Advanced  
**Technologies:** Terraform, Ansible, Kubernetes, Git, CI/CD  
**Description:** Design and implement a complete CI/CD pipeline using all three automation tools.

**Key Concepts:**
- Git-based workflow
- Automated testing
- Infrastructure as Code best practices
- Continuous deployment to Kubernetes
- Monitoring and observability
- Production-ready patterns

**Certification Focus:** All three certifications + DevOps practices

📁 **Location:** `/project7-cicd-pipeline/`

---

## 🎓 Certification Targets

### HashiCorp Certified: Terraform Associate (003)
- **Covered in:** Projects 1, 4, 6, 7
- **Key Topics:** Configuration language, providers, state, modules, workflows
- **Resources:** [HashiCorp Learn](https://learn.hashicorp.com)

### Certified Kubernetes Administrator (CKA)
- **Covered in:** Projects 2, 4, 6, 7
- **Key Topics:** Cluster architecture, workloads, services, storage, troubleshooting
- **Resources:** [Kubernetes Docs](https://kubernetes.io/docs/), [CNCF Training](https://training.linuxfoundation.org/certification/certified-kubernetes-administrator-cka/)

### Certified Kubernetes Application Developer (CKAD)
- **Covered in:** Projects 2, 4, 6, 7
- **Key Topics:** Application design, deployment, observability, services
- **Alternative to CKA:** More development-focused

### Red Hat Certified Specialist in Ansible Automation
- **Covered in:** Projects 3, 5, 6, 7
- **Key Topics:** Playbooks, roles, modules, variables, Ansible Vault
- **Resources:** [Ansible Docs](https://docs.ansible.com), [Red Hat Training](https://www.ansible.com/products/training-certification)

---

## 🛠️ Technology Stack

**Core Tools:**
- **Terraform** - Infrastructure as Code
- **Kubernetes** - Container orchestration
- **Ansible** - Configuration management
- **Docker** - Containerization
- **Minikube** - Local Kubernetes development

**Languages:**
- **HCL** - Terraform configuration
- **YAML** - Kubernetes manifests, Ansible playbooks
- **Python** - Example applications
- **Jinja2** - Ansible templating
- **Bash** - Scripting and automation

**Development Environment:**
- **WSL** (Windows Subsystem for Linux)
- **VS Code** - Code editor with Claude Code integration
- **Git** - Version control

---

## 📋 Prerequisites

### Required Software

1. **Docker Desktop** or Docker Engine
   ```bash
   docker --version
   ```

2. **Terraform**
   ```bash
   terraform --version
   ```

3. **Kubernetes CLI (kubectl)**
   ```bash
   kubectl version --client
   ```

4. **Minikube** (for local k8s development)
   ```bash
   minikube version
   ```

5. **Ansible**
   ```bash
   ansible --version
   ```

### Installation Guides

See individual project READMEs for detailed installation instructions specific to your operating system.

---

## 🚀 Getting Started

### Clone the Repository
```bash
git clone <repository-url>
cd mini-projects
```

### Start with Project 1
```bash
cd project1-terraform-docker
# Follow the README.md instructions
```

### Progress Through Projects Sequentially

Projects build on each other, so it's recommended to complete them in order:
1. Project 1 - Terraform basics
2. Project 2 - Kubernetes basics
3. Project 3 - Ansible basics
4. Project 4 - Terraform + Kubernetes
5. Project 5 - Advanced Ansible
6. Project 6 - Full integration
7. Project 7 - Complete pipeline

---

## 📖 Learning Approach

### For Each Project:

1. **Read the README thoroughly** - Understand concepts before coding
2. **Follow step-by-step instructions** - Don't skip steps
3. **Experiment with variations** - Try the suggested experiments
4. **Document your learnings** - Keep notes on challenges and solutions
5. **Build incrementally** - Start simple, add complexity
6. **Practice repeatedly** - Destroy and rebuild to reinforce learning

### Best Practices:

- **Version control everything** - Commit often with clear messages
- **Use descriptive names** - Make code self-documenting
- **Add comments** - Explain non-obvious logic
- **Test thoroughly** - Verify each component works
- **Clean up resources** - Don't leave containers/VMs running unnecessarily

---

## 🎯 Career Focus

These projects target the following remote positions:

### Target Roles:
- DevOps Engineer
- Site Reliability Engineer (SRE)
- Cloud Engineer (AWS, Azure, GCP)
- Platform Engineer
- Infrastructure Engineer
- Kubernetes Administrator
- Automation Engineer

### Target Industries:
- Financial Services
- Healthcare Technology
- Aerospace & Defense
- Enterprise SaaS
- Manufacturing
- Government Contracting

### Why These Skills Matter:
- **High demand** - Infrastructure automation is critical for modern operations
- **Remote-friendly** - These roles commonly offer fully remote options
- **Well-compensated** - Strong market value for these skill combinations
- **Career growth** - Foundation for senior and architect-level positions

---

## 📊 Progress Tracking

### Completed Projects: 3/7 (43%)

- [x] Project 1: Terraform + Docker
- [x] Project 2: Kubernetes + Minikube  
- [x] Project 3: Ansible + Docker
- [ ] Project 4: Terraform + Kubernetes
- [ ] Project 5: Ansible + Docker Advanced
- [ ] Project 6: Full Stack Integration
- [ ] Project 7: CI/CD Pipeline

### Skills Acquired:

**Terraform:**
- [x] Basic configuration and syntax
- [x] Provider management
- [x] Resource dependencies
- [x] Variables and outputs
- [ ] Modules and workspaces
- [ ] Remote state management
- [ ] Advanced patterns

**Kubernetes:**
- [x] Pods, Deployments, Services
- [x] kubectl basics
- [x] Health checks
- [x] Load balancing
- [ ] ConfigMaps and Secrets
- [ ] Persistent storage
- [ ] Advanced networking

**Ansible:**
- [x] Playbooks and tasks
- [x] Inventory management
- [x] Idempotency
- [x] Templates (Jinja2)
- [x] Handlers
- [ ] Roles
- [ ] Ansible Vault
- [ ] Dynamic inventories

---

## 🔗 Additional Resources

### Official Documentation
- [Terraform Documentation](https://www.terraform.io/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Ansible Documentation](https://docs.ansible.com/)
- [Docker Documentation](https://docs.docker.com/)

### Learning Platforms
- [HashiCorp Learn](https://learn.hashicorp.com/)
- [Kubernetes By Example](http://kubernetesbyexample.com/)
- [Ansible for DevOps](https://www.ansiblefordevops.com/)
- [KodeKloud](https://kodekloud.com/) - Interactive labs

### Practice & Certification
- [Terraform Associate Practice](https://learn.hashicorp.com/terraform)
- [Killer.sh](https://killer.sh/) - CKA/CKAD practice exams
- [Ansible Galaxy](https://galaxy.ansible.com/) - Reusable roles

### Community
- [r/Terraform](https://reddit.com/r/terraform)
- [r/Kubernetes](https://reddit.com/r/kubernetes)
- [r/Ansible](https://reddit.com/r/ansible)
- [DevOps Slack/Discord communities]

---

## 🤝 Contributing

This is a personal learning repository, but feedback and suggestions are welcome!

### If You Find Issues:
- Document the problem clearly
- Include error messages and logs
- Note your environment (OS, versions)
- Suggest a fix if possible

---

## 📝 Notes & Lessons Learned

### Key Takeaways So Far:

**Project 1 (Terraform):**
- Always use `eval $(minikube docker-env)` when building images for Minikube
- Variables make configurations reusable and maintainable
- Terraform state is critical - handle with care

**Project 2 (Kubernetes):**
- WSL networking requires special consideration for accessing services
- `imagePullPolicy: Never` requires images to exist in Minikube's container runtime
- Use `minikube image load` to make Docker images available to Kubernetes
- Health checks are essential for production-ready deployments

**Project 3 (Ansible):**
- Idempotency is a core principle - design tasks to be safely repeatable
- Templates (Jinja2) enable dynamic, host-specific configurations
- Handlers ensure services restart only when necessary
- Ad-hoc commands are powerful for quick tasks

### Common Patterns:
- Start simple, add complexity incrementally
- Test each component independently before integration
- Documentation is as important as code
- Clean up resources after experimentation

---

## 🗓️ Project Timeline

- **Week 1-2:** Projects 1-3 (Basics) ✅ Complete
- **Week 3-4:** Projects 4-5 (Intermediate) 🔄 In Progress
- **Week 5-6:** Project 6 (Integration) 🔄 Planned
- **Week 7-8:** Project 7 (CI/CD) 🔄 Planned

---

## 📧 Contact & Portfolio

**GitHub:** [Your GitHub Profile]  
**LinkedIn:** [Your LinkedIn Profile]  
**Portfolio:** [Your Portfolio Site]

---

## 📄 License

This project is for educational purposes. Individual tools and technologies are subject to their respective licenses.

---

**Last Updated:** January 22, 2025  
**Status:** Active Development (3/7 projects complete)  
**Next Milestone:** Project 4 - Terraform + Kubernetes Integration
