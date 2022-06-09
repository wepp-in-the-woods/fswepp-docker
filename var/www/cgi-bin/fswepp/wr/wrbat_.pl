#! /fsapps/fssys/bin/perl
#
# wrb.pl
#
# WEPP:Road batch checker
# 31 January 2002
# David Hall, USDA Forest Service, Rocky Mountain Research Station
#

   $batch=1;
   $debug=0;
   $version = "2002.07.03";
   $host = $ENV{REMOTE_HOST};
   if ($host eq "") {$host = 'unknown'}

#=========================================================================

   &ReadParse(*parameters);
   $action=$parameters{'submit'};
   $spread = $parameters{'spread'};
#!
#   $spread = 'ib 12 100 4 45 12 75 20 n l 20 comment 1';
   $CL=$parameters{'Climate'};         # get Climate (file name base)
   $ST=$parameters{'SoilType'};
   $units=$parameters{'units'};
   $years=$parameters{'years'};
   $climyears=$parameters{'climyears'};
   $check = 0;
   $check = 1 if ($action =~ /check/);

# ########### PARSE TEXTAREA data and check

     print "Content-type: text/html\n\n";
     print "<HTML>\n";
     print "<HEAD>\n";
     print "<TITLE>WEPP:Road batch parameters</TITLE>\n";
     print "</HEAD>\n";
     print '<BODY background="http://',$wepphost,
          '/fswepp/images/note.gif" link="#ff0000">
<font face="Arial, Geneva, Helvetica">';
     print "<blockquote>
<CENTER><H1>WEPP:Road batch parameters</H1></CENTER><P><HR>
";
 if ($debug) {
   print "   Climate: $CL
   Soil texture: $ST
   Units: $units
   Years: $years
   Batch: $batch
   "
 }

display_errors:

 if ($batch) {
   $spread = $parameters{'spread'};
#!
#   $spread = 'ib 12 100 4 45 12 75 20 n l 20 comment 1';
   $spread .= "\n";
   $spreadx = &detag($spread);
 }
#   print $spreadx;
   $num_invalid_records=0;

 if ($check) {print "
  <table border=2>
   <tr>
    <th rowspan=2 bgcolor=\"cyan\">run
    <th rowspan=2 bgcolor=\"cyan\">Design
    <th colspan=3 bgcolor=\"cyan\">Road
    <th colspan=2 bgcolor=\"cyan\">Fill
    <th colspan=2 bgcolor=\"cyan\">Buffer
    <th rowspan=2 bgcolor=\"cyan\">Road<br>surface
    <th rowspan=2 bgcolor=\"cyan\">Traffic<br>level
    <th rowspan=2 bgcolor=\"cyan\">Rock<br>fragment
    <th rowspan=2 bgcolor=\"cyan\">Comments
   <tr><th bgcolor=\"cyan\">gradient
    <th bgcolor=\"cyan\">length
    <th bgcolor=\"cyan\">width
    <th bgcolor=\"cyan\">gradient
    <th bgcolor=\"cyan\">length
    <th bgcolor=\"cyan\">gradient
    <th bgcolor=\"cyan\">length
</tr> "
 }
 $count=0;
 if ($batch) {
   $ind=index($spreadx,"\n");
   while ($ind>1) {
     $head = substr($spreadx,0,$ind);
     $spreadx = substr($spreadx,$ind+1);
#     print "line $count: $head ";
     $count+=1;
     @inputs[$count] = $head;
     $num_invalid_fields=0;
     ($design,$rg,$rl,$rw,$fg,$fl,$bg,$bl,$rs,$tl,$rf,$comments)=split(' ',$head,12);
     if ($check) {
       print "<tr>";
       print "<td bgcolor=\"cyan\">$count";
     }
     $valid = &validate_design($design);&printfield($check,$valid,$design);
     $valid = &validate_slope($rg); &printfield($check,$valid,$rg);
     $valid = &validate_length($rl); &printfield($check,$valid,$rl);
     $valid = &validate_length($rw); &printfield($check,$valid,$rw);
     $valid = &validate_slope($fg); &printfield($check,$valid,$fg);
     $valid = &validate_length($fl); &printfield($check,$valid,$fl);
     $valid = &validate_slope($bg); &printfield($check,$valid,$bg);
     $valid = &validate_length($bl); &printfield($check,$valid,$bl);
     $valid = &validate_surface($rs); &printfield($check,$valid,$rs);
     $valid = &validate_traffic($tl); &printfield($check,$valid,$tl);
     $valid = &validate_rock($rf); &printfield($check,$valid,$rf);
     if ($check) {print "<td>$comments</tr>\n"}
     $num_invalid_records+=1 if $num_invalid_fields > 0;
     $ind=index($spreadx,"\n")
   }
 }
 else {
#   $design=
#   $rg=
#   $rl=
#   $rw=
#   $fg=
#   $fl=
#   $bg=
#   $bl=
#   $rs=
#   $tl=
#   $rf=
#   $comments=
     $valid = &validate_design($design);&printfield($check,$valid,$design);
     $valid = &validate_slope($rg); &printfield($check,$valid,$rg);
     $valid = &validate_length($rl); &printfield($check,$valid,$rl);
     $valid = &validate_length($rw); &printfield($check,$valid,$rw);
     $valid = &validate_slope($fg); &printfield($check,$valid,$fg);
     $valid = &validate_length($fl); &printfield($check,$valid,$fl);
     $valid = &validate_slope($bg); &printfield($check,$valid,$bg);
     $valid = &validate_length($bl); &printfield($check,$valid,$bl);
     $valid = &validate_surface($rs); &printfield($check,$valid,$rs);
     $valid = &validate_traffic($tl); &printfield($check,$valid,$tl);
     $valid = &validate_rock($rf); &printfield($check,$valid,$rf);
 }

 if ($check) {
   print "  </table>
   <p>
    $num_invalid_records invalid record(s) out of $count record(s)
    <p>
    <center><hr>
     <a href=\"JavaScript:window.history.go(-1)\">
     <img src=\"http://',$wepphost,'/fswepp/images/rtis.gif\"
     alt=\"Return to input screen\" border=\"0\" aligh=center></A>
     <BR><HR>
    </center>
   </body>
  </html>
  ";
  die;
}

  $check=1;
  goto display_errors if ($num_invalid_records > 0);
  die if $num_invalid_records > 0;

