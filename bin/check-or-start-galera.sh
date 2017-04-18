#!/bin/sh
. ../0-set-config.sh
STOP_ARR=();
### 1. Check mariadb service in every nodes
for i in 01 02 03;
do
  FLAG=$(ssh controller$i systemctl status mariadb |grep Active:|grep running|wc -l)
  if [ "${FLAG}" = "0" ];then
    echo "controller$i is down!"
    let INDEX=${#STOP_ARR[@]}+1
    STOP_ARR[INDEX]=controller$i
  elif [ "$FLAG" = "1" ];then
    echo "controller$i is up!"
  else
    echo "Get the status of controller$i ariadb is error!"
    exit 127 
  fi
done
### 2. Recover Galera Cluster
let CLUSTER_SIZE=3-${#STOP_ARR[@]}
echo $CLUSTER_SIZE
if [ "${CLUSTER_SIZE}" = "3" ]; then
  echo "Galera is OK!"
elif [ "$CLUSTER_SIZE" = "2" -o "$CLUSTER_SIZE" = "1" ];then
  echo "One or Two MariaDB nodes is down!"
  ## a) Only start the mariadb service in stopped nodes
  for node in ${STOP_ARR[@]};
  do
    ssh ${node} systemctl start mariadb
  done
elif [ "${CLUSTER_SIZE}" = "3" ]; then
  ## b) Find the latest state node to bootstrap and start others nodes
  echo "All MariaDB nodes is down!"
  echo "Galera is OK!"

else
  echo "Recover Galera Cluster is error!!"
fi
### 3. Check Galera Status
WSREP_CLUSTER_SIZE=$(mysql -uroot -p$password_galera_root -e "SHOW STATUS LIKE 'wsrep_cluster_size';"|grep wsrep_cluster_size|awk '{print $2}')
echo "Galera cluster CLUSTER_SIZE:"$WSREP_CLUSTER_SIZE
if [ "${WSREP_CLUSTER_SIZE}" = "3" ]; then
  echo "Galera is OK!"
  exit 0
elif [ "$WSREP_CLUSTER_SIZE" = "2"  ];then
  echo "One MariaDB nodes is down!"
  exit 2
elif [ "$WSREP_CLUSTER_SIZE" = "1"  ];then
  echo "Two MariaDB nodes is down!"
  exit 1
else
  echo "All MariaDB nodes is down!"
  exit 3
fi

