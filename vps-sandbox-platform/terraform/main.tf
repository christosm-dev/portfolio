# Zensical Sandbox Platform - Terraform Configuration
# 
# This Terraform configuration provisions and configures a VPS for running
# the sandbox platform. It demonstrates Infrastructure as Code practices
# and can be adapted for various cloud providers.

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    # For Contabo VPS, we'll use null_provider with remote-exec
    # In production, you might use Contabo's API or other cloud providers
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

# Variables for configuration
variable "vps_host" {
  description = "VPS hostname or IP address"
  type        = string
}

variable "vps_user" {
  description = "SSH user for VPS access"
  type        = string
  default     = "root"
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key for VPS access"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "domain_name" {
  description = "Domain name for the sandbox platform (optional)"
  type        = string
  default     = ""
}

variable "enable_ssl" {
  description = "Enable SSL/TLS with Let's Encrypt"
  type        = bool
  default     = false
}

variable "admin_email" {
  description = "Admin email for SSL certificate notifications"
  type        = string
  default     = ""
}

# Local variables
locals {
  project_name = "zensical-sandbox"
  
  # Files to copy to VPS
  backend_files = [
    "../backend/main.py",
    "../backend/requirements.txt",
    "../backend/Dockerfile"
  ]
  
  compose_files = [
    "../docker-compose.yml"
  ]
}

# SSH connection configuration
locals {
  ssh_connection = {
    type        = "ssh"
    user        = var.vps_user
    host        = var.vps_host
    private_key = file(var.ssh_private_key_path)
  }
}

# Install Docker and dependencies
resource "null_resource" "install_dependencies" {
  connection {
    type        = local.ssh_connection.type
    user        = local.ssh_connection.user
    host        = local.ssh_connection.host
    private_key = local.ssh_connection.private_key
  }

  provisioner "remote-exec" {
    inline = [
      "# Update system packages",
      "apt-get update",
      "apt-get upgrade -y",
      
      "# Install Docker",
      "apt-get install -y apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -",
      "add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "apt-get update",
      "apt-get install -y docker-ce docker-ce-cli containerd.io",
      
      "# Install Docker Compose",
      "curl -L \"https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
      "chmod +x /usr/local/bin/docker-compose",
      
      "# Start Docker service",
      "systemctl start docker",
      "systemctl enable docker",
      
      "# Create project directory",
      "mkdir -p /opt/${local.project_name}",
      "mkdir -p /opt/${local.project_name}/backend",
      "mkdir -p /opt/${local.project_name}/logs",
      
      "# Install additional tools",
      "apt-get install -y ufw fail2ban",
      
      "echo 'Dependencies installed successfully'"
    ]
  }
}

# Configure firewall
resource "null_resource" "configure_firewall" {
  depends_on = [null_resource.install_dependencies]
  
  connection {
    type        = local.ssh_connection.type
    user        = local.ssh_connection.user
    host        = local.ssh_connection.host
    private_key = local.ssh_connection.private_key
  }

  provisioner "remote-exec" {
    inline = [
      "# Configure UFW firewall",
      "ufw --force reset",
      "ufw default deny incoming",
      "ufw default allow outgoing",
      "ufw allow ssh",
      "ufw allow 80/tcp",
      "ufw allow 443/tcp",
      "ufw allow 8000/tcp",  # API port (remove in production, use nginx instead)
      "ufw --force enable",
      
      "echo 'Firewall configured successfully'"
    ]
  }
}

# Copy application files
resource "null_resource" "copy_files" {
  depends_on = [null_resource.install_dependencies]
  
  connection {
    type        = local.ssh_connection.type
    user        = local.ssh_connection.user
    host        = local.ssh_connection.host
    private_key = local.ssh_connection.private_key
  }

  # Copy backend files
  provisioner "file" {
    source      = "../backend/"
    destination = "/opt/${local.project_name}/backend"
  }

  # Copy docker-compose
  provisioner "file" {
    source      = "../docker-compose.yml"
    destination = "/opt/${local.project_name}/docker-compose.yml"
  }
}

# Pull Docker images
resource "null_resource" "pull_images" {
  depends_on = [null_resource.copy_files]
  
  connection {
    type        = local.ssh_connection.type
    user        = local.ssh_connection.user
    host        = local.ssh_connection.host
    private_key = local.ssh_connection.private_key
  }

  provisioner "remote-exec" {
    inline = [
      "cd /opt/${local.project_name}",
      
      "# Pull base images for sandbox environments",
      "docker pull python:3.11-slim",
      "docker pull node:18-alpine",
      "docker pull bash:5.2-alpine3.19",
      
      "echo 'Docker images pulled successfully'"
    ]
  }
}

# Deploy application
resource "null_resource" "deploy_application" {
  depends_on = [
    null_resource.copy_files,
    null_resource.pull_images,
    null_resource.configure_firewall
  ]
  
  connection {
    type        = local.ssh_connection.type
    user        = local.ssh_connection.user
    host        = local.ssh_connection.host
    private_key = local.ssh_connection.private_key
  }

  provisioner "remote-exec" {
    inline = [
      "cd /opt/${local.project_name}",
      
      "# Stop existing containers",
      "docker-compose down || true",
      
      "# Build and start services",
      "docker-compose build",
      "docker-compose up -d",
      
      "# Wait for services to be healthy",
      "sleep 10",
      
      "# Check status",
      "docker-compose ps",
      
      "echo 'Application deployed successfully'"
    ]
  }
}

# Configure systemd service for auto-restart
resource "null_resource" "configure_systemd" {
  depends_on = [null_resource.deploy_application]
  
  connection {
    type        = local.ssh_connection.type
    user        = local.ssh_connection.user
    host        = local.ssh_connection.host
    private_key = local.ssh_connection.private_key
  }

  provisioner "remote-exec" {
    inline = [
      "cat > /etc/systemd/system/${local.project_name}.service <<EOF",
      "[Unit]",
      "Description=Zensical Sandbox Platform",
      "Requires=docker.service",
      "After=docker.service",
      "",
      "[Service]",
      "Type=oneshot",
      "RemainAfterExit=yes",
      "WorkingDirectory=/opt/${local.project_name}",
      "ExecStart=/usr/local/bin/docker-compose up -d",
      "ExecStop=/usr/local/bin/docker-compose down",
      "TimeoutStartSec=0",
      "",
      "[Install]",
      "WantedBy=multi-user.target",
      "EOF",
      
      "systemctl daemon-reload",
      "systemctl enable ${local.project_name}.service",
      
      "echo 'Systemd service configured successfully'"
    ]
  }
}

# Outputs
output "vps_ip" {
  description = "VPS IP address"
  value       = var.vps_host
}

output "api_url" {
  description = "API endpoint URL"
  value       = "http://${var.vps_host}:8000"
}

output "health_check_url" {
  description = "Health check endpoint"
  value       = "http://${var.vps_host}:8000/health"
}

output "deployment_status" {
  description = "Deployment completion status"
  value       = "Deployment completed. Check API health at http://${var.vps_host}:8000/health"
}

output "next_steps" {
  description = "Next steps for configuration"
  value = <<-EOT
    Next steps:
    1. Test the API: curl http://${var.vps_host}:8000/health
    2. Review logs: ssh ${var.vps_user}@${var.vps_host} "cd /opt/${local.project_name} && docker-compose logs"
    3. Configure your frontend to use: http://${var.vps_host}:8000
    4. Set up NGINX reverse proxy for production (SSL/TLS)
    5. Configure domain DNS if using custom domain
  EOT
}
