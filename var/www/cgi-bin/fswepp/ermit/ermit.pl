#!/usr/bin/perl
use CGI;
use CGI qw(escapeHTML);

use MoscowFSL::FSWEPP::FsWeppUtils qw(get_version);

#
#  ERMiT input screen
#
#  ERMiT.pl -- input screen for ERMiT

## BEGIN HISTORY ###################################
## WEPP ERMiT version history

my $version = get_version(__FILE__);

# $version = '2014.04.07';    # Provide unburned option
#! $version='2013.04.30';       # Oops, fix run count report for 2013
#  $version='2013.03.01';	# Sort personal climates (newest at top) and standard climates (by name)
#  $version='2009.09.17';	# Adjust FSWEPPuser personality
#  $version='2009.02.23';	# Add WEPP version user selection
#! $version='2006.07.19';	# remove background='under_dev__.gif' was  85910 Apr 27 14:45 ermit.pl
#! $version='2006.04.27';	# Change link to users guide
#! $version='2006.04.06';	# USCS: Unified
#  $version='2006.01.18';	# ERMiT released
#! $version='2005.11.21';	# Change soil burn severity explanation popup text and graphics
#! $version='2005.10.26';	# Remove probability table option
#! $version='2005.10.24';	# Temporary probability table option, remove range soils test option
#! $version='2005.09.30';	# Remove options for CLIGEN, call 5-storm ERMiT engine
#! $version='2005.09.13';	# Remove new range values switch. Add switch for CLIGEN 5.22564
#! $version = '2005.04.20';	# Change <i>burn severity</i> to <i>soil burn severity</i><br>Add history pop-up
#! $version = '2004.12.13';	# Add Corey Moffet, USDA-ARS, to tagline
#! $version = '2004.09.16';	# Add Fred Pierson, USDA-ARS, to tagline<br>Place temporary <i>ravel check</i> graphic
#! $version = '2004.06.07';	# Convert help text to pop-ups<br>Correct mouseover status line text
#! $version = '2003.09.04';	# Add input checking for hillslope horizontal length

# 2009.09.17 DEH Keep up with change in FSWEPPuser cookie
# 2004.12.13 DEH Add Corey Moffet, USDA-ARS to tagline;
# 2004.11.01 DEH change "no ravel" graphic; make "rock" new table cell "rock content"
# 2004.10.28 DEH non-breaking space on '% grass' etc.
# 2004.10.13 DEH Add trailing '\\' for $working for platform eq 'pc'
# 2004.09.16 DEH Add Fred Pierson, USDA-ARS to tagline; reduce fontsize of tagline; remove "Rock" link to dox.
#	  Place temporary graphic for ravelcheck instead of button
# 2004.06.07 DEH Correct status notes, add colors to shrub/grass/bare
#	  Change help screens to pop-ups
# 2004.03.24 DEH Instability warning removed
# 2004.03.16 DEH Instability warning
# 2003.09.04 DEH Input checking for hillslope horizontal length
# 2003.08.19 DEH Add run count report
# 2003.03.04 DEH Remove 'host' echo; add Pete to tagline; reinstate "Risk"
# 2002.12.30 DEH add sample result screen for dry ravel
# 2002.11.21 DEH use HTTP_X_FORWARDRD_FOR a user IP if not blank
# 2002.11.12 DEH check HTTP_X_FORWARDED_FOR
# 2002.11.06 DEH added % shrub %grass %bare for range / chaparral
# 2002.08.22 DEH transformed weppdist.pl from "forest"
# 2002.01.08 DEH Removed errant return link to "dindex.html" & wrap pbs
## END HISTORY ###################################

#  usage:
#    action = "ermit.pl"
#  parameters:
#    debug
#    units             # unit scheme (ft|m)
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

$remote_host    = $ENV{'REMOTE_HOST'};
$remote_address = $ENV{'REMOTE_ADDR'};    # if ($userIP eq '');

$http_x_forwarded_for = $ENV{'HTTP_X_FORWARDED_FOR'};
$http_cache_control   = $ENV{'HTTP_CACHE_CONTROL'};

my $cgi = new CGI;
$units = escapeHTML( $cgi->param('units') );
$debug = escapeHTML( $cgi->param('debug') );

if    ( $units eq 'm' )  { $areaunits = 'ha' }
elsif ( $units eq 'ft' ) { $areaunits = 'ac' }
else                     { $units     = 'ft'; $areaunits = 'ac' }

$cookie = $ENV{'HTTP_COOKIE'};

$sep = index( $cookie, "FSWEPPuser=" );
$me  = "";
if ( $sep > -1 ) { $me = substr( $cookie, $sep + 11, 1 ) }    # DEH 2009.09.17

if ( $me ne "" ) {
    $me = lc( substr( $me, 0, 1 ) );
    $me =~ tr/a-z/ /c;
}
if ( $me eq " " ) { $me = "" }

$working     = '../working/';                                 # DEH 08/22/2000
$public      = $working . 'public/';                          # DEH 09/21/2000
$user_ID     = $ENV{'REMOTE_ADDR'};
$user_really = $ENV{'HTTP_X_FORWARDED_FOR'};                  # DEH 11/14/2002
$user_ID     = $user_really if ( $user_really ne '' );        # DEH 11/14/2002
$user_ID =~ tr/./_/;
$user_ID = $user_ID . $me . '_';                              # DEH 03/05/2001
$logFile = '../working/' . $user_ID . '.log';
$cliDir  = '../climates/';
$custCli = '../working/' . $user_ID;                          # DEH 03/02/2001

########################################

$num_cli = 0;

### get public climates, if any

opendir PUBLICDIR, $public;
@allpfiles = readdir PUBLICDIR;
close PUBLICDIR;

for $f (@allpfiles) {
    if ( substr( $f, -4 ) eq '.par' ) {
        $f = $public . $f;
        open( M, "<$f" ) || goto vskip;
        $station = <M>;
        close(M);
        $climate_file[$num_cli] = substr( $f, 0, -4 );
        $clim_name = '- ' . substr( $station, index( $station, ":" ) + 2, 40 );
        $clim_name =~ s/^\s*(.*?)\s*$/$1/;
        $climate_name[$num_cli] = $clim_name;
        $num_cli += 1;
      vskip:
    }
}

### get personal climates, if any

opendir CLIMDIR, $working;
@allpfiles = readdir CLIMDIR;
close CLIMDIR;

for $f (@allpfiles) {
    if ( index( $f, $user_ID ) == 0 ) {
        if ( substr( $f, -4 ) eq '.par' ) {
            $f = $working . $f;
            open( M, "<$f" ) || goto psskip;
            $station = <M>;
            close(M);

            #  ####  get file creation date  ####  #
            $age[$num_cli_ps] =
              -M $f;    # age of the file in days since the last modification
            $climate_file_ps[$num_cli_ps] = substr( $f, 0, -4 );
            $clim_name_ps =
              '*' . substr( $station, index( $station, ":" ) + 2, 40 );
            $clim_name_ps =~ s/^\s*(.*?)\s*$/$1/;
            $climate_name_ps[$num_cli_ps] = $clim_name_ps;
            $num_cli_ps += 1;
        }    # if (substr
      psskip:
    }    # if (index
}    # for $f

#  ####  index sort climate modification time           www.perlmonks.org/?node_id=60442
@ind = sort { $age[$a] <=> $age[$b] } 0 .. $#age;    # sort index

#  ####  copy sorted entries into climate name and file lists  ####  #
for my $i ( 0 .. $#age ) {
    $climate_name[$num_cli] = $climate_name_ps[ $ind[$i] ];
    $climate_file[$num_cli] = $climate_file_ps[ $ind[$i] ];
    $num_cli++;
}

### get standard climates

opendir CLIMDIR, '../climates';
@allfiles = readdir CLIMDIR;
close CLIMDIR;

$num_cli_s     = 0;
$num_cli_start = $num_cli;
for $f (@allfiles) {
    $f = '../climates/' . $f;
    if ( substr( $f, -4 ) eq '.par' ) {
        open( M, $f ) || goto sskip;
        $station = <M>;
        close(M);

        $climate_file_s[$num_cli_s] = substr( $f, 0, -4 );
        $clim_name = substr( $station, index( $station, ":" ) + 2, 40 );
        $clim_name =~ s/^\s*(.*?)\s*$/$1/;
        $climate_name_s[$num_cli_s] = $clim_name;
        $num_cli_s += 1;
      sskip:
    }
}

#  ####  index sort climate name  ####  #
@ind = sort { $climate_name_s[$a] cmp $climate_name_s[$b] }
  0 .. $#climate_name_s;    # sort index

#  ####  copy sorted entries into climate name and file lists  ####  #
for my $i ( 0 .. $#climate_name_s ) {
    $climate_name[ $i + $num_cli_start ] = $climate_name_s[ $ind[$i] ];
    $climate_file[ $i + $num_cli_start ] = $climate_file_s[ $ind[$i] ];
    $num_cli++;
}
$num_cli -= 1;

###################################################

