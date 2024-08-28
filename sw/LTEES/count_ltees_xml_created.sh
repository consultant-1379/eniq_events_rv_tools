#!/bin/bash
LS=/usr/bin/ls
GREP=/usr/bin/grep
AWK=/usr/bin/awk
CAT=/usr/bin/cat 
SORT=/usr/bin/sort
TEE=/usr/bin/tee
RM=/usr/bin/rm
TR=/usr/bin/tr
PRINTF=/usr/bin/printf
EPOCH=`/usr/bin/nawk 'BEGIN{print srand()}'`
TEMP_FILE=/tmp/.count_ltees_xml_created_$EPOCH.txt
CONFIG="/eniq/home/dcuser/eniq_events_rv_tools/sw/config"

Event_OSS_LTEES=$($GREP Event_OSS_LTEES $CONFIG | $AWK -F= '{print $2}' | $TR -d '\r')
DIR=/eniq/northbound/lte_event_stat_file/$Event_OSS_LTEES
ROPS=/eniq/home/dcuser/eniq_events_rv_tools/sw/LTEES/rop_ltees.txt 
FILENAME="A`TZ=IST+23 date +%Y%m%d`"
LOGFILE=/eniq/home/dcuser/eniq_events_rv_tools/logs/ltees_XML_count.log

echo -e "\n\tgathering LTEES xml.gz file list now.......\n"
$LS -lR $DIR | $GREP xml.gz | $AWK '{ print $8" "$9 }' > $TEMP_FILE
echo -e "\t collection complete \n"

while read rop ; do
	count=`$GREP -c $FILENAME.$rop $TEMP_FILE`
	maxLatency=`$CAT $TEMP_FILE | $GREP $FILENAME.$rop | $SORT -k 1.1nbr -k 1.3nbr | /usr/bin/tail -1 | $AWK '{ print $1 }'`
	echo $FILENAME.$rop $count $maxLatency | $TEE -a $LOGFILE 
done < $ROPS

$RM $TEMP_FILE
