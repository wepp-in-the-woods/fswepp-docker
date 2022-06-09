#! /fsapps/fssys/bin/perl
#
# descpar2.pl
#
#  usage:
#    descpar2.pl?station=path/file&units=m
#    exec descpar2.pl $CL $units
#  arguments:
#    $CL		climate file name
#    $units		'm' or 'ft'
#  reads:
#    ../wepphost	(unused)
#    ../platform	(unused)

#  FSWEPP, USDA Forest Service, Rocky Mountain Research Station, Soil & Water Engineering
#  Science by Bill Elliot et alia                                Code by David Hall

#  Display specified or random climate parameters, short form

#  14 November 2002 DEH tocd/fswepp/fswepp/rc/descpar.pl --> descpar2.pl
#  18 April 2002   DEH add display PAR file for Chris Pyke [limit to his IP and ours] 
#  23 August 2000  DEH add table reporting interpolation stations and record
#  12 April 2000   DEH fixed parsing of temperature lines (Jan standalone fix)
#  19 October 1999

    $version = "2003.01.13";

#    &ReadParse(*parameters);
#    $station=$parameters{'station'};       
#    $units=$parameters{'units'};

    $debug=TRUE;
#    $lotsofoutput=TRUE;
    $monthlyoutput=TRUE;

    if ($station eq '' && $units eq '') {
      $station=$ARGV[0];
      $units=$ARGV[1];
      chomp $station;
      chomp $units;
    }

    if ($station eq '' && $units eq '') {
      $station='wy/Wy487845';
      $units='f';
      $climateFile = $station . 'par';
      if (-e $climateFile) {}
      else {$sation='wy\\Wy487845'}
      chomp $units;
    }

#   $wepphost="localhost";
#   if (-e "../wepphost") {
#     open HOST, "<../wepphost";
#     $wepphost=lc(<HOST>);
#     chomp $wepphost;
#     close HOST;
#   }

#   $platform="pc";
#   if (-e "../platform") {
#     open Platform, "<../platform";
#     $platform=lc(<Platform>);
#     chomp $platform;
#     close Platform;
#   }

   $climateFile = $station . '.par';

   $units = 'f' if $units ne 'm';

   if ($climateFile eq '.par') {
#     select random 1..51 for 'AK' to 'WY'
#     read directory for number of .par files
#     select random 1..num_par_files
#     return $climateFile
   }


#   print "station: $station\nunits: $units\n";
#   die

