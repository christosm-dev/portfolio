# Deployment Guide - Zensical Sandbox Platform

This guide walks you through deploying the Zensical Sandbox Platform to your Contabo VPS using Terraform.

## Prerequisites

Before starting, ensure you have:

1. **A Contabo VPS** (or any Ubuntu/Debian-based VPS)
   - Minimum specs: 2 CPU cores, 4GB RAM, 20GB storage
   - Ubuntu 20.04 LTS or newer
   - Root or sudo access

2. **Local machine requirements**:
   - Terraform 1.5.0 or newer
   - SSH key pair for VPS access
   - Git (for cloning the repository)

3. **Network access**:
   - SSH access to your VPS (port 22)
   - VPS must allow outbound connections (for Docker pulls)

## Step-by-Step Deployment

### 1. Prepare Your VPS

If you haven't already, set up SSH key authentication to your VPS:

```bash
# Generate SSH key pair (if you don't have one)
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# Copy your public key to the VPS
ssh-copy-id root@YOUR_VPS_IP

# Test SSH connection
ssh root@YOUR_VPS_IP
```

### 2. Clone the Repository

```bash
git clone <your-repo-url>
cd zensical-sandbox-platform
```

### 3. Configure Terraform Variables

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your actual values:

```hcl
# Your VPS IP address
vps_host = "203.0.113.42"  # Replace with your VPS IP

# SSH user (usually 'root' for Contabo)
vps_user = "root"

# Path to your SSH private key
ssh_private_key_path = "~/.ssh/id_rsa"

# Optional: If you have a domain
# domain_name = "sandbox.yourdomain.com"
# enable_ssl = true
# admin_email = "you@example.com"
```

**Security Note**: Never commit `terraform.tfvars` to version control. It's already in `.gitignore`.

### 4. Initialize Terraform

```bash
terraform init
```

This will:
- Download required Terraform providers
- Initialize the backend
- Prepare for deployment

Expected output:
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/null versions matching "~> 3.2"...
Terraform has been successfully initialized!
```

### 5. Review the Deployment Plan

```bash
terraform plan
```

This shows what Terraform will do WITHOUT making changes. Review carefully:

- ✅ Docker installation
- ✅ Firewall configuration (UFW)
- ✅ Application file copying
- ✅ Container deployment
- ✅ Systemd service setup

Example output:
```
Plan: 6 to add, 0 to change, 0 to destroy.
```

### 6. Deploy to VPS

```bash
terraform apply
```

Type `yes` when prompted.

The deployment process takes 5-10 minutes and includes:

1. **Installing dependencies** (Docker, Docker Compose, UFW, fail2ban)
2. **Configuring firewall** (allowing ports 22, 80, 443, 8000)
3. **Copying application files** to `/opt/zensical-sandbox`
4. **Pulling Docker images** (Python, Node.js, Bash)
5. **Building and starting containers**
6. **Setting up systemd service** for auto-restart

### 7. Verify Deployment

Once Terraform completes, verify the deployment:

```bash
# Test the health endpoint
curl http://YOUR_VPS_IP:8000/health

# Expected response:
# {
#   "status": "healthy",
#   "docker_available": true,
#   "timestamp": "2024-02-04T10:30:00Z",
#   "active_containers": 0
# }
```

### 8. Test Code Execution

Use the test client:

```bash
# From your local machine
cd ..  # Back to project root
python3 test_client.py
```

Or use curl:

```bash
curl -X POST http://YOUR_VPS_IP:8000/execute \
  -H "Content-Type: application/json" \
  -d '{
    "code": "print(\"Hello from VPS!\")",
    "environment": "python",
    "timeout": 30
  }'
```

## Post-Deployment Configuration

### Access Logs

SSH into your VPS:

```bash
ssh root@YOUR_VPS_IP
cd /opt/zensical-sandbox
docker-compose logs -f sandbox-api
```

### Check Service Status

```bash
# On VPS
systemctl status zensical-sandbox

# Docker containers
docker-compose ps

# Container logs
docker-compose logs sandbox-api
```

### Restart Services

```bash
# Restart the entire stack
cd /opt/zensical-sandbox
docker-compose restart

# Or via systemd
systemctl restart zensical-sandbox
```

## Updating the Application

When you make changes to the code:

### Method 1: Terraform Re-apply (Recommended)

```bash
# From your local machine
cd terraform
terraform apply
```

This will:
- Copy updated files
- Rebuild containers
- Restart services

### Method 2: Manual Update (Quick changes)

```bash
# SSH to VPS
ssh root@YOUR_VPS_IP
cd /opt/zensical-sandbox

# Pull latest code (if using Git on VPS)
git pull

# Rebuild and restart
docker-compose down
docker-compose build
docker-compose up -d
```

## Production Considerations

### 1. Secure Port 8000

In production, you should NOT expose port 8000 directly. Instead:

**Option A: Use NGINX Reverse Proxy**

```bash
# Install NGINX
apt-get install -y nginx certbot python3-certbot-nginx

