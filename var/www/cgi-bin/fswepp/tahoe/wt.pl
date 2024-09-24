#! /usr/bin/perl

use warnings;
use CGI qw(escapeHTML);
use Scalar::Util 'looks_like_number';
use lib '/var/www/cgi-bin/fswepp/dry';
use CligenUtils qw(CreateCligenFile GetParSummary);

#
# wt.pl        Tahoe Basin Sediment Model
#
# Tahoe Basin Sediment Model workhorse * with phosphorus *
# Reads user input from tahoe.pl, runs WEPP, parses output files

# Needed update: automatic history popup

# 2020.08.17 REB -- Removed * provisional * from header title
# 2012.10.29 DEH -- Have createSlopeFile() put a bit of a bump in the slope if it is entirely flat
# 2012.10.29 DEH -- Report WEPP calculation anomaly to user
# 2012.09.27 DEH -- Search extended output for NaN result and log run if found
# 2011.11.27 DEH -- Add phosphorus analysis, tidy up code and displays
# 2009.08.24 DEH -- Modify from wd.pl

$verbose = 0;

# $debug=1; # this likely breaks the page. wasn't tested. likely prints without ;
$weppversion = "wepp2010";

## BEGIN HISTORY ###################################
## Tahoe Basin Sediment Model version history

$version = '2014.04.38'; # Increase phosphate sediment concentration upper limit to reflect ongoing research results

#  $version = '2012.12.31';     # complete move to year-based logging (2012 through 2020)
#  $version = '2012.11.13';	# Fix fines analysis to pick up varying percent silt and clay in all size classes
#  $version = '2012.11.02';	# Match Disturbed WEPP functionality of variable canopy cover in CreateManagementFileT Initial Conditions and modify .ini files
#  $version = '2012.10.29';	# Have createSlopeFile() put a bit of a bump in the slope if it is entirely flat
#  $version = '2012.10.25';	# formatting changes
#  $version = '2012.08.31';	# bring in future climate capabilities
#  $version = '2012.07.23';	# nicer formatting for precip- etc. table
#  $version = '2012.07.18';	# continue fines calculations
#  $version = '2012.04.25';	# add fines analysis
#  $version = '2012.04.09';	# move phosphorus inputs to input table; interaction not needed
#  $version = '2011.12.09';     # combine phosphorus table with precipitation/erosion table
#  $version = '2011.11.30';	# read WEPP water file to determine lateral flow
#  $version = '2011.11.27';	# Continue putting phosphorus table in
#  $version = '2011.11.18';	# Start putting phosphorus table in
#  $version = '2011.02.14';     # Adjust handling of sod and bunchgrass
#  $version = '2010.06.01';	# Model release
#! $version = "2010.05.27";
#! $version = "2010.03.03";

## END HISTORY ###################################

print "Content-type: text/html\n\n";

#=========================================================================

&ReadParse(*parameters);    # 2012.08.31 DEH
$CL             = escapeHTML( $parameters{'Climate'} );
$soil           = escapeHTML( $parameters{'SoilType'} );
$treat1         = escapeHTML( $parameters{'UpSlopeType'} );
$ofe1_length    = escapeHTML( $parameters{'ofe1_length'} ) + 0;
$ofe1_top_slope = escapeHTML( $parameters{'ofe1_top_slope'} ) + 0;
$ofe1_mid_slope = escapeHTML( $parameters{'ofe1_mid_slope'} ) + 0;
$ofe1_pcover    = escapeHTML( $parameters{'ofe1_pcover'} ) + 0;
$ofe1_rock      = escapeHTML( $parameters{'ofe1_rock'} ) + 0;
$treat2         = escapeHTML( $parameters{'LowSlopeType'} );
$ofe2_length    = escapeHTML( $parameters{'ofe2_length'} ) + 0;
$ofe2_mid_slope = escapeHTML( $parameters{'ofe2_top_slope'} ) + 0;
$ofe2_bot_slope = escapeHTML( $parameters{'ofe2_bot_slope'} ) + 0;
$ofe2_pcover    = escapeHTML( $parameters{'ofe2_pcover'} ) + 0;
$ofe2_rock      = escapeHTML( $parameters{'ofe2_rock'} ) + 0;
$ofe_area       = escapeHTML( $parameters{'ofe_area'} ) + 0;
$action =
    escapeHTML( $parameters{'actionc'} )
  . escapeHTML( $parameters{'actionv'} )
  . escapeHTML( $parameters{'actionw'} )
  . escapeHTML( $parameters{'ActionCD'} );
$me          = escapeHTML( $parameters{'me'} );
$units       = escapeHTML( $parameters{'units'} );
$achtung     = escapeHTML( $parameters{'achtung'} );
$climyears   = escapeHTML( $parameters{'climyears'} );
$description = escapeHTML( $parameters{'description'} );

#  determine which week the model is being run, for recording in the weekly runs log

#   $thisday   -- day of the year (1..365)
#   $thisyear  -- year of the run (ie, 2012)
#   $dayoffset -- account for which day of the week Jan 1 is: -1: Su; 0: Mo; 1: Tu; 2: We; 3: Th; 4: Fr; 5: Sa.

$thisday  = 1 + (localtime)[7];      # $yday, day of the year (0..364)
$thisyear = 1900 + (localtime)[5];

if    ( $thisyear == 2010 ) { $dayoffset = 4 }     # Jan 1 is Friday
elsif ( $thisyear == 2011 ) { $dayoffset = 5 }     # Jan 1 is Saturday
elsif ( $thisyear == 2012 ) { $dayoffset = -1 }    # Jan 1 is Sunday
elsif ( $thisyear == 2013 ) { $dayoffset = 1 }     # Jan 1 is Tuesday
elsif ( $thisyear == 2014 ) { $dayoffset = 2 }     # Jan 1 is Wednesday
elsif ( $thisyear == 2015 ) { $dayoffset = 3 }     # Jan 1 is Thursday
elsif ( $thisyear == 2016 ) { $dayoffset = 4 }     # Jan 1 is Friday
elsif ( $thisyear == 2017 ) { $dayoffset = -1 }    # Jan 1 is Sunday
elsif ( $thisyear == 2018 ) { $dayoffset = 0 }     # Jan 1 is Monday
elsif ( $thisyear == 2019 ) { $dayoffset = 1 }     # Jan 1 is Tuesday
elsif ( $thisyear == 2020 ) { $dayoffset = 2 }     # Jan 1 is Wednesday
elsif ( $thisyear == 2021 ) { $dayoffset = 4 }     # Jan 1 is Friday
elsif ( $thisyear == 2022 ) { $dayoffset = 5 }     # Jan 1 is Saturday
elsif ( $thisyear == 2023 ) { $dayoffset = -1 }    # Jan 1 is Sunday
elsif ( $thisyear == 2024 ) { $dayoffset = 0 }     # Jan 1 is Monday
elsif ( $thisyear == 2025 ) { $dayoffset = 2 }     # Jan 1 is Wednesday
else                        { $dayoffset = 0 }

$thisdayoff = $thisday + $dayoffset;
$thisweek   = 1 + int $thisdayoff / 7;

#  print "[$dayoffset] Julian day $thisday, $thisyear: week $thisweek\n";

# future climates
$fc          = escapeHTML( $parameters{'fc'} );    # future climate input screen
$startYear   = escapeHTML( $parameters{'startyear'} );    # DEH 2012.08.27
$fullCliFile = escapeHTML( $CL . '.cli' );                # DEH 2012.08.21

# fines
$fines_upper = escapeHTML( $parameters{'fines_upper'} )
  ;    # upper limit for fines analysis (microns) [4..62.5]

# phosphorus concentration parameter input values

$sr_conc = escapeHTML( $parameters{'sr_conc'} )
  ;    # surface runoff phosphorus concentration
$lf_conc =
  escapeHTML( $parameters{'lf_conc'} );  # lateral flow phosphorus concentration
$sed_conc =
  escapeHTML( $parameters{'sed_conc'} );    # sediment phosphorus concentration

$sr_conc_in        = $sr_conc;
$lf_conc_in        = $lf_conc;
$sed_conc_in       = $sed_conc;
$sr_conc_color[0]  = 'red';
$sr_conc_color[1]  = 'black';
$lf_conc_color[0]  = 'red';
$lf_conc_color[1]  = 'black';
$sed_conc_color[0] = 'red';
$sed_conc_color[1] = 'black';

$sr_conc_min = 0;
$sr_conc_max = 4;
$sr_conc_def = 1;      # mg/l
$lf_conc_min = 0;
$lf_conc_max = 4;
$lf_conc_def = 1.5;    # mg/l

#  $sed_conc_min= 0; $sed_conc_max = 200; $sed_conc_def = 100;	# mg/kg
$sed_conc_min = 0;
$sed_conc_max = 2000;
$sed_conc_def = 1000;    # mg/kg  2014.04.18 DEH
$sr_conc_ok   = 1;
$lf_conc_ok   = 1;
$sed_conc_ok  = 1;

if ( looks_like_number $sr_conc) {
    if ( $sr_conc <= $sr_conc_min ) { $sr_conc = $sr_conc_min; $sr_conc_ok = 0 }
    if ( $sr_conc >= $sr_conc_max ) { $sr_conc = $sr_conc_max; $sr_conc_ok = 0 }
}
else {
    { $sr_conc = $sr_conc_def; $sr_conc_ok = 0 };
}

#  if ($sr_conc !~ /^-?(?:\d+(?:\.\d*)?&\.\d+)$/) {$sr_conc = $sr_conc_def; $sr_conc_ok=0};	# match decimal number
if ( looks_like_number $lf_conc) {
    if ( $lf_conc <= $lf_conc_min ) { $lf_conc = $lf_conc_min; $lf_conc_ok = 0 }
    if ( $lf_conc >= $lf_conc_max ) { $lf_conc = $lf_conc_max; $lf_conc_ok = 0 }
}
else {
    { $lf_conc = $lf_conc_def; $lf_conc_ok = 0 };
}
if ( looks_like_number $sed_conc) {
    if ( $sed_conc <= $sed_conc_min ) {
        $sed_conc    = $sed_conc_min;
        $sed_conc_ok = 0;
    }
    if ( $sed_conc >= $sed_conc_max ) {
        $sed_conc    = $sed_conc_max;
        $sed_conc_ok = 0;
    }
}
else {
    { $sed_conc = $sed_conc_def; $sed_conc_ok = 0 };
}

### filter bad stuff out of description ###
#   limit length to reasonable (200?)
#   remove HTML tags ( '<' to &lt; and '>' to &gt; )
$description = substr( $description, 0, 100 );
$description =~ s/</&lt;/g;
$description =~ s/>/&gt;/g;
###

$tahoe = "/cgi-bin/fswepp/tahoe/tahoe.pl";

if ( lc($action) =~ /custom/ ) {
    exec "../rc/rockclim.pl -server -i$me -u$units $tahoe";
    die;
}    # /custom/

if ( lc($achtung) =~ /describe climate/ ) {
    if ($fc) {
        exec "../rc/desccli.pl $CL $units";
    }
    else {
        exec "../rc/descpar.pl $CL $units $tahoe";
    }
    die;
}    # /describe climate/

if ( lc($achtung) =~ /describe soil/ ) {    ##########
    $units    = escapeHTML( $parameters{'units'} );
    $SoilType = escapeHTML( $parameters{'SoilType'} );
    $soilPath = 'data/';

    $surf = "";
    if ( substr( $surface, 0, 1 ) eq "g" ) { $surf = "g" }
    $soilFile = '3' . $surf . $SoilType . $conduct . '.sol';

    $soilFilefq = $soilPath . $soilFile;
    print "Content-Type: text/html\n\n";
    print '<HTML>
 <HEAD>
  <meta http-equiv="content-type" content="text/html; charset=UTF-8">
  <TITLE>Tahoe Basin Sediment Model -- Soil Parameters</TITLE>
  <link rel="stylesheet" type="text/css" href="/fswepp/notebook.css">
 </HEAD>
 <BODY>
  <font face="Arial, Geneva, Helvetica">
   <blockquote>
    <table width=95% border=0>
     <tr>
      <td> 
       <a href="JavaScript:window.history.go(-1)">
       <IMG src="/fswepp/images/tahoe.jpg"
       align="left" alt="Back to FS WEPP menu" border=1></a>
      </td>
      <td align=center>
       <hr>
       <h3>Tahoe Basin Sediment Model Soil Texture Properties</h3>
       <hr>
      </td>
     </tr>
    </table>
';
    if ($verbose) { print "Action: '$action'<br>\nAchtung: '$achtung'<br>\n"; }

    $working  = '../working';
    $unique   = 'wepp-' . $$;                  # DEH 01/13/2004
    $soilFile = "$working/$unique" . '.sol';
    $soilPath = 'data/';

    &CreateSoilFile;

    open SOIL, "<$soilFile";
    $weppver = <SOIL>;
    $comment = <SOIL>;
    while ( substr( $comment, 0, 1 ) eq "#" ) {
        chomp $comment;

        #       print $comment,"\n";
        $comment = <SOIL>;
    }

    print "
  <center>
   <table border=0 cellpadding=3>
";

    #      $solcom = $comment;

    $record = <SOIL>;
    @vals   = split " ", $record;
    $ntemp  = @vals[0];    # no. flow elements or channels
    $ksflag = @vals[1];    # 0: hold hydraulic conductivity constant
                           # 1: use internal adjustments to hydr con
    for $i ( 1 .. $ntemp ) {
        print "
   <tr>
    <th colspan=5 bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica'>
     Element $i &mdash;
";
        $record      = <SOIL>;
        @descriptors = split "'", $record;

        #      $my_soilID = lc(@descriptors[1]);
        #      $my_texture =lc(@descriptors[3]);
        $my_soilID  = @descriptors[1];
        $my_texture = @descriptors[3];
        print "$my_soilID treatment;&nbsp;&nbsp;   ";    # slid:
        print "$my_texture soil texture\n";              # texid: soil texture
        ( $nsl, $salb, $sat, $ki, $kr, $shcrit, $avke ) = split " ",
          @descriptors[4];

        #      @vals = split " ", @descriptors[4];
        #      print "No. soil layers: $nsl\n";
        $avke_e = sprintf "%.2f", $avke / 25.4;

        print "
      </font>
     </th>
    </tr>
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Albedo of the bare dry surface soil</font></th>
     <td align=right valign=bottom><font face=\"Arial, Geneva, Helvetica\" size=-1>$salb</font></td>
     <td>&nbsp;</td>
    </tr>
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Initial saturation level of the soil profile porosity</font></th>
     <td align=right valign=bottom><font face=\"Arial, Geneva, Helvetica\" size=-1>$sat</font></td>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>m m<sup>-1</sup></font></td>
    </tr>
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Baseline interrill erodibility parameter (<i>k<sub>i</sub></i> )</font></th>
     <td align=right valign=bottom><font face=\"Arial, Geneva, Helvetica\" size=-1>$ki</font></td>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>kg s m<sup>-4</sup></font></td>
    </tr>
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Baseline rill erodibility parameter (<i>k<sub>r</sub></i> )</font></th>
     <td align=right valign=bottom><font face=\"Arial, Geneva, Helvetica\" size=-1>$kr</font></td>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>s m<sup>-1</sup></font></td>
    </tr>
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Baseline critical shear parameter</font></th>
     <td align=right valign=bottom><font face=\"Arial, Geneva, Helvetica\" size=-1>$shcrit</font></td>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>N m<sup>-2</sup></font></td>
    </tr>
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Effective hydraulic conductivity of surface soil</font></th>
     <td align=right valign=bottom><font face=\"Arial, Geneva, Helvetica\" size=-1>$avke</font></td>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>mm h<sup>-1</sup></font></td>
     <td align=right valign=bottom><font face=\"Arial, Geneva, Helvetica\" size=-1>$avke_e</font></td>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>in hr<sup>-1</sup></font></td>
    </tr>
";
        for $layer ( 1 .. $nsl ) {
            $record = <SOIL>;
            ( $solthk, $sand, $clay, $orgmat, $cec, $rfg ) = split " ", $record;
            $solthk_e = sprintf "%.2f", $solthk / 25.4;
            print "
    <tr>
     <td>&nbsp;</font></td>
     <th colspan=4 bgcolor=\"85d2d2\"><font face=\"Arial, Geneva, Helvetica\">layer $layer</font></th>
    </tr>
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Depth from soil surface to bottom of soil layer</font></th>
     <td align=right valign=bottom><font face=\"Arial, Geneva, Helvetica\" size=-1>$solthk</font></td>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>mm</font></td>
     <td align=right valign=bottom><font face=\"Arial, Geneva, Helvetica\" size=-1>$solthk_e</font></td>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>in</font></td>
    </tr>
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Percentage of sand</font></th>
     <td align=right valign=bottom><font face=\"Arial, Geneva, Helvetica\" size=-1>$sand</font></td>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>%</font></td>
    </tr>
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Percentage of clay</font></th>
     <td align=right valign=bottom><font face=\"Arial, Geneva, Helvetica\" size=-1>$clay</font></td>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>%</font></td>
    </tr>
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Percentage of organic matter (by volume)</font></th>
     <td align=right valign=bottom><font face=\"Arial, Geneva, Helvetica\" size=-1>$orgmat</font></td>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>%</font></td>
    </tr>
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Cation exchange capacity</font></th>
     <td align=right valign=bottom><font face=\"Arial, Geneva, Helvetica\" size=-1>$cec</font></td>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>meq per 100 g of soil</font></td>
    </tr>
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Percentage of rock fragments (by volume)</font></th>
     <td align=right valign=bottom><font face=\"Arial, Geneva, Helvetica\" size=-1>$rfg</font></td>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>%</font></td>
    </tr>
";
        }
    }
    close SOIL;

    #           <form method="post" action="',$soilFilefq,'">
    print '   </table>
  <p>
  <hr>
  <p>
<!-- <form method="post" action="wepproad.sol">
    <input type="submit" value="DOWNLOAD">
    <input type="hidden" value="', $soilFile, '" name="filename">
   </form>
-->
';
    open SOIL, "<$soilFile";
    print '
   </center>
   <p>
   <pre>
';
    print <SOIL>;
    print '
   </pre>
  </blockquote>
 </body>
</html>
';
    unlink $soilFile;    # DEH 01/13/2004
    die;
}    #  /describe soil/

# *******************************

# ########### RUN WEPP ###########

$years2sim = $climyears;
if ( $years2sim > 100 ) { $years2sim = 100 }

#  $years2sim = 2;                 # DEH 2012.08.21  TEMP

#  if ($host eq "") {$host = 'unknown';}
$unique = 'wepp-' . $$;
if ($verbose) { print 'Unique? filename= ', $unique, "\n<BR>"; }

