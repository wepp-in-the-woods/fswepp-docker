package MoscowFSL::FSWEPP::CligenUtils;

use strict;
use warnings;
use Exporter qw(import);
use File::Basename;
use DBI;

our @EXPORT_OK =
  qw(CreateCligenFile GetParSummary GetAnnualPrecip GetPersonalClimates GetClimates GetFutureClimates GetStationName GetParLatLong GetStationsByState);


=head1 NAME

GetStationsByState - Retrieve stations from an SQLite database filtered by state.

=head1 SYNOPSIS

    use MoscowFSL::FSWEPP::CligenUtils qw(GetStationsByState);
    my @stations = GetStationsByState($db_path, $state);

=head1 DESCRIPTION

Returns a list of stations filtered by the provided state from an SQLite database, sorted by station description (C<desc>).

=head2 PARAMETERS

=over

=item * C<$db_path> - Path to the SQLite database file.

=item * C<$state> - State code for filtering stations.

=back

=head2 RETURNS

A list of hashes, each representing a station with the following keys:

    state, desc, par, latitude, longitude, years, type, elevation, tp5, tp6

=head1 EXAMPLE

    my @stations = GetStationsByState('stations.db', 'AK');
    foreach my $station (@stations) {
        print "$station->{desc}, $station->{latitude}, $station->{longitude}\n";
    }

=cut

sub GetStationsByState {
    my ($db_path, $state) = @_;

    my $dbh = DBI->connect("dbi:SQLite:dbname=$db_path","","", {
        RaiseError => 1,
        PrintError => 0,
    }) or die $DBI::errstr;

    my $sth = $dbh->prepare("SELECT * FROM stations WHERE state = ? ORDER BY desc");
    $sth->execute($state);

    my @stations;
    while (my $row = $sth->fetchrow_hashref) {
        push @stations, $row;
    }

    $sth->finish();
    $dbh->disconnect();

    return @stations;
}


=head1 NAME

GetStationName - Extracts the station name from a .cli or .par file.

=head1 SYNOPSIS

    my $station_name = GetStationName($cli_fn);

=head1 DESCRIPTION

This subroutine reads a station file (either a `.cli` or `.par` file) and extracts the station name from it. If the file is a `.cli` file, the first two lines are skipped before extracting the station name from the third line.

=head2 PARAMETERS

=over

=item * C<$cli_fn> - Path to the station parameter file (`.par`) or Cligen climate file (`.cli`).

=back

=head2 RETURNS

Returns the station name as a string. Returns undef if the file cannot be opened.

=cut

sub GetStationName {
    my $cli_fn = shift;

    open my $fh, '<', $cli_fn or do {
        warn "Could not open '$cli_fn': $!";
        return undef;
    };

    my $station;

    # skip the first two lines if the file is a .cli file
    if ( substr( $cli_fn, -4 ) eq '.cli' ) {
        $station = <$fh>;
        $station = <$fh>;
    }
    $station = <$fh>;
    close $fh;

    my $clim_name = substr( $station, index( $station, ":" ) + 2, 40 );
    $clim_name =~ s/^\s*(.*?)\s*$/$1/;

    return $clim_name;
}

sub GetPersonalClimates {
    my $user_id = shift;

    # Fetch personal climate files
    my @pfiles = glob "../working/*$user_id*.par";
    my @climates;

    foreach my $pfile (@pfiles) {
        my $station = GetStationName($pfile);
        next unless $station;    # Skip files that couldn't be opened

        push @climates,
          {
            'clim_name' => "*" . $station,
            'clim_file' => substr( $pfile, 0, -4 )
          };
    }

    # Sort by climate name
    @climates = sort { $a->{'clim_name'} cmp $b->{'clim_name'} } @climates;

    return @climates;
}


sub GetClimates {
    my $user_id  = shift;
    my @climates = GetPersonalClimates($user_id);

    # Fetch standard climate files
    my @pfiles = glob "../climates/*.par";
    foreach my $pfile (@pfiles) {
        my $station = GetStationName($pfile);
        next unless $station;

        push @climates,
          { 'clim_name' => $station, 'clim_file' => substr( $pfile, 0, -4 ) };
    }

    # Sort by climate name
    @climates = sort { $a->{'clim_name'} cmp $b->{'clim_name'} } @climates;

    return @climates;
}


sub GetFutureClimates {
    my $fc_dir = shift;
    my @climates;

    # Fetch standard climate files
    my @pfiles = glob "$fc_dir/*.cli";
    foreach my $pfile (@pfiles) {
        my $station = GetStationName($pfile);
        next unless $station;

        push @climates,
          { 'clim_name' => $station, 'clim_file' => substr( $pfile, 0, -4 ) };
    }

    # Sort by climate name
    @climates = sort { $a->{'clim_name'} cmp $b->{'clim_name'} } @climates;

    return @climates;
}

