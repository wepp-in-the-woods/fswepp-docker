#! /usr/bin/perl

#  add link to (dead) cumulative runs and weekly runs graphs
#  scan FS WEPP run logs to report number of entries, and age of last entry
#  allow click to individual model run log report

#  2011.07.29 DEH add bERMiT and Disturbed WEPP Batch
#  2010.12.31 DEH modify for 2011 (need to finish Sundays) and add WEPP Runs for 2010 at bottom
#  2010.02.26 DEH add WASP and Tahoe
#  2010.01.01 DEH modify for 2010
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

   @base=('wr', 'wrb', 'wd2', 'wd', 'dwb', 'we', 'web', 'wf', 'wa', 'wt');
   @link = map {$_ . 'tailer.pl'} @base;
   @logfile = map {'working/' . $_ . '.log'} @base;
   @colors = map {'/fswepp/images/' . $_ . '_color.gif'} @base;
   @prog=('WEPP:Road', 'WEPP:Road Batch', 'Dist WEPP 2.0', 'Dist WEPP 1.0', 'Disturbed WEPP Batch', 'ERMiT', 'bERMiT', 'WEPP FuME', 'WASP', 'Tahoe Basin');
   @image=('/fswepp/images/road4.gif', '/fswepp/images/roadb_r.gif', '/fswepp/images/disturb.gif', '/fswepp/images/disturb.gif', '/fswepp/images/dWb.gif', '/fswepp/images/ermit.gif', '/fswepp/images/bERMiT.gif', '/fswepp/images/fume.jpg','/fswepp/images/wasp_logo.png','/fswepp/images/tahoelogo.jpg');

    $now = localtime;
#   print "   <br><font size=-1>$now</font>";

   print "Content-type: text/html\n\n";
   print "<html>
 <head>
  <title>FS WEPP run logs</title>
 </head>
 <body>
  <font face='tahoma, arial, sans serif'>
   <h4>FS WEPP model runs YTD 2011 -- $now</h4>
";

#  print "166.2.22.221: "; 
#  $domain = &resolve_dq ('166.2.22.221');
#  print "result: $domain";
# die;

print "
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
($ip,$rest)=split ' ',$tailer,2;
$resolved=&resolve_dq($ip);
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
      <font size=1>$resolved</font>
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
#   $thisdayoff=$thisday+3;                             # 2009 Jan 1 is a Thursday
#   $thisdayoff=$thisday+4;                             # 2010 Jan 1 is a Friday
    $thisdayoff=$thisday+5;                             # 2011 Jan 1 is a Saturday
    $thisweek = 1+ int $thisdayoff/7;

