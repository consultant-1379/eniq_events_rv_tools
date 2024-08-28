Checks server disk usage (local and NAS), services and dmesg output, and emails results to provided recipients. Can also run user-defined scripts 
and email the results

Script obtains a list of servers to check by looking at the file /eniq/sw/conf/service_names. The expected format for entries in this file is:
	
	ipv4_address::hostname::type

The value at hostname will be used to connect to the server, providing it starts with "atrcx". Any hostnames listed twice will only be checked once.
The co-ordinator must be defined in the file "config" (see below). All servers in the deployment will be accessed via SSH from the co-ordinator to run relevant 
checks (even the co-ordinator will SSH into itself). For this to work the servers must have their public/private keys set up to allow direct access from the 
coordinator - see below for more on this. A set of additional scripts to run can be provided in the additional_scripts folder. All scripts present here
will be ran, and the output emailed. See the README in that directory for more information.

Installation:
	-Place the email_alerts folder on the co-ordinator server in your deployment.
	-Grant execution permissions for the file checkServers.sh
	-Schedule the file checkServers.sh on a cron (instructions below).
	 
To configure:
	-Config fields are in the file "config".
	-To change mail recipients, edit mailList.txt.
	-To change services to monitor edit services_config.
	-To add additional scripts to run, place them in the additional_scripts folder.
	
Usage instructions:
	-Before running, edit config and specify the correct values for the mail server and coordinator. The other
		config values should also be edited as needed.
		
	-When running for the first time (or after a re-install) host keys will need to
		be re-confirmed. Either do this manually, or run: "perl checkServers.pl -qm" from the installation dir
		and confirm each key as prompted. You will only have as much time to accept the key as is defined in
		the config variable networkCommandTimeout (by default this is set to 6)
		
	-checkServers.sh should be scheduled on a cron job at desired intervals - this will check systems as specified
		Usage:
			./checkServers.sh -qctslmwah
		Switches
			q : print email text to console rather than send emails
			c : send an email to confirm any checks succeeded, even if there are no problems
			t : set networkCommandTimeout to 1 second (rather than defined value)
			s : check services
			l : check disk usage - local & NAS
			m : check dmesg output
			w : run check for any services which have entered maintenance mode, if checking services
			a : execute additional scripts
			h : help
			
	-The perl script can be ran directly for testing purposes - don't schedule the Perl script on a cron.
		Usage: perl checkServers.pl -qctslmwah

	-Check cronResult.txt for results of last run, will indicate success/failure and error details
	
	-Sample cron entry:
		0 15 * * * /email_alerts/checkServers.sh -lsmw
		0 8 * * * /email_alerts/checkServers.sh -clsmw

		This entry runs two checks daily - at 8am disk load, services, dmesg output and services in maintenance are checked.
		At 3pm the same checks are ran, with confirmation. This means that the checks are ran twice daily, but a confirmation mail
		will only be sent at 3pm - this is a good system for ensuring the script is functioning properly, but not spamming inboxes
		with mail.

Any problems or issues: daniel.rogers@ericsson.com
Latest version available at https://gerrit.ericsson.se/#/admin/projects/OSS/com.ericsson.eniq.events/eniq_events_rv_tools
See "File Description.txt" for more info