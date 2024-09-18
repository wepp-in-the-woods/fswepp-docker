<?php
require("../../shared_web/resources.php");
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
<meta name="description" content="Priest River Experimental Forest - Datasets" />
<meta name="keywords" contest="Datasets, experimental forest, experimental forests, Priest River Experimental Forest, Priest River" />
<title>Priest River Experimental Forest - Datasets</title>
<?php
include ($_SERVER["DOCUMENT_ROOT"]."/".$shared_directory."/stylesheets.php");
?>
</head>

<body class="home">

<?php
include($_SERVER["DOCUMENT_ROOT"]."/".$shared_directory."/left_nav.php");
?>
<div id="pagewrapper01" class="ef">
    <div id="main01">
        <div id="row01">
            <div id="section02">
                <div class="contentbox01">
                	<h1><span class="umbrella-title">Experimental Forests</span> <br />
                    Priest River Experimental Forest - Datasets</h1>
					<ul class="breadcrumb-nav">
						<li><a href="<?php echo ("".$home_URL.""); ?>/">Moscow Home</a> &gt; </li>
						<li><a href="<?php echo ("".$home_URL.""); ?>/ef/pref/index.php">Priest River Experimental Forest</a> &gt; </li>
						<li><strong>Datasets</strong></li>
					</ul>
					<ul class="subsite-nav">
						<li><a href="index.php">Introduction</a> |</li>
						<li><a href="pref_facilities.php">Facilities</a> |</li>
						<li><a href="pref_climate.php">Climate</a> |</li>
						<li><a href="pref_soils.php">Soils</a> |</li>
						<li><a href="pref_vegetation.php">Vegetation</a> |</li>
						<li><a href="pref_aquatic.php">Aquatic</a> |</li>
						<li><a href="pref_research.php">Research</a> |</li>
						<li><a href="pref_references.php">References</a> |</li>
						<li><strong>Datasets</strong></li>
					</ul>
					<p>The climatic, hydrological, and atmospheric data sets collected at PREF are public domain and available to interested parties. Raw data are archived at PREF and the Moscow Forestry Sciences Lab and is also available at several websites:</p>
					<h2>Control Weather Station (CWS):</h2>
					<p>Data (11/27/1911 to 12/31/2005) are available from several websites, under Priest River Experimental Station, ID # 107386:</p>
					<ul>
						<li><b>University of Idaho's</b> "Interactive Numeric &amp; Spatial Information and Data Engine" is a comprehensive source, having daily observations of min/max temp, precipitation, snowfall, etc. See: <a href="https://inside.uidaho.edu/asp/dates.asp?stations=107386">inside.uidaho.edu/asp/dates.asp?stations=107386</a>, select the dates of interest, and then the parameters of interest.</li>
						<li><b>Western Regional Climate Center</b> has monthly averages and station metadata. Go to <a href="https://www.wrcc.dri.edu/cgi-bin/cliMAIN.pl?idprie">www.wrcc.dri.edu/cgi-bin/cliMAIN.pl?idprie</a>. </li>
					</ul>

					<h2>Snow Pack data sets:</h2> 
					<p>(WY 1937 to present) are available for the Benton Meadow (elev. 2380 ft, 725 m) and Benton Spring (elev. 4775 ft, 1455 m) snowcourses:</p>
					<ul>
						<li><strong>Natural Resource Conservation Service (NRCS)</strong> has the full record for both snowcourses. See: <a href="https://www.wcc.nrcs.usda.gov/cgibin/state-site.pl?state=ID&report=snowcourse">www.wcc.nrcs.usda.gov/cgibin/state-site.pl?state=ID&report=snowcourse</a> and select the snow course of interest (Benton Meadow or Benton Spring).</li>
					</ul>

					<h2>Atmospheric Chemistry:</h2>
					<p>National Atmospheric Deposition Program (NADP) site was established in PREF on December 31, 2002. The site reference is <strong>ID02</strong>. Data can be found at the NADP web page at: <a href="https://nadp.sws.uiuc.edu/sites/siteinfo.asp?net=NTN&id=ID02">nadp.sws.uiuc.edu/sites/siteinfo.asp?net=NTN&id=ID02</a>.</p>

					<h2>Precipitation:</h2>
					<ul>
						<li>Benton Spring (elev. 4725 ft, 1440 m), monthly observations, transcribed into Excel spreadsheets from 1961 to present.</li>
						<li>Benton gaging dam (elev. 2640 ft, 805 m), recording rain gauge stripcharts and spreadsheets of monthly totals, beginning from 1961 to present.</li>
					</ul>
					<h2>Hydrographs from Benton gaging dam:</h2>
					<p>Digitized gage heights from 1955 to 1964, and 1976 to 1997. Electronic data have been collected from 1997 to the present. Efforts are now underway to complete the digitizing of all available paper records from the dam, precipitation gages and climate variables from the Benton Creek watershed. (<a href="ftp://forest.moscowfsl.wsu.edu/water/benton/" target="_ftp">LINK TO FTP SITE</a>)</p>
					<h2>Tree growth data:</h2>
					<p>available from permanent growth and yield plots, 1914 to present.</p>

					<iframe src="pref_dat_01.php" frameborder="0" width="630" height="300">
					</iframe>

					<div class="footer-information">
						<p><strong>Contact:</strong> Bob Denner <a href="javascript:document.bdenner.submit()"><img src="../../images/mail.gif" border="0" width="32" height="21" alt="email Bob" /></a>
						or 
						Russell T. Graham <a href="javascript:document.rgraham.submit()"><img src="../../images/mail.gif" border="0" width="32" height="21" alt="email Russell" /></a></p>
						<p><strong>Priest River Experimental Forest</strong> <br />
						c/o Rocky Mountain Research Station<br />
						1221 South Main Street<br />
						Moscow, ID 83843-4211<br />
						<strong>Phone:</strong> (208) 882-3557</p>
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
