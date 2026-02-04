# Security Architecture - Zensical Sandbox Platform

This document details the security measures implemented in the Zensical Sandbox Platform, demonstrating security-conscious development practices suitable for roles requiring security clearance.

## Table of Contents

1. [Threat Model](#threat-model)
2. [Defense-in-Depth Architecture](#defense-in-depth-architecture)
3. [Container Security](#container-security)
4. [Network Security](#network-security)
5. [Application Security](#application-security)
6. [Infrastructure Security](#infrastructure-security)
7. [Compliance Considerations](#compliance-considerations)
8. [Security Testing](#security-testing)
9. [Incident Response](#incident-response)

## Threat Model

### Assets to Protect

1. **VPS Infrastructure** - The host system must remain secure
2. **Service Availability** - Prevent denial of service
3. **System Resources** - CPU, memory, disk, network bandwidth
4. **Other Users' Data** - Isolation between executions
5. **API Integrity** - Prevent unauthorized access or manipulation

### Threat Actors

1. **Malicious Users** - Attempting to exploit sandbox for cryptocurrency mining, DOS attacks, or host escape
2. **Curious Users** - Testing boundaries of the sandbox
3. **Automated Bots** - Scanning for vulnerabilities
4. **Resource Abusers** - Attempting to consume excessive resources

### Attack Vectors

1. **Container Escape** - Breaking out of Docker isolation
2. **Resource Exhaustion** - Fork bombs, memory exhaustion, CPU hogging
3. **Network Abuse** - Port scanning, external connections
4. **Code Injection** - Exploiting command execution
5. **Rate Limit Bypass** - Overwhelming the API
6. **Privilege Escalation** - Gaining elevated permissions

## Defense-in-Depth Architecture

Our security approach uses multiple layers of protection:

```
┌───────────────────────────────────────────────┐
│         Layer 1: Network Security             │
│  • Firewall (UFW)                             │
│  • Rate Limiting                              │
│  • fail2ban                                   │
└───────────────┬───────────────────────────────┘
                │
┌───────────────▼───────────────────────────────┐
│      Layer 2: Application Security            │
│  • Input Validation                           │
│  • Request Size Limits                        │
│  • Dangerous Pattern Detection                │
└───────────────┬───────────────────────────────┘
                │
┌───────────────▼───────────────────────────────┐
│       Layer 3: Container Security             │
│  • Network Isolation (network_mode: none)     │
│  • Read-only Filesystem                       │
│  • Capability Dropping (cap_drop: ALL)        │
│  • No New Privileges                          │
└───────────────┬───────────────────────────────┘
                │
┌───────────────▼───────────────────────────────┐
│      Layer 4: Resource Constraints            │
│  • CPU Limits (50% of one core)               │
│  • Memory Limits (256MB hard limit)           │
│  • Process Limits (50 processes max)          │
│  • Execution Timeouts (30 seconds)            │
└───────────────┬───────────────────────────────┘
                │
┌───────────────▼───────────────────────────────┐
│      Layer 5: Monitoring & Logging            │
│  • Execution Logging                          │
│  • Error Tracking                             │
│  • Resource Monitoring                        │
└───────────────────────────────────────────────┘
```

## Container Security

### 1. Network Isolation

**Configuration:**
```yaml
network_mode: "none"
```

**Effect:**
- Containers have NO network access whatsoever
- Cannot connect to external services
- Cannot port scan internal networks
- Cannot download malicious payloads
- Cannot participate in DDOS attacks

**Verification:**
```bash
# Inside container
ping google.com  # Fails
curl https://example.com  # Fails
wget http://malicious.com  # Fails
```

### 2. Read-only Filesystem

**Configuration:**
```yaml
read_only: true
tmpfs:
  - /tmp:size=50M,mode=1777
```

**Effect:**
- Root filesystem is immutable
- Only /tmp is writable (limited to 50MB)
- Prevents persistence of malware
- Prevents modification of system files
- No ability to install packages

**Verification:**
```bash
# Inside container
touch /malware.sh  # Permission denied
echo "data" > /etc/passwd  # Read-only file system
```

### 3. Capability Dropping

**Configuration:**
```yaml
cap_drop:
  - ALL
```

**Effect:**
- Removes ALL Linux capabilities
- No ability to:
  - Modify kernel parameters
  - Load kernel modules
  - Perform administrative operations
  - Change file ownership/permissions
  - Create device nodes
  - Perform network administration

**Linux Capabilities Dropped:**
- CAP_CHOWN
- CAP_DAC_OVERRIDE
- CAP_FSETID
- CAP_KILL
- CAP_NET_BIND_SERVICE
- CAP_NET_RAW
- CAP_SYS_ADMIN
- CAP_SYS_BOOT
- CAP_SYS_MODULE
- ... and 30+ others

### 4. No New Privileges

**Configuration:**
```yaml
security_opt:
  - no-new-privileges:true
```

**Effect:**
- Prevents gaining additional privileges via setuid/setgid
- Even if setuid binary exists, it runs with user's privileges
- Prevents privilege escalation attacks

### 5. Process Limits

**Configuration:**
```yaml
pids_limit: 50
```

**Effect:**
- Maximum 50 processes per container
- Prevents fork bomb attacks
- Protects host from process exhaustion

**Fork Bomb Example (Prevented):**
```bash
# This classic fork bomb is blocked:
:(){ :|:& };:
# After 50 processes, new forks fail
```

### 6. Resource Constraints

**CPU Limiting:**
```yaml
cpu_quota: 50000    # 50% of one core
cpu_period: 100000
```

**Memory Limiting:**
```yaml
mem_limit: 256m
memswap_limit: 256m  # No swap
```

**Effect:**
- Prevents CPU-based DOS
- Prevents memory exhaustion
- Container killed if limits exceeded
- Host remains stable

### 7. Execution Timeout

**Code Implementation:**
```python
container.wait(timeout=timeout)  # 30 seconds default
```

**Effect:**
- Long-running processes are killed
- Prevents infinite loops
- Protects against computational complexity attacks

## Network Security

### Firewall Configuration (UFW)

```bash
# Default policies
ufw default deny incoming
ufw default allow outgoing

# Allowed services
ufw allow ssh       # Port 22
ufw allow 80/tcp    # HTTP (if using NGINX)
ufw allow 443/tcp   # HTTPS (if using SSL)
```

**Production Recommendation:**
```bash
# Remove direct API access
ufw delete allow 8000/tcp

# Force traffic through NGINX
# NGINX then proxies to localhost:8000
```

### Rate Limiting

**Implementation:**
```python
RATE_LIMIT_WINDOW = 60  # seconds
MAX_REQUESTS_PER_WINDOW = 10  # requests per IP

def check_rate_limit(ip_address: str) -> bool:
    current_time = time.time()
    # Clean old entries
    rate_limit_store[ip_address] = [
        req_time for req_time in rate_limit_store[ip_address]
        if current_time - req_time < RATE_LIMIT_WINDOW
    ]
    # Check limit
    if len(rate_limit_store[ip_address]) >= MAX_REQUESTS_PER_WINDOW:
        return False
    rate_limit_store[ip_address].append(current_time)
    return True
```

**Effect:**
- Limits each IP to 10 requests per minute
- Prevents automated abuse
- Protects against brute force attempts
- Reduces DOS attack effectiveness

### fail2ban Protection

**SSH Protection:**
```bash
# /etc/fail2ban/jail.local
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
```

## Application Security

### Input Validation

**Code Length Limits:**
```python
code: str = Field(..., min_length=1, max_length=5000)
```

**Dangerous Pattern Detection:**
```python
dangerous_patterns = [
    'rm -rf',        # Destructive commands
    'dd if=',        # Disk operations
    'fork',          # Fork bombs
    ':(){ :|:& };:', # Fork bomb syntax
    '/dev/random',   # Entropy exhaustion
    'curl',          # Network access
    'wget',          # Network access
    'nc ',           # Netcat
]
```

### Output Sanitization

```python
MAX_OUTPUT_SIZE = 10000  # 10KB

if len(logs) > MAX_OUTPUT_SIZE:
    logs = logs[:MAX_OUTPUT_SIZE] + "\n... (output truncated)"
```

### Error Handling

- Never expose internal paths or system information
- Generic error messages to users
- Detailed errors logged server-side only

### Authentication (Future)

For production deployment, consider:
- API key authentication
- JWT tokens for session management
- OAuth2 for user authentication
- Per-user rate limits and quotas

## Infrastructure Security

### VPS Hardening

**1. SSH Security:**
```bash
# Disable password authentication
PasswordAuthentication no

# Disable root login
PermitRootLogin prohibit-password

# Use key-based auth only
PubkeyAuthentication yes
```

**2. System Updates:**
```bash
# Enable automatic security updates
apt-get install unattended-upgrades
dpkg-reconfigure -plow unattended-upgrades
```

**3. Audit Logging:**
```bash
# Install auditd
apt-get install auditd

# Monitor Docker socket
auditctl -w /var/run/docker.sock -p rwxa -k docker
```

### Docker Security

**1. Docker Socket Protection:**
```yaml
# IMPORTANT: Mounting Docker socket grants significant privileges
volumes:
  - /var/run/docker.sock:/var/run/docker.sock
```

**Mitigation:**
- API runs in isolated container
- API itself has resource limits
- Regular security audits
- Consider alternatives like Kubernetes for production

**2. Image Security:**
```bash
# Use official, minimal images
python:3.11-slim      # vs python:3.11
node:18-alpine        # vs node:18
bash:5.2-alpine3.19   # vs bash:latest
```

**3. Image Scanning:**
```bash
# Scan images for vulnerabilities
docker scout quickview python:3.11-slim
docker scout cves python:3.11-slim
```

### Secrets Management

**Current (Development):**
- No secrets required
- Configuration in terraform.tfvars (not committed)

**Production Recommendations:**
1. Use environment variables
2. HashiCorp Vault for sensitive data
3. Kubernetes Secrets (Phase 2)
4. Never commit credentials to Git

## Compliance Considerations

### GDPR Compliance

**Data Minimization:**
- No personal data stored
- Only anonymous execution logs
- IP addresses for rate limiting (can be hashed)

**Right to be Forgotten:**
- No persistent user data
- Logs can be purged on request

### UK Security Clearance (SC Level)

This architecture demonstrates:

**Physical Security Awareness:**
- VPS hosted in known locations
- No cross-border data transfer (if UK VPS)

**Logical Security:**
- Defense-in-depth approach
- Least privilege principle
- Network segmentation
- Comprehensive logging

**Personnel Security:**
- Clear documentation
- Audit trail capability
- Incident response procedures

### Industry Standards

**CIS Docker Benchmark:**
- ✅ 5.1: Verify AppArmor profile (if enabled)
- ✅ 5.2: Verify SELinux security options (if enabled)
- ✅ 5.3: Restrict Linux kernel capabilities
- ✅ 5.7: Do not map sensitive host directories
- ✅ 5.10: Do not run containers with --privileged flag
- ✅ 5.12: Limit memory usage
- ✅ 5.13: Set CPU priority
- ✅ 5.14: Mount container's root filesystem as read only
- ✅ 5.25: Restrict container from acquiring additional privileges

## Security Testing

### Manual Testing

**1. Network Isolation Test:**
```python
# Should fail
code = "import urllib.request; urllib.request.urlopen('http://google.com')"
```

**2. File System Write Test:**
```python
# Should fail
code = "with open('/tmp/../etc/passwd', 'w') as f: f.write('hacked')"
```

**3. Fork Bomb Test:**
```bash
# Should be limited to 50 processes
code = ":(){ :|:& };:"
```

**4. Memory Exhaustion Test:**
```python
# Should be killed at 256MB
code = "a = ' ' * (1024 * 1024 * 1024)"
```

**5. CPU Hogging Test:**
```python
# Should be limited to 50% CPU
code = "while True: pass"
```

### Automated Testing

Create test suite:
```python
import pytest
from test_client import SandboxClient

def test_network_isolation():
    client = SandboxClient()
    result = client.execute_code(
        "import socket; socket.create_connection(('google.com', 80))",
        "python"
    )
    assert result['status'] == 'error'

def test_filesystem_readonly():
    client = SandboxClient()
    result = client.execute_code(
        "with open('/etc/passwd', 'w') as f: f.write('test')",
        "python"
    )
    assert result['status'] == 'error'

# Add more tests...
```

## Incident Response

### Detection

**Monitoring:**
- Watch for repeated rate limit violations
- Alert on container creation failures
- Monitor CPU/memory spikes
- Track execution errors

**Log Analysis:**
```bash
# Check for suspicious patterns
grep "error" /opt/zensical-sandbox/logs/*.log
grep "timeout" /opt/zensical-sandbox/logs/*.log
grep "rate limit" /opt/zensical-sandbox/logs/*.log
```

### Response Procedures

**1. Rate Limit Violations:**
```bash
# Identify offending IP
grep "Rate limit exceeded" logs/*.log | awk '{print $X}' | sort | uniq -c

# Block with UFW
ufw deny from OFFENDING_IP
```

**2. Resource Exhaustion:**
```bash
# Stop all sandbox containers
docker ps | grep zensical | awk '{print $1}' | xargs docker stop

# Restart service
docker-compose restart
```

**3. Container Escape Attempt:**
```bash
# Immediately stop service
systemctl stop zensical-sandbox

# Audit logs
auditctl -w /var/run/docker.sock -p rwxa

# Review and patch
docker-compose down
# Apply security updates
docker-compose up -d
```

### Reporting

For security issues:
1. Document the incident
2. Preserve logs
3. Patch the vulnerability
4. Update documentation
5. Consider public disclosure (responsible disclosure)

## Security Roadmap

### Phase 1 (Current)
- ✅ Docker-based isolation
- ✅ Resource limits
- ✅ Network isolation
- ✅ Rate limiting

### Phase 2 (Kubernetes)
- [ ] Namespace-based multi-tenancy
- [ ] NetworkPolicies
- [ ] PodSecurityPolicies/PodSecurityStandards
- [ ] ResourceQuotas
- [ ] Admission webhooks

### Phase 3 (Advanced)
- [ ] gVisor runtime
- [ ] Firecracker microVMs
- [ ] Secret management (Vault)
- [ ] SIEM integration
- [ ] Automated security scanning

## Audit Trail

All executions are logged with:
- Unique execution ID
- Timestamp
- Source IP address
- Environment used
- Execution status
- Execution time
- Output/errors (truncated)

**Log Format:**
```
2024-02-04 10:30:00 - INFO - Starting execution abc-123 in python environment
2024-02-04 10:30:01 - INFO - Container started: container_xyz
2024-02-04 10:30:01 - INFO - Execution abc-123 completed: success in 0.523s
```

## Conclusion

This security architecture demonstrates:

1. **Defense-in-Depth**: Multiple layers of security
2. **Least Privilege**: Minimal permissions at every level
3. **Isolation**: Strong boundaries between executions
4. **Monitoring**: Comprehensive logging and alerting
5. **Incident Response**: Clear procedures for security events

These practices are directly applicable to roles in:
- Aerospace and Defense (SC clearance requirements)
- Financial Services (PCI-DSS, data protection)
- Healthcare (HIPAA compliance)
- Government (GovCloud, FedRAMP)

The architecture shows security-conscious development suitable for sensitive environments while maintaining usability and performance.
