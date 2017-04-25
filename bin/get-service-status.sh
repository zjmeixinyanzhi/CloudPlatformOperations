#!/bin/sh
ssh $1 systemctl status $2 |grep Active:|grep running|wc -l
