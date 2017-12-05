#!/bin/bash
backup_dir="/var/lib/backups/mysql"
mkdir -p $backup_dir
filename="${backup_dir}/mysql-`hostname`-`eval date +%Y%m%d%H%M%S`.sql.gz"
# Dump the entire MySQL database
/usr/bin/mysqldump  -uroot -p$password_galera_root -h$virtual_ip --opt --all-databases | gzip > $filename
# Delete backups older than 10 days
find $backup_dir/*.sql.gz -ctime +10 -type f -delete
