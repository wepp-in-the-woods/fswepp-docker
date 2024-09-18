#!/usr/bin/perl

#
#  Disturbed WEPP input screen
#

#  weppdist.pl -- input screen for Disturbed WEPP

#  2009.02.23 DE Add radio button for WEPP version
#  2007.04.04 DEH Add Description user input
#  2004.12.20 DEH Modify "checkeverything" -- Error: 'this.form.climyears' is null or not an object (IE?)
#						'this.form' has no properties (Mozilla)
#  2004.10.13 DEH Add trailing '\\' to $working for platform eq 'pc'
#  2004.02.18  DEH Remove Extended Output checkbox
#  2004.01.05  DEH Adjust run counter message
#  2003.12.03  DEH Add metric and non-metric limits on input (require adj)
#  2003.11.28  DEH Add calls to checkRange (function already there)
#                  "Explain treatment" to "Explain soil texture"
#                  "Explain Cover" to "Explain cover"
#                  "Explain Rock" to "Explain rock content"
#  2002.11.14  DEH Patch for IP blocking
#  2002.11.04  DEH Report remote_host and remote_address
#  2002.01.08  DEH Removed errant return link of "dindex.html" & wrap pbs
#  2001.10.10  SDA Removed AREA input, added ROCK FRAGMENT inputs
#  2001.04.24  DEH Changed upper, lower treatment display 4 to 8
#  2001.04.24  DEH [forest's 2000.10.13]
#              DEH added more EXPLAIN links; into documentation
#      to do:      move climate explanation into documentation
#      to do:      add graphic for slope explanation           
#  2001.04.10  DEH add checkYears to # yrs (from WEPP:Road)
#		add call to checkYears
#		and call to existing showRange
#		add minyears, maxyears, defyears
#		add isNumber (existing call in CheckRange)
#  2001.03.05  DEH fix $user_ID
#  2000.12.05  DEH move documentation target to separate "docs" window
#  2000.11.27  Update contact e-mails (Hall & Elliot)
#  2000.09.15a Add capability to read PUBLIC (!) climates [03/02/2001]
#  2000.09.15  Filter on $user_ID again for personal climates
#  2000.08.22  Switched from [glob] to DIY climate file name extraction
#                following lead in wepproad.pl
#              Updated personal climate search a'la wepproad.pl

    $version = '2009.02.23';
#    $version = '2007.04.04';
#    $version = '2004.12.20';

#  usage:
#    action = "weppdist.pl"
#  parameters:
#    units:             # unit scheme (ft|m)
#    me
#  reads environment variables:
#       HTTP_COOKIE
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
#    /cgi-bin/fswepp/wr/wr.pl
#    /cgi-bin/fswepp/wr/logstuff.pl
#  popup links:
#    /fswepp/wr/wrwidths.html
#    /fswepp/wr/rddesign.html

#  FSWEPP, USDA Forest Service, Rocky Mountain Research Station, 
#  Soil & Water Engineering
#  Science by Bill Elliot et alia
#  Code by David Hall 

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
<title>Disturbed WEPP</title>
  <META http-equiv="Content-Type" content="text/html; charset=utf-8">
  <META NAME="Name" CONTENT="Disturbed WEPP">
  <META NAME="Brief Description" CONTENT="Disturbed WEPP, a component of FS WEPP, predicts erosion from rangeland, forestland, and forest skid trails. Disturbed WEPP allows users to easily describe numerous disturbed forest and rangeland erosion conditions. The interface presents the probability of a given level of erosion occurring the year following a disturbance.">
  <META NAME="Status" CONTENT="Released 2000">
  <META NAME="Updates" CONTENT="Ongoing, online">
  <META NAME="Inputs" CONTENT="Climate station; soil texture; upper and lower element treatment, gradient, horizontal length, cover, and rock content">
  <META NAME="Outputs" CONTENT="Annual average precipitation; runoff from rainfall; runoff from snowmelt or winter rainstorm; upland erosion rate; sediment leaving profile; return period analysis of precipitation, runoff, erosion, and sediment; probabilities of occurrence first year following disturbance of runoff, erosion, and sediment delivery">
  <META NAME="Suggested user" CONTENT="">
  <META NAME="Suggested use" CONTENT="">
  <META NAME="Keywords" CONTENT="">
  <META NAME="Contributors" CONTENT="USDA Forest Service, Rocky Mountain Research Station, Moscow, ID: Bill Elliot and David Hall">
  <META NAME="Source" content="Run online at https://forest.moscowfsl.wsu.edu/fswepp/">

  <!--<bgsound src="journey.wav">-->
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

