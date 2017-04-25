#!/bin/sh
source /root/CloudPlatformOperations/0-set-config.sh
echo "`eval date +%Y-%m-%d_%H:%M:%S` [INFO] Start openstack service in compute nodes!" | tee -a $log_file
for ((i=0; i<${#hypervisor_map[@]}; i+=1));
do
  name=${nodes_name[$i]};
  ip=${hypervisor_map[$name]};
  ssh root@$ip systemctl start libvirtd.service openstack-nova-compute.service openvswitch.service neutron-openvswitch-agent.service openstack-ceilometer-compute.service 
done;
