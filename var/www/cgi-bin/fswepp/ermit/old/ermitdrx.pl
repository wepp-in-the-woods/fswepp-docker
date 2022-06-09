#!/usr/bin/perl

#
#  ERMiT input screen
#

#  ERMiT.pl -- input screen for ERMiT

#  2002.12.30  DEH add sample result screen for dry ravel
#  2002.11.21  DEH use HTTP_X_FORWARDRD_FOR a user IP if not blank
#  2002.11.12  DEH check HTTP_X_FORWARDED_FOR
#  2002.11.06  DEH added % shrub %grass %bare for range / chaparral
#  2002.08.22  DEH transformed weppdist.pl from "forest"
#  2002.01.08  DEH Removed errant return link ot "dindex.html" & wrap pbs

    $version = '2002.12.30';

#  usage:
#    action = "ermit.pl"
#  parameters:
#    units:             # unit scheme (ft|m)
#    me
#  reads environment variables:
#       HTTP_COOKIE
#       REMOTE_ADDR
#       REMOTE_HOST

#       HTTP_X_FORWARDED_FOR
#       HTTP_CACHE_CONTROL

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

  $http_x_forwarded_for = $ENV{'HTTP_X_FORWARDED_FOR'};
  $http_cache_control = $ENV{'HTTP_CACHE_CONTROL'};

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
    var which = window.document.ermit.SoilType.selectedIndex;
    if (which != 2) {
    }
    else {
      var soiltexture='sandy loam'
      var text='Soil texture: ' + soiltexture
//      alert(text);
      newin = window.open('','dry_ravel','width=600,scrollbars=yes,resizable=yes')                                         
      newin.document.open()
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>Dry ravel prediction</title>')
      newin.document.writeln('  <style>')
      newin.document.writeln('   BODY')
      newin.document.writeln('   {scrollbar-base-color:666666;scrollbar-face-color:#333333;scrollbar-highlight-color:#333333;scrollbar-shadow-color:666666;scrollbar-dark-shadow-color:ffffcc;scrollbar-arrow-color:ff6600}')
      newin.document.writeln('   .question {color:ffffcc}')
      newin.document.writeln('   .header {color:ffffcc}')
      newin.document.writeln('   .highlight {font-weight:bold}')
      newin.document.writeln('  </style>')
      newin.document.writeln(' </HEAD>')
      newin.document.writeln(' <body bgcolor="ivory" onLoad="top.window.focus()" link="white" vlink="white">')
      newin.document.writeln(' <center>')
      newin.document.writeln(' <h3>&quot;Ravel&quot;<br>Dry Ravel Estimator</h3>')
      newin.document.writeln(' <p>')
      newin.document.writeln(' <table border=1>')
      newin.document.writeln('  <tr><td align="right">')
      newin.document.writeln('    Soil texture:<td>sandy loam</td></tr>')
      newin.document.writeln('  <tr><td align="right">')
      newin.document.writeln('    Rock fragment:<td> 20%</td></tr>')
      newin.document.writeln('  <tr><td align="right">')
      newin.document.writeln('    Top gradient:<td>0%</td></tr>')
      newin.document.writeln('  <tr><td align="right">')
      newin.document.writeln('    Middle gradient:<td>65%</td></tr>')
      newin.document.writeln('  <tr><td align="right">')
      newin.document.writeln('    Toe gradient:<td>40%</td></tr>')
      newin.document.writeln('  <tr><td align="right">')
      newin.document.writeln('    Fire severity:<td>High</td></tr>')
      newin.document.writeln('  </table>')
      newin.document.writeln(' <p>')
      newin.document.writeln('Given the proper climate:')
      newin.document.writeln(' <p>')
      newin.document.writeln('<font color="green">No ravel detected for top portion</font><br>')
      newin.document.writeln('<font color="red">Ravel detected for middle portion</font><br>')
      newin.document.writeln('<font color="red">Ravel detected for toe portion</font><br>')
      newin.document.writeln('<font color="red">Sediment will be delivered off-site</font><br>')
      newin.document.writeln('<p>')
      newin.document.writeln('<font color="purple">NOTE: The following figures are made up.</font>')
      newin.document.writeln('<p>')
      newin.document.writeln('<table border=1 cellpadding=5>')
      newin.document.writeln(' <tr>')
      newin.document.writeln('  <th bgcolor="85d2f2">Trigger<br>level<br></th>')
      newin.document.writeln('  <th bgcolor="85d2f2">Sediment<br> transported<br>(t ha<sup>-1</sup>)</th>')
      newin.document.writeln('  <th bgcolor="85d2f2">Sediment<br> delivered off-site<br>(t ha<sup>-1</sup>)</th>')
      newin.document.writeln(' </tr>')
      newin.document.writeln(' <tr>')
      newin.document.writeln('  <th bgcolor="85d2f2">None</th>')
      newin.document.writeln('  <th>36</th>')
      newin.document.writeln('  <th>36</th>')
      newin.document.writeln(' </tr>')
      newin.document.writeln(' <tr>')
      newin.document.writeln('  <th bgcolor="85d2f2">Low</th>')
      newin.document.writeln('  <th>45</th>')
      newin.document.writeln('  <th>45</th>')
      newin.document.writeln(' </tr>')
      newin.document.writeln(' <tr>')
      newin.document.writeln('  <th bgcolor="85d2f2">Moderate</th>')
      newin.document.writeln('  <th>54</th>')
      newin.document.writeln('  <th>54</th>')
      newin.document.writeln(' </tr>')
      newin.document.writeln(' <tr>')
      newin.document.writeln('  <th bgcolor="85d2f2">High</th>')
      newin.document.writeln('  <th>63</th>')
      newin.document.writeln('  <th>63</th>')
      newin.document.writeln(' </tr>')
      newin.document.writeln('</table>')
      newin.document.writeln('<p>')
      newin.document.writeln('<!--tool bar begins--><p>')
      newin.document.writeln('  <table bgcolor="#666666" width="20%" border="0" cellspacing="1" cellpadding="5" align="center">')
      newin.document.writeln('   <tr>')
      newin.document.writeln('    <td align="center" bgcolor="#333333" onMouseOver="this.style.backgroundColor=\'#000000\';" onMouseOut="this.style.backgroundColor=\'\';"><font face="verdana,arial,helvetica" size="1"><img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.print()">Print me</a></font></td>')
      newin.document.writeln('    <td align="center" bgcolor="#333333" onMouseOver="this.style.backgroundColor=\'#000000\';" onMouseOut="this.style.backgroundColor=\'\';"><font face="verdana,arial,helvetica" size="1"><img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.close()">Close me</a></font></td>')
      newin.document.writeln('   </tr>')
      newin.document.writeln('  </table>')
      newin.document.writeln('<!--tool bar ends-->')
      newin.document.writeln('  </center>')
      newin.document.writeln(' </body>')
      newin.document.writeln('</html>')
      newin.document.close()
    }
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
    {
     text = 'Native-surface roads on shales and similar decomposing sedimentary rock (MH, CH)';
     buttontext='(no dry ravel)'
    }
  else if (which == 1)       // silt loam
    {
     text = 'Glacial outwash areas; finer-grained granitics (SW, SP, SM, SC)';
     buttontext = '(no dry ravel)'
    }
  else if (which == 2)       // sandy loam
    {
     text = 'Ash cap native-surface road; alluvial loess native-surface road (ML, CL)'
     buttontext='Check for ravel'
    }
  else                       // loam
    {
     text = 'Loam';
     buttontext='(no dry ravel)'
    }
  window.status = text
  window.document.ermit.ravel.value=buttontext
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
<input type="hidden" size="1" name="me" value="',$me,'">
<input type="hidden" size="1" name="units" value="',$units,'">
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
       <td align=center>
      <input type="hidden" name="achtung" value="Run WEPP">
      <input type="SUBMIT" name="actionc" value="Custom Climate">
       </td>
       <td align="center">
     <INPUT type="submit" name="ravel" value="(no dry ravel)"
       onClick="javascript:ravelcheck(); return false;">
       </td>
      </tr>
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
      <td>                                  
        <select name="vegetation" size="4" align="top"
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
      <td><input type="radio" name="severity" value="h" checked="checked"> <b>High</b><br>
          <input type="radio" name="severity" value="m"> <b>Moderate</b><br>
          <input type="radio" name="severity" value="l"> <b>Low</b><br>
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
<input type="hidden" name="climate_name">
  <BR>
    </b>
    <p>
<INPUT TYPE="hidden" NAME="Units" VALUE="m">
     <INPUT TYPE="SUBMIT" name="actionw" VALUE="Run ERMiT"
       onClick='RunningMsg(this.form.actionw,"Running ERMiT..."); this.form.achtung.value="Run WEPP"'>
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
 <a href="http://',$wepphost,'/fswepp/history/ermver.html">',$version,'</a>
 (for review only) by David Hall, 
Project Leader
Bill Elliot<BR>
USDA Forest Service, Rocky Mountain Research Station, Moscow, ID
83843<br>';
  print "Host: $remote_host &ndash; Address: $remote_address &ndash;
  Forwarded for: $http_x_forwarded_for
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
