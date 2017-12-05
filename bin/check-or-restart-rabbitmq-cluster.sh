#!/bin/sh
source /root/CloudPlatformOperations/0-set-config.sh
RUNNING_SIZE=$(rabbitmqctl cluster_status|grep running_nodes|awk -F "," '{for(i=1;i<=NF;i++){printf "%s ", $i; printf "\n"}}'|grep controller0|wc -l)
PARTITIONS_SIZE=$(rabbitmqctl cluster_status|grep partitions|grep controller|wc -l)
### 1. Check and resume rabbitmq-server service in every nodes
if [ "${RUNNING_SIZE}" = "3" -a "$PARTITIONS_SIZE" = "0" ]; then
   echo "`eval date +%Y-%m-%d_%H:%M:%S` [INFO] Rabbitmq cluster is OK!" | tee -a $log_file
   exit 0
else
  ssh controller01 systemctl restart rabbitmq-server
  ssh controller02 systemctl restart rabbitmq-server
  ssh controller03 systemctl restart rabbitmq-server
fi
### 2. Recheck Galera Status
RUNNING_SIZE=$(rabbitmqctl cluster_status|grep running_nodes|awk -F "," '{for(i=1;i<=NF;i++){printf "%s ", $i; printf "\n"}}'|grep controller0|wc -l)
PARTITIONS_SIZE=$(rabbitmqctl cluster_status|grep partitions|grep controller|wc -l)
### 1. Check and resume rabbitmq-server service in every nodes
if [ "${RUNNING_SIZE}" = "3" -a "$PARTITIONS_SIZE" = "0" ]; then
  echo "`eval date +%Y-%m-%d_%H:%M:%S` [INFO] Rabbitmq cluster have restarted!"| tee -a $log_file
  exit 0
else
  echo "`eval date +%Y-%m-%d_%H:%M:%S` [ERROR] Rabbitmq cluster is error!"| tee -a $log_file
  exit 127
fi
