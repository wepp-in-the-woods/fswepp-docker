#! /usr/bin/perl

# counter.pl?chapter=5

# read chapter parameter from command line
# return file size of working/$chapter file, which is intended to be a record of file downloads

  $numhits='';

# read argument (chapter)

  &ReadParse(*parameters);
  $chapter=$parameters{'chapter'};

# clean up argument (limit to '1' to '14')

  $numhits='0';
  $downloads='downloads';
  $chapt=$chapter+0;
  if ($chapt >= 1 && $chapt <= 14) {
    $file = 'working/' . $chapt;
    if (-e $file) {
      $wc = `wc -m $file`;
      @words = split " ", $wc;
      $numhits = commify (@words[0]);
#     $numhits = @words[0];
      $downloads='download' if ($numhits eq '1');
    }
  }

# return HTML page with length of file 'chapter'

     print "Content-type: text/html

<HTML>
 <HEAD>
 </HEAD>
 <BODY leftmargin=0 topmargin=0 marginwidth=0 marginheight=0>
  <font face='tahoma' color='gray' size=-1>
   <div align='right'>
    $numhits $downloads&nbsp;
   </div>
  </font>
 </body>
</html>";

sub commify {
    my $text = reverse $_[0];
    $text =~ s/(\d\d\d)(?=\d)(?!d*\.)/$1,/g;
    return scalar reverse $text;
}

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
    $in[$i] =~ s/\+/ /g;    # Convert pluses to spaces
    ($key, $val) = split(/=/,$in[$i],2);   # Split into key and value
    $key =~ s/%(..)/pack("c",hex($1))/ge;  # Convert %XX from hex numbers to alphanumeric
    $val =~ s/%(..)/pack("c",hex($1))/ge;
    $in{$key} .= "\0" if (defined($in{$key}));  # \0 is the multiple separator
    $in{$key} .= $val;
  }
  return 1;
 }

