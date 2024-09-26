#!/usr/bin/perl

use strict;
use warnings;
use CGI;
use CGI qw(escapeHTML);
use POSIX qw(strftime);
use Config::Simple;
use Path::Tiny;
use Encode qw(decode_utf8 FB_CROAK);

# Load environment configuration for password
my $cfg = Config::Simple->new('.env');
my $stored_password = $cfg->param('PASSWORD');

# Create CGI object
my $cgi = CGI->new;

# Retrieve user input
my $user_password = $cgi->param('password');

my $year          = escapeHTML( scalar $cgi->param('year') || '' );
$year = defined($year) && $year ne '' ? int($year + 0) : strftime("%Y", localtime);

my $lines          = escapeHTML( scalar $cgi->param('lines') || '' );
$lines = defined($lines) && $lines ne '' ? int($lines + 0) : 200;

# Password verification
unless ($user_password && $user_password eq $stored_password) {
    my $year_param = $cgi->param('year') || '';
    my $lines_param = $cgi->param('lines') || '';
    my $log_param = $cgi->param('log') || '';
    
    print $cgi->header('text/html');
    print "<html><body><h3>Access Denied: Invalid Password</h3>";
    print "<form method='POST'>";
    print "Password: <input type='password' name='password'><br>";
    print "<input type='hidden' name='year' value='$year_param'>";
    print "<input type='hidden' name='lines' value='$lines_param'>";
    print "<input type='hidden' name='log' value='$log_param'>";
    print "<input type='submit' value='Submit'>";
    print "</form>";
    print "</body></html>";
    exit;
}

my %log_titles = (
    wa  => 'WASP',
    wb  => 'BioMass',
    wd2 => 'Disturbed WEPP 2.0',
    wd  => 'Disturbed WEPP 1.0',
    dwb => 'Disturbed WEPP Batch',
    web => 'Batch ERMiT',
    we  => 'ERMiT',
    wf  => 'WEPP FUME',
    wrb => 'WEPP:Road Batch',
    wr  => 'WEPP:Road',
    wt  => 'Tahoe Basin',
);

my $log = $cgi->param('log');
unless (defined $log && exists $log_titles{$log}) {
    print $cgi->header('text/html');
    print "<html><body><h3>Error: Invalid or missing log parameter</h3></body></html>";
    exit;
}

my $log_path = path("working/_$year/$log.log");
my $title    = $log_titles{$log};

# Check if log file exists
unless (-e $log_path) {
    print $cgi->header('text/html');
    print "<html><body><h3>Error: Log file $log_path not found</h3></body></html>";
    exit;
}

# Handle potential encoding issues while reading the file
my @results;
eval {
    @results = reverse(map { decode_utf8($_, FB_CROAK) } $log_path->lines_raw({count => $lines}));
};
if ($@) {
    print $cgi->header('text/html');
    print "<html><body><h3>Error reading log file: $@</h3></body></html>";
    exit;
}

# Get the total number of lines in the log
my @runs = $log_path->lines_utf8;
my $total_lines = scalar(@runs);

$lines = $total_lines if $total_lines < $lines;

# Output the HTML response
print $cgi->header('text/html');
print <<"HTML";
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$title Run Log</title>
</head>
<body onLoad='self.focus()'>
  <font face='tahoma, arial, sans-serif'>
    <h3>$lines most recent of $total_lines $title runs in $year</h3>
    <pre>$log_path</pre>
    <pre>
      @results
    </pre>
  </font>
</body>
</html>
HTML
