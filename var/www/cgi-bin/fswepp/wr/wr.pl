#!/usr/bin/perl

use warnings;
use CGI;
use CGI qw(escapeHTML header);

use MoscowFSL::FSWEPP::CligenUtils qw(CreateCligenFile GetParSummary GetParLatLong);
use MoscowFSL::FSWEPP::FsWeppUtils qw(CreateSlopeFileWeppRoad get_version printdate get_thisyear_and_thisweek get_user_id);

use String::Util qw(trim);

$| = 1;    # flush output buffers

my $version = get_version(__FILE__);
my $user_ID = get_user_id();

my $debug = 0;
my ($thisyear, $thisweek) = get_thisyear_and_thisweek();
my $weppversion = "wepp2010";

my $cgi = CGI->new;
$action =
    escapeHTML( $cgi->param('ActionC') )
  . escapeHTML( $cgi->param('ActionW') )
  . escapeHTML( $cgi->param('ActionCD') )
  . escapeHTML( $cgi->param('ActionSD') );
chomp $action;

$traffic      = escapeHTML( $cgi->param('traffic') );
$units        = escapeHTML( $cgi->param('units') );
$achtung      = escapeHTML( $cgi->param('achtung') );
$CL           = escapeHTML( $cgi->param('Climate') );
$climate_name = escapeHTML( $cgi->param('climate_name') );

$runLogFile = "../working/" . $user_ID . ".run.log";



# ======================  DESCRIBE SOIL  ======================

if ( $achtung =~ /Describe Soil/ ) {
    $UBR   = escapeHTML( $cgi->param('Rock') ) * 1;   # Rock fragment percentage
    $units = escapeHTML( $cgi->param('units') );
    $SoilType = escapeHTML( $cgi->param('SoilType') )
      ;    # get SoilType (loam, ... pclay) # HR
    $surface = escapeHTML( $cgi->param('surface') )
      ;    # paved, graveled or native      # HR
    $slope = escapeHTML( $cgi->param('SlopeType') );    # get slope type
    if    ( substr( $surface, 0, 1 ) eq 'g' ) { $surf = 'g' }    # HR
    elsif ( substr( $surface, 0, 1 ) eq 'p' ) { $surf = 'p' }    # HR
    else                                      { $surf = '' }     # HR
    if    ( $slope eq 'inveg' )    { $tauC = '10' }    # critical shear (N/M^2)
    elsif ( $slope eq 'outunrut' ) { $tauC = '2' }     # HR
    elsif ( $slope eq 'outrut' )   { $tauC = '2' }     # HR
    elsif ( $slope eq 'inbare' )   { $tauC = '2' }     # HR
    if    ( $slope eq 'inbare' && $surf eq 'p' ) { $tauC = '1' }    # HR
    $soilFile = '3' . $surf . $SoilType . $tauC . '.sol';           # HR

    if    ( $surface eq 'graveled' ) { $URR = 65;   $UFR = ( $UBR + 65 ) / 2 }
    elsif ( $surface eq 'paved' )    { $URR = 95;   $UFR = ( $UBR + 65 ) / 2 }
    else                             { $URR = $UBR; $UFR = $UBR }

    $working      = '../working';
    $unique       = 'wepp' . '-' . $$;
    $newSoilFile  = "$working/" . $unique . '.sol';
    $responseFile = "$working/" . $unique . '.in';
    $outputFile   = "$working/" . $unique . '.out';
    $stoutFile    = "$working/" . $unique . '.stout';
    $sterFile     = "$working/" . $unique . '.sterr';
    $slopeFile    = "$working/" . $unique . '.slp';
    $soilPath     = 'data/';
    $manPath      = 'data/';
    $wepproad     = "/cgi-bin/fswepp/wr/wepproad.pl";
    $soilFilefq   = $soilPath . $soilFile;

    &CreateSoilFile;

    print header('text/html');
    print '<HTML>
 <HEAD>
  <TITLE>WEPP:Road -- Soil Parameters</TITLE>
 </HEAD>
 <BODY>
  <font face="Arial, Geneva, Helvetica">
   <center><h1>WEPP:Road Soil Parameters</h1></center>
   <blockquote>
';

    if    ( $surf eq 'g' ) { print 'Graveled ' }
    elsif ( $surf eq 'p' ) { print 'Paved ' }      # HR
    if    ( $SoilType eq 'clay' ) {
        print "clay loam (MH, CH)<br>\n";
        print
          "Shales and similar decomposing fine-grained sedimentary rock<br>\n";
    }
    elsif ( $SoilType eq 'loam' ) {
        print "loam<br>\n";
        print "<br>\n";
    }
    elsif ( $SoilType eq 'sand' ) {
        print "sandy loam (SW, SP, SM, SC)<br>\n";
        print "Glacial outwash areas; finer-grained granitics and sand<br>\n";
    }
    elsif ( $SoilType eq 'silt' ) {
        print "silt loam (ML, CL)<br>\n";
        print "Ash cap or alluvial loess<br>\n";
    }
    if   ( $tauC == 10 ) { print 'High ' }
    else                 { print 'Low ' }    # HR
    print "critical shear<br>\n";            # HR

    #     if ($conduct == 2) {print 'Low '} else {print 'High '}
    #     print "conductivity<br>\n";

    print "     <hr><b><font face=courier><pre>\n";
    open SOIL, "<$newSoilFile";
    $weppver = <SOIL>;
    $comment = <SOIL>;
    while ( substr( $comment, 0, 1 ) eq "#" ) {
        chomp $comment;
        print $comment, "\n";
        $comment = <SOIL>;
    }
    print "
      </pre>
     </font>
    </b>
    <center>
     <table border=1>
";
    $record = <SOIL>;
    @vals   = split " ", $record;
    $ntemp  = @vals[0];    # no. flow elements or channels
    $ksflag = @vals[1];    # 0: hold hydraulic conductivity constant
                           # 1: use internal adjustments to hydr con

    for $i ( 1 .. $ntemp ) {    # Element $i
        print '       <tr><th colspan=3 bgcolor="#85D2D2">', "\n";
        $record      = <SOIL>;
        @descriptors = split "'", $record;
        print "       @descriptors[1]   ";            # slid: Road, Fill, Forest
        print "       texture: @descriptors[3]\n";    # texid: soil texture
        ( $nsl, $salb, $sat, $ki, $kr, $shcrit, $avke ) = split " ",
          @descriptors[4];

        #      @vals = split " ", @descriptors[4];
        #      print "       No. soil layers: $nsl\n";
        print
"       <tr><th align=left>Albedo of the bare dry surface soil<td>$salb<td>\n";
        print
"       <tr><th align=left>Initial saturation level of the soil profile porosity<td>$sat<td>m/m\n";
        print
"       <tr><th align=left>Baseline interrill erodibility parameter (<i>k<sub>i</sub></i>)<td>$ki<td>kg*s/m<sup>4</sup>\n";
        print
"       <tr><th align=left>Baseline rill erodibility parameter (<i>k<sub>r</sub></i>)<td>$kr<td>s/m\n";
        print
"       <tr><th align=left>Baseline critical shear parameter<td>$shcrit<td>N/m<sup>2</sup>\n";
        print
"       <tr><th align=left>Effective hydraulic conductivity of surface soil<td>$avke<td>mm/h\n";
        for $layer ( 1 .. $nsl ) {
            $record = <SOIL>;
            ( $solthk, $sand, $clay, $orgmat, $cec, $rfg ) = split " ", $record;
            print
              "       <tr><td><br><th colspan=2 bgcolor=#85D2D2>layer $layer\n";
            print
"       <tr><th align=left>Depth from soil surface to bottom of soil layer<td>$solthk<td>mm\n";
            print
              "       <tr><th align=left>Percentage of sand<td>$sand<td>%\n";
            print
              "       <tr><th align=left>Percentage of clay<td>$clay<td>%\n";
            print
"       <tr><th align=left>Percentage of organic matter (by volume)<td>$orgmat<td>%\n";
            print
"       <tr><th align=left>Cation exchange capacity<td>$cec<td>meq per 100 g of soil\n";
            print
"       <tr><th align=left>Percentage of rock fragments (by volume)<td> $rfg<td>%\n";
        }    # for $layer (1..$nsl)
    }    # for $i (1..$ntemp)
    close SOIL;
    print '     </table>
     <br>
     <hr>
     <br>
     <form method="post" action="wepproad.sol"
      <br><br>
       <center>
        <a href="JavaScript:window.history.go(-1)">
         <img src="/fswepp/images/rtis.gif"
          alt="Return to input screen" border="0" align=center></a>
         <input type="hidden" value="', $soilFile, '" name"filename">
     </form>
    </center><p><hr><p></blockquote>
';
    die;
}    # if ($achtung =~ /Describe Soil/)

