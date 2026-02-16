# Zensical Sandbox Platform - Terraform Configuration
#
# Manages Docker resources natively via the Terraform Docker provider.
# Scope: Traefik reverse proxy, Sandbox API, and monitoring stack
# (Prometheus, Loki, Promtail, Grafana, Portainer).

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# =============================================================================
# Network
# =============================================================================

resource "docker_network" "sandbox_network" {
  name   = "sandbox-network"
  driver = "bridge"

  ipam_config {
    subnet = "172.20.0.0/16"
  }

  lifecycle {
    ignore_changes = [ipam_config]
  }
}

# =============================================================================
# Volumes
# =============================================================================

resource "docker_volume" "letsencrypt_data" {
  name = "letsencrypt-data"
}

resource "docker_volume" "prometheus_data" {
  name = "prometheus-data"
}

resource "docker_volume" "loki_data" {
  name = "loki-data"
}

resource "docker_volume" "grafana_data" {
  name = "grafana-data"
}

resource "docker_volume" "portainer_data" {
  name = "portainer-data"
}

# =============================================================================
# Traefik - Reverse Proxy & Load Balancer
# =============================================================================

resource "docker_image" "traefik" {
  name = "traefik:${var.traefik_image_tag}"
}

resource "docker_container" "traefik" {
  name  = "traefik"
  image = docker_image.traefik.image_id

  restart = "unless-stopped"

  # Ports
  ports {
    internal = 80
    external = 80
  }

  ports {
    internal = 443
    external = 443
  }

  # Command
  command = [
    # API and Dashboard
    "--api.dashboard=true",
    # Docker provider
    "--providers.docker=true",
    "--providers.docker.exposedbydefault=false",
    "--providers.docker.network=sandbox-network",
    # Entrypoints
    "--entrypoints.web.address=:80",
    "--entrypoints.websecure.address=:443",
    # HTTP to HTTPS redirect
    "--entrypoints.web.http.redirections.entrypoint.to=websecure",
    "--entrypoints.web.http.redirections.entrypoint.scheme=https",
    # Let's Encrypt with Cloudflare DNS Challenge
    "--certificatesresolvers.letsencrypt.acme.email=laptop-yodel-chilli@duck.com",
    "--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json",
    "--certificatesresolvers.letsencrypt.acme.dnschallenge=true",
    "--certificatesresolvers.letsencrypt.acme.dnschallenge.provider=cloudflare",
    "--certificatesresolvers.letsencrypt.acme.dnschallenge.resolvers=1.1.1.1:53,8.8.8.8:53",
    # Logging
    "--log.level=${var.log_level}",
    "--accesslog=true",
    # Metrics for Prometheus
    "--metrics.prometheus=true",
    "--metrics.prometheus.buckets=0.1,0.3,1.2,5.0",
  ]

  # Environment
  env = [
    "DOCKER_API_VERSION=1.45",
    "CF_DNS_API_TOKEN=${var.cf_dns_api_token}",
  ]

  # Volumes
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only      = true
  }

  volumes {
    volume_name    = docker_volume.letsencrypt_data.name
    container_path = "/letsencrypt"
  }

  # Network
  networks_advanced {
    name = docker_network.sandbox_network.name
  }

  # Labels - Traefik self-routing
  labels {
    label = "traefik.enable"
    value = "true"
  }

  # Basic Auth middleware
  labels {
    label = "traefik.http.middlewares.admin-auth.basicauth.users"
    value = var.traefik_basic_auth
  }

  # Dashboard router
  labels {
    label = "traefik.http.routers.traefik.rule"
    value = "Host(`traefik.${var.domain}`)"
  }

  labels {
    label = "traefik.http.routers.traefik.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.traefik.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.routers.traefik.service"
    value = "api@internal"
  }

  labels {
    label = "traefik.http.routers.traefik.middlewares"
    value = "admin-auth"
  }

  # Security
  security_opts = ["no-new-privileges:true"]
}

# =============================================================================
# Sandbox API
# =============================================================================

