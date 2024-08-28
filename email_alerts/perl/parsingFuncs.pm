use strict;
=comment
Library of commands used to process text
=cut

sub say
{
	if(not defined($_[1]))
	{
		print $_[0]."\n";
	}
}

=comment
	Pulls data from a line of text at specified column. Delimits using dashes, dots (periods)
	colons and whitespace, by default.
Args:
	0 - String, Line of text to read data from
	1 - Number, column index - this is 0 padded, so use 1 for the first column
	2 - Number, Delimit using WS only. Leave blank or undef for standard delimit
Returns:
	Data at column specified
=cut
sub getColumnData
{
	my $lineData = $_[0];
	my $columnToPullDataFrom = $_[1];
	$lineData = &trim($lineData);
	#Older implementation of this subroutine was not zero-indexed, adjust here to keep things working.
	$columnToPullDataFrom--;
	my @dataArray;
	my $columnCount = 0;
	#Standard delimit
	if(not defined($_[2]))
	{
		#Split on spaces, dots or dashes
		#A single split will fail here given the following string:
		#	"Usage: grep -hblcnsviw pattern file . . .\n"
		#This will give a length of 6 (instead of 5), because of the dash before the
		#grep switches. The workaround is to join the string back with a pattern not 
		#likely to be seen, then splitting again on this pattern with the + option
		@dataArray = split(/&&&&&+/, join("&&&&&", split (/ +|\.|\-|:/, $lineData)));
		$columnCount = @dataArray;
		if($columnToPullDataFrom >= $columnCount)
		{
			die "Attempt to access column $columnToPullDataFrom is invalid, line only has $columnCount columns! Line:\n".$lineData."\nendl";
		}
		else
		{
			return $dataArray[$columnToPullDataFrom];
		}
	}
	#WS only delimit
	else
	{
		@dataArray = split (/ +/, $lineData);
		$columnCount = @dataArray;
		if($columnToPullDataFrom >= $columnCount)
		{
			die "Attempt to access column $columnToPullDataFrom is invalid, line only has $columnCount columns! Line:\n".$lineData."\nendl";
		}
		else
		{
			return $dataArray[$columnToPullDataFrom];
		}
	}
	die "Error in getColumnData, should not be here! Debug textParser.pm";
}

=comment
	Counts the number of columns in a line - delimits using dashes, dots (periods)
	colons and whitespace by default
Args:
		0 - String, Line of text to read from
		1 - Bool, delimit using ws only
Returns:
		int, real number of columns
=cut
sub countColumnsInLine
{	
	my $lineData = $_[0];
	my $columnCount = 0;
	$lineData = &trim($lineData);
	if(not defined($_[1]))
	{
		#Split on spaces, dots or dashes
		#A single split will fail here given the following string:
		#	"Usage: grep -hblcnsviw pattern file . . .\n"
		#This will give a length of 6 (instead of 5), because of the dash before the
		#grep switches. The workaround is to join the string back with a pattern not 
		#likely to be seen, then splitting again on this pattern with the + option
		$columnCount = split(/&&&&&+/, join("&&&&&", split (/ +|\.|\-|:/, $lineData)));
		return $columnCount;
	}
	$columnCount = split (/ +/, $lineData);
	return $columnCount;
}

=comment
	Splits a block of text to an array, delimits using newlines
Args:
	0 - String, text to split
Returns:
	Pointer to array containing split text
=cut
sub splitToArray
{
	my $text = $_[0];
	my @returnArray = split(/\n/, $text);
	return \@returnArray;
}

=comment
Trims all leading and trailing whitespace from the provided string
Args:
	0 - String to trim
Returns:
	String, trimmed string
=cut
sub trim
{
	#$_[0] is an alias to passed variable, editing that variable 
	#may not be the intended effect
	my $str = $_[0];
	$str =~ s/^\s+//;
	$str =~ s/\s+$//;
	return $str;
}

return 1;