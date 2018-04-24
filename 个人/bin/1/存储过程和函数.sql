-- MySQL dump 10.13  Distrib 5.7.15, for Win64 (x86_64)
--
-- Host: localhost    Database: vsms
-- ------------------------------------------------------
-- Server version	5.7.15

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Dumping events for database 'vsms'
--
/*!50106 SET @save_time_zone= @@TIME_ZONE */ ;
/*!50106 DROP EVENT IF EXISTS `event_timing_task_return_to_the_high_seas` */;
DELIMITER ;;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;;
/*!50003 SET character_set_client  = utf8mb4 */ ;;
/*!50003 SET character_set_results = utf8mb4 */ ;;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;;
/*!50003 SET @saved_time_zone      = @@time_zone */ ;;
/*!50003 SET time_zone             = 'SYSTEM' */ ;;
/*!50106 CREATE*/ /*!50117 DEFINER=`root`@`localhost`*/ /*!50106 EVENT `event_timing_task_return_to_the_high_seas` ON SCHEDULE EVERY 1 HOUR STARTS '2017-10-10 05:36:31' ON COMPLETION PRESERVE ENABLE DO call pro_timing_task_return_to_the_high_seas() */ ;;
/*!50003 SET time_zone             = @saved_time_zone */ ;;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;;
/*!50003 SET character_set_client  = @saved_cs_client */ ;;
/*!50003 SET character_set_results = @saved_cs_results */ ;;
/*!50003 SET collation_connection  = @saved_col_connection */ ;;
/*!50106 DROP EVENT IF EXISTS `opt_snapshot_event` */;;
DELIMITER ;;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;;
/*!50003 SET character_set_client  = utf8mb4 */ ;;
/*!50003 SET character_set_results = utf8mb4 */ ;;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;;
/*!50003 SET @saved_time_zone      = @@time_zone */ ;;
/*!50003 SET time_zone             = 'SYSTEM' */ ;;
/*!50106 CREATE*/ /*!50117 DEFINER=`root`@`localhost`*/ /*!50106 EVENT `opt_snapshot_event` ON SCHEDULE EVERY 1 DAY STARTS '2018-01-18 23:00:00' ON COMPLETION PRESERVE ENABLE DO BEGIN
	 declare startingday varchar(20);  
     declare startdate varchar(20);    
     declare month varchar(20);        
     declare day varchar(20); 		   
     declare snapperiod varchar(20);   
     declare snap_date varchar(20);    

	set month = date_format(now(), '%Y%m'); 
	set day = date_format(now(), '%d');   
	set startingday = getStartingDay();  

    if (startingday < 10) then
       set startingday = concat('0',startingday);
    end if;
    set startdate = concat(month,startingday); 

    if(day > startingday) then  
    	 set snapperiod = date_format(date_sub(date_add(startdate,interval 1 month),interval 1 day),'%d');
    	 set snap_date = date_format(date_sub(date_add(startdate,interval 1 month),interval 1 day),'%Y-%m-%d');
    else 						
    	 set snapperiod = date_format(date_sub(startdate,interval 1 day),'%d');
    	 set snap_date = date_format(date_sub(startdate,interval 1 day),'%Y-%m-%d');
    end if;

    update customtime set snapdate=snap_date;
    if (day = snapperiod) then
    		call opt_snapshot_proc();
    end if;

END */ ;;
/*!50003 SET time_zone             = @saved_time_zone */ ;;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;;
/*!50003 SET character_set_client  = @saved_cs_client */ ;;
/*!50003 SET character_set_results = @saved_cs_results */ ;;
/*!50003 SET collation_connection  = @saved_col_connection */ ;;
DELIMITER ;
/*!50106 SET TIME_ZONE= @save_time_zone */ ;

--
-- Dumping routines for database 'vsms'
--
/*!50003 DROP FUNCTION IF EXISTS `ability_dateprocess` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `ability_dateprocess`(datetype varchar(30), nowdate varchar(20)) RETURNS varchar(20) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci
begin
    declare resultdate varchar(20);
    declare q1startdate varchar(20);
    declare currentyearstartdate varchar(20);

    declare m1 varchar(20);
    declare q1 varchar(20);
    declare y1 varchar(20);
    declare y2 varchar(20);
    declare y3 varchar(20);

  
    select last1MStart,q1Start,currentYStart,last1YStart,last2YStart from customtime where id = 1
    into m1,q1,y1,y2,y3;

    if (datetype is null or nowdate is null) then
        return null;
    end if;

	
    if (datetype = 'before1monthdate') then
        set resultdate = date_format(m1,'%Y%m');
        return resultdate;
    end if;
    if (datetype = 'before2monthdate') then
        set resultdate = date_format(date_sub(m1,interval 1 month),'%Y%m');
        return resultdate;
    end if;
    if (datetype = 'before3monthdate') then
       set resultdate = date_format(date_sub(m1,interval 2 month),'%Y%m');
        return resultdate;
    end if;
    
    
    if (datetype = 'before1monthstartdate') then
        set resultdate = m1;
        return resultdate;
    end if;
    if (datetype = 'before1monthenddate') then
        set resultdate = date_sub(date_add(m1,interval 1 month),interval 1 day);
        return resultdate;
    end if;
    if (datetype = 'before2monthstartdate') then
        set resultdate = date_sub(m1,interval 1 month);
        return resultdate;
    end if;
    if (datetype = 'before2monthenddate') then
        set resultdate = date_sub(m1,interval 1 day);
        return resultdate;
    end if;
    if (datetype = 'before3monthstartdate') then
       set resultdate = date_sub(m1,interval 2 month);
        return resultdate;
    end if;
    if (datetype = 'before3monthenddate') then
        set resultdate = date_sub(date_sub(m1,interval 1 month),interval 1 day);
        return resultdate;
    end if;
    

    
    if locate('q',datetype) then
      set q1startdate = date_sub(date_add(q1,interval 1 month),interval 1 day);
        if (datetype = 'q1startdate') then
            return date_format(q1startdate,'%Y%m');
        end if;
        if (datetype = 'q1enddate') then
            set resultdate = date_format(date_add(q1startdate,interval 2 month),'%Y%m');
            return resultdate;
        end if;
        if (datetype = 'q2startdate') then
            set resultdate = date_format(date_add(q1startdate,interval 3 month),'%Y%m');
            return resultdate;
        end if;
        if (datetype = 'q2enddate') then
            set resultdate = date_format(date_add(q1startdate,interval 5 month),'%Y%m');
            return resultdate;
        end if;
        if (datetype = 'q3startdate') then
            set resultdate = date_format(date_add(q1startdate,interval 6 month),'%Y%m');
            return resultdate;
        end if;
        if (datetype = 'q3enddate') then
            set resultdate = date_format(date_add(q1startdate,interval 8 month),'%Y%m');
            return resultdate;
        end if;
        if (datetype = 'q4startdate') then
            set resultdate = date_format(date_add(q1startdate,interval 9 month),'%Y%m');
            return resultdate;
        end if;
        if (datetype = 'q4enddate') then
            set resultdate = date_format(date_add(q1startdate,interval 11 month),'%Y%m');
            return resultdate;
        end if;
        
        if (datetype = 'q1startdatelong') then
            set resultdate = q1;
            return resultdate;
        end if;
        if (datetype = 'q1enddatelong') then
            set resultdate = date_format(date_sub(date_add(q1,interval 3 month),interval 1 day),'%Y-%m-%d');
            return resultdate;
        end if;
        if (datetype = 'q2startdatelong') then
            set resultdate = date_format(date_add(q1,interval 3 month),'%Y-%m-%d');
            return resultdate;
        end if;
        if (datetype = 'q2enddatelong') then
            set resultdate = date_format(date_sub(date_add(q1,interval 6 month),interval 1 day),'%Y-%m-%d');
            return resultdate;
        end if;
        if (datetype = 'q3startdatelong') then
            set resultdate = date_format(date_add(q1,interval 6 month),'%Y-%m-%d');
            return resultdate;
        end if;
        if (datetype = 'q3enddatelong') then
            set resultdate = date_format(date_sub(date_add(q1,interval 9 month),interval 1 day),'%Y-%m-%d');
            return resultdate;
        end if;
        if (datetype = 'q4startdatelong') then
            set resultdate = date_format(date_add(q1,interval 9 month),'%Y-%m-%d');
            return resultdate;
        end if;
        if (datetype = 'q4enddatelong') then
            set resultdate = date_format(date_sub(date_add(q1,interval 12 month),interval 1 day),'%Y-%m-%d');
            return resultdate;
        end if;
    end if;
    
    
    if locate('year',datetype) then
        if (datetype = 'currentyearstartdate') then
            set resultdate = date_format(y1,'%Y%m');
            return resultdate;
        end if;
        if (datetype = 'currentyearenddate') then
            set resultdate =  date_format(date_add(y1,interval 11 month),'%Y%m');
            return resultdate;
        end if;
        if (datetype = 'before1yearstartdate') then
            set resultdate = date_format(y2,'%Y%m');
            return resultdate;
        end if;
        if (datetype = 'before1yearenddate') then
            set resultdate = date_format(date_add(y2,interval 11 month),'%Y%m');
            return resultdate;
        end if;
        if (datetype = 'before2yearstartdate') then
            set resultdate = date_format(y3,'%Y%m');
            return resultdate;
        end if;
        if (datetype = 'before2yearenddate') then
            set resultdate = date_format(date_add(y3,interval 11 month),'%Y%m');
            return resultdate;
        end if;
        
        if (datetype = 'currentyearstartdatelong') then
            set resultdate = y1;
            return resultdate;
        end if;
        if (datetype = 'currentyearenddatelong') then
            set resultdate = date_format(date_sub(date_add(y1,interval 12 month),interval 1 day),'%Y-%m-%d');
            return resultdate;
        end if;
        if (datetype = 'before1yearstartdatelong') then
            set resultdate = y2;
            return resultdate;
        end if;
        if (datetype = 'before1yearenddatelong') then
            set resultdate = date_format(date_sub(date_add(y2,interval 12 month),interval 1 day),'%Y-%m-%d');
            return resultdate;
        end if;
        if (datetype = 'before2yearstartdatelong') then
            set resultdate = y3;
            return resultdate;
        end if;
        if (datetype = 'before2yearenddatelong') then
            set resultdate = date_format(date_sub(date_add(y3,interval 12 month),interval 1 day),'%Y-%m-%d');
            return resultdate;
        end if;
    end if;
    
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `ability_multiplecolumnprocess` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `ability_multiplecolumnprocess`(singleColumnSqlStr longtext, columnTotalNum int) RETURNS longtext CHARSET utf8
begin

















	declare multipleColumnSqlStr longtext default '';

















    declare i int;

















    declare isFirst boolean;

















    

















    set i = 1;

















    set isFirst = true;

















    

















    set multipleColumnSqlStr = singleColumnSqlStr;

















    

















	if columnTotalNum > 0 then

















		while i <= columnTotalNum do

















			

















            if isFirst then

















				set multipleColumnSqlStr = replace(singleColumnSqlStr,'_$num',i);

















                set isFirst = false;

















            else

















				set multipleColumnSqlStr = concat(multipleColumnSqlStr,'join ',singleColumnSqlStr,'on 1=1 ');

















                set multipleColumnSqlStr = replace(multipleColumnSqlStr,'_$num',i);

















            end if;

















			set i = i +1;

















        end while;

















    end if;

















    return multipleColumnSqlStr;

















END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fc_ck_date` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `fc_ck_date`(

















	`p_cont` varchar(255)

















) RETURNS int(11)
BEGIN

















		   IF(SELECT DATE_FORMAT(p_cont,'%Y-%m-%d')) IS NULL 

















		THEN

















		  RETURN 0;

















		ELSE

















		  RETURN 1;

















		END IF;



































END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `find_employeeid_by_employeeid_or_departids` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `find_employeeid_by_employeeid_or_departids`(_employeeids varchar(500), _departids varchar(500) ) RETURNS varchar(4000) CHARSET utf8
begin 
	
	declare returntemp varchar (4000);
	
	declare sTemp varchar (4000);
	
	declare sTempChd varchar (4000);
	
	
	set returntemp = '';
	set sTemp = '';	
	set sTempChd = _departids;
	
	while sTempChd is not null DO
		if sTemp = '' then
			set sTemp = sTempChd;
		else
			set sTemp = concat(sTemp, ',', sTempChd);
		end if;
		
		select group_concat(id) into sTempChd from empdepart where find_in_set(sdepartid, sTempChd) > 0;
	end while;

	
	select group_concat(id) into returntemp from employee where find_in_set(id, _employeeids) or find_in_set(depid, sTemp) > 0;
	
	return returntemp;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `getAllDeparts` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `getAllDeparts`(depId int) RETURNS varchar(4000) CHARSET utf8
begin
	
	declare sTemp varchar (4000);
	
	declare sTempChd varchar (4000);
	
	set sTemp = '';
	set sTempChd = cast(depId as char);
	
	while sTempChd is not null DO

		if sTemp = '' then
			set sTemp = sTempChd;
		else
			set sTemp = concat(sTemp, ',', sTempChd);
		end if;
		
		select group_concat(id) into sTempChd from empdepart where FIND_IN_SET(sdepartid, sTempChd) > 0;

	end while;
return sTemp;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `getAllDepartsByemployeeid` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `getAllDepartsByemployeeid`(_employeeid int) RETURNS varchar(4000) CHARSET utf8
begin 
	
	declare sTemp varchar (4000);
	
	declare sTempChd varchar (4000);
	
	set sTemp = '';	
	select group_concat(departid) into sTempChd from empemployeedepart where employeeid = cast(_employeeid as char);
	
	while sTempChd is not null DO
		if sTemp = '' then
			set sTemp = sTempChd;
		else
			set sTemp = concat(sTemp, ',', sTempChd);
		end if;
		
		select group_concat(id) into sTempChd from empdepart where FIND_IN_SET(sdepartid, sTempChd) > 0;
	end while;
	return sTemp;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `getAllEmployeeidBySuperiorid` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `getAllEmployeeidBySuperiorid`(_superiorid int) RETURNS varchar(4000) CHARSET utf8
begin 
	
	declare sTemp varchar (4000);
	
	declare sTempChd varchar (4000);
	
	set sTemp = '';	
	select group_concat(id) into sTempChd from employee where superiorid = cast(_superiorid as char);
	
	while sTempChd is not null DO
		if sTemp = '' then
			set sTemp = sTempChd;
		else
			set sTemp = concat(sTemp, ',', sTempChd);
		end if;
		
		select group_concat(id) into sTempChd from employee where FIND_IN_SET(superiorid, sTempChd) > 0;
	end while;
	return sTemp;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `getAllPermissionByEmployeeid` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `getAllPermissionByEmployeeid`(_employeeid int) RETURNS varchar(4000) CHARSET utf8
begin 
	
	declare sTemp varchar (4000);
	
	declare sTempChd varchar (4000);
	
	declare sTempRole varchar (4000);
	
	select group_concat(roleid) into sTempRole from empemployeerole where employeeid = cast(_employeeid as char);
	
	if sTempRole is not null then 
		select group_concat(permissionid) into sTemp from emprolepermission where find_in_set(roleid, sTempRole);
	end if;
	
	select group_concat(permissionid) into sTempChd from empemployeepermission where employeeid = cast(_employeeid as char);
 	set sTemp = IFNULL(sTemp,'');
 	set sTempChd = IFNULL(sTempChd,'');
 	if sTemp = '' then 
 		set sTemp = sTempChd;
 	else 
 		set sTemp = concat(sTemp, ',', sTempChd);
 	end if;
 	return sTemp;		
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `getStartingDay` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `getStartingDay`() RETURNS int(11)
begin
    declare flag int;
    declare startday int;
    declare currentYStart varchar(20);

    
    
    select isSynchronized into flag from systemconfig limit 1;
    select isSynchronized into currentYStart from systemconfig limit 1;

    if (currentYStart is null) then 
        set currentYStart = date_format(now(), '%Y-%m-%d');
    end if;

    if (flag = 1) then
        update customtime c left join systemconfig s on 1=1
            set c.startingday = ifnull(s.startingday,1);
         update customtime c left join systemconfig s on 1=1
            set c.startingmonth = ifnull(s.startingmonth,1);
    else 
       update customtime ct left join customyear cy on 1=1
            set ct.startingday = if(cy.startingday is not null and cy.years = date_format(currentYStart, '%Y'),cy.startingday,1);
       update customtime ct left join customyear cy on 1=1
            set ct.startingmonth = if(cy.startingmonth is not null and cy.years = date_format(currentYStart, '%Y'),cy.startingday,1);
    end if; 
   
    select startingday into startday from customtime;
    return startday;
    
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `get_first_pinyin_char` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `get_first_pinyin_char`(param varchar(255)) RETURNS varchar(2) CHARSET utf8
begin
	
  declare v_return varchar(255);
  declare v_first_char varchar(2);
	
  set v_first_char = upper(left(param,1));
  set v_return = v_first_char;
	
  if length( v_first_char) <> character_length( v_first_char ) then
    set v_return = elt( interval( 
					conv( hex( left( convert( param using gbk ), 1 ) ), 16, 10 )						
						, 0xB0A1, 0xB0C5, 0xB2C1, 0xB4EE, 0xB6EA, 0xB7A2, 0xB8C1, 0xB9FE
						, 0xBBF7, 0xBBF7, 0xBFA6, 0xC0AC, 0xC2E8, 0xC4C3, 0xC5B6, 0xC5BE
						, 0xC6DA, 0xC8BB, 0xC8F6, 0xCBFA, 0xCDDA, 0xCDDA, 0xCDDA, 0xCEF4
						, 0xD1B9, 0xD4D1)
					, 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M'
					, 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
			);
    end if;
    return v_return;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `chart_ability_allcompetewin_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `chart_ability_allcompetewin_proc`(in datetype varchar(10),in employeesid varchar(4000),in departsid varchar(4000),in m1 varchar(10),in m2 varchar(10),in m3 varchar(10),in y1 int,in faranchiseid int,in checktype int)
begin
    declare sqlstr longtext default '';
    declare tsqlstr longtext default '';
    declare sqlstring longtext default '';
    declare tsqlstring longtext default '';
    declare sqlcondition longtext default '';
    declare m1str varchar(10) default concat('m',right(m1,2)); 
    declare m2str varchar(10) default concat('m',right(m2,2)); 
    declare m3str varchar(10) default concat('m',right(m3,2)); 
    declare m1year varchar(10) default left(m1,4); 
    declare m2year varchar(10) default left(m2,4); 
    declare m3year varchar(10) default left(m3,4); 
    declare coli int; 
    declare i int; 
    declare scol longtext default ''; 
    declare done TINYINT DEFAULT 0;

    
    declare cur1 cursor for 
        select 1,concat(',if(years = ',m1year,',',m1str,',0)+ if(years = ',m2year,',',m2str,',0)+if(years = ',m3year,',',m3str,',0),0')
        union all select 4,concat(' and years = ',m1year,',',m1str,',0')
        union all select 7,concat(' and years = ',m2year,',',m2str,',0')
        union all select 10,concat(' and years = ',m3year,',',m3str,',0');
     
    declare cur2 cursor for 
        select 1,concat(' and years = ',y1,',q1,0')
        union all select 4,concat(' and years = ',y1,',q2,0')
        union all select 7,concat(' and years = ',y1,',q3,0')
        union all select 10,concat(' and years = ',y1,',q4,0');
     
    declare cur3 cursor for 
        select 1,concat(' and years = ',y1,',yearly,0')
        union all select 4,concat(' and years = ',y1-1,',yearly,0')
        union all select 7,concat(' and years = ',y1-2,',yearly,0');
    declare continue handler for not found set done = 1;

    
    if (employeesid is not null and CHAR_LENGTH(employeesid) = 0) then
        set employeesid = null;
    end if;
    if (departsid is not null and CHAR_LENGTH(departsid) = 0) then
        set departsid = null;
    end if;
    
    set sqlstr = concat('ifNull(cast(sum(if(type=1 $scol)) as DECIMAL(12,0)),0) $col1 ,  
                         ifNull(cast(sum(if(type=2 $scol)) as DECIMAL(12,0)),0) $col2 ,
                         ifNull(cast(sum(if(type=2 $scol))/sum(if(type=1 $scol)) as DECIMAL(14,2)),0)  $col3 ');
    set i = 0;
    while i<5 do
        set tsqlstring = '';
        if datetype = 'm' then
            
            open cur1;
        end if;
        if datetype = 'q' then
            
            open cur2;
        end if;
        if datetype = 'y' then
            
            open cur3;
        end if;
        
            read_loop: loop
                if datetype = 'm' then
                    fetch cur1 into coli,scol;
                end if;
                if datetype = 'q' then
                    fetch cur2 into coli,scol;
                end if;
                if datetype = 'y' then
                    fetch cur3 into coli,scol;
                end if;
                if done then
                    leave read_loop;
                end if;
                set tsqlstr = sqlstr;
                set tsqlstr = replace(tsqlstr,'$scol',scol);
                set tsqlstr = replace(tsqlstr,'$col1',concat('col',coli));
                set tsqlstr = replace(tsqlstr,'$col2',concat('col',coli+1));
                set tsqlstr = replace(tsqlstr,'$col3',concat('col',coli+2));
                if coli = 1 then 
                    set tsqlstring = concat(tsqlstring,'select ', tsqlstr);
                else 
                    set tsqlstring = concat(tsqlstring,' , ',tsqlstr);
                end if;

            end loop;
    
        if datetype = 'm' then
            
            close cur1;
        end if;
        if datetype = 'q' then
            
            close cur2;
        end if;
        if datetype = 'y' then
            
            close cur3;
        end if;
        
        set done = FALSE;

        set sqlcondition = concat(' from abilitystat abi left join employee emp on abi.employeeid = emp.id left join empdepart empd 
            on emp.depid = empd.id  where abi.stattype = ',i+1,' and abi.statclass = 7 ');    

        
        if checktype = 1 then
            set sqlcondition = concat(sqlcondition, ' and abi.employeeid is not null');
            if (employeesid is not null and departsid is not null) then
                set sqlcondition = concat(sqlcondition,' and (abi.employeeid in (',employeesid,') or emp.depid in (',departsid,')) ');
            else
                if employeesid is not null then
                    set sqlcondition = concat(sqlcondition,' and abi.employeeid in (',employeesid,') ');
                elseif departsid is not null then
                    set sqlcondition = concat(sqlcondition, ' and emp.depid in (',departsid,') ');
                end if;
            end if;
        else
            set sqlcondition = concat(sqlcondition, ' and abi.faranchiseid = ',faranchiseid);
        end if;

        if i = 0 then 
            set sqlstring = concat(sqlstring,tsqlstring);
        else
            set sqlstring = concat(sqlstring,' union all ',tsqlstring);
        end if; 

        set sqlstring = concat(sqlstring,sqlcondition);
        set i=i+1;
    end while;

    insert  into debug(debug) value(sqlstring);
    set @stmt = sqlstring;
        PREPARE stmt FROM @stmt;
        EXECUTE stmt;
   
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `chart_ability_allstagewin_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `chart_ability_allstagewin_proc`(in datetype varchar(10),in stattype int,in currencyid int,in employeesid varchar(4000),in departsid varchar(4000),in m1 varchar(10),in m2 varchar(10),in m3 varchar(10),in y1 int,in faranchiseid int,in checktype int)
begin
    declare sqlstr longtext default '';
    declare tsqlstr longtext default '';
    declare sqlstring longtext default '';
    declare tsqlstring longtext default '';
    declare sqlcondition longtext default '';
    declare m1str varchar(10) default concat('m',right(m1,2)); 
    declare m2str varchar(10) default concat('m',right(m2,2)); 
    declare m3str varchar(10) default concat('m',right(m3,2)); 
    declare m1year varchar(10) default left(m1,4); 
    declare m2year varchar(10) default left(m2,4); 
    declare m3year varchar(10) default left(m3,4); 
    declare coli int; 
    declare i int; 
    declare scol longtext default ''; 
    declare done TINYINT DEFAULT 0;

    
    declare cur1 cursor for 
        select 1,concat(',if(years = ',m1year,',',m1str,',0)+ if(years = ',m2year,',',m2str,',0)+if(years = ',m3year,',',m3str,',0),0')
        union all select 4,concat(' and years = ',m1year,',',m1str,',0')
        union all select 7,concat(' and years = ',m2year,',',m2str,',0')
        union all select 10,concat(' and years = ',m3year,',',m3str,',0');
     
    declare cur2 cursor for 
        select 1,concat(' and years = ',y1,',q1,0')
        union all select 4,concat(' and years = ',y1,',q2,0')
        union all select 7,concat(' and years = ',y1,',q3,0')
        union all select 10,concat(' and years = ',y1,',q4,0');
     
    declare cur3 cursor for 
        select 1,concat(' and years = ',y1,',yearly,0')
        union all select 4,concat(' and years = ',y1-1,',yearly,0')
        union all select 7,concat(' and years = ',y1-2,',yearly,0');
    declare continue handler for not found set done = 1;

    
    if (employeesid is not null and CHAR_LENGTH(employeesid) = 0) then
        set employeesid = null;
    end if;
    if (departsid is not null and CHAR_LENGTH(departsid) = 0) then
        set departsid = null;
    end if;
    
    if stattype=0 then
             set sqlstr = concat('sum(if(type=1 $scol)) $col1 ,  
                         sum(if(type=2 $scol)) $col2 ,
                         ifnull(cast(sum(if(type=2 $scol))/sum(if(type=1 $scol)) as DECIMAL(14,2)),0)  $col3 ');
    else
            set sqlstr = concat('ifNull(cast(sum(if(type=',currencyid*2+1,' $scol))/(select statisticunit from currencyexchange where id = ',currencyid,' ) as DECIMAL(12,2)),0) $col1 ,  
                         ifNull(cast(sum(if(type=',currencyid*2+2,' $scol))/(select statisticunit from currencyexchange where id = ',currencyid,' ) as DECIMAL(14,2)),0) $col2 ,
                         ifNull( cast(sum(if(type=',currencyid*2+2,' $scol))/sum(if(type=',currencyid*2+1,' $scol)) as DECIMAL(14,2)),0)  $col3 ');
    end if;


    
    set i = 0;
    while i<5 do
        set tsqlstring = '';
        if datetype = 'm' then
            
            open cur1;
        end if;
        if datetype = 'q' then
            
            open cur2;
        end if;
        if datetype = 'y' then
            
            open cur3;
        end if;
        
            read_loop: loop
                if datetype = 'm' then
                    fetch cur1 into coli,scol;
                end if;
                if datetype = 'q' then
                    fetch cur2 into coli,scol;
                end if;
                if datetype = 'y' then
                    fetch cur3 into coli,scol;
                end if;
                if done then
                    leave read_loop;
                end if;
                set tsqlstr = sqlstr;
                set tsqlstr = replace(tsqlstr,'$scol',scol);
                set tsqlstr = replace(tsqlstr,'$col1',concat('col',coli));
                set tsqlstr = replace(tsqlstr,'$col2',concat('col',coli+1));
                set tsqlstr = replace(tsqlstr,'$col3',concat('col',coli+2));
                if coli = 1 then 
                    set tsqlstring = concat(tsqlstring,'select ', tsqlstr);
                else 
                    set tsqlstring = concat(tsqlstring,' , ',tsqlstr);
                end if;

            end loop;
    
        if datetype = 'm' then
            
            close cur1;
        end if;
        if datetype = 'q' then
            
            close cur2;
        end if;
        if datetype = 'y' then
            
            close cur3;
        end if;
        
        set done = FALSE;

        set sqlcondition = concat(' from abilitystat abi left join employee emp on abi.employeeid = emp.id left join empdepart empd 
            on emp.depid = empd.id  where abi.stattype = ',i+1,' and abi.statclass = 5 ');    

        
        if checktype = 1 then
            set sqlcondition = concat(sqlcondition, ' and abi.employeeid is not null');
            if (employeesid is not null and departsid is not null) then
                set sqlcondition = concat(sqlcondition,' and (abi.employeeid in (',employeesid,') or emp.depid in (',departsid,')) ');
            else
                if employeesid is not null then
                    set sqlcondition = concat(sqlcondition,' and abi.employeeid in (',employeesid,') ');
                elseif departsid is not null then
                    set sqlcondition = concat(sqlcondition, ' and emp.depid in (',departsid,') ');
                end if;
            end if;
        else
            set sqlcondition = concat(sqlcondition, ' and abi.faranchiseid = ',faranchiseid);
        end if;


        if i = 0 then 
            set sqlstring = concat(sqlstring,tsqlstring);
        else
            set sqlstring = concat(sqlstring,' union all ',tsqlstring);
        end if; 

        set sqlstring = concat(sqlstring,sqlcondition);
        set i=i+1;
    end while;

    set @stmt = sqlstring;
        PREPARE stmt FROM @stmt;
        EXECUTE stmt;
   
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `chart_ability_competewin_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `chart_ability_competewin_proc`(in datetype varchar(10),in stattype int,in currencyid int,in employeesid varchar(4000),in departsid varchar(4000),in m1 varchar(10),in m2 varchar(10),in m3 varchar(10),in y1 int,in faranchiseid int,in checktype int)
begin
    declare sqlstr longtext default '';
    declare tsqlstr longtext default '';
    declare sqlstring longtext default '';
    declare tsqlstring longtext default '';
    declare sqlcondition longtext default '';
    declare m1str varchar(10) default concat('m',right(m1,2)); 
    declare m2str varchar(10) default concat('m',right(m2,2)); 
    declare m3str varchar(10) default concat('m',right(m3,2)); 
    declare m1year varchar(10) default left(m1,4); 
    declare m2year varchar(10) default left(m2,4); 
    declare m3year varchar(10) default left(m3,4); 
    declare coli int; 
    declare i int; 
    declare scol longtext default ''; 
    declare done TINYINT DEFAULT 0;

    
    declare cur1 cursor for 
        select 1,concat(',if(years = ',m1year,',',m1str,',0)+ if(years = ',m2year,',',m2str,',0)+if(years = ',m3year,',',m3str,',0),0')
        union all select 2,concat(' and years = ',m1year,',',m1str,',0')
        union all select 3,concat(' and years = ',m2year,',',m2str,',0')
        union all select 4,concat(' and years = ',m3year,',',m3str,',0');
     
    declare cur2 cursor for 
        select 1,concat(' and years = ',y1,',q1,0')
        union all select 2,concat(' and years = ',y1,',q2,0')
        union all select 3,concat(' and years = ',y1,',q3,0')
        union all select 4,concat(' and years = ',y1,',q4,0');
     
    declare cur3 cursor for 
        select 1,concat(' and years = ',y1,',yearly,0')
        union all select 2,concat(' and years = ',y1-1,',yearly,0')
        union all select 3,concat(' and years = ',y1-2,',yearly,0');
    declare continue handler for not found set done = 1;

    
    if (employeesid is not null and CHAR_LENGTH(employeesid) = 0) then
        set employeesid = null;
    end if;
    if (departsid is not null and CHAR_LENGTH(departsid) = 0) then
        set departsid = null;
    end if;
    
    if stattype=0 then
            set sqlstr = concat('sum(if(type=1 $scol)) $col1 ');
    else
        set sqlstr = concat('ifnull(cast(sum(if(type=',currencyid+1,' $scol))/(select statisticunit from currencyexchange where id = ',currencyid,' ) as DECIMAL(14,2)),0) $col1 ');
    end if;
    
    set i = 0;
    while i<2 do
        set tsqlstring = '';
        if datetype = 'm' then
            
            open cur1;
        end if;
        if datetype = 'q' then
            
            open cur2;
        end if;
        if datetype = 'y' then
            
            open cur3;
        end if;
        
            read_loop: loop
                if datetype = 'm' then
                    fetch cur1 into coli,scol;
                end if;
                if datetype = 'q' then
                    fetch cur2 into coli,scol;
                end if;
                if datetype = 'y' then
                    fetch cur3 into coli,scol;
                end if;
                if done then
                    leave read_loop;
                end if;
                set tsqlstr = sqlstr;
                set tsqlstr = replace(tsqlstr,'$scol',scol);
                set tsqlstr = replace(tsqlstr,'$col1',concat('col',coli));
                if coli = 1 then 
                    set tsqlstring = concat(tsqlstring,'select ', tsqlstr);
                else 
                    set tsqlstring = concat(tsqlstring,' , ',tsqlstr);
                end if;

            end loop;
    
        if datetype = 'm' then
            
            close cur1;
        end if;
        if datetype = 'q' then
            
            close cur2;
        end if;
        if datetype = 'y' then
            
            close cur3;
        end if;
        
        set done = FALSE;

        set sqlcondition = concat(' from abilitystat abi left join employee emp on abi.employeeid = emp.id left join empdepart empd 
            on emp.depid = empd.id  where abi.stattype = ',i+1,' and abi.statclass = 6 ');    

        
        if checktype = 1 then
            set sqlcondition = concat(sqlcondition, ' and abi.employeeid is not null');
            if (employeesid is not null and departsid is not null) then
                set sqlcondition = concat(sqlcondition,' and (abi.employeeid in (',employeesid,') or emp.depid in (',departsid,')) ');
            else
                if employeesid is not null then
                    set sqlcondition = concat(sqlcondition,' and abi.employeeid in (',employeesid,') ');
                elseif departsid is not null then
                    set sqlcondition = concat(sqlcondition, ' and emp.depid in (',departsid,') ');
                end if;
            end if;
        else
            set sqlcondition = concat(sqlcondition, ' and abi.faranchiseid = ',faranchiseid);
        end if;


        if i = 0 then 
            set sqlstring = concat(sqlstring,tsqlstring);
        else
            set sqlstring = concat(sqlstring,' union all ',tsqlstring);
        end if; 

        set sqlstring = concat(sqlstring,sqlcondition);
        set i=i+1;
    end while;

    set @stmt = sqlstring;
        PREPARE stmt FROM @stmt;
        EXECUTE stmt;
   
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `chart_ability_optanalysiswin_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `chart_ability_optanalysiswin_proc`(in datetype varchar(10),in currencyid int,in employeesid varchar(4000),in departsid varchar(4000),in m1 varchar(10),in m2 varchar(10),in m3 varchar(10),in y1 int,in faranchiseid int,in checktype int)
begin
    declare sqlstr longtext default '';
    declare tsqlstr longtext default '';
    declare sqlstring longtext default '';
    declare tsqlstring longtext default '';
    declare sqlcondition longtext default '';
    declare m1str varchar(10) default concat('m',right(m1,2)); 
    declare m2str varchar(10) default concat('m',right(m2,2)); 
    declare m3str varchar(10) default concat('m',right(m3,2)); 
    declare m1year varchar(10) default left(m1,4); 
    declare m2year varchar(10) default left(m2,4); 
    declare m3year varchar(10) default left(m3,4); 
    declare coli int; 
    declare i int; 
    declare scol longtext default ''; 
    declare done TINYINT DEFAULT 0;

    
    declare cur1 cursor for 
        select 1,concat(',if(years = ',m1year,',',m1str,',0)+ if(years = ',m2year,',',m2str,',0)+if(years = ',m3year,',',m3str,',0),0')
        union all select 4,concat(' and years = ',m1year,',',m1str,',0')
        union all select 7,concat(' and years = ',m2year,',',m2str,',0')
        union all select 10,concat(' and years = ',m3year,',',m3str,',0');
     
    declare cur2 cursor for 
        select 1,concat(' and years = ',y1,',q1,0')
        union all select 4,concat(' and years = ',y1,',q2,0')
        union all select 7,concat(' and years = ',y1,',q3,0')
        union all select 10,concat(' and years = ',y1,',q4,0');
     
    declare cur3 cursor for 
        select 1,concat(' and years = ',y1,',yearly,0')
        union all select 4,concat(' and years = ',y1-1,',yearly,0')
        union all select 7,concat(' and years = ',y1-2,',yearly,0');
    declare continue handler for not found set done = 1;

    
    if (employeesid is not null and CHAR_LENGTH(employeesid) = 0) then
        set employeesid = null;
    end if;
    if (departsid is not null and CHAR_LENGTH(departsid) = 0) then
        set departsid = null;
    end if;
    
    set sqlstr = concat('ifNull(cast(sum(if(type=1 $scol)) as DECIMAL(12,0)),0) $col1 ,  
                         ifNull(cast(sum(if(type=',currencyid+1,' $scol))/(select statisticunit from currencyexchange where id = ',currencyid,' ) as DECIMAL(14,2)),0) $col2 ,
                         ifNull( cast(sum(if(type=',currencyid+1,' $scol))/sum(if(type=1 $scol))/(select statisticunit from currencyexchange where id = ',currencyid,' ) as DECIMAL(14,2)),0)  $col3 ');
    set i = 0;
    while i<3 do
        set tsqlstring = '';
        if datetype = 'm' then
            
            open cur1;
        end if;
        if datetype = 'q' then
            
            open cur2;
        end if;
        if datetype = 'y' then
            
            open cur3;
        end if;
        
            read_loop: loop
                if datetype = 'm' then
                    fetch cur1 into coli,scol;
                end if;
                if datetype = 'q' then
                    fetch cur2 into coli,scol;
                end if;
                if datetype = 'y' then
                    fetch cur3 into coli,scol;
                end if;
                if done then
                    leave read_loop;
                end if;
                set tsqlstr = sqlstr;
                set tsqlstr = replace(tsqlstr,'$scol',scol);
                set tsqlstr = replace(tsqlstr,'$col1',concat('col',coli));
                set tsqlstr = replace(tsqlstr,'$col2',concat('col',coli+1));
                set tsqlstr = replace(tsqlstr,'$col3',concat('col',coli+2));
                if coli = 1 then 
                    set tsqlstring = concat(tsqlstring,'select ', tsqlstr);
                else 
                    set tsqlstring = concat(tsqlstring,' , ',tsqlstr);
                end if;

            end loop;
    
        if datetype = 'm' then
            
            close cur1;
        end if;
        if datetype = 'q' then
            
            close cur2;
        end if;
        if datetype = 'y' then
            
            close cur3;
        end if;
        
        set done = FALSE;

        set sqlcondition = concat(' from abilitystat abi left join employee emp on abi.employeeid = emp.id left join empdepart empd 
            on emp.depid = empd.id  where abi.stattype = ',i+1,' and abi.statclass = 1 ');    

        
        if checktype = 1 then
            set sqlcondition = concat(sqlcondition, ' and abi.employeeid is not null');
            if (employeesid is not null and departsid is not null) then
                set sqlcondition = concat(sqlcondition,' and (abi.employeeid in (',employeesid,') or emp.depid in (',departsid,')) ');
            else
                if employeesid is not null then
                    set sqlcondition = concat(sqlcondition,' and abi.employeeid in (',employeesid,') ');
                elseif departsid is not null then
                    set sqlcondition = concat(sqlcondition, ' and emp.depid in (',departsid,') ');
                end if;
            end if;
        else
            set sqlcondition = concat(sqlcondition, ' and abi.faranchiseid = ',faranchiseid);
        end if;


        if i = 0 then 
            set sqlstring = concat(sqlstring,tsqlstring);
        else
            set sqlstring = concat(sqlstring,' union all ',tsqlstring);
        end if; 

        set sqlstring = concat(sqlstring,sqlcondition);
        set i=i+1;
    end while;

    
    set @stmt = sqlstring;
        PREPARE stmt FROM @stmt;
        EXECUTE stmt;
   
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `chart_ability_optanalysiswin_proc2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `chart_ability_optanalysiswin_proc2`(in datetype varchar(10),in currencyid int,in employeesid varchar(4000),in departsid varchar(4000),in m1 varchar(10),in m2 varchar(10),in m3 varchar(10),in y1 int)
begin





    declare sqlstr longtext default '';





    declare tsqlstr longtext default '';





    declare sqlstring longtext default '';





    declare tsqlstring longtext default '';





    declare sqlcondition longtext default '';





    declare m1str varchar(10) default concat('m',right(m1,2)); -- 前一个月是 如：m3





    declare m2str varchar(10) default concat('m',right(m2,2)); -- 前两个月是 如：m2





    declare m3str varchar(10) default concat('m',right(m3,2)); -- 前三个月是 如：m1





    declare m1year varchar(10) default left(m1,4); -- 前一个月对应的年份 如：2017





    declare m2year varchar(10) default left(m2,4); -- 前两个月对应的年份 如：2017





    declare m3year varchar(10) default left(m3,4); -- 前三个月对应的年份 如：2017





    declare coli int; -- 列标记





    declare i int; -- 循环次数





    declare scol longtext default ''; -- 查询的列str 





    declare done TINYINT DEFAULT 0;











    /* 动态三个月 游标*/





    declare cur1 cursor for 





        select 1,concat(',if(years = ',m1year,',',m1str,',0)+ if(years = ',m2year,',',m2str,',0)+if(years = ',m3year,',',m3str,',0),0')





        union all select 3,concat(' and years = ',m1year,',',m1str,',0')





        union all select 5,concat(' and years = ',m2year,',',m2str,',0')





        union all select 7,concat(' and years = ',m3year,',',m3str,',0');





     /* 季度 游标*/





    declare cur2 cursor for 





        select 1,concat(' and years = ',y1,',q1,0')





        union all select 3,concat(' and years = ',y1,',q2,0')





        union all select 5,concat(' and years = ',y1,',q3,0')





        union all select 7,concat(' and years = ',y1,',q4,0');





     /* 年度 游标*/





    declare cur3 cursor for 





        select 1,concat(' and years = ',y1,',yearly,0')





        union all select 3,concat(' and years = ',y1-1,',yearly,0')





        union all select 5,concat(' and years = ',y1-2,',yearly,0');





    declare continue handler for not found set done = 1;











    /* 清理初始化参数 */





    if (employeesid is not null and CHAR_LENGTH(employeesid) = 0) then





        set employeesid = null;





    end if;





    if (departsid is not null and CHAR_LENGTH(departsid) = 0) then





        set departsid = null;





    end if;





    





    set sqlstr = concat('sum(if(stattype=$i $scol)) $col1,  





                        ifNull(cast(sum(if(stattype=$i $scol))/sum($scol) as DECIMAL(12,0)) ,0) $col2 ');





    set i = 0;





    while i<5 do





        set tsqlstring = '';





        if datetype = 'm' then





            /* 打开游标  动态三个月*/





            open cur1;





        end if;





        if datetype = 'q' then





            /* 打开游标  季度*/





            open cur2;





        end if;





        if datetype = 'y' then





            /* 打开游标  年度*/





            open cur3;





        end if;





        /* 遍历数据表 */





            read_loop: loop





                if datetype = 'm' then





                    fetch cur1 into coli,scol;





                end if;





                if datetype = 'q' then





                    fetch cur2 into coli,scol;





                end if;





                if datetype = 'y' then





                    fetch cur3 into coli,scol;





                end if;





                if done then





                    leave read_loop;





                end if;





                set tsqlstr = sqlstr;





                set tsqlstr = replace(tsqlstr,'$scol',scol);





                set tsqlstr = replace(tsqlstr,'$col1',concat('col',coli));





                set tsqlstr = replace(tsqlstr,'$col2',concat('col',coli+1));





                if coli = 1 then 





                    set tsqlstring = concat(tsqlstring,'select ', tsqlstr);





                else 





                    set tsqlstring = concat(tsqlstring,' , ',tsqlstr);





                end if;











            end loop;





    





        if datetype = 'm' then





            /* 关闭游标 */





            close cur1;





        end if;





        if datetype = 'q' then





            /* 关闭游标 */





            close cur2;





        end if;





        if datetype = 'y' then





            /* 关闭游标 */





            close cur3;





        end if;





        /*结束游标*/





        set done = FALSE;











        set tsqlstr = replace(tsqlstr,'$i',i+1);





        set sqlcondition = concat(' from abilitystat abi left join employee emp on abi.employeeid = emp.id left join empdepart empd 





            on emp.depid = empd.id  where  abi.statclass = 3 ');    











        if (employeesid is not null and departsid is not null) then





            set sqlcondition = concat(sqlcondition,' and (abi.employeeid in (',employeesid,') or emp.depid in (',departsid,')) ');





        else





            if employeesid is not null then





                set sqlcondition = concat(sqlcondition,' and abi.employeeid in (',employeesid,') ');





            elseif departsid is not null then





                set sqlcondition = concat(sqlcondition, ' and emp.depid in (',departsid,') ');





            end if;





        end if;

















        if i = 0 then 





            set sqlstring = concat(sqlstring,tsqlstring);





        else





            set sqlstring = concat(sqlstring,' union all ',tsqlstring);





        end if; 











        set sqlstring = concat(sqlstring,sqlcondition);





        set i=i+1;





    end while;











    set @stmt = sqlstring;





        PREPARE stmt FROM @stmt;





        EXECUTE stmt;





   





end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `chart_ability_optboost_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `chart_ability_optboost_proc`(in datetype varchar(10),in employeesid varchar(4000),in departsid varchar(4000),in m1 varchar(10),in m2 varchar(10),in m3 varchar(10),in y1 int,in faranchiseid int,in checktype int)
begin
    declare sqlstr longtext default '';
    declare tsqlstr longtext default '';
    declare sqlstring longtext default '';
    declare tsqlstring longtext default '';
    declare sqlcondition longtext default '';
    declare m1str varchar(10) default concat('m',right(m1,2)); 
    declare m2str varchar(10) default concat('m',right(m2,2)); 
    declare m3str varchar(10) default concat('m',right(m3,2)); 
    declare m1year varchar(10) default left(m1,4); 
    declare m2year varchar(10) default left(m2,4); 
    declare m3year varchar(10) default left(m3,4); 
    declare coli int; 
    declare i int; 
    declare scol longtext default ''; 
    declare done TINYINT DEFAULT 0;

    
    declare cur1 cursor for 
        select 1,concat(',(if(years = ',m1year,',',m1str,',0)+ if(years = ',m2year,',',m2str,',0)+if(years = ',m3year,',',m3str,',0))/3,0')
        union all select 4,concat(' and years = ',m1year,',',m1str,',0')
        union all select 7,concat(' and years = ',m2year,',',m2str,',0')
        union all select 10,concat(' and years = ',m3year,',',m3str,',0');
     
    declare cur2 cursor for 
        select 1,concat(' and years = ',y1,',q1,0')
        union all select 4,concat(' and years = ',y1,',q2,0')
        union all select 7,concat(' and years = ',y1,',q3,0')
        union all select 10,concat(' and years = ',y1,',q4,0');
     
    declare cur3 cursor for 
        select 1,concat(' and years = ',y1,',yearly,0')
        union all select 4,concat(' and years = ',y1-1,',yearly,0')
        union all select 7,concat(' and years = ',y1-2,',yearly,0');
    declare continue handler for not found set done = 1;

    
    if (employeesid is not null and CHAR_LENGTH(employeesid) = 0) then
        set employeesid = null;
    end if;
    if (departsid is not null and CHAR_LENGTH(departsid) = 0) then
        set departsid = null;
    end if;
    
    set sqlstr = concat('ifNull(cast(sum(if(type=1 $scol)) as DECIMAL(12,0)),0) $col1 ,  
                         ifNull(cast(sum(if(type=2 $scol)) as DECIMAL(12,0)),0) $col2 ,
                         ifNull(cast(cast(sum(if(type=2 $scol)) as DECIMAL(12,0))/cast(sum(if(type=1 $scol)) as DECIMAL(12,0)) as DECIMAL(14,2)),0)  $col3 ');
    set i = 0;
    while i<5 do
        set tsqlstring = '';
        if datetype = 'm' then
            
            open cur1;
        end if;
        if datetype = 'q' then
            
            open cur2;
        end if;
        if datetype = 'y' then
            
            open cur3;
        end if;
        
            read_loop: loop
                if datetype = 'm' then
                    fetch cur1 into coli,scol;
                end if;
                if datetype = 'q' then
                    fetch cur2 into coli,scol;
                end if;
                if datetype = 'y' then
                    fetch cur3 into coli,scol;
                end if;
                if done then
                    leave read_loop;
                end if;
                set tsqlstr = sqlstr;
                set tsqlstr = replace(tsqlstr,'$scol',scol);
                set tsqlstr = replace(tsqlstr,'$col1',concat('col',coli));
                set tsqlstr = replace(tsqlstr,'$col2',concat('col',coli+1));
                set tsqlstr = replace(tsqlstr,'$col3',concat('col',coli+2));
                if coli = 1 then 
                    set tsqlstring = concat(tsqlstring,'select ', tsqlstr);
                else 
                    set tsqlstring = concat(tsqlstring,' , ',tsqlstr);
                end if;

            end loop;
    
        if datetype = 'm' then
            
            close cur1;
        end if;
        if datetype = 'q' then
            
            close cur2;
        end if;
        if datetype = 'y' then
            
            close cur3;
        end if;
        
        set done = FALSE;

        set sqlcondition = concat(' from abilitystat abi left join employee emp on abi.employeeid = emp.id left join empdepart empd 
            on emp.depid = empd.id  where abi.stattype = ',i+1,' and abi.statclass = 8 ');    

        
        if checktype = 1 then
            set sqlcondition = concat(sqlcondition, ' and abi.employeeid is not null');
            if (employeesid is not null and departsid is not null) then
                set sqlcondition = concat(sqlcondition,' and (abi.employeeid in (',employeesid,') or emp.depid in (',departsid,')) ');
            else
                if employeesid is not null then
                    set sqlcondition = concat(sqlcondition,' and abi.employeeid in (',employeesid,') ');
                elseif departsid is not null then
                    set sqlcondition = concat(sqlcondition, ' and emp.depid in (',departsid,') ');
                end if;
            end if;
        else
            set sqlcondition = concat(sqlcondition, ' and abi.faranchiseid = ',faranchiseid);
        end if;


        if i = 0 then 
            set sqlstring = concat(sqlstring,tsqlstring);
        else
            set sqlstring = concat(sqlstring,' union all ',tsqlstring);
        end if; 

        set sqlstring = concat(sqlstring,sqlcondition);
        set i=i+1;
    end while;

    
    set @stmt = sqlstring;
        PREPARE stmt FROM @stmt;
        EXECUTE stmt;
   
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `chart_ability_optinvalid_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `chart_ability_optinvalid_proc`(in datetype varchar(10),in employeesid varchar(4000),in departsid varchar(4000),in m1 varchar(10),in m2 varchar(10),in m3 varchar(10),in y1 int,in faranchiseid int,in checktype int)
begin
    declare sqlstr longtext default '';
    declare tsqlstr longtext default '';
    declare sqlstring longtext default '';
    declare tsqlstring longtext default '';
    declare sqlcondition longtext default '';
    declare m1str varchar(10) default concat('m',right(m1,2)); 
    declare m2str varchar(10) default concat('m',right(m2,2)); 
    declare m3str varchar(10) default concat('m',right(m3,2)); 
    declare m1year varchar(10) default left(m1,4); 
    declare m2year varchar(10) default left(m2,4); 
    declare m3year varchar(10) default left(m3,4); 
    declare coli int; 
    declare i int; 
    declare scol longtext default ''; 
    declare done TINYINT DEFAULT 0;

    
    declare cur1 cursor for 
        select 1,concat(',(if(years = ',m1year,',',m1str,',0)+ if(years = ',m2year,',',m2str,',0)+if(years = ',m3year,',',m3str,',0))/3,0')
        union all select 4,concat(' and years = ',m1year,',',m1str,',0')
        union all select 7,concat(' and years = ',m2year,',',m2str,',0')
        union all select 10,concat(' and years = ',m3year,',',m3str,',0');
     
    declare cur2 cursor for 
        select 1,concat(' and years = ',y1,',q1,0')
        union all select 4,concat(' and years = ',y1,',q2,0')
        union all select 7,concat(' and years = ',y1,',q3,0')
        union all select 10,concat(' and years = ',y1,',q4,0');
     
    declare cur3 cursor for 
        select 1,concat(' and years = ',y1,',yearly,0')
        union all select 4,concat(' and years = ',y1-1,',yearly,0')
        union all select 7,concat(' and years = ',y1-2,',yearly,0');
    declare continue handler for not found set done = 1;

    
    if (employeesid is not null and CHAR_LENGTH(employeesid) = 0) then
        set employeesid = null;
    end if;
    if (departsid is not null and CHAR_LENGTH(departsid) = 0) then
        set departsid = null;
    end if;
    
    set sqlstr = concat('ifNull(cast(sum(if(type=1 $scol)) as DECIMAL(12,0)),0) $col1 ,  
                         ifNull(cast(sum(if(type=2 $scol)) as DECIMAL(12,0)),0) $col2 ,
                         ifNull(cast(cast(sum(if(type=2 $scol)) as DECIMAL(12,0))/cast(sum(if(type=1 $scol)) as DECIMAL(12,0)) as DECIMAL(14,2)),0)  $col3 ');
    set i = 0;
    while i<5 do
        set tsqlstring = '';
        if datetype = 'm' then
            
            open cur1;
        end if;
        if datetype = 'q' then
            
            open cur2;
        end if;
        if datetype = 'y' then
            
            open cur3;
        end if;
        
            read_loop: loop
                if datetype = 'm' then
                    fetch cur1 into coli,scol;
                end if;
                if datetype = 'q' then
                    fetch cur2 into coli,scol;
                end if;
                if datetype = 'y' then
                    fetch cur3 into coli,scol;
                end if;
                if done then
                    leave read_loop;
                end if;
                set tsqlstr = sqlstr;
                set tsqlstr = replace(tsqlstr,'$scol',scol);
                set tsqlstr = replace(tsqlstr,'$col1',concat('col',coli));
                set tsqlstr = replace(tsqlstr,'$col2',concat('col',coli+1));
                set tsqlstr = replace(tsqlstr,'$col3',concat('col',coli+2));
                if coli = 1 then 
                    set tsqlstring = concat(tsqlstring,'select ', tsqlstr);
                else 
                    set tsqlstring = concat(tsqlstring,' , ',tsqlstr);
                end if;

            end loop;
    
        if datetype = 'm' then
            
            close cur1;
        end if;
        if datetype = 'q' then
            
            close cur2;
        end if;
        if datetype = 'y' then
            
            close cur3;
        end if;
        
        set done = FALSE;

        set sqlcondition = concat(' from abilitystat abi left join employee emp on abi.employeeid = emp.id left join empdepart empd 
            on emp.depid = empd.id  where abi.stattype = ',i+1,' and abi.statclass = 10 ');    

        
        if checktype = 1 then
            set sqlcondition = concat(sqlcondition, ' and abi.employeeid is not null');
            if (employeesid is not null and departsid is not null) then
                set sqlcondition = concat(sqlcondition,' and (abi.employeeid in (',employeesid,') or emp.depid in (',departsid,')) ');
            else
                if employeesid is not null then
                    set sqlcondition = concat(sqlcondition,' and abi.employeeid in (',employeesid,') ');
                elseif departsid is not null then
                    set sqlcondition = concat(sqlcondition, ' and emp.depid in (',departsid,') ');
                end if;
            end if;
        else
            set sqlcondition = concat(sqlcondition, ' and abi.faranchiseid = ',faranchiseid);
        end if;

        if i = 0 then 
            set sqlstring = concat(sqlstring,tsqlstring);
        else
            set sqlstring = concat(sqlstring,' union all ',tsqlstring);
        end if; 

        set sqlstring = concat(sqlstring,sqlcondition);
        set i=i+1;
    end while;

    
    set @stmt = sqlstring;
        PREPARE stmt FROM @stmt;
        EXECUTE stmt;
   
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `chart_ability_optreceivingperiod_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `chart_ability_optreceivingperiod_proc`(in datetype varchar(10),in employeesid varchar(4000),in departsid varchar(4000),in m1 varchar(10),in m2 varchar(10),in m3 varchar(10),in y1 int,in faranchiseid int,in checktype int)
begin
    declare sqlstr longtext default '';
    declare tsqlstr longtext default '';
    declare sqlstring longtext default '';
    declare tsqlstring longtext default '';
    declare sqlcondition longtext default '';
    declare m1str varchar(10) default concat('m',right(m1,2)); 
    declare m2str varchar(10) default concat('m',right(m2,2)); 
    declare m3str varchar(10) default concat('m',right(m3,2)); 
    declare m1year varchar(10) default left(m1,4); 
    declare m2year varchar(10) default left(m2,4); 
    declare m3year varchar(10) default left(m3,4); 
    declare coli int; 
    declare i int; 
    declare scol longtext default ''; 
    declare done TINYINT DEFAULT 0;

    
    declare cur1 cursor for 
        select 1,concat(',(if(years = ',m1year,',',m1str,',0)+ if(years = ',m2year,',',m2str,',0)+if(years = ',m3year,',',m3str,',0))/3,0')
        union all select 2,concat(' and years = ',m1year,',',m1str,',0')
        union all select 3,concat(' and years = ',m2year,',',m2str,',0')
        union all select 4,concat(' and years = ',m3year,',',m3str,',0');
     
    declare cur2 cursor for 
        select 1,concat(' and years = ',y1,',q1,0')
        union all select 2,concat(' and years = ',y1,',q2,0')
        union all select 3,concat(' and years = ',y1,',q3,0')
        union all select 4,concat(' and years = ',y1,',q4,0');
     
    declare cur3 cursor for 
        select 1,concat(' and years = ',y1,',yearly,0')
        union all select 2,concat(' and years = ',y1-1,',yearly,0')
        union all select 3,concat(' and years = ',y1-2,',yearly,0');
    declare continue handler for not found set done = 1;

    
    if (employeesid is not null and CHAR_LENGTH(employeesid) = 0) then
        set employeesid = null;
    end if;
    if (departsid is not null and CHAR_LENGTH(departsid) = 0) then
        set departsid = null;
    end if;
    
    set sqlstr = concat('ifnull(cast(cast(sum(if(type=1 $scol)) as DECIMAL(14,0))/$employeeid as DECIMAL(14,0)),0) $col1 ');
    set i = 0;
    while i<5 do
        set tsqlstring = '';
        if datetype = 'm' then
            
            open cur1;
        end if;
        if datetype = 'q' then
            
            open cur2;
        end if;
        if datetype = 'y' then
            
            open cur3;
        end if;
        
            read_loop: loop
                if datetype = 'm' then
                    fetch cur1 into coli,scol;
                end if;
                if datetype = 'q' then
                    fetch cur2 into coli,scol;
                end if;
                if datetype = 'y' then
                    fetch cur3 into coli,scol;
                end if;
                if done then
                    leave read_loop;
                end if;
                set tsqlstr = sqlstr;
                set tsqlstr = replace(tsqlstr,'$scol',scol);
                set tsqlstr = replace(tsqlstr,'$col1',concat('col',coli));
                set tsqlstr = replace(tsqlstr,'$employeeid','(SELECT count(*)
                                        from abilitystat abi left join employee emp on abi.employeeid = emp.id left join empdepart empd
                                            on emp.depid = empd.id where abi.statclass = 9 and abi.stattype=1 $where)');
                if coli = 1 then 
                    set tsqlstring = concat(tsqlstring,'select ', tsqlstr);
                else 
                    set tsqlstring = concat(tsqlstring,' , ',tsqlstr);
                end if;

            end loop;
    
        if datetype = 'm' then
            
            close cur1;
        end if;
        if datetype = 'q' then
            
            close cur2;
        end if;
        if datetype = 'y' then
            
            close cur3;
        end if;
        
        set done = FALSE;

        if i = 0 then 
            set sqlstring = concat(sqlstring,tsqlstring);
        else
            set sqlstring = concat(sqlstring,' union all ',tsqlstring);
        end if; 

        set sqlstring = concat(sqlstring,' from abilitystat abi left join employee emp on abi.employeeid = emp.id left join empdepart empd 
            on emp.depid = empd.id  where abi.stattype = ',i+1,' and abi.statclass = 9 ');    

        
        if checktype = 1 then
            set sqlcondition = concat(sqlcondition, ' and abi.employeeid is not null');
            if (employeesid is not null and departsid is not null) then
                set sqlcondition = concat(sqlcondition,' and (abi.employeeid in (',employeesid,') or emp.depid in (',departsid,')) ');
            else
                if employeesid is not null then
                    set sqlcondition = concat(sqlcondition,' and abi.employeeid in (',employeesid,') ');
                elseif departsid is not null then
                    set sqlcondition = concat(sqlcondition, ' and emp.depid in (',departsid,') ');
                end if;
            end if;
        else
            set sqlcondition = concat(sqlcondition, ' and abi.faranchiseid = ',faranchiseid);
        end if;

        set sqlstring = replace(sqlstring,'$where',sqlcondition);
        set sqlstring = concat(sqlstring,sqlcondition);
        set i=i+1;
    end while;

    set @stmt = sqlstring;
        PREPARE stmt FROM @stmt;
        EXECUTE stmt;
   
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `chart_ability_orderdistribution_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `chart_ability_orderdistribution_proc`(in datetype varchar(10),in currencyid int,in employeesid varchar(4000),in departsid varchar(4000),in m1 varchar(10),in m2 varchar(10),in m3 varchar(10),in y1 int)
begin
    declare sqlstr longtext default '';
    declare tsqlstr longtext default '';
    declare sqlstring longtext default '';
    declare tsqlstring longtext default '';
    declare sqlcondition longtext default '';
    declare m1str varchar(10) default concat('m',right(m1,2)); 
    declare m2str varchar(10) default concat('m',right(m2,2)); 
    declare m3str varchar(10) default concat('m',right(m3,2)); 
    declare m1year varchar(10) default left(m1,4); 
    declare m2year varchar(10) default left(m2,4); 
    declare m3year varchar(10) default left(m3,4); 
    declare coli int; 
    declare i int; 
    declare scol longtext default ''; 
    declare done TINYINT DEFAULT 0;

    
    declare cur1 cursor for 
        select 1,concat(',if(years = ',m1year,',',m1str,',0)+ if(years = ',m2year,',',m2str,',0)+if(years = ',m3year,',',m3str,',0),0')
        union all select 3,concat(' and years = ',m1year,',',m1str,',0')
        union all select 5,concat(' and years = ',m2year,',',m2str,',0')
        union all select 7,concat(' and years = ',m3year,',',m3str,',0');
     
    declare cur2 cursor for 
        select 1,concat(' and years = ',y1,',q1,0')
        union all select 3,concat(' and years = ',y1,',q2,0')
        union all select 5,concat(' and years = ',y1,',q3,0')
        union all select 7,concat(' and years = ',y1,',q4,0');
     
    declare cur3 cursor for 
        select 1,concat(' and years = ',y1,',yearly,0')
        union all select 3,concat(' and years = ',y1-1,',yearly,0')
        union all select 5,concat(' and years = ',y1-2,',yearly,0');
    declare continue handler for not found set done = 1;

    
    if (employeesid is not null and CHAR_LENGTH(employeesid) = 0) then
        set employeesid = null;
    end if;
    if (departsid is not null and CHAR_LENGTH(departsid) = 0) then
        set departsid = null;
    end if;
    
    set sqlstr = concat('ifNull(cast(sum(if(stattype = $i and type=',currencyid,' $scol))/(select statisticunit from currencyexchange where id = ',currencyid,' ) as DECIMAL(14,2)),0) $col1 ,
                         ifNull(cast(sum(if(stattype = $i and type=',currencyid,' $scol))/sum(if(stattype = 5 and type=',currencyid,' $scol)) as DECIMAL(14,2)),0)  $col2 ');
    set i = 0;
    while i<5 do
        set tsqlstring = '';
        if datetype = 'm' then
            
            open cur1;
        end if;
        if datetype = 'q' then
            
            open cur2;
        end if;
        if datetype = 'y' then
            
            open cur3;
        end if;
        
            read_loop: loop
                if datetype = 'm' then
                    fetch cur1 into coli,scol;
                end if;
                if datetype = 'q' then
                    fetch cur2 into coli,scol;
                end if;
                if datetype = 'y' then
                    fetch cur3 into coli,scol;
                end if;
                if done then
                    leave read_loop;
                end if;
                set tsqlstr = sqlstr;
                set tsqlstr = replace(tsqlstr,'$scol',scol);
                set tsqlstr = replace(tsqlstr,'$col1',concat('col',coli));
                set tsqlstr = replace(tsqlstr,'$col2',concat('col',coli+1));
                set tsqlstr = replace(tsqlstr,'$i',i+1);
                if coli = 1 then 
                    set tsqlstring = concat(tsqlstring,'select ', tsqlstr);
                else 
                    set tsqlstring = concat(tsqlstring,' , ',tsqlstr);
                end if;

            end loop;
    
        if datetype = 'm' then
            
            close cur1;
        end if;
        if datetype = 'q' then
            
            close cur2;
        end if;
        if datetype = 'y' then
            
            close cur3;
        end if;
        
        set done = FALSE;

        set sqlcondition = concat(' from abilitystat abi left join employee emp on abi.employeeid = emp.id left join empdepart empd 
            on emp.depid = empd.id  where  abi.statclass = 2 ');    

        if (employeesid is not null and departsid is not null) then
            set sqlcondition = concat(sqlcondition,' and (abi.employeeid in (',employeesid,') or emp.depid in (',departsid,')) ');
        else
            if employeesid is not null then
                set sqlcondition = concat(sqlcondition,' and abi.employeeid in (',employeesid,') ');
            elseif departsid is not null then
                set sqlcondition = concat(sqlcondition, ' and emp.depid in (',departsid,') ');
            end if;
        end if;


        if i = 0 then 
            set sqlstring = concat(sqlstring,tsqlstring);
        else
            set sqlstring = concat(sqlstring,' union all ',tsqlstring);
        end if; 

        set sqlstring = concat(sqlstring,sqlcondition);
        set i=i+1;
    end while;

    
    set @stmt = sqlstring;
        PREPARE stmt FROM @stmt;
        EXECUTE stmt;
   
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `chart_ability_orderreceivingmoney_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `chart_ability_orderreceivingmoney_proc`(in datetype varchar(10),in currencyid int,in employeesid varchar(4000),in departsid varchar(4000),in m1 varchar(10),in m2 varchar(10),in m3 varchar(10),in y1 int,in faranchiseid int,in checktype int)
begin
    declare sqlstr longtext default '';
    declare tsqlstr longtext default '';
    declare sqlstring longtext default '';
    declare tsqlstring longtext default '';
    declare sqlcondition longtext default '';
    declare m1str varchar(10) default concat('m',right(m1,2)); 
    declare m2str varchar(10) default concat('m',right(m2,2)); 
    declare m3str varchar(10) default concat('m',right(m3,2)); 
    declare m1year varchar(10) default left(m1,4); 
    declare m2year varchar(10) default left(m2,4); 
    declare m3year varchar(10) default left(m3,4); 
    declare coli int; 
    declare i int; 
    declare scol longtext default ''; 
    declare done TINYINT DEFAULT 0;

    
    declare cur1 cursor for 
        select 1,concat(',if(years = ',m1year,',',m1str,',0)+ if(years = ',m2year,',',m2str,',0)+if(years = ',m3year,',',m3str,',0),0')
        union all select 2,concat(' and years = ',m1year,',',m1str,',0')
        union all select 3,concat(' and years = ',m2year,',',m2str,',0')
        union all select 4,concat(' and years = ',m3year,',',m3str,',0');
     
    declare cur2 cursor for 
        select 1,concat(' and years = ',y1,',q1,0')
        union all select 2,concat(' and years = ',y1,',q2,0')
        union all select 3,concat(' and years = ',y1,',q3,0')
        union all select 4,concat(' and years = ',y1,',q4,0');
     
    declare cur3 cursor for 
        select 1,concat(' and years = ',y1,',yearly,0')
        union all select 2,concat(' and years = ',y1-1,',yearly,0')
        union all select 3,concat(' and years = ',y1-2,',yearly,0');
    declare continue handler for not found set done = 1;

    
    if (employeesid is not null and CHAR_LENGTH(employeesid) = 0) then
        set employeesid = null;
    end if;
    if (departsid is not null and CHAR_LENGTH(departsid) = 0) then
        set departsid = null;
    end if;
    
    set sqlstr = concat('ifnull(cast(sum(if(type=',currencyid,' $scol))/(select statisticunit from currencyexchange where id = ',currencyid,' ) as DECIMAL(14,2)),0) $col1 ');
    set i = 0;
    while i<2 do
        set tsqlstring = '';
        if datetype = 'm' then
            
            open cur1;
        end if;
        if datetype = 'q' then
            
            open cur2;
        end if;
        if datetype = 'y' then
            
            open cur3;
        end if;
        
            read_loop: loop
                if datetype = 'm' then
                    fetch cur1 into coli,scol;
                end if;
                if datetype = 'q' then
                    fetch cur2 into coli,scol;
                end if;
                if datetype = 'y' then
                    fetch cur3 into coli,scol;
                end if;
                if done then
                    leave read_loop;
                end if;
                set tsqlstr = sqlstr;
                set tsqlstr = replace(tsqlstr,'$scol',scol);
                set tsqlstr = replace(tsqlstr,'$col1',concat('col',coli));
                if coli = 1 then 
                    set tsqlstring = concat(tsqlstring,'select ', tsqlstr);
                else 
                    set tsqlstring = concat(tsqlstring,' , ',tsqlstr);
                end if;

            end loop;
    
        if datetype = 'm' then
            
            close cur1;
        end if;
        if datetype = 'q' then
            
            close cur2;
        end if;
        if datetype = 'y' then
            
            close cur3;
        end if;
        
        set done = FALSE;

        set sqlcondition = concat(' from abilitystat abi left join employee emp on abi.employeeid = emp.id left join empdepart empd 
            on emp.depid = empd.id  where abi.stattype = ',i+1,' and abi.statclass = 4 ');    

        
        if checktype = 1 then
            set sqlcondition = concat(sqlcondition, ' and abi.employeeid is not null');
            if (employeesid is not null and departsid is not null) then
                set sqlcondition = concat(sqlcondition,' and (abi.employeeid in (',employeesid,') or emp.depid in (',departsid,')) ');
            else
                if employeesid is not null then
                    set sqlcondition = concat(sqlcondition,' and abi.employeeid in (',employeesid,') ');
                elseif departsid is not null then
                    set sqlcondition = concat(sqlcondition, ' and emp.depid in (',departsid,') ');
                end if;
            end if;
        else
            set sqlcondition = concat(sqlcondition, ' and abi.faranchiseid = ',faranchiseid);
        end if;


        if i = 0 then 
            set sqlstring = concat(sqlstring,tsqlstring);
        else
            set sqlstring = concat(sqlstring,' union all ',tsqlstring);
        end if; 

        set sqlstring = concat(sqlstring,sqlcondition);
        set i=i+1;
    end while;

    set @stmt = sqlstring;
        PREPARE stmt FROM @stmt;
        EXECUTE stmt;
   
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `chart_ability_orderreceiving_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `chart_ability_orderreceiving_proc`(in datetype varchar(10),in employeesid varchar(4000),in departsid varchar(4000),in m1 varchar(10),in m2 varchar(10),in m3 varchar(10),in y1 int,in faranchiseid int,in checktype int)
begin
    declare sqlstr longtext default '';
    declare tsqlstr longtext default '';
    declare sqlstring longtext default '';
    declare tsqlstring longtext default '';
    declare sqlcondition longtext default '';
    declare m1str varchar(10) default concat('m',right(m1,2)); 
    declare m2str varchar(10) default concat('m',right(m2,2)); 
    declare m3str varchar(10) default concat('m',right(m3,2)); 
    declare m1year varchar(10) default left(m1,4); 
    declare m2year varchar(10) default left(m2,4); 
    declare m3year varchar(10) default left(m3,4); 
    declare coli int; 
    declare i int; 
    declare scol longtext default ''; 
    declare done TINYINT DEFAULT 0;

    
    declare cur1 cursor for 
        select 1,concat(',if(years = ',m1year,',',m1str,',0)+ if(years = ',m2year,',',m2str,',0)+if(years = ',m3year,',',m3str,',0),0')
        union all select 3,concat(' and years = ',m1year,',',m1str,',0')
        union all select 5,concat(' and years = ',m2year,',',m2str,',0')
        union all select 7,concat(' and years = ',m3year,',',m3str,',0');
     
    declare cur2 cursor for 
        select 1,concat(' and years = ',y1,',q1,0')
        union all select 3,concat(' and years = ',y1,',q2,0')
        union all select 5,concat(' and years = ',y1,',q3,0')
        union all select 7,concat(' and years = ',y1,',q4,0');
     
    declare cur3 cursor for 
        select 1,concat(' and years = ',y1,',yearly,0')
        union all select 3,concat(' and years = ',y1-1,',yearly,0')
        union all select 5,concat(' and years = ',y1-2,',yearly,0');
    declare continue handler for not found set done = 1;

    
    if (employeesid is not null and CHAR_LENGTH(employeesid) = 0) then
        set employeesid = null;
    end if;
    if (departsid is not null and CHAR_LENGTH(departsid) = 0) then
        set departsid = null;
    end if;
    
    set sqlstr = concat('sum(if($stattype $scol)) $col1,  
                         ifnull(cast(sum(if($stattype $scol))/sum(if(1=1 $scol)) as DECIMAL(14,2)),0) $col2 ');
    set i = 0;
    while i<6 do
        set tsqlstring = '';
        if datetype = 'm' then
            
            open cur1;
        end if;
        if datetype = 'q' then
            
            open cur2;
        end if;
        if datetype = 'y' then
            
            open cur3;
        end if;
        
            read_loop: loop
                if datetype = 'm' then
                    fetch cur1 into coli,scol;
                end if;
                if datetype = 'q' then
                    fetch cur2 into coli,scol;
                end if;
                if datetype = 'y' then
                    fetch cur3 into coli,scol;
                end if;
                if done then
                    leave read_loop;
                end if;
                set tsqlstr = sqlstr;
                set tsqlstr = replace(tsqlstr,'$scol',scol);
                set tsqlstr = replace(tsqlstr,'$col1',concat('col',coli));
                set tsqlstr = replace(tsqlstr,'$col2',concat('col',coli+1));
                if coli = 1 then 
                    set tsqlstring = concat(tsqlstring,'select ', tsqlstr);
                else 
                    set tsqlstring = concat(tsqlstring,' , ',tsqlstr);
                end if;
            end loop;
        set tsqlstring = concat(tsqlstring,' , ',i+1,' as id');
        if datetype = 'm' then
            
            close cur1;
        end if;
        if datetype = 'q' then
            
            close cur2;
        end if;
        if datetype = 'y' then
            
            close cur3;
        end if;
        
        set done = FALSE;

        
        if i<5 then
            set tsqlstring = replace(tsqlstring,'$stattype',concat('stattype=',i+1));
        else
            set tsqlstring = replace(tsqlstring,'$stattype',1=1);
        end if;
        set sqlcondition = concat(' from abilitystat abi left join employee emp on abi.employeeid = emp.id left join empdepart empd 
            on emp.depid = empd.id  where  abi.statclass = 3 ');    

        
        if checktype = 1 then
            set sqlcondition = concat(sqlcondition, ' and abi.employeeid is not null');
            if (employeesid is not null and departsid is not null) then
                set sqlcondition = concat(sqlcondition,' and (abi.employeeid in (',employeesid,') or emp.depid in (',departsid,')) ');
            else
                if employeesid is not null then
                    set sqlcondition = concat(sqlcondition,' and abi.employeeid in (',employeesid,') ');
                elseif departsid is not null then
                    set sqlcondition = concat(sqlcondition, ' and emp.depid in (',departsid,') ');
                end if;
            end if;
        else
            set sqlcondition = concat(sqlcondition, ' and abi.faranchiseid = ',faranchiseid);
        end if;

        if i = 0 then 
            set sqlstring = concat(sqlstring,tsqlstring);
        else
            set sqlstring = concat(sqlstring,' union all ',tsqlstring);
        end if; 

        set sqlstring = concat(sqlstring,sqlcondition);
        set i=i+1;
    end while;

    set @stmt = sqlstring;
        PREPARE stmt FROM @stmt;
        EXECUTE stmt;
   
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `chart_manage_check_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `chart_manage_check_proc`(in differnum int,in employeeIds varchar(4000),in departIds varchar(4000),in currentYStart varchar(20),in currentYEnd varchar(20),in currentYToM varchar(50))
begin
        declare actualsqlcondition longtext default ''; -- 统计实际时sql 条件
        declare targetsqlcondition longtext default ''; -- 统计目标时sql 条件
        declare sqlstring longtext default ''; -- 最终执行(返回数据)的sql

        declare i int default 1;  -- 循环次数i
        declare num int default 1;  -- 数量


        drop table if exists `chart_manage_check`;
        /* 创建结果集临时表*/
        create temporary  table IF NOT EXISTS `chart_manage_check`
        (
            `id` int(10) NOT NULL AUTO_INCREMENT COMMENT 'ID',
            `name` varchar(10)  COMMENT '员工/部门',
            `year` varchar(10)  COMMENT '年份',
            `month` int(10)  COMMENT '月份',
            `type` int(10)  COMMENT '1.目标,2.实际',
            UNIQUE INDEX `Index` (`name`,`year`,`month`),
            PRIMARY KEY (`id`)
        );
        truncate table `chart_manage_check`;

        /* 清理初始化参数 */
        if (employeeIds is not null and CHAR_LENGTH(employeeIds) = 0) then
            set employeeIds = null;
        end if;
        if (departIds is not null and CHAR_LENGTH(departIds) = 0) then
            set departIds = null;
        end if;
        if (currentYToM is not null and CHAR_LENGTH(currentYToM) = 0) then
            set currentYToM = null;
        end if;
        if (currentYStart is not null and CHAR_LENGTH(currentYStart) = 0) then
            set currentYStart = null;
        end if;
        


       /*统计目标--员工、部门条件*/
        if (employeeIds is not null and departIds is not null) then

            set targetsqlcondition = concat(targetsqlcondition,' (empt.employeeid in (',employeeIds,') or (empt.depid in (',departIds,') and empt.employeeid is not null))');
        else
            if employeeIds is not null then
                set targetsqlcondition = concat(targetsqlcondition, ' empt.employeeid in (',employeeIds,')');
            elseif departIds is not null then
                set targetsqlcondition = concat(targetsqlcondition, ' empt.depid  in (',departIds,') and empt.employeeid is not null');
            end if;
        end if;

        /*统计实际--员工、部门条件*/
        if (employeeIds is not null and departIds is not null) then

            set actualsqlcondition = concat(actualsqlcondition,' (empl.employeeid in (',employeeIds,') or empl.depid in (',departIds,')) ');
        else
            if employeeIds is not null then
                set actualsqlcondition = concat(actualsqlcondition, ' empl.employeeid in (',employeeIds,')');
            elseif departIds is not null then
                set actualsqlcondition = concat(actualsqlcondition, ' empl.depid  in (',departIds,')');
            end if;
        end if;


        if(currentYToM is not null and currentYStart is not null) then

       -- set tmpdate = startdate;
       -- while tmpcount <= monthcount do

       --      if tmpcount > 1 then 
       --          set tmpdate = date_add(tmpdate,interval 1 day); 
       --      end if;
                
       --      set startplanoverdate = tmpdate;

       --      set tmpdate = date_sub(date_add(tmpdate,interval 1 month),interval 1 day); 

       --      set endplanoverdate = tmpdate;

       --  /*  求部门目标  */
       --  set sqlstring = concat('replace into chart_manage_check(name,year,month,type)
       --      select emp.fullname,empt.years,empt.months,1 FROM  emptarget empt  
       --      left join empdepart empd on empt.depid  = empd.id
       --      where empt.years and empt.employeeid is null and empl.depid  in (',departIds,')  ');

       --  set sqlstring = replace(sqlstring,'$actualsqlcondition',actualsqlcondition);
       --  set @stmt = sqlstring; 
       --  PREPARE stmt FROM @stmt;
       --  EXECUTE stmt;        
       --  DEALLOCATE PREPARE stmt;

       --  end while;


        /*  实际连目标  */
        -- 财务数据
        set sqlstring = concat('replace into chart_manage_check(name,year,month,type)
            select emp.fullname,
              if(date_format(f.createdatetime,"%c")-',differnum,'<=0,date_format(f.createdatetime,"%Y")-1,date_format(f.createdatetime,"%Y")),
              if(date_format(f.createdatetime,"%c")-',differnum,'<=0,date_format(f.createdatetime,"%c")-',differnum,'+12,date_format(f.createdatetime,"%c")-',differnum,'),1
            FROM financialdata f
              left join managedef empl on empl.employeeid = f.employeeid
              left join employee emp on emp.id = empl.employeeid
              left join emptarget empt on f.employeeid=empt.employeeid and
                  if(date_format(f.createdatetime,"%c")-',differnum,'<=0,date_format(f.createdatetime,"%Y")-1,date_format(f.createdatetime,"%Y"))=empt.years
            and
               if(date_format(f.createdatetime,"%c")-',differnum,'<=0,date_format(f.createdatetime,"%c")-',differnum,'+12,date_format(f.createdatetime,"%c")-',differnum,')=empt.months
            where f.createdatetime BETWEEN "',currentYStart,'" and "',currentYEnd,'" and empt.id is null and $actualsqlcondition  ');

        set sqlstring = replace(sqlstring,'$actualsqlcondition',actualsqlcondition);
        set @stmt = sqlstring; 
        PREPARE stmt FROM @stmt;
        EXECUTE stmt;        
        DEALLOCATE PREPARE stmt;

        -- 新增机会
        set sqlstring = concat('replace into chart_manage_check(name,year,month,type)
            select o.fullname,
              if(date_format(o.createdatetime,"%c")-',differnum,'<=0,date_format(o.createdatetime,"%Y")-1,date_format(o.createdatetime,"%Y")),
              if(date_format(o.createdatetime,"%c")-',differnum,'<=0,date_format(o.createdatetime,"%c")-',differnum,'+12,date_format(o.createdatetime,"%c")-',differnum,'),1
            from(
                select o.createdatetime,o.ownerid,emp.fullname
                FROM opt o
                left join managedef empl on empl.employeeid = o.ownerid 
                left join employee emp on emp.id = empl.employeeid
                where o.isdelete = 0 and o.createdatetime BETWEEN "',currentYStart,'" and "',currentYEnd,'" and $actualsqlcondition
                group by o.ownerid,date_format(o.createdatetime,"%Y"),date_format(o.createdatetime,"%c")
            ) o
              left join emptarget empt on o.ownerid=empt.employeeid and
                  if(date_format(o.createdatetime,"%c")-',differnum,'<=0,date_format(o.createdatetime,"%Y")-1,date_format(o.createdatetime,"%Y"))=empt.years
                    and
                  if(date_format(o.createdatetime,"%c")-',differnum,'<=0,date_format(o.createdatetime,"%c")-',differnum,'+12,date_format(o.createdatetime,"%c")-',differnum,')=empt.months
            where  empt.id is null  ');

        set sqlstring = replace(sqlstring,'$actualsqlcondition',actualsqlcondition);
        set @stmt = sqlstring; 
        PREPARE stmt FROM @stmt;
        EXECUTE stmt;        
        DEALLOCATE PREPARE stmt;

        -- 新增客户
        set sqlstring = concat('replace into chart_manage_check(name,year,month,type)
            select cust.fullname,
              if(date_format(cust.createdatetime,"%c")-',differnum,'<=0,date_format(cust.createdatetime,"%Y")-1,date_format(cust.createdatetime,"%Y")),
              if(date_format(cust.createdatetime,"%c")-',differnum,'<=0,date_format(cust.createdatetime,"%c")-',differnum,'+12,date_format(cust.createdatetime,"%c")-',differnum,'),1
            from (
                  select cust.ownerid,cust.createdatetime,emp.fullname
                  from customertemp cust
                  left join customeofftmp cot ON  cot.customertempid = cust.id
                  left join customer cus on cot.customerofficialid = cus.id
                  left join managedef empl on cust.ownerid = empl.employeeid  
                  left join employee emp on emp.id = empl.employeeid
                  where (cust.isdelete = 0 or cus.isdelete = 0) and cust.createdatetime BETWEEN "',currentYStart,'" and "',currentYEnd,'" and $actualsqlcondition
                  group by cust.ownerid,date_format(cust.createdatetime,"%Y"),date_format(cust.createdatetime,"%c")
             ) cust
              left join emptarget empt on cust.ownerid=empt.employeeid and
                  if(date_format(cust.createdatetime,"%c")-',differnum,'<=0,date_format(cust.createdatetime,"%Y")-1,date_format(cust.createdatetime,"%Y"))=empt.years
                     and
               if(date_format(cust.createdatetime,"%c")-',differnum,'<=0,date_format(cust.createdatetime,"%c")-',differnum,'+12,date_format(cust.createdatetime,"%c")-',differnum,')=empt.months
            where empt.id is null');

        set sqlstring = replace(sqlstring,'$actualsqlcondition',actualsqlcondition);
        set @stmt = sqlstring; 
        PREPARE stmt FROM @stmt;
        EXECUTE stmt;        
        DEALLOCATE PREPARE stmt;

        -- 客户拜访
        set sqlstring = concat('replace into chart_manage_check(name,year,month,type)
            select we.fullname,
              if(date_format(we.planstartdate,"%c")-',differnum,'<=0,date_format(we.planstartdate,"%Y")-1,date_format(we.planstartdate,"%Y")),
              if(date_format(we.planstartdate,"%c")-',differnum,'<=0,date_format(we.planstartdate,"%c")-',differnum,'+12,date_format(we.planstartdate,"%c")-',differnum,'),1
            from (
                select we.createrid,we.planstartdate,emp.fullname
                from workplan we
                left join managedef empl on we.createrid = empl.employeeid 
                left join employee emp on emp.id = empl.employeeid
                where we.customerid IS NOT NULL and we.isdelete = 0  and we.iscomplete = 1 and we.planstartdate BETWEEN "',currentYStart,'" and "',currentYEnd,'" and $actualsqlcondition
                 group by we.createrid,date_format(we.planstartdate,"%Y"),date_format(we.planstartdate,"%c")
            ) we 
           left join emptarget empt on we.createrid=empt.employeeid and
                  if(date_format(we.planstartdate,"%c")-',differnum,'<=0,date_format(we.planstartdate,"%Y")-1,date_format(we.planstartdate,"%Y"))=empt.years
                      and
               if(date_format(we.planstartdate,"%c")-',differnum,'<=0,date_format(we.planstartdate,"%c")-',differnum,'+12,date_format(we.planstartdate,"%c")-',differnum,')=empt.months
            where  empt.id is null  ');

        set sqlstring = replace(sqlstring,'$actualsqlcondition',actualsqlcondition);
        set @stmt = sqlstring; 
        PREPARE stmt FROM @stmt;
        EXECUTE stmt;        
        DEALLOCATE PREPARE stmt;

       -- 目标连实际  求实际是否配置
      set sqlstring = concat('replace into chart_manage_check(name,year,month,type)
            select emp.fullname,empt.years,empt.months,2
            FROM  emptarget empt
              left join managedef empl on empl.employeeid = empt.employeeid
              left join employee emp on emp.id = empl.employeeid
              left join financialdata f on f.employeeid=empt.employeeid and
                  if(date_format(f.createdatetime,"%c")-',differnum,'<=0,date_format(f.createdatetime,"%Y")-1,date_format(f.createdatetime,"%Y"))=empt.years
            and
               if(date_format(f.createdatetime,"%c")-',differnum,'<=0,date_format(f.createdatetime,"%c")-',differnum,'+12,date_format(f.createdatetime,"%c")-',differnum,')=empt.months
            where empt.employeeid is not null and empt.years = date_format("',currentYStart,'","%Y") and empt.months in (',currentYToM,') and 
            f.id is null and $actualsqlcondition  ');

        set sqlstring = replace(sqlstring,'$actualsqlcondition',actualsqlcondition);
        -- select sqlstring
        set @stmt = sqlstring; 
        PREPARE stmt FROM @stmt;
        EXECUTE stmt;        
        DEALLOCATE PREPARE stmt;

            select * from chart_manage_check order by name,month;

        end if;
      

        

       
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `chart_manage_salesranking_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `chart_manage_salesranking_proc`(in stattype varchar(10),in currencyid int,in employeeIds varchar(4000),in departIds varchar(4000),in statisticunit decimal(14,2),in currentYStart varchar(20),in currentYEnd varchar(20),in currentYToM varchar(50),
      in currentMStart varchar(20),in next2MEnd varchar(20),in currentToM varchar(20),in next1ToM varchar(20),in next2ToM varchar(20),in m1 varchar(20),in m2 varchar(20),in m3 varchar(20))
begin
        declare targetsqlstr longtext default ''; -- 统计实际时sql
        declare actualsqlstr longtext default ''; -- 统计目标时sql
        declare list longtext default ''; -- 接单率list
        declare temptargetsqlstr longtext default ''; -- 统计实际时sql (临时执行)
        declare tempactualsqlstr longtext default ''; -- 统计目标时sql (临时执行)
        declare actualsqlcondition longtext default ''; -- 统计实际时sql 条件
        declare targetsqlcondition longtext default ''; -- 统计目标时sql 条件
        declare sqlstring longtext default ''; -- 最终执行(返回数据)的sql
        declare sqlcondition longtext default ''; -- 最终执行(返回数据)的sql条件
        declare currentYToMnum int; -- 月份数量
        declare departIdNum int; -- 部门的数量 
        declare i int default 1;  -- 循环次数i
        declare emplNum int; -- 员工的数量
        declare mm1 varchar(100); --  根据m1获取指定值
        declare mm2 varchar(100); --  根据m2获取指定值
        declare mm3 varchar(100); --  根据m3获取指定值
        declare type int default 4; -- 预测金额类型

        /*sql1 - sql11 (预测金额、实际接单率、实际新增客户数量、实际拜访数量、实际新增机会数量、实际新增机会金额、订单值、发货值、实际毛利率、实际回款周期、实际费用支出)*/
        declare actual_sql1 longtext default '';
        declare actual_sql2 longtext default '';
        declare actual_sql3 longtext default '';
        declare actual_sql4 longtext default '';
        declare actual_sql5 longtext default '';
        declare actual_sql6 longtext default '';
        declare actual_sql7 longtext default '';
        declare actual_sql8 longtext default '';
        declare actual_sql9 longtext default '';
        declare actual_sql10 longtext default '';
        declare actual_sql11 longtext default '';

        declare target_sql1 longtext default '';
        declare target_sql2 longtext default '';
        declare target_sql3 longtext default '';
        declare target_sql4 longtext default '';
        declare target_sql5 longtext default '';
        declare target_sql6 longtext default '';
        declare target_sql7 longtext default '';
        declare target_sql8 longtext default '';
        declare target_sql9 longtext default '';
        declare target_sql10 longtext default '';
        declare target_sql11 longtext default '';

        /* 清理初始化参数 */
        if (employeeIds is not null and CHAR_LENGTH(employeeIds) = 0) then
            set employeeIds = null;
        end if;
        if (departIds is not null and CHAR_LENGTH(departIds) = 0) then
            set departIds = null;
        end if;
        if (currentYToM is not null and CHAR_LENGTH(currentYToM) = 0) then
            set currentYToM = null;
        end if;
        if (currentYStart is not null and CHAR_LENGTH(currentYStart) = 0) then
            set currentYStart = null;
        end if;


        drop table if exists `chart_manage_salesranking_actual_table`;
        /* 创建结果集临时表*/
        create temporary  table IF NOT EXISTS `chart_manage_salesranking_actual_table`
        (
            `id` int(10) NOT NULL AUTO_INCREMENT COMMENT 'ID',
            `eid` int(10)  COMMENT '员工/部门id',
            `value` DECIMAL(14,2)  COMMENT '值',
            `stype` int(10)  COMMENT '统计实际值的类型',
            PRIMARY KEY (`id`)
        );
        truncate table `chart_manage_salesranking_actual_table`;


        drop table if exists `chart_manage_salesranking_target_table`;
        /* 创建结果集临时表*/
        create temporary table IF NOT EXISTS `chart_manage_salesranking_target_table`
        (
            `id` int(10) NOT NULL AUTO_INCREMENT COMMENT 'ID',
            `eid` int(10)  COMMENT '员工/部门id',
            `value` DECIMAL(14,2)  COMMENT '值',
            `stype` int(10)  COMMENT '统计目标值的类型',
            PRIMARY KEY (`id`)
        );
        truncate table `chart_manage_salesranking_target_table`;

        /*求出月份数量*/
        select CHAR_LENGTH(currentYToM) - CHAR_LENGTH(replace(currentYToM,',','')) + 1 into currentYToMnum;

        /*循环遍历,得出拿统计表中那些列值*/
        while i <= currentYToMnum do
           select SUBSTRING_INDEX(SUBSTRING_INDEX(currentYToM,',',currentYToMnum - i + 1),',',-1) into @m;
           if @m < 10 then
             set @m = concat('0',@m);
           end if;
           set list = concat(list,'m',@m);
           set list = concat(list,'+');
           set i = i + 1;
        end while;    
        set list = left(list,length(list)-1);
        set i=1;      

        /*根据币种,获取统计表相应的type*/
        if currencyid=2 then
           set type=6;
        end if;

        /*获取前三个月的列值*/
        set mm1 = concat('m',right(m1,2));
        set mm2 = concat('m',right(m2,2));
        set mm3 = concat('m',right(m3,2));

        /*初始化 统计目标 查询语句*/
        set targetsqlstr = 'insert into chart_manage_salesranking_target_table(eid,value,stype) select $eid eid,IFNULL($scol,0) value,$stype stype FROM emptarget empt where $sqlcondition';

        /*初始化 统计实际 查询语句*/
        set actualsqlstr = 'insert into chart_manage_salesranking_actual_table(eid,value,stype) select $select';

       set target_sql1 = concat('insert into chart_manage_salesranking_target_table(eid,value,stype)
                                  select
                                       $eid eid,empt.col2+empt.col3+empt.col4 as value,1 stype
                                  from (
                                  select empt.employeeid,empt.depid,
                                  ifnull(sum(cast(if(find_in_set(months,substr(\'',currentToM,'\',5)) and years = left(\'',currentToM,'\',4),
                                  if(',currencyid,'=1,targetmoney,targetmoneyminor)/',statisticunit,',0)  as decimal(14,2))),0) as col2,
                                  ifnull(sum(cast(if(find_in_set(months,substr(\'',next1ToM,'\',5)) and years = left(\'',next1ToM,'\',4),
                                  if(',currencyid,'=1,targetmoney,targetmoneyminor)/',statisticunit,',0)  as decimal(14,2))),0) as col3,
                                  ifnull(sum(cast(if(find_in_set(months,substr(\'',next2ToM,'\',5)) and years = left(\'',next2ToM,'\',4),
                                  if(',currencyid,'=1,targetmoney,targetmoneyminor)/',statisticunit,',0)  as decimal(14,2))),0) as col4
                                  from emptarget empt where $sqlcondition
                                  ) empt');

        set actual_sql1 = concat('$eid eid, ifnull(cast(sum(if(o.planoverdate between \'',currentMStart,'\' and  \'',next2MEnd,'\',
                                    if(o.stageid=2,convertopt.converttotalprice*a.stageid2,
                                    if(o.stageid=3,convertopt.converttotalprice*a.stageid3,
                                    if(o.stageid=4,convertopt.converttotalprice*a.stageid4,
                                    if(o.stageid=5,convertopt.converttotalprice*a.stageid5,
                                    if(o.stageid=6,convertopt.converttotalprice*a.stageid6,
                                    if(o.stageid=7,convertopt.converttotalprice,0)))))),
                                    0)/',statisticunit,') as decimal(14,2)),0) as value, 1 stype
                                    from opt o
                                    LEFT JOIN (
                                        SELECT  opt.id id, IF(',currencyid,'=1,
                                        IF(opt.currencyid = 1,
                                        opt.totalprice,
                                        opt.totalpriceminor * CAST(IF(',currencyid,'=1, IFNULL(cc.intoajformula, lasc.formula), IFNULL(cc.ajtoinformula, lasc.formula)) AS DECIMAL(14, 2))),
                                        IF(opt.currencyid = 2,
                                        opt.totalpriceminor,
                                        opt.totalprice * CAST(IF(',currencyid,'=1, IFNULL(cc.intoajformula, lasc.formula), IFNULL(cc.ajtoinformula, lasc.formula)) AS DECIMAL(14, 2)))) converttotalprice
                                        FROM opt
                                        LEFT JOIN currencyconvert cc ON IFNULL(opt.realityoverdate, opt.planoverdate) BETWEEN cc.startdate AND cc.enddate
                                        LEFT JOIN (
                                        SELECT CAST(IF(1 = 1, intoajformula, ajtoinformula) AS DECIMAL(14, 2)) formula
                                        FROM currencyconvert
                                        ORDER BY id DESC
                                        LIMIT 1) lasc ON 1 = 1) convertopt ON o.id = convertopt.id
                                    left join managedef empl on o.ownerid = empl.employeeid
                                    left join (
                                    select abi.employeeid,ifnull(cast(sum(if(abi.type=',type,' and stattype=1,if(years = left(\'',m1,'\',4),',mm1,',0)+ if(years = left(\'',m2,'\',4),',mm2,',0)+if(years = left(\'',m3,'\',4),',mm3,',0),0))/sum(if(abi.type=',type-1,' and stattype=1 ,if(years = left(\'',m1,'\',4),',mm1,',0)+ if(years = left(\'',m2,'\',4),',mm2,',0)+if(years = left(\'',m3,'\',4),',mm3,',0),0)) as DECIMAL(14,2)),0)  stageid2,
                                    ifnull(cast(sum(if(abi.type=',type,' and stattype=2,if(years = left(\'',m1,'\',4),',mm1,',0)+ if(years = left(\'',m2,'\',4),',mm2,',0)+if(years = left(\'',m3,'\',4),',mm3,',0),0))/sum(if(abi.type=',type-1,' and stattype=2,if(years = left(\'',m1,'\',4),',mm1,',0)+ if(years = left(\'',m2,'\',4),',mm2,',0)+if(years = left(\'',m3,'\',4),',mm3,',0),0)) as DECIMAL(14,2)),0)  stageid3,
                                    ifnull(cast(sum(if(abi.type=',type,' and stattype=3,if(years = left(\'',m1,'\',4),',mm1,',0)+ if(years = left(\'',m2,'\',4),',mm2,',0)+if(years = left(\'',m3,'\',4),',mm3,',0),0))/sum(if(abi.type=',type-1,' and stattype=3,if(years = left(\'',m1,'\',4),',mm1,',0)+ if(years = left(\'',m2,'\',4),',mm2,',0)+if(years = left(\'',m3,'\',4),',mm3,',0),0)) as DECIMAL(14,2)),0)  stageid4,
                                    ifnull(cast(sum(if(abi.type=',type,' and stattype=4,if(years = left(\'',m1,'\',4),',mm1,',0)+ if(years = left(\'',m2,'\',4),',mm2,',0)+if(years = left(\'',m3,'\',4),',mm3,',0),0))/sum(if(abi.type=',type-1,' and stattype=4,if(years = left(\'',m1,'\',4),',mm1,',0)+ if(years = left(\'',m2,'\',4),',mm2,',0)+if(years = left(\'',m3,'\',4),',mm3,',0),0)) as DECIMAL(14,2)),0)  stageid5,
                                    ifnull(cast(sum(if(abi.type=',type,' and stattype=5,if(years = left(\'',m1,'\',4),',mm1,',0)+ if(years = left(\'',m2,'\',4),',mm2,',0)+if(years = left(\'',m3,'\',4),',mm3,',0),0))/sum(if(abi.type=',type-1,' and stattype=5,if(years = left(\'',m1,'\',4),',mm1,',0)+ if(years = left(\'',m2,'\',4),',mm2,',0)+if(years = left(\'',m3,'\',4),',mm3,',0),0)) as DECIMAL(14,2)),0)  stageid6
                                    from abilitystat abi  left join managedef empl on abi.employeeid = empl.employeeid
                                    where abi.statclass = 5 and $sqlcondition
                                    ) a  ON $oncondition
                                    where o.optstatus in (1,2) and o.isdelete=0 and  $sqlcondition');
        
        set target_sql2 = concat('sum(if(months in(',currentYToM,') and years = DATE_FORMAT(\'',currentYStart,'\',\'%Y\'),orderreceiverate,0)/',currentYToMnum,')');

        set actual_sql2 = concat('$eid eid,
                                    ifnull(cast(sum(if(years = DATE_FORMAT(\'',currentYStart,'\',\'%Y\'),',list,',0)/',currentYToMnum,')*100 as decimal(14,2)),0) value
                                                , 2 stype
                                              from (select a.employeeid,sum(a.m01)/b.m01 m01,sum(a.m02)/b.m02 m02,sum(a.m03)/b.m03 m03,sum(a.m04)/b.m04 m04,
                                              sum(a.m05)/b.m05 m05,sum(a.m06)/b.m06 m06,sum(a.m07)/b.m07 m07,sum(a.m08)/b.m08 m08,
                                              sum(a.m09)/b.m09 m09,sum(a.m10)/b.m10 m10,sum(a.m11)/b.m11 m11,sum(a.m12)/b.m12 m12,
                                              sum(a.q1)/b.q1 q1,sum(a.q2)/b.q2 q2,sum(a.q3)/b.q3 q3,sum(a.q4)/b.q4 q4,sum(a.yearly)/b.yearly yearly,a.years
                                              from abilitystat a
                                              left join managedef empl on a.employeeid = empl.employeeid
                                              left join (
                                              select empl.employeeid,sum(m01) m01,sum(m02) m02,sum(m03) m03,sum(m04) m04,sum(m05) m05,sum(m06) m06,sum(m07) m07,sum(m08) m08,sum(m09) m09,
                                              sum(m10) m10,sum(m11) m11,sum(m12) m12,sum(q1) q1,sum(q2) q2,sum(q3) q3,sum(q4) q4,sum(yearly) yearly,years
                                              from abilitystat b
                                              left join managedef empl on b.employeeid = empl.employeeid
                                              where statclass=3 and b.years = DATE_FORMAT(\'',currentYStart,'\',\'%Y\') and $sqlcondition 
                                              ) b on a.employeeid=b.employeeid
                                              where statclass=3 and stattype=1 and a.years = DATE_FORMAT(\'',currentYStart,'\',\'%Y\') and $sqlcondition) a group by a.employeeid');

        set target_sql3 = concat('sum(if(months in(',currentYToM,') and years = DATE_FORMAT(\'',currentYStart,'\',\'%Y\')
                          ,newcustomernum,0))');

        set actual_sql3 = concat('$eid eid, ifnull(count(if(DATE_FORMAT(cust.createdatetime,\'%Y-%m-%d\') between \'',currentYStart,
                          '\' and \'',currentYEnd,'\',cust.id,NULL)),0)  value , 3 stype from customertemp cust
                          left join customeofftmp cot ON  cot.customertempid = cust.id
                          left join customer cus on cot.customerofficialid = cus.id
                          left join managedef empl on cust.ownerid = empl.employeeid where (cust.isdelete = 0 or cus.isdelete = 0) and $sqlcondition');

         set target_sql4 = concat('sum(if(months in(',currentYToM,') and years = DATE_FORMAT(\'',currentYStart,'\',\'%Y\')
                          ,customervisit,0))');

        set actual_sql4 = concat('$eid eid, ifnull(count(if(DATE_FORMAT(we.planstartdate,\'%Y-%m-%d\') between \'',currentYStart,
                          '\' and \'',currentYEnd,'\',we.id,NULL)),0)  value , 4 stype from workplan we
                          left join managedef empl on we.createrid = empl.employeeid where we.customerid IS NOT NULL and we.isdelete = 0  and we.iscomplete = 1 and $sqlcondition ');

         set target_sql5 = concat('sum(if(months in(',currentYToM,') and years = DATE_FORMAT(\'',currentYStart,'\',\'%Y\')
                          ,newoptnum,0))');

        set actual_sql5 = concat('$eid eid, ifnull(sum(if(DATE_FORMAT(o.createdatetime,\'%Y-%m-%d\') between \'',currentYStart,
                          '\' and \'',currentYEnd,'\',1,0)),0)  value , 5 stype from opt o
                          left join managedef empl on o.ownerid = empl.employeeid where o.isdelete = 0 and $sqlcondition');

         set target_sql6 = concat('sum(cast(if(months in(',currentYToM,') and years = DATE_FORMAT(\'',currentYStart,'\',\'%Y\')
                          ,if(',currencyid,'=1,newoptmoney,newoptmoneyminor)/',statisticunit,',0)  as decimal(14,2)))');

        set actual_sql6 = concat('$eid eid, ifnull(sum(cast(if(DATE_FORMAT(o.createdatetime,\'%Y-%m-%d\') between \'',currentYStart,
                          '\' and \'',currentYEnd,'\',convertopt.converttotalprice/',statisticunit,',0)  as decimal(14,2))),0)  value , 6 stype from opt o
                           LEFT JOIN (
                                SELECT  opt.id id, IF(',currencyid,'=1,
                                IF(opt.currencyid = 1,
                                opt.totalprice,
                                opt.totalpriceminor * CAST(IF(',currencyid,'=1, IFNULL(cc.intoajformula, lasc.formula), IFNULL(cc.ajtoinformula, lasc.formula)) AS DECIMAL(14, 2))),
                                IF(opt.currencyid = 2,
                                opt.totalpriceminor,
                                opt.totalprice * CAST(IF(',currencyid,'=1, IFNULL(cc.intoajformula, lasc.formula), IFNULL(cc.ajtoinformula, lasc.formula)) AS DECIMAL(14, 2)))) converttotalprice
                                FROM opt
                                LEFT JOIN currencyconvert cc ON IFNULL(opt.realityoverdate, opt.planoverdate) BETWEEN cc.startdate AND cc.enddate
                                LEFT JOIN (
                                SELECT CAST(IF(1 = 1, intoajformula, ajtoinformula) AS DECIMAL(14, 2)) formula
                                FROM currencyconvert
                                ORDER BY id DESC
                                LIMIT 1) lasc ON 1 = 1) convertopt ON o.id = convertopt.id
                          left join managedef empl on o.ownerid = empl.employeeid where o.isdelete = 0 and $sqlcondition ');

        set target_sql7 = concat('sum(cast(if(months in(',currentYToM,') and years = DATE_FORMAT(\'',currentYStart,'\',\'%Y\')
                          ,if(',currencyid,'=1,targetmoney,targetmoneyminor)/',statisticunit,',0)  as decimal(14,2)))');

        set actual_sql7 = concat('$eid eid, ifnull(sum(cast(if(DATE_FORMAT(fic.createdatetime,\'%Y-%m-%d\') between \'',currentYStart,
                          '\' and \'',currentYEnd,'\',if(',currencyid,'=1,ordermoney,ordermoneyminor)/',statisticunit,',0)  as decimal(14,2))),0)  value , 7 stype from financialdata fic
                          left join managedef empl on fic.employeeid = empl.employeeid where $sqlcondition');

        set target_sql8 = concat('sum(cast(if(months in(',currentYToM,') and years = DATE_FORMAT(\'',currentYStart,'\',\'%Y\')
                          ,if(',currencyid,'=1,targetmoney,targetmoneyminor)/',statisticunit,',0)  as decimal(14,2)))');

        set actual_sql8 = concat('$eid eid, ifnull(sum(cast(if(DATE_FORMAT(fic.createdatetime,\'%Y-%m-%d\') between \'',currentYStart,
                          '\' and \'',currentYEnd,'\',if(',currencyid,'=1,shipmentsmoney,shipmentsmoneyminor)/',statisticunit,',0)  as decimal(14,2))),0)  value , 8 stype from financialdata fic
                          left join managedef empl on fic.employeeid = empl.employeeid where $sqlcondition');


        set target_sql9 = concat('cast(sum(if(months in(',currentYToM,') and years = DATE_FORMAT(\'',currentYStart,'\',\'%Y\')
                          ,grossmarginratio,0))/',currentYToMnum,' as decimal(14,2))');

        set actual_sql9 = concat('$eid eid, ifnull(cast(sum(if(DATE_FORMAT(fic.createdatetime,\'%Y-%m-%d\') between \'',currentYStart,
                          '\' and \'',currentYEnd,'\',grossmarginratio,0))/',currentYToMnum,'/$emplNum as decimal(14,2)),0)  value , 9 stype from financialdata fic
                          left join managedef empl on fic.employeeid = empl.employeeid where $sqlcondition');


        set target_sql10 = concat('cast(sum(if(months in(',currentYToM,') and years = DATE_FORMAT(\'',currentYStart,'\',\'%Y\')
                          ,returnedmoneyperiod,0))/',currentYToMnum,' as decimal(14,2))');

        set actual_sql10 = concat('$eid eid, ifnull(cast(sum(if(DATE_FORMAT(fic.createdatetime,\'%Y-%m-%d\') between \'',currentYStart,
                          '\' and \'',currentYEnd,'\',returnedmoneyperiod,0))/',currentYToMnum,'/$emplNum as decimal(14,2)),0)  value , 10 stype from financialdata fic
                          left join managedef empl on fic.employeeid = empl.employeeid where $sqlcondition');


        set target_sql11 = concat('sum(cast(if(months in(',currentYToM,') and years = DATE_FORMAT(\'',currentYStart,'\',\'%Y\')
                          ,if(',currencyid,'=1,expensedisburse,expensedisburseminor)/',statisticunit,'/',currentYToMnum,',0)  as decimal(14,2)))');

        set actual_sql11 = concat('$eid eid, ifnull(sum(cast(if(DATE_FORMAT(fic.createdatetime,\'%Y-%m-%d\') between \'',currentYStart,
                          '\' and \'',currentYEnd,'\',if(',currencyid,'=1,expensedisburse,expensedisburseminor)/',statisticunit,'/',currentYToMnum,'/$emplNum,0)  as decimal(14,2))),0)  value , 11 stype from financialdata fic
                          left join managedef empl on fic.employeeid = empl.employeeid where $sqlcondition');

        /* 返回数据sql*/
        set sqlstring = concat(sqlstring, ' 
            select 
                $id col1,$name col2,$en_name col3,
                    cast(sum(
                        ifnull(if(target.value > 1,1,target.value)*if(target.stype = 1,empt.weightpredictedmoney,0),0) + 
                        ifnull(if(target.value > 1,1,target.value)*if(target.stype = 2,empt.weightorderreceiverate,0),0) + 
                        ifnull(if(target.value > 1,1,target.value)*if(target.stype = 3,empt.weightnewcustomernum,0),0) + 
                        ifnull(if(target.value > 1,1,target.value)*if(target.stype = 4,empt.weightcustomervisit,0),0) + 
                        ifnull(if(target.value > 1,1,target.value)*if(target.stype = 5,empt.weightnewoptnum,0),0) + 
                        ifnull(if(target.value > 1,1,target.value)*if(target.stype = 6,empt.weightnewoptmoney,0),0)
                        ) as decimal(14,0)) col4,
                        
                    cast(sum(
                        ifnull(if(target.value > 1,1,target.value)*if(target.stype = 7,empt.weightorder,0),0) + 
                        ifnull(if(target.value > 1,1,target.value)*if(target.stype = 8,empt.weightshipments,0),0) + 
                        ifnull(if(target.value > 1,1,target.value)*if(target.stype = 9,empt.weightgrossmarginratio,0),0) + 
                        ifnull(if(target.value > 1,1,target.value)*if(target.stype = 10,empt.weightreturnedmoney,0),0) + 
                        ifnull(if(target.value > 1,1,target.value)*if(target.stype = 11,empt.weightexpensedisburse,0),0)
                        ) as decimal(14,0)) col5,
                    if(empt.weightorderreceiverate is null,0,1) col6 
        
            from $table    
            left join

            (select 
                $empt,
                cast(sum(if((months = substr(\'',currentToM,'\',5) and years = left(\'',currentToM,'\',4)) or 
                            (months = substr(\'',next1ToM,'\',5) and years = left(\'',next1ToM,'\',4)) or 
                            (months = substr(\'',next2ToM,'\',5) and years = left(\'',next2ToM,'\',4)),weightpredictedmoney,null))/3 as decimal(14,2))  weightpredictedmoney,
                cast(sum(if(empt.years = DATE_FORMAT(\'',currentYStart,'\',\'%Y\') and empt.months in(',currentYToM,'),weightorderreceiverate,null))/',currentYToMnum,'  as decimal(14,2)) weightorderreceiverate,
                cast(sum(if(empt.years = DATE_FORMAT(\'',currentYStart,'\',\'%Y\') and empt.months in(',currentYToM,'),weightnewcustomernum,null))/',currentYToMnum,'  as decimal(14,2))  weightnewcustomernum,
                cast(sum(if(empt.years = DATE_FORMAT(\'',currentYStart,'\',\'%Y\') and empt.months in(',currentYToM,'),weightcustomervisit,null))/',currentYToMnum,'  as decimal(14,2)) weightcustomervisit,
                cast(sum(if(empt.years = DATE_FORMAT(\'',currentYStart,'\',\'%Y\') and empt.months in(',currentYToM,'),weightnewoptnum,null))/',currentYToMnum,'  as decimal(14,2))  weightnewoptnum,
                cast(sum(if(empt.years = DATE_FORMAT(\'',currentYStart,'\',\'%Y\') and empt.months in(',currentYToM,'),weightnewoptmoney,null))/',currentYToMnum,'  as decimal(14,2)) weightnewoptmoney,
                cast(sum(if(empt.years = DATE_FORMAT(\'',currentYStart,'\',\'%Y\') and empt.months in(',currentYToM,'),weightorder,null))/',currentYToMnum,'  as decimal(14,2))  weightorder,
                cast(sum(if(empt.years = DATE_FORMAT(\'',currentYStart,'\',\'%Y\') and empt.months in(',currentYToM,'),weightshipments,null))/',currentYToMnum,'  as decimal(14,2)) weightshipments,
                cast(sum(if(empt.years = DATE_FORMAT(\'',currentYStart,'\',\'%Y\') and empt.months in(',currentYToM,'),weightgrossmarginratio,null))/',currentYToMnum,'  as decimal(14,2)) weightgrossmarginratio,
                cast(sum(if(empt.years = DATE_FORMAT(\'',currentYStart,'\',\'%Y\') and empt.months in(',currentYToM,'),weightreturnedmoney,null))/',currentYToMnum,'  as decimal(14,2)) weightreturnedmoney,
                cast(sum(if(empt.years = DATE_FORMAT(\'',currentYStart,'\',\'%Y\') and empt.months in(',currentYToM,'),weightexpensedisburse,null))/',currentYToMnum,'  as decimal(14,2)) weightexpensedisburse
            from emptarget empt where empt.employeeid $isnull group by $empt ) empt on $id = $empt
            left join 
            
            (select 
                target.eid eid, cast(if(target.value = 0,0,actual.value/target.value) as decimal(14,2)) value, target.stype stype
            from chart_manage_salesranking_target_table target
            left join chart_manage_salesranking_actual_table actual
            on actual.eid = target.eid and actual.stype = target.stype) target on $id = target.eid
            where $sqlcondition');      

        if(currentYToM is not null and currentYStart is not null) then
               /* 看员工  */
            if stattype = 'e' then

                /*统计目标--员工、部门条件*/
                if (employeeIds is not null and departIds is not null) then

                    set targetsqlcondition = concat(targetsqlcondition,' (empt.employeeid in (',employeeIds,') or (empt.depid in (',departIds,') and empt.employeeid is not null)) group by empt.employeeid');
                else
                    if employeeIds is not null then
                        set targetsqlcondition = concat(targetsqlcondition, ' empt.employeeid in (',employeeIds,') group by empt.employeeid');
                    elseif departIds is not null then
                        set targetsqlcondition = concat(targetsqlcondition, ' empt.depid  in (',departIds,') and empt.employeeid is not null  group by empt.employeeid');
                    end if;
                end if;

                /*统计实际--员工、部门条件*/
                if (employeeIds is not null and departIds is not null) then

                    set actualsqlcondition = concat(actualsqlcondition,' (empl.employeeid in (',employeeIds,') or empl.depid in (',departIds,')) and empl.type= 2  group by empl.employeeid');
                else
                    if employeeIds is not null then
                        set actualsqlcondition = concat(actualsqlcondition, ' empl.employeeid in (',employeeIds,') and empl.type= 2 group by empl.employeeid');
                    elseif departIds is not null then
                        set actualsqlcondition = concat(actualsqlcondition, ' empl.depid  in (',departIds,') and empl.type= 2 group by empl.employeeid');
                    end if;
                end if;


                /* -- 每项统计 start -- */

                 /* -- 目标 项目预测金额 -- */
                set temptargetsqlstr = target_sql1;
                set temptargetsqlstr = replace(temptargetsqlstr,'$eid','empt.employeeid');
                set temptargetsqlstr = replace(temptargetsqlstr,'$sqlcondition',targetsqlcondition);
                set @stmt = temptargetsqlstr; 
                PREPARE stmt FROM @stmt;
                EXECUTE stmt;        
                DEALLOCATE PREPARE stmt;

                 /* -- 实际 项目预测金额 -- */
                set tempactualsqlstr = replace(actualsqlstr,'$select',actual_sql1);
                set tempactualsqlstr = replace(tempactualsqlstr,'$eid','o.ownerid');
                set tempactualsqlstr = replace(tempactualsqlstr,'$emplNum',1);
                set tempactualsqlstr = replace(tempactualsqlstr,'$oncondition', ' a.employeeid=o.ownerid ');
                set tempactualsqlstr = replace(tempactualsqlstr,'$sqlcondition',actualsqlcondition);
                set @stmt = tempactualsqlstr; 
                insert into debug(debug) values(tempactualsqlstr);
                PREPARE stmt FROM @stmt;
                EXECUTE stmt;        
                DEALLOCATE PREPARE stmt;

                /* -- 目标 接单率 -- */
                set temptargetsqlstr = replace(targetsqlstr,'$eid','empt.employeeid');
                set temptargetsqlstr = replace(temptargetsqlstr,'$scol',target_sql2);
                set temptargetsqlstr = replace(temptargetsqlstr,'$stype',2);
                set temptargetsqlstr = replace(temptargetsqlstr,'$sqlcondition',targetsqlcondition);
                set @stmt = temptargetsqlstr; 
                PREPARE stmt FROM @stmt;
                EXECUTE stmt;        
                DEALLOCATE PREPARE stmt;

                 /* -- 实际 接单率 -- */
                set tempactualsqlstr = replace(actualsqlstr,'$select',actual_sql2);
                set tempactualsqlstr = replace(tempactualsqlstr,'$eid','a.employeeid');
                set tempactualsqlstr = replace(tempactualsqlstr,'$emplNum',1);
                set tempactualsqlstr = replace(tempactualsqlstr,'$sqlcondition',actualsqlcondition);
                set @stmt = tempactualsqlstr;
                PREPARE stmt FROM @stmt;
                EXECUTE stmt;        
                DEALLOCATE PREPARE stmt;

                /* -- 目标 新增客户 -- */
                set temptargetsqlstr = replace(targetsqlstr,'$eid','empt.employeeid');
                set temptargetsqlstr = replace(temptargetsqlstr,'$scol',target_sql3);
                set temptargetsqlstr = replace(temptargetsqlstr,'$stype',3);
                set temptargetsqlstr = replace(temptargetsqlstr,'$sqlcondition',targetsqlcondition);
                set @stmt = temptargetsqlstr; 
                PREPARE stmt FROM @stmt;
                EXECUTE stmt;        
                DEALLOCATE PREPARE stmt;

                /* -- 实际 新增客户 -- */
                set tempactualsqlstr = replace(actualsqlstr,'$select',actual_sql3);
                set tempactualsqlstr = replace(tempactualsqlstr,'$eid','cust.ownerid');
                set tempactualsqlstr = replace(tempactualsqlstr,'$emplNum',1);
                set tempactualsqlstr = replace(tempactualsqlstr,'$sqlcondition',actualsqlcondition);
                set @stmt = tempactualsqlstr; 
                PREPARE stmt FROM @stmt;
                EXECUTE stmt;        
                DEALLOCATE PREPARE stmt;

                 /* -- 目标 客户拜访 -- */
                set temptargetsqlstr = replace(targetsqlstr,'$eid','empt.employeeid');
                set temptargetsqlstr = replace(temptargetsqlstr,'$scol',target_sql4);
                set temptargetsqlstr = replace(temptargetsqlstr,'$stype',4);
                set temptargetsqlstr = replace(temptargetsqlstr,'$sqlcondition',targetsqlcondition);
                set @stmt = temptargetsqlstr; 
                PREPARE stmt FROM @stmt;
                EXECUTE stmt;        
                DEALLOCATE PREPARE stmt;

                /* -- 实际 客户拜访 -- */
                set tempactualsqlstr = replace(actualsqlstr,'$select',actual_sql4);
                set tempactualsqlstr = replace(tempactualsqlstr,'$eid','we.createrid');
                set tempactualsqlstr = replace(tempactualsqlstr,'$emplNum',1);
                set tempactualsqlstr = replace(tempactualsqlstr,'$sqlcondition',actualsqlcondition);
                   insert into debug(debug) values(tempactualsqlstr);
                set @stmt = tempactualsqlstr; 
                PREPARE stmt FROM @stmt;
                EXECUTE stmt;        
                DEALLOCATE PREPARE stmt;

                /* -- 目标 新增机会数量 -- */
                set temptargetsqlstr = replace(targetsqlstr,'$eid','empt.employeeid');
                set temptargetsqlstr = replace(temptargetsqlstr,'$scol',target_sql5);
                set temptargetsqlstr = replace(temptargetsqlstr,'$stype',5);
                set temptargetsqlstr = replace(temptargetsqlstr,'$sqlcondition',targetsqlcondition);
                  insert into debug(debug) values(sqlstring);
                set @stmt = temptargetsqlstr; 
                PREPARE stmt FROM @stmt;
                EXECUTE stmt;        
                DEALLOCATE PREPARE stmt;

                /* -- 实际 新增机会数量 -- */
                set tempactualsqlstr = replace(actualsqlstr,'$select',actual_sql5);
                set tempactualsqlstr = replace(tempactualsqlstr,'$eid','o.ownerid');
                set tempactualsqlstr = replace(tempactualsqlstr,'$emplNum',1);
                set tempactualsqlstr = replace(tempactualsqlstr,'$sqlcondition',actualsqlcondition);
                set @stmt = tempactualsqlstr; 
                PREPARE stmt FROM @stmt;
                EXECUTE stmt;        
                DEALLOCATE PREPARE stmt;

                 /* -- 目标 新增机会金额 -- */
                set temptargetsqlstr = replace(targetsqlstr,'$eid','empt.employeeid');
                set temptargetsqlstr = replace(temptargetsqlstr,'$scol',target_sql6);
                set temptargetsqlstr = replace(temptargetsqlstr,'$stype',6);
                set temptargetsqlstr = replace(temptargetsqlstr,'$sqlcondition',targetsqlcondition);
                set @stmt = temptargetsqlstr; 
                PREPARE stmt FROM @stmt;
                EXECUTE stmt;        
                DEALLOCATE PREPARE stmt;

                /* -- 实际 新增机会金额 -- */
                set tempactualsqlstr = replace(actualsqlstr,'$select',actual_sql6);
                set tempactualsqlstr = replace(tempactualsqlstr,'$eid','o.ownerid');
                set tempactualsqlstr = replace(tempactualsqlstr,'$emplNum',1);
                set tempactualsqlstr = replace(tempactualsqlstr,'$sqlcondition',actualsqlcondition);
                set @stmt = tempactualsqlstr; 
                PREPARE stmt FROM @stmt;
                EXECUTE stmt;        
                DEALLOCATE PREPARE stmt;

                /* -- 目标 订单金额 -- */
                set temptargetsqlstr = replace(targetsqlstr,'$eid','empt.employeeid');
                set temptargetsqlstr = replace(temptargetsqlstr,'$scol',target_sql7);
                set temptargetsqlstr = replace(temptargetsqlstr,'$stype',7);
                set temptargetsqlstr = replace(temptargetsqlstr,'$sqlcondition',targetsqlcondition);
                  insert into debug(debug) values(sqlstring);
                set @stmt = temptargetsqlstr; 
                PREPARE stmt FROM @stmt;
                EXECUTE stmt;        
                DEALLOCATE PREPARE stmt;

                /* -- 实际 订单金额 -- */
                set tempactualsqlstr = replace(actualsqlstr,'$select',actual_sql7);
                set tempactualsqlstr = replace(tempactualsqlstr,'$eid','fic.employeeid');
                set tempactualsqlstr = replace(tempactualsqlstr,'$emplNum',1);
                set tempactualsqlstr = replace(tempactualsqlstr,'$sqlcondition',actualsqlcondition);
                set @stmt = tempactualsqlstr; 
                PREPARE stmt FROM @stmt;
                EXECUTE stmt;        
                DEALLOCATE PREPARE stmt;

                 /* -- 目标 发货金额 -- */
                set temptargetsqlstr = replace(targetsqlstr,'$eid','empt.employeeid');
                set temptargetsqlstr = replace(temptargetsqlstr,'$scol',target_sql8);
                set temptargetsqlstr = replace(temptargetsqlstr,'$stype',8);
                set temptargetsqlstr = replace(temptargetsqlstr,'$sqlcondition',targetsqlcondition);
                set @stmt = temptargetsqlstr; 
                PREPARE stmt FROM @stmt;
                EXECUTE stmt;        
                DEALLOCATE PREPARE stmt;

                /* -- 实际 发货金额 -- */
                set tempactualsqlstr = replace(actualsqlstr,'$select',actual_sql8);
                set tempactualsqlstr = replace(tempactualsqlstr,'$eid','fic.employeeid');
                set tempactualsqlstr = replace(tempactualsqlstr,'$emplNum',1);
                set tempactualsqlstr = replace(tempactualsqlstr,'$sqlcondition',actualsqlcondition);
                set @stmt = tempactualsqlstr; 
                PREPARE stmt FROM @stmt;
                EXECUTE stmt;        
                DEALLOCATE PREPARE stmt;

                 /* -- 目标 毛利率 -- */
                set temptargetsqlstr = replace(targetsqlstr,'$eid','empt.employeeid');
                set temptargetsqlstr = replace(temptargetsqlstr,'$scol',target_sql9);
                set temptargetsqlstr = replace(temptargetsqlstr,'$stype',9);
                set temptargetsqlstr = replace(temptargetsqlstr,'$sqlcondition',targetsqlcondition);
                set @stmt = temptargetsqlstr; 
                PREPARE stmt FROM @stmt;
                EXECUTE stmt;        
                DEALLOCATE PREPARE stmt;

                /* -- 实际 毛利率 -- */
                set tempactualsqlstr = replace(actualsqlstr,'$select',actual_sql9);
                set tempactualsqlstr = replace(tempactualsqlstr,'$eid','fic.employeeid');
                set tempactualsqlstr = replace(tempactualsqlstr,'$emplNum',1);
                set tempactualsqlstr = replace(tempactualsqlstr,'$sqlcondition',actualsqlcondition);
                set @stmt = tempactualsqlstr; 
                PREPARE stmt FROM @stmt;
                EXECUTE stmt;        
                DEALLOCATE PREPARE stmt;


                 /* -- 目标 回款周期 -- */
                set temptargetsqlstr = replace(targetsqlstr,'$eid','empt.employeeid');
                set temptargetsqlstr = replace(temptargetsqlstr,'$scol',target_sql10);
                set temptargetsqlstr = replace(temptargetsqlstr,'$stype',10);
                set temptargetsqlstr = replace(temptargetsqlstr,'$sqlcondition',targetsqlcondition);
                set @stmt = temptargetsqlstr; 
                PREPARE stmt FROM @stmt;
                EXECUTE stmt;        
                DEALLOCATE PREPARE stmt;

                /* -- 实际 回款周期 -- */
                set tempactualsqlstr = replace(actualsqlstr,'$select',actual_sql10);
                set tempactualsqlstr = replace(tempactualsqlstr,'$eid','fic.employeeid');
                set tempactualsqlstr = replace(tempactualsqlstr,'$emplNum',1);
                set tempactualsqlstr = replace(tempactualsqlstr,'$sqlcondition',actualsqlcondition);
                set @stmt = tempactualsqlstr; 
                PREPARE stmt FROM @stmt;
                EXECUTE stmt;        
                DEALLOCATE PREPARE stmt;


                 /* -- 目标 费用支出 -- */
                set temptargetsqlstr = replace(targetsqlstr,'$eid','empt.employeeid');
                set temptargetsqlstr = replace(temptargetsqlstr,'$scol',target_sql11);
                set temptargetsqlstr = replace(temptargetsqlstr,'$stype',11);
                set temptargetsqlstr = replace(temptargetsqlstr,'$sqlcondition',targetsqlcondition);
                set @stmt = temptargetsqlstr; 
                PREPARE stmt FROM @stmt;
                EXECUTE stmt;        
                DEALLOCATE PREPARE stmt;

                /* -- 实际 费用支出 -- */
                set tempactualsqlstr = replace(actualsqlstr,'$select',actual_sql11);
                set tempactualsqlstr = replace(tempactualsqlstr,'$eid','fic.employeeid');
                set tempactualsqlstr = replace(tempactualsqlstr,'$emplNum',1);
                set tempactualsqlstr = replace(tempactualsqlstr,'$sqlcondition',actualsqlcondition);
                set @stmt = tempactualsqlstr; 
                PREPARE stmt FROM @stmt;
                EXECUTE stmt;        
                DEALLOCATE PREPARE stmt;



                /* -- 每项统计 end -- */

                /*替换返回结果的sql*/
                set sqlstring = replace(sqlstring,'$id','empl.employeeid');
                set sqlstring = replace(sqlstring,'$name','emp.fullname');
                set sqlstring = replace(sqlstring,'$en_name','emp.fullname');
                set sqlstring = replace(sqlstring,'$table','managedef empl left join employee emp on emp.id = empl.employeeid ');
                set sqlstring = replace(sqlstring,'$empt','empt.employeeid');
                set sqlstring = replace(sqlstring,'$isnull','is not null');
                set sqlstring = replace(sqlstring,'$sqlcondition',actualsqlcondition);
                set @stmt = sqlstring; 
                insert into debug(debug) values(sqlstring);
                -- select * from chart_manage_salesranking_actual_table;
                PREPARE stmt FROM @stmt;
                EXECUTE stmt;        
                DEALLOCATE PREPARE stmt;


            /* 看部门  */
            else

                if departIds is not null then
            
                    /*统计目标--部门条件*/
                    set targetsqlcondition = concat(targetsqlcondition, ' empt.depid in (',departIds,') and empt.employeeid is null  group by empt.depid ');   

                    set sqlcondition = concat(sqlcondition, ' empd.id in (',departIds,')  group by empd.id ');

                    /* -- 每项统计 start -- */

                     /* -- 目标 项目预测金额 -- */
                    set temptargetsqlstr = target_sql1;
                    set temptargetsqlstr = replace(temptargetsqlstr,'$eid','empt.depid');
                    set temptargetsqlstr = replace(temptargetsqlstr,'$sqlcondition',targetsqlcondition);
                    set @stmt = temptargetsqlstr; 
                    PREPARE stmt FROM @stmt;
                    EXECUTE stmt;        
                    DEALLOCATE PREPARE stmt;

                    /* -- 目标 接单率 -- */
                    set temptargetsqlstr = replace(targetsqlstr,'$eid','empt.depid');
                    set temptargetsqlstr = replace(temptargetsqlstr,'$scol',target_sql2);
                    set temptargetsqlstr = replace(temptargetsqlstr,'$stype',2);
                    set temptargetsqlstr = replace(temptargetsqlstr,'$sqlcondition',targetsqlcondition);
                    set @stmt = temptargetsqlstr; 
                    PREPARE stmt FROM @stmt;
                    EXECUTE stmt;        
                    DEALLOCATE PREPARE stmt;

                    /* -- 目标 新增客户 --*/
                    set temptargetsqlstr = replace(targetsqlstr,'$eid','empt.depid');
                    set temptargetsqlstr = replace(temptargetsqlstr,'$scol',target_sql3);
                    set temptargetsqlstr = replace(temptargetsqlstr,'$stype',3);
                    set temptargetsqlstr = replace(temptargetsqlstr,'$sqlcondition',targetsqlcondition);
                    set @stmt = temptargetsqlstr; 
                    PREPARE stmt FROM @stmt;
                    EXECUTE stmt;        
                    DEALLOCATE PREPARE stmt;
                   
                    /* -- 目标 客户拜访 --*/
                    set temptargetsqlstr = replace(targetsqlstr,'$eid','empt.depid');
                    set temptargetsqlstr = replace(temptargetsqlstr,'$scol',target_sql4);
                    set temptargetsqlstr = replace(temptargetsqlstr,'$stype',4);
                    set temptargetsqlstr = replace(temptargetsqlstr,'$sqlcondition',targetsqlcondition);
                    set @stmt = temptargetsqlstr; 
                    PREPARE stmt FROM @stmt;
                    EXECUTE stmt;        
                    DEALLOCATE PREPARE stmt;

                    /* -- 目标 新增机会数量 --*/
                    set temptargetsqlstr = replace(targetsqlstr,'$eid','empt.depid');
                    set temptargetsqlstr = replace(temptargetsqlstr,'$scol',target_sql5);
                    set temptargetsqlstr = replace(temptargetsqlstr,'$stype',5);
                    set temptargetsqlstr = replace(temptargetsqlstr,'$sqlcondition',targetsqlcondition);
                    set @stmt = temptargetsqlstr; 
                    PREPARE stmt FROM @stmt;
                    EXECUTE stmt;        
                    DEALLOCATE PREPARE stmt;

                    /* -- 目标 新增机会金额 --*/
                    set temptargetsqlstr = replace(targetsqlstr,'$eid','empt.depid');
                    set temptargetsqlstr = replace(temptargetsqlstr,'$scol',target_sql6);
                    set temptargetsqlstr = replace(temptargetsqlstr,'$stype',6);
                    set temptargetsqlstr = replace(temptargetsqlstr,'$sqlcondition',targetsqlcondition);
                    set @stmt = temptargetsqlstr; 
                    PREPARE stmt FROM @stmt;
                    EXECUTE stmt;        
                    DEALLOCATE PREPARE stmt;


                    /* -- 目标 订单金额 --*/
                    set temptargetsqlstr = replace(targetsqlstr,'$eid','empt.depid');
                    set temptargetsqlstr = replace(temptargetsqlstr,'$scol',target_sql7);
                    set temptargetsqlstr = replace(temptargetsqlstr,'$stype',7);
                    set temptargetsqlstr = replace(temptargetsqlstr,'$sqlcondition',targetsqlcondition);
                    set @stmt = temptargetsqlstr; 
                    PREPARE stmt FROM @stmt;
                    EXECUTE stmt;        
                    DEALLOCATE PREPARE stmt;
                   
                    /* -- 目标 发货金额 --*/
                    set temptargetsqlstr = replace(targetsqlstr,'$eid','empt.depid');
                    set temptargetsqlstr = replace(temptargetsqlstr,'$scol',target_sql8);
                    set temptargetsqlstr = replace(temptargetsqlstr,'$stype',8);
                    set temptargetsqlstr = replace(temptargetsqlstr,'$sqlcondition',targetsqlcondition);
                    set @stmt = temptargetsqlstr; 
                    PREPARE stmt FROM @stmt;
                    EXECUTE stmt;        
                    DEALLOCATE PREPARE stmt;

                    /* -- 目标 毛利率 --*/
                    set temptargetsqlstr = replace(targetsqlstr,'$eid','empt.depid');
                    set temptargetsqlstr = replace(temptargetsqlstr,'$scol',target_sql9);
                    set temptargetsqlstr = replace(temptargetsqlstr,'$stype',9);
                    set temptargetsqlstr = replace(temptargetsqlstr,'$sqlcondition',targetsqlcondition);
                    set @stmt = temptargetsqlstr; 
                    PREPARE stmt FROM @stmt;
                    EXECUTE stmt;        
                    DEALLOCATE PREPARE stmt;

                    /* -- 目标 回款周期 --*/
                    set temptargetsqlstr = replace(targetsqlstr,'$eid','empt.depid');
                    set temptargetsqlstr = replace(temptargetsqlstr,'$scol',target_sql10);
                    set temptargetsqlstr = replace(temptargetsqlstr,'$stype',10);
                    set temptargetsqlstr = replace(temptargetsqlstr,'$sqlcondition',targetsqlcondition);
                    set @stmt = temptargetsqlstr; 
                    PREPARE stmt FROM @stmt;
                    EXECUTE stmt;        
                    DEALLOCATE PREPARE stmt;

                    /* -- 目标 费用支出 --*/
                    set temptargetsqlstr = replace(targetsqlstr,'$eid','empt.depid');
                    set temptargetsqlstr = replace(temptargetsqlstr,'$scol',target_sql11);
                    set temptargetsqlstr = replace(temptargetsqlstr,'$stype',11);
                    set temptargetsqlstr = replace(temptargetsqlstr,'$sqlcondition',targetsqlcondition);
                    set @stmt = temptargetsqlstr; 
                    PREPARE stmt FROM @stmt;
                    EXECUTE stmt;        
                    DEALLOCATE PREPARE stmt;

                    select CHAR_LENGTH(departIds) - CHAR_LENGTH(replace(departIds,',','')) + 1 into departIdNum; -- 获取部门数量

                    /* 根据部门的数量循环统计*/
                    while i <= departIdNum do

                        select SUBSTRING_INDEX(SUBSTRING_INDEX(departIds,',',departIdNum - i + 1),',',-1) into @depid;

                        /*统计实际--部门条件*/
                        set actualsqlcondition = concat('', ' find_in_set (empl.depid,getAllDeparts(',@depid,'))');
                  
                        select count(id) into emplNum from managedef empl where find_in_set(empl.depid,getAllDeparts(@depid)) and empl.type= 2; -- 获取员工的数量
                         /* -- 实际 项目预测金额 -- */
                        set tempactualsqlstr = replace(actualsqlstr,'$select',actual_sql1);
                        set tempactualsqlstr = replace(tempactualsqlstr,'$eid',@depid);
                        set tempactualsqlstr = replace(tempactualsqlstr,'$emplNum',emplNum);
                        set tempactualsqlstr = replace(tempactualsqlstr,'$sqlcondition',actualsqlcondition);
                        set tempactualsqlstr = replace(tempactualsqlstr,'$oncondition', ' 1=1 ');
                        set tempactualsqlstr = replace(tempactualsqlstr,'group by empl.employeeid','');
                        set @stmt = tempactualsqlstr; 
                        PREPARE stmt FROM @stmt;
                        EXECUTE stmt;        
                        DEALLOCATE PREPARE stmt;

                        /* -- 实际 接单率 -- */
                        set tempactualsqlstr = replace(actualsqlstr,'$select',actual_sql2);
                        set tempactualsqlstr = replace(tempactualsqlstr,'$eid',@depid);
                        set tempactualsqlstr = replace(tempactualsqlstr,'$emplNum',emplNum);
                        set tempactualsqlstr = replace(tempactualsqlstr,'$sqlcondition',actualsqlcondition);
                        set tempactualsqlstr = replace(tempactualsqlstr,'group by empl.employeeid','');
                        set @stmt = tempactualsqlstr; 
                        PREPARE stmt FROM @stmt;
                        EXECUTE stmt;        
                        DEALLOCATE PREPARE stmt;

                         /* -- 实际 新增客户  */
                        set tempactualsqlstr = replace(actualsqlstr,'$select',actual_sql3);
                        set tempactualsqlstr = replace(tempactualsqlstr,'$eid',@depid);
                        set tempactualsqlstr = replace(tempactualsqlstr,'$emplNum',emplNum);
                        set tempactualsqlstr = replace(tempactualsqlstr,'$sqlcondition',actualsqlcondition);
                         insert into debug(debug) values( tempactualsqlstr);
                        set @stmt = tempactualsqlstr; 
                        PREPARE stmt FROM @stmt;
                        EXECUTE stmt;        
                        DEALLOCATE PREPARE stmt;

                        /* -- 实际 客户拜访  */
                        set tempactualsqlstr = replace(actualsqlstr,'$select',actual_sql4);
                        set tempactualsqlstr = replace(tempactualsqlstr,'$eid',@depid);
                        set tempactualsqlstr = replace(tempactualsqlstr,'$emplNum',emplNum);
                        set tempactualsqlstr = replace(tempactualsqlstr,'$sqlcondition',actualsqlcondition);
                        set @stmt = tempactualsqlstr; 
                        PREPARE stmt FROM @stmt;
                        EXECUTE stmt;        
                        DEALLOCATE PREPARE stmt;

                        /* -- 实际 新增机会数量  */
                        set tempactualsqlstr = replace(actualsqlstr,'$select',actual_sql5);
                        set tempactualsqlstr = replace(tempactualsqlstr,'$eid',@depid);
                        set tempactualsqlstr = replace(tempactualsqlstr,'$emplNum',emplNum);
                        set tempactualsqlstr = replace(tempactualsqlstr,'$sqlcondition',actualsqlcondition);
                        set @stmt = tempactualsqlstr; 
                        PREPARE stmt FROM @stmt;
                        EXECUTE stmt;        
                        DEALLOCATE PREPARE stmt;

                        /* -- 实际 新增机会金额  */
                        set tempactualsqlstr = replace(actualsqlstr,'$select',actual_sql6);
                        set tempactualsqlstr = replace(tempactualsqlstr,'$eid',@depid);
                        set tempactualsqlstr = replace(tempactualsqlstr,'$emplNum',emplNum);
                        set tempactualsqlstr = replace(tempactualsqlstr,'$sqlcondition',actualsqlcondition);
                        set @stmt = tempactualsqlstr; 
                        PREPARE stmt FROM @stmt;
                        EXECUTE stmt;        
                        DEALLOCATE PREPARE stmt;

                        /* -- 实际 订单金额  */
                        set tempactualsqlstr = replace(actualsqlstr,'$select',actual_sql7);
                        set tempactualsqlstr = replace(tempactualsqlstr,'$eid',@depid);
                        set tempactualsqlstr = replace(tempactualsqlstr,'$emplNum',emplNum);
                        set tempactualsqlstr = replace(tempactualsqlstr,'$sqlcondition',actualsqlcondition);
                         insert into debug(debug) values( tempactualsqlstr);
                        set @stmt = tempactualsqlstr; 
                        PREPARE stmt FROM @stmt;
                        EXECUTE stmt;        
                        DEALLOCATE PREPARE stmt;

                        /* -- 实际 发货金额  */
                        set tempactualsqlstr = replace(actualsqlstr,'$select',actual_sql8);
                        set tempactualsqlstr = replace(tempactualsqlstr,'$eid',@depid);
                        set tempactualsqlstr = replace(tempactualsqlstr,'$emplNum',emplNum);
                        set tempactualsqlstr = replace(tempactualsqlstr,'$sqlcondition',actualsqlcondition);
                        set @stmt = tempactualsqlstr; 
                        PREPARE stmt FROM @stmt;
                        EXECUTE stmt;        
                        DEALLOCATE PREPARE stmt;

                        /* -- 实际 毛利率  */
                        set tempactualsqlstr = replace(actualsqlstr,'$select',actual_sql9);
                        set tempactualsqlstr = replace(tempactualsqlstr,'$eid',@depid);
                        set tempactualsqlstr = replace(tempactualsqlstr,'$emplNum',emplNum);
                        set tempactualsqlstr = replace(tempactualsqlstr,'$sqlcondition',actualsqlcondition);
                        set @stmt = tempactualsqlstr; 
                        PREPARE stmt FROM @stmt;
                        EXECUTE stmt;        
                        DEALLOCATE PREPARE stmt;

                        /* -- 实际 回款周期  */
                        set tempactualsqlstr = replace(actualsqlstr,'$select',actual_sql10);
                        set tempactualsqlstr = replace(tempactualsqlstr,'$eid',@depid);
                        set tempactualsqlstr = replace(tempactualsqlstr,'$emplNum',emplNum);
                        set tempactualsqlstr = replace(tempactualsqlstr,'$sqlcondition',actualsqlcondition);
                        set @stmt = tempactualsqlstr; 
                        PREPARE stmt FROM @stmt;
                        EXECUTE stmt;        
                        DEALLOCATE PREPARE stmt;

                        /* -- 实际 费用支出  */
                        set tempactualsqlstr = replace(actualsqlstr,'$select',actual_sql11);
                        set tempactualsqlstr = replace(tempactualsqlstr,'$eid',@depid);
                        set tempactualsqlstr = replace(tempactualsqlstr,'$emplNum',emplNum);
                        set tempactualsqlstr = replace(tempactualsqlstr,'$sqlcondition',actualsqlcondition);
                        set @stmt = tempactualsqlstr; 
                        PREPARE stmt FROM @stmt;
                        EXECUTE stmt;        
                        DEALLOCATE PREPARE stmt;

                        set i = i + 1;
                    end while;

                    /* -- 每项统计 end -- */

                    /*替换返回结果的sql*/
                    set sqlstring = replace(sqlstring,'$id','empd.id');
                    set sqlstring = replace(sqlstring,'$name','empd.depart');
                    set sqlstring = replace(sqlstring,'$en_name','empd.departen');
                    set sqlstring = replace(sqlstring,'$table','empdepart empd');
                    set sqlstring = replace(sqlstring,'$empt','empt.depid');
                    set sqlstring = replace(sqlstring,'$isnull','is null');
                    set sqlstring = replace(sqlstring,'$sqlcondition',sqlcondition);
                    insert into debug(debug) values(sqlstring);
                    set @stmt = sqlstring; 
                    PREPARE stmt FROM @stmt;
                    EXECUTE stmt;        
                    DEALLOCATE PREPARE stmt;

                end if;

            end if;
        end if;

       
    end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `chart_optanalysis_industry_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
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
    set sqlheader = 'insert into tmp_chart_optanalysis_industry_table(classname,classnameen,classfield,classid,totalprice,percent) select IFNULL($classname$,\'Other\') as classname,IFNULL($classnameen$,\'Other\') as classnameen,
	 \'$classfield$\',IFNULL($classid$,0),IFNULL(round(sum(optsd.converttotalprice)/$statisticunit$,2),0) as totalprice ,IFNULL(round(sum(optsd.converttotalprice)/$totalvalue$,2),0) as percent from 
	 (select distinct(opt.id) as optid, ind.industry, ind.industryen,ind.id as indid, inds.industrysub,inds.industrysuben, inds.id as indsid, convertopt.converttotalprice ';
  
  	 drop table if exists `tmp_chart_optanalysis_industry_table`;
    
    create temporary table IF NOT EXISTS `tmp_chart_optanalysis_industry_table`
    (
        `id` int(10) NOT NULL AUTO_INCREMENT COMMENT 'ID',
        `classfield` varchar(20) NOT NULL COMMENT '类别字段名称',
        `classid` varchar(20) NOT NULL COMMENT '类别id',
        `classname` varchar(20) NOT NULL COMMENT '类别名称',
        `classnameen` varchar(20) NOT NULL COMMENT '类别名称 - 英文',
        `totalprice` DECIMAL(14,2) NOT NULL COMMENT '总金额',
        `percent` DECIMAL(14,2) NOT NULL COMMENT '占比',
        PRIMARY KEY (`id`)
    );
    truncate table `tmp_chart_optanalysis_industry_table`;

	
    if (employeesid is not null and CHAR_LENGTH(employeesid) = 0) then
		set employeesid = null;
    end if;
    if (departsid is not null and CHAR_LENGTH(departsid) = 0) then
		set departsid = null;
    end if;
    
    set tmpcount = 1;

    if CHAR_LENGTH(startdate) > 0 then
                
        set sqlstr = '$sqlheader$ ';
        set sqlstr = concat(sqlstr,'from customer as cus ');
        set sqlstr = concat(sqlstr,'left join opt on cus.id = opt.customerid ');        
        set sqlstr = concat(sqlstr,'left join employee emp on opt.ownerid = emp.id left join (select
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

        
        if classid = 0 then
        	set sqlstr = concat(sqlstr, ' and ind.isdelete = 0 ');  
			set sqlstringtotal = concat(sqlstr, ' ) as optsd');
			set sqlstring = concat(sqlstr, ' ) as optsd group by optsd.indid');
			set sqlheader = replace(sqlheader,'$classname$','optsd.industry');
			set sqlheader = replace(sqlheader,'$classnameen$','optsd.industryen');
            set sqlheader = replace(sqlheader,'$classfield$','industryid');
            set sqlheader = replace(sqlheader,'$classid$',' optsd.indid');
        
        elseif classid > 0 then
        	set sqlstr = concat(sqlstr, ' and (inds.isdelete is null or inds.isdelete = 0) ');  
			set sqlstringtotal = concat(sqlstr, ' and cus.industryid = ', classid, ' ) as optsd');
            set sqlstring = concat(sqlstr, ' and cus.industryid = ', classid, ' ) as optsd group by optsd.indsid');
			set sqlheader = replace(sqlheader, '$classname$','optsd.industrysub');
			set sqlheader = replace(sqlheader, '$classnameen$','optsd.industrysuben');
            set sqlheader = replace(sqlheader,'$classfield$','industrysubid');
            set sqlheader = replace(sqlheader,'$classid$',' optsd.indsid');
        end if;

        
        set sqlstringtotal = replace(sqlstringtotal,'$sqlheader$','select sum(optsd.converttotalprice) into @totalvalue from (select distinct(opt.id) as optid, convertopt.converttotalprice');
        set @stmt = sqlstringtotal; 
		PREPARE stmt FROM @stmt;
		EXECUTE stmt;
        set totalvalue = ifnull(@totalvalue,0);
       
        
		set sqlheader = replace(sqlheader, '$totalvalue$', totalvalue);
        
        set sqlstring = replace(sqlstring, '$sqlheader$', sqlheader);
        
        set sqlstring = replace(sqlstring,'$statisticunit$',statisticunits);
		set @stmt = sqlstring; 
		
		PREPARE stmt FROM @stmt;
		EXECUTE stmt;        
		DEALLOCATE PREPARE stmt;
        select * from tmp_chart_optanalysis_industry_table;
	end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `chart_optanalysis_product_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
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
    set sqlheader = 'insert into tmp_chart_optanalysis_product_table(classname,classnameen,classfield,classid,totalprice,percent) select IFNULL($classname$,\'Other\') as classname,IFNULL($classnameen$,\'Other\') as classnameen,
	 \'$classfield$\',IFNULL($classid$,0),IFNULL(round(sum(oppsd.converttotalprice*oppsd.num*oppsd.discount)/$statisticunit$,2),0) as totalprice ,
	 IFNULL(round(sum(oppsd.converttotalprice*oppsd.num*oppsd.discount)/$totalvalue$,2),0) as percent from 
	 (select distinct(opp.id) as optproid, prob.brandname,prob.brandnameen, prob.id as probid, proc.classname,proc.classnameen, proc.id as procid, num, discount, convertoptproduct.converttotalprice ';
    
	  drop table if exists `tmp_chart_optanalysis_product_table`;
	 
    create temporary table IF NOT EXISTS `tmp_chart_optanalysis_product_table`
    (
        `id` int(10) NOT NULL AUTO_INCREMENT COMMENT 'ID',
		  `classfield` varchar(20) NOT NULL COMMENT '类别字段名称',
        `classid` varchar(20) NOT NULL COMMENT '类别id',
        `classname` varchar(20) NOT NULL  COMMENT '类别名称',
        `classnameen` varchar(20) NOT NULL  COMMENT '类别名称- 英文',
        `totalprice` DECIMAL(14,2) NOT NULL COMMENT '总金额',
        `percent` DECIMAL(14,2) NOT NULL COMMENT '占比',
        PRIMARY KEY (`id`)
    );
    truncate table `tmp_chart_optanalysis_product_table`;

	
    if (employeesid is not null and CHAR_LENGTH(employeesid) = 0) then
		set employeesid = null;
    end if;
    if (departsid is not null and CHAR_LENGTH(departsid) = 0) then
		set departsid = null;
    end if;
    
    set tmpcount = 1;

    if CHAR_LENGTH(startdate) > 0 then
                
        set sqlstr = '$sqlheader$ ';
        set sqlstr = concat(sqlstr,'from optproduct as opp ');
        set sqlstr = concat(sqlstr,'left join opt on opp.optid = opt.id ');        
        set sqlstr = concat(sqlstr,'left join employee emp on opt.ownerid = emp.id left join (select
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

        
        if classid = 0 then
         set sqlstr = concat(sqlstr, ' and prob.isdelete = 0');     
			set sqlstringtotal = concat(sqlstr, ' ) as oppsd');
			set sqlstring = concat(sqlstr, ') as oppsd group by oppsd.probid');
			set sqlheader = replace(sqlheader,'$classname$','oppsd.brandname');
			set sqlheader = replace(sqlheader,'$classnameen$','oppsd.brandnameen');
            set sqlheader = replace(sqlheader,'$classfield$','brandid');
            set sqlheader = replace(sqlheader,'$classid$',' oppsd.probid');
        
        elseif classid > 0 then
        set sqlstr = concat(sqlstr, ' and proc.isdelete = 0');   
			set sqlstringtotal = concat(sqlstr, ' and pro.brandid = ', classid, ' ) as oppsd');
            set sqlstring = concat(sqlstr, ' and pro.brandid = ', classid, ') as oppsd group by oppsd.procid');
			set sqlheader = replace(sqlheader, '$classname$','oppsd.classname');
		   set sqlheader = replace(sqlheader, '$classnameen$','oppsd.classnameen');	
            set sqlheader = replace(sqlheader,'$classfield$','classid');
            set sqlheader = replace(sqlheader,'$classid$',' oppsd.procid');
        end if;

        
        set sqlstringtotal = replace(sqlstringtotal,'$sqlheader$','select sum(oppsd.converttotalprice*oppsd.num*oppsd.discount) into @totalvalue from (select distinct(opp.id) as optproid, opp.num, opp.discount, convertoptproduct.converttotalprice ');
        set @stmt = sqlstringtotal; 
		PREPARE stmt FROM @stmt;
		EXECUTE stmt;
        set totalvalue = ifnull(@totalvalue,0);
       
        
		set sqlheader = replace(sqlheader, '$totalvalue$', totalvalue);
        
        set sqlstring = replace(sqlstring, '$sqlheader$', sqlheader);
        
        set sqlstring = replace(sqlstring,'$statisticunit$',statisticunits);
		set @stmt = sqlstring; 
		
		PREPARE stmt FROM @stmt;
		EXECUTE stmt;        
		DEALLOCATE PREPARE stmt;
        select * from tmp_chart_optanalysis_product_table;
	end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `chart_optanalysis_region_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
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
    set sqlheader = 'insert into tmp_chart_optanalysis_region_table(classname,classnameen,classfield,classid,totalprice,percent) select IFNULL($classname$,\'Other\') as classname,IFNULL($classnameen$,\'Other\') as classnameen
	 ,\'$classfield$\',IFNULL($classid$,0),IFNULL(round(sum(optsd.converttotalprice)/$statisticunit$,2),0) as totalprice 
	 ,IFNULL(round(sum(optsd.converttotalprice)/$totalvalue$,2),0) as percent from 
	 (select distinct(opt.id) as optid, coun.country,coun.countryen, coun.id as counid, reg.region,reg.regionen, reg.id as regid, pro.province,pro.provinceen, pro.id as proid, city.city,city.cityen, city.id as cityid, convertopt.converttotalprice ';
     
	  drop table if exists `tmp_chart_optanalysis_region_table`;
	 
    create temporary table IF NOT EXISTS `tmp_chart_optanalysis_region_table`
    (
        `id` int(10) NOT NULL AUTO_INCREMENT COMMENT 'ID',
        `classfield` varchar(20) NOT NULL COMMENT '类别字段名称',
        `classid` varchar(20) NOT NULL COMMENT '类别id',
        `classname` varchar(20) NOT NULL COMMENT '类别名称',
        `classnameen` varchar(20) NOT NULL COMMENT '类别名称-英文',
        `totalprice` DECIMAL(14,2) NOT NULL COMMENT '总金额',
        `percent` DECIMAL(14,2) NOT NULL COMMENT '占比',
        PRIMARY KEY (`id`)
    );
    truncate table `tmp_chart_optanalysis_region_table`;

    
    if (employeesid is not null and CHAR_LENGTH(employeesid) = 0) then
        set employeesid = null;
    end if;
    if (departsid is not null and CHAR_LENGTH(departsid) = 0) then
        set departsid = null;
    end if;
    
    set tmpcount = 1;

    if CHAR_LENGTH(startdate) > 0 then
                
        set sqlstr = '$sqlheader$ ';
        set sqlstr = concat(sqlstr,'from customer as cus ');
        set sqlstr = concat(sqlstr,'left join opt on cus.id = opt.customerid ');        
        set sqlstr = concat(sqlstr,'left join employee emp on opt.ownerid = emp.id left join (select
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


        
        if classType = 'empty' then
        		set sqlstr = concat(sqlstr, ' and cus.isdelete = 0');
            set sqlstringtotal = concat(sqlstr, ' ) as optsd ');
            set sqlstring = concat(sqlstr, ' ) as optsd group by optsd.counid');
            set sqlheader = replace(sqlheader,'$classname$','optsd.country');
            set sqlheader = replace(sqlheader,'$classnameen$','optsd.countryen');
            set sqlheader = replace(sqlheader,'$classfield$','countryid');
            set sqlheader = replace(sqlheader,'$classid$','optsd.counid');
        
        elseif classType = 'country' then
        		set sqlstr = concat(sqlstr, ' and reg.isdelete = 0');
            set sqlstringtotal = concat(sqlstr, ' and cus.countryid = ', classid, ' ) as optsd');
            set sqlstring = concat(sqlstr, ' and cus.countryid = ', classid, ' ) as optsd group by optsd.regid');
            set sqlheader = replace(sqlheader, '$classname$','optsd.region');
            set sqlheader = replace(sqlheader, '$classnameen$','optsd.regionen');
            set sqlheader = replace(sqlheader, '$classfield$','regionid');
            set sqlheader = replace(sqlheader, '$classid$','optsd.regid');
        
        elseif classType = 'region' then
            set sqlstr = concat(sqlstr, ' and pro.isdelete = 0');
            set sqlstringtotal = concat(sqlstr, ' and cus.regionid = ', classid, ' ) as optsd');
            set sqlstring = concat(sqlstr, ' and cus.regionid = ', classid, ' ) as optsd group by optsd.proid');
            set sqlheader = replace(sqlheader, '$classname$','optsd.province');
            set sqlheader = replace(sqlheader, '$classnameen$','optsd.provinceen');
            set sqlheader = replace(sqlheader, '$classfield$','provinceid');
            set sqlheader = replace(sqlheader, '$classid$','optsd.proid');
        
        elseif classType = 'province' then
        		set sqlstr = concat(sqlstr, ' and city.isdelete = 0');
            set sqlstringtotal = concat(sqlstr, ' and cus.provinceid = ', classid, ' ) as optsd');
            set sqlstring = concat(sqlstr, ' and cus.provinceid = ', classid, ' ) as optsd group by optsd.cityid');
            set sqlheader = replace(sqlheader,'$classname$','optsd.city');
            set sqlheader = replace(sqlheader,'$classnameen$','optsd.cityen');
            set sqlheader = replace(sqlheader, '$classfield$','cityid');
            set sqlheader = replace(sqlheader, '$classid$','optsd.cityid');
        end if;

        
        set sqlstringtotal = replace(sqlstringtotal,'$sqlheader$','select sum(optsd.converttotalprice) into @totalvalue from (select distinct(opt.id) as optid, convertopt.converttotalprice ');
        set @stmt = sqlstringtotal; 
        PREPARE stmt FROM @stmt;
        EXECUTE stmt;
        set totalvalue = ifnull(@totalvalue,0);
       
        
        set sqlheader = replace(sqlheader, '$totalvalue$', totalvalue);
        
        set sqlstring = replace(sqlstring, '$sqlheader$', sqlheader);
        
        set sqlstring = replace(sqlstring,'$statisticunit$',statisticunits);
        set @stmt = sqlstring; 
        
        PREPARE stmt FROM @stmt;
        EXECUTE stmt;        
        DEALLOCATE PREPARE stmt;
        select * from tmp_chart_optanalysis_region_table;
    end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `chart_optsizemain_chart_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `chart_optsizemain_chart_proc`(IN syscurrencyid varchar(20),IN before1monthdate varchar(20),IN before3monthdate varchar(20),IN startdate varchar(20),IN enddate varchar(20),IN employeesid varchar(4000),IN departsid varchar(4000),IN faranchiseid int,IN isbigproject smallint,IN bigvalue DECIMAL(14,2))
BEGIN
    declare statisticunits DECIMAL(14,2);
    declare done TINYINT DEFAULT 0;
    declare yearmonthval varchar(20);
    declare percent10val DECIMAL(14,2);
    declare percent30val DECIMAL(14,2);
    declare percent50val DECIMAL(14,2);
    declare percent70val DECIMAL(14,2);
    declare percent90val DECIMAL(14,2);
    declare percent100val DECIMAL(14,2);
    declare percent10preval DECIMAL(3,2);
    declare percent30preval DECIMAL(3,2);
    declare percent50preval DECIMAL(3,2);
    declare percent70preval DECIMAL(3,2);
    declare percent90preval DECIMAL(3,2);
    declare targetvalueval DECIMAL(14,2);
    declare predictedvalueval DECIMAL(14,2);
    declare optpriceval DECIMAL(14,2);
    declare escur cursor for (select yearmonth,percent10,percent30,percent50,percent70,percent90,percent100,targetvalue,predictedvalue,optprice from tmp_chart_optsize_chart_table);
    declare continue handler for not found set done = 1;
    
    select `statisticunit` into statisticunits from currencyexchange where id = syscurrencyid;
    /* 创建结果集临时表 */
    create temporary table IF NOT EXISTS `tmp_chart_optsizemian_chart_table`
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

    truncate table `tmp_chart_optsizemian_chart_table`;

    /* 清理初始化参数 */
    if (employeesid is not null and CHAR_LENGTH(employeesid) = 0) then
        set employeesid = null;
    end if;
    if (departsid is not null and CHAR_LENGTH(departsid) = 0) then
        set departsid = null;
    end if;

    /* 打开游标 */
    open escur;
        /* 遍历数据表 */
        read_loop: loop
            fetch escur into yearmonthval,percent10val,percent30val,percent50val,percent70val,percent90val,percent100val,targetvalueval,predictedvalueval,optpriceval;
            if done then
                leave read_loop;
            end if;
            call chart_optsize_allstagewin_proc(before1monthdate,before3monthdate,yearmonthval,syscurrencyid,employeesid,departsid,faranchiseid);
            set percent10preval = (select predictpercent from tmp_chart_optsize_allstagewin_table where id = 1);
            set percent30preval = (select predictpercent from tmp_chart_optsize_allstagewin_table where id = 2);
            set percent50preval = (select predictpercent from tmp_chart_optsize_allstagewin_table where id = 3);
            set percent70preval = (select predictpercent from tmp_chart_optsize_allstagewin_table where id = 4);
            set percent90preval = (select predictpercent from tmp_chart_optsize_allstagewin_table where id = 5);
            set predictedvalueval = percent10val*percent10preval+percent30val*percent30preval+percent50val*percent50preval+percent70val*percent70preval+percent90val*percent90preval+percent100val;
            insert into tmp_chart_optsizemian_chart_table(yearmonth,percent10,percent30,percent50,percent70,percent90,percent100,targetvalue,predictedvalue,optprice) values(yearmonthval,percent10val,percent30val,percent50val,percent70val,percent90val,percent100val,targetvalueval,predictedvalueval,optpriceval);
            
        end loop;
    /* 关闭游标 */
    close escur;
          
    set done = 0;

    select * from tmp_chart_optsizemian_chart_table;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `chart_optsize_allstagewin_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `chart_optsize_allstagewin_proc`(IN before1monthdate varchar(20),IN before3monthdate varchar(20),in startdate varchar(20),in currencyid int,in employeesid varchar(4000),in departsid varchar(4000),in faranchiseid int)
begin
    declare sqlstr longtext default '';
    declare sqlstring longtext default '';
    declare sqlcondition longtext default '';
    declare currencyblock longtext default '';
    declare currencyblockString longtext default '';
    declare othercondition longtext default '';
    declare statuscondition longtext default '';
    declare nowdate varchar(20);

    drop table if exists `tmp_chart_optsize_allstagewin_table`;
    /* 创建阶段预测百分比结果集临时表 */
    create temporary table if not exists `tmp_chart_optsize_allstagewin_table`
    (
        `id` int(10) not null auto_increment comment 'ID',
        `predictpercent` decimal(3,2) not null comment '预测百分比',
        primary key (`id`)
    );

    truncate table `tmp_chart_optsize_allstagewin_table`;

  /* 清理初始化参数 */
    if (employeesid is not null and char_length(employeesid) = 0) then
    set employeesid = null;
    end if;
    if (departsid is not null and char_length(departsid) = 0) then
    set departsid = null;
    end if;
    set nowdate = date_format(concat(startdate,'/01'),'%Y-%m-%d');

    
    /* 定义项目金额百分比insert select语句 */
    set sqlstr = 'insert into tmp_chart_optsize_allstagewin_table(predictpercent) select optcol1.col1 from ';
    set sqlstr = concat(sqlstr,'(select ifnull(round(sum(if(opt.optstatus=2 ,opt.converttotalprice,null))/sum(opt.converttotalprice2),2),0.00) as col1 ');
    set sqlstr = concat(sqlstr,'from ');
    set sqlstr = concat(sqlstr,'(select opte.id,optr.optstatus,opte.stageid,opte.converttotalprice converttotalprice2,
        optr.converttotalprice converttotalprice from ($estimateCurrencyBlock1) opte left join ($realCurrencyBlock1) optr
         on opte.id = optr.id and opte.snapdate = optr.snapdate left join opt on opt.id = optr.id 
         left join employee emp on opt.ownerid = emp.id where 1=1 $othercondition $statuscondition) opt) optcol1 ');

	/* 根据机会币种构造机会总值和转换率sql */
    set currencyblock = concat('select opt.optid id,opt.stageid,opt.optstatus,opt.snapdate, if(',currencyid,'=1,');
    set currencyblock = concat(currencyblock,'if(opt.currencyid=1,');
    set currencyblock = concat(currencyblock,'opt.totalprice,');
    set currencyblock = concat(currencyblock,'opt.totalpriceminor*cast(if(',currencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as decimal(14,2))),');
    set currencyblock = concat(currencyblock,'if(opt.currencyid=2,');
    set currencyblock = concat(currencyblock,'opt.totalpriceminor,');
    set currencyblock = concat(currencyblock,'opt.totalprice*cast(if(',currencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as decimal(14,2)))) converttotalprice,');
    set currencyblock = concat(currencyblock,'if(',currencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) formula ');
    set currencyblock = concat(currencyblock,'from $targetTable opt ');
    set currencyblock = concat(currencyblock,'left join currencyconvert cc on ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate ');
    set currencyblock = concat(currencyblock,'left join (select cast(if(',currencyid,'=1,intoajformula,ajtoinformula) as decimal(14,2)) formula from currencyconvert order by id desc limit 1) lasc on 1=1');
    
    /* 拼接where条件 */
    if (employeesid is not null and departsid is not null) then
        set othercondition = concat(othercondition,' and (opt.ownerid in (',employeesid,') or emp.depid in (',departsid,')) ');
    else
        if employeesid is not null then
            set othercondition = concat(othercondition,' and (opt.ownerid in (',employeesid,')) ');
        elseif departsid is not null then
            set othercondition = concat(othercondition, ' and emp.depid in (',departsid,') ');
        end if;
    end if;

    if (faranchiseid is not null and faranchiseid > 0) then
        set othercondition = concat(othercondition, ' and opt.faranchiseid = ',faranchiseid);
    end if;
    
    /*10% -> 100%*/
    set sqlstring = sqlstr;
	set currencyblockString = replace(currencyblock,'$targetTable',concat('(select optid,currencyid,totalprice,totalpriceminor,realityoverdate,planoverdate,stageid,optstatus,snapdate from optestimatesnap where (snapdate between ',before3monthdate,' and ',before1monthdate,'))'));
	set sqlstring = replace(sqlstring,'$estimateCurrencyBlock1',currencyblockString);
	set currencyblockString = replace(currencyblock,'$targetTable',concat('(select optid,currencyid,totalprice,totalpriceminor,realityoverdate,planoverdate,stageid,optstatus,snapdate from optrealsnap where (snapdate between ',before3monthdate,' and ',before1monthdate,'))'));
	set sqlstring = replace(sqlstring,'$realCurrencyBlock1',currencyblockString);
    set sqlstring = replace(sqlstring,'$othercondition',othercondition);
    set sqlstring = replace(sqlstring,'$statuscondition',' and opte.stageid = 2 and opt.isdelete = 0');

    set @stmt = sqlstring;
    prepare stmt from @stmt;
    execute stmt;
    
    /*30% -> 100%*/
    set sqlstring = sqlstr;
	set currencyblockString = replace(currencyblock,'$targetTable',concat('(select optid,currencyid,totalprice,totalpriceminor,realityoverdate,planoverdate,stageid,optstatus,snapdate from optestimatesnap where (snapdate between ',before3monthdate,' and ',before1monthdate,'))'));
	set sqlstring = replace(sqlstring,'$estimateCurrencyBlock1',currencyblockString);
	set currencyblockString = replace(currencyblock,'$targetTable',concat('(select optid,currencyid,totalprice,totalpriceminor,realityoverdate,planoverdate,stageid,optstatus,snapdate from optrealsnap where (snapdate between ',before3monthdate,' and ',before1monthdate,'))'));
	set sqlstring = replace(sqlstring,'$realCurrencyBlock1',currencyblockString);
    set sqlstring = replace(sqlstring,'$othercondition',othercondition);
    set sqlstring = replace(sqlstring,'$statuscondition',' and opte.stageid = 3 and opt.isdelete = 0');

    set @stmt = sqlstring;
    prepare stmt from @stmt;
    execute stmt;
    
    /*50% -> 100%*/
    set sqlstring = sqlstr;
	set currencyblockString = replace(currencyblock,'$targetTable',concat('(select optid,currencyid,totalprice,totalpriceminor,realityoverdate,planoverdate,stageid,optstatus,snapdate from optestimatesnap where (snapdate between ',before3monthdate,' and ',before1monthdate,'))'));
	set sqlstring = replace(sqlstring,'$estimateCurrencyBlock1',currencyblockString);
	set currencyblockString = replace(currencyblock,'$targetTable',concat('(select optid,currencyid,totalprice,totalpriceminor,realityoverdate,planoverdate,stageid,optstatus,snapdate from optrealsnap where (snapdate between ',before3monthdate,' and ',before1monthdate,'))'));
	set sqlstring = replace(sqlstring,'$realCurrencyBlock1',currencyblockString);
    set sqlstring = replace(sqlstring,'$othercondition',othercondition);
    set sqlstring = replace(sqlstring,'$statuscondition',' and opte.stageid = 4 and opt.isdelete = 0');

    set @stmt = sqlstring;
    prepare stmt from @stmt;
    execute stmt;
    
    /*70% -> 100%*/
    set sqlstring = sqlstr;
	set currencyblockString = replace(currencyblock,'$targetTable',concat('(select optid,currencyid,totalprice,totalpriceminor,realityoverdate,planoverdate,stageid,optstatus,snapdate from optestimatesnap where (snapdate between ',before3monthdate,' and ',before1monthdate,'))'));
	set sqlstring = replace(sqlstring,'$estimateCurrencyBlock1',currencyblockString);
	set currencyblockString = replace(currencyblock,'$targetTable',concat('(select optid,currencyid,totalprice,totalpriceminor,realityoverdate,planoverdate,stageid,optstatus,snapdate from optrealsnap where (snapdate between ',before3monthdate,' and ',before1monthdate,'))'));
	set sqlstring = replace(sqlstring,'$realCurrencyBlock1',currencyblockString);
    set sqlstring = replace(sqlstring,'$othercondition',othercondition);
    set sqlstring = replace(sqlstring,'$statuscondition',' and opte.stageid = 5 and opt.isdelete = 0');

    set @stmt = sqlstring;
    prepare stmt from @stmt;
    execute stmt;
    
    /*90% -> 100%*/
    set sqlstring = sqlstr;
	set currencyblockString = replace(currencyblock,'$targetTable',concat('(select optid,currencyid,totalprice,totalpriceminor,realityoverdate,planoverdate,stageid,optstatus,snapdate from optestimatesnap where (snapdate between ',before3monthdate,' and ',before1monthdate,'))'));
	set sqlstring = replace(sqlstring,'$estimateCurrencyBlock1',currencyblockString);
	set currencyblockString = replace(currencyblock,'$targetTable',concat('(select optid,currencyid,totalprice,totalpriceminor,realityoverdate,planoverdate,stageid,optstatus,snapdate from optrealsnap where (snapdate between ',before3monthdate,' and ',before1monthdate,'))'));
	set sqlstring = replace(sqlstring,'$realCurrencyBlock1',currencyblockString);
    set sqlstring = replace(sqlstring,'$othercondition',othercondition);
    set sqlstring = replace(sqlstring,'$statuscondition',' and opte.stageid = 6 and opt.isdelete = 0');

    set @stmt = sqlstring;
    prepare stmt from @stmt;
    execute stmt;
    
    deallocate prepare stmt;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `chart_optsize_chart_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `chart_optsize_chart_proc`(IN syscurrencyid varchar(20),IN before1monthdate varchar(20),IN before3monthdate varchar(20),IN startdate varchar(20),IN enddate varchar(20),IN employeesid varchar(4000),IN departsid varchar(4000),IN faranchiseid int,IN isbigproject smallint,IN bigvalue DECIMAL(14,2))
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
     drop table if exists `tmp_chart_optsize_chart_table`;
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
        set sqlstr = concat(sqlstr,'ifnull(round($targetvalue$,2),0) as targetvalue, ');
        set sqlstr = concat(sqlstr,'$yearmonth$ as yearmonth, ');
        set sqlstr = concat(sqlstr,'ifnull(round(sum((case when opt.optstatus = 1 then convertopt.converttotalprice*op.possibility*os.stage when opt.optstatus = 2 then convertopt.converttotalprice else 0 end)/$statisticunit$),2),0.00) as optprice ');
        set sqlstr = concat(sqlstr,'from opt 
            LEFT JOIN optpossibility op on opt.possibilityid=op.id
            LEFT JOIN optstage os on opt.stageid=os.id
            left join employee emp on opt.ownerid = emp.id left join (select
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
		set monthcount = 12;
            /* 取12个月的日期 */
            while tmpcount <= monthcount do
                -- 如果大于1取下一个月的第1天
                
                if tmpcount > 1 then 
                    set tmpdate = date_add(tmpdate,interval 1 day); 
                end if;
                    
                set startplanoverdate = tmpdate;

                set tmpdate = date_sub(date_add(tmpdate,interval 1 month),interval 1 day); 
                set endplanoverdate = tmpdate;

			set sqlstring = concat(sqlstr, ' and opt.planoverdate between \'', startplanoverdate, '\' and \'', endplanoverdate, '\'');
            /** 
             * 将$targetvalue$替换为目标金额
             * 将$yearmonth$替换为实际年月格式 
             * 
             */
            call chart_optsize_target_proc(syscurrencyid,employeesid,departsid,faranchiseid,startplanoverdate,targetvalue);

            set sqlstring = replace(sqlstring,'$targetvalue$',targetvalue/statisticunits);
            set sqlstring = replace(sqlstring,'$yearmonth$',date_format(startplanoverdate,'\'%Y/%m\''));
            set sqlstring = replace(sqlstring,'$statisticunit$',statisticunits);
			
           insert into debug(debug) values(sqlstring);
            set @stmt = sqlstring;
            PREPARE stmt FROM @stmt;
			EXECUTE stmt;
			-- insert into debug(debug) values(sqlstring);
			
            set tmpcount = tmpcount + 1;
        end while;
		DEALLOCATE PREPARE stmt;
        call chart_optsizemain_chart_proc(syscurrencyid,before1monthdate,before3monthdate,startdate,enddate,employeesid,departsid,faranchiseid,isbigproject,bigvalue);
	end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `chart_optsize_grid_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `chart_optsize_grid_proc`(IN syscurrencyid varchar(20),IN before1monthdate varchar(20),IN before3monthdate varchar(20), IN startdate varchar(20),IN enddate varchar(20),IN employeesid varchar(4000),IN departsid varchar(4000),IN faranchiseid int)
BEGIN
    declare tmpdate varchar(20);
    declare nowdate varchar(20);
    declare yearmonth varchar(20);
    declare startplanoverdate varchar(20);
    declare endplanoverdate varchar(20);
    declare tmpcount int;
    declare sqlstr longtext default '';
    declare optsqlstr longtext default '';
    declare sqlstring longtext default '';
    declare optsqlstring longtext default '';
    declare othercondition longtext default '';
    declare flag TINYINT DEFAULT 0;
    declare targetvalue DECIMAL(14,2);
    declare statisticunits DECIMAL(14,2);
    declare monthcount int;
    declare percent10preval DECIMAL(3,2);
    declare percent30preval DECIMAL(3,2);
    declare percent50preval DECIMAL(3,2);
    declare percent70preval DECIMAL(3,2);
    declare percent90preval DECIMAL(3,2);
    declare m1 varchar(20);
    declare p1 DECIMAL(3,2);

    set sqlstring = '';
    select `statisticunit` into statisticunits from currencyexchange where id = syscurrencyid;
    
    drop temporary table if exists tmp_chart_optsize_grid_table;
    /* 创建结果集临时表 */
    create temporary table IF NOT EXISTS `tmp_chart_optsize_grid_table`
    (
        `id` int(10)  AUTO_INCREMENT COMMENT 'ID',
        `yearmonth` varchar(20)  COMMENT '年/月',
        `targetvalue` DECIMAL(14,2)  DEFAULT 0 COMMENT '目标金额（￥10K）',
        `dooptprice` DECIMAL(14,2)  DEFAULT 0 COMMENT '执行情况-订单总金额',
        `dooptnum` varchar(20)  DEFAULT 0 COMMENT '执行情况-订单数量',
        `doforeoptprice` varchar(20)  DEFAULT 0 COMMENT '执行情况-预计项目接单金额',
        `doforeoptnum` varchar(20)  DEFAULT 0 COMMENT '执行情况-预计项目中接单数',
        `orderrate` DECIMAL(14,2)  DEFAULT 0 COMMENT '接单能力-接单率(%)',
        `closeingamoutrate` DECIMAL(14,2)  DEFAULT 0 COMMENT '接单能力-接单金额转换率(%)',
        `forecastoptnum` varchar(20)  DEFAULT 0 COMMENT '销售预测-预计接单项目数',
        `forecastoptprice` DECIMAL(14,2)  DEFAULT 0 COMMENT '销售预测-预测金额',
        `optprice` DECIMAL(14,2)  DEFAULT 0 COMMENT '销售漏斗-有效金额',
        `dealprice` DECIMAL(14,2)  DEFAULT 0 COMMENT '销售漏斗-项目金额',
        `alloptpercent90` DECIMAL(14,2)  DEFAULT 0 COMMENT '销售漏斗-所有项目-90%',
        `alloptpercent70` DECIMAL(14,2)  DEFAULT 0 COMMENT '销售漏斗-所有项目-70%',
        `alloptpercent50` DECIMAL(14,2)  DEFAULT 0 COMMENT '销售漏斗-所有项目-50%',
        `alloptpercent30` DECIMAL(14,2)  DEFAULT 0 COMMENT '销售漏斗-所有项目-30%',
        `alloptpercent10` DECIMAL(14,2)  DEFAULT 0 COMMENT '销售漏斗-所有项目-10%',
        `bigprojecttotalprice` DECIMAL(14,2)  DEFAULT 0 COMMENT '销售漏斗-所有项目-大项目',
        `alloptpercent100` DECIMAL(14,2)  DEFAULT 0 COMMENT '销售漏斗-接单项目-100%',
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
        set sqlstr = concat(sqlstr,'insert into tmp_chart_optsize_grid_table(yearmonth,targetvalue,dooptprice,dooptnum,doforeoptprice,doforeoptnum,orderrate,closeingamoutrate,forecastoptnum,forecastoptprice,optprice,dealprice,alloptpercent90,alloptpercent70,
        alloptpercent50,alloptpercent30,alloptpercent10,bigprojecttotalprice,alloptpercent100) 
        select 
        $yearmonth$ as yearmonth, 
        ifnull(round($targetvalue$,2),0) as targetvalue, 
        $dooptprice$ as dooptprice, 
        $dooptnum$ as dooptnum, 
        $doforeoptprice$ as doforeoptprice, 
        $doforeoptnum$ as doforeoptnum, 
        $orderrate$ as orderrate, 
        $closeingamoutrate$ as closeingamoutrate,
        $forecastoptnum$ as forecastoptnum,
        $forecastoptprice$ as forecastoptprice, 
        $optprice$ as optprice, 
        $dealprice$ as dealprice, 
        $alloptpercent90$ as alloptpercent90, 
        $alloptpercent70$ as alloptpercent70, 
        $alloptpercent50$ as alloptpercent50, 
        $alloptpercent30$ as alloptpercent30, 
        $alloptpercent10$ as alloptpercent10, 
        $bigprojecttotalprice$ as bigprojecttotalprice, 
        $alloptpercent100$ as alloptpercent100 
        from $maintable
         left join employee emp on opt.ownerid = emp.id 
         left join (select  opt.id ,
                      if(',syscurrencyid,'=1,
                         if(opt.currencyid,
                            opt.totalprice,
                            opt.totalpriceminor*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2))),
                         if(opt.currencyid=2,
                            opt.totalpriceminor,
                            opt.totalprice*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2)))) converttotalprice
                        from  $table
                        left join currencyconvert cc
                          ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
                        left join (select cast(if(',syscurrencyid,'=1,intoajformula,ajtoinformula) as DECIMAL(14,2)) formula  from currencyconvert ORDER BY id desc limit 1) lasc
                          ON 1=1 where 1=1) convertopt on opt.id=convertopt.id
        left join (select  opt.id,
                        if(opt.currencyid,
                                 if(opt.totalprice >= cue.statisticunit*ed.bigoptprice,
                                    1,0),
                                 if(opt.totalpriceminor >= cue.statisticuniteminor*ed.bigoptpriceminor,
                                    1,0) 
                         )  isbigdeals 
                          from $table
                          left join employee e on e.id = opt.ownerid
                          left join empdepart ed on e.depid = ed.id
                          left join (SELECT c.statisticunit,cue.statisticunit statisticuniteminor
                                       from currencyexchange c
                                         left join (SELECT statisticunit from currencyexchange LIMIT 1,2) cue on 1=1 limit 0,1) cue on 1=1
                          ) bigdeals on opt.id = bigdeals.id
        where $where$ $othercondition$');

       set optsqlstr = concat(optsqlstr,'
        select ifnull(count(opt.id),0),ifnull(round(sum(convertopt.converttotalprice)/$statisticunit$,2),0)
        from optrealsnap opt 
          left join employee emp on opt.ownerid = emp.id 
          left join (select  opt.id,
                      if(',syscurrencyid,'=1,
                         if(opt.currencyid,
                            opt.totalprice,
                            opt.totalpriceminor*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2))),
                         if(opt.currencyid=2,
                            opt.totalpriceminor,
                            opt.totalprice*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2)))) converttotalprice
                            from  optrealsnap opt
                            left join currencyconvert cc
                              ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
                            left join (select cast(if(',syscurrencyid,'=1,intoajformula,ajtoinformula) as DECIMAL(14,2)) formula  from currencyconvert ORDER BY id desc limit 1) lasc
                              ON 1=1 ) convertopt on opt.id=convertopt.id
            left join ( select  opt.id,
                    if(opt.currencyid,
                             if(opt.totalprice >= cue.statisticunit*ed.bigoptprice,
                                1,0),
                             if(opt.totalpriceminor >= cue.statisticuniteminor*ed.bigoptpriceminor,
                                1,0) 
                     )  isbigdeals from optrealsnap opt
                          left join employee e on e.id = opt.ownerid
                          left join empdepart ed on e.depid = ed.id
                          left join (SELECT c.statisticunit,cue.statisticunit statisticuniteminor
                                       from currencyexchange c
                                         left join (SELECT statisticunit from currencyexchange LIMIT 1,2) cue on 1=1 limit 0,1) cue on 1=1 
                    ) bigdeals on opt.id = bigdeals.id
        where $whereoptr$ $othercondition$
        into @donum,@doprice');

        if (employeesid is not null and departsid is not null) then
            set othercondition = concat(othercondition,' and (opt.ownerid in (',employeesid,') or emp.depid in (',departsid,'))');
        else
            if employeesid is not null then
                set othercondition = concat(othercondition,' and (opt.ownerid in (',employeesid,'))');
            elseif departsid is not null then
                set othercondition = concat(othercondition, ' and emp.depid in (',departsid,')');
            end if;
        end if;
        if (faranchiseid is not null and faranchiseid > 0) then
            set othercondition = concat(othercondition, ' and opt.faranchiseid = ',faranchiseid);
        end if;

        set nowdate = date_format(now(),'%Y-%m-%d');
        set tmpdate = startdate;
        set monthcount = 12;
            /* 取12个月的日期 */
            while tmpcount <= monthcount do
             -- 如果大于1取下一个月的第1天
            if tmpcount > 1 then 
                set tmpdate = date_add(tmpdate,interval 1 day); 
            end if;
                
            set startplanoverdate = tmpdate;

            set tmpdate = date_sub(date_add(tmpdate,interval 1 month),interval 1 day); 
            set endplanoverdate = tmpdate;
            
             -- 
            set optsqlstring = replace(optsqlstr,'$whereoptr$',concat('opt.planoverdate between \'', startplanoverdate, '\' and \'', endplanoverdate, '\'  and opt.optstatus=2'));
            set optsqlstring = replace(optsqlstring,'$statisticunit$',statisticunits);
            set optsqlstring = replace(optsqlstring,'$othercondition$',othercondition);

            set @stmt = optsqlstring;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;

            set m1 = @donum;
            set p1 = @doprice;

            -- 获取目标,代理商,员工
            call chart_optsize_target_proc(syscurrencyid,employeesid,departsid,faranchiseid,startplanoverdate,targetvalue);
            -- 获取动态三个月的不同进展阶段阶段率
            call chart_optsize_allstagewin_proc(before1monthdate,before3monthdate,date_format(startplanoverdate,'%Y/%m'),syscurrencyid,employeesid,departsid,faranchiseid);
            set percent10preval = (select predictpercent from tmp_chart_optsize_allstagewin_table where id = 1);
            set percent30preval = (select predictpercent from tmp_chart_optsize_allstagewin_table where id = 2);
            set percent50preval = (select predictpercent from tmp_chart_optsize_allstagewin_table where id = 3);
            set percent70preval = (select predictpercent from tmp_chart_optsize_allstagewin_table where id = 4);
            set percent90preval = (select predictpercent from tmp_chart_optsize_allstagewin_table where id = 5);
            
            set sqlstring = replace(sqlstr,'$yearmonth$',date_format(startplanoverdate,'\'%Y/%m\''));
            set sqlstring = replace(sqlstring,'$targetvalue$',targetvalue/statisticunits);
            set sqlstring = replace(sqlstring,'$othercondition$',othercondition);
            
    -- 如果当前时间大于起始,则处于本月之前
        if nowdate > endplanoverdate then
            set sqlstring = replace(sqlstring,'$maintable','optestimatesnap opt left join optrealsnap optr on opt.optid = optr.optid and opt.snapdate = optr.snapdate');
            set sqlstring = replace(sqlstring,'$table','optestimatesnap opt');
            set sqlstring = replace(sqlstring,'$where$',concat('opt.planoverdate between \'', startplanoverdate, '\' and \'', endplanoverdate, '\'  and opt.optstatus=1'));
            set sqlstring = replace(sqlstring,'$dooptprice$',p1);
            set sqlstring = replace(sqlstring,'$dooptnum$',m1);
            set sqlstring = replace(sqlstring,'$doforeoptprice$','ifnull(round(sum(if(optr.optstatus = 2,convertopt.converttotalprice,0))/$statisticunit$,2),0)');
            set sqlstring = replace(sqlstring,'$doforeoptnum$','ifnull(round(count(if(optr.optstatus = 2,opt.id,null)),2),0)');
            set sqlstring = replace(sqlstring,'$orderrate$','ifnull(round(count(if(optr.optstatus = 2,opt.id,null))/count(opt.id),2),0)');
            set sqlstring = replace(sqlstring,'$closeingamoutrate$','ifnull(round(sum(if(optr.optstatus = 2,convertopt.converttotalprice,0))/
                                                                    sum(convertopt.converttotalprice),2),0)');
            set sqlstring = replace(sqlstring,'$forecastoptnum$','count(opt.id)');
            set sqlstring = replace(sqlstring,'$forecastoptprice$',concat('ifnull(cast(sum(
                                                                        if(opt.stageid=2,convertopt.converttotalprice*', percent10preval, ',
                                                                        if(opt.stageid=3,convertopt.converttotalprice*', percent30preval, ',
                                                                        if(opt.stageid=4,convertopt.converttotalprice*', percent50preval, ',
                                                                        if(opt.stageid=5,convertopt.converttotalprice*', percent70preval, ',
                                                                        if(opt.stageid=6,convertopt.converttotalprice*', percent90preval, ',0)))))/$statisticunit$) as decimal(14,2)),0)'));
            set sqlstring = replace(sqlstring,'$optprice$','ifnull(round(sum(convertopt.converttotalprice*(case opt.stageid when 1 then 0 when 2 then 0.1 when 3 then 0.3 when 4 then 0.5 when 5 then 0.7 when 6 then 0.9 end)*
    (case opt.possibilityid when 1 then 0.2 when 2 then 0.25 when 3 then 0.3 when 4 then 0.5 when 5 then 0.8 end))/$statisticunit$,2),0)
    ');         
            set sqlstring = replace(sqlstring,'$dealprice$','ifnull(round(sum(convertopt.converttotalprice)/$statisticunit$,2),0)');
            set sqlstring = replace(sqlstring,'$alloptpercent90$','ifnull(round(sum(if(opt.stageid = 6,convertopt.converttotalprice,0))/$statisticunit$,2),0)');
            set sqlstring = replace(sqlstring,'$alloptpercent70$','ifnull(round(sum(if(opt.stageid = 5,convertopt.converttotalprice,0))/$statisticunit$,2),0)');
            set sqlstring = replace(sqlstring,'$alloptpercent50$','ifnull(round(sum(if(opt.stageid = 4,convertopt.converttotalprice,0))/$statisticunit$,2),0)');
            set sqlstring = replace(sqlstring,'$alloptpercent30$','ifnull(round(sum(if(opt.stageid = 3,convertopt.converttotalprice,0))/$statisticunit$,2),0)');
            set sqlstring = replace(sqlstring,'$alloptpercent10$','ifnull(round(sum(if(opt.stageid = 2,convertopt.converttotalprice,0))/$statisticunit$,2),0)');
            set sqlstring = replace(sqlstring,'$bigprojecttotalprice$',concat('ifnull(round(sum(if(bigdeals.isbigdeals,convertopt.converttotalprice,0))/$statisticunit$,2),0)'));
            set sqlstring = replace(sqlstring,'$alloptpercent100$',p1);
            set sqlstring = replace(sqlstring,'$statisticunit$',statisticunits);
        else 
            set sqlstring = replace(sqlstring,'$maintable','opt');
            set sqlstring = replace(sqlstring,'$table','opt');
            set sqlstring = replace(sqlstring,'$where$',concat('opt.planoverdate between \'', startplanoverdate, '\' and \'', endplanoverdate, '\'  and opt.optstatus in (1,2) and opt.isdelete=0'));
            set sqlstring = replace(sqlstring,'$dooptprice$','0');
            set sqlstring = replace(sqlstring,'$dooptnum$','0');
            set sqlstring = replace(sqlstring,'$doforeoptprice$','0');
            set sqlstring = replace(sqlstring,'$doforeoptnum$','0');
            set sqlstring = replace(sqlstring,'$orderrate$','0');
            set sqlstring = replace(sqlstring,'$closeingamoutrate$','0');
            set sqlstring = replace(sqlstring,'$forecastoptnum$','count(opt.id)');
            set sqlstring = replace(sqlstring,'$forecastoptprice$',concat('ifnull(cast(sum(
                                                                        if(opt.optstatus=1 and opt.stageid=2,convertopt.converttotalprice*', percent10preval, ',
                                                                        if(opt.optstatus=1 and opt.stageid=3,convertopt.converttotalprice*', percent30preval, ',
                                                                        if(opt.optstatus=1 and opt.stageid=4,convertopt.converttotalprice*', percent50preval, ',
                                                                        if(opt.optstatus=1 and opt.stageid=5,convertopt.converttotalprice*', percent70preval, ',
                                                                        if(opt.optstatus=1 and opt.stageid=6,convertopt.converttotalprice*', percent90preval, ',0)))))/$statisticunit$) as decimal(14,2)),0)'));
            set sqlstring = replace(sqlstring,'$optprice$','ifnull(round(sum(if(opt.optstatus=1,convertopt.converttotalprice*(case opt.stageid when 1 then 0 when 2 then 0.1 when 3 then 0.3 when 4 then 0.5 when 5 then 0.7 when 6 then 0.9 end)*
    (case opt.possibilityid when 1 then 0.2 when 2 then 0.25 when 3 then 0.3 when 4 then 0.5 when 5 then 0.8 end),0))/$statisticunit$,2),0)
    ');         
            set sqlstring = replace(sqlstring,'$dealprice$','ifnull(round(sum(convertopt.converttotalprice)/$statisticunit$,2),0)');
            set sqlstring = replace(sqlstring,'$alloptpercent90$','ifnull(round(sum(if(opt.optstatus=1 and opt.stageid = 6,convertopt.converttotalprice,0))/$statisticunit$,2),0)');
            set sqlstring = replace(sqlstring,'$alloptpercent70$','ifnull(round(sum(if(opt.optstatus=1 and opt.stageid = 5,convertopt.converttotalprice,0))/$statisticunit$,2),0)');
            set sqlstring = replace(sqlstring,'$alloptpercent50$','ifnull(round(sum(if(opt.optstatus=1 and opt.stageid = 4,convertopt.converttotalprice,0))/$statisticunit$,2),0)');
            set sqlstring = replace(sqlstring,'$alloptpercent30$','ifnull(round(sum(if(opt.optstatus=1 and opt.stageid = 3,convertopt.converttotalprice,0))/$statisticunit$,2),0)');
            set sqlstring = replace(sqlstring,'$alloptpercent10$','ifnull(round(sum(if(opt.optstatus=1 and opt.stageid = 2,convertopt.converttotalprice,0))/$statisticunit$,2),0)');
            set sqlstring = replace(sqlstring,'$bigprojecttotalprice$',concat('ifnull(round(sum(if(bigdeals.isbigdeals,convertopt.converttotalprice,0))/$statisticunit$,2),0)'));
            set sqlstring = replace(sqlstring,'$alloptpercent100$','ifnull(round(sum(if(opt.optstatus = 2,convertopt.converttotalprice,0))/$statisticunit$,2),0)');
            set sqlstring = replace(sqlstring,'$statisticunit$',statisticunits);
         end if;

            -- select sqlstring;
            set @stmt = sqlstring;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
             
            set tmpcount = tmpcount + 1;
        end while;
       DEALLOCATE PREPARE stmt;

       insert into tmp_chart_optsize_grid_table (yearmonth) values ('untilnow');
       insert into tmp_chart_optsize_grid_table (yearmonth) values ('total');

        select * from tmp_chart_optsize_grid_table;  
    end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `chart_optsize_shape_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
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

	
    if (employeesid is not null and CHAR_LENGTH(employeesid) = 0) then
		set employeesid = null;
    end if;
    if (departsid is not null and CHAR_LENGTH(departsid) = 0) then
		set departsid = null;
    end if;
    
    set tmpcount = 1;

    if CHAR_LENGTH(startdate) > 0 then
                
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

		













				
				











        
			set monthcount = 12;
			
			while tmpcount <= monthcount do
				
				
				if tmpcount > 1 then 
					set tmpdate = date_add(tmpdate,interval 1 day); 
				end if;
					
				set startplanoverdate = tmpdate;

				set tmpdate = date_sub(date_add(tmpdate,interval 1 month),interval 1 day); 
				set endplanoverdate = tmpdate;

				set sqlstring = concat(sqlstr, ' and opt.planoverdate between \'', startplanoverdate, '\' and \'', endplanoverdate, '\'');
				
				set sqlstring = replace(sqlstring,'$yearmonth$',date_format(startplanoverdate,'\'%Y/%m\''));
                set sqlstring = replace(sqlstring,'$statisticunit$',statisticunits);
				set @stmt = sqlstring;
				PREPARE stmt FROM @stmt;
				EXECUTE stmt;				
				set tmpcount = tmpcount + 1;
			end while;
        
        
		DEALLOCATE PREPARE stmt;
        select * from tmp_chart_optsize_shape_table;
	end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `chart_optsize_target_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `chart_optsize_target_proc`(IN syscurrencyid varchar(20),IN employeesid varchar(4000),IN departsid varchar(4000),IN faranchiseid int,IN targetdate varchar(20),OUT targetvalue DECIMAL(14,2))
BEGIN
	declare sqlstr longtext;
    declare years varchar(10);
    declare months varchar(10);
    set years = date_format(targetdate,'%Y');
    set months = date_format(targetdate,'%m');
    
    if faranchiseid > 0 then
		set sqlstr = concat('select if(',syscurrencyid,'=1,ifnull(round(faranchisevalue/12,0),0),ifnull(round(faranchiseminor/12,0),0)) into @p_targetvalue from faranchise where id = ',faranchiseid);
    else
		set sqlstr = concat('select if(',syscurrencyid,'=1,ifnull(sum(empt.targetmoney),0),ifnull(sum(empt.targetmoneyminor),0)) into @p_targetvalue from emptarget empt left join employee emp on empt.employeeid = emp.id where',
					' empt.years = \'',years,'\' and empt.months = \'',months,'\'');

		/*统计目标--员工、部门条件*/
        if (employeesid is not null and departsid is not null) then
            set sqlstr = concat(sqlstr,' and (find_in_set(empt.employeeid, (select group_concat(id) from employee where id in (',employeesid,') and depid not in(',departsid,')))
            or (find_in_set(empt.depid,(select group_concat(id) from empdepart  where  id in(',departsid,')
            and sdepartid not in(',departsid,'))) and empt.employeeid is null))');
        else
            if employeesid is not null then
                set sqlstr = concat(sqlstr, ' and empt.employeeid in (',employeesid,')');
            elseif departsid is not null then
                set sqlstr = concat(sqlstr, ' and find_in_set(empt.depid, (select group_concat(id) from empdepart  where id in(',departsid,') and sdepartid not in(',departsid,'))) and  empt.employeeid is null');
            else
            	-- 当部门、员工都为空时 获取最高级部门
            	set sqlstr = concat(sqlstr, ' and find_in_set(empt.depid, (select group_concat(id) from empdepart where sdepartid = 0)) and  empt.employeeid is null');
            end if;
        end if;
    end if;
    
    set @stmt = sqlstr;
	PREPARE stmt FROM @stmt;
	EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    set targetvalue = @p_targetvalue;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `chart_opttype_chart_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
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
    
    set sqltablestring = 'create temporary table IF NOT EXISTS `tmp_chart_opttype_chart_table`
    (`id` int(10) NOT NULL AUTO_INCREMENT COMMENT \'ID\',`yearmonth` varchar(20) NOT NULL COMMENT \'年/月\',';
    
	
    if (employeesid is not null and CHAR_LENGTH(employeesid) = 0) then
        set employeesid = null;
    end if;
    if (departsid is not null and CHAR_LENGTH(departsid) = 0) then
        set departsid = null;
    end if;
    
    if CHAR_LENGTH(startdate) > 0 then
    
		        
        set sqlstr = 'insert into tmp_chart_opttype_chart_table($opttypefields$, yearmonth) ';
        set sqlstr = concat(sqlstr,'select ');
    
		
		
		open cur;
		
		
		read_loop: loop
        
			fetch cur into opttypeid;
            
			if done then
				set tmpcount = 1;
				leave read_loop;
			end if;
            
            
			set sqltablestring = concat(sqltablestring, '`opttype', tmpcount, '` DECIMAL(14,2) NOT NULL,');
            
            
            if char_length(opttypefieldsstring) = 0 then
				set opttypefieldsstring = concat('opttype', tmpcount);
            else
				set opttypefieldsstring = concat_ws(',', opttypefieldsstring, concat('opttype', tmpcount));
            end if;
            set sqlstr = concat(sqlstr,'ifnull(round(sum(if(opt.opttype = ', opttypeid, ',convertopt.converttotalprice,0.00))/$statisticunit$,2),0.00) as ', 'opttype', tmpcount ,', ');
			set tmpcount = tmpcount + 1;
            
		end loop;
		
		
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
       set monthcount = 12;
            
            while tmpcount <= monthcount do
                
                
            if tmpcount > 1 then 
                set tmpdate = date_add(tmpdate,interval 1 day); 
            end if;
                
            set startplanoverdate = tmpdate;

            set tmpdate = date_sub(date_add(tmpdate,interval 1 month),interval 1 day); 
            set endplanoverdate = tmpdate;
            set sqlstring = concat(sqlstr, ' and opt.planoverdate between \'', startplanoverdate, '\' and \'', endplanoverdate, '\'');

			set sqlstring = replace(sqlstring, '$opttypefields$', opttypefieldsstring);
            set sqlstring = replace(sqlstring, '$yearmonth$', date_format(startplanoverdate, '\'%Y/%m\''));
            set sqlstring = replace(sqlstring, '$statisticunit$', statisticunits);
           
            set @stmt = sqlstring;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;

            set tmpcount = tmpcount + 1;
        end while;
        DEALLOCATE PREPARE stmt;

		select * from tmp_chart_opttype_chart_table;
    end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `chart_productanalysis_industry_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `chart_productanalysis_industry_proc`(
        IN `syscurrencyid` int,
	IN `startdate` varchar(20),
	IN `enddate` varchar(20),
	IN `brandid` varchar(4000),
	IN `classid` varchar(4000),
	IN `pmodelList` varchar(4000),
	IN `optstatus` int,
	IN `employeeIds` varchar(4000),
	IN `departIds` varchar(4000),
	IN `faranchiseid` int,
	IN `loginEmployeeid` int,
	IN `ispriceprofit` int ,
	IN `industryid` int

)
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
    declare totalvalue DECIMAL(14,2);
    declare lossvalue DECIMAL(14,2);
	 declare statisticunits DECIMAL(14,2);
	 
    set sqlstring = '';
	select `statisticunit` into statisticunits from currencyexchange where id = syscurrencyid;
    set sqlheader = 'insert into chart_productanalysis_industry_table(classId,className,classNameEn,totalprice,percent,lossprice,losspercent,ispriceprofit)  
	    select *from (select IFNULL($classId$,0) as classId,IFNULL($className$,\'Other\') as className,IFNULL($classNameEn$,\'Other\') as classNameEn 
		  ,IFNULL(cast(if(sum($converttotalprice$)>0,sum($converttotalprice$),0)/$statisticunit$ as DECIMAL(14,2)),0) as totalprice 
		  ,IFNULL(cast(if(sum($converttotalprice$)>0,sum($converttotalprice$),0)/$totalvalue$ as DECIMAL(14,2)),0) as percent,$lossprice$,$losspercent$,$ispriceprofit$';
		
	 drop table if exists `chart_productanalysis_industry_table`;
    
    create temporary table IF NOT EXISTS `chart_productanalysis_industry_table`
    (
        `id` int(10) NOT NULL AUTO_INCREMENT COMMENT 'ID',
        `classId` varchar(200) NOT NULL COMMENT '行业id',
        `className` varchar(200) NOT NULL  COMMENT '行业名称',
        `classNameEn` varchar(200) NOT NULL  COMMENT '行业名称-英文',
        `totalprice` DECIMAL(14,2) NOT NULL COMMENT '总金额/总毛利',
        `percent` DECIMAL(14,2) NOT NULL COMMENT '占比',
        `lossprice` DECIMAL(14,2) NOT NULL COMMENT '亏损的毛利',
        `losspercent` DECIMAL(14,2) NOT NULL COMMENT '亏损占比',
        `ispriceprofit` int(10) NOT NULL COMMENT '金额/毛利',
        PRIMARY KEY (`id`)
    );
    truncate table `chart_productanalysis_industry_table`;

	
    if (employeeIds is not null and CHAR_LENGTH(employeeIds) = 0) then
		set employeeIds = null;
    end if;
    if (departIds is not null and CHAR_LENGTH(departIds) = 0) then
		set departIds = null;
    end if;
   if (pmodelList is not null and CHAR_LENGTH(pmodelList) = 0) then
		set pmodelList = null;
    end if;
      if (brandid is not null and CHAR_LENGTH(brandid) = 0) then
		set brandid = null;
    end if;
      if (classid is not null and CHAR_LENGTH(classid) = 0) then
		set classid = null;
    end if;
    set tmpcount = 1;

    if CHAR_LENGTH(startdate) > 0 then
                
        set sqlstr = '$sqlheader$ ';
        set sqlstr = concat(sqlstr,'from optproduct as opp ');
        set sqlstr = concat(sqlstr,'left join opt on opp.optid = opt.id ');        
        set sqlstr = concat(sqlstr,'left join employee emp on opt.ownerid = emp.id left join (select
		  optproduct.id id,
		  if(',syscurrencyid,'=1,
		     if(opt.currencyid=1,
		        optproduct.rmbprice,
		        optproduct.dollarprice*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2))),
		     if(opt.currencyid=2,
		        optproduct.dollarprice,
		        optproduct.rmbprice*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2)))) converttotalprice,
		   if(',syscurrencyid,'=1,
		     if(opt.currencyid=1,
		        optproduct.rmbcost,
		        optproduct.dollarcost*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2))),
		     if(opt.currencyid=2,
		        optproduct.dollarcost,
		        optproduct.rmbcost*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2)))) converttotalcost,
		  if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) formula
			from optproduct 
			left join opt
			  on optproduct.optid = opt.id
			left join currencyconvert cc
			  ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
			left join (select cast(if(',syscurrencyid,'=1,intoajformula,ajtoinformula) as DECIMAL(14,2)) formula  from currencyconvert ORDER BY id desc limit 1) lasc
			  ON 1=1) convertoptproduct on opp.id=convertoptproduct.id
			left join currencyexchange cue on cue.id = opt.currencyid ');
		  set sqlstr = concat(sqlstr,	'left join optstage optsta on opt.stageid = optsta.id  left join  customer cto on opt.customerid =  cto.id  ');
		  set sqlstr = concat(sqlstr,'left join industry indu on cto.industryid = indu.id ');
		  set sqlstr = concat(sqlstr,'left join industrysub indusub on cto.industrysubid = indusub.id ');
        set sqlstr = concat(sqlstr,'left join product pro on pro.id = opp.productid ');
        set sqlstr = concat(sqlstr,'left join productbrand prob on prob.id = pro.brandid ');
        set sqlstr = concat(sqlstr,'left join productclass proc on proc.id = pro.classid where opt.isdelete = 0 and opp.productid>0 ');            
  
			
			if (optstatus =0 ) then
			   set sqlstr = concat(sqlstr,' and opt.optstatus in(\'1\',\'2\')');
			elseif (optstatus = 1 )then 
			   set sqlstr = concat(sqlstr,' and opt.optstatus=1');
			elseif optstatus = 2 then
			   set sqlstr = concat(sqlstr,' and opt.optstatus=2 and optsta.stage=1');
			end if;
			   
			
          if (employeeIds is not null and departIds is not null) then
            set sqlstr = concat(sqlstr,' and (opt.ownerid in (',employeeIds,') or emp.depid in (',departIds,'))');
		  else
			if employeeIds is not null then
				set sqlstr = concat(sqlstr, ' and opt.ownerid in (',employeeIds,')');
			elseif departIds is not null then
				set sqlstr = concat(sqlstr, ' and emp.depid  in (',departIds,')');
         end if;
        end if;

        if (faranchiseid is not null and faranchiseid > 0) then
			set sqlstr = concat(sqlstr, ' and opt.faranchiseid = ',faranchiseid);
        end if;
        
        
		  set sqlstr = concat(sqlstr, ' and opt.planoverdate between \'', startdate, '\' and \'', enddate, '\'');     
		  
		   
			if(brandid is not null) then
				set sqlstr = concat(sqlstr, ' and prob.id in (',brandid,')');
			end if;
			
			if(classid is not null) then
				set sqlstr = concat(sqlstr, ' and proc.id in (',classid,')');
			end if;
			   
			if(pmodelList is not null) then 
			   set sqlstr = concat(sqlstr, ' and  opp.productid in (',pmodelList,')');
			end if;
				
			
			if(industryid <= 0) then
				set sqlstringtotal = concat(sqlstr, ' and indu.isdelete = 0 ');
				set sqlstring = concat(sqlstr, ' and indu.isdelete = 0  group by indu.id ');
				set sqlheader = replace(sqlheader,'$className$','indu.industry');
            set sqlheader = replace(sqlheader,'$classNameEn$','indu.industryen');
            set sqlheader = replace(sqlheader,'$classId$',' indu.id');
			else  
				set sqlstringtotal = concat(sqlstr, ' and indu.id = ',industryid,' and (indusub.isdelete is null or indusub.isdelete = 0)');
				set sqlstring = concat(sqlstr, ' and indu.id = ',industryid,' and (indusub.isdelete is null or indusub.isdelete = 0) group by indusub.id ');
				set sqlheader = replace(sqlheader,'$className$','indusub.industrysub');
            set sqlheader = replace(sqlheader,'$classNameEn$','indusub.industrysuben');
            set sqlheader = replace(sqlheader,'$classId$',' indusub.id');
			end if;
       
		   
        if ispriceprofit = 1 then
          
		    set sqlstring = concat(sqlstring,') totatab order by totalprice desc ') ;
        	
        	 set sqlstringtotal = replace(sqlstringtotal,'$sqlheader$','select sum(convertoptproduct.converttotalprice*num*discount) into @totalvalue ');			 
        	 set sqlheader = replace(sqlheader,'$converttotalprice$','convertoptproduct.converttotalprice*num*discount');
        	 set sqlheader = replace(sqlheader,'$ispriceprofit$',1);
        	 set sqlheader = replace(sqlheader,'$statisticunit$',statisticunits);
			 set sqlheader = replace(sqlheader,'$lossprice$',' 0 lossprice');
        	 set sqlheader = replace(sqlheader,'$losspercent$',' 0 losspercent');  
        else 
          set sqlstringtotal = replace(sqlstring,'$sqlheader$',' select sum(if(totatab.totalprice>0,totatab.totalprice,0)), sum(if(totatab.totalprice<0,totatab.totalprice,0))  into @totalvalue 
						,@lossvalue from  (select sum((convertoptproduct.converttotalprice*discount-convertoptproduct.converttotalcost)*num) totalprice ');
			  	
		    set sqlstringtotal = concat(sqlstringtotal,') totatab order by totalprice desc ') ;
		    set sqlstring = concat(sqlstring,' ) totatab order by if(totalprice>0,totalprice,lossprice) desc ');
		   
   		 set sqlheader = replace(sqlheader,'$lossprice$','IFNULL(cast(if(sum($converttotalprice$)<0,sum($converttotalprice$),0)/$statisticunit$ as DECIMAL(14,2)),0) as lossprice ');
          set sqlheader = replace(sqlheader,'$losspercent$','IFNULL(cast(if(sum($converttotalprice$)<0,sum($converttotalprice$),0)/$lossvalue$ as DECIMAL(14,2)),0) as losspercent');
          set sqlheader = replace(sqlheader,'$converttotalprice$','((convertoptproduct.converttotalprice*discount)-convertoptproduct.converttotalcost)*num');
          set sqlheader = replace(sqlheader,'$ispriceprofit$',3);
          set sqlheader = replace(sqlheader,'$statisticunit$',statisticunits);
        end if;
        
        
        set @stmt = sqlstringtotal; 
		  PREPARE stmt FROM @stmt;
		  EXECUTE stmt;
         set totalvalue = ifnull(@totalvalue,0);
        	set lossvalue = ifnull(@lossvalue,0);
        
			set sqlheader = replace(sqlheader, '$totalvalue$', totalvalue);
			set sqlheader = replace(sqlheader, '$lossvalue$', lossvalue);
	        
	     	set sqlstring = replace(sqlstring, '$sqlheader$', sqlheader); 
			set @stmt = sqlstring; 
			PREPARE stmt FROM @stmt;
			EXECUTE stmt;        
			DEALLOCATE PREPARE stmt;
			
				  
		  select  ifNUll(sum(totalprice),0),ifNUll(sum(lossprice),0)  into @totalvalue,@lossvalue from chart_productanalysis_industry_table ;
		  insert into chart_productanalysis_industry_table (classId,className,classNameEn,totalprice,percent,lossprice,losspercent,ispriceprofit)
		  values('-1','汇总','Summary',@totalvalue,'1',@lossvalue,1,ispriceprofit);
			
	      select * from chart_productanalysis_industry_table;
	      
	end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `chart_productanalysis_productbubble_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `chart_productanalysis_productbubble_proc`(
	IN `syscurrencyid` int,
	IN `startdate` varchar(20),
	IN `enddate` varchar(20),
	IN `brandid` varchar(4000),
	IN `classid` varchar(4000),
	IN `pmodelList` varchar(4000),
	IN `optstatus` int,
	IN `employeeIds` varchar(4000),
	IN `departIds` varchar(4000),
	IN `faranchiseid` int,
	IN `loginEmployeeid` int
)
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
    declare totalvalue DECIMAL(14,2);
    declare lossvalue DECIMAL(14,2);
	 declare statisticunits DECIMAL(14,2);
	 
    set sqlstring = '';
	 select `statisticunit` into statisticunits from currencyexchange where id = syscurrencyid;
    set sqlheader = 'insert into chart_productanalysis_productbubble_table(classId,className,classNameen,price,grossprofit,num)  
	      select *from (select IFNULL($classId$,0) as classId,IFNULL($className$,\'Other\') as className,IFNULL($classNameEn$,\'Other\') as classNameen
		  ,IFNULL(cast(sum($price$)/$statisticunit$ as DECIMAL(14,2)),0) as price 
		  ,IFNULL(cast(sum($grossprofit$)/$statisticunit$ as DECIMAL(14,2)),0) as grossprofit 
		  ,IFNULL(sum($num$),0) as num';

	 drop table if exists `chart_productanalysis_productbubble_table`;
    
    create temporary table IF NOT EXISTS `chart_productanalysis_productbubble_table`
    (
        `id` int(10) NOT NULL AUTO_INCREMENT COMMENT 'ID',
        `classId` varchar(200) NOT NULL COMMENT '产品id',
        `className` varchar(200) NOT NULL  COMMENT '型号名称',
        `classNameEn` varchar(200) NOT NULL  COMMENT '型号名称 - 英文',
        `price` DECIMAL(14,2) NOT NULL COMMENT '总金额',
        `grossprofit`  DECIMAL(14,2) NOT NULL COMMENT '总毛利',
        `num`  int(20) NOT NULL COMMENT '总数量',
        PRIMARY KEY (`id`)
    );
    truncate table `chart_productanalysis_productbubble_table`;

	
    if (employeeIds is not null and CHAR_LENGTH(employeeIds) = 0) then
		set employeeIds = null;
    end if;
    if (departIds is not null and CHAR_LENGTH(departIds) = 0) then
		set departIds = null;
    end if;
     if (pmodelList is not null and CHAR_LENGTH(pmodelList) = 0) then
		set pmodelList = null;
    end if;
      if (brandid is not null and CHAR_LENGTH(brandid) = 0) then
		set brandid = null;
    end if;
      if (classid is not null and CHAR_LENGTH(classid) = 0) then
		set classid = null;
    end if;
    
    set tmpcount = 1;

    if CHAR_LENGTH(startdate) > 0 then
                
        set sqlstr = '$sqlheader$ ';
        set sqlstr = concat(sqlstr,'from optproduct as opp ');
        set sqlstr = concat(sqlstr,'left join opt on opp.optid = opt.id ');        
        set sqlstr = concat(sqlstr,'left join employee emp on opt.ownerid = emp.id left join (select
		  optproduct.id id,
		  if(',syscurrencyid,'=1,
		     if(opt.currencyid=1,
		        optproduct.rmbprice,
		        optproduct.dollarprice*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2))),
		     if(opt.currencyid=2,
		        optproduct.dollarprice,
		        optproduct.rmbprice*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2)))) converttotalprice,
		   if(',syscurrencyid,'=1,
		     if(opt.currencyid=1,
		        optproduct.rmbcost,
		        optproduct.dollarcost*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2))),
		     if(opt.currencyid=2,
		        optproduct.dollarcost,
		        optproduct.rmbcost*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2)))) converttotalcost,
		  if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) formula
			from optproduct 
			left join opt
			  on optproduct.optid = opt.id
			left join currencyconvert cc
			  ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
			left join (select cast(if(',syscurrencyid,'=1,intoajformula,ajtoinformula) as DECIMAL(14,2)) formula  from currencyconvert ORDER BY id desc limit 1) lasc
			  ON 1=1) convertoptproduct on opp.id=convertoptproduct.id
			left join currencyexchange cue on cue.id = opt.currencyid ');
		  set sqlstr = concat(sqlstr,	'left join optstage optsta on opt.stageid = optsta.id  left join  customer cto on opt.customerid =  cto.id  ');
        set sqlstr = concat(sqlstr,'left join product pro on pro.id = opp.productid ');
        set sqlstr = concat(sqlstr,'left join productbrand prob on prob.id = pro.brandid ');
        set sqlstr = concat(sqlstr,'left join productclass proc on proc.id = pro.classid where opt.isdelete = 0 and opp.productid>0 ');            
  
			
			if (optstatus =0 ) then
			   set sqlstr = concat(sqlstr,' and opt.optstatus in(\'1\',\'2\')');
			elseif (optstatus = 1 )then 
			   set sqlstr = concat(sqlstr,' and opt.optstatus=1');
			elseif optstatus = 2 then
			   set sqlstr = concat(sqlstr,' and opt.optstatus=2 and optsta.stage=1');
			end if;
			   
			
          if (employeeIds is not null and departIds is not null) then
            set sqlstr = concat(sqlstr,' and (opt.ownerid in (',employeeIds,') or emp.depid in (',departIds,'))');
		  else
			if employeeIds is not null then
				set sqlstr = concat(sqlstr, ' and opt.ownerid in (',employeeIds,')');
			elseif departIds is not null then
				set sqlstr = concat(sqlstr, ' and emp.depid  in (',departIds,')');
         end if;
        end if;

        if (faranchiseid is not null and faranchiseid > 0) then
			set sqlstr = concat(sqlstr, ' and opt.faranchiseid = ',faranchiseid);
        end if;
        
        
		  set sqlstr = concat(sqlstr, ' and opt.planoverdate between \'', startdate, '\' and \'', enddate, '\'');     
		  
		    
			if(brandid is not null) then
				set sqlstr = concat(sqlstr, ' and prob.id in (',brandid,')');
			end if;
			
			if(classid is not null) then
				set sqlstr = concat(sqlstr, ' and proc.id in (',classid,')');
			end if;
			   
			if(pmodelList is not null) then 
			   set sqlstr = concat(sqlstr, ' and  opp.productid in (',pmodelList,')');
			end if;
			
			
		  if(brandid is null and classid is null and pmodelList is null) then 
		  		set sqlstringtotal = concat(sqlstr, ' and prob.isdelete = 0');
		     	set sqlstring = concat(sqlstr, ' and prob.isdelete = 0  group by prob.id');
				set sqlheader = replace(sqlheader,'$className$','prob.brandname');
            set sqlheader = replace(sqlheader,'$classNameEn$','prob.brandnameen');
            set sqlheader = replace(sqlheader,'$classId$',' prob.id');
         end if;   
            
        
        if (brandid is not null and classid is null  and pmodelList is null) then
				set sqlstringtotal = concat(sqlstr, ' and proc.isdelete = 0');
				set sqlstring = concat(sqlstr, ' and proc.isdelete = 0 group by proc.id ');
				set sqlheader = replace(sqlheader,'$className$','proc.classname');
            set sqlheader = replace(sqlheader,'$classNameEn$','proc.classnameen');
            set sqlheader = replace(sqlheader,'$classId$',' proc.id');
        end if;   
            
        
        if (classid is not null and pmodelList is null) then
				set sqlstringtotal = concat(sqlstr, ' and pro.isdelete = 0');
				set sqlstring = concat(sqlstr, ' and pro.isdelete = 0 group by opp.productid ');
				set sqlheader = replace(sqlheader,'$className$','pro.productmodel');
            set sqlheader = replace(sqlheader,'$classNameEn$','pro.productmodel');
            set sqlheader = replace(sqlheader,'$classId$',' opp.productid');
         end if;
                  
         
        if(pmodelList is not null) then 
         	set sqlstringtotal = concat(sqlstr, ' ');
				set sqlstring = concat(sqlstr, ' group by opp.productid ');
				set sqlheader = replace(sqlheader,'$className$','pro.productmodel');
            set sqlheader = replace(sqlheader,'$classNameEn$','pro.productmodel');
            set sqlheader = replace(sqlheader,'$classId$',' opp.productid');
            
        end if;
            
			
				
			set sqlstring = concat(sqlstring, ' ) totatab order by price desc , grossprofit desc');
         set sqlheader = replace(sqlheader,'$statisticunit$',statisticunits);
         set sqlheader = replace(sqlheader,'$price$','convertoptproduct.converttotalprice*num*discount');
      	set sqlheader = replace(sqlheader,'$grossprofit$','((convertoptproduct.converttotalprice*discount)-convertoptproduct.converttotalcost)*num');
      	set sqlheader = replace(sqlheader,'$num$','num');
      
	        
	      set sqlstring = replace(sqlstring, '$sqlheader$', sqlheader); 
			set @stmt = sqlstring; 
			PREPARE stmt FROM @stmt;
			EXECUTE stmt;        
			DEALLOCATE PREPARE stmt;
			
		  
		  select * from chart_productanalysis_productbubble_table;
	end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `chart_productanalysis_productdistribution_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `chart_productanalysis_productdistribution_proc`(
	IN `syscurrencyid` int,
	IN `startdate` varchar(20),
	IN `enddate` varchar(20),
	IN `brandid` varchar(4000),
	IN `classid` varchar(4000),
	IN `pmodelList` varchar(4000),
	IN `optstatus` int,
	IN `employeeIds` varchar(4000),
	IN `departIds` varchar(4000),
	IN `faranchiseid` int,
	IN `loginEmployeeid` int,
	IN `ispriceprofit` int ,
	IN `isexportorshow` int
)
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
    declare totalvalue DECIMAL(14,2);
    declare lossvalue DECIMAL(14,2);
	 declare statisticunits DECIMAL(14,2);
	 declare ken varchar(20);
	 
    set sqlstring = '';
	select `statisticunit` into statisticunits from currencyexchange where id = syscurrencyid;
    set sqlheader = 'insert into chart_productanalysis_productdistribution_table(classId,className,classNameEn,totalprice,percent,lossprice,losspercent,ispriceprofit)  
	    select *from (select IFNULL($classId$,0) as classId,IFNULL($className$,\'Other\') as className,IFNULL($classNameEn$,\'Other\') as classNameEn 
		  ,IFNULL(cast(if(sum($converttotalprice$)>0,sum($converttotalprice$),0)/$statisticunit$ as DECIMAL(14,2)),0) as totalprice 
		  ,IFNULL(cast(if(sum($converttotalprice$)>0,sum($converttotalprice$),0)/$totalvalue$ as DECIMAL(14,2)),0) as percent,$lossprice$,$losspercent$,$ispriceprofit$';
		  
	 drop table if exists `chart_productanalysis_productdistribution_table`;
    
    create temporary table IF NOT EXISTS `chart_productanalysis_productdistribution_table`
    (
        `id` int(10) NOT NULL AUTO_INCREMENT COMMENT 'ID',
        `classId` varchar(200) NOT NULL COMMENT '品牌/类别id',
        `className` varchar(200) NOT NULL  COMMENT '品牌/类别/型号名称',
        `classNameEn` varchar(200) NOT NULL  COMMENT '品牌/类别/型号名称-英文',
        `totalprice` DECIMAL(14,2) NOT NULL COMMENT '总金额/总毛利/总数量',
        `percent` DECIMAL(14,2) NOT NULL COMMENT '占比',
        `lossprice` DECIMAL(14,2) NOT NULL COMMENT '亏损的毛利',
        `losspercent` DECIMAL(14,2) NOT NULL COMMENT '亏损占比',
        `ispriceprofit` int(10) NOT NULL COMMENT '金额/数量/毛利',
        PRIMARY KEY (`id`)
    );
    truncate table `chart_productanalysis_productdistribution_table`;

	
    if (employeeIds is not null and CHAR_LENGTH(employeeIds) = 0) then
		set employeeIds = null;
    end if;
    if (departIds is not null and CHAR_LENGTH(departIds) = 0) then
		set departIds = null;
    end if;
     if (pmodelList is not null and CHAR_LENGTH(pmodelList) = 0) then
		set pmodelList = null;
    end if;
      if (brandid is not null and CHAR_LENGTH(brandid) = 0) then
		set brandid = null;
    end if;
      if (classid is not null and CHAR_LENGTH(classid) = 0) then
		set classid = null;
    end if;
    
    set tmpcount = 1;

    if CHAR_LENGTH(startdate) > 0 then
                
        set sqlstr = '$sqlheader$ ';
        set sqlstr = concat(sqlstr,'from optproduct as opp ');
        set sqlstr = concat(sqlstr,'left join opt on opp.optid = opt.id ');        
        set sqlstr = concat(sqlstr,'left join employee emp on opt.ownerid = emp.id left join (select
		  optproduct.id id,
		  if(',syscurrencyid,'=1,
		     if(opt.currencyid=1,
		        optproduct.rmbprice,
		        optproduct.dollarprice*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2))),
		     if(opt.currencyid=2,
		        optproduct.dollarprice,
		        optproduct.rmbprice*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2)))) converttotalprice,
		   if(',syscurrencyid,'=1,
		     if(opt.currencyid=1,
		        optproduct.rmbcost,
		        optproduct.dollarcost*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2))),
		     if(opt.currencyid=2,
		        optproduct.dollarcost,
		        optproduct.rmbcost*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2)))) converttotalcost,
		  if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) formula
			from optproduct 
			left join opt
			  on optproduct.optid = opt.id
			left join currencyconvert cc
			  ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
			left join (select cast(if(',syscurrencyid,'=1,intoajformula,ajtoinformula) as DECIMAL(14,2)) formula  from currencyconvert ORDER BY id desc limit 1) lasc
			  ON 1=1) convertoptproduct on opp.id=convertoptproduct.id
			left join currencyexchange cue on cue.id = opt.currencyid ');
		  set sqlstr = concat(sqlstr,	'left join optstage optsta on opt.stageid = optsta.id ');
        set sqlstr = concat(sqlstr,'left join product pro on pro.id = opp.productid ');
        set sqlstr = concat(sqlstr,'left join productbrand prob on prob.id = pro.brandid ');
        set sqlstr = concat(sqlstr,'left join productclass proc on proc.id = pro.classid where opt.isdelete = 0 and opp.productid>0 ');            
  
			
			if (optstatus =0 ) then
			   set sqlstr = concat(sqlstr,' and opt.optstatus in(\'1\',\'2\')');
			elseif (optstatus = 1 )then 
			   set sqlstr = concat(sqlstr,' and opt.optstatus=1');
			elseif optstatus = 2 then
			   set sqlstr = concat(sqlstr,' and opt.optstatus=2 and optsta.stage=1');
			end if;
			   
			
          if (employeeIds is not null and departIds is not null) then
            set sqlstr = concat(sqlstr,' and (opt.ownerid in (',employeeIds,') or emp.depid in (',departIds,'))');
		  else
			if employeeIds is not null then
				set sqlstr = concat(sqlstr, ' and opt.ownerid in (',employeeIds,')');
			elseif departIds is not null then
				set sqlstr = concat(sqlstr, ' and emp.depid  in (',departIds,')');
         end if;
        end if;

        if (faranchiseid is not null and faranchiseid > 0) then
			set sqlstr = concat(sqlstr, ' and opt.faranchiseid = ',faranchiseid);
        end if;
        
        
		  set sqlstr = concat(sqlstr, ' and opt.planoverdate between \'', startdate, '\' and \'', enddate, '\'');     
		  		
		  
			if(brandid is not null) then
				set sqlstr = concat(sqlstr, ' and prob.id in (',brandid,')');
			end if;
			
			if(classid is not null) then
				set sqlstr = concat(sqlstr, ' and proc.id in (',classid,')');
			end if;
			   
			if(pmodelList is not null) then 
			   set sqlstr = concat(sqlstr, ' and  opp.productid in (',pmodelList,')');
			end if;
			
			
		  if(brandid is null and classid is null and pmodelList is null) then 
		  		set sqlstringtotal = concat(sqlstr, ' and prob.isdelete = 0');
		     	set sqlstring = concat(sqlstr, ' and prob.isdelete = 0  group by prob.id');
				set sqlheader = replace(sqlheader,'$className$','prob.brandname');
            set sqlheader = replace(sqlheader,'$classNameEn$','prob.brandnameen');
            set sqlheader = replace(sqlheader,'$classId$',' prob.id');
         end if;   
            
        
        if (brandid is not null and classid is null  and pmodelList is null) then
				set sqlstringtotal = concat(sqlstr, ' and proc.isdelete = 0');
				set sqlstring = concat(sqlstr, ' and proc.isdelete = 0 group by proc.id ');
				set sqlheader = replace(sqlheader,'$className$','proc.classname');
            set sqlheader = replace(sqlheader,'$classNameEn$','proc.classnameen');
            set sqlheader = replace(sqlheader,'$classId$',' proc.id');
        end if;   
            
        
        if (classid is not null and pmodelList is null) then
				set sqlstringtotal = concat(sqlstr, ' and pro.isdelete = 0');
				set sqlstring = concat(sqlstr, ' and pro.isdelete = 0 group by opp.productid ');
				set sqlheader = replace(sqlheader,'$className$','pro.productmodel');
            set sqlheader = replace(sqlheader,'$classNameEn$','pro.productmodel');
            set sqlheader = replace(sqlheader,'$classId$',' opp.productid');
         end if;
                  
         
        if(pmodelList is not null) then 
         	set sqlstringtotal = concat(sqlstr, ' ');
				set sqlstring = concat(sqlstr, ' group by opp.productid ');
				set sqlheader = replace(sqlheader,'$className$','pro.productmodel');
            set sqlheader = replace(sqlheader,'$classNameEn$','pro.productmodel');
            set sqlheader = replace(sqlheader,'$classId$',' opp.productid');
            
        end if;
        
		    
			if(classid is not null  and pmodelList is null and isexportorshow = 1) then 
				set isexportorshow = 1;
			else 
			  set isexportorshow = 2;
		   end if;       
		       
		   
        if ispriceprofit = 1 then
        
         	
		    set sqlstring = concat(sqlstring,' order by totalprice desc $limit$) totatab') ;
        	
        	 set sqlstringtotal = replace(sqlstringtotal,'$sqlheader$','select sum(convertoptproduct.converttotalprice*num*discount) into @totalvalue ');
         
        	  
        	 if isexportorshow = 1 then
					 set sqlstring = replace(sqlstring,'$limit$','limit 10') ;
        	 		 set sqlstringtotal = replace(sqlstring,'$sqlheader$','select sum(totatab.totalprice)  into @totalvalue from  (select sum(convertoptproduct.converttotalprice*num*discount) totalprice ');
			 end if;	 
			 
			 set sqlstring = replace(sqlstring,'$limit$','') ;
        	 set sqlheader = replace(sqlheader,'$converttotalprice$','convertoptproduct.converttotalprice*num*discount');
        	 set sqlheader = replace(sqlheader,'$ispriceprofit$',1);
        	 set sqlheader = replace(sqlheader,'$statisticunit$',statisticunits);
          set sqlheader = replace(sqlheader,'$lossprice$',' 0 lossprice');
        	 set sqlheader = replace(sqlheader,'$losspercent$',' 0 losspercent');
        	 alter table `chart_productanalysis_productdistribution_table` MODIFY  `totalprice`  DECIMAL(14,2);
        elseif ispriceprofit = 2 then 
        
        	 	
		    set sqlstring = concat(sqlstring,' order by totalprice desc $limit$) totatab') ;
          set sqlstringtotal = replace(sqlstringtotal,'$sqlheader$','select sum(num) into @totalvalue ');
          
          	
        	 if isexportorshow = 1 then
					 set sqlstring = replace(sqlstring,'$limit$','') ;
        	 		 set sqlstringtotal = replace(sqlstring,'$sqlheader$','select sum(totatab.totalprice)  into @totalvalue from  (select sum(num)  totalprice ');
			 end if;	
			 
			 set sqlstring = replace(sqlstring,'$limit$','') ;
          set sqlheader = replace(sqlheader,'$converttotalprice$','num');
          set sqlheader = replace(sqlheader,'$ispriceprofit$',2);
          set sqlheader = replace(sqlheader,'$statisticunit$',1);
          set sqlheader = replace(sqlheader,'$lossprice$',' 0 lossprice');
        	 set sqlheader = replace(sqlheader,'$losspercent$',' 0 losspercent');
          alter table `chart_productanalysis_productdistribution_table` MODIFY  `totalprice`  int(20);
        else 
        	
			  set sqlstringtotal = replace(sqlstring,'$sqlheader$',' select sum(if(totatab.totalprice>0,totatab.totalprice,0)), sum(if(totatab.totalprice<0,totatab.totalprice,0))  into @totalvalue 
						,@lossvalue from  (select sum((convertoptproduct.converttotalprice*discount-convertoptproduct.converttotalcost)*num) totalprice  ');
			  	
		     set sqlstringtotal = concat(sqlstringtotal,' order by totalprice desc $limit$) totatab  ') ;
		     set sqlstring = concat(sqlstring,' ) totatab order by if(totalprice>0,totalprice,lossprice) desc ');
		     
			   
        	 if isexportorshow = 1 then
					 set sqlstring = concat(sqlstring,' limit 10 ');
					 set sqlstringtotal = replace(sqlstringtotal,'$limit$',' limit 10 ');
			 end if;	
			 
			 set sqlstringtotal = replace(sqlstringtotal,'$limit$',' ');
			 set sqlheader = replace(sqlheader,'$lossprice$','IFNULL(cast(if(sum($converttotalprice$)<0,sum($converttotalprice$),0)/$statisticunit$ as DECIMAL(14,2)),0) as lossprice ');
          set sqlheader = replace(sqlheader,'$losspercent$','IFNULL(cast(if(sum($converttotalprice$)<0,sum($converttotalprice$),0)/$lossvalue$ as DECIMAL(14,2)),0) as losspercent');
          set sqlheader = replace(sqlheader,'$converttotalprice$','((convertoptproduct.converttotalprice*discount)-convertoptproduct.converttotalcost)*num');
          set sqlheader = replace(sqlheader,'$ispriceprofit$',3);
          set sqlheader = replace(sqlheader,'$statisticunit$',statisticunits);
          alter table `chart_productanalysis_productdistribution_table` MODIFY  `totalprice`  DECIMAL(14,2);
        end if;
        
        set @stmt = sqlstringtotal; 
		PREPARE stmt FROM @stmt;
		EXECUTE stmt;
        set totalvalue = ifnull(@totalvalue,0);
        set lossvalue = ifnull(@lossvalue,0);
        
		set sqlheader = replace(sqlheader, '$totalvalue$', totalvalue);
		set sqlheader = replace(sqlheader, '$lossvalue$', lossvalue);
        
        set sqlstring = replace(sqlstring, '$sqlheader$', sqlheader);
      
          
		set @stmt = sqlstring; 
	
		PREPARE stmt FROM @stmt;
		EXECUTE stmt;        
		DEALLOCATE PREPARE stmt;
		
		  
		  select  ifNUll(sum(totalprice),0),ifNUll(sum(lossprice),0)  into @totalvalue,@lossvalue from chart_productanalysis_productdistribution_table ;
		  insert into chart_productanalysis_productdistribution_table (classId,className,classNameEn,totalprice,percent,lossprice,losspercent,ispriceprofit)
		  values('-1','汇总','Summary',@totalvalue,'1',@lossvalue,1,ispriceprofit);
		
        select * from chart_productanalysis_productdistribution_table;
	end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `chart_productanalysis_region_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `chart_productanalysis_region_proc`(
	IN `syscurrencyid` int,
	IN `startdate` varchar(20),
	IN `enddate` varchar(20),
	IN `brandid` varchar(4000),
	IN `classid` varchar(4000),
	IN `pmodelList` varchar(4000),
	IN `optstatus` int,
	IN `employeeIds` varchar(4000),
	IN `departIds` varchar(4000),
	IN `faranchiseid` int,
	IN `loginEmployeeid` int,
	IN `ispriceprofit` int ,
	IN `countryid` int,
	IN `regionid` int,
	IN `provinceid` int
	
)
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
    declare totalvalue DECIMAL(14,2);
    declare lossvalue DECIMAL(14,2);
	 declare statisticunits DECIMAL(14,2);
	 
    set sqlstring = '';
	select `statisticunit` into statisticunits from currencyexchange where id = syscurrencyid;
    set sqlheader = 'insert into chart_productanalysis_region_table(classId,className,classNameEn,totalprice,percent,lossprice,losspercent,ispriceprofit)  
	     select *from (select IFNULL($classId$,0) as classId,IFNULL($className$,\'Other\') as className,IFNULL($classNameEn$,\'Other\') as classNameEn 
		  ,IFNULL(cast(if(sum($converttotalprice$)>0,sum($converttotalprice$),0)/$statisticunit$ as DECIMAL(14,2)),0) as totalprice 
		  ,IFNULL(cast(if(sum($converttotalprice$)>0,sum($converttotalprice$),0)/$totalvalue$ as DECIMAL(14,2)),0) as percent,$lossprice$,$losspercent$,$ispriceprofit$';
		  
	drop table if exists `chart_productanalysis_region_table`;
    
    create temporary table IF NOT EXISTS `chart_productanalysis_region_table`
    (
        `id` int(10) NOT NULL AUTO_INCREMENT COMMENT 'ID',
        `classId` varchar(200) NOT NULL COMMENT '地域id',
        `className` varchar(200) NOT NULL  COMMENT '地域名称',
        `classNameEn` varchar(200) NOT NULL  COMMENT '地域名称-英文',
        `totalprice` DECIMAL(14,2) NOT NULL COMMENT '总金额/总毛利',
        `percent` DECIMAL(14,2) NOT NULL COMMENT '占比',
        `lossprice` DECIMAL(14,2) NOT NULL COMMENT '亏损的毛利',
        `losspercent` DECIMAL(14,2) NOT NULL COMMENT '亏损占比',
        `ispriceprofit` int(10) NOT NULL COMMENT '金额/毛利',
        PRIMARY KEY (`id`)
    );
    truncate table `chart_productanalysis_region_table`;

	
    if (employeeIds is not null and CHAR_LENGTH(employeeIds) = 0) then
		set employeeIds = null;
    end if;
    if (departIds is not null and CHAR_LENGTH(departIds) = 0) then
		set departIds = null;
    end if;
     if (pmodelList is not null and CHAR_LENGTH(pmodelList) = 0) then
		set pmodelList = null;
    end if;
      if (brandid is not null and CHAR_LENGTH(brandid) = 0) then
		set brandid = null;
    end if;
      if (classid is not null and CHAR_LENGTH(classid) = 0) then
		set classid = null;
    end if;
    
    set tmpcount = 1;

    if CHAR_LENGTH(startdate) > 0 then
                
        set sqlstr = '$sqlheader$ ';
        set sqlstr = concat(sqlstr,'from optproduct as opp ');
        set sqlstr = concat(sqlstr,'left join opt on opp.optid = opt.id ');        
        set sqlstr = concat(sqlstr,'left join employee emp on opt.ownerid = emp.id left join (select
		  optproduct.id id,
		  if(',syscurrencyid,'=1,
		     if(opt.currencyid=1,
		        optproduct.rmbprice,
		        optproduct.dollarprice*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2))),
		     if(opt.currencyid=2,
		        optproduct.dollarprice,
		        optproduct.rmbprice*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2)))) converttotalprice,
		   if(',syscurrencyid,'=1,
		     if(opt.currencyid=1,
		        optproduct.rmbcost,
		        optproduct.dollarcost*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2))),
		     if(opt.currencyid=2,
		        optproduct.dollarcost,
		        optproduct.rmbcost*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2)))) converttotalcost,
		  if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) formula
			from optproduct 
			left join opt
			  on optproduct.optid = opt.id
			left join currencyconvert cc
			  ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
			left join (select cast(if(',syscurrencyid,'=1,intoajformula,ajtoinformula) as DECIMAL(14,2)) formula  from currencyconvert ORDER BY id desc limit 1) lasc
			  ON 1=1) convertoptproduct on opp.id=convertoptproduct.id
			left join currencyexchange cue on cue.id = opt.currencyid ');
		  set sqlstr = concat(sqlstr,	'left join optstage optsta on opt.stageid = optsta.id  left join  customer cto on opt.customerid =  cto.id  ');
		  set sqlstr = concat(sqlstr,'left join country ctry on cto.countryid = ctry.id ');
		  set sqlstr = concat(sqlstr,'left join region reg on cto.regionid = reg.id ');
		  set sqlstr = concat(sqlstr,'left join province prov on cto.provinceid = prov.id ');
		  set sqlstr = concat(sqlstr,'left join city city on cto.cityid = city.id ');
        set sqlstr = concat(sqlstr,'left join product pro on pro.id = opp.productid ');
        set sqlstr = concat(sqlstr,'left join productbrand prob on prob.id = pro.brandid ');
        set sqlstr = concat(sqlstr,'left join productclass proc on proc.id = pro.classid where opt.isdelete = 0 and opp.productid>0 ');            
  
			
			if (optstatus =0 ) then
			   set sqlstr = concat(sqlstr,' and opt.optstatus in(\'1\',\'2\')');
			elseif (optstatus = 1 )then 
			   set sqlstr = concat(sqlstr,' and opt.optstatus=1');
			elseif optstatus = 2 then
			   set sqlstr = concat(sqlstr,' and opt.optstatus=2 and optsta.stage=1');
			end if;
			   
			
          if (employeeIds is not null and departIds is not null) then
            set sqlstr = concat(sqlstr,' and (opt.ownerid in (',employeeIds,') or emp.depid in (',departIds,'))');
		  else
			if employeeIds is not null then
				set sqlstr = concat(sqlstr, ' and opt.ownerid in (',employeeIds,')');
			elseif departIds is not null then
				set sqlstr = concat(sqlstr, ' and emp.depid  in (',departIds,')');
         end if;
        end if;
  	
		  
        if (faranchiseid is not null and faranchiseid > 0) then
			set sqlstr = concat(sqlstr, ' and opt.faranchiseid = ',faranchiseid);
        end if;
        
        
		  set sqlstr = concat(sqlstr, ' and opt.planoverdate between \'', startdate, '\' and \'', enddate, '\'');     
		  
		   
			if(brandid is not null) then
				set sqlstr = concat(sqlstr, ' and prob.id in (',brandid,')');
			end if;
			
			if(classid is not null) then
				set sqlstr = concat(sqlstr, ' and proc.id in (',classid,')');
			end if;
			   
			if(pmodelList is not null) then 
			   set sqlstr = concat(sqlstr, ' and  opp.productid in (',pmodelList,')');
			end if;
			
			
			if(countryid <= 0) then
				set sqlstringtotal = concat(sqlstr, ' and ctry.isdelete = 0 ');
				set sqlstring = concat(sqlstr, ' and ctry.isdelete = 0  group by ctry.id ');
				set sqlheader = replace(sqlheader,'$className$','ctry.country');
            set sqlheader = replace(sqlheader,'$classNameEn$','ctry.countryen');
            set sqlheader = replace(sqlheader,'$classId$',' ctry.id');
			elseif(regionid <= 0 ) then
					set sqlstringtotal = concat(sqlstr, ' and ctry.id = ',countryid,' and reg.isdelete = 0 ');
					set sqlstring = concat(sqlstr, ' and ctry.id = ',countryid,' and reg.isdelete = 0  group by reg.id ');
					set sqlheader = replace(sqlheader,'$className$','reg.region');
            	set sqlheader = replace(sqlheader,'$classNameEn$','reg.regionen');
            	set sqlheader = replace(sqlheader,'$classId$',' reg.id');
			elseif(provinceid <= 0) then
					set sqlstringtotal = concat(sqlstr, ' and ctry.id = ',countryid,' and reg.id = ',regionid,' and prov.isdelete = 0 ');
					set sqlstring = concat(sqlstr, ' and ctry.id = ',countryid,' and reg.id = ',regionid,' and prov.isdelete = 0  group by prov.id ');
					set sqlheader = replace(sqlheader,'$className$','prov.province');
            	set sqlheader = replace(sqlheader,'$classNameEn$','prov.provinceen');
            	set sqlheader = replace(sqlheader,'$classId$',' prov.id');
         else
					set sqlstringtotal = concat(sqlstr, ' and ctry.id = ',countryid,' and reg.id = ',regionid,' and  prov.id = ',provinceid, ' and city.isdelete = 0');
					set sqlstring = concat(sqlstr, ' and ctry.id = ',countryid,' and reg.id = ',regionid,' and  prov.id = ',provinceid, ' and city.isdelete = 0 group by city.id ');
					set sqlheader = replace(sqlheader,'$className$','city.city');
            	set sqlheader = replace(sqlheader,'$classNameEn$','city.cityen');
            	set sqlheader = replace(sqlheader,'$classId$',' city.id');
			end if;

		   
        if ispriceprofit = 1 then
          
		    set sqlstring = concat(sqlstring,') totatab order by totalprice desc ') ;
        	
        	 set sqlstringtotal = replace(sqlstringtotal,'$sqlheader$','select sum(convertoptproduct.converttotalprice*num*discount) into @totalvalue ');			 
        	 set sqlheader = replace(sqlheader,'$converttotalprice$','convertoptproduct.converttotalprice*num*discount');
        	 set sqlheader = replace(sqlheader,'$ispriceprofit$',1);
        	 set sqlheader = replace(sqlheader,'$statisticunit$',statisticunits);
			 set sqlheader = replace(sqlheader,'$lossprice$',' 0 lossprice');
        	 set sqlheader = replace(sqlheader,'$losspercent$',' 0 losspercent');    
        else 
          set sqlstringtotal = replace(sqlstring,'$sqlheader$',' select sum(if(totatab.totalprice>0,totatab.totalprice,0)), sum(if(totatab.totalprice<0,totatab.totalprice,0))  into @totalvalue 
						,@lossvalue from  (select sum((convertoptproduct.converttotalprice*discount-convertoptproduct.converttotalcost)*num) totalprice ');
			  	
		    set sqlstringtotal = concat(sqlstringtotal,') totatab order by totalprice desc ') ;
		    set sqlstring = concat(sqlstring,' ) totatab order by if(totalprice>0,totalprice,lossprice) desc ');
		   
   		 set sqlheader = replace(sqlheader,'$lossprice$','IFNULL(cast(if(sum($converttotalprice$)<0,sum($converttotalprice$),0)/$statisticunit$ as DECIMAL(14,2)),0) as lossprice ');
          set sqlheader = replace(sqlheader,'$losspercent$','IFNULL(cast(if(sum($converttotalprice$)<0,sum($converttotalprice$),0)/$lossvalue$ as DECIMAL(14,2)),0) as losspercent');
          set sqlheader = replace(sqlheader,'$converttotalprice$','((convertoptproduct.converttotalprice*discount)-convertoptproduct.converttotalcost)*num');
          set sqlheader = replace(sqlheader,'$ispriceprofit$',3);
          set sqlheader = replace(sqlheader,'$statisticunit$',statisticunits);
        end if;
        
        
        set @stmt = sqlstringtotal; 
		  PREPARE stmt FROM @stmt;
		  EXECUTE stmt;
         set totalvalue = ifnull(@totalvalue,0);
        	set lossvalue = ifnull(@lossvalue,0);
        
			set sqlheader = replace(sqlheader, '$totalvalue$', totalvalue);
			set sqlheader = replace(sqlheader, '$lossvalue$', lossvalue);
	        
	     set sqlstring = replace(sqlstring, '$sqlheader$', sqlheader); 
			set @stmt = sqlstring; 
			PREPARE stmt FROM @stmt;
			EXECUTE stmt;        
			DEALLOCATE PREPARE stmt;
			
				  
		  select  ifNUll(sum(totalprice),0),ifNUll(sum(lossprice),0)  into @totalvalue,@lossvalue from chart_productanalysis_region_table ;
		  insert into chart_productanalysis_region_table (classId,className,classNameEn,totalprice,percent,lossprice,losspercent,ispriceprofit)
		  values('-1','汇总','Summary',@totalvalue,'1',@lossvalue,1,ispriceprofit);
			
	      select * from chart_productanalysis_region_table;
	      
	end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `chart_productanalysis_toptencustomer_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `chart_productanalysis_toptencustomer_proc`(
	IN `syscurrencyid` int,
	IN `startdate` varchar(20),
	IN `enddate` varchar(20),
	IN `brandid` varchar(4000),
	IN `classid` varchar(4000),
	IN `pmodelList` varchar(4000),
	IN `optstatus` int,
	IN `employeeIds` varchar(4000),
	IN `departIds` varchar(4000),
	IN `faranchiseid` int,
	IN `loginEmployeeid` int,
	IN `ispriceprofit` int ,
	IN `isexportorshow` int
)
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
    declare totalvalue DECIMAL(14,2);
    declare lossvalue DECIMAL(14,2);
	 declare statisticunits DECIMAL(14,2);
	 
    set sqlstring = '';
	select `statisticunit` into statisticunits from currencyexchange where id = syscurrencyid;
    set sqlheader = 'insert into chart_productanalysis_toptencustomer_table(classId,className,classNameEn,totalprice,percent,lossprice,losspercent,ispriceprofit)  
	     select *from (select IFNULL($classId$,0) as classId,IFNULL($className$,\'Other\') as className,IFNULL($classNameEn$,\'Other\') as classNameEn 
		  ,IFNULL(cast(if(sum($converttotalprice$)>0,sum($converttotalprice$),0)/$statisticunit$ as DECIMAL(14,2)),0) as totalprice 
		  ,IFNULL(cast(if(sum($converttotalprice$)>0,sum($converttotalprice$),0)/$totalvalue$ as DECIMAL(14,2)),0) as percent,$lossprice$,$losspercent$,$ispriceprofit$';
		  
	 drop table if exists `chart_productanalysis_toptencustomer_table`;
    
    create temporary table IF NOT EXISTS `chart_productanalysis_toptencustomer_table`
    (
        `id` int(10) NOT NULL AUTO_INCREMENT COMMENT 'ID',	
        `classId` varchar(200) NOT NULL COMMENT '行业id',
        `className` varchar(200) NOT NULL  COMMENT '行业名称',
        `classNameEn` varchar(200) NOT NULL  COMMENT '行业名称-英文',
        `totalprice` DECIMAL(14,2) NOT NULL COMMENT '总金额/总毛利',
        `percent` DECIMAL(14,2) NOT NULL COMMENT '占比',
        `lossprice` DECIMAL(14,2) NOT NULL COMMENT '亏损的毛利',
        `losspercent` DECIMAL(14,2) NOT NULL COMMENT '亏损占比',
        `ispriceprofit` int(10) NOT NULL COMMENT '金额/毛利',
        PRIMARY KEY (`id`)
    );
    truncate table `chart_productanalysis_toptencustomer_table`;

	
    if (employeeIds is not null and CHAR_LENGTH(employeeIds) = 0) then
		set employeeIds = null;
    end if;
    if (departIds is not null and CHAR_LENGTH(departIds) = 0) then
		set departIds = null;
    end if;
     if (pmodelList is not null and CHAR_LENGTH(pmodelList) = 0) then
		set pmodelList = null;
    end if;
      if (brandid is not null and CHAR_LENGTH(brandid) = 0) then
		set brandid = null;
    end if;
      if (classid is not null and CHAR_LENGTH(classid) = 0) then
		set classid = null;
    end if;
    set tmpcount = 1;

    if CHAR_LENGTH(startdate) > 0 then
                
        set sqlstr = '$sqlheader$ ';
        set sqlstr = concat(sqlstr,'from optproduct as opp ');
        set sqlstr = concat(sqlstr,'left join opt on opp.optid = opt.id ');        
        set sqlstr = concat(sqlstr,'left join employee emp on opt.ownerid = emp.id left join (select
		  optproduct.id id,
		  if(',syscurrencyid,'=1,
		     if(opt.currencyid=1,
		        optproduct.rmbprice,
		        optproduct.dollarprice*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2))),
		     if(opt.currencyid=2,
		        optproduct.dollarprice,
		        optproduct.rmbprice*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2)))) converttotalprice,
		   if(',syscurrencyid,'=1,
		     if(opt.currencyid=1,
		        optproduct.rmbcost,
		        optproduct.dollarcost*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2))),
		     if(opt.currencyid=2,
		        optproduct.dollarcost,
		        optproduct.rmbcost*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2)))) converttotalcost,
		  if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) formula
			from optproduct 
			left join opt
			  on optproduct.optid = opt.id
			left join currencyconvert cc
			  ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
			left join (select cast(if(',syscurrencyid,'=1,intoajformula,ajtoinformula) as DECIMAL(14,2)) formula  from currencyconvert ORDER BY id desc limit 1) lasc
			  ON 1=1) convertoptproduct on opp.id=convertoptproduct.id
			left join currencyexchange cue on cue.id = opt.currencyid ');
		  set sqlstr = concat(sqlstr,	'left join optstage optsta on opt.stageid = optsta.id  left join  customer cto on opt.customerid =  cto.id  ');
        set sqlstr = concat(sqlstr,'left join product pro on pro.id = opp.productid ');
        set sqlstr = concat(sqlstr,'left join productbrand prob on prob.id = pro.brandid ');
        set sqlstr = concat(sqlstr,'left join productclass proc on proc.id = pro.classid where opt.isdelete = 0 and opp.productid>0 ');            
  
			
			if (optstatus =0 ) then
			   set sqlstr = concat(sqlstr,' and opt.optstatus in(\'1\',\'2\')');
			elseif (optstatus = 1 )then 
			   set sqlstr = concat(sqlstr,' and opt.optstatus=1');
			elseif optstatus = 2 then
			   set sqlstr = concat(sqlstr,' and opt.optstatus=2 and optsta.stage=1');
			end if;
			   
			
          if (employeeIds is not null and departIds is not null) then
            set sqlstr = concat(sqlstr,' and (opt.ownerid in (',employeeIds,') or emp.depid in (',departIds,'))');
		  else
			if employeeIds is not null then
				set sqlstr = concat(sqlstr, ' and opt.ownerid in (',employeeIds,')');
			elseif departIds is not null then
				set sqlstr = concat(sqlstr, ' and emp.depid  in (',departIds,')');
         end if;
        end if;

        if (faranchiseid is not null and faranchiseid > 0) then
			set sqlstr = concat(sqlstr, ' and opt.faranchiseid = ',faranchiseid);
        end if;
        
        
		  set sqlstr = concat(sqlstr, ' and opt.planoverdate between \'', startdate, '\' and \'', enddate, '\'');     
		  
		   
			if(brandid is not null) then
				set sqlstr = concat(sqlstr, ' and prob.id in (',brandid,')');
			end if;
			
			if(classid is not null) then
				set sqlstr = concat(sqlstr, ' and proc.id in (',classid,')');
			end if;
			   
			if(pmodelList is not null) then 
			   set sqlstr = concat(sqlstr, ' and  opp.productid in (',pmodelList,')');
			end if;
			
			
				
			set sqlstringtotal = concat(sqlstr, ' and cto.isdelete = 0 ');
			set sqlstring = concat(sqlstr, ' and cto.isdelete = 0  group by cto.id ');
			set sqlheader = replace(sqlheader,'$className$','cto.customername');
         set sqlheader = replace(sqlheader,'$classNameEn$','cto.customername');
         set sqlheader = replace(sqlheader,'$classId$',' cto.id');

         if ispriceprofit = 1 then
        
          
		    set sqlstring = concat(sqlstring,' order by totalprice desc $limit$) totatab ') ;
        	
        	 set sqlstringtotal = replace(sqlstringtotal,'$sqlheader$','select sum(convertoptproduct.converttotalprice*num*discount) into @totalvalue ');
				
			  
        	 if isexportorshow = 1 then
				 set sqlstring = replace(sqlstring,'$limit$',' limit 10 ') ;
        	 	 set sqlstringtotal = replace(sqlstring,'$sqlheader$','select sum(totatab.totalprice)  into @totalvalue from  (select sum(convertoptproduct.converttotalprice*num*discount) totalprice ');
			 end if;
			 
			 set sqlstring = replace(sqlstring,'$limit$','') ;				 
        	 set sqlheader = replace(sqlheader,'$converttotalprice$','convertoptproduct.converttotalprice*num*discount');
        	 set sqlheader = replace(sqlheader,'$ispriceprofit$',1);
        	 set sqlheader = replace(sqlheader,'$statisticunit$',statisticunits);
			 set sqlheader = replace(sqlheader,'$lossprice$',' 0 lossprice');
        	 set sqlheader = replace(sqlheader,'$losspercent$',' 0 losspercent');   
        else 
        
          	  
           set sqlstringtotal = replace(sqlstring,'$sqlheader$',' select sum(if(totatab.totalprice>0,totatab.totalprice,0)), sum(if(totatab.totalprice<0,totatab.totalprice,0))  into @totalvalue 
						,@lossvalue from  (select sum((convertoptproduct.converttotalprice*discount-convertoptproduct.converttotalcost)*num) totalprice ');
			  	
		     set sqlstringtotal = concat(sqlstringtotal,' order by totalprice desc $limit$) totatab  ') ;
		     set sqlstring = concat(sqlstring,' ) totatab order by if(totalprice>0,totalprice,lossprice) desc ');
		     
			   
        	 if isexportorshow = 1 then
					 set sqlstring = concat(sqlstring,' limit 10 ');
					 set sqlstringtotal = replace(sqlstringtotal,'$limit$',' limit 10 ');
			 end if;	
			 
			 set sqlstringtotal = replace(sqlstringtotal,'$limit$',' ');
			 set sqlheader = replace(sqlheader,'$lossprice$','IFNULL(cast(if(sum($converttotalprice$)<0,sum($converttotalprice$),0)/$statisticunit$ as DECIMAL(14,2)),0) as lossprice ');
          set sqlheader = replace(sqlheader,'$losspercent$','IFNULL(cast(if(sum($converttotalprice$)<0,sum($converttotalprice$),0)/$lossvalue$ as DECIMAL(14,2)),0) as losspercent');
          set sqlheader = replace(sqlheader,'$converttotalprice$','((convertoptproduct.converttotalprice*discount)-convertoptproduct.converttotalcost)*num');
          set sqlheader = replace(sqlheader,'$ispriceprofit$',3);
          set sqlheader = replace(sqlheader,'$statisticunit$',statisticunits);
        end if;
        
        
        set @stmt = sqlstringtotal; 
		  PREPARE stmt FROM @stmt;
		  EXECUTE stmt;
         set totalvalue = ifnull(@totalvalue,0);
         set lossvalue = ifnull(@lossvalue,0);
         
		   set sqlheader = replace(sqlheader, '$totalvalue$', totalvalue);
		   set sqlheader = replace(sqlheader, '$lossvalue$', lossvalue);
	        
	      set sqlstring = replace(sqlstring, '$sqlheader$', sqlheader); 
			set @stmt = sqlstring; 
			PREPARE stmt FROM @stmt;
			EXECUTE stmt;        
			DEALLOCATE PREPARE stmt;
			
			  
			select ifNUll(sum(totalprice),0),ifNUll(sum(lossprice),0) into @totalvalue,@lossvalue from chart_productanalysis_toptencustomer_table ;
			
			
	      	
			if isexportorshow = 1 then
	      	select topten.* from ( select * from chart_productanalysis_toptencustomer_table 
				union all (select '','-2','','',0,0,0,0,ispriceprofit)
				union all (select '','-2','','',0,0,0,0,ispriceprofit)
				union all (select '','-2','','',0,0,0,0,ispriceprofit)
				union all (select '','-2','','',0,0,0,0,ispriceprofit)
			   union all (select '','-2','','',0,0,0,0,ispriceprofit)
				union all (select '','-2','','',0,0,0,0,ispriceprofit)
				union all (select '','-2','','',0,0,0,0,ispriceprofit)
				union all (select '','-2','','',0,0,0,0,ispriceprofit)
				union all (select '','-2','','',0,0,0,0,ispriceprofit)
				union all (select '','-2','','',0,0,0,0,ispriceprofit)
				limit 10 ) topten 
				union all (select '','-1','汇总','Summary',round(@totalvalue,2),'1',round(@lossvalue,2),'1',ispriceprofit );
	      elseif isexportorshow = 2 then
	         select * from chart_productanalysis_toptencustomer_table 
				union all (select '','-1','汇总','Summary',round(@totalvalue,2),'1',round(@lossvalue,2),'1',ispriceprofit );
	      end if;	   
	end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `chart_productanalysis_toptenopt_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `chart_productanalysis_toptenopt_proc`(
	IN `syscurrencyid` int,
	IN `startdate` varchar(20),
	IN `enddate` varchar(20),
	IN `brandid` varchar(4000),
	IN `classid` varchar(4000),
	IN `pmodelList` varchar(4000),
	IN `optstatus` int,
	IN `employeeIds` varchar(4000),
	IN `departIds` varchar(4000),
	IN `faranchiseid` int,
	IN `loginEmployeeid` int,
	IN `ispriceprofit` int ,
	IN `isexportorshow` int
)
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
    declare totalvalue DECIMAL(14,2);
    declare lossvalue DECIMAL(14,2);
	 declare statisticunits DECIMAL(14,2);
	 
    set sqlstring = '';
	select `statisticunit` into statisticunits from currencyexchange where id = syscurrencyid;
    set sqlheader = 'insert into chart_productanalysis_toptenopt_table(optid,optname,optnameen,customername,ownername,stage,totalprice,percent,lossprice,losspercent,ispriceprofit)  
	     select *from  (select IFNULL($optid$,0),IFNULL($optno$,0) as optname,IFNULL($optnoen$,0) as optnameen,$customername$ customername,$ownername$ as ownername ,$stage$ stage
		  ,IFNULL(cast(if(sum($converttotalprice$)>0,sum($converttotalprice$),0)/$statisticunit$ as DECIMAL(14,2)),0) as totalprice 
		  ,IFNULL(cast(if(sum($converttotalprice$)>0,sum($converttotalprice$),0)/$totalvalue$ as DECIMAL(14,2)),0) as percent,$lossprice$,$losspercent$,$ispriceprofit$';
		  
	 drop table if exists `chart_productanalysis_toptenopt_table`;
    
    create temporary table IF NOT EXISTS `chart_productanalysis_toptenopt_table`
    (
        `id` int(10) NOT NULL AUTO_INCREMENT COMMENT 'ID',
		  `optid` int(10) NOT NULL COMMENT '机会id',
        `optname` varchar(200) NOT NULL COMMENT '机会名称',
        `optnameen` varchar(200) NOT NULL COMMENT '机会编号-en',
        `customername` varchar(200) NOT NULL  COMMENT '客户名称',
        `ownername` varchar(200) NOT NULL  COMMENT '销售姓名',
        `stage` varchar(200) NOT NULL COMMENT '进展阶段',
        `totalprice` DECIMAL(14,2) NOT NULL COMMENT '总金额/总毛利',
        `percent` DECIMAL(14,2) NOT NULL COMMENT '占比',
        `lossprice` DECIMAL(14,2) NOT NULL COMMENT '亏损的毛利',
        `losspercent` DECIMAL(14,2) NOT NULL COMMENT '亏损占比',
        `ispriceprofit` int(10) NOT NULL COMMENT '金额/毛利',
        PRIMARY KEY (`id`)
    );
    truncate table `chart_productanalysis_toptenopt_table`;

	
    if (employeeIds is not null and CHAR_LENGTH(employeeIds) = 0) then
		set employeeIds = null;
    end if;
    if (departIds is not null and CHAR_LENGTH(departIds) = 0) then
		set departIds = null;
    end if;
     if (pmodelList is not null and CHAR_LENGTH(pmodelList) = 0) then
		set pmodelList = null;
    end if;
      if (brandid is not null and CHAR_LENGTH(brandid) = 0) then
		set brandid = null;
    end if;
      if (classid is not null and CHAR_LENGTH(classid) = 0) then
		set classid = null;
    end if;
    
    set tmpcount = 1;

    if CHAR_LENGTH(startdate) > 0 then
                
        set sqlstr = '$sqlheader$ ';
        set sqlstr = concat(sqlstr,'from optproduct as opp ');
        set sqlstr = concat(sqlstr,'left join opt on opp.optid = opt.id ');        
        set sqlstr = concat(sqlstr,'left join employee emp on opt.ownerid = emp.id left join (select
		  optproduct.id id,
		  if(',syscurrencyid,'=1,
		     if(opt.currencyid=1,
		        optproduct.rmbprice,
		        optproduct.dollarprice*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2))),
		     if(opt.currencyid=2,
		        optproduct.dollarprice,
		        optproduct.rmbprice*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2)))) converttotalprice,
		   if(',syscurrencyid,'=1,
		     if(opt.currencyid=1,
		        optproduct.rmbcost,
		        optproduct.dollarcost*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2))),
		     if(opt.currencyid=2,
		        optproduct.dollarcost,
		        optproduct.rmbcost*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2)))) converttotalcost,
		  if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) formula
			from optproduct 
			left join opt
			  on optproduct.optid = opt.id
			left join currencyconvert cc
			  ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
			left join (select cast(if(',syscurrencyid,'=1,intoajformula,ajtoinformula) as DECIMAL(14,2)) formula  from currencyconvert ORDER BY id desc limit 1) lasc
			  ON 1=1) convertoptproduct on opp.id=convertoptproduct.id
			left join currencyexchange cue on cue.id = opt.currencyid ');
		  set sqlstr = concat(sqlstr,	'left join optstage optsta on opt.stageid = optsta.id  left join  customer cto on opt.customerid =  cto.id  ');
        set sqlstr = concat(sqlstr,'left join product pro on pro.id = opp.productid ');
        set sqlstr = concat(sqlstr,'left join productbrand prob on prob.id = pro.brandid ');
        set sqlstr = concat(sqlstr,'left join productclass proc on proc.id = pro.classid where opt.isdelete = 0 and opp.productid>0 ');            
  
			
			if (optstatus =0 ) then
			   set sqlstr = concat(sqlstr,' and opt.optstatus in(\'1\',\'2\')');
			elseif (optstatus = 1 )then 
			   set sqlstr = concat(sqlstr,' and opt.optstatus=1');
			elseif optstatus = 2 then
			   set sqlstr = concat(sqlstr,' and opt.optstatus=2 and optsta.stage=1');
			end if;
			   
			
          if (employeeIds is not null and departIds is not null) then
            set sqlstr = concat(sqlstr,' and (opt.ownerid in (',employeeIds,') or emp.depid in (',departIds,'))');
		  else
			if employeeIds is not null then
				set sqlstr = concat(sqlstr, ' and opt.ownerid in (',employeeIds,')');
			elseif departIds is not null then
				set sqlstr = concat(sqlstr, ' and emp.depid  in (',departIds,')');
         end if;
        end if;

        if (faranchiseid is not null and faranchiseid > 0) then
			set sqlstr = concat(sqlstr, ' and opt.faranchiseid = ',faranchiseid);
        end if;
        
        
		  set sqlstr = concat(sqlstr, ' and opt.planoverdate between \'', startdate, '\' and \'', enddate, '\'');     
		  
		   
			if(brandid is not null) then
				set sqlstr = concat(sqlstr, ' and prob.id in (',brandid,')');
			end if;
			
			if(classid is not null) then
				set sqlstr = concat(sqlstr, ' and proc.id in (',classid,')');
			end if;
			   
			if(pmodelList is not null) then 
			   set sqlstr = concat(sqlstr, ' and  opp.productid in (',pmodelList,')');
			end if;
			
			
				
			set sqlstring = concat(sqlstr, ' group by opp.optid ');
			set sqlheader = replace(sqlheader,'$optid$','opt.id');
			set sqlheader = replace(sqlheader,'$optno$','opt.optname');
			set sqlheader = replace(sqlheader,'$optnoen$','opt.optname');
         set sqlheader = replace(sqlheader,'$customername$','cto.customername');
         set sqlheader = replace(sqlheader,'$ownername$','emp.fullname');
         set sqlheader = replace(sqlheader,'$stage$','optsta.stage');
       
		   
         if ispriceprofit = 1 then
        
          
		    set sqlstring = concat(sqlstring,' order by totalprice desc $limit$) totatab') ;
        	
        	 set sqlstringtotal = replace(sqlstr,'$sqlheader$','select sum(convertoptproduct.converttotalprice*num*discount) into @totalvalue ');
				
			  
        	 if isexportorshow = 1 then
				 set sqlstring = replace(sqlstring,'$limit$','limit 10') ;
        	 	 set sqlstringtotal = replace(sqlstring,'$sqlheader$','select sum(totatab.totalprice)  into @totalvalue from  (select sum(convertoptproduct.converttotalprice*num*discount) totalprice ');
			 end if;
			 
			 set sqlstring = replace(sqlstring,'$limit$','') ;			 
        	 set sqlheader = replace(sqlheader,'$converttotalprice$','convertoptproduct.converttotalprice*num*discount');
        	 set sqlheader = replace(sqlheader,'$ispriceprofit$',1);
        	 set sqlheader = replace(sqlheader,'$statisticunit$',statisticunits); 
		    set sqlheader = replace(sqlheader,'$lossprice$',' 0 lossprice');
        	 set sqlheader = replace(sqlheader,'$losspercent$',' 0 losspercent');   
        else 
        
       	  
           set sqlstringtotal = replace(sqlstring,'$sqlheader$',' select sum(if(totatab.totalprice>0,totatab.totalprice,0)), sum(if(totatab.totalprice<0,totatab.totalprice,0))  into @totalvalue 
						,@lossvalue from  (select sum((convertoptproduct.converttotalprice*discount-convertoptproduct.converttotalcost)*num) totalprice ');
			  	
		     set sqlstringtotal = concat(sqlstringtotal,' order by totalprice desc $limit$) totatab  ') ;
		     set sqlstring = concat(sqlstring,' ) totatab order by if(totalprice>0,totalprice,lossprice) desc ');
		     
			   
        	 if isexportorshow = 1 then
					 set sqlstring = concat(sqlstring,' limit 10 ');
					 set sqlstringtotal = replace(sqlstringtotal,'$limit$',' limit 10 ');
			 end if;
			 	
			 set sqlstringtotal = replace(sqlstringtotal,'$limit$',' ');
			 set sqlheader = replace(sqlheader,'$lossprice$','IFNULL(cast(if(sum($converttotalprice$)<0,sum($converttotalprice$),0)/$statisticunit$ as DECIMAL(14,2)),0) as lossprice ');
          set sqlheader = replace(sqlheader,'$losspercent$','IFNULL(cast(if(sum($converttotalprice$)<0,sum($converttotalprice$),0)/$lossvalue$ as DECIMAL(14,2)),0) as losspercent');
          set sqlheader = replace(sqlheader,'$converttotalprice$','((convertoptproduct.converttotalprice*discount)-convertoptproduct.converttotalcost)*num');
          set sqlheader = replace(sqlheader,'$ispriceprofit$',3);
          set sqlheader = replace(sqlheader,'$statisticunit$',statisticunits);
        end if;
        
        
        set @stmt = sqlstringtotal; 
		  PREPARE stmt FROM @stmt;
		  EXECUTE stmt;
         set totalvalue = ifnull(@totalvalue,0);
         set lossvalue = ifnull(@lossvalue,0);
         
		   set sqlheader = replace(sqlheader, '$totalvalue$', totalvalue);
		   set sqlheader = replace(sqlheader, '$lossvalue$', lossvalue);
	        
	      set sqlstring = replace(sqlstring, '$sqlheader$', sqlheader); 
			set @stmt = sqlstring; 
			PREPARE stmt FROM @stmt;
			EXECUTE stmt;        
			DEALLOCATE PREPARE stmt;
			  
			select ifNUll(sum(totalprice),0),ifNUll(sum(lossprice),0) into @totalvalue,@lossvalue from chart_productanalysis_toptenopt_table ;
		
	      	
			if isexportorshow = 1 then
	      	select topten.* from ( select * from chart_productanalysis_toptenopt_table 
				union all (select '','-2','','','','',0,0,0,0,0,ispriceprofit)
				union all (select '','-2','','','','',0,0,0,0,0,ispriceprofit)
				union all (select '','-2','','','','',0,0,0,0,0,ispriceprofit)
				union all (select '','-2','','','','',0,0,0,0,0,ispriceprofit)
				union all (select '','-2','','','','',0,0,0,0,0,ispriceprofit)
				union all (select '','-2','','','','',0,0,0,0,0,ispriceprofit)
				union all (select '','-2','','','','',0,0,0,0,0,ispriceprofit)
				union all (select '','-2','','','','',0,0,0,0,0,ispriceprofit)
				union all (select '','-2','','','','',0,0,0,0,0,ispriceprofit)
				union all (select '','-2','','','','',0,0,0,0,0,ispriceprofit)
				union all (select '','-2','','','','',0,0,0,0,0,ispriceprofit)
				limit 10 ) topten
				union all (select '','-1','汇总','Summary','','','',round(@totalvalue,2),'1',round(@lossvalue,2),'1',ispriceprofit );
	      elseif isexportorshow = 2 then
	      	select * from chart_productanalysis_toptenopt_table 
				union all (select '','-1','汇总','Summary','','','',round(@totalvalue,2),'1',round(@lossvalue,2),'1',ispriceprofit );
	      end if;	   
	end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `chart_productanalysis_toptenproduct_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `chart_productanalysis_toptenproduct_proc`(
	IN `syscurrencyid` int,
	IN `startdate` varchar(20),
	IN `enddate` varchar(20),
	IN `brandid` varchar(4000),
	IN `classid` varchar(4000),
	IN `pmodelList` varchar(4000),
	IN `optstatus` int,
	IN `employeeIds` varchar(4000),
	IN `departIds` varchar(4000),
	IN `faranchiseid` int,
	IN `loginEmployeeid` int,
	IN `ispriceprofit` int ,
	IN `isexportorshow` int
)
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
    declare totalvalue DECIMAL(14,2);
    declare lossvalue DECIMAL(14,2);
	 declare statisticunits DECIMAL(14,2);
	 
    set sqlstring = '';
	select `statisticunit` into statisticunits from currencyexchange where id = syscurrencyid;
    set sqlheader = 'insert into chart_productanalysis_toptenproduct_table(classId,className,classNameEn,totalprice,percent,lossprice,losspercent,ispriceprofit)  
	    select *from (select IFNULL($classId$,0) as classId,IFNULL($className$,\'Other\') as className,IFNULL($classNameEn$,\'Other\') as classNameEn 
		  ,IFNULL(cast(if(sum($converttotalprice$)>0,sum($converttotalprice$),0)/$statisticunit$ as DECIMAL(14,2)),0) as totalprice 
		  ,IFNULL(cast(if(sum($converttotalprice$)>0,sum($converttotalprice$),0)/$totalvalue$ as DECIMAL(14,2)),0) as percent,$lossprice$,$losspercent$,$ispriceprofit$';
		  
	 drop table if exists `chart_productanalysis_toptenproduct_table`;
    
    create temporary table IF NOT EXISTS `chart_productanalysis_toptenproduct_table`
    (
        `id` int(10) NOT NULL AUTO_INCREMENT COMMENT 'ID',
        `classId` varchar(200) NOT NULL COMMENT '产品id',
        `className` varchar(200) NOT NULL  COMMENT '型号名称',
        `classNameEn` varchar(200) NOT NULL  COMMENT '型号名称-英文',
        `totalprice` DECIMAL(14,2) NOT NULL COMMENT '总金额/总毛利',
        `percent` DECIMAL(14,2) NOT NULL COMMENT '占比',
        `lossprice` DECIMAL(14,2) NOT NULL COMMENT '亏损的毛利',
        `losspercent` DECIMAL(14,2) NOT NULL COMMENT '亏损占比',
        `ispriceprofit` int(10) NOT NULL COMMENT '金额/毛利',
        PRIMARY KEY (`id`)
    );
    truncate table `chart_productanalysis_toptenproduct_table`;

	
    if (employeeIds is not null and CHAR_LENGTH(employeeIds) = 0) then
		set employeeIds = null;
    end if;
    if (departIds is not null and CHAR_LENGTH(departIds) = 0) then
		set departIds = null;
    end if;
     if (pmodelList is not null and CHAR_LENGTH(pmodelList) = 0) then
		set pmodelList = null;
    end if;
     if (brandid is not null and CHAR_LENGTH(brandid) = 0) then
		set brandid = null;
    end if;
     if (classid is not null and CHAR_LENGTH(classid) = 0) then
		set classid = null;
    end if;
    
    set tmpcount = 1;

    if CHAR_LENGTH(startdate) > 0 then
                
        set sqlstr = '$sqlheader$ ';
        set sqlstr = concat(sqlstr,'from optproduct as opp ');
        set sqlstr = concat(sqlstr,'left join opt on opp.optid = opt.id ');        
        set sqlstr = concat(sqlstr,'left join employee emp on opt.ownerid = emp.id left join (select
		  optproduct.id id,
		  if(',syscurrencyid,'=1,
		     if(opt.currencyid=1,
		        optproduct.rmbprice,
		        optproduct.dollarprice*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2))),
		     if(opt.currencyid=2,
		        optproduct.dollarprice,
		        optproduct.rmbprice*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2)))) converttotalprice,
		   if(',syscurrencyid,'=1,
		     if(opt.currencyid=1,
		        optproduct.rmbcost,
		        optproduct.dollarcost*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2))),
		     if(opt.currencyid=2,
		        optproduct.dollarcost,
		        optproduct.rmbcost*cast(if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) as DECIMAL(14,2)))) converttotalcost,
		  if(',syscurrencyid,'=1,ifnull(cc.intoajformula,lasc.formula),ifnull(cc.ajtoinformula,lasc.formula)) formula
			from optproduct 
			left join opt
			  on optproduct.optid = opt.id
			left join currencyconvert cc
			  ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
			left join (select cast(if(',syscurrencyid,'=1,intoajformula,ajtoinformula) as DECIMAL(14,2)) formula  from currencyconvert ORDER BY id desc limit 1) lasc
			  ON 1=1) convertoptproduct on opp.id=convertoptproduct.id
			left join currencyexchange cue on cue.id = opt.currencyid ');
		  set sqlstr = concat(sqlstr,	'left join optstage optsta on opt.stageid = optsta.id  left join  customer cto on opt.customerid =  cto.id  ');
        set sqlstr = concat(sqlstr,'left join product pro on pro.id = opp.productid ');
        set sqlstr = concat(sqlstr,'left join productbrand prob on prob.id = pro.brandid ');
        set sqlstr = concat(sqlstr,'left join productclass proc on proc.id = pro.classid where opt.isdelete = 0 and opp.productid>0 ');            
  
			
			if (optstatus =0 ) then
			   set sqlstr = concat(sqlstr,' and opt.optstatus in(\'1\',\'2\')');
			elseif (optstatus = 1 )then 
			   set sqlstr = concat(sqlstr,' and opt.optstatus=1');
			elseif optstatus = 2 then
			   set sqlstr = concat(sqlstr,' and opt.optstatus=2 and optsta.stage=1');
			end if;
			   
			
          if (employeeIds is not null and departIds is not null) then
            set sqlstr = concat(sqlstr,' and (opt.ownerid in (',employeeIds,') or emp.depid in (',departIds,'))');
		  else
			if employeeIds is not null then
				set sqlstr = concat(sqlstr, ' and opt.ownerid in (',employeeIds,')');
			elseif departIds is not null then
				set sqlstr = concat(sqlstr, ' and emp.depid  in (',departIds,')');
         end if;
        end if;

        if (faranchiseid is not null and faranchiseid > 0) then
			set sqlstr = concat(sqlstr, ' and opt.faranchiseid = ',faranchiseid);
        end if;
        
        
		  set sqlstr = concat(sqlstr, ' and opt.planoverdate between \'', startdate, '\' and \'', enddate, '\'');     
		  
		   
			if(brandid is not null) then
				set sqlstr = concat(sqlstr, ' and prob.id in (',brandid,')');
			end if;
			
			if(classid is not null) then
				set sqlstr = concat(sqlstr, ' and proc.id  in (',classid,')');
			end if;
			   
			if(pmodelList is not null) then 
			   set sqlstr = concat(sqlstr, ' and  opp.productid in (',pmodelList,')');
			end if;
			
			
				
			set sqlstringtotal = concat(sqlstr, ' and pro.isdelete = 0 ');
			set sqlstring = concat(sqlstr, ' and pro.isdelete = 0  group by pro.id ');
			set sqlheader = replace(sqlheader,'$className$','pro.productmodel');
         set sqlheader = replace(sqlheader,'$classNameEn$','pro.productmodel');
         set sqlheader = replace(sqlheader,'$classId$',' pro.id');
         
		
         if ispriceprofit = 1 then
        
          
		    set sqlstring = concat(sqlstring,' order by totalprice desc $limit$) totatab') ;
        	
        	 set sqlstringtotal = replace(sqlstringtotal,'$sqlheader$','select sum(convertoptproduct.converttotalprice*num*discount) into @totalvalue ');
				
			  
        	 if isexportorshow = 1 then
				 set sqlstring = replace(sqlstring,'$limit$','limit 10') ;
        	 	 set sqlstringtotal = replace(sqlstring,'$sqlheader$','select sum(totatab.totalprice)  into @totalvalue from  (select sum(convertoptproduct.converttotalprice*num*discount) totalprice ');
			 end if;
			 set sqlstring = replace(sqlstring,'$limit$','') ;					 
        	 set sqlheader = replace(sqlheader,'$converttotalprice$','convertoptproduct.converttotalprice*num*discount');
        	 set sqlheader = replace(sqlheader,'$ispriceprofit$',1);
        	 set sqlheader = replace(sqlheader,'$statisticunit$',statisticunits);
			 set sqlheader = replace(sqlheader,'$lossprice$',' 0 lossprice');
        	 set sqlheader = replace(sqlheader,'$losspercent$',' 0 losspercent');  
        	 alter table `chart_productanalysis_toptenproduct_table` MODIFY  `totalprice`  DECIMAL(14,2);
         elseif ispriceprofit = 2 then 
          
		    set sqlstring = concat(sqlstring,' order by totalprice desc $limit$) totatab') ;
         	
        	 set sqlstringtotal = replace(sqlstringtotal,'$sqlheader$','select sum(num) into @totalvalue ');
				
			  
        	 if isexportorshow = 1 then
				 set sqlstring = replace(sqlstring,'$limit$','limit 10') ;
        	 	 set sqlstringtotal = replace(sqlstring,'$sqlheader$','select sum(totatab.totalprice)  into @totalvalue from  (select sum(num) totalprice ');
			 end if;
			 set sqlstring = replace(sqlstring,'$limit$','') ;					 
        	 set sqlheader = replace(sqlheader,'$converttotalprice$','num');
        	 set sqlheader = replace(sqlheader,'$ispriceprofit$',2);
        	 set sqlheader = replace(sqlheader,'$statisticunit$',1); 
			 set sqlheader = replace(sqlheader,'$lossprice$',' 0 lossprice');
        	 set sqlheader = replace(sqlheader,'$losspercent$',' 0 losspercent'); 	 
        	 alter table `chart_productanalysis_toptenproduct_table` MODIFY  `totalprice`  int(20);
        else 
        
        	  
           set sqlstringtotal = replace(sqlstring,'$sqlheader$',' select sum(if(totatab.totalprice>0,totatab.totalprice,0)), sum(if(totatab.totalprice<0,totatab.totalprice,0))  into @totalvalue 
						,@lossvalue from  (select sum((convertoptproduct.converttotalprice*discount-convertoptproduct.converttotalcost)*num) totalprice ');
			  	
		     set sqlstringtotal = concat(sqlstringtotal,' order by totalprice desc $limit$) totatab  ') ;
		     set sqlstring = concat(sqlstring,' ) totatab order by if(totalprice>0,totalprice,lossprice) desc ');
		     
			   
        	 if isexportorshow = 1 then
					 set sqlstring = concat(sqlstring,' limit 10 ');
					 set sqlstringtotal = replace(sqlstringtotal,'$limit$',' limit 10 ');
			 end if;	
			 set sqlstringtotal = replace(sqlstringtotal,'$limit$',' ');
			 set sqlheader = replace(sqlheader,'$lossprice$','IFNULL(cast(if(sum($converttotalprice$)<0,sum($converttotalprice$),0)/$statisticunit$ as DECIMAL(14,2)),0) as lossprice ');
          set sqlheader = replace(sqlheader,'$losspercent$','IFNULL(cast(if(sum($converttotalprice$)<0,sum($converttotalprice$),0)/$lossvalue$ as DECIMAL(14,2)),0) as losspercent');
          set sqlheader = replace(sqlheader,'$converttotalprice$','((convertoptproduct.converttotalprice*discount)-convertoptproduct.converttotalcost)*num');
          set sqlheader = replace(sqlheader,'$ispriceprofit$',3);
          set sqlheader = replace(sqlheader,'$statisticunit$',statisticunits);
          alter table `chart_productanalysis_toptenproduct_table` MODIFY  `totalprice`  DECIMAL(14,2);
        end if;
        
        set @stmt = sqlstringtotal; 
		  PREPARE stmt FROM @stmt;
		  EXECUTE stmt;
        set totalvalue = ifnull(@totalvalue,0);
        set lossvalue = ifnull(@lossvalue,0);
        
		  set sqlheader = replace(sqlheader, '$totalvalue$', totalvalue);
		  set sqlheader = replace(sqlheader, '$lossvalue$', lossvalue);
	        
	     set sqlstring = replace(sqlstring, '$sqlheader$', sqlheader); 
			set @stmt = sqlstring; 
			PREPARE stmt FROM @stmt;
			EXECUTE stmt;        
			DEALLOCATE PREPARE stmt;
			
			
			  
			select ifNUll(sum(totalprice),0),ifNUll(sum(lossprice),0) into @totalvalue,@lossvalue from chart_productanalysis_toptenproduct_table ;
			
			
	      	
			if isexportorshow = 1 then
	      	select topten.* from ( select * from chart_productanalysis_toptenproduct_table 
				union all (select '','-2','','',0,0,0,0,ispriceprofit)
				union all (select '','-2','','',0,0,0,0,ispriceprofit)
				union all (select '','-2','','',0,0,0,0,ispriceprofit)
				union all (select '','-2','','',0,0,0,0,ispriceprofit)
			   union all (select '','-2','','',0,0,0,0,ispriceprofit)
				union all (select '','-2','','',0,0,0,0,ispriceprofit)
				union all (select '','-2','','',0,0,0,0,ispriceprofit)
				union all (select '','-2','','',0,0,0,0,ispriceprofit)
				union all (select '','-2','','',0,0,0,0,ispriceprofit)
				union all (select '','-2','','',0,0,0,0,ispriceprofit)
				limit 10 ) topten 
				union all (select '','-1','汇总','Summary',round(@totalvalue,2),'1',round(@lossvalue,2),'1',ispriceprofit );
	      elseif isexportorshow = 2 then
	         select * from chart_productanalysis_toptenproduct_table 
				union all (select '','-1','汇总','Summary',round(@totalvalue,2),'1',round(@lossvalue,2),'1',ispriceprofit );
	      end if;	   
	end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `do_insert` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `do_insert`()
BEGIN





   START TRANSACTION;INSERT INTO debug(debug) VALUES('test sql 001');INSERT INTO debug(debug) VALUES('test sql 001');INSERT INTO debug(debug) VALUES('test sql 001');INSERT INTO debug(debug) VALUES('test sql 001');INSERT INTO debug(debug) VALUES('test sql 001');INSERT INTO debug(debug) VALUES('test sql 001');INSERT INTO debug(debug) VALUES('test sql 001');INSERT INTO debug(debug) VALUES('test sql 001');INSERT INTO debug(debug) VALUES('test sql 001');INSERT INTO debug(debug) VALUES('test sql 001');INSERT INTO debug(debug) VALUES('test sql 001');select * from debug;ROLLBACK;END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `faranchise_stat_ability_allcompetewin_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `faranchise_stat_ability_allcompetewin_proc`(IN statdate varchar(20))
BEGIN
    declare years varchar(20) default '';
    declare months varchar(20) default '';
    declare optpossibility1 int(10); 
    declare optpossibility2 int(10); 
    declare optpossibility3 int(10); 
    declare optpossibility4 int(10); 
    declare optpossibility5 int(10); 
    declare var_faranchiseid int(10); 
    declare monthfield varchar(20); 
    declare execsql varchar(2000) default ''; 
    declare insertsql varchar(2000) default ''; 
    declare updatesql varchar(2000) default ''; 
    declare insertorupdateid int(10); 
    declare done TINYINT DEFAULT 0;
    declare code varchar(20) default '00000'; 
    declare name varchar(20);                 
    declare msg varchar(500);                 


    
    declare cur1 cursor for 
    SELECT COUNT(if(opt.possibilityid=5,opt.id,null)) AS optpossibility5 , COUNT(if(opt.possibilityid=4,opt.id,null)) AS optpossibility4,
        COUNT(if(opt.possibilityid=3,opt.id,null)) AS optpossibility3 , COUNT(if(opt.possibilityid=2,opt.id,null)) AS optpossibility2,
        COUNT(if(opt.possibilityid=1,opt.id,null)) AS optpossibility1 ,opt.faranchiseid
    FROM optrealsnap AS opt
    WHERE opt.snapdate = statdate  AND opt.optstatus IN(2,4) AND opt.faranchiseid IS NOT NULL  group by opt.faranchiseid;

    
    declare cur2 cursor for 
    SELECT COUNT(if(opt.possibilityid=5,opt.id,null)) AS optpossibility5 , COUNT(if(opt.possibilityid=4,opt.id,null)) AS optpossibility4,
        COUNT(if(opt.possibilityid=3,opt.id,null)) AS optpossibility3 , COUNT(if(opt.possibilityid=2,opt.id,null)) AS optpossibility2,
        COUNT(if(opt.possibilityid=1,opt.id,null)) AS optpossibility1 ,opt.faranchiseid     
    FROM optrealsnap AS opt
    WHERE opt.snapdate = statdate  AND opt.optstatus = 2 AND opt.faranchiseid IS NOT NULL  group by opt.faranchiseid;

    declare continue handler for not found set done = 1;
    declare continue handler for sqlexception 
    BEGIN
        GET DIAGNOSTICS CONDITION 1
        code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
    END;                                      
    set name = (select companyname from systemconfig limit 1); 
    start transaction; 

    
    set years =   left(statdate,4);
    set months =  right(statdate,2);
    set monthfield = concat('m',months);
    set execsql = '';
    set insertsql = concat('insert into abilitystat(statclass, stattype,type, ',monthfield,', years, faranchiseid) values($statclass, $stattype,$type, $nums, $years, $faranchiseid)');
    
    
    set updatesql = concat('update abilitystat set ',monthfield,' = $nums where id = $id');


    
    open cur1;
        
        read_loop: loop
            fetch cur1 into optpossibility5,optpossibility4,optpossibility3,optpossibility2,optpossibility1,var_faranchiseid;
            if done then
                leave read_loop;
            end if;
            
            
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=7 and stattype=1 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 7);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', optpossibility5);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', optpossibility5);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
            

            
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=7 and stattype=2 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 7);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', optpossibility4);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', optpossibility4);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
            
             
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=7 and stattype=3 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 7);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', optpossibility3);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', optpossibility3);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);


            
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=7 and stattype=4 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 7);
                set execsql = replace(execsql, '$stattype', 4);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', optpossibility2);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', optpossibility2);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
            
            
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=7 and stattype=5 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 7);
                set execsql = replace(execsql, '$stattype', 5);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', optpossibility1);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', optpossibility1);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);

            set insertorupdateid = null;
        end loop;
    
    close cur1;

    
    set done = FALSE;

    
    open cur2;
        
        read_loop: loop
            fetch cur2 into optpossibility5,optpossibility4,optpossibility3,optpossibility2,optpossibility1,var_faranchiseid;
            if done then
                leave read_loop;
            end if;
            
            
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=7 and stattype=1 and type = 2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 7);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', optpossibility5);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', optpossibility5);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
            

            
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=7 and stattype=2 and type = 2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 7);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', optpossibility4);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', optpossibility4);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
            
             
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=7 and stattype=3 and type = 2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 7);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', optpossibility3);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', optpossibility3);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);


            
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=7 and stattype=4 and type = 2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 7);
                set execsql = replace(execsql, '$stattype', 4);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', optpossibility2);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', optpossibility2);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
            
            
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=7 and stattype=5 and type = 2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 7);
                set execsql = replace(execsql, '$stattype', 5);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', optpossibility1);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', optpossibility1);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);

            set insertorupdateid = null;
        end loop;
    
    close cur2;

    if code = '00000' then  
        commit;
    else                    
        ROLLBACK;
        insert into snap_log(`companyname`,`code`,`msg`,`log_time`) values(name,code,msg,now());
    end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `faranchise_stat_ability_allstagewin_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `faranchise_stat_ability_allstagewin_proc`(IN statdate varchar(20))
begin

    declare years varchar(20) default '';
    declare months varchar(20) default '';
    declare f1 decimal(14,2); -- 预测 10% 数量/金额
    declare f2 decimal(14,2); -- 预测 30% 数量/金额
    declare f3 decimal(14,2); -- 预测 50% 数量/金额
    declare f4 decimal(14,2); -- 预测 70% 数量/金额
    declare f5 decimal(14,2); -- 预测 90% 数量/金额

    declare r1 decimal(14,2); -- 接单 10% 数量/金额
    declare r2 decimal(14,2); -- 接单 30% 数量/金额
    declare r3 decimal(14,2); -- 接单 50% 数量/金额
    declare r4 decimal(14,2); -- 接单 70% 数量/金额
    declare r5 decimal(14,2); -- 接单 90% 数量/金额

    declare var_faranchiseid int(10); -- 代理商id
    declare monthfield varchar(20); -- 月份字段名
    declare execsql varchar(2000) default ''; -- 执行sql语句字符串
    declare insertsql varchar(2000) default ''; -- 插入  sql字符串
    declare updatesql varchar(2000) default ''; -- 更新  sql字符串
    declare insertorupdateid int(10); -- 更新或插入后的id
    declare done TINYINT DEFAULT 0;
    declare code varchar(20) default '00000'; -- 错误代码
    declare name varchar(20);                 -- 公司名称
    declare msg varchar(500);                 -- 错误信息

    -- 预测数量
    declare cur1 cursor for 
    select count(if(opte.stageid=2,opt.optid,null)) as f1,
    count(if(opte.stageid=3,opt.optid,null)) as f2, count(if(opte.stageid=4,opt.optid,null)) as f3,
    count(if(opte.stageid=5,opt.optid,null)) as f4, count(if(opte.stageid=6,opt.optid,null)) as f5,opt.faranchiseid 
    from (select optid,stageid,snapdate,optstatus from optestimatesnap where snapdate=statdate) opte
     left join optrealsnap opt on opte.optid=opt.optid and opt.snapdate=opte.snapdate 
     where opt.faranchiseid is not null and opte.optstatus=1
     group by opt.faranchiseid;

     -- 接单数量
     declare cur2 cursor for 
    select count(if(opte.stageid=2,opt.optid,null)) as r1,
    count(if(opte.stageid=3,opt.optid,null)) as r2, count(if(opte.stageid=4,opt.optid,null)) as r3,
    count(if(opte.stageid=5,opt.optid,null)) as r4, count(if(opte.stageid=6, opt.optid,null)) as r5,opt.faranchiseid 
    from (select optid,stageid,snapdate from optestimatesnap where snapdate=statdate) opte
    left join optrealsnap opt on opte.optid=opt.optid and opt.snapdate=opte.snapdate
    where  opt.optstatus=2  and opt.faranchiseid is not null group by opt.faranchiseid;

    -- 主货币 预测
    declare cur3 cursor for 
    select sum(if(opte.stageid=2,opte.totalprice,0)) as f1,
    sum(if(opte.stageid=3,opte.totalprice,0)) as f2, sum(if(opte.stageid=4,opte.totalprice,0)) as f3,
    sum(if(opte.stageid=5,opte.totalprice,0)) as f4, sum(if(opte.stageid=6,opte.totalprice,0)) as f5,opt.faranchiseid 
    from (select opt.optid,opt.faranchiseid,opt.snapdate,opt.stageid,opt.optstatus,
            ifnull(
                if(opt.currencyid=1,
                 opt.totalprice,
                 opt.totalpriceminor*cast(ifnull(cc.intoajformula,lasc.formula) as DECIMAL(14,2))) ,0) totalprice
            from optestimatesnap opt 
              left join currencyconvert cc ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
              left join (select intoajformula formula from currencyconvert ORDER BY id desc limit 1) lasc  ON 1=1
           where opt.snapdate=statdate) opte    
    left join optrealsnap opt on opte.optid=opt.optid and opt.snapdate=opte.snapdate
    where opt.faranchiseid is not null and opte.optstatus = 1
    group by opt.faranchiseid;

    -- 主货币 接单
   declare cur4 cursor for 
   select sum(if(opte.stageid=2,opt.totalprice,0)) as f1,
    sum(if(opte.stageid=3,opt.totalprice,0)) as f2, sum(if(opte.stageid=4,opt.totalprice,0)) as f3,
    sum(if(opte.stageid=5,opt.totalprice,0)) as f4, sum(if(opte.stageid=6,opt.totalprice,0)) as f5,opt.faranchiseid 
    from (select optid,stageid,snapdate from optestimatesnap where snapdate=statdate) opte
     left join (select opt.optid,opt.optstatus,opt.faranchiseid,opt.snapdate,
                ifnull(
                    if(opt.currencyid=1,
                     opt.totalprice,
                     opt.totalpriceminor*cast(ifnull(cc.intoajformula,lasc.formula) as DECIMAL(14,2))) ,0) totalprice
                from optrealsnap opt
                  left join currencyconvert cc ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
                  left join (select intoajformula formula from currencyconvert ORDER BY id desc limit 1) lasc
                    ON 1=1) opt on opte.optid=opt.optid and opt.snapdate=opte.snapdate
     where opt.optstatus=2 and opt.faranchiseid is not null group by opt.faranchiseid;

     -- 辅货币 预测
    declare cur5 cursor for 
    select sum(if(opte.stageid=2,opte.totalprice,0)) as f1,
    sum(if(opte.stageid=3,opte.totalprice,0)) as f2, sum(if(opte.stageid=4,opte.totalprice,0)) as f3,
    sum(if(opte.stageid=5,opte.totalprice,0)) as f4, sum(if(opte.stageid=6,opte.totalprice,0)) as f5,opt.faranchiseid 
    from (select opt.optid,opt.faranchiseid,opt.snapdate,opt.stageid,opt.optstatus,
            ifnull(
                if(opt.currencyid=2,
                      opt.totalpriceminor,
                      opt.totalprice*cast(ifnull(cc.ajtoinformula,lasc.formula) as DECIMAL(14,2))) ,0) totalprice
            from optestimatesnap opt 
              left join currencyconvert cc ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
              left join (select intoajformula formula from currencyconvert ORDER BY id desc limit 1) lasc  ON 1=1
           where opt.snapdate=statdate) opte    
    left join optrealsnap opt on opte.optid=opt.optid and opt.snapdate=opte.snapdate
    where opt.faranchiseid is not null and opte.optstatus = 1
    group by opt.faranchiseid;

     -- 辅货币 接单
    declare cur6 cursor for 
    select sum(if(opte.stageid=2,opt.totalprice,0)) as f1,
    sum(if(opte.stageid=3,opt.totalprice,0)) as f2, sum(if(opte.stageid=4,opt.totalprice,0)) as f3,
    sum(if(opte.stageid=5,opt.totalprice,0)) as f4, sum(if(opte.stageid=6,opt.totalprice,0)) as f5,opt.faranchiseid 
    from (select optid,stageid,snapdate from optestimatesnap where snapdate=statdate) opte
    left join (select opt.optid,opt.snapdate,opt.optstatus,opt.faranchiseid,
                ifnull(
                   if(opt.currencyid=2,
                      opt.totalpriceminor,
                      opt.totalprice*cast(ifnull(cc.ajtoinformula,lasc.formula) as DECIMAL(14,2))) ,0) totalprice
                from optrealsnap opt
                  left join currencyconvert cc ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
                  left join (select ajtoinformula formula from currencyconvert ORDER BY id desc limit 1) lasc
                    ON 1=1) opt on opte.optid=opt.optid and opt.snapdate=opte.snapdate
     where opt.optstatus=2 and opt.faranchiseid is not null group by opt.faranchiseid;

    declare continue handler for not found set done = TRUE;
    declare continue handler for sqlexception 
    BEGIN
        GET DIAGNOSTICS CONDITION 1
        code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
    END;                                      --  当错误时,赋值错误代码,错误信息
    set name = (select companyname from systemconfig limit 1); -- 获取公司名称
    start transaction; -- 开启事物


    set years =   left(statdate,4);
    set months =  right(statdate,2);
    set monthfield = concat('m',months);
    set execsql = '';
    set insertsql = concat('insert into abilitystat(statclass, stattype, type, ',monthfield,', years, faranchiseid) values($statclass, $stattype, $type, $nums, $years, $faranchiseid)');


    set updatesql = concat('update abilitystat set ',monthfield,' = $nums where id = $id');
      /* 打开游标 */
    open cur1;
        /* 遍历数据表 */
        read_loop: loop
            fetch cur1 into f1,f2,f3,f4,f5,var_faranchiseid;
            if done then
                leave read_loop;
            end if;
            
            /*-----数量: 10% 预测-----*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=5 and stattype=1 and type=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', f1);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', f1);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----数量: 30% 预测------*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=5 and stattype=2 and type=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', f2);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', f2);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----数量: 50% 预测------*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=5 and stattype=3 and type=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', f3);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', f3);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----数量: 70% 预测------*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=5 and stattype=4 and type=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 4);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', f4);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', f4);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----数量: 90% 预测------*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=5 and stattype=5 and type=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 5);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', f5);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', f5);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);

            set insertorupdateid = null;
        end loop;
    /* 关闭游标 */
    close cur1;

    SET done = FALSE;
     /* 打开游标 */
    open cur2;
        /* 遍历数据表 */
        read_loop: loop
            fetch cur2 into r1,r2,r3,r4,r5,var_faranchiseid;
            if done then
                leave read_loop;
            end if;
            
            /*-----数量: 10% 接单-----*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=5 and stattype=1 and type=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', r1);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', r1);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----数量: 30% 接单------*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=5 and stattype=2 and type=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', r2);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', r2);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----数量: 50% 接单------*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=5 and stattype=3 and type=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', r3);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', r3);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----数量: 70% 接单------*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=5 and stattype=4 and type=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 4);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', r4);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', r4);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----数量: 90% 接单------*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=5 and stattype=5 and type=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 5);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', r5);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', r5);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);

            set insertorupdateid = null;
        end loop;
    /* 关闭游标 */
    close cur2;

    SET done = FALSE;
     /* 打开游标 */
    open cur3;
        /* 遍历数据表 */
        read_loop: loop
             fetch cur3 into f1,f2,f3,f4,f5,var_faranchiseid;
            if done then
                leave read_loop;
            end if;
            
            /*-----金额 主货币: 10% 预测-----*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=5 and stattype=1 and type=3) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 3);
                set execsql = replace(execsql, '$nums', f1);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', f1);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----金额 主货币: 30% 预测------*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=5 and stattype=2 and type=3) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 3);
                set execsql = replace(execsql, '$nums', f2);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', f2);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----金额 主货币: 50% 预测------*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=5 and stattype=3 and type=3) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 3);
                set execsql = replace(execsql, '$nums', f3);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', f3);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----金额 主货币: 70% 预测------*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=5 and stattype=4 and type=3) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 4);
                set execsql = replace(execsql, '$type', 3);
                set execsql = replace(execsql, '$nums', f4);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', f4);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----金额 主货币: 90% 预测------*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=5 and stattype=5 and type=3) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 5);
                set execsql = replace(execsql, '$type', 3);
                set execsql = replace(execsql, '$nums', f5);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', f5);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);

            set insertorupdateid = null;
        end loop;
    /* 关闭游标 */
    close cur3;

    SET done = FALSE;
     /* 打开游标 */
    open cur4;
        /* 遍历数据表 */
        read_loop: loop
            fetch cur4 into r1,r2,r3,r4,r5,var_faranchiseid;
            if done then
                leave read_loop;
            end if;
            
            /*-----金额 主货币: 10% 接单-----*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=5 and stattype=1 and type=4) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 4);
                set execsql = replace(execsql, '$nums', r1);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', r1);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----金额 主货币: 30% 接单------*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=5 and stattype=2 and type=4) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 4);
                set execsql = replace(execsql, '$nums', r2);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', r2);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----金额 主货币: 50% 接单------*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=5 and stattype=3 and type=4) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 4);
                set execsql = replace(execsql, '$nums', r3);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', r3);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----金额 主货币: 70% 接单------*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=5 and stattype=4 and type=4) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 4);
                set execsql = replace(execsql, '$type', 4);
                set execsql = replace(execsql, '$nums', r4);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', r4);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----金额 主货币: 90% 接单------*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=5 and stattype=5 and type=4) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 5);
                set execsql = replace(execsql, '$type', 4);
                set execsql = replace(execsql, '$nums', r5);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', r5);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);

            set insertorupdateid = null;
           -- DEALLOCATE PREPARE stmt;
        end loop;
    /* 关闭游标 */
    close cur4;

    SET done = FALSE;
      /* 打开游标 */
    open cur5;
        /* 遍历数据表 */
        read_loop: loop
            fetch cur5 into f1,f2,f3,f4,f5,var_faranchiseid;
            if done then
                leave read_loop;
            end if;
            
            /*-----金额 辅货币: 10% 预测-----*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=5 and stattype=1 and type=5) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 5);
                set execsql = replace(execsql, '$nums', f1);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', r1);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----金额 辅货币: 30% 预测------*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=5 and stattype=2 and type=5) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 5);
                set execsql = replace(execsql, '$nums', f2);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', f2);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----金额 辅货币: 50% 预测------*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=5 and stattype=3 and type=5) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 5);
                set execsql = replace(execsql, '$nums', f3);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', f3);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----金额 辅货币: 70% 预测------*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=5 and stattype=4 and type=5) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 4);
                set execsql = replace(execsql, '$type', 5);
                set execsql = replace(execsql, '$nums', f4);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', f4);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----金额 辅货币: 90% 预测------*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=5 and stattype=5 and type=5) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 5);
                set execsql = replace(execsql, '$type', 5);
                set execsql = replace(execsql, '$nums', f5);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', f5);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);

            set insertorupdateid = null;
 
        end loop;
    /* 关闭游标 */
    close cur5;

    SET done = FALSE;
      /* 打开游标 */
    open cur6;
        /* 遍历数据表 */
        read_loop: loop
            fetch cur6 into r1,r2,r3,r4,r5,var_faranchiseid;
            if done then
                leave read_loop;
            end if;
            
            /*-----金额 主货币: 10% 接单-----*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=5 and stattype=1 and type=6) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 6);
                set execsql = replace(execsql, '$nums', r1);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', r1);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----金额 主货币: 30% 接单------*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=5 and stattype=2 and type=6) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 6);
                set execsql = replace(execsql, '$nums', r2);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', r2);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----金额 主货币: 50% 接单------*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=5 and stattype=3 and type=6) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 6);
                set execsql = replace(execsql, '$nums', r3);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', r3);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----金额 主货币: 70% 接单------*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=5 and stattype=4 and type=6) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 4);
                set execsql = replace(execsql, '$type', 6);
                set execsql = replace(execsql, '$nums', r4);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', r4);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----金额 主货币: 90% 接单------*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=5 and stattype=5 and type=6) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 5);
                set execsql = replace(execsql, '$type', 6);
                set execsql = replace(execsql, '$nums', r5);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', r5);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);

            set insertorupdateid = null;

        end loop;
    /* 关闭游标 */
    close cur6;

    if code = '00000' then  -- 如果没有错误,提交
        commit;
    else                    -- 有错误则回滚,插入错误信息
        ROLLBACK;
        insert into snap_log(`companyname`,`code`,`msg`,`log_time`) values(name,code,msg,now());
    end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `faranchise_stat_ability_competewin_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `faranchise_stat_ability_competewin_proc`(IN statdate varchar(20))
BEGIN
    declare years varchar(20) default '';
    declare months varchar(20) default '';
    declare num int(10); 
    declare wnum int(10); 
    declare totalprice decimal(14,2); 
    declare totalpriceminor decimal(14,2); 
    declare wtotalprice decimal(14,2); 
    declare wtotalpriceminor decimal(14,2); 
    declare var_faranchiseid int(10); 
    declare monthfield varchar(20); 
    declare execsql varchar(2000) default ''; 
    declare insertsql varchar(2000) default ''; 
    declare updatesql varchar(2000) default ''; 
    declare insertorupdateid int(10); 
    declare done TINYINT DEFAULT 0;
    declare code varchar(20) default '00000'; 
    declare name varchar(20);                 
    declare msg varchar(500);                 
    
    
    declare cur1 cursor for 
    select count(opt.id) as num,count(if(opt.optstatus=2,opt.id,null)) as wnum,opt.faranchiseid 
    from optrealsnap opt 
    where opt.possibilityid<5 and opt.optstatus in (2,4) and opt.snapdate=statdate and opt.faranchiseid is not null group by opt.faranchiseid;

     
    declare cur2 cursor for 
    select   sum(ifnull(
                   if(opt.currencyid=1,
                      opt.totalprice,
                      opt.totalpriceminor*cast(ifnull(cc.intoajformula,lasc.formula) as DECIMAL(14,2))),0)) totalprice,
             sum(ifnull(
                   if(opt.currencyid=2,
                      opt.totalpriceminor,
                      opt.totalprice*cast(ifnull(cc.ajtoinformula,lasc.formula) as DECIMAL(14,2))) ,0)) totalpriceminor,
              sum(ifnull(
                   if(opt.optstatus=2,
                        if(opt.currencyid=1,
                          opt.totalprice,
                          opt.totalpriceminor*cast(ifnull(cc.intoajformula,lasc.formula) as DECIMAL(14,2))),0),0)) wtotalprice,
             sum(ifnull(
                   if(opt.optstatus=2,
                        if(opt.currencyid=2,
                           opt.totalpriceminor,
                           opt.totalprice*cast(ifnull(cc.ajtoinformula,lasc.formula) as DECIMAL(14,2))),0),0)) wtotalpriceminor,
               opt.faranchiseid
                from optrealsnap opt
                  left join currencyconvert cc ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
                  left join (select intoajformula formula from currencyconvert ORDER BY id desc limit 1) lasc ON 1=1
     where opt.possibilityid<5 and opt.optstatus in (2,4) and opt.snapdate=statdate  and opt.faranchiseid is not null group by opt.faranchiseid;

    declare continue handler for not found set done = TRUE;
    declare continue handler for sqlexception 
    BEGIN
        GET DIAGNOSTICS CONDITION 1
        code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
    END;                                      
    set name = (select companyname from systemconfig limit 1); 
    start transaction; 

    set years =   left(statdate,4);
    set months =  right(statdate,2);
    set monthfield = concat('m',months);
    set execsql = '';
    set insertsql = concat('insert into abilitystat(statclass, stattype, type, ',monthfield,', years, faranchiseid) values($statclass, $stattype, $type, $nums, $years, $faranchiseid)');
    
    set updatesql = concat('update abilitystat set ',monthfield,' = $nums where id = $id');

      
    open cur1;
        
        read_loop: loop
            fetch cur1 into num,wnum,var_faranchiseid;
            if done then
                leave read_loop;
            end if;
            
            
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=6 and stattype=1 and type=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 6);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', num);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', num);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
            
            
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=6 and stattype=2 and type=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 6);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', wnum);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', wnum);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
          
            set insertorupdateid = null;
   
        end loop;
    
    close cur1;

    SET done = FALSE;
     
    open cur2;
        
        read_loop: loop
            fetch cur2 into totalprice,totalpriceminor,wtotalprice,wtotalpriceminor,var_faranchiseid;
            if done then
                leave read_loop;
            end if;
            
            
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=6 and stattype=1 and type=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 6);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', totalprice);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', totalprice);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
            
            
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=6 and stattype=2 and type=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 6);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', wtotalprice);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', wtotalprice);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);

            
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=6 and stattype=1 and type=3) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 6);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 3);
                set execsql = replace(execsql, '$nums', totalpriceminor);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', totalpriceminor);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);

            
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=6 and stattype=2 and type=3) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 6);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 3);
                set execsql = replace(execsql, '$nums', wtotalpriceminor);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', wtotalpriceminor);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
          
            set insertorupdateid = null;
        end loop;
    
    close cur2;

    if code = '00000' then  
        commit;
    else                    
        ROLLBACK;
        insert into snap_log(`companyname`,`code`,`msg`,`log_time`) values(name,code,msg,now());
    end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `faranchise_stat_ability_optanalysiswin_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `faranchise_stat_ability_optanalysiswin_proc`(IN statdate varchar(20))
BEGIN
    declare years varchar(20) default '';
    declare months varchar(20) default '';
    declare baseitemnum decimal(14,2); 
    declare bigitemnum decimal(14,2); 
    declare allitemnum decimal(14,2); 
    declare baseitemprice decimal(14,2); 
    declare bigitemprice decimal(14,2); 
    declare allitemprice decimal(14,2); 
    declare baseitempriceminor decimal(14,2); 
    declare bigitempriceminor decimal(14,2); 
    declare allitempriceminor decimal(14,2); 
    declare var_faranchiseid int(10); 
    declare monthfield varchar(20); 
    declare execsql varchar(2000) default ''; 
    declare insertsql varchar(2000) default ''; 
    declare updatesql varchar(2000) default ''; 
    declare insertorupdateid int(10); 
    declare done TINYINT DEFAULT 0;
    declare code varchar(20) default '00000'; 
    declare name varchar(20);                 
    declare msg varchar(500);                 
    
     
    declare cur1 cursor for 
    select count(if(isbigdeals=1,null,1)) as baseitemnum,
           count(if(isbigdeals=1,1,null)) as bigitemnum,
           count(opt.optid) as allitemnum,

           sum(if(isbigdeals=1,0,opt.totalprice)) as baseitemprice,
           sum(if(isbigdeals=1,opt.totalprice,0)) as bigitemprice,
           sum(opt.totalprice) as allitemprice,

           sum(if(isbigdeals=1,0,opt.totalpriceminor)) as baseitempriceminor,
           sum(if(isbigdeals=1,opt.totalpriceminor,0)) as bigitempriceminor,
           sum(opt.totalpriceminor) as allitempriceminor,opt.faranchiseid 
    from (select opt.optid,opt.faranchiseid,
                if(opt.currencyid=1,
                         if(opt.totalprice >= cue.statisticunit*ed.bigoptprice,
                            1,0),
                         if(opt.totalpriceminor >= cue.statisticuniteminor*ed.bigoptpriceminor,
                            1,0)
                ) isbigdeals,
                ifnull(
                    if(opt.currencyid=1,
                     opt.totalprice,
                     opt.totalpriceminor*cast(ifnull(cc.intoajformula,lasc.formula) as DECIMAL(14,2))) ,0) totalprice,
                 ifnull(
                   if(opt.currencyid=2,
                      opt.totalpriceminor,
                      opt.totalprice*cast(ifnull(cc.ajtoinformula,lasc.formula) as DECIMAL(14,2))) ,0) totalpriceminor
                from optrealsnap opt
                  left join currencyconvert cc ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
                  left join (select intoajformula formula from currencyconvert ORDER BY id desc limit 1) lasc
                    ON 1=1
                 left join employee e on e.id = opt.faranchiseid
                 left join empdepart ed on e.depid = ed.id
                 left join (SELECT c.statisticunit,cue.statisticunit statisticuniteminor 
                                from currencyexchange c
                                left join (SELECT statisticunit from currencyexchange LIMIT 1,2) cue on 1=1 limit 0,1) cue on 1=1
                  where opt.optstatus=2 and opt.snapdate=statdate
       ) opt
     where opt.faranchiseid is not null
     group by opt.faranchiseid;

    declare continue handler for not found set done = TRUE;
    declare continue handler for sqlexception 
    BEGIN
        GET DIAGNOSTICS CONDITION 1
        code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
    END;                                      
    set name = (select companyname from systemconfig limit 1); 
    start transaction; 

    set years =   left(statdate,4);
    set months =  right(statdate,2);
    set monthfield = concat('m',months);
    set execsql = '';
    set insertsql = concat('insert into abilitystat(statclass, stattype, type, ',monthfield,', years, faranchiseid) values($statclass, $stattype, $type, $nums, $years, $faranchiseid)');
   
    set updatesql = concat('update abilitystat set ',monthfield,' = $nums where id = $id');

      
    open cur1;
        
        read_loop: loop
            fetch cur1 into baseitemnum,bigitemnum,allitemnum,baseitemprice,bigitemprice,allitemprice,baseitempriceminor,bigitempriceminor,allitempriceminor,var_faranchiseid;
            if done then
                leave read_loop;
            end if;
            
            
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=1 and stattype=1 and type=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 1);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', baseitemnum);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', baseitemnum);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
            
            
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=1 and stattype=2 and type=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 1);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', bigitemnum);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', bigitemnum);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);

              
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=1 and stattype=3 and type=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 1);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', allitemnum);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', allitemnum);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);

              
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=1 and stattype=1 and type=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 1);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', baseitemprice);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', baseitemprice);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);

              
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=1 and stattype=2 and type=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 1);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type',2);
                set execsql = replace(execsql, '$nums', bigitemprice);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', bigitemprice);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);

              
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=1 and stattype=3 and type=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 1);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', allitemprice);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', allitemprice);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);

            
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=1 and stattype=1 and type=3) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 1);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 3);
                set execsql = replace(execsql, '$nums', baseitempriceminor);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', baseitempriceminor);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);

              
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=1 and stattype=2 and type=3) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 1);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type',3);
                set execsql = replace(execsql, '$nums', bigitempriceminor);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', bigitempriceminor);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);

              
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=1 and stattype=3 and type=3) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 1);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 3);
                set execsql = replace(execsql, '$nums', allitempriceminor);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', allitempriceminor);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
          
            set insertorupdateid = null;

        end loop;
    
    close cur1;

    if code = '00000' then  
        commit;
    else                    
        ROLLBACK;
        insert into snap_log(`companyname`,`code`,`msg`,`log_time`) values(name,code,msg,now());
    end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `faranchise_stat_ability_optboost_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `faranchise_stat_ability_optboost_proc`(IN statdate varchar(20),IN startdate varchar(20),IN enddate varchar(20))
BEGIN
    declare years varchar(20) default '';
    declare months varchar(20) default '';
    declare num1 int(10); 
    declare num2 int(10); 
    declare num3 int(10); 
    declare num4 int(10); 
    declare num5 int(10); 
    declare var_faranchiseid int(10); 
    declare monthfield varchar(20); 
    declare execsql varchar(2000) default ''; 
    declare insertsql varchar(2000) default ''; 
    declare updatesql varchar(2000) default ''; 
    declare insertorupdateid int(10); 
    declare done TINYINT DEFAULT 0;
    declare code varchar(20) default '00000'; 
    declare name varchar(20);                 
    declare msg varchar(500);                 
    
    
    declare cur1 cursor for 
    SELECT count(if(DATE_FORMAT(osu.stageupdatetime,'%Y-%m-%d') BETWEEN startdate AND enddate AND  osu.stageid= 3,1,null)) 
        + count(if(DATE_FORMAT(osu.stageupdatetime,'%Y-%m-%d') <= enddate AND osu.islaststage= 1 AND  osu.stageid= 2,1,null)) as num1,
         
            count(if(DATE_FORMAT(osu.stageupdatetime,'%Y-%m-%d') BETWEEN startdate AND enddate AND  osu.stageid= 4,1,null)) 
        + count(if(DATE_FORMAT(osu.stageupdatetime,'%Y-%m-%d') <= enddate AND osu.islaststage= 1 AND  osu.stageid= 3,1,null)) as num2,
         
            count(if(DATE_FORMAT(osu.stageupdatetime,'%Y-%m-%d') BETWEEN startdate AND enddate AND  osu.stageid= 5,1,null)) 
        + count(if(DATE_FORMAT(osu.stageupdatetime,'%Y-%m-%d') <= enddate AND osu.islaststage= 1 AND  osu.stageid= 4,1,null)) as num3,
         
            count(if(DATE_FORMAT(osu.stageupdatetime,'%Y-%m-%d') BETWEEN startdate AND enddate AND  osu.stageid= 6,1,null)) 
        + count(if(DATE_FORMAT(osu.stageupdatetime,'%Y-%m-%d') <= enddate AND osu.islaststage= 1 AND  osu.stageid= 5,1,null)) as num4,
         
            count(if(DATE_FORMAT(osu.stageupdatetime,'%Y-%m-%d') BETWEEN startdate AND enddate AND  osu.stageid= 7,1,null)) 
        + count(if(DATE_FORMAT(osu.stageupdatetime,'%Y-%m-%d') <= enddate AND osu.islaststage= 1 AND  osu.stageid= 6,1,null)) as num5,
         osu.faranchiseid
    FROM optstageupdatesnap osu
    WHERE osu.isdelete = 0 AND osu.snapdate = statdate and osu.faranchiseid is not null 
    group by osu.faranchiseid ;

    
    declare cur2 cursor for 
    SELECT count(if(osu.stageid=3,1,null)) as num1 ,count(if(osu.stageid=4,1,null)) as num2
           ,count(if(osu.stageid=5,1,null)) as num3 ,count(if(osu.stageid=6,1,null)) as num4 ,count(if(osu.stageid=7,1,null)) as num5 
           , osu.faranchiseid
    FROM optstageupdatesnap osu
    WHERE (DATE_FORMAT(osu.stageupdatetime,'%Y-%m-%d') BETWEEN startdate AND enddate)  AND osu.isdelete = 0  AND osu.snapdate = statdate  
    group by osu.faranchiseid;

    declare continue handler for not found set done = 1;
    declare continue handler for sqlexception 
    BEGIN
        GET DIAGNOSTICS CONDITION 1
        code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
    END;                                      
    set name = (select companyname from systemconfig limit 1); 
    start transaction; 
    
    set years =   left(statdate,4);
    set months =  right(statdate,2);
    set monthfield = concat('m',months);
    set execsql = '';
    set insertsql = concat('insert into abilitystat(statclass, stattype,type, ',monthfield,', years, faranchiseid) values($statclass, $stattype,$type, $nums, $years, $faranchiseid)');

    set updatesql = concat('update abilitystat set ',monthfield,' = $nums where id = $id');


    
    open cur1;
        
        read_loop: loop
            fetch cur1 into num1,num2,num3,num4,num5,var_faranchiseid;
            if done then
                leave read_loop;
            end if;
            
            
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=8 and stattype=1 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 8);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', num1);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', num1);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);
            

            
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=8 and stattype=2 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 8);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', num2);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', num2);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);
            
             
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=8 and stattype=3 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 8);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', num3);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', num3);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);


            
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=8 and stattype=4 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 8);
                set execsql = replace(execsql, '$stattype', 4);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', num4);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', num4);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);
            
            
           set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=8 and stattype=5 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 8);
                set execsql = replace(execsql, '$stattype', 5);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', num5);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', num5);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);

            set insertorupdateid = null;
     
        end loop;
    
    close cur1;

    
    set done = FALSE;

    
    open cur2;
        
        read_loop: loop
            fetch cur2 into num1,num2,num3,num4,num5,var_faranchiseid;
            if done then
                leave read_loop;
            end if;
            
            
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=8 and stattype=1 and type = 2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 8);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', num1);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', num1);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);
            
            
            
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=8 and stattype=2 and type = 2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 8);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', num2);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', num2);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);
            
             
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=8 and stattype=3 and type = 2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 8);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', num3);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', num3);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);


            
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=8 and stattype=4 and type = 2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 8);
                set execsql = replace(execsql, '$stattype', 4);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', num4);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', num4);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);
            
            
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=8 and stattype=5 and type = 2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 8);
                set execsql = replace(execsql, '$stattype', 5);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', num5);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', num5);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);

            set insertorupdateid = null;

        end loop;
    
    close cur2;

    if code = '00000' then  
        commit;
    else                    
        ROLLBACK;
        insert into snap_log(`companyname`,`code`,`msg`,`log_time`) values(name,code,msg,now());
    end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `faranchise_stat_ability_optinvalid_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `faranchise_stat_ability_optinvalid_proc`(IN statdate varchar(20),IN startdate varchar(20),IN enddate varchar(20))
BEGIN
    declare years varchar(20) default '';
    declare months varchar(20) default '';
    declare num1 int(10); 
    declare num2 int(10); 
    declare num3 int(10); 
    declare num4 int(10); 
    declare num5 int(10); 
    declare var_faranchiseid int(10); 
    declare monthfield varchar(20); 
    declare execsql varchar(2000) default ''; 
    declare insertsql varchar(2000) default ''; 
    declare updatesql varchar(2000) default ''; 
    declare insertorupdateid int(10); 
    declare done TINYINT DEFAULT 0;
    declare code varchar(20) default '00000'; 
    declare name varchar(20);                 
    declare msg varchar(500);                 
    
    
    declare cur1 cursor for 
    SELECT count(if(DATE_FORMAT(osu.stageupdatetime,'%Y-%m-%d') <= enddate AND osu.islaststage= 1 AND  osu.stageid= 2 AND osu.optstatus=1,1,null)) 
            +count(if((osu.laststageid=2 OR (osu.optstatus IN (3,4,5) AND osu.stageid=2)) AND DATE_FORMAT(osu.statusupdatetime,'%Y-%m-%d') BETWEEN startdate AND enddate,1,null)) as num1,
            
             count(if(DATE_FORMAT(osu.stageupdatetime,'%Y-%m-%d') <= enddate AND osu.islaststage= 1 AND  osu.stageid= 3 AND osu.optstatus=1,1,null)) 
            +count(if((osu.laststageid=3 OR (osu.optstatus IN (3,4,5) AND osu.stageid=3)) AND DATE_FORMAT(osu.statusupdatetime,'%Y-%m-%d') BETWEEN startdate AND enddate,1,null)) as num2,
            
             count(if(DATE_FORMAT(osu.stageupdatetime,'%Y-%m-%d') <= enddate AND osu.islaststage= 1 AND  osu.stageid= 4 AND osu.optstatus=1,1,null)) 
            +count(if((osu.laststageid=4 OR (osu.optstatus IN (3,4,5) AND osu.stageid=4)) AND DATE_FORMAT(osu.statusupdatetime,'%Y-%m-%d') BETWEEN startdate AND enddate,1,null)) as num3,
            
             count(if(DATE_FORMAT(osu.stageupdatetime,'%Y-%m-%d') <= enddate AND osu.islaststage= 1 AND  osu.stageid= 5 AND osu.optstatus=1,1,null)) 
            +count(if((osu.laststageid=5 OR (osu.optstatus IN (3,4,5) AND osu.stageid=5)) AND DATE_FORMAT(osu.statusupdatetime,'%Y-%m-%d') BETWEEN startdate AND enddate,1,null)) as num4,
            
             count(if(DATE_FORMAT(osu.stageupdatetime,'%Y-%m-%d') <= enddate AND osu.islaststage= 1 AND  osu.stageid= 6 AND osu.optstatus=1,1,null)) 
            +count(if((osu.laststageid=6 OR (osu.optstatus IN (3,4,5) AND osu.stageid=6)) AND DATE_FORMAT(osu.statusupdatetime,'%Y-%m-%d') BETWEEN startdate AND enddate,1,null)) as num5,  
            osu.faranchiseid
    FROM optstageupdatesnap osu
    WHERE osu.isdelete = 0 AND osu.snapdate = statdate AND osu.faranchiseid IS NOT NULL 
    group by osu.faranchiseid ;

    
    declare cur2 cursor for 
    SELECT  count(if(osu.optstatus IN (3,4,5)   AND (osu.stageid=2 OR osu.laststageid=2),1,NULL)) as num1,
                         
            count(if( osu.optstatus IN (3,4,5)  AND (osu.stageid=3 OR osu.laststageid=3),1,NULL)) as num2,
                         
            count(if(osu.optstatus IN (3,4,5)   AND (osu.stageid=4 OR osu.laststageid=4),1,NULL)) as num3,
                         
            count(if( osu.optstatus IN (3,4,5)  AND (osu.stageid=5 OR osu.laststageid=5),1,NULL)) as num4,
                         
            count(if( osu.optstatus IN (3,4,5)  AND (osu.stageid=6 OR osu.laststageid=6),1,NULL)) as num5,
            osu.faranchiseid
    FROM optstageupdatesnap osu
    WHERE osu.isdelete = 0  AND osu.snapdate = statdate AND osu.faranchiseid IS NOT NULL AND DATE_FORMAT(osu.statusupdatetime,'%Y-%m-%d') BETWEEN startdate AND enddate 
    group by osu.faranchiseid ;

    declare continue handler for not found set done = 1;
    declare continue handler for sqlexception 
    BEGIN
        GET DIAGNOSTICS CONDITION 1
        code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
    END;                                      
    set name = (select companyname from systemconfig limit 1); 
    start transaction; 
    
    set years =   left(statdate,4);
    set months =  right(statdate,2);
    set monthfield = concat('m',months);
    set execsql = '';
    set insertsql = concat('insert into abilitystat(statclass, stattype,type, ',monthfield,', years, faranchiseid) values($statclass, $stattype,$type, $nums, $years, $faranchiseid)');
    
    set updatesql = concat('update abilitystat set ',monthfield,' = $nums where id = $id');


    
    open cur1;
        
        read_loop: loop
            fetch cur1 into num1,num2,num3,num4,num5,var_faranchiseid;
            if done then
                leave read_loop;
            end if;
            
            
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=10 and stattype=1 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 10);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', num1);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', num1);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);
            

            
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=10 and stattype=2 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 10);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', num2);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', num2);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);
            
             
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=10 and stattype=3 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 10);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', num3);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', num3);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);


            
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=10 and stattype=4 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 10);
                set execsql = replace(execsql, '$stattype', 4);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', num4);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', num4);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);
            
            
           set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=10 and stattype=5 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 10);
                set execsql = replace(execsql, '$stattype', 5);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', num5);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', num5);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);

            set insertorupdateid = null;

        end loop;
    
    close cur1;

    
    set done = FALSE;

    
    open cur2;
        
        read_loop: loop
            fetch cur2 into num1,num2,num3,num4,num5,var_faranchiseid;
            if done then
                leave read_loop;
            end if;
            
            
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=10 and stattype=1 and type = 2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 10);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', num1);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', num1);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);
            
            
            
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=10 and stattype=2 and type = 2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 10);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', num2);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', num2);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);
            
             
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=10 and stattype=3 and type = 2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 10);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', num3);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', num3);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);


            
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=10 and stattype=4 and type = 2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 10);
                set execsql = replace(execsql, '$stattype', 4);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', num4);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', num4);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);
            
            
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=10 and stattype=5 and type = 2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 10);
                set execsql = replace(execsql, '$stattype', 5);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', num5);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', num5);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);

            set insertorupdateid = null;
   
        end loop;
    
    close cur2;

    if code = '00000' then  
        commit;
    else                    
        ROLLBACK;
        insert into snap_log(`companyname`,`code`,`msg`,`log_time`) values(name,code,msg,now());
    end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `faranchise_stat_ability_optreceivingperiod_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `faranchise_stat_ability_optreceivingperiod_proc`(IN statdate varchar(20),IN startdate varchar(20),IN enddate varchar(20))
BEGIN
    declare years varchar(20) default '';
    declare months varchar(20) default '';
    declare num1 int(10); 
    declare num2 int(10); 
    declare num3 int(10); 
    declare num4 int(10); 
    declare num5 int(10); 
    declare var_faranchiseid int(10); 
    declare monthfield varchar(20); 
    declare execsql varchar(2000) default ''; 
    declare insertsql varchar(2000) default ''; 
    declare updatesql varchar(2000) default ''; 
    declare insertorupdateid int(10); 
    declare done TINYINT DEFAULT 0;
    declare code varchar(20) default '00000'; 
    declare name varchar(20);                 
    declare msg varchar(500);                 
    
    
    declare cur1 cursor for 
    SELECT ifnull(cast(sum(if(osu.stageid= 2,osu.remaindays,0)) 
        /count(if(osu.stageid= 2,1,null)) as DECIMAL(14,2)),0) as num1,
        ifnull(cast(sum(if(osu.stageid= 3,osu.remaindays,0)) 
        /count(if(osu.stageid= 3,1,null)) as DECIMAL(14,2)),0) as num2,
        ifnull(cast(sum(if(osu.stageid= 4,osu.remaindays,0)) 
        /count(if(osu.stageid= 4,1,null)) as DECIMAL(14,2)),0) as num3,
        ifnull(cast(sum(if(osu.stageid= 5,osu.remaindays,0)) 
        /count(if(osu.stageid= 5,1,null)) as DECIMAL(14,2)),0) as num4,
        ifnull(cast(sum(if(osu.stageid= 6,osu.remaindays,0)) 
        /count(if(osu.stageid= 6,1,null)) as DECIMAL(14,2)),0) as num5,
        osu.faranchiseid
    FROM optstageupdatesnap osu
    WHERE  osu.isdelete = 0 and DATE_FORMAT(osu.stageupdatetime,'%Y-%m-%d') <= enddate and osu.islaststage=0 AND osu.snapdate = statdate  AND osu.faranchiseid IS NOT NULL
    group by osu.faranchiseid ;

    declare continue handler for not found set done = 1;
    declare continue handler for sqlexception 
    BEGIN
        GET DIAGNOSTICS CONDITION 1
        code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
    END;                                      
    set name = (select companyname from systemconfig limit 1); 
    start transaction; 
    
    set years =   left(statdate,4);
    set months =  right(statdate,2);
    set monthfield = concat('m',months);
    set execsql = '';
    set insertsql = concat('insert into abilitystat(statclass, stattype,type, ',monthfield,', years, faranchiseid) values($statclass, $stattype,$type, $nums, $years, $faranchiseid)');
    
    set updatesql = concat('update abilitystat set ',monthfield,' = $nums where id = $id');


    
    open cur1;
        
        read_loop: loop
            fetch cur1 into num1,num2,num3,num4,num5,var_faranchiseid;
            if done then
                leave read_loop;
            end if;
            
            
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=9 and stattype=1 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 9);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', num1);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', num1);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);
            

            
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=9 and stattype=2 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 9);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', num2);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', num2);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);
            
             
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=9 and stattype=3 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 9);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', num3);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', num3);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);


            
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=9 and stattype=4 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 9);
                set execsql = replace(execsql, '$stattype', 4);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', num4);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', num4);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);
            
            
           set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=9 and stattype=5 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 9);
                set execsql = replace(execsql, '$stattype', 5);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', num5);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', num5);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);

            set insertorupdateid = null;
     
        end loop;
    
    close cur1;

    if code = '00000' then  
        commit;
    else                    
        ROLLBACK;
        insert into snap_log(`companyname`,`code`,`msg`,`log_time`) values(name,code,msg,now());
    end if;
  
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `faranchise_stat_ability_orderdistribution_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `faranchise_stat_ability_orderdistribution_proc`(IN statdate varchar(20),IN startdate varchar(20),IN enddate varchar(20))
BEGIN
    declare years varchar(20) default '';
    declare months varchar(20) default '';
    declare totalprice decimal(14,2); 
    declare totalpriceminor decimal(14,2); 
    declare var_ownerid int(10); 
    declare monthfield varchar(20); 
    declare execsql varchar(2000) default ''; 
    declare insertsql varchar(2000) default ''; 
    declare updatesql varchar(2000) default ''; 
    declare insertorupdateid int(10); 
    declare done TINYINT DEFAULT 0;
    declare code varchar(20) default '00000'; 
    declare name varchar(20);                 
    declare msg varchar(500);                 
    
    
    declare cur1 cursor for 
    select opt.ownerid,
        sum(ifnull(
            if(opt.currencyid=1,
                opt.totalprice,
                opt.totalpriceminor*cast(ifnull(cc.intoajformula,lasc.formula) as DECIMAL(14,2))) ,0)) as totalprice,
        sum(ifnull(
            if(opt.currencyid=2,
                opt.totalpriceminor,
                opt.totalprice*cast(ifnull(cc.ajtoinformula,lasc.formula) as DECIMAL(14,2))) ,0)) as totalpriceminor
    from optrealsnap as opt
    left join currencyconvert cc ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
    left join (select intoajformula formula from currencyconvert ORDER BY id desc limit 1) lasc ON 1=1
    where opt.snapdate = statdate and opt.optstatus = 2 group by opt.ownerid;

     
    declare cur2 cursor for 
     select opt.ownerid,
        sum(ifnull(
            if(opt.currencyid=1,
                opt.totalprice,
                opt.totalpriceminor*cast(ifnull(cc.intoajformula,lasc.formula) as DECIMAL(14,2))) ,0)) as totalprice,
        sum(ifnull(
            if(opt.currencyid=2,
                opt.totalpriceminor,
                opt.totalprice*cast(ifnull(cc.ajtoinformula,lasc.formula) as DECIMAL(14,2))) ,0)) as totalpriceminor
    from optrealsnap as opt
    left join currencyconvert cc ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
    left join (select intoajformula formula from currencyconvert ORDER BY id desc limit 1) lasc ON 1=1
    where opt.snapdate = statdate  and opt.isestimate = 1 and opt.optstatus = 2 group by opt.ownerid;

      
    declare cur3 cursor for 
     select opt.ownerid,
        sum(ifnull(
            if(opt.currencyid=1,
                opt.totalprice,
                opt.totalpriceminor*cast(ifnull(cc.intoajformula,lasc.formula) as DECIMAL(14,2))) ,0)) as totalprice,
        sum(ifnull(
            if(opt.currencyid=2,
                opt.totalpriceminor,
                opt.totalprice*cast(ifnull(cc.ajtoinformula,lasc.formula) as DECIMAL(14,2))) ,0)) as totalpriceminor
    from optrealsnap as opt
    left join currencyconvert cc ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
    left join (select intoajformula formula from currencyconvert ORDER BY id desc limit 1) lasc ON 1=1
    where opt.snapdate = statdate  and opt.isestimate = 0 and opt.optstatus = 2 group by opt.ownerid;

    
    declare cur4 cursor for 
        select  ifnull(optr.ownerid,fd.ownerid) ownerid,ifnull(fd.totalprice,0)-ifnull(optr.totalprice,0) totalprice,
            ifnull(fd.totalpriceminor,0)-ifnull(optr.totalpriceminor,0) totalpriceminor from         
                ( select opt.ownerid,
            sum(ifnull(
                if(opt.currencyid=1,
                opt.totalprice,
                opt.totalpriceminor*cast(ifnull(cc.intoajformula,lasc.formula) as DECIMAL(14,2))) ,0)) as totalprice,
            sum(ifnull(
                if(opt.currencyid=2,
                    opt.totalpriceminor,
                    opt.totalprice*cast(ifnull(cc.ajtoinformula,lasc.formula) as DECIMAL(14,2))) ,0)) as totalpriceminor
            from optrealsnap as opt
            left join currencyconvert cc ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
            left join (select intoajformula formula from currencyconvert ORDER BY id desc limit 1) lasc ON 1=1
            where opt.snapdate = statdate and opt.optstatus = 2 group by opt.ownerid) optr    
        left join        
                (select 
                    fd.employeeid AS ownerid , 
                    fd.ordermoney totalprice,
                    fd.ordermoneyminor totalpriceminor
                    from  financialdata  as fd 
                    where  fd.createdatetime between startdate and enddate group by fd.employeeid) fd
                    on optr.ownerid = fd.ownerid
        union     
                select  ifnull(optr.ownerid,fd.ownerid) ownerid,ifnull(fd.totalprice,0)-ifnull(optr.totalprice,0) totalprice,
                    ifnull(fd.totalpriceminor,0)-ifnull(optr.totalpriceminor,0) totalpriceminor from         
                (select 
                    fd.employeeid AS ownerid , 
                    fd.ordermoney totalprice,
                    fd.ordermoneyminor totalpriceminor
                    from  financialdata  as fd 
                    where  fd.createdatetime between startdate and enddate group by fd.employeeid) fd   
                left join    
                    ( select opt.ownerid,
                sum(ifnull(
                    if(opt.currencyid=1,
                        opt.totalprice,
                        opt.totalpriceminor*cast(ifnull(cc.intoajformula,lasc.formula) as DECIMAL(14,2))) ,0)) as totalprice,
                sum(ifnull(
                    if(opt.currencyid=2,
                        opt.totalpriceminor,
                        opt.totalprice*cast(ifnull(cc.ajtoinformula,lasc.formula) as DECIMAL(14,2))) ,0)) as totalpriceminor
                from optrealsnap as opt
                left join currencyconvert cc ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
                left join (select intoajformula formula from currencyconvert ORDER BY id desc limit 1) lasc ON 1=1
                where opt.snapdate = statdate and opt.optstatus = 2 group by opt.ownerid) optr                       
                on fd.ownerid = optr.ownerid;
          
    declare cur5 cursor for 
        select fd.employeeid AS ownerid , 
               fd.ordermoney totalprice,
               fd.ordermoneyminor totalpriceminor
        from  financialdata  as fd  
        where  fd.createdatetime between startdate and enddate group by fd.employeeid;


    declare continue handler for not found set done = TRUE;
    declare continue handler for sqlexception 
    BEGIN
        GET DIAGNOSTICS CONDITION 1
        code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
    END;                                      
    set name = (select companyname from systemconfig limit 1); 
    start transaction; 

    set years =   left(statdate,4);
    set months =  right(statdate,2);
    set monthfield = concat('m',months);
    set execsql = '';
    set insertsql = concat('insert into abilitystat(statclass, stattype, type, ',monthfield,', years, employeeid) values($statclass, $stattype, $type, $nums, $years, $ownerid)');
    
    set updatesql = concat('update abilitystat set ',monthfield,' = $nums where id = $id');

      
    open cur1;
        
        read_loop: loop
            fetch cur1 into var_ownerid,totalprice,totalpriceminor;
            if done then
                leave read_loop;
            end if;
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=2 and stattype=1 and type=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 2);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', totalprice);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', totalprice);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=2 and stattype=1 and type=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 2);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', totalpriceminor);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', totalpriceminor);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
          
            set insertorupdateid = null;

        end loop;
    
    close cur1;

    SET done = FALSE;
    
    open cur2;
        
        read_loop: loop
            fetch cur2 into var_ownerid,totalprice,totalpriceminor;
            if done then
                leave read_loop;
            end if;
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=2 and stattype=2 and type=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 2);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', totalprice);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', totalprice);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=2 and stattype=2 and type=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 2);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', totalpriceminor);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', totalpriceminor);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
          
            set insertorupdateid = null;
           
        end loop;
    
    close cur2;

    SET done = FALSE;

    
    open cur3;
        
        read_loop: loop
            fetch cur3 into var_ownerid,totalprice,totalpriceminor;
            if done then
                leave read_loop;
            end if;
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=2 and stattype=3 and type=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 2);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', totalprice);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', totalprice);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=2 and stattype=3 and type=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 2);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', totalpriceminor);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', totalpriceminor);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
          
            set insertorupdateid = null;
   
        end loop;
    
    close cur3;

    SET done = FALSE;

    
    open cur4;
        
        read_loop: loop
            fetch cur4 into var_ownerid,totalprice,totalpriceminor;
            if done then
                leave read_loop;
            end if;
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=2 and stattype=4 and type=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 2);
                set execsql = replace(execsql, '$stattype', 4);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', totalprice);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', totalprice);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=2 and stattype=4 and type=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 2);
                set execsql = replace(execsql, '$stattype', 4);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', totalpriceminor);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', totalpriceminor);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
          
            set insertorupdateid = null;
          
        end loop;
    
    close cur4;

    SET done = FALSE;

    
    open cur5;
        
        read_loop: loop
            fetch cur5 into var_ownerid,totalprice,totalpriceminor;
            if done then
                leave read_loop;
            end if;
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=2 and stattype=5 and type=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 2);
                set execsql = replace(execsql, '$stattype', 5);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', totalprice);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', totalprice);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=2 and stattype=5 and type=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 2);
                set execsql = replace(execsql, '$stattype', 5);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', totalpriceminor);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', totalpriceminor);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
          
            set insertorupdateid = null;
        
        end loop;
    
    close cur5;
    SET done = FALSE;

    if code = '00000' then  
        commit;
    else                    
        ROLLBACK;
        insert into snap_log(`companyname`,`code`,`msg`,`log_time`) values(name,code,msg,now());
    end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `faranchise_stat_ability_orderreceivingmoney_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `faranchise_stat_ability_orderreceivingmoney_proc`(IN statdate varchar(20))
BEGIN
    declare years varchar(20) default '';
    declare months varchar(20) default '';
    declare totalprice decimal(14,2); -- 主货币总金额
    declare totalpriceminor decimal(14,2); -- 辅货币总金额
    declare var_faranchiseid int(10); -- 代理商id
    declare monthfield varchar(20); -- 月份字段名
    declare execsql varchar(2000) default ''; -- 执行sql语句字符串
    declare insertsql varchar(2000) default ''; -- 插入  sql字符串
    declare updatesql varchar(2000) default ''; -- 更新  sql字符串
    declare insertorupdateid int(10); -- 更新或插入后的id
    declare done TINYINT DEFAULT 0;
    declare code varchar(20) default '00000'; -- 错误代码
    declare name varchar(20);                 -- 公司名称
    declare msg varchar(500);                 -- 错误信息
    
    -- 预计接单金额 接单
    declare cur1 cursor for 
    select sum(opte.totalprice) as totalprice,sum(opte.totalpriceminor) as totalpriceminor,opt.faranchiseid 
    from (select opt.optid,opt.snapdate,opt.optstatus,
                ifnull(
                    if(opt.currencyid=1,
                     opt.totalprice,
                     opt.totalpriceminor*cast(ifnull(cc.intoajformula,lasc.formula) as DECIMAL(14,2))) ,0) totalprice,
               ifnull(
                   if(opt.currencyid=2,
                      opt.totalpriceminor,
                      opt.totalprice*cast(ifnull(cc.ajtoinformula,lasc.formula) as DECIMAL(14,2))) ,0) totalpriceminor
                from optestimatesnap opt
                  left join currencyconvert cc ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
                  left join (select intoajformula formula from currencyconvert ORDER BY id desc limit 1) lasc ON 1=1
                  where snapdate=statdate
           ) opte
    left join optrealsnap opt on opte.optid=opt.optid and opt.snapdate=opte.snapdate
    where opt.faranchiseid is not null and opte.optstatus=1
    group by opt.faranchiseid;

     -- 实际接单金额 接单
    declare cur2 cursor for 
    select sum(opt.totalprice) as totalprice,sum(opt.totalpriceminor) as totalpriceminor,opt.faranchiseid 
    from (select optid,snapdate from optestimatesnap where snapdate=statdate) opte
     left join (select opt.optid,opt.snapdate,opt.faranchiseid,opt.optstatus,
                 ifnull(
                    if(opt.currencyid=1,
                     opt.totalprice,
                     opt.totalpriceminor*cast(ifnull(cc.intoajformula,lasc.formula) as DECIMAL(14,2))) ,0) totalprice,
               ifnull(
                   if(opt.currencyid=2,
                      opt.totalpriceminor,
                      opt.totalprice*cast(ifnull(cc.ajtoinformula,lasc.formula) as DECIMAL(14,2))) ,0) totalpriceminor
                from optrealsnap opt
                  left join currencyconvert cc ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
                  left join (select intoajformula formula from currencyconvert ORDER BY id desc limit 1) lasc
                    ON 1=1) opt on opte.optid=opt.optid and opt.snapdate=opte.snapdate
     where  opt.optstatus=2 and opt.faranchiseid is not null group by opt.faranchiseid;

    declare continue handler for not found set done = TRUE;
    declare continue handler for sqlexception 
    BEGIN
        GET DIAGNOSTICS CONDITION 1
        code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
    END;                                      --  当错误时,赋值错误代码,错误信息
    set name = (select companyname from systemconfig limit 1); -- 获取公司名称
    start transaction; -- 开启事物

    set years =   left(statdate,4);
    set months =  right(statdate,2);
    set monthfield = concat('m',months);
    set execsql = '';
    set insertsql = concat('insert into abilitystat(statclass, stattype, type, ',monthfield,', years, faranchiseid) values($statclass, $stattype, $type, $nums, $years, $faranchiseid)');
 
    set updatesql = concat('update abilitystat set ',monthfield,' = $nums where id = $id');

      /* 打开游标 */
    open cur1;
        /* 遍历数据表 */
        read_loop: loop
            fetch cur1 into totalprice,totalpriceminor,var_faranchiseid;
            if done then
                leave read_loop;
            end if;
            
            /*-----主货币 预测金额-----*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=4 and stattype=1 and type=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 4);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', totalprice);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', totalprice);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----辅货币 预测金额------*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=4 and stattype=1 and type=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 4);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', totalpriceminor);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', totalpriceminor);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
          
            set insertorupdateid = null;
      
        end loop;
    /* 关闭游标 */
    close cur1;

    SET done = FALSE;
     /* 打开游标 */
    open cur2;
        /* 遍历数据表 */
        read_loop: loop
            fetch cur2 into totalprice,totalpriceminor,var_faranchiseid;
            if done then
                leave read_loop;
            end if;
            
            /*----主货币 接单金额-----*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=4 and stattype=2 and type=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 4);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', totalprice);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', totalprice);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----辅货币 接单金额------*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=4 and stattype=2 and type=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 4);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', totalpriceminor);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', totalpriceminor);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
          
            set insertorupdateid = null;
        
        end loop;
    /* 关闭游标 */
    close cur2;

    if code = '00000' then  -- 如果没有错误,提交
        commit;
    else                    -- 有错误则回滚,插入错误信息
        ROLLBACK;
        insert into snap_log(`companyname`,`code`,`msg`,`log_time`) values(name,code,msg,now());
    end if;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `faranchise_stat_ability_orderreceiving_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `faranchise_stat_ability_orderreceiving_proc`(IN statdate varchar(20))
BEGIN
    declare years varchar(20) default '';
    declare months varchar(20) default '';
    declare successnums int(10); -- 成功的数量
    declare failingnums int(10); -- 失败的数量
    declare followingnums int(10); -- 跟踪的数量
    declare suspendingnums int(10); -- 搁置的数量
    declare invalidationnums int(10); -- 失效的数量
    declare var_faranchiseid int(10); -- 代理商id
    declare monthfield varchar(20); -- 月份字段名
    declare execsql varchar(2000) default ''; -- 执行sql语句字符串
    declare insertsql varchar(2000) default ''; -- 插入  sql字符串
    declare updatesql varchar(2000) default ''; -- 更新  sql字符串
    declare insertorupdateid int(10); -- 更新或插入后的id
    declare done TINYINT DEFAULT 0;
    declare code varchar(20) default '00000'; -- 错误代码
    declare name varchar(20);                 -- 公司名称
    declare msg varchar(500);                 -- 错误信息
    
    declare cur cursor for 
    select count(if(opt.optstatus=2 and opt.stageid=7,opt.id,null)) as success,
    count(if(opt.optstatus=4, opt.id,null)) as failing, count(if(opt.optstatus=1, opt.id,null)) as following,
    count(if(opt.optstatus=3, opt.id,null)) as suspending, count(if(opt.optstatus=5, opt.id,null)) as invalidation,opt.faranchiseid 
    from (select optid,snapdate,optstatus from optestimatesnap where snapdate=statdate) opte
     left join optrealsnap opt on opte.optid=opt.optid and opt.snapdate=opte.snapdate
     where opt.faranchiseid is not null and opte.optstatus=1
     group by opt.faranchiseid;

    declare continue handler for not found set done = 1;
    declare continue handler for sqlexception 
    BEGIN
        GET DIAGNOSTICS CONDITION 1
        code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
    END;                                      --  当错误时,赋值错误代码,错误信息
    set name = (select companyname from systemconfig limit 1); -- 获取公司名称
    start transaction; -- 开启事物

    set years =   left(statdate,4);
    set months =  right(statdate,2);
    set monthfield = concat('m',months);
    set execsql = '';
    set insertsql = concat('insert into abilitystat(statclass, stattype, ',monthfield,', years, faranchiseid) values($statclass, $stattype, $nums, $years, $faranchiseid)');
    
    set updatesql = concat('update abilitystat set ',monthfield,' = $nums where id = $id');

    /* 打开游标 */
    open cur;
        /* 遍历数据表 */
        read_loop: loop
            fetch cur into successnums,failingnums,followingnums,suspendingnums,invalidationnums,var_faranchiseid;
            if done then
                leave read_loop;
            end if;
            
            /*-----接单-----*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=3 and stattype=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 3);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$nums', successnums);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', successnums);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            -- insert into debug(debug) values(execsql);
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----失单-----*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=3 and stattype=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 3);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$nums', failingnums);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', failingnums);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----转移-----*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=3 and stattype=3) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 3);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$nums', followingnums);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', followingnums);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----搁置-----*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=3 and stattype=4) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 3);
                set execsql = replace(execsql, '$stattype', 4);
                set execsql = replace(execsql, '$nums', suspendingnums);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', suspendingnums);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----失效-----*/
            set insertorupdateid = (select id from abilitystat where faranchiseid = var_faranchiseid and `years` = years and statclass=3 and stattype=5) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 3);
                set execsql = replace(execsql, '$stattype', 5);
                set execsql = replace(execsql, '$nums', invalidationnums);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$faranchiseid', var_faranchiseid);
            else
                set execsql = replace(updatesql, '$nums', invalidationnums);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);

            set insertorupdateid = null;
         
        end loop;
    /* 关闭游标 */
    close cur;

    if code = '00000' then  -- 如果没有错误,提交
        commit;
    else                    -- 有错误则回滚,插入错误信息
        ROLLBACK;
        insert into snap_log(`companyname`,`code`,`msg`,`log_time`) values(name,code,msg,now());
    end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getAllDepartById` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `getAllDepartById`(IN depId INT,OUT sResult varchar(4000))
BEGIN
	
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getAllDepartByIdList` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `getAllDepartByIdList`(IN departIds VARCHAR(4000),OUT sResult varchar(4000))
BEGIN
	
	DECLARE cTemp VARCHAR (20); 
    DECLARE sTemp VARCHAR (4000); 
    
	SET cTemp = '';
	SET sTemp = '';
    
	IF departIds IS NOT NULL THEN
		
		WHILE departIds != '' DO
			SET cTemp = substring_index(departIds,',',1);
            SET departIds = substring(departIds,length(cTemp)+2,length(departIds));
            IF cTemp != '' THEN
				CALL getAllDepartById(cTemp,sTemp);
				SET sResult = concat_ws(',',sTemp,sResult);
            END IF;
		END WHILE;		
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `opt_snapshot_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `opt_snapshot_proc`()
BEGIN
    declare ispart int;
    declare starting_month int;
    declare currentToM varchar(20);
    declare intCurrentM int;
    declare currentY int;
    declare stat_date varchar(20); 
    declare nowmonthStart varchar(20);
    declare nowmonthEnd varchar(20);
    declare nowmonthint varchar(20);
    declare nextmonthint varchar(20);
    declare snap_date varchar(20);
    declare next1MStart varchar(20);
    declare next1MEnd varchar(20);
    declare execsql varchar(2000); 
    declare partitionname varchar(20);

    declare code varchar(20) default '00000'; 
    declare name varchar(20);                 
    declare msg varchar(500);                 

    declare continue handler for sqlexception 
    BEGIN
      GET DIAGNOSTICS CONDITION 1
        code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
    END;                                      
    
    set name = (select companyname from systemconfig limit 1);  

    select snapdate,startingmonth into snap_date,starting_month from customtime where id = 1;
    
    
    set next1MStart= date_format(date_add(snap_date,interval 1 day),'%Y-%m-%d');
    set next1MEnd = date_format(date_add(snap_date,interval 1 month),'%Y-%m-%d');
    

    set nowmonthStart = date_format(date_add(date_sub(snap_date,interval 1 month),interval 1 day),'%Y-%m-%d');
    set nowmonthEnd = snap_date;

    set nowmonthint = date_format(nowmonthStart, '%Y%m');
    set nextmonthint = date_format(next1MStart, '%Y%m');

    set intCurrentM = date_format(nowmonthStart, '%c');
    
    set currentToM = intCurrentM-starting_month+1;
    set currentY = date_format(nowmonthStart, '%Y');

    if currentToM <= 0 then 
        set currentToM = currentToM + 12;
        set currentY = currentY-1;
    end if;

    if currentToM < 10 then 
        set currentToM = concat('0',currentToM);
    end if;
    set stat_date = concat(currentY,currentToM);

    
    
     start transaction;
        
        insert into optestimatesnap(`optid`, `optno`, `leadid`, `sourceid`, `customerid`, `opttype`, `optname`, `totalprice`, `totalpriceminor`, `totalcost`, `totalcostminor`, `optexpend`, `otherexpend`, `planoverdate`, `realityoverdate`, `possibilityid`, `stageid`, `createrid`, `createdatetime`, `confidenceindex`, `optstatus`, `optlevel`, `remark`, `ownerid`, `procurementmethodid`, `faranchiseid`, `currencyid`,`snapdate`)
        select `id`, `optno`, `leadid`, `sourceid`, `customerid`, `opttype`, `optname`, `totalprice`, `totalpriceminor`, `totalcost`, `totalcostminor`, `optexpend`, `otherexpend`, `planoverdate`, `realityoverdate`, `possibilityid`, `stageid`, `createrid`, `createdatetime`, `confidenceindex`, `optstatus`, `optlevel`, `remark`, `ownerid`, `procurementmethodid`, `faranchiseid`, `currencyid`,nextmonthint
        from opt 
        where date_format(planoverdate,'%Y-%m-%d') between next1MStart and next1MEnd and isdelete = 0;
        
        insert into optestimatesnapproduct(`optproductid`, `optid`, `brandname`, `classname`, `productid`, `productmodel`, `productname`, `specification`, `productdiscribe`, `rmbcost`, `rmbprice`, `dollarcost`, `dollarprice`, `num`, `discount`, `remark`, `pmid`, `currencyexchangerate`,`snapdate`)
        select optproduct.`id`, optproduct.`optid`, optproduct.`brandname`, optproduct.`classname`, optproduct.`productid`, optproduct.`productmodel`, optproduct.`productname`, optproduct.`specification`, optproduct.`productdiscribe`, optproduct.`rmbcost`, optproduct.`rmbprice`, optproduct.`dollarcost`, optproduct.`dollarprice`, optproduct.`num`, optproduct.`discount`, optproduct.`remark`, optproduct.`pmid`, optproduct.`currencyexchangerate`, nextmonthint
        from opt 
        left join optproduct 
        on opt.id = optproduct.optid 
        where date_format(opt.planoverdate,'%Y-%m-%d') between next1MStart and next1MEnd and opt.isdelete = 0;
        
        
        insert into optrealsnap(`optid`, `optno`, `leadid`, `sourceid`, `customerid`, `opttype`, `optname`, `totalprice`, `totalpriceminor`, `totalcost`, `totalcostminor`, `optexpend`, `otherexpend`, `planoverdate`, `realityoverdate`, `possibilityid`, `stageid`, `createrid`, `createdatetime`, `confidenceindex`, `optstatus`, `optlevel`, `remark`, `ownerid`, `procurementmethodid`, `faranchiseid`, `currencyid`,`snapdate`,`isestimate`)
        select `id`, `optno`, `leadid`, `sourceid`, `customerid`, `opttype`, `optname`, `totalprice`, `totalpriceminor`, `totalcost`, `totalcostminor`, `optexpend`, `otherexpend`, `planoverdate`, `realityoverdate`, `possibilityid`, `stageid`, `createrid`, `createdatetime`, `confidenceindex`, `optstatus`, `optlevel`, `remark`, `ownerid`, `procurementmethodid`, `faranchiseid`, `currencyid`, nowmonthint,1
        from opt
        where id in (select optid from optestimatesnap where snapdate = nowmonthint) ;
        
        insert into optrealsnapproduct(`optproductid`, `optid`, `brandname`, `classname`, `productid`, `productmodel`, `productname`, `specification`, `productdiscribe`, `rmbcost`, `rmbprice`, `dollarcost`, `dollarprice`, `num`, `discount`, `remark`, `pmid`, `currencyexchangerate`,`snapdate`)
        select optproduct.`id`, optproduct.`optid`, optproduct.`brandname`, optproduct.`classname`, optproduct.`productid`, optproduct.`productmodel`, optproduct.`productname`, optproduct.`specification`, optproduct.`productdiscribe`, optproduct.`rmbcost`, optproduct.`rmbprice`, optproduct.`dollarcost`, optproduct.`dollarprice`, optproduct.`num`, optproduct.`discount`, optproduct.`remark`, optproduct.`pmid`, optproduct.`currencyexchangerate`, nowmonthint
        from opt 
        left join optproduct 
        on opt.id = optproduct.optid 
        where opt.id in (select optid from optestimatesnap where snapdate = nowmonthint);
        
        
        insert into optrealsnap(`optid`, `optno`, `leadid`, `sourceid`, `customerid`, `opttype`, `optname`, `totalprice`, `totalpriceminor`, `totalcost`, `totalcostminor`, `optexpend`, `otherexpend`, `planoverdate`, `realityoverdate`, `possibilityid`, `stageid`, `createrid`, `createdatetime`, `confidenceindex`, `optstatus`, `optlevel`, `remark`, `ownerid`, `procurementmethodid`, `faranchiseid`, `currencyid`,`snapdate`,`isestimate`)
        select `id`, `optno`, `leadid`, `sourceid`, `customerid`, `opttype`, `optname`, `totalprice`, `totalpriceminor`, `totalcost`, `totalcostminor`, `optexpend`, `otherexpend`, `planoverdate`, `realityoverdate`, `possibilityid`, `stageid`, `createrid`, `createdatetime`, `confidenceindex`, `optstatus`, `optlevel`, `remark`, `ownerid`, `procurementmethodid`, `faranchiseid`, `currencyid`, nowmonthint,0
        from opt
        where id not in (select optid from optestimatesnap where snapdate = nowmonthint) and date_format(realityoverdate,'%Y-%m-%d') between nowmonthStart and nowmonthEnd and opt.optstatus in (2,4);
        
        insert into optrealsnapproduct(`optproductid`, `optid`, `brandname`, `classname`, `productid`, `productmodel`, `productname`, `specification`, `productdiscribe`, `rmbcost`, `rmbprice`, `dollarcost`, `dollarprice`, `num`, `discount`, `remark`, `pmid`, `currencyexchangerate`,`snapdate`)
        select optproduct.`id`, optproduct.`optid`, optproduct.`brandname`, optproduct.`classname`, optproduct.`productid`, optproduct.`productmodel`, optproduct.`productname`, optproduct.`specification`, optproduct.`productdiscribe`, optproduct.`rmbcost`, optproduct.`rmbprice`, optproduct.`dollarcost`, optproduct.`dollarprice`, optproduct.`num`, optproduct.`discount`, optproduct.`remark`, optproduct.`pmid`, optproduct.`currencyexchangerate`, nowmonthint
        from opt 
        left join optproduct 
        on opt.id = optproduct.optid 
        where opt.id not in (select optid from optestimatesnap where snapdate = nowmonthint) and date_format(realityoverdate,'%Y-%m-%d') between nowmonthStart and nowmonthEnd and opt.optstatus in (2,4);        
        
       
       set partitionname=concat('p',nowmonthint);
       SELECT count(*) into ispart FROM  INFORMATION_SCHEMA.partitions  WHERE TABLE_SCHEMA = schema()  AND TABLE_NAME="optstageupdatesnap" AND partition_name = partitionname;

       if ispart = 0 then 
           set execsql = concat('alter table optstageupdatesnap add partition (partition p',nowmonthint,' values IN (',nowmonthint,'))');
           set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
       end if;

        
        insert into optstageupdatesnap(`optstageupdateid`, `optid`, `ownerid`,`faranchiseid`, `stageid`, `stageupdatetime`, `optstatus`, `statusupdatetime`, `remaindays`, `islaststage`, `isdelete`, `importreferid`, `laststageid`, `snapdate`)
        select osu.`id`, osu.`optid`, o.`ownerid`,o.`faranchiseid`, osu.`stageid`, osu.`stageupdatetime`, osu.`optstatus`, 
        osu.`statusupdatetime`, osu.`remaindays`, osu.`islaststage`, osu.`isdelete`, osu.`importreferid`, osu.`laststageid`, nowmonthint
        from optstageupdate osu 
        left join opt o on osu.optid=o.id
        where osu.isdelete=0 and o.isdelete=0;

       
        if code = '00000' then  
            call proc_stat_proc(stat_date,stat_date);
            commit;
        else                    
            ROLLBACK;
            insert into snap_log(`companyname`,`code`,`msg`,`log_time`) values(name,code,msg,now());
        end if;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `proc_import_batchCheck` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_import_batchCheck`(
	IN `language` VARCHAR(50)
)
BEGIN
call proc_import_check('zmemory_currencyexchange',language);
call proc_import_check('zmemory_currencyconvert',language);
call proc_import_check('zmemory_empdepart',language);
call proc_import_check('zmemory_empposition',language);

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
call proc_import_check('zmemory_expensetype',language);
call proc_import_check('zmemory_traffictype',language);
call proc_import_check('zmemory_agencytype',language);
call proc_import_check('zmemory_source',language);
call proc_import_check('zmemory_opttype',language);
call proc_import_check('zmemory_optstage',language);

call proc_import_check('zmemory_optcontactrole',language);
call proc_import_check('zmemory_procurementmethod',language);
call proc_import_check('zmemory_faranchise',language);
call proc_import_check('zmemory_opt',language);
call proc_import_check('zmemory_optproduct',language);
call proc_import_check('zmemory_optcontact',language);
call proc_import_check('zmemory_systemconfig',language);





END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `proc_import_check` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
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
    
    DECLARE done INT DEFAULT FALSE;
    
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
	declare decimals CURSOR FOR SELECT COLUMN_NAME,substring_index(substring_index(column_comment,',',-2),',',1),substring_index(column_comment,',',-1)
	  FROM INFORMATION_SCHEMA.Columns WHERE table_name=tableName and left(column_comment,8)='decimals';
    declare equal CURSOR FOR SELECT COLUMN_NAME,substring(column_comment,7) FROM INFORMATION_SCHEMA.Columns WHERE table_name=tableName and left(column_comment,5)='equal';
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

   
    
    
    if language='en'
    then
		    OPEN  cur;     
		    
		    read_loop: LOOP
		            
		            FETCH   cur INTO fieldName;
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
		                from ",tableName," where ",fieldName," is null or ",fieldName,"='{length}'
		                ");
		                
		            PREPARE stmt from @sqlStr;
		            EXECUTE stmt;
		      
		    END LOOP;
		    CLOSE cur;
		    
		    SET done = FALSE;
		     OPEN  cur0;     
			    
			    read_loop: LOOP
			            
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
				    
				    read_loop: LOOP
				            
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
		    
		    read_loop: LOOP
		            
		            FETCH   cur INTO fieldName;
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
		    CLOSE cur;
     end if;


       

    SET done = FALSE;
       OPEN  cur00;     
    read_loop: LOOP
            
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
					from ",tableName," where ",fieldName," is not null and ",fieldName," not in (select ID from ",tomtable," where ID is not null)
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
                when length(",fieldName,")>16  then '",fieldName,"长度不能超过16'
                end 'error'
                from ",tableName," where ",fieldName," REGEXP '^[0-9]*(\\.?)[0-9]*$'=0 or length(",fieldName,")>16
                or ",fieldName,"='{length}'
                ");
            PREPARE stmt from @sqlStr;
            EXECUTE stmt;
    END LOOP;
    CLOSE cur1;

	 SET done = FALSE;
	       OPEN  cur4;     
	    read_loop: LOOP
	            
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
	                when length(",fieldName,")>16  then '",fieldName,"长度不能超过16'
	                end 'error'
	                from ",tableName," where ",fieldName," is null or ",fieldName," REGEXP '^[0-9]*(\\.?)[0-9]*$'=0 or
	                 length(",fieldName,")>16
	                or ",fieldName,"='{length}' ");
	            PREPARE stmt from @sqlStr;
	            EXECUTE stmt;
	    END LOOP;
	    CLOSE cur4;
	    
	    
	    
	   SET done = FALSE;
	   OPEN  cur2;     
	   read_loop: LOOP
	            
	            FETCH   cur2 INTO fieldName;
	            IF done THEN
	                LEAVE read_loop;
	             END IF;
	 
	       set @sqlStr=CONCAT("
	       				 insert into zmemory_question(tableName,row,col,error)
	                select '",tableName,"',row, '",fieldName,"',
	                case 
	                when ",fieldName," REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'=0 then '",fieldName,"必须为日期格式'
	                end 'error'
	                from ",tableName," where  ",fieldName," REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'=0
	                ");
	            PREPARE stmt from @sqlStr;
	            EXECUTE stmt;
	    END LOOP;
	    CLOSE cur2;
	    
	   SET done = FALSE;
	   OPEN  cur5;     
	   read_loop: LOOP
	            
	            FETCH   cur5 INTO fieldName;
	            IF done THEN
	                LEAVE read_loop;
	             END IF;
	 
	       set @sqlStr=CONCAT("
	       			 insert into zmemory_question(tableName,row,col,error)
	                select '",tableName,"',row, '",fieldName,"',
	                case 
	                when ",fieldName," is null then '",fieldName,"不能为空且必须为日期格式'
	                when ",fieldName," REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'=0 then '",fieldName,"必须为日期格式'
	                end 'error'
	                from ",tableName," where ",fieldName," is null or ",fieldName," REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'=0
	                ");
	            PREPARE stmt from @sqlStr;
	            EXECUTE stmt;
	    END LOOP;
	    CLOSE cur5;

	     SET done = FALSE;
	   OPEN  cur7;     
	   read_loop: LOOP
	            
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
	            
	            FETCH   num INTO fieldName,firstnum,lastnum;
	            IF done THEN
	                LEAVE read_loop;
	             END IF;
	 
	        
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
			when length(o.rmbcost)>16  then 'rmbcost长度不能超过16'
			end 'error'
			from zmemory_optproduct o left join (select Distinct ID,currencyID from zmemory_opt) opt
			on o.optID=opt.ID
			where opt.currencyID=1  and o.rmbcost is null
			 or o.rmbcost REGEXP '^[0-9]*(\\.?)[0-9]*$'=0 or length(o.rmbcost)>16 or o.rmbcost='{length}';
			 
			insert into zmemory_question(tableName,row,col,error)
			select 'zmemory_optproduct',o.row,'rmbprice',
			case
			when o.rmbprice is null then 'rmbprice不能为空且必须为数字'
			when o.rmbprice='{length}' then 'rmbprice长度不能超过200'
			when o.rmbprice REGEXP '^[0-9]*(\\.?)[0-9]*$'=0 then 'rmbprice必须为数字'
			when length(o.rmbprice)>16  then 'rmbprice长度不能超过16'
			end 'error'
			from zmemory_optproduct o left join (select Distinct ID,currencyID from zmemory_opt) opt
			on o.optID=opt.ID
			where opt.currencyID=1  and o.rmbprice is null
			 or o.rmbprice REGEXP '^[0-9]*(\\.?)[0-9]*$'=0 or length(o.rmbprice)>16  or o.rmbprice='{length}';
			 
			insert into zmemory_question(tableName,row,col,error)
			select 'zmemory_optproduct',o.row,'dollarcost',
			case
			when o.dollarcost is null then 'dollarcost不能为空且必须为数字'
			when o.dollarcost='{length}' then 'dollarcost长度不能超过200'
			when o.dollarcost REGEXP '^[0-9]*(\\.?)[0-9]*$'=0 then 'dollarcost必须为数字'
			when length(o.dollarcost)>16  then 'dollarcost长度不能超过16'
			end 'error'
			from zmemory_optproduct o left join (select Distinct ID,currencyID from zmemory_opt) opt
			on o.optID=opt.ID
			where opt.currencyID=2  and o.dollarcost is null
			 or o.dollarcost REGEXP '^[0-9]*(\\.?)[0-9]*$'=0 or length(o.dollarcost)>16  or o.dollarcost='{length}';
			 
			 
			insert into zmemory_question(tableName,row,col,error)
			select 'zmemory_optproduct',o.row,'dollarprice',
			case
			when o.dollarprice is null then 'dollarprice不能为空且必须为数字'
			when o.dollarprice='{length}' then 'dollarprice长度不能超过200'
			when o.dollarprice REGEXP '^[0-9]*(\\.?)[0-9]*$'=0 then 'dollarprice必须为数字'
			when length(o.dollarprice)>16  then 'dollarprice长度不能超过16'
			end 'error'
			from zmemory_optproduct o left join (select Distinct ID,currencyID from zmemory_opt) opt
			on o.optID=opt.ID
			where opt.currencyID=2  and o.dollarprice is null
			 or o.dollarprice REGEXP '^[0-9]*(\\.?)[0-9]*$'=0 or length(o.dollarprice)>16  or o.dollarprice='{length}';
	 end if; 

	 if tableName='zmemory_emptarget' 
	 then
	 	insert into zmemory_question(tableName,row,col,error)
			select 'zmemory_emptarget',row,'at_sumperformancemanagementisnot1','at_sumperformancemanagementisnot1'
			from zmemory_emptarget  
			where weightgrossmarginratio+weightreturnedmoney+weightorder+weightshipments+weightexpensedisburse != 1;

		insert into zmemory_question(tableName,row,col,error)
			select 'zmemory_emptarget',row,'at_sumofdailymanagementisnot1','at_sumofdailymanagementisnot1' 
			from zmemory_emptarget  
			where weightcustomervisit+weightorderreceiverate+weightnewcustomernum+weightpredictedmoney+
						weightnewoptmoney+weightnewoptnum != 1;
	 end if;

	 SET done = FALSE;
	    OPEN  decimals;     
	    read_loop: LOOP
	            
	            FETCH   decimals INTO fieldName,firstnum,lastnum;
	            IF done THEN
	                LEAVE read_loop;
	             END IF;
	 
	        
	       set @sqlStr=CONCAT("
	      			 insert into zmemory_question(tableName,row,col,error)
	                select '",tableName,"',row, '",fieldName,"',
	                case 
	                when ",fieldName,"<",firstnum," or ",fieldName,">",lastnum," then '",fieldName,"必须在",firstnum,",",lastnum,"之间'
	                end 'error'
	                from ",tableName," where  ",fieldName,"<",firstnum," or ",fieldName,">",lastnum,"
	                ");
	            PREPARE stmt from @sqlStr;
	            EXECUTE stmt;
	      
	    END LOOP;
	    CLOSE decimals;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `proc_import_cleanSystem` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_import_cleanSystem`()
BEGIN

truncate table abilitystat;
truncate table agency;
truncate table agencytype;
truncate table chartdefaultload;
truncate table city;
truncate table country;
truncate table currencyconvert;
truncate table customyear;

truncate table customeofftmp;
truncate table customer;
truncate table customercontact;
truncate table customercontacttemp;
truncate table customertemp;
truncate table debug;
truncate table departprofit;
truncate table empdepart;
truncate table empemployeedepart;
truncate table empemployeepermission;
truncate table empemployeerole;
truncate table empemployeeviewuser;
truncate table employee;

truncate table empposition;
truncate table emprole;

truncate table emptarget;
truncate table expensetype;
truncate table faranchise;
truncate table financialdata;
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
truncate table source;
truncate table sqllog;

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

INSERT INTO `chartdefaultload` (`id`, `charttype`, `charttypeen`, `chartvalue`) VALUES
	(1, '全部', 'All', 0),
	(2, '全部', 'All', 0),
	(3, '全部', 'All', 0);


	
INSERT INTO `employee` (`id`, `empno`, `depid`, `positionid`, `fullname`, `username`, `pwd`, `email`, `gender`, `birthdaytype`, `birthday`, `fax`, `tel`, `mobile`, `officeaddr`, `status`, `superiorid`, `emailcode`, `entrydate`, `extensionnum`, `importreferid`) VALUES
	(1, 'S00001', 1, 1, '管理员', 'admin', '8f1af05474e9f9a0e9b0c85a3e553ce0', 'admin@admin.com', 0, 1, '2016-11-11', '66666666', '88888888', '1888888888', '江西南昌', 0, NULL, NULL, '2016-11-11 12:00:00', '1633',1);





	










	

















		





































	



























































	

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `proc_import_copy` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_import_copy`()
begin









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

insert into empdepart(depart,departen,importreferid,sdepartid,level,bigoptprice,bigoptpriceminor,isdelete) 
	select departcn,departen,id,sdepartid,level,bigoptprice,bigoptpriceminor,isdelete from zmemory_empdepart
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

update employee set uuid = FLOOR((RAND() * 10000));

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

insert into emptarget(importreferid,employeeid,years,months,targetmoney,targetmoneyminor,grossmarginratio,returnedmoneyperiod,expensedisburse,
	expensedisburseminor,customervisit,orderreceiverate,newcustomernum,newoptmoney,newoptmoneyminor,newoptnum,weightcustomervisit,
	weightorderreceiverate,weightnewcustomernum,weightpredictedmoney,weightnewoptmoney,weightnewoptnum,weightgrossmarginratio,weightreturnedmoney,weightorder,
	weightshipments,weightexpensedisburse)
	select ID,employeeid,years,months,targetmoney,targetmoneyminor,grossmarginratio,returnedmoneyperiod,expensedisburse,
	expensedisburseminor,customervisit,orderreceiverate,newcustomernum,newoptmoney,newoptmoneyminor,newoptnum,weightcustomervisit,
	weightorderreceiverate,weightnewcustomernum,weightpredictedmoney,weightnewoptmoney,weightnewoptnum,weightgrossmarginratio,weightreturnedmoney,weightorder,
	weightshipments,weightexpensedisburse  from zmemory_emptarget
	on duplicate key update employeeid=values(employeeid),years=values(years),months=values(months),targetmoney=values(targetmoney)
	,targetmoneyminor=values(targetmoneyminor),grossmarginratio=values(grossmarginratio),returnedmoneyperiod=values(returnedmoneyperiod),expensedisburse=values(expensedisburse)
	,expensedisburseminor=values(expensedisburseminor),customervisit=values(customervisit),orderreceiverate=values(orderreceiverate),newcustomernum=values(newcustomernum)
	,newoptmoney=values(newoptmoney),newoptmoneyminor=values(newoptmoneyminor),newoptnum=values(newoptnum),weightcustomervisit=values(weightcustomervisit)
	,weightorderreceiverate=values(weightorderreceiverate),weightnewcustomernum=values(weightnewcustomernum),weightpredictedmoney=values(weightpredictedmoney)
	,weightnewoptmoney=values(weightnewoptmoney),weightnewoptnum=values(weightnewoptnum),weightgrossmarginratio=values(weightgrossmarginratio)
	,weightreturnedmoney=values(weightreturnedmoney),weightorder=values(weightorder),weightshipments=values(weightshipments)
	,weightexpensedisburse=values(weightexpensedisburse);

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
left join empdepart old2 on new.departid=old2.importreferid 
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

insert into expensetype(expensetype,expensetypeen,importreferid,isdelete) 
	select expensetype,expensetypeen,id,isdelete from zmemory_expensetype
	on duplicate key update expensetype=values(expensetype),expensetypeen=values(expensetypeen),isdelete=values(isdelete);

insert into traffictype(traffictype,traffictypeen,importreferid,isdelete) 
	select traffictype,traffictypeen,id,isdelete from zmemory_traffictype
	on duplicate key update traffictype=values(traffictype),traffictypeen=values(traffictypeen),isdelete=values(isdelete);

insert into agencytype(agencytype,agencytypeen,importreferid,isdelete) 
	select agencytype,agencytypeen,id,isdelete from zmemory_agencytype
	on duplicate key update agencytype=values(agencytype),agencytypeen=values(agencytypeen),isdelete=values(isdelete);

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


REPLACE into systemconfig(id,importreferid,emailusername,emailpassword,emailsendaddr,emailsmtpaddr,emailsmtpport,emailisverification,snapshootperiod,customerauditorid,startingmonth,startingday,issynchronized,companyname,leadreleaseperiod) 
	select 1,id,emailusername,emailpassword,emailsendaddr,emailsmtpaddr,emailsmtpport,emailisverification,snapshootperiod,customerauditorid,startingmonth,startingday,issynchronized,companyname,leadreleaseperiod
	from zmemory_systemconfig;

end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `proc_import_createMemoryTable` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_import_createMemoryTable`()
begin
DROP TABLE IF exists `zmemory_currencyexchange`;
CREATE TABLE IF NOT exists `zmemory_currencyexchange` (
  `row` int(1) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL COMMENT '00' ,
  `currencyname` varchar(200) DEFAULT NULL COMMENT '0',
  `currencysymbol` varchar(200) DEFAULT NULL COMMENT '0',
  `statisticunit` varchar(200) DEFAULT NULL COMMENT '4',
  `unitcomment` varchar(200) DEFAULT NULL COMMENT '0',
  `currencynameen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` SMALLINT(1) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 ;

DROP TABLE IF exists `zmemory_currencyconvert`;
CREATE TABLE IF NOT exists `zmemory_currencyconvert` (
  `row` int(1) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL COMMENT '00',
  `startdate` varchar(200) DEFAULT NULL COMMENT '5',
  `enddate` varchar(200) DEFAULT NULL COMMENT '5',
  `ajtoinformula` varchar(200) DEFAULT NULL COMMENT '4',
  `intoajformula` varchar(200) DEFAULT NULL COMMENT '4'
) ENGINE=MEMORY DEFAULT CHARSET=utf8  ;


DROP TABLE IF exists `zmemory_empdepart`;
CREATE TABLE IF NOT exists `zmemory_empdepart` (
  `row` int(1) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `departcn` varchar(200) DEFAULT NULL COMMENT '0',
  `sdepartid` varchar(200) DEFAULT NULL COMMENT '6zmemory_empdepart',
  `level` varchar(200) DEFAULT NULL COMMENT '4',
  `sort` varchar(200) DEFAULT NULL COMMENT '',  
  `departen` varchar(200) DEFAULT NULL COMMENT '-1',
  `bigoptprice` varchar(200) DEFAULT NULL COMMENT '1',
  `bigoptpriceminor` varchar(200) DEFAULT NULL COMMENT '1',
  `isdelete` SMALLINT(1) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 ;

DROP TABLE IF exists `zmemory_empposition`;
CREATE TABLE IF NOT exists `zmemory_empposition` (
  `row` int(1) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `positioncn` varchar(200) DEFAULT NULL COMMENT '0',
  `positionen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` SMALLINT(1) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8;

DROP TABLE IF exists `zmemory_emprole`;
CREATE TABLE IF NOT exists `zmemory_emprole` (
  `row` int(1) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '',
  `role` varchar(200) DEFAULT NULL COMMENT '',
  `rolediscribe` varchar(200) COMMENT '',
  `roleen` varchar(200) DEFAULT NULL COMMENT '',
  `rolediscribeen` varchar(200) DEFAULT NULL COMMENT '',
  `isdelete` SMALLINT(1) DEFAULT '0' COMMENT  ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8;


DROP TABLE IF exists `zmemory_employee`; 
CREATE TABLE IF NOT exists `zmemory_employee` (
  `row` int(1) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `empno` varchar(200) DEFAULT NULL COMMENT '0',
  `depid` varchar(200) DEFAULT NULL COMMENT '6zmemory_empdepart',
  `positionid` varchar(200) DEFAULT NULL COMMENT '6zmemory_empposition',
  `fullname` varchar(200) DEFAULT NULL COMMENT '0',
  `username` varchar(200) DEFAULT NULL COMMENT '00',
  `pwd` varchar(200) DEFAULT NULL COMMENT '0',
  `email` varchar(200) DEFAULT NULL COMMENT '0',
  `gender` varchar(200) DEFAULT NULL COMMENT 'num,0,1' ,
  `birthdaytype` varchar(200) DEFAULT '1' COMMENT '', 
  `birthday` varchar(200) DEFAULT NULL COMMENT '2',
  `fax` varchar(200) DEFAULT NULL COMMENT '11',
  `tel` varchar(200) DEFAULT NULL COMMENT '0',
  `mobile` varchar(200) DEFAULT NULL COMMENT '0',
  `officeaddr` varchar(200) DEFAULT NULL COMMENT '11',
  `status` varchar(200) DEFAULT '0' COMMENT '',  
  `superiorid` varchar(200) DEFAULT NULL COMMENT '',  
  `emailcode` varchar(200) DEFAULT NULL COMMENT '',   
  `entrydate` varchar(200) DEFAULT NULL COMMENT '2',
  `extensionnum` varchar(200) DEFAULT NULL COMMENT '11'
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='员工表';

DROP TABLE IF exists `zmemory_empemployeerole`;
CREATE TABLE IF NOT exists `zmemory_empemployeerole` (
  `row` int(1) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `employeeid` varchar(200) DEFAULT NULL COMMENT '6zmemory_employee',
  `roleid` varchar(200) DEFAULT NULL COMMENT '6zmemory_emprole'
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 ;

DROP TABLE IF exists `zmemory_emptarget`;
CREATE TABLE IF NOT exists `zmemory_emptarget` (
  `row` int(1) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `employeeid` varchar(200) DEFAULT NULL COMMENT '6zmemory_employee',
  `years` varchar(200) DEFAULT NULL COMMENT 'num,1901,2155',
  `months` varchar(200) DEFAULT NULL COMMENT 'num,1,12',
  `targetmoney` varchar(40) DEFAULT NULL COMMENT '4',
  `targetmoneyminor` varchar(40) DEFAULT NULL COMMENT '4',
  `grossmarginratio` varchar(40) NULL DEFAULT NULL COMMENT 'decimals,0,1',
  `returnedmoneyperiod` varchar(40) NULL DEFAULT NULL COMMENT '1',
  `expensedisburse` varchar(40) NULL DEFAULT NULL COMMENT '1',
  `expensedisburseminor` varchar(40) NULL DEFAULT NULL COMMENT '1',
  `customervisit` varchar(40) NULL DEFAULT NULL COMMENT '1',
  `orderreceiverate` varchar(40) NULL DEFAULT NULL COMMENT 'decimals,0,1',
  `newcustomernum` varchar(40) NULL DEFAULT NULL COMMENT '1',
  `newoptmoney` varchar(40) NULL DEFAULT NULL COMMENT '1',
  `newoptmoneyminor` varchar(40) NULL DEFAULT NULL COMMENT '1',
  `newoptnum` varchar(40) NULL DEFAULT NULL COMMENT '1',
  `weightcustomervisit` varchar(40) NULL DEFAULT NULL COMMENT 'decimals,0,1',
  `weightorderreceiverate` varchar(40) NULL DEFAULT NULL COMMENT 'decimals,0,1',
  `weightnewcustomernum` varchar(40) NULL DEFAULT NULL COMMENT 'decimals,0,1',
  `weightpredictedmoney` varchar(40) NULL DEFAULT NULL COMMENT 'decimals,0,1',
  `weightnewoptmoney` varchar(40) NULL DEFAULT NULL COMMENT 'decimals,0,1',
  `weightnewoptnum` varchar(40) NULL DEFAULT NULL COMMENT 'decimals,0,1',
  `weightgrossmarginratio` varchar(40) NULL DEFAULT NULL COMMENT 'decimals,0,1',
  `weightreturnedmoney` varchar(40) NULL DEFAULT NULL COMMENT 'decimals,0,1',
  `weightorder` varchar(40) NULL DEFAULT NULL COMMENT 'decimals,0,1',
  `weightshipments` varchar(40) NULL DEFAULT NULL COMMENT 'decimals,0,1',
  `weightexpensedisburse` varchar(40) NULL DEFAULT NULL COMMENT 'decimals,0,1'
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='销售任务表';

DROP TABLE IF exists `zmemory_empemployeeviewuser`;
CREATE TABLE IF NOT exists `zmemory_empemployeeviewuser` (
  `row` int(1) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `employeeid` varchar(200) DEFAULT NULL COMMENT '6zmemory_employee',
  `viewuserid` varchar(200) DEFAULT NULL COMMENT '6zmemory_employee'
) ENGINE=MEMORY DEFAULT CHARSET=utf8 COMMENT='员工-可查看用户对应表';

DROP TABLE IF exists `zmemory_empemployeedepart`;
CREATE TABLE IF NOT exists `zmemory_empemployeedepart` (
  `row` int(1) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `employeeid` varchar(200) DEFAULT NULL COMMENT '6zmemory_employee',
  `departid` varchar(200) DEFAULT NULL COMMENT '6zmemory_empdepart'
) ENGINE=MEMORY DEFAULT CHARSET=utf8 COMMENT='员工-可查看部门对应表';

DROP TABLE IF exists `zmemory_productbrand`; 
CREATE TABLE IF NOT exists `zmemory_productbrand` (
  `row` int(1) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `brandnamecn` varchar(200) DEFAULT NULL COMMENT '0',
  `brandnameen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` SMALLINT(1) DEFAULT '0' COMMENT  ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='品牌表';  

DROP TABLE IF exists `zmemory_productclass`;
CREATE TABLE IF NOT exists `zmemory_productclass` (
  `row` int(1) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `brandid` varchar(200) DEFAULT NULL COMMENT '6zmemory_productbrand',
  `classnamecn` varchar(200) DEFAULT NULL COMMENT '0',
  `classnameen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` SMALLINT(1) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='类别表';

DROP TABLE IF exists `zmemory_product`;
CREATE TABLE IF NOT exists `zmemory_product` (
  `row` int(1) DEFAULT NULL COMMENT '',
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
  `isdelete` SMALLINT(1) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='产品表';

DROP TABLE IF exists `zmemory_country`;
CREATE TABLE IF NOT exists `zmemory_country` (
  `row` int(1) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL COMMENT '00',
  `country` varchar(200) DEFAULT NULL COMMENT '0',
  `countryen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` SMALLINT(1) DEFAULT '0' COMMENT ''

) ENGINE=MEMORY DEFAULT CHARSET=utf8 COMMENT='国家表';


DROP TABLE IF exists `zmemory_region`;
CREATE TABLE IF NOT exists `zmemory_region` (
  `row` int(1) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `countryid` varchar(200) DEFAULT NULL COMMENT '6zmemory_country',
  `region` varchar(200) DEFAULT NULL COMMENT '0',
  `regionen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` SMALLINT(1) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='地域表';

DROP TABLE IF exists `zmemory_province`;
CREATE TABLE IF NOT exists `zmemory_province` (
  `row` int(1) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `regionid` varchar(200) DEFAULT NULL COMMENT '6zmemory_region',
  `province` varchar(200) DEFAULT NULL COMMENT '0',
  `provinceen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` SMALLINT(1) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='省份表';

DROP TABLE IF exists `zmemory_city`;
CREATE TABLE IF NOT exists `zmemory_city` (
  `row` int(1) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `provinceid` varchar(200) DEFAULT NULL COMMENT '6zmemory_province',
  `city` varchar(200) DEFAULT NULL COMMENT '0',
  `cityen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` SMALLINT(1) DEFAULT '0' COMMENT ''

) ENGINE=MEMORY DEFAULT CHARSET=utf8 COMMENT='城市表';

DROP TABLE IF exists `zmemory_town`;
CREATE TABLE IF NOT exists `zmemory_town` (
  `row` int(1) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `cityid` varchar(200) DEFAULT NULL COMMENT '6zmemory_city',
  `town` varchar(200) DEFAULT NULL COMMENT '0',
  `townen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` SMALLINT(1) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY DEFAULT CHARSET=utf8 COMMENT='辖区表';


DROP TABLE IF exists `zmemory_piecearea`;
CREATE TABLE IF NOT exists `zmemory_piecearea` (
  `row` int(1) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `townid` varchar(200) DEFAULT NULL COMMENT '6zmemory_town',
  `piecearea` varchar(200) DEFAULT NULL COMMENT '0',
  `pieceareaen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` SMALLINT(1) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY DEFAULT CHARSET=utf8 COMMENT='片区表';

DROP TABLE IF exists `zmemory_industry`;
CREATE TABLE IF NOT exists `zmemory_industry` (
  `row` int(1) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `industry` varchar(200) DEFAULT NULL COMMENT '0',
  `industryen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` SMALLINT(1) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='行业表';

DROP TABLE IF exists `zmemory_industrysub`;
CREATE TABLE IF NOT exists `zmemory_industrysub` (
  `row` int(1) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `industryid` varchar(200) DEFAULT NULL COMMENT '6zmemory_industrysub',
  `industrysub` varchar(200) DEFAULT NULL COMMENT '0',
  `industrysuben` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` SMALLINT(1) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='子行业表';
  
DROP TABLE IF exists `zmemory_customer`;
CREATE TABLE IF NOT exists `zmemory_customer` (
  `row` int(1) DEFAULT NULL COMMENT '',
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
  `isdelete` SMALLINT(1) DEFAULT '0' COMMENT '',
  `isblacklist` varchar(200) DEFAULT '0' COMMENT '',
  `remark` varchar(200) COMMENT '11'
) ENGINE=MEMORY DEFAULT CHARSET=utf8 COMMENT='客户表';

DROP TABLE IF exists `zmemory_customercontact`;
CREATE TABLE IF NOT exists `zmemory_customercontact` (
  `row` int(1) DEFAULT NULL COMMENT '',
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
  `isdelete` SMALLINT(1) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='客户联系人表';

DROP TABLE IF exists `zmemory_workplanworktype`;
CREATE TABLE IF NOT exists `zmemory_workplanworktype` (
  `row` int(1) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `worktype` varchar(200) DEFAULT NULL COMMENT '0',
  `benefit` varchar(200) DEFAULT '1' COMMENT '',
  `worktypeen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` SMALLINT(1) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='工作计划工作类别表';


DROP TABLE IF exists `zmemory_expensetype`;
CREATE TABLE IF NOT exists `zmemory_expensetype` (
  `row` int(1) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `expensetype` varchar(200) DEFAULT NULL COMMENT '0',
  `expensetypeen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` SMALLINT(1) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='活动费用类别表';

DROP TABLE IF exists `zmemory_traffictype`;
CREATE TABLE IF NOT exists `zmemory_traffictype` (
  `row` int(1) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `traffictype` varchar(200) DEFAULT NULL COMMENT '0',
  `traffictypeen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` SMALLINT(1) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='交通方式表';

DROP TABLE IF exists `zmemory_agencytype`;
CREATE TABLE IF NOT exists `zmemory_agencytype` (
  `row` int(1) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `agencytype` varchar(200) DEFAULT NULL COMMENT '0',
  `agencytypeen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` SMALLINT(1) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='合作方类型表';


DROP TABLE IF exists `zmemory_source`;
CREATE TABLE IF NOT exists `zmemory_source` (
  `row` int(1) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `source` varchar(200) DEFAULT NULL COMMENT '0',
  `sourceen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` SMALLINT(1) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='来源表';

DROP TABLE IF exists `zmemory_opttype`;
CREATE TABLE IF NOT exists `zmemory_opttype` (
  `row` int(1) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `opttype` varchar(200) DEFAULT NULL COMMENT '0',
  `opttypeen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` SMALLINT(1) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='机会类型';

DROP TABLE IF exists `zmemory_optstage`;
CREATE TABLE IF NOT exists `zmemory_optstage` (
  `row` int(1) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '',
  `stage` varchar(200) DEFAULT NULL COMMENT '',
  `colorvalue` varchar(10) DEFAULT NULL COMMENT '',
  `description` varchar(200) DEFAULT NULL COMMENT '0',
  `descriptionen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` SMALLINT(1) DEFAULT '0' COMMENT '',
  UNIQUE INDEX `Index` (`ID`)
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='机会进展阶段表';

DROP TABLE IF exists `zmemory_optpossibility`;
CREATE TABLE IF NOT exists `zmemory_optpossibility` (
  `row` int(1) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '',
  `possibility` varchar(200) DEFAULT NULL COMMENT '',
  `description` varchar(200) DEFAULT NULL COMMENT '',
  `descriptionen` varchar(200) DEFAULT NULL COMMENT '',
  `isdelete` SMALLINT(1) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='竞争机会表';

DROP TABLE IF exists `zmemory_optcontactrole`;
CREATE TABLE IF NOT exists `zmemory_optcontactrole` (
  `row` int(1) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL  COMMENT '00',
  `rolecn` varchar(200) DEFAULT NULL COMMENT '0',
  `roleen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` SMALLINT(1) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY DEFAULT CHARSET=utf8 COMMENT='联系人角色表';

DROP TABLE IF exists `zmemory_procurementmethod`;
CREATE TABLE IF NOT exists `zmemory_procurementmethod` (
  `row` int(1) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL COMMENT '00',
  `procurementmethodname` varchar(200) DEFAULT NULL COMMENT '0',
  `procurementmethodnameen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` SMALLINT(1) DEFAULT '0' COMMENT ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='采购方式';

DROP TABLE IF exists `zmemory_faranchise`;
CREATE TABLE IF NOT exists `zmemory_faranchise` (
  `row` int(1) DEFAULT NULL COMMENT '',
  `ID` varchar(200) DEFAULT NULL COMMENT '00',
  `faranchisename` varchar(200) DEFAULT NULL COMMENT '0',
  `faranchisevalue` varchar(200) DEFAULT NULL COMMENT '4',
  `faranchiseminor` varchar(200) DEFAULT NULL COMMENT '4',
  `faranchisenameen` varchar(200) DEFAULT NULL COMMENT '-1',
  `isdelete` SMALLINT(1) DEFAULT '0' COMMENT  ''
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='代理商表';

DROP TABLE IF exists `zmemory_opt`;
CREATE TABLE IF NOT exists `zmemory_opt` (
  `row` int(1) DEFAULT NULL COMMENT '',
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
  `isdelete` SMALLINT(1) DEFAULT '0' COMMENT '',
  `remark` varchar(200) DEFAULT NULL COMMENT '11',
  `ownerid` varchar(200) DEFAULT NULL COMMENT '6zmemory_employee',
  `procurementmethodid` varchar(200) DEFAULT NULL COMMENT '6zmemory_procurementmethod',
  `faranchiseid` varchar(200) DEFAULT NULL COMMENT '6zmemory_faranchise',
  `currencyid` varchar(200) DEFAULT NULL COMMENT '6zmemory_currencyexchange'
) ENGINE=MEMORY  DEFAULT CHARSET=utf8 COMMENT='销售机会表';

DROP TABLE IF exists `zmemory_optproduct`;
CREATE TABLE IF NOT exists `zmemory_optproduct` (
  `row` int(1) DEFAULT NULL COMMENT '',
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
  `row` int(1) DEFAULT NULL COMMENT '',
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
  `row` int(1) DEFAULT NULL COMMENT '',
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
  `snapshootperiod` varchar(200) DEFAULT NULL COMMENT '',
  `systemaddr` varchar(200) DEFAULT NULL COMMENT '',
  `companyname` varchar(200) DEFAULT NULL COMMENT '0',
  `profitrelationship` varchar(200) DEFAULT NULL COMMENT '',
  `leadreleaseperiod` varchar(200) DEFAULT NULL COMMENT '4',
  `startingmonth` varchar(200) DEFAULT NULL COMMENT 'num,1,12',
  `startingday` varchar(200) DEFAULT NULL COMMENT 'num,1,31',
  `issynchronized` SMALLINT(1) DEFAULT '1' COMMENT  ''
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

  
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `proc_import_dropMemoryTable` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
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
drop table zmemory_expensetype;
drop table zmemory_traffictype;
drop table zmemory_agencytype;
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

end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `proc_import_financialData_check` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_import_financialData_check`(
	IN `tableName` VARCHAR(50)
)
begin
   declare  fieldName varchar(64);  
   declare  totable varchar(64);  
   declare  tomtable varchar(64);
   declare  value varchar(64); 
   declare  firstnum varchar(64); 
   declare  lastnum varchar(64);
   declare  questioncount int;
    
    declare done INT DEFAULT FALSE;
    
    
   

    declare cur0 CURSOR FOR SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.Columns WHERE table_name=tableName and column_comment='0';
    declare cur4 CURSOR FOR SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.Columns WHERE table_name=tableName and column_comment='4';
    declare cur5 CURSOR FOR SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.Columns WHERE table_name=tableName and column_comment='5';
      declare decimals CURSOR FOR SELECT COLUMN_NAME,substring_index(substring_index(column_comment,',',-2),',',1),substring_index(column_comment,',',-1)
    FROM INFORMATION_SCHEMA.Columns WHERE table_name=tableName and left(column_comment,8)='decimals';


    
    declare CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    insert into zmemory_financialdataquestion(row,col,error)
	select f.`row`,'empoyeeid','员工姓名输入有误,请重新填写'
	from
	zmemory_financialdata f
	left join employee e
	on f.employeeid=e.fullname
	where e.id is null;


    SET done = FALSE;
	     OPEN  cur0;     
		    
		    read_loop: LOOP
		            
		            FETCH   cur0 INTO fieldName;
		            IF done THEN
		                LEAVE read_loop;
		             END IF;
	       set @sqlStr=CONCAT("
	      			 insert into zmemory_financialdataquestion(tableName,row,col,error)
		                select '",tableName,"',row, 'at_",fieldName,"',
		                case 
		                when ",fieldName,"='{length}' then 'at_",fieldName,"长度不能超过200'
		                end 'error'
		                from ",tableName," where ",fieldName,"='{length}' 
	                ");
	                
	            PREPARE stmt from @sqlStr;
	            EXECUTE stmt;
		      
    END LOOP;
    CLOSE cur0;

	SET done = FALSE;
  	OPEN  cur4;     
    read_loop: LOOP
            
            FETCH   cur4 INTO fieldName;
            IF done THEN
                LEAVE read_loop;
             END IF;
 
       set @sqlStr=CONCAT("
       				 insert into zmemory_financialdataquestion(tableName,row,col,error)
                select '",tableName,"',row, 'at_",fieldName,"',
                case 
                when ",fieldName,"='{length}' then 'at_",fieldName,"长度不能超过200'
                when ",fieldName," is null then 'at_",fieldName,"不能为空且必须为数字'
                when ",fieldName," REGEXP '^[0-9]*(\\.?)[0-9]*$'=0 then 'at_",fieldName,"必须为数字'
                when length(",fieldName,")>16  then 'at_",fieldName,"长度不能超过16'
                end 'error'
                from ",tableName," where ",fieldName," is null or ",fieldName," REGEXP '^[0-9]*(\\.?)[0-9]*$'=0 or
                 length(",fieldName,")>16
                or ",fieldName,"='{length}' ");
            PREPARE stmt from @sqlStr;
            EXECUTE stmt;
    END LOOP;
    CLOSE cur4;		    

   SET done = FALSE;
   OPEN  cur5;     
   read_loop: LOOP
            
            FETCH   cur5 INTO fieldName;
            IF done THEN
                LEAVE read_loop;
             END IF;
 
       set @sqlStr=CONCAT("
       			 insert into zmemory_financialdataquestion(tableName,row,col,error)
                select '",tableName,"',row, 'at_",fieldName,"',
                case 
                when ",fieldName," is null then 'at_",fieldName,"不能为空且必须为日期格式'
                when ",fieldName," REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}'=0 then 'at_",fieldName,"必须为日期格式'
                end 'error'
                from ",tableName," where ",fieldName," is null or ",fieldName," REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}'=0
                ");
            PREPARE stmt from @sqlStr;
            EXECUTE stmt;
    END LOOP;
    CLOSE cur5;

     SET done = FALSE;
      OPEN  decimals;     
      read_loop: LOOP
              
              FETCH   decimals INTO fieldName,firstnum,lastnum;
              IF done THEN
                  LEAVE read_loop;
               END IF;
   
          
         set @sqlStr=CONCAT("
               insert into zmemory_financialdataquestion(tableName,row,col,error)
                  select '",tableName,"',row, '",fieldName,"',
                  case 
                  when ",fieldName,"<",firstnum," or ",fieldName,">",lastnum," then '",fieldName,"必须在",firstnum,",",lastnum,"之间'
                  end 'error'
                  from ",tableName," where  ",fieldName,"<",firstnum," or ",fieldName,">",lastnum,"
                  ");
              PREPARE stmt from @sqlStr;
              EXECUTE stmt;
        
      END LOOP;
      CLOSE decimals;

    select count(id) into questioncount from zmemory_financialdataquestion;

  if questioncount = 0 then
    	update zmemory_financialdata f
    	left join employee e on f.employeeid=e.fullname
    	set f.employeeid=e.id;
      update zmemory_financialdata f
      set f.grossmarginratio=f.grossmarginratio*100;
	end if;
  
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `proc_import_financialData_createMemoryTable` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_import_financialData_createMemoryTable`()
begin

	DROP TABLE IF exists `zmemory_financialdata`;
	CREATE TABLE IF NOT exists `zmemory_financialdata` (
		`id` int(10) NOT NULL AUTO_INCREMENT,
		`employeeid` varchar(200) DEFAULT NULL COMMENT '',
		`ordermoney` varchar(200) DEFAULT NULL COMMENT '4',
		`ordermoneyminor` varchar(200) DEFAULT NULL COMMENT '4',
		`shipmentsmoney` varchar(200) DEFAULT NULL COMMENT '4',
		`shipmentsmoneyminor` varchar(200) DEFAULT NULL COMMENT '4',
		`expensedisburse` varchar(200) DEFAULT NULL COMMENT '4',
		`expensedisburseminor` varchar(200) DEFAULT NULL COMMENT '4',
		`grossmarginratio` varchar(200) DEFAULT NULL COMMENT 'decimals,0,100',
		`returnedmoneyperiod` varchar(200) DEFAULT NULL COMMENT '4',
		`createdatetime` varchar(200) DEFAULT NULL COMMENT '5',
		`row` varchar(200) DEFAULT NULL COMMENT '',
		 PRIMARY KEY (`id`)
	) ENGINE=MEMORY  DEFAULT CHARSET=utf8 ;

	DROP TABLE IF exists `zmemory_financialdataquestion`;
	CREATE TABLE IF NOT exists `zmemory_financialdataquestion` (
		`id` INT(11) NOT NULL AUTO_INCREMENT,
		`tableName` VARCHAR(200)  DEFAULT NULL ,
		 `row` VARCHAR(200)  DEFAULT NULL ,
		 `col` VARCHAR(200)   DEFAULT NULL ,
		 `error` VARCHAR(200)   DEFAULT NULL ,
		PRIMARY KEY (`id`)
	) ENGINE=MEMORY  DEFAULT CHARSET=utf8;
		
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `proc_import_updateCN` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
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
update zmemory_expensetype set expensetype=expensetypeen where expensetype is null;
update zmemory_traffictype set traffictype=traffictypeen where traffictype is null;
update zmemory_agencytype set agencytype=agencytypeen where agencytype is null;
update zmemory_source set source=sourceen where source is null;
update zmemory_opttype set opttype=opttypeen where opttype is null;
update zmemory_procurementmethod set procurementmethodname=procurementmethodnameen where procurementmethodname is null;
update zmemory_faranchise set faranchisename=faranchisenameen where faranchisename is null; 
update zmemory_productclass set classnamecn=classnameen where classnamecn is null; 
update zmemory_productbrand set brandnamecn=brandnameen where brandnamecn is null; 
update zmemory_optcontactrole set rolecn=roleen where rolecn is null; 
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `proc_import_updateEN` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
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
update zmemory_expensetype set expensetypeen=expensetype where worktype is null;
update zmemory_traffictype set traffictypeen=traffictype where expensetypeen is null;
update zmemory_agencytype set agencytypeen=agencytype where agencytypeen is null;
update zmemory_source set sourceen=source where sourceen is null;
update zmemory_opttype set opttypeen=opttype where opttypeen is null;
update zmemory_procurementmethod set procurementmethodnameen=procurementmethodname where procurementmethodnameen is null;
update zmemory_faranchise set faranchisenameen=faranchisename where faranchisenameen is null;
update zmemory_productclass set classnameen=classnamecn where classnameen is null; 
update zmemory_productbrand set brandnameen=brandnamecn where brandnameen is null; 
update zmemory_optcontactrole set roleen=rolecn where roleen is null; 
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `proc_stat_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_stat_proc`(IN statstart varchar(20),IN statend varchar(20))
BEGIN
  declare startingday varchar(20);  -- 起始天
  declare startdate varchar(20); -- 开始日期
  declare enddate varchar(20);   -- 结束日期

  set startingday = getStartingDay(); -- 获取起始日
  
  if (startingday < 10) then
    set startingday = concat('0',startingday);
  end if;
  while statstart <= statend DO -- 循环开始 判断是否具备循坏条件
    set startdate = concat(statstart,startingday); -- 201701
    set startdate = date_format(startdate,'%Y-%m-%d'); -- 2017-01-01
    set enddate = date_format(date_sub(date_add(startdate,interval 1 month),interval 1 day),'%Y-%m-%d');  -- 结束日期

    -- 按员工统计
    call stat_ability_orderreceivingmoney_proc(statstart);
    call stat_ability_competewin_proc(statstart);
    call stat_ability_orderreceiving_proc(statstart);
    call stat_ability_allstagewin_proc(statstart);
    call stat_ability_optanalysiswin_proc(statstart);
    call stat_ability_optreceivingperiod_proc(statstart,startdate,enddate);
    call stat_ability_optboost_proc(statstart,startdate,enddate);
    call stat_ability_optinvalid_proc(statstart,startdate,enddate);
    call stat_ability_allcompetewin_proc(statstart);
    call stat_ability_orderdistribution_proc(statstart,startdate,enddate);

    -- 按代理商统计
    call faranchise_stat_ability_orderreceivingmoney_proc(statstart);
    call faranchise_stat_ability_competewin_proc(statstart);
    call faranchise_stat_ability_orderreceiving_proc(statstart);
    call faranchise_stat_ability_allstagewin_proc(statstart);
    call faranchise_stat_ability_optanalysiswin_proc(statstart);
    call faranchise_stat_ability_optreceivingperiod_proc(statstart,startdate,enddate);
    call faranchise_stat_ability_optboost_proc(statstart,startdate,enddate);
    call faranchise_stat_ability_optinvalid_proc(statstart,startdate,enddate);
    call faranchise_stat_ability_allcompetewin_proc(statstart);
   -- call faranchise_stat_ability_orderdistribution_proc(statstart,startdate,enddate);
    set statstart = statstart + 1; -- 开始下一个月的数据
 end while; 
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `pro_timing_task_return_to_the_high_seas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `pro_timing_task_return_to_the_high_seas`()
BEGIN

















	

















	update customertemp as ct, lead as l 

















	set l.owndatetime = null, l.ownerid = null, ct.ownerid = ct.createrid

















	where l.isdelete = 0

















			and l.customerid = ct.id

















			and l.customertype = 0

















			and l.leadscope is not null

















			and l.status = 1

















			and l.owndatetime is not null

















			and l.ownerid is not null

















			and round( ( select leadreleaseperiod from systemconfig limit 0, 1 ) * 3600 - timestampdiff(second, l.owndatetime, SYSDATE()) ) / 60 < 0	

















	;

















	

















	update lead set owndatetime = null, ownerid = null

















	where isdelete = 0

















		and leadscope is not null

















		and status = 1

















		and owndatetime is not null

















		and ownerid is not null

















		and round( ( select leadreleaseperiod from systemconfig limit 0, 1 ) * 3600 - timestampdiff(second, owndatetime, SYSDATE()) ) / 60 < 0

















	;

















END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `stat_ability_accumulation_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `stat_ability_accumulation_proc`(IN insertorupdateid int(10))
BEGIN
    update abilitystat set q1 = m01+m02+m03, q2 = m04+m05+m06, q3 = m07+m08+m09, q4 = m10+m11+m12,
     yearly = m01+m02+m03+m04+m05+m06+m07+m08+m09+m10+m11+m12 where id = insertorupdateid;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `stat_ability_allcompetewin_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `stat_ability_allcompetewin_proc`(IN statdate varchar(20))
BEGIN
    declare years varchar(20) default '';
    declare months varchar(20) default '';
    declare optpossibility1 int(10); 
    declare optpossibility2 int(10); 
    declare optpossibility3 int(10); 
    declare optpossibility4 int(10); 
    declare optpossibility5 int(10); 
    declare var_ownerid int(10); 
    declare monthfield varchar(20); 
    declare execsql varchar(2000) default ''; 
    declare insertsql varchar(2000) default ''; 
    declare updatesql varchar(2000) default ''; 
    declare insertorupdateid int(10); 
    declare done TINYINT DEFAULT 0;
    declare code varchar(20) default '00000'; 
    declare name varchar(20);                 
    declare msg varchar(500);                 


    
    declare cur1 cursor for 
    SELECT COUNT(if(opt.possibilityid=5,opt.id,null)) AS optpossibility5 , COUNT(if(opt.possibilityid=4,opt.id,null)) AS optpossibility4,
        COUNT(if(opt.possibilityid=3,opt.id,null)) AS optpossibility3 , COUNT(if(opt.possibilityid=2,opt.id,null)) AS optpossibility2,
        COUNT(if(opt.possibilityid=1,opt.id,null)) AS optpossibility1 ,opt.ownerid  
    FROM optrealsnap AS opt
    WHERE opt.snapdate = statdate  AND opt.optstatus IN(2,4)  group by opt.ownerid;

    
    declare cur2 cursor for 
    SELECT COUNT(if(opt.possibilityid=5,opt.id,null)) AS optpossibility5 , COUNT(if(opt.possibilityid=4,opt.id,null)) AS optpossibility4,
        COUNT(if(opt.possibilityid=3,opt.id,null)) AS optpossibility3 , COUNT(if(opt.possibilityid=2,opt.id,null)) AS optpossibility2,
        COUNT(if(opt.possibilityid=1,opt.id,null)) AS optpossibility1 ,opt.ownerid     
    FROM optrealsnap AS opt
    WHERE opt.snapdate = statdate  AND opt.optstatus = 2  group by opt.ownerid;

    declare continue handler for not found set done = 1;
    declare continue handler for sqlexception 
    BEGIN
        GET DIAGNOSTICS CONDITION 1
        code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
    END;                                      
    set name = (select companyname from systemconfig limit 1); 
    start transaction; 

    
    set years =   left(statdate,4);
    set months =  right(statdate,2);
    set monthfield = concat('m',months);
    set execsql = '';
    set insertsql = concat('insert into abilitystat(statclass, stattype,type, ',monthfield,', years, employeeid) values($statclass, $stattype,$type, $nums, $years, $ownerid)');
    
    
    set updatesql = concat('update abilitystat set ',monthfield,' = $nums where id = $id');


    
    open cur1;
        
        read_loop: loop
            fetch cur1 into optpossibility5,optpossibility4,optpossibility3,optpossibility2,optpossibility1,var_ownerid;
            if done then
                leave read_loop;
            end if;
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=7 and stattype=1 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 7);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', optpossibility5);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', optpossibility5);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
            

            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=7 and stattype=2 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 7);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', optpossibility4);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', optpossibility4);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
            
             
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=7 and stattype=3 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 7);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', optpossibility3);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', optpossibility3);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);


            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=7 and stattype=4 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 7);
                set execsql = replace(execsql, '$stattype', 4);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', optpossibility2);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', optpossibility2);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=7 and stattype=5 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 7);
                set execsql = replace(execsql, '$stattype', 5);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', optpossibility1);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', optpossibility1);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);

            set insertorupdateid = null;
            DEALLOCATE PREPARE stmt;
        end loop;
    
    close cur1;

    
    set done = FALSE;

    
    open cur2;
        
        read_loop: loop
            fetch cur2 into optpossibility5,optpossibility4,optpossibility3,optpossibility2,optpossibility1,var_ownerid;
            if done then
                leave read_loop;
            end if;
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=7 and stattype=1 and type = 2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 7);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', optpossibility5);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', optpossibility5);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
            

            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=7 and stattype=2 and type = 2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 7);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', optpossibility4);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', optpossibility4);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
            
             
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=7 and stattype=3 and type = 2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 7);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', optpossibility3);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', optpossibility3);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);


            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=7 and stattype=4 and type = 2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 7);
                set execsql = replace(execsql, '$stattype', 4);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', optpossibility2);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', optpossibility2);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=7 and stattype=5 and type = 2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 7);
                set execsql = replace(execsql, '$stattype', 5);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', optpossibility1);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', optpossibility1);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);

            set insertorupdateid = null;
            DEALLOCATE PREPARE stmt;
        end loop;
    
    close cur2;

    if code = '00000' then  
        commit;
    else                    
        ROLLBACK;
        insert into snap_log(`companyname`,`code`,`msg`) values(name,code,msg);
    end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `stat_ability_allstagewin_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `stat_ability_allstagewin_proc`(IN statdate varchar(20))
begin

    declare years varchar(20) default '';
    declare months varchar(20) default '';
    declare f1 decimal(14,2); -- 预测 10% 数量/金额
    declare f2 decimal(14,2); -- 预测 30% 数量/金额
    declare f3 decimal(14,2); -- 预测 50% 数量/金额
    declare f4 decimal(14,2); -- 预测 70% 数量/金额
    declare f5 decimal(14,2); -- 预测 90% 数量/金额

    declare r1 decimal(14,2); -- 接单 10% 数量/金额
    declare r2 decimal(14,2); -- 接单 30% 数量/金额
    declare r3 decimal(14,2); -- 接单 50% 数量/金额
    declare r4 decimal(14,2); -- 接单 70% 数量/金额
    declare r5 decimal(14,2); -- 接单 90% 数量/金额

    declare var_ownerid int(10); -- 负责人id
    declare monthfield varchar(20); -- 月份字段名
    declare execsql varchar(2000) default ''; -- 执行sql语句字符串
    declare insertsql varchar(2000) default ''; -- 插入  sql字符串
    declare updatesql varchar(2000) default ''; -- 更新  sql字符串
    declare insertorupdateid int(10); -- 更新或插入后的id
    declare done TINYINT DEFAULT 0;
    declare code varchar(20) default '00000'; -- 错误代码
    declare name varchar(20);                 -- 公司名称
    declare msg varchar(500);                 -- 错误信息

    -- 预测数量
    declare cur1 cursor for 
    select count(if(opte.stageid=2,opt.optid,null)) as f1,
    count(if(opte.stageid=3,opt.optid,null)) as f2, count(if(opte.stageid=4,opt.optid,null)) as f3,
    count(if(opte.stageid=5,opt.optid,null)) as f4, count(if(opte.stageid=6,opt.optid,null)) as f5,opt.ownerid 
    from (select optid,stageid,snapdate,optstatus from optestimatesnap where snapdate=statdate) opte
     left join optrealsnap opt on opte.optid=opt.optid and opt.snapdate=opte.snapdate
     where  opte.optstatus=1
     group by opt.ownerid;

     -- 接单数量
     declare cur2 cursor for 
    select count(if(opte.stageid=2,opt.optid,null)) as r1,
    count(if(opte.stageid=3,opt.optid,null)) as r2, count(if(opte.stageid=4,opt.optid,null)) as r3,
    count(if(opte.stageid=5,opt.optid,null)) as r4, count(if(opte.stageid=6, opt.optid,null)) as r5,opt.ownerid 
    from (select optid,stageid,snapdate from optestimatesnap where snapdate=statdate) opte
    left join optrealsnap opt on opte.optid=opt.optid and opt.snapdate=opte.snapdate
    where  opt.optstatus=2 group by opt.ownerid;

    -- 主货币 预测
    declare cur3 cursor for 
    select sum(if(opte.stageid=2,opte.totalprice,0)) as f1,
    sum(if(opte.stageid=3,opte.totalprice,0)) as f2, sum(if(opte.stageid=4,opte.totalprice,0)) as f3,
    sum(if(opte.stageid=5,opte.totalprice,0)) as f4, sum(if(opte.stageid=6,opte.totalprice,0)) as f5,opt.ownerid 
    from (select opt.optid,opt.ownerid,opt.snapdate,opt.stageid,opt.optstatus,
            ifnull(
                if(opt.currencyid=1,
                 opt.totalprice,
                 opt.totalpriceminor*cast(ifnull(cc.intoajformula,lasc.formula) as DECIMAL(14,2))) ,0) totalprice
            from optestimatesnap opt 
              left join currencyconvert cc ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
              left join (select intoajformula formula from currencyconvert ORDER BY id desc limit 1) lasc  ON 1=1
           where opt.snapdate=statdate) opte    
    left join optrealsnap opt on opte.optid=opt.optid and opt.snapdate=opte.snapdate
    where  opte.optstatus=1
     group by opt.ownerid;

    -- 主货币 接单
   declare cur4 cursor for 
   select sum(if(opte.stageid=2,opt.totalprice,0)) as f1,
    sum(if(opte.stageid=3,opt.totalprice,0)) as f2, sum(if(opte.stageid=4,opt.totalprice,0)) as f3,
    sum(if(opte.stageid=5,opt.totalprice,0)) as f4, sum(if(opte.stageid=6,opt.totalprice,0)) as f5,opt.ownerid 
    from (select optid,stageid,snapdate from optestimatesnap where snapdate=statdate) opte
     left join (select opt.optid,opt.optstatus,opt.ownerid,opt.snapdate,
                ifnull(
                    if(opt.currencyid=1,
                     opt.totalprice,
                     opt.totalpriceminor*cast(ifnull(cc.intoajformula,lasc.formula) as DECIMAL(14,2))) ,0) totalprice
                from optrealsnap opt
                  left join currencyconvert cc ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
                  left join (select intoajformula formula from currencyconvert ORDER BY id desc limit 1) lasc
                    ON 1=1) opt on opte.optid=opt.optid and opt.snapdate=opte.snapdate
     where opt.optstatus=2 group by opt.ownerid;

     -- 辅货币 预测
    declare cur5 cursor for 
    select sum(if(opte.stageid=2,opte.totalprice,0)) as f1,
    sum(if(opte.stageid=3,opte.totalprice,0)) as f2, sum(if(opte.stageid=4,opte.totalprice,0)) as f3,
    sum(if(opte.stageid=5,opte.totalprice,0)) as f4, sum(if(opte.stageid=6,opte.totalprice,0)) as f5,opt.ownerid 
    from (select opt.optid,opt.ownerid,opt.snapdate,opt.stageid,
            ifnull(
                if(opt.currencyid=2,
                      opt.totalpriceminor,
                      opt.totalprice*cast(ifnull(cc.ajtoinformula,lasc.formula) as DECIMAL(14,2))) ,0) totalprice
            from optestimatesnap opt 
              left join currencyconvert cc ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
              left join (select intoajformula formula from currencyconvert ORDER BY id desc limit 1) lasc  ON 1=1
           where opt.snapdate=statdate) opte    
    left join optrealsnap opt on opte.optid=opt.optid and opt.snapdate=opte.snapdate
     group by opt.ownerid;

     -- 辅货币 接单
    declare cur6 cursor for 
    select sum(if(opte.stageid=2,opt.totalprice,0)) as f1,
    sum(if(opte.stageid=3,opt.totalprice,0)) as f2, sum(if(opte.stageid=4,opt.totalprice,0)) as f3,
    sum(if(opte.stageid=5,opt.totalprice,0)) as f4, sum(if(opte.stageid=6,opt.totalprice,0)) as f5,opt.ownerid 
    from (select optid,stageid,snapdate from optestimatesnap where snapdate=statdate) opte
    left join (select opt.optid,opt.snapdate,opt.optstatus,opt.ownerid,
                ifnull(
                   if(opt.currencyid=2,
                      opt.totalpriceminor,
                      opt.totalprice*cast(ifnull(cc.ajtoinformula,lasc.formula) as DECIMAL(14,2))) ,0) totalprice
                from optrealsnap opt
                  left join currencyconvert cc ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
                  left join (select ajtoinformula formula from currencyconvert ORDER BY id desc limit 1) lasc
                    ON 1=1) opt on opte.optid=opt.optid and opt.snapdate=opte.snapdate
     where opt.optstatus=2 group by opt.ownerid;

    declare continue handler for not found set done = TRUE;
    declare continue handler for sqlexception 
    BEGIN
        GET DIAGNOSTICS CONDITION 1
        code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
    END;                                      --  当错误时,赋值错误代码,错误信息
    set name = (select companyname from systemconfig limit 1); -- 获取公司名称
    start transaction; -- 开启事物


    set years =   left(statdate,4);
    set months =  right(statdate,2);
    set monthfield = concat('m',months);
    set execsql = '';
    set insertsql = concat('insert into abilitystat(statclass, stattype, type, ',monthfield,', years, employeeid) values($statclass, $stattype, $type, $nums, $years, $ownerid)');


    set updatesql = concat('update abilitystat set ',monthfield,' = $nums where id = $id');
      /* 打开游标 */
    open cur1;
        /* 遍历数据表 */
        read_loop: loop
            fetch cur1 into f1,f2,f3,f4,f5,var_ownerid;
            if done then
                leave read_loop;
            end if;
            
            /*-----数量: 10% 预测-----*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=5 and stattype=1 and type=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', f1);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', f1);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----数量: 30% 预测------*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=5 and stattype=2 and type=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', f2);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', f2);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----数量: 50% 预测------*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=5 and stattype=3 and type=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', f3);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', f3);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----数量: 70% 预测------*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=5 and stattype=4 and type=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 4);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', f4);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', f4);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----数量: 90% 预测------*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=5 and stattype=5 and type=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 5);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', f5);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', f5);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);

            set insertorupdateid = null;
        end loop;
    /* 关闭游标 */
    close cur1;

    SET done = FALSE;
     /* 打开游标 */
    open cur2;
        /* 遍历数据表 */
        read_loop: loop
            fetch cur2 into r1,r2,r3,r4,r5,var_ownerid;
            if done then
                leave read_loop;
            end if;
            
            /*-----数量: 10% 接单-----*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=5 and stattype=1 and type=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', r1);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', r1);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----数量: 30% 接单------*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=5 and stattype=2 and type=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', r2);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', r2);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----数量: 50% 接单------*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=5 and stattype=3 and type=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', r3);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', r3);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----数量: 70% 接单------*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=5 and stattype=4 and type=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 4);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', r4);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', r4);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----数量: 90% 接单------*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=5 and stattype=5 and type=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 5);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', r5);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', r5);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);

            set insertorupdateid = null;
        end loop;
    /* 关闭游标 */
    close cur2;

    SET done = FALSE;
     /* 打开游标 */
    open cur3;
        /* 遍历数据表 */
        read_loop: loop
             fetch cur3 into f1,f2,f3,f4,f5,var_ownerid;
            if done then
                leave read_loop;
            end if;
            
            /*-----金额 主货币: 10% 预测-----*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=5 and stattype=1 and type=3) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 3);
                set execsql = replace(execsql, '$nums', f1);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', f1);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----金额 主货币: 30% 预测------*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=5 and stattype=2 and type=3) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 3);
                set execsql = replace(execsql, '$nums', f2);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', f2);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----金额 主货币: 50% 预测------*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=5 and stattype=3 and type=3) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 3);
                set execsql = replace(execsql, '$nums', f3);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', f3);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----金额 主货币: 70% 预测------*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=5 and stattype=4 and type=3) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 4);
                set execsql = replace(execsql, '$type', 3);
                set execsql = replace(execsql, '$nums', f4);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', f4);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----金额 主货币: 90% 预测------*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=5 and stattype=5 and type=3) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 5);
                set execsql = replace(execsql, '$type', 3);
                set execsql = replace(execsql, '$nums', f5);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', f5);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);

            set insertorupdateid = null;
        end loop;
    /* 关闭游标 */
    close cur3;

    SET done = FALSE;
     /* 打开游标 */
    open cur4;
        /* 遍历数据表 */
        read_loop: loop
            fetch cur4 into r1,r2,r3,r4,r5,var_ownerid;
            if done then
                leave read_loop;
            end if;
            
            /*-----金额 主货币: 10% 接单-----*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=5 and stattype=1 and type=4) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 4);
                set execsql = replace(execsql, '$nums', r1);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', r1);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----金额 主货币: 30% 接单------*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=5 and stattype=2 and type=4) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 4);
                set execsql = replace(execsql, '$nums', r2);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', r2);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----金额 主货币: 50% 接单------*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=5 and stattype=3 and type=4) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 4);
                set execsql = replace(execsql, '$nums', r3);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', r3);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----金额 主货币: 70% 接单------*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=5 and stattype=4 and type=4) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 4);
                set execsql = replace(execsql, '$type', 4);
                set execsql = replace(execsql, '$nums', r4);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', r4);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----金额 主货币: 90% 接单------*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=5 and stattype=5 and type=4) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 5);
                set execsql = replace(execsql, '$type', 4);
                set execsql = replace(execsql, '$nums', r5);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', r5);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);

            set insertorupdateid = null;
           -- DEALLOCATE PREPARE stmt;
        end loop;
    /* 关闭游标 */
    close cur4;

    SET done = FALSE;
      /* 打开游标 */
    open cur5;
        /* 遍历数据表 */
        read_loop: loop
            fetch cur5 into f1,f2,f3,f4,f5,var_ownerid;
            if done then
                leave read_loop;
            end if;
            
            /*-----金额 辅货币: 10% 预测-----*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=5 and stattype=1 and type=5) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 5);
                set execsql = replace(execsql, '$nums', f1);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', r1);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----金额 辅货币: 30% 预测------*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=5 and stattype=2 and type=5) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 5);
                set execsql = replace(execsql, '$nums', f2);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', f2);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----金额 辅货币: 50% 预测------*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=5 and stattype=3 and type=5) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 5);
                set execsql = replace(execsql, '$nums', f3);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', f3);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----金额 辅货币: 70% 预测------*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=5 and stattype=4 and type=5) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 4);
                set execsql = replace(execsql, '$type', 5);
                set execsql = replace(execsql, '$nums', f4);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', f4);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----金额 辅货币: 90% 预测------*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=5 and stattype=5 and type=5) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 5);
                set execsql = replace(execsql, '$type', 5);
                set execsql = replace(execsql, '$nums', f5);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', f5);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);

            set insertorupdateid = null;
 
        end loop;
    /* 关闭游标 */
    close cur5;

    SET done = FALSE;
      /* 打开游标 */
    open cur6;
        /* 遍历数据表 */
        read_loop: loop
            fetch cur6 into r1,r2,r3,r4,r5,var_ownerid;
            if done then
                leave read_loop;
            end if;
            
            /*-----金额 主货币: 10% 接单-----*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=5 and stattype=1 and type=6) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 6);
                set execsql = replace(execsql, '$nums', r1);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', r1);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----金额 主货币: 30% 接单------*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=5 and stattype=2 and type=6) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 6);
                set execsql = replace(execsql, '$nums', r2);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', r2);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----金额 主货币: 50% 接单------*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=5 and stattype=3 and type=6) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 6);
                set execsql = replace(execsql, '$nums', r3);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', r3);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----金额 主货币: 70% 接单------*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=5 and stattype=4 and type=6) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 4);
                set execsql = replace(execsql, '$type', 6);
                set execsql = replace(execsql, '$nums', r4);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', r4);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----金额 主货币: 90% 接单------*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=5 and stattype=5 and type=6) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 5);
                set execsql = replace(execsql, '$stattype', 5);
                set execsql = replace(execsql, '$type', 6);
                set execsql = replace(execsql, '$nums', r5);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', r5);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);

            set insertorupdateid = null;

        end loop;
    /* 关闭游标 */
    close cur6;

    if code = '00000' then  -- 如果没有错误,提交
        commit;
    else                    -- 有错误则回滚,插入错误信息
        ROLLBACK;
        insert into snap_log(`companyname`,`code`,`msg`,`log_time`) values(name,code,msg,now());
    end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `stat_ability_averaging_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `stat_ability_averaging_proc`(IN insertorupdateid int(10))
BEGIN
    update abilitystat set q1 = cast((m01+m02+m03)/3  as DECIMAL(14,2)), q2 = cast((m04+m05+m06)/3 as DECIMAL(14,2)),
    	   q3 = cast((m07+m08+m09)/3 as DECIMAL(14,2)), q4 = cast((m10+m11+m12)/3 as DECIMAL(14,2)),
    	   yearly = cast((m01+m02+m03+m04+m05+m06+m07+m08+m09+m10+m11+m12)/12 as DECIMAL(14,2)) where id = insertorupdateid;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `stat_ability_competewin_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `stat_ability_competewin_proc`(IN statdate varchar(20))
BEGIN
    declare years varchar(20) default '';
    declare months varchar(20) default '';
    declare num int(10); 
    declare wnum int(10); 
    declare totalprice decimal(14,2); 
    declare totalpriceminor decimal(14,2); 
    declare wtotalprice decimal(14,2); 
    declare wtotalpriceminor decimal(14,2); 
    declare var_ownerid int(10); 
    declare monthfield varchar(20); 
    declare execsql varchar(2000) default ''; 
    declare insertsql varchar(2000) default ''; 
    declare updatesql varchar(2000) default ''; 
    declare insertorupdateid int(10); 
    declare done TINYINT DEFAULT 0;
    declare code varchar(20) default '00000'; 
    declare name varchar(20);                 
    declare msg varchar(500);                 
    
    
    declare cur1 cursor for 
    select count(opt.id) as num,count(if(opt.optstatus=2,opt.id,null)) as wnum,opt.ownerid 
    from optrealsnap opt 
    where opt.possibilityid<5 and opt.optstatus in (2,4) and opt.snapdate=statdate group by opt.ownerid;

     
    declare cur2 cursor for 
    select   sum(ifnull(
                   if(opt.currencyid=1,
                      opt.totalprice,
                      opt.totalpriceminor*cast(ifnull(cc.intoajformula,lasc.formula) as DECIMAL(14,2))),0)) totalprice,
             sum(ifnull(
                   if(opt.currencyid=2,
                      opt.totalpriceminor,
                      opt.totalprice*cast(ifnull(cc.ajtoinformula,lasc.formula) as DECIMAL(14,2))) ,0)) totalpriceminor,
              sum(ifnull(
                   if(opt.optstatus=2,
                        if(opt.currencyid=1,
                          opt.totalprice,
                          opt.totalpriceminor*cast(ifnull(cc.intoajformula,lasc.formula) as DECIMAL(14,2))),0),0)) wtotalprice,
             sum(ifnull(
                   if(opt.optstatus=2,
                        if(opt.currencyid=2,
                           opt.totalpriceminor,
                           opt.totalprice*cast(ifnull(cc.ajtoinformula,lasc.formula) as DECIMAL(14,2))),0),0)) wtotalpriceminor,
               opt.ownerid
                from optrealsnap opt
                  left join currencyconvert cc ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
                  left join (select intoajformula formula from currencyconvert ORDER BY id desc limit 1) lasc ON 1=1
     where opt.possibilityid<5 and opt.optstatus in (2,4) and opt.snapdate=statdate group by opt.ownerid;

    declare continue handler for not found set done = TRUE;
    declare continue handler for sqlexception 
    BEGIN
        GET DIAGNOSTICS CONDITION 1
        code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
    END;                                      
    set name = (select companyname from systemconfig limit 1); 
    start transaction; 

    set years =   left(statdate,4);
    set months =  right(statdate,2);
    set monthfield = concat('m',months);
    set execsql = '';
    set insertsql = concat('insert into abilitystat(statclass, stattype, type, ',monthfield,', years, employeeid) values($statclass, $stattype, $type, $nums, $years, $ownerid)');
    
    set updatesql = concat('update abilitystat set ',monthfield,' = $nums where id = $id');

      
    open cur1;
        
        read_loop: loop
            fetch cur1 into num,wnum,var_ownerid;
            if done then
                leave read_loop;
            end if;
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=6 and stattype=1 and type=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 6);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', num);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', num);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=6 and stattype=2 and type=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 6);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', wnum);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', wnum);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
          
            set insertorupdateid = null;
            DEALLOCATE PREPARE stmt;
        end loop;
    
    close cur1;

    SET done = FALSE;
     
    open cur2;
        
        read_loop: loop
            fetch cur2 into totalprice,totalpriceminor,wtotalprice,wtotalpriceminor,var_ownerid;
            if done then
                leave read_loop;
            end if;
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=6 and stattype=1 and type=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 6);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', totalprice);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', totalprice);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=6 and stattype=2 and type=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 6);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', wtotalprice);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', wtotalprice);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);

            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=6 and stattype=1 and type=3) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 6);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 3);
                set execsql = replace(execsql, '$nums', totalpriceminor);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', totalpriceminor);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);

            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=6 and stattype=2 and type=3) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 6);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 3);
                set execsql = replace(execsql, '$nums', wtotalpriceminor);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', wtotalpriceminor);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
          
            set insertorupdateid = null;
            DEALLOCATE PREPARE stmt;
        end loop;
    
    close cur2;

    if code = '00000' then  
        commit;
    else                    
        ROLLBACK;
        insert into snap_log(`companyname`,`code`,`msg`) values(name,code,msg);
    end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `stat_ability_optanalysiswin_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `stat_ability_optanalysiswin_proc`(IN statdate varchar(20))
BEGIN
    declare years varchar(20) default '';
    declare months varchar(20) default '';
    declare baseitemnum decimal(14,2); 
    declare bigitemnum decimal(14,2); 
    declare allitemnum decimal(14,2); 
    declare baseitemprice decimal(14,2); 
    declare bigitemprice decimal(14,2); 
    declare allitemprice decimal(14,2); 
    declare baseitempriceminor decimal(14,2); 
    declare bigitempriceminor decimal(14,2); 
    declare allitempriceminor decimal(14,2); 
    declare var_ownerid int(10); 
    declare monthfield varchar(20); 
    declare execsql varchar(2000) default ''; 
    declare insertsql varchar(2000) default ''; 
    declare updatesql varchar(2000) default ''; 
    declare insertorupdateid int(10); 
    declare done TINYINT DEFAULT 0;
    declare code varchar(20) default '00000'; 
    declare name varchar(20);                 
    declare msg varchar(500);                 
    
     
    declare cur1 cursor for 
    select count(if(isbigdeals=1,null,1)) as baseitemnum,
           count(if(isbigdeals=1,1,null)) as bigitemnum,
           count(opt.optid) as allitemnum,

           sum(if(isbigdeals=1,0,opt.totalprice)) as baseitemprice,
           sum(if(isbigdeals=1,opt.totalprice,0)) as bigitemprice,
           sum(opt.totalprice) as allitemprice,

           sum(if(isbigdeals=1,0,opt.totalpriceminor)) as baseitempriceminor,
           sum(if(isbigdeals=1,opt.totalpriceminor,0)) as bigitempriceminor,
           sum(opt.totalpriceminor) as allitempriceminor,opt.ownerid 
    from (select opt.optid,opt.ownerid,
                if(opt.currencyid=1,
                         if(opt.totalprice >= cue.statisticunit*ed.bigoptprice,
                            1,0),
                         if(opt.totalpriceminor >= cue.statisticuniteminor*ed.bigoptpriceminor,
                            1,0)
                ) isbigdeals,
                ifnull(
                    if(opt.currencyid=1,
                     opt.totalprice,
                     opt.totalpriceminor*cast(ifnull(cc.intoajformula,lasc.formula) as DECIMAL(14,2))) ,0) totalprice,
                 ifnull(
                   if(opt.currencyid=2,
                      opt.totalpriceminor,
                      opt.totalprice*cast(ifnull(cc.ajtoinformula,lasc.formula) as DECIMAL(14,2))) ,0) totalpriceminor
                from optrealsnap opt
                  left join currencyconvert cc ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
                  left join (select intoajformula formula from currencyconvert ORDER BY id desc limit 1) lasc
                    ON 1=1
                 left join employee e on e.id = opt.ownerid
                 left join empdepart ed on e.depid = ed.id
                 left join (SELECT c.statisticunit,cue.statisticunit statisticuniteminor 
                                from currencyexchange c
                                left join (SELECT statisticunit from currencyexchange LIMIT 1,2) cue on 1=1 limit 0,1) cue on 1=1
                  where opt.optstatus=2 and opt.snapdate=statdate
       ) opt
     group by opt.ownerid;

    declare continue handler for not found set done = TRUE;
    declare continue handler for sqlexception 
    BEGIN
        GET DIAGNOSTICS CONDITION 1
        code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
    END;                                      
    set name = (select companyname from systemconfig limit 1); 
    start transaction; 

    set years =   left(statdate,4);
    set months =  right(statdate,2);
    set monthfield = concat('m',months);
    set execsql = '';
    set insertsql = concat('insert into abilitystat(statclass, stattype, type, ',monthfield,', years, employeeid) values($statclass, $stattype, $type, $nums, $years, $ownerid)');
   
    set updatesql = concat('update abilitystat set ',monthfield,' = $nums where id = $id');

      
    open cur1;
        
        read_loop: loop
            fetch cur1 into baseitemnum,bigitemnum,allitemnum,baseitemprice,bigitemprice,allitemprice,baseitempriceminor,bigitempriceminor,allitempriceminor,var_ownerid;
            if done then
                leave read_loop;
            end if;
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=1 and stattype=1 and type=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 1);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', baseitemnum);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', baseitemnum);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=1 and stattype=2 and type=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 1);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', bigitemnum);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', bigitemnum);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);

              
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=1 and stattype=3 and type=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 1);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', allitemnum);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', allitemnum);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);

              
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=1 and stattype=1 and type=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 1);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', baseitemprice);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', baseitemprice);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);

              
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=1 and stattype=2 and type=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 1);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type',2);
                set execsql = replace(execsql, '$nums', bigitemprice);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', bigitemprice);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);

              
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=1 and stattype=3 and type=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 1);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', allitemprice);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', allitemprice);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);

            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=1 and stattype=1 and type=3) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 1);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 3);
                set execsql = replace(execsql, '$nums', baseitempriceminor);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', baseitempriceminor);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);

              
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=1 and stattype=2 and type=3) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 1);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type',3);
                set execsql = replace(execsql, '$nums', bigitempriceminor);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', bigitempriceminor);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);

              
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=1 and stattype=3 and type=3) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 1);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 3);
                set execsql = replace(execsql, '$nums', allitempriceminor);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', allitempriceminor);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
          
            set insertorupdateid = null;
            DEALLOCATE PREPARE stmt;
        end loop;
    
    close cur1;

    if code = '00000' then  
        commit;
    else                    
        ROLLBACK;
        insert into snap_log(`companyname`,`code`,`msg`) values(name,code,msg);
    end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `stat_ability_optboost_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `stat_ability_optboost_proc`(IN statdate varchar(20),IN startdate varchar(20),IN enddate varchar(20))
BEGIN
    declare years varchar(20) default '';
    declare months varchar(20) default '';
    declare num1 int(10); 
    declare num2 int(10); 
    declare num3 int(10); 
    declare num4 int(10); 
    declare num5 int(10); 
    declare var_ownerid int(10); 
    declare monthfield varchar(20); 
    declare execsql varchar(2000) default ''; 
    declare insertsql varchar(2000) default ''; 
    declare updatesql varchar(2000) default ''; 
    declare insertorupdateid int(10); 
    declare done TINYINT DEFAULT 0;
    declare code varchar(20) default '00000'; 
    declare name varchar(20);                 
    declare msg varchar(500);                 
    
    
    declare cur1 cursor for 
    SELECT count(if(DATE_FORMAT(osu.stageupdatetime,'%Y-%m-%d') BETWEEN startdate AND enddate AND  osu.stageid= 3,1,null)) 
        + count(if(DATE_FORMAT(osu.stageupdatetime,'%Y-%m-%d') <= enddate AND osu.islaststage= 1 AND  osu.stageid= 2,1,null)) as num1,
         
            count(if(DATE_FORMAT(osu.stageupdatetime,'%Y-%m-%d') BETWEEN startdate AND enddate AND  osu.stageid= 4,1,null)) 
        + count(if(DATE_FORMAT(osu.stageupdatetime,'%Y-%m-%d') <= enddate AND osu.islaststage= 1 AND  osu.stageid= 3,1,null)) as num2,
         
            count(if(DATE_FORMAT(osu.stageupdatetime,'%Y-%m-%d') BETWEEN startdate AND enddate AND  osu.stageid= 5,1,null)) 
        + count(if(DATE_FORMAT(osu.stageupdatetime,'%Y-%m-%d') <= enddate AND osu.islaststage= 1 AND  osu.stageid= 4,1,null)) as num3,
         
            count(if(DATE_FORMAT(osu.stageupdatetime,'%Y-%m-%d') BETWEEN startdate AND enddate AND  osu.stageid= 6,1,null)) 
        + count(if(DATE_FORMAT(osu.stageupdatetime,'%Y-%m-%d') <= enddate AND osu.islaststage= 1 AND  osu.stageid= 5,1,null)) as num4,
         
            count(if(DATE_FORMAT(osu.stageupdatetime,'%Y-%m-%d') BETWEEN startdate AND enddate AND  osu.stageid= 7,1,null)) 
        + count(if(DATE_FORMAT(osu.stageupdatetime,'%Y-%m-%d') <= enddate AND osu.islaststage= 1 AND  osu.stageid= 6,1,null)) as num5,
         osu.ownerid
    FROM optstageupdatesnap osu
    WHERE osu.isdelete = 0 AND osu.snapdate = statdate 
    group by osu.ownerid ;

    
    declare cur2 cursor for 
    SELECT count(if(osu.stageid=3,1,null)) as num1 ,count(if(osu.stageid=4,1,null)) as num2
           ,count(if(osu.stageid=5,1,null)) as num3 ,count(if(osu.stageid=6,1,null)) as num4 ,count(if(osu.stageid=7,1,null)) as num5 
           , osu.ownerid
    FROM optstageupdatesnap osu
    WHERE (DATE_FORMAT(osu.stageupdatetime,'%Y-%m-%d') BETWEEN startdate AND enddate)  AND osu.isdelete = 0  AND osu.snapdate = statdate  
    group by osu.ownerid;

    declare continue handler for not found set done = 1;
    declare continue handler for sqlexception 
    BEGIN
        GET DIAGNOSTICS CONDITION 1
        code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
    END;                                      
    set name = (select companyname from systemconfig limit 1); 
    start transaction; 
    
    set years =   left(statdate,4);
    set months =  right(statdate,2);
    set monthfield = concat('m',months);
    set execsql = '';
    set insertsql = concat('insert into abilitystat(statclass, stattype,type, ',monthfield,', years, employeeid) values($statclass, $stattype,$type, $nums, $years, $ownerid)');

    set updatesql = concat('update abilitystat set ',monthfield,' = $nums where id = $id');


    
    open cur1;
        
        read_loop: loop
            fetch cur1 into num1,num2,num3,num4,num5,var_ownerid;
            if done then
                leave read_loop;
            end if;
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=8 and stattype=1 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 8);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', num1);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', num1);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);
            

            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=8 and stattype=2 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 8);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', num2);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', num2);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);
            
             
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=8 and stattype=3 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 8);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', num3);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', num3);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);


            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=8 and stattype=4 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 8);
                set execsql = replace(execsql, '$stattype', 4);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', num4);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', num4);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);
            
            
           set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=8 and stattype=5 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 8);
                set execsql = replace(execsql, '$stattype', 5);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', num5);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', num5);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);

            set insertorupdateid = null;
            DEALLOCATE PREPARE stmt;
        end loop;
    
    close cur1;

    
    set done = FALSE;

    
    open cur2;
        
        read_loop: loop
            fetch cur2 into num1,num2,num3,num4,num5,var_ownerid;
            if done then
                leave read_loop;
            end if;
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=8 and stattype=1 and type = 2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 8);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', num1);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', num1);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);
            
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=8 and stattype=2 and type = 2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 8);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', num2);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', num2);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);
            
             
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=8 and stattype=3 and type = 2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 8);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', num3);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', num3);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);


            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=8 and stattype=4 and type = 2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 8);
                set execsql = replace(execsql, '$stattype', 4);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', num4);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', num4);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=8 and stattype=5 and type = 2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 8);
                set execsql = replace(execsql, '$stattype', 5);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', num5);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', num5);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);

            set insertorupdateid = null;
            DEALLOCATE PREPARE stmt;
        end loop;
    
    close cur2;

    if code = '00000' then  
        commit;
    else                    
        ROLLBACK;
        insert into snap_log(`companyname`,`code`,`msg`) values(name,code,msg);
    end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `stat_ability_optinvalid_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `stat_ability_optinvalid_proc`(IN statdate varchar(20),IN startdate varchar(20),IN enddate varchar(20))
BEGIN
    declare years varchar(20) default '';
    declare months varchar(20) default '';
    declare num1 int(10); 
    declare num2 int(10); 
    declare num3 int(10); 
    declare num4 int(10); 
    declare num5 int(10); 
    declare var_ownerid int(10); 
    declare monthfield varchar(20); 
    declare execsql varchar(2000) default ''; 
    declare insertsql varchar(2000) default ''; 
    declare updatesql varchar(2000) default ''; 
    declare insertorupdateid int(10); 
    declare done TINYINT DEFAULT 0;
    declare code varchar(20) default '00000'; 
    declare name varchar(20);                 
    declare msg varchar(500);                 
    
    
    declare cur1 cursor for 
    SELECT count(if(DATE_FORMAT(osu.stageupdatetime,'%Y-%m-%d') <= enddate AND osu.islaststage= 1 AND  osu.stageid= 2 AND osu.optstatus=1,1,null)) 
            +count(if((osu.laststageid=2 OR (osu.optstatus IN (3,4,5) AND osu.stageid=2)) AND DATE_FORMAT(osu.statusupdatetime,'%Y-%m-%d') BETWEEN startdate AND enddate,1,null)) as num1,
            
             count(if(DATE_FORMAT(osu.stageupdatetime,'%Y-%m-%d') <= enddate AND osu.islaststage= 1 AND  osu.stageid= 3 AND osu.optstatus=1,1,null)) 
            +count(if((osu.laststageid=3 OR (osu.optstatus IN (3,4,5) AND osu.stageid=3)) AND DATE_FORMAT(osu.statusupdatetime,'%Y-%m-%d') BETWEEN startdate AND enddate,1,null)) as num2,
            
             count(if(DATE_FORMAT(osu.stageupdatetime,'%Y-%m-%d') <= enddate AND osu.islaststage= 1 AND  osu.stageid= 4 AND osu.optstatus=1,1,null)) 
            +count(if((osu.laststageid=4 OR (osu.optstatus IN (3,4,5) AND osu.stageid=4)) AND DATE_FORMAT(osu.statusupdatetime,'%Y-%m-%d') BETWEEN startdate AND enddate,1,null)) as num3,
            
             count(if(DATE_FORMAT(osu.stageupdatetime,'%Y-%m-%d') <= enddate AND osu.islaststage= 1 AND  osu.stageid= 5 AND osu.optstatus=1,1,null)) 
            +count(if((osu.laststageid=5 OR (osu.optstatus IN (3,4,5) AND osu.stageid=5)) AND DATE_FORMAT(osu.statusupdatetime,'%Y-%m-%d') BETWEEN startdate AND enddate,1,null)) as num4,
            
             count(if(DATE_FORMAT(osu.stageupdatetime,'%Y-%m-%d') <= enddate AND osu.islaststage= 1 AND  osu.stageid= 6 AND osu.optstatus=1,1,null)) 
            +count(if((osu.laststageid=6 OR (osu.optstatus IN (3,4,5) AND osu.stageid=6)) AND DATE_FORMAT(osu.statusupdatetime,'%Y-%m-%d') BETWEEN startdate AND enddate,1,null)) as num5,  
            osu.ownerid
    FROM optstageupdatesnap osu
    WHERE osu.isdelete = 0 AND osu.snapdate = statdate
    group by osu.ownerid ;

    
    declare cur2 cursor for 
    SELECT  count(if(osu.optstatus IN (3,4,5)   AND (osu.stageid=2 OR osu.laststageid=2),1,NULL)) as num1,
                         
            count(if( osu.optstatus IN (3,4,5)  AND (osu.stageid=3 OR osu.laststageid=3),1,NULL)) as num2,
                         
            count(if(osu.optstatus IN (3,4,5)   AND (osu.stageid=4 OR osu.laststageid=4),1,NULL)) as num3,
                         
            count(if( osu.optstatus IN (3,4,5)  AND (osu.stageid=5 OR osu.laststageid=5),1,NULL)) as num4,
                         
            count(if( osu.optstatus IN (3,4,5)  AND (osu.stageid=6 OR osu.laststageid=6),1,NULL)) as num5,
            osu.ownerid
    FROM optstageupdatesnap osu
    WHERE osu.isdelete = 0  AND osu.snapdate = statdate AND DATE_FORMAT(osu.statusupdatetime,'%Y-%m-%d') BETWEEN startdate AND enddate 
    group by osu.ownerid ;

    declare continue handler for not found set done = 1;
    declare continue handler for sqlexception 
    BEGIN
        GET DIAGNOSTICS CONDITION 1
        code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
    END;                                      
    set name = (select companyname from systemconfig limit 1); 
    start transaction; 
    
    set years =   left(statdate,4);
    set months =  right(statdate,2);
    set monthfield = concat('m',months);
    set execsql = '';
    set insertsql = concat('insert into abilitystat(statclass, stattype,type, ',monthfield,', years, employeeid) values($statclass, $stattype,$type, $nums, $years, $ownerid)');
    
    set updatesql = concat('update abilitystat set ',monthfield,' = $nums where id = $id');


    
    open cur1;
        
        read_loop: loop
            fetch cur1 into num1,num2,num3,num4,num5,var_ownerid;
            if done then
                leave read_loop;
            end if;
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=10 and stattype=1 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 10);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', num1);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', num1);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);
            

            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=10 and stattype=2 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 10);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', num2);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', num2);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);
            
             
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=10 and stattype=3 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 10);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', num3);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', num3);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);


            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=10 and stattype=4 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 10);
                set execsql = replace(execsql, '$stattype', 4);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', num4);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', num4);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);
            
            
           set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=10 and stattype=5 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 10);
                set execsql = replace(execsql, '$stattype', 5);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', num5);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', num5);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);

            set insertorupdateid = null;
            DEALLOCATE PREPARE stmt;
        end loop;
    
    close cur1;

    
    set done = FALSE;

    
    open cur2;
        
        read_loop: loop
            fetch cur2 into num1,num2,num3,num4,num5,var_ownerid;
            if done then
                leave read_loop;
            end if;
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=10 and stattype=1 and type = 2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 10);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', num1);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', num1);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);
            
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=10 and stattype=2 and type = 2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 10);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', num2);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', num2);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);
            
             
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=10 and stattype=3 and type = 2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 10);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', num3);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', num3);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);


            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=10 and stattype=4 and type = 2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 10);
                set execsql = replace(execsql, '$stattype', 4);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', num4);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', num4);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=10 and stattype=5 and type = 2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 10);
                set execsql = replace(execsql, '$stattype', 5);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', num5);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', num5);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);

            set insertorupdateid = null;
            DEALLOCATE PREPARE stmt;
        end loop;
    
    close cur2;

    if code = '00000' then  
        commit;
    else                    
        ROLLBACK;
        insert into snap_log(`companyname`,`code`,`msg`) values(name,code,msg);
    end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `stat_ability_optreceivingperiod_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `stat_ability_optreceivingperiod_proc`(IN statdate varchar(20),IN startdate varchar(20),IN enddate varchar(20))
BEGIN
    declare years varchar(20) default '';
    declare months varchar(20) default '';
    declare num1 int(10); 
    declare num2 int(10); 
    declare num3 int(10); 
    declare num4 int(10); 
    declare num5 int(10); 
    declare var_ownerid int(10); 
    declare monthfield varchar(20); 
    declare execsql varchar(2000) default ''; 
    declare insertsql varchar(2000) default ''; 
    declare updatesql varchar(2000) default ''; 
    declare insertorupdateid int(10); 
    declare done TINYINT DEFAULT 0;
    declare code varchar(20) default '00000'; 
    declare name varchar(20);                 
    declare msg varchar(500);                 
    
    
    declare cur1 cursor for 
    SELECT ifnull(cast(sum(if(osu.stageid= 2,osu.remaindays,0)) 
        /count(if(osu.stageid= 2,1,null)) as DECIMAL(14,2)),0) as num1,
        ifnull(cast(sum(if(osu.stageid= 3,osu.remaindays,0)) 
        /count(if(osu.stageid= 3,1,null)) as DECIMAL(14,2)),0) as num2,
        ifnull(cast(sum(if(osu.stageid= 4,osu.remaindays,0)) 
        /count(if(osu.stageid= 4,1,null)) as DECIMAL(14,2)),0) as num3,
        ifnull(cast(sum(if(osu.stageid= 5,osu.remaindays,0)) 
        /count(if(osu.stageid= 5,1,null)) as DECIMAL(14,2)),0) as num4,
        ifnull(cast(sum(if(osu.stageid= 6,osu.remaindays,0)) 
        /count(if(osu.stageid= 6,1,null)) as DECIMAL(14,2)),0) as num5,
        osu.ownerid
    FROM optstageupdatesnap osu
    WHERE  osu.isdelete = 0 and DATE_FORMAT(osu.stageupdatetime,'%Y-%m-%d') <= enddate and osu.islaststage=0 AND osu.snapdate = statdate 
    group by osu.ownerid ;

    declare continue handler for not found set done = 1;
    declare continue handler for sqlexception 
    BEGIN
        GET DIAGNOSTICS CONDITION 1
        code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
    END;                                      
    set name = (select companyname from systemconfig limit 1); 
    start transaction; 
    
    set years =   left(statdate,4);
    set months =  right(statdate,2);
    set monthfield = concat('m',months);
    set execsql = '';
    set insertsql = concat('insert into abilitystat(statclass, stattype,type, ',monthfield,', years, employeeid) values($statclass, $stattype,$type, $nums, $years, $ownerid)');
    
    set updatesql = concat('update abilitystat set ',monthfield,' = $nums where id = $id');


    
    open cur1;
        
        read_loop: loop
            fetch cur1 into num1,num2,num3,num4,num5,var_ownerid;
            if done then
                leave read_loop;
            end if;
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=9 and stattype=1 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 9);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', num1);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', num1);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);
            

            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=9 and stattype=2 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 9);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', num2);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', num2);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);
            
             
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=9 and stattype=3 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 9);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', num3);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', num3);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);


            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=9 and stattype=4 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 9);
                set execsql = replace(execsql, '$stattype', 4);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', num4);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', num4);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);
            
            
           set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=9 and stattype=5 and type = 1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 9);
                set execsql = replace(execsql, '$stattype', 5);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', num5);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', num5);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_averaging_proc(insertorupdateid);

            set insertorupdateid = null;
            DEALLOCATE PREPARE stmt;
        end loop;
    
    close cur1;

    if code = '00000' then  
        commit;
    else                    
        ROLLBACK;
        insert into snap_log(`companyname`,`code`,`msg`) values(name,code,msg);
    end if;
  
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `stat_ability_orderdistribution_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `stat_ability_orderdistribution_proc`(IN statdate varchar(20),IN startdate varchar(20),IN enddate varchar(20))
BEGIN
    declare years varchar(20) default '';
    declare months varchar(20) default '';
    declare totalprice decimal(14,2); 
    declare totalpriceminor decimal(14,2); 
    declare var_ownerid int(10); 
    declare monthfield varchar(20); 
    declare execsql varchar(2000) default ''; 
    declare insertsql varchar(2000) default ''; 
    declare updatesql varchar(2000) default ''; 
    declare insertorupdateid int(10); 
    declare done TINYINT DEFAULT 0;
    declare code varchar(20) default '00000'; 
    declare name varchar(20);                 
    declare msg varchar(500);                 
    
    
    declare cur1 cursor for 
    select opt.ownerid,
        sum(ifnull(
            if(opt.currencyid=1,
                opt.totalprice,
                opt.totalpriceminor*cast(ifnull(cc.intoajformula,lasc.formula) as DECIMAL(14,2))) ,0)) as totalprice,
        sum(ifnull(
            if(opt.currencyid=2,
                opt.totalpriceminor,
                opt.totalprice*cast(ifnull(cc.ajtoinformula,lasc.formula) as DECIMAL(14,2))) ,0)) as totalpriceminor
    from optrealsnap as opt
    left join currencyconvert cc ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
    left join (select intoajformula formula from currencyconvert ORDER BY id desc limit 1) lasc ON 1=1
    where opt.snapdate = statdate and opt.optstatus = 2 group by opt.ownerid;

     
    declare cur2 cursor for 
     select opt.ownerid,
        sum(ifnull(
            if(opt.currencyid=1,
                opt.totalprice,
                opt.totalpriceminor*cast(ifnull(cc.intoajformula,lasc.formula) as DECIMAL(14,2))) ,0)) as totalprice,
        sum(ifnull(
            if(opt.currencyid=2,
                opt.totalpriceminor,
                opt.totalprice*cast(ifnull(cc.ajtoinformula,lasc.formula) as DECIMAL(14,2))) ,0)) as totalpriceminor
    from optrealsnap as opt
    left join currencyconvert cc ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
    left join (select intoajformula formula from currencyconvert ORDER BY id desc limit 1) lasc ON 1=1
    where opt.snapdate = statdate  and opt.isestimate = 1 and opt.optstatus = 2 group by opt.ownerid;

      
    declare cur3 cursor for 
     select opt.ownerid,
        sum(ifnull(
            if(opt.currencyid=1,
                opt.totalprice,
                opt.totalpriceminor*cast(ifnull(cc.intoajformula,lasc.formula) as DECIMAL(14,2))) ,0)) as totalprice,
        sum(ifnull(
            if(opt.currencyid=2,
                opt.totalpriceminor,
                opt.totalprice*cast(ifnull(cc.ajtoinformula,lasc.formula) as DECIMAL(14,2))) ,0)) as totalpriceminor
    from optrealsnap as opt
    left join currencyconvert cc ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
    left join (select intoajformula formula from currencyconvert ORDER BY id desc limit 1) lasc ON 1=1
    where opt.snapdate = statdate  and opt.isestimate = 0 and opt.optstatus = 2 group by opt.ownerid;

    
    declare cur4 cursor for 
        select  ifnull(optr.ownerid,fd.ownerid) ownerid,ifnull(fd.totalprice,0)-ifnull(optr.totalprice,0) totalprice,
            ifnull(fd.totalpriceminor,0)-ifnull(optr.totalpriceminor,0) totalpriceminor from         
                ( select opt.ownerid,
            sum(ifnull(
                if(opt.currencyid=1,
                opt.totalprice,
                opt.totalpriceminor*cast(ifnull(cc.intoajformula,lasc.formula) as DECIMAL(14,2))) ,0)) as totalprice,
            sum(ifnull(
                if(opt.currencyid=2,
                    opt.totalpriceminor,
                    opt.totalprice*cast(ifnull(cc.ajtoinformula,lasc.formula) as DECIMAL(14,2))) ,0)) as totalpriceminor
            from optrealsnap as opt
            left join currencyconvert cc ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
            left join (select intoajformula formula from currencyconvert ORDER BY id desc limit 1) lasc ON 1=1
            where opt.snapdate = statdate and opt.optstatus = 2 group by opt.ownerid) optr    
        left join        
                (select 
                    fd.employeeid AS ownerid , 
                    fd.ordermoney totalprice,
                    fd.ordermoneyminor totalpriceminor
                    from  financialdata  as fd 
                    where  fd.createdatetime between startdate and enddate group by fd.employeeid) fd
                    on optr.ownerid = fd.ownerid
        union     
                select  ifnull(optr.ownerid,fd.ownerid) ownerid,ifnull(fd.totalprice,0)-ifnull(optr.totalprice,0) totalprice,
                    ifnull(fd.totalpriceminor,0)-ifnull(optr.totalpriceminor,0) totalpriceminor from         
                (select 
                    fd.employeeid AS ownerid , 
                    fd.ordermoney totalprice,
                    fd.ordermoneyminor totalpriceminor
                    from  financialdata  as fd 
                    where  fd.createdatetime between startdate and enddate group by fd.employeeid) fd   
                left join    
                    ( select opt.ownerid,
                sum(ifnull(
                    if(opt.currencyid=1,
                        opt.totalprice,
                        opt.totalpriceminor*cast(ifnull(cc.intoajformula,lasc.formula) as DECIMAL(14,2))) ,0)) as totalprice,
                sum(ifnull(
                    if(opt.currencyid=2,
                        opt.totalpriceminor,
                        opt.totalprice*cast(ifnull(cc.ajtoinformula,lasc.formula) as DECIMAL(14,2))) ,0)) as totalpriceminor
                from optrealsnap as opt
                left join currencyconvert cc ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
                left join (select intoajformula formula from currencyconvert ORDER BY id desc limit 1) lasc ON 1=1
                where opt.snapdate = statdate and opt.optstatus = 2 group by opt.ownerid) optr                       
                on fd.ownerid = optr.ownerid;
          
    declare cur5 cursor for 
        select fd.employeeid AS ownerid , 
               fd.ordermoney totalprice,
               fd.ordermoneyminor totalpriceminor
        from  financialdata  as fd  
        where  fd.createdatetime between startdate and enddate group by fd.employeeid;


    declare continue handler for not found set done = TRUE;
    declare continue handler for sqlexception 
    BEGIN
        GET DIAGNOSTICS CONDITION 1
        code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
    END;                                      
    set name = (select companyname from systemconfig limit 1); 
    start transaction; 

    set years =   left(statdate,4);
    set months =  right(statdate,2);
    set monthfield = concat('m',months);
    set execsql = '';
    set insertsql = concat('insert into abilitystat(statclass, stattype, type, ',monthfield,', years, employeeid) values($statclass, $stattype, $type, $nums, $years, $ownerid)');
    
    set updatesql = concat('update abilitystat set ',monthfield,' = $nums where id = $id');

      
    open cur1;
        
        read_loop: loop
            fetch cur1 into var_ownerid,totalprice,totalpriceminor;
            if done then
                leave read_loop;
            end if;
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=2 and stattype=1 and type=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 2);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', totalprice);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', totalprice);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=2 and stattype=1 and type=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 2);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', totalpriceminor);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', totalpriceminor);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
          
            set insertorupdateid = null;
            DEALLOCATE PREPARE stmt;
        end loop;
    
    close cur1;

    SET done = FALSE;
    
    open cur2;
        
        read_loop: loop
            fetch cur2 into var_ownerid,totalprice,totalpriceminor;
            if done then
                leave read_loop;
            end if;
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=2 and stattype=2 and type=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 2);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', totalprice);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', totalprice);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=2 and stattype=2 and type=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 2);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', totalpriceminor);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', totalpriceminor);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
          
            set insertorupdateid = null;
            DEALLOCATE PREPARE stmt;
        end loop;
    
    close cur2;

    SET done = FALSE;

    
    open cur3;
        
        read_loop: loop
            fetch cur3 into var_ownerid,totalprice,totalpriceminor;
            if done then
                leave read_loop;
            end if;
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=2 and stattype=3 and type=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 2);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', totalprice);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', totalprice);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=2 and stattype=3 and type=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 2);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', totalpriceminor);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', totalpriceminor);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
          
            set insertorupdateid = null;
            DEALLOCATE PREPARE stmt;
        end loop;
    
    close cur3;

    SET done = FALSE;

    
    open cur4;
        
        read_loop: loop
            fetch cur4 into var_ownerid,totalprice,totalpriceminor;
            if done then
                leave read_loop;
            end if;
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=2 and stattype=4 and type=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 2);
                set execsql = replace(execsql, '$stattype', 4);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', totalprice);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', totalprice);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=2 and stattype=4 and type=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 2);
                set execsql = replace(execsql, '$stattype', 4);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', totalpriceminor);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', totalpriceminor);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
          
            set insertorupdateid = null;
            DEALLOCATE PREPARE stmt;
        end loop;
    
    close cur4;

    SET done = FALSE;

    
    open cur5;
        
        read_loop: loop
            fetch cur5 into var_ownerid,totalprice,totalpriceminor;
            if done then
                leave read_loop;
            end if;
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=2 and stattype=5 and type=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 2);
                set execsql = replace(execsql, '$stattype', 5);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', totalprice);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', totalprice);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
            
            
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=2 and stattype=5 and type=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 2);
                set execsql = replace(execsql, '$stattype', 5);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', totalpriceminor);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', totalpriceminor);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            
            call stat_ability_accumulation_proc(insertorupdateid);
          
            set insertorupdateid = null;
            DEALLOCATE PREPARE stmt;
        end loop;
    
    close cur5;
    SET done = FALSE;

    if code = '00000' then  
        commit;
    else                    
        ROLLBACK;
        insert into snap_log(`companyname`,`code`,`msg`) values(name,code,msg);
    end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `stat_ability_orderreceivingmoney_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `stat_ability_orderreceivingmoney_proc`(IN statdate varchar(20))
BEGIN
    declare years varchar(20) default '';
    declare months varchar(20) default '';
    declare totalprice decimal(14,2); -- 主货币总金额
    declare totalpriceminor decimal(14,2); -- 辅货币总金额
    declare var_ownerid int(10); -- 负责人id
    declare monthfield varchar(20); -- 月份字段名
    declare execsql varchar(2000) default ''; -- 执行sql语句字符串
    declare insertsql varchar(2000) default ''; -- 插入  sql字符串
    declare updatesql varchar(2000) default ''; -- 更新  sql字符串
    declare insertorupdateid int(10); -- 更新或插入后的id
    declare done TINYINT DEFAULT 0;
    declare code varchar(20) default '00000'; -- 错误代码
    declare name varchar(20);                 -- 公司名称
    declare msg varchar(500);                 -- 错误信息
    
    -- 预计接单金额 接单
    declare cur1 cursor for 
    select sum(opte.totalprice) as totalprice,sum(opte.totalpriceminor) as totalpriceminor,opt.ownerid 
    from (select opt.optid,opt.snapdate,opt.optstatus,
                ifnull(
                    if(opt.currencyid=1,
                     opt.totalprice,
                     opt.totalpriceminor*cast(ifnull(cc.intoajformula,lasc.formula) as DECIMAL(14,2))) ,0) totalprice,
               ifnull(
                   if(opt.currencyid=2,
                      opt.totalpriceminor,
                      opt.totalprice*cast(ifnull(cc.ajtoinformula,lasc.formula) as DECIMAL(14,2))) ,0) totalpriceminor
                from optestimatesnap opt
                  left join currencyconvert cc ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
                  left join (select intoajformula formula from currencyconvert ORDER BY id desc limit 1) lasc ON 1=1
                  where snapdate=statdate
           ) opte
    left join optrealsnap opt on opte.optid=opt.optid and opt.snapdate=opte.snapdate
    where opte.optstatus=1
     group by opt.ownerid;

     -- 实际接单金额 接单
    declare cur2 cursor for 
    select sum(opt.totalprice) as totalprice,sum(opt.totalpriceminor) as totalpriceminor,opt.ownerid 
    from (select optid,snapdate from optestimatesnap where snapdate=statdate) opte
     left join (select opt.optid,opt.snapdate,opt.ownerid,opt.optstatus,
                 ifnull(
                    if(opt.currencyid=1,
                     opt.totalprice,
                     opt.totalpriceminor*cast(ifnull(cc.intoajformula,lasc.formula) as DECIMAL(14,2))) ,0) totalprice,
               ifnull(
                   if(opt.currencyid=2,
                      opt.totalpriceminor,
                      opt.totalprice*cast(ifnull(cc.ajtoinformula,lasc.formula) as DECIMAL(14,2))) ,0) totalpriceminor
                from optrealsnap opt
                  left join currencyconvert cc ON ifnull(opt.realityoverdate, opt.planoverdate) between cc.startdate and cc.enddate
                  left join (select intoajformula formula from currencyconvert ORDER BY id desc limit 1) lasc
                    ON 1=1) opt on opte.optid=opt.optid and opt.snapdate=opte.snapdate
     where  opt.optstatus=2 group by opt.ownerid;

    declare continue handler for not found set done = TRUE;
    declare continue handler for sqlexception 
    BEGIN
        GET DIAGNOSTICS CONDITION 1
        code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
    END;                                      --  当错误时,赋值错误代码,错误信息
    set name = (select companyname from systemconfig limit 1); -- 获取公司名称
    start transaction; -- 开启事物

    set years =   left(statdate,4);
    set months =  right(statdate,2);
    set monthfield = concat('m',months);
    set execsql = '';
    set insertsql = concat('insert into abilitystat(statclass, stattype, type, ',monthfield,', years, employeeid) values($statclass, $stattype, $type, $nums, $years, $ownerid)');
 
    set updatesql = concat('update abilitystat set ',monthfield,' = $nums where id = $id');

      /* 打开游标 */
    open cur1;
        /* 遍历数据表 */
        read_loop: loop
            fetch cur1 into totalprice,totalpriceminor,var_ownerid;
            if done then
                leave read_loop;
            end if;
            
            /*-----主货币 预测金额-----*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=4 and stattype=1 and type=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 4);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', totalprice);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', totalprice);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----辅货币 预测金额------*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=4 and stattype=1 and type=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 4);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', totalpriceminor);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', totalpriceminor);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
          
            set insertorupdateid = null;
      
        end loop;
    /* 关闭游标 */
    close cur1;

    SET done = FALSE;
     /* 打开游标 */
    open cur2;
        /* 遍历数据表 */
        read_loop: loop
            fetch cur2 into totalprice,totalpriceminor,var_ownerid;
            if done then
                leave read_loop;
            end if;
            
            /*----主货币 接单金额-----*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=4 and stattype=2 and type=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 4);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 1);
                set execsql = replace(execsql, '$nums', totalprice);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', totalprice);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----辅货币 接单金额------*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=4 and stattype=2 and type=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 4);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$type', 2);
                set execsql = replace(execsql, '$nums', totalpriceminor);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', totalpriceminor);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
          
            set insertorupdateid = null;
        
        end loop;
    /* 关闭游标 */
    close cur2;

    if code = '00000' then  -- 如果没有错误,提交
        commit;
    else                    -- 有错误则回滚,插入错误信息
        ROLLBACK;
        insert into snap_log(`companyname`,`code`,`msg`,`log_time`) values(name,code,msg,now());
    end if;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `stat_ability_orderreceiving_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `stat_ability_orderreceiving_proc`(IN statdate varchar(20))
BEGIN
    declare years varchar(20) default '';
    declare months varchar(20) default '';
    declare successnums int(10); -- 成功的数量
    declare failingnums int(10); -- 失败的数量
    declare followingnums int(10); -- 跟踪的数量
    declare suspendingnums int(10); -- 搁置的数量
    declare invalidationnums int(10); -- 失效的数量
    declare var_ownerid int(10); -- 负责人id
    declare monthfield varchar(20); -- 月份字段名
    declare execsql varchar(2000) default ''; -- 执行sql语句字符串
    declare insertsql varchar(2000) default ''; -- 插入  sql字符串
    declare updatesql varchar(2000) default ''; -- 更新  sql字符串
    declare insertorupdateid int(10); -- 更新或插入后的id
    declare done TINYINT DEFAULT 0;
    declare code varchar(20) default '00000'; -- 错误代码
    declare name varchar(20);                 -- 公司名称
    declare msg varchar(500);                 -- 错误信息
    
    declare cur cursor for 
    select count(if(opt.optstatus=2 and opt.stageid=7,opt.id,null)) as success,
    count(if(opt.optstatus=4, opt.id,null)) as failing, count(if(opt.optstatus=1, opt.id,null)) as following,
    count(if(opt.optstatus=3, opt.id,null)) as suspending, count(if(opt.optstatus=5, opt.id,null)) as invalidation,opt.ownerid 
    from (select optid,snapdate from optestimatesnap where snapdate=statdate) opte
     left join optrealsnap opt on opte.optid=opt.optid and opt.snapdate=opte.snapdate
     where opte.optstatus=1
     group by opt.ownerid;

    declare continue handler for not found set done = 1;
    declare continue handler for sqlexception 
    BEGIN
        GET DIAGNOSTICS CONDITION 1
        code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
    END;                                      --  当错误时,赋值错误代码,错误信息
    set name = (select companyname from systemconfig limit 1); -- 获取公司名称
    start transaction; -- 开启事物

    set years =   left(statdate,4);
    set months =  right(statdate,2);
    set monthfield = concat('m',months);
    set execsql = '';
    set insertsql = concat('insert into abilitystat(statclass, stattype, ',monthfield,', years, employeeid) values($statclass, $stattype, $nums, $years, $ownerid)');
    
    set updatesql = concat('update abilitystat set ',monthfield,' = $nums where id = $id');

    /* 打开游标 */
    open cur;
        /* 遍历数据表 */
        read_loop: loop
            fetch cur into successnums,failingnums,followingnums,suspendingnums,invalidationnums,var_ownerid;
            if done then
                leave read_loop;
            end if;
            
            /*-----接单-----*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=3 and stattype=1) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 3);
                set execsql = replace(execsql, '$stattype', 1);
                set execsql = replace(execsql, '$nums', successnums);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', successnums);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            -- insert into debug(debug) values(execsql);
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----失单-----*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=3 and stattype=2) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 3);
                set execsql = replace(execsql, '$stattype', 2);
                set execsql = replace(execsql, '$nums', failingnums);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', failingnums);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----转移-----*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=3 and stattype=3) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 3);
                set execsql = replace(execsql, '$stattype', 3);
                set execsql = replace(execsql, '$nums', followingnums);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', followingnums);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----搁置-----*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=3 and stattype=4) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 3);
                set execsql = replace(execsql, '$stattype', 4);
                set execsql = replace(execsql, '$nums', suspendingnums);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', suspendingnums);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);
            
            /*-----失效-----*/
            set insertorupdateid = (select id from abilitystat where employeeid = var_ownerid and `years` = years and statclass=3 and stattype=5) ;            
            if insertorupdateid is null then
                set execsql = replace(insertsql, '$statclass', 3);
                set execsql = replace(execsql, '$stattype', 5);
                set execsql = replace(execsql, '$nums', invalidationnums);
                set execsql = replace(execsql, '$years', years);
                set execsql = replace(execsql, '$ownerid', var_ownerid);
            else
                set execsql = replace(updatesql, '$nums', invalidationnums);
                set execsql = replace(execsql, '$id', insertorupdateid);
            end if;
            set @stmt = execsql;
            PREPARE stmt FROM @stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            /* 如果是插入，则取最后一次插入的id */
            if locate('insert',execsql) then
                set insertorupdateid = (select max(id) from abilitystat);  
            end if;
            /* 将id所在的行里其它字段求和 */
            call stat_ability_accumulation_proc(insertorupdateid);

            set insertorupdateid = null;
         
        end loop;
    /* 关闭游标 */
    close cur;

    if code = '00000' then  -- 如果没有错误,提交
        commit;
    else                    -- 有错误则回滚,插入错误信息
        ROLLBACK;
        insert into snap_log(`companyname`,`code`,`msg`,`log_time`) values(name,code,msg,now());
    end if;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `transfer_to_otheremployee_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `transfer_to_otheremployee_proc`(IN operatorid varchar(20),IN sourceid varchar(4000),IN targetid varchar(20))
BEGIN
	declare operatedate datetime;
	declare t_error integer default 0;
	declare continue handler for sqlexception set t_error=1;
    set operatedate = now(); 

		
        update opt set ownerid = targetid where createrid in (sourceid);
        update optestimatesnap set ownerid = targetid where createrid in (sourceid);
        update optrealsnap set ownerid = targetid where createrid in (sourceid);
        update customertemp set ownerid = targetid where createrid in (sourceid);
        update customercontacttemp set ownerid = targetid where createrid in (sourceid);
        update customercontact set ownerid = targetid where createrid in (sourceid);
        update workplan set createrid = targetid where createrid in (sourceid); 
        insert into transferlog(operatorid,sourceid,targetid,createdatetime) values(operatorid,sourceid,targetid,operatedate);
        	
		

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2018-02-09  9:53:22
