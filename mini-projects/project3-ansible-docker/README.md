# Project 3: Ansible - Configure Docker Containers

> Automate multi-container configuration management with Ansible. **[View source on GitHub](https://github.com/christosm-dev/portfolio/tree/main/mini-projects/project3-ansible-docker)**

## Project Overview

This project demonstrates Ansible fundamentals by automating the configuration of multiple Docker containers acting as remote hosts. Three Ubuntu containers running SSH are provisioned with Docker Compose, then Ansible configures all three simultaneously - installing NGINX, deploying Jinja2-templated web pages, and managing services. The project showcases idempotent automation, inventory management, and configuration-as-code practices.

```
┌────────────────────────────────────────────────────────┐
│                     Local Machine                      │
│                                                        │
│  ansible-playbook playbook.yml                         │
│            │                                           │
│            │  SSH (ports 2221 / 2222 / 2223)           │
│      ┌─────┼─────────────┐                             │
│      ▼     ▼             ▼                             │
│  ┌────────┐ ┌────────┐ ┌────────┐                     │
│  │target1 │ │target2 │ │target3 │  ← Ubuntu + SSH     │
│  │ :2221  │ │ :2222  │ │ :2223  │                     │
│  │ NGINX  │ │ NGINX  │ │ NGINX  │  ← Ansible deploys  │
│  └────────┘ └────────┘ └────────┘                     │
│                                                        │
│  Docker Compose provisions all three containers        │
│  Ansible inventory maps each to a host group           │
└────────────────────────────────────────────────────────┘
```

## Technology Stack

| Technology | Role |
|------------|------|
| Ansible | Agentless configuration management and automation |
| Docker / Docker Compose | Target containers simulating remote hosts |
| SSH | Transport layer for Ansible to managed hosts |
| Jinja2 | Templating engine for dynamic configuration files |
| NGINX | Web server deployed and configured by playbooks |
| YAML | Playbook and inventory format |

## Key Features

- Agentless automation over SSH to three simultaneous targets
- Idempotent playbook design (safe to re-run without side effects)
- Jinja2 templates for host-specific dynamic content generation
- Handlers for conditional service restarts on configuration changes
- Inventory groups and host/group variables
- Ad-hoc command support for one-off tasks

## Codebase Overview

```
project3-ansible-docker/
├── target/
│   └── Dockerfile          # Ubuntu image with SSH server and Python (Ansible requirement)
├── templates/
│   ├── index.html.j2       # Jinja2 template: custom web page with host variables
│   └── nginx-site.conf.j2  # Jinja2 template: NGINX virtual host configuration
├── docker-compose.yml      # Defines 3 target containers with SSH port mappings (2221-2223)
├── inventory.ini           # Ansible inventory: host groups, connection params, variables
├── ansible.cfg             # Project-level Ansible settings (inventory path, SSH options)
├── playbook.yml            # Main playbook: apt update, NGINX install, template deploy, handlers
├── adhoc-commands.sh       # Example ad-hoc commands for quick tasks
├── .gitignore
└── README.md               # This file
```

## Quick Start

### Prerequisites

```bash
docker compose version   # must be v2.x
ansible --version        # must be v2.x
```

### Start the target containers

```bash
cd mini-projects/project3-ansible-docker

# Bring up three Ubuntu+SSH containers as Ansible targets
docker compose up -d

# Wait a few seconds for the SSH daemon to start in each container
sleep 3
```

### Verify Ansible connectivity

```bash
# Ping all hosts — expect 'pong' from all three
ansible all -m ping
```

### Run the playbook

```bash
ansible-playbook playbook.yml
```

Ansible installs NGINX, renders Jinja2 templates with host-specific variables, and restarts the service on each target. The output shows each task's status (ok / changed) per host.

### Verify the result

```bash
# Each target serves a custom NGINX page on its own port
curl http://localhost:8081   # target1
curl http://localhost:8082   # target2
curl http://localhost:8083   # target3
```

Each response includes the hostname and a message generated from the Jinja2 template.

### Re-run for idempotency

```bash
# Running again should show all tasks as 'ok' (no changes) —
# this demonstrates Ansible's idempotent design
ansible-playbook playbook.yml
```

### Tear down

```bash
docker compose down
```

## Future Work

- [ ] Refactor playbook into Ansible roles for reusability
- [ ] Add Ansible Vault for secret management (e.g. SSL certificates)
- [ ] Implement a multi-stage deployment: staging then production
- [ ] Add molecule testing for playbook validation
- [ ] Create a dynamic inventory plugin for Docker containers
- [ ] Add monitoring checks (e.g. verify nginx response after deployment)

## Resources

- [Ansible Official Documentation](https://docs.ansible.com/)
- [Ansible Galaxy](https://galaxy.ansible.com/)
- [Ansible Module Index](https://docs.ansible.com/ansible/latest/collections/index_module.html)
- [Jinja2 Template Designer](https://jinja.palletsprojects.com/)
- [Red Hat Ansible Training](https://www.ansible.com/products/training-certification)
