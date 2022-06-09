#! /usr/bin/perl

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
   $ermit_factor=1;
   $chart=1;
   $graphwidth=600;
   @bgcol[0]='ivory';
   @bgcol[1]='lightgoldenrodyellow';
   $flipper = 0;

#################################################
#
#            CALENDAR STUFF
#
#   $thisday -- day of the year (1..365) $thisyear -- current year (ie, 2012) $dayoffset -- account for which day of 
#   the week Jan 1 is: -1: Su; 0: Mo; 1: Tu; 2: We; 3: Th; 4: Fr; 5: Sa.

   $thisday = 1 + (localtime)[7];	# $yday, day of the year (0..364)
   $thisyear = 1900 + (localtime)[5];	# http://perldoc.perl.org/functions/localtime.html
#  $year = $thisyear;

#  look for year specified on command line:  weppruns.pl?year=2011
#
   &ReadParse(*parameters);
   $year = $parameters{'year'};
   $year = $thisyear if $year == '';
#
#####
#  use $thisyear if year not specified on command line
#  report whole year if $year<$thisyear
#  report YTD if current year 
#  no runs if $year>$thisyear
#
#  New year: change $thisdayoff factor (why) and @whatweek ***
#
   if    ($year == 2007) { $dayoffset = 1;  # Jan 1 is Monday
                           @whatweek=('','Dec 31-','Jan 7-','Jan 14-','Jan 21-','Jan 28-','Feb 4-','Feb 11-','Feb 18-','Feb 25-','Mar 4-','Mar 11-','Mar 18-','Mar 25-','Apr 1-','Apr 8-','Apr 15-','Apr 22-','Apr 29-','May 6-','May 13-','May 20-','May 27-','Jun 3-','Jun 10-','Jun 17-','Jun 24-','Jul 1-','Jul 8-','Jul 15-','Jul 22-','Jul 29-','Aug 5-','Aug 12-','Aug 21-','Aug 26-','Sep 2-','Sep 9-','Sep 16-','Sep 23-','Sep 30-','Oct 7-','Oct 14-','Oct 21-','Oct 28-','Nov 4-','Nov 11-','Nov 18-','Nov 25-','Dec 2-','Dec 9-','Dec 16-','Dec 23-','Dec 30-') }
   elsif ($year == 2008) { $dayoffset = 2;  # Jan 1 is Tuesday
                           @whatweek=('','Dec 30-','Jan 6-','Jan 13-','Jan 20-','Jan 27-','Feb 3-','Feb 10-','Feb 17-','Feb 24-','Mar 2-','Mar 9-','Mar 16-','Mar 23-','Mar 30-','Apr 6-','Apr 13-','Apr 20-','Apr 27-','May 4-','May 11-','May 18-','May 25-','Jun 1-','Jun 8-','Jun 15-','Jun 22-','Jun 29-','Jul 6-','Jul 13-','Jul 20-','Jul 27-','Aug 3-','Aug 10-','Aug 17-','Aug 24-','Aug 31-','Sep 7-','Sep 14-','Sep 21-','Oct 5-','Oct 12-','Oct 19-','Oct 26-','Nov 2-','Nov 9-','Nov 16-','Nov 23-','Nov 30-','Dec 7-','Dec 14-','Dec 21-','Dec 28-')  }
   elsif ($year == 2009) { $dayoffset = 3;  # Jan 1 is Thursday
                           @whatweek=('','Jan 1-','Jan 4-','Jan 11-','Jan 18-','Jan 25-','Feb 1-','Feb 08-','Feb 15-','Feb 22-','Mar 1-','Mar 8-','Mar 15-','Mar 22-','Mar 29-','Apr 5-','Apr 12-','Apr 19-','Apr 26-','May 3-','May 10-','May 17-','May 24-','May 31-','Jun 7-','Jun 14-','Jun 21-','Jun 28-','Jul 5-','Jul 12-','Jul 19-','Jul 26-','Aug 2-','Aug 9-','Aug 16-','Aug 23-','Aug 30-','Sep 6-','Sep 13-','Sep 20-','Sep 27-','Oct 4-','Oct 11-','Oct 18-','Oct 25-','Nov 1-','Nov 8-','Nov 15-','Nov 22-','Nov 29-','Dec 6-','Dec 13-','Dec 20-','Dec 27-'); }
   elsif ($year == 2010) { $dayoffset = 4;  # Jan 1 is Friday
                           @whatweek=('','Jan 1-','Jan 3-','Jan 10-','Jan 17-','Jan 24-','Jan 31-','Feb 07-','Feb 14-','Feb 21-','Feb 28-','Mar 7-','Mar 14-','Mar 21-','Mar 28-','Apr 4-','Apr 11-','Apr 18-','Apr 25-','May 2-','May 9-','May 16-','May 23-','May 30-','Jun 6-','Jun 13-','Jun 20-','Jun 27-','Jul 4-','Jul 11-','Jul 18-','Jul 25-','Aug 1-','Aug 8-','Aug 15-','Aug 22-','Aug 29-','Sep 5-','Sep 12-','Sep 19-','Sep 26-','Oct 3-','Oct 10-','Oct 17-','Oct 24-','Oct 31-','Nov 7-','Nov 14-','Nov 21-','Nov 28-','Dec 5-','Dec 12-','Dec 19-','Dec 26-');  }
   elsif ($year == 2011) { $dayoffset = 5;  # Jan 1 is Saturday
                           @whatweek=('','Jan 2-','Jan 9-','Jan 16-','Jan 23-','Jan 30-','Feb 6-','Feb 13-','Feb 20-','Feb 27-','Mar 5-','Mar 12-','Mar 19-','Mar 26-','Apr 2-','Apr 9-','Apr 16-','Apr 23-','Apr 30-','May 7-','May 14-','May 21-','May 28-','Jun 4-','Jun 11-','Jun 18-','Jun 25-','Jul 2-','Jul 9-','Jul 16-','Jul 23-','Jul 30-','Aug 6-','Aug 13-','Aug 20-','Aug 27-','Sep 3-','Sep 10-','Sep 17-','Sep 24-','Oct 8-','Oct 15-','Oct 22-','Oct 29-','Nov 5-','Nov 12-','Nov 19-','Nov 26-','Dec 3-','Dec 10-','Dec 17-','Dec 24-','Dec 31-')  }
   elsif ($year == 2012) { $dayoffset =-1;  # Jan 1 is Sunday
                           @whatweek=('','Dec 30-','Jan 1-','Jan 8-','Jan 15-','Jan 22-','Jan 29-','Feb 5-','Feb 12-','Feb 19-','Feb 26-','Mar 4-','Mar 11-','Mar 18-','Mar 25-','Apr 1-','Apr 8-','Apr 15-','Apr 22-','Apr 29-','May 6-','May 13-','May 20-','May 27-','Jun 3-','Jun 10-','Jun 17-','Jun 24-','Jul 1-','Jul 8-','Jul 15-','Jul 22-','Jul 29-','Aug 5-','Aug 12-','Aug 19-','Aug 26-','Sep 2-','Sep 9-','Sep 16-','Sep 23-','Oct 7-','Oct 14-','Oct 21-','Oct 28-','Nov 4-','Nov 11-','Nov 18-','Nov 25-','Dec 2-','Dec 9-','Dec 16-','Dec 23-','Dec 30-')  }
   elsif ($year == 2013) { $dayoffset = 1;  # Jan 1 is Tuesday
                           @whatweek=('','Dec 30-','Jan 6-','Jan 13-','Jan 20-','Jan 27-','Feb 3-','Feb 10-','Feb 17-','Feb 24-','Mar 3-','Mar 10-','Mar 17-','Mar 24-','Mar 31-','Apr 7-','Apr 14-','Apr 21-','Apr 28-','May 5-','May 12-','May 19-','May 26-','Jun 2-','Jun 9-','Jun 16-','Jun 23-','Jun 30-','Jul 7-','Jul 14-','Jul 21-','Jul 28-','Aug 4-','Aug 11-','Aug 18-','Aug 25-','Sep 1-','Sep 8-','Sep 15-','Sep 22-','Sep 29-','Oct 6-','Oct 13-','Oct 20-','Oct 27-','Nov 3-','Nov 10-','Nov 17-','Nov 24-','Dec 1-','Dec 8-','Dec 15-','Dec 22-','Dec 29-')  }
   elsif ($year == 2014) { $dayoffset = 2;  # Jan 1 is Wednesday
                           @whatweek=('','Jan 1-','Jan 5-','Jan 12-','Jan 19-','Jan 26-','Feb 2-','Feb 09-','Feb 16-','Feb 23-','Mar 2-','Mar 09-','Mar 16-','Mar 23-','Mar 30-','Apr 6-','Apr 13-','Apr 20-','Apr 27-','May 4-','May 11-','May 18-','May 25-','Jun 01-','Jun 08-','Jun 15-','Jun 22-','Jun 29-','Jul 6-','Jul 13-','Jul 20-','Jul 27-','Aug 03-','Aug 10-','Aug 17-','Aug 24-','Aug 31-','Sep 7-','Sep 14-','Sep 21-','Sep 28-','Oct 5-','Oct 12-','Oct 19-','Oct 26-','Nov 02-','Nov 09-','Nov 16-','Nov 23-','Nov 30-','Dec 07-','Dec 14-','Dec 21-','Dec 28-')  }
   elsif ($year == 2015) { $dayoffset = 3;  # Jan 1 is Thursday
                           @whatweek=('','Jan 1-','Jan 4-','Jan 11-','Jan 18-','Jan 25-','Feb 1-','Feb 08-','Feb 15-','Feb 22-','Mar 1-','Mar 8-','Mar 15-','Mar 22-','Mar 29-','Apr 5-','Apr 12-','Apr 19-','Apr 26-','May 3-','May 10-','May 17-','May 24-','May 31-','Jun 7-','Jun 14-','Jun 21-','Jun 28-','Jul 5-','Jul 12-','Jul 19-','Jul 26-','Aug 2-','Aug 9-','Aug 16-','Aug 23-','Aug 30-','Sep 6-','Sep 13-','Sep 20-','Sep 27-','Oct 4-','Oct 11-','Oct 18-','Oct 25-','Nov 1-','Nov 8-','Nov 15-','Nov 22-','Nov 29-','Dec 6-','Dec 13-','Dec 20-','Dec 27-');  }
   elsif ($year == 2016) { $dayoffset = 4;  # Jan 1 is Friday
                           @whatweek=('','Jan 1-','Jan 3-','Jan 10-','Jan 17-','Jan 24-','Jan 31-','Feb 07-','Feb 14-','Feb 21-','Feb 28-','Mar 7-','Mar 14-','Mar 21-','Mar 28-','Apr 4-','Apr 11-','Apr 18-','Apr 25-','May 2-','May 9-','May 16-','May 23-','May 30-','Jun 6-','Jun 13-','Jun 20-','Jun 27-','Jul 4-','Jul 11-','Jul 18-','Jul 25-','Aug 1-','Aug 8-','Aug 15-','Aug 22-','Aug 29-','Sep 5-','Sep 12-','Sep 19-','Sep 26-','Oct 3-','Oct 10-','Oct 17-','Oct 24-','Oct 31-','Nov 7-','Nov 14-','Nov 21-','Nov 28-','Dec 5-','Dec 12-','Dec 19-','Dec 26-');  }
   elsif ($year == 2017) { $dayoffset =-1;  # Jan 1 is Sunday
                           @whatweek=('','Jan 1-','Jan 8-','Jan 15-','Jan 22-','Jan 29-','Feb 5-','Feb 12-','Feb 19-','Feb 26-','Mar 4-','Mar 11-','Mar 18-','Mar 25-','Apr 1-','Apr 8-','Apr 15-','Apr 22-','Apr 29-','May 6-','May 13-','May 20-','May 27-','Jun 3-','Jun 10-','Jun 17-','Jun 24-','Jul 1-','Jul 8-','Jul 15-','Jul 22-','Jul 29-','Aug 5-','Aug 12-','Aug 19-','Aug 26-','Sep 2-','Sep 9-','Sep 16-','Sep 23-','Oct 7-','Oct 14-','Oct 21-','Oct 28-','Nov 4-','Nov 11-','Nov 18-','Nov 25-','Dec 2-','Dec 9-','Dec 16-','Dec 23-','Dec 30-')  }
   elsif ($year == 2018) { $dayoffset = 0;  # Jan 1 is Monday
                           @whatweek=('','Dec 31-','Jan 7-','Jan 14-','Jan 21-','Jan 28-','Feb 4-','Feb 11-','Feb 18-','Feb 25-','Mar 4-','Mar 11-','Mar 18-','Mar 25-','Apr 1-','Apr 8-','Apr 15-','Apr 22-','Apr 29-','May 6-','May 13-','May 20-','May 27-','Jun 3-','Jun 10-','Jun 17-','Jun 24-','Jul 1-','Jul 8-','Jul 15-','Jul 22-','Jul 29-','Aug 5-','Aug 12-','Aug 21-','Aug 26-','Sep 2-','Sep 9-','Sep 16-','Sep 23-','Sep 30-','Oct 7-','Oct 14-','Oct 21-','Oct 28-','Nov 4-','Nov 11-','Nov 18-','Nov 25-','Dec 2-','Dec 9-','Dec 16-','Dec 23-','Dec 30-');  }
   elsif ($year == 2019) { $dayoffset = 1;  # Jan 1 is Tuesday
                           @whatweek=('','Dec 30-','Jan 6-','Jan 13-','Jan 20-','Jan 27-','Feb 3-','Feb 10-','Feb 17-','Feb 24-','Mar 2-','Mar 9-','Mar 16-','Mar 23-','Mar 30-','Apr 6-','Apr 13-','Apr 20-','Apr 27-','May 4-','May 11-','May 18-','May 25-','Jun 1-','Jun 8-','Jun 15-','Jun 22-','Jun 29-','Jul 6-','Jul 13-','Jul 20-','Jul 27-','Aug 3-','Aug 10-','Aug 17-','Aug 24-','Aug 31-','Sep 7-','Sep 14-','Sep 21-','Oct 5-','Oct 12-','Oct 19-','Oct 26-','Nov 2-','Nov 9-','Nov 16-','Nov 23-','Nov 30-','Dec 7-','Dec 14-','Dec 21-','Dec 28-')  }
   elsif ($year == 2020) { $dayoffset = 2;  # Jan 1 is Wednesday
                           @whatweek=('','Jan 1-','Jan 5-','Jan 12-','Jan 19-','Jan 26-','Feb 2-','Feb 09-','Feb 16-','Feb 23-','Mar 1-','Mar 09-','Mar 15-','Mar 22-','Mar 29-','Apr 5-','Apr 12-','Apr 19-','Apr 26-','May 3-','May 10-','May 17-','May 24-','May 31-','Jun 07-','Jun 14-','Jun 21-','Jun 28-','Jul 5-','Jul 12-','Jul 19-','Jul 26-','Aug 02-','Aug 09-','Aug 16-','Aug 23-','Aug 30-','Sep 6-','Sep 13-','Sep 20-','Oct 4-','Oct 11-','Oct 18-','Oct 25-','Nov 01-','Nov 08-','Nov 15-','Nov 22-','Nov 29-','Dec 06-','Dec 13-','Dec 20-','Dec 27-')  }
   else {$year = 2013;     @whatweek=('','Dec 30-','Jan 6-','Jan 13-','Jan 20-','Jan 27-','Feb 3-','Feb 10-','Feb 17-','Feb 24-','Mar 3-','Mar 10-','Mar 17-','Mar 24-','Mar 31-','Apr 7-','Apr 14-','Apr 21-','Apr 28-','May 5-','May 12-','May 19-','May 26-','Jun 2-','Jun 9-','Jun 16-','Jun 23-','Jun 30-','Jul 7-','Jul 14-','Jul 21-','Jul 28-','Aug 4-','Aug 11-','Aug 18-','Aug 25-','Sep 1-','Sep 8-','Sep 15-','Sep 22-','Oct 6-','Oct 13-','Oct 20-','Oct 27-','Nov 3-','Nov 10-','Nov 17-','Nov 24-','Dec 1-','Dec 8-','Dec 15-','Dec 22-','Dec 29-')  }

   $thisdayoff=$thisday+$dayoffset;
   $thisweek = 1+ int $thisdayoff/7;
