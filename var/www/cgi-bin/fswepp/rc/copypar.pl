#!/usr/bin/perl

use warnings;
use CGI;
use CGI qw(escapeHTML);

# copypar.pl

#  FS WEPP, USDA Forest Service,
#  Rocky Mountain Research Station, Soil & Water Engineering
#  Science by Bill Elliot et alia         Code by David Hall
#  2009.08.24 DEH   Allow 'tahoe' climates
#  07/19/2000 DEH	fix for unix platform multiple personal files
#  03/03/2001 DEH	add '_' to $user_ID
#  19 October 1999

# place copy of user's newly-selected personal climate into the working
#   directory using a name based on the client IP address

#  parameters
#    'state'
#    'station'
#    'comefrom'
#    'submitbutton'	=~ /describe/    /modify/    /personal/
#    'me'
#    'units'
#  reads
#  calls
#   /describe/
#     exec "perl ../rc/descpar.pl $CL $units $iam"
#     exec "../rc/descpar.pl $CL $units $iam"
#   /modify/
#     exec "perl ../rc/modpar.pl $CL $units $state $comefrom"
#     exec "../rc/modpar.pl $CL $units $state $comefrom"
#   /personal/
#     `copy $climate_file $dest`;
#     exec "perl ../rc/rockclim.pl -server -u$units $comefrom"
#     `cp $climate_file $dest`;
#     exec "../rc/rockclim.pl -server $units $comefrom"

$version = '2014.10.06';

$cgi = CGI->new;
$state        = escapeHTML( $cgi->param('state') );
$station      = escapeHTML( $cgi->param('station') );
$comefrom     = escapeHTML( $cgi->param('comefrom') );
$submitbutton = lc( escapeHTML( $cgi->param('submitbutton') ) );
$units        = escapeHTML( $cgi->param('units') );
$me           = escapeHTML( $cgi->param('me') );

if ( $me ne "" ) {
    $me = substr( $me, 0, 1 );
    $me =~ tr/a-zA-Z/ /c;
}
if ( $me eq " " ) { $me = "" }

$user_ID     = $ENV{REMOTE_ADDR};
$user_really = $ENV{'HTTP_X_FORWARDED_FOR'};              # DEH 11/14/2002
$user_ID     = $user_really if ( $user_really ne '' );    # DEH 11/14/2002
$user_ID =~ tr/./_/;
$user_ID = $user_ID . $me . '_';                          # DEH 03/05/2001
if ( $user_ID eq "" ) { $user_ID = "custom" }

#  verify filename entry no .. ~ leading / etc.
#  verify state entry AL..WY or whatever
if ( $state eq "" )   { $state   = "id" }
if ( $station eq "" ) { $station = "id108080" }

# store valid states (plus) in array @states and
# construct a hash (Wall, Programming Perl, p. 537)
@states = (
    'al', 'az', 'ar', 'ca', 'co', 'ct', 'de', 'fl',
    'ga', 'id', 'il', 'in', 'ia', 'ks', 'ky', 'la',
    'me', 'md', 'ma', 'mi', 'mn', 'ms', 'mo', 'mt',
    'ne', 'nv', 'nh', 'nj', 'nm', 'ny', 'nc', 'nd',
    'oh', 'ok', 'or', 'pa', 'ri', 'sc', 'sd', 'tn',
    'tx', 'ut', 'vt', 'va', 'wa', 'wv', 'wi', 'wy',
    'dc', 'ak', 'hi', 'pr', 'pi', 'vi', 'if', 'nonus',
    'tahoe'
);
for (@states) { $states{$_}++; }

# $_ contains a keyword (state) if $states{$_} is non-zero.

###################################

if ( $states{$state} && $station =~ /^[\w.]*$/ ) {

    $working      = '../working';
    $climate_file = $state . '/' . $station . '.par';

    # open specified .par file, verify content, and close

    open CLIM, "<" . $climate_file;    # || die "can't open parameter file!";
    $title        = <CLIM>;
    $station_text = substr $title, 0, 40;
    close(CLIM);

####################################################################
    #
    #  MODIFY
    #
####################################################################

    if ( $submitbutton =~ /modify/ ) {

        $CL  = $state . "/" . $station;
        $iam = "/cgi-bin/fswepp/rc/copypar.pl";
        exec "../rc/modpar.pl $CL $units $comefrom $state";
    }

####################################################################
    #
    #  DESCRIBE
    #
####################################################################

    if ( $submitbutton =~ /describe/ ) {
        $CL  = $state . "/" . $station;
        $iam = "/cgi-bin/fswepp/rc/climate.cli";
        exec "../rc/descpar.pl $CL $units $iam";
    }

####################################################################
    #
    #  ADD TO PERSONAL CLIMATES
    #
####################################################################

    if ( $submitbutton =~ /personal/ ) {
        for $letter ( 'a' .. 'e' ) {
            $nextletter = $letter;
            $filename   = "$working/" . $user_ID . $letter . '.par';
            if ( !( -e $filename ) ) { last }
        }
        $dest = "$working/" . $user_ID . $nextletter . '.par';
        `cp $climate_file $dest`;
        exec "../rc/rockclim.pl -server -u$units $comefrom";
    }    # /personal/

    if ( $comefrom eq "" ) {
        print '<a href="JavaScript:window.history.go(-1)">';
    }
    else {
        print "<a href=$comefrom>";
    }
    print '<img src="/fswepp/images/retreat.gif"
       alt="Retreat" border="0" align=center></a>';
    print "<font size=-2>
copypar.pl version $version, (a part of Rock:Clim)<br>
U.S.D.A. Forest Service, Rocky Mountain Research Station
     </font>
";
    print "</body></html>\n";
}    # end state and station OK
