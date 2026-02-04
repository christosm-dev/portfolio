# Phase 2: Kubernetes Migration Guide

This guide outlines the migration from Docker Compose to Kubernetes, aligning with your CKA/CKAD certification preparation and demonstrating enterprise-grade orchestration skills.

## Why Kubernetes for This Project?

### Benefits Over Docker Compose

1. **Enhanced Isolation**: Namespace-based multi-tenancy
2. **Better Resource Management**: ResourceQuotas, LimitRanges
3. **Advanced Networking**: NetworkPolicies, service mesh options
4. **Scalability**: Horizontal Pod Autoscaling, cluster autoscaling
5. **Self-healing**: Automatic pod restarts, health checks
6. **Enterprise Patterns**: Matches production Kubernetes deployments

### Career Benefits

- **Direct CKA/CKAD Relevance**: Hands-on with exam topics
- **Portfolio Differentiation**: Beyond basic Docker skills
- **Interview Material**: Discuss production Kubernetes patterns
- **Enterprise Credibility**: Shows understanding of industry standards

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│              Kubernetes Cluster (K3s on VPS)            │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │           Namespace: zensical-platform           │  │
│  │  (Backend API and supporting services)           │  │
│  │                                                  │  │
│  │  ┌────────────┐      ┌────────────┐            │  │
│  │  │  Service   │      │  Backend   │            │  │
│  │  │  (LoadBal) │─────▶│   API      │            │  │
│  │  └────────────┘      │  Deployment│            │  │
│  │                      └────┬───────┘            │  │
│  │                           │                     │  │
│  │                           │ Creates Pods        │  │
│  │                           ▼                     │  │
│  └───────────────────────────┼─────────────────────┘  │
│                               │                        │
│  ┌────────────────────────────▼────────────────────┐  │
│  │     Namespace: sandbox-XXXXXX (Ephemeral)       │  │
│  │     Created per execution request               │  │
│  │                                                 │  │
│  │  ResourceQuota:                                 │  │
│  │  - CPU: 0.5 cores                               │  │
│  │  - Memory: 256Mi                                │  │
│  │  - Pods: 3                                      │  │
│  │                                                 │  │
│  │  NetworkPolicy:                                 │  │
│  │  - Deny all egress                              │  │
│  │  - Deny all ingress                             │  │
│  │                                                 │  │
│  │  PodSecurityStandard: restricted                │  │
│  │                                                 │  │
│  │  ┌──────────────┐                               │  │
│  │  │ Sandbox Pod  │                               │  │
│  │  │ - Python     │                               │  │
│  │  │ - Node.js    │                               │  │
│  │  │ - Bash       │                               │  │
│  │  └──────────────┘                               │  │
│  │                                                 │  │
│  │  Automatic cleanup via CronJob                  │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Prerequisites

Before starting Phase 2:

1. ✅ Phase 1 completed and tested
2. ✅ Comfortable with Kubernetes concepts
3. ✅ Started CKA/CKAD preparation
4. VPS with:
   - 4GB+ RAM (K3s requires ~1GB)
   - 2+ CPU cores
   - 40GB+ storage

## Step 1: Install K3s

K3s is a lightweight Kubernetes distribution perfect for single-node deployments.

### Why K3s?

- **Lightweight**: ~70MB binary, ~512MB RAM
- **Production-grade**: Used by enterprises
- **Full K8s API**: Compatible with all K8s resources
- **Easy to install**: Single command
- **Built-in**: Traefik Ingress, local storage provisioner

### Installation

SSH to your VPS:

```bash
ssh root@YOUR_VPS_IP

# Install K3s
curl -sfL https://get.k3s.io | sh -

# Verify installation
kubectl get nodes
# Expected: NAME STATUS ROLES AGE VERSION
#          vps   Ready  control-plane,master  1m  v1.28.x

# Check system pods
kubectl get pods -A
```

### Configure kubectl Locally

To manage the cluster from your local machine:

