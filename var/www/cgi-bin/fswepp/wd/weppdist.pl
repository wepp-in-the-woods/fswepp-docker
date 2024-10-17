#!/usr/bin/perl

use CGI;
use CGI qw(escapeHTML);

use warnings;

use MoscowFSL::FSWEPP::FsWeppUtils qw(get_version get_user_id get_units);
use MoscowFSL::FSWEPP::CligenUtils qw(GetClimates);

#
#  Disturbed WEPP input screen -- new format, no veg calibration needed
#

my $version = get_version(__FILE__);
my ($units, $areaunits) = get_units();
my $user_ID = get_user_id();
my @climates = GetClimates($user_ID);

###################################################

print "Content-type: text/html\n\n";
print <<'theEnd2';
<html>
<head>
<title>Disturbed WEPP Model 2.0</title>
  <META http-equiv="Content-Type" content="text/html; charset=utf-8">
  <META NAME="Name" CONTENT="Disturbed WEPP Model 2.0">
  <META NAME="Brief Description" CONTENT="Disturbed WEPP Model 2.0, a component of FS WEPP, predicts sedimentation and erosion from rangeland, forestland, and forest skid trails.
   The interface presents the probability of a given level of sedimentation and erosion occurring the year following a disturbance.">
  <META NAME="Status" CONTENT="Released 2011">
  <META NAME="Updates" CONTENT="Ongoing, online">
  <META NAME="Inputs" CONTENT="Climate station; soil texture; upper and lower element treatment, gradient, horizontal length, cover, and rock content">
  <META NAME="Outputs" CONTENT="Annual average precipitation; runoff from rainfall; runoff from snowmelt or winter rainstorm; upland erosion rate; sediment leaving profile; return period analysis of precipitation, runoff, erosion, and sediment; probabilities of occurrence first year following disturbance of runoff, erosion, and sediment delivery">
  <META NAME="Suggested user" CONTENT="">
  <META NAME="Suggested use" CONTENT="">
  <META NAME="Keywords" CONTENT="">
  <META NAME="Contributors" CONTENT="USDA Forest Service, Rocky Mountain Research Station, Moscow, ID: Bill Elliot and David Hall">
  <META NAME="Source" content="Run online at https://forest.moscowfsl.wsu.edu/fswepp/">

  <SCRIPT LANGUAGE = "JavaScript" type="TEXT/JAVASCRIPT">

  // these need to be global because this code is garbage
  var para;
  var default_pcover;
  var text;

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
  var rmin = 0		//dehdehdeh2004//
  var rmax = 75
  var rdef = 20

  var previous_what=''  // for show_help

