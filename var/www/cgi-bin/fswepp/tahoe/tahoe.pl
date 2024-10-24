#!/usr/bin/perl

use CGI;
use CGI qw(escapeHTML);

use MoscowFSL::FSWEPP::FsWeppUtils qw(get_version get_user_id);
use MoscowFSL::FSWEPP::CligenUtils qw(GetClimates GetFutureClimates);
#
#  Tahoe Basin Sediment Model input screen
#

#  tahoe.pl -- input screen for Tahoe Basin Sediment Model

#  2009.08.24 DEH Modify Disturbed WEPP input screen weppdist.pl for Tahoe Basin Sediment Model

## BEGIN HISTORY ###################################
## Tahoe Basin Sediment Model version history

my $version = get_version(__FILE__);
my $user_ID = get_user_id();

my $cgi = CGI->new;

my $units = escapeHTML( $cgi->param('units') );

my $areaunits;
if    ( $units eq 'm' )  { $areaunits = 'ha' }
elsif ( $units eq 'ft' ) { $areaunits = 'ac' }
else                     { $units     = 'ft'; $areaunits = 'ac' }
my $fc = escapeHTML( $cgi->param('fc') );

my $working = '../working/';                       # DEH 08/22/2000
my $logFile = '../working/' . $user_ID . '.log';
my $custCli = '../working/' . $user_ID;            # DEH 03/02/2001

########################################

$num_cli = 0;

my @climates;

if ($fc) {
    @climates = GetFutureClimates('../rc/tahoe/fc/');
}
else {
    @climates = GetClimates($user_ID);
}

###################################################

print "Content-type: text/html\n\n";
print <<'theEnd2';
<html>
<head>
<title>Tahoe Basin Sediment Model</title>
  <META http-equiv="Content-Type" content="text/html; charset=utf-8">
  <META NAME="Name" CONTENT="Tahoe Basin Sediment Model">
  <META NAME="Brief Description" CONTENT="Tahoe Basin Sediment Model, a component of FS WEPP, predicts sedimentation and erosion from rangeland, forestland, and forest skid trails.
   The interface presents the probability of a given level of sedimentation and erosion occurring the year following a disturbance.">
  <META NAME="Status" CONTENT="Released 2010">
  <META NAME="Updates" CONTENT="Ongoing, online">
  <META NAME="Inputs" CONTENT="Climate station; soil texture; upper and lower element treatment, gradient, horizontal length, cover, and rock content">
  <META NAME="Outputs" CONTENT="Annual average precipitation; runoff from rainfall; runoff from snowmelt or winter rainstorm; upland erosion rate; sediment leaving profile; return period analysis of precipitation, runoff, erosion, and sediment; probabilities of occurrence first year following disturbance of runoff, erosion, and sediment delivery">
  <META NAME="Suggested user" CONTENT="">
  <META NAME="Suggested use" CONTENT="">
  <META NAME="Keywords" CONTENT="">
  <META NAME="Contributors" CONTENT="USDA Forest Service, Rocky Mountain Research Station, Moscow, ID: Bill Elliot and David Hall">
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
  <SCRIPT LANGUAGE = "JavaScript" type="TEXT/JAVASCRIPT">
  <!--

  var minyear = 1
  var maxyear = 200
  var defyear = 30

  var sunit = '%'
  var smin = 0
  var smax = 100
  var ofe1tsdef = 0
  var ofe1msdef = 30
  var ofe2tsdef = 30
  var ofe2bsdef = 5

  var pcunit = '%'
  var pcmin = 0
  var pcmax = 150
  var pcdef = 100

  var runit = '%'
  var rmin = 1
  var rmin = 0
  var rmax = 50
  var rdef = 20

  var previous_what=''  // for show_help
theEnd2

if   ($fc) { print "  var NowIs = 'future'\n"; }
else       { print "  var NowIs = 'current'\n"; }

print "
function click_future() {
//   alert ('future')
// location.href = \"/cgi-bin/fswepp/tahoe/tahoepfc.pl?units=$units&fc=1\";
   location.href = \"/cgi-bin/fswepp/tahoe/tahoe.pl?units=$units&fc=1\";	// 2012.11.14
   NowIs='future';
}

function click_present() {
//   alert ('present')
// location.href = \"/cgi-bin/fswepp/tahoe/tahoepfc.pl?units=$units\";
   location.href = \"/cgi-bin/fswepp/tahoe/tahoe.pl?units=$units\";        // 2012.11.14
   NowIs='present';
}
";
print <<'theEnd2';
function popupclosest() {
url = '/fswepp/rc/closest.php?units=ft';
width=900;
height=600;
popupwindow = window.open(url,'popupwindow','toolbar=no,location=no,status=no,directories=no,menubar=no,scrollbars=yes,resizable=yes,width='+width+',height='+height);
popupwindow.focus()
}

theEnd2

if ( $units eq "m" ) {
    $lunit = ' m';
    $lmin  = 0.5;
    $lmax  = 400;
    $ldef  = 50;
}
else {
    $lunit = ' ft';
    $lmin  = 1.5;
    $lmax  = 1200;
    $ldef  = 150;
}

print "  var lunit = '$lunit'
  var lmin = $lmin
  var lmax = $lmax
  var ldef = $ldef
";

