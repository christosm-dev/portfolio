# Project 2: Kubernetes - Deploy Python Flask App to Minikube

> Deploy a containerised Python application to a local Kubernetes cluster. **[View source on GitHub](https://github.com/christosm-dev/portfolio/tree/main/mini-projects/project2-k8s-python-app)**

## Project Overview

This project demonstrates Kubernetes fundamentals by deploying a Python Flask web application to a local Minikube cluster. The deployment runs three replicas behind a NodePort Service, with liveness and readiness probes for health checking, and resource requests/limits for capacity management. It showcases core Kubernetes concepts: Deployments, Services, rolling updates, and self-healing.

## Technology Stack

| Technology | Role |
|------------|------|
| Kubernetes (Minikube) | Container orchestration and cluster management |
| Docker | Container image build and runtime |
| Python 3.11 / Flask | Web application serving HTTP requests |
| kubectl | CLI tool for Kubernetes resource management |
| YAML | Declarative manifests for Deployments and Services |

## Key Features

- Multi-replica Deployment (3 pods) with automatic self-healing
- NodePort Service for external access with load balancing across pods
- Liveness and readiness probes for health monitoring
- Resource requests and limits (CPU and memory)
- Rolling update strategy for zero-downtime deployments
- Pod hostname display demonstrating load balancer distribution

## Codebase Overview

```
project2-k8s-python-app/
├── app.py              # Flask web server: homepage with pod hostname, /health endpoint
├── requirements.txt    # Python dependencies (Flask)
├── Dockerfile          # Container image based on Python 3.11-slim
├── k8s/
│   ├── deployment.yaml # Deployment: 3 replicas, probes, resource limits
│   └── service.yaml    # NodePort Service: port 80 → 5000, nodePort 30080
├── .gitignore
└── README.md           # This file
```

## Future Work

- [ ] Add ConfigMaps and Secrets for externalised configuration
- [ ] Implement Ingress controller for domain-based routing
- [ ] Add Horizontal Pod Autoscaler based on CPU utilisation
- [ ] Create a Helm chart to package the deployment
- [ ] Add NetworkPolicies to restrict inter-pod traffic
- [ ] Implement a CI/CD pipeline that deploys to Minikube on push

## Resources

- [Kubernetes Official Docs](https://kubernetes.io/docs/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [CKA/CKAD Exam Info](https://training.linuxfoundation.org/certification/catalog/)
