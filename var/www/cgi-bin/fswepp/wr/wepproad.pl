#!/usr/bin/perl

use warnings;
use CGI;
use CGI qw(escapeHTML);

use MoscowFSL::FSWEPP::CligenUtils qw(GetClimates);
use MoscowFSL::FSWEPP::FsWeppUtils qw(get_version get_user_id get_units);

#  wepproad.pl -- input screen for WEPP:Road

my $version = get_version(__FILE__);
my $user_ID = get_user_id();
my ($units, $areaunits) = get_units();

my $cgi = CGI->new;

$logFile  = '../working/' . $user_ID . '.wrlog';
$custCli  = '../working/' . $user_ID . '_';               # DEH 05/18/2000

my @climates = GetClimates($user_ID);

##########################################

print "Content-type: text/html\n\n";
print '<HTML>
 <HEAD>
  <TITLE>WEPP:Road
  </TITLE>
  <META http-equiv="Content-Type" content="text/html; charset=utf-8">
  <META NAME="Name" CONTENT="WEPP:Road">
  <META NAME="Brief Description" CONTENT="WEPP:Road, a component of FS WEPP, predicts erosion from insloped or outsloped forest roads. WEPP:Road allows users to easily describe numerous road erosion conditions.">
  <META NAME="Status" CONTENT="Released 2000">
  <META NAME="Updates" CONTENT="Ongoing, online">
  <META NAME="Inputs" CONTENT="Climate station; soil texture; rock content; nominal road design; road gradient, length, and width; fill gradient and length; buffer gradient and length; road surface (native, graveled, paved); traffic level (high, low, none)">
  <META NAME="Outputs" CONTENT="Annual average precipitation; runoff from rainfall; runoff from snowmelt or winter rainstorm; erosion from road prism; sediment leaving buffer">
  <META NAME="Suggested user" CONTENT="">
  <META NAME="Suggested use" CONTENT="">
  <META NAME="Keywords" CONTENT="">
  <META NAME="Contributors" CONTENT="USDA Forest Service, Rocky Mountain Research Station, Moscow, ID">
  <META NAME="Source" content="Run online at https://forest.moscowfsl.wsu.edu/fswepp/">
  <SCRIPT Language="JavaScript" type="TEXT/JAVASCRIPT">
<!--
function validate() {

  if (window.document.wepproad.traffic[0].checked
   && window.document.wepproad.SlopeType.selectedIndex==3
   && window.document.wepproad.surface[0].checked) {
    if (confirm("High traffic unrutted not allowed -- selecting rutted")) {
      window.document.wepproad.SlopeType.selectedIndex=2
    }
  }
  if (window.document.wepproad.traffic[0].checked
   && window.document.wepproad.SlopeType.selectedIndex==3
   && window.document.wepproad.surface[0].checked) {
    return false
  }
  else {
    document.wepproad.ActionW.value="Running...";
    document.wepproad.achtung.value="Run WEPP";
    return true
  }
}

function readCookie() {
   var cookie_name = "FSWEPPuser";
//   if(document.cookie) {
      index = document.cookie.indexOf(cookie_name);
      var cookiebeg = (document.cookie.indexOf("=",index)+1);
      var cookieend = document.cookie.indexOf(";",index);
      if (cookieend==-1) {cookieend=document.cookie.length}
//      var LastUsercode = document.cookie.substring(cookiebeg,cookieend);
      var LastUsercode = document.cookie.substring(cookiebeg,cookiebeg+1);
      document.wepproad.me.value = LastUsercode;
//   } else {
//      document.wepproad.me.value = "z";
//   }
}

