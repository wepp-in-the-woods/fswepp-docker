<?php
require("../../shared_web/resources.php");
require("../../shared_web/resources_climate.php");
require($_SERVER["DOCUMENT_ROOT"]."/".$climate_directory."/_lib/arrays.php");
require($_SERVER["DOCUMENT_ROOT"]."/".$climate_directory."/future/future_scripts.php");
require($_SERVER["DOCUMENT_ROOT"]."/".$climate_directory."/shared/shared_scripts.php");
	
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "https://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="https://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Content-Language" content="en-us" />
<meta name="copyright" content="2009 USDA Forest Service Rocky Mountain Research Station" />
<meta name="author" content="USDA Forest Service - Nick Crookston" />
<meta name="robots" content="all" />
<meta name="MSSmartTagsPreventParsing" content="true" />
<meta name="description" content="Future Climate Estimates and Potential Impacts of Global Warming Scenarios in Western North America and Mexico." />
<meta name="keywords" content="climate, climate estimates, predictions, plant and climate relationships, global warming, global warming scenarios, predicting global warming, " />
<title>Future Climate Estimates and Potential Impacts of Global Warming Scenarios in Western North America and Mexico</title>
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
<div id="pagewrapper01" class="future">
    <div id="main01">
        <div id="row01">
            <div id="section02">
                <div class="contentbox01">
                	<h1><span class="umbrella-title">Climate Estimates and Plant-Climate Relationships</span> <br />
                    Future Climate Estimates</h1>
					<ul class="breadcrumb-nav">
						<li><a href="<?php echo ("".$home_URL.""); ?>/">Moscow Home</a> &gt; </li>
						<li><a href="<?php echo ("".$home_climate_URL.""); ?>/">Climate</a> &gt; </li>
						<li><strong>Future Climate Estimates</strong></li>
					</ul>
					<h2 class="mainlink"><a href="details.php">Details of Data/Methods Used</a></h2>

					<div class="sub-content-nav">
						<!-- Begin form -->
						<form method="post" name="downloadFutureData" id="downloadFutureData" action="index.php" enctype="multipart/form-data">
							<h2>Download Data Files</h2>
							<h3>Spatial Extents</h3>
							<div class="two-column-content">
								<div class="two-column-content-row">
									<div class="two-column-content-left">
										<p><strong>Choose one:</strong></p>
										<input class="scanMe" divId="spatial-extent-allna" type="radio" name="spatialExtent" value="allNA" id="allna" onclick="scan();" checked /> <label for="allna">All North America (Preferred)</label><br />
										<input class="scanMe" divId="spatial-extent-westna" type="radio" name="spatialExtent" value="westNA" id="westna" onclick="scan();" /> <label for="westna">Western North America (Depreciated)</label><br />
										<input class="scanMe" divId="spatial-extent-mexico" type="radio" name="spatialExtent" value="Mexico" id="mexico" onclick="scan();" /> <label for="mexico">Mexico (Depreciated)</label>
									</div>
									<div class="two-column-content-right">
										<div class="naming-key">
											<table>
												<thead> 
													<tr>
														<th scope="col">Spatial Extent</th>
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
									<p class="closefloat2">&nbsp;<br /><br /><br /><br /><br /></p>
								</div> 
							</div>

					<!-- Begin Block of MEXICO download options - hidden by default -->
							<div id="spatial-extent-mexico" class="showHide">
								<h3>Select a General Circulation Model/Scenario/Nominal Decade</h3>
<?php
formWriteSelectOptions($path = "/future/Mexico/", $spatial_extent_abbr = "Mex");
formWriteScenarioDownloads($path = "/future/Mexico/", $spatial_extent_abbr = "Mex");
?>
							</div><!-- END spatial-extent-mexico -->
					<!-- End Block of MEXICO download options -->

					<!-- Begin Block of WESTERN NORTH AMERICA download options - displayed by default -->
							<div id="spatial-extent-westna" class="showHide">
								<h3>Select a General Circulation Model/Scenario/Nominal Decade</h3>
<?php
formWriteSelectOptions($path = "/future/westNA/", $spatial_extent_abbr = "wNA");
formWriteScenarioDownloads($path = "/future/westNA/", $spatial_extent_abbr = "wNA");
?>
							</div><!-- END spatial-extent-westNA -->
					<!-- End Block of WESTERN NORTH AMERICA download options -->

					<!-- Begin Block of ALL NORTH AMERICA download options - displayed by default -->
							<div id="spatial-extent-allna" class="showHide">
								<h3>Select a General Circulation Model/Scenario/Nominal Decade</h3>
<?php
formWriteSelectOptions($path = "/future/allNA/", $spatial_extent_abbr = "aNA");
formWriteScenarioDownloads($path = "/future/allNA/", $spatial_extent_abbr = "aNA");
?>
							</div><!-- END spatial-extent-allNA -->
					<!-- End Block of ALL NORTH AMERICA download options -->

					</form>
					</div><!-- END subcontent-nav -->
					<div class="footer-information">
						<p><strong>Contact:</strong> <a href="mailto:ncrookston@fs.fed.us">Nicholas Crookston</a></p>
						<p>USDA Forest Service - RMRS - Moscow Forestry Sciences Laboratory<br />
							Last Modified:
							<script>document.write( document.lastModified )</script>
						</p>
						<p><a href="https://www.fs.fed.us/disclaimers.shtml">Important Notices</a> | <a href="https://www.fs.fed.us/privacy.shtml">Privacy Policy</a></p>
					</div>

                </div>
            </div>
        </div>
  	</div>
</div>

</body>
</html>
