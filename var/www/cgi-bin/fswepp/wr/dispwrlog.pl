#! /usr/bin/perl
#! /fsapps/fssys/bin/perl
#
# dispwrlog.pl
#
#  Display arbitrary WEPP:Road log
#
#  parameters
#      ip		# 'Add to log' or 'Create new log'

#  reads
#    $working\\{ip}.wrlog

#  FSWEPP, USDA Forest Service, Rocky Mountain Research Station, Soil & Water Engineering
#  Science by Bill Elliot et alia                                      Code by David Hall
#  19 October 1999

    &ReadParse(*parameters);

    $user_ID=$parameters{'ip'};

    $logFile = "../working/" . $user_ID . ".wrlog";

#	$units
#	$years
#	$climate
#	$soil
#	$rock
#	$surface $traffic
#	$design
#	$road_grad
#	$road_length
#	$road_width
#	$fill_grad
#	$fill_length
#	$buff_grad
#	$buff_length
#	$precip
#	$rro
#	$sro
#	$syr
#	$syp
#	$comment

    print "Content-type: text/html\n\n";
    print "<HTML>
 <HEAD>
  <TITLE>WEPP:Road log for $user_ID</TITLE>
 </HEAD>
 <BODY bgcolor='white'>
  <font face='Arial, Geneva, Helvetica'>
  <CENTER><H3>WEPP:Road log for $user_ID</H3></CENTER>
  <HR>
  <center>
