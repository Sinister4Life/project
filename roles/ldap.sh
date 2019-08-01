#!/bin/bash
setenforce 0
systemctl stop firewalld
systemctl disable firewalld
yum install -y openldap openldap-clients openldap-servers openssl

cat << EOF > slapps.sh
#!/usr/sbin/slappasswd -s
expect_user -re "(\[^ \]+) (\[^ \]+)\n"
set user $expect_out(1,string)
set pw   $expect_out(2,string)
spawn slappasswd $user
expect "password:"
send "$pw\r"
expect "password:"
send "$pw\r"
expect eof
EOF
chmod +x slapps.sh
./slapps.sh > slaps

cat << EOF > hdb.ldif
dn: olcDatabase={2}hdb,cn=config
changeType: modify
replace: olcSuffix
olcSuffix: dc=ziyotek5,dc=local
-
replace: olcRootDN
olcRootDN: cn=admin,dc=ziyotek5,dc=local
-
add: olcRootPW
olcRootPW: `cat $slaps`
EOF

ldapmodify -Y EXTERNAL -H ldapi:/// -f hdb.ldif

#LDAP GUI Installation/Configuration
yum install -y epel-release phpldapadmin httpd
phpath=/etc/phpldapadmin/config.php
grep "\$servers->setValue('server','base',array(''))" $phpath | sed 's/\/\///' | sed "s/array('')/array('dc=ziyotek5,cn=local')/" >> $phpath
grep "\$servers->setValue('login','bind_id','cn=Manager,dc=example,dc=com')"  $phpath| sed 's/^#$*//' | sed 's/'cn=Manager,dc=example,dc=com'/'cn=admin,dc=ziyotek5,dc=local'/' >> $phpath
grep "\$servers->setValue('login','attr','dn');" $phpath |  sed 's/\/\///' | sed 's/^#//' >> $phpath
grep "\$servers->setValue('login','attr','dn');" $phpath |  sed 's/\/\///' | sed 's/^#*//'>> $phpath
echo "Require ip 192.168.40.0/22" >> /etc/httpd/conf.d/phpldapadmin.conf
systemctl enable slapd && systemctl start slapd

cat << EOF > monitor.ldif
dn: olcDatabase={1}monitor,cn=config
changeType: modify
replace: olcAccess
olcAccess: {0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" read by dn.base="cn=admin,dc=ziyotek5,dc=local" read by * none
EOF

ldapmodify -Y EXTERNAL -H ldapi:/// -f monitor.ldif

cat << EOF > base.ldif
dn: dc=ziyotek5,dc=local
objectClass: dcObject
objectClass: organization
o: ziyotek5.local
dc: ziyotek5

dn: ou=users,dc=ziyotek5,dc=local
objectClass: organizationalUnit
objectClass: top
ou: users

dn: ou=groups,dc=ziyotek5,dc=local
objectClass: organizationalUnit
objectClass: top
ou: groups
EOF

ldapadd -x -W -D "cn=admin,dc=ziyotek5,dc=local" -f base.ldif
#!/usr/sbin/slappasswd -s
expect_user -re "(\[^ \]+) (\[^ \]+)\n"
set user $expect_out(1,string)
set pw   $expect_out(2,string)
spawn slappasswd $user
expect "password:"
send "$pw\r"
expect "password:"
send "$pw\r"
expect eof
