<?php
require("../../shared_web/resources.php");
require("../../shared_web/resources_climate.php");
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
<meta name="description" content="Details of Data/Methods Used for Future Climate Estimates and Potential Impacts of Global Warming Scenarios in Western North America and Mexico." />
<meta name="keywords" content="methods, climate, climate estimates, predictions, plant and climate relationships, global warming, global warming scenarios, predicting global warming, " />
<title>Details of Data/Methods Used for Future Climate Estimates</title>
<?php
include ($_SERVER["DOCUMENT_ROOT"]."/".$shared_directory."/stylesheets.php");
?>
</head>

<body class="subpage-tier01">

<?php
include($_SERVER["DOCUMENT_ROOT"]."/".$shared_directory."/left_nav.php");
?>
<div id="pagewrapper01" class="future-details">
    <div id="main01">
        <div id="row01">
            <div id="section02">
                <div class="contentbox01">
                	<h1><span class="umbrella-title">Climate Estimates and Plant-Climate Relationships</span> <br />
                    Details of Data and Methods Used for Calculating Future Climate Estimates</h1>
					<ul class="breadcrumb-nav">
						<li><a href="<?php echo ("".$home_URL.""); ?>/">Moscow Home</a> &gt; </li>
						<li><a href="<?php echo ("".$home_climate_URL.""); ?>/">Climate</a> &gt; </li>
						<li><a href="<?php echo ("".$home_climate_URL.""); ?>/future/">Future Climate Estimates</a> &gt; </li>
						<li><strong>Details of Data/Methods Used</strong></li>
					</ul>

					<h2>Introduction</h2>
					<p>This document describes how we computed future climates, including references to the General Circulation Models (GCM) and scenarios we used, our naming convention, and the computational details.</p>
					<p>Our basic approach is to first fit an <a href="https://fennerschool.anu.edu.au/research/software-datasets/anusplin">ANUSPIN</a> surface to 1961 to 1990 climate normals. For the future climate, we updated our climate normal data to reflect changes predicted by GCM outputs. We then refit the ANUSPLIN surfaces to the updated climates. This approach provides climate surfaces for each scenario and time period. Point predictions then can be made from these surfaces. The results can be considered a downscaling of GCM outputs or they can be considered a prediction of future climate.</p>
					<p>We have three generations of climate surfaces that were developed using about the same procedures. The first delt with the "westUS" extent and was built with the mean of the green house gas scinario of the Canadian and Hadley GCMs; they were used by <a href="https://www.fs.fed.us/rm/pubs_other/rmrs_2006_rehfeldt_g001.pdf">Rehfeldt et al. (2006).</a> The second considers three GCMs and the A and B scenarios (SRES) used in the<a href="https://en.wikipedia.org/wiki/IPCC_Third_Assessment_Report"> third IPCC assessment</a>. The third is based on GCM model runs used to support the fifth assessment: <a href="https://cmip-pcmdi.llnl.gov/cmip5/">IPCC/CMIP5 AR5</a>. These models were run for various<a href="https://sedac.ciesin.columbia.edu/ddc/ar5_scenario_process/RCPs.html"> Representative Concentration Pathways (RCP)</a>; we looked at rcp4.5, rcp6.0, and rcp8.5.</p>
					<p>Please note that we are grateful for the use of the data from the climate model centers. Their work made our work possible. Also, note that while we use the center and scenario names in our naming conventions, the files available from this site are not the GCM outputs from the respective centers. They are data we derived from their data and other data using the methods described below, under "Processing steps".</p>

					<h2>GCMs, scenarios, and data files used for our second generation surfaces (based on AR3/SRES):</h2>
					<ol>
						<li><a href="https://www.cccma.ec.gc.ca/models/cgcm3.shtml">CGCM3 from the Canadian Center for Climate Modeling and Analysis</a> <br /><br />
							This model is run at two resolutions, we used the T63 version with a 2.8 degrees resolution (in the first generation work, the T47 version was used). We used three scenarios, <strong>sresA1B</strong>, <strong>sresA2</strong>, and <strong>sresB1</strong>, by processing the following data sets:
							<ul>
								<li><h3>For the climate normal we used <a href="https://www.cccma.ec.gc.ca/data/cgcm3/cgcm3_t63_20c3m.shtml">20C3M</a>:</h3>
									<ul>
										<li>pr_a2_20c3m_1_cgcm3.1_t63_1961_2000.nc</li>
										<li>tas_a2_20c3m_1_cgcm3.1_t63_1961_2000.nc</li>
										<li>tasmax_a2_20c3m_1_cgcm3.1_t63_1961_2000.nc</li>
										<li>tasmin_a2_20c3m_1_cgcm3.1_t63_1961_2000.nc</li>
									</ul>
								</li>
								<li><h3>For scenario <a href="https://www.cccma.ec.gc.ca/data/cgcm3/cgcm3_t63_sresa1b.shtml">sresA1B</a> we used:</h3>
									<ul>
										<li>pr_a1_sresa1b_1_cgcm3[1].1_t63_2001_2100.nc</li>
										<li>tas_a1_sresa1b_1_cgcm3[1].1_t63_2001_2100.nc</li>
										<li>tasmax_a2_sresa1b_1_cgcm3[1].1_t63_2001_2050.nc</li>
										<li>tasmax_a2_sresa1b_1_cgcm3[1].1_t63_2051_2100.nc</li>
										<li>tasmin_a2_sresa1b_1_cgcm3[1].1_t63_2001_2050.nc</li>
										<li>tasmin_a2_sresa1b_1_cgcm3[1].1_t63_2051_2100.nc</li>
									</ul>
								</li>
								<li><h3>For scenario <a href="https://www.cccma.ec.gc.ca/data/cgcm3/cgcm3_t63_sresa2.shtml">sresA2</a> we used:</h3>
									<ul>
										<li>pr_a1_sresa2_1_cgcm3[1].1_t63_2001_2100.nc</li>
										<li>tas_a1_sresa2_1_cgcm3[1].1_t63_2001_2100.nc</li>
										<li>tasmax_a2_sresa2_1_cgcm3[1].1_t63_2001_2050.nc</li>
										<li>tasmax_a2_sresa2_1_cgcm3[1].1_t63_2051_2100.nc</li>
										<li>tasmin_a2_sresa2_1_cgcm3[1].1_t63_2001_2050.nc</li>
										<li>tasmin_a2_sresa2_1_cgcm3[1].1_t63_2051_2100.nc</li>
									</ul>
								</li>
								<li><h3>For scenario <a href="https://www.cccma.ec.gc.ca/data/cgcm3/cgcm3_t63_sresb1.shtml">sresB1</a> we used:</h3>
									<ul>
										<li>pr_a1_sresb1_1_cgcm3.1_t63_2001_2100.nc</li>
										<li>tas_a1_sresb1_1_cgcm3.1_t63_2001_2100.nc</li>
										<li>tasmax_a2_sresb1_1_cgcm3[1].1_t63_2001_2050.nc</li>
										<li>tasmax_a2_sresb1_1_cgcm3[1].1_t63_2051_2100.nc</li>
										<li>tasmin_a2_sresb1_1_cgcm3[1].1_t63_2001_2050.nc</li>
										<li>tasmin_a2_sresb1_1_cgcm3[1].1_t63_2051_2100.nc</li>
									</ul>
								</li>
							</ul>
						</li>
						<li><a href="https://www.metoffice.gov.uk/research/hadleycentre/">HadCM3 is from the Hadley Center</a>; we got the data we used from the <a href="https://cera-www.dkrz.de/CERA/">World Data Center</a>. We used two scenarios, <strong>A2</strong> and <strong>B2</strong>, by processing the following data sets:
							<ul>
								<li>HADCM3_A2_tmin.grb</li>
								<li>HADCM3_A2_tmax.grb</li>
								<li>HADCM3_A2_temp.grb</li>
								<li>HADCM3_A2_prec.grb</li>
								<li>HADCM3_B2_tmin.grb</li>
								<li>HADCM3_B2_tmax.grb</li>
								<li>HADCM3_B2_temp.grb</li>
								<li>HADCM3_B2_prec.grb</li>
							</ul>
						</li>
						<li><a href="https://data1.gfdl.noaa.gov/">GFDL CM2.1</a> is from the <a href="https://www.gfdl.noaa.gov/">Geophysical Fluid Dynamics Laboratory</a>. We used two scenarios, <strong>A2</strong> and <strong>B1</strong>, by processing the following data sets:
							<ul>
								<li><h3>For the climate normal period, we used these data:</h3>
									<ul>
										<li>CM2.1U-D4_1860-2000-AllForc_H2/pp/atmos/ts/monthly/tas_A1.186101-200012.nc</li>
										<li>CM2.1U-D4_1860-2000-AllForc_H2/pp/atmos/ts/monthly/pr_A1.186101-200012.nc</li>
										<li>CM2.1U-D4_1860-2000-AllForc_H2/pp/atmos/ts/daily/tasmax_A2.19660101-19701231.nc</li>
										<li>CM2.1U-D4_1860-2000-AllForc_H2/pp/atmos/ts/daily/tasmax_A2.19710101-19751231.nc</li>
										<li>CM2.1U-D4_1860-2000-AllForc_H2/pp/atmos/ts/daily/tasmax_A2.19760101-19801231.nc</li>
										<li>CM2.1U-D4_1860-2000-AllForc_H2/pp/atmos/ts/daily/tasmax_A2.19810101-19851231.nc</li>
										<li>CM2.1U-D4_1860-2000-AllForc_H2/pp/atmos/ts/daily/tasmax_A2.19860101-19901231.nc</li>
										<li>CM2.1U-D4_1860-2000-AllForc_H2/pp/atmos/ts/daily/tasmin_A2.19610101-19651231.nc</li>
										<li>CM2.1U-D4_1860-2000-AllForc_H2/pp/atmos/ts/daily/tasmin_A2.19660101-19701231.nc</li>
										<li>CM2.1U-D4_1860-2000-AllForc_H2/pp/atmos/ts/daily/tasmin_A2.19710101-19751231.nc</li>
										<li>CM2.1U-D4_1860-2000-AllForc_H2/pp/atmos/ts/daily/tasmin_A2.19760101-19801231.nc</li>
										<li>CM2.1U-D4_1860-2000-AllForc_H2/pp/atmos/ts/daily/tasmin_A2.19810101-19851231.nc</li>
										<li>CM2.1U-D4_1860-2000-AllForc_H2/pp/atmos/ts/daily/tasmin_A2.19860101-19901231.nc</li>
									</ul>
								</li>
								<li><h3>For <strong>SresA2</strong> we used:</h3>
									<ul>
										<li>CM2.1U-H2_SresA2_W1/pp/atmos/ts/monthly/pr_A1.200101-210012.nc</li>
										<li>CM2.1U-H2_SresA2_W1/pp/atmos/ts/monthly/tas_A1.200101-210012.nc</li>
										<li>CM2.1U-H2_SresA2_W1/pp/atmos/ts/daily/tasmax_A2.20260101-20301231.nc</li>
										<li>CM2.1U-H2_SresA2_W1/pp/atmos/ts/daily/tasmax_A2.20310101-20351231.nc</li>
										<li>CM2.1U-H2_SresA2_W1/pp/atmos/ts/daily/tasmax_A2.20560101-20601231.nc</li>
										<li>CM2.1U-H2_SresA2_W1/pp/atmos/ts/daily/tasmax_A2.20610101-20651231.nc</li>
										<li>CM2.1U-H2_SresA2_W1/pp/atmos/ts/daily/tasmax_A2.20860101-20901231.nc</li>
										<li>CM2.1U-H2_SresA2_W1/pp/atmos/ts/daily/tasmax_A2.20910101-20951231.nc</li>
										<li>CM2.1U-H2_SresA2_W1/pp/atmos/ts/daily/tasmin_A2.20260101-20301231.nc</li>
										<li>CM2.1U-H2_SresA2_W1/pp/atmos/ts/daily/tasmin_A2.20310101-20351231.nc</li>
										<li>CM2.1U-H2_SresA2_W1/pp/atmos/ts/daily/tasmin_A2.20560101-20601231.nc</li>
										<li>CM2.1U-H2_SresA2_W1/pp/atmos/ts/daily/tasmin_A2.20610101-20651231.nc</li>
										<li>CM2.1U-H2_SresA2_W1/pp/atmos/ts/daily/tasmin_A2.20860101-20901231.nc</li>
										<li>CM2.1U-H2_SresA2_W1/pp/atmos/ts/daily/tasmin_A2.20910101-20951231.nc</li>
									</ul>
								</li>
								<li><h3>For <strong>SresB1</strong> we used:</h3>
									<ul>
										<li>CM2.1U-H2_SresB1_Y1/pp/atmos/ts/monthly/pr_A1.200101-210012.nc</li>
										<li>CM2.1U-H2_SresB1_Y1/pp/atmos/ts/monthly/tas_A1.200101-210012.nc</li>
										<li>CM2.1U-H2_SresB1_Y1/pp/atmos/ts/daily/tasmax_A2.20260101-20301231.nc</li>
										<li>CM2.1U-H2_SresB1_Y1/pp/atmos/ts/daily/tasmax_A2.20310101-20351231.nc</li>
										<li>CM2.1U-H2_SresB1_Y1/pp/atmos/ts/daily/tasmax_A2.20560101-20601231.nc</li>
										<li>CM2.1U-H2_SresB1_Y1/pp/atmos/ts/daily/tasmax_A2.20610101-20651231.nc</li>
										<li>CM2.1U-H2_SresB1_Y1/pp/atmos/ts/daily/tasmax_A2.20860101-20901231.nc</li>
										<li>CM2.1U-H2_SresB1_Y1/pp/atmos/ts/daily/tasmax_A2.20910101-20951231.nc</li>
										<li>CM2.1U-H2_SresB1_Y1/pp/atmos/ts/daily/tasmin_A2.20260101-20301231.nc</li>
										<li>CM2.1U-H2_SresB1_Y1/pp/atmos/ts/daily/tasmin_A2.20310101-20351231.nc</li>
										<li>CM2.1U-H2_SresB1_Y1/pp/atmos/ts/daily/tasmin_A2.20560101-20601231.nc</li>
										<li>CM2.1U-H2_SresB1_Y1/pp/atmos/ts/daily/tasmin_A2.20610101-20651231.nc</li>
										<li>CM2.1U-H2_SresB1_Y1/pp/atmos/ts/daily/tasmin_A2.20860101-20901231.nc</li>
										<li>CM2.1U-H2_SresB1_Y1/pp/atmos/ts/daily/tasmin_A2.20910101-20951231.nc</li>
									</ul>
								</li>
							</ul>
						</li>
					</ol>

					<h2>GCMs, RCPs, and data used for our third generation surfaces (based on CMIP5 AR5).</h2> <br />
					
					<ol>
						<li>
						<a href=\"https://www.cesm.ucar.edu/models/ccsm4.0/\">CCSM4: The Community Earth System Model</a><br />

									<ul>
										<li>pr_Amon_CCSM4_historical_r1i1p1_185001-200512.nc</li>
										<li>tasmax_Amon_CCSM4_historical_r1i1p1_185001-200512.nc</li>
										<li>tasmin_Amon_CCSM4_historical_r1i1p1_185001-200512.nc</li>
										<li>pr_Amon_CCSM4_rcp45_r1i1p1_200601-210012.nc</li>
										<li>tasmax_Amon_CCSM4_rcp45_r1i1p1_200601-210012.nc</li>
										<li>tasmin_Amon_CCSM4_rcp45_r1i1p1_200601-210012.nc</li>
										<li>pr_Amon_CCSM4_rcp60_r1i1p1_200601-210012.nc</li>
										<li>tasmax_Amon_CCSM4_rcp60_r1i1p1_200601-210012.nc</li>
										<li>tasmin_Amon_CCSM4_rcp60_r1i1p1_200601-210012.nc</li>
										<li>pr_Amon_CCSM4_rcp85_r1i1p1_200601-210012.nc</li>
										<li>tasmax_Amon_CCSM4_rcp85_r1i1p1_200601-210012.nc</li>
										<li>tasmin_Amon_CCSM4_rcp85_r1i1p1_200601-210012.nc</li>
									</ul>
						
						</li>
						<li>
					  <a href=\"https://www.gfdl.noaa.gov/news-app/story.32/title.the-gfdl-cm3-model/menu.no/sec./home.\">GFDLCM3: Geophysical Fluid Dynamics Laboratory</a> <br />Note: there are too many files to list here, the * represents the appropriate date range.

									<ul>
										<li>pr_Amon_GFDL-CM3_historical_r1i1p1_*.nc</li>
										<li>tasmax_Amon_GFDL-CM3_historical_r1i1p1_*.nc</li>
										<li>tasmin_Amon_GFDL-CM3_historical_r1i1p1_*.nc</li>
										<li>pr_Amon_GFDL-CM3_rcp45_r1i1p1_*.nc</li>
										<li>tasmax_Amon_GFDL-CM3_rcp45_r1i1p1_*.nc</li>
										<li>tasmin_Amon_GFDL-CM3_rcp45_r1i1p1_*.nc</li>
										<li>pr_Amon_GFDL-CM3_rcp60_r1i1p1_*.nc</li>
										<li>tasmax_Amon_GFDL-CM3_rcp60_r1i1p1_*.nc</li>
										<li>tasmin_Amon_GFDL-CM3_rcp60_r1i1p1_*.nc</li>
										<li>pr_Amon_GFDL-CM3_rcp85_r1i1p1_*.nc</li>
										<li>tasmax_Amon_GFDL-CM3_rcp85_r1i1p1_*.nc</li>
										<li>tasmin_Amon_GFDL-CM3_rcp85_r1i1p1_*.nc</li>
									</ul>
					 
					 <li>