# print form *********************************

#  print '
#  <form name="wrbat" action="http://forest.moscowfsl.wsu.edu/cgi-bin/fswepp/wrbat.pl" method="post">
#  <TEXTAREA name="spread" cols="70" rows="16">',$spread,'</TEXTAREA>
#  <input type="hidden" name="checked" value="x">
#  <input type="submit" value="submit">
# </form>
#';

# =======================  Run WEPP  =========================

#   $outputf=$parameters{'Full'};

   if ($platform eq "pc") {
     if (-e 'd:/fswepp/working') {$working = 'd:\\fswepp\\working'}
     elsif (-e 'c:/fswepp/working') {$working = 'c:\\fswepp\\working'}
     else {$working = '..\\working'}
     $newSoilFile  = "$working\\wrwepp.sol";
     $responseFile = "$working\\wrwepp.in";
     $outputFile   = "$working\\wrwepp.out";
     $stoutFile    = "$working\\wrwepp.sto";
     $sterFile     = "$working\\wrwepp.err";
     $slopeFile    = "$working\\wrwepp.slp";
     $soilPath     = 'data\\';
     $manPath      = 'data\\';
   }
   else {
     $working = '../working';
     $unique='wepp' . '-' . $$;
     $newSoilFile  = "$working/" . $unique . '.sol';
     $responseFile = "$working/" . $unique . '.in';
     $outputFile   = "$working/" . $unique . '.out';
     $stoutFile    = "$working/" . $unique . '.stout';
     $sterFile     = "$working/" . $unique . '.sterr';
     $slopeFile    = "$working/" . $unique . '.slp';
     $soilPath     = 'data/';
     $manPath      = 'data/';
   }

   print '
   <blockquote>
   <CENTER>
   <font face="Arial, Geneva, Helvetica">
   <table width="90%">
     <tr><td><a href="JavaScript:window.history.go(-1)">
     <img src="http://',$wepphost,'/fswepp/images/road4.gif"
        align=left border=1
        width=50 height=50
        alt="Return to WEPP:Road input screen" 
        onMouseOver="window.status=',"'Return to WEPP:Road input screen'",'; return true"
        onMouseOut="window.status=',"' '",'; return true">
   </a>
   <td align=center>
     <hr><H2>WEPP:Road Results</H2><hr>
    <td>
       <A HREF="http://',$wepphost,'/fswepp/docs/wroadimg.html#wrout">
       <IMG src="http://',$wepphost,'/fswepp/images/ipage.gif"
        align="right" alt="Read the documentation" border=0
        onMouseOver="window.status=\'Read the documentation\'; return true"
        onMouseOut="window.status=\' \'; return true"></a>
    </table>
   </CENTER>
   ';

 &CreateCligenFile;	# take out of loop (remember file name)

 for $record (1..$count) {
   if ($batch) {
     ($slope,$URS,$URL,$URW,$UFS,$UFL,$UBS,$UBL,$surface,$traffic,$UBR,$comments)=split(' ',@inputs[$record],12);
   }
   $URL*=1;           # Road length -- buffer spacing (free)
   $URS*=1;           # Road gradient (free)
   $URW*=1;           # road width (free)
   $UFL*=1;           # fill length (free)
   $UFS*=1;           # fill steepness (free)
   $UBL*=1;           # Buffer length (free)
   $UBS*=1;           # Buffer steepness (free)
   $UBR*=1;           # Rock fragment percentage
#   $slope=$parameters{'SlopeType'};    # slope type (outunrut, inbare, inveg, outrut)
#   $design=$slope;
   if ($slope eq "ou")  {
     $design="Outsloped, unrutted";
     $slopex = 'outsloped unrutted'
   }
   elsif ($slope eq "ib") {
     $design="Insloped, bare ditch";
     $slopex = 'insloped bare'
   }
   elsif ($slope eq "iv") {
     $design="Insloped, vegetated or rocked ditch";
     $slopex = 'insloped vegetated'
   }
   elsif ($slope eq "or") {
     $design="Outsloped, rutted";
     $slopex = 'outsloped rutted'
  }

  if    ($traffic eq 'l') {$traffic = 'low'}
  elsif ($traffic eq 'h') {$traffic = 'high'}
  elsif ($traffic eq 'n') {$traffic = 'none'}

  if    ($surface eq 'n') {$surface = 'native'} 
  elsif ($surface eq 'g') {$surface = 'graveled'} 
  elsif ($surface eq 'p') {$surface = 'paved'} 

   if    ($ST eq 'clay') {$STx = 'clay loam'} 
   elsif ($ST eq 'silt') {$STx = 'silt loam'} 
   elsif ($ST eq 'sand') {$STx = 'sandy loam'} 
   elsif ($ST eq 'loam') {$STx = 'loam'} 

   if ($debug) {
   print @inputs[1],"<br>\nUnits: $units<br>
   Submit action: $action<br>
   Years: $years<br>
   ST: $ST<br>
   Surface: $surface<br>
   Traffic: $traffic<br>
   URL: $URL<br>
   URS: $URS<br>
   URW: $URW<br>
   UFS: $UFS<br>
   UFL: $UFL<br>
   UBS: $UBS<br>
   UBL: $URL<br>
   Slope: $slope<br>
   Design: $design<br>
   I am '$me', units '$units' <br>
"}

   $rcin = &checkInput;
   if ($rcin >= 0) {

       $soilFilefq = $soilPath . &soilfilename;
       $manfile = &manfilename;

       open NEWSOILFILE, ">$newSoilFile";
         print NEWSOILFILE &CreateSoilFile;
       close NEWSOILFILE;
       if ($debug) {print "<pre>creating soil file: $newSoilFile\n", $soilFileBody, "</pre>\n"}
       &CreateSlopeFile;
#      &CreateCligenFile;	# take out of loop (remember file name)
       &CreateResponseFile;
#      $stoutFile = 'working' . $unique . ".sto";
#      $sterFile = 'working' . $unique . ".ste";
       if ($platform eq "pc") {
         @args = ("..\\wepp <$responseFile >$stoutFile"); 
       }
       else {
         @args = ("nice -20 ../wepp <$responseFile >$stoutFile 2>$sterFile");
       }
       system @args;

#       unlink $climateFile;    # be sure this is right file .....  # out of loop............

       open weppstout, "<$stoutFile";

       $found = 0;
       while (<weppstout>) {
         if (/SUCCESSFUL/) {
           $found = 1;
           last;
         }
       }  
       close (weppstout);

       if ($found == 0) {       # unsuccessful run -- search STDOUT for error message
         open weppstout, "<$stoutFile";
         while (<weppstout>) {
            if (/ERROR/) {
              $found = 2;
              print "<font color=red>\n";
              $_ = <weppstout>;  $_ = <weppstout>; 
              $_ = <weppstout>;  print;
              $_ = <weppstout>;  print;
              print "</font>\n";
              last;
            }
         }
         close (weppstout);
       }

       if ($found == 0) {
         open weppstout, "<$stoutFile";
         while (<weppstout>) {
           if (/error #/) {
             $found = 4;
             print "<font color=red>\n";
             print;
             print "</font>\n";
             last;
           }
         }
         close (weppstout);
       }

       if ($found == 0) {
         open weppstout, "<$stoutFile";
           while (<weppstout>) {
             if (/\*\*\* /) {
             $found = 3;
             print "<font color=red>\n";
             $_ = <weppstout>; print;
             $_ = <weppstout>; print;
             $_ = <weppstout>; print;
             $_ = <weppstout>; print;
             print "</font>\n";
             last;
           }
         }
         close (weppstout);
       }

       if ($found == 0) {
         open weppstout, "<$stoutFile";
         while (<weppstout>) {
           if (/MATHERRQQ/) {
             $found = 5;
             print "<font color=red>\n";
             print 'WEPP has run into a mathematical anomaly.<br>
             You may be able to get around it by modifying the geometry slightly;
             try changing road length by 1 foot (1/2 meter) or so.
             ';
             $_ = <weppstout>; print;
             print "</font>\n";
             last;
           }
         }
         close (weppstout);
       }

       if ($found == 1) {       # Successful run -- get actual WEPP version number
         open weppout, "<$outputFile";
         $ver = 'unknown';
         while (<weppout>) {
           if (/VERSION/) {
              $weppver = $_;
              last;
           }
         }


         while (<weppout>) {     # read actual climate file used from WEPP output
           if (/CLIMATE/) {
             $a_c_n=<weppout>;
             $actual_climate_name=substr($a_c_n,index($a_c_n,":")+1,40);
             $climate_name = $actual_climate_name;
             last;
           }
         }

         while (<weppout>) {
           if (/RAINFALL AND RUNOFF SUMMARY/) {
             $_ = <weppout>; #      -------- --- ------ -------
             $_ = <weppout>; # 
             $_ = <weppout>; #       total summary:  years    1 -    1
             $_ = <weppout>; # 
             $_ = <weppout>; #         71 storms produced                          346.90 mm of precipitation
             $storms = substr $_,1,10;
             $_ = <weppout>; #          3 rain storm runoff events produced          0.00 mm of runoff
             $rainevents = substr $_,1,10;
             $_ = <weppout>; #          2 snow melts and/or
             $snowevents = substr $_,1,10;
             $_ = <weppout>; #              events during winter produced            0.00 mm of runoff
             $_ = <weppout>; # 
             $_ = <weppout>; #      annual averages
             $_ = <weppout>; #      ---------------
             $_ = <weppout>; #
             $_ = <weppout>; #        Number of years                                    1
             $_ = <weppout>; #        Mean annual precipitation                     346.90    mm
             $precip = substr $_,51,10;
             $_ = <weppout>; $rro = substr $_,51,10;   # print; 
             $_ = <weppout>; # print;
             $_ = <weppout>; $sro = substr $_,51,10;   # print; 
             $_ = <weppout>; # print;
             last;
           }
         }

         while (<weppout>) {
           if (/AREA OF NET SOIL LOSS/) {
             $_ = <weppout>;             $_ = <weppout>;
             $_ = <weppout>;             $_ = <weppout>;
             $_ = <weppout>;             $_ = <weppout>; # print;
             $_ = <weppout>; # print;
             $_ = <weppout>; # print;
             $_ = <weppout>; # print;
             $_ = <weppout>; # print;
             $syr = substr $_,17,7;  
             $effective_road_length = substr $_,9,9;
#  area = val(mid$($_,9,7))
#  sed = val(mid$($_,16,9))
#  rsv = area * sed
             last;
           }
         }

         while (<weppout>) {
           if (/OFF SITE EFFECTS/) {
             $_ = <weppout>;             $_ = <weppout>;
#            $_ = <weppout>; $syp = substr $_,50,9;   # pre-WEPP 98.4
             $_ = <weppout>; $syp = substr $_,49,10;   # pre-WEPP 98.4
#            $_ = <weppout>; if ($syp eq "") {$syp = substr $_,10,9} # off-site yield
#            $_ = <weppout>; if ($syp eq "") {$syp = substr $_,9,10} # off-site yield
             $_ = <weppout>; if ($syp eq "") {
                                              @sypline = split ' ',$_;
                                              $syp = @sypline[0];
                                             }
             $_ = <weppout>;             $_ = <weppout>;
             last;
           }
         }
         close (weppout);

         $storms+=0;
         $rainevents+=0;
         $snowevents+=0;
         $precip+=0;
         $rro+=0;
         $sro+=0;
         $syr+=0;
         $syp+=0;
         $syra=$syr * $effective_road_length * $WeppRoadWidth;
         $sypa=$syp * $WeppRoadWidth;

        if ($surface eq 'graveled') {$URR = 65; $UFR = ($UBR+65)/2}
	elsif ($surface eq 'paved') {$URR = 95; $UFR = ($UBR+65)/2}
        else {$URR = $UBR; $UFR = $UBR}

         print "
<center>
<table border=1>
   <tr><th colspan=8 bgcolor=#85D2D2>INPUTS
   <tr><td>$climate_name
       <td><td width=20>
       <td><th>Gradient<br> (%)
       <th>Length<br> ($units)
       <th>Width<br> ($units)
       <th>Rock<br> (%)
   <tr><td>$design
       <td><td><th align=left>Road
       <td align=right>$URS
       <td align=right>$URL
       <td align=right>$URW
       <td align=right>$URR
   <tr><td>$STx with $UBR% rock fragments
       <td><td><th align=left>Fill
       <td align=right>$UFS
       <td align=right>$UFL
       <td align=right>
       <td align=right>$UFR
   <tr><td>$surface surface, $traffic traffic <td><td><th align=left>Buffer
       <td align=right>$UBS
       <td align=right>$UBL
       <td align=right>
       <td align=right>$UBR
   <td>
</table>
<p>
";
         if ($units eq "m") {
           $precipunits = "mm"; 
           $sedunits = "kg";
           $pcpfmt = '%.0f';
         }
         else {					# convert WEPP metric results to in and lb
           $precipunits = "in";
           $precip      = $precip / 25.4;
           $rro         = $rro    / 25.4;
           $sro         = $sro    / 25.4;
           $sedunits    = "lb";
           $syra        = $syra * 2.2046;
           $sypa        = $sypa * 2.2046;
           $pcpfmt = '%.2f';
         }
#        $precipf = sprintf "%.0f", $precip;
#        $rrof = sprintf "%.0f", $rro;
#        $srof = sprintf "%.0f", $sro;
         $precipf = sprintf $pcpfmt, $precip;
         $rrof = sprintf $pcpfmt, $rro;
         $srof = sprintf $pcpfmt, $sro;
         $syraf = sprintf "%.2f", $syra;
         $sypaf = sprintf "%.2f", $sypa;

         print "<table cellspacing=8>
   <tr><th colspan=5 bgcolor=#85D2D2>$years2sim - YEAR MEAN ANNUAL AVERAGES
   <tr><td align=right>$precipf<td>$precipunits<td>precipitation from
       <td align=right>$storms<td>storms
   <tr><td align=right>$rrof<td>$precipunits<td>runoff from rainfall from
       <td align=right>$rainevents<td>events
   <tr><td align=right>$srof<td>$precipunits<td>runoff from snowmelt or winter rainstorm from 
       <td align=right>$snowevents<td>events
   <tr><td align=right>$syraf<td>$sedunits<td>road prism erosion
   <tr><td align=right>$sypaf<td>$sedunits<td>sediment leaving buffer

<!--   <tr><td>$syr<td>$effective_road_length<td>$WeppRoadWidth<td> syra=syr x rdlen x rdwidth
   <tr><td>$syp<td>sypa=syp x rdwidth
-->
</table>
<hr width=50%>
";
}

       }
       else {           # ($found != 1)
#        print "<p>\nSomething has gone awry!\n<p><hr><p>\n";
         print "<p>\nI'm sorry; WEPP did not run successfully.
          WEPP's error message follows:  \n<p><hr><p>\n";
       }

# ---------------------  WEPP summary output  --------------------

       if ($outputf==1) {
         print '<CENTER><H2>WEPP output</H2></CENTER>';
         print '<font face=courier><PRE>';
         open weppout, "<$outputFile";
         while (<weppout>){
           print;
         }
         close weppout;
         print '</PRE></font>
<p><center><hr>
<a href="JavaScript:window.history.go(-1)">
<img src="http://',$wepphost,'/fswepp/images/rtis.gif"
     alt="Return to input screen" border="0" aligh=center></A>
<BR><HR></center>
';
       }
       print "<br>\n";
   }   #   if ($rcin >= 0)

print '
</center>
<p>
<center>
<a href="JavaScript:window.history.go(-1)">
<img src="http://',$wepphost,'/fswepp/images/rtis.gif"
  alt="Return to input screen" border="0" align=center></A>
<BR>
</center>
<hr>
<table width=90%>
<tr><td>WEPP:Road version <a href="/fswepp/history/wrrver.html">',
  $version,'</a> based on WEPP ',$weppver,'<br>
by 
	 <A HREF="mailto:dehall@fs.fed.us">Hall</A> and 
	 <A HREF="mailto:darrellanderson@fs.fed.us">Anderson</A>;
     Project leader Bill Elliot<BR>
     USDA Forest Service, Rocky Mountain Research Station, Moscow, ID
83843
    <br>';    &printdate; print '
    <td>
      <a href="http://',$wepphost,'/fswepp/comments.html"  onClick="return confirm(\'You need to be connected to the Internet to e-mail comments. Shall I try?\')">
      <img src="http://',$wepphost,'/fswepp/images/epaemail.gif" align="right" border=0></a>
</table>
</BODY>
</HTML>
';

#   unlink <"$working/$unique.*">;

###   unlink $responseFile;
###   unlink $outputFile;
###   unlink $stoutFile;
###   unlink $sterFile;
###   unlink $slopeFile;

#  record activity in WEPP:Road log (if running on remote server)

   if (lc($wepphost) ne "localhost") {
     open WRLOG, ">>../working/wr.log";
       $host = $ENV{REMOTE_HOST};
       if ($host eq "") {$host = $ENV{REMOTE_ADDR} };
       print WRLOG "$host\t";
       printf WRLOG "%0.2d:%0.2d ", $hour, $min;
       print WRLOG $ampm[$ampmi],"  ",$days[$wday]," ",$months[$mon]," ",$mday,", ",$year+1900, "\t";
       print WRLOG $years2sim,"\t";
       print WRLOG $climate_name,"\n";
     close WRLOG;
   }

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
    $in[$i] =~ s/\+/ /g;			# Convert pluses to spaces
    ($key, $val) = split(/=/,$in[$i],2);	# Split into key and value
    $key =~ s/%(..)/pack("c",hex($1))/ge;	# Convert %XX from hex numbers to alphanumeric
    $val =~ s/%(..)/pack("c",hex($1))/ge;
    $in{$key} .= "\0" if (defined($in{$key}));  # \0 is the multiple separator
    $in{$key} .= $val;
  }
  return 1;
 }

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
    print " ",$mday,", ",$year+1900, " GMT<br>\n";
    if (lc($wepphost) ne "localhost") {
      $ampmi = 0;
      ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime;
      if ($hour == 12) {$ampmi = 1}
      if ($hour > 12) {$ampmi = 1; $hour = $hour - 12}
      printf "%0.2d:%0.2d ", $hour, $min;
      print $ampm[$ampmi],"  ",$days[$wday]," ",$months[$mon];
      print " ",$mday,", ",$year+1900, " Pacific Time";
    } 
}

