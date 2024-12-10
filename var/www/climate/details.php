<?php
require("../shared_web/resources.php");
require("../shared_web/resources_climate.php");
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
                    Details on Spatial Extents, Temporal Information and Data Elements</h1>
					<ul class="breadcrumb-nav">
						<li><a href="<?php echo ("".$home_URL.""); ?>/">Moscow Home</a> &gt; </li>
						<li><a href="<?php echo ("".$home_climate_URL.""); ?>/">Climate</a> &gt; </li>
						<li><strong>Details on Spatial Extents, Temporal Information and Data Elements</strong></li>
					</ul>
					<h2>Spatial Extents</h2>
			        <ul>
						<li><strong>All of North America <span class="new-info">(Preferred)</span> (longitude -177 to -52 and latitude 13.9 to 80 degrees)</strong> was recently built to support new research. It includes all the data used in the original western North America (including Mexico) extents plus data from eastern U.S. and Canada. We do not have a lot of experience using this surface yet. </li>          
						<li><strong>Western United States <span class="new-info">(Depreciated)</span> (westUS: longitude -125 to -102 and latitude 31 to 51 degrees)</strong> is that used by <a href="https://www.fs.fed.us/rm/pubs_other/rmrs_2006_rehfeldt_g001.pdf">Rehfeldt <em>et al.</em> 2006</a> and <a href="https://www.fs.fed.us/rm/pubs/rmrs_gtr165.pdf">Rehfeldt (2006)</a>. This extent is only used in our species modeling, the original data used by <a href="https://www.fs.fed.us/rm/pubs_other/rmrs_2006_rehfeldt_g001.pdf">Rehfeldt <em>et al.</em> 2006</a> and <a href="https://www.fs.fed.us/rm/pubs/rmrs_gtr165.pdf">Rehfeldt (2006)</a> have been incorporated into the North American work.</li>
						<li><strong>Western North America <span class="new-info">(Depreciated)</span> (westNA: longitude -177 to -97 and latitude 25 to 79 degrees)</strong> is based on from the western U.S. (including Alaska), western Canada, and northern Mexico). This surface is based on more data than used to fit the original western U.S. surfaces, even within the original westUS extent. It is the extent we use for all our current work at the one used when <a href="<?php echo ("".$home_climate_URL.""); ?>/customData/">custom data requests</a> are made for western North America.</li>          
						<li><strong>Mexico <span class="new-info">(Depreciated)</span> (Mexico: longitude -118 to -74 and latitude 13.9 to 33 degrees)</strong> falls under work done in cooperation with Cuauhtemoc Saenz-Romero, Universidad Michoacana de San Nicolas de Hidalgo, Mexico (csaenz@umich.mx). Weather stations included are from Mexico, parts of Southeastern U.S., and few stations from Cuba, Guatemala, and Belize. A paper has be re-submitted describing this work. <a href="<?php echo ("".$home_climate_URL."/publications.php"); ?>">See Publications.</a> 
