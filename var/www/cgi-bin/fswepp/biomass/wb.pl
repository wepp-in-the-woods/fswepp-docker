#!/usr/bin/perl

use warnings;
use CGI;
use CGI qw(escapeHTML);
use String::Util qw(trim);

use MoscowFSL::FSWEPP::CligenUtils qw(CreateCligenFile GetParSummary GetAnnualPrecip);
use MoscowFSL::FSWEPP::FsWeppUtils
  qw(CreateSlopeFile CreateSlopeFileWeppRoad printdate CreateSoilFile get_thisyear_and_thisweek get_version);

my $debug = 0;

#  wb.pl -- BIOMASS workhorse
#  Modified by HR from fume2.pl 2013.03.01

## BEGIN HISTORY ##############################
# WEPP BIOMASS Results history

$version = get_version(__FILE__);

#  $version = '2015.05.27';    # Unlink temporary and WEPP output files when done
#  $version = '2015.05.06';	# Run WEPP 2010.100 and update roads soil data
#  $version = '2014.02.22';	# Add new calculations A through F
#  $version = '2014.02.21';
#  $version = '2013.09.27';	# "Thinning" to "Harvest" etc.
#  $version = '2013.03.01';     # Modified from FuME
## END HISTORY ##############################

# Reads user input from biomass.pl
#   runs Disturbed WEPP (4 runs) (plus some more)
#   runs WEPP:Road (3 times)
#   parses output files
# English units only at present

# Writes:
#   ../working/_[year]/wb.log

# to do: Road network will add...
#	unlink working files

# David Hall and Hakjun Rhee, USDA Forest Service, Rocky Mountain Research Station, Moscow, ID

#=========================================================================

my @out_asypa;

#####  TEMPORARY KLUGE TO FORCE VALUES TO MAKE THE MODEL RUN  #####

$wildfire_cycle   = 20;
$rx_fire_cycle    = 40;
$harvest_cycle    = 10;
$CL               = 'z';      # Climate (file name base)
$soil             = 'sand';
$hillslope_length = 100;
$ofe1_top_slope   = 0;
$ofe1_mid_slope   = 20;
$ofe2_bot_slope   = 10;
$buffer_length    = 30;
$ofe_area         = 100;
$action           = '';
$me               = '';
$units            = '';
$achtung          = '';
$climyears        = 2;
$roaddensity      = 15;

# goto skipper;

########################################

#####  Read user input parameters  #####

my $cgi = new CGI;

my $debug = escapeHTML( scalar $cgi->param('debug') ) || 0;

$wildfire_cycle =
  escapeHTML( scalar $cgi->param('wildfire_cycle') ) + 0;    # 2004.09.16
$rx_fire_cycle =
  escapeHTML( scalar $cgi->param('rx_fire_cycle') ) + 0;     # 2004.09.16
$harvest_cycle =
  escapeHTML( scalar $cgi->param('harvest_cycle') ) + 0;     # 2004.09.16

$CL               = escapeHTML( $cgi->param('Climate') );
$soil             = escapeHTML( $cgi->param('SoilType') );
$hillslope_length = escapeHTML( scalar $cgi->param('totall') ) + 0;
$ofe1_top_slope   = escapeHTML( scalar $cgi->param('ofe1_top_slope') ) + 0;
$ofe1_mid_slope   = escapeHTML( scalar $cgi->param('ofe1_mid_slope') ) + 0;
$ofe2_bot_slope   = escapeHTML( scalar $cgi->param('ofe2_bot_slope') ) + 0;
$buffer_length    = escapeHTML( scalar $cgi->param('buffl') ) + 0;
$ofe_area         = escapeHTML( scalar $cgi->param('ofe_area') ) + 0;
$action =
    escapeHTML( $cgi->param('actionc') )
  . escapeHTML( $cgi->param('actionv') )
  . escapeHTML( $cgi->param('actionw') )
  . escapeHTML( $cgi->param('ActionCD') );
$me          = escapeHTML( $cgi->param('me') );
$units       = escapeHTML( $cgi->param('units') );
$achtung     = escapeHTML( $cgi->param('achtung') );
$climyears   = escapeHTML( $cgi->param('climyears') );
$roaddensity = escapeHTML( $cgi->param('road_density') );

skipper:

my ( $thisyear, $thisweek ) = get_thisyear_and_thisweek();

#####  Set other Disturbed WEPP parameters values  #####

$CLx = $CL;                                        #leave a copy w/o '.cli'

#  $ofe1_top_slope=0; #elena
$ofe2_mid_slope = $ofe1_mid_slope + 0;             #elena

#  $ofe2_bot_slope=$ofe1_mid_slope/2; 	#elena
$ofe1_rock        = 20;                                   #elena
$ofe2_rock        = 20;                                   #elena
$ofe1_length      = $hillslope_length - $buffer_length;
$ofe2_length      = $buffer_length;
$user_ofe1_length = $ofe1_length;                         #elena
$user_ofe2_length = $ofe2_length;                         #elena

if    ( $units eq 'm' )  { $areaunits = 'ha' }                       #kova
elsif ( $units eq 'ft' ) { $areaunits = 'ac' }                       #kova
else                     { $units     = 'ft'; $areaunits = 'ac' }    #kova

############################ start 2010.01.20 DEH

$user_ID     = $ENV{'REMOTE_ADDR'};
$user_really = $ENV{'HTTP_X_FORWARDED_FOR'};              # DEH 11/14/2003
$user_ID     = $user_really if ( $user_really ne '' );    # DEH 11/14/2003
$user_ID =~ tr/./_/;
$user_ID    = $user_ID . $me;
$runLogFile = "../working/" . $user_ID . ".run.log";

############################ end 2010.01.20 DEH

# initialization for inputs array
@runheadd = (
    'Undisturbed forest',
    'Ground harvest',
    'Prescribed burn',
    'Wildfire',
    'Cable harvest',
    'Higher Rx fire',
    'Lower Rx fire',
    'Moderate wildfire',
    'Low wildfire'
);
@intreat1 =
  ( 'tree20', 'tree5', 'low', 'high', 'tree5', 'low', 'low', 'low', 'low' );
@intreat2 = (
    'tree20', 'tree20', 'tree20', 'high', 'tree20', 'low',
    'tree20', 'low',    'low'
);
@inofe1_pcover = ( 100, 90,  85,  30, 95,  75, 90,  50, 70 );   # 2004.11.19 DEH
@inofe2_pcover = ( 100, 100, 100, 40, 100, 85, 100, 60, 80 );   # 2004.11.19 DEH

$fume = "/cgi-bin/fswepp/wd/fume.pl";                           #elena

if ( lc($action) =~ /custom/ ) {
    $fume = "/cgi-bin/fswepp/biomass/biomass.pl";
    exec "../rc/rockclim.pl -server -i$me -u$units $fume";
    die;
}                                                               # /custom/

if ( lc($action) ne 'run wepp biomass' && lc($achtung) =~ /describe climate/ )
{    # 2004.11.19 DEH
    $weppdiro = "/Scripts/fswepp/wd/weppdiro.pl";
    $fume     = "/cgi-bin/fswepp/biomass/biomass.pl";
    exec "../rc/descpar.pl $CL $units $fume";
    die;
}    # /describe climate/

# *******************************

if ( lc($achtung) =~ /describe soil/ ) {    ##########

}                                           #  /describe soil/

# *******************************

# ########### RUN WEPP ###########

print "Content-type: text/html\n\n";

$years2sim = $climyears;
if ( $years2sim > 100 ) { $years2sim = 100 }

$unique = 'wepp-' . $$;

##  File paths ##

$unique       = 'wepp' . '-' . $$;
$working      = '../working';
$responseFile = "$working/$unique" . '.in';
$outputFile   = "$working/$unique" . '.out';
$soilFile     = "$working/$unique" . '.sol';
$slopeFile    = "$working/$unique" . '.slp';
$cropFile     = "$working/$unique" . '.crp';
$stoutFile    = "$working/$unique" . ".stout";
$sterFile     = "$working/$unique" . ".sterr";
$manFile      = "$working/$unique" . ".man";
$soilPath     = 'dat/';
$manPath      = 'dat/';
$newSoilFile  = "$working/" . $unique . '.sol';    # WEPP:Road
$tempFile     = "$working/$unique" . ".temp";      # 2004.09.15  # 2015.05.27

# make hash of treatments

$treatments         = {};
$treatments{skid}   = 'skid trail';
$treatments{high}   = 'high severity fire';
$treatments{low}    = 'low severity fire';
$treatments{short}  = 'short prairie grass';
$treatments{tall}   = 'tall prairie grass';
$treatments{shrub}  = 'shrubs';
$treatments{tree5}  = '5 year old trees';
$treatments{tree20} = '20 year old trees';

# make hash of soil types

$soil_type       = {};
$soil_type{sand} = 'sandy loam';
$soil_type{silt} = 'silt loam';
$soil_type{clay} = 'clay loam';
$soil_type{loam} = 'loam';

#   print "Content-type: text/html\n\n";
$climatePar = $CL . '.par';

#   print "<p>the value of climatePar is $climatePar";
open PAR, "<$climatePar";
$climatename1 = <PAR>;

#   print "<p>this is climatename1 $climatename1 ";
$climatename = substr( $climatename1, 1, length($climatename1) - 10 );
close PAR;

print <<'end0';
<HTML>
 <HEAD>
  <TITLE>BIOMASS Results</TITLE>
  <script language="Javascript">

   function popuppulvroad() {
     url = '/fswepp/biomass/pulvroad.html';
     height=450;
     width=600;
     popupwindow = window.open(url,'popupwindow','toolbar=no,location=no,status=no,directories=no,menubar=no,scrollbars=yes,resizable=yes,width='+width+',height='+height);
     popupwindow.document.close();
     popupwindow.focus()
   }
  </script>
 </HEAD>

end0


print '
 <BODY link="#555555" vlink="#555555">
  <font face="trebuchet, tahoma, Arial, Geneva, Helvetica">
   <blockquote> 
    <table width=100% border=0>
     <tr>
      <td>
       <a href="JavaScript:window.history.go(-1)"
         onMouseOver="window.status=\'Return to WEPP:BIOMASS input screen\'; return true"
         onMouseOut="window.status=\' \'; return true">
        <img src="/fswepp/images/fume.jpg"
          align=left border=1
          width=50 height=50
          alt="Return to WEPP:BIOMASS input screen">
       </a> 
      </td>
      <td align=center>
       <hr>
       <h3>WEPP <font color="green">BIOMASS</font><br>
           <font color="green">Biomass</font> Utilization Impacts on Soil Erosion Results</h3>
       <hr>
      <td>
       <a href="https://www.fs.fed.us/rm/pubs_other/rmrs_2010_elliot_w001.pdf" target="docs">
       <img src="/fswepp/images/epage.gif" align="right" title="Effects of Forest Biomass Use on Watershed Processes in the Western United States [pdf]" border=0></a>
      </td>
     </tr>
    </table>
';

# 2005.04.28 DEH

$sup       = '';
$grad_warn = '';
if ( $ofe1_top_slope > 50 || $ofe1_mid_slope > 50 || $ofe2_bot_slope > 50 ) {
    $sup = '<font color=red><sup>*</sup></font>';
    $grad_warn =
'<font color=red size=-1><sup>*</sup> Hillslopes with greater than 50% gradient may be prone to mass failure.</font>';
}

# 2005.04.28 DEH

print "   
   <center>
    <table border=0 bgcolor='lightyellow'>
     <tr>
      <th bgcolor='#85d2d2'>
       <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
        Climate
       </th>
      <td colspan=3 valign='top'>
       <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
        <b>$climatename</b><br>
        <font size=1>
";
print &GetParSummary($climatePar, $units);
print "
        </font>
      </td>
     </tr>
     <tr>
      <th bgcolor='#85d2d2'>
       <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
        Soil texture
       </font>
      </th>
      <td align='right'>
       <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
        $soil_type{$soil}
       </font>
      </td>
     </tr>
     <tr>
      <th bgcolor='#85d2d2'>
       <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
        Hillslope length
      </th>
      <td align='right'>
       <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
        $hillslope_length
      </td>
      <td>
       <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
        ft
       </font>
      </td>
     </tr>
     <tr>
      <th bgcolor='#85d2d2'>
       <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
        Hillslope gradient
      </th>
      <td align='right'>
       <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
        $ofe1_top_slope $ofe1_mid_slope $ofe2_bot_slope
      </td>
      <td>
       <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
        % $sup
       </font>
      </td>
     </tr>
     <tr>
      <th bgcolor='#85d2d2'>
       <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
        Buffer length
      </th>
      <td align='right'>
       <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
        $ofe2_length
      </td>
      <td>
       <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
        ft
       </font>
      </td>
     </tr>
     <tr>
      <th bgcolor='#85d2d2'>
       <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
        Wildfire cycle
      </th>
      <td align='right'>
       <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
        $wildfire_cycle
      </td>
      <td>
       <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
        y
       </font>
      </td>
     </tr>
     <tr>
      <th bgcolor='#85d2d2'>
       <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
        Prescribed fire cycle
      </th>
      <td align='right'>
       <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
        $rx_fire_cycle
      </td>
      <td>
       <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
        y
       </font>
      </td>
     </tr>
     <tr>
      <th bgcolor='#85d2d2'>
       <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
        Harvesting cycle
      </th>
      <td align='right'>
       <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
        $harvest_cycle
      </td>
      <td>
       <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
        y
       </font>
      </td>
     </tr>
     <tr>
      <th bgcolor='#85d2d2'>
       <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
        Road density
       </font>
      </th>
      <td align='right'>
       <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
        $roaddensity
       </font>
      </td>
      <td>
       <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
        mi mi<sup>-2</sup>
       </font>
      </td>
     </tr>
     <tr>
      <td colspan=2>$grad_warn
      </td>
     </tr>
    </table>
   </center>

