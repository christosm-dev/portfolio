# Project 3: Ansible - Configure Docker Containers

**Project Series:** 3 of 7  
**Difficulty:** Beginner  
**Technologies:** Ansible, Docker, SSH  
**Goal:** Learn Ansible fundamentals by automating container configuration

---

## 📋 Project Overview

This is the third project in a series of 7 designed to build expertise in infrastructure automation tools. This project introduces **Ansible**, a powerful automation platform for configuration management, application deployment, and task automation. You'll learn how to use Ansible to configure multiple Docker containers acting as remote hosts.

### What You'll Learn

- **Ansible Basics:** Inventory, playbooks, modules, tasks
- **Configuration Management:** Automating system setup
- **Idempotency:** Safe, repeatable automation
- **Templates:** Jinja2 templating for dynamic configuration
- **Handlers:** Triggered actions based on changes
- **Ad-Hoc Commands:** Quick one-off tasks
- **Variables:** Making playbooks flexible
- **SSH Connection Management:** Remote host communication

---

## 🎯 Certification Path Context

This project supports preparation for:
- **Red Hat Certified Specialist in Ansible Automation**

Skills practiced:
- Writing and executing Ansible playbooks
- Managing inventories
- Using core Ansible modules
- Working with templates and variables
- Understanding idempotency
- Implementing handlers for service management

---

## 🏗️ What This Project Does

This project:
1. Spins up 3 Docker containers as Ansible targets
2. Uses Ansible to configure all 3 containers simultaneously
3. Installs and configures nginx web server
4. Deploys custom HTML pages using Jinja2 templates
5. Manages services and system configuration
6. Demonstrates idempotent automation

**End Result:** Three configured web servers, each displaying a custom page with server information, all managed through Ansible automation.

---

## 📁 Project Structure

```
ansible-docker-demo/
├── target/
│   └── Dockerfile          # Docker image for target containers
├── templates/
│   ├── index.html.j2       # Jinja2 template for web page
│   └── nginx-site.conf.j2  # Jinja2 template for nginx config
├── docker-compose.yml      # Defines 3 target containers
├── inventory.ini           # Ansible inventory file
├── ansible.cfg             # Ansible configuration
├── playbook.yml            # Main Ansible playbook
├── adhoc-commands.sh       # Example ad-hoc commands
├── .gitignore
└── README.md               # This file
```

### File Explanations

**target/Dockerfile**
- Creates Ubuntu containers with SSH enabled
- Installs Python (required by Ansible)
- Sets up ansible user with sudo privileges

**docker-compose.yml**
- Defines 3 target containers (target1, target2, target3)
- Maps SSH ports (2221, 2222, 2223)
- Creates isolated network

**inventory.ini**
- Lists hosts Ansible will manage
- Defines connection parameters (user, password, port)
- Groups hosts (webservers)
- Sets variables

**ansible.cfg**
- Project-specific Ansible settings
- Points to inventory file
- Disables host key checking (for demo)

**playbook.yml**
- Main automation script
- Defines tasks to execute on hosts
- Uses variables, templates, and handlers

