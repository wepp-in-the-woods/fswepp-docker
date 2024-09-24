#! /usr/bin/perl

use CGI qw(escapeHTML);

#  report custom climate files (names and user description)
#  determines caller's IP or ?ip=166.2.0.0
#  optionally reads personality as ?me=a

#  2010.10.06 David E. Hall USFS RMRS Moscow

#  to do: verify $me is '' or [a-zA-Z]

&ReadParse(*parameters);

$me = escapeHTML($parameters{'me'});
$ip = escapeHTML($parameters{'ip'});

if ( $ip ne '' ) {
    $user_ID = $ip;
    $user_ID =~ tr/./_/;
}
else {    # who am I?
    $user_ID        = $ENV{'REMOTE_ADDR'};
    $remote_address = $user_ID;                                 # DEH 02/19/2003
    $remote_host    = $ENV{'REMOTE_HOST'};                      # DEH 02/19/2003
    $user_really    = $ENV{'HTTP_X_FORWARDED_FOR'};             # DEH 11/14/2002
    $user_ID        = $user_really if ( $user_really ne '' );   # DEH 11/14/2002
    $user_ID =~ tr/./_/;
}

# $user_ID = '166_2_22_221';

$user_ID = $user_ID . $me;                    # DEH 03/05/2001
$custCli = '../working/' . $user_ID . '_';    # DEH 03/05/2001

#   $ipd = '166_2_22_221';                      # get from caller or argument list
#   $debug=1;

print "Content-type: text/html\n\n";
print '<html>
 <head>
  <title>Personal Climate Lister</title>
 </head>
 <BODY bgcolor="white" link="#1603F3" vlink="160A8C">
';

### get custom climates, if any ###

$num_cli   = 0;
@fileNames = glob( $custCli . '*.par' );


for $f (@fileNames) {
    if ($debug) { print "Opening $f<br>\n"; }
    open( M, "<$f" ) || die;    # cli file
    $station = <M>;
    close(M);
    $climate_file[$num_cli] = substr( $f, 0, length($f) - 4 );

    #      $clim_name = "*" . substr($station, index($station, ":")+2, 40);
    $clim_name = "*" . substr( $station, 0, 40 );
    $clim_name =~ s/^\s*(.*?)\s*$/$1/;
    $climate_name[$num_cli] = $clim_name;
    $num_cli += 1;
}

print "  <h3> $num_cli personal climates for $user_ID</h3>\n";
if ( $num_cli == 0 ) { print "No personal climates exist<p><hr>\n" }
else {
    print '
  <form method="post" action="../rc/manageclimates.pl">
   <SELECT NAME="Climate" SIZE="', $num_cli, '">
    ';
    for $ii ( 0 .. $num_cli - 1 ) {
        print '    <OPTION VALUE="';
        print $climate_file[$ii];
        print '"> ' . $climate_name[$ii] . "\n";
    }
    print '   </SELECT>
  </form>
 </body>
</html>
';
}    # if ($num_cli == 0)

#-------------------------------

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