function popupclosest() {
url = 'https://forest.moscowfsl.wsu.edu/fswepp/rc/closest.php?units=ft';
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
//      alert('show_help')
      if (what == previous_what) {hide_help(); return}
      if (what == 'climate') {				// CLIMATE
para='<h3>Climate file</h3>'
para = para +'  <b>[Ownership] Station name [Status]</b>'
para = para +'  <p>'
para = para +'  <table align=center border=1>'
para = para +'  <tr><th colspan=2 bgcolor=gold>Ownership</th></tr>'
para = para +'  <tr><th> -    <td>Public (any computer could create)</th></tr>'
para = para +'  <tr><th> *    <td>Personal climate (your computer created)</th></tr>'
para = para +'  <tr><th>&nbsp;<td>Standard-issue climate</th></tr>'
para = para +'  </table>'
para = para +'<p>'
para = para +'  <table align=center border=1>'
para = para +'  <tr><th colspan=2 bgcolor=gold>Status</th></tr>'
para = para +'  <tr><th> +    <td>Parameters have been changed from standard-issue</th></tr>'
para = para +'  <tr><th>&nbsp;<td>Unchanged from distribution</th></tr> '
para = para +'  </table>'
para = para + '<br>'
para = para +'Several climates (Birmingham, AL; Flagstaff, AZ; Mount Shasta, CA; '
para = para +'Denver, CO; Moscow, ID; and Charleston, WV) are listed in the climate list as stock '
para = para +'climates. '
para = para +'These climates are provided to allow the user to quickly select a regional climate for an '
para = para +'initial run.  '
para = para +'<p>'
para = para +'Most users will prefer to click the '
para = para +' <input type="submit" value="Custom Climate" disabled> '
para = para +'button and use the Rock:Clime weather generator to select desired climates from the '
para = para +'2,600 sets of climate statistics in the database.  '
para = para +'<p>'
para = para +'Users may select several nearby climates to determine the sensitivity of '
para = para +'their site to climate effects.  '
      }
      if (what == 'gradient') {					// GRADIENT
para='<h3>Gradient</h3>'
para = para +' The Disturbed WEPP Model uses two "overland flow elements" &ndash; an upper and a lower.'
para = para +' The user specifies the surface slope by entering the horizontal length of each element,'
para = para +' and the gradient at the top and midway down the upper element,'
para = para +' and midway and at the toe of the lower element.'
      }
      else if (what == 'soil_texture') {			// SOIL TEXTURE
para ='   <h3>Soil Texture</h3>'
para = para +' The user may specify a soil texture for the two elements.'
para = para +' Choices are clay loam, silt loam, sandy loam, and loam.'
para = para +'<br><br>'
para = para +' The soil database has been adjusted (April 2014) to better compliment the current versions of WEPP.'
para = para +' In recent years, lateral flow has been incorporated into the WEPP model, better modeling hydrologic processes on steep forested hillslopes.'
para = para +' With the addition of lateral flow, recent watershed validation studies have all shown that hydraulic conductivity needed to be increased, so this has been done for most of the soils.  '
para = para +'<br><br>'
para = para +' In field studies measuring rill erodibility that have been recently completed and published, it was found that rill erodibility in forests is much lower than was assumed when this database was originally developed, so rill erodibility has been decreased in most cases by 80 percent.'
para = para +'<br>'
para = para +' To better reflect deeper rooting depths, and increased amounts of water stored in shrubs and trees, soil depths have been increased for those vegetation conditions.'
para = para +'<br><br>'
para = para +'References<br><br>'
para = para +'Conroy, W. J., R. H. Hotchkiss and W. J. Elliot.  2006.  A coupled upland-erosion and instream hydrodynamic-sediment transport model for evaluating sediment transport in forested watersheds.  Transactions of the American Society of Agriculture and Biological Engineers 49(6):1-10.<br>'
para = para +'Covert, S. A., P. R. Robichaud, W. J. Elliot and T. E. Link.  2005.  Evaluation of runoff prediction from WEPP-Based erosion models for harvested and burned forest watersheds.  Trans ASAE 43(3):1091-1100.<br>'
para = para +'Dun, S., J.Q. Wu, W.J. Elliot, P.R. Robichaud, D.C. Flanagan, J.R. Frankenberger, R.E. Brown and A.D. Xu.  2009.  Adapting the Water Erosion Prediction Project (WEPP) Model for forest applications.  Journal of Hydrology, 336(1-4):45-54.<br>'
para = para +'Srivastava, A. 2013. Modeling of hydrological processes in three mountainous watersheds in the U.S. Pacific Northwest. PhD Dissertation. Pullman, WA: Washington State University. 170 p<br>'
para = para +'Wagenbrenner, J. W., P. R. Robichaud, and W. J. Elliot (2010), Rill erosion in natural and disturbed forests: 2.Modeling Approaches, Water Resour. Res., 46, W10507, doi:10.1029/2009WR008315.<br>'
para = para +'Zhang, X.J. 2005. Effects of DEM resolution on the WEPP runoff and erosion predictions: A case study of forest areas in Northern Idaho. PhD Dissertation. Moscow, ID: University of Idaho. 115&nbsp;p.<br>'

// para = para +' Choices are Granitic, Volcanic, Alluvial, and Rock/Pavement.'
// para = para +' If the user selects Rock/Pavement, parameter values appropriate for a rock/pavement texture are used for the'
// para = para +' upper element, and values appropriate for alluvial soil are used for the lower element.'
// para = para +' <br><br>'
// para = para +'\'Mature forest\' and \'Young or thin forest\' are not valid for the upper element vegetation for Rock/Pavement soil texture.'
      }
      else if (what == 'cover') {				// COVER
para='<h3>Modeling Cover in Disturbed WEPP, Version 2</h3>';

para = para +'The ground cover is the single most important vegetation input into the WEPP model,'
para = para +' and affects infiltration, runoff, interrill erosion and rill erosion rates, so it is critical to ensure that'
para = para +' a defensible value is used.'
para = para +' The WEPP Model considers three categories of cover: canopy, rill and interrill (Flanagan and Nearing, 1995).'
para = para +' These conditions can be described in great detail if necessary using the WEPP Windows interface.'
para = para +' In this interface, we have simplified the modeling of cover for the users as we found that this was the'
para = para +' most awkward step in modeling erosion.<br><br>'
 
para = para +' The <b>Cover</b> input is for ground cover.'
para = para +' It can include duff, leaves, needles, branches, logs, animal waste, mulch and rocks.'
para = para +' Sometimes it is determined by estimating the fraction of bare soil, and subtracting that from 1'
para = para +' (&lt;Ground cover&gt; = 1.0 - &lt;Fraction bare soil&gt;).'
para = para +' Cover is generally measured with several line transects'
para = para +' (cover at each meter along a 20 m tape; Wollenhaupt and Pingry, 1991), or several grid observations'
para = para +' (1.2-sq m grid with intersecting grid of strings every 0.1 m; Dobre, 2010).'
para = para +' The most simple transect is to take 20 paces, and at the end of each pace, to observe the cover under your toe'
para = para +' (Canfield, 1941).'
para = para +' Within this interface, we have fixed both rill and interrill cover as the input value for the entire run.'
para = para +' We also set the canopy cover to be equal to the ground cover.'
para = para +' It may be beneficial to do several runs for a given site with different cover amounts based on field observations,'
para = para +' and report a range of erosion estimates.'
para = para +' If users want to study the effects of a variable canopy or ground cover within a year, or have cover gradually'
para = para +' increase as a site recovers from a fire, then it is necessary to use the WEPP Windows interface'
para = para +' where there are many more options for describing the factors that cause variable cover including plant growth rate,'
para = para +' fraction and time of senescence, residue decomposition, and relationship between biomass and canopy'
para = para +' (Flanagan and Nearing, 1995).<br><br>'

para = para +'References:<br><br>'
para = para +'Canfield, R.H., 1941, <i>Application of the line interception method in sampling range vegetation,</i>'
para = para +'  <b>Journal of Forestry,</b> Vol. 39, No. 4, pp. 388&ndash;394.<br>'
para = para +'Dobre, M. 2010. <b>Assessing spatial distribution of fire effects in forests using GIS.</b>'
para = para +'  Proceedings of the 2nd Joint Federal Interagency Conference, Las Vegas, NV. 27 June &ndash; 1 July, 2010.'
para = para +'  Online at &lt;https://acwi.gov/sos/pubs/2ndJFIC/Contents/SP06_Dobre_03_29_10_paper.pdf&gt;. Accessed Nov., 2011.<br>'
para = para +'Flanagan, D.C., and M.A. Nearing (eds.).  1995.'
para = para +'  <b>USDA-Water Erosion Prediction Project (WEPP) Hillslope Profile and Watershed Model Documentation.</b>'
para = para +'  NSERL Report No. 10, National Soil Erosion Research Laboratory, USDA-Agricultural Research Service, West Lafayette, Indiana.<br>'
para = para +'Wollenhaupt, N.C., and J. Pingry. 1991.'
para = para +'  <b>Estimating residue using the line transect method.</b> UWEX Bull. G3533.'
para = para +'  Online at &lt;https://learningstore.uwex.edu/assets/pdfs/A3533.pdf&gt; Accessed Nov. 2011.'
para = para +'  Madison: Univ. of Wisconsin. 2&nbsp;p.<br><br>'


// para = para +' One\'s selection of the treatment will set a suggested value for cover, with the exception of treatment "Bare."'
para = para +' One\'s selection of the treatment will set a suggested value for cover'
// para = para +'  The "Bare" treatment uses for cover the current value for percent rock.'
para = para +' <br><br>'
para = para +' The suggested cover value for each treatment is:'
para = para +'   <table>'
para = para +'    <tr><td><font size=-1>mature forest</font></td>       <td><font size=-1>100% cover</font></td></tr>'
para = para +'    <tr><td><font size=-1>thin or young forest</font></td><td><font size=-1>100% cover</font></td></tr>'
para = para +'    <tr><td><font size=-1>shrubs</font></td>              <td><font size=-1> 80% cover</font></td></tr>'
para = para +'    <tr><td><font size=-1>good grass</font></td>          <td><font size=-1> 60% cover</font></td></tr>'
para = para +'    <tr><td><font size=-1>poor grass</font></td>          <td><font size=-1> 40% cover</font></td></tr>'
para = para +'    <tr><td><font size=-1>low severity fire</font></td>   <td><font size=-1> 85% cover</font></td></tr>'
para = para +'    <tr><td><font size=-1>high severity fire</font></td>  <td><font size=-1> 45% cover</font></td></tr>'
// para = para +'    <tr><td><font size=-1>bare</font></td>                <td><font size=-1>same as percent rock</td></tr>'
// para = para +'    <tr><td><font size=-1>mulch only</font></td>          <td><font size=-1> 60% cover</font></td></tr>'
// para = para +'    <tr><td><font size=-1>mulch and till</font></td>      <td><font size=-1> 80% cover</font></td></tr>'
// para = para +'    <tr><td><font size=-1>low traffic road</font></td>    <td><font size=-1> 10% cover</font></td></tr>'
// para = para +'    <tr><td><font size=-1>high traffic road</font></td>   <td><font size=-1> 10% cover</font></td></tr>'
para = para +'    <tr><td><font size=-1>skid trail</font></td>          <td><font size=-1> 10% cover</font></td></tr>'
para = para +'   </table>'
      }
      else if (what == 'restrictive_layer') {			// RESTRICTIVE LAYER
para = '<h3>Restrictive layer</h3>'
para = para +'    Click the checkbox next to "Restrictive layer" to specify the name of the bedrock that forms'
para = para +'    the soil\'s restrictive layer.'
para = para +'    Suggested values for that rock type will be displayed for saturated hydraulic conductivity.'
para = para +'    <br><br>'
para = para +'    If the Restriction checkbox is unchecked, then a restrictive layer is not present and the old'
para = para +'    (standard) soil input is used.';
      }
      else if (what == 'vegetation_treatment') {		// TREATMENT
para = '  <h3>Vegetation/Treatment</h3>';
para = para +'   The Disturbed WEPP Model provides thirteen categories of vegetation or treatment.';
para = para +'   A default cover is associated with each vegetation treatment, but users are encouraged to alter this value to suit site conditions.  The vegetation treatments are:';
para = para +'   <ul>';
para = para +'    <li>  mature forest &ndash;   100% cover</li>';
para = para +'    <li>	thin or young forest &ndash;    100% cover</li>';
para = para +'    <li>	shrubs &ndash;    80% cover</li>';
para = para +'    <li>	good grass &ndash;    60% cover</li>';
para = para +'    <li>	poor grass &ndash;    40% cover</li>';
para = para +'    <li>	low severity fire &ndash;    85% cover</li>';
para = para +'    <li>	high severity fire &ndash;    45% cover</li>';
// para = para +'    <li>	bare &ndash;    same as percent rock</li>';
// para = para +'    <li>	mulch only &ndash;    60% cover</li>';
// para = para +'    <li>	mulch and till &ndash;    80% cover</li>';
// para = para +'    <li>	low traffic road &ndash;    10% cover</li>';
// para = para +'    <li>	high traffic road &ndash;    10% cover</li>';
para = para +'    <li>	skid trail &ndash;    10% cover</li>';
para = para +'   </ul>';
para = para +'   These categories can describe a wide range of forest and rangeland conditions. '
para = para +'   The selection of a given vegetation treatment alters these key input values for the WEPP model:'
para = para +'   <ul>'
para = para +'    <li>	Plant height, spacing, leaf area index and root depth</li>'
para = para +'    <li>	Percent of live biomass remaining after vegetation</li>'
para = para +'    <li>	Soil rill and interrill erodibility and hydraulic conductivity</li>'
para = para +'    <li>	Default radiation energy to biomass conversion ratio</li>'
para = para +'   </ul>'
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
      document.getElementById("help_text").innerHTML = '<div align=left><hr>[<a href="javascript:hide_help()">hide</a>]<br><br>' + para +'<hr></div>';
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
//    if (checkYears(this.form.climyears)) {			//	this.form has no properties
//      RunningMsg(this.form.actionw,"Running WEPP...");	//	2004.12.20 DEH
//      this.form.achtung.value="Run WEPP"
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

    default_pcover = new MakeArray(12);
    default_pcover[12] = 10;	// skid trail
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
    window.document.weppdist.ofe1_pcover.value=default_pcover[which];
    return false;
  }

  function pcover2() {        // change ofe2 pcover to default for selected   // 2010.05.27
    var which = window.document.weppdist.LowSlopeType.selectedIndex;
    window.document.weppdist.ofe2_pcover.value=default_pcover[which];
    return false;
  }

  function climYear() {        // change climate years to max for selected
    var which = window.document.weppdist.Climate.selectedIndex;
    window.document.weppdist.climate_name.value=climate_name[which];
    window.document.weppdist.achtung.value="Calibrate vegetation";
    window.document.weppdist.achtung.value="WEPP run";
    return false;
  }
function RunningMsg (obj, text) {
       obj.value=text
}

  function checkOFE1rock(obj,min,max,def,unit,text) {
    var which = window.document.weppdist.SoilType.selectedIndex;
    checkRange(obj,min,max,def,unit,text)
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
    var which = window.document.weppdist.UpSlopeType.selectedIndex;
    if (obj.name=='ofe1_rock' && which == 7) {           // bare
      window.document.weppdist.ofe1_pcover.value=window.document.weppdist.ofe1_rock.value;
    }
     } else {
         obj.value=def
         alert("Invalid entry for " + thistext + "!")
       }
  }

