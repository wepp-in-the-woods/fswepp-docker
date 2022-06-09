<?php
require("../shared_web/resources.php");
require("../shared_web/resources_climate.php");
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Content-Language" content="en-us" />
<meta name="copyright" content="2010 USDA Forest Service Rocky Mountain Research Station" />
<meta name="author" content="USDA Forest Service - Nick Crookston" />
<meta name="robots" content="all" />
<meta name="MSSmartTagsPreventParsing" content="true" />
<meta name="description" content="Future climate maps for Western North America and Mexico showing the probable locations for many species of forest trees and plants." />
<meta name="keywords" content="climate, climate estimates, climate data, plant and climate relationships, global warming, climate change, global warming scenarios, predicting global warming, " />
<title>Forest Climate Change Evidence | Potential Effects of Global Warming on Forests and Plant Climate Relationships | Western North America and Mexico</title>
<?php
include ($_SERVER["DOCUMENT_ROOT"]."/".$shared_directory."/stylesheets.php");
?>
</head>

<body class="climate">

<?php
include ($_SERVER["DOCUMENT_ROOT"]."/".$shared_directory."/left_nav.php");
?>
<div id="pagewrapper01" class="home">
    <div id="main01">
        <div id="row01">
            <div id="section02">
                <div class="contentbox01">
                	<h1>Research on Forest Climate Change: Potential Effects of Global Warming on Forests and Plant Climate Relationships in Western North America and Mexico</h1>
					<ul class="breadcrumb-nav">
						<li><a href="<?php echo ("".$home_URL.""); ?>/">Moscow Home</a> &gt; </li>
						<li><strong>Climate</strong></li>
					</ul>
					<h2>Introduction</h2>
					<p>Climate surfaces that can provide point estimates of climate measures are needed for studying forest plant-climate relationships (e.g.    <a href="http://www.fs.fed.us/rm/pubs_other/rmrs_2006_rehfeldt_g001.pdf">Rehfeldt <em>et al.</em> 2006</a>) and for making predictions about how forests, plant communities and species distributions may change on natural landscapes. To meet those needs,  <a href="http://www.fs.fed.us/rm/pubs/rmrs_gtr165.pdf">Rehfeldt (2006)</a> developed monthly climatic surfaces using <a href="http://fennerschool.anu.edu.au/research/software-datasets/anusplin">Hutchinson's thin-plate splines</a> from which were derived variables of demonstrated importance in biology. Analyses of data have shown that climate estimates produced using these methods are closely related to plant responses and should have a variety of uses in spatial biological research. This web page provides access to these climate data and surfaces, and to some of the predictions we have made using these data. For climate data, we build contemporary climate and future climate surfaces. The future climate surfaces are based on the same data used to build the contemporay surfaces after they are updated using information from General Circulation Models (GCM's). Plant-climate relationships are based on contemporary observations of species presence and absence and contemporary climate. Predictions using these relationships can be mapped for contemporary forests and future forest climates.</p>
					<div class="simple-main-content-nav">
                        <h2><a href="<?php echo ("".$home_climate_URL.""); ?>/details.php">Details on Spatial Extents, Temporal Information and Data Elements</a></h2>
                    	<h2 class="nolink">Climate Data and Predictions</h2>
                        	<ul class="homenav">
                            	<li><a href="<?php echo ("".$home_climate_URL.""); ?>/current/">Current Forest Climate Data and Maps</a></li>
                            	<li><a href="<?php echo ("".$home_climate_URL.""); ?>/future/">Maps of Future Climate Change Predictions</a></li>
                            </ul>
                        <h2><a href="<?php echo ("".$home_climate_URL.""); ?>/species/index.php">Maps of Specific Forest Plant Species and Climate Profile Predictions</a></h2>
                        <h2><a href="<?php echo ("".$home_climate_URL.""); ?>/publications.php">Publications Related to this Work</a></h2>
                    	<h2 class="nolink">Custom Climate Data Requests</h2>
                        	<ul class="homenav">
                            	<li><a href="<?php echo ("".$home_climate_URL.""); ?>/customData/">Custom Climate Data Requests</a></li>
                            	<li><a href="<?php echo ("".$home_climate_URL.""); ?>/customData/fvs_data.php">Climate-FVS (Forest Vegetation Simulator) Ready Data</a></li>
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
