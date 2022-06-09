#! /usr/bin/perl
#! /fsapps/fssys/bin/perl
#
# desccli.pl
#
#  usage:
#    exec desccli.pl $CL $units
#  arguments:
#    $CL		climate file name
#    $units		'm' or 'ft' or '-um' or '-uft'
#  reads:
#    ../wepphost
#    ../platform

# Read .CLI file headers
# Display headers formatted

#     4.3
#       1     1   0
# Station:  SNOTEL - Fallen Leaf Snotel A2
# Latitude Longitude Elevation (m) Obs. Years   Beginning year  Years simulated
#   38.935        -120.045   2028.96      99    2001      99
# Observed monthly ave max temperature (C)
#      5.6     6.6     9.3    10.9    14.9    19.3    24.0    23.6    21.4    15.8     8.6     4.8
# Observed monthly ave min temperature (C)
#     -7.7    -7.5    -6.0    -4.4    -1.3     1.2     4.5     4.3     2.1    -1.3    -5.3    -8.0
# Observed monthly ave solar radiation (Langleys/day)
#    213.5   283.3   408.6   498.4   589.3   674.2   684.2   610.1   503.7   381.5   252.1   201.5
# Observed monthly ave precipitation (mm)
#    324.7   268.5   255.5   133.6    98.6    32.2     3.2     7.8    25.6    82.0   200.2   332.6


#  1	CLIGEN version
#  2a	simulation mode (1: continuous; 2: single storm)
#  2b	breakpoint data flag (0: no bp data; 1: bp data used)
#  2c	wind information/ET equation flag (0: wind info, use Penman ET eq; 1: no wind info, use Priestly-Taylor ET eq)
#  3	Station ID, etc
#  5	Latitude Longitude Elevation (m) Obs. Years   Beginning year  Years simulated 	
#  7	Observed monthly ave max temperature (C)
#  9	Observed monthly ave min temperature (C)
# 11	Observed monthly ave solar radiation (Langleys[/day])
# 13	Observed monthly ave precipitation (mm)
BREAKPOINT:
# 16a	day of simulation (0..31)
# 16b	month of simulation (0..12)
# 16c	year of simulation
# 16d	number of breakpoints (0..50)
# 16e	maximum daily tmperature (C)
# 16f	minimum daily temperature (C)
# 16g	daily solar radiation (langley/day)
# 16h	wind velocity (m/sec)
# 16i	wind direction (deg from N)
# 16j	dew point tep (C)
# 17a	time after midnight (h)
# 17b	cumulative precip at this time (mm of water)


#  FSWEPP, USDA Forest Service, Rocky Mountain Research Station, Soil & Water Engineering
#  Science by Bill Elliot et alia                                      Code by David Hall

#  2012.08.31 DEH built atop of descpar.pl
#  2010.06.11 DEH filter single quote out of par file climate name for display of .par and map
#  2005.06.07 DEH Fix units to recognize '-um' as well as 'm'
#  07 October 2004 DEH -- ?
#  24 April 2003   DEH add map popup and PAR file popup, and remove RTIS.gif
#  27 March 2003   DEH add displayPAR file  to Corey Moffett remove Chris Pyke
#  18 April 2002   DEH add display PAR file for Chris Pyke [limit to his IP and ours]
#  23 August 2000  DEH add table reporting interpolation stations and record
#  12 April 2000   DEH fixed parsing of temperature lines (Jan standalone fix)
#  19 October 1999

   $version = '2012.08.31';

   $CL=$ARGV[0];
   $units=$ARGV[1];
#  $wherefrom=$ARGV[2];


#  $CL = 'Heavenly_A2_srad';

   chomp $CL;
   $units = 'm' if ($units eq '-um');
   $units = 'm' if ($units eq '');

   $wepphost="localhost";
   if (-e "../wepphost") {
     open HOST, "<../wepphost";
     $wepphost=lc(<HOST>);
     chomp $wepphost;
     close HOST;
   }

   $platform="pc";
   if (-e "../platform") {
     open Platform, "<../platform";
     $platform=lc(<Platform>);
     chomp $platform;
     close Platform;
   }

   $climateFile = $CL . '.cli';

   open CLI, "<$climateFile";
   $line=<CLI>;         #     4.3

     $line=<CLI>;	#       1     1   0
     ($itemp, $ibrkpt, $iwind) = split ' ',$line;
     $line=<CLI>;	# Station:  SNOTEL - Fallen Leaf Snotel A2
     ($dupe, $climate_name) = split ':',$line;
     $line=<CLI>;	# Latitude Longitude Elevation (m) Obs. Years   Beginning year  Years simulated
     $line=<CLI>;	#   38.935        -120.045   2028.96      99    2001      99
     ($deglat, $deglon, $elev, $obsyrs, $ibyear, $numyr) = split ' ',$line;
     $line=<CLI>;	# Observed monthly ave max temperature (C)
     $line=<CLI>;	#      5.6     6.6     9.3    10.9    14.9    19.3    24.0    23.6    21.4    15.8     8.6     4.8
     (@obmaxt) = split ' ',$line;
     $line=<CLI>;	# Observed monthly ave min temperature (C)
     $line=<CLI>;	#     -7.7    -7.5    -6.0    -4.4    -1.3     1.2     4.5     4.3     2.1    -1.3    -5.3    -8.0
     (@obmint) = split ' ',$line;
     $line=<CLI>;	# Observed monthly ave solar radiation (Langleys/day)
     $line=<CLI>;	#    213.5   283.3   408.6   498.4   589.3   674.2      ($deglat, $deglon, $elev, $obsyrs, $ibyear, $numyr) = split ' ',$line;
     (@radave) = split ' ',$line;
     $line=<CLI>;	# Observed monthly ave precipitation (mm)
     $line=<CLI>;	#    324.7   268.5   255.5   133.6    98.6    32.2     3.2     7.8    25.6    82.0   200.2   332.6
     (@obrain) = split ' ',$line;

   close CLI;

   @month_name=qw(January February March April May June July August September October November December);
   @month_days=(31,28,31,30,31,30,31,31,30,31,30,31);

     $lat += 0;
     $lon += 0;

