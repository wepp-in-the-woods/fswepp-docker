#!/usr/bin/perl

# adhoc.pl
# This is not BAER Web DB production code, but rather just a place to write
# temp code for ad-hoc queries.  -CMA 2013.08.13.

use strict;
use warnings;

################################# "#INCLUDES" ##################################

require "Query.pl";		# For TheProjs pkg.  -CMA 2013.08.13.


################################### "MAIN()" ###################################

Treatment::Init();
BaerProj::Init();
TheProjs::Init();
TheBwdPageState::Load();	# Accesses our URL params.
TheProjs::Load();	# Load from file the data we'll be querying.

print "Content-type: text/html\n\n";

print( '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
						"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">' );

print( "
<html>
<head>
	<meta http-equiv='Content-type' content='text/html;charset=UTF-8' />
" );

#Head131118();

print( "
</head>
<body>\n" );

# Ad-hoc query code goes here.
#Query130918();
#Body131118();

print( "DOCUMENT_ROOT = " . $ENV{'DOCUMENT_ROOT'} );
	
print( "</body'></html>\n" );


# End "Main" script.  -CMA 2013.08.13.


###############################################################################
sub Query130806 {
	print( "Query130806.1515.<br />\n" );

	my $raProjs = TheBwdPageState::Filter();
	my $fnNoAction = sub { $_->[ 19 ] };

	print( "Total cost of no treatment: " .
					BwdUtils::Total_fn( $raProjs, $fnNoAction ) . "<br />" );

	my @VarTags =
			( "LifeThrtDescr", "PropThrtDescr", "WtrQualThrtDescr",
								"T_x0026_ESpcDescr", "SoilProdThrtDescr" );

	for my $Tag ( @VarTags ) {
		my $fnCount = sub { BaerProj::PropByTag( $_, $Tag ) ? 0 : 1 };

		my $Tot = 0;

		for( @$raProjs ) {
			$Tot++ if BaerProj::PropByTag( $_, $Tag ); }

		print( "# with $Tag: " . $Tot . "<br />\n" );
	}
}

###############################################################################
sub Query130818 {
	print( "Query130818.1125.<br />\n" );

	my %TmtUnits;

	for my $rProj ( @{ TheBwdPageState::Filter() } ) {
		for my $rTmt ( BaerProj::Treatments( $rProj ) ) {
			$TmtUnits{ Treatment::Units( $rTmt ) }++; } }

	my @Sorted = sort { $TmtUnits{ $b } <=> $TmtUnits{ $a } } keys( %TmtUnits );

	print( "$_: " . $TmtUnits{ $_ } . "<br />\n" ) for @Sorted;
}

###############################################################################
sub Query130819 {
	print( "Query130819.1132.<br />\n" );
	print( "$_<br />\n" ) for @INC;
}

###############################################################################
sub Query130917 {
	print( "Query130917.1612.<br />\n" );

	for( ( "2500-8_South Fork_Boise.pdf",
					"2500-8_Bear’S Oil, Wendover, Pleasant_Clearwater.pdf" ) ) {
		print( $_ . "<br />");
	}
}

###############################################################################
sub Query130918 {
	print( "Query130918.0929.<br />\n" );

	my $Firename = BaerProj::Firename( ${ TheBwdPageState::Filter() }[ 734 ] );

	print( "Fire name: $Firename<br />" );

	for( 0 .. ( length( $Firename ) - 1 ) ) {
		my $Ch = substr( $Firename, $_, 1 );

		print( "($Ch" . ") " . ord( $Ch ) . "<br />\n" );
	}
}

###############################################################################
sub Head131118 {
	# Note, this seems to work with no <key> param!
	print( "
<!--
-->
		<script type='text/javascript'
					src='https://maps.googleapis.com/maps/api/js?sensor=false'>
		</script> 
		<script type='text/javascript'>
			function OnLoad131118() {
				alert( 'In OnLoad131118().' );

				var oOptions = {
						center: new google.maps.LatLng( 46, -117 ),
						zoom: 8,
						mapTypeId: google.maps.MapTypeId.ROADMAP
				};

				var divMap = document.getElementById( 'divMap' );
				var map    = new google.maps.Map( divMap, oOptions );
			}
		</script>
	" );
}

###############################################################################
sub Body131118 {
	print( "<div id='divMap' style='width:400px; height:300px'>divMap</div>" );
}

################################# END OF FILE #################################
