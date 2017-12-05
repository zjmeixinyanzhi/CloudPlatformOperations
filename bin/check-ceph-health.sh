#!/bin/sh
source /root/CloudPlatformOperations/0-set-config.sh
IS_ERR=$(ceph health|grep ERR|wc -l)
echo "`eval date +%Y-%m-%d_%H:%M:%S` [INFO] Ceph health is $(ceph health)"| tee -a $log_file
if [ $IS_ERR = "0" ];then
  echo "`eval date +%Y-%m-%d_%H:%M:%S` [INFO] Ceph health is $(ceph health)"| tee -a $log_file
  exit 0
else
  echo "`eval date +%Y-%m-%d_%H:%M:%S` [ERROR] Ceph health is $(ceph health)"| tee -a $log_file
  exit 127;
fi
