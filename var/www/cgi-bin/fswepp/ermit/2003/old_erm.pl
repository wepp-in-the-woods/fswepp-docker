#! /usr/bin/perl
#
# erm.pl
#
# ermit workhorse
# Reads user input from ermit.pl, runs WEPP, parses output files
# top adapted from wd.pl 8/28/2002

# *** check top_slope
# 13 Feb 2003 DEH treat American units
# 15 Jan 2003 DEH fix variable name error in createslopefile: abb
# 19 Dec 2002 DEH tighten up output; add format report of input 

# 28 August 2002
# David Hall, USDA Forest Service, Rocky Mountain Research Station
# William J. Elliot, USDA Forest Service, Rocky Mountain Research Station

   $debug=0;
   $version = "2003.02.28";
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
       <IMG src="http://',$wepphost,'/fswepp/images/disturb.gif"
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
# $sedunits = 'kg m<sup>-1</sup>';
  $sedunits = 't ha<sup>-1</sup>';
  $precipf = $precip;
  $rrof = $rro;
  $srof = $sro;
  $syraf = $syr;
  $sypaf = $syp;

  if ($units eq 'ft') {
    $precipunits = 'in';
    $sedunits = 't ac<sup>-1</sup>';
    $precipf = sprintf '%9.2g', $precip/25.4;   # sprintf
    $rrof = sprintf '%9.2g', $rro/25.4;         # sprintf
    $srof = sprintf '%9.2g', $sro/25.4;         # sprintf
#    $syraf = $syr;             # *** dimensions?
#    $sypaf = $syp;             # *** dimensions?
  }

         print TEMP "<center>
  <table cellspacing=8 bgcolor='ivory'>
   <tr>
    <th colspan=5 bgcolor=#85D2D2>
     $years2sim - YEAR MEAN ANNUAL AVERAGES
    </th>
   </tr>
   <tr>
    <td align=right><b>
     $precipf</b>
    </td>
    <td><b>
     $precipunits</b>
    </td>
    <td>
     precipitation from
    </td>
    <td align=right>
     $storms
    </td>
    <td>
     storms
    </td>
   </tr>
   <tr>
    <td align=right><b>
     $rrof</b>
    </td>
    <td><b>
     $precipunits</b>
    </td>
    <td>
     runoff from rainfall from
    </td>
    <td align=right>
     $rainevents
    </td>
    <td>events
   </tr>
   <tr>
    <td align=right><b>
     $srof</b>
    </td>
    <td><b>
     $precipunits</b>
    </td>
    <td>
     runoff from snowmelt or winter rainstorm from
    </td>
    <td align=right>
     $snowevents
    </td>
    <td>events
   </tr>
  </table>
  <hr width=50%>
";

# }

# goto cutout;

# ====================== parse_evo_s.pl ======================================

# D.E. Hall 08 June 2001  USDA FS Moscow, ID

   if ($debug) {print TEMP "\nParse WEPP event output EVO file: $eventFile<br>\n";}

   @selected_ranks = (5,10,20,50);

sub numerically { $a <=> $b }

   $evo_file = "<$eventFile";

    open EVO, $evo_file;
    while (<EVO>) {				# skip past header lines
#      if ($_ =~ /------/) {last}
      if ($_ =~ /---/) {last}
    }
#    print TEMP $_; 	# verify location

    $keep = <EVO>;
    ($day1,$month1,$year1,$precip1,$runoff1,$rest1) = split ' ', $keep, 6;
    $runoff1+=0; $year1+=0;			# force to numeric
#   print TEMP "day: $day1\tmonth: $month1\tyear: $year1\trunoff:$runoff1\n";

#    print TEMP "$evo_file -- maximal runoff event for year, sorted by year\n\n";

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
#        print TEMP $keep;			# print last year's max runoff entry
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
#    print TEMP $keep;			# print final year's max runoff entry
    close EVO;

  $, = " ";
  if ($debug) {print TEMP "\n",@run_off,"\n";}

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
#  for $i (0..$years) {print TEMP @run_off[$indx[$i]],"  "}
#  print TEMP "\n\n<p>"; $, = "<br>";
#  for $i (0..$years) {print TEMP @max_run[$indx[$i]]}

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
    @previous_year[$i] = $year-1;
  }