**templates/*.j2**
- Jinja2 templates for dynamic file generation
- Variables replaced at runtime
- Creates customized content per host

---

## 🚀 Prerequisites

Before starting, ensure you have:

1. **Docker & Docker Compose**
   ```bash
   docker --version
   docker-compose --version
   ```

2. **Ansible** - Configuration management tool
   ```bash
   ansible --version
   ```
   
   Installation (if needed):
   ```bash
   # Ubuntu/Debian/WSL
   sudo apt update
   sudo apt install ansible -y
   
   # Or via pip
   pip3 install ansible --break-system-packages
   ```

---

## 📖 Step-by-Step Instructions

### Step 1: Start the Target Containers

Build and start the 3 target containers:

```bash
docker-compose up -d --build
```

**What happens:**
- Builds Ubuntu image with SSH
- Starts 3 containers (target1, target2, target3)
- Maps SSH ports to 2221, 2222, 2223

Verify containers are running:
```bash
docker-compose ps
```

You should see 3 containers running.

### Step 2: Test Connectivity

Verify Ansible can reach the hosts:

```bash
ansible all -m ping
```

**Expected output:**
```
target1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
target2 | SUCCESS => ...
target3 | SUCCESS => ...
```

If you see GREEN "SUCCESS", connectivity is working!

### Step 3: Gather Host Information

Get facts about your hosts:

```bash
ansible all -m setup -a "filter=ansible_distribution*"
```

This shows you what Ansible knows about each host.

### Step 4: Run the Playbook (Dry Run)

Check what the playbook will do without making changes:

```bash
ansible-playbook playbook.yml --check
```

**What happens:**
- Ansible simulates the playbook execution
- Shows what would change
- No actual changes are made

### Step 5: Run the Playbook

Execute the playbook:

```bash
ansible-playbook playbook.yml
```

**What happens:**
- Updates apt cache on all hosts
- Installs nginx
- Creates custom HTML pages
- Configures nginx
- Starts nginx service
- Creates directories and files

Watch the colored output showing task progress!

### Step 6: Verify the Results

Access the web servers:

```bash
# target1
curl http://localhost:2221

# target2  
curl http://localhost:2222

# target3
curl http://localhost:2223
```

Or open in browser:
- http://localhost:2221
- http://localhost:2222
- http://localhost:2223

Each should show a custom page with that server's information!

### Step 7: Demonstrate Idempotency

Run the playbook again:

```bash
ansible-playbook playbook.yml
```

**What to observe:**
- Most tasks show "ok" (green) instead of "changed" (yellow)
- Ansible detects nothing needs changing
- This is **idempotency** - safe to run multiple times

### Step 8: Try Ad-Hoc Commands

Execute one-off tasks without a playbook:

```bash
# Check disk space
ansible all -m shell -a "df -h"

# Check memory
ansible all -m shell -a "free -m"

# Install a package
ansible webservers -m apt -a "name=htop state=present" --become

# Restart nginx
ansible webservers -m service -a "name=nginx state=restarted" --become
```

Or run the example script:
```bash
chmod +x adhoc-commands.sh
./adhoc-commands.sh
```

### Step 9: SSH into a Container

For manual inspection:

```bash
# SSH into target1
ssh -p 2221 ansible@localhost
# Password: ansible

# Once inside
systemctl status nginx
cat /var/www/html/index.html
cat /opt/ansible-demo/info.txt

# Exit
exit
```

### Step 10: Clean Up

Stop and remove containers:

```bash
docker-compose down
```

Or stop without removing:
```bash
docker-compose stop
```

---

## 🔍 Understanding Ansible Concepts

### What is Ansible?

Ansible is an **agentless** automation tool. Key features:
- **Agentless** - No software to install on managed hosts (just SSH + Python)
- **Declarative** - Describe desired state, not steps to get there
- **Idempotent** - Safe to run repeatedly
- **Simple** - Uses YAML, easy to read and write
- **Powerful** - Can manage thousands of hosts

### Inventory

The **inventory** defines which hosts Ansible manages:

```ini
[webservers]
target1 ansible_host=localhost ansible_port=2221
target2 ansible_host=localhost ansible_port=2222

[webservers:vars]
ansible_user=ansible
ansible_password=ansible
```

- **Groups** - `[webservers]` groups related hosts
- **Host variables** - Connection details per host
- **Group variables** - Variables shared by group members

### Playbooks

A **playbook** is a YAML file describing automation tasks:

```yaml
---
- name: Configure Web Servers
  hosts: webservers
  become: yes
  
  tasks:
    - name: Install nginx
      apt:
        name: nginx
        state: present
```

**Structure:**
- **Play** - Top-level grouping targeting hosts
- **Tasks** - Individual actions to perform
- **Modules** - Reusable units of work (apt, copy, service, etc.)

### Modules

**Modules** are Ansible's tools for getting work done. Common modules:

- **apt** - Manage packages on Debian/Ubuntu
- **yum** - Manage packages on RedHat/CentOS
- **copy** - Copy files to hosts
- **template** - Deploy Jinja2 templates
- **file** - Manage files and directories
- **service** - Manage system services
- **user** - Manage user accounts
- **command** / **shell** - Run commands

Each module is idempotent by design.

### Idempotency

**Idempotency** means running the same operation multiple times produces the same result:

```yaml
- name: Ensure nginx is installed
  apt:
    name: nginx
    state: present
```

- First run: Installs nginx (changed=true)
- Second run: Already installed (changed=false)
- Safe to run anytime!

### Variables

**Variables** make playbooks flexible:

```yaml
vars:
  nginx_port: 80
  site_name: "My Site"

tasks:
  - name: Create index page
    template:
      src: index.html.j2
      dest: /var/www/html/index.html
```

Variables can come from:
- Playbook vars section
- Inventory file
- Command line (-e key=value)
- Variable files
- Ansible facts

### Templates (Jinja2)

**Templates** generate files dynamically using variables:

```jinja2
<h1>{{ site_name }}</h1>
<p>Running on {{ ansible_hostname }}</p>
<p>IP: {{ ansible_default_ipv4.address }}</p>
```

At runtime, Ansible replaces `{{ variables }}` with actual values.

### Handlers

**Handlers** are tasks triggered by changes:

```yaml
tasks:
  - name: Update nginx config
    template:
      src: nginx.conf.j2
      dest: /etc/nginx/nginx.conf
    notify: Reload nginx

handlers:
  - name: Reload nginx
    service:
      name: nginx
      state: reloaded
```

Handlers run once at the end, even if triggered multiple times.

### Facts

**Facts** are system information Ansible gathers automatically:

- `ansible_hostname` - Host name
- `ansible_distribution` - OS name
- `ansible_default_ipv4.address` - IP address
- `ansible_memory_mb` - RAM
- `ansible_processor_cores` - CPU cores

Access with: `ansible all -m setup`

---

## 🧪 Experiments to Try

### Experiment 1: Modify the Web Page

Edit `templates/index.html.j2` to change the page design or content.

Run the playbook:
```bash
ansible-playbook playbook.yml
```

Refresh your browser - changes appear on all 3 servers!

### Experiment 2: Add a New Task

Add a task to the playbook to install another package:

```yaml
- name: Install htop
  apt:
    name: htop
    state: present
  tags: [packages]
```

Run with specific tags:
```bash
ansible-playbook playbook.yml --tags packages
```

### Experiment 3: Use Variables

Create a variables file `vars.yml`:

```yaml
nginx_port: 8080
site_name: "Custom Site Name"
custom_message: "Hello from Ansible!"
```

Include it in your playbook:

```yaml
vars_files:
  - vars.yml
```

### Experiment 4: Target Specific Hosts

Run playbook on just one host:

```bash
ansible-playbook playbook.yml --limit target1
```

Or exclude hosts:
```bash
ansible-playbook playbook.yml --limit 'all:!target3'
```

### Experiment 5: Dry Run with Diff

See what would change:

```bash
ansible-playbook playbook.yml --check --diff
```

Shows file differences before applying.

### Experiment 6: Increase Verbosity

See more details:

```bash
ansible-playbook playbook.yml -v    # verbose
ansible-playbook playbook.yml -vv   # more verbose
ansible-playbook playbook.yml -vvv  # very verbose
ansible-playbook playbook.yml -vvvv # connection debugging
```

### Experiment 7: Create a New Playbook

Create `update-system.yml`:

```yaml
---
- name: Update System Packages
  hosts: all
  become: yes
  
  tasks:
    - name: Update all packages
      apt:
        upgrade: dist
        update_cache: yes
        cache_valid_time: 3600
    
    - name: Remove unused packages
      apt:
        autoremove: yes
    
    - name: Check if reboot required
      stat:
        path: /var/run/reboot-required
      register: reboot_required
    
    - name: Display reboot status
      debug:
        msg: "Reboot is {{ 'required' if reboot_required.stat.exists else 'not required' }}"
```

Run it:
```bash
ansible-playbook update-system.yml
```

---

## 🐛 Common Issues & Solutions

### Issue: "Failed to connect to the host via ssh"
**Cause:** Containers not running or SSH not ready  
**Solution:**
- Check containers: `docker-compose ps`
- Wait 10 seconds after starting containers
- Restart: `docker-compose restart`

### Issue: "Permission denied"
**Cause:** Wrong credentials or sudo issues  
**Solution:**
- Verify inventory credentials match Dockerfile
- Check `ansible_become=yes` is set
- SSH manually to test: `ssh -p 2221 ansible@localhost`

### Issue: "Module not found" or "No module named 'apt'"
**Cause:** Missing Python modules in container  
**Solution:**
- Rebuild containers: `docker-compose up -d --build`
- Verify Python is installed in containers

### Issue: Tasks showing "changed" every run
**Cause:** Non-idempotent task or incorrect module usage  
**Solution:**
- Use `state: present` instead of raw commands
- Check module documentation for idempotent options
- Use `template` instead of `copy` for dynamic files

### Issue: "Host key verification failed"
**Cause:** SSH strict host key checking  
**Solution:**
- Already disabled in ansible.cfg
- Or add to ~/.ssh/config:
```
Host localhost
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
```

---

## 📝 Key Commands Reference

```bash
# Inventory & Connection
ansible all --list-hosts          # List all hosts
ansible webservers --list-hosts   # List hosts in group
ansible all -m ping               # Test connectivity

# Ad-Hoc Commands
ansible all -m command -a "uptime"
ansible all -m shell -a "df -h"
ansible all -m setup              # Gather facts
ansible all -m apt -a "name=htop state=present" --become

# Playbook Execution
ansible-playbook playbook.yml                    # Run playbook
ansible-playbook playbook.yml --check            # Dry run
ansible-playbook playbook.yml --check --diff     # Show changes
ansible-playbook playbook.yml --limit target1    # Run on specific host
ansible-playbook playbook.yml --tags nginx       # Run specific tags
ansible-playbook playbook.yml -v                 # Verbose output

# Docker Management
docker-compose up -d              # Start containers
docker-compose ps                 # Check status
docker-compose logs               # View logs
docker-compose restart            # Restart containers
docker-compose down               # Stop and remove

# Debugging
ansible-playbook playbook.yml -vvv               # Very verbose
ansible all -m setup -a "filter=ansible_*"       # Show specific facts
ansible-doc apt                                  # Module documentation
```

---

## ✅ Key Concepts Learned

After completing this project, you should understand:

✅ **Ansible Architecture** - Agentless automation via SSH  
✅ **Inventory Management** - Defining and grouping hosts  
✅ **Playbook Structure** - Plays, tasks, modules  
✅ **Idempotency** - Safe, repeatable automation  
✅ **Variables** - Making playbooks flexible  
✅ **Templates** - Dynamic file generation with Jinja2  
✅ **Handlers** - Triggered actions on changes  
✅ **Modules** - Using apt, service, copy, template, etc.  
✅ **Facts** - Automatic system information gathering  
✅ **Ad-Hoc Commands** - Quick one-off tasks

---

## ➡️ Next Steps

After mastering this project:

1. **Experiment** with the variations above
2. **Write custom playbooks** for different scenarios
3. **Learn Ansible Vault** for managing secrets
4. **Explore Ansible Galaxy** for pre-built roles
5. **Move to Project 4:** Combined Terraform + Kubernetes
6. **Study:** Ansible documentation and best practices

---

## 📝 Notes for Portfolio

When adding this to your portfolio or GitHub:
- Document what you automated
- Show before/after configurations
- Explain idempotency benefits
- Include screenshots of playbook runs
- Demonstrate understanding of Ansible concepts

---

## 🔗 Resources

- [Ansible Official Documentation](https://docs.ansible.com/)
- [Ansible Galaxy](https://galaxy.ansible.com/) - Pre-built roles
- [Ansible Module Index](https://docs.ansible.com/ansible/latest/collections/index_module.html)
- [Jinja2 Template Designer](https://jinja.palletsprojects.com/)
- [Red Hat Ansible Training](https://www.ansible.com/products/training-certification)

---

**Project Status:** Ready to begin  
**Estimated Time:** 1-2 hours  
**Previous Project:** Kubernetes + Minikube  
**Next Project:** Terraform + Kubernetes integration
