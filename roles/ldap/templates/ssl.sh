#!/bin/bash
cd /etc/pki/tls/misc/
./CA -newca
cd /etc/pki/CA
cp cacert.pem /etc/openldap/certs/
cp private/cakey.pem /etc/openldap/certs/ldapkey.pem
cp newcerts/C928C4D8863A765B.pem /etc/openldap/certs/ldap.pem
