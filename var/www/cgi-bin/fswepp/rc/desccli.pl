#!/usr/bin/perl

use warnings;
use CGI;
use CGI qw(escapeHTML);
use MoscowFSL::FSWEPP::FsWeppUtils qw(get_version);

#
# desccli.pl
#

my $debug    = 0;
my $version  = get_version(__FILE__);

my $referrer = $ENV{'HTTP_REFERER'};
if ( !$referrer ) {
    $referrer = '/fswepp/';
}

my $query    = CGI->new;
my $CL = $query->param('CL') || $ARGV[0];
chomp $CL;

my $units = $query->param('units') || $ARGV[1];
$units = 'm' if ( $units eq '-um' );

my $climateFile = $CL . '.cli';

open CLI, "<$climateFile";
$line = <CLI>;    #     4.3

$line = <CLI>;    #       1     1   0
( $itemp, $ibrkpt, $iwind ) = split ' ', $line;
$line = <CLI>;    # Station:  SNOTEL - Fallen Leaf Snotel A2
( $dupe, $climate_name ) = split ':', $line;
$line = <CLI>
  ; # Latitude Longitude Elevation (m) Obs. Years   Beginning year  Years simulated
$line = <CLI>;    #   38.935        -120.045   2028.96      99    2001      99
( $deglat, $deglon, $elev, $obsyrs, $ibyear, $numyr ) = split ' ', $line;
$line = <CLI>;    # Observed monthly ave max temperature (C)
$line = <CLI>
  ; #      5.6     6.6     9.3    10.9    14.9    19.3    24.0    23.6    21.4    15.8     8.6     4.8
(@obmaxt) = split ' ', $line;
$line = <CLI>;    # Observed monthly ave min temperature (C)
$line = <CLI>
  ; #     -7.7    -7.5    -6.0    -4.4    -1.3     1.2     4.5     4.3     2.1    -1.3    -5.3    -8.0
(@obmint) = split ' ', $line;
$line = <CLI>;    # Observed monthly ave solar radiation (Langleys/day)
$line = <CLI>
  ; #    213.5   283.3   408.6   498.4   589.3   674.2      ($deglat, $deglon, $elev, $obsyrs, $ibyear, $numyr) = split ' ',$line;
(@radave) = split ' ', $line;
$line = <CLI>;    # Observed monthly ave precipitation (mm)
$line = <CLI>
  ; #    324.7   268.5   255.5   133.6    98.6    32.2     3.2     7.8    25.6    82.0   200.2   332.6
(@obrain) = split ' ', $line;

close CLI;

@month_name =
  qw(January February March April May June July August September October November December);
@month_days = ( 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 );

$lat += 0;
$lon += 0;

##########################
chomp $climate_name;
$climate_name_filt = $climate_name;
$climate_name_filt =~ s/'/`/;
print "Content-type: text/html\n\n";
print "<HTML>\n";
print " <HEAD>\n";
print "  <TITLE>Climate Parameters</TITLE>\n";
print " </HEAD>\n";
print ' <body bgcolor=white link="#1603F3" vlink="#160A8C">
  <font face="Arial, Geneva, Helvetica">', "\n";
print "   <center>
    <h2>Climate file headers for $climate_name</h2>\n";

if ($debug) { print "climate: '$CL' ; units: '$units'<br>\n" }
##########################

$yr_rec += 0;
print '    <h3>';
printf "%.2f", abs($deglat);
print '<sup>o</sup>';
if   ( $deglat > 0 ) { print 'N ' }
else                 { print 'S ' }
printf "%.2f", abs($deglon);
print '<sup>o</sup>';
if   ( $deglon > 0 ) { print 'E' }
else                 { print 'W' }

if ( $units eq 'm' ) {

    #      printf "; %4d m elevation",$elev;	# 2028.96 -> 2028
    printf "; %4.0f m elevation", $elev;
}
else {
    printf "; %4d ft elevation", $elev * 3.28;
}
print "<br>$obsyrs years of record</h3>\n";
print '    <img src="/fswepp/images/line_red2.gif"><p>', "\n";

