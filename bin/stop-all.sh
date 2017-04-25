#!/bin/sh
source /root/CloudPlatformOperations/0-set-config.sh
nodes_name=(${!nodes_map[@]});
stop_all_services(){
  ### stop portal
  /opt/apache-tomcat-7.0.68/bin/shutdown.sh
  ### Stop controller cluster
  echo -e "\033[34m正在关闭控制节点集群上的云平台服务，请耐心等待！\033[0m"| tee -a $log_file
  pcs cluster stop --all
  for i in 01 02 03; do ssh controller$i pcs cluster kill; done
  pcs cluster stop --all
  ### Stop network cluster
  echo -e "\033[34m正在关闭网络节点集群上的云平台服务，请耐心等待！\033[0m"| tee -a $log_file
  ssh root@network01 pcs cluster stop --all
  for i in 01 02 03; do ssh network$i pcs cluster kill; done
  ssh root@network01 pcs cluster stop --all
  ### Stop Galera DB Cluster
  echo -e "\033[34m正在数据库集群，请耐心等待！\033[0m"| tee -a $log_file
  for i in 01 02 03; do ssh controller$i systemctl stop mariadb; done
}

shutdown_all_nodes(){
  for host in ${nodes_name[@]}
  do
    if [ $name =  "controller01" ]; then
      echo $name" will poweroff at the end!"
    else
      ssh $host poweroff
    fi
  done
  poweroff
}
reboot_all_nodes(){
  for host in ${nodes_name[@]}
  do
    if [ $name =  "controller01" ]; then
      echo $name" will reboot at the end!"
    else
      ssh $host reboot
    fi
  done
  reboot
}

echo -e "\n======= 关闭云平台 =======" | tee -a $log_file
echo "操作时间：`date`" | tee -a $log_file
echo "操作人：`whoami`" | tee -a $log_file
echo `who` >> $log_file
echo -e "\033[33m警告:是否要关闭云平台服务？yes/no \033[0m" | tee -a $log_file
read confirm
echo "确认操作:"$confirm | tee -a $log_file
if [ $confirm = "yes" ];then
  stop_all_services 
  echo -e "\033[34m云平台服务已关闭！ \033[0m" | tee -a $log_file
else
  echo -e "\033[34m未执行关闭云平台服务操作！\033[0m" | tee -a $log_file
fi
### Poweroff
echo -e "\033[33m警告:是否要关闭所有节点？yes/no \033[0m" | tee -a $log_file
read confirm
echo "确认操作:"$confirm | tee -a $log_file
if [ $confirm = "yes" ];then
  echo -e "\033[34m执行关机操作！\033[0m"| tee -a $log_file
  shutdown_all_nodes
else
  echo -e "\033[34m未执行关机操作！\033[0m"| tee -a $log_file
fi
### Reboot
echo -e "\033[33m警告:是否要重启所有节点？yes/no \033[0m" | tee -a $log_file
read confirm
echo "确认操作:"$confirm | tee -a $log_file
if [ $confirm = "yes" ];then
  echo -e "\033[34m执行重启操作！\033[0m"| tee -a $log_file
  reboot_all_nodes
else
  echo -e "\033[34m未执行重启操作！\033[0m"| tee -a $log_file
fi
