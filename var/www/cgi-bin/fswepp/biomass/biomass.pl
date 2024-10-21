#!/usr/bin/perl

use warnings;
use CGI ':standard';

use MoscowFSL::FSWEPP::FsWeppUtils qw(get_version get_user_id);
use MoscowFSL::FSWEPP::CligenUtils qw(GetClimates);

my $year_min   = 1;
my $year_def   = 5;
my $year_max   = 200;
my $totl_l_min = 1.1;
my $totl_l_def = 200;
my $totl_l_max = 1500;    # total hill length
my $buff_l_min = 1;
my $buff_l_def = 50;
my $buff_l_max = 1000;    # buffer length
my $hill_g_min = 0.5;
my $hill_g_def = 30;
my $hill_g_max = 90;      # hillslope gradient
my $wfc_min    = 1;
my $wfc_def    = 40;
my $wfc_max    = 400;     # wildfire cycle
my $fmc_min    = 1;
my $fmc_def    = 20;
my $fmc_max    = 200;     # fuel management cycle
my $rd_den_min = 0;
my $rd_den_def = 4;
my $rd_den_max = 20;      # road density

#  WEPP Biomass utilization Impacts On Soil Erosion (BIOMASS) input screen
#
#  biomass.pl -- input screen for BIOMASS
#  FSWEPP, USDA Forest Service, Rocky Mountain Research Station,
#  Soil & Water Engineering
#  Science by Bill Elliot et alia
#  Code by David Hall and Hakjun Rhee

my $version = get_version(__FILE__);
my $user_ID = get_user_id();

print "Content-type: text/html\n\n";

my $working     = '../working/';
my $custCli = '../working/' . $user_ID;  

my @climates = GetClimates($user_ID);

print <<'theEnd0';
<html>
 <head>
  <title>WEPP BIOMASS: Biomass Utilization Impacts on Soil Erosion Analysis</title>
  <META http-equiv="Content-Type" content="text/html; charset=utf-8">
  <META NAME="Name" CONTENT="WEPP BIOMASS">
  <META NAME="Brief Description" CONTENT="WEPP BIOMASS (Biomass Utilization Impacts on Soil Erosion Analysis), a component of FS WEPP, predicts soil erosion associated with fuel management practices including prescribed fire, biomass harvest, and a road network, and compares that prediction with erosion from wildfire.">
  <META NAME="Status" CONTENT="Under development; beta released 2004">
  <META NAME="Updates" CONTENT="Ongoing, online">
  <META NAME="Inputs" CONTENT="Climate station; soil texture; road density; hillslope length and gradient; buffer length; wildfire, prescribed fire, and harvest return periods">
  <META NAME="Outputs" CONTENT="Sediment delivery in year of disturbance and 'average' annual hillslope sedimentation for undisturbed forest, wildfire, prescribed fire, biomass harvest, and low and high access roads; descriptive summary of analysis">
  <META NAME="Suggested user" CONTENT="">
  <META NAME="Suggested use" CONTENT="">
  <META NAME="Keywords" CONTENT="">
  <META NAME="Contributors" CONTENT="USDA Forest Service, Rocky Mountain Research Station, Moscow, ID: model developed by Bill Elliot and Pete Robichaud; Interface programming by David Hall and Hakjun Rhee">
  <META NAME="Source" content="Run online at https://forest.moscowfsl.wsu.edu/fswepp/">
  <style>
   th.thhelpon {
    background-color: pink;
    cursor: help
   }
   th.thhelpoff {
    background-color: #85d2d2
   }
   td.tdhelpon {
    background-color: pink;
    cursor: help
   }
   td.tdhelpoff {
    background-color: #FAF8CC
   }
  </style>
theEnd0
print "
  <SCRIPT LANGUAGE = \"JavaScript\" type=\"TEXT/JAVASCRIPT\">
  <!--
  var minyear    =$year_min,   defyear    =$year_def,   maxyear=$year_max
  var total_l_min=$totl_l_min, total_l_def=$totl_l_def, total_l_max=$totl_l_max	// total hill length
  var buff_l_min =$buff_l_min, buff_l_def =$buff_l_def, buff_l_max =$buff_l_max	// buffer length
  var hill_g_min =$hill_g_min, hill_g_def =$hill_g_def, hill_g_max =$hill_g_max	// hillslope gradient
  var wfc_min    =$wfc_min,    wfc_def    =$wfc_def,    wfc_max    =$wfc_max	// wildfire cycle
  var fmc_min    =$fmc_min,    fmc_def    =$fmc_def,    fmc_max    =$fmc_max	// fuel management cycle
  var rd_den_min =$rd_den_min, rd_den_def =$rd_den_def, rd_den_max =$rd_den_max	// road density
