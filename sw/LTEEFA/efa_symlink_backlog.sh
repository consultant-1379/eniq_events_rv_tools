#!/bin/bash

# This script will count the number of symbolic links in the following directory:

# /eniq/data/pmdata/eventdata/00/CTRS/lte_cfa/5min    - CTR symlink Directory
# /eniq/data/pmdata/eventdata/00/CTRS/ctum/5min - CTUM symlink Directory

# and return the maximum mtime of the links that it finds. It does not discriminate between ROPs. i.e. if there
# are multiple ROP times it will return the mtime of the most recent file.

LS=/usr/bin/ls
CAT=/usr/bin/cat
GREP=/usr/bin/grep
AWK=/usr/bin/awk
SORT=/usr/bin/sort
HEAD=/usr/bin/head
RM=/usr/bin/rm
TEE=/usr/bin/tee
EPOCH=`/usr/bin/nawk 'BEGIN{print srand()}'`
TEMP_FILE_CTRS=/tmp/.ctr_symlink_efa_latency$EPOCH.sh
TEMP_FILE_CTUM=/tmp/.ctum_symlink_efa_latency$EPOCH.sh
LOGFILE=/eniq/home/dcuser/eniq_events_rv_tools/sw/logs/efa_symlinks_backlog.log
CTRS_SYMLINK_COUNT=0
CTRS_MAX_LATENCY=0
CTUM_SYMLINK_COUNT=0
CTUM_MAX_LATENCY=0
CONFIG="/eniq/home/dcuser/eniq_events_rv_tools/sw/config"
CTRS_SYM_DIR=$($GREP CTRS_SYM_DIR $CONFIG | $AWK -F= '{print $2}' | $TR -d '\r')
CTUM_SYM_DIR=$($GREP CTUM_SYM_DIR $CONFIG | $AWK -F= '{print $2}' | $TR -d '\r')

function cleanup() {
	$RM $TEMP_FILE_CTRS $TEMP_FILE_CTUM
}

function collectSymlinks() {
	$LS -lR $CTRS_SYM_DIR | $GREP bin.gz | $AWK '{ print $8" "$9}'> $TEMP_FILE_CTRS
	$LS -lR $CTUM_SYM_DIR | $GREP _ctum- | $AWK '{ print $8" "$9}'> $TEMP_FILE_CTUM
}

function countSymlinks() {
	CTRS_SYMLINK_COUNT=`$CAT $TEMP_FILE_CTRS | wc -l`
	CTRS_MAX_LATENCY=`$CAT $TEMP_FILE_CTRS | $SORT -k 1.1nbr -k 1.3nbr | $HEAD -1 | $AWK '{ print $1 }'`
	CTUM_SYMLINK_COUNT=`$CAT $TEMP_FILE_CTUM | wc -l`
	CTUM_MAX_LATENCY=`$CAT $TEMP_FILE_CTUM | $SORT -k 1.1nbr -k 1.3nbr | $HEAD -1 | $AWK '{ print $1 }'`
}

collectSymlinks
countSymlinks
cleanup

echo `date -u` | $TEE -a $LOGFILE
echo "CTRS EFA Symlink Backlog: $CTRS_SYMLINK_COUNT" | $TEE -a $LOGFILE
echo -e "CTRS EFA Symlink Latency: $CTRS_MAX_LATENCY\n" | $TEE -a $LOGFILE
echo "CTUM EFA Symlink Backlog: $CTUM_SYMLINK_COUNT" | $TEE -a $LOGFILE
echo -e "CTUM EFA Symlink Latency: $CTUM_MAX_LATENCY\n\n" | $TEE -a $LOGFILE
