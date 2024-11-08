package MoscowFSL::FSWEPP::WeppRoad;

use warnings;
use strict;

use CGI;
use HTML::Entities;
use CGI qw(escapeHTML);

use Exporter qw(import);
use File::Basename;
use DateTime;
use YAML::XS 'LoadFile';
use File::Slurp;
use POSIX qw(strftime);
use Time::Local;

our @EXPORT_OK =
  qw(CreateSoilFileWeppRoad CreateSlopeFileWeppRoad CheckInputWeppRoad GetSoilFileTemplate LogWeppRoadRun);

sub LogWeppRoadRun {
    use MoscowFSL::FSWEPP::CligenUtils qw(GetParLatLong);


    my ( $user_ID, $climatePar, $climate_name, $years) = @_;


    my @months =
      qw(January February March April May June July August September October November December);
    my @days    = qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);
    my @ampm = ("am", "pm");

    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime;
    
    my $ispm = 0;
    if ( $hour == 12 ) { $ispm = 1 }
    if ( $hour > 12 )  { $ispm = 1; $hour =- 12 }
    my $gregorian_year  = $year + 1900;

    my ( $lat, $long ) = GetParLatLong($climatePar);

    # 2008.06.04 DEH end
    open WRLOG, ">>../working/_$gregorian_year/wr.log";
    flock( WRLOG, 2 );
    print WRLOG "$user_ID\t\"";
    printf WRLOG "%0.2d:%0.2d ", $hour, $min;
    print WRLOG $ampm[$ispm], "  ", $days[$wday], " ", $months[$mon], " ",
      $mday, ", ", $gregorian_year, "\"\t";
    print WRLOG $years, "\t";
    print WRLOG '"', trim($climate_name), "\"\t";
    print WRLOG "$lat\t$long\n";    

    close WRLOG;

    my ($thisyear, $thisweek) = get_thisyear_and_thisweek();

    my $ditlogfile = ">>../working/_$gregorian_year/wr/" . $thisweek;  
    open MYLOG, $ditlogfile;
    flock MYLOG, 2;
    print MYLOG '.';
    close MYLOG;

}

sub GetSoilFileTemplate {
    my ( $soilDataDir, $surface, $SoilType, $slope ) = @_;

    my $surf = '';
    if    ( substr( $surface, 0, 1 ) eq 'g' ) { $surf = 'g' }
    elsif ( substr( $surface, 0, 1 ) eq 'p' ) { $surf = 'p' }
    else                                      { $surf = '' }

    if (   $slope ne 'inveg'
        && $slope ne 'outunrut'
        && $slope ne 'outrut'
        && $slope ne 'inbare' )
    {
        die "Invalid slope type $slope";
    }

    my $tauC = '2';
    if ( $slope eq 'inveg' ) {
        $tauC = '10';
    }
    elsif ( $slope eq 'inbare' && $surf eq 'p' ) {
        $tauC = '1';
    }

    my $soilFile = '3' . $surf . $SoilType . $tauC . '.sol';

    my $soilFilefq = $soilDataDir . $soilFile;

    if ( !-e $soilFilefq ) {
        die "Soil file $soilFile does not exist";
    }

    return $soilFilefq;
}

sub CheckInputWeppRoad {
    my ( $URL, $URS, $URW, $UFL, $UFS, $UBL, $UBS, $years, $units ) = @_;

    my $minURL        = 3;
    my $maxURL        = 1000;
    my $minURS        = 0.3;
    my $maxURS        = 40;
    my $minURW        = 1;
    my $maxURW        = 300;
    my $minUFL        = 1;
    my $maxUFL        = 1000;
    my $minUFS        = 0.3;
    my $maxUFS        = 150;
    my $minUBL        = 1;
    my $maxUBL        = 1000;
    my $minUBS        = 0.3;
    my $maxUBS        = 100;
    my $minyrs        = 1;
    my $maxyrs        = 200;
    my $rc            = 0;
    my $error_message = '';

    if ( $units eq "m" ) {
        $minURL = 1;
        $maxURL = 300;
        $minURS = 0.1;
        $maxURS = 40;
        $minURW = 0.3;
        $maxURW = 100;
        $minUFL = 0.3;
        $maxUFL = 100;
        $minUFS = 0.1;
        $maxUFS = 150;
        $minUBL = 0.3;
        $maxUBL = 300;
        $minUBS = 0.1;
        $maxUBS = 100;
    }

    if ( $URL < $minURL or $URL > $maxURL ) {
        $rc = -1;
        $error_message .=
          "Road length must be between $minURL and $maxURL $units ($URL)<BR>\n";
    }
    if ( $URS < $minURS or $URS > $maxURS ) {
        $rc = -1;
        $error_message .=
          "Road gradient must be between $minURS and $maxURS % ($URS)<BR>\n";
    }
    if ( $URW < $minURW or $URW > $maxURW ) {
        $rc = -1;
        $error_message .=
          "Road width must be between $minURW and $maxURW $units ($URW)<BR>\n";
    }
    if ( $UFL < $minUFL or $UFL > $maxUFL ) {
        $rc = -1;
        $error_message .=
          "Fill length must be between $minUFL and $maxUFL $units<BR>\n";
    }
    if ( $UFS < $minUFS or $UFS > $maxUFS ) {
        $rc = -1;
        $error_message .=
          "Fill gradient must be between $minUFS and $maxUFS %<BR>\n";
    }
    if ( $UBL < $minUBL or $UBL > $maxUBL ) {
        $rc = -1;
        $error_message .=
          "Buffer length must be between $minUBL and $maxUBL $units<BR>\n";
    }
    if ( $UBS < $minUBS or $UBS > $maxUBS ) {
        $rc = -1;
        $error_message .=
          "Buffer gradient must be between $minUBS and $maxUBS %<BR>\n";
    }
    if ( $years < $minyrs or $years > $maxyrs ) {
        $rc = -1;
        $error_message .=
"Number of years to simulate must be between $minyrs and $maxyrs ($years)<BR>\n";
    }
    return $rc, $error_message;
}

