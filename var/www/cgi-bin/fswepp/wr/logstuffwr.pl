#!/usr/bin/perl

use warnings;
use CGI;
use CGI qw(escapeHTML);

use MoscowFSL::FSWEPP::FsWeppUtils qw( get_user_id );

#
# logstuffwr.pl
#

my $user_ID = get_user_id();

$cgi     = CGI->new;
$button  = escapeHTML( $cgi->param('button') );
$project = escapeHTML( $cgi->param('projectdescription') );
if ( $button eq "Add to log" ) {
    $climate     = escapeHTML( $cgi->param('climate') );
    $soil        = escapeHTML( $cgi->param('soil') );
    $rock        = escapeHTML( $cgi->param('rock') );
    $surface     = escapeHTML( $cgi->param('surface') );
    $traffic     = escapeHTML( $cgi->param('traffic') );
    $design      = escapeHTML( $cgi->param('design') );
    $years       = escapeHTML( $cgi->param('years') );
    $road_grad   = escapeHTML( $cgi->param('road_grad') );
    $road_length = escapeHTML( $cgi->param('road_length') );
    $road_width  = escapeHTML( $cgi->param('road_width') );
    $fill_grad   = escapeHTML( $cgi->param('fill_grad') );
    $fill_length = escapeHTML( $cgi->param('fill_length') );
    $buff_grad   = escapeHTML( $cgi->param('buff_grad') );
    $buff_length = escapeHTML( $cgi->param('buff_length') );
    $precip      = escapeHTML( $cgi->param('precip') );
    $rro         = escapeHTML( $cgi->param('rro') );
    $sro         = escapeHTML( $cgi->param('sro') );
    $syr         = escapeHTML( $cgi->param('syr') );
    $syp         = escapeHTML( $cgi->param('syp') );
    $comment     = escapeHTML( $cgi->param('rundescription') );
    $units       = escapeHTML( $cgi->param('units') );
}

$logFile = "../working/" . $user_ID . ".wrlog";

$host = $ENV{REMOTE_HOST};

if ( $button eq 'Create new log'
    || ( $button eq 'Add to log' && ( !-e $logFile ) ) )
{
    open LOG, ">" . $logFile;
    print LOG time, "\n";
    print LOG $project, "\n";
    close LOG;
}
if ( $button eq "Add to log" ) {
    open LOG, ">>" . $logFile;
    print LOG "$units
$years
$climate
$soil
$rock
$surface $traffic
$design
$road_grad
$road_length
$road_width
$fill_grad
$fill_length
$buff_grad
$buff_length
$precip
$rro
$sro
$syr
$syp
$comment
";
    close LOG;
}

print "Content-type: text/html\n\n";
print '<HTML>
 <HEAD>
  <TITLE>WEPP:Road log</TITLE>
 </HEAD>
 <BODY bgcolor="white">
  <font face="Arial, Geneva, Helvetica">
  <CENTER><H1>WEPP:Road log</H1></CENTER>
  <CENTER><H3><em><font color="red">*This Log File will be deleted on some unpredetermined date.*</font></em></H3></CENTER>
  <HR>
  <center>
