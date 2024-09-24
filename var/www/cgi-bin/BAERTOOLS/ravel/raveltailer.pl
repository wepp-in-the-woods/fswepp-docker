#! /usr/bin/perl

$lines = 200;

@results = `tail -$lines working/ravel.log`;
@results = reverse(@results);
$wc      = `wc working/ravel.log`;
@words   = split " ", $wc;
$runs    = @words[0];

$lines = $runs if ( $runs < $lines );

print "Content-type: text/html\n\n";
print "<HTML>
 <HEAD>
  <TITLE>RavelRAT-CA run log</TITLE>
 </head>
 <body onLoad='self.focus()'>
  <font face='tahoma, arial, sans serif'>
   <h3>$lines most recent of $runs RavelRAT-CA runs</h3>
   <pre>
    User\t\"Time&ndash;Date\"\tlat\tlong\tlat\tlong\t\seconds\t\"Description\"<br><br>
 @results
   </pre>
  </font>
 </body>
</html>
";

