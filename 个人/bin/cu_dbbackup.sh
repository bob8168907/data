#!/bin/bash
backupurl='/home/vsf/project/dbbackup/cus1'
now=$(date +%Y%m%d%H%M%S)  
file=$backupurl/backup$now.sql
mysqldump cuvsms1 > $file
