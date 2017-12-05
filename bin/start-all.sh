#!/bin/sh
source /root/CloudPlatformOperations/0-set-config.sh
check_status(){
  if [ $? != "0" ];then
  echo "`eval date +%Y-%m-%d_%H:%M:%S` [ERROR] 启动云平台失败！请联系运维人员！"
    exit 127
  fi
}

echo -e "\n======= 启动云平台操作开始 =======" | tee -a $log_file
echo "操作时间：`date`" | tee -a $log_file
echo "操作人：`whoami`" | tee -a $log_file
echo `who` >> $log_file 
### [Connectity]
echo "=== 节点联通性测试 ===" | tee -a $log_file
/root/CloudPlatformOperations/bin/check-nodes-connectity.sh
check_status
### [Rabbitmq]
echo "=== 消息队列集群启动 ===" | tee -a $log_file
/root/CloudPlatformOperations/bin/check-or-restart-rabbitmq-cluster.sh
check_status
### [Galera]
echo "=== 数据库集群启动 ===" | tee -a $log_file
/root/CloudPlatformOperations/bin/check-or-recover-galera.sh
check_status
### [Pcs cluster]
### 1 controllers
echo "=== 管理节点HA集群启动 ===" | tee -a $log_file
/root/CloudPlatformOperations/bin/check-or-restart-controller-pcs-cluster.sh
check_status
### 2 networker
echo "=== 网络节点HA集群启动 ===" | tee -a $log_file
/root/CloudPlatformOperations/bin/check-or-restart-networker-pcs-cluster.sh
check_status
### [Compute services]
echo "=== 计算节点服务启动启动 ===" | tee -a $log_file
/root/CloudPlatformOperations/bin/check-or-restart-compute-services.sh
### [Ceph storage cluster]
echo "=== 统一存储集群状态检测 ===" | tee -a $log_file
/root/CloudPlatformOperations/bin/check-ceph-health.sh
check_status
### [Ceph-rest-api]
echo "=== 统一存储Rest-api服务启动 ===" | tee -a $log_file
/root/CloudPlatformOperations/bin/ceph-rest-api-start.sh
check_status
### [Update VMs status]
echo "=== 还原虚拟机启动状态 ===" | tee -a $log_file
/root/CloudPlatformOperations/bin/resume_instances_status.sh
### [Cloud Portal]
echo "=== 云平台管理系统启动 ===" | tee -a $log_file
/opt/apache-tomcat-7.0.68/bin/startup.sh
echo -e "======= 启动云平台操作结束 =======" | tee -a $log_file
