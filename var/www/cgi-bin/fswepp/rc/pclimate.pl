#! /usr/bin/perl
#! /fsapps/fssys/bin/perl

# pclimate.cli  --  disguised perl script to generate & return climate for personal climates
#   01/24/2001  DEH patched to work under Unix ("working/" to "../working/")
#   01/24/2001  DEH erase (unlink) .cli file after download

#  usage:
#    <form ACTION="https://host/cgi-bin/fswepp/rc/pclimate.cli" method="post">
#  parameters:
#    'state'         
#    'station'       
#    'startyear'   	# should be numeric
#    'simyears'		# should 1..200
#    'action'		# '-download' or '-server'
#    'comefrom'
#    'submitbutton'	# 'describe' or 'download'
#    'me'
#    'units'		# 'm' or 'ft'
#  reads:
#    ../wepphost
#    ../platform
#    d:\fswepp\working
#    $climate_file
#  calls:
#    exec "perl ../rc/descpar.pl $CL $units $iam"
#    exec "perl ../rc/modpar.pl $CL $units $iam"
#    system "cligen43 <$rspfile >$stoutfile"

#  FSWEPP, USDA Forest Service, Rocky Mountain Research Station, Soil & Water Engineering
#  Science by Bill Elliot et alia                      Code by David Hall & Dayna Scheele
#  19 October 1999

    &ReadParse(*parameters);
    $state=$parameters{'state'};         
    $station=$parameters{'station'};       
    $startyear=$parameters{'startyear'};   # should numeric
    $simyears=$parameters{'simyears'};     # should 1..200
    $action=$parameters{'action'};     # "-download" or "-server"
    $comefrom=$parameters{'comefrom'};
    $submitbutton=lc($parameters{'submitbutton'});
    $units=$parameters{'units'};
    $me=$parameters{'me'};

    if ($me ne "") {
       $me = lc(substr($me,0,1));
       $me =~ tr/a-z/ /c;
    }
    if ($me eq " ") {$me = ""}

  $wepphost="localhost";
  if (-e "../wepphost") {
    open Host, "<../wepphost";
    $wepphost = <Host>;
    chomp $wepphost;
    close Host;
  }

  $platform="pc";
  if (-e "../platform") {
    open Platform, "<../platform";
    $platform=lc(<Platform>);
    chomp $platform;
    close Platform;
  }

# get user_ID and remove weirdness
# get user PID for temp files

#    $host = $ENV{REMOTE_HOST};
#    print 'remote_host:     ', $host,"\n<BR>";
     $user_ID = $ENV{REMOTE_ADDR};
     $user_ID =~ tr/./_/;
     $user_ID = $user_ID . $me;
     if ($user_ID eq "") {$user_ID = "custom"}
#    $unique='wepp' . time . '-' . $$;
     $unique='wepp' . '-' . $$;

    $minyear = 1;
    $maxyear=200;

    if ($state eq "") {$state = "id"}
    if ($station eq "") {$station = "id108080"}
    if ($startyear eq "") {$startyear = 1}
    $simyears += 0.5;
    $simyears = int($simyears);
    if ($simyears < $minyear) {$simyears = $minyear}
    if ($simyears > $maxyear) {$simyears = $maxyear}
    if ($action eq "") {$action = "-server"}

#  build filename + ".par"

   if ($platform eq "pc") {
     if (-e "d:/fswepp/working") {$working = 'd:\\fswepp\\working'}
     elsif (-e "c:/fswepp/working") {$working = 'c:\\fswepp\\working'}
     else {$working = '..\\working'}
     $climate_file = $station . ".par";
     $outfile = "$working\\custom.cli";
     $rspfile = "$working\\custom.rsp";
     $stoutfile = "$working\\custom.out"
   }
   else {
     $climate_file = $station . ".par";
     $outfile = "../working/" . $user_ID . ".cli";	# DEH 01/24/2001
     $rspfile = "../working/" . $unique . ".rsp";	# DEH 01/24/2001
     $stoutfile = "../working/" . $unique . ".out";	# DEH 01/24/2001
   }

#    $climate_file = $station . ".par";
#    $outfile = "working\\custom.cli";

# open specified .par file, verify content, and close

    open CLIM, "<" . $climate_file;  # || die "can't open file!";
      $title = <CLIM>;		    # save climate file name to $station_text
      $station_text = substr $title,0,40;
    close CLIM;

####################################################################
#
#  MODIFY
#
####################################################################

    if ($submitbutton =~ /modify/) {
      $state = "personal";
      $CL = $station;
      $iam = "https://" . $wepphost . "/cgi-bin/fswepp/rc/pclimate.cli";
      if ($platform eq "pc") {
         exec "perl ../rc/modpar.pl $CL $units $state $comefrom"
      }
      else {
         exec "../rc/modpar.pl $CL $units $state $comefrom"
      }
    }

