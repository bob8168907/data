#!/bin/bash
#============================ 安装软件 ============================
# 注意事项：
# 使用管理员权限执行
#

#目录路径
vsfPath=/home/vsf
configFilePath=${vsfPath}/project/conf/cus1_config.properties
#修改全局URL
URL=`cat ${configFilePath} | sed -n '/^url/{s/^.*url=//g;p;}' | tail -n 1`
mysqlPassword=L1i2a3n4g5!

#----- 目录权限修改 -----
changeDirOwner(){
    chown -R vsf:vsf_group ${vsfPath}/
}

#----- 部署前端程序 -----
deployExtJS(){
    echo '正在部署前端应用(客户试用)...'
    #解压到指定目录
    unzip -q -o ${vsfPath}/project/updatepack/VSMS.zip -d ${vsfPath}/project/cuvsms1/
    if [ -d "${vsfPath}/project/cuvsms1/vsms" ]
    then
      rm -rf ${vsfPath}/project/cuvsms1/vsms
    fi
    #改名
    mv ${vsfPath}/project/cuvsms1/VSMS ${vsfPath}/project/cuvsms1/vsms
    appURL='appURL:"'${URL}':8081/vsmsserver"'
    #替换URL
    sed -i 's#appURL:"http://localhost:8080/vsmsserver"#'${appURL}'#' ${vsfPath}/project/cuvsms1/vsms/crisp-en/app.js
    sed -i 's#appURL:"http://localhost:8080/vsmsserver"#'${appURL}'#' ${vsfPath}/project/cuvsms1/vsms/crisp-zh_CN/app.js
    echo '前端应用(客户试用)部署完成'
    #写日志
    echo "$(date '+%Y年%m月%d日 %H:%M:%S')         已部署新的ExtJs前端应用" >> ${vsfPath}/project/log/cus1_deploy.log
}

#----- 部署后端程序 -----
deployJava(){
    echo '正在部署后端应用(客户试用)...'
    if [ `ps -ef | grep ${vsfPath}/project/apache-tomcat-cuapp1/apache-tomcat-7.0.64 | grep -v grep | wc -l` = '1' ]  
    then  
        service tomcat7cus1 stop
    fi
    rm -rf ${vsfPath}/project/apache-tomcat-cuapp1/apache-tomcat-7.0.64/wtpwebapps/vsmsserver
    unzip -q -o ${vsfPath}/project/updatepack/vsmsserver.zip -d ${vsfPath}/project/apache-tomcat-cuapp1/apache-tomcat-7.0.64/wtpwebapps/

    configPath=${vsfPath}/project/apache-tomcat-cuapp1/apache-tomcat-7.0.64/wtpwebapps/vsmsserver/WEB-INF/classes
    crossDomain=`cat ${configFilePath} | sed -n '/^crossdomain/{s/^.*crossdomain=//g;p;}' | tail -n 1`
    corsURL=${URL}':8081,'${URL}','${crossDomain}':8081,'${crossDomain}
    appURL=${URL}':8081'
    mybatislogPath=${vsfPath}'/project/apache-tomcat-cuapp1/'
    pdffontPath='/usr/share/fonts/winFonts/YAHEI.CONSOLAS.1.12.TTF'
    pdflogoPath=${vsfPath}'/project/apache-tomcat-cuapp1/apache-tomcat-7.0.64/wtpwebapps/vsmsserver/vsms/quotation/quot.png'
    templateFileName=`cat ${configFilePath} | sed -n '/^templatefilename/{s/^.*templatefilename=//g;p;}' | tail -n 1`
    templatePath=${vsfPath}'/project/apache-tomcat-cuapp1/apache-tomcat-7.0.64/wtpwebapps/vsmsserver/vsms/quotation/'${templateFileName}
    dbbackupPath=${vsfPath}'/project/dbbackup/cus1/'
    userLimit='MA=='
    expirationTime='MA=='
    log4jPath=${vsfPath}'/project/apache-tomcat-cuapp1/vsmsserver.log'

    #修改web.xml
    sed -i 's#http://localhost:1481,http://www.ql-crm.com:8080#'${corsURL}'#' ${vsfPath}/project/apache-tomcat-cuapp1/apache-tomcat-7.0.64/wtpwebapps/vsmsserver/WEB-INF/web.xml
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
    sed -i 's#vsms#cuvsms1#g' ${configPath}/dbconfig.properties
    #修改log4j.properties
    sed -i -r 's#(^log4j.appender.A.File\s*=)[^&]*#\1'${log4jPath}'#' ${configPath}/log4j.properties
    changeDirOwner
    service tomcat7cus1 start
    echo '后端应用(客户试用)部署完成'
    #写日志
    echo "$(date '+%Y年%m月%d日 %H:%M:%S')         已部署新的Java后端应用" >> ${vsfPath}/project/log/cus1_deploy.log
}

#----- 清理工作 -----
clearUselessDir(){
    if [ -d ${vsfPath}'/project/cuvsms1/__MACOSX' ]
    then
        rm -rf ${vsfPath}/project/cuvsms1/__MACOSX
    fi
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