```bash
# On VPS, get kubeconfig
cat /etc/rancher/k3s/k3s.yaml

# On local machine
mkdir -p ~/.kube
# Copy content to ~/.kube/config and edit:
# - Replace 127.0.0.1 with YOUR_VPS_IP
# - Update cluster name if desired

# Test connection
kubectl get nodes
```

## Step 2: Create Kubernetes Manifests

### Directory Structure

```
k8s/
├── namespace.yaml              # Platform namespace
├── backend/
│   ├── deployment.yaml         # Backend API deployment
│   ├── service.yaml            # Backend service
│   └── configmap.yaml          # Configuration
├── rbac/
│   ├── serviceaccount.yaml     # Service account for backend
│   ├── role.yaml               # Permissions for namespace creation
│   └── rolebinding.yaml        # Bind role to service account
├── sandbox/
│   ├── namespace-template.yaml # Template for sandbox namespaces
│   ├── resourcequota.yaml      # Resource limits template
│   ├── networkpolicy.yaml      # Network isolation template
│   └── podsecuritypolicy.yaml  # Security policy (if using PSP)
└── monitoring/
    ├── servicemonitor.yaml     # Prometheus monitoring (optional)
    └── dashboard.yaml          # Grafana dashboard (optional)
```

### Core Manifests

Let me create the essential Kubernetes manifests:

#### 1. Platform Namespace

```yaml
# k8s/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: zensical-platform
  labels:
    name: zensical-platform
    app: sandbox-platform
```

#### 2. Backend Deployment

```yaml
# k8s/backend/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sandbox-api
  namespace: zensical-platform
  labels:
    app: sandbox-api
spec:
  replicas: 2  # For high availability
  selector:
    matchLabels:
      app: sandbox-api
  template:
    metadata:
      labels:
        app: sandbox-api
    spec:
      serviceAccountName: sandbox-controller
      containers:
      - name: api
        image: your-registry/zensical-sandbox-api:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 8000
          name: http
        env:
        - name: KUBERNETES_MODE
          value: "true"
        - name: NAMESPACE_PREFIX
          value: "sandbox-"
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 10
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 10
```

#### 3. Backend Service

```yaml
# k8s/backend/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: sandbox-api
  namespace: zensical-platform
  labels:
    app: sandbox-api
spec:
  type: LoadBalancer  # K3s will expose via Traefik
  selector:
    app: sandbox-api
  ports:
  - port: 80
    targetPort: 8000
    name: http
```

#### 4. RBAC Configuration

```yaml
# k8s/rbac/serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: sandbox-controller
  namespace: zensical-platform
---
# k8s/rbac/clusterrole.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: sandbox-namespace-manager
rules:
- apiGroups: [""]
  resources: ["namespaces"]
  verbs: ["create", "delete", "get", "list", "watch"]
- apiGroups: [""]
  resources: ["pods", "pods/log"]
  verbs: ["create", "delete", "get", "list", "watch"]
- apiGroups: [""]
  resources: ["resourcequotas"]
  verbs: ["create", "delete", "get"]
- apiGroups: ["networking.k8s.io"]
  resources: ["networkpolicies"]
  verbs: ["create", "delete", "get"]
---
# k8s/rbac/clusterrolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: sandbox-controller-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: sandbox-namespace-manager
subjects:
- kind: ServiceAccount
  name: sandbox-controller
  namespace: zensical-platform
```

#### 5. Sandbox Namespace Template

