#!/usr/bin/perl
use CGI;

my $query = CGI->new;

# Extract all parameters
my %params = $query->Vars;

# Construct the URL with query parameters
my $url = 'rav.pl?' . $query->query_string;

# Perform the redirect
print $query->redirect($url);