sub CreateCligenFile {
    my ( $CL, $unique, $years2sim, $debug ) = @_;

    my $climatePar  = "$CL.par";
    my $climateFile = "../working/$unique.cli";
    my $outfile     = $climateFile;
    my $rspfile     = "../working/c$unique.rsp";
    my $stoutfile   = "../working/c$unique.out";

    if ($debug) {
        print "[CreateCligenFile]<br>
Arguments:    $years2sim<br>
ClimatePar:   $climatePar<br>
ClimateFile:  $climateFile<br>
OutputFile:   $outfile<br>
ResponseFile: $rspfile<br>
StandardOut:  $stoutfile<br>
";
    }

    my $startyear = 1;

    open my $RSP, '>', $rspfile or die "Could not open '$rspfile': $!";
    print $RSP "4.31\n";
    print $RSP "$climatePar\n";
    print $RSP "n do not display file here\n";
    print $RSP "5 Multiple-year WEPP format\n";
    print $RSP "$startyear\n";
    print $RSP "$years2sim\n";
    print $RSP "$climateFile\n";
    print $RSP "n\n";
    close $RSP;

    unlink $climateFile;    # erase previous climate file so's CLIGEN'll run

    my @args = ("../rc/cligen43 -r12345 <$rspfile >$stoutfile");
    system @args;

    my $cligen_version = "version unknown";
    open my $STOUT, '<', $stoutfile or die "Could not open '$stoutfile': $!";
    while (<$STOUT>) {
        if (/VERSION/) {
            chomp;
            $cligen_version = lc($_);
            last;
        }
    }
    close $STOUT;

    if ( -e $climateFile ) {
        unlink $rspfile;      # "../working/c$unique.rsp"
        unlink $stoutfile;    # "../working/c$unique.out"
    }

    return ( $climateFile, $climatePar );
}


sub GetParLatLong {
    my $climatePar = shift;

    if ( !-e $climatePar ) {
        die "Climate parameter file '$climatePar' does not exist";
    }

    open PAR, "<$climatePar";
    my $PARline  = <PAR>;                       # station name
    $PARline  = <PAR>;                       # Lat long
    my $lat_long = substr( $PARline, 0, 26 );
    my $lat      = substr $lat_long, 6,  7;
    my $long     = substr $lat_long, 19, 7;
    close PAR;

    return ( $lat, $long );
}

sub GetParSummary {
    my ( $file, $units ) = @_;
    my (
        @mean_p_if,  $mean_p_base, @pww,          $pww_base,  @pwd,
        $pwd_base,   @tmax_av,     $tmax_av_base, @tmin_av,   $tmin_av_base,
        @month_days, @num_wet,     @mean_p,       $lat,       $long,
        $elev,       $nwetunits,   $elevunits,    $tempunits, $prcpunits,
        $modfrom,    @ret,         @tmax,         @tmin
    );

    open my $PAR, '<', $file or die "Could not open '$file': $!";
    my $line = <$PAR>;

    $line = <$PAR>;
    my @latlong = split '=', $line;
    $lat  = substr( $latlong[1], 0, 7 );
    $long = substr( $latlong[2], 0, 7 );

    $line = <$PAR>;
    my @elevs = split '=', $line;
    $elev = substr( $elevs[1], 0, 7 );

    $line        = <$PAR>;
    @mean_p_if   = split ' ', $line;
    $mean_p_base = 2;
    <$PAR> for 1 .. 3;
    $line     = <$PAR>;
    @pww      = split ' ', $line;
    $pww_base = 1;
    $line     = <$PAR>;
    @pwd      = split ' ', $line;
    $pwd_base = 1;
    $line     = <$PAR>;

    for my $ii ( 0 .. 11 ) { $tmax_av[$ii] = substr( $line, 8 + $ii * 6, 6 ) }
    $tmax_av_base = 0;
    $line         = <$PAR>;

    for my $ii ( 0 .. 11 ) { $tmin_av[$ii] = substr( $line, 8 + $ii * 6, 6 ) }
    $tmin_av_base = 0;

    @month_days = ( 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 );

    for my $i ( 1 .. 12 ) {
        $num_wet[$i] = $pwd[$i] / ( 1 + $pwd[$i] - $pww[$i] );
    }

    for my $i ( 0 .. 11 ) {
        $tmax[$i]    = $tmax_av[ $i + $tmax_av_base ];
        $tmin[$i]    = $tmin_av[ $i + $tmin_av_base ];
        $pww[$i]     = $pww[ $i + $pww_base ];
        $pwd[$i]     = $pwd[ $i + $pwd_base ];
        $num_wet[$i] = sprintf '%.2f',
          $num_wet[ $i + $pww_base ] * $month_days[$i];
        $mean_p[$i] = sprintf '%.2f',
          $num_wet[$i] * $mean_p_if[ $i + $mean_p_base ];
        if ( $units eq 'm' ) {
            $mean_p[$i] = sprintf '%.2f', 25.4 * $mean_p[$i];
            $tmax[$i]   = sprintf '%.2f', ( $tmax[$i] - 32 ) * 5 / 9;
            $tmin[$i]   = sprintf '%.2f', ( $tmin[$i] - 32 ) * 5 / 9;
        }
    }

    $nwetunits = 'days';
    if ( $units eq 'm' ) {
        $tempunits = 'deg C';
        $prcpunits = 'mm';
        $elevunits = 'm';
        $elev      = sprintf '%.1f', $elev / 3.28;
    }
    else {
        $tempunits = 'deg F';
        $prcpunits = 'in';
        $elevunits = 'ft';
    }

    while (<$PAR>) {
        if (/Modified by/) {
            $modfrom = $_;
            $modfrom .= <$PAR>;
            last;
        }
    }

    close $PAR;

    if ($modfrom) {
        chomp $modfrom;

        $ret[0] = $modfrom . "<br>\n";
        $ret[1] = 'T MAX ' . join( ' ', @tmax ) . " $tempunits<br>\n";
        $ret[2] = 'T MIN ' . join( ' ', @tmin ) . " $tempunits<br>\n";
        $ret[3] = 'MEANP ' . join( ' ', @mean_p ) . " $prcpunits<br>\n";
        $ret[4] = '# WET ' . join( ' ', @num_wet ) . " $nwetunits<br>\n";
        $ret[5] =
          "Latitude $lat Longitude $long Elevation $elev $elevunits<br>";
        return @ret;
    }
    return;
}

