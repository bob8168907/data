#!/bin/bash
#============================ 部署项目文件 ============================
#

#----- 分析需要上传的文件名，取当天生成的文件上传 -----
vsfPath=/home/vsf
configFilePath=${vsfPath}/project/conf/config.properties
#修改全局URL
URL=`cat ${configFilePath} | sed -n '/^url/{s/^.*url=//g;p;}' | tail -n 1`
mysqlPassword=L1i2a3n4g5!
#----- 部署前端程序 -----
deployExtJS(){
    echo '正在部署前端应用...'
    #解压到指定目录
    unzip -q -o ${vsfPath}/project/updatepack/VSMS.zip -d ${vsfPath}/project/
    if [ -d "${vsfPath}/project/vsms" ]
    then
      rm -rf ${vsfPath}/project/vsms
    fi
    #改名
    mv ${vsfPath}/project/VSMS ${vsfPath}/project/vsms
    echo '前端应用部署完成'
    #写日志
    echo "$(date '+%Y年%m月%d日 %H:%M:%S')         已部署新的ExtJs前端应用" >> ${vsfPath}/project/log/deploy.log
}

#----- 部署后端程序 -----
deployJava(){
    echo '正在部署后端应用...'
    if [ `ps -ef | grep ${vsfPath}/project/apache-tomcat-7.0.64 | grep -v grep | wc -l` = '1' ]  
    then  
        service tomcat7 stop
    fi
    rm -rf ${vsfPath}/project/apache-tomcat-7.0.64/wtpwebapps/vsmsserver
    unzip -q -o ${vsfPath}/project/updatepack/vsmsserver.zip -d ${vsfPath}/project/apache-tomcat-7.0.64/wtpwebapps/

    configPath=${vsfPath}/project/apache-tomcat-7.0.64/wtpwebapps/vsmsserver/WEB-INF/classes
    crossDomain=`cat ${configFilePath} | sed -n '/^crossdomain/{s/^.*crossdomain=//g;p;}' | tail -n 1`
    corsURL=${URL}':8080,'${URL}','${crossDomain}':8080,'${crossDomain}
    appURL=${URL}':8080'
    mybatislogPath=${vsfPath}'/project/log/'
    pdffontPath='/usr/share/fonts/winFonts/YAHEI.CONSOLAS.1.12.TTF'
    pdflogoPath=${vsfPath}'/project/apache-tomcat-7.0.64/wtpwebapps/vsmsserver/vsms/quotation/quot.png'
    templateFileName=`cat ${configFilePath} | sed -n '/^templatefilename/{s/^.*templatefilename=//g;p;}' | tail -n 1`
    templatePath=${vsfPath}'/project/apache-tomcat-7.0.64/wtpwebapps/vsmsserver/vsms/quotation/'${templateFileName}
    dbbackupPath=${vsfPath}'/project/dbbackup/'
    userLimit=`cat ${configFilePath} | sed -n '/^userlimit/{s/^.*userlimit=//g;p;}' | tail -n 1`
    expirationTime=`cat ${configFilePath} | sed -n '/^expirationtime/{s/^.*expirationtime=//g;p;}' | tail -n 1`
    log4jPath=${vsfPath}'/project/log/vsmsserver.log'

    #修改web.xml
    sed -i 's#http://localhost:1481,http://www.ql-crm.com:8080#'${corsURL}'#' ${vsfPath}/project/apache-tomcat-7.0.64/wtpwebapps/vsmsserver/WEB-INF/web.xml
    #修改config.properties
    sed -i -r 's#(^web_app_url\s*=)[^&]*#\1'${appURL}'#' ${configPath}/config.properties
    sed -i -r 's#(^dir_mybatis_log\s*=)[^&]*#\1'${mybatislogPath}'#' ${configPath}/config.properties
    sed -i -r 's#(^pdf_font\s*=)[^&]*#\1'${pdffontPath}'#' ${configPath}/config.properties
    sed -i -r 's#(^pdf_logo\s*=)[^&]*#\1'${pdflogoPath}'#' ${configPath}/config.properties
    sed -i -r 's#(^template_path\s*=)[^&]*#\1'${templatePath}'#' ${configPath}/config.properties
    sed -i -r 's#(^dbbackup_path\s*=)[^&]*#\1'${dbbackupPath}'#' ${configPath}/config.properties
    sed -i -r 's#(^userlimit\s*=)[^&]*#\1'${userLimit}'#' ${configPath}/config.properties
    sed -i -r 's#(^expirationtime\s*=)[^&]*#\1'${expirationTime}'#' ${configPath}/config.properties
    #修改dbconfig.properties
    sed -i -r 's#(^password\s*:)[^&]*#\1'${mysqlPassword}'#' ${configPath}/dbconfig.properties
    #修改log4j.properties
    sed -i -r 's#(^log4j.appender.A.File\s*=)[^&]*#\1'${log4jPath}'#' ${configPath}/log4j.properties
    changeDirOwner
    service tomcat7 start
    echo '后端应用部署完成'
    #写日志
    echo "$(date '+%Y年%m月%d日 %H:%M:%S')         已部署新的Java后端应用" >> ${vsfPath}/project/log/deploy.log
}

#----- 清理工作 -----
clearUselessDir(){
    if [ -d ${vsfPath}'/project/__MACOSX' ]
    then
        rm -rf ${vsfPath}/project/__MACOSX
    fi
}

#----- 目录权限修改 -----
changeDirOwner(){
    chown -R vsf:vsf_group ${vsfPath}/
}

#----- 入口 -----
#传入参数 1或者js：更新前端
#传入参数 2或者java: 更新后端
main(){
    if [ $1 = '1' ] || [ $1 = 'js' ]
    then
        deployExtJS
        clearUselessDir
    elif [ $1 = '2' ] || [ $1 = 'java' ]
    then
        deployJava
    else
        exit 1
    fi
}
main $1
