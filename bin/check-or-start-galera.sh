#!/bin/sh
. ../0-set-config.sh
size=$(mysql -uroot -p$password_galera_root  -e "SHOW STATUS LIKE 'wsrep_cluster_size';"|grep wsrep_cluster_size|awk '{print $2}')
echo $0
echo $*
echo $@
echo $$
echo $!
sleep 0.1