";
print <<'theEnd0';
// START HELP STUFF

  var previous_what=''  // for show_help

  function show_help(what) {
//      write into "help_text"
//      alert('show_help')
    if (what == previous_what) {hide_help(); return}
    if (what == 'climate') {				// CLIMATE
      para='<h3>Climate file</h3>'
      para = para +'  Several climates are listed in the climate list as stock climates'
      para = para +'  to allow the user to quickly select a regional climate for an initial run.'
      para = para +'  Additional climates will be added to the list as custom/personal climates are added from this computer.'
      para = para +'  Available climates will be filtered by the user personality (a..z) chosen in the initial FS WEPP screen.'
      para = para +'  <br><br>'
      para = para +'  Most users will prefer to click the'
      para = para +'  <input type="submit" value="Custom Climate" disabled>'
      para = para +'  button and use the Rock:Clime weather file generator to select desired climates from the'
      para = para +'  2,600 sets of climate statistics available.'
      para = para +'  <br><br>'
      para = para +'  Users may select several nearby climates to determine the sensitivity of'
      para = para +'  their site to climate effects.'
      para = para +'  <br><br>'
      para = para +'  Personal climates are sorted by creation date.</font>'
    }
    if (what == 'soil_texture') {                         // SOIL TEXTURE
      para='<h3>Soil texture</h3>'
      alert ('Soil texture')
      para = para +'The erosion potential of a given soil depends on the vegetation cover, the surface residue cover,'
      para = para +'the soil texture, and other soil properies that influence soil strength.'
      para = para +'<br><br>'
      para = para +'The soil texture field contains four USDA soil textures.'
      para = para +'Once a texture is selected, the appropriate erodibility values for that texture are used for all the soil components of the seven runs.'
      para = para +'<br><br>'
      para = para +'The following table can aid in selecting the desired soil texture.'
      para = para +'The specific soil properties associated with each selection can be seen by'
      para = para +'running Disturbed WEPP or WEPP:Road, selecting the desired soil'
      para = para +'and clicking "Describe" under the Soil Texture title.'
      para = para +'Properties vary depending upon the context in which the soil texture is selected.'
      para = para +'<br><br>'
      para = para +' <blockquote>'
      para = para +' <table border=1>'
      para = para +'  <tr>'
      para = para +'   <font face="tahoma, arial, helvetica, sans serif">'
      para = para +'    <caption>'
      para = para +'     <b>'
      para = para +'      <i>Categories of Common Forest Soils in relation to ERMiT soils</i>'
      para = para +'     </b>'
      para = para +'    </caption>'
      para = para +'   </font>'
      para = para +'  </tr>'
      para = para +'  <tr>'
      para = para +'   <th bgcolor=85d2d2><font face="tahoma, arial, helvetica, sans serif">'
      para = para +'    Soil type'
      para = para +'   </font></th>'
      para = para +'   <th bgcolor=85d2d2><font face="tahoma, arial, helvetica, sans serif">'
      para = para +'    Soil Description'
      para = para +'   </font></th>'
      para = para +'   <th bgcolor=85d2d2><font face="tahoma, arial, helvetica, sans serif">'
      para = para +'    Universal Soil Classification'
      para = para +'   </font></th>'
      para = para +'  </tr>'
      para = para +'  <tr>'
      para = para +'   <th><font face="tahoma, arial, helvetica, sans serif">'
      para = para +'    Clay loam'
      para = para +'   </font></th>'
      para = para +'   <td><font face="tahoma, arial, helvetica, sans serif">'
      para = para +'    Soils derived from shales, limestone and similar decomposing fine-grained sedimentary rock.<br>'
      para = para +'    Lakebeds and similar areas of ancient lacustrian deposits'
      para = para +'   </font></td>'
      para = para +'   <td><font face="tahoma, arial, helvetica, sans serif">'
      para = para +'    CH'
      para = para +'   </font></td>'
      para = para +'  </tr>'
      para = para +'  <tr>'
      para = para +'   <th><font face="tahoma, arial, helvetica, sans serif">'
      para = para +'    Silt loam'
      para = para +'   </font></th>'
      para = para +'   <td><font face="tahoma, arial, helvetica, sans serif">'
      para = para +'    Ash cap and loess soils, soils derived from siltstone or similar sedimentary rock<br>'
      para = para +'    Highly-erodible mica/schist geologies'
      para = para +'   </font></td>'
      para = para +'   <td><font face="tahoma, arial, helvetica, sans serif">'
      para = para +'    ML,CL'
      para = para +'   </font></td>'
      para = para +'  </tr>'
      para = para +'  <tr>'
      para = para +'   <th><font face="tahoma, arial, helvetica, sans serif">'
      para = para +'    Sandy loam'
      para = para +'   </font></th>'
      para = para +'   <td><font face="tahoma, arial, helvetica, sans serif">'
      para = para +'    Glacial outwash areas; decomposed granites and sand stone, and sand deposits'
      para = para +'   </font></td>'
      para = para +'   <td><font face="tahoma, arial, helvetica, sans serif">'
      para = para +'    GP, GM, SW, SP'
      para = para +'   </font></td>'
      para = para +'  </tr>'
      para = para +'  <tr>'
      para = para +'   <th><font face="tahoma, arial, helvetica, sans serif">'
      para = para +'    Loam'
      para = para +'   </font></th>'
      para = para +'   <td><font face="tahoma, arial, helvetica, sans serif">'
      para = para +'    Glacial tills, alluvium'
      para = para +'   </font></td>'
      para = para +'   <td><font face="tahoma, arial, helvetica, sans serif">'
      para = para +'    GC, SM, SC, MH'
      para = para +'   </font></td>'
      para = para +'  </tr>'
      para = para +' </table>'
      para = para +'</blockquote>'
      para = para +'To fully describe each set of soils for WEPP requires 24 soil parameter values.'
      para = para +'Further details describing these parameters are available in the WEPP Technical Documentation'
      para = para +'(Alberts and others 1995).'
      para = para +'<br><br>'
      para = para +'<font size=-1>'
      para = para +'Alberts, E. E., M. A. Nearing, M. A. Weltz, L. M. Risse, F. B. Pierson, X. C. Zhang, J. M. Laflen, and J. R. Simanton.'
      para = para +'  1995.'
      para = para +'   <a href="https://topsoil.nserl.purdue.edu/nserlweb/weppmain/docs/chap7.pdf" target="pdf"><i>Chapter 7. Soil Component.</i></a> <b>In:</b> Flanagan, D. C. and M. A. Nearing (eds.)'
      para = para +'   <b>USDA-Water Erosion Prediction Project Hillslope Profile and Watershed Model Documentation.</b>'
      para = para +'   NSERL Report No. 10.'
      para = para +'   W. Lafayette, IN: USDA-ARS-MWA.'
      para = para +'</font>'
    }
    else if (what == 'explain_topo') {                          // HILLSLOPE HORIZONTAL LENGTH & HILLSLOPE GRADIENT
             para = '      <h3>FS WEPP BIOMASS topography</h3>'
      para = para + '   In the topography fields, the user is asked to input values for a typical horizontal slope length and steepness.'
      para = para + '   Slope lengths and steepnesses can be obtained from field surveys or contour maps.'
      para = para + '   Users may also have access to GIS topographic analysis tools to aid in estimating these values,'
      para = para + '   providing average values, or determining a range of topographic values to consider.'
      para = para + '   <br><br>'
      para = para + '   The hillslope gradients represent the top of the hill,'
      para = para + '   the overall average steepness, and'
      para = para + '   the gradient of the toe of the hill.'
      para = para + '   The top of the hill is zero if the area of interest starts at the crest of the hill.'
      para = para + '   It is likely the same as the average hillslope gradient if the treated area starts midslope.'
      para = para + '   The toe of the specified hillslope should be located in a channel.'
      para = para + '   <br><br>'
      para = para + '   The user enters <b>total hillslope horizontal length</b> and'
      para = para + '   <b>buffer horizontal length</b>.'
      para = para + '   <b>Treated hillslope horizontal length</b> is calculated by the program as the difference between these two entered values.'
      para = para + '   <br><br>'
      para = para + '   Hillslope horizontal length is the length of a hillslope as projected on a map.'
      para = para + '   <br><br>'
      para = para + '   <center>'
      para = para + '    <img src="/fswepp/images/fume/fume_topo.gif" width=320 height=220>'
      para = para + '    <br>'
      para = para + '    Cross section of a generic BIOMASS hillslope'
      para = para + '   </center>'
    }
    else if (what == 'explain_frequency') {                          // DISTURBANCE RETURN PERIOD
             para = '  <h3>Disturbance Return Period</h3>'
      para = para + '   The <b>disturbance return periods</b> are the number of years between'
      para = para + '   severe wildfire occurrence for the forest,'
      para = para + '   the planned period between prescribed fire treatments,'
      para = para + '   and the planned period between harvest treatments.'
      para = para + '   <br><br>'
      para = para + '   <b>Wildfire cycles</b> will likely range from 20 years for low elevation, dry forests, to'
      para = para + '   200 years for high elevation moist forests, to'
      para = para + '   300 years for very wet forests on the west slopes of the Cascades or the Coastal ranges.'
      para = para + '   <br><br>'
      para = para + '   <b>Prescribed fire cycles</b> can vary from 2 to 40 years, or more.'
      para = para + '   <br><br>'
      para = para + '   <b>Harvest cycles</b> vary from 10 to 80 years.'
    }
    else if (what == 'road_density') {                          // ROAD DENSITY
para = '  <h3>Road density</h3>'
para = para +'   Road density is the number of miles of road per square mile of watershed.'
para = para +'   Road segments more than 200 ft (60 m) from ephemeral or perennial channels generally can  be ignored.'
    }
    previous_what=what
    document.getElementById("help_text").innerHTML = '<div align=left><hr>'+ para +"\n"+'<br><br>[<a href="javascript:hide_help()">close</a>]<hr></div>';
  }

    function hide_help() {
//    alert('hide_help')
      previous_what=''
      document.getElementById("help_text").innerHTML = '';
    }

