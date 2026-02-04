# Project 2: Kubernetes - Deploy Python Flask App to Minikube

**Project Series:** 2 of 7  
**Difficulty:** Beginner  
**Technologies:** Kubernetes, Docker, Minikube, Python, Flask  
**Goal:** Learn Kubernetes fundamentals by deploying a containerized Python application

---

## 📋 Project Overview

This is the second project in a series of 7 designed to build expertise in infrastructure automation tools. This project introduces **Kubernetes (k8s)**, the industry-standard container orchestration platform. You'll learn how to package a Python application, containerize it, and deploy it to a local Kubernetes cluster.

### What You'll Learn

- **Kubernetes Core Concepts:** Pods, Deployments, Services, Labels
- **kubectl CLI:** Essential commands for managing k8s resources
- **Container Orchestration:** How k8s manages multiple replicas
- **Service Discovery:** How pods communicate and are exposed
- **Health Checks:** Liveness and readiness probes
- **Resource Management:** CPU and memory limits/requests
- **YAML Manifests:** Declarative infrastructure for k8s

---

## 🎯 Certification Path Context

This project supports preparation for:
- **Certified Kubernetes Administrator (CKA)**
- **Certified Kubernetes Application Developer (CKAD)**

Skills practiced:
- Understanding Kubernetes architecture
- Working with core k8s resources
- Using kubectl to manage clusters
- Creating and managing deployments
- Configuring services and networking
- Implementing health checks

---

## 🏗️ What This Project Does

This project:
1. Creates a simple Python Flask web application
2. Containerizes it using Docker
3. Deploys it to Minikube (local k8s cluster)
4. Runs 3 replicas for high availability
5. Exposes it via a Kubernetes Service
6. Implements health checks (liveness & readiness probes)

**End Result:** A Python web app running in Kubernetes, accessible via your browser, with automatic load balancing across 3 pods.

---

## 📁 Project Structure

```
k8s-python-app/
├── app.py              # Python Flask application
├── requirements.txt    # Python dependencies
├── Dockerfile          # Container image definition
├── k8s/
│   ├── deployment.yaml # Kubernetes Deployment manifest
│   └── service.yaml    # Kubernetes Service manifest
├── .gitignore
└── README.md           # This file
```

### File Explanations

**app.py**
- Simple Flask web server on port 5000
- Shows pod hostname (to demonstrate load balancing)
- Health check endpoint at `/health`

**requirements.txt**
- Lists Python package dependencies
- Flask web framework

**Dockerfile**
- Instructions to build a Docker image
- Based on Python 3.11 slim image
- Installs dependencies and copies application code

**k8s/deployment.yaml**
- Defines how to deploy the application
- Specifies 3 replicas for high availability
- Sets resource limits and health checks

**k8s/service.yaml**
- Exposes the application to external traffic
- Uses NodePort type for local access
- Maps port 80 to container port 5000

---

## 🚀 Prerequisites

Before starting, ensure you have:

1. **Docker Desktop** (or Docker Engine)
   ```bash
   docker --version
   ```

2. **Minikube** - Local Kubernetes cluster
   ```bash
   minikube version
   ```
   
   Installation:
   ```bash
   # Linux/WSL
   curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
   sudo install minikube-linux-amd64 /usr/local/bin/minikube
   ```

3. **kubectl** - Kubernetes CLI
   ```bash
   kubectl version --client
   ```
   
   Installation:
   ```bash
   # Linux/WSL
   curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
   sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
   ```

---

## 📖 Step-by-Step Instructions

### Step 1: Start Minikube

Start your local Kubernetes cluster:

```bash
minikube start
```

**What happens:**
- Downloads Minikube ISO (first time only)
- Creates a VM or container to run k8s
- Configures kubectl to connect to the cluster
- Takes 2-5 minutes on first run

Verify it's running:
```bash
kubectl cluster-info
kubectl get nodes
```