$working      = '../working';
$unique       = 'wepp' . '-' . $$;
$responseFile = "$working/$unique" . '.in';
$outputFile   = "$working/$unique" . '.out';
$soilFile     = "$working/$unique" . '.sol';
$slopeFile    = "$working/$unique" . '.slp';
$cropFile     = "$working/$unique" . '.crp';
$stoutFile    = "$working/$unique" . ".stout";
$sterFile     = "$working/$unique" . ".sterr";
$manFile      = "$working/$unique" . ".man";
$WatBalFile   = "$working/$unique" . ".water";
$soilPath     = 'data/';
$manPath      = 'data/';

# make hash of treatments

$treatments           = {};
$treatments{Skid}     = 'skid trail';
$treatments{BurnP}    = 'burn pile';            # 2012.09.07
$treatments{HighFire} = 'high severity fire';
$treatments{LowFire}  = 'low severity fire';

#  $treatments{Bunchgrass} = 'poor grass';
#  $treatments{Sod}        = 'good grass';
$treatments{Bunchgrass}  = 'good grass';
$treatments{Sod}         = 'poor grass';
$treatments{Shrub}       = 'shrubs';
$treatments{Bare}        = 'bare';
$treatments{Mulch}       = 'mulch only';
$treatments{Till}        = 'mulch and till';
$treatments{LowRoad}     = 'low traffic road';
$treatments{HighRoad}    = 'high traffic road';
$treatments{YoungForest} = 'thin or young forest';
$treatments{OldForest}   = 'mature forest';

# make hash of soil types

$soil_type           = {};
$soil_type{granitic} = 'granitic';
$soil_type{volcanic} = 'volcanic';
$soil_type{alluvial} = 'alluvial';
$soil_type{rockpave} = 'rock/pavement';

# ----------------------------

$host = $ENV{REMOTE_HOST};

$user_ofe1_length = $ofe1_length;
$user_ofe2_length = $ofe2_length;

