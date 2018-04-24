-- --------------------------------------------------------
-- 主机:                           localhost
-- 服务器版本:                        5.7.15 - MySQL Community Server (GPL)
-- 服务器操作系统:                      Win64
-- HeidiSQL 版本:                  9.4.0.5125
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- 导出  过程 vsms.chart_optanalysis_industry_proc 结构
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `chart_optanalysis_industry_proc`(IN syscurrencyid varchar(20), IN startdate varchar(20),IN enddate varchar(20),IN classid int,IN employeesid varchar(4000),IN departsid varchar(4000),IN faranchiseid int)
BEGIN
    declare tmpdate varchar(20);
	declare startplanoverdate varchar(20);
    declare endplanoverdate varchar(20);
    declare tmpcount int;
    declare sqlstr longtext;
    declare sqlstringtotal longtext;
    declare sqlstring longtext;
    declare sqlheader longtext;
    declare sqlheadertotal longtext;
    declare flag TINYINT DEFAULT 0;
    declare totalvalue DECIMAL(14,2);
	declare statisticunits DECIMAL(14,2);
	
    set sqlstring = '';
	select `statisticunit` into statisticunits from currencyexchange where id = syscurrencyid;
    set sqlheader = 'insert into tmp_chart_optanalysis_industry_table(classname,classfield,classid,totalprice,percent) select IFNULL($classname$,\'Other\') as classname,\'$classfield$\',IFNULL($classid$,0),IFNULL(round(sum(optsd.converttotalprice)/$statisticunit$,2),0) as totalprice ,IFNULL(round(sum(optsd.converttotalprice)/$totalvalue$,2),0) as percent from (select distinct(opt.id) as optid, ind.industry, ind.id as indid, inds.industrysub, inds.id as indsid, convertopt.converttotalprice ';
    /* 创建结果集临时表*/
    create temporary table IF NOT EXISTS `tmp_chart_optanalysis_industry_table`
    (
        `id` int(10) NOT NULL AUTO_INCREMENT COMMENT 'ID',
        `classfield` varchar(20) NOT NULL COMMENT '类别字段名称',
        `classid` varchar(20) NOT NULL COMMENT '类别id',
        `classname` varchar(20) NOT NULL COMMENT '类别名称',
        `totalprice` DECIMAL(14,2) NOT NULL COMMENT '总金额',
        `percent` DECIMAL(14,2) NOT NULL COMMENT '占比',
        PRIMARY KEY (`id`)
    );
    truncate table `tmp_chart_optanalysis_industry_table`;

	/* 清理初始化参数 */
    if (employeesid is not null and CHAR_LENGTH(employeesid) = 0) then
		set employeesid = null;
    end if;
    if (departsid is not null and CHAR_LENGTH(departsid) = 0) then
		set departsid = null;
    end if;
    
    set tmpcount = 1;

    if CHAR_LENGTH(startdate) > 0 then
        /* 根据参数拼接where条件 */        
        set sqlstr = '$sqlheader$ ';
        set sqlstr = concat(sqlstr,'from customer as cus ');
        set sqlstr = concat(sqlstr,'left join opt on cus.id = opt.customerid ');        
        set sqlstr = concat(sqlstr,'left join employee emp on opt.ownerid = emp.depid left join (select
		  opt.id id,
		  if(',syscurrencyid,'=1,
		     if(opt.currencyid=1,
		        opt.totalprice,
		        opt.totalpriceminor*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2))),
		     if(opt.currencyid=2,
		        opt.totalpriceminor,
		        opt.totalprice*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2)))) converttotalprice,
		  if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) formula
		from opt
		left join currencyconvert cc
		  ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
		left join (select cast(if(',syscurrencyid,'=1,intoajformula,ajtoinformula) as DECIMAL(14,2)) formula  from currencyconvert ORDER BY id desc limit 1) lasc
		  ON 1=1) convertopt on opt.id=convertopt.id
		left join currencyexchange cue on cue.id = opt.currencyid ');
        set sqlstr = concat(sqlstr,'left join industry ind on cus.industryid = ind.id ');            
        set sqlstr = concat(sqlstr,'left join industrysub inds on cus.industrysubid = inds.id where opt.isdelete = 0 and opt.optstatus not in(3,4,5) ');            

        if (employeesid is not null and departsid is not null) then
            set sqlstr = concat(sqlstr,' and (opt.ownerid in (',employeesid,') or emp.depid in (',departsid,'))');
		else
			if employeesid is not null then
				set sqlstr = concat(sqlstr,' and (opt.ownerid in (',employeesid,'))');
			elseif departsid is not null then
				set sqlstr = concat(sqlstr, ' and emp.depid in (',departsid,')');
            end if;
        end if;

        if (faranchiseid is not null and faranchiseid > 0) then
			set sqlstr = concat(sqlstr, ' and opt.faranchiseid = ',faranchiseid);
        end if;

		set tmpdate = startdate;
		set startplanoverdate = tmpdate;
		set endplanoverdate = enddate;
        
		set sqlstr = concat(sqlstr, ' and opt.planoverdate between \'', startplanoverdate, '\' and \'', endplanoverdate, '\'');      

        /* 如果id为0,则查大类*/
        if classid = 0 then
			set sqlstringtotal = concat(sqlstr, ' ) as optsd');
			set sqlstring = concat(sqlstr, ' ) as optsd group by optsd.indid');
			set sqlheader = replace(sqlheader,'$classname$','optsd.industry');
            set sqlheader = replace(sqlheader,'$classfield$','industryid');
            set sqlheader = replace(sqlheader,'$classid$',' optsd.indid');
        /* 如果id大于0,查询指定industry的classid下的industrysub */
        elseif classid > 0 then
			set sqlstringtotal = concat(sqlstr, ' and cus.industryid = ', classid, ' ) as optsd');
            set sqlstring = concat(sqlstr, ' and cus.industryid = ', classid, ' ) as optsd group by optsd.indsid');
			set sqlheader = replace(sqlheader, '$classname$','optsd.industrysub');
            set sqlheader = replace(sqlheader,'$classfield$','industrysubid');
            set sqlheader = replace(sqlheader,'$classid$',' optsd.indsid');
        end if;

        /* 计算总值 */
        set sqlstringtotal = replace(sqlstringtotal,'$sqlheader$','select sum(optsd.converttotalprice) into @totalvalue from (select distinct(opt.id) as optid, convertopt.converttotalprice');
        set @stmt = sqlstringtotal; 
		PREPARE stmt FROM @stmt;
		EXECUTE stmt;
        set totalvalue = ifnull(@totalvalue,0);
       
        /* 将总值替换到insert into select语句里 */
		set sqlheader = replace(sqlheader, '$totalvalue$', totalvalue);
        /* 将sqlheader替换到sqlstring里的$sqlheader$参数 */
        set sqlstring = replace(sqlstring, '$sqlheader$', sqlheader);
        
        set sqlstring = replace(sqlstring,'$statisticunit$',statisticunits);
		set @stmt = sqlstring; 
		-- insert into debug(debug) values(sqlstring);
		PREPARE stmt FROM @stmt;
		EXECUTE stmt;        
		DEALLOCATE PREPARE stmt;
        select * from tmp_chart_optanalysis_industry_table;
	end if;
END//
DELIMITER ;

-- 导出  过程 vsms.chart_optanalysis_product_proc 结构
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `chart_optanalysis_product_proc`(IN syscurrencyid int, IN startdate varchar(20),IN enddate varchar(20),IN classid int,IN employeesid varchar(4000),IN departsid varchar(4000),IN faranchiseid int)
BEGIN
    declare tmpdate varchar(20);
	declare startplanoverdate varchar(20);
    declare endplanoverdate varchar(20);
    declare tmpcount int;
    declare sqlstr longtext;
    declare sqlstringtotal longtext;
    declare sqlstring longtext;
    declare sqlheader longtext;
    declare sqlheadertotal longtext;
    declare flag TINYINT DEFAULT 0;
    declare totalvalue DECIMAL(14,2);
	declare statisticunits DECIMAL(14,2);
	
    set sqlstring = '';
	select `statisticunit` into statisticunits from currencyexchange where id = syscurrencyid;
    set sqlheader = 'insert into tmp_chart_optanalysis_product_table(classname,classfield,classid,totalprice,percent) select IFNULL($classname$,\'Other\') as classname,\'$classfield$\',IFNULL($classid$,0),IFNULL(round(sum(oppsd.converttotalprice*oppsd.num*oppsd.discount)/$statisticunit$,2),0) as totalprice ,IFNULL(round(sum(oppsd.converttotalprice*oppsd.num*oppsd.discount)/$totalvalue$,2),0) as percent from (select distinct(opp.id) as optproid, prob.brandname, prob.id as probid, proc.classname, proc.id as procid, num, discount, convertoptproduct.converttotalprice ';
    /* 创建结果集临时表*/
    create temporary table IF NOT EXISTS `tmp_chart_optanalysis_product_table`
    (
        `id` int(10) NOT NULL AUTO_INCREMENT COMMENT 'ID',
		`classfield` varchar(20) NOT NULL COMMENT '类别字段名称',
        `classid` varchar(20) NOT NULL COMMENT '类别id',
        `classname` varchar(20) NOT NULL  COMMENT '类别名称',
        `totalprice` DECIMAL(14,2) NOT NULL COMMENT '总金额',
        `percent` DECIMAL(14,2) NOT NULL COMMENT '占比',
        PRIMARY KEY (`id`)
    );
    truncate table `tmp_chart_optanalysis_product_table`;

	/* 清理初始化参数 */
    if (employeesid is not null and CHAR_LENGTH(employeesid) = 0) then
		set employeesid = null;
    end if;
    if (departsid is not null and CHAR_LENGTH(departsid) = 0) then
		set departsid = null;
    end if;
    
    set tmpcount = 1;

    if CHAR_LENGTH(startdate) > 0 then
        /* 根据参数拼接where条件 */        
        set sqlstr = '$sqlheader$ ';
        set sqlstr = concat(sqlstr,'from optproduct as opp ');
        set sqlstr = concat(sqlstr,'left join opt on opp.optid = opt.id ');        
        set sqlstr = concat(sqlstr,'left join employee emp on opt.ownerid = emp.depid left join (select
		  optproduct.id id,
		  if(',syscurrencyid,'=1,
		     if(opt.currencyid=1,
		        optproduct.rmbprice,
		        optproduct.dollarprice*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2))),
		     if(opt.currencyid=2,
		        optproduct.dollarprice,
		        optproduct.rmbprice*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2)))) converttotalprice,
		  if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) formula
		from optproduct 
		left join opt
		  on optproduct.optid = opt.id
		left join currencyconvert cc
		  ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
		left join (select cast(if(',syscurrencyid,'=1,intoajformula,ajtoinformula) as DECIMAL(14,2)) formula  from currencyconvert ORDER BY id desc limit 1) lasc
		  ON 1=1) convertoptproduct on opp.id=convertoptproduct.id
		left join currencyexchange cue on cue.id = opt.currencyid ');
        set sqlstr = concat(sqlstr,'left join product pro on pro.id = opp.productid ');
        set sqlstr = concat(sqlstr,'left join productbrand prob on prob.id = pro.brandid ');
        set sqlstr = concat(sqlstr,'left join productclass proc on proc.id = pro.classid where opt.isdelete = 0 and opt.optstatus not in(3,4,5) ');            

        if (employeesid is not null and departsid is not null) then
            set sqlstr = concat(sqlstr,' and (opt.ownerid in (',employeesid,') or emp.depid in (',departsid,'))');
		else
			if employeesid is not null then
				set sqlstr = concat(sqlstr,' and (opt.ownerid in (',employeesid,'))');
			elseif departsid is not null then
				set sqlstr = concat(sqlstr, ' and emp.depid in (',departsid,')');
            end if;
        end if;

        if (faranchiseid is not null and faranchiseid > 0) then
			set sqlstr = concat(sqlstr, ' and opt.faranchiseid = ',faranchiseid);
        end if;

		set tmpdate = startdate;
		set startplanoverdate = tmpdate;
		set endplanoverdate = enddate;
        
		set sqlstr = concat(sqlstr, ' and opt.planoverdate between \'', startplanoverdate, '\' and \'', endplanoverdate, '\'');     

        /* 如果id为0,则查大类*/
        if classid = 0 then
			set sqlstringtotal = concat(sqlstr, ' ) as oppsd');
			set sqlstring = concat(sqlstr, ') as oppsd group by oppsd.probid');
			set sqlheader = replace(sqlheader,'$classname$','oppsd.brandname');
            set sqlheader = replace(sqlheader,'$classfield$','brandid');
            set sqlheader = replace(sqlheader,'$classid$',' oppsd.probid');
        /* 如果id大于0,查询指定industry的classid下的industrysub */
        elseif classid > 0 then
			set sqlstringtotal = concat(sqlstr, ' and pro.brandid = ', classid, ' ) as oppsd');
            set sqlstring = concat(sqlstr, ' and pro.brandid = ', classid, ') as oppsd group by oppsd.procid');
			set sqlheader = replace(sqlheader, '$classname$','oppsd.classname');
            set sqlheader = replace(sqlheader,'$classfield$','classid');
            set sqlheader = replace(sqlheader,'$classid$',' oppsd.procid');
        end if;

        /* 计算总值 */
        set sqlstringtotal = replace(sqlstringtotal,'$sqlheader$','select sum(oppsd.converttotalprice*oppsd.num*oppsd.discount) into @totalvalue from (select distinct(opp.id) as optproid, opp.num, opp.discount, convertoptproduct.converttotalprice ');
        set @stmt = sqlstringtotal; 
		PREPARE stmt FROM @stmt;
		EXECUTE stmt;
        set totalvalue = ifnull(@totalvalue,0);
       
        /* 将总值替换到insert into select语句里 */
		set sqlheader = replace(sqlheader, '$totalvalue$', totalvalue);
        /* 将sqlheader替换到sqlstring里的$sqlheader$参数 */
        set sqlstring = replace(sqlstring, '$sqlheader$', sqlheader);
        
        set sqlstring = replace(sqlstring,'$statisticunit$',statisticunits);
		set @stmt = sqlstring; 
		-- insert into debug(debug) values(sqlstring);
		PREPARE stmt FROM @stmt;
		EXECUTE stmt;        
		DEALLOCATE PREPARE stmt;
        select * from tmp_chart_optanalysis_product_table;
	end if;
END//
DELIMITER ;

-- 导出  过程 vsms.chart_optanalysis_region_proc 结构
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `chart_optanalysis_region_proc`(IN syscurrencyid int, IN startdate varchar(20),IN enddate varchar(20),IN classType varchar(20),IN classid int,IN employeesid varchar(4000),IN departsid varchar(4000),IN faranchiseid int)
BEGIN
    declare tmpdate varchar(20);
    declare startplanoverdate varchar(20);
    declare endplanoverdate varchar(20);
    declare tmpcount int;
    declare sqlstr longtext;
    declare sqlstringtotal longtext;
    declare sqlstring longtext;
    declare sqlheader longtext;
    declare sqlheadertotal longtext;
    declare flag TINYINT DEFAULT 0;
    declare totalvalue DECIMAL(14,2);
    declare statisticunits DECIMAL(14,2);
    
    set sqlstring = '';
    select `statisticunit` into statisticunits from currencyexchange where id = syscurrencyid;
    set sqlheader = 'insert into tmp_chart_optanalysis_region_table(classname,classfield,classid,totalprice,percent) select IFNULL($classname$,\'Other\') as classname,\'$classfield$\',IFNULL($classid$,0),IFNULL(round(sum(optsd.converttotalprice)/$statisticunit$,2),0) as totalprice ,IFNULL(round(sum(optsd.converttotalprice)/$totalvalue$,2),0) as percent from (select distinct(opt.id) as optid, coun.country, coun.id as counid, reg.region, reg.id as regid, pro.province, pro.id as proid, city.city, city.id as cityid, convertopt.converttotalprice ';
    /* 创建结果集临时表*/
    create temporary table IF NOT EXISTS `tmp_chart_optanalysis_region_table`
    (
        `id` int(10) NOT NULL AUTO_INCREMENT COMMENT 'ID',
        `classfield` varchar(20) NOT NULL COMMENT '类别字段名称',
        `classid` varchar(20) NOT NULL COMMENT '类别id',
        `classname` varchar(20) NOT NULL COMMENT '类别名称',
        `totalprice` DECIMAL(14,2) NOT NULL COMMENT '总金额',
        `percent` DECIMAL(14,2) NOT NULL COMMENT '占比',
        PRIMARY KEY (`id`)
    );
    truncate table `tmp_chart_optanalysis_region_table`;

    /* 清理初始化参数 */
    if (employeesid is not null and CHAR_LENGTH(employeesid) = 0) then
        set employeesid = null;
    end if;
    if (departsid is not null and CHAR_LENGTH(departsid) = 0) then
        set departsid = null;
    end if;
    
    set tmpcount = 1;

    if CHAR_LENGTH(startdate) > 0 then
        /* 根据参数拼接where条件 */        
        set sqlstr = '$sqlheader$ ';
        set sqlstr = concat(sqlstr,'from customer as cus ');
        set sqlstr = concat(sqlstr,'left join opt on cus.id = opt.customerid ');        
        set sqlstr = concat(sqlstr,'left join employee emp on opt.ownerid = emp.depid left join (select
          opt.id id,
          if(',syscurrencyid,'=1,
             if(opt.currencyid=1,
                opt.totalprice,
                opt.totalpriceminor*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2))),
             if(opt.currencyid=2,
                opt.totalpriceminor,
                opt.totalprice*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2)))) converttotalprice,
          if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) formula
        from opt
        left join currencyconvert cc
          ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
        left join (select cast(if(',syscurrencyid,'=1,intoajformula,ajtoinformula) as DECIMAL(14,2)) formula  from currencyconvert ORDER BY id desc limit 1) lasc
          ON 1=1) convertopt on opt.id=convertopt.id
        left join currencyexchange cue on cue.id = opt.currencyid ');
        set sqlstr = concat(sqlstr,'left join country coun on cus.countryid = coun.id ');
        set sqlstr = concat(sqlstr,'left join region reg on cus.regionid = reg.id ');            
        set sqlstr = concat(sqlstr,'left join province pro on cus.provinceid = pro.id ');            
        set sqlstr = concat(sqlstr,'left join city on cus.cityid = city.id where opt.isdelete = 0 and opt.optstatus not in(3,4,5) ');

        if (employeesid is not null and departsid is not null) then
            set sqlstr = concat(sqlstr,' and (opt.ownerid in (',employeesid,') or emp.depid in (',departsid,'))');
        else
            if employeesid is not null then
                set sqlstr = concat(sqlstr,' and (opt.ownerid in (',employeesid,'))');
            elseif departsid is not null then
                set sqlstr = concat(sqlstr, ' and emp.depid in (',departsid,')');
            end if;
        end if;

        if (faranchiseid is not null and faranchiseid > 0) then
            set sqlstr = concat(sqlstr, ' and opt.faranchiseid = ',faranchiseid);
        end if;

        set tmpdate = startdate;
        set startplanoverdate = tmpdate;
        set endplanoverdate = enddate;
        
        set sqlstr = concat(sqlstr, ' and opt.planoverdate between \'', startplanoverdate, '\' and \'', endplanoverdate, '\'');     


        /* 如果为empty,查询大类*/
        if classType = 'empty' then
            set sqlstringtotal = concat(sqlstr, ' ) as optsd');
            set sqlstring = concat(sqlstr, ' ) as optsd group by optsd.counid');
            set sqlheader = replace(sqlheader,'$classname$','optsd.country');
            set sqlheader = replace(sqlheader,'$classfield$','countryid');
            set sqlheader = replace(sqlheader,'$classid$','optsd.counid');
        /* 如果为country,查询指定country的classid下的region */
        elseif classType = 'country' then
            set sqlstringtotal = concat(sqlstr, ' and cus.countryid = ', classid, ' ) as optsd');
            set sqlstring = concat(sqlstr, ' and cus.countryid = ', classid, ' ) as optsd group by optsd.regid');
            set sqlheader = replace(sqlheader, '$classname$','optsd.region');
            set sqlheader = replace(sqlheader, '$classfield$','regionid');
            set sqlheader = replace(sqlheader, '$classid$','optsd.regid');
        /* 如果为region,查询指定region的classid下的province */
        elseif classType = 'region' then
            set sqlstringtotal = concat(sqlstr, ' and cus.regionid = ', classid, ' ) as optsd');
            set sqlstring = concat(sqlstr, ' and cus.regionid = ', classid, ' ) as optsd group by optsd.proid');
            set sqlheader = replace(sqlheader, '$classname$','optsd.province');
            set sqlheader = replace(sqlheader, '$classfield$','provinceid');
            set sqlheader = replace(sqlheader, '$classid$','optsd.proid');
        /* 如果为province,查询指定province的classid下的city */
        elseif classType = 'province' then
            set sqlstringtotal = concat(sqlstr, ' and cus.provinceid = ', classid, ' ) as optsd');
            set sqlstring = concat(sqlstr, ' and cus.provinceid = ', classid, ' ) as optsd group by optsd.cityid');
            set sqlheader = replace(sqlheader,'$classname$','optsd.city');
            set sqlheader = replace(sqlheader, '$classfield$','cityid');
            set sqlheader = replace(sqlheader, '$classid$','optsd.cityid');
        end if;

        /* 计算总值 */
        set sqlstringtotal = replace(sqlstringtotal,'$sqlheader$','select sum(optsd.converttotalprice) into @totalvalue from (select distinct(opt.id) as optid, convertopt.converttotalprice ');
        set @stmt = sqlstringtotal; 
        PREPARE stmt FROM @stmt;
        EXECUTE stmt;
        set totalvalue = ifnull(@totalvalue,0);
       
        /* 将总值替换到insert into select语句里 */
        set sqlheader = replace(sqlheader, '$totalvalue$', totalvalue);
        /* 将sqlheader替换到sqlstring里的$sqlheader$参数 */
        set sqlstring = replace(sqlstring, '$sqlheader$', sqlheader);
        
        set sqlstring = replace(sqlstring,'$statisticunit$',statisticunits);
        set @stmt = sqlstring; 
        -- insert into debug(debug) values(sqlstring);
        PREPARE stmt FROM @stmt;
        EXECUTE stmt;        
        DEALLOCATE PREPARE stmt;
        select * from tmp_chart_optanalysis_region_table;
    end if;
