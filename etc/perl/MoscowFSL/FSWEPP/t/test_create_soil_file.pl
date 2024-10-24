#!/usr/bin/perl


use strict;
use warnings;
use Test::More;
use File::Temp qw(tempfile);
use YAML::XS 'DumpFile';
use File::Slurp;

use MoscowFSL::FSWEPP::FsWeppUtils qw(CreateSoilFile);


# Test the CreateSoilFile subroutine
sub test_CreateSoilFile {
    my $expected_content = <<'END';
97.3
#
# MoscowFSL::FSWEPP::FsWeppUtils::CreateSoilFile
#
'skid' 'sandy loam' 1 0.2 0.75 400000 0.0001 2 10
300 65 10 5 15 20
'HIGH' 'sandy loam' 1 0.1 0.75 400000 0.00014 2 15
400 65 10 5 15 25
END

    my $soil_db_file = '/var/www/cgi-bin/fswepp/biomass/dat/soilbase.yaml';
    my $sol_filename = 'test_sand_skid_HIGH.sol';

    # Call the subroutine
    CreateSoilFile(
        "97.3", "sand", "skid", "HIGH", 30, 40, 20, 25, $sol_filename, $soil_db_file
    );

    # Read the content of the generated file
    my $generated_content = read_file($sol_filename);

    # Test if the generated file matches the expected output
    is($generated_content, $expected_content, "Generated soil file matches expected content");

    # Clean up
    unlink $sol_filename;
}


# Run the test
test_CreateSoilFile();

# Finish testing
done_testing();
