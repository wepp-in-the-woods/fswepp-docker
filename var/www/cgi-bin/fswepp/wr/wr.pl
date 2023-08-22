#! /usr/bin/perl
#! /fsapps/fssys/bin/perl

#  wr.pl -- WEPP:Road workhorse

#  *** modify for each new year *** $thisdayoff
#
#  FS WEPP
#  USDA Forest Service, Rocky Mountain Research Station
#  Soil & Water Engineering
#  Science by Bill Elliot et alia                      
#  Code by David Hall
#  Reads user input from wepproad.pl, runs CLIGEN and WEPP, parses output files
#  October 1999
#  David Hall, USDA Forest Service, Rocky Mountain Research Station

#  usage: wr.pl (called from web HTML form)
#  parameters:
#     ActionC		# Custom Climate selection submit button
#     ActionW		# Run WEPP selection submit button
#     ActionCD		# Describe Climate selection submit button
#     ActionSD		# Describe Soil selection submit button
#     me
#     units		# English (ft) or metric (m) units
#     achtung		# Alternative action selection from text links
#     Climate
#     climate_name
#    Describe Soil
#      units		
#      SoilType         # Soil type (loam,  sand,  silt,  clay,
#                                   gloam, gsand, gsilt, gclay,
#                                   ploam, psand, psilt, pclay)   # HR 08 99
#      surface		# graveled, paved, or native surface
#      SlopeType	# slope type (outunrut, inbare, inveg, outrut)
#    else
#      units
#      SoilType         # Soil type (loam,  sand,  silt,  clay,
#                                   gloam, gsand, gsilt, gclay,
#                                   ploam, psand, psilt, pclay)   # HR 08 99
#      surface		# graveled, paved, or native surface
#      RL		# Road length -- buffer spacing (free)
#      RS		# Road gradient (free)
#      RW		# road width (free)
#      FL		# fill length (free)
#      FS		# fill steepness (free)
#      BL		# Buffer length (free)
#      BS		# Buffer steepness (free)
#      SlopeType	# slope type (outunrut, inbare, inveg, outrut)
#      Full
#      Slope
#      climate_name
#      years
#  reads environment variables:
#       HTTP_COOKIE
#       REMOTE_ADDR
#       REQUEST_METHOD
#       QUERY_STRING
#       CONTENT_LENGTH
#  reads: 
#    ../wepphost		# localhost or other
#    ../platform		# pc or unix
#    ../climates/*.par		# standard climate parameter files
#    $working/*.par		# personal climate parameter files
#    $soilFilefq		# soil file
#    $slopeFile			# slope file
#    stoutFile			# WEPP run standard output file (error messages)
#    outputFile			# WEPP run summary output file
#    $working\$user_ID.out	# CLIGEN standard output file
#  writes:
#    ../working/wr.log
#    $slopeFile			# slope file
#    $working\$user_ID.rsp	# CLIGEN response file
#  erases:
#    $working\$station.cli	# CLIGEN output file
#  calls:
#    ../rc/rockclim.pl -server -i$me -u$units $wepproad		# custom
#    ../rc/descpar.pl $CL $units $wepproad			# Describe Climate
#    custom.sol
#    wepproad.sol						# Describe Soil
#    /cgi-bin/fswepp/wr/logstuffwr.pl
#    ..\rc\cligen43.exe <$rspfile >$stoutfile
#    ..\wepp <$responseFile >$stoutFile

   $| = 1;   # flush output buffers

## BEGIN HISTORY ####################################################
# WEPP:Road Version History

  $version = '2023.08.16'; # docker refactor
#  $version = '2015.03.02';	# Remove Provisional proviso
#  $version = '2012.12.31';	# complete move to year-based logging (2012 through 2020)
#  $version = '2012.11.20';	# Revise hisory display
#  $version = "2011.03.25";	# Allow WEPP 2010 executable run
#  $version = "2011.04.12";	# CRLF of results file also broke sediment delivery parse -- fixed (needed a "chomp" for $syp)
#  $version = "2011.04.12";	# Fixed another break in 2011, CRLF effect of results file broke Javascript of display of files
#    2011.03.29 DEH Oops, I broke it Friday with the 2000/2010 option. Fixed.
#  $version = "2011.03.25";	# Select WEPP2000 or WEPP2010 added (altho calling screen not modified to specify)
#  $version = "2009.10.13";	# Change display of vegetation file to allow full file display (had been truncated for brevity)
#  $version = "2009.02.23";	# Add WEPP version option, Reduce baseline interrill erodibility (k<sub>i</sub>) for low- and no-traffic conditions
#  $version = "2008.06.04";	# Record Lat/Long to wr.log
#  $version = "2006.09.18";	# Reformat INPUT report, change extended to WEPP results, paint results table, move calculated %rock, Remove you must be connected to the Internet, shall I try? message on comment link
#  $version = "2006.09.14";	# Report user climate parameters
#  $version = "2006.02.23";	# Print $unique in output and in title of each file listing popup; unlink $newSoilFile
#!   2005.07.14 DEH Write climate name to working/lastclimate.txt
#  $version = "2004.01.06";	# reduce Ki to 25% for low- and no-traffic
#    24 Dec 2003 DEH move wrdev to wr and change internal pointers
#  $version = "2003.12.19";	# Print almost proper error page for users who skate by the input checks (history popup inactive on error report page)
#    18 Nov 2003 DEH remove "mailto:" links (link to personnel pages)
#  $version = "2003.1114";	# logstuff.pl to logstuffwr.pl, Adjust critical shear values for some soil files, Report traffic level and rock content inputs, Report derived rock content for road, fill, and buffer, Add link to display WEPP slope input file, Add link to display WEPP soil input file, Add link to display part of WEPP vegetation (management) input file, Add link to display WEPP weather station (climate) parameter file, Add link to display WEPP extended output file, Change results version history to pop-up window, Clean up type faces
#    09 Oct 2003 DEH Extend report from "vegetation" (.man file)
#    2002.11.14  proxy/NAT workaround (HTTP_X_FORWARDED_FOR)
#    09 Jul 2002 DEH messed about...
#    18 Jun 2002 SDA rebuilt ".man" files and corrected "$traffic"
#    21 Dec 2001 SDA changed ("$traffic eq 'none') adjustment
#    05 Nov 2001 SDA changed ".man" files
#    18 Apr 2001 DEH changed "awry" error message
#    07 Mar 2001 DEH add missing "paved" mod (to CreateResponse)
#    06 Mar 2001 DEH from "forest" changes 08/21/00 08/03/00
#       Hakjun Rhee -- add pavement capability
#    13 October 2000 DEH add "align=right" for snowmelt table...
#                  Display WEPP error file if unsuccessful run.
#                  Adjust alignment for snowmelt table
#                  Make unit-conversion consistent with other server (change signif. digits for precipitation
#    2000.08.21 Add pavement capability
#    August 02, 2000 fixed unrutted < -- > rutted management (thanks, Jun!)
#     Modified <pre> to <font face=courier><pre> for Netscape
#     Removed one extraneous </pre>      03/31/2000  DEH
#     Corrected unlink to delete used-up files.
#    07 June 2000     DEH  changed sig. dig. output for English precip, rro, sro;
#                          align right same
#    13 April 2000    DEH  'clay' -> 'clay loam' etc. for input report and wr log
#                        'inbare' -> 'insloped bare' etc. for wr log
#                        removed document.write(lastmodified) -- bad date under NN!
## END HISTORY ######################################################

   $debug = 0;

#  determine which week the model is being run, for recording in the weekly runs log

