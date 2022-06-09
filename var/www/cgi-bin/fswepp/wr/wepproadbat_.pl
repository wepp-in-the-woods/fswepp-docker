#! /usr/bin/perl
#! /fsapps/fssys/bin/perl

   $debug=0;

#  wepproadbat.pl -- input screen for WEPP:Road Batch

  $version = "2004.06.14";

#  2004.05.13	Change order of input columns in "spreadsheet"
#  2004.05.06	Add connection to check years input
#		Confirm example data only if 'spread' not empty
#		Need: convert '"' in comments to "'" or other...
#  2004.04.27	Add link for XLS input template
#		and a bunch of other stuff...
#  2004.04.12   Initial trial
#
#  usage:
#    action = "wepproadbat.pl"
#  parameters:
#    units:		# unit scheme (ft|m)
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
#    /cgi-bin/fswepp/wr/wrbat.pl
#    /cgi-bin/fswepp/wr/logstuffwr.pl
#  popup links:
#    /fswepp/wr/wrwidthsb.html
#    /fswepp/wr/rddesignb.html
#    /fswepp/wr/rockcont.html
#    /fswepp/wr/traflevlb.html
#    /fswepp/wr/roadsurfb.html
#    history

#  FS WEPP, USDA Forest Service, Rocky Mountain Research Station, Soil & Water Engineering
#  Science by Bill Elliot et alia                                      Code by David Hall

  &ReadParse(*parameters);
  $units=$parameters{'units'};
  if ($units eq '') {$units = 'ft'}	# DEH 01/05/2001
  $cookie = $ENV{'HTTP_COOKIE'};
  $sep = index ($cookie,"=");
  $me = "";

# DEH 2003.12.22

  if ($sep > -1) {$me = substr($cookie,$sep+1)} 

  if ($me ne "") {
    $me = lc($me);
    $me =~ tr/a-z0-9/_/cs;             # change non-alpha-nums to underline
  }
  if ($me eq ' ') {$me = ''}

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
    $logFile = "$working\\wrbwepp.log";
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
    $logFile = '../working/' . $user_ID . '.wrblog';
    $cliDir = '../climates/';
    $custCli = '../working/' . $user_ID . '_';		# DEH 05/18/2000
  }

##########################################

### get personal climates, if any

#    $user_ID=$ENV{'REMOTE_ADDR'};
#    $user_ID =~ tr/./_/;

    $num_cli=0;
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

##########################################

    if ($units eq 'm') {
     $zz  = 'IV N L 6 60 5 60 5 30 10 20 Typical low use road\n';
     $zz .= 'IB N L 6 60 5 60 5 30 10 20 Same road, but the ditch is graded\n';
     $zz .= 'OR N H 6 60 5 60 5 30 10 20 Same road, but rutted from heavy logging traffic\n';
     $zz .= 'OU N L 6 60 5 60 5 30 10 20 Same road, regraded after logging with low traffic\n';
     $zz .= 'OU N N 6 60 5 60 5 30 10 20 Same road, no traffic allowed after outsloping';
     $RLmin=1;   $RLdef=60; $RLmax=300; $RLunit='m';
     $RSmin=0.1; $RSdef=4;  $RSmax=40;  $RSunit='%';
     $RWmin=0.3; $RWdef=4;  $RWmax=100; $RWunit='m';
     $FLmin=0.3; $FLdef=5;  $FLmax=100; $FLunit='m';
     $FSmin=0.1; $FSdef=50; $FSmax=150; $FSunit='%';
     $BLmin=0.3; $BLdef=40; $BLmax=300; $BLunit='m';
     $BSmin=0.1; $BSdef=25; $BSmax=100; $BSunit='%';
   }
   else {
     $zz  = 'IV N L 6 200 16 60 16 30 30 20 Typical low use road\n';
     $zz .= 'IB N L 6 200 16 60 16 30 30 20 Same road, but the ditch is graded\n';
     $zz .= 'OR N H 6 200 16 60 16 30 30 20 Same road, but rutted from heavy logging traffic\n';
     $zz .= 'OU N L 6 200 16 60 16 30 30 20 Same road, regraded after logging with low traffic\n';
     $zz .= 'OU N N 6 200 16 60 16 30 30 20 Same road, no traffic allowed after outsloping';
     $RLmin=3;   $RLdef=200; $RLmax=1000; $RLunit='ft';
     $RSmin=0.3; $RSdef=4;   $RSmax=40;   $RSunit='%';
     $RWmin=1;   $RWdef=13;  $RWmax=300;  $RWunit='ft';
     $FLmin=1;   $FLdef=15;  $FLmax=300;  $FLunit='ft';
     $FSmin=0.3; $FSdef=50;  $FSmax=150;  $FSunit='%';
     $BLmin=1;   $BLdef=130; $BLmax=1000; $BLunit='ft';
     $BSmin=0.3; $BSdef=25;  $BSmax=100;  $BSunit='%';
   }