#---------------------------

sub CreateSlopeFile {

# create slope file from specified geometry

     $userRoadSlope  = $URS / 100;		# road slope in decimal percent
     $userFillSlope  = $UFS / 100;
     $userBuffSlope  = $UBS / 100;
     if ($units eq 'm') {
       $userRoadWidth  = $URW;			# road width in meters
       $userRoadLength = $URL;
       $userFillLength = $UFL;
       $userBuffLength = $UBL;
     }
     else {$tom = 0.3048;
       $userRoadWidth  = sprintf "%.2f", $URW * $tom;
       $userRoadLength = sprintf "%.2f", $URL * $tom;
       $userFillLength = sprintf "%.2f", $UFL * $tom;
       $userBuffLength = sprintf "%.2f", $UBL * $tom;
     }
     $WeppRoadSlope  = $userRoadSlope;
     $WeppRoadLength = $userRoadLength;
     $WeppFillSlope  = $userFillSlope;
     $WeppFillLength = $userFillLength;
     $WeppBuffSlope  = $userBuffSlope;
     $WeppBuffLength = $userBuffLength;
     if ($WeppRoadLength < 1) {$WeppRoadLength=1}				# minimum 1 m road length

     if ($slope eq 'outunrut') {
       $outslope = 0.04;
       $WeppRoadSlope = sqrt($outslope * $outslope + $WeppRoadSlope * $WeppRoadSlope);		# 11/1999
       $WeppRoadLength = $userRoadWidth  * $WeppRoadSlope / $outslope;
       $WeppRoadWidth =  $userRoadLength * $userRoadWidth / $WeppRoadLength;
     }
     else {
       $WeppRoadWidth = $userRoadWidth;
     }

     open (SlopeFile, ">".$slopeFile);
       print SlopeFile "97.3\n";           # datver
       print SlopeFile "# Slope file for $slope by WEPP:Road Interface\n";
       print SlopeFile "3\n";              # no. OFE
       print SlopeFile "100 $WeppRoadWidth\n";          # aspect; profile width			# 11/1999
                                   # OFE 1 (road)
       printf SlopeFile "%d  %.2f\n", 2,$WeppRoadLength;     # no. points, OFE length
       printf SlopeFile "%.2f, %.2f  ", 0,$WeppRoadSlope;    # dx, gradient
       printf SlopeFile "%.2f, %.2f\n", 1,$WeppRoadSlope;    # dx, gradient
                                   # OFE 2 (fill)
       printf SlopeFile "%d  %.2f\n",   3,   $WeppFillLength; # no. points, OFE length
       printf SlopeFile "%.2f, %.2f  ", 0,   $WeppRoadSlope;  # dx, gradient
       printf SlopeFile "%.2f, %.2f  ", 0.05,$WeppFillSlope;  # dx, gradient
       printf SlopeFile "%.2f, %.2f\n", 1,   $WeppFillSlope;  # dx, gradient
                                   # OFE 3 (buffer)
       printf SlopeFile "%d  %.2f\n",   3,   $WeppBuffLength; # no. points, OFE length
       printf SlopeFile "%.2f, %.2f  ", 0,   $WeppFillSlope;  # dx, gradient
       printf SlopeFile "%.2f, %.2f  ", 0.05,$WeppBuffSlope;  # dx, gradient
       printf SlopeFile "%.2f, %.2f\n", 1,   $WeppBuffSlope;  # dx, gradient
     close SlopeFile;
     return $slopeFile;
 }

