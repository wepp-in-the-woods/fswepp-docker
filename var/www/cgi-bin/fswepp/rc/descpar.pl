#!/usr/bin/perl

use warnings;
use CGI;
use CGI qw(escapeHTML);
use MoscowFSL::FSWEPP::FsWeppUtils qw(get_version);

#
# descpar.pl
#

my @debug    = 0;
my $version  = get_version(__FILE__);
my $query    = CGI->new;
my $referrer = $ENV{'HTTP_REFERER'};
if ( !$referrer ) {
    $referrer = '/fswepp/';
}

my $CL = $query->param('CL') || $ARGV[0];
chomp $CL;

my $units = $query->param('units') || $ARGV[1];
$units = 'm' if ( $units eq '-um' );

my $climateFile = $CL . '.par';

open PAR, "<$climateFile";
$line         = <PAR>;    # EPHRATA CAA AP WA                       452614 0
$climate_name = substr( $line, 1, 32 );

$line = <PAR>;            # LATT=  47.30 LONG=-119.53 YEARS= 44. TYPE= 3
( $lattext, $lat, $lon, $yr_rec, $type ) = split '=', $line;
$line = <PAR>;            # ELEVATION = 1260. TP5 = 0.86 TP6= 2.90
( $this, $that ) = split '=', $line;
$elev = $that + 0;
$line = <PAR>
  ; # MEAN P   0.10  0.10  0.11  0.10  0.11  0.14  0.14  0.09  0.10  0.10  0.12  0.12
@mean_p_if   = split ' ', $line;
$mean_p_base = 2;
$line        = <PAR>
  ; # S DEV P  0.12  0.12  0.11  0.13  0.13  0.18  0.22  0.13  0.13  0.11  0.14  0.13
$line = <PAR>
  ; # SQEW  P  1.88  2.30  2.21  2.15  2.29  2.35  3.60  3.22  2.05  2.49  2.22  1.87
$line = <PAR>
  ; # P(W/W)   0.47  0.50  0.39  0.32  0.33  0.30  0.27  0.28  0.40  0.41  0.42  0.48
@pww      = split ' ', $line;
$pww_base = 1;
$line     = <PAR>
  ; # P(W/D)   0.20  0.16  0.15  0.13  0.13  0.11  0.05  0.06  0.08  0.12  0.23  0.23
@pwd      = split ' ', $line;
$pwd_base = 1;
$line     = <PAR>
  ; # TMAX AV 32.89 41.62 52.60 62.81 72.56 80.58 88.52 87.06 77.76 62.85 44.78 34.63

for $ii ( 0 .. 11 ) { $tmax_av[$ii] = substr( $line, 8 + $ii * 6, 6 ) }
$tmax_av_base = 0;
$line         = <PAR>
  ; # TMIN AV 20.31 26.55 32.33 39.12 47.69 55.39 61.58 60.31 51.52 40.17 30.33 22.81
for $ii ( 0 .. 11 ) { $tmin_av[$ii] = substr( $line, 8 + $ii * 6, 6 ) }
$tmin_av_base = 0;

while (<PAR>) {

    #     print;
    #     $/="\n"; chomp;     # some lines have 0d0d0a so remove all CR LF
    #     $/="\r"; chomp;
    #     $/="\n";
    #     tr/ //;
    #     if (/^$/) {last};		# look for blank line -- not working...?
    last if (/CALM/);
}

$_ = <PAR>;
$_ = <PAR>;

if ( /INTERPOLATED DATA/ || /TRIANGULATED DATA/ ) {
    $interpolated = 1;
    while (<PAR>) {
        if (/Wind Stations/) {
            $line = <PAR>
              ; # IDAHO FALLS   ID     .339  IDAHO FALLS   ID .339  DILLON        MT     .322
            $ws1  = substr( $line, 0,  20 );
            $wwt1 = substr( $line, 20, 5 );
            $ws2  = substr( $line, 27, 20 );
            $wwt2 = substr( $line, 47, 5 );
            $ws3  = substr( $line, 54, 20 );
            $wwt3 = substr( $line, 74, 5 );
        }
        if (/Solar Radiat/) {
            $line = <PAR>
              ; #  BILLINGS, MONTANA   .390   POCATELLO, IDAHO .307   HELENA, MONTANA     .303
            $ss1  = substr( $line, 0,  20 );
            $swt1 = substr( $line, 20, 5 );
            $ss2  = substr( $line, 27, 20 );
            $swt2 = substr( $line, 47, 5 );
            $ss3  = substr( $line, 54, 20 );
            $swt3 = substr( $line, 74, 5 );
        }
        if (/Dewpoint/) {
            $line = <PAR>
              ; # MT BILLINGS          .366  MT BUTTE .325  WY LANDER            .309
            $dwt1 = substr( $line, 20, 5 );
            $dwt2 = substr( $line, 47, 5 );
            $dwt3 = substr( $line, 74, 5 );
            $dst  = substr( $line, 0,  2 );
            $dsc  = substr( $line, 3,  18 );
            $ds1  = $dsc . ' ' . $dst;
            $dst  = substr( $line, 27, 2 );
            $dsc  = substr( $line, 30, 18 );
            $ds2  = $dsc . ' ' . $dst;
            $dst  = substr( $line, 54, 2 );
            $dsc  = substr( $line, 57, 18 );
            $ds3  = $dsc . ' ' . $dst;
        }
        if (/Time Peak/) {
            $line = <PAR>
              ; # LAKE YELLOWSTONE WY 1.000  COOKE CITY 2 W MT .000  CAMERON MT           .000
            $ts1  = substr( $line, 0,  20 );
            $twt1 = substr( $line, 20, 5 );
            $ts2  = substr( $line, 27, 20 );
            $twt2 = substr( $line, 47, 5 );
            $ts3  = substr( $line, 54, 20 );
            $twt3 = substr( $line, 74, 5 );
        }
        if (/Modified by/) {
            $modhead = $_;
            $modfile = <PAR>;
        }
    }    # while (<PAR>)
}    # if (/INTERPOLATED DATA/) {
else {    # if (/INTERPOLATED DATA/) {
    $comment  = $_;
    @comments = <PAR>;
}
close PAR;

