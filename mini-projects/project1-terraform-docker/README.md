# Project 1: Terraform + Docker - Provision NGINX Container

> Learn Terraform fundamentals by provisioning Docker containers locally. **[View source on GitHub](https://github.com/christosm-dev/portfolio/tree/main/mini-projects/project1-terraform-docker)**

## Project Overview

This project demonstrates Terraform fundamentals using the Docker provider to provision infrastructure locally. The Terraform configuration pulls an official NGINX image, creates a container with port mapping, and manages the full lifecycle (init, plan, apply, destroy) - demonstrating declarative Infrastructure as Code principles without requiring cloud provider accounts.

```
┌───────────────────────────────────────────────────────┐
│                     Local Machine                     │
│                                                       │
│  terraform apply                                      │
│       │                                               │
│       ▼                                               │
│  ┌──────────┐  lock + read/write state  ┌──────────┐  │
│  │Terraform │ ────────────────────────► │  Consul  │  │
│  │   CLI    │ ◄──────────────────────── │ :8500    │  │
│  └────┬─────┘                           └──────────┘  │
│       │ Docker provider API                           │
│       ▼                                               │
│  ┌──────────────────────────────────┐                 │
│  │          Docker Engine           │                 │
│  │  ┌────────────┐  ┌────────────┐  │                 │
│  │  │    NGINX   │  │   Consul   │  │                 │
│  │  │ :8080→80   │  │   :8500    │  │                 │
│  │  └────────────┘  └────────────┘  │                 │
│  └──────────────────────────────────┘                 │
└───────────────────────────────────────────────────────┘
         │                    │
         ▼                    ▼
 http://localhost:8080   http://localhost:8500 (UI)
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
- **Remote state backend** via Consul with state locking
- Output values for deployment information

## Codebase Overview

```
project1-terraform-docker/
├── main.tf                    # Core Terraform config: provider, image, and container resources
├── backend.tf                 # Consul remote state backend configuration
├── variables.tf               # Input variable declarations with defaults and validation
├── outputs.tf                 # Output definitions: container ID, name, image ID, access URL
├── docker-compose.consul.yml  # Runs a local Consul node as the state backend
├── .gitignore                 # Excludes Terraform state files and working directories
└── README.md                  # This file
```

## Quick Start

### Prerequisites

```bash
terraform version   # must be v1.x
docker info         # Docker daemon must be running
docker compose version
```

### 1. Start Consul (state backend)

Consul must be running before `terraform init` so Terraform can connect to the backend.

```bash
cd mini-projects/project1-terraform-docker

docker compose -f docker-compose.consul.yml up -d
```

Consul UI is now available at **http://localhost:8500**. You can watch state appear there after `apply`.

### 2. Initialise Terraform

`terraform init` reads `backend.tf` and connects to Consul. If you had a previous local state file, Terraform will offer to migrate it automatically.

```bash
terraform init
```

Expected output includes:
```
Initializing the backend...
Successfully configured the backend "consul"!
```

### 3. Deploy

```bash
# Preview the resources Terraform will create
terraform plan

# Create the NGINX container (state is written to Consul, not local disk)
terraform apply
# Confirm with 'yes' when prompted
```

Terraform prints the output values (container name, ID, and access URL) after apply completes.

### 4. Verify

```bash
# NGINX web server
curl http://localhost:8080
# Expected: NGINX welcome page HTML

# State stored in Consul (raw JSON)
curl http://localhost:8500/v1/kv/project1/terraform.tfstate?raw
```

### 5. Inspect state

```bash
# List all resources tracked in state
terraform state list

# Show detailed attributes of the container resource
terraform state show docker_container.nginx
```

### 6. Tear down

```bash
# Remove the NGINX container (state entry in Consul is updated, not deleted)
terraform destroy
# Confirm with 'yes'

# Stop Consul when you're done
docker compose -f docker-compose.consul.yml down
```

## Terraform Associate Exam Alignment

This project covers **Objective 7: Manage state** directly:

| Exam Topic | Where It Appears |
|---|---|
| Purpose of remote state (collaboration, locking, durability) | `backend.tf` comments |
| `terraform init` backend initialisation and state migration | Step 2 of Quick Start |
| State locking (preventing concurrent apply corruption) | `lock = true` in `backend.tf` |
| Inspecting state with `terraform state list` / `state show` | Step 5 of Quick Start |
| Why state files must not be committed to version control | `.gitignore` entries |

**Interview talking point**: *"I replaced local state with a Consul backend. This means state is no longer on my laptop — it's stored in Consul's key-value store with locking enabled, so two simultaneous `terraform apply` runs can't corrupt it. The pattern maps directly to using S3 + DynamoDB in AWS, which is the production standard."*

## Future Work

- [x] ~~Implement remote state backend (S3 or Consul) instead of local state~~ ✅ Done — Consul backend with locking
- [ ] Add a second container (e.g. Redis) to demonstrate multi-resource dependencies
- [ ] Create Terraform modules to make the configuration reusable
- [ ] Add `terraform fmt` and `terraform validate` as pre-commit hooks
- [ ] Migrate to S3 backend as an AWS-aligned alternative

## Resources

- [Terraform Docker Provider Docs](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs)
- [HashiCorp Learn - Get Started with Docker](https://learn.hashicorp.com/collections/terraform/docker-get-started)
- [Terraform CLI Documentation](https://www.terraform.io/cli)
