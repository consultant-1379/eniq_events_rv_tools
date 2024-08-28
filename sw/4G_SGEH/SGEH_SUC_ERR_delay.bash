#!/usr/bin/bash
LOG=/eniq/home/dcuser/eniq_events_rv_tools/sw/logs/SGEH_SUC_ERR_delay.log
GREP=/usr/bin/grep
TEE=/usr/bin/tee

echo "     " >> $LOG 
date -u +'%r   %d-%m-%y' >> $LOG

DELAY_QUERY="
select max(DATETIME_ID) from  dc.EVENT_E_LTE_ERR_RAW
select max(DATETIME_ID) from  dc.EVENT_E_LTE_IMSI_SUC_RAW
go
"

RESULT=`
iqisql -Udc -Pdc -Sdwhdb -w200 <<!
$DELAY_QUERY
!
`

echo `echo "$RESULT" |  $GREP -v "-" | $GREP -v "affected"` | $TEE -a $LOG
