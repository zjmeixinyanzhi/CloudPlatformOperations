#!/bin/sh
for host in $(cat ./hosts/online_vm.txt)
do
  echo -e "\033[34m------$host------ \033[0m"  
  ssh-copy-id root@$host 
done
