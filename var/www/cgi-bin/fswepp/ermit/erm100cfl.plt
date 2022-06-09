#! /usr/bin/perl
#
# erm.pl
#
# ermit workhorse
# Reads user input from ermit.pl, runs WEPP, parses output files
# top adapted from wd.pl 8/28/2002

# *** check top_slope

# to do: check how leap years are handled #

#  $pt=1;	# produce probability table as output (see tie into $me below)
#  $zoop=1;
  $debug=0;
  $new_range=1;		# 2005.09.13 DEH Solidify new range values
  $new_cligen=0;	# 2005.09.13 DEH # 2005.10.12 DEH

## BEGIN HISTORY ###################################
## WEPP ERMiT version history

  $version='2005.10.25';	# Modify showtable to report run conditions<br>Stamp showtable, graph and printseds with FS WEPPrun code<br>Fix crash on bookmark of results<br>Reduce minimum probability to 1% from 5%
#  $version='2005.10.24';	# Move graphic key<br>Adjust minimum probability from 0% to 5%<br>Final range critical shear<br>Modify showtable
#  $version='2005.10.21';	# Shore up math in function whatsed and call logchange when probability is changed
#  $version='2005.10.20';	# Remove some working displays
#  $version='2005.10.18';	# Estimate I10 for erosion barriers (option A)
#  $version='2005.10.13';	# Run all lower severity scenarios (8 for H, 6 for M, 4 for L)
#  $version='2005.10.12';	# Adjust IP to account for internal WEPP intensity fudge factor,<br>Adjust low Kr value for forest
#  $version='2005.10.05';	# Correct Kr for clay range table, temporary save of working files
#  $version='2005.10.04';	# Tweak forest and range Ke (Ksat) values for CLIGEN 5.22 operation
#  $version='2005.09.30';	# New mulch tables for 47, 72, 89, 94% ground cover<br>Add a fifth (rank 75) event
#  $version='2005.09.29';	# Activate contour-felled log and wattle calculations
#  $version='2005.09.16';	# Add check for monsoonal climates (sub monsoonal) for altered recovery
#  $version='2005.09.13';	# Solidify new range values. Look for incoming switch for which CLIGEN to run.
#  $version='2005.05.24';	# Modify soil parameter values for rangeland and chaparral, and allow different tau_c for high and low severity
#  $version = '2005.04.20';	# Change <i>fire severity</i> to <i>soil burn severity</i> or <i>soil condition</i><br>Add history pop-up
# 2005.02.07 DEH Add 'flock' for WELOG
#  $version='2004.12.13';	# Add Corey Moffet and Fred Pierson to tagline
#! $version='2004.10.12';	# DEH Change mulching rate values back (underlying data not updated to match)
#		 Check SA version for .png fixes
# 2004.10.07 DEH Add readPARfile subroutine to report missing link to climate parameters
#		 Pass descpar.pl unit scheme... hmmm..
# 2004.10.05 DEH Change mulching rate values (0.5, 1, 1.5, 2 t/ha to 0.5, 1, 1.5, 2 ton/ac)
#		 Start putting contour-felled logs back in
# 2004.09.16 DEH Change @probClimate from (0.05, 0.1, 0.3, 0.5) to (0.075, 0.075, 0.20, 0.65) again
#		 Set $tp to lower limit of 0.01 to allow calculation to proceed.
# $version='2004.09.15';	# Keep first event (screws up list if it is largest of year)<br>Create gnuplot postscript file then convert .eps to .png
# 2004.09.14 DEH Finish fix for less than 50 years with runoff events
# $version='2004.09.13';	# Allow for short event list<br>$tp, $ip = <b>--</b> if peak events are <b>N/A</b>
#		 Removed $tp, $ip = '--' -- wiped out too much
# $version='2004.04.23';	# Report 10- and 30-min peak intensities in English if desired
# $version='2004.04.22';	# Pump 100-year climate files to <i>working</i> if <b>g</b> ID<br>Add storm duration estimation calculation (metric)<br>Specify <b>year <i>nn</i></b> under <b>Storm date</b>
# 19 Mar 2004 DEH change @probClimate values (0.05, 0.05, 0.10, 0.3)
#                 to                         (0.05, 0.1, 0.3, 0.5);
# 18 Mar 2004 DEH remove "Target event sediment delivery" table (popup?)
#                 add links behind printer icon for untreated, seeding, ...
# 		  change from 'for_1ofe.man' etc to '1ofe.man'
#		  change @probClimate values (0.075, 0.075, 0.20, 0.65)
#		  to                         (0.05, 0.05, 0.10, 0.3)
#		  fix spurrious value in @probSoil_mt1 (2 Mg/ha mulch) .2 to .08
#		  change &creategnuplotjclfile (smooth bezier) (station) (untreated)
#		  change base cum_prom from 0 to 0.05 (5%)
#		  break on 'showtable' results *after* first zero, not before
# 16 Mar 2004 DEH pump 20 sol, 4 slp, 4 man, 1 cli files to 'working' if 'g'
#                 create 20 WGR files for validation (Corey Moffet) if 'g'
# 20 Nov 2003 DEH handle year-1 case (don't add 0 to @previous_year)
# 25 Aug 2003 DEH complete t/ac t/ha headings; add aural indicator
# 19 Aug 2003 DEH start logging runs ($climate_name empty...?)
# 18 Aug 2003 DEH mulching amount labels to English (Later: adjust values)
#                 remove "Sediment delivery ranges from..."
#                 remove worst-case 100-yr "Sediment delivery" column
# 13 Feb 2003 DEH treat American units
# 15 Jan 2003 DEH fix variable name error in createslopefile: abb
# 19 Dec 2002 DEH tighten up output; add format report of input 

# David Hall, USDA Forest Service, Rocky Mountain Research Station
# William J. Elliot, USDA Forest Service, Rocky Mountain Research Station
## END HISTORY ###################################

#   $rfg = 20;

#=========================================================================

   &ReadParse(*parameters);

#   $new_range=1 if ($parameters{'new_range'} =~ 'on');		# 2005.09.15 DEH temporary
#   $new_cligen=1 if ($parameters{'new_cligen'} =~ 'on');	# 2005.09.13 DEH
#   $rtc=1 if ($parameters{'rtc'} =~ 'on');  			# 2005.10.19 DEH
   $rtc=0;							# 2005.10.24 DEH
   $pt=1 if ($parameters{'ptcheck'} =~ 'on');  			# 2005.10.13 DEH
   $me=$parameters{'me'};		# $pt=1 if ($me eq 'z');# 2005.03.24 DEH
   $units=$parameters{'units'};
   $CL=$parameters{'Climate'};		# get Climate (file name base)
   $climate_name=$parameters{'climate_name'};   # requested climate #
   $SoilType=$parameters{'SoilType'};
#  $soil_name=$parameters{'soil_name'};
   $rfg=$parameters{'rfg'};
   $vegtype=$parameters{'vegetation'};
   $top_slope=$parameters{'top_slope'};
   $avg_slope=$parameters{'avg_slope'};
   $toe_slope=$parameters{'toe_slope'};
   $hillslope_length=$parameters{'length'};
   $severityclass=$parameters{'severity'};
   $shrub=$parameters{'pct_shrub'};
   $grass=$parameters{'pct_grass'};
   $bare=$parameters{'pct_bare'};
   $achtung=$parameters{'achtung'};
   $action=$parameters{'actionc'} . 
           $parameters{'actionw'};
   if ($achtung . $action eq '') {&bomb}					# 2005.10.25 DEH

   $vegtype_x = $vegtype;							# 2004.10.07 DEH
   $vegtype_x = 'chaparral' if ($vegtype eq 'chap');				# 2004.10.07 DEH

   $wgr = 1 if ($me eq 'g');							# DEH 2004.03.16
### $wgr=1; #$#$$#
#   $debug = 1 if ($wgr);							# DEH 2004.03.18

   if ($SoilType eq 'clay') {
     $soil_texture = 'clay loam';
     $soil_symbols = '(MH, CH)';
     $soil_description = 'Shales and similar decomposing fine-grained sedimentary rock';
   }
   elsif ($SoilType eq 'loam') {
     $soil_texture = 'loam';
     $soil_symbols = '';
     $soil_description = '';
   }
     elsif ($SoilType eq 'sand') {
     $soil_texture = 'sandy loam';
     $soil_symbols = '(SW, SP, SM, SC)';
     $soil_description = 'Glacial outwash areas; finer-grained granitics and sand';
   }
   elsif ($SoilType eq 'silt') {
     $soil_texture = 'silt loam';
     $soil_symbols = '(ML, CL)';
     $soil_description = 'Ash cap or alluvial loess';
   }

   $severityclass_x = 'high' if ($severityclass eq 'h');
   $severityclass_x = 'moderate' if ($severityclass eq 'm');
   $severityclass_x = 'low' if ($severityclass eq 'l');

   $rfg+=0;
   $rfg=05 if ($rfg<05);
   $rfg=85 if ($rfg>85);

   $wepphost = "localhost";
   if (-e "../wepphost") {
     open HOST, "<../wepphost";
       $wepphost = lc(<HOST>);
       chomp $wepphost;
       if ($wepphost eq "") {$wepphost = "Localhost"}
     close HOST;
   }

   $platform = "unix";
   if (-e "../platform") {
     open PLATFORM, "<../platform";
       $platform = lc(<PLATFORM>);
       chomp $platform;
       if ($platform eq "") {$platform = "unix"}
     close PLATFORM;
   }

################  CUSTOM CLIMATE ############################

   if (lc($action) =~ /custom/) {
     $comefrom = "http://" . $wepphost . "/cgi-bin/fswepp/ermit/ermit.pl";
     if ($platform eq "pc") {
       exec "perl ../rc/rockclim.pl -server -i$me -u$units $comefrom"
     }
     else {
       exec "../rc/rockclim.pl -server -i$me -u$units $comefrom"
     }
     die
   }            # /custom/

############### DESCRIBE CLIMATE #################

   if (lc($achtung) =~ /describe climate/) {
     $comefrom = "http://" . $wepphost . "/cgi-bin/fswepp/ermit/ermit.pl";
     if ($platform eq "pc") {
#       exec "perl ../rc/descpar.pl $CL $comefrom"
#     }
#     else {
#       exec "../rc/descpar.pl $CL $comefrom"
#     }
       exec "perl ../rc/descpar.pl $CL $units $comefrom"
     }
     else {
       exec "../rc/descpar.pl $CL $units $comefrom"
     }
     die
   }            # /describe climate/

####################  set up file names and paths

   if ($platform eq "pc") {
     if (-e 'd:/fswepp/working') {$working = 'd:\\fswepp\\working'}
     elsif (-e 'c:/fswepp/working') {$working = 'c:\\fswepp\\working'}
     else {$working = '..\\working'}
     $div='\\';
   }
   else {
     $working = '../working';
     $div='/';
   }

##### set up file names and paths #####

   $unique='wepp-' . $$;
   $workingpath    = $working . $div . $unique;
   $datapath       = 'data' . $div;
   $responseFile   = $workingpath . '.in';
   $outputFile     = $workingpath . '.out';
   $stoutFile      = $workingpath . '.stout';
   $sterrFile      = $workingpath . '.sterr';
   $soilFile       = $workingpath . '.sol';
   $slopeFile      = $workingpath . '.slp';
   $CLIfile        = $workingpath . '.cli';        #  open INCLI, "<$CLIfile" or die;
   $shortCLIfile   = $workingpath . '_' . '.cli';  #  open OUTCLI, ">$shortCLIfile";
   $manFile        = $workingpath . '.man';
   $manFile        = $datapath    . 'high100.man';
   $eventFile      = $workingpath . '.event100';   # DEH 2003.02.06
   $tempFile       = $workingpath . '.temp';
   $gnuplotdatafile= $workingpath . '.gnudata';
   $gnuplotjclfile = $workingpath . '.gnujcl';
   $gnuplotgraphpng   = $workingpath . '.png';
   $gnuplotgrapheps   = $workingpath . '.eps';
   $gnuplotgraphpl = "http://$wepphost/cgi-bin/fswepp/ermit/servepng.pl?graph=$unique";
   $gnuplotgraphpath = "http://$wepphost/cgi-bin/fswepp/working/$unique.png";

# CLIGEN paths

   $PARfile = $CL . '.par';
   $crspfile = $workingpath . 'c.rsp';
   $cstoutfile = $workingpath . 'c.out';

# flow paths

#  $slopeFilePath = $workingpath . '.slp';
#  $stoutFilePath = $workingpath . 'stout';
#  $sterrFilePath = $workingpath . 'sterr';
   $evoFile = $workingpath . '.evo';
   $ev_by_evFile = $workingpath . '.event';


################## DESCRIBE SOIL ################

   if (lc($achtung) =~ /describe soil/) {   ##########

     $units=$parameters{'units'};
     $SoilType=$parameters{'SoilType'};  # get SoilType (loam, sand, silt, clay, gloam, gsand, gsilt, gclay)

     $comefrom = "http://" . $wepphost . "/cgi-bin/fswepp/ermit/ermit.pl";
#     $soilFilefq = $datapath . $soilFile;
     print "Content-type: text/html\n\n";
     print "<HTML>\n";
     print " <HEAD>\n";
     print "  <TITLE>ERMiT -- Soil Parameters</TITLE>\n";
     print " </HEAD>\n";
     print '<BODY background="/fswepp/images/note.gif" link="#ff0000">
  <font face="Arial, Geneva, Helvetica">
  <blockquote>
  <table width=95% border=0>
    <tr><td>
       <a href="JavaScript:window.history.go(-1)">
       <IMG src="http://',$wepphost,'/fswepp/images/ermit.gif"
       align="left" alt="Back to FS WEPP menu" border=1></a>
    <td align=center>
       <hr>
       <h2>ERMiT Soil Texture Properties</h2>
       <hr>
    <td>
       <A HREF="http://',$wepphost,'/fswepp/docs/ermitdoc.html">
       <IMG src="http://',$wepphost,'/fswepp/images/epage.gif"
        align="right" alt="Read the documentation" border=0></a>
    </table>
';
     if ($debug) {print "Action: '$action'<br>\nAchtung: '$achtung'<br>\n"}

     print $soil_texture,' ', $soil_symbols, '<br>', $soil_description,"\n";

     open SOIL, ">$soilFile";
       $s='hhh';
       $k=4;
       $soilfileitself = &createsoilfile;
       print SOIL $soilfileitself;
     close SOIL;

     print "<hr><b><pre>\n\n";
#    print $soilFile,"\n";

     open SOIL, "<$soilFile";
     $weppver = <SOIL>;
     $comment = <SOIL>;
     while (substr($comment,0,1) eq "#") {
       chomp $comment;
       print $comment,"\n";
       $comment = <SOIL>;
     }

     print "</pre></b>
 <center>
 <table border=1 cellpadding=8>
";

#      $solcom = $comment;
#     $record = <SOIL>;
    
     @vals = split " ", $comment;
     $ntemp = @vals[0];      # no. flow elements or channels
     $ksflag = @vals[1];     # 0: hold hydraulic conductivity constant
                             # 1: use internal adjustments to hydr con

     for $i (1..$ntemp) {
       print '<tr><th colspan=3 bgcolor="85d2d2"><font face="Arial, Geneva, Helvetica">',"\n";
       print "Element $i --- \n";
       $record = <SOIL>;
       @descriptors = split "'", $record;
       print "@descriptors[1]   ";                # slid: Road, Fill, Forest
       print "<br>Soil texture: @descriptors[3]</font></th></tr>\n";    # texid: soil texture
       ($nsl,$salb,$sat,$ki,$kr,$shcrit,$avke) = split " ", @descriptors[4];
#      @vals = split " ", @descriptors[4];
#      print "No. soil layers: $nsl\n";
       print "<tr><th align=left><font face='Arial, Geneva, Helvetica'>Albedo of the bare dry surface soil</font></th><td align='right'><font face='Arial, Geneva, Helvetica'>$salb</font></td><td></td></tr>\n";
       print "<tr><th align=left><font face='Arial, Geneva, Helvetica'>Initial saturation level of the soil profile porosity</font></th><td align='right'><font face='Arial, Geneva, Helvetica'>$sat</font></td><td><font face='Arial, Geneva, Helvetica'>m m<sup>-1</sup></font></td></tr>\n";
       print "<tr><th align=left><font face='Arial, Geneva, Helvetica'>Baseline interrill erodibility parameter (<i>k<sub>i</sub></i> )<td align='right'><font face='Arial, Geneva, Helvetica'>$ki</font></td><td><font face='Arial, Geneva, Helvetica'>kg s m<sup>-4</sup></font></td></tr>\n";
       print "<tr><th align=left><font face='Arial, Geneva, Helvetica'>Baseline rill erodibility parameter (<i>k<sub>r</sub></i> )<td align='right'><font face='Arial, Geneva, Helvetica'>$kr</font></td><td><font face='Arial, Geneva, Helvetica'>s m<sup>-1</sup></font></td></tr>\n";
       print "<tr><th align=left><font face='Arial, Geneva, Helvetica'>Baseline critical shear parameter (&tau;<sub>c</sub>)<td align='right'><font face='Arial, Geneva, Helvetica'>$shcrit</font></td><td><font face='Arial, Geneva, Helvetica'>N m<sup>-2</sup></font></td></tr>\n";
       print "<tr><th align=left><font face='Arial, Geneva, Helvetica'>Effective hydraulic conductivity of surface soil<td align='right'><font face='Arial, Geneva, Helvetica'>$avke</font></td><td><font face='Arial, Geneva, Helvetica'>mm h<sup>-1</sup></font></td></tr>\n";
       for $layer (1..$nsl) {
         $record = <SOIL>;
         ($solthk,$sand,$clay,$orgmat,$cec,$rfg) = split " ", $record;
         print "<tr><td><br></td><th colspan=2 bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>layer $layer</font></th></tr>\n";
         print "<tr><th align=left><font face='Arial, Geneva, Helvetica'>Depth from soil surface to bottom of soil layer</font></td><td align='right'><font face='Arial, Geneva, Helvetica'>$solthk</font></td><td><font face='Arial, Geneva, Helvetica'>mm</font></td></tr>\n";
         print "<tr><th align=left><font face='Arial, Geneva, Helvetica'>Percentage of sand</font></td><td align='right'><font face='Arial, Geneva, Helvetica'>$sand</font></td><td><font face='Arial, Geneva, Helvetica'>%</font></td></tr>\n";
         print "<tr><th align=left><font face='Arial, Geneva, Helvetica'>Percentage of clay</font></td><td align='right'><font face='Arial, Geneva, Helvetica'>$clay</font></td><td><font face='Arial, Geneva, Helvetica'>%</font></td></tr>\n";
         print "<tr><th align=left><font face='Arial, Geneva, Helvetica'>Percentage of organic matter (by volume)</font></th><td align='right'><font face='Arial, Geneva, Helvetica'>$orgmat</font></td><td><font face='Arial, Geneva, Helvetica'>%</font></td></tr>\n";
         print "<tr><th align=left><font face='Arial, Geneva, Helvetica'>Cation exchange capacity</font></td><td align='right'><font face='Arial, Geneva, Helvetica'>$cec</font></td><td><font face='Arial, Geneva, Helvetica'>meq per 100 g of soil</font></td></tr>\n";
         print "<tr><th align=left><font face='Arial, Geneva, Helvetica'>Percentage of rock fragments (by volume)</font></th><td align='right'><font face='Arial, Geneva, Helvetica'>$rfg</font></td><td><font face='Arial, Geneva, Helvetica'>%</font></td></tr>\n";
       }
     }
     close SOIL;
     print '</table><p><hr><p>';
     print '  </center><pre>';
     print $soilfileitself;
     print '
    </pre>
   <p>
  </blockquote>
 </body>
</html>
';
     die
   }            #  /describe soil/

# *******************************

    $years2sim=100;

# ######### for logging ERMiT run ######################

   @months=qw(January February March April May June July August September October November December);
   @days=qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);
   $ampm[0] = "am";
   $ampm[1] = "pm";

   $ampmi = 0;
   ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime;
   if ($hour == 12) {$ampmi = 1}
   if ($hour > 12) {$ampmi = 1; $hour = $hour - 12}
   $thisyear = $year+1900;
   $thissyear=$thisyear;

   $host = $ENV{REMOTE_HOST};
   $host = $ENV{REMOTE_ADDR} if ($host eq '');
   $user_really=$ENV{'HTTP_X_FORWARDED_FOR'};           # DEH 11/14/2002
   $host = $user_really if ($user_really ne '');        # DEH 11/14/2002

# ########### RUN WEPP for 100-year simulation ######################

# open TEMP...
   open TEMP, ">$tempFile";

#   $unique='wepp-' . $$;
   if ($debug) {print TEMP "Unique? filename= $unique\n<BR>"}

  $evo_file = $eventFile;

#   $host = $ENV{REMOTE_HOST};

#   $rcin = &checkInput;
#   if ($rcin >= 0) {

  $s = 'hhh';

# $avg_slope - average surface slope gradient
# $toe_slope - surface slope toe gradient
# $hillslope_length

   $avg_slope += 0;
   $toe_slope += 0;
   $hillslope_length += 0;
   $hillslope_length_m = $hillslope_length;
   if ($units eq 'ft') {$hillslope_length_m *= 0.3048}

#     print "Content-type: text/html\n\n";
#     print "<HTML>\n";
#     print " <HEAD>\n";
#     print "  <TITLE>ERMiT -- Preliminary results</TITLE>
#   <script language=\"Javascript\">
#   </HEAD>\n";
#     print ' <BODY background="http://',$wepphost,
#          '/fswepp/images/note.gif" link="#ff0000"
#           onload="removeSpinner()">
#  <font face="Arial, Geneva, Helvetica">
#';
  if ($debug) { print TEMP "
  <blockquote>
   <pre>
    ERMiT version $version
    I am $me
    units = $units
    climate file = $CL
    climate_name = $climate_name
    soil type = $SoilType
    soil texture = $soil_texture
    vegtype = $vegtype
    avg_slope = $avg_slope
    toe_slope = $toe_slope
    hillslope_length = $hillslope_length $units
    severityclass = $severityclass
    achtung = $achtung 

    length = $hillslope_length_m m
<font face=\"courier, mono\">
    Create 100-year slope file       $slopeFile
           100-year management file  $manFile
    Create 100-year climate file     $CLIfile
                            from     $PARfile
    Create 100-year soil file        $soilFile
    Create WEPP Response File        $responseFile
           temporary file            $tempFile
</font>
";
    }

     if ($platform eq "pc") {
       @args = (".\\wepp <$responseFile >$stoutFile");
     }
     else {
       @args = ("../wepp <$responseFile >$stoutFile 2>$sterrFile");
     }
     if ($debug) {
      print TEMP "@args
    </pre>
   </blockquote>
";
     }

 # die;

     if ($debug) {print TEMP "Creating 100-year slope file $slopeFile"}
     open SLOPE, ">$slopeFile";
       print SLOPE &createSlopeFile;
     close SLOPE;
     if ($debug) {$printfilename = $slopeFile; &printfile}
     if ($debug) {print TEMP "100-year management file "}
#     if ($debug) {$printfilename = $manFile; &printfile}
     if ($debug) {print TEMP "Creating 100-year climate file $CLIfile from $PARfile<br>"}
     &createCligenFile;
     if ($debug) {print TEMP "Creating 100-year soil file<br>\n"}
     open SOL, ">$soilFile";
       $s='hhh';
       $k=4;
       print SOL &createsoilfile;
     close SOL;

     open SOL, ">../working/soil100.txt";
       $s='hhh';
       $k=4;
       print SOL &createsoilfile;
     close SOL;
#$#$#$

     if ($debug) {$printfilename = $soilFile; &printfile}
     if ($debug) {print TEMP "Creating WEPP Response File "}
     &CreateResponseFile;
     if ($debug) {$printfilename = $responseFile; &printfile}

#    @args = ("nice -20 ./wepp <$responseFile >$stoutFile 2>$sterrFile");
     if ($platform eq "pc") {
       @args = (".\\wepp <$responseFile >$stoutFile");
     }
     else {
       @args = ("../wepp <$responseFile >$stoutFile 2>$sterrFile");
     }
     system @args;

###
# die 'temporary';
###

#     unlink $CLIfile;    # be sure this is right file .....     # 2/2000
     &readWEPPresults;

#         $storms+=0;
#         $rainevents+=0;
#         $snowevents+=0;
#         $precip+=0;
#         $rro+=0;
#         $sro+=0;
#         $syr+=0;
#         $syp+=0;

  $precipunits = 'mm';
  $intunits = 'mm h<sup>-1</sup>';
# $sedunits = 'kg m<sup>-1</sup>';
  $sedunits = 't ha<sup>-1</sup>';
  $alt_sedunits = 't / ha';
  $precipf = $precip;
  $rrof = $rro;
  $srof = $sro;
  $syraf = $syr;
  $sypaf = $syp;

  if ($units eq 'ft') {
    $precipunits = 'in';
    $intunits = 'in h<sup>-1</sup>';
    $sedunits = 'ton ac<sup>-1</sup>';
    $alt_sedunits = 'ton / ac';
    $precipf = sprintf '%9.2g', $precip/25.4;
    $rrof = sprintf '%9.2g', $rro/25.4;
    $srof = sprintf '%9.2g', $sro/25.4;
  }

         print TEMP "<center><p>
  <table cellspacing=8 bgcolor='ivory'>
   <tr>
    <th colspan=5 bgcolor=#85D2D2>
     $years2sim - YEAR MEAN ANNUAL AVERAGES
    </th>
   </tr>
   <tr>
    <td align=right><b>$precipf</b></td>
    <td><b>$precipunits</b></td>
    <td>annual precipitation from</td>
    <td align=right>$storms</td>
    <td>storms</td>
   </tr>
   <tr>
    <td align=right><b>$rrof</b></td>
    <td><b>$precipunits</b>    </td>
    <td>annual runoff from rainfall from</td>
    <td align=right>$rainevents</td>
    <td>events</td>
   </tr>
   <tr>
    <td align=right><b>$srof</b></td>
    <td><b>$precipunits</b></td>
    <td>annual runoff from snowmelt or winter rainstorm from</td>
    <td align=right>$snowevents</td>
    <td>events</td>
   </tr>
  </table>
";

# }

# goto cutout;

# ====================== parse_evo_s.pl ======================================

# D.E. Hall 08 June 2001  USDA FS Moscow, ID

   if ($debug) {print TEMP "\nParse WEPP event output EVO file: $eventFile<br>\n";}

#   @selected_ranks = (5,10,20,50);

sub numerically { $a <=> $b }

   $evo_file = "<$eventFile";

    open EVO, $evo_file;
    while (<EVO>) {				# skip past header lines
#      if ($_ =~ /------/) {last}
      if ($_ =~ /---/) {last}
    }

# testing here ###
    print TEMP $_ if ($zoop); 	# verify location

    $keep = <EVO>;
    ($day1,$month1,$year1,$precip1,$runoff1,$rest1) = split ' ', $keep, 6;
    $runoff1+=0; $year1+=0;			# force to numeric
    @max_run[$yr] = $keep;			# store as best so far 2004.09.15
    @run_off[$yr] = $runoff1;			# store as best so far 2004.09.15
# testing here ###
   print TEMP "day: $day1\tmonth: $month1\tyear: $year1\trunoff:$runoff1\n" if ($zoop);

