=comment
Attempts to kill the specified process. Will only kill the process with pid $_[0]
if it's command is the same as $_[1] 
Args:
	0 - PID of process to kill
	1 - Process command (listed under CMD column when running ps) i.e command that spawned the
		process.
=cut
use strict;
use parsingFuncs;

my $pid = $ARGV[0];
my $cmd = $ARGV[1];

#Make sure to exclude this process - it will list due to having the pid of the target 
#process in the arg list
=comment
Continuing on from the example in checkServers.pl:

	Assuming this was called as:
		
		kill_proc.pl 1234 df -hk
	
	And the current PID is 1235, the following will expand to 
	
		ps -e | grep 1234 | grep "df" | grep -v 1235
=cut
my $procList = qx( ps -e | grep $pid | grep \"$cmd\" | grep -v $$);

#If the above found a process, then it is alive and should be killed
if ($procList ne "")
{
	#This error message must start with the text "Killing" and be output to STDOUT, not STDERR!
	#This is a workaround to ensure it is correctly identified; also STDERR is frequently redirected 
	#to /dev/null when accessing a server via SSH, in order to silence the banner message
	#Generally speaking, the error details will be elaborated upon when this is caught in checkServers.pl
	print "Killing $pid; $cmd - command timed out";
	qx(kill $pid);
}