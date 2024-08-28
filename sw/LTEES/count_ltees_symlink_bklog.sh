#!/bin/bash

# counts number of ctrs symlinks consumed by LTEES feature and returns the 
# mtime of the most recently created symlink

DIR=/eniq/data/pmdata/eventdata/00/CTRS/lte_es/5min/events_oss_1
LS=/usr/bin/ls
AWK=/usr/bin/awk
CUT=/usr/bin/cut
GREP=/usr/bin/grep
TAIL=/usr/bin/tail
SORT=/usr/bin/sort
CAT=/usr/bin/cat
RM=/usr/bin/rm
TEE=/usr/bin/tee
EPOCH=`/usr/bin/nawk 'BEGIN{print srand()}'`
TEMPFILE=/tmp/.ltees_backlog.$EPOCH.log
#Log Set
LOGFILE=/eniq/home/dcuser/eniq_events_rv_tools/sw/logs/ltees_symlink_backlog.log
YEAR=`/usr/bin/date +%Y`
MONTH=`/usr/bin/date +%m`
DAY=`/usr/bin/date +%d`
FILENAME=A$YEAR$MONTH$DAY

$LS -lR $DIR | $GREP $FILENAME | $AWK '{ print $8" "$9}' | $CUT -d_ -f1 > $TEMPFILE 
COUNT=`$CAT $TEMPFILE | wc -l`
LATENCY=`$CAT $TEMPFILE | $SORT -k 1.1nbr -k 1.3nbr | $TAIL -1 | $AWK '{ print $1}'`

echo `date` | $TEE -a $LOGFILE
echo "BACKLOG COUNT: $COUNT" | $TEE -a $LOGFILE
echo -e "MAX LATENCY: $LATENCY\n\n" | $TEE -a $LOGFILE

$RM $TEMPFILE
