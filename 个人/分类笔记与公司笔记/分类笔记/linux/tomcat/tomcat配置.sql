1、yum -y install tomcat  执行命令后，会帮你把jdk也安装好

2、tomcat安装目录：/var/lib/tomcat/

3、tomcat配置目录：/etc/tomcat/

4、启动tomcat：service tomcat start

5、访问下：curl 127.0.0.1:8080（安装目录是个空文件夹，所以访问时，没有任何内容返回，这是正常的）

    远程访问地址：http://ip:8080（ip是你购买的云服务器的公网ip）

6、部署一个项目试试

    第一步：通过前面安装的svn上传一个项目war包，然后checkout出来

        checkout命令：svn checkout svn://127.0.0.1/llj（会提示你输入用户信息的，看着来就行，很简单）

    第二步：将war包拷贝到tomcat安装目录/var/lib/tomcat/webapps下

        拷贝命令：cp llj/ROOT.war -d /var/lib/tomcat/webapps

    重启下tomcat，再访问。

7、修改下tomcat的端口试试

    vi /etc/tomcat/server.xml  找到8080端口，改为14802（14802是我本地喜欢用的一个端口）

8、重启下tomcat，用新端口访问下试试

    重启命令：service tomcat restart

    地址：http://ip:14802

9、上面自动安装的jdk是1.6的，你的项目可能需要更高版本的jdk

    查看可安装的jdk：yum list java*

    从上面的列表里选择一个版本即可，我要装的是1.7的

        命令：yum -y install java-1.7.0-openjdk*（后面的*号表示把jdk1.7相关的都安装了）

10、jdk的安装路径：/usr/lib/jvm/

11、打完收工

12、安装路径  /usr/share/tomcat


    ./startup.sh

4. 关闭firewalld， Centos默认的防火墙不是iptables，而是firewalld。所以需要关闭firewalld

  systemctl stop firewalld
    systemctl disable firewalld

5. 安装iptables，修改rules文件。

    1> 安装iptables 

  #先检查是否安装了iptables
    service iptables status
    #安装iptables
    yum install -y iptables
    #升级iptables
    yum update iptables 
    #安装iptables-services
    yum install iptables-services

    2> 修改启用iptables。再在iptables文件里再加上开放8080端口(tomcat)

          vim /etc/sysconfig/iptables，新安装的第一次打开里面是空的，粘贴上下面的内容

          iptables -A INPUT -p tcp --dport 8080 -j ACCEPT 这句的意义是开放8080端口。 

    # Firewall configuration written by system-config-firewall
    # Manual customization of this file is not recommended.
    *filter
    :INPUT ACCEPT [0:0]
    :FORWARD ACCEPT [0:0]
    :OUTPUT ACCEPT [0:0]
    -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    -A INPUT -p icmp -j ACCEPT
    -A INPUT -i lo -j ACCEPT
    -A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
    -A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
    -A INPUT -m state --state NEW -m tcp -p tcp --dport 3306 -j ACCEPT
    -A INPUT -m state --state NEW -m tcp -p tcp --dport 8080 -j ACCEPT
    -A INPUT -m state --state NEW -m tcp -p tcp --dport 8081 -j ACCEPT
    -A INPUT -j REJECT --reject-with icmp-host-prohibited
    -A FORWARD -j REJECT --reject-with icmp-host-prohibited
    COMMIT

          修改完保持退出。

    3> 开启iptables服务

    systemctl enable iptables.service    
    systemctl start iptables.service

6. 验证

    在浏览器输入http://127.0.0.1:8080/ 看到tomcat系统界面，说明安装成功！


    jar cvf vsmsserver.war */ .