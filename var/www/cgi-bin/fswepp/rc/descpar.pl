#! /usr/bin/perl
#! /fsapps/fssys/bin/perl
#
# descpar.pl
#
#  usage:
#    exec descpar.pl $CL $units
#    exec descpar.pl $CL $units $wherefrom
#  arguments:
#    $CL		climate file name
#    $units		'm' or 'ft' or '-um' or '-uft'
#    $wherefrom
#  reads:
#    ../wepphost
#    ../platform

#  FSWEPP, USDA Forest Service, Rocky Mountain Research Station, Soil & Water Engineering
#  Science by Bill Elliot et alia                                      Code by David Hall

#  2010.06.11 DEH filter single quote out of par file climate name for display of .par and map
#  2005.06.07 DEH Fix units to recognize '-um' as well as 'm'
#  07 October 2004 DEH -- ?
#  24 April 2003   DEH add map popup and PAR file popup, and remove RTIS.gif
#  27 March 2003   DEH add displayPAR file  to Corey Moffett remove Chris Pyke
#  18 April 2002   DEH add display PAR file for Chris Pyke [limit to his IP and ours]
#  23 August 2000  DEH add table reporting interpolation stations and record
#  12 April 2000   DEH fixed parsing of temperature lines (Jan standalone fix)
#  19 October 1999

# $lotsofoutput=1;


#  $version = "2005.06.07";
   $version = '2010.04.08';     # allow random trailing text to be displayed (for SNOTEL, etc)

   $CL=$ARGV[0];
   $units=$ARGV[1];
#  $wherefrom=$ARGV[2];

   chomp $CL;
   $units = 'm' if ($units eq '-um');	# 2005.06.07 DEH

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

   $climateFile = $CL . '.par';