### Step 2: Build the Docker Image in Minikube

Configure your terminal to use Minikube's Docker daemon:

```bash
eval $(minikube docker-env)
```

**Why?** This makes Docker commands build images inside Minikube, so k8s can access them without a registry.

Build the image:

```bash
docker build -t python-flask-app:latest .
```

**What happens:**
- Reads Dockerfile instructions
- Downloads Python base image
- Installs Flask dependencies
- Copies application code
- Creates image tagged `python-flask-app:latest`

Verify the image:
```bash
docker images | grep python-flask-app
```

### Step 3: Deploy to Kubernetes

Apply the Deployment manifest:

```bash
kubectl apply -f k8s/deployment.yaml
```

**What happens:**
- Creates a Deployment resource
- Spawns 3 replica pods
- Each pod runs a container from your image
- k8s automatically distributes pods across nodes

Watch the pods start:
```bash
kubectl get pods -w
```

Press `Ctrl+C` when all pods show `Running` status.

### Step 4: Expose the Application

Create the Service:

```bash
kubectl apply -f k8s/service.yaml
```

**What happens:**
- Creates a Service resource
- Routes traffic to pods with label `app: python-app`
- Exposes NodePort 30080

Get service details:
```bash
kubectl get services
```

### Step 5: Access the Application

Get the Minikube IP:

```bash
minikube ip
```

Open in your browser:
```
http://<minikube-ip>:30080
```

Or use this shortcut:
```bash
minikube service python-app-service
```

**What to observe:**
- The web page shows the pod hostname
- Refresh multiple times - hostname changes (load balancing!)
- Each refresh might hit a different pod replica

### Step 6: Explore with kubectl

#### View all resources:
```bash
kubectl get all
```

#### Describe the deployment:
```bash
kubectl describe deployment python-app
```

#### View pod logs:
```bash
# Get pod name first
kubectl get pods

# View logs
kubectl logs <pod-name>

# Follow logs in real-time
kubectl logs -f <pod-name>
```

#### Execute commands in a pod:
```bash
kubectl exec -it <pod-name> -- /bin/bash
```

#### Check pod details:
```bash
kubectl describe pod <pod-name>
```

### Step 7: Scale the Application

Scale to 5 replicas:

```bash
kubectl scale deployment python-app --replicas=5
```

Watch the new pods start:
```bash
kubectl get pods -w
```

Scale back down:
```bash
kubectl scale deployment python-app --replicas=3
```

### Step 8: Update the Application

Edit `app.py` to change the message, then rebuild and update:

```bash
# Rebuild image with new tag
docker build -t python-flask-app:v2 .

# Update deployment to use new image
kubectl set image deployment/python-app python-app=python-flask-app:v2

# Watch rolling update
kubectl rollout status deployment/python-app
```

**What happens:**
- k8s performs a rolling update
- New pods start with v2 image
- Old pods terminate gracefully
- Zero downtime!

### Step 9: Clean Up

Delete all resources:

```bash
kubectl delete -f k8s/
```

Or delete individually:
```bash
kubectl delete deployment python-app
kubectl delete service python-app-service
```

Stop Minikube (optional):
```bash
minikube stop
```

Delete Minikube cluster (optional):
```bash
minikube delete
```

---

## 🔍 Understanding Kubernetes Concepts

### What is a Pod?

A **Pod** is the smallest deployable unit in Kubernetes. It's a wrapper around one or more containers that share:
- Network namespace (same IP address)
- Storage volumes
- Lifecycle

Think of a pod as a "logical host" for your application.

**In this project:**
- Each pod runs one container (python-flask-app)
- We have 3 pods for high availability
- Each pod gets a unique hostname

### What is a Deployment?

A **Deployment** manages ReplicaSets and ensures the desired number of pods are running.

**Key features:**
- Declares desired state (3 replicas)
- Automatically replaces failed pods
- Supports rolling updates and rollbacks
- Manages pod lifecycle