resource "docker_image" "sandbox_api" {
  name = "sandbox-api:latest"

  build {
    context    = "${path.module}/../backend"
    dockerfile = "Dockerfile"
  }

  triggers = {
    dockerfile   = filemd5("${path.module}/../backend/Dockerfile")
    main_py      = filemd5("${path.module}/../backend/main.py")
    requirements = filemd5("${path.module}/../backend/requirements.txt")
  }
}

resource "docker_container" "sandbox_api" {
  name  = "sandbox-api"
  image = docker_image.sandbox_api.image_id

  restart = "unless-stopped"

  # Environment
  env = [
    "PYTHONUNBUFFERED=1",
    "LOG_LEVEL=${var.log_level}",
  ]

  # Volumes - Docker socket for spawning sandbox containers
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }

  volumes {
    host_path      = abspath("${path.module}/../logs")
    container_path = "/app/logs"
  }

  # Network
  networks_advanced {
    name = docker_network.sandbox_network.name
  }

  # Labels - Traefik routing
  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.sandbox-api.rule"
    value = "Host(`api.${var.domain}`)"
  }

  labels {
    label = "traefik.http.routers.sandbox-api.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.sandbox-api.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.services.sandbox-api.loadbalancer.server.port"
    value = "8000"
  }

  # Resource limits
  memory     = var.api_memory_limit
  cpu_shares = var.api_cpu_shares

  # Security
  security_opts = ["no-new-privileges:true"]

  depends_on = [docker_container.traefik]
}

# =============================================================================
# Prometheus - Metrics Collection
# =============================================================================

resource "docker_image" "prometheus" {
  name = "prom/prometheus:${var.prometheus_image_tag}"
}

resource "docker_container" "prometheus" {
  name  = "prometheus"
  image = docker_image.prometheus.image_id

  restart = "unless-stopped"

  # Command
  command = [
    "--config.file=/etc/prometheus/prometheus.yml",
    "--storage.tsdb.path=/prometheus",
    "--storage.tsdb.retention.time=15d",
    "--web.enable-lifecycle",
  ]

  # Volumes
  volumes {
    host_path      = abspath("${path.module}/../monitoring/prometheus/prometheus.yml")
    container_path = "/etc/prometheus/prometheus.yml"
    read_only      = true
  }

  volumes {
    host_path      = abspath("${path.module}/../monitoring/prometheus/alerts")
    container_path = "/etc/prometheus/alerts"
    read_only      = true
  }

  volumes {
    volume_name    = docker_volume.prometheus_data.name
    container_path = "/prometheus"
  }

  # Network
  networks_advanced {
    name = docker_network.sandbox_network.name
  }

  # Labels - Traefik routing
  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.prometheus.rule"
    value = "Host(`prometheus.${var.domain}`)"
  }

  labels {
    label = "traefik.http.routers.prometheus.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.prometheus.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.routers.prometheus.middlewares"
    value = "admin-auth@docker"
  }

  labels {
    label = "traefik.http.services.prometheus.loadbalancer.server.port"
    value = "9090"
  }

  # Resource limits
  memory      = 512
  cpu_shares  = 1024

  # Security
  security_opts = ["no-new-privileges:true"]

  depends_on = [docker_container.traefik]
}

# =============================================================================
# Loki - Log Aggregation
# =============================================================================

resource "docker_image" "loki" {
  name = "grafana/loki:${var.loki_image_tag}"
}

resource "docker_container" "loki" {
  name  = "loki"
  image = docker_image.loki.image_id

  restart = "unless-stopped"

  # Command
  command = [
    "-config.file=/etc/loki/loki-config.yml",
  ]

  # Volumes
  volumes {
    host_path      = abspath("${path.module}/../monitoring/loki/loki-config.yml")
    container_path = "/etc/loki/loki-config.yml"
    read_only      = true
  }

  volumes {
    volume_name    = docker_volume.loki_data.name
    container_path = "/loki"
  }

  # Network
  networks_advanced {
    name = docker_network.sandbox_network.name
  }

  # Resource limits
  memory      = 512
  cpu_shares  = 1024

  # Security
  security_opts = ["no-new-privileges:true"]
}

