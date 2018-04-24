#!/bin/bash
#============================ 从主服务器更新项目 ============================
#

vsfPath=/home/vsf
ftpUrl='120.76.77.192'
ftpUser=vsf

#----- 校验并更新前端项目 -----
checkAndDownExtJS(){
    ssh-keygen -R ${ftpUrl}
    ssh-keyscan -H ${ftpUrl} >> /root/.ssh/known_hosts
    servermd5=`ssh ${ftpUser}@${ftpUrl} "md5sum /home/vsf/updatepack/VSMS.zip|cut -d ' ' -f1"`
    clientmd5=`md5sum /home/vsf/project/updatepack/VSMS.zip|cut -d ' ' -f1`
    if [ ${servermd5} != ${clientmd5} ]; then
        sftp ${ftpUser}@${ftpUrl} << EOF
        get ${vsfPath}/updatepack/VSMS.zip ${vsfPath}/project/updatepack/
        bye
EOF
        /bin/sh ${vsfPath}/project/bin/deployproject.sh 1
        /bin/sh ${vsfPath}/project/bin/cus1_deployproject.sh 1
    fi
}

#----- 校验并更新后端项目 -----
checkAndDownJava(){
    ssh-keygen -R ${ftpUrl}
    ssh-keyscan -H ${ftpUrl} >> /root/.ssh/known_hosts
    servermd5=`ssh ${ftpUser}@${ftpUrl} "md5sum /home/vsf/updatepack/vsmsserver.zip|cut -d ' ' -f1"`
    clientmd5=`md5sum /home/vsf/project/updatepack/vsmsserver.zip|cut -d ' ' -f1`
    if [ ${servermd5} != ${clientmd5} ]; then
        sftp ${ftpUser}@${ftpUrl} << EOF
        get ${vsfPath}/updatepack/vsmsserver.zip ${vsfPath}/project/updatepack/
        bye
EOF
        /bin/sh ${vsfPath}/project/bin/deployproject.sh 2
        /bin/sh ${vsfPath}/project/bin/cus1_deployproject.sh 2
    fi
}
checkAndDownExtJS
checkAndDownJava