# 
######################################################################

   @base = ('wr', 'wrb', 'wd2', 'wd', 'dwb', 'we', 'web', 'wf', 'wa', 'wt');
   @link    = map {$_ . "tailer.pl?year=$year"} @base;
   @logfile = map {"working/_$year/" . $_ . '.log'} @base;
   @colors  = map {'/fswepp/images/' . $_ . '_color.gif'} @base;
   @prog=('WEPP:Road','WEPP:Road Batch','Dist WEPP 2.0','Dist WEPP 1.0','Disturbed WEPP Batch','ERMiT','bERMiT','WEPP FuME','WASP','Tahoe Basin');
   @image=('/fswepp/images/road4.gif','/fswepp/images/roadb_r.gif','/fswepp/images/disturb.gif','/fswepp/images/disturb.gif','/fswepp/images/dWb.gif','/fswepp/images/ermit.gif','/fswepp/images/bERMiT.gif','/fswepp/images/fume.jpg','/fswepp/images/wasp_logo.png','/fswepp/images/tahoelogo.jpg');

   $now = localtime;
 # print "  <br><font size=-1>$now</font>";

   print "Content-type: text/html\n\n";
   print "<html>
 <head>
  <title>FS WEPP run logs</title>
 </head>
 <body>
  <font face='tahoma, arial, sans serif'>
   <h4>FS WEPP model runs March 7 $year -- $now</h4>
