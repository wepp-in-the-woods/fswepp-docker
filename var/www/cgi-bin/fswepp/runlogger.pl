#!/usr/bin/perl

use warnings;
use CGI qw(escapeHTML);

use MoscowFSL::FSWEPP::FsWeppUtils qw(get_user_id);

#
# read given FS WEPP runlog file and return HTML
#
my $ipd = get_user_id();

my $runlogfile = 'working/' . $ipd . '.run.log';

if ( !-e $runlogfile ) {
    die "Run log file: $runlogfile not found";
}

my $wr_color = '#a1a1f7';    # WEPP:Road
my $wd_color = '#77c677';    # Disturbed WEPP
my $we_color = '#e91d45';    # ERMiT
my $wf_color = '#f0a014';    # FuME
my $wa_color = '#f0f014';    # WASP
my $wt_color = '#3fe275';    # Tahoe

#  print table header

print "Content-type: text/html\n\n";
print "
<html>
 <head>
  <title>FS WEPP run log for $ipd</title>
 </head>
 <body link=black vlink=black alink=crimson>
  <font face=\"trebuchet, tahoma, arial, sans serif\" size=-3>
";

print "
   <h3>Run log for IP $ipd'</h3>
   <table border=1 cellpadding=7>
    <tr>
     <th bgcolor=#a1a1f7><a href='#wr'>WEPP:Road</a></th>
     <th bgcolor=#77c677><a href='#wd'>Disturbed</a></th>
     <th bgcolor=#e91d45><a href='#we'>ERMiT</a></th>
     <th bgcolor=#f0a014><a href='#wf'>FuME</a></th>
     <th bgcolor=#f0f014><a href='#ww'>WASP</a></th>
     <th bgcolor=#3fe275><a href='#wt'>Tahoe</a></th>
    </tr>
   </table>
";

####################
###   WEPP:ROAD  ###
####################

