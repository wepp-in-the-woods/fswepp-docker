<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "https://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="https://www.w3.org/1999/xhtml">
 <head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  <meta http-equiv="Content-Language" content="en-us" />
  <meta name="copyright" content="2009 USDA Forest Service Rocky Mountain Research Station" />
  <meta name="author" content="USDA Forest Service - Andy Hudak" />
  <meta name="robots" content="all" />
  <meta name="MSSmartTagsPreventParsing" content="true" />
  <meta name="description" content="USDA Forest Service - Rocky Mountain Research Station, Moscow Forestry Sciences Laboratory" />
  <meta name="keywords" content="Rocky Mountain Research Station, Forest Service, Fire Research, forest fire, prescribed fire, fire conditions, fire effects, wildfire, fire science, watershed, Forestry Sciences Laboratory, erosion prediction, climate, climate estimates, plant and climate relationships, global warming, global warming scenarios, climate change, species composition, predicting global warming" />
  <title>LiDAR -- Moscow Forestry Sciences Laboratory, USDA Forest Service</title>
  <link rel="shortcut icon" href="https://forest.moscowfsl.wsu.edu/images/favicon.ico" />
  <link rel="stylesheet" href="https://forest.moscowfsl.wsu.edu/shared_web/climate.css" type="text/css" media="screen, projection" />
  <link rel="stylesheet" href="https://forest.moscowfsl.wsu.edu/shared_web/climate-print.css" type="text/css" media="print" />
  <!--[if lt IE 8]>
   <link rel="stylesheet" type="text/css" href="https://forest.moscowfsl.wsu.edu/shared_web/climate-oldbrowsers.css" />
  <![endif]-->
  <script src="https://forest.moscowfsl.wsu.edu/shared_web/shared_javascript.js"></script>
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
     <li><a href="https://www.fs.fed.us/rmrs/" title="Rocky Mountain Research Station"><img src="https://forest.moscowfsl.wsu.edu/shared_web/logo_rmrs_tan_bkgd.gif" width="160" height="118" alt="Rocky Mountain Research Station" /></a></li>
     <li><a href="https://www.usda.gov" title="United States Department of Agriculture"><img src="https://forest.moscowfsl.wsu.edu/shared_web/logo_usda.gif" width="69" height="47" alt="United States Department of Agriculture" /></a><a href="https://www.fs.fed.us/"><img src="https://forest.moscowfsl.wsu.edu/shared_web/logo_fs_tan_bkgd.gif" width="45" height="46" alt="United States Forest Service" /></a></li>
     <li><a href="https://www.usa.gov"><img src="https://forest.moscowfsl.wsu.edu/shared_web/logo_usagov_tan_bkgd.gif" width="121" height="36" alt="USA.gov" /></a></li>
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
         <h2 class="nohref">LiDAR study &ndash; Multiscale Curvature Classification</h2>
         <br>
         <b>LiDAR Classification</b>
         <br><br>
          <strong>Multiscale Curvature Classification</strong> (Evans and Hudak 2007) is an iterative, multiscale approach
          for identifying positive curvatures representing non-ground returns in discrete return LiDAR.
          This old version of MCC software works on ArcInfo point coverages, is written in Arc Macro Language, and is slow.
          We recommend using the 
          <a href="https://sourceforge.net/apps/trac/mcclidar/">current MCC-LIDAR software</a> hosted on SourceForge
          (https://sourceforge.net/apps/trac/mcclidar/), which reads/writes lidar .las format files, is written in c++,
          and is fast.
         <br><br>
         For information regarding this algorithm please contact
         <blockquote>
          Andrew T. Hudak - Research Forester / Landscape Ecologist<br>
          USFS &ndash; Rocky Mt. Research Station, Forestry Sciences Lab<br>
          1221 South Main St.<br>
          Moscow, Idaho, 83843<br>
          ahudak[at]fs.fed.us
         </blockquote>
         <p>
 A large portion of LiDAR acquisition cost is incurred during post-processing to separate ground from non-ground returns.
 This is in large part due to the manual editing required to "clean up" the surface and the need to reclaim software
 development or purchase costs.
 LiDAR vendors have put forth substantial investment into development of ground identification algorithms.
 Unfortunately, the majority of available algorithms are proprietary and available only in commercial software or through
 "in-house" vendor processing at considerable cost.
 Ground information is often delivered in the form of gridded raster or normally spaced point data.
 Both of these deliverables generalize the data, discarding the original spatial precision and volume of ground returns.
 The original volume of ground returns is needed to build relationships between ground and vegetation returns.
 If an appropriate volume of ground returns is retained, then the resulting interpolated surface will match the scale
 and precision of the original LiDAR point cloud, reducing bias and error in the derived heights.
 A simple differencing of the interpolated ground height surface from the raw LiDAR elevations will provide
 the vegetation height at each point while preserving density relationships related to vegetation cover,
 such as the proportion of non-ground to ground returns.
         <br><br>
         <img src="image004.jpg" width=674 height=575>
         <br>
         <i>Example of MCC model in high biomass forest in northern Idaho across 3 model loops.</i>
         <br><br>
         <b>References:</b>
         <p align="left" class="Reference">
          J.S. Evans, A.T. Hudak. 2007.
          <i>A Multiscale Curvature Algorithm for Classifying Discrete Return LiDAR in Forested Environments.</i>
          <b>IEEE Transactions on Geoscience and Remote Sensing</b> 45:4 pp.1029-1038.
         </p>
         <p align="left" class="Reference">
          R.A. Haugerud, D.J. Harding. 2001.
          <i>Some Algorithms for Virtual Deforestation (VDF) of Lidar Topographic Survey Data.</i>
          <b>International Archives of Photogrammetry and Remote Sensing</b>, Graz, Austria, vol. XXXIV-3/W4, pp. 211-217.
         </p>
         <p>
          <b>Model Usage:</b>
          <br>
          <pre>
MCC &lt;INCOVER&gt; &lt;OUTCOVER&gt; &lt;ELEVATION ITEM&gt; &lt;SCALE&gt;
        {CURVATURE} {COLUMNS-X} {COLUMNS-Y}

INCOVER - Point coverage of LiDAR point cloud
OUTCOVER - Coverage of identified LiDAR ground returns
ELEVATION ITEM - Info item in LiDAR-coverage, containing elevation value
SCALE - Scale parameter
CURVATURE - Coefficient defining curvature threshold
COLUMNS-X - Number of divisions on X plane
COLUMNS-Y - Number of divisions on Y plane
          </pre>
         </p>
         <p>
          The curvature coefficient for ~2 meter postspacing can be set to 0.2 - 0.3,
          for &lt; 1 meter postspacing depending on the density of the canopy
          I have set it to 0.7.
          This may require some trial and error to find the ideal starting value.
          The scale and curvature coefficients are defined automatically in subsequent model loops,
          thus requiring only a starting value.
          The scale parameter is initially derived from the nominal postspacing.
          <!-- check this -->
          The COLUMNS-X and COLUMNS-Y arguments are for an automatic tiling scheme within the model.
          The tiling is corrected for edge effect and is meant to speed up processing and accommodate the limit of samples
          the spline can fit (400,000 point max).
          The best way to determine these arguments is to take the total number of points in a given coverage
          and figure out the number of tiles you need to have &lt;= 400,000 points per tile.
          The AML merges the tiles so the final coverage is a new coverage containing the filtered ground returns.
          The model assumes an unfiltered point cloud.
          If the LiDAR data has already been filtered by the vendor or is gridded, MCC will not provide correct results.
          <!--  If the LiDAR data have been filtered by the vendor is gridded,
          or separated into a separate dataset(s), MCC will not work. -->
          <br><br>
          A second version of the model has been implemented using the IFD (Iterative Finite Differencing) spline model.
          This method is much faster and does not require a tiling scheme.
          However, care must be taken in certain landscapes not to classify ground returns as positive curvatures.
          In very steep terrains erosion of the hillslope has been observed.
          This can often be addressed by changing the model parameters.
          An additional parameter has been added to adjust the spline tension <i>f</i> which can mitigate
          over-classification by altering the magnitude of the curvature.
          <br><br>
          The model is set up as an ATOOL. 
          If you put it in the $ARCHOME\atool\arc directory it will act like a  native ArcInfo command.
          An example of this path, depending on the version you are running, is:
          C:\arcgis\arcexe9x\atool\arc
         <br><br>
         <a href="MCC.aml" target="_aml">DOWNLOAD MCC</a><br>
        <!-- 
         /*  Purpose: Multiscale Curvature Classification for classification of ground returns<br>
         /*           with an automated tiling function.<br>
          -->
          <br>
         <a href="MCC_IFD.aml" target="_aml">DOWNLOAD MCC_IFD</a><br>
          </font>
				
					<div class="footer-information">
						<p>USDA Forest Service - RMRS - Moscow Forestry Sciences Laboratory<br />
							Last Modified: 
							<!-- below added for Safari and Google Chrome - other date script is not showing for them with this particular server set-up -->
							<span id="lastModified">&nbsp;</span>
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