// END HELP STUFF

    function lengths_changed() {
// recalculate hillslope horizontal length
// recalculate pixel widths for buffer and hillslope length representations
      totalpixels  = document.total.width * 1
      bufferlength = document.fume.buffl.value * 1
      totallength  = document.fume.totall.value * 1
       if (bufferlength>=totallength) {
     alert('Buffer length (' + bufferlength + ') must be less than total length (' + totallength + ')')
         bufferlength=totallength-0.1
         if (bufferlength<buff_l_min) {bufferlength=buff_l_min; totallength=bufferlength+0.1}
//       document.fume.hilll.value=0
         document.fume.buffl.value=bufferlength
         document.fume.hilll.value=totallength
       }
      hilllength   = totallength - bufferlength
      bufferpixels = totalpixels * bufferlength / totallength
      hillpixels   = totalpixels - bufferpixels
      document.fume.hilll.value=hilllength
      document.buffer.width=bufferpixels
      document.hillslope.width=hillpixels
    }

theEnd0
print <<'theEnd';

  function submitme(which) {
    document.forms.fume.achtung.value=which
    document.forms.fume.submit()
    return true
  }

  function isNumber(inputVal) {
  // Determine whether a suspected numeric input
  // is a positive or negative number.
  // Ref.: JavaScript Handbook. Danny Goodman. listing 15-4, p. 374.
  oneDecimal = false                              // no dots yet
  inputStr = "" + inputVal                        // force to string
  for (var i = 0; i < inputStr.length; i++) {     // step through each char
    var oneChar = inputStr.charAt(i)              // get one char out
    if (i == 0 && oneChar == "-") {               // negative OK at char 0
      continue
    }
    if (oneChar == "." && !oneDecimal) {
      oneDecimal = true
      continue
    }
    if (oneChar < "0" || oneChar > "9") {
      return false
    }
  }
  return true
  }

  function MakeArray(n) {     // initialize array of length *n* [Goodman p
    this.length = n; for (var i = 0; i<n; i++) {this[i] = 0} return this
  }

