#!/usr/bin/perl

#
#  ERMiT input screen
#

#  ERMiT.pl -- input screen for ERMiT

#  2002.11.06  DEH added % shrub %grass %bare for range / chaparral
#  2002.08.22  DEH transformed weppdist.pl from "forest"
#  2002.01.08  DEH Removed errant return link ot "dindex.html" & wrap pbs

    $version = '2002.11.06';

#  usage:
#    action = "ermit.pl"
#  parameters:
#    units:             # unit scheme (ft|m)
#    me
#  reads environment variables:
#       HTTP_COOKIE
#       REMOTE_ADDR
#       REMOTE_HOST
#       REQUEST_METHOD
#       QUERY_STRING
#       CONTENT_LENGTH
#  reads:
#    ../wepphost        # localhost or other
#    ../platform        # pc or unix
#    ../climates/*.par  # standard climate parameter files
#    $working/*.par     # personal climate parameter files
#  calls:
#    /cgi-bin/fswepp/wr/wr.pl
#    /cgi-bin/fswepp/wr/logstuff.pl
#  popup links:
#    /fswepp/wr/wrwidths.html
#    /fswepp/wr/rddesign.html

#  FSWEPP, USDA Forest Service, Rocky Mountain Research Station, 
#  Soil & Water Engineering
#  Science by Bill Elliot et alia
#  Code by David Hall 

  $remote_host = $ENV{'REMOTE_HOST'};                           
  $remote_address = $ENV{'REMOTE_ADDR'};  # if ($userIP eq ''); 

    &ReadParse(*parameters);
    $units=$parameters{'units'};
    if ($units eq 'm') {$areaunits='ha'}
    elsif ($units eq 'ft') {$areaunits='ac'}
    else {$units = 'ft'; $areaunits='ac'}