sub CreateResponseFile {

     print "creating $responseFile<br>\n";
     open (ResponseFile, ">$responseFile");
       print ResponseFile "97.3\n";        # datver
       print ResponseFile "y\n";           # not watershed
       print ResponseFile "1\n";           # 1 = continuous
       print ResponseFile "1\n";           # 1 = hillslope
       print ResponseFile "n\n";           # hillsplope pass file out?
       print ResponseFile "1\n";           # 1 = abreviated annual out
       print ResponseFile "n\n";           # initial conditions file?
       print ResponseFile "$outputFile","\n";  # soil loss output file
       print ResponseFile "n\n";           # water balance output?
       print ResponseFile "n\n";           # crop output?
       print ResponseFile "n\n";           # soil output?
       print ResponseFile "n\n";           # distance/sed loss output?
       print ResponseFile "n\n";           # large graphics output?
       print ResponseFile "n\n";           # event-by-event out?
       print ResponseFile "n\n";           # element output?
       print ResponseFile "n\n";           # final summary out?
       print ResponseFile "n\n";           # daily winter out?
       print ResponseFile "n\n";           # plant yield out?
       print ResponseFile $manPath . $manfile,"\n";      # management file name
       print ResponseFile $slopeFile,"\n";          # slope file name
       print ResponseFile $climateFile,"\n";        # climate file name
       print ResponseFile $newSoilFile, "\n";        # soil file name
       print ResponseFile "0\n";           # 0 = no irrigation
       print ResponseFile "$years2sim\n";  # no. years to simulate
       print ResponseFile "0\n";           # 0 = route all events
     close ResponseFile;
     return $responseFile;
}

 sub CreateSoilFile {                                                          
                                                                               
# Read a WEPP:Road soil file template and create a usable soil file.
# File may have 'urr', 'ufr' and 'ubr' as placeholders for rock fragments
# percentage
# Adjust road surface Kr downward for traffic levels of 'low' or 'none'

# David Hall and Darrell Anderson
# November 26, 2001

# uses: $soilFilefq   fully qualified input soil file name
#       $surface      native, graveled, paved
#       $traffic      High, Low, None
#       $UBR          user-specified rock fragment decimal percentage for buffer
# sets: $URR          calculated rock fragment decimal percentage for road
#       $UFR          calculated rock fragment decimal percentage for fill

   my $body;
   my $in;
   my ($pos1, $pos2, $pos3, $pos4);
   my ($ind, $left, $right);

   open SOILFILE, "<$soilFilefq";                                              
   print "incoming soil file: $soilFilefq\n";

   if ($surface eq 'graveled') {$URR = 65; $UFR = ($UBR+65)/2}
   elsif ($surface eq 'paved') {$URR = 95; $UFR = ($UBR+65)/2}
   else {$URR = $UBR; $UFR = $UBR}

# modify 'Kr' for 'no traffic' and 'low traffic'

 if ($traffic eq 'low' || $traffic eq 'none') {
   $in = <SOILFILE>;
   $body =  $in;     # line 1; version control number - datver
   $in = <SOILFILE>;          # first comment line
   $body .= $in;
   while (substr($in,0,1) eq '#') {   # gobble up comment lines
      $in = <SOILFILE>;
      $body .= $in;
   }
   $in = <SOILFILE>;
   $body .= $in;     # line 3: ntemp, ksflag
   $in = <SOILFILE>;
   $pos1 = index ($in,"'");                 # location of first apostrophe
   $pos2 = index ($in,"'",$pos1+1);  # location of second apostrophe
   $pos3 = index ($in,"'",$pos2+1);  # location of third apostrophe
   $pos4 = index ($in,"'",$pos3+1);  # location of fourth apostrophe
   my $slid_texid = substr($in,0,$pos4+1);  # slid; texid
   my $rest = substr($in,$pos4+1);
   my ($nsl, $salb, $sat, $ki, $kr, $shcrit, $avke) = split ' ', $rest;
   $kr /= 4;
   $body .= "$slid_texid\t";
   $body .= "$nsl\t$salb\t$sat\t$ki\t$kr\t$shcrit\t$avke\n";
 }
   while (<SOILFILE>) {                                                        
     $in = $_;                                                                 
     if (/urr/) {               # user-specified road rock fragment            
#        print 'found urr';                                                    
        $ind = index($in,'urr');                                               
        $left = substr($in,0,$ind);                                            
        $right = substr ($in, $ind+3);                                         
        $in = $left . $URR . $right;                                           
     }                                                                         
     elsif (/ufr/) {            # calculated fill rock fragment            
#        print 'found ufr';                                                    
        $ind = index($in,'ufr');                                               
        $left = substr($in,0,$ind);                                            
        $right = substr ($in, $ind+3);                                         
        $in = $left . $UFR . $right;                                           
     }                                                                         
     elsif (/ubr/) {            # calculated buffer rock fragment          
#        print 'found ubr';                                                    
        $ind = index($in,'ubr');                                               
        $left = substr($in,0,$ind);                                            
        $right = substr ($in, $ind+3);                                         
        $in = $left . $UBR . $right;                                           
     }                                                                         
#     print $in;                                                                
     $body .= $in;                                                    
   }                                                                           
   close SOILFILE;
   return $body;
}

 sub createSoilFile {                                                          
                                                                               
# Read a WEPP:Road soil file template and create a usable soil file.
# File may have 'urr', 'ufr' and 'ubr' as placeholders for rock fragments
# percentage
# Adjust road surface Kr downward for traffic levels of 'low' or 'none'

# David Hall and Darrell Anderson
# November 26, 2001

# uses: $soilFilefq   fully qualified input soil file name
#       $newSoilFile  name of soil file to be created
#       $surface      native, graveled, paved
#       $traffic      High, Low, None
#       $UBR          user-specified rock fragment decimal percentage for buffer
# sets: $URR          calculated rock fragment decimal percentage for road
#       $UFR          calculated rock fragment decimal percentage for fill

   my $in;
   my ($pos1, $pos2, $pos3, $pos4);
   my ($ind, $left, $right);

   open SOILFILE, "<$soilFilefq";                                              
   open NEWSOILFILE, ">$newSoilFile";                                          
                                                                               
   if ($surface eq 'graveled') {$URR = 65; $UFR = ($UBR+65)/2}
   elsif ($surface eq 'paved') {$URR = 95; $UFR = ($UBR+65)/2}
   else {$URR = $UBR; $UFR = $UBR}

# modify 'Kr' for 'no traffic' and 'low traffic'

 if ($traffic eq 'low' || $traffic eq 'none') {
   $in = <SOILFILE>;
   print NEWSOILFILE $in;     # line 1; version control number - datver
   $in = <SOILFILE>;          # first comment line
   print NEWSOILFILE $in;
   while (substr($in,0,1) eq '#') {   # gobble up comment lines
      $in = <SOILFILE>;
      print NEWSOILFILE $in;
   }
   $in = <SOILFILE>;
   print NEWSOILFILE $in;     # line 3: ntemp, ksflag
   $in = <SOILFILE>;
   $pos1 = index ($in,"'");                 # location of first apostrophe
   $pos2 = index ($in,"'",$pos1+1);  # location of second apostrophe
   $pos3 = index ($in,"'",$pos2+1);  # location of third apostrophe
   $pos4 = index ($in,"'",$pos3+1);  # location of fourth apostrophe
   my $slid_texid = substr($in,0,$pos4+1);  # slid; texid
   my $rest = substr($in,$pos4+1);
   my ($nsl, $salb, $sat, $ki, $kr, $shcrit, $avke) = split ' ', $rest;
   $kr /= 4;
   print NEWSOILFILE "$slid_texid\t";
   print NEWSOILFILE "$nsl\t$salb\t$sat\t$ki\t$kr\t$shcrit\t$avke\n";
 }

   while (<SOILFILE>) {                                                        
     $in = $_;                                                                 
     if (/urr/) {               # user-specified road rock fragment            
#        print 'found urr';                                                    
        $ind = index($in,'urr');                                               
        $left = substr($in,0,$ind);                                            
        $right = substr ($in, $ind+3);                                         
        $in = $left . $URR . $right;                                           
     }                                                                         
     elsif (/ufr/) {            # calculated fill rock fragment            
#        print 'found ufr';                                                    
        $ind = index($in,'ufr');                                               
        $left = substr($in,0,$ind);                                            
        $right = substr ($in, $ind+3);                                         
        $in = $left . $UFR . $right;                                           
     }                                                                         
     elsif (/ubr/) {            # calculated buffer rock fragment          
#        print 'found ubr';                                                    
        $ind = index($in,'ubr');                                               
        $left = substr($in,0,$ind);                                            
        $right = substr ($in, $ind+3);                                         
        $in = $left . $UBR . $right;                                           
     }                                                                         
#     print $in;                                                                
     print NEWSOILFILE $in;                                                    
   }                                                                           
   close SOILFILE;                                                             
   close NEWSOILFILE;                                                          
}                                                                              

