#!/bin/sh
for i in 01 02 03; do 
  echo controller$i
  for j in $@; do
    echo "  "$j
    ssh controller$i systemctl status $j |grep Active:
    systemctl status mariadb |grep Active:|grep running|wc -l 
  done
done
