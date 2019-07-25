#!/bin/bash

#Dancing with the Wolves woooo-woooo-wooo skadooshhh
setenforce 0;
yum install -y tftp tftp-server syslinux vsftpd xinetd;
sed -i 's/no/yes' /etc/xinetd.d/tftp;
cp -vp /usr/share/syslinux/{pxelinux.0,menu.c32,memdisk,mboot.c32,chain.c32} /var/lib/tftpboot;
mkdir -p /var/lib/tftpboot/pxelinux.0 && mkdir -p /var/lib/tftpboot/networkboot;
mount -o loop ftp://192.168.45.17/pub/CentOS7/CentOS-7-x86_64-DVD-1810.iso /mnt/;
cp -av /mnt/* /var/ftp/pub/;
umount /mnt/;

openssl passwd -1 password > passgen;
cat << EOF > centos7.cfg
#version=DEVEL

#Firewall configuration
firewall --disabled

# Install OS instead of upgrade install
install

# Use FTP installation media
url --url="ftp://192.168.45.17/pub/CentOS7/"

# Root password
rootpw --iscrypted `cat passgen`

# System authorization information
auth useshadow passalgo=sha512

# Use graphical install graphical
firstboot disable

#System keyboard
keyboard us

#System language
lang en_US

#SELinux configuration
selinux disabled

#Installation logging level
logging level=info

#System timezone
timezone "America/New_York"

#System bootloader configuration
bootloader location=mbr
clearpart --all --initlabel
autopart --type=lvm

#System Services
services --enabled="chronyd"

#Packages to install
%packages
@^minimal
@core
chrony
wget
ntp
mlocate
bind-utils
sysstat
man
man-pages
%end

%addon com_redhat_kdump --disable --reserve-mb='auto'
%end
EOF

sshpass -p password scp -r centos7.cfg root@192.168.45.17:/var/ftp/pub/CentOS7/;

cat << EOF > /var/lib/tftpboot/pxelinux.cfg/default
default menu.c32
prompt 0
timeout 30
MENU TITLE ######## PXE Menu #########
LABEL 1
MENU LABEL ^1) Install CentOS 7
KERNEL /networkboot/vmlinuz
APPEND initrd=/networkboot/initrd.img inst.repo=ftp://192.168.45.17/pub/CentOS7/ ks=ftp://192.168.45.17/pub/CentOS7/centos7.cfg
EOF

systemctl status firewalld | grep -i active | awk '{print $2;}' > status;
stat=status
if [ "$stat" == "active" ]; then
  sudo systemctl start xinetd && sudo systemctl start dhcpd && sudo systemctl start vsftpd && sudo systemctl enable xinetd && sudo systemctl enable dhcpd && sudo systemctl enable vsftpd;
elif [ "$stat" == "inactive" ]; then
  echo "firewalld is not rinning";
else
  echo "firewall doesn't need to be configured";
fi

exit 0;
