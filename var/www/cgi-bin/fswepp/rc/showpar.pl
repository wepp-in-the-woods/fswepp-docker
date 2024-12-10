#!/usr/bin/perl

use strict;
use warnings;
use CGI;
use CGI qw(escapeHTML);
use MoscowFSL::FSWEPP::FsWeppUtils qw(get_version);
use File::Slurp;    # To easily read the file contents

# Initialize CGI object
my $query = CGI->new;

# Get the climate parameter from the query string
my $CL = $query->param('CL');
chomp $CL;

# Construct the parameter file name
my $par_fn = "$CL.par";

# Get the script version
my $version = get_version(__FILE__);

# Check if the file exists and read its contents
if ( -e $par_fn ) {
    my $file_content = read_file($par_fn);    # Slurp the file content

    # Print the HTTP header and HTML content
    print $query->header('text/html'),
      $query->start_html( -title => "Station Parameter File: $CL" ),
      $query->h2("Station Parameter File"),
      $query->h3($CL),
      $query->start_pre,
      escapeHTML($file_content)
      ,    # Safely escape the file content for HTML output
      $query->end_pre, $query->end_html;
}
else {
    # Handle case where the file doesn't exist
    print $query->header('text/html'),
      $query->start_html('Error'),
      $query->h1('Error: File Not Found'),
      $query->p("The file $par_fn does not exist."),
      $query->end_html;
}
