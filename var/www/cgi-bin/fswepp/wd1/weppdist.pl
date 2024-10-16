#!/usr/bin/perl

use warnings;
use CGI;
use CGI qw(escapeHTML);

use MoscowFSL::FSWEPP::FsWeppUtils qw(get_user_id get_version get_units);
use MoscowFSL::FSWEPP::CligenUtils qw(GetClimates);

#
#  Disturbed WEPP input screen
#

my $version = get_version(__FILE__);
my ($units, $areaunits)   = get_units();
my $user_ID = get_user_id();

$working     = '../working/';                                 # DEH 08/22/2000
$logFile = '../working/' . $user_ID . '.log';
$custCli = '../working/' . $user_ID;                          # DEH 03/02/2001

my @climates = GetClimates($user_ID);

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
popupwindow.document.writeln('     <td>Add run description input field</td>')
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

print <<'theEnd';
    default_pcover = new MakeArray(7);
    default_pcover[7] = 10;	// skid trail
    default_pcover[6] = 45;	// high fire
    default_pcover[5] = 85;	// low fire
    default_pcover[4] = 40;	// short grass
    default_pcover[3] = 60;	// tall grass
    default_pcover[2] = 80;	// shrub
    default_pcover[1] = 100;	// trees 5 year
    default_pcover[0] = 100;	// trees 20 year
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
    window.document.weppdist.climate_name.value=climate_name[which];
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
       <a href="/fswepp/">
       <IMG src="/fswepp/images/fsweppic2.jpg" width=75 height=75
       align="left" alt="Back to FS WEPP menu" border=0></a>
    <td align=center>
       <hr>
       <h2>Disturbed WEPP</h2>
       <hr>
    <td>
       <A HREF="/fswepp/docs/distweppdoc.html" target="docs">
       <IMG src="/fswepp/images/epage.gif"
        align="right" alt="Read the documentation" border=0></a>
    </table>
  <center>
  <FORM name="weppdist" method="post" ACTION="wd.pl">
  <input type="hidden" size="1" name="me" value="',    $me,    '">
  <input type="hidden" size="1" name="units" value="', $units, '">
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

foreach my $ii ( 0 .. $#climates ) {
    print '<OPTION VALUE="', $climates[$ii]->{'clim_file'}, '"';
    print ' selected' if $ii == 0;
    print '> ', $climates[$ii]->{'clim_name'}, "\n";
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
print
"    <th bgcolor=85d2d2><font face=\"Arial, Geneva, Helvetica\">Horizontal<br>Length ($units)
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
  <!-- input type=Radio name="weppversion" value="2000" -->WEPP 2000
  <!-- input type=Radio name="weppversion" value="2008" checked -->
  <!-- a href="/fswepp/weppver2008.html" target="weppver" WEPP 2008 /a -->
</font>
<!--       onClick='RunningMsg(this.form.actionw,"Running WEPP..."); this.form.achtung.value="Run WEPP"'>
  <input type="button" value="Exit" onClick="window.close(self)">-->
<BR>
</center>
</FORM>
<P>
<HR>
theEnd

print '>                                                              
  Interface v. 
  <a href="javascript:popuphistory()">', $version, '</a>
  by
  David Hall, 
  Project Leader  Bill Elliot<BR>
  USDA Forest Service, Rocky Mountain Research Station, Moscow, ID<br>';
$remote_host    = $ENV{'REMOTE_HOST'};
$remote_address = $ENV{'REMOTE_ADDR'};

$wc    = `wc ../working/wd.log`;
@words = split " ", $wc;
$runs  = @words[0];

print
"  $remote_host &ndash; $remote_address ($user_really) personality '<b>$me</b>'<br>
  <b>$runs</b> Disturbed WEPP runs since Jan 1, 2011
  <!--  9,875 runs in 2009 -->
  <!-- 18,970 runs in 2008 -->
  <!--  9,538 runs in 2007 -->
  <!-- 16,760 runs in 2006 -->
  <!-- 16,760 runs in 2006 -->
  <!-- 19,060 runs in 2005 -->
  <!-- 19,258 runs in 2004 -->
  <!-- 18,950 runs in 2003 -->
  <!-- 12,176 runs in 2002 -->
 </body>
</html>
";

# --------------------- subroutines
