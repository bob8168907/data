#!/bin/bash　　
 #数据库信息
#HOSTNAME="120.76.77.192"       
#PASSWORD="L1i2a3n4g5!"                                   
PORT="3306"
USERNAME="root"
HOSTNAME="localhost"       
PASSWORD="123"  

DBNAME="vsms" 

FILENAME1="E:/vsms/documents/mysql/chart/ability/proc_chart_ability_allcompetewin.sql"
FILENAME2="E:/vsms/documents/mysql/chart/ability/proc_chart_ability_allstagewin.sql"
FILENAME3="E:/vsms/documents/mysql/chart/ability/proc_chart_ability_competewin.sql"
FILENAME4="E:/vsms/documents/mysql/chart/ability/proc_chart_ability_optanalysiswin.sql"
FILENAME5="E:/vsms/documents/mysql/chart/ability/proc_chart_ability_optboost.sql"
FILENAME6="E:/vsms/documents/mysql/chart/ability/proc_chart_ability_optinvalid.sql"
FILENAME7="E:/vsms/documents/mysql/chart/ability/proc_chart_ability_optreceivingperiod.sql"
FILENAME8="E:/vsms/documents/mysql/chart/ability/proc_chart_ability_orderdistribution.sql"
FILENAME9="E:/vsms/documents/mysql/chart/ability/proc_chart_ability_orderreceiving.sql"
FILENAME10="E:/vsms/documents/mysql/chart/ability/proc_chart_ability_orderreceivingmoney.sql"

FILENAME31="E:/vsms/documents/mysql/chart/opt/proc_chart_optanalysis_industry.sql"
FILENAME32="E:/vsms/documents/mysql/chart/opt/proc_chart_optanalysis_product.sql"
FILENAME33="E:/vsms/documents/mysql/chart/opt/proc_chart_optanalysis_region.sql"
FILENAME34="E:/vsms/documents/mysql/chart/opt/proc_chart_optsize_allstagewin.sql"
FILENAME35="E:/vsms/documents/mysql/chart/opt/proc_chart_optsize_chart.sql"
FILENAME36="E:/vsms/documents/mysql/chart/opt/proc_chart_optsize_grid.sql"
FILENAME37="E:/vsms/documents/mysql/chart/opt/proc_chart_optsize_shape.sql"
FILENAME38="E:/vsms/documents/mysql/chart/opt/proc_chart_optsize_target.sql"
FILENAME39="E:/vsms/documents/mysql/chart/opt/proc_chart_optsizemain_chart.sql"
FILENAME40="E:/vsms/documents/mysql/chart/opt/proc_chart_opttype_chart.sql"

FILENAME11="E:/vsms/documents/mysql/chart/product/proc_chart_productanalysis_industry.sql"
FILENAME12="E:/vsms/documents/mysql/chart/product/proc_chart_productanalysis_productbubble.sql"
FILENAME13="E:/vsms/documents/mysql/chart/product/proc_chart_productanalysis_productdistribution.sql"
FILENAME14="E:/vsms/documents/mysql/chart/product/proc_chart_productanalysis_region.sql"
FILENAME15="E:/vsms/documents/mysql/chart/product/proc_chart_productanalysis_toptencustomer.sql"
FILENAME16="E:/vsms/documents/mysql/chart/product/proc_chart_productanalysis_toptenopt.sql"
FILENAME17="E:/vsms/documents/mysql/chart/product/proc_chart_productanalysis_toptenproduct.sql"

FILENAME21="E:/vsms/documents/mysql/import/system_import/proc_import_batchCheck.sql"
FILENAME22="E:/vsms/documents/mysql/import/system_import/proc_import_check.sql"
FILENAME23="E:/vsms/documents/mysql/import/system_import/proc_import_cleanSystem.sql"
FILENAME24="E:/vsms/documents/mysql/import/system_import/proc_import_copy.sql"
FILENAME25="E:/vsms/documents/mysql/import/system_import/proc_import_createMemoryTable.sql"
FILENAME26="E:/vsms/documents/mysql/import/system_import/proc_import_dropMemoryTable.sql"

FILENAME27="E:/vsms/documents/mysql/import/financialdata/proc_import_financialData_check.sql"
FILENAME28="E:/vsms/documents/mysql/import/financialdata/proc_import_financialData_createMemoryTable.sql"

FILENAME29="E:/vsms/documents/mysql/import/system_import/proc_import_updateCN.sql"
FILENAME30="E:/vsms/documents/mysql/import/system_import/proc_import_updateEN.sql"




