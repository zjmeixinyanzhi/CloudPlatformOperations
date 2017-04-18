#!/bin/sh
### [Rabbitmq]
ssh controller02 systemctl stop rabbitmq-server
ssh controller01 systemctl stop rabbitmq-server
ssh controller03 systemctl stop rabbitmq-server
ssh controller01 systemctl start rabbitmq-server
ssh controller03 systemctl start rabbitmq-server
ssh controller02 systemctl start rabbitmq-server

### [Galera]
ssh controller01 galera_new_cluster
ssh controller02 systemctl start mariadb
ssh controller03 systemctl start mariadb

### [Pcs cluster]
### 1 controllers
pcs cluster start --all
pcs resource|grep Stopped|wc -l
### 2 networker
ssh network01 pcs cluster start --all
pcs resource|grep Stopped|wc -l

### [Ceph-rest-api]



### [Update VMs status]

### [Cloud Portal]
