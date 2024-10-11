#!/usr/bin/perl
#use strict;
#use CGI ':standard';
#use File::Basename;

use warnings;
use CGI;
use MoscowFSL::FSWEPP::FsWeppUtils qw(CreateSlopeFile printdate get_version);

#
#  rav.pl -- Ravel workhorse
#

## BEGIN HISTORY ##############################
# RMRS Ravel Results history

my $version = get_version(__FILE__);
#  $version = '2010.03.15';    #
#  $version = '2010.09.01';    # California DEMs
## END HISTORY ##############################

$debug = 0;

# Reads
#   user input from ravel-ca.pl,
#   output file from get_ca
#   temporary DEM file
#
# Writes:
#   input param file for get-ca
#   output
#
# Runs:
#   get_ca (c++)
#   ravel  (c++)

# to do:
#   US units...

# David Hall, USDA Forest Service, Rocky Mountain Research Station, Moscow

#=========================================================================

#####  Read user input parameters  #####

my $cgi = CGI->new;

my %parameters = $cgi->Vars;

$description          = escapeHTML( $parameters{'description'} );
$vegetationSize       = escapeHTML( $parameters{'stemsize'} ) + 0;
$vegetationDensity    = escapeHTML( $parameters{'density'} ) + 0;
$fireImpactDepth      = escapeHTML( $parameters{'brndep'} ) / 1000;
$staticFrictionAngle  = escapeHTML( $parameters{'static'} ) + 0;
$kineticFrictionAngle = escapeHTML( $parameters{'kinetic'} ) + 0;
$bulkDensity          = escapeHTML( $parameters{'bulk'} ) + 0;

$lat1 = escapeHTML( $parameters{'bndlat1'} );
$lat2 = escapeHTML( $parameters{'bndlat2'} );
$lon1 = escapeHTML( $parameters{'bndlon1'} );
$lon2 = escapeHTML( $parameters{'bndlon2'} );

$me    = escapeHTML( $parameters{'me'} );
$units = escapeHTML( $parameters{'units'} );

#####  Set other parameters values  #####

# *******************************

$unique    = 'ravel' . '-' . $$;
$working   = 'working';
$temp_base = "$working/$unique";

$temp_html_base0 = "/srv/www/cgi-bin/BAERTOOLS/ravel/working/$unique";
$temp_html_base1 = "/cgi-bin/BAERTOOLS/ravel/working/$unique";
$DEMparamfile    = $temp_base . '.DEMinput.txt';
$DEMerrorfile    = $temp_base . '.DEMerror.txt';
$DEMfile         = $temp_base . '.DEM';
$paramFile       = $temp_base . '.paraminput.txt';

$demfilename       = $temp_base . '.dem.txt';
$results_dep_File  = $temp_base . '.depgrd.txt';
$results_prod_File = $temp_base . '.prodgrd.txt';

$calibration_File = "$temp_base.cal.txt";
$stdout0          = $temp_html_base0 . '.stdout.txt';
$stdout1          = $temp_html_base1 . '.stdout.txt';
$stderr0          = $temp_html_base0 . '.stderr.txt';
$stderr1          = $temp_html_base1 . '.stderr.txt';

# ########### RUN RAVEL ###########

print "Content-type: text/html\n\n";

print '<html>
 <head>
  <title>RMRS Ravel results for ', $unique, '</title>
   <script language = "JavaScript" type="TEXT/JAVASCRIPT">
