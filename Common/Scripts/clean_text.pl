#!/usr/bin/perl

# /-----------------------------------------------------------------------------------------------------------
# Cleaning utility - Version 2, converts UTF-8 encoded file into Unicode (Windows default text encoding).
# ODI converts files to UTF-8 after calculating the audit file, so this utility can be used to return
# to Unicode to ensure Audit file checks are completed appropriately.
#
# Input: 1 Argument - Filename
# Output: STDOUT
# /-----------------------------------------------------------------------------------------------------------

use strict;
use warnings;
#use Encode qw(encode :fallbacks);
#use Encode 'decode';
#use Encode 'decode_utf8';
use open ':encoding(UTF-8)';

# open the file
open my $fh, '<:utf8',  $ARGV[0] or die "could not open $ARGV[0]";

my $line = "";

# loop line by line until EOF
while ( ! eof($fh) ) {
	$line = readline($fh);
	#my $converted = decode_utf8($line);
	#print $converted;
	print $line;
	#print decode('UTF-8', $line, FB_DEFAULT);
}

# close the file
close $fh;