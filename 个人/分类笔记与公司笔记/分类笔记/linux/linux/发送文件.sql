https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html  官网下载   putty-0.69.tar.gz

解压zip发现里面有plink.exe pscp.exe psftp.exe putty.exe puttygen.exe puttytel.exe等可执行文件，
如果只是想要链接主机做一些操作那么使用putty.exe，要想要上传 下载文件，那么需要使用pscp.exe这个文件。 

进入C:\Program Files\PuTTY  
下执行 pscp命令查看是否安装成功

-q 安静模式，传输文件时什么也不显示，否则会显示出文件的传输进度

-P port 指定服务器的 SSH 端口，注意这个是大写字母 P，默认是 -P 22，如果主机的 SSH 端口就是 22，就不用指定了

-l user 指定以哪个用户的身份登录主机，用户名称也可以和主机名称写在一起，用@分割开，比如：username@server

-pw passwd 指定登录时所用的口令为：passwd

-C 表示允许压缩传输，提高传输速度

1.查看Linux 是否启动 sshd服务
systemctl status sshd.service

2.如果没有启动，则需要启动该服务：
systemctl start sshd.service

3.重启 sshd 服务：
systemctl restart sshd.service

4.设置服务开启自启
systemctl enable sshd.service

向远程Linux发送文件
执行 ：pscp E:\work\ben\target\ben.jar root@120.78.87.5:/home
向window发送文件
pscp root@120.76.137.194:/home/love.png E:/pic/

java -jar -Dserver.port=9999 boot.jar

 arping -c 3 -f -D 120.77.252.12 查看端口是否被占用

120.77.252.12 返回空，说明这个IP地址没有被局域网占用。
120.77.252.12 返回1，说明这个IP地址已经被占用，并且收到回复可以看到绑定该IP的终端的mac地址。


pscp E:\work\ben\target\ben.jar root@119.23.228.157:/home