#   $thisday   -- day of the year (1..365)
#   $thisyear  -- year of the run (ie, 2012)
#   $dayoffset -- account for which day of the week Jan 1 is: -1: Su; 0: Mo; 1: Tu; 2: We; 3: Th; 4: Fr; 5: Sa.

   $thisday = 1 + (localtime)[7];           # $yday, day of the year (0..364)
   $thisyear = 1900 + (localtime)[5];		
   
   if    ($thisyear == 2010) { $dayoffset = 4 }	# Jan 1 is Friday
   elsif ($thisyear == 2011) { $dayoffset = 5 }	# Jan 1 is Saturday
   elsif ($thisyear == 2012) { $dayoffset =-1 }	# Jan 1 is Sunday
   elsif ($thisyear == 2013) { $dayoffset = 1 }	# Jan 1 is Tuesday
   elsif ($thisyear == 2014) { $dayoffset = 2 }	# Jan 1 is Wednesday
   elsif ($thisyear == 2015) { $dayoffset = 3 }	# Jan 1 is Thursday
   elsif ($thisyear == 2016) { $dayoffset = 4 }	# Jan 1 is Friday
   elsif ($thisyear == 2017) { $dayoffset =-1 }	# Jan 1 is Sunday
   elsif ($thisyear == 2018) { $dayoffset = 0 }	# Jan 1 is Monday
   elsif ($thisyear == 2019) { $dayoffset = 1 }	# Jan 1 is Tuesday
   elsif ($thisyear == 2020) { $dayoffset = 2 }	# Jan 1 is Wednesday
   elsif ($thisyear == 2021) { $dayoffset = 4 } # Jan 1 is Friday
   elsif ($thisyear == 2022) { $dayoffset = 5 } # Jan 1 is Saturday
   elsif ($thisyear == 2023) { $dayoffset =-1 } # Jan 1 is Sunday
   elsif ($thisyear == 2024) { $dayoffset = 0 } # Jan 1 is Monday
   elsif ($thisyear == 2025) { $dayoffset = 2 } # Jan 1 is Wednesday
   else                      { $dayoffset = 0 }

   $thisdayoff=$thisday+$dayoffset;
   $thisweek = 1 + int $thisdayoff/7;
#  print "[$dayoffset] Julian day $thisday, $thisyear: week $thisweek\n";

   &ReadParse(*parameters);

   $action=$parameters{'ActionC'} . 
           $parameters{'ActionW'} .
           $parameters{'ActionCD'} .
           $parameters{'ActionSD'};
   $traffic=$parameters{'traffic'};
   chomp $action;
   $me=$parameters{'me'};
   $units=$parameters{'units'};
   $achtung=$parameters{'achtung'};
   $CL=$parameters{'Climate'};         # get Climate (file name base)
   $climate_name=$parameters{'climate_name'};   ######### requested #########

   $weppversion = "wepp_latest";

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

############################ start 2009.10.29 DEH

   if ($platform eq "pc") {
     if (-e 'd:/fswepp/working') {$runLogFile = 'd:\\fswepp\\working\\wepprun.log'}
     elsif (-e 'c:/fswepp/working') {$runLogFile = 'c:\\fswepp\\working\\wepprun.log'}
     else {$runLogFile = '..\\working\\wepprun.log'}
 #   $logFile = "..\\working\\wepprun.log";
   }
   else {
     $user_ID=$ENV{'REMOTE_ADDR'};
     $user_really=$ENV{'HTTP_X_FORWARDED_FOR'};          # DEH 11/14/2003
     $user_ID=$user_really if ($user_really ne '');      # DEH 11/14/2003
     $user_ID =~ tr/./_/;
     $user_ID = $user_ID . $me;
     $runLogFile = "../working/" . $user_ID . ".run.log";
   }

############################ end 2009.10.29 DEH

# ======================  CUSTOM CLIMATE  ======================

   if (lc($action) =~ /custom/) {
     $wepproad = "https://" . $wepphost . "/cgi-bin/fswepp/wr/wepproad.pl";
     if ($platform eq "pc") {
       exec "perl ../rc/rockclim.pl -server -i$me -u$units $wepproad"
     }
     else {
       exec "../rc/rockclim.pl -server -i$me -u$units $wepproad"
#      exec "../rc/rockclim_s.pl -server -i$me -u$units $wepproad"
     }
   }

# ======================  DESCRIBE CLIMATE  ======================

   if ($achtung =~ /Describe Climate/) {
     $wepproad = "https://" . $wepphost . "/cgi-bin/fswepp/wr/wepproad.pl";
     if ($platform eq "pc") {
       exec "perl ../rc/descpar.pl $CL $units $wepproad"
     }
     else {
       exec "../rc/descpar.pl $CL $units $wepproad"
     }
     die
   }

