#!/bin/sh
source /root/CloudPlatformOperations/0-set-config.sh
check_status(){
  if [ $? != "0" ];then
    exit 127
  fi
}

### [Connectity]
/root/CloudPlatformOperations/bin/check-nodes-connectity.sh
check_status
### [Rabbitmq]
/root/CloudPlatformOperations/bin/check-or-restart-rabbitmq-cluster.sh
check_status
### [Galera]
/root/CloudPlatformOperations/bin/check-or-recover-galera.sh
check_status
### [Pcs cluster]
### 1 controllers
/root/CloudPlatformOperations/bin/check-or-restart-controller-pcs-cluster.sh
check_status
### 2 networker
/root/CloudPlatformOperations/bin/check-or-restart-networker-pcs-cluster.sh
check_status
### [Compute services]
/root/CloudPlatformOperations/bin/check-or-restart-compute-services.sh
### [Ceph-rest-api]
/root/CloudPlatformOperations/bin/ceph-rest-api-start.sh
check_status
### [Update VMs status]

### [Cloud Portal]
