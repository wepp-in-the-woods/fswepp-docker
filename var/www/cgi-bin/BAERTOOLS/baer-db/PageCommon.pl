# PageCommon.pl
# Secondary "library" file containing common code used by our Web pages.
# By Conrad Albrecht (CMA) 2013.11.15.

use strict;
use warnings;

################################# "#INCLUDES" ##################################
# No #includes yet.

###############################################################################
###############################################################################
# PACKAGE:  BwdPages.  -CMA 2013.11.15.

# Package for services provided by this file which don't go in any other
# particular package.
{	package BwdPages;

###############################################################################
# SUB:  BwdPages::PrintBanners.

# PARAMS:  $raExtraCrumb (optional) is a 2-element array containing (0) the
# extra breadcrumb's text and (1) its URL.
sub PrintBanners { my( $Title, $raExtraCrumb ) = @_;
	my $ExtraCrumb = "";

	if( $raExtraCrumb ) {
		$ExtraCrumb = " &nbsp;&gt;&nbsp;
				<a href='" . $raExtraCrumb->[ 1 ] . "' style='color:white'>" .
												$raExtraCrumb->[ 0 ] . "</a>";
	}

	# I copied much of this page-framing content from
	# <DATA_ROOT>/BAERTOOLS/index.html and the stylesheets it uses.
	
	print( "
	<!-- Generic Forest Service banner. -->
	<div>
		<a href='http://www.fs.fed.us'>
			<img src='/local_resources/images/logos/usda-fs-text.gif'
					width='143' height='29' border='0'
					alt='USDA Forest Service' />
		</a>
	</div>

	<!-- Page title banner. -->
	<div style='background-color:#788a51; padding-top:10px; padding-left:10px;
																color:white'>
		<img src='/local_resources/images/rmrs/rmrs_index_top.gif' width='75'
													height='40' align='right' />
	
		<!-- Navigation breadcrumbs. -->
		<a href='/' style='color:white'>MFSL Home</a> &nbsp;&gt;&nbsp;
		<a href='/BAERTOOLS/' style='color:white'>BAER Tools</a>
		$ExtraCrumb
		<!-- Page title. -->
		<h1 style='margin:0.5em 0 0; font:bold 16px; text-align:center'>$Title
																		</h1>
		<br /><br />
	</div>
	" );
}	# BwdPages::PrintBanners.  -CMA 2013.11.15.

}	# End package BwdPages.

# Standard "main script stub" for library file.  -CMA 2013.11.15.
1;

################################# END OF FILE #################################
