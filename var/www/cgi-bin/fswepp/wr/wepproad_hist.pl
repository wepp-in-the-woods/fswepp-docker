#!/usr/bin/perl

#  wepproad.pl -- input screen for WEPP:Road

## BEGIN HISTORY ###################################
## WEPP:Road version history

  $version = '2012.10.29';	# Add help text and graphics
# $version = '2011.12.22';	# Force WEPP 2010 executable
# $version = '2009.09.17';	# Adjust FSWEPPuser personality
# $version = "2009.02.23";	# Add option for WEPP version
# $version = "2005.08.15";	# Add metadata to generated HTML page
# $version = "2003.11.24";	# Restrict confirm of unrutted high traffic to native surface
# $version = "2003.11.14";	# Add rock content field to log file; Add traffic level to surface field; Remove "extended output" option (now always available); Remove "paved" warning; Add "road surface" popup help; Add traffic level radio buttons for "low" and "no" traffic; Add "rock content" input (was 20% for buffer before); Display user IP for diagnostic purposes (enhanced); Display counter for number of runs; Move history report to popup window; Clean up type faces
# $version = "2001.01.04";	# If no units specified (bookmarked), use "ft"
# $version = "2000.09.21";	# Add paved surface button

## END HISTORY ###################################

#  2009.09.17 DEH Keep up with FSWEPPuser personality
#  2009.02.23 DEH Add option for WEPP version
#  2005.08.15 DEH Add metadata to generated HTML page
#  2004.11.10 DEH Remove '||die' in collecting personal & standard climates
#  2004.01.05 DEH Adjust run counter message
#  2003.12.24 DEH move wrdev to wr and change internal pointers
#  2003.11.24 DEH restrict confirm of unrutted high traffic to native surface
#  2003.11.14 DEH .log to .wrlog to differentiate from old wr log and
#                    from upcoming wd and we logs
#                 logstuff.pl to logstuffwr.pl to ditto
#  2003.10.15 DEH Display IP and run counter
#  2003.10.14 DEH clean up fonts
#  2001.01.25 DEH default units is 'ft' (bookmarked?)
#  2001.03.05 DEH Filter climate names on $user_ID_ instead of $user_ID
#		note: still globbed
#  2000.09.21   Add paved button according to Hakjun Rhee instructions
#               Add capability to read PUBLIC (!) climates
#		added 10/24/2001 from "forest" version
#  usage:
#    action = "wepproad.pl"
#  parameters:
#    units:		# unit scheme (ft|m)
#    me
#  reads environment variables:
#       HTTP_COOKIE
#       REMOTE_ADDR
#       REQUEST_METHOD
#       QUERY_STRING
#       CONTENT_LENGTH
#  reads: 
#    ../wepphost	# localhost or other
#    ../platform	# pc or unix
#    ../climates/*.par	# standard climate parameter files
#    $working/*.par	# personal climate parameter files
#  calls:
#    /cgi-bin/fswepp/wrd/wr.pl
#    /cgi-bin/fswepp/wrd/logstuffwr.pl
#  popup links:
#    /fswepp/wr/wrwidths.html
#    /fswepp/wr/rddesign.html
#    /fswepp/wr/rockcont.html
#    /fswepp/wr/traflevl.html
#    /fswepp/wr/roadsurf.html
#    /fswepp/wr/road.html		# 2012
#    /fswepp/wr/fill.html		# 2012
#    /fswepp/wr/buffer.html		# 2012
#    /fswepp/wr/wepp2010.html		# 2012
#    history

#  FSWEPP, USDA Forest Service, Rocky Mountain Research Station, Soil & Water Engineering
#  Science by Bill Elliot et alia                                      Code by David Hall

#  05 December 2000 DEH  documentation to target "docs"
#  18 May 2000 DEH personal climates for "" limited to "" no "a", "b"...
#  19 October 1999

  &ReadParse(*parameters);
  $units=$parameters{'units'};
  if ($units eq '') {$units = 'ft'}	# DEH 01/05/2001
# $me=$parameters{'me'};
  $cookie = $ENV{'HTTP_COOKIE'};
