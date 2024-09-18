#!/usr/bin/perl

# test.pl
# This is not BAER Web DB production code.  It's a page that tests the DB and
# our library files for bugs.  -CMA 2014.01.21.

use strict;
use warnings;

################################# "#INCLUDES" ##################################

require "Query.pl";		# For TheProjs pkg.  -CMA 2014.01.21.
require "ShowProj.pl";	# For ShowProj pkg.  -CMA 2014.01.21.


################################### "MAIN()" ###################################

TheProjs::Init();
TheProjs::Load();
ShowProj::Init();

print "Content-type: text/html\n\n";

print( '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
						"https://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">' );

print( "
<html>
<head>
  <meta http-equiv='Content-type' content='text/html;charset=UTF-8' />
</head>
<body>
<h1>BAER DB Test Page</h1>
This page tests BAER DB for bugs.<br />
<br />
<b>Test:</b> Check that all treatments have valid types (either empty or found
in our table of treatment types).<br />
<br />
<b>Result:</b> 
" );

my $NumTmts = 0;	# Counter.
my $raProjs	= TheProjs::rGetC();

PROJECTS_LOOP:	# Check every treatment in every project for type validity.
for my $rProj ( @$raProjs ) {
TREATMENTS_LOOP:
	for my $rTmt ( BaerProj::Treatments( $rProj ) ) {
		$NumTmts++;		# Maintain the counter.

		my $Type = Treatment::Type( $rTmt );

		# Empty types are OK.
		next TREATMENTS_LOOP unless length( $Type ) > 0;

		my $Stupid = $ShowProj::raTmtTypesRowsXml;	# Kill only-once warning.

		# If the treatment's type is found in our types table, it's OK.
		if( grep { $_->{treatment} cmp $Type } @$ShowProj::raTmtTypesRowsXml ) {
			next TREATMENTS_LOOP; }

		# If we get here, it's NOT OK!
		print( "<span style='color:red'><b>ERROR! Treatment \"" .
				Treatment::Descr( $rTmt ) . "\" in project \"" .
				BaerProj::Firename( $rProj ) . "\" in forest \"" .
				BaerProj::Forest( $rProj ) .
				"\" has invalid treatment type \"$Type\".</b><span>" );

		# Test post-loop code that we found & reported an error.
		$NumTmts = -1;

		last PROJECTS_LOOP;		# One error per run is enough.
	}
}

# If we didn't find an error, then report success.
if( $NumTmts >= 0 ) {
	print( "Checked $NumTmts treatments, all OK." ); }

print( "<br />" );
print( "</body></html>\n" );

# End "Main" script.  -CMA 2014.01.21.


################################# END OF FILE #################################
