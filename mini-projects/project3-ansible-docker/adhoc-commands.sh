#!/bin/bash
# Ansible Ad-Hoc Commands Examples
# These demonstrate quick one-off tasks without writing a playbook

echo "=== Ansible Ad-Hoc Commands Demo ==="
echo ""

echo "1. Ping all hosts:"
ansible all -m ping
echo ""

echo "2. Check disk space on all hosts:"
ansible all -m shell -a "df -h"
echo ""

echo "3. Get system information:"
ansible all -m setup -a "filter=ansible_distribution*"
echo ""

echo "4. Check uptime:"
ansible all -m command -a "uptime"
echo ""

echo "5. List files in /opt:"
ansible all -m command -a "ls -la /opt"
echo ""

echo "6. Install a package (htop):"
ansible webservers -m apt -a "name=htop state=present" --become
echo ""

echo "7. Create a file:"
ansible all -m file -a "path=/tmp/ansible-test state=touch mode=0644"
echo ""

echo "8. Check nginx status:"
ansible webservers -m service -a "name=nginx state=started" --become
echo ""