print <<'theEnd';

  function show_help(what) {
//      write into "help_text"
//      alert('show_help')
    if (what == previous_what) {hide_help(); return}
    if (what == 'fines') {				// FINE PARTICLE DELIVERY
      para='<h3>Fine particle delivery</h3>'
para =para+' Total delivery of sand, silt, and clay size particles, including the fraction of sand, silt and clay in each of the particle classes, is estimated by WEPP.'
para =para+' The fraction of each particle in the two aggregate classes in the delivered sediment is multiplied by'
para =para+'  the fraction of the primary particle in that class, and then by the sediment yield,'
para =para+'  to determine the amount of each primary particle size delivered.'
para =para+'  To estimate the total delivery of fines, the delivery of all clay particles, plus a fraction of the silt particles smaller'
para =para+'  than the specified maximum size, is interpolated for the maximum particle size requested.'
    }
    if (what == 'phosphorus') {				// PHOSPHORUS CONCENTRATION
      para='<h3>Phosphorus concentration</h3>'
para =para+'<blockquote>'
para =para+' Enter typical concentrations of phosphorus observed in soil water, in surface runoff, and adsorbed to delivered sediment or measured in sediment transported from the site.'
para =para+' <br><br>'
para =para+' Observed phosphorus concentrations in Tahoe Basin forests'
para =para+' <blockquote>'
para =para+'  <table border=0>'
para =para+'   <tr>'
para =para+'    <td valign=top>'
para =para+'     <table border=0>'
para =para+'      <tr><td colspan=4><h4>Surface runoff concentration</h4></td></tr>'
para =para+'      <tr><td width=15></td><td colspan=2>Surface/Interflow</th>   <td align=right>0.004-0.75&nbsp;mg/l</td><td><sup>a</sup></td></tr>'
para =para+'      <tr><td colspan=4><h4>Subsurface lateral flow concentration</h4></td></tr>'
para =para+'      <tr><td></td><td colspan=2>Soil solution (lateral flow)</th> <td align=right>    5-10&nbsp;mg/l</td><td><sup>b</sup></td></tr>'
para =para+'      <tr><td></td><td colspan=2>Soil water in Oi horizon</th>     <td align=right>     4-6&nbsp;mg/l</td><td><sup>c</sup></td></tr>'
para =para+'      <tr><td colspan=4><h4>Sediment concentration</h4></td></tr>'
para =para+'      <tr><td></td><td>Volcanic&nbsp;colluvium</td><td> unburned </td>  <td align=right>    340&nbsp;mg/kg</td><td><sup>d</sup></td></tr>'
para =para+'      <tr><td></td><td>               </td><td>     burned  </td>  <td align=right> 40-500&nbsp;mg/kg</td></tr>'
para =para+'      <tr><td></td><td>Glacial outwash</td><td>     unburned</td>  <td align=right> 60-740&nbsp;mg/kg</td></tr>'
para =para+'      <tr><td></td><td>               </td><td>     burned  </td>  <td align=right> 85-110&nbsp;mg/kg</td></tr>'
para =para+'      <tr><td></td><td>Mixed colluvium</td><td>     unburned</td>  <td align=right>110-840&nbsp;mg/kg</td></tr>'
para =para+'      <tr><td></td><td>               </td><td>     burned  </td>  <td align=right>120-220&nbsp;mg/kg</td><td></tr>'
para =para+'      <tr></tr>'
para =para+'      <tr>'
para =para+'       <td colspan=4><font size=-1>'
para =para+'                     <sup>a</sup> Reuter and Miller, 2000<br>'
para =para+'                     <sup>b</sup> Johnson, 2001<br>'
para =para+'                     <sup>c</sup> Loupe, 2007<br>'
para =para+'                     <sup>d</sup> Traeumer et al., 2012</td>'
para =para+'       </font></td>'
para =para+'      </tr>'
para =para+'     </table>'
para =para+'    </td>'
para =para+'    <td width=570>'
para =para+'     <img src="/fswepp/images/PhosphorusConcentrationMap567x428.png" width=567 height=428>'
para =para+'    </td>'
para =para+'   </tr>'
para =para+'  </table>'
para =para+' </blockquote>'
    }
    if (what == 'geometry') {				// GEOMETRY (GRADIENT, HORIZONTAL LENGTH)
para='<h3>Gradients and Horizontal Lengths</h3>'
para = para +'  The user may visualize the slope profile as a line running up and down the hill, having a representative width which applies to the entire hillslope or a portion of the hillslope.'
para = para +'<br><br>'
para = para +'  The WEPP model allows the user to simulate many types of nonuniformities on a hillslope through the use of Overland Flow Elements (OFEs).'
para = para +'  Each hillslope OFE is a region of homogeneous soils, vegetation, and management.'
para = para +'  The Tahoe Basin model uses two OFEs&ndash;the "upper element" and the "lower element."'
para = para +'<br><br>'
para = para +'  The user enters four surface slope <b>gradients</b>, labeled (A) through (D) in the figure below, '
para = para +'to describe the profile&ndash;the top and middle gradient of the upper element, '
para = para +' and the middle and toe gradient of the lower element&ndash;and the <b>horizontal length</b> (E) and (F) '
para = para +' of each element. '
para = para +'Horizontal length is measured from topographic maps, Google Earth distance, by ruler, or GIS.'
para = para +'<br><br>'
para = para +'  The slope profile must be described to the end of the field, or to a concentrated flow channel, grassed waterway, or terrace.'
para = para +'<br><br>'
para = para +'<img src="/fswepp/images/wdwt_topo.gif" width=320 height=220'
    }
    if (what == 'climate_buttons') {			// CLIMATE BUTTONS
      if (NowIs == 'future') {
para='<h3>Climate modeling options</h3>'
para = para + ' <blockquote>'
para = para + '  <input type=button value="Current climates"> Display climates available for current climate scenarios'
para = para + '  <br><br>'
para = para + '  Note that one should select the climate scenario before entering other input values, as parameter values will all be reset to their default values upon switching between Cuurent and Future climate scanarios.'
para = para + ' </blockquote>'
      } else {
para='<h3>Climate modeling options</h3>'
para = para + ' <blockquote>'
para = para + '  <table border=0>'
para = para + '   <tr>'
para = para + '    <td><input type=button value="Custom"> </td><td>Select a new current climate, and optionally modify it, for use</td></tr>'
para = para + '    <td><input type=button value="Future"> </td><td>Display climates available for future climate scenarios for the Tahoe Basin</td></tr>'
para = para + '    <td><input type=button value="Closest"></td><td>Find the geographically closest climate station given latitude and longitude (pop-up)</td>'
para = para + '   </tr>'
para = para + '  </table>'
para = para + '  Note that one should select the climate scenario before entering other input values, as parameter values will all be reset to their default values upon switching between Cuurent and Future climate scanarios.'
para = para + ' </blockquote>'
      }
    }
    if (what == 'climate') {				// CLIMATE
      if (NowIs == 'future') {
//       alert('future help here')
para='<h3>Future climate</h3>'
para = para +'  <font size=-1></b>'
para = para +'   We developed future climate files based on Coats\' downscaled climate data for eight station locations in the Tahoe Basin. '
para = para +'   These future climate scenarios were developed using scaling factors to relate Coats\' locations to our stations using'
para = para +'   800-m resolution, 30-year average PRISM maps.'
para = para +'   <br><br>'
para = para +'   Coats et al. used the Geophysical Fluid Dynamics Laboratory Model and the Parallel Climate Model to provide'
para = para +'   100-year records of daily future climate projections for the A2 and B1 emissions scenarios.'
para = para +'   These daily data were disaggregated into hourly data by Riverson using observed hourly data trends from historic weather'
para = para +'   records at SNOTEL sites in the basin.'
para = para +'   These data were used to drive the LSPC hydrology and water quality model.'
para = para +'   <br><br>'
para = para +'   Note that multiple climate scenarios are independent predictions, so simulations cannot be compared on a day to day,'
para = para +'   nor even a year to year, basis.'
para = para +'  </font>'
      } else {
para='<h3>Climate file</h3>'
para = para +'  <font size=-1>Climate station names are indicated as <b>[Ownership] Station name [Status]</b>'
para = para +'  '
para = para +'  <table border=0 cellpadding=10>'
para = para +'   <tr><td>'
para = para +'    <table align=center border=1>'
para = para +'     <tr><th colspan=2 bgcolor=gold><font size=-1>Ownership</font></th></tr>'
para = para +'     <tr><th> * </th><td><font size=-1>Personal climate (your computer created)</font></td></tr>'
para = para +'     <tr><th>&nbsp;<td><font size=-1>Standard-issue climate</font></td></tr>'
para = para +'    </table>'
para = para +'   </td><td>'
para = para +'    <table align=center border=1>'
para = para +'     <tr><th colspan=2 bgcolor=gold><font size=-1>Status</font></th></tr>'
para = para +'     <tr><th> +    <td><font size=-1>Climate parameters modified</font></td></tr>'
para = para +'     <tr><th>&nbsp;<td><font size=-1>Climate parameters unmodified</font></td></tr>'
para = para +'     </table>'
para = para +'     </td</tr>'
para = para +'  </table>'
para = para + ' <br>'
para = para +'  Several climates are listed in the climate list as stock climates'
para = para +'  to allow the user to quickly select a regional climate for an initial run.'
para = para +'  Additional climates will be added to the list as custom/personal climates are added from this computer.'
para = para +'  Available climates will be filtered by the user personality (a..z) chosen in the initial FS WEPP screen.'
para = para +'  <br><br>'
para = para +'  Most users will prefer to click the'
para = para +'  <input type="submit" value="Custom" disabled>'
para = para +'  button and use the Rock:Clime weather file generator to select desired climates from the'
para = para +'  2,600 sets of climate statistics available.'
para = para +'  The <input type="submit" value="Future" disabled> button offers future climate scenario files for the Tahoe Basin.'
para = para +'  <br><br>'
para = para +'  Users may select several nearby climates to determine the sensitivity of'
para = para +'  their site to climate effects.'
para = para +'  <br><br>'
para = para +'  Personal climates are sorted by creation date.</font>'
      }
    }
    if (what == 'gradient') {				// GRADIENT
para='<h3>Gradient</h3>'
para = para +' The Tahoe Basin Sediment Model uses two "overland flow elements" &ndash; an upper and a lower.'
para = para +' The user specifies the surface slope by entering the horizontal length of each element,'
para = para +' and the gradient at the top and midway down the upper element,'
para = para +' and midway and at the toe of the lower element.'
    }
    else if (what == 'soil_texture') {			// SOIL TEXTURE
para ='   <h3>Soil Texture</h3>'
para = para +' The user may specify a soil texture for the two elements.'
para = para +' Choices are Granitic, Volcanic, Alluvial, and Rock/Pavement.'
para = para +' If the user selects Rock/Pavement, parameter values appropriate for a rock/pavement texture are used for the'
para = para +' upper element, and values appropriate for alluvial soil are used for the lower element.'
para = para +' <br><br>'
para = para +'\'Mature forest\' and \'Thin or young forest\' are not valid for the upper element vegetation for Rock/Pavement soil texture.'
    }
    else if (what == 'cover') {				// COVER
para='<h3>Cover</h3>';
para = para +' Cover includes litter, duff, branches, logs, and--most importantly in the context of fire--rock greater than 2 mm diameter. The user can change the cover value to what was observed on site, and this value will be held constant for the entire WEPP run.'
para = para +' <br><br>'
para = para +' One\'s selection of the treatment will set a suggested value for cover, with the exception of treatment "Bare."'
para = para +' The "Bare" treatment uses for cover the current value for percent rock.'
para = para +' The suggested cover value for each treatment is:'
para = para +' <br><br>'
para = para +'   <table border=1>'
para = para +'    <tr><th>Treatment</th><th>Cover</th><th>Treatment</th><th>Cover</th></tr>'
para = para +'    <tr><td><font size=-1>mature forest</font></td>      <td align=right><font size=-1>100%</font></td>'
para = para +'    <td><font size=-1>thin or young forest</font></td>   <td align=right><font size=-1>100%</font></td></tr>'
para = para +'    <tr><td><font size=-1>shrubs</font></td>             <td align=right><font size=-1> 80%</font></td>'
para = para +'    <td><font size=-1>good grass</font></td>             <td align=right><font size=-1> 60%</font></td></tr>'
para = para +'    <tr><td><font size=-1>poor grass</font></td>         <td align=right><font size=-1> 40%</font></td>'
para = para +'    <td><font size=-1>low severity fire</font></td>      <td align=right><font size=-1> 85%</font></td></tr>'
para = para +'    <tr><td><font size=-1>high severity fire</font></td> <td align=right><font size=-1> 45%</font></td>'
para = para +'    <td><font size=-1>bare</font></td>                   <td align=right><font size=-1>=rock%</font></td></tr>'
para = para +'    <tr><td><font size=-1>mulch only</font></td>         <td align=right><font size=-1> 60%</font></td>'
para = para +'    <td><font size=-1>mulch and till</font></td>         <td align=right><font size=-1> 80%</font></td></tr>'
para = para +'    <tr><td><font size=-1>low traffic road</font></td>   <td align=right><font size=-1> 10%</font></td>'
para = para +'    <td><font size=-1>high traffic road</font></td>      <td align=right><font size=-1> 10%</font></td></tr>'
para = para +'    <tr><td><font size=-1>burn pile</font></td>          <td align=right><font size=-1> 20%</font></td>'
para = para +'    <td><font size=-1>skid trail</font></td>             <td align=right><font size=-1> 10%</font></td></tr>'
para = para +'   </table>'
    }
    else if (what == 'restrictive_layer') {		// RESTRICTIVE LAYER
para = '<h3>Restrictive layer</h3>'
para = para +'    Click the checkbox next to "Restrictive layer" to specify the name of the bedrock that forms'
para = para +'    the soil\'s restrictive layer.'
para = para +'    Suggested values for that rock type will be displayed for saturated hydraulic conductivity.'
para = para +'    <br><br>'
para = para +'    If the Restriction checkbox is unchecked, then a restrictive layer is not present and the old'
para = para +'    (standard) soil input is used.'
    }
    else if (what == 'vegetation_treatment') {		// TREATMENT
para = '  <h3>Vegetation/Treatment</h3>'
para = para +'  <font size=-1>'
para = para +'   The Tahoe Basin Sediment Model provides fourteen categories of vegetation or treatment.'
para = para +'   A default cover is associated with each vegetation treatment, '
para = para +'   but users are encouraged to alter this value to suit site conditions.'
para = para +'   The vegetation treatments are:'
para = para +'   <br><br>'
para = para +'   <table border=1 cellpadding=4>'
para = para +'    <tr><th><font size=-1>Vegetation/<br>treatment</th>       <th><font size=-1>Default<br>cover</th>'
para = para +'        <th><font size=-1>Vegetation/<br>treatment</th>       <th><font size=-1>Default<br>cover</th>'
para = para +'        <th><font size=-1>Vegetation/<br>treatment</th>       <th><font size=-1>Default<br>cover</th></tr>'
para = para +'    <tr><td><font size=-1>mature forest</td>       <td align=right><font size=-1>100%</td>'
para = para +'        <td><font size=-1>thin or young forest</td><td align=right><font size=-1>100%</td>'
para = para +'        <td><font size=-1>shrubs </td>             <td align=right><font size=-1>80%</td></tr>'
para = para +'    <tr><td><font size=-1>good grass </td>         <td align=right><font size=-1>60%</td>'
para = para +'        <td><font size=-1>poor grass </td>         <td align=right><font size=-1>40%</td>'
para = para +'        <td><font size=-1>low severity fire </td>  <td align=right><font size=-1>85%</td></tr>'
para = para +'    <tr><td><font size=-1>high severity fire </td> <td align=right><font size=-1>45%</td>'
para = para +'        <td><font size=-1>bare </td>               <td align=right><font size=-1>= rock%</td>'
para = para +'        <td><font size=-1>mulch only </td>         <td align=right><font size=-1>60%</td></tr>'
para = para +'    <tr><td><font size=-1>mulch and till </td>     <td align=right><font size=-1>80%</td>'
para = para +'        <td><font size=-1>low traffic road </td>   <td align=right><font size=-1>10%</td>'
para = para +'        <td><font size=-1>high traffic road </td>  <td align=right><font size=-1>10%</td></tr>'
para = para +'    <tr><td><font size=-1>burn pile </td>          <td align=right><font size=-1>20%</td>'
para = para +'        <td><font size=-1>skid trail </td>         <td align=right><font size=-1>10%</td></tr>'
para = para +'   </table><br>';
para = para +'   These categories can describe a wide range of forest and rangeland conditions. '
para = para +'   The selection of a given vegetation treatment alters these key input values for the WEPP model:'
para = para +'   <ul>'
para = para +'    <li>	Plant height, spacing, leaf area index and root depth</li>'
para = para +'    <li>	Percent of live biomass remaining after vegetation</li>'
para = para +'    <li>	Soil rill and interrill erodibility and hydraulic conductivity</li>'
para = para +'    <li>	Default radiation energy to biomass conversion ratio</li>'
para = para +'   </ul>'
para = para +'  </font>'
    }
    else if (what == 'rock') {				// ROCK
para = '  <h3>Rock</h3>'
para = para +'   Rock fragments in WEPP are considered rocks in the soil. As such, WEPP'
para = para +'   assumes that as water moves through soil, it must flow around the rocks.'
para = para +'   Therefore, WEPP reduces the hydraulic conductivity of the soil in direct'
para = para +'   proportion to the rock content (i.e. 20 percent rock will reduce the'
para = para +'   hydraulic conductivity by 20 percent).  WEPP will not accept a value for'
para = para +'   rock content higher than 50 percent, so even when the user puts 100'
para = para +'   percent rock into the rock content box, WEPP assumes that it is only 50'
para = para +'   percent.  In this context, as rock content increases up to 50 percent,'
para = para +'   runoff increases, as does rill erosion.  Above 50 percent, there is no'
para = para +'   further impact modeled from increased rock content.'
para = para +'   <br><br>'
para = para +'   Any surface rocks need to be accounted for in the surface cover.  For'
para = para +'   example, if after a fire there is 50 percent surface cover remaining from'
para = para +'   vegetation, and 20 percent of the bare soil is covered with rock, the'
para = para +'   correct surface cover including vegetation and rock is 60 percent (50'
para = para +'   percent vegetation + 20 percent rock * 50 percent bare).  In this context,'
para = para +'   as surface cover due to rock increases, the cover should be increased;'
para = para +'   both runoff and erosion will be reduced.  '
para = para +'   <br><br>'
para = para +'   Our interface currently does not automatically add rock content to surface'
para = para +'   cover, as there are cases where that may be inappropriate.'
    }
    previous_what=what
//  document.getElementById("help_text").innerHTML = '<div align=left><hr>[<a href="javascript:hide_help()">hide</a>]<br><br>' + para +'<hr></div>';
    document.getElementById("help_text").innerHTML = '<div align=left><hr>'+ para +"\n"+'<br><br>[<a href="javascript:hide_help()">close</a>]<hr></div>';
  }

    function hide_help() {
//    alert('hide_help')
      previous_what=''
      document.getElementById("help_text").innerHTML = '';
    }

  function pop_closest() {
    url = '/fswepp/rc/closest.php?units=$units';
    alert (' pop_closest');
    height=500;
    width=660;
    popupwindow = window.open(url,'popupclosest','toolbar=no,location=no,status=no,directories=no,menubar=no,scrollbars=yes,resizable=yes,width='+width+',height='+height);
  }