function popuphistory() {
url = '';
height=500;
width=660;
popupwindow = window.open(url,'popupwindow','toolbar=no,location=no,status=no,directories=no,menubar=no,scrollbars=yes,resizable=yes,width='+width+',height='+height);

popupwindow.document.writeln('<html>')
popupwindow.document.writeln(' <head>')
popupwindow.document.writeln('  <title>Disturbed WEPP Input Screen version history</title>')
popupwindow.document.writeln(' </head>')
popupwindow.document.writeln(' <body bgcolor=white>')
popupwindow.document.writeln('  <font face="arial, helvetica, sans serif">')
popupwindow.document.writeln('  <center>')
popupwindow.document.writeln('   <h3>Disturbed WEPP Input Screen Version History</h3>')

popupwindow.document.writeln('   <p>')
popupwindow.document.writeln('   <table border=0 cellpadding=10>')
popupwindow.document.writeln('    <tr>')
popupwindow.document.writeln('     <th bgcolor=85d2d2>Version</th>')
popupwindow.document.writeln('     <th bgcolor=85d2d2>Comments</th>')
popupwindow.document.writeln('    </tr>')

popupwindow.document.writeln('    <tr>')
popupwindow.document.writeln('     <th valign="top" bgcolor="85d2d2">2009.02.23</th>')
popupwindow.document.writeln('     <td>Add WEPP version selection</td>')
popupwindow.document.writeln('    </tr>')

popupwindow.document.writeln('    <tr>')
popupwindow.document.writeln('     <th valign="top" bgcolor="85d2d2">2007.04.04</th>')
popupwindow.document.writeln('     <td>Add rund description input field</td>')
popupwindow.document.writeln('    </tr>')

popupwindow.document.writeln('    <tr>')
popupwindow.document.writeln('     <th valign="top" bgcolor="85d2d2">2004.02.18</th>')
popupwindow.document.writeln('     <td>Remove Extended Output checkbox</td>')
popupwindow.document.writeln('    </tr>')

popupwindow.document.writeln('    <tr>')
popupwindow.document.writeln('     <th valign="top" bgcolor="85d2d2">2004.01.05</th>')
popupwindow.document.writeln('     <td>Adjust run counter message</td>')
popupwindow.document.writeln('    </tr>')

popupwindow.document.writeln('    <tr>')
popupwindow.document.writeln('     <th valign="top" bgcolor="85d2d2">2003.12.03</th>')
popupwindow.document.writeln('     <td>Add metric and non-metric limits on input (require adjustment)</td>')
popupwindow.document.writeln('    </tr>')

popupwindow.document.writeln('    <tr>')
popupwindow.document.writeln('     <th valign="top" bgcolor="85d2d2">2003.11.28</th>')
popupwindow.document.writeln('     <td>Add calls to checkRange (function already there)<br>Change wording</td>')
popupwindow.document.writeln('    </tr>')

popupwindow.document.writeln('    <tr>')
popupwindow.document.writeln('     <th valign="top" bgcolor="85d2d2">2002.11.14</th>')
popupwindow.document.writeln('     <td>Work around clumped IP addresses for RMRS and other sites</td>')
popupwindow.document.writeln('    </tr>')

popupwindow.document.writeln('    <tr>')
popupwindow.document.writeln('     <th valign="top" bgcolor="85d2d2">2001.10.10</th>')
popupwindow.document.writeln('     <td>Add "rock content" input field for upper and lower element.<br>Remove area input field.</td>')
popupwindow.document.writeln('    </tr>')

popupwindow.document.writeln('    <tr>')
popupwindow.document.writeln('     <th valign="top" bgcolor="85d2d2">2001.04.10</th>')
popupwindow.document.writeln('     <td>Check number-of-years-to-simulate entry for validity and range</td>')
popupwindow.document.writeln('    </tr>')

popupwindow.document.writeln('    <tr>')
popupwindow.document.writeln('     <th valign="top" bgcolor="85d2d2">2001.03.05</th>')
popupwindow.document.writeln('     <td>Adjust method to keep track of climates for multiple users on one machine</td>')
popupwindow.document.writeln('    </tr>')

popupwindow.document.writeln('    <tr>')
popupwindow.document.writeln('     <th valign="top" bgcolor="85d2d2">2000.10.13</th>')
popupwindow.document.writeln('     <td>Add explanation links, which lead to documentation<br>Move climate file symbols into documentation<br>Add graphic for slope explanation</td>')
popupwindow.document.writeln('    </tr>')

popupwindow.document.writeln('    <tr>')
popupwindow.document.writeln('     <th valign="top" bgcolor="85d2d2">2000.09.15</th>')
popupwindow.document.writeln('     <td>Modify method for finding personal climates<br>Add capability to read "public" ("!") climates</td>')
popupwindow.document.writeln('    </tr>')

popupwindow.document.writeln('    <tr>')
popupwindow.document.writeln('     <th valign="top" bgcolor="85d2d2">2000.08.22</th>')
popupwindow.document.writeln('     <td>Change method of finding climate files dynamically</td>')
popupwindow.document.writeln('    </tr>')

popupwindow.document.writeln('    <tr>')
popupwindow.document.writeln('     <th valign="top" bgcolor="85d2d2">2000.02.10</th>')
popupwindow.document.writeln('     <td>Release for review.</td>')
popupwindow.document.writeln('    </tr>')

popupwindow.document.writeln('   </table>')
popupwindow.document.writeln('   <p>')
popupwindow.document.writeln('  </font>')
popupwindow.document.writeln('  </center>')
popupwindow.document.writeln(' </body>')
popupwindow.document.writeln('</html>')
popupwindow.document.close()
popupwindow.focus()
}

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

    default_pcover = new MakeArray(7);
