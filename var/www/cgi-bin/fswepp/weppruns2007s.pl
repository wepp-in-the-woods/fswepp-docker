#! /usr/bin/perl

#  add link to (dead) cumulative runs and weekly runs graphs
#  scan FS WEPP run logs to report number of entries, and age of last entry
#  allow click to individual model run log report

#  2006.12.21 DEH modify for 2007; report model (interface) runs not WEPP runs
#  2005.12.31 DEH Modify for 2006
#  2005.11.08 DEH bump up WEPP runs for ERMiT
#  2005.07.14 DEH align number of runs and time-agos
#                 add <iframe> with lastclim.pl
#  2005.01.04 DEH change title 2004 to 2005
#  2004.10.19 DEH loopify; report days, hours, minutes as appropriate 2004.10.20 DEH

#  $ermit_factor=20;	# 2006.01.18 DEH (15 dits into week 3) erm.pl now dits 20, 30, or 40
   $ermit_factor=1;
   $chart=1;
   $graphwidth=600;
   @bgcol[0]='ivory';
   @bgcol[1]='lightgoldenrodyellow';
   $flipper = 0;

   @base=('wr', 'wrb', 'wd', 'we', 'wf');
   @link = map {$_ . 'tail2007.pl'} @base;
   @logfile = map {'working/' . $_ . '2007.log'} @base;
   @colors = map {'/fswepp/images/' . $_ . '_color.gif'} @base;
#   @logfile=('working/wr.log', 'working/wrb.log', 'working/wd.log', 'working/we.log', 'working/wf.log');
#   @link=('wrtail.pl', 'wrbtail.pl', 'wdtail.pl', 'wetail.pl', 'wftail.pl');
   @prog=('WEPP:Road', 'WEPP:Road Batch', 'Disturbed WEPP', 'ERMiT', 'WEPP FuME');
   @image=('/fswepp/images/road4.gif', '/fswepp/images/roadb_r.gif', '/fswepp/images/disturb.gif', '/fswepp/images/ermit.gif', '/fswepp/images/fume.jpg');

#    $now = localtime;
#   print "   <br><font size=-1>$now</font>";

   print "Content-type: text/html\n\n";
   print "<html>
 <head>
  <title>FS WEPP run logs</title>
 </head>
 <body>
  <font face='tahoma, arial, sans serif'>
   <h4>FS WEPP model runs 2007 </h4>
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
    <tr valign='bottom'>
     <td><img src='@image[$i]'></td>
     <td align='right' valign='bottom'>$numruns<br>
      <img src='@colors[$i]' width=50 height=5><br>
      <font size=1>&nbsp;</font>
     </td>
     <td valign='bottom'> <b>@prog[$i]</b> runs<br>
      <img src='@colors[$i]' width=100% height=5><br>
     </td>
    </tr>
";
#      print "   <img src='@colors[$i]' width=250 height=5><br>\n";
    }
  }
  print "   </table>\n";

#### ======================================= ####

  if ($chart) {

    $thisday = 1+ (localtime)[7];			# $yday, day of the year (0..364)
#   $thisdayoff=$thisday-2;
    $thisdayoff=$thisday; 				# [Jan 1] Sunday: -1; Monday: 0;
    $thisweek = 1+ int $thisdayoff/7;

#   @whatweek=('','Jan 1-','Jan 8-','Jan 15-','Jan 22-','Jan 29-','Feb 5-','Feb 12-','Feb 19-','Feb 26-','Mar 5-','Mar 12-','Mar 19-','Mar 26-','Apr 2-','Apr 9-','Apr 16-','Apr 23-','Apr 30-','May 7-','May 14-','May 21-','May 28-','Jun 4-','Jun 11-','Jun 18-','Jun 25-','Jul 2-','Jul 9-','Jul 16-','Jul 23-','Jul 30-','Aug 6-','Aug 13-','Aug 20-','Aug 27-','Sep 3-','Sep 10-','Sep 17-','Sep 24-','Oct 1-','Oct 8-','Oct 15-','Oct 22-','Oct 29-','Nov 5-','Nov 12-','Nov 19-','Nov 26-','Dec 3-','Dec 10-','Dec 17-','Dec 24-');
    @whatweek=('','Dec 31-','Jan 7-','Jan 14-','Jan 21-','Jan 28-','Feb 4-','Feb 11-','Feb 18-','Feb 25-','Mar 4-','Mar 11-','Mar 18-','Mar 25-','Apr 1-','Apr 8-','Apr 15-','Apr 22-','Apr 29-','May 6-','May 13-','May 20-','May 27-','Jun 3-','Jun 10-','Jun 17-','Jun 24-','Jul 1-','Jul 8-','Jul 15-','Jul 22-','Jul 29-','Aug 5-','Aug 12-','Aug 21-','Aug 26-','Sep 2-','Sep 9-','Sep 16-','Sep 23-','Sep 30-','Oct 7-','Oct 14-','Oct 21-','Oct 28-','Nov 4-','Nov 11-','Nov 18-','Nov 25-','Dec 2-','Dec 9-','Dec 16-','Dec 23-','Dec 30-');

    $maxruns=0;
    foreach $week (1..53) {
      foreach $prog ('wr2007','wrb2007','wd2007','we2007','wf2007') {
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
      }		# foreach $prog ()
    }	# foreach $week ()

    $scale = 1;
    $scale = $graphwidth / $maxruns if ($maxruns > $graphwidth);

# print "scale: $scale\n";

#    $framewidth=$graphwidth+30;

#    print "
#    <iframe src='/cgi-bin/fswepp/lastclim.pl' frameborder=0 width=$framewidth height=38>
#    </iframe>
#";
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

    @weeks = (1..53);
    @revweeks = reverse @weeks;

    foreach $week (@revweeks) {
#    foreach $week (1..$thisweek) {
      $flipper = !$flipper;
      print "    <tr>
     <td bgcolor='@bgcol[$flipper]'>@whatweek[$week]</td>
     <td bgcolor='@bgcol[$flipper]' width='$graphwidth'>
";
      $sumruns=0;
      foreach $progbase ('wr','wrb','wd','we','wf') {
        $prog=$progbase . '2007';
        $file = 'working/' . $prog . '/' . $week;
        $color = '/fswepp/images/' . $progbase . '_color.gif';
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

  }	# if ($chart)

  print '   </table>
   <h5>1 WEPP run per road segment for WEPP:Road batch<br>12 WEPP runs per WEPP FuME run<br>20, 30, or 40 WEPP runs per ERMiT run</h5>

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
