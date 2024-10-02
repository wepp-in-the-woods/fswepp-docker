#!/usr/bin/perl

use URI::Escape;
use CGI qw(:standard);

my $query = CGI->new;
my $pub   = $query->param('pub');
my $title = $query->param('title');
$title = uri_unescape($title);
my $hcode = $query->param('code') + 0;

# HTML escape the pub parameter
$pub = escapeHTML($pub);

# verify $pub !!!!!!!!!!! #########
# if ($pub eq '') {$pub='2001a'};

&hashHTTPDcodes;

print header('text/html');

print start_html(
  -title => $title ? "Moscow FSL - $title" : "Moscow FSL - Engineering Publications search results",
  -bgcolor => "#ffffff",
  -onLoad => "self.focus()"
);

print h1($title);
print p("Document download report");

print start_table;
print Tr(
  th(),
  th("Location"),
  th("Date"),
  th("Code"),
  th("Bytes")
);

my @goop = `fgrep $pub.pdf ~dhall/logs/logs/ac*.log`;

for (my $i = 0; $i <= $#goop; $i++) {
  my $j = $i + 1;
  my $loc_start1 = index($goop[$i], ':', 0);
  my $loc_end1 = index($goop[$i], ' ', $loc_start1);
  my $loc_start2 = index($goop[$i], '[', $loc_end1);
  my $loc_end2 = index($goop[$i], ' ', $loc_start2);
  $loc_start1 += 1;
  $loc_start2 += 1;
  my $len_site = $loc_end1 - $loc_start1;
  my $len_date = $loc_end2 - $loc_start2;
  my $site = substr($goop[$i], $loc_start1, $len_site);

  my $dottedquad = $site;

  if ($dottedquad =~ m/(\d{1,3}\.){3}(\d{1,3})/) {
    my $arg = 'dig -x ' . $dottedquad;
    my @result = `$arg`;
    for (my $i = 0; $i < scalar(@result); $i++) {
      if ($result[$i] =~ 'ANSWER SECTION') {
        my $answer = $result[$i + 1];
        my @parts = split(' ', $answer);
        $site = $parts[4];
        chop $site;
      }
    }
  }

  my $date = substr($goop[$i], $loc_start2, $len_date);

  my $loc_quote1 = index($goop[$i], '"', 0);
  my $loc_quote2 = index($goop[$i], '"', $loc_quote1 + 2);

  my $loc_start_size = index($goop[$i], ' ', $loc_quote2 + 5);
  my $loc_end_size = index($goop[$i], ' ', $loc_start_size + 1);

  my $len_code = 4;
  my $len_size = $loc_end_size - $loc_start_size + 1;

  my $code = substr($goop[$i], $loc_quote2 + 1, $len_code) + 0;
  my $size = substr($goop[$i], $loc_start_size, $len_size);
  my $colorcode = ($code == 200) ? 'lightgreen' : 'white';

  if ($hcode == $code || $hcode == 0) {
    print Tr(
      td(a({-title => $goop[$i]}, $j)),
      td($site),
      td($date),
      td({-align => 'right', -bgcolor => $colorcode}, a({-title => $httpdcode{$code}}, $code)),
      td({-align => 'right'}, $size)
    );
  }
}

print end_table;
print end_html;

sub hashHTTPDcodes {
  $httpdcode = {};
  $httpdcode{100} = 'Continue';
  $httpdcode{200} = 'OK';
  $httpdcode{202} = 'Accepted';
  $httpdcode{203} = 'Non-Authoritative Information';
  $httpdcode{204} = 'No Content';
  $httpdcode{205} = 'Reset Content';
  $httpdcode{206} = 'Partial Content';
  $httpdcode{300} = 'Multiple Choices';
  $httpdcode{301} = 'Moved Permanently';
  $httpdcode{302} = 'Found';
  $httpdcode{304} = 'Not Modified';
  $httpdcode{305} = 'Use Proxy';
  $httpdcode{306} = 'Switch Proxy';
  $httpdcode{307} = 'Temporary Redirect';
  $httpdcode{400} = 'Bad Request';
  $httpdcode{401} = 'Unauthorized';
  $httpdcode{402} = 'Payment Required';
  $httpdcode{403} = 'Forbidden';
  $httpdcode{404} = 'Not Found';
  $httpdcode{405} = 'Method Not Allowed';
  $httpdcode{406} = 'Not Acceptable';
  $httpdcode{407} = 'Proxy Authentication Required';
  $httpdcode{408} = 'Request Timeout';
  $httpdcode{409} = 'Conflict';
  $httpdcode{410} = 'Gone';
  $httpdcode{411} = 'Length Required';
  $httpdcode{412} = 'Precondition Failed';
  $httpdcode{413} = 'Request Entity Too Large';
  $httpdcode{414} = 'Request-URI Too Long';
  $httpdcode{415} = 'Unsupported Media Type';
  $httpdcode{416} = 'Requested Range Not Satisfiable';
  $httpdcode{417} = 'Expectation Failed';
  $httpdcode{421} = 'There are too many connections from your internet address';
  $httpdcode{425} = 'Unordered Collection';
  $httpdcode{426} = 'Upgrade Required';
  $httpdcode{449} = 'Retry With';
  $httpdcode{500} = 'Internal Server Error';
  $httpdcode{501} = 'Not Implemented';
  $httpdcode{502} = 'Bad Gateway';
  $httpdcode{503} = 'Service Unavailable';
  $httpdcode{504} = 'Gateway Timeout';
  $httpdcode{505} = 'HTTP Version Not Supported';
  $httpdcode{506} = 'Variant Also Negotiates';
  $httpdcode{507} = 'Insufficient Storage';
  $httpdcode{509} = 'Bandwidth Limit Exceeded';
  $httpdcode{510} = 'Not Extended';
}
