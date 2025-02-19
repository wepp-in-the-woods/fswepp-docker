#!/usr/bin/perl
use CGI;
use CGI qw(escapeHTML);

use warnings;

use MoscowFSL::FSWEPP::CligenUtils
  qw(CreateCligenFile GetParSummary GetAnnualPrecip GetParLatLong);
use MoscowFSL::FSWEPP::FsWeppUtils
  qw(CreateSlopeFile printdate get_version get_thisyear_and_thisweek CreateSoilFile get_user_id);

use String::Util qw(trim);

#
# wd.pl
#
# Disturbed WEPP 2.0 workhorse
# Reads user input from weppdist.pl, runs WEPP, parses output files

my $debug = 0;

print "Content-type: text/html\n\n";

my $version      = get_version(__FILE__);
my $user_ID      = get_user_id();
my ( $thisyear, $thisweek ) = get_thisyear_and_thisweek();

#=========================================================================

my $cgi            = CGI->new;
my $CL             = escapeHTML( $cgi->param('Climate') );
my $soil           = escapeHTML( $cgi->param('SoilType') );
my $treat1         = escapeHTML( $cgi->param('UpSlopeType') );
my $ofe1_length    = escapeHTML( $cgi->param('ofe1_length') ) + 0;
my $ofe1_top_slope = escapeHTML( $cgi->param('ofe1_top_slope') ) + 0;
my $ofe1_mid_slope = escapeHTML( $cgi->param('ofe1_mid_slope') ) + 0;
my $ofe1_pcover    = escapeHTML( $cgi->param('ofe1_pcover') ) + 0;
my $ofe1_rock      = escapeHTML( $cgi->param('ofe1_rock') ) + 0;
my $treat2         = escapeHTML( $cgi->param('LowSlopeType') );
my $ofe2_length    = escapeHTML( $cgi->param('ofe2_length') ) + 0;
my $ofe2_mid_slope = escapeHTML( $cgi->param('ofe2_top_slope') ) + 0;
my $ofe2_bot_slope = escapeHTML( $cgi->param('ofe2_bot_slope') ) + 0;
my $ofe2_pcover    = escapeHTML( $cgi->param('ofe2_pcover') ) + 0;
my $ofe2_rock      = escapeHTML( $cgi->param('ofe2_rock') ) + 0;
my $ofe_area       = escapeHTML( $cgi->param('ofe_area') ) + 0;
my $action =
    escapeHTML( $cgi->param('actionc') )
  . escapeHTML( $cgi->param('actionv') )
  . escapeHTML( $cgi->param('actionw') )
  . escapeHTML( $cgi->param('ActionCD') );
my $units       = escapeHTML( $cgi->param('units') );
my $achtung     = escapeHTML( $cgi->param('achtung') );
my $climyears   = escapeHTML( $cgi->param('climyears') );

my $weppversion = "wepp2010";
my $description = escapeHTML( $cgi->param('description') );

my $soil_db_file = '/var/www/cgi-bin/fswepp/wd/data/soilbase2014.yaml';

if ( $treat1 eq 'tree20' ) { $treat1 = 'OldForest' }
if ( $treat1 eq 'tree5' )  { $treat1 = 'YoungForest' }
if ( $treat1 eq 'shrub' )  { $treat1 = 'Shrub' }
if ( $treat1 eq 'tall' )   { $treat1 = 'Bunchgrass' }
if ( $treat1 eq 'short' )  { $treat1 = 'Sod' }
if ( $treat1 eq 'low' )    { $treat1 = 'LowFire' }
if ( $treat1 eq 'high' )   { $treat1 = 'HighFire' }
if ( $treat1 eq 'skid' )   { $treat1 = 'Skid' }

if ( $treat2 eq 'tree20' ) { $treat2 = 'OldForest' }
if ( $treat2 eq 'tree5' )  { $treat2 = 'YoungForest' }
if ( $treat2 eq 'shrub' )  { $treat2 = 'Shrub' }
if ( $treat2 eq 'tall' )   { $treat2 = 'Bunchgrass' }
if ( $treat2 eq 'short' )  { $treat2 = 'Sod' }
if ( $treat2 eq 'low' )    { $treat2 = 'LowFire' }
if ( $treat2 eq 'high' )   { $treat2 = 'HighFire' }
if ( $treat2 eq 'skid' )   { $treat2 = 'Skid' }

if ($debug) { print "treatment 1: $treat1<br>\n" }


