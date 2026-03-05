# Project 5: GitHub Actions - CI/CD Pipeline for a Containerised Application

> Automate test, build, and deploy stages for a Flask application with a three-job GitHub Actions pipeline. **[View source on GitHub](https://github.com/christosm-dev/portfolio/tree/main/mini-projects/project5-cicd-github-actions)**

## Project Overview

This project demonstrates CI/CD fundamentals by building a GitHub Actions pipeline that runs automatically on every push to `main`. A Flask task-tracker API with ten unit tests provides real work for the pipeline to do: the `test` job runs pytest and flake8, the `build` job produces a Docker image pushed to GitHub Container Registry (GHCR) with both a SHA tag and `:latest`, and the `deploy` job spins up a Minikube cluster inside the runner, applies the Kubernetes manifests, waits for a healthy rollout, then runs a port-forward smoke test. Path filters ensure the pipeline only triggers when project files change, not on every portfolio commit.

```
  git push to main
        │
        ▼
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Actions Runner                     │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  test job                                           │   │
│  │  pytest (10 tests) · flake8 lint                   │   │
│  └──────────────────────┬──────────────────────────────┘   │
│                         │ ✓ passes                          │
│                         ▼                                   │
│  ┌──────────────────┐       ┌──────────────────────────┐   │
│  │  build job       │──────►│  GHCR                    │   │
│  │                  │ push  │  flask-tasks:sha-abc1234  │   │
│  └──────────────────┘       │  flask-tasks:latest      │   │
│         │                   └──────────────────────────┘   │
│         │ ✓ image pushed                                    │
│         ▼                                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  deploy job                                         │   │
│  │  Minikube (in runner) ← kubectl apply               │   │
│  │  rollout status ✓  smoke test ✓                     │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## Technology Stack

| Technology | Role |
|------------|------|
| GitHub Actions | CI/CD orchestration and runner environment |
| Python 3.11 / Flask | Task-tracker API with ten pytest unit tests |
| Docker | Container image build and packaging |
| GHCR | GitHub Container Registry — image storage, tied to the repo |
| Kubernetes (Minikube) | Cluster spun up inside the CI runner for deploy validation |
| flake8 | Python linter enforcing code style in the test job |
| YAML | Workflow and Kubernetes manifest definition |

## Key Features

- Three-job pipeline with explicit dependency chain: `test` → `build` → `deploy`
- Path-based trigger filters — pipeline runs only when project files change
- GHCR image push with dual tagging: immutable `sha-<short>` and mutable `:latest`
- `GITHUB_TOKEN` used for GHCR authentication — no external secrets required
- Minikube spun up inside GitHub Actions runner using `medyagh/setup-minikube`
- Image built directly into Minikube's Docker daemon, avoiding registry pull in CI
- Rolling update strategy with `maxUnavailable: 0` for zero-downtime deploys
- Readiness and liveness probes on `/health` gate rollout completion
- Smoke test via `kubectl port-forward` validates the live deployment end-to-end
- `build` and `deploy` jobs skipped on pull requests — only `test` runs

## Codebase Overview

```
project5-cicd-github-actions/
├── app/
│   ├── app.py            # Flask task-tracker: CRUD endpoints + /health
│   ├── test_app.py       # 10 pytest tests covering all routes and error cases
│   ├── requirements.txt  # Runtime dependency: flask==3.0.3
│   └── Dockerfile        # Python 3.11-slim image
├── k8s/
│   ├── deployment.yaml   # 2-replica Deployment with probes and resource limits
│   └── service.yaml      # NodePort Service: port 80 → 5000, nodePort 30090
└── README.md

# Workflow lives at the portfolio root:
.github/workflows/
└── project5-ci-cd.yml    # Three-job pipeline with path filters
```

## Future Work

- [ ] Add a test coverage report published as a workflow artefact
- [ ] Push image to GHCR and configure an imagePullSecret for cluster auth
- [ ] Add a staging environment gate with manual approval before production deploy
- [ ] Implement semantic versioning with tags triggering release builds
- [ ] Cache pip and Docker layer builds between runs to reduce pipeline duration
- [ ] Add a security scan step (Trivy or Grype) between build and deploy jobs

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [docker/metadata-action](https://github.com/docker/metadata-action)
- [docker/build-push-action](https://github.com/docker/build-push-action)
- [medyagh/setup-minikube](https://github.com/medyagh/setup-minikube)
- [GitHub Container Registry Docs](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