#  $climate_name=$parameters{'climate_name'};

   open PAR, "<$climateFile";
   $line=<PAR>;                           # EPHRATA CAA AP WA                       452614 0
   $climate_name = substr($line,1,32);

     $line=<PAR>;                           # LATT=  47.30 LONG=-119.53 YEARS= 44. TYPE= 3
     ($lattext, $lat, $lon, $yr_rec, $type) = split '=',$line;
     $line=<PAR>;	# ELEVATION = 1260. TP5 = 0.86 TP6= 2.90
     ($this,$that) = split '=',$line; $elev = $that + 0;
     $line=<PAR>;	# MEAN P   0.10  0.10  0.11  0.10  0.11  0.14  0.14  0.09  0.10  0.10  0.12  0.12
     @mean_p_if = split ' ',$line; $mean_p_base = 2;
     $line=<PAR>;	# S DEV P  0.12  0.12  0.11  0.13  0.13  0.18  0.22  0.13  0.13  0.11  0.14  0.13
     $line=<PAR>;	# SQEW  P  1.88  2.30  2.21  2.15  2.29  2.35  3.60  3.22  2.05  2.49  2.22  1.87
     $line=<PAR>;	# P(W/W)   0.47  0.50  0.39  0.32  0.33  0.30  0.27  0.28  0.40  0.41  0.42  0.48
     @pww = split ' ',$line; $pww_base = 1;
     $line=<PAR>;	# P(W/D)   0.20  0.16  0.15  0.13  0.13  0.11  0.05  0.06  0.08  0.12  0.23  0.23
     @pwd = split ' ',$line; $pwd_base=1;
     $line=<PAR>;	# TMAX AV 32.89 41.62 52.60 62.81 72.56 80.58 88.52 87.06 77.76 62.85 44.78 34.63
     for $ii (0..11) {$tmax_av[$ii]=substr ($line,8+$ii*6,6)}; $tmax_av_base = 0;
     $line=<PAR>;	# TMIN AV 20.31 26.55 32.33 39.12 47.69 55.39 61.58 60.31 51.52 40.17 30.33 22.81
     for $ii (0..11) {$tmin_av[$ii]=substr ($line,8+$ii*6,6)}; $tmin_av_base = 0;

   while (<PAR>) {
#     print;
#     $/="\n"; chomp;     # some lines have 0d0d0a so remove all CR LF
#     $/="\r"; chomp;
#     $/="\n";
#     tr/ //;
#     if (/^$/) {last};		# look for blank line -- not working...?
     last if (/CALM/);
   }

   $_ = <PAR>;   $_ = <PAR>;

   if (/INTERPOLATED DATA/ || /TRIANGULATED DATA/) {
     $interpolated=1;
     while (<PAR>) {
       if (/Wind Stations/) {
         $line = <PAR>;   # IDAHO FALLS   ID     .339  IDAHO FALLS   ID .339  DILLON        MT     .322
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
     }	# while (<PAR>)
   }	# if (/INTERPOLATED DATA/) {
   else {	# if (/INTERPOLATED DATA/) {
     $comment=$_;
     @comments=<PAR>;
   }
   close PAR;

   @month_name=qw(January February March April May June July August September October November December);
   @month_days=(31,28,31,30,31,30,31,31,30,31,30,31);

     $lat += 0;
     $lon += 0;

##########################
   $climate_name_filt=$climate_name;
   $climate_name_filt =~ s/'/`/;
   print "Content-type: text/html\n\n";
   print "<HTML>\n";
   print " <HEAD>\n";
   print "  <TITLE>Climate Parameters</TITLE>\n";
   print "  <script language=Javascript>
   function ShowMap() {
    newin = window.open('','map',',scrollbars=yes,resizable=yes,height=600,width=900,status=yes')
    newin.document.open()                                                        
    newin.document.writeln('<html>')
    newin.document.writeln(' <head>')
    newin.document.writeln('  <title>Map of $climate_name_filt</title>')
    newin.document.writeln(' </head>')
    newin.document.writeln(' <body bgcolor=ivory onLoad=\"self.focus()\">')
    newin.document.writeln('  <center>')
    newin.document.writeln('   <h3>$climate_name_filt -- $lat<sup>o</sup>N$lon<sup>o</sup>E</h3>')
    newin.document.writeln('   <table border=5 cellpadding=4 bgcolor=\"black\">')
    newin.document.writeln('    <tr>')
    newin.document.writeln('     <th><img src=\"https://tiger.census.gov/cgi-bin/mapgen?&lat=$lat&lon=$lon&on=states&iwd=400&iht=400&wid=10&ht=10&mark=$lon,$lat,redstar\" width=400 height=400><br><font color=white>10 deg x 10 deg</font></th>')
    newin.document.writeln('     <th><img src=\"https://tiger.census.gov/cgi-bin/mapgen?&lat=$lat&lon=$lon&on=states&iwd=400&iht=400&wid=1&ht=1&mark=$lon,$lat,redstar\" width=400 height=400><br><font color=white>1 deg x 1 deg</font></th>')
    newin.document.writeln('    </tr>')
    newin.document.writeln('   </table>')
    newin.document.writeln('   <a href=\"https://tiger.census.gov/cgi-bin/mapsurfer?&infact=2&outfact=2&act=move&tlevel=-&tvar=-&tmeth=i&mlat=$lat&mlon=$lon&msym=smalldot&mlabel=&murl=&lat=$lat&lon=$lon&wid=0.045&ht=0.016&conf=mapnew.con\">more</a> Tiger Census map options')
    newin.document.writeln('  </center>')
    newin.document.writeln(' </body>')
    newin.document.writeln('</html>')
    newin.document.close()
   }
   function ShowPar() {
// alert ('ShowPar')
    newin = window.open('','par',',scrollbars=yes,resizable=yes,height=600,width=900,status=yes')                       
    newin.document.open()
    newin.document.writeln('<html><body onload=\"self.focus()\"><pre>')
";
   open PAR, "<$climateFile";
   while (<PAR>) {
     tr/'/`/;
#    s/'/ /;
     $/="\n"; chomp;	# some lines have 0d0d0a so remove all CR LF
     $/="\r"; chomp;
     $/="\n";
    print "    newin.document.writeln('$_')\n";
   }
   close PAR;
   print "
    newin.document.close()
   }
  </script>
";
   print " </HEAD>\n";                                             
   print ' <body bgcolor=white link="#1603F3" vlink="#160A8C">
  <font face="Arial, Geneva, Helvetica">',"\n";
   print "   <center>
    <h2>Climate parameters for $climate_name</h2>\n";

     if ($debug) {print "climate: '$CL' ; units: '$units'<br>\n"}  
##########################

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
     print "<br>$yr_rec years of record</h3>\n";
     print '    <img src="/fswepp/images/line_red2.gif"><p>',"\n";
     if ($lotsofoutput) {
       print '     <table border=1>
               <tr><th bgcolor="#85D2D2">Month
                   <th bgcolor="#85D2D2">Avg precip
                   <th bgcolor="#85D2D2">p(w/w)
                   <th bgcolor="#85D2D2">p(w/d)
                   <th bgcolor="#85D2D2">tmaxav
                   <th bgcolor="#85D2D2">tminav',"\n";
        for $i (0..11) {
          print '      <tr><th>',$month_name[$i],"</th>\n",
                '       <td align=right>',$mean_p_if[$i+$mean_p_base],"</td>\n",
                '       <td align=right>',$pww[$i+$pww_base],"</td>\n",
                '       <td align=right>',$pwd[$i+$pwd_base],"</td>\n",
                '       <td align=right>',$tmax_av[$i+$tmax_av_base],"</td>\n",
                '       <td align=right>',$tmin_av[$i+$tmin_av_base],"</td>\n";
        }
        print '</table>
    <br><br>
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
      <th bgcolor=85D2D2>Month</th>
      <th bgcolor=85D2D2>Mean<br>Maximum<br>Temperature<br>($tempunit)</th>
      <th bgcolor=85D2D2>Mean<br>Minimum<br>Temperature<br>($tempunit)</th>
      <th bgcolor=85D2D2>Mean<br>Precipitation<br>($pcpunit)</th>
      <th bgcolor=85D2D2>Number<br>of wet days</th>
     </tr>
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
        print  "     <tr><th bgcolor=85D2D2>$month_name[$i]</th>\n";
        printf "      <td align=right>%7.1f</td>\n",$tmax;
        printf "      <td align=right>%7.1f</td>\n",$tmin;
        printf "      <td align=right>%7.2f</td>\n",$mean_p;
        printf "      <td align=right>%7.1f</td>\n",$num_wet;
        print  "     </tr>\n";
    }
    print  "     <tr><th bgcolor=85D2D2>Annual</th>\n";
    print  "      <td><br></td><td><br></td>\n";
    printf "      <td align=right>%7.2f</td>\n",$annual_precip;
    printf "      <td align=right>%7.1f</td>\n",$annual_wet_days;
    print  "     </tr>\n";
    print  "    </table>\n    <br><br>\n";

# **********************

#print '<a href="https://tiger.census.gov/cgi-bin/mapgen?&lat=',$ylt;
#print "&lon=$yll&on=states&iwd=400&iht=400&wid=1&ht=1&mark=$yll,$ylt,redstar";
#print '">Generate 1<sup>o</sup> <i>x</i> 1<sup>o</sup> map</a><br>
#       <a href="https://tiger.census.gov/cgi-bin/mapgen?&lat=',$ylt;
#print "&lon=$yll&on=states&iwd=400&iht=400&wid=10&ht=10&mark=$yll,$ylt,redstar";
#print '">Generate 10<sup>o</sup> <i>x</i> 10<sup>o</sup> map</a>';
#print "\n<center>\n";

#    print "<p><input type=submit value=test>\n";
#    print "</form></body></html>\n";
#    }      # DESCRIBE

#-----------------------------------

#if ($climate_name eq "") {$climate_name = $CL}  # should remove path and .cli

print '
    <img src="/fswepp/images/line_red2.gif">
    <form>
     <input type="hidden" value="Show map" onClick="ShowMap(); return false;">
     <input type="submit" value="Show PAR" onClick="ShowPar(); return false;">
     <input type="submit" value="Return to input screen" onClick="window.history.go(-1); return false;">                            
    </form>
';

#<!--
#<form action="https://',$wepphost,'/cgi-bin/fswepp/rc/mapper.pl" method="post">
#<input type="hidden" name="lat" value="',$lat,'">
#<input type="hidden" name="lon" value="',$lon,'">
#<input type="hidden" name="station" value="',$climate_name,'">
#<input type="submit" value="Display map">
#</form>
#<p>
#<a href="JavaScript:window.history.go(-1)">
#<img src="https://',$wepphost,'/fswepp/images/rtis.gif"
#  alt="Return to input screen" border="0" align=center></A>
#<BR>
#-->

  if ($interpolated) {
print '
    <h4>INTERPOLATED DATA</h4>

    <table border=1 bgcolor=85d2d2>
     <tr>
      <th><font size=-1>Station</th>
      <th><font size=-1>Weighting</th>
      <th><font size=-1>Station</th>
      <th><font size=-1>Weighting</th>
     <tr>
      <td bgcolor=white colspan=2><font size=-1><b>Wind Stations</b></td>
      <td bgcolor=white colspan=2><font size=-1><b>Solar Radiation and Max .5 P Stations</b></td>
     </tr>
     <tr>
      <td>&nbsp;&nbsp;&nbsp;<font size=-1>',$ws1,'</td>
      <td align=right><font size=-1> ',$wwt1*100,' %&nbsp;&nbsp;</td>
      <td>&nbsp;&nbsp;&nbsp;<font size=-1>',$ss1,'</td>
      <td align=right><font size=-1>',$swt1*100,' %&nbsp;&nbsp;</td>
     </tr>
     <tr>
      <td>&nbsp;&nbsp;&nbsp;<font size=-1>',$ws2,'</td>
      <td align=right><font size=-1> ',$wwt2*100,' %&nbsp;&nbsp;</td>
      <td>&nbsp;&nbsp;&nbsp;<font size=-1>',$ss2,'</td>
      <td align=right><font size=-1> ',$swt2*100,' %&nbsp;&nbsp;</td>
     </tr>
     <tr>
      <td>&nbsp;&nbsp;&nbsp;<font size=-1>',$ws3,'</td>
      <td align=right><font size=-1> ',$wwt3*100,' %&nbsp;&nbsp;</td>
      <td>&nbsp;&nbsp;&nbsp;<font size=-1>',$ss3,'</td>
      <td align=right><font size=-1> ',$swt3*100,' %&nbsp;&nbsp;</td>
     </tr>
     <tr>
      <td bgcolor=white colspan=2><font size=-1><b>Dewpoint Stations</b></td>
      <td bgcolor=white colspan=2><font size=-1><b>Time-to-Peak Stations</b></td>
     </tr>
     <tr>
      <td>&nbsp;&nbsp;&nbsp;<font size=-1>',$ds1,'</td>
      <td align=right><font size=-1> ',$dwt1*100,' %&nbsp;&nbsp;</td>
      <td>&nbsp;&nbsp;&nbsp;<font size=-1>',$ts1,'</td>
      <td align=right><font size=-1> ',$twt1*100,' %&nbsp;&nbsp;</td>
     </tr>
     <tr>
      <td>&nbsp;&nbsp;&nbsp;<font size=-1>',$ds2,'</td>
      <td align=right><font size=-1> ',$dwt2*100,' %&nbsp;&nbsp;</td>
      <td>&nbsp;&nbsp;&nbsp;<font size=-1>',$ts2,'</td>
      <td align=right><font size=-1> ',$twt2*100,' %&nbsp;&nbsp;</td>
     </tr>
     <tr>
      <td>&nbsp;&nbsp;&nbsp;<font size=-1>',$ds3,'</td>
      <td align=right><font size=-1> ',$dwt3*100,' %&nbsp;&nbsp;</td>
      <td>&nbsp;&nbsp;&nbsp;<font size=-1>',$ts3,'</td>
      <td align=right><font size=-1> ',$twt3*100,' %&nbsp;&nbsp;</td>
     </tr>
    </table>
    <br><br>
    <font size=-1>
     ',$modhead,' ',$modfile,'
    </font>
   </center>
';
  }	# if ($interpolated)
  else {
# ************************************ not INTERPOLATED *******************
    print "
   </center>
   <pre>
$comment
@comments
   </pre>
";
  }

goto goop;

### Display PAR file ###
### limit to IP of 166.2.22.* and 128.111.110.220 [Chris Pyke pyke@icess.ucsb.edu]
   $user_ID=$ENV{'REMOTE_ADDR'};
   $user_really=$ENV{'HTTP_X_FORWARDED_FOR'};          # DEH 11/14/2002
   $user_ID=$user_really if ($user_really ne '');      # DEH 11/14/2002
   if (index($user_ID,'166.2.22.') == 0 ||             # Moscow lab
       index($user_ID,'199.133.140.156') == 0) {       # Corey Moffett 3/2002
print "
<hr><pre><font face='courier'>
";
   open PAR, "<$climateFile";
   while (<PAR>) {
    print $_
   }
 }
###
goop:

print "
  </center>
   <font size=-2>
    <hr>
    <b>descpar</b> version $version
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
