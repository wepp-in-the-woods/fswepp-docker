#! /usr/bin/perl

# showpubhits.pl?pub=2001a&title=something

#  2009-08-17 DEH use 'dig' to resolve IP address
#		  add hover of log entry over document download number
#  2008-04-17 09:50 showpubhits.pl

# /home/dhall/logs/logs/ac2008Jan13.log:lj512351.crawl.yahoo.net - - [13/Jan/2008:07:22:35 -0800] "GET /engr/library/Hall/Hall2001a/2001a.pdf HTTP/1.0" 200 385850 "-" "Mozilla/5.0 (compatible; Yahoo! Slurp; http://help.yahoo.com/help/us/ysearch/slurp)"
# /home/dhall/logs/logs/ac2008Mar09.log:lj512110.crawl.yahoo.net - - [09/Mar/2008:21:40:10 -0800] "GET /engr/library/Hall/Hall2001a/2001a.pdf HTTP/1.0" 200 385850 "-" "Mozilla/5.0 (compatible; Yahoo! Slurp; http://help.yahoo.com/help/us/ysearch/slurp)"
# /home/dhall/logs/logs/ac2008Mar23.log:lj512110.crawl.yahoo.net - - [24/Mar/2008:01:06:30 -0800] "GET /engr/library/Hall/Hall2001a/2001a.pdf HTTP/1.0" 304 - "-" "Mozilla/5.0 (compatible; Yahoo! Slurp; http://help.yahoo.com/help/us/ysearch/slurp)"
# /home/dhall/logs/logs/ac2008Mar30.log:lj512110.crawl.yahoo.net - - [31/Mar/2008:14:23:26 -0800] "GET /engr/library/Hall/Hall2001a/2001a.pdf HTTP/1.0" 304 - "-" "Mozilla/5.0 (compatible; Yahoo! Slurp; http://help.yahoo.com/help/us/ysearch/slurp)"';

use URI::Escape;

   &ReadParse(*parameters);
   $pub=$parameters{'pub'};
   $title=$parameters{'title'};
   $title=uri_unescape($title);

# verify $pub !!!!!!!!!!! #########
# if ($pub eq '') {$pub='2001a'};

   &hashHTTPDcodes;


#   $pub_code           '2001z'
#   $authors            'Elliot, Robichaud, Hall'
#   $year               '2001'
#   $title              'A probabilistic approach to modeling erosion for spatially-varied conditions'
#   $publisher          'ASAE'
#   $citationt
#   $abstract           'In the years following a major fire disturbance...'
#   $keyword            'Modeling, WEPP, Forest Fire, Erosion, Variability'
#   $authorblock        '<table width=80% align=center border=0>
#                        <tr><td align=center>...'
#   $links              '<a href="http://forest.moscowfsl.wsu.edu/engr/library/Elliot/2001z/">PDF</a> [2 MB]'
#   $plinks             '<a href="http://forest.moscowfsl.wsu.edu/engr/library/Elliot/2001z/">PDF</a> [2 MB]'
#   $treesearch         'pubs/29445'

#   &print_head ($title);

print 'Content-type: text/html

<html>
 <head>
';

if ($title ne '') {print "  <title>Moscow FSL - $title</title>"}
else {print "  <title>Moscow FSL - Engineering Publications search results</title>"}

  print '
 </head> 
 <body bgcolor="#ffffff" onLoad="self.focus()">
  <font face="tahoma, arial, sans serif" size=-1>
   <b>',$title,'</b><br><br>
   Document download report
   <table>
    <tr><th></th><th>Location</th><th>Date</th><th>Code</th><th>Bytes</th></tr>
';

  @goop = `fgrep $pub.pdf ~dhall/logs/logs/ac*.log`;

# print @goop[0];

