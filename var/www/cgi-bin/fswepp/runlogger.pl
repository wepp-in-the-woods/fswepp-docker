#!/usr/bin/perl
use CGI qw(escapeHTML);

#
# read given FS WEPP runlog file and return HTML
#

# to do: validate [ddd].[ddd].[ddd].[ddd][a-zA-Z]

#    add color on first table box to indicate model (all the way down, not just the header)
#    read from argument list the IP
#    166.2.22.221 or 166_2_22_221
# if not there, read from user machine
#    what about 'me'?
#
#      ?ip=166.2.22.220		-- personality ''
#      ?ip=166.2.22.220a	-- personality 'a'

&ReadParse(*parameters);
$ip = escapeHTML($parameters{'ip'});
   # https://forest.moscowfsl.wsu.edu/cgi-bin/fswepp/runlogger.pl?ip=<meta%20http-equiv=Set-Cookie%20content="testlfyg=5195">

if ( $ip ne '' ) {
    $ipd = $ip;
    $ipd =~ tr/./_/;
}

#   $ipd = '166_2_22_221';			# get from caller or argument list
else {    # who am I?
    $ip          = $ENV{'REMOTE_ADDR'};
    $user_really = $ENV{'HTTP_X_FORWARDED_FOR'};
    $ip          = $user_really if ( $user_really ne '' );
    $ipd         = $ip;
    $ipd =~ tr/./_/;
}

##################################################
#   validate dotted quad
##################################################

# strip single letter (a-zA-Z)($me) off end if it exists

$ipp = $ip;
$ipp = substr( $ip, 0,  -1 ) if ( $ip =~ m/[a-z]$/i );
$me  = substr( $ip, -1, 1 )  if ( $ip =~ m/[a-z]$/i );

if ( $ipp =~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/
    && ( ( $1 <= 255 && $2 <= 255 && $3 <= 255 && $4 <= 255 ) ) )
{
    $valid_ip = "valid";
}
else {
    $valid_ip = "invalid";
}

#    https://stackoverflow.com/questions/2346869/what-regex-can-i-use-to-match-any-valid-ip-address-represented-in-dot-decimal-no

#################################################
#################################################

$runlogfile = 'working/' . $ipd . '.run.log';

# WR      wepp-6551       "05:51 pm  Tuesday February 23, 2010"	"SANDPOINT EXP STA ID"	8       clay    native  200     4   13       15      50      130     25      20      inveg
# WD      wepp-6860       "02:54 pm  Thursday January 28, 2010"	"SANTA MONICA PIER CA"	30      clay    short   50      0   30       40      20      short   50      30      5       40      20      0       m       ""
# WF      wepp-30788      "03:31 pm  Friday January 22, 2010"	"WhiteKnob +"	sand    193     1       14      28      7   40       20      20      0       ft
# WE      wepp-7122       "04:24 pm  Friday March 5, 1902"	"Melbourne AU +"	clay    20      forest  0       50  30       100     l
# WW      wepp-5118       "05:13 pm  Monday April 12, 2010"	"Melbourne AU +"	clay    skid    50      0       30      10  20       400     skid    50      30      5       100     20      400     restricted      "fractured igneous and metamorphic" 25       9.00E-05        m
# wt      "May 25, 2010"  "RUBICON #2 CA SNOTEL +"        granitic        OldForest       0       30      50      100       20      YoungForest     30      5       50      100     20      m	""

$wr_color = '#a1a1f7';    # WEPP:Road
$wd_color = '#77c677';    # Disturbed WEPP
$we_color = '#e91d45';    # ERMiT
$wf_color = '#f0a014';    # FuME
$wa_color = '#f0f014';    # WASP
$wt_color = '#3fe275';    # Tahoe

#  print table header

print "Content-type: text/html\n\n";
print "
<html>
 <head>
  <title>FS WEPP run log for $ip</title>
 </head>
 <body link=black vlink=black alink=crimson>
  <font face=\"trebuchet, tahoma, arial, sans serif\" size=-3>
";

if ( $valid_ip eq 'invalid' ) {
    print "
   <h3>Run log for [Invalid IP]</h3>
  </font>
 </body>
</html>";
    die;
}

print "
   <h3>Run log for IP $ipp personality '$me'</h3>
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
$count = 0;
$gt    = 0;
while (<RUNLOG>) {

    ( $prog, $rest ) = split "\t", $_, 0;

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

# ------------------------ subroutines ---------------------------

sub ReadParse {

    # ReadParse -- from cgi-lib.pl (Steve Brenner) from Eric Herrmann's
    # "Teach Yourself CGI Programming With PERL in a Week" p. 131

    local (*in) = @_ if @_;
    local ( $i, $loc, $key, $val );

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