theEnd

print <<'theEnd';

  function pcover1() {        // change ofe1 pcover to default for selected
    var which = window.document.fume.UpSlopeType.selectedIndex;
    window.document.fume.ofe1_pcover.value=default_pcover[which];
    return false;
  }

  function pcover2() {        // change ofe2 pcover to default for selected
    var which = window.document.fume.LowSlopeType.selectedIndex;
    window.document.fume.ofe2_pcover.value=default_pcover[which];
    return false;
  }


function RunningMsg (obj, text) {
//  var hill_l=parseFloat(document.forms[0].hillslope_length.value)
//  var buff_l=parseFloat(document.forms[0].buffer_length.value)
    var hill_l=parseFloat(document.forms[0].totall.value)
    var buff_l=parseFloat(document.forms[0].buffl.value)
    var buff_plus_one=buff_l+1
    if (hill_l < buff_l) {document.forms[0].totall.value=buff_plus_one}
    if (checkYears(document.forms[0].climyears)) {
       obj.value=text
       return true
    }
    else {
       return false
    }
}

function RunningMsgZ (obj, text) {
       obj.value=text
}

  function checkRange(obj,min,max,def,unit,thistext) {
     if (isNumber(obj.value)) {                   // obj == document.fume.BS
       if (obj.value < min) {                     // min == BSmin
         alert_text=thistext + " must be between " + min + " and " + max + unit
         alert(alert_text)
         obj.value=min
       }
       if (obj.value > max){
         alert_text=thistext + " must be between " + min + " and " + max + unit
         alert(alert_text)
         obj.value=max
       }
     }
     else {
         alert("Invalid entry for " + thistext + "!")
         obj.value=def
         lengths_changed()
         return 0;
    }
    lengths_changed()
  }