<a href=\"https://www.metoffice.gov.uk/research/modelling-systems/unified-model/climate-models/hadgem2\">HadGEM2ES: Met Office (UK)</a></td><br />Note: there are too many files to list here, the * represents the appropriate date range.

									<ul>
										<li>pr_Amon_HadGEM2-ES_historical_r1i1p1_*.nc</li>
										<li>tasmax_Amon_HadGEM2-ES_historical_r1i1p1_*.nc</li>
										<li>tasmin_Amon_HadGEM2-ES_historical_r1i1p1_*.nc</li>
										<li>pr_Amon_HadGEM2-ES_rcp45_r1i1p1_*.nc</li>
										<li>tasmax_Amon_HadGEM2-ES_rcp45_r1i1p1_*.nc</li>
										<li>tasmin_Amon_HadGEM2-ES_rcp45_r1i1p1_*.nc</li>
										<li>pr_Amon_GFDL-HadGEM2-ES_r1i1p1_*.nc</li>
										<li>tasmax_Amon_HadGEM2-ES_rcp60_r1i1p1_*.nc</li>
										<li>tasmin_Amon_HadGEM2-ES_rcp60_r1i1p1_*.nc</li>
										<li>pr_Amon_GFDL-HadGEM2-ES_r1i1p1_*.nc</li>
										<li>tasmax_Amon_HadGEM2-ES_rcp85_r1i1p1_*.nc</li>
										<li>tasmin_Amon_HadGEM2-ES_rcp85_r1i1p1_*.nc</li>

									</ul>
						
						</li>

					 <li>
