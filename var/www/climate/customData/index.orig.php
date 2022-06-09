<?php
require("../../shared_web/resources.php");
require("../../shared_web/resources_climate.php");
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
<meta name="description" content="Custom Data Requests for Mexico and Western North America." />
<meta name="keywords" content="data requests, climate, climate estimates, predictions, plant and climate relationships, global warming, global warming scenarios, predicting global warming, " />
<title>Custom Data Requests</title>
<?php
include ($_SERVER["DOCUMENT_ROOT"]."/".$shared_directory."/stylesheets.php");
?>
</head>

<body class="climate">

<?php
include($_SERVER["DOCUMENT_ROOT"]."/".$shared_directory."/left_nav.php");
?>
<div id="pagewrapper01" class="customData">
    <div id="main01">
        <div id="row01">
            <div id="section02">
                <div class="contentbox01">
                  <h1><span class="umbrella-title">Climate Estimates and Plant-Climate Relationships</span> <br />
                    Custom Climate Data Requests</h1>
          <ul class="breadcrumb-nav">
            <li><a href="<?php echo ("".$home_URL.""); ?>/">Moscow Home</a> &gt; </li>
            <li><a href="<?php echo ("".$home_climate_URL.""); ?>/">Climate</a> &gt; </li>
            <li><strong>Custom Data Requests</strong></li>
          </ul>
                
          <h2>Introduction</h2>
          <p>You can select specific data elements and get a zip file that contains the data you request. See <a href="<?php echo ("".$home_climate_URL.""); ?>/details.php">Details on Spatial Extents, Temporal Information and Data Elements</a> to gain an understanding what is available here. Note that the target user community for this web site is focused on analysts with computer experience and a general knowledge of climate data.</p>
          <p><strong>NOTE: Climate-FVS ready data should be requested on the <a href="<?php echo ("".$home_climate_URL.""); ?>/customData/fvs_data.php">Climate-FVS Ready Data page</a>.</strong></p>
          <p><strong>NOTE: Para los que hablan español: <a href="http://forest.moscowfsl.wsu.edu/climate/ManualZonification.pdf"> <i> Manual de Zonificación Ecológica de Especies Forestales y Aplicación de Modelos de Simulación del Efecto del Cambio Climático</i></a>.</strong></p>
          See <a href="<?php echo ("".$home_climate_URL.""); ?>/future/details.php">details on how futures are computed.</a>
          </strong></p>
          <h2>How it works</h2>
          <ol>
            <li>You prepare a file of locations for which climate predictions are produced. You can upload two types of data:
              <ul>
                <li>Point data has 3 or 4 columns coded as space separated values (commas and tabs also work) with these fields: 
   PointID, Long, Lat (decimal degrees), and optionally, Elevation (meters). 
   If you do not include a header record, then the order of the columns must be PointID, Long, Lat, Elev. If Elev is missing (for
   any or all points), it will be estimated from 
   <a href="http://nationalmap.gov/3DEP/index.html">USGS 1-arc second elevation data.</a> <br /><br />   
   If you include a header record, the name you supply for the first field will be replaced with "PointID"; the 
   PointID column must be the first column. The other column names are matched using the following rules: 
   a name with "lat" is the latitude (case insensitive), a name with "lon" is the longitude, and a name with "ele" is the elevation. <br /><br />
   If a PointID includes blank(s), enclose it in quotation marks. Example line: "Moscow ID" -117.0 46.73 787.3<br /><br />
   File extension is normally .txt, however you may compress your file so that the extension is .zip (implies a zip file) or .gz (implies a gzip file). 
   </li>
                <li><a href="http://docs.codehaus.org/display/GEOTOOLS/ArcInfo+ASCII+Grid+format">Asciigrid</a> files must be of elevations in meters and the grid definition in decimal degrees (please limit your request to about 1 million grid cells).  File extensions are normally .txt, but you can compress your file as described for point data.</li>
              </ul>
                  Our software detects which kind of data you supply by looking for the header records for Asciigrid files. If the headers are not found, the file is assumed to be a point data file. Only ASCII characters be used in the data files.</li>
            <li>You specify an Email address we can use to contact you.</li>
            <li>You specify the data file to send our site.</li>
            <li>You specify which spatial extent(s) you want to use.</li>
            <li>Our server process the request and builds a zip file of the output data.</li>
            <li>Our server sends you an Email with links included that you can use to retrieve the data you requested. You are given 24 hours to recover your data from the time the Email message is sent. Short runs take 5 to 10 mins, long runs can take an hour or two.</li>
          </ol>
          <p>NOTE: We do not attempt to secure your data. While we do not deliberately share it with others, we do not take steps to protect it and we may use it for debugging purposes.</p>
          <p>Also see: <a href="<?php echo ("".$home_climate_URL."/dataNotice.php"); ?>">New Algorithms Used For Some Derived Variables</a> </p>

          <div class="sub-content-nav">
            <h2>Input Form</h2>
            <form name="customRequest" method="POST" action= "<?php echo ("".$home_climate_URL.""); ?>/customData/customRequest.php" enctype="multipart/form-data">
              <label for="emailAddress">Your Email Address:</label><br />
              <input type="TEXT" name="emailAddress" VALUE ="" size="50" /><br /><br />
              <label for="uploadFileName">Specify the file name for the file upload:</label><br />
              <input type="file" name="uploadFileName" size="50" /><br /><br />
              <label for="surface">Select the spatial extent your data falls within:</label><br />
                <input type="radio" name="surface" value="allNA" checked="checked" /> <span class="new-info">(Preferred)</span> All of North America (longitude -177 to -52 and latitude 13.9 to 80 degrees)<br />
                <input type="radio" name="surface" value="westNA" /> <span class="new-info">(Depreciated)</span> Western North America (including western U.S., Canada, and Alaska; longitude -125 to -102 and latitude 31 to 51 degrees) <br />
                <input type="radio" name="surface" value="Mexico" /> <span class="new-info">(Depreciated)</span> Mexico (including parts of southeastern U.S. and Cuba; longitude -118 to -74 and latitude 13.9 to 33 degrees)
              <h3>Output data elements you desire (check all that apply):</h3>
              <input type="checkbox" name="monthlyValues" value="Yes" /><label for="monthlyValues">Monthly values, min, max, average temperature and precipitation</label><br />
              <input type="checkbox" name="derivedData" value="Yes" /><label for="derivedData">Derived variables</label><br /><br />

              <h3>Pick the climate models/scenarios you want run:</h3>
              
                <input type="checkbox" name="currentClim" value="Yes" />Current climate<br />
                <input type="checkbox" name="CGCM3_A1B_y2030" value="Yes" /><label for="CGCM3_A1B_y2030">CGCM3_A1B_y2030</label><br />
                <input type="checkbox" name="CGCM3_A1B_y2060" value="Yes" /><label for="CGCM3_A1B_y2060">CGCM3_A1B_y2060</label><br />
                <input type="checkbox" name="CGCM3_A1B_y2090" value="Yes" /><label for="CGCM3_A1B_y2090">CGCM3_A1B_y2090</label><br />
                <input type="checkbox" name="CGCM3_A2_y2030" value="Yes" /><label for="CGCM3_A2_y2030">CGCM3_A2_y2030</label><br />
                <input type="checkbox" name="CGCM3_A2_y2060" value="Yes" /><label for="CGCM3_A2_y2060">CGCM3_A2_y2060</label><br />
                <input type="checkbox" name="CGCM3_A2_y2090" value="Yes" /><label for="CGCM3_A2_y2090">CGCM3_A2_y2090</label><br />
                <input type="checkbox" name="CGCM3_B1_y2030" value="Yes" /><label for="CGCM3_B1_y2030">CGCM3_B1_y2030</label><br />
                <input type="checkbox" name="CGCM3_B1_y2060" value="Yes" /><label for="CGCM3_B1_y2060">CGCM3_B1_y2060</label><br />
                <input type="checkbox" name="CGCM3_B1_y2090" value="Yes" /><label for="CGCM3_B1_y2090">CGCM3_B1_y2090</label><br />
                <input type="checkbox" name="HADCM3_A2_y2030" value="Yes" /><label for="HADCM3_A2_y2030">HADCM3_A2_y2030</label><br />
                <input type="checkbox" name="HADCM3_A2_y2060" value="Yes" /><label for="HADCM3_A2_y2060">HADCM3_A2_y2060</label><br />
                <input type="checkbox" name="HADCM3_A2_y2090" value="Yes" /><label for="HADCM3_A2_y2090">HADCM3_A2_y2090</label><br />
                <input type="checkbox" name="HADCM3_B2_y2030" value="Yes" /><label for="HADCM3_B2_y2030">HADCM3_B2_y2030</label><br />
                <input type="checkbox" name="HADCM3_B2_y2060" value="Yes" /><label for="HADCM3_B2_y2060">HADCM3_B2_y2060</label><br />
                <input type="checkbox" name="HADCM3_B2_y2090" value="Yes" /><label for="HADCM3_B2_y2090">HADCM3_B2_y2090</label><br />
                <input type="checkbox" name="GFDLCM21_A2_y2030" value="Yes" /><label for="GFDLCM21_A2_y2030">GFDLCM21_A2_y2030</label><br />
                <input type="checkbox" name="GFDLCM21_A2_y2060" value="Yes" /><label for="GFDLCM21_A2_y2060">GFDLCM21_A2_y2060</label><br />
                <input type="checkbox" name="GFDLCM21_A2_y2090" value="Yes" /><label for="GFDLCM21_A2_y2090">GFDLCM21_A2_y2090</label><br />
                <input type="checkbox" name="GFDLCM21_B1_y2030" value="Yes" /><label for="GFDLCM21_B1_y2030">GFDLCM21_B1_y2030</label><br />                  
                <input type="checkbox" name="GFDLCM21_B1_y2060" value="Yes" /><label for="GFDLCM21_B1_y2060">GFDLCM21_B1_y2060</label><br />
                <input type="checkbox" name="GFDLCM21_B1_y2090" value="Yes" /><label for="GFDLCM21_B1_y2090">GFDLCM21_B1_y2090</label><br /><br />
          <p><strong>NOTE: The following are only available when for the All of North America spatial extent.</strong></p>
                <input type="checkbox" name="Ensemble_rcp45_y2030"  value="Yes" /><label for="Ensemble_rcp45_y2030" >Ensemble_rcp45_y2030 </label><br />  
                <input type="checkbox" name="Ensemble_rcp45_y2060"  value="Yes" /><label for="Ensemble_rcp45_y2060" >Ensemble_rcp45_y2060 </label><br />  
                <input type="checkbox" name="Ensemble_rcp45_y2090"  value="Yes" /><label for="Ensemble_rcp45_y2090" >Ensemble_rcp45_y2090 </label><br />  
                <input type="checkbox" name="Ensemble_rcp60_y2030"  value="Yes" /><label for="Ensemble_rcp60_y2030" >Ensemble_rcp60_y2030 </label><br />  
                <input type="checkbox" name="Ensemble_rcp60_y2060"  value="Yes" /><label for="Ensemble_rcp60_y2060" >Ensemble_rcp60_y2060 </label><br />  
                <input type="checkbox" name="Ensemble_rcp60_y2090"  value="Yes" /><label for="Ensemble_rcp60_y2090" >Ensemble_rcp60_y2090 </label><br />  
                <input type="checkbox" name="Ensemble_rcp85_y2030"  value="Yes" /><label for="Ensemble_rcp85_y2030" >Ensemble_rcp85_y2030 </label><br />  
                <input type="checkbox" name="Ensemble_rcp85_y2060"  value="Yes" /><label for="Ensemble_rcp85_y2060" >Ensemble_rcp85_y2060 </label><br />  
                <input type="checkbox" name="Ensemble_rcp85_y2090"  value="Yes" /><label for="Ensemble_rcp85_y2090" >Ensemble_rcp85_y2090 </label><br />  
                <input type="checkbox" name="CCSM4_rcp45_y2030"     value="Yes" /><label for="CCSM4_rcp45_y2030"    >CCSM4_rcp45_y2030    </label><br />  
                <input type="checkbox" name="CCSM4_rcp45_y2060"     value="Yes" /><label for="CCSM4_rcp45_y2060"    >CCSM4_rcp45_y2060    </label><br />  
                <input type="checkbox" name="CCSM4_rcp45_y2090"     value="Yes" /><label for="CCSM4_rcp45_y2090"    >CCSM4_rcp45_y2090    </label><br />  
                <input type="checkbox" name="CCSM4_rcp60_y2030"     value="Yes" /><label for="CCSM4_rcp60_y2030"    >CCSM4_rcp60_y2030    </label><br />  
                <input type="checkbox" name="CCSM4_rcp60_y2060"     value="Yes" /><label for="CCSM4_rcp60_y2060"    >CCSM4_rcp60_y2060    </label><br />  
                <input type="checkbox" name="CCSM4_rcp60_y2090"     value="Yes" /><label for="CCSM4_rcp60_y2090"    >CCSM4_rcp60_y2090    </label><br />  
                <input type="checkbox" name="CCSM4_rcp85_y2030"     value="Yes" /><label for="CCSM4_rcp85_y2030"    >CCSM4_rcp85_y2030    </label><br />  
                <input type="checkbox" name="CCSM4_rcp85_y2060"     value="Yes" /><label for="CCSM4_rcp85_y2060"    >CCSM4_rcp85_y2060    </label><br />  
                <input type="checkbox" name="CCSM4_rcp85_y2090"     value="Yes" /><label for="CCSM4_rcp85_y2090"    >CCSM4_rcp85_y2090    </label><br />  
                <input type="checkbox" name="GFDLCM3_rcp45_y2030"   value="Yes" /><label for="GFDLCM3_rcp45_y2030"  >GFDLCM3_rcp45_y2030  </label><br />  
                <input type="checkbox" name="GFDLCM3_rcp45_y2060"   value="Yes" /><label for="GFDLCM3_rcp45_y2060"  >GFDLCM3_rcp45_y2060  </label><br />  
                <input type="checkbox" name="GFDLCM3_rcp45_y2090"   value="Yes" /><label for="GFDLCM3_rcp45_y2090"  >GFDLCM3_rcp45_y2090  </label><br />  
                <input type="checkbox" name="GFDLCM3_rcp60_y2030"   value="Yes" /><label for="GFDLCM3_rcp60_y2030"  >GFDLCM3_rcp60_y2030  </label><br />  
                <input type="checkbox" name="GFDLCM3_rcp60_y2060"   value="Yes" /><label for="GFDLCM3_rcp60_y2060"  >GFDLCM3_rcp60_y2060  </label><br />  
                <input type="checkbox" name="GFDLCM3_rcp60_y2090"   value="Yes" /><label for="GFDLCM3_rcp60_y2090"  >GFDLCM3_rcp60_y2090  </label><br />  
                <input type="checkbox" name="GFDLCM3_rcp85_y2030"   value="Yes" /><label for="GFDLCM3_rcp85_y2030"  >GFDLCM3_rcp85_y2030  </label><br />  
                <input type="checkbox" name="GFDLCM3_rcp85_y2060"   value="Yes" /><label for="GFDLCM3_rcp85_y2060"  >GFDLCM3_rcp85_y2060  </label><br />  
                <input type="checkbox" name="GFDLCM3_rcp85_y2090"   value="Yes" /><label for="GFDLCM3_rcp85_y2090"  >GFDLCM3_rcp85_y2090  </label><br />  
                <input type="checkbox" name="HadGEM2ES_rcp45_y2030" value="Yes" /><label for="HadGEM2ES_rcp45_y2030">HadGEM2ES_rcp45_y2030</label><br />  
                <input type="checkbox" name="HadGEM2ES_rcp45_y2060" value="Yes" /><label for="HadGEM2ES_rcp45_y2060">HadGEM2ES_rcp45_y2060</label><br />  
                <input type="checkbox" name="HadGEM2ES_rcp45_y2090" value="Yes" /><label for="HadGEM2ES_rcp45_y2090">HadGEM2ES_rcp45_y2090</label><br />  
                <input type="checkbox" name="HadGEM2ES_rcp60_y2030" value="Yes" /><label for="HadGEM2ES_rcp60_y2030">HadGEM2ES_rcp60_y2030</label><br />  
                <input type="checkbox" name="HadGEM2ES_rcp60_y2060" value="Yes" /><label for="HadGEM2ES_rcp60_y2060">HadGEM2ES_rcp60_y2060</label><br />  
                <input type="checkbox" name="HadGEM2ES_rcp60_y2090" value="Yes" /><label for="HadGEM2ES_rcp60_y2090">HadGEM2ES_rcp60_y2090</label><br />  
                <input type="checkbox" name="HadGEM2ES_rcp85_y2030" value="Yes" /><label for="HadGEM2ES_rcp85_y2030">HadGEM2ES_rcp85_y2030</label><br />  
                <input type="checkbox" name="HadGEM2ES_rcp85_y2060" value="Yes" /><label for="HadGEM2ES_rcp85_y2060">HadGEM2ES_rcp85_y2060</label><br />  
                <input type="checkbox" name="HadGEM2ES_rcp85_y2090" value="Yes" /><label for="HadGEM2ES_rcp85_y2090">HadGEM2ES_rcp85_y2090</label><br /> 
                <input type="checkbox" name="CESM1BGC_rcp45_y2030" value="Yes" /><label for="CESM1BGC_rcp45_y2030">CESM1BGC_rcp45_y2030</label><br />  
                <input type="checkbox" name="CESM1BGC_rcp45_y2060" value="Yes" /><label for="CESM1BGC_rcp45_y2060">CESM1BGC_rcp45_y2060</label><br />  
                <input type="checkbox" name="CESM1BGC_rcp45_y2090" value="Yes" /><label for="CESM1BGC_rcp45_y2090">CESM1BGC_rcp45_y2090</label><br />  
                <input type="checkbox" name="CESM1BGC_rcp85_y2030" value="Yes" /><label for="CESM1BGC_rcp85_y2030">CESM1BGC_rcp85_y2030</label><br />  
                <input type="checkbox" name="CESM1BGC_rcp85_y2060" value="Yes" /><label for="CESM1BGC_rcp85_y2060">CESM1BGC_rcp85_y2060</label><br />  
                <input type="checkbox" name="CESM1BGC_rcp85_y2090" value="Yes" /><label for="CESM1BGC_rcp85_y2090">CESM1BGC_rcp85_y2090</label><br />                
                <input type="checkbox" name="CNRMCM5_rcp45_y2030" value="Yes" /><label for="CNRMCM5_rcp45_y2030">CNRMCM5_rcp45_y2030</label><br />  
                <input type="checkbox" name="CNRMCM5_rcp45_y2060" value="Yes" /><label for="CNRMCM5_rcp45_y2060">CNRMCM5_rcp45_y2060</label><br />  
                <input type="checkbox" name="CNRMCM5_rcp45_y2090" value="Yes" /><label for="CNRMCM5_rcp45_y2090">CNRMCM5_rcp45_y2090</label><br />  
                <input type="checkbox" name="CNRMCM5_rcp85_y2030" value="Yes" /><label for="CNRMCM5_rcp85_y2030">CNRMCM5_rcp85_y2030</label><br />  
                <input type="checkbox" name="CNRMCM5_rcp85_y2060" value="Yes" /><label for="CNRMCM5_rcp85_y2060">CNRMCM5_rcp85_y2060</label><br />  
                <input type="checkbox" name="CNRMCM5_rcp85_y2090" value="Yes" /><label for="CNRMCM5_rcp85_y2090">CNRMCM5_rcp85_y2090</label><br />                

              <br /><input type="submit" value="Submit" />
            
            </form>
    
          </div>
          <div class="footer-information">
            <p><strong>Contact:</strong> <a href="mailto:ncrookston.fs@gmail.com">Nicholas Crookston</a></p>
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