sub CreateSoilFileWeppRoad {
    my ( $soilFilefq, $newSoilFile, $surface, $traffic, $UBR, $URR_ref,
        $UFR_ref )
      = @_;

    my $in;
    my ( $pos1, $pos2, $pos3, $pos4 );
    my ( $ind, $left, $right );

    if ( !-e $soilFilefq ) {
        die "Soil file $soilFilefq does not exist";
    }

    if ( -e $newSoilFile ) {
        unlink $newSoilFile or die "Cannot delete file $newSoilFile: $!";
    }

    open my $SOILFILE, '<', $soilFilefq
      or die "Cannot open file $soilFilefq: $!";
    open my $NEWSOILFILE, '>', $newSoilFile
      or die "Cannot open file $newSoilFile: $!";

    if ( $surface eq 'graveled' ) {
        $URR_ref = 65;
        $UFR_ref = ( $UBR + 65 ) / 2;
    }
    elsif ( $surface eq 'paved' ) {
        $URR_ref = 95;
        $UFR_ref = ( $UBR + 65 ) / 2;
    }
    else { $URR_ref = $UBR; $UFR_ref = $UBR }

    # modify 'Kr' for 'no traffic' and 'low traffic'
    # modify 'Ki' for 'no traffic' and 'low traffic'

    if ( $traffic eq 'low' || $traffic eq 'none' ) {
        $in = <$SOILFILE>;
        print $NEWSOILFILE $in;    # line 1; version control number - datver
        $in = <$SOILFILE>;         # first comment line
        print $NEWSOILFILE $in;
        while ( substr( $in, 0, 1 ) eq '#' ) {    # gobble up comment lines
            $in = <$SOILFILE>;
            print $NEWSOILFILE $in;
        }
        $in = <$SOILFILE>;
        print $NEWSOILFILE $in;                   # line 3: ntemp, ksflag
        $in   = <$SOILFILE>;
        $pos1 = index( $in, "'" );                # location of first apostrophe
        $pos2 = index( $in, "'", $pos1 + 1 );    # location of second apostrophe
        $pos3 = index( $in, "'", $pos2 + 1 );    # location of third apostrophe
        $pos4 = index( $in, "'", $pos3 + 1 );    # location of fourth apostrophe
        my $slid_texid = substr( $in, 0, $pos4 + 1 );    # slid; texid
        my $rest       = substr( $in, $pos4 + 1 );
        my ( $nsl, $salb, $sat, $ki, $kr, $shcrit, $avke ) = split ' ', $rest;
        $kr /= 4;
        $ki /= 4;                                        # DEH 2004.01.26
        print $NEWSOILFILE "$slid_texid\t";
        print $NEWSOILFILE "$nsl\t$salb\t$sat\t$ki\t$kr\t$shcrit\t$avke\n";
    }
    while (<$SOILFILE>) {
        $in = $_;
        if (/urr/) {    # user-specified road rock fragment
            $ind   = index( $in, 'urr' );
            $left  = substr( $in, 0, $ind );
            $right = substr( $in, $ind + 3 );
            $in    = $left . $URR_ref . $right;
        }
        elsif (/ufr/) {    # calculated fill rock fragment
            $ind   = index( $in, 'ufr' );
            $left  = substr( $in, 0, $ind );
            $right = substr( $in, $ind + 3 );
            $in    = $left . $UFR_ref . $right;
        }
        elsif (/ubr/) {    # calculated buffer rock fragment
            $ind   = index( $in, 'ubr' );
            $left  = substr( $in, 0, $ind );
            $right = substr( $in, $ind + 3 );
            $in    = $left . $UBR . $right;
        }
        print $NEWSOILFILE $in;
    }
    close $SOILFILE;
    close $NEWSOILFILE;

    if ( !-e $newSoilFile ) {
        die "Soil file $newSoilFile does not exist";
    }

    return $newSoilFile;
}

