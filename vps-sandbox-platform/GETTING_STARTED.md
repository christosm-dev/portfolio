# Getting Started - Zensical Sandbox Platform

Welcome to the Zensical Sandbox Platform! This document will help you get up and running quickly.

## What Is This Project?

A production-grade, secure sandbox execution platform that:
- Executes Python, Node.js, and Bash code in isolated containers
- Implements defense-in-depth security (network isolation, resource limits, capability dropping)
- Demonstrates DevOps, SRE, and Platform Engineering skills
- Provides a foundation for Kubernetes migration (Phase 2)

**Perfect for:** Portfolio demonstration, interview discussions, hands-on learning of containerization and orchestration

## Quick Start (5 Minutes)

### 1. Prerequisites Check

```bash
# Check Docker
docker --version
# Should show: Docker version 20.x or higher

# Check Docker Compose
docker-compose --version
# Should show: Docker Compose version 2.x or higher

# Check Python
python3 --version
# Should show: Python 3.8 or higher
```

### 2. Start the Platform

```bash
# Clone (or if you have the files locally, navigate to directory)
cd zensical-sandbox-platform

# Start services
docker-compose up --build
```

Wait for: `Uvicorn running on http://0.0.0.0:8000`

### 3. Test It Works

**Option A: Use the test client**
```bash
# In a new terminal
python3 test_client.py
```

**Option B: Use curl**
```bash
curl http://localhost:8000/health
```

**Option C: Open the frontend**
```bash
# Open in browser
open frontend-integration/example.html
# Or: firefox frontend-integration/example.html
```

### 4. Try Running Code

**Via test client:**
```bash
python3 test_client.py --interactive
>>> python print("Hello, World!")
```

**Via curl:**
```bash
curl -X POST http://localhost:8000/execute \
  -H "Content-Type: application/json" \
  -d '{
    "code": "print(\"Hello from Docker!\")",
    "environment": "python",
    "timeout": 30
  }'
```

## Project Structure

```
zensical-sandbox-platform/
├── README.md                      # Main documentation
├── docker-compose.yml             # Service orchestration
├── test_client.py                 # Test/demo script
│
├── backend/                       # FastAPI application
│   ├── main.py                   # API implementation
│   ├── requirements.txt          # Python dependencies
│   └── Dockerfile                # Container image
│
├── terraform/                     # Infrastructure as Code
│   ├── main.tf                   # VPS provisioning
│   └── terraform.tfvars.example  # Configuration template
│
├── docs/                         # Comprehensive documentation
│   ├── DEPLOYMENT.md            # Step-by-step deployment guide
│   ├── SECURITY.md              # Security architecture details
│   └── KUBERNETES_MIGRATION.md  # Phase 2 upgrade path
│
└── frontend-integration/         # Example frontend
    └── example.html             # Working demo page
```

## What Can You Do?

### For Learning

**Explore the code:**
- `backend/main.py` - See FastAPI patterns, Docker SDK usage
- `docker-compose.yml` - Understand service orchestration
- `terraform/main.tf` - Learn Infrastructure as Code

**Experiment safely:**
- Modify resource limits
- Add new execution environments
- Try breaking the security (it should hold!)

### For Your Portfolio

**Demonstrate to employers:**
1. Open `frontend-integration/example.html` in browser
2. Show live code execution
3. Explain security measures (see `docs/SECURITY.md`)
4. Discuss architecture decisions

**Interview preparation:**
- Review `docs/SECURITY.md` for talking points
- Practice explaining the architecture
- Be ready to discuss trade-offs

### For Career Development

**Aligns with certifications:**
- Docker fundamentals (current)
- Terraform Associate (Terraform code included)
- CKA/CKAD (Phase 2 migration path documented)

**Relevant job roles:**
- DevOps Engineer (automated deployment)
- SRE (reliability patterns, resource management)
- Platform Engineer (developer-facing API)
- Cloud Engineer (infrastructure automation)

## Common Tasks

### View Logs

```bash
docker-compose logs -f sandbox-api
```

### Restart Services

```bash
docker-compose restart
```

### Update Code

```bash
# After modifying backend/main.py
docker-compose down
docker-compose up --build
```

### Stop Everything

```bash
docker-compose down
```

### Clean Up Completely

```bash
docker-compose down -v
docker system prune -a
```

## Deployment to VPS

When ready to deploy to your Contabo VPS:

1. **Read the deployment guide:**
```bash
cat docs/DEPLOYMENT.md
```

2. **Configure Terraform:**
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your VPS details
```

3. **Deploy:**
```bash
terraform init
terraform apply
```

See `docs/DEPLOYMENT.md` for complete instructions.

## Phase 2: Kubernetes Migration

Ready to level up? Migrate to Kubernetes:

1. **Read the migration guide:**
```bash
cat docs/KUBERNETES_MIGRATION.md
```

2. **Benefits:**
- Enhanced isolation (namespace-based)
- Enterprise patterns (ResourceQuotas, NetworkPolicies)
- CKA/CKAD exam alignment
- Portfolio differentiation

3. **Timeline:**
- Phase 1 (Current): Docker-based sandbox ✅
- Phase 2 (Next): Kubernetes orchestration
- Phase 3 (Advanced): gVisor, Firecracker, full production

## Troubleshooting

### Docker not running

```bash
# Start Docker
sudo systemctl start docker

