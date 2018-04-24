windows kill进程
tasklist /fi "imagename eq nginx.EXE"  查看进程tasklist tasklist /fi "imagename eq nginx.EXE" 
taskkill /fi "imagename eq nginx.EXE" /f
linux命令大全    chmod u+x *.sh 赋权限
发送文件 pscp E:\work\git\ben\html root@120.78.87.5:/home 文件  文件夹 pscp -r D:\work_software\apache-tomcat-8.5.24 root@119.23.228.157:/home/
\cp -rf /home/ben/html /home/tomcat8.0.38/webapps/hedongli 复制文件夹
进入这个文件夹 然后用命令 rm  -rf  *

pscp -r D:\idea\qkl2\ root@120.78.87.5:/home/apache-tomcat-8.5.24/webapps/ROOT

\cp -rf /home/apache-tomcat-8.5.24/webapps/qukuailian /home/apache-tomcat-8.5.24/webapps/ROOT

cp -r /home/apache-tomcat-8.5.24/webapps/qkl2/. /home/apache-tomcat-8.5.24/webapps/ROOT

sudo find / -name *tomcat* 查找文件
rpm -ql tomcat | cat -n  查看tomcat所有目录
rpm -qa|grep -i mysql 查看是否安装mysql
find / -name mysql 查找Mysql
pwd 当前目录
tail -f catalina.out 查看tomcat日志
ps -ef|grep java 查看进程  ps -ef|grep tomcat 查看tomcat / netstat -anp|grep 80 查看端口占用  kill -9 324  杀进程
tail -f catalina.out 查看  ctrl+c 退出
> filename 清除文件内容  shutdown -s -t 7200 定时关机
docker
1.更新
yum update 更新yum  可配置阿里云yum
2.安装docker 
yum -y install docker
3.开启服务
service docker start 
4.配置阿里云镜像加速器
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://pl01ql34.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
5.常用命令
  docker ps 进程 
  docker images 镜像
  docker ps -a 所有容器
  docker rm -f (id/name) 删除容器/镜像 docker container prune 删除未启用的容器
  docker pull [选项] [Docker Registry地址]<仓库名>:<标签>  //若不给地址,则是官方
  docker run -i -t ubuntu:15.10 /bin/bash 进入容器
  mkdir -p ~/home/nginx/www ~/home/nginx/logs ~/home/nginx/conf 创建文件 ~/表示root  mkdir -p /home/nginx/www /home/nginx/logs /home/nginx/conf
  docker pull nginx
  docker attach d48b21a7e439 进入一个容器

   docker run --name mysql -v /home/erikxu/mysql:/var/lib/mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123 -d mysql:latest
   docker run --name mongo -v /home/erikxu/mongo:/data/db -p 27017:27017 -d mongo:latest
   docker run --name redis -d -p 6379:6379 redis
   docker run --hostname rabbit-host --name rabbit -d -p 5672:5672 -p 15672:15672 rabbitmq:management
   docker run --name nginx -p 80:80 -v /home/erikxu/nginx/nginx.conf:/etc/nginx/nginx.conf:ro -d nginx
   docker run --name eureka -d -p 8761:8761 springcloud/eureka
   docker run -d -p 8081:8080 docker.io/tomcat 


   docker exec -it tomcat /bin/bash 进入一个容器 docker exec -it 7db40eec8f43  /bin/bash
   docker exec -it redis /bin/bash 进入一个容器

   docker cp DemoOne.war container2:tomcat/webapps //复制文件  docker cp -L /home/ben/html 0a389ff52c90:/usr/local/tomcat/webapps //复制文件夹

   cp /home/ben.jar redis:/ben.jar

   docker tag 21b6e55f4e76 bob8168907/21b6e55f4e76
   docker push bob8168907/21b6e55f4e76
   docker search bob8168907
   自动构建
   docker run -d -p 5000:5000 --restart=always --name registry registry 总是使用官方镜像


   git pull origin html:html
   mvn clean package  -Dmaven.test.skip=true 不测试打包
   yum install coreutils  支持后台挂载
   docker cp -L /home/ben/vue-ben/dist 0a389ff52c90:/usr/local/tomcat/webapps


git remote set-url origin https://github.com/bob8168907/ben.git
git clone https://github.com/bob8168907/ben.git



docker cp  /home/vsmsserver.war e467115038af:/usr/local/tomcat/webapps


docker exec -it 24d2c72bbb3f /bin/bash



pscp -r  C:\Users\ben\Desktop\apache-tomcat-7.0.64 root@120.78.87.5:/home


pscp  D:\work_software\apache-tomcat-8.0.38-windows-x64\tomcat8.0.38\conf\server.xml root@120.78.87.5:/home

容器添加vim apt-get update 


npm install yarn -g 

yarn config set registry https://registry.npm.taobao.org



pscp -r D:\work_software\apache-tomcat-8.0.38-windows-x64\tomcat8.0.38 root@120.78.87.5:/home/tomcat
cp -rf home/ben/html /home/tomcat8.0.38/webapps/hedongli/
chmod u+x *.sh


cp /home/ben.jar redis:/ben.jar



pscp E:\work\git\ben\html root@120.78.87.5:/home/tomcat8.0.38/webapps/hedongli/


\cp -rf /home/ben/html /home/tomcat8.0.38/webapps/html

:su 使用root账号密码