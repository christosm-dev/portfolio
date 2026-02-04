workspace "VPS Sandbox Platform" "C4 architecture for the VPS Sandbox Platform - a production-grade container platform demonstrating DevOps/SRE skills" {

    model {
        # People
        devopsEngineer = person "DevOps Engineer" "Deploys and manages containerized applications on the platform"
        developer = person "Developer" "Develops and tests applications in the sandbox environment"
        interviewer = person "Technical Interviewer" "Reviews portfolio and architecture decisions"

        # External Systems
        github = softwareSystem "GitHub" "Version control and CI/CD triggers" "External"
        dockerHub = softwareSystem "Docker Hub" "Container image registry" "External"
        letsEncrypt = softwareSystem "Let's Encrypt" "SSL/TLS certificate provider" "External"

        # VPS Sandbox Platform (Main System)
        vpsPlatform = softwareSystem "VPS Sandbox Platform" "Production-grade container platform demonstrating DevOps skills and best practices" {

            # Web Layer
            nginx = container "NGINX Reverse Proxy" "Handles SSL termination, load balancing, and rate limiting" "NGINX" "WebServer"

            # Application Layer
            backendApi = container "Backend API" "Provides REST API for container management and monitoring" "FastAPI, Python 3.11" "Application" {
                # API Layer Components
                containerRoutes = component "Container Management Routes" "Handles HTTP requests for container operations" "FastAPI Router"
                authRoutes = component "Authentication Routes" "Handles user authentication and token validation" "FastAPI Router"
                healthRoutes = component "Health Check Routes" "Provides health and readiness endpoints" "FastAPI Router"

                # Service Layer Components
                containerService = component "Container Service" "Business logic for container lifecycle management" "Python Service"
                resourceMonitor = component "Resource Monitor" "Monitors container resource usage (CPU, memory, disk)" "Python Service"
                securityService = component "Security Service" "Handles authentication, authorization, and audit logging" "Python Service"

                # Data Access Layer Components
                containerRepo = component "Container Repository" "Data access for container information" "SQLAlchemy"
                userRepo = component "User Repository" "Data access for user information" "SQLAlchemy"

                # Infrastructure Components
                dockerClient = component "Docker Client Wrapper" "Wraps Docker API calls for container operations" "Docker SDK for Python"
                cacheClient = component "Cache Client" "Handles caching operations" "Redis Client"
                metricsCollector = component "Metrics Collector" "Exposes metrics for Prometheus" "Prometheus Client"
            }

            # Data Layer
            postgres = container "PostgreSQL Database" "Stores application data, user information, and configuration" "PostgreSQL 15" "Database"
            redis = container "Redis Cache" "Caches API responses and session data" "Redis 7" "Database"

            # Monitoring Layer
            prometheus = container "Prometheus" "Collects and stores metrics from all containers" "Prometheus" "Monitoring"
            grafana = container "Grafana" "Visualizes metrics and provides monitoring dashboards" "Grafana" "Monitoring"
        }

        # Relationships - People to Systems
        devopsEngineer -> vpsPlatform "Deploys applications, manages infrastructure via"
        developer -> vpsPlatform "Tests applications in production-like environment using"
        interviewer -> vpsPlatform "Reviews architecture and implementation of"

        # Relationships - System to External Systems
        vpsPlatform -> github "Pulls code and configuration from"
        vpsPlatform -> dockerHub "Pulls container images from"
        vpsPlatform -> letsEncrypt "Obtains SSL/TLS certificates from"

        # Relationships - People to Containers (for detailed views)
        devopsEngineer -> nginx "Accesses via" "HTTPS"
        developer -> nginx "Accesses via" "HTTPS"
        interviewer -> grafana "Views metrics and dashboards via" "HTTPS"

        # Relationships - Container Level
        nginx -> backendApi "Forwards requests to" "HTTPS/REST"
        backendApi -> postgres "Reads from and writes to" "PostgreSQL Protocol"
        backendApi -> redis "Caches data in" "Redis Protocol"

        prometheus -> backendApi "Scrapes metrics from" "HTTP/Prometheus"
        prometheus -> postgres "Scrapes metrics from" "PostgreSQL Exporter"
        prometheus -> redis "Scrapes metrics from" "Redis Exporter"
        prometheus -> nginx "Scrapes metrics from" "NGINX Exporter"

        grafana -> prometheus "Queries metrics from" "PromQL"

        # Relationships - Component Level (within Backend API)
        # API Layer to Service Layer
        containerRoutes -> containerService "Calls"
        containerRoutes -> securityService "Validates permissions via"
        authRoutes -> securityService "Authenticates users via"
        healthRoutes -> resourceMonitor "Checks system health via"

        # Service Layer to Data Access Layer
        containerService -> containerRepo "Reads/writes container data via"
        containerService -> dockerClient "Manages Docker containers via"
        containerService -> cacheClient "Caches container states via"
        securityService -> userRepo "Reads user credentials via"
        resourceMonitor -> dockerClient "Monitors container resources via"

        # Data Access Layer to Databases
        containerRepo -> postgres "Queries" "SQL"
        userRepo -> postgres "Queries" "SQL"
        cacheClient -> redis "Reads/writes" "Redis Protocol"

        # Infrastructure Components
        metricsCollector -> prometheus "Exposes metrics to" "HTTP"

        # Deployment Environments

        # Phase 1: Docker-based deployment
        live = deploymentEnvironment "Live" {
            deploymentNode "Contabo VPS" "Ubuntu 22.04 LTS, 8GB RAM, 4 vCPU" "Physical Server" {
                deploymentNode "Docker Engine" "Container runtime" "Docker 24.x" {
                    containerInstance nginx
                    containerInstance backendApi
                    containerInstance postgres
                    containerInstance redis
                    containerInstance prometheus
                    containerInstance grafana
                }
            }
        }

        # Phase 2: Kubernetes-based deployment
        kubernetes = deploymentEnvironment "Kubernetes" {
            deploymentNode "Kubernetes Cluster" "K3s or managed Kubernetes" "Kubernetes" {
                deploymentNode "Backend Namespace" "vps-platform-prod" "Namespace" {
                    deploymentNode "Backend Deployment" "3 replicas for high availability" "Deployment" {
                        containerInstance backendApi
                    }
                    deploymentNode "PostgreSQL StatefulSet" "Persistent storage with volume claims" "StatefulSet" {
                        containerInstance postgres
                    }
                    deploymentNode "Redis Deployment" "2 replicas for caching" "Deployment" {
                        containerInstance redis
                    }
                }
                deploymentNode "Ingress Namespace" "vps-platform-ingress" "Namespace" {
                    deploymentNode "NGINX Ingress Controller" "Load balancer and routing" "Ingress" {
                        containerInstance nginx
                    }
                }
                deploymentNode "Monitoring Namespace" "vps-platform-monitoring" "Namespace" {
                    deploymentNode "Prometheus Deployment" "Metrics collection" "Deployment" {
                        containerInstance prometheus
                    }
                    deploymentNode "Grafana Deployment" "Visualization dashboards" "Deployment" {
                        containerInstance grafana
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
            description "Container diagram showing the major runtime components of the VPS Sandbox Platform"
        }

        # Component View (Backend API)
        component backendApi "Components" {
            include *
            autoLayout
            description "Component diagram showing the internal structure of the Backend API"
        }

        # Dynamic View - Container Deployment
        dynamic vpsPlatform "ContainerDeployment" "Container deployment flow" {
            devopsEngineer -> nginx "1. HTTPS request to deploy container"
            nginx -> backendApi "2. Forward request"
            backendApi -> redis "3. Check cache"
            backendApi -> postgres "4. Validate user and permissions"
            backendApi -> postgres "5. Store container metadata"
            backendApi -> nginx "6. Return success response"
            nginx -> devopsEngineer "7. Display deployment status"
            autoLayout
        }

        # Dynamic View - Resource Monitoring
        dynamic vpsPlatform "ResourceMonitoring" "Resource monitoring flow" {
            prometheus -> backendApi "1. Scrape metrics"
            backendApi -> prometheus "2. Expose container metrics"
            grafana -> prometheus "3. Query metrics"
            prometheus -> grafana "4. Return time-series data"
            interviewer -> grafana "5. View dashboard"
            autoLayout
        }

        # Deployment View - Phase 1 (Docker)
        deployment vpsPlatform "Live" "DockerDeployment" {
            include *
            autoLayout
            description "Phase 1: Docker-based deployment on Contabo VPS"
        }

        # Deployment View - Phase 2 (Kubernetes)
        deployment vpsPlatform "Kubernetes" "KubernetesDeployment" {
            include *
            autoLayout
            description "Phase 2: Kubernetes-based deployment with namespaces and high availability"
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
        }

        theme default
    }

    configuration {
        scope softwaresystem
    }
}