theEnd

print <<'theEnd';

  function checkeverything() {
//  if (checkYears(this.form.climyears)) {			//	this.form has no properties
//    RunningMsg(this.form.actionw,"Running WEPP...");	//	2004.12.20 DEH
//    this.form.achtung.value="Run WEPP"
    if (checkYears(document.forms.weppdist.climyears)) {
      RunningMsg(document.forms.weppdist.actionw,"Running WEPP...");
      document.forms.weppdist.achtung.value="Run WEPP"
    }
  }

  function submitme(which) {
    document.forms.weppdist.achtung.value=which
//    document.forms.weppdist.submit.value="Describe"
    document.forms.weppdist.submit()
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
print "function StartUp() {\n";

print <<'theEnd';
    default_pcover = new MakeArray(13);
    default_pcover[13] = 10;	// skid trail		# 2012
    default_pcover[12] = 20;	// burn pile		# 2012
    default_pcover[11] = 10;	// high traffic road
    default_pcover[10] = 10;	// low traffic road
    default_pcover[9] = 80;	// mulch and till
    default_pcover[8] = 60;	// mulch only
    default_pcover[7] = 10;	// bare
    default_pcover[6] = 45;	// high severity fire
    default_pcover[5] = 85;	// low severity fire
    default_pcover[4] = 40;	// poor grass
    default_pcover[3] = 60;	// good grass
    default_pcover[2] = 80;	// shrubs
    default_pcover[1] = 100;	// thin or young forest
    default_pcover[0] = 100;	// mature forest
    if (window.document.weppdist.Climate.selectedIndex == "") {
        window.document.weppdist.Climate.selectedIndex = 0;
    }
    climYear();
  }

  function pcover1() {        // change ofe1 pcover to default for selected
    var which = window.document.weppdist.UpSlopeType.selectedIndex;
    if (which == 0 || which == 1) {		// old forest or young forest
      if (window.document.weppdist.SoilType.selectedIndex == 3) { // rock/pavement
        window.document.weppdist.UpSlopeType.selectedIndex = 7	// bare
      }
    }
    if (which == 7) {		// bare
      window.document.weppdist.ofe1_pcover.value=window.document.weppdist.ofe1_rock.value;
      window.document.weppdist.ofe1_pcover.readonly='readonly';      // disable cover
      window.document.weppdist.ofe1_pcover.style.background='#ddd';
    }
    else {
      window.document.weppdist.ofe1_pcover.readonly='';      // enable cover
      window.document.weppdist.ofe1_pcover.style.background='#fff';
      window.document.weppdist.ofe1_pcover.value=default_pcover[which];
    }
    return false;
  }

  function pcover2() {        // change ofe2 pcover to default for selected   // 2010.05.27
    var which = window.document.weppdist.LowSlopeType.selectedIndex;
    if (which == 7) {           // bare
      window.document.weppdist.ofe2_pcover.value=window.document.weppdist.ofe2_rock.value;
      window.document.weppdist.ofe2_pcover.readonly='readonly';      // disable cover
      window.document.weppdist.ofe2_pcover.style.background='#ddd';
    }
    else {
      window.document.weppdist.ofe2_pcover.readonly='';      // enable cover
      window.document.weppdist.ofe2_pcover.style.background='#fff';
      window.document.weppdist.ofe2_pcover.value=default_pcover[which];
    }
    return false;
  }

  function climYear() {        // change climate years to max for selected
    var which = window.document.weppdist.Climate.selectedIndex;
    window.document.weppdist.climate_name.value=climate_name[which];
    // this is dumb. the select input already has this. why is it duplicating input to climate_name? why is the name of this climYear? this has nothing to do with Year! why David, why?
    window.document.weppdist.achtung.value="Calibrate vegetation";
    window.document.weppdist.achtung.value="WEPP run";
    return false;
  }
