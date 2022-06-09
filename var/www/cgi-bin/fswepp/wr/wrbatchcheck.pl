#! /usr/bin/perl

# wrbatchcheck.pl

# get IP, count from arg line

   &ReadParse(*parameters);

   $ip=$parameters{'ip'};
   $count=$parameters{'count'};

#   if ($ip ne '') {
#     $ipd = $ip;
#     $ipd =~ tr/./_/;
#   }

# validate IP and count

# convert IP to user log
      $ip =~ tr/./_/;
#     $ip = $ip . $me;
      $logFile = "../working/" . $ip . ".wrblog";

# read user WEPP:Road Batch log /fswepp/working/xxx_xx_xxx_xx.wrblog
# wc user log pull out line count do some math display progress

#  $wc  = `wc ../working/wr.log`;
#  @words = split " ", $wc;
#  $runs = @words[0];

  @args = ("wc $logFile");
  $wc  = `@args`;
  @words = split " ", $wc;
  $lines = @words[0];
  $segs = ($lines - 5) / 17;

   print "Content-type: text/html\n\n";
   print "<html>
 <head>
  <title>Last FS WEPP climate</title>
  <meta http-equiv='Refresh' content='6; URL=/cgi-bin/fswepp/wr/wrbatchcheck.pl?ip=$ip&count=$count'>
 </head>
 <body bgcolor='lightblue'>
  <font face='trebuchet, tahoma, arial, sans serif' size=2>
IP: $ip Count: $count Segment: $segs ($wc)
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

