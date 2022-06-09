<?php
require("../../shared_web/resources.php");
require("../../shared_web/resources_climate.php");
require($_SERVER["DOCUMENT_ROOT"]."/".$climate_directory."/_lib/arrays.php");
require($_SERVER["DOCUMENT_ROOT"]."/".$climate_directory."/species/species_scripts.php");
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
<meta name="description" content="Predictions of Current Plant Species and Community Distributions and Projections into Future Climatic Space for Mexico and Western North America." />
<meta name="keywords" content="plant, plants, species, climate predictions, climate prediction, species climate profiles, relationships, global warming, global warming scenarios, predicting global warming, " />
<title>Plant Species and Climate Profile Predictions</title>
<?php
include ($_SERVER["DOCUMENT_ROOT"]."/".$shared_directory."/stylesheets.php");
?>
<script language="JavaScript" type="text/javascript">
onload = function(){
	scan();
}
</script>
</head>

<body class="climate">

<?php
include($_SERVER["DOCUMENT_ROOT"]."/".$shared_directory."/left_nav.php");
?>
<div id="pagewrapper01" class="speciesClimateProfiles">
    <div id="main01">
        <div id="row01">
            <div id="section02">
                <div class="contentbox01">
                	<h1><span class="umbrella-title">Climate Estimates, Climate Change and Plant Climate Relationships</span> <br />Plant Species and Climate Profile Predictions</h1>
					<ul class="breadcrumb-nav">
						<li><a href="<?php echo ("".$home_URL.""); ?>/">Moscow Home</a> &gt; </li>
						<li><a href="<?php echo ("".$home_climate_URL.""); ?>/">Climate</a> &gt; </li>
						<li><strong>Plant Species and Climate Profile Predictions</strong></li>
					</ul>

					<!--<h2>Introduction</h2>
					<p>Introduction text goes here.</p> -->
					<div class="sub-content-nav">
						<h2>File Naming Conventions</h2>
						<div class="naming-key">
							<h4 class="first-heading">File Naming Structure</h4>
							<p><strong>&lt;Data Source&gt;_&lt;Scenario&gt;_&lt;Decade of Estimate&gt;.&lt;PNG, TXT or ZIP&gt;</strong></p>
							<ul>
								<li><strong>PNG</strong> files are images of the maps. </li>
								<li><strong>ZIP</strong> files are ASCII grid files of the maps. These zip files will unzip to one file named &lt;Data Source&gt;_&lt;Scenario&gt;_&lt;Decade of Estimate&gt;.txt </li>
								<li><strong>metadata.xml</strong> files are the meta data that describes maps.</li>
							</ul>
							<table style="margin-bottom:10px;">
								<thead> 
									<tr>
										<th scope="col">Abbreviation</th>
										<th scope="col">Data Source</th>
									</tr>
								</thead>
								<tbody>
									<tr>
										<td>CGCM3</td>
										<td><a href="http://www.cccma.ec.gc.ca/models/cgcm3.shtml">Canadian Center for Climate Modeling and Analysis</a></td>
									</tr>
									<tr>
										<td>GFDLCM21</td>
										<td><a href="http://www.gfdl.noaa.gov/">Geophysical Fluid Dynamics Laboratory</a></td>
									</tr>
									<tr>
										<td>HADCM3</td>
										<td><a href="http://www.metoffice.gov.uk/climatechange/science/projections/">Hadley Center</a>/<a href="http://cera-www.dkrz.de/CERA/">World Data Center</a></td>
									</tr>
								</tbody>
							</table>
							<p style="margin-bottom:0;">Scenarios (<strong>A1B</strong>, <strong>A2</strong>, <strong>B1</strong>, <strong>B2</strong>) and year of estimate (<strong>y2030</strong>, <strong>y2060</strong>, <strong>y2090</strong>) follow the abbreviation for the data source.</p>
						</div>
						<h2>Available Species-Climate Profiles</h2>
						<ul>
<?php

	writeSpeciesLinksFullNames($path = "/species/speciesDist/");
	//write out form with nothing selected

?>
						</ul>

					</div>
                    
					<div class="footer-information">
						<p><strong>Contact:</strong> <a href="mailto:ncrookston@fs.fed.us">Nicholas Crookston</a></p>
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