';
if ( -e $logFile ) {

    # now display it
    open LOG, "<" . $logFile;
    $logtime = <LOG>;
    ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
      localtime($logtime);
    $thisday = ( Sun, Mon, Tue, Wed, Thu, Fri, Sat )[$wday];

    $project = <LOG>;

    print "
  <center>
   <h2>$project</h2>
   <h2>$thisday", " ",
      ( January, February, March, April, May, June,
        July, August, September, October, November, December
      )[$mon], " ",
      $mday, ", ", 1900 + $year, " ", $hour, ":", $min, "</h2>\n";

#    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($logtime);
    print "
    <table border=1>
     <tr>
      <th><font face='Arial, Geneva, Helvetica'>Yrs</font></th>
      <th><font face='Arial, Geneva, Helvetica'>Climate</font></th>
      <th><font face='Arial, Geneva, Helvetica'>Soil</font></th>
      <th><font face='Arial, Geneva, Helvetica'>Rock</font></th>
      <th><font face='Arial, Geneva, Helvetica'>Surface, traffic</font></th>
      <th><font face='Arial, Geneva, Helvetica'>Design</font></th>
      <th><font face='Arial, Geneva, Helvetica'>Road grad</font></th>
      <th><font face='Arial, Geneva, Helvetica'>Road len</font></th>
      <th><font face='Arial, Geneva, Helvetica'>Road width</font></th>
      <th><font face='Arial, Geneva, Helvetica'>Fill grad</font></th>
      <th><font face='Arial, Geneva, Helvetica'>Fill len</font></th>
      <th><font face='Arial, Geneva, Helvetica'>Buff grad</font></th>
      <th><font face='Arial, Geneva, Helvetica'>Buff len</font></th>
      <th><font face='Arial, Geneva, Helvetica'>Precip</font></th>
      <th><font face='Arial, Geneva, Helvetica'>Rain runoff</font></th>
      <th><font face='Arial, Geneva, Helvetica'>Snow runoff</font></th>
      <th><font face='Arial, Geneva, Helvetica'>Sed road</font></th>
      <th><font face='Arial, Geneva, Helvetica'>Sed profile</font></th>
      <th><font face='Arial, Geneva, Helvetica'>Comment</font></th>
     </tr>
";
    while ( !eof LOG ) {
        print "    <tr>";
        $units = <LOG>;
        chomp $units;
        if   ( $units eq "ft" ) { $lu = "ft"; $du = "in"; $vu = "lb" }
        else                    { $lu = "m";  $du = "mm"; $vu = "kg" }
        $t = <LOG>;
        print "<td><font face='Arial, Geneva, Helvetica'>$t\n";      # Years
        $t = <LOG>;
        print "<td><font face='Arial, Geneva, Helvetica'>$t\n";      # Climate
        $t = <LOG>;
        print "<td><font face='Arial, Geneva, Helvetica'>$t\n";      # Soil type
        $t = <LOG>;
        print "<td><font face='Arial, Geneva, Helvetica'>$t %\n";    # Rock %
        $t = <LOG>;
        print "<td><font face='Arial, Geneva, Helvetica'>$t\n";      # Surface
        $t = <LOG>;
        print "<td><font face='Arial, Geneva, Helvetica'>$t\n";    # Road design
        $t = <LOG>;
        print
          "<td><font face='Arial, Geneva, Helvetica'>$t %\n";    # Road gradient
        $t = <LOG>;
        print
          "<td><font face='Arial, Geneva, Helvetica'>$t $lu\n";    # Road length
        $t = <LOG>;
        print "<td><font face='Arial, Geneva, Helvetica'>$t $lu\n"; # Road width
        $t = <LOG>;
        print
          "<td><font face='Arial, Geneva, Helvetica'>$t %\n";    # Fill gradient
        $t = <LOG>;
        print
          "<td><font face='Arial, Geneva, Helvetica'>$t $lu\n";    # Fill length
        $t = <LOG>;
        print
          "<td><font face='Arial, Geneva, Helvetica'>$t %\n";  # Buffer gradient
        $t = <LOG>;
        print
          "<td><font face='Arial, Geneva, Helvetica'>$t $lu\n";  # Buffer length
        $t = <LOG>;
        print
          "<td><font face='Arial, Geneva, Helvetica'>$t $du\n";  # Precipitation
        $t = <LOG>;
        print
          "<td><font face='Arial, Geneva, Helvetica'>$t $du\n";    # Rain runoff
        $t = <LOG>;
        print
          "<td><font face='Arial, Geneva, Helvetica'>$t $du\n";    # Snow runoff
        $t = <LOG>;
        print "<td><font face='Arial, Geneva, Helvetica'>$t $vu\n"
          ;    # Sediment yield from road
        $t = <LOG>;
        print "<td><font face='Arial, Geneva, Helvetica'>$t $vu\n"
          ;    # Sediment yield from profile
        $t = <LOG>;
        print "<td><font face='Arial, Geneva, Helvetica'>$t\n";   # User comment
    }
    close LOG;
    print "   </tr>\n";
    print "  </table>\n<br>\n<font size=-1>$logFile</font>\n</center>\n";
}
else {
    print "No log file found\n";
}

print " </body>\n</html>\n";

