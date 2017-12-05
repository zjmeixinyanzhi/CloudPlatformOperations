#!/bin/sh
file_name=`eval date +%Y%m%d%H%M%S`.log
log_file=/tmp/$file_name
hosts_file=
target_file=/var/www/html/index.html
>$log_file
function check(){
  if  [[ $1 -gt 60 ]];then
    echo "<font color='red'>磁盘使用率：$1% <警告>!</font>" | tee -a $log_file
    echo "<br>" |tee -a $log_file
  else
    echo "磁盘使用率："$1"%" | tee -a $log_file
    echo "<br>" |tee -a $log_file
  fi
}


for host in $(cat /root/CloudPlatformOperations/bin/hosts/online_vm.txt)
do
  echo -e "------$host------"  | tee -a $log_file
  echo "<br>" |tee -a $log_file
  ssh_str="ssh "$host
  if [[ $host == "172.20.100.120" ]];then
    ssh_str="ssh gugongoa@"$host" -p 7758 "
  elif [[ $host == "172.20.100.121" ]];then
    ssh_str="ssh gugongoadb@"$host" -p 7758 "
  else
    ssh_str="ssh $host"
  fi

  echo "系统时间："$($ssh_str eval date +%Y-%m-%d_%H:%M:%S) | tee -a $log_file
  echo "<br>" |tee -a $log_file
  echo "CPU使用率："$($ssh_str iostat -c|grep -A1 avg-cpu|grep -v avg-cpu|awk '{print $1}')"%" | tee -a $log_file
  echo "<br>" |tee -a $log_file
  echo "内存使用率："$($ssh_str free -m|grep Mem:|awk '{print $3/$2*100"%"}') | tee -a $log_file
  echo "<br>" |tee -a $log_file
  disk=$($ssh_str df -TH |grep /$|awk '{print $6}'|awk -F"%" '{print $1}') 
  if [[ $disk == "/" ]];then
    disk=$($ssh_str df -TH |grep /$|awk '{print $5}'|awk -F"%" '{print $1}')
  fi
  check $disk
  echo "<br>" |tee -a $log_file
done
\cp $log_file $target_file
