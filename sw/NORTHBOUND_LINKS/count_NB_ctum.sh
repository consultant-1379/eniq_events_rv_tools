#!/bin/bash

# Script is to count the number, and latency of Northbound CTUM files

HOUR=`/usr/bin/date '+%H'`
export TZ=UTC
DAY=`/usr/bin/date '+%d'`
MONTH=`/usr/bin/date '+%m'`
YEAR=`/usr/bin/date '+%y'`
SYMLINKS=/eniq/home/dcuser/eniq_events_rv_tools/sw/logs/.nb_ctum_temp.log
FILENAME=A20$YEAR$MONTH$DAY
DIR_CTUM_NB=$($GREP DIR_CTUM_NB $CONFIG | $AWK -F= '{print $2}' | $TR -d '\r')
LOGFILE=/eniq/home/dcuser/eniq_events_rv_tools/sw/logs/ctum_nb.log
CTUMNBCOUNTFILEEXISTS=false
NEWDAY=false
TEE=/usr/bin/tee
CAT=/usr/bin/cat
GREP=/usr/bin/grep
CUT=/usr/bin/cut
SORT=/usr/bin/sort
HEAD=/usr/bin/head
AWK=/usr/bin/awk
LS=/usr/bin/ls
XAWK=/usr/xpg4/bin/awk
CP=/usr/bin/cp
RM=/usr/bin/rm
SED=/usr/bin/sed
ROP_FILE=/eniq/home/dcuser/eniq_events_rv_tools/sw/NORTHBOUND_LINKS/nb_ctum_rop.txt 

if [ -e $LOGFILE ] ; then 	
	CTUMNBCOUNTFILEEXISTS=true
fi

#if is just before midnight sleep for 5mins to allow for file collection
if [ "$HOUR" -eq 23 ] ; then
	/usr/bin/sleep 300
fi

echo "collecting NB CTUM links..."
$LS -ltrR $DIR_CTUM_NB >> $SYMLINKS


if [ "$CTUMNBCOUNTFILEEXISTS" == "false" ] ; then

	echo "    ROPNAME    LATENCY  COUNT"  | $TEE  $LOGFILE
	echo "----------------------------------" | $TEE -a $LOGFILE
	
	while read rop ; do
		
		latency=`$CAT $SYMLINKS | $GREP $FILENAME.$rop | $CUT -d_ -f1 | $SORT -k 8.1nbr -k 8.4nbr | $HEAD -1 | $AWK '{ print $8 }'`
		symLinkCount=`$CAT $SYMLINKS | $GREP -c $FILENAME.$rop`

		if [ -z "$latency" ] ;  then 
			echo "$FILENAME.$rop  00:00  00" | $TEE -a $LOGFILE
		else
			echo "$FILENAME.$rop  $latency  $symLinkCount" | $TEE -a $LOGFILE
		fi

	done < $ROP_FILE 

else

	YESTERDAY=`/usr/bin/tail -1 $LOGFILE | $CUT -d\. -f1 | $SED 's/A//g'`	

	if [ $YESTERDAY -lt "20$YEAR$MONTH$DAY" ] ; then 
		NEWDAY=true
	fi

	$CP 	"$LOGFILE" "$LOGFILE"_copy
	$RM "$LOGFILE"

	echo "    ROPNAME    LATENCY  COUNT" 
	echo "-----------------------------------" 

	$CAT "$LOGFILE"_copy | $GREP -v $FILENAME >> "$LOGFILE"

	while read rop ; do
		
		latency=`$CAT $SYMLINKS | $GREP $FILENAME.$rop | $CUT -d_ -f1 | $SORT -k 8.1nbr -k 8.4nbr | $HEAD -1 | $AWK '{ print $8 }'`
		symLinkCount=`$CAT $SYMLINKS | $GREP -c $FILENAME.$rop`

		if [ "$NEWDAY" == "true" ] ; then 

			if [ -z "$latency" ] ;  then 
				echo "$FILENAME.$rop  00:00  00" | $TEE -a $LOGFILE
			else
				echo "$FILENAME.$rop  $latency  $symLinkCount" | $TEE -a $LOGFILE
			fi

		else

			$CAT "$LOGFILE"_copy | $GREP $FILENAME.$rop | $XAWK -v count=$symLinkCount -v latency=$latency '{ 

					 if ( $3 < count ) {
					 	$2=latency
					 	$3=count;
					 }

				print  $1"  "$2"  "$3;
			}' | $TEE -a "$LOGFILE"	

		fi
	done < $ROP_FILE
fi

$RM $SYMLINKS
$RM "$LOGFILE"_copy &> /dev/null