####################################################################
#
#  DESCRIBE
#
####################################################################

    if ($submitbutton =~ /describe/) {

      $CL = $station;
      $iam = "https://" . $wepphost . "/cgi-bin/fswepp/rc/pclimate.cli";
      if ($platform eq "pc") {
         exec "perl ../rc/descpar.pl $CL $units $iam"
      }
      else {
         exec "../rc/descpar.pl $CL $units $iam"
      }
    }

##################  ' following for future use in allowing user to modify parameters
#
##    $climate_file = "cligen/" . $state . "/" . $station . ".par";
#
## open specified .par file, verify content, and close
#
#    open CLIM, "<" . $climate_file;  # || die "can't open file!";
#      $title = <CLIM>;
#      $station_text = substr $title,0,40;
#      $line2 = <CLIM>;     $line3 = <CLIM>;
#      $line4 = <CLIM>;     $line5 = <CLIM>;
#      $line6 = <CLIM>;     $line7 = <CLIM>;
#      $line8 = <CLIM>;     $line9 = <CLIM>;
#      $line10 = <CLIM>;    $line11 = <CLIM>;
#      $line12 = <CLIM>;    $line13 = <CLIM>;
#      $line14 = <CLIM>;    $line15 = <CLIM>;
#      $line16 = <CLIM>;    $line17 = <CLIM>;
#    close (CLIM);
#
#    print "Content-type: text/html\n\n";
#    print "<HTML>\n";
#    print "<HEAD>\n";
#    print "<TITLE>$station_text parameters</TITLE>\n";
#    print "</HEAD>\n";#
#    print "<BODY>\n";
#    print "<CENTER><H2>$station_text parameters</H2></CENTER>\n";
#
## create on-the-fly web page to display with:
## display top portion of file values (precip, temp, geog)
#
#    print "<pre>";
#    print $title, $line1, $line2, $line3, $line4, $line5, $line6;
#    print $line7, $line8, $line9, $line10, $line11, $line12, $line13;
#    print $line14, $line15, $line16, $line17;
#    print "</pre><br><hr>\n";
#
#    print "</form></body></html>\n";
#    }      # state OK



