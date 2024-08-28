package ServiceEntry;
=comment
ServiceEntry objects are used to store data describing
the state that a selection of services should be in on a given
server
=cut

=comment
Constructs a new ServiceEntry object
Args:
	0 - String, name of the server
	1 - Pointer to array containing all the name of all online services
	2 - Pointer to array containing all the name of all offline services
	3 - Pointer to array containing all the name of all disabled services
	4 - Pointer to array containing all the name of all legacy run services
=cut
sub new
{
	my $class = shift;
	my $self =
		{
		serverName => shift,
		onlineServicesPtr => shift,
		offlineServicesPtr => shift,
		disabledServicesPtr => shift,
		legacyrunServicesPtr => shift
		};
	bless $self;
}

sub getServerName
{
	return shift->{serverName};
}

sub setServerName
{
	my($self, $name) = @_;
	$self->{serverName} = $name;
}

sub getOnlineServicesPtr
{
	return shift->{onlineServicesPtr};
}

sub addOnlineService
{
	my($self, $svc) = @_;
	push(@{$self->{onlineServicesPtr}}, $svc);
}

sub getOfflineServicesPtr
{
	return shift->{offlineServicesPtr};
}

sub addOfflineService
{
	my($self, $svc) = @_;
	push(@{$self->{offlineServicesPtr}}, $svc);
}

sub getDisabledServicesPtr
{
	return shift->{disabledServicesPtr};
}

sub addDisabledService
{
	my($self, $svc) = @_;
	push(@{$self->{disabledServicesPtr}}, $svc);
}

sub getLegacyRunServicesPtr
{
	return shift->{legacyrunServicesPtr};
}

sub addLegancyRunService
{
	my($self, $svc) = @_;
	push(@{$self->{legacyrunServicesPtr}}, $svc);
}

=comment
Gets a string for use in grep queries. The string will be a fully formed grep command,
searching for each of the specified services in the output of the "svcs -a" command
Args:
	0 - String, type. One of :
		online
		offline
		disabled
		legacy
Returns:
	String in format:
		svcs -a | egrep -i "<service1>|<service2>|..|<serviceN>" | egrep -v <type>
=cut
sub getGrepString
{
	my($self, $type) = @_;
	my @services;
	my $queryString = "svcs -a | egrep -i \"";
	
	if($type eq "online")
	{
		#Dereference the pointer
		@services = @{$self->{onlineServicesPtr}};
		for(my $e = 0; $e < @services; $e++)
		{
			$queryString.=$services[$e];
			#the or pipe should not be added after the last element
			if($e != @services - 1)
			{
				$queryString.="|";
			}
		}
		$queryString.="\" | egrep -v online";
	}
	elsif($type eq "offline")
	{
		@services = @{$self->{offlineServicesPtr}};
		for(my $e = 0; $e < @services; $e++)
		{
			$queryString.=$services[$e];
			#the or pipe should not be added after the last element
			if($e != @services - 1)
			{
				$queryString.="|";
			}
		}
		$queryString.="\" | egrep -v offline";
	}
	elsif($type eq "disabled")
	{
		@services = @{$self->{disabledServicesPtr}};
		for(my $e = 0; $e < @services; $e++)
		{
			$queryString.=$services[$e];
			#the or pipe should not be added after the last element
			if($e != @services - 1)
			{
				$queryString.="|";
			}
		}
		$queryString.="\" | egrep -v disabled";
	}
	elsif($type eq "legacy")
	{
		@services = @{$self->{legacyrunServicesPtr}};
		for(my $e = 0; $e < @services; $e++)
		{
			$queryString.=$services[$e];
			#the or pipe should not be added after the last element
			if($e != @services - 1)
			{
				$queryString.="|";
			}
		}
		$queryString.="\" | egrep -v legacy_run";
	}
	return $queryString;
}

1;