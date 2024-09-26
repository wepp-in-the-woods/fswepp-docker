#! /usr/bin/perl
use warnings;
use CGI;

#
#   Display Disturbed WEPP Batch run log (most recent first)
#

$lines = 200;

my $query = CGI->new;
my $lines = $query->param('lines') || 200;
my $year  = $query->param('year')  || 2014;

# Escape HTML to prevent XSS attacks
$lines = CGI::escapeHTML($lines);
$year  = CGI::escapeHTML($year);

$year = $parameters{'year'};
$year = int( $year + 0 );
$year = 2014 if ( $year == 0 );

@results = `tail -$lines working/_$year/dwb.log`;
@results = reverse(@results);
$wc      = `wc working/_$year/dwb.log`;
@words   = split " ", $wc;
$runs    = @words[0];

$lines = $runs if ( $lines > $runs );

print "Content-type: text/html\n\n";
print "<HTML>
 <HEAD>
  <TITLE>Disturbed WEPP Batch run log</TITLE>
 </head>
 <body onLoad='self.focus()'>
  <font face='tahoma, arial, sans serif'>
   <h3>$lines most recent of $runs Disturbed WEPP Batch runs</h3>
   <pre>
   [IP]   [\"Date\"]   [# runs]   [Batch version]   [\"Location\"]

 @results
   </pre>
   <br><br>
    <a href=\"wrtailer.pl\"><img src=\"/fswepp/images/road4.gif\" alt=\"WEPP:Road run log\"></a>
    <a href=\"wrbtailer.pl\"><img src=\"/fswepp/images/roadb_r.gif\" alt=\"WEPP:Road batch run log\"></a>
    <a href=\"wdtailer.pl\"><img src=\"/fswepp/images/disturb.gif\" alt=\"Disturbed WEPP run log\"></a>
    <a href=\"wetailer.pl\"><img src=\"/fswepp/images/ermit.gif\" alt=\"ERMiT run log\"></a>
  </font>
 </body>
</html>
";
