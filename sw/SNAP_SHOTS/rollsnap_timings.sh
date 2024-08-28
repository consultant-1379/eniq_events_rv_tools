#!/bin/bash

# Script to parse rolling snapshot logs to gather and calculate timings for snapshots

DAY=$1
MONTH=$2
YEAR=$3
YEAR_FULL="20$YEAR"
MONTH_NUM=`echo "$MONTH" | /usr/bin/sed 's/^0//g'`
MONTH_INDEX=$(($MONTH_NUM-1))
HOSTFILE=/eniq/sw/conf/server_types
MONTHS=(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
SNAP_LOGS=/eniq/local_logs/rolling_snapshot_logs/prep_roll_snap.log*
CAT=/usr/bin/cat
CUT=/usr/bin/cut
GREP=/usr/bin/grep
GGREP=/usr/sfw/bin/ggrep
EGREP=/usr/bin/egrep
NAWK=/usr/bin/nawk
CO_ORD=$($CAT /eniq/home/dcuser/eniq_events_rv_tools/sw/config | $GREP ^Controlzone | $NAWK -F= '{print $2}' | tr -d '\r')

function __USAGE__() {
	case $1 in 
		1) echo -e " \n\n\tUsage : args month <dd> <mm> <yy> e.g. 27 05 14 \n\n"
		   exit 1
		   ;;
		2) echo -e " \n\nUsage : this script must be run on co-ordinator server: $CO_ORD\n\n"
		   exit 1
		   ;;
	esac
}

if [ "$#" -ne 3 ] ; then
	__USAGE__ 1
fi

if [ "$HOSTNAME" != "$CO_ORD" ] ; then 
	__USAGE__ 2
fi


function __GET_ROLL_AND_ZFS_SNAP_TIMES__() {
	echo -e "\nROLLING SNAPSHOT TIMINGS - $1"
	echo "--------------------------------------------"
	ROLL_SNAP_START=`$CAT $SNAP_LOGS | $GREP "Rolling snapshot started at $DAY\.$MONTH\.$YEAR"`
	ROLL_SNAP_FINISH=`$CAT $SNAP_LOGS | $GREP "$DAY\.$MONTH\.$YEAR_.* - Rolling Snapshot successfully created on ENIQ Server"`
	echo $ROLL_SNAP_START
	echo -e "$ROLL_SNAP_FINISH \n\n"

	echo "ZFS Snapshot Timings - $1"
	echo "--------------------------------------"
	$CAT $SNAP_LOGS | $GREP "$YEAR_FULL-${MONTHS[$MONTH_INDEX]}-$DAY" | $GREP " - Starting to create ZFS snapshots"
	echo -e "ZFS SNAPSHOT END TIME IS START OF SAN SNAP SHOT - Please see below\n\n"
}

function __GET_SAN_SNAP_TIMES__() {
	echo "SAN SNAPSHOT TIMINGS - $1"
	echo "--------------------------------------"
	$CAT $SNAP_LOGS | $GREP "$YEAR_FULL-$MONTH-$DAY" | $GREP " -  Starting to create SAN snapshots"
	$CAT $SNAP_LOGS | $GREP "$DAY\.$MONTH\.$YEAR" | $GREP " - Successfully created the SAN snapshots"
}

function __GET_NAS_SNAP_TIMES__() {
	echo -e "\n\nNFS Snapshot Timings - $1"
	echo "---------------------------------------------"
	$CAT $SNAP_LOGS | $GREP "$YEAR_FULL-${MONTH}-${DAY}_.*- Starting to create NFS snapshots"
	PATTERN=`$CAT $SNAP_LOGS | $GREP "$YEAR_FULL-${MONTH}-${DAY}_.*- Starting to create NFS snapshots" | /usr/bin/tail -1`
	$CAT $SNAP_LOGS | $GGREP -A20 "$PATTERN" | $GREP "snee" | $GREP "created"
}

__GET_ROLL_AND_ZFS_SNAP_TIMES__ $CO_ORD
__GET_SAN_SNAP_TIMES__ $CO_ORD
__GET_NAS_SNAP_TIMES__ $CO_ORD

for SERVER in `$CAT $HOSTFILE | $GREP -v coordinator | $CUT -d: -f3` ; do
	
	ssh root@$SERVER "echo '\n\n\n\nSNAPSHOT TIMINGS - $SERVER';
					  echo '--------------------------------------------';
					  $CAT $SNAP_LOGS | $GGREP -A50 'Rolling snapshot started at "$DAY.$MONTH.$YEAR"' | $EGREP -v '^Creating|^Backing|^$|eniq|Preparing|Snapping|Cleaning'
					  " 2>/dev/null

done