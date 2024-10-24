#!/usr/bin/perl

use warnings;
use CGI;
use CGI qw(escapeHTML);
use POSIX qw(strftime);
use Time::Local qw(timegm);
use Date::Calc qw(Add_Delta_Days);


#  2013.01.07 DEH recover from accidental justification!
#  2012.12.30 DEH beef up calendar; add year parameter add link to (dead) cumulative runs and weekly runs graphs scan
#  FS WEPP run logs to report number of entries, and age of last entry allow click to individual model run log report

#  2011.09.06 DEH add link to 'pop-up' climinute.pl and expand on 'dq' 2011.07.29 DEH add bERMiT and Disturbed WEPP
#  Batch 2010.12.31 DEH modify for 2011 (need to finish Sundays) and add WEPP Runs for 2010 at bottom 2010.02.26 DEH
#  add WASP and Tahoe 2010.01.01 DEH modify for 2010 2009.01.01 DEH modify for 2009 2008.01.01 DEH modify for 2008
#  2006.12.21 DEH modify for 2007; report model (interface) runs not WEPP runs 2005.12.31 DEH Modify for 2006
#  2005.11.08 DEH bump up WEPP runs for ERMiT 2005.07.14 DEH align number of runs and time-agos
#                 add <iframe> with lastclim.pl 2005.01.04 DEH change title 2004 to 2005 2004.10.19 DEH loopify; report
#  days, hours, minutes as appropriate 2004.10.20 DEH

# $ermit_factor=20;  # 2006.01.18 DEH (15 dits into week 3) erm.pl now dits 20, 30, or 40
$ermit_factor = 1;
$chart        = 1;
$graphwidth   = 600;
@bgcol[0]     = 'ivory';
@bgcol[1]     = 'lightgoldenrodyellow';
$flipper      = 0;

# Get current year and day of the year
my $thisday  = 1 + (localtime)[7];  # day of the year (0..364)
my $thisyear = 1900 + (localtime)[5];

my $query = CGI->new;
my $year = escapeHTML( scalar $query->param('year') );
$year = $thisyear if !defined $year || $year eq '';

# Determine the day of the week for Jan 1 of the specified year
my ($jan1_year, $jan1_month, $jan1_day) = ($year, 1, 1);
my $jan1_day_of_week = (localtime(timegm(0, 0, 0, $jan1_day, $jan1_month - 1, $jan1_year - 1900)))[6]; 
my $dayoffset = $jan1_day_of_week == 0 ? -1 : $jan1_day_of_week - 1;  # Adjust day offset for calendar

# Dynamically generate the @whatweek array based on the year
my @whatweek = ('');  # Start with an empty week 0

# Add each week by calculating the date for the start of each week
for my $week_num (0..51) {
    my ($week_year, $week_month, $week_day) = Add_Delta_Days($jan1_year, 1, 1, 7 * $week_num);
    my $week_start = sprintf("%s %02d-", strftime('%b', 0, 0, 0, $week_day, $week_month - 1, $week_year - 1900), $week_day);
    push @whatweek, $week_start;
}

# Calculate day and week offset for the current year or the specified year
my $thisdayoff = $thisday + $dayoffset;
my $thisweek = 1 + int($thisdayoff / 7);



#
######################################################################

@base    = ( 'wr', 'wrb', 'wd2', 'wd', 'dwb', 'we', 'web', 'wf', 'wa', 'wt' );
@link    = map { "tailer.pl?year=$year&log=$_" } @base;
@logfile = map { "working/_$year/" . $_ . '.log' } @base;
@colors  = map { '/fswepp/images/' . $_ . '_color.gif' } @base;
@prog    = (
    'WEPP:Road',
    'WEPP:Road Batch',
    'Dist WEPP 2.0',
    'Dist WEPP 1.0',
    'Disturbed WEPP Batch',
    'ERMiT',
    'bERMiT',
    'WEPP FuME',
    'WASP',
    'Tahoe Basin'
);
@image = (
    '/fswepp/images/road4.gif',     '/fswepp/images/roadb_r.gif',
    '/fswepp/images/disturb.gif',   '/fswepp/images/disturb.gif',
    '/fswepp/images/dWb.gif',       '/fswepp/images/ermit.gif',
    '/fswepp/images/bERMiT.gif',    '/fswepp/images/fume.jpg',
    '/fswepp/images/wasp_logo.png', '/fswepp/images/tahoelogo.jpg'
);