";
    if (-e $logFile) {
      # now display it
      open LOG, "<" .$logFile;
      $logtime = <LOG>;
      ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =localtime($logtime);
      $thisday=(Sun,Mon,Tue,Wed,Thu,Fri,Sat) [$wday];

      $project=<LOG>;

      print "
  <center>
   <h4>$project</h4>
   <h4>$thisday"," ",
            (January,February,March,April,May,June,July,August,September,October,November,December) [$mon]," ",
            $mday,", ",1900+$year," ",$hour,":",$min,"</h4>\n";
  #    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($logtime);
      print "
    <table border=1>
     <tr>
      <th bgcolor='lightgreen'><font face='Arial, Geneva, Helvetica'>Yrs</font></th>
      <th bgcolor='lightgreen'><font face='Arial, Geneva, Helvetica'>Climate</font></th>
      <th bgcolor='lightgreen'><font face='Arial, Geneva, Helvetica'>Soil</font></th>
      <th bgcolor='lightgreen'><font face='Arial, Geneva, Helvetica'>Rock</font></th>
      <th bgcolor='lightgreen'><font face='Arial, Geneva, Helvetica'>Surface, traffic</font></th>
      <th bgcolor='lightgreen'><font face='Arial, Geneva, Helvetica'>Design</font></th>
      <th bgcolor='lightgreen'><font face='Arial, Geneva, Helvetica'>Road grad</font></th>
      <th bgcolor='lightgreen'><font face='Arial, Geneva, Helvetica'>Road len</font></th>
      <th bgcolor='lightgreen'><font face='Arial, Geneva, Helvetica'>Road width</font></th>
      <th bgcolor='lightgreen'><font face='Arial, Geneva, Helvetica'>Fill grad</font></th>
      <th bgcolor='lightgreen'><font face='Arial, Geneva, Helvetica'>Fill len</font></th>
      <th bgcolor='lightgreen'><font face='Arial, Geneva, Helvetica'>Buff grad</font></th>
      <th bgcolor='lightgreen'><font face='Arial, Geneva, Helvetica'>Buff len</font></th>
      <th bgcolor='lightgreen'><font face='Arial, Geneva, Helvetica'>Precip</font></th>
      <th bgcolor='lightgreen'><font face='Arial, Geneva, Helvetica'>Rain runoff</font></th>
      <th bgcolor='lightgreen'><font face='Arial, Geneva, Helvetica'>Snow runoff</font></th>
      <th bgcolor='lightgreen'><font face='Arial, Geneva, Helvetica'>Sed road</font></th>
      <th bgcolor='lightgreen'><font face='Arial, Geneva, Helvetica'>Sed profile</font></th>
      <th bgcolor='lightgreen'><font face='Arial, Geneva, Helvetica'>Comment</font></th>
     </tr>
";
      while (! eof LOG) {
        print "    <tr>";
        $units=<LOG>; chomp $units;
        if ($units eq "ft") {$lu = "ft"; $du = "in"; $vu = "lb"}
        else                {$lu = "m";  $du = "mm"; $vu = "kg"}
        $t=<LOG>; print "<td><font face='Arial, Geneva, Helvetica'>$t\n";		# Years
        $t=<LOG>; print "<td><font face='Arial, Geneva, Helvetica'>$t\n";		# Climate
        $t=<LOG>; print "<td><font face='Arial, Geneva, Helvetica'>$t\n";		# Soil type
        $t=<LOG>; print "<td><font face='Arial, Geneva, Helvetica'>$t %\n";		# Rock %
        $t=<LOG>; print "<td><font face='Arial, Geneva, Helvetica'>$t\n";		# Surface
        $t=<LOG>; print "<td><font face='Arial, Geneva, Helvetica'>$t\n";		# Road design
        $t=<LOG>; print "<td><font face='Arial, Geneva, Helvetica'>$t %\n";		# Road gradient
        $t=<LOG>; print "<td><font face='Arial, Geneva, Helvetica'>$t $lu\n";		# Road length
        $t=<LOG>; print "<td><font face='Arial, Geneva, Helvetica'>$t $lu\n";		# Road width
        $t=<LOG>; print "<td><font face='Arial, Geneva, Helvetica'>$t %\n";		# Fill gradient
        $t=<LOG>; print "<td><font face='Arial, Geneva, Helvetica'>$t $lu\n";		# Fill length
        $t=<LOG>; print "<td><font face='Arial, Geneva, Helvetica'>$t %\n";		# Buffer gradient
        $t=<LOG>; print "<td><font face='Arial, Geneva, Helvetica'>$t $lu\n";		# Buffer length
        $t=<LOG>; print "<td><font face='Arial, Geneva, Helvetica'>$t $du\n";		# Precipitation
        $t=<LOG>; print "<td><font face='Arial, Geneva, Helvetica'>$t $du\n";		# Rain runoff
        $t=<LOG>; print "<td><font face='Arial, Geneva, Helvetica'>$t $du\n";		# Snow runoff
        $t=<LOG>; print "<td><font face='Arial, Geneva, Helvetica'>$t $vu\n";		# Sediment yield from road
        $t=<LOG>; print "<td><font face='Arial, Geneva, Helvetica'>$t $vu\n";		# Sediment yield from profile
        $t=<LOG>; print "<td><font face='Arial, Geneva, Helvetica'>$t\n";		# User comment
      }
      close LOG;
      print "   </tr>\n";
      print "  </table>\n<br>\n<font size=-1>$logFile</font>\n</center>\n";
    }
    else {
      print "No log file found\n";
    }

    print " </body>\n</html>\n";

# ------------------------ subroutines ---------------------------

sub ReadParse {

# ReadParse -- from cgi-lib.pl (Steve Brenner) from Eric Herrmann's
# "Teach Yourself CGI Programming With PERL in a Week" p. 131

  local (*in) = @_ if @_;
  local ($i, $loc, $key, $val);

  if ($ENV{'REQUEST_METHOD'} eq "GET") {
    $in = $ENV{'QUERY_STRING'};
  } elsif ($ENV{'REQUEST_METHOD'} eq "POST") {
    read(STDIN,$in,$ENV{'CONTENT_LENGTH'});
  }

  @in = split(/&/,$in);

  foreach $i (0 .. $#in) {
    # Convert pluses to spaces
    $in[$i] =~ s/\+/ /g;

    # Split into key and value
    ($key, $val) = split(/=/,$in[$i],2);  # splits on the first =

    # Convert %XX from hex numbers to alphanumeric
    $key =~ s/%(..)/pack("c",hex($1))/ge;
    $val =~ s/%(..)/pack("c",hex($1))/ge;

    # Associative key and value
    $in{$key} .= "\0" if (defined($in{$key}));  # \0 is the multiple separator
    $in{$key} .= $val;
  }
  return 1;
 }
