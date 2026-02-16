# =============================================================================
# Zensical Sandbox Platform - Outputs
# =============================================================================

# Traefik
output "traefik_container_id" {
  description = "Traefik container ID"
  value       = docker_container.traefik.id
}

output "traefik_container_name" {
  description = "Traefik container name"
  value       = docker_container.traefik.name
}

# Sandbox API
output "sandbox_api_container_id" {
  description = "Sandbox API container ID"
  value       = docker_container.sandbox_api.id
}

output "sandbox_api_container_name" {
  description = "Sandbox API container name"
  value       = docker_container.sandbox_api.name
}

# Network
output "network_id" {
  description = "Docker network ID for the sandbox network"
  value       = docker_network.sandbox_network.id
}

# Service URLs
output "traefik_dashboard_url" {
  description = "Traefik dashboard URL"
  value       = "https://traefik.${var.domain}"
}

output "api_url" {
  description = "Sandbox API URL"
  value       = "https://api.${var.domain}"
}

output "health_check_url" {
  description = "Sandbox API health check endpoint"
  value       = "https://api.${var.domain}/health"
}

# =============================================================================
# Monitoring Stack
# =============================================================================

# Prometheus
output "prometheus_container_id" {
  description = "Prometheus container ID"
  value       = docker_container.prometheus.id
}

output "prometheus_container_name" {
  description = "Prometheus container name"
  value       = docker_container.prometheus.name
}

# Loki
output "loki_container_id" {
  description = "Loki container ID"
  value       = docker_container.loki.id
}

output "loki_container_name" {
  description = "Loki container name"
  value       = docker_container.loki.name
}

# Promtail
output "promtail_container_id" {
  description = "Promtail container ID"
  value       = docker_container.promtail.id
}

output "promtail_container_name" {
  description = "Promtail container name"
  value       = docker_container.promtail.name
}

# Grafana
output "grafana_container_id" {
  description = "Grafana container ID"
  value       = docker_container.grafana.id
}

output "grafana_container_name" {
  description = "Grafana container name"
  value       = docker_container.grafana.name
}

# Portainer
output "portainer_container_id" {
  description = "Portainer container ID"
  value       = docker_container.portainer.id
}

output "portainer_container_name" {
  description = "Portainer container name"
  value       = docker_container.portainer.name
}

# Monitoring Service URLs
output "prometheus_url" {
  description = "Prometheus URL"
  value       = "https://prometheus.${var.domain}"
}

output "grafana_url" {
  description = "Grafana URL"
  value       = "https://grafana.${var.domain}"
}

output "portainer_url" {
  description = "Portainer URL"
  value       = "https://portainer.${var.domain}"
}
