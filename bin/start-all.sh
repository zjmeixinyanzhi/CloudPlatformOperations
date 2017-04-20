#!/bin/sh
. ../0-set-config.sh
check_status(){
  if [ $? != "0" ];then
    exit 127
  fi
}
### [Rabbitmq]
./check-or-restart-rabbitmq-cluster.sh
check_status
### [Galera]
./check-or-recover-galera.sh
check_status
### [Pcs cluster]
### 1 controllers
./check-or-restart-controller-pcs-cluster.sh
check_status
### 2 networker
./check-or-restart-networker-pcs-cluster.sh
check_status
### [Compute services]
./check-or-restart-compute-services.sh
### [Ceph-rest-api]
./ceph-rest-api-start.sh
check_status
### [Update VMs status]

### [Cloud Portal]
