"""
VPS Sandbox Platform - System Context Diagram

This diagram shows the high-level view of the VPS Sandbox Platform
and how it interacts with users and external systems.

Level: C4 Level 1 - System Context
Audience: Everyone (technical and non-technical)
"""

# TODO: Define the system context for the VPS Sandbox Platform
#
# Questions to answer:
# - Who are the users? (DevOps engineers, developers, interviewers, etc.)
# - What external systems does it interact with? (GitHub, Docker Hub, monitoring services)
# - What are the system boundaries?
# - What are the key responsibilities of the system?
#
# Example structure (adapt based on chosen DSL):
#
# from c4_literate import Person, System, Relationship
#
# # People
# devops_engineer = Person(
#     name="DevOps Engineer",
#     description="Deploys and manages containerized applications"
# )
#
# developer = Person(
#     name="Developer",
#     description="Develops and tests applications in sandbox environment"
# )
#
# interviewer = Person(
#     name="Technical Interviewer",
#     description="Reviews portfolio and architecture decisions"
# )
#
# # Systems
# vps_platform = System(
#     name="VPS Sandbox Platform",
#     description="Production-grade container platform demonstrating DevOps skills",
#     internal=True
# )
#
# github = System(
#     name="GitHub",
#     description="Version control and CI/CD triggers",
#     internal=False
# )
#
# docker_hub = System(
#     name="Docker Hub",
#     description="Container image registry",
#     internal=False
# )
#
# monitoring = System(
#     name="External Monitoring",
#     description="Uptime and performance monitoring",
#     internal=False
# )
#
# # Relationships
# devops_engineer.uses(vps_platform, "Deploys applications, manages infrastructure")
# developer.uses(vps_platform, "Tests applications in production-like environment")
# interviewer.uses(vps_platform, "Reviews architecture and implementation")
#
# vps_platform.uses(github, "Pulls code, triggers deployments")
# vps_platform.uses(docker_hub, "Pulls container images")
# vps_platform.uses(monitoring, "Sends metrics and logs")
