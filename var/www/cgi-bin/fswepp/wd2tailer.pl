#! /usr/bin/perl

use CGI qw(:standard);
use POSIX qw(strftime);
use HTML::Entities;

my $query = CGI->new;
my $year = $query->param('year');

$year = int( $year + 0 );
$year = strftime("%Y", localtime) if ( $year == 0 );

$lines = 200;

@results = `tail -$lines working/_$year/wd2.log`;
@results = reverse(@results);
$wc      = `wc -l working/_$year/wd2.log`;
@words   = split " ", $wc;
$runs    = $words[0];

$lines = $runs if ( $lines > $runs );

my $escaped_year = encode_entities($year);

print header('text/html');
print start_html(
  -title => 'Disturbed WEPP 2.0 run log',
  -BGCOLOR => 'white',
  -onLoad => 'self.focus()'
);
print h3("$lines most recent of $runs Disturbed WEPP 2.0 runs in $escaped_year");
print pre(join("", @results));
print end_html;
