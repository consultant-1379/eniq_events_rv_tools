#!/usr/bin/bash
############# Scripts checks the input file, and backlog in etldata directories for error raw , error failed and  imsi suc ############
GREP=/usr/bin/grep
CONFIG="/eniq/home/dcuser/eniq_events_rv_tools/sw/config"
AWK=/usr/bin/awk
SORT=/usr/bin/sort
LS=/usr/bin/ls
TR=/usr/bin/tr
WC=/usr/bin/wc

SGEH_INPUT=$($GREP SGEH_INPUT $CONFIG | $AWK -F= '{print $2}' | $TR -d '\r')
SUC_DIR_IMSI=$($GREP SUC_DIR_IMSI $CONFIG | $AWK -F= '{print $2}' | $TR -d '\r')
ERR_DIR_FAIL=$($GREP ERR_DIR_FAIL $CONFIG | $AWK -F= '{print $2}' | $TR -d '\r')
ERR_DIR=$($GREP ERR_DIR $CONFIG | $AWK -F= '{print $2}' | $TR -d '\r')


INPUT_FOLDER_FILE_TIME_STABMP=`$LS -Rltr $SGEH_INPUT | $GREP -i MME | $AWK '{print $6 " " $7 " " $8}' | $SORT -u`
SGEH_FILE_ERR_BINARY_COUNT=`$LS -ltrR $ERR_DIR | $GREP A20 | $GREP MME | $WC -l`
SGEH_FILE_FAILED_BINARY_COUNT=`$LS -ltrR $ERR_DIR_FAIL | $GREP A20 | $GREP MME | $WC -l`
SGEH_FILE_IMSI_COUNT=`$LS -ltrR $SUC_DIR_IMSI | $GREP imsi_suc | $GREP binary | $WC -l`

echo "SGEH MME Input File time stamps: $INPUT_FOLDER_FILE_TIME_STABMP"
echo "sgeh_file_err_binary_count: $SGEH_FILE_ERR_BINARY_COUNT"
echo "sgeh_file_failed_binary_count: $SGEH_FILE_FAILED_BINARY_COUNT"
echo "SGEH_FILE_IMSI_COUNT: $SGEH_FILE_IMSI_COUNT"