#----------------

   open PAR, "<$climateFile" || die;

   $line=<PAR>;                           # EPHRATA CAA AP WA 452614 0
   $climate_name = substr($line,1,32);

   print "Content-type: text/html\n\n";
   print "<HTML>\n";
   print " <HEAD>\n";
   print "  <TITLE>Climate Parameters</TITLE>\n";
   print " </HEAD>\n";
   print ' <body bgcolor="white" link="#1603F3" vlink="#160A8C" onLoad="self.focus()">
  <font face="Arial, Geneva, Helvetica">';
   print "
   <CENTER>
    <H2>$climate_name</H2>\n";

     if ($debug) {print "climate: $station ; units: $units<br>\n"}

     $line=<PAR>;                           # LATT=  47.30 LONG=-119.53 YEARS= 44. TYPE= 3
     ($lattext, $lat, $lon, $yr_rec, $type) = split '=',$line;
     $line=<PAR>;	# ELEVATION = 1260. TP5 = 0.86 TP6= 2.90
     ($this,$that) = split '=',$line; $elev = $that + 0;
     $line=<PAR>;	# MEAN P   0.10  0.10  0.11  0.10  0.11  0.14  0.14 0.09  0.10  0.10  0.12  0.12
     @mean_p_if = split ' ',$line; $mean_p_base = 2;
     $line=<PAR>;	# S DEV P  0.12  0.12  0.11  0.13  0.13  0.18  0.22 0.13  0.13  0.11  0.14  0.13
     $line=<PAR>;	# SQEW  P  1.88  2.30  2.21  2.15  2.29  2.35  3.60 3.22  2.05  2.49  2.22  1.87
     $line=<PAR>;	# P(W/W)   0.47  0.50  0.39  0.32  0.33  0.30  0.27 0.28  0.40  0.41  0.42  0.48
     @pww = split ' ',$line; $pww_base = 1; 
     $line=<PAR>;	# P(W/D)   0.20  0.16  0.15  0.13  0.13  0.11  0.05 0.06  0.08  0.12  0.23  0.23
     @pwd = split ' ',$line; $pwd_base=1;
     $line=<PAR>;	# TMAX AV 32.89 41.62 52.60 62.81 72.56 80.58 88.52 87.06 77.76 62.85 44.78 34.63
     for $ii (0..11) {
       $tmax_av[$ii]=substr($line,8+$ii*6,6)
     }
     $tmax_av_base = 0;
     $line=<PAR>;	# TMIN AV 20.31 26.55 32.33 39.12 47.69 55.39 61.58 60.31 51.52 40.17 30.33 22.81
     for $ii (0..11) {
       $tmin_av[$ii]=substr($line,8+$ii*6,6)
     }
     $tmin_av_base = 0;

   while (<PAR>) {
     if (/Wind Stations/) {
       $line = <PAR>;   # IDAHO FALLS   ID     .339  IDAHO FALLS   ID .339 DILLON        MT     .322
       $ws1 = substr($line, 0,20); $wwt1 = substr($line,20,5);
       $ws2 = substr($line,27,20); $wwt2 = substr($line,47,5);
       $ws3 = substr($line,54,20); $wwt3 = substr($line,74,5);
     }
     if (/Solar Radiat/) {
       $line = <PAR>;   #  BILLINGS, MONTANA   .390   POCATELLO, IDAHO .307   HELENA, MONTANA     .303
       $ss1 = substr($line, 0,20); $swt1 = substr($line,20,5);
       $ss2 = substr($line,27,20); $swt2 = substr($line,47,5);
       $ss3 = substr($line,54,20); $swt3 = substr($line,74,5);
     }
     if (/Dewpoint/) {
       $line = <PAR>;   # MT BILLINGS          .366  MT BUTTE .325  WY LANDER            .309
       $dwt1 = substr($line,20,5);
       $dwt2 = substr($line,47,5);
       $dwt3 = substr($line,74,5);
       $dst = substr($line,0,2); $dsc = substr($line,3,18); 
       $ds1 = $dsc . ' ' . $dst; 
       $dst = substr($line,27,2); $dsc = substr($line,30,18); 
       $ds2 = $dsc . ' ' . $dst; 
       $dst = substr($line,54,2); $dsc = substr($line,57,18); 
       $ds3 = $dsc . ' ' . $dst; 
     }
     if (/Time Peak/) {
       $line = <PAR>;   # LAKE YELLOWSTONE WY 1.000  COOKE CITY 2 W MT .000  CAMERON MT           .000
       $ts1 = substr($line, 0,20); $twt1 = substr($line,20,5);
       $ts2 = substr($line,27,20); $twt2 = substr($line,47,5);
       $ts3 = substr($line,54,20); $twt3 = substr($line,74,5);
     }
     if (/Modified by/) {
       $modhead = $_; $modfile = <PAR>;
     }
   }
   close PAR;

   @month_name=qw(January February March April May June July August September October November December);
   @month_days=(31,28,31,30,31,30,31,31,30,31,30,31);

     $lat += 0;
     $lon += 0;
     $yr_rec += 0;
     print '    <h3>';
     printf "%.2f", abs($lat);     print '<sup>o</sup>';
     if ($lat > 0) {print 'N '} else {print 'S '}
     printf "%.2f", abs($lon);     print '<sup>o</sup>';
     if ($lon > 0) {print 'E'} else {print 'W'};
     if ($units eq 'm') {
       printf "; %4d m elevation",$elev / 3.28;
     }
     else {
       print "; $elev feet elevation";
     }
     print "<br>$yr_rec years of record</h3>";

     if ($lotsofoutput) {
       print '
    <table border=1 bgcolor="white">
     <tr>
      <th bgcolor="#85D2D2">Month</th>
      <th bgcolor="#85D2D2">Avg precip</th>
      <th bgcolor="#85D2D2">p(w/w)</th>
      <th bgcolor="#85D2D2">p(w/d)</th>
      <th bgcolor="#85D2D2">tmaxav</th>
      <th bgcolor="#85D2D2">tminav</th>';
        for $i (0..11) {
          print '
     <tr>
      <th>',$month_name[$i],'</th>
      <td align=right>',$mean_p_if[$i+$mean_p_base],'</td>
      <td align=right>',$pww[$i+$pww_base],'</td>
      <td align=right>',$pwd[$i+$pwd_base],'</td>
      <td align=right>',$tmax_av[$i+$tmax_av_base],'</td>
      <td align=right>',$tmin_av[$i+$tmin_av_base],'</td>
';
        }
        print '  </table>
  <p>
';
    } # lotsofoutput

#-----------------------------------

