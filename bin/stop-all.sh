#!/bin/sh
### Stop controller cluster
pcs cluster stop --all
for i in 01 02 03; do ssh controller$i pcs cluster kill; done
pcs cluster stop --all
### Stop network cluster
ssh root@$network_host pcs cluster stop --all
for i in 01 02 03; do ssh network$i pcs cluster kill; done
ssh root@$network_host pcs cluster stop --all
### Poweroff

