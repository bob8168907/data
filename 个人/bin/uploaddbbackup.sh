#!/bin/bash
#============================ 上传备份文件 ============================
#

#----- 分析需要上传的文件名，取当天生成的文件上传 -----
today=$(date +%Y%m%d)
vsfPath=/home/vsf
dbbackupPath=${vsfPath}/project/dbbackup
#配置文件路径
configFilePath=${vsfPath}/project/conf/config.properties
#获取配置文件里定义的上传文件夹名称
backupname=`cat ${configFilePath} | sed -n '/^backupname/{s/^.*backupname=//g;p;}' | tail -n 1`
ftpUrl='120.76.77.192'
ftpUser=vsf

#----- ftp上传 -----
upload(){
    if [ `ls -l ${dbbackupPath} | grep -c ${today}` = '0' ]; then
        exit 0
    fi
    ssh-keygen -R ${ftpUrl}
    ssh-keyscan -H ${ftpUrl} >> /root/.ssh/known_hosts
    ssh ${ftpUser}@${ftpUrl} "test -d ${dbbackupPath}/${backupname}"
    if [ $? -ne 0 ]; then
      # 目录不存在
      sftp ${ftpUser}@${ftpUrl} << EOF
      mkdir ${dbbackupPath}/${backupname}
      cd ${dbbackupPath}/${backupname}
      lcd ${dbbackupPath}
      mput *${today}*.sql
      bye
EOF
    else
      # 目录已经存在
      sftp ${ftpUser}@${ftpUrl} << EOF
      cd ${dbbackupPath}/${backupname}
      lcd ${dbbackupPath}
      mput *${today}*.sql
      bye
EOF
    fi
}
upload