#    $lathemisphere = "N";
#    $longhemisphere = "W";
#    if ($lat<0) {$lathemisphere = "S"}
#    if ($lon>0) {$longhemisphere = "E"} 
    $tempunit = '<sup>o</sup>F';
    $pcpunit='in';
    if ($units eq 'm') {$tempunit = '<sup>o</sup>C'; $pcpunit='mm'}

    for $i (1..12) {
      $pw[$i] = $pwd[$i] / (1 + $pwd[$i] - $pww[$i]);
    }

#    print abs($lat),"<sup>o</sup>$lathemisphere",
#          abs($lon),"<sup>o</sup>$longhemisphere<br>\n";
#    print '<center>';

    print "
    <table border=1 bgcolor=white>
     <tr>
     <th bgcolor=85D2D2>
     <th bgcolor=85D2D2>Mean<br>Maximum<br>Temperature<br>($tempunit)</th>
     <th bgcolor=85D2D2>Mean<br>Minimum<br>Temperature<br>($tempunit)</th>
     <th bgcolor=85D2D2>Mean<br>Precipitation<br>($pcpunit)</th>
     <th bgcolor=85D2D2>Number<br>of wet days</th>
";
    $annual_precip = 0;
    $annual_wet_days = 0;
    for $i (0..11) {
        $tmax = $tmax_av[$i+$tmax_av_base];
        $tmin = $tmin_av[$i+$tmin_av_base];
        $num_wet = $pw[$i+$pww_base] * $month_days[$i];
        $mean_p = $num_wet * $mean_p_if[$i+$mean_p_base];
        if ($units eq 'm') {
           $mean_p *= 25.4;                 # inches to mm
           $tmax = ($tmax - 32) * 5/9;      # deg F to deg C
           $tmin = ($tmin - 32) * 5/9;      # deg F to deg C
        }
        $annual_precip += $mean_p;
        $annual_wet_days += $num_wet;
      if ($monthlyoutput) {
        print "    <tr>\n";
        print "     <th bgcolor=85D2D2>$month_name[$i]</th>\n";
        printf "     <td align=right>%7.1f</td>\n",$tmax;
        printf "     <td align=right>%7.1f</td>\n",$tmin;
        printf "     <td align=right>%7.2f</td>\n",$mean_p;
        printf "     <td align=right>%7.1f</td>\n",$num_wet;
        print "    </tr>\n";
      }       # $monthlyoutput
    }
    print "    <tr>
     <th bgcolor=85D2D2>Annual</th>
     <td align=right><br></td>
     <td align=right><br></td>\n";
    printf "     <td align=right>%7.2f</td>\n",$annual_precip;
    printf "     <td align=right>%7.1f</td>\n",$annual_wet_days;
    print "    </tr>\n   </table>\n   </p>\n";

#-----------------------------------

#if ($climate_name eq "") {$climate_name = $CL}  # should remove path and .cli

print '
   <p>
    <font size=-1>
    ',$modhead,' ',$modfile,'
    </font>
   </p>
  </center>
';

#-----------------------------------------


print "
  </font>
  <hr>
 </BODY>
</HTML>\n";


#-----------------------------------------

sub ReadParse {

# ReadParse -- from cgi-lib.pl (Steve Brenner) from Eric Herrmann's
# "Teach Yourself CGI Programming With PERL in a Week" p. 131

# Reads GET or POST data, converts it to unescaped text, and puts
# one key=value in each member of the list "@in"
# Also creates key/value pairs in %in, using '\0' to separate multiple
# selections

# If a variable-glob parameter...

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

#---------------------------

sub printdate {

    @months=qw(January February March April May June July August September October November December);
    @days=qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);
    $ampm[0] = "am";
    $ampm[1] = "pm";

    $ampmi = 0;
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime;
    if ($hour == 12) {$ampmi = 1}
    if ($hour > 12) {$ampmi = 1; $hour = $hour - 12}
    printf "%0.2d:%0.2d ", $hour, $min;
    print $ampm[$ampmi],"  ",$days[$wday]," ",$months[$mon];
    print " ",$mday,", ",$year+1900, " GMT/UTC/Zulu<br>\n";

    $ampmi = 0;
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime;
    if ($hour == 12) {$ampmi = 1}
    if ($hour > 12) {$ampmi = 1; $hour = $hour - 12}
    printf "%0.2d:%0.2d ", $hour, $min;
    print $ampm[$ampmi],"  ",$days[$wday]," ",$months[$mon];
    print " ",$mday,", ",$year+1900, " Pacific Time";
}