sub checkInput {

     if ($units eq "m") {
       $lu = "m";
       $minURL = 1;   $maxURL = 300;
       $minURS = 0.1; $maxURS = 40;
       $minURW = 0.3; $maxURW = 100;
       $minUFL = 0.3; $maxUFL = 100;
       $minUFS = 0.1; $maxUFS = 150;
       $minUBL = 0.3; $maxUBL = 300;
       $minUBS = 0.1; $maxUBS = 100;
     }
     else {
       $lu = "ft";
       $minURL = 3;   $maxURL = 1000;
       $minURS = 0.3; $maxURS = 40;
       $minURW = 1;   $maxURW = 300;
       $minUFL = 1;   $maxUFL = 300;
       $minUFS = 0.3; $maxUFS = 150;
       $minUBL = 1;   $maxUBL = 1000;
       $minUBS = 0.3; $maxUBS = 100;
     }
     $minyrs = 1;   $maxyrs = 200;
     $rc = -0;
     print "<font color=red>\n";
     if ($URL < $minURL or $URL > $maxURL) {
       $rc=-1; print "Road length must be between $minURL and $maxURL $lu<BR>\n";}
     if ($URS < $minURS or $URS > $maxURS) {
       $rc=$rc-1; print "Road gradient must be between $minURS and $maxURS %<BR>\n";}
     if ($URW < $minURW or $URW > $maxURW) {
       $rc=$rc-1; print "Road width must be between $minURW and $maxURW $lu<BR>\n";} 
     if ($UFL < $minUFL or $UFL > $maxUFL) {
       $rc=$rc-1; print "Fill length must be between $minUFL and $maxUFL $lu<BR>\n";}
     if ($UFS < $minUFS or $UFS > $maxUFS) {
       $rc=$rc-1; print "Fill gradient must be between $minUFS and $maxUFS %<BR>\n";}
     if ($UBL < $minUBL or $UBL > $maxUBL) {
       $rc=$rc-1; print "Buffer length must be between $minUBL and $maxUBL $lu<BR>\n";}
     if ($UBS < $minUBS or $UBS > $maxUBS) {
      $rc=$rc-1; print "Buffer gradient must be between $minUBS and $maxUBS %<BR>\n";}
     print "</font>\n";
     if ($rc < 0) {print "<p><hr><p>\n"}
     $years2sim=$years*1;
#     if ($years2sim < $minyrs) {$years2sim=$minyrs}
#     if ($years2sim > $maxyrs) {$years2sim=$maxyrs}
     if ($years2sim < 1) {$years2sim=1}
     if ($years2sim > 200) {$years2sim=200}
     return $rc;
}