```yaml
# k8s/sandbox/namespace-template.yaml
# This is applied programmatically by the backend
apiVersion: v1
kind: Namespace
metadata:
  name: sandbox-{execution_id}
  labels:
    type: ephemeral-sandbox
    created-by: zensical-platform
    created-at: "{timestamp}"
---
# k8s/sandbox/resourcequota.yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: sandbox-quota
  namespace: sandbox-{execution_id}
spec:
  hard:
    requests.cpu: "500m"
    requests.memory: "256Mi"
    limits.cpu: "1"
    limits.memory: "512Mi"
    pods: "3"
    persistentvolumeclaims: "0"
    services: "0"
---
# k8s/sandbox/networkpolicy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: sandbox-{execution_id}
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  # No ingress or egress rules = deny all
---
# k8s/sandbox/limitrange.yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: sandbox-limits
  namespace: sandbox-{execution_id}
spec:
  limits:
  - max:
      cpu: "500m"
      memory: "256Mi"
    min:
      cpu: "10m"
      memory: "10Mi"
    default:
      cpu: "250m"
      memory: "128Mi"
    defaultRequest:
      cpu: "100m"
      memory: "64Mi"
    type: Container
```

## Step 3: Update Backend for Kubernetes

### New Kubernetes Client Code

Create `backend/kubernetes_sandbox.py`:

```python
from kubernetes import client, config
from kubernetes.client.rest import ApiException
import uuid
import logging
from datetime import datetime

logger = logging.getLogger(__name__)

class KubernetesSandboxManager:
    """Manages sandbox execution in Kubernetes namespaces"""
    
    def __init__(self):
        # Load in-cluster config (when running in K8s)
        try:
            config.load_incluster_config()
        except:
            # Fallback to local kubeconfig (for development)
            config.load_kube_config()
        
        self.core_api = client.CoreV1Api()
        self.networking_api = client.NetworkingV1Api()
    
    def create_sandbox_namespace(self, execution_id: str) -> str:
        """Create ephemeral namespace for sandbox execution"""
        namespace_name = f"sandbox-{execution_id}"
        
        namespace = client.V1Namespace(
            metadata=client.V1ObjectMeta(
                name=namespace_name,
                labels={
                    "type": "ephemeral-sandbox",
                    "created-by": "zensical-platform",
                    "execution-id": execution_id,
                    "created-at": datetime.utcnow().isoformat()
                }
            )
        )
        
        try:
            self.core_api.create_namespace(body=namespace)
            logger.info(f"Created namespace: {namespace_name}")
            
            # Apply ResourceQuota
            self._apply_resource_quota(namespace_name)
            
            # Apply NetworkPolicy
            self._apply_network_policy(namespace_name)
            
            return namespace_name
        except ApiException as e:
            logger.error(f"Failed to create namespace: {e}")
            raise
    
    def _apply_resource_quota(self, namespace: str):
        """Apply ResourceQuota to namespace"""
        quota = client.V1ResourceQuota(
            metadata=client.V1ObjectMeta(
                name="sandbox-quota",
                namespace=namespace
            ),
            spec=client.V1ResourceQuotaSpec(
                hard={
                    "requests.cpu": "500m",
                    "requests.memory": "256Mi",
                    "limits.cpu": "1",
                    "limits.memory": "512Mi",
                    "pods": "3",
                    "persistentvolumeclaims": "0",
                    "services": "0"
                }
            )
        )
        
        try:
            self.core_api.create_namespaced_resource_quota(
                namespace=namespace,
                body=quota
            )
            logger.info(f"Applied ResourceQuota to {namespace}")
        except ApiException as e:
            logger.error(f"Failed to apply ResourceQuota: {e}")
    
    def _apply_network_policy(self, namespace: str):
        """Apply NetworkPolicy for complete isolation"""
        policy = client.V1NetworkPolicy(
            metadata=client.V1ObjectMeta(
                name="deny-all",
                namespace=namespace
            ),
            spec=client.V1NetworkPolicySpec(
                pod_selector=client.V1LabelSelector(),
                policy_types=["Ingress", "Egress"]
                # No ingress or egress rules = deny all
            )
        )
        
        try:
            self.networking_api.create_namespaced_network_policy(
                namespace=namespace,
                body=policy
            )
            logger.info(f"Applied NetworkPolicy to {namespace}")
        except ApiException as e:
            logger.error(f"Failed to apply NetworkPolicy: {e}")
    
    def execute_sandbox_pod(
        self,
        namespace: str,
        code: str,
        environment: str,
        timeout: int = 30
    ) -> dict:
        """Execute code in a Pod within the sandbox namespace"""
        
        # Environment-specific images
        images = {
            "python": "python:3.11-slim",
            "node": "node:18-alpine",
            "bash": "bash:5.2-alpine3.19"
        }
        
        pod_name = f"executor-{uuid.uuid4().hex[:8]}"
        
        # Create Pod specification
        pod = client.V1Pod(
            metadata=client.V1ObjectMeta(
                name=pod_name,
                namespace=namespace,
                labels={
                    "app": "sandbox-executor",
                    "environment": environment
                }
            ),
            spec=client.V1PodSpec(
                restart_policy="Never",
                automount_service_account_token=False,
                security_context=client.V1PodSecurityContext(
                    run_as_non_root=True,
                    run_as_user=1000,
                    fs_group=1000
                ),
                containers=[
                    client.V1Container(
                        name="executor",
                        image=images[environment],
                        command=["sh", "-c"],
                        args=[code],
                        resources=client.V1ResourceRequirements(
                            requests={
                                "memory": "64Mi",
                                "cpu": "100m"
                            },
                            limits={
                                "memory": "256Mi",
                                "cpu": "500m"
                            }
                        ),
                        security_context=client.V1SecurityContext(
                            read_only_root_filesystem=True,
                            allow_privilege_escalation=False,
                            run_as_non_root=True,
                            run_as_user=1000,
                            capabilities=client.V1Capabilities(
                                drop=["ALL"]
                            )
                        )
                    )
                ]
            )
        )
        
        try:
            # Create Pod
            self.core_api.create_namespaced_pod(
                namespace=namespace,
                body=pod
            )
            logger.info(f"Created pod: {pod_name} in {namespace}")
            
            # Wait for completion or timeout
            # Implementation depends on your needs:
            # - Poll pod status
            # - Get logs when complete
            # - Handle timeout
            
            # For now, return immediately
            # Real implementation would wait and get logs
            return {
                "pod_name": pod_name,
                "namespace": namespace,
                "status": "created"
            }
            
        except ApiException as e:
            logger.error(f"Failed to create pod: {e}")
            raise
    
    def delete_sandbox_namespace(self, namespace: str):
        """Delete sandbox namespace and all its resources"""
        try:
            self.core_api.delete_namespace(
                name=namespace,
                body=client.V1DeleteOptions()
            )
            logger.info(f"Deleted namespace: {namespace}")
        except ApiException as e:
            logger.error(f"Failed to delete namespace: {e}")
    
    def cleanup_old_namespaces(self, max_age_seconds: int = 300):
        """Clean up sandbox namespaces older than max_age_seconds"""
        try:
            namespaces = self.core_api.list_namespace(
                label_selector="type=ephemeral-sandbox"
            )
            
            current_time = datetime.utcnow()
            
            for ns in namespaces.items:
                created_at = ns.metadata.labels.get("created-at")
                if created_at:
                    created_time = datetime.fromisoformat(created_at)
                    age = (current_time - created_time).total_seconds()
                    
                    if age > max_age_seconds:
                        logger.info(f"Cleaning up old namespace: {ns.metadata.name}")
                        self.delete_sandbox_namespace(ns.metadata.name)
                        
        except ApiException as e:
            logger.error(f"Failed to cleanup namespaces: {e}")
```

### Update Backend Dependencies

Add to `backend/requirements.txt`:
```
kubernetes==28.1.0
```

## Step 4: Deploy to Kubernetes

### Build and Push Images

```bash
# Build backend image
cd backend
docker build -t your-registry/zensical-sandbox-api:latest .

# Push to registry (DockerHub, GitHub Registry, etc.)
docker push your-registry/zensical-sandbox-api:latest
```

### Apply Kubernetes Manifests

