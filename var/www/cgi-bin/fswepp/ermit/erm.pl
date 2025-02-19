#!/usr/bin/perl

use warnings;
use CGI;
use CGI qw(escapeHTML);
use MoscowFSL::FSWEPP::CligenUtils
  qw(CreateCligenFile GetParSummary GetParLatLong);
use MoscowFSL::FSWEPP::FsWeppUtils
  qw(get_version get_thisyear_and_thisweek get_user_id);
use String::Util qw(trim);

#
# erm.pl
#
# ermit workhorse
# Reads user input from ermit.pl, runs WEPP, parses output files
# top adapted from wd.pl 8/28/2002

my $verbose = 0;

my $debug       = 0;           # DEH 2014-02-07 over-ride command-line
my $weppversion = "wepp2010"
  ; # 2014.02.07 DEH 2000 or 2010; WEPP 2010 needs frost.txt file in ERMiT directory to give 'correct' results

my $version = get_version(__FILE__);
my $user_ID = get_user_id();

#=========================================================================

my ( $thisyear, $thisweek ) = get_thisyear_and_thisweek();

my $cgi = CGI->new;

my $pt               = 1 if ( $cgi->param('ptcheck') =~ 'on' );
my $units            = escapeHTML( $cgi->param('units') );
my $CL               = escapeHTML( $cgi->param('Climate') );
my $climate_name     = escapeHTML( $cgi->param('climate_name') );
my $SoilType         = escapeHTML( $cgi->param('SoilType') );
my $rfg              = escapeHTML( $cgi->param('rfg') );
my $vegtype          = escapeHTML( $cgi->param('vegetation') );
my $top_slope        = escapeHTML( $cgi->param('top_slope') );
my $avg_slope        = escapeHTML( $cgi->param('avg_slope') );
my $toe_slope        = escapeHTML( $cgi->param('toe_slope') );
my $hillslope_length = escapeHTML( $cgi->param('length') );
my $severityclass    = escapeHTML( $cgi->param('severity') );
my $shrub            = escapeHTML( $cgi->param('pct_shrub') );
my $grass            = escapeHTML( $cgi->param('pct_grass') );
my $bare             = escapeHTML( $cgi->param('pct_bare') );
my $achtung          = escapeHTML( $cgi->param('achtung') );
my $action =
  escapeHTML( $cgi->param('actionc') ) . escapeHTML( $cgi->param('actionw') );

if ( $achtung . $action eq '' ) { &bomb; die }

$vegtype_x = $vegtype;                                 # 2004.10.07 DEH
$vegtype_x = 'chaparral' if ( $vegtype eq 'chap' );    # 2004.10.07 DEH

if ( $SoilType eq 'clay' ) {
    $soil_texture = 'clay loam';
    $soil_symbols = '(MH, CH)';
    $soil_description =
      'Shales and similar decomposing fine-grained sedimentary rock';
}
elsif ( $SoilType eq 'loam' ) {
    $soil_texture     = 'loam';
    $soil_symbols     = '(GC, SM, SW, SP)';
    $soil_description = 'Glacial tills, alluvium';
}
elsif ( $SoilType eq 'sand' ) {
    $soil_texture = 'sandy loam';
    $soil_symbols = '(SW, SP, SM, SC)';
    $soil_description =
      'Glacial outwash areas; finer-grained granitics and sand';
}
elsif ( $SoilType eq 'silt' ) {
    $soil_texture     = 'silt loam';
    $soil_symbols     = '(ML, CL)';
    $soil_description = 'Ash cap or alluvial loess';
}

$severityclass_x = 'high'     if ( $severityclass eq 'h' );
$severityclass_x = 'moderate' if ( $severityclass eq 'm' );
$severityclass_x = 'low'      if ( $severityclass eq 'l' );
$severityclass_x = 'unburned' if ( $severityclass eq 'u' );    # 2013.04.19 DEH

# $count doesn't do anything RL
$count = 40 if ( $severityclass eq 'h' );    # 2006.01.18 DEH
$count = 30 if ( $severityclass eq 'm' );    # 2006.01.18 DEH
$count = 20 if ( $severityclass eq 'l' );    # 2006.01.18 DEH
$count = 10 if ( $severityclass eq 'u' );    # 2013.04.19 DEH	# unburned

$rfg += 0;
$rfg = 05 if ( $rfg < 05 );
$rfg = 85 if ( $rfg > 85 );

$working    = '../working';
$runLogFile = "../working/" . $user_ID . ".run.log";
$div        = '/';

##### set up file names and paths #####

$unique       = 'wepp-' . $$;
$workingpath  = $working . $div . $unique;
$datapath     = 'data' . $div;
$responseFile = $workingpath . '.in';
$outputFile   = $workingpath . '.out';
$stoutFile    = $workingpath . '.stout';
$sterrFile    = $workingpath . '.sterr';
$soilFile     = $workingpath . '.sol';
$slopeFile    = $workingpath . '.slp';
$CLIfile      = $workingpath . '.cli';        #  open INCLI, "<$CLIfile" or die;
$shortCLIfile = $workingpath . '_' . '.cli';  #  open OUTCLI, ">$shortCLIfile";

#   $manFile        = $workingpath . '.man';
$manFile          = $datapath . 'high100.man';
$eventFile        = $workingpath . '.event100';    # DEH 2003.02.06
$tempFile         = $workingpath . '.temp';
$gnuplotdatafile  = $workingpath . '.gnudata';
$gnuplotjclfile   = $workingpath . '.gnujcl';
$gnuplotgraphpng  = $workingpath . '.png';
$gnuplotgrapheps  = $workingpath . '.eps';
$gnuplotgraphpl   = "/cgi-bin/fswepp/ermit/servepng.pl?graph=$unique";
$gnuplotgraphpath = "/cgi-bin/fswepp/working/$unique.png";

# CLIGEN paths

$climatePar = $CL . '.par';
$crspfile   = $workingpath . 'c.rsp';
$cstoutfile = $workingpath . 'c.out';

# flow paths

#  $slopeFilePath = $workingpath . '.slp';
#  $stoutFilePath = $workingpath . 'stout';
#  $sterrFilePath = $workingpath . 'sterr';
$evoFile      = $workingpath . '.evo';
$ev_by_evFile = $workingpath . '.event';

################## DESCRIBE SOIL ################

if ( lc($achtung) =~ /describe soil/ ) {
    $units    = escapeHTML( $cgi->param('units') );
    $SoilType = escapeHTML( $cgi->param('SoilType') );

    $comefrom = "/cgi-bin/fswepp/ermit/ermit.pl";

    #     $soilFilefq = $datapath . $soilFile;
    print "Content-type: text/html\n\n";
    print "<HTML>\n";
    print " <HEAD>\n";
    print "  <TITLE>ERMiT -- Soil Parameters</TITLE>\n";
    print " </HEAD>\n";
    print '<BODY link="#ff0000">
  <font face="Arial, Geneva, Helvetica">
  <blockquote>
  <table width=95% border=0>
    <tr><td>
       <a href="/cgi-bin/fswepp/ermit/ermit.pl">
       <IMG src="/fswepp/images/ermit.gif"
       align="left" alt="Back to FS WEPP menu" border=1></a>
    <td align=center>
       <hr>
       <h3>ERMiT Soil Texture Properties</h3>
       <hr>
    <td>
       <A HREF="/fswepp/docs/ermit/.html">
       <IMG src="/fswepp/images/epage.gif"
        align="right" alt="Read the documentation" border=0></a>
    </table>
';
    if ($verbose) { print "Action: '$action'<br>\nAchtung: '$achtung'<br>\n" }

    print $soil_texture, ' ', $soil_symbols, '<br>', $soil_description, "\n";

    if ( $severityclass eq 'u' ) {    # 2013.04.19 DEH)
        $s = 'uuu';
        $k = 1;
    }
    else {
        $s = 'hhh';
        $k = 4;
    }
    open SOIL, ">$soilFile";
    $soilfileitself = &createsoilfile;
    print SOIL $soilfileitself;
    close SOIL;

    print "<hr><b><pre>\n\n";

    #    print $soilFile,"\n";

    open SOIL, "<$soilFile";
    $sweppver = <SOIL>;
    $comment  = <SOIL>;
    while ( substr( $comment, 0, 1 ) eq "#" ) {
        chomp $comment;

        #       print $comment,"\n";
        $comment = <SOIL>;
    }

    print "</pre></b>
 <center>
 <table border=1 cellpadding=8>
";

    #     $solcom = $comment;
    #     $record = <SOIL>;

    @vals   = split " ", $comment;
    $ntemp  = @vals[0];    # no. flow elements or channels
    $ksflag = @vals[1];    # 0: hold hydraulic conductivity constant
                           # 1: use internal adjustments to hydr con

    for $i ( 1 .. $ntemp ) {
        print
'<tr><th colspan=3 bgcolor="85d2d2"><font face="Arial, Geneva, Helvetica">',
          "\n";
        print "<font size=-1>Element $i --- \n";
        $record      = <SOIL>;
        @descriptors = split "'", $record;
        print "@descriptors[1]\n   ";    # slid: Road, Fill, Forest
        print "<br>Soil texture: @descriptors[3]</font></th></tr>\n"
          ;                              # texid: soil texture
        ( $nsl, $salb, $sat, $ki, $kr, $shcrit, $avke ) = split " ",
          @descriptors[4];

        #      @vals = split " ", @descriptors[4];
        #      print "No. soil layers: $nsl\n";
        print
"<tr><th align=left><font face='Arial, Geneva, Helvetica' size=-1>Albedo of the bare dry surface soil</font></th><td align='right'><font face='Arial, Geneva, Helvetica' size=-1>$salb</font></td><td></td></tr>\n";
        print
"<tr><th align=left><font face='Arial, Geneva, Helvetica' size=-1>Initial saturation level of the soil profile porosity</font></th><td align='right'><font face='Arial, Geneva, Helvetica' size=-1>$sat</font></td><td><font face='Arial, Geneva, Helvetica' size=-1>m m<sup>-1</sup></font></td></tr>\n";
        print
"<tr><th align=left><font face='Arial, Geneva, Helvetica' size=-1>Baseline interrill erodibility parameter (k<sub>i</sub>)</td><td align='right'><font face='Arial, Geneva, Helvetica' size=-1>$ki</font></td><td><font face='Arial, Geneva, Helvetica' size=-1>kg s m<sup>-4</sup></font></td></tr>\n";
        print
"<tr><th align=left><font face='Arial, Geneva, Helvetica' size=-1>Baseline rill erodibility parameter (k<sub>r</sub>)</td><td align='right'><font face='Arial, Geneva, Helvetica' size=-1>$kr</font></td><td><font face='Arial, Geneva, Helvetica' size=-1>s m<sup>-1</sup></font></td></tr>\n";
        print
"<tr><th align=left><font face='Arial, Geneva, Helvetica' size=-1>Baseline critical shear parameter (&tau;<sub>c</sub> )</td><td align='right'><font face='Arial, Geneva, Helvetica' size=-1>$shcrit</font></td><td><font face='Arial, Geneva, Helvetica' size=-1>N m<sup>-2</sup></font></td></tr>\n";
        print
"<tr><th align=left><font face='Arial, Geneva, Helvetica' size=-1>Effective hydraulic conductivity of surface soil (k<sub>e</sub>)</td><td align='right'><font face='Arial, Geneva, Helvetica' size=-1>$avke</font></td><td><font face='Arial, Geneva, Helvetica' size=-1>mm h<sup>-1</sup></font></td></tr>\n";
        for $layer ( 1 .. $nsl ) {
            $record = <SOIL>;
            ( $solthk, $sand, $clay, $orgmat, $cec, $rfg ) = split " ", $record;
            print
"<tr><td><br></td><th colspan=2 bgcolor=85d2d2><font face='Arial, Geneva, Helvetica' size=-1>layer $layer</font></th></tr>\n";
            print
"<tr><th align=left><font face='Arial, Geneva, Helvetica' size=-1>Depth from soil surface to bottom of soil layer</font></td><td align='right'><font face='Arial, Geneva, Helvetica' size=-1>$solthk</font></td><td><font face='Arial, Geneva, Helvetica' size=-1>mm</font></td></tr>\n";
            print
"<tr><th align=left><font face='Arial, Geneva, Helvetica' size=-1>Percentage of sand</font></td><td align='right'><font face='Arial, Geneva, Helvetica' size=-1>$sand</font></td><td><font face='Arial, Geneva, Helvetica' size=-1>%</font></td></tr>\n";
            print
"<tr><th align=left><font face='Arial, Geneva, Helvetica' size=-1>Percentage of clay</font></td><td align='right'><font face='Arial, Geneva, Helvetica' size=-1>$clay</font></td><td><font face='Arial, Geneva, Helvetica' size=-1>%</font></td></tr>\n";
            print
"<tr><th align=left><font face='Arial, Geneva, Helvetica' size=-1>Percentage of organic matter (by volume)</font></th><td align='right'><font face='Arial, Geneva, Helvetica' size=-1>$orgmat</font></td><td><font face='Arial, Geneva, Helvetica' size=-1>%</font></td></tr>\n";
            print
"<tr><th align=left><font face='Arial, Geneva, Helvetica' size=-1>Cation exchange capacity</font></td><td align='right'><font face='Arial, Geneva, Helvetica' size=-1>$cec</font></td><td><font face='Arial, Geneva, Helvetica' size=-1>meq per 100 g of soil</font></td></tr>\n";
            print
"<tr><th align=left><font face='Arial, Geneva, Helvetica' size=-1>Percentage of rock fragments (by volume)</font></th><td align='right'><font face='Arial, Geneva, Helvetica' size=-1>$rfg</font></td><td><font face='Arial, Geneva, Helvetica' size=-1>%</font></td></tr>\n";
        }
    }
    close SOIL;
    print '</table><br><hr><br>';
    print '  </center><pre>';
    print $soilfileitself;
    print '
    </pre>
   <br>
  </blockquote>
 </body>
</html>
';
    die;
}    #  /describe soil/

# *******************************

$years2sim = 100;    # initial run

# ######### for logging ERMiT run ######################

@months =
  qw(January February March April May June July August September October November December);
@days    = qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);
$ampm[0] = "am";
$ampm[1] = "pm";

$ampmi = 0;
( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime;
if ( $hour == 12 ) { $ampmi = 1 }
if ( $hour > 12 )  { $ampmi = 1; $hour = $hour - 12 }
$mythisyear = $year + 1900;
$thissyear  = $mythisyear;

$host        = $ENV{REMOTE_HOST};
$host        = $ENV{REMOTE_ADDR} if ( $host eq '' );
$user_really = $ENV{'HTTP_X_FORWARDED_FOR'};              # DEH 11/14/2002
$host        = $user_really if ( $user_really ne '' );    # DEH 11/14/2002

# ########### RUN WEPP for 100-year simulation ######################

# open TEMP...
open TEMP, ">$tempFile";

#   $unique='wepp-' . $$;

if ($verbose) { print TEMP "</center>\nUnique? filename= $unique\n<BR>" }

$evo_file = $eventFile;

#   $host = $ENV{REMOTE_HOST};

#   $rcin = &checkInput;
#   if ($rcin >= 0) {

if ( $severityclass eq 'u' ) {    # 2013.04.19 DEH
    $s = 'uuu';
}
else {
    $s = 'hhh';
}

# $avg_slope - average surface slope gradient
# $toe_slope - surface slope toe gradient
# $hillslope_length

$avg_slope        += 0;
$toe_slope        += 0;
$hillslope_length += 0;
$hillslope_length_m = $hillslope_length;
if ( $units eq 'ft' ) { $hillslope_length_m *= 0.3048 }

if ($verbose) {
    print TEMP "
  <blockquote>
   <pre>
    ERMiT version $version
    WEPP version $weppversion requested
    I am $user_ID
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
                            from     $climatePar
    Create 100-year soil file        $soilFile
    Create WEPP Response File        $responseFile
           temporary file            $tempFile
</font>
";
}

@args = ("../$weppversion <$responseFile >$stoutFile 2>$sterrFile");

# wtf is this here. it isn't running wepp. it redefines this on 413

if ($debug) {
    print TEMP "@args
    </pre>
   </blockquote>
";
}

# die;

if ($debug) { print TEMP "Creating 100-year slope file $slopeFile" }
open SLOPE, ">$slopeFile";
print SLOPE &createSlopeFile;
close SLOPE;
if ($debug) { $printfilename = $slopeFile; &printfile }
if ($debug) { print TEMP "100-year management file " }

#     if ($debug) {$printfilename = $manFile; &printfile}
if ($debug) {
    print TEMP "Creating 100-year climate file $CLIfile from $climatePar<br>";
}

( $climateFile, $climatePar ) =
  &CreateCligenFile( $CL, $unique, $years2sim, $debug );

if ($debug) { print TEMP "Creating 100-year soil file<br>\n" }
if ( $severityclass eq 'u' ) {                                  # 2013.05.03 DEH
    $s = 'uuu';
    $k = 1;
}
else {
    $s = 'hhh';
    $k = 4;
}
open SOL, ">$soilFile";
print SOL &createsoilfile;
close SOL;

#       $s='hhh';			# 2103.05.03 DEH
#       $k=4;
open SOL, ">../working/soil100.txt";
print SOL &createsoilfile;
close SOL;

#$#$#$

if ($debug) { $printfilename = $soilFile; &printfile }
if ($debug) { print TEMP "Creating WEPP Response File " }
&CreateResponseFile;
if ($debug) { $printfilename = $responseFile; &printfile }

@args = ("../$weppversion <$responseFile >$stoutFile 2>$sterrFile");
system @args;

###
# die 'temporary';
###

#     unlink $CLIfile;    # be sure this is right file .....     # 2/2000 # 2006.02.23 DEH uncomment
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
$intunits    = 'mm h<sup>-1</sup>';

# $sedunits = 'kg m<sup>-1</sup>';
$sedunits     = 't ha<sup>-1</sup>';
$alt_sedunits = 't / ha';
$precipf      = $precip;
$rrof         = $rro;
$srof         = $sro;
$syraf        = $syr;
$sypaf        = $syp;

if ( $units eq 'ft' ) {
    $precipunits  = 'in';
    $intunits     = 'in h<sup>-1</sup>';
    $sedunits     = 'ton ac<sup>-1</sup>';
    $alt_sedunits = 'ton / ac';
    $precipf      = sprintf '%9.2g', $precip / 25.4;
    $rrof         = sprintf '%9.2g', $rro / 25.4;
    $srof         = sprintf '%9.2g', $sro / 25.4;
}

print TEMP "<center><br>
  <table cellspacing=8 bgcolor='ivory'>
   <tr>
    <th colspan=5 bgcolor=#ccffff>
     $years2sim - YEAR MEAN ANNUAL AVERAGES
    </th>
   </tr>
     <tr>
      <td colspan=3></td>
      <th colspan=2><font size=-1>Total in<br>$years2sim years</font></th>
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

if ($verbose) {
    print TEMP "\nParse WEPP event output EVO file: $eventFile<br>\n";
}

#   @selected_ranks = (5,10,20,50);

sub numerically { $a <=> $b }

$evo_file = "<$eventFile";

open EVO, $evo_file;
while (<EVO>) {    # skip past header lines

    #      if ($_ =~ /------/) {last}
    if ( $_ =~ /---/ ) { last }
}

# testing here ###
print TEMP $_ if ($zoop);    # verify location

$keep = <EVO>;
( $day1, $month1, $year1, $precip1, $runoff1, $rest1 ) = split ' ', $keep, 6;
$runoff1 += 0;
$year1   += 0;               # force to numeric
@max_run[$yr] = $keep;       # store as best so far 2004.09.15
@run_off[$yr] = $runoff1;    # store as best so far 2004.09.15

# testing here ###
print TEMP "day: $day1\tmonth: $month1\tyear: $year1\trunoff:$runoff1\n"
  if ($zoop);

# testing here ###
print TEMP "$evo_file -- maximal runoff event for year, sorted by year\n\n"
  if ($zoop);

while (<EVO>) {
    ( $day, $month, $year, $precip, $runoff, $rest ) = split ' ', $_, 6;
    $runoff += 0;
    $year   += 0;               # force to numeric
    if ( $year == $year1 ) {    # same year
        if ( $runoff > $runoff1 ) {    # new runoff larger
            $keep         = $_;        # keep the new one
            $runoff1      = $runoff;
            @max_run[$yr] = $keep;
            @run_off[$yr] = $runoff;
        }
        else {                         # new runoff small
        }
    }
    else {                             # new year

        # testing here ###
        print TEMP $keep if ($zoop);    # print last year's max runoff entry
        $yr++;
        $keep         = $_;             # update this year's starting line
        @max_run[$yr] = $keep;
        @run_off[$yr] = $runoff;
        $year1        = $year;          # update year
        $runoff1      = $runoff;        # update this year's first runoff
    }
}

# handle final year
if ( $runoff > $runoff1 ) {    # new runoff larger
    $keep         = $_;        # keep the new one
    $runoff1      = $runoff;
    @max_run[$yr] = $keep;
    @run_off[$yr] = $runoff;
}

# testing here ###
print TEMP $keep      if ($zoop);    # print final year's max runoff entry
print TEMP "\n<br>\n" if ($zoop);
close EVO;

if ($debug) { $, = " "; print TEMP "\n", @run_off, "\n"; $, = ""; }

# index-sort runoff		# index sort from "Efficient FORTRAN Programming"
# see built-in index sort elsewhere in code...

$years = $#run_off;
for $i ( 0 .. $years ) { @indx[$i] = $i }    # set up initial index into array
for $i ( 0 .. $years - 1 ) {
    $m = $i;
    for $j ( $i + 1 .. $years ) {
        $m = $j if $run_off[ $indx[$j] ] > $run_off[ $indx[$m] ];
    }
    $temp     = $indx[$m];
    $indx[$m] = $indx[$i];
    $indx[$i] = $temp;
}

if ($debug) {
    print TEMP "<br>\n -- maximal runoff for each year, sorted by runoff\n\n";
}

# print TEMP $#run_off;
# testing here ###
if ($zoop) {
    for $i ( 0 .. $years ) { print TEMP @run_off[ $indx[$i] ], "  " }
    print TEMP "\n\n<p>";
    $, = "<br>";
    for $i ( 0 .. $years ) { print TEMP @max_run[ $indx[$i] ] }
}

####****###

# select [5th, 10th, 20th, 50th, 75th] largest runoff event lines

$years1         = $years + 1;             #  Number of years with runoff
@selected_ranks = ( 5, 10, 20, 50, 75 )
  ;    # 2005.09.30 If too few, do we have to adjust percentages?

#								# keep all ranks for unBurned batch *** 2015 DEH
#  @selected_ranks = (5,10,20,50) if ($years1<75);		# 2005.09.30
#  @selected_ranks = (5,10,20)    if ($years1<50);
#  @selected_ranks = (5,10)       if ($years1<20);
#  @selected_ranks = (5)          if ($years1<10);
#  @selected_ranks = ()           if ($years1<5);

# print TEMP "<p>Runoff events range from ",@run_off[$indx[0]]," down to ",@run_off[$indx[$years]]," mm\n";
# print TEMP '<br>',@years2run,"<br>\n";
print TEMP "<br>$years1 years out of 100 had runoff events.<br>\n"
  if ( $years < 50 );
if ($debug) {
    print TEMP "<br>Runoff events (mm)\n<br><font size=-2><pre>";
    foreach $runner ( 0 .. $years ) {
        print TEMP @run_off[ $indx[$runner] ], @max_run[ $indx[$runner] ];
    }
    print TEMP "</pre><font>\n";
}

for $i ( 0 .. $#selected_ranks ) {
    @selected_ranks[$i] -= 1;    # account for base zero
    ( $day, $month, $year, $precip, $runoff, $rest ) = split ' ',
      @max_run[ $indx[ $selected_ranks[$i] ] ], 6;
    if ( $year + 0 > 0 ) {    # DEH crash fix start if too few events 2004.09.13
        (
            $interrill_det, $avg_det, $max_det,
            $det_pt,        $avg_dep, $max_dep,
            $dep_pt,        $sed_del, $enrich
        ) = split ' ', $rest;
        @sed_delivery[$i]  = $sed_del;
        @precip[$i]        = $precip;
        @day[$i]           = $day;
        @month[$i]         = $month;
        @selected_year[$i] = $year;
        @previous_year[$i] = $year - 1;    # DEH 2003/11/20 ***
        if ( $year == 1 ) { @previous_year[$i] = $year }
        ;                                  # DEH 2003/11/20 ***
    }
}

#print TEMP "@selected_ranks\n";

( $max_day, $max_month, $max_year, $precip, $runoff, $rest ) = split ' ',
  @max_run[ @indx[0] ], 6;
(
    $interrill_det, $avg_det, $max_det, $det_pt, $avg_dep,
    $max_dep,       $dep_pt,  $sed_del, $enrich
) = split ' ', $rest;
@monthnames = (
    '',     'January', 'February', 'March',     'April',   'May',
    'June', 'July',    'August',   'September', 'October', 'November',
    'December'
);

#### 2003 units
if ( $units eq 'ft' ) {

    #        $run_off_f = sprintf '%9.2f', @run_off[$indx[0]]/25.4;
    $run_off_f = sprintf '%9.2f', $runoff / 25.4;
    $precip_f  = sprintf '%9.2f', $precip / 25.4;
    $sed_del_f = sprintf '%9.2f', $sed_del / $hillslope_length_m * 4.45;

    # kg per m / m length * 4.45 --> t per ac
}
else {
    #        $run_off_f = @run_off[$indx[0]];
    $run_off_f = $runoff;
    $precip_f  = $precip;
    $sed_del_f = $sed_del / $hillslope_length * 10;

    # kg per m / m length * 10 --> t per ha
}
#### 2003 units

###############ZZZZZZZZZZZZZZZZZZZZZ################

@years2run = sort numerically @selected_year, @previous_year;
if ($debug) { print TEMP "\nYears to run: @years2run\n"; }

# remove duplicates / clean up

# $year_count = $#years2run;
$year_count = 1;    # count unique years
for $i ( 1 .. $#years2run ) {
    $year_count += 1 if ( @years2run[$i] ne @years2run[ $i - 1 ] );
}
if ($debug) { print TEMP "<br>$year_count unique years<br></center>\n"; }

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

    my $monsoon = 0;

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

    my (
        $objan, $obfeb, $obmar, $obapr, $obmay, $objun,
        $objul, $obaug, $obsep, $oboct, $obnov, $obdec
    );

    my $cliver = <INCLI>;
    chomp $cliver;
    my $trio    = <INCLI>;
    my $station = <INCLI>;    # chomp $station; $station=substr($station,13,46);
    my $header  = <INCLI>;
    my $line    = <INCLI>;

    # ($lat,$lon,$ele,$yobs,$ybeg,$ysim,$rest)=split ' ', $line;
    $line = <INCLI>;
    $line = <INCLI>;
    $line = <INCLI>;
    $line = <INCLI>;
    $line = <INCLI>;
    $line = <INCLI>;
    $line = <INCLI>;
    $line = <INCLI>;          # Observed monthly ave precipitation (mm)
    close INCLI;

    (
        $objan, $obfeb, $obmar, $obapr, $obmay, $objun,
        $objul, $obaug, $obsep, $oboct, $obnov, $obdec
    ) = split ' ', $line;
    $obannual =
      $objan + $obfeb + $obmar + $obapr + $obmay + $objun + $objul + $obaug +
      $obsep + $oboct + $obnov + $obdec;
    $obJAS = $objul + $obaug + $obsep;

    #  print "$station\n$ysim years  CLIGEN version $cliver\n";
    #  print "Observed annual precip: $obannual mm\n";
    #  print "Observed JAS precip:    $obJAS mm\n";
    $pctJAS = 0;
    if ( $obannual > 0.00001 ) {
        $pctJAS = 100 * $obJAS / $obannual;
        $pctJAS = sprintf '%.2f', $pctJAS;

        #  print "Percent JAS precip:     $pctJAS\n";
        if ( $obannual < 600 && $pctJAS > 30 ) { $monsoon = 1 }
    }
  bailer:
    return $monsoon;
###### 2005.09.16 DEH Look for monsoonal climates end
}

