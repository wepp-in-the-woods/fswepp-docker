#!/usr/bin/perl

#
#  Tahoe Basin Sediment Model input screen
#

#  tahoe.pl -- input screen for Tahoe Basin Sediment Model

#  2009.08.24 DEH Modify Disturbed WEPP input screen weppdist.pl for Tahoe Basin Sediment Model

## BEGIN HISTORY ###################################
## Tahoe Basin Sediment Model version history

   $version = '2012.05.15';	# adjust units and details
#  $version = '2012.04.25';	# add Fines upper size
#  $version = '2012.04.09';	# move phosphorus concentration inputs to input page; no need to be interactive
#  $version = '2012.01.27';	# Phosphorus calculations
#  $version = '2011.12.01';	# Reformat a bit
#  $version = '2011.02.14';	# Adjust handling of sod and bunchgrass
#  $version = '2010.12.09';	# Modify "closest" button to work under IE8
#  $version = '2010.06.01';	# Preliminary release
#! $version = '2010.05.21';	# 

## END HISTORY ###################################

#  usage:
#    action = "tahoe.pl"	# call Tahoe engine
#  parameters:
#    units:             # unit scheme (ft|m)
#    me			# user personality
#  reads environment variables:
#       HTTP_COOKIE	# FSWEPPuser
#       REMOTE_ADDR
#       HTTP_X_FORWARDED_FOR
#       REQUEST_METHOD
#       QUERY_STRING
#       CONTENT_LENGTH
#  reads:
#    ../wepphost        # localhost or other
#    ../platform        # pc or unix
#    ../climates/*.par  # standard climate parameter files
#    $working/*.par     # personal climate parameter files
#  calls:
#    /cgi-bin/fswepp/tahoe/wt.pl
#  popup links:

#  FS WEPP, USDA Forest Service, Rocky Mountain Research Station, Moscow
#  AWAE
#  Science by Bill Elliot et alia
#  Code by David Hall 

    &ReadParse(*parameters);
    $units=$parameters{'units'};
    if ($units eq 'm') {$areaunits='ha'}
    elsif ($units eq 'ft') {$areaunits='ac'}
    else {$units = 'ft'; $areaunits='ac'}

###   find personality ###
    $cookie = $ENV{'HTTP_COOKIE'};
    $sep = index ($cookie,"FSWEPPuser=");
    $me = "";
    if ($sep > -1) {$me = substr($cookie,$sep+11,1)}

    if ($me ne "") {
#       $me = lc(substr($me,0,1));
       $me = substr($me,0,1);
       $me =~ tr/a-zA-Z/ /c;
    }
    if ($me eq " ") {$me = ""}

  $wepphost="localhost";
  if (-e "../wepphost") {
    open Host, "<../wepphost";
    $wepphost = <Host>;
    chomp $wepphost;
    close H;
  }

  $platform="pc";
  if (-e "../platform") {
    open Platform, "<../platform";
      $platform=lc(<Platform>);
      chomp $platform;
    close Platform;
  }
  if ($platform eq "pc") {
    if (-e 'd:/fswepp/working') {$working = 'd:\\fswepp\\working\\'}
    elsif (-e 'c:/fswepp/working') {$working = 'c:\\fswepp\\working\\'}
    else {$working = '..\\working\\'}			# 2004.10.13 DEH
    $public = $working . '\\public\\'; 
    $logFile = "$working\\wdwepp.log";
    $cliDir = '..\\climates\\';
    $custCli = "$working";
  }
  else {
    $working='../working/';                             # DEH 08/22/2000
    $public = $working . 'public/';                     # DEH 09/21/2000
    $user_ID=$ENV{'REMOTE_ADDR'};
    $user_really=$ENV{'HTTP_X_FORWARDED_FOR'};          # DEH 11/14/2002
    $user_ID=$user_really if ($user_really ne '');      # DEH 11/14/2002
    $user_ID =~ tr/./_/;
    $user_ID = $user_ID . $me . '_';			# DEH 03/05/2001
    $logFile = '../working/' . $user_ID . '.log';
    $cliDir = '../climates/';
    $custCli = '../working/' . $user_ID;		# DEH 03/02/2001
  }

########################################