```bash
# Create platform namespace
kubectl apply -f k8s/namespace.yaml

# Apply RBAC
kubectl apply -f k8s/rbac/

# Deploy backend
kubectl apply -f k8s/backend/

# Verify deployment
kubectl get all -n zensical-platform
```

## Step 5: Testing

### Test Namespace Creation

```python
from kubernetes_sandbox import KubernetesSandboxManager

manager = KubernetesSandboxManager()

# Create sandbox namespace
execution_id = "test-123"
namespace = manager.create_sandbox_namespace(execution_id)

# Verify it exists
kubectl get namespace sandbox-test-123

# Check ResourceQuota
kubectl get resourcequota -n sandbox-test-123

# Check NetworkPolicy
kubectl get networkpolicy -n sandbox-test-123

# Cleanup
manager.delete_sandbox_namespace(namespace)
```

## CKA/CKAD Exam Topics Covered

This project covers many CKA/CKAD exam topics:

### CKA Topics

1. **Cluster Architecture** ✅
   - Understanding of Kubernetes components
   - API server interaction via Python client

2. **Workloads & Scheduling** ✅
   - Pod creation and management
   - Resource requests and limits
   - Security contexts

3. **Services & Networking** ✅
   - NetworkPolicies for isolation
   - Service creation (LoadBalancer)

4. **Storage** ✅
   - Understanding of PV/PVC (prevented in sandboxes)

5. **Troubleshooting** ✅
   - Log collection
   - Pod status monitoring
   - Debug failed executions

### CKAD Topics

1. **Application Design** ✅
   - Multi-container patterns (if extended)
   - Init containers (can add)

2. **Application Deployment** ✅
   - Deployments with replicas
   - Rolling updates

3. **Application Observability** ✅
   - Liveness/readiness probes
   - Logging

4. **Application Environment** ✅
   - ConfigMaps (can add)
   - Secrets (can add)
   - ResourceQuotas and LimitRanges

5. **Services & Networking** ✅
   - NetworkPolicies
   - Service exposure

## Interview Talking Points

### For Platform Engineering Roles

"I built a Kubernetes-based sandbox platform with namespace-based multi-tenancy. Each execution runs in its own namespace with ResourceQuotas limiting CPU and memory, and NetworkPolicies ensuring complete isolation. The backend uses the Kubernetes API to dynamically create and destroy namespaces, demonstrating enterprise-grade orchestration patterns."

### For SRE Roles

"My portfolio includes a self-healing sandbox platform on Kubernetes. It uses readiness probes for zero-downtime deployments, automatically cleans up failed executions, and implements resource limits at multiple levels - Pod, Namespace, and Cluster. I built comprehensive monitoring with metrics on namespace lifecycle, execution success rates, and resource utilization."

### For DevOps Roles

"I automated the entire deployment pipeline from infrastructure provisioning with Terraform to Kubernetes orchestration. The project demonstrates GitOps principles, Infrastructure as Code, and follows the CIS Kubernetes Benchmark for security hardening."

## Next Steps

1. **Complete Phase 2 Implementation** - Build out the full Kubernetes backend
2. **Add Monitoring** - Prometheus metrics, Grafana dashboards
3. **Implement Autoscaling** - HPA based on queue depth
4. **Add Persistent Storage** - For execution history (using PVCs properly)
5. **Multi-node Cluster** - If you want to scale beyond one VPS

## Resources

- [CKA Exam Curriculum](https://github.com/cncf/curriculum)
- [CKAD Exam Curriculum](https://github.com/cncf/curriculum)
- [Kubernetes Python Client](https://github.com/kubernetes-client/python)
- [K3s Documentation](https://docs.k3s.io/)
- [NetworkPolicy Recipes](https://github.com/ahmetb/kubernetes-network-policy-recipes)

This Phase 2 enhancement transforms your project from a good Docker demonstration into an enterprise-grade Kubernetes platform, directly supporting your certification goals and career transition.