function blankStatus()
{
  window.status = ""
  return true                           // p. 86
}

  function checkYears(obj) {
     if (isNumber(obj.value)) {
       obj.value = Math.round(obj.value)
       var alert_text = "Number of years must be between " + minyear + " and " + maxyear 
       if (obj.value < minyear){
         alert(alert_text)
         obj.value=minyear
         return true
       }
       if (obj.value > maxyear) {
         alert(alert_text)
         obj.value=maxyear
         return false
       }
     }
     else {
         alert("Invalid entry for number of years!")
         obj.value=defyear
         return true
     }
  }

function showRange(obj, head, min, max, unit) {
  range = head + min + " to " + max + unit	
  window.status = range
  return true                           // p. 86
}

function showHelp(obj, head, min, max, unit) {
  var which = window.document.fume.SlopeType.selectedIndex;
     if (which == 0) {vhead = "Ditch width + traveledway width: "}
     else if (which == 1) {vhead = "Ditch width + traveledway width: "}
     else if (which == 2) {vhead = "Traveledway width: "}
     else {vhead = "Rut spacing + rut width: "}
  range = vhead + min + " to " + max + unit	
  window.status = range
  return true                           // p. 86
}

function showTexture() {
  var which = window.document.fume.SoilType.selectedIndex;
  if (which == 0)             //clay loam
     {text = "Native-surface roads on shales and similar decomposing sedimentary rock (MH, CH)"}
   else if (which == 2)       // silt loam
     {text = "Ash cap native-surface road; alluvial loess native-surface road (ML, CL)"}
   else if (which == 1)       // sandy loam
     {text = "Glacial outwash areas; finer-grained granitics (SW, SP, SM, SC)"}
   else                       // loam
     {text = "Loam"}
   window.status = text
   return true                           // p. 86
}

  // end hide -->
  </SCRIPT>
</head>
theEnd
print
' <BODY bgcolor="white" link="#000000" vlink="#000000" alink="red">
  <font face="tahoma, arial, helvetica, sans serif">
   <table width=100% border=0>
    <tr>
     <td>
      <a href="/fswepp/">
       <IMG src="/fswepp/images/fsweppic2.jpg" alt="Erosion Analysis" align="left" border=0 width="95" height="95">
      </a>
     </td>
     <!-- td align=center bgcolor="#006009" -->
     <td align=center>
       <hr>
       <h3>WEPP <font color="#006009">BIOMASS</font><br>
           <font color="#006009">Biomass</font> Utilization Impacts on Soil Erosion Analysis</h3>
       <hr>
    <td>
       <A HREF="https://www.fs.fed.us/rm/pubs_other/rmrs_2010_elliot_w001.pdf" target="docs">
       <IMG src="/fswepp/images/epage.gif"
        align="right" title="Effects of Forest Biomass Use on Watershed Processes in the Western United States [pdf]" border=0></a>
    </table>
  <center>

