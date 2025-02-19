#!/usr/bin/perl

#  scan Fuels Synthesis run logs to report number of entries, and age of last entry
#  allow click to individual model run log report
#  2004.10.19 DEH  loopify; report days, hours, minutes as appropriate 2004.10.20 DEH

   @logfile=('../fswepp/working/wf.log', 'working/whrm.log', 'working/urm.log');
   @link=('', 'whrmtail.pl', 'urmtail.pl');
   @prog=('WEPP FuME', 'Wildlife Habitat Response Model', 'Understory Response Model');
   @image=('/fswepp/images/fume.jpg','/fuels/images/borealowl_small.jpg','/fuels/images/muskthistle_small.jpg');

    $now = localtime;

   print "Content-type: text/html\n\n";
   print "<html>
 <head>
  <title>Fuel Synthesis run logs</title>
 </head>
 <body>
  <font face='tahoma, arial, sans serif'>
   <h3>Fuel Synthesis runs since January 1, 2006<br>$now</h3>
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
      print '   <a href="',@link[$i],'" target="_n"><img src="',@image[$i],'"></a> ', $numruns, ' <b>',@prog[$i], '</b> runs; most recent ', $long_ago, $time, ' ago<br>',"\n";
    }
  }
  print '<br><br><br>
  <h3>2005 Runs</h3>
  WEPP FuME: 1,396<br>
  WHRM: 525<br>
  URM: 347<br>
  ART: 500
  </font>
 </body>
</html>
';
sub commify {
    my $text = reverse $_[0];
    $text =~ s/(\d\d\d)(?=\d)(?!d*\.)/$1,/g;
    return scalar reverse $text;
}