sub CreateCligenFile {

    $climatePar = "$CL" . '.par';
    $station = substr($CL, length($CL)-8);
    $user_ID = '';
#   $user_ID = 'getalife';
####  next for unix and pc ************************* DEH 2/1/2000
    if ($platform eq 'pc') {
      $station = substr($CL, length($CL)-8);
      $climateFile = "$working\\$station.cli";
      $outfile = $climateFile;
      $rspfile = "$working\\cligen.rsp";
      $stoutfile = "$working\\cligen.out";
    } else {
#     $user_ID = '';
#     $climateFile = '..\\working' . "$station.cli";
      $climateFile = "../working/$unique.cli";
      $outfile = $climateFile;
#     $rspfile = "../working/$user_ID.rsp";
#     $stoutfile = "../working/$user_ID.out";
      $rspfile = "../working/c$unique.rsp";
      $stoutfile = "../working/c$unique.out";
    }
####
    if ($debug) {print "[CreateCligenFile]<br>
      Arguments:    $args<br>
      ClimatePar:   $climatePar<br>
      ClimateFile:  $climateFile<br>
      OutputFile:   $outfile<br>
      ResponseFile: $rspfile<br>
      StandardOut:  $stoutfile<br>
      ";
    }

#  run CLIGEN43 on verified user_id.par file to
#  create user_id.cli file in FSWEPP working directory
#  for specified # years.

    $startyear = 1;
    open RSP, ">" . $rspfile;
      print RSP "4.31\n";
      print RSP $climatePar,"\n";
      print RSP "n do not display file here\n";
      print RSP "5 Multiple-year WEPP format\n";
      print RSP $startyear,"\n";
      print RSP $years,"\n";
      print RSP $climateFile,"\n";
      print RSP "n\n";
    close RSP;
    unlink $climateFile;   # erase previous climate file so CLIGEN'll run
    if ($platform eq 'pc') {
       @args = ("..\\rc\\cligen43.exe <$rspfile >$stoutfile"); 
    }
    else {
#      @args = ("nice -20 ../wepp <$responseFile >$stoutFile 2>$sterFile");
       @args = ("../rc/cligen43 <$rspfile >$stoutfile"); 
    }
    system @args;
    unlink $rspfile;   #  "../working/c$unique.rsp"
    unlink $stoutfile;  #  "../working/c$unique.out"
}