@month_name =
  qw(January February March April May June July August September October November December);
@month_days = ( 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 );

$lat += 0;
$lon += 0;

##########################
$climate_name_filt = $climate_name;
$climate_name_filt =~ s/'/`/;
print "Content-type: text/html\n\n";
print "<HTML>\n";
print " <HEAD>\n";
print "  <TITLE>Climate Parameters</TITLE>\n";
print "  <script language=Javascript>

   function ShowPar() {
    newin = window.open('','par',',scrollbars=yes,resizable=yes,height=600,width=900,status=yes')                       
    newin.document.open()
    newin.document.writeln('<html><body onload=\"self.focus()\"><pre>')
";
open PAR, "<$climateFile";

while (<PAR>) {
    tr/'/`/;

    #    s/'/ /;
    $/ = "\n";
    chomp;    # some lines have 0d0d0a so remove all CR LF
    $/ = "\r";
    chomp;
    $/ = "\n";
    print "    newin.document.writeln('$_')\n";
}
close PAR;
print "
    newin.document.close()
   }
  </script>
";
print " </HEAD>\n";
print ' <body bgcolor=white link="#1603F3" vlink="#160A8C">
  <font face="Arial, Geneva, Helvetica">', "\n";
print "   <center>
    <h2>Climate parameters for $climate_name</h2>\n";

if ($debug) { print "climate: '$CL' ; units: '$units'<br>\n" }
##########################

$yr_rec += 0;
print '    <h3>';
printf "%.2f", abs($lat);
print '<sup>o</sup>';
if   ( $lat > 0 ) { print 'N ' }
else              { print 'S ' }
printf "%.2f", abs($lon);
print '<sup>o</sup>';
if   ( $lon > 0 ) { print 'E' }
else              { print 'W' }

if ( $units eq 'm' ) {
    printf "; %4d m elevation", $elev / 3.28;
}
else {
    print "; $elev feet elevation";
}
print "<br>$yr_rec years of record</h3>\n";
print '    <img src="/fswepp/images/line_red2.gif"><p>', "\n";

$tempunit = '<sup>o</sup>F';
$pcpunit  = 'in';
if ( $units eq 'm' ) { $tempunit = '<sup>o</sup>C'; $pcpunit = 'mm' }

for $i ( 1 .. 12 ) {
    $pw[$i] = $pwd[$i] / ( 1 + $pwd[$i] - $pww[$i] );
}

print "
    <table border=1 bgcolor=white>
     <tr>
      <th bgcolor=85D2D2>Month</th>
      <th bgcolor=85D2D2>Mean<br>Maximum<br>Temperature<br>($tempunit)</th>
      <th bgcolor=85D2D2>Mean<br>Minimum<br>Temperature<br>($tempunit)</th>
      <th bgcolor=85D2D2>Mean<br>Precipitation<br>($pcpunit)</th>
      <th bgcolor=85D2D2>Number<br>of wet days</th>
     </tr>
";
$annual_precip   = 0;
$annual_wet_days = 0;
for $i ( 0 .. 11 ) {
    $tmax    = $tmax_av[ $i + $tmax_av_base ];
    $tmin    = $tmin_av[ $i + $tmin_av_base ];
    $num_wet = $pw[ $i + $pww_base ] * $month_days[$i];
    $mean_p  = $num_wet * $mean_p_if[ $i + $mean_p_base ];
    if ( $units eq 'm' ) {
        $mean_p *= 25.4;                   # inches to mm
        $tmax = ( $tmax - 32 ) * 5 / 9;    # deg F to deg C
        $tmin = ( $tmin - 32 ) * 5 / 9;    # deg F to deg C
    }
    $annual_precip   += $mean_p;
    $annual_wet_days += $num_wet;
    print "     <tr><th bgcolor=85D2D2>$month_name[$i]</th>\n";
    printf "      <td align=right>%7.1f</td>\n", $tmax;
    printf "      <td align=right>%7.1f</td>\n", $tmin;
    printf "      <td align=right>%7.2f</td>\n", $mean_p;
    printf "      <td align=right>%7.1f</td>\n", $num_wet;
    print "     </tr>\n";
}
print "     <tr><th bgcolor=85D2D2>Annual</th>\n";
print "      <td><br></td><td><br></td>\n";
printf "      <td align=right>%7.2f</td>\n", $annual_precip;
printf "      <td align=right>%7.1f</td>\n", $annual_wet_days;
print "     </tr>\n";
print "    </table>\n    <br><br>\n";

