Each sh script in this directory will be executed from this directory (Not root or dcuser home directory!).
An execution timeout must be defined by adding a comment to the second line (i.e. the line
after the shebang) as follows:

	#TIMEOUT=<value in seconds>
	
e.g. for a 5 second timeout the head of the script may look like:

	#!/bin/bash
	#TIMEOUT=5

Note that execution will block for the amount of seconds specified in the header - large timeouts
should be avoided where possible. If SSHing into a server, ensure the public/private keys have been set
up before attempting to access it

Example script:
-----------------------------
#!/bin/bash
#TIMEOUT=5

cd /
ls
-----------------------------