**In deployment.yaml:**
```yaml
spec:
  replicas: 3  # Always maintain 3 pods
  selector:
    matchLabels:
      app: python-app  # Manage pods with this label
  template:
    # Pod template - how to create each pod
```

### What is a Service?

A **Service** provides stable networking for pods. Pods are ephemeral (come and go), but services provide consistent endpoints.

**Service Types:**
- **ClusterIP** (default) - Internal access only
- **NodePort** - Accessible on each node's IP (we use this)
- **LoadBalancer** - Cloud provider external load balancer
- **ExternalName** - DNS alias

**In service.yaml:**
```yaml
spec:
  type: NodePort
  selector:
    app: python-app  # Route to pods with this label
  ports:
  - port: 80          # Service port
    targetPort: 5000  # Container port
    nodePort: 30080   # External access port
```

### Labels and Selectors

**Labels** are key-value pairs attached to resources:
```yaml
labels:
  app: python-app
  tier: frontend
  environment: development
```

**Selectors** query resources by labels:
```yaml
selector:
  matchLabels:
    app: python-app
```

This is how Services find their Pods!

### Health Checks

**Liveness Probe** - Is the container alive?
- If fails, k8s restarts the container
- Detects deadlocks, frozen processes

**Readiness Probe** - Is the container ready for traffic?
- If fails, k8s removes pod from service endpoints
- Prevents routing traffic to starting/unhealthy pods

**In deployment.yaml:**
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 5000
  initialDelaySeconds: 10  # Wait before first check
  periodSeconds: 5         # Check every 5 seconds

readinessProbe:
  httpGet:
    path: /health
    port: 5000
  initialDelaySeconds: 5
  periodSeconds: 3
```

### Resource Management

**Requests** - Minimum resources guaranteed:
```yaml
resources:
  requests:
    memory: "64Mi"
    cpu: "100m"  # 0.1 CPU core
```

**Limits** - Maximum resources allowed:
```yaml
limits:
  memory: "128Mi"
  cpu: "200m"  # 0.2 CPU core
```

If a pod exceeds memory limit, it's killed (OOMKilled).
If it exceeds CPU limit, it's throttled.

---

## 🧪 Experiments to Try

### Experiment 1: Test High Availability

Simulate a pod failure:

```bash
# Get pods
kubectl get pods

# Delete one pod
kubectl delete pod <pod-name>

# Watch k8s automatically recreate it
kubectl get pods -w
```

The Deployment controller ensures 3 replicas always exist!

### Experiment 2: Load Balancing

```bash
# Watch the service in action
while true; do curl http://$(minikube ip):30080 | grep "Hostname"; sleep 1; done
```

You'll see requests distributed across different pods.

### Experiment 3: Rolling Update

1. Modify `app.py` (change the title or colors)
2. Build with a new tag: `docker build -t python-flask-app:v2 .`
3. Update: `kubectl set image deployment/python-app python-app=python-flask-app:v2`
4. Watch: `kubectl rollout status deployment/python-app`

No downtime during the update!

### Experiment 4: Rollback

```bash
# View rollout history
kubectl rollout history deployment/python-app

# Rollback to previous version
kubectl rollout undo deployment/python-app

# Rollback to specific revision
kubectl rollout undo deployment/python-app --to-revision=1
```

### Experiment 5: Resource Stress

Try setting very low resource limits and see what happens:

```yaml
resources:
  limits:
    memory: "32Mi"  # Very low
    cpu: "50m"
