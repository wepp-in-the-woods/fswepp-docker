#!/usr/bin/perl

use CGI;
use CGI qw(escapeHTML);

#
# manageclimates.pl
#

#  parameters:
#    'units'
#    'Climate'
#    'comefrom'
#    'me'
#    'manage'		/describe/ or /remove/ or /modify/  DEH 10/12/00
#  reads:
#  calls
#     exec "perl ../rc/descpar.pl $CL $units $iam"
#     exec "../rc/descpar.pl $CL $units $iam"
#     exec "perl ../rc/rockclim.pl -server -u$units $comefrom"
#     exec "../rc/rockclim.pl -server -u$units $comefrom"
##    exec "perl ../rc/modparsd2.pl $CL $units $comefrom $state"
#     exec "perl ../rc/modpar.pl $CL $units $comefrom $state"

#  FSWEPP, USDA Forest Service, Rocky Mountain Research Station, Soil & Water Engineering
#  Science by Bill Elliot et alia                                      Code by David Hall
#  19 October 1999
#  12 October 2000  --  need to add "modify" capability (does nothing now)
#			removed extraneous PRINT stuff for "remove"
#  17 September 2014 -- add exec to modpar again

my $cgi = CGI->new;
$units    = escapeHTML( $cgi->param('units') );
$climate  = escapeHTML( $cgi->param('Climate') );
$comefrom = escapeHTML( $cgi->param('comefrom') );
$dowhat   = escapeHTML( $cgi->param('manage') );

if ( $units ne 'm' && $units ne 'ft' ) { $units = 'm' }

##################

$CL  = $climate;
$iam = "/cgi-bin/fswepp/rc/manageclimates.pl";
if ( lc($dowhat) eq 'describe' ) {
    exec "../rc/descpar.pl $CL $units $iam";
}

##################

goto skipit;

print "Content-type: text/html\n\n";
print '<html>
<head>
<title>Rock:Clime</title>
</head>
<BODY bgcolor="white">
  <a href="/fswepp/">
  <IMG src="/fswepp/images/fsshield4.gif"
  align="left" alt="Back to FSWEPP menu" border=0></a>
  <CENTER>
  <H1>Rock:Clime</H1>
  <H2>USFS Rocky Mountain Research Station<BR> Climate Generator</H2>
  <br clear=all>
  <hr>
  <p>
';

skipit:
if ($debug) { print "manageclimates: $dowhat $climate" }

if ( lc($dowhat) eq 'remove' ) {
    $climatefile = $climate . '.par';
    unlink $climatefile;
}
else {
    exec "perl ../rc/modpar.pl $CL $units $comefrom $state";
}
exec "../rc/rockclim.pl -server -u$units $comefrom";

