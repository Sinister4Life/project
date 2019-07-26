#!/bin/bash

#Just to make sure Elementa Finitia is roothhh
runas=`id | awk -F '(' '{print $1}' | awk -F '=' '{print $2}'`
if [ $runas -ne 0 ]; then 
echo "$PROG: sorry dawg yall aint root" >> ${LOGFILE} 2>&1
exit 1
fi

#Installing basic packages for DHCP services
sudo yum install -y dhcp syslinux xinetd sshpass

#Transforming Skeihjar DHCP energy into Dologruin Ansibleou automatique by Samwiseoul Ganjaoil
s=subnet;
rr=range;
odns=option domain-name-servers;
odn=option domain-name;
or=option routers;
oba=option broadcast-address;
dlt=default-lease-t*;
mlt=max-lease-t*;
dcfg_path=/etc/dhcp/dhcpd.conf;
f=filename;
fa=fixed-address;
h=host;
sa=server-name;
hw=hardware*;
c=class;
m=match;
p=pool;
a=allow*;
d=deny*;
shn=shared-network;

sed -i "/^$p/c#$p/^$a/c#$a/^$d/c#$d/^$shn/c#$shn/^$m/c#$m/^$c/c#$c/^$hw/c#$hw/^$sa/c#$sa/^$h/c#$h/^}/c#}/^$f/c#$f/^$fa/$fa/^/^$s/c#$s;/^$rr/c#$rr;/^$odns/c#$odns;/^$or/c#$or;/^$oba/c#$oba;/^$dlt/c#$dlt;/^$mlt/c#$mlt" $dcfg_path;
cat << EOF >> $dcfg_path
#DHCP Server Configuration file.
ddns-update-style interim;
ignore client-updates;
authoritative;
allow booting;
allow bootp;
allow unknown-clients;

# option definitions common to all supported networks...
option domain-name "ziyotek5.local";
option domain-name-servers prdx-nsmaster15, prdx-nsworker15, prdx-nsworker25;
default-lease-time 3600;
max-lease-time 7200;
authoritative;

#internal subnet for my DHCP Server
subnet 192.168.45.0 netmask 255.255.248.0 {
range 192.168.45.20 192.168.45.239;
option domain-name-servers 192.168.45.12;
option domain-name "ziyotek5.local";
option routers 192.168.40.1;
range 192.168.45.20 192.168.45.239;
option broadcast-address 192.168.45.239;
default-lease-time 600;
max-lease-time 7200;
}

#IP of PXE Server
next-server 192.168.45.150;
filename "pxelinux.0";
}
EOF

echo "DHCPDARGS=ens192" >> /etc/sysconfig/dhcpd

exit 0;