#  $sep = index ($cookie,"=");
#  $me = "";
#  if ($sep > -1) {$me = substr($cookie,$sep+1,1)} 
  $sep = index ($cookie,"FSWEPPuser=");
  $me = "";
  if ($sep > -1) {$me = substr($cookie,$sep+11,1)}      # DEH 2009.09.17

  if ($me ne "") {
#    $me = lc(substr($me,0,1));
#    $me =~ tr/a-z/ /c;
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
    if (-e 'd:/fswepp/working') {$working = 'd:\\fswepp\\working'}
    elsif (-e 'c:/fswepp/working') {$working = 'c:\\fswepp\\working'}
    else {$working = '..\\working'}
    $logFile = "$working\\wrwepp.log";
    $cliDir = '..\\climates\\';
    $custCli = "$working\\";
  }
  else {
    $public = $working . 'public/';                     # DEH 03/06/2001
    $user_ID = $ENV{'REMOTE_ADDR'};
    $user_really = $ENV{'HTTP_X_FORWARDED_FOR'};        # DEH 10/15/2003
    $user_ID = $user_really if ($user_really ne '');    # DEH 10/15/2002
    $user_ID =~ tr/./_/;
    $user_ID = $user_ID . $me;
    $user_ID_ = $user_ID . '_';				# DEH 03/05/2001
    $logFile = '../working/' . $user_ID . '.wrlog';
    $cliDir = '../climates/';
    $custCli = '../working/' . $user_ID . '_';		# DEH 05/18/2000
  }

##########################################

### get personal climates, if any

#    $user_ID=$ENV{'REMOTE_ADDR'};
#    $user_ID =~ tr/./_/;

    $num_cli=0;
#   @fileNames = glob($custCli . $user_ID . '*.par');
    @fileNames = glob($custCli . '*.par');
    for $f (@fileNames) {
#     open(M,"<$f") || die;              # par file
      if (open(M,"<$f")) {              # par file 2004.11.10 DEH
          $station = <M>;
        close (M);
        $climate_file[$num_cli] = substr($f, 0, length($f)-4);
        $clim_name = '*' . substr($station, index($station, ":")+2, 40); 
        $clim_name =~ s/^\s*(.*?)\s*$/$1/;
        $climate_name[$num_cli] = $clim_name;
        $num_cli += 1;
      }					# 2004.11.10 DEH
    }

