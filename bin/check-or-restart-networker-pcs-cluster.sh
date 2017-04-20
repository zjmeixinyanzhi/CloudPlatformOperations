#!/bin/sh
. ../0-set-config.sh
WHILE_FLAG=0

wait_start(){
  while [ $WHILE_FLAG -lt 20 ]
  do
    PCS_RESOURCE_STOP_SIZE=$(ssh $network_host pcs resource|grep Stopped|wc -l)
    if [ "${PCS_RESOURCE_STOP_SIZE}" = "0" ];then
      break;
    fi 
    echo -ne "=>\033[s"
    echo -ne "\033[40;-20H"$((WHILE_FLAG*5*100/100))%"\033[u\033[1D"
    let WHILE_FLAG++
    sleep 2
  done
}
### 1. Start pcs cluster
ssh $network_host pcs cluster start --all

### 2. Wait all start 
echo "[INFO] Networker Pcs Resources are starting!"
wait_start
ssh $network_host pcs resource
### 3. Check the staus of pcs cluster
PCS_RESOURCE_STOP_SIZE=$(ssh $network_host pcs resource|grep Stopped|wc -l)
if [ "${PCS_RESOURCE_STOP_SIZE}" = "0" ];then
  echo "[INFO] All pcs resources in network nodes are started!"
  exit 0
else
  echo "[ERROR] Not all the pcs resources in network are started!"
  exit 127
fi
