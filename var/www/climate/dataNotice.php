<?php
require("../shared_web/resources.php");
require("../shared_web/resources_climate.php");
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
<meta name="description" content="Current and Future Climate Estimates, Plant-Climate Relationships, and Potential Impacts of Global Warming Scenarios in Western North America and Mexico." />
<meta name="keywords" contest="climate, climate estimates, plant and climate relationships, global warming, global warming scenarios, predicting global warming, " />
<title>Current and Future Climate Estimates, Plant-Climate Relationships, and Potential Impacts of Global Warming Scenarios in Western North America and Mexico</title>
<?php
include ($_SERVER["DOCUMENT_ROOT"]."/".$shared_directory."/stylesheets.php");
?>
</head>

<body class="home">

<?php
include($_SERVER["DOCUMENT_ROOT"]."/".$shared_directory."/left_nav.php");
?>
<div id="pagewrapper01" class="home-climate">
    <div id="main01">
        <div id="row01">
            <div id="section02">
                <div class="contentbox01">
                	<h1><span class="umbrella-title">Climate Estimates and Plant-Climate Relationships</span> <br />
                    New Algorithms Used For Some Derived Variables</h1>
					<ul class="breadcrumb-nav">
						<li><a href="<?php echo ("".$home_URL.""); ?>/">Moscow Home</a> &gt; </li>
						<li><a href="<?php echo ("".$home_climate_URL.""); ?>/">Climate</a> &gt; </li>
						<li><strong>New Algorithms Used For Some Derived Variables</strong></li>
					</ul>
					<p><span class="new-info">April 28, 2010 Update:</span> The original algorithms for the following four derived variables:</p>
						<li><strong>fday</strong> &#8212; Julian date of the first freezing date of autumn</li>
						<li><strong>ffp</strong> &#8212; Length of the frost-free period (days)</li>
						<li><strong>sday</strong> &#8212; Julian date of the last freezing date of spring</li>
						<li><strong>gsdd5</strong> &#8212; Degree-days &gt;5 degrees C accumulating within the frost-free period</li>
					<p>
          <br>produced non-continuous predictions along a continuous gradient for mean 
          monthly minimum temperature (<strong>mmin</strong>) and have been replaced. The poor behavior affected 
          predictions where (1) winters are warm (January or December <strong>mmin</strong> greater than 2 C) and (2) 
          where summers are cool (July or August <strong>mmin</strong> less than 5.5 C). The former was evident 
          largely for predictions at low elevation at latitudes below 32 N and locations 
          immediately along the Pacific Coast to latitudes of 50 N. The latter affected 
          predictions at latitudes greater than 58 N and elevations over 2800 m in Mexico, over 2000 m in the 
          Southwest and Great Basin of USA, over 1500 m in Northwest USA, and over 1000 m in 
          western Canada. AsciiGrid maps of these variables have been deleted until they can be replaced with new calculations.</p>
          <p>
          The algorithms have been replaced with with non 
          parametric regressions. The new algorithms will result in small differences in 
          predictions even for areas not affected. Values from the following pages are being computed using the new algorithms:
          <li><a href="<?php echo ("".$home_climate_URL.""); ?>/customData/">Custom Climate Data Requests</a></li>
          <li><a href="<?php echo ("".$home_climate_URL.""); ?>/customData/fvs_data.php">Climate-FVS (Forest Vegetation Simulator) Ready Data</a></li>
          </p>

                </div>
            </div>
        </div>
  	</div>
</div>

</body>
</html>
