#!/usr/bin/perl

use strict;
use warnings;
use Test::More;

use MoscowFSL::FSWEPP::CligenUtils qw(GetStationsByState);

# Example usage
my $db_path = '/workdir/jimf-cligen532/db/stations.db';
my $state = 'AK';  # Change this to your state filter

my @stations = GetStationsByState($db_path, $state);

# Print the results
foreach my $station (@stations) {
    print "State: $station->{state}, Desc: $station->{desc}, Latitude: $station->{latitude}, Longitude: $station->{longitude}\n";
}