//  mperf=1/3.29
';
if ( $units eq "m" ) {
    $RLmin  = 1;
    $RLdef  = 60;
    $RLmax  = 300;
    $RLunit = 'm';
    $RSmin  = 0.1;
    $RSdef  = 4;
    $RSmax  = 40;
    $RSunit = '%';
    $RWmin  = 0.3;
    $RWdef  = 4;
    $RWmax  = 100;
    $RWunit = 'm';
    $FLmin  = 0.3;
    $FLdef  = 5;
    $FLmax  = 100;
    $FLunit = 'm';
    $FSmin  = 0.1;
    $FSdef  = 50;
    $FSmax  = 150;
    $FSunit = '%';
    $BLmin  = 0.3;
    $BLdef  = 40;
    $BLmax  = 300;
    $BLunit = 'm';
    $BSmin  = 0.1;
    $BSdef  = 25;
    $BSmax  = 100;
    $BSunit = '%';
}
else {
    $RLmin  = 3;
    $RLdef  = 200;
    $RLmax  = 1000;
    $RLunit = 'ft';
    $RSmin  = 0.3;
    $RSdef  = 4;
    $RSmax  = 40;
    $RSunit = '%';
    $RWmin  = 1;
    $RWdef  = 13;
    $RWmax  = 300;
    $RWunit = 'ft';
    $FLmin  = 1;
    $FLdef  = 15;
    $FLmax  = 1000;
    $FLunit = 'ft';    #  29685 Jan  3  2007 wepproad.pl   was 300 max

    $FSmin  = 0.3;
    $FSdef  = 50;
    $FSmax  = 150;
    $FSunit = '%';
    $BLmin  = 1;
    $BLdef  = 130;
    $BLmax  = 1000;
    $BLunit = 'ft';
    $BSmin  = 0.3;
    $BSdef  = 25;
    $BSmax  = 100;
    $BSunit = '%';
}
print "
  RSmin=$RSmin; RSdef=$RSdef; RSmax=$RSmax; RSunit='$RSunit'
  RLmin=$RLmin; RLdef=$RLdef; RLmax=$RLmax; RLunit='$RLunit'
  RWmin=$RWmin; RWdef=$RWdef; RWmax=$RWmax; RWunit='$RWunit'
  FLmin=$FLmin; FLdef=$FLdef; FLmax=$FLmax; FLunit='$FLunit'
  FSmin=$FSmin; FSdef=$FSdef; FSmax=$FSmax; FSunit='$FSunit'
  BLmin=$BLmin; BLdef=$BLdef; BLmax=$BLmax; BLunit='$BLunit'
  BSmin=$BSmin; BSdef=$BSdef; BSmax=$BSmax; BSunit='$BSunit'
";

