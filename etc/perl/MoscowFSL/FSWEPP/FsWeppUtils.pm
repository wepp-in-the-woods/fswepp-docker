package MoscowFSL::FSWEPP::FsWeppUtils;

use CGI;
use HTML::Entities;
use CGI qw(escapeHTML);

use strict;
use warnings;
use Exporter qw(import);
use File::Basename;
use DateTime;
use YAML::XS 'LoadFile';
use File::Slurp;
use POSIX qw(strftime);
use Time::Local;

our @EXPORT_OK =
  qw(commify printdate CreateSlopeFile CreateSoilFile 
     get_version get_thisyear_and_thisweek get_user_id get_units get_current_url
     LogUserRun);

sub LogUserRun {

    my ($model, $runLogFile, $climate_name, $unique, @data) = @_;

    $climate_name =~ s/^\s+|\s+$//g;

    my @months =
      qw(January February March April May June July August September October November December);
    my @days    = qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);
    my @ampm = ("am", "pm");

    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime;
    
    my $ispm = 0;
    if ( $hour == 12 ) { $ispm = 1 }
    if ( $hour > 12 )  { $ispm = 1; $hour =- 12 }
    my $gregorian_year  = $year + 1900;

    open RUNLOG, ">>$runLogFile";
    flock( RUNLOG, 2 );
    print RUNLOG "$model\t$unique\t\"";
    print RUNLOG sprintf("%02d:%02d ", $hour, $min);
    print RUNLOG "$ampm[$ispm] $days[$wday] $months[$mon] $mday, $gregorian_year\"\t\"";
    print RUNLOG "$climate_name\"\t";

    foreach my $value (@data) {
        print RUNLOG "$value\t";
    }
    print RUNLOG "\n";

    close RUNLOG;
}

sub get_current_url {
    my $cgi          = CGI->new;
    my $script_name  = $cgi->script_name;
    my $query_string = $cgi->query_string;
    my $full_path    = $script_name;
    $full_path .= "?$query_string" if $query_string;

    return $full_path;
}

sub get_units {

    my $cgi   = CGI->new;
    my $units = escapeHTML( lc( $cgi->param('units') ) );

    my $areaunits;
    if    ( $units eq 'm' )  { $areaunits = 'ha' }
    elsif ( $units eq 'ft' ) { $areaunits = 'ac' }
    else                     { $units     = 'ft'; $areaunits = 'ac' }

    return ( $units, $areaunits );
}

sub get_user_id {

    # DEH was using passing ip and me values as form parameters.
    # It's just double bookkeeping to do it that way...

    my $cookie = $ENV{'HTTP_COOKIE'} || '';
    my $sep    = index( $cookie, "FSWEPPuser=" );
    my $me     = "";
    if ( $sep > -1 ) { $me = substr( $cookie, $sep + 11, 1 ) }
    if ( $me ne "" ) {
        $me = lc( substr( $me, 0, 1 ) );
        $me =~ tr/a-z/ /c;
    }
    if ( $me eq " " ) { $me = "" }

    my $user_ID     = $ENV{'REMOTE_ADDR'}          // '';
    my $remote_host = $ENV{'REMOTE_HOST'}          // '';
    my $user_really = $ENV{'HTTP_X_FORWARDED_FOR'} // '';

    $user_ID = $user_really if ( $user_really ne '' );
    $user_ID =~ tr/./_/;    # Replace dots with underscores
                            # Append 'me' to user_ID

    return $user_ID . $me;
}

sub get_thisyear_and_thisweek {

    # Get the current date and year
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
      localtime();

    # Calculate the day of the week for January 1st of the current year
    my $thisyear   = 1900 + $year;
    my $jan_1_wday = ( localtime( timelocal( 0, 0, 0, 1, 0, $year ) ) )[6]
      ;    # Day of the week for Jan 1

    # Calculate day of the year and adjust for week number
    my $thisday    = $yday + 1;
    my $thisdayoff = $thisday + $jan_1_wday;
    my $thisweek   = 1 + int( $thisdayoff / 7 );

    return ( $thisyear, $thisweek );
}

sub printdate {
    my $tz = DateTime::TimeZone->new( name => 'America/Los_Angeles' );
    my $dt = DateTime->now( time_zone => $tz );

    printf "%02d:%02d %s %s %s %d, %d Pacific Time\n",
      $dt->hour_12,
      $dt->minute,
      $dt->am_or_pm,
      $dt->day_name,
      $dt->month_name,
      $dt->day,
      $dt->year;
}

sub commify {
    my $text = reverse $_[0];
    $text =~ s/(\d\d\d)(?=\d)(?!d*\.)/$1,/g;
    return scalar reverse $text;
}

