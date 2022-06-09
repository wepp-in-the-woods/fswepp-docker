<?php
require("../../shared_web/resources.php");
require("../../shared_web/resources_climate.php");
require($_SERVER["DOCUMENT_ROOT"]."/".$climate_directory."/shared/shared_scripts.php");
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Content-Language" content="en-us" />
<meta name="copyright" content="2009 USDA Forest Service Rocky Mountain Research Station" />
<meta name="author" content="USDA Forest Service - Nick Crookston" />
<meta name="robots" content="all" />
<meta name="MSSmartTagsPreventParsing" content="true" />
<meta name="description" content="Climate-FVS climate and species viability data for Western United States." />
<meta name="keywords" content="FVS, climate, species viability, plant and climate relationships, global warming, global warming scenarios,  " />
<title>Climate-FVS Ready Data Requests</title>
<?php
include ($_SERVER["DOCUMENT_ROOT"]."/".$shared_directory."/stylesheets.php");
?>
</head>

<body class="climate">

<?php
include($_SERVER["DOCUMENT_ROOT"]."/".$shared_directory."/left_nav.php");
?>
<div id="pagewrapper01" class="customData">
    <div id="main01">
        <div id="row01">
            <div id="section02">
                <div class="contentbox01">
                	<h1><span class="umbrella-title">Climate Estimates and Plant-Climate Relationships</span> <br />
                    Get Climate-FVS Ready Data</h1>
					<ul class="breadcrumb-nav">
						<li><a href="<?php echo ("".$home_URL.""); ?>">Moscow Home</a> &gt; </li>
						<li><a href="<?php echo ("".$home_climate_URL.""); ?>/index.php">Climate</a> &gt; </li>
						<li><a href="<?php echo ("".$home_climate_URL.""); ?>/customData/index.php">Custom Climate Data Requests</a> &gt; </li>
						<li><strong>Climate-FVS Ready Data</strong></li>
					</ul>
								
					<h2>Introduction</h2>
					<p><a href=http://www.fs.fed.us/fmsc/fvs/description/climate-fvs.shtml">Climate-FVS</a> is a modification to the <a href="http://www.fs.fed.us/fmsc/fvs/index.shtml">Forest Vegetation Simulator</a>, a stand dynamics model generally used to support forest planning, project analysis, and silvicultural prescription preparation.</p>
					<p>Climate-FVS reads an input a data file created from using this web page. The file includes derived variables like those available from the <a href="<?php echo ("".$home_climate_URL.""); ?>/customData/index.php">Custom Climate Data Request</a> page plus relevant species-climate profile scores described on the <a href="<?php echo ("".$home_climate_URL.""); ?>/species/index.php">Species-Climate Profiles </a> page. The data for all GCM and SRES scenarios and for all time slices that are available are included automatically. Users select which ones to use in Climate-FVS projections in that software, not here.</p>
					<p><strong>NOTE: These data are only available for Western United States (excluding Alaska, longitude -125 to -102 and latitude 31 to 51 degrees).</strong></p>
					<h2>How it Works</h2>
					<ol>
            <li>You prepare a file of locations for which
Climate-FVS-ready data are produced. Normally, each location represents one stand, "setting", or point and
is labeled as a "PointID". These point data have 3 or 4 columns coded as space separated values (commas and tabs also work) with these fields:
   PointID, Long, Lat (decimal degrees), and optionally, Elevation (meters).
   If you do not include a header record, then the order of the columns must be PointID, Long, Lat, Elev. If Elev is missing (for
   any or all points), it will be estimated from
   <a href="http://nationalmap.gov/3DEP/index.html">USGS 1-arc second elevation data.</a> <br /><br />
   If you include a header record, the name you supply for the first field will be replaced with "PointID"; the
   PointID column must be the first column. The other column names are matched using the following rules:
   a name with "lat" is the latitude (case insensitive), a name with "lon" is the longitude, and a name with "ele" is the elevation. <br /><br />
   If a PointID includes blank(s), enclose it in quotation marks. Example line: "Moscow ID" -117.0 46.73 787.3<br /><br />
   File extension is normally .txt, however you may compress your file so that the extension is .zip (implies a zip file) or .gz (implies a gzip file).
</li>
						<li>You specify an Email address we can use to contact you.</li>
						<li>You specify the data file to send our site.</li>
						<li>Our server processes the request and builds a zip file of the output data.</li>
						<li>Our server sends you an Email with links included that you can use to retrieve the data you requested. You are given 48 hours to recover your data from the time the Email message is sent. Short runs take 5 to 10 mins, long runs can take an hour or two.</li>
						<li>Once you get the answers.zip file, copy the file named FVSClimAttrs.csv to the FVS data directory for your simulations.</li>
					</ol>
  				<p>See: <a href="<?php echo ("".$home_climate_URL."/dataNotice.php"); ?>">New Algorithms Used For Some Derived Variables</a> </p>

					<div class="sub-content-nav">
						<h2>Input Form for Climate-FVS Ready Data</h2>
						<form name="customRequestFVS" method="POST" action= "http://<?php echo ("".$_SERVER["HTTP_HOST"].""); ?>/climate/customData/customRequestFVS.php" enctype="multipart/form-data">
							<label for="emailAddress">Your Email Address:</label><br />
							<input type="TEXT" name="emailAddress" VALUE ="" size="50" /><br /><br />
							<label for="uploadFileName">Specify the file name for the file upload:</label><br />
							<input type="file" name="uploadFileName" size="50" /><br /><br />

							<input type="checkbox" name="CMIP5" value="Yes" checked/><label for="CMIP5">Futures based on AR5 climate model outputs (if unchecked, only AR3 models are used).</label><br />
							<input type="checkbox" name="ALLCM5" value="Yes" /><label for="ALLCM5">When AR5 outputs are used, include rcp45 and rcp85 for CCSM4, GFDLCM3, and HadGEM2ES.</label><br /><br /><br />
														
							<input type="submit" value="Submit" />
						</form>
					</div>
					<div class="footer-information">
						<p><strong>Contact:</strong> <a href="mailto:ncrookston.fs@gmail.com">Nicholas Crookston</a></p>
						<p>USDA Forest Service - RMRS - Moscow Forestry Sciences Laboratory<br />
							Last Modified:
							<script>document.write( document.lastModified )</script>
						</p>
						<p><a href="http://www.fs.fed.us/disclaimers.shtml">Important Notices</a> | <a href="http://www.fs.fed.us/privacy.shtml">Privacy Policy</a></p>
					</div>
					
				</div>
			</div>
		</div>
  	</div>
</div>

</body>
</html>
