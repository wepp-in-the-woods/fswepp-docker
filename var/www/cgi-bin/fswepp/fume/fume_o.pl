#! /usr/bin/perl
###! /fsapps/fssys/bin/perl
#!C:\Perl\bin\perl.exe T-w

#use strict;
use CGI ':standard';

#
#  Fuel Management Erosion (FuME) Analysis input screen
#
#  Based on Disturbed WEPP and WEPP:Road
#
#  fume.pl -- input screen for FuMe
#  based on weppdiro.pl
#  by David Hall and Elena Velasquez

## BEGIN HISTORY ###################################
## WEPP FuMe Input version history

   $version='2009.09.17';	# Adjust FSWEPPuser personality
#  $version='2006.04.27';	# Remove planting operation in management file
#  $version='2005.04.29';	# Allow hillslope gradients up to 90% (was 60%)
#  $version='2005.03.16';	# Report user IP and personality<br>Report no. runs<br>Credit Pete Robichaud
#! $version='2005.02.09';	# Switch to live history subroutine
#  $version = '2005.01.12';	# Production runs: change to 50 years climate
#! $version=2004.12.01 DEH;	# Fix RunningMsg variable names so no JS warning
#! $version =2004.12.01;	# add </body> at end
#! $version =2004.11.19 DEH;	# add code from ERMiT to actually allow public climates
#  $version = '2004.11.02';	# Beta release; for Missoula presentation
#! $version =2004.11.02 DEH;	# add helps, move [road density]
#! $version =2004.09.24 DEH;	# change bounds for input checks
#! $version =2004.09.21 DEH;	# Fix return ($fume) from Custom Climate call

# 2004.09.17 DEH Adjust for changed FSWEPPuser reference
# 2004.09.21		  	Add work-around for NAT ($user_really)
# 2004.08.17 DEH Explanations to status line; try question marks (modified terraserver gif)
# 2004.01.13 DEH '2003' to '2004' runs
# 2003.09.18 DEH Clean up fonts
# 2003.09.18                Remove "cleaned logs and climates" note (finally!)
# 2003.01.01 DEH Remove "mailto:" link (welliot)
# 2003.01.01                Fix close of "Host"
# 2003.01.01                Add "cleaned logs and climates" note
# 2002.01.08 DEH Removed errant return link of "dindex.html" & wrap pbs
# 2001.10.10 SDA Removed AREA input, added ROCK FRAGMENT inputs
# 2001.04.24 DEH Changed upper, lower treatment display 4 to 8
# 2001.04.24 DEH [forest's 2000.10.13]
# 2001.04.24             DEH added more EXPLAIN links; into documentation
#      to do:      move climate explanation into documentation
#      to do:      add graphic for slope explanation           
# 2001.04.10 DEH add checkYears to # yrs (from WEPP:Road)
#	        add call to checkYears
#		and call to existing showRange
#		add minyears, maxyears, defyears
#		add isNumber (existing call in CheckRange)
# 2001.03.05 DEH fix $user_ID
# 2000.12.05 DEH move documentation target to separate "docs" window
# 2000.11.27 Update contact e-mails (Hall & Elliot)
# 2000.09.15a Add capability to read PUBLIC (!) climates [03/02/2001]
# 2000.09.15 Filter on $user_ID again for personal climates
# 2000.08.22 Switched from [glob] to DIY climate file name extraction
#                following lead in wepproad.pl
#             Updated personal climate search a'la wepproad.pl
## END HISTORY ###################################

#  usage:
#    action = "fume.pl"
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
#    /Scripts/fswepp/wr/wr.pl
#    /Scripts/fswepp/wr/logstuff.pl
#  popup links:
#    /fswepp/wr/wrwidths.html
#    /fswepp/wr/rddesign.html

#  FSWEPP, USDA Forest Service, Rocky Mountain Research Station, 
#  Soil & Water Engineering
#  Science by Bill Elliot et alia
#  Code by David Hall 
print "Content-type: text/html\n\n";


    $cookie = $ENV{'HTTP_COOKIE'};
    $sep = index ($cookie,"FSWEPPuser=");
    $me = "";
    if ($sep > -1) {$me = substr($cookie,$sep+11,1)}
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
    close Host;
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
#    else {$working = 'c:\\working'}
    else {$working = 'c:\\Inetpub\\Scripts\\fswepp\\working'}       #elena
    $public = $working . '\\public'; 
    $logFile = "$working\\wdwepp.log";
#    $cliDir = '..\\climates\\';
    $cliDir = 'c:\\Inetpub\\Scripts\\fswepp\\climates\\'; #elena
    $custCli = "$working\\";
  }
  else {
    $working='../working/';                             # DEH 08/22/2000
    $public = $working . 'public/';                     # DEH 09/21/2000
    $user_ID = $ENV{'REMOTE_ADDR'};
    $user_really = $ENV{'HTTP_X_FORWARDED_FOR'};        # 2004.09.21 DEH
    $user_ID = $user_really if ($user_really ne '');    # 2004.09.21 DEH
    $user_ID =~ tr/./_/;
    $user_ID = $user_ID . $me . '_';			# DEH 03/05/2001
#    $logFile = '../working/' . $user_ID . '.log';	# 2004.09.21 DEH
    $cliDir = '../climates/';                         
    $custCli = '../working/' . $user_ID;		# DEH 03/02/2001
  }

########################################

    $num_cli=0;

