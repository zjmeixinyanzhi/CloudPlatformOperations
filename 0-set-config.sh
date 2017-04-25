#!/bin/sh
### 设置部署节点主机名和IP，nodes_map为全部节点、controller_map为三个控制节点、hypervisor_map为计算节点（与存储节点融合）
declare -A nodes_map=(["controller01"]="172.20.103.1" ["controller02"]="172.20.103.2" ["controller03"]="172.20.103.3" ["compute01"]="172.20.103.4" ["compute02"]="172.20.103.5" ["compute03"]="172.20.103.6" ["compute04"]="172.20.103.7" ["compute05"]="172.20.103.8" ["network01"]="172.20.103.9" ["network02"]="172.20.103.10" ["network03"]="172.20.103.17" ["compute06"]="172.20.103.11" ["compute07"]="172.20.103.12" ["compute08"]="172.20.103.13" ["compute09"]="172.20.103.14" ["compute10"]="172.20.103.15" ["compute11"]="172.20.103.16");
declare -A controller_map=(["controller01"]="172.20.103.1" ["controller02"]="172.20.103.2" ["controller03"]="172.20.103.3");
declare -A hypervisor_map=(["compute01"]="172.20.103.4" ["compute02"]="172.20.103.5" ["compute03"]="172.20.103.6" ["compute04"]="172.20.103.7" ["compute05"]="172.20.103.8" ["compute06"]="172.20.103.11" ["compute07"]="172.20.103.12" ["compute08"]="172.20.103.13" ["compute09"]="172.20.103.14" ["compute10"]="172.20.103.15" ["compute11"]="172.20.103.16");
declare -A monitor_map=(["controller01"]="172.20.200.1" ["network01"]="172.20.200.9" ["compute01"]="172.20.200.4");
declare -A networker_map=(["network01"]="172.20.200.9" ["network02"]="172.20.200.10" ["network03"]="172.20.200.17");
### 后期需要增加的计算节点
#declare -A additionalNodes_map=(["compute04"]="192.168.2.107" ["compute05"]="192.168.2.108");

declare nodes_name=(${!nodes_map[@]});
declare controller_name=(${!controller_map[@]});
declare networker_name=(${!networker_map[@]});
declare hypervisor_name=(${!hypervisor_map[@]});

### 设置虚拟IP，virtual_ip为openstack服务的虚拟IP，virtual_ip_redis为Redis为虚拟IP
virtual_ip=172.20.103.241
virtual_ip_redis=172.20.200.242
### 设置网卡信息 local_nic为管理网网卡名称 data_nic为虚拟网网卡名称 storage_nic为存储网网卡信息 local_bridge为外网网桥名称
local_nic=em4
data_nic=em1
storage_nic=em2
local_bridge=br-ex
### 设置网络网段信息，分别对应管理网、虚拟网、存储网
local_network=172.20.200.0/24
data_network=172.20.201.0/24
store_network=172.20.202.0/24
### 离线安装源的FTP目录信息
ftp_info="ftp://172.20.200.1/pub/share/"
nfs_location=/var/ftp/pub/
nfs_host=172.20.200.1
### 临时目录，用于scp存放配置脚本
tmp_path=/root/tools/t_sh/
### 存储节点上OSD盘挂载目录 所有节点统一成一个
declare -A blks_map=(["osd01"]="sdb" ["osd02"]="sdc" ["osd03"]="sdd" ["osd04"]="sde" ["osd05"]="sdf");
#osd_path=/osd
### ceph安装版本
ceph_release=jewel

### Openstack各组件的数据库密码，所有服务统一成一个
password=9b15318364bb66e1
### Pacemaker密码
password_ha_user=9b15318364bb66e1
### Mariadb数据库Root密码
password_galera_root=a263f6a89fa2
### Mongodb数据库Root密码
password_mongo_root=a263f6a89fa2
### Rabbitm密码
passsword_rabbitmq=9b15318364bb66e1
### Openstack admin用户密码
password_openstack_admin=9b15318364bb66e1
### Operation Log 操作日志
log_file=/var/log/ggcloud/operations.log

