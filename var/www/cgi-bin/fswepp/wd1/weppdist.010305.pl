#!/usr/bin/perl

#
#  Disturbed WEPP input screen
#

#  weppdist.pl -- input screen for Disturbed WEPP

#  2001.03.05   Filter climate names on $user_ID_ instead of $user_ID
#  2000.10.13  DEH added more EXPLAIN links; into documentation
#		   move climate symbols into documentation
#		   add graphic for slope explanation
#  2000.09.15a Add capability to read PUBLIC (!) climates
#  2000.09.15  Filter on $user_ID for PERSONAL (*) climates
#  2000.08.22  Switched from [glob] to DIY climate file name extraction
#                following lead in wepproad.pl
#              Updated personal climate search a'la wepproad.pl

    $version = '2001.03.05';

#  usage:
#    action = "weppdist.pl"
#  parameters:
#    units:             # unit scheme (ft|m)
#    me
#  reads environment variables:
#       HTTP_COOKIE
#       REMOTE_ADDR
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
    else {$units = 'm'; $areaunits='ha'}
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
    $public = $working . 'public/';			# DEH 09/21/2000
    $user_ID=$ENV{'REMOTE_ADDR'};
    $user_ID =~ tr/./_/;
    $user_ID = $user_ID . $me;				# DEH 03/05/2001
    $user_ID_ = $user_ID . '_';				# DEH 03/05/2001
    $logFile = $working . $user_ID . '.log';
    $cliDir = '../climates/';
    $custCli = $working . $user_ID . '_';		# DEH 03/05/2001
  }

########################################

    $num_cli=0;
### get published climates, if any

    opendir PUBLICDIR, $public;                      
    @allpfiles=readdir PUBLICDIR;                     
    close PUBLICDIR;                                  

    for $f (@allpfiles) {                             
      if (substr($f,-4) eq '.par') {                  
        $f = $public . $f;				# DEH 09/22/2000
        open(M,"<$f") || goto vskip;                 
          $station = <M>;
        close (M);
        $climate_file[$num_cli] = substr($f, 0, -4);
        $clim_name = '- ' . substr($station, index($station, ":")+2, 40);
        $clim_name =~ s/^\s*(.*?)\s*$/$1/;
        $climate_name[$num_cli] = $clim_name;
        $num_cli += 1;
vskip:                                                  
      }                                                 
    }

### get personal climates, if any

    opendir CLIMDIR, $working;                          # DEH 06/14/2000
    @allpfiles=readdir CLIMDIR;                         # DEH 05/05/2000
    close CLIMDIR;                                      # DEH 05/05/2000

