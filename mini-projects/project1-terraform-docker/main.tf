# Project 1: Terraform + Docker - Provision nginx Container
# This is a beginner-level project to learn Terraform basics

# Terraform configuration block - specifies required providers
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# Provider configuration - connects Terraform to Docker
provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Resource: Docker Image
# This tells Terraform to pull the nginx image from Docker Hub
resource "docker_image" "nginx" {
  name         = var.image_name
  keep_locally = var.keep_image_locally
}

# Resource: Docker Container
# This creates and runs a container from the nginx image
resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = var.container_name

  ports {
    internal = var.internal_port
    external = var.external_port
  }
}