$rcin = &checkInput;
if ( $rcin eq '' ) {

    if ( $units eq 'm' ) {

        #      $user_ofe1_length=$ofe1_length;
        #      $user_ofe2_length=$ofe2_length;
        $user_ofe_area = $ofe_area;
    }
    else {
        #      $user_ofe1_length=$ofe1_length;
        #      $user_ofe2_length=$ofe2_length;
        $user_ofe_area = $ofe_area;
        $ofe1_length   = $ofe1_length / 3.28;    # 3.28 ft == 1 m
        $ofe2_length   = $ofe2_length / 3.28;    # 3.28 ft == 1 m
        $ofe_area =
          $ofe_area / 2.47;   # 2.47 ac == 1 ha; Schwab Fangmeier Elliot Frevert
    }

    $ofe_width = $ofe_area * 10000 / ( $ofe1_length + $ofe2_length );

    if ($verbose) { print "Creating Slope File<br>\n"; }
    &CreateSlopeFile;
    if ($verbose) { print "Creating Management File<br>\n"; }

    #     &CreateManagementFile;
    &CreateManagementFileT;
    if ($fc) {
        if ($verbose) { print "Extracting Climate File<br>\n"; }
        &ExtractCligenFile;    # 2012.08.31 DEH
    }
    else {
        if ($verbose) { print "Creating Climate File<br>\n"; }
        ($climateFile, $climatePar) = &CreateCligenFile($CL, $unique, $years2sim, $debug);
    }
    if ($verbose) { print "Creating Soil File<br>\n"; }
    &CreateSoilFile;
    if ($verbose) { print "Creating WEPP Response File<br>\n" }
    &CreateResponseFile;

    @args = ("../$weppversion <$responseFile >$stoutFile 2>$sterFile");
    system @args;

########################  start HTML output ###############

    print '<HTML>
 <HEAD>
  <TITLE>Tahoe Basin Sediment Model Results</TITLE>
  <script type=text/javascript>

<!--             phosphorus table calculations start         -->

   function erase_sr_delivery() {
     document.getElementById("sr_delivery").innerHTML="";
     document.getElementById("total").innerHTML="";
   }
   function erase_lf_delivery() {
     document.getElementById("lf_delivery").innerHTML="";
     document.getElementById("total").innerHTML="";
   }
   function erase_sed_delivery() {
     document.getElementById("sed_delivery").innerHTML="";
     document.getElementById("total").innerHTML="";
   }
   function calc_sr_delivery() {
     //  D mm x 10,000 sq m/ha x 1 m/1000mm x 1000 l/cu m = 10,000 D l/mm 
     //  10,000 D l/mm x C mg/l x 1 kg/1,000,000 mg = D * C / 100 kg/ha
     //  where D = depth of surface runoff (mm)
     //        C = concentration of phosphorous in surface runoff (mg/l)
     val=""
//   D = 14.6;    // ****
     rro=parseFloat(phosphate.rro.value)    // triggers a warning to use rro=document.getElementById("rro").innerHTML
     sro=parseFloat(phosphate.sro.value)    // sro=document.getElementById("sro").innerHTML
     D = rro+sro
     if (form_input_is_numeric(phosphate.sr_conc.value)) {
       val = D * phosphate.sr_conc.value / 100
       // if browser supports toFixed() method		www.javascriptkit.com/javatutors/formatnumber.shtml
       if (val.toFixed) val = val.toFixed(2)
     }
     document.getElementById("sr_delivery").innerHTML=val;
   }
   function calc_lf_delivery() {
     val=""
     //  D mm x 10,000 sq m/ha x 1 m/1000mm x 1000 l/cu m = 10,000 D l/mm 
     //  10,000 D l/mm x C mg/l x 1 kg/1,000,000 mg = D * C / 100 kg/ha
     //  where D = depth of lateral flow (mm)
     //        C = concentration of phosphorous in lateral flow (mg/l)
     val=""
//   D = 40;    // ****
     D = phosphate.lf.value		
// alert("lat "+D);
     if (form_input_is_numeric(phosphate.lf_conc.value)) {
       val = D * phosphate.lf_conc.value / 100
       if (val.toFixed) val = val.toFixed(2)
     }
     document.getElementById("lf_delivery").innerHTML=val;
   }
   function calc_sed_delivery() {
     // S t/ha * 1,000 kg/t * C mg/kg * 1 kg/1,000,000 mg x SSA = S * C * SSA / 1,000 kg/ha
     // where S = sediment leaving profile (t/ha)
     //       C = concentration of phosphoros in eroded sediment (likely the same as on the hill)
     //     SSA = average annual SSA enrichment ratio leaving profile
     val=""
     S = phosphate.sed.value
     SSA = phosphate.SSA.value
//   alert (" S: " + S + " SSA: " + SSA + "conc: " + phosphate.sed_conc.value)
     if (form_input_is_numeric(phosphate.sed_conc.value) && form_input_is_numeric(phosphate.SSA.value) && form_input_is_numeric(phosphate.sed.value)) {
       val=S * phosphate.sed_conc.value * SSA / 1000;
       if (val.toFixed) val = val.toFixed(2)
     }
     document.getElementById("sed_delivery").innerHTML=val;
   }
   function calc_total_delivery() {
     sr_num=form_input_is_numeric(phosphate.sr_conc.value);
     lf_num=form_input_is_numeric(phosphate.lf_conc.value);
     sed_num=form_input_is_numeric(phosphate.sed_conc.value);
     val=""
     if (sr_num && lf_num && sed_num) {
       sr_del =parseFloat(document.getElementById("sr_delivery").innerHTML)
       lf_del =parseFloat(document.getElementById("lf_delivery").innerHTML)
       sed_del=parseFloat(document.getElementById("sed_delivery").innerHTML)
       val=sr_del + lf_del + sed_del
       if (val.toFixed) val = val.toFixed(2)
     }
     document.getElementById("total").innerHTML=val;
   }
   function calc_delivery() {
     calc_sr_delivery()
     calc_lf_delivery()
     calc_sed_delivery()
     calc_total_delivery()
   }
  function form_input_is_numeric(input) {       
    return !isNaN(input);
  }
  function markRunoffs($i) {
    if ($i) {
      document.getElementById("rro").style.background="#e18b6b"
      document.getElementById("sro").style.background="#e18b6b"
    } else {
      document.getElementById("rro").style.background="#e0ffff"
      document.getElementById("sro").style.background="#e0ffff"
    }
  }
  function markLatFlow($i) {
    if ($i) {
      document.getElementById("lat").style.background="#e18b6b"
    } else {
      document.getElementById("lat").style.background="#e0ffff"
    }
  }
  function markSed($i) {
    if ($i) {
      document.getElementById("sed").style.background="#e18b6b"
    } else {
      document.getElementById("sed").style.background="#e0ffff"
    }
  }
  function markDeliveries($i) {
    if ($i) {
      document.getElementById("srDel").style.background="#e18b6b"
      document.getElementById("lfDel").style.background="#e18b6b"
      document.getElementById("sedDel").style.background="#e18b6b"
    } else {
      document.getElementById("srDel").style.background="#e0ffff"
      document.getElementById("lfDel").style.background="#e0ffff"
      document.getElementById("sedDel").style.background="#e0ffff"
    }
  }
  function markLatCalc($i) {
    if ($i) {
      document.getElementById("len_top").style.background="#e18b6b"
      document.getElementById("len_bot").style.background="#e18b6b"
      document.getElementById("years").style.background="#e18b6b"
      document.getElementById("sumLat").style.background="#e18b6b"
    } else {
      document.getElementById("len_top").style.background="#faf8cc"
      document.getElementById("len_bot").style.background="#faf8cc"
      document.getElementById("years").style.background="#faf8cc"
      document.getElementById("sumLat").style.background="#e0ffff"
    }
  }
  function markSrCalc($i) {
//   alert ("markSrCalc")
    if ($i) {
      document.getElementById("avg_rro").style.background="#e18b6b"
      document.getElementById("avg_sro").style.background="#e18b6b"
      document.getElementById("srConc").style.background="#e18b6b"
    } else {
      document.getElementById("avg_rro").style.background="#e0ffff"
      document.getElementById("avg_sro").style.background="#e0ffff"
      document.getElementById("srConc").style.background="#faf8cc"
    }
    markRunoffs($i)
  }
  function markLfCalc($i) {
    if ($i) {
      document.getElementById("lfAmt").style.background="#e18b6b"
      document.getElementById("lfConc").style.background="#e18b6b"
    } else {
      document.getElementById("lfAmt").style.background="#e0ffff"
      document.getElementById("lfConc").style.background="#faf8cc"
    }
  }
  function markSedCalc($i) {
    if ($i) {
      document.getElementById("sedAmt").style.background="#e18b6b"
      document.getElementById("sedConc").style.background="#e18b6b"
      document.getElementById("ssa_").style.background="#e18b6b"
    } else {
      document.getElementById("sedAmt").style.background="#e0ffff"
      document.getElementById("sedConc").style.background="#faf8cc"
      document.getElementById("ssa_").style.background="#e0ffff"
    }
  }
  function markAvgSed($i) {
    if ($i) {
      document.getElementById("sedAmt").style.background="#e18b6b"
    } else {
      document.getElementById("sedAmt").style.background="#e0ffff"
    }
  }
  function markClayRatio($i) {
    if ($i) {
      document.getElementById("ClayRatio").style.background="#e18b6b"
    } else {
      document.getElementById("ClayRatio").style.background="#e0ffff"
    }
  }
  function markSiltRatio($i) {
    if ($i) {
      document.getElementById("SiltRatio").style.background="#e18b6b"
    } else {
      document.getElementById("SiltRatio").style.background="#e0ffff"
    }
  }
  function markSiltLessRatio($i) {
    if ($i) {
      document.getElementById("SiltLessRatio").style.background="#e18b6b"
    } else {
      document.getElementById("SiltLessRatio").style.background="#e0ffff"
    }
  }
  function markClayDel($i) {
    if ($i) {
      document.getElementById("claydel").style.background="#e18b6b"
    } else {
      document.getElementById("claydel").style.background="#e0ffff"
    }
  }
  function markSiltLessDel($i) {
    if ($i) {
      document.getElementById("siltlessdel").style.background="#e18b6b"
    } else {
      document.getElementById("siltlessdel").style.background="#e0ffff"
    }
  }

  function explain($i) {
     $text="&nbsp;"
     if ($i==1) $text="surface runoff delivery = (average annual surface runoff) * (surface runoff concentration) / 100"
     if ($i==2) $text="lateral flow delivery = (average annual lateral flow) * (lateral flow concentration) / 100"
     if ($i==3) $text="sediment delivery = (average annual sediment) * (sediment concentration) * (SSA enrichment ratio) / 1000"
     if ($i==4) $text="total delivery = (surface runoff delivery) + (lateral flow delivery) + (sediment delivery)"
     if ($i==5) $text="Average annual lateral flow = (total lateral flow) * ((lower element length) / (hillslope length)) / years"
     document.getElementById("helptext").innerHTML=$text
  }

<!--             phosphorus table calculations end         -->

    function showslopefile() {
     var properties="menubar,scrollbars,resizable"
     filewindow = window.open("","slope",properties)
     filewindow.document.open()
     if (filewindow && filewindow.open && !filewindow.closed) {
      filewindow.focus
      filewindow.document.writeln("<html>")
      filewindow.document.writeln(" <head>")
      filewindow.document.writeln("  <title>WEPP slope file ', $unique,
      '<\/title>")
      filewindow.document.writeln(" <\/head>")
      filewindow.document.writeln(" <body>")
      filewindow.document.writeln("  <font face=\'courier\'>")
      filewindow.document.writeln("   <pre>")
';
    open WEPPFILE, "<$slopeFile";
    while (<WEPPFILE>) {
        chomp;
        print '      filewindow.document.writeln("', $_, '")', "\n";
    }
    close WEPPFILE;
    print '      filewindow.document.writeln("   <\/pre>")
      filewindow.document.writeln("  <\/font>")
      filewindow.document.writeln(" <\/body>")
      filewindow.document.writeln("<\/html>")
      filewindow.document.close()
     }
     return false
    }

    function showsoilfile() {
     var properties="menubar,scrollbars,resizable"
     filewindow = window.open("","soil",properties)
     filewindow.document.open()
     if (filewindow && filewindow.open && !filewindow.closed) {
      filewindow.focus
      filewindow.document.writeln("<head><title>WEPP soil file ', $unique,
      '<\/title><\/head>")
      filewindow.document.writeln("<body><font face=\'courier\'><pre>")
';
    open WEPPFILE, "<$soilFile";
    while (<WEPPFILE>) {
        chomp;
        print '      filewindow.document.writeln("', $_, '")', "\n";
    }
    close WEPPFILE;
    print '      filewindow.document.writeln("<\/pre><\/font><\/body><\/html>")
      filewindow.document.close()
     }
     return false
    }

    function showresponsefile() {
     var properties="menubar,scrollbars,resizable"
     filewindow = window.open("","resp",properties)
     filewindow.document.open()
     if (filewindow && filewindow.open && !filewindow.closed) {
      filewindow.focus
      filewindow.document.writeln("<head><title>WEPP response file ', $unique,
      '<\/title><\/head>")
      filewindow.document.writeln("<body><pre>")
';
    open WEPPFILE, "<$responseFile";
    while (<WEPPFILE>) {
        chomp;
        print '      filewindow.document.writeln("', $_, '")', "\n";
    }
    close WEPPFILE;
    print '      filewindow.document.writeln("<\/pre><\/body><\/html>")
      filewindow.document.close()
     }
     return false
    }

    function showvegfile() {
     var properties="menubar,scrollbars,resizable"
     filewindow = window.open("","veg",properties)
     filewindow.document.open()
     if (filewindow && filewindow.open && !filewindow.closed) {
      filewindow.focus
      filewindow.document.writeln("<head><title>WEPP vegetation file ', $unique,
      '<\/title><\/head>")
      filewindow.document.writeln("<body><pre>")
';
    $line = 0;
    open WEPPFILE, "<$manFile";
    while (<WEPPFILE>) {
        chomp;
        print '      filewindow.document.writeln("', $_, '")', "\n";
        $line += 1;

        #       last if ($line > 100);
        last if ( /Management Section/ && $years2sim > 5 );
    }
    close WEPPFILE;
    print '      filewindow.document.writeln("<\/pre><\/body><\/html>")
      filewindow.document.close()
     }
     return false
    }

    function showextendedoutput() {
     var properties="menubar,scrollbars,resizable"
     filewindow = window.open("","extendedout",properties)
     filewindow.document.open()
     if (filewindow && filewindow.open && !filewindow.closed) {
      $z=0
     }
     else {
      return false
     }
     filewindow.focus
     filewindow.document.writeln("<head><title>WEPP output file ', $unique,
      '<\/title><\/head>")
     filewindow.document.writeln("<body><font face=\'courier\'><pre>")
';
    open WEPPFILE, "<$outputFile";
    while (<WEPPFILE>) {
        chomp;
        chop;
        print '      filewindow.document.writeln("', $_, '")', "\n";
    }
    close WEPPFILE;
    print '      filewindow.document.writeln("<\/pre><\/font><\/body><\/html>")
     filewindow.document.close()
     return false
    }

    function showcligenparfile() {
     var properties="menubar,scrollbars,resizable"
     filewindow = window.open("","clipar",properties)
     filewindow.document.open()
     if (filewindow && filewindow.open && !filewindow.closed) {
      filewindow.focus
      filewindow.document.writeln("<head><title>WEPP weather file ', $unique,
      '<\/title><\/head>")
      filewindow.document.writeln("<body><pre>")
';

    open WEPPFILE, "<$climatePar";
    while (<WEPPFILE>) {
        chomp;
        chop;
        print '      filewindow.document.writeln("', $_, '")', "\n";
    }
    close WEPPFILE;
    print '      filewindow.document.writeln("<\/pre><\/body><\/html>")
      filewindow.document.close()
     }
     return false
    }
  <!-- end new 2004 -->
';

    print "
  function popuphistory() {
    height=500;
    width=660;
    pophistory = window.open('','pophistory','toolbar=no,location=no,status=no,directories=no,menubar=no,scrollbars=yes,resizable=yes,width='+width+',height='+height);
";
    print make_history_popup();

    print '
    pophistory.document.close()
    pophistory.focus()
  }
  </script>
  <link rel="stylesheet" type="text/css" href="/fswepp/notebook.css">
 </HEAD>
 <BODY>
  <font face="Arial, Geneva, Helvetica">
  <blockquote>
   <table width=100% border=0>
    <tr>
     <td>
      <a href="JavaScript:window.history.go(-1)">
      <IMG src="/fswepp/images/tahoe.jpg"
      align="left" alt="Return to Tahoe Basin Sediment Model input screen" border=1></a>
     <td align=center>
      <hr>
      <h3>Tahoe Basin Sediment Model Results</h3>
      <hr>
     </td>
    </tr>
   </table>
';

######################## end of top part of HTML output ###############

    #------------------------------

    # 2010.05.15 #

    open weppstout, "<$stoutFile";

    $found = 0;
    while (<weppstout>) {
        if (/SUCCESSFUL/) {
            $found = 1;
            last;
        }
    }
    close(weppstout);

# print "******************************** found: $found ***************************<br><br>\n";

########################   NAN check   ###################

    open weppoutfile, "<$outputFile";
    while (<weppoutfile>) {
        if (/NaN/) {
            open NANLOG, ">>../working/NANlog.log";
            flock( NANLOG, 2 );
            print NANLOG "$user_ID_\t";

            #        print NANLOG "WTpfc\t$unique\n";
            print NANLOG "WT\t$version\t$unique $_";
            close NANLOG;

            $found = 5;
            print "<font color=red>\n";
            print
              "  WEPP has run into a mathematical calculation anomaly.<br>\n";
            print
"  This generally can be addressed by changing the lower element length a fraction of a foot or meter.\n";
            print "</font>\n";
            last;
        }
    }
    close(weppoutfile);

########################   NAN check   ###################

    if ( $found == 0 ) {
        open weppstout, "<$stoutFile";
        while (<weppstout>) {
            if (/ERROR/) {
                $found = 2;
                print "<font color=red>\n";
                $_ = <weppstout>;    # print;
                $_ = <weppstout>;    # print;
                $_ = <weppstout>;
                print;
                $_ = <weppstout>;
                print;
                print "</font>\n";
                last;
            }
        }
        close(weppstout);
        open weppstout, "<$stoutFile";
        while (<weppstout>) {
            if (/error #/) {
                $found = 4;
                print "<font color=red>\n";
                print;
                last;
                print "</font>\n";
            }
        }
        close(weppstout);
        open weppstout, "<$stoutFile";
        while (<weppstout>) {
            if (/\*\*\* /) {
                $found = 3;
                print "<font color=red>\n";
                $_ = <weppstout>;
                print;
                $_ = <weppstout>;
                print;
                $_ = <weppstout>;
                print;
                $_ = <weppstout>;
                print;
                print "</font>\n";
                last;
            }
        }
        close(weppstout);
    }    # $found == 0

    if ( $found == 1 ) {

        open weppout, "<$outputFile";
        $_ = <weppout>;
        if (/Annual; detailed/) { $outputfiletype = "annualdetailed" }
        $ver = 'unknown';
        while (<weppout>) {
            if (/VERSION/) {
                $weppver = lc($_);
                chomp $weppver;
                last;
            }
        }

        # ############# actual climate station name #####################

        while (<weppout>) {    ######## actual ########
            if (/CLIMATE/) {

                #          print;
                $a_c_n = <weppout>;
                $actual_climate_name =
                  substr( $a_c_n, index( $a_c_n, ":" ) + 1, 40 );
                $climate_name = $actual_climate_name;
                last;
            }
        }

#################################################################

        #      if ($outputfiletype eq "annualdetailed") {
        while (<weppout>) {
            if (/ANNUAL AVERAGE SUMMARIES/) { print ""; last }
        }

        #      }

        while (<weppout>) {
            if (/RAINFALL AND RUNOFF SUMMARY/) {
                $_        = <weppout>; #      -------- --- ------ -------
                $_        = <weppout>; #
                $_        = <weppout>; #       total summary:  years    1 -    1
                $simyears = substr $_, 35, 10;
                chomp $simyears;
                $simyears += 0;
                if   ( $simyears == '1' ) { $yearyears = 'year' }
                else                      { $yearyears = 'years' }
                $_ = <weppout>;        #
                $_ = <weppout>
                  ; #         71 storms produced                          346.90 mm of precipitation
                $storms = substr $_, 1, 10;
                $_ = <weppout>
                  ; #          3 rain storm runoff events produced          0.00 mm of runoff
                $rainevents = substr $_, 1, 10;
                $_          = <weppout>;    #          2 snow melts and/or
                $snowevents = substr $_, 1, 10;
                $_          = <weppout>
                  ; #              events during winter produced            0.00 mm of runoff
                $_ = <weppout>;    #
                $_ = <weppout>;    #      annual averages
                $_ = <weppout>;    #      ---------------
                $_ = <weppout>;    #
                $_ = <weppout>
                  ; #        Number of years                                    1
                $_ = <weppout>
                  ; #        Mean annual precipitation                     346.90    mm
                $precip = substr $_, 51, 10;    #print "precip: ";
                $_      = <weppout>;
                $rro    = substr $_, 51, 10;    #print;
                $_      = <weppout>;            # print;
                $_      = <weppout>;
                $sro    = substr $_, 51, 10;    #print;
                $_      = <weppout>;            # print;
                last;
            }
        }

        while (<weppout>) {
            if (/AREA OF NET SOIL LOSS/) {
                $_        = <weppout>;
                $_        = <weppout>;
                $_        = <weppout>;
                $_        = <weppout>;
                $_        = <weppout>;
                $_        = <weppout>;           # print;
                $_        = <weppout>;           # print;
                $_        = <weppout>;           # print;
                $_        = <weppout>;           # print;
                $_        = <weppout>;
                $syr      = substr $_, 17, 7;
                $effrdlen = substr $_, 9,  9;    # print;
                last;
            }
        }

        while (<weppout>) {
            if (/OFF SITE EFFECTS/) {
                $_   = <weppout>;
                $_   = <weppout>;
                $_   = <weppout>;
                $syp = substr $_, 50, 9;
                $_   = <weppout>;
                if ( $syp eq "" ) { $syp = substr $_, 10, 9 }
                $_ = <weppout>;
                $_ = <weppout>;
                last;
            }
        }
        close(weppout);

        #-----------------------------------

        &parsead;

        # ## #    START WATER BALANCE   # ## #

        #    $WatBalFile   = "$working/$unique" . '.water';
        #    $years2sim
        #    $user_ofe2_length
        #    $user_ofe1_length
        $user_total_length = $user_ofe1_length + $user_ofe2_length;

        (
            $sumP,     $sumRM, $sumQ, $sumEp, $sumEs, $sumDp, $sumLatqcc,
            $sumTotal, $firstTotalSoilWater, $lastTotalSoilWater, $OFEsoff
        ) = &WaterBalanceSum($WatBalFile);

        # print "Precip: $sumP\n";
        #     @totals = &WaterBalanceSum();
        #     @averages = map $_/$years2sim, @totals;
        # print "Total precip: $sumP\n";
        # print "Lateral flow: $sumLatqcc\n";
        # print "Total precip: $sumP\n";
        # print "Average precip: ",@averages[0];

# multiply returned lateral flow by ((bottom OFE length / total hillslope length))

        # Average lateral flow from toe
        $lateral_flow =
          ( $sumLatqcc * $user_ofe2_length / $user_total_length ) /
          $years2sim;    # mm
        $lateral_flow_u = $lateral_flow;
        $lateral_flow_u /= 25.4 if ( $units ne 'm' );    # mm or in.
        $lf_conv = 1;
        $lf_conv = 1 / 25.4 if ( $units ne 'm' );

        # ## #   END WATER BALANCE   # ## #

        $storms     = $storms * 1;
        $rainevents = $rainevents * 1;
        $snowevents = $snowevents * 1;
        $precip     = $precip * 1;
        $rro        = $rro * 1;
        $sro        = $sro * 1;
        $syr        = $syr * 1;
        $syp        = $syp * 1;
        $effrdlen   = $effrdlen * 1;
        $syra       = $syr;              # * $effrdlen * $effrdwidth;
        $sypa       = $syp;              # * $effrdwidth;

        if ( $units eq 'm' ) {
            $user_ofe_width = $ofe_width;
        }
        else {                           #  $units eq 'ft'
            $user_ofe_width = $ofe_width * 3.28    # 1 m = 3.28 ft
        }
        $rofe_width   = sprintf "%.2f", $user_ofe_width;
        $slope_length = $ofe1_length + $ofe2_length;
        $asyra        = $syra * 10;                    # kg.m^2 * 10 = t/ha

#       $asypa= sprintf "%.2f", $sypa * $ofe_width / (100000 * $ofe_area);  # kg/m width * m width * (1 t / 1000 kg) / area-in-ha
        $asypa = sprintf "%.2f", $sypa * 10 / $slope_length;

        #       if ($units eq 'm') {$areaunits='ha'}
        #       if ($units eq 'ft') {$areaunits='ac'}
        $areaunits = 'ac';
        $areaunits = 'ha' if $units eq 'm';

        print "   </pre>
  <center>

    <table border=0 width=10% align=right>
     <tr><td align=right bgcolor='#faf8cc'>user&nbsp;inputs</td></tr>
     <tr><td align=right bgcolor='#e0ffff'>model&nbsp;results</td></tr>
    </table>

   <table border=1><tr><td>
    <table border=0 cellpadding=5 bgcolor='#faf8cc'>
     <tr><th colspan=6 bgcolor='gold'>User inputs</th></tr>
     <tr>
      <th bgcolor='#85d2d2'>Run description</th>
      <td colspan=4><font face='Arial, Geneva, Helvetica' size=-1>$description</font></td>
     </tr>
     <tr>
      <th bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica'>Climate/Location</font></th>
      <td colspan=5><font face='Arial, Geneva, Helvetica'><b>$climate_name</b>
       <br>
       <font size=1>
";
        print &GetParSummary($climatePar);
        print "
       </font>
      </td>
     </tr>
     <tr>
      <th bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica'>&nbsp;</font></th>
      <th bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica'>Treatment/<br>Vegetation</font></th>
      <th bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica'>Gradient<br>(%)</font></th>
      <th bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica'>Length<br>($units</font>)</th>
      <th bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica'>Cover<br>(%)</font></th>
      <th bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica'>Rock<br>(%)</th>
     </tr>
     <tr>
      <th rowspan=2 bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica'>Upper element</font></th>
      <td rowspan=2 bgcolor='#FAF8CC' style='border-bottom:solid 2px black;'><font face='Arial, Geneva, Helvetica'>$treatments{$treat1}</font></td>
      <td align=right bgcolor='#FAF8CC'><font face='Arial, Geneva, Helvetica'>$ofe1_top_slope</font></td>
      <td align=right rowspan=2 bgcolor='#FAF8CC' style='border-bottom:solid 2px black;' id='len_top'><font face='Arial, Geneva, Helvetica'>$user_ofe1_length</font></td>
      <td align=right rowspan=2 bgcolor='#FAF8CC' style='border-bottom:solid 2px black;'><font face='Arial, Geneva, Helvetica'>$ofe1_pcover</font></td>
      <td align=right rowspan=2 bgcolor='#FAF8CC' style='border-bottom:solid 2px black;'><font face='Arial, Geneva, Helvetica'>$ofe1_rock</font></td>
     </tr>
     <tr>
      <td align=right bgcolor='#FAF8CC' style='border-bottom:solid 2px black;'><font face='Arial, Geneva, Helvetica'>$ofe1_mid_slope</font></td>
     </tr>
     <tr>
      <th rowspan=2 bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica'>Lower element</th>
      <td rowspan=2 bgcolor='#FAF8CC' style='border-bottom:solid 2px black;'><font face='Arial, Geneva, Helvetica'>$treatments{$treat2}</td>
      <td align=right bgcolor='#FAF8CC'><font face='Arial, Geneva, Helvetica'>$ofe2_mid_slope</td>
      <td align=right rowspan=2 bgcolor='#FAF8CC' style='border-bottom:solid 2px black;' id='len_bot'><font face='Arial, Geneva, Helvetica'>$user_ofe2_length</td>
      <td align=right rowspan=2 bgcolor='#FAF8CC' style='border-bottom:solid 2px black;'><font face='Arial, Geneva, Helvetica'>$ofe2_pcover</td>
      <td align=right rowspan=2 bgcolor='#FAF8CC' style='border-bottom:solid 2px black;'><font face='Arial, Geneva, Helvetica'>$ofe2_rock  </td>
     </tr>
     <tr>
      <td align=right bgcolor='#FAF8CC' style='border-bottom:solid 2px black;'><font face='Arial, Geneva, Helvetica'>$ofe2_bot_slope</font></td>
     </tr>
     <tr>
      <th bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica'>Soil texture</font></th>
      <td colspan=2 bgcolor='#FAF8CC'><font face='Arial, Geneva, Helvetica'>$soil_type{$soil}</font></td>
      <td bgcolor='#85d2d2'>Period</td>
      <td id='years' colspan=2><font face='Arial, Geneva, Helvetica'>";
        print " $simyears $yearyears" if ( !$fc );
        print " $startYear to ", $startYear + $simyears - 1 if ($fc);
        print "</font></td>
     </tr>
     <tr>
      <th bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica'>Phosphorus concentration</font></th>
      <td colspan=5 bgcolor='#FAF8CC'>
       <font face='Arial, Geneva, Helvetica'>
        <font color='", $sr_conc_color[$sr_conc_ok],
          "'>$sr_conc_in</font> mg/l surface;
        <font color='", $sr_conc_color[$lf_conc_ok],
          "'>$lf_conc_in</font> mg/l lateral flow;
        <font color='", $sr_conc_color[$sed_conc_ok],
          "'>$sed_conc_in</font> mg/kg sediment</td> 
       </font
      </td>
     </tr>
    </table>
   </td></tr></table>
    <p>
";

        if ( $units eq 'm' ) {
            $user_precip              = sprintf "%.1f", $precip;
            $user_rro                 = sprintf "%.1f", $rro;
            $user_sro                 = sprintf "%.1f", $sro;
            $user_asyra               = sprintf "%.3f", $asyra; # 2004.10.14 DEH
            $user_asypa               = sprintf "%.3f", $asypa; # 2004.10.14 DEH
            $rate                     = 't ha<sup>-1</sup>';
            $pcp_unit                 = 'mm';
            $phosphate_delivery_units = 'kg/ha';
            $p_conv                   = 1;
        }
        else {                                                  # $units eq 'ft'
            $user_precip = sprintf "%.2f", $precip * 0.0394;    # mm to in
            $user_rro    = sprintf "%.2f", $rro * 0.0394;       # mm to in
            $user_sro    = sprintf "%.2f", $sro * 0.0394;       # mm to in
            $user_asyra  = sprintf "%.3f",
              $asyra * 0.445;    # t/ha to t/ac # 2004.10.14 DEH
            $user_asypa = sprintf "%.3f",
              $asypa * 0.445;    # t/ha to t/ac # 2004.10.14 DEH
            $rate                     = 't ac<sup>-1</sup>';
            $pcp_unit                 = 'in.';
            $phosphate_delivery_units = 'lb/ac';
            $p_conv =
              0.8922;    # unit conversion: kg/ha * 0.8922 = lb/ac [wolfram]
        }

        #  Phosphorus values  #

        # $sr_conc = 1.0;
        # $lf_conc = 1.5;
        # $sed_conc = 100;
        $sr_delivery = ( $user_rro + $user_sro ) *
          $sr_conc / 100;    # user units -- kg/ha (mm * mg/l) or lb/ac
        $lf_delivery = $lateral_flow_u *
          $lf_conc / 100;    # user units -- kg/ha (mm * mg/l) or lb/ac
        $sed_delivery =
          $user_asypa *
          $sed_conc *
          $SSA_ratio / 1000;    # user units -- kg/ha or lb/ac
        $total_phosphate =
          $sr_delivery +
          $lf_delivery +
          $sed_delivery;        # user units -- kg/ha (t/ha * mg/kg) or lb/ac

##################################
        #                                #
        #        Fines analysis          #
        #   2012.11.13 vary %silt %clay  #
##

        (
            $class[1],        $diam,        $spgr,   $sand_pct,
            $silt_pct[1],     $clay_pct[1], $om_pct, $sedfrac,
            $frac_exiting[1], $rest
        ) = split ' ', $class1, 9;
        (
            $class[2],        $diam,        $spgr,   $sand_pct,
            $silt_pct[2],     $clay_pct[2], $om_pct, $sedfrac,
            $frac_exiting[2], $rest
        ) = split ' ', $class2, 9;
        (
            $class[3],        $diam,        $spgr,   $sand_pct,
            $silt_pct[3],     $clay_pct[3], $om_pct, $sedfrac,
            $frac_exiting[3], $rest
        ) = split ' ', $class3, 9;
        (
            $class[4],        $diam,        $spgr,   $sand_pct,
            $silt_pct[4],     $clay_pct[4], $om_pct, $sedfrac,
            $frac_exiting[4], $rest
        ) = split ' ', $class4, 9;
        (
            $class[5],        $diam,        $spgr,   $sand_pct,
            $silt_pct[5],     $clay_pct[5], $om_pct, $sedfrac,
            $frac_exiting[5], $rest
        ) = split ' ', $class5, 9;

        $frac_exiting[1] += 0;
        $frac_exiting[2] += 0;
        $frac_exiting[3] += 0;
        $frac_exiting[4] += 0;
        $frac_exiting[5] += 0;

        $pct_clay[1] = $clay_pct[1] * $frac_exiting[1];    # 100   * 0.006
        $pct_clay[2] = $clay_pct[2] * $frac_exiting[2];    #   0   * 0.050
        $pct_clay[3] =
          $clay_pct[3] * $frac_exiting[3];    #  20   * 0.041		2012.11.13
        $pct_clay[4] =
          $clay_pct[4] * $frac_exiting[4];    #   7.5 * 0.115		2012.11.13
        $pct_clay[5] = $clay_pct[5] * $frac_exiting[5];    #   0   * 0.788

        $pct_silt[1] = $silt_pct[1] * $frac_exiting[1];    #   0   * 0.006
        $pct_silt[2] = $silt_pct[2] * $frac_exiting[2];    # 100   * 0.050
        $pct_silt[3] =
          $silt_pct[3] * $frac_exiting[3];    #  80   * 0.041		2012.11.13
        $pct_silt[4] =
          $silt_pct[4] * $frac_exiting[4];    #   7.1 * 0.115		2012.11.13
        $pct_silt[5] = $silt_pct[5] * $frac_exiting[5];    #   0   * 0.788

        $sed_del = $user_asypa
          ;    # average annual sediment delivery in user units (t/ac or t/ha)

        $total_clay_in_del_sed = $pct_clay[1] + $pct_clay[3] + $pct_clay[4]; # %
        $total_clay_in_del_sed_ratio   = $total_clay_in_del_sed / 100;
        $total_clay_in_del_sed_ratio_f = sprintf "%0.2f",
          $total_clay_in_del_sed_ratio;
        $total_silt_in_del_sed = $pct_silt[2] + $pct_silt[3] + $pct_silt[4]; # %
        $total_silt_in_del_sed_ratio   = $total_silt_in_del_sed / 100;
        $total_silt_in_del_sed_ratio_f = sprintf "%0.2f",
          $total_silt_in_del_sed_ratio;

        $total_clay_del = $total_clay_in_del_sed_ratio *
          $sed_del;    # Total clay delivered: $total_clay_del t/ac or t/ha
        $total_silt_del = $total_silt_in_del_sed_ratio *
          $sed_del;    # Total silt delivered: $total_silt_del t/ac or t/ha

        # Clay fraction in delivered sediment: $total_clay_in_del_sed/100
        # Total silt fraction in delivered sediment: $total_silt_in_del_sed/100

       #  USDA silt size definition is 4.0 to 62.5 microns (= user input limits)
        $fines_lower_limit = 4;
        $fines_upper_limit = 62.5;
        $denom             = $fines_upper_limit - $fines_lower_limit;

        $fines_upper = $fines_upper_limit
          if ( $fines_upper > $fines_upper_limit );
        $fines_upper = $fines_lower_limit
          if ( $fines_upper < $fines_lower_limit );

        #  $upper = 10;			# ******* user input
        $numer      = $fines_upper - $fines_lower_limit;
        $silt_ratio = $numer / $denom;

#  $silt_frac_less = $silt_ratio * $total_silt_del;			# Silt fraction < $fines_upper microns, t/ac or t/ha
        $silt_frac_less = $silt_ratio *
          $total_silt_in_del_sed_ratio
          ;    # Silt fraction < $fines_upper microns, t/ac or t/ha
        $silt_frac_less_del = $silt_frac_less * $sed_del;

        if ( $units eq 'm' ) {
            $fines_units = 'kg/ha';

    #  $silt_frac_less *= 1000;				# Silt fraction < $fines_upper microns, kg/ha
            $total_clay_del_x     = $total_clay_del * 1000;      # t/ha -> kg/ha
            $total_silt_del_x     = $total_silt_del * 1000;      # t/ha -> kg/ha
            $silt_frac_less_del_x = $silt_frac_less_del * 1000;  # t/ha -> kg/ha
            $conversion           = ' * 1000';
        }
        else {                                                   # units == 'ft'
            $fines_units = 'lb/ac';

    #  $silt_frac_less *= 2000;				# Silt fraction < $fines_upper microns, lb/ac
            $total_clay_del_x     = $total_clay_del * 2000;      # t/ac -> lb/ha
            $total_silt_del_x     = $total_silt_del * 2000;      # t/ac -> lb/ha
            $silt_frac_less_del_x = $silt_frac_less_del * 2000;  # t/ha -> lb/ac
            $conversion           = ' * 2000';
        }
        $total_frac_del =
          $silt_frac_less_del_x + $total_clay_del_x;             # 2012-07-18
        $silt_frac_less_f = sprintf "%0.2f", $silt_frac_less;
        $total_clay_del_f = sprintf "%0.2f", $total_clay_del_x;
        $total_silt_del_f = sprintf "%0.2f", $total_silt_del_x;

#  $total_frac_del_f = sprintf "%0.2f",$total_silt_del_x + $total_clay_del_x;	# 2012-07-18
        $total_frac_del_f     = sprintf "%0.2f", $total_frac_del;   # 2012-07-18
        $silt_frac_less_del_f = sprintf "%0.2f", $silt_frac_less_del_x;

        if ($debug) {
            print "<h4>Fines</h4>\n";
            print "<pre>\n";

            if ( $units eq 'ft' ) {
                print "Sediment delivered: $sed_del t/ac\n";
                print "Clay fraction in delivered sediment: ",
                  $total_clay_in_del_sed / 100, "\n";
                print "Total clay delivered: $total_clay_del t/ac -- ",
                  2000 * $total_clay_del, " lb/ac\n";
                print "Total silt fraction in delivered sediment: ",
                  $total_silt_in_del_sed / 100, "\n";
                print "Total silt delivered: $total_silt_del t/ac -- ",
                  2000 * $total_silt_del, " lb/ac\n";
            }
            else {
#  print "Average annual sediment delivered: $sed_del t/ha\n";
#  print "Clay fraction in delivered sediment: ", $total_clay_in_del_sed/100 ," [$frac_exiting[1] + 20 * $frac_exiting[3] + 7.5 * $frac_exiting[4]]\n";
#  print "Total clay delivered: $total_clay_del t/ha [",$total_clay_in_del_sed / 100," * $sed_del]\n";
#  print "Total silt fraction in delivered sediment: ", $total_silt_in_del_sed/100 ," [$frac_exiting[2] + 80 * $frac_exiting[3] + 7.1 * $frac_exiting[4]]\n";
#  print "Total silt delivered: $total_silt_del t/ha [",$total_silt_in_del_sed / 100," * $sed_del]\n";
            }

       #  USDA silt size definition is 4.0 to 62.5 microns (= user input limits)
            $fines_lower_limit = 4;
            $fines_upper_limit = 62.5;
            $denom             = $fines_upper_limit - $fines_lower_limit;
            $fines_upper       = $fines_upper_limit
              if ( $fines_upper > $fines_upper_limit );
            $fines_upper = $fines_lower_limit
              if ( $fines_upper < $fines_lower_limit );

            #  $upper = 10;			# ******* user input
            $numer = $fines_upper - $fines_lower_limit;
            $ratio = $numer / $denom;

            if ( $units eq 'ft' ) {
                print "Silt fraction less than $fines_upper microns: ",
                  $ratio * $total_silt_del, "\n";
            }
            else {
                print "Silt fraction less than $fines_upper microns: ",
                  $ratio * $total_silt_del,
" [($fines_upper - $fines_lower_limit)/($fines_upper_limit - $fines_lower_limit) * $total_silt_del]\n";
            }

            print "</pre>\n";

        }    # -- if ($debug) {

        #
        #   END FINES ANALYSIS
        #
############################

        #   <p><hr><p>
        print "
    <form name='phosphate'>
     <input type='hidden' name='rro' id='user_rro' value=$user_rro>
     <input type='hidden' name='sro' id='user_sro' value=$user_sro>
     <input type='hidden' name='sed' id='user_sed' value=$user_asyp>
     <input type='hidden' name='lf'  id='lf'  value=$lateral_flow>
     <input type='hidden' name='SSA' id='SSA' value=$SSA_ratio>
   <table border=1>
   <tr><th bgcolor=gold>Tahoe Basin Sediment Model results</th></tr>
   <tr><td>
    <table border=0 cellpadding=4 bgcolor='#e0ffff'>
     <tr>
      <td rowspan=2 bgcolor='#85d2d2'></td>
      <th rowspan=2 colspan=2 bgcolor='#85d2d2'><font size=-1>Total for<br>$years2sim $yearyears</font></th>
      <th rowspan=2 colspan=2 bgcolor='#85d2d2'><font size=-1>Average<br>annual</font></th>
      <th colspan=4 bgcolor='gold'
          style='border-left:solid 3px purple; border-top:solid 3px purple; border-right:solid 3px purple'>
       Phosphorus Analysis
     </th>
     </tr>
     <tr>
      <th colspan=2 bgcolor='#85d2d2' style='border-left:solid 3px purple'><font size=-1>Concentration</font></th>
      <th colspan=2 bgcolor='#85d2d2' style='border-right:solid 3px purple'><font size=-1>Delivery</font></th>
     </tr>
     <tr>
      <th align=right bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica' size=-1>Precipitation</font></th>
      <td align=right><font face='Arial, Geneva, Helvetica'>$storms</font></td>
      <td>
       <font face='Arial, Geneva, Helvetica'>
        <a onMouseOver=\"window.status='There were $storms storms in $simyears year(s)';return true;\"
           onMouseOut=\"window.status='';return true;\">storms</a>
       </font>
      </td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$user_precip</font></td>
      <td><font face='Arial, Geneva, Helvetica'>$pcp_unit</font></td>
      <th colspan=4 style='border-left:solid 3px purple; border-right:solid 3px purple'>
       <font face='Arial, Geneva, Helvetica'>&nbsp;</font>
      </th>
     </tr>
     <tr>
      <th align=right bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica' size=-1>Surface runoff from rainfall</font></th>
      <td align=right style='border-top:solid 2px black'><font face='Arial, Geneva, Helvetica'>$rainevents</font></td>
      <td style='border-top:solid 2px black'><font face='Arial, Geneva, Helvetica'>events</font></td>
      <td align=right id='avg_rro' style='border-top:solid 2px black'><font face='Arial, Geneva, Helvetica'>$user_rro</font></td>   <!-- rro  -->
      <td style='border-top:solid 2px black'>
       <font face='Arial, Geneva, Helvetica'>$pcp_unit</font>
      </td>
      <td rowspan=2 bgcolor=faf8cc align=right id='srConc'
          style='border-left:solid 3px purple; border-top:solid 2px black; border-bottom:solid 2px black'>
       <font face='Arial, Geneva, Helvetica'>$sr_conc</font>
      </td>
      <td rowspan=2 style='border-top:solid 2px black; border-bottom:solid 2px black'>
       <font face='Arial, Geneva, Helvetica'>mg/l</font>
      </td>
      <td rowspan=2 align=right id='srDel' onmouseover='explain(1);markSrCalc(1)' onmouseout='explain(0);markSrCalc(0)'
          style='border-top:solid 2px black; border-bottom:solid 2px black'>
       <div title='", $sr_delivery * $p_conv,
          " = ($user_rro + $user_sro) * $sr_conc / 100'>
        <font face='Arial, Geneva, Helvetica'><span id='sr_delivery'>",
          sprintf( "%.3f", $sr_delivery * $p_conv ), "</span></font>
       </div>
      </td>
      <td rowspan=2 style='border-top:solid 2px black; border-bottom:solid 2px black; border-right:solid 3px purple'>
       <font face='Arial, Geneva, Helvetica'>", $phosphate_delivery_units,
          "</font>
      </td>
     </tr>
     <tr>
      <th align=right bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica' size=-1>Runoff from snowmelt or winter rainstorm</font></th>
      <td align=right style='border-bottom:solid 2px black'><font face='Arial, Geneva, Helvetica'>$snowevents</font></td>
      <td style='border-bottom:solid 2px black'><font face='Arial, Geneva, Helvetica'>events</font></td>
      <td align=right id='avg_sro'
          style='border-bottom:solid 2px black'><font face='Arial, Geneva, Helvetica'>$user_sro</font></td>   <!-- sro  -->
      <td style='border-bottom:solid 2px black'><font face='Arial, Geneva, Helvetica'>$pcp_unit</font></td>
     </tr>
     <tr>
      <th align=right valign=bottom bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica' size=-1>Lateral flow</font></th>
      <td align=right id='sumLat' style='border-bottom:solid 2px black'><font face='Arial, Geneva, Helvetica'>",
          sprintf( "%.2f", $sumLatqcc * $lf_conv ), "</font></td>
      <td style='border-bottom:solid 2px black'><font face='Arial, Geneva, Helvetica'>$pcp_unit</font></td>
      <td align=right id='lfAmt' onmouseover='explain(5);markLatCalc(1)' onmouseout='explain(-1);markLatCalc(0)' style='border-bottom:solid 2px black'>
       <font face='Arial, Geneva, Helvetica'>",
          sprintf( '%.2f', $lateral_flow_u ), "</font>
      </td>
      <td style='border-bottom:solid 2px black'><font face='Arial, Geneva, Helvetica'>$pcp_unit</font></td>
      <td align=right bgcolor='#faf8cc' id='lfConc' style='border-left:solid 3px purple; border-bottom:solid 2px black'>
       <font face='Arial, Geneva, Helvetica'>$lf_conc</font>
      </td>
      <td style='border-bottom:solid 2px black'><font face='Arial, Geneva, Helvetica'>mg/l</font></td>
      <td align=right id='lfDel' onmouseover='explain(2);markLfCalc(1)' onmouseout='explain(-1);markLfCalc(0)'
          style='border-bottom:solid 2px black'>
       <div title='", $lf_delivery * $p_conv,
          " = $lateral_flow_u * $lf_conc / 100'>
        <font face='Arial, Geneva, Helvetica'>
         <span id='lf_delivery'>", sprintf( "%.3f", $lf_delivery * $p_conv ),
          "</span>
        </font>
       </div>
      </td>
      <td style='border-bottom:solid 2px black; border-right:solid 3px purple'>
       <font face='Arial, Geneva, Helvetica'>", $phosphate_delivery_units,
          "</font>
      </td>
     </tr>
     <tr>
      <th align=right valign=bottom bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica' size=-1>Upland erosion rate ($syra kg m<sup>-2</sup>)</font></th>
      <td></td><td></td>
      <td align=right valign=bottom><font face='Arial, Geneva, Helvetica'>$user_asyra</font></td>
      <td><font face='Arial, Geneva, Helvetica'>$rate</font></td>
      <td style='border-left:solid 3px purple'>&nbsp;</td>
      <td colspan=4 style='border-right:solid 3px purple'>&nbsp;</td>
     </tr>
     <tr>
      <th align=right valign=bottom bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica' size=-1>Sediment leaving profile ($sypa kg m<sup>-1</sup> width)</font></th>
      <td style='border-top:solid 2px black; border-bottom:solid 2px black'>&nbsp;</td>
      <td style='border-top:solid 2px black; border-bottom:solid 2px black'>&nbsp;</td>
      <td align=right id='sedAmt' valign=bottom id='sed'
          style='border-top:solid 2px black; border-bottom:solid 2px black'>
       <font face='Arial, Geneva, Helvetica'>$user_asypa</font>
      </td>   <!-- sed  -->
      <td style='border-top:solid 2px black; border-bottom:solid 2px black'><font face='Arial, Geneva, Helvetica'>$rate</font></td>
      <td align=right bgcolor='#faf8cc' id='sedConc'
          style='border-left:solid 3px purple; border-top:solid 2px black; border-bottom:solid 2px black'>
       <font face='Arial, Geneva, Helvetica'>$sed_conc</font>
      </td>
      <td style='border-top:solid 2px black; border-bottom:solid 2px black'><font face='Arial, Geneva, Helvetica'>mg/kg</font></td>
      <td align=right id='sedDel' onmouseover='explain(3);markSedCalc(1)' onmouseout='explain(-1);markSedCalc(0)'
          style='border-top:solid 2px black; border-bottom:double black'>
       <div title='", $sed_delivery * $p_conv,
          " = $sed_del * $sed_conc * $SSA_ratio / 1000'>    <!-- 2012-07-19 -->
        <font face='Arial, Geneva, Helvetica'>
         <span id='sed_delivery'>", sprintf( "%.3f", $sed_delivery * $p_conv ),
          "</span>
        </font>
       </div>
      </td>
      <td style='border-top:solid 2px black; border-bottom:solid 2px black; border-right:solid 3px purple'>
       <font face='Arial, Geneva, Helvetica'>", $phosphate_delivery_units,
          "</font></td>
     </tr>
     <!--   PHOSPHORUS TOTAL   -->
     <tr>
      <th colspan = 5 align=right  style='border-bottom:solid 3px black;'><font face='Arial, Geneva, Helvetica' size=-1></font></th>
      <th valign=bottom colspan=2 style='border-left:solid 3px purple; border-bottom:solid 3px purple'>
       <font face='Arial, Geneva, Helvetica'>Total</font></th>
      <td align=right onmouseover='explain(4);markDeliveries(1)' onmouseout='explain(-1);markDeliveries(0)'
          style='border-bottom:solid 3px purple'>
       <div title='", $total_phosphate * $p_conv, " = ",
          $sr_delivery * $p_conv, " + ", $lf_delivery * $p_conv, " + ",
          $sed_delivery * $p_conv, "'>
        <font face='Arial, Geneva, Helvetica'>
         <span id='total'><b>", sprintf( "%.3f", $total_phosphate * $p_conv ),
          "</b></span>
        </font>
       </div>
      </td>
      <td valign=bottom style='border-bottom:solid 3px purple; border-right:solid 3px purple'>
       <font face='Arial, Geneva, Helvetica'><b>", $phosphate_delivery_units,
          "</b></font>
      </td>
     </tr>
     <!--   RETURN PERIOD ANALYSIS  and  FINES START  -->
     <tr>
      <th rowspan=7 align=right valign=top style='border-right:solid 3px black;'>
        <font face='Arial, Geneva, Helvetica' size=-1>

     	<!-- RETURN PERIOD ANALYSIS table  -->

     <table border=0 cellpadding=2 bgcolor='#e0ffff'>
     <tr>
      <th bgcolor=gold colspan=5>
       <font face='Arial, Geneva, Helvetica'>
         Return period analysis<br>
         based on $simyears&nbsp;$yearyears of climate
       </font>
      </th>
     </tr>
     <tr>
      <th bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica'>Return<br>Period</font></th>
      <th bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica'>Precipitation<br>($pcp_unit)</font></th>
      <th bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica'>Runoff<br>($pcp_unit)</font></th>
      <th bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica'>Erosion<br>($rate)</font></th>
      <th bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica'>Sediment<br>($rate)</font></th>
     </tr>
";
        $rcf = 1;
        $dcf = 1;    # rate conversion factor; depth conversion factor

        if ( $units eq 'ft' ) {
            $rcf = 0.445;
            $dcf = 0.0394;
        }            # t/ha to t/ac; mm to in.
        $ii           = 0;
        @rp_year_text = ( '1st', '2nd', '5th', '10th', '20th' );
        for $rp_year ( 1, 2, 5, 10, 20 ) {
            $rp = $simyears / $rp_year;
            if ( $rp >= 1 ) {
                $user_pcpa = sprintf "%.2f", $pcpa[ $rp_year - 1 ] * $dcf;
                $user_ra   = sprintf "%.2f", $ra[ $rp_year - 1 ] * $dcf;
                $asyr      = sprintf "%.2f", $detach[ $rp_year - 1 ] * 10 *
                  $rcf;    # kg.m^2 * 10 = t/ha * 0.445$

#     $asyp = sprintf "%.2f", $sed_del[$rp_year-1] * $ofe_width / (100000 * $ofe_area) * $rcf;  # kg/m width * m width * (1 $
#     $asyp = sprintf "%.4f", $sed_del[$rp_year-1] * 10 / $slope_length * $rcf;                 # 2006.01.20 DEH
                $asyp = sprintf "%.3f",
                  $sed_del[ $rp_year - 1 ] * 10 /
                  $slope_length *
                  $rcf;    # 2012.10.26 DEH
                print "
     <tr>
      <th bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica'>
        <a onMouseOver=\"window.status='For year with $rp_year_text[$ii] largest values';return true;\"
           onMouseOut=\"window.status='';return true;\">$rp year</a></font></th>
      <td align=right><font face='Arial, Geneva, Helvetica'>$user_pcpa</font></td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$user_ra</font></td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$asyr</font></td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$asyp</font></td>
     </tr>
";
                $ii += 1;
            }
        }
        $user_avg_pcp = sprintf "%.2f", $avg_pcp * $dcf;
        $user_avg_ro  = sprintf "%.2f", $avg_ro * $dcf;
        $user_asyra   = sprintf "%.2f", $asyra * $rcf;

#  $user_asypa   = sprintf "%.4f", $asypa*$rcf;                 # 2006.01.20 DEH
        $user_asypa       = sprintf "%.3f", $asypa * $rcf;    # 2012.10.26 DEH
        $base_size        = 100;
        $prob_no_pcp      = sprintf "%.2f", $nzpcp / $simyears;
        $prob_no_runoff   = sprintf "%.2f", $nzra / $simyears;
        $prob_no_erosion  = sprintf "%.2f", $nzdetach / $simyears;
        $prob_no_sediment = sprintf "%.2f", $nzsed_del / $simyears;

        print "
     <tr>
      <th bgcolor='yellow'><font face='Arial, Geneva, Helvetica'>Average</font></th>
      <td align=right><font face='Arial, Geneva, Helvetica'>$user_avg_pcp</font></td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$user_avg_ro</font></td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$user_asyra</font></td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$user_asypa</font></td>
     </tr>
    </table>

        </font>
      </th>
      <th colspan=4 bgcolor='gold'><font face='Arial, Geneva, Helvetica'><b>Fines analysis</b></font></th>
      <th colspan=2 bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica' size=-1><b>Ratio</b></font></th>
      <th colspan=2 bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica' size=-1><b>Delivery</b></font></th>
     </tr>
     <!-- clay -->
     <tr>
      <th colspan=4 align=right valign=bottom bgcolor='#85d2d2'>Clay</th>
      <td align=right valign=bottom id='ClayRatio'>
<!-- 2012.11.13 -->
       <DIV TITLE='$total_clay_in_del_sed_ratio = $frac_exiting[1] + (",
          $clay_pct[3] / 100, " * $frac_exiting[3]) + (", $clay_pct[4] / 100,
          " * $frac_exiting[4])'>
        <font face='Arial, Geneva, Helvetica'>
         $total_clay_in_del_sed_ratio_f
        </font>
       </div>
      </td>
      <td><font face='Arial, Geneva, Helvetica'></font></td>
      <td id='claydel' align=right valign=bottom onmouseover='markAvgSed(1);markClayRatio(1)' onmouseout='markAvgSed(0);markClayRatio(0)'>
       <DIV TITLE='$total_clay_del_x = $total_clay_in_del_sed_ratio * $sed_del $conversion'>
        <font face='Arial, Geneva, Helvetica'>
         $total_clay_del_f
        </font>
       </div>
      </td>
      <td align=right valign=bottom><font face='Arial, Geneva, Helvetica'><span id='clay'>$fines_units</span></font></td>
     </tr>
     <!-- silt -->
<!--
     <tr>
      <th colspan=4 align=right valign=bottom bgcolor='#85d2d2'>Silt</th>
      <td align=right valign=bottom id='SiltRatio'>
       <DIV TITLE='$total_silt_in_del_sed_ratio = $frac_exiting[2] + 80 * $frac_exiting[3] + 7.1 * $frac_exiting[4]'>
        <font face='Arial, Geneva, Helvetica'>
         $total_silt_in_del_sed_ratio_f
        </font>
       </div>
      </td>
      <td><font face='Arial, Geneva, Helvetica'></font></td>
      <td align=right valign=bottom onmouseover='markAvgSed(1);markSiltRatio(1)' onmouseout='markAvgSed(0);markSiltRatio(0)'>
       <DIV TITLE='$total_silt_del_x = $total_silt_in_del_sed_ratio * $sed_del $conversion'>
        <font face='Arial, Geneva, Helvetica'>
         $total_silt_del_f
        </font>
       </div>
      </td>
      <td align=right valign=bottom>$fines_units</font></td>
     </tr>
-->
     <!-- silt less -->
     <tr>
      <th colspan=4 align=right valign=bottom bgcolor='#85d2d2'>Silt &lt; $fines_upper microns</th>
      <td align=right valign=bottom id='SiltLessRatio'>
<!--  2012.11.13  -->
       <DIV TITLE='$silt_frac_less = ($fines_upper - $fines_lower_limit)/($fines_upper_limit - $fines_lower_limit)
 * ($frac_exiting[2] + (", $silt_pct[3] / 100, " * $frac_exiting[3]) + (",
          $silt_pct[4] / 100, " * $frac_exiting[4]))'>
        <font face='Arial, Geneva, Helvetica'>
          $silt_frac_less_f
        </font>
       </div>
      </td>
      <td><font face='Arial, Geneva, Helvetica'></font></td>
      <td id='siltlessdel' align=right valign=bottom onmouseover='markAvgSed(1);markSiltLessRatio(1)' onmouseout='markAvgSed(0);markSiltLessRatio(0)'
          style='border-bottom:double black'>
       <DIV TITLE='$silt_frac_less_del_x = $silt_frac_less * $sed_del $conversion'>  <!-- 2012-07-18 -->
        <font face='Arial, Geneva, Helvetica'>
         $silt_frac_less_del_f
        </font>
       </div>
      </td>
      <td align=right valign=bottom><font face='Arial, Geneva, Helvetica'>$fines_units</font></td>
     </tr>
     <! --- total less  --->
     <tr>
      <th colspan=4 align=right valign=bottom bgcolor='#85d2d2'>Total &lt; $fines_upper microns</th>
      <td align=right valign=bottom></td>
      <td><font face='Arial, Geneva, Helvetica'></font></td>
      <td align=right valign=bottom onmouseover='markClayDel(1);markSiltLessDel(1)' onmouseout='markClayDel(0);markSiltLessDel(0)'>
       <b>
        <DIV TITLE='$total_frac_del = $silt_frac_less_del_x +  $total_clay_del_x'>
         <font face='Arial, Geneva, Helvetica'>$total_frac_del_f</font>
        </div>
       </b>
      </td>
      <td align=right valign=bottom><b>$fines_units</b></td>
     </tr>
     <!-- SSA enrichment ratio -->
     <!--  FINES END -->
     <tr>
      <th colspan=4 align=right valign=bottom bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica' size=-1>SSA enrichment ratio leaving profile</font></th>
      <td align=right valign=bottom id='ssa_'><font face='Arial, Geneva, Helvetica'>$SSA_ratio</font></td>   <!-- SSA  -->
      <th valign=bottom><font face='Arial, Geneva, Helvetica' size=-1></font></th>
      <td><font face='Arial, Geneva, Helvetica'><span id='total'></span></font></td>
      <td valign=bottom><font face='Arial, Geneva, Helvetica'></font></td>
     </tr>
<tr><td></td></tr>
    </table>
   </td>
  </tr>
  <tr>
   <td>
    <font face='Arial, Geneva, Helvetica' size=-1>
     <span id='helptext'>
<pre>
     B.  SEDIMENT CHARACTERISTICS AND ENRICHMENT

     Sediment particle information leaving profile
-------------------------------------------------------------------------------
                                 Particle Composition         Detached Fraction
Class  Diameter  Specific  ---------------------------------  Sediment  In Flow
         (mm)    Gravity   % Sand   % Silt   % Clay   % O.M.  Fraction  Exiting
-------------------------------------------------------------------------------
$class1
$class2
$class3
$class4
$class5
</pre>
     </span>
    </font>
   </td>
  </tr>
 </table>
    </form>
   </center>
";

#          Phosphorus Table
#print '
#   <center>
#    <h3>Phosphorus analysis</h3>
#     <table border=0 cellpadding=5 bgcolor="lightyellow">
#      <tr>
#       <th bgcolor="#85d2d2"><font face="Arial, Geneva, Helvetica">Source</font></th>
#       <th colspan=2 bgcolor="#85d2d2"><font face="Arial, Geneva, Helvetica">Amount</font></th>
#       <th colspan=2 bgcolor="#85d2d2"><font face="Arial, Geneva, Helvetica">Concentration</font></th>
#       <th colspan=2 bgcolor="#85d2d2"><font face="Arial, Geneva, Helvetica">Delivery</font></th>
#      </tr>
#      <tr>
#       <td bgcolor="#85d2d2"><font face="Arial, Geneva, Helvetica"><b>Surface runoff</b></font></td>
#       <td align="right" id="srAmt" onmouseover="markRunoffs(1)" onmouseout="markRunoffs(0)"><font face="Arial, Geneva, Helvetica">',$user_rro+$user_sro,'</font></td>
#       <td><font face="Arial, Geneva, Helvetica">',$pcp_unit,'</font></td>
#      </tr>
#      <tr>
#       <td bgcolor="#85d2d2"><font face="Arial, Geneva, Helvetica"><b>Lateral flow</b></font></td>
#       <td align=right id="lf_Amt" onmouseover="markLatFlow(1)" onmouseout="markLatFlow(0)"><font face="Arial, Geneva, Helvetica">',sprintf("%.1f",$lateral_flow_u),'</font></td>
#       <td><font face="Arial, Geneva, Helvetica">',$pcp_unit,'</font></td>
#      </tr>
#      <tr>
#       <td bgcolor="#85d2d2"><font face="Arial, Geneva, Helvetica"><b>Sediment</b></font></td>
#       <td align=right id="sed_Amt" onmouseover="markSed(1)" onmouseout="markSed(0)"><font face="Arial, Geneva, Helvetica">',$user_asypa,'</font></td>
#       <td><font face="Arial, Geneva, Helvetica">',$rate,'</font></td>
#      </tr>
#      <tr>
#       <td colspan=3 bgcolor="#85d2d2"><font face="Arial, Geneva, Helvetica"><b>Total</b></font></td>
#      </tr>
#      <tr>
#       <td colspan=7><font face="Arial, Geneva, Helvetica" size=-2>
#         surface runoff delivery = (surface runoff amount) * (surface runoff concentration) / 100<br>
#         lateral flow delivery = (lateral flow amount) * (lateral flow concentration) / 100<br>
#         sediment delivery = (sediment amount) * (sediment concentration) * (SSA enrichment ratio) / 1000<br>
#         total = (surface runoff delivery) + (lateral flow delivery) + (sediment delivery)
#        </font>
#       </td>
#      </tr>
#     </table>
#   </center>
#';

#####

#      print "
#   <center>
#    <p>
#    <table border=0 cellpadding=3 bgcolor='#e0ffff'>
#     <tr>
#      <th bgcolor=gold colspan=5>
#       <font face='Arial, Geneva, Helvetica'>
#         Return period analysis<br>
#         based on $simyears&nbsp;$yearyears of climate
#       </font>
#      </th>
#     </tr>
#     <tr>
#      <th bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica'>Return<br>Period</font></th>
#      <th bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica'>Precipitation<br>($pcp_unit)</font></th>
#      <th bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica'>Runoff<br>($pcp_unit)</font></th>
#      <th bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica'>Erosion<br>($rate)</font></th>
#      <th bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica'>Sediment<br>($rate)</font></th>
#     </tr>";
#
#$rcf = 1; $dcf = 1;					# rate conversion factor; depth conversion factor
#if ($units eq 'ft') {$rcf = 0.445; $dcf = 0.0394}	# t/ha to t/ac; mm to in.
#$ii = 0;
#@rp_year_text=('1st','2nd','5th','10th','20th');
#for $rp_year (1,2,5,10,20) {
#   $rp = $simyears/$rp_year;
#   if ($rp >= 1) {
#      $user_pcpa = sprintf "%.2f", $pcpa[$rp_year-1] * $dcf;
#      $user_ra   = sprintf "%.2f", $ra[$rp_year-1] * $dcf;
#      $asyr = sprintf "%.2f", $detach[$rp_year-1] * 10 * $rcf;					# kg.m^2 * 10 = t/ha * 0.445 = t/ac
##     $asyp = sprintf "%.2f", $sed_del[$rp_year-1] * $ofe_width / (100000 * $ofe_area) * $rcf;	# kg/m width * m width * (1 t / 1000 kg) / area-in-ha
#      $asyp = sprintf "%.4f", $sed_del[$rp_year-1] * 10 / $slope_length * $rcf;			# 2006.01.20 DEH
#
#      print "
#     <tr>
#      <th bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica'>
#        <a onMouseOver=\"window.status='For year with $rp_year_text[$ii] largest values';return true;\"
#           onMouseOut=\"window.status='';return true;\">$rp year</a></font></th>
#      <td align=right><font face='Arial, Geneva, Helvetica'>$user_pcpa</font></td>
#      <td align=right><font face='Arial, Geneva, Helvetica'>$user_ra</font></td>
#      <td align=right><font face='Arial, Geneva, Helvetica'>$asyr</font></td>
#      <td align=right><font face='Arial, Geneva, Helvetica'>$asyp</font></td>
#     </tr>
#";
#      $ii += 1;
#   }
#}
#   $user_avg_pcp = sprintf "%.2f", $avg_pcp*$dcf;
#   $user_avg_ro  = sprintf "%.2f", $avg_ro*$dcf;
#   $user_asyra   = sprintf "%.2f", $asyra*$rcf;
#   $user_asypa   = sprintf "%.4f", $asypa*$rcf;			# 2006.01.20 DEH
#         $base_size=100;
#         $prob_no_pcp      = sprintf "%.2f", $nzpcp/$simyears;
#         $prob_no_runoff   = sprintf "%.2f", $nzra/$simyears;
#         $prob_no_erosion  = sprintf "%.2f", $nzdetach/$simyears;
#         $prob_no_sediment = sprintf "%.2f", $nzsed_del/$simyears;
#
#   print "
#     <tr>
#      <th bgcolor='yellow'><font face='Arial, Geneva, Helvetica'>Average</font></th>
#      <td align=right><font face='Arial, Geneva, Helvetica'>$user_avg_pcp</font></td>
#      <td align=right><font face='Arial, Geneva, Helvetica'>$user_avg_ro</font></td>
#      <td align=right><font face='Arial, Geneva, Helvetica'>$user_asyra</font></td>
#      <td align=right><font face='Arial, Geneva, Helvetica'>$user_asypa</font></td>
#     </tr>
#    </table>
#";
        print "
   <center>
   <table border=1><tr><td>
    <table border=0 cellpadding=4 bgcolor='#e0ffff'>
     <tr>
      <th colspan=3 bgcolor=gold>
       <font face='Arial, Geneva, Helvetica'>
        Probabilities of occurrence<br>first year following disturbance<br>
        based on $simyears&nbsp;$yearyears of climate
       </font>
      </th>
     </tr>
     <tr>
      <th align=right bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica'>Probability there is runoff</font></th>
      <td><font face='Arial, Geneva, Helvetica'>";
        printf "%.0f", ( 1 - $prob_no_runoff ) * 100;
        print " %</font></td>
      <td><font face='Arial, Geneva, Helvetica'>
        <a onMouseOver=\"window.status='$nnzra year(s) in $simyears had runoff';return true;\"
           onMouseOut=\"window.status='';return true;\">
        <img src=\"/fswepp/images/rouge.gif\" height=15 width=",
          ( 1 - $prob_no_runoff ) * $base_size, "></a>
        <a onMouseOver=\"window.status='$nzra year(s) in $simyears had no runoff';return true;\"
           onMouseOut=\"window.status='';return true;\">
        <img src=\"/fswepp/images/green.gif\" height=15 width=",
          ($prob_no_runoff) * $base_size, "></a></font></td>
     </tr>
     <tr>
      <th align=right bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica'>Probability there is erosion</font></th>
      <td align=right>";
        printf "%.0f", ( 1 - $prob_no_erosion ) * 100;
        print " %</font></td>
      <td><font face='Arial, Geneva, Helvetica'>
       <a onMouseOver=\"window.status='$nnzdetach year(s) in $simyears had erosion';return true;\"
           onMouseOut=\"window.status='';return true;\">
        <img src=\"/fswepp/images/rouge.gif\" height=15 width=",
          ( 1 - $prob_no_erosion ) * $base_size, "></a>
        <a onMouseOver=\"window.status='$nzdetach year(s) in $simyears had no erosion';return true;\"
           onMouseOut=\"window.status='';return true;\">
        <img src=\"/fswepp/images/green.gif\" height=15 width=",
          ($prob_no_erosion) * $base_size, "></a></font></td>
     </tr>
     <tr>
      <th align=right bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica'>Probability there is sediment delivery</font></th>
      <td align=right><font face='Arial, Geneva, Helvetica'>";
        printf "%.0f", ( 1 - $prob_no_sediment ) * 100;
        print " %</font></td>
      <td><font face='Arial, Geneva, Helvetica'>
          <a onMouseOver=\"window.status='$nnzsed_del year(s) in $simyears had sediment delivery';return true;\"
             onMouseOut=\"window.status='';return true;\">
          <img src=\"/fswepp/images/rouge.gif\" height=15 width=",
          ( 1 - $prob_no_sediment ) * $base_size, "></a>
          <a onMouseOver=\"window.status='$nzsed_del year(s) in $simyears had no sediment delivery';return true;\"
             onMouseOut=\"window.status='';return true;\">
          <img src=\"/fswepp/images/green.gif\" height=15 width=",
          ($prob_no_sediment) * $base_size, "></a></font></td>
     </tr>
       </font>
      </td>
     </tr>
    </table>
   </td></tr></table>
   </center>
      ";
#
#     <tr>
#      <td><font size=-2>
#$, = " ";
#print "yearly runoff amounts (storm runoff amount + melt runoff amount, mm): @ra<br>\n";
#print "$nnzra year(s) with runoff<br>\n";
#print "$nzra year(s) ($simyears - $nnzra) with no runoff<br>\n";
#print "probability no runoff = $prob_no_runoff = $nzra / $simyears<br>\n";
#print "<hr>";
#print "yearly erosion amounts (mm): @detach<br>\n";
#print "$nnzdetach year(s) with erosion<br>\n";
#print "$nzdetach year(s) ($simyears - $nnzdetach) with no erosion<br>\n";
#print "probability no erosion = $prob_no_erosion = $nzdetach / $simyears<br>\n";
#print "<hr>";
#print "yearly sediment delivery amounts (mm): @sed_del<br>\n";
#print "$nnzsed_del year(s) with sediment delivery<br>\n";
#print "$nzsed_del year(s) ($simyears - $nnzsed_del) with no sediment delivery<br>\n";
#print "probability no sediment delivery = $prob_no_sediment = $nzsed_del / $simyears<br>\n";
#$, = "";
#print "
#";

        print '
   <p>
   <center>
    <input type=button value="Return to Input Screen" onClick="JavaScript:window.history.go(-1)">
    <br>
    <hr>
   </center>
';

#####

        # print "<hr width=50%> \n";

        if ( $outputi == 1 ) {
            print '
   <hr>
   <p>
    <h3 align=center>Generated slope file</h3>
    <pre>
';
            open slopef, "<$slopeFile";
            while (<slopef>) {
                print;
            }
            close slopef;
            print '</PRE>';
        }    # $outputi == 1

        #----------------------
    }    # $found == 1
    else {    #  $found == 1
        print
          "    <p><font color=red>Something seems to have gone awry!</font>\n";
        print '    <blockquote><pre><font size=1>
';
        open STERR, "<$sterFile";
        while (<STERR>) {
            print;
        }
        close STERR;
        print '    </font></pre></blockquote><hr>
';

    }    # $found == 1

    #-----------------------------------------

    if ( $outputf == 1 ) {
        print '<BR><CENTER><H2>WEPP output</H2></CENTER>';
        print '<PRE>';
        open weppout, "<$outputFile";
        for $line ( 0 .. 38 ) {
            $_ = <weppout>;
            print;
        }
        print "\n\n";
        while (<weppout>) {    # skip 'til "ANNUAL AVERAGE SUMMARIES"
            if (/ANNUAL AVERAGE SUMMARIES/) {    # DEH 03/07/2001 patch
                last;
            }
        }
        print;
        while (<weppout>) {                      # DEH 03/07/2001 patch
            print;
        }
        close weppout;
        print '</PRE>';
        print "<p><hr>";
        print '<center>
<a href="JavaScript:window.history.go(-1)">
<img src="/fswepp/images/rtis.gif"
  alt="Return to input screen" border="0" align=center></A>
<BR><HR></center>';
    }    # $outputf == 1

    #-------------------------------------

}    # $rcin >= 0
else {
    print "Content-type: text/html\n\n";
    print '<HTML>
 <HEAD>
  <TITLE>Tahoe Basin Sediment Model Results</TITLE>
 </head>
 <body>
';
    print $rcin;
}

print '
  <center>
   <font size=-1>
    <table border=1>
     <tr>
      <th bgcolor="lightgreen"><font size=-1>WEPP input files</font></th>
      <th bgcolor="lightgreen"><font size=-1>WEPP output</font></th>
     </tr>
     <tr>
      <td>
       <font size=-1>
          [ <a href="javascript:void(showresponsefile())">response</a>
          | <a href="javascript:void(showslopefile())">slope</a>
          | <a href="javascript:void(showsoilfile())">soil</a>
          | <a href="javascript:void(showvegfile())">vegetation</a>';
if ( !$fc ) {
    print '
          | <a href="javascript:void(showcligenparfile())">weather</a>';
}
print ' ]
       </font>
      </td>
      <td><font size=-1> [ <a href="javascript:void(showextendedoutput())">annual detailed</a> ] </font></td>
     </tr>
    </table>
   </font>
  </center>
  <hr>
';

print "
    <font size=-2>
<font size=-2>
<b>Citation:</b><br>
Elliot, William J.; Hall, David E. 2010. Tahoe Basin Sedimet Model. Ver. $version.
Moscow, ID: U.S. Department of Agriculture, Forest Service, Rocky Mountain Research Station.
Online at &lt;https://forest.moscowfsl.wsu.edu/fswepp&gt;.
<br><br>
     Tahoe Basin Sediment Model Results v.";
print '     <a href="javascript:popuphistory()">';
print
  "     $version</a> based on <b>WEPP $weppver</b>, CLIGEN $cligen_version<br>";
&printdate;
print "
     <br>
     Tahoe Basin Sediment Model Run ID $unique
    </font>
   </blockquote>
 </body>
</html>
";

#  system "rm working/$unique.*";

#   unlink <$working/$unique.*>;                #####  Nov unlink comment out  ####

$host        = $ENV{REMOTE_HOST};
$host        = $ENV{REMOTE_ADDR} if ( $host eq '' );
$user_really = $ENV{'HTTP_X_FORWARDED_FOR'};              # DEH 11/14/2002
$host        = $user_really if ( $user_really ne '' );    # DEH 11/14/2002

# 2008.06.04 DEH start
open PAR, "<$climatePar";
$PARline  = <PAR>;                                        # station name
$PARline  = <PAR>;                                        # Lat long
$lat_long = substr( $PARline, 0, 26 );
$lat      = substr $lat_long, 6,  7;
$long     = substr $lat_long, 19, 7;
close PAR;

# 2008.06.04 DEH end

#  record activity in Tahoe log (if running on remote server)

open WTLOG, ">>../working/_$thisyear/wt.log";    # 2012.12.31 DEH
flock( WTLOG, 2 );

#      $host = $ENV{REMOTE_HOST};
#      if ($host eq "") {$host = $ENV{REMOTE_ADDR} };
print WTLOG "$host\t\"";
printf WTLOG "%0.2d:%0.2d ", $hour, $min;
print WTLOG $ampm[$ampmi], "  ", $days[$wday], " ", $months[$mon], " ",
  $mday, ", ", $thisyear, "\"\t";
print WTLOG $years2sim, "\t";
print WTLOG '"', trim($climate_name), "\"\t";
print WTLOG "$lat\t$long\n";    # 2008.06.04 DEH

close WTLOG;

open CLIMLOG, ">../working/_$thisyear/lastclimate.txt";    # 2012.12.31 DEH
flock CLIMLOG, 2;
print CLIMLOG 'Tahoe: ', $climate_name;
close CLIMLOG;

$ditlogfile = ">>../working/_$thisyear/wt/$thisweek";      # 2012.12.31 DEH
open MYLOG, $ditlogfile;
flock MYLOG, 2;                                            # 2005.02.09 DEH
print MYLOG '.';
close MYLOG;

# #####
#    record run to user IP run log

$user_ID     = $ENV{'REMOTE_ADDR'};
$user_really = $ENV{'HTTP_X_FORWARDED_FOR'};              # DEH 11/14/2003
$user_ID     = $user_really if ( $user_really ne '' );    # DEH 11/14/2003
$user_ID =~ tr/./_/;
$user_ID    = $user_ID . $me;
$runLogFile = "../working/" . $user_ID . ".run.log";

## open runLogFile for append // print // close #

# print "Run log: $runLogFile\n";
( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
  localtime(time);
my @abbr = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
$year += 1900;
$actual_climate_name =~ s/^\s+//;
$actual_climate_name =~ s/\s+$//;

open RUNLOG, ">>$runLogFile";
flock( RUNLOG, 2 );
print RUNLOG "wt\t";
print RUNLOG "$unique\t";
print RUNLOG "\"$abbr[$mon] $mday, $year\"\t";
print RUNLOG "\"$actual_climate_name\"\t";
print RUNLOG "$soil\t";
print RUNLOG "$treat1\t";
print RUNLOG "$ofe1_top_slope\t";
print RUNLOG "$ofe1_mid_slope\t";
print RUNLOG "$user_ofe1_length\t";
print RUNLOG "$ofe1_pcover\t";
print RUNLOG "$ofe1_rock\t";
print RUNLOG "$treat2\t";
print RUNLOG "$ofe2_mid_slope\t";
print RUNLOG "$ofe2_bot_slope\t";
print RUNLOG "$user_ofe2_length\t";
print RUNLOG "$ofe2_pcover\t";
print RUNLOG "$ofe2_rock\t";
print RUNLOG "$units\t";
print RUNLOG "\"$description\"\n";
close RUNLOG;

# #####

# ------------------------ subroutines ---------------------------

sub ReadParse {

    # ReadParse -- from cgi-lib.pl (Steve Brenner) from Eric Herrmann's
    # "Teach Yourself CGI Programming With PERL in a Week" p. 131

    # Reads GET or POST data, converts it to unescaped text, and puts
    # one key=value in each member of the list "@in"
    # Also creates key/value pairs in %in, using '\0' to separate multiple
    # selections

    local (*in) = @_ if @_;
    local ( $i, $loc, $key, $val );

    #       read text
    if ( $ENV{'REQUEST_METHOD'} eq "GET" ) {
        $in = $ENV{'QUERY_STRING'};
    }
    elsif ( $ENV{'REQUEST_METHOD'} eq "POST" ) {
        read( STDIN, $in, $ENV{'CONTENT_LENGTH'} );
    }
    @in = split( /&/, $in );
    foreach $i ( 0 .. $#in ) {
        $in[$i] =~ s/\+/ /g;    # Convert pluses to spaces
        ( $key, $val ) = split( /=/, $in[$i], 2 );    # Split into key and value
        $key =~ s/%(..)/pack("c",hex($1))/ge
          ;    # Convert %XX from hex numbers to alphanumeric
        $val =~ s/%(..)/pack("c",hex($1))/ge;
        $in{$key} .= "\0"
          if ( defined( $in{$key} ) );    # \0 is the multiple separator
        $in{$key} .= $val;
    }
    return 1;
}

#---------------------------

sub printdate {

    @months =
      qw(January February March April May June July August September October November December);
    @days    = qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);
    $ampm[0] = "am";
    $ampm[1] = "pm";

    #   $ampmi = 0;
    #   ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime;
    #   if ($hour == 12) {$ampmi = 1}
    #   if ($hour > 12) {$ampmi = 1; $hour -= 12}
    #   printf "%0.2d:%0.2d ", $hour, $min;
    #   print $ampm[$ampmi],"  ",$days[$wday]," ",$months[$mon];
    #   print " ",$mday,", ",$year+1900, " GMT/UTC/Zulu<br>\n";

    $ampmi = 0;
    ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime;
    if ( $hour == 12 ) { $ampmi = 1 }
    if ( $hour > 12 )  { $ampmi = 1; $hour = $hour - 12 }
    $thisyear = $year + 1900;
    printf "%0.2d:%0.2d ", $hour, $min;
    print $ampm[$ampmi], "  ", $days[$wday], " ", $months[$mon];
    print " ", $mday, ", ", $thisyear, " Pacific Time\n";
}

sub CreateSlopeFile {

    # create slope file from specified geometry

    $top_slope1 = $ofe1_top_slope / 100;
    $mid_slope1 = $ofe1_mid_slope / 100;
    $mid_slope2 = $ofe2_mid_slope / 100;
    $bot_slope2 = $ofe2_bot_slope / 100;
    $avg_slope  = ( $mid_slope1 + $mid_slope2 ) / 2;
####   Counteract calculation difficulties in WEPP 2010.100 if slope is unchanging.  2012.10.29 DEH Hint from JRF
    $slope_fuzz = 0.001;
    if ( abs( $mid_slope1 - $mid_slope2 ) < $slope_fuzz ) {
        $mid_slope2 += 0.01;
    }
###
    $ofe_width = 100 if $ofe_area == 0;
    open( SlopeFile, ">" . $slopeFile );

    $listdirected = 1;
    if ($listdirected) {
        print SlopeFile "97.3\n";                              # datver
        print SlopeFile "#\n# Slope file generated for Tahoe\n#\n";
        print SlopeFile "2\n";                                 # no. OFE
        print SlopeFile
          "100 $ofe_width\n";    # aspect; representative profile width
                                 # OFE 1 (upper)
        printf SlopeFile "%d  %.2f\n",    3, $ofe1_length;  # no. points, length
        printf SlopeFile " %.2f, %.3f  ", 0, $top_slope1;   # dx, gradient
        printf SlopeFile " %.2f, %.3f  ", 0.5, $mid_slope1;    # dx, gradient
        printf SlopeFile " %.2f, %.3f\n", 1,   $avg_slope;     # dx, gradient
                                                               # OFE 2 (lower)
        printf SlopeFile "%d  %.2f\n",    3, $ofe2_length;  # no. points, length
        printf SlopeFile " %.2f, %.3f  ", 0, $avg_slope;    # dx, gradient
        printf SlopeFile " %.2f, %.3f  ", 0.5, $mid_slope2;    # dx, gradient
        printf SlopeFile " %.2f, %.3f\n", 1,   $bot_slope2;    # dx, gradient

        close SlopeFile;
        return $slopeFile;
    }
    else {
        print SlopeFile "97.3\n";                              # datver
        print SlopeFile "#\n# Slope file generated for Tahoe\n#\n";
        print SlopeFile "2\n";                                 # no. OFE
        print SlopeFile
          "100 $ofe_width\n";    # aspect; representative profile width
                                 # OFE 1 (upper)
        printf SlopeFile "%d  %.2f\n",   3,   $ofe1_length; # no. points, length
        printf SlopeFile "%.2f, %.2f  ", 0,   $top_slope1;  # dx, gradient
        printf SlopeFile "%.2f, %.2f  ", 0.5, $mid_slope1;  # dx, gradient
        printf SlopeFile "%.2f, %.2f\n", 1,   $avg_slope;   # dx, gradient
                                                            # OFE 2 (lower)
        printf SlopeFile "%d  %.2f\n",   3,   $ofe2_length; # no. points, length
        printf SlopeFile "%.2f, %.2f  ", 0,   $avg_slope;   # dx, gradient
        printf SlopeFile "%.2f, %.2f  ", 0.5, $mid_slope2;  # dx, gradient
        printf SlopeFile "%.2f, %.2f\n", 1,   $bot_slope2;  # dx, gradient
    }    #   if ($listdirected) {
    close SlopeFile;
    return $slopeFile;
}

# ###########################    CreateSoilFile    #########################

sub CreateSoilFile {    # 2010.05.27

    #  read: $treat1, $treat2, $soil $ofe1_rock, $ofe2_rock
    #  reads: soilbase_bp.tahoe

    #  $soil = 'alluvial';
    #  $treat1 = $ofe1;   # 'short'
    #  $treat2 = $ofe2;   # 'tree5'
    #  local   $fcover1 = $ofe1_pcover/100;
    #  local   $fcover2 = $ofe2_pcover/100;

    local $i, $in;
    local $soil1 = $soil;
    local $soil2 = $soil;

    $soil2 = 'alluvial' if ( $soil1 eq 'rockpave' );

    # make outer_offset hash	2009.08.28 DEH

    local $outer_offset = {};

    #   $outer_offset{granitic} = 6;
    #   $outer_offset{volcanic} = 36;
    #   $outer_offset{alluvial} = 66;
    #   $outer_offset{rockpave} = 96;
    $outer_offset{granitic} = 6;
    $outer_offset{volcanic} = 38;
    $outer_offset{alluvial} = 70;
    $outer_offset{rockpave} = 102;

    # make inner_offset hash        2009.08.28 DEH

    local $inner_offset = {};
    $inner_offset{Skid}        = 0;
    $inner_offset{HighFire}    = 2;
    $inner_offset{LowFire}     = 4;
    $inner_offset{Sod}         = 6;
    $inner_offset{Bunchgrass}  = 8;
    $inner_offset{Shrub}       = 10;
    $inner_offset{YoungForest} = 12;
    $inner_offset{OldForest}   = 14;
    $inner_offset{Bare}        = 16;
    $inner_offset{Mulch}       = 18;
    $inner_offset{Till}        = 20;
    $inner_offset{LowRoad}     = 22;
    $inner_offset{HighRoad}    = 24;
    $inner_offset{BurnP}       = 26;    # DEH 2012.09.07

    local $line_number1 = $outer_offset{$soil1} + $inner_offset{$treat1};
    local $line_number2 = $outer_offset{$soil2} + $inner_offset{$treat2};

    open SOLFILE, ">$soilFile";

    print SOLFILE "97.3
#
#      Created by 'wt.pl' (v $version)
#      Numbers by: Bill Elliot (USFS)
#
Soil file for Tahoe Basin Sediment Model run from soilbase_bp.tahoe for $treat1 $soil1 $treat2 $soil2
 2    1
";

    open SOILDB, "<data/soilbase_bp.tahoe";
    for $i ( 1 .. $line_number1 ) {
        $in = <SOILDB>;
    }
    chomp $in;
    print SOLFILE $in, "\n";

    $in = <SOILDB>;
    local $index_rfg = index( $in, 'rfg' );
    local $left      = substr( $in, 0, $index_rfg );
    local $right     = substr( $in, $index_rfg + 3 );
    $in = $left . $ofe1_rock . $right;

    print SOLFILE $in;
    close SOILDB;

    open SOILDB, "<data/soilbase_bp.tahoe";
    for $i ( 1 .. $line_number2 ) {
        $in = <SOILDB>;
    }
    chomp $in;
    print SOLFILE $in, "\n";
    $in        = <SOILDB>;
    $index_rfg = index( $in, 'rfg' );
    $left      = substr( $in, 0, $index_rfg );
    $right     = substr( $in, $index_rfg + 3 );
    $in        = $left . $ofe2_rock . $right;

    print SOLFILE $in;
    close SOILDB;
    close SOLFILE;
}

sub CreateResponseFile {

    # add Water file

    open( ResponseFile, ">" . $responseFile );

    #     print ResponseFile "98.4\n";        # datver
    print ResponseFile "m\n";    # 'metric'
    print ResponseFile "y\n";    # not watershed
    print ResponseFile "1\n";    # 1 = continuous
    print ResponseFile "1\n";    # 1 = hillslope
    print ResponseFile "n\n";    # hillsplope pass file out?
    if ( lc($action) =~ /vegetation/ ) {
        print ResponseFile "1\n";    # 1 = annual; abbreviated
    }
    else {
        print ResponseFile "2\n";    # 2 = annual; detailed
    }
    print ResponseFile "n\n";                # initial conditions file?
    print ResponseFile $outputFile, "\n";    # soil loss output file

    #    print ResponseFile "n\n";           # water balance output?
    print ResponseFile "y\n";                # water balance output?
    print ResponseFile $WatBalFile, "\n";    # water file name
    if ( lc($action) =~ /vegetation/ ) {
        print ResponseFile "y\n";              # crop output?
        print ResponseFile $cropFile, "\n";    # crop output file name
    }
    else {
        print ResponseFile "n\n";              # crop output?
    }
    print ResponseFile "n\n";               # soil output?
    print ResponseFile "n\n";               # distance/sed loss output?
    print ResponseFile "n\n";               # large graphics output?
    print ResponseFile "n\n";               # event-by-event out?
    print ResponseFile "n\n";               # element output?
    print ResponseFile "n\n";               # final summary out?
    print ResponseFile "n\n";               # daily winter out?
    print ResponseFile "n\n";               # plant yield out?
    print ResponseFile "$manFile\n";        # management file name
    print ResponseFile "$slopeFile\n";      # slope file name
    print ResponseFile "$climateFile\n";    # climate file name
    print ResponseFile "$soilFile\n";       # soil file name
    print ResponseFile "0\n";               # 0 = no irrigation
    print ResponseFile "$years2sim\n";      # no. years to simulate
    print ResponseFile "0\n";               # 0 = route all events

    close ResponseFile;
    return $responseFile;
}

sub checkInput {

    $rc = '';
    if ( $CL eq "" ) { $rc .= "No climate selected<br>\n" }
    if (   $soil ne "granitic"
        && $soil ne "volcanic"
        && $soil ne "alluvial"
        && $soil ne "rockpave" )
    {
        $rc .= "Invalid soil: " . $soil . "<br>\n";
    }

    #  if ($treat1 ne "skid" && $treat1 ne "high" && $treat1 ne "low"
    #      && $treat1 ne "short" && $treat1 ne "tall" && $treat1 ne "shrub"
    #      && $treat1 ne "tree5" && $treat1 ne "tree20")
    if ( $treatments{$treat1} eq "" ) {
        $rc .= "Invalid upper treatment: " . $treat1 . "<br>\n";
    }
    if ( $treatments{$treat2} eq "" ) {
        $rc .= "Invalid lower treatment: " . $treat2 . "<br>\n";
    }
    if ( $units eq 'm' ) {
        if ( $ofe1_length < 0 || $ofe1_length > 3000 ) {
            $rc .= "Invalid upper length; range 0 to 3000 m<br>\n";
        }
        if ( $ofe2_length < 0 || $ofe2_length > 3000 ) {
            $rc .= "Invalid lower length; range 0 to 3000 m<br>\n";
        }
    }
    else {
        if ( $ofe1_length < 0 || $ofe1_length > 9000 ) {
            $rc .= "Invalid upper length; range 0 to 9000 ft<br>\n";
        }
        if ( $ofe2_length < 0 || $ofe2_length > 9000 ) {
            $rc .= "Invalid lower length; range 0 to 9000 ft<br>\n";
        }
    }
    if ( $ofe1_top_slope < 0 || $ofe1_top_slope > 1000 ) {
        $rc .= "Invalid upper top gradient; range 0 to 1000 %<br>\n";
    }
    if ( $ofe1_mid_slope < 0 || $ofe1_mid_slope > 1000 ) {
        $rc .= "Invalid upper mid gradient; range 0 to 1000 %<br>\n";
    }
    if ( $ofe2_mid_slope < 0 || $ofe2_mid_slope > 1000 ) {
        $rc .= "Invalid lower mid gradient; range 0 to 1000 %<br>\n";
    }
    if ( $ofe2_bot_slope < 0 || $ofe2_bot_slope > 1000 ) {
        $rc .= "Invalid lower toe gradient; range 0 to 1000 %<br>\n";
    }

    #   if ($ofe1_pcover < 0 || $ofe1_pcover > 100)
    #      {$rc .= "Invalid upper percent cover; range 0 to 100 %<br>\n"}
    #   if ($ofe2_pcover < 0 || $ofe2_pcover > 100)
    #      {$rc .= "Invalid lower percent cover; range 0 to 100 %<br>\n"}
    if ( $rc ne '' ) { $rc = '<font color="red"><b>' . $rc . "</b></font>\n" }
    return $rc;
}

sub cropper {

    # average crop (.crp) file rill cover and live biomass
    #    by OFE  (ignoring spikes to zero?)
    #
    # Knuth: recurrent mean calculation is:
    #
    #   M(1) = x(1)
    #   M(k) = M(k-1) + (x(k)-M(k-1) / k
    #
    # (Seminumerical Methods, p. 232, Section 4.2.2, No. 15)

    open CROP, "<" . $cropFile;
    if ($debug) { print "Cropper: opening $cropFile<br>\n" }

    # read 15 lines of headers

    for $line ( 1 .. 15 ) {
        $header = <CROP>;
    }

    $_ = <CROP>;

    #  chomp;
    @fields         = split ' ', $_;
    $rillmean[1]    = $fields[5];
    $livebiomean[1] = $fields[8];
    $_              = <CROP>;

    #  chomp;
    @fields         = split ' ', $_;
    $rillmean[2]    = $fields[5];
    $livebiomean[2] = $fields[8];
    $count          = 1;

    while (<CROP>) {

        #    $record1 = <CROP>;
        if ( $_ eq "" ) { last }
        $count += 1;

        #    chomp;
        @fields = split ' ', $_;
        $ofe    = $fields[7];

        #    print "\n ",$fields[5],"  ",$fields[7],"  ",$fields[8];
        $rillcover[$ofe]   = $fields[5];
        $livebiomass[$ofe] = $fields[8];
        $rillmean[$ofe] += ( $rillcover[$ofe] - $rillmean[$ofe] ) / $count;
        $livebiomean[$ofe] +=
          ( $livebiomass[$ofe] - $livebiomean[$ofe] ) / $count;
    }
    close CROP;

    #  print "<pre>\n";
    #  print "OFE 1   Mean rill cover =   ", $rillmean[1],"\n";
    #  print "        Mean live biomass = ",$livebiomean[1],"\n";
    #  print "OFE 2   Mean rill cover =   ", $rillmean[2],"\n";
    #  print "        Mean live biomass = ",$livebiomean[2],"\n";
    #  print "Count = ", $count;
    #  print "</pre>";

}

sub numerically { $b <=> $a }

sub parsead {    ############### parsead

    $dailyannual = "<" . $outputFile;

    #   if ($debug) {print "\nParsead: opening $outputFile<br>\n"}
    open AD, $dailyannual;
    $_ = <AD>;

    if (/Annual; detailed/) {    # Good file
        for $i ( 2 .. 8 ) { $_ = <AD> }

        #    if (/VERSION *([0-9.]+)/) {$version = $1}
        #    print "\n", $version,"\n";

        #======================== yearly precip and runoff events and amounts

    #    print "</center><pre>\n";
    #    print "    \t       \t       \t storm \t storm \t melt  \t melt\n";
    #    print "    \t precip\t precip\t runoff\t runoff\t runoff\t runoff\n";
    #    print "year\t events\t amount\t events\t amount\t events\t amount\n\n";
        while (<AD>) {
            if (/year: *([0-9]+)/) {
                $year = $1;

                #        print $year,"  ";
                for $i ( 1 .. 6 ) { $_ = <AD> }
                (
                    $pcpe[$year], $pcpa[$year], $sre[$year],
                    $sra[$year],  $mre[$year],  $mra[$year]
                ) = split ' ', $_;

#        print "\t",$pcpe[$year],"\t",$pcpa[$year],"\t",$sre[$year],"\t",$sra[$year],"\t",$mre[$year],"\t",$mra[$year],"\n";
                $re[$year] = $sre[$year] + $mre[$year];
                $ra[$year] = $sra[$year] + $mra[$year];
            }
        }
        close AD;

        #======================== yearly sediment leaving profile

        open AD, $dailyannual;

        #    print "\nyear\tSediment\n\tleaving\n\tprofile\n\n";
        while (<AD>) {
            if (/SEDIMENT LEAVING PROFILE for year *([0-9]+) *([0-9.]+)/) {
                $year = $1;
                $sed_del[$year] = $2;

                #       print "$year\t$sed_del[$year]\n";
            }
        }
        close AD;

     #====== Net detachment (not all years are represented; final is an average)

        open AD, $dailyannual;

        #    print "\nArea of net soil loss\n\n";
        $detcount = 0;
        while (<AD>) {

            #      if (/Net Detachment *([A-Za-z.( )=]+) *([0-9.]+)/) {
            if (/Net Detachment *([A-Za-z( )=]+) *([0-9.]+)/) {
                $detachx[$detcount] = $2;

                #        print "$detachx[$detcount]\n";
                $detcount += 1;
            }
        }
        $detcount -= 1;
        $avg_det = $detachx[$detcount];
        $detcount -= 1;
        for $looper ( 0 .. $detcount ) { $detach[$looper] = $detachx[$looper] }
        close AD;

        #===================== Mean annual values for various parameters

        open AD, $dailyannual;
        while (<AD>) {
            if (/Mean annual precipitation *([0-9.]+)/) {
                $avg_pcp = $1;

                #        print "\n\nAverage annual precip: $avg_pcp\n";
                $_ = <AD>;
                if (/Mean annual runoff from rainfall *([0-9.]+)/) {
                    $avg_rro = $1;

             #          print "Average annual runoff from rainfall: $avg_rro\n";
                }
                $_ = <AD>;
                $_ = <AD>;
                if (/rain storm during winter *([0-9.]+)/) {
                    $avg_sro = $1;

             #          print "Average annual runoff from snowmelt: $avg_sro\n";
                }
            }
            if (/AVERAGE ANNUAL SEDIMENT LEAVING PROFILE/) {

                #        print $_;
                if (/AVERAGE ANNUAL SEDIMENT LEAVING PROFILE *([0-9.]+)/)
                {    # WEPP pre-98.4
                    $avg_sed = $1;
                }
                else {    # WEPP 98.4
                    $_ = <AD>;    # print;
                    if (/ *([0-9.]+)/) { $avg_sed = $1 }
                }

                #        print "Average sediment delivery = $avg_sed\n";
            }

            # --- SSA enrichment ratio ---
            if (
/Average annual SSA enrichment ratio leaving profile = *([0-9.]+)/
              )
            {
                $SSA_ratio = $1;
            }

            #  -- for FINES --
            if (/SEDIMENT CHARACTERISTICS/) {
                $dummy = <AD>;    #
                $dummy =
                  <AD>;    #     Sediment particle information leaving profile
                $dummy = <AD>
                  ; #-------------------------------------------------------------------------------
                $dummy = <AD>
                  ; #                                 Particle Composition         Detached Fraction
                $dummy = <AD>
                  ; #Class  Diameter  Specific  ---------------------------------  Sediment  In Flow
                $dummy = <AD>
                  ; #         (mm)    Gravity   % Sand   % Silt   % Clay   % O.M.  Fraction  Exiting
                $dummy = <AD>
                  ; #-------------------------------------------------------------------------------
                $class1 = <AD>
                  ; #  1     0.002      2.60      0.0      0.0    100.0    100.0     0.005    0.006
                $class2 = <AD>
                  ; #  2     0.010      2.65      0.0    100.0      0.0      0.0     0.044    0.050
                $class3 = <AD>
                  ; #  3     0.030      1.80      0.0     80.0     20.0     20.0     0.036    0.041
                $class4 = <AD>
                  ; #  4     0.300      1.60     85.4      7.1      7.5      7.5     0.101    0.115
                $class5 = <AD>
                  ; #  5     0.200      2.65    100.0      0.0      0.0      0.0     0.814    0.788
            }
        }
        close AD;

        chomp $class5;
        chomp $class4;
        chomp $class3;
        chomp $class2;
        chomp $class1;

        @pcpa = sort numerically @pcpa;

        #    print @pcpa,"\n";
        @ra = sort numerically @ra;

        #    print @ra,"\n";
        @detach = sort numerically @detach;

        #    print @detach,"\n";
        @sed_del = sort numerically @sed_del;

        #    print @sed_del,"\n";

        $nnzpcp     = 0;
        $nnzra      = 0;
        $nnzdetach  = 0;
        $nnzsed_del = 0;
        foreach $elem (@pcpa)    { $nnzpcp     += 1 if ( $elem * 1 != 0 ) }
        foreach $elem (@ra)      { $nnzra      += 1 if ( $elem * 1 != 0 ) }
        foreach $elem (@detach)  { $nnzdetach  += 1 if ( $elem * 1 != 0 ) }
        foreach $elem (@sed_del) { $nnzsed_del += 1 if ( $elem * 1 != 0 ) }
        $nzpcp       = $simyears - $nnzpcp;
        $nzra        = $simyears - $nnzra;
        $omnzra      = 1 - $nzra;
        $nzdetach    = $simyears - $nnzdetach;
        $omnzdetach  = 1 - $nzdetach;
        $nzsed_del   = $simyears - $nnzsed_del;
        $omnzsed_del = 1 - $nzsed_del;

        $avg_ro = $avg_rro + $avg_sro;

#print $year;
#print "\n================================\n";
#print "\t precip\trunoff\terosion\tsed\n\n";
# print "#(x=0)\t pcp= $nnzpcp\t sra= $nnzra\t det= $nnzdetach\t sed_del= $nnzsed_del\n";
# print "#(x=0)\t pcp= $nzpcp\t sra= $nzra\t det= $nzdetach\t sed_del= $nzsed_del\n";
#print "p(x=0)\t",($nzpcp)/$year,
#            "\t",($nzra)/$year,
#            "\t",($nzdetach)/$year,
#            "\t",($nzsed_del)/$year,"\n";
#print "Average $avg_pcp\t$avg_ro\t$avg_det\t$avg_sed\n";
#print "return\nperiod\n";
#print "100\t$pcpa[0]\t$ra[0]\t$detach[0]\t$sed_del[0]\n";    # 1
#print " 50\t$pcpa[1]\t$ra[1]\t$detach[1]\t$sed_del[1]\n";    # 2
#print " 20\t$pcpa[4]\t$ra[4]\t$detach[4]\t$sed_del[4]\n";    # 5
#print " 10\t$pcpa[9]\t$ra[9]\t$detach[9]\t$sed_del[9]\n";    # 10
#print "  5\t$pcpa[19]\t$ra[19]\t$detach[19]\t$sed_del[19]\n";    # 20
#print "</pre><center>\n";
#==================
    }    # if /Annual detailed/
    else {
        chomp;
        s/^\s*(.*?)\s*$/$1/;
        print "\nExpecting 'Annual; detailed' file; you gave me a '$_' file\n";
    }
}

sub ExtractCligenFile {

    # $startYear
    # Cligen File Name (and path)
    # unique file base for CLI file result

    # $startYear = 2001;
    $endYear = $startYear + $years2sim;

    $climateFile = "../working/$unique.cli";

    open CLI,   "<$fullCliFile";
    open CLOUT, ">$climateFile";

    $line = <CLI>;
    print CLOUT $line;    #     4.3
    $line = <CLI>;
    print CLOUT $line;    #          1     1   0
    $line = <CLI>;
    print CLOUT $line;    #    Station:  SNOTEL - Echo Peak Snotel A2
    $line = <CLI>;
    print CLOUT $line
      ; #     Latitude Longitude Elevation (m) Obs. Years   Beginning year  Years simulated
    $line = <CLI>;
    print CLOUT $line
      ;    #      38.855        -120.075   2028.96      99    2001      99
    $line = <CLI>;
    print CLOUT $line;    #    Observed monthly ave max temperature (C)
    $line = <CLI>;
    print CLOUT $line
      ; #         5.6     6.6     9.3    10.9    14.9    19.3    24.0    23.6    21.4    15.8         8.6     4.8
    $line = <CLI>;
    print CLOUT $line;    #    Observed monthly ave min temperature (C)
    $line = <CLI>;
    print CLOUT $line
      ; #        -7.7    -7.5    -6.0    -4.4    -1.3     1.2     4.5     4.3     2.1    -1.3      -5.3    -8.0
    $line = <CLI>;
    print CLOUT $line; #     Observed monthly ave solar radiation (Langleys/day)
    $line = <CLI>;
    print CLOUT $line
      ; #       213.5   283.3   408.6   498.4   589.3   674.2   684.2   610.1   503.7   381.5   252.1   201.5
    $line = <CLI>;
    print CLOUT $line;    #    Observed monthly ave precipitation (mm)
    $line = <CLI>;
    print CLOUT $line
      ; #       324.7   268.5   255.5   133.6    98.6    32.2     3.2     7.8    25.6    82.0   200.   332.6
    $line = <CLI>;
    print CLOUT $line
      ; #     da       mo   year    prcp     dur     tp       ip    tmax    tmin     rad    w-vl    w-dir    tdew
    $line = <CLI>;
    print CLOUT $line
      ; #                           (mm)     (h)                     (C)     (C)    (l/d)  (m/s)   (Deg)     (C)

    while (<CLI>) {
        if ( substr( $_, 0, 8 ) eq "1\t1\t$startYear" ) {
            print CLOUT $_;
            while (<CLI>) {
                if ( substr( $_, 0, 8 ) eq "1\t1\t$endYear" ) {
                    last;
                }
                else {
                    print CLOUT $_;
                }
            }
        }
    }
    close CLOUT;
    close CLI;

}

sub getAnnualPrecip {

    # in:  $climatePar
    # out: $ap_mean_precip

    open PAR, "<$climatePar";
    $line = <PAR>;    # EPHRATA CAA AP WA                       452614 0
    if ($debug) { print $line, "<br>\n" }
    $line = <PAR>;    # LATT=  47.30 LONG=-119.53 YEARS= 44. TYPE= 3
    $line = <PAR>;    # ELEVATION = 1260. TP5 = 0.86 TP6= 2.90
    $line = <PAR>
      ; # MEAN P   0.10  0.10  0.11  0.10  0.11  0.14  0.14  0.09  0.10  0.10  0.12  0.12
    @ap_mean_p_if   = split ' ', $line;
    $ap_mean_p_base = 2;
    $line           = <PAR>
      ; # S DEV P  0.12  0.12  0.11  0.13  0.13  0.18  0.22  0.13  0.13  0.11  0.14  0.13
    $line = <PAR>
      ; # SQEW  P  1.88  2.30  2.21  2.15  2.29  2.35  3.60  3.22  2.05  2.49  2.22  1.87
    $line = <PAR>
      ; # P(W/W)   0.47  0.50  0.39  0.32  0.33  0.30  0.27  0.28  0.40  0.41  0.42  0.48
    @ap_pww      = split ' ', $line;
    $ap_pww_base = 1;
    $line        = <PAR>
      ; # P(W/D)   0.20  0.16  0.15  0.13  0.13  0.11  0.05  0.06  0.08  0.12  0.23  0.23
    @ap_pwd      = split ' ', $line;
    $ap_pwd_base = 1;
    close PAR;

    @ap_month_days = ( 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 );

    $ap_units = 'm';

    #   $pcpunit='in';
    for $ap_i ( 1 .. 12 ) {
        $ap_pw[$ap_i] =
          $ap_pwd[$ap_i] / ( 1 + $ap_pwd[$ap_i] - $ap_pww[$ap_i] );
    }
    $ap_annual_precip   = 0;
    $ap_annual_wet_days = 0;
    for $ap_i ( 0 .. 11 ) {
        $ap_num_wet = $ap_pw[ $ap_i + $ap_pww_base ] * $ap_month_days[$ap_i];
        $ap_mean_p  = $ap_num_wet * $ap_mean_p_if[ $ap_i + $ap_mean_p_base ];
        if ( $ap_units eq 'm' ) {
            $ap_mean_p *= 25.4;    # inches to mm
        }
        $ap_annual_precip += $ap_mean_p;
    }
}

sub trim($) {
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}

sub CreateManagementFileT {

# new TAHOE management files
# Add lines from Disturbed WEPP CreateManagementFileT for variable pcover  2012.11.02 DEH

#     $climatePar = $CL . '.par';
#     &getAnnualPrecipT ($climatePar);                  # open .par file and calculate annual precipitation
#     if ($debug) {print "Annual Precip: $ap_annual_precip mm<br>\n"}

    #  $treat1 = "skid";   $treat2 = "tree5";

    open MANFILE, ">$manFile";

    print MANFILE "98.4
#
#\tCreated for Tahoe by wt.pl (v. $version)
#\tNumbers by: Bill Elliot (USFS) et alia
#

2\t# number of OFEs
$years2sim\t# (total) years in simulation

#################
# Plant Section #
#################

2\t# looper; number of Plant scenarios data/$treat1.plt data/$treat2.plt

";

    open PS1, "<data/$treat1.plt";    # WEPP plant scenario

   #  read 14 lines (base 0); line 9 entry 2 will change (biomass) as f(climate)

#  $beinp is biomass energy ratio (real ~ 0 to 1000): plant scenario 7.3 (p. 33)
#  the following equation relates biomass ratio to cover (whole) percent and precipitation in mm
#  from work December 1999 by W.J. Elliot unpublished.

    #   ($ofe1_pcover > 100) ? $pcover = 100 : $pcover = $ofe1_pcover;
    $pcover = $ofe1_pcover
      ; # decided not to limit input cover to 100%; use whatever is entered (for now)

#   $precip_cap = 450;           # max precip in mm to put into biomass equation (curve flattens out)
#   ($ap_annual_precip < $precip_cap) ? $capped_precip = $ap_annual_precip : $capped_precip = $precip_cap;
#   $beinp = sprintf "%.1f", 8.17 * exp(0.031 * $pcover - 0.0023 * $capped_precip);

    while (<PS1>) {

#    if (/beinp/) {                              # read file search for token to replace with value
#       $index_beinp = index($_,'beinp');                # where does token start?
#       $wps_left = substr($_,0,$index_beinp);           # grab stuff to left of token
#       $wps_right = substr($_,$index_beinp+5);          # grab stuff to right of token end
#       $_ = $wps_left . $beinp . $wps_right;            # stuff value inbetween the two ends
#       if ($debug) {print "<b>wps1:</b><br>
#                           pcover: $pcover<br>
#                           beinp: $beinp<br><pre> $_<br>\n"}
#    }
        print MANFILE $_;    # print line to management file
    }
    close PS1;

    open PS2, "<data/$treat2.plt";

   #  read 14 lines (base 0); line 9 entry 2 will change (biomass) as f(climate)

    #   ($ofe2_pcover > 100)? $pcover = 100 : $pcover = $ofe2_pcover;
    $pcover = $ofe2_pcover;

#   ($ap_annual_precip < $precip_cap) ? $capped_precip = $ap_annual_precip : $capped_precip = $precip_cap;
#   $beinp = sprintf "%.1f", 8.17 * exp(0.031 * $pcover - 0.0023 * $capped_precip);;

    print MANFILE "\n";

    while (<PS2>) {

        #    if (/beinp/) {
        #       $index_beinp = index($_,'beinp');
        #       $wps_left = substr($_,0,$index_beinp);
        #       $wps_right = substr($_,$index_beinp+5);
        #       $_ = $wps_left . $beinp . $wps_right;
        #       if ($debug) {print "</pre><b>wps2:</b><br>
        #                           pcover: $pcover<br>
        #                           beinp: $beinp<br><pre> $_<br>\n"}
        #    }
        print MANFILE $_;
    }
    close PS2;

    print MANFILE "
#####################
# Operation Section #
#####################

2\t# looper; number of Operation scenarios data/$treat1.op data/$treat2.op

";

    open OP, "<data/$treat1.op";    # Operations
    while (<OP>) {

        #    if (/itype/) {substr ($_,0,1) = "1"}
        print MANFILE $_;
    }
    close OP;

    print MANFILE "\n";

    open OP, "<data/$treat2.op";
    while (<OP>) {

        #    if (/itype/) {substr ($_,0,1) = "2"}
        print MANFILE $_;
    }
    close OP;

    print MANFILE "
##############################
# Initial Conditions Section #
##############################

2\t# looper; number of Initial Conditions scenarios data/$treat1.ini data/$treat2.ini

";

#  $inrcov is initial interrill cover (real 0-1): initial conditions 6.6 (p. 37)
#  $rilcov is initial rill cover (real 0-1): initial conditions 9.3 (p. 37)
#  $pcoverf is user-specified ground cover, formatted, decimal percent        2012.11.02 DEH
#  December 1999 by W.J. Elliot unpublished.

    ( $ofe1_pcover > 100 ) ? $pcover = 100 : $pcover = $ofe1_pcover;
    $inrcov  = sprintf "%.2f", $pcover / 100;
    $rilcov  = $inrcov;
    $pcoverf = sprintf "%7.5f", $pcover / 100;    # 2012.11.02 DEH

    open IC, "<data/$treat1.ini";    # Initial Conditions Scenario file

    #  read 14 lines (base 0); change line 8 values 1 and 5; line 11 value 2

    while (<IC>) {

        #    if (/iresd/) {substr ($_,0,1) = "1"}
        if (/inrcov/) {
            $index_pos = index( $_, 'inrcov' );
            $ics_left  = substr( $_, 0, $index_pos );
            $ics_right = substr( $_, $index_pos + 6 );
            $_         = $ics_left . $inrcov . $ics_right;
            if ($debug) { print "<b>ics1:</b><br>$_<br>\n" }
        }
        if (/rilcov/) {
            $index_pos = index( $_, 'rilcov' );
            $ics_left  = substr( $_, 0, $index_pos );
            $ics_right = substr( $_, $index_pos + 6 );
            $_         = $ics_left . $rilcov . $ics_right;
            if ($debug) { print "$_<br>\n" }
        }
##### start canopy cover (pcover) variability added 2012.11.02 DEH
        if (/pcover/) {
            $index_pos = index( $_, 'pcover' );
            $ics_left  = substr( $_, 0, $index_pos );
            $ics_right = substr( $_, $index_pos + 6 );
            $_         = $ics_left . $pcoverf . $ics_right;
            if ($debug) { print "<b>ics1:</b><br>$_<br>\n" }
        }
##### end canopy cover (pcover) variability added 2012.11.02 DEH
        print MANFILE $_;
    }
    close IC;

    print MANFILE "\n";

    ( $ofe2_pcover > 100 ) ? $pcover = 100 : $pcover = $ofe2_pcover;
    $pcoverf = sprintf "%7.5f", $pcover / 100;    # 2012.11.02 DEH
    $inrcov  = sprintf "%.2f",  $pcover / 100;
    $rilcov  = $inrcov;

    open IC, "<data/$treat2.ini";

    #  read 14 lines (base 0); change line 8 values 1 and 5; line 11 value 2
    while (<IC>) {

        #    if (/iresd/) {substr ($_,0,1) = "2"}
        if (/inrcov/) {
            $index_pos = index( $_, 'inrcov' );
            $ics_left  = substr( $_, 0, $index_pos );
            $ics_right = substr( $_, $index_pos + 6 );
            $_         = $ics_left . $inrcov . $ics_right;
            if ($debug) { print "<b>ics2:</b><br>$_<br>\n" }
        }
##### start canopy cover (pcover) variability added 2012.11.02 DEH
        if (/pcover/) {
            $index_pos = index( $_, 'pcover' );
            $ics_left  = substr( $_, 0, $index_pos );
            $ics_right = substr( $_, $index_pos + 6 );
            $_         = $ics_left . $pcoverf . $ics_right;
            if ($debug) { print "<b>ics1:</b><br>$_<br>\n" }
        }
##### end canopy cover (pcover) variability added 2012.11.02 DEH
        if (/rilcov/) {
            $index_pos = index( $_, 'rilcov' );
            $ics_left  = substr( $_, 0, $index_pos );
            $ics_right = substr( $_, $index_pos + 6 );
            $_         = $ics_left . $rilcov . $ics_right;
            if ($debug) { print "$_</pre><br>\n" }
        }
        print MANFILE $_;
    }
    close IC;

    print MANFILE "
###########################
# Surface Effects Section #
###########################

2\t# Number of Surface Effects Scenarios

#
#   Surface Effects Scenario 1 of 2
#
Year 1
From WEPP database
USFS RMRS Moscow

1\t# landuse  - cropland
1\t# ntill - number of operations
  2\t# mdate  --- 1 / 2 
  1\t# op --- Tah_****
      0.010\t# depth
      2\t# type

#
#   Surface Effects Scenario 2 of 2
#
Year 2
From WEPP database
USFS RMRS Moscow

1\t# landuse  - cropland
1\t# ntill - number of operations
  2\t# mdate  --- 1 / 2 
  2\t# op --- Tah_****
      0.010\t# depth
      2\t# type

######################
# Contouring Section #
######################

0\t# looper; number of Contouring scenarios

####################
# Drainage Section #
####################

0\t# looper; number of Drainage scenarios

##################
# Yearly Section #
##################

2\t# looper; number of Yearly Scenarios

#
# Yearly scenario 1 of 2
#
Year 1 



1\t# landuse <cropland>
1\t# plant growth scenario
1\t# surface effect scenario
0\t# contour scenario
0\t# drainage scenario
2\t# management <perennial>
   250\t# senescence date 
   0\t# perennial plant date --- 0 /0
   0\t# perennial stop growth date --- 0/0
   0.0000\t# row width
   3\t# neither cut or grazed

#
# Yearly scenario 2 of 2
#
Year 2 



1\t# landuse <cropland>
2\t# plant growth scenario
2\t# surface effect scenario
0\t# contour scenario
0\t# drainage scenario
2\t# management <perennial>
   250\t# senescence date 
   0\t# perennial plant date --- 0 /0
   0\t# perennial stop growth date --- 0/0
   0.0000\t# row width
   3\t# neither cut or grazed
";
    print MANFILE "
######################
# Management Section #
######################
Tahoe Basin Sediment Model
Two OFEs for forest conditions
W. Elliot 02/99

2\t# `nofe' - <number of Overland Flow Elements>
\t1\t# `Initial Conditions indx' - <$treat1>
\t2\t# `Initial Conditions indx' - <$treat2>
$years2sim\t# `nrots' - <rotation repeats..>
1\t# `nyears' - <years in rotation>
";

    for $i ( 1 .. $years2sim ) {
        print MANFILE "
#
#       Rotation $i : year $i to $i
#
\t1\t# `nycrop' - <plants/yr; Year of Rotation :  $i - OFE : 1>
\t\t1\t# `YEAR indx' - <$treat1>

\t1\t# `nycrop' - <plants/yr; Year of Rotation :  $i - OFE : 2>
\t\t2\t# `YEAR indx' - <$treat2>
";
    }
    close MANFILE;
}

#####################################
#
#   Read lateral flow from water file     ###################### Water Balance
#
#####################################

sub WaterBalanceSum() {    ###################### Water Balance


# returns total precip, Q, Ep, Es, Dp, latqcc, sum from bottom OFE
# variable-OFE file
# note: Lateral Flow likely desired will be (latqcc * (bottom OFE length) / (total slope length))

# Argument is WEPP water file name [$WatBalFile]
# reads WEPP Water file
# return vector of P  RM Q  Ep Es Dp latqcc total-soil-water total-soil-water-start total-soil-water-end
#                  mm mm mm mm mm mm mm     mm
# ($sumP,$sumRM,$sumQ,$sumEp,$sumEs,$sumDp,$sumLatqcc,$sumTotal,$firstTotalSoilWater,$lastTotalSoilWater,$OFEsoff)

    my $WaterFile = @_[0];    # name of WEPP water file
    my $sumP      = 0;
    my $sumEp     = 0;
    my $sumEs     = 0;
    my $sumDp     = 0;
    my $sumLatqcc = 0;
    my $sumRM     = 0;
    my $sumQ      = 0;
    my $i;
    my $line;
    my $first;
    my $OFEsoff;                 # track that we are not off in reading OFEs
    my $OFE, $JulDay, $SimYr, $P, $RM, $Q, $Ep, $Es, $Dp, $UpStrmQ, $latqcc,
      $TotSoilWater, $frozwt;    # read from file
    my $firstTotalSoilWater, $firstline;
    my $nOFE;                    # number of OFEs reported in the water file

    # open WTRFILE, "<$WatBalFile";
    open WTRFILE, "<$WaterFile";

#  0 DAILY WATER BALANCE
#  1
#  2 J=julian day, Y=simulation year
#  3 P= precipitation
#  4 RM=rainfall+irrigation+snowmelt
#  5 Q=daily runoff, Ep=plant transpiration
#  6 Es=soil evaporation, Dp=deep percolation
#  7 watstr=water stress for plant growth  latqcc=lateral subsurface flow
#  8
#  9 ------------------------------------------------------------------------------
# 10 OFE  J    Y      P      RM     Q      Ep    Es     Dp  UpStrmQ  latqcc Total-Soil  frozwt
# 11 #    -    -      mm     mm     mm     mm     mm     mm     -      mm    Water(mm)   mm
# 12 ------------------------------------------------------------------------------
# 13
# 14      1    1    1    8.80    0.00   0.0000000E+00    0.00    0.02    0.00   0.0000000E+00    0.00  134.88    0.00

    # determine how many OFEs

    for ( $i = 0 ; $i < 14 ; $i++ ) {
        $line = <WTRFILE>;
    }
    $nOFE = 0;
    while ( $line = <WTRFILE> ) {
        (
            $OFE,    $JulDay, $SimYr, $P, $RM, $Q, $Ep, $Es, $Dp, $UpStrmQ,
            $latqcc, $TotSoilWater, $frozwt
        ) = split ' ', $line;
        last if ( $OFE < $nOFE );
        $nOFE = $OFE;
    }
    close WTRFILE;

    # print " $nOFE OFEs\n";

##############################

    # open WTRFILE, "<$WatBalFile";
    open WTRFILE, "<$WaterFile";

    for ( $i = 0 ; $i < 14 ; $i++ ) {
        $line = <WTRFILE>;
    }

    #  print $line;

    #    print "OFE\tP\tRM\tQ\tEp\tEs\tDp\tlatqcc\ttotal\n";
    #    print "\tmm\tmm\tmm\tmm\tmm\tmm\tmm\tmm\n";

    $first   = 1;
    $OFEsoff = 0;

    while ( $line = <WTRFILE> ) {    # OFE 1
        for ( $i = 1 ; $i < $nOFE ; $i++ ) {
            $line = <WTRFILE>;       # eat up OFE 2, 3, ..., $nOFE
        }
        (
            $OFE,    $JulDay, $SimYr, $P, $RM, $Q, $Ep, $Es, $Dp, $UpStrmQ,
            $latqcc, $TotSoilWater, $frozwt
        ) = split ' ', $line;
        $OFEsoff = 1 if ( $OFE != $nOFE );

        $firstTotalSoilWater = $TotSoilWater if ($first);
        $firstline           = $line         if ($first);

        $first = 0;

#    $latqcc/=4;        # four OFEs -- multiply by (bottom OFE length / full length)
# delay gratification -- we don't know OFE or hillslope lengths
#   $total = $RM + $Q + $Ep + $Es + $Dp + $latqcc;
        $total = $Q + $Ep + $Es + $Dp + $latqcc;

        #   print "$OFE\t$P\t$RM\t$Q\t$Ep\t$Es\t$Dp\t$latqcc\t$total\n";
        $sumRM     += $RM;
        $sumQ      += $Q;
        $sumP      += $P;
        $sumEp     += $Ep;
        $sumEs     += $Es;
        $sumDp     += $Dp;
        $sumLatqcc += $latqcc;
        $sumTotal  += $total;
    }
    $lastTotalSoilWater = $TotSoilWater;

    close WTRFILE;

    #print "\n Totals\n";
    #print "\tP\tRM\tQ\tEp\tEs\tDp\tLatqcc\tTotal\n";
##print "\t$sumP\t$sumRM\t$sumQ\t$sumEp\t$sumEs\t$sumDp\t$sumLatqcc\t$sumTotal\n";
#printf "\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n", $sumP,$sumRM,$sumQ,$sumEp,$sumEs,$sumDp,$sumLatqcc,$sumTotal;

    # $sumP/=$years2sim;             # $years2sim year run --> average year
    # $sumRM/=$years2sim;
    # $sumQ/=$years2sim;
    # $sumEp/=$years2sim;
    # $sumEs/=$years2sim;
    # $sumDp/=$years2sim;
    # $sumLatqcc/=$years2sim;
    # $sumTotal/=$years2sim;

# print "\t$sumP\t$sumRM\t$sumQ\t$sumEp\t$sumEs\t$sumDp\t$sumLatqcc\t$sumTotal\n";
# $results = sprintf "\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n", $sumP,$sumRM,$sumQ,$sumEp,$sumEs,$sumDp,$sumLatqcc,$sumTotal;
# @results = split ' ',$results;
    @results = (
        $sumP, $sumRM, $sumQ, $sumEp, $sumEs, $sumDp, $sumLatqcc, $sumTotal,
        $firstTotalSoilWater, $lastTotalSoilWater, $OFEsoff
    );
    return @results;
}

#####################################
sub make_history_popup {

    my $version;

    # Reads parent (perl) file and looks for a history block:
## BEGIN HISTORY ####################################################
    # ERMiT Version History

    $version = '2005.02.08';    # Make self-creating history popup page

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

    my ( $line, $z, $vers, $comment );

    open MYSELF, "<$0";
    while (<MYSELF>) {

        next if (/!/);

        if (/## BEGIN HISTORY/) {
            $line = <MYSELF>;
            chomp $line;
            $line = substr( $line, 2 );
            $z    = "    pophistory.document.writeln('<html>')
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
        }    # if (/## BEGIN HISTORY/)

        if (/version/) {
            ( $vers, $comment ) = split( /;/, $_ );
            $comment =~ s/#//;
            chomp $comment;
            $vers =~ s/'//g;
            $vers =~ s/ //g;
            $vers =~ s/"//g;
            if ( $vers =~ /version=*([0-9.]+)/ )
            {    # pull substring out of a line
                $z .= "    pophistory.document.writeln('    <tr>')
    pophistory.document.writeln('     <th valign=top bgcolor=lightblue>$1</th>')
    pophistory.document.writeln('     <td>$comment</td>')
    pophistory.document.writeln('    </tr>')
";
            }    # (/version *([0-9]+)/)
        }    # if (/version/)

        if (/## END HISTORY/) {
            $z .= "    pophistory.document.writeln('   </table>')
    pophistory.document.writeln('   </font>')
    pophistory.document.writeln('  </center>')
    pophistory.document.writeln(' </body>')
    pophistory.document.writeln('</html>')
";
            last;
        }    # if (/## END HISTORY/)
    }    # while
    close MYSELF;
    return $z;
}

# ------------------------ end of subroutines ----------------------------