#print TEMP "@selected_ranks\n";

    ($max_day,$max_month,$max_year,$max_precip,$runoff,$rest) = split ' ', @max_run[@indx[0]], 6;
    ($interrill_det,$avg_det,$max_det,$det_pt,
     $avg_dep,$max_dep,$dep_pt,$max_sed_del,$enrich) = split ' ', $rest; 

   @monthnames = ('', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December');

#### 2003 units
      if ($units eq 'ft') {
         $run_off_f = sprintf '%9.2f', @run_off[$indx[0]]/25.4;
         $max_precip_f = sprintf '%9.2f', $max_precip/25.4;
         $max_sed_del_f = $max_sed_del / $hillslope_length_m * 4.45;
            # kg per m / m length * 4.45 --> t per ac
      }
      else {
         $run_off_f = @run_off[$indx[0]];
         $max_precip_f = $max_precip;
         $max_sed_del_f = $max_sed_del / $hillslope_length_m * 10;
            # kg per m / m length * 10 --> t per ha
      }
#### 2003 units

print TEMP "<p>
       <table border=1 cellpadding=12 bgcolor='ivory'>
        <tr><th bgcolor='#ffddff'>Rank
         <th bgcolor='#ffddff'>Runoff<br>($precipunits)
         <th bgcolor='#ffddff'>Precipitation<br>($precipunits)
         <th bgcolor='#ffddff'>Sediment<br>delivery<br>($sedunits)
         <th bgcolor='#ffddff'>Date of year-max event
        </tr>
        <tr>
         <th bgcolor='#ff00ff'>1</th>
         <td align=right>$run_off_f</td>
         <td align=right>$max_precip_f</td>
         <td align=right>$max_sed_del_f</td>
         <td align=right>@monthnames[$max_month] $max_day, $max_year</td>
        </tr>
";

   @color[0]="'#ff33ff'"; @color[1]="'#ff66ff'"; @color[2]="'#ff99ff'";
   @color[3]="'#ffaaff'"; @color[4]="'#ffccff'"; @color[5]="'#ffddff'";

      for $i (0..$#selected_ranks) {
# #### 2003 units
      if ($units eq 'ft') {
        $run_off_f = sprintf '%9.2f', @run_off[$indx[@selected_ranks[$i]]]/25.4;
        $precip_f = sprintf '%9.2f', @precip[$i]/25.4;
        $sed_delivery_f = @sed_delivery[$i];
        $sed_delivery_f = $sed_delivery_f / $hillslope_length_m * 4.45;
      }
      else {
        $run_off_f = @run_off[$indx[@selected_ranks[$i]]];
        $precip_f = @precip[$i];
        $sed_delivery_f = @sed_delivery[$i];
        $sed_delivery_f = $sed_delivery_f / $hillslope_length_m * 10;
      }
# #### 2003 units
      print TEMP '
            <tr>
             <th bgcolor=',@color[$i],'>',@selected_ranks[$i] + 1,' (',100/(@selected_ranks[$i] + 1),"- year)</td>
             <td align=right><b>$run_off_f</b></td>
             <td align=right><b>$precip_f</b></td>
             <td align=right><b>$sed_delivery_f</b></td>
             <td align=right><b>@monthnames[@month[$i]]  @day[$i], @selected_year[$i]</b></td>
            </tr>
";
    }

    ($min_day,$min_month,$min_year,$min_precip,$runoff,$rest) = split ' ', @max_run[@indx[$years]], 6;
    ($interrill_det,$avg_det,$max_det,$det_pt,
     $avg_dep,$max_dep,$dep_pt,$min_sed_del,$enrich) = split ' ', $rest; 

     if (@run_off[$indx[$years]] eq '') {
       $run_off_f = ' -- ';
       $min_precip_f = ' -- ';
       $min_sed_del_f = ' -- ';
     }
     elsif ($units eq 'ft') {
       $run_off_f = sprintf '%9.2f', @run_off[$indx[$years]]/25.4;
       $min_precip_f = sprintf '%9.2f', $min_precip/25.4;
       $min_sed_del_f = $min_sed_del / $hillslope_length_m * 4.45;
     }
     else {
       $run_off_f = @run_off[$indx[$years]];
       $min_precip_f = $min_precip;
       $min_sed_del_f = $min_sed_del / $hillslope_length_m * 10;
     }

      print TEMP
"     <tr>
       <th bgcolor='#ffddff'>100</td>
       <td align=right>$run_off_f</td>
       <td align=right>$min_precip_f</td>
       <td align=right>$min_sed_del_f</td>
       <td align=right>@monthnames[$min_month] $min_day, $min_year</td>
      </tr>
     </table>
";

@years2run = sort numerically @selected_year, @previous_year;
print TEMP "\nYears to run: @years2run\n";

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
      for $day (1..364) {
        $line = <INCLI>;
        print OUTCLI $line;
      }
      ($da,$mo,$yr,$rest) = split ' ',$line;
      while ($da < 31) {
        $line = <INCLI>;
#       print "$yr leap\n";
        print OUTCLI $line;
        ($da,$mo,$yr,$rest) = split ' ',$line;      
      }
    }
  }

  close INCLI;
  close OUTCLI;

