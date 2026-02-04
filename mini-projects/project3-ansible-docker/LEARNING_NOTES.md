# Ansible Project - Hands-On Learning Notes

**Date**: February 4, 2026
**Project**: 3-ansible-docker-demo
**Goal**: Learn Ansible fundamentals through hands-on practice
**Status**: ✅ Successfully Completed

---

## 🎯 Session Overview

This document captures hands-on learning from running and testing the ansible-docker-demo project. The project demonstrates Ansible automation by configuring Docker containers as if they were production servers.

**What Was Accomplished**:
- Set up Docker infrastructure with 3 target containers
- Configured Ansible connectivity to manage remote hosts
- Executed playbooks to automate server configuration
- Installed and configured nginx web servers across all hosts simultaneously
- Verified automation results
- Understood idempotency through practical demonstration

---

## 🛠️ Technical Setup Completed

### Environment Configuration

**Prerequisites Installed**:
- Docker Engine (running)
- Docker Compose V2 (v5.0.2)
- Ansible (with sshpass for password authentication)

**Infrastructure Deployed**:
- 3 Ubuntu 22.04 Docker containers (ansible-target1, target2, target3)
- SSH servers enabled on ports 2221, 2222, 2223
- Nginx web servers exposed on ports 8081, 8082, 8083
- Isolated bridge network for container communication

### Issues Encountered & Resolved

#### Issue 1: Docker Compose Compatibility Error
**Problem**:
```
ModuleNotFoundError: No module named 'distutils'
```
- Old `docker-compose` (v1.29.2) incompatible with Python 3.12
- Python 3.12 removed the `distutils` module

**Solution**:
- Used Docker Compose V2 command syntax: `docker compose` (space, not hyphen)
- Docker Compose V2 is written in Go, has no Python dependencies

**Learning**: Always check tool versions and migration paths when upgrading system Python versions.

#### Issue 2: Ansible SSH Password Authentication
**Problem**:
```
msg": "to use the 'ssh' connection type with passwords, you must install the sshpass program"
```

**Solution**:
- Installed `sshpass`: `sudo apt install sshpass -y`
- Allows Ansible to pass passwords to SSH non-interactively

**Learning**:
- Ansible uses SSH for communication (agentless architecture)
- Password authentication requires `sshpass`
- Production environments use SSH keys instead (more secure)

#### Issue 3: Missing Web Server Port Mappings
**Problem**:
```
curl: (1) Received HTTP/0.9 when not allowed
```
- Port 2221 mapped to SSH (port 22), not nginx (port 80)

**Solution**:
- Updated `docker-compose.yml` to expose nginx ports:
  - target1: `8081:80`
  - target2: `8082:80`
  - target3: `8083:80`
- Restarted containers: `docker compose down && docker compose up -d`

**Learning**:
- Docker port mappings are `host:container`
- Multiple ports can be exposed per container
- Configuration changes require container restart

---

## 📚 Ansible Concepts Learned

### 1. Ansible Architecture

**Agentless Design**:
- No software to install on managed hosts
- Uses SSH + Python (already on most Linux systems)
- Control node (your machine) connects to managed nodes (containers)