FILENAME51="E:/vsms/documents/mysql/stat/proc_stat_ability_accumulation.sql"
FILENAME41="E:/vsms/documents/mysql/stat/employee/proc_stat_ability_allcompetewin.sql"
FILENAME42="E:/vsms/documents/mysql/stat/employee/proc_stat_ability_allstagewin.sql"
FILENAME53="E:/vsms/documents/mysql/stat/proc_stat_ability_averaging.sql"
FILENAME43="E:/vsms/documents/mysql/stat/employee/proc_stat_ability_competewin.sql"
FILENAME44="E:/vsms/documents/mysql/stat/employee/proc_stat_ability_optanalysiswin.sql"
FILENAME45="E:/vsms/documents/mysql/stat/employee/proc_stat_ability_optboost.sql"
FILENAME46="E:/vsms/documents/mysql/stat/employee/proc_stat_ability_optinvalid.sql"
FILENAME47="E:/vsms/documents/mysql/stat/employee/proc_stat_ability_optreceivingperiod.sql"
FILENAME48="E:/vsms/documents/mysql/stat/employee/proc_stat_ability_orderdistribution.sql"
FILENAME49="E:/vsms/documents/mysql/stat/employee/proc_stat_ability_orderreceiving.sql"
FILENAME50="E:/vsms/documents/mysql/stat/employee/proc_stat_ability_orderreceivingmoney.sql"
FILENAME52="E:/vsms/documents/mysql/stat/proc_stat_proc.sql"


FILENAME60="E:/vsms/documents/mysql/func/func_ability_dateprocess.sql"
FILENAME61="E:/vsms/documents/mysql/func/func_find_all_departs.sql"
FILENAME62="E:/vsms/documents/mysql/func/func_find_all_departs_by_employeeid.sql"
FILENAME63="E:/vsms/documents/mysql/func/func_find_all_employee_by_superiorid.sql"
FILENAME64="E:/vsms/documents/mysql/func/func_find_all_permission_employeeid.sql"
FILENAME65="E:/vsms/documents/mysql/func/func_find_employeeid_by_employeeid_departids.sql"
FILENAME66="E:/vsms/documents/mysql/func/func_get_first_pinyin_char.sql"
FILENAME67="E:/vsms/documents/mysql/func/func_getStartingDay.sql"

FILENAME68="E:/vsms/documents/mysql/event_opt_snapshot.sql"
FILENAME69="E:/vsms/documents/mysql/proc_getAllDepartById.sql"
FILENAME70="E:/vsms/documents/mysql/proc_getAllDepartByIdList.sql"
FILENAME71="E:/vsms/documents/mysql/proc_opt_snapshot.sql"
FILENAME72="E:/vsms/documents/mysql/proc_transfer_to_otheremployee.sql"


FILENAME73="E:/vsms/documents/mysql/stat/faranchise/proc_faranchise_stat_ability_allcompetewin.sql"
FILENAME74="E:/vsms/documents/mysql/stat/faranchise/proc_faranchise_stat_ability_allstagewin.sql"
FILENAME75="E:/vsms/documents/mysql/stat/faranchise/proc_faranchise_stat_ability_competewin.sql"
FILENAME76="E:/vsms/documents/mysql/stat/faranchise/proc_faranchise_stat_ability_optanalysiswin.sql"
FILENAME77="E:/vsms/documents/mysql/stat/faranchise/proc_faranchise_stat_ability_optboost.sql"
FILENAME78="E:/vsms/documents/mysql/stat/faranchise/proc_faranchise_stat_ability_optinvalid.sql"
FILENAME79="E:/vsms/documents/mysql/stat/faranchise/proc_faranchise_stat_ability_optreceivingperiod.sql"
FILENAME80="E:/vsms/documents/mysql/stat/faranchise/proc_faranchise_stat_ability_orderdistribution.sql"
FILENAME81="E:/vsms/documents/mysql/stat/faranchise/proc_faranchise_stat_ability_orderreceiving.sql"
FILENAME82="E:/vsms/documents/mysql/stat/faranchise/proc_faranchise_stat_ability_orderreceivingmoney.sql"

FILENAME83="E:/vsms/documents/mysql/chart/manage/proc_chart_manage_salesranking.sql"
FILENAME84="E:/vsms/documents/mysql/chart/manage/chart_manage_proc.sql"

#也可以写 HOSTNAME="localhost"，端口号 PORT可以不设定
#mysqldump -uroot -p --default-character-set=utf8 mo（dbname） > E://xxxx.sql  导出


mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME1}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME2}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME3}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME4}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME5}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME6}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME7}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME8}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME9}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME10}

mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME11}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME12}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME13}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME14}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME15}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME16}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME17}

mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME21}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME22}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME23}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME24}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME25}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME26}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME27}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME28}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME29}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME30}

mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME31}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME32}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME33}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME34}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME35}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME36}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME37}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME38}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME39}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME40}

mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME41}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME42}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME43}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME44}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME45}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME46}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME47}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME48}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME49}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME50}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME51}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME52}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME53}

mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME60}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME61}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME62}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME63}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME64}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME65}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME66}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME67}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME68}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME69}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME70}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME71}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME72}

mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME73}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME74}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME75}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME76}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME77}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME78}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME79}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME80}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME81}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME82}

mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME83}
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} --default-character-set=utf8 ${DBNAME}  <  ${FILENAME84}


