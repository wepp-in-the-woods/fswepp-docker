#! /usr/bin/perl

#  add link to (dead) cumulative runs and weekly runs graphs
#  scan FS WEPP run logs to report number of entries, and age of last entry
#  allow click to individual model run log report

#  2009.01.01 DEH modify for 2009
#  2008.01.01 DEH modify for 2008
#  2006.12.21 DEH modify for 2007; report model (interface) runs not WEPP runs
#  2005.12.31 DEH Modify for 2006
#  2005.11.08 DEH bump up WEPP runs for ERMiT
#  2005.07.14 DEH align number of runs and time-agos
#                 add <iframe> with lastclim.pl
#  2005.01.04 DEH change title 2004 to 2005
#  2004.10.19 DEH loopify; report days, hours, minutes as appropriate 2004.10.20 DEH

#  $ermit_factor=20;    # 2006.01.18 DEH (15 dits into week 3) erm.pl now dits 20, 30, or 40
   $ermit_factor=1;
   $chart=1;
   $graphwidth=600;
   @bgcol[0]='ivory';
   @bgcol[1]='lightgoldenrodyellow';
   $flipper = 0;

   @base=('wr', 'wrb', 'wd', 'we', 'wf');
   @link = map {$_ . 'tailer.pl'} @base;
   @logfile = map {'working/' . $_ . '.log'} @base;
   @colors = map {'/fswepp/images/' . $_ . '_color.gif'} @base;
#   @logfile=('working/wr.log', 'working/wrb.log', 'working/wd.log', 'working/we.log', 'working/wf.log');
#   @link=('wrtail.pl', 'wrbtail.pl', 'wdtail.pl', 'wetail.pl', 'wftail.pl');
   @prog=('WEPP:Road', 'WEPP:Road Batch', 'Disturbed WEPP', 'ERMiT', 'WEPP FuME');
   @image=('/fswepp/images/road4.gif', '/fswepp/images/roadb_r.gif', '/fswepp/images/disturb.gif', '/fswepp/images/ermit.gif', '/fswepp/images/fume.jpg');

    $now = localtime;
#   print "   <br><font size=-1>$now</font>";

   print "Content-type: text/html\n\n";
   print "<html>
 <head>
  <title>FS WEPP run logs</title>
 </head>
 <body>
  <font face='tahoma, arial, sans serif'>
   <h4>FS WEPP model runs YTD 2009 -- $now</h4>
   <table border=0>
";
  foreach $i (0..$#logfile) {
    if (-e @logfile[$i]) {
      $days_old = -M @logfile[$i];
      $long_ago = sprintf '%.2f', $days_old; $time=' days';
      if ($long_ago < 1) {$long_ago = sprintf '%.2f', $days_old*24; $time=' hours'}
      if ($long_ago < 1) {$long_ago = sprintf '%.2f', $days_old*24*60; $time=' minutes'}
      $wc  = `wc @logfile[$i]`;
      @words = split " ", $wc;
      $numruns = commify (@words[0]);
      $tailer=`tail -1 @logfile[$i]`;
      print "
    <tr>
     <td><a href='@link[$i]' target='_n'><img src='@image[$i]'></a></td>
     <td align='right'>$numruns<br>
      <img src='@colors[$i]' width=50 height=5><br>
      <font size=1>&nbsp;</font>
     </td>
     <td> <b>@prog[$i]</b> runs; most recent <br>
      <img src='@colors[$i]' width=100% height=5><br>
      <font size=1>$tailer</font>
     </td>
     <td>$long_ago $time ago<br>
      <img src='@colors[$i]' width=100% height=5><br>
      <font size=1>&nbsp;</font>
     </td>
    </tr>
";
#      print "   <img src='@colors[$i]' width=250 height=5><br>\n";
    }
  }
  print "   </table>\n";