print "
   <a name='wr'></a>
   <h2>(<a href=\"#wd\">V</a>) WEPP:Road runs</h2>
   <table border=1>
    <tr>
     <th bgcolor=#a1a1f7><font size=-3>Run ID</th>
     <th bgcolor=$wr_color><font size=-3>Run time</th>
     <th bgcolor=$wr_color><font size=-3>Climate name</th>
     <th bgcolor=$wr_color><font size=-3>Sim. years</th>
     <th bgcolor=$wr_color><font size=-3>Soil type</th>
     <th bgcolor=$wr_color><font size=-3>Surface</th>
     <th bgcolor=$wr_color><font size=-3>Road length</th>
     <th bgcolor=$wr_color><font size=-3>Road gradient</th>
     <th bgcolor=$wr_color><font size=-3>Road width</th>
     <th bgcolor=$wr_color><font size=-3>Fill length</th>
     <th bgcolor=$wr_color><font size=-3>Fill steepness</th>
     <th bgcolor=$wr_color><font size=-3>Buffer length</th>
     <th bgcolor=$wr_color><font size=-3>Buffer steepness</th>
     <th bgcolor=$wr_color><font size=-3>Rock fragment</th>
     <th bgcolor=$wr_color><font size=-3>Road design</th>
     <th bgcolor=$wr_color><font size=-3>Units</th>
    </tr>";

open RUNLOG, "<$runlogfile";
my $count = 0;
my $gt    = 0;
while (<RUNLOG>) {

    my ( $prog, $rest ) = split "\t", $_, 0;

    if ( $prog eq 'WR' ) {
        (
            $prog,    $run_id, $run_time, $climate, $years2sim, $ST,
            $surface, $URL,    $URS,      $URW,     $UFL,       $UFS,
            $UBL,     $UBS,    $UBR,      $design,  $units
        ) = split "\t", $_;
        print "
    <tr>
     <td valign=top bgcolor=$wr_color><font size=-3>$run_id</td>
     <td valign=top><font size=-3>$run_time</td>
     <td valign=top><font size=-3>$climate</td>
     <td valign=top align=right><font size=-3>$years2sim</td>
     <td valign=top><font size=-3>$ST</td>
     <td valign=top><font size=-3>$surface</td>
     <td valign=top align=right><font size=-3>$URL</td>
     <td valign=top align=right><font size=-3>$URS</td>
     <td valign=top align=right><font size=-3>$URW</td>
     <td valign=top align=right><font size=-3>$UFL</td>
     <td valign=top align=right><font size=-3>$UFS</td>
     <td valign=top align=right><font size=-3>$UBL</td>
     <td valign=top align=right><font size=-3>$UBS</td>
     <td valign=top align=right><font size=-3>$UBR</td>
     <td valign=top><font size=-3>$design</td>
     <td valign=top><font size=-3>$units</td>
    </tr>";
        $count++;
    }    # if ($prog eq 'WR')
}    # while (<RUNLOG>)

print "
   </table>
   $count WEPP:Road runs
";

close RUNLOG;

##########################
###   Disturbed WEPP   ###
##########################

print "
   <a name='wd'></a>
   <h2>(<a href=\"#we\">V</a>) Disturbed WEPP runs</h2>
   <table border=1>
    <tr>
     <th valign=bottom bgcolor=#77c77><font size=-3>Run ID</th>
     <th valign=bottom bgcolor=$wd_color><font size=-3>Run time</th>
     <th valign=bottom bgcolor=$wd_color><font size=-3>Climate name</th>
     <th valign=bottom bgcolor=$wd_color><font size=-3>Simulation years</th>
     <th valign=bottom bgcolor=$wd_color><font size=-3>Soil</font></td>
     <th valign=bottom bgcolor=$wd_color><font size=-3>Upper treatment</font></td>
     <th valign=bottom bgcolor=$wd_color><font size=-3>Upper length</font></td>
     <th valign=bottom bgcolor=$wd_color><font size=-3>Upper top slope</font></td>
     <th valign=bottom bgcolor=$wd_color><font size=-3>Upper mid slope</font></td>
     <th valign=bottom bgcolor=$wd_color><font size=-3>Upper cover</font></td>
     <th valign=bottom bgcolor=$wd_color><font size=-3>Upper rock</font></td>
     <th valign=bottom bgcolor=$wd_color><font size=-3>Lower treatment</font></td>
     <th valign=bottom bgcolor=$wd_color><font size=-3>Lower length</font></td>
     <th valign=bottom bgcolor=$wd_color><font size=-3>Lower mid slope</font></td>
     <th valign=bottom bgcolor=$wd_color><font size=-3>Lower bot slope</font></td>
     <th valign=bottom bgcolor=$wd_color><font size=-3>Lower cover</font></td>
     <th valign=bottom bgcolor=$wd_color><font size=-3>Lower rock</font></td>
     <th valign=bottom bgcolor=$wd_color><font size=-3>Units</font></th>
     <th valign=bottom bgcolor=$wd_color><font size=-3>Run description</font></td>
    </tr>";

open RUNLOG, "<$runlogfile";
$gt += $count;
$count = 0;
while (<RUNLOG>) {

    ( $prog, $rest ) = split "\t", $_, 0;

    # print "$prog $program<br>\n";

    if ( $prog eq 'WD' ) {
        (
            $prog,           $run_id,      $run_time,
            $climate,        $years2sim,   $soil,
            $treat1,         $ofe1_length, $ofe1_top_slope,
            $ofe1_mid_slope, $ofe1_pcover, $ofe1_rock,
            $treat2,         $ofe2_length, $ofe2_mid_slope,
            $ofe2_bot_slope, $ofe2_pcover, $ofe2_rock,
            $ofe_area,       $units,       $description
        ) = split "\t", $_;
        print "
    <tr>
     <td valign=top bgcolor=$wd_color><font size=-3>$run_id</td>
     <td valign=top><font size=-3>$run_time</td>
     <td valign=top><font size=-3>$climate</td>
     <td valign=top><font size=-3>$years2sim</td>
     <td valign=top><font size=-3>$soil</font></td>
     <td valign=top><font size=-3>$treat1</font></td>
     <td valign=top><font size=-3>$ofe1_length</font></td>
     <td valign=top><font size=-3>$ofe1_top_slope</font></td>
     <td valign=top><font size=-3>$ofe1_mid_slope</font></td>
     <td valign=top><font size=-3>$ofe1_pcover</font></td>
     <td valign=top><font size=-3>$ofe1_rock</font></td>
     <td valign=top><font size=-3>$treat2</font></td>
     <td valign=top><font size=-3>$ofe2_length</font></td>
     <td valign=top><font size=-3>$ofe2_mid_slope</font></td>
     <td valign=top><font size=-3>$ofe2_bot_slope</font></td>
     <td valign=top><font size=-3>$ofe2_pcover</font></td>
     <td valign=top><font size=-3>$ofe2_rock</font></td>
     <td valign=top><font size=-3>$units</font></td>
     <td valign=top><font size=-3>$description</font></td>
    </tr>";
        $count++;
    }    # if ($prog eq 'WD') {
}    # while (<RUNLOG>) {

print "
   </table>
   $count Disturbed WEPP runs
";
close RUNLOG;

################
###   ERMIT  ###
################

print "
   <a name='we'></a>
   <h2>(<a href=\"#wf\">V</a>) ERMIT runs</h2>
   <table border=1>
    <tr>
     <th bgcolor=#e91d45><font size=-3>Run ID</th>
     <th bgcolor=$we_color><font size=-3>Run time</th>
     <th bgcolor=$we_color><font size=-3>Climate name</th>
     <th bgcolor=$we_color><font size=-3>Soil texture</th>
     <th bgcolor=$we_color><font size=-3>Rock content</th>
     <th bgcolor=$we_color><font size=-3>Vegetation type</th>
     <th bgcolor=$we_color><font size=-3>Hillslope top gradient</th>
     <th bgcolor=$we_color><font size=-3>Hillslope average gradient</th>
     <th bgcolor=$we_color><font size=-3>Hillslope bottom gradient</th>
     <th bgcolor=$we_color><font size=-3>Hillslope length</th>
     <th bgcolor=$we_color><font size=-3>Burn severity</th>
     <th bgcolor=$we_color><font size=-3>Percent shrub</th>
     <th bgcolor=$we_color><font size=-3>Percent grass</th>
     <th bgcolor=$we_color><font size=-3>Units</th>
    </tr>";

open RUNLOG, "<$runlogfile";
$gt += $count;
$count = 0;
while (<RUNLOG>) {

    ( $prog, $rest ) = split "\t", $_, 0;

    # print "$prog $program<br>\n";

    if ( $prog eq 'WE' ) {
        (
            $prog, $run_id,     $run_time,  $climate,   $soil,
            $rfg,  $vegetation, $top_slope, $avg_slope, $toe_slope,
            $h_l,  $severity,   $pct_shrub, $pct_grass, $units
        ) = split "\t", $_;
        print "
    <tr>
     <td valign=top bgcolor=$we_color><font size=-3>$run_id</td>
     <td valign=top><font size=-3>$run_time</td>
     <td valign=top><font size=-3>$climate</td>
     <td valign=top><font size=-3>$soil</td>
     <td valign=top><font size=-3>$rfg</td>
     <td valign=top><font size=-3>$vegetation</td>
     <td valign=top><font size=-3>$top_slope</td>
     <td valign=top><font size=-3>$avg_slope</td>
     <td valign=top><font size=-3>$toe_slope</td>
     <td valign=top><font size=-3>$h_l</td>
     <td valign=top><font size=-3>$severity</td>
     <td valign=top><font size=-3>$pct_shrub</td>
     <td valign=top><font size=-3>$pct_grass</td>
     <td valign=top><font size=-3>$units</td>
    </tr>";
        $count++;
    }    # if ($prog eq 'WE') {
}    # while (<RUNLOG>) {

close RUNLOG;

print "
   </table>
   $count ERMiT runs
";

###############
###   FuME  ###
###############

print "
   <a name='wf'></a>
   <h2>(<a href=\"#ww\">V</a>) FuME runs</h2>
   <table border=1>
    <tr>
     <th bgcolor=#f0a014><font size=-3>Run ID</th>
     <th bgcolor=$wf_color><font size=-3>Run time</th>
     <th bgcolor=$wf_color><font size=-3>Climate name</th>
     <th bgcolor=$wf_color><font size=-3>Soil texture</th>
     <th bgcolor=$wf_color><font size=-3>Hillslope length</th>
     <th bgcolor=$wf_color><font size=-3>Buffer length</th>
     <th bgcolor=$wf_color><font size=-3>Hillslope gradient top</th>
     <th bgcolor=$wf_color><font size=-3>Hillslope gradient middle</th>
     <th bgcolor=$wf_color><font size=-3>Hillslope gradient bottom</th>
     <th bgcolor=$wf_color><font size=-3>Wildfire cycle</th>
     <th bgcolor=$wf_color><font size=-3>Prescribed fire cycle</th>
     <th bgcolor=$wf_color><font size=-3>Thinning cycle</th>
     <th bgcolor=$wf_color><font size=-3>Road density</th>
     <th bgcolor=$wf_color><font size=-3>Units</th>
    </tr>";

open RUNLOG, "<$runlogfile";
$gt += $count;
$count = 0;
while (<RUNLOG>) {

    ( $prog, $rest ) = split "\t", $_, 0;

    # print "$prog $program<br>\n";

    if ( $prog eq 'WF' ) {
        (
            $prog,           $run_id,         $run_time,
            $climate,        $soil,           $h_l,
            $b_l,            $ofe1_top_slope, $ofe1_mid_slope,
            $ofe2_bot_slope, $w_cycle,        $r_cycle,
            $t_cycle,        $roaddensity,    $units
        ) = split "\t", $_;
        print "
    <tr>
     <td valign=top bgcolor=$wf_color><font size=-3>$run_id</td>
     <td valign=top><font size=-3>$run_time</td>
     <td valign=top><font size=-3>$climate</td>
     <td valign=top><font size=-3>$soil</td>
     <td valign=top><font size=-3>$h_l</td>
     <td valign=top><font size=-3>$b_l</td>
     <td valign=top><font size=-3>$ofe1_top_slope</td>
     <td valign=top><font size=-3>$ofe1_mid_slope</td>
     <td valign=top><font size=-3>$ofe2_bot_slope</td>
     <td valign=top><font size=-3>$w_cycle</td>
     <td valign=top><font size=-3>$r_cycle</td>
     <td valign=top><font size=-3>$t_cycle</td>
     <td valign=top><font size=-3>$roaddensity</td>
     <td valign=top><font size=-3>$units</td>
    </tr>";
        $count++;
    }    # if ($prog eq 'WF') {
}    # while (<RUNLOG>) {
close RUNLOG;

print "
   </table>
   $count FuME runs
";
close RUNLOG;

#WW
#$prog,$run_id,$run_time,$climate_name,$yrs,$soil,$upper_treat,$50,$0,$30,$40,$20,$lower_treat,$50,$30,$5,$40,$20,$0,$units,$run_description

########################################
###   Water And Sediment Predictor   ###
########################################

print "
   <a name='ww'></a>
   <h2>(<a href=\"#wt\">V</a>) WASP (Water And Sediment Predictor) runs</h2>
   <table border=1>
    <tr>
     <th valign=bottom bgcolor=#f0f014><font size=-3>Run ID</th>
     <th valign=bottom bgcolor=$wa_color><font size=-3>Run time</th>
     <th valign=bottom bgcolor=$wa_color><font size=-3>Climate name</th>
     <th valign=bottom bgcolor=$wa_color><font size=-3>Soil</font></td>
     <th valign=bottom bgcolor=$wa_color><font size=-3>Upper treatment</font></td>
     <th valign=bottom bgcolor=$wa_color><font size=-3>Upper length</font></td>
     <th valign=bottom bgcolor=$wa_color><font size=-3>Upper top slope</font></td>
     <th valign=bottom bgcolor=$wa_color><font size=-3>Upper mid slope</font></td>
     <th valign=bottom bgcolor=$wa_color><font size=-3>Upper cover</font></td>
     <th valign=bottom bgcolor=$wa_color><font size=-3>Upper rock</font></td>
     <th valign=bottom bgcolor=$wa_color><font size=-3>Upper depth</font></td>
     <th valign=bottom bgcolor=$wa_color><font size=-3>Lower treatment</font></td>
     <th valign=bottom bgcolor=$wa_color><font size=-3>Lower length</font></td>
     <th valign=bottom bgcolor=$wa_color><font size=-3>Lower mid slope</font></td>
     <th valign=bottom bgcolor=$wa_color><font size=-3>Lower bot slope</font></td>
     <th valign=bottom bgcolor=$wa_color><font size=-3>Lower cover</font></td>
     <th valign=bottom bgcolor=$wa_color><font size=-3>Lower rock</font></td>
     <th valign=bottom bgcolor=$wa_color><font size=-3>Lower depth</font></td>
     <th valign=bottom bgcolor=$wa_color><font size=-3>Restrict</font></th>
     <th valign=bottom bgcolor=$wa_color><font size=-3>Bedrock</font></th>
     <th valign=bottom bgcolor=$wa_color><font size=-3>Aniso ratio</font></th>
     <th valign=bottom bgcolor=$wa_color><font size=-3>Sat Hydro Cond</font></th>
     <th valign=bottom bgcolor=$wa_color><font size=-3>Units</font></th>
    </tr>";

open RUNLOG, "<$runlogfile";
$gt += $count;
$count = 0;
while (<RUNLOG>) {

    ( $prog, $rest ) = split "\t", $_, 0;

    if ( $prog eq 'WW' ) {
        (
            $prog,           $run_id,         $run_time,
            $climate,        $soil,           $treat1,
            $ofe1_length,    $ofe1_top_slope, $ofe1_mid_slope,
            $ofe1_pcover,    $ofe1_rock,      $ofe1_depth,
            $treat2,         $ofe2_length,    $ofe2_mid_slope,
            $ofe2_bot_slope, $ofe2_pcover,    $ofe2_rock,
            $ofe2_depth,     $restrict,       $rocktype,
            $aniso,          $sathydcond,     $units
        ) = split "\t", $_;
        print "
    <tr>
     <td valign=top bgcolor=$wa_color><font size=-3>$run_id</td>
     <td valign=top><font size=-3>$run_time</td>
     <td valign=top><font size=-3>$climate</td>
     <td valign=top><font size=-3>$soil</font></td>
     <td valign=top><font size=-3>$treat1</font></td>
     <td valign=top><font size=-3>$ofe1_length</font></td>
     <td valign=top><font size=-3>$ofe1_top_slope</font></td>
     <td valign=top><font size=-3>$ofe1_mid_slope</font></td>
     <td valign=top><font size=-3>$ofe1_pcover</font></td>
     <td valign=top><font size=-3>$ofe1_rock</font></td>
     <td valign=top><font size=-3>$ofe1_depth</font></td>
     <td valign=top><font size=-3>$treat2</font></td>
     <td valign=top><font size=-3>$ofe2_length</font></td>
     <td valign=top><font size=-3>$ofe2_mid_slope</font></td>
     <td valign=top><font size=-3>$ofe2_bot_slope</font></td>
     <td valign=top><font size=-3>$ofe2_pcover</font></td>
     <td valign=top><font size=-3>$ofe2_rock</font></td>
     <td valign=top><font size=-3>$ofe2_depth</font></td>
     <td valign=top><font size=-3>$restrict</font></td>
     <td valign=top><font size=-3>$rocktype</font></td>
     <td valign=top><font size=-3>$aniso</font></td>
     <td valign=top><font size=-3>$sathydcond</font></td>
     <td valign=top><font size=-3>$units</font></td>
    </tr>";
        $count++;
    }    # if ($prog eq 'ww') {
}    # while (<RUNLOG>) {

print "
   </table>
   $count WASP runs
";
close RUNLOG;

#WT
#$prog,$run_id,$run_time,$climate_name,$soil,$193,$1,$14,$28,$7,$40,$20,$20,$0,$units

#############################
###   Tahoe Basin Model   ###
#############################

print "
   <a name='wt'></a>
   <h2>(<a href=\"#end\">V</a>) Tahoe Basin Model runs</h2>
   <table border=1>
    <tr>
     <th valign=bottom bgcolor=#3fe275><font size=-3>Run ID</th>
     <th valign=bottom bgcolor=$wt_color><font size=-3>Run time</th>
     <th valign=bottom bgcolor=$wt_color><font size=-3>Climate name</th>
     <th valign=bottom bgcolor=$wt_color><font size=-3>Soil</font></td>
     <th valign=bottom bgcolor=$wt_color><font size=-3>Upper treatment</font></td>
     <th valign=bottom bgcolor=$wt_color><font size=-3>Upper top slope</font></td>
     <th valign=bottom bgcolor=$wt_color><font size=-3>Upper mid slope</font></td>
     <th valign=bottom bgcolor=$wt_color><font size=-3>Upper length</font></td>
     <th valign=bottom bgcolor=$wt_color><font size=-3>Upper cover</font></td>
     <th valign=bottom bgcolor=$wt_color><font size=-3>Upper rock</font></td>
     <th valign=bottom bgcolor=$wt_color><font size=-3>Lower treatment</font></td>
     <th valign=bottom bgcolor=$wt_color><font size=-3>Lower mid slope</font></td>
     <th valign=bottom bgcolor=$wt_color><font size=-3>Lower bot slope</font></td>
     <th valign=bottom bgcolor=$wt_color><font size=-3>Lower length</font></td>
     <th valign=bottom bgcolor=$wt_color><font size=-3>Lower cover</font></td>
     <th valign=bottom bgcolor=$wt_color><font size=-3>Lower rock</font></td>
     <th valign=bottom bgcolor=$wt_color><font size=-3>Units</font></th>
     <th valign=bottom bgcolor=$wt_color><font size=-3>Run description</font></td>
    </tr>";

open RUNLOG, "<$runlogfile";
$gt += $count;
$count = 0;
while (<RUNLOG>) {
    ( $prog, $rest ) = split "\t", $_, 0;

    # print "$prog $program<br>\n";

    if ( lc($prog) eq 'wt' ) {
        (
            $prog,           $run_id,         $run_time,
            $climate,        $soil,           $treat1,
            $ofe1_top_slope, $ofe1_mid_slope, $ofe1_length,
            $ofe1_pcover,    $ofe1_rock,      $treat2,
            $ofe2_mid_slope, $ofe2_bot_slope, $ofe2_length,
            $ofe2_pcover,    $ofe2_rock,      $units,
            $description
        ) = split "\t", $_;
        print "
    <tr>
     <td valign=top bgcolor=$wt_color><font size=-3>$run_id</td>
     <td valign=top><font size=-3>$run_time</td>
     <td valign=top><font size=-3>$climate</td>
     <td valign=top><font size=-3>$soil</font></td>
     <td valign=top><font size=-3>$treat1</font></td>
     <td valign=top><font size=-3>$ofe1_top_slope</font></td>
     <td valign=top><font size=-3>$ofe1_mid_slope</font></td>
     <td valign=top><font size=-3>$ofe1_length</font></td>
     <td valign=top><font size=-3>$ofe1_pcover</font></td>
     <td valign=top><font size=-3>$ofe1_rock</font></td>
     <td valign=top><font size=-3>$treat2</font></td>
     <td valign=top><font size=-3>$ofe2_mid_slope</font></td>
     <td valign=top><font size=-3>$ofe2_bot_slope</font></td>
     <td valign=top><font size=-3>$ofe2_length</font></td>
     <td valign=top><font size=-3>$ofe2_pcover</font></td>
     <td valign=top><font size=-3>$ofe2_rock</font></td>
     <td valign=top><font size=-3>$units</font></td>
     <td valign=top><font size=-3>$description</font></td>
    </tr>";
        $count++;
    }    # if ($prog eq 'wt') {
}    # while (<RUNLOG>) {

$gt += $count;
print "
   </table>
   <a name='end'></a>
   $count Tahoe Basin runs<br>
   $gt total runs
";
close RUNLOG;
print "  </font>
 </body>
</html>
";
