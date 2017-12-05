#!/bin/sh
sed -i -e "s#^PasswordAuthentication.*#PasswordAuthentication yes#g" /etc/ssh/sshd_config
systemctl restart sshd
