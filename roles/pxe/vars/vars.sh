#!/bin/bash

sudo openssl passwd -1 password > pvar << EOF
pvar=$pvar;
cos7cfg_path=/var/ftp/pub/centos7.cfg;
dhcpdcfg_path=/etc/dhcp/dhcpd.conf;
tftpcfg_path=/etc/xinetd.d/tftp;
ftp_path=/var/ftp/pub/;
firewall_script=/ansible/roles/pxe/vars/firewall.sh
EOF
