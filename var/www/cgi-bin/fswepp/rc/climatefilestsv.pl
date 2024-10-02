#!/usr/bin/perl

use CGI;
use CGI qw(escapeHTML);

#  report custom climate files (names and user description)
#  determines caller's IP or ?ip=166.2.0.0
#  optionally reads personality as ?me=a

#  2010.10.06 David E. Hall USFS RMRS Moscow

#  to do: verify $me is '' or [a-zA-Z]

my $cgi = CGI->new;
$me = escapeHTML($cgi->param('me'));
$ip = escapeHTML($cgi->param('ip'));

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

$user_ID = $user_ID . $me;                    # DEH 03/05/2001
$custCli = '../working/' . $user_ID . '_';    # DEH 03/05/2001

print "Content-type: text/plain\n\n";
print "Personal Climate Lister\n\n";

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

print "$num_cli personal climates for $user_ID\n\n";
if ( $num_cli > 0 ) {
    for $ii ( 0 .. $num_cli - 1 ) {
        print $climate_file[$ii] . "\t" . $climate_name[$ii] . "\n";
    }
    print "\n";
}    
print '

  <!-- https://forest.moscowfsl.wsu.edu/cgi-bin/fswepp/rc/climatefilestsv.pl?ip=166.2.22.221&me=a -->
  <!-- ip is optional; me is optional: personality [a-zA-Z] -->
';
