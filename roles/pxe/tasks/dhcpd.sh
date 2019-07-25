#!/bin/bash


#Performing clean up of any actions and exit with successful return status
clean_exit()
{
cd /
test -f "$tmpfile" && rm $tmpfile
exit $1
}

#Just to make sure dawg is da root
runas=`id | awk -F '(' '{print $1}' | awk -F '=' '{print $2}'`
if [ $runas -ne 0 ]; then 
echo "$PROG: sorry dawg yall aint root" >> ${LOGFILE} 2>&1
exit 1
fi

sudo yum install -y sshpass;

#Transforming Skellig DHCP energy into Dologruin transfitia automata
s=subnet;
rr=range;
odns=option domain-name-servers;
odn=option domain-name;
or=option routers;
oba=option broadcast-address;
dlt=default-lease-t*;
mlt=max-lease-t*;
dcfg_path=/etc/dhcp/dhcpd.conf;

sed -i "/^$s/c#$s/g;/^$rr/c#$rr/g;/^$odns/c#$odns/g;/^$or/c#$or/g;/^$oba/c#$oba/g;/^$dlt/c#$dlt/g;/^$mlt/c#$mlt/g" $dcfg_path;
cat << EOF >> $dcfg_path
#DHCP Server Configuration file.
ddns-update-style interim;
ignore client-updates;
authoritative;
allow booting;
allow bootp;
allow unknown-clients;

#internal subnet for my DHCP Server
subnet 192.168.40.0 netmask 255.255.248.0 {
range 192.168.45.11 192.168.45.239;
option domain-name-servers 192.168.45.12;
option domain-name "ziyotek5.local";
option routers 192.168.40.1;
option broadcast-address 192.168.40.255;
default-lease-time 600;
max-lease-time 7200;

# IP of PXE Server
next-server 192.168.45.15;
filename "pxelinux.0";
}
EOF

echo "DHCPDARGS=ens192" >> /etc/sysconfig/dhcpd
sudo sed -i 's/no/yes' /etc/xinetd.d/tftp;
sudo cp -vp /usr/share/syslinux/{pxelinux.0,menu.c32,memdisk,mboot.c32,chain.c32} /var/lib/tftpboot;
sudo mkdir /var/lib/tftpboot/pxelinux.0 && sudo mkdir /var/lib/tftpboot/networkboot;
sudo mount -o loop ftp://192.168.45.17/pub/CentOS7/CentOS-7-x86_64-DVD-1810.iso /mnt/;
sudo umount /mnt/;
sudo openssl passwd -1 password >> passgen;
sudo var=passgen;
sudo cat << EOF > centos7.cfg
#version=DEVEL

#Firewall configuration
firewall --disabled

# Install OS instead of upgrade install
install 

# Use FTP installation media
url --url="ftp://192.168.45.17/pub/CentOS7/"

# Root password
rootpw --iscrypted $var

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

clean_exit