sub printfield {
  my $print=shift(@_);
  my $valid=shift(@_);
  my $value=shift(@_);
  if ($print) {
    if ($valid) {
      print "<td>$value</td>\n"
    }
    else {
      print "<td bgcolor='red'>$value</td>\n"
    }
  }
  else {
  } 
}

sub validate_design {
  my $design=shift(@_);
  if ($design eq 'ib') {$designx = 'insloped, bare ditch'}
  elsif ($design eq 'iv') {$designx='insloped, vegetated ditch'}
  elsif ($design eq 'or') {$designx='outsloped, rutted'}
  elsif ($design eq 'ou') {$designx='outsloped, unrutted'}
  else {$num_invalid_fields+=1; return 0}
  return 1
}

sub validate_traffic {
  my $traffic=shift(@_);
  if ($traffic eq 'l' || $traffic eq 'h' || $traffic eq 'n') {
    return 1
  }
  if ($traffic eq 'low' || $traffic eq 'high' || $traffic eq 'none') {
    return 1
  }
  else {$num_invalid_fields+=1; return 0}
}

sub validate_rock {
  my $rock=shift(@_);
  return 1
}

sub validate_surface {
  my $surface=shift(@_);
  return 1
}

sub validate_slope {

  my $slope=shift(@_);
  my $slope0=$slope+0;

  if ($slope ne $slope0) {
     $num_invalid_fields+=1;
     return 0;
  }
  if ($slope0 < 0 || $slope0 > 200) {
     $num_invalid_fields+=1;
     return 0
  }
  return 1
}