END//
DELIMITER ;

-- 导出  过程 vsms.chart_optsize_chart_proc 结构
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `chart_optsize_chart_proc`(IN syscurrencyid varchar(20),IN startdate varchar(20),IN enddate varchar(20),IN employeesid varchar(4000),IN departsid varchar(4000),IN faranchiseid int,IN isbigproject smallint,IN bigvalue DECIMAL(14,2))
BEGIN
    declare tmpdate varchar(20);
	declare startplanoverdate varchar(20);
    declare endplanoverdate varchar(20);
    declare tmpcount int;
    declare sqlstr longtext;
    declare sqlstring longtext;
    declare flag TINYINT DEFAULT 0;
    declare targetvalue DECIMAL(14,2);
    declare statisticunits DECIMAL(14,2);
    declare monthcount int;
	
    set sqlstring = '';
    select `statisticunit` into statisticunits from currencyexchange where id = syscurrencyid;
    /* 创建结果集临时表 */
    create temporary table IF NOT EXISTS `tmp_chart_optsize_chart_table`
    (
        `id` int(10) NOT NULL AUTO_INCREMENT COMMENT 'ID',
        `yearmonth` varchar(20) NOT NULL COMMENT '年/月',
        `percent10` DECIMAL(14,2) NOT NULL COMMENT '10%',
        `percent30` DECIMAL(14,2) NOT NULL COMMENT '30%',
        `percent50` DECIMAL(14,2) NOT NULL COMMENT '50%',
        `percent70` DECIMAL(14,2) NOT NULL COMMENT '70%',
        `percent90` DECIMAL(14,2) NOT NULL COMMENT '90%',
        `percent100` DECIMAL(14,2) NOT NULL COMMENT '100%',
        `targetvalue` DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '目标金额',
        `predictedvalue` DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '预测金额',
        `optprice` DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '有效金额',
        PRIMARY KEY (`id`)
    );
    truncate table `tmp_chart_optsize_chart_table`;

	/* 清理初始化参数 */
    if (employeesid is not null and CHAR_LENGTH(employeesid) = 0) then
		set employeesid = null;
    end if;
    if (departsid is not null and CHAR_LENGTH(departsid) = 0) then
		set departsid = null;
    end if;
    
    set tmpcount = 1;
    if CHAR_LENGTH(startdate) > 0 then
        /* 根据参数拼接where条件 */        
        set sqlstr = 'insert into tmp_chart_optsize_chart_table(percent10,percent30,percent50,percent70,percent90,percent100,targetvalue,yearmonth,optprice) ';
		set sqlstr = concat(sqlstr,'select ');
        set sqlstr = concat(sqlstr,'ifnull(round(sum(if(opt.stageid = 2,convertopt.converttotalprice,0.00))/$statisticunit$,2),0.00) as percent10, ');
        set sqlstr = concat(sqlstr,'ifnull(round(sum(if(opt.stageid = 3,convertopt.converttotalprice,0.00))/$statisticunit$,2),0.00) as percent30, ');            
        set sqlstr = concat(sqlstr,'ifnull(round(sum(if(opt.stageid = 4,convertopt.converttotalprice,0.00))/$statisticunit$,2),0.00) as percent50, ');            
        set sqlstr = concat(sqlstr,'ifnull(round(sum(if(opt.stageid = 5,convertopt.converttotalprice,0.00))/$statisticunit$,2),0.00) as percent70, ');            
        set sqlstr = concat(sqlstr,'ifnull(round(sum(if(opt.stageid = 6,convertopt.converttotalprice,0.00))/$statisticunit$,2),0.00) as percent90, ');            
        set sqlstr = concat(sqlstr,'ifnull(round(sum(if(opt.stageid = 7,convertopt.converttotalprice,0.00))/$statisticunit$,2),0.00) as percent100, ');            
        set sqlstr = concat(sqlstr,'$targetvalue$ as targetvalue, ');
        set sqlstr = concat(sqlstr,'$yearmonth$ as yearmonth, ');
        set sqlstr = concat(sqlstr,'ifnull(round(sum(if(opt.optstatus = 1,convertopt.converttotalprice*(case opt.stageid when 1 then 0 when 2 then 0.1 when 3 then 0.3 when 4 then 0.5 when 5 then 0.7 when 6 then 0.9 end)*(case opt.possibilityid when 1 then 0 when 2 then 0.2 when 3 then 0.25 when 4 then 0.3 when 5 then 0.5 when 6 then 0.8 end),0))/$statisticunit$,2),0.00) as optprice ');
        set sqlstr = concat(sqlstr,'from opt left join employee emp on opt.ownerid = emp.id left join (select
		  opt.id id,
		  if(',syscurrencyid,'=1,
		     if(opt.currencyid=1,
		        opt.totalprice,
		        opt.totalpriceminor*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2))),
		     if(opt.currencyid=2,
		        opt.totalpriceminor,
		        opt.totalprice*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2)))) converttotalprice,
		  if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) formula
		from opt
		left join currencyconvert cc
		  ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
		left join (select cast(if(',syscurrencyid,'=1,intoajformula,ajtoinformula) as DECIMAL(14,2)) formula  from currencyconvert ORDER BY id desc limit 1) lasc
		  ON 1=1) convertopt on opt.id=convertopt.id
		left join currencyexchange cue on cue.id = opt.currencyid where opt.isdelete = 0 and opt.optstatus not in(3,4,5) ');

        if (employeesid is not null and departsid is not null) then
            set sqlstr = concat(sqlstr,' and ( opt.ownerid in (',employeesid,') or emp.depid in (',departsid,'))');
		else
			if employeesid is not null then
				set sqlstr = concat(sqlstr,' and ( opt.ownerid in (',employeesid,'))');
			elseif departsid is not null then
				set sqlstr = concat(sqlstr, ' and emp.depid in (',departsid,')');
            end if;
        end if;

        if (faranchiseid is not null and faranchiseid > 0) then
			set sqlstr = concat(sqlstr, ' and opt.faranchiseid = ',faranchiseid);
        end if;

		if isbigproject = 1 then
			if (bigvalue is not null or bigvalue = 0) then
				set bigvalue = bigvalue * 10000;
				set sqlstr = concat(sqlstr, ' and opt.totalprice >= ',bigvalue);
			else
				set bigvalue = (select ifnull(bigoptprice*10000,0) from systemconfig where id = 1);
				set sqlstr = concat(sqlstr, ' and opt.totalprice >= ',bigvalue);
			end if;
		end if;
		set tmpdate = startdate;
		set monthcount = PERIOD_DIFF(date_format(enddate,'%Y%m'),date_format(startdate,'%Y%m'))+1;
        /* 取monthcount个月的日期 */
		while tmpcount <= monthcount do
			-- 如果大于1取下一个月的第1天
            if tmpcount > 1 then
				set tmpdate = DATE_ADD(tmpdate,interval -day(tmpdate)+1 day);
			    set tmpdate = DATE_ADD(tmpdate, interval 1 month);
            end if;

            set startplanoverdate = tmpdate;
            /* 取当月最后一天的日期 */
			if tmpcount < monthcount then
				set endplanoverdate = DATE_ADD(tmpdate, interval DAY(LAST_DAY(tmpdate)) - DAY(tmpdate) day);
			else
				set endplanoverdate = enddate;
            end if;

			set sqlstring = concat(sqlstr, ' and opt.planoverdate between \'', startplanoverdate, '\' and \'', endplanoverdate, '\'');
            /** 
             * 将$targetvalue$替换为目标金额
             * 将$yearmonth$替换为实际年月格式 
             * 
             */
            call chart_optsize_target_proc(syscurrencyid,employeesid,departsid,faranchiseid,startplanoverdate,targetvalue);

            set sqlstring = replace(sqlstring,'$targetvalue$',targetvalue);
            set sqlstring = replace(sqlstring,'$yearmonth$',date_format(startplanoverdate,'\'%Y/%m\''));
            set sqlstring = replace(sqlstring,'$statisticunit$',statisticunits);
			
            set @stmt = sqlstring;
            PREPARE stmt FROM @stmt;
			EXECUTE stmt;
			-- insert into debug(debug) values(sqlstring);
			
            set tmpcount = tmpcount + 1;
        end while;
		DEALLOCATE PREPARE stmt;
        select * from tmp_chart_optsize_chart_table;
	end if;
END//
DELIMITER ;

-- 导出  过程 vsms.chart_optsize_grid_proc 结构
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `chart_optsize_grid_proc`(IN syscurrencyid varchar(20), IN startdate varchar(20),IN enddate varchar(20),IN employeesid varchar(4000),IN departsid varchar(4000),IN faranchiseid int,IN bigvalue DECIMAL(14,2))
BEGIN
    declare tmpdate varchar(20);
    declare nowdate varchar(20);
	declare startplanoverdate varchar(20);
    declare endplanoverdate varchar(20);
    declare tmpcount int;
    declare sqlstr longtext;
    declare sqlstring longtext;
    declare flag TINYINT DEFAULT 0;
    declare targetvalue DECIMAL(14,2);
    declare statisticunits DECIMAL(14,2);
    declare monthcount int;
	
    set sqlstring = '';
    select `statisticunit` into statisticunits from currencyexchange where id = syscurrencyid;
    set nowdate = date_format(now(),'%Y/%m');
    
    /* 创建结果集临时表 */
    create temporary table IF NOT EXISTS `tmp_chart_optsize_grid_table`
    (
        `id` int(10) NOT NULL AUTO_INCREMENT COMMENT 'ID',
        `yearmonth` varchar(20) NOT NULL COMMENT '年/月',
        `targetvalue` DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '目标金额',
        `dooptprice` DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '执行情况-订单金额',
        `dooptnum` int(10) NOT NULL DEFAULT 0 COMMENT '执行情况-订单数量',
        `forecastoptprice` DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '销售预测-订单金额',
        `forecastoptnum` int(10) NOT NULL DEFAULT 0 COMMENT '销售预测-订单数量',
        `opttotalnum` int(10) NOT NULL DEFAULT 0 COMMENT '总项目数',
        `opttotalprice` DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '总项目金额',
        `alloptpercent10` DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '全部项目-10%',
        `alloptpercent30` DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '全部项目-30%',
        `alloptpercent50` DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '全部项目-50%',
        `alloptpercent70` DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '全部项目-70%',
        `alloptpercent90` DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '全部项目-90%',
        `alloptpercent100` DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '全部项目-100%',
        `lostoptprice` DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '丢失项目金额',
        `optprice` DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '有效金额',
        `bigprojecttotalprice` DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '大项目总额',
        `bigprojectpercent10` DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '大项目状态-10%',
        `bigprojectpercent30` DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '大项目状态-30%',
        `bigprojectpercent50` DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '大项目状态-50%',
        `bigprojectpercent70` DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '大项目状态-70%',
        `bigprojectpercent90` DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '大项目状态-90%',
        `bigprojectpercent100` DECIMAL(14,2) NOT NULL DEFAULT 0 COMMENT '大项目状态-100%',
        PRIMARY KEY (`id`)
    );
    truncate table `tmp_chart_optsize_grid_table`;

	/* 清理初始化参数 */
    if (employeesid is not null and CHAR_LENGTH(employeesid) = 0) then
		set employeesid = null;
    end if;
    if (departsid is not null and CHAR_LENGTH(departsid) = 0) then
		set departsid = null;
    end if;
    
    set tmpcount = 1;

    if CHAR_LENGTH(startdate) > 0 then
        /* 根据参数拼接where条件 */        
        set sqlstr = 'insert into tmp_chart_optsize_grid_table(yearmonth,targetvalue,dooptprice,dooptnum,opttotalnum,opttotalprice,alloptpercent10,alloptpercent30,alloptpercent50,alloptpercent70,alloptpercent90,alloptpercent100,lostoptprice,optprice,bigprojecttotalprice,bigprojectpercent10,bigprojectpercent30,bigprojectpercent50,bigprojectpercent70,bigprojectpercent90,bigprojectpercent100) ';
		set sqlstr = concat(sqlstr,'select ');
		set sqlstr = concat(sqlstr,'$yearmonth$ as yearmonth, ');
		set sqlstr = concat(sqlstr,'$targetvalue$ as targetvalue, ');
        set sqlstr = concat(sqlstr,'ifnull(round(sum(if(opt.stageid = 7 and opt.optstatus = 2,convertopt.converttotalprice,0))/$statisticunit$,2),0.00) as dooptprice, ');
        set sqlstr = concat(sqlstr,'count(if(opt.stageid = 7 and opt.optstatus = 2,opt.id,null)) as dooptnum, ');
        set sqlstr = concat(sqlstr,'$opttotalnum$ as opttotalnum, ');
        set sqlstr = concat(sqlstr,'$opttotalprice$ as opttotalprice, ');
        set sqlstr = concat(sqlstr,'$alloptpercent10$ as alloptpercent10, ');
		set sqlstr = concat(sqlstr,'$alloptpercent30$ as alloptpercent30, ');
        set sqlstr = concat(sqlstr,'$alloptpercent50$ as alloptpercent50, ');
        set sqlstr = concat(sqlstr,'$alloptpercent70$ as alloptpercent70, ');
        set sqlstr = concat(sqlstr,'$alloptpercent90$ as alloptpercent90, ');
        set sqlstr = concat(sqlstr,'ifnull(round(sum(if(opt.stageid = 7 and opt.optstatus = 2,convertopt.converttotalprice,0))/$statisticunit$,2),0.00) as alloptpercent100, ');
		set sqlstr = concat(sqlstr,'ifnull(round(sum(if(opt.optstatus = 4,convertopt.converttotalprice,0))/$statisticunit$,2),0.00) as lostoptprice, ');
        set sqlstr = concat(sqlstr,'$optprice$ as optprice, ');
        set sqlstr = concat(sqlstr,'$bigprojecttotalprice$ as bigprojecttotalprice, ');
        set sqlstr = concat(sqlstr,'$bigprojectpercent10$ as bigprojectpercent10, ');
        set sqlstr = concat(sqlstr,'$bigprojectpercent30$ as bigprojectpercent30, ');
        set sqlstr = concat(sqlstr,'$bigprojectpercent50$ as bigprojectpercent50, ');
        set sqlstr = concat(sqlstr,'$bigprojectpercent70$ as bigprojectpercent70, ');
        set sqlstr = concat(sqlstr,'$bigprojectpercent90$ as bigprojectpercent90, ');
        set sqlstr = concat(sqlstr,'$bigprojectpercent100$ as bigprojectpercent100 ');
        set sqlstr = concat(sqlstr,'from opt left join employee emp on opt.ownerid = emp.id left join (select
		  opt.id id,
		  if(',syscurrencyid,'=1,
		     if(opt.currencyid=1,
		        opt.totalprice,
		        opt.totalpriceminor*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2))),
		     if(opt.currencyid=2,
		        opt.totalpriceminor,
		        opt.totalprice*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2)))) converttotalprice,
		  if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) formula
		from opt
		left join currencyconvert cc
		  ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
		left join (select cast(if(',syscurrencyid,'=1,intoajformula,ajtoinformula) as DECIMAL(14,2)) formula  from currencyconvert ORDER BY id desc limit 1) lasc
		  ON 1=1) convertopt on opt.id=convertopt.id
		left join currencyexchange cue on cue.id = opt.currencyid where opt.isdelete = 0 ');

        if (employeesid is not null and departsid is not null) then
            set sqlstr = concat(sqlstr,'and (opt.ownerid in (',employeesid,') or emp.depid in (',departsid,'))');
		else
			if employeesid is not null then
				set sqlstr = concat(sqlstr,'and (opt.ownerid in (',employeesid,'))');
			elseif departsid is not null then
				set sqlstr = concat(sqlstr, 'and emp.depid in (',departsid,')');
            end if;
        end if;

        if (faranchiseid is not null and faranchiseid > 0) then
			set sqlstr = concat(sqlstr, ' and opt.faranchiseid = ',faranchiseid);
        end if;
		if (bigvalue is not null or bigvalue = 0) then
			set bigvalue = bigvalue * 10000;
		else
			set bigvalue = (select if(syscurrencyid=1,ifnull(bigoptprice*statisticunits,0),ifnull(bigoptpriceminor*statisticunits,0)) from systemconfig where id = 1);
		end if;
		set tmpdate = startdate;
		set monthcount = PERIOD_DIFF(date_format(enddate,'%Y%m'),date_format(startdate,'%Y%m'))+1;
        /* 取monthcount个月的日期 */
		while tmpcount <= monthcount do
			-- 如果大于1取下一个月的第1天
            if tmpcount > 1 then
				set tmpdate = DATE_ADD(tmpdate,interval -day(tmpdate)+1 day);
			    set tmpdate = DATE_ADD(tmpdate, interval 1 month);
            end if;
            
            set startplanoverdate = tmpdate;
            /* 取当月最后一天的日期 */
            if tmpcount < monthcount then
				set endplanoverdate = DATE_ADD(tmpdate, interval DAY(LAST_DAY(tmpdate)) - DAY(tmpdate) day);
			else
				set endplanoverdate = enddate;
            end if;
            
			set sqlstring = concat(sqlstr, ' and opt.planoverdate between \'', startplanoverdate, '\' and \'', endplanoverdate, '\'');
            /** 
             * 将$targetvalue$替换为目标金额
             * 将$yearmonth$替换为实际年月格式 
             * 
             */
            call chart_optsize_target_proc(syscurrencyid,employeesid,departsid,faranchiseid,startplanoverdate,targetvalue);
            
            set sqlstring = replace(sqlstring,'$targetvalue$',targetvalue);
            set sqlstring = replace(sqlstring,'$yearmonth$',date_format(startplanoverdate,'\'%Y/%m\''));
            
			set sqlstring = replace(sqlstring,'$opttotalnum$','count(if(opt.optstatus = 1 or opt.optstatus = 2,opt.id,null))');
			set sqlstring = replace(sqlstring,'$opttotalprice$','ifnull(round(sum(if(opt.optstatus = 1 or opt.optstatus = 2,convertopt.converttotalprice,0))/$statisticunit$,2),0.00)');
			set sqlstring = replace(sqlstring,'$alloptpercent10$','ifnull(round(sum(if(opt.stageid = 2 and opt.optstatus = 1,convertopt.converttotalprice,0))/$statisticunit$,2),0.00)');
			set sqlstring = replace(sqlstring,'$alloptpercent30$','ifnull(round(sum(if(opt.stageid = 3 and opt.optstatus = 1,convertopt.converttotalprice,0))/$statisticunit$,2),0.00)');
			set sqlstring = replace(sqlstring,'$alloptpercent50$','ifnull(round(sum(if(opt.stageid = 4 and opt.optstatus = 1,convertopt.converttotalprice,0))/$statisticunit$,2),0.00)');
			set sqlstring = replace(sqlstring,'$alloptpercent70$','ifnull(round(sum(if(opt.stageid = 5 and opt.optstatus = 1,convertopt.converttotalprice,0))/$statisticunit$,2),0.00)');
			set sqlstring = replace(sqlstring,'$alloptpercent90$','ifnull(round(sum(if(opt.stageid = 6 and opt.optstatus = 1,convertopt.converttotalprice,0))/$statisticunit$,2),0.00)');
			set sqlstring = replace(sqlstring,'$optprice$','ifnull(round(sum(if(opt.optstatus = 1,convertopt.converttotalprice*(case opt.stageid when 1 then 0 when 2 then 0.1 when 3 then 0.3 when 4 then 0.5 when 5 then 0.7 when 6 then 0.9 end)*
(case opt.possibilityid when 1 then 0 when 2 then 0.2 when 3 then 0.25 when 4 then 0.3 when 5 then 0.5 when 6 then 0.8 end),0))/$statisticunit$,2),0.00)');
			set sqlstring = replace(sqlstring,'$bigprojecttotalprice$',concat('ifnull(round(sum(if(convertopt.converttotalprice >= ',bigvalue,' and (opt.optstatus = 1 or opt.optstatus = 2),convertopt.converttotalprice,0))/$statisticunit$,2),0.00)'));
			set sqlstring = replace(sqlstring,'$bigprojectpercent10$',concat('ifnull(round(sum(if(convertopt.converttotalprice >= ',bigvalue,' and opt.optstatus = 1 and opt.stageid = 2,convertopt.converttotalprice,0))/$statisticunit$,2),0.00)'));
			set sqlstring = replace(sqlstring,'$bigprojectpercent30$',concat('ifnull(round(sum(if(convertopt.converttotalprice >= ',bigvalue,' and opt.optstatus = 1 and opt.stageid = 3,convertopt.converttotalprice,0))/$statisticunit$,2),0.00)'));
			set sqlstring = replace(sqlstring,'$bigprojectpercent50$',concat('ifnull(round(sum(if(convertopt.converttotalprice >= ',bigvalue,' and opt.optstatus = 1 and opt.stageid = 4,convertopt.converttotalprice,0))/$statisticunit$,2),0.00)'));
			set sqlstring = replace(sqlstring,'$bigprojectpercent70$',concat('ifnull(round(sum(if(convertopt.converttotalprice >= ',bigvalue,' and opt.optstatus = 1 and opt.stageid = 5,convertopt.converttotalprice,0))/$statisticunit$,2),0.00)'));
			set sqlstring = replace(sqlstring,'$bigprojectpercent90$',concat('ifnull(round(sum(if(convertopt.converttotalprice >= ',bigvalue,' and opt.optstatus = 1 and opt.stageid = 6,convertopt.converttotalprice,0))/$statisticunit$,2),0.00)'));
            set sqlstring = replace(sqlstring,'$bigprojectpercent100$',concat('ifnull(round(sum(if(convertopt.converttotalprice >= ',bigvalue,' and opt.optstatus = 2 and opt.stageid = 7,convertopt.converttotalprice,0))/$statisticunit$,2),0.00)'));
            set sqlstring = replace(sqlstring,'$statisticunit$',statisticunits);

            set @stmt = sqlstring;
            PREPARE stmt FROM @stmt;
			EXECUTE stmt;

            set tmpcount = tmpcount + 1;
        end while;
	
        DEALLOCATE PREPARE stmt;
        select * from tmp_chart_optsize_grid_table;
	end if;
