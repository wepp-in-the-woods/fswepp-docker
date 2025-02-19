<html>
 <head>
  <title>ArcInfo Hillslope Delineation Toolbox</title>
 </head>
 <body bgcolor="ivory">
  <font face="calibri, trebuchet, tahoma, arial, sans serif">
    <h3>ArcInfo Hillslope Delineation Toolbox</h3>
    ArcInfo Hillslope Delineation Toolbox for
    <em>Disturbed WEPP batch interface spreadsheet</em> and
    <em>Batch ERMiT interface spreadsheet</em>.

    <h4>ArcGIS 10</h4>
    <ul>
        <li><a href="download.php?file=arcgis_v10-3">Toolbox for ArcGIS v. 10.3</a> (v. 2012.04.01 modified 2017.03.22) (.TBX file)</li>
        <li><a href="download.php?file=arcgis_v10-0">Toolbox for ArcGIS v. 10.0</a> (v. 2012.04.01) (3.4 MB TBX file)</li>
        <li><a href="manuals/10-04818-000_Hillslope_Toolbox_User_Guide-ArcGIS_10-2012_03_30.pdf">Toolbox User Manual for ArcGIS v. 10.0 (2012.04.11)</a> (40 page 3 MB PDF)</li>
    </ul>

    <h4>ArcGIS 9</h4>
    <ul>
        <li><a href="download.php?file=arcgis_v9-3">Toolbox for ArcGIS v. 9.3 (v. 2012.03.29)</a> (3.2 MB TBX file)</li>
        <li><a href="manuals/10-04818-000_Hillslope_Toolbox_User_Guide-ArcGIS_9.3-2012_03_30.pdf">Toolbox User Manual for ArcGIS v. 9.3 (2012.04.11) </a> (40 page 3 MB PDF)</li>
    </ul>

    <br><br>
    This is an ArcInfo Toolbox (.tbx file) that one downloads and installs on one's PC.
    The toolbox is not required for running the Disturbed WEPP Batch or Batch ERMiT interface spreadsheets,
    but it can assist in collecting the run parameter input values.
    <br><br>

    <h4>Requirements for the optional ArcInfo Hillslope Delineation Toolbox</h4>
    <ul>
     <li>ESRI ArcGIS 9.x and ArcGIS Spatial Analyst extension</li>
     <li>GIS datasets in one common coordinate system
      <ul>
       <li>an elevation raster, such as a 10-meter DEM or LiDAR, as one single raster grid (publicly available)</li>
       <li>polygons describing stream centerline data with names (publicly available)</li>
       <li>polygons describing treatment types (user-developed)</li>
       <li>polygons describing land use (user-developed)</li>
     </ul>
    </ul>

    The final product from operating the Hillslope Delineation Toolbox is a comma-separatated-values (CSV) file with
    the following fields:
    <ul>
     <li>"OID_" &ndash; O identification
     <li>"HS_ID" &ndash; Hillslope identification
     <li>"UNIT_ID" &ndash; Unit identification
     <li>"LAND_TYPE" &ndash; Hillslope landtype
     <li>"AREA"	 &ndash; Hillslope area
     <li>"UTREAT" &ndash; Upper element treatment
     <li>"USLP_LNG" &ndash; Upper element hillslope horizontal gradient
     <li>"UGRD_TP" &ndash; Upper element hillslope top gradient
     <li>"UGRD_BTM" &ndash; Upper element hillslope bottom gradient
     <li>"LTREAT" &ndash; Lower element treatment
     <li>"LSLP_LNG" &ndash; Lower element hillslope horizontal length
     <li>"LGRD_TP" &ndash; Lower element hillslope top gradient
     <li>"LGRD_BTM" &ndash; Lower element hillslope bottom gradient
     <li>"ADJ_STRM" &ndash; Adjacent stream
     <li>"TRIB_TO" &ndash; Stream tribuary to
     <li>"ERM_TSLP" &ndash; ERMiT top slope
     <li>"ERM_MSLP" &ndash; ERMiT mid-slope
     <li>"ERM_BSLP" &ndash; ERMiT bottom slope
     <li>"BURNSEV" &ndash; ERMiT burn severity value (0-255)
    </ul>

    The resulting file can be read into the Disturbed WEPP Batch or Batch ERMiT interface spreadsheets.
    The following values for the <b>Disturbed WEPP Batch</b> interface spreadsheet input screen will be loaded:
    <ul>
     <li>hillslope code
     <li>GIS land type (optional)
     <li>area
     <li>upper and lower element GIS treatment type (optional)
     <li>upper and lower element hillslope horizontal slope length
     <li>upper and lower element hillslope top and bottom gradient
    </ul>
    For the <b>Batch ERMiT</b> interface spreadsheet input screen, the following fields will be loaded:
    <ul>
     <li>hillslope code
     <li>GIS land type (optional)
     <li>area
     <li>GIS treatment (optional)
     <li>hillslope top, middle, and bottom gradients
     <li>hillslope horizontal slope length
     <li>soil burn severity rating (optional)
     <li>soil burn severity class (mapped from the rating above)
    </ul>
<br><br>
<h4>Tips</h4>
Users should be sure that they are running the toolbox in ArcGIS 10.
The toolbox may have some incompatibilities with version 10.1.
<br><br>
Two issues have come up related to the default workspace settings within ArcToolbox.
To access these settings, right-click inside <i>ArcToolbox,</i>
select <i>Environments,</i> and click on the <i>Workspace</i> drop-down.
<blockquote>
Specific to each error:
<ul>
 <li>	<b>ERROR 010032</b> (eg., "Step1HydroProcessing DEMs 010032: Unable to create the scratch grid") is a permissions error
        &ndash; the user doesn't have the necessary permissions to write files to the default workspaces that are selected by ArcToolbox.
        There is specific help information on this error at:<br>
        https://help.arcgis.com/EN/arcgisdesktop/10.0/help/#//00vq0000000n010032.htm
</li>
<li>	<b>ERROR 000303</b> (eg., "Step 2 Stream and Watershed Delineation, 000303: Field FID does not exist") occurs because the default current and scratch workspaces in ArcGIS are set as geodatabases.
        This happens by default when you install ArcGIS.
        A scratch database is created at C:\Users\[user]\Documents\ArcGIS\Default.gdb and all temporary files
        are written here unless otherwise specified.
        If users go into their workspace settings and change both output locations to a non-geodatabase directory,
        this error should be resolved.
        The input files can come from a geodatabase without a problem.
</li>
</ul>
</blockquote>

    Check this webpage to watch for updates and hints as we get more experience with this Toolbox.<br>
    <a href="/fswepp/comments.html" target="_comment">
     <img src="/fswepp/images/epaemail.gif" align="right" border=0>
    </a>
    Send us comments, or register as a user.
   </blockquote>
   <img src="/fswepp/images/rmrs_logo_tiny.jpg" width=100><br><br>
   <img src="/fswepp/images/herrera.jpg" width=162 height=46>
   <br><br>
  </font>
 </body>
</html>
