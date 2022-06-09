#! /usr/bin/perl

#
#  call 'dig' to determine domain for dotted quad
#

# e.g. /cgi-bin/engr/resolve_dq.pl?dottedquad=199.156.164.23
# read parameter into $dottedq

   &ReadParse(*parameters);
   $dottedquad=$parameters{'dottedquad'};
   $answer='unknown';

#     $dottedquad = '134.121.1.72';
#     $dottedquad = '166.2.22.128';

     if ($dottedquad eq '') {
       $dottedquad = '166.2.22.128';
       $answer = 'whitepine.moscow.rmrs.fs.fed.us';
     }
     else {
#
#    regexp check
#
       if ($dottedquad =~ m/(\d{1,3}\.){3}(\d{1,3})/) {
         $arg = 'dig -x ' . $dottedquad;
         @result = `$arg`;
         for ( my $i=0; $i < scalar(@result); $i++) {
           if (@result[$i] =~ 'ANSWER SECTION') {
             $answer = @result[$i+1];		# get NEXT line following 'ANSWER'
             @parts=split(' ',$answer);
             $answer=@parts[4];
           }
         }
       }
       else {
         $answer = "Improper format: $dottedquad<br>example: 166.2.22.128";
       }
     }
#     print @result;
     print "Content-type: text/html\n\n";
     print '<html>
 <head>
  <title>Resolve dotted-quad</title>
 </head>
 <body>
  <font face="trebuchet, tahoma, aria, sans serif">
   <center>
    <h4>Resolve dotted-quad IP address</h4>
    <form name=quad method="get" name="resolve" action="/cgi-bin/engr/resolve_dq.pl">
     <br>
     <input type="text" name="dottedquad" value="';
print $dottedquad;			#	166.2.22.128
print '">
     <input type="submit" value="Resolve"> <br>
      ||<br>
      \/<br>
';
print $answer;			#	whitepine.moscow.rmrs.fs.fed.us
print '<br><br>
    <form>
   </center>
  </font>
 </body>
</html>
';

#     print "$body\n";

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

#---------------------------
