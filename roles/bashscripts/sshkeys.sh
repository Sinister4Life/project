
#!/bin/bash

# This script is meant to be run on the ansible server,
# for copying its SSH key to all the other servers it manages.

# Switch to ansible user and create key

sudo -i -u ansible bash << EOF
yes y | ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa >/dev/null
EOF

# Add to this list as we add more servers
SERVERS=( 192.168.45.10 192.168.45.11
          192.168.45.12 192.168.45.13
          192.168.45.14 192.168.45.151
          192.168.45.150 192.168.45.18
          192.168.45.19 192.168.45.20
          192.168.45.21 192.168.45.22
          192.168.45.23 192.168.45.24
          192.168.45.25 192.168.45.26
          192.168.45.27 192.168.45.28
          192.168.45.29 192.168.45.30
          192.168.45.31 192.168.45.32
          192.168.45.33 192.168.45.34
	  192.168.45.35 192.168.45.36
          192.168.45.37	192.168.45.230
          192.168.45.16
)

for ip in "${SERVERS[@]}" ;
do
    sshpass -p password ssh-copy-id -i ~/.ssh/id_rsa.pub ansible@$ip
done


