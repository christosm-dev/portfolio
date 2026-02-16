# =============================================================================
# Zensical Sandbox Platform - Variable Definitions
# =============================================================================

variable "cf_dns_api_token" {
  description = "Cloudflare API token for DNS challenge (Let's Encrypt)"
  type        = string
  sensitive   = true
}

variable "traefik_basic_auth" {
  description = "htpasswd hash for Traefik dashboard basic auth"
  type        = string
  sensitive   = true
}

variable "domain" {
  description = "Base domain for service routing"
  type        = string
  default     = "christosm.dev"
}

variable "traefik_image_tag" {
  description = "Traefik Docker image tag"
  type        = string
  default     = "latest"
}

variable "log_level" {
  description = "Log level for services"
  type        = string
  default     = "INFO"

  validation {
    condition     = contains(["DEBUG", "INFO", "WARN", "ERROR"], var.log_level)
    error_message = "log_level must be one of: DEBUG, INFO, WARN, ERROR."
  }
}

variable "api_memory_limit" {
  description = "Memory limit for the sandbox API container (in MB)"
  type        = number
  default     = 1024
}

variable "api_cpu_shares" {
  description = "CPU shares for the sandbox API container"
  type        = number
  default     = 2048
}

# =============================================================================
# Monitoring Stack - Image Tags
# =============================================================================

variable "prometheus_image_tag" {
  description = "Prometheus Docker image tag"
  type        = string
  default     = "v2.50.0"
}

variable "loki_image_tag" {
  description = "Loki Docker image tag"
  type        = string
  default     = "3.4.2"
}

variable "promtail_image_tag" {
  description = "Promtail Docker image tag"
  type        = string
  default     = "3.4.2"
}

variable "grafana_image_tag" {
  description = "Grafana Docker image tag"
  type        = string
  default     = "10.3.0"
}

variable "portainer_image_tag" {
  description = "Portainer CE Docker image tag"
  type        = string
  default     = "2.11.1"
}

# =============================================================================
# Monitoring Stack - Credentials
# =============================================================================

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
  default     = "admin"
}