$monsoon = &monsoonal;
###  $monsoon=1;	# TEMP !!!

open INCLI,  "<$CLIfile" or goto bail;
open OUTCLI, ">$shortCLIfile";

for $i ( 0 .. 3 ) {
    $line = <INCLI>;
    print OUTCLI $line;
}

#  Latitude Longitude Elevation (m) Obs. Years   Beginning year  Years simulated
#    21.98  -159.35          36          43           1             100
$line = <INCLI>;
chomp $line;
( $lat, $long, $elev, $obs_yrs, $beg_year, $years_sim ) = split ' ', $line;
$beg_year = @years2run[0];

#  $years_sim = $#years2run;
print OUTCLI
"   $lat  $long       $elev           $obs_yrs          $beg_year              $year_count\n";
for $i ( 5 .. 14 ) {
    $line = <INCLI>;
    print OUTCLI $line;
}

if ($debug) { print TEMP " running @years2run<br>\n" }
$numyears = $#years2run;
$lastyear = 0;             # prime starting year
$dumb     = '31 12 0';     # prime last year's final day entry da mo yr
for $i ( 0 .. $numyears ) {
    $mythisyear = @years2run[$i];
    if (
        $mythisyear eq '' ||    # blank if beyond number of years with events
        $mythisyear < 1   ||    # year = -1 if no previous year in event file
        $mythisyear == $lastyear
      )
    {
        if ($debug) { print TEMP "Bailing on $mythisyear\n" }
        next;
    }    # bail
    else {
        if ($debug) { print TEMP "<br>Seeking year $mythisyear:  "; }

        #      print TEMP "<br>Seeking year $mythisyear:  ";
        $yeardiff = $mythisyear - $lastyear;
        $lastyear = $mythisyear;               # prepare next year's lastyear

    #      last if $yeardiff < 1;		# should have been taken care of: sort & same
        $daydiff = 364 * ( $yeardiff - 1 );    # ignoring leaps for now
        if ($debug) { print TEMP "daydiff: $daydiff\n"; }
        for $day ( 1 .. $daydiff ) {
            $dumb = <INCLI>;    # skip to near start of correct year

            #       print TEMP "skipping $dumb";
        }

        # find start of year
      nextday:
        ( $da, $mo, $yr, $rest ) = split ' ', $dumb;

        #      print TEMP "$da $mo $yr\n";
        if ( $mo < 12 ) { $dumb = <INCLI>; goto nextday }
        if ( $da < 31 ) { $dumb = <INCLI>; goto nextday }

# @@@@@@@@@@@@@
#      $my_index = -1;
#      for $k (0..$#selected_year) {  print TEMP "$yr @selected_year[$k]<br>\n";
#        if ($yr+2 == @selected_year[$k]) {
#          $my_index = $k;
#          print TEMP "Year: $yr+2, Index $my_index<br>\n";    # @@@@@@@
#        }
#      }
        for $day ( 1 .. 364 ) {
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
        ( $da, $mo, $yr, $pcpp, $durr, $tp, $ip, $rest ) = split ' ',
          $line;    # DEH duration 0404022
        while ( $da < 31 ) {
            $line = <INCLI>;

            #       print "$yr leap\n";
            print OUTCLI $line;
            ( $da, $mo, $yr, $pcpp, $durr, $tp, $ip, $rest ) = split ' ',
              $line;    # DEH duration 040422
        }
    }
}

close INCLI;
close OUTCLI;

if ($wgr) {    # DEH 040316

#    @args = "cp $shortCLIfile /var/www/html/fswepp/working/wepp.cli";	# DEH 040316
#    system @args;							# DEH 040316
    `cp $CLIfile /var/www/html/fswepp/working/wepp100.cli`;         # DEH 040422
    `cp $shortCLIfile /var/www/html/fswepp/working/wepp.cli`;       # DEH 040316
    `cp data/high100.man /var/www/html/fswepp/working/high100.man`; # DEH 040316
    `cp data/1ofe.man /var/www/html/fswepp/working/1ofe.man`;       # DEH 040318
    `cp data/2ofe.man /var/www/html/fswepp/working/2ofe.man`;       # DEH 040318
    `cp data/3ofe.man /var/www/html/fswepp/working/3ofe.man`;       # DEH 040318
    `cp $eventFile /var/www/html/fswepp/working/event100`;          # DEH 040913
}    # DEH 040316

skip:
###############ZZZZZZZZZZZZZZZZZZZZZ################

$durr    = '-';
$lookfor = sprintf ' %2d %2d  %3d ', $max_day, $max_month, $max_year;

#  print TEMP "[$lookfor]";

open CLIMATE, "<$CLIfile";

# open CLIMATE, "<$shortCLIfile";
while (<CLIMATE>) {
    if ( $_ =~ $lookfor ) {
        ( $d_day, $d_month, $d_year, $d_pcp, $durr, $tp, $ip ) = split ' ',
          $_;    # DEH 040422
        last;
    }
}
close CLIMATE;

$i10w          = 0;             # weighted i10 2005.10.18 DEH
@max_time_list = ( 10, 30 );    # target durations times (min)
$prcp          = $d_pcp;
$dur           = $durr;
$ip *= 0.7;                     # 2005.10.12 DEH counteract WEPP fudge factor
&peak_intensity;

if ( $units eq 'ft' ) {
    @i_peak[0] = sprintf '%9.2f', @i_peak[0] / 25.4 if ( @i_peak[0] ne 'N/A' );
    @i_peak[1] = sprintf '%9.2f', @i_peak[1] / 25.4 if ( @i_peak[1] ne 'N/A' );
}
else {
    @i_peak[0] = sprintf '%9.2f', @i_peak[0] if ( @i_peak[0] ne 'N/A' );
    @i_peak[1] = sprintf '%9.2f', @i_peak[1] if ( @i_peak[1] ne 'N/A' );
}

#    if (@i_peak[0] eq 'N/A' || @i_peak[1] eq 'N/A') {
#      $tp='--'; $ip='--';				# 2004.09.13
#    }

print TEMP "<p>
       <table border=1 cellpadding=8 bgcolor='ivory'>
        <tr>
         <th colspan=7>
          Rainfall Event Rankings and Characteristics from the Selected Storms
         </th>
        </tr>
        <tr>
         <th bgcolor='#ccffff'><font size=-2>Storm Rank<br>based on runoff<br>(return interval)</font></th>
         <th bgcolor='#ccffff'><font size=-2>Storm<br>Runoff<br>($precipunits)</font></th>
         <th bgcolor='#ccffff'><font size=-2>Storm<br>Precipitation<br>($precipunits)</font></th>
         <th bgcolor='#ccffff'><font size=-2>Storm<br>Duration<br>(h)</font></th>
         <!-- th bgcolor='#ffddff' --><!-- tp --><!-- br --><!-- (fraction) -->        <!-- 2005.10.17 -->
         <!-- th bgcolor='#ffddff' --><!-- ip --><!-- br --><!-- (ratio) -->
         <th bgcolor='#ccffff'><font size=-2>10-min<br>Peak Rainfall Intensity<br>($intunits)</font></th>
         <th bgcolor='#ccffff'><font size=-2>30-min<br>Peak Rainfall Intensity<br>($intunits)</font></th>
         <th bgcolor='#ccffff'><font size=-2>Storm Date</font></th>
        </tr>
        <tr>
         <th bgcolor='#ccffff'><font size=-2>1</font></th>
         <td align=right><font size=-2>$run_off_f</font></td>
         <td align=right><font size=-2>$precip_f</font></td>
         <td align=right><font size=-2>$durr</font></td>
         <!-- td align=right --><!-- $tp --><!-- /td -->	<!-- 2005.10.17 -->
         <!-- td align=right --><!-- $ip --><!-- /td -->
         <td align=right><font size=-2>@i_peak[0]</font></td>
         <td align=right><font size=-2>@i_peak[1]</font></td>
         <td align=right><font size=-2>@monthnames[$max_month]&nbsp;$max_day<br>year $max_year</font></td>
        </tr>
";

#   @color[0]="'#ff33ff'"; @color[1]="'#ff66ff'"; @color[2]="'#ff99ff'";
#   @color[3]="'#ffaaff'"; @color[4]="'#ffccff'"; @color[5]="'#ffddff'";
#   @color[0]="#3388ff"; @color[1]="#3399ff"; @color[2]="#33aaff";
#   @color[3]="#33bbff"; @color[4]="#33ccff"; @color[5]="#33ddff";
@color[0] = "#ccffff";
@color[1] = "#ccffff";
@color[2] = "#ccffff";
@color[3] = "#ccffff";
@color[4] = "#ccffff";
@color[5] = "#ccffff";

@probClimate = ( 0.075, 0.075, 0.20, 0.275, 0.375 )
  ;    # rank 5, 10, 20, 50, 75  DEH 2005.09.30 10.18 move up

#### 2015.04.06 DEH shorten table so duplicates don't show if insufficient storms had runoff

#  @selected_ranks = (5,10,20,50) if ($years1<75);              # 2005.09.30
#  @selected_ranks = (5,10,20)    if ($years1<50);
#  @selected_ranks = (5,10)       if ($years1<20);
#  @selected_ranks = (5)          if ($years1<10);
#  @selected_ranks = ()           if ($years1<5);

$s_r = 4;
$s_r = 3  if ( $years1 < 75 );
$s_r = 2  if ( $years1 < 50 );
$s_r = 1  if ( $years1 < 20 );
$s_r = 0  if ( $years1 < 10 );
$s_r = -1 if ( $years1 < 5 );

#      for $i (0..$#selected_ranks) {
for $i ( 0 .. $s_r ) {

    $durr    = '--';
    $lookfor = sprintf ' %2d %2d  %3d ', @day[$i], @month[$i],
      @selected_year[$i];

    #        print TEMP "[$lookfor]";

    #       open CLIMATE, "<$CLIfile";
    open CLIMATE, "<$shortCLIfile";
    while (<CLIMATE>) {
        if ( $_ =~ $lookfor ) {
            ( $d_day, $d_month, $d_year, $d_pcp, $durr, $tp, $ip ) = split ' ',
              $_;    # DEH 040422
            last;
        }
    }
    close CLIMATE;

### duration DEH 040422 Earth Day 2004
    #   @max_time_list = (10, 30);			# target durations times (min)
    $prcp = $pcpp;
    $prcp = $d_pcp;
    $dur  = $durr;
    $ip *= 0.7;    # 2005.10.12 DEH counteract WEPP fudge factor
    &peak_intensity;

    #      returns peak intensities (mm/h) or 'N/A' in @i_peak
    #      returns $error_text
### duration DEH 040422

    # #### 2003 units
    if ( $units eq 'ft' ) {
        $run_off_f = sprintf '%9.2f',
          @run_off[ $indx[ @selected_ranks[$i] ] ] / 25.4;

        #zxc    $run_off_f = sprintf '%9.2f', @runoff[$i]/25.4;
        $precip_f       = sprintf '%9.2f', @precip[$i] / 25.4;
        $sed_delivery_f = @sed_delivery[$i];
        $sed_delivery_f = sprintf '%9.2f',
          $sed_delivery_f / $hillslope_length_m * 4.45;
        $i10w += @probClimate[$i] * @i_peak[0]
          if ( @i_peak[0] ne 'N/A' );    # 2005.10.20 DEH
        @i_peak[0] = sprintf '%9.2f', @i_peak[0] / 25.4
          if ( @i_peak[0] ne 'N/A' );
        @i_peak[1] = sprintf '%9.2f', @i_peak[1] / 25.4
          if ( @i_peak[1] ne 'N/A' );
    }
    else {
        $run_off_f = @run_off[ $indx[ @selected_ranks[$i] ] ];

        #zxc    $run_off_f = @runoff[$i];
        $precip_f       = @precip[$i];
        $sed_delivery_f = @sed_delivery[$i];
        $sed_delivery_f = $sed_delivery_f / $hillslope_length * 10;
        @i_peak[0] = sprintf '%9.2f', @i_peak[0] if ( @i_peak[0] ne 'N/A' );
        @i_peak[1] = sprintf '%9.2f', @i_peak[1] if ( @i_peak[1] ne 'N/A' );
        $i10w += @probClimate[$i] * @i_peak[0]
          if ( @i_peak[0] ne 'N/A' );    # 2005.10.18 DEH
    }

    #    if (@i_peak[0] eq 'N/A' || @i_peak[1] eq 'N/A') {
    #      $tp='--'; $ip='--';				# 2004.09.13
    #    }

    # #### 2003 units
    $yrs = sprintf '%.0f', ( 100 / ( @selected_ranks[$i] + 1 ) );
    if ( @selected_ranks[$i] == 74 ) {
        $yrs = '1<sup>1</sup>/<sub>3</sub>';
    }    # 2005.10.20 DEH
    print TEMP "            <tr>
             <th bgcolor='@color[$i]'><font size=-2><a onMouseOver=\"window.status='",
      @probClimate[$i] * 100,
"% probability';return true\" onMouseOut=\"window.status=''; return true\">",
      @selected_ranks[$i] + 1, "</a><br>($yrs-year)</font></th>
             <td align=right><font size=-2><b>$run_off_f</b></font></td>
             <td align=right><font size=-2><b>$precip_f</b></font></td>
             <td align=right><font size=-2><b>$durr</b></font></td>
             <!-- td align=right --><!-- b --><!-- $tp --><!-- /b --><!-- /td -->        <!-- 2005.10.17 -->
             <!-- td align=right --><!-- b --><!-- $ip --><!-- /b --><!-- /td -->
             <td align=right><font size=-2><b>@i_peak[0]</b></font></td>
             <td align=right><font size=-2><b>@i_peak[1]</b></font></td>
";
    if ( @selected_year[$i] ne '' ) {
        print TEMP "
             <td align=right><font size=-2><b>@monthnames[@month[$i]]&nbsp;@day[$i]<br>year @selected_year[$i]</b></font></td>
";
    }
    print TEMP "
            </tr>
";
}

( $min_day, $min_month, $min_year, $precip, $runoff, $rest ) = split ' ',
  @max_run[ @indx[$years] ], 6;
(
    $interrill_det, $avg_det, $max_det, $det_pt, $avg_dep,
    $max_dep,       $dep_pt,  $sed_del, $enrich
) = split ' ', $rest;

$durr    = '--';
$lookfor = sprintf ' %2d %2d  %3d ', $min_day, $min_month, $min_year;

#     print TEMP "[$lookfor]";

open CLIMATE, "<$CLIfile";
while (<CLIMATE>) {

    $d_day   = 0;
    $d_month = 0;
    $d_year  = 0;
    $d_pcp   = 0;
    $durr    = 0;
    $tp      = 0;
    $ip      = 0;
    if ( $_ =~ $lookfor ) {
        ( $d_day, $d_month, $d_year, $d_pcp, $durr, $tp, $ip ) = split ' ',
          $_;    # DEH 040422
        last;
    }
}
close CLIMATE;

$prcp = $d_pcp;
$dur  = $durr;
&peak_intensity;

if ( @run_off[ $indx[$years] ] eq '' ) {
    $run_off_f = ' -- ';
    $precip_f  = ' -- ';
    $sed_del_f = ' -- ';
}
elsif ( $units eq 'ft' ) {
    $run_off_f = sprintf '%9.2f', @run_off[ $indx[$years] ] / 25.4;
    $precip_f  = sprintf '%9.2f', $precip / 25.4;
    $sed_del_f = sprintf '%9.2f', $sed_del / $hillslope_length_m * 4.45;
    @i_peak[0] = sprintf '%9.2f', @i_peak[0] / 25.4 if ( @i_peak[0] ne 'N/A' );
    @i_peak[1] = sprintf '%9.2f', @i_peak[1] / 25.4 if ( @i_peak[1] ne 'N/A' );
}
else {
    $run_off_f = @run_off[ $indx[$years] ];
    $precip_f  = $precip;
    $sed_del_f = $sed_del / $hillslope_length * 10;
    @i_peak[0] = sprintf '%9.2f', @i_peak[0] if ( @i_peak[0] ne 'N/A' );
    @i_peak[1] = sprintf '%9.2f', @i_peak[1] if ( @i_peak[1] ne 'N/A' );
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

$a = 0;    # dummy

# ------------------------ flow 5 --------------------------------

# ermit flow

# climate selected
# soil selected			["clay loam" "silt loam" "sandy loam" "loam"]
# vegetation type selected	["forest" "range" "chaparral"]
# topography specified		["surface slope average" "surface slope at toe" "surface length"]
# soil burn severity class selected	["U" "L" "M" "H"]	# 2013

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

@monthnames = (
    '',     'January', 'February', 'March',     'April',   'May',
    'June', 'July',    'August',   'September', 'October', 'November',
    'December'
);

#   $data = 'data/';
#   $working = 'working/';

#  $SlopeFileName = 'slope.slp';
#  $SlopeFilePath = $workingpath . $SlopeFileName;
#  $slopeFilePath = $workingpath . '.slp';
#  $stoutFilePath = $workingpath . 'stout';
#  $sterrFilePath = $workingpath . 'sterr';

$climateFile = $shortCLIfile;

if ($debug) {
    print TEMP "<br>
    climateFile: $climateFile<br>
    slopeFile:  $slopeFile<br>
    management file: $manFile<br>
    evoFile: $evoFile<br>
    ev_by_evFile: $ev_by_evFile<br>
    ";
}

#  @probClimate = (0.075, 0.075, 0.20, 0.275, 0.375);	# rank 5, 10, 20, 50, 75  DEH 2005.09.30
### unburned ###
if ( lc($severityclass) eq 'u' ) {

    # unburned
    @probSoil0 = ( 0.10, 0.20, 0.40, 0.20, 0.10 );    # year 0
    @probSoil1 = ( 0.10, 0.20, 0.40, 0.20, 0.10 );    # year 1
    @probSoil2 = ( 0.10, 0.20, 0.40, 0.20, 0.10 );    # year 2
    @probSoil3 = ( 0.10, 0.20, 0.40, 0.20, 0.10 );    # year 3
    @probSoil4 = ( 0.10, 0.20, 0.40, 0.20, 0.10 );    # year 4
}
else {
    # untreated
    @probSoil0 = ( 0.10, 0.20, 0.40, 0.20,  0.10 );    # year 0
    @probSoil1 = ( 0.30, 0.30, 0.20, 0.19,  0.01 );    # year 1
    @probSoil1 = ( 0.12, 0.21, 0.38, 0.195, 0.095 )
      if ($monsoon);                                   # year 1 # 2005.09.30 DEH
    @probSoil2 = ( 0.50, 0.30, 0.18, 0.01, 0.01 );     # year 2
    @probSoil3 = ( 0.60, 0.30, 0.08, 0.01, 0.01 );     # year 3
    @probSoil4 = ( 0.70, 0.27, 0.01, 0.01, 0.01 );     # year 4

    # seeding
    @probSoil_s0 = ( 0.10, 0.20, 0.40, 0.20, 0.10 );    # year 0
    @probSoil_s1 = ( 0.50, 0.30, 0.18, 0.01, 0.01 );    # year 2
    @probSoil_s2 = ( 0.60, 0.30, 0.08, 0.01, 0.01 );    # year 3
    @probSoil_s3 = ( 0.70, 0.27, 0.01, 0.01, 0.01 );    # year 4
    @probSoil_s4 = ( 0.70, 0.27, 0.01, 0.01, 0.01 );    # year 4

   # mulching 27% ground cover (1/2 Mg/ha; ~1/4 ton/ac)		# 2005.09.30 DEH
   #   @probSoil_mh0 = (0.30, 0.40, 0.20, 0.09, 0.01); # year 0	# 2005.09.30 DEH
   #   @probSoil_mh1 = (0.40, 0.35, 0.20, 0.04, 0.01); # year 1	# 2005.09.30 DEH
   #   @probSoil_mh2 = (0.50, 0.30, 0.18, 0.01, 0.01); # year 2	# 2005.09.30 DEH
   #   @probSoil_mh3 = (0.60, 0.30, 0.08, 0.01, 0.01); # year 3	# 2005.09.30 DEH
   #   @probSoil_mh4 = (0.70, 0.27, 0.01, 0.01, 0.01); # year 4	# 2005.09.30 DEH
   # mulching 47% ground cover (1 Mg/ha; ~1/2 ton/ac)		# 2005.09.30 DEH
    @probSoil_m470 = ( 0.70, 0.20, 0.08, 0.01, 0.01 ); # year 0	# 2005.09.30 DEH
    @probSoil_m471 = ( 0.60, 0.25, 0.13, 0.01, 0.01 ); # year 1	# 2005.09.30 DEH
    @probSoil_m472 = ( 0.50, 0.30, 0.18, 0.01, 0.01 ); # year 2	# 2005.09.30 DEH
    @probSoil_m473 = ( 0.60, 0.30, 0.08, 0.01, 0.01 ); # year 3	# 2005.09.30 DEH
    @probSoil_m474 = ( 0.70, 0.27, 0.01, 0.01, 0.01 ); # year 4	# 2005.09.30 DEH

  # mulching 62% ground cover (1-1/2 Mg/ha; ~2/3 ton/ac)		# 2005.09.30 DEH
  #   @probSoil_moh0 = (0.80, 0.10, 0.08, 0.01, 0.01); # year 0	# 2005.09.30 DEH
  #   @probSoil_moh1 = (0.65, 0.20, 0.13, 0.01, 0.01); # year 1	# 2005.09.30 DEH
  #   @probSoil_moh2 = (0.50, 0.30, 0.18, 0.01, 0.01); # year 2	# 2005.09.30 DEH
  #   @probSoil_moh3 = (0.60, 0.30, 0.08, 0.01, 0.01); # year 3	# 2005.09.30 DEH
  #   @probSoil_moh4 = (0.70, 0.27, 0.01, 0.01, 0.01); # year 4	# 2005.09.30 DEH
  # mulching 72% ground cover (2 Mg/ha; ~1 ton/ac)		# 2005.09.30 DEH
    @probSoil_m720 = ( 0.90, 0.07, 0.01, 0.01, 0.01 ); # year 0	# 2005.09.30 DEH
    @probSoil_m721 = ( 0.70, 0.20, 0.08, 0.01, 0.01 ); # year 1	# 2005.09.30 DEH
    @probSoil_m722 = ( 0.50, 0.30, 0.18, 0.01, 0.01 ); # year 2	# 2005.09.30 DEH
    @probSoil_m723 = ( 0.60, 0.30, 0.08, 0.01, 0.01 ); # year 3	# 2005.09.30 DEH
    @probSoil_m724 = ( 0.70, 0.27, 0.01, 0.01, 0.01 ); # year 4	# 2005.09.30 DEH

    # mulching 89% ground cover (3-1/2 Mg/ha; ~1-1/2 ton/ac)	# 2005.09.30 DEH
    @probSoil_m890 = ( 0.93, 0.04, 0.01, 0.01, 0.01 ); # year 0	# 2005.09.30 DEH
    @probSoil_m891 = ( 0.77, 0.15, 0.06, 0.01, 0.01 ); # year 1	# 2005.09.30 DEH
    @probSoil_m892 = ( 0.50, 0.30, 0.18, 0.01, 0.01 ); # year 2	# 2005.09.30 DEH
    @probSoil_m893 = ( 0.60, 0.30, 0.08, 0.01, 0.01 ); # year 3	# 2005.09.30 DEH
    @probSoil_m894 = ( 0.70, 0.27, 0.01, 0.01, 0.01 ); # year 4	# 2005.09.30 DEH

    # mulching 94% ground cover (4-1/2 Mg/ha; ~2 ton/ac)		# 2005.09.30 DEH
    @probSoil_m940 = ( 0.96, 0.01, 0.01, 0.01, 0.01 ); # year 0	# 2005.09.30 DEH
    @probSoil_m941 = ( 0.78, 0.16, 0.04, 0.01, 0.01 ); # year 1	# 2005.09.30 DEH
    @probSoil_m942 = ( 0.50, 0.30, 0.18, 0.01, 0.01 ); # year 2	# 2005.09.30 DEH
    @probSoil_m943 = ( 0.60, 0.30, 0.08, 0.01, 0.01 ); # year 3	# 2005.09.30 DEH
    @probSoil_m944 = ( 0.70, 0.27, 0.01, 0.01, 0.01 ); # year 4	# 2005.09.30 DEH
}
if ( lc($severityclass) eq "h" ) {

    #    @severe = ("hhh", "lhh", "hlh", "hhl");
    @severe      = ( "hhh", "lhh", "hlh", "hhl", "llh", "lhl", "hll", "lll" );
    @probspatial = (
        [ 0.10, 0.30, 0.30, 0.30, 0.00, 0.00, 0.00, 0.00 ],
        [ 0.00, 0.25, 0.25, 0.25, 0.25, 0.00, 0.00, 0.00 ],
        [ 0.00, 0.00, 0.25, 0.25, 0.25, 0.25, 0.00, 0.00 ],
        [ 0.00, 0.00, 0.00, 0.25, 0.25, 0.25, 0.25, 0.00 ],
        [ 0.00, 0.00, 0.00, 0.00, 0.25, 0.25, 0.25, 0.25 ]
    );
}
if ( lc($severityclass) eq "m" ) {

    #    @severe = ("hlh", "hhl", "llh", "lhl");
    @severe      = ( "hlh", "hhl", "llh", "lhl", "hll", "lll" );
    @probspatial = (
        [ 0.25, 0.25, 0.25, 0.25, 0.00, 0.00 ],
        [ 0.00, 0.25, 0.25, 0.25, 0.25, 0.00 ],
        [ 0.00, 0.00, 0.25, 0.25, 0.25, 0.25 ],
        [ 0.00, 0.00, 0.25, 0.25, 0.25, 0.25 ],
        [ 0.00, 0.00, 0.25, 0.25, 0.25, 0.25 ]
    );
}
if ( lc($severityclass) eq "l" ) {
    @severe      = ( "llh", "lhl", "hll", "lll" );
    @probspatial = (
        [ 0.30, 0.30, 0.30, 0.10 ],
        [ 0.25, 0.25, 0.25, 0.25 ],
        [ 0.25, 0.25, 0.25, 0.25 ],
        [ 0.25, 0.25, 0.25, 0.25 ],
        [ 0.25, 0.25, 0.25, 0.25 ]
    );
}
if ( lc($severityclass) eq "u" ) {    # 2013.04.19 DEH
    @severe      = ("uuu");
    @probspatial = ( [1.0], [1.0], [1.0], [1.0], [1.0] );
}

if ($debug) { print TEMP "  Severity class '$severityclass'\n" }
if ($debug) { print TEMP '  <pre><font face="courier new, courier"><br>', "\n" }

#  for $sn (0..3) {
for $sn ( 0 .. $#severe ) {    # 2005.10.13 DEH

    $s = @severe[$sn];         # 2005.10.13 DEH
## 	@severe = (LLL, HLL, LHL, LLH), (LHL, LLH, LHH, HLH), (LHH, HLH, HHL, HHH)
    #       @severe = ("hhh", "lhh", "hlh", "hhl", "llh", "lhl", "hll", "lll");
    #       @severe = ("hlh", "hhl", "llh", "lhl", "hll", "lll");
    #       @severe = ("llh", "lhl", "hll", "lll");
    #       @severe = ("uuu");						# 2013.04.19 DEH

    &lhtoab;

    #    print TEMP "\n$s: $nofe OFEs\n" ;

    open SLOPE, ">$slopeFile";
    $mySlopeFile = &createSlopeFile;    # DEH 040316

    #      print SLOPE &createSlopeFile;					# DEH 040316
    print SLOPE $mySlopeFile;           # DEH 040316
    close SLOPE;
    if ($wgr) {                         # DEH 040316
        open TempSlp, ">/var/www/html/fswepp/working/wepp$sn.slp";  # DEH 040316
        print TempSlp $mySlopeFile;                                 # DEH 040316
        close TempSlp;                                              # DEH 040316
    }    # DEH 040316

    &createVegFile;
    $manFile = $datapath . $manFileName;
    if ($debug) {
        print TEMP
          "createVegFile: $manFile -- $severityclass -- $vegtype<br>\n";
    }

    #  for $k (0..0) {   #ZZ#
    for $k ( 0 .. 4 ) {    #   for conductivity (k) = (u1..u5; l1..l5; h1..h5)
        open SOL, ">$soilFile";
        $mySoilFile = &createsoilfile;    # DEH 040316
        print SOL $mySoilFile;            # DEH 040316
        close SOL;

        if ($wgr) {                       # DEH 040316
            open TempSol,
              ">/var/www/html/fswepp/working/wepp$sn-$k.sol";    # DEH 040316
            print TempSol $mySoilFile;                           # DEH 040316
            close TempSol;                                       # DEH 040316
        }

        &createResponseFile;    # create WEPP response file

        #            run WEPP on climate file (4 to 16 years)
        @args = ("../$weppversion <$responseFile >$stoutFile 2>$sterrFile")
          if ($wgr);            # compaction
        print TEMP "@args\n" if $debug;
        system @args;

        if ($debug) { $printfilename = $sterrFile; &printfile }

        foreach (@filetext) {    # iterate the array
            if (m/Error/g) {
                print TEMP "Dagblarnit if WEPP didn't crash!";
                goto bail;

                #      next KLOOP;		# 2005.10.29 DEH
            }
        }

        #        pull out 5 sediment deliveries from WEPP output
        #		store one tables by year
        @seds = &get_event_seds;

        if ($verbose) {

       #         $severity_event_path = $s . '_events.out';
       #         @args = ("copy $ev_by_evFile $severity_event_path");	# TEMP DEH
       #         system @args;						# TEMP DEH

            print TEMP '<br>', "\n";
            print TEMP "Severity $sn ('$s')\n Conductivity $k\n";
            print TEMP "\tDay\tMonth\tYear\tSedDel\n";
        }

        for $i ( 0 .. $#selected_year ) {
            $sedtable[$i][$k][$sn] = @seds[$i];
            if ($verbose) {
                print TEMP "\t", @day[$i], "\t", @month[$i], "\t",
                  @selected_year[$i], "\t", @seds[$i], "\n";
            }
        }
    }    # Loop (k)
}    # Loop (s)

if ($debug) {
    print TEMP '</font></pre>', "\n";
}
$sp = 0;

if ($pt) {
    print TEMP '
 <p>
 <table cellpadding="2" bgcolor="ivory">
  <tr><th colspan=5><font size=+1>SEDIMENT DELIVERY (', $sedunits,
      ')</font></th><th>Spatial (y1 .. y5)</th></tr>',  "\n";
}

for $c ( 0 .. $#selected_year ) {
    if ($pt) {
        print TEMP '  <tr><th align="left" bgcolor="ffff99" colspan="5">',
          @selected_ranks[$c] + 1, ' (', 100 / ( @selected_ranks[$c] + 1 ),
          '- year) -- ', @day[$c], ' ', @monthnames[ @month[$c] ], ' year ',
          @selected_year[$c], ' (', @probClimate[$c] * 100,
          '%)</th><td></td></tr>', "\n";
    }

    #    for $sn (0..3) {										# 2005.10.13 DEH
    for $sn ( 0 .. $#severe ) {    # 2005.10.13 DEH
        if ($pt) { print TEMP "<tr>\n"; }
      KLOOP: for $k ( 0 .. 4 ) { # KLOOP doesn't do anything! RL
            @sed_yields[$sp] = $sedtable[$c][$k][$sn];
            @scheme[$sp] =
                @selected_ranks[$c] + 1
              . uc( @severe[$sn] )
              . ( $k + 1 );    # 2005.10.25 DEH
            if ( $severityclass eq 'u' ) {

                # unburned
                @probabilities0[$sp] =
                  @probClimate[$c] * $probspatial[0][$sn] * @probSoil0[$k];
                @probabilities1[$sp] =
                  @probClimate[$c] * $probspatial[1][$sn] * @probSoil1[$k];
                @probabilities2[$sp] =
                  @probClimate[$c] * $probspatial[2][$sn] * @probSoil2[$k];
                @probabilities3[$sp] =
                  @probClimate[$c] * $probspatial[3][$sn] * @probSoil3[$k];
                @probabilities4[$sp] =
                  @probClimate[$c] * $probspatial[4][$sn] * @probSoil4[$k];
            }
            else {
                # untreated
                @probabilities0[$sp] =
                  @probClimate[$c] * $probspatial[0][$sn] * @probSoil0[$k];
                @probabilities1[$sp] =
                  @probClimate[$c] * $probspatial[1][$sn] * @probSoil1[$k];
                @probabilities2[$sp] =
                  @probClimate[$c] * $probspatial[2][$sn] * @probSoil2[$k];
                @probabilities3[$sp] =
                  @probClimate[$c] * $probspatial[3][$sn] * @probSoil3[$k];
                @probabilities4[$sp] =
                  @probClimate[$c] * $probspatial[4][$sn] * @probSoil4[$k];

                # seeding
                @probabilities_s0[$sp] =
                  @probClimate[$c] * $probspatial[0][$sn] * @probSoil_s0[$k];
                @probabilities_s1[$sp] =
                  @probClimate[$c] * $probspatial[1][$sn] * @probSoil_s1[$k];
                @probabilities_s2[$sp] =
                  @probClimate[$c] * $probspatial[2][$sn] * @probSoil_s2[$k];
                @probabilities_s3[$sp] =
                  @probClimate[$c] * $probspatial[3][$sn] * @probSoil_s3[$k];
                @probabilities_s4[$sp] =
                  @probClimate[$c] * $probspatial[4][$sn] * @probSoil_s4[$k];

                # mulch 047% GC	# 2005.09.30 DEH
                @probabilities_m470[$sp] =
                  @probClimate[$c] * $probspatial[0][$sn] * @probSoil_m470[$k]
                  ;    # 2005.09.30 DEH
                @probabilities_m471[$sp] =
                  @probClimate[$c] * $probspatial[1][$sn] * @probSoil_m471[$k]
                  ;    # 2005.09.30 DEH
                @probabilities_m472[$sp] =
                  @probClimate[$c] * $probspatial[2][$sn] * @probSoil_m472[$k]
                  ;    # 2005.09.30 DEH
                @probabilities_m473[$sp] =
                  @probClimate[$c] * $probspatial[3][$sn] * @probSoil_m473[$k]
                  ;    # 2005.09.30 DEH
                @probabilities_m474[$sp] =
                  @probClimate[$c] * $probspatial[4][$sn] * @probSoil_m474[$k]
                  ;    # 2005.09.30 DEH

                # mulch 72% GC	# 2005.09.30 DEH
                @probabilities_m720[$sp] =
                  @probClimate[$c] * $probspatial[0][$sn] * @probSoil_m720[$k]
                  ;    # 2005.09.30 DEH
                @probabilities_m721[$sp] =
                  @probClimate[$c] * $probspatial[1][$sn] * @probSoil_m721[$k]
                  ;    # 2005.09.30 DEH
                @probabilities_m722[$sp] =
                  @probClimate[$c] * $probspatial[2][$sn] * @probSoil_m722[$k]
                  ;    # 2005.09.30 DEH
                @probabilities_m723[$sp] =
                  @probClimate[$c] * $probspatial[3][$sn] * @probSoil_m723[$k]
                  ;    # 2005.09.30 DEH
                @probabilities_m724[$sp] =
                  @probClimate[$c] * $probspatial[4][$sn] * @probSoil_m724[$k]
                  ;    # 2005.09.30 DEH

                # mulch 89% GC	# 2005.09.30 DEH
                @probabilities_m890[$sp] =
                  @probClimate[$c] * $probspatial[0][$sn] * @probSoil_m890[$k]
                  ;    # 2005.09.30 DEH
                @probabilities_m891[$sp] =
                  @probClimate[$c] * $probspatial[1][$sn] * @probSoil_m891[$k]
                  ;    # 2005.09.30 DEH
                @probabilities_m892[$sp] =
                  @probClimate[$c] * $probspatial[2][$sn] * @probSoil_m892[$k]
                  ;    # 2005.09.30 DEH
                @probabilities_m893[$sp] =
                  @probClimate[$c] * $probspatial[3][$sn] * @probSoil_m893[$k]
                  ;    # 2005.09.30 DEH
                @probabilities_m894[$sp] =
                  @probClimate[$c] * $probspatial[4][$sn] * @probSoil_m894[$k]
                  ;    # 2005.09.30 DEH

                # mulch 94% GC	# 2005.09.30 DEH
                @probabilities_m940[$sp] =
                  @probClimate[$c] * $probspatial[0][$sn] * @probSoil_m940[$k]
                  ;    # 2005.09.30 DEH
                @probabilities_m941[$sp] =
                  @probClimate[$c] * $probspatial[1][$sn] * @probSoil_m941[$k]
                  ;    # 2005.09.30 DEH
                @probabilities_m942[$sp] =
                  @probClimate[$c] * $probspatial[2][$sn] * @probSoil_m942[$k]
                  ;    # 2005.09.30 DEH
                @probabilities_m943[$sp] =
                  @probClimate[$c] * $probspatial[3][$sn] * @probSoil_m943[$k]
                  ;    # 2005.09.30 DEH
                @probabilities_m944[$sp] =
                  @probClimate[$c] * $probspatial[4][$sn] * @probSoil_m944[$k]
                  ;    # 2005.09.30 DEH
            }
            if ( $units eq 'ft' )
            {          # convert sediment yield kg per m to ton per ac
                $sed_yield = @sed_yields[$sp] / $hillslope_length * 4.45;
            }
            else {     # convert sediment yield kg per m to t per ha
                $sed_yield = @sed_yields[$sp] / $hillslope_length * 10;
            }
            $sed_yield_f = sprintf '%6.2f', $sed_yield;
            if ($pt) {
                print TEMP "
  <td align=\"right\"><a href=\"https://forest.moscowfsl.wsu.edu/cgi-bin/fswepp/ermit/soilfile.pl?s=$severe[$sn]&k=$k&SoilType=$SoilType&vegtype=$vegtype&rfg=$rfg&grass=$grass&shrub=$shrub&bare=$bare\" target=\"o\">$sed_yield_f</a></td>
";
            }
            $sp += 1;
        }
        if ($pt) {    # 2005.10.13 DEH
            print TEMP '     <td bgcolor="ffff99">', @severe[$sn],
              ' (', $probspatial[0][$sn] * 100, '%) ',
              ' (', $probspatial[1][$sn] * 100, '%) ',
              ' (', $probspatial[2][$sn] * 100, '%) ',
              ' (', $probspatial[3][$sn] * 100, '%) ',
              ' (', $probspatial[4][$sn] * 100, '%) ',
              "    </td>\n   </tr>\n";
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
  <tr><td bgcolor="ffff99">(', $probSoil0[0] * 100, '%)</td>
   <td bgcolor="ffff99">(',    $probSoil0[1] * 100, '%)</td>
   <td bgcolor="ffff99">(',    $probSoil0[2] * 100, '%)</td>
   <td bgcolor="ffff99">(',    $probSoil0[3] * 100, '%)</td>
   <td bgcolor="ffff99">(',    $probSoil0[4] * 100, '%)</td>
   <td>year 0</td></tr>
  <tr><td bgcolor="ffff99">(', $probSoil1[0] * 100, '%)</td>
   <td bgcolor="ffff99">(',    $probSoil1[1] * 100, '%)</td>
   <td bgcolor="ffff99">(',    $probSoil1[2] * 100, '%)</td>
   <td bgcolor="ffff99">(',    $probSoil1[3] * 100, '%)</td>
   <td bgcolor="ffff99">(',    $probSoil1[4] * 100, '%)</td>
   <td>year 1</td></tr>
  <tr><td bgcolor="ffff99">(', $probSoil2[0] * 100, '%)</td>
   <td bgcolor="ffff99">(',    $probSoil2[1] * 100, '%)</td>
   <td bgcolor="ffff99">(',    $probSoil2[2] * 100, '%)</td>
   <td bgcolor="ffff99">(',    $probSoil2[3] * 100, '%)</td>
   <td bgcolor="ffff99">(',    $probSoil2[4] * 100, '%)</td>
   <td>year 2</td></tr>
  <tr><td bgcolor="ffff99">(', $probSoil3[0] * 100, '%)</td>
   <td bgcolor="ffff99">(',    $probSoil3[1] * 100, '%)</td>
   <td bgcolor="ffff99">(',    $probSoil3[2] * 100, '%)</td>
   <td bgcolor="ffff99">(',    $probSoil3[3] * 100, '%)</td>
   <td bgcolor="ffff99">(',    $probSoil3[4] * 100, '%)</td>
   <td>year 3</td></tr>
  <tr><td bgcolor="ffff99">(', $probSoil4[0] * 100, '%)</td>
   <td bgcolor="ffff99">(',    $probSoil4[1] * 100, '%)</td>
   <td bgcolor="ffff99">(',    $probSoil4[2] * 100, '%)</td>
   <td bgcolor="ffff99">(',    $probSoil4[3] * 100, '%)</td>
   <td bgcolor="ffff99">(',    $probSoil4[4] * 100, '%)</td>
   <td>year 4</td></tr>
 </table>
';
}

# index sort @sed_yields decreasing
#   print TEMP @sed_yields and @probabilities using same index and calculate cumulative probability

# index-sort runoff		# index sort from "Efficient FORTRAN Programming"

@index =
  sort { $sed_yields[$b] <=> $sed_yields[$a] } 0 .. $#sed_yields; # sort indices

#  @rank[@index] = 0..$#sed_yields;                    # make rank


#  @sorted_sed_probs = sort { $a <=> $b } @sed_probs;	# sort numerically increasing
#  for $sp (0..$#sed_probs) {
#    print TEMP @sorted_sed_probs[$sp], ' ';
#  }

# bail:

if ( lc($severityclass) eq 'u' ) {
    open YADDA, ">$gnuplotdatafile";
    print YADDA &createGnuplotUnburnedDatafile;    # yadda yadda
    close YADDA;
    open YADDA, ">$gnuplotjclfile";
    print YADDA &createGnuplotUnburnedJCLfile;     # yadda yadda
    close YADDA;
}
else {
    open YADDA, ">$gnuplotdatafile";
    print YADDA &createGnuplotDatafile;            # yadda yadda
    close YADDA;
    open YADDA, ">$gnuplotjclfile";
    print YADDA &createGnuplotJCLfile;             # yadda yadda
    close YADDA;
}

print TEMP `gnuplot`;

@args = ("gnuplot $gnuplotjclfile");

system @args;

`convert -rotate 90 $gnuplotgrapheps $gnuplotgraphpng`;

bail:    # 2005.10.29 DEH moved down

close TEMP;

############################
#  return HTML page
############################

print "Content-type: text/html\n\n";    # SERVER
print '<HTML>
 <HEAD>
  <TITLE>ERMiT Results</TITLE>
  <style>
   <!--
     P.Reference {
        margin-top:0pt;
        margin-left:.3in;
        text-indent:-.3in;
    }
   -->
  </style>
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

&CreateJavascriptwhatsedsFunction;

cutout:

print '   </HEAD>
   <BODY link="green" vlink="#160A8C">		<!-- ZZZZ -->
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
print &GetParSummary( $climatePar, $units );
$severityclass_xx = $severityclass_x;    # 2013.06.14
if ( $severityclass ne 'u' ) { $severityclass_xx .= ' soil burn severity on' }

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
       <b>$severityclass_xx $vegtype_x</b>
      </td>
     </tr>
";

#     <tr>
#      <td bgcolor=ccffff> <b>$vegtype</b> vegetation
#      </td>
#     </tr>
#";

if ( $vegtype ne 'forest' ) {
    print "
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
    print $_;
}

close TEMP;

#   ##################### display Sediment delivery exceedance prob graph

print '
  <p>
   <a href="javascript:showtable(\'cp\',\'untreated\',\'Untreated\')"
             onMouseOver="window.status=\'Display untreated sediment yield--probability of exceedance table (new window)\'; return true"
             onMouseOut="window.status=\'\'; return true"><img src="'
  . $gnuplotgraphpl . '"></a>
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
//   var seds = whatseds (0.2, cp0)
     var seds = whatseds (0.2, cp0)		// 2012.06.27
     seds = rounder(seds*js_sedconv,2)

     mulchrate = '1'	////<!-- mulch 47% -->	// 2005.09.30 DEH
     if (js_units == 'ft') mulchrate = '0.5'	// 2005.09.30 DEH
     mulch1  = '<a onMouseOver="window.status=\'47% groundcover\';return true" onMouseOut="window.status=\'\'; return true">Mulch ('+mulchrate+' '+js_sedunits+')</a>'
     mulch1a = 'Mulch ('+mulchrate+' '+js_alt_sedunits+')'

     mulchrate = '2'	////<!-- mulch 72% -->	// 2005.09.30 DEH
     if (js_units == 'ft') mulchrate = '1'	// 2005.09.30 DEH
     mulch2  = '<a onMouseOver="window.status=\'72% groundcover\';return true" onMouseOut="window.status=\'\'; return true">Mulch ('+mulchrate+' '+js_sedunits+')</a>'
     mulch2a = 'Mulch ('+mulchrate+' '+js_alt_sedunits+')'

     mulchrate = '3.5'	////<!-- mulch 89% -->	// 2005.09.30 DEH
     if (js_units == 'ft') mulchrate = '1.5'	// 2005.09.30 DEH
     mulch3  = '<a onMouseOver="window.status=\'89% groundcover\';return true" onMouseOut="window.status=\'\'; return true">Mulch ('+mulchrate+' '+js_sedunits+')</a>'
     mulch3a = 'Mulch ('+mulchrate+' '+js_alt_sedunits+')'

     mulchrate = '4.5'	////<!-- mulch 94% -->	// 2005.09.30 DEH
     if (js_units == 'ft') mulchrate = '2'	// 2005.09.30 DEH
     mulch4  = '<a onMouseOver="window.status=\'94% groundcover\';return true" onMouseOut="window.status=\'\'; return true">Mulch ('+mulchrate+' '+js_sedunits+')</a>'
     mulch4a = 'Mulch ('+mulchrate+' '+js_alt_sedunits+')'
var defprob = 0.1;	// 2012.06.27
var defprob = 0.2;	// 2012.06.27
     sediment0 = rounder(whatseds (defprob, cp0)*js_sedconv,2)	// 2005.09.30 DEH
     sediment1 = rounder(whatseds (defprob, cp1)*js_sedconv,2)	// 2005.09.30 DEH
     sediment2 = rounder(whatseds (defprob, cp2)*js_sedconv,2)	// 2005.09.30 DEH
     sediment3 = rounder(whatseds (defprob, cp3)*js_sedconv,2)	// 2005.09.30 DEH
     sediment4 = rounder(whatseds (defprob, cp4)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_s0 = rounder(whatseds (defprob, cp_s0)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_s1 = rounder(whatseds (defprob, cp_s1)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_s2 = rounder(whatseds (defprob, cp_s2)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_s3 = rounder(whatseds (defprob, cp_s3)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_s4 = rounder(whatseds (defprob, cp_s4)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m470 = rounder(whatseds (defprob, cp_m470)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m471 = rounder(whatseds (defprob, cp_m471)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m472 = rounder(whatseds (defprob, cp_m472)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m473 = rounder(whatseds (defprob, cp_m473)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m474 = rounder(whatseds (defprob, cp_m474)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m720 = rounder(whatseds (defprob, cp_m720)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m721 = rounder(whatseds (defprob, cp_m721)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m722 = rounder(whatseds (defprob, cp_m722)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m723 = rounder(whatseds (defprob, cp_m723)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m724 = rounder(whatseds (defprob, cp_m724)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m890 = rounder(whatseds (defprob, cp_m890)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m891 = rounder(whatseds (defprob, cp_m891)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m892 = rounder(whatseds (defprob, cp_m892)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m893 = rounder(whatseds (defprob, cp_m893)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m894 = rounder(whatseds (defprob, cp_m894)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m940 = rounder(whatseds (defprob, cp_m940)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m941 = rounder(whatseds (defprob, cp_m941)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m942 = rounder(whatseds (defprob, cp_m942)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m943 = rounder(whatseds (defprob, cp_m943)*js_sedconv,2)	// 2005.09.30 DEH
     sediment_m944 = rounder(whatseds (defprob, cp_m944)*js_sedconv,2)	// 2005.09.30 DEH
    </script>

    <table border=1>
     <tr><th colspan=6 bgcolor="gold">Sediment Delivery</th></tr>
     <tr>
      <th rowspan=3 bgcolor="gold"><!-- Target chance<br>event sediment delivery<br>will be exceeded<br> -->
       Probability that<br>sediment yield<br>will be exceeded<br>
       <input type="text" name="probability0x" onChange="javascript:probchange()" value="20" size="6"> %&nbsp;&nbsp;&nbsp;
<!-- 2012.06.27 value="10" to value="20" -->
       <img src="/fswepp/images/go.gif" alt="[X]">
      </th>
      <th colspan=5 bgcolor="lightgoldenrodyellow">&nbsp;
       <a href="javascript:showpt()"><img src="/fswepp/images/printer.png" border="0" alt="[table]" title="Display sediment yield--probability table"></a>
       &nbsp;&nbsp;&nbsp;
       Event sediment delivery (<script>document.writeln(js_sedunits)</script>)
       &nbsp;&nbsp;&nbsp;
       <a href="javascript:printseds()">
        <img src="/fswepp/images/printer.png" border="0" alt="[text]" title="Display sediment delivery paragraphs"></a>&nbsp;
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
EOP2
if ( lc($severityclass) eq 'u' ) {
    print "<!-- unburned -->
     <tr>
      <th bgcolor=\"lightgoldenrodyellow\" align=\"right\">Unburned
       <a href=\"javascript:showtable('cp','unburned','Unburned')\">
        <img src=\"/fswepp/images/printer.png\" border=0 alt=\"[table]\" title=\"sediment yield--probability of exceedance table\"></a>&nbsp;
      </th>
      <th><script>document.write('<span id=\"sediment0\">'+sediment0+'</span>')</script></th>
      <th><script>document.write('<span id=\"sediment1\">'+sediment1+'</span>')</script></th>
      <th><script>document.write('<span id=\"sediment2\">'+sediment2+'</span>')</script></th>
      <th><script>document.write('<span id=\"sediment3\">'+sediment3+'</span>')</script></th>
      <th><script>document.write('<span id=\"sediment4\">'+sediment4+'</span>')</script></th>
     </tr>
    </table>
";
}
else {
    print "<!-- untreated -->
     <tr>
      <th bgcolor=\"lightgoldenrodyellow\" align=\"right\"> Untreated
       <a href=\"javascript:showtable('cp','untreated','Untreated')\">
        <img src=\"/fswepp/images/printer.png\" border=0 alt=\"[table]\" title=\"Display untreated sediment yield--probability of exceedance table\"></a>&nbsp;
      </th>
      <th><script>document.write('<span id=\"sediment0\">'+sediment0+'</span>')</script></th>
      <th><script>document.write('<span id=\"sediment1\">'+sediment1+'</span>')</script></th>
      <th><script>document.write('<span id=\"sediment2\">'+sediment2+'</span>')</script></th>
      <th><script>document.write('<span id=\"sediment3\">'+sediment3+'</span>')</script></th>
      <th><script>document.write('<span id=\"sediment4\">'+sediment4+'</span>')</script></th>
     </tr>
<!-- seeding -->
     <tr>
      <th bgcolor=\"lightgoldenrodyellow\" align=\"right\"> Seeding
       <a href=\"javascript:showtable('cp_s','seed','Seeding after fire')\">
        <img src=\"/fswepp/images/printer.png\" border=0 alt=\"[table]\" title=\"Display seeding sediment yield--probability of exceedance table\"></a>&nbsp;
      </th>
      <th><script>document.write('<span id=\"sediment_s0\">'+sediment_s0+'</span>')</script></th>
      <th><script>document.write('<span id=\"sediment_s1\">'+sediment_s1+'</span>')</script></th>
      <th><script>document.write('<span id=\"sediment_s2\">'+sediment_s2+'</span>')</script></th>
      <th><script>document.write('<span id=\"sediment_s3\">'+sediment_s3+'</span>')</script></th>
      <th><script>document.write('<span id=\"sediment_s4\">'+sediment_s4+'</span>')</script></th>
     </tr>
<!-- mulch 47% -->
     <tr>
      <th bgcolor=\"lightgoldenrodyellow\" align=\"right\">
       <script>document.writeln(mulch1)</script>
       <a href=\"javascript:showtable('cp_m47','mulch_47',mulch1a)\">
       <img src=\"/fswepp/images/printer.png\" border=0 alt=\"[table]\" title=\"Display 47% mulching sediment yield--probability of exceedance table\"></a>&nbsp;
      </th>
      <th><script>document.write('<span id=\"sediment_m470\">'+sediment_m470+'</span>')</script></th>
      <th><script>document.write('<span id=\"sediment_m471\">'+sediment_m471+'</span>')</script></th>
      <th><script>document.write('<span id=\"sediment_m472\">'+sediment_m472+'</span>')</script></th>
      <th><script>document.write('<span id=\"sediment_m473\">'+sediment_m473+'</span>')</script></th>
      <th><script>document.write('<span id=\"sediment_m474\">'+sediment_m474+'</span>')</script></th>
     </tr>
<!-- mulch 72% -->
     <tr>
      <th bgcolor=\"lightgoldenrodyellow\" align=\"right\">
       <script>document.writeln(mulch2)</script>
       <a href=\"javascript:showtable('cp_m72','mulch_72',mulch2a)\">
       <img src=\"/fswepp/images/printer.png\" border=0 alt=\"[table]\" title=\"Display 72% mulching sediment yield--probability of exceedance table\"></a>&nbsp;
      </th>
      <th><script>document.write('<span id=\"sediment_m720\">'+sediment_m720+'</span>')</script></th>
      <th><script>document.write('<span id=\"sediment_m721\">'+sediment_m721+'</span>')</script></th>
      <th><script>document.write('<span id=\"sediment_m722\">'+sediment_m722+'</span>')</script></th>
      <th><script>document.write('<span id=\"sediment_m723\">'+sediment_m723+'</span>')</script></th>
      <th><script>document.write('<span id=\"sediment_m724\">'+sediment_m724+'</span>')</script></th>
     </tr>
<!-- mulch 89% -->
     <tr>
      <th bgcolor=\"lightgoldenrodyellow\" align=\"right\">
       <script>document.writeln(mulch3)</script>
       <a href=\"javascript:showtable('cp_m89','mulch_89',mulch3a)\">
       <img src=\"/fswepp/images/printer.png\" border=0 alt=\"[table]\" title=\"Display 89% mulching sediment yield--probability of exceedance table\"></a>&nbsp;
      </th>
      <th><script>document.write('<span id=\"sediment_m890\">'+sediment_m890+'</span>')</script></th>
      <th><script>document.write('<span id=\"sediment_m891\">'+sediment_m891+'</span>')</script></th>
      <th><script>document.write('<span id=\"sediment_m892\">'+sediment_m892+'</span>')</script></th>
      <th><script>document.write('<span id=\"sediment_m893\">'+sediment_m893+'</span>')</script></th>
      <th><script>document.write('<span id=\"sediment_m894\">'+sediment_m894+'</span>')</script></th>
     </tr>
<!-- mulch 94% -->
     <tr>
      <th bgcolor=\"lightgoldenrodyellow\" align=\"right\">
       <script>document.writeln(mulch4)</script>
       <a href=\"javascript:showtable('cp_m94','mulch_94',mulch4a)\">
       <img src=\"/fswepp/images/printer.png\" border=0 alt=\"[table]\" title=\"Display 94% mulching sediment yield--probability of exceedance table\"></a>&nbsp;
      </th>
      <th><script>document.write('<span id=\"sediment_m940\">'+sediment_m940+'</span>')</script></th>
      <th><script>document.write('<span id=\"sediment_m941\">'+sediment_m941+'</span>')</script></th>
      <th><script>document.write('<span id=\"sediment_m942\">'+sediment_m942+'</span>')</script></th>
      <th><script>document.write('<span id=\"sediment_m943\">'+sediment_m943+'</span>')</script></th>
      <th><script>document.write('<span id=\"sediment_m944\">'+sediment_m944+'</span>')</script></th>
     </tr>
<!-- logs & wattles -->
     <tr>
      <td bgcolor=\"gold\" colspan=6>Erosion Barriers: 
       <font size=-1>
         Diameter <input type=\"text\" name=\"diameter\" value ='' size=\"5\" onChange=\"javascript:logchange()\"> <script>document.write(js_units)</script>&nbsp;
         Spacing <input type=\"text\" name=\"spacing\" value='' size=\"5\" onChange=\"javascript:logchange()\"> <script>document.write(js_units)</script>&nbsp;
         &nbsp;<img src=\"/fswepp/images/go.gif\">&nbsp;
         <a href=\"javascript:explain_log_spacing()\"
             onMouseOver=\"window.status='Explain log spacing (new window)'; return true\"
             onMouseOut=\"window.status=''; return true\">
         <img src=\"/fswepp/images/quest_b.gif\" width=14 height=12 border=0 alt=\"[?]\"></a>
       </font>
      </td>
     </tr>
<!-- contour-felled logs -->
     <tr>
      <th bgcolor=\"gold\" align=\"right\">
                               &nbsp;<a href=\"javascript:log_prob()\"><img src=\"/fswepp/images/printer.png\" border=0 alt=\"[table]\" title=\"Display log & wattle probability table\"></a>
       Logs &amp; Wattles&nbsp;&nbsp;<a href=\"javascript:logtable()\"><img src=\"/fswepp/images/printer.png\" border=\"0\" alt=\"[table]\" title=\"Display log & wattle efficiency tables\"></a>&nbsp;
       <br>
       <div align=\"right\">
        <font size=-1>
";

    print '         <input type="hidden" name="i10" value="', $i10w, '">';
    print "
         <!-- Storage --> <input type=\"hidden\" name=\"capacity\" value=\"0\"> <!-- script --><!-- document.write(js_storage_units) --><!-- /script -->
        </font>
       </div>
      </th>
";

    print "      <th valign=\"top\">
       <span id=\"sediment_cl0\"><script>document.write('')</script></span><br>
      </th>
      <th valign=\"top\">
       <span id=\"sediment_cl1\"><script>document.write('')</script></span><br>
      </th>
      <th valign=\"top\">
       <span id=\"sediment_cl2\"><script>document.write('')</script></span><br>
      </th>
      <th valign=\"top\">
       <span id=\"sediment_cl3\"><script>document.write('')</script></span><br>
      </th>
      <th valign=\"top\">
       <span id=\"sediment_cl4\"><script>document.write('')</script></span><br>
      </th>
     </tr>
    </table>
";
}

print <<'EOP2a';
   </form>
  </center>
  <a href="/cgi-bin/fswepp/ermit/ermit.pl">Return to input screen</a>
  </center>
  <br>
  <br>
EOP2a
print '
  <hr>
  <font size=-2>
   ERMiT  Version <a href="https://github.com/wepp-in-the-woods/fswepp-docker/commits/main/var/www/cgi-bin/fswepp/ermit/erm.pl">',
  $version, '</a>
   <br><br>
   <b>Citation:</b>
   <p align="left" class="Reference">
        Robichaud, Peter R.; Elliot, William J.; Pierson, Fredrick B.; Hall, David E.; Moffet, Corey A.
        2014.
        <b>Erosion Risk Management Tool (ERMiT).</b>
        [Online at &lt;https://forest.moscowfsl.wsu.edu/fswepp/&gt;.]
        Moscow, ID: U.S. Department of Agriculture, Forest Service, Rocky Mountain Research Station.
</p>

   WEPP ',         $weppver, '<br>
   ERMiT run ID ', $unique,  '<br>
';

print
" Observed annual precip $obannual mm; July, August, September precip $obJAS mm ($pctJAS percent):";
print " MONSOONAL climate<br>\n"     if ($monsoon);
print " NON-MONSOONAL climate<br>\n" if ( !$monsoon );

print "
  </font>
 </body>
</html>
";

#  record activity in ERMiT log (if running on remote server)

my ( $lat, $long ) = GetParLatLong($climatePar);

# 2008.06.04 DEH end

open WELOG, ">>../working/_$thisyear/we.log";    # 2012.12.31 DEH
flock( WELOG, 2 );
print WELOG "$host\t\"";
printf WELOG "%0.2d:%0.2d ", $hour, $min;
print WELOG $ampm[$ampmi], "  ", $days[$wday], " ", $months[$mon], " ",
  $mday, ", ", $thissyear, "\"\t";
print WELOG '"', trim($climate_name), "\"\t";
print WELOG "$lat\t$long\n";                     # 2008.06.04 DEH

#       print  WELOG $lat_long,"\n";                      # 2008.06.04 DEH
#      print  WELOG "$climate_name\n";
close WELOG;

open CLIMLOG, ">../working/_$thisyear/lastclimate.txt";    # 2012.12.31 DEH
flock CLIMLOG, 2;
print CLIMLOG 'ERMiT: ', $climate_name;
close CLIMLOG;

$ditlogfile = ">>../working/_$thisyear/we/$thisweek";      # 2012.12.31 DEH
open MYLOG, $ditlogfile;
flock MYLOG, 2;                                            # 2005.02.09 DEH

#      print MYLOG '.' x $count;	# 2006.01.18 DEH
print MYLOG '.';                                           # 2007.01.01 DEH
close MYLOG;

################################# start 2010.01.20 DEH   record run in user wepp run log file

$climate_trim = trim($climate_name);

open RUNLOG, ">>$runLogFile";
flock( RUNLOG, 2 );
print RUNLOG "WE\t$unique\t", '"';
printf RUNLOG "%0.2d:%0.2d ", $hour, $min;
print RUNLOG $ampm[$ampmi], "  ", $days[$wday], " ", $months[$mon], " ", $mday,
  ", ", $thissyear, '"', "\t", '"';
print RUNLOG $climate_trim, '"', "\t";    # Climate
print RUNLOG "$SoilType\t";               # Soil texture
print RUNLOG "$rfg\t";                    # Rock content
print RUNLOG "$vegtype\t";                # Vegetation type
print RUNLOG "$top_slope\t";              # Hillslope top gradient
print RUNLOG "$avg_slope\t";              # Hillslope average gradient
print RUNLOG "$toe_slope\t";              # Hillslope toe gradient
print RUNLOG "$hillslope_length\t";       # Hillslope length
print RUNLOG "$severityclass\t";          # Burn severity
print RUNLOG "$shrub\t";                  # Percent shrub
print RUNLOG "$grass\t";                  # Percent grass

#     print  RUNLOG "$bare\t";			# Percent bare
print RUNLOG "$units\n";                  # units
close RUNLOG;

################################# end 2010.01.20 DEH

# unlink

if ($wgr) {
    `cp $evoFile /var/www/html/fswepp/working/evo`;           # DEH 040913
    `cp $ev_by_evFile /var/www/html/fswepp/working/event`;    # DEH 040913
}
if (1) { }
else {
    unlink $soilfile;
    unlink $tempfile;
    unlink $slopefile;
    unlink $evo_file;    # 2015.05.27 DEH uncomment
    unlink $shortCLIfile;
    unlink $responseFile;
    unlink $ev_by_evFile;    # 2006.02.23 DEH uncomment
    unlink $crspfile;
    unlink $stoutfile;
    unlink $outputfile;
    unlink $gnuplotdatafile;    # 2006.02.23 DEH uncomment
    unlink $gnuplotjclfile;     # 2006.02.23 DEH uncomment

    #    unlink $gnuplotgrapheps;		# 2006.02.23 DEH new

    unlink $workingpath . '.cli';    # 2006.02.23 DEH uncomment
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

sub lhtoab {    # ######################### lhtoab

# reads:
# $s - spatial severity arrangement ("uuu", "lll", "lhl", "hhl" etc.)	# 2013.04.19 DEH

    # returns:
    # $ab - generic representation of spatial severity arrangement
    # $nofe - number of OFEs

    my $string = lc($s);

    if ( lc($s) eq "uuu" ) { $ab = 'aaa'; $nofe = 1 }    ### aaa.slp ###
    if ( lc($s) eq "lll" || lc($s) eq "hhh" ) {
        $ab   = 'aaa';
        $nofe = 1;
    }                                                    ### aaa.slp ###
    if ( lc($s) eq "llh" || lc($s) eq "hhl" ) {
        $ab   = 'aab';
        $nofe = 2;
    }                                                    ### aab.slp ###
    if ( lc($s) eq "lhl" || lc($s) eq "hlh" ) {
        $ab   = 'aba';
        $nofe = 3;
    }                                                    ### aba.slp ###
    if ( lc($s) eq "lhh" || lc($s) eq "hll" ) {
        $ab   = 'abb';
        $nofe = 2;
    }                                                    ### abb.slp ###

}

sub createResponseFile {    # ######################### createResponseFile

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

    $wgrFile = "/var/www/html/fswepp/working/wgr$sn-$k.wgr";    # DEH 040316

    open( ResponseFile, ">" . $responseFile );
    print ResponseFile "m\n";           # metric
    print ResponseFile "y\n";           # batch
    print ResponseFile "1\n";           # 1 = continuous
    print ResponseFile "1\n";           # 1 = hillslope
    print ResponseFile "n\n";           # hillsplope pass file out?
    print ResponseFile "2\n";           # soil loss output -- detailed annual
    print ResponseFile "n\n";           # initial conditions out?
    print ResponseFile "$evoFile\n";    # soil loss out filename
    print ResponseFile "n\n";           # water balance out?
    print ResponseFile "n\n";           # crop out?
    print ResponseFile "n\n";           # soil out?
    print ResponseFile "n\n";           # dx and sed loss output?

    if ($wgr) {                         # DEH 040316
        print ResponseFile "y\n";         # large graphics out?		# DEH 040316
        print ResponseFile "$wgrFile\n";  # event-by-event filename	# DEH 040316
    }    # DEH 040316
    else {    # DEH 040316
        print ResponseFile "n\n";    # large graphics out?
    }    # DEH 040316
    print ResponseFile "y\n";                # event-by-event out?
    print ResponseFile "$ev_by_evFile\n";    # event-by-event filename
    print ResponseFile "n\n";                # element output?
    print ResponseFile "n\n";                # final summary out?
    print ResponseFile "n\n";                # daily winter out?
    print ResponseFile "n\n";                # yield output?
    print ResponseFile "$manFile\n";         # management file name
    print ResponseFile "$slopeFile\n";       # slope file name
    print ResponseFile "$climateFile\n";     # climate file name
    print ResponseFile "$soilFile\n";        # soil file name
    print ResponseFile "0\n";                # 0 = no irrigation
    print ResponseFile "$year_count\n";      # number of years to simulate
    print ResponseFile "0\n";                # small event bypass
    close ResponseFile;

    return $responseFile;

}

sub createSlopeFile {    # ######################### createSlopeFile

    #	create topography file		(1, 2, or 3 OFE based on severity)

    # $s - spatial severity representation ("lll", "lhl", "hhl" etc.)
    # $avg_slope - average surface slope gradient
    # $toe_slope - surface slope toe gradient
    # $hillslope_length

    # print TEMP " ********* createslopefile:  $s<br>";

    # $result - slope file

    my $topslope = $top_slope / 100;
    my $aveslope = $avg_slope / 100;
    my $toeslope = $toe_slope / 100;

#  print "========================== slope file for '$s' ===================\n";
    if ( lc($s) eq "lll" || lc($s) eq "hhh" || lc($s) eq "uuu" )
    {    ### aaa.slp ###  # 2013.04.24 DEH
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

    if ( lc($s) eq "llh" || lc($s) eq "hhl" ) {    ### aab.slp ###
        my $length2 = $hillslope_length_m / 3;
        my $length1 = $hillslope_length_m - $length2;
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

    if ( lc($s) eq "lhl" || lc($s) eq "hlh" ) {    ### aba.slp ###
        my $length1 = $hillslope_length_m / 3;
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

    if ( lc($s) eq "lhh" || lc($s) eq "hll" ) {    ### abb.slp ###
        my $length1 = $hillslope_length_m / 3;
        my $length2 = $hillslope_length_m - $length1;
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

sub createVegFile {    # ######################### createVegFile

#	select management file
#		(1, 2, or 3 OFE based on severity)
#		(4 to 16 years) [all can be 16 years]
#		depends on management selected?
#                  forest will have 1 veg type
#
#	unburned use select management files (1 OFE, 1 for forest, 1 for range/chaparral)   DEH 2014.02.06

    # reads:
    #  $nofe -- number of OFEs
    #  $severityclass -- 'u','l','m','h'				# DEH 2014.02.06
    #  $vegtype -- 'forest', 'range', 'chap'			# DEH 2014.02.06
    # returns:
    #  $manFileName

    # tentative naming scheme: [forest]
    # forest and range/chaparral the same -- CM 03/18/2004
    #    1ofe.man
    #    2ofe.man
    #    3ofe.man
    #    forest_95%_cover_80%_canopy.man
    #    range_40%_cover_40%_canopy.man

    #    $manFileName = 'for_' . $nofe . 'ofe.man';
    $manFileName = $nofe . 'ofe.man';    # DEH 2004.03.18
    if ( $severityclass eq 'u' ) {       # unburned -- 1 OFE
        if ( $vegtype eq 'forest' ) {
            $manFileName = 'forest_95%_cover_80%_canopy.man';
        }
        else { $manFileName = $manFileName = 'range_40%_cover_40%_canopy.man' }
    }
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
    if ($debug) { print TEMP "min_year: $min_year<br>\n"; }

    open EVENTS, "<$ev_by_evFile";

    $line = <EVENTS>;
    $line = <EVENTS>;
    $line = <EVENTS>;

    $counter = 0;
    while (<EVENTS>) {
        $event = $_;
        (
            $da,     $mo,       $yr,     $pcp,      $runoff,
            $IRdet,  $avdet,    $mxdet,  $detpoint, $avdep,
            $maxdep, $deppoint, $seddel, $er
        ) = split( ' ', $event );
        $yr += $min_year - 1;    # 2030 vulnerable line
        if ( $yr > -1 ) {        # 2013.04.19 DEH
            @idx_for_year[$yr] = $counter if ( @idx_for_year[$yr] eq '' );
        }
        @days[$counter]     = $da;
        @months[$counter]   = $mo;
        @years[$counter]    = $yr;
        @sed_dels[$counter] = $seddel;
        $counter += 1;

        #  print TEMP $event;
        #    print TEMP $da,'  ', $mo,'  ', $yr,'  ', $seddel,"\n";
    }

    close EVENTS;

    #  print TEMP "$counter\n";

    #  for $i (0..$#idx_for_year)  {
    #   print TEMP $i,'  ',@idx_for_year[$i],"\n" if ($idx_for_year[$i] ne '')
    #  }

    for $i ( 0 .. $#selected_year ) {

#    if ($debug) {print TEMP 'Looking for day ' , @day[$i], ' month ' ,@month[$i], ' year ' , @selected_year[$i];}
        $start_index = @idx_for_year[ @selected_year[$i] ];

        #    $end_index = @idx_for_year[@selected_year[$i]+1];
        $end_index = $#sed_dels;

        #    if ($debug) {print TEMP "  starting at $start_index<br>\n";}
        for $j ( $start_index .. $end_index ) {

#      if ($debug) {print TEMP '   comparing ', @days[$j],' to ',@day[$i],' and ',$months[$j],' to ',@month[$i],' and ',$years[$j],' to ',@selected_year[$i],"\n";}
            if (   @days[$j] == @day[$i]
                && $months[$j] == @month[$i]
                && $years[$j] == @selected_year[$i] )
            {
                #        if ($debug) {print TEMP "got it!\n";}
                @seds[$i] = @sed_dels[$j];
                last;
            }
            last if ( ( $months[$j] + 0 ) > ( @month[$i] + 0 ) );
        }
    }
    return @seds;
}

sub printfile {

    #  $filename = $_;
    open INININ, '<' . $printfilename;
    @filetext = <INININ>;
    print TEMP "<hr><br>$printfilename<pre>
   @filetext
   </pre>
";
    close INININ;    # 2003.01.14
}

sub CreateResponseFile {    # 100-year -- modified from wd.pl on PC43

    open( ResponseFile, ">" . $responseFile );
    print ResponseFile "m\n";                # metric output
    print ResponseFile "y\n";                # not watershed
    print ResponseFile "1\n";                # 1 = continuous
    print ResponseFile "1\n";                # 1 = hillslope
    print ResponseFile "n\n";                # hillsplope pass file out?
    print ResponseFile "1\n";                # 1 = annual; abbreviated
    print ResponseFile "n\n";                # initial conditions file?
    print ResponseFile $outputFile, "\n";    # soil loss output file
    print ResponseFile "n\n";                # water balance output?
    print ResponseFile "n\n";                # crop output?
    print ResponseFile "n\n";                # soil output?
    print ResponseFile "n\n";                # distance/sed loss output?
    print ResponseFile "n\n";                # large graphics output?
    print ResponseFile "y\n";                # event-by-event out?
    print ResponseFile "$eventFile\n";       # event-by-event filename
    print ResponseFile "n\n";                # element output?
    print ResponseFile "n\n";                # final summary out?
    print ResponseFile "n\n";                # daily winter out?
    print ResponseFile "n\n";                # plant yield out?
    print ResponseFile "$manFile\n";         # management file name
    print ResponseFile "$slopeFile\n";       # slope file name
    print ResponseFile "$CLIfile\n";         # climate file name
    print ResponseFile "$soilFile\n";        # soil file name
    print ResponseFile "0\n";                # 0 = no irrigation
    print ResponseFile "$years2sim\n";       # no. years to simulate
    print ResponseFile "0\n";                # 0 = route all events

    close ResponseFile;
    return $responseFile;
}

sub readWEPPresults {

    open weppstout, "<$stoutFile";

    print TEMP "checking $stoutFile for successful run ... " if ($debug);
    $found = 0;
    print TEMP "<font size=-2><pre>\n" if ($debug);
    while (<weppstout>) {
        print TEMP $_ if ($debug);
        if (/SUCCESSFUL/) {
            $found = 1;
            print TEMP "successful! " if ($debug);
            last;
        }
    }
    print TEMP "</pre></font>\n" if ($debug);
    close(weppstout);

########################   NAN check   ###################

    open weppoutfile, "<$outputFile";
    while (<weppoutfile>) {
        if (/NaN/) {
            open NANLOG, ">>../working/NANlog.log";
            flock( NANLOG, 2 );
            print NANLOG "$user_ID_\t";
            print NANLOG "WE\t$unique\n";
            close NANLOG;
            last;
        }
    }
    close(weppoutfile);

########################   NAN check   ###################

    if ( $found == 0 ) {   # unsuccessful run -- search STDOUT for error message
        open weppstout, "<$stoutFile";
        while (<weppstout>) {
            if (/ERROR/) {
                $found = 2;
                print TEMP "<font color=red>ERROR:\n";
                $_ = <weppstout>;
                $_ = <weppstout>;
                $_ = <weppstout>;
                print TEMP;
                $_ = <weppstout>;
                print TEMP;
                print TEMP "</font>\n";
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
                print TEMP "<font color=red>error #\n";
                print TEMP $_;
                print TEMP "</font>\n";
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
                print TEMP "<font color=red>***\n";
                $_ = <weppstout>;
                print TEMP $_;
                $_ = <weppstout>;
                print TEMP $_;
                $_ = <weppstout>;
                print TEMP $_;
                $_ = <weppstout>;
                print TEMP $_;
                print TEMP "</font>\n";
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
                print TEMP "<font color=red>\n";
                print TEMP 'WEPP has run into a mathematical anomaly.<br>
             You may be able to get around it by modifying the geometry slightly.
             ';
                $_ = <weppstout>;
                print TEMP;
                print TEMP "</font>\n";
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
                $climate_name =~ s/^\s*(.*?)\s*$/$1/;    # strip whitespace
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
                  ;    #         71 storms produced 346.90 mm of precipitation
                $storms = substr $_, 1, 10;
                $_ = <weppout>
                  ; #          3 rain storm runoff events produced          0.00 mm of runoff
                $rainevents = substr $_, 1, 10;
                $_          = <weppout>;    #          2 snow melts and/or
                $snowevents = substr $_, 1, 10;
                $_          = <weppout>
                  ; #              events during winter produced 0.00 mm of runoff
                $_ = <weppout>;  #
                $_ = <weppout>;  #      annual averages
                $_ = <weppout>;  #      ---------------
                $_ = <weppout>;  #
                $_ = <weppout>;  #        Number of years   1
                $_ = <weppout>;  #        Mean annual precipitation 346.90    mm
                $precip = substr $_, 51, 10;
                $_      = <weppout>;
                $rro    = substr $_, 51, 10;    # print TEMP;
                $_      = <weppout>;            # print TEMP;
                $_      = <weppout>;
                $sro    = substr $_, 51, 10;    # print TEMP;
                $_      = <weppout>;            # print TEMP;
                last;
            }
        }
        while (<weppout>) {
            if (/AREA OF NET SOIL LOSS/) {
                $_                     = <weppout>;
                $_                     = <weppout>;
                $_                     = <weppout>;
                $_                     = <weppout>;
                $_                     = <weppout>;
                $_                     = <weppout>;    # print TEMP;
                $_                     = <weppout>;    # print TEMP;
                $_                     = <weppout>;    # print TEMP;
                $_                     = <weppout>;    # print TEMP;
                $_                     = <weppout>;    # print TEMP;
                $syr                   = substr $_, 17, 7;
                $effective_road_length = substr $_, 9,  9;
                last;
            }
        }
        while (<weppout>) {
            if (/OFF SITE EFFECTS/) {
                $_   = <weppout>;
                $_   = <weppout>;
                $_   = <weppout>;
                $syp = substr $_, 49, 10;              # pre-WEPP 98.4
                $_   = <weppout>;
                if ( $syp eq "" ) {
                    @sypline = split ' ', $_;
                    $syp     = @sypline[0];
                }
                $_ = <weppout>;
                $_ = <weppout>;
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
    }
    else {    # ($found != 1)
        print TEMP
"<br><br>\nSomething has gone amiss! -- error no. $found\n<br><hr><br>\n";
        open STERR, "<$sterrFile";
        @STERR = <STERR>;
        print TEMP "error file $sterrFile: <br>\n";
        print TEMP @STERR;

        # die;
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
// untreated
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
   js_severityclass    = '$severityclass'
   js_severityclass_x  = '$severityclass_x' + ' soil burn severity'
   js_severityclass_xx = js_severityclass_x
   if (js_severityclass == 'u') {js_severityclass_xx = 'unburned'}
   js_sedunits = '$sedunits'
   js_alt_sedunits = '$alt_sedunits'
   js_intensity_units='$intunits'
";
    if ( $units eq 'm' ) {
        print '   js_sedconv = ' . 10 / $hillslope_length, "\n";
        print "   js_storage_units=\'Mg ha<sup>-1</sup>'\n";
    }
    else {
        print '   js_sedconv = ' . 4.45 / $hillslope_length_m, "\n";
        print "   js_storage_units='ton ac<sup>-1</sup>'\n";
    }

    # ###

    $cum_prob0     = 0.01;
    $cum_prob1     = 0.01;
    $cum_prob2     = 0.01;
    $cum_prob3     = 0.01;
    $cum_prob4     = 0.01;
    $cum_prob_s0   = 0.01;
    $cum_prob_s1   = 0.01;
    $cum_prob_s2   = 0.01;
    $cum_prob_s3   = 0.01;
    $cum_prob_s4   = 0.01;
    $cum_prob_m470 = 0.01;
    $cum_prob_m471 = 0.01;
    $cum_prob_m472 = 0.01;
    $cum_prob_m473 = 0.01;
    $cum_prob_m474 = 0.01;
    $cum_prob_m720 = 0.01;
    $cum_prob_m721 = 0.01;
    $cum_prob_m722 = 0.01;
    $cum_prob_m723 = 0.01;
    $cum_prob_m724 = 0.01;
    $cum_prob_m890 = 0.01;
    $cum_prob_m891 = 0.01;
    $cum_prob_m892 = 0.01;
    $cum_prob_m893 = 0.01;
    $cum_prob_m894 = 0.01;
    $cum_prob_m940 = 0.01;
    $cum_prob_m941 = 0.01;
    $cum_prob_m942 = 0.01;
    $cum_prob_m943 = 0.01;
    $cum_prob_m944 = 0.01;

    for $i ( 0 .. $#sed_yields ) {

        #  for $i (0..115) {						# DEH test 2005.10.21
        # untreated
        $cum_prob0 += @probabilities0[ @index[$i] ];
        $cum_prob1 += @probabilities1[ @index[$i] ];
        $cum_prob2 += @probabilities2[ @index[$i] ];
        $cum_prob3 += @probabilities3[ @index[$i] ];
        $cum_prob4 += @probabilities4[ @index[$i] ];

        # seeding
        $cum_prob_s0 += @probabilities_s0[ @index[$i] ];
        $cum_prob_s1 += @probabilities_s1[ @index[$i] ];
        $cum_prob_s2 += @probabilities_s2[ @index[$i] ];
        $cum_prob_s3 += @probabilities_s3[ @index[$i] ];
        $cum_prob_s4 += @probabilities_s4[ @index[$i] ];

        # mulch 47%
        $cum_prob_m470 += @probabilities_m470[ @index[$i] ];
        $cum_prob_m471 += @probabilities_m471[ @index[$i] ];
        $cum_prob_m472 += @probabilities_m472[ @index[$i] ];
        $cum_prob_m473 += @probabilities_m473[ @index[$i] ];
        $cum_prob_m474 += @probabilities_m474[ @index[$i] ];

        # mulch 72%
        $cum_prob_m720 += @probabilities_m720[ @index[$i] ];
        $cum_prob_m721 += @probabilities_m721[ @index[$i] ];
        $cum_prob_m722 += @probabilities_m722[ @index[$i] ];
        $cum_prob_m723 += @probabilities_m723[ @index[$i] ];
        $cum_prob_m724 += @probabilities_m724[ @index[$i] ];

        # mulch 89%
        $cum_prob_m890 += @probabilities_m890[ @index[$i] ];
        $cum_prob_m891 += @probabilities_m891[ @index[$i] ];
        $cum_prob_m892 += @probabilities_m892[ @index[$i] ];
        $cum_prob_m893 += @probabilities_m893[ @index[$i] ];
        $cum_prob_m894 += @probabilities_m894[ @index[$i] ];

        # mulch 94%
        $cum_prob_m940 += @probabilities_m940[ @index[$i] ];
        $cum_prob_m941 += @probabilities_m941[ @index[$i] ];
        $cum_prob_m942 += @probabilities_m942[ @index[$i] ];
        $cum_prob_m943 += @probabilities_m943[ @index[$i] ];
        $cum_prob_m944 += @probabilities_m944[ @index[$i] ];
        $j      = $i + 1;
        $scheme = @scheme[ @index[$i] ];       # 2005.10.25 DEH
        $sedval = @sed_yields[ @index[$i] ];
        if ( $sedval eq '' )    { $sedval = '0.0' }
        if ( $sedval =~ /^\*/ ) { $sedval = '99' }
        print "sed_del[$j] = $sedval; scheme[$j] = '$scheme'\n";    # 2005.10.25 DEH
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

function whatseds (target, array) {

// 2005.10.27 DEH
// arguments
//    target		probability target
//    array[]		array containing cumulative probability values matching sed_del[]
// reads
//    sed_del[]		sediment delivery values corresponding to cum. probs in array[]
//				note that there may be noise in the sed_del and array arrays --
//				sed_dels with no increased cum. prob. should be ignored.

  var diff_fuzz=0.0001	// mathematical fuzz tolerable for diff
  var diff=0		// difference between bounding probabilities
  var k=1		// index into array[] and sed_del[]
  var less=array[k]	// current cumulative probability that is less than target
  var gotit=0
  var prop=0		// proportion of the way that target is between bounding cum. probability values

  while (k <= array.length && gotit == 0) {
    if (array[k] >= target) {
      gotit = 1
      diff=Math.abs(array[k] - less)
      if (diff < diff_fuzz) {
        sed = sed_del[k]
      }
      else {
        prop = (array[k] - target) / diff    // poss math problem
        sed = sed_del[k] - (sed_del[k] - sedless) * prop
      }
      return sed
    }
    if (gotit == 0) {
      if (array[k]>less) {less=array[k]; sedless=sed_del[k]}
      k = k + 1
    }
  } 
  return 0				// 2005.12.30 DEH
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

// 2006.02.17 DEH User now enters spacing between offset rows (half of original spec)

// READS
//	document.doit.i10.value				10-min peak intensity (mm h-1)
//	document.doit.diameter.value			log or wattle diameter (m or ft)
//	document.doit.spacing.value			spacing between rows of logs or wattles (m or ft)
//	js_units
//	js_avg_slope
//	js_soil_texture					'clay loam', 'silt loam', 'sandy loam' or 'loam'
//	document.getElementById('sediment0').innerHTML	no-treatment sediment value 1st year following fire
//	document.getElementById('sediment1').innerHTML	no-treatment sediment value 2nd year following fire
//	document.getElementById('sediment2').innerHTML	no-treatment sediment value 3rd year following fire
//	document.getElementById('sediment3').innerHTML	no-treatment sediment value 4th year following fire
//	document.getElementById('sediment4').innerHTML	no-treatment sediment value 5th year following fire

// SETS
//	document.doit.diameter.value			   diameter of logs or wattles
//	document.doit.spacing.value			   spacing between rows (if out of range)
//	document.doit.slope.value			   hillslope gradient set (if out of range)
//      document.getElementById('sediment_cl0').innerHTML  no-treatment sediment value 1st year following fire
//      document.getElementById('sediment_cl1').innerHTML  no-treatment sediment value 1st year following fire
//      document.getElementById('sediment_cl2').innerHTML  no-treatment sediment value 1st year following fire
//      document.getElementById('sediment_cl3').innerHTML  no-treatment sediment value 1st year following fire
//      document.getElementById('sediment_cl4').innerHTML  no-treatment sediment value 1st year following fire
//      document.doit.capacity.value			   maximum holding capacity (Mg ha -1 or ton ac -1)

   var diameter=document.doit.diameter.value	// DEH 2005.09
   var spacing=document.doit.spacing.value	// DEH 2005.09
   var i10=document.doit.i10.value		// DEH 2005.09

// set minima, maxima, and default values for slope, spacing, and diameter user input values

   var slope_max = 100		// %
   var slope_min = 0.05		// %
   var spacing_min = 1.5	// m
   var spacing_max = 25		// m
   var spacing_def = 5		// m
   var diam_min = 0.05		// m
   var diam_max = 1		// m
   var diam_def = 0.3		// m

   if (js_units == 'ft') {
     spacing_min = 5		// ft
     spacing_max = 82	  	// ft
     spacing_def = 20		// ft
     diam_min = 0.15		// ft
     diam_max = 3.5		// ft
     diam_def = 1		// ft
   }

// do a bit of error-checking on form values

   if (!isNumber (diameter)){diameter = diam_def; document.doit.diameter.value=diameter}
   if (!isNumber (spacing)) {spacing = spacing_def; document.doit.spacing.value=spacing}
   if (diameter < diam_min) {diameter = diam_min; document.doit.diameter.value=diameter}
   if (diameter > diam_max) {diameter = diam_max; document.doit.diameter.value=diameter}
   if (spacing < spacing_min) {spacing = spacing_min; document.doit.spacing.value=spacing}
   if (spacing > spacing_max) {spacing = spacing_max; document.doit.spacing.value=spacing}

// temporary -- should be OK

   if (!isNumber (js_avg_slope)) {js_avg_slope = 10; document.doit.slope.value=js_avg_slope} // ***
   if (js_avg_slope>slope_max) {js_avg_slope = slope_max} // ???

// fill in metric-unit variables (convert if necessary)

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

// if slope is too flat, retain sediment produced

     document.getElementById('sediment_cl0').innerHTML = sediment_0
     document.getElementById('sediment_cl1').innerHTML = sediment_1
     document.getElementById('sediment_cl2').innerHTML = sediment_2
     document.getElementById('sediment_cl3').innerHTML = sediment_3
     document.getElementById('sediment_cl4').innerHTML = sediment_4
   }
   else {

//   coefficients from measured data; form of equation based on geometry
//     capacity in m^3/ha = a / slope_in_percent + b * diam^2_in_cm^2 + c / spacing_in_m + d

     sediment_bulk_density=1
     if (js_soil_texture == 'clay loam') sediment_bulk_density = 1.1	// g/m^3
     if (js_soil_texture == 'silt loam') sediment_bulk_density = 0.97
     if (js_soil_texture == 'sandy loam') sediment_bulk_density = 1.23
     if (js_soil_texture == 'loam') sediment_bulk_density = 1.16
     coeff_slope = 1342			// slope in whole percent i.e. '30'
     coeff_diam = 0.0029		// diam^2 for diam in cm
     coeff_spacing = 272		// spacing in m
     intercept = -35.4
     capacity_vol = coeff_slope/js_avg_slope+coeff_diam*diam_cm*diam_cm+coeff_spacing/spacing_m+intercept
     if (capacity_vol<0) {capacity_vol=0}

     capacity_m = capacity_vol * sediment_bulk_density		// capacity in Mg/ha
     capacity = capacity_m
     if (js_units == 'ft') {capacity=0.4461*capacity_m} 	// capacity in user units ton/ac or Mg/ha

     document.doit.capacity.value=capacity			// DEH 2005.09

// set efficiency of barriers by year
// years 1 and 2 after fire related to i10; subsequent years taper off

     var eff_0 = 113.97-0.8425*i10;  if (eff_0<0) {eff_0=0}; if (eff_0>100) {eff_0=100}
     var eff_1 = 116-1.4*i10;        if (eff_1<0) {eff_1=0}; if (eff_1>100) {eff_1=100}
     var eff_2 = eff_1 * 0.75;   //  if (eff_2<0) {eff_2=0}; if (eff_2>100) {eff_2=100}
     var eff_3 = eff_2 * 0.55;   //  if (eff_3<0) {eff_3=0}; if (eff_3>100) {eff_3=100}
     var eff_4 = eff_3 * 0.45;   //  if (eff_4<0) {eff_4=0}; if (eff_4>100) {eff_4=100}

// sediment caught is capacity (Mg/ha or ton/ac) * efficiency, but not more than what is produced

     var caught_0 = capacity * eff_0/100; if (caught_0>sediment_0) {caught_0=sediment_0}
     var caught_1 = capacity * eff_1/100; if (caught_1>sediment_1) {caught_1=sediment_1}
     var caught_2 = capacity * eff_2/100; if (caught_2>sediment_2) {caught_2=sediment_2}
     var caught_3 = capacity * eff_3/100; if (caught_3>sediment_3) {caught_3=sediment_3}
     var caught_4 = capacity * eff_4/100; if (caught_4>sediment_4) {caught_4=sediment_4}

     document.getElementById('sediment_cl0').innerHTML = rounder(sediment_0-caught_0,2)
     document.getElementById('sediment_cl1').innerHTML = rounder(sediment_1-caught_1,2)
     document.getElementById('sediment_cl2').innerHTML = rounder(sediment_2-caught_2,2)
     document.getElementById('sediment_cl3').innerHTML = rounder(sediment_3-caught_3,2)
     document.getElementById('sediment_cl4').innerHTML = rounder(sediment_4-caught_4,2)
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

}

function probchange () {

  var myprob=document.doit.probability0x.value
  if (!isNumber (myprob)) {myprob = 20}		// 2012.06.27
  if (myprob < 1.0)       {myprob = 1.0}
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

   logchange()	// 2005.10.21 DEH


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

// 2013.06.27 allow for unburned condition reporting
// to do: report WEPP unique run number -- done
// 2005.10.25 DEH add column for permutation (event/spatial/soil) and reduce font size
// 2005.10.24 DEH to remove noise, and tidy up HTML code generated
// display sediment delivery vs. cumulative probability (5 years) table
// for no-mitigation, seeding, or mulching

// which:  Cumulative probability array base name
// where:  browser window ID (no spaces)
// what:  'Untreated', 'Seeding', or 'Mulching' 

  var0 = eval(which + '0')
  var1 = eval(which + '1')
  var2 = eval(which + '2')
  var3 = eval(which + '3')
  var4 = eval(which + '4')
  newin = window.open('',where,'width=600,height=300,scrollbars=yes,resizable=yes')
  newin.document.open()
  newin.document.writeln('<HTML>')
  newin.document.writeln(' <HEAD>')
  newin.document.writeln('  <title>ERMiT '+what+' probability table<\/title>')
  newin.document.writeln(' <\/HEAD>')
  newin.document.writeln(' <body bgcolor="ivory" onLoad="top.window.focus()">')
  newin.document.writeln('  <font face="Tahoma, Arial, Helvetica, sans serif" size=-1>')
  newin.document.writeln('   <h4>Erosion Risk Management Tool: '+what+'<\/h4>')
  newin.document.writeln('   '+js_climate_name+'<br>'+js_soil_texture+'; '+js_rfg+'% rock; '+js_top_slope+'%, '+js_avg_slope+'%, '+js_toe_slope+'% slope; '+js_hillslope_length+' '+ js_units+'; '+js_severityclass_xx+'<br>[Run ID '+js_unique+']')
  newin.document.writeln('   <table border=1 cellpadding=3>')
  newin.document.writeln('    <tr><th rowspan=2 bgcolor=ffff99><font face="Tahoma, Arial, Helvetica, sans serif" size=1>Sediment<br>delivery<br>('+js_alt_sedunits+')<\/th>')
  newin.document.writeln('     <th colspan=5 bgcolor=ffff99><font face="Tahoma, Arial, Helvetica, sans serif" size=1>Percent chance that sediment delivery will be exceeded<\/th>')
  newin.document.writeln('     <th rowspan=2 bgcolor=ffff99><font face="Tahoma, Arial, Helvetica, sans serif" size=1>Permutation<br><font size=-2>Event rank<br>Spatial burn<br>Soil class<\/font><\/th><\/tr>')
  newin.document.writeln('    <tr><th bgcolor=ffff99><font face="Tahoma, Arial, Helvetica, sans serif" size=1>1st year<\/th>')
  newin.document.writeln('     <th bgcolor=ffff99><font face="Tahoma, Arial, Helvetica, sans serif" size=1>2nd year<\/th>')
  newin.document.writeln('     <th bgcolor=ffff99><font face="Tahoma, Arial, Helvetica, sans serif" size=1>3rd year<\/th>')
  newin.document.writeln('     <th bgcolor=ffff99><font face="Tahoma, Arial, Helvetica, sans serif" size=1>4th year<\/th>')
  newin.document.writeln('     <th bgcolor=ffff99><font face="Tahoma, Arial, Helvetica, sans serif" size=1>5th year<\/th><\/tr>')
  seddel = sed_del[1] * js_sedconv  // kg / m to t / ac or t / ha
  newin.document.writeln('    <tr><td align=right bgcolor=ffff99><b><font face="Tahoma, Arial, Helvetica, sans serif" size=1>' + rounder(seddel,2)+'<\/b><\/td>')
    if (var0[1] == 0.01) {newin.document.writeln('     <td>&nbsp;<\/td>')} else {newin.document.writeln('     <td><font face="Tahoma, Arial, Helvetica, sans serif" size=1>' + rounder(var0[1]*100,2)+'<\/td>')}
    if (var1[1] == 0.01) {newin.document.writeln('     <td>&nbsp;<\/td>')} else {newin.document.writeln('     <td><font face="Tahoma, Arial, Helvetica, sans serif" size=1>' + rounder(var1[1]*100,2)+'<\/td>')}
    if (var2[1] == 0.01) {newin.document.writeln('     <td>&nbsp;<\/td>')} else {newin.document.writeln('     <td><font face="Tahoma, Arial, Helvetica, sans serif" size=1>' + rounder(var2[1]*100,2)+'<\/td>')}
    if (var3[1] == 0.01) {newin.document.writeln('     <td>&nbsp;<\/td>')} else {newin.document.writeln('     <td><font face="Tahoma, Arial, Helvetica, sans serif" size=1>' + rounder(var3[1]*100,2)+'<\/td>')}
    if (var4[1] == 0.01) {newin.document.writeln('     <td>&nbsp;<\/td>')} else {newin.document.writeln('     <td><font face="Tahoma, Arial, Helvetica, sans serif" size=1>' + rounder(var4[1]*100,2)+'<\/td>')}
  newin.document.writeln('    <td align=right><font face="Tahoma, Arial, Helvetica, sans serif" size=1>' + scheme[1]+'<\/td>')
  newin.document.writeln('    <\/tr>')
  for (var i=2; i<= sed_del.length; i++) {
    seddel = sed_del[i] * js_sedconv  // kg / m to t / ac or t / ha
    newin.document.writeln('    <tr><td align=right bgcolor=ffff99><b><font face="Tahoma, Arial, Helvetica, sans serif" size=1>' + rounder(seddel,2)+'<\/b><\/td>')
    if (var0[i] == var0[i-1]) {newin.document.writeln('     <td>&nbsp;<\/td>')} else {newin.document.writeln('     <td><font face="Tahoma, Arial, Helvetica, sans serif" size=1>' + rounder(var0[i]*100,2)+'<\/td>')}
    if (var1[i] == var1[i-1]) {newin.document.writeln('     <td>&nbsp;<\/td>')} else {newin.document.writeln('     <td><font face="Tahoma, Arial, Helvetica, sans serif" size=1>' + rounder(var1[i]*100,2)+'<\/td>')}
    if (var2[i] == var2[i-1]) {newin.document.writeln('     <td>&nbsp;<\/td>')} else {newin.document.writeln('     <td><font face="Tahoma, Arial, Helvetica, sans serif" size=1>' + rounder(var2[i]*100,2)+'<\/td>')}
    if (var3[i] == var3[i-1]) {newin.document.writeln('     <td>&nbsp;<\/td>')} else {newin.document.writeln('     <td><font face="Tahoma, Arial, Helvetica, sans serif" size=1>' + rounder(var3[i]*100,2)+'<\/td>')}
    if (var4[i] == var4[i-1]) {newin.document.writeln('     <td>&nbsp;<\/td>')} else {newin.document.writeln('     <td><font face="Tahoma, Arial, Helvetica, sans serif" size=1>' + rounder(var4[i]*100,2)+'<\/td>')}
    newin.document.writeln('    <td align=right><font face="Tahoma, Arial, Helvetica, sans serif" size=1>' + scheme[i]+'<\/td>')
    newin.document.writeln('    <\/tr>')
////// 2006.03.10 DEH ISAAC //////
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
  newin.document.writeln('   <!--tool bar begins--><br><br>')
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
  newin.document.writeln('  <title>ERMiT event sediment delivery table<\/title>')
  newin.document.writeln(' <\/HEAD>')
  newin.document.writeln(' <body bgcolor="ivory" onLoad="top.window.focus()">')
  newin.document.writeln('  <font face="tahoma" size=-1> ')
  newin.document.writeln('   <h4>Erosion Risk Management Tool event sediment delivery table<\/h4>')
  newin.document.writeln('   '+js_climate_name+'<br>'+js_soil_texture+'; '+js_rfg+'% rock; '+js_top_slope+'%, '+js_avg_slope+'%, '+js_toe_slope+'% slope; '+js_hillslope_length+' '+ js_units+'; '+js_severityclass_xx+' <br>[Run ID '+js_unique+']')
// newin.document.writeln('   '+js_climate_name+'<br>'+js_soil_texture+'; '+js_rfg+'% rock; '+js_top_slope+'%, '+js_avg_slope+'%, '+js_toe_slope+'% slope; '+js_hillslope_length+' '+ js_units+'; '+js_severityclass_x+' soil burn severity<br>[Run ID '+js_unique+']')

  if (js_severityclass == 'u') {
// unburned	document.getElementById("sediment0").innerHTML
  newin.document.writeln('  <h3 align="center">Unburned<\/h3>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.getElementById("sediment0").innerHTML + ' '+js_alt_sedunits + ' in the first year.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.getElementById("sediment1").innerHTML + ' '+js_alt_sedunits + ' in the second year.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.getElementById("sediment2").innerHTML + ' '+js_alt_sedunits + ' in the third year.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.getElementById("sediment3").innerHTML + ' '+js_alt_sedunits + ' in the fourth year.<br>')
  newin.document.writeln('   There is a ' + probval+'% chance that sediment delivery will exceed ' + document.getElementById("sediment4").innerHTML + ' '+js_alt_sedunits + ' in the fifth year.<br>')
  } else {
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
  }
  newin.document.writeln('   <!--tool bar begins--><br><br>')
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
  newin.document.writeln('   <!--tool bar begins--><br><br>')
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

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

function log_prob () {

// read data from form fields into variables

// 2015.04.30 DEH

// READS
//	document.doit.i10.value				10-min peak intensity (mm h-1)
//	document.doit.diameter.value			log or wattle diameter (m or ft)
//	document.doit.spacing.value			spacing between rows of logs or wattles (m or ft)
//	js_units
//	js_avg_slope
//	js_soil_texture					'clay loam', 'silt loam', 'sandy loam' or 'loam'
//	document.getElementById('sediment0').innerHTML	no-treatment sediment value 1st year following fire
//	document.getElementById('sediment1').innerHTML	no-treatment sediment value 2st year following fire
//	document.getElementById('sediment2').innerHTML	no-treatment sediment value 3st year following fire
//	document.getElementById('sediment3').innerHTML	no-treatment sediment value 4st year following fire
//	document.getElementById('sediment4').innerHTML	no-treatment sediment value 5st year following fire

   var diameter=document.doit.diameter.value	// DEH 2005.09
   var spacing=document.doit.spacing.value	// DEH 2005.09
   var i10=document.doit.i10.value		// DEH 2005.09
   var badflag = 0 // *******************************************************

// diameter=2		// ??
// diameter = document.getElementById('diameter').innerHTML

// alert ('diameter = ' + diameter)
// alert ('units = ' + js_units)
// var incoming_prob = document.getElementById('probability0x').innerHTML
 var incoming_prob = document.doit.probability0x.value				//////////////////  2015   ////////////////
// alert ('Incoming probability = ' + incoming_prob)

//   var js_avg_slope=document.doit.slope.value	// DEH 2005.09.23 ***
//   alert (js_avg_slope)

// set minima, maxima, and default values for slope, spacing, and diameter user input values

   var slope_max = 100		// %
   var slope_min = 0.05		// %
   var spacing_min = 1.5	// m
   var spacing_max = 25		// m
   var spacing_def = 5		// m
   var diam_min = 0.05		// m
   var diam_max = 1		// m
   var diam_def = 0.3		// m

   if (js_units == 'ft') {
     spacing_min = 5		// ft
     spacing_max = 82	  	// ft
     spacing_def = 20		// ft
     diam_min = 0.15		// ft
     diam_max = 3.5		// ft
     diam_def = 1		// ft
   }

// alert ('log_prob')

prob_list = new MakeArray; prob_list.length = 19
prob_list[0] = 1
prob_list[1] = 5
prob_list[2] = 10
prob_list[3] = 15
prob_list[4] = 20
prob_list[5] = 25
prob_list[6] = 30
prob_list[7] = 35
prob_list[8] = 40
prob_list[9] = 45
prob_list[10] = 50
prob_list[11] = 55
prob_list[12] = 60
prob_list[13] = 65
prob_list[14] = 70
prob_list[15] = 75
prob_list[16] = 80
prob_list[17] = 85
prob_list[18] = 90
// prob_list[19] = incoming_prob			// or plug in incoming value...


// for (iprob = 0; iprob < prob_list.length; iprob++) { 

//  alert ('Setting probability at '+ prob_list[iprob])
//    document.getElementById('probability0x').innerHTML = 15			//////////////////  2015   ////////////////

// do a bit of error-checking on form values

   if (!isNumber (diameter))  {diameter = diam_def; document.doit.diameter.value=diameter}
   if (!isNumber (spacing))   {spacing = spacing_def; document.doit.spacing.value=spacing}
   if (diameter < diam_min)   {diameter = diam_min; document.doit.diameter.value=diameter}
   if (diameter > diam_max)   {diameter = diam_max; document.doit.diameter.value=diameter}
   if (spacing < spacing_min) {spacing = spacing_min; document.doit.spacing.value=spacing}
   if (spacing > spacing_max) {spacing = spacing_max; document.doit.spacing.value=spacing}

// temporary -- should be OK

   if (!isNumber (js_avg_slope)) {js_avg_slope = 10; document.doit.slope.value=js_avg_slope} // ***
   if (js_avg_slope>slope_max)   {js_avg_slope = slope_max} // ???

//alert ('js_avg_slope')

// fill in metric-unit variables (convert if necessary)

   var spacing_m = spacing
   var diameter_m = diameter
   if (js_units == 'ft') {
    spacing_m  = spacing  * 0.3048   // convert ft to m if necessary	// DEH 2005.09
    diameter_m = diameter * 0.3048   // convert ft to m if necessary	// DEH 2005.09
   }
   var diam_cm = diameter_m * 100	// log diameter in cm

// alert ('diameter = ' + diameter)
// alert ('units = ' + js_units)
  var newin2 = window.open('','ERMiTlogProbs','width=600,height=480,scrollbars=yes,resizable=yes')

  newin2.document.open()
  newin2.document.writeln('<HTML>')
  newin2.document.writeln(' <head>')
  newin2.document.writeln('  <title>ERMiT Logs & Wattles probabilities table<\/title>')
  newin2.document.writeln(' <\/HEAD>')
  newin2.document.writeln(' <body bgcolor="ivory" onLoad="top.window.focus()">')
  newin2.document.writeln('  <font face="tahoma" size=-1> ')
  newin2.document.writeln('   <h4>ERMiT Logs & Wattles probabilities table<\/h4>')
  newin2.document.writeln('   <font size=2>')
  newin2.document.writeln('    '+js_climate_name+'<br>'+js_soil_texture+'; '+js_rfg+'% rock; '+js_top_slope+'%, '+js_avg_slope+'%, '+js_toe_slope+'% slope; '+js_hillslope_length+' '+ js_units+'; '+js_severityclass_xx+'<br>[Run ID '+js_unique+']<br>')
  newin2.document.writeln('    i<sub>10</sub>='+i10+'<br>')
if (js_units == 'ft') {  newin2.document.writeln('    Diameter '+ diameter + ' ft, spacing ' + spacing + ' ft')}
else                  {  newin2.document.writeln('    Diameter '+ diameter +   ' m spacing ' + spacing + ' m')}
  newin2.document.writeln('   </font>')
  newin2.document.writeln('   <br>')
  newin2.document.writeln('    <table border=1>')
  newin2.document.writeln('     <tr><th rowspan=2>Probability that sediment yield will be exceeded</th><th colspan=5>Event sediment delivery</th></tr>')
  newin2.document.writeln('     <tr><th>1st year</th><th>2nd year</th><th>3rd year</th><th>4th year</th><th>5th year</th></tr>')

 for (iprob = 0; iprob < prob_list.length; iprob++) { 		// ******************************************

  document.doit.probability0x.value = prob_list[iprob]

//alert ('fff')

  probchange()

//alert ('ggg')

// get no-treatment sediment values from table

//  alert ('sediment_0 = '+sediment_0)

   sediment_0=document.getElementById('sediment0').innerHTML
   sediment_1=document.getElementById('sediment1').innerHTML
   sediment_2=document.getElementById('sediment2').innerHTML
   sediment_3=document.getElementById('sediment3').innerHTML
   sediment_4=document.getElementById('sediment4').innerHTML

////////////////////////// if slope is too flat or spacing too close, retain sediment produced

   if (js_avg_slope < slope_min || spacing_m < spacing_min) {

badflag = 1		// *******************************************************

// alert ('js_avg_slope = ' + js_avg_slope + ' < slope_min = ' + slope_min + '%')
// alert (' or spacing_m = ' + spacing_m + ' < spacing_min = ' + spacing_min + ' m')

//alert (' sediment_0 = ' + sediment_0)

     document.getElementById('sediment_cl0').innerHTML = sediment_0
     document.getElementById('sediment_cl1').innerHTML = sediment_1
     document.getElementById('sediment_cl2').innerHTML = sediment_2
     document.getElementById('sediment_cl3').innerHTML = sediment_3
     document.getElementById('sediment_cl4').innerHTML = sediment_4

     caught_0 = 0
     caught_1 = 0
     caught_2 = 0
     caught_3 = 0
     caught_4 = 0

   }
   else {

badflag = 0		// *******************************************************

//   coefficients from measured data; form of equation based on geometry
//     capacity in m^3/ha = a / slope_in_percent + b * diam^2_in_cm^2 + c / spacing_in_m + d

     sediment_bulk_density=1
     if (js_soil_texture == 'clay loam')  sediment_bulk_density = 1.1	// g/m^3
     if (js_soil_texture == 'silt loam')  sediment_bulk_density = 0.97
     if (js_soil_texture == 'sandy loam') sediment_bulk_density = 1.23
     if (js_soil_texture == 'loam')       sediment_bulk_density = 1.16
//   alert (js_soil_texture + ' sediment bulk density: ' + sediment_bulk_density)
     coeff_slope = 1342			// slope in whole percent i.e. '30'
     coeff_diam = 0.0029		// diam^2 for diam in cm
//   coeff_spacing = 544		// spacing in m
     coeff_spacing = 272		// spacing in m
     intercept = -35.4
     capacity_vol = coeff_slope/js_avg_slope+coeff_diam*diam_cm*diam_cm+coeff_spacing/spacing_m+intercept
     if (capacity_vol<0) {capacity_vol=0}

     capacity_m = capacity_vol * sediment_bulk_density		// capacity in Mg/ha
     capacity = capacity_m
     if (js_units == 'ft') {capacity=0.4461*capacity_m} 	// capacity in user units ton/ac or Mg/ha

     document.doit.capacity.value=capacity			// DEH 2005.09

// set efficiency of barriers by year
// years 1 and 2 after fire related to i10; subsequent years taper off

     var eff_0 = 113.97-0.8425*i10;  if (eff_0<0) {eff_0=0}; if (eff_0>100) {eff_0=100}
     var eff_1 = 116-1.4*i10;        if (eff_1<0) {eff_1=0}; if (eff_1>100) {eff_1=100}
     var eff_2 = eff_1 * 0.75;   //  if (eff_2<0) {eff_2=0}; if (eff_2>100) {eff_2=100}
     var eff_3 = eff_2 * 0.55;   //  if (eff_3<0) {eff_3=0}; if (eff_3>100) {eff_3=100}
     var eff_4 = eff_3 * 0.45;   //  if (eff_4<0) {eff_4=0}; if (eff_4>100) {eff_4=100}

// sediment caught is capacity (Mg/ha or ton/ac) * efficiency, but not more than what is produced

     var caught_0 = capacity * eff_0/100; if (caught_0>sediment_0) {caught_0=sediment_0}
     var caught_1 = capacity * eff_1/100; if (caught_1>sediment_1) {caught_1=sediment_1}
     var caught_2 = capacity * eff_2/100; if (caught_2>sediment_2) {caught_2=sediment_2}
     var caught_3 = capacity * eff_3/100; if (caught_3>sediment_3) {caught_3=sediment_3}
     var caught_4 = capacity * eff_4/100; if (caught_4>sediment_4) {caught_4=sediment_4}

     document.getElementById('sediment_cl0').innerHTML = rounder(sediment_0-caught_0,2)
     document.getElementById('sediment_cl1').innerHTML = rounder(sediment_1-caught_1,2)
     document.getElementById('sediment_cl2').innerHTML = rounder(sediment_2-caught_2,2)
     document.getElementById('sediment_cl3').innerHTML = rounder(sediment_3-caught_3,2)
     document.getElementById('sediment_cl4').innerHTML = rounder(sediment_4-caught_4,2)

//   alert ('sediment caught = ' + rounder(sediment_0-caught_0,2))

}

//  if (badflag) {  newin2.document.writeln('     <tr><td align=right> * ' + prob_list[iprob] + '<\/td> ') }    // ***************
  newin2.document.writeln('     <tr><td align=right>' + prob_list[iprob] + '<\/td> ') 
  newin2.document.writeln('         <td align=right>' + rounder(sediment_0-caught_0,2) + ' <\/td> ')
  newin2.document.writeln('         <td align=right>' + rounder(sediment_1-caught_1,2) + ' <\/td> ')
  newin2.document.writeln('         <td align=right>' + rounder(sediment_2-caught_2,2) + ' <\/td> ')
  newin2.document.writeln('         <td align=right>' + rounder(sediment_3-caught_3,2) + ' <\/td> ')
  newin2.document.writeln('         <td align=right>' + rounder(sediment_4-caught_4,2) + ' <\/td><\/tr> ')

  }
/////////////// 2015.04.30 //////////////
  newin2.document.writeln('    <\/table>')
  if (badflag) {newin2.document.writeln('js_avg_slope = ' + js_avg_slope + ' < slope_min = ' + slope_min + '% or spacing_m = ' + spacing_m + ' < spacing_min = ' + spacing_min + ' m -- retaining sediment produced') }    // ***************

  newin2.document.writeln('   <!--tool bar ends-->')
  newin2.document.writeln('  <\/font>')
  newin2.document.writeln(' <\/body>')
  newin2.document.writeln('</html>')
  newin2.document.close()

  document.doit.probability0x.value = incoming_prob
  probchange()

}

function logtable () {

// 2013.06.27

// INPUTS
//    i10		10-min peak intensity (mm h-1)
//    js_avg_slope
//    js_soil_texture	'clay loam' | 'silt loam' | 'sandy loam' | 'loam'
//    js_units		'm' | 'ft'

// REPORT ONLY

//    js_climate_name
//    js_rfg
//    js_top_slope
//    js_toe_slope
//    js_hillslope_length
//    js_severityclass_xx
//    js_unique

//    diameter
//    spacing

   var i10=document.doit.i10.value

   var spacing  = new MakeArray;  spacing.length = 5
   var diameter = new MakeArray; diameter.length = 5
   var eff      = new MakeArray;      eff.length = 5
   var sediment = new MakeArray; sediment.length = 5

   sediment[0]=document.getElementById('sediment0').innerHTML
   sediment[1]=document.getElementById('sediment1').innerHTML
   sediment[2]=document.getElementById('sediment2').innerHTML
   sediment[3]=document.getElementById('sediment3').innerHTML
   sediment[4]=document.getElementById('sediment4').innerHTML

   if (js_units == 'm') {
     spacing[0] = 3		// m
     spacing[1] = 5		// m
     spacing[2] = 10		// m
     spacing[3] = 25		// m
     spacing[4] = 50		// m
     diameter[0] = 0.05		// m
     diameter[1] = 0.1		// m
     diameter[2] = 0.3		// m
     diameter[3] = 0.5		// m
     diameter[4] = 1		// m
   }
   else {
     spacing[0] = 3.048		// m  10'
     spacing[1] = 7.620		// m  25'
     spacing[2] = 15.24		// m  50'
     spacing[3] = 22.86		// m  75'
     spacing[4] = 45.72		// m 150'
//   diameter[0] = 0.0457	// m 0.15' (1.8")
//   diameter[1] = 0.091	// m 0.30' (3.6")
     diameter[0] = 0.0508	// m 0.17' (2")
     diameter[1] = 0.1524	// m 0.5' (6")
     diameter[2] = 0.3048	// m 1' (12")
     diameter[3] = 0.4572	// m 1.5' (18")
     diameter[4] = 0.9144	// m 3' (36")
   }

    height=500;
    width=660;
    log_table = window.open('','logtable','toolbar=no,location=no,status=no,directories=no,menubar=no,scrollbars=yes,resizable=yes,width='+width+',height='+height);
    log_table.document.writeln('<html>')
    log_table.document.writeln(' <head>')
    log_table.document.writeln('  <title>ERMiT contour-felled log/straw wattle table</title>')
    log_table.document.writeln(' </head>')
    log_table.document.writeln(' <body bgcolor=white>')
    log_table.document.writeln('  <font face="trebuchet, tahoma, arial, helvetica, sans serif">')
    log_table.document.writeln('  <center>')
    log_table.document.writeln('   <h4>Erosion Risk Management Tool: contour-felled log/straw wattle</h4>')
    log_table.document.writeln('  </center>')
    log_table.document.writeln('   <font size=2>')
    log_table.document.writeln('    '+js_climate_name+'<br>'+js_soil_texture+'; '+js_rfg+'% rock; '+js_top_slope+'%, '+js_avg_slope+'%, '+js_toe_slope+'% slope; '+js_hillslope_length+' '+ js_units+'; '+js_severityclass_xx+'<br>[Run ID '+js_unique+']<br>')
    log_table.document.writeln('    i<sub>10</sub>='+i10)
    log_table.document.writeln('   </font>')
    log_table.document.writeln('   <br><br>')

//   coefficients from measured data; form of equation based on geometry
//     capacity in m^3/ha = a / slope_in_percent + b * diam^2_in_cm^2 + c / spacing_in_m + d

//   alert (js_soil_texture + ' sediment bulk density: ' + sediment_bulk_density)

    var m_conv=3.28084
    var cap_conv=0.4461
    if (js_units=='m') {m_conv=1; cap_conv=1}  // m -> ft and t/ha -> ton/ac
    var cap_units='ton ac<sup>-1</sup>'
    if (js_units=='m') {cap_units='t ha<sup>-1</sup>'}

   var capacity_vol=0
   var coeff_slope = 1342		// slope in whole percent i.e. '30'
   var coeff_diam = 0.0029		// diam^2 for diam in cm
// var coeff_spacing = 544		// spacing in m
   var coeff_spacing = 272		// spacing in m
   var intercept = -35.4
   var sediment_bulk_density=1
   if (js_soil_texture == 'clay loam') sediment_bulk_density = 1.1	// g/m^3
   if (js_soil_texture == 'silt loam') sediment_bulk_density = 0.97
   if (js_soil_texture == 'sandy loam') sediment_bulk_density = 1.23
   if (js_soil_texture == 'loam') sediment_bulk_density = 1.16

   eff[0] = 113.97-0.8425*i10;   if (eff[0]<0) {eff[0]=0}; if (eff[0]>100) {eff[0]=100}
   eff[1] = 116-1.4*i10;         if (eff[1]<0) {eff[1]=0}; if (eff[1]>100) {eff[1]=100}
   eff[2] = eff[1] * 0.75;   //  if (eff[2]<0) {eff[2]=0}; if (eff[2]>100) {eff[2]=100}
   eff[3] = eff[2] * 0.55;   //  if (eff[3]<0) {eff[3]=0}; if (eff[3]>100) {eff[3]=100}
   eff[4] = eff[3] * 0.45;
   eff[5] = 100;

   for (yr=0; yr<6; yr++) {
     log_table.document.writeln('  <table cellpadding=2 bgcolor=ivory border=1>')
     log_table.document.writeln('    <tr>')
     if (eff[yr]==100) {
       log_table.document.writeln('     <th bgcolor=#33ccff><font size=3>&nbsp;</font></th>')
       log_table.document.writeln('     <th bgcolor=#33ccff colspan='+diameter.length+'><font size=2>')
       log_table.document.writeln('      Theoretical capacity ('+cap_units+')')
     }
     else {
       spanner=diameter.length+1
//       log_table.document.writeln('     <th bgcolor=#33ccff><font size=3>YEAR '+yr+'</font></th>')
       if (yr==0) log_table.document.writeln('     <th bgcolor=#33ccff colspan='+spanner+'><font size=3>1st year</font></th>')
       if (yr==1) log_table.document.writeln('     <th bgcolor=#33ccff colspan='+spanner+'><font size=3>2nd year</font></th>')
       if (yr==2) log_table.document.writeln('     <th bgcolor=#33ccff colspan='+spanner+'><font size=3>3rd year</font></th>')
       if (yr==3) log_table.document.writeln('     <th bgcolor=#33ccff colspan='+spanner+'><font size=3>4th year</font></th>')
       if (yr==4) log_table.document.writeln('     <th bgcolor=#33ccff colspan='+spanner+'><font size=3>5th year</font></th>')
       log_table.document.writeln('     </tr>')
       log_table.document.writeln('     <tr>')
       log_table.document.writeln('      <th bgcolor=#33ccff><font size=-2>Untreated '+rounder(sediment[yr],2)+'</font></th>')
 


       log_table.document.writeln('     <th bgcolor=#33ccff colspan='+diameter.length+'><font size=2>')
       log_table.document.writeln('      Maximum caught ('+cap_units+')')
     }
     log_table.document.writeln('     </font></th>')
     log_table.document.writeln('    </tr>')
     log_table.document.writeln('    <tr>')
     log_table.document.writeln('     <th bgcolor=#33ccff><font size=2>'+rounder(eff[yr],0)+'% efficient</font></th>')
     log_table.document.writeln('     <th bgcolor=#33ccff colspan='+diameter.length+'><font size=2>Diameter ('+js_units+')</font></th>')
     log_table.document.writeln('    </tr>')
     log_table.document.writeln('    <tr>')
     log_table.document.writeln('     <th bgcolor=#33ccff><font size=2>Spacing ('+js_units+')</font></th>')
     for (diam=0; diam<diameter.length; diam++) {
       log_table.document.writeln('    <th bgcolor=#33ccff><font size=2>'+rounder(diameter[diam]*m_conv,2)+'</font></th>')
     }
     for (spac=0; spac<spacing.length; spac++) {
       log_table.document.writeln('   <tr>')
       log_table.document.writeln('    <th bgcolor=#33ccff><font size=2>'+rounder(spacing[spac]*m_conv,0)+'</font></th>')
       for (diam=0; diam<diameter.length; diam++) {
         diam_cm = diameter[diam] * 100		// log diameter in cm
         capacity_vol = coeff_slope/js_avg_slope+coeff_diam*diam_cm*diam_cm+coeff_spacing/spacing[spac]+intercept
         if (capacity_vol<0) {capacity_vol=0}
         capacity = capacity_vol * sediment_bulk_density * cap_conv		// capacity in Mg/ha or ton/ac
//       capacity = capacity_m
//       if (js_units == 'ft') {capacity=0.4461*capacity_m} 	// capacity in user units ton/ac or Mg/ha
         max_caught = capacity * eff[yr]/100; // if (max_caught>sediment[yr]) {max_caught=sediment[yr]}
         log_table.document.writeln('    <td align=right><font size=2>'+rounder(max_caught,2)+'</font></td>')
       }	// for (diam)
       log_table.document.writeln('   </tr>')
     }	// for (spac)
     log_table.document.writeln('   </table>')
     log_table.document.writeln('  <br>')
   }	// for (yr)
   log_table.document.writeln('   </font>')
   log_table.document.writeln('  </center>')
   log_table.document.writeln(' </body>')
   log_table.document.writeln('</html>')
   log_table.document.close()
   log_table.focus()
}

  function explain_log_spacing () {

    logwin = window.open('','ermit_help','width=400,height=500,scrollbars=yes,resizable=1')
    var logWin = logwin.document.open()
    if (logWin != null) {
      logwin.document.writeln('<HTML>')
      logwin.document.writeln(' <HEAD>')
      logwin.document.writeln('  <title>ERMiT log and wattle spacing</title>')
      logwin.document.writeln('  <style>')
      logwin.document.writeln('   BODY')
      logwin.document.writeln('   {scrollbar-base-color:666666;scrollbar-face-color:#333333;scrollbar-highlight-color:#333333;scrollbar-shadow-color:666666;scrollbar-dark-shadow-color:ffffcc;scrollbar-arrow-color:ff6600}')
      logwin.document.writeln('   .question {color:ffffcc}')
      logwin.document.writeln('   .header {color:ffffcc}')
      logwin.document.writeln('   .highlight {font-weight:bold}')
      logwin.document.writeln('  </style>')
      logwin.document.writeln(' </HEAD>')
      logwin.document.writeln(' <body bgcolor="ivory" onLoad="top.window.focus()" link="white" vlink="white">')
      logwin.document.writeln('  <font face="tahoma, sans serif">')
      logwin.document.writeln('   <h4>ERMiT log and wattle spacing</h4>')
      logwin.document.writeln('    <img src="/fswepp/images/ermit/spacing300.jpg" width="300" height="200"')
      logwin.document.writeln(' <font size=2>')
//    logwin.document.writeln(' ERMiT v. ' + version + ' <i>explain_log_spacing</i>')
      logwin.document.writeln(' </font>')
      logwin.document.writeln('<!--tool bar begins--><br><br>')
      logwin.document.writeln('  <table bgcolor="#666666" width="40%" border="0" cellspacing="1" cellpadding="5" align="center">')
      logwin.document.writeln('   <tr>')
      logwin.document.writeln('    <td align="center" bgcolor="#333333" onMouseOver="this.style.backgroundColor=\'#000000\';" onMouseOut="this.style.backgroundColor=\'\';"><font face="verdana,arial,helvetica" size="1"><img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.print()">Print me</a></font></td>')
      logwin.document.writeln('    <td align="center" bgcolor="#333333" onMouseOver="this.style.backgroundColor=\'#000000\';" onMouseOut="this.style.backgroundColor=\'\';"><font face="verdana,arial,helvetica" size="1"><img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.close()">Close me</a></font></td>')
      logwin.document.writeln('   </tr>')
      logwin.document.writeln('  </table>')
      logwin.document.writeln('<!--tool bar ends-->')
      logwin.document.writeln(' </body>')
      logwin.document.writeln('</html>')
      logwin.document.close()
    }
  }

EOP

    print "

function showpt() {
// 2013.06.27 allow for ununburned condition report
  newinpt = window.open('','pt','width=600,height=300,scrollbars=yes,resizable=yes')
  newinpt.document.open()
  newinpt.document.writeln('<HTML>')
  newinpt.document.writeln(' <HEAD>')
  newinpt.document.writeln('  <title>ERMiT probability table<\/title>')
  newinpt.document.writeln(' <\/HEAD>')
  newinpt.document.writeln(' <body bgcolor=\"ivory\" onLoad=\"top.window.focus()\">')
  newinpt.document.writeln('  <font face=\"Tahoma, Arial, Helvetica, sans serif\" size=-1>')
  newinpt.document.writeln('   <h4>Erosion Risk Management Tool probability table<\/h4>')
  newinpt.document.writeln('   '+js_climate_name+'<br>'+js_soil_texture+'; '+js_rfg+'% rock; '+js_top_slope+'%, '+js_avg_slope+'%, '+js_toe_slope+'% slope; '+js_hillslope_length+' '+ js_units+'; '+js_severityclass_xx+'<br>[Run ID '+js_unique+']')
  newinpt.document.writeln('     <table cellpadding=2 bgcolor=ivory>')
  newinpt.document.writeln('      <tr>')
  newinpt.document.writeln('       <th colspan=5><font size=2>SEDIMENT DELIVERY (",
      $sedunits, ")</font></th>')
  newinpt.document.writeln('       <th><font size=2>Spatial (1st .. 5th yr)</font></th>')
  newinpt.document.writeln('      </tr>')
";
    for $c ( 0 .. $#selected_year ) {
        print "  newinpt.document.writeln('     <tr>')\n";
        print "  newinpt.document.writeln('      <th align=left bgcolor=",
          @color[$c], " colspan=5><font size=1>Rank ", @selected_ranks[$c] + 1,
          " -- ", @monthnames[ @month[$c] ], " ", @day[$c], " year ",
          @selected_year[$c], " (", @probClimate[$c] * 100,
          "%)</font></th>')\n";

#   print "  newinpt.document.writeln('      <th align=left bgcolor=#ffff99 colspan=5><font size=1>", @selected_ranks[$c] + 1," (",100/(@selected_ranks[$c] + 1),"-year) -- ",@day[$c]," ",@monthnames[@month[$c]]," year ",@selected_year[$c]," (",@probClimate[$c]*100,"%)</font></th>')\n";
        print "  newinpt.document.writeln('     <td></td>')\n";
        print "  newinpt.document.writeln('    </tr>')\n";
        for $sn ( 0 .. $#severe ) {    # 2005.10.13 DEH
            print "  newinpt.document.writeln('    <tr>')\n";
            for $k ( 0 .. 4 ) {
                @sed_yields[$sp] = $sedtable[$c][$k][$sn];
                if ( $units eq 'ft' )
                {    # convert sediment yield kg / m to ton / ac
                    $sed_yield = @sed_yields[$sp] / $hillslope_length * 4.45;
                }
                else {    # convert sediment yield kg per m to t per ha
                    $sed_yield = @sed_yields[$sp] / $hillslope_length * 10;
                }
                $sed_yield_f = sprintf '%6.2f', $sed_yield;
                print
"  newinpt.document.writeln('     <td align=right><font size=1>$sed_yield_f</font></td>')\n";
                $sp += 1;
            }    # for ($k)
            print "  newinpt.document.writeln('        <td bgcolor=",
              @color[5], "><font size=1>", uc( @severe[$sn] ), " (",
              $probspatial[0][$sn] * 100, "%) ", " (",
              $probspatial[1][$sn] * 100, "%) ", " (",
              $probspatial[2][$sn] * 100, "%) ", " (",
              $probspatial[3][$sn] * 100, "%) ", " (",
              $probspatial[4][$sn] * 100, "%)</font></td>')\n";
            print "  newinpt.document.writeln('       </tr>')\n";
        }    # for ($sn)
    }    # for ($c)
    print '  newinpt.document.writeln("    <tr>")
  newinpt.document.writeln("     <td align=right><font size=1>soil 1</font></td>")
  newinpt.document.writeln("     <td align=right><font size=1>soil 2</font></td>")
  newinpt.document.writeln("     <td align=right><font size=1>soil 3</font></td>")
  newinpt.document.writeln("     <td align=right><font size=1>soil 4</font></td>")
  newinpt.document.writeln("     <td align=right><font size=1>soil 5</font></td>")
  newinpt.document.writeln("     <td></td>")
  newinpt.document.writeln("    </tr>")
  newinpt.document.writeln("    <tr><td align=right bgcolor=', @color[5],
      '><font size=1>(', $probSoil0[0] * 100, '%)</font></td>")
  newinpt.document.writeln("     <td align=right bgcolor=', @color[5],
      '><font size=1>(', $probSoil0[1] * 100, '%)</font></td>")
  newinpt.document.writeln("     <td align=right bgcolor=', @color[5],
      '><font size=1>(', $probSoil0[2] * 100, '%)</font></td>")
  newinpt.document.writeln("     <td align=right bgcolor=', @color[5],
      '><font size=1>(', $probSoil0[3] * 100, '%)</font></td>")
  newinpt.document.writeln("     <td align=right bgcolor=', @color[5],
      '><font size=1>(', $probSoil0[4] * 100, '%)</font></td>")
  newinpt.document.writeln("     <td><font size=1>1st year</font></td></tr>")
  newinpt.document.writeln("    <tr><td align=right bgcolor=', @color[5],
      '><font size=1>(', $probSoil1[0] * 100, '%)</font></td>")
  newinpt.document.writeln("     <td align=right bgcolor=', @color[5],
      '><font size=1>(', $probSoil1[1] * 100, '%)</font></td>")
  newinpt.document.writeln("     <td align=right bgcolor=', @color[5],
      '><font size=1>(', $probSoil1[2] * 100, '%)</font></td>")
  newinpt.document.writeln("     <td align=right bgcolor=', @color[5],
      '><font size=1>(', $probSoil1[3] * 100, '%)</font></td>")
  newinpt.document.writeln("     <td align=right bgcolor=', @color[5],
      '><font size=1>(', $probSoil1[4] * 100, '%)</font></td>")
  newinpt.document.writeln("     <td><font size=1>2nd year</font></td></tr>")
  newinpt.document.writeln("    <tr><td align=right bgcolor=', @color[5],
      '><font size=1>(', $probSoil2[0] * 100, '%)</font></td>")
  newinpt.document.writeln("     <td align=right bgcolor=', @color[5],
      '><font size=1>(', $probSoil2[1] * 100, '%)</font></td>")
  newinpt.document.writeln("     <td align=right bgcolor=', @color[5],
      '><font size=1>(', $probSoil2[2] * 100, '%)</font></td>")
  newinpt.document.writeln("     <td align=right bgcolor=', @color[5],
      '><font size=1>(', $probSoil2[3] * 100, '%)</font></td>")
  newinpt.document.writeln("     <td align=right bgcolor=', @color[5],
      '><font size=1>(', $probSoil2[4] * 100, '%)</font></td>")
  newinpt.document.writeln("     <td><font size=1>3rd year</font></td></tr>")
  newinpt.document.writeln("   <tr><td align=right bgcolor=', @color[5],
      '><font size=1>(', $probSoil3[0] * 100, '%)</font></td>")
  newinpt.document.writeln("     <td align=right bgcolor=', @color[5],
      '><font size=1>(', $probSoil3[1] * 100, '%)</font></td>")
  newinpt.document.writeln("     <td align=right bgcolor=', @color[5],
      '><font size=1>(', $probSoil3[2] * 100, '%)</font></td>")
  newinpt.document.writeln("     <td align=right bgcolor=', @color[5],
      '><font size=1>(', $probSoil3[3] * 100, '%)</font></td>")
  newinpt.document.writeln("     <td align=right bgcolor=', @color[5],
      '><font size=1>(', $probSoil3[4] * 100, '%)</font></td>")
  newinpt.document.writeln("     <td><font size=1>4th year</font></td></tr>")
  newinpt.document.writeln("    <tr><td align=right bgcolor=', @color[5],
      '><font size=1>(', $probSoil4[0] * 100, '%)</font></td>")
  newinpt.document.writeln("     <td align=right bgcolor=', @color[5],
      '><font size=1>(', $probSoil4[1] * 100, '%)</font></td>")
  newinpt.document.writeln("     <td align=right bgcolor=', @color[5],
      '><font size=1>(', $probSoil4[2] * 100, '%)</font></td>")
  newinpt.document.writeln("     <td align=right bgcolor=', @color[5],
      '><font size=1>(', $probSoil4[3] * 100, '%)</font></td>")
  newinpt.document.writeln("     <td align=right bgcolor=', @color[5],
      '><font size=1>(', $probSoil4[4] * 100, '%)</font></td>")
  newinpt.document.writeln("     <td><font size=1>5th year</font></td>")
  newinpt.document.writeln("    </tr>")
  newinpt.document.writeln("   </table>")
  newinpt.document.writeln("  <\/font>")
  newinpt.document.writeln(" <\/body>")
  newinpt.document.writeln("<\/html>")
  newinpt.document.close()
}
';

    print " </script>\n";

}

sub isNumber {

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

    $_[0] =~ /^(?=[-+.]*\d)[-+]?\d*\.?\d*(?:e[-+ ]?\d+)?$/i;
}

sub createsoilfile {

    # return soil file for ERMiT given
    #   soil texture designation (sand, silt, clay, loam)
    #   spatial representation (lll, llh, lhl, lhh, hll, hlh, hhl, hhh, uuu)
    #   conductivity ranking for ki, kr, ksat/aveke (0..4)
    #   percent rock fragments (rfg)

 # USDA FS RMRS Moscow FSL coding by david numbers by Bill Elliot & Corey Moffat
 #                         unbured numbers by Pete Robichaud 2013.04.18

    $ver = '2014.02.06'
      ;    # DEH 2014.02.06 add support for unburned range and chaparral

    # reads:
    # $s -- severity code ('hhh' .. 'lll', 'uuu')
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
    die "Invalid SoilType: $SoilType"
      unless $SoilType =~ /^(sand|silt|clay|loam)$/;

    my $string = lc($s);

    if ( $string eq 'lll' || $string eq 'hhh' ) { $nofe = 1 }
    if ( $string eq 'llh' || $string eq 'hhl' ) { $nofe = 2 }
    if ( $string eq 'lhl' || $string eq 'hlh' ) { $nofe = 3 }
    if ( $string eq 'lhh' || $string eq 'hll' ) { $nofe = 2 }
    if ( $string eq 'uuu' )                     { $nofe = 1 }    # 2013.05.03

    $ksflag = 0
      ; # hold internal hydraulic conductivity constant (0 => do not adjust internally)
    $nsl  = 1;     # number of soil layers for the current OFE
    $salb = 0.2;   # albedo of the bare dry surface soil on the current OFE
    $sat  = 0.75;  # initial saturation level of the soil profile porosity (m/m)

    # goto skip;
    # skip:

    &soil_parameters;

    @u[0] =
        @ki_u[0] . "\t"
      . @kr_u[0] . "\t"
      . $tauc_u . "\t"
      . @ksat_u[0];    # 2013.05.03
    @u[1] = @ki_u[1] . "\t" . @kr_u[1] . "\t" . $tauc_u . "\t" . @ksat_u[1];
    @u[2] = @ki_u[2] . "\t" . @kr_u[2] . "\t" . $tauc_u . "\t" . @ksat_u[2];
    @u[3] = @ki_u[3] . "\t" . @kr_u[3] . "\t" . $tauc_u . "\t" . @ksat_u[3];
    @u[4] = @ki_u[4] . "\t" . @kr_u[4] . "\t" . $tauc_u . "\t" . @ksat_u[4];
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

    $results = "95.1
#  WEPP '$soil_texture' '$s$k' $vegtype soil input file for ERMiT";
    if ( $vegtype ne 'forest' ) {
        $results .= "\n#  $shrub% shrub $grass% grass $bare% bare";
    }
    $results .= "
#  Data from U.S. Forest Service RMRS Air, Water and Aquatic Environments (AWAE) Project, Moscow FSL
#  Created by 'createsoilfile' version $ver
$nofe\t0
";

    $that_severity = '';
    for $i ( 0 .. 2 ) {
        $this_severity = substr( $string, $i, 1 );
        $sev           = $this_severity;
        if ( $this_severity ne $that_severity ) {
            if ( $this_severity eq 'u' ) { $KiKrShcritAvke = @u[$k] }
            if ( $this_severity eq 'l' ) { $KiKrShcritAvke = @l[$k] }
            if ( $this_severity eq 'h' ) { $KiKrShcritAvke = @h[$k] }
            $results .= "'ERMiT_$sev$k'\t'$soil_texture'\t$nsl\t$salb\t$sat\t"
              . $KiKrShcritAvke;
            $results .= "\n$solthk\t$sand\t$clay\t$orgmat\t$cec\t$rfg\n";
            $that_severity = $this_severity;
        }
    }
    return $results;
}

sub soil_parameters {

# 2014.02.06 new unburned forest and new unburned range/chaparral -- PRR and WJE 02/05/2014
# 2013.04.19 added 'unburned' condition
# 2006.06.20 adjusted range values to match 'Working Range Soil Tables(Simanton_krs).xlstable' (4/25/2006)

    # $vegtype ['forest' 'range' 'chaparral']
    # $SoilType ['sand' 'silt' 'clay' 'loam']
    # $shrub
    # $grass
    # $bare

# @ki_u[0..4]		       # unburned baseline interrill erodibility (ki) (kg s/m^4)			# 2013.04.19
# @ki_l[0..4]          # low soil burn severity baseline interrill erodibility (ki) (kg s/m^4)
# @ki_h[0..4]          # high soil burn severity baseline interrill erodibility (ki) (kg s/m^4)
# @kr_u[0..4]          # unburned baseline rill erodibility (kr) (s/m)					# 2013.04.19
# @kr_l[0..4]          # low soil burn severity baseline rill erodibility (kr) (s/m)
# @kr_h[0..4]          # high soil burn severity baseline rill erodibility (kr) (s/m)
# $tauc_u              # unburned baseline critical shear (shcrit) (N/m^2)				# 2013.04.19
# $tauc_l              # low soil burn severity baseline critical shear (shcrit) (N/m^2)
# $tauc_h              # high soil burn severity baseline critical shear (shcrit) (N/m^2)
# @ksat_u[0..4]        # unburned effective hydraulic conductivity of surface soil (avke) (mm/h)	# 2013.04.19
# @ksat_l[0..4]        # low severity effective hydraulic conductivity of surface soil (avke) (mm/h)
# @ksat_h[0..4]        # high severity effective hydraulic conductivity of surface soil (avke) (mm/h)

    if ( $vegtype eq 'forest' ) {
        if ( $SoilType eq 'sand' ) {
            $solthk = 400;  # depth of soil surface to bottom of soil layer (mm)
            $sand   = 55;   # percentage of sand in the layer (%)
            $clay   = 10;   # percentage of clay in the layer (%)
            $orgmat =
              5;    # percentage of organic matter (by volume) in the layer (%)
            $cec = 15
              ;  # cation exchange capacity in the layer (meq per 100 g of soil)
            $tauc_u    = 2;           # 2013.05.03
            $tauc_l    = 2;
            $tauc_h    = 2;
            @ki_u[0]   = 84200;
            @kr_u[0]   = 0.0000015;
            @ksat_u[0] = 100;         # 2014.02.06 DEH
            @ki_u[1]   = 118700;
            @kr_u[1]   = 0.0000018;
            @ksat_u[1] = 75;          # 2014.02.06 DEH
            @ki_u[2]   = 189100;
            @kr_u[2]   = 0.0000020;
            @ksat_u[2] = 50;          # 2014.02.06 DEH
            @ki_u[3]   = 411900;
            @kr_u[3]   = 0.0000021;
            @ksat_u[3] = 35;          # 2014.02.06 DEH
            @ki_u[4]   = 873300;
            @kr_u[4]   = 0.0000023;
            @ksat_u[4] = 20;          # 2014.02.06 DEH
            @ki_l[0]   = 300000;
            @kr_l[0]   = 0.0000030;
            @ksat_l[0] = 48;          # 2005.10.12 DEH
            @ki_l[1]   = 500000;
            @kr_l[1]   = 0.00034;
            @ksat_l[1] = 46;
            @ki_l[2]   = 700000;
            @kr_l[2]   = 0.00037;
            @ksat_l[2] = 44;
            @ki_l[3]   = 1000000;
            @kr_l[3]   = 0.00040;
            @ksat_l[3] = 24;
            @ki_l[4]   = 1200000;
            @kr_l[4]   = 0.00045;
            @ksat_l[4] = 14;
            @ki_h[0]   = 1000000;
            @kr_h[0]   = 0.00040;
            @ksat_h[0] = 22;
            @ki_h[1]   = 1500000;
            @kr_h[1]   = 0.00050;
            @ksat_h[1] = 13;
            @ki_h[2]   = 2000000;
            @kr_h[2]   = 0.00060;
            @ksat_h[2] = 7;
            @ki_h[3]   = 2500000;
            @kr_h[3]   = 0.00070;
            @ksat_h[3] = 6;
            @ki_h[4]   = 3000000;
            @kr_h[4]   = 0.00100;
            @ksat_h[4] = 5;
        }
        if ( $SoilType eq 'silt' ) {
            $solthk    = 400;
            $sand      = 25;
            $clay      = 15;
            $orgmat    = 5;
            $cec       = 15;
            $tauc_u    = 3.5;
            $tauc_l    = 3.5;
            $tauc_h    = 3.5;
            @ki_u[0]   = 48800;
            @kr_u[0]   = 0.0000011;
            @ksat_u[0] = 65;          # 2014 DEH
            @ki_u[1]   = 68800;
            @kr_u[1]   = 0.0000013;
            @ksat_u[1] = 48;          # 2014 DEH
            @ki_u[2]   = 109700;
            @kr_u[2]   = 0.0000015;
            @ksat_u[2] = 32;          # 2014 DEH
            @ki_u[3]   = 238900;
            @kr_u[3]   = 0.0000015;
            @ksat_u[3] = 26;          # 2014 DEH
            @ki_u[4]   = 506500;
            @kr_u[4]   = 0.0000017;
            @ksat_u[4] = 20;          # 2014 DEH
             #    @ki_l[0] =  300000; @kr_l[0] = 0.0000030; @ksat_l[0] = 48;        # 2005 DEH
            @ki_l[0]   = 250000;
            @kr_l[0]   = 0.0000020;
            @ksat_l[0] = 33;          # 2005.10.12 DEH
            @ki_l[1]   = 300000;
            @kr_l[1]   = 0.00024;
            @ksat_l[1] = 31;
            @ki_l[2]   = 400000;
            @kr_l[2]   = 0.00027;
            @ksat_l[2] = 29;
            @ki_l[3]   = 500000;
            @kr_l[3]   = 0.00030;
            @ksat_l[3] = 19;
            @ki_l[4]   = 600000;
            @kr_l[4]   = 0.00035;
            @ksat_l[4] = 9;
            @ki_h[0]   = 500000;
            @kr_h[0]   = 0.00030;
            @ksat_h[0] = 18;
            @ki_h[1]   = 1000000;
            @kr_h[1]   = 0.00040;
            @ksat_h[1] = 10;
            @ki_h[2]   = 1500000;
            @kr_h[2]   = 0.00050;
            @ksat_h[2] = 6;
            @ki_h[3]   = 2000000;
            @kr_h[3]   = 0.00060;
            @ksat_h[3] = 4;
            @ki_h[4]   = 2500000;
            @kr_h[4]   = 0.00090;
            @ksat_h[4] = 3;
        }
        if ( $SoilType eq 'clay' ) {
            $solthk    = 400;
            $sand      = 25;
            $clay      = 30;
            $orgmat    = 5;
            $cec       = 25;
            $tauc_u    = 4;
            $tauc_l    = 4;
            $tauc_h    = 4;
            @ki_u[0]   = 56400;
            @kr_u[0]   = 0.0000024;
            @ksat_u[0] = 70;          # 2014.02.06 DEH
            @ki_u[1]   = 79500;
            @kr_u[1]   = 0.0000028;
            @ksat_u[1] = 50;          # 2014.02.06 DEH
            @ki_u[2]   = 126700;
            @kr_u[2]   = 0.0000032;
            @ksat_u[2] = 30;          # 2014.02.06 DEH
            @ki_u[3]   = 276000;
            @kr_u[3]   = 0.0000033;
            @ksat_u[3] = 20;          # 2014.02.06 DEH
            @ki_u[4]   = 585100;
            @kr_u[4]   = 0.0000036;
            @ksat_u[4] = 10;          # 2014.02.06 DEH

#     @ki_l[0] =  300000; @kr_l[0] = 0.0000030; @ksat_l[0] = 48;        # 2005.10.12 DEH
            @ki_l[0]   = 200000;
            @kr_l[0]   = 0.0000010;
            @ksat_l[0] = 25;          # 2005.10.12 DEH
            @ki_l[1]   = 250000;
            @kr_l[1]   = 0.00014;
            @ksat_l[1] = 24;
            @ki_l[2]   = 300000;
            @kr_l[2]   = 0.00017;
            @ksat_l[2] = 23;
            @ki_l[3]   = 400000;
            @kr_l[3]   = 0.00020;
            @ksat_l[3] = 14;
            @ki_l[4]   = 500000;
            @kr_l[4]   = 0.00025;
            @ksat_l[4] = 8;
            @ki_h[0]   = 400000;
            @kr_h[0]   = 0.00020;
            @ksat_h[0] = 13;
            @ki_h[1]   = 700000;
            @kr_h[1]   = 0.00030;
            @ksat_h[1] = 7;
            @ki_h[2]   = 1000000;
            @kr_h[2]   = 0.00040;
            @ksat_h[2] = 4;
            @ki_h[3]   = 1500000;
            @kr_h[3]   = 0.00050;
            @ksat_h[3] = 3;
            @ki_h[4]   = 2000000;
            @kr_h[4]   = 0.00080;
            @ksat_h[4] = 2;
        }
        if ( $SoilType eq 'loam' ) {
            $solthk    = 400;
            $sand      = 45;
            $clay      = 20;
            $orgmat    = 5;
            $cec       = 20;
            $tauc_u    = 3;
            $tauc_l    = 3;
            $tauc_h    = 3;
            @ki_u[0]   = 72400;
            @kr_u[0]   = 0.0000018;
            @ksat_u[0] = 75;          # 2013.04.19 DEH
            @ki_u[1]   = 102100;
            @kr_u[1]   = 0.0000022;
            @ksat_u[1] = 56;          # 2013.04.19 DEH
            @ki_u[2]   = 162600;
            @kr_u[2]   = 0.0000025;
            @ksat_u[2] = 37;          # 2013.04.19 DEH
            @ki_u[3]   = 354200;
            @kr_u[3]   = 0.0000026;
            @ksat_u[3] = 26;          # 2013.04.19 DEH
            @ki_u[4]   = 751000;
            @kr_u[4]   = 0.0000028;
            @ksat_u[4] = 15;          # 2013.04.19 DEH

#     @ki_l[0] =  300000; @kr_l[0] = 0.0000030; @ksat_l[0] = 48;        # 2005.10.12 DEH
            @ki_l[0]   = 320000;
            @kr_l[0]   = 0.0000015;
            @ksat_l[0] = 40;          # 2005.10.12 DEH
            @ki_l[1]   = 370000;
            @kr_l[1]   = 0.00019;
            @ksat_l[1] = 38;
            @ki_l[2]   = 470000;
            @kr_l[2]   = 0.00022;
            @ksat_l[2] = 36;
            @ki_l[3]   = 600000;
            @kr_l[3]   = 0.00025;
            @ksat_l[3] = 28;
            @ki_l[4]   = 800000;
            @kr_l[4]   = 0.00030;
            @ksat_l[4] = 18;
            @ki_h[0]   = 600000;
            @kr_h[0]   = 0.00025;
            @ksat_h[0] = 27;
            @ki_h[1]   = 800000;
            @kr_h[1]   = 0.00035;
            @ksat_h[1] = 15;
            @ki_h[2]   = 1200000;
            @kr_h[2]   = 0.00055;
            @ksat_h[2] = 8;
            @ki_h[3]   = 2200000;
            @kr_h[3]   = 0.00065;
            @ksat_h[3] = 5;
            @ki_h[4]   = 3200000;
            @kr_h[4]   = 0.00085;
            @ksat_h[4] = 4;
        }

        # return
        #   $tauc_u
        #   $tauc_l
        #   $tauc_h
        #   @ki_u[0..4]
        #   @ki_l[0..4]
        #   @ki_h[0..4]
        #   @kr_u[0..4]
        #   @kr_l[0..4]
        #   @kr_h[0..4]
        #   @ksat_u[0..4]
        #   @ksat_l[0..4]
        #   @ksat_h[0..4]

    }    # $vegtype eq 'forest'
    else
    { # $vegtype ne 'forest'...  # soil parameter values 25 April 2006 added 20 June 2006
        if ( $SoilType eq 'sand' ) {
            $solthk = 400;  # depth of soil surface to bottom of soil layer (mm)
            $sand   = 55;   # percentage of sand in the layer (%)
            $clay   = 10;   # percentage of clay in the layer (%)
            $orgmat = 1
              ; # percentage of organic matter (by volume) in the layer (%) # per CM 2006.06.05
            $cec = 15
              ;  # cation exchange capacity in the layer (meq per 100 g of soil)
            $tauc_l = 2.75;
            $tauc_h = 2.17;
            $tauc_u = 1.14;    # DEH 2014.02.06

            @ki_shrub_u[0] = 18871;
            @ki_grass_u[0] = 12541;
            @ki_bare_u[0]  = 58343;
            @kr_u[0]       = 0.0000022;    # DEH 2014.02.06
            @ki_shrub_u[1] = 37742;
            @ki_grass_u[1] = 25028;
            @ki_bare_u[1]  = 116686;
            @kr_u[1]       = 0.0000045;
            @ki_shrub_u[2] = 75483;
            @ki_grass_u[2] = 50165;
            @ki_bare_u[2]  = 233373;
            @kr_u[2]       = 0.000009;
            @ki_shrub_u[3] = 94354;
            @ki_grass_u[3] = 62706;
            @ki_bare_u[3]  = 291716;
            @kr_u[3]       = 0.000011;
            @ki_shrub_u[4] = 1723789;
            @ki_grass_u[4] = 85555;
            @ki_bare_u[4]  = 788669;
            @kr_u[4]       = 0.00259;
            @ki_shrub_l[0] = 7.548E+4;
            @ki_grass_l[0] = 5.016E+4;
            @ki_bare_l[0]  = 2.334E+5;
            @kr_l[0]       = 8.991E-6;
            @ki_shrub_l[1] = 1.191E+5;
            @ki_grass_l[1] = 1.174E+5;
            @ki_bare_l[1]  = 2.536E+5;
            @kr_l[1]       = 1.393E-5;
            @ki_shrub_l[2] = 2.480E+5;
            @ki_grass_l[2] = 2.372E+5;
            @ki_bare_l[2]  = 5.520E+5;
            @kr_l[2]       = 8.042E-5;
            @ki_shrub_l[3] = 4.093E+5;
            @ki_grass_l[3] = 3.921E+5;
            @ki_bare_l[3]  = 2.187E+6;
            @kr_l[3]       = 3.316E-4;
            @ki_shrub_l[4] = 9.313E+5;
            @ki_grass_l[4] = 6.513E+5;
            @ki_bare_l[4]  = 3.608E+6;
            @kr_l[4]       = 7.236E-4;
            @ki_shrub_h[0] = 2.334E+5;
            @ki_grass_h[0] = 1.745E+5;
            @ki_bare_h[0]  = 2.334E+5;
            @kr_h[0]       = 9.492E-5;
            @ki_shrub_h[1] = 2.536E+5;
            @ki_grass_h[1] = 2.518E+5;
            @ki_bare_h[1]  = 2.536E+5;
            @kr_h[1]       = 1.346E-4;
            @ki_shrub_h[2] = 4.630E+5;
            @ki_grass_h[2] = 5.520E+5;
            @ki_bare_h[2]  = 5.520E+5;
            @kr_h[2]       = 5.444E-4;
            @ki_shrub_h[3] = 6.868E+5;
            @ki_grass_h[3] = 2.187E+6;
            @ki_bare_h[3]  = 2.187E+6;
            @kr_h[3]       = 1.684E-3;
            @ki_shrub_h[4] = 9.313E+5;
            @ki_grass_h[4] = 3.608E+6;
            @ki_bare_h[4]  = 3.608E+6;
            @kr_h[4]       = 3.137E-3;
            @ks_shrub_u[0] = 40;
            @ks_grass_u[0] = 30;
            @ks_bare_u[0]  = 26;
            @ks_shrub_u[1] = 35;
            @ks_grass_u[1] = 24;
            @ks_bare_u[1]  = 15;
            @ks_shrub_u[2] = 30;
            @ks_grass_u[2] = 17;
            @ks_bare_u[2]  = 14;
            @ks_shrub_u[3] = 23;
            @ks_grass_u[3] = 15;
            @ks_bare_u[3]  = 10;
            @ks_shrub_u[4] = 15;
            @ks_grass_u[4] = 12;
            @ks_bare_u[4]  = 7;
            @ks_shrub_l[0] = 29;
            @ks_grass_l[0] = 17;
            @ks_bare_l[0]  = 14;
            @ks_shrub_l[1] = 17;
            @ks_grass_l[1] = 17;
            @ks_bare_l[1]  = 14;
            @ks_shrub_l[2] = 15;
            @ks_grass_l[2] = 13;
            @ks_bare_l[2]  = 11;
            @ks_shrub_l[3] = 12;
            @ks_grass_l[3] = 12;
            @ks_bare_l[3]  = 10;
            @ks_shrub_l[4] = 9;
            @ks_grass_l[4] = 8;
            @ks_bare_l[4]  = 7;
            @ks_shrub_h[0] = 21;
            @ks_grass_h[0] = 14;
            @ks_bare_h[0]  = 14;
            @ks_shrub_h[1] = 12;
            @ks_grass_h[1] = 14;
            @ks_bare_h[1]  = 14;
            @ks_shrub_h[2] = 11;
            @ks_grass_h[2] = 11;
            @ks_bare_h[2]  = 11;
            @ks_shrub_h[3] = 9;
            @ks_grass_h[3] = 10;
            @ks_bare_h[3]  = 10;
            @ks_shrub_h[4] = 6;
            @ks_grass_h[4] = 7;
            @ks_bare_h[4]  = 7;
        }
        if ( $SoilType eq 'silt' ) {
            $solthk        = 400;
            $sand          = 25;
            $clay          = 15;
            $orgmat        = 1;
            $cec           = 15;
            $tauc_l        = 3.39;
            $tauc_h        = 2.68;
            $tauc_u        = 3.39;
            @ki_shrub_u[0] = 3990;
            @ki_grass_u[0] = 2874;
            @ki_bare_u[0]  = 12335;
            @kr_u[0]       = 0.000008;
            @ki_shrub_u[1] = 7979;
            @ki_grass_u[1] = 5748;
            @ki_bare_u[1]  = 24670;
            @kr_u[1]       = 0.000016;
            @ki_shrub_u[2] = 15959;
            @ki_grass_u[2] = 11496;
            @ki_bare_u[2]  = 49340;
            @kr_u[2]       = 0.000033;
            @ki_shrub_u[3] = 19948;
            @ki_grass_u[3] = 14370;
            @ki_bare_u[3]  = 61675;
            @kr_u[3]       = 0.000041;
            @ki_shrub_u[4] = 23938;
            @ki_grass_u[4] = 17244;
            @ki_bare_u[4]  = 74010;
            @kr_u[4]       = 0.000049;
            @ki_shrub_l[0] = 1.596E+4;
            @ki_grass_l[0] = 1.150E+4;
            @ki_bare_l[0]  = 4.934E+4;
            @kr_l[0]       = 3.276E-5;
            @ki_shrub_l[1] = 2.933E+4;
            @ki_grass_l[1] = 2.070E+4;
            @ki_bare_l[1]  = 6.247E+4;
            @kr_l[1]       = 5.989E-5;
            @ki_shrub_l[2] = 8.151E+4;
            @ki_grass_l[2] = 5.556E+4;
            @ki_bare_l[2]  = 1.522E+5;
            @kr_l[2]       = 1.804E-4;
            @ki_shrub_l[3] = 1.428E+5;
            @ki_grass_l[3] = 9.548E+4;
            @ki_bare_l[3]  = 5.326E+5;
            @kr_l[3]       = 4.363E-4;
            @ki_shrub_l[4] = 2.312E+5;
            @ki_grass_l[4] = 1.521E+5;
            @ki_bare_l[4]  = 8.425E+5;
            @kr_l[4]       = 7.787E-4;
            @ki_shrub_h[0] = 4.934E+4;
            @ki_grass_h[0] = 3.998E+4;
            @ki_bare_h[0]  = 4.934E+4;
            @kr_h[0]       = 2.661E-4;
            @ki_shrub_h[1] = 6.247E+4;
            @ki_grass_h[1] = 4.439E+4;
            @ki_bare_h[1]  = 6.247E+4;
            @kr_h[1]       = 4.304E-4;
            @ki_shrub_h[2] = 1.522E+5;
            @ki_grass_h[2] = 1.293E+5;
            @ki_bare_h[2]  = 1.522E+5;
            @kr_h[2]       = 1.037E-3;
            @ki_shrub_h[3] = 2.312E+5;
            @ki_grass_h[3] = 5.326E+5;
            @ki_bare_h[3]  = 5.326E+5;
            @kr_h[3]       = 2.096E-3;
            @ki_shrub_h[4] = 2.312E+5;
            @ki_grass_h[4] = 8.425E+5;
            @ki_bare_h[4]  = 8.425E+5;
            @kr_h[4]       = 3.326E-3;
            @ks_shrub_u[0] = 32;
            @ks_grass_u[0] = 34;
            @ks_bare_u[0]  = 22;
            @ks_shrub_u[1] = 27;
            @ks_grass_u[1] = 30;
            @ks_bare_u[1]  = 17;
            @ks_shrub_u[2] = 22;
            @ks_grass_u[2] = 26;
            @ks_bare_u[2]  = 13;
            @ks_shrub_u[3] = 18;
            @ks_grass_u[3] = 20;
            @ks_bare_u[3]  = 11;
            @ks_shrub_u[4] = 13;
            @ks_grass_u[4] = 15;
            @ks_bare_u[4]  = 9;
            @ks_shrub_l[0] = 22;
            @ks_grass_l[0] = 26;
            @ks_bare_l[0]  = 21;
            @ks_shrub_l[1] = 18;
            @ks_grass_l[1] = 20;
            @ks_bare_l[1]  = 16;
            @ks_shrub_l[2] = 13;
            @ks_grass_l[2] = 15;
            @ks_bare_l[2]  = 12;
            @ks_shrub_l[3] = 11;
            @ks_grass_l[3] = 13;
            @ks_bare_l[3]  = 10;
            @ks_shrub_l[4] = 8;
            @ks_grass_l[4] = 10;
            @ks_bare_l[4]  = 8;
            @ks_shrub_h[0] = 16;
            @ks_grass_h[0] = 21;
            @ks_bare_h[0]  = 21;
            @ks_shrub_h[1] = 12;
            @ks_grass_h[1] = 16;
            @ks_bare_h[1]  = 16;
            @ks_shrub_h[2] = 9;
            @ks_grass_h[2] = 12;
            @ks_bare_h[2]  = 12;
            @ks_shrub_h[3] = 8;
            @ks_grass_h[3] = 10;
            @ks_bare_h[3]  = 10;
            @ks_shrub_h[4] = 6;
            @ks_grass_h[4] = 8;
            @ks_bare_h[4]  = 8;
        }
        if ( $SoilType eq 'clay' ) {
            $solthk = 400;
            $sand   = 25;
            $clay   = 30;
            $orgmat = 1;
            $cec    = 25;
            $tauc_l = 1.9;
            $tauc_h = 1.5;
            $tauc_u = 1.9;

            @ki_shrub_u[0] = 3167;
            @ki_grass_u[0] = 447;
            @ki_bare_u[0]  = 9791;
            @kr_u[0]       = 0.000009;
            @ki_shrub_u[1] = 6334;
            @ki_grass_u[1] = 954;
            @ki_bare_u[1]  = 19581;
            @kr_u[1]       = 0.000019;
            @ki_shrub_u[2] = 12667;
            @ki_grass_u[2] = 1908;
            @ki_bare_u[2]  = 39163;
            @kr_u[2]       = 0.000038;
            @ki_shrub_u[3] = 15834;
            @ki_grass_u[3] = 2358;
            @ki_bare_u[3]  = 48954;
            @kr_u[3]       = 0.000047;
            @ki_shrub_u[4] = 19001;
            @ki_grass_u[4] = 2862;
            @ki_bare_u[4]  = 58744;
            @kr_u[4]       = 0.000056;
            @ki_shrub_l[0] = 1.267E+4;
            @ki_grass_l[0] = 1.908E+3;
            @ki_bare_l[0]  = 3.916E+4;
            @kr_l[0]       = 3.750E-5;
            @ki_shrub_l[1] = 2.295E+4;
            @ki_grass_l[1] = 3.069E+3;
            @ki_bare_l[1]  = 4.887E+4;
            @kr_l[1]       = 7.500E-5;
            @ki_shrub_l[2] = 6.223E+4;
            @ki_grass_l[2] = 6.814E+3;
            @ki_bare_l[2]  = 1.162E+5;
            @kr_l[2]       = 1.500E-4;
            @ki_shrub_l[3] = 1.075E+5;
            @ki_grass_l[3] = 1.055E+4;
            @ki_bare_l[3]  = 1.721E+5;
            @kr_l[3]       = 3.000E-4;
            @ki_shrub_l[4] = 1.721E+5;
            @ki_grass_l[4] = 1.537E+4;
            @ki_bare_l[4]  = 1.721E+5;
            @kr_l[4]       = 6.000E-4;
            @ki_shrub_h[0] = 3.916E+4;
            @ki_grass_h[0] = 6.636E+3;
            @ki_bare_h[0]  = 3.916E+4;
            @kr_h[0]       = 2.963E-4;
            @ki_shrub_h[1] = 4.887E+4;
            @ki_grass_h[1] = 6.636E+3;
            @ki_bare_h[1]  = 4.887E+4;
            @kr_h[1]       = 5.149E-4;
            @ki_shrub_h[2] = 1.162E+5;
            @ki_grass_h[2] = 1.586E+4;
            @ki_bare_h[2]  = 1.162E+5;
            @kr_h[2]       = 8.948E-4;
            @ki_shrub_h[3] = 1.721E+5;
            @ki_grass_h[3] = 5.886E+4;
            @ki_bare_h[3]  = 1.721E+5;
            @kr_h[3]       = 1.555E-3;
            @ki_shrub_h[4] = 1.712E+5;
            @ki_grass_h[4] = 8.516E+4;
            @ki_bare_h[4]  = 1.721E+5;
            @kr_h[4]       = 2.702E-3;
            @ks_shrub_u[0] = 30;
            @ks_grass_u[0] = 20;
            @ks_bare_u[0]  = 11;
            @ks_shrub_u[1] = 22;
            @ks_grass_u[1] = 16;
            @ks_bare_u[1]  = 10;
            @ks_shrub_u[2] = 15;
            @ks_grass_u[2] = 13;
            @ks_bare_u[2]  = 8;
            @ks_shrub_u[3] = 11;
            @ks_grass_u[3] = 10;
            @ks_bare_u[3]  = 6;
            @ks_shrub_u[4] = 7;
            @ks_grass_u[4] = 6;
            @ks_bare_u[4]  = 5;
            @ks_shrub_l[0] = 15;
            @ks_grass_l[0] = 13;
            @ks_bare_l[0]  = 10;
            @ks_shrub_l[1] = 13;
            @ks_grass_l[1] = 11;
            @ks_bare_l[1]  = 9;
            @ks_shrub_l[2] = 10;
            @ks_grass_l[2] = 9;
            @ks_bare_l[2]  = 7;
            @ks_shrub_l[3] = 8;
            @ks_grass_l[3] = 6;
            @ks_bare_l[3]  = 5;
            @ks_shrub_l[4] = 6;
            @ks_grass_l[4] = 5;
            @ks_bare_l[4]  = 4;
            @ks_shrub_h[0] = 11;
            @ks_grass_h[0] = 10;
            @ks_bare_h[0]  = 10;
            @ks_shrub_h[1] = 9;
            @ks_grass_h[1] = 9;
            @ks_bare_h[1]  = 9;
            @ks_shrub_h[2] = 7;
            @ks_grass_h[2] = 7;
            @ks_bare_h[2]  = 7;
            @ks_shrub_h[3] = 5;
            @ks_grass_h[3] = 5;
            @ks_bare_h[3]  = 5;
            @ks_shrub_h[4] = 5;
            @ks_grass_h[4] = 4;
            @ks_bare_h[4]  = 4;
        }
        if ( $SoilType eq 'loam' ) {
            $solthk = 400;
            $sand   = 45;
            $clay   = 20;
            $orgmat = 1;
            $cec    = 20;
            $tauc_l = 0.8;
            $tauc_h = 0.63;
            $tauc_u = 0.8;

            @ki_shrub_u[0] = 857;
            @ki_grass_u[0] = 650;
            @ki_bare_u[0]  = 2649;
            @kr_u[0]       = 0.000013;
            @ki_shrub_u[1] = 1714;
            @ki_grass_u[1] = 1301;
            @ki_bare_u[1]  = 5299;
            @kr_u[1]       = 0.000026;
            @ki_shrub_u[2] = 3428;
            @ki_grass_u[2] = 2601;
            @ki_bare_u[2]  = 10597;
            @kr_u[2]       = 0.000051;
            @ki_shrub_u[3] = 4285;
            @ki_grass_u[3] = 3252;
            @ki_bare_u[3]  = 13247;
            @kr_u[3]       = 0.000064;
            @ki_shrub_u[4] = 5142;
            @ki_grass_u[4] = 3902;
            @ki_bare_u[4]  = 15896;
            @kr_u[4]       = 0.000077;
            @ki_shrub_l[0] = 3.428E+3;
            @ki_grass_l[0] = 2.601E+3;
            @ki_bare_l[0]  = 1.060E+4;
            @kr_l[0]       = 5.102E-5;
            @ki_shrub_l[1] = 6.220E+3;
            @ki_grass_l[1] = 4.626E+3;
            @ki_bare_l[1]  = 1.325E+4;
            @kr_l[1]       = 1.157E-4;
            @ki_shrub_l[2] = 3.700E+4;
            @ki_grass_l[2] = 2.590E+4;
            @ki_bare_l[2]  = 6.909E+4;
            @kr_l[2]       = 1.991E-4;
            @ki_shrub_l[3] = 7.866E+4;
            @ki_grass_l[3] = 5.368E+4;
            @ki_bare_l[3]  = 2.994E+5;
            @kr_l[3]       = 3.037E-4;
            @ki_shrub_l[4] = 9.286E+4;
            @ki_grass_l[4] = 6.302E+4;
            @ki_bare_l[4]  = 3.491E+5;
            @kr_l[4]       = 4.649E-4;
            @ki_shrub_h[0] = 1.060E+4;
            @ki_grass_h[0] = 9.047E+3;
            @ki_bare_h[0]  = 1.060E+4;
            @kr_h[0]       = 3.788E-4;
            @ki_shrub_h[1] = 1.325E+4;
            @ki_grass_h[1] = 9.922E+3;
            @ki_bare_h[1]  = 1.325E+4;
            @kr_h[1]       = 7.273E-4;
            @ki_shrub_h[2] = 6.909E+4;
            @ki_grass_h[2] = 6.028E+4;
            @ki_bare_h[2]  = 6.909E+4;
            @kr_h[2]       = 1.122E-3;
            @ki_shrub_h[3] = 9.286E+4;
            @ki_grass_h[3] = 2.994E+5;
            @ki_bare_h[3]  = 2.994E+5;
            @kr_h[3]       = 1.570E-3;
            @ki_shrub_h[4] = 9.286E+4;
            @ki_grass_h[4] = 3.491E+5;
            @ki_bare_h[4]  = 3.491E+5;
            @kr_h[4]       = 2.205E-3;
            @ks_shrub_u[0] = 26;
            @ks_grass_u[0] = 23;
            @ks_bare_u[0]  = 13;
            @ks_shrub_u[1] = 24;
            @ks_grass_u[1] = 19;
            @ks_bare_u[1]  = 11;
            @ks_shrub_u[2] = 22;
            @ks_grass_u[2] = 15;
            @ks_bare_u[2]  = 7;
            @ks_shrub_u[3] = 15;
            @ks_grass_u[3] = 10;
            @ks_bare_u[3]  = 6;
            @ks_shrub_u[4] = 9;
            @ks_grass_u[4] = 6;
            @ks_bare_u[4]  = 5;
            @ks_shrub_l[0] = 22;
            @ks_grass_l[0] = 15;
            @ks_bare_l[0]  = 12;
            @ks_shrub_l[1] = 18;
            @ks_grass_l[1] = 13;
            @ks_bare_l[1]  = 10;
            @ks_shrub_l[2] = 13;
            @ks_grass_l[2] = 6;
            @ks_bare_l[2]  = 5;
            @ks_shrub_l[3] = 11;
            @ks_grass_l[3] = 6;
            @ks_bare_l[3]  = 5;
            @ks_shrub_l[4] = 8;
            @ks_grass_l[4] = 5;
            @ks_bare_l[4]  = 4;
            @ks_shrub_h[0] = 16;
            @ks_grass_h[0] = 12;
            @ks_bare_h[0]  = 12;
            @ks_shrub_h[1] = 12;
            @ks_grass_h[1] = 10;
            @ks_bare_h[1]  = 10;
            @ks_shrub_h[2] = 9;
            @ks_grass_h[2] = 5;
            @ks_bare_h[2]  = 5;
            @ks_shrub_h[3] = 8;
            @ks_grass_h[3] = 5;
            @ks_bare_h[3]  = 5;
            @ks_shrub_h[4] = 6;
            @ks_grass_h[4] = 4;
            @ks_bare_h[4]  = 4;
        }    # #SoilType
             # return
             #   $tauc_u
             #   $tauc_l
             #   $tauc_h
             #   @ki_u[0..4]
             #   @ki_l[0..4]
             #   @ki_h[0..4]
             #   @kr_u[0..4]
             #   @kr_l[0..4]
             #   @kr_h[0..4]
             #   @ksat_u[0..4]
             #   @ksat_l[0..4]
             #   @ksat_h[0..4]

        $pshrub = $shrub / 100;
        $pgrass = $grass / 100;
        $pbare  = $bare / 100;

        for ( $i = 0 ; $i < 5 ; $i++ ) {
            @ki_u[$i] =
              $pshrub * @ki_shrub_u[$i] +
              $pgrass * @ki_grass_u[$i] +
              $pbare * @ki_bare_u[$i];
            @ki_l[$i] =
              $pshrub * @ki_shrub_l[$i] +
              $pgrass * @ki_grass_l[$i] +
              $pbare * @ki_bare_l[$i];
            @ki_h[$i] =
              $pshrub * @ki_shrub_h[$i] +
              $pgrass * @ki_grass_h[$i] +
              $pbare * @ki_bare_h[$i];
            @ksat_u[$i] =
              $pshrub * @ks_shrub_u[$i] +
              $pgrass * @ks_grass_u[$i] +
              $pbare * @ks_bare_u[$i];
            @ksat_l[$i] =
              $pshrub * @ks_shrub_l[$i] +
              $pgrass * @ks_grass_l[$i] +
              $pbare * @ks_bare_l[$i];
            @ksat_h[$i] =
              $pshrub * @ks_shrub_h[$i] +
              $pgrass * @ks_grass_h[$i] +
              $pbare * @ks_bare_h[$i];
        }
    }    # $vegtype
}

sub createGnuplotUnburnedJCLfile
{    # #######################  createGnuplotJCLfile

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

    # 'size 800,600' and 'enhanced' work from command-line but not
    # when called from within the perl program ............
    #  $result="set terminal png size 800,600 enhanced

    #  $result="set terminal postscript color
    $result =
      "set terminal pngcairo size 800,600 enhanced font 'sans,10' fontscale 1.1
set output '$gnuplotgraphpng'
set title 'Sediment Delivery Exceedance Probability for unburned $climate_name'
set xlabel 'Sediment Delivery ($alt_sedunits)'
set ylabel 'Probability (%)'
set noautoscale y
set yrange [0:100]
set key top
set grid ytics
set grid xtics
set timestamp \"%m-%d-%Y -- $soil_texture; $rfg%% rock; $top_slope%%, $avg_slope%%, $toe_slope%% slope; $hillslope_length $units; $severityclass_x [$unique]\"
plot [] [1:] \\
     '$gnuplotdatafile' using 1:2 t '1st year' with lines linewidth 3
";

    #     ''         using 1:3 t '2nd year' with lines linewidth 5,\\
    #     ''         using 1:4 t '3rd year' with lines linewidth 15,\\
    #     ''         using 1:5 t '4th year' with lines linewidth 5,\\
    #     ''         using 1:6 t '5th year' with lines lt 12 linewidth 5
    #";
}

sub createGnuplotJCLfile {    # #######################  createGnuplotJCLfile

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
    #  $result="set terminal postscript color
    $result =
      "set terminal pngcairo size 800,600 enhanced font 'sans,10' fontscale 1.1
set output '$gnuplotgraphpng'
set title 'Sediment Delivery Exceedance Probability for untreated $climate_name'
set xlabel 'Sediment Delivery ($alt_sedunits)'
set ylabel 'Probability (%)'
set noautoscale y
set yrange [0:100]
set key top
set grid ytics
set grid xtics
set timestamp \"%m-%d-%Y -- $soil_texture; $rfg%% rock; $top_slope%%, $avg_slope%%, $toe_slope%% slope; $hillslope_length $units; $severityclass_x soil burn severity [$unique]\"
plot [] [1:] \\
     '$gnuplotdatafile' using 1:2 t '1st year' with lines linewidth 3,\\
     ''         using 1:3 t '2nd year' with lines linewidth 3,\\
     ''         using 1:4 t '3rd year' with lines linewidth 3,\\
     ''         using 1:5 t '4th year' with lines linewidth 3,\\
     ''         using 1:6 t '5th year' with lines linewidth 3
";

    #plot [] [1:] \\
    #     '$gnuplotdatafile' using 1:2 smooth bezier t '1st year' linewidth 5,\\
    #     ''         using 1:3 sm b t '2nd year' linewidth 5,\\
    #     ''         using 1:4 sm b t '3rd year' linewidth 5,\\
    #     ''         using 1:5 sm b t '4th year' linewidth 5,\\
    #     ''         using 1:6 sm b t '5th year' linewidth 5
    #";
}

sub createGnuplotUnburnedDatafile {  # ##################  createGnuplotDatafile

    if ( $units eq 'm' ) {
        $unit_conv = $hillslope_length_m / 10;
    }                                # (x / 100) * 10 = x / (100 / 10)
    else { $unit_conv = $hillslope_length_m / 4.45 }
    $result =
      "# gnuplot  data file of sed_delivery vs cumulate probs (5 years) no mit
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

    for $i ( 0 .. $#sed_yields ) {    # 2005.09.30 DEH test 2005.10.21
        $cum_prob0 += @probabilities0[ @index[$i] ];
        $cum_prob1 += @probabilities1[ @index[$i] ];
        $cum_prob2 += @probabilities2[ @index[$i] ];
        $cum_prob3 += @probabilities3[ @index[$i] ];
        $cum_prob4 += @probabilities4[ @index[$i] ];
        $sedval = @sed_yields[ @index[$i] ];
        if ( $sedval eq '' ) { $sedval = '0.0' }
        $cp0r = sprintf '%9.2g', $cum_prob0 * 100;
        $cp1r = sprintf '%9.2g', $cum_prob1 * 100;
        $cp2r = sprintf '%9.2g', $cum_prob2 * 100;
        $cp3r = sprintf '%9.2g', $cum_prob3 * 100;
        $cp4r = sprintf '%9.2g', $cum_prob4 * 100;
        $sedu = $sedval / $unit_conv;
        $result .= "$sedu $cp0r $cp1r $cp2r $cp3r $cp4r\n";
        last if ( $sedval eq '0.0' );
    }
    return $result;
}

sub createGnuplotDatafile {    # ##################  createGnuplotDatafile

    #  create data file of sed_delivery vs cumulate probs (5 years) untreated

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

    if ( $units eq 'm' ) {
        $unit_conv = $hillslope_length_m / 10;
    }    # (x / 100) * 10 = x / (100 / 10)
    else { $unit_conv = $hillslope_length_m / 4.45 }
    $result =
      "# gnuplot  data file of sed_delivery vs cumulate probs (5 years) no mit
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

    for $i ( 0 .. $#sed_yields ) {    # 2005.09.30 DEH test 2005.10.21
        $cum_prob0 += @probabilities0[ @index[$i] ];
        $cum_prob1 += @probabilities1[ @index[$i] ];
        $cum_prob2 += @probabilities2[ @index[$i] ];
        $cum_prob3 += @probabilities3[ @index[$i] ];
        $cum_prob4 += @probabilities4[ @index[$i] ];
        $sedval = @sed_yields[ @index[$i] ];
        if ( $sedval eq '' ) { $sedval = '0.0' }
        $cp0r = sprintf '%9.2g', $cum_prob0 * 100;
        $cp1r = sprintf '%9.2g', $cum_prob1 * 100;
        $cp2r = sprintf '%9.2g', $cum_prob2 * 100;
        $cp3r = sprintf '%9.2g', $cum_prob3 * 100;
        $cp4r = sprintf '%9.2g', $cum_prob4 * 100;
        $sedu = $sedval / $unit_conv;
        $result .= "$sedu $cp0r $cp1r $cp2r $cp3r $cp4r\n";
        last if ( $sedval eq '0.0' );
    }
    return $result;

}

sub bomb {

    print "Content-type: text/html\n\n";
    print '<html>
 <head>
  <meta http-equiv="Refresh" content="0; URL=/cgi-bin/fswepp/ermit/ermit.pl?units=m">
 </head>
</html>
';

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
    my $eps_tp  = 0.01;       # 2004.09.16
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

    @i_peak = ('N/A') x ( $#max_time_list + 1 );  # set all intensities to 'N/A'

    $tp = $eps_tp if ( $tp < $eps_tp );

    $error_text = '';
    $error_text .= 'Storm duration too small. ' if ( $dur < $eps_dur );
    $error_text .= 'Too little precipitation. ' if ( $prcp < $eps_pcp );

# $error_text .= 'Time to peak too close to 0. ' if ($tp < $eps_tp);   # 2004.09.16
    $error_text .= 'Time to peak too close to 1. ' if ( $tp > 1 - $eps_tp );
    return                                         if ( $error_text ne '' );

    my $im = $prcp / $dur;    # (average intensity) (mm/h) $dur ~ 0

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

    my $last_b = 15;    # good all situations?
    my $b      = 10;    # good all situations?

    my $loop_count = 0;
    while ( abs( $b - $last_b ) > $epsilon ) {
        $last_b = $b;
        $b      = ( $ip - $ip * exp( -$b * $tp ) ) / $tp;    # &the_b
        if ( $loopcount > $iteration_limit_b ) {
            $error_text .= 'Could not determine appropriate B coefficient. ';
            last;
        }
        $loop_count += 1;
    }

    $error_text .= 'B coefficient too small. ' if ( $b < $eps_b );

    #  TRAILING CURVE

    #               d (tp-x)
    #     y = ip  e
    #

    #           b  tp
    #     d = ---------
    #          1 - tp

    my $d = $b * $tp / ( 1 - $tp );    # $tp ~ 1.00
    $error_text .= 'D coefficient too small. ' if ( $d < $eps_d );

    return if ( $error_text ne '' );

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
    my $max_time   = 0;
    my $peak_count = 0;

    foreach $max_time_m (@max_time_list) {
        $max_time = $max_time_m / 60;    # times of interest in hours

        $t_start = $tp - $max_time / $dur;                 # $dur ~ 0
        $t_high  = $tp;
        $t_low   = $t_start;
        $t_end   = $tp;
        $i_start = $ip * exp( $b * ( $t_start - $tp ) );
        $i_end   = $ip;

        $loop_count = 0;
        while ( abs( $i_start - $i_end ) > $epsilon ) {
            $loop_count += 1;
            if   ( $i_start < $i_end ) { $t_low  = $t_start }
            else                       { $t_high = $t_start }
            $t_start = ( $t_high + $t_low ) / 2;       # split the difference
            $t_end   = $t_start + $max_time / $dur;    # $dur ~ 0
            $i_start = $ip * exp( $b * ( $t_start - $tp ) );
            $i_end   = $ip * exp( $d * ( $tp - $t_end ) );
            if ( $loop_count > $iteration_limit_t ) {
                $error_text .= 'Time iteration limit exceeded. ';
                last;
            }
        }

        if ( $t_start < 0 ) {
            $starts = 0;
            $ends   = 1;
        }
        else {
            $starts = $t_start;
            $ends   = $t_end;
        }

        my $dur_peak = $ends - $starts;
        my $max_dur  = $max_time / $dur;    # $dur ~ 0

        $error_text .= 'Maximum duration too small. '
          if ( $max_dur < $eps_mxd );
        if ( $error_text ne '' ) {
            next;
        }

        if ( $dur_peak > $max_dur ) { $max_dur = $dur_peak }
        $I_peak =
          ( ( $ip / $b - $ip / $b * exp( $b * ( $starts - $tp ) ) ) +
              ( $ip / $d - $ip / $d * exp( $d * ( $tp - $ends ) ) ) ) *
          $im / $max_dur;

        # $b ~ 0;  $d ~ 0;  $max_dur ~ 0;  $im ~ 0 [$prcp ~ 0]

        @i_peak[$peak_count] = sprintf '%.2f', $I_peak;
        $peak_count += 1;

        if ($debug) {
            $starts_h   = $starts * $dur;
            $ends_h     = $ends * $dur;
            $dur_peak_m = $dur_peak * $dur * 60;

            print "\# $max_time_m min peak intensity
\#    starts    $starts_h h
\#    ends      $ends_h h
\#    duration  $dur_peak_m m
\#    intensity $I_peak
";
        }
        $error_text = '';
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
