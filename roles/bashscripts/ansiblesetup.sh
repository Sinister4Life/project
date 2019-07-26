#!/bin/bash

sudo useradd -p $(openssl passwd password) ansible
sudo echo "ansible ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
# Generate ssh keys for ansible
sudo -i -u ansible bash << EOF
yes y | ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa >/dev/null
EOF

