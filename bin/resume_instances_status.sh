#!/bin/sh
. ~/keystonerc_admin
## Get VMs old status
python retrieve_instances_status.py > server-status.dat

for line in `cat server-status.dat`
do
  ID=$(echo $line|awk -F: '{print $1}')
  LAST_STATUS=$(echo $line|awk -F: '{print $2}')
  CUR_STATUS=$(openstack server show $ID |grep "status"|awk '{print $4}')
  echo "$ID": "${CUR_STATUS} --> ${LAST_STATUS}" 
  if [ "${LAST_STATUS}" = "ACTIVE" -a "$CUR_STATUS" = "SHUTOFF" ];then
    echo "Unconsistent status!Start this VM!"
    openstack server start $ID
  fi
done
