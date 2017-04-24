#!/bin/sh
. ~/keystonerc_admin
. ../0-set-config.sh
### Get VMs old status
sed -i -e 's/^database_host.*/database_host = "'"$virtual_ip"'"/' retrieve_instances_status.py
sed -i -e 's/^database_password.*/database_password = "'"$password_galera_root"'"/' retrieve_instances_status.py
python retrieve_instances_status.py > server-status.dat
### check and resume
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