$now = localtime;

print "Content-type: text/html\n\n";

print "<html>
 <head>
  <title>FS WEPP run logs</title>
 </head>
 <body>
  <font face='tahoma, arial, sans serif'>
   <h4>FS WEPP model runs $year </h4>
";

print "
   <table border=0>
 ";
foreach $i ( 0 .. $#logfile ) {
    if ( -e @logfile[$i] ) {
        $days_old = -M @logfile[$i];
        $long_ago = sprintf '%.2f', $days_old;
        $time     = ' days';
        if ( $long_ago < 1 ) {
            $long_ago = sprintf '%.2f', $days_old * 24;
            $time     = ' hours';
        }
        if ( $long_ago < 1 ) {
            $long_ago = sprintf '%.2f', $days_old * 24 * 60;
            $time     = ' minutes';
        }
        $wc      = `wc @logfile[$i]`;
        @words   = split " ", $wc;
        $numruns = commify( @words[0] );
###
##  patch for incomplete recording of WEPP:Road runs through WWPP:Road Batch (dit log seems correct, wr.log missing batch segments record)

        if ( @logfile[$i] eq 'working/_2015/wr.log' ) {
            $dits = 0;
            foreach $i ( 0 .. 53 ) {
                $dits += -s "working/_2015/wr/$i";
            }
        }
        if ( @logfile[$i] eq 'working/_2014/wr.log' ) {
            $dits = 0;
            foreach $i ( 0 .. 53 ) {
                $dits += -s "working/_2014/wr/$i";
            }
        }
        $dits = commify($dits);
###
        $tailer = `tail -1 @logfile[$i]`;
        ( $ip, $rest ) = split ' ', $tailer, 2;
        chomp $tailer;
        print "   <tr>
     <td><a href='@link[$i]' target='_n'><img src='@image[$i]'></a></td>
";
###
        if (   @logfile[$i] eq 'working/_2014/wr.log'
            || @logfile[$i] eq 'working/_2015/wr.log' )
        {
            print
"      <td align='right'>$numruns<br><img src='@colors[$i]' width=50 height=5><br><font size=1>&nbsp;$dits</font></td>";
        }
        else {
            print
"      <td align='right'>$numruns<br><img src='@colors[$i]' width=50 height=5><br><font size=1>&nbsp;</font></td>";
        }
###
        print "
     <td><b>@prog[$i]</b> runs; most recent<br><img src='@colors[$i]' width=100% height=5><br><font size=1>$rest</font></td>
     <td>$long_ago $time ago<br> <img src='@colors[$i]' width=100% height=5><br></td>
    </tr>
 ";

    }
}
print "  </table>
";

#### ======================================= ####

