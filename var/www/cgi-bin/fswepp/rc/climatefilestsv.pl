#!/usr/bin/perl
use strict;
use warnings;
use MoscowFSL::FSWEPP::FsWeppUtils qw(get_user_id);
use MoscowFSL::FSWEPP::CligenUtils qw(GetPersonalClimates);

#  report custom climate files (names and user description)
#  determines caller's IP or ?ip=166.2.0.0
#  optionally reads personality as ?me=a

my $user_ID = get_user_id();
my @climates = GetPersonalClimates($user_ID);
my $num_cli = scalar @climates;

print "Content-type: text/plain\n\n";
print "Personal Climate Lister\n\n";
print "$num_cli personal climates for $user_ID\n\n";

foreach my $ii ( 0 .. $#climates ) {
    print $climates[$ii]->{'clim_file'} . "\t"
      . $climates[$ii]->{'clim_name'} . "\n";
}

print '

  <!-- https://forest.moscowfsl.wsu.edu/cgi-bin/fswepp/rc/climatefilestsv.pl?ip=166.2.22.221&me=a -->
  <!-- ip is optional; me is optional: personality [a-zA-Z] -->
';
