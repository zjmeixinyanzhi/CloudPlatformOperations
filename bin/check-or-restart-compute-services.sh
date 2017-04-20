#!/bin/sh
. ../0-set-config.sh
echo "[INFO] Start openstack service in compute nodes!"
for ((i=0; i<${#hypervisor_map[@]}; i+=1));
do
  name=${nodes_name[$i]};
  ip=${hypervisor_map[$name]};
  ssh root@$ip systemctl start libvirtd.service openstack-nova-compute.service openvswitch.service neutron-openvswitch-agent.service openstack-ceilometer-compute.service 
done;