# ======================  DESCRIBE SOIL  ======================

   if ($achtung =~ /Describe Soil/) {
      
     $UBR=$parameters{'Rock'}*1;		  # Rock fragment percentage
     $units=$parameters{'units'};
     $SoilType=$parameters{'SoilType'};  # get SoilType (loam, ... pclay) # HR
     $surface=$parameters{'surface'};    # paved, graveled or native      # HR
     $slope=$parameters{'SlopeType'};    # get slope type
     if    (substr($surface,0,1) eq 'g') {$surf = 'g'}                  # HR
     elsif (substr($surface,0,1) eq 'p') {$surf = 'p'}                  # HR
     else                                {$surf = ''}                   # HR
     if    ($slope eq 'inveg')    {$tauC = '10'}  # critical shear (N/M^2)
     elsif ($slope eq 'outunrut') {$tauC = '2'}                         # HR
     elsif ($slope eq 'outrut')   {$tauC = '2'}                         # HR
     elsif ($slope eq 'inbare')   {$tauC = '2'}                         # HR
     if ($slope eq 'inbare' && $surf eq 'p') {$tauC = '1'}              # HR
     $soilFile = '3' . $surf . $SoilType . $tauC . '.sol';              # HR

     if ($surface eq 'graveled') {$URR = 65; $UFR = ($UBR+65)/2}
     elsif ($surface eq 'paved') {$URR = 95; $UFR = ($UBR+65)/2}
     else                        {$URR = $UBR; $UFR = $UBR}

     if ($platform eq "pc") {
       if    (-e 'd:/fswepp/working') {$working = 'd:\\fswepp\\working'}
       elsif (-e 'c:/fswepp/working') {$working = 'c:\\fswepp\\working'}
       else                           {$working = '..\\working'}
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
#      $unique='wepp' . time . '-' . $$;
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
     $wepproad = "https://" . $wepphost . "/cgi-bin/fswepp/wr/wepproad.pl";
     $soilFilefq = $soilPath . $soilFile;

     &CreateSoilFile;

     print "Content-type: text/html\n\n";
     print '<HTML>
 <HEAD>
  <TITLE>WEPP:Road -- Soil Parameters</TITLE>
  <link rel="stylesheet" type="text/css" href="/fswepp/notebook.css">
 </HEAD>
 <BODY>
  <font face="Arial, Geneva, Helvetica">
   <center><h1>WEPP:Road Soil Parameters</h1></center>
   <blockquote>
';
#    &printdate;

     if    ($surf eq 'g') {print 'Graveled '}
     elsif ($surf eq 'p') {print 'Paved '}                              # HR
     if ($SoilType eq 'clay') {
       print "clay loam (MH, CH)<br>\n";
       print "Shales and similar decomposing fine-grained sedimentary rock<br>\n";
     }
     elsif ($SoilType eq 'loam') {
       print "loam<br>\n";
       print "<br>\n";
     }
     elsif ($SoilType eq 'sand') {
       print "sandy loam (SW, SP, SM, SC)<br>\n";
       print "Glacial outwash areas; finer-grained granitics and sand<br>\n";
     }
     elsif ($SoilType eq 'silt') {
       print "silt loam (ML, CL)<br>\n";
       print "Ash cap or alluvial loess<br>\n";
     }
     if ($tauC == 10) {print 'High '} else {print 'Low '}               # HR
     print "critical shear<br>\n";                                      # HR
#     if ($conduct == 2) {print 'Low '} else {print 'High '}
#     print "conductivity<br>\n";

     print "     <hr><b><font face=courier><pre>\n";
     open SOIL, "<$newSoilFile";
     $weppver = <SOIL>;
     $comment = <SOIL>;
     while (substr($comment,0,1) eq "#") {
       chomp $comment;
       print $comment,"\n";
       $comment = <SOIL>;
     }
     print "
      </pre>
     </font>
    </b>
    <center>
     <table border=1>
";
     $record = <SOIL>;
     @vals = split " ", $record;
     $ntemp = @vals[0];      # no. flow elements or channels
     $ksflag = @vals[1];     # 0: hold hydraulic conductivity constant
                             # 1: use internal adjustments to hydr con
     for $i (1..$ntemp) {    # Element $i
       print '       <tr><th colspan=3 bgcolor="#85D2D2">',"\n";
       $record = <SOIL>;
       @descriptors = split "'", $record;
       print "       @descriptors[1]   ";                # slid: Road, Fill, Forest
       print "       texture: @descriptors[3]\n";        # texid: soil texture
       ($nsl,$salb,$sat,$ki,$kr,$shcrit,$avke) = split " ", @descriptors[4];
#      @vals = split " ", @descriptors[4];
#      print "       No. soil layers: $nsl\n";
       print "       <tr><th align=left>Albedo of the bare dry surface soil<td>$salb<td>\n";
       print "       <tr><th align=left>Initial saturation level of the soil profile porosity<td>$sat<td>m/m\n";
       print "       <tr><th align=left>Baseline interrill erodibility parameter (<i>k<sub>i</sub></i>)<td>$ki<td>kg*s/m<sup>4</sup>\n";
       print "       <tr><th align=left>Baseline rill erodibility parameter (<i>k<sub>r</sub></i>)<td>$kr<td>s/m\n";
       print "       <tr><th align=left>Baseline critical shear parameter<td>$shcrit<td>N/m<sup>2</sup>\n";
       print "       <tr><th align=left>Effective hydraulic conductivity of surface soil<td>$avke<td>mm/h\n";
       for $layer (1..$nsl) {
         $record = <SOIL>;
         ($solthk,$sand,$clay,$orgmat,$cec,$rfg) = split " ", $record;
         print "       <tr><td><br><th colspan=2 bgcolor=#85D2D2>layer $layer\n";
         print "       <tr><th align=left>Depth from soil surface to bottom of soil layer<td>$solthk<td>mm\n";
         print "       <tr><th align=left>Percentage of sand<td>$sand<td>%\n";
         print "       <tr><th align=left>Percentage of clay<td>$clay<td>%\n";
         print "       <tr><th align=left>Percentage of organic matter (by volume)<td>$orgmat<td>%\n";
         print "       <tr><th align=left>Cation exchange capacity<td>$cec<td>meq per 100 g of soil\n";
         print "       <tr><th align=left>Percentage of rock fragments (by volume)<td> $rfg<td>%\n";
       }	# for $layer (1..$nsl)
     }		# for $i (1..$ntemp)
     close SOIL;
     print '     </table>
     <br>
     <hr>
     <br>
     <form method="post" action="wepproad.sol"
      <br><br>
       <center>
        <a href="JavaScript:window.history.go(-1)">
         <img src="/fswepp/images/rtis.gif"
          alt="Return to input screen" border="0" align=center></a>
         <input type="hidden" value="',$soilFile,'" name"filename">
     </form>
    </center><p><hr><p></blockquote>
';
     die
   }       # if ($achtung =~ /Describe Soil/)

# =======================  Run WEPP  =========================

   $units=$parameters{'units'};
   $ST=$parameters{'SoilType'};        # Soil type (loam, ..., pclay)
   $surface=$parameters{'surface'};    # Paved, graveled or native
   $URL=$parameters{'RL'}*1;           # Road length -- buffer spacing (free)
   $URS=$parameters{'RS'}*1;           # Road gradient (free)
   $URW=$parameters{'RW'}*1;           # Road width (free)
   $UFL=$parameters{'FL'}*1;           # Fill length (free)
   $UFS=$parameters{'FS'}*1;           # Fill steepness (free)
   $UBL=$parameters{'BL'}*1;           # Buffer length (free)
   $UBS=$parameters{'BS'}*1;           # Buffer steepness (free)
   $UBR=$parameters{'Rock'}*1;	       # Rock fragment percentage
   $slope=$parameters{'SlopeType'};    # Slope type (outunrut, inbare, inveg, outrut)
   $design=$slope;
   if ($slope eq "outunrut")  {$design="Outsloped, unrutted"}
   elsif ($slope eq "inbare") {$design="Insloped, bare ditch"}
   elsif ($slope eq "inveg")  {$design="Insloped, vegetated or rocked ditch"}
   elsif ($slope eq "outrut") {$design="Outsloped, rutted"}

# DEH 4/13/2000

   if    ($ST eq 'clay') {$STx = 'clay loam'} 
   elsif ($ST eq 'silt') {$STx = 'silt loam'} 
   elsif ($ST eq 'sand') {$STx = 'sandy loam'} 
   elsif ($ST eq 'loam') {$STx = 'loam'} 

   if    ($slope eq 'inveg')    {$slopex = 'insloped vegetated'}
   elsif ($slope eq "outunrut") {$slopex = 'outsloped unrutted'}
   elsif ($slope eq "outrut")   {$slopex = 'outsloped rutted'}
   elsif ($slope eq "inbare")   {$slopex = 'insloped bare'}

   $outputf=$parameters{'Full'};
   $outputi=$parameters{'Slope'};
   $years=$parameters{'years'};
   if ($platform eq "pc") {
     if    (-e 'd:/fswepp/working') {$working = 'd:\\fswepp\\working'}
     elsif (-e 'c:/fswepp/working') {$working = 'c:\\fswepp\\working'}
     else                           {$working = '..\\working'}
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
#    $unique='wepp' . time . '-' . $$;
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

#  ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime;
#  @months=qw(January February March April May June July August September October November December);
#  @days=qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);

   $host = $ENV{REMOTE_HOST};
   if ($host eq "") {$host = 'unknown'}

   $rcin = &checkInput;
   if ($rcin >= 0) {
     if     (substr ($surface,0,1) eq 'g') {$surf = 'g'}         #HR
     elsif  (substr ($surface,0,1) eq 'p') {$surf = 'p'}         #HR
     else                                  {$surf = ''}          #HR
     if    ($slope eq 'inveg')    {$tauC ='10'; $manfile = '3inslope.man'}
     elsif ($slope eq 'outunrut') {$tauC = '2'; $manfile = '3outunr.man'}
     elsif ($slope eq 'outrut')   {$tauC = '2'; $manfile = '3outrut.man'}
     elsif ($slope eq 'inbare')   {$tauC = '2'; $manfile = '3inslope.man'}
     if ($traffic eq 'none') {
       if ($manfile eq '3inslope.man'){$manfile = '3inslopen.man'} # DEH 07/10/2002
       if ($manfile eq '3outunr.man') {$manfile = '3outunrn.man'}
       if ($manfile eq '3outrut.man') {$manfile = '3outrutn.man'}
     }
     $zzveg = $manPath . $manfile;
     if ($slope eq 'inbare' && $surf eq 'p') {$tauC = '1'}
     $soilFile = '3' . $surf . $ST . $tauC . '.sol';
     $soilFilefq = $soilPath . $soilFile;
#    print "<br>Soil file: $soilFilefq<br>";
     $zzsoil   = &CreateSoilFile; 
     $zzslope  = &CreateSlopeFile;
     $zzcligen = &CreateCligenFile;
     $zzresp   = &CreateResponseFile;
#    $stoutFile = 'working' . $unique . ".sto";
#    $sterFile = 'working' . $unique . ".ste";
     if ($platform eq "pc") {
       @args = ("..\\wepp <$responseFile >$stoutFile"); 
     }
     else {
       @args = ("../$weppversion <$responseFile >$stoutFile 2>$sterFile");
     }

     system @args;

     unlink $climateFile;    # be sure this is right file .....

     print "Content-type: text/html\n\n";
     print "<HTML>
 <HEAD>
  <TITLE>WEPP:Road Results</TITLE>  
  <link rel=\"stylesheet\" type=\"text/css\" href=\"/fswepp/notebook.css\">
   <script language=\"javascript\">

  function popuphistory() {
    height=500;
    width=660;
    pophistory = window.open('','pophistory','toolbar=no,location=no,status=no,directories=no,menubar=no,scrollbars=yes,resizable=yes,width='+width+',height='+height);
";
     print make_history_popup();
     print "
    pophistory.document.close()
    pophistory.focus()
  }
";
     print '
  function showslopefile() {
    var properties="menubar,scrollbars,resizable"
    filewindow = window.open("","file",properties)
    filewindow.document.open()
    if (filewindow && filewindow.open && !filewindow.closed) {
      filewindow.focus
      filewindow.document.writeln("<head><title>WEPP slope file ',$unique,'<\/title><\/head>")
      filewindow.document.writeln("<body><font face=\'courier\'><pre>")
//      filewindow.document.writeln("I am the walrus")
//      filewindow.document.writeln("koo koo ka choo")
';
      open WEPPFILE, "<$zzslope";
        while (<WEPPFILE>) {
          chomp;
          print '      filewindow.document.writeln("', $_, '")',"\n";
        }
      close WEPPFILE;
      print '      filewindow.document.writeln("<\/pre><\/font><\/body><\/html>")
      filewindow.document.close()
    }
    return false
  }

  function showsoilfile() {
    var properties="menubar,scrollbars,resizable"
    filewindow = window.open("","file",properties)
    filewindow.document.open()
    if (filewindow && filewindow.open && !filewindow.closed) {
      filewindow.focus
      filewindow.document.writeln(" <head><title>WEPP soil file ',$unique,'<\/title><\/head>")
      filewindow.document.writeln(" <body><font face=\'courier\'><pre>")
//    filewindow.document.writeln("', $zzsoil, '")
';
     open WEPPFILE, "<$zzsoil";
       while (<WEPPFILE>) {
         chomp;
         print '      filewindow.document.writeln("', $_, '")',"\n";
       }
     close WEPPFILE;
     print '      filewindow.document.writeln("<\/pre><\/font><\/body><\/html>")
      filewindow.document.close()
    }
    return false
  }

  function showresponsefile() {
    var properties="menubar,scrollbars,resizable"
    filewindow = window.open("","file",properties)
    filewindow.document.open()
    if (filewindow && filewindow.open && !filewindow.closed) {
      filewindow.focus
      filewindow.document.writeln("<head><title>WEPP response file ',$unique,'<\/title><\/head>")
      filewindow.document.writeln("<body><pre>")
';
     open WEPPFILE, "<$zzresp";
       while (<WEPPFILE>) {
         chomp;
         print '      filewindow.document.writeln("', $_, '")',"\n";
       }
     close WEPPFILE;
     print '      filewindow.document.writeln("<\/pre><\/body><\/html>")
      filewindow.document.close()
    }
    return false
  }

  function showvegfile() {
    var properties="menubar,scrollbars,resizable"
    filewindow = window.open("","file",properties)
    filewindow.document.open()
    if (filewindow && filewindow.open && !filewindow.closed) {
      filewindow.focus
      filewindow.document.writeln("<head><title>WEPP vegetation file ',$unique,'<\/title><\/head>")
      filewindow.document.writeln("<body><pre>")
';
     $line = 0;
     open WEPPFILE, "<$zzveg";
       while (<WEPPFILE>) {
         chomp;
         print '      filewindow.document.writeln("', $_, '")',"\n";
         $line +=1;
#        last if ($line > 100);
         last if (/Management Section/);
       }
     close WEPPFILE;
     print '      filewindow.document.writeln("    <\/pre>\n  <\/body>\n<\/html>")
      filewindow.document.close()
    }
    return false
  }

  function showextendedoutput() {
    var properties="menubar,scrollbars,resizable"
    filewindow = window.open("","file",properties)
    filewindow.document.open()
    if (filewindow && filewindow.open && !filewindow.closed) {
      $z=0
    }
    else {
      return false
    }
    filewindow.focus
    filewindow.document.writeln("<head><title>WEPP output file ',$unique,'<\/title><\/head>")
    filewindow.document.writeln("<body><font face=\'courier\'><pre>")
';
     open WEPPFILE, "<$outputFile";
       while (<WEPPFILE>) {
         s/\015$//;       # dos2unix:     https://lists.samba.org/archive/samba/2000-September/021008.html
         chomp;
         print '      filewindow.document.writeln("', $_, '")',"\n";
       }
     close WEPPFILE;
     print '      filewindow.document.writeln("<\/pre><\/font><\/body><\/html>")
    filewindow.document.close()
    return false
  }

  function showcligenparfile() {
    var properties="menubar,scrollbars,resizable"
    filewindow = window.open("","file",properties)
    filewindow.document.open()
    if (filewindow && filewindow.open && !filewindow.closed) {
      filewindow.focus
      filewindow.document.writeln("<head><title>WEPP weather file ',$unique,'<\/title><\/head>")
      filewindow.document.writeln("<body><pre>")
';
#    print '      filewindow.document.writeln("climate file: ', $zzcligen, '")',"\n";
     open WEPPFILE, "<$zzcligen";
       while (<WEPPFILE>) {
         chomp; chop;
         print '      filewindow.document.writeln("', $_, '")',"\n";
       }
     close WEPPFILE;
     print '      filewindow.document.writeln("   <\/pre>\n  <\/body>\n<\/html>")
      filewindow.document.close()
    }
    return false
  }
';

  print '
   <link rel="stylesheet" type="text/css" href="/fswepp/notebook.css">
   </script>
 </head>
 <BODY>
  <font face="Arial, Geneva, Helvetica">
   <blockquote>
    <CENTER>
     <font face="Arial, Geneva, Helvetica">
      <table width="90%">
       <tr>
        <td>
         <a href="JavaScript:window.history.go(-1)">
          <img src="/fswepp/images/road4.gif"
          align=left border=1
          width=50 height=50
          alt="Return to WEPP:Road input screen" 
          onMouseOver="window.status=',"'Return to WEPP:Road input screen'",'; return true"
          onMouseOut="window.status=',"' '",'; return true">
         </a>
        </td>
        <td align=center>
         <hr>
         <h2>WEPP:Road Results</h2>
         <hr>
        </td>
        <td>
         <a href="/fswepp/docs/wroadimg.html#wrout" target="_docs">
          <img src="/fswepp/images/ipage.gif"
          align="right" alt="Read the documentation" border=0
          onMouseOver="window.status=\'Read the documentation\'; return true"
          onMouseOut="window.status=\' \'; return true">
         </a>
        </td>
       </tr>
     </table>
    </center>
';
   if ($debug) {print "I am '$me', units '$units' <br>\n"}

# 12/19/2003 DEH
#   print $error_message, "<br>\n";

     $found = &parseWeppResults;

#    if ($outputf==1) {
#      &printWeppSummary;
#    }
     print '  <br><center><font size=-1>WEPP files: 
    [ <a href="javascript:void(showslopefile())">slope</a>
    | <a href="javascript:void(showsoilfile())">soil</a>
    | <a href="showmanfile.pl?f='.$manfile.'" target="_manfile">vegetation</a>
    | <a href="javascript:void(showcligenparfile())">weather</a>
    | <a href="javascript:void(showresponsefile())">response</a>
    || <a href="javascript:void(showextendedoutput())">results</a> ]
     </font>
    </center>
';
   }   #   if ($rcin >= 0) 
#    | <a href="javascript:void(showvegfile())">vegetation</a>
   else {
     print "Content-type: text/html\n\n";                    
     print '
<HTML>                                       
 <HEAD>                                      
   <TITLE>WEPP:Road -- error messages</TITLE>
    <link rel="stylesheet" type="text/css" href="/fswepp/notebook.css">
 </HEAD>                                     
 <BODY>
  <font face="Arial, Geneva, Helvetica">
   <blockquote>
    <center>
     <table width="90%">
      <tr>
       <td>
        <a href="JavaScript:window.history.go(-1)">
         <img src="/fswepp/images/road4.gif"
         align=left border=1
         width=50 height=50
         alt="Return to WEPP:Road input screen"
         onMouseOver="window.status=',"'Return to WEPP:Road input screen'",'; return true" 
         onMouseOut="window.status=',"' '",'; return true">
        </a>
       </td>
       <td align=center>
        <hr>
        <h2>WEPP:Road Results</h2>
        <hr>
       </td>
       <td>
        <a HREF="https://',$wepphost,'/fswepp/docs/wroadimg.html#wrout">
         <img src="https://',$wepphost,'/fswepp/images/ipage.gif"
         align="right" alt="Read the documentation" border=0
         onMouseOver="window.status=\'Read the documentation\'; return true"
         onMouseOut="window.status=\' \'; return true">
        </a>
       </td>
      </tr>
     </table>
    <font color="red">', $error_message, '</font>
    <br> 
   </center>
';

   }	#   if ($rcin >= 0)

    print '
   <hr>
   <table width=90%>
    <tr>
     <td><font face="Arial, Geneva, Helvetica" size=-2>
     WEPP:Road results version 
<!--a href="/fswepp/history/wrrver.html"-->
<a href="javascript:popuphistory()">',
     $version,'</a> based on WEPP ',$weppver,'<br>
     by 
     <a HREF="https://forest.moscowfsl.wsu.edu/people/engr/dehall.html" target="o">Hall</A> and
     Anderson;
     Project leader 
     <a HREF="https://forest.moscowfsl.wsu.edu/people/engr/welliot.html" target="o">Bill Elliot</a><BR>
     USDA Forest Service, Rocky Mountain Research Station, Moscow, ID 83843
     <br>';    &printdate; print '<br>
     WEPP:Road run ID ',$unique,'
    </td>
    <td>
      <!-- a href="https://',$wepphost,'/fswepp/comments.html" onClick="return confirm(\'You need to be connected to the Internet to e-mail comments. Shall I try?\')" -->
      <a href="https://',$wepphost,'/fswepp/comments.html">
      <img src="https://',$wepphost,'/fswepp/images/epaemail.gif" align="right" border=0></a>
    </td>
   </tr>
  </table>
 </BODY>
</HTML>
';

#   unlink <"$working/$unique.*">;

   unlink $responseFile;
   unlink $outputFile;
   unlink $stoutFile;
   unlink $sterFile;
   unlink $slopeFile;
   unlink $newSoilFile;			# 2006.02.23 DEH

################################# start 2009.10.29 DEH

#  record run in user wepp run log file 

#   print date\trun_id\tmodel\tclimate_name\tfilename\tparams

#  strip leading and trailing blanks on file name

sub trim($){       # https://www.somacon.com/p114.php

	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

    $climate_trim = trim($climate_name);

    open RUNLOG, ">>$runLogFile";
      flock (RUNLOG,2);
      print  RUNLOG "WR\t$unique\t",'"';
      printf RUNLOG "%0.2d:%0.2d ", $hour, $min;
      print  RUNLOG $ampm[$ampmi],"  ",$days[$wday]," ",$months[$mon]," ",$mday,", ",$year+1900, '"',"\t",'"';
      print  RUNLOG $climate_trim,'"',"\t";
      print  RUNLOG "$years2sim\t";
      print  RUNLOG "$ST\t";		# Soil type (loam, ..., pclay)
      print  RUNLOG "$surface\t";	# Paved, graveled or native
      print  RUNLOG "$URL\t";		# Road length -- buffer spacing (free)
      print  RUNLOG "$URS\t";		# Road gradient (free)
      print  RUNLOG "$URW\t";		# Road width (free)
      print  RUNLOG "$UFL\t";		# Fill length (free)
      print  RUNLOG "$UFS\t";		# Fill steepness (free)
      print  RUNLOG "$UBL\t";		# Buffer length (free)
      print  RUNLOG "$UBS\t";		# Buffer steepness (free)
      print  RUNLOG "$UBR\t";		# Rock fragment percentage
      print  RUNLOG "$slope\t";		# Slope type (outunrut, inbare, inveg, outrut)
      print  RUNLOG "$units\n";
    close RUNLOG;

################################# end 2009.10.29 DEH

#  record activity in WEPP:Road log (if running on remote server)

   if (lc($wepphost) ne "localhost") {
     $host = $ENV{REMOTE_HOST};
     $host = $ENV{REMOTE_ADDR} if ($host eq '');  
     $user_really=$ENV{'HTTP_X_FORWARDED_FOR'};   
     $host = $user_really if ($user_really ne '');
# 2008.06.04 DEH start
   open PAR, "<$climatePar";
    $PARline=<PAR>;                 # station name
    $PARline=<PAR>;                 # Lat long
    $lat_long=substr($PARline,0,26);
    $lat=substr $lat_long,6,7;
    $long=substr $lat_long,19,7;
   close PAR;
# 2008.06.04 DEH end
     open WRLOG, ">>../working/_$thisyear/wr.log";	# 2012.12.31 DEH
       flock (WRLOG,2);
       print WRLOG "$host\t\"";
       printf WRLOG "%0.2d:%0.2d ", $hour, $min;
       print WRLOG $ampm[$ampmi],"  ",$days[$wday]," ",$months[$mon]," ",$mday,", ",$year+1900, "\"\t";
       print WRLOG $years2sim,"\t";
       print WRLOG '"',trim($climate_name),"\"\t";
#      print WRLOG $lat_long,"\n";			# 2008.06.04 DEH
       print WRLOG "$lat\t$long\n";			# 2008.06.04 DEH
#       print WRLOG $climate_name,"\n";                 # 2008.06.04 DEH
     close WRLOG;

#    open CLIMLOG, '>../working/lastclimate.txt';	# 2005.07.14 DEH
     open CLIMLOG, ">../working/_$thisyear/lastclimate.txt";	# 2012.12.31 DEH
       flock CLIMLOG,2;
       print CLIMLOG 'WEPP:Road: ', trim($climate_name);
     close CLIMLOG;

#    $thisday = 1+ (localtime)[7];                      # $yday, day of the year (0..364|365)
#    $thisdayoff=$thisday+4;				# [Jan 1] -1: Sunday; 0: Monday # +3: 2009
#    $thisweek = 1+ int $thisdayoff/7;

# if (!-e "../working/_$thisyear") create it
# if (!-e "../working/_$thisyear/wr") create it

     $ditlogfile = ">>../working/_$thisyear/wr/" . $thisweek;	# 2012.12.31 DEH
#    if ($thisyear == 2012) {$ditlogfile = ">>../working/wr/" . $thisweek}
     open MYLOG,$ditlogfile;
       flock MYLOG,2;
       print MYLOG '.';
     close MYLOG;

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

     open (ResponseFile, ">" . $responseFile);
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
       print ResponseFile $newSoilFile,"\n";           # soil file name
       print ResponseFile "0\n";           # 0 = no irrigation
       print ResponseFile "$years2sim\n";  # no. years to simulate
       print ResponseFile "0\n";           # 0 = route all events
     close ResponseFile;
     return $responseFile;
}

sub CreateSoilFile {                                                          

# David Hall and Darrell Anderson
#    2004.01.26
#    2001.11.26
                                                                               
# Read a WEPP:Road soil file template and create a usable soil file.
# File may have 'urr', 'ufr' and 'ubr' as placeholders for rock fragment
# Adjust road surface Kr downward for traffic levels of 'low' or 'none'
# Adjust road surface Ki downward for traffic levels of 'low' or 'none'
#         DEH 2004.01.26

# uses: $soilFilefq   fully qualified input soil file name
#       $newSoilFile  name of soil file to be created
#       $surface      native, graveled, paved
#       $traffic      High, Low, None
#       $UBR          user-specified rock fragment decimal percentage for
# buffer
# sets: $URR          calculated rock fragment decimal percentage for road
#       $UFR          calculated rock fragment decimal percentage for fill

   my $in;
   my ($pos1, $pos2, $pos3, $pos4);
   my ($ind, $left, $right);

   open SOILFILE, "<$soilFilefq";                                              
   open NEWSOILFILE, ">$newSoilFile";                                          
                                                                               
   if    ($surface eq 'graveled') {$URR = 65; $UFR = ($UBR+65)/2}
   elsif ($surface eq 'paved')    {$URR = 95; $UFR = ($UBR+65)/2}
   else                           {$URR = $UBR; $UFR = $UBR}

# modify 'Kr' for 'no traffic' and 'low traffic'
# modify 'Ki' for 'no traffic' and 'low traffic'

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
     $pos1 = index ($in,"'");          # location of first apostrophe
     $pos2 = index ($in,"'",$pos1+1);  # location of second apostrophe
     $pos3 = index ($in,"'",$pos2+1);  # location of third apostrophe
     $pos4 = index ($in,"'",$pos3+1);  # location of fourth apostrophe
     my $slid_texid = substr($in,0,$pos4+1);  # slid; texid
     my $rest = substr($in,$pos4+1);
     my ($nsl, $salb, $sat, $ki, $kr, $shcrit, $avke) = split ' ', $rest;
     $kr /= 4;
     $ki /= 4;				# DEH 2004.01.26
     print NEWSOILFILE "$slid_texid\t";
     print NEWSOILFILE "$nsl\t$salb\t$sat\t$ki\t$kr\t$shcrit\t$avke\n";
   }
   while (<SOILFILE>) {                                                        
     $in = $_;                                                                 
     if (/urr/) {               # user-specified road rock fragment            
        $ind = index($in,'urr');                                               
        $left = substr($in,0,$ind);                                            
        $right = substr ($in, $ind+3);                                         
        $in = $left . $URR . $right;                                           
     }                                                                         
     elsif (/ufr/) {            # calculated fill rock fragment            
        $ind = index($in,'ufr');                                               
        $left = substr($in,0,$ind);                                            
        $right = substr ($in, $ind+3);                                         
        $in = $left . $UFR . $right;                                           
     }                                                                         
     elsif (/ubr/) {            # calculated buffer rock fragment          
        $ind = index($in,'ubr');                                               
        $left = substr($in,0,$ind);                                            
        $right = substr ($in, $ind+3);                                         
        $in = $left . $UBR . $right;                                           
     }                                                                         
     print NEWSOILFILE $in;                                                    
   }                                                                           
   close SOILFILE;                                                             
   close NEWSOILFILE;                                                          
   return $newSoilFile;
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
     $minUFL = 1;   $maxUFL = 300; #   67585 Jun  4 15:36 wr.pl
     $minUFL = 1;   $maxUFL = 1000; #
     $minUFS = 0.3; $maxUFS = 150;
     $minUBL = 1;   $maxUBL = 1000;
     $minUBS = 0.3; $maxUBS = 100;
   }
   $minyrs = 1;   $maxyrs = 200;
   $rc = -0;

# 12/19/2003 DEH

# [Fri Dec 19 09:37:11 2003] [error] [client 166.4.225.152] malformed header from 
# script. Bad header=Road length must be between 3 : /home/httpd/cgi-bin/fswepp/wr
# dev/wr.pl

   $error_message = '';

   if ($URL < $minURL or $URL > $maxURL) { $rc=-1;
      $error_message .= "Road length must be between $minURL and $maxURL $lu<BR>\n";}
   if ($URS < $minURS or $URS > $maxURS) { $rc=$rc-1;
      $error_message .= "Road gradient must be between $minURS and $maxURS %<BR>\n";}
   if ($URW < $minURW or $URW > $maxURW) { $rc=$rc-1;
      $error_message .= "Road width must be between $minURW and $maxURW $lu<BR>\n";} 
   if ($UFL < $minUFL or $UFL > $maxUFL) { $rc=$rc-1;
      $error_message .= "Fill length must be between $minUFL and $maxUFL $lu<BR>\n";}
   if ($UFS < $minUFS or $UFS > $maxUFS) { $rc=$rc-1;
      $error_message .= "Fill gradient must be between $minUFS and $maxUFS %<BR>\n";}
   if ($UBL < $minUBL or $UBL > $maxUBL) { $rc=$rc-1;
      $error_message .= "Buffer length must be between $minUBL and $maxUBL $lu<BR>\n";}
   if ($UBS < $minUBS or $UBS > $maxUBS) { $rc=$rc-1;
      $error_message .= "Buffer gradient must be between $minUBS and $maxUBS %<BR>\n";}
#  if ($rc < 0) {print "<p><hr><p>\n"}
   $years2sim=$years*1;
#  if ($years2sim < $minyrs) {$years2sim=$minyrs}
#  if ($years2sim > $maxyrs) {$years2sim=$maxyrs}
   if ($years2sim < 1) {$years2sim=1}
   if ($years2sim > 200) {$years2sim=200}
   return $rc;
}

sub CreateCligenFile {

   $climatePar = "$CL" . '.par';
   $station = substr($CL, length($CL)-8);
   $user_ID = '';
#  $user_ID = 'getalife';
####  next for unix and pc ************************* DEH 2/1/2000
   if ($platform eq 'pc') {
     $station = substr($CL, length($CL)-8);
     $climateFile = "$working\\$station.cli";
     $outfile = $climateFile;
     $rspfile = "$working\\cligen.rsp";
     $stoutfile = "$working\\cligen.out";
   } else {
#    $user_ID = '';
#    $climateFile = '..\\working' . "$station.cli";
     $climateFile = "../working/$unique.cli";
     $outfile = $climateFile;
#    $rspfile = "../working/$user_ID.rsp";
#    $stoutfile = "../working/$user_ID.out";
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
#    @args = ("nice -20 ../wepp <$responseFile >$stoutFile 2>$sterFile");
     @args = ("../rc/cligen43 <$rspfile >$stoutfile"); 
   }
   system @args;
   unlink $rspfile;   #  "../working/c$unique.rsp"
   unlink $stoutfile;  #  "../working/c$unique.out"
   return $climatePar;
}

sub parseWeppResults {

   open weppstout, "<$stoutFile";

     $found = 0;
     while (<weppstout>) {
       if (/SUCCESSFUL/) {
         $found = 1;
         last;
       }
     }  

   close (weppstout);

########################   NAN check   ###################

   open weppoutfile, "<$outputFile";
     while (<weppoutfile>) {
       if (/NaN/) {
         open NANLOG, ">>../working/NANlog.log";
         flock (NANLOG,2);
         print NANLOG "$user_ID_\t";
         print NANLOG "WR\t$unique\n";
         close NANLOG;
         last;
       }
     }
   close (weppoutfile);

########################   NAN check   ###################

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
   }		# if ($found == 0)

   if ($found == 0) {
     open weppstout, "<$stoutFile";
       while (<weppstout>) {
         if (/MATHERRQQ/) {
           $found = 5;
           print '     <font color=red>
           WEPP has run into a mathematical anomaly.<br>
           You may be able to get around it by modifying the geometry slightly;
           try changing road length by 1 foot (1/2 meter) or so.
';
           $_ = <weppstout>; print;
           print "</font>\n";
             last;
         }
       }
     close (weppstout);
   }		# if ($found == 0)

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
           $_ = <weppout>; #  print; print "<br>\n";
           $_ = <weppout>; #  print; print "<br>\n";
           $_ = <weppout>; #  print; print "<br>\n";
           $syp = substr $_,49,10;   # pre-WEPP 98.4 [was (50,9)]
           $_ = <weppout>; #  print; print "<br>\n";
           chomp $syp;
           if ( $syp eq "") {
             @sypline = split ' ',$_; # print "a: $_<br>\n";
             $syp = @sypline[0];
           }
           $_ = <weppout>;
           $_ = <weppout>;
           last;
         }
       }
     close (weppout);

