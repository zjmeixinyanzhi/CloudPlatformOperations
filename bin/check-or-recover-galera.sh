#!/bin/sh
source /root/CloudPlatformOperations/0-set-config.sh
STOP_NODES=();
UUID=$(uuidgen)
rm -rf /tmp/GTID_*

findBootstrapNode(){
  for host in $(cat /tmp/GTID_${UUID}|grep "\-1"|awk '{print $2}')
  do
    VIEW_ID=$(ssh ${host} cat /var/lib/mysql/gvwstate.dat|grep view_id|awk '{print $3}')
    MY_UUID=$(ssh ${host} cat /var/lib/mysql/gvwstate.dat|grep my_uuid|awk '{print $2}')
    if [ $VIEW_ID = $MY_UUID  ];then
       echo $host
       break
    fi
  done
}

### 1. Check mariadb service in every nodes
for i in 01 02 03;
do
  FLAG=$(ssh controller$i systemctl status mariadb |grep Active:|grep running|wc -l)
  if [ "${FLAG}" = "0" ];then
    echo "`eval date +%Y-%m-%d_%H:%M:%S` [INFO] controller$i is down!" | tee -a $log_file
    let INDEX=${#STOP_NODES[@]}+1
    STOP_NODES[INDEX]=controller$i
    seqno=$(ssh controller$i cat /var/lib/mysql/grastate.dat|grep seqno:|awk '{print $2}')
    echo $seqno" "controller$i >> /tmp/GTID_$UUID
  elif [ "$FLAG" = "1" ];then
    echo "`eval date +%Y-%m-%d_%H:%M:%S` [INFO] controller$i is up!" | tee -a $log_file
  else
    echo "`eval date +%Y-%m-%d_%H:%M:%S` [ERROR] Get the status of controller$i ariadb is error!"| tee -a $log_file
    exit 127 
  fi
done
### 2. Recover Galera Cluster
let CLUSTER_SIZE=3-${#STOP_NODES[@]}
if [ "${CLUSTER_SIZE}" = "3" ]; then
  echo "`eval date +%Y-%m-%d_%H:%M:%S` [INFO] Galera is OK!"| tee -a $log_file
elif [ "$CLUSTER_SIZE" = "2" -o "$CLUSTER_SIZE" = "1" ];then
  echo "`eval date +%Y-%m-%d_%H:%M:%S` [INFO] One or Two MariaDB nodes is down!"| tee -a $log_file
  ## 2.1 Only start the mariadb service in stopped nodes
  for node in ${STOP_NODES[@]};
  do
    ssh ${node} systemctl start mariadb
  done
elif [ "${CLUSTER_SIZE}" = "0" ]; then
  echo "`eval date +%Y-%m-%d_%H:%M:%S` [INFO] All MariaDB nodes is down!"| tee -a $log_file
  ABNORMAL_SIZE=$(cat /tmp/GTID_$UUID |grep "\-1"|wc -l)
  ## 2.2 Find the latest state node to bootstrap and start others nodes
  ## 2.2.1 All three nodes are gracefully stopped
  if [ "$ABNORMAL_SIZE" = "0" ];then
    BOOTSTARP_NODE=$(cat /tmp/GTID_$UUID|sort -n -r|head -n 1|awk '{print $2}')
    echo "`eval date +%Y-%m-%d_%H:%M:%S` [INFO] All three nodes are gracefully stopped!"| tee -a $log_file
  ## 2.2.2 All nodes went down without proper shutdown procedure
  elif [ "$ABNORMAL_SIZE" = "1" ];then
    BOOTSTARP_NODE=$(cat /tmp/GTID_$UUID|grep "\-1"|awk '{print $2}')
    echo "`eval date +%Y-%m-%d_%H:%M:%S` [INFO] One node disappear in Galera Cluster! Two nodes are gracefully stopped!"| tee -a $log_file
  elif [ "$ABNORMAL_SIZE" = "2" ];then
    echo "`eval date +%Y-%m-%d_%H:%M:%S` [INFO] Two nodes disappear in Galera Cluster! One node is gracefully stopped!"| tee -a $log_file
    BOOTSTARP_NODE=$(findBootstrapNode)
  elif [ "$ABNORMAL_SIZE" = "3" ];then
    echo "`eval date +%Y-%m-%d_%H:%M:%S` [INFO] All nodes went down without proper shutdown procedure!"| tee -a $log_file
    BOOTSTARP_NODE=$(findBootstrapNode)
  else
   echo "`eval date +%Y-%m-%d_%H:%M:%S` [ERROR] No grastate.dat or gvwstate.dat file!"| tee -a $log_file
   exit 127 
  fi
  ### Recover Galera
  echo "`eval date +%Y-%m-%d_%H:%M:%S` [INFO] The bootstarp node is:"$BOOTSTARP_NODE| tee -a $log_file
  MYSQL_PID=$(ssh $BOOTSTARP_NODE netstat -ntlp|grep 4567|awk '{print $7}'|awk -F "/" '{print $1}') 
  ssh $BOOTSTARP_NODE /bin/bash << EOF
    kill -9 $MYSQL_PID 
    mv /var/lib/mysql/gvwstate.dat /var/lib/mysql/gvwstate.dat.bak 
    galera_new_cluster
EOF
  sleep 20
  for i in 01 02 03;
  do
    if [ "controller$i" = $BOOTSTARP_NODE ];then
      echo "`eval date +%Y-%m-%d_%H:%M:%S` [INFO] controller$i's mariadb service status:"$(ssh controller$i systemctl status mariadb |grep Active:) | tee -a $log_file
    else
      echo "`eval date +%Y-%m-%d_%H:%M:%S` [INFO] controller$i start service:"| tee -a $log_file
      ssh "controller$i" systemctl start mariadb
    fi
  done  
else
  echo "`eval date +%Y-%m-%d_%H:%M:%S` [ERROR] Recover Galera Cluster is error!"| tee -a $log_file
  exit 127
fi
### 3. Check Galera Status
sleep 5
WSREP_CLUSTER_SIZE=$(mysql -uroot -p$password_galera_root -e "SHOW STATUS LIKE 'wsrep_cluster_size';"|grep wsrep_cluster_size|awk '{print $2}')
echo "`eval date +%Y-%m-%d_%H:%M:%S` [INFO] Galera cluster CLUSTER_SIZE:"$WSREP_CLUSTER_SIZE| tee -a $log_file
if [ "${WSREP_CLUSTER_SIZE}" = "3" ]; then
  echo "`eval date +%Y-%m-%d_%H:%M:%S` [INFO] Galera Cluster is OK!"| tee -a $log_file
  exit 0
elif [ "$WSREP_CLUSTER_SIZE" = "2"  ];then
  echo "`eval date +%Y-%m-%d_%H:%M:%S` [INFO] One MariaDB nodes is down!"| tee -a $log_file
  exit 2
elif [ "$WSREP_CLUSTER_SIZE" = "1"  ];then
  echo "`eval date +%Y-%m-%d_%H:%M:%S` [INFO] Two MariaDB nodes is down!"| tee -a $log_file
  exit 1
else
  echo "`eval date +%Y-%m-%d_%H:%M:%S` [INFO] All MariaDB nodes is down!"| tee -a $log_file
  exit 3
fi