# following parsing works for more than 1 access file
# dhall@forest:~/logs/logs> fgrep 2008a.pdf ac*.log | fgrep ' 200 '
# [1 ac*.log file]
# 65.55.106.155 - - [24/Jul/2009:14:10:48 -0700] "GET /engr/library/Robichaud/Robichaud2008a/2008a.pdf HTTP/1.1" 200 3671898 "-" "msnbot/2.0b (+http://search.msn.com/msnbot.htm)"
# [>1 ac*.log file]
# ac2009Jul21.log:65.55.106.155 - - [24/Jul/2009:14:10:48 -0700] "GET /engr/library/Robichaud/Robichaud2008a/2008a.pdf HTTP/1.1" 200 3671898 "-" "msnbot/2.0b (+http://search.msn.com/msnbot.htm)"

  for ($i=0; $i<=$#goop; $i++) {

    $j=$i+1;
    $loc_start1 = index(@goop[$i],':',0);
    $loc_end1   = index(@goop[$i],' ',$loc_start1);
    $loc_start2 = index(@goop[$i],'[',$loc_end1);
#   $loc_end2   = index(@goop[$i],':',$loc_start2);
    $loc_end2   = index(@goop[$i],' ',$loc_start2);
    $loc_start1+=1;
    $loc_start2+=1;
    $len_site   = $loc_end1-$loc_start1;
    $len_date   = $loc_end2-$loc_start2;
    $site=substr(@goop[$i],$loc_start1,$len_site);

### 2009.08.17 DEH resolve dotted quad site -- from resolve_dq.pl
#
#    regexp check
#
    $dottedquad = $site;

       if ($dottedquad =~ m/(\d{1,3}\.){3}(\d{1,3})/) {
         $arg = 'dig -x ' . $dottedquad;
         @result = `$arg`;
         for ( my $i=0; $i < scalar(@result); $i++) {
           if (@result[$i] =~ 'ANSWER SECTION') {
             $answer = @result[$i+1];           # get NEXT line following 'ANSWER'
             @parts=split(' ',$answer);
             $site=@parts[4]; chop $site;
           }
         }
       }

# print $site;                  #       whitepine.moscow.rmrs.fs.fed.us

    $date=substr(@goop[$i],$loc_start2,$len_date);
#      $ref = index(@goop[$i],'http:',0);
#      $ref = substr(@goop[$i],$ref);
#      chomp $ref;

    $loc_quote1 = index(@goop[$i],'"',0);
    $loc_quote2 = index(@goop[$i],'"',$loc_quote1+2);

    $loc_start_size = index(@goop[$i],' ',$loc_quote2+5);
    $loc_end_size   = index(@goop[$i],' ',$loc_start_size+1);

    $len_code=4;
    $loc_start3+=1;
    $len_size   = $loc_end_size-$loc_start_size+1;

    $code = substr(@goop[$i],$loc_quote2+1,$len_code)+0;
    $size = substr(@goop[$i],$loc_start_size,$len_size);
    if ($code == '200') {$colorcode='lightgreen'} else {$colorcode='white'}
     print "
    <tr>
     <td><font size=-1><a title='$goop[$i]'>$j</a></font></td>
     <td><font size=-1>$site</font></td>
     <td><font size=-1>$date</font></td>
     <td align=right bgcolor=$colorcode><font size=-1><a title='",$httpdcode{$code},"'>$code</a></font></td>
     <td align=right><font size=-1>$size</font></td>
     <td align=left><font size=-1>$ref</font></td>
    </tr>
";
  }

  print "
    </tr>
   </table>
  </font>
 </body>
</html>
";

# ------------------------------- subroutines -----------------------------------------

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

sub hashHTTPDcodes() {

# hash HTTPD codes

$httpdcode={};
$httpdcode{100}='Continue';
$httpdcode{200}='OK';
$httpdcode{202}='Accepted';
$httpdcode{203}='Non-Authoritative Information';
$httpdcode{204}='No Content';
$httpdcode{205}='Reset Content';
$httpdcode{206}='Partial Content';
$httpdcode{300}='Multiple Choices';
$httpdcode{301}='Moved Permanently';
$httpdcode{302}='Found';
$httpdcode{304}='Not Modified';
$httpdcode{305}='Use Proxy';
$httpdcode{306}='Switch Proxy';
$httpdcode{307}='Temporary Redirect';
$httpdcode{400}='Bad Request';
$httpdcode{401}='Unauthorized';
$httpdcode{402}='Payment Required';
$httpdcode{403}='Forbidden';
$httpdcode{404}='Not Found';
$httpdcode{405}='Method Not Allowed';
$httpdcode{406}='Not Acceptable';
$httpdcode{407}='Proxy Authentication Required';
$httpdcode{408}='Request Timeout';
$httpdcode{409}='Conflict';
$httpdcode{410}='Gone';
$httpdcode{411}='Length Required';
$httpdcode{412}='Precondition Failed';
$httpdcode{413}='Request Entity Too Large';
$httpdcode{414}='Request-URI Too Long';
$httpdcode{415}='Unsupported Media Type';
$httpdcode{416}='Requested Range Not Satisfiable';
$httpdcode{417}='Expectation Failed';
$httpdcode{421}='There are too many connections from your internet address';
$httpdcode{425}='Unordered Collection';
$httpdcode{426}='Upgrade Required';
$httpdcode{449}='Retry With';
$httpdcode{500}='Internal Server Error';
$httpdcode{501}='Not Implemented';
$httpdcode{502}='Bad Gateway';
$httpdcode{503}='Service Unavailable';
$httpdcode{504}='Gateway Timeout';
$httpdcode{505}='HTTP Version Not Supported';
$httpdcode{506}='Variant Also Negotiates';
$httpdcode{507}='Insufficient Storage';
$httpdcode{509}='Bandwidth Limit Exceeded';
$httpdcode{510}='Not Extended';
}