# print "syr: $syr; syp: $syp; effective_road_length: $effective_road_length; WeppRoadWidth $WeppRoadWidth<br>\n";

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

## DEH 2003/10/09
     $trafficx = $traffic;
     $trafficx = 'no' if ($traffic eq 'none');
##

     print "
   <center>
    <table border=1>
     <tr>
      <th colspan=8 bgcolor=#85D2D2><font face='Arial, Geneva, Helvetica'>INPUTS</font></th>
     </tr>
     <tr>
      <td><font face='Arial, Geneva, Helvetica'><b>Climate</font></td>
      <td colspan=3>
       <font face='Arial, Geneva, Helvetica'>$climate_name<br>
        <font size=1>
";
     $PARfile = $climatePar;                      # for &readPARfile()
     &readPARfile();

     print "
        </font>
       </font>
      </td>
     </tr>
     <tr>
      <td><font face='Arial, Geneva, Helvetica'><b>Soil texture</b></font></td>
      <td colspan=3><font face='Arial, Geneva, Helvetica'>$STx with $UBR% rock fragments<br>
                    <font size=1>(road: $URR%; fill: $UFR%; buffer: $UBR% rock)</font></font></td>
     </tr>
     <tr>
      <td><font face='Arial, Geneva, Helvetica'><b>Road design</b></font></td>
      <td colspan=3><font face='Arial, Geneva, Helvetica'>$design</font></td>
     </tr>
     <tr>
      <td><font face='Arial, Geneva, Helvetica'><b>Surface, traffic</b></font></td>
      <td colspan=3><font face='Arial, Geneva, Helvetica'>$surface surface, $trafficx traffic</font></td>
     </tr>
     <tr>
      <td></td>
      <th><font face='Arial, Geneva, Helvetica'>Gradient<br> (%)</font></th>
      <th><font face='Arial, Geneva, Helvetica'>Length<br> ($units)</font></th>
      <th><font face='Arial, Geneva, Helvetica'>Width<br> ($units)</font></th>
     </tr>
     <tr>
      <th align=left> <font face='Arial, Geneva, Helvetica'>Road</font></th>
      <td align=right><font face='Arial, Geneva, Helvetica'>$URS</font></td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$URL</font></td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$URW</font></td>
     </tr>
     <tr>
      <th align=left> <font face='Arial, Geneva, Helvetica'>Fill</font></th>
      <td align=right><font face='Arial, Geneva, Helvetica'>$UFS</font></td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$UFL</font></td>
      <td align=right></td>
     </tr>
     <tr>
      <th align=left> <font face='Arial, Geneva, Helvetica'>Buffer</font></th>
      <td align=right><font face='Arial, Geneva, Helvetica'>$UBS</font></td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$UBL</font></td>
      <td align=right></td>
     </tr>
    </table>
    <br><br>