**Key Components**:
- **Control Node**: Where Ansible runs (your laptop/workstation)
- **Managed Nodes**: Servers being configured (the 3 Docker containers)
- **Inventory**: List of hosts to manage ([inventory.ini](file:///home/cm/portfolio/3-ansible-docker-demo/inventory.ini))
- **Playbook**: YAML file describing automation tasks ([playbook.yml](file:///home/cm/portfolio/3-ansible-docker-demo/playbook.yml))
- **Modules**: Reusable units of work (apt, service, template, file, copy)

### 2. Inventory Management

**File**: [inventory.ini](file:///home/cm/portfolio/3-ansible-docker-demo/inventory.ini:1-15)

**Structure Learned**:
```ini
[webservers]                          # Group name
target1 ansible_host=localhost ansible_port=2221
target2 ansible_host=localhost ansible_port=2222
target3 ansible_host=localhost ansible_port=2223

[webservers:vars]                     # Group variables
ansible_user=ansible
ansible_password=ansible
ansible_connection=ssh
```

**Key Concepts**:
- **Groups**: Organize hosts by function (webservers, databases, etc.)
- **Host Variables**: Connection details specific to each host
- **Group Variables**: Shared settings for all hosts in a group
- **Targeting**: Can run playbooks against all hosts, specific groups, or individual hosts

**Production Difference**:
- Demo uses static inventory with hardcoded passwords
- Production uses dynamic inventories (cloud APIs, CMDBs) with SSH keys

### 3. Playbook Structure

**File**: [playbook.yml](file:///home/cm/portfolio/3-ansible-docker-demo/playbook.yml:1-79)

**Components Learned**:

```yaml
---
- name: Configure Web Servers          # Play name (descriptive)
  hosts: webservers                    # Target group from inventory
  become: yes                          # Use sudo for privileged tasks

  vars:                                # Variables for customization
    nginx_port: 80
    document_root: /var/www/html

  tasks:                               # List of actions to perform
    - name: Install nginx
      apt:
        name: nginx
        state: present
      notify: Start nginx              # Trigger handler if changed

  handlers:                            # Triggered actions
    - name: Start nginx
      service:
        name: nginx
        state: started
```

**Learning Points**:
- Playbooks are declarative - describe desired state, not steps
- YAML syntax is human-readable and version-controllable
- Tasks run in order on all hosts
- Handlers only run if notified and run at the end of the play

### 4. Modules Used

#### apt Module (Package Management)
```yaml
- name: Install nginx
  apt:
    name: nginx
    state: present
    update_cache: yes
```
- Manages Debian/Ubuntu packages
- `state: present` ensures package is installed
- `update_cache: yes` runs `apt update` first

#### service Module (Service Control)
```yaml
- name: Ensure nginx is running
  service:
    name: nginx
    state: started
    enabled: yes
```
- Manages systemd/init services
- `state: started` ensures service is running
- `enabled: yes` configures service to start on boot

#### template Module (Jinja2 Templates)
```yaml
- name: Create custom index.html
  template:
    src: templates/index.html.j2
    dest: /var/www/html/index.html
    mode: '0644'
```
- Renders Jinja2 templates with variables
- Creates host-specific configurations
- Uses Ansible facts for dynamic content

#### file Module (Directory Management)
```yaml
- name: Create a custom directory
  file:
    path: /opt/ansible-demo
    state: directory
    mode: '0755'
```
- Creates directories and manages permissions
- `state: directory` ensures directory exists
- `mode` sets Unix permissions

#### copy Module (File Content)
```yaml
- name: Copy a sample file
  copy:
    content: |
      Hostname: {{ ansible_hostname }}
    dest: /opt/ansible-demo/info.txt
    mode: '0644'
```
- Creates files with inline content
- Can also copy files from control node
- Supports template-like variable substitution

### 5. Jinja2 Templating

**Files**:
- [templates/index.html.j2](file:///home/cm/portfolio/3-ansible-docker-demo/templates/index.html.j2)
- [templates/nginx-site.conf.j2](file:///home/cm/portfolio/3-ansible-docker-demo/templates/nginx-site.conf.j2)

**Variable Substitution**:
```jinja2
<h1>Server: {{ ansible_hostname }}</h1>
<p>OS: {{ ansible_distribution }} {{ ansible_distribution_version }}</p>
<p>IP: {{ ansible_default_ipv4.address }}</p>
<p>Deployed: {{ ansible_date_time.iso8601 }}</p>
```

**Key Learning**:
- `{{ variable }}` syntax for variable substitution
- Ansible automatically gathers "facts" about each host
- Templates create unique configurations for each server
- Same template produces different output per host

**Facts Available**:
- `ansible_hostname` - Server hostname
- `ansible_distribution` - OS distribution (Ubuntu)
- `ansible_distribution_version` - OS version (22.04)
- `ansible_default_ipv4.address` - Primary IP address
- `ansible_date_time.iso8601` - Current timestamp

### 6. Idempotency

**Definition**: Running the same playbook multiple times produces the same result without unintended side effects.

**Practical Demonstration**:

**First Run**:
```
TASK [Install nginx] ************************************
changed: [target1]
changed: [target2]
changed: [target3]
```
- Tasks show "changed" (yellow)
- Nginx was installed
- Execution took ~2-3 minutes

**Second Run**:
```
TASK [Install nginx] ************************************
ok: [target1]
ok: [target2]
ok: [target3]
```
- Tasks show "ok" (green)
- Ansible detected nginx already installed
- No changes made
- Execution took ~10-30 seconds

**Why This Matters**:
- Safe to run playbooks repeatedly
- Won't break working systems
- Useful for drift correction (bringing servers back to desired state)
- Much safer than shell scripts that might create duplicates or errors

### 7. Handlers

**Purpose**: Triggered actions that run only when notified and only once at the end of a play.

**Example from playbook.yml**:
```yaml
tasks:
  - name: Create custom nginx configuration
    template:
      src: templates/nginx-site.conf.j2
      dest: /etc/nginx/sites-available/default
    notify: Reload nginx                # Triggers handler if template changes

handlers:
  - name: Reload nginx
    service:
      name: nginx
      state: reloaded                   # Graceful reload, not full restart
```

**Learning Points**:
- Handlers run at the end of the play
- Only run if notified by a task
- Only run once even if notified multiple times
- Efficient service management (no unnecessary restarts)

### 8. Tags

**Usage in Playbook**:
```yaml
tasks:
  - name: Update apt cache
    apt:
      update_cache: yes
    tags: [setup]

  - name: Install nginx
    apt:
      name: nginx
    tags: [nginx]
```

**Selective Execution**:
```bash
# Run only nginx tasks
ansible-playbook playbook.yml --tags nginx

# Run only setup tasks
ansible-playbook playbook.yml --tags setup

# Skip nginx tasks
ansible-playbook playbook.yml --skip-tags nginx
```

**Use Cases**:
- Run only specific parts of a playbook
- Skip time-consuming tasks during development
- Selective updates in production

---

## 🎬 Commands Executed & Results

### Initial Setup

```bash
# Navigate to project
cd /home/cm/portfolio/3-ansible-docker-demo

# Start Docker containers
docker compose up -d --build

# Verify containers running
docker compose ps
```

**Result**: 3 containers running (ansible-target1, target2, target3)

### Ansible Connectivity Testing

```bash
# Test Ansible ping
ansible all -m ping
```

**Result**:
```
target1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
target2 | SUCCESS => ...
target3 | SUCCESS => ...
```

**Learning**: The ping module doesn't use ICMP - it tests Python/SSH connectivity.

### Playbook Execution

```bash
# Run the playbook
ansible-playbook playbook.yml
```

**Result**:
- All 3 servers configured simultaneously
- Nginx installed and started
- Custom HTML pages deployed
- nginx configuration applied
- Services enabled for auto-start

**Execution Summary**:
```
PLAY RECAP *********************************************
target1 : ok=8  changed=7  unreachable=0  failed=0
target2 : ok=8  changed=7  unreachable=0  failed=0
target3 : ok=8  changed=7  unreachable=0  failed=0
```

### Verification

```bash
# Test web servers
curl http://localhost:8081  # target1
curl http://localhost:8082  # target2
curl http://localhost:8083  # target3
```

**Result**: Beautiful HTML pages with server-specific information:
- Each server shows its unique hostname
- OS distribution: Ubuntu 22.04
- IP addresses differ per container
- Deployment timestamps

### Ad-Hoc Commands

```bash
# Check disk space
ansible all -m shell -a "df -h"

# Check memory
ansible all -m shell -a "free -m"

# Check nginx status
ansible all -m shell -a "systemctl status nginx" --become

# View info.txt file
ansible all -m shell -a "cat /opt/ansible-demo/info.txt" --become
```

**Learning**: Ad-hoc commands allow quick one-off tasks without writing playbooks.

---

## 🎓 Production vs Demo Differences

### Security

| Aspect | Demo | Production |
|--------|------|------------|
| Authentication | Passwords (ansible/ansible) | SSH keys |
| Secrets | Plaintext in inventory | Ansible Vault encrypted |
| Host Key Checking | Disabled | Enabled |
| User Privileges | Password-based sudo | Sudoers with NOPASSWD or SSH key forwarding |

### Inventory

| Aspect | Demo | Production |
|--------|------|------------|
| Type | Static (inventory.ini) | Dynamic (AWS, Azure, GCP APIs) |
| Updates | Manual edits | Auto-discovered from cloud |
| Scale | 3 hosts | Hundreds to thousands |
| Grouping | Simple groups | Complex hierarchies |

### Deployment Strategies

| Aspect | Demo | Production |
|--------|------|------------|
| Rollout | All hosts at once | Serial/batched rollouts |
| Testing | Manual verification | Automated testing (Molecule, ansible-lint) |
| Rollback | Manual | Automated rollback on failure |
| Monitoring | None | Integration with monitoring tools |

### Code Organization

| Aspect | Demo | Production |
|--------|------|------------|
| Structure | Single playbook.yml | Roles, collections, multiple playbooks |
| Version Control | Local files | Git with PR reviews |
| Environments | Single | Multiple (dev, staging, prod) |
| Documentation | README | Extensive docs, runbooks |

---

## 💼 Career & Interview Relevance

### Talking Points for Interviews

**When discussing this project**:

> "I built a hands-on Ansible lab using Docker containers to learn configuration management automation. The project demonstrates:
>
> - **Automation at Scale**: Configured 3 servers simultaneously with a single playbook
> - **Idempotency**: Safe to run multiple times - Ansible only changes what needs changing
> - **Infrastructure as Code**: Version-controllable YAML playbooks replace manual documentation
> - **Template-Based Configuration**: Jinja2 templates create host-specific configurations from Ansible facts
> - **Best Practices**: Used handlers for service management, tags for selective execution, and variables for flexibility
>
> While this demo uses Docker containers for learning, I understand production environments use SSH keys instead of passwords, Ansible Vault for secrets, dynamic inventories from cloud APIs, and controlled rollout strategies. This foundation prepared me for the Red Hat Certified Specialist in Ansible Automation certification."

### Industry Applications

**Aerospace/Defense (Target Industry)**:
- Automated security hardening of classified systems
- Consistent configuration across air-gapped environments
- Compliance enforcement (NIST, CIS benchmarks)
- Rapid disaster recovery
- Patch management for critical systems

**Financial Services**:
- Configuration drift detection and correction
- Compliance automation (PCI-DSS, SOX)
- Database and middleware configuration
- Automated security patching
- Multi-datacenter consistency

**Healthcare Technology**:
- HIPAA compliance automation
- EMR system deployment
- Standardized configurations across hospital networks
- Secure PHI data handling
- Disaster recovery automation

**Government (SC Clearance Suitable)**:
- Secure systems management
- Policy enforcement across departments
- Audit trail generation
- Classified system configuration
- Rapid deployment for emergency response

### Relevant Job Roles

This project demonstrates skills for:
- **DevOps Engineer**: Automation, IaC, configuration management
- **SRE (Site Reliability Engineer)**: Service reliability, automated remediation
- **Cloud Engineer**: Multi-cloud automation, infrastructure provisioning
- **Platform Engineer**: Platform standardization, developer tooling
- **Infrastructure Engineer**: Server configuration, deployment automation

---

## 📊 Skills Demonstrated

### Technical Skills

✅ **Ansible Core Competencies**:
- Inventory management (static)
- Playbook development
- Module usage (apt, service, template, file, copy, shell)
- Variable and facts usage
- Jinja2 templating
- Handler implementation
- Tag usage for selective execution
- Ad-hoc command execution

✅ **Infrastructure Skills**:
- Docker containerization
- Docker Compose multi-container orchestration
- SSH configuration and troubleshooting
- Linux system administration (Ubuntu)
- Web server configuration (nginx)

✅ **DevOps Practices**:
- Infrastructure as Code (IaC)
- Configuration management
- Idempotent automation
- Documentation as code

✅ **Troubleshooting**:
- Docker compatibility issues
- Python dependency conflicts
- SSH authentication configuration
- Network port mapping debugging

### Soft Skills

✅ **Problem-Solving**: Diagnosed and resolved 3 technical issues independently
✅ **Learning Agility**: Quickly grasped new concepts through hands-on practice
✅ **Documentation**: Created comprehensive learning notes for future reference
✅ **Systematic Thinking**: Followed structured approach to testing and verification

---

## 🚀 Next Steps for Skill Development

### Immediate Practice (This Week)

1. **Experiment with the Current Setup**:
   - Modify playbook variables and observe changes
   - Add new tasks (install additional packages)
   - Create custom templates
   - Practice with different tags

2. **Try Advanced Features**:
   - Run playbook with verbosity: `ansible-playbook playbook.yml -vv`
   - Limit execution to specific hosts: `--limit target1`
   - Use check mode: `--check`
   - Test different modules from Ansible documentation

3. **Explore Ad-Hoc Commands**:
   - Run the [adhoc-commands.sh](file:///home/cm/portfolio/3-ansible-docker-demo/adhoc-commands.sh) script
   - Create your own ad-hoc command examples
   - Practice with different Ansible modules

### Short-Term Learning (This Month)

1. **Ansible Roles**:
   - Restructure playbook into reusable roles
   - Create roles for nginx, monitoring, security hardening
   - Understand role directory structure and best practices

2. **Ansible Vault**:
   - Encrypt sensitive variables
   - Practice with vault commands
   - Implement proper secrets management

3. **Dynamic Inventories**:
   - Create a Python script for dynamic inventory
   - Practice with inventory plugins
   - Understand cloud-based dynamic inventories

4. **Testing & Quality**:
   - Install and run ansible-lint
   - Learn Molecule for playbook testing
   - Implement CI/CD for Ansible code

### Medium-Term Goals (Next 3 Months)

1. **Red Hat Certified Specialist in Ansible Automation**:
   - Study exam objectives
   - Practice with exam-style scenarios
   - Build additional projects covering all exam topics
   - Schedule and take the exam

2. **Real-World Projects**:
   - Build a multi-tier application deployment (web, app, database)
   - Create security hardening playbooks (CIS benchmarks)
   - Automate Kubernetes cluster setup
   - Implement rolling deployment strategies

3. **Advanced Topics**:
   - Ansible collections and content organization
   - Custom Ansible modules
   - Callback plugins for logging/monitoring
   - Integration with CI/CD pipelines (Jenkins, GitLab)
   - AWX/Ansible Tower (Red Hat Ansible Automation Platform)

### Portfolio Enhancement

1. **Documentation**:
   - Add architecture diagrams to README
   - Create interview talking points document
   - Document common patterns and anti-patterns

2. **GitHub Presentation**:
   - Clean up repository structure
   - Add badges (Ansible version, license)
   - Include screenshots of results
   - Link to related certification study materials

3. **Blog Content**:
   - Write blog post about the learning journey
   - Create tutorial for beginners
   - Document troubleshooting experiences
   - Share on LinkedIn/technical community

---

## 📖 Key Takeaways

### Most Important Concepts

1. **Idempotency is Powerful**: Ansible's idempotent nature means you can run playbooks repeatedly without fear of breaking things. This is a massive advantage over shell scripts.

2. **Declarative > Imperative**: Describing the desired state (declarative) is simpler and more maintainable than specifying steps (imperative).

3. **Facts Are Your Friends**: Ansible automatically gathers detailed information about each host, making it easy to create dynamic, host-specific configurations.

4. **Templates Enable Consistency**: Jinja2 templates allow standardized configurations that adapt to each server's specifics - one template, many unique outputs.

5. **Agentless is Simple**: No agents to install, update, or troubleshoot. Just SSH and Python, which are already everywhere.

### Real-World Value

**Why Ansible Matters for DevOps/SRE Roles**:

- **Scale**: Manage thousands of servers with the same effort as managing one
- **Consistency**: Eliminate configuration drift and "snowflake servers"
- **Speed**: Automate tasks that would take hours/days manually
- **Reliability**: Idempotent operations reduce errors and increase confidence
- **Collaboration**: YAML playbooks are readable by both ops and dev teams
- **Version Control**: Infrastructure configurations tracked like code

**Where This Fits in the DevOps Toolchain**:

```
Development → CI/CD → Configuration Management → Monitoring
              Jenkins   Ansible                    Prometheus
              GitLab    (THIS PROJECT)             Grafana
```

Ansible bridges the gap between code deployment and production operations.

### Personal Insights

**What Worked Well**:
- Hands-on practice solidified theoretical concepts
- Troubleshooting real issues built practical experience
- Docker containers provided safe, isolated learning environment
- Seeing immediate results (web pages) made learning tangible

**Challenges Overcome**:
- Docker Compose version compatibility required investigation
- Understanding port mappings took practical trial and error
- Connecting abstract Ansible concepts to concrete results

**Confidence Gained**:
- Can write basic Ansible playbooks independently
- Understand when to use different modules
- Comfortable troubleshooting Ansible connectivity issues
- Ready to explore more advanced Ansible features

---

## 📚 Additional Resources

### Official Documentation
- [Ansible Documentation](https://docs.ansible.com/)
- [Ansible Module Index](https://docs.ansible.com/ansible/latest/collections/index_module.html)
- [Jinja2 Template Designer Documentation](https://jinja.palletsprojects.com/)

### Red Hat Certification
- [Red Hat Certified Specialist in Ansible Automation](https://www.redhat.com/en/services/training/ex407-red-hat-certified-specialist-in-ansible-automation-exam)
- [Red Hat Ansible Automation Platform](https://www.redhat.com/en/technologies/management/ansible)

### Learning Resources
- [Ansible for DevOps (Jeff Geerling)](https://www.ansiblefordevops.com/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Ansible Galaxy](https://galaxy.ansible.com/) - Community roles and collections

### Related Technologies
- Docker: Container platform used for lab environment
- Kubernetes: Ansible can provision and manage K8s clusters
- Terraform: Complementary tool for infrastructure provisioning
- AWX: Open-source web UI for Ansible (upstream of Ansible Tower)

---

## 📝 Session Metadata

**Environment Details**:
- **OS**: Ubuntu (WSL/Native Linux)
- **Python Version**: 3.12
- **Docker Compose**: v5.0.2 (V2)
- **Ansible Version**: Installed via apt
- **Project Location**: `/home/cm/portfolio/3-ansible-docker-demo`

**Files Modified**:
- [docker-compose.yml](file:///home/cm/portfolio/3-ansible-docker-demo/docker-compose.yml) - Added nginx port mappings (8081:80, 8082:80, 8083:80)

**Packages Installed**:
- `sshpass` - SSH password authentication for Ansible

**Commands Successfully Executed**:
- ✅ `docker compose up -d --build`
- ✅ `docker compose ps`
- ✅ `ansible all -m ping`
- ✅ `ansible-playbook playbook.yml`
- ✅ `curl http://localhost:8081` (and 8082, 8083)
- ✅ Various ad-hoc Ansible commands

**Verification**:
- ✅ All 3 containers running and accessible
- ✅ Ansible connectivity working
- ✅ Nginx installed and serving custom pages
- ✅ Idempotency demonstrated
- ✅ Templates rendering correctly with host-specific data

---

## 🎯 Certification Exam Topic Coverage

### Red Hat Certified Specialist in Ansible Automation (EX407)

**Topics Covered in This Project**:

✅ **Understand core components of Ansible**
- Inventories ✅
- Modules ✅
- Variables ✅
- Facts ✅
- Plays ✅
- Playbooks ✅
- Configuration files ✅

✅ **Run ad-hoc Ansible commands**
- Used shell, ping, and other modules via ad-hoc commands ✅

✅ **Use static inventories to define groups of hosts**
- Created [webservers] group with 3 hosts ✅
- Used group variables ✅

✅ **Create Ansible plays and playbooks**
- Written and executed complete playbook ✅
- Multiple tasks and handlers ✅

✅ **Work with commonly used Ansible modules**
- apt ✅
- service ✅
- template ✅
- file ✅
- copy ✅
- shell ✅

✅ **Use conditionals to control play execution**
- Handlers with notify conditions ✅

✅ **Configure error handling**
- Understanding of changed/ok/failed states ✅

✅ **Create playbooks to configure systems to a specified state**
- Nginx installation and configuration ✅
- Service management ✅

✅ **Use Ansible modules for system administration tasks**
- Package installation ✅
- Service management ✅
- File operations ✅

✅ **Work with Ansible templates**
- Jinja2 templates for HTML and nginx config ✅
- Variable substitution ✅
- Ansible facts usage ✅

✅ **Work with Ansible variables and facts**
- Playbook variables (vars:) ✅
- Ansible facts (ansible_hostname, etc.) ✅

**Topics NOT Yet Covered** (Future Learning):
- ⏳ Ansible roles
- ⏳ Ansible Vault
- ⏳ Dynamic inventories
- ⏳ Conditionals (when:)
- ⏳ Loops (loop:, with_items:)
- ⏳ Error handling (block/rescue/always)
- ⏳ Ansible Galaxy
- ⏳ Custom modules

---

**Document Status**: ✅ Complete
**Review Date**: February 4, 2026
**Next Review**: After completing additional Ansible experiments and role-based projects

---

*This document serves as both a learning record and interview preparation material for DevOps/SRE roles in aerospace, defense, financial services, and healthcare technology industries.*
