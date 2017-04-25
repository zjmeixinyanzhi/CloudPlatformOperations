#!/bin/sh
source /root/CloudPlatformOperations/0-set-config.sh
WHILE_FLAG=0

wait_start(){
  while [ $WHILE_FLAG -lt 20 ]
  do
    PCS_RESOURCE_STOP_SIZE=$(ssh network01 pcs resource|grep Stopped|wc -l)
    if [ "${PCS_RESOURCE_STOP_SIZE}" = "0" ];then
      break;
    fi 
    echo -ne "=>\033[s"
    echo -ne "\033[40;-20H"$((WHILE_FLAG*5*100/100))%"\033[u\033[1D"
    let WHILE_FLAG++
    sleep 10
  done
}
### 1. Start pcs cluster
ssh network01 pcs cluster start --all

### 2. Wait all start 
echo "`eval date +%Y-%m-%d_%H:%M:%S` [INFO] Networker Pcs Resources are starting!"
wait_start
ssh network01 pcs resource
### 3. Check the staus of pcs cluster
PCS_RESOURCE_STOP_SIZE=$(ssh network01 pcs resource|grep Stopped|wc -l)
if [ "${PCS_RESOURCE_STOP_SIZE}" = "0" ];then
  echo "`eval date +%Y-%m-%d_%H:%M:%S` [INFO] All pcs resources in network nodes are started!" | tee -a $log_file
  exit 0
else
  echo "`eval date +%Y-%m-%d_%H:%M:%S` [ERROR] Not all the pcs resources in network are started!"| tee -a $log_file
  exit 127
fi