";
#     if ($trafficx eq 'no' or $trafficx eq 'low') { 		# DEH 2015.03.02
#       print "     <font color=\"red\">
#      Provisional values for $trafficx traffic
#     </font>
#    <br><br>
#";
#     }		# if ($trafficx eq 'no' or $trafficx eq 'low')
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
     }		# if ($units eq "m")
#    $precipf = sprintf "%.0f", $precip;
#    $rrof = sprintf "%.0f", $rro;
#    $srof = sprintf "%.0f", $sro;
     $precipf = sprintf $pcpfmt, $precip;
     $rrof = sprintf $pcpfmt, $rro;
     $srof = sprintf $pcpfmt, $sro;
     $syraf = sprintf "%.2f", $syra;
     $sypaf = sprintf "%.2f", $sypa;

     print "
    <table cellspacing=8 bgcolor='#ccffff'>
     <tr>
      <th colspan=5 bgcolor=#85D2D2><font face='Arial, Geneva, Helvetica'>$years2sim - YEAR MEAN ANNUAL AVERAGES</font></th>
     </tr>
     <tr>
       <td colspan=3></td>
       <th colspan=2><font size=-1 face='Arial, Geneva, Helvetica'>Total in<br>$years2sim years</font></th>
     </tr>
     <tr>
      <td align=right><font face='Arial, Geneva, Helvetica'>$precipf</font></td>
      <td><font face='Arial, Geneva, Helvetica'>$precipunits
      <td><font face='Arial, Geneva, Helvetica'>precipitation from</font></td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$storms</font></td>
      <td><font face='Arial, Geneva, Helvetica'>storms</font></td>
     </tr>
     <tr>
      <td align=right><font face='Arial, Geneva, Helvetica'>$rrof</font></td>
      <td><font face='Arial, Geneva, Helvetica'>$precipunits</font></td>
      <td><font face='Arial, Geneva, Helvetica'>runoff from rainfall from</font></td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$rainevents</font></td>
      <td><font face='Arial, Geneva, Helvetica'>events</font></td>
     </tr>
     <tr>
      <td align=right><font face='Arial, Geneva, Helvetica'>$srof</font></td>
      <td><font face='Arial, Geneva, Helvetica'>$precipunits</font></td>
      <td><font face='Arial, Geneva, Helvetica'>runoff from snowmelt or winter rainstorm from </font></td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$snowevents</font></td>
      <td><font face='Arial, Geneva, Helvetica'> events</font></td>
     </tr>
     <tr>
      <td align=right><font face='Arial, Geneva, Helvetica'>$syraf</font></td>
      <td><font face='Arial, Geneva, Helvetica'>$sedunits</font></td>
      <td><font face='Arial, Geneva, Helvetica'>road prism erosion</font></td>
     </tr>
     <tr>
      <td align=right><font face='Arial, Geneva, Helvetica'>$sypaf</font></td>
      <td><font face='Arial, Geneva, Helvetica'>$sedunits</font></td>
      <td><font face='Arial, Geneva, Helvetica'>sediment leaving buffer</font></td>
     </tr>