#    $me=$parameters{'me'};
    $cookie = $ENV{'HTTP_COOKIE'};
    $sep = index ($cookie,"=");
    $me = "";
    if ($sep > -1) {$me = substr($cookie,$sep+1,1)}

    if ($me ne "") {
       $me = lc(substr($me,0,1));
       $me =~ tr/a-z/ /c;
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
    if (-e 'd:/fswepp/working') {$working = 'd:\\fswepp\\working'}
    elsif (-e 'c:/fswepp/working') {$working = 'c:\\fswepp\\working'}
    else {$working = '..\\working'}
    $public = $working . '\\public'; 
    $logFile = "$working\\wdwepp.log";
    $cliDir = '..\\climates\\';
    $custCli = "$working\\";
  }
  else {
    $working='../working/';                             # DEH 08/22/2000
    $public = $working . 'public/';                     # DEH 09/21/2000
    $user_ID=$ENV{'REMOTE_ADDR'};
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
print <<'theEnd';
<html>
<head>
<title>ERMiT</title>
  <!--<bgsound src="journey.wav">-->
  <SCRIPT LANGUAGE = "JavaScript" type="TEXT/JAVASCRIPT">
  <!--

  var minyear = 1
  var maxyear = 200
  var defyear = 30

  function submitme(which) {
    document.forms.ermit.achtung.value=which
//    document.forms.ermit.submit.value="Describe"
    document.forms.ermit.submit()
    return true
  }

  function bushes() {

    var vegtype = document.ermit.vegetation.value
//    alert(vegtype)

    if (vegtype == 'range') {
      document.ermit.pct_shrub.value = 15
      document.ermit.pct_grass.value = 75
      document.ermit.pct_bare.value = 100 - document.ermit.pct_shrub.value - document.ermit.pct_grass.value
    }
    if (vegtype == 'forest') {
      document.ermit.pct_shrub.value = ''
      document.ermit.pct_grass.value = ''
      document.ermit.pct_bare.value = ''
    }
    if (vegtype == 'chap') {
      document.ermit.pct_shrub.value = 80
      document.ermit.pct_grass.value = 0
      document.ermit.pct_bare.value = 100 - document.ermit.pct_shrub.value - document.ermit.pct_grass.value
    }
    return true
  }

  function shrub () {

    var shrub = parseFloat(document.ermit.pct_shrub.value)
    var grass = parseFloat(document.ermit.pct_grass.value)
    var bare  = parseFloat(document.ermit.pct_bare.value)

    if (document.ermit.vegetation.value == 'forest') {
      document.ermit.pct_shrub.value = ''
      return
    }

    if (!isNumber(grass)) {grass = 0}
    if (isNumber(shrub)) {
      if (shrub > 100.1) {
        shrub = 100
        grass = 0
      }
      else {
        if (shrub + grass > 100.1) {
//          alert(shrub + grass, 'is too big') 
          grass = 100 - shrub
        }
        else {
//          alert('not too big')
        }
      }
      bare = 100 - shrub - grass
    }
    else {
      shrub = ''
      bare = 100 - grass
    }
    document.ermit.pct_shrub.value = shrub
    document.ermit.pct_grass.value = grass
    document.ermit.pct_bare.value  = bare
  }

  function grass () {

    var shrub = parseFloat(document.ermit.pct_shrub.value)
    var grass = parseFloat(document.ermit.pct_grass.value)
    var bare  = parseFloat(document.ermit.pct_bare.value)

    if (document.ermit.vegetation.value == 'forest') {
      document.ermit.pct_grass.value = ''
      return
    }

    if (!isNumber(shrub)) {shrub = 0}
    if (isNumber(grass)) {
      if (grass > 100.1) {
        grass = 100
        shrub = 0
      }
      else {
        if (grass + shrub > 100.1) {
//          alert(shrub + grass, 'is too big') 
          shrub = 100 - grass
        }
        else {
//          alert('not too big')
        }
      }
      bare = 100 - shrub - grass
    }
    else {
      grass = ''
      bare = 100 - shrub
    }
    document.ermit.pct_shrub.value = shrub
    document.ermit.pct_grass.value = grass
    document.ermit.pct_bare.value  = bare
  }

  function bare () {
    var shrub = parseFloat(document.ermit.pct_shrub.value)
    var grass = parseFloat(document.ermit.pct_grass.value)
    if (isNumber(shrub) && isNumber(grass)) {
      document.ermit.pct_bare.value = 100 - shrub - grass
    }
    else {
      document.ermit.pct_shrub.value = ''
      document.ermit.pct_grass.value = ''
      document.ermit.pct_bare.value = ''
    }
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

  function ravelcheck () {
    alert('checking for dry ravel conditions');
    var soiltexture='loam'
    var which = window.document.ermit.SoilType.selectedIndex;
    if (which == 0) {soiltexture='clay loam'}
    else if (which == 1) {soiltexture='silt loam'}
    else if (which == 2) {soiltexture='sandy loam'}
    var text='Soil texture: ' + soiltexture
    alert(text);

    ravel()
    return true;
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

  }

function RunningMsg (obj, text) {
       obj.value=text
}

  function checkRange(obj,min,max,def,unit,thistext) {
     if (isNumber(obj.value)) {                   // obj == document.ermit.BS
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
     } else {
         alert("Invalid entry for " + thistext + "!")
         obj.value=def
       }
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
         return false
       }
       if (obj.value > maxyear) {
         alert(alert_text)
         obj.value=maxyear
         return false
       }
     } else {
         alert("Invalid entry for number of years!")
         obj.value=defyear
         return false
       }
  }

function showRange(obj, head, min, max, unit)
{
  range = head + min + " to " + max + unit	
  window.status = range
  return true                           // p. 86
}

function showHelp(obj, head, min, max, unit)
{
  var which = window.document.ermit.SlopeType.selectedIndex;
     if (which == 0) {vhead = "Ditch width + traveledway width: "}
     else if (which == 1) {vhead = "Ditch width + traveledway width: "}
     else if (which == 2) {vhead = "Traveledway width: "}
     else {vhead = "Rut spacing + rut width: "}
  range = vhead + min + " to " + max + unit	
  window.status = range
  return true                           // p. 86
}

