#! /usr/bin/perl

# whrmtail.pl ## report last *lines* lines of WHRM run log

   $lines=$ARGV[0];

   if ($lines eq '') {
     &ReadParse(*parameters);
     $lines = $parameters{'lines'}
   }

   $lines = int ($lines+0);
   $lines = 25 if ($lines == 0);
   $maxlines = 150;
   $lines = $maxlines if ($lines > $maxlines);
   $lines = 1 if ($lines < 1);

   $results=`tail -$lines working/whrm.log`;
   $wc  = `wc working/whrm.log`;
   @words = split " ", $wc;
   $runs = @words[0];

print "Content-type: text/html\n\n";
print "<HTML>
 <HEAD>
  <TITLE>WHRM run log</TITLE>
 </head>
 <body onload='self.focus()'>
  <font face='tahoma, arial, sans serif'>
   <h2>$lines most recent of $runs WHRM runs</h2>
   <pre>
$results
   </pre>
  </font>
 </body>
</html>
";

# ************************                                             

sub ReadParse {

# ReadParse -- from cgi-lib.pl (Steve Brenner) from Eric Herrmann's
# "Teach Yourself CGI Programming With PERL in a Week" p. 131

# Reads GET or POST data, converts it to unescaped text, and puts
# one key=value in each member of the list "@in"
# Also creates key/value pairs in %in, using '\0' to separate multiple
# selections

# If a variable-glob parameter...

  local (*in) = @_ if @_;
  local ($i, $loc, $key, $val);

  if ($ENV{'REQUEST_METHOD'} eq "GET") {
    $in = $ENV{'QUERY_STRING'};
  } elsif ($ENV{'REQUEST_METHOD'} eq "POST") {
    read(STDIN,$in,$ENV{'CONTENT_LENGTH'});
  }

  @in = split(/&/,$in);

  foreach $i (0 .. $#in) {
    # Convert pluses to spaces
    $in[$i] =~ s/\+/ /g;

    # Split into key and value
    ($key, $val) = split(/=/,$in[$i],2);  # splits on the first =

    # Convert %XX from hex numbers to alphanumeric
    $key =~ s/%(..)/pack("c",hex($1))/ge;
    $val =~ s/%(..)/pack("c",hex($1))/ge;

    # Associative key and value
    $in{$key} .= "\0" if (defined($in{$key}));  # \0 is the multiple separator
    $in{$key} .= $val;
  }
  return 1;
 }
