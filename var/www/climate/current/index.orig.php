<?php
require("../../shared_web/resources.php");
require("../../shared_web/resources_climate.php");
require($_SERVER["DOCUMENT_ROOT"]."/".$climate_directory."/_lib/arrays.php");
require($_SERVER["DOCUMENT_ROOT"]."/".$climate_directory."/current/current_scripts.php");
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
<meta name="description" content="Current Climate Data for Mexico, the United States and all of North America." />
<meta name="keywords" content="climate, climate estimates, plant and climate relationships, global warming, global warming scenarios, predicting global warming, " />
<title>Current Climate Data for Western North America, Western United States, All of North America and Mexico</title>
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
<div id="pagewrapper01" class="current">
    <div id="main01">
        <div id="row01">
            <div id="section02">
                <div class="contentbox01">
                	<h1><span class="umbrella-title">Climate Estimates and Plant-Climate Relationships</span> <br />
                    Current Climate Data</h1>
					<ul class="breadcrumb-nav">
						<li><a href="<?php echo ("".$home_URL.""); ?>/">Moscow Home</a> &gt; </li>
						<li><a href="<?php echo ("".$home_climate_URL.""); ?>/">Climate</a> &gt; </li>
						<li><strong>Current Climate Data</strong></li>
					</ul>

					<!--<h2>Introduction</h2>
					<p>Introduction text goes here.</p> -->
					<div class="sub-content-nav">
						<h2>Download Data Files</h2>
						<!-- Begin form -->
						<form method="post" name="downloadCurrentData" action="index.php" enctype="multipart/form-data">
						<h3>Spatial Extents</h3>
							<div class="two-column-content">
								<div class="two-column-content-row">
									<div class="two-column-content-left">
										<p><strong>Choose one:</strong></p>
										<input type="radio" class="scanMe" divId="spatial-extent-allNA" name="spacialExtent" value="allNA" id="allna" onclick="scan();" checked /> <label for="allna">All North America (Preferred)</label><br />
										<input type="radio" class="scanMe" divId="spatial-extent-westNA" name="spacialExtent" value="westNA" id="westna" onclick="scan();"  /> <label for="westna">Western North America (Depreciated)</label><br />
										<input type="radio" class="scanMe" divId="spatial-extent-Mexico" name="spacialExtent" value="Mexico" id="mexico" onclick="scan();" /> <label for="mexico">Mexico (Depreciated)</label>
									</div>
									<div class="two-column-content-right">
										<div class="naming-key">
											<table>
												<thead> 
													<tr>
														<th scope="col">Spacial Extent</th>
														<th scope="col">Latitude/Longitude</th>
													</tr>
												</thead>
												<tbody>
													<tr>
														<td>Mexico</td>
														<td>longitude -118 to -74 and latitude 13.9 to 33 degrees</td>
													</tr>
													<tr>
														<td>westNA</td>
														<td>longitude -177 to -97 and latitude 25 to 79 degrees</td>
													</tr>
													<tr>
														<td>allNA</td>
														<td>longitude -177 to -52 and latitude 13.9 to 80 degrees</td>
													</tr>
												</tbody>												
											</table>
										</div>
									</div>
									<p class=\"closefloat2\">&nbsp;<br /><br /><br /><br /><br /></p>
								</div> 
							</div>

<?php
formWriteCurrentScenarioDownloads($path = "/current/");
?>
							<div><p>&nbsp;</p></div>
						
						</form>

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