#   @fileNames = glob($custCli . '*.par');
#   for $f (@fileNames) {
    for $f (@allpfiles) {                               # DEH 05/05/2000
      if (index($f,$user_ID_)==0) {			# DEH 03/05/2001
        if (substr($f,-4) eq '.par') {                  # DEH 05/05/2000
          $f = $working . $f;                           # DEH 06/14/2000
          open(M,"<$f") || goto pskip;                  # DEH 05/05/2000
            $station = <M>;
          close (M);
#  print STDERR "$f\n";
          $climate_file[$num_cli] = substr($f, 0, -4);
          $clim_name = '* ' . substr($station, index($station, ":")+2, 40);
          $clim_name =~ s/^\s*(.*?)\s*$/$1/;
          $climate_name[$num_cli] = $clim_name;
          $num_cli += 1;
        }						# DEH 09/15/2000
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
<title>Disturbed WEPP</title>
  <!--<bgsound src="/journey.wav">-->
  <!--<bgsound src="V0PD3ECG.au">-->
  <SCRIPT LANGUAGE = "JavaScript" type="TEXT/JAVASCRIPT">
  <!--

  function submitme(which) {
    document.forms.weppdist.achtung.value=which
//    document.forms.weppdist.submit.value="Describe"
    document.forms.weppdist.submit()
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
       <A HREF="https://',$wepphost,'/fswepp/docs/distweppdoc.html" target="_documentation">
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
       <B>             Climate</B> 
       <br>[
       <a href="JavaScript:submitme('Describe Climate')"
             onMouseOver="window.status='Describe climate';return true"
             onMouseOut="window.status='Forest Service Disturbed WEPP'; return true">
             Describe</a> ]
       [
       <a href="/fswepp/wd/clisymbols.html" target="_popup"
             onMouseOver="window.status='Explain symbols (new window)';return true"
             onMouseOut="window.status='Forest Service Disturbed WEPP'; return true">
             Explain</a> ]
       <th width=20 rowspan=3><br>
  <TD align="center" bgcolor="85d2d2">
    <B>               Soil Texture</b>
    <br>[
    <a href="JavaScript:submitme('Describe Soil')"
             onMouseOver="window.status='Describe soil';return true"
             onMouseOut="window.status='Forest Service Disturbed WEPP'; return true">
             Describe</a> ]
       [
       <a href="/fswepp/docs/distweppdoc.html#texture" target="_popup"
             onMouseOver="window.status='Explain treatment (new window)';return true"
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
<tr><th bgcolor=85d2d2>Element
    <th bgcolor=85d2d2>Treatment <br>
       [
       <a href="/fswepp/docs/distweppdoc.html#treatment" target="_popup"
             onMouseOver="window.status='Explain treatment (new window)';return true"
             onMouseOut="window.status='Forest Service Disturbed WEPP'; return true">
             Explain</a> ]
    <th bgcolor=85d2d2>Gradient (%) <br>
       [
       <a href="/fswepp/docs/distweppdoc.html#topography" target="_popup"
             onMouseOver="window.status='Explain gradient (new window)';return true"
             onMouseOut="window.status='Forest Service Disturbed WEPP'; return true">
             Explain</a> ]

theEnd
print "    <th bgcolor=85d2d2>Length ($units)
           <th bgcolor=85d2d2>Area ($areaunits)
           <th bgcolor=85d2d2>Cover (%)\n";
print <<'theEnd';
       <br> [
       <a href="/fswepp/docs/distweppdoc.html#cover" target="_popup"
             onMouseOver="window.status='Explain Cover (new window)';return true"
             onMouseOut="window.status='Forest Service Disturbed WEPP'; return true">
             Explain</a> ]
 <tr><th rowspan=2 bgcolor=85d2d2>Upper
    <TD rowspan=2>
    <SELECT NAME="UpSlopeType" SIZE="4" ALIGN="top" onChange="pcover1()";>
     <OPTION VALUE="tree20" selected> Twenty year old forest
     <OPTION VALUE="tree5"> Five year old forest
     <OPTION VALUE="shrub"> Shrubs
     <OPTION VALUE="tall"> Tall Grass
     <OPTION VALUE="short"> Short Grass
     <OPTION VALUE="low"> Low Severity Fire
     <OPTION VALUE="high"> High Severity Fire
     <OPTION VALUE="skid"> Skid trail
    </SELECT>
    <td><input type="text" size=5 name="ofe1_top_slope" value="0">
    <td rowspan=2><input type="text" size=5 name="ofe1_length" value="50">
    <td rowspan=4><input type="text" size=5 name="ofe_area" value="10">
    <td rowspan=2><input type="text" size=5 name="ofe1_pcover" value="100">
 <tr><td><input type="text" size=5 name="ofe1_mid_slope" value="30">
 <tr><th rowspan=2 bgcolor=85d2d2>Lower
 <TD rowspan=2>
    <SELECT NAME="LowSlopeType" SIZE="4" ALIGN="top" onChange="pcover2()";>
     <OPTION VALUE="tree20"> Twenty year old forest
     <OPTION VALUE="tree5" selected> Five year old forest
     <OPTION VALUE="shrub"> Shrubs
     <OPTION VALUE="tall"> Tall Grass
     <OPTION VALUE="short"> Short Grass
     <OPTION VALUE="low"> Low Severity Fire
     <OPTION VALUE="high"> High Severity Fire
     <OPTION VALUE="skid"> Skid trail
    </SELECT>
    <td><input type="text" size=5 name="ofe2_top_slope" value="30">
    <td rowspan=2><input type="text" size=5 name="ofe2_length" value="50">
    <td rowspan=2><input type="text" size=5 name="ofe2_pcover" value="100">
 <tr><td><input type="text" size=5 name="ofe2_bot_slope" value="5">
</TABLE>

<BR>
   <input type=hidden name="climate_name">
<!-- .... Summary output...
<INPUT TYPE="CHECKBOX" NAME="Full" VALUE="1">Full output
<INPUT TYPE="CHECKBOX" NAME="Slope" VALUE="1">Slope file input -->
<BR>
<B>Years to simulate:</B> <input type="text" size="3" name="climyears" value="30"><br>
<b><input type=checkbox name="Full" value=1>
theEnd
print "
<a onMouseOver=\"window.status='Return WEPP annual summary output report';return true;\"
             onMouseOut=\"window.status='';return true;\">Extended output</a>
";
print <<'theEnd';
</b>
<p>
<!--<INPUT TYPE="SUBMIT" name="actionw" VALUE="Run WEPP"
    onClick='RunningMsg(this.form.actionw,"Running..."); this.form.achtung.value="Run WEPP"'>
-->
<P>
<INPUT TYPE="HIDDEN" NAME="Units" VALUE="m">
<input type="SUBMIT" name="actionv" value="Calibrate vegetation"
       onClick='RunningMsg(this.form.actionv,"Calibrating vegetation..."); this.form.achtung.value="vegetation"'>
<INPUT TYPE="SUBMIT" name="actionw" VALUE="Run WEPP"
       onClick='RunningMsg(this.form.actionw,"Running WEPP..."); this.form.achtung.value="Run WEPP"'>
<!--<input type="button" value="Exit" onClick="window.close(self)">-->
<BR>
</center>
</FORM>
<P>
<HR>
theEnd
print '
<a href="https://',$wepphost,'/fswepp/comments.html" ';
if ($wepphost eq 'localhost') {print 'onClick="return confirm(\'You must be connected to the Internet to 
e-mail comments. Shall I try?\')"'};                                  
print '>                                                              
<img src="https://',$wepphost,'/fswepp/images/epaemail.gif" align="right" border=0>
</a>
Interface v. 
 <a href="https://',$wepphost,'/fswepp/history/wdver.html"> ',$version,'</a>
 (for review only) by
 <A HREF="mailto:dhall@forest.moscowfsl.wsu.edu">Hall</A>, 
Project leader
 <A HREF="mailto:belliot@forest.moscowfsl.wsu.edu">Bill Elliot</A><BR>
USDA Forest Service, Rocky Mountain Research Station, Moscow, ID 83843
</body>
</html>
';

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