";

#  print "166.2.22.221: "; $domain = &resolve_dq ('166.2.22.221'); print "result: $domain"; die;

print "
   <table border=0>
 ";
  foreach $i (0..$#logfile) {
    if (-e @logfile[$i]) {
      $days_old = -M @logfile[$i];
      $long_ago = sprintf '%.2f', $days_old;
      $time=' days';
      if ($long_ago < 1) {
        $long_ago = sprintf '%.2f', $days_old*24;
        $time=' hours'
      }
      if ($long_ago < 1) {
        $long_ago = sprintf '%.2f', $days_old*24*60; 
        $time=' minutes'
      }
      $wc = `wc @logfile[$i]`;
      @words = split " ", $wc;
      $numruns = commify (@words[0]);
###
##  patch for incomplete recording of WEPP:Road runs through WWPP:Road Batch (dit log seems correct, wr.log missing batch segments record)

      if (@logfile[$i] eq 'working/_2015/wr.log') {
         $dits = 0;
         foreach $i (0..53) {
            $dits += -s "working/_2015/wr/$i"
         }
      }
      if (@logfile[$i] eq 'working/_2014/wr.log') {
         $dits = 0;
         foreach $i (0..53) {
            $dits += -s "working/_2014/wr/$i"
         }
      }
      $dits = commify ($dits);
###
      $tailer=`tail -1 @logfile[$i]`;
      ($ip,$rest) = split ' ',$tailer,2;
      chomp $tailer;
      $resolved=&resolve_dq($ip);
      print "   <tr>
     <td><a href='@link[$i]' target='_n'><img src='@image[$i]'></a></td>
";
###
if (@logfile[$i] eq 'working/_2014/wr.log' || @logfile[$i] eq 'working/_2015/wr.log') {
     print "      <td align='right'>$numruns<br><img src='@colors[$i]' width=50 height=5><br><font size=1>&nbsp;$dits</font></td>";
} else {
     print "      <td align='right'>$numruns<br><img src='@colors[$i]' width=50 height=5><br><font size=1>&nbsp;</font></td>";
}
###
     print "
     <td><b>@prog[$i]</b> runs; most recent<br><img src='@colors[$i]' width=100% height=5><br><font size=1>$tailer</font></td>
     <td>$long_ago $time ago<br> <img src='@colors[$i]' width=100% height=5><br> <font size=1>$resolved</font></td>
    </tr>
 ";
#     print "  <img src='@colors[$i]' width=250 height=5><br>\n";
    }
  }
 print "  </table>
