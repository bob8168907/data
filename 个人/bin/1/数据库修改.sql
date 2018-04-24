#################################################################
 truncate emptargetdef;
insert into emptargetdef(id,targetname,targetnameen,iseditor) values 
 (1,'任务金额','Target amount',0),
 (2,'预测金额','Forecast amount',0),
 (3,'接单率','Closing rate',0),
 (4,'新增客户','Add new customers',0),
 (5,'客户拜访','Visit Customers',0),
 (6,'新增机会(数量)','Add neww Opp. (Number)',0),
 (7,'新增机会(金额)','Add new Opp. (Amount)',0),
 (8,'合同金额','Order amount',0),
 (9,'发货金额','Shipment amount',0),
 (10,'毛利率','Gross profit rate',0),
 (11,'回款周期','Return period',1),
 (12,'万元费用支出','Ten thousand yuan expense',1);
 
update emptarget e set e.targetmoney=e.targetmoney*10000,e.targetmoneyminor=e.targetmoneyminor*1000;


alter table customtime add startingmonth int(10)  COMMENT '起始月';



DROP TABLE IF EXISTS `managedef`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `managedef` (
  `id` int(10) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `depid` int(10) DEFAULT NULL COMMENT '部门id',
  `employeeid` int(10) DEFAULT NULL COMMENT '员工id',
  `type` smallint(5) DEFAULT NULL COMMENT '1.需要排名的部门,2.需要排名的员工',
  `importreferid` varchar(200) DEFAULT NULL COMMENT '导入引用id',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COMMENT='管理配置表';



alter table abilitystat add faranchiseid int(10) comment '代理商id' AFTER employeeid ;
alter table snap_log add log_time datetime comment '插入时间';

alter table optrealsnap add isdelete int(10)  comment '是否删除' DEFAULT 1;
alter table optestimatesnap add isdelete int(10) comment '是否删除' DEFAULT 1;
alter table optstageupdatesnap add faranchiseid int(10) comment '机会代理商id' AFTER ownerid;