if ( lc($achtung) =~ /describe soil/ ) {    ##########
    $units    = escapeHTML( $cgi->param('units') );
    $SoilType = escapeHTML( $cgi->param('SoilType') );
    $soilPath = 'data/';

    $surf = "";
    if ( substr( $surface, 0, 1 ) eq "g" ) { $surf = "g" }
    $soilFile = '3' . $surf . $SoilType . $conduct . '.sol';

    $weppdist   = "/cgi-bin/fswepp/wd/weppdist.pl";
    $soilFilefq = $soilPath . $soilFile;
    print "<HTML>\n";
    print " <HEAD>\n";
    print "  <TITLE>Disturbed WEPP -- Soil Parameters</TITLE>\n";
    print " </HEAD>\n";
    print ' <BODY link="#ff0000">
  <font face="Arial, Geneva, Helvetica">
  <blockquote>
  <table width=95% border=0>
    <tr><td> 
       <a href="/cgi-bin/fswepp/wd/weppdist.pl">
       <IMG src="/fswepp/images/disturb.gif"
       align="left" alt="Back to FS WEPP menu" border=1></a>
    <td align=center>
       <hr>
       <h2>Disturbed WEPP Soil Texture Properties</h2>
       <hr>
    <td>
       <A HREF="/fswepp/docs/distweppdoc.html">
       <IMG src="/fswepp/images/epage.gif"
        align="right" alt="Read the documentation" border=0></a>
    </table>
';
    if ($debug) { print "Action: '$action'<br>\nAchtung: '$achtung'<br>\n" }

    if ( $SoilType eq 'clay' ) {
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

    $working  = '../working';
    $unique   = 'wepp-' . $$;                  # DEH 01/13/2004
    $soilFile = "$working/$unique" . '.sol';
    $soilPath = 'data/';                       # DEH 20110408

    CreateSoilFile(
        "97.3",    $soil,         $treat1,
        $treat2,   $ofe1_rock,    $ofe2_rock,
        $soilFile, $soil_db_file, $debug
    );
    
    open SOIL, "<$soilFile";
    $weppver = <SOIL>;
    $comment = <SOIL>;
    while ( substr( $comment, 0, 1 ) eq "#" ) {
        chomp $comment;
        $comment = <SOIL>;
    }

    print "<hr>
  <center>
   <table border=1 cellpadding=3>
";

    $record = <SOIL>;
    @vals   = split " ", $record;
    $ntemp  = @vals[0];    # no. flow elements or channels
    $ksflag = @vals[1];    # 0: hold hydraulic conductivity constant
                           # 1: use internal adjustments to hydr con
    for $i ( 1 .. $ntemp ) {
        print "
   <tr>
    <th colspan=5 bgcolor=\"85d2d2\"><font face=\"Arial, Geneva, Helvetica\">
     Element $i ---
";
        $record      = <SOIL>;
        @descriptors = split "'", $record;
        $my_soilID   = lc( @descriptors[1] );
        $my_texture  = lc( @descriptors[3] );
        print "$my_soilID;&nbsp;&nbsp;   ";    # slid: Road, Fill, Forest
        print "texture:$my_texture\n";         # texid: soil texture
        ( $nsl, $salb, $sat, $ki, $kr, $shcrit, $avke ) = split " ",
          @descriptors[4];
        $avke_e = sprintf "%.2f", $avke / 25.4;

        print "
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\">Albedo of the bare dry surface soil
     <td><font face=\"Arial, Geneva, Helvetica\">$salb
     <td>&nbsp;
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\">Initial saturation level of the soil profile porosity
     <td><font face=\"Arial, Geneva, Helvetica\">$sat
     <td><font face=\"Arial, Geneva, Helvetica\">m m<sup>-1</sup>
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\">Baseline interrill erodibility parameter (<i>k<sub>i</sub></i> )
     <td><font face=\"Arial, Geneva, Helvetica\">$ki
     <td><font face=\"Arial, Geneva, Helvetica\">kg s m<sup>-4</sup>
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\">Baseline rill erodibility parameter (<i>k<sub>r</sub></i> )
     <td><font face=\"Arial, Geneva, Helvetica\">$kr
     <td><font face=\"Arial, Geneva, Helvetica\">s m<sup>-1</sup>
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\">Baseline critical shear parameter
     <td><font face=\"Arial, Geneva, Helvetica\">$shcrit
     <td><font face=\"Arial, Geneva, Helvetica\">N m<sup>-2</sup>
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\">Effective hydraulic conductivity of surface soil
     <td><font face=\"Arial, Geneva, Helvetica\">$avke
     <td><font face=\"Arial, Geneva, Helvetica\">mm h<sup>-1</sup>
     <td><font face=\"Arial, Geneva, Helvetica\">$avke_e
     <td><font face=\"Arial, Geneva, Helvetica\">in hr<sup>-1</sup>
";
        for $layer ( 1 .. $nsl ) {
            $record = <SOIL>;
            ( $solthk, $sand, $clay, $orgmat, $cec, $rfg ) = split " ", $record;
            $solthk_e = sprintf "%.2f", $solthk / 25.4;
            print "
    <tr>
     <td>&nbsp;
     <th colspan=4 bgcolor=\"85d2d2\"><font face=\"Arial, Geneva, Helvetica\">layer $layer
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\">Depth from soil surface to bottom of soil layer
     <td><font face=\"Arial, Geneva, Helvetica\">$solthk
     <td><font face=\"Arial, Geneva, Helvetica\">mm
     <td><font face=\"Arial, Geneva, Helvetica\">$solthk_e
     <td><font face=\"Arial, Geneva, Helvetica\">in
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\">Percentage of sand
     <td><font face=\"Arial, Geneva, Helvetica\">$sand
     <td><font face=\"Arial, Geneva, Helvetica\">%
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\">Percentage of clay
     <td><font face=\"Arial, Geneva, Helvetica\">$clay
     <td><font face=\"Arial, Geneva, Helvetica\">%
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\">Percentage of organic matter (by volume)
     <td><font face=\"Arial, Geneva, Helvetica\">$orgmat
     <td><font face=\"Arial, Geneva, Helvetica\">%
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\">Cation exchange capacity
     <td><font face=\"Arial, Geneva, Helvetica\">$cec
     <td><font face=\"Arial, Geneva, Helvetica\">meq per 100 g of soil
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\">Percentage of rock fragments (by volume)
     <td><font face=\"Arial, Geneva, Helvetica\">$rfg
     <td><font face=\"Arial, Geneva, Helvetica\">%
";
        }
    }
    close SOIL;
    print '   </table>
  <p>
  <hr>
  <p>

';

    open SOIL, "<$soilFile";
    print '
   </center>
   <p>
   <pre>
';
    print <SOIL>;
    print '
   </pre>
  </blockquote>
 </body>
</html>
';

    unlink $soilFile;    # DEH 01/13/2004
    die;
}    #  /describe soil/

# ################################
# ########### RUN WEPP ###########
# ################################

############################ start 2009.11.02 DEH

$runLogFile = "../working/" . $user_ID . ".run.log";

############################ end 2009.11.02 DEH

$years2sim = $climyears;
if ( $years2sim > 100 ) { $years2sim = 100 }

$unique = 'wepp-' . $$;

$working      = '../working';
$unique       = 'wepp' . '-' . $$;
$responseFile = "$working/$unique" . '.in';
$outputFile   = "$working/$unique" . '.out';
$soilFile     = "$working/$unique" . '.sol';
$slopeFile    = "$working/$unique" . '.slp';
$cropFile     = "$working/$unique" . '.crp';
$stoutFile    = "$working/$unique" . ".stout";
$sterFile     = "$working/$unique" . ".sterr";
$manFile      = "$working/$unique" . ".man";
$soilPath     = 'data/';
$manPath      = 'datatahoebasin/';

# make hash of treatments

$treatments         = {};
$treatments{skid}   = 'skid trail';
$treatments{high}   = 'high severity fire';
$treatments{low}    = 'low severity fire';
$treatments{short}  = 'short prairie grass';
$treatments{tall}   = 'tall prairie grass';
$treatments{shrub}  = 'shrubs';
$treatments{tree5}  = '5 year old trees';
$treatments{tree20} = '20 year old trees';

$treatments{Skid}        = 'skid trail';
$treatments{HighFire}    = 'high severity fire';
$treatments{LowFire}     = 'low severity fire';
$treatments{Bunchgrass}  = 'good grass';
$treatments{Sod}         = 'poor grass';
$treatments{Shrub}       = 'shrubs';
$treatments{Bare}        = 'bare';
$treatments{Mulch}       = 'mulch only';
$treatments{Till}        = 'mulch and till';
$treatments{LowRoad}     = 'low traffic road';
$treatments{HighRoad}    = 'high traffic road';
$treatments{YoungForest} = 'thin or young forest';
$treatments{OldForest}   = 'mature forest';

# make hash of soil types

$soil_type       = {};
$soil_type{sand} = 'sandy loam';
$soil_type{silt} = 'silt loam';
$soil_type{clay} = 'clay loam';
$soil_type{loam} = 'loam';

# ----------------------------

$host = $ENV{REMOTE_HOST};

$user_ofe1_length = $ofe1_length;
$user_ofe2_length = $ofe2_length;

$rcin = &checkInput;
if ( $rcin eq '' ) {

    if ( $units eq 'm' ) {
        $user_ofe_area = $ofe_area;
    }
    if ( $units eq 'ft' ) {
        $user_ofe_area = $ofe_area;
        $ofe1_length   = $ofe1_length / 3.28;    # 3.28 ft == 1 m
        $ofe2_length   = $ofe2_length / 3.28;    # 3.28 ft == 1 m
        $ofe_area =
          $ofe_area / 2.47;   # 2.47 ac == 1 ha; Schwab Fangmeier Elliot Frevert
    }

    $ofe_width = $ofe_area * 10000 / ( $ofe1_length + $ofe2_length );

    &CreateSlopeFile(
        $ofe1_top_slope, $ofe1_mid_slope, $ofe2_mid_slope, $ofe2_bot_slope,
        $ofe1_length,    $ofe2_length,    $ofe_area,       $slopeFile,
        $ofe_width,      $debug
    );

    if ($debug) { print "Creating Management File<br>\n" }
    &CreateManagementFileT;

    if ($debug) { print "Creating Climate File<br>\n" }
    ( $climateFile, $climatePar ) =
      &CreateCligenFile( $CL, $unique, $years2sim, $debug );

    CreateSoilFile(
        "97.3",    $soil,         $treat1,
        $treat2,   $ofe1_rock,    $ofe2_rock,
        $soilFile, $soil_db_file, $debug
    );

    if ($debug) { print "Creating WEPP Response File<br>\n" }
    &CreateResponseFile;

    @args = ("../$weppversion <$responseFile >$stoutFile 2>$sterFile");

    if ($debug) {
        print(@args);
    }
    system @args;

########################  start HTML output ###############

    print '<HTML>
 <HEAD>
  <TITLE>Disturbed WEPP Results</TITLE>
<!-- new 2004 -->
  <script>

    function showslopefile() {
     var properties="menubar,scrollbars,resizable"
     filewindow = window.open("","slope",properties)
     filewindow.document.open()
     if (filewindow && filewindow.open && !filewindow.closed) {
      filewindow.focus
      filewindow.document.writeln("<html>")
      filewindow.document.writeln(" <head>")
      filewindow.document.writeln("  <title>WEPP slope file ', $unique,
      '<\/title>")
      filewindow.document.writeln(" <\/head>")
      filewindow.document.writeln(" <body>")
      filewindow.document.writeln("  <font face=\'courier\'>")
      filewindow.document.writeln("   <pre>")
';
    open WEPPFILE, "<$slopeFile";
    while (<WEPPFILE>) {
        chomp;
        print '      filewindow.document.writeln("', $_, '")', "\n";
    }
    close WEPPFILE;
    print '      filewindow.document.writeln("   <\/pre>")
      filewindow.document.writeln("  <\/font>")
      filewindow.document.writeln(" <\/body>")
      filewindow.document.writeln("<\/html>")
      filewindow.document.close()
     }
     return false
    }

    function showsoilfile() {
     var properties="menubar,scrollbars,resizable"
     filewindow = window.open("","soil",properties)
     filewindow.document.open()
     if (filewindow && filewindow.open && !filewindow.closed) {
      filewindow.focus
      filewindow.document.writeln("<head><title>WEPP soil file ', $unique,
      '<\/title><\/head>")
      filewindow.document.writeln("<body><font face=\'courier\'><pre>")
';
    open WEPPFILE, "<$soilFile";
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
     filewindow = window.open("","resp",properties)
     filewindow.document.open()
     if (filewindow && filewindow.open && !filewindow.closed) {
      filewindow.focus
      filewindow.document.writeln("<head><title>WEPP response file ', $unique,
      '<\/title><\/head>")
      filewindow.document.writeln("<body><pre>")
';
    open WEPPFILE, "<$responseFile";
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
     filewindow = window.open("","veg",properties)
     filewindow.document.open()
     if (filewindow && filewindow.open && !filewindow.closed) {
      filewindow.focus
      filewindow.document.writeln("<head><title>WEPP vegetation file ', $unique,
      '<\/title><\/head>")
      filewindow.document.writeln("<body><pre>")
';
    $line = 0;
    open WEPPFILE, "<$manFile";
    while (<WEPPFILE>) {
        chomp;
        print '      filewindow.document.writeln("', $_, '")', "\n";
        $line += 1;
    }
    close WEPPFILE;
    print '      filewindow.document.writeln("<\/pre><\/body><\/html>")
      filewindow.document.close()
     }
     return false
    }

    function showextendedoutput() {
     var properties="menubar,scrollbars,resizable"
     filewindow = window.open("","extendedout",properties)
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
    binmode WEPPFILE;
    while (<WEPPFILE>) {

     #     's/\r\n/\n/';	# dos2unix:   https://www.perlmonks.org/?node_id=557248
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
     filewindow = window.open("","clipar",properties)
     filewindow.document.open()
     if (filewindow && filewindow.open && !filewindow.closed) {
      filewindow.focus
      filewindow.document.writeln("<head><title>WEPP weather file ', $unique,
      '<\/title><\/head>")
      filewindow.document.writeln("<body><pre>")
';

#     print '      filewindow.document.writeln("climate file: ', $climateFile, '")$
    open WEPPFILE, "<$climateFile";
    while (<WEPPFILE>) {
        chomp;
        chop;
        print '      filewindow.document.writeln("', $_, '")', "\n";
    }
    close WEPPFILE;
    print '      filewindow.document.writeln("<\/pre><\/body><\/html>")
      filewindow.document.close()
     }
     return false
    }
  <!-- end new 2004 -->
';

    print '
  </script>
 </HEAD>
 <BODY>
  <font face="Arial, Geneva, Helvetica">
  <blockquote>
   <table width=100% border=0>
    <tr>
     <td>
      <a href="/cgi-bin/fswepp/wd/weppdist.pl">
      <IMG src="/fswepp/images/disturb.gif"
      align="left" alt="Return to Disturbed WEPP input screen" border=1></a>
     <td align=center>
      <hr>
      <h2>Disturbed WEPP Results</h2>
      <hr>
     </td>
     <td>
      <a href="/fswepp/docs/distweppdoc.html">
      <IMG src="/fswepp/images/epage.gif"
       align="right" alt="Read the documentation" border=0 /></a>
     </td>
    </tr>
   </table>
';

######################## end of top part of HTML output ###############

    #------------------------------

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
        $NaN = 0;
        if (/NaN/) {
            open NANLOG, ">>../working/NANlog.log";
            flock( NANLOG, 2 );
            print NANLOG "$user_ID_\t";
            print NANLOG "WD\t$unique $_";
            close NANLOG;

            $found = 4;
            print "<font color=red>\n";
            print
              "  WEPP has run into a mathematical calculation anomaly.<br>\n";
            print
"  This generally can be addressed by changing the lower element length a fraction of a foot or meter.\n";
            print "</font>\n";
            last;
        }
    }
    close(weppoutfile);

########################   NAN check   ###################

    if ( $found == 0 ) {

        open weppstout, "<$stoutFile";
        while (<weppstout>) {
            if (/ERROR/) {
                $found = 2;
                print "<font color=red>\n";
                $_ = <weppstout>;    # print;
                $_ = <weppstout>;    # print;
                $_ = <weppstout>;
                print;
                $_ = <weppstout>;
                print;
                print "</font>\n";
                last;
            }
        }
        close(weppstout);
        open weppstout, "<$stoutFile";
        while (<weppstout>) {
            if (/error #/) {
                $found = 4;
                print "<font color=red>\n";
                print;
                last;
                print "</font>\n";
            }
        }
        close(weppstout);
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
    }    # $found == 0

    if ( $found == 1 ) {
        open weppout, "<$outputFile";
        $_ = <weppout>;
        if (/Annual; detailed/) { $outputfiletype = "annualdetailed" }
        $ver = 'unknown';
        while (<weppout>) {
            if (/VERSION/) {
                $weppver = lc($_);
                chomp $weppver;
                last;
            }
        }

        # ############# actual climate station name #####################

        while (<weppout>) {    ######## actual ########
            if (/CLIMATE/) {

                #          print;
                $a_c_n = <weppout>;
                $actual_climate_name =
                  substr( $a_c_n, index( $a_c_n, ":" ) + 1, 40 );
                $climate_name = $actual_climate_name;
                last;
            }
        }

#################################################################

        #      if ($outputfiletype eq "annualdetailed") {
        while (<weppout>) {
            if (/ANNUAL AVERAGE SUMMARIES/) { print ""; last }
        }

        #      }

        while (<weppout>) {
            if (/RAINFALL AND RUNOFF SUMMARY/) {
                $_        = <weppout>; #      -------- --- ------ -------
                $_        = <weppout>; #
                $_        = <weppout>; #       total summary:  years    1 -    1
                $simyears = substr $_, 35, 10;
                chomp $simyears;
                $simyears += 0;
                $_ = <weppout>;        #
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
                $precip = substr $_, 51, 10;    #print "precip: ";
                $_      = <weppout>;
                $rro    = substr $_, 51, 10;    #print;
                $_      = <weppout>;            # print;
                $_      = <weppout>;
                $sro    = substr $_, 51, 10;    #print;
                $_      = <weppout>;            # print;
                last;
            }
        }

        while (<weppout>) {
            if (/AREA OF NET SOIL LOSS/) {
                $_        = <weppout>;
                $_        = <weppout>;
                $_        = <weppout>;
                $_        = <weppout>;
                $_        = <weppout>;
                $_        = <weppout>;           # print;
                $_        = <weppout>;           # print;
                $_        = <weppout>;           # print;
                $_        = <weppout>;           # print;
                $_        = <weppout>;
                $syr      = substr $_, 17, 7;
                $effrdlen = substr $_, 9,  9;    # print;
                last;
            }
        }

        while (<weppout>) {
            if (/OFF SITE EFFECTS/) {
                $_   = <weppout>;
                $_   = <weppout>;
                $_   = <weppout>;
                $syp = substr $_, 50, 9;
                $_   = <weppout>;
                if ( $syp eq "" ) { $syp = substr $_, 10, 9 }
                $_ = <weppout>;
                $_ = <weppout>;
                last;
            }
        }
        close(weppout);

        #-----------------------------------

        $storms     = $storms * 1;
        $rainevents = $rainevents * 1;
        $snowevents = $snowevents * 1;
        $precip     = $precip * 1;
        $rro        = $rro * 1;
        $sro        = $sro * 1;
        $syr        = $syr * 1;
        $syp        = $syp * 1;
        $effrdlen   = $effrdlen * 1;
        $syra       = $syr;              # * $effrdlen * $effrdwidth;
        $sypa       = $syp;              # * $effrdwidth;

        if ( $units eq 'm' ) {
            $user_ofe_width = $ofe_width;
        }
        if ( $units eq 'ft' ) {
            $user_ofe_width = $ofe_width * 3.28    # 1 m = 3.28 ft
        }
        $rofe_width   = sprintf "%.2f", $user_ofe_width;
        $slope_length = $ofe1_length + $ofe2_length;
        $asyra        = $syra * 10;                    # kg.m^2 * 10 = t/ha
        $asypa        = sprintf "%.2f", $sypa * 10 / $slope_length;
        $areaunits    = 'ha' if $units eq 'm';
        $areaunits    = 'ac' if $units eq 'ft';

        print "   </pre>
  <center>
   <h3>User inputs</h3>
    <table border=1>
     <tr>
      <th bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>Location</th>
      <td colspan=5><font face='Arial, Geneva, Helvetica'><b>$climate_name</b>
       <br>
       <font size=1>
";
        print &GetParSummary($climatePar, $units);
        print "
       </font>
      </td>
     </tr>
     <tr>
      <th bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>Soil texture</th>
      <td colspan=5><font face='Arial, Geneva, Helvetica'>$soil_type{$soil}</td>
     </tr>
     <tr>
      <th bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>Element</th>
      <th bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>Treatment</th>
      <th bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>Gradient<BR> (%)</th>
      <th bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>Length<BR> ($units)</th>
      <th bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>Cover<BR> (%)</th>
      <th bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>Rock<BR> (%)</th>
     </tr>
     <tr>
      <th align=left rowspan=2 bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>Upper</th>
      <td rowspan=2><font face='Arial, Geneva, Helvetica'>$treatments{$treat1}</td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$ofe1_top_slope</td>
      <td align=right rowspan=2><font face='Arial, Geneva, Helvetica'>$user_ofe1_length</td>
      <td align=right rowspan=2><font face='Arial, Geneva, Helvetica'>$ofe1_pcover</td>
      <td align=right rowspan=2><font face='Arial, Geneva, Helvetica'>$ofe1_rock</td>
     </tr>
     <tr>
      <td align=right><font face='Arial, Geneva, Helvetica'>$ofe1_mid_slope</td>
     </tr>
     <tr>
      <th align=left rowspan=2 bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>Lower</th>
      <td rowspan=2><font face='Arial, Geneva, Helvetica'>$treatments{$treat2}</td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$ofe2_mid_slope</td>
      <td align=right rowspan=2><font face='Arial, Geneva, Helvetica'>$user_ofe2_length</td>
      <td align=right rowspan=2><font face='Arial, Geneva, Helvetica'>$ofe2_pcover</td>
      <td align=right rowspan=2><font face='Arial, Geneva, Helvetica'>$ofe2_rock  </td>
     </tr>
     <tr>
      <td align=right><font face='Arial, Geneva, Helvetica'>$ofe2_bot_slope</font></td>
     </tr>
     <tr>
      <th bgcolor=85d2d2>Description</th><td colspan=5><font face='Arial, Geneva, Helvetica' size=-1>$description</font></td>
     </tr>
    </table>
    <p>
";

        if ( $units eq 'm' ) {
            $user_precip = sprintf "%.1f", $precip;
            $user_rro    = sprintf "%.1f", $rro;
            $user_sro    = sprintf "%.1f", $sro;
            $user_asyra  = sprintf "%.3f", $asyra;    # 2004.10.14 DEH
            $user_asypa  = sprintf "%.3f", $asypa;    # 2004.10.14 DEH
            $rate        = 't ha<sup>-1</sup>';
            $pcp_unit    = 'mm';
        }
        if ( $units eq 'ft' ) {
            $user_precip = sprintf "%.2f", $precip * 0.0394;    # mm to in
            $user_rro    = sprintf "%.2f", $rro * 0.0394;       # mm to in
            $user_sro    = sprintf "%.2f", $sro * 0.0394;       # mm to in
            $user_asyra  = sprintf "%.3f",
              $asyra * 0.445;    # t/ha to t/ac # 2004.10.14 DEH
            $user_asypa = sprintf "%.3f",
              $asypa * 0.445;    # t/ha to t/ac # 2004.10.14 DEH
            $rate     = 't ac<sup>-1</sup>';
            $pcp_unit = 'in.';
        }
        print "
   <p><hr><p>
   <h3>Mean annual averages for $simyears years</h3>
    <table border=0 cellpadding=4>
     <tr>
      <td colspan=3></td><th colspan=2><font size=-1>Total in<br>$years2sim years</font></th>
     </tr>
     <tr>
      <td><font face='Arial, Geneva, Helvetica'>$user_precip</td>
      <td><font face='Arial, Geneva, Helvetica'>$pcp_unit</td>
      <td><font face='Arial, Geneva, Helvetica'>precipitation from </td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$storms</td>
      <td><font face='Arial, Geneva, Helvetica'>
          <a onMouseOver=\"window.status='There were $storms storms in $simyears year(s)';return true;\"
             onMouseOut=\"window.status='';return true;\">
          storms</a></td>
     </tr>
     <tr>
      <td><font face='Arial, Geneva, Helvetica'>$user_rro</td>
      <td><font face='Arial, Geneva, Helvetica'>$pcp_unit</td>
      <td><font face='Arial, Geneva, Helvetica'>runoff from rainfall from</td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$rainevents</td>
      <td><font face='Arial, Geneva, Helvetica'>events</td>
     </tr>
     <tr>
      <td><font face='Arial, Geneva, Helvetica'>$user_sro</td>
      <td><font face='Arial, Geneva, Helvetica'>$pcp_unit</td>
      <td><font face='Arial, Geneva, Helvetica'>runoff from snowmelt or winter rainstorm from</td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$snowevents</td>
      <td><font face='Arial, Geneva, Helvetica'>events</td>
     </tr>
     <tr>
      <td valign=bottom><font face='Arial, Geneva, Helvetica'>$user_asyra</td>
      <td><font face='Arial, Geneva, Helvetica'>$rate</td>
      <td valign=bottom>upland erosion rate ($syra kg m<sup>-2</sup>)</td>
     </tr>
     <tr>
      <td valign=bottom><font face='Arial, Geneva, Helvetica'>$user_asypa</td>
      <td><font face='Arial, Geneva, Helvetica'>$rate</td>
      <td valign=bottom><font face='Arial, Geneva, Helvetica'>sediment leaving profile ($sypa kg m<sup>-1</sup> width)</td>
     </tr>
    </table>
   </center>
";

#####
        if ( lc($action) =~ /vegetation/ ) {
            &cropper;
            print "<center>\n";
            print "<p><hr><p><h2>Vegetation check for $simyears years</h2>\n";
            if ( $units eq "ft" ) {
                print "<table border=1>
           <tr><th>Element
               <th>Biomass<br>(t ac<sup>-1</sup>)
               <th>Cover<br>(%)
           <tr><th>Upper<td align=right>";
                printf "%.4f", $livebiomean[1] * 4.45;
                print "<td align=right>";
                printf "%7.2f", $rillmean[1] * 100;
                print "  <tr><th>Lower<td align=right>";
                printf "%.4f", $livebiomean[2] * 4.45;
                print "<td align=right>";
                printf "%7.2f", $rillmean[2] * 100;
                print "  </table></center>\n";
            }
            else {    # ($units eq "m")
                print "<table border=1>
           <tr><th>Element<th>Biomass<br>(kg m<sup>-2</sup>)<th>Cover<br>(%)
           <tr><th>Upper<td align=right>";
                printf "%.4f", $livebiomean[1];
                print "<td align=right>";
                printf "%7.2f", $rillmean[1] * 100;
                print "  <tr><th>Lower<td align=right>";
                printf "%.4f", $livebiomean[2];
                print "<td align=right>";
                printf "%7.2f", $rillmean[2] * 100;
                print "  </table></center>\n";
            }
        }
        else {
            &parsead;
            print "
   <center>
    <p><hr><p>
    <h3>Return period analysis<br>
        based on $simyears&nbsp;years of climate</h3>
    <p>
    <table border=1 cellpadding=3>
     <tr>
      <th bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>Return<br>Period</th>
      <th bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>Precipitation<br>($pcp_unit)</th>
      <th bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>Runoff<br>($pcp_unit)</th>
      <th bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>Erosion<br>($rate)</th>
      <th bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>Sediment<br>($rate)</th>
     </tr>";

            $rcf = 1;
            $dcf = 1;    # rate conversion factor; depth conversion factor
            if ( $units eq 'ft' ) {
                $rcf = 0.445;
                $dcf = 0.0394;
            }            # t/ha to t/ac; mm to in.
            $ii           = 0;
            @rp_year_text = ( '1st', '2nd', '5th', '10th', '20th' );
            for $rp_year ( 1, 2, 5, 10, 20 ) {
                $rp = $simyears / $rp_year;
                if ( $rp >= 1 ) {
                    $user_pcpa = sprintf "%.2f", $pcpa[ $rp_year - 1 ] * $dcf;
                    $user_ra   = sprintf "%.2f", $ra[ $rp_year - 1 ] * $dcf;
                    $asyr      = sprintf "%.2f", $detach[ $rp_year - 1 ] * 10 *
                      $rcf;    # kg.m^2 * 10 = t/ha * 0.445 = t/ac

#     $asyp = sprintf "%.2f", $sed_del[$rp_year-1] * $ofe_width / (100000 * $ofe_area) * $rcf;	# kg/m width * m width * (1 t / 1000 kg) / area-in-ha
                    $asyp = sprintf "%.4f",
                      $sed_del[ $rp_year - 1 ] * 10 /
                      $slope_length *
                      $rcf;    # 2006.01.20 DEH

                    print "
     <tr>
      <th bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>
        <a onMouseOver=\"window.status='For year with $rp_year_text[$ii] largest values';return true;\"
           onMouseOut=\"window.status='';return true;\">$rp year</a></th>
      <td align=right><font face='Arial, Geneva, Helvetica'>$user_pcpa</td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$user_ra</td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$asyr</td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$asyp</td>
     </tr>
";
                    $ii += 1;
                }
            }
            $user_avg_pcp = sprintf "%.2f", $avg_pcp * $dcf;
            $user_avg_ro  = sprintf "%.2f", $avg_ro * $dcf;
            $user_asyra   = sprintf "%.2f", $asyra * $rcf;
            $user_asypa   = sprintf "%.4f", $asypa * $rcf;     # 2006.01.20 DEH
            print "
     <tr>
      <th bgcolor=yellow><font face='Arial, Geneva, Helvetica'>Average</th>
      <td align=right><font face='Arial, Geneva, Helvetica'>$user_avg_pcp</td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$user_avg_ro</td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$user_asyra</td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$user_asypa</td>
     </tr>
    </table>
";
            $base_size        = 100;
            $prob_no_pcp      = sprintf "%.2f", $nzpcp / $simyears;
            $prob_no_runoff   = sprintf "%.2f", $nzra / $simyears;
            $prob_no_erosion  = sprintf "%.2f", $nzdetach / $simyears;
            $prob_no_sediment = sprintf "%.2f", $nzsed_del / $simyears;

            print "
    <p>
    <hr>
<!--
<h2>Yearly probabilities based on $simyears years</h2>
-->
   <h3>Probabilities of occurrence first year following disturbance<br>
       based on $simyears&nbsp;years of climate</h3>
    <table border=1 cellpadding=4>
     <tr>
      <th align=right><font face='Arial, Geneva, Helvetica'>Probability there is runoff
      <td><font face='Arial, Geneva, Helvetica'>";
            printf "%.0f", ( 1 - $prob_no_runoff ) * 100;
            print " %</td>
      <td><font face='Arial, Geneva, Helvetica'>
        <a onMouseOver=\"window.status='$nnzra year(s) in $simyears had runoff';return true;\"
           onMouseOut=\"window.status='';return true;\">
        <img src=\"/fswepp/images/rouge.gif\" height=15 width=",
              ( 1 - $prob_no_runoff ) * $base_size, "></a>
        <a onMouseOver=\"window.status='$nzra year(s) in $simyears had no runoff';return true;\"
           onMouseOut=\"window.status='';return true;\">
        <img src=\"/fswepp/images/green.gif\" height=15 width=",
              ($prob_no_runoff) * $base_size, "></a></td>
     </tr>
     <tr>
      <th align=right><font face='Arial, Geneva, Helvetica'>Probability there is erosion</th>
      <td>";
            printf "%.0f", ( 1 - $prob_no_erosion ) * 100;
            print " %</td>
      <td><font face='Arial, Geneva, Helvetica'>
       <a onMouseOver=\"window.status='$nnzdetach year(s) in $simyears had erosion';return true;\"
           onMouseOut=\"window.status='';return true;\">
        <img src=\"/fswepp/images/rouge.gif\" height=15 width=",
              ( 1 - $prob_no_erosion ) * $base_size, "></a>
        <a onMouseOver=\"window.status='$nzdetach year(s) in $simyears had no erosion';return true;\"
           onMouseOut=\"window.status='';return true;\">
        <img src=\"/fswepp/images/green.gif\" height=15 width=",
              ($prob_no_erosion) * $base_size, "></a></td>
     </tr>
     <tr>
      <th align=right><font face='Arial, Geneva, Helvetica'>Probability there is sediment delivery</th>
      <td><font face='Arial, Geneva, Helvetica'>";
            printf "%.0f", ( 1 - $prob_no_sediment ) * 100;
            print " %</td>
      <td><font face='Arial, Geneva, Helvetica'>
          <a onMouseOver=\"window.status='$nnzsed_del year(s) in $simyears had sediment delivery';return true;\"
             onMouseOut=\"window.status='';return true;\">
          <img src=\"/fswepp/images/rouge.gif\" height=15 width=",
              ( 1 - $prob_no_sediment ) * $base_size, "></a>
          <a onMouseOver=\"window.status='$nzsed_del year(s) in $simyears had no sediment delivery';return true;\"
             onMouseOut=\"window.status='';return true;\">
          <img src=\"/fswepp/images/green.gif\" height=15 width=",
              ($prob_no_sediment) * $base_size, "></a></td>
     </tr>
    </table>
   </center>
";
        }    #	else case of if (lc($action) =~ /vegetation/)

        print '
   <p>
   <center>
    <hr>
    <a href="/cgi-bin/fswepp/wd/weppdist.pl" style="text-decoration: none;">
        <input type="button" value="Return to Input Screen">
    </a>
    <br>
    <hr>
   </center>
';

#####

        # print "<hr width=50%> \n";

        if ( $outputi == 1 ) {
            print '
   <hr>
   <p>
    <h3 align=center>Generated slope file</h3>
    <pre>
';
            open slopef, "<$slopeFile";
            while (<slopef>) {
                print;
            }
            close slopef;
            print '</PRE>';
        }    # $outputi == 1

        #----------------------
    }    # $found == 1
    else {    #  $found == 1
        print
"<p><font color=red>Something seems to have gone awry!</font>\n<p><hr><p>\n";
    }         # $found == 1

    #-----------------------------------------

    if ( $outputf == 1 ) {
        print '<BR><CENTER><H2>WEPP output</H2></CENTER>';
        print '<PRE>';
        open weppout, "<$outputFile";
        for $line ( 0 .. 38 ) {
            $_ = <weppout>;
            print;
        }
        print "\n\n";
        while (<weppout>) {    # skip 'til "ANNUAL AVERAGE SUMMARIES"
            if (/ANNUAL AVERAGE SUMMARIES/) {    # DEH 03/07/2001 patch
                last;
            }
        }
        print;
        while (<weppout>) {                      # DEH 03/07/2001 patch
            print;
        }
        close weppout;
        print '</PRE>';
        print "<p><hr>";
        print '<center>
<a href="/cgi-bin/fswepp/wd/weppdist.pl">
<img src="/fswepp/images/rtis.gif"
  alt="Return to input screen" border="0" align=center></A>
<BR><HR></center>';
    }    # $outputf == 1

    #-------------------------------------

}    # $rcin eq ''
else {
    print "Content-type: text/html\n\n";
    print '<HTML>
 <HEAD>
  <TITLE>Disturbed WEPP Results</TITLE>
 </head>
 <body>
  <h3>Disturbed WEPP Results</h3>
   Error in input:<br><br>
';
    print $rcin;
    print "   <br><br>\n";
}

#   print values %parameters;     # if ($debug);

if ( $rcin eq '' ) {

    print '  <br><center>
    [ <a href="javascript:void(showslopefile())">slope</a>
    | <a href="javascript:void(showsoilfile())">soil</a>
    | <a href="javascript:void(showvegfile())">vegetation</a>
    | <a href="javascript:void(showcligenparfile())">weather</a>
    | <a href="javascript:void(showresponsefile())">response</a>
    || <a href="javascript:void(showextendedoutput())">WEPP results</a> ]
    </center>
';

    print "
    <br><br>
    <font size=-2>
     Disturbed WEPP 2.0 Results v.";
    print
'     <a href="https://github.com/wepp-in-the-woods/fswepp-docker/commits/main/var/www/cgi-bin/fswepp/wd/wd.pl">';
    print
"     $version</a> based on <b>WEPP $weppver</b>, CLIGEN $cligen_version<br>";
}

&printdate;
print "
     <br>
     Disturbed WEPP Run ID $unique
    </font>
   </blockquote>
 </body>
</html>
";

#  system "rm working/$unique.*";

#################################################    unlink <$working/$unique.*>;       # da

$host        = $ENV{REMOTE_HOST};
$host        = $ENV{REMOTE_ADDR} if ( $host eq '' );
$user_really = $ENV{'HTTP_X_FORWARDED_FOR'};              # DEH 11/14/2002
$host        = $user_really if ( $user_really ne '' );    # DEH 11/14/2002


my ($lat, $long) = GetParLatLong($climatePar);

# 2008.06.04 DEH end

#  record activity in Disturbed WEPP log (if running on remote server)

open WDLOG, ">>../working/_$thisyear/wd2.log";    # 2012.12.31 DEH
flock( WDLOG, 2 );

#      $host = $ENV{REMOTE_HOST};
#      if ($host eq "") {$host = $ENV{REMOTE_ADDR} };
print WDLOG "$host\t\"";
printf WDLOG "%0.2d:%0.2d ", $hour, $min;
print WDLOG $ampm[$ampmi], "  ", $days[$wday], " ", $months[$mon], " ",
  $mday, ", ", $thisyear, "\"\t";
print WDLOG $years2sim, "\t";
print WDLOG '"', trim($climate_name), "\"\t";

#       print WDLOG $lat_long,"\n";                      # 2008.06.04 DEH
print WDLOG "$lat\t$long\n";    # 2008.06.04 DEH

#       print WDLOG $climate_name,"\n";
close WDLOG;

#    open CLIMLOG, '>../working/lastclimate.txt';       # 2005.07.14 DEH
open CLIMLOG, ">../working/_$thisyear/lastclimate.txt";    # 2012.12.31 DEH
flock CLIMLOG, 2;
print CLIMLOG 'Disturbed WEPP 2.0: ', trim($climate_name);
close CLIMLOG;

$ditlogfile = ">>../working/_$thisyear/wd2/$thisweek";     # 2013.01.07 DEH
open MYLOG, $ditlogfile;
flock MYLOG, 2;                                            # 2005.02.09 DEH
print MYLOG '.';
close MYLOG;
################################# start 2009.11.02 DEH

#  record run in user wepp run log file

$climate_trim = trim($climate_name);
$climate_trim = $CL
  if ( $climate_trim eq '' )
  ;    # 2010.04.22 capture filename in case of failed run

open RUNLOG, ">>$runLogFile";
flock( RUNLOG, 2 );
print RUNLOG "WD\t$unique\t", '"';
printf RUNLOG "%0.2d:%0.2d ", $hour, $min;
print RUNLOG $ampm[$ampmi], "  ", $days[$wday], " ", $months[$mon], " ", $mday,
  ", ", $year + 1900, '"', "\t", '"';
print RUNLOG $climate_trim, '"', "\t";
print RUNLOG "$years2sim\t";
print RUNLOG "$soil\t";
print RUNLOG "$treat1\t";
print RUNLOG "$user_ofe1_length\t";    # 2010.04.22 Earthday 40
print RUNLOG "$ofe1_top_slope\t";
print RUNLOG "$ofe1_mid_slope\t";
print RUNLOG "$ofe1_pcover\t";
print RUNLOG "$ofe1_rock\t";
print RUNLOG "$treat2\t";
print RUNLOG "$user_ofe2_length\t";    # 2010.04.22 Earthday 40
print RUNLOG "$ofe2_mid_slope\t";
print RUNLOG "$ofe2_bot_slope\t";
print RUNLOG "$ofe2_pcover\t";
print RUNLOG "$ofe2_rock\t";
print RUNLOG "$ofe_area\t";
print RUNLOG "$units\t";
print RUNLOG '"', $description, '"', "\n";
close RUNLOG;

################################# end 2009.11.02 DEH

sub CreateManagementFileT {

# disturbed WEPP management files based on Tahoe Basin model -- no veg calibration needed

    open MANFILE, ">$manFile";

    print MANFILE "98.4
#
#\tCreated for Disturbed WEPP by wd.pl (v. $version)
#\tNumbers by: Bill Elliot (USFS) et alia
#

2\t# number of OFEs
$years2sim\t# (total) years in simulation

#################
# Plant Section #
#################

2\t# looper; number of Plant scenarios $treat1.plt $treat2.plt

";

    open PS1, "<datatahoebasin/$treat1.plt";    # WEPP plant scenario

   #  read 14 lines (base 0); line 9 entry 2 will change (biomass) as f(climate)

#  $beinp is biomass energy ratio (real ~ 0 to 1000): plant scenario 7.3 (p. 33)
#  the following equation relates biomass ratio to cover (whole) percent and precipitation in mm
#  from work December 1999 by W.J. Elliot unpublished.

    $pcover = $ofe1_pcover
      ; # decided not to limit input cover to 100%; use whatever is entered (for now)

    while (<PS1>) {
        print MANFILE $_;    # print line to management file
    }
    close PS1;

    open PS2, "<datatahoebasin/$treat2.plt";

   #  read 14 lines (base 0); line 9 entry 2 will change (biomass) as f(climate)

    $pcover = $ofe2_pcover;

    print MANFILE "\n";
    while (<PS2>) {
        print MANFILE $_;
    }
    close PS2;

    print MANFILE "
#####################
# Operation Section #
#####################

2\t# looper; number of Operation scenarios $treat1.op $treat2.op

";

    open OP, "<datatahoebasin/$treat1.op";    # Operations
    while (<OP>) {

        #    if (/itype/) {substr ($_,0,1) = "1"}
        print MANFILE $_;
    }
    close OP;

    print MANFILE "\n";

    open OP, "<datatahoebasin/$treat2.op";
    while (<OP>) {

        #    if (/itype/) {substr ($_,0,1) = "2"}
        print MANFILE $_;
    }
    close OP;

    print MANFILE "
##############################
# Initial Conditions Section #
##############################

2\t# looper; number of Initial Conditions scenarios $treat1.ini $treat2.ini

";

#  $inrcov is initial interrill cover (real 0-1): initial conditions 6.6 (p. 37)
#  $rilcov is initial rill cover (real 0-1): initial conditions 9.3 (p. 37)
#  $pcoverf is user-specified ground cover, formatted, decimal percent
#  December 1999 by W.J. Elliot unpublished.

    ( $ofe1_pcover > 100 ) ? $pcover = 100 : $pcover = $ofe1_pcover;
    $inrcov  = sprintf "%.2f", $pcover / 100;
    $rilcov  = $inrcov;
    $pcoverf = sprintf '%7.5f', $pcover / 100;

    open IC, "<datatahoebasin/$treat1.ini";   # Initial Conditions Scenario file

    #  read 14 lines (base 0); change line 8 values 1 and 5; line 11 value 2

    while (<IC>) {

        #    if (/iresd/) {substr ($_,0,1) = "1"}
        if (/inrcov/) {
            $index_pos = index( $_, 'inrcov' );
            $ics_left  = substr( $_, 0, $index_pos );
            $ics_right = substr( $_, $index_pos + 6 );
            $_         = $ics_left . $inrcov . $ics_right;
            if ($debug) { print "<b>ics1:</b><br>$_<br>\n" }
        }
        if (/rilcov/) {
            $index_pos = index( $_, 'rilcov' );
            $ics_left  = substr( $_, 0, $index_pos );
            $ics_right = substr( $_, $index_pos + 6 );
            $_         = $ics_left . $rilcov . $ics_right;
            if ($debug) { print "$_<br>\n" }
        }
        if (/pcover/) {
            $index_pos = index( $_, 'pcover' );
            $ics_left  = substr( $_, 0, $index_pos );
            $ics_right = substr( $_, $index_pos + 6 );
            $_         = $ics_left . $pcoverf . $ics_right;
            if ($debug) { print "<b>ics1:</b><br>$_<br>\n" }
        }
        print MANFILE $_;
    }
    close IC;

    print MANFILE "\n";

    ( $ofe2_pcover > 100 ) ? $pcover = 100 : $pcover = $ofe2_pcover;
    $inrcov  = sprintf "%.2f", $pcover / 100;
    $rilcov  = $inrcov;
    $pcoverf = sprintf '%7.5f', $pcover / 100;

    open IC, "<datatahoebasin/$treat2.ini";

    #  read 14 lines (base 0); change line 8 values 1 and 5; line 11 value 2
    while (<IC>) {

        #    if (/iresd/) {substr ($_,0,1) = "2"}
        if (/inrcov/) {
            $index_pos = index( $_, 'inrcov' );
            $ics_left  = substr( $_, 0, $index_pos );
            $ics_right = substr( $_, $index_pos + 6 );
            $_         = $ics_left . $inrcov . $ics_right;
            if ($debug) { print "<b>ics2:</b><br>$_<br>\n" }
        }
        if (/rilcov/) {
            $index_pos = index( $_, 'rilcov' );
            $ics_left  = substr( $_, 0, $index_pos );
            $ics_right = substr( $_, $index_pos + 6 );
            $_         = $ics_left . $rilcov . $ics_right;
            if ($debug) { print "$_</pre><br>\n" }
        }
        if (/pcover/) {
            $index_pos = index( $_, 'pcover' );
            $ics_left  = substr( $_, 0, $index_pos );
            $ics_right = substr( $_, $index_pos + 6 );
            $_         = $ics_left . $pcoverf . $ics_right;
            if ($debug) { print "$_</pre><br>\n" }
        }
        print MANFILE $_;
    }
    close IC;

    print MANFILE "
###########################
# Surface Effects Section #
###########################

2\t# Number of Surface Effects Scenarios

#
#   Surface Effects Scenario 1 of 2
#
Year 1
From WEPP database
USFS RMRS Moscow

1\t# landuse  - cropland
1\t# ntill - number of operations
  2\t# mdate  --- 1 / 2
  1\t# op --- Tah_****
      0.010\t# depth
      2\t# type

#
#   Surface Effects Scenario 2 of 2
#
Year 2
From WEPP database
USFS RMRS Moscow

1\t# landuse  - cropland
1\t# ntill - number of operations
  2\t# mdate  --- 1 / 2
  2\t# op --- Tah_****
      0.010\t# depth
      2\t# type

######################
# Contouring Section #
######################

0\t# looper; number of Contouring scenarios

####################
# Drainage Section #
####################

0\t# looper; number of Drainage scenarios

##################
# Yearly Section #
##################

2\t# looper; number of Yearly Scenarios

#
# Yearly scenario 1 of 2
#
Year 1



1\t# landuse <cropland>
1\t# plant growth scenario
1\t# surface effect scenario
0\t# contour scenario
0\t# drainage scenario
2\t# management <perennial>
   250\t# senescence date
   0\t# perennial plant date --- 0 /0
   0\t# perennial stop growth date --- 0/0
   0.0000\t# row width
   3\t# neither cut or grazed

#
# Yearly scenario 2 of 2
#
Year 2



1\t# landuse <cropland>
2\t# plant growth scenario
2\t# surface effect scenario
0\t# contour scenario
0\t# drainage scenario
2\t# management <perennial>
   250\t# senescence date
   0\t# perennial plant date --- 0 /0
   0\t# perennial stop growth date --- 0/0
   0.0000\t# row width
   3\t# neither cut or grazed
";
    print MANFILE "
######################
# Management Section #
######################
Disturbed WEPP Model
Two OFEs for forest conditions
W. Elliot 02/99

2\t# `nofe' - <number of Overland Flow Elements>
\t1\t# `Initial Conditions indx' - <$treat1>
\t2\t# `Initial Conditions indx' - <$treat2>
$years2sim\t# `nrots' - <rotation repeats..>
1\t# `nyears' - <years in rotation>
";

    for $i ( 1 .. $years2sim ) {
        print MANFILE "
#
#       Rotation $i : year $i to $i
#
\t1\t# `nycrop' - <plants/yr; Year of Rotation :  $i - OFE : 1>
\t\t1\t# `YEAR indx' - <$treat1>

\t1\t# `nycrop' - <plants/yr; Year of Rotation :  $i - OFE : 2>
\t\t2\t# `YEAR indx' - <$treat2>
";
    }
    close MANFILE;
}


sub CreateResponseFile {

    open( ResponseFile, ">" . $responseFile );
    print ResponseFile "98.4\n";    # datver
    print ResponseFile "y\n";       # not watershed
    print ResponseFile "1\n";       # 1 = continuous
    print ResponseFile "1\n";       # 1 = hillslope
    print ResponseFile "n\n";       # hillsplope pass file out?
    if ( lc($action) =~ /vegetation/ ) {
        print ResponseFile "1\n";    # 1 = annual; abbreviated
    }
    else {
        print ResponseFile "2\n";    # 2 = annual; detailed
    }
    print ResponseFile "n\n";                # initial conditions file?
    print ResponseFile $outputFile, "\n";    # soil loss output file
    print ResponseFile "n\n";                # water balance output?
    if ( lc($action) =~ /vegetation/ ) {
        print ResponseFile "y\n";              # crop output?
        print ResponseFile $cropFile, "\n";    # crop output file name
    }
    else {
        print ResponseFile "n\n";              # crop output?
    }
    print ResponseFile "n\n";               # soil output?
    print ResponseFile "n\n";               # distance/sed loss output?
    print ResponseFile "n\n";               # large graphics output?
    print ResponseFile "n\n";               # event-by-event out?
    print ResponseFile "n\n";               # element output?
    print ResponseFile "n\n";               # final summary out?
    print ResponseFile "n\n";               # daily winter out?
    print ResponseFile "n\n";               # plant yield out?
    print ResponseFile "$manFile\n";        # management file name
    print ResponseFile "$slopeFile\n";      # slope file name
    print ResponseFile "$climateFile\n";    # climate file name
    print ResponseFile "$soilFile\n";       # soil file name
    print ResponseFile "0\n";               # 0 = no irrigation
    print ResponseFile "$years2sim\n";      # no. years to simulate
    print ResponseFile "0\n";               # 0 = route all events

    close ResponseFile;
    return $responseFile;
}

sub checkInput {

    $rc = '';
    if ( $CL eq "" ) { $rc .= "No climate selected<br>\n" }
    if (   $soil ne "sand"
        && $soil ne "silt"
        && $soil ne "clay"
        && $soil ne "loam" )
    {
        $rc .= "Invalid soil: " . $soil . "<br>\n";
    }

    #  if ($treat1 ne "skid" && $treat1 ne "high" && $treat1 ne "low"
    #      && $treat1 ne "short" && $treat1 ne "tall" && $treat1 ne "shrub"
    #      && $treat1 ne "tree5" && $treat1 ne "tree20")
    if ( $treatments{$treat1} eq "" ) {
        $rc .= "Invalid upper treatment: " . $treat1 . "<br>\n";
    }
    if ( $treatments{$treat2} eq "" ) {
        $rc .= "Invalid lower treatment: " . $treat2 . "<br>\n";
    }
    if ( $units eq 'm' ) {
        if ( $ofe1_length < 0 || $ofe1_length > 3000 ) {
            $rc .= "Invalid upper length; range 0 to 3000 m<br>\n";
        }
        if ( $ofe2_length < 0 || $ofe2_length > 3000 ) {
            $rc .= "Invalid lower length; range 0 to 3000 m<br>\n";
        }
    }
    else {
        if ( $ofe1_length < 0 || $ofe1_length > 9000 ) {
            $rc .= "Invalid upper length; range 0 to 9000 ft<br>\n";
        }
        if ( $ofe2_length < 0 || $ofe2_length > 9000 ) {
            $rc .= "Invalid lower length; range 0 to 9000 ft<br>\n";
        }
    }
    if ( $ofe1_top_slope < 0 || $ofe1_top_slope > 1000 ) {
        $rc .= "Invalid upper top gradient; range 0 to 1000 %<br>\n";
    }
    if ( $ofe1_mid_slope < 0 || $ofe1_mid_slope > 1000 ) {
        $rc .= "Invalid upper mid gradient; range 0 to 1000 %<br>\n";
    }
    if ( $ofe2_mid_slope < 0 || $ofe2_mid_slope > 1000 ) {
        $rc .= "Invalid lower mid gradient; range 0 to 1000 %<br>\n";
    }
    if ( $ofe2_bot_slope < 0 || $ofe2_bot_slope > 1000 ) {
        $rc .= "Invalid lower toe gradient; range 0 to 1000 %<br>\n";
    }

    #   if ($ofe1_pcover < 0 || $ofe1_pcover > 100)
    #      {$rc .= "Invalid upper percent cover; range 0 to 100 %<br>\n"}
    #   if ($ofe2_pcover < 0 || $ofe2_pcover > 100)
    #      {$rc .= "Invalid lower percent cover; range 0 to 100 %<br>\n"}
    if ( $rc ne '' ) { $rc = '<font color="red"><b>' . $rc . "</b></font>\n" }
    return $rc;
}

sub cropper {

    # average crop (.crp) file rill cover and live biomass
    #    by OFE  (ignoring spikes to zero?)
    #
    # Knuth: recurrent mean calculation is:
    #
    #   M(1) = x(1)
    #   M(k) = M(k-1) + (x(k)-M(k-1) / k
    #
    # (Seminumerical Methods, p. 232, Section 4.2.2, No. 15)

    open CROP, "<" . $cropFile;
    if ($debug) { print "Cropper: opening $cropFile<br>\n" }

    # read 15 lines of headers

    for $line ( 1 .. 15 ) {
        $header = <CROP>;
    }

    $_ = <CROP>;

    #  chomp;
    @fields         = split ' ', $_;
    $rillmean[1]    = $fields[5];
    $livebiomean[1] = $fields[8];
    $_              = <CROP>;

    #  chomp;
    @fields         = split ' ', $_;
    $rillmean[2]    = $fields[5];
    $livebiomean[2] = $fields[8];
    $count          = 1;

    while (<CROP>) {

        #    $record1 = <CROP>;
        if ( $_ eq "" ) { last }
        $count += 1;

        #    chomp;
        @fields = split ' ', $_;
        $ofe    = $fields[7];

        #    print "\n ",$fields[5],"  ",$fields[7],"  ",$fields[8];
        $rillcover[$ofe]   = $fields[5];
        $livebiomass[$ofe] = $fields[8];
        $rillmean[$ofe] += ( $rillcover[$ofe] - $rillmean[$ofe] ) / $count;
        $livebiomean[$ofe] +=
          ( $livebiomass[$ofe] - $livebiomean[$ofe] ) / $count;
    }
    close CROP;

    #  print "<pre>\n";
    #  print "OFE 1   Mean rill cover =   ", $rillmean[1],"\n";
    #  print "        Mean live biomass = ",$livebiomean[1],"\n";
    #  print "OFE 2   Mean rill cover =   ", $rillmean[2],"\n";
    #  print "        Mean live biomass = ",$livebiomean[2],"\n";
    #  print "Count = ", $count;
    #  print "</pre>";

}

sub numerically { $b <=> $a }

sub parsead {    ############### parsead

    $dailyannual = "<" . $outputFile;

    #   if ($debug) {print "\nParsead: opening $outputFile<br>\n"}
    open AD, $dailyannual;
    $_ = <AD>;

    if (/Annual; detailed/) {    # Good file
        for $i ( 2 .. 8 ) { $_ = <AD> }

        #    if (/VERSION *([0-9.]+)/) {$version = $1}
        #    print "\n", $version,"\n";

        #======================== yearly precip and runoff events and amounts

    #    print "</center><pre>\n";
    #    print "    \t       \t       \t storm \t storm \t melt  \t melt\n";
    #    print "    \t precip\t precip\t runoff\t runoff\t runoff\t runoff\n";
    #    print "year\t events\t amount\t events\t amount\t events\t amount\n\n";
        while (<AD>) {
            if (/year: *([0-9]+)/) {
                $year = $1;

                #        print $year,"  ";
                for $i ( 1 .. 6 ) { $_ = <AD> }
                (
                    $pcpe[$year], $pcpa[$year], $sre[$year],
                    $sra[$year],  $mre[$year],  $mra[$year]
                ) = split ' ', $_;

#        print "\t",$pcpe[$year],"\t",$pcpa[$year],"\t",$sre[$year],"\t",$sra[$year],"\t",$mre[$year],"\t",$mra[$year],"\n";
                $re[$year] = $sre[$year] + $mre[$year];
                $ra[$year] = $sra[$year] + $mra[$year];
            }
        }
        close AD;

        #======================== yearly sediment leaving profile

        open AD, $dailyannual;

        #    print "\nyear\tSediment\n\tleaving\n\tprofile\n\n";
        while (<AD>) {
            if (/SEDIMENT LEAVING PROFILE for year *([0-9]+) *([0-9.]+)/) {
                $year = $1;
                $sed_del[$year] = $2;

                #       print "$year\t$sed_del[$year]\n";
            }
        }
        close AD;

     #====== Net detachment (not all years are represented; final is an average)

        open AD, $dailyannual;
        $detcount = 0;
        while (<AD>) {
            if (/Net Detachment *([A-Za-z( )=]+) *([0-9.]+)/) {
                $detach[$detcount] = $2;
                $detcount += 1;
            }
        }

        # Using pop to get the last element and also removing it from @detach
        $avg_det = pop(@detach);
        close AD;

        #===================== Mean annual values for various parameters

        open AD, $dailyannual;
        while (<AD>) {
            if (/Mean annual precipitation *([0-9.]+)/) {
                $avg_pcp = $1;

                #        print "\n\nAverage annual precip: $avg_pcp\n";
                $_ = <AD>;
                if (/Mean annual runoff from rainfall *([0-9.]+)/) {
                    $avg_rro = $1;

             #          print "Average annual runoff from rainfall: $avg_rro\n";
                }
                $_ = <AD>;
                $_ = <AD>;
                if (/rain storm during winter *([0-9.]+)/) {
                    $avg_sro = $1;

             #          print "Average annual runoff from snowmelt: $avg_sro\n";
                }
            }
            if (/AVERAGE ANNUAL SEDIMENT LEAVING PROFILE/) {

                #        print $_;
                if (/AVERAGE ANNUAL SEDIMENT LEAVING PROFILE *([0-9.]+)/)
                {    # WEPP pre-98.4
                    $avg_sed = $1;
                }
                else {    # WEPP 98.4
                    $_ = <AD>;    # print;
                    if (/ *([0-9.]+)/) { $avg_sed = $1 }
                }

                #        print "Average sediment delivery = $avg_sed\n";
            }
        }
        close AD;

        @pcpa = sort numerically @pcpa;

        #print @pcpa,"\n";
        @ra = sort numerically @ra;

        #print @ra,"\n";
        @detach = sort numerically @detach;

        #print "detach:", @detach,"\n";
        @sed_del = sort numerically @sed_del;

        #print @sed_del,"\n";

        $nnzpcp     = 0;
        $nnzra      = 0;
        $nnzdetach  = 0;
        $nnzsed_del = 0;
        foreach $elem (@pcpa)    { $nnzpcp     += 1 if ( $elem * 1 != 0 ) }
        foreach $elem (@ra)      { $nnzra      += 1 if ( $elem * 1 != 0 ) }
        foreach $elem (@detach)  { $nnzdetach  += 1 if ( $elem * 1 != 0 ) }
        foreach $elem (@sed_del) { $nnzsed_del += 1 if ( $elem * 1 != 0 ) }
        $nzpcp       = $simyears - $nnzpcp;
        $nzra        = $simyears - $nnzra;
        $omnzra      = 1 - $nzra;
        $nzdetach    = $simyears - $nnzdetach;
        $omnzdetach  = 1 - $nzdetach;
        $nzsed_del   = $simyears - $nnzsed_del;
        $omnzsed_del = 1 - $nzsed_del;

        $avg_ro = $avg_rro + $avg_sro;

#print $year;
#print "<pre>";
#print "\n================================\n";
#print "\t precip\trunoff\terosion\tsed\n\n";
#print "#(x=0)\t pcp= $nnzpcp\t sra= $nnzra\t det= $nnzdetach\t sed_del= $nnzsed_del\n";
#print "#(x=0)\t pcp= $nzpcp\t sra= $nzra\t det= $nzdetach\t sed_del= $nzsed_del\n";
#print "p(x=0)\t",($nzpcp)/$year,
#           "\t",($nzra)/$year,
#          "\t",($nzdetach)/$year,
#          "\t",($nzsed_del)/$year,"\n";
#print "Average $avg_pcp\t$avg_ro\t$avg_det\t$avg_sed\n";
#print "return\nperiod\n";
#print "100\t$pcpa[0]\t$ra[0]\t$detach[0]\t$sed_del[0]\n";    # 1
#print " 50\t$pcpa[1]\t$ra[1]\t$detach[1]\t$sed_del[1]\n";    # 2
#print " 20\t$pcpa[4]\t$ra[4]\t$detach[4]\t$sed_del[4]\n";    # 5
#print " 10\t$pcpa[9]\t$ra[9]\t$detach[9]\t$sed_del[9]\n";    # 10
#print "  5\t$pcpa[19]\t$ra[19]\t$detach[19]\t$sed_del[19]\n";    # 20
#print "\n================================\n";
#print "</pre><center>\n";
    }    # if /Annual detailed/
    else {
        chomp;
        s/^\s*(.*?)\s*$/$1/;
        print "\nExpecting 'Annual; detailed' file; you gave me a '$_' file\n";
    }
}

# ------------------------ end of subroutines ----------------------------

