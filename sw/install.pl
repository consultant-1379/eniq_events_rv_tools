#!/usr/bin/perl -C0

use strict;
use Cwd;
use Sys::Hostname;
use File::Copy;

my $BASE_DIR = "/eniq/home/dcuser/eniq_events_rv_tools";
my $audit_log = $BASE_DIR.'/sw/installation.log';
my $configFile = $BASE_DIR.'/sw/config';
my $ctrs=0;
my $events_oss_LTEES;

my @coordServer;



sub FT_LOG {
	my ($message) = @_;
	chomp $message;
	if (open (AUDIT, ">> $audit_log")) {
		my ($SS, $MM, $HH, $dd, $mm, $yy) = (localtime)[0..5];
		my ($time) = sprintf("%d-%02d-%02d %02d:%02d:%02d",$yy+1900, $mm+1, $dd, $HH, $MM, $SS);
		print AUDIT "$time $message\n";
		close AUDIT;
	}else{
		print STDOUT "$message\n";
		print ("Could not open $audit_log for writing");
	}
	print STDOUT "$message\n";
}


sub executeThisWithLogging{
	my @cmd;
	my $command = shift;
	open(CMD,"$command |");
	while(<CMD>){
		&FT_LOG($_);
		push(@cmd, $_);
	}
	close(CMD);
	return @cmd;
}

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

sub prompt{
	my ($query) = @_;
	local $| = 1;
	$query.="\n";
	print $query;
	chomp (my $answer = <STDIN>);
	return $answer;
}

sub prompt_yn{
	my ($query)=@_;
	my $answer = prompt ("$query (Y/N):");
	if (lc ($answer) eq 'y'){
		return 1;
	}elsif (lc ($answer) eq 'n'){
		return 0;
	}else{
		print "Invalid input\n";
		$answer = prompt ("$query (Y/N):");	
	}
}

sub openConfig{
	open (FILE, "< /eniq/home/dcuser/eniq_events_rv_tools/sw/config") or die "Can not open config file $!";
	my @file=<FILE>;
	close FILE;
	return @file;
}

sub writeConfig{
	open (FILE, "> $configFile") or die "Can not open config file $!";
	print FILE @_;
	close FILE;
}

sub deploymentConfiguration{
my @content = openConfig();
foreach (@content){
	s/^Event_OSS_LTEES=.*$/Event_OSS_LTEES=$events_oss_LTEES/;
}
	
}
sub lteInstall{

$ctrs = prompt_yn("Do you have M_E_CTRS installed?");
unless($ctrs) {
	&FT_LOG("Proceed LTE Tools Without M_E_CTRS");
	system ("rm -r $BASE_DIR/sw/CTRS");
	unlink ("$BASE_DIR/sw/LTEES/count_ltees_symlink_bklog.sh");
}
$events_oss_LTEES = prompt("Enter the oss alias, e.g. events_oss_1");
my @content = openConfig();

foreach (@content){
	s/^Event_OSS_LTEES=.*$/Event_OSS_LTEES=$events_oss_LTEES/;
}
writeConfig(@content);

}

#MAIN METHOD
{

@coordServer=grepFile("engine", "/etc/hosts");
my $host=hostname;
if (!grep(/$host/,@coordServer)) {
	print "ERROR:Run this script as dcuser on your ENIQ server's coordinator\n";
	exit 1;
}
&FT_LOG("Install RV utilities package");
deploymentConfiguration();
lteInstall();


}