sub validate_length {

  my $length=shift(@_);
  my $length0=$length+0;

  if ($length ne $length0) {
     $num_invalid_fields+=1;
     return 0
  }
  if ($length0 < 0 || $length0 > 200) {
     $num_invalid_fields+=1;
     return 0
  }
  return 1
}

sub detag {

  # convert some HTML tags so they won't muck the HTML code when displayed
  # http://www.biglist.com/lists/xsl-list/archives/199807/msg00094.html

  my $parseString=shift(@_);

# Convert plus's to spaces
#  $parseString =~ s/\+/ /g;

# Convert %xx URLencoded to equiv ASCII characters
#  $parseString =~ s/%(..)/chr(hex($1))/ge;

# Browsers don't display "<" chars as it could represent a tag in
# html. To get round the problem, you need to do the following
# conversion for the 'main' special characters in HTML.

# Convert < > & " to 'html' special characters.
  $parseString =~ s/&/\&amp;/g;  # &amp;   & (The ampersand sign itself)
  $parseString =~ s/</\&lt;/g;   # &lt;    < (less than sign)
  $parseString =~ s/>/\&gt;/g;   # &gt;    > (greater than sign)
  $parseString =~ s/"/\&quot;/g; # &quot;  " (double quote)

  return $parseString;

}

sub soilfilename {
# $surface
# $slope
# $ST

# $surf
# $tauC

     if    (substr ($surface,0,1) eq 'g') {$surf = 'g'}
     elsif (substr ($surface,0,1) eq 'p') {$surf = 'p'}
     else                                 {$surf = ''}

     if    ($slope eq 'inveg'    || $slope eq 'iv') {$tauC ='10'}
     elsif ($slope eq 'inbare'   || $slope eq 'ib') {$tauC = '2'}
     elsif ($slope eq 'outunrut' || $slope eq 'ou') {$tauC = '2'}
     elsif ($slope eq 'outrut'   || $slope eq 'or') {$tauC = '2'}

     if (($slope eq 'inbare' || $slope eq 'ib') && $surf eq 'p') {$tauC = '1'}
     return '3' . $surf . $ST . $tauC . '.sol';
}

sub manfilename {
# $surface
# $slope
# $traffic

# $manfile

  my $manfile;

     if    (substr ($surface,0,1) eq 'g') {$surf = 'g'}
     elsif (substr ($surface,0,1) eq 'p') {$surf = 'p'}
     else                                 {$surf = ''}

     if    ($slope eq 'inveg'   || $slope eq 'iv'){$manfile='3inslope.man'}
     elsif ($slope eq 'inbare'  || $slope eq 'ib'){$manfile='3inslope.man'}
     elsif ($slope eq 'outunrut'|| $slope eq 'ou'){$manfile='3outunr.man'}
     elsif ($slope eq 'outrut'  || $slope eq 'or'){$manfile='3outrut.man'}

     if ($traffic eq 'none') {
       if ($manfile eq '3inslope.man') {$manfile = '3inslopen.man'}
       if ($manfile eq '3outunr.man') {$manfile = '3outunrn.man'}
       if ($manfile eq '3outrut.man') {$manfile = '3outrutn.man'} 
     }
     return $manfile;
}

# ------------------------ end of subroutines ----------------------------
