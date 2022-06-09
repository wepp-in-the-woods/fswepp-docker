#! /usr/bin/perl

   $lines=200;

   &ReadParse(*parameters);
   $year = $parameters{'year'};
   $year = int ($year+0);
   $year = 2014 if ($year == 0);

   @results=`tail -$lines working/_$year/wf.log`;
   @results=reverse(@results);
   $wc  = `wc working/_$year/wf.log`;
   @words = split " ", $wc;
   $runs = @words[0];

   $lines=$runs if ($runs<$lines);

print "Content-type: text/html\n\n";
print "<HTML>
 <HEAD>
  <TITLE>WEPP FuME run log</TITLE>
 </head>
 <body onLoad='self.focus()'>
  <font face='tahoma, arial, sans serif'>
   <h3>$lines most recent of $runs WEPP FuME runs in $year</h3>
   <pre>
@results
   </pre>
  </font>
 </body>
</html>
";
# ------------------------ subroutines ---------------------------

sub ReadParse {

# ReadParse -- from cgi-lib.pl (Steve Brenner) from Eric Herrmann's
# "Teach Yourself CGI Programming With PERL in a Week" p. 131

  local (*in) = @_ if @_;
  local ($i, $loc, $key, $val);

  if ($ENV{'REQUEST_METHOD'} eq "GET") {
    $in = $ENV{'QUERY_STRING'};
  } elsif ($ENV{'REQUEST_METHOD'} eq "POST") {
    read(STDIN,$in,$ENV{'CONTENT_LENGTH'});
  }
  @in = split(/&/,$in);
  foreach $i (0 .. $#in) {
    $in[$i] =~ s/\+/ /g;                        # Convert pluses to spaces
    ($key, $val) = split(/=/,$in[$i],2);        # Split into key and value
    $key =~ s/%(..)/pack("c",hex($1))/ge;       # Convert %XX from hex numbers to alphanumeric
    $val =~ s/%(..)/pack("c",hex($1))/ge;
    $in{$key} .= "\0" if (defined($in{$key}));  # \0 is the multiple separator
    $in{$key} .= $val;
  }
  return 1;
}

