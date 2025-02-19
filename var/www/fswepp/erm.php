<?php 

echo "Content-Type: application/vnd.google-earth.kml+xml\n\n";
// echo "Content-Type: text/plain\n\n";

echo '<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="https://earth.google.com/kml/2.2">
<Document>
	<name>ERMiT climate locations</name>
	<visibility>0</visibility>
	<open>1</open>
	<Snippet maxLines="1">ERMiT</Snippet>
        <description>wa</description>
	<Style>
		<IconStyle>
			<Icon>
			</Icon>
		</IconStyle>
		<BalloonStyle>
			<text>$[description]</text>
			<textColor>ff000000</textColor>
			<displayMode>default</displayMode>
		</BalloonStyle>
	</Style>
	<StyleMap id="Sheet1Map10_copy0">
		<Pair>
			<key>normal</key>
			<styleUrl>#NormalSheet1Map10</styleUrl>
		</Pair>
		<Pair>
			<key>highlight</key>
			<styleUrl>#HighlightSheet1Map10</styleUrl>
		</Pair>
	</StyleMap>
	<Style id="HighlightSheet1Map10_copy0">
		<IconStyle>
			<scale>1.1</scale>
			<Icon>
				<href>https://maps.google.com/mapfiles/kml/pushpin/red-pushpin.png</href>
			</Icon>
		</IconStyle>
		<LabelStyle>
			<scale>0.5</scale>
		</LabelStyle>
		<BalloonStyle>
			<text>$[description]</text>
		</BalloonStyle>
		<LineStyle>
			<color>ffff00ff</color>
			<width>3</width>
		</LineStyle>
		<PolyStyle>
			<color>70ff00ff</color>
			<fill>0</fill>
		</PolyStyle>
	</Style>
	<Style id="NormalSheet1Map10_copy0">
		<IconStyle>
			<Icon>
				<href>https://maps.google.com/mapfiles/kml/pushpin/ylw-pushpin.png</href>
			</Icon>
		</IconStyle>
		<BalloonStyle>
			<text>$[description]</text>
		</BalloonStyle>
		<LineStyle>
			<color>ffff00ff</color>
			<width>2</width>
		</LineStyle>
		<PolyStyle>
			<color>00ff00ff</color>
			<fill>0</fill>
		</PolyStyle>
	</Style>
	<Style id="HighlightSheet1Map10">
		<IconStyle>
			<scale>0.7</scale>
			<Icon>
				<href>https://maps.google.com/mapfiles/kml/pushpin/red-pushpin.png</href>
			</Icon>
		</IconStyle>
		<LabelStyle>
			<scale>0.7</scale>
		</LabelStyle>
		<BalloonStyle>
			<text>$[description]</text>
		</BalloonStyle>
		<LineStyle>
			<color>ffff00ff</color>
			<width>3</width>
		</LineStyle>
		<PolyStyle>
			<color>70ff00ff</color>
			<fill>0</fill>
		</PolyStyle>
	</Style>
	<StyleMap id="Sheet1Map10">
		<Pair>
			<key>normal</key>
			<styleUrl>#NormalSheet1Map10</styleUrl>
		</Pair>
		<Pair>
			<key>highlight</key>
			<styleUrl>#HighlightSheet1Map10</styleUrl>
		</Pair>
	</StyleMap>
	<Style id="NormalSheet1Map10">
		<IconStyle>
			<Icon>
				<href>https://maps.google.com/mapfiles/kml/pushpin/ylw-pushpin.png</href>
			</Icon>
		</IconStyle>
		<BalloonStyle>
			<text>$[description]</text>
		</BalloonStyle>
		<LineStyle>
			<color>ffff00ff</color>
			<width>2</width>
		</LineStyle>
		<PolyStyle>
			<color>00ff00ff</color>
			<fill>0</fill>
		</PolyStyle>
	</Style>
	<Folder>
		<name>Sheet1</name>
		<visibility>0</visibility>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>DENVER WB AP CO</description>
			<LookAt>
				<longitude>-104.88</longitude>
				<latitude>39.77</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-104.88,39.77,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>CHARLESTON KAN AP WV</description>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-81.59999999999999,38.37,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>BOULDER UT</description>
			<LookAt>
				<longitude>-111.42</longitude>
				<latitude>37.92</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-111.42,37.92000000000001,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>BOULDER UT</description>
			<LookAt>
				<longitude>-111.42</longitude>
				<latitude>37.92</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-111.42,37.92000000000001,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>BOULDER UT</description>
			<LookAt>
				<longitude>-111.42</longitude>
				<latitude>37.92</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-111.42,37.92000000000001,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>BOULDER UT</description>
			<LookAt>
				<longitude>-111.42</longitude>
				<latitude>37.92</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-111.42,37.92000000000001,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>HOUGHTON FAA AP MI +</description>
			<LookAt>
				<longitude>-88.5</longitude>
				<latitude>47.17</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-88.5,47.17000000000001,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>DENVER WB AP CO</description>
			<LookAt>
				<longitude>-104.88</longitude>
				<latitude>39.77</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-104.88,39.77,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>TAHOE CA</description>
			<LookAt>
				<longitude>-120.15</longitude>
				<latitude>39.17</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-120.15,39.17,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>TAHOE CA</description>
			<LookAt>
				<longitude>-120.15</longitude>
				<latitude>39.17</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-120.15,39.17,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>LOS ANGELES WB CITY CA</description>
			<LookAt>
				<longitude>-118.23</longitude>
				<latitude>34.05</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-118.23,34.05,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>MOSCOW U OF I ID</description>
			<LookAt>
				<longitude>-117</longitude>
				<latitude>46.73</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-117,46.73,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>NORTON Road Site +</description>
			<LookAt>
				<longitude>-105.36</longitude>
				<latitude>39.67</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-105.36,39.67,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>Tularosa Creek +</description>
			<LookAt>
				<longitude>-105.94</longitude>
				<latitude>33.1</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-105.94,33.1,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>Tularosa Creek +</description>
			<LookAt>
				<longitude>-105.94</longitude>
				<latitude>33.1</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-105.94,33.1,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>Tularosa Creek +</description>
			<LookAt>
				<longitude>-105.94</longitude>
				<latitude>33.1</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-105.94,33.1,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>BRIDGEPORT CA</description>
			<LookAt>
				<longitude>-119.23</longitude>
				<latitude>38.27</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-119.23,38.27,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>MINDEN NV</description>
			<LookAt>
				<longitude>-119.77</longitude>
				<latitude>38.95</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-119.77,38.95,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>WALLACE WDLND PK ID</description>
			<LookAt>
				<longitude>-115.88</longitude>
				<latitude>47.5</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-115.88,47.5,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>WALLACE WDLND PK ID</description>
			<LookAt>
				<longitude>-115.88</longitude>
				<latitude>47.5</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-115.88,47.5,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>WALLACE WDLND PK ID</description>
			<LookAt>
				<longitude>-115.88</longitude>
				<latitude>47.5</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-115.88,47.5,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>WALLACE WDLND PK ID</description>
			<LookAt>
				<longitude>-115.88</longitude>
				<latitude>47.5</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-115.88,47.5,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>WALLACE WDLND PK ID</description>
			<LookAt>
				<longitude>-115.88</longitude>
				<latitude>47.5</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-115.88,47.5,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>WALLACE WDLND PK ID</description>
			<LookAt>
				<longitude>-115.88</longitude>
				<latitude>47.5</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-115.88,47.5,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>WALLACE WDLND PK ID</description>
			<LookAt>
				<longitude>-115.88</longitude>
				<latitude>47.5</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-115.88,47.5,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>WALLACE WDLND PK ID</description>
			<LookAt>
				<longitude>-115.88</longitude>
				<latitude>47.5</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-115.88,47.5,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>WALLACE WDLND PK ID</description>
			<LookAt>
				<longitude>-115.88</longitude>
				<latitude>47.5</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-115.88,47.5,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>WALLACE WDLND PK ID</description>
			<LookAt>
				<longitude>-115.88</longitude>
				<latitude>47.5</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-115.88,47.5,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>WALLACE WDLND PK ID</description>
			<LookAt>
				<longitude>-115.88</longitude>
				<latitude>47.5</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-115.88,47.5,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>WALLACE WDLND PK ID</description>
			<LookAt>
				<longitude>-115.88</longitude>
				<latitude>47.5</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-115.88,47.5,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>WALLACE WDLND PK ID</description>
			<LookAt>
				<longitude>-115.88</longitude>
				<latitude>47.5</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-115.88,47.5,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>WALLACE WDLND PK ID</description>
			<LookAt>
				<longitude>-115.88</longitude>
				<latitude>47.5</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-115.88,47.5,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>WALLACE WDLND PK ID</description>
			<LookAt>
				<longitude>-115.88</longitude>
				<latitude>47.5</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-115.88,47.5,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>WALLACE WDLND PK ID</description>
			<LookAt>
				<longitude>-115.88</longitude>
				<latitude>47.5</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-115.88,47.5,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>WALLACE WDLND PK ID</description>
			<LookAt>
				<longitude>-115.88</longitude>
				<latitude>47.5</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-115.88,47.5,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>WALLACE WDLND PK ID</description>
			<LookAt>
				<longitude>-115.88</longitude>
				<latitude>47.5</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-115.88,47.5,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>WALLACE WDLND PK ID</description>
			<LookAt>
				<longitude>-115.88</longitude>
				<latitude>47.5</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-115.88,47.5,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>WALLACE WDLND PK ID</description>
			<LookAt>
				<longitude>-115.88</longitude>
				<latitude>47.5</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-115.88,47.5,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>WALLACE WDLND PK ID</description>
			<LookAt>
				<longitude>-115.88</longitude>
				<latitude>47.5</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-115.88,47.5,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>WALLACE WDLND PK ID</description>
			<LookAt>
				<longitude>-115.88</longitude>
				<latitude>47.5</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-115.88,47.5,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>WALLACE WDLND PK ID</description>
			<LookAt>
				<longitude>-115.88</longitude>
				<latitude>47.5</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-115.88,47.5,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>WALLACE WDLND PK ID</description>
			<LookAt>
				<longitude>-115.88</longitude>
				<latitude>47.5</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-115.88,47.5,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>WALLACE WDLND PK ID</description>
			<LookAt>
				<longitude>-115.88</longitude>
				<latitude>47.5</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-115.88,47.5,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>WALLACE WDLND PK ID</description>
			<LookAt>
				<longitude>-115.88</longitude>
				<latitude>47.5</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-115.88,47.5,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>WALLACE WDLND PK ID</description>
			<LookAt>
				<longitude>-115.88</longitude>
				<latitude>47.5</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-115.88,47.5,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>WALLACE WDLND PK ID</description>
			<LookAt>
				<longitude>-115.88</longitude>
				<latitude>47.5</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-115.88,47.5,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>WALLACE WDLND PK ID</description>
			<LookAt>
				<longitude>-115.88</longitude>
				<latitude>47.5</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-115.88,47.5,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>TAHOE CA</description>
			<LookAt>
				<longitude>-120.15</longitude>
				<latitude>39.17</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-120.15,39.17,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>HARRISBURG IL</description>
			<LookAt>
				<longitude>-88.53</longitude>
				<latitude>37.73</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-88.53,37.73,0</coordinates>
			</Point>
		</Placemark>
		<Placemark>
			<visibility>0</visibility>
			<Snippet maxLines="0"></Snippet>
			<description>CHARLESTON KAN AP WV</description>
			<LookAt>
				<longitude>-81.59999999999999</longitude>
				<latitude>38.37</latitude>
				<altitude>0</altitude>
				<range>1000</range>
				<tilt>0</tilt>
				<heading>0</heading>
			</LookAt>
			<styleUrl>#Sheet1Map10</styleUrl>
			<Point>
				<extrude>1</extrude>
				<altitudeMode>relativeToGround</altitudeMode>
				<coordinates>-81.59999999999999,38.37,0</coordinates>
			</Point>
		</Placemark>
	</Folder>
</Document>
</kml>
';
