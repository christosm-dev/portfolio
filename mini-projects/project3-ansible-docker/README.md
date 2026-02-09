# Project 3: Ansible - Configure Docker Containers

> Automate multi-container configuration management with Ansible. **[View source on GitHub](https://github.com/christosm-dev/portfolio/tree/main/mini-projects/project3-ansible-docker)**

## Project Overview

This project demonstrates Ansible fundamentals by automating the configuration of multiple Docker containers acting as remote hosts. Three Ubuntu containers running SSH are provisioned with Docker Compose, then Ansible configures all three simultaneously - installing NGINX, deploying Jinja2-templated web pages, and managing services. The project showcases idempotent automation, inventory management, and configuration-as-code practices.

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