#   @whatweek=('','Jan 1-','Jan 8-','Jan 15-','Jan 22-','Jan 29-','Feb 5-','Feb 12-','Feb 19-','Feb 26-','Mar 5-','Mar 12-','Mar 19-','Mar 26-','Apr 2-','Apr 9-','Apr 16-','Apr 23-','Apr 30-','May 7-','May 14-','May 21-','May 28-','Jun 4-','Jun 11-','Jun 18-','Jun 25-','Jul 2-','Jul 9-','Jul 16-','Jul 23-','Jul 30-','Aug 6-','Aug 13-','Aug 20-','Aug 27-','Sep 3-','Sep 10-','Sep 17-','Sep 24-','Oct 1-','Oct 8-','Oct 15-','Oct 22-','Oct 29-','Nov 5-','Nov 12-','Nov 19-','Nov 26-','Dec 3-','Dec 10-','Dec 17-','Dec 24-');
#   @whatweek=('','Dec 31-','Jan 7-','Jan 14-','Jan 21-','Jan 28-','Feb 4-','Feb 11-','Feb 18-','Feb 25-','Mar 4-','Mar 11-','Mar 18-','Mar 25-','Apr 1-','Apr 8-','Apr 15-','Apr 22-','Apr 29-','May 6-','May 13-','May 20-','May 27-','Jun 3-','Jun 10-','Jun 17-','Jun 24-','Jul 1-','Jul 8-','Jul 15-','Jul 22-','Jul 29-','Aug 5-','Aug 12-','Aug 21-','Aug 26-','Sep 2-','Sep 9-','Sep 16-','Sep 23-','Sep 30-','Oct 7-','Oct 14-','Oct 21-','Oct 28-','Nov 4-','Nov 11-','Nov 18-','Nov 25-','Dec 2-','Dec 9-','Dec 16-','Dec 23-','Dec 30-');
#09 @whatweek=('','Jan 1-','Jan 4-','Jan 11-','Jan 18-','Jan 25-','Feb 1-','Feb 08-','Feb 15-','Feb 22-','Mar 1-','Mar 8-','Mar 15-','Mar 22-','Mar 29-','Apr 5-','Apr 12-','Apr 19-','Apr 26-','May 3-','May 10-','May 17-','May 24-','May 31-','Jun 7-','Jun 14-','Jun 21-','Jun 28-','Jul 5-','Jul 12-','Jul 19-','Jul 26-','Aug 2-','Aug 9-','Aug 16-','Aug 23-','Aug 30-','Sep 6-','Sep 13-','Sep 20-','Sep 27-','Oct 4-','Oct 11-','Oct 18-','Oct 25-','Nov 1-','Nov 8-','Nov 15-','Nov 22-','Nov 29-','Dec 6-','Dec 13-','Dec 20-','Dec 27-');
#  @whatweek=('','Jan 1-','Jan 3-','Jan 10-','Jan 17-','Jan 24-','Jan 31-','Feb 07-','Feb 14-','Feb 21-','Feb 28-','Mar 7-','Mar 14-','Mar 21-','Mar 28-','Apr 4-','Apr 11-','Apr 18-','Apr 25-','May 2-','May 9-','May 16-','May 23-','May 30-','Jun 6-','Jun 13-','Jun 20-','Jun 27-','Jul 4-','Jul 11-','Jul 18-','Jul 25-','Aug 1-','Aug 8-','Aug 15-','Aug 22-','Aug 29-','Sep 5-','Sep 12-','Sep 19-','Sep 26-','Oct 3-','Oct 10-','Oct 17-','Oct 24-','Oct 31-','Nov 7-','Nov 14-','Nov 21-','Nov 28-','Dec 5-','Dec 12-','Dec 19-','Dec 26-');
   @whatweek=('','Dec 31-','Jan 02-','Jan 09-','Jan 16-','Jan 23-','Jan 30-','Feb 06-','Feb 13-','Feb 20-','Feb 27-','Mar 6-','Mar 13-','Mar 20-','Mar 27-','Apr 3-','Apr 10-','Apr 17-','Apr 24-','May 1-','May 8-','May 15-','May 22-','May 29-','Jun 5-','Jun 12-','Jun 19-','Jun 26-','Jul 3-','Jul 10-','Jul 17-','Jul 24-','Jul 31-','Aug 7-','Aug 14-','Aug 21-','Aug 28-','Sep 4-','Sep 11-','Sep 18-','Sep 25-','Oct 2-','Oct 9-','Oct 16-','Oct 23-','Oct 30-','Nov 6-','Nov 13-','Nov 20-','Nov 27-','Dec 4-','Dec 11-','Dec 18-','Dec 25-');

    $maxruns=0;
    foreach $week (1..$thisweek) {
      foreach $prog ('wr','wrb','wd','we','wf','wa','wt') {
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
      foreach $prog ('wr','wrb','wd','we','wf','wa','wt') {
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

<font face="tahoma" size=-1>
<table>
 <tr>
  <th colspan=2>2010</th>
 </tr>
 <tr><th align=right>Model<br>runs</th><th>Model</th><th align=right>WEPP<br>runs</th></tr>
 <tr><td align=right>8,938</td><th>WEPP:Road</th><td align=right>8,938</td></tr>
 <tr><td align=right>1,323</td><th>WEPP:Road Batch</th><td align=right>20,636</td></tr>
 <tr><td align=right>11,082</td><th>Disturbed WEPP</th><td align=right>11,082</td></tr>
 <tr><td align=right>1,830</td><th>ERMiT</th><td align=right>~54,900</td></tr>
 <tr><td align=right>563</td><th>WEPP FuME</th><td align=right>6,756</td></tr>
 <tr><td align=right>159</td><th>WASP</th><td align=right>159</td></tr>
 <tr><td align=right>1,119</td><th>Tahoe Basin</th><td align=right>1,119</td></tr>
 <tr><td align=right></td><th></th><td align=right><b>~103,590</b></td></tr>
</table> 
<br><br><a href="/fswepp/fswepprunsyearly.html">Model runs for prior years</a>

<!--
<br><br><a href="/cgi-bin/fswepp/2008weppruns.pl">2008 model runs</a>
<br><br><a href="weppruns2007s.pl">2007 model runs</a>
<br><br><a href="/fswepp/runs/2006weppruns.html">2006 usage</a>
-->

  </font>
 </body>
</html>
';
sub commify {
    my $text = reverse $_[0];
    $text =~ s/(\d\d\d)(?=\d)(?!d*\.)/$1,/g;
    return scalar reverse $text;
}

sub resolve_dq {

#
#  call 'dig' to determine domain for dotted quad
#

  my $answer, $dottedquad, $arg, @parts, @result;

#   &ReadParse(*parameters);
#   $dottedquad=$parameters{'dottedquad'};

    $dottedquad = $_[0];

#    $answer = $dottedquad;

#     print "
#0: $_[0]
#1: $_[1]
#";

   $answer="unknown: $dottedquad";

#     $dottedquad = '134.121.1.72';
#     $dottedquad = '166.2.22.128';

#
#    regexp check
#
       if ($dottedquad =~ m/(\d{1,3}\.){3}(\d{1,3})/) {
         $arg = 'dig -x ' . $dottedquad;
         @result = `$arg`;
         for ( my $i=0; $i < scalar(@result); $i++) {
           if (@result[$i] =~ 'ANSWER SECTION') {
             $answer = @result[$i+1];           # get NEXT line following 'ANSWER'
             @parts=split(' ',$answer);
             $answer=@parts[4];
           }
         }
       }
       else {
         $answer = "Improper format: $dottedquad<br>example: 166.2.22.128";
       }

# print "dq: $answer\n";

    return $answer;

#     print @result;

}
