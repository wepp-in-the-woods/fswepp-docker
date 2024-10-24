#!/usr/bin/perl

use warnings;
use CGI;
use CGI qw(escapeHTML);

use MoscowFSL::FSWEPP::FsWeppUtils qw(printdate get_user_id);

# createpar.pl

my $cgi = CGI->new;

my $user_ID = get_user_id();

$ftelev         = escapeHTML( $cgi->param('ftelev') );
$melev          = escapeHTML( $cgi->param('melev') );
$units          = escapeHTML( $cgi->param('units') );
$newlat         = escapeHTML( $cgi->param('latitude') );
$newlong        = escapeHTML( $cgi->param('longitude') );
$climateFile    = escapeHTML( $cgi->param('climateFile') );
$lathemisphere  = escapeHTML( $cgi->param('lathemisphere') );
$longhemisphere = escapeHTML( $cgi->param('longhemisphere') );

for $i ( 1 .. 12 ) {
    $mean_p[ $i - 1 ]  = escapeHTML( $cgi->param("pc$i") );
    $tmn[ $i - 1 ]     = escapeHTML( $cgi->param("tn$i") );
    $tmx[ $i - 1 ]     = escapeHTML( $cgi->param("tx$i") );
    $num_wet[ $i - 1 ] = escapeHTML( $cgi->param("nw$i") );
    $pww[ $i - 1 ]     = escapeHTML( $cgi->param("pww$i") );
    $pwd[ $i - 1 ]     = escapeHTML( $cgi->param("pwd$i") );
}

my $comefrom  = escapeHTML( $cgi->param('comefrom') );
my $newheader = escapeHTML( $cgi->param('newname') );

my @num_days = ( 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 );

my $working = '../working';    # DEH 07/19/00

my $startletter = 'f';
my $endletter   = 'z';

for my $letter ( $startletter .. $endletter ) {
    $nextletter = $letter;
    $outfile    = "$working/" . $user_ID . $letter . '.par';
    if ( !( -e $outfile ) ) { last }
}


if ( $lathemisphere eq "S" )  { $newlat  *= -1 }
if ( $longhemisphere eq "W" ) { $newlong *= -1 }
#
#    Return proper units
#
if ( $units eq 'm' ) {
    $new_elev = $melev * 3.28;
}
else {
    $new_elev = $ftelev;
}


open INPAR,  "<$climateFile";
open NEWPAR, ">$outfile";

#================
$station_line = <INPAR>;

# print "$station_line\n";				# DEH 2004.02.03
$old_station_name = substr( $station_line, 1, 40 );

# $new_station_name = '! ' . $old_station_name;
$new_station_name = $newheader . ' +';
$old_station_no   = substr( $station_line, 43, 6 );
chomp $old_station_no;

$lat_line    = <INPAR>;    # ' LATT=  68.87 LONG=-166.12 YEARS= 27. TYPE= 1';
$elev_line   = <INPAR>;    # ' ELEVATION =   50. TP5 =  .91 TP6= 1.28';
$mean_p_line = <INPAR>
  ; # ' MEAN P    .06   .05   .05   .06   .05   .10   .16   .18   .13   .08   .07   .05';
$sdp_line = <INPAR>
  ; # ' S DEV P   .08   .07   .05   .06   .13   .13   .24   .25   .17   .09   .12   .07';
$skp_line = <INPAR>
  ; # ' SKEW  P  3.61  4.12  1.99  3.12  9.85  2.69  2.68  2.92  2.20  2.70  4.78  3.93';
$pww_line = <INPAR>
  ; # ' P(W/W)    .49   .47   .40   .51   .47   .49   .56   .66   .68   .66   .57   .47';
$pwd_line = <INPAR>
  ; # ' P(W/D)    .14   .11   .11   .14   .13   .13   .21   .26   .23   .24   .19   .12';
$tmx_line = <INPAR>;
$tmn_line = <INPAR>;

$yrsstuff = substr( $lat_line,  27 );
$tpstuff  = substr( $elev_line, 19 );