";

$host = $ENV{REMOTE_HOST};

#######################  do DISTURBED WEPP runs #########################

print "   <font size=-2><br>Running <b>Disturbed WEPP</b> for </font>\n";

open TEMP, ">$tempFile";    # 2004.09.15
print TEMP '
   <br>
   <center><h4>Details of Inputs and Outputs</h4></center>
   <font size=-1>
    Refer to the <a href="/fswepp/docs/fume/WEPP_FuME.pdf" target="docs">documentation</a> for details on the applications for the five
    additional runs listed in this table, but not used in the initial
    analyses.
    <center>
     <h5>Inputs (blue) and results (green) for individual Disturbed WEPP runs</h5>
    </center>
    <table width=100% border=0>
     <tr>
      <th bgcolor="lightgreen" colspan=14>
       <font face="tahoma" size=1>
        <a href="/cgi-bin/fswepp/wd/weppdist.pl?units=ft" target="wd">Disturbed WEPP</a>
       </font>
      </th>
     </tr>
     <tr>
      <th bgcolor="lightgreen"><font face="tahoma" size=1>Upper element treatment</font></th>
      <th bgcolor="lightgreen"><font face="tahoma" size=1>Lower element treatment</font></th>
      <th bgcolor="lightgreen"><font face="tahoma" size=1>Upper cover<br>(%)</font></th>
      <th bgcolor="lightgreen"><font face="tahoma" size=1>Lower cover<br>(%)</font></th>
      <th bgcolor="lightgreen"><font face="tahoma" size=1>Upper length<br>(ft)</font></th>
      <th bgcolor="lightgreen"><font face="tahoma" size=1>Lower length<br>(ft)</font></th>
      <th bgcolor="lightgreen"><font face="tahoma" size=1>Upper rock<br>(%)</font></th>
      <th bgcolor="lightgreen"><font face="tahoma" size=1>Lower rock<br>(%)</font></th>
      <th bgcolor="lightgreen"><font face="tahoma" size=1>Upper top gradient<br>(%)</font></th>
      <th bgcolor="lightgreen"><font face="tahoma" size=1>Upper mid gradient<br>(%)</font></th>
      <th bgcolor="lightgreen"><font face="tahoma" size=1>Lower mid gradient<br>(%)</font></th>
      <th bgcolor="lightgreen"><font face="tahoma" size=1>Lower toe gradient<br>(%)</font></th>
      <th bgcolor="lightgreen"><font face="tahoma" size=1><a href="/fswepp/fume/equations.html" target="doc">Sediment yield</a><br>(t mi<sup>-2</sup>)</font></th>
      <th bgcolor="lightgreen"><font face="tahoma" size=1>Condition</font></th>
     </tr>
';

( $climateFile, $climatePar ) =
  &CreateCligenFile( $CL, $unique, $years2sim, $debug );

########################### new loop #############################

# for($i = 0; $i < 4; $i++){
for ( $i = 0 ; $i < $#intreat1 + 1 ; $i++ ) {    # 2004.11.19 DEH

    $treat1      = $intreat1[$i];
    $treat2      = $intreat2[$i];
    $ofe1_pcover = $inofe1_pcover[$i];
    $ofe2_pcover = $inofe2_pcover[$i];
    $ofe1_length = $user_ofe1_length;
    $ofe2_length = $user_ofe2_length;

    print "   <font size=-2> $runheadd[$i] ... </font> ";

    print TEMP "
    <tr>
     <td bgcolor='lightblue'>
      <font face='tahoma' size=1>$treatments{$treat1}</font>
     </td>
     <td bgcolor='lightblue'>
      <font face='tahoma' size=1>$treatments{$treat2}</font>
     </td>
     <td bgcolor='lightblue' align='right'>
      <font face='tahoma' size=1>$ofe1_pcover</font>
     </td>
     <td bgcolor='lightblue' align='right'>
      <font face='tahoma' size=1>$ofe2_pcover</font>
     </td>
     <td bgcolor='lightblue' align='right'>
      <font face='tahoma' size=1>$ofe1_length</font>
     </td>
     <td bgcolor='lightblue' align='right'>
      <font face='tahoma' size=1>$ofe2_length</font>
     </td>
     <td bgcolor='lightblue' align='right'>
      <font face='tahoma' size=1>$ofe1_rock</font>
     </td>
     <td bgcolor='lightblue' align='right'>
      <font face='tahoma' size=1>$ofe2_rock</font>
     </td>
     <td bgcolor='lightblue' align='right'>
      <font face='tahoma' size=1>$ofe1_top_slope</font>
     </td>
     <td bgcolor='lightblue' align='right'>
      <font face='tahoma' size=1>$ofe1_mid_slope</font>
     </td>
     <td bgcolor='lightblue' align='right'>
      <font face='tahoma' size=1>$ofe2_mid_slope</font>
     </td>
     <td bgcolor='lightblue' align='right'>
      <font face='tahoma' size=1>$ofe2_bot_slope</font>
     </td>
";

    #   $rcin = &checkInput;
    if ( &checkInput >= 0 ) {

        if ( $units eq 'm' ) {
            $user_ofe1_length = $ofe1_length;
            $user_ofe2_length = $ofe2_length;
            $user_ofe_area    = $ofe_area;
        }
        if ( $units eq 'ft' ) {
            $user_ofe1_length = $ofe1_length;
            $user_ofe2_length = $ofe2_length;
            $user_ofe_area    = $ofe_area;
            $ofe1_length      = $ofe1_length / 3.28084;    # 3.28084 ft == 1 m

            #       print "<p>the value of ofe1_length is $ofe1_length";#elena
            $ofe2_length = $ofe2_length / 3.28;            # 3.28 ft == 1 m
            $ofe_area    = $ofe_area /
              2.47;    # 2.47 ac == 1 ha; Schwab Fangmeier Elliot Frevert
        }

        $ofe_width = $ofe_area * 10000 / ( $ofe1_length + $ofe2_length );

        &CreateSlopeFile(
            $ofe1_top_slope, $ofe1_mid_slope, $ofe2_mid_slope,
            $ofe2_bot_slope, $ofe1_length,    $ofe2_length,
            $ofe_area,       $slopeFile,      $ofe_width,
            $debug
        );

        if ( $debug > 1 ) { print "Creating Management File<br>\n" }
        &CreateManagementFile;

        my $soil_db_file = '/var/www/cgi-bin/fswepp/biomass/dat/soilbase.yaml';
        CreateSoilFile(
            "97.3",    $soil,         $treat1,
            $treat2,   $ofe1_rock,    $ofe2_rock,
            $soilFile, $soil_db_file, $debug
        );
        if ( $debug > 1 ) { print "Creating WEPP Response File<br>\n" }
        &CreateResponseFile;

        @args = ("../wepp2010 <$responseFile >$stoutFile 2>$sterFile");
        system @args;

        #------------------------------

        # 2004.11.30 DEH
        $storms     = '';
        $rainevents = '';
        $snowevents = '';
        $precip     = '';
        $rro        = '';
        $sro        = '';
        $syr        = '';
        $syp        = '';
        $effrdlen   = '';
        $syra       = '';
        $sypa       = '';

        # 2004.11.30 DEH

        open weppstout, "<$stoutFile";

        $found = 0;
        while (<weppstout>) {
            if (/SUCCESSFUL/) {
                $found = 1;
                last;
            }
        }
        close(weppstout);

        if ( $found == 0 ) {
            open weppstout, "<$stoutFile";
            while (<weppstout>) {
                if (/ERROR/) {
                    $found = 2;
                    print "<font color=red>";
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
                    print "<font color=red>";
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
                    print "<font color=red>";
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
                    $weppver = $_;
                    last;
                }
            }

            # ############# actual climate station name #####################

            while (<weppout>) {    ######## actual ########
                if (/CLIMATE/) {
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
                    $_ = <weppout>;    #      -------- --- ------ -------
                    $_ = <weppout>;    #
                    $_ = <weppout>;    #       total summary:  years    1 -    1
                    $simyears = substr $_, 35, 10;
                    chomp $simyears;
                    $simyears += 0;
                    $_ = <weppout>;    #
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
                    $_   = <weppout>;
                    $_   = <weppout>;
                    $_   = <weppout>;
                    $_   = <weppout>;
                    $_   = <weppout>;
                    $_   = <weppout>;               # print;
                    $_   = <weppout>;               # print;
                    $_   = <weppout>;               # print;
                    $_   = <weppout>;               # print;
                    $_   = <weppout>;
                    $syr = substr $_, 17, 7;

                    # print "syr $syr  ; $slope_length  ";
                    $effrdlen = substr $_, 9, 9;    # print;
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

             #          if ($syp eq "") {$syp = substr $_,10,9}	# 2005.09.12 DEH
                    if ( $syp eq "" ) {
                        $syp = substr $_, 1, 18;
                    }    # 2005.09.12 DEH; could change to regular pattern match
                         # eg if (/*([0-9]+)/) {$syp = $1}
                    $_ = <weppout>;
                    $_ = <weppout>;
                    last;
                }
            }
            close(weppout);

            #-----------------------------------

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
            if ( $units eq 'ft' ) {
                $user_ofe_width = $ofe_width * 3.28    # 1 m = 3.28 ft
            }
            $rofe_width   = sprintf "%.2f", $user_ofe_width;
            $slope_length = $ofe1_length + $ofe2_length;
            $asyra        = $syra * 10;                    # kg.m^2 * 10 = t/ha

#      $asypa = sprintf "%.2f", $sypa * $ofe_width / (100000 * $ofe_area);  # kg/m width * m width * (1 t / 1000 kg) / area-in-ha
            $asypa     = sprintf "%.2f", $sypa * 10 / $slope_length;
            $areaunits = 'ha' if $units eq 'm';
            $areaunits = 'ac' if $units eq 'ft';

            #elenaprint "<p> asypa is $asypa";
            #elenaprint "<p> areaunits is $areaunits";

            if ( $units eq 'm' ) {
                $user_precip   = sprintf "%.1f", $precip;
                $user_rro      = sprintf "%.1f", $rro;
                $user_sro      = sprintf "%.1f", $sro;
                $user_asyra    = sprintf "%.2f", $asyra;
                $user_asypa    = sprintf "%.2f", $asypa;
                $out_asypa[$i] = $user_asypa;

                $rate     = 't ha<sup>-1</sup>';
                $pcp_unit = 'mm';
            }
            if ( $units eq 'ft' ) {
                $user_precip = sprintf "%.2f", $precip * 0.0394;  # mm to in
                $user_rro    = sprintf "%.2f", $rro * 0.0394;     # mm to in
                $user_sro    = sprintf "%.2f", $sro * 0.0394;     # mm to in
                $user_asyra  = sprintf "%.2f", $asyra * 0.445;    # t/ha to t/ac
                $user_asypa  = sprintf "%.2f", $asypa * 0.445;    # t/ha to t/ac

                $out_asypa[$i] = $user_asypa;

                $rate     = 't ac<sup>-1</sup>';
                $pcp_unit = 'in.';
            }

            &parsead;

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
                      $rcf;    # kg.m^2 * 10 = t/ha * 0.445 = t/ac

                    $asyp = sprintf "%.2f",
                      $sed_del[ $rp_year - 1 ] * 10 / $slope_length * $rcf;

                    $ii += 1;
                }
            }
            $user_avg_pcp = sprintf "%.2f", $avg_pcp * $dcf;
            $user_avg_ro  = sprintf "%.2f", $avg_ro * $dcf;
            $user_asyra   = sprintf "%.2f", $asyra * $rcf;
            $user_asypa   = sprintf "%.2f", $asypa * $rcf;

            $base_size        = 100;
            $prob_no_pcp      = sprintf "%.2f", $nzpcp / $simyears;
            $prob_no_runoff   = sprintf "%.2f", $nzra / $simyears;
            $prob_no_erosion  = sprintf "%.2f", $nzdetach / $simyears;
            $prob_no_sediment = sprintf "%.2f", $nzsed_del / $simyears;

            # print "<hr width=50%> \n";

        }    # $found == 1
        else {    #  $found == 1
            print
"<p><font color=red>Something seems to have gone awry!</font>\n<p><hr><p>\n";
        }         # $found == 1
    }    # &checkInput
    else {
        print " checkInput failed";
    }

    #  system "rm working/$unique.*";

    #   unlink <$working/$unique.*>;

    $host        = $ENV{REMOTE_HOST};
    $host        = $ENV{REMOTE_ADDR} if ( $host eq '' );
    $user_really = $ENV{'HTTP_X_FORWARDED_FOR'};
    $host        = $user_really if ( $user_really ne '' );

    $z_out_asypa   = @out_asypa[$i] * 640;
    $slope_lengthf = sprintf "%.1f", $slope_length;

    $NUMBERS .= "<br><br>
    <b>$runheadd[$i]</b>
    <br>
    $z_out_asypa t mi<sup>-2</sup> y<sup>-1</sup> =
   <a title='from WEPP'>$syp</a> kg m<sup>-1</sup> y<sup>-1</sup> *
   <a title='unit conversion'>10</a> (kg m<sup>-1</sup> -&gt; t ha<sup>-1</sup>) *
   <a title='unit conversion'>0.445</a> (t ha<sup>-1</sup> -&gt; t a<sup>-1</sup>) *
   <a title='unit conversion'>640</a> a mi<sup>-1</sup> *
   <a title='slope length'>$slope_lengthf</a> m length
";

    print TEMP "
     <td bgcolor='lightgreen' align='right'>
      <font face='tahoma' size=1>
       <a title='$syp kg/y/m width, $slope_lengthf m slope length'>$z_out_asypa</a><br>
      </font>
     </td>
     <td bgcolor='lightblue'>
      <font face='tahoma' size=1>
       <a href=\"javascript:document.forms[$i].submit()\">
       <b>$runheadd[$i]</b></a>
      </font>