# testing here ###
    print TEMP "$evo_file -- maximal runoff event for year, sorted by year\n\n" if ($zoop);

    while (<EVO>) {
      ($day,$month,$year,$precip,$runoff,$rest) = split ' ', $_, 6;
      $runoff+=0; $year+=0;			# force to numeric
      if ($year == $year1) {			# same year
        if ($runoff > $runoff1) {		# new runoff larger
          $keep = $_;				# keep the new one
          $runoff1 = $runoff;
          @max_run[$yr] = $keep;
          @run_off[$yr] = $runoff;
        }
        else {					# new runoff small
        }
      }
      else {				# new year
# testing here ###
        print TEMP $keep if ($zoop);			# print last year's max runoff entry
        $yr++;				
        $keep = $_;			# update this year's starting line
        @max_run[$yr] = $keep;
        @run_off[$yr] = $runoff;
        $year1 = $year;			# update year
	$runoff1 = $runoff;	  	# update this year's first runoff
      }
    }
					# handle final year
    if ($runoff > $runoff1) {		# new runoff larger
      $keep = $_;			# keep the new one
      $runoff1 = $runoff;
      @max_run[$yr] = $keep;
      @run_off[$yr] = $runoff;
    }
# testing here ###
    print TEMP $keep if ($zoop);			# print final year's max runoff entry
    close EVO;

  
if ($debug) {$, = " "; print TEMP "\n",@run_off,"\n"; $, = "";}

# index-sort runoff		# index sort from "Efficient FORTRAN Programming"
				# see built-in index sort elsewhere in code...

  $years = $#run_off;
  for $i (0..$years) {@indx[$i]=$i}	# set up initial index into array
  for $i (0..$years-1) {
    $m = $i;
    for $j ($i+1..$years) {
      $m = $j if $run_off[$indx[$j]] > $run_off[$indx[$m]]
    }
    $temp     = $indx[$m];
    $indx[$m] = $indx[$i];
    $indx[$i] = $temp;
  }

  if ($debug) {print TEMP "\n -- maximal runoff for each year, sorted by runoff\n\n";}

  # print TEMP $#run_off;
# testing here ###
  if ($zoop) {
    for $i (0..$years) {print TEMP @run_off[$indx[$i]],"  "}
    print TEMP "\n\n<p>"; $, = "<br>";
    for $i (0..$years) {print TEMP @max_run[$indx[$i]]}
  }

####****###

# select [5th, 10th, 20th, 50th, 75th] largest runoff event lines

  $years1=$years+1;				#  Number of years with runoff
  @selected_ranks = (5,10,20,50,75);		# 2005.09.30 If too few, do we have to adjust percentages?
  @selected_ranks = (5,10,20,50) if ($years1<75);		# 2005.09.30
  @selected_ranks = (5,10,20)    if ($years1<50);
  @selected_ranks = (5,10)       if ($years1<20);
  @selected_ranks = (5)          if ($years1<10);
  @selected_ranks = ()           if ($years1<5);

# print TEMP "<p>Runoff events range from ",@run_off[$indx[0]]," down to ",@run_off[$indx[$years]]," mm\n";
# print TEMP '<br>',@years2run,"<br>\n";
  print TEMP "<br>$years1 years out of 100 had runoff events.<br>\n" if ($years<50);
#  print TEMP "<br>Runoff events (mm) \n";
#  foreach $runner (0..$years) {
#    print TEMP @run_off[$indx[$runner]],"\n";
#  }

  for $i (0..$#selected_ranks) {
    @selected_ranks[$i] -= 1;			# account for base zero
    ($day,$month,$year,$precip,$runoff,$rest) = split ' ', @max_run[$indx[$selected_ranks[$i]]], 6;
    if ($year+0 > 0) {				# DEH crash fix start if too few events 2004.09.13
      ($interrill_det,$avg_det,$max_det,$det_pt,$avg_dep,$max_dep,$dep_pt,$sed_del,$enrich) = split ' ', $rest; 
      @sed_delivery[$i] = $sed_del;
      @precip[$i] = $precip;
      @day[$i] = $day;
      @month[$i] = $month;
      @selected_year[$i] = $year;
      @previous_year[$i] = $year-1;   # DEH 2003/11/20 ***
      if ($year == 1) {@previous_year[$i] = $year};  # DEH 2003/11/20 ***
    }
  }

#print TEMP "@selected_ranks\n";

    ($max_day,$max_month,$max_year,$precip,$runoff,$rest) = split ' ', @max_run[@indx[0]], 6;
    ($interrill_det,$avg_det,$max_det,$det_pt,$avg_dep,$max_dep,$dep_pt,$sed_del,$enrich) = split ' ', $rest; 
    @monthnames = ('', 'January', 'February', 'March', 'April', 'May','June', 'July', 'August', 'September', 'October', 'November', 'December');

#### 2003 units
      if ($units eq 'ft') {
#        $run_off_f = sprintf '%9.2f', @run_off[$indx[0]]/25.4;
         $run_off_f = sprintf '%9.2f', $runoff/25.4;
         $precip_f = sprintf '%9.2f', $precip/25.4;
         $sed_del_f = sprintf '%9.2f', $sed_del / $hillslope_length_m * 4.45;
            # kg per m / m length * 4.45 --> t per ac
      }
      else {
#        $run_off_f = @run_off[$indx[0]];
         $run_off_f = $runoff;
         $precip_f = $precip;
         $sed_del_f = $sed_del / $hillslope_length * 10;
            # kg per m / m length * 10 --> t per ha
      }
#### 2003 units

###############ZZZZZZZZZZZZZZZZZZZZZ################

@years2run = sort numerically @selected_year, @previous_year;
 if ($debug) {print TEMP "\nYears to run: @years2run\n";}

# remove duplicates / clean up

# $year_count = $#years2run;
  $year_count = 1;			# count unique years
  for $i (1 .. $#years2run) {
    $year_count += 1 if (@years2run[$i] ne @years2run[$i-1]);
  }
  if ($debug) {print TEMP "<br>$year_count unique years<br></center>\n";}

# pull years out of climate file

# open climate file

# ===========================  pullcli.pl  ===================================

# pullcli.pl -- pull specified years out of .CLI file
# D. Hall USDA FS RMRS Moscow, ID   June 2001

## sub numerically { $a <=> $b }

#  print TEMP "@month<br>\n@day<br>@selected_year<br>@years2run<br>\n";    # @@@@@@@@@@@@@

  sub monsoonal {

###### 2005.09.16 DEH Look for monsoonal climates begin
# 'Monsoonal' if
#     (1) total annual precip is less than 600 mm and
#     (2) Jul, Aug, Sep precip is greater than 30% of annual precip
# Could be intersperced with code to create short climate file (following),
#  but we'll just do it simplemindedly for now
# Read 100-year CLI climate file header for "observed precipitation" by month

  my $monsoon=0;

  open INCLI, "<$CLIfile" or goto bailer;

# read CLI file $CLIfile
# report
#   $obannual    Total precip (mm)
#   $obJAS       J_A_S precip (mm)
#   $pctJAS      $obJAS/$obannual*100

###################
#5.22564
#   1   0   0
#  Station:  Cheesman 1 +                                   CLIGEN VER. 5.22564 -r:    0 -I: 0
# Latitude Longitude Elevation (m) Obs. Years   Beginning year  Years simulated Command Line:
#    39.22  -105.28        2099          45           1             100          -i../working/public/129_82_114_11_v.par -y100 -b1 -t5 -o../working/wepp-16188.cli
# Observed monthly ave max temperature (C)
#   7.5   8.8  10.6  15.0  19.9  26.0  28.9  27.7  24.5  19.2  11.8   8.1
# Observed monthly ave min temperature (C)
# -10.8 -10.0  -7.5  -3.3   1.2   5.8   8.5   7.7   3.5  -2.2  -7.1 -10.0
# Observed monthly ave solar radiation (Langleys/day)
# 207.0 277.0 408.0 472.0 480.0 548.0 540.0 459.0 426.0 320.0 368.0 188.0
# Observed monthly ave precipitation (mm)
#   0.0   0.0   0.0   0.0   0.0   0.0  66.6  60.9  27.8  28.1  19.9  15.3
# da mo year  prcp  dur   tp     ip  tmax  tmin  rad  w-vl w-dir  tdew
#             (mm)  (h)               (C)   (C) (l/d) (m/s)(Deg)   (C)
#  1  1    1   0.0  0.00 0.00   0.00  -0.4 -14.6 157.  5.8  252. -16.3
#  2  1    1   0.0  0.00 0.00   0.00   1.1 -14.3 242.  3.0   97. -13.1

  my ($objan,$obfeb,$obmar,$obapr,$obmay,$objun,$objul,$obaug,$obsep,$oboct,$obnov,$obdec);

  my $cliver=<INCLI>; chomp $cliver;
  my $trio=<INCLI>;
  my $station=<INCLI>; # chomp $station; $station=substr($station,13,46);
  my $header=<INCLI>;
  my $line=<INCLI>;
  # ($lat,$lon,$ele,$yobs,$ybeg,$ysim,$rest)=split ' ', $line;
  $line=<INCLI>;
  $line=<INCLI>;
  $line=<INCLI>;
  $line=<INCLI>;
  $line=<INCLI>;
  $line=<INCLI>;
  $line=<INCLI>;
  $line=<INCLI>;      # Observed monthly ave precipitation (mm)
  close INCLI;

  ($objan,$obfeb,$obmar,$obapr,$obmay,$objun,$objul,$obaug,$obsep,$oboct,$obnov,$obdec)=split ' ',$line;
  $obannual=$objan+$obfeb+$obmar+$obapr+$obmay+$objun+$objul+$obaug+$obsep+$oboct+$obnov+$obdec;
  $obJAS=$objul+$obaug+$obsep;
#  print "$station\n$ysim years  CLIGEN version $cliver\n";
#  print "Observed annual precip: $obannual mm\n";
#  print "Observed JAS precip:    $obJAS mm\n";
  $pctJAS=0;
  if ($obannual > 0.00001) {
    $pctJAS=100*$obJAS/$obannual;
    $pctJAS=sprintf '%.2f', $pctJAS;
  #  print "Percent JAS precip:     $pctJAS\n";
    if ($obannual<600 && $pctJAS>30) {$monsoon=1}
  }
bailer:
  return $monsoon;
###### 2005.09.16 DEH Look for monsoonal climates end
}

  $monsoon=&monsoonal;
###  $monsoon=1;	# TEMP !!!

  open INCLI, "<$CLIfile" or goto bail;
  open OUTCLI, ">$shortCLIfile";

  for $i (0..3) {
    $line = <INCLI>;
    print OUTCLI $line;
  }
#  Latitude Longitude Elevation (m) Obs. Years   Beginning year  Years simulated
#    21.98  -159.35          36          43           1             100
  $line = <INCLI>;
  chomp $line;
  ($lat, $long, $elev, $obs_yrs, $beg_year, $years_sim) = split ' ',$line;
  $beg_year = @years2run[0];
#  $years_sim = $#years2run;
  print OUTCLI "   $lat  $long       $elev           $obs_yrs          $beg_year              $year_count\n";
  for $i (5..14) {
    $line = <INCLI>;
    print OUTCLI $line;
  }

if ($debug) {print TEMP " running @years2run<br>\n"}
  $numyears = $#years2run;
  $lastyear = 0;			# prime starting year
  $dumb = '31 12 0';			# prime last year's final day entry da mo yr
  for $i (0..$numyears) {
    $thisyear = @years2run[$i];
    if ($thisyear eq '' ||		# blank if beyond number of years with events
        $thisyear < 1 || 		# year = -1 if no previous year in event file
        $thisyear == $lastyear) {
          if ($debug) {print TEMP "Bailing on $thisyear\n"}
          next
    }	# bail
    else {
      if ($debug) {print TEMP "<br>Seeking year $thisyear:  ";}
#      print TEMP "<br>Seeking year $thisyear:  ";
      $yeardiff = $thisyear - $lastyear;
      $lastyear = $thisyear;		# prepare next year's lastyear
#      last if $yeardiff < 1;		# should have been taken care of: sort & same
      $daydiff = 364 * ($yeardiff-1);	# ignoring leaps for now
      if ($debug) {print TEMP "daydiff: $daydiff\n";}
      for $day (1..$daydiff) {
        $dumb = <INCLI>;		# skip to near start of correct year
#       print TEMP "skipping $dumb";
      }
      					# find start of year
nextday:
      ($da,$mo,$yr,$rest) = split ' ',$dumb;
#      print TEMP "$da $mo $yr\n";
      if ($mo < 12) { $dumb = <INCLI>; goto nextday }
      if ($da < 31) { $dumb = <INCLI>; goto nextday }
# @@@@@@@@@@@@@
#      $my_index = -1;
#      for $k (0..$#selected_year) {  print TEMP "$yr @selected_year[$k]<br>\n";
#        if ($yr+2 == @selected_year[$k]) {
#          $my_index = $k;
#          print TEMP "Year: $yr+2, Index $my_index<br>\n";    # @@@@@@@
#        }
#      }
      for $day (1..364) {
        $line = <INCLI>;
####    ($da,$mo,$yr,$pcpp,$durr,$tp,$ip,$rest) = split ' ',$line;   # DEH duration 040422
        print OUTCLI $line;
#        if ($my_index > -1) {
#          if ($mo == @month[$my_index] && $da == @day[$my_index]) {    # @@@@@@@@@@@@@@@@@@@@
#            @duration[$yr] = $durr;
#            print TEMP "$da $mo $yr $pcpp $durr<br>\n" ; #if correct day...  DEH duration
#          }
#        }
      }
      ($da,$mo,$yr,$pcpp,$durr,$tp,$ip,$rest) = split ' ',$line;   # DEH duration 0404022
      while ($da < 31) {
        $line = <INCLI>;
#       print "$yr leap\n";
        print OUTCLI $line;
        ($da,$mo,$yr,$pcpp,$durr,$tp,$ip,$rest) = split ' ',$line;      # DEH duration 040422
      }
    }
  }

  close INCLI;
  close OUTCLI;

  if ($wgr) {								# DEH 040316
#    @args = "cp $shortCLIfile /var/www/html/fswepp/working/wepp.cli";	# DEH 040316
#    system @args;							# DEH 040316
    `cp $CLIfile /var/www/html/fswepp/working/wepp100.cli`;		# DEH 040422
    `cp $shortCLIfile /var/www/html/fswepp/working/wepp.cli`;		# DEH 040316
    `cp data/high100.man /var/www/html/fswepp/working/high100.man`;	# DEH 040316
    `cp data/1ofe.man /var/www/html/fswepp/working/1ofe.man`;		# DEH 040318
    `cp data/2ofe.man /var/www/html/fswepp/working/2ofe.man`;		# DEH 040318
    `cp data/3ofe.man /var/www/html/fswepp/working/3ofe.man`;		# DEH 040318
    `cp $eventFile /var/www/html/fswepp/working/event100`;              # DEH 040913
  }									# DEH 040316

skip:
###############ZZZZZZZZZZZZZZZZZZZZZ################

  $durr = '-';
  $lookfor = sprintf ' %2d %2d  %3d ', $max_day, $max_month, $max_year;
#  print TEMP "[$lookfor]";

  open CLIMATE, "<$CLIfile";
# open CLIMATE, "<$shortCLIfile";
  while (<CLIMATE>) {
    if ($_ =~ $lookfor) {
      ($d_day, $d_month, $d_year, $d_pcp, $durr, $tp, $ip) = split ' ' ,$_; # DEH 040422
      last
    }
  }
  close CLIMATE;

    $i10w=0;					# weighted i10 2005.10.18 DEH
    @max_time_list = (10, 30);			# target durations times (min)
    $prcp = $d_pcp;
    $dur = $durr;
$ip*=0.7;					# 2005.10.12 DEH counteract WEPP fudge factor
    &peak_intensity;

    if ($units eq 'ft') {
      @i_peak[0] = sprintf '%9.2f', @i_peak[0]/25.4 if (@i_peak[0] ne 'N/A');
      @i_peak[1] = sprintf '%9.2f', @i_peak[1]/25.4 if (@i_peak[1] ne 'N/A');
    }
    else {
      @i_peak[0] = sprintf '%9.2f', @i_peak[0] if (@i_peak[0] ne 'N/A');
      @i_peak[1] = sprintf '%9.2f', @i_peak[1] if (@i_peak[1] ne 'N/A');
    }
#    if (@i_peak[0] eq 'N/A' || @i_peak[1] eq 'N/A') {
#      $tp='--'; $ip='--';				# 2004.09.13
#    }

print TEMP "<p>
       <table border=1 cellpadding=8 bgcolor='ivory'>
        <tr><th bgcolor='#33ddff'>Ranking of event<br>(return interval)
         <th bgcolor='#33ddff'>Storm<br>Runoff<br>($precipunits)
         <th bgcolor='#33ddff'>Storm<br>Precipitation<br>($precipunits)
         <th bgcolor='#33ddff'>Storm<br>Duration<br>(h)
         <!-- th bgcolor='#ffddff' --><!-- tp --><!-- br --><!-- (fraction) -->        <!-- 2005.10.17 -->
         <!-- th bgcolor='#ffddff' --><!-- ip --><!-- br --><!-- (ratio) -->
         <th bgcolor='#33ddff'>10-min peak intensity<br>($intunits)
         <th bgcolor='#33ddff'>30-min peak intensity<br>($intunits)
         <th bgcolor='#33ddff'>Storm date
        </tr>
        <tr>
         <th bgcolor='#3377ff'>1</th>
         <td align=right>$run_off_f</td>
         <td align=right>$precip_f</td>
         <td align=right>$durr</td>
         <!-- td align=right --><!-- $tp --><!-- /td -->	<!-- 2005.10.17 -->
         <!-- td align=right --><!-- $ip --><!-- /td -->
         <td align=right>@i_peak[0]</td>
         <td align=right>@i_peak[1]</td>
         <td align=right>@monthnames[$max_month]&nbsp;$max_day<br>year $max_year</td>
        </tr>
";

#   @color[0]="'#ff33ff'"; @color[1]="'#ff66ff'"; @color[2]="'#ff99ff'";
#   @color[3]="'#ffaaff'"; @color[4]="'#ffccff'"; @color[5]="'#ffddff'";
   @color[0]="'#3388ff'"; @color[1]="'#3399ff'"; @color[2]="'#33aaff'";
   @color[3]="'#33bbff'"; @color[4]="'#33ccff'"; @color[5]="'#33ddff'";

   @probClimate = (0.075, 0.075, 0.20, 0.275, 0.375);	# rank 5, 10, 20, 50, 75  DEH 2005.09.30 10.18 move up

      for $i (0..$#selected_ranks) {

        $durr = '--';
  $lookfor = sprintf ' %2d %2d  %3d ', @day[$i], @month[$i], @selected_year[$i];
#        print TEMP "[$lookfor]";

#       open CLIMATE, "<$CLIfile";
        open CLIMATE, "<$shortCLIfile";
        while (<CLIMATE>) {
          if ($_ =~ $lookfor) {
            ($d_day, $d_month, $d_year, $d_pcp, $durr, $tp, $ip) = split ' ' ,$_;  # DEH 040422
            last
          }
        }
        close CLIMATE;

### duration DEH 040422 Earth Day 2004
#   @max_time_list = (10, 30);			# target durations times (min)
    $prcp = $pcpp;
    $prcp = $d_pcp;
    $dur = $durr;
$ip*=0.7;					# 2005.10.12 DEH counteract WEPP fudge factor
    &peak_intensity;
#      returns peak intensities (mm/h) or 'N/A' in @i_peak
#      returns $error_text
### duration DEH 040422

# #### 2003 units
      if ($units eq 'ft') {
        $run_off_f = sprintf '%9.2f', @run_off[$indx[@selected_ranks[$i]]]/25.4;
#zxc    $run_off_f = sprintf '%9.2f', @runoff[$i]/25.4;
        $precip_f = sprintf '%9.2f', @precip[$i]/25.4;
        $sed_delivery_f = @sed_delivery[$i];
        $sed_delivery_f = sprintf '%9.2f', $sed_delivery_f / $hillslope_length_m * 4.45;
        $i10w+=@probClimate[$i]*@i_peak[0] if (@i_peak[0] ne 'N/A');	# 2005.10.20 DEH
        @i_peak[0] = sprintf '%9.2f', @i_peak[0]/25.4 if (@i_peak[0] ne 'N/A');
        @i_peak[1] = sprintf '%9.2f', @i_peak[1]/25.4 if (@i_peak[1] ne 'N/A');
      }
      else {
        $run_off_f = @run_off[$indx[@selected_ranks[$i]]];
#zxc    $run_off_f = @runoff[$i];
        $precip_f = @precip[$i];
        $sed_delivery_f = @sed_delivery[$i];
        $sed_delivery_f = $sed_delivery_f / $hillslope_length * 10;
        @i_peak[0] = sprintf '%9.2f', @i_peak[0] if (@i_peak[0] ne 'N/A');
        @i_peak[1] = sprintf '%9.2f', @i_peak[1] if (@i_peak[1] ne 'N/A');
        $i10w+=@probClimate[$i]*@i_peak[0] if (@i_peak[0] ne 'N/A');	# 2005.10.18 DEH
      }
#    if (@i_peak[0] eq 'N/A' || @i_peak[1] eq 'N/A') {
#      $tp='--'; $ip='--';				# 2004.09.13
#    }

# #### 2003 units
      $yrs=sprintf '%.0f',(100/(@selected_ranks[$i] + 1));
      if (@selected_ranks[$i] == 74) {$yrs='1<sup>1</sup>/<sub>3</sub>'}	# 2005.10.20 DEH
      print TEMP "            <tr>
             <th bgcolor=@color[$i]><a onMouseOver=\"window.status='",@probClimate[$i]*100,"% probability';return true\" onMouseOut=\"window.status=''; return true\">",@selected_ranks[$i] + 1,"</a><br>($yrs-year)</td>
             <td align=right><b>$run_off_f</b></td>
             <td align=right><b>$precip_f</b></td>
             <td align=right><b>$durr</b></td>
             <!-- td align=right --><!-- b --><!-- $tp --><!-- /b --><!-- /td -->        <!-- 2005.10.17 -->
             <!-- td align=right --><!-- b --><!-- $ip --><!-- /b --><!-- /td -->
             <td align=right><b>@i_peak[0]</b></td>
             <td align=right><b>@i_peak[1]</b></td>
";
      if (@selected_year[$i] ne '') {
        print TEMP "
             <td align=right><b>@monthnames[@month[$i]]&nbsp;@day[$i]<br>year @selected_year[$i]</b></td>
";
      }
      print TEMP "
            </tr>
";
    }

     ($min_day,$min_month,$min_year,$precip,$runoff,$rest) = split ' ', @max_run[@indx[$years]], 6;
     ($interrill_det,$avg_det,$max_det,$det_pt,$avg_dep,$max_dep,$dep_pt,$sed_del,$enrich) = split ' ', $rest;

     $durr = '--';
     $lookfor = sprintf ' %2d %2d  %3d ', $min_day, $min_month, $min_year;
#     print TEMP "[$lookfor]";

     open CLIMATE, "<$CLIfile";
     while (<CLIMATE>) {
       if ($_ =~ $lookfor) {
         ($d_day, $d_month, $d_year, $d_pcp, $durr, $tp, $ip) = split ' ',$_;   # DEH 040422
         last
       }
     }
     close CLIMATE;

    $prcp = $d_pcp;
    $dur = $durr;
    &peak_intensity;

     if (@run_off[$indx[$years]] eq '') {
       $run_off_f = ' -- ';
       $precip_f = ' -- ';
       $sed_del_f = ' -- ';
     }
     elsif ($units eq 'ft') {
       $run_off_f = sprintf '%9.2f', @run_off[$indx[$years]]/25.4;
       $precip_f  = sprintf '%9.2f', $precip/25.4;
       $sed_del_f = sprintf '%9.2f', $sed_del / $hillslope_length_m * 4.45;
       @i_peak[0] = sprintf '%9.2f', @i_peak[0]/25.4 if (@i_peak[0] ne 'N/A');
       @i_peak[1] = sprintf '%9.2f', @i_peak[1]/25.4 if (@i_peak[1] ne 'N/A');
     }
     else {
       $run_off_f = @run_off[$indx[$years]];
       $precip_f = $precip;
       $sed_del_f = $sed_del / $hillslope_length * 10;
       @i_peak[0] = sprintf '%9.2f', @i_peak[0] if (@i_peak[0] ne 'N/A');
       @i_peak[1] = sprintf '%9.2f', @i_peak[1] if (@i_peak[1] ne 'N/A');
     }

#      print TEMP
#"     <tr>
#       <th bgcolor='#ffddff'>100</td>
#       <td align=right>$run_off_f</td>
#       <td align=right>$precip_f</td>
#       <td align=right>$durr</td>
#       <td align=right>$tp</td>
#       <td align=right>$ip</td>
#       <td align=right>@i_peak[0]</td>
#       <td align=right>@i_peak[1]</td>
#       <td align=right>@monthnames[$min_month]&nbsp;$min_day<br>year $min_year</td>
#      </tr>
      print TEMP "
     </table>
";
#     print TEMP '<br>',@years2run,"<br>\n";
#     print TEMP "<br>$years1 years out of 100 had runoff events.<br>\n" if ($years<50);

################################ skippit

# goto cutout;

     $a=0;            # dummy

# ------------------------ flow 5 --------------------------------

# ermit flow

# climate selected
# soil selected			["clay loam" "silt loam" "sandy loam" "loam"]
# vegetation type selected	["forest" "range" "chaparral"]
# topography specified		["surface slope average" "surface slope at toe" "surface length"]
# soil burn severity class selected	["L" "M" "H"]

# number of years of weather generated (telescoped) known (4 to 16)

# -------------------------------
#	$severityclass="h";

#	$avg_slope=25;
#	$toe_slope=10;
#	$hillslope_length=100;

#  @month = (5,12,1,12);
#  @day = (1,23,25,2);
#  @selected_year = (12,59,62,60);