```

The pod may get OOMKilled or be slow to start.

### Experiment 6: Multiple Services

Deploy the same app with a different name and port:

```bash
# Copy and modify manifests
# Change deployment name, service name, and nodePort
kubectl apply -f k8s/deployment-v2.yaml
kubectl apply -f k8s/service-v2.yaml
```

Now you have two versions running simultaneously!

---

## 🐛 Common Issues & Solutions

### Issue: "ImagePullBackOff" or "ErrImagePull"
**Cause:** k8s can't find the Docker image  
**Solution:** 
- Ensure you ran `eval $(minikube docker-env)` before building
- Verify `imagePullPolicy: Never` in deployment.yaml
- Check image name matches: `docker images`

### Issue: Pods stuck in "Pending"
**Cause:** Insufficient cluster resources  
**Solution:**
- Check node status: `kubectl get nodes`
- Restart Minikube: `minikube stop && minikube start`
- Increase Minikube resources: `minikube start --memory=4096 --cpus=2`

### Issue: Can't access via Minikube IP
**Cause:** Network/firewall issue  
**Solution:**
- Use: `minikube service python-app-service` (opens browser automatically)
- Check service: `kubectl get svc`
- Check Minikube: `minikube status`

### Issue: "CrashLoopBackOff"
**Cause:** Container keeps crashing  
**Solution:**
- Check logs: `kubectl logs <pod-name>`
- Describe pod: `kubectl describe pod <pod-name>`
- Common causes: wrong port, missing dependencies, code errors

---

## 📝 Key Commands Reference

```bash
# Cluster Management
minikube start                 # Start cluster
minikube stop                  # Stop cluster
minikube status                # Check status
minikube dashboard             # Open web UI
minikube ip                    # Get cluster IP

# Resource Management
kubectl get pods               # List pods
kubectl get deployments        # List deployments
kubectl get services           # List services
kubectl get all                # List all resources

# Detailed Information
kubectl describe pod <name>    # Pod details
kubectl logs <pod-name>        # View logs
kubectl logs -f <pod-name>     # Follow logs
kubectl exec -it <pod> -- bash # Shell into pod

# Apply/Delete Resources
kubectl apply -f <file>        # Create/update from file
kubectl delete -f <file>       # Delete from file
kubectl delete pod <name>      # Delete specific resource

# Scaling & Updates
kubectl scale deployment <name> --replicas=5    # Scale
kubectl set image deployment/<name> <container>=<image>  # Update image
kubectl rollout status deployment/<name>        # Watch update
kubectl rollout undo deployment/<name>          # Rollback

# Debugging
kubectl port-forward pod/<name> 8080:5000      # Forward port
kubectl top pods               # Resource usage (requires metrics-server)
```

---

## ✅ Key Concepts Learned

After completing this project, you should understand:

✅ **Kubernetes Architecture** - Pods, Deployments, Services  
✅ **kubectl Commands** - Basic resource management  
✅ **Container Orchestration** - Running multiple replicas  
✅ **Service Discovery** - How pods communicate  
✅ **Health Checks** - Liveness and readiness probes  
✅ **Resource Management** - CPU and memory limits  
✅ **Rolling Updates** - Zero-downtime deployments  
✅ **YAML Manifests** - Declarative infrastructure  
✅ **Minikube** - Local k8s development

---

## ➡️ Next Steps

After mastering this project:

1. **Experiment** with the variations above
2. **Try the k8s dashboard**: `minikube dashboard`
3. **Learn about ConfigMaps and Secrets** for configuration management
4. **Move to Project 3:** Ansible configuration management
5. **Study:** Official Kubernetes documentation and tutorials

---

## 📝 Notes for Portfolio

When adding this to your portfolio or GitHub:
- Document your learning journey
- Add screenshots of the running app and k8s dashboard
- Explain experiments you tried
- Describe how this relates to real-world k8s usage
- Show kubectl command proficiency

---

## 🔗 Resources

- [Kubernetes Official Docs](https://kubernetes.io/docs/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [CKA/CKAD Exam Info](https://training.linuxfoundation.org/certification/catalog/)

---

**Project Status:** Ready to begin  
**Estimated Time:** 1-2 hours  
**Previous Project:** Terraform + Docker  
**Next Project:** Ansible automation
