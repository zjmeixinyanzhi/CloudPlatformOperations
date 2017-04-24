#!/bin/sh
source /root/CloudPlatformOperations/0-set-config.sh
SLEEP_SECOND=2
WHILE_FLAG=0

test_connection(){
  while [ $WHILE_FLAG -lt 20 ]
  do
    SUCCESS_FLAG=$(ping -c 3 $1|grep "100% packet loss"|wc -l)
    if [ "${SUCCESS_FLAG}" != "1" ];then
      echo "[INFO] $1:SUCCESS"
      break;
    fi
    echo -ne "=>\033[s"
    echo -ne "\033[40;-20H"$((WHILE_FLAG*5*100/100))%"\033[u\033[1D"
    let WHILE_FLAG++
    sleep $SLEEP_SECOND
  done
}

check_result(){
  SUCCESS_FLAG=$(ping -c 3 $1|grep "100% packet loss"|wc -l)
  if [ "${SUCCESS_FLAG}" = "1" ];then
    exit 127
  fi 
}

### 1. check compute nodes
for node in ${hypervisor_name[@]}
do
  test_connection $node
done
### 2. check networker nodes
for node in ${networker_name[@]}
do
  test_connection $node
  check_result $node
done
### 3. check controller nodes
for node in ${controller_name[@]}
do
  test_connection $node
  check_result $node
done