<a href=\"https://www.cesm.ucar.edu/experiments/cesm1.0\">CESM1BGC: NCAR/UCAR Boulder</a></td><br />

									<ul>
										<li>pr_Amon_CESM1-BGC_historical_r1i1p1_185001-200512.nc</li>
										<li>tasmax_Amon_CESM1-BGC_historical_r1i1p1_185001-200512.nc</li>
										<li>tasmin_Amon_CESM1-BGC_historical_r1i1p1_185001-200512.nc</li>
										<li>pr_Amon_CESM1-BGC_rcp45_r1i1p1_200601-210012.nc</li>
										<li>tasmax_Amon_CESM1-BGC_rcp45_r1i1p1_200601-210012.nc</li>
										<li>tasmin_Amon_CESM1-BGC_rcp45_r1i1p1_200601-210012.nc</li>
										<li>pr_Amon_CESM1-BGC_rcp85_r1i1p1_200601-210012.nc</li>
										<li>tasmax_Amon_CESM1-BGC_rcp85_r1i1p1_200601-210012.nc</li>
										<li>tasmin_Amon_CESM1-BGC_rcp85_r1i1p1_200601-210012.nc</li>
										
									</ul>
						
						</li>

					 <li>
<a href=\"https://www.cnrm.meteo.fr/cmip5/\">CNRMCM5: METEO France</a></td><br />
									<ul>
										<li>pr_Amon_CNRM-CM5_historical_r1i1p1_195001-200512.nc</li>
										<li>tasmax_Amon_CNRM-CM5_historical_r1i1p1_195001-200512.nc</li>
										<li>tasmin_Amon_CNRM-CM5_historical_r1i1p1_195001-200512.nc</li>
										<li>pr_Amon_CNRM-CM5_rcp45_r1i1p1_200601-205512.nc</li>
										<li>pr_Amon_CNRM-CM5_rcp45_r1i1p1_205601-210012.nc</li>
										<li>tasmax_Amon_CNRM-CM5_rcp45_r1i1p1_200601-205512.nc</li>
										<li>tasmax_Amon_CNRM-CM5_rcp45_r1i1p1_205601-210012.nc</li>
										<li>tasmin_Amon_CNRM-CM5_rcp45_r1i1p1_200601-205512.nc</li>
										<li>tasmin_Amon_CNRM-CM5_rcp45_r1i1p1_205601-210012.nc</li>
										<li>pr_Amon_CNRM-CM5_rcp85_r1i1p1_200601-205512.nc</li>
										<li>pr_Amon_CNRM-CM5_rcp85_r1i1p1_205601-210012.nc</li>
										<li>tasmax_Amon_CNRM-CM5_rcp85_r1i1p1_200601-205512.nc</li>
										<li>tasmax_Amon_CNRM-CM5_rcp85_r1i1p1_205601-210012.nc</li>
										<li>tasmin_Amon_CNRM-CM5_rcp85_r1i1p1_200601-205512.nc</li>
										<li>tasmin_Amon_CNRM-CM5_rcp85_r1i1p1_205601-210012.nc</li>
										
									</ul>						
						</li>

						<li>
						Our <strong>Ensemble</strong> of 17 models is based on data from the following models.  

									<ul>
										<li>BCC-CSM1-1</li>
										<li>CCSM4</li>
										<li>CESM1-CAM5</li>
										<li>CSIRO-Mk3-6-0</li>
										<li>FIO-ESM</li>
										<li>GFDL-CM3</li>
										<li>GFDL-ESM2G</li>
										<li>GFDL-ESM2M</li>
										<li>GISS-E2-R</li>
										<li>HadGEM2-AO</li>
										<li>HadGEM2-ES</li>
										<li>IPSL-CM5A-LR</li>
										<li>MIROC5</li>
										<li>MIROC-ESM-CHEM</li>
										<li>MIROC-ESM</li>
										<li>MRI-CGCM3</li>
										<li>NorESM1-M</li>
									</ul>
						
						</li>

					</ol>
					
					<h2>Processing steps:</h2>
					<ol>
						<li>For each GCM we calculated mean monthly values corresponding to the 1961-1990 normals. For HadCM3 (second generation) this was done once for each scenario data set. For CGCM3 (second generation), we used data from experiment 20C3M, and for the GFDL we used the 1961-1990 portion of the 1860 to 2000 data listed above. For the third generation, we used the data as listed above and marked "historical". That pattern follows for all of the models in the <strong>Ensemble</strong>.</li> 
						
						<li>Another difference between the second and third generations of our work is how we computed <strong>tas</strong>. In the second generation this variable was processed as input from the GCM model data. In the third generation, this variable is the mean of tasmin and tasmax.</li>
						
						<li>For each GCM center and scenario, we computed monthly averages that correspond to the nominal decades of 2030, 2060, and 2090. For the Canadian center and for GFDLCM2, we used 10 year averages: for 2030 the period is 2026 to 2035, and so on. For HadCM3 we used 2025 to 2036 for an 11 year average. We do not consider the difference in methods to be material to the results; the reason they are different has to do with minutia of our work flow. For the third generation work, we consistently used 10 year averages.</li>
						
						<li>For each monthly mean at each time period, we calculated deltas. They are the difference between the future climate and that of the normal period. For temperatures the deltas are absolute differences and for precipitation they are proportions.</li>
						<li>For each weather station (our observed normal data), we computed an updated value for each attribute and for each scenario. Updating weather stations means was done by:
							<ol>
								<li>Selecting a set of GCM grid cells that surrounded a weather station. In the second generation work, the number of grid cells selected was such that all cell centers lying within 400 km of the station were included. In the third generation, the GCM cell that contained the weather station was selected and all eight cells that surround that cell were also selected. </li>
								<li>Calculating the distance from the station location to the center each grid cell in the candidate set using great-circle distance. These calculations were done in <a href="https://cran.r-project.org/">R</a>, using <a href="https://cran.r-project.org/src/contrib/Descriptions/sp.html"> Roger Bivand's function spDistsN1 in package sp</a>.</li>
								<li>Calculating a weights for the distance as 1/((<i>d</i>+1)^2), were <i>d</i> is the distance in km.</li>
								<li>Updating the station data using a GCM cell mean weighted by the weights computed in step d.</li>
							</ol>
						</li>
						<li>Once the station's measured attributes (monthly max, min, and average temperatures, plus precipitation) were updated to reflect the changes predicted for each GCM's, scenario, and future time period, new ANUSPLIN surfaces were computed.</li>
						<li>For the <strong>Ensemble</strong>, the means of the 17 updated station's measured attributes were computed and the new ANUSPLIN surfaces were then computed.</li>						
					</ol>
					
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
