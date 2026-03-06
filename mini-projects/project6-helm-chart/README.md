# Project 6: Helm Chart Packaging

> Package the Flask task-tracker API as a reusable Helm chart with environment-specific values overrides, conditional HPA, and full lifecycle management. **[View source on GitHub](https://github.com/christosm-dev/portfolio/tree/main/mini-projects/project6-helm-chart)**

## Project Overview

This project packages the Flask task-tracker API (from Project 5) as a Helm chart — the standard way to distribute and manage Kubernetes applications. Rather than applying raw YAML manifests with `kubectl apply`, Helm adds versioning, templating, environment-specific configuration, and lifecycle commands (`install`, `upgrade`, `rollback`) on top of a Kubernetes cluster.

The chart demonstrates the full Helm workflow: linting, dry-run template rendering, installation, configuration overrides per environment, rolling upgrades with pinned image tags, and rollback to a previous release.

```
Developer
    |
    | helm install/upgrade -f values-dev.yaml
    v
+---------------------------------------------------+
|  Helm (client-side templating engine)             |
|                                                   |
|  values.yaml + values-dev.yaml                    |
|       |                                           |
|       v                                           |
|  templates/ --> rendered YAML manifests           |
+---------------------------------------------------+
    |
    | kubectl apply (managed by Helm)
    v
+---------------------------------------------------+
|  Kubernetes Cluster (Minikube)                    |
|                                                   |
|  ConfigMap (APP_ENV, LOG_LEVEL, MAX_TASKS)        |
|       |  env vars                                 |
|       v                                           |
|  Deployment --> Pod  Pod  ...                     |
|                  |    |                           |
|                 /health probes                    |
|                                                   |
|  Service (NodePort :30091) <-- external traffic   |
|                                                   |
|  HPA (prod only) --> scales Deployment            |
+---------------------------------------------------+
```

## Technology Stack

| Technology | Role |
|------------|------|
| Helm 3 | Chart packaging, templating, and release management |
| Kubernetes (Minikube) | Container orchestration target |
| Go templates | Helm template language for dynamic manifest generation |
| Flask (Python 3.11) | The application being deployed (from Project 5) |
| Docker / GHCR | Container image built and published by Project 5's pipeline |

## Key Features

- Parameterised templates — all tuneable values live in `values.yaml`, nothing is hardcoded in templates
- Environment-specific overrides via `values-dev.yaml` (single replica, debug logging) and `values-prod.yaml` (three replicas, HPA, higher limits)
- `_helpers.tpl` named templates for consistent labelling and image reference across all resources
- ConfigMap injected as `envFrom` so the app reads config from environment variables without code changes
- Conditional HPA template — the resource only renders when `autoscaling.enabled: true`
- ConfigMap checksum annotation forces a rolling restart when configuration changes
- `NOTES.txt` prints access instructions and useful commands after every install or upgrade

## Codebase Overview

```
project6-helm-chart/
├── chart/
│   └── flask-tasks/
│       ├── Chart.yaml          # Chart metadata: name, version, appVersion, maintainers
│       ├── values.yaml         # Default values (production-safe baseline)
│       ├── values-dev.yaml     # Development overrides: 1 replica, DEBUG logging, Always pull
│       ├── values-prod.yaml    # Production overrides: 3 replicas, HPA enabled, pinned tag
│       └── templates/
│           ├── _helpers.tpl    # Named templates: name, fullname, labels, image reference
│           ├── configmap.yaml  # APP_ENV, LOG_LEVEL, MAX_TASKS from values.config
│           ├── deployment.yaml # Deployment with envFrom, probes, rolling update strategy
│           ├── service.yaml    # NodePort or ClusterIP depending on values.service.type
│           ├── hpa.yaml        # HorizontalPodAutoscaler — only rendered when autoscaling.enabled
│           └── NOTES.txt       # Post-install instructions printed by helm install/upgrade
└── README.md                   # This file
```

## Quick Start

### Prerequisites

```bash
# Minikube running
minikube start

# Helm 3 installed
helm version

# Build the app image into Minikube's Docker daemon (no registry pull needed)
eval $(minikube docker-env)
docker build -t ghcr.io/christosm-dev/flask-tasks:latest \
  ../project5-cicd-github-actions/app/
```

### Lint and dry-run

```bash
# Validate chart structure and template syntax
helm lint chart/flask-tasks

# Render templates locally without installing — inspect the output YAML
helm template flask-tasks chart/flask-tasks -f chart/flask-tasks/values-dev.yaml
```

### Install (development)

```bash
helm install flask-tasks chart/flask-tasks \
  -f chart/flask-tasks/values-dev.yaml

# Helm prints NOTES.txt — follow the instructions to access the API
```

### Verify the deployment

```bash
kubectl rollout status deployment/flask-tasks
kubectl get pods -l app.kubernetes.io/instance=flask-tasks

# Access via Minikube
minikube service flask-tasks --url
curl $(minikube service flask-tasks --url)/tasks
```

### Upgrade with a new image tag

```bash
helm upgrade flask-tasks chart/flask-tasks \
  -f chart/flask-tasks/values-dev.yaml \
  --set image.tag=sha-abc1234
```

### Roll back

```bash
# View release history
helm history flask-tasks

# Roll back to the previous revision
helm rollback flask-tasks

# Roll back to a specific revision
helm rollback flask-tasks 1
```

### Install (production simulation)

```bash
helm upgrade --install flask-tasks chart/flask-tasks \
  -f chart/flask-tasks/values-prod.yaml \
  --set image.tag=sha-abc1234

# Enable metrics-server for HPA to function
minikube addons enable metrics-server
kubectl get hpa flask-tasks -w
```

### Uninstall

```bash
helm uninstall flask-tasks
```

## Future Work

- [ ] Publish the chart to a Helm repository (GitHub Pages OCI or ChartMuseum)
- [ ] Add Ingress template with TLS annotation support (cert-manager)
- [ ] Add `helm test` hook with a curl-based connectivity test pod
- [ ] Parameterise the chart for multiple applications, not just flask-tasks
- [ ] Integrate chart linting and `helm template` validation into the Project 5 GitHub Actions pipeline

## Resources

- [Helm Documentation](https://helm.sh/docs/)
- [Chart Template Guide](https://helm.sh/docs/chart_template_guide/)
- [Helm Best Practices](https://helm.sh/docs/chart_best_practices/)
- [CKAD Exam Curriculum](https://github.com/cncf/curriculum)