<!-- ============== -->
  <!-- form method='post' action='/cgi-bin/fswepp/wdbio/wd.pl' -->
  <form method='post' action='/cgi-bin/fswepp/wd/wd.pl'>
   <input type='hidden' name='Climate' value='$CLx'>
   <input type='hidden' name='SoilType' value='$soil'>
   <input type='hidden' name='UpSlopeType' value='$treat1'>
   <input type='hidden' name='ofe1_length' value='$user_ofe1_length'>
   <input type='hidden' name='ofe1_top_slope' value='$ofe1_top_slope'>
   <input type='hidden' name='ofe1_mid_slope' value='$ofe1_mid_slope'>
   <input type='hidden' name='ofe1_pcover' value='$ofe1_pcover'>
   <input type='hidden' name='ofe1_rock' value='$ofe1_rock'>
   <input type='hidden' name='LowSlopeType' value='$treat2'>
   <input type='hidden' name='ofe2_length' value='$user_ofe2_length'>
   <input type='hidden' name='ofe2_top_slope' value='$ofe2_mid_slope'>
   <input type='hidden' name='ofe2_bot_slope' value='$ofe2_bot_slope'>
   <input type='hidden' name='ofe2_pcover' value='$ofe2_pcover'>
   <input type='hidden' name='ofe2_rock' value='$ofe2_rock'>
   <input type='hidden' name='actionc' value=''>
   <input type='hidden' name='me' value='$me'>
   <input type='hidden' name='units' value='ft'>
   <input type='hidden' name='achtung' value=''>
   <input type='hidden' name='climyears' value='$years2sim'>
   <input type='hidden' name='action' value=''>
  </form>
<!-- ============== -->
     </td>
    </tr>
";

}    ################# i loop for Disturbed runs (0 to 3) (plus)

print "<br>\n";

print TEMP '
   </table>
';

# die;

$doroad = 1;
if ( $roaddensity < 0.001 || $roaddensity eq '0' ) {
    $doroad       = 0;
    $no_road_min  = 0;
    $no_road_max  = 0;
    $no_road_low  = 0;
    $no_road_high = 0;
    $tr_road_min  = 0;
    $tr_road_max  = 0;
    $tr_road_low  = 0;
    $tr_road_high = 0;
}

