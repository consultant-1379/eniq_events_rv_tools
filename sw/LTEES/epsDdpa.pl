#!/usr/bin/perl -C

##Assistante tool for ddpa eps mornitoring
##Owned by Softbank RV team
##Any concern please contact ejmnqrz & epaupea

use strict;

my $logPath="/eniq/log/sw_log/mediation_gw/wfinstr/";
my @logList=`ls -lrt $logPath | grep wfin`;
print "[INFO] DDPA logs list below:\n";
print @logList;
print "\n[INFO] Pick the file you want to check (instument logs are sent to DDPA's database by every half day):\n";
my $log=<STDIN>;
chomp $log;
$log=$logPath.$log;
print "[INFO] Parsing EPS in $log";

my @content=`cat $log | grep EBSL | grep -v "Events=0" |grep "Events="`;
my @hours = qw(00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23);
print "\n\nHOUR(EE)\t\tEPH\t\tEPS\n";
foreach my $hour(@hours){
	my $eph=0;
	foreach my $line(@content){
		if ($line =~ m/$hour:\d\d:\d\d.*?Events=(\d+)/){
		#print "$1\n";
			$eph+=$1;
		}
	}
	$eph=sprintf("%12d",$eph);
	my $eps=sprintf ("%8d",$eph/3600);
	print "$hour\t\t$eph\t    $eps\n";
}




