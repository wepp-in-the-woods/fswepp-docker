#!/usr/bin/perl

use warnings;
use CGI;
use CGI qw(escapeHTML header);

use MoscowFSL::FSWEPP::CligenUtils
  qw(CreateCligenFile GetParSummary GetParLatLong);
use MoscowFSL::FSWEPP::FsWeppUtils
  qw(get_version printdate get_thisyear_and_thisweek get_user_id get_units);
use MoscowFSL::FSWEPP::WeppRoad
  qw(CreateSlopeFileWeppRoad CreateSoilFileWeppRoad CheckInputWeppRoad GetSoilFileTemplate);

use String::Util qw(trim);

my $debug   = 0;

my $version = get_version(__FILE__);
my $user_ID = get_user_id();
my ( $thisyear, $thisweek ) = get_thisyear_and_thisweek();
my ($units, $areaunits) = get_units();

my $weppversion = "wepp2010";

my $cgi = CGI->new;
$action =
    escapeHTML( $cgi->param('ActionC') )
  . escapeHTML( $cgi->param('ActionW') );
chomp $action;

# todo make variable names consistent
$traffic      = escapeHTML( $cgi->param('traffic') );
$achtung      = escapeHTML( $cgi->param('achtung') );
$CL           = escapeHTML( $cgi->param('Climate') );
$climate_name = escapeHTML( $cgi->param('climate_name') );

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

# TODO: this results in triple book keeping would be better to have slope_descriptions hash and 
$design = $slope;

$runLogFile = "../working/" . $user_ID . ".run.log";


# TODO: remove double book keeping
if    ( $slope eq "outunrut" ) { $design = "Outsloped, unrutted" }
elsif ( $slope eq "inbare" )   { $design = "Insloped, bare ditch" }
elsif ( $slope eq "inveg" )  { $design = "Insloped, vegetated or rocked ditch" }
elsif ( $slope eq "outrut" ) { $design = "Outsloped, rutted" }

# TODO: remove double book keeping
# slopex is only used for logging.
if    ( $slope eq 'inveg' )    { $slopex = 'insloped vegetated' }
elsif ( $slope eq "outunrut" ) { $slopex = 'outsloped unrutted' }
elsif ( $slope eq "outrut" )   { $slopex = 'outsloped rutted' }
elsif ( $slope eq "inbare" )   { $slopex = 'insloped bare' }

# TODO: remove double book keeping
if    ( $ST eq 'clay' ) { $STx = 'clay loam' }
elsif ( $ST eq 'silt' ) { $STx = 'silt loam' }
elsif ( $ST eq 'sand' ) { $STx = 'sandy loam' }
elsif ( $ST eq 'loam' ) { $STx = 'loam' }

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

my ( $rcin, $error_message ) = &CheckInputWeppRoad( $URL, $URS, $URW, $UFL, $UFS, $UBL, $UBS, $years, $units );

if ( $rcin < 0 ) {
    die $error_message;
}

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
$zzsoil =
  &CreateSoilFileWeppRoad( $soilFilefq, $newSoilFile, $surface, $traffic, $UBR,
    \$URR, \$UFR );
( $zzslope, $WeppRoadSlope, $WeppRoadWidth, $WeppRoadLength ) =
  &CreateSlopeFileWeppRoad(
    $URS, $UFS,   $UBS,   $URW,       $URL, $UFL,
    $UBL, $units, $slope, $slopeFile, $debug
  );

( $climateFile, $climatePar ) =
  &CreateCligenFile( $CL, $unique, $years, $debug );
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
print '      filewindow.document.writeln("    <\/pre>\n  <\/body>\n<\/html>")
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
print RUNLOG "$years\t";
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

my ( $lat, $long ) = GetParLatLong($climatePar);

# 2008.06.04 DEH end
open WRLOG, ">>../working/_$thisyear/wr.log";    # 2012.12.31 DEH
flock( WRLOG, 2 );
print WRLOG "$user_ID\t\"";
printf WRLOG "%0.2d:%0.2d ", $hour, $min;
print WRLOG $ampm[$ampmi], "  ", $days[$wday], " ", $months[$mon], " ",
  $mday, ", ", $year + 1900, "\"\t";
print WRLOG $years, "\t";
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
    print ResponseFile "$years\n";               # no. years to simulate
    print ResponseFile "0\n";                        # 0 = route all events
    close ResponseFile;
    return $responseFile;
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

                last;
            }
        }
        while (<weppout>) {
            if (/OFF SITE EFFECTS/) {
                $_   = <weppout>;                      #  print; print "<br>\n";
                $_   = <weppout>;                      #  print; print "<br>\n";
                $_   = <weppout>;                      #  print; print "<br>\n";
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

# print "syr: $syr; syp: $syp; effective_road_length: $effective_road_length; WeppRoadWidth $WeppRoadWidth; URW: $URW<br>\n";

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

        $trafficx = $traffic;
        $trafficx = 'no' if ( $traffic eq 'none' );

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
        print &GetParSummary( $climatePar, $units );
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

        $precipf = sprintf $pcpfmt, $precip;
        $rrof    = sprintf $pcpfmt, $rro;
        $srof    = sprintf $pcpfmt, $sro;
        $syraf   = sprintf "%.2f", $syra;
        $sypaf   = sprintf "%.2f", $sypa;

        print "
    <table cellspacing=8 bgcolor='#ccffff'>
     <tr>
      <th colspan=5 bgcolor=#85D2D2><font face='Arial, Geneva, Helvetica'>$years - YEAR MEAN ANNUAL AVERAGES</font></th>
     </tr>
     <tr>
       <td colspan=3></td>
       <th colspan=2><font size=-1 face='Arial, Geneva, Helvetica'>Total in<br>$years years</font></th>
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

# TODO: why do we need this add to log function. does anyone use it?
        print '
     <font face="Arial, Geneva, Helvetica">
      <form name="wrlog" method="post" action="/cgi-bin/fswepp/wr/logstuffwr.pl">
       <input type="hidden" name="me" value="',          $me,           '">
       <input type="hidden" name="units" value="',       $units,        '">
       <input type="hidden" name="years" value="',       $years,    '">
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
