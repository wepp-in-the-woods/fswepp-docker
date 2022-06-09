#! /fsapps/fssys/bin/perl
#
# logstuff.pl
#
# take form data from wr.pl and add it to WEPP:Road log
#
#  11/14/2002 Use HTTP_X_FORWARDED_FOR as user ID
#
#  usage: 
#    <form name="wrlog" method="post" action="http://host/cgi-bin/fswepp/wr/logstuff.pl">
#  parameters
#    all:
#      button			# 'Add to log' or 'Create new log'
#      projectdescription	# project description
#    for "Add to log"
#      climate			# climate
#      soil			# soil type
#      surface			# road surface
#      design			# road design
#      years			# years
#      road_grad		# road gradient
#      road_length		# road length
#      road_width		# road width
#      fill_grad		# fill gradient
#      fill_length		# fill length
#      buff_grad		# buffer gradient
#      buff_length		# buffer length
#      precip			# precip amount
#      rro			# rain run off
#      sro			# snow run off
#      syr			# sediment yield from road
#      syp			# sediment yield from prism
#      rundescription		# comments for run
#      units			# units for run ("m" or "ft")
#      me
#  reads environment variables:
#       HTTP_COOKIE
#       REMOTE_ADDR
#       HTTP_X_FORWARDED_FOR
#       REQUEST_METHOD
#       QUERY_STRING
#       CONTENT_LENGTH
#  reads:
#    ../platform
#  writes
#    $working\\wrwepp.log
#  creates
#    $working\\wrwepp.log	# for "Create" or ("Add"  if non-existent)

#  FSWEPP, USDA Forest Service, Rocky Mountain Research Station, Soil & Water Engineering
#  Science by Bill Elliot et alia                                      Code by David Hall
#  19 October 1999

    &ReadParse(*parameters);

    $button=$parameters{'button'};
    $project=$parameters{'projectdescription'};
    if ($button eq "Add to log") {
      $climate=$parameters{'climate'};
      $soil=$parameters{'soil'};
      $surface=$parameters{'surface'};
      $design=$parameters{'design'};
      $years=$parameters{'years'};
      $road_grad=$parameters{'road_grad'};
      $road_length=$parameters{'road_length'};
      $road_width=$parameters{'road_width'};
      $fill_grad=$parameters{'fill_grad'};
      $fill_length=$parameters{'fill_length'};
      $buff_grad=$parameters{'buff_grad'};
      $buff_length=$parameters{'buff_length'};
      $precip=$parameters{'precip'};
      $rro=$parameters{'rro'};
      $sro=$parameters{'sro'};
      $syr=$parameters{'syr'};
      $syp=$parameters{'syp'};
      $comment=$parameters{'rundescription'};
      $units=$parameters{'units'};
#      $me=$parameters{'me'};
    }

    $cookie = $ENV{'HTTP_COOKIE'};
    $sep = index ($cookie,"=");
    $me = "";
    if ($sep > -1) {$me = substr($cookie,$sep+1,1)}

    if ($me ne "") {
       $me = lc(substr($me,0,1));
       $me =~ tr/a-z/ /c;
    }
    if ($me eq " ") {$me = ""}

    $platform="pc";
    if (-e "../platform") {
      open Platform, "<../platform";
      $platform=lc(<Platform>);
      chomp $platform;
      close Platform;
    }

    if ($platform eq "pc") {
      if (-e 'd:/fswepp/working') {$logFile = 'd:\\fswepp\\working\\wrwepp.log'}
      elsif (-e 'c:/fswepp/working') {$logFile = 'c:\\fswepp\\working\\wrwepp.log'}
      else {$logFile = '..\\working\\wrwepp.log'}
 #    $logFile = "..\\working\\wrwepp.log";
    }
    else {
      $user_ID=$ENV{'REMOTE_ADDR'};
      $user_really=$ENV{'HTTP_X_FORWARDED_FOR'};          # DEH 11/14/2002 
      $user_ID=$user_really if ($user_really ne '');      # DEH 11/14/2002 
      $user_ID =~ tr/./_/;
      $user_ID = $user_ID . $me;
      $logFile = "../working/" . $user_ID . ".log";
    }

#    $host = $ENV{REMOTE_HOST};

    if ($button eq 'Create new log' || ($button eq 'Add to log' && (! -e $logFile))) {
       open LOG, ">" . $logFile;
       print LOG time,"\n";
       print LOG $project,"\n";
       close LOG;
    }
    if ($button eq "Add to log") {
      open LOG, ">>" . $logFile;
      print LOG "$units
$years
$climate
$soil
$surface
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
<HR>
<center>
';
    if (-e $logFile) {
      # now display it
      open LOG, "<" .$logFile;
      $logtime = <LOG>;
      ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($logtime);
      $thisday=(Sun,Mon,Tue,Wed,Thu,Fri,Sat) [$wday];

      $project=<LOG>;

      print "<center>\n";
      print "<h2>$project</h2>\n";
      print "<h2>$thisday"," ",
            (January,February,March,April,May,June,July,August,September,October,November,December) [$mon]," ",
            $mday,", ",1900+$year," ",$hour,":",$min,"</h2>\n";         
  #    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($logtime);
      print "<table border=1>\n";
      print "<tr>\n";
      print "<th>Yrs
             <th>Climate
             <th>Soil
             <th>Surface
             <th>Design
             <th>Road grad<br>
             <th>Road len<br>
             <th>Road width<br>
             <th>Fill grad<br>
             <th>Fill len<br>
             <th>Buff grad<br>
             <th>Buff len<br>
             <th>Precip<br>
             <th>RRO<br>
             <th>SRO<br>
             <th>Sed Road<br>
             <th>Sed Profile<br>
             <th>Comment</tr>\n";
      while (! eof LOG) {
        print "<tr>";
        $units=<LOG>; chomp $units;
        if ($units eq "ft") {$lu = "ft"; $du = "in"; $vu = "lb"}
        else                {$lu = "m";  $du = "mm"; $vu = "kg"}
        $t=<LOG>; print "<td>$t\n";		# Years
        $t=<LOG>; print "<td>$t\n";		# Climate
        $t=<LOG>; print "<td>$t\n";		# Soil type
        $t=<LOG>; print "<td>$t\n";		# Surface
        $t=<LOG>; print "<td>$t\n";		# Road design
        $t=<LOG>; print "<td>$t %\n";		# Road gradient
        $t=<LOG>; print "<td>$t $lu\n";		# Road length
        $t=<LOG>; print "<td>$t $lu\n";		# Road width
        $t=<LOG>; print "<td>$t %\n";		# Fill gradient
        $t=<LOG>; print "<td>$t $lu\n";		# Fill length
        $t=<LOG>; print "<td>$t %\n";		# Buffer gradient
        $t=<LOG>; print "<td>$t $lu\n";		# Buffer length
        $t=<LOG>; print "<td>$t $du\n";		# Precipitation
        $t=<LOG>; print "<td>$t $du\n";		# Rain runoff
        $t=<LOG>; print "<td>$t $du\n";		# Snow runoff
        $t=<LOG>; print "<td>$t $vu\n";		# Sediment yield from road
        $t=<LOG>; print "<td>$t $vu\n";		# Sediment yield from profile
        $t=<LOG>; print "<td>$t\n";		# User comment
      }
      close LOG;
      print "</tr>\n";
      print "</table>\n</center>\n";
    }
    else {
      print "No log file found\n";
    }

    print "</body></html>\n";

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