# -------------------------------

   @monthnames = ('', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December');

#   $data = 'data/';
#   $working = 'working/';

#  $SlopeFileName = 'slope.slp';
#  $SlopeFilePath = $workingpath . $SlopeFileName;
#  $slopeFilePath = $workingpath . '.slp';
#  $stoutFilePath = $workingpath . 'stout';
#  $sterrFilePath = $workingpath . 'sterr';

  $climateFile = $shortCLIfile;

  if ($debug) {print TEMP "<br>
    climateFile: $climateFile<br>
    slopeFile:  $slopeFile<br>
    evoFile: $evoFile<br>
    ev_by_evFile: $ev_by_evFile<br>
    ";
  }

#  @probClimate = (0.075, 0.075, 0.20, 0.275, 0.375);	# rank 5, 10, 20, 50, 75  DEH 2005.09.30
# no mitigation
   @probSoil0 = (0.10, 0.20, 0.40, 0.20,  0.10); # year 0
   @probSoil1 = (0.30, 0.30, 0.20, 0.19,  0.01); # year 1
   @probSoil1 = (0.12, 0.21, 0.38, 0.195, 0.095) if ($monsoon); # year 1 # 2005.09.30 DEH
   @probSoil2 = (0.50, 0.30, 0.18, 0.01,  0.01); # year 2
   @probSoil3 = (0.60, 0.30, 0.08, 0.01,  0.01); # year 3
   @probSoil4 = (0.70, 0.27, 0.01, 0.01,  0.01); # year 4
# seeding
   @probSoil_s0 = (0.10, 0.20, 0.40, 0.20, 0.10); # year 0
   @probSoil_s1 = (0.50, 0.30, 0.18, 0.01, 0.01); # year 2
   @probSoil_s2 = (0.60, 0.30, 0.08, 0.01, 0.01); # year 3
   @probSoil_s3 = (0.70, 0.27, 0.01, 0.01, 0.01); # year 4
   @probSoil_s4 = (0.70, 0.27, 0.01, 0.01, 0.01); # year 4
# mulching 27% ground cover (1/2 Mg/ha; ~1/4 ton/ac)		# 2005.09.30 DEH
#   @probSoil_mh0 = (0.30, 0.40, 0.20, 0.09, 0.01); # year 0	# 2005.09.30 DEH
#   @probSoil_mh1 = (0.40, 0.35, 0.20, 0.04, 0.01); # year 1	# 2005.09.30 DEH
#   @probSoil_mh2 = (0.50, 0.30, 0.18, 0.01, 0.01); # year 2	# 2005.09.30 DEH
#   @probSoil_mh3 = (0.60, 0.30, 0.08, 0.01, 0.01); # year 3	# 2005.09.30 DEH
#   @probSoil_mh4 = (0.70, 0.27, 0.01, 0.01, 0.01); # year 4	# 2005.09.30 DEH
# mulching 47% ground cover (1 Mg/ha; ~1/2 ton/ac)		# 2005.09.30 DEH
   @probSoil_m470 = (0.70, 0.20, 0.08, 0.01, 0.01); # year 0	# 2005.09.30 DEH
   @probSoil_m471 = (0.60, 0.25, 0.13, 0.01, 0.01); # year 1	# 2005.09.30 DEH
   @probSoil_m472 = (0.50, 0.30, 0.18, 0.01, 0.01); # year 2	# 2005.09.30 DEH
   @probSoil_m473 = (0.60, 0.30, 0.08, 0.01, 0.01); # year 3	# 2005.09.30 DEH
   @probSoil_m474 = (0.70, 0.27, 0.01, 0.01, 0.01); # year 4	# 2005.09.30 DEH
# mulching 62% ground cover (1-1/2 Mg/ha; ~2/3 ton/ac)		# 2005.09.30 DEH
#   @probSoil_moh0 = (0.80, 0.10, 0.08, 0.01, 0.01); # year 0	# 2005.09.30 DEH
#   @probSoil_moh1 = (0.65, 0.20, 0.13, 0.01, 0.01); # year 1	# 2005.09.30 DEH
#   @probSoil_moh2 = (0.50, 0.30, 0.18, 0.01, 0.01); # year 2	# 2005.09.30 DEH
#   @probSoil_moh3 = (0.60, 0.30, 0.08, 0.01, 0.01); # year 3	# 2005.09.30 DEH
#   @probSoil_moh4 = (0.70, 0.27, 0.01, 0.01, 0.01); # year 4	# 2005.09.30 DEH
# mulching 72% ground cover (2 Mg/ha; ~1 ton/ac)		# 2005.09.30 DEH
   @probSoil_m720 = (0.90, 0.07, 0.01, 0.01, 0.01); # year 0	# 2005.09.30 DEH
   @probSoil_m721 = (0.70, 0.20, 0.08, 0.01, 0.01); # year 1	# 2005.09.30 DEH
   @probSoil_m722 = (0.50, 0.30, 0.18, 0.01, 0.01); # year 2	# 2005.09.30 DEH
   @probSoil_m723 = (0.60, 0.30, 0.08, 0.01, 0.01); # year 3	# 2005.09.30 DEH
   @probSoil_m724 = (0.70, 0.27, 0.01, 0.01, 0.01); # year 4	# 2005.09.30 DEH
# mulching 89% ground cover (3-1/2 Mg/ha; ~1-1/2 ton/ac)	# 2005.09.30 DEH
   @probSoil_m890 = (0.93, 0.04, 0.01, 0.01, 0.01); # year 0	# 2005.09.30 DEH
   @probSoil_m891 = (0.77, 0.15, 0.06, 0.01, 0.01); # year 1	# 2005.09.30 DEH
   @probSoil_m892 = (0.50, 0.30, 0.18, 0.01, 0.01); # year 2	# 2005.09.30 DEH
   @probSoil_m893 = (0.60, 0.30, 0.08, 0.01, 0.01); # year 3	# 2005.09.30 DEH
   @probSoil_m894 = (0.70, 0.27, 0.01, 0.01, 0.01); # year 4	# 2005.09.30 DEH
# mulching 94% ground cover (4-1/2 Mg/ha; ~2 ton/ac)		# 2005.09.30 DEH
   @probSoil_m940 = (0.96, 0.01, 0.01, 0.01, 0.01); # year 0	# 2005.09.30 DEH
   @probSoil_m941 = (0.78, 0.16, 0.04, 0.01, 0.01); # year 1	# 2005.09.30 DEH
   @probSoil_m942 = (0.50, 0.30, 0.18, 0.01, 0.01); # year 2	# 2005.09.30 DEH
   @probSoil_m943 = (0.60, 0.30, 0.08, 0.01, 0.01); # year 3	# 2005.09.30 DEH
   @probSoil_m944 = (0.70, 0.27, 0.01, 0.01, 0.01); # year 4	# 2005.09.30 DEH
   if (lc($severityclass) eq "h") {
#    @severe = ("hhh", "lhh", "hlh", "hhl");
#     @probspatial=([0.10, 0.30, 0.30, 0.30],
#                  [0.10, 0.30, 0.30, 0.30],
#                  [0.10, 0.30, 0.30, 0.30],
#                  [0.10, 0.30, 0.30, 0.30],
#                  [0.10, 0.30, 0.30, 0.30]);
     @severe = ("hhh", "lhh", "hlh", "hhl", "llh", "lhl", "hll", "lll");
     @probspatial=([0.10, 0.30, 0.30, 0.30, 0.00, 0.00, 0.00, 0.00],
                   [0.00, 0.25, 0.25, 0.25, 0.25, 0.00, 0.00, 0.00],
                   [0.00, 0.00, 0.25, 0.25, 0.25, 0.25, 0.00, 0.00],
                   [0.00, 0.00, 0.00, 0.25, 0.25, 0.25, 0.25, 0.00],
                   [0.00, 0.00, 0.00, 0.00, 0.25, 0.25, 0.25, 0.25]);
#     @probspatial[0] = (0.10, 0.30, 0.30, 0.30);		# 2005.10.13 DEH
#     @probspatial[1] = (0.10, 0.30, 0.30, 0.30);
#     @probspatial[2] = (0.10, 0.30, 0.30, 0.30);
#     @probspatial[3] = (0.10, 0.30, 0.30, 0.30);
#     @probspatial[4] = (0.10, 0.30, 0.30, 0.30);
   }
   if (lc($severityclass) eq "m") {
#    @severe = ("hlh", "hhl", "llh", "lhl");
#    @probspatial=([0.25, 0.25, 0.25, 0.25],
#                  [0.25, 0.25, 0.25, 0.25],
#                  [0.25, 0.25, 0.25, 0.25],
#                  [0.25, 0.25, 0.25, 0.25],
#                  [0.25, 0.25, 0.25, 0.25]);
     @severe = ("hlh", "hhl", "llh", "lhl", "hll", "lll");
     @probspatial=([0.25, 0.25, 0.25, 0.25, 0.00, 0.00],
                   [0.00, 0.25, 0.25, 0.25, 0.25, 0.00],
                   [0.00, 0.00, 0.25, 0.25, 0.25, 0.25],
                   [0.00, 0.00, 0.25, 0.25, 0.25, 0.25],
                   [0.00, 0.00, 0.25, 0.25, 0.25, 0.25]);
   }
   if (lc($severityclass) eq "l") {
     @severe = ("llh", "lhl", "hll", "lll");
     @probspatial=([0.30, 0.30, 0.30, 0.10],
                   [0.25, 0.25, 0.25, 0.25],
                   [0.25, 0.25, 0.25, 0.25],
                   [0.25, 0.25, 0.25, 0.25],
                   [0.25, 0.25, 0.25, 0.25]);
   }

  if ($debug) {print TEMP "  Severity class '$severityclass'\n"}
  if ($debug) {print TEMP '  <pre><font face="courier new, courier"><br>',"\n"}

#  for $sn (0..3) {
   for $sn (0..$#severe) {						# 2005.10.13 DEH
     $s = @severe[$sn];							# 2005.10.13 DEH
## 	@severe = (LLL, HLL, LHL, LLH), (LHL, LLH, LHH, HLH), (LHH, HLH, HHL, HHH)
#       @severe = ("hhh", "lhh", "hlh", "hhl", "llh", "lhl", "hll", "lll");
#       @severe = ("hlh", "hhl", "llh", "lhl", "hll", "lll");
#       @severe = ("llh", "lhl", "hll", "lll");

     &lhtoab;
#    print TEMP "\n$s: $nofe OFEs\n" ;

     open SLOPE, ">$slopeFile";
       $mySlopeFile = &createSlopeFile;					# DEH 040316
#      print SLOPE &createSlopeFile;					# DEH 040316
       print SLOPE $mySlopeFile;					# DEH 040316
     close SLOPE;
     if ($wgr) {							# DEH 040316
       open TempSlp, ">/var/www/html/fswepp/working/wepp$sn.slp";	# DEH 040316
         print TempSlp $mySlopeFile;					# DEH 040316
       close TempSlp;							# DEH 040316
     }									# DEH 040316

     &createVegFile;
     $manFile = $datapath . $manFileName;

#  for $k (0..0) {   #ZZ#
     for $k (0..4) {			#   for conductivity (k) = (l1..l5; h1..h5)
       open SOL, ">$soilFile";
         $mySoilFile = &createsoilfile;					# DEH 040316
         print SOL $mySoilFile;						# DEH 040316
#         print SOL &createsoilfile;					# DEH 040316
       close SOL;

       if ($wgr) {							# DEH 040316
         open TempSol, ">/var/www/html/fswepp/working/wepp$sn-$k.sol";	# DEH 040316
           print TempSol $mySoilFile;					# DEH 040316
         close TempSol;							# DEH 040316
       }

       &createResponseFile;			# create WEPP response file
## warning
#       if ($wgr) {
#        `cp $evoFile /var/www/html/fswepp/working/evo`;			# DEH 040913
#        `cp $ev_by_evFile /var/www/html/fswepp/working/event`;		# DEH 040913
#       }
       -e $evoFile and unlink $evoFile;
       -e $ev_by_evFile and unlink $ev_by_evFile;
## warning
#            run WEPP on climate file (4 to 16 years)
      if ($platform eq "pc") {
         @args = ("wepp <$responseFile >$stoutFile");
      }
      else {
#        @args = ("nice -20 ../wepp <$response ile>$stoutFile 2>$sterrFile");
        @args = ("nice -20 ../wepp <$responseFile >$stoutFile 2>$sterrFile");
      }
       print TEMP "@args\n" if $debug;
       system @args;

       if ($debug) {$printfilename = $sterrFile; &printfile}

##############

    # die on bad error   2003.01.14

#    die if @filetext =~ /Error/;

  #   if (@filetext =~ /Error/) {
  #     print TEMP "Dagblarnit if WEPP didn't crash!\n";
  #     goto somewhere;
  #   }
  foreach (@filetext) { # iterate the array
    if (m/Error/g) {
      print TEMP "Dagblarnit if WEPP didn't crash!";
      goto bail;
    }
  }

##############

#        pull out 5 sediment deliveries from WEPP output
#		store one tables by year
       @seds = &get_event_seds;

       if ($debug) {

#         $severity_event_path = $s . '_events.out';
#         @args = ("copy $ev_by_evFile $severity_event_path");	# TEMP DEH
#         system @args;						# TEMP DEH

         print TEMP '<br>',"\n";
         print TEMP "Severity $sn ('$s')\n Conductivity $k\n";
         print TEMP "\tDay\tMonth\tYear\tSedDel\n";
       }

       for $i (0..$#selected_year) {
         $sedtable[$i][$k][$sn] = @seds[$i];
         if ($debug) {print TEMP "\t",@day[$i],"\t",@month[$i],"\t",@selected_year[$i],"\t",@seds[$i],"\n";}
       }
     }   # Loop (k)
   }   # Loop (s)

   if ($debug) {
     print TEMP '</font></pre>',"\n";
   }
  $sp = 0;

  if ($pt) {
  print TEMP '
 <p>
 <table cellpadding="2" bgcolor="ivory">
  <tr><th colspan=5><font size=+1>SEDIMENT DELIVERY (', $sedunits,')</font></th><th>Spatial (prob; y0..y4)</th></tr>',"\n";
  }

# @selected_ranks[$i] + 1,' (',100/(@selected_ranks[$i] + 1),"- year)

  for $c (0..$#selected_year) {
   if ($pt) {
     print TEMP '  <tr><th align="left" bgcolor="ffff99" colspan="5">', @selected_ranks[$c] + 1,' (',100/(@selected_ranks[$c] + 1),'- year) -- ',@day[$c],' ',@monthnames[@month[$c]],' year ',@selected_year[$c],' (',@probClimate[$c]*100,'%)</th><td></td></tr>',"\n";
   }

#    for $sn (0..3) {										# 2005.10.13 DEH
    for $sn (0..$#severe) {									# 2005.10.13 DEH
      if ($pt) {      print TEMP "<tr>\n"; }
      for $k (0..4) {
        @sed_yields[$sp] = $sedtable[$c][$k][$sn];
        @scheme[$sp] = @selected_ranks[$c]+1 . uc(@severe[$sn]) . ($k+1);			# 2005.10.25 DEH
# no mitigation
        @probabilities0[$sp] = @probClimate[$c] * $probspatial[0][$sn] * @probSoil0[$k];
        @probabilities1[$sp] = @probClimate[$c] * $probspatial[1][$sn] * @probSoil1[$k];
        @probabilities2[$sp] = @probClimate[$c] * $probspatial[2][$sn] * @probSoil2[$k];
        @probabilities3[$sp] = @probClimate[$c] * $probspatial[3][$sn] * @probSoil3[$k];
        @probabilities4[$sp] = @probClimate[$c] * $probspatial[4][$sn] * @probSoil4[$k];
# seeding
        @probabilities_s0[$sp] = @probClimate[$c] * $probspatial[0][$sn] * @probSoil_s0[$k];
        @probabilities_s1[$sp] = @probClimate[$c] * $probspatial[1][$sn] * @probSoil_s1[$k];
        @probabilities_s2[$sp] = @probClimate[$c] * $probspatial[2][$sn] * @probSoil_s2[$k];
        @probabilities_s3[$sp] = @probClimate[$c] * $probspatial[3][$sn] * @probSoil_s3[$k];
        @probabilities_s4[$sp] = @probClimate[$c] * $probspatial[4][$sn] * @probSoil_s4[$k];
# mulch 047% GC	# 2005.09.30 DEH
        @probabilities_m470[$sp] = @probClimate[$c] * $probspatial[0][$sn] * @probSoil_m470[$k];	# 2005.09.30 DEH
        @probabilities_m471[$sp] = @probClimate[$c] * $probspatial[1][$sn] * @probSoil_m471[$k];	# 2005.09.30 DEH
        @probabilities_m472[$sp] = @probClimate[$c] * $probspatial[2][$sn] * @probSoil_m472[$k];	# 2005.09.30 DEH
        @probabilities_m473[$sp] = @probClimate[$c] * $probspatial[3][$sn] * @probSoil_m473[$k];	# 2005.09.30 DEH
        @probabilities_m474[$sp] = @probClimate[$c] * $probspatial[4][$sn] * @probSoil_m474[$k];	# 2005.09.30 DEH
# mulch 72% GC	# 2005.09.30 DEH
        @probabilities_m720[$sp] = @probClimate[$c] * $probspatial[0][$sn] * @probSoil_m720[$k];	# 2005.09.30 DEH
        @probabilities_m721[$sp] = @probClimate[$c] * $probspatial[1][$sn] * @probSoil_m721[$k];	# 2005.09.30 DEH
        @probabilities_m722[$sp] = @probClimate[$c] * $probspatial[2][$sn] * @probSoil_m722[$k];	# 2005.09.30 DEH
        @probabilities_m723[$sp] = @probClimate[$c] * $probspatial[3][$sn] * @probSoil_m723[$k];	# 2005.09.30 DEH
        @probabilities_m724[$sp] = @probClimate[$c] * $probspatial[4][$sn] * @probSoil_m724[$k];	# 2005.09.30 DEH
# mulch 89% GC	# 2005.09.30 DEH
        @probabilities_m890[$sp] = @probClimate[$c] * $probspatial[0][$sn] * @probSoil_m890[$k];	# 2005.09.30 DEH
        @probabilities_m891[$sp] = @probClimate[$c] * $probspatial[1][$sn] * @probSoil_m891[$k];	# 2005.09.30 DEH
        @probabilities_m892[$sp] = @probClimate[$c] * $probspatial[2][$sn] * @probSoil_m892[$k];	# 2005.09.30 DEH
        @probabilities_m893[$sp] = @probClimate[$c] * $probspatial[3][$sn] * @probSoil_m893[$k];	# 2005.09.30 DEH
        @probabilities_m894[$sp] = @probClimate[$c] * $probspatial[4][$sn] * @probSoil_m894[$k];	# 2005.09.30 DEH
# mulch 94% GC	# 2005.09.30 DEH
        @probabilities_m940[$sp] = @probClimate[$c] * $probspatial[0][$sn] * @probSoil_m940[$k];	# 2005.09.30 DEH
        @probabilities_m941[$sp] = @probClimate[$c] * $probspatial[1][$sn] * @probSoil_m941[$k];	# 2005.09.30 DEH
        @probabilities_m942[$sp] = @probClimate[$c] * $probspatial[2][$sn] * @probSoil_m942[$k];	# 2005.09.30 DEH
        @probabilities_m943[$sp] = @probClimate[$c] * $probspatial[3][$sn] * @probSoil_m943[$k];	# 2005.09.30 DEH
        @probabilities_m944[$sp] = @probClimate[$c] * $probspatial[4][$sn] * @probSoil_m944[$k];	# 2005.09.30 DEH

        if ($units eq 'ft') {     # convert sediment yield kg per m to ton per ac
          $sed_yield = @sed_yields[$sp] / $hillslope_length * 4.45; 
        }
        else {     # convert sediment yield kg per m to t per ha
          $sed_yield = @sed_yields[$sp] / $hillslope_length * 10; 
        }
    $sed_yield_f = sprintf '%6.2f', $sed_yield;
    if ($pt) {
        print TEMP "
  <td align=\"right\"><a href=\"http://forest.moscowfsl.wsu.edu/cgi-bin/fswepp/ermit/soilfile.pl?s=$severe[$sn]&k=$k&SoilType=$SoilType&vegtype=$vegtype&rfg=$rfg&grass=$grass&shrub=$shrub&bare=$bare\" target=\"o\">$sed_yield_f</a></td>
";
    }	# if ($pt)
        $sp += 1;
  }	# for ($k)
    if ($pt) {								# 2005.10.13 DEH
      print TEMP '     <td bgcolor="ffff99">',@severe[$sn],
                 ' (', $probspatial[0][$sn]*100, '%) ',
                 ' (', $probspatial[1][$sn]*100, '%) ',
                 ' (', $probspatial[2][$sn]*100, '%) ',
                 ' (', $probspatial[3][$sn]*100, '%) ',
                 ' (', $probspatial[4][$sn]*100, '%) ',
                 "    </td>\n   </tr>\n";
    }	# if ($pt)
    }	# for ($c)
#    print TEMP "\n";
  }
    if ($pt) {
  print TEMP '  <tr>
   <td align="right">soil 0</td>
   <td align="right">soil 1</td>
   <td align="right">soil 2</td>
   <td align="right">soil 3</td>
   <td align="right">soil 4</td>
   <td></td>
  </tr>
  <tr><td bgcolor="ffff99">(',$probSoil0[0]*100,'%)</td>
   <td bgcolor="ffff99">(',$probSoil0[1]*100,'%)</td>
   <td bgcolor="ffff99">(',$probSoil0[2]*100,'%)</td>
   <td bgcolor="ffff99">(',$probSoil0[3]*100,'%)</td>
   <td bgcolor="ffff99">(',$probSoil0[4]*100,'%)</td>
   <td>year 0</td></tr>
  <tr><td bgcolor="ffff99">(',$probSoil1[0]*100,'%)</td>
   <td bgcolor="ffff99">(',$probSoil1[1]*100,'%)</td>
   <td bgcolor="ffff99">(',$probSoil1[2]*100,'%)</td>
   <td bgcolor="ffff99">(',$probSoil1[3]*100,'%)</td>
   <td bgcolor="ffff99">(',$probSoil1[4]*100,'%)</td>
   <td>year 1</td></tr>
  <tr><td bgcolor="ffff99">(',$probSoil2[0]*100,'%)</td>
   <td bgcolor="ffff99">(',$probSoil2[1]*100,'%)</td>
   <td bgcolor="ffff99">(',$probSoil2[2]*100,'%)</td>
   <td bgcolor="ffff99">(',$probSoil2[3]*100,'%)</td>
   <td bgcolor="ffff99">(',$probSoil2[4]*100,'%)</td>
   <td>year 2</td></tr>
  <tr><td bgcolor="ffff99">(',$probSoil3[0]*100,'%)</td>
   <td bgcolor="ffff99">(',$probSoil3[1]*100,'%)</td>
   <td bgcolor="ffff99">(',$probSoil3[2]*100,'%)</td>
   <td bgcolor="ffff99">(',$probSoil3[3]*100,'%)</td>
   <td bgcolor="ffff99">(',$probSoil3[4]*100,'%)</td>
   <td>year 3</td></tr>
  <tr><td bgcolor="ffff99">(',$probSoil4[0]*100,'%)</td>
   <td bgcolor="ffff99">(',$probSoil4[1]*100,'%)</td>
   <td bgcolor="ffff99">(',$probSoil4[2]*100,'%)</td>
   <td bgcolor="ffff99">(',$probSoil4[3]*100,'%)</td>
   <td bgcolor="ffff99">(',$probSoil4[4]*100,'%)</td>
   <td>year 4</td></tr>
 </table>
';
}

# index sort @sed_yields decreasing
#   print TEMP @sed_yields and @probabilities using same index and calculate cumulative probability

# index-sort runoff		# index sort from "Efficient FORTRAN Programming"

  @index = sort {$sed_yields[$b] <=> $sed_yields[$a]} 0..$#sed_yields;  # sort indices
#  @rank[@index] = 0..$#sed_yields;                    # make rank

  if ($debug) {print TEMP "<pre>\n";			# put following calculation block within debug "if" 2005.10.24
# no mitigation
  $cum_prob0 = 0.01;					# 2004.03.18 DEH 0. to 0.05 per CAM
  $cum_prob1 = 0.01;					# 2005.10.25 DEH 0.05 to 0.01 per PRR
  $cum_prob2 = 0.01;
  $cum_prob3 = 0.01;
  $cum_prob4 = 0.01;
# seeding
  $cum_prob_s0 = 0.01;
  $cum_prob_s1 = 0.01;
  $cum_prob_s2 = 0.01;
  $cum_prob_s3 = 0.01;
  $cum_prob_s4 = 0.01;
# mulch 47% GC	# 2005.09.30 DEH
  $cum_prob_m470 = 0.01;	# 2005.09.30 DEH
  $cum_prob_m471 = 0.01;	# 2005.09.30 DEH
  $cum_prob_m472 = 0.01;	# 2005.09.30 DEH
  $cum_prob_m473 = 0.01;	# 2005.09.30 DEH
  $cum_prob_m474 = 0.01;	# 2005.09.30 DEH
# mulch 72% GC	# 2005.09.30 DEH
  $cum_prob_m720 = 0.01;	# 2005.09.30 DEH
  $cum_prob_m721 = 0.01;	# 2005.09.30 DEH
  $cum_prob_m722 = 0.01;	# 2005.09.30 DEH
  $cum_prob_m723 = 0.01;	# 2005.09.30 DEH
  $cum_prob_m724 = 0.01;	# 2005.09.30 DEH
# mulch 89% GC	# 2005.09.30 DEH
  $cum_prob_m890 = 0.01;	# 2005.09.30 DEH
  $cum_prob_m891 = 0.01;	# 2005.09.30 DEH
  $cum_prob_m892 = 0.01;	# 2005.09.30 DEH
  $cum_prob_m893 = 0.01;	# 2005.09.30 DEH
  $cum_prob_m894 = 0.01;	# 2005.09.30 DEH
# mulch 94% GC	# 2005.09.30 DEH
  $cum_prob_m940 = 0.01;	# 2005.09.30 DEH
  $cum_prob_m941 = 0.01;	# 2005.09.30 DEH
  $cum_prob_m942 = 0.01;	# 2005.09.30 DEH
  $cum_prob_m943 = 0.01;	# 2005.09.30 DEH
  $cum_prob_m944 = 0.01;	# 2005.09.30 DEH
  for $sp (0..$#sed_yields) {
# no mitigation
    $cum_prob0 += @probabilities0[@index[$sp]];
    $cum_prob1 += @probabilities1[@index[$sp]];
    $cum_prob2 += @probabilities2[@index[$sp]];
    $cum_prob3 += @probabilities3[@index[$sp]];
    $cum_prob4 += @probabilities4[@index[$sp]];
# seeding
    $cum_prob_s0 += @probabilities_s0[@index[$sp]];
    $cum_prob_s1 += @probabilities_s1[@index[$sp]];
    $cum_prob_s2 += @probabilities_s2[@index[$sp]];
    $cum_prob_s3 += @probabilities_s3[@index[$sp]];
    $cum_prob_s4 += @probabilities_s4[@index[$sp]];
# mulch 47% GC	# 2005.09.30 DEH
    $cum_prob_m470 += @probabilities_m470[@index[$sp]];	# 2005.09.30 DEH
    $cum_prob_m471 += @probabilities_m471[@index[$sp]];	# 2005.09.30 DEH
    $cum_prob_m472 += @probabilities_m472[@index[$sp]];	# 2005.09.30 DEH
    $cum_prob_m473 += @probabilities_m473[@index[$sp]];	# 2005.09.30 DEH
    $cum_prob_m474 += @probabilities_m474[@index[$sp]];	# 2005.09.30 DEH
# mulch 72% GC	# 2005.09.30 DEH
    $cum_prob_m720 += @probabilities_m720[@index[$sp]];	# 2005.09.30 DEH
    $cum_prob_m721 += @probabilities_m721[@index[$sp]];	# 2005.09.30 DEH
    $cum_prob_m722 += @probabilities_m722[@index[$sp]];	# 2005.09.30 DEH
    $cum_prob_m723 += @probabilities_m723[@index[$sp]];	# 2005.09.30 DEH
    $cum_prob_m724 += @probabilities_m724[@index[$sp]];	# 2005.09.30 DEH
# mulch 89% GC	# 2005.09.30 DEH
    $cum_prob_m890 += @probabilities_m890[@index[$sp]];	# 2005.09.30 DEH
    $cum_prob_m891 += @probabilities_m891[@index[$sp]];	# 2005.09.30 DEH
    $cum_prob_m892 += @probabilities_m892[@index[$sp]];	# 2005.09.30 DEH
    $cum_prob_m893 += @probabilities_m893[@index[$sp]];	# 2005.09.30 DEH
    $cum_prob_m894 += @probabilities_m894[@index[$sp]];	# 2005.09.30 DEH
# mulch 94% GC	# 2005.09.30 DEH
    $cum_prob_m940 += @probabilities_m940[@index[$sp]];	# 2005.09.30 DEH
    $cum_prob_m941 += @probabilities_m941[@index[$sp]];	# 2005.09.30 DEH
    $cum_prob_m942 += @probabilities_m942[@index[$sp]];	# 2005.09.30 DEH
    $cum_prob_m943 += @probabilities_m943[@index[$sp]];	# 2005.09.30 DEH
    $cum_prob_m944 += @probabilities_m944[@index[$sp]];	# 2005.09.30 DEH

    print TEMP @sed_yields[@index[$sp]],"\t",@probabilities0[@index[$sp]],"\t$cum_prob0\t$cum_prob1\t$cum_prob2\t$cum_prob3\t$cum_prob4\n";
#    print TEMP @sed_yields[@index[$sp]],"\t",@probabilities0[@index[$sp]],"\t$cum_prob0\t",,"\t",@probabilities1[@index[$sp]],"\t$cum_prob1\n";
  }
    print TEMP "\n\n";
  }  # if ($debug)

#  @sorted_sed_probs = sort { $a <=> $b } @sed_probs;	# sort numerically increasing
#  for $sp (0..$#sed_probs) {
#    print TEMP @sorted_sed_probs[$sp], ' ';
#  }

bail:

  open YADDA, ">$gnuplotdatafile";
    print YADDA &createGnuplotDatafile;   # yadda yadda
  close YADDA;
  open YADDA, ">$gnuplotjclfile";
   print YADDA &createGnuplotJCLfile;   # yadda yadda
  close YADDA;

  print TEMP `gnuplot`;

#  open (GP, "|gnuplot");
#   use FileHandle;  
#   GP->autoflush(1);      # force buffer to flush after each write
#   print GP "load '$gnuplotjclfile'\n";
#  close GP;

#   exec "/usr/local/bin/gnuplot $gnuplotjclfile";
#   `gnuplot $gnuplotjclfile`;

   @args=  ("gnuplot $gnuplotjclfile");
#   print TEMP @args;
   system @args;

   `convert -rotate 90 $gnuplotgrapheps $gnuplotgraphpng`;
#  print TEMP @args;
#   system @args;

close TEMP;

############################
#  return HTML page
############################

   print "Content-type: text/html\n\n";	# SERVER
   print '<HTML>
   <HEAD>
   <TITLE>ERMiT Results</TITLE>
<!-- bgsound src="http://forest.moscowfsl.wsu.edu/sounds/SHAKUHA1.WAV" -->
<script language="Javascript">

function percentages(x) {
    document.doit.probability0.value = x; probchange(0)
    document.doit.probability1.value = x; probchange(1)
    document.doit.probability2.value = x; probchange(2)
    document.doit.probability3.value = x; probchange(3)
    document.doit.probability4.value = x; probchange(4)
}

function sediments(x) {
    document.getElementById("sediment0").innerHTML = x; sedchange(0)
    document.getElementById("sediment1").innerHTML = x; sedchange(1)
    document.getElementById("sediment2").innerHTML = x; sedchange(2)
    document.getElementById("sediment3").innerHTML = x; sedchange(3)
    document.getElementById("sediment4").innerHTML = x; sedchange(4)
//    document.doit.sediment0.value = x; sedchange(0)
//    document.doit.sediment1.value = x; sedchange(1)
//    document.doit.sediment2.value = x; sedchange(2)
//    document.doit.sediment3.value = x; sedchange(3)
//    document.doit.sediment4.value = x; sedchange(4)
}
';

print "
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

#  &CreateJavascriptsoilfileFunction;
  &CreateJavascriptwhatsedsFunction;

cutout:

print'   </HEAD>
   <!-- BODY background="/fswepp/images/note.gif" link="#1603F3" vlink="#160A8C" -->		<!-- ZZZZ -->
   <BODY background="/fswepp/images/note.gif" link="green" vlink="#160A8C">		<!-- ZZZZ -->
   <font face="Arial, Geneva, Helvetica">
   <blockquote>
   <center>
       <h2>
        <hr width=50%>
         <font color=red>E</font>rosion
         <font color=red>R</font>isk
         <font color=red>M</font>anagement
         <font color=red>T</font>ool
        <hr width=50%>
       </h2>
';

#   echo input parameters

    print "
    <table border=1 cellpadding=3>
     <tr>
      <td bgcolor=ccffff><b>$climate_name</b>
       <br>
       <font size=1>
";
&readPARfile();
print "
       </font>
      </td>
     </tr>
     <tr>
      <td bgcolor=ccffff>
       <b>$soil_texture</b> soil texture, <b>$rfg%</b> rock fragment
      </td>
     <tr>
      <td bgcolor=ccffff>
       <b>$top_slope% top, $avg_slope% average, $toe_slope% toe</b> hillslope gradient&nbsp;
      </td>
     </tr>
     <tr>
      <td bgcolor=ccffff>
       <b>$hillslope_length $units</b> hillslope horizontal length
      </td>
     </tr>
     <tr>
      <td bgcolor=ccffff>
       <b>$severityclass_x</b> soil burn severity on <b>$vegtype_x</b>
      </td>
     </tr>
";
#     <tr>
#      <td bgcolor=ccffff> <b>$vegtype</b> vegetation
#      </td>
#     </tr>
#";

    if ($vegtype ne 'forest') {print "
     <tr>
      <td bgcolor=ccffff>
        Prefire community <b>$shrub% shrub, $grass% grass, $bare% bare <\/b><br>
       <table width=100% border=0>
        <tr>
         <td bgcolor=\"yellow\" width=\"$shrub %\" height=15>
         </td>
         <td bgcolor=\"lightgreen\" width=\"$grass %\" height=15>
         </td>
          <td bgcolor=\"#eeddcc\" width=\"$bare %\" height=15>
         </td>
        </tr>
       </table>
      </td>
     </tr>
";
    }
print '
    </table>
';

   open TEMP, "<$tempFile";
   while (<TEMP>) {
     print $_
   }

   close TEMP;

#   ##################### display Sediment delivery exceedance prob graph

print '
  <p>
   <a href="javascript:showtable(\'cp\',\'no_mit\',\'No mitigation\')"><img src="'.$gnuplotgraphpl.'"></a>
';

print <<'EOP2';
<br>
   <form name="doit">

       <!-- script
        sed_del_min = rounder(sed_del[100]*js_sedconv,2)   // 2005.09.30 DEH  Fix for 100, 150, 200 (L, M, H burn)
        sed_del_max = rounder(sed_del[1]*js_sedconv,2)
        // document.writeln('Sediment delivery ranges from <b>'+sed_del_min+'<\/b> to <b>'+sed_del_max+'<\/b> '+js_sedunits+'<br>')
       /script -->

    <script language="JavaScript">
     var seds = whatseds (0.1, cp0)
     seds = rounder(seds*js_sedconv,2)

     mulchrate = '1'	////<!-- mulch 47% -->	// 2005.09.30 DEH
     if (js_units == 'ft') mulchrate = '0.5'	// 2005.09.30 DEH
     mulch1  = '<a onMouseOver="window.status=\'47% groundcover\';return true" onMouseOut="window.status=\'\'; return true">Mulch rate '+mulchrate+' '+js_sedunits+'</a>'
     mulch1a = 'Mulch rate '+mulchrate+' '+js_alt_sedunits

     mulchrate = '2'	////<!-- mulch 72% -->	// 2005.09.30 DEH
     if (js_units == 'ft') mulchrate = '1'	// 2005.09.30 DEH
     mulch2  = '<a onMouseOver="window.status=\'72% groundcover\';return true" onMouseOut="window.status=\'\'; return true">Mulch rate '+mulchrate+' '+js_sedunits+'</a>'
     mulch2a = 'Mulch rate '+mulchrate+' '+js_alt_sedunits

     mulchrate = '3.5'	////<!-- mulch 89% -->	// 2005.09.30 DEH
     if (js_units == 'ft') mulchrate = '1.5'	// 2005.09.30 DEH
     mulch3  = '<a onMouseOver="window.status=\'89% groundcover\';return true" onMouseOut="window.status=\'\'; return true">Mulch rate '+mulchrate+' '+js_sedunits+'</a>'
     mulch3a = 'Mulch rate '+mulchrate+' '+js_alt_sedunits

     mulchrate = '4.5'	////<!-- mulch 94% -->	// 2005.09.30 DEH
     if (js_units == 'ft') mulchrate = '2'	// 2005.09.30 DEH
     mulch4  = '<a onMouseOver="window.status=\'94% groundcover\';return true" onMouseOut="window.status=\'\'; return true">Mulch rate '+mulchrate+' '+js_sedunits+'</a>'
     mulch4a = 'Mulch rate '+mulchrate+' '+js_alt_sedunits
     sediment0 = rounder(whatseds (0.1, cp0)*js_sedconv,2)	// 2005.09.30 DEH
     sediment1 = rounder(whatseds (0.1, cp1)*js_sedconv,2)	// 2005.09.30 DEH
     sediment2 = rounder(whatseds (0.1, cp2)*js_sedconv,2)	// 2005.09.30 DEH
     sediment3 = rounder(whatseds (0.1, cp3)*js_sedconv,2)	// 2005.09.30 DEH
     sediment4 = rounder(whatseds (0.1, cp4)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_s0 = rounder(whatseds (0.1, cp_s0)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_s1 = rounder(whatseds (0.1, cp_s1)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_s2 = rounder(whatseds (0.1, cp_s2)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_s3 = rounder(whatseds (0.1, cp_s3)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_s4 = rounder(whatseds (0.1, cp_s4)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m470 = rounder(whatseds (0.1, cp_m470)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m471 = rounder(whatseds (0.1, cp_m471)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m472 = rounder(whatseds (0.1, cp_m472)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m473 = rounder(whatseds (0.1, cp_m473)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m474 = rounder(whatseds (0.1, cp_m474)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m720 = rounder(whatseds (0.1, cp_m720)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m721 = rounder(whatseds (0.1, cp_m721)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m722 = rounder(whatseds (0.1, cp_m722)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m723 = rounder(whatseds (0.1, cp_m723)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m724 = rounder(whatseds (0.1, cp_m724)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m890 = rounder(whatseds (0.1, cp_m890)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m891 = rounder(whatseds (0.1, cp_m891)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m892 = rounder(whatseds (0.1, cp_m892)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m893 = rounder(whatseds (0.1, cp_m893)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m894 = rounder(whatseds (0.1, cp_m894)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m940 = rounder(whatseds (0.1, cp_m940)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m941 = rounder(whatseds (0.1, cp_m941)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m942 = rounder(whatseds (0.1, cp_m942)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m943 = rounder(whatseds (0.1, cp_m943)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m944 = rounder(whatseds (0.1, cp_m944)*js_sedconv,2)	// 2005.09.30 DEH
    </script>

<!== == == ==  ALL NEW TABLE == == == ->
<!== == == ==  ALL NEW TABLE == == == ->
<!== == == ==  ALL NEW TABLE == == == ->
<!== == == ==  ALL NEW TABLE == == == ->

    <table border=1>
     <tr>
      <th rowspan=3 bgcolor="gold">Target chance<br>event sediment delivery<br>will be exceeded<br>
       <input type="text" name="probability0x" onChange="javascript:probchange()" value="10" size="6"> %&nbsp;&nbsp;&nbsp;
       <img src="/fswepp/images/go.gif" alt="[X]">
      </th>
      <th colspan=5 bgcolor="lightgoldenrodyellow">Event sediment delivery (<script>document.writeln(js_sedunits)</script>)&nbsp;&nbsp;&nbsp;
       <a href="javascript:printseds()"><img src="/fswepp/images/printer.png" border="0" alt="[print table]"></a>
      </th>
     </tr>
     <tr>
      <th colspan=5 bgcolor="lightgoldenrodyellow">Year following fire</th>
     </tr>
     <tr>
      <th bgcolor="lightgoldenrodyellow">1st year
      <th bgcolor="lightgoldenrodyellow">2nd year
      <th bgcolor="lightgoldenrodyellow">3rd year
      <th bgcolor="lightgoldenrodyellow">4th year
      <th bgcolor="lightgoldenrodyellow">5th year
     </tr>
<!-- untreated -->
     <tr>
      <th bgcolor="lightgoldenrodyellow" align="right">
       Untreated <a href="javascript:showtable('cp','no_mit','No mitigation')"><img src="/fswepp/images/printer.png" border=0 alt="[?]"></a>&nbsp;
      </th>
      <th><script>document.write('<span id="sediment0">'+sediment0+'</span>')</script></th>
      <th><script>document.write('<span id="sediment1">'+sediment1+'</span>')</script></th>
      <th><script>document.write('<span id="sediment2">'+sediment2+'</span>')</script></th>
      <th><script>document.write('<span id="sediment3">'+sediment3+'</span>')</script></th>
      <th><script>document.write('<span id="sediment4">'+sediment4+'</span>')</script></th>
     </tr>
<!-- seeding -->
     <tr>
      <th bgcolor="lightgoldenrodyellow" align="right">
       Seeding <a href="javascript:showtable('cp_s','seed','Seeding after fire')"><img src="/fswepp/images/printer.png" border=0 alt="[?]"></a>&nbsp;
      </th>
      <th><script>document.write('<span id="sediment_s0">'+sediment_s0+'</span>')</script></th>
      <th><script>document.write('<span id="sediment_s1">'+sediment_s1+'</span>')</script></th>
      <th><script>document.write('<span id="sediment_s2">'+sediment_s2+'</span>')</script></th>
      <th><script>document.write('<span id="sediment_s3">'+sediment_s3+'</span>')</script></th>
      <th><script>document.write('<span id="sediment_s4">'+sediment_s4+'</span>')</script></th>
     </tr>
<!-- mulch 47% -->
     <tr>
      <th bgcolor="lightgoldenrodyellow" align="right">
       <script>document.writeln(mulch1)</script>
       <a href="javascript:showtable('cp_m47','mulch_47',mulch1a)"><img src="/fswepp/images/printer.png" border=0 alt="[?]"></a>&nbsp;
      </th>
      <th><script>document.write('<span id="sediment_m470">'+sediment_m470+'</span>')</script></th>
      <th><script>document.write('<span id="sediment_m471">'+sediment_m471+'</span>')</script></th>
      <th><script>document.write('<span id="sediment_m472">'+sediment_m472+'</span>')</script></th>
      <th><script>document.write('<span id="sediment_m473">'+sediment_m473+'</span>')</script></th>
      <th><script>document.write('<span id="sediment_m474">'+sediment_m474+'</span>')</script></th>
     </tr>
<!-- mulch 72% -->
     <tr>
      <th bgcolor="lightgoldenrodyellow" align="right">
       <script>document.writeln(mulch2)</script>
       <a href="javascript:showtable('cp_m72','mulch_72',mulch2a)"><img src="/fswepp/images/printer.png" border=0 alt="[?]"></a>&nbsp;
      </th>
      <th><script>document.write('<span id="sediment_m720">'+sediment_m720+'</span>')</script></th>
      <th><script>document.write('<span id="sediment_m721">'+sediment_m721+'</span>')</script></th>
      <th><script>document.write('<span id="sediment_m722">'+sediment_m722+'</span>')</script></th>
      <th><script>document.write('<span id="sediment_m723">'+sediment_m723+'</span>')</script></th>
      <th><script>document.write('<span id="sediment_m724">'+sediment_m724+'</span>')</script></th>
     </tr>
<!-- mulch 89% -->
     <tr>
      <th bgcolor="lightgoldenrodyellow" align="right">
       <script>document.writeln(mulch3)</script>
       <a href="javascript:showtable('cp_m89','mulch_89',mulch3a)"><img src="/fswepp/images/printer.png" border=0 alt="[?]"></a>&nbsp;
      </th>
      <th><script>document.write('<span id="sediment_m890">'+sediment_m890+'</span>')</script></th>
      <th><script>document.write('<span id="sediment_m891">'+sediment_m891+'</span>')</script></th>
      <th><script>document.write('<span id="sediment_m892">'+sediment_m892+'</span>')</script></th>
      <th><script>document.write('<span id="sediment_m893">'+sediment_m893+'</span>')</script></th>
      <th><script>document.write('<span id="sediment_m894">'+sediment_m894+'</span>')</script></th>
     </tr>
<!-- mulch 94% -->
     <tr>
      <th bgcolor="lightgoldenrodyellow" align="right">
       <script>document.writeln(mulch4)</script>
       <a href="javascript:showtable('cp_m94','mulch_94',mulch4a)"><img src="/fswepp/images/printer.png" border=0 alt="[?]"></a>&nbsp;
      </th>
      <th><script>document.write('<span id="sediment_m940">'+sediment_m940+'</span>')</script></th>
      <th><script>document.write('<span id="sediment_m941">'+sediment_m941+'</span>')</script></th>
      <th><script>document.write('<span id="sediment_m942">'+sediment_m942+'</span>')</script></th>
      <th><script>document.write('<span id="sediment_m943">'+sediment_m943+'</span>')</script></th>
      <th><script>document.write('<span id="sediment_m944">'+sediment_m944+'</span>')</script></th>
     </tr>
<!-- contour-felled logs -->
     <tr>
      <th bgcolor="lightgoldenrodyellow">
       Logs &amp; Wattles <img src="/fswepp/images/go.gif"><br>
       <div align="right">
        <font size=-1>
         Diameter <input type="text" name="diameter" value ="0" size="5" onChange="javascript:logchange()"> <script>document.write(js_units)</script><br>
         Spacing <input type="text" name="spacing" value="100" size="5" onChange="javascript:logchange()"> <script>document.write(js_units)</script><br>
EOP2
#print '         I<sub>10</sub> <input type="text" name="i10" value="',$i10w,'" size="5" disabled onChange="javascript:logchange()"> <script>document.write(js_intensity_units)</script><br>';
#print '         I<sub>10</sub> <input type="text" name="i10" value="',$i10w,'" size="5" disabled onChange="javascript:logchange()"> mm/h<br>';
print '         <input type="hidden" name="i10" value="',$i10w,'">';
print <<'EOP2a';

         <!-- Storage --> <input type="hidden" name="capacity" value="0"> <!-- script --><!-- document.write(js_storage_units) --><!-- /script -->
        </font>
       </div>
      </th>
      <th valign="top">
       <span id="sediment_cl0"><script>document.write(sediment0)</script></span><br>
       <font size=-1 color="white">
        <span id="capacity0"></span> capacity<br>
        <span id="eff0"></span>% effic.<br>
        <span id="caught0"></span>&nbsp;caught
       </font>
      </th>
      <th valign="top">
       <span id="sediment_cl1"><script>document.write(sediment1)</script></span><br>
       <font size=-1 color="white">
        <span id="capacity1"></span> capacity<br>
        <span id="eff1"></span>% effic.<br>
        <span id="caught1"></span>&nbsp;caught
       </font>
      </th>
      <th valign="top">
       <span id="sediment_cl2"><script>document.write(sediment2)</script></span><br>
       <font size=-1 color="white">
        <span id="capacity2"></span> capacity<br>
        <span id="eff2"></span>% effic.<br>
        <span id="caught2"></span>&nbsp;caught<br>
       </font>
      </th>
      <th valign="top">
       <span id="sediment_cl3"><script>document.write(sediment3)</script></span><br>
       <font size=-1 color="white">
        <span id="capacity3"></span> capacity<br>
        <span id="eff3"></span>% effic.<br>
        <span id="caught3"></span>&nbsp;caught
       </font>
      </th>
      <th valign="top">
       <span id="sediment_cl4"><script>document.write(sediment4)</script></span><br>
      </th>
     </tr>
    </table>

<!== == == ==  END NEW TABLE == == == ->
<!== == == ==  END NEW TABLE == == == ->
<!== == == ==  END NEW TABLE == == == ->
<!== == == ==  END NEW TABLE == == == ->


<p>   <!-- =============== contour-felled logs or straw wattles ======= -->

   </form>
  </center>
<p>
EOP2a
print '
  <form><input type="submit" value="Return to input screen" onclick="JavaScript:window.history.go(-1); return false;"></form>
   </center>
  <p>
  <hr>
  <font size=-2>
   <a href="http://forest.moscowfsl.wsu.edu/fswepp/comments.html"><img src="http://'.$wepphost.'/fswepp/images/epaemail.gif" align="right" border=0></a>
   ERMiT v. <a href="javascript:popuphistory()">',$version,'</a> (for review only). 
   <b>Pete Robichaud</b> and <b>Bill Elliot</b><br>
   USDA Forest Service, Rocky Mountain Research Station, Moscow, ID 83843<br>
   <b>Fred Pierson</b> and <b>Corey Moffet,</b>
   USDA Agricultural Research Service, Northwest Watershed Research Center, Boise, ID<br>
';
# print "New soil parameters for range<br>\n" if ($new_range);
  print "CLIGEN version 5.22564<br>\n" if ($new_cligen);
  print "Observed annual precip $obannual mm; July, August, September precip $obJAS mm ($pctJAS percent):";
  print " MONSOONAL climate<br>\n" if ($monsoon);
  print " NON-MONSOONAL climate<br>\n" if (!$monsoon);
# print " 'Range' &tau;<sub>c</sub><br>\n" if (!$rtc);
# print " 'Forest' &tau;<sub>c</sub><br>\n" if ($rtc);
  print " FS WEPP run ID $unique<br>
  </font>
 </body>
</html>
";

#welog welog welog

   if (lc($wepphost) ne "localhost") {
     open WELOG, ">>../working/we.log";
     flock (WELOG,2);
       print WELOG "$host\t";
       printf WELOG "%0.2d:%0.2d ", $hour, $min;
       print  WELOG $ampm[$ampmi],"  ",$days[$wday]," ",$months[$mon]," ",$mday, ", ",$thissyear,"\t";
       print  WELOG "$climate_name\n";
     close WELOG;

     open CLIMLOG, '>../working/lastclimate.txt';       # 2005.07.14 DEH
       flock CLIMLOG,2;
       print CLIMLOG 'ERMiT: ', $climate_name;
     close CLIMLOG;

     $thisday = 1+ (localtime)[7];                      # $yday, day of the year (0..364)
     $thisdayoff=$thisday-2;
     $thisweek = 1+ int $thisdayoff/7;
#     print "$thisday\t $thisweek\n";
     $ditlogfile = '>>../working/we/' . $thisweek;
     open MYLOG,$ditlogfile;
       flock MYLOG,2;                  # 2005.02.09 DEH
       print MYLOG '.';
     close MYLOG; 

  }

  # unlink

       if ($wgr) {
        `cp $evoFile /var/www/html/fswepp/working/evo`;			# DEH 040913
        `cp $ev_by_evFile /var/www/html/fswepp/working/event`;		# DEH 040913
       }
  if ($debug) {}
  else {
    unlink $soilfile;
    unlink $tempfile;
    unlink $slopefile;
#    unlink $evo_file;
    unlink $shortCLIfile;
    unlink $responseFile;
#    unlink $ev_by_evFile;
    unlink $crspfile;
    unlink $stoutfile;
    unlink $outputfile;
#    unlink $gnuplotdatafile;
#    unlink $gnuplotjclfile;

#DEH#    unlink $workingpath . '.cli';
    unlink $workingpath . '.event100';
    unlink $workingpath . '.evo';
    unlink $workingpath . '.out';
    unlink $workingpath . '.slp';
    unlink $workingpath . '.sol';
    unlink $workingpath . '.sterr';
    unlink $workingpath . '.stout';
    unlink $workingpath . '.temp';
    unlink $workingpath . 'c.out';
  }

#                         E V E N T    
#                   __________________ 
#		s1 |	              |
#               s2 |                  |
#    C05        s3 |                  |
#               s4 |__________________|
#                   k1  k2  k3  k4  k5 
#
#                   __________________ 
#		s1 |	              |
#               s2 |                  |
#    C10        s3 |                  |
#               s4 |__________________|
#                   k1  k2  k3  k4  k5 
#
#
#                   __________________ 
#		s1 |	              |
#               s2 |                  |
#    C20        s3 |                  |
#               s4 |__________________|
#                   k1  k2  k3  k4  k5 
#
#                   __________________ 
#		s1 |	              |
#               s2 |                  |
#    C50        s3 |                  |
#               s4 |__________________|
#                   k1  k2  k3  k4  k5 
#
#                   __________________ 
#		s1 |	              |
#               s2 |                  |
#    C75        s3 |                  |
#               s4 |__________________|
#                   k1  k2  k3  k4  k5 


############################### SUBROUTINES #########################

sub lhtoab {	# ######################### lhtoab

# reads:
  # $s - spatial severity arrangement ("lll", "lhl", "hhl" etc.)

# returns:
  # $ab - generic representation of spatial severity arrangement
  # $nofe - number of OFEs

 my $string = lc($s);
 
 if (lc($s) eq "lll" || lc($s) eq "hhh") { $ab = 'aaa'; $nofe = 1 }	### aaa.slp ###
 if (lc($s) eq "llh" || lc($s) eq "hhl") { $ab = 'aab'; $nofe = 2 }	### aab.slp ###
 if (lc($s) eq "lhl" || lc($s) eq "hlh") { $ab = 'aba'; $nofe = 3 }	### aba.slp ###
 if (lc($s) eq "lhh" || lc($s) eq "hll") { $ab = 'abb'; $nofe = 2 }	### abb.slp ###

}

sub countofes {	# ######################### countofes

# $s - spatial severity arrangement ("lll", "lhl", "hhl" etc.)

 my $string = lc($s);
 my $ofe=0;
 my $nofe = 1;
 my $str;
 $str[0] = substr($string,0,1);

 for $ofe (1..2) {
  $str[$nofe] = substr($string,$ofe,1);
  if ($str[$nofe] ne $str[$nofe-1]) {$nofe+=1}
 }
 return $nofe
}

sub createResponseFile {	# ######################### createResponseFile

# Response file for WEPP 2001.100
#   continuous storm etc.
#   create large graphic file based on $sn $k if $wgr				# DEH 040316

# reads
  # $soilFile -- soil file
  # $climateFile -- climate file
  # $manFile -- management/vegetation file
  # $slopeFile -- slope file
  # $wgr

  # $yearcount

      $wgrFile = "/var/www/html/fswepp/working/wgr$sn-$k.wgr";			# DEH 040316

      open (ResponseFile, ">" . $responseFile);
      print ResponseFile "m\n";           	# metric
      print ResponseFile "y\n";           	# batch
      print ResponseFile "1\n";           	# 1 = continuous
      print ResponseFile "1\n";           	# 1 = hillslope
      print ResponseFile "n\n";           	# hillsplope pass file out?
      print ResponseFile "2\n";			# soil loss output -- detailed annual
      print ResponseFile "n\n";			# initial conditions out?
      print ResponseFile "$evoFile\n";		# soil loss out filename
      print ResponseFile "n\n";			# water balance out?
      print ResponseFile "n\n";			# crop out?
      print ResponseFile "n\n";			# soil out?
      print ResponseFile "n\n";			# dx and sed loss output?
      if ($wgr) {								# DEH 040316
       print ResponseFile "y\n";		# large graphics out?		# DEH 040316
       print ResponseFile "$wgrFile\n";		# event-by-event filename	# DEH 040316
      }										# DEH 040316
      else {									# DEH 040316
       print ResponseFile "n\n";		# large graphics out?		
      }										# DEH 040316
      print ResponseFile "y\n";       		# event-by-event out?
      print ResponseFile "$ev_by_evFile\n";	# event-by-event filename
      print ResponseFile "n\n";           	# element output?
      print ResponseFile "n\n";           	# final summary out?
      print ResponseFile "n\n";           	# daily winter out?
      print ResponseFile "n\n";			# yield output?
      print ResponseFile "$manFile\n";		# management file name
      print ResponseFile "$slopeFile\n";	# slope file name
      print ResponseFile "$climateFile\n";	# climate file name
      print ResponseFile "$soilFile\n";		# soil file name
      print ResponseFile "0\n";          	# 0 = no irrigation
      print ResponseFile "$year_count\n";	# number of years to simulate
      print ResponseFile "0\n";		  	# small event bypass
     close ResponseFile;

     return $responseFile;

}

sub createSlopeFile {	# ######################### createSlopeFile

#	create topography file		(1, 2, or 3 OFE based on severity)

# $s - spatial severity representation ("lll", "lhl", "hhl" etc.)
# $avg_slope - average surface slope gradient
# $toe_slope - surface slope toe gradient
# $hillslope_length

# $result - slope file

  my $topslope=$top_slope/100;
  my $aveslope=$avg_slope/100;
  my $toeslope=$toe_slope/100;

#  print "========================== slope file for '$s' ===================\n";
  if (lc($s) eq "lll" || lc($s) eq "hhh") {			### aaa.slp ###
    my $length1 = $hillslope_length_m;
    $result = "97.5
#
# Slope file created for soil condition $s average gradient $avg_slope toe gradient $toe_slope
#
#  1 ofe (1/1) aaa
#  Author:   dehall
#
1
213.0000  5.0000
4  $length1
0.0, $topslope\t0.1, $aveslope\t0.9, $aveslope\t1.0, $toeslope
"
}

  if (lc($s) eq "llh" || lc($s) eq "hhl") {			### aab.slp ###
    my $length2 = $hillslope_length_m/3;
    my $length1 = $hillslope_length_m-$length2;
    $result = "97.5
#
# Slope file created for soil condition $s average gradient $avg_slope toe gradient $toe_slope
#
#  2 ofe (2/3, 1/3) aab
#  Author:   dehall
#
2
213.0000  5.0000
3  $length1
0, $topslope\t0.15, $aveslope\t1.0, $aveslope
3  $length2
0, $aveslope\t0.7, $aveslope\t1.0, $toeslope
"
  }

  if (lc($s) eq "lhl" || lc($s) eq "hlh") {			### aba.slp ###
    my $length1 = $hillslope_length_m/3;
    my $length2 = $length1;
    my $length3 = $hillslope_length_m - $length1 - $length2;
    $result = "97.5
#
# Slope file created for soil condition $s average gradient $avg_slope toe gradient $toe_slope
#
#  3 ofe (1/3, 1/3, 1/3) aba
#  Author:   dehall
#
3
213.0000  5.0000
3  $length1
0, $topslope\t0.3, $aveslope\t1.0, $aveslope
2  $length2
0, $aveslope\t1.0, $aveslope
3  $length3
0, $aveslope\t0.7, $aveslope\t1.0, $toeslope
"
  }

  if (lc($s) eq "lhh" || lc($s) eq "hll") {			### abb.slp ###
    my $length1 = $hillslope_length_m/3;
    my $length2 = $hillslope_length_m-$length1;
    $result = "97.5
#
# Slope file created for soil condition $s average gradient $avg_slope toe gradient $toe_slope
#
#  2 ofe (1/3, 2/3) abb
#  Author:   dehall
#
2
213.0000  5.0000
3  $length1
0, $topslope\t0.3, $aveslope\t1.0, $aveslope
3  $length2
0, $aveslope\t0.85, $aveslope\t1.0, $toeslope
"
  }
  return $result;
}

sub createVegFile {	# ######################### createVegFile

#	select management file
#		(1, 2, or 3 OFE based on severity)
#		(4 to 16 years) [all can be 16 years]
#		depends on management selected?
#                  forest will have 1 veg type
#
#

# reads:
  #  $nofe -- number of OFEs
# returns:
  #  $manFileName

# tentative naming scheme: [forest]
# forest and range/chaparral the same -- CM 03/18/2004
#    1ofe.man
#    2ofe.man
#    3ofe.man

#    $manFileName = 'for_' . $nofe . 'ofe.man';
     $manFileName = $nofe . 'ofe.man';				# DEH 2004.03.18

}

sub get_event_seds() {

# reads 
  # @month
  # @day
  # @selected_year
  # $ev_by_evFile	-- event file output file name

# sets
  # 

# returns
  # sediment delivery (kg/m) or ''

  my $line;
  my $counter;
  my $event;
  my $da;
  my $mo;
  my $yr;
  my $pcp;
  my $runoff;
  my $IRdet;
  my $avdet;
  my $mxdet;
  my $detpoint;
  my $avdep;
  my $maxdep;
  my $deppoint;
  my $seddel;
  my $er;
  my @idx_for_year;
  my @days;
  my @months;
  my @years;
  my @sed_dels;
  my @seds;
  my $i;
  my $j;
  my $min_year;

  $min_year = @years2run[0];
#  for $i (1..$#selected_year) {
#    if ((@selected_year[$i]+0) < $min_year) {$min_year = @selected_year[$i]}
#  }
  if ($debug) {print TEMP "min_year == $min_year<br>\n";}

  open EVENTS, "<$ev_by_evFile";

  $line = <EVENTS>;
  $line = <EVENTS>;
  $line = <EVENTS>;

  $counter = 0;
  while (<EVENTS>) {
    $event = $_;
    ($da, $mo, $yr, $pcp, $runoff, $IRdet, $avdet, $mxdet, $detpoint, $avdep, $maxdep, $deppoint, $seddel, $er) = split (' ',$event);
    $yr += $min_year -1;      # 2030 vulnerable line
    @idx_for_year[$yr] = $counter if (@idx_for_year[$yr] eq '');
    @days[$counter] = $da;
    @months[$counter] = $mo;
    @years[$counter] = $yr;
    @sed_dels[$counter] = $seddel;
    $counter+=1;

#  print TEMP $event;
#    print TEMP $da,'  ', $mo,'  ', $yr,'  ', $seddel,"\n";
  }

  close EVENTS;
#  print TEMP "$counter\n";

#  for $i (0..$#idx_for_year)  {
#   print TEMP $i,'  ',@idx_for_year[$i],"\n" if ($idx_for_year[$i] ne '')
#  }

  for $i (0..$#selected_year) {
#    if ($debug) {print TEMP 'Looking for day ' , @day[$i], ' month ' ,@month[$i], ' year ' , @selected_year[$i];}
    $start_index = @idx_for_year[@selected_year[$i]];
#    $end_index = @idx_for_year[@selected_year[$i]+1];
    $end_index = $#sed_dels;
#    if ($debug) {print TEMP "  starting at $start_index<br>\n";}
    for $j ($start_index..$end_index) {
#      if ($debug) {print TEMP '   comparing ', @days[$j],' to ',@day[$i],' and ',$months[$j],' to ',@month[$i],' and ',$years[$j],' to ',@selected_year[$i],"\n";}
      if (@days[$j] == @day[$i] && $months[$j] == @month[$i] && $years[$j] == @selected_year[$i]) {
#        if ($debug) {print TEMP "got it!\n";}
        @seds[$i] = @sed_dels[$j];
        last;
     }
     last if (($months[$j]+0) > (@month[$i]+0));
    }
  }
  return @seds;
}

sub printfile {

#  $filename = $_;
  open INININ, '<' . $printfilename;
   @filetext=<INININ>;
   print TEMP "<hr><br>$printfilename<pre>
   @filetext
   </pre>
";
  close INININ;    # 2003.01.14
}

sub CreateResponseFile {		# 100-year -- modified from wd.pl on PC43

   open (ResponseFile, ">" . $responseFile);
     print ResponseFile "m\n";           # metric output
     print ResponseFile "y\n";           # not watershed
     print ResponseFile "1\n";           # 1 = continuous
     print ResponseFile "1\n";           # 1 = hillslope
     print ResponseFile "n\n";           # hillsplope pass file out?
     print ResponseFile "1\n";           # 1 = annual; abbreviated
     print ResponseFile "n\n";           # initial conditions file?
     print ResponseFile $outputFile,"\n";  # soil loss output file
     print ResponseFile "n\n";           # water balance output?
     print ResponseFile "n\n";           # crop output?
     print ResponseFile "n\n";           # soil output?
     print ResponseFile "n\n";           # distance/sed loss output?
     print ResponseFile "n\n";           # large graphics output?
     print ResponseFile "y\n";           # event-by-event out?
     print ResponseFile "$eventFile\n";   # event-by-event filename
     print ResponseFile "n\n";           # element output?
     print ResponseFile "n\n";           # final summary out?
     print ResponseFile "n\n";           # daily winter out?
     print ResponseFile "n\n";           # plant yield out?
     print ResponseFile "$manFile\n";    # management file name
     print ResponseFile "$slopeFile\n";  # slope file name
     print ResponseFile "$CLIfile\n";    # climate file name
     print ResponseFile "$soilFile\n";   # soil file name
     print ResponseFile "0\n";           # 0 = no irrigation
     print ResponseFile "$years2sim\n";  # no. years to simulate
     print ResponseFile "0\n";           # 0 = route all events

   close ResponseFile;
   return $responseFile;
}

sub createCligenFile {		# modified from wd.pl on PC43

  if ($new_cligen) {
    $station = substr($CL, length($CL)-8);
    if ($platform eq 'pc') {
#     @args = ("..\\rc\\cligen43.exe <$rspfile >$stoutfile");
      @args = ("cligen43.exe <$crspfile >$cstoutfile");
    }
    else {
      $startyear = 1;
#     @args = ("nice -20 ../rc/cligen43 <$rspfile >$stoutfile");
      @args = ("../rc/cligen522564 -i$PARfile -y$years2sim -b$startyear -t5 -o$CLIfile >$cstoutfile");
    }

   if ($debug) {print TEMP "[createCligenFile]<br>
Arguments:    @args<br>
StandardOut:  $cstoutfile<br>
";}

#  run CLIGEN522564 on verified user_id.par file to
#  create user_id.cli file in FSWEPP working directory
#  for $years2sim years.

#   unlink $PARfile;   # erase previous climate file so's CLIGEN'll run

   system @args;

  }
  else {	# if ($new_cligen)

    $station = substr($CL, length($CL)-8);
    if ($platform eq 'pc') {
#      @args = ("..\\rc\\cligen43.exe <$rspfile >$stoutfile");
       @args = ("cligen43.exe <$crspfile >$cstoutfile");
    }
    else {
#      @args = ("nice -20 ../rc/cligen43 <$rspfile >$stoutfile");
       @args = ("../rc/cligen43 <$crspfile >$cstoutfile");
    }

   if ($debug) {print TEMP "[createCligenFile]<br>
Arguments:    $args<br>
PARfile:      $PARfile<br>
CLIfile:      $CLIfile<br>
ResponseFile: $crspfile<br>
StandardOut:  $cstoutfile<br>
";}

#  run CLIGEN43 on verified user_id.par file to
#  create user_id.cli file in FSWEPP working directory
#  for $years2sim years.

   $startyear = 1;

   open RSP, ">" . $crspfile;
     print RSP "4.31\n";
     print RSP $PARfile,"\n";
     print RSP "n do not display file here\n";
     print RSP "5 Multiple-year WEPP format\n";
     print RSP $startyear,"\n";
     print RSP $years2sim,"\n";
    print RSP $CLIfile,"\n";
    print RSP "n\n";
   close RSP;

#   unlink $PARfile;   # erase previous climate file so's CLIGEN'll run

   system @args;
  }	# if ($new_cligen)

#   if ($debug) {
#     open STOUT, "<$cstoutfile";
#     print "Cligen: \n";
#     while (<STOUT>) {
#       print $_,"\n<br>";
#     }
#     close STOUT;
#   }
}

sub readWEPPresults  {

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
              print TEMP "<font color=red>\n";
              $_ = <weppstout>;  $_ = <weppstout>; 
              $_ = <weppstout>;  print TEMP;
              $_ = <weppstout>;  print TEMP;
              print TEMP "</font>\n";
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
             print TEMP "<font color=red>\n";
             print TEMP;
             print TEMP "</font>\n";
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
             print TEMP "<font color=red>\n";
             $_ = <weppstout>; print TEMP;
             $_ = <weppstout>; print TEMP;
             $_ = <weppstout>; print TEMP;
             $_ = <weppstout>; print TEMP;
             print TEMP "</font>\n";
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
             print TEMP "<font color=red>\n";
             print TEMP 'WEPP has run into a mathematical anomaly.<br>
             You may be able to get around it by modifying the geometry slightly;
             try changing road length by 1 foot (1/2 meter) or so.
             ';
             $_ = <weppstout>; print TEMP;
             print TEMP "</font>\n";
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
             $climate_name =~ s/^\s*(.*?)\s*$/$1/;    # strip whitespace 
             last;
           }
         }
         while (<weppout>) {
           if (/RAINFALL AND RUNOFF SUMMARY/) {
             $_ = <weppout>; #      -------- --- ------ -------
             $_ = <weppout>; # 
             $_ = <weppout>; #       total summary:  years    1 -    1
             $_ = <weppout>; # 
             $_ = <weppout>; #         71 storms produced 346.90 mm of precipitation
             $storms = substr $_,1,10;
             $_ = <weppout>; #          3 rain storm runoff events produced          0.00 mm of runoff
             $rainevents = substr $_,1,10;
             $_ = <weppout>; #          2 snow melts and/or
             $snowevents = substr $_,1,10;
             $_ = <weppout>; #              events during winter produced 0.00 mm of runoff
             $_ = <weppout>; # 
             $_ = <weppout>; #      annual averages
             $_ = <weppout>; #      ---------------
             $_ = <weppout>; #
             $_ = <weppout>; #        Number of years   1
             $_ = <weppout>; #        Mean annual precipitation 346.90    mm
             $precip = substr $_,51,10;
             $_ = <weppout>; $rro = substr $_,51,10;   # print TEMP; 
             $_ = <weppout>; # print TEMP;
             $_ = <weppout>; $sro = substr $_,51,10;   # print TEMP; 
             $_ = <weppout>; # print TEMP;
             last;
           }
         }
         while (<weppout>) {
           if (/AREA OF NET SOIL LOSS/) {
             $_ = <weppout>;             $_ = <weppout>;
             $_ = <weppout>;             $_ = <weppout>;
             $_ = <weppout>;             $_ = <weppout>; # print TEMP;
             $_ = <weppout>; # print TEMP;
             $_ = <weppout>; # print TEMP;
             $_ = <weppout>; # print TEMP;
             $_ = <weppout>; # print TEMP;
             $syr = substr $_,17,7;  
             $effective_road_length = substr $_,9,9;
             last;
           }
         }
         while (<weppout>) {
           if (/OFF SITE EFFECTS/) {
             $_ = <weppout>;             $_ = <weppout>;
             $_ = <weppout>; $syp = substr $_,49,10;   # pre-WEPP 98.4
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
       }
       else {           # ($found != 1)
         print TEMP "<p>\nSomething has gone wacko!\n<p><hr><p>\n";
       }
}

sub CreateJavascriptsoilfileFunction {
 # ******************************
}

sub CreateJavascriptwhatsedsFunction {

print '

function MakeArray () {
  this.length = 0
  return this
}

var a_len=200
scheme  = new MakeArray; scheme.length = a_len  // 2005.10.25 DEH
sed_del = new MakeArray; sed_del.length = a_len	// 2005.09.30 DEH
// no mitigation
cp0 = new MakeArray; cp0.length = a_len		// 2005.09.30 DEH
cp1 = new MakeArray; cp1.length = a_len
cp2 = new MakeArray; cp2.length = a_len
cp3 = new MakeArray; cp3.length = a_len
cp4 = new MakeArray; cp4.length = a_len
// seeding
cp_s0 = new MakeArray; cp_s0.length = a_len
cp_s1 = new MakeArray; cp_s1.length = a_len
cp_s2 = new MakeArray; cp_s2.length = a_len
cp_s3 = new MakeArray; cp_s3.length = a_len
cp_s4 = new MakeArray; cp_s4.length = a_len
// mulch 47%
cp_m470 = new MakeArray; cp_m470.length = a_len
cp_m471 = new MakeArray; cp_m471.length = a_len
cp_m472 = new MakeArray; cp_m472.length = a_len
cp_m473 = new MakeArray; cp_m473.length = a_len
cp_m474 = new MakeArray; cp_m474.length = a_len
// mulch 72%
cp_m720 = new MakeArray; cp_m720.length = a_len
cp_m721 = new MakeArray; cp_m721.length = a_len
cp_m722 = new MakeArray; cp_m722.length = a_len
cp_m723 = new MakeArray; cp_m723.length = a_len
cp_m724 = new MakeArray; cp_m724.length = a_len
// mulch 89%
cp_m890 = new MakeArray; cp_m890.length = a_len
cp_m891 = new MakeArray; cp_m891.length = a_len
cp_m892 = new MakeArray; cp_m892.length = a_len
cp_m893 = new MakeArray; cp_m893.length = a_len
cp_m894 = new MakeArray; cp_m894.length = a_len
// mulch 94%
cp_m940 = new MakeArray; cp_m940.length = a_len
cp_m941 = new MakeArray; cp_m941.length = a_len
cp_m942 = new MakeArray; cp_m942.length = a_len
cp_m943 = new MakeArray; cp_m943.length = a_len
cp_m944 = new MakeArray; cp_m944.length = a_len
';

# ###   DEH 2003/03/05 add variables to pass from perl to Javascript functions

#  $climate_name =~ s/^\s*(.*?)\s*$/$1/;    # strip whitespace 
  print "
   js_unique = '$unique'
   js_climate_name = '$climate_name'
   js_soil_texture = '$soil_texture'
   js_rfg = $rfg
   js_top_slope = $top_slope
   js_avg_slope = $avg_slope
   js_toe_slope = $toe_slope
   js_hillslope_length = $hillslope_length
   js_units = '$units'
   js_severityclass_x = '$severityclass_x'
   js_sedunits = '$sedunits'
   js_alt_sedunits = '$alt_sedunits'
   js_intensity_units='$intunits'
   // printer='http://$wepphost/fswepp/images/hinduonnet_print2.png'
   // gostone='http://$wepphost/fswepp/images/go.gif'
";
   if ($units eq 'm') {
     print '   js_sedconv = ' . 10 / $hillslope_length,"\n";
     print "   js_storage_units=\'Mg ha<sup>-1</sup>'\n";
   }
   else {
     print '   js_sedconv = ' . 4.45 / $hillslope_length_m,"\n";
     print "   js_storage_units='ton ac<sup>-1</sup>'\n";
   }

# ###

  $cum_prob0    =0.01; $cum_prob1    =0.01; $cum_prob2    =0.01; $cum_prob3    =0.01; $cum_prob4    =0.01;
  $cum_prob_s0  =0.01; $cum_prob_s1  =0.01; $cum_prob_s2  =0.01; $cum_prob_s3  =0.01; $cum_prob_s4  =0.01;
  $cum_prob_m470=0.01; $cum_prob_m471=0.01; $cum_prob_m472=0.01; $cum_prob_m473=0.01; $cum_prob_m474=0.01;
  $cum_prob_m720=0.01; $cum_prob_m721=0.01; $cum_prob_m722=0.01; $cum_prob_m723=0.01; $cum_prob_m724=0.01;
  $cum_prob_m890=0.01; $cum_prob_m891=0.01; $cum_prob_m892=0.01; $cum_prob_m893=0.01; $cum_prob_m894=0.01;
  $cum_prob_m940=0.01; $cum_prob_m941=0.01; $cum_prob_m942=0.01; $cum_prob_m943=0.01; $cum_prob_m944=0.01;

  for $i (0..$#sed_yields) {
#  for $i (0..115) {						# DEH test 2005.10.21
# no mitigation
    $cum_prob0 += @probabilities0[@index[$i]];
    $cum_prob1 += @probabilities1[@index[$i]];
    $cum_prob2 += @probabilities2[@index[$i]];
    $cum_prob3 += @probabilities3[@index[$i]];
    $cum_prob4 += @probabilities4[@index[$i]];
# seeding
    $cum_prob_s0 += @probabilities_s0[@index[$i]];
    $cum_prob_s1 += @probabilities_s1[@index[$i]];
    $cum_prob_s2 += @probabilities_s2[@index[$i]];
    $cum_prob_s3 += @probabilities_s3[@index[$i]];
    $cum_prob_s4 += @probabilities_s4[@index[$i]];
# mulch 47%
    $cum_prob_m470 += @probabilities_m470[@index[$i]];
    $cum_prob_m471 += @probabilities_m471[@index[$i]];
    $cum_prob_m472 += @probabilities_m472[@index[$i]];
    $cum_prob_m473 += @probabilities_m473[@index[$i]];
    $cum_prob_m474 += @probabilities_m474[@index[$i]];
# mulch 72%
    $cum_prob_m720 += @probabilities_m720[@index[$i]];
    $cum_prob_m721 += @probabilities_m721[@index[$i]];
    $cum_prob_m722 += @probabilities_m722[@index[$i]];
    $cum_prob_m723 += @probabilities_m723[@index[$i]];
    $cum_prob_m724 += @probabilities_m724[@index[$i]];
# mulch 89%
    $cum_prob_m890 += @probabilities_m890[@index[$i]];
    $cum_prob_m891 += @probabilities_m891[@index[$i]];
    $cum_prob_m892 += @probabilities_m892[@index[$i]];
    $cum_prob_m893 += @probabilities_m893[@index[$i]];
    $cum_prob_m894 += @probabilities_m894[@index[$i]];
# mulch 94%
    $cum_prob_m940 += @probabilities_m940[@index[$i]];
    $cum_prob_m941 += @probabilities_m941[@index[$i]];
    $cum_prob_m942 += @probabilities_m942[@index[$i]];
    $cum_prob_m943 += @probabilities_m943[@index[$i]];
    $cum_prob_m944 += @probabilities_m944[@index[$i]];
    $j = $i + 1;
    $scheme = @scheme[@index[$i]];				# 2005.10.25 DEH
    $sedval = @sed_yields[@index[$i]];
    if ($sedval eq '') {$sedval = '0.0'}
    print "sed_del[$j] = $sedval; scheme[$j] = '$scheme'\n";	# 2005.10.25 DEH
    print "  cp0[$j] = $cum_prob0; ";
    print "  cp1[$j] = $cum_prob1; ";
    print "  cp2[$j] = $cum_prob2; ";
    print "  cp3[$j] = $cum_prob3; ";
    print "  cp4[$j] = $cum_prob4\n";
    print "  cp_s0[$j] = $cum_prob_s0; ";
    print "  cp_s1[$j] = $cum_prob_s1; ";
    print "  cp_s2[$j] = $cum_prob_s2; ";
    print "  cp_s3[$j] = $cum_prob_s3; ";
    print "  cp_s4[$j] = $cum_prob_s4\n";
    print "  cp_m470[$j] = $cum_prob_m470; ";
    print "  cp_m471[$j] = $cum_prob_m471; ";
    print "  cp_m472[$j] = $cum_prob_m472; ";
    print "  cp_m473[$j] = $cum_prob_m473; ";
    print "  cp_m474[$j] = $cum_prob_m474\n";
    print "  cp_m720[$j] = $cum_prob_m720; ";
    print "  cp_m721[$j] = $cum_prob_m721; ";
    print "  cp_m722[$j] = $cum_prob_m722; ";
    print "  cp_m723[$j] = $cum_prob_m723; ";
    print "  cp_m724[$j] = $cum_prob_m724\n";
    print "  cp_m890[$j] = $cum_prob_m890; ";
    print "  cp_m891[$j] = $cum_prob_m891; ";
    print "  cp_m892[$j] = $cum_prob_m892; ";
    print "  cp_m893[$j] = $cum_prob_m893; ";
    print "  cp_m894[$j] = $cum_prob_m894\n";
    print "  cp_m940[$j] = $cum_prob_m940; ";
    print "  cp_m941[$j] = $cum_prob_m941; ";
    print "  cp_m942[$j] = $cum_prob_m942; ";
    print "  cp_m943[$j] = $cum_prob_m943; ";
    print "  cp_m944[$j] = $cum_prob_m944\n";
  }

print <<'EOP';

function whatseds (n, array) {

  var diff_fuzz = 0.0001      // probability fuzz
  var diff=0
  var k = 1
  var gotit = 0
  while (k <= array.length && gotit == 0) {
    if (array[k] >= n) {
      gotit = 1
      if (k > 1) {
        j = k - 1
        diff=Math.abs(array[k] - array[j])
        if (diff < diff_fuzz) {
          sed = sed_del[k]
        }
        else {
          prop = (array[k] - n) / diff    // poss math problem
          sed = sed_del[k] - (sed_del[k] - sed_del[j]) * prop
        }
        return sed
      }
      if (k == 1) {
        return sed_del[1]
      }
    }
    if (gotit == 0) {
      k = k + 1
    }
  } 
//  alert ('dropped out of whatseds')
  return sed_del[array.length]
}

function old_whatseds (n, array) {

//prob_fuzz = 0.0001      // probability fuzz
  k = 1
  gotit = 0
  while (k <= array.length && gotit == 0) {
    if (array[k] >= n) {
      gotit = 1
      if (k > 1) {
        j = k - 1
          prop = (array[k] - n) / (array[k] - array[j])    // poss math problem
          sed = sed_del[k] - (sed_del[k] - sed_del[j]) * prop
        return sed
      }
      if (k == 1) {
        return sed_del[1]
      }
    }
    if (gotit == 0) {
      k = k + 1
    }
  } 
}

function whatsedscl (n, array) {

}

function whatprob (n, array) {

//sed_fuzz = 0.001   // sediment delivery rate fuzz in kg per m
  k = 1
  gotit = 0
  while (k <= sed_del.length && gotit == 0) {
    if (sed_del[k] <= n) {
      gotit = 1
      if (k > 1) {
        j = k - 1
          proportion = (sed_del[k] - n) / (sed_del[k] - sed_del[j])  // poss math problem
          prob = array[k] - (array[k] - array[j]) * proportion
        return prob
      }
      if (k == 1) {
        return array[1]
      }
    }
    if (gotit == 0) {
      k = k + 1
    }
  }
}

function whatprobcl (sed_treated, array) {

}

function logchange () {

// read data from form fields into variables
   var diameter=document.doit.diameter.value	// DEH 2005.09
   var spacing=document.doit.spacing.value	// DEH 2005.09
//   var js_avg_slope=document.doit.slope.value	// DEH 2005.09.23 ***
//   alert (js_avg_slope)

// i10 (10-min peak intensity (mm h-1) and js_avg_slope are temporarily inputtable
// i10 will be calculated and js_avg_slope will revert to global value
   var i10=document.doit.i10.value		// DEH 2005.09
// do a bit of error-checking on form values
   if (!isNumber (diameter)) {diameter = 0; document.doit.diameter.value=0}
   if (!isNumber (spacing))  {spacing = 100; document.doit.spacing.value=100}

// temporary -- should be OK
//   if (!isNumber (i10)) {i10 = 10; document.doit.i10.value=i10}
   if (!isNumber (js_avg_slope)) {js_avg_slope = 0; document.doit.slope.value=0} // ***

// alert('i10 '+i10)

// set minimum values for log spacing and slope (both in denominator of equation)
   var slope_max = 100		// %
   var slope_min = 0.05		// %
   var spacing_min = 1		// m

   if (js_avg_slope>slope_max) {js_avg_slope = slope_max} // ???

//   alert (js_units)
// convert units if necessary
   var spacing_m = spacing
   var diameter_m = diameter
   if (js_units == 'ft') {
    spacing_m = spacing * 0.3048     // convert ft to m if necessary	// DEH 2005.09
    diameter_m = diameter * 0.3048   // convert ft to m if necessary	// DEH 2005.09
   }
   var diam_cm = diameter_m * 100	// log diameter in cm

// get no-treatment sediment values from table
   sediment_0=document.getElementById('sediment0').innerHTML
   sediment_1=document.getElementById('sediment1').innerHTML
   sediment_2=document.getElementById('sediment2').innerHTML
   sediment_3=document.getElementById('sediment3').innerHTML
   sediment_4=document.getElementById('sediment4').innerHTML
   if (js_avg_slope < slope_min || spacing_m < spacing_min) {
     document.getElementById('sediment_cl0').innerHTML = sediment_0
     document.getElementById('sediment_cl1').innerHTML = sediment_1
     document.getElementById('sediment_cl2').innerHTML = sediment_2
     document.getElementById('sediment_cl3').innerHTML = sediment_3
     document.getElementById('sediment_cl4').innerHTML = sediment_4
     document.getElementById('eff0').innerHTML = ''
     document.getElementById('eff1').innerHTML = ''
     document.getElementById('eff2').innerHTML = ''
     document.getElementById('eff3').innerHTML = ''
     document.getElementById('caught0').innerHTML = 0
     document.getElementById('caught1').innerHTML = 0
     document.getElementById('caught2').innerHTML = 0
     document.getElementById('caught3').innerHTML = 0
     document.getElementById('capacity0').innerHTML = ''
     document.getElementById('capacity1').innerHTML = ''
     document.getElementById('capacity2').innerHTML = ''
     document.getElementById('capacity3').innerHTML = ''
   }
   else {

//   coefficients from measured data; form of equation based on geometry
//     capacity in m^3/ha = a / slope_in_percent + b * diam^2_in_cm^2 + c / spacing_in_m + d

     sediment_bulk_density=1
     if (js_soil_texture == 'clay loam') sediment_bulk_density = 1.1	// g/m^3
     if (js_soil_texture == 'silt loam') sediment_bulk_density = 0.97
     if (js_soil_texture == 'sandy loam') sediment_bulk_density = 1.23
     if (js_soil_texture == 'loam') sediment_bulk_density = 1.16
//   alert (js_soil_texture + ' sediment bulk density: ' + sediment_bulk_density)
     coeff_slope = 1342			// slope in whole percent i.e. '30'
     coeff_diam = 0.0029		// diam^2 for diam in cm
     coeff_spacing = 544		// spacing in m
     intercept = -35.4
     capacity_vol = coeff_slope/js_avg_slope+coeff_diam*diam_cm*diam_cm+coeff_spacing/spacing_m+intercept
     if (capacity_vol<0) {capacity_vol=0}

     capacity_m = capacity_vol * sediment_bulk_density		// capacity in Mg/ha
     capacity = capacity_m
     if (js_units == 'ft') {capacity=0.4461*capacity_m} 	// capacity in user units ton/ac or Mg/ha
     document.doit.capacity.value=capacity			// DEH 2005.09
     var eff_0 = 113.97-0.8425*i10;  if (eff_0<0) {eff_0=0}; if (eff_0>100) {eff_0=100}
     var eff_1 = 116-1.4*i10;        if (eff_1<0) {eff_1=0}; if (eff_1>100) {eff_1=100}
     var eff_2 = eff_1 * 0.75;       if (eff_2<0) {eff_2=0}; if (eff_2>100) {eff_2=100}
     var eff_3 = eff_2 * 0.55;       if (eff_3<0) {eff_3=0}; if (eff_3>100) {eff_3=100}
     var caught_0 = capacity * eff_0/100; if (caught_0>sediment_0) {caught_0=sediment_0}
     var caught_1 = capacity * eff_1/100; if (caught_1>sediment_1) {caught_1=sediment_1}
     var caught_2 = capacity * eff_2/100; if (caught_2>sediment_2) {caught_2=sediment_2}
     var caught_3 = capacity * eff_3/100; if (caught_3>sediment_3) {caught_3=sediment_3}
     document.getElementById('sediment_cl0').innerHTML = rounder(sediment_0-caught_0,2)
     document.getElementById('sediment_cl1').innerHTML = rounder(sediment_1-caught_1,2)
     document.getElementById('sediment_cl2').innerHTML = rounder(sediment_2-caught_2,2)
     document.getElementById('sediment_cl3').innerHTML = rounder(sediment_3-caught_3,2)
     if (sediment_4 < (sediment_3-caught_3)) {
       document.getElementById('sediment_cl4').innerHTML = sediment_4
     }
     else {
       document.getElementById('sediment_cl4').innerHTML = rounder(sediment_3-caught_3,2)
     }
     document.getElementById('eff0').innerHTML = rounder(eff_0,0)
     document.getElementById('eff1').innerHTML = rounder(eff_1,0)
     document.getElementById('eff2').innerHTML = rounder(eff_2,0)
     document.getElementById('eff3').innerHTML = rounder(eff_3,0)
     document.getElementById('caught0').innerHTML = rounder(caught_0,2)
     document.getElementById('caught1').innerHTML = rounder(caught_1,2)
     document.getElementById('caught2').innerHTML = rounder(caught_2,2)
     document.getElementById('caught3').innerHTML = rounder(caught_3,2)
     document.getElementById('capacity0').innerHTML = rounder(capacity,2)		// 2005.10.20 DEH
     document.getElementById('capacity1').innerHTML = rounder(capacity,2)
     document.getElementById('capacity2').innerHTML = rounder(capacity,2)
     document.getElementById('capacity3').innerHTML = rounder(capacity,2)
  }
}

function sedchange () {

  var sed_del_min = rounder(sed_del[100]*js_sedconv,2)		// 2005.09.30 DEH not true
  var sed_del_max = rounder(sed_del[1]*js_sedconv,2)
  var default_sed_del = rounder((sed_del_max-sed_del_min)/2,2)

    sedval = document.doit.sediment0x.value
    if (!isNumber (sedval)) {sedval = default_sed_del}
    if (sedval > sed_del_max) {sedval = sed_del_max}
    if (sedval < sed_del_min) {sedval = sed_del_min}
    document.doit.sediment0x.value=sedval

    document.doit.probability0.value = rounder(whatprob(sedval/js_sedconv, eval('cp0'))*100,2)
    document.doit.probability1.value = rounder(whatprob(sedval/js_sedconv, eval('cp1'))*100,2)
    document.doit.probability2.value = rounder(whatprob(sedval/js_sedconv, eval('cp2'))*100,2)
    document.doit.probability3.value = rounder(whatprob(sedval/js_sedconv, eval('cp3'))*100,2)
    document.doit.probability4.value = rounder(whatprob(sedval/js_sedconv, eval('cp4'))*100,2)

    document.doit.probability_s0.value = rounder(whatprob(sedval/js_sedconv, eval('cp_s0'))*100,2)
    document.doit.probability_s1.value = rounder(whatprob(sedval/js_sedconv, eval('cp_s1'))*100,2)
    document.doit.probability_s2.value = rounder(whatprob(sedval/js_sedconv, eval('cp_s2'))*100,2)
    document.doit.probability_s3.value = rounder(whatprob(sedval/js_sedconv, eval('cp_s3'))*100,2)
    document.doit.probability_s4.value = rounder(whatprob(sedval/js_sedconv, eval('cp_s4'))*100,2)

    document.doit.probability_m470.value = rounder(whatprob(sedval/js_sedconv, eval('cp_m470'))*100,2)
    document.doit.probability_m471.value = rounder(whatprob(sedval/js_sedconv, eval('cp_m471'))*100,2)
    document.doit.probability_m472.value = rounder(whatprob(sedval/js_sedconv, eval('cp_m472'))*100,2)
    document.doit.probability_m473.value = rounder(whatprob(sedval/js_sedconv, eval('cp_m473'))*100,2)
    document.doit.probability_m474.value = rounder(whatprob(sedval/js_sedconv, eval('cp_m474'))*100,2)

    document.doit.probability_m720.value = rounder(whatprob(sedval/js_sedconv, eval('cp_m720'))*100,2)
    document.doit.probability_m721.value = rounder(whatprob(sedval/js_sedconv, eval('cp_m721'))*100,2)
    document.doit.probability_m722.value = rounder(whatprob(sedval/js_sedconv, eval('cp_m722'))*100,2)
    document.doit.probability_m723.value = rounder(whatprob(sedval/js_sedconv, eval('cp_m723'))*100,2)
    document.doit.probability_m724.value = rounder(whatprob(sedval/js_sedconv, eval('cp_m724'))*100,2)

    document.doit.probability_m890.value = rounder(whatprob(sedval/js_sedconv, eval('cp_m890'))*100,2)
    document.doit.probability_m891.value = rounder(whatprob(sedval/js_sedconv, eval('cp_m891'))*100,2)
    document.doit.probability_m892.value = rounder(whatprob(sedval/js_sedconv, eval('cp_m892'))*100,2)
    document.doit.probability_m893.value = rounder(whatprob(sedval/js_sedconv, eval('cp_m893'))*100,2)
    document.doit.probability_m894.value = rounder(whatprob(sedval/js_sedconv, eval('cp_m894'))*100,2)

    document.doit.probability_m940.value = rounder(whatprob(sedval/js_sedconv, eval('cp_m940'))*100,2)
    document.doit.probability_m941.value = rounder(whatprob(sedval/js_sedconv, eval('cp_m941'))*100,2)
    document.doit.probability_m942.value = rounder(whatprob(sedval/js_sedconv, eval('cp_m942'))*100,2)
    document.doit.probability_m943.value = rounder(whatprob(sedval/js_sedconv, eval('cp_m943'))*100,2)
    document.doit.probability_m944.value = rounder(whatprob(sedval/js_sedconv, eval('cp_m944'))*100,2)

//    document.doit.probability_cl0.value = rounder(whatprobcl(sedval/js_sedconv, eval('cp0'))*100,2)
//    document.doit.probability_cl1.value = rounder(whatprobcl(sedval/js_sedconv, eval('cp1'))*100,2)
//    document.doit.probability_cl2.value = rounder(whatprobcl(sedval/js_sedconv, eval('cp2'))*100,2)
//    document.doit.probability_cl3.value = rounder(whatprobcl(sedval/js_sedconv, eval('cp3'))*100,2)
//    document.doit.probability_cl4.value = rounder(whatprobcl(sedval/js_sedconv, eval('cp4'))*100,2)

//  printprobs()

}

function probchange () {

  var myprob=document.doit.probability0x.value
  if (!isNumber (myprob)) {myprob = 10}
//  if (myprob < 0.1)       {myprob = .1}
  if (myprob < 5.0)       {myprob = 5.0}
  if (myprob > 99.9)      {myprob = 99.9}
  document.doit.probability0x.value = myprob
  myprob = myprob/100

  document.getElementById("sediment0").innerHTML = rounder(whatseds (myprob, eval('cp0')) * js_sedconv,2)
  document.getElementById("sediment1").innerHTML = rounder(whatseds (myprob, eval('cp1')) * js_sedconv,2)
  document.getElementById("sediment2").innerHTML = rounder(whatseds (myprob, eval('cp2')) * js_sedconv,2)
  document.getElementById("sediment3").innerHTML = rounder(whatseds (myprob, eval('cp3')) * js_sedconv,2)
  document.getElementById("sediment4").innerHTML = rounder(whatseds (myprob, eval('cp4')) * js_sedconv,2)

  document.getElementById("sediment_s0").innerHTML = rounder(whatseds (myprob,eval('cp_s0')) * js_sedconv,2)
  document.getElementById("sediment_s1").innerHTML = rounder(whatseds (myprob,eval('cp_s1')) * js_sedconv,2)
  document.getElementById("sediment_s2").innerHTML = rounder(whatseds (myprob,eval('cp_s2')) * js_sedconv,2)
  document.getElementById("sediment_s3").innerHTML = rounder(whatseds (myprob,eval('cp_s3')) * js_sedconv,2)
  document.getElementById("sediment_s4").innerHTML = rounder(whatseds (myprob,eval('cp_s4')) * js_sedconv,2)

  document.getElementById("sediment_m470").innerHTML = rounder(whatseds (myprob,eval('cp_m470')) * js_sedconv,2)
  document.getElementById("sediment_m471").innerHTML = rounder(whatseds (myprob,eval('cp_m471')) * js_sedconv,2)
  document.getElementById("sediment_m472").innerHTML = rounder(whatseds (myprob,eval('cp_m472')) * js_sedconv,2)
  document.getElementById("sediment_m473").innerHTML = rounder(whatseds (myprob,eval('cp_m473')) * js_sedconv,2)
  document.getElementById("sediment_m474").innerHTML = rounder(whatseds (myprob,eval('cp_m474')) * js_sedconv,2)

  document.getElementById("sediment_m720").innerHTML = rounder(whatseds (myprob,eval('cp_m720')) * js_sedconv,2)
  document.getElementById("sediment_m721").innerHTML = rounder(whatseds (myprob,eval('cp_m721')) * js_sedconv,2)
  document.getElementById("sediment_m722").innerHTML = rounder(whatseds (myprob,eval('cp_m722')) * js_sedconv,2)
  document.getElementById("sediment_m723").innerHTML = rounder(whatseds (myprob,eval('cp_m723')) * js_sedconv,2)
  document.getElementById("sediment_m724").innerHTML = rounder(whatseds (myprob,eval('cp_m724')) * js_sedconv,2)

  document.getElementById("sediment_m890").innerHTML = rounder(whatseds (myprob,eval('cp_m890')) * js_sedconv,2)
  document.getElementById("sediment_m891").innerHTML = rounder(whatseds (myprob,eval('cp_m891')) * js_sedconv,2)
  document.getElementById("sediment_m892").innerHTML = rounder(whatseds (myprob,eval('cp_m892')) * js_sedconv,2)
  document.getElementById("sediment_m893").innerHTML = rounder(whatseds (myprob,eval('cp_m893')) * js_sedconv,2)
  document.getElementById("sediment_m894").innerHTML = rounder(whatseds (myprob,eval('cp_m894')) * js_sedconv,2)

  document.getElementById("sediment_m940").innerHTML = rounder(whatseds (myprob,eval('cp_m940')) * js_sedconv,2)
  document.getElementById("sediment_m941").innerHTML = rounder(whatseds (myprob,eval('cp_m941')) * js_sedconv,2)
  document.getElementById("sediment_m942").innerHTML = rounder(whatseds (myprob,eval('cp_m942')) * js_sedconv,2)
  document.getElementById("sediment_m943").innerHTML = rounder(whatseds (myprob,eval('cp_m943')) * js_sedconv,2)
  document.getElementById("sediment_m944").innerHTML = rounder(whatseds (myprob,eval('cp_m944')) * js_sedconv,2)

//  document.getElementById("sediment_cl0").innerHTML = rounder(whatsedscl (myprob,eval('cp0')) * js_sedconv,2)
//  document.getElementById("sediment_cl1").innerHTML = rounder(whatsedscl (myprob,eval('cp1')) * js_sedconv,2)
//  document.getElementById("sediment_cl2").innerHTML = rounder(whatsedscl (myprob,eval('cp2')) * js_sedconv,2)
//  document.getElementById("sediment_cl3").innerHTML = rounder(whatsedscl (myprob,eval('cp3')) * js_sedconv,2)
//  document.getElementById("sediment_cl4").innerHTML = rounder(whatsedscl (myprob,eval('cp4')) * js_sedconv,2)
//document.doit.sediment_cl4.value = rounder(whatsedscl (myprob,eval('cp4')) * js_sedconv,2)

   logchange()	// 2005.10.21 DEH

//  printprobs()

}

function isNumber(inputVal) {		//From JavaScript Handbook (Goodman) p. 374.
  oneDecimal = false
  inputStr = "" + inputVal
  for (var i = 0; i < inputStr.length; i++) {
    var oneChar = inputStr.charAt(i)
    if (i == 0 && oneChar == "-") {
      continue
    }
    if (oneChar == "." && !oneDecimal) {
      oneDecimal = true
      continue
    }
    if (oneChar < "0" || oneChar > "9") {
      return false
    }
  }
  return true
}

function rounder (x,d) {
// round x to d decimal places
  if (isNumber(x)) {
    var y = Math.pow(10, d)
    return Math.round(x * y)/y
  }
  else {return x}
}

function showtable (which,where,what) {

// to do: report WEPP unique run number
// 2005.10.25 DEH add column for permutation (climate/spatial/soil) and reduce font size
// 2005.10.24 DEH to remove noise, and tidy up HTML code generated
// display sediment delivery vs. cumulative probability (5 years) table
// for no-mitigation, seeding, or mulching

// which:  Cumulative probability array base name
// where:  browser window ID (no spaces)
// what:  'No mitigation', 'Seeding', or 'Mulching' 

  var0 = eval(which + '0')
  var1 = eval(which + '1')
  var2 = eval(which + '2')
  var3 = eval(which + '3')
  var4 = eval(which + '4')
  newin = window.open('',where,'width=600,height=300,scrollbars=yes,resizable=yes')
  newin.document.open()
  newin.document.writeln('<HTML>')
  newin.document.writeln(' <HEAD>')
  newin.document.writeln('  <title>'+what+' probability table<\/title>')
  newin.document.writeln(' <\/HEAD>')
  newin.document.writeln(' <body bgcolor="ivory" onLoad="top.window.focus()">')
  newin.document.writeln('  <font face="Tahoma, Arial, Helvetica, sans serif" size=-1>')
  newin.document.writeln('   <h3>Erosion Risk Management Tool<\/h3>')
  newin.document.writeln('   <h3 align="center">'+what+'<\/h3>')
  newin.document.writeln('   '+js_climate_name+'<br>'+js_soil_texture+'; '+js_rfg+'% rock; '+js_top_slope+'%, '+js_avg_slope+'%,'+js_toe_slope+'% slope; '+js_hillslope_length+' '+ js_units+'; '+js_severityclass_x+' soil burn severity<br>[Run ID '+js_unique+']')
  newin.document.writeln('   <table border=1 cellpadding=5>')
  newin.document.writeln('    <tr><th rowspan=2 bgcolor=ffff99><font face="Tahoma, Arial, Helvetica, sans serif" size=-1>Sediment delivery<br>('+js_alt_sedunits+')<\/th>')
  newin.document.writeln('     <th colspan=5 bgcolor=ffff99><font face="Tahoma, Arial, Helvetica, sans serif" size=-1>Percent chance that sediment delivery will be exceeded<\/th>')
  newin.document.writeln('     <th rowspan=2 bgcolor=ffff99><font face="Tahoma, Arial, Helvetica, sans serif" size=-1>Permutation<br><font size=-2>Climate rank<br>Spatial burn<br>Soil class<\/font><\/th><\/tr>')
  newin.document.writeln('    <tr><th bgcolor=ffff99><font face="Tahoma, Arial, Helvetica, sans serif" size=-1>1st year<\/th>')
  newin.document.writeln('     <th bgcolor=ffff99><font face="Tahoma, Arial, Helvetica, sans serif" size=-1>2nd year<\/th>')
  newin.document.writeln('     <th bgcolor=ffff99><font face="Tahoma, Arial, Helvetica, sans serif" size=-1>3rd year<\/th>')
  newin.document.writeln('     <th bgcolor=ffff99><font face="Tahoma, Arial, Helvetica, sans serif" size=-1>4th year<\/th>')
  newin.document.writeln('     <th bgcolor=ffff99><font face="Tahoma, Arial, Helvetica, sans serif" size=-1>5th year<\/th><\/tr>')
  seddel = sed_del[1] * js_sedconv  // kg / m to t / ac or t / ha
  newin.document.writeln('    <tr><td align=right bgcolor=ffff99><b><font face="Tahoma, Arial, Helvetica, sans serif" size=-1>' + rounder(seddel,2)+'<\/b><\/td>')
    if (var0[1] == 0.01) {newin.document.writeln('     <td>&nbsp;<\/td>')} else {newin.document.writeln('     <td><font face="Tahoma, Arial, Helvetica, sans serif" size=-1>' + rounder(var0[1]*100,2)+'<\/td>')}
    if (var1[1] == 0.01) {newin.document.writeln('     <td>&nbsp;<\/td>')} else {newin.document.writeln('     <td><font face="Tahoma, Arial, Helvetica, sans serif" size=-1>' + rounder(var1[1]*100,2)+'<\/td>')}
    if (var2[1] == 0.01) {newin.document.writeln('     <td>&nbsp;<\/td>')} else {newin.document.writeln('     <td><font face="Tahoma, Arial, Helvetica, sans serif" size=-1>' + rounder(var2[1]*100,2)+'<\/td>')}
    if (var3[1] == 0.01) {newin.document.writeln('     <td>&nbsp;<\/td>')} else {newin.document.writeln('     <td><font face="Tahoma, Arial, Helvetica, sans serif" size=-1>' + rounder(var3[1]*100,2)+'<\/td>')}
    if (var4[1] == 0.01) {newin.document.writeln('     <td>&nbsp;<\/td>')} else {newin.document.writeln('     <td><font face="Tahoma, Arial, Helvetica, sans serif" size=-1>' + rounder(var4[1]*100,2)+'<\/td>')}
  newin.document.writeln('    <td align=right><font face="Tahoma, Arial, Helvetica, sans serif" size=-1>' + scheme[1]+'<\/td>')
  newin.document.writeln('    <\/tr>')
  for (var i=2; i<= sed_del.length; i++) {
    seddel = sed_del[i] * js_sedconv  // kg / m to t / ac or t / ha
    newin.document.writeln('    <tr><td align=right bgcolor=ffff99><b><font face="Tahoma, Arial, Helvetica, sans serif" size=-1>' + rounder(seddel,2)+'<\/b><\/td>')
    if (var0[i] == var0[i-1]) {newin.document.writeln('     <td>&nbsp;<\/td>')} else {newin.document.writeln('     <td><font face="Tahoma, Arial, Helvetica, sans serif" size=-1>' + rounder(var0[i]*100,2)+'<\/td>')}
    if (var1[i] == var1[i-1]) {newin.document.writeln('     <td>&nbsp;<\/td>')} else {newin.document.writeln('     <td><font face="Tahoma, Arial, Helvetica, sans serif" size=-1>' + rounder(var1[i]*100,2)+'<\/td>')}
    if (var2[i] == var2[i-1]) {newin.document.writeln('     <td>&nbsp;<\/td>')} else {newin.document.writeln('     <td><font face="Tahoma, Arial, Helvetica, sans serif" size=-1>' + rounder(var2[i]*100,2)+'<\/td>')}
    if (var3[i] == var3[i-1]) {newin.document.writeln('     <td>&nbsp;<\/td>')} else {newin.document.writeln('     <td><font face="Tahoma, Arial, Helvetica, sans serif" size=-1>' + rounder(var3[i]*100,2)+'<\/td>')}
    if (var4[i] == var4[i-1]) {newin.document.writeln('     <td>&nbsp;<\/td>')} else {newin.document.writeln('     <td><font face="Tahoma, Arial, Helvetica, sans serif" size=-1>' + rounder(var4[i]*100,2)+'<\/td>')}
    newin.document.writeln('    <td align=right><font face="Tahoma, Arial, Helvetica, sans serif" size=-1>' + scheme[i]+'<\/td>')
    newin.document.writeln('    <\/tr>')
    if (sed_del[i] == 0) {break}					// DEH 2004.03.18 move from top
  }
//  for (var i=1; i<=sed_del.length; i++) {
//    seddel = sed_del[i] * js_sedconv  // kg / m to t / ac or t / ha
//    newin.document.write(' <tr><td align=right bgcolor=ffff99><b>')
//    newin.document.writeln('  <font face="Tahoma, Arial, Helvetica, sans serif">' + rounder(seddel,2)+'<\/b><\/td>')
//    newin.document.writeln(' <td><font face="Tahoma, Arial, Helvetica, sans serif">' + rounder(var0[i]*100,2)+'<\/td>')
//    newin.document.writeln(' <td><font face="Tahoma, Arial, Helvetica, sans serif">' + rounder(var1[i]*100,2)+'<\/td>')
//    newin.document.writeln(' <td><font face="Tahoma, Arial, Helvetica, sans serif">' + rounder(var2[i]*100,2)+'<\/td>')
//    newin.document.writeln(' <td><font face="Tahoma, Arial, Helvetica, sans serif">' + rounder(var3[i]*100,2)+'<\/td>')
//    newin.document.writeln(' <td><font face="Tahoma, Arial, Helvetica, sans serif">' + rounder(var4[i]*100,2)+'<\/td><\/tr>')
//    if (sed_del[i] == 0) {break}					// DEH 2004.03.18 move from top
//  }
  newin.document.writeln('   <\/table>')
  newin.document.writeln('   <!--tool bar begins--><p>')
  newin.document.writeln('     <table bgcolor="#666666" width="20%" border="0" cellspacing="1" cellpadding="5" align="center">')
  newin.document.writeln('      <tr>')
  newin.document.writeln('       <td align="center" bgcolor="#dddddd" onMouseOver="this.style.backgroundColor=\'#ffffff\';" onMouseOut="this.style.backgroundColor=\'\';"><font face="verdana,arial,helvetica" size="1"><img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.print()">Print&nbsp;me<\/a><\/font><\/td>')
  newin.document.writeln('       <td align="center" bgcolor="#dddddd" onMouseOver="this.style.backgroundColor=\'#ffffff\';" onMouseOut="this.style.backgroundColor=\'\';"><font face="verdana,arial,helvetica" size="1"><img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.close()">Close&nbsp;me\</a><\/font><\/td>')
  newin.document.writeln('      <\/tr>')
  newin.document.writeln('     <\/table>')
  newin.document.writeln('   <!--tool bar ends-->')
  newin.document.writeln('  <\/font>')
  newin.document.writeln(' <\/body>')
  newin.document.writeln('<\/html>')
  newin.document.close()
}

function printseds() {

  var where='ERMiTseds'
  var probval = document.doit.probability0x.value
  var newin = window.open('',where,'width=600,height=480,scrollbars=yes,resizable=yes')

  newin.document.open()
  newin.document.writeln('<HTML>')
  newin.document.writeln(' <head>')
  newin.document.writeln('  <title>ERMiT sediment deliveries<\/title>')
  newin.document.writeln(' <\/HEAD>')
  newin.document.writeln(' <body bgcolor="ivory" onLoad="top.window.focus()">')
  newin.document.writeln('  <font face="tahoma" size=-1> ')
  newin.document.writeln('   <h3>Erosion Risk Management Tool<\/h3>')
  newin.document.writeln('   <h3>Event sediment delivery table<\/h3>')
  newin.document.writeln('   '+js_climate_name+'<br>'+js_soil_texture+'; '+js_rfg+'% rock; '+js_top_slope+'%, '+js_avg_slope+'%,'+js_toe_slope+'% slope; '+js_hillslope_length+' '+ js_units+'; '+js_severityclass_x+' soil burn severity<br>[Run ID '+js_unique+']')
// untreated	document.getElementById("sediment0").innerHTML
  newin.document.writeln('  <h3 align="center">Untreated<\/h3>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.getElementById("sediment0").innerHTML + ' '+js_alt_sedunits + ' in the first year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.getElementById("sediment1").innerHTML + ' '+js_alt_sedunits + ' in the second year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.getElementById("sediment2").innerHTML + ' '+js_alt_sedunits + ' in the third year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.getElementById("sediment3").innerHTML + ' '+js_alt_sedunits + ' in the fourth year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.getElementById("sediment4").innerHTML + ' '+js_alt_sedunits + ' in the fifth year following the fire.<br>')
// seeding
  newin.document.writeln('  <h3 align="center">Seeding<\/h3>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.getElementById("sediment_s0").innerHTML + ' '+js_alt_sedunits + ' in the first year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.getElementById("sediment_s1").innerHTML + ' '+js_alt_sedunits + ' in the second year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.getElementById("sediment_s2").innerHTML + ' '+js_alt_sedunits + ' in the third year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.getElementById("sediment_s3").innerHTML + ' '+js_alt_sedunits + ' in the fourth year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.getElementById("sediment_s4").innerHTML + ' '+js_alt_sedunits + ' in the fifth year following the fire.<br>')
// mulch 47%
  newin.document.writeln('  <h3 align="center">'+mulch1+'<\/h3>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.getElementById("sediment_m470").innerHTML + ' '+js_alt_sedunits + ' in the first year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.getElementById("sediment_m471").innerHTML + ' '+js_alt_sedunits + ' in the second year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.getElementById("sediment_m472").innerHTML + ' '+js_alt_sedunits + ' in the third year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.getElementById("sediment_m473").innerHTML + ' '+js_alt_sedunits + ' in the fourth year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.getElementById("sediment_m474").innerHTML + ' '+js_alt_sedunits + ' in the fifth year following the fire.<br>')
// mulch 72%
  newin.document.writeln('  <h3 align="center">'+mulch2+'<\/h3>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.getElementById("sediment_m720").innerHTML + ' '+js_alt_sedunits + ' in the first year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.getElementById("sediment_m721").innerHTML + ' '+js_alt_sedunits + ' in the second year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.getElementById("sediment_m722").innerHTML + ' '+js_alt_sedunits + ' in the third year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.getElementById("sediment_m723").innerHTML + ' '+js_alt_sedunits + ' in the fourth year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.getElementById("sediment_m724").innerHTML + ' '+js_alt_sedunits + ' in the fifth year following the fire.<br>')
// mulch 89%
  newin.document.writeln('  <h3 align="center">'+mulch3+'<\/h3>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.getElementById("sediment_m890").innerHTML + ' '+js_alt_sedunits + ' in the first year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.getElementById("sediment_m891").innerHTML + ' '+js_alt_sedunits + ' in the second year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.getElementById("sediment_m892").innerHTML + ' '+js_alt_sedunits + ' in the third year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.getElementById("sediment_m893").innerHTML + ' '+js_alt_sedunits + ' in the fourth year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.getElementById("sediment_m894").innerHTML + ' '+js_alt_sedunits + ' in the fifth year following the fire.<br>')
// mulch 94%
  newin.document.writeln('  <h3 align="center">'+mulch4+'<\/h3>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.getElementById("sediment_m940").innerHTML + ' '+js_alt_sedunits + ' in the first year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.getElementById("sediment_m941").innerHTML + ' '+js_alt_sedunits + ' in the second year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.getElementById("sediment_m942").innerHTML + ' '+js_alt_sedunits + ' in the third year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.getElementById("sediment_m943").innerHTML + ' '+js_alt_sedunits + ' in the fourth year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.getElementById("sediment_m944").innerHTML + ' '+js_alt_sedunits + ' in the fifth year following the fire.<br>')
// Contour-felled logs and straw wattles
//  newin.document.write  ('  <h3 align="center">Contour-felled logs and straw wattles ')
//  newin.document.writeln('  ('+diameter+' '+js_units+' dia.; '+spacing+' '+js_units+' apart)</h3>')
//  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.doit.sediment_cl0.value + ' '+js_alt_sedunits + ' in the first year following the fire.<br>')
//  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.doit.sediment_cl1.value + ' '+js_alt_sedunits + ' in the second year following the fire.<br>')
//  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.doit.sediment_cl2.value + ' '+js_alt_sedunits + ' in the third year following the fire.<br>')
//  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.doit.sediment_cl3.value + ' '+js_alt_sedunits + ' in the fourth year following the fire.<br>')
//  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.doit.sediment_cl4.value + ' '+js_alt_sedunits + ' in the fifth year following the fire.<br>')
  newin.document.writeln('   <!--tool bar begins--><p>')
  newin.document.writeln('     <table bgcolor="#666666" width="20%" border="0" cellspacing="1" cellpadding="5" align="center">')
  newin.document.writeln('      <tr>')
  newin.document.writeln('       <td align="center" bgcolor="#dddddd" onMouseOver="this.style.backgroundColor=\'#ffffff\';" onMouseOut="this.style.backgroundColor=\'\';"><font face="verdana,arial,helvetica" size="1"><img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.print()">Print&nbsp;me<\/a><\/font><\/td>')
  newin.document.writeln('       <td align="center" bgcolor="#dddddd" onMouseOver="this.style.backgroundColor=\'#ffffff\';" onMouseOut="this.style.backgroundColor=\'\';"><font face="verdana,arial,helvetica" size="1"><img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.close()">Close&nbsp;me<\/a><\/font><\/td>')
  newin.document.writeln('      <\/tr>')
  newin.document.writeln('     <\/table>')
  newin.document.writeln('   <!--tool bar ends-->')
  newin.document.writeln('  </font>')
  newin.document.writeln(' </body>')
  newin.document.writeln('</html>')
  newin.document.close()
}

function printprobs() {

  var where='ERMiTprobs'
  var sedval = document.doit.sediment0x.value
  var newin = window.open('',where,'width=600,height=480,scrollbars=yes,resizable=yes')

  newin.document.open()
  newin.document.writeln('<HEAD><title>ERMiT probabilities<\/title><\/HEAD>')
  newin.document.writeln(' <body bgcolor="ivory" onLoad="top.window.focus()">')
  newin.document.writeln('  <font face="tahoma"> ')
  newin.document.writeln('   <h2>Erosion Risk Management Tool<br>event probability table</h2>')
  newin.document.writeln(js_climate_name+'<br>'+js_soil_texture+'; '+js_rfg+'% rock;'+js_top_slope+' %, '+js_avg_slope+' %,'+js_toe_slope+' % slope; '+js_hillslope_length+' '+ js_units+'; '+js_severityclass_x+' severity fire<br>['+js_unique+']')
  newin.document.writeln('  <h3 align="center">Untreated<\/h3>')
// untreated
//  newin.document.writeln('   There is a ' + document.doit.probability0.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the first year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.getElementById("probability0").innerHTML+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the first year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.getElementById("probability1").innerHTML+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the second year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.getElementById("probability2").innerHTML+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the third year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.getElementById("probability3").innerHTML+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the fourth year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.getElementById("probability4").innerHTML+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the fifth year following the fire.<br>')
// seeding
  newin.document.writeln('  <h3 align="center">Seeding<\/h3>')
//  newin.document.writeln('   There is a ' + document.doit.probability_s0.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the first year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.getElementById("probability_s0").innerHTML+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the first year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.getElementById("probability_s1").innerHTML+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the second year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.getElementById("probability_s2").innerHTML+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the third year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.getElementById("probability_s3").innerHTML+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the fourth year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.getElementById("probability_s4").innerHTML+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the fifth year following the fire.<br>')
// mulch 47%
  newin.document.writeln('  <h3 align="center">'+mulch1+'<\/h3>')
  newin.document.writeln('   There is a ' + document.getElementById("sediment_m470").innerHTML+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the first year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.getElementById("sediment_m471").innerHTML+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the second year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.getElementById("sediment_m472").innerHTML+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the third year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.getElementById("sediment_m473").innerHTML+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the fourth year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.getElementById("sediment_m474").innerHTML+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the fifth year following the fire.<br>')
// mulch 72%
  newin.document.writeln('  <h3 align="center">'+mulch2+'<\/h3>')
  newin.document.writeln('   There is a ' + document.getElementById("sediment_m720").innerHTML+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the first year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.getElementById("sediment_m721").innerHTML+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the second year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.getElementById("sediment_m722").innerHTML+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the third year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.getElementById("sediment_m723").innerHTML+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the fourth year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.getElementById("sediment_m724").innerHTML+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the fifth year following the fire.<br>')
// mulch 89%
  newin.document.writeln('  <h3 align="center">'+mulch3+'<\/h3>')
  newin.document.writeln('   There is a ' + document.getElementById("sediment_m940").innerHTML+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the first year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.getElementById("sediment_m891").innerHTML+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the second year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.getElementById("sediment_m892").innerHTML+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the third year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.getElementById("sediment_m893").innerHTML+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the fourth year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.getElementById("sediment_m894").innerHTML+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the fifth year following the fire.<br>')
// mulch 94%
  newin.document.writeln('  <h3 align="center">'+mulch4+'<\/h3>')
  newin.document.writeln('   There is a ' + document.getElementById("sediment_m940").innerHTML+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the first year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.getElementById("sediment_m941").innerHTML+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the second year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.getElementById("sediment_m942").innerHTML+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the third year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.getElementById("sediment_m943").innerHTML+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the fourth year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.getElementById("sediment_m944").innerHTML+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the fifth year following the fire.<br>')
// Contour-felled logs and straw wattles
//  newin.document.write  ('  <h3 align="center">Contour-felled logs and straw wattles ')
//  newin.document.writeln('  ('+diameter+' '+js_units+' dia.; '+spacing+' '+js_units+' apart)</h3>')
//  newin.document.writeln('   There is a ' + document.doit.probability_cl0.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the first year following the fire.<br>')
//  newin.document.writeln('   There is a ' + document.doit.probability_cl1.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the second year following the fire.<br>')
//  newin.document.writeln('   There is a ' + document.doit.probability_cl2.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the third year following the fire.<br>')
//  newin.document.writeln('   There is a ' + document.doit.probability_cl3.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the fourth year following the fire.<br>')
//  newin.document.writeln('   There is a ' + document.doit.probability_cl4.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the fifth year following the fire.<br>')
  newin.document.writeln('   <!--tool bar begins--><p>')
  newin.document.writeln('     <table bgcolor="#666666" width="20%" border="0" cellspacing="1" cellpadding="5" align="center">')
  newin.document.writeln('      <tr>')
  newin.document.writeln('       <td align="center" bgcolor="#dddddd" onMouseOver="this.style.backgroundColor=\'#ffffff\';" onMouseOut="this.style.backgroundColor=\'\';"><font face="verdana,arial,helvetica" size="1"><img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.print()">Print&nbsp;me<\/a><\/font><\/td>')
  newin.document.writeln('       <td align="center" bgcolor="#dddddd" onMouseOver="this.style.backgroundColor=\'#ffffff\';" onMouseOut="this.style.backgroundColor=\'\';"><font face="verdana,arial,helvetica" size="1"><img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.close()">Close&nbsp;me<\/a><\/font><\/td>')
  newin.document.writeln('      <\/tr>')
  newin.document.writeln('     <\/table>')
  newin.document.writeln('   <!--tool bar ends-->')
  newin.document.writeln('  <\/font>')
  newin.document.writeln(' <\/body>')
  newin.document.writeln('</html>')
  newin.document.close()
}

</script>
EOP

## sub probtable



}

sub isNumber{

# "Selector, Lev Y" <Lev.Selector@gs.com>
# for (  qw[ 0 abcdefg 1  -1.0  1.0e-10  10abc ]  ) {
#   print "$_ -> ", isNumber($_), "\n";
# }
# 0 -> 1
# abcdefg ->
# 1 -> 1
# -1.0 -> 1
# 1.0e-10 -> 1
# 10abc ->

     $_[0] =~ /^(?=[-+.]*\d)[-+]?\d*\.?\d*(?:e[-+ ]?\d+)?$/i
}

sub createsoilfile {                                                   

# return soil file for ERMiT given                                     
#   soil texture designation (sand, silt, clay, loam)                  
#   spatial representation (lll, llh, lhl, lhh, hll, hlh, hhl, hhh)    
#   conductivity ranking for ki, kr, ksat/aveke (0..4)                 
#   percent rock fragments (rfg)                                       

# USDA FS RMRS Moscow FSL coding by david numbers by bill & corey

  $ver = '2002.11.27';                                                          

# reads:                                                                        
  # $s -- severity code ('hhh' .. 'lll')                                        
  # $k -- kr/ksat counter (0..4)                                                
  # $SoilType -- soil type                                                      
  # $soil_texture -- soil texture                                               
  # $rfg -- percentage of rock fragments (by volume) in the layer (%)           
  # $vegtype
  # $shrub, $grass, $bare
# returns:                                                                      
  # Soil file                                                                   
# calls
  # soil_parameters

#  $SoilType = 'silt';                                                          
#  $s = 'lll';                                                                  
#  $k = 4;                                                                      
#  $rfg = 20;      # percentage of rock fragments (by volume) in the layer (%)

  if ($SoilType ne 'sand' && $SoilType ne 'silt' &&                            
      $SoilType ne 'clay' && $SoilType ne 'loam') {return}

  my $string = lc($s);                                                         

  if ($string eq 'lll' || $string eq 'hhh') { $nofe = 1 }                      
  if ($string eq 'llh' || $string eq 'hhl') { $nofe = 2 }                      
  if ($string eq 'lhl' || $string eq 'hlh') { $nofe = 3 }                      
  if ($string eq 'lhh' || $string eq 'hll') { $nofe = 2 }                      

  $ksflag = 0;  # hold internal hydraulic conductivity constant (0 => do not adjust internally)
  $nsl = 1;     # number of soil layers for the current OFE                    
  $salb = 0.2;  # albedo of the bare dry surface soil on the current OFE       
  $sat = 0.75;  # initial saturation level of the soil profile porosity (m/m)  

# goto skip;
# skip:

  &soil_parameters;

  @l[0] = @ki_l[0] . "\t" . @kr_l[0] . "\t" . $tauc_l . "\t" . @ksat_l[0];
  @l[1] = @ki_l[1] . "\t" . @kr_l[1] . "\t" . $tauc_l . "\t" . @ksat_l[1];
  @l[2] = @ki_l[2] . "\t" . @kr_l[2] . "\t" . $tauc_l . "\t" . @ksat_l[2];
  @l[3] = @ki_l[3] . "\t" . @kr_l[3] . "\t" . $tauc_l . "\t" . @ksat_l[3];
  @l[4] = @ki_l[4] . "\t" . @kr_l[4] . "\t" . $tauc_l . "\t" . @ksat_l[4];
  @h[0] = @ki_h[0] . "\t" . @kr_h[0] . "\t" . $tauc_h . "\t" . @ksat_h[0];
  @h[1] = @ki_h[1] . "\t" . @kr_h[1] . "\t" . $tauc_h . "\t" . @ksat_h[1];
  @h[2] = @ki_h[2] . "\t" . @kr_h[2] . "\t" . $tauc_h . "\t" . @ksat_h[2];
  @h[3] = @ki_h[3] . "\t" . @kr_h[3] . "\t" . $tauc_h . "\t" . @ksat_h[3];
  @h[4] = @ki_h[4] . "\t" . @kr_h[4] . "\t" . $tauc_h . "\t" . @ksat_h[4];

  $results="95.1
#  WEPP '$soil_texture' '$s$k' $vegtype soil input file for ERMiT";
  if ($vegtype eq 'forest') {}
  else {$results .= "\n#  $shrub% shrub $grass% grass $bare% bare"}
  $results .= "
#  Data from RMRS Soil and Water Engineering Project, Moscow FSL
#  Created by 'createsoilfile' version $ver
$nofe\t0
";

  $that_severity = '';
  for $i (0..2) {
    $this_severity = substr($string,$i,1);
    $sev = $this_severity;
    if ($this_severity ne $that_severity) {
      if ($this_severity eq 'l') {
        $KiKrShcritAvke = @l[$k]
      }
      else {
        $KiKrShcritAvke = @h[$k]
      }
      $results .= "'ERMiT_$sev$k'\t'$soil_texture'\t$nsl\t$salb\t$sat\t" . $KiKrShcritAvke;
      $results .= "\n$solthk\t$sand\t$clay\t$orgmat\t$cec\t$rfg\n";
      $that_severity = $this_severity;
    }
  }
  return $results;
}                                                                              

sub soil_parameters {

 # $vegtype ['forest' 'range' 'chaparral']
 # $SoilType ['sand' 'silt' 'clay' 'loam']
 # $shrub
 # $grass
 # $bare

 # @ki_l[0..4]
 # @ki_h[0..4]
 # @kr_l[0..4]
 # @kr_h[0..4]
 # $tauc_l
 # $tauc_h
 # @ksat_l[0..4]
 # @ksat_h[0..4]

  if ($vegtype eq 'forest') {
    $ksatfact=1;
    $ksatfact=0.59 if ($new_cligen);
    if ($SoilType eq 'sand') {
      $solthk = 400;      # depth of soil surface to bottom of soil layer (mm)
      $sand = 55;         # percentage of sand in the layer (%)               
      $clay = 10;         # percentage of clay in the layer (%)               
      $orgmat = 5;        # percentage of organic matter (by volume) in the layer (%)
      $cec = 15;          # cation exchange capacity in the layer (meq per 100 g of soil)
      $tauc_l=2;
      $tauc_h=2;
      @ki_l[0] =  300000; @kr_l[0] = 0.0000030; @ksat_l[0] = 48*$ksatfact;	# 2005.10.12 DEH
      @ki_l[1] =  500000; @kr_l[1] = 0.00034; @ksat_l[1] = 46*$ksatfact;
      @ki_l[2] =  700000; @kr_l[2] = 0.00037; @ksat_l[2] = 44*$ksatfact;
      @ki_l[3] = 1000000; @kr_l[3] = 0.00040; @ksat_l[3] = 24*$ksatfact;
      @ki_l[4] = 1200000; @kr_l[4] = 0.00045; @ksat_l[4] = 14*$ksatfact;
      @ki_h[0] = 1000000; @kr_h[0] = 0.00040; @ksat_h[0] = 22*$ksatfact;
      @ki_h[1] = 1500000; @kr_h[1] = 0.00050; @ksat_h[1] = 13*$ksatfact;
      @ki_h[2] = 2000000; @kr_h[2] = 0.00060; @ksat_h[2] =  7*$ksatfact;
      @ki_h[3] = 2500000; @kr_h[3] = 0.00070; @ksat_h[3] =  6*$ksatfact;
      @ki_h[4] = 3000000; @kr_h[4] = 0.00100; @ksat_h[4] =  5*$ksatfact;
    }
    if ($SoilType eq 'silt') {
      $solthk = 400;
      $sand = 25;
      $clay = 15;
      $orgmat = 5;
      $cec = 15;
      $tauc_l = 3.5;
      $tauc_h = 3.5;
      @ki_l[0] =  250000; @kr_l[0] = 0.0000020; @ksat_l[0] = 33*$ksatfact;      # 2005.10.12 DEH
      @ki_l[1] =  300000; @kr_l[1] = 0.00024; @ksat_l[1] = 31*$ksatfact;
      @ki_l[2] =  400000; @kr_l[2] = 0.00027; @ksat_l[2] = 29*$ksatfact; 
      @ki_l[3] =  500000; @kr_l[3] = 0.00030; @ksat_l[3] = 19*$ksatfact;
      @ki_l[4] =  600000; @kr_l[4] = 0.00035; @ksat_l[4] =  9*$ksatfact;
      @ki_h[0] =  500000; @kr_h[0] = 0.00030; @ksat_h[0] = 18*$ksatfact;
      @ki_h[1] = 1000000; @kr_h[1] = 0.00040; @ksat_h[1] = 10*$ksatfact;
      @ki_h[2] = 1500000; @kr_h[2] = 0.00050; @ksat_h[2] =  6*$ksatfact;
      @ki_h[3] = 2000000; @kr_h[3] = 0.00060; @ksat_h[3] =  4*$ksatfact;
      @ki_h[4] = 2500000; @kr_h[4] = 0.00090; @ksat_h[4] =  3*$ksatfact;
    }
    if ($SoilType eq 'clay') {
      $solthk = 400;
      $sand = 25;
      $clay = 30;
      $orgmat = 5;
      $cec = 25;
      $tauc_l = 4;
      $tauc_h = 4;
      @ki_l[0] =  200000; @kr_l[0] = 0.0000010; @ksat_l[0] = 25*$ksatfact;      # 2005.10.12 DEH
      @ki_l[1] =  250000; @kr_l[1] = 0.00014; @ksat_l[1] = 24*$ksatfact;
      @ki_l[2] =  300000; @kr_l[2] = 0.00017; @ksat_l[2] = 23*$ksatfact;
      @ki_l[3] =  400000; @kr_l[3] = 0.00020; @ksat_l[3] = 14*$ksatfact;
      @ki_l[4] =  500000; @kr_l[4] = 0.00025; @ksat_l[4] =  8*$ksatfact;
      @ki_h[0] =  400000; @kr_h[0] = 0.00020; @ksat_h[0] = 13*$ksatfact;
      @ki_h[1] =  700000; @kr_h[1] = 0.00030; @ksat_h[1] =  7*$ksatfact;
      @ki_h[2] = 1000000; @kr_h[2] = 0.00040; @ksat_h[2] =  4*$ksatfact;
      @ki_h[3] = 1500000; @kr_h[3] = 0.00050; @ksat_h[3] =  3*$ksatfact;
      @ki_h[4] = 2000000; @kr_h[4] = 0.00080; @ksat_h[4] =  2*$ksatfact;
    }
    if ($SoilType eq 'loam') {
      $solthk = 400;
      $sand = 45;
      $clay = 20;
      $orgmat = 5;
      $cec = 20;
      $tauc_l = 3;
      $tauc_h = 3;
      @ki_l[0] =  320000; @kr_l[0] = 0.0000015; @ksat_l[0] = 40*$ksatfact;      # 2005.10.12 DEH
      @ki_l[1] =  370000; @kr_l[1] = 0.00019; @ksat_l[1] = 38*$ksatfact;
      @ki_l[2] =  470000; @kr_l[2] = 0.00022; @ksat_l[2] = 36*$ksatfact;
      @ki_l[3] =  600000; @kr_l[3] = 0.00025; @ksat_l[3] = 28*$ksatfact;
      @ki_l[4] =  800000; @kr_l[4] = 0.00030; @ksat_l[4] = 18*$ksatfact;
      @ki_h[0] =  600000; @kr_h[0] = 0.00025; @ksat_h[0] = 27*$ksatfact;
      @ki_h[1] =  800000; @kr_h[1] = 0.00035; @ksat_h[1] = 15*$ksatfact;
      @ki_h[2] = 1200000; @kr_h[2] = 0.00055; @ksat_h[2] =  8*$ksatfact;
      @ki_h[3] = 2200000; @kr_h[3] = 0.00065; @ksat_h[3] =  5*$ksatfact;
      @ki_h[4] = 3200000; @kr_h[4] = 0.00085; @ksat_h[4] =  4*$ksatfact;
    }

    # return
    #   $tauc_l
    #   $tauc_h
    #   @ki_l[0..4]
    #   @ki_h[0..4]
    #   @kr_l[0..4]
    #   @kr_h[0..4]
    #   @ksat_l[0..4]
    #   @ksat_h[0..4]

  }
  else {   # $vegtype ne 'forest'...  # soil parameter values from Corey Moffett 19 Oct 2005
    if ($SoilType eq 'sand') {
      $solthk = 400;      # depth of soil surface to bottom of soil layer (mm)
      $sand = 55;         # percentage of sand in the layer (%)
      $clay = 10;         # percentage of clay in the layer (%)
      $orgmat = 5;        # percentage of organic matter (by volume) in the layer (%)
      $cec = 15;          # cation exchange capacity in the layer (meq per 100 g of soil)
      $tauc_l=15.35;      $tauc_h=7.53;
#     if ($rtc) {$tauc_l=2; $tauc_h=2}
      @ki_shrub_l[0] = 7.548E+4; @ki_grass_l[0] = 5.016E+4; @ki_bare_l[0] = 1.745E+5; @kr_l[0] = 1.984E-6; #!
      @ki_shrub_l[1] = 1.191E+5; @ki_grass_l[1] = 1.174E+5; @ki_bare_l[1] = 2.518E+5; @kr_l[1] = 4.308E-6;
      @ki_shrub_l[2] = 2.480E+5; @ki_grass_l[2] = 2.372E+5; @ki_bare_l[2] = 5.520E+5; @kr_l[2] = 9.015E-6;
      @ki_shrub_l[3] = 4.093E+5; @ki_grass_l[3] = 3.921E+5; @ki_bare_l[3] = 2.187E+6; @kr_l[3] = 1.664E-5;
      @ki_shrub_l[4] = 9.313E+5; @ki_grass_l[4] = 6.513E+5; @ki_bare_l[4] = 3.608E+6; @kr_l[4] = 9.341E-5;
      @ki_shrub_h[0] = 2.334E+5; @ki_grass_h[0] = 1.745E+5; @ki_bare_h[0] = 1.745E+5; @kr_h[0] = 6.188E-4;
      @ki_shrub_h[1] = 2.536E+5; @ki_grass_h[1] = 2.518E+5; @ki_bare_h[1] = 2.518E+5; @kr_h[1] = 9.573E-4;
      @ki_shrub_h[2] = 4.630E+5; @ki_grass_h[2] = 5.520E+5; @ki_bare_h[2] = 5.520E+5; @kr_h[2] = 1.450E-3;
      @ki_shrub_h[3] = 6.868E+5; @ki_grass_h[3] = 2.187E+6; @ki_bare_h[3] = 2.187E+6; @kr_h[3] = 2.048E-3;
      @ki_shrub_h[4] = 8.915E+5; @ki_grass_h[4] = 3.608E+6; @ki_bare_h[4] = 3.608E+6; @kr_h[4] = 5.405E-3;
      @ks_shrub_l[0] = 29; @ks_grass_l[0] = 17; @ks_bare_l[0] = 14;
      @ks_shrub_l[1] = 17; @ks_grass_l[1] = 17; @ks_bare_l[1] = 14;
      @ks_shrub_l[2] = 15; @ks_grass_l[2] = 13; @ks_bare_l[2] = 11;
      @ks_shrub_l[3] = 12; @ks_grass_l[3] = 12; @ks_bare_l[3] = 10;
      @ks_shrub_l[4] =  9; @ks_grass_l[4] =  8; @ks_bare_l[4] =  7;
      @ks_shrub_h[0] = 21; @ks_grass_h[0] = 14; @ks_bare_h[0] = 14;
      @ks_shrub_h[1] = 12; @ks_grass_h[1] = 14; @ks_bare_h[1] = 14;
      @ks_shrub_h[2] = 11; @ks_grass_h[2] = 11; @ks_bare_h[2] = 11;
      @ks_shrub_h[3] =  9; @ks_grass_h[3] = 10; @ks_bare_h[3] = 10;
      @ks_shrub_h[4] =  6; @ks_grass_h[4] =  7; @ks_bare_h[4] =  7;
    }
    if ($SoilType eq 'silt') {
      $solthk = 400;
      $sand = 25;
      $clay = 15;
      $orgmat = 5;
      $cec = 15;
      $tauc_l=15.35;      $tauc_h=7.53;
#      $tauc_l=36.58;      $tauc_h=17.93;
#      if ($rtc) {$tauc_l=3.5; $tauc_h=3.5}
      @ki_shrub_l[0] = 1.852E+4; @ki_grass_l[0] = 1.150E+4; @ki_bare_l[0] = 3.998E+4; @kr_l[0] = 1.105E-5;
      @ki_shrub_l[1] = 3.435E+4; @ki_grass_l[1] = 2.070E+4; @ki_bare_l[1] = 4.439E+4; @kr_l[1] = 1.851E-5;
      @ki_shrub_l[2] = 9.697E+4; @ki_grass_l[2] = 5.556E+4; @ki_bare_l[2] = 1.293E+5; @kr_l[2] = 3.241E-5;
      @ki_shrub_l[3] = 1.713E+5; @ki_grass_l[3] = 9.548E+4; @ki_bare_l[3] = 5.326E+5; @kr_l[3] = 6.346E-5;
      @ki_shrub_l[4] = 2.794E+5; @ki_grass_l[4] = 1.521E+5; @ki_bare_l[4] = 8.425E+5; @kr_l[4] = 1.290E-4;
      @ki_shrub_h[0] = 5.725E+4; @ki_grass_h[0] = 3.998E+4; @ki_bare_h[0] = 3.998E+4; @kr_h[0] = 1.627E-3;
      @ki_shrub_h[1] = 7.316E+4; @ki_grass_h[1] = 4.439E+4; @ki_bare_h[1] = 4.439E+4; @kr_h[1] = 2.174E-3;
      @ki_shrub_h[2] = 1.811E+5; @ki_grass_h[2] = 1.293E+5; @ki_bare_h[2] = 1.293E+5; @kr_h[2] = 2.979E-3;
      @ki_shrub_h[3] = 2.675E+5; @ki_grass_h[3] = 5.326E+5; @ki_bare_h[3] = 5.326E+5; @kr_h[3] = 4.349E-3; #!
      @ki_shrub_h[4] = 2.675E+5; @ki_grass_h[4] = 8.425E+5; @ki_bare_h[4] = 8.425E+5; @kr_h[4] = 6.483E-3;
      @ks_shrub_l[0] = 22; @ks_grass_l[0] = 26; @ks_bare_l[0] = 21;
      @ks_shrub_l[1] = 18; @ks_grass_l[1] = 20; @ks_bare_l[1] = 16;
      @ks_shrub_l[2] = 13; @ks_grass_l[2] = 15; @ks_bare_l[2] = 12;
      @ks_shrub_l[3] = 11; @ks_grass_l[3] = 13; @ks_bare_l[3] = 10;
      @ks_shrub_l[4] =  8; @ks_grass_l[4] = 10; @ks_bare_l[4] =  8;
      @ks_shrub_h[0] = 16; @ks_grass_h[0] = 21; @ks_bare_h[0] = 21;
      @ks_shrub_h[1] = 12; @ks_grass_h[1] = 16; @ks_bare_h[1] = 16;
      @ks_shrub_h[2] =  9; @ks_grass_h[2] = 12; @ks_bare_h[2] = 12;
      @ks_shrub_h[3] =  8; @ks_grass_h[3] = 10; @ks_bare_h[3] = 10;
      @ks_shrub_h[4] =  6; @ks_grass_h[4] =  8; @ks_bare_h[4] =  8;
    }
    if ($SoilType eq 'clay') {
      $solthk = 400;
      $sand = 25;
      $clay = 30;
      $orgmat = 5;
      $cec = 25;
      $tauc_l=15.35;      $tauc_h=7.53;
#      $tauc_l = 75.56;      $tauc_h = 37.04;
#      if ($rtc) {$tauc_l=4; $tauc_h=4}
      @ki_shrub_l[0] = 5.358E+4; @ki_grass_l[0] = 1.908E+3; @ki_bare_l[0] = 6.636E+3; @kr_l[0] = 9.041E-6;
      @ki_shrub_l[1] = 1.063E+5; @ki_grass_l[1] = 3.069E+3; @ki_bare_l[1] = 6.636E+3; @kr_l[1] = 1.217E-5; #!
      @ki_shrub_l[2] = 3.357E+5; @ki_grass_l[2] = 6.814E+3; @ki_bare_l[2] = 1.586E+4; @kr_l[2] = 1.843E-5;
      @ki_shrub_l[3] = 6.306E+5; @ki_grass_l[3] = 1.055E+4; @ki_bare_l[3] = 5.886E+4; @kr_l[3] = 5.044E-5;
      @ki_shrub_l[4] = 1.085E+6; @ki_grass_l[4] = 1.537E+4; @ki_bare_l[4] = 8.516E+4; @kr_l[4] = 6.645E-5;
      @ki_shrub_h[0] = 1.657E+5; @ki_grass_h[0] = 6.636E+3; @ki_bare_h[0] = 6.636E+3; @kr_h[0] = 1.453E-3;
      @ki_shrub_h[1] = 2.263E+5; @ki_grass_h[1] = 6.636E+3; @ki_bare_h[1] = 6.636E+3; @kr_h[1] = 1.717E-3; #!
      @ki_shrub_h[2] = 6.267E+5; @ki_grass_h[2] = 1.586E+4; @ki_bare_h[2] = 1.586E+4; @kr_h[2] = 2.169E-3;
      @ki_shrub_h[3] = 1.038E+6; @ki_grass_h[3] = 5.886E+4; @ki_bare_h[3] = 5.886E+4; @kr_h[3] = 3.822E-3; #!
      @ki_shrub_h[4] = 1.038E+6; @ki_grass_h[4] = 8.516E+4; @ki_bare_h[4] = 8.516E+4; @kr_h[4] = 4.463E-3;
      @ks_shrub_l[0] = 15; @ks_grass_l[0] = 13; @ks_bare_l[0] = 10;
      @ks_shrub_l[1] = 13; @ks_grass_l[1] = 11; @ks_bare_l[1] =  9;
      @ks_shrub_l[2] = 10; @ks_grass_l[2] =  9; @ks_bare_l[2] =  7;
      @ks_shrub_l[3] =  8; @ks_grass_l[3] =  6; @ks_bare_l[3] =  5;
      @ks_shrub_l[4] =  6; @ks_grass_l[4] =  5; @ks_bare_l[4] =  4;
      @ks_shrub_h[0] = 11; @ks_grass_h[0] = 10; @ks_bare_h[0] = 10;
      @ks_shrub_h[1] =  9; @ks_grass_h[1] =  9; @ks_bare_h[1] =  9;
      @ks_shrub_h[2] =  7; @ks_grass_h[2] =  7; @ks_bare_h[2] =  7;
      @ks_shrub_h[3] =  5; @ks_grass_h[3] =  5; @ks_bare_h[3] =  5;
      @ks_shrub_h[4] =  5; @ks_grass_h[4] =  4; @ks_bare_h[4] =  4;
    }
    if ($SoilType eq 'loam') {
      $solthk = 400;
      $sand = 45;
      $clay = 20;
      $orgmat = 5;
      $cec = 20;
      $tauc_l=15.35;      $tauc_h=7.53;
#      $tauc_l = 14.38;      $tauc_h = 7.05;
#      if ($rtc) {$tauc_l=3; $tauc_h=3}
      @ki_shrub_l[0] = 3.884E+3; @ki_grass_l[0] = 2.601E+3; @ki_bare_l[0] = 9.047E+3; @kr_l[0] = 1.587E-5;
      @ki_shrub_l[1] = 7.113E+3; @ki_grass_l[1] = 4.626E+3; @ki_bare_l[1] = 9.922E+3; @kr_l[1] = 2.738E-5;
      @ki_shrub_l[2] = 4.349E+4; @ki_grass_l[2] = 2.590E+4; @ki_bare_l[2] = 6.028E+4; @kr_l[2] = 5.001E-5;
      @ki_shrub_l[3] = 9.353E+4; @ki_grass_l[3] = 5.368E+4; @ki_bare_l[3] = 2.994E+5; @kr_l[3] = 8.144E-5;
      @ki_shrub_l[4] = 1.107E+5; @ki_grass_l[4] = 6.302E+4; @ki_bare_l[4] = 3.491E+5; @kr_l[4] = 1.020E-4;
      @ki_shrub_h[0] = 1.201E+4; @ki_grass_h[0] = 9.047E+3; @ki_bare_h[0] = 9.047E+3; @kr_h[0] = 1.994E-3;
      @ki_shrub_h[1] = 1.515E+4; @ki_grass_h[1] = 9.922E+3; @ki_bare_h[1] = 9.922E+3; @kr_h[1] = 2.710E-3;
      @ki_shrub_h[2] = 8.120E+4; @ki_grass_h[2] = 6.028E+4; @ki_bare_h[2] = 6.028E+4; @kr_h[2] = 3.803E-3;
      @ki_shrub_h[3] = 1.060E+5; @ki_grass_h[3] = 2.994E+5; @ki_bare_h[3] = 2.944E+5; @kr_h[3] = 5.004E-3; #!
      @ki_shrub_h[4] = 1.060E+5; @ki_grass_h[4] = 3.491E+5; @ki_bare_h[4] = 3.491E+5; @kr_h[4] = 5.680E-3;
      @ks_shrub_l[0] = 22; @ks_grass_l[0] = 15; @ks_bare_l[0] = 12;
      @ks_shrub_l[1] = 18; @ks_grass_l[1] = 13; @ks_bare_l[1] = 10;
      @ks_shrub_l[2] = 13; @ks_grass_l[2] =  6; @ks_bare_l[2] =  5;
      @ks_shrub_l[3] = 11; @ks_grass_l[3] =  6; @ks_bare_l[3] =  5;
      @ks_shrub_l[4] =  8; @ks_grass_l[4] =  5; @ks_bare_l[4] =  4;
      @ks_shrub_h[0] = 16; @ks_grass_h[0] = 12; @ks_bare_h[0] = 12;
      @ks_shrub_h[1] = 12; @ks_grass_h[1] = 10; @ks_bare_h[1] = 10;
      @ks_shrub_h[2] =  9; @ks_grass_h[2] =  5; @ks_bare_h[2] =  5;
      @ks_shrub_h[3] =  8; @ks_grass_h[3] =  5; @ks_bare_h[3] =  5;
      @ks_shrub_h[4] =  6; @ks_grass_h[4] =  4; @ks_bare_h[4] =  4;
    }  # #SoilType
    # return 
    #   $tauc_l
    #   $tauc_h
    #   @ki_l[0..4]
    #   @ki_h[0..4]
    #   @kr_l[0..4]
    #   @kr_h[0..4]
    #   @ksat_l[0..4]
    #   @ksat_h[0..4]

    $pshrub = $shrub / 100;
    $pgrass = $grass / 100;
    $pbare = $bare / 100;

    for ($i=0; $i<5; $i++) {
      @ki_l[$i]   = $pshrub * @ki_shrub_l[$i] + $pgrass * @ki_grass_l[$i] + $pbare * @ki_bare_l[$i];
      @ki_h[$i]   = $pshrub * @ki_shrub_h[$i] + $pgrass * @ki_grass_h[$i] + $pbare * @ki_bare_h[$i];
      @kr_l[$i]   = $pshrub * @kr_l[$i] + $pgrass * @kr_l[$i] + $pbare * @kr_l[$i];
      @kr_h[$i]   = $pshrub * @kr_h[$i] + $pgrass * @kr_h[$i] + $pbare * @kr_h[$i];
      @ksat_l[$i] = $pshrub * @ks_shrub_l[$i] + $pgrass * @ks_grass_l[$i] + $pbare * @ks_bare_l[$i];
      @ksat_h[$i] = $pshrub * @ks_shrub_h[$i] + $pgrass * @ks_grass_h[$i] + $pbare * @ks_bare_h[$i];
    }
#    $, = '  ';
#    print 'Ki_l ', @ki_l,"\n";
#    print 'Kr_l ', @kr_l,"\n";
#    print 'Ksat_l ', @ksat_l,"\n";

  }     # $vegtype
}

sub createGnuplotJCLfile { # #######################  createGnuplotJCLfile

# mod 2004.08.18 DEH for gnuplot 4.0.0 capabilities

# $gnuplotdatafile
# $gnuplotgrapheps
# $sed_units
# $soil_texture
# $rfg
# $top_slope
# $avg_slope
# $toe_slope
# $hillslope_length
# $units
# $severityclass_x
# climate_name - climate station name
# {calculate location for climate station name}

# $result="set term png color
#set output '$gnuplotgraph'
#set title 'Sediment Delivery Exceedance Probability for untreated $climate_name' font 'sans serif,20'
#set xlabel 'Sediment Delivery ($alt_sedunits)' font 'sans serif,12'
#set ylabel 'Probability (%)' font 'sans serif,12'
#set noautoscale y
#set yrange [0:100]
#set key bottom
#set timestamp \"%m-%d-%Y -- $soil_texture; $rfg%% rock; $top_slope%%, $avg_slope%%, $toe_slope%% slope; $hillslope_length $units; $severityclass_x soil burn severity\"
#plot [] [1:] \\
#     '$gnuplotdatafile' using 1:2 t '1st year' with lines linewidth 5,\\
#     ''         using 1:3 t '2nd year' with lines linewidth 5,\\
#     ''         using 1:4 t '3rd year' with lines linewidth 15,\\
#     ''         using 1:5 t '4th year' with lines linewidth 5,\\
#     ''         using 1:6 t '5th year' with lines lt 12 linewidth 5
#";

# 'size 800,600' and 'enhanced' work from command-line but not
# when called from within the perl program ............
#  $result="set terminal png size 800,600 enhanced

#  $result="set terminal png
  $result="set terminal postscript color
set output '$gnuplotgrapheps'
set title 'Sediment Delivery Exceedance Probability for untreated $climate_name'
set xlabel 'Sediment Delivery ($alt_sedunits)'
set ylabel 'Probability (%)'
set noautoscale y
set yrange [0:100]
set key top
set timestamp \"%m-%d-%Y -- $soil_texture; $rfg%% rock; $top_slope%%, $avg_slope%%, $toe_slope%% slope; $hillslope_length $units; $severityclass_x soil burn severity [$unique]\"
plot [] [1:] \\
     '$gnuplotdatafile' using 1:2 t '1st year' with lines linewidth 5,\\
     ''         using 1:3 t '2nd year' with lines linewidth 5,\\
     ''         using 1:4 t '3rd year' with lines linewidth 15,\\
     ''         using 1:5 t '4th year' with lines linewidth 5,\\
     ''         using 1:6 t '5th year' with lines lt 12 linewidth 5
";

#plot [] [1:] \\
#     '$gnuplotdatafile' using 1:2 smooth bezier t '1st year' linewidth 5,\\
#     ''         using 1:3 sm b t '2nd year' linewidth 5,\\
#     ''         using 1:4 sm b t '3rd year' linewidth 5,\\
#     ''         using 1:5 sm b t '4th year' linewidth 5,\\
#     ''         using 1:6 sm b t '5th year' linewidth 5
#";
}

sub createGnuplotDatafile {	# ##################  createGnuplotDatafile

#  create data file of sed_delivery vs cumulate probs (5 years) no mitigation

# $units - 
# @probabilities0[]
# @probabilities1[]
# @probabilities2[]
# @probabilities3[]
# @probabilities4[]
# @sed_yields[]
# @index[]
# $climate_name - climate station name
# $soil_texture
# $rfg% - rock fragment
# $top_slope% - top gradient
# $avg_slope% - average gradient
# $toe_slope% - toe gradient
# $hillslope_length_m - hillslope horizontal length (m)
# $severityclass_x - fire severity class ('low', 'moderate', 'high')

# $result - data file

# my $sedu, $cp0r, $cp1r, $cp2r, $cp3r, $cp4r, $result, $seddelunits;

  if ($units eq 'm') {$unit_conv=$hillslope_length_m / 10}  # (x / 100) * 10 = x / (100 / 10)
  else {$unit_conv = $hillslope_length_m / 4.45}
  $result = "# gnuplot  data file of sed_delivery vs cumulate probs (5 years) no mit
# $climate_name
# Sediment Delivery Exceedance Probability
# Sediment Delivery ($alt_sedunits)
# Probability (%)
# $soil_texture; $rfg% rock; $top_slope%, $avg_slope%, $toe_slope% slope; $hillslope_length $units; $severityclass_x fire severity
";
  $cum_prob0 = 0.01;
  $cum_prob1 = 0.01;
  $cum_prob2 = 0.01;
  $cum_prob3 = 0.01;
  $cum_prob4 = 0.01;
  for $i (0..$#sed_yields) {				# 2005.09.30 DEH test 2005.10.21
    $cum_prob0 += @probabilities0[@index[$i]];
    $cum_prob1 += @probabilities1[@index[$i]];
    $cum_prob2 += @probabilities2[@index[$i]];
    $cum_prob3 += @probabilities3[@index[$i]];
    $cum_prob4 += @probabilities4[@index[$i]];
    $sedval = @sed_yields[@index[$i]];
    if ($sedval eq '') {$sedval = '0.0'}
    $cp0r = sprintf '%9.2g', $cum_prob0* 100;
    $cp1r = sprintf '%9.2g', $cum_prob1* 100;
    $cp2r = sprintf '%9.2g', $cum_prob2* 100;
    $cp3r = sprintf '%9.2g', $cum_prob3* 100;
    $cp4r = sprintf '%9.2g', $cum_prob4* 100;
    $sedu = $sedval / $unit_conv;
    $result .= "$sedu $cp0r $cp1r $cp2r $cp3r $cp4r\n";
    last if ($sedval eq '0.0');
  }
  return $result;

}

sub bomb {

     print "Content-type: text/html\n\n";
     print '<html>
 <head>
  <meta http-equiv="Refresh" content="0; URL=/cgi-bin/fswepp/ermit/ermitnew.pl?units=m">
 </head>
</html>
';

}

sub ReadParse {

# ReadParse -- from cgi-lib.pl (Steve Brenner) from Eric Herrmann's
# "Teach Yourself CGI Programming With PERL in a Week" p. 131

# Reads GET or POST data, converts it to unescaped text, and puts
# one key=value in each member of the list "@in"
# Also creates key/value pairs in %in, using '\0' to separate multiple
# selections

   local (*in) = @_ if @_;
   local ($i, $loc, $key, $val);
#       read text
   if ($ENV{'REQUEST_METHOD'} eq "GET") {
     $in = $ENV{'QUERY_STRING'};
   }
   elsif ($ENV{'REQUEST_METHOD'} eq "POST") {
     read(STDIN,$in,$ENV{'CONTENT_LENGTH'});
   }
   @in = split(/&/,$in);
   foreach $i (0 .. $#in) {
     $in[$i] =~ s/\+/ /g;         # Convert pluses to spaces
     ($key, $val) = split(/=/,$in[$i],2);         # Split into key and value
     $key =~ s/%(..)/pack("c",hex($1))/ge;        # Convert %XX from hex number$
     $val =~ s/%(..)/pack("c",hex($1))/ge;
     $in{$key} .= "\0" if (defined($in{$key}));  # \0 is the multiple separator
     $in{$key} .= $val;
   }
   return 1;
}
sub peak_intensity {

#  Estimate peak durations

#  Input:
#    @max_time_list in minutes
#    $prcp	total precipitation (mm) ($prcp > 0)
#    $dur	event duration (h) ($dur > 0)
#    $tp	time to peak (fraction of duration) ($tp < 1)
#		tp == (normalized time to peak intensity) / (storm duration) [WEPP]
#    $ip	normalized peak intensity (unitless ratio) ($ip)
#		ip == (peak intensity) / (average intensity) [WEPP manual]

#  Return:
#    @i_peak	x-minute intensity (mm/h) ['N/A' if error conditions]
#    $error_text

#  Algorithm devised by Corey Moffett (ARS-Boise) and coded in R
#  Recoded in Perl by David Hall (USDA-FS)  April 16, 2004

 my $debug = 0;

 my $epsilon = 0.000001;
 my $eps_dur = 0.000001;
 my $eps_pcp = 0.000001;
# my $eps_tp  = 0.000001;	# 2004.09.16
 my $eps_tp  = 0.01;		# 2004.09.16
 my $eps_b   = 0.000001;
 my $eps_d   = 0.000001;
 my $eps_mxd = 0.000001;

 my $iteration_limit_b = 20;
 my $iteration_limit_t = 100;

 my $t_start;
 my $t_high;
 my $t_low;
 my $t_end;
 my $i_start;
 my $i_end;
 my $I_peak;
 my $starts;
 my $ends;

#  Vulnerabilities:
#	$dur     approaching 0.0
#	$prcp    approaching 0.0
#	$tp      approaching 0.0
#	$tp      approaching 1.0

#	$b       approaching 0.0
#	$d       approaching 0.0
#	$max_dur approaching 0.0

 @i_peak = ('N/A') x ($#max_time_list+1);		# set all intensities to 'N/A'

 $tp = $eps_tp if ($tp < $eps_tp);

 $error_text = '';
 $error_text .= 'Storm duration too small. ' if ($dur < $eps_dur);
 $error_text .= 'Too little precipitation. ' if ($prcp < $eps_pcp);
# $error_text .= 'Time to peak too close to 0. ' if ($tp < $eps_tp);   # 2004.09.16
 $error_text .= 'Time to peak too close to 1. ' if ($tp > 1-$eps_tp);
 return if ($error_text ne '');

 my $im = $prcp / $dur;				# (average intensity) (mm/h) $dur ~ 0

#  LEADING CURVE

#               b (x-tp)
#     y = ip  e
#

#
#  iterate to find b (leading edge exponential coefficient) such that
#
#                    -b tp
#          ip - ip e
#     b = -----------------
#               tp
#
#  "Newton's method works to solve for b if b < 60" [WEPP brown doc p. 2.9]

 my $last_b = 15;					# good all situations?
 my $b = 10;						# good all situations?

 my $loop_count = 0;
 while (abs($b - $last_b) > $epsilon) {
  $last_b = $b;
  $b = ($ip - $ip*exp(-$b*$tp))/$tp;			# &the_b
  if ($loopcount > $iteration_limit_b) {
    $error_text .= 'Could not determine appropriate B coefficient. ';
    last;
  }
  $loop_count += 1;
 }

 $error_text .= 'B coefficient too small. ' if ($b < $eps_b);

#  TRAILING CURVE

#               d (tp-x)
#     y = ip  e
#

#           b  tp
#     d = ---------
#          1 - tp


 my $d = $b * $tp / (1-$tp);				# $tp ~ 1.00
 $error_text .= 'D coefficient too small. ' if ($d < $eps_d);

 return if ($error_text ne '');

  if ($debug) {
    print "
\#   Total precip: $prcp
\#   Duration:     $dur
\#   tp:           $tp
\#   ip:           $ip
\#    b:           $b
\#    d:           $d\n\n";
  }

  my $max_time_m = 0;
  my $max_time = 0;
  my $peak_count = 0;

  foreach $max_time_m (@max_time_list) {
    $max_time = $max_time_m/60;				# times of interest in hours

    $t_start = $tp - $max_time / $dur;			# $dur ~ 0
    $t_high = $tp;
    $t_low = $t_start;
    $t_end = $tp;
    $i_start = $ip * exp($b * ($t_start - $tp));
    $i_end = $ip;

    $loop_count = 0;
    while (abs($i_start - $i_end) > $epsilon) {
      $loop_count += 1;
      if ($i_start < $i_end) { $t_low = $t_start } else { $t_high = $t_start };
      $t_start = ($t_high+$t_low)/2;			# split the difference
      $t_end = $t_start + $max_time / $dur;		# $dur ~ 0
      $i_start = $ip * exp($b * ($t_start - $tp));
      $i_end = $ip * exp($d * ($tp - $t_end));
      if ($loop_count > $iteration_limit_t) {
        $error_text .= 'Time iteration limit exceeded. ';
        last;
      }
    }

    if ($t_start < 0) {
      $starts = 0;
      $ends = 1
    }
    else {
      $starts = $t_start;
      $ends = $t_end
    }

    my $dur_peak = $ends - $starts;
    my  $max_dur = $max_time/$dur;				# $dur ~ 0

    $error_text .= 'Maximum duration too small. ' if ($max_dur < $eps_mxd);
    if ($error_text ne '') {
      next
    }

    if ($dur_peak > $max_dur) {$max_dur = $dur_peak};
    $I_peak = (($ip/$b - $ip/$b*exp($b*($starts-$tp))) + ($ip/$d - $ip/$d*exp($d*($tp-$ends))))*$im/$max_dur;
		# $b ~ 0;  $d ~ 0;  $max_dur ~ 0;  $im ~ 0 [$prcp ~ 0]

    @i_peak[$peak_count] = sprintf '%.2f', $I_peak;
    $peak_count += 1;

    if ($debug) {
      $starts_h = $starts * $dur;
      $ends_h = $ends * $dur;
      $dur_peak_m = $dur_peak * $dur * 60; 

      print "\# $max_time_m min peak intensity
\#    starts    $starts_h h
\#    ends      $ends_h h
\#    duration  $dur_peak_m m
\#    intensity $I_peak
";
    }
    $error_text='';
  }

# =======================================================

# C:\4702\deh\ermit>perl dur_test2.pl

#   Total precip: 101.6
#   Duration:       1
#   tp:             0.01
#   ip:             1.01
#    b:             1.99
#    d:             0.02

# 10 min peak intensity
#    starts         0.008 h
#    ends           0.175 h
#    duration      10 m
#    intensity    102.4
#
# 30 min peak intensity
#    starts         0.005 h
#    ends           0.505 h
#    duration      30 m
#    intensity    102.1
#
# 60 min peak intensity
#    starts         0 h
#    ends           1 h
#    duration      60 m
#    intensity    101.6


# C:\4702\deh\ermit>perl dur_test2.p

#   Total precip:  76.2
#   Duration:       2
#   tp:             0.75
#   ip:             5
#    b:             6.620
#    d:            19.86

# 10 min peak intensity
#    starts         1.375 h
#    ends           1.54 h
#    duration      10 m
#    intensity    156.0
# 30 min peak intensity
#    starts         1.125 h
#    ends           1.625 h
#    duration      30 m
#    intensity    109.1
# 60 min peak intensity
#    starts         0.75 h
#    ends           1.75 h
#    duration      60 m
#    intensity     70.3

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
# print $line;
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

################

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
# WHRM Wildlife Habitat Response Model Version History

  $version='2005.02.08';        # Make self-creating history popup page
# $version = '2005.02.07';      # Fix parameter passing to tail_html; stuff after semicolon lost
#!$version = '2005.02.07';      # Bang in line says do not use
# $version = '2005.02.04';      # Clean up HTML formatting, add head_html and tail_html functions
#                               # Continuation line not handled
# $version = '2005.01.08';      # Initial beta release

## END HISTORY ######################################################

# and returns body (including Javascript document.writeln instructions) for a pop-up history window
# called pophistory.

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
        ($vers, $comment) = split (/;/,$_);
        $comment =~ s/#//;
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
# ------------------------ end of subroutines ----------------------------