</li>        
					</ul>

					<h2>Spatial Resolution</h2>       
					<p>We work with thin-plate splines <a href="https://fennerschool.anu.edu.au/research/software-datasets/anusplin">(ANUSPLIN Version 4.3)</a> which provide the ability to make point predictions. For mapping, we generally use grid cell size of 0.00833333 decimal degrees (about 1 km), but grids of other resolutions could be used.</p>
					<h2>Temporal Information</h2>
					<ul>
						<li>Contemporary climate for the climate normal period from 1961 to 1990.</li>
						<li>Future climates for the nominal years 2030 (average of 2026 to 2035), 2060, and 2090 based on updating the contemporary data with projections from three General Circulation Models.</li>
					</ul>
					<h2>Data Elements</h2>
					<p>The <a href="https://fennerschool.anu.edu.au/research/software-datasets/anusplin">ANUSPLIN</a> model directly predicts monthly values for:</p>
					<ul>
						<li>average mean daily temperature (degrees C)</li>
						<li>average minimum temperature (degrees C)</li>
						<li>average maximum temperature (degrees C)</li>
						<li>total precipitation (mm)</li>
					</ul>
					<p>From these variables, several derived climate variables <a href="<?php echo ("".$home_climate_URL."/dataNotice.php"); ?>">(see New Algorithms Used For Some Derived Variables)</a> are computed using methods presented by <a href="https://www.fs.fed.us/rm/pubs/rmrs_gtr165.pdf">Rehfeldt</a> (2006). The variables included are:</p>
					<ul>
						<li><strong>d100</strong> &#8212; Julian date the sum of degree-days &gt;5 degrees C reaches 100</li>
						<li><strong>dd0</strong> &#8212; Degree-days &lt;0 degrees C (based on mean monthly temperature)</li>
						<li><strong>dd5</strong> &#8212; Degree-days &gt;5 degrees C (based on mean monthly temperature)</li>
						<li><strong>fday</strong> &#8212; Julian date of the first freezing date of autumn</li>
						<li><strong>ffp</strong> &#8212; Length of the frost-free period (days)</li>
						<li><strong>gsdd5</strong> &#8212; Degree-days &gt;5 degrees C accumulating within the frost-free period</li>
						<li><strong>gsp</strong> &#8212; Growing season precipitation, April to September</li>
						<li><strong>map</strong> &#8212; Mean annual precipitation (mm)</li>
						<li><strong>mat_tenths</strong> &#8212; Mean annual temperature (degrees C)</li>
						<li><strong>mmax_tenths</strong> &#8212; Mean maximum temperature in the warmest month</li>
						<li><strong>mmindd0</strong> &#8212; Degree-days &lt;0 degrees C (based on mean minimum monthly temperature)</li>
						<li><strong>mmin_tenths</strong> &#8212; Mean minimum temperature (degrees C) in the coldest month</li>
						<li><strong>mtcm_tenths</strong> &#8212; Mean temperature (degrees C) in the coldest month</li>
						<li><strong>mtwm_tenths</strong> &#8212; Mean temperature (degrees C) in the warmest month</li>
						<li><strong>sday</strong> &#8212; Julian date of the last freezing date of spring</li>
						<li><strong>smrpb</strong> &#8212; Summer precipitation balance: (jul+aug+sep)/(apr+may+jun)</li>
						<li><strong>smrsprpb</strong> &#8212; (Depreciated) Summer/Spring precipitation balance: (jul+aug)/(apr+may)</li>
						<li><strong>sprp</strong> &#8212; Spring precipitation: (apr+may)</li>
						<li><strong>smrp</strong> &#8212; Summer precipitation: (jul+aug)</li>
						<li><strong>winp</strong> &#8212; Winter precipitation: (nov+dec+jan+feb)</li>

					</ul>
					<p>We used these alone and in combination in our analyses. Typical combinations include:</p>
					<ul>
						<li><strong>adi</strong> &#8212; Annual dryness index, <strong>dd5/map</strong> or <strong>sqrt(dd5)/map</strong> (once named <strong>ami</strong> annual moisture index)</li>
						<li><strong>sdi</strong> &#8212; Summer dryness index, <strong>gsdd5/gsp</strong> or <strong>sqrt(gsdd5)/gsp</strong> (once named <strong>smi</strong>, summer moisture index)</li>
						<li><strong>pratio</strong> &#8212; Ratio of summer precipitatioin to total precipitation, <strong>gsp/map</strong></li>
					</ul>
					<p>These variables are computed for the points where we have vegetation observations for the purpose of building functions that predict vegetation. The variables are computed for <a href="https://docs.codehaus.org/display/GEOTOOLS/ArcInfo+ASCII+Grid+format">Asciigrid</a> maps for the purpose of making predictions of vegetation and mapping those predictions.</p>

					<h2 class="mainlink"><a href="future/details.php">Also See: Details of Data/Methods Used for Future Climates</a></h2>

					<div class="footer-information">
						<p><strong>Contact:</strong> <a href="mailto:ncrookston@fs.fed.us">Nicholas Crookston</a></p>
						<p>USDA Forest Service - RMRS - Moscow Forestry Sciences Laboratory<br />
							Last Modified:
							<script>document.write( document.lastModified )</script>
						</p>
					</div>
                </div>
            </div>
        </div>
  	</div>
</div>

</body>
</html>
