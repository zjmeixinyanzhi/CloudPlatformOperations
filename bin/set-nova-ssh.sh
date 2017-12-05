#!/bin/sh
declare -A hypervisor_map=(["compute01"]="172.20.103.4" ["compute02"]="172.20.103.5" ["compute03"]="172.20.103.6" ["compute04"]="172.20.103.7" ["compute05"]="172.20.103.8" ["compute06"]="172.20.103.11" ["compute07"]="172.20.103.12" ["compute08"]="172.20.103.13" ["compute09"]="172.20.103.14" ["compute10"]="172.20.103.15" ["compute11"]="172.20.103.16");
for host in ${hypervisor_map[@]};
do
  ssh $host /bin/bash << EOF
  su - nova 
  whoami
EOF
done 
