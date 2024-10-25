#!/usr/bin/perl

use warnings;
use strict;
use CGI;
use CGI qw(escapeHTML);

my $cgi    = CGI->new;
my $manfile = escapeHTML( $cgi->param('f') );

print "Content-type: text/plain\n\n";

# Check if the filename parameter is provided
if ( !$manfile ) {
    print 'no management file specified';
    exit;
}

unless ( -e $manfile ) {
    print "I can't open file $manfile";
    exit;
}

# Read and print the file contents
open my $MAN, '<', $manfile or do {
    print "Error opening file $manfile";
    exit;
};
print <$MAN>;
close $MAN;