function blankStatus() {
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

function showTexture() {	// 2010.05.27    2011.07.08
   var which = window.document.weppdist.SoilType.selectedIndex;
   if (which == 0)           {text = "clay loam"}
   else if (which == 1)      {text = "silt loam"}
   else if (which == 2)      {text = "sandy loam"}
   else if (which == 3)      {text = "loam"}
   else {text = 'Unknown soil texture selection'}
   window.status = text
   return true                           // p. 86
}

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
       <h3>Disturbed WEPP Model 2.0<br>
       </h3>
       <hr>
    <td>
       <a HREF="/fswepp/docs/distweppdoc.html">
        <img src="/fswepp/images/epage.gif" align="right" alt="" border=0 />
       </a>
    </td>
   </table>
  <center>
  
  <FORM name="weppdist" method="post" ACTION="wd.pl">
  <input type="hidden" size="1" name="me" value="',    $me,    '">
  <input type="hidden" size="1" name="units" value="', $units, '">
<br>
 <table width=90% border=0 bgcolor="#FAF8CC">
  <tr>
   <td>
    <font size=-1 id="help_text"> 
    </font>
   </td>
  </tr>
 </table>
<br>
';

# print "units: $units<br>";

print qq(
 <table border = 7>
  <tr>
   <td bgcolor="85d2d2" colspan=2>
    <b>Run description:</b> <input type = "text" name="description" value="" size="50" tabindex="1">
    &nbsp;&nbsp;
    <b>Years to simulate:</b> <input type="text" size="3" name="climyears" value="10" tabindex="2"
        onChange="checkYears(this.form.climyears)"
        onFocus="showRange(this.form,'Years to simulate: ',minyear, maxyear, '','')"
        onBlur="blankStatus()">
   </td>
  </tr>
  <tr valign=top>
   <td valign=top> 

    <TABLE border="1">
     <tr align="top">
      <td align="center" bgcolor="#85d2d2">
      <a href="#" onclick="
          var climateValue = document.getElementById('Climate').value;
          window.location.href = '/cgi-bin/fswepp/rc/descpar.pl?CL=' + climateValue + '&units=$units'">
          Climate</a></b>
          <a href="JavaScript:show_help('climate')"
             onMouseOver="window.status='Explain climate symbols';return true"
             onMouseOut="window.status='Forest Service Disturbed WEPP Model';return true">
             <img src="/fswepp/images/quest_b.gif" border=0 name="gradient_quest" align=right></a>
      </td>
     <tr align=top>
      <td align="center" bgcolor="#FAF8CC">
       <SELECT NAME="Climate" id="Climate" SIZE="', $num_cli + 1, '" tabindex="3">
);

foreach my $ii ( 0 .. $#climates ) {
    print '<OPTION VALUE="', $climates[$ii]->{'clim_file'}, '"';
    print ' selected' if $ii == 0;
    print '> ', $climates[$ii]->{'clim_name'}, "\n";
}

print qq(
    </SELECT>
    <tr><td align="center">
    <input type="hidden" name="achtung" value="Run WEPP">
    <button type="button" onclick="window.location.href='/cgi-bin/fswepp/rc/rockclim.pl?comefrom=wd&units=$units'">Custom Climate</button>
    <input type="button" value="Closest Wx" onclick="popupclosest()">
);

#################
#
#      SOIL TEXTURES SELECTION
#
print qq(
     <tr>
      <td height=5 bgcolor="red"></td>
     <tr>
     <tr>
      <td align="center" bgcolor="85d2d2">
       <b><a href="JavaScript:submitme('Describe Soil')"
             onMouseOver="window.status='Describe soil';return true"
             onMouseOut="window.status='Forest Service Disturbed WEPP Model'; return true">
             Soil Texture</a></b>
          <a href="JavaScript:show_help('soil_texture')"
             onMouseOver="window.status='Explain soil texture';return true"
             onMouseOut="window.status='Forest Service Disturbed WEPP Model'; return true">
             <img src="/fswepp/images/quest_b.gif" border=0 name="soil_quest"></a>
);

print '
      <tr>
       <td align="center" bgcolor="#FAF8CC">
        <select name="SoilType" size="4" taborder="3"
         onChange="showTexture()"
         onBlur="blankStatus()">
         <option value="clay" selected>clay loam</option>
         <option value="silt">silt loam</option>
         <option value="sand">sandy loam</option>
         <option value="loam">loam</option>
        </select>
      </td>
     </tr>
    </table>

  </td>
  <td>
';

print <<'theEnd';
<table border=2 cellpadding=6>
<tr><th bgcolor=85d2d2>
  <font face="Arial, Geneva, Helvetica">Element
    <th bgcolor="#85d2d2">
     <font face="Arial, Geneva, Helvetica">Treatment /<br>Vegetation
            <a href="JavaScript:show_help('vegetation_treatment')"
               onMouseOver="window.status='Explain treatment';return true"
               onMouseOut="window.status='Forest Service Water And Sediment Predictor';return true">
               <img src="/fswepp/images/quest_b.gif" border=0 name="treat_quest" align=right></a>
    <th bgcolor="#85d2d2">
     <font face="Arial, Geneva, Helvetica">Gradient (%)<br>
             <a href="JavaScript:show_help('gradient')"
               onMouseOver="window.status='Explain gradient';return true"
               onMouseOut="window.status='Forest Service Disturbed WEPP Model';return true">
               <img src="/fswepp/images/quest_b.gif" border=0 name="gradient_quest" align=right></a>
            </font>
theEnd
print
"    <th bgcolor=85d2d2><font face=\"Arial, Geneva, Helvetica\">Horizontal<br>Length ($units)\n";
print <<'theEnd';
           <th bgcolor=85d2d2><font face="Arial, Geneva, Helvetica">Cover (%) <br>
             <a href="JavaScript:show_help('cover')"
               onMouseOver="window.status='Explain cover';return true"
               onMouseOut="window.status='Forest Service Disturbed WEPP Model';return true">
               <img src="/fswepp/images/quest_b.gif" border=0 name="gradient_quest" align=right></a>
</font>

    <th bgcolor=85d2d2><font face="Arial, Geneva, Helvetica">Rock (%) <br>
             <a href="JavaScript:show_help('rock')"
               onMouseOver="window.status='Explain rock content';return true"
               onMouseOut="window.status='Forest Service Water And Sediment Predictor';return true">
               <img src="/fswepp/images/quest_b.gif" border=0 name="rock_quest" align=right></a>
   <tr>
    <th rowspan=2 bgcolor="#85d2d2"><font face="Arial, Geneva, Helvetica">Upper
    <TD rowspan=2 bgcolor="#FAF8CC">
    <SELECT NAME="UpSlopeType" SIZE="8" ALIGN="top" onChange="pcover1()" taborder="5">
     <OPTION VALUE="OldForest" selected> Mature forest
     <OPTION VALUE="YoungForest"> Thin or young forest
     <OPTION VALUE="Shrub"> Shrubs
     <OPTION VALUE="Bunchgrass"> Good grass
     <OPTION VALUE="Sod"> Poor grass
     <OPTION VALUE="LowFire"> Low severity fire
     <OPTION VALUE="HighFire"> High severity fire
     <OPTION VALUE="Skid"> Skid trail
    </SELECT>
    <td bgcolor="#FAF8CC"><input type="text" size=5 name="ofe1_top_slope" value="0" taborder="7"
        onChange="checkRange(ofe1_top_slope,smin,smax,ofe1tsdef,sunit,'Slope')"
        onFocus="showRange(this.form,'Slope: ',smin,smax,sunit,'')"
        onBlur="blankStatus()">
    <td rowspan=2 bgcolor="#FAF8CC"><input type="text" size=5 name="ofe1_length" value="50" taborder="11"
        onChange="checkRange(ofe1_length,lmin,lmax,ldef,lunit,'Upper element length')"
        onFocus="showRange(this.form,'Upper element length: ',lmin,lmax,lunit,'')"
        onBlur="blankStatus()">
    <td rowspan=2 bgcolor="#FAF8CC"><input type="text" size=5 name="ofe1_pcover" value="100" taborder="13"
        onChange="checkRange(ofe1_pcover,pcmin,pcmax,pcdef,pcunit,'Percent cover')"
        onFocus="showRange(this.form,'Percent cover: ',pcmin,pcmax,pcunit,'')"
        onBlur="blankStatus()">
    <td rowspan=2 bgcolor="#FAF8CC"><input type="text" size=5 name="ofe1_rock" value="20" taborder="15"
        onChange="checkOFE1rock(ofe1_rock,rmin,rmax,rdef,runit,'Percent rock')"
        onFocus="showRange(this.form,'Percent rock: ',rmin,rmax,runit,' (50% for rock/pavement)')"
        onBlur="blankStatus()"> 
   <tr>
    <td bgcolor="#FAF8CC"><input type="text" size=5 name="ofe1_mid_slope" value="30" taborder="8"
        onChange="checkRange(ofe1_mid_slope,smin,smax,ofe1msdef,sunit,'Slope')"
        onFocus="showRange(this.form,'Slope: ',smin,smax,sunit,'')"
        onBlur="blankStatus()">
   <tr>
    <th rowspan=2 bgcolor="#85d2d2"><font face="Arial, Geneva, Helvetica">Lower
    <TD rowspan=2 bgcolor="#FAF8CC">
     <SELECT NAME="LowSlopeType" SIZE="8" ALIGN="top" onChange="pcover2()" taborder="6">
      <OPTION VALUE="OldForest" selected> Mature forest
      <OPTION VALUE="YoungForest"> Thin or young forest
      <OPTION VALUE="Shrub"> Shrubs
      <OPTION VALUE="Bunchgrass"> Good grass
      <OPTION VALUE="Sod"> Poor grass
      <OPTION VALUE="LowFire"> Low severity fire
      <OPTION VALUE="HighFire"> High severity fire
      <OPTION VALUE="Skid"> Skid trail
     </SELECT>
    <td bgcolor="#FAF8CC"><input type="text" size=5 name="ofe2_top_slope" value="30" taborder="9"
        onChange="checkRange(ofe2_top_slope,smin,smax,ofe2tsdef,sunit,'Slope')"
        onFocus="showRange(this.form,'Slope range: ',smin,smax,sunit,'')"
        onBlur="blankStatus()">
    <td rowspan=2 bgcolor="#FAF8CC"><input type="text" size=5 name="ofe2_length" value="50" taborder="12"
        onChange="checkRange(ofe2_length,lmin,lmax,ldef,lunit,'Lower element length')"
        onFocus="showRange(this.form,'Lower element length: ',lmin,lmax,lunit,'')"
        onBlur="blankStatus()">
    <td rowspan=2 bgcolor="#FAF8CC"><input type="text" size=5 name="ofe2_pcover" value="100" taborder="14"
        onChange="checkRange(ofe2_pcover,pcmin,pcmax,pcdef,pcunit,'Percent cover')"
        onFocus="showRange(this.form,'Percent cover: ',pcmin,pcmax,pcunit,'')"
        onBlur="blankStatus()">
    <td rowspan=2 bgcolor="#FAF8CC"><input type="text" size=5 name="ofe2_rock" value="20" taborder="16"
        onChange="checkRange(ofe2_rock,rmin,rmax,rdef,runit,'Percent rock')"
        onFocus="showRange(this.form,'Percent rock: ',rmin,rmax,runit,'')"
        onBlur="blankStatus()">
   <tr><td bgcolor="#FAF8CC"><input type="text" size=5 name="ofe2_bot_slope" value="5" taborder="10"
        onChange="checkRange(ofe2_bot_slope,smin,smax,ofe2bsdef,sunit,'Slope')"
        onFocus="showRange(this.form,'Slope range: ',smin,smax,sunit,'')"
        onBlur="blankStatus()">
  </TABLE>
   </td>
  </tr>
</table>

   <input type=hidden name="climate_name">

<br>
<INPUT TYPE="HIDDEN" NAME="Units" VALUE="m">
<INPUT TYPE="SUBMIT" name="actionw" VALUE="Run WEPP"
       onClick='checkeverything()'>

<font size=1>
</font>

<BR>
</center>
</FORM>
<P>
<HR>
theEnd

print '>                                                              

<font size=-2>
Disturbed WEPP allows users easily to describe numerous disturbed
          forest and rangeland erosion conditions.
          The interface  presents the probability of a given level of
          erosion occurring the year following a disturbance.
          Version 2.0 needs no vegetation calibration.<br><br>
<b>Citation:</b><br>
Elliot, William J.; Hall, David E. 2010. Disturbed WEPP Model 2.0. Ver. ',
  $version, '.
Moscow, ID: U.S. Department of Agriculture, Forest Service, Rocky Mountain Research Station. 
Online at &lt;https://forest.moscowfsl.wsu.edu/fswepp&gt;.
<br><br>
  Interface v.
  <a href="https://github.com/wepp-in-the-woods/fswepp-docker/commits/main/var/www/cgi-bin/fswepp/wd/weppdist.pl">',
  $version, '</a><br>
';
$remote_host    = $ENV{'REMOTE_HOST'};
$remote_address = $ENV{'REMOTE_ADDR'};

$wc    = `wc ../working/' . currentLogDir() . '/wd2.log`;
@words = split " ", $wc;
$runs  = @words[0];

print "
   $remote_host &ndash; $remote_address ($user_really) personality '<b>$me</b>'<br>
   Log of FS WEPP runs for IP and personality <a href=\"/cgi-bin/fswepp/runlogger.pl\" target=\"_rl\">$remote_address$me</a>
   <br>
   <b>$runs</b> Disturbed WEPP 2.0 Model runs YTD
   <br>
 </body>
</html>
";

