yum快速安装mysql

新增yum源

rpm -Uvh http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm

查看可用的mysql版本（直接略过）

yum repolist enabled | grep "mysql.*-community.*"

导入

yum -y install mysql-community-server

加入开机启动

systemctl enable mysqld

启动mysql

systemctl start mysqld

配置初始信息

mysql_secure_installation

登录mysql -uroot -p

show variables like '%skip_networking%';  查看是否能远程连接


#将host设置为%表示任何ip都能连接mysql，当然您也可以将host指定为某个ip

     update user set host='%' where user='root' and host='localhost';

     flush privileges;        #刷新权限表，使配置生效

     然后我们就能远程连接我们的mysql了。

3、如果您想关闭远程连接，恢复mysql的默认设置（只能本地连接），您可以通过以下步骤操作：

     use mysql                #打开mysql数据库

     #将host设置为localhost表示只能本地连接mysql

     update user set host='localhost' where user='root';

     flush privileges;        #刷新权限表，使配置生效

备注：您也可以添加一个用户名为yuancheng，密码为123，权限为%（表示任意ip都能连接）的远程连接用户。命令参考如下：

     grant all on *.* to 'yuancheng'@'%' identified by '123';

     flush privileges;

UPDATE user SET password=PASSWORD("123456") WHERE user='root'; 修改密码

GRANT ALL PRIVILEGES ON *.* TO 'root'@'%'IDENTIFIED BY '123456' WITH GRANT OPTION;