if ($doroad) {

    print "   <font size=-2>Running <b>WEPP:Road</b> for </font> \n";

    # ############# Set up WEPP:Road parameter values  ############
    #ZZ#

    @runheadr  = ( 'No traffic', 'Low traffic', 'High traffic' );
    @insurface = ( 'native',     'native',      'graveled' );       #elena
    @intraffic = ( 'none',       'low',         'high' );           #elena
    @inslope   = ( 'inveg',      'inveg',       'outrut' );         #elena

    #  $ST='silt';        # Soil type (loam, ..., pclay)
    $ST  = $soil;
    $URS = $ofe1_mid_slope / 10;  # User's road gradient (hillslope gradient/10)

    #  $UBS=40;           # User buffer steepness
    $UBS = $ofe2_bot_slope;

    #  $UBL=50;           # User's buffer length
    $UBL = $buffer_length;

    $URL = 300;                   # User road length -- assumed
    $URW = 13;                    # User road width -- assumed
    $UBR = 20;                    # User rock fragment percentage -- assumed

    $UFS = $ofe1_mid_slope *
      2;    # If fill gradient two times hill gradient WJE 04.07.08
    $UFL = $URW;    # Then fill length equals road width WJE 2004.07.08

    print TEMP '
   <br>
   <center>
    <h5>Inputs (blue) and results (green) for individual WEPP:Road runs</h5>
   </center>
   <table width=100% border=0>
    <tr>
     <th bgcolor="lightgreen" colspan=14>
      <font face="tahoma" size=1>
       <a href="/cgi-bin/fswepp/wr/wepproad.pl?units=ft" target="wr">WEPP:Road</a>
      </font>
     </th>
    </tr>
    <tr>
     <th bgcolor="lightgreen">
      <font face="tahoma" size=1>
       Design<br>
      (<a title=\'Insloped road with bare ditch\'>\'ib\'</a>,
       <a title=\'Insloped road with vegetated or rocked ditch\'>\'iv\'</a>,<br>
       <a title=\'Outsloped rutted road\'>\'or\'</a>,
       <a title=\'Outsloped unrutted road\'>\'ou\'</a>)
      </font>
     </th>
     <th bgcolor="lightgreen">
      <font face="tahoma" size=1>
       Road surface<br>
      (<a title=\'Native surface\'>\'n\'</a>,
       <a title=\'Gravel surface\'>\'g\'</a>,
       <a title=\'Paved surface\'>\'p\'</a>)
      </font>
     </th>
     <th bgcolor="lightgreen">
      <font face="tahoma" size=1>
       Traffic level<br>
       (<a title=\'High traffic\'>\'h\'</a>,
        <a title=\'Low traffic\'>\'l\'</a>,
        <a title=\'No traffic\'>\'n\'</a>)
      </font>
     </th>
     <th bgcolor="lightgreen">
      <font face="tahoma" size=1>
       <a title=\'Decimal percent slope of the water flow path along the road surface\'>Road<br>gradient</a><br>(%)
      </font>
     </th>
     <th bgcolor="lightgreen">
      <font face="tahoma" size=1>       Road<br>length<br>(ft)      </font>
     </th>
     <th bgcolor="lightgreen">
      <font face="tahoma" size=1>       Road<br>width<br>(ft)      </font>
     </th>
     <th bgcolor="lightgreen">
      <font face="tahoma" size=1>       Fill<br>gradient<br>(%)      </font>
     </th>
     <th bgcolor="lightgreen">
      <font face="tahoma" size=1>       Fill<br>length<br>(ft)      </font>
     </th>
     <th bgcolor="lightgreen">
      <font face="tahoma" size=1>       Buffer<br>gradient<br>(%)      </font>
     </th>
     <th bgcolor="lightgreen">
      <font face="tahoma" size=1>       Buffer<br>length<br>(ft)      </font>
     </th>
     <th bgcolor="lightgreen">
      <font face="tahoma" size=1>       Rock<br>fragment<br>(%)      </font>
     </th>
     <th bgcolor="lightgreen">
      <font face="tahoma" size=1>
       <a href="/fswepp/fume/equations.html#road" target="doc">Sediment yield<br>from road</a><br>(t mi<sup>-2</sup>y<sup>-1</sup>)
      </font>
     </th>
     <th bgcolor="lightgreen">
      <font face="tahoma" size=1>
       <a href="/fswepp/fume/equations.html#road" target="doc">Sediment yield<br>from buffer</a><br>(t mi<sup>-2</sup> y<sup>-1</sup>)
      </font>
     </th>
     <th bgcolor="lightgreen">
      <font face="tahoma" size=1>Condition</font>
     </th>
    </tr>
';

#####  create unchanging WEPP:Road files  ################

#####  loop through three WEPP:Road runs  ################

    for ( $i = 0 ; $i < 3 ; $i++ ) {

        print "   <font size=-2> $runheadr[$i] ... </font>\n";

#####  Do the WEPP:Road runs  #####

        %wroadout = &wrdt($i);

        #   @outsyraf= @{$wroadout{'sedroad'}};
        #   @outsypaf= @{$wroadout{'sedbuff'}};

        @z_syraf[$i] = sprintf "%.1f", $syra * 0.0088 * $roaddensity;
        @z_sypaf[$i] = sprintf "%.1f", $sypa * 0.0088 * $roaddensity;
        $eff_rdlenf  = sprintf "%.2f", $effective_road_length;

        $NUMBERS .= "<br><br>
  <b>$runheadr[$i]</b><br>
  from road:
    @z_syraf[$i] t mi<sup>-2</sup> y<sup>-1</sup> =
   <a title='from WEPP'>$syr</a> kg m<sup>-2</sup> y<sup>-1</sup> *
   <a title='unit conversion'>2.2046</a> lb kg<sup>-1</sup> *
   <a title='unit conversion'>0.0088</a> *
   <a title='road density'>$roaddensity</a> mi mi<sup>-2</sup> *
   <a title='effective road length'>$eff_rdlenf</a> m effective road length *
   <a title='road width'>$WeppRoadWidth</a> m road width
  <br>
  from buffer:
   @z_sypaf[$i] t mi<sup>-2</sup> y<sup>-1</sup> =
   <a title='from WEPP'>$syp kg m<sup>-1</sup> y<sup>-1</sup> *
   <a title='unit conversion'>2.2046 lb kg<sup>-1</sup> *
   <a title='unit conversion'>0.0088 *
   <a title='road density'>$roaddensity</a> mi mi<sup>-2</sup> *
   <a title='road width'>$WeppRoadWidth</a> m road width
";

        #  $j=$i+4;
        $j = $i + 9
          ; # 2005.03.10 DEH (accomodate added Disturbed WEPP runs in previous table!
        print TEMP "
    <tr>
     <td bgcolor='lightblue'>
      <font face='tahoma' size=1>$design</font>
     </td>
     <td bgcolor='lightblue'>
      <font face='tahoma' size=1>$insurface[$i]</font>
     </td>
     <td bgcolor='lightblue'>
      <font face='tahoma' size=1>$intraffic[$i]</font>
     </td>
     <td bgcolor='lightblue' align='right'>
      <font face='tahoma' size=1>$URS</font>
     </td>
     <td bgcolor='lightblue' align='right'>
      <font face='tahoma' size=1>$URL</font>
     </td>
     <td bgcolor='lightblue' align='right'>
      <font face='tahoma' size=1>$URW</font>
     </td>
     <td bgcolor='lightblue' align='right'>
      <font face='tahoma' size=1>$UFS</font>
     </td>
     <td bgcolor='lightblue' align='right'>
      <font face='tahoma' size=1>$UFL</font>
     </td>
     <td bgcolor='lightblue' align='right'>
      <font face='tahoma' size=1>$UBS</font>
     </td>
     <td bgcolor='lightblue' align='right'>
      <font face='tahoma' size=1>$UBL</font>
     </td>
     <td bgcolor='lightblue' align='right'>
      <font face='tahoma' size=1>$UBR</font>
     </td>
     <td bgcolor='lightgreen' align='right'>
      <font face='tahoma' size=1>
       <a title='$syr kg/y/m2, $WeppRoadWidth m road width'>@z_syraf[$i]</a>
      </font>
     </td>
     <td bgcolor='lightgreen' align='right'>
      <font face='tahoma' size=1>
       <a title='$syp kg/y/m width, $WeppRoadWidth m road width, $eff_rdlenf m effective road length'>@z_sypaf[$i]</a>
      </font>
     </td>
     <td bgcolor='lightblue'>
      <font face='tahoma' size=1>
       <b><a href=\"javascript:document.forms[$j].submit()\">$runheadr[$i]</a></b>
      </font>
<!-- =================== -->
  <form method='post' action='/cgi-bin/fswepp/wr/wr.pl'>
   <input type='hidden' name='me' value='$me'>
   <input type='hidden' name='units' value='ft'>
   <input type='hidden' name='Climate' value='$CLx'>
   <input type='hidden' name='SoilType' value='$soil'>
   <input type='hidden' name='SlopeType' value='@inslope[$i]'>
   <input type='hidden' name='surface' value='@insurface[$i]'>
   <input type='hidden' name='traffic' value='@intraffic[$i]'>
   <input type='hidden' name='RL' value='$URL'>
   <input type='hidden' name='RS' value='$URS'>
   <input type='hidden' name='RW' value='$URW'>
   <input type='hidden' name='FL' value='$UFL'>
   <input type='hidden' name='FS' value='$UFS'>
   <input type='hidden' name='BL' value='$UBL'>
   <input type='hidden' name='BS' value='$UBS'>
   <input type='hidden' name='Rock' value='$UBR'>
   <input type='hidden' name='years' value='$years2sim'>
   <input type='hidden' name='action' value=''>
   <input type='hidden' name='actionc' value=''>
   <input type='hidden' name='achtung' value=''>
  </form>
<!-- =================== -->
     </td>
    </tr>
";
    }

    print TEMP '
   </table>
';

}    #doroad

close TEMP;    # 2004.09.15

######################## DEVELOPMENT ############################
#################################################################

$thinraw    = @out_asypa[1] * 640;
$presraw    = @out_asypa[2] * 640;
$wildraw    = @out_asypa[3] * 640;
$wildmodraw = @out_asypa[7] * 640;

$undisturbe = $out_asypa[0] * 640;
$harvest    = sprintf '%.1f', $thinraw / $harvest_cycle;
$prescribe  = sprintf '%.1f', $presraw / $rx_fire_cycle;
$wildfire   = sprintf '%.1f', $wildraw / $wildfire_cycle;

$notbackground = $undisturbe + $wildfire;
$witbackground = $harvest + $prescribe;
$withbperofnotb =
  sprintf( '%.1f', ( ( 100 * $witbackground ) / $notbackground ) );

$thinback   = $thinraw + $notbackground;
$thinback   = $notbackground + $harvest;
$presback   = $notbackground + $prescribe;
$thinrx     = $notbackground + $witbackground;
$thinbackno = $undisturbe + $harvest;
$presbackno = $undisturbe + $prescribe;
$thinrxno   = $undisturbe + $witbackground;

if ($doroad) {

    $no_road_min =
      &min( ( @z_sypaf[0], @z_syraf[0], @z_sypaf[1], @z_syraf[1] ) );
    $no_road_max =
      &max( ( @z_sypaf[0], @z_syraf[0], @z_sypaf[1], @z_syraf[1] ) );
    $tr_road_min =
      &min( ( @z_sypaf[1], @z_syraf[1], @z_sypaf[2], @z_syraf[2] ) );
    $tr_road_max =
      &max( ( @z_sypaf[1], @z_syraf[1], @z_sypaf[2], @z_syraf[2] ) );

    print @z_sypa[0];
    $no_road_low  = $notbackground + $no_road_min;
    $no_road_high = $notbackground + $no_road_max;

    $no_thin_low1  = $notbackground + $thinning + $no_road_min;
    $no_thin_high1 = $notbackground + $thinning + $no_road_max;

    $tr_road_low   = $thinrx + $tr_road_min;
    $tr_road_high  = $thinrx + $tr_road_max;
    $tr_thin_low   = $thin + $tr_road_min;
    $tr_thin_high  = $thin + $tr_road_max;
    $tr_thin_low1  = $notbackground + $harvest + $tr_road_min;
    $tr_thin_high1 = $notbackground + $harvest + $tr_road_max;
}

# ######################## new table with results #############

if ( $debug > 0 ) {
    print "
  <blockquote>
   <font size=2>$NUMBERS</font>
  </blockquote>
";
}

print "
     <center>
      <h4>Output summary based on $years2sim years of possible weather</h4>

      <table border=1>
       <tr>
	<th bgcolor='lightblue'>
         <font face='Trebuchet, Tahoma, Arial, Geneva, Helvetica'>
          Line
         </font>
	</th>
	<th bgcolor='lightblue'>
         <font face='Trebuchet, Tahoma, Arial, Geneva, Helvetica'>
          <b>Source of sediment</b>
         </font>
	</th>
	<th bgcolor='lightblue'>
         <font face='Trebuchet, Tahoma, Arial, Geneva, Helvetica'>
          <!-- Erosion in year of disturbance --> <!-- DEH 2005.06.29 -->
          Sediment delivery in year of disturbance<br>(ton mi<sup>-2</sup>)
         </font>
	</th>
	<th bgcolor='lightblue'>
         <font face='Trebuchet, Tahoma, Arial, Geneva, Helvetica'>
          Return period of disturbance<br>(y)
         </font>
	</th>
	<th bgcolor='lightblue'>
         <font face='Trebuchet, Tahoma, Arial, Geneva, Helvetica'>
          \"Average\" annual hillslope sedimentation<br>    <!-- DEH 2005.06.29 -->
          (ton mi<sup>-2</sup> y<sup>-1</sup>)
         </font>
	</th>
       </tr>
<!--  UNDISTURBED -->
       <tr>
	<td align='right' bgcolor='#ceffce'>
         <font face='Trebuchet, Tahoma, Arial, Geneva, Helvetica'>
          1
         </font>
	</td>
	<td bgcolor='#ceffce'>
         <font face='Trebuchet, Tahoma, Arial, Geneva, Helvetica'>
          Undisturbed forest
         </font>
	</td>
	<td align='right' bgcolor='#ceffce'>
         <font face='Trebuchet, Tahoma, Arial, Geneva, Helvetica'>
         </font>
	</td>
	<td align='right' bgcolor='#ceffce'>
         <font face='Trebuchet, Tahoma, Arial, Geneva, Helvetica'>
          1
         </font>
	</td>
	<td align='right' bgcolor='#ceffce'>
         <font face='Trebuchet, Tahoma, Arial, Geneva, Helvetica'>
          $undisturbe
         </font>
	</td>
       </tr>
<!--  WILDFIRE -->
       <tr>
	<td align='right' bgcolor='#ffcece'>
         <font face='Trebuchet, Tahoma, Arial, Geneva, Helvetica'>
          2
         </font>
	</td>
	<td bgcolor='#ffcece'>
         <font face='Trebuchet, Tahoma, Arial, Geneva, Helvetica'>
          Wildfire
         </font>
	</td>
	<td align='right' bgcolor='#ffcece'>
         <font face='Trebuchet, Tahoma, Arial, Geneva, Helvetica'>
          $wildraw
         </font>
	</td>
	<td align='right' bgcolor='#ffcece'>
         <font face='Trebuchet, Tahoma, Arial, Geneva, Helvetica'>
          $wildfire_cycle
         </font>
	</td>
	<td align='right' bgcolor='#ffcece'>
         <font face='Trebuchet, Tahoma, Arial, Geneva, Helvetica'>
          $wildfire
         </font>
	</td>
       </tr>
<!--  PRESCRIBED FIRE -->
       <tr>
	<td align='right' bgcolor='#ffcece'>
         <font face='Trebuchet, Tahoma, Arial, Geneva, Helvetica'>
          3
         </font>
	</td>
	<td bgcolor='#ffcece'>
         <font face='Trebuchet, Tahoma, Arial, Geneva, Helvetica'>
          Prescribed fire
         </font>
	</td>
	<td align='right' bgcolor='#ffcece'>
         <font face='Trebuchet, Tahoma, Arial, Geneva, Helvetica'>
          $presraw
         </font>
	</td>
	<td align='right' bgcolor='#ffcece'>
         <font face='Trebuchet, Tahoma, Arial, Geneva, Helvetica'>
          $rx_fire_cycle
         </font>
	</td>
	<td align='right' bgcolor='#ffcece'>
         <font face='Trebuchet, Tahoma, Arial, Geneva, Helvetica'>
          $prescribe
         </font>
	</td>
       </tr>
<!--  HARVESTING OPERATION -->
       <tr>
	<td align='right' bgcolor='#ffffce'>
         <font face='Trebuchet, Tahoma, Arial, Geneva, Helvetica'>
          4
         </font>
	</td>
	<td bgcolor='#ffffce'>
         <font face='Trebuchet, Tahoma, Arial, Geneva, Helvetica'>
          Harvesting
         </font>
	</td>
	<td align='right' bgcolor='#ffffce'>
         <font face='Trebuchet, Tahoma, Arial, Geneva, Helvetica'>
          $thinraw
         </font>
	</td>
	<td align='right' bgcolor='#ffffce'>
         <font face='Trebuchet, Tahoma, Arial, Geneva, Helvetica'>
          $harvest_cycle
         </font>
	</td>
	<td align='right' bgcolor='#ffffce'>
         <font face='Trebuchet, Tahoma, Arial, Geneva, Helvetica'>
          $harvest
         </font>
	</td>
       </tr>
";
if ($doroad) {
    print "
<!--  LOW ACCESS ROADS -->
       <tr>
	<td align='right' bgcolor='#ffce9c'>
         <font face='Trebuchet, Tahoma, Arial, Geneva, Helvetica'>
          5
         </font>
	</td>
	<td bgcolor='#ffce9c'>
         <font face='Trebuchet, Tahoma, Arial, Geneva, Helvetica'>
          Low access roads
         </font>
	</td>
	<td align='right' bgcolor='#ffce9c'>
         <font face='Trebuchet, Tahoma, Arial, Geneva, Helvetica'>
          $no_road_min to $no_road_max
         </font>
	</td>
	<td align='right' bgcolor='#ffce9c'>
         <font face='Trebuchet, Tahoma, Arial, Geneva, Helvetica'>
          1
         </font>
	</td>
	<td align='right' bgcolor='#ffce9c'>
         <font face='Trebuchet, Tahoma, Arial, Geneva, Helvetica'>
          $no_road_min to $no_road_max
         </font>
	</td>
       </tr>
<!--  HIGHACCESS ROADS -->
       <tr>
	<td align='right' bgcolor='#ffce9c'>
         <font face='Trebuchet, Tahoma, Arial, Geneva, Helvetica'>
          6
         </font>
	</td>
	<td bgcolor='#ffce9c'>
         <font face='Trebuchet, Tahoma, Arial, Geneva, Helvetica'>
          High access roads
         </font>
	</td>
	<td align='right' bgcolor='#ffce9c'>
         <font face='Trebuchet, Tahoma, Arial, Geneva, Helvetica'>
          $tr_road_min to $tr_road_max
         </font>
	</td>
	<td align='right' bgcolor='#ffce9c'>
         <font face='Trebuchet, Tahoma, Arial, Geneva, Helvetica'>
          1
         </font>
	</td>
	<td align='right' bgcolor='#ffce9c'>
         <font face='Trebuchet, Tahoma, Arial, Geneva, Helvetica'>
          $tr_road_min to $tr_road_max
         </font>
	</td>
       </tr>
";
}    # if ($doroad)

print "
      </table>
     </center>
";

# @@@@@@@@@@@@@@@@@@@@

$undiwild = $undisturbe + $wildfire;

$thin_over_back    = 'N/A';
$no_low_over_back  = 'N/A';
$no_high_over_back = 'N/A';
##
#  Insert B [line 1543]		Line 1543: Insert the follwing.

$no_thin_low1_over_back  = 'N/A';
$no_thin_high1_over_back = 'N/A';
##
$tr_low_over_back        = 'N/A';
$tr_high_over_back       = 'N/A';
$tr_thin_low_over_back   = 'N/A';
$tr_thin_high_over_back  = 'N/A';
$tr_thin_low1_over_back  = 'N/A';
$tr_thin_high1_over_back = 'N/A';
$rx_over_back            = 'N/A';

$thin_over_back = sprintf '%.0f', 100 * ($harvest) / $undiwild
  if ( $undiwild > 0.001 );
$rx_over_back = sprintf '%.0f', 100 * ($prescribe) / $undiwild
  if ( $undiwild > 0.001 );

$no_low_over_back = sprintf '%.0f',
  100 * ( $no_road_low - $undiwild ) / $undiwild
  if ( $undiwild > 0.001 );
$no_high_over_back = sprintf '%.0f',
  100 * ( $no_road_high - $undiwild ) / $undiwild
  if ( $undiwild > 0.001 );
##
#  Insert C [line 1556]		Line 1556: Insert the following.

$no_thin_low1_over_back = sprintf '%.0f',
  100 * ( $no_thin_low1 - $undiwild ) / $undiwild
  if ( $undiwild > 0.001 );
$no_thin_high1_over_back = sprintf '%.0f',
  100 * ( $no_thin_high1 - $undiwild ) / $undiwild
  if ( $undiwild > 0.001 );
##
$tr_low_over_back = sprintf '%.0f',
  100 * ( $tr_road_low - $undiwild ) / $undiwild
  if ( $undiwild > 0.001 );
$tr_high_over_back = sprintf '%.0f',
  100 * ( $tr_road_high - $undiwild ) / $undiwild
  if ( $undiwild > 0.001 );
$tr_thin_low_over_back = sprintf '%.0f',
  100 * ( $tr_thin_low - $undiwild ) / $undiwild
  if ( $undiwild > 0.001 );
$tr_thin_high_over_back = sprintf '%.0f',
  100 * ( $tr_thin_high - $undiwild ) / $undiwild
  if ( $undiwild > 0.001 );
$tr_thin_low1_over_back = sprintf '%.0f',
  100 * ( $tr_thin_low1 - $undiwild ) / $undiwild
  if ( $undiwild > 0.001 );
$tr_thin_high1_over_back = sprintf '%.0f',
  100 * ( $tr_thin_high1 - $undiwild ) / $undiwild
  if ( $undiwild > 0.001 );

$rx_temp = $notbackground + $prescribe;
$rx_low  = $rx_temp + $no_road_min;
$rx_high = $rx_temp + $no_road_max;

$rx_low_over_back = sprintf '%.0f', 100 * ( $rx_low - $undiwild ) / $undiwild
  if ( $undiwild > 0.001 );
$rx_high_over_back = sprintf '%.0f', 100 * ( $rx_high - $undiwild ) / $undiwild
  if ( $undiwild > 0.001 );

$presraw_over_wildfire_cycle = sprintf '%.2f', $presraw / $wildfire_cycle
  if ( $wildfire_cycle > 0.01 );
$wildmodraw_over_wildfire_cycle = sprintf '%.2f', $wildmodraw / $wildfire_cycle
  if ( $wildfire_cycle > 0.01 );

$rx_temp      = $presraw_over_wildfire_cycle + $thinbackno + $prescribe;
$rx_wild_low  = $rx_temp + $tr_road_min;
$rx_wild_high = $rx_temp + $tr_road_max;

$rx_wild_low_over_back = sprintf '%.0f',
  -100 * ( $rx_wild_low - $undiwild ) / $undiwild
  if ( $undiwild > 0.001 );
$rx_wild_high_over_back = sprintf '%.0f',
  -100 * ( $rx_wild_high - $undiwild ) / $undiwild
  if ( $undiwild > 0.001 );

# @@@@@@@@@@@@@@@@@@@@

print "
    <font size=-1>
    <h4>Summary of Analysis</h4>

    The output summary table presents the predicted sediment yield rates from seven runs with the WEPP model.
    The outputs from those runs were converted to common units of ton mi<sup>-2</sup> y<sup>-1</sup>.
    From these runs, several key watershed sedimentation values can be estimated.
    <br><br>

    <b><em>Background sedimentation.</em></b>
    The background sedimentation rate -- the rate that will occur with no action --
    can be estimated either with or without roads.
    In the absence of roads, the background sedimentation rate is erosion from undisturbed forest
    plus erosion from wildfire.
    This value is the sum of lines 1 and 2, or
	<font color=green>
        $undisturbe + $wildfire = $notbackground
	</font>
    ton&nbsp;mi<sup>-2</sup>&nbsp;y<sup>-1</sup>.
    If the existing low access road network is included in the background sediment rate,
    then the background rate will be the sum of lines 1, 2, and 5, or
	<font color=green>
        $notbackground + ($no_road_min to $no_road_max) = $no_road_low to $no_road_high
	</font>
    ton&nbsp;mi<sup>-2</sup>&nbsp;y<sup>-1</sup>,
    depending on what percent of the road network crosses live water during major runoff events.
    <br><br>

    <b><em>Biomass harvest effects.</em></b>
    From the summary table, line 4, biomass harvest will generate
	<font color=green>
        $thinraw
	</font>
    tons of sediment the year following the harvest, and when averaged over the harvesting period of once in
	<font color=green>
        $harvest_cycle
	</font>
    years, will average about
	<font color=green>
        $harvest
	</font>
    ton&nbsp;mi<sup>-2</sup>&nbsp;y<sup>-1</sup>.
    This is
        an increase of about
	<font color=green>
        $thin_over_back					<!-- DEH -->
	</font>
    percent above background without roads. There are several methods of biomass harvest: ground-based (forwarder and skidder)
    and cable harvest. The method selected often depends on site conditions, like slope steepness and road density.
    The effects of different methods can be evaluated in the Disturbed WEPP interface by inputting the average ground cover
    for the site following the harvesting operation.
    <br><br>
    In order to carry out the harvesting operation, however, on fine-textured soils, traffic on the roads will have to be increased
    to the high access level to support the traffic associated with an ongoing biomass harvesting operation in the watershed.
    When soil texture is clay loam, silt loam, or loam, the road will be <a href=\"/fswepp/biomass/pulvroad.html\" target=\"pr\">pulverized</a> and its traffic will be high access level.
    The <a href=\"JavaScript:popuppulvroad()\">pulverized road</a> is dusty when it is dry, and turns to slurry when it is wet.
    When soil texture is sandy loam or the road surface is graveled, the road traffic impact can be considered at the low access level.
    The total sediment yield from the watershed will then be the background value plus that from biomass harvesting
    and from
";
##
#  Replace D start [1640-1664]     Line 1640-1664: Replace the section with the following.
##
#    and from high access roads for a total of
#	<font color=green>
#        $notbackground +
#        $harvest +		<!-- $thinback -->
#        ($tr_road_min to
#        $tr_road_max) =
#        $tr_thin_low1 to
#        $tr_thin_high1
#	</font>
#    ton&nbsp;mi<sup>-2</sup>&nbsp;y<sup>-1</sup>.
#    This is an increase of
#	<font color=green>
#        $tr_thin_low1_over_back to
#        $tr_thin_high1_over_back
# 	</font>
#    percent above the background rate, if roads are not considered in the background, or
#	<font color=green>
#";
#    printf '%.0f', 100*($tr_thin_high1-$no_road_high) / $no_road_high if ($no_road_high > 0.01);
#    print "
#        to
#";
#    printf '%.0f', 100*($tr_thin_low1-$no_road_low) / $no_road_low if ($no_road_low > 0.01);
#    print "
#	</font>
if ( $soil eq 'sandy loam' ) {

    print "
        low access roads for a total of
        <font color=green>
         $notbackground +
         $thinning +  <!-- $thinback -->
         ($no_road_min to
         $no_road_max) =
         $no_thin_low1 to
         $no_thin_high1
        </font>
        ton&nbsp;mi<sup>-2</sup>&nbsp;y<sup>-1</sup>.
        This is an increase of
        <font color=green>
         $no_thin_low1_over_back to
         $no_thin_high1_over_back
        </font>
        percent above the background rate, if roads are not considered in the background, or
        <font color=green>
";
    printf '%.0f', 100 * ( $no_thin_high1 - $no_road_high ) / $no_road_high
      if ( $no_road_high > 0.01 );
    print "
         to
";
    printf '%.0f', 100 * ( $no_thin_low1 - $no_road_low ) / $no_road_low
      if ( $no_road_low > 0.01 );
    print "
       </font>
";
}    # if ($soil eq 'sandy loam') {
else {
    print "
        high access roads for a total of
        <font color=green>
         $notbackground +
         $thinning +  <!-- $thinback -->
         ($tr_road_min to
         $tr_road_max) =
         $tr_thin_low1 to
         $tr_thin_high1
        </font>
        ton&nbsp;mi<sup>-2</sup>&nbsp;y<sup>-1</sup>.
        This is an increase of
        <font color=green>
         $tr_thin_low1_over_back to
         $tr_thin_high1_over_back
        </font>
        percent above the background rate, if roads are not considered in the background, or
        <font color=green>
";
    printf '%.0f', 100 * ( $tr_thin_high1 - $no_road_high ) / $no_road_high
      if ( $no_road_high > 0.01 );
    print "
        to
";
    printf '%.0f', 100 * ( $tr_thin_low1 - $no_road_low ) / $no_road_low
      if ( $no_road_low > 0.01 );
    print "
        </font>
";
}    # if ($soil eq 'sandy loam') {
##
#  Replace D end
##
print "
    percent if the road network is considered in the background rate.
    <br><br>
    Further comparisons can be made by assuming that biomass harvesting will eliminate wildfire from the watershed,
    thus reducing the wildfire sedimentation value,
    or that the harvesting will lead to a less severe wildfire,
    and the moderate or low severity fire sedimentation rate from
    the table below can be substituted for the wildfire erosion rate in line 2.
    <br><br>

    <b><em>Prescribed fire effects.</em></b>
    From the summary table, line 3, prescribed fire will generate
	<font color=green>
        $presraw
	</font>
    ton&nbsp;mi<sup>-2</sup> the year of the prescribed fire, or when averaged over the prescribed fire return period of
	<font color=green>
        $rx_fire_cycle
	</font>
        y, it will generate
	<font color=green>
        $prescribe
	</font>
    ton&nbsp;mi<sup>-2</sup>&nbsp;y<sup>-1</sup>.
    This is
       an increase of
	<font color=green>
        $rx_over_back
	</font>
    percent above background.
    As there will be no need for heavy traffic to carry out the prescribed burn,
    there is no increase in sedimentation from the road network.
    For a watershed with an active prescribed fire program, the total erosion will then be the background rate
    plus the low access road rate and the average erosion from prescribed fire, or
	<font color=green>
        $notbackground +
        $prescribe +
        ($no_road_min to
        $no_road_max) =
        $rx_low to
        $rx_high
	</font>
    tons&nbsp;mi<sup>-2</sup>&nbsp;y<sup>-1</sup>, or
        an increase of
	<font color=green>
        $rx_low_over_back to $rx_high_over_back
	</font>
    percent above background, if roads are not included in the background value.
    <br><br>
    If the prescribed fire eliminates the risk of wildfire, the background erosion rate will need to be set to
	<font color=green>
        $undisturbe
	</font>
    (line 1 of the outputs summary) for the analysis.
    Alternatively, the impact of the prescribed fire program may be to reduce the intensity of the wildfire,
    in which case, the sedimentation associated with
    a moderate or low severity fire from the following table can be substituted for the wildfire prediction
    for the analysis.
    <br><br>

    <b><em>Combined biomass harvest and prescribed fire effects.</em></b>
    The combined effects of biomass harvest and prescribed fire can be determined by summing up the background rate,
    the biomass harvesting rate, the prescribed fire rate, and the
";
##
#  Replace E start [1726-1742]  Line 1726-1742: Replace the section with the following.
##
#    the biomass harvesting rate, the prescribed fire rate, and the high access road rate.
#    In this case, this leads to a total predicted erosion rate of
#	<font color=green>
#         $notbackground +
#         $harvest +
#         $prescribe +
#         ($tr_road_min to
#         $tr_road_max) =
#         $tr_road_low to
#         $tr_road_high
#	</font>
#    ton&nbsp;mi<sup>-2</sup>&nbsp;y<sup>-1</sup>,
#       an increase of
#	<font color=green>
#        $tr_low_over_back to
#        $tr_high_over_back
#	</font>

if ( $soil eq 'sandy loam' ) {

    print "
        low access road rate.
        In this case, this leads to a total predicted erosion rate of
        <font color=green>
         $notbackground +
         $thinning +
         $prescribe +
         ($no_road_min to
         $no_road_max) =
         $no_road_low to
         $no_road_high
        </font>
        ton&nbsp;mi<sup>-2</sup>&nbsp;y<sup>-1</sup>,
        an increase of
        <font color=green>
         $no_low_over_back to
         $no_high_over_back
        </font>
";
}
else {

    print "
    high access road rate.
    In this case, this leads to a total predicted erosion rate of
        <font color=green>
         $notbackground +
         $thinning +
         $prescribe +
         ($tr_road_min to
         $tr_road_max) =
         $tr_road_low to
         $tr_road_high
        </font>
        ton&nbsp;mi<sup>-2</sup>&nbsp;y<sup>-1</sup>,
        an increase of
        <font color=green>
         $tr_low_over_back to
         $tr_high_over_back
        </font>
";
}
##
#  Replace E end
##
print "
    percent
    above
    the background erosion rate without roads.
    <br><br>

    If this intensive fuel management scenario can reduce the severity of wildfire in the watershed,
    then the moderate severity fire sedimentation value of
	<font color=green>
        $wildmodraw
	</font>
    ton&nbsp;mi<sup>-2</sup> can be substituted for the wildfire erosion rate once every
	<font color=green>
        $wildfire_cycle
	</font>
    years to give an average value of
	<font color=green>
        $wildmodraw_over_wildfire_cycle
	</font>
    ton&nbsp;mi<sup>-2</sup>&nbsp;y<sup>-1</sup>.
";
##
#  Replace F start [1763-1773]    Line 1763-1773: Replace the section with the following.
##
#    Using this value to determine the total impact of fuel management gives
#	<font color=green>
#        $wildmodraw_over_wildfire_cycle +
#        $thinbackno +
#        $prescribe +
#        ($tr_road_min to
#        $tr_road_max) =
#	</font>
#	<font color=green>
#";
#    $tempmin=$wildmodraw_over_wildfire_cycle + $thinbackno + $prescribe + $tr_road_min;
#    $tempmax=$wildmodraw_over_wildfire_cycle + $thinbackno + $prescribe + $tr_road_max;

if ( $soil eq 'sandy loam' ) {
    print "
       <font color=green>
        $wildmodraw_over_wildfire_cycle +
        $thinbackno +
        $prescribe +
        ($no_road_min to
        $no_road_max) =
       </font>
       <font color=green>
";
    $tempmin =
      $wildmodraw_over_wildfire_cycle + $thinbackno + $prescribe + $no_road_min;
    $tempmax =
      $wildmodraw_over_wildfire_cycle + $thinbackno + $prescribe + $no_road_max;
}
else {
    print "
       <font color=green>
        $wildmodraw_over_wildfire_cycle +
        $thinbackno +
        $prescribe +
        ($tr_road_min to
        $tr_road_max) =
       </font>
       <font color=green>
";
    $tempmin =
      $wildmodraw_over_wildfire_cycle + $thinbackno + $prescribe + $tr_road_min;
    $tempmax =
      $wildmodraw_over_wildfire_cycle + $thinbackno + $prescribe + $tr_road_max;
}
##
#  Replace F end
##
print "      $tempmin to $tempmax
	</font>
    ton&nbsp;mi<sup>-2</sup>&nbsp;y<sup>-1</sup>,
       a decrease of
	<font color=green>
";
printf '%.0f', -100 * ( $tempmax - $no_road_high ) / $no_road_high
  if ( $no_road_high > 0.01 );
print "     \n    to\n     ";
printf '%.0f', -100 * ( $tempmin - $no_road_low ) / $no_road_low
  if ( $no_road_low > 0.01 );
print "
	</font>
    percent compared to background with roads or
        <font color=green>
";
printf '%.0f', -100 * ( $tempmax - $notbackground ) / $notbackground
  if ( $notbackground > 0.01 );
print "     \n    to\n     ";
printf '%.0f', -100 * ( $tempmin - $notbackground ) / $notbackground
  if ( $notbackground > 0.01 );
print "
        </font>
    percent compared to background without roads.
    <br>
    <br>

    <b><em>Road Impacts.</em></b>
";

if ($doroad) {
    print "
    The range of values given for road sedimentation represent the amount of sediment delivered across the buffer,
    and the amount delivered to a stream crossing.
    Roads with buffers greater than
    <font color='green'>$buffer_length</font> ft will generate less sediment.
       The summary table shows that roads generate significant amounts of sediment within a watershed, even when traffic is low.
    Road management strategies -- including
      minimizing rutting,
      minimizing stream crossings, and
      maximizing the use of buffers between the road and the stream
    --  are well established to minimize sedimentation.
    The WEPP:Road interface can be used to evaluate the impacts of some of these improved practices.
       Another alternative to reduce sedimentation from the road network is to reduce the road density
       within the watershed by removing roads that are no longer needed with modern timber operations.
    Watershed managers may wish to offset the increase in sediment associated with biomass utilization
    with a decrease in sediment from improved road management or a reduction in road density.
      ";
}
else {
    print "
    You have indicated that there are no roads.
      ";
}
print "
    <br><br>
    <b><em>Multiple Hillslopes.</em></b>
    This analysis was for a single hillslope.
    Users are advised to run this simulation for a number of different hillslopes within the watershed,
    and to report a range of sedimentation rates in the output table before completing the analysis.
    Results from each hillslope can be copied and pasted into a word processor or spreadsheet
    to serve as a log for a series of runs.
    <br><br>
    For further information, refer to the documentation.
";

# @@@@@@@@@@@@@@@@@@@@ print 'details of inputs and outputs'

print "    </font>\n    <br>\n";
open TEMP, "<$tempFile";
while (<TEMP>) { print $_}
close TEMP;
print "
  </font>
";

goto skipjunk;

print "
  <center>
   <h3>Mean annual predicted values based on $years2sim years of weather data</h3>
";

print <<"end";

      <table border="1">
       <tr>
	<td align="center" bgcolor="#85d2d2" colspan="2">
         <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
          <b>No Treatment</b>
         </font>
	</td>
	<td align="center" bgcolor="#85d2d2" colspan="2">
         <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
          <b>With Treatment<br>with wildfire</b>
         </font>
	</td>
	<td align="center" bgcolor="#85d2d2" colspan="2">
         <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
          <b>With Treatment<br>no wildfire</b>
         </font>
	</td>
       </tr>
       <tr>
	<th align="center" valign="center" bgcolor="#85d2d2">
         <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
          Source
         </font>
	</th>
	<th align="center" valign="center" bgcolor="#85d2d2">
         <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
          Sediment Yield<br>(t/mi<sup>2</sup>/year)
         </font>
	</th>
	<th align="center" valign="center" bgcolor="#85d2d2">
         <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
          Source
         </font>
	</th>
	<th align="center" valign="center" bgcolor="#85d2d2">
         <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
          Sediment Yield<br>(t/mi<sup>2</sup>/year)
         </font>
	</th>
	<th align="center" valign="center" bgcolor="#85d2d2">
         <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
          Source
         </font>
	</th>
	<th align="center" valign="center" bgcolor="#85d2d2">
         <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
          Sediment Yield<br>(t/mi<sup>2</sup>/year)
         </font>
	</th>
       </tr>
       <tr>
	<td align="center" bgcolor="lightgreen">
         <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
           Undisturbed forest</td>
	<td align="center">
         <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
           $undisturbe
        </td>
	<td align="center" bgcolor="lightgreen">
         <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
          Harvested forest,<br>wildfire
        </td>
	<td align="center">
         <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
          <a
           onMouseOver="window.status='Background + $thinraw/$harvest_cycle yr'"
           onMouseOut="window.status=''">
          $thinback<br>(<font color="green">$notbackground</font>+$thinraw/$harvest_cycle = <font color="green">$notbackground</font>+$harvest)</a>
        </td>
	<td align="center" bgcolor="lightgreen">
         <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
          Harvested forest,<br>no wildfire
        </td>
	<td align="center">
         <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
          <a
           onMouseOver="window.status='Undisturbed + $thinraw/$harvest_cycle yr'"
           onMouseOut="window.status=''">
          $thinbackno<br>(<font color="green">$undisturbe</font>+$thinraw/$harvest_cycle = <font color="green">$undisturbe</font>+$harvest)</a>
        </td>
       </tr>
       <tr>
	<td align="center" bgcolor="lightgreen">
         <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
          <a
           onMouseOver="window.status=''"
           onMouseOut="window.status=''">
            Wildfire</a>
         </font>
        </td>
	<td align="center">
         <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
          <a
           onMouseOver="window.status='$wildraw / $wildfire_cycle yr'"
           onMouseOut="window.status=''">
          $wildfire</a><br>
          ($wildraw/$wildfire_cycle)
        </td>
	<td align="center" bgcolor="lightgreen">
         <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
           Prescribed fire,<br>wildfire
        </td>
	<td align="center">
         <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
          <a
           onMouseOver="window.status=\'\'"
           onMouseOut="window.status=\'\'">
          $presback<br>(<font color=green>$notbackground</font>+$presraw/$rx_fire_cycle = <font color="green">$notbackground</font>+$prescribe)</a>
        </td>
	<td align="center" bgcolor="lightgreen">
         <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
           Prescribed fire,<br>no wildfire
        </td>
	<td align="center">
         <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
          <a
           onMouseOver="window.status=\'\'"
           onMouseOut="window.status=\'\'">
          $presbackno<br>(<font color=green>$undisturbe</font>+$presraw/$rx_fire_cycle = <font color="green">$undisturbe</font>+$prescribe)</a>
        </td>
       </tr>
       <tr>
	<td align="center" bgcolor="lightgreen">
         <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
          <a
           onMouseOver="window.status='Undisturbed + wildfire'"
           onMouseOut="window.status=''">
           Background</a>
        </td>
	<td align="center">
         <font face='trebuchet, tahoma, Arial, Geneva, Helvetica' color='green'>
          $notbackground<br>
         </font>
         ($undisturbe+$wildfire)
        </td>
	<td align="center" bgcolor="lightgreen">
         <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
          Harvested,<br>prescribed fire, wildfire</td>
	<td align="center">
         <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
          <a
           onMouseOver="window.status=\'\'"
           onMouseOut="window.status=\'\'">
            $thinrx<br>
            (<font color="green">$notbackground</font>+$harvest+$prescribe = <font color="green">$notbackground</font>+$witbackground)
         </font>
        </td>
	<td align="center" bgcolor="lightgreen">
         <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
          Harvested,<br>prescribed fire,<br>no wildfire</td>
	<td align="center">
         <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
          <a
           onMouseOver="window.status=\'\'"
           onMouseOut="window.status=\'\'">
            $thinrxno<br>
            (<font color="green">$undisturbe</font>+$harvest+$prescribe = <font color="green">$undisturbe</font>+$witbackground)
         </font>
        </td>
       </tr>
end

if ($doroad) {
    print <<"end";

       <tr>
	<td align="center" bgcolor="lightgreen">
         <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
          Road Network
        </td>
	<td align="center">
         <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
          $no_road_min to $no_road_max<br>
          ($no_road_low to $no_road_high)
        </td>
	<td align="center" bgcolor="lightgreen">
         <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
          Road Network
        </td>
	<td align="center">
         <font face='trebuchet, tahoma, Arial, Geneva, Helvetica'>
          $tr_road_min to $tr_road_max<br>
          ($tr_road_low to $tr_road_high)
        </td>
       </tr>
end
}

print '

      </table>
     </center>
     <br>
     <br>
';

print "
    <h3>Discussion of Results</h3>
    <p>
     <font face='trebuchet, tahoma, arial, helvetica, sans serif'>
      A typical background erosion rate is
      <font color=green>$notbackground</font> 
      t/mi<sup>2</sup>/yr (undisturbed plus wildfire effects).<br><br>
";

if ($doroad) {
    print "
      The road network will add an additional
      $no_road_min $lowntrafficbuffer to
      $tr_road_max $highltrafficroad t/mi<sup>2</sup>/yr,
      depending on the condition of the road and the number of live water
      crossings."
}
else {
    print "
      No road network was specified."
}
print "
      <br><br>
      If fuel management prevents wildfire, then there will be a
      <font color=red>net decrease</font>
      in erosion in the watershed, which may have implications for aquatic
      ecosystems.
      <br><br>";

if ( $witbackground > 0 ) {
    print "
      If the fuel management does not prevent wildfire,
      then there is an <font color=red>increase</font> in sediment delivery of
      $witbackground t/mi<sup>2</sup>/yr, or about
      $withbperofnotb percent, not counting roads.";
}
elsif ( $witbackground < 0 ) {
    print "
      If the fuel management does not prevent wildfire,
      then there is a <font color=red>decrease</font> in sediment delivery of
      $witbackground t/mi<sup>2</sup>/yr, or about
      $withbperofnotb percent, not counting roads.";
}
else {
    print "
      If the fuel management does not prevent wildfire,
      then there is <font color=red>no change</font> in sediment delivery
      (not counting roads).";
}

if ($doroad) {
    if ($highltrafficroad) {    #2004.07.22 DEH ****
        print "
      <br><br>
      There appears to be scope in this watershed to significantly decrease
      sediment from road sources, and a more detailed road analysis
      using the WEPP:Road interface is advised.";
    }
}

skipjunk:
print "  
  </p>

  <hr>
  <font size=-1>
";

print "&gt;                                                            
  <font size=1>
 WEPP BIOMASS v. 
 <a href='javascript:popuphistory()'>$version</a> ($unique)
 <br>Interface by David Hall, Elena Velasquez, and Hakjun Rhee
 <br>Model by Hakjun Rhee, Bill Elliot and Pete Robichaud
 <br>USDA Forest Service, Rocky Mountain Research Station, Moscow, ID 83843<br><br>

 Disturbed WEPP soil database: $soildbcomment<br>";

$wc    = `wc ../working/_$thisyear/wb.log`;
@words = split " ", $wc;
$runs  = @words[0];

print " WEPP $weppver <br>";
print " File frost.exe found <br>" if ( -e 'frost.txt' );

&printdate;

print "
    <br>
    <b>$runs</b> WEPP BIOMASS runs YTD<br>
    <br><br>
    This project was supported by the Agriculture and Food Research Initiative,
    Biomass Research and Development Initiative,
    Competitive Grant no. 2010-05325 from the USDA National Institute of Food and Agriculture.
   </font>
  </font>
 </body>
</html>
";

################################# start 2010.01.20 DEH   record run in user wepp run log file

$climate_trim = trim($climatename);

open RUNLOG, ">>$runLogFile";
flock( RUNLOG, 2 );
print RUNLOG "WB\t$unique\t", '"';
printf RUNLOG "%0.2d:%0.2d ", $hour, $min;
print RUNLOG $ampm[$ampmi], "  ", $days[$wday], " ", $months[$mon], " ", $mday,
  ", ", $year + 1900, '"', "\t", '"';
print RUNLOG $climate_trim, '"', "\t";    # Climate

print RUNLOG "$soil\t";                   # Soil texture
print RUNLOG "$hillslope_length\t";       # Hillslope length
print RUNLOG "$buffer_length\t";          # Buffer length
print RUNLOG "$ofe1_top_slope\t";         # Hillslope gradient top
print RUNLOG "$ofe1_mid_slope\t";         # Hillslope gradient middle
print RUNLOG "$ofe2_bot_slope\t";         # Hillslope gradient bottom
print RUNLOG "$wildfire_cycle\t";         # Wildfire cycle
print RUNLOG "$rx_fire_cycle\t";          # Prescribed fire cycle
print RUNLOG "$harvest_cycle\t";          # Harvesting cycle
print RUNLOG "$roaddensity\t";            # Road density
print RUNLOG "$units\n";                  # units
close RUNLOG;

################################# end 2010.01.20 DEH

# Record run in log

# 2008.06.04 DEH start
open PAR, "<$climatePar";
$PARline  = <PAR>;                       # station name
$PARline  = <PAR>;                       # Lat long
$lat_long = substr( $PARline, 0, 26 );
$lat      = substr $lat_long, 6,  7;
$long     = substr $lat_long, 19, 7;
close PAR;

# 2008.06.04 DEH end

open WBLOG, ">>../working/_$thisyear/wb.log";    # 2012.12.31 DEH
flock WBLOG, 2;                                  # 2005.02.09 DEH
print WBLOG "$host\t\"";
printf WBLOG '%0.2d:%0.2d ', $hour, $min;
print WBLOG $ampm[$ampmi], "  ", $days[$wday], " ", $months[$mon], " ", $mday,
  ", ", $year + 1900, "\"\t";
print WBLOG '"', trim($climate_name), "\"\t";
print WBLOG "$lat\t$long\n";
close WBLOG;

open CLIMLOG, ">../working/_$thisyear/lastclimate.txt";    # 2012.12.31 DEH
flock CLIMLOG, 2;
print CLIMLOG 'BIOMASS: ', $climate_name;
close CLIMLOG;

$ditlogfile = ">>../working/_$thisyear/wb/$thisweek";    # 2012.12.31 DEH
open WBLOG2, $ditlogfile;
flock WBLOG2, 2;                                         # 2005.02.09 DEH

#      binmode WBLOG2;
print WBLOG2 '.';
close WBLOG2;

# }

#   }

unlink $responseFile;    # 2015.05.27 DEH
unlink $outputFile;      # 2015.05.27 DEH
unlink $stoutFile;       # 2015.05.27 DEH
unlink $sterFile;        # 2015.05.27 DEH
unlink $slopeFile;       # 2015.05.27 DEH
unlink $tempFile;        # 2015.05.27 DEH
unlink $solFile;         # 2015.05.27 DEH

# ------------------------ subroutines ---------------------------

sub CreateManagementFile {

    $climatePar = $CL . '.par';
    my $ap_annual_precip = &GetAnnualPrecip($climatePar);

    if ( $debug > 1 ) { print "Annual Precip: $ap_annual_precip mm<br>\n" }

    #  $treat1 = "skid";   $treat2 = "tree5";

    open MANFILE, ">$manFile";

    print MANFILE "97.3
#
#\tCreated for Disturbed WEPP by wd.pl (v. $version)
#\tNumbers by: Bill Elliot (USFS) et alia
#

2\t# number of OFEs
$years2sim\t# (total) years in simulation

#################
# Plant Section #
#################

2\t# looper; number of Plant scenarios

";

    #   print "<p>the value of treat1.wps is: $treat1.wps <br>";  #elena
    open PS1, "<dat/$treat1.wps";    # WEPP plant scenario

   #   open PS1, "<c:\\Inetpub\\Scripts\\fswepp\\wd\\data\\$treat1.wps"; #elena
   #  read 14 lines (base 0); line 9 entry 2 will change (biomass) as f(climate)

#  $beinp is biomass energy ratio (real ~ 0 to 1000): plant scenario 7.3 (p. 33)
#  the following equation relates biomass ratio to cover (whole) percent and precipitation in mm
#  from work December 1999 by W.J. Elliot unpublished.

    #   ($ofe1_pcover > 100) ? $pcover = 100 : $pcover = $ofe1_pcover;
    $pcover = $ofe1_pcover
      ; # decided not to limit input cover to 100%; use whatever is entered (for now)
    $precip_cap =
      450;  # max precip in mm to put into biomass equation (curve flattens out)
    ( $ap_annual_precip < $precip_cap )
      ? $capped_precip = $ap_annual_precip
      : $capped_precip = $precip_cap;

#   $beinp = sprintf "%.1f", 8.17 * exp(0.031 * $pcover - 0.0023 * $capped_precip);
    $beinp = sprintf "%.1f",
      0.0 * exp( 0.031 * $pcover - 0.0023 * $capped_precip );    #elena

    #   $beinp = 0.1 #elena
    #   print "<p> this is beinp: $beinp <br>"; #elena
    while (<PS1>) {
        if (/beinp/) {    # read file search for token to replace with value
            $index_beinp = index( $_, 'beinp' );    # where does token start?
            $wps_left =
              substr( $_, 0, $index_beinp );    # grab stuff to left of token
            $wps_right =
              substr( $_, $index_beinp + 5 ); # grab stuff to right of token end
            $_ =
                $wps_left
              . $beinp
              . $wps_right;    # stuff value inbetween the two ends
            if ( $debug > 1 ) {
                print "<b>wps1:</b><br>
                           pcover: $pcover<br>
                           beinp: $beinp<br><pre> $_<br>\n";
            }
        }
        print MANFILE $_;    # print line to management file
    }
    close PS1;

    #   print "<p>the value of treat2.wps is: $treat2.wps <br>";  #elena
    open PS2, "<dat/$treat2.wps";

   #   open PS2, "<c:\\Inetpub\\Scripts\\fswepp\\wd\\data\\$treat2.wps"; #elena
   #  read 14 lines (base 0); line 9 entry 2 will change (biomass) as f(climate)

    #   ($ofe2_pcover > 100)? $pcover = 100 : $pcover = $ofe2_pcover;
    $pcover = $ofe2_pcover;
    ( $ap_annual_precip < $precip_cap )
      ? $capped_precip = $ap_annual_precip
      : $capped_precip = $precip_cap;

#   $beinp = sprintf "%.1f", 8.17 * exp(0.031 * $pcover - 0.0023 * $capped_precip);;
    $beinp = sprintf "%.1f",
      0.00 * exp( 0.031 * $pcover - 0.0023 * $capped_precip );
    ;    #elena

    #   $beinp = 0.0 #elena
    while (<PS2>) {
        if (/beinp/) {
            $index_beinp = index( $_, 'beinp' );
            $wps_left    = substr( $_, 0, $index_beinp );
            $wps_right   = substr( $_, $index_beinp + 5 );
            $_           = $wps_left . $beinp . $wps_right;
            if ( $debug > 2 ) {
                print "</pre><b>wps2:</b><br>
                           pcover: $pcover<br>
                           beinp: $beinp<br><pre> $_<br>\n";
            }
        }
        print MANFILE $_;
    }
    close PS2;

    print MANFILE "#####################
# Operation Section #
#####################

0\t# looper; number of Operation scenarios

##############################
# Initial Conditions Section #
##############################

2\t# looper; number of Initial Conditions scenarios

";

#  $inrcov is initial interrill cover (real 0-1): initial conditions 6.6 (p. 37)
#  $rilcov is initial rill cover (real 0-1): initial conditions 9.3 (p. 37)
#  December 1999 by W.J. Elliot unpublished.

    ( $ofe1_pcover > 100 ) ? $pcover = 100 : $pcover = $ofe1_pcover;
    $inrcov = sprintf "%.2f", $pcover / 100;
    $rilcov = $inrcov;

    #   print "<p>the value of treat1.ics is: $treat1.ics <br>";  #elena
    open IC, "<dat/$treat1.ics";    # Initial Conditions Scenario file

    #   open IC, "<c:\\Inetpub\\Scripts\\fswepp\\wd\\data\\$treat1.ics"; #elena
    #  read 14 lines (base 0); change line 8 values 1 and 5; line 11 value 2

    while (<IC>) {
        if (/iresd/) { substr( $_, 0, 1 ) = "1" }
        if (/inrcov/) {
            $index_pos = index( $_, 'inrcov' );
            $ics_left  = substr( $_, 0, $index_pos );
            $ics_right = substr( $_, $index_pos + 6 );
            $_         = $ics_left . $inrcov . $ics_right;
            if ( $debug > 1 ) { print "<b>ics1:</b><br>$_<br>\n" }
        }
        if (/rilcov/) {
            $index_pos = index( $_, 'rilcov' );
            $ics_left  = substr( $_, 0, $index_pos );
            $ics_right = substr( $_, $index_pos + 6 );
            $_         = $ics_left . $rilcov . $ics_right;
            if ( $debug > 1 ) { print "$_<br>\n" }
        }
        print MANFILE $_;
    }
    close IC;

    ( $ofe2_pcover > 100 ) ? $pcover = 100 : $pcover = $ofe2_pcover;
    $inrcov = sprintf "%.2f", $pcover / 100;
    $rilcov = $inrcov;

    #   print "<p>the value of treat2.ics is: $treat2.ics <br>";  #elena
    open IC, "<dat/$treat2.ics";

    #   open IC, "<c:\\Inetpub\\Scripts\\fswepp\\wd\\data\\$treat2.ics"; #elena
    #  read 14 lines (base 0); change line 8 values 1 and 5; line 11 value 2
    while (<IC>) {
        if (/iresd/) { substr( $_, 0, 1 ) = "2" }
        if (/inrcov/) {
            $index_pos = index( $_, 'inrcov' );
            $ics_left  = substr( $_, 0, $index_pos );
            $ics_right = substr( $_, $index_pos + 6 );
            $_         = $ics_left . $inrcov . $ics_right;
            if ( $debug > 1 ) { print "<b>ics2:</b><br>$_<br>\n" }
        }
        if (/rilcov/) {
            $index_pos = index( $_, 'rilcov' );
            $ics_left  = substr( $_, 0, $index_pos );
            $ics_right = substr( $_, $index_pos + 6 );
            $_         = $ics_left . $rilcov . $ics_right;
            if ( $debug > 1 ) { print "$_</pre><br>\n" }
        }
        print MANFILE $_;
    }
    close IC;

    print MANFILE "###########################
# Surface Effects Section #
###########################

0\t# looper; number of Surface Effects scenarios

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

2\t# looper; number of Yearly scenarios

";

    #   print "<p>the value of treat1.ys is: $treat1.ys <br>";  #elena

    open YS, "<dat/$treat1.ys";    # Yearly Scenario

#   open YS, "<c:\\Inetpub\\Scripts\\fswepp\\wd\\data\\$treat1.ys";      # elena
    while (<YS>) {
        if (/itype/) { substr( $_, 0, 1 ) = "1" }
        print MANFILE $_;
    }
    close YS;

    #   print "<p>the value of treat2.ys is: $treat2.ys <br>";  #elena
    open YS, "<dat/$treat2.ys";

    #   open YS, "<c:\\Inetpub\\Scripts\\fswepp\\wd\\data\\$treat2.ys"; #elena
    while (<YS>) {
        if (/itype/) { substr( $_, 0, 1 ) = "2" }
        print MANFILE $_;
    }
    close YS;

    print MANFILE "######################
# Management Section #
######################
DISTWEPP
Two OFEs to drive the Disturbed WEPP interface
for forest conditions
W. Elliot 02/99
2\t# `nofe' - <number of Overland Flow Elements>
\t1\t# `Initial Conditions indx' - <$treat1>
\t2\t# `Initial Conditions indx' - <$treat2>
$years2sim\t# `nrots' - <rotation repeats..>
1\t# `nyears' - <years in rotation>
";

    for $i ( 1 .. $years2sim ) {
        print MANFILE "#
#	Rotation $i : year $i to $i
#
\t1\t# `nycrop' - <plants/yr; Year of Rotation :  $i - OFE : 1>
\t\t1\t# `YEAR indx' - <$treat1>
\t1\t# `nycrop' - <plants/yr; Year of Rotation :  $i - OFE : 2>
\t\t2\t# `YEAR indx' - <$treat2>
";
    }
    close MANFILE;
}

sub CreateResponseFile {

    open( ResponseFile, ">" . $responseFile );
    print ResponseFile "98.4\n";    # datver
    print ResponseFile "y\n";       # not watershed
    print ResponseFile "1\n";       # 1 = continuous
    print ResponseFile "1\n";       # 1 = hillslope
    print ResponseFile "n\n";       # hillsplope pass file out?
    if ( lc($action) =~ /vegetation/ ) {
        print ResponseFile "1\n";    # 1 = annual; abbreviated
    }
    else {
        print ResponseFile "2\n";    # 2 = annual; detailed
    }
    print ResponseFile "n\n";                # initial conditions file?
    print ResponseFile $outputFile, "\n";    # soil loss output file
    print ResponseFile "n\n";                # water balance output?
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

    $rc = 0;
    print '<font color="red"><b>', "";
    if ( $CL eq "" ) { print "No climate selected<br>\n"; $rc -= 1 }
    if (   $soil ne "sand"
        && $soil ne "silt"
        && $soil ne "clay"
        && $soil ne "loam" )
    {
        print "Invalid soil: ", $soil, "<br>\n";
        $rc -= 1;
    }

    #  if ($treat1 ne "skid" && $treat1 ne "high" && $treat1 ne "low"
    #      && $treat1 ne "short" && $treat1 ne "tall" && $treat1 ne "shrub"
    #      && $treat1 ne "tree5" && $treat1 ne "tree20")
    if ( $treatments{$treat1} eq "" ) {
        print "Invalid upper treatment: ", $treat1, "<br>\n";
        $rc -= 1;
    }
    if ( $treatments{$treat2} eq "" ) {
        print "Invalid lower treatment: ", $treat2, "<br>\n";
        $rc -= 1;
    }
    if ( $units eq 'm' ) {
        if ( $ofe1_length < 0 || $ofe1_length > 3000 ) {
            print "Invalid upper length; range 0 to 3000 m<br>\n";
            $rc -= 1;
        }
        if ( $ofe2_length < 0 || $ofe2_length > 3000 ) {
            print "Invalid lower length; range 0 to 3000 m<br>\n";
            $rc -= 1;
        }
    }
    else {
        if ( $ofe1_length < 0 || $ofe1_length > 9000 ) {
            print "Invalid upper length; range 0 to 9000 ft<br>\n";
            $rc -= 1;
        }
        if ( $ofe2_length < 0 || $ofe2_length > 9000 ) {
            print "Invalid lower length; range 0 to 9000 ft<br>\n";
            $rc -= 1;
        }
    }
    if ( $ofe1_top_slope < 0 || $ofe1_top_slope > 1000 ) {
        print "Invalid upper top gradient; range 0 to 1000 %<br>\n";
        $rc -= 1;
    }
    if ( $ofe1_mid_slope < 0 || $ofe1_mid_slope > 1000 ) {
        print "Invalid upper mid gradient; range 0 to 1000 %<br>\n";
        $rc -= 1;
    }
    if ( $ofe2_mid_slope < 0 || $ofe2_mid_slope > 1000 ) {
        print "Invalid lower mid gradient; range 0 to 1000 %<br>\n";
        $rc -= 1;
    }
    if ( $ofe2_bot_slope < 0 || $ofe2_bot_slope > 1000 ) {
        print "Invalid lower toe gradient; range 0 to 1000 %<br>\n";
        $rc -= 1;
    }

    print "</b></font>\n";
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
    if ( $debug > 1 ) { print "Cropper: opening $cropFile<br>\n" }

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

    #   if ($debug > 1) {print "\nParsead: opening $outputFile<br>\n"}
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
        }
        close AD;

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

    }    # if /Annual detailed/
    else {
        chomp;
        s/^\s*(.*?)\s*$/$1/;
        print "\nExpecting 'Annual; detailed' file; you gave me a '$_' file\n";
    }
}


# ------------------------ end of subroutines ----------------------------

sub wrdt {

    $i = shift;
    local $surface = @insurface[$i];
    local $traffic = @intraffic[$i];
    local $slope   = @inslope[$i];

    # =======================  Run WEPP  =========================

    $design = $slope;

    if ( &CheckInputwr >= 0 ) {
        if    ( substr( $surface, 0, 1 ) eq 'g' ) { $surf = 'g' }    #HR
        elsif ( substr( $surface, 0, 1 ) eq 'p' ) { $surf = 'p' }    #HR
        else                                      { $surf = '' }     #HR
        if    ( $slope eq 'inveg' ) { $tauC = '10'; $manfile = '3inslope.man' }
        elsif ( $slope eq 'outunrut' ) { $tauC = '2'; $manfile = '3outunr.man' }
        elsif ( $slope eq 'outrut' )   { $tauC = '2'; $manfile = '3outrut.man' }
        elsif ( $slope eq 'inbare' ) { $tauC = '2'; $manfile = '3inslope.man' }
        if    ( $traffic eq 'none' ) {
            if ( $manfile eq '3inslope.man' ) {
                $manfile = '3inslopen.man';
            }    # DEH 07/10/2002
            if ( $manfile eq '3outunr.man' ) { $manfile = '3outunrn.man' }
            if ( $manfile eq '3outrut.man' ) { $manfile = '3outrutn.man' }
        }
        $zzveg = $manPath . $manfile;
        if ( $slope eq 'inbare' && $surf eq 'p' ) { $tauC = '1' }
        $soilFile   = '3' . $surf . $ST . $tauC . '.sol';
        $soilFilefq = $soilPath . $soilFile;

        $zzsoil  = &CreateSoilFilewr;
        $zzslope = &CreateSlopeFileWeppRoad(
            $URS, $UFS,   $UBS,   $URW,       $URL, $UFL,
            $UBL, $units, $slope, $slopeFile, $debug
        );

        $zzresp = &CreateResponseFilewr;
        @args   = ("../wepp2010 <$responseFile >$stoutFile 2>$sterFile");
        system @args;
        $found = &parseWeppResults;

    }    #   if (&checkInputwr >= 0)

    return ( $syraf, $sypaf );

}    #	end of subroutine wrdt

1;

# ------------------------ subroutines ---------------------------

sub CreateResponseFilewr {

    open( ResponseFile, ">" . $responseFile );
    print ResponseFile "97.3\n";               # datver
    print ResponseFile "y\n";                  # not watershed
    print ResponseFile "1\n";                  # 1 = continuous
    print ResponseFile "1\n";                  # 1 = hillslope
    print ResponseFile "n\n";                  # hillsplope pass file out?
    print ResponseFile "1\n";                  # 1 = abreviated annual out
    print ResponseFile "n\n";                  # initial conditions file?
    print ResponseFile "$outputFile", "\n";    # soil loss output file
    print ResponseFile "n\n";                  # water balance output?
    print ResponseFile "n\n";                  # crop output?
    print ResponseFile "n\n";                  # soil output?
    print ResponseFile "n\n";                  # distance/sed loss output?
    print ResponseFile "n\n";                  # large graphics output?
    print ResponseFile "n\n";                  # event-by-event out?
    print ResponseFile "n\n";                  # element output?
    print ResponseFile "n\n";                  # final summary out?
    print ResponseFile "n\n";                  # daily winter out?
    print ResponseFile "n\n";                  # plant yield out?
    print ResponseFile $manPath . $manfile, "\n";    # management file name
    print ResponseFile $slopeFile,   "\n";           # slope file name
    print ResponseFile $climateFile, "\n";           # climate file name
    print ResponseFile $newSoilFile, "\n";           # soil file name
    print ResponseFile "0\n";                        # 0 = no irrigation
    print ResponseFile "$years2sim\n";               # no. years to simulate
    print ResponseFile "0\n";                        # 0 = route all events
    close ResponseFile;
    return $responseFile;
}

sub CreateSoilFilewr {

    # Read a WEPP:Road soil file template and create a usable soil file.
    # File may have 'urr', 'ufr' and 'ubr' as placeholders for rock fragments
    # percentage
    # Adjust road surface Kr downward for traffic levels of 'low' or 'none'
    # Adjust road surface Ki downward for

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
    my ( $pos1, $pos2, $pos3, $pos4 );
    my ( $ind, $left, $right );

    open SOILFILE,    "<$soilFilefq";
    open NEWSOILFILE, ">$newSoilFile";

    # print "surface: $surface<br>\n";
    if    ( $surface eq 'graveled' ) { $URR = 65;   $UFR = ( $UBR + 65 ) / 2 }
    elsif ( $surface eq 'paved' )    { $URR = 95;   $UFR = ( $UBR + 65 ) / 2 }
    else                             { $URR = $UBR; $UFR = $UBR }

    # modify 'Kr' for 'no traffic' and 'low traffic'
    # modify 'Ki' for 'no traffic' and 'low traffic'

    if ( $traffic eq 'low' || $traffic eq 'none' ) {
        $in = <SOILFILE>;
        print NEWSOILFILE $in;    # line 1; version control number - datver
        $in = <SOILFILE>;         # first comment line
        print NEWSOILFILE $in;
        while ( substr( $in, 0, 1 ) eq '#' ) {    # gobble up comment lines
            $in = <SOILFILE>;
            print NEWSOILFILE $in;
        }
        $in = <SOILFILE>;
        print NEWSOILFILE $in;                    # line 3: ntemp, ksflag
        $in   = <SOILFILE>;
        $pos1 = index( $in, "'" );                # location of first apostrophe
        $pos2 = index( $in, "'", $pos1 + 1 );    # location of second apostrophe
        $pos3 = index( $in, "'", $pos2 + 1 );    # location of third apostrophe
        $pos4 = index( $in, "'", $pos3 + 1 );    # location of fourth apostrophe
        my $slid_texid = substr( $in, 0, $pos4 + 1 );    # slid; texid
        my $rest       = substr( $in, $pos4 + 1 );
        my ( $nsl, $salb, $sat, $ki, $kr, $shcrit, $avke ) = split ' ', $rest;
        $kr /= 4;
        $ki /= 4;    #  if ($ki_code ne 'none');     # DEH 2004.01.27
        print NEWSOILFILE "$slid_texid\t";
        print NEWSOILFILE "$nsl\t$salb\t$sat\t$ki\t$kr\t$shcrit\t$avke\n";
    }

    while (<SOILFILE>) {
        $in = $_;
        if (/urr/) {    # user-specified road rock fragment
            $ind   = index( $in, 'urr' );
            $left  = substr( $in, 0, $ind );
            $right = substr( $in, $ind + 3 );
            $in    = $left . $URR . $right;
        }
        elsif (/ufr/) {    # calculated fill rock fragment
            $ind   = index( $in, 'ufr' );
            $left  = substr( $in, 0, $ind );
            $right = substr( $in, $ind + 3 );
            $in    = $left . $UFR . $right;
        }
        elsif (/ubr/) {    # calculated buffer rock fragment
            $ind   = index( $in, 'ubr' );
            $left  = substr( $in, 0, $ind );
            $right = substr( $in, $ind + 3 );
            $in    = $left . $UBR . $right;
        }
        print NEWSOILFILE $in;
    }
    close SOILFILE;
    close NEWSOILFILE;
    return $newSoilFile;
}

sub CheckInputwr {

    if ( $units eq "m" ) {
        $lu     = "m";
        $minURL = 1;
        $maxURL = 300;
        $minURS = 0.1;
        $maxURS = 40;
        $minURW = 0.3;
        $maxURW = 100;
        $minUFL = 0.3;
        $maxUFL = 100;
        $minUFS = 0.1;
        $maxUFS = 150;
        $minUBL = 0.3;
        $maxUBL = 300;
        $minUBS = 0.1;
        $maxUBS = 100;
    }
    else {
        $lu     = "ft";
        $minURL = 3;
        $maxURL = 1000;
        $minURS = 0.3;
        $maxURS = 40;
        $minURW = 1;
        $maxURW = 300;
        $minUFL = 1;
        $maxUFL = 300;
        $minUFS = 0.3;
        $maxUFS = 150;
        $minUBL = 1;
        $maxUBL = 1000;
        $minUBS = 0.3;
        $maxUBS = 100;
    }
    $minyrs = 1;
    $maxyrs = 200;
    $rc     = -0;

    if ( $URL < $minURL or $URL > $maxURL ) {
        $rc = -1;
        print "Road length must be between $minURL and $maxURL $lu<BR>\n";
    }
    if ( $URS < $minURS or $URS > $maxURS ) {
        $rc = $rc - 1;
        print "Road gradient must be between $minURS and $maxURS %<BR>\n";
    }
    if ( $URW < $minURW or $URW > $maxURW ) {
        $rc = $rc - 1;
        print "Road width must be between $minURW and $maxURW $lu<BR>\n";
    }
    if ( $UFL < $minUFL or $UFL > $maxUFL ) {
        $rc = $rc - 1;
        print "Fill length must be between $minUFL and $maxUFL $lu<BR>\n";
    }

    if ( $UFS < $minUFS ) {
        $rc = $rc - 1;
        print "Fill gradient must be greater than $minUFS %<BR>\n";
    }
    if ( $UFS > $maxUFS ) {
        $UFS = $maxUFS;
    }

    if ( $UBL < $minUBL or $UBL > $maxUBL ) {
        $rc = $rc - 1;
        print "Buffer length must be between $minUBL and $maxUBL $lu<BR>\n";
    }
    if ( $UBS < $minUBS or $UBS > $maxUBS ) {
        $rc = $rc - 1;
        print "Buffer gradient must be between $minUBS and $maxUBS %<BR>\n";
    }

    if ( $years2sim < 1 )   { $years2sim = 1 }
    if ( $years2sim > 200 ) { $years2sim = 200 }
    return $rc;
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
    close(weppstout);

    if ( $found == 0 ) {   # unsuccessful run -- search STDOUT for error message
        open weppstout, "<$stoutFile";
        while (<weppstout>) {
            if (/ERROR/) {
                $found = 2;
                print "<font color=red>\n";
                $_ = <weppstout>;
                $_ = <weppstout>;
                $_ = <weppstout>;
                print;
                $_ = <weppstout>;
                print;
                print "</font>\n";
                last;
            }
        }
        close(weppstout);
    }

    if ( $found == 0 ) {
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
        close(weppstout);
    }

    if ( $found == 0 ) {
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
    }

    if ( $found == 0 ) {
        open weppstout, "<$stoutFile";
        while (<weppstout>) {
            if (/MATHERRQQ/) {
                $found = 5;
                print "<font color=red>\n";
                print 'WEPP has run into a mathematical anomaly.<br>
             You may be able to get around it by modifying the geometry slightly;
             try changing road length by 1 foot (1/2 meter) or so.
             ';
                $_ = <weppstout>;
                print;
                print "</font>\n";
                last;
            }
        }
        close(weppstout);
    }

    if ( $found == 1 ) {    # Successful run -- get actual WEPP version number
        open weppout, "<$outputFile";
        $ver = 'unknown';
        while (<weppout>) {
            if (/VERSION/) {
                $weppver = $_;
                last;
            }
        }

        while (<weppout>) {    # read actual climate file used from WEPP output
            if (/CLIMATE/) {
                $a_c_n = <weppout>;
                $actual_climate_name =
                  substr( $a_c_n, index( $a_c_n, ":" ) + 1, 40 );
                $climate_name = $actual_climate_name;
                last;
            }
        }

        while (<weppout>) {
            if (/RAINFALL AND RUNOFF SUMMARY/) {
                $_ = <weppout>;    #      -------- --- ------ -------
                $_ = <weppout>;    #
                $_ = <weppout>;    #       total summary:  years    1 -    1
                $_ = <weppout>;    #
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
                $precip = substr $_, 51, 10;
                $_      = <weppout>;
                $rro    = substr $_, 51, 10;    # print;
                $_      = <weppout>;            # print;
                $_      = <weppout>;
                $sro    = substr $_, 51, 10;    # print;
                $_      = <weppout>;            # print;
                last;
            }
        }

        while (<weppout>) {
            if (/AREA OF NET SOIL LOSS/) {
                $_   = <weppout>;
                $_   = <weppout>;
                $_   = <weppout>;
                $_   = <weppout>;
                $_   = <weppout>;
                $_   = <weppout>;               # print;
                $_   = <weppout>;               # print;
                $_   = <weppout>;               # print;
                $_   = <weppout>;               # print;
                $_   = <weppout>;               # print;
                $syr = substr $_, 17, 7;

                #print "syr $syr";
                $effective_road_length = substr $_, 9, 9;
                last;
            }
        }

        while (<weppout>) {
            if (/OFF SITE EFFECTS/) {
                $_   = <weppout>;
                $_   = <weppout>;
                $_   = <weppout>;
                $syp = substr $_, 49, 10;    # pre-WEPP 98.4
                $_   = <weppout>;
                if ( $syp eq "" ) {
                    @sypline = split ' ', $_;
                    $syp     = @sypline[0];
                }
                $_ = <weppout>;
                $_ = <weppout>;

                #print "syp $syp";
                last;
            }
        }
        close(weppout);

        $storms     += 0;
        $rainevents += 0;
        $snowevents += 0;
        $precip     += 0;
        $rro        += 0;
        $sro        += 0;
        $syr        += 0;
        $syp        += 0;
        $syra = $syr * $effective_road_length * $WeppRoadWidth;
        $sypa = $syp * $WeppRoadWidth;

# print "sed yield road: $syra = $syr * $effective_road_length m length * $WeppRoadWidth m width (* 2.2046)<br>\n";
# print "sed yield buff: $sypa = $syp * $WeppRoadWidth m width (* 2.2046)<br>\n";
        if    ( $surface eq 'graveled' ) { $URR = 65; $UFR = ( $UBR + 65 ) / 2 }
        elsif ( $surface eq 'paved' )    { $URR = 95; $UFR = ( $UBR + 65 ) / 2 }
        else                             { $URR = $UBR; $UFR = $UBR }

## DEH 2003/10/09
        $trafficx = $traffic;
        $trafficx = 'no' if ( $traffic eq 'none' );
##

        #*******the input tables were here starting with <center>#

        if ( $units eq "m" ) {
            $precipunits = "mm";
            $sedunits    = "kg";
            $pcpfmt      = '%.0f';
        }
        else {    # convert WEPP metric results to in and lb
            $precipunits = "in";
            $precip      = $precip / 25.4;
            $rro         = $rro / 25.4;
            $sro         = $sro / 25.4;
            $sedunits    = "lb";
            $syra        = $syra * 2.2046;
            $sypa        = $sypa * 2.2046;
            $pcpfmt      = '%.2f';
        }
        $precipf     = sprintf $pcpfmt, $precip;
        $rrof        = sprintf $pcpfmt, $rro;
        $srof        = sprintf $pcpfmt, $sro;
        $syraf       = sprintf "%.2f", $syra;
        @outsyra[$i] = $syra;    #elena
        $sypaf       = sprintf "%.2f", $sypa;
        @outsypa[$i] = $sypa;    #elena

        # print TEMP "<tr><td colspan=14><font size=1>";
        # print TEMP "</font></td></tr>";
    }
    else {    # ($found != 1)
        print
"<p>\n[WEPP:Road] I'm sorry; WEPP did not run successfully.\n<p><hr><p>\n";
    }
    return $found;
}

# ---------------------  WEPP summary output  --------------------

sub printWeppSummary {
    print '<CENTER><H2>WEPP output</H2></CENTER>';
    print '<font face=courier><PRE>';
    open weppout, "<$outputFile";
    while (<weppout>) {
        print;
    }
    close weppout;
    print '</PRE></font>
<p><center><hr>
<a href="JavaScript:window.history.go(-1)">
<img src="/fswepp/images/rtis.gif"
     alt="Return to input screen" border="0" aligh=center></A>
<BR><HR></center>
';
}

sub min () {
    my $min = shift(@_);
    foreach $val (@_) {
        $min = $val if $min > $val;
    }
    return $min;
}

sub max () {
    my $max = shift(@_);
    foreach $val (@_) {
        $max = $val if $max < $val;
    }
    return $max;
}
