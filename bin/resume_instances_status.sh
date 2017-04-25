#!/bin/sh
. ~/keystonerc_admin
source /root/CloudPlatformOperations/0-set-config.sh
### Get VMs old status
sed -i -e 's/^database_host.*/database_host = "'"$virtual_ip"'"/' retrieve_instances_status.py
sed -i -e 's/^database_password.*/database_password = "'"$password_galera_root"'"/' retrieve_instances_status.py
#python retrieve_instances_status.py > server-status.txt
### check and resume
for line in  $(python retrieve_instances_status.py |grep ACTIVE)
do
  ID=$(echo $line|awk -F: '{print $1}')
  LAST_STATUS=$(echo $line|awk -F: '{print $2}')
  TMP_FILE=/tmp/_server_info
  CUR_STATUS=$(nova show $ID|grep status|grep -v "_status"|awk '{print $4}')
  echo "`eval date +%Y-%m-%d_%H:%M:%S` [INFO] $ID": "${CUR_STATUS} --> ${LAST_STATUS}"| tee -a $log_file
  if [ "${LAST_STATUS}" = "ACTIVE" -a "$CUR_STATUS" = "SHUTOFF" ];then
    echo "`eval date +%Y-%m-%d_%H:%M:%S` [INFO] Unconsistent status!Start this VM!"| tee -a $log_file
    openstack server start $ID
  fi
done
