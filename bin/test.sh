#!/bin/sh
find(){
 for host in $(cat /tmp/GTID_16bc90ec-be73-4149-b14f-119d4bd807dc|grep "\-1"|awk '{print $2}')
 do 
    VIEW_ID=$(ssh ${host} cat /var/lib/mysql/gvwstate.dat|grep view_id|awk '{print $3}')
    MY_UUID=$(ssh ${host} cat /var/lib/mysql/gvwstate.dat|grep my_uuid|awk '{print $2}')
    if [ $VIEW_ID = $MY_UUID  ];then
       echo $host
    fi
 done
}
ssh $(find) pwd
