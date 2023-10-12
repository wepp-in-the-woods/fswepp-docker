#!/usr/bin/perl
use strict;
use warnings;
use CGI;

my $q = CGI->new;

print $q->redirect(
    -uri => '/fswepp/',
    -status => 302
);
