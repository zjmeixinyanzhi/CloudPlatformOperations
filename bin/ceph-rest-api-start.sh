#!/bin/sh
source /root/CloudPlatformOperations/0-set-config.sh
ceph-rest-api -n client.admin > /dev/null 2>&1 &
PORT=$(cat /etc/ceph/ceph.conf |grep "public addr"|awk -F":" '{print $2}')
START_FLAG=$(netstat -ntlp|grep $PORT|wc -l)
if [ "$START_FLAG" = "1" ];then
  echo "`eval date +%Y-%m-%d_%H:%M:%S` [INFO] Ceph-rest-api service is started!"| tee -a $log_file
  exit 0
else
  echo "`eval date +%Y-%m-%d_%H:%M:%S` [ERROR] Ceph-rest-api service isn't started!" | tee -a $log_file
  exit 127
fi
