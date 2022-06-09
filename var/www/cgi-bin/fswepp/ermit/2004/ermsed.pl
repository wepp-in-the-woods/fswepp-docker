#! /usr/bin/perl
#
# erm.pl
#
# ermit workhorse
# Reads user input from ermit.pl, runs WEPP, parses output files
# top adapted from wd.pl 8/28/2002

# *** check top_slope

# to do: check how leap years are handled #

# 23 Apr 2004 DEH report 10- and 30-min peak int in English if desired
# 22 Apr 2004 DEH pump 100-year climate files to 'working' if 'g'
#                 add storm duration estimation calculation (metric)
#                 specify 'year nn' under 'Storm date'
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

   $debug = 0;
   $sortsed = 0;
   $zoop = 0;

#  $version = "2004.03.16";
   $version = "2004.04.23";

#   $rfg = 20;

#=========================================================================

   &ReadParse(*parameters);

   $me=$parameters{'me'};
   $units=$parameters{'units'};
   $CL=$parameters{'Climate'};         # get Climate (file name base)
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

   $wgr = 1 if ($me eq 'g');							# DEH 2004.03.16
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
       exec "perl ../rc/descpar.pl $CL $comefrom"
     }
     else {
       exec "../rc/descpar.pl $CL $comefrom"
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
   $gnuplotgraph   = $workingpath . '.png';
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
     print '<BODY background="http://',$wepphost,
          '/fswepp/images/note.gif" link="#ff0000">
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
       print '<tr><th colspan=3 bgcolor="85d2d2">',"\n";
       print "Element $i --- \n";
       $record = <SOIL>;
       @descriptors = split "'", $record;
       print "@descriptors[1]   ";                # slid: Road, Fill, Forest
       print "<br>Soil texture: @descriptors[3]\n";    # texid: soil texture
       ($nsl,$salb,$sat,$ki,$kr,$shcrit,$avke) = split " ", @descriptors[4];
#      @vals = split " ", @descriptors[4];
#      print "No. soil layers: $nsl\n";
       print "<tr><th align=left>Albedo of the bare dry surface soil<td align='right'>$salb<td>\n";
       print "<tr><th align=left>Initial saturation level of the soil profile porosity<td align='right'>$sat<td>m m<sup>-1</sup>\n";
       print "<tr><th align=left>Baseline interrill erodibility parameter (<i>k<sub>i</sub></i> )<td align='right'>$ki<td>kg s m<sup>-4</sup>\n";
       print "<tr><th align=left>Baseline rill erodibility parameter (<i>k<sub>r</sub></i> )<td align='right'>$kr<td>s m<sup>-1</sup>\n";
       print "<tr><th align=left>Baseline critical shear parameter (&tau;<sub>c</sub>)<td align='right'>$shcrit<td>N m<sup>-2</sup>\n";
       print "<tr><th align=left>Effective hydraulic conductivity of surface soil<td align='right'>$avke<td>mm h<sup>-1</sup>\n";
       for $layer (1..$nsl) {
         $record = <SOIL>;
         ($solthk,$sand,$clay,$orgmat,$cec,$rfg) = split " ", $record;
         print "<tr><td><br><th colspan=2 bgcolor=85d2d2>layer $layer\n";
         print "<tr><th align=left>Depth from soil surface to bottom of soil layer<td align='right'>$solthk<td>mm\n";
         print "<tr><th align=left>Percentage of sand<td align='right'>$sand<td>%\n";
         print "<tr><th align=left>Percentage of clay<td align='right'>$clay<td>%\n";
         print "<tr><th align=left>Percentage of organic matter (by volume)<td align='right'>$orgmat<td>%\n";
         print "<tr><th align=left>Cation exchange capacity<td align='right'>$cec<td>meq per 100 g of soil\n";
         print "<tr><th align=left>Percentage of rock fragments (by volume)<td align='right'>$rfg<td>%\n";
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
  $intunits = 'mm/h';
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
    $intunits = 'in/h';
    $sedunits = 't ac<sup>-1</sup>';
    $alt_sedunits = 't / ac';
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

   @selected_ranks = (5,10,20,50);

sub numerically { $a <=> $b }

   $evo_file = "<$eventFile";

#zxc ============================================================

    open EVO, $evo_file;
    while (<EVO>) {                             # skip past header lines
#      if ($_ =~ /------/) {last}
      if ($_ =~ /---/) {last}
    }

    print TEMP $_ if ($zoop);   # verify location

    $keep = <EVO>;
    ($day1,$month1,$year1,$precip1,$runoff1,$rest1) = split ' ', $keep, 6;
    ($interrill_det,$avg_det,$max_det,$det_pt,$avg_dep,$max_dep,$dep_pt,$sed_del,$enrich) = split ' ', $rest1;

    if ($sortsed) {$var1=$sed_del1+0} else {$var1=$runoff1+0}		# force to numeric
    $year1+=0;                     # force to numeric

#   print "day: $day1\tmonth: $month1\tyear: $year1\trunoff:$runoff1\n" if ($zoop);

    if ($zoop) {
      if ($sortsed) {
       print TEMP "$evo_file
 -- maximal sediment delivery event for year, sorted by year

day month  yr precip runoff interrill avg   max    det     avg     max     dep    sed  enrich
                              det     det   det     pt     dep     dep      pt    del

";
      }
      else {
       print TEMP "$evo_file
 -- maximal runoff event for year, sorted by year

day month  yr precip runoff interrill avg   max    det     avg     max     dep    sed  enrich
                              det     det   det     pt     dep     dep      pt    del

";
      }
    }

    while (<EVO>) {
      ($day,$month,$year,$precip,$runoff,$rest) = split ' ', $_, 6;
      ($interrill_det,$avg_det,$max_det,$det_pt,$avg_dep,$max_dep,$dep_pt,$sed_del,$enrich) = split ' ', $rest;

      if ($sortsed) {$var=$sed_del+0} else {$var=$runoff+0}		# force to numeric
      $year+=0;                     # force to numeric
      if ($year == $year1) {                    # same year
        if ($var > $var1) {               	# new runoff or sed_del larger
          $keep = $_;                           # keep the new one
          $var1 = $var;
          @max_var[$yr] = $keep;
          @variable[$yr] = $var;
        }
        else {                                  # new runoff of sed_del small
        }
      }
      else {                            	# new year

        print TEMP $keep if ($zoop);                 # print last year's max$
        $yr++;
        $keep = $_;                     # update this year's starting line
        @max_var[$yr] = $keep;
        @variable[$yr] = $var;
        $year1 = $year;                 # update year
        $var1 = $var;             # update this year's first runoff
      }
    }
                                        # handle final year
    if ($var > $var1) {           # new runoff larger
      $keep = $_;                       # keep the new one
      $var1 = $var;
      @max_var[$yr] = $keep;
      @variable[$yr] = $var;
    }

    print TEMP $keep if ($zoop);                        # print final year's ma$
    close EVO;

  if ($debug) {$, = " "; print "\n",@variable,"\n"; $, = "";}

# index-sort runoff or sed_del  # index sort from "Efficient FORTRAN Programming
                                # see built-in index sort elsewhere in code...

  $years = $#variable;
  for $i (0..$years) {@indx[$i]=$i}     # set up initial index into array
  for $i (0..$years-1) {
    $m = $i;
    for $j ($i+1..$years) {
      $m = $j if $variable[$indx[$j]] > $variable[$indx[$m]]
    }
    $temp     = $indx[$m];
    $indx[$m] = $indx[$i];
    $indx[$i] = $temp;
  }

  if ($zoop) {
    if ($sortsed) {
     print TEMP '

 -- maximal sed delivery for each year, sorted by sed del

day month  yr precip runoff interrill avg   max    det     avg     max     dep    sed  enrich
                              det     det   det     pt     dep     dep      pt    del

';
    }
    else {
     print TEMP '

 -- maximal runoff for each year, sorted by runoff

day month  yr precip runoff interrill avg   max    det     avg     max     dep    sed  enrich
                              det     det   det     pt     dep     dep      pt    del

';
    }
  }

  if ($debug) {print "\n -- maximal runoff for each year, sorted by runoff\n\n";}

# testing here ###
  if ($zoop) {
#    for $i (0..$years) {print @variable[$indx[$i]],"  "}
#    print "\n\n<p>"; $, = "<br>";
    for $i (0..$years) {print TEMP @max_var[$indx[$i]]}
  }

####****###
#zxc =======================================

# print TEMP "<p>Runoff events range from ",@run_off[$indx[0]]," down to ",@run_off[$indx[$years]]," mm\n";

# select [5th, 10th, 20th, 50th] largest runoff event lines

  for $i (0..$#selected_ranks) {
    @selected_ranks[$i] -= 1;			# account for base zero
    ($day,$month,$year,$precip,$runoff,$rest) = split ' ', @max_run[$indx[$selected_ranks[$i]]], 6;
    ($interrill_det,$avg_det,$max_det,$det_pt,$avg_dep,$max_dep,$dep_pt,$sed_del,$enrich) = split ' ', $rest; 
    @sed_delivery[$i] = $sed_del;
    @precip[$i] = $precip;
    @day[$i] = $day;
    @month[$i] = $month;
    @selected_year[$i] = $year;
    @previous_year[$i] = $year-1;   # DEH 2003/11/20 ***
    if ($year == 1) {@previous_year[$i] = $year};  # DEH 2003/11/20 ***
  }

#print TEMP "@selected_ranks\n";

    ($max_day,$max_month,$max_year,$precip,$runoff,$rest) = split ' ', @max_run[@indx[0]], 6;
    ($interrill_det,$avg_det,$max_det,$det_pt,$avg_dep,$max_dep,$dep_pt,$sed_del,$enrich) = split ' ', $rest; 
    @monthnames = ('', 'January', 'February', 'March', 'April', 'May','June', 'July', 'August', 'September', 'October', 'November', 'December');

#### 2003 units
      if ($units eq 'ft') {
         $variable_f = sprintf '%9.2f', @variable[$indx[0]]/25.4;
#        $run_off_f = sprintf '%9.2f', $runoff/25.4;
         $precip_f = sprintf '%9.2f', $precip/25.4;
         $sed_del_f = sprintf '%9.2f', $sed_del / $hillslope_length_m * 4.45;
            # kg per m / m length * 4.45 --> t per ac
      }
      else {
         $variable_f = @variable[$indx[0]];
#        $run_off_f = $runoff;
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

    @max_time_list = (10, 30);			# target durations times (min)
    $prcp = $d_pcp;
    $dur = $durr;
    &peak_intensity;

    if ($units eq 'ft') {
      @i_peak[0] = sprintf '%9.2f', @i_peak[0]/25.4 if (@i_peak[0] ne 'N/A');
      @i_peak[1] = sprintf '%9.2f', @i_peak[1]/25.4 if (@i_peak[1] ne 'N/A');
    }
    else {
      @i_peak[0] = sprintf '%9.2f', @i_peak[0] if (@i_peak[0] ne 'N/A');
      @i_peak[1] = sprintf '%9.2f', @i_peak[1] if (@i_peak[1] ne 'N/A');
    }

print TEMP "<p>
       <table border=1 cellpadding=8 bgcolor='ivory'>
        <tr><th bgcolor='#ffddff'>Ranking of event<br>(return interval)
         <th bgcolor='#ffddff'>Storm<br>Runoff or Sed del<br>($precipunits)
         <th bgcolor='#ffddff'>Storm<br>Precipitation<br>($precipunits)
         <th bgcolor='#ffddff'>Storm<br>Duration<br>(h)
         <th bgcolor='#ffddff'>tp<br>(fraction)
         <th bgcolor='#ffddff'>ip<br>(ratio)
         <th bgcolor='#ffddff'>10-min peak int<br>($intunits)
         <th bgcolor='#ffddff'>30-min peak int<br>($intunits)
         <th bgcolor='#ffddff'>Storm date
        </tr>
        <tr>
         <th bgcolor='#ff00ff'>1</th>
         <td align=right>$variable_f</td>
         <td align=right>$precip_f</td>
         <td align=right>$durr</td>
         <td align=right>$tp</td>
         <td align=right>$ip</td>
         <td align=right>@i_peak[0]</td>
         <td align=right>@i_peak[1]</td>
         <td align=right>@monthnames[$max_month]&nbsp;$max_day<br>year $max_year</td>
        </tr>
";

   @color[0]="'#ff33ff'"; @color[1]="'#ff66ff'"; @color[2]="'#ff99ff'";
   @color[3]="'#ffaaff'"; @color[4]="'#ffccff'"; @color[5]="'#ffddff'";

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
    &peak_intensity;
#      returns peak intensities (mm/h) or 'N/A' in @i_peak
#      returns $error_text
### duration DEH 040422

# #### 2003 units
      if ($units eq 'ft') {
        $variable_f = sprintf '%9.2f', @variable[$indx[@selected_ranks[$i]]]/25.4;
#zxc    $run_off_f = sprintf '%9.2f', @runoff[$i]/25.4;
        $precip_f = sprintf '%9.2f', @precip[$i]/25.4;
        $sed_delivery_f = @sed_delivery[$i];
        $sed_delivery_f = sprintf '%9.2f', $sed_delivery_f / $hillslope_length_m * 4.45;
        @i_peak[0] = sprintf '%9.2f', @i_peak[0]/25.4 if (@i_peak[0] ne 'N/A');
        @i_peak[1] = sprintf '%9.2f', @i_peak[1]/25.4 if (@i_peak[1] ne 'N/A');
      }
      else {
        $variable_f = @variable[$indx[@selected_ranks[$i]]];
#zxc    $run_off_f = @runoff[$i];
        $precip_f = @precip[$i];
        $sed_delivery_f = @sed_delivery[$i];
        $sed_delivery_f = $sed_delivery_f / $hillslope_length * 10;
        @i_peak[0] = sprintf '%9.2f', @i_peak[0] if (@i_peak[0] ne 'N/A');
        @i_peak[1] = sprintf '%9.2f', @i_peak[1] if (@i_peak[1] ne 'N/A');
      }

# #### 2003 units
      print TEMP "            <tr>
             <th bgcolor=@color[$i]>",@selected_ranks[$i] + 1,'<br>(',100/(@selected_ranks[$i] + 1),"- year)</td>
             <td align=right><b>$variable_f</b></td>
             <td align=right><b>$precip_f</b></td>
             <td align=right><b>$durr</b></td>
             <td align=right><b>$tp</b></td>
             <td align=right><b>$ip</b></td>
             <td align=right><b>@i_peak[0]</b></td>
             <td align=right><b>@i_peak[1]</b></td>
             <td align=right><b>@monthnames[@month[$i]]&nbsp;@day[$i]<br>year @selected_year[$i]</b></td>
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
       $variable_f = ' -- ';
       $precip_f = ' -- ';
       $sed_del_f = ' -- ';
     }
     elsif ($units eq 'ft') {
       $variable_f = sprintf '%9.2f', @variable[$indx[$years]]/25.4;
       $precip_f  = sprintf '%9.2f', $precip/25.4;
       $sed_del_f = sprintf '%9.2f', $sed_del / $hillslope_length_m * 4.45;
       @i_peak[0] = sprintf '%9.2f', @i_peak[0]/25.4 if (@i_peak[0] ne 'N/A');
       @i_peak[1] = sprintf '%9.2f', @i_peak[1]/25.4 if (@i_peak[1] ne 'N/A');
     }
     else {
       $variable_f = @variable[$indx[$years]];
       $precip_f = $precip;
       $sed_del_f = $sed_del / $hillslope_length * 10;
       @i_peak[0] = sprintf '%9.2f', @i_peak[0] if (@i_peak[0] ne 'N/A');
       @i_peak[1] = sprintf '%9.2f', @i_peak[1] if (@i_peak[1] ne 'N/A');
     }

      print TEMP
"     <tr>
       <th bgcolor='#ffddff'>100</td>
       <td align=right>$variable_f</td>
       <td align=right>$precip_f</td>
       <td align=right>$durr</td>
       <td align=right>$tp</td>
       <td align=right>$ip</td>
       <td align=right>@i_peak[0]</td>
       <td align=right>@i_peak[1]</td>
       <td align=right>@monthnames[$min_month]&nbsp;$min_day<br>year $min_year</td>
      </tr>
     </table>
";

################################ skippit

# goto cutout;

     $a=0;            # dummy

# ------------------------ flow 5 --------------------------------

# ermit flow

# climate selected
# soil selected			["clay loam" "silt loam" "sandy loam" "loam"]
# vegetation type selected	["forest" "range" "chaparral"]
# topography specified		["surface slope average" "surface slope at toe" "surface length"]
# fire severity class selected	["L" "M" "H"]

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

#  @probClimate = (0.075, 0.075, 0.20, 0.65);	# rank 5, ..  DEH 2004.03.18
#  @probClimate = (0.05, 0.05, 0.1, 0.3);	# rank 5, rank 10, rank 20, rank 50
   @probClimate = (0.05, 0.1, 0.3, 0.5);	# rank 5, rank 10, rank 20, rank 50
# no mitigation
   @probSoil0 = (0.10, 0.20, 0.40, 0.20, 0.10); # year 0
   @probSoil1 = (0.30, 0.30, 0.20, 0.19, 0.01); # year 1
   @probSoil2 = (0.50, 0.30, 0.18, 0.01, 0.01); # year 2
   @probSoil3 = (0.60, 0.30, 0.08, 0.01, 0.01); # year 3
   @probSoil4 = (0.70, 0.27, 0.01, 0.01, 0.01); # year 4
# seeding
   @probSoil_s0 = (0.10, 0.20, 0.40, 0.20, 0.10); # year 0
   @probSoil_s1 = (0.50, 0.30, 0.18, 0.01, 0.01); # year 2
   @probSoil_s2 = (0.60, 0.30, 0.08, 0.01, 0.01); # year 3
   @probSoil_s3 = (0.70, 0.27, 0.01, 0.01, 0.01); # year 4
   @probSoil_s4 = (0.70, 0.27, 0.01, 0.01, 0.01); # year 4
# mulching 0.5 Mg/ha
   @probSoil_mh0 = (0.30, 0.40, 0.20, 0.09, 0.01); # year 0
   @probSoil_mh1 = (0.40, 0.35, 0.20, 0.04, 0.01); # year 1
   @probSoil_mh2 = (0.50, 0.30, 0.18, 0.01, 0.01); # year 2
   @probSoil_mh3 = (0.60, 0.30, 0.08, 0.01, 0.01); # year 3
   @probSoil_mh4 = (0.70, 0.27, 0.01, 0.01, 0.01); # year 4
# mulching 1 Mg/ha
   @probSoil_mo0 = (0.70, 0.20, 0.08, 0.01, 0.01); # year 0
   @probSoil_mo1 = (0.60, 0.25, 0.13, 0.01, 0.01); # year 1
   @probSoil_mo2 = (0.50, 0.30, 0.18, 0.01, 0.01); # year 2
   @probSoil_mo3 = (0.60, 0.30, 0.08, 0.01, 0.01); # year 3
   @probSoil_mo4 = (0.70, 0.27, 0.01, 0.01, 0.01); # year 4
# mulching 1.5 Mg/ha
   @probSoil_moh0 = (0.80, 0.10, 0.08, 0.01, 0.01); # year 0
   @probSoil_moh1 = (0.65, 0.20, 0.13, 0.01, 0.01); # year 1
   @probSoil_moh2 = (0.50, 0.30, 0.18, 0.01, 0.01); # year 2
   @probSoil_moh3 = (0.60, 0.30, 0.08, 0.01, 0.01); # year 3
   @probSoil_moh4 = (0.70, 0.27, 0.01, 0.01, 0.01); # year 4
# mulching 2 Mg/ha
   @probSoil_mt0 = (0.90, 0.07, 0.01, 0.01, 0.01); # year 0
#  @probSoil_mt1 = (0.70, 0.20, 0.20, 0.01, 0.01); # year 1
   @probSoil_mt1 = (0.70, 0.20, 0.08, 0.01, 0.01); # year 1 # DEH 2004.03.18
   @probSoil_mt2 = (0.50, 0.30, 0.18, 0.01, 0.01); # year 2
   @probSoil_mt3 = (0.60, 0.30, 0.08, 0.01, 0.01); # year 3
   @probSoil_mt4 = (0.70, 0.27, 0.01, 0.01, 0.01); # year 4
   if (lc($severityclass) eq "h") { 
     @severe = ("hhh", "lhh", "hlh", "hhl");
     @probspatial = (0.10, 0.30, 0.30, 0.30);
   }
   if (lc($severityclass) eq "m") {
     @severe = ("hlh", "hhl", "llh", "lhl");
     @probspatial = (0.25, 0.25, 0.25, 0.25);
   }
   if (lc($severityclass) eq "l") {
     @severe = ("llh", "lhl", "hll", "lll");
     @probspatial = (0.30, 0.30, 0.30, 0.10);
   }

#DEH 8
#   $severe[0]="hhh"; $severe[1]="hhl"; $severe[2]="hlh"; $severe[3]="lhh";
#   $severe[4]="llh"; $severe[5]="lhl"; $severe[6]="hll"; $severe[7]="lll";

#DEH 8  @severe = ("hhh", "lhh", "hlh", "hhl", "llh", "lhl", "hll", "lll");

  if ($debug) {print TEMP "Severity class '$severityclass'\n"}
  if ($debug) {print TEMP '<pre><font face="courier new, courier"><br>',"\n"}

#DEH 8

#   for $sn (1..1) {   #ZZ#
#   for $sn (0..7) {
   for $sn (0..3) {
     $s = $severe[$sn];
# 	@severity = (LLL, HLL, LHL, LLH), (LHL, LLH, LHH, HLH), (LHH, HLH, HHL, HHH)

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

#        pull out 8 sediment deliveries from WEPP output
#          (4 from event years, 4 from annual years)
#		store one in each of 8 tables by year
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
  <tr><th colspan=5><font size=+1>SEDIMENT  DELIVERY (', $sedunits,')</font></th><th>Spatial (prob)</th></tr>',"\n";
  }

# @selected_ranks[$i] + 1,' (',100/(@selected_ranks[$i] + 1),"- year)

  for $c (0..$#selected_year) {
   if ($pt) {
     print TEMP '  <tr><th align="left" bgcolor="ffff99" colspan="5">', @selected_ranks[$c] + 1,' (',100/(@selected_ranks[$c] + 1),'- year) -- ',@day[$c],' ',@monthnames[@month[$c]],' year ',@selected_year[$c],' (',@probClimate[$c]*100,'%)</th><td></td></tr>',"\n";
   }
#DEH 8
#    for $sn (0..7) {
    for $sn (0..3) {
      if ($pt) {      print TEMP "<tr>\n"; }
      for $k (0..4) {
        @sed_yields[$sp] = $sedtable[$c][$k][$sn];
# no mitigation
        @probabilities0[$sp] = @probClimate[$c] * @probspatial[$sn] * @probSoil0[$k];
        @probabilities1[$sp] = @probClimate[$c] * @probspatial[$sn] * @probSoil1[$k];
        @probabilities2[$sp] = @probClimate[$c] * @probspatial[$sn] * @probSoil2[$k];
        @probabilities3[$sp] = @probClimate[$c] * @probspatial[$sn] * @probSoil3[$k];
        @probabilities4[$sp] = @probClimate[$c] * @probspatial[$sn] * @probSoil4[$k];
# seeding
        @probabilities_s0[$sp] = @probClimate[$c] * @probspatial[$sn] * @probSoil_s0[$k];
        @probabilities_s1[$sp] = @probClimate[$c] * @probspatial[$sn] * @probSoil_s1[$k];
        @probabilities_s2[$sp] = @probClimate[$c] * @probspatial[$sn] * @probSoil_s2[$k];
        @probabilities_s3[$sp] = @probClimate[$c] * @probspatial[$sn] * @probSoil_s3[$k];
        @probabilities_s4[$sp] = @probClimate[$c] * @probspatial[$sn] * @probSoil_s4[$k];
# mulch 0.5 Mg/ha
        @probabilities_mh0[$sp] = @probClimate[$c] * @probspatial[$sn] * @probSoil_mh0[$k];
        @probabilities_mh1[$sp] = @probClimate[$c] * @probspatial[$sn] * @probSoil_mh1[$k];
        @probabilities_mh2[$sp] = @probClimate[$c] * @probspatial[$sn] * @probSoil_mh2[$k];
        @probabilities_mh3[$sp] = @probClimate[$c] * @probspatial[$sn] * @probSoil_mh3[$k];
        @probabilities_mh4[$sp] = @probClimate[$c] * @probspatial[$sn] * @probSoil_mh4[$k];
# mulch 1.0 Mg/ha
        @probabilities_mo0[$sp] = @probClimate[$c] * @probspatial[$sn] * @probSoil_mo0[$k];
        @probabilities_mo1[$sp] = @probClimate[$c] * @probspatial[$sn] * @probSoil_mo1[$k];
        @probabilities_mo2[$sp] = @probClimate[$c] * @probspatial[$sn] * @probSoil_mo2[$k];
        @probabilities_mo3[$sp] = @probClimate[$c] * @probspatial[$sn] * @probSoil_mo3[$k];
        @probabilities_mo4[$sp] = @probClimate[$c] * @probspatial[$sn] * @probSoil_mo4[$k];
# mulch 1.5 Mg/ha
        @probabilities_moh0[$sp] = @probClimate[$c] * @probspatial[$sn] * @probSoil_moh0[$k];
        @probabilities_moh1[$sp] = @probClimate[$c] * @probspatial[$sn] * @probSoil_moh1[$k];
        @probabilities_moh2[$sp] = @probClimate[$c] * @probspatial[$sn] * @probSoil_moh2[$k];
        @probabilities_moh3[$sp] = @probClimate[$c] * @probspatial[$sn] * @probSoil_moh3[$k];
        @probabilities_moh4[$sp] = @probClimate[$c] * @probspatial[$sn] * @probSoil_moh4[$k];
# mulch 2.0 Mg/ha
        @probabilities_mt0[$sp] = @probClimate[$c] * @probspatial[$sn] * @probSoil_mt0[$k];
        @probabilities_mt1[$sp] = @probClimate[$c] * @probspatial[$sn] * @probSoil_mt1[$k];
        @probabilities_mt2[$sp] = @probClimate[$c] * @probspatial[$sn] * @probSoil_mt2[$k];
        @probabilities_mt3[$sp] = @probClimate[$c] * @probspatial[$sn] * @probSoil_mt3[$k];
        @probabilities_mt4[$sp] = @probClimate[$c] * @probspatial[$sn] * @probSoil_mt4[$k];

        if ($units eq 'ft') {     # convert sediment yield kg per m to t per ac
          $sed_yield = @sed_yields[$sp] / $hillslope_length * 4.45; 
        }
        else {     # convert sediment yield kg per m to t per ha
          $sed_yield = @sed_yields[$sp] / $hillslope_length * 10; 
        }
    if ($pt) {
        print TEMP "
  <td align=\"right\"><a href=\"http://forest.moscowfsl.wsu.edu/cgi-bin/fswepp/ermit/soilfile.pl?s=$severe[$sn]&k=$k&SoilType=$SoilType&vegtype=$vegtype&rfg=$rfg&grass=$grass&shrub=$shrub&bare=$bare\" target=\"o\">$sed_yield</a></td>
";
    }
        $sp += 1;
      }
    if ($pt) {
      print TEMP '<td bgcolor="ffff99">',@severe[$sn],' (', @probspatial[$sn]*100, "%)</td></tr>\n";
    }
    }
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

  if ($debug) {print TEMP "<pre>\n"}
# no mitigation
  $cum_prob0 = 0.05;					# DEH 2004.03.18 0. to 0.05 per CM
  $cum_prob1 = 0.05;
  $cum_prob2 = 0.05;
  $cum_prob3 = 0.05;
  $cum_prob4 = 0.05;
# seeding
  $cum_prob_s0 = 0.05;
  $cum_prob_s1 = 0.05;
  $cum_prob_s2 = 0.05;
  $cum_prob_s3 = 0.05;
  $cum_prob_s4 = 0.05;
# mulch 0.5 Mg/ha
  $cum_prob_mh0 = 0.05;
  $cum_prob_mh1 = 0.05;
  $cum_prob_mh2 = 0.05;
  $cum_prob_mh3 = 0.05;
  $cum_prob_mh4 = 0.05;
# mulch 1.0 Mg/ha
  $cum_prob_mo0 = 0.05;
  $cum_prob_mo1 = 0.05;
  $cum_prob_mo2 = 0.05;
  $cum_prob_mo3 = 0.05;
  $cum_prob_mo4 = 0.05;
# mulch 1.5 Mg/ha
  $cum_prob_moh0 = 0.05;
  $cum_prob_moh1 = 0.05;
  $cum_prob_moh2 = 0.05;
  $cum_prob_moh3 = 0.05;
  $cum_prob_moh4 = 0.05;
# mulch 2.0 Mg/ha
  $cum_prob_mt0 = 0.05;
  $cum_prob_mt1 = 0.05;
  $cum_prob_mt2 = 0.05;
  $cum_prob_mt3 = 0.05;
  $cum_prob_mt4 = 0.05;
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
# mulch 0.5 Mg/ha
    $cum_prob_mh0 += @probabilities_mh0[@index[$sp]];
    $cum_prob_mh1 += @probabilities_mh1[@index[$sp]];
    $cum_prob_mh2 += @probabilities_mh2[@index[$sp]];
    $cum_prob_mh3 += @probabilities_mh3[@index[$sp]];
    $cum_prob_mh4 += @probabilities_mh4[@index[$sp]];
# mulch 1.0 Mg/ha
    $cum_prob_mo0 += @probabilities_mo0[@index[$sp]];
    $cum_prob_mo1 += @probabilities_mo1[@index[$sp]];
    $cum_prob_mo2 += @probabilities_mo2[@index[$sp]];
    $cum_prob_mo3 += @probabilities_mo3[@index[$sp]];
    $cum_prob_mo4 += @probabilities_mo4[@index[$sp]];
# mulch 1.5 Mg/ha
    $cum_prob_moh0 += @probabilities_moh0[@index[$sp]];
    $cum_prob_moh1 += @probabilities_moh1[@index[$sp]];
    $cum_prob_moh2 += @probabilities_moh2[@index[$sp]];
    $cum_prob_moh3 += @probabilities_moh3[@index[$sp]];
    $cum_prob_moh4 += @probabilities_moh4[@index[$sp]];
# mulch 2.0 Mg/ha
    $cum_prob_mt0 += @probabilities_mt0[@index[$sp]];
    $cum_prob_mt1 += @probabilities_mt1[@index[$sp]];
    $cum_prob_mt2 += @probabilities_mt2[@index[$sp]];
    $cum_prob_mt3 += @probabilities_mt3[@index[$sp]];
    $cum_prob_mt4 += @probabilities_mt4[@index[$sp]];

    if ($debug) {print TEMP @sed_yields[@index[$sp]],"\t",@probabilities0[@index[$sp]],"\t$cum_prob0\t$cum_prob1\t$cum_prob2\t$cum_prob3\t$cum_prob4\n";}
#    print TEMP @sed_yields[@index[$sp]],"\t",@probabilities0[@index[$sp]],"\t$cum_prob0\t",,"\t",@probabilities1[@index[$sp]],"\t$cum_prob1\n";
  }
  if ($debug) {print TEMP "\n\n";}

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
  open (GP, "|gnuplot");
   use FileHandle;  
   GP->autoflush(1);      # force buffer to flush after each write
   print GP "load '$gnuplotjclfile'\n";
  close GP;

close TEMP;

############################
#  return HTML page
############################

   print "Content-type: text/html\n\n";	# SERVER
   print '<HTML>
   <HEAD>
   <TITLE>ERMiT Results</TITLE>
<bgsound src="http://forest.moscowfsl.wsu.edu/sounds/SHAKUHA1.WAV">
<script language="Javascript">

function percentages(x) {
    document.doit.probability0.value = x; probchange(0)
    document.doit.probability1.value = x; probchange(1)
    document.doit.probability2.value = x; probchange(2)
    document.doit.probability3.value = x; probchange(3)
    document.doit.probability4.value = x; probchange(4)
}

function sediments(x) {
    document.doit.sediment0.value = x; sedchange(0)
    document.doit.sediment1.value = x; sedchange(1)
    document.doit.sediment2.value = x; sedchange(2)
    document.doit.sediment3.value = x; sedchange(3)
    document.doit.sediment4.value = x; sedchange(4)
}

function removeSpinner() {
//    newin = window.open("/fswepp/ermit/closeme.html","spinner")        
    newin = window.open("","spinner")        
    newin.window.close()
}

';

#  &CreateJavascriptsoilfileFunction;
  &CreateJavascriptwhatsedsFunction;

cutout:

#   <BODY background="http://',$wepphost,'/fswepp/images/note.gif" link="#1603F3" vlink="#160A8C">
print'   </HEAD>
   <BODY link="#1603F3" vlink="#160A8C" onLoad="removeSpinner()" background="/fswepp/ermit/under_dev.gif">
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
       <b>$severityclass_x</b> fire severity
      </td>
     </tr>
     <tr>
      <td bgcolor=ccffff> <b>$vegtype</b> vegetation
      </td>
     </tr>
";

    if ($vegtype ne 'forest') {print "
     <tr>
      <td bgcolor=ccffff>
        Prefire community <b>$shrub% shrub, $grass% grass<\/b> 
      </td>
     </tr>
     <tr>
      <td bgcolor=ccffff>
       <table width=100% border=0>
        <tr>
         <td bgcolor=\"yellow\" width=\"$shrub %\" height=15>
         </td>
         <td bgcolor=\"green\" width=\"$grass %\" height=15>
         </td>
          <td bgcolor=\"brown\" width=\"$bare %\" height=15>
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
<p>
  <form name="doit">

   <table border="1" bgcolor="ffff99">
    <tr>
     <td align="center">
      <script>
       sed_del_min = rounder(sed_del[80]*js_sedconv,2)
       sed_del_max = rounder(sed_del[1]*js_sedconv,2)
       // document.writeln('Sediment delivery ranges from <b>'+sed_del_min+'<\/b> to <b>'+sed_del_max+'<\/b> '+js_sedunits+'<br>')
      </script>
     </td>
    </tr>
   </table>

<p>   <!-- =============== contour-felled logs or straw wattles ======= -->

<!--

  <h3>Contour-felled logs or straw wattles</h3>
<p>
-->
   <input type="hidden" name="diameter" value =" 1" size="6" onChange="javascript:logchange()">
   <input type="hidden" name="spacing" value="10" size="6" onChange="javascript:logchange()">

 <script>
  var seds = whatseds (0.1, cp0)
  seds = rounder(seds*js_sedconv,2)
  var diameter=document.doit.diameter.value
  var spacing=document.doit.spacing.value
  var seddel

  var spacing_m = spacing    // convert ft to m if necesarry
  var diameter_m = diameter  // convert ft to m if necessary
  var slope_ratio = js_avg_slope / 100

  // as slope approaches zero, term b approaches infinity (div by 0)
  // as spacing approaches zero, term a approaches infinity (div by 0 )
  if (slope_ratio < 0.1) {slope_ratio = 0.1}
  if (spacing < 0.5) {spacing = 0.5}
  if (diameter < 0.1) {diameter = 0.1}

  var a_num = 9000 * diameter_m * diameter_m
  var a_denom = spacing_m * Math.cos(Math.atan(slope_ratio))
  var b = (1 / (2 * slope_ratio)) - 0.6
  var capacity = (a_num / a_denom) * b
  var twocap = 2 * capacity

// 2004.03.18 DEH remove first output table

//  document.writeln('<table border=1>')
//  document.write('<tr><th rowspan=3 bgcolor="gold">Target event<br>sediment delivery<br>')
//  document.write(' <input type="text" name="sediment0x" onChange="javascript:sedchange()" value="'+seds+'" size="6"> ')
//  document.writeln(js_sedunits + '&nbsp;&nbsp;&nbsp;<img src="'+gostone+'" border=0>')

//  document.writeln(' <th colspan=5 bgcolor="yellow">Chance that target event sediment delivery<br>will be exceeded (%)&nbsp;&nbsp;&nbsp;')
//  document.writeln('   <a href="javascript:printprobs()"><img src="'+printer+'" border="0" alt="[print table]"></a><\/tr>')
//  document.writeln(' <tr><th colspan=5 bgcolor="yellow">Year following fire</th></tr>')
//  document.writeln(' <tr><th bgcolor="yellow">1st year<th bgcolor="yellow">2nd year<th bgcolor="yellow">3rd year<th bgcolor="yellow">4th year<th bgcolor="yellow">5th year</tr>')
////<!-- untreated -->
//  document.writeln(' <tr><th bgcolor="yellow" align="right">Untreated <a href="javascript:showtable(\'cp\',\'no_mit\',\'No mitigation\')"><img src="'+printer+'" border=0></a>&nbsp;<\/th>')
//  probs = rounder(whatprob (seds/js_sedconv, eval('cp0'))*100,2)
//  document.writeln('  <th><input type="text" name="probability0" size="8" onFocus="self.blur()" value='+probs+' disabled>')
//  probs = rounder(whatprob (seds/js_sedconv, eval('cp1'))*100,2)
//  document.writeln('  <th><input type="text" name="probability1" size="8" onFocus="self.blur()" value='+probs+' disabled>')
//  probs = rounder(whatprob (seds/js_sedconv, eval('cp2'))*100,2)
//  document.writeln('  <th><input type="text" name="probability2" size="8" onFocus="self.blur()" value='+probs+' disabled>')
//  probs = rounder(whatprob (seds/js_sedconv, eval('cp3'))*100,2)
//  document.writeln('  <th><input type="text" name="probability3" size="8" onFocus="self.blur()" value='+probs+' disabled>')
//  probs = rounder(whatprob (seds/js_sedconv, eval('cp4'))*100,2)
//  document.writeln('  <th><input type="text" name="probability4" size="8" onFocus="self.blur()" value='+probs+' disabled>')
//  document.writeln(' <\/tr>')
////<!-- seeding -->
//  document.writeln(' <tr><th bgcolor="yellow" align="right">Seeding after fire <a href="javascript:showtable(\'cp_s\',\'seed\',\'Seeding after fire\')"><img src="'+printer+'" border=0></a>&nbsp;<\/th>')
//  probs = rounder(whatprob (seds/js_sedconv, eval('cp_s0'))*100,2)
//  document.writeln('  <th><input type="text" name="probability_s0" size="8" onFocus="self.blur()" value='+probs+' disabled>')
//  probs = rounder(whatprob (seds/js_sedconv, eval('cp_s1'))*100,2)
//  document.writeln('   <th><input type="text" name="probability_s1" size="8" onFocus="self.blur()" value='+probs+' disabled>')
//  probs = rounder(whatprob (seds/js_sedconv, eval('cp_s2'))*100,2)
//  document.writeln('   <th><input type="text" name="probability_s2" size="8" onFocus="self.blur()" value='+probs+' disabled>')
//  probs = rounder(whatprob (seds/js_sedconv, eval('cp_s3'))*100,2)
//  document.writeln('    <th><input type="text" name="probability_s3" size="8" onFocus="self.blur()" value='+probs+' disabled>')
//  probs = rounder(whatprob (seds/js_sedconv, eval('cp_s4'))*100,2)
//  document.writeln('    <th><input type="text" name="probability_s4" size="8" onFocus="self.blur()" value='+probs+' disabled>')
//  document.writeln('  <\/tr>')
////<!-- mulch half -->
  mulchrate = '0.5'
  if (js_units == 'ft') mulchrate = '0.2'
  mulch1  = 'Mulch rate '+mulchrate+' '+js_sedunits
  mulch1a = 'Mulch rate '+mulchrate+' '+js_alt_sedunits
//  document.writeln(' <tr><th bgcolor="yellow" align="right">'+mulch1+' <a href="javascript:showtable(\'cp_mh\',\'mulch_h\',\''+mulch1a+'\')"><img src="'+printer+'" border=0></a>&nbsp;<\/th>')
////  mulch1 = 'Mulch rate 0.5 t ha<sup>-1</sup>'
////  if (units == 'ft') mulch1 = 'Mulch rate 0.2 t ac<sup>-1</sup>'
////  document.writeln(' <tr><th bgcolor="yellow" align="right">'+mulch1+' <a href="javascript:showtable(\'cp_mh\',\'mulch_h\',\''+mulch1+'\')"><img src="'+printer+'" border=0></a> <\/th>')
////  document.writeln(' <tr><th bgcolor="yellow" align="right">Mulch rate 0.5 t ha<sup>-1</sup> <a href="javascript:showtable(\'cp_mh\',\'mulch_h\',\'Mulch rate 0.5 t ha<sup>-1</sup>\')"><img src="'+printer+'" border=0></a> <\/th>')
//  probs = rounder(whatprob (seds/js_sedconv, eval('cp_mh0'))*100,2)
//  document.writeln('    <th><input type="text" name="probability_mh0" size="8" onFocus="self.blur()" value='+probs+' disabled>')
//  probs = rounder(whatprob (seds/js_sedconv, eval('cp_mh1'))*100,2)
//  document.writeln('    <th> <input type="text" name="probability_mh1" size="8" onFocus="self.blur()" value='+probs+' disabled>')
//  probs = rounder(whatprob (seds/js_sedconv, eval('cp_mh2'))*100,2)
//  document.writeln('    <th> <input type="text" name="probability_mh2" size="8" onFocus="self.blur()" value='+probs+' disabled>')
//  probs = rounder(whatprob (seds/js_sedconv, eval('cp_mh3'))*100,2)
//  document.writeln('    <th> <input type="text" name="probability_mh3" size="8" onFocus="self.blur()" value='+probs+' disabled>')
//  probs = rounder(whatprob (seds/js_sedconv, eval('cp_mh4'))*100,2)
//  document.writeln('    <th> <input type="text" name="probability_mh4" size="8" onFocus="self.blur()" value='+probs+' disabled>')
//  document.writeln('  <\/tr>')
////<!-- mulch one -->
  mulchrate = '1.0'
  if (js_units == 'ft') mulchrate = '0.4'
  mulch2  = 'Mulch rate '+mulchrate+' '+js_sedunits
  mulch2a = 'Mulch rate '+mulchrate+' '+js_alt_sedunits
//  document.writeln(' <tr><th bgcolor="yellow" align="right">'+mulch2+' <a href="javascript:showtable(\'cp_mo\',\'mulch_o\',\''+mulch2a+'\')"><img src="'+printer+'" border=0></a>&nbsp;<\/th>')
////  document.writeln(' <tr><th bgcolor="yellow" align="right">Mulch rate 1.0 t ha<sup>-1</sup> <a href="javascript:showtable(\'cp_mo\',\'mulch_o\',\'Mulch rate 1.0 t/ha\')"><img src="'+printer+'" border=0></a> <\/th>')
//  probs = rounder(whatprob (seds/js_sedconv, eval('cp_mo0'))*100,2)
//  document.writeln('    <th> <input type="text" name="probability_mo0" size="8" onFocus="self.blur()" value='+probs+' disabled>')
//  probs = rounder(whatprob (seds/js_sedconv, eval('cp_mo1'))*100,2)
//  document.writeln('    <th> <input type="text" name="probability_mo1" size="8" onFocus="self.blur()" value='+probs+' disabled>')
//  probs = rounder(whatprob (seds/js_sedconv, eval('cp_mo2'))*100,2)
//  document.writeln('    <th> <input type="text" name="probability_mo2" size="8" onFocus="self.blur()" value='+probs+' disabled>')
//  probs = rounder(whatprob (seds/js_sedconv, eval('cp_mo3'))*100,2)
//  document.writeln('    <th> <input type="text" name="probability_mo3" size="8" onFocus="self.blur()" value='+probs+' disabled>')
//  probs = rounder(whatprob (seds/js_sedconv, eval('cp_mo4'))*100,2)
//  document.writeln('    <th> <input type="text" name="probability_mo4" size="8" onFocus="self.blur()" value='+probs+' disabled>')
//  document.writeln('  <\/tr>')
////<!-- mulch one and a half -->
  mulchrate = '1.5'
  if (js_units == 'ft') mulchrate = '0.7'
  mulch3  = 'Mulch rate '+mulchrate+' '+js_sedunits
  mulch3a = 'Mulch rate '+mulchrate+' '+js_alt_sedunits
//  document.writeln(' <tr><th bgcolor="yellow" align="right">'+mulch3+' <a href="javascript:showtable(\'cp_moh\',\'mulch_oh\',\''+mulch3a+'\')"><img src="'+printer+'" border=0></a>&nbsp;<\/th>')
////  document.writeln(' <tr><th bgcolor="yellow" align="right">Mulch rate 1.5 t ha<sup>-1</sup> <a href="javascript:showtable(\'cp_moh\',\'mulch_oh\',\'Mulch rate 1.5 t/ha\')"><img src="'+printer+'" border=0></a> <\/th>')
//  probs = rounder(whatprob (seds/js_sedconv, eval('cp_moh0'))*100,2)
//  document.writeln('    <th> <input type="text" name="probability_moh0" size="8" onFocus="self.blur()" value='+probs+' disabled>')
//  probs = rounder(whatprob (seds/js_sedconv, eval('cp_moh1'))*100,2)
//  document.writeln('    <th> <input type="text" name="probability_moh1" size="8" onFocus="self.blur()" value='+probs+' disabled>')
//  probs = rounder(whatprob (seds/js_sedconv, eval('cp_moh2'))*100,2)
//  document.writeln('    <th> <input type="text" name="probability_moh2" size="8" onFocus="self.blur()" value='+probs+' disabled>')
//  probs = rounder(whatprob (seds/js_sedconv, eval('cp_moh3'))*100,2)
//  document.writeln('    <th> <input type="text" name="probability_moh3" size="8" onFocus="self.blur()" value='+probs+' disabled>')
//  probs = rounder(whatprob (seds/js_sedconv, eval('cp_moh4'))*100,2)
//  document.writeln('    <th> <input type="text" name="probability_moh4" size="8" onFocus="self.blur()" value='+probs+' disabled>')
//  document.writeln('  <\/tr>')
////<!-- mulch two -->
  mulchrate = '2.0'
  if (js_units == 'ft') mulchrate = '0.9'
  mulch4  = 'Mulch rate '+mulchrate+' '+js_sedunits
  mulch4a = 'Mulch rate '+mulchrate+' '+js_alt_sedunits
//  document.writeln(' <tr><th bgcolor="yellow" align="right">'+mulch4+' <a href="javascript:showtable(\'cp_mt\',\'mulch_t\',\''+mulch4a+'\')"><img src="'+printer+'" border=0></a>&nbsp;<\/th>')
////  document.writeln(' <tr><th bgcolor="yellow" align="right">Mulch rate 2.0 t ha<sup>-1</sup> <a href="javascript:showtable(\'cp_mt\',\'mulch_t\',\'Mulch rate 2.0 t ha<sup>-1</sup>\')"><img src="'+printer+'" border=0></a>&nbsp;<\/th>')
//  probs = rounder(whatprob (seds/js_sedconv, eval('cp_mt0'))*100,2)
//  document.writeln('    <th> <input type="text" name="probability_mt0" size="8" onFocus="self.blur()" value='+probs+' disabled>')
//  probs = rounder(whatprob (seds/js_sedconv, eval('cp_mt1'))*100,2)
//  document.writeln('    <th> <input type="text" name="probability_mt1" size="8" onFocus="self.blur()" value='+probs+' disabled>')
//  probs = rounder(whatprob (seds/js_sedconv, eval('cp_mt2'))*100,2)
//  document.writeln('    <th> <input type="text" name="probability_mt2" size="8" onFocus="self.blur()" value='+probs+' disabled>')
//  probs = rounder(whatprob (seds/js_sedconv, eval('cp_mt3'))*100,2)
//  document.writeln('    <th> <input type="text" name="probability_mt3" size="8" onFocus="self.blur()" value='+probs+' disabled>')
//  probs = rounder(whatprob (seds/js_sedconv, eval('cp_mt4'))*100,2)
//  document.writeln('    <th> <input type="text" name="probability_mt4" size="8" onFocus="self.blur()" value='+probs+' disabled>')
//  document.writeln(' <\/tr>')

// 2004.03.18 DEH end change

// unit conversions!!

//<!-- contour-felled logs -->

//  document.writeln(' <tr><th bgcolor="yellow"><a href="javascript:showlogtable()">Logs &amp; Wattles</a><\/th>')
//  probs = rounder(whatprobcl (seds/js_sedconv, eval('cp0'))*100,2)
//  document.writeln('  <th><input type="text" name="probability_cl0" size="8" onFocus="self.blur()" value='+probs+'>')
//  probs = rounder(whatprobcl (seds/js_sedconv, eval('cp1'))*100,2)
//  document.writeln('  <th><input type="text" name="probability_cl1" size="8" onFocus="self.blur()" value='+probs+'>')
//  probs = rounder(whatprobcl (seds/js_sedconv, eval('cp2'))*100,2)
//  document.writeln('  <th><input type="text" name="probability_cl2" size="8" onFocus="self.blur()" value='+probs+'>')
//  probs = rounder(whatprobcl (seds/js_sedconv, eval('cp3'))*100,2)
//  document.writeln('  <th><input type="text" name="probability_cl3" size="8" onFocus="self.blur()" value='+probs+'>')
//  probs = rounder(whatprobcl (seds/js_sedconv, eval('cp4'))*100,2)
//  document.writeln('  <th><input type="text" name="probability_cl4" size="8" onFocus="self.blur()" value='+probs+'>')
//  document.writeln(' <\/tr>')

// 2004.03.18 DEH start change again

//  document.writeln(' <\/table>')

//  document.writeln(' <br><br>')

// 2004.03.18 DEH end change again

// Target chance event sediment delivery will be exceeded

  document.writeln(' <table border=1>')
  document.writeln('  <tr><th rowspan=3 bgcolor="gold">Target chance<br>event sediment delivery<br>will be exceeded<br>')
  document.writeln('    <input type="text" name="probability0x" onChange="javascript:probchange()" value="10" size="6"> %&nbsp;&nbsp;&nbsp;<img src="'+gostone+'">')
  document.writeln(' <th colspan=5 bgcolor="yellow">Event sediment delivery ('+js_sedunits+')&nbsp;&nbsp;&nbsp;')
  document.writeln('   <a href="javascript:printseds()"><img src="'+printer+'" border="0" alt="[print table]"><\/a><\/th><\/tr>')
  document.writeln(' <tr><th colspan=5 bgcolor="yellow">Year following fire</th></tr>')
  document.writeln(' <tr><th bgcolor="yellow">1st year<th bgcolor="yellow">2nd year<th bgcolor="yellow">3rd year<th bgcolor="yellow">4th year<th bgcolor="yellow">5th year</tr>')
//<!-- untreated -->
  document.writeln(' <tr><th bgcolor="yellow" align="right">Untreated <a href="javascript:showtable(\'cp\',\'no_mit\',\'No mitigation\')"><img src="'+printer+'" border=0><\/a>&nbsp;<\/th>')
  seds = rounder(whatseds (0.1, cp0)*js_sedconv,2)
  document.writeln('  <th><input type="text" name="sediment0" size="8" onFocus="self.blur()" value='+seds+' disabled>')
  seds = rounder(whatseds (0.1, cp1)*js_sedconv,2)
  document.writeln('  <th><input type="text" name="sediment1" size="8" onFocus="self.blur()" value='+seds+' disabled>')
  seds = rounder(whatseds (0.1, cp2)*js_sedconv,2)
  document.writeln('  <th><input type="text" name="sediment2" size="8" onFocus="self.blur()" value='+seds+' disabled>')
  seds = rounder(whatseds (0.1, cp3)*js_sedconv,2)
  document.writeln('  <th><input type="text" name="sediment3" size="8" onFocus="self.blur()" value='+seds+' disabled>')
  seds = rounder(whatseds (0.1, cp4)*js_sedconv,2)
  document.writeln('  <th><input type="text" name="sediment4" size="8" onFocus="self.blur()" value='+seds+' disabled><\/tr>')
//<!-- seeding -->
  document.writeln(' <tr><th bgcolor="yellow" align="right">Seeding <a href="javascript:showtable(\'cp_s\',\'seed\',\'Seeding after fire\')"><img src="'+printer+'" border=0><\/a>&nbsp;<\/th>')
  seds = rounder(whatseds (0.1, cp_s0)*js_sedconv,2)
  document.writeln('  <th><input type="text" name="sediment_s0" size="8" onFocus="self.blur()" value='+seds+' disabled>')
  seds = rounder(whatseds (0.1, cp_s1)*js_sedconv,2)
  document.writeln('   <th><input type="text" name="sediment_s1" size="8" onFocus="self.blur()" value='+seds+' disabled>')
  seds = rounder(whatseds (0.1, cp_s2)*js_sedconv,2)
  document.writeln('   <th><input type="text" name="sediment_s2" size="8" onFocus="self.blur()" value='+seds+' disabled>')
  seds = rounder(whatseds (0.1, cp_s3)*js_sedconv,2)
  document.writeln('    <th><input type="text" name="sediment_s3" size="8" onFocus="self.blur()" value='+seds+' disabled>')
  seds = rounder(whatseds (0.1, cp_s4)*js_sedconv,2)
  document.writeln('    <th><input type="text" name="sediment_s4" size="8" onFocus="self.blur()" value='+seds+' disabled><\/tr>')
//<!-- mulch half -->
  document.writeln(' <tr><th bgcolor="yellow" align="right">'+mulch1+' <a href="javascript:showtable(\'cp_mh\',\'mulch_h\',\''+mulch1a+'\')"><img src="'+printer+'" border=0><\/a>&nbsp;<\/th>')
//  document.writeln(' <tr><th bgcolor="yellow" align="right">Mulch rate 0.5 t ha<sup>-1</sup> <img src="'+printer+'" border=0><\/a>&nbsp;<\/th>')
  seds = rounder(whatseds (0.1, cp_mh0)*js_sedconv,2)
  document.writeln('    <th><input type="text" name="sediment_mh0" size="8" onFocus="self.blur()" value='+seds+' disabled>')
  seds = rounder(whatseds (0.1, cp_mh1)*js_sedconv,2)
  document.writeln('    <th><input type="text" name="sediment_mh1" size="8" onFocus="self.blur()" value='+seds+' disabled>')
  seds = rounder(whatseds (0.1, cp_mh2)*js_sedconv,2)
  document.writeln('    <th><input type="text" name="sediment_mh2" size="8" onFocus="self.blur()" value='+seds+' disabled>')
  seds = rounder(whatseds (0.1, cp_mh3)*js_sedconv,2)
  document.writeln('    <th><input type="text" name="sediment_mh3" size="8" onFocus="self.blur()" value='+seds+' disabled>')
  seds = rounder(whatseds (0.1, cp_mh4)*js_sedconv,2)
  document.writeln('    <th><input type="text" name="sediment_mh4" size="8" onFocus="self.blur()" value='+seds+' disabled><\/tr>')
//<!-- mulch one -->
  document.writeln(' <tr><th bgcolor="yellow" align="right">'+mulch2+' <a href="javascript:showtable(\'cp_mo\',\'mulch_o\',\''+mulch2a+'\')"><img src="'+printer+'" border=0><\/a>&nbsp;<\/th>')
//  document.writeln(' <tr><th bgcolor="yellow" align="right">Mulch rate 1.0 t ha<sup>-1</sup> <img src="'+printer+'" border=0><\/a>&nbsp;<\/th>')
  seds = rounder(whatseds (0.1, cp_mo0)*js_sedconv,2)
  document.writeln('    <th><input type="text" name="sediment_mo0" size="8" onFocus="self.blur()" value='+seds+' disabled>')
  seds = rounder(whatseds (0.1, cp_mo1)*js_sedconv,2)
  document.writeln('    <th><input type="text" name="sediment_mo1" size="8" onFocus="self.blur()" value='+seds+' disabled>')
  seds = rounder(whatseds (0.1, cp_mo2)*js_sedconv,2)
  document.writeln('    <th><input type="text" name="sediment_mo2" size="8" onFocus="self.blur()" value='+seds+' disabled>')
  seds = rounder(whatseds (0.1, cp_mo3)*js_sedconv,2)
  document.writeln('    <th><input type="text" name="sediment_mo3" size="8" onFocus="self.blur()" value='+seds+' disabled>')
  seds = rounder(whatseds (0.1, cp_mo4)*js_sedconv,2)
  document.writeln('    <th><input type="text" name="sediment_mo4" size="8" onFocus="self.blur()" value='+seds+' disabled><\/tr>')
//<!-- mulch one and a half -->
  document.writeln(' <tr><th bgcolor="yellow" align="right">'+mulch3+' <a href="javascript:showtable(\'cp_moh\',\'mulch_oh\',\''+mulch3a+'\')"><img src="'+printer+'" border=0><\/a>&nbsp;<\/th>')
//  document.writeln(' <tr><th bgcolor="yellow" align="right">Mulch rate 1.5 t ha<sup>-1</sup> <img src="'+printer+'" border=0><\/a>&nbsp;<\/th>')
  seds = rounder(whatseds (0.1, cp_moh0)*js_sedconv,2)
  document.writeln('    <th><input type="text" name="sediment_moh0" size="8" onFocus="self.blur()" value='+seds+' disabled>')
  seds = rounder(whatseds (0.1, cp_moh1)*js_sedconv,2)
  document.writeln('    <th><input type="text" name="sediment_moh1" size="8" onFocus="self.blur()" value='+seds+' disabled>')
  seds = rounder(whatseds (0.1, cp_moh2)*js_sedconv,2)
  document.writeln('    <th><input type="text" name="sediment_moh2" size="8" onFocus="self.blur()" value='+seds+' disabled>')
  seds = rounder(whatseds (0.1, cp_moh3)*js_sedconv,2)
  document.writeln('    <th><input type="text" name="sediment_moh3" size="8" onFocus="self.blur()" value='+seds+' disabled>')
  seds = rounder(whatseds (0.1, cp_moh4)*js_sedconv,2)
  document.writeln('    <th><input type="text" name="sediment_moh4" size="8" onFocus="self.blur()" value='+seds+' disabled><\/tr>')
//<!-- mulch two -->
  document.writeln(' <tr><th bgcolor="yellow" align="right">'+mulch4+' <a href="javascript:showtable(\'cp_mt\',\'mulch_t\',\''+mulch4a+'\')"><img src="'+printer+'" border=0><\/a>&nbsp;<\/th>')
//  document.writeln(' <tr><th bgcolor="yellow" align="right">Mulch rate 2.0 t ha<sup>-1</sup> <img src="'+printer+'" border=0><\/a>&nbsp;<\/th>')
  seds = rounder(whatseds (0.1, cp_mt0)*js_sedconv,2)
  document.writeln('    <th><input type="text" name="sediment_mt0" size="8" onFocus="self.blur()" value='+seds+' disabled>')
  seds = rounder(whatseds (0.1, cp_mt1)*js_sedconv,2)
  document.writeln('    <th><input type="text" name="sediment_mt1" size="8" onFocus="self.blur()" value='+seds+' disabled>')
  seds = rounder(whatseds (0.1, cp_mt2)*js_sedconv,2)
  document.writeln('    <th><input type="text" name="sediment_mt2" size="8" onFocus="self.blur()" value='+seds+' disabled>')
  seds = rounder(whatseds (0.1, cp_mt3)*js_sedconv,2)
  document.writeln('    <th><input type="text" name="sediment_mt3" size="8" onFocus="self.blur()" value='+seds+' disabled>')
  seds = rounder(whatseds (0.1, cp_mt4)*js_sedconv,2)
  document.writeln('    <th><input type="text" name="sediment_mt4" size="8" onFocus="self.blur()" value='+seds+' disabled><\/tr>')

// unit conversions!!

//<!-- contour-felled logs -->

//  document.writeln(' <tr><th bgcolor="yellow">Logs &amp; Wattles<\/th>')
//  seds = document.doit.sediment0.value
//  if (seds < twocap) {seds = seds / 2}  else {seds = seds - capacity}
//  document.writeln('  <th><input type="text" name="sediment_cl0" size="8" onFocus="self.blur()" value='+seds+'>')
//  seds = document.doit.sediment1.value
//  if (seds < twocap) {seds = seds / 2}  else {seds = seds - capacity}
//  document.writeln('  <th><input type="text" name="sediment_cl1" size="8" onFocus="self.blur()" value='+seds+'>')
//  seds = document.doit.sediment2.value
//  if (seds < twocap) {seds = seds / 2}  else {seds = seds - capacity}
//  document.writeln('  <th><input type="text" name="sediment_cl2" size="8" onFocus="self.blur()" value='+seds+'>')
//  seds = document.doit.sediment3.value
//  if (seds < twocap) {seds = seds / 2}  else {seds = seds - capacity}
//  document.writeln('  <th><input type="text" name="sediment_cl3" size="8" onFocus="self.blur()" value='+seds+'>')
//  seds = document.doit.sediment4.value
//  if (seds < twocap) {seds = seds / 2}  else {seds = seds - capacity}
//  document.writeln('  <th><input type="text" name="sediment_cl4" size="8" onFocus="self.blur()" value='+seds+'><\/tr>')
  document.writeln(' <\/table>')
 </script>
   </form>
<br>
  </center>
<p>
EOP2
print '
  <form><input type="submit" value="Return to input screen" onclick="JavaScript:window.history.go(-1); return false;"></form>
   </center>
  <p>
  <hr>
<a href="http://forest.moscowfsl.wsu.edu/fswepp/comments.html"><img src="http://'.$wepphost.'/fswepp/images/epaemail.gif" align="right" border=0></a>
ERMiT v. ',$version,' (for review only). 
<b>Pete Robichaud</b> and <b>Bill Elliot</b><br>
USDA Forest Service, Rocky Mountain Research Station, Moscow, ID 83843<br>
 </body>
</html>
';

#welog welog welog

   if (lc($wepphost) ne "localhost") {
     open WELOG, ">>../working/we.log";
       print WELOG "$host\t";
       printf WELOG "%0.2d:%0.2d ", $hour, $min;
       print  WELOG $ampm[$ampmi],"  ",$days[$wday]," ",$months[$mon]," ",$mday, ", ",$thissyear,"\t";
       print  WELOG "$climate_name\n";
     close WELOG;
   }

  # unlink

  if ($debug) {}
  else {
    unlink $soilfile;
    unlink $tempfile;
    unlink $slopefile;
    unlink $evo_file;
    unlink $shortCLIfile;
    unlink $responseFile;
    unlink $ev_by_evFile;
    unlink $crspfile;
    unlink $stoutfile;
    unlink $outputfile;
    unlink $gnuplotdatafile;
    unlink $gnuplotjclfile;

    unlink $workingpath . '.cli';
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

#                         E V E N T                   A N N U A L
#                   __________________ 		 __________________ 
#		s1 |	              |		|                  |
#               s2 |                  |		|                  |
#    C50        s3 |                  |		|                  |
#               s4 |__________________|		|__________________|
#                   k1  k2  k3  k4  k5 		 k1  k2  k3  k4  k5
#
#
#                   __________________ 		 __________________ 
#		s1 |	              |		|                  |
#               s2 |                  |		|                  |
#    C20        s3 |                  |		|                  |
#               s4 |__________________|		|__________________|
#                   k1  k2  k3  k4  k5 		 k1  k2  k3  k4  k5
#
#                   __________________ 		 __________________ 
#		s1 |	              |		|                  |
#               s2 |                  |		|                  |
#    C10        s3 |                  |		|                  |
#               s4 |__________________|		|__________________|
#                   k1  k2  k3  k4  k5 		 k1  k2  k3  k4  k5
#
#                   __________________ 		 __________________ 
#		s1 |	              |		|                  |
#               s2 |                  |		|                  |
#    C05        s3 |                  |		|                  |
#               s4 |__________________|		|__________________|
#                   k1  k2  k3  k4  k5 		 k1  k2  k3  k4  k5


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
# Slope file created for fire severity $s average gradient $avg_slope toe gradient $toe_slope
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
# Slope file created for fire severity $s average gradient $avg_slope toe gradient $toe_slope
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
# Slope file created for fire severity $s average gradient $avg_slope toe gradient $toe_slope
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
# Slope file created for fire severity $s average gradient $avg_slope toe gradient $toe_slope
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

sed_del = new MakeArray; sed_del.length = 80
// no mitigation
cp0 = new MakeArray; cp0.length = 80
cp1 = new MakeArray; cp1.length = 80
cp2 = new MakeArray; cp2.length = 80
cp3 = new MakeArray; cp3.length = 80
cp4 = new MakeArray; cp4.length = 80
// seeding
cp_s0 = new MakeArray; cp_s0.length = 80
cp_s1 = new MakeArray; cp_s1.length = 80
cp_s2 = new MakeArray; cp_s2.length = 80
cp_s3 = new MakeArray; cp_s3.length = 80
cp_s4 = new MakeArray; cp_s4.length = 80
// mulch 0.5
cp_mh0 = new MakeArray; cp_mh0.length = 80
cp_mh1 = new MakeArray; cp_mh1.length = 80
cp_mh2 = new MakeArray; cp_mh2.length = 80
cp_mh3 = new MakeArray; cp_mh3.length = 80
cp_mh4 = new MakeArray; cp_mh4.length = 80
// mulch 1.0
cp_mo0 = new MakeArray; cp_mo0.length = 80
cp_mo1 = new MakeArray; cp_mo1.length = 80
cp_mo2 = new MakeArray; cp_mo2.length = 80
cp_mo3 = new MakeArray; cp_mo3.length = 80
cp_mo4 = new MakeArray; cp_mo4.length = 80
// mulch 1.5
cp_moh0 = new MakeArray; cp_moh0.length = 80
cp_moh1 = new MakeArray; cp_moh1.length = 80
cp_moh2 = new MakeArray; cp_moh2.length = 80
cp_moh3 = new MakeArray; cp_moh3.length = 80
cp_moh4 = new MakeArray; cp_moh4.length = 80
// mulch 2
cp_mt0 = new MakeArray; cp_mt0.length = 80
cp_mt1 = new MakeArray; cp_mt1.length = 80
cp_mt2 = new MakeArray; cp_mt2.length = 80
cp_mt3 = new MakeArray; cp_mt3.length = 80
cp_mt4 = new MakeArray; cp_mt4.length = 80
';

# ###   DEH 2003/03/05 add variables to pass from perl to Javascript functions

#  $climate_name =~ s/^\s*(.*?)\s*$/$1/;    # strip whitespace 
  print "
   js_climate_name = '$climate_name'
   js_soil_texture = '$soil_texture';
   js_rfg = $rfg;
   js_top_slope = $top_slope
   js_avg_slope = $avg_slope
   js_toe_slope = $toe_slope
   js_hillslope_length = $hillslope_length
   js_units = '$units'
   js_severityclass_x = '$severityclass_x'
   js_sedunits = '$sedunits'
   js_alt_sedunits = '$alt_sedunits'
   printer='http://$wepphost/fswepp/images/hinduonnet_print2.png'
   gostone='http://$wepphost/fswepp/images/go.gif'
";
   if ($units eq 'm') {print '   js_sedconv = ' . 10 / $hillslope_length,"\n"}
   else {print '   js_sedconv = ' . 4.45 / $hillslope_length_m,"\n"}

# ###

  $cum_prob0    = 0; $cum_prob1    = 0; $cum_prob2    = 0; $cum_prob3    = 0; $cum_prob4  = 0;
  $cum_prob_s0  = 0; $cum_prob_s1  = 0; $cum_prob_s2  = 0; $cum_prob_s3  = 0; $cum_prob_s4 = 0;
  $cum_prob_mh0 = 0; $cum_prob_mh1 = 0; $cum_prob_mh2 = 0; $cum_prob_mh3 = 0; $cum_prob_mh4 = 0;
  $cum_prob_mo0 = 0; $cum_prob_mo1 = 0; $cum_prob_mo2 = 0; $cum_prob_mo3 = 0; $cum_prob_mo4 = 0;
  $cum_prob_moh0= 0; $cum_prob_moh1= 0; $cum_prob_moh2= 0; $cum_prob_moh3= 0; $cum_prob_moh4 = 0;
  $cum_prob_mt0 = 0; $cum_prob_mt1 = 0; $cum_prob_mt2 = 0; $cum_prob_mt3 = 0; $cum_prob_mt4 = 0;

#  for $i (0..$#sed_yields) {
  for $i (0..79) {
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
# mulch 0.5
    $cum_prob_mh0 += @probabilities_mh0[@index[$i]];
    $cum_prob_mh1 += @probabilities_mh1[@index[$i]];
    $cum_prob_mh2 += @probabilities_mh2[@index[$i]];
    $cum_prob_mh3 += @probabilities_mh3[@index[$i]];
    $cum_prob_mh4 += @probabilities_mh4[@index[$i]];
    
# mulch 1
    $cum_prob_mo0 += @probabilities_mo0[@index[$i]];
    $cum_prob_mo1 += @probabilities_mo1[@index[$i]];
    $cum_prob_mo2 += @probabilities_mo2[@index[$i]];
    $cum_prob_mo3 += @probabilities_mo3[@index[$i]];
    $cum_prob_mo4 += @probabilities_mo4[@index[$i]];
# mulch 1.5
    $cum_prob_moh0 += @probabilities_moh0[@index[$i]];
    $cum_prob_moh1 += @probabilities_moh1[@index[$i]];
    $cum_prob_moh2 += @probabilities_moh2[@index[$i]];
    $cum_prob_moh3 += @probabilities_moh3[@index[$i]];
    $cum_prob_moh4 += @probabilities_moh4[@index[$i]];
# mulch 2.0
    $cum_prob_mt0 += @probabilities_mt0[@index[$i]];
    $cum_prob_mt1 += @probabilities_mt1[@index[$i]];
    $cum_prob_mt2 += @probabilities_mt2[@index[$i]];
    $cum_prob_mt3 += @probabilities_mt3[@index[$i]];
    $cum_prob_mt4 += @probabilities_mt4[@index[$i]];
    $j = $i + 1;
    $sedval = @sed_yields[@index[$i]];
    if ($sedval eq '') {$sedval = '0.0'}
    print "sed_del[$j] = $sedval;  ";

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

    print "  cp_mh0[$j] = $cum_prob_mh0; ";
    print "  cp_mh1[$j] = $cum_prob_mh1; ";
    print "  cp_mh2[$j] = $cum_prob_mh2; ";
    print "  cp_mh3[$j] = $cum_prob_mh3; ";
    print "  cp_mh4[$j] = $cum_prob_mh4\n";

    print "  cp_mo0[$j] = $cum_prob_mo0; ";
    print "  cp_mo1[$j] = $cum_prob_mo1; ";
    print "  cp_mo2[$j] = $cum_prob_mo2; ";
    print "  cp_mo3[$j] = $cum_prob_mo3; ";
    print "  cp_mo4[$j] = $cum_prob_mo4\n";

    print "  cp_moh0[$j] = $cum_prob_moh0; ";
    print "  cp_moh1[$j] = $cum_prob_moh1; ";
    print "  cp_moh2[$j] = $cum_prob_moh2; ";
    print "  cp_moh3[$j] = $cum_prob_moh3; ";
    print "  cp_moh4[$j] = $cum_prob_moh4\n";

    print "  cp_mt0[$j] = $cum_prob_mt0; ";
    print "  cp_mt1[$j] = $cum_prob_mt1; ";
    print "  cp_mt2[$j] = $cum_prob_mt2; ";
    print "  cp_mt3[$j] = $cum_prob_mt3; ";
    print "  cp_mt4[$j] = $cum_prob_mt4\n";
  }

print <<'EOP';

function whatseds (n, array) {

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

  sedchange()
   probchange()

}

function sedchange () {

  var sed_del_min = rounder(sed_del[80]*js_sedconv,2)
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

    document.doit.probability_mh0.value = rounder(whatprob(sedval/js_sedconv, eval('cp_mh0'))*100,2)
    document.doit.probability_mh1.value = rounder(whatprob(sedval/js_sedconv, eval('cp_mh1'))*100,2)
    document.doit.probability_mh2.value = rounder(whatprob(sedval/js_sedconv, eval('cp_mh2'))*100,2)
    document.doit.probability_mh3.value = rounder(whatprob(sedval/js_sedconv, eval('cp_mh3'))*100,2)
    document.doit.probability_mh4.value = rounder(whatprob(sedval/js_sedconv, eval('cp_mh4'))*100,2)

    document.doit.probability_mo0.value = rounder(whatprob(sedval/js_sedconv, eval('cp_mo0'))*100,2)
    document.doit.probability_mo1.value = rounder(whatprob(sedval/js_sedconv, eval('cp_mo1'))*100,2)
    document.doit.probability_mo2.value = rounder(whatprob(sedval/js_sedconv, eval('cp_mo2'))*100,2)
    document.doit.probability_mo3.value = rounder(whatprob(sedval/js_sedconv, eval('cp_mo3'))*100,2)
    document.doit.probability_mo4.value = rounder(whatprob(sedval/js_sedconv, eval('cp_mo4'))*100,2)

    document.doit.probability_moh0.value = rounder(whatprob(sedval/js_sedconv, eval('cp_moh0'))*100,2)
    document.doit.probability_moh1.value = rounder(whatprob(sedval/js_sedconv, eval('cp_moh1'))*100,2)
    document.doit.probability_moh2.value = rounder(whatprob(sedval/js_sedconv, eval('cp_moh2'))*100,2)
    document.doit.probability_moh3.value = rounder(whatprob(sedval/js_sedconv, eval('cp_moh3'))*100,2)
    document.doit.probability_moh4.value = rounder(whatprob(sedval/js_sedconv, eval('cp_moh4'))*100,2)

    document.doit.probability_mt0.value = rounder(whatprob(sedval/js_sedconv, eval('cp_mt0'))*100,2)
    document.doit.probability_mt1.value = rounder(whatprob(sedval/js_sedconv, eval('cp_mt1'))*100,2)
    document.doit.probability_mt2.value = rounder(whatprob(sedval/js_sedconv, eval('cp_mt2'))*100,2)
    document.doit.probability_mt3.value = rounder(whatprob(sedval/js_sedconv, eval('cp_mt3'))*100,2)
    document.doit.probability_mt4.value = rounder(whatprob(sedval/js_sedconv, eval('cp_mt4'))*100,2)

    document.doit.probability_cl0.value = rounder(whatprobcl(sedval/js_sedconv, eval('cp0'))*100,2)
    document.doit.probability_cl1.value = rounder(whatprobcl(sedval/js_sedconv, eval('cp1'))*100,2)
    document.doit.probability_cl2.value = rounder(whatprobcl(sedval/js_sedconv, eval('cp2'))*100,2)
    document.doit.probability_cl3.value = rounder(whatprobcl(sedval/js_sedconv, eval('cp3'))*100,2)
    document.doit.probability_cl4.value = rounder(whatprobcl(sedval/js_sedconv, eval('cp4'))*100,2)

//  printprobs()

}

function probchange () {

  var myprob=document.doit.probability0x.value
  if (!isNumber (myprob)) {myprob = 10}
  if (myprob < 0.1)       {myprob = .1}
  if (myprob > 99.9)      {myprob = 99.9}
  document.doit.probability0x.value = myprob
  myprob = myprob/100

  document.doit.sediment0.value = rounder(whatseds (myprob, eval('cp0')) * js_sedconv,2)
  document.doit.sediment1.value = rounder(whatseds (myprob, eval('cp1')) * js_sedconv,2)
  document.doit.sediment2.value = rounder(whatseds (myprob, eval('cp2')) * js_sedconv,2)
  document.doit.sediment3.value = rounder(whatseds (myprob, eval('cp3')) * js_sedconv,2)
  document.doit.sediment4.value = rounder(whatseds (myprob, eval('cp4')) * js_sedconv,2)

  document.doit.sediment_s0.value = rounder(whatseds (myprob,eval('cp_s0')) * js_sedconv,2)
  document.doit.sediment_s1.value = rounder(whatseds (myprob,eval('cp_s1')) * js_sedconv,2)
  document.doit.sediment_s2.value = rounder(whatseds (myprob,eval('cp_s2')) * js_sedconv,2)
  document.doit.sediment_s3.value = rounder(whatseds (myprob,eval('cp_s3')) * js_sedconv,2)
  document.doit.sediment_s4.value = rounder(whatseds (myprob,eval('cp_s4')) * js_sedconv,2)

  document.doit.sediment_mh0.value = rounder(whatseds (myprob,eval('cp_mh0')) * js_sedconv,2)
  document.doit.sediment_mh1.value = rounder(whatseds (myprob,eval('cp_mh1')) * js_sedconv,2)
  document.doit.sediment_mh2.value = rounder(whatseds (myprob,eval('cp_mh2')) * js_sedconv,2)
  document.doit.sediment_mh3.value = rounder(whatseds (myprob,eval('cp_mh3')) * js_sedconv,2)
  document.doit.sediment_mh4.value = rounder(whatseds (myprob,eval('cp_mh4')) * js_sedconv,2)

  document.doit.sediment_mo0.value = rounder(whatseds (myprob,eval('cp_mo0')) * js_sedconv,2)
  document.doit.sediment_mo1.value = rounder(whatseds (myprob,eval('cp_mo1')) * js_sedconv,2)
  document.doit.sediment_mo2.value = rounder(whatseds (myprob,eval('cp_mo2')) * js_sedconv,2)
  document.doit.sediment_mo3.value = rounder(whatseds (myprob,eval('cp_mo3')) * js_sedconv,2)
  document.doit.sediment_mo4.value = rounder(whatseds (myprob,eval('cp_mo4')) * js_sedconv,2)

  document.doit.sediment_moh0.value = rounder(whatseds (myprob,eval('cp_moh0')) * js_sedconv,2)
  document.doit.sediment_moh1.value = rounder(whatseds (myprob,eval('cp_moh1')) * js_sedconv,2)
  document.doit.sediment_moh2.value = rounder(whatseds (myprob,eval('cp_moh2')) * js_sedconv,2)
  document.doit.sediment_moh3.value = rounder(whatseds (myprob,eval('cp_moh3')) * js_sedconv,2)
  document.doit.sediment_moh4.value = rounder(whatseds (myprob,eval('cp_moh4')) * js_sedconv,2)

  document.doit.sediment_mt0.value = rounder(whatseds (myprob,eval('cp_mt0')) * js_sedconv,2)
  document.doit.sediment_mt1.value = rounder(whatseds (myprob,eval('cp_mt1')) * js_sedconv,2)
  document.doit.sediment_mt2.value = rounder(whatseds (myprob,eval('cp_mt2')) * js_sedconv,2)
  document.doit.sediment_mt3.value = rounder(whatseds (myprob,eval('cp_mt3')) * js_sedconv,2)
  document.doit.sediment_mt4.value = rounder(whatseds (myprob,eval('cp_mt4')) * js_sedconv,2)

  document.doit.sediment_cl0.value = rounder(whatsedscl (myprob,eval('cp0')) * js_sedconv,2)
  document.doit.sediment_cl1.value = rounder(whatsedscl (myprob,eval('cp1')) * js_sedconv,2)
  document.doit.sediment_cl2.value = rounder(whatsedscl (myprob,eval('cp2')) * js_sedconv,2)
  document.doit.sediment_cl3.value = rounder(whatsedscl (myprob,eval('cp3')) * js_sedconv,2)
  document.doit.sediment_cl4.value = rounder(whatsedscl (myprob,eval('cp4')) * js_sedconv,2)

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
// display sdiment delivery vs. cumulative probability (5 years) table
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
  newin.document.writeln('<\/HEAD>')
  newin.document.writeln('<body bgcolor="ivory" onLoad="top.window.focus()">')
  newin.document.writeln('<font face="Tahoma, Arial, Helvetica, sans serif">')
  newin.document.writeln('<h3>Erosion Risk Management Tool<\/h3>')
  newin.document.writeln('<h3 align="center">'+what+'<\/h2>')
  newin.document.writeln(js_climate_name+'<br>'+js_soil_texture+'; '+js_rfg+'% rock;'+js_top_slope+' %, '+js_avg_slope+' %,'+js_toe_slope+' % slope; '+js_hillslope_length+' '+ js_units+'; '+js_severityclass_x+' severity fire')
  newin.document.writeln('<table border=1 cellpadding=5>')
  newin.document.writeln(' <tr><th rowspan=2 bgcolor=ffff99><font face="Tahoma, Arial, Helvetica, sans serif">Sediment delivery<br>('+js_alt_sedunits+')<\/th>')
  newin.document.writeln('     <th colspan=5 bgcolor=ffff99><font face="Tahoma, Arial, Helvetica, sans serif">Percent chance that sediment delivery will be exceeded<\/th><\/tr>')
  newin.document.writeln('<tr><th bgcolor=ffff99><font face="Tahoma, Arial, Helvetica, sans serif">1st year<\/th>')
  newin.document.writeln('<th bgcolor=ffff99><font face="Tahoma, Arial, Helvetica, sans serif">2nd year<\/th>')
  newin.document.writeln('<th bgcolor=ffff99><font face="Tahoma, Arial, Helvetica, sans serif">3rd year<\/th>')
  newin.document.writeln('<th bgcolor=ffff99><font face="Tahoma, Arial, Helvetica, sans serif">4th year<\/th>')
  newin.document.writeln('<th bgcolor=ffff99><font face="Tahoma, Arial, Helvetica, sans serif">5th year<\/tr>')
  for (var i=1; i<= sed_del.length; i++) {
   seddel = sed_del[i] * js_sedconv  // kg / m to t / ac or t / ha
//   if (sed_del[i] == 0) {break}
   newin.document.write(' <tr><td align=right bgcolor=ffff99><b>')
   newin.document.writeln('  <font face="Tahoma, Arial, Helvetica, sans serif">' + rounder(seddel,2)+'<\/b><\/td>')
   newin.document.writeln(' <td><font face="Tahoma, Arial, Helvetica, sans serif">' + rounder(var0[i]*100,2)+'<\/td>')
   newin.document.writeln(' <td><font face="Tahoma, Arial, Helvetica, sans serif">' + rounder(var1[i]*100,2)+'<\/td>')
   newin.document.writeln(' <td><font face="Tahoma, Arial, Helvetica, sans serif">' + rounder(var2[i]*100,2)+'<\/td>')
   newin.document.writeln(' <td><font face="Tahoma, Arial, Helvetica, sans serif">' + rounder(var3[i]*100,2)+'<\/td>')
   newin.document.writeln(' <td><font face="Tahoma, Arial, Helvetica, sans serif">' + rounder(var4[i]*100,2)+'<\/td><\/tr>')
   if (sed_del[i] == 0) {break}					// DEH 2004.03.18 move from top
  }
  newin.document.writeln('<\/table>')
  newin.document.writeln('   <!--tool bar begins--><p>')
  newin.document.writeln('     <table bgcolor="#666666" width="20%" border="0" cellspacing="1" cellpadding="5" align="center">')
  newin.document.writeln('      <tr>')
  newin.document.writeln('       <td align="center" bgcolor="#dddddd" onMouseOver="this.style.backgroundColor=\'#ffffff\';" onMouseOut="this.style.backgroundColor=\'\';"><font face="verdana,arial,helvetica" size="1"><img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.print()">Print&nbsp;me<\/a><\/font><\/td>')
  newin.document.writeln('       <td align="center" bgcolor="#dddddd" onMouseOver="this.style.backgroundColor=\'#ffffff\';" onMouseOut="this.style.backgroundColor=\'\';"><font face="verdana,arial,helvetica" size="1"><img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.close()">Close&nbsp;me\</a><\/font><\/td>')
  newin.document.writeln('      <\/tr>')
  newin.document.writeln('     <\/table>')
  newin.document.writeln('   <!--tool bar ends-->')
  newin.document.writeln('<\/body>')
  newin.document.writeln('<\/html>')
  newin.document.close()
}

function showlogtable () {
// display sediment delivery vs cumulative probability for contour logs
//  or straw wattles

// js_units
// js_avg_slope
// diameter, spacing from creating calling form

  var diameter=document.doit.diameter.value
  var spacing=document.doit.spacing.value
  var seddel

  var spacing_m = spacing    // convert ft to m if necesarry
  var diameter_m = diameter  // convert ft to m if necessary
  var slope_ratio = js_avg_slope / 100

  // as slope approaches zero, term b approaches infinity (div by 0)
  // as spacing approaches zero, term a approaches infinity (div by 0 )
  if (slope < 5) {slope = 5}
  if (spacing < 0.5) {spacing = 0.5}

  var a_num = 9000 * diameter_ * diameter_m
  var a_denom = spacing_m * Math.cosine(Math.arctan(slope_ratio/100))
  var b = (1 / (2 * slope_ratio)) - 0.6
  var capacity = (a_num / a_denom) * b
  var twocap = 2 * capacity

  newin = window.open('','contour','width=600,height=300,scrollbars=yes,resizable=yes')
  newin.document.open()
  newin.document.writeln('<HEAD><title>Contour logs probability table<\/title><\/HEAD>')
  newin.document.writeln('<body bgcolor="ivory" onLoad="top.window.focus()">')
  newin.document.writeln('<font face="Tahoma, Arial, Helvetica, sans serif">')
  newin.document.writeln('<h3 align="center">'+what+'<\/h2>')
  newin.document.writeln(js_climate_name+'<br>'+js_soil_texture+'; '+js_rfg+'% rock;'+js_top_slope+' %, '+js_avg_slope+' %,'+js_toe_slope+' % slope; '+js_hillslope_length+' '+ js_units+'; '+js_severityclass_x+' severity fire')
  newin.document.writeln('<table border=1 cellpadding=5>')
  newin.document.writeln(' <tr><th rowspan=2 bgcolor=ffff99><font face="Tahoma, Arial, Helvetica, sans serif">Sediment delivery<br>('+js_alt_sedunits+')<\/th>')
  newin.document.writeln('     <th colspan=5 bgcolor=ffff99><font face="Tahoma, Arial, Helvetica, sans serif">Percent chance that sediment delivery will be exceeded<\/th><\/tr>')
  newin.document.writeln('<tr><th bgcolor=ffff99><font face="Tahoma, Arial, Helvetica, sans serif">1st year<\/th>')
  newin.document.writeln('<th bgcolor=ffff99><font face="Tahoma, Arial, Helvetica, sans serif">2nd year<\/th>')
  newin.document.writeln('<th bgcolor=ffff99><font face="Tahoma, Arial, Helvetica, sans serif">3rd year<\/th>')
  newin.document.writeln('<th bgcolor=ffff99><font face="Tahoma, Arial, Helvetica, sans serif">4th year<\/th>')
  newin.document.writeln('<th bgcolor=ffff99><font face="Tahoma, Arial, Helvetica, sans serif">5th year</tr>')
  for (var i=1; i<= sed_del.length; i++) {
   if (sed_del[i] == 0) {break}
   seddel = sed_del[i]
   if (seddel < twocap) {seddel = seddel / 2; sed_color='blue'}
   else {seddel = seddel - capacity; sed_color='green'}
   seddel = seddel * js_sedconv    // kg / m to t / ac or t / ha
   newin.document.write(' <tr><td align=right bgcolor=ffff99><b>')
   newin.document.writeln('  <font color='+sed_color+' face="Tahoma, Arial, Helvetica, sans serif">' + rounder(seddel,2)+'<\/font><\/b><\/td>')
   newin.document.writeln(' <td><font face="Tahoma, Arial, Helvetica, sans serif">' + rounder(cp0[i]*100,2)+'<\/td>')
   newin.document.writeln(' <td><font face="Tahoma, Arial, Helvetica, sans serif">' + rounder(cp1[i]*100,2)+'<\/td>')
   newin.document.writeln(' <td><font face="Tahoma, Arial, Helvetica, sans serif">' + rounder(cp2[i]*100,2)+'<\/font><\/td>')
   newin.document.writeln(' <td><font face="Tahoma, Arial, Helvetica, sans serif">' + rounder(cp3[i]*100,2)+'<\/font><\/td>') 
   newin.document.writeln(' <td><font face="Tahoma, Arial, Helvetica, sans serif">' + rounder(cp4[i]*100,2)+'<\/font><\/td></tr>')
  }
  newin.document.writeln('</table>')
  newin.document.writeln('</body>')
  newin.document.writeln('</html>')
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
  newin.document.writeln('  <font face="tahoma"> ')
  newin.document.writeln('   <h3>Erosion Risk Management Tool<\/h3>')
  newin.document.writeln('   <h3>Event sediment delivery table<\/h3>')
  newin.document.writeln(js_climate_name+'<br>'+js_soil_texture+'; '+js_rfg+'% rock;'+js_top_slope+' %, '+js_avg_slope+' %,'+js_toe_slope+' % slope; '+js_hillslope_length+' '+ js_units+'; '+js_severityclass_x+' severity fire')

// untreated
  newin.document.writeln('  <h3 align="center">Untreated<\/h3>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.doit.sediment0.value + ' '+js_alt_sedunits + ' in the first year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.doit.sediment1.value + ' '+js_alt_sedunits + ' in the second year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.doit.sediment2.value + ' '+js_alt_sedunits + ' in the third year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.doit.sediment3.value + ' '+js_alt_sedunits + ' in the fourth year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.doit.sediment4.value + ' '+js_alt_sedunits + ' in the fifth year following the fire.<br>')
// seeding
  newin.document.writeln('  <h3 align="center">Seeding<\/h3>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.doit.sediment_s0.value + ' '+js_alt_sedunits + ' in the first year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.doit.sediment_s1.value + ' '+js_alt_sedunits + ' in the second year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.doit.sediment_s2.value + ' '+js_alt_sedunits + ' in the third year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.doit.sediment_s3.value + ' '+js_alt_sedunits + ' in the fourth year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.doit.sediment_s4.value + ' '+js_alt_sedunits + ' in the fifth year following the fire.<br>')
// 0.5 t/ha mulch
  newin.document.writeln('  <h3 align="center">'+mulch1+'<\/h3>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.doit.sediment_mh0.value + ' '+js_alt_sedunits + ' in the first year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.doit.sediment_mh1.value + ' '+js_alt_sedunits + ' in the second year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.doit.sediment_mh2.value + ' '+js_alt_sedunits + ' in the third year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.doit.sediment_mh3.value + ' '+js_alt_sedunits + ' in the fourth year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.doit.sediment_mh4.value + ' '+js_alt_sedunits + ' in the fifth year following the fire.<br>')
// 1.0 t/ha mulch
  newin.document.writeln('  <h3 align="center">'+mulch2+'<\/h3>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.doit.sediment_mo0.value + ' '+js_alt_sedunits + ' in the first year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.doit.sediment_mo1.value + ' '+js_alt_sedunits + ' in the second year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.doit.sediment_mo2.value + ' '+js_alt_sedunits + ' in the third year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.doit.sediment_mo3.value + ' '+js_alt_sedunits + ' in the fourth year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.doit.sediment_mo4.value + ' '+js_alt_sedunits + ' in the fifth year following the fire.<br>')
// 1.5 t/ha mulch
  newin.document.writeln('  <h3 align="center">'+mulch3+'<\/h3>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.doit.sediment_moh0.value + ' '+js_alt_sedunits + ' in the first year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.doit.sediment_moh1.value + ' '+js_alt_sedunits + ' in the second year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.doit.sediment_moh2.value + ' '+js_alt_sedunits + ' in the third year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.doit.sediment_moh3.value + ' '+js_alt_sedunits + ' in the fourth year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.doit.sediment_moh4.value + ' '+js_alt_sedunits + ' in the fifth year following the fire.<br>')
// 2.0 t/ha mulch
  newin.document.writeln('  <h3 align="center">'+mulch4+'<\/h3>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.doit.sediment_mt0.value + ' '+js_alt_sedunits + ' in the first year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.doit.sediment_mt1.value + ' '+js_alt_sedunits + ' in the second year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.doit.sediment_mt2.value + ' '+js_alt_sedunits + ' in the third year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.doit.sediment_mt3.value + ' '+js_alt_sedunits + ' in the fourth year following the fire.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.doit.sediment_mt4.value + ' '+js_alt_sedunits + ' in the fifth year following the fire.<br>')
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
  newin.document.writeln(js_climate_name+'<br>'+js_soil_texture+'; '+js_rfg+'% rock;'+js_top_slope+' %, '+js_avg_slope+' %,'+js_toe_slope+' % slope; '+js_hillslope_length+' '+ js_units+'; '+js_severityclass_x+' severity fire')

  newin.document.writeln('  <h3 align="center">Untreated<\/h3>')
// untreated
  newin.document.writeln('   There is a ' + document.doit.probability0.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the first year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.doit.probability1.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the second year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.doit.probability2.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the third year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.doit.probability3.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the fourth year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.doit.probability4.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the fifth year following the fire.<br>')
// seeding
  newin.document.writeln('  <h3 align="center">Seeding<\/h3>')
  newin.document.writeln('   There is a ' + document.doit.probability_s0.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the first year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.doit.probability_s1.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the second year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.doit.probability_s2.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the third year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.doit.probability_s3.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the fourth year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.doit.probability_s4.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the fifth year following the fire.<br>')
// 0.5 t/ha mulch  0.2 t/ac
  newin.document.writeln('  <h3 align="center">'+mulch1+'<\/h3>')
  newin.document.writeln('   There is a ' + document.doit.probability_mh0.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the first year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.doit.probability_mh1.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the second year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.doit.probability_mh2.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the third year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.doit.probability_mh3.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the fourth year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.doit.probability_mh4.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the fifth year following the fire.<br>')
// 1.0 t/ha mulch
  newin.document.writeln('  <h3 align="center">'+mulch2+'<\/h3>')
  newin.document.writeln('   There is a ' + document.doit.probability_mo0.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the first year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.doit.probability_mo1.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the second year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.doit.probability_mo2.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the third year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.doit.probability_mo3.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the fourth year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.doit.probability_mo4.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the fifth year following the fire.<br>')
// 1.5 t/ha mulch
  newin.document.writeln('  <h3 align="center">'+mulch3+'<\/h3>')
  newin.document.writeln('   There is a ' + document.doit.probability_moh0.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the first year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.doit.probability_moh1.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the second year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.doit.probability_moh2.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the third year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.doit.probability_moh3.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the fourth year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.doit.probability_moh4.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the fifth year following the fire.<br>')
// 2.0 t/ha mulch
  newin.document.writeln('  <h3 align="center">'+mulch4+'<\/h3>')
  newin.document.writeln('   There is a ' + document.doit.probability_mt0.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the first year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.doit.probability_mt1.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the second year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.doit.probability_mt2.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the third year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.doit.probability_mt3.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the fourth year following the fire.<br>')
  newin.document.writeln('   There is a ' + document.doit.probability_mt4.value+'% chance that sediment delivery will exceed ' + sedval + ' '+js_alt_sedunits + ' in the fifth year following the fire.<br>')
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
  # soilparameters

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

goto skip;

  if ($SoilType eq 'sand') {
    $solthk = 400;      # depth of soil surface to bottom of soil layer (mm)   
    $sand = 55;         # percentage of sand in the layer (%)                  
    $clay = 10;         # percentage of clay in the layer (%)                  
    $orgmat = 5;        # percentage of organic matter (by vlume) in the layer (%)
    $cec = 15;          # cation exchange capacity in the layer (meq per 100 g of soil)
#              ki      kr  tauc/shcrit  Ksat/avke                              
    @l[0] = "300000\t0.0003\t2\t48";                                           
    @l[1] = "500000\t0.00034\t2\t46";                                          
    @l[2] = "700000\t0.00037\t2\t44";                                          
    @l[3] = "1000000\t0.0004\t2\t24";                                          
    @l[4] = "1200000\t0.00045\t2\t14";                                         
    @h[0] = "1000000\t0.0004\t2\t22";                                          
    @h[1] = "1500000\t0.0005\t2\t13";                                          
    @h[2] = "2000000\t0.0006\t2\t7";                                           
    @h[3] = "2500000\t0.0007\t2\t6";                                           
    @h[4] = "3000000\t0.001\t2\t5";                                            
  }                                                                         
  if ($SoilType eq 'silt') {             
    $solthk = 400;                       
    $sand = 25;                          
    $clay = 15;                          
    $orgmat = 5;                         
    $cec = 15;                           
    @l[0] = "250000\t0.0002\t3.5\t33";   
    @l[1] = "300000\t0.00024\t3.5\t31";  
    @l[2] = "400000\t0.00027\t3.5\t29";  
    @l[3] = "500000\t0.0003\t3.5\t19";   
    @l[4] = "600000\t0.00035\t3.5\t9";   
    @h[0] = "500000\t0.0003\t3.5\t18";   
    @h[1] = "1000000\t0.0004\t3.5\t10";  
    @h[2] = "1500000\t0.0005\t3.5\t6";   
    @h[3] = "2000000\t0.0006\t3.5\t4";   
    @h[4] = "2500000\t0.0009\t3.5\t3";   
  }
  if ($SoilType eq 'clay') {          
    $solthk = 400;                    
    $sand = 25;                       
    $clay = 30;                       
    $orgmat = 5;                      
    $cec = 25;                        
    @l[0] = "200000\t0.0001\t4\t25";  
    @l[1] = "250000\t0.00014\t4\t24"; 
    @l[2] = "300000\t0.00017\t4\t23"; 
    @l[3] = "400000\t0.0002\t4\t14";  
    @l[4] = "500000\t0.00025\t4\t8";  
    @h[0] = "400000\t0.0002\t4\t13";  
    @h[1] = "700000\t0.0003\t4\t7";   
    @h[2] = "1000000\t0.0004\t4\t4";  
    @h[3] = "1500000\t0.0005\t4\t3";  
    @h[4] = "2000000\t0.0008\t4\t2";  
  }                                   
  if ($SoilType eq 'loam') {               
    $solthk = 400;                         
    $sand = 45;                            
    $clay = 20;                            
    $orgmat = 5;                           
    $cec = 20;                             
    @l[0] = "320000\t0.00015\t3\t40";      
    @l[1] = "370000\t0.00019\t3\t38";      
    @l[2] = "470000\t0.00022\t3\t36";      
    @l[3] = "600000\t0.00025\t3\t28";      
    @l[4] = "800000\t0.0003\t3\t18";       
    @h[0] = "600000\t0.00025\t3\t27";      
    @h[1] = "800000\t0.00035\t3\t15";      
    @h[2] = "1200000\t0.00055\t3\t8";      
    @h[3] = "2200000\t0.00065\t3\t5";      
    @h[4] = "3200000\t0.00085\t3\t4";      
  }

skip:

  &soil_parameters;

  @l[0] = @ki_l[0] . "\t" . @kr_l[0] . "\t" . $tauc . "\t" . @ksat_l[0];
  @l[1] = @ki_l[1] . "\t" . @kr_l[1] . "\t" . $tauc . "\t" . @ksat_l[1];
  @l[2] = @ki_l[2] . "\t" . @kr_l[2] . "\t" . $tauc . "\t" . @ksat_l[2];
  @l[3] = @ki_l[3] . "\t" . @kr_l[3] . "\t" . $tauc . "\t" . @ksat_l[3];
  @l[4] = @ki_l[4] . "\t" . @kr_l[4] . "\t" . $tauc . "\t" . @ksat_l[4];
  @h[0] = @ki_l[0] . "\t" . @kr_h[0] . "\t" . $tauc . "\t" . @ksat_h[0];
  @h[1] = @ki_l[1] . "\t" . @kr_h[1] . "\t" . $tauc . "\t" . @ksat_h[1];
  @h[2] = @ki_l[2] . "\t" . @kr_h[2] . "\t" . $tauc . "\t" . @ksat_h[2];
  @h[3] = @ki_l[3] . "\t" . @kr_h[3] . "\t" . $tauc . "\t" . @ksat_h[3];
  @h[4] = @ki_l[4] . "\t" . @kr_h[4] . "\t" . $tauc . "\t" . @ksat_h[4];

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
 # $tauc
 # @ksat_l[0..4]
 # @ksat_h[0..4]

  if ($vegtype eq 'forest') {

    if ($SoilType eq 'sand') {
      $solthk = 400;      # depth of soil surface to bottom of soil layer (mm)
      $sand = 55;         # percentage of sand in the layer (%)               
      $clay = 10;         # percentage of clay in the layer (%)               
      $orgmat = 5;        # percentage of organic matter (by vlume) in the layer (%)
      $cec = 15;          # cation exchange capacity in the layer (meq per 100 g of soil)
      $tauc=2;
      @ki_l[0] =  300000; @kr_l[0] = 0.00030; @ksat_l[0] = 48;
      @ki_l[1] =  500000; @kr_l[1] = 0.00034; @ksat_l[1] = 46;
      @ki_l[2] =  700000; @kr_l[2] = 0.00037; @ksat_l[2] = 44;
      @ki_l[3] = 1000000; @kr_l[3] = 0.00040; @ksat_l[3] = 24;
      @ki_l[4] = 1200000; @kr_l[4] = 0.00045; @ksat_l[4] = 14;
      @ki_h[0] = 1000000; @kr_h[0] = 0.00040; @ksat_h[0] = 22;
      @ki_h[1] = 1500000; @kr_h[1] = 0.00050; @ksat_h[1] = 13;
      @ki_h[2] = 2000000; @kr_h[2] = 0.00060; @ksat_h[2] =  7;
      @ki_h[3] = 2500000; @kr_h[3] = 0.00070; @ksat_h[3] =  6;
      @ki_h[4] = 3000000; @kr_h[4] = 0.00100; @ksat_h[4] =  5;
    }
    if ($SoilType eq 'silt') {
      $solthk = 400;
      $sand = 25;
      $clay = 15;
      $orgmat = 5;
      $cec = 15;
      $tauc = 3.5; 
      @ki_l[0] =  250000; @kr_l[0] = 0.00020; @ksat_l[0] = 33;   
      @ki_l[1] =  300000; @kr_l[1] = 0.00024; @ksat_l[1] = 31;  
      @ki_l[2] =  400000; @kr_l[2] = 0.00027; @ksat_l[2] = 29;  
      @ki_l[3] =  500000; @kr_l[3] = 0.00030; @ksat_l[3] = 19;   
      @ki_l[4] =  600000; @kr_l[4] = 0.00035; @ksat_l[4] =  9;   
      @ki_h[0] =  500000; @kr_h[0] = 0.00030; @ksat_h[0] = 18;   
      @ki_h[1] = 1000000; @kr_h[1] = 0.00040; @ksat_h[1] = 10;  
      @ki_h[2] = 1500000; @kr_h[2] = 0.00050; @ksat_h[2] =  6;   
      @ki_h[3] = 2000000; @kr_h[3] = 0.00060; @ksat_h[3] =  4;   
      @ki_h[4] = 2500000; @kr_h[4] = 0.00090; @ksat_h[4] =  3;   
    }
    if ($SoilType eq 'clay') {          
      $solthk = 400;                    
      $sand = 25;                       
      $clay = 30;                       
      $orgmat = 5;                      
      $cec = 25;
      $tauc = 4; 
      @ki_l[0] =  200000; @kr_l[0] = 0.00010; @ksat_l[0] = 25;  
      @ki_l[1] =  250000; @kr_l[1] = 0.00014; @ksat_l[1] = 24; 
      @ki_l[2] =  300000; @kr_l[2] = 0.00017; @ksat_l[2] = 23; 
      @ki_l[3] =  400000; @kr_l[3] = 0.00020; @ksat_l[3] = 14;  
      @ki_l[4] =  500000; @kr_l[4] = 0.00025; @ksat_l[4] =  8;  
      @ki_h[5] =  400000; @kr_h[0] = 0.00020; @ksat_h[0] = 13;  
      @ki_h[6] =  700000; @kr_h[1] = 0.00030; @ksat_h[1] =  7;   
      @ki_h[7] = 1000000; @kr_h[2] = 0.00040; @ksat_h[2] =  4;  
      @ki_h[8] = 1500000; @kr_h[3] = 0.00050; @ksat_h[3] =  3;  
      @ki_h[9] = 2000000; @kr_h[4] = 0.00080; @ksat_h[4] =  2;  
    }
    if ($SoilType eq 'loam') {
      $solthk = 400;
      $sand = 45;
      $clay = 20;
      $orgmat = 5;
      $cec = 20;
      $tauc = 3;
      @ki_l[0] =  320000; @kr_l[0] = 0.00015; @ksat_l[0] = 40;
      @ki_l[1] =  370000; @kr_l[1] = 0.00019; @ksat_l[1] = 38;
      @ki_l[2] =  470000; @kr_l[2] = 0.00022; @ksat_l[2] = 36;
      @ki_l[3] =  600000; @kr_l[3] = 0.00025; @ksat_l[3] = 28;
      @ki_l[4] =  800000; @kr_l[4] = 0.00030; @ksat_l[4] = 18;
      @ki_h[0] =  600000; @kr_h[0] = 0.00025; @ksat_h[0] = 27;
      @ki_h[1] =  800000; @kr_h[1] = 0.00035; @ksat_h[1] = 15;
      @ki_h[2] = 1200000; @kr_h[2] = 0.00055; @ksat_h[2] =  8;
      @ki_h[3] = 2200000; @kr_h[3] = 0.00065; @ksat_h[3] =  5;
      @ki_h[4] = 3200000; @kr_h[4] = 0.00085; @ksat_h[4] =  4;
    }

    # return 
    #   $tauc
    #   @ki_l[0..4]
    #   @ki_h[0..4]
    #   @kr_l[0..4]
    #   @kr_h[0..4]
    #   @ksat_l[0..4]
    #   @ksat_h[0..4]

  }
  else {   # $vegtype ne 'forest'...

    if ($SoilType eq 'sand') {
      $solthk = 400;      # depth of soil surface to bottom of soil layer (mm) 
      $sand = 55;         # percentage of sand in the layer (%)             
      $clay = 10;         # percentage of clay in the layer (%)        
      $orgmat = 5;        # percentage of organic matter (by vlume) in the layer (%)
      $cec = 15;          # cation exchange capacity in the layer (meq per 100 g of soil)
      $tauc=1.1;
      @ki_shrub_l[0] =  105000; @ki_grass_l[0] =  150000; @ki_bare_l[0] = 480000;
      @ki_shrub_l[1] =  217000; @ki_grass_l[1] =  231000; @ki_bare_l[1] = 771000;
      @ki_shrub_l[2] =  306000; @ki_grass_l[2] =  366000; @ki_bare_l[2] = 1280000;
      @ki_shrub_l[3] =  439000; @ki_grass_l[3] =  407000; @ki_bare_l[3] = 1440000;
      @ki_shrub_l[4] =  661000; @ki_grass_l[4] =  611000; @ki_bare_l[4] = 2240000;
      @ki_shrub_h[0] =  253000; @ki_grass_h[0] =  480000; @ki_bare_h[0] = 480000;
      @ki_shrub_h[1] =  549000; @ki_grass_h[1] =  771000; @ki_bare_h[1] = 771000;
      @ki_shrub_h[2] =  795000; @ki_grass_h[2] = 1280000; @ki_bare_h[2] = 1280000;
      @ki_shrub_h[3] = 1180000; @ki_grass_h[3] = 1440000; @ki_bare_h[3] = 1440000;
      @ki_shrub_h[4] = 1820000; @ki_grass_h[4] = 2240000; @ki_bare_h[4] = 2240000;
      @kr_l[0] = 6.79e-06;
      @kr_l[1] = 1.23e-05;
      @kr_l[2] = 1.97e-05;
      @kr_l[3] = 4.00e-05;
      @kr_l[4] = 1.24e-04;
      @kr_h[0] = 8.00e-05;
      @kr_h[1] = 1.27e-03;
      @kr_h[2] = 3.06e-03;
      @kr_h[3] = 7.95e-03;
      @kr_h[4] = 1.76e-02;
      @ks_shrub_l[0] = 34; @ks_grass_l[0] = 27; @ks_bare_l[0] = 22;
      @ks_shrub_l[1] = 29; @ks_grass_l[1] = 25; @ks_bare_l[1] = 21;
      @ks_shrub_l[2] = 25; @ks_grass_l[2] = 21; @ks_bare_l[2] = 17;
      @ks_shrub_l[3] = 23; @ks_grass_l[3] = 19; @ks_bare_l[3] = 16;
      @ks_shrub_l[4] = 17; @ks_grass_l[4] = 16; @ks_bare_l[4] = 13;
      @ks_shrub_h[0] = 26; @ks_grass_h[0] = 22; @ks_bare_h[0] = 22;
      @ks_shrub_h[1] = 22; @ks_grass_h[1] = 21; @ks_bare_h[1] = 21;
      @ks_shrub_h[2] = 20; @ks_grass_h[2] = 17; @ks_bare_h[2] = 17;
      @ks_shrub_h[3] = 17; @ks_grass_h[3] = 16; @ks_bare_h[3] = 16;
      @ks_shrub_h[4] = 13; @ks_grass_h[4] = 13; @ks_bare_h[4] = 13;
    }
    if ($SoilType eq 'silt') {
      $solthk = 400;
      $sand = 25;
      $clay = 15;
      $orgmat = 5;
      $cec = 15;
      $tauc=2.0;
      @ki_shrub_l[0] =  269000; @ki_grass_l[0] =  285000; @ki_bare_l[0] = 971000;
      @ki_shrub_l[1] =  417000; @ki_grass_l[1] =  441000; @ki_bare_l[1] = 1570000;
      @ki_shrub_l[2] =  598000; @ki_grass_l[2] =  635000; @ki_bare_l[2] = 2340000;
      @ki_shrub_l[3] =  776000; @ki_grass_l[3] =  824000; @ki_bare_l[3] = 3120000;
      @ki_shrub_l[4] = 1210000; @ki_grass_l[4] = 1280000; @ki_bare_l[4] = 5080000;
      @ki_shrub_h[0] =  693000; @ki_grass_h[0] =  971000; @ki_bare_h[0] = 971000;
      @ki_shrub_h[1] = 1110000; @ki_grass_h[1] = 1570000; @ki_bare_h[1] = 1570000;
      @ki_shrub_h[2] = 1640000; @ki_grass_h[2] = 2340000; @ki_bare_h[2] = 2340000;
      @ki_shrub_h[3] = 2170000; @ki_grass_h[3] = 3120000; @ki_bare_h[3] = 3120000;
      @ki_shrub_h[4] = 3480000; @ki_grass_h[4] = 5080000; @ki_bare_h[4] = 5080000;
      @kr_l[0] = 9.24e-05;
      @kr_l[1] = 1.29e-04;
      @kr_l[2] = 1.97e-04;
      @kr_l[3] = 4.26e-04;
      @kr_l[4] = 8.51e-04;
      @kr_h[0] = 6.34e-04;
      @kr_h[1] = 5.07e-03;
      @kr_h[2] = 1.05e-02;
      @kr_h[3] = 2.46e-02;
      @kr_h[4] = 4.18e-02;
      @ks_shrub_l[0] = 33; @ks_grass_l[0] = 37; @ks_bare_l[0] = 31;
      @ks_shrub_l[1] = 28; @ks_grass_l[1] = 32; @ks_bare_l[1] = 26;
      @ks_shrub_l[2] = 22; @ks_grass_l[2] = 25; @ks_bare_l[2] = 21;
      @ks_shrub_l[3] = 20; @ks_grass_l[3] = 23; @ks_bare_l[3] = 19;
      @ks_shrub_l[4] = 16; @ks_grass_l[4] = 18; @ks_bare_l[4] = 15;
      @ks_shrub_h[0] = 25; @ks_grass_h[0] = 31; @ks_bare_h[0] = 31;
      @ks_shrub_h[1] = 22; @ks_grass_h[1] = 26; @ks_bare_h[1] = 26;
      @ks_shrub_h[2] = 17; @ks_grass_h[2] = 21; @ks_bare_h[2] = 21;
      @ks_shrub_h[3] = 15; @ks_grass_h[3] = 19; @ks_bare_h[3] = 19;
      @ks_shrub_h[4] = 12; @ks_grass_h[4] = 15; @ks_bare_h[4] = 15;
    }
    if ($SoilType eq 'clay') {
      $solthk = 400;                    
      $sand = 25;                       
      $clay = 30;                       
      $orgmat = 5;                      
      $cec = 25;
      $tauc = 3.27;
      @ki_shrub_l[0] =  518000; @ki_grass_l[0] =  432000; @ki_bare_l[0] = 1530000;
      @ki_shrub_l[1] =  820000; @ki_grass_l[1] =  679000; @ki_bare_l[1] = 2520000;
      @ki_shrub_l[2] = 1200000; @ki_grass_l[2] =  989000; @ki_bare_l[2] = 3810000;
      @ki_shrub_l[3] = 1580000; @ki_grass_l[3] = 1300000; @ki_bare_l[3] = 5120000;
      @ki_shrub_l[4] = 2510000; @ki_grass_l[4] = 2050000; @ki_bare_l[4] = 8470000;
      @ki_shrub_h[0] = 1400000; @ki_grass_h[0] = 1530000; @ki_bare_h[0] = 1530000;
      @ki_shrub_h[1] = 2300000; @ki_grass_h[1] = 2520000; @ki_bare_h[1] = 2520000;
      @ki_shrub_h[2] = 3460000; @ki_grass_h[2] = 3810000; @ki_bare_h[2] = 3810000;
      @ki_shrub_h[3] = 4650000; @ki_grass_h[3] = 5120000; @ki_bare_h[3] = 5120000;
      @ki_shrub_h[4] = 7660000; @ki_grass_h[4] = 8470000; @ki_bare_h[4] = 8470000;
      @kr_l[0] = 1.60e-04;
      @kr_l[1] = 1.80e-04;
      @kr_l[2] = 2.00e-04;
      @kr_l[3] = 7.68e-04;
      @kr_l[4] = 1.34e-03;
      @kr_h[0] = 9.80e-04;
      @kr_h[1] = 6.17e-03;
      @kr_h[2] = 1.06e-02;
      @kr_h[3] = 3.26e-02;
      @kr_h[4] = 5.13e-02;
      @ks_shrub_l[0] = 24; @ks_grass_l[0] = 20; @ks_bare_l[0] = 17;
      @ks_shrub_l[1] = 20; @ks_grass_l[1] = 17; @ks_bare_l[1] = 14;
      @ks_shrub_l[2] = 17; @ks_grass_l[2] = 15; @ks_bare_l[2] = 12;
      @ks_shrub_l[3] = 14; @ks_grass_l[3] = 12; @ks_bare_l[3] = 10;
      @ks_shrub_l[4] = 11; @ks_grass_l[4] = 10; @ks_bare_l[4] =  8;
      @ks_shrub_h[0] = 19; @ks_grass_h[0] = 17; @ks_bare_h[0] = 17;
      @ks_shrub_h[1] = 16; @ks_grass_h[1] = 14; @ks_bare_h[1] = 14;
      @ks_shrub_h[2] = 13; @ks_grass_h[2] = 12; @ks_bare_h[2] = 12;
      @ks_shrub_h[3] = 11; @ks_grass_h[3] = 10; @ks_bare_h[3] = 10;
      @ks_shrub_h[4] =  9; @ks_grass_h[4] =  8; @ks_bare_h[4] =  8;
    }   
    if ($SoilType eq 'loam') {
      $solthk = 400;
      $sand = 45;
      $clay = 20;
      $orgmat = 5;
      $cec = 20;
      $tauc = 0.04;
      @ki_shrub_l[0] =  263000; @ki_grass_l[0] =  279000; @ki_bare_l[0] = 949000;
      @ki_shrub_l[1] =  293000; @ki_grass_l[1] =  310000; @ki_bare_l[1] = 1070000;
      @ki_shrub_l[2] =  370000; @ki_grass_l[2] =  392000; @ki_bare_l[2] = 1380000;
      @ki_shrub_l[3] =  490000; @ki_grass_l[3] =  519000; @ki_bare_l[3] = 1880000;
      @ki_shrub_l[4] =  773000; @ki_grass_l[4] =  821000; @ki_bare_l[4] = 3110000;
      @ki_shrub_h[0] =  678000; @ki_grass_h[0] =  949000; @ki_bare_h[0] = 949000;
      @ki_shrub_h[1] =  759000; @ki_grass_h[1] = 1070000; @ki_bare_h[1] = 1070000;
      @ki_shrub_h[2] =  977000; @ki_grass_h[2] = 1380000; @ki_bare_h[2] = 1380000;
      @ki_shrub_h[3] = 1320000; @ki_grass_h[3] = 1880000; @ki_bare_h[3] = 1880000;
      @ki_shrub_h[4] = 2160000; @ki_grass_h[4] = 3110000; @ki_bare_h[4] = 3110000;
      @kr_l[0] = 6.50e-05;
      @kr_l[1] = 9.50e-05;
      @kr_l[2] = 2.10e-04;
      @kr_l[3] = 3.35e-04;
      @kr_l[4] = 5.90e-04;
      @kr_h[0] = 4.80e-04;
      @kr_h[1] = 4.23e-03;
      @kr_h[2] = 1.09e-02;
      @kr_h[3] = 2.19e-02;
      @kr_h[4] = 3.55e-02;
      @ks_shrub_l[0] = 32; @ks_grass_l[0] = 24; @ks_bare_l[0] = 20;
      @ks_shrub_l[1] = 27; @ks_grass_l[1] = 18; @ks_bare_l[1] = 15;
      @ks_shrub_l[2] = 21; @ks_grass_l[2] = 10; @ks_bare_l[2] =  9;
      @ks_shrub_l[3] = 19; @ks_grass_l[3] = 10; @ks_bare_l[3] =  8;
      @ks_shrub_l[4] = 16; @ks_grass_l[4] =  8; @ks_bare_l[4] =  7;
      @ks_shrub_h[0] = 24; @ks_grass_h[0] = 20; @ks_bare_h[0] = 20;
      @ks_shrub_h[1] = 21; @ks_grass_h[1] = 15; @ks_bare_h[1] = 15;
      @ks_shrub_h[2] = 17; @ks_grass_h[2] =  9; @ks_bare_h[2] =  9;
      @ks_shrub_h[3] = 15; @ks_grass_h[3] =  8; @ks_bare_h[3] =  8;
      @ks_shrub_h[4] = 12; @ks_grass_h[4] =  7; @ks_bare_h[4] =  7;
    }  # #SoilType

    # return 
    #   $tauc
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

# $gnuplotdatafile
# $gnuplotgraph
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

  $result="set term png color
set output '$gnuplotgraph'
set title 'Sediment Delivery Exceedance Probability for untreated $climate_name' font 'sans serif,20'
set xlabel 'Sediment Delivery ($alt_sedunits)' font 'sans serif,12'
set ylabel 'Probability (%)' font 'sans serif,12'
set noautoscale y
set yrange [0:100]
set key bottom
set timestamp \"%m-%d-%Y -- $soil_texture; $rfg%% rock; $top_slope%%, $avg_slope%%, $toe_slope%% slope; $hillslope_length $units; $severityclass_x fire severity\"
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

#  create data file of sed_delivery vs cumulate probs (5 years) no mit

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
  $cum_prob0 = 0;
  $cum_prob1 = 0;
  $cum_prob2 = 0;
  $cum_prob3 = 0;
  $cum_prob4 = 0;
  for $i (0..79) {
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


# ------------------------ subroutines ---------------------------

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
 my $eps_tp  = 0.000001;
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
#	$tp      approaching 1.0

#	$b       approaching 0.0
#	$d       approaching 0.0
#	$max_dur approaching 0.0

 @i_peak = ('N/A') x ($#max_time_list+1);		# set all intensities to 'N/A'

 $error_text = '';
 $error_text .= 'Storm duration too small. ' if ($dur < $eps_dur);
 $error_text .= 'Too little precipitation. ' if ($prcp < $eps_pcp);
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
# ------------------------ end of subroutines ----------------------------