# Configure NGINX
nano /etc/nginx/sites-available/sandbox
```

Add configuration:
```nginx
server {
    listen 80;
    server_name sandbox.yourdomain.com;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Enable and test:
```bash
ln -s /etc/nginx/sites-available/sandbox /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx

# Get SSL certificate
certbot --nginx -d sandbox.yourdomain.com
```

**Option B: Update Firewall**

```bash
# Remove port 8000 from public access
ufw delete allow 8000/tcp
ufw reload
```

### 2. Configure Domain Name

Update your DNS records:

```
Type: A
Name: sandbox (or @ for apex)
Value: YOUR_VPS_IP
TTL: 300
```

Wait for DNS propagation (can take up to 48 hours, usually minutes).

### 3. Enable Rate Limiting (NGINX)

Add to NGINX config:
```nginx
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/m;

server {
    # ... other config ...
    
    location /execute {
        limit_req zone=api burst=5;
        proxy_pass http://127.0.0.1:8000;
    }
}
```

### 4. Set Up Monitoring

Install monitoring tools:
```bash
# Install Netdata for real-time monitoring
bash <(curl -Ss https://my-netdata.io/kickstart.sh)

# Access at http://YOUR_VPS_IP:19999
```

### 5. Configure Backups

Set up automated backups:
```bash
# Create backup script
cat > /root/backup-sandbox.sh <<'EOF'
#!/bin/bash
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR
tar -czf $BACKUP_DIR/sandbox-$DATE.tar.gz /opt/zensical-sandbox
find $BACKUP_DIR -mtime +7 -delete  # Keep 7 days
EOF

chmod +x /root/backup-sandbox.sh

# Add to crontab (daily at 2 AM)
(crontab -l 2>/dev/null; echo "0 2 * * * /root/backup-sandbox.sh") | crontab -
```

## Troubleshooting

### Issue: Cannot connect to API

**Check 1: Service running?**
```bash
ssh root@YOUR_VPS_IP
cd /opt/zensical-sandbox
docker-compose ps
```

**Check 2: Firewall blocking?**
```bash
ufw status
# Ensure port 8000 is allowed (or 80/443 if using NGINX)
```

**Check 3: Docker issues?**
```bash
docker-compose logs sandbox-api
```

### Issue: Rate limit errors

The API limits to 10 requests per 60 seconds per IP. Wait and try again, or adjust in `backend/main.py`:

```python
RATE_LIMIT_WINDOW = 60  # Increase to 120
MAX_REQUESTS_PER_WINDOW = 10  # Increase to 20
```

Then redeploy.

### Issue: Containers won't start

**Check Docker logs:**
```bash
docker-compose logs -f
```

**Common causes:**
1. Insufficient memory - upgrade VPS
2. Docker socket permissions - ensure `/var/run/docker.sock` is accessible
3. Port already in use - check with `netstat -tlnp | grep 8000`

### Issue: Execution timeouts

If executions are timing out:

1. **Check VPS resources:**
```bash
htop  # Check CPU/memory usage
docker stats  # Check container resources
```

2. **Increase timeout limits** in `backend/main.py`:
```python
EXECUTION_TIMEOUT = 60  # Increase from 30
```

3. **Increase resource limits** in `docker-compose.yml`:
```yaml
MEMORY_LIMIT = "512m"  # Increase from 256m
CPU_QUOTA = 100000     # Increase from 50000
```

## Destroying the Deployment

To completely remove the deployment:

```bash
# From your local machine
cd terraform
terraform destroy
```

This will:
- Stop all containers
- Remove systemd service
- NOT remove Docker (you can do that manually if needed)
- Leave backups intact

**Warning**: This does NOT uninstall Docker or remove all files. To fully clean:

```bash
ssh root@YOUR_VPS_IP

# Stop services
systemctl stop zensical-sandbox
systemctl disable zensical-sandbox

# Remove application
rm -rf /opt/zensical-sandbox

# Optional: Remove Docker
apt-get remove docker-ce docker-ce-cli containerd.io
rm -rf /var/lib/docker
```

## Security Checklist

Before going to production:

- [ ] Firewall configured (UFW enabled)
- [ ] Port 8000 NOT publicly exposed (use NGINX)
- [ ] SSL/TLS certificate installed (Let's Encrypt)
- [ ] fail2ban configured for SSH protection
- [ ] Regular security updates enabled
- [ ] Monitoring set up (Netdata or similar)
- [ ] Backups automated
- [ ] Rate limiting configured
- [ ] Logs being reviewed periodically

## Next Steps

1. **Integrate with your frontend** - Update `frontend-integration/example.html` with your VPS IP
2. **Set up monitoring** - Install Prometheus and Grafana for metrics
3. **Configure alerts** - Get notified of issues via email/Slack
4. **Document for interviews** - Note architecture decisions and security measures
5. **Prepare for Phase 2** - Plan Kubernetes migration

## Support

For issues or questions:
1. Check logs: `docker-compose logs -f`
2. Review Terraform output: `terraform output`
3. Test connectivity: `curl http://YOUR_VPS_IP:8000/health`
4. Check GitHub issues (if open source)

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Terraform Documentation](https://www.terraform.io/docs)
- [NGINX Reverse Proxy Guide](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [UFW Firewall Guide](https://help.ubuntu.com/community/UFW)
