#!/bin/sh
. ../0-set-config.sh
size=$(mysql -uroot -p$password_galera_root  -e "SHOW STATUS LIKE 'wsrep_cluster_size';"|grep wsrep_cluster_size|awk '{print $2}')
echo "Galera cluster size:"$size
if [ "${size}" = "3" ]; then
  echo "Galera is OK!"
elif [ "$size" = "2"  ];then
  echo "One MariaDB nodes is down!"
elif [ "$size" = "1"  ];then
  echo "Two MariaDB nodes is down!"
else
  echo "All MariaDB nodes is down!"
fi
