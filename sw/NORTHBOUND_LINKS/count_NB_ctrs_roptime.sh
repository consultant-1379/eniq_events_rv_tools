
# Script is checking the latency in generating northbound ctrs links 
# and number of symbolic links generated per ROP

#!/bin/bash
HOUR=`/usr/bin/date '+%H'`
export TZ=UTC
LS=/usr/bin/ls
CAT=/usr/bin/cat
GREP=/usr/bin/grep
SORT=/usr/bin/sort
HEAD=/usr/bin/head
AWK=/usr/bin/awk
RM=/usr/bin/rm
CP=/usr/bin/cp
TEE=/usr/bin/tee
SED=/usr/bin/sed
CUT=/usr/bin/cut
XAWK=/usr/xpg4/bin/awk
DAY=`/usr/bin/date '+%d'`
MONTH=`/usr/bin/date '+%m'`
YEAR=`/usr/bin/date '+%y'`
EPOCH=`/usr/bin/nawk 'BEGIN{print srand()}'`
CONFIG="/eniq/home/dcuser/eniq_events_rv_tools/sw/config"
DIR_CTRS_NB=$($GREP DIR_CTRS_NB $CONFIG | $AWK -F= '{print $2}' | $TR -d '\r')
FILENAME=A20$YEAR$MONTH$DAY
LOGFILE=/eniq/home/dcuser/eniq_events_rv_tools/sw/logs/ctr_nb.log
TEMP_LOG=/eniq/home/dcuser/eniq_events_rv_tools/sw/logs/.nb_ctrs_"$EPOCH".log
ROP_FILE=/eniq/home/dcuser/eniq_events_rv_tools/sw/NORTHBOUND_LINKS/nb_ctr_rop.txt
LOGFILEEXISTS=false
NEWDAY=false

if [ -e $LOGFILE ] ; then 	
	LOGFILEEXISTS=true
fi

# Sleep for 5 mins if running at 23:59.
if [ "$HOUR" -eq 23 ] ; then
	/usr/bin/sleep 300
fi


echo "collecting NB CTR links..."
$LS -ltrR $DIR_CTRS_NB >> $TEMP_LOG

if [ "$LOGFILEEXISTS" == "false" ] ; then

	echo "    ROPNAME    LATENCY  COUNT"  | $TEE  $LOGFILE
	echo "----------------------------------" | $TEE -a $LOGFILE
	
	while read i ; do

		latency=`$CAT $TEMP_LOG | $GREP $FILENAME.$i | $CUT -d_ -f1 | $SORT -k 8.1nbr -k 8.4nbr | $HEAD -1 | $AWK '{ print $8 }'`
		linkCount=`$CAT  $TEMP_LOG | $GREP -c $FILENAME.$i`

		if [ -z "$latency" ] ; then

			echo "$FILENAME.$i 00:00 0000" | $TEE -a $LOGFILE

		else

			echo "$FILENAME.$i $latency $linkCount" | $TEE -a $LOGFILE
			
		fi

	done < $ROP_FILE

else

	YESTERDAY=`/usr/bin/tail -1 $LOGFILE | $CUT -d\. -f1 | $SED 's/A//g'`	

	if [ $YESTERDAY -lt "20$YEAR$MONTH$DAY" ] ; then 
		NEWDAY=true
	fi

	echo $NEWDAY
	$CP "$LOGFILE" "$LOGFILE"_copy
	
	echo "    ROPNAME    LATENCY  COUNT" 
	echo "-----------------------------------" 

	$CAT "$LOGFILE"_copy | $GREP -v $FILENAME > "$LOGFILE"

	while read i ; do 

		latency=`$CAT $TEMP_LOG | $GREP $FILENAME.$i | $CUT -d_ -f1 | $SORT -k 8.1nbr -k 8.4nbr | $HEAD -1 | $AWK '{ print $8 }'`
		linkCount=`$CAT  $TEMP_LOG | $GREP -c $FILENAME.$i`

		if [ "$NEWDAY" == "true" ] ; then

			if [ -z "$latency" ] ; then

				echo "$FILENAME.$i 00:00 0000" | $TEE -a $LOGFILE

			else

				echo "$FILENAME.$i $latency $linkCount" | $TEE -a $LOGFILE
				
			fi
    
		else

			$CAT "$LOGFILE"_copy | $GREP $FILENAME.$i | $XAWK -v count=$linkCount -v latency=$latency '{ 

					 if ( $3 < count ) {
					 	$2=latency
					 	$3=count;
					 }

				print  $1"  "$2"  "$3;
			}' | $TEE -a "$LOGFILE"	

		fi
	done < $ROP_FILE
fi

$RM $TEMP_LOG
$RM "$LOGFILE"_copy >> /dev/null 2>&1