sub CreateSlopeFile {
    my (
        $ofe1_top_slope, $ofe1_mid_slope, $ofe2_mid_slope, $ofe2_bot_slope,
        $ofe1_length,    $ofe2_length,    $ofe_area,       $slopeFile,
        $ofe_width,      $debug
    ) = @_;

    if ($debug) {
        print "FsWeppUtils::CreateSlopeFile\n";
    }

    # create slope file from specified geometry
    my $top_slope1 = $ofe1_top_slope / 100;
    my $mid_slope1 = $ofe1_mid_slope / 100;
    my $mid_slope2 = $ofe2_mid_slope / 100;
    my $bot_slope2 = $ofe2_bot_slope / 100;
    my $avg_slope  = ( $mid_slope1 + $mid_slope2 ) / 2;

  # Counteract calculation difficulties in WEPP 2010.100 if slope is unchanging.
  # 2012.10.29 DEH Hint from JRF
    my $slope_fuzz = 0.001;
    if ( abs( $mid_slope1 - $mid_slope2 ) < $slope_fuzz ) {
        $mid_slope2 += 0.01;
    }

    $ofe_width = 100 if $ofe_area == 0;
    open( my $SlopeFile, ">", $slopeFile )
      or die "Cannot open file $slopeFile: $!";

    print $SlopeFile "97.3\n";                              # datver
    print $SlopeFile "#\n# Slope file generated for FSWEPP\n#\n";
    print $SlopeFile "2\n";               # no. OFE
    print $SlopeFile "100 $ofe_width\n";  # aspect; representative profile width
                                          # OFE 1 (upper)
    printf $SlopeFile "%d  %.2f\n",    3,   $ofe1_length;   # no. points, length
    printf $SlopeFile " %.2f, %.3f  ", 0,   $top_slope1;    # dx, gradient
    printf $SlopeFile " %.2f, %.3f  ", 0.5, $mid_slope1;    # dx, gradient
    printf $SlopeFile " %.2f, %.3f\n", 1,   $avg_slope;     # dx, gradient
                                                            # OFE 2 (lower)
    printf $SlopeFile "%d  %.2f\n",    3,   $ofe2_length;   # no. points, length
    printf $SlopeFile " %.2f, %.3f  ", 0,   $avg_slope;     # dx, gradient
    printf $SlopeFile " %.2f, %.3f  ", 0.5, $mid_slope2;    # dx, gradient
    printf $SlopeFile " %.2f, %.3f\n", 1,   $bot_slope2;    # dx, gradient

    close $SlopeFile;
    return $slopeFile;
}

sub CreateSoilFile {
    my (
        $sol_version, $soil,         $treat1,
        $treat2,      $ofe1_rock,    $ofe2_rock,
        $soilFile,    $soil_db_file, $debug
    ) = @_;

    if ($debug) {
        print "MoscowFSL::FSWEPP::FsWeppUtils::CreateSoilFile\n";
    }

    # Load the soil database from the YAML file
    my $soil_db = LoadFile($soil_db_file);

    # Open the soil file for writing
    open my $sol_fh, '>', $soilFile
      or die "Could not open file '$soilFile': $!";

    # Write header with soil version
    print $sol_fh "$sol_version
#
#      MoscowFSL::FSWEPP::FsWeppUtils::CreateSoilFile
#      Numbers by: Bill Elliot (USFS)
#
2014 Disturbed WEPP database
 2    1
";

    # Function to process the soil data
    sub process_soil_data {
        my ( $soil, $treat, $rock_value, $soil_db, $sol_fh ) = @_;

        # Fetch the soil data from the YAML file
        my $soil_data = $soil_db->{$soil}{$treat};
        unless ( defined $soil_data && ref($soil_data) eq 'ARRAY' ) {
            die "Soil data not found for soil: $soil, treatment: $treat";
        }

        my ( $meta_line, $data_line ) = @$soil_data;

        # Replace {rfg} with the rock value
        $data_line =~ s/\{rfg\}/$rock_value/;

        # Write the formatted lines to the soil file
        print $sol_fh "$meta_line\n";
        print $sol_fh "$data_line\n";
    }

    # Process the first treatment
    process_soil_data( $soil, $treat1, $ofe1_rock, $soil_db, $sol_fh );

    # Process the second treatment
    process_soil_data( $soil, $treat2, $ofe2_rock, $soil_db, $sol_fh );

    # Close the soil file
    close $sol_fh;
}

# Subroutine to get the first 6 characters of the commit hash for a file
sub get_version {
    my ($file) = @_;

    # Get the file's last modified time (in epoch seconds)
    my $modified_time = ( stat($file) )[9];

    # Format the time to a readable format (YYYY-MM-DD)
    my $version = strftime( "%Y.%m.%d", localtime($modified_time) );

    return $version;
}

1;    # Return true to indicate successful loading of module