<br>
 <table width=90% border=0 bgcolor="pink">
  <tr>
   <td>
    <font size=-1 id="help_text">  <!-- this is where the help text gets displayed -->
    </font>
   </td>
  </tr>
 </table>
<br>

  <form name="fume" method="post" ACTION="/cgi-bin/fswepp/biomass/wb.pl">
  <table border="1">
';
print <<'theEnd';
     <tr align="top">

    <th class="thhelpoff"
        onmouseover="className='thhelpon'" onmouseout="className='thhelpoff'"
        onClick="JavaScript:show_help('climate')">
     <font face="Arial, Geneva, Helvetica">
       <a title="* Personal climate (your computer created)">(*)</a> &nbsp;&nbsp;
       <a href="#" onclick="
          var climateValue = document.getElementById('Climate').value;
          window.location.href = '/cgi-bin/fswepp/rc/descpar.pl?CL=' + climateValue + '&units=$units'">Climate</a>&nbsp;&nbsp;
       <a title="+ Climate parameters modified">(+)
     </font>
    </th>

    <th class="thhelpoff"
        onmouseover="className='thhelpon'" onmouseout="className='thhelpoff'"
        onClick="JavaScript:show_help('soil_texture')">
     <font face="Arial, Geneva, Helvetica">Soil texture</font>
    </th>

    <th class="thhelpoff"
        onmouseover="className='thhelpon'" onmouseout="className='thhelpoff'"
        title="Explain road density (miles of road per square mile of territory)"
        onClick="JavaScript:show_help('road_density')">
     <font face="Arial, Geneva, Helvetica">Road density (mi mi<sup>-2</sup>)</font>
    </th>

     </tr>
    <tr align=top>
       <TD align="center" bgcolor="lightblue">
        <SELECT NAME="Climate" id="Climate" SIZE="5">
theEnd


foreach my $ii ( 0 .. $#climates ) {
    print '<OPTION VALUE="', $climates[$ii]->{'clim_file'}, '"';
    print ' selected' if $ii == 0;
    print '> ', $climates[$ii]->{'clim_name'}, "\n";
}

print '      </SELECT>
      </td>
      <TD align="center" bgcolor="lightblue">
       <SELECT NAME="SoilType" SIZE="4"
        onChange="showTexture()"
        onBlur="blankStatus()">
        <OPTION VALUE="clay" selected>clay loam
        <OPTION VALUE="silt">silt loam
        <OPTION VALUE="sand">sandy loam
        <OPTION VALUE="loam">loam
       </SELECT>
      </td>
     <td align="center" bgcolor="lightblue">
      <input type="text" size="5" name="road_density" value="4"
        onChange="checkRange(this.form.road_density,rd_den_min,rd_den_max,rd_den_def,\' mi/sq mi\',\'road density\')"
        title="Road density: ', $rd_den_min, ' to ', $rd_den_max, '">
     </td>
      </tr>
      <tr>
       <td align=center>
        <input type="hidden" size="5" name="climyears" value="50">
        <input type="hidden" name="achtung" value="Run BIOMASS">
        <button type="button" onclick="window.location.href='/cgi-bin/fswepp/rc/rockclim.pl?comefrom=biomass&units=$units'">Custom Climate</button>
       </td>
      </tr>
    </table>

<!--
   <table border="2">
    <tr>
     <th bgcolor="#006009">
      <font face="tahoma, arial, helvetica, sans serif" color="#99ff00">
       Road density (mi mi<sup>-2</sup>)
     </td>
    </tr>
    <tr>
     <th bgcolor="lightblue">
      <font face="tahoma, arial, helvetica, sans serif">
       Simulation period (yr)
     </td>
     <td>
      <input type="text" size="5" name="climyears" value="5"
        onChange="checkYears(this.form.climyears)"
        title="Years to simulate: ', $year_min, ' to ', $year_max, '">
     </td>
    </tr>
   </table>