####################################################################
#
#  GENERATE
#
####################################################################

  if ($submitbutton =~ /download/) {

#  Write response file and 
#  run CLIGEN43 on verified user_id.par file to
#  create user_id.cli file in WEPP:Road working directory
#  for specified # years.

#    $rspfile = "working\\rc.rsp";
#    $stoutfile = "working\\rc.out";
    open RSP, ">" . $rspfile;
    print RSP "4.31\n";
    print RSP $climate_file,"\n";
    print RSP "n do not display file here\n";
    print RSP "5 Multiple-year WEPP format\n";
    print RSP $startyear,"\n";
    print RSP $simyears,"\n";
    print RSP $outfile,"\n";
    print RSP "n\n";
    close RSP;

    unlink $outfile;   # erase previous climate file so CLIGEN'll run

#   @args = ("nice -20 ./cligen/cligen43 <$rspfile >$stoutFile 2>$sterFile");
#    @args = ("nice -20 ./cligen/cligen43 <$rspfile >$stoutfile");
   if ($platform eq "pc") {
     @args = ("cligen43 <$rspfile >$stoutfile");
   } else {
     @args = ("./cligen43 <$rspfile >$stoutfile");
   }
#    @args = ("cligen43 <$rspfile >$stoutfile");
    system @args;

##############################  DOWNLOAD  ####################

    if ($action eq "-download") {

#  If fileaction=download, send user text/plain version of generated
# user_id.cli file which he/she can file--save-as.
# Delete (unlink) user_id.cli file

## 1) read climate file and write to user.

       print 'Content-Type: application/octet-stream; name="climate.cli"
Content-Disposition: inline; filename="climate.cli"',"\n\n";

      open CLI, $outfile;
      while (<CLI>) {
        print $_;
      }
      close CLI;
      unlink $outfile;
    }
    else {         # "WEPP:Road"

#    $nopath_outfile = $user_ID . ".cli";
#    @args = ("cp $outfile $nopath_outfile");
#    system @args;
# system 'copy $climate_file working/climates/$unweirded_user_id.par'

# | If for WEPP:Road, tell user filename & on for ~1 day;
# | or tell user to accept cookie and store cookie with
# | file name (good for 1 day) to client PC.
# If for WEPP:Road tell user connect from same PC/dialin
# w/in 1 day; choose {[X] custom climate}; W:R looks for
# user_id.cli.

    print "Content-type: text/html\n\n";
    print "<HTML>\n";
    print "<HEAD>\n";
    print "<TITLE>CLIMATE FILE STORED ON SERVER</TITLE>\n";
#    print '<META HTTP-EQUIV="Refresh" CONTENT="5; URL=https://forest.moscowfsl.wsu.edu/4702/wepproad/wrdyn.html">';
    print "</HEAD>\n";
    print '<BODY bgcolor="white">',"\n";
    print "<CENTER><H2> $station_text CLIMATE STORED ON SERVER</H2>\n";
#    print '<FORM name="wepproad" method=post ACTION="https://forest.moscowfsl.wsu.edu/cgi-bin/WEPP/wepproad.pl">';
#    print '<INPUT TYPE="SUBMIT" VALUE="Run WEPP:ROAD"></form></center>';
 
#print "<p>\n Run ";
#    print '<a href="https://forest.moscowfsl.wsu.edu/4702/wepproad/wepproad.html">';
#    print "WEPP:Road</a> select custom-file.
    print "<p><hr><p>\n";
#    print "R_HOST:  ", $ENV{REMOTE_HOST},"<br>\n";
#    print "R_ADDR:  ", $ENV{REMOTE_ADDR},"<br>\n";
#    print "state:   ", $state,"<br>\n";
#    print "station: ", $station, "<br>\n";
#    print "years:   ", $simyears, "<br>\n";
#    print "action:  ", $action, "<br>\n";
#    print "climate: ", $climate_file, "<br>\n";
#    print "climate: ", $outfile, "<br>\n";
#    print "rspfile: ", $rspfile, "<br>\n";

    open CLI, "<" . $outfile;
    print "</center><pre>\n";
    $_ = <CLI>; print; # 4.20
    $_ = <CLI>;        #   1   0   0
    $_ = <CLI>; print; #   Station:  GLENNVILLE CA                                  CLIGEN VERSION 4.2
    $_ = <CLI>; print; # Latitude Longitude Elevation (m) Obs. Years   Beginning year  Years simulated
    $_ = <CLI>; print; #    35.72  -118.70         954          41           1               1
    $_ = <CLI>; print; # Observed monthly ave max temperature (C)
    $_ = <CLI>; print; #  13.6  14.7  15.0  18.4  23.2  28.5  32.8  31.9  29.0  23.5  17.2  14.0
    $_ = <CLI>; print; # Observed monthly ave min temperature (C)
    $_ = <CLI>; print; #  -2.3  -0.9   0.0   1.6   3.9   7.0  10.2   9.5   7.3   3.3  -0.2  -2.4
    $_ = <CLI>; print; # Observed monthly ave solar radiation (Langleys/day)
    $_ = <CLI>; print; # 227.0 321.0 465.0 556.0 649.0 705.0 679.0 637.0 596.0 420.0 265.0 199.0
    $_ = <CLI>; print; # Observed monthly ave precipitation (mm)
    $_ = <CLI>; print; #  82.3  68.2  83.9  45.6  16.5   3.5   0.7   2.7   8.0  18.2  54.3  68.2
    close CLI;
    print "</pre>\n";
#   print "</form>";
    print "<center>\n"; 
    print "<hr><p>";
    if ($comefrom eq "") {
       print '<a href="JavaScript:window.history.go(-1)">'
    }
    else {
       print "<a href=$comefrom>"
    }
    print '<img src="https://',$wepphost,'/fswepp/images/retreat.gif"
      alt="Retreat" border="0" align=center></A>';
    print "</body></html>\n";
   }
   }   # end state and station OK
#    else {    # bad incoming data

#    print "Content-type: text/html\n\n";
#    print "<HTML>\n";
#    print "<HEAD>\n";
#    print "<TITLE>Something is wrong!</TITLE>\n";
#    print "</HEAD>\n";
#    print "<BODY>\n";
#    print "<CENTER><H2>Excuse me!</H2></CENTER>\n";

#    print "I don't like the values of some of the parameters I received.<p>\n";
#    print "state:   ", $state,"<br>\n";
#    print "station: ", $station, "<br>\n";
#    print "years:   ", $simyears, "<br>\n";
#    print "action:  ", $action, "<br>\n";
#    print "climate: ", $climate_file, "<br>\n";
#    print "user_id: ", $user_ID, "<br>\n";
#    if ($comefrom eq "") {
#       print '<a href="JavaScript:window.history.go(-1)">'
#    }
#    else {
#       print "<a href=$comefrom>"
#    }
#     print '<img src="https://',$wepphost,'/fswepp/images/retreat.gif"
#      alt="Retreat" border="0" align=center></A>';
#    print "</form></body></html>\n";
#}
    unlink $stoutfile;
    unlink $rspfile; 

#}    # submitbutton

# --------------------------------------------------------

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
    $in[$i] =~ s/\+/ /g;    # Convert pluses to spaces
    ($key, $val) = split(/=/,$in[$i],2);   # Split into key and value
    $key =~ s/%(..)/pack("c",hex($1))/ge;  # Convert %XX from hex numbers to alphanumeric
    $val =~ s/%(..)/pack("c",hex($1))/ge;
    $in{$key} .= "\0" if (defined($in{$key}));  # \0 is the multiple separator
    $in{$key} .= $val;
  }
  return 1;
 }
