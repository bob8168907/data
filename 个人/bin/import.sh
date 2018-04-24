#!/bin/bash　　

HOSTNAME="localhost"                                           #数据库信息
PORT="3306"
USERNAME="root"
PASSWORD="L1i2a3n4g5"

DBNAME="vsms" 
FILENAME1="E:/vsms/documents/mysql/测试.sql"
FILENAME2="E:/vsms/documents/mysql/2.sql"

mysql -uroot -pL1i2a3n4g5  vsms  < ${FILENAME1}