<!-- <tr><td>$syr<td>$effective_road_length<td>$WeppRoadWidth<td> syra=syr x rdlen x rdwidth
     <tr><td>$syp<td>sypa=syp x rdwidth
-->
    </table>
    <hr width=50%>
";
     print '
     <font face="Arial, Geneva, Helvetica">
      <form name="wrlog" method="post" action="/cgi-bin/fswepp/wr/logstuffwr.pl">
       <input type="hidden" name="me" value="',$me,'">
       <input type="hidden" name="units" value="',$units,'">
       <input type="hidden" name="years" value="',$years2sim,'">
       <input type="hidden" name="climate" value="',$climate_name,'">
       <input type="hidden" name="soil" value="',$STx,'">
       <input type="hidden" name="design" value="',$slopex,'">
       <input type="hidden" name="rock" value="',$UBR,'">
       <input type="hidden" name="surface" value="',$surface,'">
       <input type="hidden" name="traffic" value="',$traffic,'">
       <input type="hidden" name="road_grad" value="',$URS,'">
       <input type="hidden" name="road_length" value="',$URL,'">
       <input type="hidden" name="road_width" value="',$URW,'">
       <input type="hidden" name="fill_grad" value="',$UFS,'">
       <input type="hidden" name="fill_length" value="',$UFL,'">
       <input type="hidden" name="buff_grad" value="',$UBS,'">
       <input type="hidden" name="buff_length" value="',$UBL,'">
       <input type="hidden" name="precip" value="',$precipf,'">
       <input type="hidden" name="rro" value="',$rrof,'">
       <input type="hidden" name="sro" value="',$srof,'">
       <input type="hidden" name="syr" value="',$syraf,'">
       <input type="hidden" name="syp" value="',$sypaf,'">
       Run description: <input type=text name="rundescription">
       <input type="submit" name="button" value="Add to log">
      </form>
      <br><br>
      <input type="button" value="Return to Input Screen" onClick="JavaScript:window.history.go(-1)">
      <br>
     </center>
