#!/usr/bin/perl

use CGI qw(escapeHTML);

#  weblogger.pl			WEPP Batch ERMiT Logger
#  log Batch ERMiT runs (names and user description)
#  determines caller's IP

#  [IP]
#  [Time]
#  ?count=RunCount   	[number of hillslopes]
#  &version=version
#  &climate=climate	[or climate, or something]

#  2011.07.29 DEH switch order of version/count in log to match Disturbed WEPP batch order
#  2011.04.15 David E. Hall USFS RMRS Moscow

#  to do: verify

my $cgi = CGI->new;

$count   = escapeHTML($cgi->param('count'));
$version = escapeHTML($cgi->param('version'));
$climate = escapeHTML($cgi->param('climate'));

#   Determine caller's ID

$user_IP        = $ENV{'REMOTE_ADDR'};
$remote_address = $user_IP;
$remote_host    = $ENV{'REMOTE_HOST'};
$user_really    = $ENV{'HTTP_X_FORWARDED_FOR'};
$user_IP        = $user_really if ( $user_really ne '' );

#   $user_IP =~ tr/./_/;

#   $user_IP = '166.2.22.221';
#   $count = 5;
#   $location = 'Somewhere';

#  determine time

@months =
  qw(January February March April May June July August September October November December);
@days    = qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);
$ampm[0] = "am";
$ampm[1] = "pm";

$ampmi = 0;
( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime;
if ( $hour == 12 ) { $ampmi = 1 }
if ( $hour > 12 )  { $ampmi = 1; $hour = $hour - 12 }
$thisyear = $year + 1900;

#  record activity in Disturbed WEPP log (if running on remote server)

#    open WEBLOG, ">>../working/web.log";		# 2013.01.24 DEH
open WEBLOG, ">>../working/_$thisyear/web.log";
flock( WEBLOG, 2 );
print WEBLOG "$user_IP\t\"";
printf WEBLOG "%0.2d:%0.2d ", $hour, $min;
print WEBLOG $ampm[$ampmi], "  ", $days[$wday], " ", $months[$mon], " ", $mday,
  ", ", $thisyear, "\"\t";
print WEBLOG $count,   "\t";
print WEBLOG $version, "\t";

#      print WEBLOG '"',trim($location),"\"\n";
print WEBLOG '"', $climate, "\"\n";
close WEBLOG;

print "Content-type: text/plain\n\n";
print "Run logged for batch ERMiT:\n";
print "$user_IP\t\"";
printf "%0.2d:%0.2d ", $hour, $min;
print $ampm[$ampmi], "  ", $days[$wday], " ", $months[$mon], " ", $mday, ", ",
  $thisyear, "\"\t";
print $version, "\t";
print $count,   "\t";

#      print  '"',trim($location),"\"\n";
print '"', $climate, "\"\n";
