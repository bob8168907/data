unix 为大厂商的硬件配套使用
linux  类unix,一般指GNU套件加上linux内核

选择 Ubuntu

发行分支
Debian
    Debian Ubuntu
SlackWare
    OpenSUSE
RedHat
    RedHat、Fedora、CentOS
在linux加上套件 产生的系统

chmod man / -R
chown
chgrp
touch
ls -alh  ls -al 
mkdir    rm -r ./project   rm -r ./project/*
pwd
mv 移动 重命名 mv aa ./project 到某个文件夹 mv aa bb重命名 cp 复制 cp -rf home/ben/html /home/tomcat8.0.38/webapps/hedongli/ 复制文件夹
.bashrc .profile
sudo 管理员执行 more 开头显示,  less 末尾显示  
链接 inode号唯一   ln 硬链接  ln软链接  ls -i查看inode号

nano vim more less cat  cat bb > cc 覆盖  >> 追加  cat(数据流重定向)

vim v命令是选择  y复制 p粘贴 1g到哪里行 gg最后一行
u 撤销  
解压缩
tar
zip、unzip  
gz解压算法 mk压缩算法  
压缩 tar -czf ben.tar.gz ./ben
解压 tar -zxvf ben.tar.gz 
df 查看 
df -h
sudo poweroff/reboot   | 管道
管道命令 grep
ps -ef 进程的详细信息   ps -ef |grep tomcat 
cut、sort、uniq、wc 统计  管道命令
ps -ef |grep tomcat  查看进程
top 查看进程  htop(yum 安装 htop)
service xxx start/stop/restart

VMware

fdisk -l 查看分区
fdisk /dev/xvdb1(磁盘名称可能不一致), n,p,1,w
ext3格式化
mkfs.ext3 /dev/xvdb1
mount /dev/xvdb1 /home/vsf
/dev/xvdb1 /home/vsf ext3 defaults 0 0

yum update 更新yum  可配置阿里云yum   yum upgrade
安装 ssh-open server 本地连接 ip addr

配置服务器
1.分区格式化
2.安装ssh服务, 
3.yum 改为阿里云镜像,yum upgrade 更新系统
4.安装相应软件
5.部署项目





crontab -l 定时任务
crontab -e 编辑定时任务
autoclean autoremove

type mysql / whereis ls 