### get public climates, if any

    opendir PUBLICDIR, $public;
    @allpfiles=readdir PUBLICDIR;
    close PUBLICDIR;

    for $f (@allpfiles) {
      if (substr($f,-4) eq '.par') {
        $f = $public . $f;
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

    for $f (@allpfiles) {                               # DEH 05/05/2000

      if (index($f,$user_ID)==0) {	        # DEH 09/15/2000
        if (substr($f,-4) eq '.par') {                  # DEH 05/05/2000
#         $f = $custCli . $f;                           # DEH 06/14/2000
          $f = $working . $f;                           # DEH 07/15/2004
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

#     opendir CLIMDIR, 'C:\Inetpub\Scripts\fswepp\climates'; #elena
    opendir CLIMDIR, $cliDir;                            #elena
    @allfiles=readdir CLIMDIR;                          # DEH 05/05/2000
#    print "<p>this are the files in the directory:@allfiles";  #elena
    close CLIMDIR;                                      # DEH 05/05/2000

    for $f (@allfiles) { #print "<p>this is f before: $f";          # DEH 05/05/2000 elena
#      $f = '../climates/' . $f;                         # DEH 05/05/2000 elena
#      $f = 'C:\Inetpub\Scripts\fswepp\climates' . $f;    #elena
       $f = $cliDir . $f;
#      $try = substr($f,-4); #elena
      if (substr($f,-4) eq '.par') {                    # DEH 05/05/2000
        open(M,"<$f") || goto sskip;                       # DEH 05/05/2000
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

#print "Content-type: text/html\n\n";
print <<'theEnd0';
<html>
 <head>
  <title>WEPP FuMe: Fuel Management Erosion Analysis</title>
  <META http-equiv="Content-Type" content="text/html; charset=utf-8">
  <META NAME="Name" CONTENT="WEPP FuME">
  <META NAME="Brief Description" CONTENT="WEPP FuME (Fuel Management Erosion Analysis), a component of FS WEPP, predicts soil erosion associated with fuel management practices including prescribed fire, thinning, and a road network, and compares that prediction with erosion from wildfire.">
  <META NAME="Status" CONTENT="Under development; beta released 2004">
  <META NAME="Updates" CONTENT="Ongoing, online">
  <META NAME="Inputs" CONTENT="Climate station; soil texture; road density; hillslope length and gradient; buffer length; wildfire, prescribed fire, and thinning return periods">
  <META NAME="Outputs" CONTENT="Sediment delivery in year of disturbance and 'average' annual hillslope sedimentation for undisturbed forest, wildfire, prescribed fire, thinning, and low and high access roads; descriptive summary of analysis">
  <META NAME="Suggested user" CONTENT="">
  <META NAME="Suggested use" CONTENT="">
  <META NAME="Keywords" CONTENT="">
  <META NAME="Contributors" CONTENT="USDA Forest Service, Rocky Mountain Research Station, Moscow, ID: model developed by Bill Elliot and Pete Robichaud; interface programming by David Hall and Elena Velasquez">
  <META NAME="Source" content="Run online at http://forest.moscowfsl.wsu.edu/fswepp/">


  <SCRIPT LANGUAGE = "JavaScript" type="TEXT/JAVASCRIPT">
  <!--

  var minyear=1, defyear=5, maxyear=200
  var total_l_min=1.1, total_l_def=200, total_l_max=1500	// total hill length
  var buff_l_min=1, buff_l_def=50, buff_l_max=1000	// buffer length
// var hill_g_min=0.5, hill_g_def= 30, hill_g_max=60	// hillslope gradient
  var hill_g_min=0.5, hill_g_def= 30, hill_g_max=90	// hillslope gradient 2005.04.29
  var wfc_min=1, wfc_def=40, wfc_max=400		// wildfire cycle
  var fmc_min=1, fmc_def=20, fmc_max=200		// fuel management cycle
  var rd_den_min=0, rd_den_def=4, rd_den_max=20		// road density

    function lengths_changed() {
// recalculate hillslope horizontal length
// recalculate pixel widths for bffer and hillslope length representations
      totalpixels  = document.total.width * 1
      bufferlength = document.fume.buffl.value * 1
      totallength  = document.fume.totall.value * 1
       if (bufferlength>=totallength) {
     alert('Buffer length (' + bufferlength + ') must be less than total length (' + totallength + ')')
         bufferlength=totallength-0.1
         if (bufferlength<buff_l_min) {bufferlength=buff_l_min; totallength=bufferlength+0.1}
//       document.fume.hilll.value=0
         document.fume.buffl.value=bufferlength
         document.fume.hilll.value=totallength
       }
      hilllength   = totallength - bufferlength
      bufferpixels = totalpixels * bufferlength / totallength
      hillpixels   = totalpixels - bufferpixels
      document.fume.hilll.value=hilllength
      document.buffer.width=bufferpixels
      document.hillslope.width=hillpixels
    }

  function popuphistory() {
    height=500;
    width=660;
    pophistory = window.open('','pophistory','toolbar=no,location=no,status=no,directories=no,menubar=no,scrollbars=yes,resizable=yes,width='+width+',height='+height);
theEnd0
    print make_history_popup();
print <<'theEnd';
    pophistory.document.close()
    pophistory.focus()
  }

  function submitme(which) {
    document.forms.fume.achtung.value=which
//    document.forms.weppdiro.submit.value="Describe"
    document.forms.fume.submit()
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

  function explain_topo() {
    newin = window.open('','topo','width=640,scrollbars=yes,resizable=1')
    var newWin = newin.document.open()
    if (newWin != null) {
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>FS WEPP FuME topography</title>')
      newin.document.writeln('  <style>')
      newin.document.writeln('   BODY')
      newin.document.writeln('   {scrollbar-base-color:666666;scrollbar-face-color:#333333;scrollbar-highlight-color:#333333;scrollbar-shadow-color:666666;scrollbar-dark-shadow-color:ffffcc;scrollbar-arrow-color:ff6600}')
      newin.document.writeln('   .question {color:ffffcc}')
      newin.document.writeln('   .header {color:ffffcc}')
      newin.document.writeln('   .highlight {font-weight:bold}')
      newin.document.writeln('  </style>')
      newin.document.writeln(' </HEAD>')
      newin.document.writeln(' <body bgcolor="ivory" onLoad="top.window.focus()" link="#99ff00" vlink="#99ff00" text="#006009">')
      newin.document.writeln('  <font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('   <table width=100%>')
      newin.document.writeln('    <tr><td bgcolor="#99ff00" align="center">')
      newin.document.writeln('     <font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('      <h3>FS WEPP FuME topography</h3>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td></tr>')
      newin.document.writeln('   </table>')
      newin.document.writeln('   In the topography fields, the user is asked to input values for a typical horizontal slope length and steepness.')
      newin.document.writeln('   Slope lengths and steepnesses can be obtained from field surveys or contour maps.')
      newin.document.writeln('   Users may also have access to GIS topographic analysis tools to aid in estimating these values,')
      newin.document.writeln('   providing average values, or determining a range of topographic values to consider.')
      newin.document.writeln('   <br><br>')
      newin.document.writeln('   The hillslope gradients represent the top of the hill,')
      newin.document.writeln('   the overall average steepness, and')
      newin.document.writeln('   the gradient of the toe of the hill.')
      newin.document.writeln('   The top of the hill is zero if the area of interest starts at the crest of the hill.')
      newin.document.writeln('   It is likely the same as the average hillslope gradient if the treated area starts midslope.')
      newin.document.writeln('   The toe of the specified hillslope should be located in a channel.')
      newin.document.writeln('   <br><br>')
      newin.document.writeln('   The user enters <b>total hillslope horizontal length</b> and')
      newin.document.writeln('   <b>buffer horizontal length</b>.')
      newin.document.writeln('   <b>Treated hillslope horizontal length</b> is calculated by the program as the difference between these two entered values.')
      newin.document.writeln('   <br><br>')
      newin.document.writeln('   Hillslope horizontal length is the length of a hillslope as projected on a map.')
      newin.document.writeln('   <br><br>')
      newin.document.writeln('   <center>')
      newin.document.writeln('    <img src="/fswepp/images/fume/fume_topo.gif" width=320 height=220>')
      newin.document.writeln('    <br>')
      newin.document.writeln('    Cross section of a generic FuME hillslope')
      newin.document.writeln('   </center>')
      newin.document.writeln('<!--tool bar begins--><p>')
      newin.document.writeln('  <table bgcolor="#666666" width="20%" border="0" cellspacing="1" cellpadding="5" align="center">')
      newin.document.writeln('   <tr>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      newin.document.writeln(' onMouseOver="this.style.backgroundColor=\'#000000\';"')
      newin.document.writeln(' onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln(' <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln(' <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.print()">Print me</a>')
      newin.document.writeln(' </font>')
      newin.document.writeln('</td>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      newin.document.writeln(' onMouseOver="this.style.backgroundColor=\'#000000\';"')
      newin.document.writeln(' onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln(' <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln('  <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.close()">Close me</a>')
      newin.document.writeln(' </font>')
      newin.document.writeln('</td>')
      newin.document.writeln('   </tr>')
      newin.document.writeln('  </table>')
      newin.document.writeln('<!--tool bar ends-->')
      newin.document.writeln('  </center>')
      newin.document.writeln(' </body>')
      newin.document.writeln('</html>')
      newin.document.close()
    } 
  }

  function explain_road_density() {
    newin = window.open('','road_density','width=640,scrollbars=yes,resizable=1')
    var newWin = newin.document.open()
    if (newWin != null) {
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>FS WEPP FuME road density</title>')
      newin.document.writeln('  <style>')
      newin.document.writeln('   BODY')
      newin.document.writeln('   {scrollbar-base-color:666666;scrollbar-face-color:#333333;scrollbar-highlight-color:#333333;scrollbar-shadow-color:666666;scrollbar-dark-shadow-color:ffffcc;scrollbar-arrow-color:ff6600}')
      newin.document.writeln('   .question {color:ffffcc}')
      newin.document.writeln('   .header {color:ffffcc}')
      newin.document.writeln('   .highlight {font-weight:bold}')
      newin.document.writeln('  </style>')
      newin.document.writeln(' </HEAD>')
      newin.document.writeln(' <body bgcolor="ivory" onLoad="top.window.focus()" link="#99ff00" vlink="#99ff00" text="#006009">')
      newin.document.writeln('  <font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('   <table width=100%>')
      newin.document.writeln('    <tr><td bgcolor="#99ff00" align="center">')
      newin.document.writeln('     <font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('      <h3>FS WEPP FuME road density</h3><br>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td></tr>')
      newin.document.writeln('   </table>')
      newin.document.writeln('   Road density is the number of miles of road per square mile of watershed.')
      newin.document.writeln('   Road segments more than 200 ft (60 m) from ephemeral or perennial channels generally can be ignored.')
      newin.document.writeln('<!--tool bar begins--><p>')
      newin.document.writeln('  <table bgcolor="#666666" width="20%" border="0" cellspacing="1" cellpadding="5" align="center">')
      newin.document.writeln('   <tr>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      newin.document.writeln(' onMouseOver="this.style.backgroundColor=\'#000000\';"')
      newin.document.writeln(' onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln(' <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln(' <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.print()">Print me</a>')
      newin.document.writeln(' </font>')
      newin.document.writeln('</td>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      newin.document.writeln(' onMouseOver="this.style.backgroundColor=\'#000000\';"')
      newin.document.writeln(' onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln(' <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln('  <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.close()">Close me</a>')
      newin.document.writeln(' </font>')
      newin.document.writeln('</td>')
      newin.document.writeln('   </tr>')
      newin.document.writeln('  </table>')
      newin.document.writeln('<!--tool bar ends-->')
      newin.document.writeln('  </center>')
      newin.document.writeln(' </body>')
      newin.document.writeln('</html>')
      newin.document.close()
    } 
  }

  function explain_frequency() {
    newin = window.open('','frequency','width=640,scrollbars=yes,resizable=1')
    var newWin = newin.document.open()
    if (newWin != null) {
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>FS WEPP FuME disturbance return period</title>')
      newin.document.writeln('  <style>')
      newin.document.writeln('   BODY')
      newin.document.writeln('   {scrollbar-base-color:666666;scrollbar-face-color:#333333;scrollbar-highlight-color:#333333;scrollbar-shadow-color:666666;scrollbar-dark-shadow-color:ffffcc;scrollbar-arrow-color:ff6600}')
      newin.document.writeln('   .question {color:ffffcc}')
      newin.document.writeln('   .header {color:ffffcc}')
      newin.document.writeln('   .highlight {font-weight:bold}')
      newin.document.writeln('  </style>')
      newin.document.writeln(' </HEAD>')
      newin.document.writeln(' <body bgcolor="ivory" onLoad="top.window.focus()" link="#99ff00" vlink="#99ff00" text="#006009">')
      newin.document.writeln('  <font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('   <table width=100%>')
      newin.document.writeln('    <tr><td bgcolor="#99ff00" align="center">')
      newin.document.writeln('     <font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('      <h3>FS WEPP FuME disturbance return period</h3>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td></tr>')
      newin.document.writeln('   </table>')
      newin.document.writeln('   The <b>disturbance return periods</b> are the number of years between')
      newin.document.writeln('   severe wildfire occurrence for the forest,')
      newin.document.writeln('   the planned period between prescribed fire treatments,')
      newin.document.writeln('   and the planned period between thinning treatments.')
      newin.document.writeln('   <br><br>')
      newin.document.writeln('   <b>Wildfire cycles</b> will likely range from 20 years for low elevation, dry forests, to')
      newin.document.writeln('   200 years for high elevation moist forests, to')
      newin.document.writeln('   300 years for very wet forests on the west slopes of the Cascades or the Coastal ranges.')
      newin.document.writeln('   <br><br>')
      newin.document.writeln('   <b>Prescribed fire cycles</b> can vary from 2 to 40 years, or more.')
      newin.document.writeln('   <br><br>')
      newin.document.writeln('   <b>Thinning cycles</b> vary from 10 to 80 years.')
      newin.document.writeln('<!--tool bar begins--><p>')
      newin.document.writeln('  <table bgcolor="#666666" width="20%" border="0" cellspacing="1" cellpadding="5" align="center">')
      newin.document.writeln('   <tr>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      newin.document.writeln(' onMouseOver="this.style.backgroundColor=\'#000000\';"')
      newin.document.writeln(' onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln(' <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln(' <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.print()">Print me</a>')
      newin.document.writeln(' </font>')
      newin.document.writeln('</td>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      newin.document.writeln(' onMouseOver="this.style.backgroundColor=\'#000000\';"')
      newin.document.writeln(' onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln(' <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln('  <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.close()">Close me</a>')
      newin.document.writeln(' </font>')
      newin.document.writeln('</td>')
      newin.document.writeln('   </tr>')
      newin.document.writeln('  </table>')
      newin.document.writeln('<!--tool bar ends-->')
      newin.document.writeln('  </center>')
      newin.document.writeln(' </body>')
      newin.document.writeln('</html>')
      newin.document.close()
    } 
  }

  function explain_soil_texture () {

    newin = window.open('','soil_texture','width=640,scrollbars=yes,resizable=1')
    var newWin = newin.document.open()
    if (newWin != null) {
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>FS WEPP soil textures</title>')
      newin.document.writeln('  <style>')
      newin.document.writeln('   BODY')
      newin.document.writeln('   {scrollbar-base-color:666666;scrollbar-face-color:#333333;scrollbar-highlight-color:#333333;scrollbar-shadow-color:666666;scrollbar-dark-shadow-color:ffffcc;scrollbar-arrow-color:ff6600}')
      newin.document.writeln('   .question {color:ffffcc}')
      newin.document.writeln('   .header {color:ffffcc}')
      newin.document.writeln('   .highlight {font-weight:bold}')
      newin.document.writeln('  </style>')
      newin.document.writeln(' </HEAD>')
      newin.document.writeln(' <body bgcolor="ivory" onLoad="top.window.focus()" link="#99ff00" vlink="#99ff00" text="#006009">')
      newin.document.writeln('  <font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('   <table width=100%>')
      newin.document.writeln('    <tr><td bgcolor="#99ff00" align="center">')
      newin.document.writeln('     <font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('      <h3>FS WEPP FuME soil texture</h3>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td></tr>')
      newin.document.writeln('   </table>')

      newin.document.writeln('The erosion potential of a given soil depends on the vegetation cover, the surface residue cover,')
      newin.document.writeln('the soil texture, and other soil properies that influence soil strength.')
      newin.document.writeln('<br><br>')
      newin.document.writeln('The soil texture field contains four USDA soil textures.')
      newin.document.writeln('Once a texture is selected, the appropriate erodibility values for that texture are used for all the soil components of the seven runs.')
      newin.document.writeln('<br><br>')
      newin.document.writeln('The following table can aid in selecting the desired soil texture.')
      newin.document.writeln('The specific soil properties associated with each selection can be seen by')
      newin.document.writeln('running Disturbed WEPP or WEPP:Road, selecting the desired soil')
      newin.document.writeln('and clicking "Describe" under the Soil Texture title.')
      newin.document.writeln('Properties vary depending upon the context in which the soil texture is selected.')
      newin.document.writeln('<br><br>')
      newin.document.writeln(' <blockquote>')
      newin.document.writeln(' <table border=1>')
      newin.document.writeln('  <tr>')
      newin.document.writeln('   <font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('    <caption>')
      newin.document.writeln('     <b>')
      newin.document.writeln('      <i>Categories of Common Forest Soils in relation to ERMiT soils</i>')
      newin.document.writeln('     </b>')
      newin.document.writeln('    </caption>')
      newin.document.writeln('   </font>')
      newin.document.writeln('  </tr>')
      newin.document.writeln('  <tr>')
      newin.document.writeln('   <th bgcolor=85d2d2><font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('    Soil type')
      newin.document.writeln('   </font></th>')
      newin.document.writeln('   <th bgcolor=85d2d2><font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('    Soil Description')
      newin.document.writeln('   </font></th>')
      newin.document.writeln('   <th bgcolor=85d2d2><font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('    Universal Soil Classification')
      newin.document.writeln('   </font></th>')
      newin.document.writeln('  </tr>')
      newin.document.writeln('  <tr>')
      newin.document.writeln('   <th><font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('    Clay loam')
      newin.document.writeln('   </font></th>')
      newin.document.writeln('   <td><font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('    Soils derived from shales, limestone and similar decomposing fine-grained sedimentary rock.<br>')
      newin.document.writeln('    Lakebeds and similar areas of ancient lacustrian deposits')
      newin.document.writeln('   </font></td>')
      newin.document.writeln('   <td><font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('    CH')
      newin.document.writeln('   </font></td>')
      newin.document.writeln('  </tr>')
      newin.document.writeln('  <tr>')
      newin.document.writeln('   <th><font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('    Silt loam')
      newin.document.writeln('   </font></th>')
      newin.document.writeln('   <td><font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('    Ash cap and loess soils, soils derived from siltstone or similar sedimentary rock<br>')
      newin.document.writeln('    Highly-erodible mica/schist geologies')
      newin.document.writeln('   </font></td>')
      newin.document.writeln('   <td><font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('    ML,CL')
      newin.document.writeln('   </font></td>')
      newin.document.writeln('  </tr>')
      newin.document.writeln('  <tr>')
      newin.document.writeln('   <th><font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('    Sandy loam')
      newin.document.writeln('   </font></th>')
      newin.document.writeln('   <td><font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('    Glacial outwash areas; decomposed granites and sand stone, and sand deposits')
      newin.document.writeln('   </font></td>')
      newin.document.writeln('   <td><font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('    GP, GM, SW, SP')
      newin.document.writeln('   </font></td>')
      newin.document.writeln('  </tr>')
      newin.document.writeln('  <tr>')
      newin.document.writeln('   <th><font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('    Loam')
      newin.document.writeln('   </font></th>')
      newin.document.writeln('   <td><font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('    Glacial tills, alluvium')
      newin.document.writeln('   </font></td>')
      newin.document.writeln('   <td><font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('    GC, SM, SC, MH')
      newin.document.writeln('   </font></td>')
      newin.document.writeln('  </tr>')
      newin.document.writeln(' </table>')
      newin.document.writeln('</blockquote>')

      newin.document.writeln('To fully describe each set of soils for WEPP requires 24 soil parameter values.')
      newin.document.writeln('Further details describing these parameters are available in the WEPP Technical Documentation')
      newin.document.writeln('(Alberts and others 1995).')
      newin.document.writeln('<br><br>')
      newin.document.writeln('<font size=-1>')
      newin.document.writeln('Alberts, E. E., M. A. Nearing, M. A. Weltz, L. M. Risse, F. B. Pierson, X. C. Zhang, J. M. Laflen, and J. R. Simanton.')
      newin.document.writeln('  1995.')
      newin.document.writeln('   <a href="http://topsoil.nserl.purdue.edu/nserlweb/weppmain/docs/chap7.pdf" target="pdf"><i>Chapter 7. Soil Component.</i></a> <b>In:</b> Flanagan, D. C. and M. A. Nearing (eds.)')
      newin.document.writeln('   <b>USDA-Water Erosion Prediction Project Hillslope Profile and Watershed Model Documentation.</b>')
      newin.document.writeln('   NSERL Report No. 10.')
      newin.document.writeln('   W. Lafayette, IN: USDA-ARS-MWA.')
      newin.document.writeln('</font>')

      newin.document.writeln('<!--tool bar begins--><p>')
      newin.document.writeln('  <table bgcolor="#666666" width="20%" border="0" cellspacing="1" cellpadding="5" align="center">')
      newin.document.writeln('   <tr>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      newin.document.writeln(' onMouseOver="this.style.backgroundColor=\'#000000\';"')
      newin.document.writeln(' onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln(' <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln(' <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.print()">Print me</a>')
      newin.document.writeln(' </font>')
      newin.document.writeln('</td>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      newin.document.writeln(' onMouseOver="this.style.backgroundColor=\'#000000\';"')
      newin.document.writeln(' onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln(' <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln('  <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.close()">Close me</a>')
      newin.document.writeln(' </font>')
      newin.document.writeln('</td>')
//      newin.document.writeln('    <td align="center" bgcolor="#333333">')
//      newin.document.writeln('  <font face="verdana,arial,helvetica" size="1">')
//      newin.document.writeln('   <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.print()">Print me</a>')
//      newin.document.writeln('  </font></td>')
//      newin.document.writeln('    <td align="center" bgcolor="#333333">')
//      newin.document.writeln('  <font face="verdana,arial,helvetica" size="1">')
//      newin.document.writeln('   <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.close()">Close me</a>')
//      newin.document.writeln('  </font></td>')
      newin.document.writeln('   </tr>')
      newin.document.writeln('  </table>')
      newin.document.writeln('<!--tool bar ends-->')
      newin.document.writeln('  </center>')
      newin.document.writeln(' </body>')
      newin.document.writeln('</html>')
      newin.document.close()
    } 
  }

  function explain_climate_symbols () {

    params='width=320';
    newin = window.open('','climate_symbols','width=340,scrollbars=yes,resizable=1')
    var newWin = newin.document.open()
    if (newWin != null) {
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>FS WEPP climate symbols</title>')
      newin.document.writeln('  <style>')
      newin.document.writeln('   BODY')
      newin.document.writeln('   {scrollbar-base-color:666666;scrollbar-face-color:#333333;scrollbar-highlight-color:#333333;scrollbar-shadow-color:666666;scrollbar-dark-shadow-color:ffffcc;scrollbar-arrow-color:ff6600}')
      newin.document.writeln('   .question {color:ffffcc}')
      newin.document.writeln('   .header {color:ffffcc}')
      newin.document.writeln('   .highlight {font-weight:bold}')
      newin.document.writeln('  </style>')
      newin.document.writeln(' </HEAD>')
      newin.document.writeln(' <body bgcolor="ivory" onLoad="top.window.focus()" link="#99ff00" vlink="#99ff00" text="#006009">')
      newin.document.writeln('  <font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln(' <center>')
      newin.document.writeln(' <h3>FS WEPP Climate symbols</h3>')
      newin.document.writeln(' <p>')
      newin.document.writeln('  <b>[Ownership] Station name [Status]</b>')
      newin.document.writeln('  <p>')
      newin.document.writeln(' <table align=center border=1 cellpadding=4>')
      newin.document.writeln('   <tr>')
      newin.document.writeln('    <th colspan=2 bgcolor=gold><font face="tahoma, sans serif">Ownership</font></th>')
      newin.document.writeln('   </tr>')
      newin.document.writeln('   <tr>')
      newin.document.writeln('    <th bgcolor=gold><font face="tahoma, sans serif">Symbol</font></th>')
      newin.document.writeln('    <th bgcolor=gold><font face="tahoma, sans serif">Meaning</font></td>')
      newin.document.writeln('   </tr>')
      newin.document.writeln('   <tr>')
      newin.document.writeln('    <th><font face="tahoma, sans serif">*</font></th>')
      newin.document.writeln('    <td><font face="tahoma, sans serif">Personal climate - created by your PC<sup>1</sup>, available only to you</font></td>')
      newin.document.writeln('   </tr>')
      newin.document.writeln('   <tr>')
      newin.document.writeln('    <th><font face="tahoma, sans serif">-</font></th>')
      newin.document.writeln('    <td><font face="tahoma, sans serif">Public climate - available temporarily for class, etc.</font></td>')
      newin.document.writeln('   </tr>')
      newin.document.writeln('  </table>')

      newin.document.writeln('  <p>')

      newin.document.writeln('  <table align=center border=1 cellpadding=4>')
      newin.document.writeln('   <tr>')
      newin.document.writeln('    <th colspan=2 bgcolor=gold><font face="tahoma, sans serif">Status</font></th>')
      newin.document.writeln('   </tr>')
      newin.document.writeln('   <tr>')
      newin.document.writeln('    <th bgcolor=gold><font face="tahoma, sans serif">Symbol</font></th>')
      newin.document.writeln('    <th bgcolor=gold><font face="tahoma, sans serif">Meaning</font></td>')
      newin.document.writeln('   </tr>')
      newin.document.writeln('   <tr>')
      newin.document.writeln('    <th><font face="tahoma, sans serif">+</font></th>')
      newin.document.writeln('    <td><font face="tahoma, sans serif">Modified from a standard Rock:Clime climate</font></td>')
      newin.document.writeln('   </tr>')
      newin.document.writeln('   <tr>')
      newin.document.writeln('    <th><font size="2" face="tahoma, sans serif">(none)</font></th>')
      newin.document.writeln('    <td><font face="tahoma, sans serif">Standard Rock:Clime climate</font></td>')
      newin.document.writeln('   </tr>')
      newin.document.writeln('  </table>')

      newin.document.writeln('  <p>')

      newin.document.writeln('<br>')
      newin.document.writeln('<br>Example:')
      newin.document.writeln('<br>')
      newin.document.writeln('  <strong><BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*COBALT ID+ </strong><br>')
      newin.document.writeln('  <br>')
      newin.document.writeln('  This climate for Cobalt Idaho is')
      newin.document.writeln('  (*) a climate your PC created, and')
      newin.document.writeln('  (+) the parameters have been modified.')
      newin.document.writeln(' </center>')
      newin.document.writeln('  <br>')
      newin.document.writeln('  <br>')
      newin.document.writeln('  <font face="tahoma, sans serif" size=-1>')
      newin.document.writeln('   <sup>1</sup> Technically, created under the Internet Protocol (IP) address for your computer.')
      newin.document.writeln('   With dial-up service, and especially under AOL, this number may vary between, and even within,')
      newin.document.writeln('   sessions.')
      newin.document.writeln('  </font>')
      newin.document.writeln('<p>')
      newin.document.writeln('<!--tool bar begins--><p>')
      newin.document.writeln('  <table bgcolor="#666666" width="20%" border="0" cellspacing="1" cellpadding="5" align="center">')
      newin.document.writeln('   <tr>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      newin.document.writeln('     onMouseOver="this.style.backgroundColor=\'#000000\';"')
      newin.document.writeln('     onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln('     <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln('      <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.print()">Print me</a>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      newin.document.writeln('     onMouseOver="this.style.backgroundColor=\'#000000\';"')
      newin.document.writeln('     onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln('     <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln('      <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.close()">Close me</a>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td>')
//      newin.document.writeln('      <td align="center" bgcolor="#333333">')
//      newin.document.writeln('     <font face="verdana,arial,helvetica" size="1">')
//      newin.document.writeln('      <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.print()">Print me</a>')
//      newin.document.writeln('     </font>')
//      newin.document.writeln('    </td>')
//      newin.document.writeln('    <td align="center" bgcolor="#333333">')
//      newin.document.writeln('     <font face="verdana,arial,helvetica" size="1">')
//      newin.document.writeln('      <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.close()">Close me</a>')
//      newin.document.writeln('     </font>')
//      newin.document.writeln('    </td>')
      newin.document.writeln('   </tr>')
      newin.document.writeln('  </table>')
      newin.document.writeln('<!--tool bar ends-->')
      newin.document.writeln('  </center>')
      newin.document.writeln(' </body>')
      newin.document.writeln('</html>')
      newin.document.close()
    } 
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

    if (window.document.fume.Climate.selectedIndex == "") {
        window.document.fume.Climate.selectedIndex = 0;
    }
    climYear();
  }

  function pcover1() {        // change ofe1 pcover to default for selected
    var which = window.document.fume.UpSlopeType.selectedIndex;
    window.document.fume.ofe1_pcover.value=default_pcover[which];
    return false;
  }

  function pcover2() {        // change ofe2 pcover to default for selected
    var which = window.document.fume.LowSlopeType.selectedIndex;
    window.document.fume.ofe2_pcover.value=default_pcover[which];
    return false;
  }

  function climYear() {        // change climate years to max for selected
//    var which = window.document.fume.Climate.selectedIndex;
//    window.document.fume.climate_name.value=climate_name[which];
//    window.document.fume.achtung.value="Calibrate vegetation";
//    window.document.fume.achtung.value="WEPP run";
//    return false;
  }

function RunningMsg (obj, text) {
//  var hill_l=parseFloat(document.forms[0].hillslope_length.value)
//  var buff_l=parseFloat(document.forms[0].buffer_length.value)
    var hill_l=parseFloat(document.forms[0].totall.value)
    var buff_l=parseFloat(document.forms[0].buffl.value)
    var buff_plus_one=buff_l+1
    if (hill_l < buff_l) {document.forms[0].totall.value=buff_plus_one}
    if (checkYears(document.forms[0].climyears)) {
       obj.value=text
       return true
    }
    else {
       return false
    }
}

function RunningMsgZ (obj, text) {
       obj.value=text
}

  function checkRange(obj,min,max,def,unit,thistext) {
     if (isNumber(obj.value)) {                   // obj == document.fume.BS
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
     }
     else {
         alert("Invalid entry for " + thistext + "!")
         obj.value=def
         lengths_changed()
         return 0;
    }
    lengths_changed()
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
         return true
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
         return true
     }
  }

function showRange(obj, head, min, max, unit) {
  range = head + min + " to " + max + unit	
  window.status = range
  return true                           // p. 86
}

function showHelp(obj, head, min, max, unit) {
  var which = window.document.fume.SlopeType.selectedIndex;
     if (which == 0) {vhead = "Ditch width + traveledway width: "}
     else if (which == 1) {vhead = "Ditch width + traveledway width: "}
     else if (which == 2) {vhead = "Traveledway width: "}
     else {vhead = "Rut spacing + rut width: "}
  range = vhead + min + " to " + max + unit	
  window.status = range
  return true                           // p. 86
}

function showTexture() {
  var which = window.document.fume.SoilType.selectedIndex;
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
print ' <BODY bgcolor="white" link="#99ff00" vlink="#99ff00" alink="red" onLoad="StartUp()">
  <font face="tahoma, arial, helvetica, sans serif">
   <table width=100% border=0>
    <tr>
     <td>
      <a href="/fswepp/">
       <IMG src="/fswepp/images/fsweppic2.jpg" alt="Erosion Analysis" align="left" border=0 width="95" height="95">
      </a>
      <a href="/fuels/">
       <img src="/fuels/images/fire2.jpg" align="left" alt="enviromental effects" border="0">
      </a>
     </td>
     <!-- td align=center bgcolor="#006009" -->
     <td align=center>
       <hr>
       <h3>WEPP <font color="#006009">FuME</font> ** <br>
           <font color="#006009">Fu</font>el
           <font color="#006009">M</font>anagement
           <font color="#006009">E</font>rosion Analysis</h3>
       <hr>
    <td>
       <A HREF="/fswepp/docs/fume/WEPP_FuME.pdf" target="docs">
       <IMG src="http://',$wepphost,'/fswepp/images/epage.gif"
        align="right" alt="Environmental Effects" border=0></a>
    </table>
  <center>

  <form name="fume" method="post" ACTION="http://',$wepphost,'/cgi-bin/fswepp/fume/fume2.pl">
  <input type="hidden" size="1" name="me" value="',$me,'">
  <table border="1">
';
print <<'theEnd';
     <tr align="top">
      <th bgcolor="#006009">
       <font color="#99ff00">
        <b>
        <a href="JavaScript:submitme('Describe Climate')"
             onMouseOver="window.status='Describe climate';return true"
             onMouseOut="window.status='Forest Service WEPP FuMe'; return true">
          Climate</a>
        </b>
          <a href="javascript:explain_climate_symbols()"
             onMouseOver="window.status='Explain symbols (new window)';return true"
             onMouseOut="window.status='Forest Service WEPP FuMe';return true">
             <img src="/fswepp/images/quest.gif" width="14" height="12" border="0"></a>
       </font>
      </th>
      <td width=20 rowspan=3><br></td>
      <th bgcolor="#006009">
       <font color="#99ff00">
        <b>
         Soil texture
        </b>
        <a href="javascript:explain_soil_texture()"
           onMouseOver="window.status='Explain soil texture (new window)';return true"
           onMouseOut="window.status='Forest Service FuMe'; return true">
         <img src="/fswepp/images/quest.gif" width="14" height="12" border="0"></a>
       </font>
      </td>

      <td width=20 rowspan=3><br></td>
      <th bgcolor="#006009">
       <font color="#99ff00">
        <b>
        <a
             onMouseOver="window.status='miles of road per square mile of territory';return true"
             onMouseOut="window.status='Forest Service WEPP FuMe'; return true">
         Road density (mi mi<sup>-2</sup>)</a>
        </b>
        <a href="javascript:explain_road_density()"
           onMouseOver="window.status='Explain road density (new window)';return true"
           onMouseOut="window.status='Forest Service FuMe'; return true">
         <img src="/fswepp/images/quest.gif" width="14" height="12" border="0"></a>
       </font>
      </td>

     </tr>
    <tr align=top>
       <TD align="center" bgcolor="lightblue">
        <SELECT NAME="Climate" SIZE="5">
theEnd

### display personal climates, if any

    if ($num_cli > 0) {
      print '         <OPTION VALUE="';
      print $climate_file[0];
      print '" selected> ', $climate_name[0] , "\n";
    }
    for $ii (1..$num_cli) {
      print '         <OPTION VALUE="';
      print $climate_file[$ii];
      print '"> ', $climate_name[$ii] , "\n";
    }

#################
print <<'theEnd';
      </SELECT>
      </td>
      <TD align="center" bgcolor="lightblue">
       <SELECT NAME="SoilType" SIZE="4"
        onChange="showTexture()"
        onBlur="blankStatus()">
        <OPTION VALUE="clay" selected>clay loam
        <OPTION VALUE="silt">silt loam
        <OPTION VALUE="sand">sandy loam
        <OPTION VALUE="loam">loam
       </SELECT>
      </td>
     <td align="center" bgcolor="lightblue">
      <input type="text" size="5" name="road_density" value="4"
        onChange="checkRange(this.form.road_density,rd_den_min,rd_den_max,rd_den_def,' mi/sq mi','road density')"
        onFocus="showRange(this.form,'Road density: ',rd_den_min,rd_den_max, '')">
     </td>
      </tr>
      <tr>
       <td align=center>
        <input type="hidden" size="5" name="climyears" value="50">   <!-- 2004.11.19 --> <!-- 2005.01.12 -->
        <input type="hidden" name="achtung" value="Run WEPP FuME">
        <input type="SUBMIT" name="actionc" value="Custom Climate">
       </td>
      </tr>
    </table>

<!--
   <table border="2">
    <tr>
     <th bgcolor="#006009">
      <font face="tahoma, arial, helvetica, sans serif" color="#99ff00">
       Road density (mi mi<sup>-2</sup>)
     </td>
    </tr>
    <tr>
     <th bgcolor="lightblue">
      <font face="tahoma, arial, helvetica, sans serif">
       Simulation length (yr)
     </td>
     <td>
      <input type="text" size="5" name="climyears" value="5"
        onChange="checkYears(this.form.climyears)"
        onFocus="showRange(this.form,'Years to simulate: ',minyear, maxyear, '')"
        onBlur="blankStatus()">
     </td>
    </tr>
   </table>
-->
   <br>

   <table border=2 cellpadding=4>
    <tr>
     <td colspan=4 bgcolor="#006009">
      <font face="tahoma, arial, helvetica, sans serif" color="#99ff00">
       <b>
        Hillslope horizontal length (ft)
        <a href="javascript:explain_topo()"><img src="/fswepp/images/quest.gif" width="14" height="12" border="0"></a>
       </b>
      </font>
     </td>
    </tr>
    <tr>
     <td>
     </td>
     <td>
      <img src="/fswepp/images/gold.gif" width="100" height="20" name="total" border="0">
     </td>
     <td bgcolor="lightblue">
      <font face="tahoma, arial, helvetica, sans serif">
       <input type="text" size=8 value="200" name="totall"
        onChange="checkRange(this.form.totall,total_l_min,total_l_max,total_l_def,' ft','hillslope length');return true"
        onFocus="showRange(this.form,'Hillslope length: ',total_l_min, total_l_max, '')"
        onBlur="blankStatus()">
       <b>
        <a onMouseOver="window.status='Horizontal length of hillslope, including buffer';return true"         
           onMouseOut="window.status='Forest Service WEPP FuMe'; return true">
        Total hillslope</a>
       </b>
      </font>
     </td>
    </tr>
    <tr>
     <td>
      <font face="tahoma, arial, helvetica, sans serif">
       <b>
        Treated hillslope <input type="text" size=8 name="hilll" disabled value="150">
       </b>
      </font>
     </td>
     <td>
      <img src="/fswepp/images/orange.gif" width="75" height="20" name="hillslope" border="0"><img src="/fswepp/images/green.gif" width="25" height="20" name="buffer" border="0">
     </td>
     <td bgcolor="lightblue">
      <font face="tahoma, arial, helvetica, sans serif">
       <input type="text" size=8 name="buffl" value="50"
        onChange="checkRange(this.form.buffl,buff_l_min,buff_l_max,buff_l_def,' ft','buffer length');return true"
        onFocus="showRange(this.form,'Buffer length: ',buff_l_min,buff_l_max, '')"
        onBlur="blankStatus()">
       <b>
        <a onMouseOver="window.status='Horizontal length of hillslope buffer';return true"         
           onMouseOut="window.status='Forest Service WEPP FuMe'; return true">
        Buffer</a>
       </b>
      </font>
     </td>
    </tr>
   </table>

   <br>

 <table>
  <tr>
   <td>

   <table border=1 cellpadding=4>
    <tr>
     <td  colspan=4 bgcolor="#006009">
      <font face="tahoma, arial, helvetica, sans serif" color="#99ff00">
       <b>
        Hillslope gradient (%)
         <a href="javascript:explain_topo()"><img src="/fswepp/images/quest.gif" width="14" height="12" border="0"></a>
       </b>
      </font>
     </td>
    </tr>
    <tr>
     <th bgcolor="lightblue">
      <font face="tahoma, arial, helvetica, sans serif">
       <b>
       <a onMouseOver="window.status='Gradient of hillslope top (%)';return true"
          onMouseOut="window.status='Forest Service WEPP FuMe'; return true">
        Top</a>
       </b>
       <br>
       <input type="text" size=8 value="0" name="ofe1_top_slope" onChange="checkRange(this.form.ofe1_top_slope,hill_g_min,hill_g_max,hill_g_def,' %','hillslope gradient')"
        onFocus="showRange(this.form,'Hillslope top gradient: ',hill_g_min, hill_g_max, '')"
        onBlur="blankStatus()">
      </font>
     </th>
     <th bgcolor="lightblue">
      <font face="tahoma, arial, helvetica, sans serif">
       <b>
       <a onMouseOver="window.status='Gradient of hillslope middle (percent)';return true"
          onMouseOut="window.status='Forest Service WEPP FuMe'; return true">
        Middle</a>
       </b>
       <br>
       <input type="text" size=8 value="30" name="ofe1_mid_slope" onChange="checkRange(this.form.ofe1_mid_slope,hill_g_min,hill_g_max,hill_g_def,' %','hillslope gradient')"
        onFocus="showRange(this.form,'Hillslope middle gradient: ',hill_g_min, hill_g_max, '')"
        onBlur="blankStatus()">
      </font>
     </th>
     <th bgcolor="lightblue">
      <font face="tahoma, arial, helvetica, sans serif">
       <b>
       <a onMouseOver="window.status='Gradient of hillslope toe (%)';return true"
          onMouseOut="window.status='Forest Service WEPP FuMe'; return true">
        Toe</a>
       </b>
       <br>
       <input type="text" size=8 value="15" name="ofe2_bot_slope" onChange="checkRange(this.form.ofe2_bot_slope,hill_g_min,hill_g_max,hill_g_def,' %','hillslope gradient')"
        onFocus="showRange(this.form,'Hillslope toe gradient: ',hill_g_min, hill_g_max, '')"
        onBlur="blankStatus()">
      </font>
     </th>
    </tr>
   </table>
   
   </td><td>

   <table border=1 cellpadding=4>
    <tr>
     <td  colspan=4 bgcolor="#006009">
      <font face="tahoma, arial, helvetica, sans serif" color="#99ff00">
       <b>
        Disturbance return period (y)
          <a href="javascript:explain_frequency()"
             onMouseOver="window.status='Explain disturbance return period (new window)';return true"
             onMouseOut="window.status='Forest Service WEPP FuMe';return true">
             <img src="/fswepp/images/quest.gif" width="14" height="12" border="0"></a>
       </b>
      </font>
     </td>
    </tr>
    <tr>
     <th bgcolor="lightblue">
      <font face="tahoma, arial, helvetica, sans serif">
        <a onMouseOver="window.status='Number of years between wildfires';return true"         
           onMouseOut="window.status='Forest Service WEPP FuMe'; return true">
        Wildfire</a>
       <br>
       <input type="text" size=8 value="40" name="wildfire_cycle"
        onChange="checkRange(this.form.wildfire_cycle,wfc_min,wfc_max,wfc_def,' yr','wildfire cycle')"
        onFocus="showRange(this.form,'Wildfire cycle: ',wfc_min, wfc_max, '')"
        onBlur="blankStatus()">
      </font>
     </th>
     <th bgcolor="lightblue">
      <font face="tahoma, arial, helvetica, sans serif">
        <a onMouseOver="window.status='Number of years between prescribed fires';return true"         
           onMouseOut="window.status='Forest Service WEPP FuMe'; return true">
        Prescribed fire</a>
       <br>
       <input type="text" size=8 value="20" name="rx_fire_cycle"
        onChange="checkRange(this.form.rx_fire_cycle,fmc_min,fmc_max,fmc_def,' yr','prescribed fire cycle')"
        onFocus="showRange(this.form,'Prescribed fire cycle: ',fmc_min,fmc_max, '')"
        onBlur="blankStatus()">
      </font>
     </th>
     <th bgcolor="lightblue">
      <font face="tahoma, arial, helvetica, sans serif">
        <a onMouseOver="window.status='Number of years between thinnings';return true"         
           onMouseOut="window.status='Forest Service WEPP FuMe'; return true">
        Thinning</a>
       <br>
       <input type="text" size=8 value="20" name="thinning_cycle"
        onChange="checkRange(this.form.thinning_cycle,fmc_min,fmc_max,fmc_def,' yr','thinning cycle')"
        onFocus="showRange(this.form,'Thinning cycle: ',fmc_min,fmc_max, '')"
        onBlur="blankStatus()">
      </font>
     </th>
    </tr>
   </table>

   </td>
  </tr>
 </table>

theEnd

print '
      </b>
     </p>

<!--
      <input type="radio" name="units" value="m"><b>metric</b>
      <input type="radio" name="units" value="ft" checked><b>English</b>
-->

     <p>
      <input type="SUBMIT" name="actionw" VALUE="Run WEPP FuME"
       onClick=\'RunningMsg(this.form.actionw,"Running WEPP..."); this.form.achtung.value="Run WEPP FuME"\'>
      <br>
     </p>
    </center>
   </form>
  <P>
   <hr>
    <table border=0>
     <tr>
      <td valign="top" bgcolor="lightgoldenrodyellow">
       <font face="tahoma, arial, helvetica, sans serif" size=1>
        The FS WEPP FuMe interface predicts soil erosion associated with fuel management practices including prescribed fire,
        thinning, and a road network, and compares that prediction to erosion from wildfire.
       </font>
      </td>
      <td valign="top">
       <a href="http://',$wepphost,'/fswepp/comments.html"<img src="/fswepp/images/epaemail.gif" align="right" border=0></a>
      </td>
     </tr>
     <tr>
      <td valign="top">
       <font face="tahoma, arial, helvetica, sans serif" size=1>
        WEPP FuME input interface v.
        <a href="javascript:popuphistory()"> ',$version,'</a>
        (for review only) by
        David Hall &amp; Elena Velasquez<br>
        Model developed by Bill Elliot &amp; Pete Robichaud, USDA Forest Service, Rocky Mountain Research Station, Moscow, ID
       </font>
      </td>
     </tr>
    </table>
';

  $remote_host = $ENV{'REMOTE_HOST'};
  $remote_address = $ENV{'REMOTE_ADDR'};

  $wc  = `wc ../working/wf.log`;
  @words = split " ", $wc;
  $runs = @words[0];

##       674 funs in 2009
##     1,170 runs in 2008
##     1,621 runs in 2007
##       842 runs in 2006

print "  <font face='tahoma, arial, helvetica, sans serif' size=1>
   $remote_host &ndash; $remote_address ($user_really) personality '<b>$me</b>'<br>
   <b>$runs</b> WEPP FuME runs since Jan 01, 2011
  </font>
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
# WHRM Wildlife Habitat Response Model Version History

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

