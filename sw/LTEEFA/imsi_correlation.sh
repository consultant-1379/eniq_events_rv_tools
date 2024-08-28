#!/bin/bash

LOGFILE=/tmp/imsi_correlation.log
TEE=/usr/bin/tee

TIMESTAMP=$1
if [$# -ne 1];
	then echo "Illegal number of parameters, format YYYY-MM-DD e.g. 2014-09-23"
fi
	
#sql command go here
SQL_EVENT_E_LTE_CFA_ERR_RAW="
SELECT MONTH_ID, DAY_ID, HOUR_ID, SUM(null_imsi), SUM(not_null_imsi), SUM(null_imsi)*100/(SUM(null_imsi)+SUM(not_null_imsi)) 'NULL IMSI %' FROM
(
SELECT month_id, day_id, hour_id, count(*) null_imsi, 0 as not_null_imsi from dc.EVENT_E_LTE_CFA_ERR_RAW WHERE datetime_id >= '$TIMESTAMP 00:00' and datetime_id < '2014-09-14 23:00' and (imsi is null or imsi =0) group by month_id, day_id, hour_id
UNION ALL
SELECT month_id, day_id, hour_id, 0 as null_imsi,  count(*) not_null_imsi FROM dc.EVENT_E_LTE_CFA_ERR_RAW WHERE datetime_id >= '$TIMESTAMP 00:00' and datetime_id < '2014-09-14 23:00' AND (imsi is not null and imsi !=0) group by month_id, day_id, hour_id
)
AS yao
GROUP BY MONTH_ID, DAY_ID, HOUR_ID order by month_id, day_id, hour_id;
"
SQL_EVENT_E_LTE_CFA_ARRAY_ERAB_ERR_RAW="
SELECT MONTH_ID, DAY_ID, HOUR_ID, SUM(null_imsi), SUM(not_null_imsi), SUM(null_imsi)*100/(SUM(null_imsi)+SUM(not_null_imsi)) 'NULL IMSI %' FROM
(
SELECT month_id, day_id, hour_id, count(*) null_imsi, 0 as not_null_imsi from dc.SQL_EVENT_E_LTE_CFA_ARRAY_ERAB_ERR_RAW WHERE datetime_id >= '$TIMESTAMP 16:00' and datetime_id < '$TIMESTAMP 23:00' and (imsi is null or imsi =0) group by month_id, day_id, hour_id
UNION ALL
SELECT month_id, day_id, hour_id, 0 as null_imsi,  count(*) not_null_imsi FROM dc.SQL_EVENT_E_LTE_CFA_ARRAY_ERAB_ERR_RAW WHERE datetime_id >= '$TIMESTAMP 16:00' and datetime_id < '$TIMESTAMP 23:00' AND (imsi is not null and imsi !=0) group by month_id, day_id, hour_id
)
AS yao_
GROUP BY MONTH_ID, DAY_ID, HOUR_ID order by month_id, day_id, hour_id;
"

RESULT=`dbisql -c 'UID=dc;pwd=dc;eng=dwhdb;links=tcpip(host=localhost;port=2640;dobroadcast=direct)' -nogui $SQL_EVENT_E_LTE_CFA_ERR_RAW`
RESULT2=`dbisql -c 'UID=dc;pwd=dc;eng=dwhdb;links=tcpip(host=localhost;port=2640;dobroadcast=direct)' -nogui $SQL_EVENT_E_LTE_CFA_ARRAY_ERAB_ERR_RAW`

echo -e "TABLE EVENT_E_LTE_CFA_ERR_RAW\n$RESULT\nTABLE EVENT_E_LTE_CFA_ARRAY_ERAB_ERR_RAW\n$RESULT_2" | $TEE -a LOGFILE