print <<'theEnd';
  var minyear = 1
  var maxyear = 200
  var defyear = 30

  function submitme(which) {
    document.forms.wepproad.achtung.value=which
    document.forms.wepproad.submit()
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

  function checkRange(obj, head, min, max, def, unit) {
     if (isNumber(obj.value)) {
       if (obj.value < min){
         alert(head + " must be between " + min + " and " + max + unit)
         obj.value=min
         return false
       }
       if (obj.value > max) {
         alert(head + " must be between " + min + " and " + max + unit)
         obj.value=max
         return false
       }
     } else {
         alert("Invalid entry for " + head+"!")
         obj.value=def
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
         alert("Invalid entry for number of years!")
         obj.value=defyear
         return false
       }
  }

function blankStatus() {
  window.status = "Forest Service WEPP:Road"
  return true 
}

function showRange(obj, head, min, max, unit) {
  window.status = head + min + " to " + max + unit	
  return true
}

function showWidthHelp(obj, head, min, max, unit) {
  var which = window.document.wepproad.SlopeType.selectedIndex;
     if (which == 0) {vhead = "Ditch width + traveledway width: "}
     else if (which == 1) {vhead = "Ditch width + traveledway width: "}
     else if (which == 2) {vhead = "Traveledway width: "}
     else {vhead = "Rut spacing + rut width: "}
  window.status = vhead + min + " to " + max + unit	
  return true
}
    function hide_help() {
//    alert('hide_help')
      previous_what=''
      document.getElementById("help_text").innerHTML = '';
    }

function showTexture() {
  var which = window.document.wepproad.SoilType.selectedIndex;
  if (which == 0)             //clay loam
     {text = "Native-surface roads on shales and similar decomposing sedimentary rock (MH, CH)"}
   else if (which == 2)       // silty loam
     {text = "Glacial outwash areas; finer-grained granitics (SW, SP, SM, SC)"}
   else if (which == 1)       // sandy loam
     {text = "Ash cap native-surface road; alluvial loess native-surface road (ML, CL)"}
   else                       // loam
     {text = "Glacial tills and mixed alluvial deposts (SC)"}
   window.status = text
   return true
}

function showExtendedHelp() {
  window.status = "Check the extended output box to receive WEPP summary output with your next run"
  return true
}

theEnd
print "

  function popupclosest() { 
    url = '/fswepp/rc/closest.php?units=ft'; width=900; height=600; popupwindow = 
    window.open(url,'popupwindow','toolbar=no,location=no,status=no,directories=no,menubar=no,scrollbars=yes,resizable=yes,width='+width+',height='+height);
    popupwindow.focus ()

function popupwidth() {
url = '/fswepp/wr/wrwidths.html';
height=200;
width=500;
popupwindow = window.open(url,'popupwindow','toolbar=no,location=no,status=no,directories=no,menubar=no,scrollbars=yes,resizable=yes,width='+width+',height='+height);
popupwindow.focus()
}

function popup(what) {
url = '/fswepp/wr/'+what+'.html';
height=700;
width=700;
popupwindow = window.open(url,'popupwindow','toolbar=no,location=no,status=no,directories=no,menubar=no,scrollbars=yes,resizable=yes,width='+width+',height='+height);
popupwindow.focus()
}

function popupdesign() {
url = '/fswepp/wr/rddesign.html';
height=500;
width=660;
popupwindow = window.open(url,'popupwindow','toolbar=no,location=no,status=no,directories=no,menubar=no,scrollbars=yes,resizable=yes,width='+width+',height='+height);
popupwindow.focus()
}

function popuptraffic() {
url = '/fswepp/wr/traflevl.html';
height=500;
width=660;
popupwindow = window.open(url,'popupwindow','toolbar=no,location=no,status=no,directories=no,menubar=no,scrollbars=yes,resizable=yes,width='+width+',height='+height);
popupwindow.focus()
}

function popuprock() {
url = '/fswepp/wr/rockcont.html';
height=500;
width=660;
popupwindow = window.open(url,'popupwindow','toolbar=no,location=no,status=no,directories=no,menubar=no,scrollbars=yes,resizable=yes,width='+width+',height='+height);
popupwindow.focus()
}

function popupsurface() {
url = '/fswepp/wr/roadsurf.html';
height=500;
width=660;
popupwindow = window.open(url,'popupwindow','toolbar=no,location=no,status=no,directories=no,menubar=no,scrollbars=yes,resizable=yes,width='+width+',height='+height);
popupwindow.focus()
}

// -->
</SCRIPT>
</HEAD>
";

print '<BODY bgcolor="white" link="#555555" vlink="#555555">
  <font face="Arial, Geneva, Helvetica">
  <table width="100%" border=0>
    <tr><td>
       <a href="/fswepp/">
       <IMG src="/fswepp/images/fsweppic2.jpg"
       width=65 height=65
       align="left" alt="Return to FSWEPP menu" border=0></a>
    <td align=center>
       <hr>
       <H2>WEPP:Road<br>WEPP Forest Road Erosion Predictor</H2>
       <hr>
    <td>
       <A HREF="/fswepp/docs/wroadimg.html" target="docs">
       <IMG src="/fswepp/images/ipage.gif"
        align="right" alt="Read the documentation" border=0></a>
    </table>

<CENTER>', "\n";
$glo = $custCli . $user_ID . '*.par';

print "  <br clear=all>\n";
print
'  <FORM name="wepproad" method=post onSubmit="return validate()" ACTION="wr.pl">';
print "\n";

#print '      <input type="hidden" name=units" value="',$units,'">';
print qq(
  <TABLE border="1">
   <TR align="top">
    <TD align="center" bgcolor="#85D2D2">
    <B>
    <a href="#" onclick="
          var climateValue = document.getElementById('Climate').value;
          window.location.href = '/cgi-bin/fswepp/rc/descpar.pl?CL=' + climateValue + '&units=$units'">
          Climate Station</a></B>
  <td width=10>
  <TD align="center" bgcolor="#85D2D2">
    <B><a href="JavaScript:submitme('Describe Soil')"
             onMouseOver="window.status='Describe soil';return true"
             onMouseOut="window.status='Forest Service WEPP:Road'; return true">
             Soil Texture</B>
<!--  <td width=10>  -->
<TR>
  <TD align=center>
  <SELECT NAME="Climate" id="Climate" SIZE="5">
);

foreach my $ii ( 0 .. $#climates ) {
    print '<OPTION VALUE="', $climates[$ii]->{'clim_file'}, '"';
    print ' selected' if $ii == 0;
    print '> ', $climates[$ii]->{'clim_name'}, "\n";
}

print <<'theEnd';
  </SELECT>
  <td>
  <TD align=center>
  <SELECT NAME="SoilType" SIZE="4" 
       onChange="showTexture()"
       onBlur="blankStatus()">
   <OPTION VALUE="clay" SELECTED>clay loam
   <OPTION VALUE="silt">silt loam
   <OPTION VALUE="sand">sandy loam
   <OPTION VALUE="loam">loam
  </SELECT>
  </TD>
</TR>

  <tr>
   <td align=center>
    <input type="hidden" name="achtung" value="Run WEPP">
    <button type="button" onclick="window.location.href='/cgi-bin/fswepp/rc/rockclim.pl?comefrom=road&units=$units'">Custom Climate</button>
    <input type="button" value="Closest Wx" onclick="javascript:popupclosest()">

<!--    <input type="submit" name="ActionCD" value="Describe">
    <td>
    <td><input type="submit" name="ActionSD" value="Soil">
 -->
    <td></td>
    <TH bgcolor="#85D2D2">
     <font face="Arial, Geneva, Helvetica">
      <a href="javascript:popuprock()">Rock</a> (%)&nbsp;<INPUT NAME="Rock" SIZE="5" VALUE="20">
     </font>
    </th>
   </tr>
  </TABLE>
  <P>
  <TABLE BORDER="1">
   <TR>
    <TH bgcolor="#85D2D2"><a href="JavaScript:popupdesign()">
    <font face="Arial, Geneva, Helvetica">Road Design</a></font></th>
    <TH rowspan=5 width=20><BR></th>
    <TH>
    <TH bgcolor="#85D2D2"><font face="Arial, Geneva, Helvetica">Gradient<br> (%)</font></th>
theEnd
print
"    <TH bgcolor=#85D2D2><font face='Arial, Geneva, Helvetica'>Length<br> ($units)</font></th>\n";
print '    <TH bgcolor=#85D2D2><a href="JavaScript:popup(\'wrwidths\')">';
print
"     <font face='Arial, Geneva, Helvetica'>Width</a><br> ($units)</font></th>\n";
print '    
   <tr>
    <TD rowspan=4>
     <SELECT NAME="SlopeType" SIZE="4" ALIGN="top">
      <OPTION VALUE="inbare"> Insloped, bare ditch
      <OPTION VALUE="inveg" SELECTED> Insloped, vegetated or rocked ditch
      <OPTION VALUE="outrut"> Outsloped, rutted
      <OPTION VALUE="outunrut"> Outsloped, unrutted
     </SELECT>
    </td>
    <TH bgcolor="#85D2D2"><font face="Arial, Geneva, Helvetica"><a href="JavaScript:popup(\'road\')">Road</a></font></th>
    <TD><INPUT NAME="RS" TYPE="TEXT" SIZE="5" VALUE="', $RSdef, '"
        onChange="checkRange(RS,\'road gradient\',RSmin, RSmax, RSdef, RSunit)"
        onFocus="showRange(this.form,\'Road gradient: \',RSmin, RSmax, RSunit)"
        onBlur="blankStatus()">
    </td>
    <TD><INPUT NAME="RL" TYPE="TEXT" SIZE="5" VALUE="', $RLdef, '"
        onChange="checkRange(RL,\'road length\',RLmin, RLmax, RLdef, RLunit)"
        onFocus="showRange(this.form,\'Road length: \',RLmin, RLmax, RLunit)"
        onBlur="blankStatus()">
    </td>
    <TD><INPUT NAME="RW" TYPE="TEXT" SIZE="5" VALUE="', $RWdef, '"
        onChange="checkRange(RW,\'road width\',RWmin, RWmax, RWdef,RWunit)"
        onFocus="showWidthHelp(this.form,\'Road width: \',RWmin, RWmax, RWunit)"
        onBlur="blankStatus()">
    </td>
   </tr>
   <TR>
    <TH bgcolor="#85D2D2"><font face="Arial, Geneva, Helvetica"><a href="JavaScript:popup(\'fill\')">Fill</a></font></th>
    <TD><INPUT NAME="FS" TYPE="TEXT" SIZE="5" VALUE="', $FSdef, '"
        onChange="checkRange(FS,\'fill gradient\',FSmin, FSmax, FSdef, FSunit)"
        onFocus="showRange(this.form,\'Fill gradient: \',FSmin, FSmax, FSunit)"
        onBlur="blankStatus()">
    </td>
    <TD><INPUT NAME="FL" TYPE="TEXT" SIZE="5" VALUE="', $FLdef, '"
        onChange="checkRange(FL,\'fill length\',FLmin, FLmax, FLdef, FLunit)"
        onFocus="showRange(this.form,\'Fill length: \',FLmin, FLmax, FLunit)"
        onBlur="blankStatus()">
    </td>
<!--    <TD><INPUT NAME="FW" TYPE="TEXT" SIZE="5" VALUE="', $FWdef, '"
        onChange="checkRange(FW,\'fill width\',FWmin, FWmax, FWdef,FWunit)"
        onFocus="showWidthHelp(this.form,\'Fill width: \',FWmin, FWmax, FWunit)"
        onBlur="blankStatus()">  -->
<TR><TH bgcolor="#85D2D2"><a href="JavaScript:popup(\'buffer\')">Buffer</a>
    <TD><INPUT NAME="BS" TYPE="TEXT" SIZE="5" VALUE="', $BSdef, '"
        onChange="checkRange(BS,\'buffer gradient\',BSmin, BSmax, BSdef, BSunit)"
        onFocus="showRange(this.form,\'Buffer gradient: \',BSmin, BSmax, BSunit)"
        onBlur="blankStatus()">
    </td>
    <TD><INPUT NAME="BL" TYPE="TEXT" SIZE="5" VALUE="', $BLdef, '"
        onChange="checkRange(BL,\'buffer length\',BLmin, BLmax, BLdef, BLunit)"
        onFocus="showRange(this.form,\'Buffer length: \',BLmin, BLmax, BLunit)"
        onBlur="blankStatus()">
    </td>
<!--
    <TD><INPUT NAME="BW" TYPE="TEXT" SIZE="5" VALUE="', $BWdef, '"
        onChange="checkRange(BW,\'road width\',BWmin, BWmax, BWdef,BWunit)"
        onFocus="showWidthHelp(this.form,\'Buffer width: \',BWmin, BWmax, BWunit)"
        onBlur="blankStatus()">  
    </td>
-->
';
print <<'theEnd';
    </TD>
   </TR>
  </table>
  <BR>
  <B><a href="javascript:popupsurface()">Road surface:</a></B>
  <INPUT TYPE="radio" NAME="surface" checked value="native"><B>Native</B>
  <INPUT TYPE="radio" NAME="surface" value="graveled"><B>Graveled</B>
  <INPUT TYPE="radio" NAME="surface" value="paved"><B>Paved</B>
  <BR>
  <B><a href="javascript:popuptraffic()">Traffic level:</a></B>
  <INPUT TYPE="radio" NAME="traffic" checked value="high"><B>High</B>&nbsp;&nbsp;&nbsp;&nbsp;
  <INPUT TYPE="radio" NAME="traffic" value="low"><B>Low</B>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <INPUT TYPE="radio" NAME="traffic" value="none"><B>None</B>
  <BR>
  <B>Years to simulate:</B> <input type="text" size="3" name="years" value="30"
        onChange="checkYears(this.form.years)"
        onFocus="showRange(this.form,'Years to simulate: ',minyear, maxyear, '')"
        onBlur="blankStatus()">
<!--<b><input type="checkbox" name="Full" value=1
onFocus="showExtendedHelp()" onBlur="blankStatus()">
   Extended output</b>-->
<BR><br>
<INPUT TYPE="SUBMIT" name="ActionW" VALUE="Run WEPP">
  <input type=hidden name="weppversion" value="2010">
<br>
theEnd

print '
  <br>

  <input type="hidden" name="climate_name">
   <INPUT TYPE="HIDDEN" NAME="units" VALUE="', $units, '">
   <p>
   <hr>
  </FORM>

  <form name="newlog" method=post action="/cgi-bin/fswepp/wr/logstuffwr.pl">
  Project description <input type="text" name="projectdescription">
  <input type="submit" name="button" value="Create new log" onClick="return confirm(\'This will delete any existing log file\')">
';

if ( -e $logFile ) {
    print '  <input type="submit" name="button" value="Display log">';
}

$remote_host    = $ENV{'REMOTE_HOST'};
$remote_address = $ENV{'REMOTE_ADDR'};    # if ($userIP eq '');

$wc    = `wc ../working/' . currentLogDir() . '/wr.log`;
@words = split " ", $wc;
$runs  = @words[0];

print '  </FORM>
  </center>
  <P>
  <HR>
  <table width=100%>
   <tr>
    <td>
     <font face="Arial, Geneva, Helvetica" size=-2>
      WEPP:Road input screen version
      <!--a href="/fswepp/history/wrver.html"-->
      <a href="https://github.com/wepp-in-the-woods/fswepp-docker/commits/main/var/www/cgi-bin/fswepp/wr/wepproad.pl">', $version, '</a><br>
      USDA Forest Service Rocky Mountain Research Station<br>
      1221 South Main Street, Moscow, ID 83843<br>',
"$user_ID<br>
      Log of FS WEPP runs for IP and personality <a href=\"/cgi-bin/fswepp/runlogger.pl\" target=\"_rl\">$user_ID</a><br>
      <b>$runs</b> WEPP:Road runs YTD
     </font>
    </td>
   </tr>
  </table>
 </BODY>
</HTML>
";