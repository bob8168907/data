#!/bin/bash　


 mysqldump -uroot -p123 vsms -R -E -d -t>E:/1/存储过程和函数.sql
 echo "" > E:/vsms/documents/mysql/空库.sql
 echo "" > E:/vsms/documents/mysql/测试.sql
 echo "" > E:/vsms/documents/动态12月库/201701.sql
 echo "" > E:/vsms/documents/动态12月库/201702.sql
 echo "" > E:/vsms/documents/动态12月库/201703.sql
 echo "" > E:/vsms/documents/动态12月库/201704.sql
 echo "" > E:/vsms/documents/动态12月库/201705.sql
 echo "" > E:/vsms/documents/动态12月库/201706.sql
 echo "" > E:/vsms/documents/动态12月库/201707.sql
 echo "" > E:/vsms/documents/动态12月库/201708.sql
 echo "" > E:/vsms/documents/动态12月库/201709.sql
 echo "" > E:/vsms/documents/动态12月库/201710.sql
 echo "" > E:/vsms/documents/动态12月库/201711.sql
 echo "" > E:/vsms/documents/动态12月库/201712.sql
 echo "" > E:/vsms/documents/mysql/存储过程和函数.sql



 cat E:/1/空库.sql E:/1/存储过程和函数.sql>> E:/vsms/documents/mysql/空库.sql
 cat E:/1/测试.sql E:/1/存储过程和函数.sql>> E:/vsms/documents/mysql/测试.sql
 cat E:/1/201701.sql E:/1/存储过程和函数.sql>> E:/vsms/documents/动态12月库/201701.sql
 cat E:/1/201702.sql E:/1/存储过程和函数.sql>> E:/vsms/documents/动态12月库/201702.sql
 cat E:/1/201703.sql E:/1/存储过程和函数.sql>> E:/vsms/documents/动态12月库/201703.sql
 cat E:/1/201704.sql E:/1/存储过程和函数.sql>> E:/vsms/documents/动态12月库/201704.sql
 cat E:/1/201705.sql E:/1/存储过程和函数.sql>> E:/vsms/documents/动态12月库/201705.sql
 cat E:/1/201706.sql E:/1/存储过程和函数.sql>> E:/vsms/documents/动态12月库/201706.sql
 cat E:/1/201707.sql E:/1/存储过程和函数.sql>> E:/vsms/documents/动态12月库/201707.sql
 cat E:/1/201708.sql E:/1/存储过程和函数.sql>> E:/vsms/documents/动态12月库/201708.sql
 cat E:/1/201709.sql E:/1/存储过程和函数.sql>> E:/vsms/documents/动态12月库/201709.sql
 cat E:/1/201710.sql E:/1/存储过程和函数.sql>> E:/vsms/documents/动态12月库/201710.sql
 cat E:/1/201711.sql E:/1/存储过程和函数.sql>> E:/vsms/documents/动态12月库/201711.sql
 cat E:/1/201712.sql E:/1/存储过程和函数.sql>> E:/vsms/documents/动态12月库/201712.sql
 cat E:/1/存储过程和函数.sql>> E:/vsms/documents/mysql/存储过程和函数.sql


 echo '合并成功'