function RunningMsg (obj, text) {
       obj.value=text
}

  function checkOFE1rock(obj,min,max,def,unit,text) {
    var which = window.document.weppdist.SoilType.selectedIndex;
// alert (which)
    if (which == 3)      {		//  rock/pavement
       obj.value=50
    }
    else {  checkRange(obj,min,max,def,unit,text) }
  }

  function checkRange(obj,min,max,def,unit,thistext) {
     if (isNumber(obj.value)) {                   // obj == document.weppdist.BS
       if (obj.value < min) {                     // min == BSmin
         alert_text=thistext + " must be between " + min + " and " + max + unit
         obj.value=min
         alert(alert_text)
       }
       if (obj.value > max){
         alert_text=thistext + " must be between " + min + " and " + max + unit
         obj.value=max
         alert(alert_text)
       }
//      alert(obj.name);
//
    var which = window.document.weppdist.UpSlopeType.selectedIndex;
    if (obj.name=='ofe1_rock' && which == 7) {           // bare
      window.document.weppdist.ofe1_pcover.value=window.document.weppdist.ofe1_rock.value;
//      var which = window.document.weppdist.UpSlopeType.selectedIndex;
    }
//
     } else {
         obj.value=def
         alert("Invalid entry for " + thistext + "!")
       }
  }

