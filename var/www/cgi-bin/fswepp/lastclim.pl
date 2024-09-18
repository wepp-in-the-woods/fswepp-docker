#! /usr/bin/perl

# lastclim.pl

# read fswepp/working/lastclimate.txt for

   $now = localtime;
   $thisyear = 1900 + (localtime)[5];           # https://perldoc.perl.org/functions/localtime.html

   $climlog = "working/_$thisyear/lastclimate.txt";
   if (-e $climlog) {
     $days_old = -M $climlog;
     $long_ago = sprintf '%.2f', $days_old; $time=' days';
     if ($long_ago < 1) {$long_ago = sprintf '%.2f', $days_old*24; $time=' hours'}
     if ($long_ago < 1) {$long_ago = sprintf '%.2f', $days_old*24*60; $time=' minutes'}
     open LASTCLIM, '<' . $climlog;
       flock LASTCLIM,2;
       $climate_entry=<LASTCLIM>;
     close LASTCLIM;
   }

   print "Content-type: text/html\n\n";
   print "<html>
 <head>
  <title>Last FS WEPP climate</title>
  <meta http-equiv='Refresh' content='600; URL=/cgi-bin/fswepp/lastclim.pl'>
 </head>
 <body bgcolor='lightblue'>
  <font face='trebuchet, tahoma, arial, sans serif' size=2>
   Last FS WEPP run <font color='crimson'>$long_ago $time</font> ago:
   <font color='crimson'>
    $climate_entry
   </font>
   (as of $now)
  </font>
 </body>
</html>
";