print "Content-type: text/html\n\n";
print '<html>
 <head>
  <title>WEPP:Road Batch</title>
  <script Language="JavaScript" type="TEXT/JAVASCRIPT">
   <!--

   function example_record() {
     zz="',$zz,'"
     if (document.wrbat.spread.value == "") {
       document.wrbat.spread.value=zz;
     }
     else {
       if (confirm("This will delete any existing data in the input table")) {
         document.wrbat.spread.value=zz
       }
     }
   }

   function validate() {

//   if (window.document.wrbat.traffic[0].checked && window.document.wrbat.SlopeType.selectedIndex==3) {
//     if (confirm("High traffic unrutted not allowed -- selecting rutted")) {
//       window.document.wrbat.SlopeType.selectedIndex=2
//     }
//   }
//   if (window.document.wrbat.traffic[0].checked && window.document.wrbat.SlopeType.selectedIndex==3) {
//     return false
//   }
//   else {
       document.wrbat.ActionW.value="Running...";
       document.wrbat.achtung.value="Run WEPP";
       return true
//   }
  }

  function readCookie() {
   var cookie_name = "FSWEPPuser";
      index = document.cookie.indexOf(cookie_name);
      var cookiebeg = (document.cookie.indexOf("=",index)+1);
      var cookieend = document.cookie.indexOf(";",index);
      if (cookieend==-1) {cookieend=document.cookie.length}
      var LastUsercode = document.cookie.substring(cookiebeg,cookiebeg+1);
      document.wrbat.me.value = LastUsercode;
  }