";

#### ======================================= ####

  if ($chart) {

    $endweek=52        if ($year<$thisyear);	# report whole year for past years
    $endweek=$thisweek if ($year==$thisyear);	# report YTD for current year
    $endweek=0         if ($year>$thisyear);	# no runs for future

    $maxruns=0; 
#   foreach $week (1..$thisweek) { 
    foreach $week (1..$endweek) {
#     foreach $prog ('wr','wrb','wd','we','wf','wa','wt') {
      foreach $prog ('wr','wrb','wd2','wd','we','wf','wa','wt') { # 2013.01.07 DEH 
#       $file = 'working/' . $prog . '/' . $week;
        $file = "working/_$year/$prog/$week";
        if (-e $file) {$runs = -s $file;}
        else { $runs = 0 }
        $maxruns = $runs if ($runs > $maxruns);
        @{$prog}[$week] = $runs;
      }         # foreach $prog ()
    }   # foreach $week ()

    $scale = 1;
    $scale = $graphwidth / $maxruns if ($maxruns > $graphwidth);

# print "scale: $scale\n";

    $framewidth=$graphwidth+30;
    print "
   <br>
   <font size=-2>Following updated every 10 minutes</font>
   <br>
   <iframe src='/cgi-bin/fswepp/lastclim.pl' frameborder=0 width=$framewidth height=38></iframe>
";
    print "
   <br>
   <font size=-1>
    [<a href=\"javascript:var navWin = window.open('/cgi-bin/engr/resolve_dq.pl','NewWin','scrollbars,toolbar=false,menubar=false,resizable=true,width=400,height=300')\">try to convert dotted quad to name</a>]
    &nbsp;&nbsp;
    [<a href=\"javascript:var navWin2 = window.open('/cgi-bin/fswepp/climinute.pl','NewWin2','scrollbars,toolbar=false,menubar=false,resizable=true,width=360,height=100')\">1-minute run check</a>]
   </font>
";
    print '
   <h5> Number of model runs per week </h5>
   <table bgcolor="black" cellpadding=3>
';
#    print ' <h5> Number of runs per week by model<br> ( <img src="/fswepp/images/wr_color.gif" width=25 height=5> 
#    WEPP:Road <img src="/fswepp/images/wrb_color.gif" width=25 height=5> WEPP:Road batch (segments) <img 
#    src="/fswepp/images/wd_color.gif" width=25 height=5> Disturbed WEPP <img src="/fswepp/images/we_color.gif" 
#    width=25 height=5> ERMiT <img src="/fswepp/images/wf_color.gif" width=25 height=5> WEPP Fume )
#   </h5> <table bgcolor="black" cellpadding=3> ';

# @weeks = (1..$thisweek);
    @weeks = (1..$endweek);
    @revweeks = reverse @weeks;
 $totalruns = 0;	# 2017 DEH
    foreach $week (@revweeks) {
      $flipper = !$flipper;
      print "    <tr>
     <td bgcolor='@bgcol[$flipper]'>@whatweek[$week]</td>
     <td bgcolor='@bgcol[$flipper]' width='$graphwidth'>
";
      $sumruns=0; 
#     foreach $prog ('wr','wrb','wd','we','wf','wa','wt') { 
      foreach $prog ('wr','wrb','wd2','wd','we','wf','wa','wt') { 	# 2013.01.07 DEH
#       $file = 'working/' . $prog . '/' . $week;
        $file = "working/_$year/$prog/$week";
        $color = '/fswepp/images/' . $prog . '_color.gif';
        $runs=@{$prog}[$week]; 
        $sumruns += $runs;
        $runscale=int $runs * $scale;
        $runscale=1 if ($runscale==0);
        if ($runscale>0) {
          print "      <img src='$color' width='$runscale' height='5' title='$prog: $runs runs'><br>\n"
        };
      }         # foreach $prog ()
  $totalruns += $sumruns;	# 2017 DEH
      $sumruns = commify ($sumruns);
      print "     </td>
     <td bgcolor='@bgcol[$flipper]' align='right'>$sumruns</td>
    </tr>
";
    }   # foreach $week ()
  }     # if ($chart)

  print '   </table>';			# 2017 DEH

 $totalruns = commify ($totalruns);	# 2017 DEH
 print "\n<br> $totalruns total model runs\n";	# 2017 DEH
  print '
   <h5>1 WEPP run per road segment for WEPP:Road batch<br>
       12 WEPP runs per WEPP FuME run<br>
       20, 30, or 40 WEPP runs per ERMiT run
   </h5>
   <br><br>
   <a href="weppruns.pl?year=2018">2018</a>
   <a href="weppruns.pl?year=2017">2017</a>
   <a href="weppruns.pl?year=2016">2016</a>
   <a href="weppruns.pl?year=2015">2015</a>
   <a href="weppruns.pl?year=2014">2014</a>
   <a href="weppruns.pl?year=2013">2013</a>
   <a href="weppruns.pl?year=2012">2012</a>
   <a href="weppruns.pl?year=2011">2011</a>
   <a href="weppruns.pl?year=2010">2010</a>
   <a href="weppruns.pl?year=2009">2009</a>
   <a href="weppruns.pl?year=2008">2008</a>
   <a href="weppruns.pl?year=2007">2007</a>
   <br><br>
   <br><br>
   <a href="/fswepp/weppmodelruns.html">Model runs for prior years</a>
<!-- 
 <br><br><a href="/cgi-bin/fswepp/2008weppruns.pl">2008 model runs</a>
 <br><br><a href="weppruns2007s.pl">2007 model runs</a>
 <br><br><a href="/fswepp/runs/2006weppruns.html">2006 usage</a>
-->
  </font>
 </body>
</html>
';

# ------------------------ subroutines ---------------------------

sub commify {
  my $text = reverse $_[0]; $text =~ s/(\d\d\d)(?=\d)(?!d*\.)/$1,/g; return scalar reverse $text;
}

sub resolve_dq {

#
#  call 'dig' to determine domain for dotted quad
#

  my $answer, $dottedquad, $arg, @parts, @result;

# &ReadParse(*parameters); $dottedquad=$parameters{'dottedquad'};

  $dottedquad = $_[0];

# $answer = $dottedquad;
#     print " 0: $_[0] 1: $_[1] ";

   $answer="unknown: $dottedquad";

#     $dottedquad = '134.121.1.72'; $dottedquad = '166.2.22.128';
#
#    regexp check
#
       if ($dottedquad =~ m/(\d{1,3}\.){3}(\d{1,3})/) {
         $arg = 'dig -x ' . $dottedquad;
         @result = `$arg`;
         for ( my $i=0; $i < scalar(@result); $i++) {
           if (@result[$i] =~ 'ANSWER SECTION') {
             $answer = @result[$i+1];  # get NEXT line following 'ANSWER'
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

# print @result;

}

sub ReadParse {

# ReadParse -- from cgi-lib.pl (Steve Brenner) from 
# Eric Herrmann's "Teach Yourself CGI Programming With PERL in a Week" p. 131

  local (*in) = @_ if @_;
  local ($i, $loc, $key, $val);

  if ($ENV{'REQUEST_METHOD'} eq "GET") {
    $in = $ENV{'QUERY_STRING'};
  }
  elsif ($ENV{'REQUEST_METHOD'} eq "POST") {
    read(STDIN,$in,$ENV{'CONTENT_LENGTH'});
  }
  @in = split(/&/,$in);
  foreach $i (0 .. $#in) {
    $in[$i] =~ s/\+/ /g;  # Convert pluses to spaces
    ($key, $val) = split(/=/,$in[$i],2);	# Split into key and value 
    $key =~ s/%(..)/pack("c",hex($1))/ge;	# Convert %XX from hex numbers to alphanumeric
    $val =~ s/%(..)/pack("c",hex($1))/ge;
    $in{$key} .= "\0" if (defined($in{$key}));	# \0 is the multiple separator
    $in{$key} .= $val;
  }
  return 1;
}

