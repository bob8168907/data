所有不是通过索引直接返回排序结果的排序都是filesort排序 通过索引排序
加大 max_length_for_sort_data的值  sort_buffer_size的值 排序区
or查询,对每一列添加索引  实际上对or的各个字段分别查询后的结果进行了union操作
使用REGEXP代替like
show status like 'Handler_read%' 查看索引情况
复合索引  运用到and 上  外键加索引 

ALTER TABLE zmemory_employee MAX_ROWS=1000000000; 
SHOW TABLE STATUS;
show variables like "tmpdir";
SELECT * FROM INFORMATION_SCHEMA.Columns WHERE table_name='zmemory_employee';
SELECT * FROM information_schema.columns WHERE column_name='employeeid';

use information_schema;
select * from columns where column_name='employeeid'; //通过字段名查表

show status like 'Com_%';  Com_select/Com_insert/Com_update/Com_delte 查看当前连接执行次数

INFORMATION_SCHEMA.SCHEMATA
INFORMATION_SCHEMA.TABLES
INFORMATION_SCHEMA.COLUMNS
INFORMATION_SCHEMA.STATISTICS
INFORMATION_SCHEMA.TRIGGERS
INFORMATION_SCHEMA.ROUTINES
用explain优化sql语句。
show variables like '%heap%';
select @@max_heap_table_size;

mysqld --romve 删除mysql服务
mysqld --install 安装mysql服务
mysqld --initialize 一定要初始化
net start mysql

内存表的表定义是存放在磁盘上的，扩展名为.frm， 所以重启不会丢失。
内存表的数据是存放在内存中的，所以重启会丢失数据。
内存表使用一个固定的记录长度格式。
内存表不支持BLOB或TEXT列，设置varchar
内存表支持AUTO_INCREMENT列和对可包含NULL值的列的索引。内存表支持大于(>) 小于( <)操作
mysql重启后，主键、自增、索引仍然存在，只是数据丢失。
内存表表在所有客户端之间共享（就像其它任何非TEMPORARY表）。
MEMORY存储引擎执行HASH和BTREE索引。你可以通过添加一个如下所示的USING子句为给定的索引指定一个或另一个：


内存表使用哈希散列索引把数据保存在内存中，因此具有极快的速度.


SELECT * FROM INFORMATION_SCHEMA.TABLES i WHERE i.TABLE_SCHEMA='vsms' and  i.table_name like 'zmemory%';


SELECT * FROM INFORMATION_SCHEMA.TABLES i WHERE i.TABLE_SCHEMA='vsms' ;


alter table zmemory_employee row_format=Dynamic;