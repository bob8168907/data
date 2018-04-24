#!/bin/bash
vsfPath=/home/vsf
backupurl="${vsfPath}/project/dbbackup"
now=$(date +%Y%m%d%H%M%S)
#配置文件路径
configFilePath=${vsfPath}/project/conf/config.properties
#获取配置文件里定义的上传文件夹名称
backupname=`cat ${configFilePath} | sed -n '/^backupname/{s/^.*backupname=//g;p;}' | tail -n 1`
file=$backupurl/${backupname}${now}.sql
mysqldump vsms > $file
