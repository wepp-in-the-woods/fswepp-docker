#!/usr/bin/perl

use warnings;
use CGI;
use CGI qw(escapeHTML);

use MoscowFSL::FSWEPP::FsWeppUtils qw( get_user_id get_units);

# pclimate.cli  --  disguised perl script to generate & return climate for personal climates

$cgi = CGI->new;

$state     = escapeHTML( $cgi->param('state') );
$station   = escapeHTML( $cgi->param('station') );
$startyear = escapeHTML( $cgi->param('startyear') );  # should be numeric
$simyears  = escapeHTML( $cgi->param('simyears') );   # should be 1..200
$action    = escapeHTML( $cgi->param('action') );     # "-download" or "-server"
$comefrom  = escapeHTML( $cgi->param('comefrom') );
$submitbutton = lc( escapeHTML( $cgi->param('submitbutton') ) );

my ($units, $areaunits) = get_units();
my $user_ID = get_user_id();

$unique = 'wepp' . '-' . $$;

$minyear = 1;
$maxyear = 200;

if ( $state eq "" )     { $state     = "id" }
if ( $station eq "" )   { $station   = "id108080" }
if ( $startyear eq "" ) { $startyear = 1 }
$simyears += 0.5;
$simyears = int($simyears);
if ( $simyears < $minyear ) { $simyears = $minyear }
if ( $simyears > $maxyear ) { $simyears = $maxyear }
if ( $action eq "" )        { $action   = "-server" }

#  build filename + ".par"

$climate_file = $station . ".par";
$outfile      = "../working/" . $user_ID . ".cli";    # DEH 01/24/2001
$rspfile      = "../working/" . $unique . ".rsp";     # DEH 01/24/2001
$stoutfile    = "../working/" . $unique . ".out";     # DEH 01/24/2001

#    $climate_file = $station . ".par";
#    $outfile = "working\\custom.cli";

# open specified .par file, verify content, and close

open CLIM, "<" . $climate_file;    # || die "can't open file!";
$title        = <CLIM>;            # save climate file name to $station_text
$station_text = substr $title, 0, 40;
close CLIM;

####################################################################
#
#  MODIFY
#
####################################################################

if ( $submitbutton =~ /modify/ ) {
    $state = "personal";
    $CL    = $station;
    $iam   = "/cgi-bin/fswepp/rc/climate.cli";
    exec "../rc/modpar.pl $CL $units $state $comefrom";
}

####################################################################
#
#  DESCRIBE
#
####################################################################

if ( $submitbutton =~ /describe/ ) {

    $CL  = $station;
    $iam = "/cgi-bin/fswepp/rc/pclimate.cli";
    exec "../rc/descpar.pl $CL $units $iam";
}

####################################################################
#
#  GENERATE
#
####################################################################

if ( $submitbutton =~ /download/ ) {

    #  Write response file and
    #  run CLIGEN43 on verified user_id.par file to
    #  create user_id.cli file in WEPP:Road working directory
    #  for specified # years.

    #    $rspfile = "working\\rc.rsp";
    #    $stoutfile = "working\\rc.out";
    open RSP, ">" . $rspfile;
    print RSP "4.31\n";
    print RSP $climate_file, "\n";
    print RSP "n do not display file here\n";
    print RSP "5 Multiple-year WEPP format\n";
    print RSP $startyear, "\n";
    print RSP $simyears,  "\n";
    print RSP $outfile,   "\n";
    print RSP "n\n";
    close RSP;

    unlink $outfile;    # erase previous climate file so CLIGEN'll run

    @args = ("./cligen43 <$rspfile >$stoutfile");
    system @args;

##############################  DOWNLOAD  ####################

    if ( $action eq "-download" ) {

        #  If fileaction=download, send user text/plain version of generated
        # user_id.cli file which he/she can file--save-as.
        # Delete (unlink) user_id.cli file

## 1) read climate file and write to user.

        print 'Content-Type: application/octet-stream; name="climate.cli"
Content-Disposition: inline; filename="climate.cli"', "\n\n";

        open CLI, $outfile;
        while (<CLI>) {
            print $_;
        }
        close CLI;
        unlink $outfile;
    }
    else {    # "WEPP:Road"

        #    $nopath_outfile = $user_ID . ".cli";
        #    @args = ("cp $outfile $nopath_outfile");
        #    system @args;
        # system 'copy $climate_file working/climates/$unweirded_user_id.par'

        # | If for WEPP:Road, tell user filename & on for ~1 day;
        # | or tell user to accept cookie and store cookie with
        # | file name (good for 1 day) to client PC.
        # If for WEPP:Road tell user connect from same PC/dialin
        # w/in 1 day; choose {[X] custom climate}; W:R looks for
        # user_id.cli.

        print "Content-type: text/html\n\n";
        print "<HTML>\n";
        print "<HEAD>\n";
        print "<TITLE>CLIMATE FILE STORED ON SERVER</TITLE>\n";

        print "</HEAD>\n";
        print '<BODY bgcolor="white">', "\n";
        print "<CENTER><H2> $station_text CLIMATE STORED ON SERVER</H2>\n";

        print "<p><hr><p>\n";


        open CLI, "<" . $outfile;
        print "</center><pre>\n";
        $_ = <CLI>;
        print;         # 4.20
        $_ = <CLI>;    #   1   0   0
        $_ = <CLI>;
        print
          ; #   Station:  GLENNVILLE CA                                  CLIGEN VERSION 4.2
        $_ = <CLI>;
        print
          ; # Latitude Longitude Elevation (m) Obs. Years   Beginning year  Years simulated
        $_ = <CLI>;
        print
          ; #    35.72  -118.70         954          41           1               1
        $_ = <CLI>;
        print;    # Observed monthly ave max temperature (C)
        $_ = <CLI>;
        print
          ; #  13.6  14.7  15.0  18.4  23.2  28.5  32.8  31.9  29.0  23.5  17.2  14.0
        $_ = <CLI>;
        print;    # Observed monthly ave min temperature (C)
        $_ = <CLI>;
        print
          ; #  -2.3  -0.9   0.0   1.6   3.9   7.0  10.2   9.5   7.3   3.3  -0.2  -2.4
        $_ = <CLI>;
        print;    # Observed monthly ave solar radiation (Langleys/day)
        $_ = <CLI>;
        print
          ; # 227.0 321.0 465.0 556.0 649.0 705.0 679.0 637.0 596.0 420.0 265.0 199.0
        $_ = <CLI>;
        print;    # Observed monthly ave precipitation (mm)
        $_ = <CLI>;
        print
          ; #  82.3  68.2  83.9  45.6  16.5   3.5   0.7   2.7   8.0  18.2  54.3  68.2
        close CLI;
        print "</pre>\n";
        print "<center>\n";
        print "<hr><p>";
        if ( $comefrom eq "" ) {
            print '<a href="JavaScript:window.history.go(-1)">';
        }
        else {
            print "<a href=$comefrom>";
        }
        print '<img src="/fswepp/images/retreat.gif"
      alt="Retreat" border="0" align=center></A>';
        print "</body></html>\n";
    }
}    # end state and station OK

unlink $stoutfile;
unlink $rspfile;

#}    # submitbutton

# --------------------------------------------------------