##########################
   chomp $climate_name;
   $climate_name_filt=$climate_name;
   $climate_name_filt =~ s/'/`/;
   print "Content-type: text/html\n\n";
   print "<HTML>\n";
   print " <HEAD>\n";
   print "  <TITLE>Climate Parameters</TITLE>\n";
   print " </HEAD>\n";                                             
   print ' <body bgcolor=white link="#1603F3" vlink="#160A8C">
  <font face="Arial, Geneva, Helvetica">',"\n";
   print "   <center>
    <h2>Climate file headers for $climate_name</h2>\n";

     if ($debug) {print "climate: '$CL' ; units: '$units'<br>\n"}  
##########################

     $yr_rec += 0;
     print '    <h3>';
     printf "%.2f", abs($deglat);     print '<sup>o</sup>';
     if ($deglat > 0) {print 'N '} else {print 'S '}
     printf "%.2f", abs($deglon);     print '<sup>o</sup>';
     if ($deglon > 0) {print 'E'} else {print 'W'};

     if ($units eq 'm') {
#      printf "; %4d m elevation",$elev;	# 2028.96 -> 2028
       printf "; %4.0f m elevation",$elev;
     }
     else {
       printf "; %4d ft elevation",$elev * 3.28;
     }
     print "<br>$obsyrs years of record</h3>\n";
     print '    <img src="/fswepp/images/line_red2.gif"><p>',"\n";

#-----------------------------------

#    $lathemisphere = "N";
#    $longhemisphere = "W";
#    if ($lat<0) {$lathemisphere = "S"}
#    if ($lon>0) {$longhemisphere = "E"} 
     $tempunit = '<sup>o</sup>F';
     $pcpunit='in';
     if ($units eq 'm') {$tempunit = '<sup>o</sup>C'; $pcpunit='mm'}

#    print abs($lat),"<sup>o</sup>$lathemisphere",
#          abs($lon),"<sup>o</sup>$longhemisphere<br>\n";
#    print '<center>';

     print "
    <table border=1 bgcolor=white>
     <tr>
      <th bgcolor=85D2D2>Month</th>
      <th bgcolor=85D2D2>Observed<br>Mean<br>Maximum<br>Temperature<br>($tempunit)</th>
      <th bgcolor=85D2D2>Observed<br>Mean<br>Minimum<br>Temperature<br>($tempunit)</th>
      <th bgcolor=85D2D2>Observed<br>Mean<br>Precipitation<br>($pcpunit)</th>
      <th bgcolor=85D2D2>Observed<br>Mean<br>Solar Radiation<br>(langley/d)</th>
     </tr>
";
    $annual_precip = 0;
    $annual_wet_days = 0;
    for $i (0..11) {
        if ($units eq 'm') {
        }
        else {
           @obrain[$i] /= 25.4;                 # mm to inches
           @obmaxt[$i] = @obmaxt[$i] * 9/5 + 32 ;      # deg C to deg F
           @obmint[$i] = @obmint[$i] * 9/5 + 32 ;      # deg C to deg F
        }
        $annual_precip += @obrain[$i];
        print  "     <tr><th bgcolor=85D2D2>$month_name[$i]</th>\n";
        printf "      <td align=right>%7.1f</td>\n",@obmaxt[$i];
        printf "      <td align=right>%7.1f</td>\n",@obmint[$i];
        printf "      <td align=right>%7.2f</td>\n",@obrain[$i];
        printf "      <td align=right>%7.1f</td>\n",@radave[$i];
        print  "     </tr>\n";
    }

    print  "     <tr><th bgcolor=85D2D2>Annual</th>\n";
    print  "      <td><br></td><td><br></td>\n";
    printf "      <td align=right>%7.2f</td>\n",$annual_precip;
    print  "     </tr>\n";
    print  "    </table>\n    <br>\n";

#   ($itemp, $ibrkpt, $iwind) = split '=',$line;

    print '    <font size=-1>';
    if ($itemp eq '1') {print 'continuous'} else {print 'single storm'}; print ' simulation; ';
    if ($ibrkpt eq '0') {print ' no breakpoint data;'} else {print ' breakpoint data;'};
    if ($iwind eq '0') {print ' no wind data&ndash;use Penman ET'} else {print ' wind data&ndash;use Priestly-Taylor ET equation'};
    print "</font><br><br>\n";

#-----------------------------------

#if ($climate_name eq "") {$climate_name = $CL}  # should remove path and .cli

print '
    <img src="/fswepp/images/line_red2.gif">
    <form>
     <input type="submit" value="Return to input screen" onClick="window.history.go(-1); return false;">                            
    </form>
';

    print "
   </center>
   <pre>
$comment
@comments
   </pre>
";

print "
  </center>
   <font size=-2>
    <hr>
    <b>desccli</b> version $version
    (a part of <b>Rock:Clime</b>)<br>
    USDA Forest Service Rocky Mountain Research Station<br>
    1221 South Main Street, Moscow, ID 83843
   </font>
  </font>
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
