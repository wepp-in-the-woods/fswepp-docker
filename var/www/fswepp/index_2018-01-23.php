<html>
 <head>
  <title>FS WEPP Interfaces</title>
  <!--<bgsound src="journey.wav">-->
  <!-- 2005.03.15 DEH Add link to Fume; add getCookie routine to fill in current userID on load -->

  <style type="text/css">
   <!--
    body {position: relative; background: #ffffff; margin: 0; padding: 0;}

    div#help a {display: block; text-align: center; font: bold 1em sans-serif;
       padding: 5px 10px; margin: 0 2 1px; border-width: 0;
       text-decoration: none; color: #ffc; background: #444;
       border-right: none;}
    div#help a:hover {color: #411; background: #AAA;
       display: block;
       margin: 0 0 0px; border-width: 0;
       border-right: none;}
    div#help a span {display: none;}
    div#help a:hover span {display: block;
       position: absolute; top: 70px; left: 0; width: 130px;
       padding: 5px; margin: 10px; z-index: 100;
       color: #000; background: white;
       font: 10px Verdana, sans-serif; text-align: left;}

    div#content {position: absolute; top: 26px; left: 161px; right: 25px;
       color: #BAA; background: #22232F;
       font: 13px Verdana, sans-serif; padding: 10px;
       border: solid 5px #444;}
    div#content p {margin: 0 1em 1em;}
    div#content h3 {margin-bottom: 0.25em;}

    h1 {margin: -9px -9px 0.5em; padding: 15px 0 5px; text-align: right; background: #333; color: #667; letter-spacing: 0.5em; text-transform: lowercase; font: bold 25px sans-serif; height: 28px; vertical-align: middle; white-space: nowrap;}
    dt {font-weight: bold;}
    dd {margin-bottom: 0.66em;}
    div#content a:link {color: white;}
    div#content a:visited {color: #BBC;}
    div#content a:link:hover {color: #FF0;}
    div#content a:visited:hover {color: #CC0;}
    code, pre {color: #EDC; font: 110% monospace;}
   -->
  </style>

  <SCRIPT LANGUAGE = "JavaScript" type="TEXT/JAVASCRIPT">
   <!--

function updateUnits(r) {
// document.CrossDrain.units.value=r
   document.WeppRoad.units.value=r
   document.WeppRoadBatch.units.value=r
   document.WeppDist.units.value=r
   document.ERMiT.units.value=r
   document.WASP.units.value=r
   document.tahoe.units.value=r
   document.RockClime.units.value=r
   document.biomass.units.value=r
}

  function submitit(what) {

    var check=0
    if (document.unitsform.units[1].checked) {check=1}
//  if (what == 'CrossDrain') {document.CrossDrain.units.value=document.unitsform.units[check].value;document.forms.CrossDrain.submit()}
    if (what == 'WeppRoad') {document.WeppRoad.units.value=document.unitsform.units[check].value;document.forms.WeppRoad.submit()}
    if (what == 'WeppRoadBatch') {document.WeppRoadBatch.units.value=document.unitsform.units[check].value;document.forms.WeppRoadBatch.submit()}
    if (what == 'WeppDist') {document.WeppDist.units.value=document.unitsform.units[check].value;document.forms.WeppDist.submit()}
    if (what == 'WeppDist2012') {document.WeppDist2012.units.value=document.unitsform.units[check].value;document.forms.WeppDist2012.submit()}
    if (what == 'ERMiT') {document.ERMiT.units.value=document.unitsform.units[check].value;document.forms.ERMiT.submit()}
    if (what == 'FuME') {document.forms.FuME.submit()}
//    if (what == 'WASP') {document.WASP.units.value=document.unitsform.units[check].value; document.forms.WASP.submit()}
    if (what == 'tahoe') {document.tahoe.units.value=document.unitsform.units[check].value; document.forms.tahoe.submit()}
    if (what == 'biomass') {document.biomass.units.value=document.unitsform.units[check].value; document.forms.biomass.submit()}
    if (what == 'RockClime') {document.RockClime.units.value=document.unitsform.units[check].value; document.forms.RockClime.submit()}
  }

function setCookie() {
  cookie_name = "FSWEPPuser";
  days_to_expire = 1;
  expiration_date = new Date();
  expiration_date.setTime(expiration_date.getTime()+ days_to_expire *(24 * 60 * 60 * 1000));
  expiration_date.toGMTString();
  //  document.cookie = cookie_name + "=" + document.unitsform.user_name.value;
  document.cookie = cookie_name + "=" + document.unitsform.user_name.value +
                  ";expires=" + expiration_date +
                  ";path=/";
  //  updateMe();
}

function getCookie(name){
  var cname = name + "=";
  var dc = document.cookie;
  if (dc.length > 0) {
    begin = dc.indexOf(cname);
    if (begin != -1) {
      begin += cname.length;
      end = dc.indexOf(";", begin);
      if (end == -1) end = dc.length;
      return unescape(dc.substring(begin, end));
    }
  }
  return null;
}

  function MakeArray(n) {     // initialize array of length *n* [Goodman]
    this.length = n; for (var i = 0; i<n; i++) {this[i] = 0} return this
  }

  function StartUp() {
    var me = getCookie('FSWEPPuser')
    if (me == null) {me = ''}
    document.unitsform.user_name.value = me
//    alert('Me: ' + me)
    self.focus()
  }

  function blankStatus() {
    window.status = "Forest Service FSWEPP"
    return true
  }

    // end hide -->
  </SCRIPT>
 </head>

 <!-- BODY link="#ffffff" vlink="lightblue" onLoad="StartUp()" -->
 <!-- BODY link="crimson" vlink="green" onLoad="StartUp()" -->
 <BODY link="green" alink="crimson" vlink="green" onLoad="StartUp()">
  <font face="Arial, Geneva, Helvetica">

   <table width=100% border=0>
    <tr>
     <td> 
       <a href="https://forest.moscowfsl.wsu.edu/">
       <IMG src="images/fsweppic2.gif" width=75 height=75
       name="fswepplogo"
       align="left" alt="Forest Service RMRS AWAE" border=0></a>
     </td>
     <td align="center">
       <h2>
        <hr>
         <font color=red>F</font>orest
         <font color=red>S</font>ervice
         <font color=red><a title="Water Erosion Prediction Project">WEPP</font>
         Interfaces
        <hr>
      </h2>
     </td>
     <td align="right">
      <a href="/fswepp/docs/fsweppdoc.html"
         onMouseOver="window.status='Documentation for FS WEPP Interfaces'; return true"
         onMouseOut="window.status='Forest Service WEPP Interfaces'; return true">
         <img src="images/epage.gif" alt="Documentation for FS WEPP Interfaces" border="0" width="50" height="50"></a>
      </td>
     </tr>
   </table>

  <center>

    <TABLE border="0" bgcolor="ivory">

<!-- ====================================================== -->
<!-- ROW ONE -->
<!-- ===================  WEPP:Road  ====================== -->

     <TR align=top>
      <td align=center bgcolor="lightgrey">
       <a href="javascript:submitit('WeppRoad')">
        <img src="images/road4.gif" height=50 width=50 border=2
        alt="Run WEPP:Road"
        onClick="document.forms.WeppRoad.submit()"
        onMouseOver="window.status='Run WEPP:Road';return true"
        onMouseOut="window.status='Forest Service WEPP Interfaces'; return true"></a>
      </td>
      <td align="center" bgcolor="lightgrey">
       <div id="help">
        <a href="javascript:submitit('WeppRoad')"
             onMouseOver="window.status='Run WEPP:Road';return true"
             onMouseOut="window.status='FS WEPP'; return true">WEPP:Road
         <span>
          Predict erosion from insloped or outsloped forest roads.<br><br>
          WEPP:Road allows users to easily describe numerous road erosion
          conditions.
 	 </span>
        </a>
       </div>
       <font size=-2>
<?php
  // wc ../cgi-bin/fswepp/working/_2015/wr.log
   $file = '../cgi-bin/fswepp/working/_2018/wr.log';
   $wr_runs = intval(exec('wc -l '.escapeshellarg($file).' 2>/dev/null'));
   echo $wr_runs;
?> runs YTD
       </font>
      </td>

<!-- ===================  WEPP:Road Batch  ====================== -->

      <td align="center" bgcolor="lightgrey">
       <div id="help">
        <a  href="javascript:submitit('WeppRoadBatch')"
             onMouseOver="window.status='Run WEPP:Road Batch';return true"
             onMouseOut="window.status='FS WEPP'; return true">WEPP:Road Batch
         <span>
           Predict erosion from multiple insloped or outsloped forest roads
 	 </span>
        </a>
       </div>
       <font size=-2>
<?php
  // wc ../cgi-bin/fswepp/working/_2015/wrb.log
   $file = '../cgi-bin/fswepp/working/_2018/wrb.log';
   echo intval(exec('wc -l '.escapeshellarg($file).' 2>/dev/null'));
?>

<?php
         $dits = 0;
         for ($i = 1; $i <= 53; $i++) {
            $dits += filesize("../cgi-bin/fswepp/working/_2018/wr/$i");
         }
         $segments = $dits - $wr_runs;
         echo "runs, $segments segments YTD";
?>

      </font>
     </td>
      <td align=center bgcolor="lightgrey">
       <a href="javascript:submitit('WeppRoadBatch')">
        <img src="images/roadb_r.gif" height=50 width=50 border=2
        alt="Run WEPP:Road Batch"
        onMouseOver="window.status='Run WEPP:Road Batch';return true"
        onMouseOut="window.status='Forest Service WEPP Interfaces'; return true"></a>
       </td>
     </tr>

<!-- ================================================== -->
<!-- ROW TWO --> <!-- ERMiT and Batch ERMiT link -->
<!-- ===================  ERMiT  ====================== -->

     <tr align=top>
      <td align=center bgcolor="lightgrey">
       <a href="javascript:submitit('ERMiT')">
       <img src="images/ermit.gif"
        alt="Run ERMiT"
        height=50 width=50
        border=2
        onMouseOver="window.status='Run ERMiT';return true"
        onMouseOut="window.status='Forest Service WEPP Interfaces'; return true"></a>
      </td>
      <td align="center" bgcolor="lightgrey">
       <div id="help">
        <a href="javascript:submitit('ERMiT')"
             onMouseOver="window.status='Run ERMiT';return true"
             onMouseOut="window.status='FS WEPP'; return true">ERMiT
         <span>
          <br><br>
          ERMiT allows users to predict the probability of a given amount of sediment delivery from the base of a hillslope following variable burns on forest, rangeland, and chaparral conditions in each of five years following wildfire.
 	 </span>
        </a>
       </div>
       <font size=-2>
<?php
  // wc ../cgi-bin/fswepp/working/_2016/we.log
   $file = '../cgi-bin/fswepp/working/_2018/we.log';
   echo intval(exec('wc -l '.escapeshellarg($file).' 2>/dev/null'));
?> runs YTD
       </font>
      </td>

<!-- ===================   Batch ERMiT link   ====================== -->

      <td align="center" bgcolor="lightgrey">
       <div id="help">
        <a href="batch/bERMiT.html" target="_doit"
             onMouseOver="window.status='';return true"
             onMouseOut="window.status='FS WEPP'; return true">ERMiT batch (download)
         <span>
          <br><br>
          Display web page that descibes and allows for downloading the Batch ERMiT Interface Excel spreadsheet
 	 </span>
        </a>
       </div>
       <font size=-2>
<?php
  // wc ../cgi-bin/fswepp/working/_2015/web.log
   $file = '../cgi-bin/fswepp/working/_2018/web.log';
   echo intval(exec('wc -l '.escapeshellarg($file).' 2>/dev/null'));
?> runs YTD
       </font>
      </td>
      <td align=center bgcolor="lightgrey">
       <a href="batch/bERMiT.html" target="_doit">
       <img src="images/bERMiT.gif"
        alt="Batch ERMiT interface spreadsheet download"
        height=50 width=50
        border=2
        onMouseOver="window.status='Batch ERMiT interface spreadsheet download';return true"
        onMouseOut="window.status='Forest Service WEPP Interfaces'; return true"></a>
      </td>
     </tr>

<!-- ========================================================== -->
<!-- ROW THREE --> <!-- Disturbed WEPP and Batch Disturbed WEPP -->
<!-- ===================  Disturbed WEPP ====================== -->

     <TR align=top>
      <td align=center bgcolor="lightgrey">
       <a href="javascript:submitit('WeppDist')">
        <img src="images/disturb.gif"
        alt="Run Disturbed WEPP"
        height=50 width=50
        border=2
        onMouseOver="window.status='Run Disturbed WEPP';return true"
        onMouseOut="window.status='Forest Service WEPP Interfaces'; return true"></a>
      </td>
      <td align="center" bgcolor="lightgrey">
       <div id="help">
        <a href="javascript:submitit('WeppDist')"
             onMouseOver="window.status='Run Disturbed WEPP';return true"
             onMouseOut="window.status='FS WEPP'; return true">Disturbed WEPP
         <span>
          Predict erosion from rangeland, forestland, and forest skid trails.<br><br>
          Disturbed WEPP allows users to easily describe numerous disturbed
          forest and rangeland erosion conditions.
          The interface  presents the probability of a given level of
          erosion occurring the year following a disturbance.<br><br>
 	 </span>
        </a>
       </div>
       <font size=-2>
<?php
  // wc ../cgi-bin/fswepp/working/_2016/wd2.log
   $file = '../cgi-bin/fswepp/working/_2018/wd2.log';
   echo intval(exec('wc -l '.escapeshellarg($file).' 2>/dev/null'));
?> runs YTD
       </font>
      </td>

<!-- ===================   Disturbed WEPP Batch link   ====================== -->

      <td align="center" bgcolor="lightgrey">
       <div id="help">
        <a href="batch/dWb.html" target="_doit"
             onMouseOver="window.status='Disturbed WEPP Batch interface spreadsheet download';return true"
             onMouseOut="window.status='FS WEPP'; return true">Disturbed WEPP batch (download)
         <span>
          <br><br>
          Display web page that descibes and allows for downloading the Batch Disturbed WEPP Interface Excel spreadsheet
         </span>
        </a>
       </div>
       <font size=-2>
<?php
  // wc ../cgi-bin/fswepp/working/_2015/dwb.log
   $file = '../cgi-bin/fswepp/working/_2018/dwb.log';
   echo intval(exec('wc -l '.escapeshellarg($file).' 2>/dev/null'));
?> runs YTD
       </font>
      </td>
      <td align=center bgcolor="lightgrey">
       <a href="batch/dWb.html" target="_doit">
       <img src="images/dWb.gif"
        alt="Disturbed WEPP batch interface spreadsheet download"
        height=50 width=50
        border=2
        onMouseOver="window.status='Disturbed WEPP batch interface spreadsheet download';return true"
        onMouseOut="window.status='Forest Service WEPP Interfaces'; return true"></a>
      </td>
     </tr>

<!-- ================================================================================= -->
<!-- ROW FOUR --> <!-- TAHOE BASIN and BIOMASS -->
<!-- ===================  TAHOE BASIN SEDIMENT MODEL  ====================== -->

     <TR align=top>
      <td align=center bgcolor="lightgrey">
       <a href="javascript:submitit('tahoe')">
       <img src="images/tahoelogo.jpg" height=45 width=45 border=2
            alt="Run Tahoe Basin Sediment Model"
            onMouseOver="window.status='Run Tahoe Basin Sediment Model';return true"
            onMouseOut="window.status='Forest Service WEPP Interfaces'; return true"></a>
      </td>
      <td align="center" bgcolor="lightgrey">
       <div id="help">
        <a href="javascript:submitit('tahoe')"
             onMouseOver="window.status='Run Tahoe Basin Sediment Model';return true"
             onMouseOut="window.status='FS WEPP'; return true">Tahoe Basin Sediment Model
         <span>
          The Tahoe Basin Sediment Model is an offshoot of Disturbed WEPP customized for the Lake Tahoe Basin.
 	 </span>
        </a>
       </div>
       <font size=-2>
<?php
// wc ../cgi-bin/fswepp/working/_2015/wt.log
   $file = '../cgi-bin/fswepp/working/_2018/wt.log';
   $total_lines = intval(exec('wc -l '.escapeshellarg($file).' 2>/dev/null'));
   echo $total_lines;
?> runs YTD
       </font>
      </td>

<!-- ===================   BIOMASS   ====================== -->

      <td align="center" bgcolor="lightgrey">
       <div id="help">
        <a href="javascript:submitit('biomass')"
             onMouseOver="window.status='Run Biomass Sediment Model';return true"
             onMouseOut="window.status='FS WEPP'; return true">Biomass Sediment Model
         <span>
          <br><br>
          The FS WEPP Biomass Sediment Model interface predicts soil erosion associated with fuel management practices including prescribed fire, biomass harvest, and a road network, and compares that prediction to erosion from wildfire. Biomass Sediment Model is an offshoot of Disturbed WEPP.
 	 </span>
        </a>
       </div>
       <font size=-2>
<?php
//   wc ../cgi-bin/fswepp/working/_2015/wb.log
   $file = '../cgi-bin/fswepp/working/_2018/wb.log';
   echo intval(exec('wc -l '.escapeshellarg($file).' 2>/dev/null'));
?> runs YTD
       </font>
      </td>
      <td align=center bgcolor="lightgrey">
       <a href="javascript:submitit('biomass')">
       <img src="images/biomassicon.jpg"
        alt="Run Biomass Sediment Model"
        height=43 width=50
        border=2
        onMouseOver="window.status='Run Biomass Sediment Model';return true"
        onMouseOut="window.status='Forest Service WEPP Interfaces'; return true"></a>
      </td>
     </tr>

<!-- ================================================= -->
<!-- ROW FIVE --> <!-- FuME and Rock:Clime
<!-- ===================  FuME  ====================== -->

     <TR align=top>
      <td align=center bgcolor="lightgrey">
       <a href="javascript:submitit('FuME')">
        <img src="images/fume.jpg"
          alt="Run FuME Fuel Management Erosion model"
          height=50 width=50 border=2
          onMouseOver="window.status='Run FuME Fuel Management Erosion model';return true"
          onMouseOut="window.status='Forest Service WEPP Interfaces'; return true"></a>
      </td>
      <td align="center" bgcolor="lightgrey">
       <div id="help">
        <a href="javascript:submitit('FuME')"
             onMouseOver="window.status='Run FuME Fuel Management Erosion model';return true"
             onMouseOut="window.status='FS WEPP'; return true">FuME (Fuel Management)
         <span>
          The FuME interface predicts soil erosion associated with fuel management practices including prescribed fire,
          thinning, and a road network, and compares that prediction with erosion from wildfire.
          <br><br>
          The interface is currently under development.
 	 </span>
        </a>
       </div>
       <font size=-2>
<?php
  // wc ../cgi-bin/fswepp/working/_2015/wf.log
   $file = '../cgi-bin/fswepp/working/_2018/wf.log';
   echo intval(exec('wc -l '.escapeshellarg($file).' 2>/dev/null'));
?> runs YTD
       </font>
      </td>

<!-- ===================  Rock Clime  ====================== -->

      <td align="center" bgcolor="lightgrey">
       <div id="help">
        <a href="javascript:submitit('RockClime')"
             onMouseOver="window.status='Run Rock:Clime';return true"
             onMouseOut="window.status='FS WEPP'; return true">Rock:Clime
         <span>
          Create and download a WEPP climate file to your PC.<br><br>
          The Rocky Mountain Climate Generator creates a daily weather file using the ARS CLIGEN weather generator.
          The file is intended to be used with the WEPP Windows and GeoWEPP interfaces,
          but also can be a source of weather data for any application.
          It creates up to 200 years of weather from a database of over 2600 weather stations and the
          PRISM 2.5-mile grid of precipitation data.
 	 </span>
        </a>
       </div>
       <font size=-2>
<?php
  // 
?> &nbsp;
       </font>
      </td>
      <td align=center bgcolor="lightgrey">
       <a href="javascript:submitit('RockClime')">
        <img src="images/climate2_r.gif"
        width=50 height=50
        border=2
        alt="Run Rock:Clime"
        onClick="document.forms.RockClime.submit()"
        onMouseOver="window.status='Run Rock:Clime';return true"
        onMouseOut="window.status='Forest Service WEPP Interfaces'; return true"></a>
      </td>
     </tr>

<!-- ============================================================== -->
<!-- ROW SIX --> <!-- Great Lakes WEPP watershed GIS and Peak Flow  -->
<!-- ===================  Great Lakes on the Web  ================= -->

     <tr align=top>
      <td align=center bgcolor="lightgrey">
       <a href="http://129.101.152.143/gl/" target="_doit">
        <img src="images/GLlogo.jpg"
          alt="Watershed Online GIS"
          height=50 width=50 border=2
          onMouseOver="window.status='Great Lakes WEPP Watershed Online GIS Interface &ndash; conterminous U.S.';return true"
          onMouseOut="window.status='Forest Service WEPP Interfaces'; return true"></a>
      </td>
      <td align="center" bgcolor="lightgrey">
       <div id="help">
        <a href="http://129.101.152.143/gl/" target="new"
             onMouseOver="window.status='Links to other WEPP resources on the Web';return true"
             onMouseOut="window.status='FS WEPP'; return true">WEPP Watershed Online GIS
         <span>
             Great Lakes WEPP Watershed Online GIS Interface &ndash; conterminous U.S.
 	 </span>
        </a>
       </div>
      </td>
<!-- ===================  Peak Flow Calculator  ====================== -->
      <td align="center" bgcolor="lightgrey">
       <div id="help">
        <a href="ermit/peakflow/" target="_doit"
             onMouseOver="window.status='Run Peak Flow Calculator';return true"
             onMouseOut="window.status='FS WEPP'; return true">Peak Flow Calculator
         <span>
          <br><br>
          FS Peakflow Calculator &ndash; Estimated peak flow for burned areas using Curve Number technology 
         </span>
        </a>
       </div>
      </td>
      <td align=center bgcolor="lightgrey">
       <a href="ermit/peakflow/" target="_doit"><img src="ermit/peakflow/peakflow.jpg" width=50 height=42 border=2></a>
      </td>
     </tr>

<!-- ==================================================================================== -->
<!-- ROW SEVEN --> <!-- Tahoe GIS and WEPP Post-Fire Erosion Prediction (PEP) interface   -->
<!-- ===================  Lake Tahoe WEPP Watershed GIS Interface  ====================== -->

     <TR align=top>
      <td align=center bgcolor="lightgrey">
       <a href="http://wepp2.nkn.uidaho.edu/lt/">
       <img src="images/TGISlogo.jpg" height=50 width=50 border=2
           alt="Tahoe GIS"
           onMouseOver="window.status='Run Lake Tahoe WEPP Watershed GIS Interface';return true"
           onMouseOut="window.status='Forest Service WEPP Interfaces'; return true"></a>
      </td>
      <td align="center" bgcolor="lightgrey">
       <div id="help">
        <a href="http://wepp2.nkn.uidaho.edu/lt/"
             onMouseOver="window.status='Run Lake Tahoe WEPP Watershed GIS Interface';return true"
             onMouseOut="window.status='FS WEPP'; return true"> Lake Tahoe WEPP Watershed GIS Interface
         <span>
          Lake Tahoe WEPP Watershed Online GIS Interface
 	 </span>
        </a>
       </div>
<font size=-2></font>
      </td>

<!-- ===================  WEPP Post-Fire Erosion Prediction (PEP) interface  ====================== -->

      <td align="center" bgcolor="lightgrey">
       <div id="help">
        <a href="http://129.101.152.143/baer"
             onMouseOver="window.status='';return true"
             onMouseOut="window.status='FS WEPP'; return true">WEPP Post-Fire Erosion Prediction (PEP)
         <span>
             WEPP Post-Fire Erosion Prediction (PEP) -- a computer simulation tool that estimates soil erosion following an actual or simulated wildfire from soil burn severity maps
 	 </span>
           <!--  -->
        </a>
       </div>
      </td>
      <td align=center bgcolor="lightgrey">
       <a href="http://129.101.152.143/baer">
        <img src="images/PEPlogo.jpg" width=50 height=50 border=2
          alt="PEP"
          height=50 width=50 border=2
          onMouseOver="window.status='WEPP Post-Fire Erosion Prediction (PEP)';return true"
          onMouseOut="window.status='Forest Service WEPP Interfaces'; return true"></a>
      </td>
     </tr>
    </table>

<!-- END ROWS -->

   <form method="post" name="CrossDrain" action="/cgi-bin/fswepp/xdrain/xdrain.pl">
    <input type="hidden" name=units value="m">
   </form>
   <form method="post" name="WeppRoad" action="/cgi-bin/fswepp/wr/wepproad.pl">
    <input type="hidden" name="units" value="m">
   </form>
   <form method="post" name="WeppRoadBatch" action="/cgi-bin/fswepp/wr/wepproadbat.pl">
    <input type="hidden" name="units" value="m">
   </form>
   <form method="post" name="WeppDist" action="/cgi-bin/fswepp/wd/weppdist.pl">
    <input type="hidden" name="units" value="m">
   </form>
   <form method="post" name="WeppDist2012" action="/cgi-bin/fswepp/wd/weppdist2012.pl">
    <input type="hidden" name="units" value="m">
   </form>
   <form method="post" name="ERMiT" action="/cgi-bin/fswepp/ermit/ermit.pl">
    <input type="hidden" name="units" value="m">
   </form>
   <form method="post" name="tahoe" action="/cgi-bin/fswepp/tahoe/tahoe.pl">
    <input type="hidden" name="units" value="m">
   </form>
   <form method="post" name="WASP" action="/cgi-bin/fswepp/wasp/wasp.pl">
    <input type="hidden" name="units" value="m">
   </form>
   <form method="post" name="biomass" action="/cgi-bin/fswepp/biomass/biomass.pl">
    <input type="hidden" name="units" value="m">
   </form>
   <form method="post" name="FuME" action="/cgi-bin/fswepp/fume/fume.pl">
   </form>
   <form method="post" name="RockClime" action="/cgi-bin/fswepp/rc/rockclim.pl">
    <input type="hidden" name="units" value="m">
    <input type="hidden" name="action" value="-download">
   </form>

   <form name="unitsform">Units:&nbsp;
    <input type="radio" name="units" value="m"
           onClick="updateUnits('m');">metric
    <input type="radio" name="units" value="ft" checked
           onClick="updateUnits('ft');">U.S. customary
    &nbsp;&nbsp;&nbsp;&nbsp;
    <font size=-1>
     <input type="text" name="user_name" size="1" onChange="setCookie()"> 
     <a href="id_info.html"> personality</a> (a to z) 
    </font>
   </form>
   <table width=100% border=0>
    <tr>
     <td align="center">
      <img src="images/line_red2.gif">
      <br>
      <font size=-1>
       <a href="WEPPlinks.html" target="new">Other WEPP Resources</a><br>
       [ <a href="fsw_help.html" target="o">FS WEPP hints and requirements</a>
       | <a href="/fswepp/comments.html" target="o">Send FS WEPP developers your comments on these Interfaces</a> ]
       <br>
       [ <!-- a href="https://www.srs.fs.usda.gov/customer/commentcard_rmrs.htm" target="o" --> <!-- Send FS Washington, DC office your comments on the Forest Service WEPP Interfaces --> <!-- /a -->
        <!-- a href="/commentcard_rmrs_fswepp.htm" target="o" | -->

       <a href="privacy.html" target="o">FS WEPP privacy disclaimer</a> ]
      </font>
      <br>
       <img src="images/line_red2.gif">
      <br>
      <font size=-1>
       <a href="/people/engr/welliot.html">Bill Elliot</a>,
       USDA Forest Service RMRS Air, Water, and Aquatics Environments, Moscow, Idaho

       <br>
       These interfaces funded in part by
       <br>

      </td>
     </tr>
    </table>
<a href="https://www.fs.fed.us">                       <img src="/images/usfs.gif" alt="USDA Forest Service" height=37 width=73 alt="USFS logo" border=0 title="U.S. Forst Service"></a>
<a href="https://www.fs.fed.us/rmrs">                  <img src="images/rmrs_small.gif" width="75" alt="RMRS logo" border=0 title="U.S. Forest Service Rocky Mountain Research Station"></a>
<a href="https://www.fs.fed.us/eng/techdev/sdtdc.htm"> <img src="/images/sdtd_l50.gif" height=50 width=87 alt="San Dimas logo" border=0 title="U.S. Forest Service San Dimas Technology and Development Center"></a>
<a href="https://www.firescience.gov">                 <img src="/images/jfsp_l75.gif" width=75 height=102 alt="JFSP logo" border=0 title="U.S. Department of Interior Joint Fire Science Program"></a>
<a href="https://nifa.usda.gov">                        <img src="https://nifa.usda.gov/sites/default/files/resource/Web_usda_nifa_vertical_rgb_72.jpg" title="USDA National Institute of Food and Agriculture" width=100></a>
<a href="http://www.usace.army.mil">                   <img src="http://trailcrew.org/wp-content/uploads/2014/12/army-corp-of-engineers.jpg" width=100 height=75" border=0 title="Army Corp of Engineers">
<a href="https://www.ars.usda.gov/mwa/lafayette/nserl"><img src="/images/ars_60.gif" with=60 height=45 alt="ARS logo" border=0 title="WEPP is an interagency model lead by the Agricultural Research Service's National Soil Erosion Research Laboratory"></a>
   </center>
  </font>
 </BODY>
</HTML>
