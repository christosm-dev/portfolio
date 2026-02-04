"""
VPS Sandbox Platform - Container Diagram

This diagram breaks down the VPS Sandbox Platform into its major
containers (applications, services, data stores).

Level: C4 Level 2 - Container
Audience: Technical staff (developers, DevOps engineers, architects)
"""

# TODO: Define the container architecture for the VPS Sandbox Platform
#
# Questions to answer:
# - What are the major runtime components?
# - How do they communicate?
# - What protocols/technologies are used?
# - What are the data flows?
#
# Containers to consider:
#
# Phase 1 (Docker-based):
# - FastAPI Backend Application (Python)
# - PostgreSQL Database
# - Redis Cache
# - NGINX Reverse Proxy
# - Prometheus (Monitoring)
# - Grafana (Visualization)
#
# Phase 2 (Kubernetes):
# - Same containers deployed as pods
# - Ingress Controller
# - Service Mesh (optional)
#
# Example structure (adapt based on chosen DSL):
#
# from c4_literate import Container, Database, Relationship
#
# # Web/API Layer
# nginx = Container(
#     name="NGINX Reverse Proxy",
#     technology="NGINX",
#     description="SSL termination, load balancing, rate limiting"
# )
#
# backend_api = Container(
#     name="Backend API",
#     technology="FastAPI, Python 3.11",
#     description="Provides REST API for container management"
# )
#
# # Data Layer
# postgres = Database(
#     name="PostgreSQL Database",
#     technology="PostgreSQL 15",
#     description="Stores application data and configuration"
# )
#
# redis = Database(
#     name="Redis Cache",
#     technology="Redis 7",
#     description="Caches API responses and session data"
# )
#
# # Monitoring Layer
# prometheus = Container(
#     name="Prometheus",
#     technology="Prometheus",
#     description="Collects metrics from all containers"
# )
#
# grafana = Container(
#     name="Grafana",
#     technology="Grafana",
#     description="Visualizes metrics and logs"
# )
#
# # Relationships
# nginx.uses(backend_api, "Forwards requests", "HTTPS/REST")
# backend_api.uses(postgres, "Reads/writes data", "PostgreSQL protocol")
# backend_api.uses(redis, "Caches data", "Redis protocol")
# prometheus.uses(backend_api, "Scrapes metrics", "HTTP/Prometheus")
# prometheus.uses(postgres, "Scrapes metrics", "PostgreSQL Exporter")
# grafana.uses(prometheus, "Queries metrics", "PromQL")