# **********************

print qq(
    <img src="/fswepp/images/line_red2.gif">
    <form>
     <input type="submit" value="Show PAR" onClick="ShowPar(); return false;">
     <input type="submit" value="Return to input screen" onClick="
     var referrer='$referrer';
     history.replaceState(null, '', referrer);
    window.location.href=referrer;">                            
    </form>
);

if ($interpolated) {
    print '
    <h4>INTERPOLATED DATA</h4>

    <table border=1 bgcolor=85d2d2>
     <tr>
      <th><font size=-1>Station</th>
      <th><font size=-1>Weighting</th>
      <th><font size=-1>Station</th>
      <th><font size=-1>Weighting</th>
     <tr>
      <td bgcolor=white colspan=2><font size=-1><b>Wind Stations</b></td>
      <td bgcolor=white colspan=2><font size=-1><b>Solar Radiation and Max .5 P Stations</b></td>
     </tr>
     <tr>
      <td>&nbsp;&nbsp;&nbsp;<font size=-1>', $ws1, '</td>
      <td align=right><font size=-1> ',      $wwt1 * 100, ' %&nbsp;&nbsp;</td>
      <td>&nbsp;&nbsp;&nbsp;<font size=-1>', $ss1, '</td>
      <td align=right><font size=-1>',       $swt1 * 100, ' %&nbsp;&nbsp;</td>
     </tr>
     <tr>
      <td>&nbsp;&nbsp;&nbsp;<font size=-1>', $ws2, '</td>
      <td align=right><font size=-1> ',      $wwt2 * 100, ' %&nbsp;&nbsp;</td>
      <td>&nbsp;&nbsp;&nbsp;<font size=-1>', $ss2, '</td>
      <td align=right><font size=-1> ',      $swt2 * 100, ' %&nbsp;&nbsp;</td>
     </tr>
     <tr>
      <td>&nbsp;&nbsp;&nbsp;<font size=-1>', $ws3, '</td>
      <td align=right><font size=-1> ',      $wwt3 * 100, ' %&nbsp;&nbsp;</td>
      <td>&nbsp;&nbsp;&nbsp;<font size=-1>', $ss3, '</td>
      <td align=right><font size=-1> ',      $swt3 * 100, ' %&nbsp;&nbsp;</td>
     </tr>
     <tr>
      <td bgcolor=white colspan=2><font size=-1><b>Dewpoint Stations</b></td>
      <td bgcolor=white colspan=2><font size=-1><b>Time-to-Peak Stations</b></td>
     </tr>
     <tr>
      <td>&nbsp;&nbsp;&nbsp;<font size=-1>', $ds1, '</td>
      <td align=right><font size=-1> ',      $dwt1 * 100, ' %&nbsp;&nbsp;</td>
      <td>&nbsp;&nbsp;&nbsp;<font size=-1>', $ts1, '</td>
      <td align=right><font size=-1> ',      $twt1 * 100, ' %&nbsp;&nbsp;</td>
     </tr>
     <tr>
      <td>&nbsp;&nbsp;&nbsp;<font size=-1>', $ds2, '</td>
      <td align=right><font size=-1> ',      $dwt2 * 100, ' %&nbsp;&nbsp;</td>
      <td>&nbsp;&nbsp;&nbsp;<font size=-1>', $ts2, '</td>
      <td align=right><font size=-1> ',      $twt2 * 100, ' %&nbsp;&nbsp;</td>
     </tr>
     <tr>
      <td>&nbsp;&nbsp;&nbsp;<font size=-1>', $ds3, '</td>
      <td align=right><font size=-1> ',      $dwt3 * 100, ' %&nbsp;&nbsp;</td>
      <td>&nbsp;&nbsp;&nbsp;<font size=-1>', $ts3, '</td>
      <td align=right><font size=-1> ',      $twt3 * 100, ' %&nbsp;&nbsp;</td>
     </tr>
    </table>
    <br><br>
    <font size=-1>
     ', $modhead, ' ', $modfile, '
    </font>
   </center>
';
}    # if ($interpolated)
else {
    # ************************************ not INTERPOLATED *******************
    print "
   </center>
   <pre>
$comment
@comments
   </pre>
";
}

print "
  </center>
   <font size=-2>
    <hr>
    <b>descpar</b> version $version
    (a part of <b>Rock:Clime</b>)<br>
    USDA Forest Service Rocky Mountain Research Station<br>
    1221 South Main Street, Moscow, ID 83843
   </font>
  </font>
 </BODY>
</HTML>\n";