if ($chart) {

    $endweek = 52 if ( $year < $thisyear );   # report whole year for past years
    $endweek = $thisweek
      if ( $year == $thisyear );              # report YTD for current year
    $endweek = 0 if ( $year > $thisyear );    # no runs for future

    $maxruns = 0;

    #   foreach $week (1..$thisweek) {
    foreach $week ( 1 .. $endweek ) {

        #     foreach $prog ('wr','wrb','wd','we','wf','wa','wt') {
        foreach $prog ( 'wr', 'wrb', 'wd2', 'wd', 'we', 'wf', 'wa', 'wt' )
        {    # 2013.01.07 DEH

            #       $file = 'working/' . $prog . '/' . $week;
            $file = "working/_$year/$prog/$week";
            if   ( -e $file ) { $runs = -s $file; }
            else              { $runs = 0 }
            $maxruns = $runs if ( $runs > $maxruns );
            @{$prog}[$week] = $runs;
        }    # foreach $prog ()
    }    # foreach $week ()

    $scale = 1;
    $scale = $graphwidth / $maxruns if ( $maxruns > $graphwidth );

    print "
   <br>
   <font size=-1>
    [<a href=\"javascript:var navWin2 = window.open('/cgi-bin/fswepp/climinute.pl','NewWin2','scrollbars,toolbar=false,menubar=false,resizable=true,width=360,height=100')\">1-minute run check</a>]
   </font>
";
    print '
   <h5> Number of model runs per week </h5>
   <table bgcolor="black" cellpadding=3>
';

    @weeks     = ( 1 .. $endweek );
    @revweeks  = reverse @weeks;
    $totalruns = 0;                   # 2017 DEH
    foreach $week (@revweeks) {
        $flipper = !$flipper;
        print "    <tr>
     <td bgcolor='@bgcol[$flipper]'>@whatweek[$week]</td>
     <td bgcolor='@bgcol[$flipper]' width='$graphwidth'>
";
        $sumruns = 0;

        #     foreach $prog ('wr','wrb','wd','we','wf','wa','wt') {
        foreach $prog ( 'wr', 'wrb', 'wd2', 'wd', 'we', 'wf', 'wa', 'wt' )
        {    # 2013.01.07 DEH

            #       $file = 'working/' . $prog . '/' . $week;
            $file  = "working/_$year/$prog/$week";
            $color = '/fswepp/images/' . $prog . '_color.gif';
            $runs  = @{$prog}[$week];
            $sumruns += $runs;
            $runscale = int $runs * $scale;
            $runscale = 1 if ( $runscale == 0 );
            if ( $runscale > 0 ) {
                print
"      <img src='$color' width='$runscale' height='5' title='$prog: $runs runs'><br>\n";
            }
        }    # foreach $prog ()
        $totalruns += $sumruns;    # 2017 DEH
        $sumruns = commify($sumruns);
        print "     </td>
     <td bgcolor='@bgcol[$flipper]' align='right'>$sumruns</td>
    </tr>
";
    }    # foreach $week ()
}    # if ($chart)

print '   </table>';    # 2017 DEH

$totalruns = commify($totalruns);                # 2017 DEH
print "\n<br> $totalruns total model runs\n";    # 2017 DEH
print '
   <h5>1 WEPP run per road segment for WEPP:Road batch<br>
       12 WEPP runs per WEPP FuME run<br>
       20, 30, or 40 WEPP runs per ERMiT run
   </h5>
   <br><br>
   <a href="?year=2025">2025</a>
   <a href="?year=2024">2024</a>
   <a href="?year=2023">2023</a>
   <a href="?year=2022">2022</a>
   <a href="?year=2021">2021</a>
   <a href="?year=2020">2020</a>
   <a href="?year=2019">2019</a>
   <a href="?year=2018">2018</a>
   <a href="?year=2017">2017</a>
   <a href="?year=2016">2016</a>
   <a href="?year=2015">2015</a>
   <a href="?year=2014">2014</a>
   <a href="?year=2013">2013</a>
   <a href="?year=2012">2012</a>
   <a href="?year=2011">2011</a>
   <a href="?year=2010">2010</a>
   <a href="?year=2009">2009</a>
   <a href="?year=2008">2008</a>
   <a href="?year=2007">2007</a>
   <br><br>
  </font>
 </body>
</html>
';

# ------------------------ subroutines ---------------------------

sub commify {
    my $text = reverse $_[0];
    $text =~ s/(\d\d\d)(?=\d)(?!d*\.)/$1,/g;
    return scalar reverse $text;
}

