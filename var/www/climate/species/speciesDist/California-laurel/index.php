<?php
require("../../../../shared_web/resources.php");
require("../../../../shared_web/resources_climate.php");
require($_SERVER["DOCUMENT_ROOT"]."/".$climate_directory."/_lib/arrays.php");
require($_SERVER["DOCUMENT_ROOT"]."/".$climate_directory."/species/species_scripts.php");
require($_SERVER["DOCUMENT_ROOT"]."/".$climate_directory."/shared/shared_scripts.php");
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Content-Language" content="en-us" />
<meta name="copyright" content="<?php echo ("".$shared_copyright.""); ?>" />
<meta name="author" content="USDA Forest Service - Nick Crookston" />
<meta name="robots" content="all" />
<meta name="MSSmartTagsPreventParsing" content="true" />
<meta name="description" content="Predictions for California-laurel (Umbellularia californica - UMCA) Community Distributions and Projections into Future Climatic Space for Mexico and Western North America." />
<meta name="keywords" content="California-laurel, Umbellularia californica, UMCA, plant, plants, species, climate predictions, climate prediction, species climate profiles, relationships, global warming, global warming scenarios, predicting global warming" />
<title>California-laurel (Umbellularia californica - UMCA): Plant Species and Climate Profile Predictions for North America</title>
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
                	<h1><span class="umbrella-title">Climate Estimates, Climate Change and Plant Climate Relationships</span> <br />
                    Plant Species and Climate Profile Predictions</h1>
					<ul class="breadcrumb-nav">
						<li><a href="<?php echo ("".$home_URL.""); ?>/">Moscow Home</a> &gt; </li>
						<li><a href="<?php echo ("".$home_climate_URL.""); ?>/">Climate</a> &gt; </li>
						<li><a href="<?php echo ("".$home_climate_URL."/species"); ?>/">Plant Species and Climate Profile Predictions</a> &gt; </li>
						<li><strong>California-laurel</strong></li>
					</ul>

					<div class="sub-content-nav">
						<p class="back-nav"><a href="<?php echo ("".$home_climate_URL."/species"); ?>/">&lt;&lt; Back to Species List</a></p>

						<h2>California-laurel (Umbellularia californica - UMCA)</h2>
	
						<div class="thumbnail-file-group">
							<h4>Current Species Data</h4>
							<div class="thumbnail-file-group-01">
								<a href="/climate/species/speciesDist/California-laurel/current.png" title="Download larger PNG file"><img class="thumbnail" src="/climate/species/speciesDist/California-laurel/current.tn.png" width="102" height="80" /></a>
							</div>
							<div class="thumbnail-file-group-02">
								<ul>
									<li><a href="/climate/species/speciesDist/California-laurel/current.png" title="Download larger PNG file">Download "current.png"</a></li>