#================
#    Need to convert mean p to mean p for a wet day and
#         number of wet days to P(W/W) and P(W/D)
#
for $i ( 0 .. 11 ) {
    if ( $units eq 'm' ) {
        $mean_p[$i] /= 25.4;                     # mm to in
        $tmx[$i] = $tmx[$i] * ( 9 / 5 ) + 32;    # deg C to F
        $tmn[$i] = $tmn[$i] * ( 9 / 5 ) + 32;    # deg C to F
    }

    # average rain/snow fall on a wet day
    if ( $num_wet[$i] == 0 ) { $mean_p[$i] = 0 }    # <<<<<<<<<<<<<<<<<<
    else                     { $mean_p[$i] /= $num_wet[$i] }
}
for $i ( 0 .. 11 ) {

    # probability of a wet day = num wet days / num days
    $pwet[$i] = $num_wet[$i] / $num_days[$i];

    # probability of a wet day following a wet day
    #   $pwetwet = 1 + $pwetdry * (1 - (1/$pwet))
    #   use this number if it is less than about 0.8 (else...?)
    #   "Instructions to modify a CLIGEN statistics file" Elliot 1998
    # where do we get P(W/D) ($pwetdry) ?
    # what if $pwet ~= 0?
}
$fmt_st = ' %-40.40s%2.2s%6.6s';
$fmt_ll = ' LATT=%7.2f LONG=%7.2f %18.18s';
$fmt_el = ' ELEVATION =%7.1f%20.20s';
$fmt_mp =
  ' MEAN P %6.2f%6.2f%6.2f%6.2f%6.2f%6.2f%6.2f%6.2f%6.2f%6.2f%6.2f%6.2f';
$fmt_pww =
  ' P(W/W) %6.2f%6.2f%6.2f%6.2f%6.2f%6.2f%6.2f%6.2f%6.2f%6.2f%6.2f%6.2f';
$fmt_pwd =
  ' P(W/D) %6.2f%6.2f%6.2f%6.2f%6.2f%6.2f%6.2f%6.2f%6.2f%6.2f%6.2f%6.2f';
$fmt_tmx =
  ' TMAX AV%6.2f%6.2f%6.2f%6.2f%6.2f%6.2f%6.2f%6.2f%6.2f%6.2f%6.2f%6.2f';
$fmt_tmn =
  ' TMIN AV%6.2f%6.2f%6.2f%6.2f%6.2f%6.2f%6.2f%6.2f%6.2f%6.2f%6.2f%6.2f';

printf NEWPAR $fmt_st, $new_station_name, '99', $old_station_no;
print NEWPAR "\n";
printf NEWPAR $fmt_ll, $newlat, $newlong, $yrsstuff;
print NEWPAR "\n";
printf NEWPAR $fmt_el, $new_elev, $tpstuff;
print NEWPAR "\n";
printf NEWPAR $fmt_mp, $mean_p[0], $mean_p[1], $mean_p[2], $mean_p[3],
  $mean_p[4], $mean_p[5], $mean_p[6], $mean_p[7], $mean_p[8], $mean_p[9],
  $mean_p[10], $mean_p[11];
print NEWPAR "\n";
print NEWPAR $sdp_line;
print NEWPAR $skp_line;
printf NEWPAR $fmt_pww, $pww[0], $pww[1], $pww[2], $pww[3], $pww[4], $pww[5],
  $pww[6], $pww[7], $pww[8], $pww[9], $pww[10], $pww[11];
print NEWPAR "\n";
printf NEWPAR $fmt_pwd, $pwd[0], $pwd[1], $pwd[2], $pwd[3], $pwd[4], $pwd[5],
  $pwd[6], $pwd[7], $pwd[8], $pwd[9], $pwd[10], $pwd[11];
print NEWPAR "\n";
printf NEWPAR $fmt_tmx, $tmx[0], $tmx[1], $tmx[2], $tmx[3], $tmx[4], $tmx[5],
  $tmx[6], $tmx[7], $tmx[8], $tmx[9], $tmx[10], $tmx[11];
print NEWPAR "\n";
printf NEWPAR $fmt_tmn, $tmn[0], $tmn[1], $tmn[2], $tmn[3], $tmn[4], $tmn[5],
  $tmn[6], $tmn[7], $tmn[8], $tmn[9], $tmn[10], $tmn[11];
print NEWPAR "\n";

while (<INPAR>) { print NEWPAR $_ }

print NEWPAR "\nModified by Rock:Clime on ";
&printdate;
print NEWPAR " from\n $station_line";

close INPAR;
close NEWPAR;

if ( $comefrom eq "" ) {
    exec "../rc/showpersonal.pl -download -u$units $comefrom $me";
}
else {
    exec "../rc/rockclim.pl -server -u$units $comefrom";
}