#-----------------------------------

#    $lathemisphere = "N";
#    $longhemisphere = "W";
#    if ($lat<0) {$lathemisphere = "S"}
#    if ($lon>0) {$longhemisphere = "E"}
$tempunit = '<sup>o</sup>F';
$pcpunit  = 'in';
if ( $units eq 'm' ) { $tempunit = '<sup>o</sup>C'; $pcpunit = 'mm' }

#    print abs($lat),"<sup>o</sup>$lathemisphere",
#          abs($lon),"<sup>o</sup>$longhemisphere<br>\n";
#    print '<center>';

print "
    <table border=1 bgcolor=white>
     <tr>
      <th bgcolor=85D2D2>Month</th>
      <th bgcolor=85D2D2>Observed<br>Mean<br>Maximum<br>Temperature<br>($tempunit)</th>
      <th bgcolor=85D2D2>Observed<br>Mean<br>Minimum<br>Temperature<br>($tempunit)</th>
      <th bgcolor=85D2D2>Observed<br>Mean<br>Precipitation<br>($pcpunit)</th>
      <th bgcolor=85D2D2>Observed<br>Mean<br>Solar Radiation<br>(langley/d)</th>
     </tr>
";
$annual_precip   = 0;
$annual_wet_days = 0;
for $i ( 0 .. 11 ) {
    if ( $units eq 'm' ) {
    }
    else {
        @obrain[$i] /= 25.4;                       # mm to inches
        @obmaxt[$i] = @obmaxt[$i] * 9 / 5 + 32;    # deg C to deg F
        @obmint[$i] = @obmint[$i] * 9 / 5 + 32;    # deg C to deg F
    }
    $annual_precip += @obrain[$i];
    print "     <tr><th bgcolor=85D2D2>$month_name[$i]</th>\n";
    printf "      <td align=right>%7.1f</td>\n", @obmaxt[$i];
    printf "      <td align=right>%7.1f</td>\n", @obmint[$i];
    printf "      <td align=right>%7.2f</td>\n", @obrain[$i];
    printf "      <td align=right>%7.1f</td>\n", @radave[$i];
    print "     </tr>\n";
}

print "     <tr><th bgcolor=85D2D2>Annual</th>\n";
print "      <td><br></td><td><br></td>\n";
printf "      <td align=right>%7.2f</td>\n", $annual_precip;
print "     </tr>\n";
print "    </table>\n    <br>\n";

#   ($itemp, $ibrkpt, $iwind) = split '=',$line;

print '    <font size=-1>';
if   ( $itemp eq '1' ) { print 'continuous' }
else                   { print 'single storm' }
;
print ' simulation; ';
if   ( $ibrkpt eq '0' ) { print ' no breakpoint data;' }
else                    { print ' breakpoint data;' }
if ( $iwind eq '0' ) { print ' no wind data&ndash;use Penman ET' }
else { print ' wind data&ndash;use Priestly-Taylor ET equation' }
print "</font><br><br>\n";

#-----------------------------------

#if ($climate_name eq "") {$climate_name = $CL}  # should remove path and .cli

print '
    <img src="/fswepp/images/line_red2.gif">
    <form>
    <input type="submit" value="Return to input screen" onClick="
     var referrer='$referrer';
     history.replaceState(null, '', referrer);
    window.location.href=referrer;">                            
    </form>
';

print "
   </center>
   <pre>
$comment
@comments
   </pre>
";

print "
  </center>
   <font size=-2>
    <hr>
    <b>desccli</b> version $version
    (a part of <b>Rock:Clime</b>)<br>
    USDA Forest Service Rocky Mountain Research Station<br>
    1221 South Main Street, Moscow, ID 83843
   </font>
  </font>
 </BODY>
</HTML>\n";
