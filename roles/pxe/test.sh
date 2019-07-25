#!/bin/bash

sudo openssl passwd -1 password >> passgen;
sudo var=passgen;
sudo cat << EOF > centos7.cfg
# Root password
rootpw --iscrypted $var

# System authorization information
auth useshadow passalgo=sha512
EOF
