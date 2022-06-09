#! /usr/bin/perl

# lastclim.pl

# read fswepp/working/lastclimate.txt for

   $now = localtime;

   $climlog = 'working/_2013/lastclimate.txt';
   if (-e $climlog) {
     $days_old = -M $climlog;
     $long_ago = sprintf '%.2f', $days_old; $time=' days';
     if ($long_ago < 1) {$long_ago = sprintf '%.2f', $days_old*24; $time=' hours'}
     if ($long_ago < 1) {$long_ago = sprintf '%.2f', $days_old*24*60; $time=' minutes'}
$bgcolor = '#FBB117';
if ($time eq ' minutes' && $long_ago < 1) {$bgcolor='#FAAFBE'};
     open LASTCLIM, '<' . $climlog;
       flock LASTCLIM,2;
       $climate_entry=<LASTCLIM>;
     close LASTCLIM;
   }

   print "Content-type: text/html\n\n";
   print "<html>
 <head>
  <title>Last FS WEPP climate</title>
  <meta http-equiv='Refresh' content='60; URL=/cgi-bin/fswepp/climinute.pl'>
 </head>
 <body>
  <font face='trebuchet, tahoma, arial, sans serif' size=2>
   <table border=1 width = 300 bgcolor='$bgcolor'>
    <tr>
     <td align=center>
      Last FS WEPP run<br>
      <font color='#347235'>$climate_entry</font><br>
      <font color='#347235'>$long_ago $time</font> ago<br>
      as of $now
     </td>
    </tr>
   </table>
  </font>
 </body>
</html>
";