skip:

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

   @probClimate = (0.075, 0.075, 0.20, 0.65);	# rank 5, rank 10, rank 20, rank 50
   @probSoil0 = (0.10, 0.20, 0.40, 0.20, 0.10); # year 0
   @probSoil1 = (0.30, 0.30, 0.20, 0.19, 0.01); # year 1
   @probSoil2 = (0.50, 0.30, 0.18, 0.01, 0.01); # year 2
   @probSoil3 = (0.60, 0.30, 0.08, 0.01, 0.01); # year 3
   @probSoil4 = (0.70, 0.27, 0.01, 0.01, 0.01); # year 4
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
       print SLOPE &createSlopeFile;
     close SLOPE;
     &createVegFile;
     $manFile = $datapath . $manFileName;

#  for $k (0..0) {   #ZZ#
     for $k (0..4) {			#   for conductivity (k) = (l1..l5; h1..h5)
       open SOL, ">$soilFile";
         print SOL &createsoilfile;
       close SOL;

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

#        pull out 8 sediment yields from WEPP output (4 from event years, 4 from annual years)
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

  print TEMP '
 <p>
 <table cellpadding="2" bgcolor="ivory">
  <tr><th colspan=5><font size=+1>SEDIMENT  DELIVERY (', $sedunits,')</font></th><th>Spatial (prob)</th></tr>',"\n";

# @selected_ranks[$i] + 1,' (',100/(@selected_ranks[$i] + 1),"- year)

  for $c (0..$#selected_year) {
    print TEMP '  <tr><th align="left" bgcolor="ffff99" colspan="5">', @selected_ranks[$c] + 1,' (',100/(@selected_ranks[$c] + 1),'- year) -- ',@day[$c],' ',@monthnames[@month[$c]],' year ',@selected_year[$c],' (',@probClimate[$c]*100,'%)</th><td></td></tr>',"\n";
#DEH 8
#    for $sn (0..7) {
    for $sn (0..3) {
      print TEMP "<tr>\n";
      for $k (0..4) {
        @sed_yields[$sp] = $sedtable[$c][$k][$sn];
        @probabilities0[$sp] = @probClimate[$c] * @probspatial[$sn] * @probSoil0[$k];
        @probabilities1[$sp] = @probClimate[$c] * @probspatial[$sn] * @probSoil1[$k];
        @probabilities2[$sp] = @probClimate[$c] * @probspatial[$sn] * @probSoil2[$k];
        @probabilities3[$sp] = @probClimate[$c] * @probspatial[$sn] * @probSoil3[$k];
        @probabilities4[$sp] = @probClimate[$c] * @probspatial[$sn] * @probSoil4[$k];
        if ($units eq 'ft') {     # convert sediment yield kg per m to t per ac
          $sed_yield = @sed_yields[$sp] / $hillslope_length_m * 4.45; 
        }
        else {     # convert sediment yield kg per m to t per ha
          $sed_yield = @sed_yields[$sp] / $hillslope_length_m * 10; 
        }
        print TEMP "
  <td align=\"right\"><a href=\"http://forest.moscowfsl.wsu.edu/cgi-bin/fswepp/ermit/soilfile.pl?s=$severe[$sn]&k=$k&SoilType=$SoilType&vegtype=$vegtype&rfg=$rfg&grass=$grass&shrub=$shrub&bare=$bare\" target=\"o\">$sed_yield</a></td>
";
        $sp += 1;
      }
      print TEMP '<td bgcolor="ffff99">',@severe[$sn],' (', @probspatial[$sn]*100, "%)</td></tr>\n";
    }
#    print TEMP "\n";
  }
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

# index sort @sed_yields decreasing
#   print TEMP @sed_yields and @probabilities using same index and calculate cumulative probability

# index-sort runoff		# index sort from "Efficient FORTRAN Programming"

  @index = sort {$sed_yields[$b] <=> $sed_yields[$a]} 0..$#sed_yields;  # sort indices
#  @rank[@index] = 0..$#sed_yields;                    # make rank

  if ($debug) {print TEMP "<pre>\n"}
  $cum_prob0 = 0;
  $cum_prob1 = 0;
  $cum_prob2 = 0;
  $cum_prob3 = 0;
  $cum_prob4 = 0;
  for $sp (0..$#sed_yields) {
    $cum_prob0 += @probabilities0[@index[$sp]];
    $cum_prob1 += @probabilities1[@index[$sp]];
    $cum_prob2 += @probabilities2[@index[$sp]];
    $cum_prob3 += @probabilities3[@index[$sp]];
    $cum_prob4 += @probabilities4[@index[$sp]];
    if ($debug) {print TEMP @sed_yields[@index[$sp]],"\t",@probabilities0[@index[$sp]],"\t$cum_prob0\t$cum_prob1\t$cum_prob2\t$cum_prob3\t$cum_prob4\n";}
#    print TEMP @sed_yields[@index[$sp]],"\t",@probabilities0[@index[$sp]],"\t$cum_prob0\t",,"\t",@probabilities1[@index[$sp]],"\t$cum_prob1\n";
  }
  if ($debug) {print TEMP "\n\n";}

#  @sorted_sed_probs = sort { $a <=> $b } @sed_probs;	# sort numerically increasing
#  for $sp (0..$#sed_probs) {
#    print TEMP @sorted_sed_probs[$sp], ' ';
#  }


bail:

close TEMP;

############################
#  return HTML page
############################

   print "Content-type: text/html\n\n";	# SERVER
   print '<HTML>
   <HEAD>
   <TITLE>ERMiT Results</TITLE>
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
         <font color=red>R</font>ehabilitation
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

print <<'EOP2';
  <p>
  <a href="javascript:showtable()"><img src="/fswepp/ermit/sample.png"></a>
  <h3>no mitigation</h3>

   <script>
    // document.writeln('Sediment delivery ranges from <b>'+sed_del[80]+'<\/b> to <b>'+sed_del[1]+'<\/b> kg m<sup>-2<\/sup><br>')
    // document.writeln('There is a <b>50%<\/b> chance that sediment delivery will exceed <b>'+ rounder(whatseds (0.5, cp0),2) + '<\/b> kg m<sup>-2</sup> for year <b>0<\/b><br>')
    document.writeln('Sediment delivery ranges from <b>'+sed_del[80]+'<\/b> to <b>'+sed_del[1]+'<\/b> kg m<sup>-1<\/sup><br>')
    // document.writeln('There is a <b>50%<\/b> chance that sediment delivery will exceed <b>'+ rounder(whatseds (0.5, cp0),2) + '<\/b> kg m<sup>-1</sup> for the year following the fire.<br>')
    // document.writeln('There is a <b>' + 100 * rounder(whatprob(0.0,cp0),4) + ' %<\/b> chance of sediment delivery the year following the fire.<br>')
   </script>

<form name="doit">
 <table border="1" bgcolor="ffff99">
  <tr>
   <td colspan="2">
 <script>
  seds = rounder(whatseds (0.5, cp0),2)
  document.writeln(' There is a ')
  document.writeln(' <input type="text" name="probability0" onChange="javascript:probchange(0)" value="50" size="8">')
  document.writeln(' % chance that sediment yield will exceed ')
  document.writeln(' <input type="text" name="sediment0" onChange="javascript:sedchange(0)" value="'+seds+'" size="8">')
  document.writeln(' kg m<sup>-1</sup> in the year following the fire.<br>')
  seds = rounder(whatseds (0.5, cp1),2)
//  document.writeln(' There is a ')
  document.writeln(' <input type="hidden" name="probability1" onChange="javascript:probchange(1)" value="50" size="8">')
//  document.writeln(' % chance that sediment yield will exceed ')
  document.writeln(' <input type="hidden" name="sediment1" onChange="javascript:sedchange(1)" value="'+seds+'" size="8">')
//  document.writeln(' kg m<sup>-1</sup> in year 1 following the fire.<br>')
  seds = rounder(whatseds (0.5, cp2),2)
//  document.writeln(' There is a ')
  document.writeln(' <input type="hidden" name="probability2" onChange="javascript:probchange(2)" value="50" size="8">')
//  document.writeln(' % chance that sediment yield will exceed ')
  document.writeln(' <input type="hidden" name="sediment2" onChange="javascript:sedchange(2)" value="'+seds+'" size="8">')
//  document.writeln(' kg m<sup>-1</sup> in year 2 following the fire.<br>')
  seds = rounder(whatseds (0.5, cp3),2)
//  document.writeln(' There is a ')
  document.writeln(' <input type="hidden" name="probability3" onChange="javascript:probchange(3)" value="50" size="8">')
//  document.writeln(' % chance that sediment yield will exceed ')
  document.writeln(' <input type="hidden" name="sediment3" onChange="javascript:sedchange(3)" value="'+seds+'" size="8">')
//  document.writeln(' kg m<sup>-1</sup> in year 3 following the fire.<br>')
  seds = rounder(whatseds (0.5, cp4),2)
//  document.writeln(' There is a ')
  document.writeln(' <input type="hidden" name="probability4" onChange="javascript:probchange(4)" value="50" size="8">')
//  document.writeln(' % chance that sediment yield will exceed ')
  document.writeln(' <input type="hidden" name="sediment4" onChange="javascript:sedchange(4)" value="'+seds+'" size="8">')
//  document.writeln(' kg m<sup>-1</sup> in year 4 following the fire.<br>')
 </script>
   </td>
  </tr>
  <tr>
   <td align="left">
    <img src="/images/go.gif">
   </td>
   <td align="right">
    [<a href="javascript:printprobs()">print table</a>]
   </td>
  </tr>
 </table>
</form>
<p>
<p>   <!-- ======================================== seeding ========================== -->
<table border="2" bgcolor="cc9900">
<tr><th>
  <h3>Seeding after fire</h3>
<form name="seeding">
 <table border="1" bgcolor="ffff99">
  <tr>
   <td colspan="2">
 <script>
  seds = rounder(whatseds (0.5, cp0),2)
  document.writeln(' There is a ')
  document.writeln(' <input type="text" name="probability0" onFocus="javascript:alert(\'coming\')" value="**" size="8">')
  document.writeln(' % chance that sediment yield will exceed ')
  document.writeln(' <input type="text" name="sediment0" onFocus="javascript:alert(\'coming\')" value="**" size="8">')
  document.writeln(' kg m<sup>-1</sup> in the year following the fire.<br>')
 </script>
   </td>
  </tr>
 </table>
</form>
  </th>
 </tr>
</table>
<p>
<p>   <!-- ======================================== mulching ========================== -->
<table border="2" bgcolor="cc9933">
<tr><th>
  <h3>Mulching</h3>
<form name="mulching">
 <input type="radio" name="mulchrate" value="0.0" checked> 0.0 t ha<sup>-1</sup> |
 <input type="radio" name="mulchrate" value="0.5"> 0.5 t ha<sup>-1</sup> |
 <input type="radio" name="mulchrate" value="1.0"> 1.0 t ha<sup>-1</sup> |
 <input type="radio" name="mulchrate" value="1.5"> 1.5 t ha<sup>-1</sup> |
 <input type="radio" name="mulchrate" value="2.0"> 2.0 t ha<sup>-1</sup>
 <table border="1" bgcolor="ffff99">
  <tr>
   <td colspan="2">
 <script>
  seds = rounder(whatseds (0.5, cp0),2)
  document.writeln(' There is a ')
  document.writeln(' <input type="text" name="probability0" onFocus="javascript:alert(\'coming\')" value="**" size="8">')
  document.writeln(' % chance that sediment yield will exceed ')
  document.writeln(' <input type="text" name="sediment0" onFocus="javascript:alert(\'coming\')" value="**" size="8">')
  document.writeln(' kg m<sup>-1</sup> in the year following the fire.<br>')
 </script>
   </td>
  </tr>
 </table>
</form>
  </th>
 </tr>
</table>
<p>   <!-- ======================= contour-felled logs or straw wattles ========================== -->
<table border="2" bgcolor="cc9966">
<tr><th>
  <h3>Contour-felled logs or straw wattles</h3>
<form name="logswattles">
 <input type="text" name="diameter" size=6> mean diameter (m)
 <input type="text" name="spacing" size=6> spacing on hillside (m)
 <table border="1" bgcolor="ffff99">
  <tr>
   <td colspan="2">
 <script>
  seds = rounder(whatseds (0.5, cp0),2)
  document.writeln(' There is a ')
  document.writeln(' <input type="text" name="probability0" onFocus="javascript:alert(\'coming\')" value="**" size="8">')
  document.writeln(' % chance that sediment yield will exceed ')
  document.writeln(' <input type="text" name="sediment0" onFocus="javascript:alert(\'coming\')" value="**" size="8">')
  document.writeln(' kg m<sup>-1</sup> in the year following the fire.<br>')
 </script>
   </td>
  </tr>
 </table>
</form>
  </th>
 </tr>
</table>
<!--<img src="gostone.gif">--> <br>
<!--  <a href="javascript:showtable()">show me the table</a> -->
  </center>
 </body>
</html>
EOP2

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

# reads
  # $soilFile -- soil file
  # $climateFile -- climate file
  # $manFile -- management/vegetation file
  # $slopeFile -- slope file

  # $yearcount

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
      print ResponseFile "n\n";			# large graphics out?
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
#    for_1ofe.man
#    for_2ofe.man
#    for_3ofe.man

     $manFileName = 'for_' . $nofe . 'ofe.man';

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
#  if ($debug) {print TEMP "min_year == $min_year<br>\n";}

  open EVENTS, "<$ev_by_evFile";

  $line = <EVENTS>;
  $line = <EVENTS>;
  $line = <EVENTS>;

  $counter = 0;
  while (<EVENTS>) {
    $event = $_;
    ($da, $mo, $yr, $pcp, $runoff, $IRdet, $avdet, $mxdet, $detpoint, $avdep, $maxdep, $deppoint, $seddel, $er) = split (' ',$event);
    $yr += $min_year - 1;
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
cp0 = new MakeArray; cp0.length = 80
cp1 = new MakeArray; cp1.length = 80
cp2 = new MakeArray; cp2.length = 80
cp3 = new MakeArray; cp3.length = 80
cp4 = new MakeArray; cp4.length = 80
';

  $cum_prob0 = 0;
  $cum_prob1 = 0;
  $cum_prob2 = 0;
  $cum_prob3 = 0;
  $cum_prob4 = 0;
#  for $i (0..$#sed_yields) {
  for $i (0..79) {
    $cum_prob0 += @probabilities0[@index[$i]];
    $cum_prob1 += @probabilities1[@index[$i]];
    $cum_prob2 += @probabilities2[@index[$i]];
    $cum_prob3 += @probabilities3[@index[$i]];
    $cum_prob4 += @probabilities4[@index[$i]];
    $j = $i + 1;
    $sedval = @sed_yields[@index[$i]];
    if ($sedval eq '') {$sedval = '0.0'}
    print "sed_del[$j] = $sedval;  ";
    print "cp0[$j] = $cum_prob0;  ";
    print "cp1[$j] = $cum_prob1;  ";
    print "cp2[$j] = $cum_prob2;  ";
    print "cp3[$j] = $cum_prob3;  ";
    print "cp4[$j] = $cum_prob4\n";
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
//      alert(array[j] + ' ' + array[k] + ' ' + n)
//      if ((array[k] - array[j]) < prob_fuzz) {
//        sed = sed_del[k]
//      }
//      else {
          prop = (array[k] - n) / (array[k] - array[j])    // poss math problem
          sed = sed_del[k] - (sed_del[k] - sed_del[j]) * prop
//    }
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

function whatprob (n, array) {

//sed_fuzz = 0.001   // sediment delivery rate fuzz in kg per m
  k = 1
  gotit = 0
  while (k <= sed_del.length && gotit == 0) {
    if (sed_del[k] <= n) {
      gotit = 1
      if (k > 1) {
        j = k - 1
//      alert('whatprob: ' + sed_del[j] + ', ' + sed_del[k] + ', ' + n)
//      alert('whatprob: ' + array[j] + ', ' + array[k])
//      if ((sed_del[k] - sel_del[j]) < sed_fuzz) {
//        prob = sed_del[k] 
//      }
//      else {
          proportion = (sed_del[k] - n) / (sed_del[k] - sed_del[j])  // poss math problem
          prob = array[k] - (array[k] - array[j]) * proportion
//      }
        return prob
      }
      if (k == 1) {
//      alert ('sed too large')
        return array[1]
      }
    }
    if (gotit == 0) {
      k = k + 1
    }
  }
}

function sedchange (year) {

  default_sed_del = (sed_del[1]-sed_del[80])/2

    sedval = document.doit.sediment0.value
    if (!isNumber (sedval)) {sedval = default_sed_del}
    if (sedval > sed_del[1]) {sedval = sed_del[1]}
    if (sedval < sed_del[80]) {sedval = sed_del[80]}

    document.doit.sediment0.value=sedval
    document.doit.sediment1.value=sedval
    document.doit.sediment2.value=sedval
    document.doit.sediment3.value=sedval
    document.doit.sediment4.value=sedval

    prob0 = whatprob (sedval, eval('cp0'))
    prob1 = whatprob (sedval, eval('cp1'))
    prob2 = whatprob (sedval, eval('cp2'))
    prob3 = whatprob (sedval, eval('cp3'))
    prob4 = whatprob (sedval, eval('cp4'))
      document.doit.probability0.value = rounder(prob0*100,2)
      document.doit.probability1.value = rounder(prob1*100,2)
      document.doit.probability2.value = rounder(prob2*100,2)
      document.doit.probability3.value = rounder(prob3*100,2)
      document.doit.probability4.value = rounder(prob4*100,2)
//  }

  printprobs()

}

function old_sedchange (year) {

  default_sed_del = (sed_del[1]-sed_del[80])/2

  if (year == 0 || year == 1 || year == 2 || year == 3 || year == 4) {
    sedval = eval('document.doit.sediment' + year + '.value')
    if (!isNumber (sedval)) {sedval = default_sed_del}
    if (sedval > sed_del[1]) {sedval = sed_del[1]}
    if (sedval < sed_del[80]) {sedval = sed_del[80]}
    mysed = sedval
    prob = whatprob (mysed, eval('cp' + year))
//  alert ('prob: ' + prob)
    probval = rounder(prob*100,2)
    if (year == 0) {
//    pb = "document.doit.probability" + year + ".value"
//    eval(pb = probval)
      document.doit.probability0.value = probval
    }
    if (year == 1) {
//    eval(document.doit.probability + year) + eval('.value') = probval
      document.doit.probability1.value = probval
    }
    if (year == 2) {
      document.doit.probability2.value = probval
    }
    if (year == 3) {
      document.doit.probability3.value = probval
    }
    if (year == 4) {
      document.doit.probability4.value = probval
    }
  }
}

function probchange (year) {

   if (!isNumber (document.doit.probability0.value)) {document.doit.probability0.value = 50}
   if (document.doit.probability0.value < 0) {document.doit.probability0.value = .1}
   if (document.doit.probability0.value > 99.9) {document.doit.probability0.value = 99.9}
   myprob = document.doit.probability0.value / 100
   document.doit.probability1.value = document.doit.probability0.value
   document.doit.probability2.value = document.doit.probability0.value
   document.doit.probability3.value = document.doit.probability0.value
   document.doit.probability4.value = document.doit.probability0.value


  seds0 = whatseds (myprob, eval('cp0'))
  seds1 = whatseds (myprob, eval('cp1'))
  seds2 = whatseds (myprob, eval('cp2'))
  seds3 = whatseds (myprob, eval('cp3'))
  seds4 = whatseds (myprob, eval('cp4'))

  document.doit.sediment0.value = rounder(seds0,2)
  document.doit.sediment1.value = rounder(seds1,2)
  document.doit.sediment2.value = rounder(seds2,2)
  document.doit.sediment3.value = rounder(seds3,2)
  document.doit.sediment4.value = rounder(seds4,2)

  printprobs()

}

function old_probchange (year) {

// alert ('probchange')
//  document.doit.sediment.value = ''

  if (year < 0) {year = 0}
  if (year > 4) {year = 4}
  if (year == 0) {
   if (!isNumber (document.doit.probability0.value)) {document.doit.probability0.value = 50}
   if (document.doit.probability0.value < 0) {document.doit.probability0.value = .1}
   if (document.doit.probability0.value > 99.9) {document.doit.probability0.value = 99.9}
   myprob = document.doit.probability0.value / 100
  }
  if (year == 1) {
   if (!isNumber (document.doit.probability1.value)) {document.doit.probability1.value = 50}
   if (document.doit.probability1.value < 0) {document.doit.probability1.value = .1}
   if (document.doit.probability1.value > 99.9) {document.doit.probability1.value = 99.9}
   myprob = document.doit.probability1.value / 100
  }
  if (year == 2) {
   if (!isNumber (document.doit.probability2.value)) {document.doit.probability2.value = 50}
   if (document.doit.probability2.value < 0) {document.doit.probability2.value = .1}
   if (document.doit.probability2.value > 99.9) {document.doit.probability2.value = 99.9}
   myprob = document.doit.probability2.value / 100
  }
  if (year == 3) {
   if (!isNumber (document.doit.probability3.value)) {document.doit.probability3.value = 50}
   if (document.doit.probability3.value < 0) {document.doit.probability3.value = .1}
   if (document.doit.probability3.value > 99.9) {document.doit.probability3.value = 99.9}
   myprob = document.doit.probability3.value / 100
  }
  if (year == 4) {
   if (!isNumber (document.doit.probability4.value)) {document.doit.probability4.value = 50}
   if (document.doit.probability4.value < 0) {document.doit.probability4.value = .1}
   if (document.doit.probability4.value > 99.9) {document.doit.probability4.value = 99.9}
   myprob = document.doit.probability4.value / 100
  }

//  if (year == 0) {seds = whatseds (myprob, cp0)}
//  if (year == 1) {seds = whatseds (myprob, cp1)}
//  if (year == 2) {seds = whatseds (myprob, cp2)}
//  if (year == 3) {seds = whatseds (myprob, cp3)}
//  if (year == 4) {seds = whatseds (myprob, cp4)}
  seds = whatseds (myprob, eval('cp'+year))
//  what = eval('document.doit.sediment'+year)
//  alert('probchange: what '+what)
//  document.doit.sediment.value = seds
  if (year == 0) {document.doit.sediment0.value = rounder(seds,2)}
  if (year == 1) {document.doit.sediment1.value = rounder(seds,2)}
  if (year == 2) {document.doit.sediment2.value = rounder(seds,2)}
  if (year == 3) {document.doit.sediment3.value = rounder(seds,2)}
  if (year == 4) {document.doit.sediment4.value = rounder(seds,2)}

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

function showtable () {

  newin = window.open('','ERMiT_prob_table','width=600,height=300,scrollbars=yes,resizable=yes')
  newin.document.open()
  newin.document.writeln('<HEAD><title>ERMiT probability table<\/title><\/HEAD>')
  newin.document.writeln('<body bgcolor="ivory" onLoad="top.window.focus()">')
  newin.document.writeln('<table border=1 cellpadding=5>')
  newin.document.writeln(' <tr><th rowspan=2 bgcolor=ffff99>sediment delivery<br>kg m<sup>-1</sup><\/th>')
//  newin.document.writeln('     <th colspan=5 bgcolor=ffff99>Probability(x>X)<\/th><\/tr>')
    newin.document.writeln('     <th colspan=5 bgcolor=ffff99>Percent chance that sediment delivery will be exceeded<\/th><\/tr>')
  newin.document.write('<tr><th bgcolor=ffff99>year 0<\/th>')
  newin.document.write('<th bgcolor=ffff99>year 1<\/th>')
  newin.document.write('<th bgcolor=ffff99>year 2<\/th>')
  newin.document.write('<th bgcolor=ffff99>year 3<\/th>')
  newin.document.writeln('<th bgcolor=ffff99>year 4</tr>')
  for (var i=1; i<= sed_del.length; i++) {
   newin.document.write(' <tr><td align=right bgcolor=ffff99><b>' + sed_del[i]+'<\/b><\/td>')
   newin.document.write(' <td>' + rounder(cp0[i]*100,2)+'<\/td>')
   newin.document.write(' <td>' + rounder(cp1[i]*100,2)+'<\/td>')
   newin.document.write(' <td>' + rounder(cp2[i]*100,2)+'<\/td>')
   newin.document.write(' <td>' + rounder(cp3[i]*100,2)+'<\/td>')
   newin.document.writeln('<td>' + rounder(cp4[i]*100,2)+'<\/td></tr>')
  }
  newin.document.writeln('</table>')
  newin.document.writeln('</body>')
  newin.document.writeln('</html>')
  newin.document.close()
}

function printprobs() {

  newin = window.open('','ERMiT_prob_table','width=600,height=300,scrollbars=yes,resizable=yes')
  newin.document.open()
  newin.document.writeln('<HEAD><title>ERMiT probability table<\/title><\/HEAD>')
  newin.document.writeln(' <body bgcolor="ivory" onLoad="top.window.focus()">')
  newin.document.writeln('  <font face="tahoma"> ')
//  newin.document.writeln('   Sediment delivery ranges from ')
//  newin.document.write  ()
//  newin.document.write  (' to')
//  newin.document.write  ()
//  newin.document.writeln(' kg m-1<br>')
//  newin.document.write  ('   There is a ')
//  newin.document.write  () 
//  newin.document.writeln('% chance of sediment delivery the year following the fire.<br>')
  newin.document.write  ('   There is a ')
  newin.document.write  (document.doit.probability0.value)
  newin.document.write  ('% chance that sediment yield will exceed ')
  newin.document.write  (document.doit.sediment0.value)
  newin.document.writeln('    kg m<sup>-1</sup> in the first year following the fire.<br>')
  newin.document.write  ('   There is a ')
  newin.document.write  (document.doit.probability1.value)
  newin.document.write  ('% chance that sediment yield will exceed ')
  newin.document.write  (document.doit.sediment1.value)
  newin.document.writeln('    kg m<sup>-1</sup> in the second year following the fire.<br>')
  newin.document.write  ('   There is a ')
  newin.document.write  (document.doit.probability2.value)
  newin.document.write  ('% chance that sediment yield will exceed ')
  newin.document.write  (document.doit.sediment2.value)
  newin.document.writeln('    kg m<sup>-1</sup> in the third year following the fire.<br>')
  newin.document.write  ('   There is a ')
  newin.document.write  (document.doit.probability3.value)
  newin.document.write  ('% chance that sediment yield will exceed ')
  newin.document.write  (document.doit.sediment3.value)
  newin.document.writeln('    kg m<sup>-1</sup> in the fourth year following the fire.<br>')
  newin.document.write  ('   There is a ' + document.doit.probability4.value)
  newin.document.writeln('% chance that sediment yield will exceed ' + document.doit.sediment4.value + ' kg m<sup>-1</sup> in the fifth year following the fire.<br>')
  newin.document.writeln('  </font>')
  newin.document.writeln(' </body>')
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

# ------------------------ end of subroutines ----------------------------