function blankStatus() {
  window.status = ""
  return true                           // p. 86
}

  function checkStartYear(obj, minstartyear, maxstartyear) {
     if (isNumber(obj.value)) {
       obj.value = Math.round(obj.value)
       var alert_text = "Start year must be between " + minstartyear + " and " + maxstartyear
       if (obj.value < minstartyear){
         alert(alert_text)
         obj.value=minstartyear
         return false
       }
       if (obj.value > maxstartyear) {
         alert(alert_text)
         obj.value=maxstartyear
         return false
       }
     } else {
         alert("Invalid entry " + obj.value + " for start year! Using " + minstartyear)
         obj.value=minstartyear
         return false
       }
  }

  function checkYears(obj) {
     if (isNumber(obj.value)) {
       obj.value = Math.round(obj.value)
       var alert_text = "Number of years must be between " + minyear + " and " + maxyear 
       if (obj.value < minyear){
         alert(alert_text)
         obj.value=minyear
         return false
       }
       if (obj.value > maxyear) {
         alert(alert_text)
         obj.value=maxyear
         return false
       }
     } else {
         alert("Invalid entry " + obj.value + " for number of years! Using " + minyear)
         obj.value=minyear
         return false
       }
  }

function showRange(obj, head, min, max, unit, more) {
  range = head + min + " to " + max + unit + more
  window.status = range
  return true                           // p. 86
}

//function showHelp(obj, head, min, max, unit) {
//  var which = window.document.weppdist.SlopeType.selectedIndex;
//     if (which == 0) {vhead = "Ditch width + traveledway width: "}
//     else if (which == 1) {vhead = "Ditch width + traveledway width: "}
//     else if (which == 2) {vhead = "Traveledway width: "}
//     else {vhead = "Rut spacing + rut width: "}
//  range = vhead + min + " to " + max + unit	
//  window.status = range
//  return true                           // p. 86
//}

function showTexture() {	// 2010.05.27

   var which = window.document.weppdist.SoilType.selectedIndex;
// alert (which)
   window.document.weppdist.ofe1_rock.readonly='';	// enable rock for OFE1 (may be disabled below)
   window.document.weppdist.ofe1_rock.style.background='#fff';
   if (which == 0)           {text = "Granitic"; window.document.weppdist.ofe1_rock.value=20}
   else if (which == 1)      {text = "Volcanic"; window.document.weppdist.ofe1_rock.value=20}
   else if (which == 2)      {text = "Alluvial"; window.document.weppdist.ofe1_rock.value=20}
   else if (which == 3)      {
      text = "rock/pavement over alluvial";
      var whichUpSlopeType = window.document.weppdist.UpSlopeType.selectedIndex;
      if (whichUpSlopeType == 0 || whichUpSlopeType == 1) {
        window.document.weppdist.UpSlopeType.selectedIndex = 7	// move off forest to bare
      }
	//window.document.weppdist.UpSlopeType.remove(0);
	//window.document.weppdist.UpSlopeType.remove(0);
      window.document.weppdist.UpSlopeType[0].disabled=1;     // disable Old forest
      window.document.weppdist.UpSlopeType[1].disabled=1;     // disable Young forest
      window.document.weppdist.ofe1_rock.value=50;	      // set rock fragment to 50% for all rock/pave soils
      window.document.weppdist.ofe1_rock.readonly='readonly';		// and disable rock input
//    window.document.weppdist.ofe1_rock.style.color='green';
      window.document.weppdist.ofe1_rock.style.background='#ddd';
      if (window.document.weppdist.UpSlopeType.selectedIndex == 7) {	// bare
        window.document.weppdist.ofe1_pcover.value=50;	// set cover to 50% as well for bare soil
      }
//      alert ("rock")
   }
   else {text = 'Unknown soil texture selection'}
   window.status = text
   if (which == 0 || which == 1 || which == 2) {               // Granitic or Volcanic or ALluvial
      window.document.weppdist.UpSlopeType[0].disabled=0;      // enable Old forest
      window.document.weppdist.UpSlopeType[1].disabled=0;      // enable Young forest
   }
   return true                           // p. 86
}

  // end hide -->
  </SCRIPT>