### get personal climates, if any

    $num_cli=0;

    opendir CLIMDIR, $working;                          # DEH 06/14/2000
    @allpfiles=readdir CLIMDIR;                         # DEH 05/05/2000
    close CLIMDIR;                                      # DEH 05/05/2000

#   @fileNames = glob($custCli . '*.par');
#   for $f (@fileNames) {
    for $f (@allpfiles) {                               # DEH 05/05/2000
      if (index($f,$user_ID)==0) {			# DEH 09/15/2000
        if (substr($f,-4) eq '.par') {                  # DEH 05/05/2000
          $f = $working . $f;                           # DEH 06/14/2000
          open(M,"<$f") || goto pskip;                  # DEH 05/05/2000
            $station = <M>;
          close (M);
#  print STDERR "$f\n";
          $climate_file[$num_cli] = substr($f, 0, -4);
          $clim_name = '*' . substr($station, index($station, ":")+2, 40);
          $clim_name =~ s/^\s*(.*?)\s*$/$1/;
          $climate_name[$num_cli] = $clim_name;
          $num_cli += 1;
        }
pskip:                                                  # DEH 05/05/2000
      }                                                 # DEH 05/05/2000
    }

### get standard climates

    opendir CLIMDIR, '../climates';                     # DEH 05/05/2000
    @allfiles=readdir CLIMDIR;                          # DEH 05/05/2000
    close CLIMDIR;                                      # DEH 05/05/2000

#   while (<../climates/*.par>) {                       # DEH 05/05/2000
#     $f = $_;                                          # DEH 05/05/2000

    for $f (@allfiles) {                                # DEH 05/05/2000
      $f = '../climates/' . $f;                         # DEH 05/05/2000
      if (substr($f,-4) eq '.par') {                    # DEH 05/05/2000
        open(M,$f) || goto sskip;                       # DEH 05/05/2000
          $station = <M>;
        close (M);
#  print STDERR "$f\n";
        $climate_file[$num_cli] = substr($f, 0, -4);
        $clim_name = substr($station, index($station, ":")+2, 40);
        $clim_name =~ s/^\s*(.*?)\s*$/$1/;
        $climate_name[$num_cli] = $clim_name;
        $num_cli += 1;
sskip:                                                  # DEH 05/05/2000
      }                                                 # DEH 05/05/2000
    }
    $num_cli -= 1;

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
  <META NAME="Source" content="Run online at http://forest.moscowfsl.wsu.edu/fswepp/">

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
  var rmin = 0		//dehdehdeh2004//
  var rmax = 75
  var rdef = 20

  var previous_what=''  // for show_help

function popupclosest() {
url = 'http://forest.moscowfsl.wsu.edu/fswepp/rc/closest.php?units=ft';
width=900;
height=600;
popupwindow = window.open(url,'popupwindow','toolbar=no,location=no,status=no,directories=no,menubar=no,scrollbars=yes,resizable=yes,width='+width+',height='+height);
popupwindow.focus()
}

theEnd2