# =======================  Run WEPP  =========================
$units   = escapeHTML( $cgi->param('units') );
$ST      = escapeHTML( $cgi->param('SoilType') ); # Soil type (loam, ..., pclay)
$surface = escapeHTML( $cgi->param('surface') );  # Paved, graveled or native
$URL     = $cgi->param('RL') * 1;      # Road length -- buffer spacing (free)
$URS     = $cgi->param('RS') * 1;      # Road gradient (free)
$URW     = $cgi->param('RW') * 1;      # Road width (free)
$UFL     = $cgi->param('FL') * 1;      # Fill length (free)
$UFS     = $cgi->param('FS') * 1;      # Fill steepness (free)
$UBL     = $cgi->param('BL') * 1;      # Buffer length (free)
$UBS     = $cgi->param('BS') * 1;      # Buffer steepness (free)
$UBR     = $cgi->param('Rock') * 1;    # Rock fragment percentage
$slope   = escapeHTML( $cgi->param('SlopeType') )
  ;    # Slope type (outunrut, inbare, inveg, outrut)
$design = $slope;
if    ( $slope eq "outunrut" ) { $design = "Outsloped, unrutted" }
elsif ( $slope eq "inbare" )   { $design = "Insloped, bare ditch" }
elsif ( $slope eq "inveg" )  { $design = "Insloped, vegetated or rocked ditch" }
elsif ( $slope eq "outrut" ) { $design = "Outsloped, rutted" }

# DEH 4/13/2000

if    ( $ST eq 'clay' ) { $STx = 'clay loam' }
elsif ( $ST eq 'silt' ) { $STx = 'silt loam' }
elsif ( $ST eq 'sand' ) { $STx = 'sandy loam' }
elsif ( $ST eq 'loam' ) { $STx = 'loam' }

if    ( $slope eq 'inveg' )    { $slopex = 'insloped vegetated' }
elsif ( $slope eq "outunrut" ) { $slopex = 'outsloped unrutted' }
elsif ( $slope eq "outrut" )   { $slopex = 'outsloped rutted' }
elsif ( $slope eq "inbare" )   { $slopex = 'insloped bare' }

$outputf = escapeHTML( $cgi->param('Full') );
$outputi = escapeHTML( $cgi->param('Slope') );
$years   = escapeHTML( $cgi->param('years') );

$working = '../working';

#    $unique='wepp' . time . '-' . $$;
$unique       = 'wepp' . '-' . $$;
$newSoilFile  = "$working/" . $unique . '.sol';
$responseFile = "$working/" . $unique . '.in';
$outputFile   = "$working/" . $unique . '.out';
$stoutFile    = "$working/" . $unique . '.stout';
$sterFile     = "$working/" . $unique . '.sterr';
$slopeFile    = "$working/" . $unique . '.slp';
$soilPath     = 'data/';
$manPath      = 'data/';

$host        = $ENV{REMOTE_HOST} // '';
$host        = $ENV{REMOTE_ADDR} if ( $host eq '' );
$user_really = $ENV{'HTTP_X_FORWARDED_FOR'};
$host        = $user_really if ( $user_really ne '' );

