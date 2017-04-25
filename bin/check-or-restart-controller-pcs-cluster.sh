#!/bin/sh
source /root/CloudPlatformOperations/0-set-config.sh
WHILE_FLAG=0

wait_start(){
  while [ $WHILE_FLAG -lt 20 ]
  do
    PCS_RESOURCE_STOP_SIZE=$(pcs resource|grep Stopped|wc -l)
    HAPROXY_START_FLAG=$(pcs resource|grep -A1 haproxy|grep Started:|wc -l)
    if [ "${PCS_RESOURCE_STOP_SIZE}" = "1" -a "${HAPROXY_START_FLAG}" = "1" ];then
      break;
    fi 
    echo -ne "=>\033[s"
    echo -ne "\033[40;-20H"$((WHILE_FLAG*5*100/100))%"\033[u\033[1D"
    let WHILE_FLAG++
    sleep 30
  done
}
### 1. Start pcs cluster
pcs cluster start --all

### 2. Wait all start 
echo "`eval date +%Y-%m-%d_%H:%M:%S` [INFO] Controllers pcs Resources are starting!"| tee -a $log_file
wait_start
pcs resource
### 3. Check the staus of pcs cluster
PCS_RESOURCE_STOP_SIZE=$(pcs resource|grep Stopped|wc -l)
HAPROXY_START_FLAG=$(pcs resource|grep -A1 haproxy|grep Started:|wc -l)
if [ "${PCS_RESOURCE_STOP_SIZE}" = "1" -a "${HAPROXY_START_FLAG}" = "1" ];then
  echo "`eval date +%Y-%m-%d_%H:%M:%S` [INFO] All Pcs Resources in controller nodes are started!" | tee -a $log_file
  exit 0
else
  echo "`eval date +%Y-%m-%d_%H:%M:%S` [ERROR] Not all the pcs resources in controller nodes are started!"| tee -a $log_file
  exit 127
fi