';
print '

   function showSTDERR() {
     var properties="menubar,scrollbars,resizable"
     filewindow = window.open("","stderr",properties)
     filewindow.document.open()
     if (filewindow && filewindow.open && !filewindow.closed) {
       $z=0
     }
     else {
       return false
     }
     filewindow.focus
     filewindow.document.writeln("<html>")
     filewindow.document.writeln(" <head><title>DRY RAVEL error file for ',
  $unique, '<\/title><\/head>")
     filewindow.document.writeln(" <body><font face=\'courier\'><pre>")
';
open SE, "<$stderr0";

while (<SE>) {
    chomp;
    print '      filewindow.document.writeln("', $_, '")', "\n";
}
close SE;
print '      filewindow.document.writeln("   <\/pre>")
       filewindow.document.writeln("  <\/font>")
       filewindow.document.writeln(" <\/body>")
       filewindow.document.writeln("<\/html>")
       filewindow.document.close()
       return false
    }		// showSTDERR()
';
$angleunit = '<sup>o</sup>';
if ( $units eq 'm' ) {
    $massunit            = 'g';
    $densityunit         = 'stem/m<sup>2</sup>';
    $bulkdensityunit     = 'kg/m<sup>3</sup>';
    $lengthunit          = 'cm';
    $depunit             = 'kg';
    $produnit            = 'kg';
    $depositionunit      = 'kilogram';
    $productionunit      = 'kilogram';
    $cellsize_m          = $cellsize;
    $minMassOut_m        = $minMassOut;
    $vegetationSize_m    = $vegetationSize;
    $vegetationDensity_m = $vegetationDensity;
    $fireImpactDepth_m   = $fireImpactDepth;
    $cellsize_f          = $cellsize * 3.28;
    $minMassOut_f        = $minMassOut / 28.35;    # meters to feet

    #     $vegetationSize_f=$vegetationSize/25.4;
    $vegetationSize_f    = $vegetationSize * 3.28;    # meters to feet
    $vegetationDensity_f = $vegetationDensity;

    #     $fireImpactDepth_f=$fireImpactDepth/2.54;
    $fireImpactDepth_f = $fireImpactDepth * 3.28;     # meters to feet
}
else {
    $massunit            = 'oz';
    $densityunit         = '';
    $lengthunit          = 'in';
    $cellsize_f          = $cellsize;
    $minMassOut_f        = $minMassOut;
    $vegetationSize_f    = $vegetationSize;
    $vegetationDensity_f = $vegetationDensity;
    $fireImpactDepth_f   = $fireImpactDepth;
    $cellsize_m          = $cellsize / 3.28;          # feet to meters
    $minMassOut_m        = $minMassOut * 28.35;       # ounces to grams

    #     $vegetationSize_m=$vegetationSize*2.54;
    $vegetationSize_m    = $vegetationSize / 3.28;    # feet to meters
    $vegetationDensity_m = $vegetationDensity;

    #     $fireImpactDepth_m=$fireImpactDepth*2.54;
    $fireImpactDepth_m = $fireImpactDepth / 3.28;     # feet to meters
}

print "  </script>
 </head>

 <body>
  <font size=2 face='trebuchet, tahoma, arial'>
  <table width=100% bgcolor='green'>
   <tr>
    <th>
     <font face='trebuchet, tahoma, arial' color='gold'>
      RMRS Ravel $version
     </font>
    </th>
   </tr>
  </table>
";

#   $DEM = upload('uploadFileName');
if ($debug) {
    print "
description:	$description<br>
vegsize:	$vegetationSize<br>
vegdense:	$vegetationDensity<br>
fireimp:	$fireImpactDepth<br>
bulk density:	$bulkDensity<br> 
friction:	$staticFrictionAngle<br>
kinematic:	$kineticFrictionAngle<br>
unique:		$unique<br>
working:	$working<br>
tempbase:	$temp_base<br>
temphtml0:	$temp_html_base0<br>
temphtml1:	$temp_html_base1<br>
parmfile:	$paramFile<br>
demfile:	$demfilename<br>
dep_results:	$results_dep_File<br>
prod_results:	$results_prod_File<br>
calibration:	$calibration_File<br>
stdout0:	$stdout0<br>
stdout1:	$stdout1<br>
stderr0:	$stderr0<br>
stderr1:	$stderr1<br>
lat1:		$lat1
lat2:		$lat2
lon1:		$lon1
lon2:		$lon2
"
}
print "  <h4>$description</h4>
  <table border=1>
   <tr>
    <th colspan=3 bgcolor='green'><font face='trebuchet, tahoma, arial' size=2 color='gold'>User inputs</th>
   </tr>
   <tr>
    <th align=right bgcolor='green'><font color='gold' face='trebuchet, tahoma, arial' size=2>Latitude</font></th>
    <td><font face='trebuchet, tahoma, arial' size=2>$lat2</font></td>
    <td><font face='trebuchet, tahoma, arial' size=2>$lat1</font></td>
   </tr>
   <tr>
    <th align=right bgcolor='green'><font color='gold' face='trebuchet, tahoma, arial' size=2>Longitude</font></th>
    <td><font face='trebuchet, tahoma, arial' size=2>$lon1</font></td>
    <td><font face='trebuchet, tahoma, arial' size=2>$lon2</font></td>
   </tr>
   </tr>
   <tr>
    <th align=right bgcolor='green'><font color='gold' face='trebuchet, tahoma, arial' size=2>Vegetation size</font></th>
    <td colspan=2><font face='trebuchet, tahoma, arial' size=2>$vegetationSize m</font></td>
   </tr>
   <tr>
    <th align=right bgcolor='green'><font color='gold' face='trebuchet, tahoma, arial' size=2>Vegetation density</font></th>
    <td colspan=2><font face='trebuchet, tahoma, arial' size=2>$vegetationDensity $densityunit</font></td>
   </tr>
   <tr>
    <th align=right bgcolor='green'><font color='gold' face='trebuchet, tahoma, arial' size=2>Fire impact depth</font></th>
    <td colspan=2><font face='trebuchet, tahoma, arial' size=2>$fireImpactDepth m</font></td>
   </tr>
   <tr>
    <th align=right bgcolor='green'><font color='gold' face='trebuchet, tahoma, arial' size=2>Bulk density</font></th>
    <td colspan=2><font face='trebuchet, tahoma, arial' size=2>$bulkDensity $bulkdensityunit</font></td>
   </tr>
   <tr>
    <th align=right bgcolor='green'><font color='gold' face='trebuchet, tahoma, arial' size=2>Static friction angle</font></th>
    <td colspan=2><font face='trebuchet, tahoma, arial' size=2>$staticFrictionAngle $angleunit</font></td>
   </tr>
   <tr>
    <th align=right bgcolor='green'><font color='gold' face='trebuchet, tahoma, arial' size=2>Kinetic friction angle</font></th>
    <td colspan=2><font face='trebuchet, tahoma, arial' size=2>$kineticFrictionAngle $angleunit</font></td>
   </tr>
   <tr>
    <th align=right bgcolor='green'><font color='gold' face='trebuchet, tahoma, arial' size=2>DEM file</font></th>
    <td colspan=2><font face='trebuchet, tahoma, arial' size=2>$DEMfile</font></td>
   </tr>
  </table>
";

#######################################
###       create DEM file           ###
#######################################

#
# create run_ca input parameter file
#

###  create DEM-getter input file ###

open DEM_PARAM, ">$DEMparamfile";
print DEM_PARAM "$lat1
$lon1
$lat2
$lon2
$DEMfile
data/CA/
";
close DEM_PARAM;

#
#  Run DEM-getter code
#

system "./run_ca $DEMparamfile $DEMerrorfile";

#
# check run_ca results
#

open DEMresults, "<$DEMerrorfile";
@results = <DEMresults>;
print "<b>Messages from run_ca</b><br>\n";
print @results;
print "\n<br><br>\n";

$demfilename = $DEMfile;

# die;

$max_size = "1000000";    # 50000 is the same as 50kb

## Check Extension

## Check file type

## Check File Size

$fileSize = -s $demfilename;
print "File size: $fileSize<br>\n";
if ( $fileSize > $max_size ) {
    print
"<p><strong class=\"error\">Error:</strong> file is too big, limit is: $max_size bytes.</p>";
    $successful = 0;
    die;
}
if ( $fileSize < 10 ) {
    print
"<p><strong class=\"error\">Error:</strong> file is empty (or almost empty).</p>";
    $successful = 0;
    die;
}

# die if !$successful;

################################################################################
################################################################################

# open DEM text file
# determine number of rows, number of columns
# determine minimum, maximum values

#  $miss = 32767;

#  print "Dry ravel DEM file? ";
#  $path=<STDIN>;
#  chomp $path;

$encode = 0;
$skip   = 0;
$encode = 1;

#  print "Display values (slow...) [n] ";
#  $show=<STDIN>;   chomp $show;
#  $encode=1 if $show=~'y';
#  $encode=1 if $show=~'Y';

$dem = '<' . $demfilename;

if ( -e $demfilename ) {
    open DEM, $dem || die;
    $_ = <DEM>;
    ( $head, $ncols ) = split ' ', $_;
    $_ = <DEM>;
    ( $head, $nrows ) = split ' ', $_;
    $_ = <DEM>;
    ( $head, $xllcorner ) = split ' ', $_;
    $_ = <DEM>;
    ( $head, $yllcorner ) = split ' ', $_;
    $_ = <DEM>;
    ( $head, $cellsize ) = split ' ', $_;
    $_ = <DEM>;
    ( $head, $miss ) = split ' ', $_;
    $num_cols = $ncols;

    #   @cell=split ' ',$_;
    #   $num_cols=$#cell;

    $rows     = 0;
    $cols     = 0;
    $min_elev = 99999;
    $max_elev = -99999;
    while (<DEM>) {
        @cell = split ' ', $_;
        $rows += 1;
        $cols = $#cell;
        for ( $col = 0 ; $col <= $cols ; $col++ ) {
            if ( @cell[$col] != $miss ) {
                $min_elev = @cell[$col] if ( @cell[$col] < $min_elev );
                $max_elev = @cell[$col] if ( @cell[$col] > $max_elev );
            }
        }
    }

    #   $num_rows = $rows - 1;
    $num_rows = $rows;
    $rows     = 0;

    # error if $cols != $num_cols
    # error if $nrows != $num_rows

    close DEM;

    #    print "$cols columns\n";
    #    print "Min elevation $min_elev\tMax elevation $max_elev\n";

    $range = $max_elev - $min_elev;    # warn if ~0

    #  open FIG, '>ele.html';

    # print FIG "

    if ($debug) {
        print "
$num_rows $nrows rows<br>
$num_cols $cols columns<br>
$xllcorner xllcorner<br>
$yllcorner yllcorner<br>
$cellsize cellsize<br>
$miss missing<br>
";
    }
    print "
  <font face='trebuchet, tahoma, arial, sans serif'>

  <table width=100% bgcolor='lightgreen'>
   <tr>
    <th>
     <font face='trebuchet, tahoma, arial' color='black'>
      ELEVATION
     </font>
    </th>
   </tr>
  </table>
    <h4>$num_rows rows x $num_cols columns</h4>
";

    print '
   <table border=0 cellpadding=0 cellspacing=0>
';

    $min_value = 99999;
    $max_value = -99999;
    @histo     = (0) x 255;    # 060922 DEH

    open DEM, $dem;

    # skip header lines

    $_ = <DEM>;                #($head,$ncols)=split ' ',$_;
    $_ = <DEM>;                #($head,$nrows)=split ' ',$_;
    $_ = <DEM>;                #($head,$xllcorner)=split ' ',$_;
    $_ = <DEM>;                #($head,$yllorner)=split ' ',$_;
    $_ = <DEM>;                #($head,$cellsize)=split ' ',$_;
    $_ = <DEM>;                #($head,$miss)=split ' ',$_;

    while (<DEM>) {
        @cell = split ' ', $_;
        $cols = $#cell;
        print '
    <tr>
';

        for ( $col = 0 ; $col <= $num_cols - 1 ; $col++ ) {
            if ( @cell[$col] == $miss ) {
                $color = '#550000';
            }
            else {
                $val   = @cell[$col];
                $value = ( $val - $min_elev ) / $range;
                $value = 0 if ( $value < 0 );
                $value = 1 if ( $value > 1 );

         #         $value = sprintf ('%d',255*((@cell[$col]-$min_elev)/$range));
                $value   = sprintf( '%d', 255 * $value );
                $val_hex = sprintf "%lx", $value;
                @histo[$value] += 1;    # DEH 060922
                $min_value = $value if ( $value < $min_value );
                $max_value = $value if ( $value > $max_value );
                $color = '#00' . $val_hex . '00';
                $color = '#000' . $val_hex . '00' if ( length($val_hex) == 1 );

        # print "     <td width=20 height=10 bgcolor='rgb(0,$level,0)'></td>\n";
            }
            if ($encode) {
                print
"     <td width=6 height=5 bgcolor='$color' onClick=\"document.elevation.elev.value='[$rows, $col]: $val'\"></td>\n";
            }
            else { print "     <td width=6 height=5 bgcolor='$color'></td>\n"; }
        }
        print '
    </tr>
';
        $rows += 1;
    }
    close DEM;

    print "
   </table>
";

    #    Min elevation: $min_elev m<br>
    #    Max elevation: $max_elev m<br>
    #    Range:         $range m<br>
    #    Minimum Z: $min_value<br>
    #    Maximum Z: $max_value

    print "
Range: $range m ($min_elev to $max_elev)
<br>
<form name='elevation'><input type='text' name='elev' readonly></form>
<br>
   <table cellpadding=0 cellspacing=0>
    <tr>
     <td colspan=100 align=left>$min_elev</td>
     <td colspan=55>&nbsp;m&nbsp;</td>
     <td colspan=100 align=right>$max_elev</td>
    </tr>
    <tr>
";

    for ( $his = 0 ; $his < 256 ; $his++ ) {
        $real  = $min_elev + ( $range * $his / 255 );
        $z_hex = sprintf "%lx", $his;
        $color = '#00' . $z_hex . '00';
        $color = '#000' . $z_hex . '00' if ( length($z_hex) == 1 );
        print
"     <td height='10' bgcolor='$color' onClick=\"document.elevation.elev.value='$real'\"></td>\n";
    }
    print '    </tr>
    <tr>
';
    for ( $his = 0 ; $his < 256 ; $his++ ) {

#      print "     <td valign='bottom'><img src='black.gif' width='2' height='@histo[$his]' alt='$his: $histo[$his]' border=0></td>\n";
        print
"     <td valign='top'><img src='/black.gif' width='2' height='@histo[$his]' onClick=\"document.elevation.elev.value='@histo[$his]'\"></td>\n";
    }

    print '
   </tr>
   <tr>
    <td height="8"></td>
   </tr>
   <tr>
';

#     for ($his=0;$his<256;$his++) {
#       $real=$min_elev+($range*$his/255);
#       $z_hex = sprintf "%lx", $his;
#       $color='#00'.$z_hex.'00';
#       $color='#000'.$z_hex.'00' if (length ($z_hex) == 1);
#       print "     <td height='5' bgcolor='$color' onClick=\"window.status='$real'\"></td>\n";
#     }
    print "
  </table>
";

#######################################
#### if display DEM only, stop here ###
#######################################

    # die;

    #  &createParamFile;

    open PARAM, ">$paramFile";
    print PARAM "$vegetationSize
$vegetationDensity
$fireImpactDepth
$bulkDensity
$staticFrictionAngle
$kineticFrictionAngle
$results_dep_File
$results_prod_File
$calibration_File
";
    close PARAM;

    #   $size_default=2;
    #   $mmo_default=0.1;
    #   $vegsize_default=0.05;
    #   $vegdensity_default=1;

#   print "Size:              [$size_default]    ";
#   $size=<STDIN>;   chomp $size;   $size=$size_default if ($size eq '');
#   print "Minimum mass out   [$mmo_default]  ";
#   $minMassOut=<STDIN>;   chomp $minMassOut;   $minMassOut=$mmo_default if ($minMassOut eq '');
#   print "Vegetation size    [$vegsize_default] ";
#   $vegetationsize=<STDIN>;   chomp $vegetationsize;   $vegetationsize=$vegsize_default if ($vegsize eq '');
#   print "Vegetation density [$vegdensity_default]    ";
#   $vegetationdensity=<STDIN>;   chomp $vegetationdensity;   $vegetationdensity=$vegdensity_default if ($vegetationdensity eq '');

#   open PARAM, '>paraminput.txt';
#     print PARAM "$num_rows\t$num_cols\t$size\t$minMassOut\t$vegetationsize\t$vegetationdensity\n";
#   close PARAM;

    print "<br>starting simulation ... ";

        $time_start = time;

        if ($debug) {
            print
"<br>\n./ravel $paramFile $demfilename >$stdout0 2>$stderr0<br>\n";
        }
        `./ravel $paramFile $demfilename >$stdout0 2>$stderr0`;
        $time_end = time;
        $time_dif = $time_end - $time_start;

        # print "timing: @timing<br>\n";
        print " [$time_dif seconds] ";

        #
        #  record run in log
        #

        $host        = $ENV{REMOTE_HOST};
        $host        = $ENV{REMOTE_ADDR} if ( $host eq '' );
        $user_really = $ENV{'HTTP_X_FORWARDED_FOR'};
        $host        = $user_really if ( $user_really ne '' );

        @months =
          qw(January February March April May June July August September October November December);
        @days    = qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);
        $ampm[0] = "am";
        $ampm[1] = "pm";
        $ampmi   = 0;
        ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
          localtime;
        if ( $hour == 12 ) { $ampmi = 1 }
        if ( $hour > 12 )  { $ampmi = 1; $hour = $hour - 12 }

        open RaveLOG, ">>working/ravel.log";
        flock( RaveLOG, 2 );
        print RaveLOG "$host\t\"";
        printf RaveLOG "%0.2d:%0.2d ", $hour, $min;
        print RaveLOG $ampm[$ampmi], "  ", $days[$wday], " ", $months[$mon],
          " ", $mday, ", ", $year + 1900, "\"\t";
        print RaveLOG "$lat1\t$lon1\t$lat2\t$lon2\t";
        print RaveLOG "$time_dif\n";
        close RaveLOG;

    print " ...finished simulation<br>
";


    if ( -s $stderr0 > 1 ) {
        print '[<a href="javascript:void(showSTDERR())">STDERR</a>]';
    }
    if ($debug) {
        if ( -s $stdout0 > 1 ) {
            print "
  <iframe src='$stdout1' width=750 height=50 frameborder=0 scrolling=yes>  </iframe>
";
        }
        if ( -s $stderr0 > 1 ) {
            print "
  <iframe src='$stderr1' width=750 height=50 frameborder=0 scrolling=yes>  </iframe>
";
        }
    }

######################
    # Deposition results #
######################

    print "
  <table width=100% bgcolor='lightgreen'>
   <tr>
    <th>
     <font face='trebuchet, tahoma, arial' color='black'>
      DEPOSITION
     </font>
    </th>
   </tr>
  </table>
";

    #print "
    #   <hr size=10>
    #
    #   <h3>Deposition</h3>
    #";

    #    open RESULTS, '<working/pointoutput.xls'; 		#

    if ( -e $results_dep_File ) {
        open RESULTS, "<$results_dep_File";

        # print "$num_rows x $num_cols<br>\n";

        $_ = <RESULTS>;    # ncols
        $_ = <RESULTS>;    # nrows
        $_ = <RESULTS>;    # xllcorner
        $_ = <RESULTS>;    # yllcorner
        $_ = <RESULTS>;    # cellsize
        $_ = <RESULTS>;    # nodata_value

        $min_r = 999999;
        $max_r = -999999;
        for ( $row = 0 ; $row < $num_rows - 1 ; $row++ ) {
            $_    = <RESULTS>;
            @cell = split ' ', $_;
            for ( $col = 0 ; $col < $num_cols ; $col++ ) {
                $min_r = @cell[$col] if ( @cell[$col] < $min_r );
                $max_r = @cell[$col] if ( @cell[$col] > $max_r );
            }
        }
        $range = $max_r - $min_r;    # warn if ~0
        $min_r;
        $max_r;

        close RESULTS;

        #    $num_rows=$rows-1;

        #    print "$cols columns\n";
        #    print "Min results $min_res\tMax results $max_res\n";

        $min_range = 0.01;
        if ( $range > $min_range ) {

            print "
   <table border=0 cellpadding=0 cellspacing=0>
";

            $min_z = 999999;
            $max_z = -999999;
            @histo = (0) x 255;    # 060922 DEH

            #  open RESULTS, '<working/pointoutput.xls';
            open RESULTS, "<$results_dep_File";

            $_ = <RESULTS>;        # ncols
            $_ = <RESULTS>;        # nrows
            $_ = <RESULTS>;        # xllcorner
            $_ = <RESULTS>;        # yllcorner
            $_ = <RESULTS>;        # cellsize
            $_ = <RESULTS>;        # nodata_value
            for ( $row = 0 ; $row < $num_rows ; $row++ ) {
                $_    = <RESULTS>;
                @cell = split ' ', $_;
                print '    <tr>
';
                for ( $col = 0 ; $col < $num_cols ; $col++ ) {
                    $val = @cell[$col];
                    $z   = ( $val - $min_r ) / $range;    ### div zero
                    $z   = 0 if ( $z < 0 );
                    $z   = 1 if ( $z > 1 );
                    $z   = sprintf( '%d', 255 * $z )
                      ; # $value = sprintf ('%d',255*(@cell[$col]-$min_r)/$range);
                    $z_hex = sprintf "%lx", $z;
                    @histo[$z] += 1;     # 060922 DEH
                    if ( $val < 0 ) {    # red
                        $color = $z_hex . '0000';
                        $color = '#0' . $z_hex . '0000'
                          if ( length($z_hex) == 1 );
                    }
                    else {               # green
                        $color = '#00' . $z_hex . '00';
                        $color = '#000' . $z_hex . '00'
                          if ( length($z_hex) == 1 );
                    }
                    $min_z = $z if ( $z < $min_z );
                    $max_z = $z if ( $z > $max_z );
                    if ($encode) {
                        print
"     <td width=6 height=5 bgcolor='$color' onClick=\"document.deposition.depos.value='[$row, $col]: $val'\"></td>\n";
                    }
                    else {
                        print
                          "     <td width=6 height=5 bgcolor='$color'></td>\n";
                    }
                }    # for ($col=0...)
                print '    </tr>
';
            }    # for ($row=0...)

            close RESULTS;

            print "
   </table>
";

            #    Min results: $min_r<br>
            #    Max results: $max_r<br>
            #    Range:       $range<br>
            #    Minimum Z: $min_z<br>
            #    Maximum Z: $max_z

        }    # if ($range > $min_range)

        print "
   Range: $range ($min_r to $max_r)
   <br>
";
        if ( $range > $min_range ) {
            print
"   <form name='deposition'><input type='text' name='depos' readonly> [row, col] $depunit deposited</form>
   <br>
   <table cellpadding=0 cellspacing=0 width=25%>
    <tr>
     <td colspan=100 align=left>$min_r</td>
     <td colspan=55>&nbsp;&nbsp;</td>
     <td colspan=100 align=right>$max_r</td>
    </tr>
    <tr>
";

###### DEPOSITION HISTOGRAM START #####

            for ( $his = 0 ; $his < 256 ; $his++ ) {
                $real  = $min_r + ( $range * $his / 255 );
                $z_hex = sprintf "%lx", $his;

                #      $color='#00'.$z_hex.'00';
                #      $color='#000'.$z_hex.'00' if (length ($z_hex) == 1);
                if ( $real < 0 ) {    # red
                    $color = $z_hex . '0000';
                    $color = '#0' . $z_hex . '0000' if ( length($z_hex) == 1 );
                }
                else {                # green
                    $color = '#00' . $z_hex . '00';
                    $color = '#000' . $z_hex . '00' if ( length($z_hex) == 1 );
                }
                print
"     <td height='5' bgcolor='$color' onClick=\"document.deposition.depos.value='$real [@histo[$his]]'\"></td>\n";
            }    # for ($his=0...)

#######################
#print '
#   </tr>
#   <tr>
#';
#     for ($his=0;$his<256;$his++) {
#       print "     <td valign='top'><img src='black.gif' width='2' height='@histo[$his]' onClick=\"window.status='@histo[$his]'\"></td>\n";
#     }		# for ($his=0...)
#######################
            print '
   </tr>
   <tr>
    <td height="8"></td>
   </tr>
   <tr>
   </tr>
  </table>
';
        }    # if ($range > $min_range)
##### DEPOSITION HISTOGRAM END #####
    }    # (-e $results_dep_File)
    else {
        print "    Deposition results not found<br>\n";
    }

######################
    # Production results #
######################

    print "
  <table width=100% bgcolor='lightgreen'>
   <tr>
    <th>
     <font face='trebuchet, tahoma, arial' color='black'>
      PRODUCTION
     </font>
    </th>
   </tr>
  </table>
";

    #print "
    #   <hr size=10>
    #   <h3>Production</h3>
    #";

    if ( -e $results_prod_File ) {

        #    open RESULTS, '<working/pointoutput.xls'; 		#
        open RESULTS, "<$results_prod_File";

        # print "$num_rows x $num_cols<br>\n";

        $_ = <RESULTS>;    # ncols
        $_ = <RESULTS>;    # nrows
        $_ = <RESULTS>;    # xllcorner
        $_ = <RESULTS>;    # yllcorner
        $_ = <RESULTS>;    # cellsize
        $_ = <RESULTS>;    # nodata_value

        $min_r = 999999;
        $max_r = -999999;
        for ( $row = 0 ; $row < $num_rows - 1 ; $row++ ) {
            $_    = <RESULTS>;
            @cell = split ' ', $_;
            for ( $col = 0 ; $col < $num_cols ; $col++ ) {
                $min_r = @cell[$col] if ( @cell[$col] < $min_r );
                $max_r = @cell[$col] if ( @cell[$col] > $max_r );
            }
        }
        $range = $max_r - $min_r;    # warn if ~0

        #     $min_r;
        #     $max_r;

        close RESULTS;

        #    $num_rows=$rows-1;

        #    print "$cols columns\n";
        #    print "Min results $min_res\tMax results $max_res\n";

        if ( $range > $min_range ) {

            print "
   <table border=0 cellpadding=0 cellspacing=0>
";

            $min_z = 999999;
            $max_z = -999999;
            @histo = (0) x 255;    # 060922 DEH

            # open RESULTS, '<working/pointoutput.xls';
            open RESULTS, "<$results_prod_File";

            #   $title=<RESULTS>;
            $_ = <RESULTS>;        # ncols
            $_ = <RESULTS>;        # nrows
            $_ = <RESULTS>;        # xllcorner
            $_ = <RESULTS>;        # yllcorner
            $_ = <RESULTS>;        # cellsize
            $_ = <RESULTS>;        # nodata_value

            #   $_=<RESULTS>;

            for ( $row = 0 ; $row < $num_rows ; $row++ ) {
                $_    = <RESULTS>;
                @cell = split ' ', $_;
                print '    <tr>
';
                for ( $col = 0 ; $col < $num_cols ; $col++ ) {
                    $val = @cell[$col];
                    $z   = ( $val - $min_r ) / $range;    ### div zero
                    $z   = 0 if ( $z < 0 );
                    $z   = 1 if ( $z > 1 );
                    $z   = sprintf( '%d', 255 * $z )
                      ; # $value = sprintf ('%d',255*(@cell[$col]-$min_r)/$range);
                    $z_hex = sprintf "%lx", $z;
                    @histo[$z] += 1;     # 060922 DEH
                    if ( $val < 0 ) {    # red
                        $color = $z_hex . '0000';
                        $color = '#0' . $z_hex . '0000'
                          if ( length($z_hex) == 1 );
                    }
                    else {               # green
                        $color = '#00' . $z_hex . '00';
                        $color = '#000' . $z_hex . '00'
                          if ( length($z_hex) == 1 );
                    }
                    $min_z = $z if ( $z < $min_z );
                    $max_z = $z if ( $z > $max_z );
                    if ($encode) {
                        print
"     <td width=6 height=5 bgcolor='$color' onClick=\"document.production.prod.value='[$row, $col]: $val'\"></td>\n";
                    }
                    else {
                        print
                          "     <td width=6 height=5 bgcolor='$color'></td>\n";
                    }
                }    # for ($col=0...)
                print '    </tr>
';
            }    # for ($row=0...)

            close RESULTS;

            print "
   </table>
";
        }    # if ($range > $min_range)

        #    Min results: $min_r<br>
        #    Max results: $max_r<br>
        #    Range:       $range<br>
        #    Minimum Z: $min_z<br>
        #    Maximum Z: $max_z

        print "
   Range: $range ($min_r to $max_r)
";
        if ( $range > $min_range ) {
            print "   <br>
   <form name='production'><input type='text' name='prod' readonly> [row, col]: $produnit produced</form>
   <br>
   <table cellpadding=0 cellspacing=0 width=25%>
    <tr>
     <td colspan=100 align=left>$min_r</td>
     <td colspan=55>&nbsp;&nbsp;</td>
     <td colspan=100 align=right>$max_r</td>
    </tr>
    <tr>
";

###### PRODUCTION HISTOGRAM START #####

            for ( $his = 0 ; $his < 256 ; $his++ ) {
                $real  = $min_r + ( $range * $his / 255 );
                $z_hex = sprintf "%lx", $his;

                #       $color='#00'.$z_hex.'00';
                #       $color='#000'.$z_hex.'00' if (length ($z_hex) == 1);
                if ( $real < 0 ) {    # red
                    $color = $z_hex . '0000';
                    $color = '#0' . $z_hex . '0000' if ( length($z_hex) == 1 );
                }
                else {                # green
                    $color = '#00' . $z_hex . '00';
                    $color = '#000' . $z_hex . '00' if ( length($z_hex) == 1 );
                }
                print
"     <td height='5' bgcolor='$color' onClick=\"document.production.prod.value='$real [@histo[$his]]'\"></td>\n";
            }    # for ($his=0...)
#########################
#print '
#   </tr>
#   <tr>
#';
#     for ($his=0;$his<256;$his++) {
#       print "     <td valign='top'><img src='black.gif' width='2' height='@histo[$his]' onClick=\"window.status='@histo[$his]'\"></td>\n";
#     }		# for ($his=0...)
#########################
            print '
   </tr>
   <tr>
    <td height="8"></td>
   </tr>
   <tr>
   </tr>
  </table>
';
        }    # if ($range > $min_range)
##### HISTOGRAM END #####
    }    # if (-e $results_prod_File)
    else {
        print "     Production results not found<br>\n";
    }

###  end production results

#$line = <RESULTS>;
#@averages = split ' ',$line;
#print $line;
#print "<br>Average value of dry ravel production @averages[0] kg<br>
#Average value of mass variation of dry ravel in each element @averages[1] kg<br>
#Average value of dry ravel deposition in each element @averages[2] kg<br>\n";

##############################################
#############################################
############################################

    #  close FIG;
}    # if (-e $dem)
else {
    print "Can't open $demfilename<br><br>";
}
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################

print "
  <br>Working ID: $unique
 </body>
</html>
";
