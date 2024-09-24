#!/usr/bin/perl

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
#    ../wepphost
#    ../platform
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

&ReadParse(*parameters);

$units    = escapeHTML( $parameters{'units'} );
$climate  = escapeHTML( $parameters{'Climate'} );
$comefrom = escapeHTML( $parameters{'comefrom'} );
$dowhat   = escapeHTML( $parameters{'manage'} );

if ( $units ne 'm' && $units ne 'ft' ) { $units = 'm' }

$wepphost = 'localhost';
if ( -e '../wepphost' ) {
    open Host, '<../wepphost';
    $wepphost = <Host>;
    chomp $wepphost;
    close Host;
}

$platform = 'pc';
if ( -e '../platform' ) {
    open Platform, '<../platform';
    $platform = lc(<Platform>);
    chomp $platform;
    close Platform;
}

##################

$CL  = $climate;
$iam = "/cgi-bin/fswepp/rc/manageclimates.pl";
if ( lc($dowhat) eq 'describe' ) {
    if ( $platform eq 'pc' ) {
        exec "perl ../rc/descpar.pl $CL $units $iam";
    }
    else {
        exec "../rc/descpar.pl $CL $units $iam";
    }
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


sub ReadParse {

    # ReadParse -- from cgi-lib.pl (Steve Brenner) from Eric Herrmann's
    # "Teach Yourself CGI Programming With PERL in a Week" p. 131

    # Reads GET or POST data, converts it to unescaped text, and puts
    # one key=value in each member of the list "@in"
    # Also creates key/value pairs in %in, using '\0' to separate multiple
    # selections

    # If a variable-glob parameter...

    local (*in) = @_ if @_;

    local ( $i, $loc, $key, $val );

    #   read text
    if ( $ENV{'REQUEST_METHOD'} eq "GET" ) {
        $in = $ENV{'QUERY_STRING'};
    }
    elsif ( $ENV{'REQUEST_METHOD'} eq "POST" ) {
        read( STDIN, $in, $ENV{'CONTENT_LENGTH'} );
    }

    @in = split( /&/, $in );

    foreach $i ( 0 .. $#in ) {

        # Convert pluses to spaces
        $in[$i] =~ s/\+/ /g;

        # Split into key and value
        ( $key, $val ) = split( /=/, $in[$i], 2 );    # splits on the first =

        # Convert %XX from hex numbers to alphanumeric
        $key =~ s/%(..)/pack("c",hex($1))/ge;
        $val =~ s/%(..)/pack("c",hex($1))/ge;

        # Associative key and value
        $in{$key} .= "\0"
          if ( defined( $in{$key} ) );    # \0 is the multiple separator
        $in{$key} .= $val;
    }
    return 1;
}

