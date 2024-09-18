#!/usr/bin/perl

# location.pl
# Map popup page for BAER DB, Moscow Forestry Sciences Laboratory. By Conrad
# Albrecht (CMA) 2013.11.21.

# This page displays a map.  When the user clicks in the map, we call our parent
# window's TakeDistOrigin() and then close this window.  -CMA 2013.11.25.

use strict;
use warnings;

################################# "#INCLUDES" ##################################

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
						"https://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">' );

print( "
<html>
<head>
  <!-- Required for any UTF-8 characters we might use. -->
  <meta http-equiv='Content-type' content='text/html;charset=UTF-8' />

  <title>Choose Location</title>

  <!-- Include Google Maps functions (google.map namespace). -->
  <script type='text/javascript'
					src='https://maps.googleapis.com/maps/api/js?sensor=false'>
  </script> 

<script type='text/javascript'>
	function OnLoad() {
		// I chose <center> and <zoom> to show the western US in a good popup
		// window size.  I set <draggableCursor> to the finger rather than the
		// default open hand because the main point of the map is to pick a
		// point, not to pan.
		var oOptions = {
				center:          new google.maps.LatLng( 40, -114 ),
				zoom:            4,
				mapTypeId:       google.maps.MapTypeId.ROADMAP, 
				draggableCursor: 'pointer' };

		// Show the Google Map in our <divMap> div.
		var divMap = document.getElementById( 'divMap' );
		var map    = new google.maps.Map( divMap, oOptions );

		// Register our callback for mouse clicks on the map.
		google.maps.event.addListener( map, 'click', OnMapClick );
	}

	// Params:  <event> is the Google Maps event for which we registered this
	// callback.
	function OnMapClick( event ) { 
		// Pass the clicked point on to our main window's (index.pl's) handler.
		// Note that we reverse the longitude, since TakeDistOrigin() expects
		// *west* lon.
		opener.TakeDistOrigin( event.latLng.lat(), -event.latLng.lng() );

		// Picking a point was all this location.pl window was opened for, so
		// now close it.
		close();
	}
</script>

</head>

<!-- Styles copied from our baer-db.css, but I don't want to use that file's
	styles as is. -->
<body style='font:12px Verdana,Arial,sans-serif; background-color:#fbf8e0'
														onload='OnLoad()'>
  Click in the map to pick a location:

  <!-- Our Javascript shows the Google Map in this div. The size is tuned to
		show the western US given the map params in OnLoad(). -->
  <div id='divMap' style='width:300px; height:300px' />
</body>
</html>\n" );

# End "Main" script.  -CMA 2013.11.21.

################################# END OF FILE #################################
