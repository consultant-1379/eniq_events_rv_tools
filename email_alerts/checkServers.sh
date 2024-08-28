#! /bin/bash
#Wrapper needed so environment is correctly set
cd /email_alerts/perl
#Throw date into result file, can be used to check when it last ran
startTime=$(date)
echo $startTime > cronResult.txt
{ perl checkServers.pl $1 ; }  >> cronResult.txt 2>&1
finishTime=$(date)
echo -e "Started at: $startTime\nFinished at: $finishTime" >> cronResult.txt