print "Content-type: text/html\n\n";
print '<html>
 <head>
  <title>ERMiT Erosion Risk Management Tool</title>
  <META http-equiv="Content-Type" content="text/html; charset=utf-8">
  <META NAME="Name" CONTENT="ERMiT">
  <META NAME="Brief Description" CONTENT="ERMiT (Erosion Risk Management Tool), a component of FS WEPP, predicts the probability associated with a given amount of soil erosion in each of five years following wildfire. ERMiT allows users to predict erosion following variable burns on forest, rangeland, and chaparral conditions.">
  <META NAME="Status" CONTENT="Under development; beta release 2003">
  <META NAME="Updates" CONTENT="Ongoing, online">
  <META NAME="Inputs" CONTENT="Climate station; soil texture; rock content; vegetation type (forest, range, chaparral); hillslope gradient and horizontal length; soil burn severity class; range/chaparral pre-fire community description (% shrub, % grass)">
  <META NAME="Outputs" CONTENT="Annual average precipitation; runoff from rainfall; runoff from snowmelt or winter rainstorm; sediment delivery exceedance probability curves; calculator of event sediment delivery vs. target chance event sediment delivery will be exceeded for untreated, seeded, and a range of mulching; contour-felled logs and straw wattles to come.">
  <META NAME="Suggested user" CONTENT="">
  <META NAME="Suggested use" CONTENT="">
  <META NAME="Keywords" CONTENT="">
  <META NAME="Contributors" CONTENT="USDA Forest Service, Rocky Mountain Research Station, Moscow, ID: Pete Robichaud, Bill Elliot, and David Hall; USDA Agricultural Research Service, Northwest Watershed Research Center, Boise, ID: Fred Pierson and Corey Moffet">
  <META NAME="Source" content="Run online at https://forest.moscowfsl.wsu.edu/fswepp/">
  <style>
   <!--
     P.Reference {
        margin-top:0pt;
        margin-left:.3in;
        text-indent:-.3in;
    }
   -->
  </style>
';
print "
  <SCRIPT type=\"TEXT/JAVASCRIPT\">
  <!--

  var version = '$version'
  var minyear = 1
  var maxyear = 200
  var defyear = 30

  function popupclosest() { 
    url = 'https://forest.moscowfsl.wsu.edu/fswepp/rc/closest.php?units=ft';
    width=900; 
    height=600;
    popupwindow = window.open(url,'popupwindow','toolbar=no,location=no,status=no,directories=no,menubar=no,scrollbars=yes,resizable=yes,width='+width+',height='+height); 
    popupwindow.focus()
                          }
