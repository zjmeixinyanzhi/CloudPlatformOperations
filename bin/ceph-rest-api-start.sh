#!/bin/sh
ceph-rest-api -n client.admin > /dev/null 2>&1 &
PORT=$(cat /etc/ceph/ceph.conf |grep "public addr"|awk -F":" '{print $2}')
START_FLAG=$(netstat -ntlp|grep $PORT|wc -l)
if [ "$START_FLAG" = "1" ];then
  echo "[INFO] Ceph-rest-api service is started!"
  exit 0
else
  echo "[ERROR] Ceph-rest-api service isn't started!" 
  exit 127
fi