$rcin = &checkInput;
if ( $rcin >= 0 ) {
    if    ( substr( $surface, 0, 1 ) eq 'g' ) { $surf = 'g' }    #HR
    elsif ( substr( $surface, 0, 1 ) eq 'p' ) { $surf = 'p' }    #HR
    else                                      { $surf = '' }     #HR
    if    ( $slope eq 'inveg' )    { $tauC = '10'; $manfile = '3inslope.man' }
    elsif ( $slope eq 'outunrut' ) { $tauC = '2';  $manfile = '3outunr.man' }
    elsif ( $slope eq 'outrut' )   { $tauC = '2';  $manfile = '3outrut.man' }
    elsif ( $slope eq 'inbare' )   { $tauC = '2';  $manfile = '3inslope.man' }
    if    ( $traffic eq 'none' ) {
        if ( $manfile eq '3inslope.man' ) {
            $manfile = '3inslopen.man';
        }    # DEH 07/10/2002
        if ( $manfile eq '3outunr.man' ) { $manfile = '3outunrn.man' }
        if ( $manfile eq '3outrut.man' ) { $manfile = '3outrutn.man' }
    }
    $zzveg = $manPath . $manfile;
    if ( $slope eq 'inbare' && $surf eq 'p' ) { $tauC = '1' }
    $soilFile   = '3' . $surf . $ST . $tauC . '.sol';
    $soilFilefq = $soilPath . $soilFile;
    $zzsoil     = &CreateSoilFile;
    $zzslope    = &CreateSlopeFileWeppRoad(
        $URS, $UFS,   $UBS,   $URW,       $URL, $UFL,
        $UBL, $units, $slope, $slopeFile, $debug
    );
    ( $climateFile, $climatePar ) =
      &CreateCligenFile( $CL, $unique, $years2sim, $debug );
    $climatePar = "$CL.par";
    $zzresp     = &CreateResponseFile;

    @args = ("../$weppversion <$responseFile >$stoutFile 2>$sterFile");
    system @args;

    unlink $climateFile;    # be sure this is right file .....

    print header('text/html');
    print "<HTML>
 <HEAD>
  <TITLE>WEPP:Road Results</TITLE>  
   <script>
";

    print '
  function showslopefile() {
    var properties="menubar,scrollbars,resizable"
    filewindow = window.open("","file",properties)
    filewindow.document.open()
    if (filewindow && filewindow.open && !filewindow.closed) {
      filewindow.focus
      filewindow.document.writeln("<head><title>WEPP slope file ', $unique,
      '<\/title><\/head>")
      filewindow.document.writeln("<body><font face=\'courier\'><pre>")
';

    open WEPPFILE, "<$zzslope";

    while (<WEPPFILE>) {
        chomp;
        print '      filewindow.document.writeln("', $_, '")', "\n";
    }
    close WEPPFILE;
    print '      filewindow.document.writeln("<\/pre><\/font><\/body><\/html>")
      filewindow.document.close()
    }
    return false
  }

  function showsoilfile() {
    var properties="menubar,scrollbars,resizable"
    filewindow = window.open("","file",properties)
    filewindow.document.open()
    if (filewindow && filewindow.open && !filewindow.closed) {
      filewindow.focus
      filewindow.document.writeln(" <head><title>WEPP soil file ', $unique,
      '<\/title><\/head>")
      filewindow.document.writeln(" <body><font face=\'courier\'><pre>")
//    filewindow.document.writeln("', $zzsoil, '")
';
    open WEPPFILE, "<$zzsoil";
    while (<WEPPFILE>) {
        chomp;
        print '      filewindow.document.writeln("', $_, '")', "\n";
    }
    close WEPPFILE;
    print '      filewindow.document.writeln("<\/pre><\/font><\/body><\/html>")
      filewindow.document.close()
    }
    return false
  }

  function showresponsefile() {
    var properties="menubar,scrollbars,resizable"
    filewindow = window.open("","file",properties)
    filewindow.document.open()
    if (filewindow && filewindow.open && !filewindow.closed) {
      filewindow.focus
      filewindow.document.writeln("<head><title>WEPP response file ', $unique,
      '<\/title><\/head>")
      filewindow.document.writeln("<body><pre>")
';
    open WEPPFILE, "<$zzresp";
    while (<WEPPFILE>) {
        chomp;
        print '      filewindow.document.writeln("', $_, '")', "\n";
    }
    close WEPPFILE;
    print '      filewindow.document.writeln("<\/pre><\/body><\/html>")
      filewindow.document.close()
    }
    return false
  }

  function showvegfile() {
    var properties="menubar,scrollbars,resizable"
    filewindow = window.open("","file",properties)
    filewindow.document.open()
    if (filewindow && filewindow.open && !filewindow.closed) {
      filewindow.focus
      filewindow.document.writeln("<head><title>WEPP vegetation file ', $unique,
      '<\/title><\/head>")
      filewindow.document.writeln("<body><pre>")
';
    $line = 0;
    open WEPPFILE, "<$zzveg";
    while (<WEPPFILE>) {
        chomp;
        print '      filewindow.document.writeln("', $_, '")', "\n";
        $line += 1;

        #        last if ($line > 100);
        last if (/Management Section/);
    }
    close WEPPFILE;
    print
      '      filewindow.document.writeln("    <\/pre>\n  <\/body>\n<\/html>")
      filewindow.document.close()
    }
    return false
  }

  function showextendedoutput() {
    var properties="menubar,scrollbars,resizable"
    filewindow = window.open("","file",properties)
    filewindow.document.open()
    if (filewindow && filewindow.open && !filewindow.closed) {
      $z=0
    }
    else {
      return false
    }
    filewindow.focus
    filewindow.document.writeln("<head><title>WEPP output file ', $unique,
      '<\/title><\/head>")
    filewindow.document.writeln("<body><font face=\'courier\'><pre>")
';
    open WEPPFILE, "<$outputFile";
    while (<WEPPFILE>) {
        s/\015$//
          ; # dos2unix:     https://lists.samba.org/archive/samba/2000-September/021008.html
        chomp;
        print '      filewindow.document.writeln("', $_, '")', "\n";
    }
    close WEPPFILE;
    print '      filewindow.document.writeln("<\/pre><\/font><\/body><\/html>")
    filewindow.document.close()
    return false
  }

  function showcligenparfile() {
    var properties="menubar,scrollbars,resizable"
    filewindow = window.open("","file",properties)
    filewindow.document.open()
    if (filewindow && filewindow.open && !filewindow.closed) {
      filewindow.focus
      filewindow.document.writeln("<head><title>WEPP weather file ', $unique,
      '<\/title><\/head>")
      filewindow.document.writeln("<body><pre>")
';

    open WEPPFILE, "<$climatePar";
    while (<WEPPFILE>) {
        chomp;
        chop;
        print '      filewindow.document.writeln("', $_, '")', "\n";
    }
    close WEPPFILE;
    print '      filewindow.document.writeln("   <\/pre>\n  <\/body>\n<\/html>")
      filewindow.document.close()
    }
    return false
  }
';

    print '
   </script>
 </head>
 <BODY>
  <font face="Arial, Geneva, Helvetica">
   <blockquote>
    <CENTER>
     <font face="Arial, Geneva, Helvetica">
      <table width="90%">
       <tr>
        <td>
         <a href="JavaScript:window.history.go(-1)">
          <img src="/fswepp/images/road4.gif"
          align=left border=1
          width=50 height=50
          alt="Return to WEPP:Road input screen" 
          onMouseOver="window.status=', "'Return to WEPP:Road input screen'",
      '; return true"
          onMouseOut="window.status=', "' '", '; return true">
         </a>
        </td>
        <td align=center>
         <hr>
         <h2>WEPP:Road Results</h2>
         <hr>
        </td>
        <td>
         <a href="/fswepp/docs/wroadimg.html#wrout" target="_docs">
          <img src="/fswepp/images/ipage.gif"
          align="right" alt="Read the documentation" border=0
          onMouseOver="window.status=\'Read the documentation\'; return true"
          onMouseOut="window.status=\' \'; return true">
         </a>
        </td>
       </tr>
     </table>
    </center>
';

    $found = &parseWeppResults;

    print '  <br><center><font size=-1>WEPP files: 
    [ <a href="javascript:void(showslopefile())">slope</a>
    | <a href="javascript:void(showsoilfile())">soil</a>
    | <a href="showmanfile.pl?f=' . $manfile
      . '" target="_manfile">vegetation</a>
    | <a href="javascript:void(showcligenparfile())">weather</a>
    | <a href="javascript:void(showresponsefile())">response</a>
    || <a href="javascript:void(showextendedoutput())">results</a> ]
     </font>
    </center>
';
}    #   if ($rcin >= 0)

#    | <a href="javascript:void(showvegfile())">vegetation</a>
else {
    print header('text/html');

    print '
<HTML>                                       
 <HEAD>                                      
   <TITLE>WEPP:Road -- error messages</TITLE>
 </HEAD>                                     
 <BODY>
  <font face="Arial, Geneva, Helvetica">
   <blockquote>
    <center>
     <table width="90%">
      <tr>
       <td>
        <a href="JavaScript:window.history.go(-1)">
         <img src="/fswepp/images/road4.gif"
         align=left border=1
         width=50 height=50
         alt="Return to WEPP:Road input screen"
         onMouseOver="window.status=', "'Return to WEPP:Road input screen'",
      '; return true" 
         onMouseOut="window.status=', "' '", '; return true">
        </a>
       </td>
       <td align=center>
        <hr>
        <h2>WEPP:Road Results</h2>
        <hr>
       </td>
       <td>
        <a HREF="/fswepp/docs/wroadimg.html#wrout">
         <img src="/fswepp/images/ipage.gif"
         align="right" alt="Read the documentation" border=0
         onMouseOver="window.status=\'Read the documentation\'; return true"
         onMouseOut="window.status=\' \'; return true">
        </a>
       </td>
      </tr>
     </table>
    <font color="red">', $error_message, '</font>
    <br> 
   </center>
';

}    #   if ($rcin >= 0)

print '
   <hr>
   <table width=90%>
    <tr>
     <td><font face="Arial, Geneva, Helvetica" size=-2>
     WEPP:Road results version 
<!--a href="/fswepp/history/wrrver.html"-->
<a href="https://github.com/wepp-in-the-woods/fswepp-docker/commits/main/var/www/cgi-bin/fswepp/wr/wr.pl">',
  $version, '</a> based on WEPP ', $weppver, '<br>
     by 
     <a HREF="https://forest.moscowfsl.wsu.edu/people/engr/dehall.html" target="o">Hall</A> and
     Anderson;
     Project leader 
     <a HREF="https://forest.moscowfsl.wsu.edu/people/engr/welliot.html" target="o">Bill Elliot</a><BR>
     USDA Forest Service, Rocky Mountain Research Station, Moscow, ID 83843
     <br>';
&printdate;
print '<br>
     WEPP:Road run ID ', $unique, '
    </td>
   </tr>
  </table>
 </BODY>
</HTML>
';

#   unlink <"$working/$unique.*">;

unlink $responseFile;
unlink $outputFile;
unlink $stoutFile;
unlink $sterFile;
unlink $slopeFile;
unlink $newSoilFile;    # 2006.02.23 DEH

################################# start 2009.10.29 DEH

#  record run in user wepp run log file

$climate_trim = trim($climate_name);

open RUNLOG, ">>$runLogFile";
flock( RUNLOG, 2 );
print RUNLOG "WR\t$unique\t", '"';
printf RUNLOG "%0.2d:%0.2d ", $hour, $min;
print RUNLOG $ampm[$ampmi], "  ", $days[$wday], " ", $months[$mon], " ", $mday,
  ", ", $year + 1900, '"', "\t", '"';
print RUNLOG $climate_trim, '"', "\t";
print RUNLOG "$years2sim\t";
print RUNLOG "$ST\t";         # Soil type (loam, ..., pclay)
print RUNLOG "$surface\t";    # Paved, graveled or native
print RUNLOG "$URL\t";        # Road length -- buffer spacing (free)
print RUNLOG "$URS\t";        # Road gradient (free)
print RUNLOG "$URW\t";        # Road width (free)
print RUNLOG "$UFL\t";        # Fill length (free)
print RUNLOG "$UFS\t";        # Fill steepness (free)
print RUNLOG "$UBL\t";        # Buffer length (free)
print RUNLOG "$UBS\t";        # Buffer steepness (free)
print RUNLOG "$UBR\t";        # Rock fragment percentage
print RUNLOG "$slope\t";      # Slope type (outunrut, inbare, inveg, outrut)
print RUNLOG "$units\n";
close RUNLOG;

################################# end 2009.10.29 DEH

#  record activity in WEPP:Road log (if running on remote server)


my ($lat, $long) = GetParLatLong($climatePar);

# 2008.06.04 DEH end
open WRLOG, ">>../working/_$thisyear/wr.log";    # 2012.12.31 DEH
flock( WRLOG, 2 );
print WRLOG "$host\t\"";
printf WRLOG "%0.2d:%0.2d ", $hour, $min;
print WRLOG $ampm[$ampmi], "  ", $days[$wday], " ", $months[$mon], " ",
  $mday, ", ", $year + 1900, "\"\t";
print WRLOG $years2sim, "\t";
print WRLOG '"', trim($climate_name), "\"\t";

#      print WRLOG $lat_long,"\n";			# 2008.06.04 DEH
print WRLOG "$lat\t$long\n";                     # 2008.06.04 DEH

#       print WRLOG $climate_name,"\n";                 # 2008.06.04 DEH
close WRLOG;

#    open CLIMLOG, '>../working/lastclimate.txt';	# 2005.07.14 DEH
open CLIMLOG, ">../working/_$thisyear/lastclimate.txt";    # 2012.12.31 DEH
flock CLIMLOG, 2;
print CLIMLOG 'WEPP:Road: ', trim($climate_name);
close CLIMLOG;

# if (!-e "../working/_$thisyear") create it
# if (!-e "../working/_$thisyear/wr") create it

$ditlogfile = ">>../working/_$thisyear/wr/" . $thisweek;    # 2012.12.31 DEH

#    if ($thisyear == 2012) {$ditlogfile = ">>../working/wr/" . $thisweek}
open MYLOG, $ditlogfile;
flock MYLOG, 2;
print MYLOG '.';
close MYLOG;

# ------------------------ subroutines ---------------------------


sub CreateResponseFile {

    open( ResponseFile, ">" . $responseFile );
    print ResponseFile "97.3\n";               # datver
    print ResponseFile "y\n";                  # not watershed
    print ResponseFile "1\n";                  # 1 = continuous
    print ResponseFile "1\n";                  # 1 = hillslope
    print ResponseFile "n\n";                  # hillsplope pass file out?
    print ResponseFile "1\n";                  # 1 = abreviated annual out
    print ResponseFile "n\n";                  # initial conditions file?
    print ResponseFile "$outputFile", "\n";    # soil loss output file
    print ResponseFile "n\n";                  # water balance output?
    print ResponseFile "n\n";                  # crop output?
    print ResponseFile "n\n";                  # soil output?
    print ResponseFile "n\n";                  # distance/sed loss output?
    print ResponseFile "n\n";                  # large graphics output?
    print ResponseFile "n\n";                  # event-by-event out?
    print ResponseFile "n\n";                  # element output?
    print ResponseFile "n\n";                  # final summary out?
    print ResponseFile "n\n";                  # daily winter out?
    print ResponseFile "n\n";                  # plant yield out?
    print ResponseFile $manPath . $manfile, "\n";    # management file name
    print ResponseFile $slopeFile,   "\n";           # slope file name
    print ResponseFile $climateFile, "\n";           # climate file name
    print ResponseFile $newSoilFile, "\n";           # soil file name
    print ResponseFile "0\n";                        # 0 = no irrigation
    print ResponseFile "$years2sim\n";               # no. years to simulate
    print ResponseFile "0\n";                        # 0 = route all events
    close ResponseFile;
    return $responseFile;
}

sub CreateSoilFile {

    # David Hall and Darrell Anderson
    #    2004.01.26
    #    2001.11.26

    # Read a WEPP:Road soil file template and create a usable soil file.
    # File may have 'urr', 'ufr' and 'ubr' as placeholders for rock fragment
    # Adjust road surface Kr downward for traffic levels of 'low' or 'none'
    # Adjust road surface Ki downward for traffic levels of 'low' or 'none'
    #         DEH 2004.01.26

    # uses: $soilFilefq   fully qualified input soil file name
    #       $newSoilFile  name of soil file to be created
    #       $surface      native, graveled, paved
    #       $traffic      High, Low, None
    #       $UBR          user-specified rock fragment decimal percentage for
    # buffer
    # sets: $URR          calculated rock fragment decimal percentage for road
    #       $UFR          calculated rock fragment decimal percentage for fill

    my $in;
    my ( $pos1, $pos2, $pos3, $pos4 );
    my ( $ind, $left, $right );

    open SOILFILE,    "<$soilFilefq";
    open NEWSOILFILE, ">$newSoilFile";

    if    ( $surface eq 'graveled' ) { $URR = 65;   $UFR = ( $UBR + 65 ) / 2 }
    elsif ( $surface eq 'paved' )    { $URR = 95;   $UFR = ( $UBR + 65 ) / 2 }
    else                             { $URR = $UBR; $UFR = $UBR }

    # modify 'Kr' for 'no traffic' and 'low traffic'
    # modify 'Ki' for 'no traffic' and 'low traffic'

    if ( $traffic eq 'low' || $traffic eq 'none' ) {
        $in = <SOILFILE>;
        print NEWSOILFILE $in;    # line 1; version control number - datver
        $in = <SOILFILE>;         # first comment line
        print NEWSOILFILE $in;
        while ( substr( $in, 0, 1 ) eq '#' ) {    # gobble up comment lines
            $in = <SOILFILE>;
            print NEWSOILFILE $in;
        }
        $in = <SOILFILE>;
        print NEWSOILFILE $in;                    # line 3: ntemp, ksflag
        $in   = <SOILFILE>;
        $pos1 = index( $in, "'" );                # location of first apostrophe
        $pos2 = index( $in, "'", $pos1 + 1 );    # location of second apostrophe
        $pos3 = index( $in, "'", $pos2 + 1 );    # location of third apostrophe
        $pos4 = index( $in, "'", $pos3 + 1 );    # location of fourth apostrophe
        my $slid_texid = substr( $in, 0, $pos4 + 1 );    # slid; texid
        my $rest       = substr( $in, $pos4 + 1 );
        my ( $nsl, $salb, $sat, $ki, $kr, $shcrit, $avke ) = split ' ', $rest;
        $kr /= 4;
        $ki /= 4;                                        # DEH 2004.01.26
        print NEWSOILFILE "$slid_texid\t";
        print NEWSOILFILE "$nsl\t$salb\t$sat\t$ki\t$kr\t$shcrit\t$avke\n";
    }
    while (<SOILFILE>) {
        $in = $_;
        if (/urr/) {    # user-specified road rock fragment
            $ind   = index( $in, 'urr' );
            $left  = substr( $in, 0, $ind );
            $right = substr( $in, $ind + 3 );
            $in    = $left . $URR . $right;
        }
        elsif (/ufr/) {    # calculated fill rock fragment
            $ind   = index( $in, 'ufr' );
            $left  = substr( $in, 0, $ind );
            $right = substr( $in, $ind + 3 );
            $in    = $left . $UFR . $right;
        }
        elsif (/ubr/) {    # calculated buffer rock fragment
            $ind   = index( $in, 'ubr' );
            $left  = substr( $in, 0, $ind );
            $right = substr( $in, $ind + 3 );
            $in    = $left . $UBR . $right;
        }
        print NEWSOILFILE $in;
    }
    close SOILFILE;
    close NEWSOILFILE;
    return $newSoilFile;
}

sub checkInput {

    if ( $units eq "m" ) {
        $lu     = "m";
        $minURL = 1;
        $maxURL = 300;
        $minURS = 0.1;
        $maxURS = 40;
        $minURW = 0.3;
        $maxURW = 100;
        $minUFL = 0.3;
        $maxUFL = 100;
        $minUFS = 0.1;
        $maxUFS = 150;
        $minUBL = 0.3;
        $maxUBL = 300;
        $minUBS = 0.1;
        $maxUBS = 100;
    }
    else {
        $lu     = "ft";
        $minURL = 3;
        $maxURL = 1000;
        $minURS = 0.3;
        $maxURS = 40;
        $minURW = 1;
        $maxURW = 300;
        $minUFL = 1;
        $maxUFL = 300;     #   67585 Jun  4 15:36 wr.pl
        $minUFL = 1;
        $maxUFL = 1000;    #
        $minUFS = 0.3;
        $maxUFS = 150;
        $minUBL = 1;
        $maxUBL = 1000;
        $minUBS = 0.3;
        $maxUBS = 100;
    }
    $minyrs = 1;
    $maxyrs = 200;
    $rc     = -0;

    # 12/19/2003 DEH

# [Fri Dec 19 09:37:11 2003] [error] [client 166.4.225.152] malformed header from
# script. Bad header=Road length must be between 3 : /home/httpd/cgi-bin/fswepp/wr
# dev/wr.pl

    $error_message = '';

    if ( $URL < $minURL or $URL > $maxURL ) {
        $rc = -1;
        $error_message .=
          "Road length must be between $minURL and $maxURL $lu ($URL)<BR>\n";
    }
    if ( $URS < $minURS or $URS > $maxURS ) {
        $rc = $rc - 1;
        $error_message .=
          "Road gradient must be between $minURS and $maxURS % ($URS)<BR>\n";
    }
    if ( $URW < $minURW or $URW > $maxURW ) {
        $rc = $rc - 1;
        $error_message .=
          "Road width must be between $minURW and $maxURW $lu ($URW)<BR>\n";
    }
    if ( $UFL < $minUFL or $UFL > $maxUFL ) {
        $rc = $rc - 1;
        $error_message .=
          "Fill length must be between $minUFL and $maxUFL $lu<BR>\n";
    }
    if ( $UFS < $minUFS or $UFS > $maxUFS ) {
        $rc = $rc - 1;
        $error_message .=
          "Fill gradient must be between $minUFS and $maxUFS %<BR>\n";
    }
    if ( $UBL < $minUBL or $UBL > $maxUBL ) {
        $rc = $rc - 1;
        $error_message .=
          "Buffer length must be between $minUBL and $maxUBL $lu<BR>\n";
    }
    if ( $UBS < $minUBS or $UBS > $maxUBS ) {
        $rc = $rc - 1;
        $error_message .=
          "Buffer gradient must be between $minUBS and $maxUBS %<BR>\n";
    }

    #  if ($rc < 0) {print "<p><hr><p>\n"}
    $years2sim = $years * 1;

    #  if ($years2sim < $minyrs) {$years2sim=$minyrs}
    #  if ($years2sim > $maxyrs) {$years2sim=$maxyrs}
    if ( $years2sim < 1 )   { $years2sim = 1 }
    if ( $years2sim > 200 ) { $years2sim = 200 }
    return $rc;
}

sub parseWeppResults {

    open weppstout, "<$stoutFile";

    $found = 0;
    while (<weppstout>) {
        if (/SUCCESSFUL/) {
            $found = 1;
            last;
        }
    }

    close(weppstout);

########################   NAN check   ###################

    open weppoutfile, "<$outputFile";
    while (<weppoutfile>) {
        if (/NaN/) {
            open NANLOG, ">>../working/NANlog.log";
            flock( NANLOG, 2 );
            print NANLOG "$user_ID_\t";
            print NANLOG "WR\t$unique\n";
            close NANLOG;
            last;
        }
    }
    close(weppoutfile);

########################   NAN check   ###################

    if ( $found == 0 ) {   # unsuccessful run -- search STDOUT for error message
        open weppstout, "<$stoutFile";
        while (<weppstout>) {
            if (/ERROR/) {
                $found = 2;
                print "<font color=red>\n";
                $_ = <weppstout>;
                $_ = <weppstout>;
                $_ = <weppstout>;
                print;
                $_ = <weppstout>;
                print;
                print "</font>\n";
                last;
            }
        }
        close(weppstout);
    }

    if ( $found == 0 ) {
        open weppstout, "<$stoutFile";
        while (<weppstout>) {
            if (/error #/) {
                $found = 4;
                print "<font color=red>\n";
                print;
                print "</font>\n";
                last;
            }
        }
        close(weppstout);
    }

    if ( $found == 0 ) {
        open weppstout, "<$stoutFile";
        while (<weppstout>) {
            if (/\*\*\* /) {
                $found = 3;
                print "<font color=red>\n";
                $_ = <weppstout>;
                print;
                $_ = <weppstout>;
                print;
                $_ = <weppstout>;
                print;
                $_ = <weppstout>;
                print;
                print "</font>\n";
                last;
            }
        }
        close(weppstout);
    }    # if ($found == 0)

    if ( $found == 0 ) {
        open weppstout, "<$stoutFile";
        while (<weppstout>) {
            if (/MATHERRQQ/) {
                $found = 5;
                print '     <font color=red>
           WEPP has run into a mathematical anomaly.<br>
           You may be able to get around it by modifying the geometry slightly;
           try changing road length by 1 foot (1/2 meter) or so.
';
                $_ = <weppstout>;
                print;
                print "</font>\n";
                last;
            }
        }
        close(weppstout);
    }    # if ($found == 0)

    if ( $found == 1 ) {    # Successful run -- get actual WEPP version number
        open weppout, "<$outputFile";
        $ver = 'unknown';
        while (<weppout>) {
            if (/VERSION/) {
                $weppver = $_;
                last;
            }
        }
        while (<weppout>) {    # read actual climate file used from WEPP output
            if (/CLIMATE/) {
                $a_c_n = <weppout>;
                $actual_climate_name =
                  substr( $a_c_n, index( $a_c_n, ":" ) + 1, 40 );
                $climate_name = $actual_climate_name;
                last;
            }
        }
        while (<weppout>) {
            if (/RAINFALL AND RUNOFF SUMMARY/) {
                $_ = <weppout>;    #      -------- --- ------ -------
                $_ = <weppout>;    #
                $_ = <weppout>;    #       total summary:  years    1 -    1
                $_ = <weppout>;    #
                $_ = <weppout>
                  ; #         71 storms produced                          346.90 mm of precipitation
                $storms = substr $_, 1, 10;
                $_ = <weppout>
                  ; #          3 rain storm runoff events produced          0.00 mm of runoff
                $rainevents = substr $_, 1, 10;
                $_          = <weppout>;    #          2 snow melts and/or
                $snowevents = substr $_, 1, 10;
                $_          = <weppout>
                  ; #              events during winter produced            0.00 mm of runoff
                $_ = <weppout>;    #
                $_ = <weppout>;    #      annual averages
                $_ = <weppout>;    #      ---------------
                $_ = <weppout>;    #
                $_ = <weppout>
                  ; #        Number of years                                    1
                $_ = <weppout>
                  ; #        Mean annual precipitation                     346.90    mm
                $precip = substr $_, 51, 10;
                $_      = <weppout>;
                $rro    = substr $_, 51, 10;    # print;
                $_      = <weppout>;            # print;
                $_      = <weppout>;
                $sro    = substr $_, 51, 10;    # print;
                $_      = <weppout>;            # print;
                last;
            }
        }
        while (<weppout>) {
            if (/AREA OF NET SOIL LOSS/) {
                $_                     = <weppout>;
                $_                     = <weppout>;
                $_                     = <weppout>;
                $_                     = <weppout>;
                $_                     = <weppout>;
                $_                     = <weppout>;    # print;
                $_                     = <weppout>;    # print;
                $_                     = <weppout>;    # print;
                $_                     = <weppout>;    # print;
                $_                     = <weppout>;    # print;
                $syr                   = substr $_, 17, 7;
                $effective_road_length = substr $_, 9,  9;

                #  area = val(mid$($_,9,7))
                #  sed = val(mid$($_,16,9))
                #  rsv = area * sed
                last;
            }
        }
        while (<weppout>) {
            if (/OFF SITE EFFECTS/) {
                $_   = <weppout>;            #  print; print "<br>\n";
                $_   = <weppout>;            #  print; print "<br>\n";
                $_   = <weppout>;            #  print; print "<br>\n";
                $syp = substr $_, 49, 10;    # pre-WEPP 98.4 [was (50,9)]
                $_   = <weppout>;            #  print; print "<br>\n";
                chomp $syp;
                if ( $syp eq "" ) {
                    @sypline = split ' ', $_;    # print "a: $_<br>\n";
                    $syp     = @sypline[0];
                }
                $_ = <weppout>;
                $_ = <weppout>;
                last;
            }
        }
        close(weppout);

# print "syr: $syr; syp: $syp; effective_road_length: $effective_road_length; WeppRoadWidth $WeppRoadWidth<br>\n";

        $storms     += 0;
        $rainevents += 0;
        $snowevents += 0;
        $precip     += 0;
        $rro        += 0;
        $sro        += 0;
        $syr        += 0;
        $syp        += 0;
        $syra = $syr * $effective_road_length * $WeppRoadWidth;
        $sypa = $syp * $WeppRoadWidth;
        if    ( $surface eq 'graveled' ) { $URR = 65; $UFR = ( $UBR + 65 ) / 2 }
        elsif ( $surface eq 'paved' )    { $URR = 95; $UFR = ( $UBR + 65 ) / 2 }
        else                             { $URR = $UBR; $UFR = $UBR }

## DEH 2003/10/09
        $trafficx = $traffic;
        $trafficx = 'no' if ( $traffic eq 'none' );
##

        print "
   <center>
    <table border=1>
     <tr>
      <th colspan=8 bgcolor=#85D2D2><font face='Arial, Geneva, Helvetica'>INPUTS</font></th>
     </tr>
     <tr>
      <td><font face='Arial, Geneva, Helvetica'><b>Climate</font></td>
      <td colspan=3>
       <font face='Arial, Geneva, Helvetica'>$climate_name<br>
        <font size=1>
";
        print &GetParSummary($climatePar, $units);
        print "
        </font>
       </font>
      </td>
     </tr>
     <tr>
      <td><font face='Arial, Geneva, Helvetica'><b>Soil texture</b></font></td>
      <td colspan=3><font face='Arial, Geneva, Helvetica'>$STx with $UBR% rock fragments<br>
                    <font size=1>(road: $URR%; fill: $UFR%; buffer: $UBR% rock)</font></font></td>
     </tr>
     <tr>
      <td><font face='Arial, Geneva, Helvetica'><b>Road design</b></font></td>
      <td colspan=3><font face='Arial, Geneva, Helvetica'>$design</font></td>
     </tr>
     <tr>
      <td><font face='Arial, Geneva, Helvetica'><b>Surface, traffic</b></font></td>
      <td colspan=3><font face='Arial, Geneva, Helvetica'>$surface surface, $trafficx traffic</font></td>
     </tr>
     <tr>
      <td></td>
      <th><font face='Arial, Geneva, Helvetica'>Gradient<br> (%)</font></th>
      <th><font face='Arial, Geneva, Helvetica'>Length<br> ($units)</font></th>
      <th><font face='Arial, Geneva, Helvetica'>Width<br> ($units)</font></th>
     </tr>
     <tr>
      <th align=left> <font face='Arial, Geneva, Helvetica'>Road</font></th>
      <td align=right><font face='Arial, Geneva, Helvetica'>$URS</font></td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$URL</font></td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$URW</font></td>
     </tr>
     <tr>
      <th align=left> <font face='Arial, Geneva, Helvetica'>Fill</font></th>
      <td align=right><font face='Arial, Geneva, Helvetica'>$UFS</font></td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$UFL</font></td>
      <td align=right></td>
     </tr>
     <tr>
      <th align=left> <font face='Arial, Geneva, Helvetica'>Buffer</font></th>
      <td align=right><font face='Arial, Geneva, Helvetica'>$UBS</font></td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$UBL</font></td>
      <td align=right></td>
     </tr>
    </table>
    <br><br>
";

        #     if ($trafficx eq 'no' or $trafficx eq 'low') { 		# DEH 2015.03.02
        #       print "     <font color=\"red\">
        #      Provisional values for $trafficx traffic
        #     </font>
        #    <br><br>
        #";
        #     }		# if ($trafficx eq 'no' or $trafficx eq 'low')
        if ( $units eq "m" ) {
            $precipunits = "mm";
            $sedunits    = "kg";
            $pcpfmt      = '%.0f';
        }
        else {    # convert WEPP metric results to in and lb
            $precipunits = "in";
            $precip      = $precip / 25.4;
            $rro         = $rro / 25.4;
            $sro         = $sro / 25.4;
            $sedunits    = "lb";
            $syra        = $syra * 2.2046;
            $sypa        = $sypa * 2.2046;
            $pcpfmt      = '%.2f';
        }         # if ($units eq "m")

        #    $precipf = sprintf "%.0f", $precip;
        #    $rrof = sprintf "%.0f", $rro;
        #    $srof = sprintf "%.0f", $sro;
        $precipf = sprintf $pcpfmt, $precip;
        $rrof    = sprintf $pcpfmt, $rro;
        $srof    = sprintf $pcpfmt, $sro;
        $syraf   = sprintf "%.2f", $syra;
        $sypaf   = sprintf "%.2f", $sypa;

        print "
    <table cellspacing=8 bgcolor='#ccffff'>
     <tr>
      <th colspan=5 bgcolor=#85D2D2><font face='Arial, Geneva, Helvetica'>$years2sim - YEAR MEAN ANNUAL AVERAGES</font></th>
     </tr>
     <tr>
       <td colspan=3></td>
       <th colspan=2><font size=-1 face='Arial, Geneva, Helvetica'>Total in<br>$years2sim years</font></th>
     </tr>
     <tr>
      <td align=right><font face='Arial, Geneva, Helvetica'>$precipf</font></td>
      <td><font face='Arial, Geneva, Helvetica'>$precipunits
      <td><font face='Arial, Geneva, Helvetica'>precipitation from</font></td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$storms</font></td>
      <td><font face='Arial, Geneva, Helvetica'>storms</font></td>
     </tr>
     <tr>
      <td align=right><font face='Arial, Geneva, Helvetica'>$rrof</font></td>
      <td><font face='Arial, Geneva, Helvetica'>$precipunits</font></td>
      <td><font face='Arial, Geneva, Helvetica'>runoff from rainfall from</font></td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$rainevents</font></td>
      <td><font face='Arial, Geneva, Helvetica'>events</font></td>
     </tr>
     <tr>
      <td align=right><font face='Arial, Geneva, Helvetica'>$srof</font></td>
      <td><font face='Arial, Geneva, Helvetica'>$precipunits</font></td>
      <td><font face='Arial, Geneva, Helvetica'>runoff from snowmelt or winter rainstorm from </font></td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$snowevents</font></td>
      <td><font face='Arial, Geneva, Helvetica'> events</font></td>
     </tr>
     <tr>
      <td align=right><font face='Arial, Geneva, Helvetica'>$syraf</font></td>
      <td><font face='Arial, Geneva, Helvetica'>$sedunits</font></td>
      <td><font face='Arial, Geneva, Helvetica'>road prism erosion</font></td>
     </tr>
     <tr>
      <td align=right><font face='Arial, Geneva, Helvetica'>$sypaf</font></td>
      <td><font face='Arial, Geneva, Helvetica'>$sedunits</font></td>
      <td><font face='Arial, Geneva, Helvetica'>sediment leaving buffer</font></td>
     </tr>
<!-- <tr><td>$syr<td>$effective_road_length<td>$WeppRoadWidth<td> syra=syr x rdlen x rdwidth
     <tr><td>$syp<td>sypa=syp x rdwidth
-->
    </table>
    <hr width=50%>
";
        print '
     <font face="Arial, Geneva, Helvetica">
      <form name="wrlog" method="post" action="/cgi-bin/fswepp/wr/logstuffwr.pl">
       <input type="hidden" name="units" value="',       $units,        '">
       <input type="hidden" name="years" value="',       $years2sim,    '">
       <input type="hidden" name="climate" value="',     $climate_name, '">
       <input type="hidden" name="soil" value="',        $STx,          '">
       <input type="hidden" name="design" value="',      $slopex,       '">
       <input type="hidden" name="rock" value="',        $UBR,          '">
       <input type="hidden" name="surface" value="',     $surface,      '">
       <input type="hidden" name="traffic" value="',     $traffic,      '">
       <input type="hidden" name="road_grad" value="',   $URS,          '">
       <input type="hidden" name="road_length" value="', $URL,          '">
       <input type="hidden" name="road_width" value="',  $URW,          '">
       <input type="hidden" name="fill_grad" value="',   $UFS,          '">
       <input type="hidden" name="fill_length" value="', $UFL,          '">
       <input type="hidden" name="buff_grad" value="',   $UBS,          '">
       <input type="hidden" name="buff_length" value="', $UBL,          '">
       <input type="hidden" name="precip" value="',      $precipf,      '">
       <input type="hidden" name="rro" value="',         $rrof,         '">
       <input type="hidden" name="sro" value="',         $srof,         '">
       <input type="hidden" name="syr" value="',         $syraf,        '">
       <input type="hidden" name="syp" value="',         $sypaf,        '">
       Run description: <input type=text name="rundescription">
       <input type="submit" name="button" value="Add to log">
      </form>
      <br><br>
      <input type="button" value="Return to Input Screen" onClick="JavaScript:window.history.go(-1)">
      <br>
     </center>
';
    }    # if ($found == 1)
    else {
        print "    <br><br>
    I'm sorry; WEPP did not run successfully.
    WEPP's error message follows:
    <br><br>
    <hr>
    <br><br>
";
    }    # if ($found == 1)
    return $found;
}

# ---------------------  WEPP summary output  --------------------

sub printWeppSummary {

    print '      <center><h2>WEPP output</h2></center>
      <font face=courier>
       <pre>
';
    open weppout, "<$outputFile";
    while (<weppout>) {
        print;
    }
    close weppout;
    print '       </pre>
      </font>
      <br><br>
      <center>
       <hr>
       <a href="JavaScript:window.history.go(-1)">
        <img src="/fswepp/images/rtis.gif"
             alt="Return to input screen" border="0" align=center></a>
       <br>
      <hr>
     </center>
';
}