';
   }		# if ($found == 1)
   else {
     print "    <br><br>
    I'm sorry; WEPP did not run successfully.
    WEPP's error message follows:
    <br><br>
    <hr>
    <br><br>
";
   }		# if ($found == 1)
   return $found;
}

# ---------------------  WEPP summary output  --------------------

sub printWeppSummary {

  print '      <center><h2>WEPP output</h2></center>
      <font face=courier>
       <pre>
';
  open weppout, "<$outputFile";
    while (<weppout>){
      print;
    }
  close weppout;
  print '       </pre>
      </font>
      <br><br>
      <center>
       <hr>
       <a href="JavaScript:window.history.go(-1)">
        <img src="https://',$wepphost,'/fswepp/images/rtis.gif"
             alt="Return to input screen" border="0" align=center></a>
       <br>
      <hr>
     </center>
';
}

sub readPARfile {

#   $PARfile= 'working/166_2_22_167_o.par';

#   $PARfile
#   $units = 'ft';

   local $line, @mean_p_if, $mean_p_base, @pww, $pww_base, @pwd, $pwd_base, @tmax_av, $tmax_av_base;
   local @tmin_av, $tmin_av_base, @month_days, @num_wet, @mean_p, $tempunits, $prcpunits, $i, $mod, $modfrom;

# TOKETEE FALLS OR                        358536 0
# LATT=  43.28 LONG=-122.45 YEARS= 40. TYPE= 2
# ELEVATION = 2060. TP5 = 1.08 TP6= 4.08
# MEAN P    .39   .33   .29   .23   .24   .22   .19   .25   .27   .35   .43   .43
# S DEV P   .45   .37   .30   .25   .24   .25   .26   .26   .29   .39   .48   .50
# SKEW  P  2.16  2.76  2.20  2.12  1.61  2.17  3.01  1.73  1.99  1.83  2.26  2.55
# P(W/W)    .74   .77   .76   .72   .64   .59   .41   .48   .60   .64   .75   .76
# P(W/D)    .30   .28   .31   .31   .20   .15   .06   .08   .10   .19   .33   .32
# TMAX AV 42.29 48.29 53.67 60.86 69.80 77.65 86.12 85.43 77.99 63.48 48.60 41.95
# TMIN AV 29.15 30.95 32.50 35.71 40.83 46.87 50.15 49.37 44.32 38.30 33.83 30.11

   open PAR, "<$PARfile";
     $line=<PAR>;                 # station name
     $line=<PAR>;                 # Lat long
     $line=<PAR>;                 # Elev

################

     $line=<PAR>;       # MEAN P   0.10  0.10  0.11  0.10  0.11  0.14  0.14  0.09  0.10  0.10  0.12  0.12
       @mean_p_if = split ' ',$line; $mean_p_base = 2;
     $line=<PAR>;       # S DEV P  0.12  0.12  0.11  0.13  0.13  0.18  0.22  0.13  0.13  0.11  0.14  0.13
     $line=<PAR>;       # SKEW  P  1.88  2.30  2.21  2.15  2.29  2.35  3.60  3.22  2.05  2.49  2.22  1.87
     $line=<PAR>;       # P(W/W)   0.47  0.50  0.39  0.32  0.33  0.30  0.27  0.28  0.40  0.41  0.42  0.48
       @pww = split ' ',$line; $pww_base = 1;
     $line=<PAR>;       # P(W/D)   0.20  0.16  0.15  0.13  0.13  0.11  0.05  0.06  0.08  0.12  0.23  0.23
       @pwd = split ' ',$line; $pwd_base=1;
     $line=<PAR>;       # TMAX AV 32.89 41.62 52.60 62.81 72.56 80.58 88.52 87.06 77.76 62.85 44.78 34.63
#      @tmax_av = split ' ',$line; $tmax_av_base = 2;
       for $ii (0..11) {@tmax_av[$ii]=substr($line,8+$ii*6,6)}; $tmax_av_base = 0;
     $line=<PAR>;       # TMIN AV 20.31 26.55 32.33 39.12 47.69 55.39 61.58 60.31 51.52 40.17 30.33 22.81
#      @tmin_av = split ' ',$line; $tmin_av_base = 2;
       for $ii (0..11) {@tmin_av[$ii]=substr($line,8+$ii*6,6)}; $tmin_av_base = 0;

     @month_days=(31,28,31,30,31,30,31,31,30,31,30,31);

#******************************************************#
# Calculation from parameter file for displayed values #
#******************************************************#

     for $i (1..12) {
       @pw[$i] = @pwd[$i] / (1 + @pwd[$i] - @pww[$i]);
     }

     for $i (0..11) {
        @tmax[$i] = @tmax_av[$i+$tmax_av_base];
        @tmin[$i] = @tmin_av[$i+$tmin_av_base];
        @pww[$i]  = @pww[$i+$pww_base];
        @pwd[$i]  = @pwd[$i+$pwd_base];
        @num_wet[$i] = sprintf '%.2f',@pw[$i+$pww_base] * @month_days[$i];
        @mean_p[$i] = sprintf '%.2f',@num_wet[$i] * @mean_p_if[$i+$mean_p_base];
        if ($units eq 'm') {
           @mean_p[$i] = sprintf '%.2f',25.4 * @mean_p[$i];        # inches to mm
           @tmax[$i] = sprintf '%.2f',(@tmax[$i] - 32) * 5/9;      # deg F to deg C
           @tmin[$i] = sprintf '%.2f',(@tmin[$i] - 32) * 5/9;      # deg F to deg C
        }
     }
     if ($units eq 'm') {
       $tempunits = 'deg C';
       $prcpunits = 'mm';
     }
     else {
       $tempunits = 'deg F';
       $prcpunits = 'in';
     }
     while (<PAR>) {
       if (/Modified by/) {
         $modfrom = $_;
         $modfrom .= <PAR>;
         last;
       }
     }
   close PAR;

   if ($modfrom ne '') {
     chomp $modfrom;
     $, = ' ';
       print $modfrom,"<br>";
       print 'T MAX ',@tmax,$tempunits,"<br>\n";
       print 'T MIN ',@tmin,$tempunits,"<br>\n";
       print 'MEANP ',@mean_p,$prcpunits,"<br>\n";
       print '# WET ',@num_wet,"<br>\n";
     $, = '';
   }
}

