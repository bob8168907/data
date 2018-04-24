merge表 
不支持事务,被淘汰了。

分区
不支持 MERGE存储引擎,FEDERATED存储引擎,CSV存储引擎,不能有外键的InnoDB存储引擎,
不支持 InnoDB不支持使用多个磁盘进行子分区。（目前仅支持此功能 MyISAM。）
ALTER TABLE ... OPTIMIZE PARTITION对使用InnoDB 存储引擎的分区表无法正常工作

不要不指定任何引擎 的任何分区或子分区
指定所有分区或子分区 的引擎

分区表达式中只允许下表所示的MySQL函数。
时间,绝对值,取模,

也就说分区字段中有主键或者唯一索引的列，那么所有主键列和唯一索引列都必须包含进来，对于为什么这样解决，引用别人的说法：为了确保主键的效率。否则同一主键区的东西一个在Ａ分区，一个在Ｂ分区，显然会比较麻烦。

4种类型
1.范围分区 RANGE
PARTITION BY RANGE (store_id) (
    PARTITION p0 VALUES LESS THAN (6),
    PARTITION p1 VALUES LESS THAN (11),
    PARTITION p2 VALUES LESS THAN (16),
    PARTITION p3 VALUES LESS THAN MAXVALUE
);  提供的所有值都大于明确指定的最高值：不然报错
2.列表分区 LIST
PARTITION BY LIST(store_id) (
    PARTITION pNorth VALUES IN (3,5,6,9,17),
    PARTITION pEast VALUES IN (1,2,10,11,19,20),
    PARTITION pWest VALUES IN (4,12,13,14,18),
    PARTITION pCentral VALUES IN (7,8,15,16)
);
3.列分区   范围列分区  列表列分区
3.HASH分区 HASH
4.KEY分区 KEY

ALTER TABLE employees TRUNCATE PARTITION p0 高效删除分区
ALTER TABLE ... ADD PARTITION  新增分区
INSERT IGNORE INTO 忽略错误插入

一个月一个分区 使用列表分区 按月新增分区
子分区



非事务性存储引擎的表 MyISAM 表级锁
事务性存储引擎 InndDB

获取错误  使用远程连接表