<li><a href="/climate/species/speciesDist/California-laurel/current.zip" title="Download ZIP file of ASCII grid files of maps">Download "current.zip"</a></li>
<li><a href="/climate/species/speciesDist/California-laurel/current.metadata.xml" title="Display metadata text file">Display "current_metadata.xml"</a></li>
								</ul>
							</div>

						</div>
						<div class="thumbnail-file-group">
							<h4>CGCM3_A1B_y2030</h4>
							<div class="thumbnail-file-group-01">
								<a href="/climate/species/speciesDist/California-laurel/CGCM3_A1B_y2030.png" title="Download larger PNG file"><img class="thumbnail" src="/climate/species/speciesDist/California-laurel/CGCM3_A1B_y2030.tn.png" /></a>
							</div>
							<div class="thumbnail-file-group-02">
							<ul>
								<li><a href="/climate/species/speciesDist/California-laurel/CGCM3_A1B_y2030.png" title="Download larger PNG file">Download "CGCM3_A1B_y2030.png"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/CGCM3_A1B_y2030.zip" title="Download ZIP file of ASCII grid files of maps">Download "CGCM3_A1B_y2030.zip"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/CGCM3_A1B_y2030.metadata.xml" title="Display metadata text file">Display "CGCM3_A1B_y2030.metadata.xml"</a></li>
							</ul>
							</div>
						</div>
						<div class="thumbnail-file-group">
							<h4>CGCM3_A1B_y2060</h4>
							<div class="thumbnail-file-group-01">
								<a href="/climate/species/speciesDist/California-laurel/CGCM3_A1B_y2060.png" title="Download larger PNG file"><img class="thumbnail" src="/climate/species/speciesDist/California-laurel/CGCM3_A1B_y2060.tn.png" /></a>
							</div>
							<div class="thumbnail-file-group-02">
							<ul>
								<li><a href="/climate/species/speciesDist/California-laurel/CGCM3_A1B_y2060.png" title="Download larger PNG file">Download "CGCM3_A1B_y2060.png"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/CGCM3_A1B_y2060.zip" title="Download ZIP file of ASCII grid files of maps">Download "CGCM3_A1B_y2060.zip"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/CGCM3_A1B_y2060.metadata.xml" title="Display metadata text file">Display "CGCM3_A1B_y2060.metadata.xml"</a></li>
							</ul>
							</div>
						</div>
						<div class="thumbnail-file-group">
							<h4>CGCM3_A1B_y2090</h4>
							<div class="thumbnail-file-group-01">
								<a href="/climate/species/speciesDist/California-laurel/CGCM3_A1B_y2090.png" title="Download larger PNG file"><img class="thumbnail" src="/climate/species/speciesDist/California-laurel/CGCM3_A1B_y2090.tn.png" /></a>
							</div>
							<div class="thumbnail-file-group-02">
							<ul>
								<li><a href="/climate/species/speciesDist/California-laurel/CGCM3_A1B_y2090.png" title="Download larger PNG file">Download "CGCM3_A1B_y2090.png"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/CGCM3_A1B_y2090.zip" title="Download ZIP file of ASCII grid files of maps">Download "CGCM3_A1B_y2090.zip"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/CGCM3_A1B_y2090.metadata.xml" title="Display metadata text file">Display "CGCM3_A1B_y2090.metadata.xml"</a></li>
							</ul>
							</div>
						</div>
						<div class="thumbnail-file-group">
							<h4>CGCM3_A2_y2030</h4>
							<div class="thumbnail-file-group-01">
								<a href="/climate/species/speciesDist/California-laurel/CGCM3_A2_y2030.png" title="Download larger PNG file"><img class="thumbnail" src="/climate/species/speciesDist/California-laurel/CGCM3_A2_y2030.tn.png" /></a>
							</div>
							<div class="thumbnail-file-group-02">
							<ul>
								<li><a href="/climate/species/speciesDist/California-laurel/CGCM3_A2_y2030.png" title="Download larger PNG file">Download "CGCM3_A2_y2030.png"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/CGCM3_A2_y2030.zip" title="Download ZIP file of ASCII grid files of maps">Download "CGCM3_A2_y2030.zip"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/CGCM3_A2_y2030.metadata.xml" title="Display metadata text file">Display "CGCM3_A2_y2030.metadata.xml"</a></li>
							</ul>
							</div>
						</div>
						<div class="thumbnail-file-group">
							<h4>CGCM3_A2_y2060</h4>
							<div class="thumbnail-file-group-01">
								<a href="/climate/species/speciesDist/California-laurel/CGCM3_A2_y2060.png" title="Download larger PNG file"><img class="thumbnail" src="/climate/species/speciesDist/California-laurel/CGCM3_A2_y2060.tn.png" /></a>
							</div>
							<div class="thumbnail-file-group-02">
							<ul>
								<li><a href="/climate/species/speciesDist/California-laurel/CGCM3_A2_y2060.png" title="Download larger PNG file">Download "CGCM3_A2_y2060.png"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/CGCM3_A2_y2060.zip" title="Download ZIP file of ASCII grid files of maps">Download "CGCM3_A2_y2060.zip"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/CGCM3_A2_y2060.metadata.xml" title="Display metadata text file">Display "CGCM3_A2_y2060.metadata.xml"</a></li>
							</ul>
							</div>
						</div>
						<div class="thumbnail-file-group">
							<h4>CGCM3_A2_y2090</h4>
							<div class="thumbnail-file-group-01">
								<a href="/climate/species/speciesDist/California-laurel/CGCM3_A2_y2090.png" title="Download larger PNG file"><img class="thumbnail" src="/climate/species/speciesDist/California-laurel/CGCM3_A2_y2090.tn.png" /></a>
							</div>
							<div class="thumbnail-file-group-02">
							<ul>
								<li><a href="/climate/species/speciesDist/California-laurel/CGCM3_A2_y2090.png" title="Download larger PNG file">Download "CGCM3_A2_y2090.png"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/CGCM3_A2_y2090.zip" title="Download ZIP file of ASCII grid files of maps">Download "CGCM3_A2_y2090.zip"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/CGCM3_A2_y2090.metadata.xml" title="Display metadata text file">Display "CGCM3_A2_y2090.metadata.xml"</a></li>
							</ul>
							</div>
						</div>
						<div class="thumbnail-file-group">
							<h4>CGCM3_B1_y2030</h4>
							<div class="thumbnail-file-group-01">
								<a href="/climate/species/speciesDist/California-laurel/CGCM3_B1_y2030.png" title="Download larger PNG file"><img class="thumbnail" src="/climate/species/speciesDist/California-laurel/CGCM3_B1_y2030.tn.png" /></a>
							</div>
							<div class="thumbnail-file-group-02">
							<ul>
								<li><a href="/climate/species/speciesDist/California-laurel/CGCM3_B1_y2030.png" title="Download larger PNG file">Download "CGCM3_B1_y2030.png"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/CGCM3_B1_y2030.zip" title="Download ZIP file of ASCII grid files of maps">Download "CGCM3_B1_y2030.zip"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/CGCM3_B1_y2030.metadata.xml" title="Display metadata text file">Display "CGCM3_B1_y2030.metadata.xml"</a></li>
							</ul>
							</div>
						</div>
						<div class="thumbnail-file-group">
							<h4>CGCM3_B1_y2060</h4>
							<div class="thumbnail-file-group-01">
								<a href="/climate/species/speciesDist/California-laurel/CGCM3_B1_y2060.png" title="Download larger PNG file"><img class="thumbnail" src="/climate/species/speciesDist/California-laurel/CGCM3_B1_y2060.tn.png" /></a>
							</div>
							<div class="thumbnail-file-group-02">
							<ul>
								<li><a href="/climate/species/speciesDist/California-laurel/CGCM3_B1_y2060.png" title="Download larger PNG file">Download "CGCM3_B1_y2060.png"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/CGCM3_B1_y2060.zip" title="Download ZIP file of ASCII grid files of maps">Download "CGCM3_B1_y2060.zip"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/CGCM3_B1_y2060.metadata.xml" title="Display metadata text file">Display "CGCM3_B1_y2060.metadata.xml"</a></li>
							</ul>
							</div>
						</div>
						<div class="thumbnail-file-group">
							<h4>CGCM3_B1_y2090</h4>
							<div class="thumbnail-file-group-01">
								<a href="/climate/species/speciesDist/California-laurel/CGCM3_B1_y2090.png" title="Download larger PNG file"><img class="thumbnail" src="/climate/species/speciesDist/California-laurel/CGCM3_B1_y2090.tn.png" /></a>
							</div>
							<div class="thumbnail-file-group-02">
							<ul>
								<li><a href="/climate/species/speciesDist/California-laurel/CGCM3_B1_y2090.png" title="Download larger PNG file">Download "CGCM3_B1_y2090.png"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/CGCM3_B1_y2090.zip" title="Download ZIP file of ASCII grid files of maps">Download "CGCM3_B1_y2090.zip"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/CGCM3_B1_y2090.metadata.xml" title="Display metadata text file">Display "CGCM3_B1_y2090.metadata.xml"</a></li>
							</ul>
							</div>
						</div>
						<div class="thumbnail-file-group">
							<h4>GFDLCM21_A2_y2030</h4>
							<div class="thumbnail-file-group-01">
								<a href="/climate/species/speciesDist/California-laurel/GFDLCM21_A2_y2030.png" title="Download larger PNG file"><img class="thumbnail" src="/climate/species/speciesDist/California-laurel/GFDLCM21_A2_y2030.tn.png" /></a>
							</div>
							<div class="thumbnail-file-group-02">
							<ul>
								<li><a href="/climate/species/speciesDist/California-laurel/GFDLCM21_A2_y2030.png" title="Download larger PNG file">Download "GFDLCM21_A2_y2030.png"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/GFDLCM21_A2_y2030.zip" title="Download ZIP file of ASCII grid files of maps">Download "GFDLCM21_A2_y2030.zip"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/GFDLCM21_A2_y2030.metadata.xml" title="Display metadata text file">Display "GFDLCM21_A2_y2030.metadata.xml"</a></li>
							</ul>
							</div>
						</div>
						<div class="thumbnail-file-group">
							<h4>GFDLCM21_A2_y2060</h4>
							<div class="thumbnail-file-group-01">
								<a href="/climate/species/speciesDist/California-laurel/GFDLCM21_A2_y2060.png" title="Download larger PNG file"><img class="thumbnail" src="/climate/species/speciesDist/California-laurel/GFDLCM21_A2_y2060.tn.png" /></a>
							</div>
							<div class="thumbnail-file-group-02">
							<ul>
								<li><a href="/climate/species/speciesDist/California-laurel/GFDLCM21_A2_y2060.png" title="Download larger PNG file">Download "GFDLCM21_A2_y2060.png"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/GFDLCM21_A2_y2060.zip" title="Download ZIP file of ASCII grid files of maps">Download "GFDLCM21_A2_y2060.zip"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/GFDLCM21_A2_y2060.metadata.xml" title="Display metadata text file">Display "GFDLCM21_A2_y2060.metadata.xml"</a></li>
							</ul>
							</div>
						</div>
						<div class="thumbnail-file-group">
							<h4>GFDLCM21_A2_y2090</h4>
							<div class="thumbnail-file-group-01">
								<a href="/climate/species/speciesDist/California-laurel/GFDLCM21_A2_y2090.png" title="Download larger PNG file"><img class="thumbnail" src="/climate/species/speciesDist/California-laurel/GFDLCM21_A2_y2090.tn.png" /></a>
							</div>
							<div class="thumbnail-file-group-02">
							<ul>
								<li><a href="/climate/species/speciesDist/California-laurel/GFDLCM21_A2_y2090.png" title="Download larger PNG file">Download "GFDLCM21_A2_y2090.png"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/GFDLCM21_A2_y2090.zip" title="Download ZIP file of ASCII grid files of maps">Download "GFDLCM21_A2_y2090.zip"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/GFDLCM21_A2_y2090.metadata.xml" title="Display metadata text file">Display "GFDLCM21_A2_y2090.metadata.xml"</a></li>
							</ul>
							</div>
						</div>
						<div class="thumbnail-file-group">
							<h4>GFDLCM21_B1_y2030</h4>
							<div class="thumbnail-file-group-01">
								<a href="/climate/species/speciesDist/California-laurel/GFDLCM21_B1_y2030.png" title="Download larger PNG file"><img class="thumbnail" src="/climate/species/speciesDist/California-laurel/GFDLCM21_B1_y2030.tn.png" /></a>
							</div>
							<div class="thumbnail-file-group-02">
							<ul>
								<li><a href="/climate/species/speciesDist/California-laurel/GFDLCM21_B1_y2030.png" title="Download larger PNG file">Download "GFDLCM21_B1_y2030.png"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/GFDLCM21_B1_y2030.zip" title="Download ZIP file of ASCII grid files of maps">Download "GFDLCM21_B1_y2030.zip"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/GFDLCM21_B1_y2030.metadata.xml" title="Display metadata text file">Display "GFDLCM21_B1_y2030.metadata.xml"</a></li>
							</ul>
							</div>
						</div>
						<div class="thumbnail-file-group">
							<h4>GFDLCM21_B1_y2060</h4>
							<div class="thumbnail-file-group-01">
								<a href="/climate/species/speciesDist/California-laurel/GFDLCM21_B1_y2060.png" title="Download larger PNG file"><img class="thumbnail" src="/climate/species/speciesDist/California-laurel/GFDLCM21_B1_y2060.tn.png" /></a>
							</div>
							<div class="thumbnail-file-group-02">
							<ul>
								<li><a href="/climate/species/speciesDist/California-laurel/GFDLCM21_B1_y2060.png" title="Download larger PNG file">Download "GFDLCM21_B1_y2060.png"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/GFDLCM21_B1_y2060.zip" title="Download ZIP file of ASCII grid files of maps">Download "GFDLCM21_B1_y2060.zip"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/GFDLCM21_B1_y2060.metadata.xml" title="Display metadata text file">Display "GFDLCM21_B1_y2060.metadata.xml"</a></li>
							</ul>
							</div>
						</div>
						<div class="thumbnail-file-group">
							<h4>GFDLCM21_B1_y2090</h4>
							<div class="thumbnail-file-group-01">
								<a href="/climate/species/speciesDist/California-laurel/GFDLCM21_B1_y2090.png" title="Download larger PNG file"><img class="thumbnail" src="/climate/species/speciesDist/California-laurel/GFDLCM21_B1_y2090.tn.png" /></a>
							</div>
							<div class="thumbnail-file-group-02">
							<ul>
								<li><a href="/climate/species/speciesDist/California-laurel/GFDLCM21_B1_y2090.png" title="Download larger PNG file">Download "GFDLCM21_B1_y2090.png"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/GFDLCM21_B1_y2090.zip" title="Download ZIP file of ASCII grid files of maps">Download "GFDLCM21_B1_y2090.zip"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/GFDLCM21_B1_y2090.metadata.xml" title="Display metadata text file">Display "GFDLCM21_B1_y2090.metadata.xml"</a></li>
							</ul>
							</div>
						</div>
						<div class="thumbnail-file-group">
							<h4>HADCM3_A2_y2030</h4>
							<div class="thumbnail-file-group-01">
								<a href="/climate/species/speciesDist/California-laurel/HADCM3_A2_y2030.png" title="Download larger PNG file"><img class="thumbnail" src="/climate/species/speciesDist/California-laurel/HADCM3_A2_y2030.tn.png" /></a>
							</div>
							<div class="thumbnail-file-group-02">
							<ul>
								<li><a href="/climate/species/speciesDist/California-laurel/HADCM3_A2_y2030.png" title="Download larger PNG file">Download "HADCM3_A2_y2030.png"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/HADCM3_A2_y2030.zip" title="Download ZIP file of ASCII grid files of maps">Download "HADCM3_A2_y2030.zip"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/HADCM3_A2_y2030.metadata.xml" title="Display metadata text file">Display "HADCM3_A2_y2030.metadata.xml"</a></li>
							</ul>
							</div>
						</div>
						<div class="thumbnail-file-group">
							<h4>HADCM3_A2_y2060</h4>
							<div class="thumbnail-file-group-01">
								<a href="/climate/species/speciesDist/California-laurel/HADCM3_A2_y2060.png" title="Download larger PNG file"><img class="thumbnail" src="/climate/species/speciesDist/California-laurel/HADCM3_A2_y2060.tn.png" /></a>
							</div>
							<div class="thumbnail-file-group-02">
							<ul>
								<li><a href="/climate/species/speciesDist/California-laurel/HADCM3_A2_y2060.png" title="Download larger PNG file">Download "HADCM3_A2_y2060.png"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/HADCM3_A2_y2060.zip" title="Download ZIP file of ASCII grid files of maps">Download "HADCM3_A2_y2060.zip"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/HADCM3_A2_y2060.metadata.xml" title="Display metadata text file">Display "HADCM3_A2_y2060.metadata.xml"</a></li>
							</ul>
							</div>
						</div>
						<div class="thumbnail-file-group">
							<h4>HADCM3_A2_y2090</h4>
							<div class="thumbnail-file-group-01">
								<a href="/climate/species/speciesDist/California-laurel/HADCM3_A2_y2090.png" title="Download larger PNG file"><img class="thumbnail" src="/climate/species/speciesDist/California-laurel/HADCM3_A2_y2090.tn.png" /></a>
							</div>
							<div class="thumbnail-file-group-02">
							<ul>
								<li><a href="/climate/species/speciesDist/California-laurel/HADCM3_A2_y2090.png" title="Download larger PNG file">Download "HADCM3_A2_y2090.png"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/HADCM3_A2_y2090.zip" title="Download ZIP file of ASCII grid files of maps">Download "HADCM3_A2_y2090.zip"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/HADCM3_A2_y2090.metadata.xml" title="Display metadata text file">Display "HADCM3_A2_y2090.metadata.xml"</a></li>
							</ul>
							</div>
						</div>
						<div class="thumbnail-file-group">
							<h4>HADCM3_B2_y2030</h4>
							<div class="thumbnail-file-group-01">
								<a href="/climate/species/speciesDist/California-laurel/HADCM3_B2_y2030.png" title="Download larger PNG file"><img class="thumbnail" src="/climate/species/speciesDist/California-laurel/HADCM3_B2_y2030.tn.png" /></a>
							</div>
							<div class="thumbnail-file-group-02">
							<ul>
								<li><a href="/climate/species/speciesDist/California-laurel/HADCM3_B2_y2030.png" title="Download larger PNG file">Download "HADCM3_B2_y2030.png"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/HADCM3_B2_y2030.zip" title="Download ZIP file of ASCII grid files of maps">Download "HADCM3_B2_y2030.zip"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/HADCM3_B2_y2030.metadata.xml" title="Display metadata text file">Display "HADCM3_B2_y2030.metadata.xml"</a></li>
							</ul>
							</div>
						</div>
						<div class="thumbnail-file-group">
							<h4>HADCM3_B2_y2060</h4>
							<div class="thumbnail-file-group-01">
								<a href="/climate/species/speciesDist/California-laurel/HADCM3_B2_y2060.png" title="Download larger PNG file"><img class="thumbnail" src="/climate/species/speciesDist/California-laurel/HADCM3_B2_y2060.tn.png" /></a>
							</div>
							<div class="thumbnail-file-group-02">
							<ul>
								<li><a href="/climate/species/speciesDist/California-laurel/HADCM3_B2_y2060.png" title="Download larger PNG file">Download "HADCM3_B2_y2060.png"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/HADCM3_B2_y2060.zip" title="Download ZIP file of ASCII grid files of maps">Download "HADCM3_B2_y2060.zip"</a></li>
								<li><a href="/climate/species/speciesDist/California-laurel/HADCM3_B2_y2060.metadata.xml" title="Display metadata text file">Display "HADCM3_B2_y2060.metadata.xml"</a></li>
							</ul>
							</div>
						</div>
		
						
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