#### ======================================= ####

  if ($chart) {

#
#  New year: change $thisdayoff factor (why) and @whatweek ***
#

    $thisday = 1+ (localtime)[7];                       # $yday, day of the year (0..364)
#   $thisdayoff=$thisday-2;
#   $thisdayoff=$thisday;                               # [Jan 1] Sunday: -1; Monday: 0;
#   $thisdayoff=$thisday+1;                             # 2008 Jan 1 is a Tuesday
    $thisdayoff=$thisday+3;                             # 2009 Jan 1 is a Thursday
    $thisweek = 1+ int $thisdayoff/7;

#   @whatweek=('','Jan 1-','Jan 8-','Jan 15-','Jan 22-','Jan 29-','Feb 5-','Feb 12-','Feb 19-','Feb 26-','Mar 5-','Mar 12-','Mar 19-','Mar 26-','Apr 2-','Apr 9-','Apr 16-','Apr 23-','Apr 30-','May 7-','May 14-','May 21-','May 28-','Jun 4-','Jun 11-','Jun 18-','Jun 25-','Jul 2-','Jul 9-','Jul 16-','Jul 23-','Jul 30-','Aug 6-','Aug 13-','Aug 20-','Aug 27-','Sep 3-','Sep 10-','Sep 17-','Sep 24-','Oct 1-','Oct 8-','Oct 15-','Oct 22-','Oct 29-','Nov 5-','Nov 12-','Nov 19-','Nov 26-','Dec 3-','Dec 10-','Dec 17-','Dec 24-');
#   @whatweek=('','Dec 31-','Jan 7-','Jan 14-','Jan 21-','Jan 28-','Feb 4-','Feb 11-','Feb 18-','Feb 25-','Mar 4-','Mar 11-','Mar 18-','Mar 25-','Apr 1-','Apr 8-','Apr 15-','Apr 22-','Apr 29-','May 6-','May 13-','May 20-','May 27-','Jun 3-','Jun 10-','Jun 17-','Jun 24-','Jul 1-','Jul 8-','Jul 15-','Jul 22-','Jul 29-','Aug 5-','Aug 12-','Aug 21-','Aug 26-','Sep 2-','Sep 9-','Sep 16-','Sep 23-','Sep 30-','Oct 7-','Oct 14-','Oct 21-','Oct 28-','Nov 4-','Nov 11-','Nov 18-','Nov 25-','Dec 2-','Dec 9-','Dec 16-','Dec 23-','Dec 30-');
    @whatweek=('','Jan 1-','Jan 4-','Jan 11-','Jan 18-','Jan 25-','Feb 1-','Feb 08-','Feb 15-','Feb 22-','Mar 1-','Mar 8-','Mar 15-','Mar 22-','Mar 29-','Apr 5-','Apr 12-','Apr 19-','Apr 26-','May 3-','May 10-','May 17-','May 24-','May 31-','Jun 7-','Jun 14-','Jun 21-','Jun 28-','Jul 5-','Jul 12-','Jul 19-','Jul 26-','Aug 2-','Aug 9-','Aug 16-','Aug 23-','Aug 30-','Sep 6-','Sep 13-','Sep 20-','Sep 27-','Oct 4-','Oct 11-','Oct 18-','Oct 25-','Nov 1-','Nov 8-','Nov 15-','Nov 22-','Nov 29-','Dec 6-','Dec 13-','Dec 20-','Dec 27-');

    $maxruns=0;
    foreach $week (1..$thisweek) {
      foreach $prog ('wr','wrb','wd','we','wf') {
        $file = 'working/' . $prog . '/' . $week;
        if (-e $file) {
          $runs = -s $file;
#          $runs*=12 if ($prog eq 'wf');
#          $runs*=$ermit_factor if ($prog eq 'we');
        }
        else {
          $runs = 0
        }
        $maxruns = $runs if ($runs > $maxruns);
        @{$prog}[$week] = $runs;
      }         # foreach $prog ()
    }   # foreach $week ()

    $scale = 1;
    $scale = $graphwidth / $maxruns if ($maxruns > $graphwidth);

# print "scale: $scale\n";

    $framewidth=$graphwidth+30;

    print "
    <iframe src='/cgi-bin/fswepp/lastclim.pl' frameborder=0 width=$framewidth height=38>
    </iframe>
";
    print "
    <a href=\"javascript:var navWin = window.open('/cgi-bin/engr/resolve_dq.pl','NewWin','scrollbars,toolbar=false,menubar=false,resizable=true,width=400,height=300')\">dq</a>
";
    print '   <h5>
    Number of model runs per week
   </h5>
   <table bgcolor="black" cellpadding=3>
';
#    print '
#   <h5>
#    Number of runs per week by model<br> (
#    <img src="/fswepp/images/wr_color.gif" width=25 height=5> WEPP:Road
#    <img src="/fswepp/images/wrb_color.gif" width=25 height=5> WEPP:Road batch (segments)
#    <img src="/fswepp/images/wd_color.gif" width=25 height=5> Disturbed WEPP
#    <img src="/fswepp/images/we_color.gif" width=25 height=5> ERMiT
#    <img src="/fswepp/images/wf_color.gif" width=25 height=5> WEPP Fume )
#   </h5>
#   <table bgcolor="black" cellpadding=3>
#';

    @weeks = (1..$thisweek);
    @revweeks = reverse @weeks;

    foreach $week (@revweeks) {
#    foreach $week (1..$thisweek) {
      $flipper = !$flipper;
      print "    <tr>
     <td bgcolor='@bgcol[$flipper]'>@whatweek[$week]</td>
     <td bgcolor='@bgcol[$flipper]' width='$graphwidth'>
";
      $sumruns=0;
      foreach $prog ('wr','wrb','wd','we','wf') {
        $file = 'working/' . $prog . '/' . $week;
        $color = '/fswepp/images/' . $prog . '_color.gif';
        $runs=@{$prog}[$week];
        $sumruns += $runs;
        $runscale=int $runs * $scale;
        $runscale=1 if ($runscale==0);
        if ($runscale>0) {print "      <img src='$color' width='$runscale' height='5' title='$prog: $runs runs'><br>\n"};
      }         # foreach $prog ()
     $sumruns = commify ($sumruns);
     print "     </td>
     <td bgcolor='@bgcol[$flipper]' align='right'>$sumruns</td>
    </tr>
";
    }   # foreach $week ()

  }     # if ($chart)

  print '   </table>
   <h5>1 WEPP run per road segment for WEPP:Road batch<br>12 WEPP runs per WEPP FuME run<br>20, 30, or 40 WEPP runs per ERMiT run</h5>

<br><br><a href="/cgi-bin/fswepp/2008weppruns.pl">2008 model runs</a>
<br><br><a href="weppruns2007s.pl">2007 model runs</a>
<br><br><a href="/fswepp/runs/2006weppruns.html">2006 usage</a>

  </font>
 </body>
</html>
';
sub commify {
    my $text = reverse $_[0];
    $text =~ s/(\d\d\d)(?=\d)(?!d*\.)/$1,/g;
    return scalar reverse $text;
}

