#! /usr/bin/perl 

  $in = $ENV{'QUERY_STRING'};
  ($dummy,$unique) = split '=',$in;
  $file = "../working/$unique.png";

#  print "Content-type: text/html\n\n";
#  print "<html><body>$file</body></html";

  print "Content-type: image/png\n\n";

  open PNG, "<$file";
  binmode PNG;
  print <PNG>;
  close PNG;