-->
   <br>

   <table border=2 cellpadding=4>
    <tr>
     <th colspan=4 class="thhelpoff" onmouseover="className=\'thhelpon\'" onmouseout="className=\'thhelpoff\'" onClick="JavaScript:show_help(\'explain_topo\')">
      <font face="Arial, Geneva, Helvetica">Hillslope horizontal length (ft)</font>
     </th>
    </tr>
    <tr>
     <td>
     </td>
     <td>
      <img src="/fswepp/images/gold.gif" width="100" height="20" name="total" border="0">
     </td>
     <td bgcolor="lightblue">
      <font face="tahoma, arial, helvetica, sans serif">
       <input type="text" size=8 value="200" name="totall"
        onChange="checkRange(this.form.totall,total_l_min,total_l_max,total_l_def,\' ft\',\'hillslope length\');return true"
        title="Hillslope length: ', $totl_l_min, ' to ', $totl_l_max, '">
       <b><a title="Horizontal length of hillslope, including buffer">Total hillslope</a></b>
      </font>
     </td>
    </tr>
    <tr>
     <td>
      <font face="tahoma, arial, helvetica, sans serif">
       <b>
        Treated hillslope <input type="text" size=8 name="hilll" disabled value="150">
       </b>
      </font>
     </td>
     <td>
      <img src="/fswepp/images/orange.gif" width="75" height="20" name="hillslope" border="0"><img src="/fswepp/images/green.gif" width="25" height="20" name="buffer" border="0">
     </td>
     <td bgcolor="lightblue">
      <font face="tahoma, arial, helvetica, sans serif">
       <input type="text" size=8 name="buffl" value="50"
        onChange="checkRange(this.form.buffl,buff_l_min,buff_l_max,buff_l_def,\' ft\',\'buffer length\');return true"
        title="Buffer length: ', $buff_l_min, ' to ', $buff_l_max, '">
       <b><a title="Horizontal length of hillslope buffer">Buffer</a></b>
      </font>
     </td>
    </tr>
   </table>

   <br>

 <table>
  <tr>
   <td>

   <table border=1 cellpadding=4>
    <tr>
     <th colspan=3 class="thhelpoff"
         onmouseover="className=\'thhelpon\'" onmouseout="className=\'thhelpoff\'"
         onClick="JavaScript:show_help(\'explain_topo\')"
         title="Explain hillslope gradient">
      <font face="Arial, Geneva, Helvetica">Hillslope gradient (%)</font>
     </th>
    </tr>
    <tr>
     <th bgcolor="lightblue" title="Gradient of hillslope top (%)">
      <font face="tahoma, arial, helvetica, sans serif">
       <b>Top</b>
       <br>
       <input type="text" size=8 value="0" name="ofe1_top_slope"
              onChange="checkRange(this.form.ofe1_top_slope,hill_g_min,hill_g_max,hill_g_def,\' %\',\'hillslope gradient\')"
              title="Hillslope top gradient: ', $hill_g_min, ' to ',
  $hill_g_max, '">
      </font>
     </th>
     <th bgcolor="lightblue" title="Gradient of hillslope middle (percent)">
      <font face="tahoma, arial, helvetica, sans serif">
       <b>Middle</b>
       <br>
       <input type="text" size=8 value="30" name="ofe1_mid_slope"
              onChange="checkRange(this.form.ofe1_mid_slope,hill_g_min,hill_g_max,hill_g_def,\' %\',\'hillslope gradient\')"
              title="Hillslope middle gradient: ', $hill_g_min, ' to ',
  $hill_g_max, '">
      </font>
     </th>
     <th bgcolor="lightblue" title="Gradient of hillslope toe (%)">
      <font face="tahoma, arial, helvetica, sans serif">
       <b>Toe</b>
       <br>
       <input type="text" size=8 value="15" name="ofe2_bot_slope"
              onChange="checkRange(this.form.ofe2_bot_slope,hill_g_min,hill_g_max,hill_g_def,\' %\',\'hillslope gradient\')"
              title="Hillslope toe gradient: ', $hill_g_min, ' to ',
  $hill_g_max, '">
      </font>
     </th>
    </tr>
   </table>
   
   </td><td>

   <table border=1 cellpadding=4>
    <tr>
     <th colspan=4 class="thhelpoff"
         onmouseover="className=\'thhelpon\'" onmouseout="className=\'thhelpoff\'"
         onClick="JavaScript:show_help(\'explain_frequency\')"
         title="Explain disturbance return period">
      <font face="Arial, Geneva, Helvetica">Disturbance return period (y)</font>
     </th>
    </tr>
    <tr>
     <th bgcolor="lightblue" title="Number of years between wildfires">
      <font face="tahoma, arial, helvetica, sans serif">
        Wildfire
       <br>
       <input type="text" size=8 value="40" name="wildfire_cycle"
        onChange="checkRange(this.form.wildfire_cycle,wfc_min,wfc_max,wfc_def,\' yr\',\'wildfire cycle\')"
        title="Wildfire cycle: ', $wfc_min, ' to ', $wfc_max, '">
      </font>
     </th>
     <th bgcolor="lightblue" title="Number of years between prescribed fires">
      <font face="tahoma, arial, helvetica, sans serif">
        Prescribed fire
       <br>
       <input type="text" size=8 value="20" name="rx_fire_cycle"
        onChange="checkRange(this.form.rx_fire_cycle,fmc_min,fmc_max,fmc_def,\' yr\',\'prescribed fire cycle\')"
        title="Prescribed fire cycle: ', $fmc_min, ' to ', $fmc_max, '">
      </font>
     </th>
     <th bgcolor="lightblue" title="Number of years between harvests">
      <font face="tahoma, arial, helvetica, sans serif">
        Harvest
       <br>
       <input type="text" size=8 value="20" name="harvest_cycle"
        onChange="checkRange(this.form.harvest_cycle,fmc_min,fmc_max,fmc_def,\' yr\',\'harvest cycle\')"
        title="Harvest cycle: ', $fmc_min, ' to ', $fmc_max, '">
      </font>
     </th>
    </tr>
   </table>

   </td>
  </tr>
 </table>

      </b>
     </p>