sub CreateSlopeFileWeppRoad {
    my (
        $URS, $UFS,   $UBS,   $URW,       $URL, $UFL,
        $UBL, $units, $slope, $slopeFile, $debug
    ) = @_;

    if ($debug) {
        print "FsWeppUtils::CreateSlopeFileWeppRoad\n";
    }

    # TODO: this is the sane place to put validation

    # create slope file from specified geometry

    my $userRoadSlope = $URS / 100;    # road slope in decimal percent
    my $userFillSlope = $UFS / 100;
    my $userBuffSlope = $UBS / 100;
    my ( $userRoadWidth, $userRoadLength, $userFillLength, $userBuffLength );

    if ( $units eq 'm' ) {
        $userRoadWidth  = $URW;        # road width in meters
        $userRoadLength = $URL;
        $userFillLength = $UFL;
        $userBuffLength = $UBL;
    }
    else {
        my $tom = 0.3048;
        $userRoadWidth  = sprintf "%.2f", $URW * $tom;
        $userRoadLength = sprintf "%.2f", $URL * $tom;
        $userFillLength = sprintf "%.2f", $UFL * $tom;
        $userBuffLength = sprintf "%.2f", $UBL * $tom;
    }

    my $WeppRoadSlope  = $userRoadSlope;
    my $WeppRoadLength = $userRoadLength;
    my $WeppFillSlope  = $userFillSlope;
    my $WeppFillLength = $userFillLength;
    my $WeppBuffSlope  = $userBuffSlope;
    my $WeppBuffLength = $userBuffLength;

    if ( $WeppRoadLength < 1 ) { $WeppRoadLength = 1 } # minimum 1 m road length

    my $WeppRoadWidth;
    if ( $slope eq 'outunrut' ) {
        my $outslope = 0.04;
        $WeppRoadSlope =
          sqrt( $outslope * $outslope + $WeppRoadSlope * $WeppRoadSlope )
          ;    # 11/1999
        $WeppRoadLength = $userRoadWidth * $WeppRoadSlope / $outslope;
        $WeppRoadWidth  = $userRoadLength * $userRoadWidth / $WeppRoadLength;
    }
    else {
        $WeppRoadWidth = $userRoadWidth;
    }

    open( my $SlopeFile, ">", $slopeFile )
      or die "Cannot open file $slopeFile: $!";
    print $SlopeFile "97.3\n";                                 # datver
    print $SlopeFile "# Slope file for $slope by WEPP:Road Interface\n";
    print $SlopeFile "3\n";                  # no. OFE
    print $SlopeFile "100 $WeppRoadWidth\n"; # aspect; profile width			# 11/1999
                                             # OFE 1 (road)
    printf $SlopeFile "%d  %.2f\n", 2, $WeppRoadLength; # no. points, OFE length
    printf $SlopeFile "%.2f, %.2f  ", 0, $WeppRoadSlope;    # dx, gradient
    printf $SlopeFile "%.2f, %.2f\n", 1, $WeppRoadSlope;    # dx, gradient
                                                            # OFE 2 (fill)
    printf $SlopeFile "%d  %.2f\n", 3, $WeppFillLength; # no. points, OFE length
    printf $SlopeFile "%.2f, %.2f  ", 0,    $WeppRoadSlope;    # dx, gradient
    printf $SlopeFile "%.2f, %.2f  ", 0.05, $WeppFillSlope;    # dx, gradient
    printf $SlopeFile "%.2f, %.2f\n", 1,    $WeppFillSlope;    # dx, gradient
                                                               # OFE 3 (buffer)
    printf $SlopeFile "%d  %.2f\n", 3, $WeppBuffLength; # no. points, OFE length
    printf $SlopeFile "%.2f, %.2f  ", 0,    $WeppFillSlope;    # dx, gradient
    printf $SlopeFile "%.2f, %.2f  ", 0.05, $WeppBuffSlope;    # dx, gradient
    printf $SlopeFile "%.2f, %.2f\n", 1,    $WeppBuffSlope;    # dx, gradient
    close $SlopeFile;
    return ( $slopeFile, $WeppRoadSlope, $WeppRoadWidth, $WeppRoadLength );
}

1;    # Return true to indicate successful loading of module