</head>
theEnd
print '<BODY bgcolor="white"
       link="#555555" vlink="#555555" onLoad="StartUp()">
  <font face="Arial, Geneva, Helvetica">
  <table width=100% border=0>
    <tr><td> 
       <a href="/fswepp/">
       <IMG src="/fswepp/images/fsweppic2.jpg" width=75 height=75
       align="left" alt="Back to FS WEPP menu" border=0></a>
    <td align=center>
       <hr>
       <h3>Tahoe Basin Sediment Model</h3>
       <hr>
    <td>
       <A HREF="/fswepp/docs/tahoe/TahoeWorksheet.pdf" target="docs">
       <IMG src="/fswepp/images/epage.gif"
        align="right" alt="Tahoe Workshop worksheet (125 kb PDF)" border=0></a>
    </table>
  <center>
  <form name="weppdist" method="post" ACTION="/cgi-bin/fswepp/tahoe/wt.pl">
  <input type="hidden" size="1" name="units" value="', $units, '">
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
';

# print "units: $units<br>";

print qq(
 <table border=5>
  <tr valign=top>
   <td valign=top>    <!-- CLIMATE above SOIL TEXTURE above FINES -->

    <TABLE border=1>
     <tr align=top>
      <th class="thhelpoff"
          onmouseover="className='thhelpon'"
          onmouseout="className='thhelpoff'"
          onClick="JavaScript:show_help('climate')"
          title='Click the link to display select climate parameter values for the selected climate file || Climate files collected for IP: $user_ID'>
);
if ($fc) {
    print qq(
       <a href="#" onclick="
          var climateValue = document.getElementById('Climate').value;
          window.location.href = '/cgi-bin/fswepp/rc/desccli.pl?CL=' + climateValue + '&units=$units'">
          Climate</a>
);
}
else {
    print qq(
       <a href="#" onclick="
          var climateValue = document.getElementById('Climate').value;
          window.location.href = '/cgi-bin/fswepp/rc/descpar.pl?CL=' + climateValue + '&units=$units'">
          Climate</a>
);
}
print '</b>
      </td>
     <tr align=top>
      <td align="center" bgcolor="#FAF8CC">
       <SELECT NAME="Climate" SIZE="', $num_cli + 1, '">
';

foreach my $ii ( 0 .. $#climates ) {
    print '<OPTION VALUE="', $climates[$ii]->{'clim_file'}, '"';
    print ' selected' if $ii == 0;
    print '> ', $climates[$ii]->{'clim_name'}, "\n";
}

print "       </SELECT>
      <tr>
       <td align=center class=\"tdhelpoff\" onmouseover=\"className='tdhelpon'\" onmouseout=\"className='tdhelpoff'\" onClick=\"JavaScript:show_help('climate_buttons')\">
      <input type=\"hidden\" name=\"achtung\" value=\"Run WEPP\">
";
if ( !$fc ) {
    print qq (
      <button type="button" onclick="window.location.href='/cgi-bin/fswepp/rc/rockclim.pl?comefrom=tahoe&units=$units'">Custom Climate</button>
      <input type=button value=Future onclick="javascript:click_future()">
      <input type="button" value="Closest" onclick="javascript:popupclosest()">
      <input type="hidden" name="fc" value="">\n
    );
}
else {
    print "      <input type=\"hidden\" name=\"fc\" value=\"*\">
      <input type=button value='Current climates' onclick=\"javascript:click_present()\">\n";
}
#################
#
#      SOIL TEXTURES SELECTION
#
print <<'theEnd';
     <tr>
      <td height=5 bgcolor="red"></td>
     <tr>
     <tr>
      <th class="thhelpoff"
          onmouseover="className='thhelpon'"
          onmouseout="className='thhelpoff'"
          onClick="JavaScript:show_help('soil_texture')"
          title="Click the link to display soil texture property values for the selected soil texture">
       <b><a href="JavaScript:submitme('Describe Soil')">
             Soil Texture</a></b>
      </th>
     </tr>
theEnd
print "
     <tr>
      <td align=\"center\" bgcolor=\"#FAF8CC\">
       <font size=-1>
        <SELECT NAME=\"SoilType\" SIZE=4
         onChange=\"showTexture()\"
         onBlur=\"blankStatus()\">
         <OPTION VALUE=\"granitic\" selected>granitic
         <OPTION VALUE=\"volcanic\">volcanic
         <OPTION VALUE=\"alluvial\">alluvial
         <OPTION VALUE=\"rockpave\">rock/pavement -&gt; alluvial
        </SELECT>
       </font>
      </td>
     </tr>
     <tr>
      <td align=\"center\" bgcolor=\"#FAF8CC\"
          class=\"tdhelpoff\"
          onmouseover=\"className='tdhelpon'\"
          onmouseout=\"className='tdhelpoff'\"
          title=\"4 to 62.5 microns\"
          onClick=\"JavaScript:show_help('fines')\">
       <font size=-1>
        Fines less than
         <input name=fines_upper type=text size=3 value=10
                onChange=\"checkRange(fines_upper,4,62.5,10,' microns','Fines')\"> microns
       </font>
      </td>
     </tr>
    </table>

  </td>
  <td>
";
print <<'theEnd';
  <table border=2 cellpadding=6>
   <tr>
    <th bgcolor=85d2d2>
     <font face="Arial, Geneva, Helvetica">&nbsp;</font>
    </th>
    <th colspan=2 class="thhelpoff" onmouseover="className='thhelpon'" onmouseout="className='thhelpoff'" onClick="JavaScript:show_help('vegetation_treatment')">
     <font face="Arial, Geneva, Helvetica">Treatment /<br>Vegetation</font>
    </th>
    <th class="thhelpoff" onmouseover="className='thhelpon'" onmouseout="className='thhelpoff'" onClick="JavaScript:show_help('geometry')">
     <font face="Arial, Geneva, Helvetica">Gradient<br>(%)<br></font>
    </th>
theEnd
print "
    <th class=\"thhelpoff\" onmouseover=\"className='thhelpon'\" onmouseout=\"className='thhelpoff'\" onClick=\"JavaScript:show_help('geometry')\">
      <font face=\"Arial, Geneva, Helvetica\">Horizontal<br>Length ($units)</font>
    </th>