# Or on Mac/Windows: Start Docker Desktop
```

### Port 8000 already in use

```bash
# Find what's using port 8000
sudo lsof -i :8000
# Or: netstat -tlnp | grep 8000

# Change the port in docker-compose.yml:
ports:
  - "8001:8000"  # Use 8001 instead
```

### Cannot connect to Docker daemon

```bash
# Add your user to docker group
sudo usermod -aG docker $USER
# Log out and back in
```

### API returns errors

```bash
# Check logs
docker-compose logs sandbox-api

# Check Docker is accessible
docker ps

# Restart everything
docker-compose down
docker-compose up --build
```

## Key Features to Highlight

### Security (Aerospace/Defense Interviews)

1. **Network Isolation**: Containers have zero network access
2. **Resource Limits**: CPU, memory, process count all constrained
3. **Read-only Filesystem**: Only temp directory is writable
4. **Capability Dropping**: All Linux capabilities removed
5. **Defense-in-Depth**: Multiple security layers

### Reliability (SRE Interviews)

1. **Health Checks**: Automatic service health monitoring
2. **Resource Management**: Prevents resource exhaustion
3. **Automatic Cleanup**: Containers removed after execution
4. **Rate Limiting**: Protection against abuse
5. **Comprehensive Logging**: All executions tracked

### Automation (DevOps Interviews)

1. **Infrastructure as Code**: Terraform for VPS provisioning
2. **Containerization**: Docker for consistent environments
3. **Orchestration**: Docker Compose (Phase 1), K8s (Phase 2)
4. **CI/CD Ready**: Easy to integrate with pipelines
5. **One-Command Deploy**: `terraform apply`

## Learning Resources

### Included Documentation

- `README.md` - Project overview and API reference
- `docs/DEPLOYMENT.md` - Complete deployment guide
- `docs/SECURITY.md` - Security architecture deep-dive
- `docs/KUBERNETES_MIGRATION.md` - K8s upgrade path

### External Resources

**Docker:**
- [Docker Documentation](https://docs.docker.com/)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)

**Terraform:**
- [Terraform Tutorials](https://learn.hashicorp.com/terraform)
- [Terraform Docker Provider](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs)

**Kubernetes:**
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [CKA Exam Prep](https://github.com/cncf/curriculum)
- [CKAD Exam Prep](https://github.com/cncf/curriculum)

## Next Steps

### Immediate (Today)

1. ✅ Get it running locally
2. ✅ Try the test client
3. ✅ Open the frontend demo
4. ✅ Read the security documentation

### Short Term (This Week)

1. Deploy to your Contabo VPS
2. Integrate with your Zensical portfolio
3. Customize the frontend styling
4. Add it to your GitHub/portfolio

### Medium Term (This Month)

1. Start Terraform certification prep
2. Begin CKA/CKAD studies
3. Plan Phase 2 Kubernetes migration
4. Practice explaining it for interviews

### Long Term (Next Quarter)

1. Implement Phase 2 (Kubernetes)
2. Add monitoring (Prometheus/Grafana)
3. Contribute to open source similar projects
4. Use as interview showcase piece

## Getting Help

### Check These First

1. **Logs**: `docker-compose logs -f`
2. **Health**: `curl http://localhost:8000/health`
3. **Docker Status**: `docker ps`
4. **Troubleshooting Section**: Above in this document

### Still Stuck?

1. Review relevant documentation in `docs/`
2. Check Docker/Docker Compose documentation
3. Verify all prerequisites are installed
4. Try restarting from scratch: `docker-compose down && docker-compose up --build`

## Success Criteria

You'll know you're ready to deploy when:

- ✅ Local environment runs without errors
- ✅ Test client executes Python, Node.js, and Bash successfully
- ✅ Health endpoint returns "healthy"
- ✅ Frontend demo page works
- ✅ You can explain the security architecture
- ✅ You've read the deployment guide

## Contribution Ideas

Want to enhance this project?

1. **Add new languages**: Ruby, Go, Rust
2. **Better frontend**: React component, syntax highlighting
3. **Monitoring**: Prometheus metrics
4. **Testing**: Automated security tests
5. **Documentation**: More examples, tutorials
6. **Phase 2**: Help with Kubernetes implementation

## Contact & Portfolio

- **Your Portfolio**: [Add your URL]
- **LinkedIn**: [Add your LinkedIn]
- **GitHub**: [Add your GitHub]
- **Email**: [Add your email]

---

**Built by Christos** - Demonstrating DevOps, SRE, and Platform Engineering Excellence

Ready to transform your infrastructure skills and land that perfect remote role in aerospace, fintech, or platform engineering? This project is your foundation.

Start here. Build confidence. Deploy to production. Ace those interviews. 🚀