//  mperf=1/3.29
';

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
    document.forms.wrbat.achtung.value=which
    document.forms.wrbat.submit()
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
     }
     else {
       alert("Invalid entry for number of years!")
       obj.value=defyear
       return false
     }
  }

  function blankStatus() {
    window.status = "Forest Service WEPP:Road Batch"
    return true 
  }

  function showRange(obj, head, min, max, unit) {
    window.status = head + min + " to " + max + unit	
    return true
  }

  function showWidthHelp(obj, head, min, max, unit) {
    var which = window.document.wrbat.SlopeType.selectedIndex;
      if (which == 0) {vhead = "Ditch width + traveledway width: "}
      else if (which == 1) {vhead = "Ditch width + traveledway width: "}
      else if (which == 2) {vhead = "Traveledway width: "}
      else {vhead = "Rut spacing + rut width: "}
    window.status = vhead + min + " to " + max + unit	
    return true
  }

  function showTexture() {
    var which = window.document.wrbat.SoilType.selectedIndex;
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

  function popuphistory() {
    url = '';
    height=500;
    width=660;
    popupwindow = window.open(url,'popupwindow','toolbar=no,location=no,status=no,directories=no,menubar=no,scrollbars=yes,resizable=yes,width='+width+',height='+height);
    popupwindow.document.writeln('<html>')
    popupwindow.document.writeln(' <head>')
    popupwindow.document.writeln('  <title>WEPP:Road Batch Input version history</title>')
    popupwindow.document.writeln(' </head>')
    popupwindow.document.writeln(' <body bgcolor=white>')
    popupwindow.document.writeln('  <font face="arial, helvetica, sans serif">')
    popupwindow.document.writeln('  <center>')
    popupwindow.document.writeln('   <h3>WEPP:Road Batch Input Version History</h3>')
    popupwindow.document.writeln('   <p>')
    popupwindow.document.writeln('   <table border=0 cellpadding=10>')
    popupwindow.document.writeln('    <tr>')
    popupwindow.document.writeln('     <th bgcolor=85d2d2>Version</th>')
    popupwindow.document.writeln('     <th bgcolor=85d2d2>Comments</th>')
    popupwindow.document.writeln('    </tr>')
    popupwindow.document.writeln('    <tr>')
    popupwindow.document.writeln('     <th valign=top bgcolor=85d2d2>2004.06.14</th>')
    popupwindow.document.writeln('     <td>Initial release</td>')
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

theEnd

  print "
  function popup(url,height,width) {
    uurl = 'http://",$wepphost,"' + url;
//    height=200;
//    width=500;
    popupwindow = window.open(uurl,'popupwindow','toolbar=no,location=no,status=no,directories=no,menubar=no,scrollbars=yes,resizable=yes,width='+width+',height='+height);
    popupwindow.focus()
  }

   // -->
  </script>
 </head>
";

print ' <body bgcolor="#eeddcc" link="#555555" vlink="#555555">
  <font face="Arial, Geneva, Helvetica">
  <table width="100%" border=0>
    <tr><td>
       <a href="http://',$wepphost,'/fswepp/">
       <IMG src="http://',$wepphost,'/fswepp/images/fsweppic2.gif"
       width=65 height=65
       align="left" alt="Return to FS WEPP menu" border=0></a>
    <td align=center>
       <h2>WEPP:Road Batch<br>WEPP Forest Road Erosion Predictor</h2>
        <a
          onMouseOver="window.status=\'You takes your chances\';return true"
          onMouseOut="window.status=\'Forest Service WEPP:Road Batch\';return true">
         <img src="/fswepp/images/underc.gif">
        </a><br>
    </td>
    <td>
<!--       <A HREF="http://',$wepphost,'/fswepp/docs/wroadimg.html" target="docs">
       <IMG src="http://',$wepphost,'/fswepp/images/ipage.gif"
        align="right" alt="Read the documentation" border=0></a>
-->
    </table>

    <CENTER>

';
   $glo = $custCli . $user_ID . '*.par';
   if ($debug) {
    print "I am '$me'<br>
     Units: $units<br>
     User_ID: $user_ID<br>
"}

    print '
   <hr>
';

print '
     <FORM name="wrbat" method=post ACTION="http://',$wepphost,'/cgi-bin/fswepp/wr/wrbat.pl#results">
        <a
          onMouseOver="window.status=\'Project title will be displayed on output log\';return true"
          onMouseOut="window.status=\'Forest Service WEPP:Road Batch\'">
      <b>Project title:</b></a>
      <input type="text" name="projectdescription" size=50>
      &nbsp;&nbsp;
';
    if (-e $logFile) {
     print '   <a
          onMouseOver="window.status=\'Display results from your last run (they will be lost with the next run)\';return true"
          onMouseOut="window.status=\'Forest Service WEPP:Road Batch\'">
   <input type="submit" name="old_log" value="Display previous log">
  </a>'
    }
print '    <input type="hidden" name="me" value="',$me,'">',"\n";
print '    <input type="hidden" name="units" value="',$units,'">'; 
print <<'theEnd';
    <hr>

    <table border="1">
     <tr align="top">
      <th bgcolor="lightblue"> <!-- "#85D2D2" -->
       <a href="JavaScript:submitme('Describe Climate')"
             onMouseOver="window.status='Display climate station parameters';return true"
             onMouseOut="window.status='Forest Service WEPP:Road Batch'; return true">
             Climate Station</a>
      </td>
      <td width=10></td>
      <th bgcolor="lightblue">
       <a href="Javascript:popup('/fswepp/wr/soiltexture.html',600,660)"
             onMouseOver="window.status='Describe soil texture';return true"
             onMouseOut="window.status='Forest Service WEPP:Road Batch'; return true"><b>Soil Texture</b></a>  <!-- can't describe; varies with rock content -->
      </th>
      <th bgcolor="lightblue">
       <font face="Arial, Geneva, Helvetica">
        <a
          onMouseOver="window.status='Years to run: 1 to 200'"
          onMouseOut="window.status='Forest Service WEPP:Road Batch'">
        Years to run</a>
       </font>
      </td>
      <th bgcolor="lightblue">
        <a
          onMouseOver="window.status='Put example data into input table, or download Excel template'"
          onMouseOut="window.status='Forest Service WEPP:Road Batch'">
       Example data</a>
      </th>
     </tr>
     <tr>
      <td align=center>
       <select name="Climate" size="4">
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
      print '        <OPTION VALUE="';
      print $climate_file[0];
      print '" selected> '. $climate_name[0] . "\n";
    }
    for $ii (1..$num_cli) {
      print '        <OPTION VALUE="';
      print $climate_file[$ii];
      print '"> '. $climate_name[$ii] . "\n";
    }

#################
print <<'theEnd';
       </SELECT>
       <br>
        <a
          onMouseOver="window.status='Choose from 1600 climate stations, or modify one to suit your needs';return true"
          onMouseOut="window.status='Forest Service WEPP:Road Batch';return true">
         <input type="submit" name="ActionC" value="Custom Climate">
        </a>
      </td>
      <td>
      </td>
      <td align="center">
      <SELECT NAME="SoilType" SIZE="4" 
         onChange="showTexture()"
         onBlur="blankStatus()">
       <OPTION VALUE="clay" SELECTED>clay loam
       <OPTION VALUE="silt">silt loam
       <OPTION VALUE="sand">sandy loam
       <OPTION VALUE="loam">loam
      </SELECT>
     </td>
     <td align="center">
       <input type="text" name="years" size=4 value="30"
           onChange="javascript:checkYears(this.form.years)">
        <br>
        <!-- input type="checkbox" name="extended"> <b>Extended output -->
        <br>
        <!-- input type="button" value="example data" onClick="javascript:example_record()" -->
        <font size=-1>
         Maximum 200 years.<br>
         About 5 sec/run for 30 years.
        </font>
     </td>
     <td align="center">
       <a
          onMouseOver="window.status='Replace data in input table with example run data';return true"
          onMouseOut="window.status='Forest Service WEPP:Road Batch';return true">
        <input type="button" value="Example runs" onClick="javascript:example_record()">
       </a>
      <br><br>
      <font size=-1>
       <a href="/fswepp/wr/wrbtemplate.xls">Excel input template</a>
      </font>
     </td>
    </tr>

   <tr>
    <td align=center>
     <input type="hidden" name="achtung" value="Run WEPP">
    </td>
    <td></td>
    <td></td>
    <td></td>
   </tr>
  </TABLE>
  <P>
<!--                                    -->
theEnd

  print "
   <table border=2>
    <tr>
     <th bgcolor=\"lightblue\">
       <a href=\"javaScript:popup('/fswepp/wr/rddesignb.html',600,700)\"
          onMouseOver=\"window.status='IB: Insloped Bare ditch; IV: Insloped Vegetated ditch; OR: Outsloped Rutted; OU: Outsloped Unrutted';return true\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">Design</a><br>
      (<a
          onMouseOver=\"window.status='Insloped road with bare ditch'\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">'ib'</a>, 
       <a
          onMouseOver=\"window.status='Insloped road with vegetated or rocked ditch'\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">'iv'</a>,<br>
       <a
          onMouseOver=\"window.status='Outsloped rutted road'\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">'or'</a>,
       <a
          onMouseOver=\"window.status='Outsloped unrutted road'\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">'ou'</a>)
     </th>
     <th bgcolor=\"lightblue\">
       <a href=\"javascript:popup('/fswepp/wr/roadsurfb.html',600,700)\"
          onMouseOver=\"window.status='N: Native; G: Gravel; P: Paved';return true\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">Road<br>surface</a><br>
      (<a onMouseOver=\"window.status='Native surface'\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">'n'</a>,
       <a onMouseOver=\"window.status='Gravel surface'\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">'g'</a>,
       <a onMouseOver=\"window.status='Paved surface'\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">'p'</a>)
     </th>
     <th bgcolor=\"lightblue\">
       <a href=\"javascript:popup('/fswepp/wr/traflevlb.html',600,700)\"
          onMouseOver=\"window.status='H: High; L: Low; N: None';return true\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">Traffic<br>level</a><br>
      (<a onMouseOver=\"window.status='High traffic'\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">'h'</a>,
       <a onMouseOver=\"window.status='Low traffic'\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">'l'</a>,
       <a onMouseOver=\"window.status='No traffic'\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">'n'</a>)
     </th>
     <th bgcolor=\"lightblue\">
      <a href=\"javascript:popup('/fswepp/wr/road.html',600,660)\"
          onMouseOver=\"window.status='Decimal percent slope of the water flow path along the road surface';return true\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">Road<br>gradient</a><br>(%)
     </th>
     <th bgcolor=\"lightblue\">
      <a href=\"javascript:popup('/fswepp/wr/road.html',700,660)\"
          onMouseOver=\"window.status='Horizontal length of road segment between successive drainage locations';return true\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">Road<br>length</a><br>($units)
     </th>
     <th bgcolor=\"lightblue\">
      <a href=\"javaScript:popup('/fswepp/wr/road.html',600,660)\"
          onMouseOver=\"window.status='IB, IV: ditch + travelway; OU: travelway; OR: rut spacing + rut width';return true\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">Road<br>width</a><br>($units)</th>
     <th bgcolor=\"lightblue\">
      <a href=\"javascript:popup('/fswepp/wr/fill.html',600,660)\"
          onMouseOver=\"window.status='Decimal percent slope of the fill slope surface';return true\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">Fill<br>gradient</a><br>(%)
     </th>
     <th bgcolor=\"lightblue\">
      <a href=\"javascript:popup('/fswepp/wr/fill.html',600,660)\"
          onMouseOver=\"window.status='Horizontal length of fill slope';return true\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">Fill<br>length</a><br>($units)
     </th>
     <th bgcolor=\"lightblue\">
      <a href=\"javascript:popup('/fswepp/wr/buffer.html',600,660)\"
          onMouseOver=\"window.status='Decimal percent slope of the buffer surface';return true\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">Buffer<br>gradient</a><br>(%)
     </th>
     <th bgcolor=\"lightblue\">
      <a href=\"javascript:popup('/fswepp/wr/buffer.html',600,660)\"
          onMouseOver=\"window.status='Horizontal length of buffer';return true\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">Buffer<br>length</a><br>($units)
     </th>
     <th bgcolor=\"lightblue\">
      <a href=\"javascript:popup('/fswepp/wr/rockcont.html',600,660)\"
          onMouseOver=\"window.status='WEPP reduces the hydraulic conductivity of the soil in direct proportion to the rock content';return true\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">Rock<br>fragment</a><br>(%)
     </th>
     <th bgcolor=\"lightblue\">
      <a
          onMouseOver=\"window.status='You step in the stream, but the water has moved on';return true\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">
      Comments</a>
     </th>
    <tr>
    </tr>
   </table>
";

print <<'theEnd';

      <TEXTAREA name="spread" cols="100" rows="16"></TEXTAREA>
      <br><br>
      <input type="submit" name="ActionW" value="check input">
      <!-- input type="submit" name="ActionW" value="run this puppy" -->
      <!-- input type="submit" name="ActionW" value="check input & run WEPP" -->
      <input type="hidden" name="climate_name">
   <br>
<!-- submit was here -->
   <p>
   <hr>
  </form>

theEnd

  $remote_host = $ENV{'REMOTE_HOST'};
  $remote_address = $ENV{'REMOTE_ADDR'};  # if ($userIP eq '');

  $wc  = `wc ../working/wr.log`;
  @words = split " ", $wc;
  $runs = @words[0];

print '
  <P>
  <table width=100%>
   <tr>
    <td>
     <font face="Arial, Geneva, Helvetica" size=-1>
      WEPP:Road Batch input screen version
      <a href="javascript:popuphistory()">', $version,'</a><br>
      USDA Forest Service Rocky Mountain Research Station<br>
      1221 South Main Street, Moscow, ID 83843<br>',
      "$remote_host &ndash; $remote_address ($user_really) personality '<b>$me</b>'<br>
     </font>
    </td>
    <td>
     <a href=\"http://$wepphost/fswepp/comments.html\" ";
if ($wepphost eq 'localhost')
 {print "\n",'onClick="return confirm(\'You must be connected to the Internet to e-mail comments. Shall I try?\')"'};
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
