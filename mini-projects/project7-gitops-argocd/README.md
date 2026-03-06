# Project 7: GitOps with ArgoCD

> Pull-based GitOps: ArgoCD syncs the cluster from Git with self-healing, automated image tag updates, and zero manual kubectl commands. **[View source on GitHub](https://github.com/christosm-dev/portfolio/tree/main/mini-projects/project7-gitops-argocd)**

## Project Overview

This project implements GitOps using ArgoCD — a pull-based continuous delivery tool that runs inside the Kubernetes cluster and continuously reconciles cluster state with a Git repository. Rather than a CI pipeline pushing changes into the cluster (Project 5's approach), ArgoCD watches Git and pulls changes into the cluster automatically.

The project deploys the flask-tasks app (Project 5) using the Helm chart from Project 6, with ArgoCD managing the full lifecycle for two environments: dev (manual sync) and prod (automated sync with self-healing).

```
Developer pushes code
        |
        | git push → main
        v
+-----------------------------------------------+
|  GitHub Actions: project5-ci-cd.yml           |
|  test → build → push image to GHCR            |
|  flask-tasks:sha-abc1234                       |
+-----------------------------------------------+
        |
        | workflow_run: completed (success)
        v
+-----------------------------------------------+
|  GitHub Actions: project7-image-updater.yml   |
|  Updates flask-tasks-prod.yaml image.tag      |
|  git commit + git push → main                 |
+-----------------------------------------------+
        |
        | Git state changed (ArgoCD polls every 3 min)
        v
+-----------------------------------------------+
|  ArgoCD Controller (inside Minikube)          |
|  Detects changed Application manifest         |
|  Renders Project 6 Helm chart                 |
|  Applies updated Deployment to cluster        |
|  selfHeal: reverts any manual kubectl edits   |
+-----------------------------------------------+
        |
        +--> flask-tasks-dev  (namespace: flask-tasks-dev)
        |    Manual sync, 1 replica, DEBUG logging
        |
        +--> flask-tasks-prod (namespace: flask-tasks-prod)
             Auto-sync, 3 replicas, HPA, pinned image tag
```

## Push-based vs Pull-based CD

| | Project 5 (push-based) | Project 7 (pull-based / GitOps) |
|-|------------------------|----------------------------------|
| Who initiates the deploy? | CI pipeline pushes to cluster | ArgoCD inside cluster pulls from Git |
| Cluster credentials location | Stored in GitHub Actions secrets | Never leave the cluster |
| Source of truth | CI script logic | Git repository |
| Self-healing | No — manual change persists | Yes — ArgoCD reverts drift |
| Audit trail | CI run logs | Git commit history |
| Deploy when CI is down | No | Yes — ArgoCD keeps reconciling |

## Technology Stack

| Technology | Role |
|------------|------|
| ArgoCD | GitOps controller — watches Git, syncs cluster |
| Kubernetes (Minikube) | Target cluster |
| Helm (via ArgoCD) | Chart rendering — consumes Project 6's chart |
| GitHub Actions | Image tag writeback — completes the automated loop |
| Git | Single source of truth for all desired cluster state |

## Key Features

- Two `Application` CRDs: dev with manual sync, prod with `automated` sync and `selfHeal: true`
- ArgoCD renders the Project 6 Helm chart directly — no duplicate manifests
- Inline `helm.values` in each Application keeps this project self-contained (no files modified in Projects 5 or 6)
- `project7-image-updater.yml` workflow closes the GitOps loop: triggered by Project 5's pipeline completion, updates the prod image tag, commits back to Git
- `sed` anchor comment ensures only the managed tag line is patched — safe and idempotent
- `prune: true` removes orphaned resources when they are deleted from Git
- Self-healing demo: any `kubectl` edit to the prod namespace is reverted within ArgoCD's sync cycle

## Codebase Overview

```
project7-gitops-argocd/
├── argocd/
│   └── apps/
│       ├── flask-tasks-dev.yaml   # Application CRD: dev, manual sync, 1 replica
│       └── flask-tasks-prod.yaml  # Application CRD: prod, auto-sync, HPA, managed image tag
└── README.md                      # This file

# Workflow at portfolio root (no Project 5/6 files are modified):
.github/workflows/
└── project7-image-updater.yml     # Triggered on Project 5 completion; patches image tag and pushes
```

## Quick Start

### 1. Prerequisites

```bash
minikube status   # must be Running
helm version      # must be v3.x
```

### 2. Install ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for all pods to be ready
kubectl wait --for=condition=available deployment --all -n argocd --timeout=120s
```

### 3. Access the ArgoCD UI

```bash
# Port-forward the ArgoCD API server
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Retrieve the initial admin password
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath="{.data.password}" | base64 -d && echo
```

Open `https://localhost:8080` — username `admin`, password from the command above.

### 4. Install the ArgoCD CLI (optional but recommended)

```bash
# Linux
curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x argocd && sudo mv argocd /usr/local/bin/

argocd login localhost:8080 --insecure --username admin
```

### 5. Apply the Application manifests

```bash
kubectl apply -f argocd/apps/flask-tasks-dev.yaml
kubectl apply -f argocd/apps/flask-tasks-prod.yaml
```

Both Applications will appear in the ArgoCD UI immediately. Prod will begin syncing automatically; dev waits for a manual trigger.

### 6. Sync the dev Application manually

```bash
# Via CLI
argocd app sync flask-tasks-dev

# Or via the UI: click the app → Sync → Synchronize
```

### 7. Verify deployments

```bash
# Check ArgoCD sync status
argocd app list
argocd app get flask-tasks-prod

# Check pods in each namespace
kubectl get pods -n flask-tasks-dev
kubectl get pods -n flask-tasks-prod

# Access the dev API
minikube service flask-tasks-dev -n flask-tasks-dev --url
```

## Demonstrating Self-Healing

```bash
# Manually scale the prod deployment down to 1 replica
kubectl scale deployment flask-tasks-prod -n flask-tasks-prod --replicas=1

# Watch ArgoCD revert it back to 3 within the sync cycle
kubectl get pods -n flask-tasks-prod -w

# ArgoCD detects drift and re-applies the desired state from Git
argocd app get flask-tasks-prod   # status will briefly show OutOfSync then Synced
```

## The Automated GitOps Loop

Once both projects are set up, the full loop is automatic:

1. Push any code change to `main`
2. Project 5's pipeline runs: test → build → push `flask-tasks:sha-<commit>` to GHCR
3. On success, `project7-image-updater.yml` triggers automatically via `workflow_run`
4. The updater patches `flask-tasks-prod.yaml` with the new tag and pushes to `main`
5. ArgoCD detects the manifest change within its poll interval (default 3 minutes)
6. ArgoCD renders the Helm chart with the new tag and rolls out the updated Deployment
7. No manual `kubectl` or `helm upgrade` commands required

## Useful ArgoCD CLI Commands

```bash
# List all applications and their sync status
argocd app list

# Get detailed status and health of an application
argocd app get flask-tasks-prod

# Manually trigger a sync
argocd app sync flask-tasks-dev

# View sync history
argocd app history flask-tasks-prod

# Roll back to a previous sync revision
argocd app rollback flask-tasks-prod <revision-number>

# Delete an application (leaves cluster resources in place by default)
argocd app delete flask-tasks-dev
```

## Future Work

- [ ] Configure an ArgoCD webhook on the portfolio GitHub repo to eliminate the 3-minute poll delay
- [ ] Add an App of Apps pattern — a root Application that manages both flask-tasks Applications
- [ ] Use ArgoCD Image Updater as an alternative to the image-updater workflow
- [ ] Add ArgoCD notifications (Slack or email) on sync failure
- [ ] Restrict ArgoCD project permissions using AppProject to limit which repos and namespaces each app can target

## Resources

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [ArgoCD Application CRD Reference](https://argo-cd.readthedocs.io/en/stable/operator-manual/application.yaml)
- [GitOps Principles (OpenGitOps)](https://opengitops.dev/)
- [CKAD Exam Curriculum](https://github.com/cncf/curriculum)