//    default_pcover[0] = 2;	// forest road
    default_pcover[7] = 10;	// skid trail
//    default_pcover[6] = 15;	// high fire       DEH 06/07/2000
//    default_pcover[5] = 50;	// low fire        DEH 06/07/2000
    default_pcover[6] = 45;	// high fire
    default_pcover[5] = 85;	// low fire
    default_pcover[4] = 40;	// short grass
    default_pcover[3] = 60;	// tall grass
    default_pcover[2] = 80;	// shrub
    default_pcover[1] = 100;	// trees 5 year
    default_pcover[0] = 100;	// trees 20 year
//   window.document.weppdist.ofe1.selectedIndex = 0;
//   window.document.weppdist.ofe2.selectedIndex = 7;
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

  function pcover2() {        // change ofe2 pcover to default for selected
    var which = window.document.weppdist.LowSlopeType.selectedIndex;
    window.document.weppdist.ofe2_pcover.value=default_pcover[which];
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
     } else {
         obj.value=def
         alert("Invalid entry for " + thistext + "!")
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
         alert("Invalid entry " + obj.value + " for number of years! Using " + minyear)
         obj.value=minyear
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
  var which = window.document.weppdist.SlopeType.selectedIndex;
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
  var which = window.document.weppdist.SoilType.selectedIndex;
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
print '<BODY bgcolor="white"
       link="#555555" vlink="#555555" onLoad="StartUp()">
  <font face="Arial, Geneva, Helvetica">
  <table width=100% border=0>
    <tr><td> 
       <a href="https://',$wepphost,'/fswepp/">
       <IMG src="https://',$wepphost,'/fswepp/images/fsweppic2.jpg" width=75 height=75
       align="left" alt="Back to FS WEPP menu" border=0></a>
    <td align=center>
       <hr>
       <h2>Disturbed WEPP</h2>
       <hr>
    <td>
       <A HREF="https://',$wepphost,'/fswepp/docs/distweppdoc.html" target="docs">
       <IMG src="https://',$wepphost,'/fswepp/images/epage.gif"
        align="right" alt="Read the documentation" border=0></a>
    </table>
  <center>
  <FORM name="weppdist" method="post" ACTION="https://',$wepphost,'/cgi-bin/fswepp/wd/wd.pl">
  <input type="hidden" size="1" name="me" value="',$me,'">
  <input type="hidden" size="1" name="units" value="',$units,'">
  <TABLE border="1">
';
print <<'theEnd';
     <TR align="top"><TD align="center" bgcolor="85d2d2">
       <B>   Climate</b>
       <br>[ <a href="JavaScript:submitme('Describe Climate')"
             onMouseOver="window.status='Describe climate';return true"
             onMouseOut="window.status='Forest Service Disturbed WEPP'; return true">
             Describe</a> ]
           [ <a href="/fswepp/wd/clisymbols.html" target="_popup"
             onMouseOver="window.status='Explain symbols (new window)';return true"
             onMouseOut="window.status='Forest Service Disturbed WEPP';return true">
             Explain</a> ]
       <th width=20 rowspan=3><br>
  <TD align="center" bgcolor="85d2d2">
    <B> Soil Texture</b>
    <br>[ <a href="JavaScript:submitme('Describe Soil')"
           onMouseOver="window.status='Describe soil';return true"
           onMouseOut="window.status='Forest Service Disturbed WEPP'; return true">
           Describe</a> ]
        [ <a href="/fswepp/docs/distweppdoc.html#texture" target="_popup"
           onMouseOver="window.status='Explain soil texture (new window)';return true"
           onMouseOut="window.status='Forest Service Disturbed WEPP'; return true">
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
      <tr><td align=center>
      <input type="hidden" name="achtung" value="Run WEPP">
      <input type="SUBMIT" name="actionc" value="Custom Climate">
    </table>
<p>
<table border=2>
<tr><th bgcolor=85d2d2>
  <font face="Arial, Geneva, Helvetica">Element
    <th bgcolor=85d2d2>
     <font face="Arial, Geneva, Helvetica">Treatment <br>
      [ <a href="/fswepp/docs/distweppdoc.html#treatment" target="_popup"
         onMouseOver="window.status='Explain treatment (new window)';return true"
         onMouseOut="window.status='Forest Service Disturbed WEPP';return true">
         Explain</a> ]
    <th bgcolor=85d2d2>
     <font face="Arial, Geneva, Helvetica">Gradient (%)<br>
      [ <a href="/fswepp/docs/distweppdoc.html#topography" target="_popup"
         onMouseOver="window.status='Explain gradient (new window)';return true"
         onMouseOut="window.status='Forest Service Disturbed WEPP';return true">
         Explain</a> ]

theEnd
print "    <th bgcolor=85d2d2><font face=\"Arial, Geneva, Helvetica\">Horizontal<br>Length ($units)
           <th bgcolor=85d2d2><font face=\"Arial, Geneva, Helvetica\">Cover (%)\n";
print <<'theEnd';
 <br> [ <a href="/fswepp/docs/distweppdoc.html#cover" target="_popup"
         onMouseOver="window.status='Explain cover (new window)';return true"
         onMouseOut="window.status='Forest Service Disturbed WEPP';return true">
         Explain</a> ]</font>
    <th bgcolor=85d2d2><font face="Arial, Geneva, Helvetica">Rock (%) <br>
      [ <a href="/fswepp/docs/distweppdoc.html#rock" target="_popup"
         onMouseOver="window.status='Explain rock content (new window)';return true"
         onMouseOut="window.status='Forest Service Disturbed WEPP';return true">
         Explain</a> ]</font>
  
   <tr>
    <th rowspan=2 bgcolor=85d2d2><font face="Arial, Geneva, Helvetica">Upper
    <TD rowspan=2>
    <SELECT NAME="UpSlopeType" SIZE="8" ALIGN="top" onChange="pcover1()";>
     <OPTION VALUE="tree20" selected> Twenty year old forest
     <OPTION VALUE="tree5"> Five year old forest
     <OPTION VALUE="shrub"> Shrubs
     <OPTION VALUE="tall"> Tall Grass
     <OPTION VALUE="short"> Short Grass
     <OPTION VALUE="low"> Low Severity Fire
     <OPTION VALUE="high"> High Severity Fire
     <OPTION VALUE="skid"> Skid trail
    </SELECT>
    <td><input type="text" size=5 name="ofe1_top_slope" value="0"
        onChange="checkRange(ofe1_top_slope,smin,smax,ofe1tsdef,sunit,'Slope')"
        onFocus="showRange(this.form,'Slope: ',smin,smax,sunit)"
        onBlur="blankStatus()">
    <td rowspan=2><input type="text" size=5 name="ofe1_length" value="50"
        onChange="checkRange(ofe1_length,lmin,lmax,ldef,lunit,'Upper element length')"
        onFocus="showRange(this.form,'Upper element length: ',lmin,lmax,lunit)"
        onBlur="blankStatus()">
    <td rowspan=2><input type="text" size=5 name="ofe1_pcover" value="100"
        onChange="checkRange(ofe1_pcover,pcmin,pcmax,pcdef,pcunit,'Percent cover')"
        onFocus="showRange(this.form,'Percent cover: ',pcmin,pcmax,pcunit)"
        onBlur="blankStatus()">
    <td rowspan=2><input type="text" size=5 name="ofe1_rock" value="20"
        onChange="checkRange(ofe1_rock,rmin,rmax,rdef,runit, 'Percent rock')"
        onFocus="showRange(this.form,'Percent rock: ',rmin,rmax,runit)"
        onBlur="blankStatus()">
   <tr>
    <td><input type="text" size=5 name="ofe1_mid_slope" value="30"
        onChange="checkRange(ofe1_mid_slope,smin,smax,ofe1msdef,sunit,'Slope')"
        onFocus="showRange(this.form,'Slope: ',smin,smax,sunit)"
        onBlur="blankStatus()">
   <tr>
    <th rowspan=2 bgcolor=85d2d2><font face="Arial, Geneva, Helvetica">Lower
    <TD rowspan=2>
    <SELECT NAME="LowSlopeType" SIZE="8" ALIGN="top" onChange="pcover2()";>
     <OPTION VALUE="tree20"> Twenty year old forest
     <OPTION VALUE="tree5" selected> Five year old forest
     <OPTION VALUE="shrub"> Shrubs
     <OPTION VALUE="tall"> Tall Grass
     <OPTION VALUE="short"> Short Grass
     <OPTION VALUE="low"> Low Severity Fire
     <OPTION VALUE="high"> High Severity Fire
     <OPTION VALUE="skid"> Skid trail
    </SELECT>
    <td><input type="text" size=5 name="ofe2_top_slope" value="30"
        onChange="checkRange(ofe2_top_slope,smin,smax,ofe2tsdef,sunit,'Slope')"
        onFocus="showRange(this.form,'Slope range: ',smin,smax,sunit)"
        onBlur="blankStatus()">
    <td rowspan=2><input type="text" size=5 name="ofe2_length" value="50"
        onChange="checkRange(ofe2_length,lmin,lmax,ldef,lunit,'Lower element length')"
        onFocus="showRange(this.form,'Lower element length: ',lmin,lmax,lunit)"
        onBlur="blankStatus()">
    <td rowspan=2><input type="text" size=5 name="ofe2_pcover" value="100"
        onChange="checkRange(ofe2_pcover,pcmin,pcmax,pcdef,pcunit,'Percent cover')"
        onFocus="showRange(this.form,'Percent cover: ',pcmin,pcmax,pcunit)"
        onBlur="blankStatus()">
    <td rowspan=2><input type="text" size=5 name="ofe2_rock" value="20"
        onChange="checkRange(ofe2_rock,rmin,rmax,rdef,runit,'Percent rock')"
        onFocus="showRange(this.form,'Percent rock: ',rmin,rmax,runit)"
        onBlur="blankStatus()">
   <tr><td><input type="text" size=5 name="ofe2_bot_slope" value="5"
        onChange="checkRange(ofe2_bot_slope,smin,smax,ofe2bsdef,sunit,'Slope')"
        onFocus="showRange(this.form,'Slope range: ',smin,smax,sunit)"
        onBlur="blankStatus()">
  </TABLE>

<BR>
   <input type=hidden name="climate_name">
<!-- .... Summary output...
<INPUT TYPE="CHECKBOX" NAME="Full" VALUE="1">Full output
<INPUT TYPE="CHECKBOX" NAME="Slope" VALUE="1">Slope file input -->
<B>Years to simulate:</B> <input type="text" size="3" name="climyears" value="30"
        onChange="checkYears(this.form.climyears)"
        onFocus="showRange(this.form,'Years to simulate: ',minyear, maxyear, '')"
        onBlur="blankStatus()">
<br>
<b>Description:</b> <input type = "text" name="description" value="" size=75>
<br>
<!--<INPUT TYPE="SUBMIT" name="actionw" VALUE="Run WEPP"
    onClick='RunningMsg(this.form.actionw,"Running..."); this.form.achtung.value="Run WEPP"'>
-->
<br>
<INPUT TYPE="HIDDEN" NAME="Units" VALUE="m">
<input type="SUBMIT" name="actionv" value="Calibrate vegetation"
       onClick='RunningMsg(this.form.actionv,"Calibrating vegetation..."); this.form.achtung.value="vegetation"'>
<INPUT TYPE="SUBMIT" name="actionw" VALUE="Run WEPP"
       onClick='checkeverything()'>
<font size=1>
  <input type=Radio name="weppversion" value="2000">WEPP 2000 |
  <input type=Radio name="weppversion" value="2008" checked><a href="/fswepp/weppver2008.html" target="weppver">WEPP 2008</a>
</font>
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
<a href="https://',$wepphost,'/fswepp/comments.html" ';
if ($wepphost eq 'localhost') {print 'onClick="return confirm(\'You must be connected to the Internet to e-mail comments. Shall I try?\')"'};                                  
print '>                                                              
<img src="https://',$wepphost,'/fswepp/images/epaemail.gif" align="right" border=0></a>
  Interface v. 
  <a href="javascript:popuphistory()">',$version,'</a>
  by
  David Hall, 
  Project Leader  Bill Elliot<BR>
  USDA Forest Service, Rocky Mountain Research Station, Moscow, ID<br>';
  $remote_host = $ENV{'REMOTE_HOST'};                          
  $remote_address = $ENV{'REMOTE_ADDR'};

  $wc  = `wc ../working/wd.log`;    
  @words = split " ", $wc;          
  $runs = @words[0];                

print "  $remote_host &ndash; $remote_address ($user_really) personality '<b>$me</b>'<br>
  <b>$runs</b> Disturbed WEPP runs since Jan 1, 2009;
  <b>18,970</b> runs in 2008.
  <!--  9,538 runs in 2007. -->
  <!-- 16,760 runs in 2006. -->
  <!-- 16,760 runs in 2006. -->
  <!-- 19,060 runs in 2005. -->
  <!-- 19,258 runs in 2004. -->
  <!-- 18,950 runs in 2003. -->
  <!-- 12,176 runs in 2002. -->
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
