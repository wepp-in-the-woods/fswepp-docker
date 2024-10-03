#!/usr/bin/perl

use warnings;
use CGI;
use CGI qw(escapeHTML);

my $cgi    = CGI->new;
my $man_fn = escapeHTML( $cgi->param('f') );

print "Content-type: text/plain\n\n";

# Check if the filename parameter is provided
if ( !$man_fn ) {
    print 'no management file specified';
    exit;
}

# Validate filename against allowed options
my @valid_files = qw(
  3inslope.man 3inslopen.man 3outrut.man 3outrutn.man
  3outunr.man 3outunrn.man
);

unless ( grep { $_ eq $man_fn } @valid_files ) {
    print "I don't like the specified file $man_fn";
    exit;
}

# Check if the file exists
my $manfile = 'data/' . $man_fn;
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