sub make_history_popup {

  my $version;

# Reads parent (perl) file and looks for a history block:
## BEGIN HISTORY ####################################################
# Example Version History

  $version='2005.02.08';        # Make self-creating history popup page
# $version = '2005.02.07';      # Fix parameter passing to tail_html; stuff after semicolon lost
#!$version = '2005.02.07';      # Bang in line says do not use
# $version = '2005.02.04';      # Clean up HTML formatting, add head_html and tail_html functions
#                               # Continuation line not handled
# $version = '2005.01.08';      # Initial beta release

## END HISTORY ######################################################

# and returns body (including Javascript document.writeln instructions)
# for a pop-up history window called 'pophistory'.

# First line after 'BEGIN HISTORY' is <title> text
# Splits version and comment on semi-colon
# Version must be version= then digits and periods
# Bang in line causes line to be ignored
# Disallowed: single and double quotes in comment part
# Not handled: continuation lines

# Usage:

#print "<html>
# <head>
#  <title>$title</title>
#   <script language=\"javascript\">
#    <!-- hide from old browsers...
#
#  function popuphistory() {
#    pophistory = window.open('','pophistory','')
#";
#    print make_history_popup();
#print "
#    pophistory.document.close()
#    pophistory.focus()
#  }
#";

# print $0,"\n";

  my ($line, $z, $vers, $comment);

  open MYSELF, "<$0";
    while (<MYSELF>) {
      next if (/!/);
      if (/## BEGIN HISTORY/) {
        $line = <MYSELF>;
        chomp $line;
        $line = substr($line,2);
        $z = "    pophistory.document.writeln('<html>')
    pophistory.document.writeln(' <head>')
    pophistory.document.writeln('  <title>$line</title>')
    pophistory.document.writeln(' </head>')
    pophistory.document.writeln(' <body bgcolor=white>')
    pophistory.document.writeln('  <font face=\"trebuchet, tahoma, arial, helvetica, sans serif\">')
    pophistory.document.writeln('  <center>')
    pophistory.document.writeln('   <h4>$line</h4>')
    pophistory.document.writeln('   <p>')
    pophistory.document.writeln('   <table border=0 cellpadding=10>')
    pophistory.document.writeln('    <tr>')
    pophistory.document.writeln('     <th bgcolor=lightblue>Version</th>')
    pophistory.document.writeln('     <th bgcolor=lightblue>Comments</th>')
    pophistory.document.writeln('    </tr>')
";
      } # if (/## BEGIN HISTORY/)

      if (/version/) {
        ($vers, $comment) = split (/;/,$_,2);
        $comment =~ s/#//;
        $comment =~ s(;)(<br>)g;
        chomp $comment;
        $vers =~ s/'//g;
        $vers =~ s/ //g;
        $vers =~ s/"//g;
        if ($vers =~ /version=*([0-9.]+)/) {    # pull substring out of a line
          $z .= "    pophistory.document.writeln('    <tr>')
    pophistory.document.writeln('     <th valign=top bgcolor=lightblue>$1</th>')
    pophistory.document.writeln('     <td>$comment</td>')
    pophistory.document.writeln('    </tr>')
";
        }       # (/version *([0-9]+)/)
      }  # if (/version/)

      if (/## END HISTORY/) {
        $z .= "    pophistory.document.writeln('   </table>')
    pophistory.document.writeln('   </font>')
    pophistory.document.writeln('  </center>')
    pophistory.document.writeln(' </body>')
    pophistory.document.writeln('</html>')
";
      last;
      }     # if (/## END HISTORY/)
    }     # while
  close MYSELF;
  return $z;
}