# =============================================================================
# Promtail - Log Collection Agent
# =============================================================================

resource "docker_image" "promtail" {
  name = "grafana/promtail:${var.promtail_image_tag}"
}

resource "docker_container" "promtail" {
  name  = "promtail"
  image = docker_image.promtail.image_id

  restart = "unless-stopped"

  # Command
  command = [
    "-config.file=/etc/promtail/promtail-config.yml",
  ]

  # Volumes
  volumes {
    host_path      = abspath("${path.module}/../monitoring/promtail/promtail-config.yml")
    container_path = "/etc/promtail/promtail-config.yml"
    read_only      = true
  }

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only      = true
  }

  volumes {
    host_path      = "/var/log/syslog"
    container_path = "/var/log/host/syslog"
    read_only      = true
  }

  volumes {
    host_path      = "/var/log/auth.log"
    container_path = "/var/log/host/auth.log"
    read_only      = true
  }

  # Network
  networks_advanced {
    name = docker_network.sandbox_network.name
  }

  # Resource limits
  memory      = 256
  cpu_shares  = 512

  # Security
  security_opts = ["no-new-privileges:true"]

  depends_on = [docker_container.loki]
}

# =============================================================================
# Grafana - Metrics & Log Visualization
# =============================================================================

resource "docker_image" "grafana" {
  name = "grafana/grafana:${var.grafana_image_tag}"
}

resource "docker_container" "grafana" {
  name  = "grafana"
  image = docker_image.grafana.image_id

  restart = "unless-stopped"

  # Environment
  env = [
    "GF_SECURITY_ADMIN_USER=admin",
    "GF_SECURITY_ADMIN_PASSWORD=${var.grafana_admin_password}",
    "GF_USERS_ALLOW_SIGN_UP=false",
    "GF_SERVER_ROOT_URL=https://grafana.${var.domain}",
    "GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-piechart-panel",
  ]

  # Volumes
  volumes {
    volume_name    = docker_volume.grafana_data.name
    container_path = "/var/lib/grafana"
  }

  volumes {
    host_path      = abspath("${path.module}/../monitoring/grafana/provisioning")
    container_path = "/etc/grafana/provisioning"
    read_only      = true
  }

  volumes {
    host_path      = abspath("${path.module}/../monitoring/grafana/dashboards")
    container_path = "/var/lib/grafana/dashboards"
    read_only      = true
  }

  # Network
  networks_advanced {
    name = docker_network.sandbox_network.name
  }

  # Labels - Traefik routing (no auth middleware - Grafana has its own)
  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.grafana.rule"
    value = "Host(`grafana.${var.domain}`)"
  }

  labels {
    label = "traefik.http.routers.grafana.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.grafana.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.services.grafana.loadbalancer.server.port"
    value = "3000"
  }

  # Resource limits
  memory      = 512
  cpu_shares  = 1024

  # Security
  security_opts = ["no-new-privileges:true"]

  depends_on = [docker_container.traefik]
}

# =============================================================================
# Portainer - Container Management UI
# =============================================================================

resource "docker_image" "portainer" {
  name = "portainer/portainer-ce:${var.portainer_image_tag}"
}

resource "docker_container" "portainer" {
  name  = "portainer"
  image = docker_image.portainer.image_id

  restart = "unless-stopped"

  # Command
  command = ["-H", "unix:///var/run/docker.sock"]

  # Volumes
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only      = true
  }

  volumes {
    volume_name    = docker_volume.portainer_data.name
    container_path = "/data"
  }

  # Network
  networks_advanced {
    name = docker_network.sandbox_network.name
  }

  # Labels - Traefik routing (no auth middleware - Portainer has its own)
  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.portainer.rule"
    value = "Host(`portainer.${var.domain}`)"
  }

  labels {
    label = "traefik.http.routers.portainer.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.portainer.tls.certresolver"
    value = "letsencrypt"
  }

  labels {
    label = "traefik.http.services.portainer.loadbalancer.server.port"
    value = "9000"
  }

  # Security
  security_opts = ["no-new-privileges:true"]

  depends_on = [docker_container.traefik]
}