<!--
      <input type="radio" name="units" value="m"><b>metric</b>
      <input type="radio" name="units" value="ft" checked><b>English</b>
-->

     <p>
      <input type="SUBMIT" name="actionw" VALUE="Run BIOMASS"
       onClick=\'RunningMsg(this.form.actionw,"Running BIOMASS..."); this.form.achtung.value="Run WEPP BIOMASS"\'>
      <br>
     </p>
    </center>
   </form>
  <P>
   <hr>
    <table border=0>
     <tr>
      <td valign="top" bgcolor="lightgoldenrodyellow">
       <font face="tahoma, arial, helvetica, sans serif" size=1>
        The FS WEPP BIOMASS interface predicts soil erosion associated with fuel management practices including prescribed fire,
        biomass harvest, and a road network, and compares that prediction to erosion from wildfire.
       </font>
      </td>
      <td valign="top">
      </td>
     </tr>
     <tr>
      <td valign="top">
       <font face="tahoma, arial, helvetica, sans serif" size=1>
        WEPP BIOMASS input interface v.
        <a href="javascript:popuphistory()"> ', $version, '</a>
        by
        David Hall and Hakjun Rhee<br>
        Model developed by Bill Elliot &amp; Pete Robichaud, USDA Forest Service, Rocky Mountain Research Station, Moscow, ID
       </font>
      </td>
     </tr>
    </table>
';

$remote_host    = $ENV{'REMOTE_HOST'};
$remote_address = $ENV{'REMOTE_ADDR'};

# $wc  = `wc ../working/_2016/wb.log`;
$wc    = `wc ../working/_2017/wb.log`;
@words = split " ", $wc;
$runs  = @words[0];


print "  <font face='tahoma, arial, helvetica, sans serif' size=1>
$user_ID<br>
   <b>$runs</b> WEPP BIOMASS runs YTD
   <br><br>
    This project was supported by the Agriculture and Food Research Initiative,
    Biomass Research and Development Initiative,
    Competitive Grant no. 2010-05325 from the USDA National Institute of Food and Agriculture.
  </font>
 </body>
</html>
";
