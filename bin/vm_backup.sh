#!/bin/sh
#
# A simple script for virtual machine backup

backup_path=/var/lib/backups/vm_image
vmid=bf67ecac-9e0d-46ca-978d-f3372b537705_disk
vmname=cirros
yesterday=`date -d '1 days ago' +%Y%m%d`
today=`date +%Y%m%d`
weekday=`date +%w`
pre_file_name=$backup_path/$vmname"_"$vmid@$yesterday
cur_snap_name=$vmid@$today
cur_file_name=$backup_path/$vmname"_"$vmid@$yesterday
## export backup data
rbd snap create vms/$cur_snap_name
if [[ "$weekday" == "0" ]];then
 # delete the older data than 35 days
 find $backup_path/*.gz -ctime +35 -type f -delete
 # delete the older snaps in ceph
 for line in $(rbd -p vms snap ls $vmid|grep MB|awk '{print $2}')
 do
 echo $line
 #timespan=$(($(date +%s -d '$today')-$(date +%s -d '$dt')));
 lastReserveTime=`date -d '35 days ago' +%s`
 thisSnapTime=`date +%s -d "$line"`
 timespan=`expr $lastReserveTime - $thisSnapTime`
 if [[ $timespan -gt 0 ]];then
 echo "Delete snap:$line"
 rbd -p vms snap rm $vmid@$line
 fi
 done

 echo "$today:Full Backup"
 rbd export-diff vms/$cur_snap_name $cur_file_name
 echo yes | gzip $cur_file_name
else
 echo "$today:Incremental Backup"
 rbd export-diff vms/$cur_snap_name --from-snap $yesterday $pre_file_name"_"$today
 echo yes | gzip $pre_file_name"_"$today
fi
