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
  document.CrossDrain.units.value=r
  document.WeppRoad.units.value=r
  document.WeppRoadBatch.units.value=r
  document.WeppDist.units.value=r
  document.ERMiT.units.value=r
  document.RockClime.units.value=r
}

  function submitit(what) {

    var check=0
    if (document.unitsform.units[1].checked) {check=1}
    if (what == 'CrossDrain') {document.CrossDrain.units.value=document.unitsform.units[check].value;document.forms.CrossDrain.submit()}
    if (what == 'WeppRoad') {document.WeppRoad.units.value=document.unitsform.units[check].value;document.forms.WeppRoad.submit()}
    if (what == 'WeppRoadBatch') {document.WeppRoadBatch.units.value=document.unitsform.units[check].value;document.forms.WeppRoadBatch.submit()}
    if (what == 'WeppDist') { document.WeppDist.units.value=document.unitsform.units[check].value;document.forms.WeppDist.submit()}
    if (what == 'ERMiT') {document.ERMiT.units.value=document.unitsform.units[check].value;document.forms.ERMiT.submit()}
    if (what == 'FuME') {document.forms.FuME.submit()}
    if (what == 'RockClime') {document.RockClime.units.value=document.unitsform.units[check].value; document.forms.RockClime.submit()}
  }

  function submitit_old(what) {

    var check=0
    if (document.unitsform.units[1].checked) {check=1}
    document.CrossDrain.units.value=document.unitsform.units[check].value
    document.WeppRoad.units.value=document.unitsform.units[check].value
    document.WeppRoadBatch.units.value=document.unitsform.units[check].value
    document.WeppDist.units.value=document.unitsform.units[check].value
    document.ERMiT.units.value=document.unitsform.units[check].value
    document.RockClime.units.value=document.unitsform.units[check].value
    if (what == 'CrossDrain') {document.forms.CrossDrain.submit()}

    if (what == 'WeppRoad') {document.forms.WeppRoad.submit()}
    if (what == 'WeppRoadBatch') {document.forms.WeppRoadBatch.submit()}
    if (what == 'WeppDist') {document.forms.WeppDist.submit()}
    if (what == 'ERMiT') {document.forms.ERMiT.submit()}
    if (what == 'RockClime') {document.forms.RockClime.submit()}
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
    window.status = "Forest Service ERMiT"
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
       <a href="http://forest.moscowfsl.wsu.edu/">
       <IMG src="images/fsweppic2.gif" width=75 height=75
       name="fswepplogo"
       align="left" alt="Forest Service Soil & Water Engineering" border=0></a>
     </td>
     <td align="center">
       <h2>
        <hr>
         <font color=red>F</font>orest
         <font color=red>S</font>ervice
         <font color=red>WEPP</font>
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

<!-- ===================  Cross Drain, X-Drain  ====================== -->

     <TR align=top>
       <td align=center bgcolor="lightgrey">
        <a href="javascript:submitit('CrossDrain')">
        <img src="images/e-drain.gif" height=50 width=50 border=2
             alt="Run X-DRAIN"
             onMouseOver="window.status='Run X-DRAIN';return true"
             onMouseOut="window.status='Forest Service WEPP Interfaces'; return true"></a>
       </td>
      <td align="center" bgcolor="lightgrey">
       <div id="help">
        <a href="javascript:submitit('CrossDrain')"
             onMouseOver="window.status='Run X-DRAIN';return true"
             onMouseOut="window.status='FS WEPP'; return true">Cross Drain
         <span>
          Predict sediment yield from a road segment across a buffer.<br><br>
          CrossDrain can be used to determine optimum cross drain spacing for
          existing or planned roads, and for developing and supporting
          recommendations concerning road construction, reconstruction,
          realignment, closure, obliteration, or mitigation efforts based on
          sediment yield.
 	 </span>
        </a>
       </div>
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
      </td>
       <td align=center bgcolor="lightgrey">
        <a href="javascript:submitit('WeppRoadBatch')">
         <img src="images/roadb_r.gif" height=50 width=50 border=2
         alt="Run WEPP:Road Batch"
         onMouseOver="window.status='Run WEPP:Road Batch';return true"
         onMouseOut="window.status='Forest Service WEPP Interfaces'; return true"></a>
       </td>
     </tr>

<!-- ===================  Disturbed WEPP  ====================== -->

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
          erosion occurring the year following a disturbance.
 	 </span>
        </a>
       </div>
      </td>

<!-- ===================  ERMiT  ====================== -->

      <td align="center" bgcolor="lightgrey">
       <div id="help">
        <a href="javascript:submitit('ERMiT')"
             onMouseOver="window.status='Run ERMiT';return true"
             onMouseOut="window.status='FS WEPP'; return true">ERMiT
         <span>
          ERMiT predicts the probability associated with a given amount of soil erosion in each of five years following wildfire.
          <br><br>
          ERMiT allows users to predict erosion following variable burns on forest, rangeland, and chaparral conditions.
 	 </span>
        </a>
       </div>
      </td>
      <td align=center bgcolor="lightgrey">
       <a href="javascript:submitit('ERMiT')">
       <img src="images/ermit.gif"
        alt="Run ERMiT"
        height=50 width=50
        border=2
        onMouseOver="window.status='Run ERMiT';return true"
        onMouseOut="window.status='Forest Service WEPP Interfaces'; return true"></a>
      </td>
     </tr>

<!-- ===================  FuME  ====================== -->

     <TR align=top>
      <td align=center bgcolor="lightgrey">
       <a href="javascript:submitit('FuME')">
        <img src="images/fume.jpg"
          alt="Run WEPP FuME Fuel Management Erosion model"
          height=50 width=50 border=2
          onMouseOver="window.status='Run WEPP FuME Fuel Management Erosion model';return true"
          onMouseOut="window.status='Forest Service WEPP Interfaces'; return true"</a>
      </td>
      <td align="center" bgcolor="lightgrey">
       <div id="help">
        <a href="javascript:submitit('FuME')"
             onMouseOver="window.status='Run WEPP FuME Fuel Management Erosion model';return true"
             onMouseOut="window.status='FS WEPP'; return true">WEPP FuME (Fuel Management)
         <span>
          The FuME interface predicts soil erosion associated with fuel management practices including prescribed fire,
          thinning, and a road network, and compares that prediction with erosion from wildfire.
          <br><br>
          The interface is currently under development.
 	 </span>
        </a>
       </div>
      </td>

<!-- ===================  Other WEPP resources on the Web  ====================== -->

      <td align="center" bgcolor="lightgrey">
       <div id="help">
        <a href="WEPPlinks.html" target="new"
             onMouseOver="window.status='Links to other WEPP resources on the Web';return true"
             onMouseOut="window.status='FS WEPP'; return true">Other WEPP resources
         <span>
           ARS's WEPP on the Web, WEPP for Windows, GeoWEPP, WEPP manuals, etc., on remote sites
 	 </span>
        </a>
       </div>
      </td>
      <td align=center bgcolor="lightgrey">
       <a href="WEPPlinks.html" target="_links">
        <img src="images/wepp.gif"
          alt="Links to other WEPP resources on the Web"
          height=50 width=50 border=2
          onMouseOver="window.status='New window: Links to other WEPP resources on the Web';return true"
          onMouseOut="window.status='Forest Service WEPP Interfaces'; return true"</a>
      </td>
     </tr>

    </table>

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
   <form method="post" name="ERMiT" action="/cgi-bin/fswepp/ermit/ermit.pl">
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
<br>
    <font size=-1>
     <input type="text" name="user_name" size="1" onChange="setCookie()"> 
     <a href="id_info.html"> personality</a> (a to z) 
    &nbsp;&nbsp;&nbsp;&nbsp;
    <b>IP:</b><input type="text" name="IP" value="<?= @$_SERVER["REMOTE_ADDR"]?>">
    </font>
   </form>
   <table width=100% border=0>
    <tr>
     <td align="left" width=75 valign="bottom">
      <img src="/images/usfs.gif" alt="USDA Forest Service" height=37 width=73 alt="USFS logo" border=0>
      <br>
      <img src="/local_resources/images/rmrs/rmrs_index_top.gif" width="75" height="40" alt="RMRS logo" border=0>
      <br>
      <img src="/images/ars_60.gif" with=60 height=45 alt="ARS logo" border=0>
     </td>
     <td align="center">
      <img src="images/line_red2.gif">
      <br>
      <font size=-2>
       [ <a href="fsw_help.html" target="o">FS WEPP hints and requirements</a>
       | <a href="/fswepp/comments.html" target="o">Send FS WEPP developers your comments on the Forest Service WEPP Interfaces</a> ]
       <br>
       [ <!-- a href="http://www.srs.fs.usda.gov/customer/commentcard_rmrs.htm" target="o" --> <!-- Send FS Washington, DC office your comments on the Forest Service WEPP Interfaces --> <!-- /a -->
        <!-- a href="/commentcard_rmrs_fswepp.htm" target="o" | -->
       <a href="privacy.html" target="o">FS WEPP privacy disclaimer</a> ]
      </font>
      <br>
       <img src="images/line_red2.gif">
      <br>
      <font size=-1>
       <a href="/people/engr/welliot.html">Bill Elliot</a>, Team Leader,
       USDA Forest Service <a href="http://forest.moscowfsl.wsu.edu/engr/">Soil &amp; Water Engineering,</a> Moscow, Idaho
       <SCRIPT>
//        <!-- hide
//          document.write(document.lastModified)
          // end hide -->
       </SCRIPT>
       <br>
       These interfaces funded in part by the
       <br>
       USDA Forest Service -- US Department of Interior
       <a href=""
        onMouseOver="window.status='Open in new window'; return true"
        onMouseOut="window.status='Forest Service WEPP Interfaces'; return true"
        onClick='window.open("http://www.firescience.gov/","jfsp"); 
        return false'>Joint Fire Science Program</a>
       <br>
       and the USDA Forest Service
       <a href=""
        onMouseOver="window.status='Open in new window'; return true"
        onMouseOut="window.status='Forest Service WEPP Interfaces'; return true"
        onClick='window.open("http://www.fs.fed.us/eng/techdev/sdtdc.htm","sdtdc"); 
        return false'>San Dimas Technology and Development Center</a>.
       <br>
       WEPP is an interagency model lead by the<br>Agricultural Research Service's
       <a href="http://www.ars.usda.gov/mwa/lafayette/nserl" target="nserl"
        onMouseOver="window.status='Open in new window'; return true"
        onMouseOut="window.status='Forest Service WEPP Interfaces'; return true">National Soil Erosion Research Laboratory</a>.
       <br>
       http://forest.moscowfsl.wsu.edu/fswepp/
      </td>
      <td width=75 valign="bottom">
       <img src="/images/jfsp_l75.gif" width=75 height=102 alt="JFSP logo" border=0>
       <br>
       <img src="/images/sdtd_l50.gif" height=50 width=87 alt="San Dimas logo" border=0>
      </td>
     </tr>
    </table>
   </center>
  </font>
 </BODY>
</HTML>