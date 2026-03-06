# Project 1: Terraform + Docker - Provision NGINX Container

> Learn Terraform fundamentals by provisioning Docker containers locally. **[View source on GitHub](https://github.com/christosm-dev/portfolio/tree/main/mini-projects/project1-terraform-docker)**

## Project Overview

This project demonstrates Terraform fundamentals using the Docker provider to provision infrastructure locally. The Terraform configuration pulls an official NGINX image, creates a container with port mapping, and manages the full lifecycle (init, plan, apply, destroy) - demonstrating declarative Infrastructure as Code principles without requiring cloud provider accounts.

```
┌──────────────────────────────────────────┐
│               Local Machine              │
│                                          │
│  terraform apply                         │
│       │                                  │
│       ▼                                  │
│  ┌─────────────────┐                     │
│  │    Terraform     │  reads/writes       │
│  │   terraform.    │◄───────────────┐    │
│  │   tfstate        │                │    │
│  └────────┬────────┘                │    │
│           │ Docker provider API     │    │
│           ▼                         │    │
│  ┌──────────────────────────────┐   │    │
│  │        Docker Engine         │   │    │
│  │  ┌──────────────────────┐   │   │    │
│  │  │   NGINX Container    │   │   │    │
│  │  │   port 8080 → 80     │   │   │    │
│  │  └──────────────────────┘   │   │    │
│  └──────────────────────────────┘   │    │
└──────────────────────────────────────────┘
              │
              ▼
    http://localhost:8080
```

## Technology Stack

| Technology | Role |
|------------|------|
| Terraform | Infrastructure as Code - declarative resource provisioning |
| Docker | Container runtime targeted by the Terraform Docker provider |
| NGINX | Web server deployed as the managed container |
| HCL | HashiCorp Configuration Language for Terraform files |

## Key Features

- Declarative infrastructure provisioning with Terraform HCL
- Docker provider integration for local container management
- Resource dependency chaining (image → container)
- State management for tracking deployed infrastructure
- Output values for deployment information

## Codebase Overview

```
project1-terraform-docker/
├── main.tf           # Core Terraform config: provider, image, and container resources
├── outputs.tf        # Output definitions: container ID, name, image ID, access URL
├── .gitignore        # Excludes Terraform state files and working directories
└── README.md         # This file
```

## Quick Start

### Prerequisites

```bash
terraform version   # must be v1.x
docker info         # Docker daemon must be running
```

### Deploy

```bash
cd mini-projects/project1-terraform-docker

# Download the Docker provider plugin
terraform init

# Preview the resources Terraform will create
terraform plan

# Create the NGINX container
terraform apply

# Confirm with 'yes' when prompted
```

Terraform prints the output values (container name, ID, and access URL) after apply completes.

### Verify

```bash
curl http://localhost:8080
# Expected: NGINX welcome page HTML
```

### Inspect state

```bash
# List all resources tracked in state
terraform state list

# Show detailed attributes of the container resource
terraform state show docker_container.nginx
```

### Tear down

```bash
terraform destroy
# Confirm with 'yes' — removes the container and releases the port
```

## Future Work

- [ ] Add Terraform variables for container port, image tag, and replica count
- [ ] Implement remote state backend (S3 or Consul) instead of local state
- [ ] Add a second container (e.g. Redis) to demonstrate multi-resource dependencies
- [ ] Create Terraform modules to make the configuration reusable
- [ ] Add `terraform fmt` and `terraform validate` as pre-commit hooks

## Resources

- [Terraform Docker Provider Docs](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs)
- [HashiCorp Learn - Get Started with Docker](https://learn.hashicorp.com/collections/terraform/docker-get-started)
- [Terraform CLI Documentation](https://www.terraform.io/cli)