END//
DELIMITER ;

-- 导出  过程 vsms.chart_optsize_shape_proc 结构
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `chart_optsize_shape_proc`(IN syscurrencyid varchar(20), IN startdate varchar(20),IN enddate varchar(20),IN dateType smallint,IN employeesid varchar(4000),IN departsid varchar(4000),IN faranchiseid int,IN bigvalue DECIMAL(14,2))
BEGIN
    declare tmpdate varchar(20);
	declare startplanoverdate varchar(20);
    declare endplanoverdate varchar(20);
    declare tmpcount int;
    declare sqlstr longtext;
    declare sqlstring longtext;
    declare flag TINYINT DEFAULT 0;
    declare targetvalue DECIMAL(14,2);
	declare statisticunits DECIMAL(14,2);
    declare monthcount int;
	
    set sqlstring = '';
	select `statisticunit` into statisticunits from currencyexchange where id = syscurrencyid;
    /* 创建结果集临时表 辅助列的作用是创造一个空白的柱子,将柱状图"挤"成漏斗图*/
    create temporary table IF NOT EXISTS `tmp_chart_optsize_shape_table`
    (
        `id` int(10) NOT NULL AUTO_INCREMENT COMMENT 'ID',
        `yearmonth` varchar(20) NOT NULL COMMENT '年/月',
        `percent10` DECIMAL(14,2) NOT NULL COMMENT '10%',
        `percent30` DECIMAL(14,2) NOT NULL COMMENT '30%',
        `percent50` DECIMAL(14,2) NOT NULL COMMENT '50%',
        `percent70` DECIMAL(14,2) NOT NULL COMMENT '70%',
        `percent90` DECIMAL(14,2) NOT NULL COMMENT '90%',
        `percent100` DECIMAL(14,2) NOT NULL COMMENT '100%',
        `totalprice` DECIMAL(14,2) NOT NULL COMMENT '总计',
        PRIMARY KEY (`id`)
    );
    truncate table `tmp_chart_optsize_shape_table`;

	/* 清理初始化参数 */
    if (employeesid is not null and CHAR_LENGTH(employeesid) = 0) then
		set employeesid = null;
    end if;
    if (departsid is not null and CHAR_LENGTH(departsid) = 0) then
		set departsid = null;
    end if;
    
    set tmpcount = 1;

    if CHAR_LENGTH(startdate) > 0 then
        /* 根据参数拼接where条件 */        
        set sqlstr = 'insert into tmp_chart_optsize_shape_table(percent10,percent30,percent50,percent70,percent90,percent100,yearmonth,totalprice) ';
		set sqlstr = concat(sqlstr,'select ');
        set sqlstr = concat(sqlstr,'ifnull(round(sum(if(opt.stageid = 2,convertopt.converttotalprice,0.00))/$statisticunit$,2),0.00) as percent10, ');
        set sqlstr = concat(sqlstr,'ifnull(round(sum(if(opt.stageid = 3,convertopt.converttotalprice,0.00))/$statisticunit$,2),0.00) as percent30, ');            
        set sqlstr = concat(sqlstr,'ifnull(round(sum(if(opt.stageid = 4,convertopt.converttotalprice,0.00))/$statisticunit$,2),0.00) as percent50, ');            
        set sqlstr = concat(sqlstr,'ifnull(round(sum(if(opt.stageid = 5,convertopt.converttotalprice,0.00))/$statisticunit$,2),0.00) as percent70, ');            
        set sqlstr = concat(sqlstr,'ifnull(round(sum(if(opt.stageid = 6,convertopt.converttotalprice,0.00))/$statisticunit$,2),0.00) as percent90, ');  
        set sqlstr = concat(sqlstr,'ifnull(round(sum(if(opt.stageid = 7,convertopt.converttotalprice,0.00))/$statisticunit$,2),0.00) as percent100, ');
        set sqlstr = concat(sqlstr,'$yearmonth$ as yearmonth, ');
        set sqlstr = concat(sqlstr,'(ifnull(round(sum(if(opt.stageid = 2,convertopt.converttotalprice,0.00))/$statisticunit$,2),0.00)+ifnull(round(sum(if(opt.stageid = 3,convertopt.converttotalprice,0.00))/$statisticunit$,2),0.00)+ifnull(round(sum(if(opt.stageid = 4,convertopt.converttotalprice,0.00))/$statisticunit$,2),0.00)+ifnull(round(sum(if(opt.stageid = 5,convertopt.converttotalprice,0.00))/$statisticunit$,2),0.00)+ifnull(round(sum(if(opt.stageid = 6,convertopt.converttotalprice,0.00))/$statisticunit$,2),0.00)+ifnull(round(sum(if(opt.stageid = 7,convertopt.converttotalprice,0.00))/$statisticunit$,2),0.00)) as totalprice ');
        set sqlstr = concat(sqlstr,'from opt left join employee emp on opt.ownerid = emp.depid left join (select
		  opt.id id,
		  if(',syscurrencyid,'=1,
		     if(opt.currencyid=1,
		        opt.totalprice,
		        opt.totalpriceminor*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2))),
		     if(opt.currencyid=2,
		        opt.totalpriceminor,
		        opt.totalprice*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2)))) converttotalprice,
		  if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) formula
		from opt
		left join currencyconvert cc
		  ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
		left join (select cast(if(',syscurrencyid,'=1,intoajformula,ajtoinformula) as DECIMAL(14,2)) formula  from currencyconvert ORDER BY id desc limit 1) lasc
		  ON 1=1) convertopt on opt.id=convertopt.id
		left join currencyexchange cue on cue.id = opt.currencyid where opt.isdelete = 0 and opt.optstatus not in(3,4,5) ');

        if (employeesid is not null and departsid is not null) then
            set sqlstr = concat(sqlstr,' and (opt.ownerid in (',employeesid,') or emp.depid in (',departsid,'))');
		else
			if employeesid is not null then
				set sqlstr = concat(sqlstr,' and (opt.ownerid in (',employeesid,'))');
			elseif departsid is not null then
				set sqlstr = concat(sqlstr, ' and emp.depid in (',departsid,')');
            end if;
        end if;

        if (faranchiseid is not null and faranchiseid > 0) then
			set sqlstr = concat(sqlstr, ' and opt.faranchiseid = ',faranchiseid);
        end if;

		if (bigvalue is not null or bigvalue = 0) then
			set bigvalue = bigvalue * 10000;
			set sqlstr = concat(sqlstr, ' and opt.totalprice >= ',bigvalue);
		else
			set bigvalue = (select ifnull(bigoptprice*10000,0) from systemconfig where id = 1);
			set sqlstr = concat(sqlstr, ' and opt.totalprice >= ',bigvalue);
		end if;
		set tmpdate = startdate;

		/* 如果为全年,取30天,60天,90天,如果为动态12个月,取动态12个月 */
--         if dateType = 1 then
-- 			set startplanoverdate = tmpdate;
-- 			while tmpcount <= 3 do
-- 				if tmpcount > 1 then
-- 					set endplanoverdate = DATE_ADD(DATE_ADD(tmpdate, interval tmpcount month), interval DAY(LAST_DAY(tmpdate)) - DAY(tmpdate) day);
-- 				else
-- 					set endplanoverdate = DATE_ADD(tmpdate, interval DAY(LAST_DAY(tmpdate)) - DAY(tmpdate) day);
--                 end if;
-- 				if flag = 1 then
-- 					set sqlstring = concat(sqlstr, ' and opt.planoverdate between \'', startplanoverdate, '\' and \'', endplanoverdate, '\'');
-- 				else
-- 					set sqlstring = concat(sqlstr, ' opt.planoverdate between \'', startplanoverdate, '\' and \'', endplanoverdate, '\'');
-- 				end if;
				/** 
				 * 将$yearmonth$替换为实际年月格式 
				 */
				-- if tmpcount = 1 then
-- 					set sqlstring = replace(sqlstring,'$yearmonth$','\'30天\'');
--                 elseif tmpcount = 2 then
-- 					set sqlstring = replace(sqlstring,'$yearmonth$','\'60天\'');
--                 elseif tmpcount = 3 then
-- 					set sqlstring = replace(sqlstring,'$yearmonth$','\'90天\'');
--                 end if;
-- 				set @stmt = sqlstring;
-- 				PREPARE stmt FROM @stmt;
-- 				EXECUTE stmt;                
--                 set tmpcount = tmpcount + 1;
--             end while;
        -- elseif dateType = 2 then
			set monthcount = PERIOD_DIFF(date_format(enddate,'%Y%m'),date_format(startdate,'%Y%m'))+1;
			/* 取12个月的日期 */
			while tmpcount <= monthcount do
				-- 如果大于1取下一个月的第1天
				if tmpcount > 1 then
					set tmpdate = DATE_ADD(tmpdate,interval -day(tmpdate)+1 day);
					set tmpdate = DATE_ADD(tmpdate, interval 1 month);
				end if;
				set startplanoverdate = tmpdate;
				/* 取当月最后一天的日期 */
				if tmpcount < monthcount then
					set endplanoverdate = DATE_ADD(tmpdate, interval DAY(LAST_DAY(tmpdate)) - DAY(tmpdate) day);
				else
					set endplanoverdate = enddate;
				end if;
				set sqlstring = concat(sqlstr, ' and opt.planoverdate between \'', startplanoverdate, '\' and \'', endplanoverdate, '\'');
				/** 
				 * 将$yearmonth$替换为实际年月格式 
				 */
				set sqlstring = replace(sqlstring,'$yearmonth$',date_format(startplanoverdate,'\'%Y/%m\''));
                set sqlstring = replace(sqlstring,'$statisticunit$',statisticunits);
				set @stmt = sqlstring;
				PREPARE stmt FROM @stmt;
				EXECUTE stmt;				
				set tmpcount = tmpcount + 1;
			end while;
        -- end if;
        
		DEALLOCATE PREPARE stmt;
        select * from tmp_chart_optsize_shape_table;
	end if;
END//
DELIMITER ;

-- 导出  过程 vsms.chart_optsize_target_proc 结构
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `chart_optsize_target_proc`(IN syscurrencyid varchar(20),IN employeesid varchar(4000),IN departsid varchar(4000),IN faranchiseid int,IN targetdate varchar(20),OUT targetvalue DECIMAL(14,2))
BEGIN
	declare sqlstr longtext;
    declare years varchar(10);
    declare months varchar(10);
    set years = date_format(targetdate,'%Y');
    set months = date_format(targetdate,'%m');
    
    if faranchiseid > 0 then
		set sqlstr = concat('select if(',syscurrencyid,'=1,ifnull(faranchisevalue,0),ifnull(faranchiseminor,0)) into @p_targetvalue from faranchise where id = ',faranchiseid);
    else
		set sqlstr = concat('select if(',syscurrencyid,'=1,ifnull(sum(empt.targetmoney),0),ifnull(sum(empt.targetmoneyminor),0)) into @p_targetvalue from emptarget empt left join employee emp on empt.employeeid = emp.id where',
					' empt.years = \'',years,'\' and empt.months = \'',months,'\'');
		/*如果有部门id则按部门id,否则按员工id查询*/
		if departsid is not null then
			set sqlstr = concat(sqlstr,' and emp.depid in (',departsid,')');
		elseif employeesid is not null then
			set sqlstr = concat(sqlstr,' and empt.employeeid in (',employeesid,')');
		end if;
    end if;
    
    set @stmt = sqlstr;
	PREPARE stmt FROM @stmt;
	EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    set targetvalue = @p_targetvalue;
END//
DELIMITER ;