";
print <<'theEnd';
    <th class="thhelpoff" onmouseover="className='thhelpon'" onmouseout="className='thhelpoff'" onClick="JavaScript:show_help('cover')">
     <font face="Arial, Geneva, Helvetica">Cover<br>(%)<br></font>
    </th>
    <th class="thhelpoff" onmouseover="className='thhelpon'" onmouseout="className='thhelpoff'" onClick="JavaScript:show_help('rock')">
     <font face="Arial, Geneva, Helvetica">Rock in soil<br>(%)<br></font>
    </th>
   </tr>
   <tr>
    <th rowspan=2 bgcolor="#85d2d2"><font face="Arial, Geneva, Helvetica">Upper<br>Element</th>
    <td rowspan=2 bgcolor="#FAF8CC" colspan=2>
     <SELECT NAME="UpSlopeType" SIZE="8" ALIGN="top" onChange="pcover1()";>
      <OPTION VALUE="OldForest" selected> Mature forest
      <OPTION VALUE="YoungForest"> Thin or young forest
      <OPTION VALUE="Shrub"> Shrubs
      <OPTION VALUE="Bunchgrass"> Good grass
      <OPTION VALUE="Sod"> Poor grass <!-- 2011.02.14 -->
      <OPTION VALUE="LowFire"> Low severity fire
      <OPTION VALUE="HighFire"> High severity fire
      <OPTION VALUE="Bare"> Bare
      <OPTION VALUE="Mulch"> Mulch only
      <OPTION VALUE="Till"> Mulch and till
      <OPTION VALUE="LowRoad"> Low traffic road
      <OPTION VALUE="HighRoad"> High traffic road
      <OPTION VALUE="BurnP">Burn pile
      <OPTION VALUE="Skid"> Skid trail
     </SELECT>
    </td>
    <td bgcolor="#FAF8CC" title="0 to 100%">
      <input type="text" size=5 name="ofe1_top_slope" value="0"
       onChange="checkRange(ofe1_top_slope,smin,smax,ofe1tsdef,sunit,'Slope')"
       onFocus="showRange(this.form,'Slope: ',smin,smax,sunit,'')"
       onBlur="blankStatus()">
    </td>
    <td rowspan=2 bgcolor="#FAF8CC" title="0.5 to 400 m; 1.5 to 1200 ft">
      <input type="text" size=5 name="ofe1_length" value="50"
       onChange="checkRange(ofe1_length,lmin,lmax,ldef,lunit,'Upper element length')"
       onFocus="showRange(this.form,'Upper element length: ',lmin,lmax,lunit,'')"
       onBlur="blankStatus()">
    </td>
    <td rowspan=2 bgcolor="#FAF8CC" title="0 to 150%">
      <input type="text" size=5 name="ofe1_pcover" value="100"
       onChange="checkRange(ofe1_pcover,pcmin,pcmax,pcdef,pcunit,'Percent cover')"
       onFocus="showRange(this.form,'Percent cover: ',pcmin,pcmax,pcunit,'')"
       onBlur="blankStatus()">
    </td>
    <td rowspan=2 bgcolor="#FAF8CC" title="0 to 50%">
      <input type="text" size=5 name="ofe1_rock" value="20"
       onChange="checkOFE1rock(ofe1_rock,rmin,rmax,rdef,runit,'Percent rock in soil')"
       onFocus="showRange(this.form,'Percent rock: ',rmin,rmax,runit,' (50% for rock/pavement)')"
       onBlur="blankStatus()">
    </td>
   </tr>
   <tr>
    <td bgcolor="#FAF8CC" title="0 to 100%">
      <input type="text" size=5 name="ofe1_mid_slope" value="30"
        onChange="checkRange(ofe1_mid_slope,smin,smax,ofe1msdef,sunit,'Slope')"
        onFocus="showRange(this.form,'Slope: ',smin,smax,sunit,'')"
        onBlur="blankStatus()">
    </td>
   </tr>
   <tr>
    <th rowspan=2 bgcolor="#85d2d2"><font face="Arial, Geneva, Helvetica">Lower<br>Element</th>
    <td rowspan=2 bgcolor="#FAF8CC" colspan=2>
     <SELECT NAME="LowSlopeType" SIZE="8" ALIGN="top" onChange="pcover2()";>
      <OPTION VALUE="OldForest"> Mature forest
      <OPTION VALUE="YoungForest" selected> Thin or young forest
      <OPTION VALUE="Shrub"> Shrubs
      <OPTION VALUE="Bunchgrass"> Good grass
      <OPTION VALUE="Sod"> Poor grass	<!-- 2011.02.14 -->
      <OPTION VALUE="LowFire"> Low severity fire
      <OPTION VALUE="HighFire"> High severity fire
      <OPTION VALUE="Bare"> Bare
      <OPTION VALUE="Mulch"> Mulch only
      <OPTION VALUE="Till"> Mulch and till
      <OPTION VALUE="LowRoad"> Low traffic road
      <OPTION VALUE="HighRoad"> High traffic road
      <OPTION VALUE="BurnP"> Burn pile
      <OPTION VALUE="Skid"> Skid trail
     </SELECT>
    </td>
    <td bgcolor="#FAF8CC" title="0 to 100%">
       <input type="text" size=5 name="ofe2_top_slope" value="30"
        onChange="checkRange(ofe2_top_slope,smin,smax,ofe2tsdef,sunit,'Slope')"
        onFocus="showRange(this.form,'Slope range: ',smin,smax,sunit,'')"
        onBlur="blankStatus()">
    </td>
    <td rowspan=2 bgcolor="#FAF8CC" title="0.5 to 400 m; 1.5 to 1200 ft">
      <input type="text" size=5 name="ofe2_length" value="50"
        onChange="checkRange(ofe2_length,lmin,lmax,ldef,lunit,'Lower element length')"
        onFocus="showRange(this.form,'Lower element length: ',lmin,lmax,lunit,'')"
        onBlur="blankStatus()">
    </td>
    <td rowspan=2 bgcolor="#FAF8CC" title="0 to 150%">
      <input type="text" size=5 name="ofe2_pcover" value="100"
        onChange="checkRange(ofe2_pcover,pcmin,pcmax,pcdef,pcunit,'Percent cover')"
        onFocus="showRange(this.form,'Percent cover: ',pcmin,pcmax,pcunit,'')"
        onBlur="blankStatus()">
    </td>
    <td rowspan=2 bgcolor="#FAF8CC" title="0 to 50%">
       <input type="text" size=5 name="ofe2_rock" value="20"
        onChange="checkRange(ofe2_rock,rmin,rmax,rdef,runit,'Percent rock in soil')"
        onFocus="showRange(this.form,'Percent rock: ',rmin,rmax,runit,'')"
        onBlur="blankStatus()">
    </td>
   </tr>
   <tr>
    <td bgcolor="#FAF8CC" title="0 to 100%">
       <input type="text" size=5 name="ofe2_bot_slope" value="5"
        onChange="checkRange(ofe2_bot_slope,smin,smax,ofe2bsdef,sunit,'Slope')"
        onFocus="showRange(this.form,'Slope range: ',smin,smax,sunit,'')"
        onBlur="blankStatus()">
    </td>
   </tr>
   <tr>
    <th class="thhelpoff"
        onmouseover="className='thhelpon'"
        onmouseout="className='thhelpoff'"
        onClick="JavaScript:show_help('phosphorus')"
        style='border-top:solid 3px purple;
               border-left:solid 3px purple;
               border-bottom:solid 3px purple'>
     <font size=-1>      Phosphorus<br>Concentration     </font>
    </th>
    <th bgcolor="#85d2d2"
        style='border-top:solid 3px purple;
               border-bottom:solid 3px purple'>
     <font size=-1>      Surface<br>Runoff<br>Concentration     </font>
    </th>
    <td bgcolor="#FAF8CC" title="0 to 4 mg/l"
        style='border-top:solid 3px purple;
               border-bottom:solid 3px purple'>
     <font size=-1>
      <input name='sr_conc' type=text value='1.0' size=3
             onChange="checkRange(sr_conc,0,4,'1.0',' mg/l','Phosphate concentration in Surface runoff')">&nbsp;mg/l
     </font>
    </td>
    <th bgcolor="#85d2d2"
        style='border-top:solid 3px purple;
               border-bottom:solid 3px purple'>
     <font size=-1>      Subsurface<br>Lateral Flow<br> Concentration     </font>
    </th>
    <td bgcolor="#FAF8CC" title="0 to 4 mg/l"
        style='border-top:solid 3px purple;
               border-bottom:solid 3px purple'>
     <font size=-1>
      <input name='lf_conc' type=text value='1.5' size=3
             onChange="checkRange(lf_conc,0,4,'1.5',' mg/l','Phosphate concentration in Lateral flow')">&nbsp;mg/l
     </font>
    </td>
    <th bgcolor="#85d2d2"
        style='border-top:solid 3px purple;
               border-bottom:solid 3px purple'>
     <font size=-1>      Sediment Concentration    </font>
    </th>
    <td bgcolor="#FAF8CC" title="0 to 2000 mg/kg"
        style='border-top:solid 3px purple;
               border-right:solid 3px purple;
               border-bottom:solid 3px purple'>
     <font size=-1>								<!-- 2014.04.18 DEH -->
      <input name='sed_conc' type=text value='1000' size=3
             onChange="checkRange(sed_conc,0,2000,1000,' mg/kg','Phosphate concentration in Sediment')">&nbsp;mg/kg
     </font>
    </td>
   </tr>
   <tr>
    <th bgcolor="#85d2d2">
     <font size=-1>
      <b>Run<br>Description</b>
     </font>
    </th>
    <td bgcolor="#FAF8CC" colspan=4>
     <font size=-1>
      <input type = "text" name="description" value="" size=50>
     </font>
    </th>
