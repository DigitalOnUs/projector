#!/bin/bash

set -e

function generate_passwd {
   cat /dev/urandom | tr -dc "a-zA-Z0-9" | fold -w 15 | head -1
}

mkdir -p /data/etc/httpd/
mkdir -p /data/etc/ssh/
mkdir -p /data/home
mkdir -p /data/lib
mkdir -p /data/etc/logrotate.d
mkdir -p /data/etc/ssl/certs/
mkdir -p /data/etc/pki/tls/private/
mkdir -p /data/root && chmod 700 /data/root

pushd . > /dev/null
cd /var/lib
mv /var/lib/mysql /data/lib && ln -s /data/lib/mysql mysql
[ -d /var/lib/gitolite ] && mv /var/lib/gitolite /data/lib && ln -s /data/lib/gitolite gitolite
popd > /dev/null

# Apply tuleap patches (should be temporary until integrated upstream)
pushd . > /dev/null
cd /usr/share/tuleap
/bin/ls /root/app/patches/*.patch | while read patch; do
    patch -p1 -i $patch
done
popd > /dev/null

# Do not activate services
sed -ie 's/\$CHKCONFIG \$service on/: #\$CHKCONFIG \$service on/g' /usr/share/tuleap/tools/setup.sh
sed -ie 's/are stored.*/are stored in \/data\/root\/\.tuleap_passwd"/g' /usr/share/tuleap/tools/setup.sh

# Install Tuleap
/usr/share/tuleap/tools/setup.sh --disable-domain-name-check --sys-default-domain=$VIRTUAL_HOST --sys-org-name=Tuleap --sys-long-org-name=Tuleap

# Setting root password
root_passwd=${ROOT_PWD:-$(generate_passwd)}
echo root_passwd=$ROOT_PWDd
echo root_passwd=$root_passwd
echo "root:$root_passwd" |chpasswd
echo "root: $root_passwd" >> /root/.tuleap_passwd

# Force the generation of the SSH host keys
service sshd start && service sshd stop

# Generate self signed certificate for Apache
cat << EOF | openssl req -new -nodes -keyout /etc/pki/tls/private/localhost.key \
         -x509 -sha256 -days 365 -set_serial $RANDOM -extensions v3_req \
         -out /etc/ssl/certs/localhost.crt 2>/dev/null
--
SomeState
SomeCity
SomeOrganization
SomeOrganizationalUnit
${VIRTUAL_HOST}
root@${VIRTUAL_HOST}
EOF

# (Re)Generate the Gitolite admin key for the codendiadm user
ssh-keygen -q -t rsa -N "" -C 'Tuleap / gitolite admin key' -f '/home/codendiadm/.ssh/id_rsa_gl-adm'
chown codendiadm:codendiadm /home/codendiadm/.ssh/id_rsa_gl-adm*
echo "command=\"/usr/share/gitolite3/gitolite-shell id_rsa_gl-adm\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty $(cat /home/codendiadm/.ssh/id_rsa_gl-adm.pub)" > /var/lib/gitolite/.ssh/authorized_keys
chown gitolite:gitolite /var/lib/gitolite/.ssh/authorized_keys
chmod 600 /var/lib/gitolite/.ssh/authorized_keys

# Place for post install stuff
./boot-postinstall.sh

# Ensure system will be synchronized ASAP
/usr/share/tuleap/src/utils/php-launcher.sh /usr/share/tuleap/src/utils/launch_system_check.php

service mysqld stop
service httpd stop
service crond stop

### Move all generated files to persistant storage ###

# Conf
mv /etc/httpd/conf            /data/etc/httpd
mv /etc/httpd/conf.d          /data/etc/httpd
mv /etc/pki/tls/private/localhost.key /data/etc/pki/tls/private
mv /etc/ssl/certs/localhost.crt /data/etc/ssl/certs
mv /etc/tuleap                /data/etc
mv /etc/aliases               /data/etc
mv /etc/logrotate.d/httpd     /data/etc/logrotate.d
mv /etc/libnss-mysql.cfg      /data/etc
mv /etc/libnss-mysql-root.cfg /data/etc
mv /etc/my.cnf                /data/etc
mv /etc/nsswitch.conf         /data/etc
mv /etc/crontab               /data/etc
mv /etc/passwd                /data/etc
mv /etc/shadow                /data/etc
mv /etc/group                 /data/etc
mv /root/.tuleap_passwd       /data/root
mv /etc/ssh/ssh_host_*        /data/etc/ssh

# Data
mv /home/codendiadm /data/home
mv /home/groups    /data/home
mv /home/users     /data/home
mv /var/lib/tuleap /data/lib

# Will be restored by boot-fixpath.sh later
[ -h /var/lib/mysql ] && rm /var/lib/mysql
[ -h /var/lib/gitolite ] && rm /var/lib/gitolite