-- 导出  过程 vsms.chart_opttype_chart_proc 结构
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `chart_opttype_chart_proc`(IN syscurrencyid varchar(20),IN startdate varchar(20),IN enddate varchar(20),IN employeesid varchar(4000),IN departsid varchar(4000),IN faranchiseid int)
BEGIN
    declare tmpdate varchar(20);
	declare startplanoverdate varchar(20);
    declare endplanoverdate varchar(20);
    declare tmpcount int default 1;
    declare sqlstr longtext;
    declare sqlstring longtext;
    declare sqltablestring longtext;
    declare opttypefieldsstring longtext default '';
    declare flag tinyint default 0;
    declare targetvalue decimal(14,2);
    declare statisticunits decimal(14,2);
    declare monthcount int;
    
	declare opttypeid int;
    declare done TINYINT DEFAULT 0;
    declare cur cursor for select id from opttype;
    declare continue handler for not found set done = 1;
	
    set sqlstring = '';
    
    if (syscurrencyid is not null and CHAR_LENGTH(syscurrencyid) > 0) then
		select `statisticunit` into statisticunits from currencyexchange where id = syscurrencyid;
    end if;

	drop temporary table if exists tmp_chart_opttype_chart_table;
    
    set sqltablestring = 'create temporary table IF NOT EXISTS `tmp_chart_opttype_chart_table`(`id` int(10) NOT NULL AUTO_INCREMENT COMMENT \'ID\',`yearmonth` varchar(20) NOT NULL COMMENT \'年/月\',';
    
	/* 清理初始化参数 */
    if (employeesid is not null and CHAR_LENGTH(employeesid) = 0) then
        set employeesid = null;
    end if;
    if (departsid is not null and CHAR_LENGTH(departsid) = 0) then
        set departsid = null;
    end if;
    
    if CHAR_LENGTH(startdate) > 0 then
    
		/* 根据参数拼接where条件 */        
        set sqlstr = 'insert into tmp_chart_opttype_chart_table($opttypefields$, yearmonth) ';
        set sqlstr = concat(sqlstr,'select ');
    
		/* 动态创建临时表 */
		/* 打开游标 */
		open cur;
		
		/* 遍历数据表 */
		read_loop: loop
        
			fetch cur into opttypeid;
            
			if done then
				set tmpcount = 1;
				leave read_loop;
			end if;
            
            /*拼接创建临时表的opttype字段*/
			set sqltablestring = concat(sqltablestring, '`opttype', tmpcount, '` DECIMAL(14,2) NOT NULL,');
            
            /*拼接插入数据的opttype字段*/
            if char_length(opttypefieldsstring) = 0 then
				set opttypefieldsstring = concat('opttype', tmpcount);
            else
				set opttypefieldsstring = concat_ws(',', opttypefieldsstring, concat('opttype', tmpcount));
            end if;
            set sqlstr = concat(sqlstr,'ifnull(round(sum(if(opt.opttype = ', opttypeid, ',convertopt.converttotalprice,0.00))/$statisticunit$,2),0.00) as ', 'opttype', tmpcount ,', ');
			set tmpcount = tmpcount + 1;
            
		end loop;
		
		/* 关闭游标 */
		close cur;
		
		set sqltablestring = concat(sqltablestring, 'PRIMARY KEY (`id`));');

		set @stmt = sqltablestring;
		PREPARE stmt FROM @stmt;
		EXECUTE stmt;
        
		truncate table `tmp_chart_opttype_chart_table`;
        
        set sqlstr = concat(sqlstr,'$yearmonth$ as yearmonth ');
		set sqlstr = concat(sqlstr,'from opt left join employee emp on opt.ownerid = emp.id left join (select
          opt.id id,
          if(',syscurrencyid,'=1,
             if(opt.currencyid=1,
                opt.totalprice,
                opt.totalpriceminor*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2))),
             if(opt.currencyid=2,
                opt.totalpriceminor,
                opt.totalprice*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2)))) converttotalprice,
          if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) formula
        from opt
        left join currencyconvert cc
          ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
        left join (select cast(if(',syscurrencyid,'=1,intoajformula,ajtoinformula) as DECIMAL(14,2)) formula  from currencyconvert ORDER BY id desc limit 1) lasc
          ON 1=1) convertopt on opt.id=convertopt.id
        left join currencyexchange cue on cue.id = opt.currencyid where opt.isdelete = 0 and opt.optstatus not in(3,4,5) ');

        if (employeesid is not null and departsid is not null) then
            set sqlstr = concat(sqlstr,' and ( opt.ownerid in (',employeesid,') or emp.depid in (',departsid,'))');
        else
            if employeesid is not null then
                set sqlstr = concat(sqlstr,' and ( opt.ownerid in (',employeesid,'))');
            elseif departsid is not null then
                set sqlstr = concat(sqlstr, ' and emp.depid in (',departsid,')');
            end if;
        end if;

        if (faranchiseid is not null and faranchiseid > 0) then
            set sqlstr = concat(sqlstr, ' and opt.faranchiseid = ',faranchiseid);
        end if;

        set tmpdate = startdate;
        set monthcount = PERIOD_DIFF(date_format(enddate,'%Y%m'),date_format(startdate,'%Y%m'))+1;
        /* 取monthcount个月的日期 */
        while tmpcount <= monthcount do
            -- 如果大于1取下一个月的第1天
            if tmpcount > 1 then
                set tmpdate = DATE_ADD(tmpdate,interval -day(tmpdate)+1 day);
                set tmpdate = DATE_ADD(tmpdate, interval 1 month);
            end if;

            set startplanoverdate = tmpdate;
            /* 取当月最后一天的日期 */
            if tmpcount < monthcount then
                set endplanoverdate = DATE_ADD(tmpdate, interval DAY(LAST_DAY(tmpdate)) - DAY(tmpdate) day);
            else
                set endplanoverdate = enddate;
            end if;

            set sqlstring = concat(sqlstr, ' and opt.planoverdate between \'', startplanoverdate, '\' and \'', endplanoverdate, '\'');

			set sqlstring = replace(sqlstring, '$opttypefields$', opttypefieldsstring);
            set sqlstring = replace(sqlstring, '$yearmonth$', date_format(startplanoverdate, '\'%Y/%m\''));
            set sqlstring = replace(sqlstring, '$statisticunit$', statisticunits);
           -- insert into debug(debug) values(sqlstring);           
            set @stmt = sqlstring;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;

            set tmpcount = tmpcount + 1;
        end while;
        DEALLOCATE PREPARE stmt;

		select * from tmp_chart_opttype_chart_table;
    end if;
END//
DELIMITER ;

-- 导出  过程 vsms.getAllDepartById 结构
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `getAllDepartById`(IN depId INT,OUT sResult varchar(4000))
BEGIN
	-- 根据单个id查询所有子部门id
	DECLARE sTempChd VARCHAR (4000);
    
	SET sResult = '';
	SET sTempChd = cast(depId as char);
    
	WHILE sTempChd IS NOT NULL DO
		IF sResult = '' THEN
			SET sResult = sTempChd;
		ELSE
			SET sResult = concat(sResult, ',', sTempChd);
		END IF;
		SELECT group_concat(id) INTO sTempChd FROM empdepart
		WHERE FIND_IN_SET(sdepartid, sTempChd) > 0;
	END WHILE;
END//
DELIMITER ;

-- 导出  过程 vsms.getAllDepartByIdList 结构
DELIMITER //
CREATE DEFINER=`root`@`%` PROCEDURE `getAllDepartByIdList`(IN departIds VARCHAR(4000),OUT sResult varchar(4000))
BEGIN
	-- 传入部门id参数，输出所有子部门id
	DECLARE cTemp VARCHAR (20); -- 临时变量
    DECLARE sTemp VARCHAR (4000); -- 临时变量
    
	SET cTemp = '';
	SET sTemp = '';
    
	IF departIds IS NOT NULL THEN
		-- 找出所有部门的子部门id
		WHILE departIds != '' DO
			SET cTemp = substring_index(departIds,',',1);
            SET departIds = substring(departIds,length(cTemp)+2,length(departIds));
            IF cTemp != '' THEN
				CALL getAllDepartById(cTemp,sTemp);
				SET sResult = concat_ws(',',sTemp,sResult);
            END IF;
		END WHILE;		
    END IF;
END//
DELIMITER ;

-- 导出  过程 vsms.opt_snapshot_proc 结构
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `opt_snapshot_proc`()
BEGIN
	declare snapperiod int;
	declare nowday varchar(20);
    declare nowmonth varchar(20);
    declare nextmonth varchar(20);
	declare t_error integer default 0;
	declare continue handler for sqlexception set t_error=1;

    set nowday = date_format(now(), '%Y-%m-%d');
    set nowmonth = date_format(nowday, '%Y-%m');
    set nextmonth = date_format(date_add(nowday, interval 1 month),'%Y-%m');
    set snapperiod = (select ifnull(snapshootperiod, date_format(last_day(nowday),'%d')) from systemconfig limit 1);

    if dayofmonth(nowday) = snapperiod then
    
		start transaction;
        
		insert into optestimatesnap(`optid`, `optno`, `leadid`, `optsource`, `customerid`, `opttype`, `optname`, `totalprice`, `totalpriceminor`, `totalcost`, `totalcostminor`, `optexpend`, `otherexpend`, `planoverdate`, `realityoverdate`, `possibilityid`, `stageid`, `createrid`, `createdatetime`, `confidenceindex`, `optstatus`, `optlevel`, `remark`, `ownerid`, `procurementmethodid`, `faranchiseid`, `currencyid`)
        select `id`, `optno`, `leadid`, `optsource`, `customerid`, `opttype`, `optname`, `totalprice`, `totalpriceminor`, `totalcost`, `totalcostminor`, `optexpend`, `otherexpend`, `planoverdate`, `realityoverdate`, `possibilityid`, `stageid`, `createrid`, `createdatetime`, `confidenceindex`, `optstatus`, `optlevel`, `remark`, `ownerid`, `procurementmethodid`, `faranchiseid`, `currencyid`
        from opt 
        where date_format(planoverdate,'%Y-%m') = nextmonth and isdelete = 0;
        
        insert into optestimatesnapproduct(`optproductid`, `optid`, `brandname`, `classname`, `productid`, `productmodel`, `productname`, `specification`, `productdiscribe`, `rmbcost`, `rmbprice`, `dollarcost`, `dollarprice`, `num`, `discount`, `remark`, `pmid`, `currencyexchangerate`)
        select optproduct.`id`, optproduct.`optid`, optproduct.`brandname`, optproduct.`classname`, optproduct.`productid`, optproduct.`productmodel`, optproduct.`productname`, optproduct.`specification`, optproduct.`productdiscribe`, optproduct.`rmbcost`, optproduct.`rmbprice`, optproduct.`dollarcost`, optproduct.`dollarprice`, optproduct.`num`, optproduct.`discount`, optproduct.`remark`, optproduct.`pmid`, optproduct.`currencyexchangerate`
        from opt 
        left join optproduct 
        on opt.id = optproduct.optid 
        where date_format(opt.planoverdate,'%Y-%m') = nextmonth and opt.isdelete = 0;
        
        insert into optrealsnap(`optid`, `optno`, `leadid`, `optsource`, `customerid`, `opttype`, `optname`, `totalprice`, `totalpriceminor`, `totalcost`, `totalcostminor`, `optexpend`, `otherexpend`, `planoverdate`, `realityoverdate`, `possibilityid`, `stageid`, `createrid`, `createdatetime`, `confidenceindex`, `optstatus`, `optlevel`, `remark`, `ownerid`, `procurementmethodid`, `faranchiseid`, `currencyid`)
        select `id`, `optno`, `leadid`, `optsource`, `customerid`, `opttype`, `optname`, `totalprice`, `totalpriceminor`, `totalcost`, `totalcostminor`, `optexpend`, `otherexpend`, `planoverdate`, `realityoverdate`, `possibilityid`, `stageid`, `createrid`, `createdatetime`, `confidenceindex`, `optstatus`, `optlevel`, `remark`, `ownerid`, `procurementmethodid`, `faranchiseid`, `currencyid`
        from opt
        where id in (select optid from optestimatesnap where date_format(planoverdate,'%Y-%m') = nowmonth) ;
        
		insert into optrealsnapproduct(`optproductid`, `optid`, `brandname`, `classname`, `productid`, `productmodel`, `productname`, `specification`, `productdiscribe`, `rmbcost`, `rmbprice`, `dollarcost`, `dollarprice`, `num`, `discount`, `remark`, `pmid`, `currencyexchangerate`)
        select optproduct.`id`, optproduct.`optid`, optproduct.`brandname`, optproduct.`classname`, optproduct.`productid`, optproduct.`productmodel`, optproduct.`productname`, optproduct.`specification`, optproduct.`productdiscribe`, optproduct.`rmbcost`, optproduct.`rmbprice`, optproduct.`dollarcost`, optproduct.`dollarprice`, optproduct.`num`, optproduct.`discount`, optproduct.`remark`, optproduct.`pmid`, optproduct.`currencyexchangerate`
        from opt 
        left join optproduct 
        on opt.id = optproduct.optid 
        where opt.id in (select optid from optestimatesnap where date_format(planoverdate,'%Y-%m') = nowmonth);
        
        if t_error = 1 then
			rollback;
		else
			commit;
		end if;
    end if;
END//
DELIMITER ;