";
print <<'theEnd';

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

  function explain_soil_texture () {

    newin = window.open('','ermit_help','width=640,scrollbars=yes,resizable=1')
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
      newin.document.writeln(' <body bgcolor="ivory" onLoad="top.window.focus()" link="white" vlink="white">')
      newin.document.writeln('  <font face="tahoma, sans serif">')
      newin.document.writeln('   <h3>ERMiT soil texture</h3>')
      newin.document.writeln('The erosion potential of a given soil depends on the vegetation cover, the surface residue cover,')
      newin.document.writeln('the soil texture, and other soil properies that influence soil strength.')
      newin.document.writeln('<br><br>')
      newin.document.writeln('Four soil textures (clay loam, silt loam, sandy loam, and loam) are available.')
      newin.document.writeln('<br><br>')
      newin.document.writeln('The following table can aid in selecting the desired soil texture.')
      newin.document.writeln('The specific soil properties associated with each selection can be seen by selecting the desired soil')
      newin.document.writeln('and clicking "Describe" under the Soil Texture title.')
      newin.document.writeln('<br><br>')
      newin.document.writeln('To fully describe each set of soils for WEPP requires 24 soil parameter values.')
      newin.document.writeln('Further details describing these parameters are available in the WEPP Technical Documentation')
      newin.document.writeln('(Alberts and others 1995).')
      newin.document.writeln(' <blockquote>')
      newin.document.writeln(' <table border=1>')
      newin.document.writeln('  <tr>')
      newin.document.writeln('   <font face="tahoma, sans serif">')
      newin.document.writeln('    <caption>')
      newin.document.writeln('     <b>')
      newin.document.writeln('      <i>Categories of Common Forest Soils in Relation to ERMiT Soil Textures</i>')
      newin.document.writeln('     </b>')
      newin.document.writeln('    </caption>')
      newin.document.writeln('   </font>')
      newin.document.writeln('  </tr>')
      newin.document.writeln('  <tr>')
      newin.document.writeln('   <th bgcolor=#85d2d2><font face="tahoma, sans serif">')
      newin.document.writeln('    ERMiT Soil Texture')
      newin.document.writeln('   </font></th>')
      newin.document.writeln('   <th bgcolor=#85d2d2><font face="tahoma, sans serif">')
      newin.document.writeln('    Soil Description')
      newin.document.writeln('   </font></th>')
      newin.document.writeln('   <th bgcolor=#85d2d2><font face="tahoma, sans serif">')
      newin.document.writeln('    Unified Soil Classification')
      newin.document.writeln('   </font></th>')
      newin.document.writeln('  </tr>')
      newin.document.writeln('  <tr>')
      newin.document.writeln('   <th><font face="tahoma, sans serif">')
      newin.document.writeln('    Clay loam')
      newin.document.writeln('   </font></th>')
      newin.document.writeln('   <td><font face="tahoma, sans serif">')
      newin.document.writeln('    Soils derived from shales, limestone and similar decomposing fine-grained sedimentary rock.<br>')
      newin.document.writeln('    Lakebeds and similar areas of ancient lacustrian deposits')
      newin.document.writeln('   </font></td>')
      newin.document.writeln('   <td><font face="tahoma, sans serif">')
      newin.document.writeln('    CH')
      newin.document.writeln('   </font></td>')
      newin.document.writeln('  </tr>')
      newin.document.writeln('  <tr>')
      newin.document.writeln('   <th><font face="tahoma, sans serif">')
      newin.document.writeln('    Silt loam')
      newin.document.writeln('   </font></th>')
      newin.document.writeln('   <td><font face="tahoma, sans serif">')
      newin.document.writeln('    Ash cap and loess soils, soils derived from siltstone or similar sedimentary rock<br>')
      newin.document.writeln('    Highly-erodible mica/schist geologies')
      newin.document.writeln('   </font></td>')
      newin.document.writeln('   <td><font face="tahoma, sans serif">')
      newin.document.writeln('    ML,CL')
      newin.document.writeln('   </font></td>')
      newin.document.writeln('  </tr>')
      newin.document.writeln('  <tr>')
      newin.document.writeln('   <th><font face="tahoma, sans serif">')
      newin.document.writeln('    Sandy loam')
      newin.document.writeln('   </font></th>')
      newin.document.writeln('   <td><font face="tahoma, sans serif">')
      newin.document.writeln('    Glacial outwash areas; decomposed granites and sand stone, and sand deposits')
      newin.document.writeln('   </font></td>')
      newin.document.writeln('   <td><font face="tahoma, sans serif">')
      newin.document.writeln('    GP, GM, SW, SP')
      newin.document.writeln('   </font></td>')
      newin.document.writeln('  </tr>')
      newin.document.writeln('  <tr>')
      newin.document.writeln('   <th><font face="tahoma, sans serif">')
      newin.document.writeln('    Loam')
      newin.document.writeln('   </font></th>')
      newin.document.writeln('   <td><font face="tahoma, sans serif">')
      newin.document.writeln('    Glacial tills, alluvium')
      newin.document.writeln('   </font></td>')
      newin.document.writeln('   <td><font face="tahoma, sans serif">')
      newin.document.writeln('    GC, SM, SC, MH')
      newin.document.writeln('   </font></td>')
      newin.document.writeln('  </tr>')
      newin.document.writeln(' </table>')
      newin.document.writeln('</blockquote>')

      newin.document.writeln('Alberts, E. E., M. A. Nearing, M. A. Weltz, L. M. Risse, F. B. Pierson, X. C. Zhang, J. M. Laflen, and J. R. Simanton.')
      newin.document.writeln('  1995.')
      newin.document.writeln('   <i>Chapter 7. Soil Component.</i> <b>In:</b> Flanagan, D. C. and M. A. Nearing (eds.)')
      newin.document.writeln('   <b>USDA-Water Erosion Prediction Project Hillslope Profile and Watershed Model Documentation.</b>')
      newin.document.writeln('   NSERL Report No. 10.')
      newin.document.writeln('   W. Lafayette, IN: USDA-ARS-MWA.')

      newin.document.writeln(' <br><br>')
      newin.document.writeln(' <font size=2>')
      newin.document.writeln(' ERMiT v. ' + version + ' <i>explain_soil_texture</i>')
      newin.document.writeln(' </font>')
      newin.document.writeln('<!--tool bar begins--><p>')
      newin.document.writeln('  <table bgcolor="#666666" width="40%" border="0" cellspacing="1" cellpadding="5" align="center">')
      newin.document.writeln('   <tr>')
      newin.document.writeln('    <td align="center" bgcolor="#333333" onMouseOver="this.style.backgroundColor=\'#000000\';" onMouseOut="this.style.backgroundColor=\'\';"><font face="verdana,arial,helvetica" size="1"><img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.print()">Print me</a></font></td>')
      newin.document.writeln('    <td align="center" bgcolor="#333333" onMouseOver="this.style.backgroundColor=\'#000000\';" onMouseOut="this.style.backgroundColor=\'\';"><font face="verdana,arial,helvetica" size="1"><img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.close()">Close me</a></font></td>')
//      newin.document.writeln('    <td align="center" bgcolor="#333333"><font face="verdana,arial,helvetica" size="1"><img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.print()">Print me</a></font></td>')
//      newin.document.writeln('    <td align="center" bgcolor="#333333"><font face="verdana,arial,helvetica" size="1"><img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.close()">Close me</a></font></td>')
      newin.document.writeln('   </tr>')
      newin.document.writeln('  </table>')
      newin.document.writeln('<!--tool bar ends-->')
      newin.document.writeln('  </center>')
      newin.document.writeln(' </body>')
      newin.document.writeln('</html>')
      newin.document.close()
    } 
  }

  function explain_rock_content () {

    newin = window.open('','ermit_help','width=640,scrollbars=yes,resizable=1')
    var newWin = newin.document.open()
    if (newWin != null) {
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>ERMiT rock content</title>')
      newin.document.writeln('  <style>')
      newin.document.writeln('   BODY')
      newin.document.writeln('   {scrollbar-base-color:666666;scrollbar-face-color:#333333;scrollbar-highlight-color:#333333;scrollbar-shadow-color:666666;scrollbar-dark-shadow-color:ffffcc;scrollbar-arrow-color:ff6600}')
      newin.document.writeln('   .question {color:ffffcc}')
      newin.document.writeln('   .header {color:ffffcc}')
      newin.document.writeln('   .highlight {font-weight:bold}')
      newin.document.writeln('  </style>')
      newin.document.writeln(' </HEAD>')
      newin.document.writeln(' <body bgcolor="ivory" onLoad="top.window.focus()" link="white" vlink="white">')
      newin.document.writeln('  <font face="tahoma, sans serif">')

      newin.document.writeln('   <h3>ERMiT rock content</h3>')
      newin.document.writeln('    Rock content provides the ability of the interface to consider rock outcrops.')
      newin.document.writeln('    <br><br>')
      newin.document.writeln('    Rock fragments in WEPP are considered rocks in the soil.')
      newin.document.writeln('    As such, WEPP assumes that as water moves through soil, it must flow around the rocks.')
      newin.document.writeln('    Therefore, WEPP reduces the hydraulic conductivity of the soil in direct proportion to')
      newin.document.writeln('    the rock content (i.e. 20 percent rock will reduce the hydraulic conductivity by 20 percent).')
      newin.document.writeln('    WEPP will not accept a value for rock content higher than 50 percent,')
      newin.document.writeln('    so even when the user puts 100 percent rock into the rock content box,')
      newin.document.writeln('    WEPP assumes that it is only 50 percent.')
      newin.document.writeln('    In this context, as rock content increases up to 50 percent, runoff increases,')
      newin.document.writeln('    as does rill erosion.')
      newin.document.writeln('    Above 50 percent, there is no further impact modeled from increased rock content.')
      newin.document.writeln(' <br><br>')
      newin.document.writeln(' <font size=2>')
      newin.document.writeln(' ERMiT v. ' + version + ' <i>explain_rock_content</i>')
      newin.document.writeln(' </font>')
      newin.document.writeln('<!--tool bar begins--><p>')
      newin.document.writeln('  <table bgcolor="#666666" width="40%" border="0" cellspacing="1" cellpadding="5" align="center">')
      newin.document.writeln('   <tr>')
      newin.document.writeln('    <td align="center" bgcolor="#333333" onMouseOver="this.style.backgroundColor=\'#000000\';" onMouseOut="this.style.backgroundColor=\'\';"><font face="verdana,arial,helvetica" size="1"><img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.print()">Print me</a></font></td>')
      newin.document.writeln('    <td align="center" bgcolor="#333333" onMouseOver="this.style.backgroundColor=\'#000000\';" onMouseOut="this.style.backgroundColor=\'\';"><font face="verdana,arial,helvetica" size="1"><img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.close()">Close me</a></font></td>')
      newin.document.writeln('   </tr>')
      newin.document.writeln('  </table>')
      newin.document.writeln('<!--tool bar ends-->')
      newin.document.writeln(' </body>')
      newin.document.writeln('</html>')
      newin.document.close()
    } 
  }

  function explain_climate_symbols () {

    params='width=320';
    newin = window.open('','ermit_help','width=340,scrollbars=yes,resizable=1')
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
      newin.document.writeln(' <body bgcolor="ivory" onLoad="top.window.focus()" link="white" vlink="white">')
      newin.document.writeln('  <font face="tahoma, sans serif">')
      newin.document.writeln('   <h3>FS WEPP Climate symbols</h3>')
      newin.document.writeln('   <center>')
      newin.document.writeln('   <p>')
      newin.document.writeln('  <b>[Ownership] Station name [Status]</b>')
      newin.document.writeln('  <p>')
      newin.document.writeln('  <table align=center border=1>')
      newin.document.writeln('  <tr><th colspan=2 bgcolor=gold>Ownership')
      newin.document.writeln('  <tr><th> -    <td>Public (any computer could create)')
      newin.document.writeln('  <tr><th> *    <td>Personal climate (your computer created)')
      newin.document.writeln('  <tr><th>&nbsp;<td>Standard-issue climate')
      newin.document.writeln('  </table>')
      newin.document.writeln('  <p>')
      newin.document.writeln('  <table align=center border=1>')
      newin.document.writeln('  <tr><th colspan=2 bgcolor=gold>Status')
      newin.document.writeln('  <tr><th> +    <td>Parameters have been changed from standard-issue')
      newin.document.writeln('  <tr><th>&nbsp;<td>Unchanged from distribution')
      newin.document.writeln('  </table>')
      newin.document.writeln('  <p>')
      newin.document.writeln(' </center>')
      newin.document.writeln(' <br><br>')
      newin.document.writeln(' <font size=2>')
      newin.document.writeln(' ERMiT v. ' + version + ' <i>explain_climate_symbols</i>')
      newin.document.writeln(' </font>')
      newin.document.writeln('<!--tool bar begins--><p>')
      newin.document.writeln('  <table bgcolor="#666666" width="40%" border="0" cellspacing="1" cellpadding="5" align="center">')
      newin.document.writeln('   <tr>')
      newin.document.writeln('    <td align="center" bgcolor="#333333" onMouseOver="this.style.backgroundColor=\'#000000\';" onMouseOut="this.style.backgroundColor=\'\';"><font face="verdana,arial,helvetica" size="1"><img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.print()">Print me</a></font></td>')
      newin.document.writeln('    <td align="center" bgcolor="#333333" onMouseOver="this.style.backgroundColor=\'#000000\';" onMouseOut="this.style.backgroundColor=\'\';"><font face="verdana,arial,helvetica" size="1"><img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.close()">Close me</a></font></td>')
//      newin.document.writeln('    <td align="center" bgcolor="#333333"><font face="verdana,arial,helvetica" size="1"><img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.print()">Print me</a></font></td>')
//      newin.document.writeln('    <td align="center" bgcolor="#333333"><font face="verdana,arial,helvetica" size="1"><img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.close()">Close me</a></font></td>')
      newin.document.writeln('   </tr>')
      newin.document.writeln('  </table>')
      newin.document.writeln('<!--tool bar ends-->')
      newin.document.writeln('  </center>')
      newin.document.writeln(' </body>')
      newin.document.writeln('</html>')
      newin.document.close()
    } 
  }

  function explain_veg_type () {

    newin = window.open('','ermit_help','width=640,scrollbars=yes,resizable=1')
    var newWin = newin.document.open()
    if (newWin != null) {
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>ERMiT vegetation type</title>')
      newin.document.writeln('  <style>')
      newin.document.writeln('   BODY')
      newin.document.writeln('   {scrollbar-base-color:666666;scrollbar-face-color:#333333;scrollbar-highlight-color:#333333;scrollbar-shadow-color:666666;scrollbar-dark-shadow-color:ffffcc;scrollbar-arrow-color:ff6600}')
      newin.document.writeln('   .question {color:ffffcc}')
      newin.document.writeln('   .header {color:ffffcc}')
      newin.document.writeln('   .highlight {font-weight:bold}')
      newin.document.writeln('  </style>')
      newin.document.writeln(' </HEAD>')
      newin.document.writeln(' <body bgcolor="ivory" onLoad="top.window.focus()" link="white" vlink="white">')
      newin.document.writeln('  <font face="tahoma, sans serif">')
      newin.document.writeln('   <h3>ERMiT vegetation type</h3>')

      newin.document.writeln('   The user may select one of three vegetation types to be modeled:')
      newin.document.writeln('   <b>forest</b>, <b>range</b>, or <b>chaparral</b>.')
      newin.document.writeln('   <br><br>')
      newin.document.writeln('   This selection affects the parameter values behind the chosen soil texture.')
      newin.document.writeln('   <br><br>')
      newin.document.writeln('   If <i>range</i> or <i>chaparral</i> is chosen, then the user may specify')
      newin.document.writeln('   the percentage split among <b>shrub</b>, <b>grass</b>, and <b>bare soil</b>.')
      newin.document.writeln('   The default values for range are 15% shrub, 75% grass, 10% bare; for')
      newin.document.writeln('   chaparral, it is 80% shrub, 0% grass, and 20% bare.')

      newin.document.writeln(' <br><br>')
      newin.document.writeln(' <font size=2>')
      newin.document.writeln(' ERMiT v. ' + version + ' <i>explain_veg_type</i>')
      newin.document.writeln(' </font>')
      newin.document.writeln('<!--tool bar begins--><p>')
      newin.document.writeln('  <table bgcolor="#666666" width="40%" border="0" cellspacing="1" cellpadding="5" align="center">')
      newin.document.writeln('   <tr>')
      newin.document.writeln('    <td align="center" bgcolor="#333333" onMouseOver="this.style.backgroundColor=\'#000000\';" onMouseOut="this.style.backgroundColor=\'\';"><font face="verdana,arial,helvetica" size="1"><img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.print()">Print me</a></font></td>')
      newin.document.writeln('    <td align="center" bgcolor="#333333" onMouseOver="this.style.backgroundColor=\'#000000\';" onMouseOut="this.style.backgroundColor=\'\';"><font face="verdana,arial,helvetica" size="1"><img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.close()">Close me</a></font></td>')
      newin.document.writeln('   </tr>')
      newin.document.writeln('  </table>')
      newin.document.writeln('<!--tool bar ends-->')
      newin.document.writeln(' </body>')
      newin.document.writeln('</html>')
      newin.document.close()
    } 
  }

  function explain_topography () {

    newin = window.open('','ermit_help','width=640,scrollbars=yes,resizable=1')
    var newWin = newin.document.open()
    if (newWin != null) {
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>ERMiT hillslope topography</title>')
      newin.document.writeln('  <style>')
      newin.document.writeln('   BODY')
      newin.document.writeln('   {scrollbar-base-color:666666;scrollbar-face-color:#333333;scrollbar-highlight-color:#333333;scrollbar-shadow-color:666666;scrollbar-dark-shadow-color:ffffcc;scrollbar-arrow-color:ff6600}')
      newin.document.writeln('   .question {color:ffffcc}')
      newin.document.writeln('   .header {color:ffffcc}')
      newin.document.writeln('   .highlight {font-weight:bold}')
      newin.document.writeln('  </style>')
      newin.document.writeln(' </HEAD>')
      newin.document.writeln(' <body bgcolor="ivory" onLoad="top.window.focus()" link="white" vlink="white">')
      newin.document.writeln('  <font face="tahoma, sans serif">')
      newin.document.writeln('   <h3>ERMiT hillslope topography</h3>')
      newin.document.writeln('    The topographic inputs for ERMiT are <em>hillslope horizontal length</em> and')
      newin.document.writeln('    <em>hillslope top, middle</em>, and <em>toe gradients</em>.')
      newin.document.writeln('    The top and toe gradients each represent 10% of the hillslope length,')
      newin.document.writeln('    and the middle gradient represents 80%.')
      newin.document.writeln('    <br><br>')
      newin.document.writeln('    <em>Top gradient</em> is the steepness, in percent, of the upper portion of the hillslope.')
      newin.document.writeln('    Enter zero if the top of the slope starts at the top of the hill.')
      newin.document.writeln('    <br>')
      newin.document.writeln('    <em>Middle gradient</em> is the steepness, in percent, of the main portion of the hillslope.')
      newin.document.writeln('    <br>')
      newin.document.writeln('    <em>Toe gradient</em> is the steepness, in percent, of the lower portion of the hillslope.')
      newin.document.writeln('    <br>')
      newin.document.writeln('    These values may be obtained from a field survey, a forest map, or a GIS database.')
      newin.document.writeln('    <br><br>')
      newin.document.writeln('    <em>Hillslope horizontal length</em> is the length that would be measured directly off a topographic map [from where to where?].')
      newin.document.writeln('    <br><br>')
      newin.document.writeln('    <center>')
      newin.document.writeln('     <img src="/fswepp/images/ermit/erm_topo.gif" width="320" height="220" alt="Hillslope cross section"><br>')
      newin.document.writeln('    </center>')
      newin.document.writeln('    <br><br>')
      newin.document.writeln('    <font size=2>')
      newin.document.writeln('     ERMiT v. ' + version + ' <i>explain_topography</i>')
      newin.document.writeln('    </font>')
      newin.document.writeln('<!--tool bar begins--><p>')
      newin.document.writeln('  <table bgcolor="#666666" width="40%" border="0" cellspacing="1" cellpadding="5" align="center">')
      newin.document.writeln('   <tr>')
      newin.document.writeln('    <td align="center" bgcolor="#333333" onMouseOver="this.style.backgroundColor=\'#000000\';" onMouseOut="this.style.backgroundColor=\'\';"><font face="verdana,arial,helvetica" size="1"><img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.print()">Print me</a></font></td>')
      newin.document.writeln('    <td align="center" bgcolor="#333333" onMouseOver="this.style.backgroundColor=\'#000000\';" onMouseOut="this.style.backgroundColor=\'\';"><font face="verdana,arial,helvetica" size="1"><img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.close()">Close me</a></font></td>')
      newin.document.writeln('   </tr>')
      newin.document.writeln('  </table>')
      newin.document.writeln('<!--tool bar ends-->')
      newin.document.writeln(' </body>')
      newin.document.writeln('</html>')
      newin.document.close()
    } 
  }

  function explain_burn_severity () {

    newin = window.open('','climate_symbols','width=640,scrollbars=yes,resizable=1')
    var newWin = newin.document.open()
    if (newWin != null) {
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>ERMiT soil burn severity class</title>')
      newin.document.writeln('  <style>')
      newin.document.writeln('   BODY')
      newin.document.writeln('   {scrollbar-base-color:666666;scrollbar-face-color:#333333;scrollbar-highlight-color:#333333;scrollbar-shadow-color:666666;scrollbar-dark-shadow-color:ffffcc;scrollbar-arrow-color:ff6600}')
      newin.document.writeln('   .question {color:ffffcc}')
      newin.document.writeln('   .header {color:ffffcc}')
      newin.document.writeln('   .highlight {font-weight:bold}')
      newin.document.writeln('  </style>')
      newin.document.writeln(' </HEAD>')
      newin.document.writeln(' <body bgcolor="ivory" onLoad="top.window.focus()" link="white" vlink="white">')
      newin.document.writeln('  <font face="tahoma, sans serif">')
      newin.document.writeln('   <h3>ERMiT soil burn severity class</h3>')

      newin.document.writeln('   Fire effects on erosion are not homogeneous<sup>1</sup>.')
      newin.document.writeln('   Soil burn severity is a description of the impact of a fire on the soil and its litter layer.')
      newin.document.writeln('   The soil burn severity of a fire varies widely in space, depending on fuel load, moisture conditions and weather at the time of the fire, and the topography.')
      newin.document.writeln('   Variability in fire often creates mosaic landscapes with varying portions having low, moderate, and high soil burn severity.')
      newin.document.writeln('   Areas that are drier, such as those near ridge tops, and areas with greater amounts of fuel, may experience higher soil burn severity than')
      newin.document.writeln('   areas that are wetter, such as riparian areas.')
      newin.document.writeln('   <br><br>')
      newin.document.writeln('   The user may select "high," "moderate," or "low" soil burn severity for the hillside.')
      newin.document.writeln('   WEPP will model the hillslope as a set of one, two, or three overland flow elements (OFEs) on the')
      newin.document.writeln('   hillslope using a variety of soil burn severities based on the selected severity class (see figure).')
      newin.document.writeln('   <br><br>')
      newin.document.writeln('   The user may also select “unburned” for the hillslope.')
      newin.document.writeln('   WEPP will model the hillslope as one overland flow element (OFE) in an unburned condition.')
      newin.document.writeln('')
      newin.document.writeln('  <blockquote>')
      newin.document.writeln('    <table border=1>')
      newin.document.writeln('     <tr>')
      newin.document.writeln('      <td valign="bottom">')
      newin.document.writeln('       <font face="trebuchet, tahoma, arial, sans serif" size=-1>')
      newin.document.writeln('        Click on a colored bar below<br>to show the corresponding cross-section.<br><br>')
      newin.document.writeln('        <table border=0 bgcolor="gray">')
      newin.document.writeln('  <!-- High -->')
      newin.document.writeln('         <tr>')
      newin.document.writeln('          <td onClick=\'document.xs.src="/fswepp/images/ermit/hhh_.gif"\'><img src="/fswepp/images/ermit/red.gif" width=5><br><img src="/fswepp/images/ermit/red.gif" width=5><br><img src="/fswepp/images/ermit/red.gif" width=5></a></td>')
      newin.document.writeln('          <td onClick=\'document.xs.src="/fswepp/images/ermit/lhh_.gif"\'><img src="/fswepp/images/ermit/gold.gif" width=5><br><img src="/fswepp/images/ermit/red.gif" width=5><br><img src="/fswepp/images/ermit/red.gif" width=5></a></td>')
      newin.document.writeln('          <td onClick=\'document.xs.src="/fswepp/images/ermit/hlh_.gif"\'><img src="/fswepp/images/ermit/red.gif" width=5><br><img src="/fswepp/images/ermit/gold.gif" width=5><br><img src="/fswepp/images/ermit/red.gif" width=5></td>')
      newin.document.writeln('          <td onClick=\'document.xs.src="/fswepp/images/ermit/hhl_.gif"\'><img src="/fswepp/images/ermit/red.gif" width=5><br><img src="/fswepp/images/ermit/red.gif" width=5><br><img src="/fswepp/images/ermit/gold.gif" width=5></td>')
      newin.document.writeln('          <td><img src="/fswepp/images/ermit/gold_l.gif" width=5><br><img src="/fswepp/images/ermit/gold_l.gif" width=5><br><img src="/fswepp/images/ermit/red_l.gif" width=5></td>')
      newin.document.writeln('          <td><img src="/fswepp/images/ermit/gold_l.gif" width=5><br><img src="/fswepp/images/ermit/red_l.gif" width=5><br><img src="/fswepp/images/ermit/gold_l.gif" width=5></td>')
      newin.document.writeln('          <td><img src="/fswepp/images/ermit/red_l.gif" width=5><br><img src="/fswepp/images/ermit/gold_l.gif" width=5><br><img src="/fswepp/images/ermit/gold_l.gif" width=5></td>')
      newin.document.writeln('          <td><img src="/fswepp/images/ermit/gold_l.gif" width=5><br><img src="/fswepp/images/ermit/gold_l.gif" width=5><br><img src="/fswepp/images/ermit/gold_l.gif" width=5></td>')
      newin.document.writeln('          <td bgcolor="white"><font face="trebuchet, tahoma, arial, sans serif">&nbsp;HIGH soil burn severity</font></td>')
      newin.document.writeln('         </tr>')
      newin.document.writeln('    <!-- Moderate -->')
      newin.document.writeln('         <tr>')
      newin.document.writeln('          <td><img src="/fswepp/images/ermit/spacer.gif" width=5><br><img src="/fswepp/images/ermit/spacer.gif" width=5><br><img src="/fswepp/images/ermit/spacer.gif" width=5></td>')
      newin.document.writeln('          <td><img src="/fswepp/images/ermit/spacer.gif" width=5><br><img src="/fswepp/images/ermit/spacer.gif" width=5><br><img src="/fswepp/images/ermit/spacer.gif" width=5></td>')
      newin.document.writeln('          <td onClick=\'document.xs.src="/fswepp/images/ermit/hlh_.gif"\'><img src="/fswepp/images/ermit/red.gif" width=5><br><img src="/fswepp/images/ermit/gold.gif" width=5><br><img src="/fswepp/images/ermit/red.gif" width=5></td>')
      newin.document.writeln('          <td onClick=\'document.xs.src="/fswepp/images/ermit/hhl_.gif"\'><img src="/fswepp/images/ermit/red.gif" width=5><br><img src="/fswepp/images/ermit/red.gif" width=5><br><img src="/fswepp/images/ermit/gold.gif" width=5></td>')
      newin.document.writeln('          <td onClick=\'document.xs.src="/fswepp/images/ermit/llh_.gif"\'><img src="/fswepp/images/ermit/gold.gif" width=5><br><img src="/fswepp/images/ermit/gold.gif" width=5><br><img src="/fswepp/images/ermit/red.gif" width=5></td>')
      newin.document.writeln('          <td onClick=\'document.xs.src="/fswepp/images/ermit/lhl_.gif"\'><img src="/fswepp/images/ermit/gold.gif" width=5><br><img src="/fswepp/images/ermit/red.gif" width=5><br><img src="/fswepp/images/ermit/gold.gif" width=5></td>')
      newin.document.writeln('          <td><img src="/fswepp/images/ermit/red_l.gif" width=5><br><img src="/fswepp/images/ermit/gold_l.gif" width=5><br><img src="/fswepp/images/ermit/gold_l.gif" width=5></td>')
      newin.document.writeln('          <td><img src="/fswepp/images/ermit/gold_l.gif" width=5><br><img src="/fswepp/images/ermit/gold_l.gif" width=5><br><img src="/fswepp/images/ermit/gold_l.gif" width=5></td>')
      newin.document.writeln('          <td bgcolor="white"><font face="trebuchet, tahoma, arial, sans serif">&nbsp;MODERATE soil burn severity&nbsp;</font></td>')
      newin.document.writeln('         </tr>')
      newin.document.writeln('     <!-- Low -->')
      newin.document.writeln('         <tr>')
      newin.document.writeln('          <td><img src="/fswepp/images/ermit/spacer.gif" width=5><br><img src="/fswepp/images/ermit/spacer.gif" width=5><br><img src="/fswepp/images/ermit/spacer.gif" width=5></td>')
      newin.document.writeln('          <td><img src="/fswepp/images/ermit/spacer.gif" width=5><br><img src="/fswepp/images/ermit/spacer.gif" width=5><br><img src="/fswepp/images/ermit/spacer.gif" width=5></td>')
      newin.document.writeln('          <td><img src="/fswepp/images/ermit/spacer.gif" width=5><br><img src="/fswepp/images/ermit/spacer.gif" width=5><br><img src="/fswepp/images/ermit/spacer.gif" width=5></td>')
      newin.document.writeln('          <td><img src="/fswepp/images/ermit/spacer.gif" width=5><br><img src="/fswepp/images/ermit/spacer.gif" width=5><br><img src="/fswepp/images/ermit/spacer.gif" width=5></td>')
      newin.document.writeln('          <td onClick=\'document.xs.src="/fswepp/images/ermit/llh_.gif"\'><img src="/fswepp/images/ermit/gold.gif" width=5><br><img src="/fswepp/images/ermit/gold.gif" width=5><br><img src="/fswepp/images/ermit/red.gif" width=5></td>')
      newin.document.writeln('          <td onClick=\'document.xs.src="/fswepp/images/ermit/lhl_.gif"\'><img src="/fswepp/images/ermit/gold.gif" width=5><br><img src="/fswepp/images/ermit/red.gif" width=5><br><img src="/fswepp/images/ermit/gold.gif" width=5></td>')
      newin.document.writeln('          <td onClick=\'document.xs.src="/fswepp/images/ermit/hll_.gif"\'><img src="/fswepp/images/ermit/red.gif" width=5><br><img src="/fswepp/images/ermit/gold.gif" width=5><br><img src="/fswepp/images/ermit/gold.gif" width=5></td>')
      newin.document.writeln('          <td onClick=\'document.xs.src="/fswepp/images/ermit/lll_.gif"\'><img src="/fswepp/images/ermit/gold.gif" width=5><br><img src="/fswepp/images/ermit/gold.gif" width=5><br><img src="/fswepp/images/ermit/gold.gif" width=5></td>')
      newin.document.writeln('          <td bgcolor="white"><font face="trebuchet, tahoma, arial, sans serif">&nbsp;LOW soil burn severity</font></td>')
      newin.document.writeln('         </tr>')
      newin.document.writeln('        </table>')
      newin.document.writeln('       </font>')
      newin.document.writeln('      </td>')
      newin.document.writeln('      <td width=180 height=125>')
      newin.document.writeln('       <font face="trebuchet, tahoma, arial, sans serif">')
      newin.document.writeln('        <img name="xs" src="/fswepp/images/ermit/hhh_.gif" width=165 height=121>')
      newin.document.writeln('       </font>')
      newin.document.writeln('      </td>')
      newin.document.writeln('     </tr>')
      newin.document.writeln('    </table>')
      newin.document.writeln('   </blockquote>')
      newin.document.writeln('    <font size=-1>')
      newin.document.writeln('     <sup>1</sup> Robichaud, P.R., Miller, S.M., 1999.')
      newin.document.writeln('     <i>Spatial interpolation and simulation of post-burn duff thickness after prescribed fire.</i>')
      newin.document.writeln('     <b>International Journal of Wildland Fire</b> 9(2):137-143.')
      newin.document.writeln('    </font>')
      newin.document.writeln('    <br><br>')
      newin.document.writeln('  <font size=2>')
      newin.document.writeln('   ERMiT v. ' + version + ' <i>explain_burn_severity</i>')
      newin.document.writeln('  </font>')
      newin.document.writeln('<!--tool bar begins--><p>')
      newin.document.writeln('  <table bgcolor="#666666" width="40%" border="0" cellspacing="1" cellpadding="5" align="center">')
      newin.document.writeln('   <tr>')
      newin.document.writeln('    <td align="center" bgcolor="#333333" onMouseOver="this.style.backgroundColor=\'#000000\';" onMouseOut="this.style.backgroundColor=\'\';"><font face="verdana,arial,helvetica" size="1"><img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.print()">Print me</a></font></td>')
      newin.document.writeln('    <td align="center" bgcolor="#333333" onMouseOver="this.style.backgroundColor=\'#000000\';" onMouseOut="this.style.backgroundColor=\'\';"><font face="verdana,arial,helvetica" size="1"><img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.close()">Close me</a></font></td>')
      newin.document.writeln('   </tr>')
      newin.document.writeln('  </table>')
      newin.document.writeln('<!--tool bar ends-->')
      newin.document.writeln(' </body>')
      newin.document.writeln('</html>')
      newin.document.close()
    } 
  }

  function explain_community () {

    newin = window.open('','ermit_help','width=640,scrollbars=yes,resizable=1')
    var newWin = newin.document.open()
    if (newWin != null) {
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>ERMiT pre-fire community</title>')
      newin.document.writeln('  <style>')
      newin.document.writeln('   BODY')
      newin.document.writeln('   {scrollbar-base-color:666666;scrollbar-face-color:#333333;scrollbar-highlight-color:#333333;scrollbar-shadow-color:666666;scrollbar-dark-shadow-color:ffffcc;scrollbar-arrow-color:ff6600}')
      newin.document.writeln('   .question {color:ffffcc}')
      newin.document.writeln('   .header {color:ffffcc}')
      newin.document.writeln('   .highlight {font-weight:bold}')
      newin.document.writeln('  </style>')
      newin.document.writeln(' </HEAD>')
      newin.document.writeln(' <body bgcolor="ivory" onLoad="top.window.focus()" link="white" vlink="white">')
      newin.document.writeln('  <font face="tahoma, sans serif">')
      newin.document.writeln('   <h3>ERMiT pre-fire community</h3>')

      newin.document.writeln('If "Range" or "Chaparral" is selected for <i>Vegetation type,</i>')
      newin.document.writeln('then <i>Range/chaparral pre-fire community description</i> is active.')
      newin.document.writeln('Default values for ')
      newin.document.writeln('"Range" are 15% shrub, 75% grass, and 10% bare soil; for')
      newin.document.writeln('"Chaparral" they are 80% shrub, 0% grass, and 20% bare soil.')
      newin.document.writeln('The user may adjust the <i>shrub</i> and <i>grass</i> values; <i>bare</i> is calculated to')
      newin.document.writeln('keep a 100% total.')

      newin.document.writeln(' <br><br>')
      newin.document.writeln(' <font size=2>')
      newin.document.writeln(' ERMiT v. ' + version + ' <i>explain_community</i>')
      newin.document.writeln(' </font>')
      newin.document.writeln('<!--tool bar begins--><p>')
      newin.document.writeln('  <table bgcolor="#666666" width="40%" border="0" cellspacing="1" cellpadding="5" align="center">')
      newin.document.writeln('   <tr>')
      newin.document.writeln('    <td align="center" bgcolor="#333333" onMouseOver="this.style.backgroundColor=\'#000000\';" onMouseOut="this.style.backgroundColor=\'\';"><font face="verdana,arial,helvetica" size="1"><img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.print()">Print me</a></font></td>')
      newin.document.writeln('    <td align="center" bgcolor="#333333" onMouseOver="this.style.backgroundColor=\'#000000\';" onMouseOut="this.style.backgroundColor=\'\';"><font face="verdana,arial,helvetica" size="1"><img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.close()">Close me</a></font></td>')
      newin.document.writeln('   </tr>')
      newin.document.writeln('  </table>')
      newin.document.writeln('<!--tool bar ends-->')
      newin.document.writeln(' </body>')
      newin.document.writeln('</html>')
      newin.document.close()
    } 
  }

  function ravelcheck () {
    var which = window.document.ermit.SoilType.selectedIndex;
    if (which != 2) {
    }
    else {
      var soiltexture='sandy loam'
//      var rfg='20'
      var rfg=window.document.ermit.rfg.value;
//      var text='Soil texture: ' + soiltexture
//      alert(text);
//      newin = window.open('','dry_ravel','width=600,scrollbars=yes,resizable=yes')                                         
      newin = window.open('','dry_ravel')                                         
      newin.document.open()
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>ERMiT Dry ravel prediction</title>')
      newin.document.writeln('  <style>')
      newin.document.writeln('   BODY')
      newin.document.writeln('   {scrollbar-base-color:666666;scrollbar-face-color:#333333;scrollbar-highlight-color:#333333;scrollbar-shadow-color:666666;scrollbar-dark-shadow-color:ffffcc;scrollbar-arrow-color:ff6600}')
      newin.document.writeln('   .question {color:ffffcc}')
      newin.document.writeln('   .header {color:ffffcc}')
      newin.document.writeln('   .highlight {font-weight:bold}')
      newin.document.writeln('  </style>')
      newin.document.writeln(' </HEAD>')
      newin.document.writeln(' <body bgcolor="ivory" onLoad="top.window.focus()" link="white" vlink="white">')
      newin.document.writeln('  <font face="tahoma, sans serif">')
      newin.document.writeln(' <center>')
      newin.document.writeln(' <h3>ERMiT<br>Dry Ravel Estimator<br>prototype</h3>')
      newin.document.writeln(' <p>')
      newin.document.writeln(' <table border=1>')
       var severity = 'high'
       if (window.document.ermit.severity[1].checked) severity = 'moderate'
       if (window.document.ermit.severity[2].checked) severity = 'low'
      newin.document.writeln('  <tr><th align="right">Soil texture:</th><td align=right>' + soiltexture+'</td></tr>')
      newin.document.writeln('  <tr><th align="right">Rock content:</th><td align=right>' + rfg +'%</td></tr>')
      newin.document.writeln('  <tr><th align="right">Top gradient:</th><td align=right>' + window.document.ermit.top_slope.value + '%</td></tr>')
      newin.document.writeln('  <tr><th align="right">Middle gradient:</th><td align=right>' + window.document.ermit.avg_slope.value + '%</td></tr>')
      newin.document.writeln('  <tr><th align="right">Toe gradient:</th><td align=right>' + window.document.ermit.toe_slope.value + '%</td></tr>')
      newin.document.writeln('  <tr><th align="right">Soil burn severity:</th><td align=right>' + severity + '</td></tr>')
      newin.document.writeln('  </table>')
      newin.document.writeln(' <p>')
      newin.document.writeln('Given the proper climate:')
      newin.document.writeln(' <p>')
      newin.document.writeln('<font color="green">(No) ravel detected for top portion</font><br>')
      newin.document.writeln('<font color="red">(No) ravel detected for middle portion</font><br>')
      newin.document.writeln('<font color="red">(No) ravel detected for toe portion</font><br>')
      newin.document.writeln('<font color="red">(No) sediment will be delivered off-site</font><br>')
      newin.document.writeln('<p>')
      newin.document.writeln('  <font face="tahoma, sans serif">')
      newin.document.writeln('<table border=1 cellpadding=5>')
      newin.document.writeln(' <tr>')
      newin.document.writeln('  <th bgcolor="85d2f2">Trigger<br>level<br></th>')
      newin.document.writeln('  <th bgcolor="85d2f2">Sediment<br>transported<br>(t ha<sup>-1</sup>)</th>')
      newin.document.writeln('  <th bgcolor="85d2f2">Sediment<br>delivered off-site<br>(t ha<sup>-1</sup>)</th>')
      newin.document.writeln(' </tr>')
      newin.document.writeln(' <tr>')
      newin.document.writeln('  <th bgcolor="85d2f2">None</th>')
      newin.document.writeln('  <th>XX</th>')
      newin.document.writeln('  <th>XX</th>')
      newin.document.writeln(' </tr>')
      newin.document.writeln(' <tr>')
      newin.document.writeln('  <th bgcolor="85d2f2">Low</th>')
      newin.document.writeln('  <th>XX</th>')
      newin.document.writeln('  <th>XX</th>')
      newin.document.writeln(' </tr>')
      newin.document.writeln(' <tr>')
      newin.document.writeln('  <th bgcolor="85d2f2">Moderate</th>')
      newin.document.writeln('  <th>XX</th>')
      newin.document.writeln('  <th>XX</th>')
      newin.document.writeln(' </tr>')
      newin.document.writeln(' <tr>')
      newin.document.writeln('  <th bgcolor="85d2f2">High</th>')
      newin.document.writeln('  <th>XX</th>')
      newin.document.writeln('  <th>XX</th>')
      newin.document.writeln(' </tr>')
      newin.document.writeln('</table>')
      newin.document.writeln(' <br><br>')
      newin.document.writeln(' <font size=2>')
      newin.document.writeln('  ERMiT v. ' + version + ' <i>ravel_check</i>')
      newin.document.writeln(' </font>')
      newin.document.writeln('<!--tool bar begins--><p>')
      newin.document.writeln('  <table bgcolor="#666666" width="40%" border="0" cellspacing="1" cellpadding="5" align="center">')
      newin.document.writeln('   <tr>')
      newin.document.writeln('    <td align="center" bgcolor="#333333" onMouseOver="this.style.backgroundColor=\'#000000\';" onMouseOut="this.style.backgroundColor=\'\';"><font face="verdana,arial,helvetica" size="1"><img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.print()">Print me</a></font></td>')
      newin.document.writeln('    <td align="center" bgcolor="#333333" onMouseOver="this.style.backgroundColor=\'#000000\';" onMouseOut="this.style.backgroundColor=\'\';"><font face="verdana,arial,helvetica" size="1"><img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.close()">Close me</a></font></td>')
//      newin.document.writeln('    <td align="center" bgcolor="#333333"><font face="verdana,arial,helvetica" size="1"><img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.print()">Print me</a></font></td>')
//      newin.document.writeln('    <td align="center" bgcolor="#333333"><font face="verdana,arial,helvetica" size="1"><img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.close()">Close me</a></font></td>')
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

for $ii ( 0 .. $num_cli ) {

    #    print "    max_year[$ii] = " . $climate_year[$ii] . ";\n";
    print "    climate_name[$ii] = ", '"', $climate_name[$ii], '"', "\n";
}
print <<'theEnd';

  }

function RunningMsg3 (obj, text) {

  obj.value=text
//  document.fswepplogo.src='/fswepp/images/countdowns/60countdown.gif'
//  document.fswepplogo.src='/cgi-bin/fswepp/moon/phase.pl'
}

function RunningMsg (obj, text) {
   obj.value=text

   var which=randomintegeroneto(5)
//   alert(which)
// popup up up
  newin = window.open('','spinner',',scrollbars=yes,resizable=yes,height=50,width=50,status=yes')
//   newin = window.open('','spinner')
   newin.document.open()
   newin.document.writeln('<html>')
   newin.document.writeln(' <head>')
   newin.document.writeln('  <title>Ermit countdown</title>')
   newin.document.writeln(' </head>')
   newin.document.writeln(' <body bgcolor=\'#DAC6AF\' onLoad=\'self.focus()\'>')
   newin.document.write  ('  <img src=\'/fswepp/images/countdowns/60countdown')
   newin.document.writeln(which + '.gif\'width=70>')
   newin.document.writeln(' </body>')
   newin.document.writeln('</html>')
   newin.document.close()
}

function RunningMsg2 (obj, text) {
  obj.value=text
  newin = window.open('/cgi-bin/fswepp/moon/phase.pl','spinner',',scrollbars=yes,resizable=yes,height=250,width=300,status=yes')
}

  function checkRange(obj,min,max,def,unit,thistext) {
     if (isNumber(obj.value)) {                   // obj == document.ermit.BS
       if (obj.value < min) {                     // min == BSmin
         alert_text=thistext + " must be between " + min + " and " + max + unit
         alert(alert_text)
         obj.value=min
         obj.focus()
       }
       if (obj.value > max){
         alert_text=thistext + " must be between " + min + " and " + max + unit
         alert(alert_text)
         obj.value=max
       }
     } else {
         alert("Invalid entry for " + thistext + "!")
         obj.value=def
         obj.focus()
         obj.select()
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
     buttontext=''
     document.ravelgraphic.src='/fswepp/images/ermit/gotravelgrey.gif'                // 2004.09.16
    }
  else if (which == 1)       // silt loam
    {
     text = 'Glacial outwash areas; finer-grained granitics (SW, SP, SM, SC)';
     buttontext = ''
     document.ravelgraphic.src='/fswepp/images/ermit/gotravelgrey.gif'                // 2004.09.16
    }
  else if (which == 2)       // sandy loam
    {
     text = 'Ash cap native-surface road; alluvial loess native-surface road (ML, CL)'
     buttontext='Check for ravel'
     document.ravelgraphic.src='/fswepp/images/ermit/gotravelgrey.gif'                // 2004.09.16 2005.10.17
    }
  else                       // loam
    {
     text = 'Glacial tills, alluvium (GC, SM, SC, MH)';
     buttontext=''
     document.ravelgraphic.src='/fswepp/images/ermit/gotravelgrey.gif'                // 2004.09.16
    }
  window.status = text
//  window.document.ermit.ravel.value=buttontext		// 2004.09.16
  return true                           // p. 86
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

function blankStatus() {
  window.status = "Forest Service ERMiT"
  return true
}

function showRange(obj, head, min, max, unit) {
  window.status = head + min + " to " + max + unit
  return true
}

// The Central Randomizer 1.3 (C) 1997 by Paul Houle (houle@msc.cornell.edu)
// See:  https://www.msc.cornell.edu/~houle/javascript/randomizer.html
// https://developer.irt.org/script/343.htm

rnd.today=new Date();
rnd.seed=rnd.today.getTime();

function rnd() {
        rnd.seed = (rnd.seed*9301+49297) % 233280;
        return rnd.seed/(233280.0);
};

function randomintegeroneto(number) {
        return Math.ceil(rnd()*number);
};

// end central randomizer.

  // end hide -->
  </SCRIPT>
 </head>
theEnd

print ' <BODY link="#555555" vlink="#555555" onLoad="StartUp()">
  <font face="Arial, Geneva, Helvetica">
  <table width=100% border=0>
    <tr><td> 
       <a href="/fswepp/">
       <IMG src="/fswepp/images/fsweppic2.jpg" width=75 height=75
       name="fswepplogo"
       align="left" alt="Back to FS WEPP menu" border=0></a>
    <td align=center>
       <h2>
        <hr>
         <font color=red>E</font>rosion
         <font color=red>R</font>isk
         <font color=red>M</font>anagement
         <font color=red>T</font>ool<br>
        <hr>
      </h2>
      <td>
       <a href="/fswepp/docs/ermit/" target="docs">
       <img src="/fswepp/images/epage.gif" title="Read ERMiT documentation online"
        align="right" alt="Read the documentation" border=0></a>
    </table>
  <center>
  <FORM name="ermit" method="post" ACTION="/cgi-bin/fswepp/ermit/erm.pl">
<input type="hidden" size="1" name="me" value="',    $me,    '">
<input type="hidden" size="1" name="units" value="', $units, '">
<input type="hidden" size="1" name="debug" value="', $debug, '">
  <TABLE border="1" bgcolor="ivory">
';
print <<'theEnd';
     <tr align="top">
      <td align="center" bgcolor="#85d2d2">
       (<a onMouseOver="window.status='Ownership code -: Public (any computer could create)';return true"
           onMouseOut="window.status='Forest Service ERMiT'; return true">-</a>
        <a onMouseOver="window.status='Ownership code *: Personal climate (your computer created)';return true"
           onMouseOut="window.status='Forest Service ERMiT'; return true">*</a>)
       &nbsp;&nbsp;&nbsp;&nbsp;
       <a href="JavaScript:submitme('Describe Climate')"
             onMouseOver="window.status='Describe climate';return true"
             onMouseOut="window.status='Forest Service ERMiT'; return true">
       <b>Climate</b></a>
       &nbsp;&nbsp;&nbsp;&nbsp;
        <a href="javascript:explain_climate_symbols()"
           onMouseOver="window.status='Explain climate name symbols (new window)';return true"
           onMouseOut="window.status='Forest Service ERMiT'; return true">
           <!-- img src="/fswepp/images/quest_b.gif" width=14 height=12 border=0 alt="[?]" --> <!-- ZZZZ --> </a>
       (<a onMouseOver="window.status='Status code +: Parameters have been changed from standard-issue';return true"
           onMouseOut="window.status='Forest Service ERMiT'; return true">+</a>)
      </td>
      <th width=20 rowspan=5><br>
      </th>
      <td align="center" bgcolor="#85d2d2">
       <a href="JavaScript:submitme('Describe Soil')"
          onMouseOver="window.status='Describe soil';return true"
          onMouseOut="window.status='Forest Service ERMiT'; return true"
          title="Describe soil">
        <b>Soil Texture</b></a>
       <a href="javascript:explain_soil_texture()" title="Explain soil texture"
        onMouseOver="window.status='Explain soil texture (new window)'; return true"
        onMouseOut="window.status='Forest Service ERMiT'; return true">
        <img src="/fswepp/images/quest_b.gif" width=14 height=12 border=0 alt="[?]"></a>
      </td>
     </tr>
     <tr align=top>
      <td align="center" rowspan=3>
       <SELECT NAME="Climate" SIZE="7">
theEnd

### display personal climates, if any

if ( $num_cli > 0 ) {
    print '<OPTION VALUE="';
    print $climate_file[0];
    print '" selected> ', $climate_name[0], "\n";
}
for $ii ( 1 .. $num_cli ) {
    print '<OPTION VALUE="';
    print $climate_file[$ii];
    print '"> ', $climate_name[$ii], "\n";
}

#################
print <<'theEnd1';
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
       </td>
      </tr>
      <tr>
       <td align="center" bgcolor="#85d2d2">
        <b>Rock content</b>
         <a href="javascript:explain_rock_content()" title="Explain rock content"
             onMouseOver="window.status='Explain rock content (new window)'; return true"
             onMouseOut="window.status='Forest Service ERMiT'; return true">
         <img src="/fswepp/images/quest_b.gif" width=14 height=12 border=0 alt="[?]"></a>
       </td>
      </tr>
      <tr>
       <td align="center">
        <input type="text" name="rfg" size="5" value="20"
           onChange="checkRange(rfg,'rock content',0,50,20,'%')"
           onFocus="showRange(this.form,'Rock content: ',0,50,'%')"
           onBlur="blankStatus()"><b> %</b>&nbsp;
       </td>
      </tr>
      <tr>
       <td align=center>
      <input type="hidden" name="achtung" value="Run WEPP">
      <input type="SUBMIT" name="actionc" value="Custom Climate">
      <input type="button" value="Closest Wx" onclick="javascript:popupclosest()">
       </td>
       <td align="center">
     <!-- INPUT type="submit" name="ravel" value=""                # 2004.09.16
       onClick="javascript:ravelcheck(); return false;" -->
     <a href="javascript:ravelcheck()"><img src="/fswepp/images/ermit/gotravelgrey.gif" name="ravelgraphic" width="91" height="20" border="0"></a>
       </td>
      </tr>
    </table>
   <p>
    <table border=2 bgcolor="ivory">
     <tr>
      <th bgcolor=#85d2d2>
        Vegetation type
        <a href="javascript:explain_veg_type()" title="Explain vegetation type"
          onMouseOver="window.status='Explain vegetation type (new window)'; return true"
          onMouseOut="window.status='Forest Service ERMiT'; return true">
          <img src="/fswepp/images/quest_b.gif" width=14 height=12 border=0 alt="[?]"></a>
      </th>
      <th bgcolor=#85d2d2>
       Hillslope gradient
       <a href="javascript:explain_topography()" title="Explain hillslope gradient"
         onMouseOver="window.status='Explain hillslope gradient (new window)'; return true"
         onMouseOut="window.status='Forest Service ERMiT'; return true">
         <img src="/fswepp/images/quest_b.gif" width=14 height=12 border=0 alt="[?]"></a>
      </th>
      <th bgcolor=#85d2d2>
       Hillslope<br>horizontal length
       <a href="javascript:explain_topography()" title="Explain hillslope length"
         onMouseOver="window.status='Explain hillslope length (new window)'; return true"
         onMouseOut="window.status='Forest Service ERMiT'; return true">
         <img src="/fswepp/images/quest_b.gif" width=14 height=12 border=0 alt="[?]"></a>
      </th>
      <th bgcolor=#85d2d2>
         Soil burn<br>severity class
         <a href="javascript:explain_burn_severity()" title="Explain soil burn severity class"
          onMouseOver="window.status='Explain soil burn severity class (new window)'; return true"
          onMouseOut="window.status='Forest Service ERMiT'; return true">
          <img src="/fswepp/images/quest_b.gif" width=14 height=12 border=0 alt="[?]"></a>
      </th>
     </tr>
     <tr>
      <td align="center">&nbsp;&nbsp;
        <select name="vegetation" size="4" align="top"
          onclick="javascript:bushes();return true"
          onmouseout="window.status='Forest Service ERMiT'; return true">    
        <option value="forest" selected="selected"> Forest</option>
        <option value="range"> Range</option>
        <option value="chap"> Chaparral</option>
        </select>
      </td>
      <td align="right">
       <b>Top&nbsp;<input type="text" size="5" name="top_slope" value="0"
           onChange="checkRange(top_slope,'Hillslope top gradient',0,100,20,'%')"
           onFocus="showRange(this.form,'Hillslope top gradient: ',0,100,'%')"
           onBlur="blankStatus()"> %</b>&nbsp;&nbsp;<br>
        <b>Middle&nbsp;<input type="text" size="5" name="avg_slope" value="50"
           onChange="checkRange(avg_slope,'Hillslope middle gradient',0,100,20,'%')"
           onFocus="showRange(this.form,'Hillslope middle gradient: ',0,100,'%')"
           onBlur="blankStatus()"> %</b>&nbsp;&nbsp;<br>
        <b>Toe&nbsp;<input type="text" size="5" name="toe_slope" value="30"
           onChange="checkRange(toe_slope,'Hillslope toe gradient',0,100,20,'%')"
           onFocus="showRange(this.form,'Hillslope toe gradient: ',0,100,'%')"
           onBlur="blankStatus()">  %</b>&nbsp;&nbsp;
       </td>
theEnd1
if ( $units eq 'm' ) {
    print '      <td align="center"><b>
       &nbsp;&nbsp;<input type="text" size="5" name="length"  value="100"
           onChange="checkRange(length,\'hillslope horizontal length\',0,300,100,\' m\')"
           onFocus="showRange(this.form,\'Hillslope horizontal length: \',0,300,\' m\')"
           onBlur="blankStatus()">
       m</b>&nbsp;&nbsp;
      </td>
';
}
else {
    print '      <td align="center"><b>
       &nbsp;&nbsp;<input type="text" size="5" name="length"  value="300"
           onChange="checkRange(length,\'hillslope horizontal length\',0,1000,300,\' ft\')"
           onFocus="showRange(this.form,\'Hillslope horizontal length: \',0,1000,\' ft\')"
           onBlur="blankStatus()">
       ft</b>&nbsp;&nbsp;
      </td>
';
}
print <<'theEnd';
      <td>
       <input type="radio" name="severity" value="h"'> <b>High</b><br>
       <input type="radio" name="severity" value="m"'> <b>Moderate</b><br>
       <input type="radio" name="severity" value="l"' checked="checked"> <b>Low</b><br>
       <input type="radio" name="severity" value="u"'> <b>Unburned</b><br>
      </td>
     </tr>
     <tr>
      <td colspan="3" align="center" bgcolor="#85d2d2">
        <b>Range/chaparral pre-fire community description</b>
         <a href="javascript:explain_community()" title="Explain pre-fire community"
            onMouseOver="window.status='Explain pre-fire community (new window)'; return true"
            onMouseOut="window.status='Forest Service ERMiT';return true">
          <img src="/fswepp/images/quest_b.gif" width=14 height=12 border=0 alt="[?]"></a>
       </td>
       <td align=center bgcolor=gray>
        <!-- img name="burnsevpic" src="/fswepp/ermit/images/lowburn.gif" border=0 title="Soil burn severity permutations modeled" -->
       </td>
      </tr>
      <tr>
       <td bgcolor="yellow">
          <input name="pct_shrub" size="8" type="text" style="BACKGROUND-COLOR: lightyellow" 
           onChange="checkRange(pct_shrub,'shrub cover',0,100,20,'%')"
           onFocus="showRange(this.form,'Shrub cover: ',0,100,'%')"
           onBlur="javascvript:shrub()"><b> %&nbsp;shrub &nbsp;&nbsp;</b>   <!-- onchange calc others -->
       </td>
       <td bgcolor="lightgreen">
          <input name="pct_grass" size="8" type="text" style="BACKGROUND-COLOR: lightgreen"
           onChange="checkRange(pct_grass,'grass cover',0,100,20,'%')"
           onFocus="showRange(this.form,'Grass cover: ',0,100,'%')"
           onBlur="javascvript:grass()"><b> %&nbsp;grass &nbsp;&nbsp;</b>   <!-- onchange calc others -->
       </td>
       <td bgcolor="#eeddcc">
          <input name="pct_bare" size="8" type="text" style="BACKGROUND-COLOR: #eeddcc"
           onFocus="showRange(this.form,'Bare cover calculated: ',0,100,'%')"
           onBlur="javascvript:bare()">  %&nbsp;bare <!-- no change -->
       </td>
     </tr>
  </TABLE>
   <input type="hidden" name="climate_name">
    </b>
   <INPUT TYPE="hidden" NAME="Units" VALUE="m">
     <br>
     <INPUT TYPE="SUBMIT" name="actionw" VALUE="Run ERMiT"
       onClick='RunningMsg3(this.form.actionw,"Running ERMiT..."); this.form.achtung.value="Run WEPP"'>
       <font size=1>
       </font>
   </center>
  </form>
  <p>

theEnd

$wc    = `wc ../working/' . currentLogDir() . '/we.log`;
@words = split " ", $wc;
$runs  = @words[0];

# print "personality '<b>$me</b>'<br><b>$runs</b> ERMiT runs in 2005 (<b>1,550</b> runs in 2004)<br>\n";

#  $wc  = `wc ../working/we.log`;
#  @words = split " ", $wc;
#  $runs = @words[0];

print '

   <hr>
    <table border=0>
     <tr>
      <td valign="top" bgcolor="white">
       <font face="tahoma, arial, helvetica, sans serif" size=1>
        ERMiT allows users to predict the probability of a given amount of sediment delivery from the base of a
        hillslope following variable burns on forest, rangeland, and chaparral conditions in each of five years
        following wildfire.
<br><br>

ERMiT version <a href="https://github.com/wepp-in-the-woods/fswepp-docker/commits/main/var/www/cgi-bin/fswepp/ermit/ermit.pl">', $version, '</a>
<br><br>
<b>Citation:</b>
 <p align="left" class="Reference">

        Robichaud, Peter R.; Elliot, William J.; Pierson, Fredrick B.; Hall, David E.; Moffet, Corey A.
        2014.
        <b>Erosion Risk Management Tool (ERMiT).</b>
        [Online at &lt;https://forest.moscowfsl.wsu.edu/fswepp/&gt;.]
        Moscow, ID: U.S. Department of Agriculture, Forest Service, Rocky Mountain Research Station.
</p>

        <b>', $runs, '</b> ERMiT runs YTD<br>
';
print
"        $remote_host &ndash; $remote_address ($user_really) personality '<b>$me</b>'<br>
        $user_ID_really<br>";

print
"Log of FS WEPP runs for IP and personality <a href=\"/cgi-bin/fswepp/runlogger.pl?ip=$remote_address$me\" target=\"_rl\">$remote_address$me</a>";

if ($debug) {
    print "
    Host: $remote_host &ndash;
    Address: $remote_address &ndash;
    Forwarded for: $http_x_forwarded_for";
}
print '
       </font>
      </td>
      <td valign="top" rowspan=2>
      </td>
     </tr>
     <tr>
      <td valign="top" bgcolor="lightgoldenrodyellow">
       <font face="tahoma, arial, helvetica, sans serif" size=1>
   <!-- 
        ERMiT predicts the probability associated with a given amount of soil erosion in each of five years following wildfire.
        ERMiT allows users to predict erosion following variable burns on forest, rangeland, and chaparral conditions.
    -->
       </font>
      </td>
     </tr>
    </table>

  </font>
 </body>
</html>
';