sub GetAnnualPrecip {
    my ( $climatePar, $debug ) = @_;

    # in:  $climatePar
    # out: $ap_mean_precip

    open my $PAR, '<', $climatePar or die "Could not open '$climatePar': $!";
    my $line = <$PAR>;    # EPHRATA CAA AP WA                       452614 0
    print $line, "<br>\n" if $debug;
    $line = <$PAR>;       # LATT=  47.30 LONG=-119.53 YEARS= 44. TYPE= 3
    $line = <$PAR>;       # ELEVATION = 1260. TP5 = 0.86 TP6= 2.90
    $line = <$PAR>
      ; # MEAN P   0.10  0.10  0.11  0.10  0.11  0.14  0.14  0.09  0.10  0.10  0.12  0.12
    my @ap_mean_p_if   = split ' ', $line;
    my $ap_mean_p_base = 2;
    $line = <$PAR>
      ; # S DEV P  0.12  0.12  0.11  0.13  0.13  0.18  0.22  0.13  0.13  0.11  0.14  0.13
    $line = <$PAR>
      ; # SQEW  P  1.88  2.30  2.21  2.15  2.29  2.35  3.60  3.22  2.05  2.49  2.22  1.87
    $line = <$PAR>
      ; # P(W/W)   0.47  0.50  0.39  0.32  0.33  0.30  0.27  0.28  0.40  0.41  0.42  0.48
    my @ap_pww      = split ' ', $line;
    my $ap_pww_base = 1;
    $line = <$PAR>
      ; # P(W/D)   0.20  0.16  0.15  0.13  0.13  0.11  0.05  0.06  0.08  0.12  0.23  0.23
    my @ap_pwd      = split ' ', $line;
    my $ap_pwd_base = 1;
    close $PAR;

    my @ap_month_days = ( 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 );

    my $ap_units = 'm';

    my @ap_pw;
    for my $ap_i ( 1 .. 12 ) {
        $ap_pw[$ap_i] =
          $ap_pwd[$ap_i] / ( 1 + $ap_pwd[$ap_i] - $ap_pww[$ap_i] );
    }
    my $ap_annual_precip   = 0;
    my $ap_annual_wet_days = 0;
    for my $ap_i ( 0 .. 11 ) {
        my $ap_num_wet = $ap_pw[ $ap_i + $ap_pww_base ] * $ap_month_days[$ap_i];
        my $ap_mean_p  = $ap_num_wet * $ap_mean_p_if[ $ap_i + $ap_mean_p_base ];
        if ( $ap_units eq 'm' ) {
            $ap_mean_p *= 25.4;    # inches to mm
        }
        $ap_annual_precip += $ap_mean_p;
    }

    return $ap_annual_precip;
}

1;    # Return true to indicate successful loading of module