if ($units eq "m") {
  $lunit = ' m';
  $lmin = 0.5;
  $lmax = 400;
  $ldef = 50;
}
else {
  $lunit = ' ft';
  $lmin = 1.5;
  $lmax = 1200;
  $ldef = 150;
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
para = para +'\'Mature forest\' and \'Young or thin forest\' are not valid for the upper element vegetation for Rock/Pavement soil texture.'
      }
      else if (what == 'cover') {				// COVER
para='<h3>Cover</h3>';
para = para +' One\'s selection of the treatment will set a suggested value for cover, with the exception of treatment "Bare."'
para = para +'  The "Bare" treatment uses for cover the current value for percent rock.'
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
para = para +'    <tr><td><font size=-1>bare</font></td>                <td><font size=-1>same as percent rock</td></tr>'
para = para +'    <tr><td><font size=-1>mulch only</font></td>          <td><font size=-1> 60% cover</font></td></tr>'
para = para +'    <tr><td><font size=-1>mulch and till</font></td>      <td><font size=-1> 80% cover</font></td></tr>'
para = para +'    <tr><td><font size=-1>low traffic road</font></td>    <td><font size=-1> 10% cover</font></td></tr>'
para = para +'    <tr><td><font size=-1>high traffic road</font></td>   <td><font size=-1> 10% cover</font></td></tr>'
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
para = para +'   The Tahoe Basin Sediment Model provides thirteen categories of vegetation or treatment.';
para = para +'   A default cover is associated with each vegetation treatment, but users are encouraged to alter this value to suit site conditions.  The vegetation treatments are:';
para = para +'   <ul>';
para = para +'    <li>  mature forest &ndash;   100% cover</li>';
para = para +'    <li>	thin or young forest &ndash;    100% cover</li>';
para = para +'    <li>	shrubs &ndash;    80% cover</li>';
para = para +'    <li>	good grass &ndash;    60% cover</li>';
para = para +'    <li>	poor grass &ndash;    40% cover</li>';
para = para +'    <li>	low severity fire &ndash;    85% cover</li>';
para = para +'    <li>	high severity fire &ndash;    45% cover</li>';
para = para +'    <li>	bare &ndash;    same as percent rock</li>';
para = para +'    <li>	mulch only &ndash;    60% cover</li>';
para = para +'    <li>	mulch and till &ndash;    80% cover</li>';
para = para +'    <li>	low traffic road &ndash;    10% cover</li>';
para = para +'    <li>	high traffic road &ndash;    10% cover</li>';
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

print "
  function popuphistory() {
    height=500;
    width=660;
    pophistory = window.open('','pophistory','toolbar=no,location=no,status=no,directories=no,menubar=no,scrollbars=yes,resizable=yes,width='+width+',height='+height);
";
    print make_history_popup();
print "
    pophistory.document.close()
    pophistory.focus()
  }
";

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
#print "    max_year = new MakeArray($num_cli);\n\n";
print "    climate_name = new MakeArray($num_cli);\n";

  for $ii (0..$num_cli) {
#    print "    max_year[$ii] = " . $climate_year[$ii] . ";\n";
    print "    climate_name[$ii] = ",'"',$climate_name[$ii],'"',"\n";
  }
print <<'theEnd';
//    window.document.weppdist.Climate.selectedIndex = 0;
//    window.document.weppdist.climyears.value = max_year[0];

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
//   window.document.weppdist.ofe1.selectedIndex = 0;
//   window.document.weppdist.ofe2.selectedIndex = 7;
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
//    window.document.weppdist.climyears.value=max_year[which];
    window.document.weppdist.climate_name.value=climate_name[which];
//    var vegyear=Math.min (max_year[which],10);
//    var simyear=Math.min (max_year[which],100);
//    window.document.weppdist.actionv.value=vegyear + "vegetation calibration";
//    window.document.weppdist.actionw.value=simyear + "WEPP run";
//    window.document.weppdist.actionv.value="vegetation calibration";
//    window.document.weppdist.actionw.value="WEPP run";
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
   if (which == 0)           {text = "Granitic"}
   else if (which == 1)      {text = "Volcanic"}
   else if (which == 2)      {text = "Alluvial"}
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
       <a href="http://',$wepphost,'/fswepp/">
       <IMG src="http://',$wepphost,'/fswepp/images/fsweppic2.jpg" width=75 height=75
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
  <FORM name="weppdist" method="post" ACTION="http://',$wepphost,'/cgi-bin/fswepp/tahoe/wtpf.pl">
  <input type="hidden" size="1" name="me" value="',$me,'">
  <input type="hidden" size="1" name="units" value="',$units,'">
<br>
 <table width=90% border=0 bgcolor="#FAF8CC">
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

print <<'theEnd';
 <table border = 5>
  <tr valign=top>
   <td valign=top>    <!-- CLIMATE above SOIL TEXTURE above FINES -->

    <TABLE border="1">
     <tr align="top">
      <td align="center" bgcolor="#85d2d2">
       <b><a href="JavaScript:submitme('Describe Climate')"
             onMouseOver="window.status='Describe climate';return true"
             onMouseOut="window.status='Forest Service Tahoe Basin Sediment Model'; return true">
             Climate</a></b>
          <a href="JavaScript:show_help('climate')"
             onMouseOver="window.status='Explain climate symbols';return true"
             onMouseOut="window.status='Forest Service Tahoe Model';return true">
             <img src="/fswepp/images/quest_b.gif" border=0 name="gradient_quest" align=right></a>
      </td>
     <tr align=top>
theEnd
print '
      <td align="center" bgcolor="#FAF8CC">
       <SELECT NAME="Climate" SIZE="',$num_cli+1,'">
';
### display personal climates, if any

    if ($num_cli > 0) {
      print '<OPTION VALUE="';
      print $climate_file[0];
      print '" selected> ', $climate_name[0] , "\n";
    }
    for $ii (1..$num_cli) {
      print '<OPTION VALUE="';
      print $climate_file[$ii];
      print '"> ', $climate_name[$ii] , "\n";
    }
    print "       </SELECT>
      <tr><td align=center>
      <input type=\"hidden\" name=\"achtung\" value=\"Run WEPP\">
      <input type=\"SUBMIT\" name=\"actionc\" value=\"Custom Climate\">
      <input type=\"button\" value=\"closest\" onclick=\"javascript:popupclosest()\">
";
#################
#
#      SOIL TEXTURES SELECTION
#
print <<'theEnd';
     <tr>
      <td height=5 bgcolor="red"></td>
     <tr>
     <tr>
      <td align="center" bgcolor="85d2d2">
       <b><a href="JavaScript:submitme('Describe Soil')"
             onMouseOver="window.status='Describe soil';return true"
             onMouseOut="window.status='Forest Service Tahoe Basin Sediment Model'; return true">
             Soil Texture</a></b>
          <a href="JavaScript:show_help('soil_texture')"
             onMouseOver="window.status='Explain soil texture';return true"
             onMouseOut="window.status='Forest Service Tahoe Basin Sediment Model'; return true">
             <img src="/fswepp/images/quest_b.gif" border=0 name="soil_quest"></a>
theEnd
print "
      <tr>
       <TD align=\"center\" bgcolor=\"#FAF8CC\">
       <font size=-1>
        <SELECT NAME=\"SoilType\" SIZE=4
         onChange=\"showTexture()\"
         onBlur=\"blankStatus()\">
         <OPTION VALUE=\"granitic\" selected>granitic
         <OPTION VALUE=\"volcanic\">volcanic
         <OPTION VALUE=\"alluvial\">alluvial
         <OPTION VALUE=\"rockpave\">rock/pavement -&gt; alluvial
        </SELECT>
        <br><br>
Fines less than <input name=fines_upper type=text size=3 value=10> microns
       </font>

      </td>
     </tr>
    </table>

  </td>
  <td>
";

print <<'theEnd';
<table border=2 cellpadding=6>
<tr><th bgcolor=85d2d2>
  <font face="Arial, Geneva, Helvetica">Element
    <th bgcolor="#85d2d2" colspan=2>
     <font face="Arial, Geneva, Helvetica">Treatment /<br>Vegetation
            <a href="JavaScript:show_help('vegetation_treatment')"
               onMouseOver="window.status='Explain treatment';return true"
               onMouseOut="window.status='Forest Service Water And Sediment Predictor';return true">
               <img src="/fswepp/images/quest_b.gif" border=0 name="treat_quest" align=right></a>
    <th bgcolor="#85d2d2">
     <font face="Arial, Geneva, Helvetica">Gradient (%)<br>
             <a href="JavaScript:show_help('gradient')"
               onMouseOver="window.status='Explain gradient';return true"
               onMouseOut="window.status='Forest Service Tahoe Model';return true">
               <img src="/fswepp/images/quest_b.gif" border=0 name="gradient_quest" align=right></a>
            </font>
theEnd
print "    <th bgcolor=85d2d2><font face=\"Arial, Geneva, Helvetica\">Horizontal<br>Length ($units)\n";
print <<'theEnd';
           <th bgcolor=85d2d2><font face="Arial, Geneva, Helvetica">Cover (%) <br>
             <a href="JavaScript:show_help('cover')"
               onMouseOver="window.status='Explain cover';return true"
               onMouseOut="window.status='Forest Service Tahoe Model';return true">
               <img src="/fswepp/images/quest_b.gif" border=0 name="gradient_quest" align=right></a>
</font>

    <th bgcolor=85d2d2><font face="Arial, Geneva, Helvetica">Rock (%) <br>
             <a href="JavaScript:show_help('rock')"
               onMouseOver="window.status='Explain rock content';return true"
               onMouseOut="window.status='Forest Service Water And Sediment Predictor';return true">
               <img src="/fswepp/images/quest_b.gif" border=0 name="rock_quest" align=right></a>
   <tr>
    <th rowspan=2 bgcolor="#85d2d2"><font face="Arial, Geneva, Helvetica">Upper
    <td rowspan=2 bgcolor="#FAF8CC" colspan=2>
    <SELECT NAME="UpSlopeType" SIZE="13" ALIGN="top" onChange="pcover1()";>
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
     <OPTION VALUE="Skid"> Skid trail
    </SELECT>
    <td bgcolor="#FAF8CC"><input type="text" size=5 name="ofe1_top_slope" value="0"
        onChange="checkRange(ofe1_top_slope,smin,smax,ofe1tsdef,sunit,'Slope')"
        onFocus="showRange(this.form,'Slope: ',smin,smax,sunit,'')"
        onBlur="blankStatus()">
    <td rowspan=2 bgcolor="#FAF8CC"><input type="text" size=5 name="ofe1_length" value="50"
        onChange="checkRange(ofe1_length,lmin,lmax,ldef,lunit,'Upper element length')"
        onFocus="showRange(this.form,'Upper element length: ',lmin,lmax,lunit,'')"
        onBlur="blankStatus()">
    <td rowspan=2 bgcolor="#FAF8CC"><input type="text" size=5 name="ofe1_pcover" value="100"
        onChange="checkRange(ofe1_pcover,pcmin,pcmax,pcdef,pcunit,'Percent cover')"
        onFocus="showRange(this.form,'Percent cover: ',pcmin,pcmax,pcunit,'')"
        onBlur="blankStatus()">
    <td rowspan=2 bgcolor="#FAF8CC"><input type="text" size=5 name="ofe1_rock" value="20"
        onChange="checkOFE1rock(ofe1_rock,rmin,rmax,rdef,runit,'Percent rock')"
        onFocus="showRange(this.form,'Percent rock: ',rmin,rmax,runit,' (50% for rock/pavement)')"
        onBlur="blankStatus()">
   <tr>
    <td bgcolor="#FAF8CC"><input type="text" size=5 name="ofe1_mid_slope" value="30"
        onChange="checkRange(ofe1_mid_slope,smin,smax,ofe1msdef,sunit,'Slope')"
        onFocus="showRange(this.form,'Slope: ',smin,smax,sunit,'')"
        onBlur="blankStatus()">
   <tr>
    <th rowspan=2 bgcolor="#85d2d2"><font face="Arial, Geneva, Helvetica">Lower
    <td rowspan=2 bgcolor="#FAF8CC" colspan=2>
    <SELECT NAME="LowSlopeType" SIZE="13" ALIGN="top" onChange="pcover2()";>
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
     <OPTION VALUE="Skid"> Skid trail
    </SELECT>
    <td bgcolor="#FAF8CC"><input type="text" size=5 name="ofe2_top_slope" value="30"
        onChange="checkRange(ofe2_top_slope,smin,smax,ofe2tsdef,sunit,'Slope')"
        onFocus="showRange(this.form,'Slope range: ',smin,smax,sunit,'')"
        onBlur="blankStatus()">
    <td rowspan=2 bgcolor="#FAF8CC"><input type="text" size=5 name="ofe2_length" value="50"
        onChange="checkRange(ofe2_length,lmin,lmax,ldef,lunit,'Lower element length')"
        onFocus="showRange(this.form,'Lower element length: ',lmin,lmax,lunit,'')"
        onBlur="blankStatus()">
    <td rowspan=2 bgcolor="#FAF8CC"><input type="text" size=5 name="ofe2_pcover" value="100"
        onChange="checkRange(ofe2_pcover,pcmin,pcmax,pcdef,pcunit,'Percent cover')"
        onFocus="showRange(this.form,'Percent cover: ',pcmin,pcmax,pcunit,'')"
        onBlur="blankStatus()">
    <td rowspan=2 bgcolor="#FAF8CC"><input type="text" size=5 name="ofe2_rock" value="20"
        onChange="checkRange(ofe2_rock,rmin,rmax,rdef,runit,'Percent rock')"
        onFocus="showRange(this.form,'Percent rock: ',rmin,rmax,runit,'')"
        onBlur="blankStatus()">
   <tr><td bgcolor="#FAF8CC"><input type="text" size=5 name="ofe2_bot_slope" value="5"
        onChange="checkRange(ofe2_bot_slope,smin,smax,ofe2bsdef,sunit,'Slope')"
        onFocus="showRange(this.form,'Slope range: ',smin,smax,sunit,'')"
        onBlur="blankStatus()">
   </tr>
   <tr>
    <th bgcolor="#85d2d2">
     <font size=-1>
      Phosphorus<br>Concentration
     </font>
    </th>
    <th bgcolor="#85d2d2">
     <font size=-1>
      Surface<br>Runoff
     </font>
    </th>
    <td bgcolor="#FAF8CC">
     <font size=-1>
      <input name='sr_conc' type=text value='1.0' size=3>&nbsp;mg/l
     </font>
    </td>
    <th bgcolor="#85d2d2">
     <font size=-1>
      Lateral Flow
     </font>
    </th>
    <td bgcolor="#FAF8CC">
     <font size=-1>
      <input name='lf_conc' type=text value='1.5' size=3>&nbsp;mg/l
     </font>
    </td>
    <th bgcolor="#85d2d2">
     <font size=-1>
      Sediment
     </font>
    </th>
    <td bgcolor="#FAF8CC">
     <font size=-1>
      <input name='sed_conc' type=text value='100' size=3>&nbsp;mg/kg
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
    <th bgcolor="#85d2d2">
     <font size=-1>
      <b>Years to<br>simulate:</b>
     </font>
    </th>
    <td bgcolor="#FAF8CC">
     <font size=-1>
      <input type="text" size="3" name="climyears" value="10"
         onChange="checkYears(this.form.climyears)"
         onFocus="showRange(this.form,'Years to Simulate: ',minyear, maxyear, '','')"
         onBlur="blankStatus()"> years
     </font>
    </td>
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
  <a href="http://',$wepphost,'/fswepp/comments.html" ';
  if ($wepphost eq 'localhost') {print 'onClick="return confirm(\'You must be connected to the Internet to e-mail comments. Shall I try?\')"'};                                  
  print '>                                                              
  <img src="/fswepp/images/epaemail.gif" align="right" border=0></a>
  <a href="http://www.blm.gov/nv/st/en/snplma.html" target="snplma"><img src="/fswepp/images/SNPLMAlogo.png" width=100 align="right" border=o></a>

  <font size=-2>
   The Tahoe Basin Sediment Model is a version of Disturbed WEPP customized for the Lake Tahoe Basin.
   <br><br>
   <b>Citation:</b><br>
   Elliot, William J.; Hall, David E. 2010. Tahoe Basin Sediment Model. Ver. ', $version,'.
   Moscow, ID: U.S. Department of Agriculture, Forest Service, Rocky Mountain Research Station. 
   Online at &lt;http://forest.moscowfsl.wsu.edu/fswepp&gt;.
   <br><br>
   With support from the U.S. Department of the Interior Bureau of Land Management
   <a href="http://www.blm.gov/nv/st/en/snplma.html">Southern Nevada Public Land Management Act</a>
   <br><br>
   Interface v.
   <a href="javascript:popuphistory()">',$version,'</a><br>
';
  $remote_host = $ENV{'REMOTE_HOST'};
  $remote_address = $ENV{'REMOTE_ADDR'};

  $wc  = `wc ../working/wt.log`;
  @words = split " ", $wc;
  $runs = @words[0];

print "  $remote_host &ndash; $remote_address ($user_really) personality '<b>$me</b>'<br>
  <b>$runs</b> Tahoe Basin Sediment Model runs since Jan 01, 2011
 </body>
</html>
";

# --------------------- subroutines

sub ReadParse {

# ReadParse -- from cgi-lib.pl (Steve Brenner) from Eric Herrmann's
# "Teach Yourself CGI Programming With PERL in a Week" p. 131

# Reads GET or POST data, converts it to unescaped text, and puts
# one key=value in each member of the list "@in"
# Also creates key/value pairs in %in, using '\0' to separate multiple
# selections

# If a variable-glob parameter...

  local (*in) = @_ if @_;
  local ($i, $loc, $key, $val);

  if ($ENV{'REQUEST_METHOD'} eq "GET") {
    $in = $ENV{'QUERY_STRING'};
  } elsif ($ENV{'REQUEST_METHOD'} eq "POST") {
    read(STDIN,$in,$ENV{'CONTENT_LENGTH'});
  }

  @in = split(/&/,$in);

  foreach $i (0 .. $#in) {
    # Convert pluses to spaces
    $in[$i] =~ s/\+/ /g;

    # Split into key and value
    ($key, $val) = split(/=/,$in[$i],2);  # splits on the first =

    # Convert %XX from hex numbers to alphanumeric
    $key =~ s/%(..)/pack("c",hex($1))/ge;
    $val =~ s/%(..)/pack("c",hex($1))/ge;

    # Associative key and value
    $in{$key} .= "\0" if (defined($in{$key}));  # \0 is the multiple separator
    $in{$key} .= $val;
  }
  return 1;
 }

sub make_history_popup {

  my $version;

# Reads parent (perl) file and looks for a history block:
## BEGIN HISTORY ####################################################
# ERMiT Version History

  $version='2005.02.08';        # Make self-creating history popup page
# $version = '2005.02.07';      # Fix parameter passing to tail_html; stuff after semicolon lost
#!$version = '2005.02.07';      # Bang in line says do not use
# $version = '2005.02.04';      # Clean up HTML formatting, add head_html and tail_html functions
#                               # Continuation line not handled
# $version = '2005.01.08';      # Initial beta release

## END HISTORY ######################################################

# and returns body (including Javascript document.writeln instructions) for a pop-up history window
# called pophistory.

# First line after 'BEGIN HISTORY' is <title> text
# Splits version and comment on semi-colon
# Version must be version= then digits and periods
# Bang in line causes line to be ignored
# Disallowed: single and double quotes in comment part
# Not handled: continuation lines

# Usage:

#print "<html>
# <head>
#  <title>$title</title>
#   <script language=\"javascript\">
#    <!-- hide from old browsers...
#
#  function popuphistory() {
#    pophistory = window.open('','pophistory','')
#";
#    print make_history_popup();
#print "
#    pophistory.document.close()
#    pophistory.focus()
#  }
#";

# print $0,"\n";

  my ($line, $z, $vers, $comment);

  open MYSELF, "<$0";
    while (<MYSELF>) {

      next if (/!/);

      if (/## BEGIN HISTORY/) {
        $line = <MYSELF>;
        chomp $line;
        $line = substr($line,2);
        $z = "    pophistory.document.writeln('<html>')
    pophistory.document.writeln(' <head>')
    pophistory.document.writeln('  <title>$line</title>')
    pophistory.document.writeln(' </head>')
    pophistory.document.writeln(' <body bgcolor=white>')
    pophistory.document.writeln('  <font face=\"trebuchet, tahoma, arial, helvetica, sans serif\">')
    pophistory.document.writeln('  <center>')
    pophistory.document.writeln('   <h4>$line</h4>')
    pophistory.document.writeln('   <p>')
    pophistory.document.writeln('   <table border=0 cellpadding=10>')
    pophistory.document.writeln('    <tr>')
    pophistory.document.writeln('     <th bgcolor=lightblue>Version</th>')
    pophistory.document.writeln('     <th bgcolor=lightblue>Comments</th>')
    pophistory.document.writeln('    </tr>')
";
      } # if (/## BEGIN HISTORY/)

      if (/version/) {
        ($vers, $comment) = split (/;/,$_);
        $comment =~ s/#//;
        chomp $comment;
        $vers =~ s/'//g;
        $vers =~ s/ //g;
        $vers =~ s/"//g;
        if ($vers =~ /version=*([0-9.]+)/) {    # pull substring out of a line
          $z .= "    pophistory.document.writeln('    <tr>')
    pophistory.document.writeln('     <th valign=top bgcolor=lightblue>$1</th>')
    pophistory.document.writeln('     <td>$comment</td>')
    pophistory.document.writeln('    </tr>')
";
        }       # (/version *([0-9]+)/)
     }  # if (/version/)

    if (/## END HISTORY/) {
        $z .= "    pophistory.document.writeln('   </table>')
    pophistory.document.writeln('   </font>')
    pophistory.document.writeln('  </center>')
    pophistory.document.writeln(' </body>')
    pophistory.document.writeln('</html>')
";
      last;
    }     # if (/## END HISTORY/)
  }     # while
  close MYSELF;
  return $z;
}
