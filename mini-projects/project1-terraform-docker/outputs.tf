# Outputs - Display useful information after deployment

output "container_id" {
  description = "ID of the Docker container"
  value       = docker_container.nginx.id
}

output "container_name" {
  description = "Name of the Docker container"
  value       = docker_container.nginx.name
}

output "image_id" {
  description = "ID of the Docker image"
  value       = docker_image.nginx.id
}

output "access_url" {
  description = "URL to access the nginx web server"
  value       = "http://localhost:${var.external_port}"
}
