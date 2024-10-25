#!/usr/bin/perl

use warnings;
use strict;
use CGI;
use CGI qw(escapeHTML header);

use MoscowFSL::FSWEPP::CligenUtils
  qw(CreateCligenFile GetParSummary GetParLatLong);
use MoscowFSL::FSWEPP::FsWeppUtils
  qw(get_version printdate get_thisyear_and_thisweek get_user_id get_units);
use MoscowFSL::FSWEPP::WeppRoad
  qw(CreateSlopeFileWeppRoad CreateSoilFileWeppRoad CheckInputWeppRoad GetSoilFileTemplate);

use String::Util qw(trim);

my $debug = 0;

my $version = get_version(__FILE__);
my $user_ID = get_user_id();
my ( $thisyear, $thisweek ) = get_thisyear_and_thisweek();
my ( $units, $areaunits )   = get_units();

my $weppversion = "wepp2010";

my $cgi = CGI->new;

my $traffic      = escapeHTML( $cgi->param('traffic') );

# TODO: standardize the names of the parameters to names of perl variables
my $UBR      = escapeHTML( $cgi->param('rock') ) * 1;    # Rock fragment percentage
my $SoilType = escapeHTML( $cgi->param('soil_type') );
my $surface  = escapeHTML( $cgi->param('surface') );
my $slope    = escapeHTML( $cgi->param('slope') );
my $soilFilefq = &GetSoilFileTemplate("data/", $surface, $SoilType, $slope );

my $working      = '../working';
my $unique      = "wepp-$$";
my $newSoilFile = "$working/$unique.sol";
my ($URR, $UFR);

$newSoilFile =
  &CreateSoilFileWeppRoad( $soilFilefq, $newSoilFile, $surface, $traffic,
    $UBR, \$URR, \$UFR );

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

if    (  substr( $surface, 0, 1 ) eq 'g' ) { print 'Graveled ' }
elsif (  substr( $surface, 0, 1 ) eq 'p' ) { print 'Paved ' }
if    ( $SoilType eq 'clay' ) {
    print "clay loam (MH, CH)<br>\n";
    print "Shales and similar decomposing fine-grained sedimentary rock<br>\n";
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
else {
    die "Unknown soil type: $SoilType\n";
}

if   ( $slope eq 'inveg' ) { print 'High ' }
else                 { print 'Low ' }    # HR
print "critical shear<br>\n";            # HR

print "     <hr><b><font face=courier><pre>\n";
open SOIL, "<$newSoilFile";
my $weppver = <SOIL>;
my $comment = <SOIL>;
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
my $record = <SOIL>;
my  @vals   = split " ", $record;
my $ntemp  = @vals[0];    # no. flow elements or channels
my $ksflag = @vals[1];    # 0: hold hydraulic conductivity constant
                       # 1: use internal adjustments to hydr con

for my $i ( 1 .. $ntemp ) {    # Element $i
    print '       <tr><th colspan=3 bgcolor="#85D2D2">', "\n";
    $record      = <SOIL>;
    my @descriptors = split "'", $record;
    print "       @descriptors[1]   ";            # slid: Road, Fill, Forest
    print "       texture: @descriptors[3]\n";    # texid: soil texture
    my ( $nsl, $salb, $sat, $ki, $kr, $shcrit, $avke ) = split " ",
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
    for my $layer ( 1 .. $nsl ) {
        $record = <SOIL>;
        my ( $solthk, $sand, $clay, $orgmat, $cec, $rfg ) = split " ", $record;
        print "       <tr><td><br><th colspan=2 bgcolor=#85D2D2>layer $layer\n";
        print
"       <tr><th align=left>Depth from soil surface to bottom of soil layer<td>$solthk<td>mm\n";
        print "       <tr><th align=left>Percentage of sand<td>$sand<td>%\n";
        print "       <tr><th align=left>Percentage of clay<td>$clay<td>%\n";
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
         <input type="hidden" value="', $soilFilefq, '" name"filename">
     </form>
    </center><p><hr><p></blockquote>
';