-- 导出  过程 vsms.proc_import_batchCheck 结构
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_import_batchCheck`(
	IN `language` VARCHAR(50)
)
BEGIN
call proc_import_check('zmemory_currencyexchange',language);
call proc_import_check('zmemory_currencyconvert',language);
call proc_import_check('zmemory_empdepart',language);
call proc_import_check('zmemory_empposition',language);
#call proc_import_check('zmemory_emprole',language);
call proc_import_check('zmemory_employee',language);
call proc_import_check('zmemory_empemployeerole',language);
call proc_import_check('zmemory_emptarget',language);
call proc_import_check('zmemory_empemployeeviewuser',language);
call proc_import_check('zmemory_empemployeedepart',language);
call proc_import_check('zmemory_productbrand',language);
call proc_import_check('zmemory_productclass',language);
call proc_import_check('zmemory_product',language);
call proc_import_check('zmemory_country',language);
call proc_import_check('zmemory_region',language);
call proc_import_check('zmemory_province',language);
call proc_import_check('zmemory_city',language);
call proc_import_check('zmemory_town',language);
call proc_import_check('zmemory_piecearea',language);
call proc_import_check('zmemory_industry',language);
call proc_import_check('zmemory_industrysub',language);
call proc_import_check('zmemory_customer',language);
call proc_import_check('zmemory_customercontact',language);
call proc_import_check('zmemory_workplanworktype',language);
call proc_import_check('zmemory_source',language);
call proc_import_check('zmemory_opttype',language);
call proc_import_check('zmemory_optstage',language);
#call proc_import_check('zmemory_optpossibility',language);
call proc_import_check('zmemory_optcontactrole',language);
call proc_import_check('zmemory_procurementmethod',language);
call proc_import_check('zmemory_faranchise',language);
call proc_import_check('zmemory_opt',language);
call proc_import_check('zmemory_optproduct',language);
call proc_import_check('zmemory_optcontact',language);
call proc_import_check('zmemory_systemconfig',language);
#call proc_import_check('zmemory_optstageupdate',language);
#call proc_import_check('zmemory_zmemory_question',language);



END//
DELIMITER ;

-- 导出  过程 vsms.proc_import_check 结构
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_import_check`(
	IN `tableName` VARCHAR(50),
	IN `language` VARCHAR(50)
)
BEGIN
   declare  fieldName varchar(64);  
   DECLARE  totable varchar(64);  
   DECLARE  tomtable varchar(64);
   declare  value varchar(64); 
   declare  firstnum varchar(64); 
   declare  lastnum varchar(64);
    -- 遍历数据结束标志
    DECLARE done INT DEFAULT FALSE;
    -- 游标
    DECLARE cur11 CURSOR FOR SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.Columns WHERE table_name=tableName and column_comment='11'; 
    DECLARE cur00 CURSOR FOR SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.Columns WHERE table_name=tableName and column_comment='00'; 
    DECLARE cur CURSOR FOR SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.Columns WHERE table_name=tableName and column_comment='-1';
    DECLARE cur0 CURSOR FOR SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.Columns WHERE table_name=tableName and column_comment='0';
    DECLARE cur1 CURSOR FOR SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.Columns WHERE table_name=tableName and column_comment='1';
    DECLARE cur2 CURSOR FOR SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.Columns WHERE table_name=tableName and column_comment='2';
    DECLARE cur4 CURSOR FOR SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.Columns WHERE table_name=tableName and column_comment='4';
    DECLARE cur5 CURSOR FOR SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.Columns WHERE table_name=tableName and column_comment='5';
    DECLARE cur7 CURSOR FOR SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.Columns WHERE table_name=tableName and column_comment='7';

    DECLARE cur3 CURSOR FOR SELECT COLUMN_NAME,substring(column_comment,2),right(substring(column_comment,2),length(substring(column_comment,2))-8)
	             FROM INFORMATION_SCHEMA.Columns WHERE table_name=tableName and left(column_comment,1)='3';
    DECLARE cur6 CURSOR FOR SELECT COLUMN_NAME,substring(column_comment,2),right(substring(column_comment,2),length(substring(column_comment,2))-8)
	             FROM INFORMATION_SCHEMA.Columns WHERE table_name=tableName and left(column_comment,1)='6';
     declare num CURSOR FOR SELECT COLUMN_NAME,substring_index(substring_index(column_comment,',',-2),',',1),substring_index(column_comment,',',-1)
	  FROM INFORMATION_SCHEMA.Columns WHERE table_name=tableName and left(column_comment,3)='num';
    declare equal CURSOR FOR SELECT COLUMN_NAME,substring(column_comment,7) FROM INFORMATION_SCHEMA.Columns WHERE table_name=tableName and left(column_comment,5)='equal';
    -- 将结束标志绑定到游标
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- 打开游标
    if language='en'
    then
		    OPEN  cur;     
		    -- 遍历
		    read_loop: LOOP
		            -- 取值 
		            FETCH   cur INTO fieldName;
		            IF done THEN
		                LEAVE read_loop;
		             END IF;
		 
		        -- 你自己想做的操作
		       set @sqlStr=CONCAT("
		      			 insert into zmemory_question(tableName,row,col,error)
		                select '",tableName,"',row, '",fieldName,"',
		                case 
		                when ",fieldName," is null then '",fieldName,"不能为空'
		                when ",fieldName,"='{length}' then '",fieldName,"长度不能超过200'
		                end 'error'
		                from ",tableName," where ",fieldName," is null or ",fieldName,"='{length}'
		                ");
		                
		            PREPARE stmt from @sqlStr;
		            EXECUTE stmt;
		      
		    END LOOP;
		    CLOSE cur;
		    
		    SET done = FALSE;
		     OPEN  cur0;     
			    -- 遍历
			    read_loop: LOOP
			            -- 取值 
			            FETCH   cur0 INTO fieldName;
			            IF done THEN
			                LEAVE read_loop;
			             END IF;
			 
			       set @sqlStr=CONCAT("
			      			 insert into zmemory_question(tableName,row,col,error)
				                select '",tableName,"',row, '",fieldName,"',
				                case 
				                when ",fieldName,"='{length}' then '",fieldName,"长度不能超过200'
				                end 'error'
				                from ",tableName," where ",fieldName,"='{length}' 
			                ");
			                
			            PREPARE stmt from @sqlStr;
			            EXECUTE stmt;
			      
			    END LOOP;
			    CLOSE cur0;
    else
		    OPEN  cur0;     
				    -- 遍历
				    read_loop: LOOP
				            -- 取值 
				            FETCH   cur0 INTO fieldName;
				            IF done THEN
				                LEAVE read_loop;
				             END IF;
				 
				       set @sqlStr=CONCAT("
				      			 insert into zmemory_question(tableName,row,col,error)
				                select '",tableName,"',row, '",fieldName,"',
				                case 
				                when ",fieldName," is null then '",fieldName,"不能为空'
				                when ",fieldName,"='{length}' then '",fieldName,"长度不能超过200'
				                end 'error'
				                from ",tableName," where ",fieldName," is null  or ",fieldName,"='{length}'
				                ");
				                
				            PREPARE stmt from @sqlStr;
				            EXECUTE stmt;
				      
				    END LOOP;
				    CLOSE cur0;

		    SET done = FALSE;
			OPEN  cur;     
		    -- 遍历
		    read_loop: LOOP
		            -- 取值 
		            FETCH   cur INTO fieldName;
		            IF done THEN
		                LEAVE read_loop;
		             END IF;
		 
		        -- 你自己想做的操作
		       set @sqlStr=CONCAT("
		      			 insert into zmemory_question(tableName,row,col,error)
				            select '",tableName,"',row, '",fieldName,"',
				            case 
				            when ",fieldName,"='{length}' then '",fieldName,"长度不能超过200'
				            end 'error'
				            from ",tableName," where ",fieldName,"='{length}' 
		                ");
		                
		            PREPARE stmt from @sqlStr;
		            EXECUTE stmt;
		      
		    END LOOP;
		    CLOSE cur;
     end if;


       

    SET done = FALSE;
       OPEN  cur00;     
    read_loop: LOOP
            -- 取值 
            FETCH   cur00 INTO fieldName;
            IF done THEN
                LEAVE read_loop;
             END IF;
 
      set @sqlStr=CONCAT("
	      			 insert into zmemory_question(tableName,row,col,error)
	                select '",tableName,"',row, '",fieldName,"',
	                case 
	                when ",fieldName," is null then '",fieldName,"不能为空'
	                when ",fieldName," in (select ",fieldName," from ",tableName," group by ",fieldName," having count(",fieldName,") > 1)
	               			then '",fieldName,"不能重复'
	               	when ",fieldName,"='{length}' then '",fieldName,"长度不能超过200'
	                end 'error'
	                from ",tableName," where ",fieldName," is null or 
	                ",fieldName," in (select ",fieldName," from ",tableName," group by ",fieldName," having count(",fieldName,") > 1)
	                or ",fieldName,"='{length}'
	                ");
            PREPARE stmt from @sqlStr;
            EXECUTE stmt;
    END LOOP;
    CLOSE cur00;
    
     SET done = FALSE;
	      OPEN  cur6;     
	   read_loop: LOOP
	            -- 取值 
	            FETCH   cur6 INTO fieldName,tomtable,totable;
	            IF done THEN
	                LEAVE read_loop;
	             END IF;
       set @sqlStr=CONCAT("
       			insert into zmemory_question(tableName,row,col,error)
                select '",tableName,"',row, '",fieldName,"',
                case 
					when ",fieldName," is null then '",fieldName,"不能为空且请根据",tomtable,"的ID填写'
					when ",fieldName,"='{length}' then '",fieldName,"长度不能超过200'
					when ",fieldName," not in (select ID from ",tomtable," where ID is not null) and ",fieldName," not in (select importreferID from ",totable," where importreferID is not null)
					    then '请根据",tomtable,"的ID填写'
					end 'error'
					from ",tableName," where ",fieldName," is null or (",fieldName," not in (select ID from ",tomtable," where ID is not null)
					          and ",fieldName," not in (select importreferID from ",totable," where importreferID is not null))
					          or ",fieldName,"='{length}'
                ");
                
            PREPARE stmt from @sqlStr;
            EXECUTE stmt;
	     
	    END LOOP;
	    CLOSE cur6;
	    
	   SET done = FALSE;
	   OPEN  cur3;     
	   read_loop: LOOP
	            -- 取值 
	            FETCH   cur3 INTO fieldName,tomtable,totable;
	            IF done THEN
	                LEAVE read_loop;
	             END IF;
	 		
       set @sqlStr=CONCAT("
       			insert into zmemory_question(tableName,row,col,error)
                select '",tableName,"',row, '",fieldName,"',
                case 
                	when ",fieldName,"='{length}' then '",fieldName,"长度不能超过200'
					when ",fieldName," not in (select ID from ",tomtable," where ID is not null) and ",fieldName," not in (select importreferID from ",totable," where importreferID is not null)
					    then '请根据",tomtable,"的ID填写'
					end 'error'
					from ",tableName," where ",fieldName," not in (select ID from ",tomtable," where ID is not null)
					          and ",fieldName," not in (select importreferID from ",totable," where importreferID is not null)
					          or ",fieldName,"='{length}'
                ");
                
            PREPARE stmt from @sqlStr;
            EXECUTE stmt;
	     
	    END LOOP;
	    CLOSE cur3;

    SET done = FALSE;
       OPEN  cur1;     
    read_loop: LOOP
            -- 取值 
            FETCH   cur1 INTO fieldName;
            IF done THEN
                LEAVE read_loop;
             END IF;
 
       set @sqlStr=CONCAT("
       			 insert into zmemory_question(tableName,row,col,error)
                select '",tableName,"',row, '",fieldName,"',
                case 
                when ",fieldName,"='{length}' then '",fieldName,"长度不能超过200'
                when ",fieldName," REGEXP '^[0-9]*(\\.?)[0-9]*$'=0 then '",fieldName,"必须为数字'
                when length(",fieldName,")>10  then '",fieldName,"长度不能超过10'
                end 'error'
                from ",tableName," where ",fieldName," REGEXP '^[0-9]*(\\.?)[0-9]*$'=0 or length(",fieldName,")>10
                or ",fieldName,"='{length}'
                ");
            PREPARE stmt from @sqlStr;
            EXECUTE stmt;
    END LOOP;
    CLOSE cur1;

	 SET done = FALSE;
	       OPEN  cur4;     
	    read_loop: LOOP
	            -- 取值 
	            FETCH   cur4 INTO fieldName;
	            IF done THEN
	                LEAVE read_loop;
	             END IF;
	 
	       set @sqlStr=CONCAT("
	       				 insert into zmemory_question(tableName,row,col,error)
	                select '",tableName,"',row, '",fieldName,"',
	                case 
	                when ",fieldName,"='{length}' then '",fieldName,"长度不能超过200'
	                when ",fieldName," is null then '",fieldName,"不能为空且必须为数字'
	                when ",fieldName," REGEXP '^[0-9]*(\\.?)[0-9]*$'=0 then '",fieldName,"必须为数字'
	                when length(",fieldName,")>10  then '",fieldName,"长度不能超过10'
	                end 'error'
	                from ",tableName," where ",fieldName," is null or ",fieldName," REGEXP '^[0-9]*(\\.?)[0-9]*$'=0 or
	                 length(",fieldName,")>10
	                or ",fieldName,"='{length}' ");
	            PREPARE stmt from @sqlStr;
	            EXECUTE stmt;
	    END LOOP;
	    CLOSE cur4;
	    
	    
	    
	   SET done = FALSE;
	   OPEN  cur2;     
	   read_loop: LOOP
	            -- 取值 
	            FETCH   cur2 INTO fieldName;
	            IF done THEN
	                LEAVE read_loop;
	             END IF;
	 
	       set @sqlStr=CONCAT("
	       				 insert into zmemory_question(tableName,row,col,error)
	                select '",tableName,"',row, '",fieldName,"',
	                case 
	                when ",fieldName," REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'=0 then '",fieldName,"必须为日期格式'
	                end 'error'
	                from ",tableName," where  ",fieldName," REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'=0 
	                ");
	            PREPARE stmt from @sqlStr;
	            EXECUTE stmt;
	    END LOOP;
	    CLOSE cur2;
	    
	   SET done = FALSE;
	   OPEN  cur5;     
	   read_loop: LOOP
	            -- 取值 
	            FETCH   cur5 INTO fieldName;
	            IF done THEN
	                LEAVE read_loop;
	             END IF;
	 
	       set @sqlStr=CONCAT("
	       			 insert into zmemory_question(tableName,row,col,error)
	                select '",tableName,"',row, '",fieldName,"',
	                case 
	                when ",fieldName," is null then '",fieldName,"不能为空且必须为日期格式'
	                when ",fieldName," REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'=0 then '",fieldName,"必须为日期格式'
	                end 'error'
	                from ",tableName," where ",fieldName," is null or ",fieldName," REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'=0
	                ");
	            PREPARE stmt from @sqlStr;
	            EXECUTE stmt;
	    END LOOP;
	    CLOSE cur5;

	     SET done = FALSE;
	   OPEN  cur7;     
	   read_loop: LOOP
	            -- 取值 
	            FETCH   cur7 INTO fieldName;
	            IF done THEN
	                LEAVE read_loop;
	             END IF;
	 
	       set @sqlStr=CONCAT("
	       			 insert into zmemory_question(tableName,row,col,error)
	                select '",tableName,"',row, '",fieldName,"',
	                case 
	                when ",fieldName," is null then '",fieldName,"不能为空且必须为时间格式'
	                when ",fieldName," REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'=0 
	                		then '",fieldName,"必须为时间格式'
	                end 'error'
	                from ",tableName," where ",fieldName," is null or ",fieldName," 
	                		REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'=0
	                ");
	            PREPARE stmt from @sqlStr;
	            EXECUTE stmt;
	    END LOOP;
	    CLOSE cur7;
	    
       SET done = FALSE;
	    OPEN  num;     
	    read_loop: LOOP
	            -- 取值 
	            FETCH   num INTO fieldName,firstnum,lastnum;
	            IF done THEN
	                LEAVE read_loop;
	             END IF;
	 
	        -- 你自己想做的操作
	       set @sqlStr=CONCAT("
	      			 insert into zmemory_question(tableName,row,col,error)
	                select '",tableName,"',row, '",fieldName,"',
	                case 
	                when ",fieldName," is null  then '",fieldName,"不能为空且必须在",firstnum,",",lastnum,"之间'
	                when ",fieldName,"  REGEXP '^[0-9]*$'=0 then '",fieldName,"必须为整数且在",firstnum,",",lastnum,"之间'
	                when ",fieldName,">",firstnum," or ",fieldName,"<",lastnum," then '",fieldName,"必须在",firstnum,",",lastnum,"之间'
	                end 'error'
	                from ",tableName," where ",fieldName," is null or ",fieldName,"  REGEXP '^[0-9]*$'=0
						  or ",fieldName,"<",firstnum," or ",fieldName,">",lastnum,"
	                ");
	                
	            PREPARE stmt from @sqlStr;
	            EXECUTE stmt;
	      
	    END LOOP;
	    CLOSE num;

	    SET done = FALSE;
       OPEN  equal;     
	    read_loop: LOOP
	            -- 取值 
	            FETCH   equal INTO fieldName,value;
	            IF done THEN
	                LEAVE read_loop;
	             END IF;
	 
	       set @sqlStr=CONCAT("
	       			 insert into zmemory_question(tableName,row,col,error)
	                select '",tableName,"',row, '",fieldName,"',
	                case 
	                when find_in_set(",fieldName,",'",value,"')=0 then '",fieldName,"必须为在",value,"之间'
	                end 'error'
	                from ",tableName," where find_in_set(",fieldName,",'",value,"')=0
	                ");
	            PREPARE stmt from @sqlStr;
	            EXECUTE stmt;
	    END LOOP;
	    CLOSE equal;

	SET done = FALSE;
       OPEN  cur11;     
    read_loop: LOOP
            -- 取值 
            FETCH   cur11 INTO fieldName;
            IF done THEN
                LEAVE read_loop;
             END IF;
 
        set @sqlStr=CONCAT("
	      			 insert into zmemory_question(tableName,row,col,error)
	                select '",tableName,"',row, '",fieldName,"',
	                case 
	                when ",fieldName,"='{length}' then '",fieldName,"长度不能超过200'
	                end 'error'
	                from ",tableName," where ",fieldName,"='{length}' 
	                ");
            PREPARE stmt from @sqlStr;
            EXECUTE stmt;
    END LOOP;
    CLOSE cur11;

     if tableName='zmemory_optproduct'
      then
			insert into zmemory_question(tableName,row,col,error)
			select 'zmemory_optproduct',o.row,'rmbcost',
			case
			when o.rmbcost is null then 'rmbcost不能为空且必须为数字'
			when o.rmbcost='{length}' then 'rmbcost长度不能超过200'
			when o.rmbcost REGEXP '^[0-9]*(\\.?)[0-9]*$'=0 then 'rmbcost必须为数字'
			when length(o.rmbcost)>10  then 'rmbcost长度不能超过10'
			end 'error'
			from zmemory_optproduct o left join (select Distinct ID,currencyID from zmemory_opt) opt
			on o.optID=opt.ID
			where opt.currencyID=1  and o.rmbcost is null
			 or o.rmbcost REGEXP '^[0-9]*(\\.?)[0-9]*$'=0 or length(o.rmbcost)>10 or o.rmbcost='{length}';
			 
			insert into zmemory_question(tableName,row,col,error)
			select 'zmemory_optproduct',o.row,'rmbprice',
			case
			when o.rmbprice is null then 'rmbprice不能为空且必须为数字'
			when o.rmbprice='{length}' then 'rmbprice长度不能超过200'
			when o.rmbprice REGEXP '^[0-9]*(\\.?)[0-9]*$'=0 then 'rmbprice必须为数字'
			when length(o.rmbprice)>10  then 'rmbprice长度不能超过10'
			end 'error'
			from zmemory_optproduct o left join (select Distinct ID,currencyID from zmemory_opt) opt
			on o.optID=opt.ID
			where opt.currencyID=1  and o.rmbprice is null
			 or o.rmbprice REGEXP '^[0-9]*(\\.?)[0-9]*$'=0 or length(o.rmbprice)>10  or o.rmbprice='{length}';
			 
			insert into zmemory_question(tableName,row,col,error)
			select 'zmemory_optproduct',o.row,'dollarcost',
			case
			when o.dollarcost is null then 'dollarcost不能为空且必须为数字'
			when o.dollarcost='{length}' then 'dollarcost长度不能超过200'
			when o.dollarcost REGEXP '^[0-9]*(\\.?)[0-9]*$'=0 then 'dollarcost必须为数字'
			when length(o.dollarcost)>10  then 'dollarcost长度不能超过10'
			end 'error'
			from zmemory_optproduct o left join (select Distinct ID,currencyID from zmemory_opt) opt
			on o.optID=opt.ID
			where opt.currencyID=2  and o.dollarcost is null
			 or o.dollarcost REGEXP '^[0-9]*(\\.?)[0-9]*$'=0 or length(o.dollarcost)>10  or o.dollarcost='{length}';
			 
			 
			insert into zmemory_question(tableName,row,col,error)
			select 'zmemory_optproduct',o.row,'dollarprice',
			case
			when o.dollarprice is null then 'dollarprice不能为空且必须为数字'
			when o.dollarprice='{length}' then 'dollarprice长度不能超过200'
			when o.dollarprice REGEXP '^[0-9]*(\\.?)[0-9]*$'=0 then 'dollarprice必须为数字'
			when length(o.dollarprice)>10  then 'dollarprice长度不能超过10'
			end 'error'
			from zmemory_optproduct o left join (select Distinct ID,currencyID from zmemory_opt) opt
			on o.optID=opt.ID
			where opt.currencyID=2  and o.dollarprice is null
			 or o.dollarprice REGEXP '^[0-9]*(\\.?)[0-9]*$'=0 or length(o.dollarprice)>10  or o.dollarprice='{length}';
	 end if; 
end//
DELIMITER ;

-- 导出  过程 vsms.proc_import_cleanSystem 结构
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_import_cleanSystem`()
BEGIN

truncate table agency;
truncate table chartdefaultload;
truncate table city;
truncate table country;
truncate table currencyconvert;
#truncate table currencyexchange;
truncate table customeofftmp;
truncate table customer;
truncate table customercontact;
truncate table customercontacttemp;
truncate table customertemp;
truncate table debug;
truncate table empdepart;
truncate table departprofit;
truncate table empemployeedepart;
truncate table empemployeepermission;
truncate table empemployeerole;
truncate table empemployeeviewuser;
truncate table employee;
#truncate table emppermission;
truncate table empposition;
truncate table emprole;
#truncate table emprolepermission;
truncate table emptarget;
truncate table expensetype;
truncate table faranchise;
truncate table industry;
truncate table industrysub;
truncate table lead;
truncate table leadcontact;
truncate table logdictionary;
truncate table opt;
truncate table optagent;
truncate table optcompetitor;
truncate table optcontact;
truncate table optcontactrole;
truncate table optestimatesnap;
truncate table optestimatesnapproduct;
truncate table optparticipant;
truncate table optpossibility;
truncate table optproduct;
truncate table optrealsnap;
truncate table optrealsnapproduct;
truncate table optreply;
truncate table optstage;
truncate table optstageupdate;
truncate table opttype;
truncate table optviewlog;
truncate table piecearea;
truncate table procurementmethod;
truncate table product;
truncate table productbrand;
truncate table productclass;
truncate table productclassprofit;
truncate table province;
truncate table quotation;
truncate table quotationproduct;
truncate table quotationworkflow;
truncate table region;
#truncate table systemconfig;
truncate table source;
truncate table tmpascontacts;
truncate table tmpaslead;
truncate table tmpasworkplan;
truncate table town;
truncate table traffictype;
truncate table transferlog;
truncate table workplan;
truncate table workplanexpense;
truncate table workplanworktype;

INSERT INTO `emprole` (`id`, `role`, `rolediscribe`, `roleen`, `rolediscribeen`, `isdelete`,importreferid) VALUES
	(1, '管理员', '系统管理员', 'Administrator', 'System administrator', 0,'1'),
	(2, '销售', '销售人员和销售管理人员', 'Sales', 'Sales and sales manager', 0,'2'),
	(3, '产品', '产品经理，负责相关产品线维护', 'Product', 'Product maintenance', 0,'3'),
	(4, '市场', '市场专员，负责销售线索管理', 'Marketing', 'Manage sales leads', 0,'4'),
	(5, '财务', '财力审核人，负责维护和审核客户黑白名单', 'Finance', 'manage  financial datas', 0,'5'),
	(6, '客户', '客户专员，负责公司正式客户的管理和临时客户转正审核', 'Customer', 'manage customer verification', 0,'6');


INSERT into optstage(stage,id,description,descriptionen,colorvalue,importreferid) values 
	('0.00','1','丢失合同','Order failed.','#5e5e5e','1'),
	('0.10','2','了解客户需求','Understand customer needs.','#ff0000','2'),
	('0.30','3','提供客户方案','Provide customer solutions.','#ff9900','3'),
	('0.50','4','确认客户审批','Confirm customer approval.','#ffff00','4'),
	('0.70','5','参加客户投标','Attend customer bidding.','#0000ff','5'),
	('0.90','6','客户商务谈判','Customer business negotiation.','#cc00ff','6'),
	('1.00','7','成功签下订单','Get customer order.','#009900','7');

INSERT into optpossibility(possibility,description,descriptionen,id,`isdelete`,importreferid) values 
	('0.20','4家及以上竞争对手','Over four competitors','1',0,'1'),
	('0.25','3家竞争对手','Three competitors','2',0,'2'),
	('0.33','2家竞争对手','Two competitors','3',0,'3'),
	('0.50','1家竞争对手','One competitor','4',0,'4'),
	('0.80','没有竞争对手','No competitor','5',0,'5');

INSERT INTO `employee` (`id`, `empno`, `depid`, `positionid`, `fullname`, `username`, `pwd`, `email`, `gender`, `birthdaytype`, `birthday`, `fax`, `tel`, `mobile`, `officeaddr`, `status`, `superiorid`, `emailcode`, `entrydate`, `extensionnum`, `importreferid`) VALUES
	(1, 'S00001', 1, 1, '管理员', 'admin', 'e10adc3949ba59abbe56e057f20f883e', 'admin@admin.com', 0, 1, '2016-11-11', '66666666', '88888888', '1888888888', '江西南昌', 0, NULL, NULL, '2016-11-11 12:00:00', '1633',NULL);

INSERT INTO `empemployeerole` (`id`, `employeeid`, `roleid`, `importreferid`) VALUES
	(1, 1, 1, NULL);

INSERT INTO `chartdefaultload` (`id`, `charttype`, `charttypeen`, `chartvalue`) VALUES
	(1, '全部', 'All', 0),
	(2, '全部', 'All', 0),
	(3, '全部', 'All', 0);
	
-- INSERT INTO `employee` (`id`, `empno`, `depid`, `positionid`, `fullname`, `username`, `pwd`, `email`, `gender`, `birthdaytype`, `birthday`, `fax`, `tel`, `mobile`, `officeaddr`, `status`, `superiorid`, `emailcode`, `entrydate`, `extensionnum`, `importreferid`) VALUES
-- 	(1, 'S00001', 1, 1, '管理员', 'admin', 'e10adc3949ba59abbe56e057f20f883e', 'admin@admin.com', 0, 1, '2016-11-11', '66666666', '88888888', '1888888888', '江西南昌', 0, NULL, NULL, '2016-11-11 12:00:00', '1633',NULL);

-- INSERT INTO `currencyexchange` (`id`, `currencyname`, `currencysymbol`, `statisticunit`, `unitcomment`, `currencynameen`, `isdelete`, `importreferid`) VALUES
-- 	(1, '人民币', '¥', 10000.00, '10K', 'RMB', 0, '1'),
-- 	(2, '美元', '$', 1000.00, 'K', 'USB', 0, '2');
	
-- INSERT INTO `systemconfig` (`id`, `emailusername`, `emailpassword`, `emailsendaddr`, `emailsmtpaddr`, `emailsmtpport`, `emailisverification`, `isdisplayotherexpense`, `customerauditorid`, `assistantid`, `versionnum`, `snapshootperiod`, `bigoptprice`, `bigoptpriceminor`, `systemaddr`, `companyname`, `profitrelationship`, `leadreleaseperiod`, `importreferid`) VALUES
-- 	(1, 'demo@ql-crm.com', '123456aA', 'demo@ql-crm.com', 'smtp.ym.163.com', '994', 1, NULL, NULL, NULL, NULL, 31, 45.00, 30.00, NULL, '深圳市汇昌达电器有限公司', NULL, 1440, NULL);

-- INSERT INTO `emprole` (`id`, `role`, `rolediscribe`, `roleen`, `rolediscribeen`, `isdelete`, `importreferid`) VALUES
-- 	(1, '管理员', '系统管理员', 'Administrator', 'System administrator', 0, '1'),
-- 	(2, '销售', '销售人员和销售管理人员', 'Sales', 'Sales and sales manager', 0, '2'),
-- 	(3, '产品', '产品经理，负责相关产品线维护', 'Product', 'Product maintenance', 0, '3'),
-- 	(4, '市场', '市场专员，负责销售线索管理', 'Marketing', 'Manage sales leads', 0, '4'),
-- 	(5, '财务', '财力审核人，负责维护和审核客户黑白名单', 'Finance', 'manage  financial datas', 0, '5'),
-- 	(6, '客户', '客户专员，负责公司正式客户的管理和临时客户转正审核', 'Customer', 'manage customer verification', 0, '6');
	

-- INSERT into optstage(stage,id,description,descriptionen,colorvalue,importreferid) values 
-- 	('0.00','1','丢失合同','Order failed.','#5e5e5e',1),
-- 	('0.10','2','了解客户需求','Understand customer needs.','#ff0000',2),
-- 	('0.30','3','提供客户方案','Provide customer solutions.','#ff9900',3),
-- 	('0.50','4','确认客户审批','Confirm customer approval.','#ffff00',4),
-- 	('0.70','5','参加客户投标','Attend customer bidding.','#0000ff',5),
-- 	('0.90','6','客户商务谈判','Customer business negotiation.','#cc00ff',6),
-- 	('1.00','7','成功签下订单','Get customer order.','#009900',7);


-- INSERT into optpossibility(possibility,description,descriptionen,id,importreferid) values 
-- 	('0.20','4家及以上竞争对手','Over four competitors','1',1),
-- 	('0.25','3家竞争对手','Three competitors','2',2),
-- 	('0.33','2家竞争对手','Two competitors','3',3),
-- 	('0.50','1家竞争对手','One competitor','4',4),
-- 	('0.80','没有竞争对手','No competitor','5',5);
		


-- INSERT INTO `emppermission` (`id`, `permission`, `permissiondiscribe`, `url`, `permissiondiscribeen`) VALUES
-- 	(1, 'product_list', '产品列表（查看所有－导出）', NULL, NULL),
-- 	(2, 'product_redact', '产品编辑（新增、修改、删除）', NULL, NULL),
-- 	(3, 'employe_app', '员工应用', NULL, NULL),
-- 	(4, 'employee_list', '员工列表（查看所有）', NULL, NULL),
-- 	(5, 'employee_redact', '员工编辑（新增、修改、删除、锁定）', NULL, NULL),
-- 	(6, 'customer_app', '客户应用', NULL, NULL),
-- 	(7, 'customer_list', '客户列表（所有－－正式＋所有临时）', NULL, NULL),
-- 	(8, 'customer_view_list', '客户列表（所有－－正式＋可查看临时）', NULL, NULL),
-- 	(9, 'customer_official_list', '客户列表（所有－－正式）', NULL, NULL),
-- 	(10, 'customer_redact', '客户编辑（临时客户新增、临时客户修改、临时客户删除、申请审核）', NULL, NULL),
-- 	(11, 'customer_official_redact', '客户编辑（正式客户修改、审批审核、重新关联、退回）', NULL, NULL),
-- 	(12, 'customer_official_isblack', '客户编辑（黑名单）', NULL, NULL),
-- 	(13, 'customer_official_level', '客户编辑（等级、信用）', NULL, NULL),
-- 	(14, 'lead_app', '线索应用', NULL, NULL),
-- 	(15, 'lead_list', '线索列表（所有）', NULL, NULL),
-- 	(16, 'lead_view_list', '线索列表（可查看）', NULL, NULL),
-- 	(17, 'lead_sale_redact', '线索编辑（新增－－投放、删除）修改只限于销售反馈', NULL, NULL),
-- 	(18, 'lead_opt_redact', '线索编辑（抢夺、退回、转机会）', NULL, NULL),
-- 	(19, 'target_app', '销售任务应用', NULL, NULL),
-- 	(20, 'target_list', '任务列表（所有）', NULL, NULL),
-- 	(21, 'target_view_list', '任务列表（可查看）', NULL, NULL),
-- 	(22, 'target_all_redact', '任务编辑（所有人定任务，新增、编辑、删除）', NULL, NULL),
-- 	(23, 'target_view_redact', '任务编辑（可查看人定任务，新增、编辑、删除）', NULL, NULL),
-- 	(24, 'workplan_app', '工作计划应用', NULL, NULL),
-- 	(25, 'workplan_list', '工作计划列表（所有）', NULL, NULL),
-- 	(26, 'workplan_view_list', '工作计划列表（可查看）', NULL, NULL),
-- 	(27, 'workplan_redact', '工作计划编辑（新增、编辑、删除）', NULL, NULL),
-- 	(28, 'opt_app', '机会应用', NULL, NULL),
-- 	(29, 'opt_list', '机会列表（所有）', NULL, NULL),
-- 	(30, 'opt_view_list', '机会列表（可查看）', NULL, NULL),
-- 	(31, 'opt_redact', '机会编辑（新增、编辑、删除）', NULL, NULL),
-- 	(32, 'product_app', '产品应用', NULL, NULL),
-- 	(33, 'customer_official_app', '客户审核应用', NULL, NULL),
-- 	(34, 'systemconfig_app', '系统应用', NULL, NULL);
	


-- 	INSERT INTO `emprolepermission` (`id`, `roleid`, `permissionid`) VALUES
-- 	(18, 3, 32),
-- 	(19, 3, 1),
-- 	(20, 3, 2),
-- 	(21, 3, 28),
-- 	(22, 3, 30),
-- 	(23, 3, 24),
-- 	(24, 3, 27),
-- 	(25, 3, 26),
-- 	(36, 5, 6),
-- 	(37, 5, 9),
-- 	(38, 5, 13),
-- 	(39, 5, 12),
-- 	(40, 5, 24),
-- 	(41, 5, 25),
-- 	(42, 6, 6),
-- 	(43, 6, 7),
-- 	(44, 6, 33),
-- 	(45, 6, 11),
-- 	(46, 6, 24),
-- 	(47, 6, 27),
-- 	(48, 6, 26),
-- 	(54, 2, 6),
-- 	(55, 2, 10),
-- 	(56, 2, 8),
-- 	(57, 2, 14),
-- 	(58, 2, 18),
-- 	(59, 2, 16),
-- 	(60, 2, 28),
-- 	(61, 2, 31),
-- 	(62, 2, 30),
-- 	(63, 2, 32),
-- 	(64, 2, 1),
-- 	(65, 2, 19),
-- 	(66, 2, 21),
-- 	(67, 2, 23),
-- 	(68, 2, 24),
-- 	(69, 2, 27),
-- 	(70, 2, 26),
-- 	(71, 4, 6),
-- 	(72, 4, 7),
-- 	(73, 4, 33),
-- 	(74, 4, 11),
-- 	(75, 4, 14),
-- 	(76, 4, 15),
-- 	(77, 4, 17),
-- 	(78, 4, 24),
-- 	(79, 4, 27),
-- 	(80, 4, 26),
-- 	(81, 4, 10),
-- 	(82, 7, 28),
-- 	(83, 7, 29),
-- 	(84, 7, 24),
-- 	(85, 7, 27),
-- 	(86, 7, 26),
-- 	(87, 7, 31),
-- 	(88, 7, 30);
	

END//
DELIMITER ;

-- 导出  过程 vsms.proc_import_copy 结构
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_import_copy`()
begin


#insert into empemployeerole(importreferid,employeeid,roleid) 
#	select id,employeeid,roleid from zmemory_empemployeerolem;

#insert into optpossibility(possibility,description,descriptionen,importreferid,isdelete) 
#	select possibility,description,descriptionen,id,isdelete from zmemory_optpossibilitym;


insert into optstage(importreferid,description,descriptionen) 
	select id,description,descriptionen from zmemory_optstage
	on duplicate key update description=values(description),descriptionen=values(descriptionen);

REPLACE into currencyexchange(id,currencyname,currencynameen,importreferid,currencysymbol,statisticunit,unitcomment,isdelete)
 	select 1,currencyname,currencynameen,id,currencysymbol,statisticunit,unitcomment,isdelete
 	from zmemory_currencyexchange limit 0,1;

 REPLACE into currencyexchange(id,currencyname,currencynameen,importreferid,currencysymbol,statisticunit,unitcomment,isdelete)
 	select 2,currencyname,currencynameen,id,currencysymbol,statisticunit,unitcomment,isdelete
 	from zmemory_currencyexchange limit 1,2;

insert into currencyconvert(importreferid,startdate,enddate,ajtoinformula,intoajformula) 
	select id,startdate,enddate,ajtoinformula,intoajformula from zmemory_currencyconvert
	 on duplicate key update startdate=values(startdate),enddate=values(enddate)
	 ,ajtoinformula=values(ajtoinformula),intoajformula=values(intoajformula);

insert into empdepart(depart,departen,importreferid,sdepartid,level,isdelete) 
	select departcn,departen,id,sdepartid,level,isdelete from zmemory_empdepart
	on duplicate key update depart=values(depart),departen=values(departen)
	 ,sdepartid=values(sdepartid),level=values(level);
	
update zmemory_empdepart new1 
left join empdepart old1 on new1.sdepartid=old1.importreferid
set new1.sdepartid=old1.id;

update empdepart new1
set new1.sdepartid=0 order by id limit 1;

insert into empposition(position,positionen,importreferid,isdelete) 
	select positioncn,positionen,id,isdelete from zmemory_empposition
	on duplicate key update position=values(position),positionen=values(positionen);


update zmemory_employee new 
left join empdepart old1 on new.depid=old1.importreferid
set new.depid=old1.id;

update zmemory_employee new 
left join empposition old2 on new.positionid=old2.importreferid
set new.positionid=old2.id;

update zmemory_employee set pwd=MD5(pwd);

insert into employee(empno,fullname,importreferid,depid,positionid,username,pwd,email,gender,birthday,mobile,tel,extensionnum,fax,officeaddr,entrydate
,birthdaytype,status) 
	select empno,fullname,id,depid,positionid,username,pwd,email,gender,birthday,mobile,tel,extensionnum,fax,officeaddr,entrydate,birthdaytype,status
	 from zmemory_employee on duplicate key update empno=values(empno),fullname=values(fullname),depid=values(depid),positionid=values(positionid)
	 ,username=values(username),pwd=values(pwd),email=values(email),gender=values(gender),birthday=values(birthday),mobile=values(mobile)
	 ,tel=values(tel),extensionnum=values(extensionnum),fax=values(fax),officeaddr=values(officeaddr),entrydate=values(entrydate),birthdaytype=values(birthdaytype)
	 ,status=values(status);

update zmemory_empemployeerole new 
left join employee old1 on new.employeeid=old1.importreferid
set new.employeeid=old1.id;

update zmemory_empemployeerole new  
left join emprole old2 on new.roleid=old2.importreferid 
set new.roleid=old2.id;

insert into empemployeerole(importreferid,employeeid,roleid) 
	select id,employeeid,roleid from zmemory_empemployeerole
	on duplicate key update employeeid=values(employeeid),roleid=values(roleid);

update zmemory_emptarget new 
left join employee old1 on new.employeeid=old1.importreferid 
set new.employeeid=old1.id;

insert into emptarget(importreferid,employeeid,years,months,targetmoney,targetmoneyminor) 
	select id,employeeid,years,months,targetmoney,targetmoneyminor from zmemory_emptarget
	on duplicate key update employeeid=values(employeeid),years=values(years),months=values(months),targetmoney=values(targetmoney)
	,targetmoneyminor=values(targetmoneyminor);

update zmemory_empemployeeviewuser new 
left join employee old1 on new.employeeid=old1.importreferid
set new.employeeid=old1.id;

update zmemory_empemployeeviewuser new 
left join employee old2 on new.viewuserid=old2.importreferid
set new.viewuserid=old2.id;

insert into empemployeeviewuser(importreferid,employeeid,viewuserid) 
	select id,employeeid,viewuserid from zmemory_empemployeeviewuser
	on duplicate key update employeeid=values(employeeid),viewuserid=values(viewuserid);

update zmemory_empemployeedepart new 
left join employee old1 on new.employeeid=old1.importreferid 
set new.employeeid=old1.id;

update zmemory_empemployeedepart new 
left join emptarget old2 on new.departid=old2.importreferid 
set new.departid=old2.id;

insert into empemployeedepart(importreferid,employeeid,departid) 
	select id,employeeid,departid from zmemory_empemployeedepart
	on duplicate key update employeeid=values(employeeid),departid=values(departid);

insert into productbrand(brandname,brandnameen,importreferid,isdelete) 
	select brandnamecn,brandnameen,id,isdelete from zmemory_productbrand
	on duplicate key update brandname=values(brandname),brandnameen=values(brandnameen)
	,isdelete=values(isdelete);

update zmemory_productclass new 
left join productbrand old1 on new.brandid=old1.importreferid
set new.brandid=old1.id;

insert into productclass(classname,classnameen,importreferid,brandid,isdelete) 
	select classnamecn,classnameen,id,brandid,isdelete from zmemory_productclass
	on duplicate key update classname=values(classname),classnameen=values(classnameen)
	,brandid=values(brandid),isdelete=values(isdelete);

update zmemory_product new 
left join productbrand old1 on new.brandid=old1.importreferid 
set new.brandid=old1.id;

update zmemory_product new 
left join productclass old2 on new.classid=old2.importreferid 
set  new.classid=old2.id;

update zmemory_product new 
left join employee old3 on new.pmid=old3.importreferid 
set new.pmid=old3.id;


insert into product(productno,productmodel,productname,importreferid,specification,productdiscribe,brandid,classid,pmid,rmbcost,rmbprice,dollarcost,dollarprice,isdelete) 
	select productno,productmodel,productname,id,specification,productdiscribe,brandid,classid,pmid,rmbcost,rmbprice,dollarcost,dollarprice,isdelete
	from zmemory_product
	on duplicate key update productno=values(productno),productmodel=values(productmodel),productname=values(productname),specification=values(specification)
	,productdiscribe=values(productdiscribe),brandid=values(brandid),classid=values(classid),pmid=values(pmid),rmbcost=values(rmbcost),rmbprice=values(rmbprice)
	,dollarcost=values(dollarcost),dollarprice=values(dollarprice),isdelete=values(isdelete);

insert into country(country,countryen,importreferid,isdelete) 
	select country,countryen,id,isdelete from zmemory_country
	on duplicate key update country=values(country),countryen=values(countryen)
	,isdelete=values(isdelete);

update zmemory_region new 
left join country old1 on new.countryid=old1.importreferid 
set new.countryid=old1.id;

insert into region(region,regionen,importreferid,countryid,isdelete) select region,regionen,id,countryid,isdelete 
	from zmemory_region
	on duplicate key update region=values(region),regionen=values(regionen),countryid=values(countryid),isdelete=values(isdelete);

update zmemory_province new 
left join region old1 on new.regionid=old1.importreferid
set new.regionid=old1.id;

insert into province(province,provinceen,importreferid,regionid,isdelete) 
	select province,provinceen,id,regionid,isdelete from zmemory_province
	on duplicate key update province=values(province),provinceen=values(provinceen),regionid=values(regionid),isdelete=values(isdelete);

update zmemory_city new 
left join province old1 on new.provinceid=old1.importreferid
set new.provinceid=old1.id;

insert into city(city,cityen,importreferid,provinceid,isdelete) 
	select city,cityen,id,provinceid,isdelete from zmemory_city
	on duplicate key update city=values(city),cityen=values(cityen),provinceid=values(provinceid),isdelete=values(isdelete);

update zmemory_town new 
left join city old1 on new.cityid=old1.importreferid
set new.cityid=old1.id;

insert into town(town,townen,importreferid,cityid,isdelete) 
	select town,townen,id,cityid,isdelete from zmemory_town
	on duplicate key update town=values(town),townen=values(townen),cityid=values(cityid),isdelete=values(isdelete);

update zmemory_piecearea new 
left join town old1 on new.townid=old1.importreferid
set new.townid=old1.id;

insert into piecearea(piecearea,pieceareaen,importreferid,townid,isdelete) 
	select piecearea,pieceareaen,id,townid,isdelete from zmemory_piecearea
	on duplicate key update piecearea=values(piecearea),pieceareaen=values(pieceareaen),townid=values(townid),isdelete=values(isdelete);

insert into industry(industry,industryen,importreferid,isdelete) 
	select industry,industryen,id,isdelete from zmemory_industry
	on duplicate key update industry=values(industry),industryen=values(industryen),isdelete=values(isdelete);

update zmemory_industrysub new 
left join industry old1 on new.industryid=old1.importreferid
set new.industryid=old1.id;

insert into industrysub(industrysub,industrysuben,importreferid,industryid,isdelete) 
	select industrysub,industrysuben,id,industryid,isdelete from zmemory_industrysub
	on duplicate key update industrysub=values(industrysub),industrysuben=values(industrysuben),industryid=values(industryid),isdelete=values(isdelete);

update zmemory_customer new 
left join country old1 on new.countryid=old1.importreferid
set new.countryid=old1.id;

update zmemory_customer new 
left join region old2 on new.regionid=old2.importreferid
set new.regionid=old2.id; 

update zmemory_customer new 
left join province old3 on new.provinceid=old3.importreferid
set new.provinceid=old3.id;

update zmemory_customer new 
left join city old4 on new.cityid=old4.importreferid
set new.cityid=old4.id;

update zmemory_customer new 
left join town old5 on new.townid=old5.importreferid
set new.townid=old5.id;

update zmemory_customer new 
left join piecearea old6 on new.pieceareaid=old6.importreferid
set new.pieceareaid=old6.id;

update zmemory_customer new 
left join industry old7 on new.industryid=old7.importreferid
set new.industryid=old7.id;

update zmemory_customer new 
left join industrysub old8 on new.industrysubid=old8.importreferid
set new.industrysubid=old8.id;


insert into customer(customerno,customername,importreferid,addr,countryid,regionid,provinceid,cityid,townid,pieceareaid,industryid,industrysubid,remark
	,customerlevel,customercredit,isdelete,isblacklist) 
	select customerno,customername,id,addr,countryid,regionid,provinceid,cityid,townid,pieceareaid,industryid,industrysubid,remark,customerlevel,customercredit
	,isdelete,isblacklist
	 from zmemory_customer
	on duplicate key update customerno=values(customerno),customername=values(customername),addr=values(addr),countryid=values(countryid)
	,regionid=values(regionid),provinceid=values(provinceid),cityid=values(cityid),townid=values(townid),pieceareaid=values(pieceareaid),industryid=values(industryid)
	,industrysubid=values(cityid),remark=values(remark),customerlevel=values(customerlevel),customercredit=values(customercredit)
	,isdelete=values(isdelete),isblacklist=values(isblacklist);
	
update zmemory_customercontact new 
left join customer old1 on new.customerid=old1.importreferid
set new.customerid=old1.id ;

update zmemory_customercontact new 
left join employee old2 on new.ownerid=old2.importreferid
set   new.ownerid=old2.id;

update zmemory_customercontact new 
left join employee old3 on new.createrid=old3.importreferid
set new.createrid=old3.id;

insert into customercontact(customerid,ownerid,createrid,fullname,importreferid,sex,depart,position,tel,mobile,fax,email,wechat,qq,addr,remark
,isdelete,birthdaytype,createdatetime,isdimission) 
	select customerid,ownerid,createrid,fullname,id,sex,depart,position,tel,mobile,fax,email,wechat,qq,address,remark
	,isdelete,birthdaytype,createdatetime,isdimission
	from zmemory_customercontact
	on duplicate key update customerid=values(customerid),ownerid=values(ownerid),createrid=values(createrid),fullname=values(fullname)
	,sex=values(sex),depart=values(depart),position=values(position),tel=values(tel),mobile=values(mobile),fax=values(fax)
	,email=values(email),wechat=values(wechat),qq=values(qq),addr=values(addr),remark=values(remark),isdelete=values(isdelete)
	,birthdaytype=values(birthdaytype),createdatetime=values(createdatetime),isdimission=values(isdimission);
	
insert into workplanworktype(worktype,benefit,worktypeen,importreferid,isdelete) 
	select worktype,benefit,worktypeen,id,isdelete from zmemory_workplanworktype
	on duplicate key update worktype=values(worktype),benefit=values(benefit),worktypeen=values(worktypeen),isdelete=values(isdelete);

insert into source(source,sourceen,importreferid,isdelete) 
	select source,sourceen,id,isdelete from zmemory_source
	on duplicate key update source=values(source),sourceen=values(sourceen),isdelete=values(isdelete);
	
insert into opttype(opttype,opttypeen,importreferid,isdelete) 
	select opttype,opttypeen,id,isdelete from zmemory_opttype
	on duplicate key update opttype=values(opttype),opttypeen=values(opttypeen),isdelete=values(isdelete);
	
insert into optcontactrole(role,roleen,importreferid,isdelete) 
	select rolecn,roleen,id,isdelete from zmemory_optcontactrole
	on duplicate key update role=values(role),roleen=values(roleen),isdelete=values(isdelete);
	
insert into procurementmethod(procurementmethodname,procurementmethodnameen,importreferid,isdelete) 
	select procurementmethodname,procurementmethodnameen,id,isdelete from zmemory_procurementmethod
	on duplicate key update procurementmethodname=values(procurementmethodname),procurementmethodnameen=values(procurementmethodnameen)
	,isdelete=values(isdelete);
	
insert into faranchise(faranchisename,faranchisenameen,importreferid,faranchisevalue,faranchiseminor,isdelete) 
	select faranchisename,faranchisenameen,id,faranchisevalue,faranchiseminor,isdelete 
	from zmemory_faranchise
	on duplicate key update faranchisename=values(faranchisename),faranchisenameen=values(faranchisenameen)
	,faranchisevalue=values(faranchisevalue),faranchiseminor=values(faranchiseminor),isdelete=values(isdelete);

update zmemory_opt new 
left join source old1 on new.sourceid=old1.importreferid
set new.sourceid=old1.id;

update zmemory_opt new 
left join customer old1 on new.customerid=old1.importreferid
set new.customerid=old1.id;

update zmemory_opt new 
left join employee old2 on new.ownerid=old2.importreferid
set new.ownerid=old2.id;

update zmemory_opt new 
left join employee old3 on new.createrid=old3.importreferid
set new.createrid=old3.id;

update zmemory_opt new 
left join faranchise old4 on new.faranchiseid=old4.importreferid
set new.faranchiseid=old4.id;

update zmemory_opt new 
left join currencyexchange old5 on new.currencyid=old5.importreferid
set new.currencyid=old5.id;

update zmemory_opt new 
left join optstage old6 on new.stageid=old6.importreferid
set new.stageid=old6.id;

update zmemory_opt new 
left join optpossibility old7 on new.possibilityid=old7.importreferid
set new.possibilityid=old7.id;

update zmemory_opt new 
left join opttype old8 on new.opttype=old8.importreferid
set new.opttype=old8.id;

update zmemory_opt new 
left join procurementmethod old9 on new.procurementmethodid=old9.importreferid
set new.procurementmethodid=old9.id;


insert into opt(optno,optname,sourceid,importreferid,customerid,ownerid,createrid,createdatetime,faranchiseid,currencyid,planoverdate,realityoverdate,stageid,possibilityid,confidenceindex,opttype,optstatus,optlevel,procurementmethodid,remark,isdelete) 
	select optno,optname,sourceid,id,customerid,ownerid,createrid,createdatetime,faranchiseid,currencyid,planoverdate,realityoverdate,stageid,possibilityid,confidenceindex,opttype,optstatus,optlevel,procurementmethodid,remark,isdelete
	from zmemory_opt 
	on duplicate key update optno=values(optno),optname=values(optname),sourceid=values(sourceid),customerid=values(customerid)
	,ownerid=values(ownerid),createrid=values(createrid),createdatetime=values(createdatetime)
	,faranchiseid=values(faranchiseid),currencyid=values(currencyid)
	,planoverdate=values(planoverdate),realityoverdate=values(realityoverdate),stageid=values(stageid),possibilityid=values(possibilityid),confidenceindex=values(confidenceindex)
	,opttype=values(opttype),optstatus=values(optstatus),optlevel=values(optlevel),procurementmethodid=values(procurementmethodid),remark=values(remark),isdelete=values(isdelete);

update zmemory_optproduct new 
left join opt old1 on new.optid=old1.importreferid
set new.optid=old1.id;

update zmemory_optproduct new 
left join product old2 on new.productid=old2.importreferid
set new.productid=old2.id;

update zmemory_optproduct new 
left join employee old3 on new.pmid=old3.importreferid
set new.pmid=old3.id;

insert into optproduct(importreferid,optid,productmodel,productname,productid,brandname,classname,specification,productdiscribe,pmid,rmbprice,rmbcost,dollarprice,dollarcost,num,discount,remark) 
	select id,optid,productmodel,productname,productid,brandname,classname,specification,productdiscribe,pmid,rmbprice,rmbcost,dollarprice,dollarcost,num,discount,remark 
	from zmemory_optproduct
	on duplicate key update optid=values(optid),productmodel=values(productmodel),productname=values(productname),productid=values(productid)
	,brandname=values(brandname),classname=values(classname),specification=values(specification),productdiscribe=values(productdiscribe)
	,pmid=values(pmid),rmbprice=values(rmbprice),rmbcost=values(rmbcost),dollarprice=values(dollarprice)
	,dollarcost=values(dollarcost),num=values(num),discount=values(discount),remark=values(remark);

update zmemory_optcontact new 
left join opt old1 on new.optid=old1.importreferid
set new.optid=old1.id;

update zmemory_optcontact new 
left join customercontact old2 on new.contactid=old2.importreferid
set new.contactid=old2.id;


insert into optcontact(importreferid,optid,fullname,contactid,role,sex,depart,position,tel,mobile,fax,email,qq,wechat,addr,remark) 
	select id,optid,fullname,contactid,role,sex,depart,position,tel,mobile,fax,email,qq,wechat,address,remark
	from zmemory_optcontact
	on duplicate key update optid=values(optid),fullname=values(fullname)
	,contactid=values(contactid),role=values(role),sex=values(sex)
	,depart=values(depart),position=values(position),tel=values(tel)
	,mobile=values(mobile),fax=values(fax),email=values(email),qq=values(qq),wechat=values(wechat),addr=values(addr),remark=values(remark);


REPLACE into systemconfig(id,importreferid,emailusername,emailpassword,emailsendaddr,emailsmtpaddr,emailsmtpport,emailisverification,snapshootperiod,bigoptprice,bigoptpriceminor,companyname,leadreleaseperiod) 
	select 1,id,emailusername,emailpassword,emailsendaddr,emailsmtpaddr,emailsmtpport,emailisverification,snapshootperiod,bigoptprice,bigoptpriceminor,companyname,leadreleaseperiod
	from zmemory_systemconfig;

end//
DELIMITER ;

-- 导出  过程 vsms.proc_import_createMemoryTable 结构
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_import_createMemoryTable`()
begin
DROP TABLE IF exists `zmemory_currencyexchange`;
CREATE TABLE IF NOT exists `zmemory_currencyexchange` (
  `row` varchar(200) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL COMMENT '00' ,
  `currencyname` varchar(200) DEFAULT NULL COMMENT '0',
  `currencysymbol` varchar(200) DEFAULT NULL COMMENT '0',
  `statisticunit` varchar(200) DEFAULT NULL COMMENT '4',
  `unitcomment` varchar(200) DEFAULT NULL COMMENT '0',
  `currencynameen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` varchar(200) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 ;

DROP TABLE IF exists `zmemory_currencyconvert`;
CREATE TABLE IF NOT exists `zmemory_currencyconvert` (
  `row` varchar(200) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL COMMENT '00',
  `startdate` varchar(200) DEFAULT NULL COMMENT '5',
  `enddate` varchar(200) DEFAULT NULL COMMENT '5',
  `ajtoinformula` varchar(200) DEFAULT NULL COMMENT '4',
  `intoajformula` varchar(200) DEFAULT NULL COMMENT '4'
) ENGINE=MEMORY DEFAULT CHARSET=utf8  ;


DROP TABLE IF exists `zmemory_empdepart`;
CREATE TABLE IF NOT exists `zmemory_empdepart` (
  `row` varchar(200) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `departcn` varchar(200) DEFAULT NULL COMMENT '0',
  `sdepartid` varchar(200) DEFAULT NULL COMMENT '6zmemory_empdepart',
  `level` varchar(200) DEFAULT NULL COMMENT '4',
  `sort` varchar(200) DEFAULT NULL COMMENT '',  
  `departen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` varchar(200) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 ;

DROP TABLE IF exists `zmemory_empposition`;
CREATE TABLE IF NOT exists `zmemory_empposition` (
  `row` varchar(200) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `positioncn` varchar(200) DEFAULT NULL COMMENT '0',
  `positionen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` varchar(200) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8;

DROP TABLE IF exists `zmemory_emprole`;
CREATE TABLE IF NOT exists `zmemory_emprole` (
  `row` varchar(200) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '',
  `role` varchar(200) DEFAULT NULL COMMENT '',
  `rolediscribe` varchar(200) COMMENT '',
  `roleen` varchar(200) DEFAULT NULL COMMENT '',
  `rolediscribeen` varchar(200) DEFAULT NULL COMMENT '',
  `isdelete` varchar(200) DEFAULT '0' COMMENT  ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8;


DROP TABLE IF exists `zmemory_employee`; #18
CREATE TABLE IF NOT exists `zmemory_employee` (
  `row` varchar(200) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `empno` varchar(200) DEFAULT NULL COMMENT '0',
  `depid` varchar(200) DEFAULT NULL COMMENT '6zmemory_empdepart',
  `positionid` varchar(200) DEFAULT NULL COMMENT '6zmemory_empposition',
  `fullname` varchar(200) DEFAULT NULL COMMENT '0',
  `username` varchar(200) DEFAULT NULL COMMENT '00',
  `pwd` varchar(200) DEFAULT NULL COMMENT '0',
  `email` varchar(200) DEFAULT NULL COMMENT '0',
  `gender` varchar(200) DEFAULT NULL COMMENT 'num,0,1' ,
  `birthdaytype` varchar(200) DEFAULT '1' COMMENT '', #默认阳历
  `birthday` varchar(200) DEFAULT NULL COMMENT '5',
  `fax` varchar(200) DEFAULT NULL COMMENT '0',
  `tel` varchar(200) DEFAULT NULL COMMENT '0',
  `mobile` varchar(200) DEFAULT NULL COMMENT '0',
  `officeaddr` varchar(200) DEFAULT NULL COMMENT '0',
  `status` varchar(200) DEFAULT '0' COMMENT '',  #默认正常
  `superiorid` varchar(200) DEFAULT NULL COMMENT '',  
  `emailcode` varchar(200) DEFAULT NULL COMMENT '',   
  `entrydate` varchar(200) DEFAULT NULL COMMENT '2',
  `extensionnum` varchar(200) DEFAULT NULL COMMENT '11'
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='员工表';

DROP TABLE IF exists `zmemory_empemployeerole`;
CREATE TABLE IF NOT exists `zmemory_empemployeerole` (
  `row` varchar(200) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `employeeid` varchar(200) DEFAULT NULL COMMENT '6zmemory_employee',
  `roleid` varchar(200) DEFAULT NULL COMMENT '6zmemory_emprole'
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 ;

DROP TABLE IF exists `zmemory_emptarget`;
CREATE TABLE IF NOT exists `zmemory_emptarget` (
  `row` varchar(200) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `employeeid` varchar(200) DEFAULT NULL COMMENT '6zmemory_employee',
  `years` varchar(200) DEFAULT NULL COMMENT 'num,1901,2155',
  `months` varchar(200) DEFAULT NULL COMMENT 'num,1,12',
  `targetmoney` varchar(200) DEFAULT NULL COMMENT '4',
  `targetmoneyminor` varchar(200) DEFAULT NULL COMMENT '4'
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='销售任务表';

DROP TABLE IF exists `zmemory_empemployeeviewuser`;
CREATE TABLE IF NOT exists `zmemory_empemployeeviewuser` (
  `row` varchar(200) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `employeeid` varchar(200) DEFAULT NULL COMMENT '6zmemory_employee',
  `viewuserid` varchar(200) DEFAULT NULL COMMENT '6zmemory_employee'
) ENGINE=MEMORY DEFAULT CHARSET=utf8 COMMENT='员工-可查看用户对应表';

DROP TABLE IF exists `zmemory_empemployeedepart`;
CREATE TABLE IF NOT exists `zmemory_empemployeedepart` (
  `row` varchar(200) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `employeeid` varchar(200) DEFAULT NULL COMMENT '6zmemory_employee',
  `departid` varchar(200) DEFAULT NULL COMMENT '6zmemory_empdepart'
) ENGINE=MEMORY DEFAULT CHARSET=utf8 COMMENT='员工-可查看部门对应表';

DROP TABLE IF exists `zmemory_productbrand`; 
CREATE TABLE IF NOT exists `zmemory_productbrand` (
  `row` varchar(200) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `brandnamecn` varchar(200) DEFAULT NULL COMMENT '0',
  `brandnameen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` varchar(200) DEFAULT '0' COMMENT  ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='品牌表';  

DROP TABLE IF exists `zmemory_productclass`;
CREATE TABLE IF NOT exists `zmemory_productclass` (
  `row` varchar(200) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `brandid` varchar(200) DEFAULT NULL COMMENT '6zmemory_productbrand',
  `classnamecn` varchar(200) DEFAULT NULL COMMENT '0',
  `classnameen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` varchar(200) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='类别表';

DROP TABLE IF exists `zmemory_product`;
CREATE TABLE IF NOT exists `zmemory_product` (
  `row` varchar(200) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `productno` varchar(200) DEFAULT NULL COMMENT '0',
  `brandid` varchar(200) DEFAULT NULL COMMENT '6zmemory_productbrand',
  `classid` varchar(200) DEFAULT NULL COMMENT '6zmemory_productclass',
  `pmid` varchar(200) DEFAULT NULL COMMENT '6zmemory_employee',
  `productname` varchar(200) DEFAULT NULL COMMENT '0',
  `productmodel` varchar(200) DEFAULT NULL COMMENT '0',
  `specification` varchar(200) DEFAULT NULL COMMENT '11',
  `rmbcost` varchar(200) DEFAULT NULL COMMENT '4',
  `rmbprice` varchar(200) DEFAULT NULL COMMENT '4',
  `dollarcost` varchar(200) DEFAULT NULL COMMENT '4',
  `dollarprice` varchar(200) DEFAULT NULL COMMENT '4',
  `productdiscribe` varchar(200) DEFAULT NULL COMMENT '11',
  `isdelete` varchar(200) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='产品表';

DROP TABLE IF exists `zmemory_country`;
CREATE TABLE IF NOT exists `zmemory_country` (
  `row` varchar(200) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL COMMENT '00',
  `country` varchar(200) DEFAULT NULL COMMENT '0',
  `countryen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` varchar(200) DEFAULT '0' COMMENT ''

) ENGINE=MEMORY DEFAULT CHARSET=utf8 COMMENT='国家表';

-- 数据导出ms.region 结构
DROP TABLE IF exists `zmemory_region`;
CREATE TABLE IF NOT exists `zmemory_region` (
  `row` varchar(200) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `countryid` varchar(200) DEFAULT NULL COMMENT '6zmemory_country',
  `region` varchar(200) DEFAULT NULL COMMENT '0',
  `regionen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` varchar(200) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='地域表';

DROP TABLE IF exists `zmemory_province`;
CREATE TABLE IF NOT exists `zmemory_province` (
  `row` varchar(200) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `regionid` varchar(200) DEFAULT NULL COMMENT '6zmemory_region',
  `province` varchar(200) DEFAULT NULL COMMENT '0',
  `provinceen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` varchar(200) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='省份表';

DROP TABLE IF exists `zmemory_city`;
CREATE TABLE IF NOT exists `zmemory_city` (
  `row` varchar(200) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `provinceid` varchar(200) DEFAULT NULL COMMENT '6zmemory_province',
  `city` varchar(200) DEFAULT NULL COMMENT '0',
  `cityen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` varchar(200) DEFAULT '0' COMMENT ''

) ENGINE=MEMORY DEFAULT CHARSET=utf8 COMMENT='城市表';

DROP TABLE IF exists `zmemory_town`;
CREATE TABLE IF NOT exists `zmemory_town` (
  `row` varchar(200) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `cityid` varchar(200) DEFAULT NULL COMMENT '6zmemory_city',
  `town` varchar(200) DEFAULT NULL COMMENT '0',
  `townen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` varchar(200) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY DEFAULT CHARSET=utf8 COMMENT='辖区表';


DROP TABLE IF exists `zmemory_piecearea`;
CREATE TABLE IF NOT exists `zmemory_piecearea` (
  `row` varchar(200) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `townid` varchar(200) DEFAULT NULL COMMENT '6zmemory_town',
  `piecearea` varchar(200) DEFAULT NULL COMMENT '0',
  `pieceareaen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` varchar(200) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY DEFAULT CHARSET=utf8 COMMENT='片区表';

DROP TABLE IF exists `zmemory_industry`;
CREATE TABLE IF NOT exists `zmemory_industry` (
  `row` varchar(200) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `industry` varchar(200) DEFAULT NULL COMMENT '0',
  `industryen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` varchar(200) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='行业表';

DROP TABLE IF exists `zmemory_industrysub`;
CREATE TABLE IF NOT exists `zmemory_industrysub` (
  `row` varchar(200) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `industryid` varchar(200) DEFAULT NULL COMMENT '6zmemory_industrysub',
  `industrysub` varchar(200) DEFAULT NULL COMMENT '0',
  `industrysuben` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` varchar(200) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='子行业表';
  
DROP TABLE IF exists `zmemory_customer`;
CREATE TABLE IF NOT exists `zmemory_customer` (
  `row` varchar(200) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `countryid` varchar(200) DEFAULT NULL COMMENT '6zmemory_country',
  `regionid` varchar(200) DEFAULT NULL COMMENT '6zmemory_region',
  `provinceid` varchar(200) DEFAULT NULL COMMENT '6zmemory_province',
  `cityid` varchar(200) DEFAULT NULL COMMENT '3zmemory_city',
  `townid` varchar(200) DEFAULT NULL COMMENT '3zmemory_town',
  `pieceareaid` varchar(200) DEFAULT NULL COMMENT '3zmemory_piecearea',
  `industryid` varchar(200) DEFAULT NULL COMMENT '6zmemory_industry',
  `industrysubid` varchar(200) DEFAULT NULL COMMENT '3zmemory_industrysub',
  `customerno` varchar(200) DEFAULT NULL COMMENT '0',
  `customerlevel` varchar(10) DEFAULT NULL COMMENT 'equal,A,B,C,D',
  `customercredit` varchar(10) DEFAULT NULL COMMENT 'equal,A,B,C,D',
  `customername` varchar(200) DEFAULT NULL COMMENT '0',
  `customerattribute1` varchar(200) DEFAULT NULL COMMENT '',
  `customerattribute2` varchar(200) DEFAULT NULL COMMENT '',
  `customerattribute3` varchar(200) DEFAULT NULL COMMENT '',
  `customerattribute4` varchar(200) DEFAULT NULL COMMENT '',
  `addr` varchar(200) DEFAULT NULL COMMENT '0',
  `isdelete` varchar(200) DEFAULT '0' COMMENT '',
  `isblacklist` varchar(200) DEFAULT '0' COMMENT '',
  `remark` varchar(200) COMMENT '11'
) ENGINE=MEMORY DEFAULT CHARSET=utf8 COMMENT='客户表';

DROP TABLE IF exists `zmemory_customercontact`;
CREATE TABLE IF NOT exists `zmemory_customercontact` (
  `row` varchar(200) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `customerid` varchar(200) DEFAULT NULL COMMENT '6zmemory_customer',
  `fullname` varchar(200) DEFAULT NULL COMMENT '0',
  `sex` varchar(200) DEFAULT NULL COMMENT 'num,0,1',
  `tel` varchar(200) DEFAULT NULL COMMENT '0',
  `mobile` varchar(200) DEFAULT NULL COMMENT '0',
  `fax` varchar(200) DEFAULT NULL COMMENT '0',
  `birthdaytype` varchar(200) DEFAULT '1' COMMENT '',
  `birthday` varchar(200) DEFAULT NULL COMMENT '',
  `email` varchar(200) DEFAULT NULL COMMENT '11',
  `qq` varchar(200) DEFAULT NULL COMMENT '11',
  `wechat` varchar(200) DEFAULT NULL COMMENT '11',
  `position` varchar(200) DEFAULT NULL COMMENT '0',
  `depart` varchar(200) DEFAULT NULL COMMENT '0',
  `address` varchar(200) DEFAULT NULL COMMENT '11',
  `remark` varchar(200) COMMENT '11',
  `createrid` varchar(200) DEFAULT NULL COMMENT '6zmemory_employee',
  `createdatetime` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '',
  `ownerid` varchar(200) DEFAULT NULL COMMENT '6zmemory_employee',
  `isdimission` varchar(200) DEFAULT '0' COMMENT '',
  `isdelete` varchar(200) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='客户联系人表';

DROP TABLE IF exists `zmemory_workplanworktype`;
CREATE TABLE IF NOT exists `zmemory_workplanworktype` (
  `row` varchar(200) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `worktype` varchar(200) DEFAULT NULL COMMENT '0',
  `benefit` varchar(200) DEFAULT '1' COMMENT '',
  `worktypeen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` varchar(200) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='工作计划工作类别表';

DROP TABLE IF exists `zmemory_source`;
CREATE TABLE IF NOT exists `zmemory_source` (
  `row` varchar(200) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `source` varchar(200) DEFAULT NULL COMMENT '0',
  `sourceen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` varchar(200) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='来源表';

DROP TABLE IF exists `zmemory_opttype`;
CREATE TABLE IF NOT exists `zmemory_opttype` (
  `row` varchar(200) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `opttype` varchar(200) DEFAULT NULL COMMENT '0',
  `opttypeen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` varchar(200) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='机会类型';

DROP TABLE IF exists `zmemory_optstage`;
CREATE TABLE IF NOT exists `zmemory_optstage` (
  `row` varchar(200) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '',
  `stage` varchar(200) DEFAULT NULL COMMENT '',
  `colorvalue` varchar(10) DEFAULT NULL COMMENT '',
  `description` varchar(200) DEFAULT NULL COMMENT '0',
  `descriptionen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` varchar(200) DEFAULT '0' COMMENT '',
  UNIQUE INDEX `Index` (`ID`)
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='机会进展阶段表';

DROP TABLE IF exists `zmemory_optpossibility`;
CREATE TABLE IF NOT exists `zmemory_optpossibility` (
  `row` varchar(200) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '',
  `possibility` varchar(200) DEFAULT NULL COMMENT '',
  `description` varchar(200) DEFAULT NULL COMMENT '',
  `descriptionen` varchar(200) DEFAULT NULL COMMENT '',
  `isdelete` varchar(200) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='竞争机会表';

DROP TABLE IF exists `zmemory_optcontactrole`;
CREATE TABLE IF NOT exists `zmemory_optcontactrole` (
  `row` varchar(200) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `rolecn` varchar(200) DEFAULT NULL COMMENT '0',
  `roleen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` varchar(200) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY DEFAULT CHARSET=utf8 COMMENT='联系人角色表';

DROP TABLE IF exists `zmemory_procurementmethod`;
CREATE TABLE IF NOT exists `zmemory_procurementmethod` (
  `row` varchar(200) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL COMMENT '00',
  `procurementmethodname` varchar(200) DEFAULT NULL COMMENT '0',
  `procurementmethodnameen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` varchar(200) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='采购方式';

DROP TABLE IF exists `zmemory_faranchise`;
CREATE TABLE IF NOT exists `zmemory_faranchise` (
  `row` varchar(200) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL COMMENT '00',
  `faranchisename` varchar(200) DEFAULT NULL COMMENT '0',
  `faranchisevalue` varchar(200) DEFAULT NULL COMMENT '4',
  `faranchiseminor` varchar(200) DEFAULT NULL COMMENT '4',
  `faranchisenameen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` varchar(200) DEFAULT '0' COMMENT  ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='代理商表';

DROP TABLE IF exists `zmemory_opt`;
CREATE TABLE IF NOT exists `zmemory_opt` (
  `row` varchar(200) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `optno` varchar(200) DEFAULT NULL COMMENT '0',
  `leadid` varchar(200) DEFAULT NULL COMMENT '',
  `sourceid` varchar(200) DEFAULT NULL COMMENT '6zmemory_source',
  `customerid` varchar(200) DEFAULT NULL COMMENT '6zmemory_customer',
  `opttype` varchar(200) DEFAULT NULL COMMENT '6zmemory_opttype',
  `optname` varchar(200) DEFAULT NULL COMMENT '0',
  `totalprice` varchar(200) DEFAULT NULL COMMENT '',
  `totalcost` varchar(200) DEFAULT NULL COMMENT '',
  `totalpriceminor` varchar(200) DEFAULT NULL COMMENT '',
  `totalcostminor` varchar(200) DEFAULT NULL COMMENT '',
  `optexpend` varchar(200) DEFAULT NULL COMMENT '',
  `otherexpend` varchar(200) DEFAULT NULL COMMENT '',
  `planoverdate` varchar(200) DEFAULT NULL COMMENT '5',
  `realityoverdate` varchar(200) DEFAULT NULL COMMENT '2',
  `possibilityid` varchar(200) DEFAULT NULL COMMENT '6zmemory_optpossibility',
  `stageid` varchar(200) DEFAULT NULL COMMENT '6zmemory_optstage',
  `createrid` varchar(200) DEFAULT NULL COMMENT '6zmemory_employee',
  `createdatetime` varchar(200) DEFAULT NULL COMMENT '7',
  `confidenceindex` varchar(200) DEFAULT NULL COMMENT 'equal,0.25,0.5,0.75,0.9',
  `optstatus` varchar(200) DEFAULT NULL COMMENT 'num,1,2',
  `optlevel` varchar(200) DEFAULT NULL COMMENT 'num,1,3',
  `isdelete` varchar(200) DEFAULT '0' COMMENT '',
  `remark` varchar(200) DEFAULT NULL COMMENT '11',
  `ownerid` varchar(200) DEFAULT NULL COMMENT '6zmemory_employee',
  `procurementmethodid` varchar(200) DEFAULT NULL COMMENT '6zmemory_procurementmethod',
  `faranchiseid` varchar(200) DEFAULT NULL COMMENT '6zmemory_faranchise',
  `currencyid` varchar(200) DEFAULT NULL COMMENT '6zmemory_currencyexchange'
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='销售机会表';

DROP TABLE IF exists `zmemory_optproduct`;
CREATE TABLE IF NOT exists `zmemory_optproduct` (
  `row` varchar(200) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `optid` varchar(200) DEFAULT NULL COMMENT '6zmemory_opt',
  `brandname` varchar(200) DEFAULT NULL COMMENT '0',
  `classname` varchar(200) DEFAULT NULL COMMENT '0',
  `productid` varchar(200) DEFAULT NULL COMMENT '6zmemory_product',
  `productmodel` varchar(200) DEFAULT NULL COMMENT '0',
  `productname` varchar(200) DEFAULT NULL COMMENT '0',
  `specification` varchar(200) DEFAULT NULL COMMENT '11',
  `productdiscribe` varchar(200) COMMENT '11',
  `rmbcost` varchar(200) DEFAULT NULL COMMENT '',
  `rmbprice` varchar(200) DEFAULT NULL COMMENT '',
  `dollarcost` varchar(200) DEFAULT NULL COMMENT '',
  `dollarprice` varchar(200) DEFAULT NULL COMMENT '',
  `num` varchar(200) DEFAULT NULL COMMENT '4',
  `discount` varchar(200) DEFAULT NULL COMMENT 'num,1,10',
  `remark` varchar(200) DEFAULT NULL COMMENT '11',
  `pmid` varchar(200) DEFAULT NULL COMMENT '6zmemory_employee',
  `currencyexchangerate` varchar(200) DEFAULT NULL COMMENT ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='机会产品表';


DROP TABLE IF exists `zmemory_optcontact`;
CREATE TABLE IF NOT exists `zmemory_optcontact` (
  `row` varchar(200) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `optid` varchar(200) DEFAULT NULL COMMENT '6zmemory_opt',
  `contactid` varchar(200) DEFAULT NULL COMMENT '6zmemory_customercontact',
  `depart` varchar(200) DEFAULT NULL COMMENT '0',
  `fullname` varchar(200) DEFAULT NULL COMMENT '0',
  `sex` varchar(200) DEFAULT NULL COMMENT 'num,0,1',
  `tel` varchar(200) DEFAULT NULL COMMENT '0',
  `mobile` varchar(200) DEFAULT NULL COMMENT '0',
  `fax` varchar(200) DEFAULT NULL COMMENT '0',
  `email` varchar(200) DEFAULT NULL COMMENT '11',
  `qq` varchar(200) DEFAULT NULL COMMENT '11',
  `wechat` varchar(200) DEFAULT NULL COMMENT '11',
  `address` varchar(200) DEFAULT NULL COMMENT '11',
  `remark` varchar(200) COMMENT '11',
  `role` varchar(200) DEFAULT NULL COMMENT '0',
  `position` varchar(200) DEFAULT NULL COMMENT '0' 
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='机会联系人表';

DROP TABLE IF exists `zmemory_systemconfig`;
CREATE TABLE IF NOT exists `zmemory_systemconfig` (
  `row` varchar(200) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `emailusername` varchar(200) DEFAULT NULL COMMENT '0',
  `emailpassword` varchar(200) DEFAULT NULL COMMENT '0',
  `emailsendaddr` varchar(200) DEFAULT NULL COMMENT '0',
  `emailsmtpaddr` varchar(200) DEFAULT NULL COMMENT '0',
  `emailsmtpport` varchar(200) DEFAULT NULL COMMENT '0',
  `emailisverification` varchar(200) DEFAULT NULL COMMENT 'num,0,1',
  `isdisplayotherexpense` varchar(200) DEFAULT NULL COMMENT '',
  `customerauditorid` varchar(200) DEFAULT NULL COMMENT '',
  `assistantid` varchar(200) DEFAULT NULL COMMENT '',
  `versionnum` varchar(200) DEFAULT NULL COMMENT '',
  `snapshootperiod` varchar(200) DEFAULT NULL COMMENT 'num,1,31',
  `bigoptprice` varchar(200) DEFAULT NULL COMMENT '4',
  `bigoptpriceminor` varchar(200) DEFAULT NULL COMMENT '4',
  `systemaddr` varchar(200) DEFAULT NULL COMMENT '',
  `companyname` varchar(200) DEFAULT NULL COMMENT '0',
  `profitrelationship` varchar(200) DEFAULT NULL COMMENT '',
  `leadreleaseperiod` varchar(200) DEFAULT NULL COMMENT '4'
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='系统配置表';

DROP TABLE IF exists `zmemory_question`;
CREATE TABLE IF NOT exists `zmemory_question` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `tableName` VARCHAR(200)  DEFAULT NULL ,
  `row` VARCHAR(200)  DEFAULT NULL ,
  `col` VARCHAR(200)   DEFAULT NULL ,
  `error` VARCHAR(200)   DEFAULT NULL ,
  PRIMARY KEY (`id`)
) ENGINE=MEMORY  DEFAULT CHARSET=utf8;

  
end//
DELIMITER ;

-- 导出  过程 vsms.proc_import_dropMemoryTable 结构
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_import_dropMemoryTable`()
begin
drop table zmemory_currencyexchange;
drop table zmemory_currencyconvert;
drop table zmemory_empdepart;
drop table zmemory_empposition;
drop table zmemory_emprole;
drop table zmemory_employee;
drop table zmemory_empemployeerole;
drop table zmemory_emptarget;
drop table zmemory_empemployeeviewuser;
drop table zmemory_empemployeedepart;
drop table zmemory_productbrand;
drop table zmemory_productclass;
drop table zmemory_product;
drop table zmemory_country;
drop table zmemory_region;
drop table zmemory_province;
drop table zmemory_city;
drop table zmemory_town;
drop table zmemory_piecearea;
drop table zmemory_industry;
drop table zmemory_industrysub;
drop table zmemory_customer;
drop table zmemory_customercontact;
drop table zmemory_source;
drop table zmemory_workplanworktype;
drop table zmemory_opttype;
drop table zmemory_optstage;
drop table zmemory_optpossibility;
drop table zmemory_optcontactrole;
drop table zmemory_procurementmethod;
drop table zmemory_faranchise;
drop table zmemory_opt;
drop table zmemory_optproduct;
drop table zmemory_optcontact;
drop table zmemory_systemconfig;

end//
DELIMITER ;

-- 导出  过程 vsms.proc_import_updateCN 结构
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_import_updateCN`()
BEGIN
update zmemory_currencyexchange set currencyname=currencynameen where currencyname is null;
update zmemory_empdepart set departcn=departen where departcn is null;
update zmemory_empposition set positioncn=positionen where positioncn is null;
update zmemory_country set country=countryen where country is null;
update zmemory_region set region=regionen where region is null;
update zmemory_province set province=provinceen where province is null;
update zmemory_city set city=cityen where city is null;
update zmemory_town set town=townen where town is null;
update zmemory_piecearea set piecearea=pieceareaen where piecearea is null;
update zmemory_industry set industry=industryen where industry is null;
update zmemory_industrysub set industrysub=industrysuben where industrysub is null;
update zmemory_workplanworktype set worktype=worktypeen where worktype is null;
update zmemory_source set source=sourceen where source is null;
update zmemory_opttype set opttype=opttypeen where opttype is null;
update zmemory_procurementmethod set procurementmethodname=procurementmethodnameen where procurementmethodname is null;
update zmemory_faranchise set faranchisename=faranchisenameen where faranchisename is null; 
update zmemory_productclass set classnamecn=classnameen where classnamecn is null; 
update zmemory_productbrand set brandnamecn=brandnameen where brandnamecn is null; 
update zmemory_optcontactrole set rolecn=roleen where rolecn is null; 
end//
DELIMITER ;

-- 导出  过程 vsms.proc_import_updateEN 结构
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_import_updateEN`()
BEGIN
update zmemory_currencyexchange set currencynameen=currencyname where currencynameen is null;
update zmemory_empdepart set departen=departcn where departen is null;
update zmemory_empposition set positionen=positioncn where positionen is null;
update zmemory_country set countryen=country where countryen is null;
update zmemory_region set regionen=region where regionen is null;
update zmemory_province set provinceen=province where provinceen is null;
update zmemory_city set cityen=city where cityen is null;
update zmemory_town set townen=town where townen is null;
update zmemory_piecearea set pieceareaen=piecearea where pieceareaen is null;
update zmemory_industry set industryen=industry where industryen is null;
update zmemory_industrysub set industrysuben=industrysub where industrysuben is null;
update zmemory_workplanworktype set worktypeen=worktype where worktypeen is null;
update zmemory_source set sourceen=source where sourceen is null;
update zmemory_opttype set opttypeen=opttype where opttypeen is null;
update zmemory_procurementmethod set procurementmethodnameen=procurementmethodname where procurementmethodnameen is null;
update zmemory_faranchise set faranchisenameen=faranchisename where faranchisenameen is null;
update zmemory_productclass set classnameen=classnamecn where classnameen is null; 
update zmemory_productbrand set brandnameen=brandnamecn where brandnameen is null; 
update zmemory_optcontactrole set roleen=rolecn where roleen is null; 
END//
DELIMITER ;

-- 导出  过程 vsms.pro_timing_task_return_to_the_high_seas 结构
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `pro_timing_task_return_to_the_high_seas`()
BEGIN
	
	update customertemp as ct, lead as l 
	set l.owndatetime = null, l.ownerid = null, ct.ownerid = ct.createrid
	where l.isdelete = 0
			and l.customerid = ct.id
			and l.customertype = 0
			and l.leadscope is not null
			and l.isback = 0
			and l.isopt = 0
			and l.owndatetime is not null
			and l.ownerid is not null
			and round( ( select leadreleaseperiod from systemconfig limit 0, 1 ) * 3600 - timestampdiff(second, l.owndatetime, SYSDATE()) ) / 60 < 0	
	;
	
	update lead set owndatetime = null, ownerid = null
	where isdelete = 0
		and leadscope is not null
		and isback = 0
		and isopt = 0
		and owndatetime is not null
		and ownerid is not null
		and round( ( select leadreleaseperiod from systemconfig limit 0, 1 ) * 3600 - timestampdiff(second, owndatetime, SYSDATE()) ) / 60 < 0
	;
END//
DELIMITER ;

-- 导出  过程 vsms.transfer_to_otheremployee_proc 结构
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `transfer_to_otheremployee_proc`(IN operatorid varchar(20),IN sourceid varchar(4000),IN targetid varchar(20))
BEGIN
	declare operatedate datetime;
	declare t_error integer default 0;
	declare continue handler for sqlexception set t_error=1;
    set operatedate = now(); 

		-- start transaction;
        update opt set ownerid = targetid where createrid in (sourceid);
        update optestimatesnap set ownerid = targetid where createrid in (sourceid);
        update optrealsnap set ownerid = targetid where createrid in (sourceid);
        update customertemp set ownerid = targetid where createrid in (sourceid);
        update customercontacttemp set ownerid = targetid where createrid in (sourceid);
        update customercontact set ownerid = targetid where createrid in (sourceid);
        update workplan set createrid = targetid where createrid in (sourceid); 
        insert into transferlog(operatorid,sourceid,targetid,createdatetime) values(operatorid,sourceid,targetid,operatedate);
        	
		/*if t_error = 1 then
			rollback;
		else
			commit;
		end if;*/

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
