<?php
require("shared_web/resources.php");
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
<meta name="description" content="USDA Forest Service - Rocky Mountain Research Station, Moscow Forestry Sciences Laboratory" />
<meta name="keywords" content="Rocky Mountain Research Station, Forest Service, Fire Research, forest fire, prescribed fire, fire conditions, fire effects, wildfire, fire science, watershed, Forestry Sciences Laboratory, erosion prediction, climate, climate estimates, plant and climate relationships, global warming, global warming scenarios, predicting global warming" />
<title>Moscow Forestry Sciences Laboratory, USDA Forest Service</title>
<?php
include ($_SERVER["DOCUMENT_ROOT"]."/".$shared_directory."/stylesheets.php");
?>
<script type="text/javascript">
//added for Safari and Google Chrome - other date script is not showing for them with this particular server set-up 
function showLastModified() {
var out = document.getElementById('lastModified');
var d = new Date();
if (d.toLocaleDateString) {
out.innerHTML = d.toLocaleDateString(document.lastModified);
}
else {
out.innerHTML = document.lastModified;
}
}

window.onload = showLastModified;
</script>
</head>

<body class="moscowfsl">

<div id="section01">
	<div class="contentbox01">
		<ul class="fslinks">
			<li><a href="http://www.fs.fed.us/rmrs/" title="Rocky Mountain Research Station"><img src="<?php echo ("".$home_URL."/".$shared_directory.""); ?>/logo_rmrs_tan_bkgd.gif" width="160" height="118" alt="Rocky Mountain Research Station" /></a></li>
			<li><a href="http://www.usda.gov" title="United States Department of Agriculture"><img src="<?php echo ("".$home_URL."/".$shared_directory.""); ?>/logo_usda.gif" width="69" height="47" alt="United States Department of Agriculture" /></a><a href="http://www.fs.fed.us/"><img src="<?php echo ("".$home_URL."/".$shared_directory.""); ?>/logo_fs_tan_bkgd.gif" width="45" height="46" alt="United States Forest Service" /></a></li>
			<li><a href="http://www.usa.gov"><img src="<?php echo ("".$home_URL."/".$shared_directory.""); ?>/logo_usagov_tan_bkgd.gif" width="121" height="36" alt="USA.gov" /></a></li>
		</ul>
		<p class="contact-info"><strong>Moscow Forestry Sciences Laboratory</strong> <br />
		1221 South Main Street <br />
		Moscow, ID 83843 <br />
		(208) 882-3557 <br />
		7:30-4:30 M-F </p>
	</div>
</div>
<div id="section01-print">
    <div class="contentbox01">
        <h2><span class="print-heading">USDA Forest Service Rocky Mountain Research Station </span><br />Moscow Forestry Sciences Laboratory</h2>
		<p class="contact-info">1221 South Main Street, Moscow, ID 83843, (208)882-3557, Hours: 7:30-4:30 M-F </p>

    </div>
</div>
<div id="pagewrapper01" class="home">
    <div id="main01">
        <div id="row01">
            <div id="section02">
                <div class="contentbox01">
                	<h1>Moscow Forestry Sciences Laboratory</h1>
               		<div class="simple-main-content-nav">
                    	<h2><a href="<?php echo ("".$home_URL."");?>/climate/">Climate Estimates and Plant-Climate Relationships</a></h2>
                        <h2 class="nohref">Long-Term Soil Productivity and Related Work</h2>
						<ul>
							<li><a href="<?php echo ("".$home_URL."");?>/smp/">Long-Term Soil Productivity (LTSP)</a></li>
							<li><a href="<?php echo ("".$home_URL."");?>/smp/solo/"><acronym title="Soil quality monitoring and Long term ecosystem sustainability">SoLo</acronym>: Soil Monitoring and Productivity Library</a></li>
						</ul>
                        <h2><a href="<?php echo ("".$home_URL."");?>/fswepp/">WEPP Modeling Software</a></h2>
					</div>
					<h2>Rocky Mountain Research Station Programs located at the Moscow Laboratory</h2>
					<ul>
						<li><a href="http://www.fs.fed.us/rmrs/research/programs/air-water-aquatics/">Air, Water and Aquatics</a></li>
						<li><a href="http://www.fs.fed.us/rmrs/research/programs/forest-woodlands-ecosystem/">Forests and Woodlands Ecosystems</a></li>
						<li><a href="http://www.fs.fed.us/rmrs/research/programs/grassland-shrubland-desert/">Grassland, Shrubland and Desert Ecosystems</a></li>
					</ul>
					<h2>Experimental Forests managed from the Moscow Laboratory</h2>
					<ul>
						<li><a href="<?php echo ("".$home_URL."");?>/ef/pref/index.php">Priest River Experimental Forest</a></li>
						<li><a href="<?php echo ("".$home_URL."");?>/ef/dcef.php">Deception Creek Experimental Forest</a></li>
						<li><a href="<?php echo ("".$home_URL."");?>/ef/bbef.php">Boise Basin Experimental Forest</a></li>
					</ul>
					
					<div class="footer-information">
						<p>USDA Forest Service - RMRS - Moscow Forestry Sciences Laboratory<br />
							Last Modified: 
							<!-- below added for Safari and Google Chrome - other date script is not showing for them with this particular server set-up -->
							<span id="lastModified">&nbsp;</span>
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