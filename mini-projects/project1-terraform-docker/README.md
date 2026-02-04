# Project 1: Terraform + Docker - Provision nginx Container

**Project Series:** 1 of 7  
**Difficulty:** Beginner  
**Technologies:** Terraform, Docker  
**Goal:** Learn Terraform basics by provisioning a Docker container locally

---

## 📋 Project Overview

This is the first project in a series of 7 designed to build expertise in infrastructure automation tools (Terraform, Kubernetes, and Ansible) for cloud engineering and DevOps roles. This beginner project focuses on understanding Terraform fundamentals by managing Docker containers as infrastructure.

### What You'll Learn

- **Terraform Basics:** Configuration syntax, providers, and resources
- **Terraform Workflow:** init, plan, apply, destroy lifecycle
- **Infrastructure as Code:** Declarative infrastructure management
- **State Management:** Understanding Terraform state files
- **Docker Provider:** Using Terraform with the Docker provider

---

## 🎯 Certification Path Context

This project supports preparation for:
- **HashiCorp Certified: Terraform Associate (003)**

Skills practiced:
- Understanding Terraform's purpose and basic concepts
- Managing infrastructure with the Terraform workflow
- Working with providers and resources
- Understanding Terraform state

---

## 🏗️ What This Project Does

This Terraform configuration:
1. Pulls the official nginx image from Docker Hub
2. Creates a Docker container running nginx
3. Maps container port 80 to host port 8080
4. Provides outputs showing container details and access URL

**End Result:** A running nginx web server accessible at `http://localhost:8080`

---

## 📁 Project Structure

```
terraform-docker-nginx/
├── main.tf           # Main Terraform configuration
├── outputs.tf        # Output definitions
├── .gitignore        # Git ignore rules
└── README.md         # This file
```

### File Explanations

**main.tf**
- Contains the core Terraform configuration
- Defines the Docker provider connection
- Declares the nginx image and container resources

**outputs.tf**
- Defines what information Terraform displays after deployment
- Shows container ID, name, image ID, and access URL

**.gitignore**
- Prevents sensitive files (state files, credentials) from being committed to Git
- Excludes Terraform working directories

---

## 🚀 Prerequisites

Before starting, ensure you have:

1. **Terraform installed** (v1.0+)
   ```bash
   terraform version
   ```

2. **Docker Desktop running** (or Docker Engine)
   ```bash
   docker ps
   ```

3. **WSL2** (if on Windows) with Docker integration enabled

---

## 📖 Step-by-Step Instructions

### Step 1: Initialize Terraform

This downloads the Docker provider plugin:

```bash
terraform init
```

**What happens:**
- Creates `.terraform/` directory
- Downloads the Docker provider
- Creates `.terraform.lock.hcl` lock file

### Step 2: Preview Changes

See what Terraform will create:

```bash
terraform plan
```

**What to expect:**
- Shows 2 resources to be added (image + container)
- Displays all configuration details
- No changes are made yet

### Step 3: Apply Configuration

Create the infrastructure:

```bash
terraform apply
```

**What happens:**
- Prompts for confirmation (type `yes`)
- Pulls nginx image from Docker Hub
- Creates and starts the container
- Displays output values

### Step 4: Verify Deployment

Check the running container:

```bash
docker ps
```

Access the web server:
```bash
curl http://localhost:8080
```

Or open `http://localhost:8080` in your browser - you should see the nginx welcome page!

### Step 5: Inspect State

View Terraform's state:

```bash
terraform show
```

This shows all managed resources and their current attributes.

### Step 6: Destroy Infrastructure

Clean up when done:

```bash
terraform destroy
```

**What happens:**
- Prompts for confirmation (type `yes`)
- Stops and removes the container
- Removes the image (because `keep_locally = false`)

---

## 🔍 Understanding the Code

### Terraform Block
```hcl
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}
```
- Declares which providers this configuration needs
- Pins the Docker provider to version 3.x

### Provider Block
```hcl
provider "docker" {
  host = "unix:///var/run/docker.sock"
}
```
- Configures how Terraform connects to Docker
- Uses the Unix socket (standard for Linux/WSL)

### Resource Blocks
```hcl
resource "docker_image" "nginx" {
  name = "nginx:latest"
  keep_locally = false
}
```
- `docker_image` = resource type
- `nginx` = local name for this resource
- Pulls the nginx:latest image

```hcl
resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "terraform-nginx"
  
  ports {
    internal = 80
    external = 8080
  }
}
```
- Creates a container from the image
- References the image using `docker_image.nginx.image_id`
- Maps internal port 80 to external port 8080

---

## 🧪 Experiments to Try

Once the basic project works, try these variations:

1. **Change the Port Mapping**
   - Modify `external = 8080` to `external = 9090`
   - Run `terraform apply` again
   - See how Terraform handles the change

2. **Add Environment Variables**
   ```hcl
   env = [
     "NGINX_HOST=localhost",
     "NGINX_PORT=80"
   ]
   ```

3. **Run Multiple Containers**
   - Duplicate the container resource with a different name
   - Change the external port for the second container

4. **Try a Different Image**
   - Replace nginx with `httpd:latest` (Apache)
   - See how Terraform manages the change

---

## 🐛 Common Issues & Solutions

### Issue: "Cannot connect to the Docker daemon"
**Solution:** Ensure Docker Desktop is running, or start Docker service:
```bash
sudo service docker start
```

### Issue: "Port 8080 is already in use"
**Solution:** Change the external port in main.tf or stop the conflicting service:
```bash
sudo lsof -i :8080
```

### Issue: "Error acquiring the state lock"
**Solution:** Previous operation didn't complete. Force unlock:
```bash
terraform force-unlock <LOCK_ID>
```

---

## 📚 Key Concepts Learned

After completing this project, you should understand:

✅ **Terraform Configuration Language (HCL)** - Basic syntax and structure  
✅ **Provider Management** - How Terraform connects to external services  
✅ **Resource Declaration** - Defining infrastructure as code  
✅ **Resource Dependencies** - How resources reference each other  
✅ **Terraform State** - How Terraform tracks infrastructure  
✅ **Terraform Workflow** - init → plan → apply → destroy cycle  
✅ **Outputs** - Displaying useful information after deployment

---

## ➡️ Next Steps

After mastering this project:

1. **Experiment** with the variations suggested above
2. **Review** the Terraform state file to understand its structure
3. **Move to Project 2:** Deploy a web app to Minikube with Kubernetes
4. **Study:** HashiCorp Learn Terraform tutorials for deeper understanding

---

## 📝 Notes for Portfolio

When adding this to your portfolio or GitHub:
- Document what you learned in this README
- Add screenshots of the nginx welcome page
- Explain any experiments or customizations you tried
- Describe how this project relates to real-world infrastructure

---

## 🔗 Resources

- [Terraform Docker Provider Docs](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs)
- [HashiCorp Learn - Get Started with Docker](https://learn.hashicorp.com/collections/terraform/docker-get-started)
- [Terraform CLI Documentation](https://www.terraform.io/cli)

---

**Project Status:** Ready to begin  
**Estimated Time:** 30-60 minutes  
**Next Project:** Kubernetes deployment to Minikube
