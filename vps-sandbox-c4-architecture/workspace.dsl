workspace "VPS Sandbox Platform" "C4 architecture for the VPS Sandbox Platform - a production-grade container platform demonstrating DevOps/SRE skills" {

    model {
        # People
        devopsEngineer = person "DevOps Engineer" "Deploys and manages containerized applications on the platform"
        developer = person "Developer" "Executes code in sandboxed containers via the API"
        interviewer = person "Technical Interviewer" "Reviews portfolio, architecture decisions, and monitoring dashboards"

        # External Systems
        github = softwareSystem "GitHub" "Version control and CI/CD triggers" "External"
        dockerHub = softwareSystem "Docker Hub" "Container image registry" "External"
        letsEncrypt = softwareSystem "Let's Encrypt" "SSL/TLS certificate provider (ACME)" "External"
        cloudflare = softwareSystem "Cloudflare" "DNS management and CDN proxy for *.christosm.dev" "External"

        # VPS Sandbox Platform (Main System)
        vpsPlatform = softwareSystem "VPS Sandbox Platform" "Production-grade container platform demonstrating DevOps skills and best practices" {

            # Reverse Proxy / Edge
            traefik = container "Traefik" "Reverse proxy with automatic service discovery, SSL termination, and rate limiting" "Traefik v3" "WebServer"

            # Application Layer
            backendApi = container "Sandbox API" "REST API for sandboxed code execution and container management" "FastAPI, Python 3.11" "Application" {
                # API Layer
                executionRoutes = component "Execution Routes" "Handles code execution requests (/execute endpoint)" "FastAPI Router"
                healthRoutes = component "Health Check Routes" "Provides health and readiness endpoints (/health, /ready)" "FastAPI Router"
                metricsEndpoint = component "Metrics Endpoint" "Exposes Prometheus metrics at /metrics" "Prometheus Client"

                # Service Layer
                sandboxManager = component "Sandbox Manager" "Orchestrates ephemeral container lifecycle: create, execute, destroy" "Python Service"
                securityManager = component "Security Manager" "Enforces resource limits, network isolation, and capability restrictions" "Python Service"

                # Infrastructure Layer
                dockerClient = component "Docker Client" "Wraps Docker Engine API for container operations" "Docker SDK for Python"
            }

            # Monitoring Stack
            prometheus = container "Prometheus" "Collects and stores time-series metrics from all services" "Prometheus v2.50" "Monitoring"
            grafana = container "Grafana" "Unified dashboards for metrics and log visualisation" "Grafana 10.3" "Monitoring"
            loki = container "Loki" "Log aggregation engine with label-based indexing" "Grafana Loki 3.4" "Monitoring"
            promtail = container "Promtail" "Log collection agent for Docker containers and host logs" "Grafana Promtail 3.4" "Monitoring"

            # Container Management
            portainer = container "Portainer" "Web-based Docker management UI for container and image operations" "Portainer CE 2.11" "Management"
        }

        # Relationships - People to System
        devopsEngineer -> vpsPlatform "Deploys applications, manages infrastructure via"
        developer -> vpsPlatform "Executes code in sandbox containers via"
        interviewer -> vpsPlatform "Reviews architecture and monitoring dashboards of"

        # Relationships - System to External
        vpsPlatform -> github "Pulls code and configuration from"
        vpsPlatform -> dockerHub "Pulls container images from"
        vpsPlatform -> letsEncrypt "Obtains SSL/TLS certificates from"
        vpsPlatform -> cloudflare "Routes traffic through"

        # Relationships - People to Containers
        devopsEngineer -> traefik "Manages platform via" "HTTPS"
        developer -> traefik "Submits code for execution via" "HTTPS"
        interviewer -> grafana "Views metrics and logs via" "HTTPS"
        interviewer -> traefik "Browses API documentation via" "HTTPS"

        # Relationships - Edge Layer
        traefik -> backendApi "Forwards API requests to" "HTTP (api.christosm.dev)"
        traefik -> grafana "Forwards dashboard requests to" "HTTP (grafana.christosm.dev)"
        traefik -> prometheus "Forwards metrics UI requests to" "HTTP (prometheus.christosm.dev)"
        traefik -> portainer "Forwards management requests to" "HTTP (portainer.christosm.dev)"
        traefik -> letsEncrypt "Requests certificates via" "ACME / Cloudflare DNS challenge"
        traefik -> cloudflare "Validates domain ownership via" "DNS-01 challenge"

        # Relationships - Monitoring
        prometheus -> backendApi "Scrapes metrics from" "HTTP /metrics"
        prometheus -> traefik "Scrapes metrics from" "HTTP :8080/metrics"
        prometheus -> loki "Scrapes metrics from" "HTTP :3100/metrics"
        grafana -> prometheus "Queries metrics from" "PromQL"
        grafana -> loki "Queries logs from" "LogQL"
        promtail -> loki "Pushes log streams to" "HTTP /loki/api/v1/push"

        # Relationships - Component Level (within Sandbox API)
        executionRoutes -> sandboxManager "Delegates execution to"
        executionRoutes -> securityManager "Validates request limits via"
        healthRoutes -> dockerClient "Checks Docker connectivity via"
        sandboxManager -> securityManager "Applies security constraints via"
        sandboxManager -> dockerClient "Creates and manages ephemeral containers via"
        metricsEndpoint -> prometheus "Exposes metrics to" "HTTP"

        # Deployment - Phase 1: Docker (Current)
        live = deploymentEnvironment "Live" {
            deploymentNode "Contabo VPS" "Ubuntu 22.04 LTS, 8GB RAM, 4 vCPU" "Physical Server" {
                deploymentNode "Docker Engine" "Container runtime with bridge networking" "Docker 29.x" {
                    containerInstance traefik
                    containerInstance backendApi
                    containerInstance prometheus
                    containerInstance grafana
                    containerInstance loki
                    containerInstance promtail
                    containerInstance portainer
                }
            }
        }

        # Deployment - Phase 2: Kubernetes (Planned)
        kubernetes = deploymentEnvironment "Kubernetes" {
            deploymentNode "Kubernetes Cluster" "K3s or managed Kubernetes" "Kubernetes" {
                deploymentNode "Platform Namespace" "vps-platform-prod" "Namespace" {
                    deploymentNode "Backend Deployment" "3 replicas for high availability" "Deployment" {
                        containerInstance backendApi
                    }
                }
                deploymentNode "Ingress Namespace" "vps-platform-ingress" "Namespace" {
                    deploymentNode "Traefik Ingress Controller" "TLS termination and routing" "IngressRoute" {
                        containerInstance traefik
                    }
                }
                deploymentNode "Monitoring Namespace" "vps-platform-monitoring" "Namespace" {
                    deploymentNode "Prometheus Stack" "Metrics collection and alerting" "Deployment" {
                        containerInstance prometheus
                    }
                    deploymentNode "Grafana Stack" "Dashboards and visualisation" "Deployment" {
                        containerInstance grafana
                    }
                    deploymentNode "Loki Stack" "Log aggregation" "StatefulSet" {
                        containerInstance loki
                    }
                    deploymentNode "Promtail DaemonSet" "Node-level log collection" "DaemonSet" {
                        containerInstance promtail
                    }
                }
                deploymentNode "Management Namespace" "vps-platform-mgmt" "Namespace" {
                    deploymentNode "Portainer Deployment" "Cluster management UI" "Deployment" {
                        containerInstance portainer
                    }
                }
            }
        }
    }

    views {
        # System Context View
        systemContext vpsPlatform "SystemContext" {
            include *
            autoLayout
            description "System Context diagram for the VPS Sandbox Platform showing users and external systems"
        }

        # Container View
        container vpsPlatform "Containers" {
            include *
            autoLayout
            description "Container diagram showing the runtime services of the VPS Sandbox Platform"
        }

        # Component View (Sandbox API)
        component backendApi "Components" {
            include *
            autoLayout
            description "Component diagram showing the internal structure of the Sandbox API"
        }

        # Deployment View - Phase 1 (Docker)
        deployment vpsPlatform "Live" "DockerDeployment" {
            include *
            autoLayout
            description "Current deployment: Docker containers on Contabo VPS with Traefik edge routing"
        }

        # Deployment View - Phase 2 (Kubernetes)
        deployment vpsPlatform "Kubernetes" "KubernetesDeployment" {
            include *
            autoLayout
            description "Planned: Kubernetes-based deployment with namespaces, DaemonSets, and high availability"
        }

        styles {
            element "Person" {
                shape person
                background #08427b
                color #ffffff
            }
            element "External" {
                background #999999
                color #ffffff
            }
            element "WebServer" {
                shape WebBrowser
                background #2ecc71
                color #ffffff
            }
            element "Application" {
                background #3498db
                color #ffffff
            }
            element "Database" {
                shape Cylinder
                background #e74c3c
                color #ffffff
            }
            element "Monitoring" {
                background #f39c12
                color #ffffff
            }
            element "Management" {
                background #9b59b6
                color #ffffff
            }
        }

        theme default
    }

    configuration {
        scope softwaresystem
    }
}
