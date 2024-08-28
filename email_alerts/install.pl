#!/usr/bin/perl -C

##Script used to initial & configure email_alarms project

use strict;
use Cwd;
use Sys::Hostname;
use File::Copy;


my @coordServer;
my $host;


sub grepFile{
	my $pattern = shift;
	my $file = shift;
	my $arg = shift;
	
	open( FILE, $file );
	my @contents = <FILE>;
	close( FILE );
	
	if($arg =~ /i/){
		return grep(/$pattern/i, @contents);
	}
	return grep(/$pattern/, @contents);
}

sub conf_Config{
	#parameters set in config file
	my $deploymentName;
	my $rootFileSystemLoadTolerance;
	my $NASLoadTolerance;
	my $ZFSLoadTolerance;
	
	print "Configure /email_alerts/config\n";
	open (FILE, "</email_alerts/config") or die "Can not open file $!";
	my @content = <FILE>;
	close FILE;
	print "Please set the deployments name that will be popped in email alarts, e.g. Softbank\n";
	chomp($deploymentName=<STDIN>);
	print "Please set % root usage on  any server in deployment is above this email will send, e.g. 85\n";
	chomp($rootFileSystemLoadTolerance=<STDIN>);
	print "Please set % root usage on any NAS mount is above this, email will send, e.g. 60\n";
	chomp($NASLoadTolerance=<STDIN>);
	print "Please set % root usage on any ZFS mount is above this, email will send, e.g. 60\n";
	chomp ($ZFSLoadTolerance=<STDIN>);
	
	#if (($rootFileSystemLoadTolerance ~~ [1..99]) && ($NASLoadTolerance ~~ [1..99]) && ($ZFSLoadTolerance ~~ [1..99]))
		
		print qq{
deploymentName = $deploymentName
rootFileSystemLoadTolerance = $rootFileSystemLoadTolerance
NASLoadTolerance = $NASLoadTolerance;
ZFSLoadTolerance= $ZFSLoadTolerance;
		
};
		print "Please confirm above values, hit return to proceed\n";
		my $input = <>;
		if ($input eq "\n"){
			foreach (@content){
				s/^mailServer =.*$/mailServer = $host/;
				s/^rootFileSystemLoadTolerance =.*$/rootFileSystemLoadTolerance = $rootFileSystemLoadTolerance/;
				s/^NASLoadTolerance =.*$/NASLoadTolerance = $NASLoadTolerance/;
				s/^ZFSLoadTolerance =.*$/ZFSLoadTolerance = $ZFSLoadTolerance/;
				s/^coordServer =.*$/coordServer = $host/;
				s/^deploymentName = .*$/deploymentName = $deploymentName/;
			}
			print ("Please refer to /email_alerts/config for detail\n");
		}else{
			conf_Config();
			}
		

		open (FILE, ">/email_alerts/config") or die "Can not open file $!";
		print FILE @content;
		close FILE;
	
}


##MAIN
{

@coordServer=grepFile("engine", "/etc/hosts");
$host=hostname;
if (!grep(/$host/,@coordServer)) {
	print "ERROR:Run this script as dcuser on your ENIQ server's coordinator\n";
	exit 1;
}
system("cp -r ../email_alerts/ /");
chdir("/email_alerts/");

print qq{
RV tool email_alarm will be applied on this deployment, whose coordinator is $host
Press enter if you want to continue
};

my $input=<STDIN>;
if($input ne "\n"){
print "User cancelled the process. Script exists..\n";
exit 1;
}

my $currentDir=cwd();
print "Proceeding installation in $currentDir\n";

#Configure config file
conf_Config();



}