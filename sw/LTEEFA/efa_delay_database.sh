#!/bin/bash
TEE=/usr/bin/tee
LOGFILE=/eniq/home/dcuser/eniq_events_rv_tools/sw/logs/efa_delay_database.log
QUERY=/eniq/home/dcuser/eniq_events_rv_tools/sw/LTEEFA/efa_delay.sql

echo `date -u` | $TEE -a $LOGFILE
echo -e "$(iqisql -Udc -Pdc -Sdwhdb -w200 -i $QUERY | /usr/xpg4/bin/egrep -e max -e :)\n"| $TEE -a $LOGFILE