### get standard climates

    while (<../climates/*.par>) {
      $f = $_;
#      open(M,$f) || die;		# 2004.11.10 DEH
      if (open(M,$f)) {			# 2004.11.10 DEH
          $station = <M>;
        close (M);
        $climate_file[$num_cli] = substr($f, 0, length($f)-4);
        $clim_name = substr($station, index($station, ":")+2, 40);
        $clim_name =~ s/^\s*(.*?)\s*$/$1/;
        $climate_name[$num_cli] = $clim_name;
        $num_cli += 1;
      }					# 2004.11.10 DEH
    }
    $num_cli -= 1;

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
  <META NAME="Source" content="Run online at http://forest.moscowfsl.wsu.edu/fswepp/">
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
if ($units eq "m") {
  $RLmin=1;   $RLdef=60; $RLmax=300; $RLunit='m';
  $RSmin=0.1; $RSdef=4;  $RSmax=40;  $RSunit='%';
  $RWmin=0.3; $RWdef=4;  $RWmax=100; $RWunit='m';
  $FLmin=0.3; $FLdef=5;  $FLmax=100; $FLunit='m';
  $FSmin=0.1; $FSdef=50; $FSmax=150; $FSunit='%';
  $BLmin=0.3; $BLdef=40; $BLmax=300; $BLunit='m';
  $BSmin=0.1; $BSdef=25; $BSmax=100; $BSunit='%';
}
else {
  $RLmin=3;   $RLdef=200; $RLmax=1000; $RLunit='ft';
  $RSmin=0.3; $RSdef=4;   $RSmax=40;   $RSunit='%';
  $RWmin=1;   $RWdef=13;  $RWmax=300;  $RWunit='ft';
  $FLmin=1;   $FLdef=15;  $FLmax=1000;  $FLunit='ft';  #  29685 Jan  3  2007 wepproad.pl   was 300 max

  $FSmin=0.3; $FSdef=50;  $FSmax=150;  $FSunit='%';
  $BLmin=1;   $BLdef=130; $BLmax=1000; $BLunit='ft';
  $BSmin=0.3; $BSdef=25;  $BSmax=100;  $BSunit='%';
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

function popupwidth() {
url = 'http://",$wepphost,"/fswepp/wr/wrwidths.html';
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
url = 'http://",$wepphost,"/fswepp/wr/rddesign.html';
height=500;
width=660;
popupwindow = window.open(url,'popupwindow','toolbar=no,location=no,status=no,directories=no,menubar=no,scrollbars=yes,resizable=yes,width='+width+',height='+height);
popupwindow.focus()
}

function popuptraffic() {
url = 'http://",$wepphost,"/fswepp/wr/traflevl.html';
height=500;
width=660;
popupwindow = window.open(url,'popupwindow','toolbar=no,location=no,status=no,directories=no,menubar=no,scrollbars=yes,resizable=yes,width='+width+',height='+height);
popupwindow.focus()
}

function popuprock() {
url = 'http://",$wepphost,"/fswepp/wr/rockcont.html';
height=500;
width=660;
popupwindow = window.open(url,'popupwindow','toolbar=no,location=no,status=no,directories=no,menubar=no,scrollbars=yes,resizable=yes,width='+width+',height='+height);
popupwindow.focus()
}

function popupsurface() {
url = 'http://",$wepphost,"/fswepp/wr/roadsurf.html';
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
       <a href="http://',$wepphost,'/fswepp/">
       <IMG src="http://',$wepphost,'/fswepp/images/fsweppic2.jpg"
       width=65 height=65
       align="left" alt="Return to FSWEPP menu" border=0></a>
    <td align=center>
       <hr>
       <H2>WEPP:Road<br>WEPP Forest Road Erosion Predictor</H2>
       <hr>
    <td>
       <A HREF="http://',$wepphost,'/fswepp/docs/wroadimg.html" target="docs">
       <IMG src="http://',$wepphost,'/fswepp/images/ipage.gif"
        align="right" alt="Read the documentation" border=0></a>
    </table>

<CENTER>',"\n";
  $glo = $custCli . $user_ID . '*.par';
if ($debug) {print "I am '$me' with units $units\nUser_ID: $user_ID<p>$glo<p>"}
print "  <br clear=all>\n";
print '  <FORM name="wepproad" method=post onSubmit="return validate()" ACTION="/cgi-bin/fswepp/wr/wr_hist.pl">';
print "\n";
print '      <input type="hidden" name="me" value="',$me,'">';
#print '      <input type="hidden" name=units" value="',$units,'">'; 
print <<'theEnd';
  <TABLE border="1">
   <TR align="top">
    <TD align="center" bgcolor="#85D2D2">
    <B><a href="JavaScript:submitme('Describe Climate')"
             onMouseOver="window.status='Describe climate';return true"
             onMouseOut="window.status='Forest Service WEPP:Road'; return true">
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
  <SELECT NAME="Climate" SIZE="4">
theEnd

# ##################################################################

#    $user_ID=$ENV{'REMOTE_ADDR'};
#    $user_ID =~ tr/./_/;

    $num_cli=0;
### get published climates, if any                      # DEH 03/06/2001

    opendir PUBLICDIR, $public;
    @allpfiles=readdir PUBLICDIR;
    close PUBLICDIR;

    for $f (@allpfiles) {
      if (substr($f,-4) eq '.par') {
        $f = $public . $f;
        open(M,"<$f") || goto v_skip;
          $station = <M>;
        close (M);
        $climate_file[$num_cli] = substr($f, 0, -4);
        $clim_name = '- ' . substr($station, index($station, ":")+2, 40);
        $clim_name =~ s/^\s*(.*?)\s*$/$1/;
        $climate_name[$num_cli] = $clim_name;
        $num_cli += 1;
v_skip:
      }
    }

### get personal climates

    $num_cli=0;
#   @fileNames = glob($custCli . $user_ID . '*.par');
    @fileNames = glob($custCli . '*.par');
    for $f (@fileNames) {
      open(M,"<$f") || die;              # par file
        $station = <M>;
      close (M);
      $climate_file[$num_cli] = substr($f, 0, length($f)-4);
      $clim_name = '*' . substr($station, index($station, ":")+2, 40); 
      $clim_name =~ s/^\s*(.*?)\s*$/$1/;
      $climate_name[$num_cli] = $clim_name;
      $num_cli += 1;
    }

### get standard climates

    while (<../climates/*.par>) {
      $f = $_;
      open(M,$f) || die;
        $station = <M>;
      close (M);
      $climate_file[$num_cli] = substr($f, 0, length($f)-4);
      $clim_name = substr($station, index($station, ":")+2, 40);
      $clim_name =~ s/^\s*(.*?)\s*$/$1/;
      $climate_name[$num_cli] = $clim_name;
      $num_cli += 1;
    }
    $num_cli -= 1;

#    $user_ID=$ENV{'REMOTE_ADDR'};
#    $user_ID =~ tr/./_/;
#    $fileName = "../rc/working/" . $user_ID;
#    $fileNameE = $fileName . ".cli";

    if ($num_cli > 0) {
      print '    <OPTION VALUE="';
      print $climate_file[0];
      print '" selected> '. $climate_name[0] . "\n";
    }
    for $ii (1..$num_cli) {
      print '    <OPTION VALUE="';
      print $climate_file[$ii];
      print '"> '. $climate_name[$ii] . "\n";
    }

#################
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
    <input type="SUBMIT" name="ActionC" value="Custom Climate">

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
print "    <TH bgcolor=#85D2D2><font face='Arial, Geneva, Helvetica'>Length<br> ($units)</font></th>\n";
print '    <TH bgcolor=#85D2D2><a href="JavaScript:popup(\'wrwidths\')">';
print "     <font face='Arial, Geneva, Helvetica'>Width</a><br> ($units)</font></th>\n";
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
    <TD><INPUT NAME="RS" TYPE="TEXT" SIZE="5" VALUE="',$RSdef,'"
        onChange="checkRange(RS,\'road gradient\',RSmin, RSmax, RSdef, RSunit)"
        onFocus="showRange(this.form,\'Road gradient: \',RSmin, RSmax, RSunit)"
        onBlur="blankStatus()">
    </td>
    <TD><INPUT NAME="RL" TYPE="TEXT" SIZE="5" VALUE="',$RLdef,'"
        onChange="checkRange(RL,\'road length\',RLmin, RLmax, RLdef, RLunit)"
        onFocus="showRange(this.form,\'Road length: \',RLmin, RLmax, RLunit)"
        onBlur="blankStatus()">
    </td>
    <TD><INPUT NAME="RW" TYPE="TEXT" SIZE="5" VALUE="',$RWdef,'"
        onChange="checkRange(RW,\'road width\',RWmin, RWmax, RWdef,RWunit)"
        onFocus="showWidthHelp(this.form,\'Road width: \',RWmin, RWmax, RWunit)"
        onBlur="blankStatus()">
    </td>
   </tr>
   <TR>
    <TH bgcolor="#85D2D2"><font face="Arial, Geneva, Helvetica"><a href="JavaScript:popup(\'fill\')">Fill</a></font></th>
    <TD><INPUT NAME="FS" TYPE="TEXT" SIZE="5" VALUE="',$FSdef,'"
        onChange="checkRange(FS,\'fill gradient\',FSmin, FSmax, FSdef, FSunit)"
        onFocus="showRange(this.form,\'Fill gradient: \',FSmin, FSmax, FSunit)"
        onBlur="blankStatus()">
    </td>
    <TD><INPUT NAME="FL" TYPE="TEXT" SIZE="5" VALUE="',$FLdef,'"
        onChange="checkRange(FL,\'fill length\',FLmin, FLmax, FLdef, FLunit)"
        onFocus="showRange(this.form,\'Fill length: \',FLmin, FLmax, FLunit)"
        onBlur="blankStatus()">
    </td>
<!--    <TD><INPUT NAME="FW" TYPE="TEXT" SIZE="5" VALUE="',$FWdef,'"
        onChange="checkRange(FW,\'fill width\',FWmin, FWmax, FWdef,FWunit)"
        onFocus="showWidthHelp(this.form,\'Fill width: \',FWmin, FWmax, FWunit)"
        onBlur="blankStatus()">  -->
<TR><TH bgcolor="#85D2D2"><a href="JavaScript:popup(\'buffer\')">Buffer</a>
    <TD><INPUT NAME="BS" TYPE="TEXT" SIZE="5" VALUE="',$BSdef,'"
        onChange="checkRange(BS,\'buffer gradient\',BSmin, BSmax, BSdef, BSunit)"
        onFocus="showRange(this.form,\'Buffer gradient: \',BSmin, BSmax, BSunit)"
        onBlur="blankStatus()">
    </td>
    <TD><INPUT NAME="BL" TYPE="TEXT" SIZE="5" VALUE="',$BLdef,'"
        onChange="checkRange(BL,\'buffer length\',BLmin, BLmax, BLdef, BLunit)"
        onFocus="showRange(this.form,\'Buffer length: \',BLmin, BLmax, BLunit)"
        onBlur="blankStatus()">
    </td>
<!--
    <TD><INPUT NAME="BW" TYPE="TEXT" SIZE="5" VALUE="',$BWdef,'"
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
  <font size=-2>WEPP 2010.100
<br>
theEnd

print '
  <font color=red size=-2>
   For <a href="JavaScript:popup(\'wepp2010\')">continuity:</a> <a href="/cgi-bin/fswepp/wr/wepproadv2000.pl?units=',$units,'">WEPP:Road 2000</a> 
  </font>
  <br>

  <input type="hidden" name="climate_name">
   <INPUT TYPE="HIDDEN" NAME="units" VALUE="',$units,'">
   <p>
   <hr>
  </FORM>

  <form name="newlog" method=post action="http://',
      $wepphost,'/cgi-bin/fswepp/wr/logstuffwr.pl">
  Project description <input type="text" name="projectdescription">
  <input type="submit" name="button" value="Create new log" onClick="return confirm(\'This will delete any existing log file\')">
';
if (-e $logFile) {
  print '  <input type="submit" name="button" value="Display log">'
}

  $remote_host = $ENV{'REMOTE_HOST'};
  $remote_address = $ENV{'REMOTE_ADDR'};  # if ($userIP eq '');

  $wc  = `wc ../working/wr.log`;
  @words = split " ", $wc;
  $runs = @words[0];

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
      <a href="javascript:popuphistory()">', $version,'</a><br>
      USDA Forest Service Rocky Mountain Research Station<br>
      1221 South Main Street, Moscow, ID 83843<br>',
      "$remote_host &ndash; $remote_address ($user_really) personality '<b>$me</b>'<br>
      <b>$runs</b> WEPP:Road runs since Jan 1, 2012
   <!--
         8,101 runs in 2009
         8,563 runs in 2008
         9,033 runs in 2007
         8,028 runs in 2006
         9,512 runs in 2005
        12,119 runs in 2004
        19,845 runs in 2003
        17,845 runs in 2002 -->
     </font>
    </td>
    <td>
     <a href=\"http://$wepphost/fswepp/comments.html\" 
";
if ($wepphost eq 'localhost')
 {print 'onClick="return confirm(\'You must be connected to the Internet to e-mail comments. Shall I try?\')"'};
print '> 
     <img src="http://',$wepphost,'/fswepp/images/epaemail.gif" align="right" border=0></a>
    </td>
   </tr>
  </table>
 </BODY>
</HTML>
';

# ------------------------ subroutines ---------------------------------

sub ReadParse {

# ReadParse -- from cgi-lib.pl (Steve Brenner) from Eric Herrmann's
# "Teach Yourself CGI Programming With PERL in a Week" p. 131

  local (*in) = @_ if @_;
  local ($i, $loc, $key, $val);

  if ($ENV{'REQUEST_METHOD'} eq "GET") {
    $in = $ENV{'QUERY_STRING'}} 
  elsif ($ENV{'REQUEST_METHOD'} eq "POST") {
    read(STDIN,$in,$ENV{'CONTENT_LENGTH'})}

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
        ($vers, $comment) = split (/;/,$_,2);
        $comment =~ s/#//;
        $comment =~ s(;)(<br>)g;
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
