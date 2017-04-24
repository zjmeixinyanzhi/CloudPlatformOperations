#!/bin/sh
IS_ERR=$(ceph health|grep ERR|wc -l)
echo "[INFO] Ceph health is $(ceph health)"
if [ $IS_ERR = "0" ];then
  exit 0
else
  exit 127;
fi
