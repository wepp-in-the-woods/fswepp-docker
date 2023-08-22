# ShowProj.pl
# Secondary "library" file containing code for displaying BAER project
# information in our Web page.  By Conrad Albrecht (CMA) 2014.01.13.

use strict;
use warnings;

################################# "#INCLUDES" ##################################

require HTML::Entities;		# -CMA 2013.08.19.
require XML::Simple;		# -CMA 2014.01.16.
require "Query.pl";			# For BaerProj pkg.  -CMA 2014.01.14.

###############################################################################
###############################################################################
# PACKAGE:  ShowProj.  -CMA 2014.01.14.

# Package for services provided by this file which don't go in any other
# particular package.
{	package ShowProj;

	# Reference to array of hash refs.  Each hash ref represents a row of our
	# DB's Treatments table (which table is actually a table of treatment
	# "types"), as read in by XML::Simple::XMLin() in our Init() sub.
	# -CMA 2014.01.16.
	our $raTmtTypesRowsXml;

	# These are the treatment types whose treatments almost all use the acre
	# unit, as chosen by me looking through our DB data.  Filled in Init().
	# -CMA 2014.02.04.
	my @_c_AcreUnitTmts;

	# Converts misc. irregular unit strings to our canonical equivalents.
	# Filled in Init().  -CMA 2014.01.14.
	my %_c_TmtUnitsCleanup;

	# Metric-equivalent information for English units.  Filled in Init().
	# -CMA 2014.01.14.
	my %_c_UnitsToMet;

###############################################################################
# SUB:  ShowProj::Init.
# ACTION:  Must be called before calling other members of this package.
sub Init {
	# -CMA 2014.02.04.
	@_c_AcreUnitTmts =
		(	"contour felling",
			"hydromulch,aerial",
			"mulching",
			"seeding - aerial",
			"seeding - ground",
			"seeding and fertilizer",
			"soil scarification",
			"straw mulch, aerial",
			"straw mulch, ground",
			"wood shreds",
			"woodstraw" );

	# -CMA 2013.08.18.
	%_c_TmtUnitsCleanup = (
			"AC"          => "ac",
			"acre"        => "ac",
			"Acre"        => "ac",
			"acres"       => "ac",
			"Acres"       => "ac",
			"ACRES"       => "ac",
			"Cu Yd"       => "cu yd",
			"cu yds"      => "cu yd",
			"Cu Yds"      => "cu yd",
			"cu. Yard"    => "cu yd",
			"cu. yd"      => "cu yd",
			"cu. Yd"      => "cu yd",
			"cu. Yds"     => "cu yd",
			"Cu. Yds"     => "cu yd",
			"cubic yards" => "cu yd",
			"Cubic Yards" => "cu yd",
			"CuYd"        => "cu yd",
			"CuYds"       => "cu yd",
			"cy"          => "cu yd",
			"CY"          => "cu yd",
			"feet"        => "ft",
			"Feet"        => "ft",
			"foot"        => "ft",
			"Ft"          => "ft",
			"ft3"         => "cu ft",
			"Gallons"     => "gal",
			"L.F."        => "ft",
			"lbs"         => "lb",
			"lf"          => "ft",
			"LF"          => "ft",
			"Lin - Ft"    => "ft",
			"lin ft"      => "ft",
			"Lin Ft"      => "ft",
			"Linear Ft"   => "ft",
			"linear ft."  => "ft",
			"linft"       => "ft",
			"mile"        => "mi",
			"Mile"        => "mi",
			"miles"       => "mi",
			"Miles"       => "mi",
			"Sq Ft"       => "sq ft",
			"Sq Yd"       => "sq yd",
			"sqft"        => "sq ft",
			"SqFt"        => "sq ft",
			"SqYds"       => "sq yd",
			"ton"         => "t",
			"tons"        => "t",
			"Tons"        => "t",
			"yd3"         => "cu yd",
			"yds"         => "yd",
	);

	# -CMA 2013.08.18.
	%_c_UnitsToMet = (
			"\$/ac"   => [ 1 / 0.404686,        "\$/ha" ],	# -CMA 2014.01.17.
			"1000 ft" => [ 0.3048,              "km"    ],
			"ac"      => [ 0.404686,            "ha"    ],
	
			# \xc2\xb3 is UTF-8 for superscript 3.  This works because we
			# specify charset=UTF-8 in our HTML <head>.
			"cu ft"   => [ 0.0283168,           "m\xc2\xb3" ],
			"cu yd"   => [ 0.764555,            "m\xc2\xb3" ],
	
			"ft"      => [ 0.3048,              "m"         ],
			"gal"     => [ 3.78541,             "l"         ],
			"lb"      => [ 0.453592,            "kg"        ],
			"mi"      => [ 1.60934,             "km"        ],

			# \xc2\xb2 is UTF-8 for superscript 2.
			"sq ft"   => [ 0.092903,            "m\xc2\xb2" ],
			"sq yd"   => [ 0.836127,            "m\xc2\xb2" ],

			"t"       => [ 0.907185,            "mt"        ],
			"tons/ac" => [ 0.907185 / 0.404686, "mt/ha"     ],
			"yd"      => [ 0.9144,              "m"         ],
	);

	my $Stupid = $TheProjs::DataPath;	# Kill only-once warning.
	my $TmtCatsPath = $TheProjs::DataPath . "Treatments.xml";

	# CMA replaced 2014.01.23.
#	my $TmtCatsPath = "/srv/www/htdocs/BAERTOOLS/baer-db/Treatments.xml";

	$raTmtTypesRowsXml = XML::Simple::XMLin( $TmtCatsPath )->{Treatments};
}	# ShowProj::Init.  -CMA 2014.01.14.

###############################################################################
# SUB:  ShowProj::PrintListView.
sub PrintListView { my ( $raProjs ) = @_;
	my $bShowTotals = TheBwdPageState::ShouldShowTotals();

	_PrintTotalsOverProjects( $raProjs ) if $bShowTotals;

	my $rPageState = TheBwdPageState::GetC();
	my $iPgStart   = BwdPageState::PageStart( $rPageState );
	my $iPgEnd     = $iPgStart + BwdPageState::PerPage( $rPageState ) - 1;

	# Correct $iPgEnd if it overshoots.
	$iPgEnd = @$raProjs if $iPgEnd > @$raProjs;

	my $SortedBy = BwdQuery::GetSortPhrase();		# -CMA 2013.08.23.

	# Show a command to show totals only if we're not already showing totals.
	my $TotalsRelink = $bShowTotals ? "" : " &nbsp;" . BwdQuery::GetTotalsRelink();

	my @ResizeLinks;	# Generate the "expand" and "shrink" links in here.

	for( 0..1 ) {	# -CMA 2013.08.15.
		my $rLinkPageState = TheBwdPageState::GetCopy();

		BwdPageState::SetSize( $rLinkPageState, $_ ? 0 : 1 );

		my $Cmd = $_ ? "shrink" : "expand";

		# I was disabling the resize command for the current state by making it
		# just text, but both commands need to be enabled anyway if the user has
		# any size exceptions, so I'm not bothering to try to figure out when to
		# disable one command.
		$ResizeLinks[ $_ ] = BwdQuery::GetRelink( $rLinkPageState, "$Cmd&nbsp;all" );
	}

	# This shows e.g.:
	#		"Showing reports 1-20 out of 345 selected, ordered by fire name:"
	# and then a row of command links, e.g.
	#		"show_totals   expand_all   shrink_all   metric_units"
	print( "
		Showing reports <b>$iPgStart-$iPgEnd</b> out of <b>" . @$raProjs .
													" selected</b>, $SortedBy:

		<div style='text-align:right'>
			$TotalsRelink &nbsp; " . $ResizeLinks[ 0 ] . " &nbsp; " . 
			$ResizeLinks[ 1 ] . " &nbsp; " . BwdQuery::GetUnitsRelink() . "
		</div>
	" );

	# Finally, the main event:  Show the reports.
	_PrintProjects( $raProjs, $iPgStart, $iPgEnd );		# -CMA 2013.08.14.
}	# ShowProj::PrintListView.  -CMA 2014.01.06.

###############################################################################
# SUB:  ShowProj::ShowIndentedAcres.

# ACTION:  Prints the section of a report summary that displays fire-intensity
# and erosion-hazard areas.

# PARAMS:  $rProj is a BearProj "object" (ref).

# NOTES:  Tested by Test140204_1544.  -CMA 2014.02.06.
sub ShowIndentedAcres { my ( $rProj ) = @_;
	my @c_IdtTags =
		(	"FirIntLw", "FirIntMd", "FirIntHg",
			"EroHazLw", "EroHazMd", "EroHazHh" );
		
	my @Vals;

	push( @Vals, BaerProj::PropByTag( $rProj, $_ ) ) for @c_IdtTags;

	_PrintIndentedAcres( $Vals[ 0 ], $Vals[ 1 ], $Vals[ 2 ], $Vals[ 3 ],
													$Vals[ 4 ], $Vals[ 5 ] );
}	# ShowProj::ShowIndentedAcres.  -CMA 2013.08.02.

###############################################################################
# SUB:  ShowProj::ShowProjectBlock.
# ACTION:  Prints our block-style BAER report summary.

# PARAMS:  $rProj is a BearProj "object" (ref).  $rShrinkPageState and
# $ResultNum are optional.
sub ShowProjectBlock { my ( $rProj, $rShrinkPageState, $ResultNum ) = @_;
	return unless $rProj;	# -CMA 2014.01.06.

	# The markup that will display the report's ordinal number (in the ordered
	# search results), if requested.
	my $NumDiv =
			$ResultNum ?
						"<div style='float:left'><b>$ResultNum.</b></div>" : "";

	# The markup that will display the link command to shrink this report, if
	# requested.
	my $ShrinkLink;

	if( $rShrinkPageState ) {
		my $ShrinkUrl = BwdQuery::GetRelinkUrl( $rShrinkPageState );	# -CMA 2013.08.16.

		$ShrinkLink = "<a href='$ShrinkUrl' style='float:right'>shrink</a>";
	}

	my $Title = BaerProj::Firename( $rProj );

	# 2nd arg = 1 inserts "NF".
	my $ForestRgn = _GetForestAndRegionStr( $rProj, 1 );

	my $Started = _FormattedFireStrt( $rProj );	# -CMA 2013.08.16.
	my $bMet    = TheBwdPageState::IsMetric();
	my $Area    = _FmtArea( BaerProj::TotAcres( $rProj ), $bMet );

	print( "
<div class='ProjectCell'>
  $NumDiv $ShrinkLink
  <div style='text-align:center'><b>$Title</b></div>
  <div style='text-align:center'><b>$ForestRgn</b></div>
  <br />
  <div style='float:left; width:50%'><b>Started:</b> $Started</div>
														<b>Area:</b> $Area<br />
  <br />
	" );

	ShowIndentedAcres( $rProj );	# Fire-intensity and erosion-hazard areas.

	# -CMA 2013.08.18.
	my $WtrRplnt = _FmtArea( BaerProj::PropByTag( $rProj, "WtrRplnt" ), $bMet );

	my $EroPotnt = BaerProj::PropByTag( $rProj, "EroPotnt" );

	# Using "%.1f" because 1 decimal place seems to be the greatest common
	# precision in the English database values for this field.  -CMA 2013.08.18.
	$EroPotnt = _FmtVal( $EroPotnt, "tons/ac", $bMet, "%.1f" );

	print( "
		<br />
		<b>Water-Repellent Soil:</b> $WtrRplnt<br />
		<b>Erosion Potential:</b> $EroPotnt<br />
		<br />
	" );

	_ShowValsAtRisk( $rProj );
    _ShowTreatments( $rProj );   # -CMA 2013.07.29.
    
	# -CMA 2014.01.13.
    print( "<b>Report Type:</b> " . BaerProj::RptTyp( $rProj ) . "<br />
			<b>Full report:</b> " . _GetReportFileLink( $rProj ) . "
	</div><br />\n" );	# -CMA 2013.08.16.
}	# ShowProj::ShowProjectBlock.  -CMA 2014.01.13.

###############################################################################
# SUB:  ShowProj::_AddTreatmentToTypeTotals.
sub _AddTreatmentToTypeTotals { my ( $rTmt, $rhTypesSummaries ) = @_;
	my $Type = Treatment::Type( $rTmt );

	# Combine untyped treatments with the "other" type.
	$Type = "other" unless $Type;

	# Get the totals array for this treatment's type.
	my $raCurTypeSums = $rhTypesSummaries->{ $Type };

	# If this treatment has a rogue type (not in our types table), then it can't
	# be tallied.  We shouldn't have any such data but let's not crash if we do.
	return unless defined( $raCurTypeSums );

	my $NFSCost   = Treatment::NFSCost( $rTmt );
	my $TotalCost = Treatment::NFSCost( $rTmt );

	# Avoid error log warnings.
	$NFSCost   = 0 unless $NFSCost;
	$TotalCost = 0 unless $TotalCost;

	# Accumulate this treatment's values into the totals for its type.
	$raCurTypeSums->[ 0 ] += $NFSCost;
	$raCurTypeSums->[ 1 ] += $TotalCost;

	# The rest of this loop body tallies the extra totals for acre treatment
	# types, so skip it if this treatment isn't of those types.
	return unless grep { $Type eq $_ } @_c_AcreUnitTmts;

	my $Units = Treatment::Units( $rTmt );

	# Even in the "mostly acre types", some treatments have other units.
	# For purposes of totaling acres, skip those treatments.
	return unless "ac" eq _CleanUnits( $Units );

	my $NumUnits = Treatment::NumUnits( $rTmt );

	# If the treatment's num-units field is missing, it's meaningless
	# to include it in a $/acre tally.
	return unless $NumUnits;

	my $UnitCost = Treatment::UnitCost( $rTmt );

	# If the treatment has a unit cost, then I prefer to use it to calculate
	# total cost for tallying $/acre, because it's inconsistent in the DB
	# whether "NFS cost" or "Total Cost" should match this.  But if there's no
	# unit cost, then I use the DB's total cost because sometimes the NFS costs
	# are missing.
	$raCurTypeSums->[ 2 ] +=
					$UnitCost ? $UnitCost * $NumUnits : $raCurTypeSums->[ 1 ];

	$raCurTypeSums->[ 3 ] += $NumUnits;
}	# ShowProj::_AddTreatmentToTypeTotals.  -CMA 2014.02.04.

###############################################################################
# SUB:  ShowProj::_CleanUnits.
sub _CleanUnits { my ( $RawUnits ) = @_;
	return "" unless $RawUnits;		# Allow eq w/o warning.

	my $CleanedUnits = $_c_TmtUnitsCleanup{ $RawUnits };

	# %_c_TmtUnitsCleanup doesn't have conversions for already-canonical units,
	# so $RawUnits might be clean already even if $CleanedUnits is null here.
	return $CleanedUnits ? $CleanedUnits : $RawUnits;
}	# ShowProj::_CleanUnits.  -CMA 2014.01.24.

###############################################################################
# SUB:  ShowProj::_DolOr.
sub _DolOr { my ( $Val, $UndefSub ) = @_;
	if( defined( $Val ) ) {
		return '$' . BwdUtils::commify( sprintf( "%.0f", $Val ) ); }
	else {
		return $UndefSub; }
}	# ShowProj::_DolOr.  -CMA 2014.01.16.

###############################################################################
# SUB:  ShowProj::_DolOrNa.
sub _DolOrNa { my ( $Val ) = @_;
	return _DolOr( $Val, "NA" );
}	# ShowProj::_DolOrNa.  -CMA 2013.08.01.

###############################################################################
# SUB:  ShowProj::_FmtArea.
sub _FmtArea { my ( $Acres, $bMetric ) = @_;
	# I don't have a policy for sig digits, so I'm just rounding ha to whole
	# number ("%.0f") for compact display.
	return _FmtVal( $Acres, "ac", $bMetric, "%.0f" );
}	# ShowProj::_FmtArea.  -CMA 2013.08.18.

###############################################################################
# SUB:  ShowProj::_FmtVal.
# NOTES:  Tested by Test140204_1544.  -CMA 2014.02.07.
sub _FmtVal { my ( $NativeVal, $NativeUnits, $bToMet, $ConvFmt ) = @_;
	return "NA" unless defined( $NativeVal );

	my $DispVal = $NativeVal;
	my $Units   = $NativeUnits;

	if( $bToMet ) {
		my $raUnitInfo = $_c_UnitsToMet{ $NativeUnits };

		$DispVal *= $raUnitInfo->[ 0 ];
		$Units = $raUnitInfo->[ 1 ];
	}

	return BwdUtils::commify( sprintf( $ConvFmt, $DispVal ) ) . " " . $Units;
}	# ShowProj::_FmtVal.  -CMA 2014.01.17.

###############################################################################
# SUB:  ShowProj::_FormattedFireStrt.
sub _FormattedFireStrt { my ( $rProj ) = @_;
	my $FireStrt = BaerProj::FireStrt( $rProj );

	# We have some missing FireStrt's in the DB, and substr() apparently crashes
	# on invalid args!
	return $FireStrt unless length( $FireStrt ) >= 7;

	my $Idx = substr( $FireStrt, 5, 2 ) - 1;

	my $Stupid = \@BwdQuery::c_Mos;		# Kill Perl only-once warning.
	substr( $FireStrt, 5, 2 ) = $BwdQuery::c_Mos[ $Idx ];
	return $FireStrt;
}	# ShowProj::_FormattedFireStrt.  -CMA 2013.08.16.

###############################################################################
# SUB:  ShowProj::_GetForestAndRegionStr.
# PARAMS:  $rProj is a BearProj "object" (ref).
sub _GetForestAndRegionStr { my ( $rProj, $bNf ) = @_;
	my $StoredForest = BaerProj::Forest( $rProj );

	# For a few projects, we know the region but not the forest, so we store
	# "REGIONX" as the forest (title-cased on import into our Perl code).
	my $bRegionOnly = ( $StoredForest =~ /^Region/ );
	my $ShowForest  = $bRegionOnly ? "[unknown]" : $StoredForest;
	my $State       = BaerProj::State( $rProj );
	my $Region      = BwdQuery::GetRegion( $StoredForest );
	my $Nf          = $bNf ? "NF " : "";	# -CMA 2014.01.13.

	return "$ShowForest $Nf ($State, rgn $Region)";
}	# ShowProj::_GetForestAndRegionStr.  -CMA 2013.11.12.

###############################################################################
# SUB:  ShowProj::_GetIndNumSpans.
# NOTES:  Gets a series of spans indenting, labeling, and showing a number.
sub _GetIndNumSpans { my ( $Label, $Val ) = @_;
	return "\n<span class='SpanIndent'></span><span class='SpanLabel'><b
						>$Label:</b></span><span class='SpanNum'>$Val</span>";
}	# ShowProj::_GetIndNumSpans.  -CMA 2013.06.25.

###############################################################################
# SUB:  ShowProj::_GetProjectFilename.
sub _GetProjectFilename { my ( $rProj ) = @_;
	my $FireName = BaerProj::Firename( $rProj );
	my $Forest   = BaerProj::Forest( $rProj );

    # The file's name, if we have it.
    my $FileName = "2500-8_" . $FireName . "_" . $Forest . ".pdf";

	# CMA added the 'g' all-occurrences modifier to all these regexes
	# 2013.11.27.  We got away without it because our data happens to only have
	# <= one of these in any filename, but it wasn't correct.

	# A few firenames contain /, which doesn't work in a filename, so our policy
	# is that in these filenames, / must be replaced with a space.  I tried
	# replacing / with %2F, the URL escape for /, but that didn't work because
	# IE apparently translates the %2F back to / when it requests the URL.
	# -CMA 2013.08.20.
	$FileName =~ s{/}{ }g;

	# A few firenames contain the Unicode apostrophe (U+2019).  I think it will
	# be too hard for our data workers to create the proper filename on our
	# Linux Web server to match this, so our policy is that the filename must
	# use ' (the ASCII single quote) in place of U+2019.  -CMA 2013.09.18.
	$FileName =~ s{\x{2019}}{'}g;

	# A few (or just one?) firenames contain ?, which does not work in a
	# filename (Windows Save As dialogs can't save such a file).  So, our policy
	# is that ?'s must be deleted.  -CMA 2013.10.28.
	$FileName =~ s{\?}{}g;

	return $FileName;
}	# ShowProj::_GetProjectFilename.  -CMA 2014.01.06.

###############################################################################
# SUB:  ShowProj::_GetReportFileLink.
sub _GetReportFileLink { my( $rProj ) = @_;
	my $FileName = _GetProjectFilename( $rProj );

    # If the file exists, then show a link to it; otherwise show "NA".
    unless( -e( $TheProjs::DataPath . "2500-8/$FileName" ) ) {
        return "NA"; }

	my $EscFileName = $FileName;

	# >= 1 of our firenames contains #, which must be URL-escaped to work in
	# an href.  -CMA 2013.09.05.
	$EscFileName =~ s{#}{%23}g;

	# Note *double-quotes* around href attrib value.  This is because
	# filenames occasionally contain ' which would cause the attrib value to
	# terminate if it was single-quoted.  -CMA 2013.08.20.
	return "<a href=\"/BAERTOOLS/baer-db/2500-8/$EscFileName\"
												target='_blank'>$FileName</a>";
}	# ShowProj::_GetReportFileLink.  -CMA 2014.01.13.

###############################################################################
# SUB:  ShowProj::_PrintIndentedAcres.
sub _PrintIndentedAcres { my( $FirIntLw, $FirIntMd, $FirIntHg, $EroHazLw,
													$EroHazMd, $EroHazHh ) = @_;
	my @c_IdtLabels = ( "Low", "Moderate", "High", "Low", "Moderate", "High" );

	my @Vals =
			( $FirIntLw, $FirIntMd, $FirIntHg, $EroHazLw,
														$EroHazMd, $EroHazHh );

	my $bMet = TheBwdPageState::IsMetric();
	my @IdtLines;
	
	for( 0 .. $#c_IdtLabels ) {
		my $ValStr = _FmtArea( $Vals[ $_ ], $bMet );		# -CMA 2013.08.18.
		
		push( @IdtLines, _GetIndNumSpans( $c_IdtLabels[ $_ ], $ValStr ) );
	}

	print( "
		<div style='float:left; width:50%'>
			<b>Burn Severity Areas</b><br />\n", 
			$IdtLines[ 0 ], "<br />\n", 
			$IdtLines[ 1 ], "<br />\n",
			$IdtLines[ 2 ], 
		"</div>
		<div>
			<b>Erosion Hazard Areas</b><br />\n", 
			$IdtLines[ 3 ], "<br />\n", 
			$IdtLines[ 4 ], "<br />\n", 
			$IdtLines[ 5 ], 
		"</div>
	" );
}	# ShowProj::_PrintIndentedAcres.  -CMA 2013.08.02.

###############################################################################
# SUB:  ShowProj::_PrintProjects.
sub _PrintProjects { my ( $raProjs, $Start, $End ) = @_;

	# Create the relink URLs so the user can sort by clicking on our line-mode
	# column headers.  -CMA 2014.01.13.

	my $rSortPageState = TheBwdPageState::GetCopy();

	BwdPageState::SetSortType( $rSortPageState, "name" );

	my $NameSortUrl = BwdQuery::GetRelinkUrl( $rSortPageState );

	BwdPageState::SetSortType( $rSortPageState, "forest" );

	my $ForestSortUrl = BwdQuery::GetRelinkUrl( $rSortPageState );

	BwdPageState::SetSortType( $rSortPageState, "" );

	my $DateSortUrl = BwdQuery::GetRelinkUrl( $rSortPageState );

	BwdPageState::SetSortType( $rSortPageState, "area" );

	my $AreaSortUrl = BwdQuery::GetRelinkUrl( $rSortPageState );
	my $rPageState  = TheBwdPageState::GetC();
	my $bMetric     = BwdPageState::IsMetric( $rPageState );
	my $rIt = BwdPageState::NewExpandedRangeItr( $rPageState, $Start, $End );

	# Run through the alternating "shrunk" and "expanded" subranges in the range
	# of projects we're showing, and present each range appropriately.
	for( ; OnRangeItr::IsValid( $rIt ); OnRangeItr::Advance( $rIt ) ) {
		my $bExpanded = OnRangeItr::IsOn( $rIt );

		# A shrunk range is printed as a table, one row per project, with this
		# table header.  Tested by Test140201_1128.  -CMA 2014.02.01.
		unless( $bExpanded ) {
			print( "
<table style='width:100%; border:1px solid black'>
	<tr style='background-color:#fbf8bb'>
		<th>#</th>
		<th><a href='$NameSortUrl'   class='SortHeader'>Fire</a></th>
		<th><a href='$ForestSortUrl' class='SortHeader'>Forest</a></th>
		<th><a href='$DateSortUrl'   class='SortHeader'>Started</a></th>
		<th><a href='$AreaSortUrl'   class='SortHeader'>Area</a></th>
		<th>Expand</th>
	</tr>\n" );
		}
	
		# Print each project in the current range.
		for( OnRangeItr::Start( $rIt ) - 1 .. OnRangeItr::End( $rIt ) - 1 ) {
			# In either display mode, we print a relink command to toggle the
			# current project's display size.  Here we set up $rResizePageState
			# to generate that relink for either case.
			my $rResizePageState = TheBwdPageState::GetCopy();
			my $Offset           = $_ - $Start + 1;

			BwdPageState::SetOffsetSize(
									$rResizePageState, $Offset, !$bExpanded );

			if( $bExpanded ) {	# Show the project as a block...
				ShowProjectBlock(
								$raProjs->[ $_ ], $rResizePageState, $_ + 1 ); }
			else {	# ... or as a single row.
				my $rProj    = $raProjs->[ $_ ];
				my $TotAcres = BaerProj::TotAcres( $rProj );

				# Tested by Test140207_1501.  -CMA 2014.02.07.
				my $TotArea = _FmtArea( $TotAcres, $bMetric );

				my $ExpandLink =
							BwdQuery::GetRelink( $rResizePageState, "expand" );

				print( "
<tr class='Sep' style='background-color:#ffffff'>
  <td class='LeftCell'>" . ( $_ + 1 )                       . "</td>
  <td>"                  . BaerProj::Firename( $rProj )     . "</td>
  <td>"                  . _GetForestAndRegionStr( $rProj ) . "</td>
  <td>"                  . _FormattedFireStrt( $rProj )     . "</td>
  <td class='NumCell'>$TotArea</td>
  <td>$ExpandLink</td>
</tr>
				" );
			}
		}
	
		# Close the table element iff we opened it above.
		print( "</table><br />\n" ) unless $bExpanded;
	}
}	# ShowProj::_PrintProjects.  -CMA 2013.08.14.

###############################################################################
# SUB:  ShowProj::_PrintTotalsOverProjects.
# ACTION:  Prints values totaled from the set of given projects.
sub _PrintTotalsOverProjects { my( $raProjs ) = @_;
	my $bMet     = TheBwdPageState::IsMetric();
	my $TotAcres = BwdUtils::Total_fn( $raProjs, \&BaerProj::TotAcres );

	# ProjectCell class gives the totals report a border like the individual
	# project blocks.
	print( "<br />
	<div class='ProjectCell'>
		<div style='text-align:center'><b>Totals for All Requested Reports</b>
						&nbsp;" . BwdQuery::GetTotalsRelink() . "</div><br />
		<b>Area:</b> " . _FmtArea( $TotAcres, $bMet ) . "<br /><br />
	" );

	# Print the fire-intensity and erosion-hazard areas.

	my $FirIntLw = BwdUtils::Total_fn( $raProjs, \&BaerProj::FirIntLw );
	my $FirIntMd = BwdUtils::Total_fn( $raProjs, \&BaerProj::FirIntMd );
	my $FirIntHg = BwdUtils::Total_fn( $raProjs, \&BaerProj::FirIntHg );
	my $EroHazLw = BwdUtils::Total_fn( $raProjs, \&BaerProj::EroHazLw );
	my $EroHazMd = BwdUtils::Total_fn( $raProjs, \&BaerProj::EroHazMd );
	my $EroHazHh = BwdUtils::Total_fn( $raProjs, \&BaerProj::EroHazHh );

	_PrintIndentedAcres( $FirIntLw, $FirIntMd, $FirIntHg, $EroHazLw,
														$EroHazMd, $EroHazHh );

	# Total up the water-repellent area.

	my $fnWtrRplnt = sub { BaerProj::PropByTag( $_, "WtrRplnt" ) };
	my $WtrRplnt   = BwdUtils::Total_fn( $raProjs, $fnWtrRplnt );

	$WtrRplnt = _FmtArea( $WtrRplnt, $bMet );	# -CMA 2013.08.19.

	# Total up treatment costs.

	my $NFSCost = BwdUtils::Total_fn( $raProjs, \&BaerProj::NFSCost );

	$NFSCost = _DolOrNa( $NFSCost );

	my $TotalCost = BwdUtils::Total_fn( $raProjs, \&BaerProj::TotalCost );

	$TotalCost = _DolOrNa( $TotalCost );

	print( "<br />
		<b>Water-Repellent Soil:</b> $WtrRplnt<br />
		<b>Treatments, requested by National Forests:</b> $NFSCost<br />
		<b>Treatments, requested by all entities:</b> $TotalCost<br />
		<br />
	" );

	_PrintTreatmentTypeTotals( $raProjs );	# -CMA 2014.01.16.
	print( "</div>\n<br />\n" );
}	# ShowProj::_PrintTotalsOverProjects.  -CMA 2013.08.02.

###############################################################################
# SUB:  ShowProj::_PrintTreatmentCategoryTypeTotals.

# ACTION:  Prints the table rows for the treatment type summaries for one
# major treatment category.

# PARAMS:
#	$raCatTmtTypes:  The (unsorted) array (ref) of the treatment types (names)
# 		in this category.
#	$rhTmtTypesSummaries:  The hash (ref) of the summary data.  Each key is a
#		treatment type (name), and each key's value is an array (ref) of that
#		type's summary data.
sub _PrintTreatmentCategoryTypeTotals { my(
			$CatTitle, $raCatTmtTypes, $rhTmtTypesSummaries, $bMetric ) = @_;
	# We'll accumulate the NFS and all-source whole-category totals in these.
	my $CatNfsTotal    = 0;
	my $CatAllSrcTotal = 0;

	# Accumulate $CatNfsTotal & $CatAllSrcTotal.
	for( @$raCatTmtTypes ) {
		my @CurTypeSums = @{ $rhTmtTypesSummaries->{ $_ } };

		$CatNfsTotal    += $CurTypeSums[ 0 ];
		$CatAllSrcTotal += $CurTypeSums[ 1 ];
	}

	# Print the category header row.
	print( "<tr><td><b>$CatTitle</b></td><td class='NumCell'><b>" .
			_DolOr( $CatNfsTotal, 0 ) . "</b></td><td class='NumCell'><b>" . 
			_DolOr( $CatAllSrcTotal, 0 ) . "</b></td><td></td></tr>\n" );

	# Print the row for each treatment type.
	for my $TmtType ( BwdUtils::SortAlpha( $raCatTmtTypes ) ) {
		my @CurTypeSums = @{ $rhTmtTypesSummaries->{ $TmtType } };
		my $NfsTotal    = _DolOr( $CurTypeSums[ 0 ], 0 );
		my $AllSrcTotal = _DolOr( $CurTypeSums[ 1 ], 0 );
		my $CostPerAcre = "";

		# We only set $CurTypeSums[ 2 ] (total cost, for per-acre purposes) and
		# $CurTypeSums[ 3 ] (total acres) for certain treatment types.
		if( $CurTypeSums[ 3 ] ) {
			$CostPerAcre = $CurTypeSums[ 2 ] / $CurTypeSums[ 3 ];
			$CostPerAcre = _FmtVal( $CostPerAcre, '$/ac', $bMetric, "%.0f" );
		}

		print( "
  <tr class='Sep'>
    <td class='LeftCell'>$TmtType</td>
    <td class='NumCell'>" . $NfsTotal    . "</td>
    <td class='NumCell'>" . $AllSrcTotal . "</td>
    <td class='NumCell RightCell'>" . $CostPerAcre . "</td>
  </tr>
		" );
	}
}	# ShowProj::_PrintTreatmentCategoryTypeTotals.  -CMA 2014.01.21.

###############################################################################
# SUB:  ShowProj::_PrintTreatmentRow.
sub _PrintTreatmentRow { my( $rTmt ) = @_;
	my $UnitsRaw = Treatment::Units( $rTmt );

	# Set this to point to our metric conversion info if we're requested to,
	# and able to, convert this treatment's units; otherwise it stays null.
	my $raMetInfo;

	if( TheBwdPageState::IsMetric() ) {
		# Convert the various odd unit names in the DB to our canonical
		# form, if we can.  -CMA 2014.01.24.
		my $CleanedUnits = _CleanUnits( $UnitsRaw );

		# If we have a metric conversion for this units, grab it.
		$raMetInfo = $_c_UnitsToMet{ $CleanedUnits };
	}

	# We'll display this unit cost.
	my $UnitCost = Treatment::UnitCost( $rTmt );

	if( defined( $UnitCost ) ) {
		# Convert to metric if we should & can.
		if( $raMetInfo ) {
			$UnitCost = sprintf( "%.0f", $UnitCost / $raMetInfo->[ 0 ] ); }

		# Format.
		$UnitCost = '$' . BwdUtils::commify( $UnitCost );
	}
	else {
		$UnitCost = "NA"; }		# Some DB treatments are missing unit cost.
	
	# The units we'll display:  metric if we should & can, or NA if missing.
	my $Units = $raMetInfo ? $raMetInfo->[ 1 ] : _ValStrOrNa( $UnitsRaw );

	# The number-of-units we'll display.
	my $NumUnits = Treatment::NumUnits( $rTmt );
	
	if( defined( $NumUnits ) ) {
		# Convert to metric if we should & can.
		if( $raMetInfo ) {
			$NumUnits = sprintf( "%.1f", $NumUnits * $raMetInfo->[ 0 ] ); }

		# Format.
		$NumUnits = BwdUtils::commify( $NumUnits );
	}
	else {
		$NumUnits = "NA"; }		# Some DB treatments are missing # of units.
	
	my $NFSCost = _DolOrNa( Treatment::NFSCost( $rTmt ) );
	my $TotCost = _DolOrNa( Treatment::TotalCost( $rTmt ) );
	
	print( "<tr class='Sep'>
				<td class='LeftCell'>", Treatment::Descr( $rTmt ), "</td>
				<td class='NumCell'>$UnitCost</td>
				<td>$Units</td>
				<td class='NumCell'>$NumUnits</td>
				<td class='NumCell'>$NFSCost</td>
				<td class='NumCell RightCell'>$TotCost</td>
			</tr>\n" );
}	# ShowProj::_PrintTreatmentRow.  -CMA 2014.02.03.

###############################################################################
# SUB:  ShowProj::_PrintTreatmentsHeader.
sub _PrintTreatmentsHeader {
	# Note, no line breaks in HTML code for title attribute content; IE
	# renders the tabs!
	print( "
<tr>
  <th style='width:15em'>Treatment</th>
  <th style='width:6em' title='Cost per unit'>\$/Unit</th>

  <th style='width:6em'
					title='Unit of measure for \$/Unit and # of Units'>Unit</th>

  <th style='width:6em' title='Number of units'># of Units</th>

  <th style='width:5em'
		title='Money requested for this treatment by the National Forest System'
		>NF \$ Requested</th>

  <th style='width:5em'
		title='Money requested for this treatment by all sources (NFS and others)'
		>Total \$ Requested</th>
</tr>
	" );
}	# ShowProj::_PrintTreatmentsHeader.  -CMA 2013.08.18.

###############################################################################
# SUB:  ShowProj::_PrintTreatmentTypeTotals.

# ACTION:  Prints a table of per-treatment-type summary information (totals, and
# aggregate unit cost for selected treatment types) for the given projects.
sub _PrintTreatmentTypeTotals { my( $raProjs ) = @_;
	# Collect the summary information.  Each key in %TmtTypesSummaries is a
	# treatment type, and each key's value is an array (ref) of the 2 or 4
	# summary values for that treatment type.
	my %TmtTypesSummaries = _TallyTreatmentTypeTotals( $raProjs );

	print( "
<table style='border:1px solid black'>
  <tr><th>Treatment Type</th><th>NF \$ Requested</th><th>All \$ Requested</th>
														<th>Unit Cost</th></tr>
	" );

	# Each of these 4 arrays (refs) will hold the treatment types that belong in
	# one of our 4 major treatment "categories": land, channel, roads/trails, &
	# protection.  I use these 4 categories because they're the 4 categories in
	# a BAER report's costs table for which we actually have any treatment
	# types.  There are some additional categories in the BAER reports, but our
	# DB doesn't use them.
	my @TmtCats = ( [], [], [], [] );

	# This array maps the "category number" that we've assigned to each
	# treatment type in our DB (the index into this array), to an index into
	# @TmtCats above (the value in this array).  A -1 value in this array means
	# there is no display category for that DB category number.  The DB
	# categories are 1-based; there is no DB category 0, so I set
	# $c_DbCatToIdx[ 0 ] = -1 here just to make the array lookup simple.  DB
	# categories 3 (roads) & 4 (trails) both map to $TmtCats[ 2 ] (roads &
	# trails).  DB category 5 is "other" which has no corresponding BAER
	# category, and DB category 6 is the protection category.
	my @c_DbCatToIdx = ( -1, 0, 1, 2, 2, -1, 3 );

	# Fill @TmtCats, using the XML version of our DB treatment-types table,
	# which we've already loaded.
	for( @$raTmtTypesRowsXml ) {
		my $DbCatNum = $_->{category};

		# I don't think our DB has any category #'s outside 1-6, but let's not
		# crash if they create one someday.
		next unless $DbCatNum >= 1 && $DbCatNum <= 6;

		# Map the DB category to our @TmtCats index.
		my $CatIdx = $c_DbCatToIdx[ $DbCatNum ];

		# Add this treatment type (name) to the collection for its category in
		# @TmtCats, except for the treatment type "other".
		push( @{ $TmtCats[ $CatIdx ] }, $_->{treatment} ) if $CatIdx >= 0;
	}

	# These are the same category titles as in the BAER reports' costs tables.
	my @c_CatTitles =
			( "Land Treatments", "Channel Treatments", "Road and Trails",
														"Protection/Safety" );

	# Note that the # of td's in each row must match the header row in order to
	# get proper borders, and the &nbsp; (i.e., some content in some cell) is
	# required in order to make the blank row occupy vertical space.
	my $c_BlankRow =
			"<tr class='Sep'><td>&nbsp;</td><td></td><td></td><td></td></tr>";

	my $bMet = TheBwdPageState::IsMetric();

	# Print the summary rows in each treatment category.
	for my $CatIdx ( 0..3 ) {
		# Insert a blank row between each category, but not above the 1st 
		# category.
		print( "$c_BlankRow\n" ) if $CatIdx > 0;

		_PrintTreatmentCategoryTypeTotals( $c_CatTitles[ $CatIdx ],
							$TmtCats[ $CatIdx ], \%TmtTypesSummaries, $bMet );

# CMA replaced 2014.01.21.
=pod
		my $CatNfsTotal = 0;
		my $CatAllSrcTotal = 0;

		print( "<tr><td><b>" . $c_CatTitles[ $CatIdx ] .
								"</b></td><td></td><td></td><td></td></tr>\n" );

		for my $TmtType ( BwdUtils::SortAlpha( $TmtCats[ $CatIdx ] ) ) {
			my @CurTypeSums = @{ $TmtTypesSummaries{ $TmtType } };
			my $NfsTotal = _DolOr( $CurTypeSums[ 0 ], 0 );
			my $AllSrcTotal = _DolOr( $CurTypeSums[ 1 ], 0 );
			my $CostPerAcre;

			if( $CurTypeSums[ 2 ] ) {
				$CostPerAcre = $CurTypeSums[ 2 ] / $CurTypeSums[ 3 ];
				$CostPerAcre = _FmtVal( $CostPerAcre, '$/ac', $bMet, "%.0f" );
			}

			print( "
  <tr/>
    <td>$TmtType</td>
    <td class='NumCell'>" . $NfsTotal    . "</td>
    <td class='NumCell'>" . $AllSrcTotal . "</td>
    <td class='NumCell'>" . $CostPerAcre . "</td>
  </tr>
			" );
		}
=cut

	}

	# After the real categories, print an "Uncategorized" row.

	my $OtherNfsTotal = _DolOr( $TmtTypesSummaries{other}->[ 0 ], 0 );
	my $OtherAllSrcTotal = _DolOr( $TmtTypesSummaries{other}->[ 1 ], 0 );

	print( "
 $c_BlankRow
  <tr><td><b>Uncategorized</b></td><td class='NumCell'>" . $OtherNfsTotal .
		"</td><td class='NumCell'>" . $OtherAllSrcTotal . "</td><td></td></tr>
</table>
	" );
}	# ShowProj::_PrintTreatmentTypeTotals.  -CMA 2014.01.16.

###############################################################################
# SUB:  ShowProj::_ShowTreatments.
# ACTION:  Prints the treatments table for one project.
# PARAMS:  $rProj is a BearProj "object" (ref).
sub _ShowTreatments { my ( $rProj ) = @_;
	print( "<table style='border:1px solid black'>\n" );
	_PrintTreatmentsHeader();	# -CMA 2013.08.18.

	my $bMet = TheBwdPageState::IsMetric();
	my @Tmts = BaerProj::Treatments( $rProj );

	# Sort by treatment, then units.  Since Perl sort is stable, we can achieve
	# this by reverse-sequential sorts.

	my $fnCmpUnits = sub {
		my $UnitsA = Treatment::Units( $a );
		my $UnitsB = Treatment::Units( $b );

		# Don't uc( null ); Perl generates warnings.  -CMA 2014.02.03.
		$UnitsA = "" unless length( $UnitsA );
		$UnitsB = "" unless length( $UnitsB );
		return uc( $UnitsA ) cmp uc( $UnitsB )
	};

	@Tmts = sort $fnCmpUnits @Tmts;

	my $fnCmpDescr =
			sub { uc( Treatment::Descr( $a ) ) cmp
												uc( Treatment::Descr( $b ) ) };

	@Tmts = sort $fnCmpDescr @Tmts;

	# Print a table row for each treatment.
	for( @Tmts ) {
		_PrintTreatmentRow( $_ ); }

	# If this project has no treatments, then print a no-results placeholder.
	unless( @Tmts ) {
		print( "<tr><td colspan='10'>No treatments reported.</td></tr>" ); }

	print( "</table><br />\n" );
}   # ShowProj::_ShowTreatments.  -CMA 2013.07.08.

###############################################################################
# SUB:  ShowProj::_ShowValsAtRisk.
# PARAMS:  $rProj is a BearProj "object" (ref).
sub _ShowValsAtRisk { my( $rProj ) = @_;
	print( "
		<div style='text-align:center'><b>Values at Risk</b></div>
		<br />
	" );

	my @VarTags =
			( "LifeThrtDescr", "PropThrtDescr", "WtrQualThrtDescr",
									"T_x0026_ESpcDescr", "SoilProdThrtDescr" );

	my @VarLabels = ( "Life", "Property", "Water", "Species", "Soil" );

	my $bVarFound = 0;   # We set this = 1 if there are any VAR descriptions.

    # For each VAR category, show its description if any.
	for my $Idx ( 0 .. $#VarTags ) {
		my $Descr = BaerProj::PropByTag( $rProj, $VarTags[ $Idx ] );
		
		# If there's a description, then $Descr should be a string; otherwise
        # it's null.  No description means no VAR noted in this category.
		# Tested by Test140204_1457.  -CMA 2014.02.04.
        next if ( ref( $Descr ) || !$Descr );
		
		$bVarFound = 1;

		my $Label = $VarLabels[ $Idx ];

		# VAR descriptions in the DB occasionally contain HTML entities, e.g.
		# <S> (which caused the rest of the page to strikethrough), so we
		# definitely need to escape them.  -CMA 2013.08.19.
		$Descr = HTML::Entities::encode( $Descr );

		print( "<b>$Label:</b> $Descr<br /><br />" );
	}

	# Show a placeholder if there are no VARs.
	print( "No values at risk noted.<br /><br />" ) unless $bVarFound;
}	# ShowProj::_ShowValsAtRisk.  -CMA 2013.06.25.

###############################################################################
# SUB:  ShowProj::_TallyTreatmentTypeTotals.

# RETURN:  A hash.  Each key is a treatment type.  Each value is a ref to an
# array of totals for that treatment type.  Array[ 0 ] == the total NFSCost,
# array[ 1 ] == total TotalCost.  For treatment types whose predominant unit is
# acres, we also set array[ 2 ] = total cost calculated from per-acre cost
# (where available), and array[ 3 ] = # of acres.
sub _TallyTreatmentTypeTotals { my( $raProjs ) = @_;
	# These are the treatment types whose treatments almost all use the acre
	# unit, as chosen by me looking through our DB data.
	my @c_AcreUnitTmts =
		(	"contour felling",
			"hydromulch,aerial",
			"mulching",
			"seeding - aerial",
			"seeding - ground",
			"seeding and fertilizer",
			"soil scarification",
			"straw mulch, aerial",
			"straw mulch, ground",
			"wood shreds",
			"woodstraw" );

	my %TmtTypesSummaries;	# The hash we'll return.

	# Initialize all the hash's keys that we'll support (treatment types from
	# our treatment-types table) with empty array-ref values, so the arrays are
	# there to write to the 1st time we need them below.
	for( @$raTmtTypesRowsXml ) {
		$TmtTypesSummaries{ $_->{treatment} } = [ 0, 0, 0, 0 ]; }

	# For each given project, add its values to our totals.
	for my $rProj ( @$raProjs ) {
		# For each treatment in the project, add its values.
		for my $rTmt ( BaerProj::Treatments( $rProj ) ) {
			# -CMA 2014.02.04.
			_AddTreatmentToTypeTotals( $rTmt, \%TmtTypesSummaries );

# CMA replaced 2014.02.04.
=pod
			my $Type = Treatment::Type( $rTmt );

			# Combine untyped treatments with the "other" type.
			$Type = "other" unless $Type;

			# Get the totals array for this treatment's type.
			my $raCurTypeSums = $TmtTypesSummaries{ $Type };

			# If this treatment has a rogue type (not in our types table), then
			# it can't be tallied.  We shouldn't have any such data but let's
			# not crash if we do.
			next unless defined( $raCurTypeSums );

			# Accumulate this treatment's values into the totals for its type.
			$raCurTypeSums->[ 0 ] += Treatment::NFSCost( $rTmt );
			$raCurTypeSums->[ 1 ] += Treatment::TotalCost( $rTmt );

			# The rest of this loop body tallies the extra totals for acre
			# treatment types, so skip it if this treatment isn't of those
			# types.
			next unless grep { $Type eq $_ } @c_AcreUnitTmts;

			my $Units = Treatment::Units( $rTmt );

			# Even in the "mostly acre types", some treatments have other units.
			# For purposes of totaling acres, skip those treatments.
			next unless "ac" eq _CleanUnits( $Units );

	        my $NumUnits = Treatment::NumUnits( $rTmt );

			# If the treatment's num-units field is missing, it's meaningless
			# to include it in a $/acre tally.
			next unless $NumUnits;

	        my $UnitCost = Treatment::UnitCost( $rTmt );

			# If the treatment has a unit cost, then I prefer to use it to
			# calculate total cost for tallying $/acre, because it's
			# inconsistent in the DB whether "NFS cost" or "Total Cost" should
			# match this.  But if there's no unit cost, then I use the DB's
			# total cost because sometimes the NFS costs are missing.
			$raCurTypeSums->[ 2 ] +=
					$UnitCost ? $UnitCost * $NumUnits : $raCurTypeSums->[ 1 ];

			$raCurTypeSums->[ 3 ] += $NumUnits;
=cut

		} }

	return %TmtTypesSummaries;
}	# ShowProj::_TallyTreatmentTypeTotals.  -CMA 2014.01.17.

###############################################################################
# SUB:  ShowProj::_ValStrOrNa.
sub _ValStrOrNa { my( $Val, $Units ) = @_;
	return "NA" unless defined( $Val );

	my $ValStr = BwdUtils::commify( $Val );

	return $Units ? $ValStr . " " . $Units : $ValStr;
}	# ShowProj::_ValStrOrNa.  -CMA 2013.08.02.

}	# End package ShowProj.


# Standard "main script stub" for library file.  -CMA 2014.01.13.
1;

################################# END OF FILE #################################
