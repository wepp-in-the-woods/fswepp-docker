#!/usr/bin/perl

   $lines=50;

   @results=`tail -$lines working/NANlog.log`;
   @results=reverse(@results);
   $wc  = `wc working/NANlog.log`;
   @words = split " ", $wc;
   $runs = @words[0];

   $lines=$runs if ($runs<$lines);

   $f = 'working/NANlog.log';
   if (-e $f) {
     $daysold = int((-M $f)+0.5);
   }

print "Content-type: text/html\n\n";
print "<html>
 <head>
  <title>FS WEPP NaN run log</title>
 </head>
 <body onLoad='self.focus()'>
  <font face='tahoma, arial, sans serif'>
   <h3>$lines most recent of $runs FS WEPP NaN exceptions</h3>
   <h4>Latest $daysold day(s) ago</h4>
   Most recent on top
   <pre>
@results
   </pre>
  </font>
 </body>
</html>
";

