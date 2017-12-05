#!/bin/sh
declare -a controllers=(controller01 controller02 controller03)
declare -a networkers=(network01 network02 network03)
declare -a hypervisors=(compute01 compute02 compute03 compute04 compute05)
dir=/var/lib/backups/all_nodes_configs/`eval date +%Y%m%d%H%M%S`/
echo $dir
for h in ${controllers[@]};
do
  tmp_dir=$dir/$h
  mkdir -p $tmp_dir
  for i in haproxy keystone glance nova neutron httpd cinder aodh ceilometer ceph sysconfig/network-scripts/;
  do
    echo "  -->scp -r $h:/etc/$i/ $tmp_dir/"
    scp -r root@$h:/etc/$i/ $tmp_dir
  done
done
for h in ${networkers[@]};
do
  tmp_dir=$dir/$h
  mkdir -p $tmp_dir
  for i in neutron ceph sysconfig/network-scripts/;
  do
    echo "  -->scp -r $h:/etc/$i/ $tmp_dir/"
    scp -r root@$h:/etc/$i/ $tmp_dir
  done
done
for h in ${hypervisors[@]};
do
  tmp_dir=$dir/$h
  mkdir -p $tmp_dir
  for i in nova neutron ceilometer libvirt ceph sysconfig/network-scripts/;
  do
    echo "  -->scp -r $h:/etc/$i/ $tmp_dir/"
    scp -r root@$h:/etc/$i/ $tmp_dir
  done
done