function showTexture()
{
  var which = window.document.ermit.SoilType.selectedIndex;
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

// begin DRY RAVEL CODE

  var windowWidth
  var windowHeight
  var windowLeft
  var newin = null
  var helpwindowWidth
  var helpwindowHeight
  var newhelpwin = null

function ravel() {

  var theta_crit = 32		// deg -- critical surface slope
  var rfg_crit = 18		// %   -- critical course (rock) fragment

  var sed_20_no_trigger = 40	// t ha^-1 sediment (ravel) for high severity (20% cover) no trigger
  var sed_40_no_trigger = 30	// t ha^-1 sediment (ravel) for mod severity (40% cover) no trigger
  var sed_60_no_trigger = 20	// t ha^-1 sediment (ravel) for low severity (60% cover) no trigger

  var sed_20_low_trigger = 50	// t ha^-1 sediment (ravel) for high severity (20% cover) low trigger
  var sed_40_low_trigger = 40	// t ha^-1 sediment (ravel) for mod severity (40% cover) low trigger
  var sed_60_low_trigger = 30	// t ha^-1 sediment (ravel) for low severity (60% cover) low trigger

  var sed_20_mod_trigger = 60	// t ha^-1 sediment (ravel) for high severity (20% cover) moderate trigger
  var sed_40_mod_trigger = 50	// t ha^-1 sediment (ravel) for mod severity (40% cover) moderate trigger
  var sed_60_mod_trigger = 40	// t ha^-1 sediment (ravel) for low severity (60% cover) moderate trigger

  var sed_20_high_trigger = 70	// t ha^-1 sediment (ravel) for high severity (20% cover) high trigger
  var sed_40_high_trigger = 60	// t ha^-1 sediment (ravel) for mod severity (40% cover) high trigger
  var sed_60_high_trigger = 50	// t ha^-1 sediment (ravel) for low severity (60% cover) high trigger

  var top_percent = .1
  var mid_percent = .8
  var toe_percent = .1
  var properties = 'menubar,scrollbars,resizable'

//=====================

  if (!isNumber(windowHeight)) {
    windowHeight = screen.availHeight*0.75
    properties = 'height='+windowHeight+','+properties
  }
//  else {if (newin != null) {windowHeight=newin.height}}
  if (!isNumber(windowWidth))  {
    windowWidth = screen.availWidth / 3
    if (windowWidth < 500) windowWidth = 500
    if (windowWidth > screen.availWidth) windowWidth = screen.availWidth
    properties = 'width='+windowWidth+','+properties
  }
  if (!isNumber(windowLeft)) {
   windowLeft = (screen.availWidth - windowWidth) - 20
   properties = 'left='+windowLeft+','+properties
  }
  if (newin && newin.closed) properties='left='+windowLeft+',width='+windowWidth+',height='+windowHeight+',menubar,scrollbars,resizable'
//  alert(properties)
  newin = window.open('','dry_ravel',properties)

  newin.document.open()

  if (newin && newin.open && !newin.closed) {
   newin.focus()
   newin.document.writeln('<HEAD><title>Dry ravel prediction<\/title><\/HEAD>')
   newin.document.writeln('<body bgcolor="ivory" onLoad="top.window.focus()">')
//=====================
//  alert('checking ravel')
  var whichsoil = window.document.ermit.SoilType.selectedIndex;
   // whichsoil == 0: clay loam
   // whichsoil == 2: silt loam
   // whichsoil == 1: sandy loam
   // whichsoil == 4: loam
//  alert(window.document.ermit.SoilType[whichsoil].text)
  rfg = window.document.ermit.rfg.value

//  alert('Rock fragment: ' + rfg + '%')
  for (var i = 0; i < 3; i++) {
    if (document.ermit.severity[i].checked) {
      var severity = document.ermit.severity[i].value
      break
    }
  }
//  alert('Severity: ' + severity)
  theta_top = window.document.ermit.top_slope.value
  theta_mid = window.document.ermit.avg_slope.value
  theta_toe = window.document.ermit.toe_slope.value
 
  if (whichsoil == 2 && rfg > rfg_crit) {

    if (severity == 'High')
	{sed_no_trigger = sed_20_no_trigger;
	 sed_low_trigger = sed_20_low_trigger;
	 sed_mod_trigger = sed_20_mod_trigger;
	 sed_high_trigger = sed_20_high_trigger}
    if (severity == 'Moderate')
	{sed_no_trigger = sed_40_no_trigger;
	 sed_low_trigger = sed_40_low_trigger;
	 sed_mod_trigger = sed_40_mod_trigger;
	 sed_high_trigger = sed_40_high_trigger}
    if (severity == 'Low')
	{sed_no_trigger = sed_60_no_trigger;
	 sed_low_trigger = sed_60_low_trigger;
	 sed_mod_trigger = sed_60_mod_trigger;
	 sed_high_trigger = sed_60_high_trigger}

	// top
//    alert('Checking top portion of slope')
    if (theta_top > theta_crit) {	// potential ravel
      sed_no_trigger_top = sed_no_trigger * top_percent
      sed_low_trigger_top = sed_low_trigger * top_percent
      sed_mod_trigger_top = sed_mod_trigger * top_percent
      sed_high_trigger_top = sed_high_trigger * top_percent
      top_ravel = true
//      alert('Ravel detected for top portion')
    }
    else {
      sed_no_trigger_top = 0
      sed_low_trigger_top = 0
      sed_mod_trigger_top = 0
      sed_high_trigger_top = 0
      top_ravel = false
//      alert('No ravel detected for top portion')
    }
	// mid
//    alert('Checking middle portion of slope')
    if (theta_mid > theta_crit) {	// potential ravel
      sed_no_trigger_mid = sed_no_trigger * mid_percent
      sed_low_trigger_mid = sed_low_trigger * mid_percent
      sed_mod_trigger_mid = sed_mod_trigger * mid_percent
      sed_high_trigger_mid = sed_high_trigger * mid_percent
      mid_ravel = true
//      alert('Ravel detected for middle portion')
    }
    else {
      sed_no_trigger_mid = 0
      sed_low_trigger_mid = 0
      sed_mod_trigger_mid = 0
      sed_high_trigger_mid = 0
      mid_ravel = false
//      alert('No ravel detected for middle portion')
    }
	// toe
//    alert('Checking toe portion of slope')
    if (theta_toe > theta_crit) {	// potential ravel
      sed_no_trigger_toe = sed_no_trigger * toe_percent
      sed_low_trigger_toe = sed_low_trigger * toe_percent
      sed_mod_trigger_toe = sed_mod_trigger * toe_percent
      sed_high_trigger_toe = sed_high_trigger * toe_percent
      toe_ravel = true
//      alert('Ravel detected for toe portion:')
    }
    else {
      sed_no_trigger_toe = 0
      sed_low_trigger_toe = 0
      sed_mod_trigger_toe = 0
      sed_high_trigger_toe = 0
      toe_ravel = false
//      alert('No ravel detected for toe portion')
    }

  sed_no_trigger_transported = sed_no_trigger_top + sed_no_trigger_mid + sed_no_trigger_toe
  sed_low_trigger_transported = sed_low_trigger_top + sed_low_trigger_mid + sed_low_trigger_toe
  sed_mod_trigger_transported = sed_mod_trigger_top + sed_mod_trigger_mid + sed_mod_trigger_toe
  sed_high_trigger_transported = sed_high_trigger_top + sed_high_trigger_mid + sed_high_trigger_toe

//  alert('No trigger: sediment transported = ' + sed_no_trigger_transported + ' t/ha')
//  alert('Low trigger: sediment transported = ' + sed_low_trigger_transported + ' t/ha')
//  alert('Moderate trigger: sediment transported = ' + sed_mod_trigger_transported + ' t/ha')
//  alert('High trigger: sediment transported = ' + sed_high_trigger_transported + ' t/ha')

//  if (top_ravel && !mid_ravel) {alert('Ravel from top portion deposited on middle portion')}
//  if (mid_ravel && !toe_ravel) {alert('Ravel from middle portion deposited on toe')}
//  if (toe_ravel) {alert('Sediment will be delivered off-site')}

    sed_no_trigger_delivered = 0
    sed_low_trigger_delivered = 0
    sed_mod_trigger_delivered = 0
    sed_high_trigger_delivered = 0

  if (toe_ravel && mid_ravel && top_ravel) {
    sed_no_trigger_delivered = sed_no_trigger_top + sed_no_trigger_mid + sed_no_trigger_toe
    sed_low_trigger_delivered = sed_low_trigger_top + sed_low_trigger_mid + sed_low_trigger_toe
    sed_mod_trigger_delivered = sed_mod_trigger_top + sed_mod_trigger_mid + sed_mod_trigger_toe
    sed_high_trigger_delivered = sed_high_trigger_top + sed_high_trigger_mid + sed_high_trigger_toe
  }
  if (toe_ravel && mid_ravel && !top_ravel) {
    sed_no_trigger_delivered = sed_no_trigger_mid + sed_no_trigger_toe
    sed_low_trigger_delivered = sed_low_trigger_mid + sed_low_trigger_toe
    sed_mod_trigger_delivered = sed_mod_trigger_mid + sed_mod_trigger_toe
    sed_high_trigger_delivered = sed_high_trigger_mid + sed_high_trigger_toe
  }
  if (toe_ravel && !mid_ravel) {
    sed_no_trigger_delivered = sed_no_trigger_toe
    sed_low_trigger_delivered = sed_low_trigger_toe
    sed_mod_trigger_delivered = sed_mod_trigger_toe
    sed_high_trigger_delivered = sed_high_trigger_toe
  }

//  alert('No trigger: sediment delivered = ' + sed_no_trigger_delivered + ' t/ha')
//  alert('Low trigger: sediment delivered = ' + sed_low_trigger_delivered + ' t/ha')
//  alert('Moderate trigger: sediment delivered = ' + sed_mod_trigger_delivered + ' t/ha')
//  alert('High trigger: sediment delivered = ' + sed_high_trigger_delivered + ' t/ha')
//=================
  newin.document.writeln('<center>')
    newin.document.writeln(' <h3>&quot;Ravel&quot;<br>Dry Ravel Estimator</h3>')
    newin.document.writeln(' <p>')
    newin.document.writeln(' <table border=1>')
    newin.document.writeln('  <tr><td align="right">')
    newin.document.writeln('    Soil texture:<td>' + window.document.ermit.SoilType[whichsoil].text + '<\/td><\/tr>')
    newin.document.writeln('  <tr><td align="right">')
    newin.document.writeln('    Rock fragment:<td> ' + rfg + '%<\/td><\/tr>')
    newin.document.writeln('  <tr><td align="right">')
    newin.document.writeln('    Top gradient:<td>' + theta_top + '%<\/td><\/tr>')
    newin.document.writeln('  <tr><td align="right">')
    newin.document.writeln('    Middle gradient:<td>' + theta_mid + '%<\/td><\/tr>')
    newin.document.writeln('  <tr><td align="right">')
    newin.document.writeln('    Toe gradient:<td>' + theta_toe + '%<\/td><\/tr>')
    newin.document.writeln('  <tr><td align="right">')
    newin.document.writeln('    Fire severity:<td>' + severity + '<\/td><\/tr>')
    newin.document.writeln('  <\/table>')
    newin.document.writeln(' <p>')
  newin.document.writeln('Given the proper climate:')
  newin.document.writeln(' <p>')
  if (top_ravel) {
    newin.document.writeln('<font color="red">Ravel detected for top portion<\/font><br>')
  }
  else {
    newin.document.writeln('<font color="green">No ravel detected for top portion<\/font><br>')
  }
  if (mid_ravel) {
    newin.document.writeln('<font color="red">Ravel detected for middle portion<\/font><br>')
  }
  else {
    newin.document.writeln('<font color="green">No ravel detected for middle portion<\/font><br>')
  }
  if (toe_ravel) {
    newin.document.writeln('<font color="red">Ravel detected for toe portion<\/font><br>')
  }
  else {
    newin.document.writeln('<font color="green">No ravel detected for toe portion<\/font><br>')
  }
  if (top_ravel && !mid_ravel) {newin.document.writeln('Ravel from top portion deposited on middle portion<br>')}
  if (mid_ravel && !toe_ravel) {newin.document.writeln('Ravel from middle portion deposited on toe<br>')}
  if (toe_ravel) {newin.document.writeln('<font color="red">Sediment will be delivered off-site<\/font><br>')}
  newin.document.writeln('<p>')
  newin.document.writeln('<font color="purple">NOTE: The following figures are made up.<\/font>')
  newin.document.writeln('<p>')
  newin.document.writeln('<table border=1 cellpadding=5>')
  newin.document.writeln(' <tr>')
  newin.document.writeln('  <th bgcolor="85d2f2">Trigger<br>level<br></th>')
  newin.document.writeln('  <th bgcolor="85d2f2">Sediment<br> transported<br>(t ha<sup>-1</sup>)</th>')
  newin.document.writeln('  <th bgcolor="85d2f2">Sediment<br> delivered off-site<br>(t ha<sup>-1</sup>)</th>')
  newin.document.writeln(' </tr>')
  newin.document.writeln(' <tr>')
  newin.document.writeln('  <th bgcolor="85d2f2">None</th>')
  newin.document.writeln('  <th>' + sed_no_trigger_transported+'</th>')
  newin.document.writeln('  <th>' + sed_no_trigger_delivered+'</th>')
  newin.document.writeln(' </tr>')
  newin.document.writeln(' <tr>')
  newin.document.writeln('  <th bgcolor="85d2f2">Low</th>')
  newin.document.writeln('  <th>' + sed_low_trigger_transported+'</th>')
  newin.document.writeln('  <th>' + sed_low_trigger_delivered+'</th>')
  newin.document.writeln(' </tr>')
  newin.document.writeln(' <tr>')
  newin.document.writeln('  <th bgcolor="85d2f2">Moderate</th>')
  newin.document.writeln('  <th>' + sed_mod_trigger_transported+'</th>')
  newin.document.writeln('  <th>' + sed_mod_trigger_delivered+'</th>')
  newin.document.writeln(' </tr>')
  newin.document.writeln(' <tr>')
  newin.document.writeln('  <th bgcolor="85d2f2">High</th>')
  newin.document.writeln('  <th>' + sed_high_trigger_transported +'</th>')
  newin.document.writeln('  <th>' + sed_high_trigger_delivered+'</th>')
  newin.document.writeln(' </tr>')
  newin.document.writeln('</table>')
  newin.document.writeln('<p>(<a href="javascript:self.print()">print me</a>)')
  newin.document.writeln('&nbsp;&nbsp;&nbsp;(<a href="javascript:self.close()">close me</a>)')
  newin.document.writeln('</center>')
//=================
  }
  else {
    newin.document.writeln(' <center>')
    newin.document.writeln(' <h3>&quot;Ravel&quot;<br>Dry Ravel Estimator</h3>')
    newin.document.writeln(' <p>')
    newin.document.writeln(' <table border=1>')
    newin.document.writeln('  <tr><td align="right">')
    newin.document.writeln('    Soil texture:<td>' + window.document.ermit.SoilType[whichsoil].text + '<\/td><\/tr>')
    newin.document.writeln('  <tr><td align="right">')
    newin.document.writeln('    Rock fragment:<td> ' + rfg + '%<\/td><\/tr>')
    newin.document.writeln('  <tr><td align="right">')
    newin.document.writeln('    Top gradient:<td>' + theta_top + '%<\/td><\/tr>')
    newin.document.writeln('  <tr><td align="right">')
    newin.document.writeln('    Middle gradient:<td>' + theta_mid + '%<\/td><\/tr>')
    newin.document.writeln('  <tr><td align="right">')
    newin.document.writeln('    Toe gradient:<td>' + theta_toe + '%<\/td><\/tr>')
    newin.document.writeln('  <tr><td align="right">')
    newin.document.writeln('    Fire severity:<td>' + severity + '<\/td><\/tr>')
    newin.document.writeln('  <\/table>')
    newin.document.writeln('<h3>No ravel</h3>')
    newin.document.writeln('<p>(<a href="javascript:self.close()">close me</a>)')
    newin.document.writeln('</center>')
  }

  newin.document.writeln('</body>')
  newin.document.writeln('</html>')
  newin.document.close()
 }
  return true

}

// ############################################ explain (what)

function explain (what) {

//  alert(what)

  helpwindowHeight = screen.availHeight*0.25
  helpwindowWidth = screen.availWidth / 3
  if (helpwindowWidth < 500) helpwindowWidth = 500
  if (helpwindowWidth > screen.availWidth) helpwindowWidth = screen.availWidth
  helpproperties='width='+helpwindowWidth+',height='+helpwindowHeight+',menubar,scrollbars,resizable'
//  alert(helpproperties)

  newhelpwin = window.open('','help',helpproperties)
  newhelpwin.document.open()
  if (newhelpwin && newhelpwin.open && !newhelpwin.closed) {
   newhelpwin.focus()
   newhelpwin.document.writeln('<HEAD><title>Dry ravel prediction explanations<\/title><\/HEAD>')
   newhelpwin.document.writeln('<body bgcolor="ivory" onLoad="top.window.focus()">')

   if (what == 'soil_texture') {
     newhelpwin.document.writeln('<h3 align="center">Dry Ravel<br>Soil Texture<\/h3>')
     newhelpwin.document.writeln("'Sandy loam' is susceptible to dry ravel.")
   }
   if (what == 'rock_content') {
     newhelpwin.document.writeln('<h3 align="center">Dry Ravel<br>Rock Content<\/h3>')
     newhelpwin.document.writeln('Rock content must exceed a critical value (to be determined)')
     newhelpwin.document.writeln('for a slope to be susceptible to dry ravel.')
   }
   if (what == 'vegetation_type') {
     newhelpwin.document.writeln('<h3 align="center">Dry Ravel<br>Vegetation Type<\/h3>')
     newhelpwin.document.writeln('We are not currently distinguishing between vegetation types.')
     newhelpwin.document.writeln('')
   }
   if (what == 'hillslope_gradient') {
     newhelpwin.document.writeln('<h3 align="center">Dry Ravel<br>Hillslope Gradient<\/h3>')
     newhelpwin.document.writeln('We break the hillslope into three segments and look at the')
     newhelpwin.document.writeln('potential for ravel on each of the segments from top to bottom.')
     newhelpwin.document.writeln('Each segment is susceptible to ravel if it is steeper than a critical steepness.')
     newhelpwin.document.writeln('If a segment is flatter than the critical steepness, then it will catch any')
     newhelpwin.document.writeln('material raveled from the segment above.')
   }
   if (what == 'hillslope_length') {
     newhelpwin.document.writeln('<h3 align="center">Dry Ravel<br>Hillslope Length<\/h3>')
     newhelpwin.document.writeln('Unused at present.')
     newhelpwin.document.writeln('')
   }
   if (what == 'fire_severity') {
     newhelpwin.document.writeln('<h3 align="center">Dry Ravel<br>Fire Severity<\/h3>')
     newhelpwin.document.writeln('')
     newhelpwin.document.writeln('')
   }
  
   newhelpwin.document.writeln('<p>')
   newhelpwin.document.writeln('<center>')
   newhelpwin.document.writeln('&nbsp;&nbsp;&nbsp;(<a href="javascript:self.close()">close me</a>)')
   newhelpwin.document.writeln('</center>')
   newhelpwin.document.writeln('</body>')
   newhelpwin.document.writeln('</html>')
   newhelpwin.document.close()
  }
}

// end DRY RAVEL CODE
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
       <h2>
           <font color=red>E</font>rosion
           <font color=red>R</font>ehabilitation
           <font color=red>M</font>anagement
           <font color=red>T</font>ool</h2>
       <hr>
      <td>
       <A HREF="http://',$wepphost,'/fswepp/docs/ermitdoc.html" target="docs">
       <IMG src="http://',$wepphost,'/fswepp/images/epage.gif"
        align="right" alt="Read the documentation" border=0></a>
    </table>
  <center>
  <FORM name="ermit" method="post" ACTION="http://',$wepphost,'/cgi-bin/fswepp/ermit/erm.pl">
  me <input type="text" size="1" name="me" value="',$me,'">
  units <input type="text" size="1" name="units" value="',$units,'">
  <TABLE border="1">
';
print <<'theEnd';
     <TR align="top"><TD align="center" bgcolor="85d2d2">
       <B>   Climate</b>
       <br>[ <a href="JavaScript:submitme('Describe Climate')"
             onMouseOver="window.status='Describe climate';return true"
             onMouseOut="window.status='Forest Service ERMiT'; return true">
             Describe</a> ]
           [ <a href="/fswepp/wd/clisymbols.html" target="_popup"
             onMouseOver="window.status='Explain symbols (new window)';return true"
             onMouseOut="window.status='Forest Service ERMiT';return true">
             Explain</a> ]
       <th width=20 rowspan=3><br>
  <TD align="center" bgcolor="85d2d2">
    <B> Soil Texture</b>
    <br>[ <a href="JavaScript:submitme('Describe Soil')"
           onMouseOver="window.status='Describe soil';return true"
           onMouseOut="window.status='Forest Service ERMiT'; return true">
           Describe</a> ]
        [ <a href="/fswepp/docs/distweppdoc.html#texture" target="_popup"
           onMouseOver="window.status='Explain treatment (new window)';return true"
           onMouseOut="window.status='Forest Service ERMiT'; return true">
           Explain</a> ]
    <TR align=top>
       <TD align="center"><SELECT NAME="Climate" SIZE="5">
theEnd

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

#################
print <<'theEnd';
       </SELECT>
       <TD align="center">
       <SELECT NAME="SoilType" SIZE="4"
         onChange="showTexture()"
         onBlur="blankStatus()">
         <OPTION VALUE="clay" selected>clay loam
         <OPTION VALUE="silt">silt loam
         <OPTION VALUE="sand">sandy loam
         <OPTION VALUE="loam">loam
       </SELECT>
      <tr>
       <th>
        achtung <input type="text" name="achtung" value="Run WEPP">
        <input type="SUBMIT" name="actionc" value="Custom Climate">
       </th>
       <th>Rock content
        <input type="text" name="rfg" size="6" value=20> <b>%</b>
       </th>
    </table>
   <p>
    <table border=2>
     <tr>
      <th bgcolor=85d2d2>Vegetation type <br>
       [
       <a href="/fswepp/docs/ermitdoc.html#treatment" target="_popup"
             onMouseOver="window.status='Explain treatment (new window)';return true"
             onMouseOut="window.status='Forest Service ERMiT'; return true">
             Explain</a> ]
      </th>
      <th bgcolor=85d2d2>Hillslope gradient (%) <br>
       [
       <a href="/fswepp/docs/ermitdoc.html#topography" target="_popup"
             onMouseOver="window.status='Explain gradient (new window)';return true"
             onMouseOut="window.status='Forest Service ERMiT'; return true">
             Explain</a> ]
      </th>
      <th bgcolor=85d2d2>Hillslope horizontal<br>length (m)
      </th>
      <th bgcolor=85d2d2>Fire severity class<br>
       [
       <a href="severity.html" target="_popup"
             onMouseOver="window.status='Explain fire severity rank (new window)';return true"
             onMouseOut="window.status='Forest Service ERMiTP'; return true">
             Explain</a> ]
      </th>
     </tr>
     <tr>
      <td align="center">
        <select name="vegetation" size="4" valign="top"
          onclick="javascript:bushes();return true"
          onmouseout="window.status='Forest Service ERMiT'; return true">    
 <!--  onfocus="javascript:alert('hoop')"> -->
        <option value="forest" selected="selected"> Forest</option>
        <option value="range"> Range</option>
        <option value="chap"> Chaparral</option>
        </select>
      </td>
      <td>
        <input type="hidden" name="top_slope" value="0"> <!-- <b>Top</b> -->
        <input type="text" size="5" name="avg_slope" value="30"> <b>Average</b><br>
        <input type="text" size="5" name="toe_slope" value="5"> <b>Toe</b>
       </td>
      <td><input type="text" size="5" name="length"  value="100">
      </td>
      <td><input type="radio" name="severity" value="High" checked="checked"> <b>High</b><br>
          <input type="radio" name="severity" value="Moderate"> <b>Moderate</b><br>
          <input type="radio" name="severity" value="Low"> <b>Low</b><br>
      </td>
     </tr>
     <tr>
      <td colspan="4">
        <b>Range/chaparral prefire community description</b><br>
          <input name="pct_shrub" size="8" type="text" onblur="javascvript:shrub()"><b> % shrub &nbsp;&nbsp;</b>   <!-- onchange calc others -->
          <input name="pct_grass" size="8" type="text" onblur="javascvript:grass()"><b> % grass &nbsp;&nbsp;</b>   <!-- onchange calc others -->
          <input name="pct_bare" size="8" type="text" onblur="javascvript:bare()">  % bare <!-- no change --> </td>
     </tr>

  </TABLE>
  <BR>
   climate_name <input type="text" name="climate_name">
  <BR>
    </b>
    <p>
     Units <INPUT TYPE="text" NAME="Units" VALUE="m">
     <INPUT TYPE="SUBMIT" name="actionw" VALUE="Run ERMiT"
       onClick='RunningMsg(this.form.actionw,"Running ERMiT..."); this.form.achtung.value="Run WEPP"'>
     <INPUT type="submit" name="ravel" value="Check dry ravel"
           onClick="javascript:ravelcheck(); return false;">
<!--       onCLick="javascript:void(ravel())"> -->
     <BR>
   </center>
  </FORM>
  <P>
  <HR>
theEnd
print '
<a href="http://',$wepphost,'/fswepp/comments.html" ';
if ($wepphost eq 'localhost') {print 'onClick="return confirm(\'You must be connected to the Internet to e-mail comments. Shall I try?\')"'};                                  
print '>                                                              
<img src="http://',$wepphost,'/fswepp/images/epaemail.gif" align="right" border=0>
</a>
Interface v. 
 <a href="http://',$wepphost,'/fswepp/history/wdver.html"> ',$version,'</a>
 (for review only) by David Hall, 
Project Leader
Bill Elliot<BR>
USDA Forest Service, Rocky Mountain Research Station, Moscow, ID
83843<br>';
  print "$remote_host &ndash; $remote_address
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