theEnd
#####################################
if ($fc) {
    print <<'theEnd';
    <th bgcolor="#85d2d2" title="20-year simulation starting 2001 to 2080">
     <font size=-1>
      <b>Starting year</b>
     </font>
    </th>
    <td bgcolor="#FAF8CC" title="2001 to 2080">
     <font size=-1>
      <input type="text" size="4" name="startyear" value="2013"
        onChange="checkStartYear(this.form.startyear,2001,2080)"
        onFocus="showRange(this.form,'Start year: ',2001, 2080, '','')"
        onBlur="blankStatus()">
      <input type="hidden" name="climyears" value="20">
     </font>
    </td>
theEnd
}
else {
    print <<'theEnd';
    <th bgcolor="#85d2d2">
     <font size=-1>
      <b>Simulation Length</b>
     </font>
    </th>
    <td bgcolor="#FAF8CC" title="1 to 200 years">
     <font size=-1>
      <input type="text" size="3" name="climyears" value="10"
         onChange="checkYears(this.form.climyears)"
         onFocus="showRange(this.form,'Years to Simulate: ',minyear, maxyear, '','')"
         onBlur="blankStatus()"> years
     </font>
    </td>
theEnd
}
print <<'theEnd';
   </tr>
  </table>
   </td>
  </tr>
</table>

   <input type=hidden name="climate_name">
<!-- .... Summary output...
<INPUT TYPE="CHECKBOX" NAME="Full" VALUE="1">Full output
<INPUT TYPE="CHECKBOX" NAME="Slope" VALUE="1">Slope file input -->
<!--<INPUT TYPE="SUBMIT" name="actionw" VALUE="Run WEPP"
    onClick='RunningMsg(this.form.actionw,"Running..."); this.form.achtung.value="Run WEPP"'>
-->
<br>
<INPUT TYPE="HIDDEN" NAME="Units" VALUE="m">
<INPUT TYPE="SUBMIT" name="actionw" VALUE="Run WEPP"
       onClick='checkeverything()'>
<!--       onClick='RunningMsg(this.form.actionw,"Running WEPP..."); this.form.achtung.value="Run WEPP"'>
  <input type="button" value="Exit" onClick="window.close(self)">-->
<BR>
</center>
</FORM>
<P>
<HR>
theEnd
print '
 <font size=-1>
  <a href="/fswepp/comments.html" >                                                              
  <img src="/fswepp/images/epaemail.gif" align="right" border=0></a>
  <a href="https://www.blm.gov/programs/lands-and-realty/regional-information/nevada/snplma" 
     target="snplma"><img src="/fswepp/images/SNPLMAlogo.png" width=100 align="right" border=o></a>
  <font size=-2>
   The Tahoe Basin Sediment Model is a version of Disturbed WEPP customized for the Lake Tahoe Basin.
   <br><br>
   <b>Citation:</b><br>
   Elliot, William J.; Hall, David E. 2010. Tahoe Basin Sediment Model. Ver. ',
  $version, '.
   Moscow, ID: U.S. Department of Agriculture, Forest Service, Rocky Mountain Research Station. 
   Online at &lt;https://forest.moscowfsl.wsu.edu/fswepp&gt;.
   <br><br>
   With support from the U.S. Department of the Interior Bureau of Land Management
   <a href="https://www.blm.gov/programs/lands-and-realty/regional-information/nevada/snplma">
     Southern Nevada Public Land Management Act</a>
   <br><br>
   Tahoe Basin Sediment Model Interface v.
   <a href="https://github.com/wepp-in-the-woods/fswepp-docker/commits/main/var/www/cgi-bin/fswepp/tahoe/tahoe.pl">',
  $version, '</a><br>
';
$remote_host    = $ENV{'REMOTE_HOST'};
$remote_address = $ENV{'REMOTE_ADDR'};

$wc    = `wc ../working/' . currentLogDir() . '/wt.log`;
@words = split " ", $wc;
$runs  = @words[0];

print
"$user_ID<br>
  Log of FS WEPP runs for IP and personality <a href=\"/cgi-bin/fswepp/runlogger.pl\" target=\"_rl\">$user_ID</a><br>
  <b>$runs</b> Tahoe Basin Sediment Model runs YTD
 </body>
</html>
";

