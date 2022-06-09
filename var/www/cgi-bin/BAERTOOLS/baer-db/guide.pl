#!/usr/bin/perl

# doc.pl
# Documentation page for BAER DB, Moscow Forestry Sciences Laboratory. By Conrad
# Albrecht (CMA) 2013.11.14.

use strict;
use warnings;

################################# "#INCLUDES" ##################################

require "PageCommon.pl";	# For BwdPages pkg.  -CMA 2013.11.15.

################################### "MAIN()" ###################################

	# Standard HTTP response preamble for any CGI script.
	print( "Content-type: text/html\n\n" );

	# Using DOCTYPE to avoid browsers' quirks mode. I don't know if I'll
	# actually need it on this page, but I needed it in index.pl, so it seems
	# more likely to help than hurt here too.
	#
	# This print() call is separate so as to use single-quotes around the
	# double-quotes.
	print( '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
						"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">' );

	my $c_BwdName = "BAER Burned Area Reports DB";

	# If I end up using any UTF-8-encoded characters on this page, I'll 
	# definitely need this charset=UTF-8 spec for the browser to show them
 	# correctly.
	print( "
	<html>
	<head>
		<meta http-equiv='Content-type' content='text/html;charset=UTF-8' />
		<title>RMRS - $c_BwdName Guide</title>

		<link rel='stylesheet'
						type='text/css' href='/BAERTOOLS/baer-db/baer-db.css'>
	</head>
	<body>
	" );

	BwdPages::PrintBanners( "$c_BwdName Guide", [ $c_BwdName, "index.pl" ] );

	print( "<div class='PageContentDiv' style='max-width:60em'>\n" );
	BwdLocGuidePl::PrintPageContent();
	print( "</div></body></html>\n" );

# End "Main" script.  -CMA 2013.11.14.

###############################################################################
###############################################################################
# PACKAGE:  BwdLocGuidePl.  -CMA 2013.11.15.

# Catch-all file-local package to avoid implicitly using main::, which caused
# nasty bugs.
{	package BwdLocGuidePl;

###############################################################################
# SUB:  BwdLocGuidePl::PrintPageContent.
sub PrintPageContent { 
	print <<'END_HERE_DOC_131115';

<b>BAER Burned Area Reports DB</b> is a database containing post-fire assessment
information from four decades of US Forest Service Burned Area Reports
(FS 2500-8 forms). We have compiled information from approximately 1500 reports
and other information when available, mostly from the western US, into the
database. New reports are added annually.<br />
<br />
The first Burned Area Reports on post-fire emergency watershed stabilization and
rehabilitation were prepared in the 1960's and early 1970's. In 1974 a formal
authority for post-fire rehabilitation activities was authorized to evaluate
burn severity and request funding for recommended post-fire treatments. In
1988-1989, Burned Area Emergency Response (BAER) policies and procedures were
incorporated in the Forest Service Manual and the BAER Handbook, which
standardized the assessments and reports filed.<br />
<br />
The Burned Area Reports, with their standard protocols and formats, provide
comparable information across most of the forest fires that have been assessed
within the BAER program. With the information compiled into a searchable
database, an active BAER team may, for example, examine past reports from the
region where they are working to learn about treatment costs or treatment
adaptations and implementation strategies that have worked well. It is hoped
that this database makes it easier to access past decisions to inform current
and future work.<br />

<h2 style='text-align:center'>Tips for Using BAER Burned Area Reports DB</h2>

<b>Selecting several locations or treatments:</b> In the "Location" list,
you may select more than one item at a time; e.g. you could select both the
Angeles and Los Padres National Forests. Then, when you "Get reports," results
from all of the selected locations will be returned mixed together.<br />
<br />
To select multiple items (in Windows), use "Ctrl+Click": First, select your
first item. Then, hold down your Ctrl key, and mouse-click the 2nd item, 3rd
item, etc. You may select multiple treatments in the "Treatment Types" list the
same way.<br />
<br />
<b>Selecting <i>all</i> locations or treatments:</b> If you don't select any
locations or treatments, then all will automatically be included, as if they had
all been selected. Or, you can explicitly select the [All] item. If you have
previously selected other items in the lists, and you no longer want those
items, then you may want to scroll through the lists to make sure the unwanted
items are no longer selected. If you select [All] along with other items in the
same list, then the [All] is ignored and only the results which match the other
item(s) you have selected are returned.<br />
<br />
<b>Treatment Types:</b> BAER Burned Area Reports DB contains records of many
individual post-fire response treatments, most of which have been classified
into one of the "types" in this list. When you select some of these types and
then click "Get reports," only reports which include a treatment from your
selected types are returned.<br />
<br />
However, some treatment records (e.g. "interagency coordination") have not yet
been assigned a type. Therefore, to include more listings that may fall into
your desired set, you can select the "other" type in addition to your specific
desired types. Selecting "other" will return all treatments whose type has not
been assigned.<br />
<br />
<b>From date [XXX] to [XXX]:</b> You may limit your selected reports to a
particular time period by filling in these boxes. The project date used for
this selection is the date the fire started. You may leave either or both of
the "from" and "to" date boxes blank. If you leave both boxes blank, then all
dates are included. If you fill only the "from" box, then you get newer results,
starting on your "from" date and including all more recent fires. If you fill
only the "to" box, then you get older results, ending on your "to" date and
including all older fires.<br />
<br />
You may enter your date(s) several ways, but you must always use a 4 digit entry
for the year. The standard format is yyyy&#8209;mm&#8209;dd (e.g. 2001-02-03
means February 3, 2001). You may use 3-letter month abbreviations instead of
month numbers (e.g. 2001-feb-03). You don't have to enter any day; you may enter
just the year (e.g. "2001") or just the year and month (e.g. "2001-02"). If you
enter just years or just years and months, you will get results through the
entire identified period (e.g. if you enter "from" as "2001", and you enter "to"
as "2002", then you will get results from the beginning of 2001 to the end of
2002).<br />
<br />
<b>Order by distance from:</b> When you select "Distance from" in the "Order by"
list, then text boxes appear which let you specify a latitude N and longitude W
(in decimal degrees). Then when you "Get reports," fires closest to that
location will be returned first.<br />
<br />
<b>pick from map:</b> This command appears next to the latitude and longitude
text boxes when those are displayed. It lets you use a map to fill in those text 
boxes. Clicking this command brings up a popup window which displays a Google
Map. Click on your desired point in the map, and the map window closes, and your
chosen point's coordinates are entered into the text boxes. Note: After doing
this, you must still click the "Get reports" button to execute your search.
<br />
<br />
<b>Map view:</b> If you choose the "Map view" radio button instead of the
default "List view" button, then your reports are shown as markers on a map
instead of in a list. (The "Map view" button is a different item from the "pick
from map" command link discussed above.) The map is a Google Map which you can
pan and zoom like any Google Map. If you hover your mouse over a marker, the
name(s) of the fire(s) near that point appear. If you click on a marker, then
the report(s) for that marker are displayed below the map.<br />
<br />
A warning about map view:  The accuracy of the marker locations varies. For many
reports, the locations come from government databases and are believed accurate
within the ability of a single point to represent a large burned area. For other
(mostly older) reports, however, the only location information available was in
the reports themselves, and we have inferred approximate locations from mentions
of watersheds or other geographic features. Therefore, in some cases the marker
may be up to dozens of miles away from the actual fire. We believed it was
preferable to include these estimated locations so that these reports can still
be found on the map, even if in not quite the correct location.  However, for a
few reports, we lacked even this approximate location information, and those
reports do not appear on the map.<br />
<br />
<b>show totals:</b> This command is just above your search results. It
displays a box above the search results, showing certain values totaled from all
of your selected reports, such as acreages and proposed treatment costs.<br />
<br />
These totals must be interpreted carefully. Actual spending may be different due
to changes in contracts, weather delays, area actually treated, etc. As a
result, you cannot assume that the requested total shown is the amount that was
actually spent.<br />
<br />
<b>expand/shrink all:</b> These commands are just above your search results. By
default, your results appear in a compact table with a single line for each
report. You can expand all of the reports into larger "details" boxes with
these commands. You can also expand a single report using the "expand" command
on a single line in the compact table.<br />
<br />
<b>metric/English units:</b> This command is just above your search results. You
can use it to display numeric values in your preferred unit system.<br />
<br />
<b>Full report:</b> At the bottom of the expanded report details box for
most reports, a link to the original Burned Area report (2500-8) file is
provided. Note: For many reports, several versions (initial, interim, and final)
exist. When multiple reports were available, the most complete report was chosen
to be linked here.<br />
<br />
<div style='text-align:right'>
	<a href='index.pl'>Back to BAER Burned Area Reports DB main page</a>
</div>

END_HERE_DOC_131115

}	# BwdLocGuidePl::PrintPageContent.  -CMA 2013.11.15.

}	# End package BwdLocGuidePl.

################################# END OF FILE #################################
