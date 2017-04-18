#!/bin/sh
. ../0-set-config.sh
STOP_ARR=();
UUID=$(uuidgen)
rm -rf /tmp/GTID_*
### 1. Check mariadb service in every nodes
for i in 01 02 03;
do
  FLAG=$(ssh controller$i systemctl status mariadb |grep Active:|grep running|wc -l)
  if [ "${FLAG}" = "0" ];then
    echo "controller$i is down!"
    let INDEX=${#STOP_ARR[@]}+1
    STOP_ARR[INDEX]=controller$i
    seqno=$(ssh controller$i cat /var/lib/mysql/grastate.dat|grep seqno:|awk '{print $2}')
    echo $seqno" "controller$i >> /tmp/GTID_$UUID
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
  ## 2.1 Only start the mariadb service in stopped nodes
  for node in ${STOP_ARR[@]};
  do
    ssh ${node} systemctl start mariadb
  done
elif [ "${CLUSTER_SIZE}" = "0" ]; then
  echo "All MariaDB nodes is down!"
  ABNORMAL_SIZE=$(cat /tmp/GTID_$UUID |grep "\-1"|wc -l)
  ## 2.2 Find the latest state node to bootstrap and start others nodes
  ## 2.2.1 All three nodes are gracefully stopped
  if [ "$ABNORMAL_SIZE" = "0" ];then
    BOOTSTARP_NODE=$(cat /tmp/GTID_$UUID|sort -n -r|head -n 1|awk '{print $2}')
    echo "All three nodes are gracefully stopped!"
  ## 2.2.2 All nodes went down without proper shutdown procedure
  elif [ "$ABNORMAL_SIZE" = "1" ];then
    BOOTSTARP_NODE=$(cat /tmp/GTID_$UUID|grep "\-1"|awk '{print $2}')
    echo "One node disappear in Galera Cluster! Two nodes are gracefully stopped!"
  elif [ "$ABNORMAL_SIZE" = "2" ];then
    echo "Two nodes disappear in Galera Cluster! One node is gracefully stopped!"
  elif [ "$ABNORMAL_SIZE" = "3" ];then
    BOOTSTARP_NODE=$(cat /tmp/GTID_$UUID|grep "\-1"|awk '{print $2}')
    echo "All nodes went down without proper shutdown procedure!"
  else
   echo "No grastate.dat or gvwstate.dat file!"
   exit 127 
  fi
  ### Recover Galera
  echo "[INFO] The bootstarp node is:"$BOOTSTARP_NODE
  ssh $BOOTSTARP_NODE /bin/bash << EOF
    mv /var/lib/mysql/gvwstate.dat /var/lib/mysql/gvwstate.dat.bak 
    galera_new_cluster
EOF
  for i in 01 02 03;
  do
    if [ "controller$i" = $BOOTSTARP_NODE ];then
      echo "[INFO] controller$i's mariadb service status:"$(ssh controller$i systemctl status mariadb |grep Active:) 
    else
      ssh "controller$i" systemctl start mariadb
    fi
  done  
else
  echo "Recover Galera Cluster is error!"
  exit 127
fi

### 3. Check Galera Status
WSREP_CLUSTER_SIZE=$(mysql -uroot -p$password_galera_root -e "SHOW STATUS LIKE 'wsrep_cluster_size';"|grep wsrep_cluster_size|awk '{print $2}')
echo "Galera cluster CLUSTER_SIZE:"$WSREP_CLUSTER_SIZE
if [ "${WSREP_CLUSTER_SIZE}" = "3" ]; then
  echo "Galera Cluster is OK!"
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
