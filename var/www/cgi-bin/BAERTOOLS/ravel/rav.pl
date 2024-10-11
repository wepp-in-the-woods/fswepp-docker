#!/usr/bin/perl

use warnings;
use CGI;
use CGI qw(escapeHTML);
use MoscowFSL::FSWEPP::FsWeppUtils qw(printdate get_version);

my $cgi = new CGI;

#
#  rav.pl -- Ravel workhorse
#

my $version = get_version(__FILE__);

my $debug = 1;

# Reads user input from ravel.pl,
# Metric units only at present
# David Hall, USDA Forest Service, Rocky Mountain Research Station, Moscow

#=========================================================================

#####  Read user input parameters  #####
$description          = escapeHTML( $cgi->param('description') );
$vegetationSize       = escapeHTML( $cgi->param('stemsize') ) + 0;
$vegetationDensity    = escapeHTML( $cgi->param('density') ) + 0;
$fireImpactDepth      = escapeHTML( $cgi->param('brndep') ) + 0;
$staticFrictionAngle  = escapeHTML( $cgi->param('static') ) + 0;
$kineticFrictionAngle = escapeHTML( $cgi->param('kinetic') ) + 0;
$bulkDensity          = escapeHTML( $cgi->param('bulk') ) + 0;
$DEMfile              = $cgi->upload('uploadFileName');

$me    = escapeHTML( $cgi->param('me') );      # DEH 05/24/2000
$units = escapeHTML( $cgi->param('units') );

#####  Set other parameters values  #####

$unique            = 'ravel' . '-' . $$;
$working           = '../working';
$temp_base         = "$working/$unique";
$temp_html_base0   = "/srv/www/htdocs/fswepp/working/$unique";
$temp_html_base1   = "/fswepp/working/$unique";
$paramFile         = $temp_base . '.paraminput.txt';
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
    $cellsize_m          = $cellsize;
    $minMassOut_m        = $minMassOut;
    $vegetationSize_m    = $vegetationSize;
    $vegetationDensity_m = $vegetationDensity;
    $fireImpactDepth_m   = $fireImpactDepth;
    $cellsize_f          = $cellsize * 3.28;
    $minMassOut_f        = $minMassOut / 28.35;
    $vegetationSize_f    = $vegetationSize / 2.54;
    $vegetationDensity_f = $vegetationDensity;
    $fireImpactDepth_f   = $fireImpactDepth / 2.54;
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
    $cellsize_m          = $cellsize / 3.28;
    $minMassOut_m        = $minMassOut * 28.35;
    $vegetationSize_m    = $vegetationSize * 2.54;
    $vegetationDensity_m = $vegetationDensity;
    $fireImpactDepth_m   = $fireImpactDepth * 2.54;
}

print "  </script>
 </head>
    
 <body>
  <font size=2 face='trebuchet, tahoma, arial'>
  <table width=100% bgcolor='green'>
   <tr>
    <th>
     <font face='trebuchet, tahoma, arial' color='gold'>
      RMRS Ravel
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
DEM file:       $DEMfile<br>";
}
print "  <h4>$description</h4>
  <table border=1>
   <tr>
    <th colspan=3 bgcolor='green'><font face='trebuchet, tahoma, arial' size=2 color='gold'>User inputs</th>
   </tr>
   <tr>
    <th align=right bgcolor='green'><font color='gold' face='trebuchet, tahoma, arial' size=2>Vegetation size</font></th>
    <td><font face='trebuchet, tahoma, arial' size=2>$vegetationSize $lengthunit</font></td>
   </tr>
   <tr>
    <th align=right bgcolor='green'><font color='gold' face='trebuchet, tahoma, arial' size=2>Vegetation density</font></th>
    <td><font face='trebuchet, tahoma, arial' size=2>$vegetationDensity $densityunit</font></td>
   </tr>
   <tr>
    <th align=right bgcolor='green'><font color='gold' face='trebuchet, tahoma, arial' size=2>Fire impact depth</font></th>
    <td><font face='trebuchet, tahoma, arial' size=2>$fireImpactDepth $lengthunit</font></td>
   </tr>
   <tr>
    <th align=right bgcolor='green'><font color='gold' face='trebuchet, tahoma, arial' size=2>Bulk density</font></th>
    <td><font face='trebuchet, tahoma, arial' size=2>$bulkDensity $bulkdensityunit</font></td>
   </tr>
   <tr>
    <th align=right bgcolor='green'><font color='gold' face='trebuchet, tahoma, arial' size=2>Static friction angle</font></th>
    <td><font face='trebuchet, tahoma, arial' size=2>$staticFrictionAngle $angleunit</font></td>
   </tr>
   <tr>
    <th align=right bgcolor='green'><font color='gold' face='trebuchet, tahoma, arial' size=2>Kinetic friction angle</font></th>
    <td><font face='trebuchet, tahoma, arial' size=2>$kineticFrictionAngle $angleunit</font></td>
   </tr>
   <tr>
    <th align=right bgcolor='green'><font color='gold' face='trebuchet, tahoma, arial' size=2>DEM file</font></th>
    <td><font face='trebuchet, tahoma, arial' size=2>$DEMfile</font></td>
   </tr>
  </table>
";

#######################################
###       check out DEM file        ###
#######################################

# If you use 'strict', then Perl will complain when you try to use a string as a filehandle.
# You can get around this by placing the file reading code in a block containing the 'no strict' pragma.
# More seriously, it is possible for the remote user to type garbage into the upload field,
# in which case what you get from param() is not a filehandle at all, but a string.
# To be safe, use the upload() function (new in version 2.47).
# When called with the name of an upload field, upload() returns a filehandle-like object,
# or undef if the parameter is not a valid filehandle.
#     $fh = upload('uploaded_file');
# https://perldoc.perl.org/CGI.html#CREATING-A-FILE-UPLOAD-FIELD

#   $DEM = upload('uploadFileName');

# $DEMfile = $cgi->upload('uploadFileName');
# $DEMfile=~m/^.*(\\|\/)(.*)/; # strip the remote path and keep the filename

# There are occasionally problems involving parsing the uploaded file.
# This usually happens when the user presses "Stop" before the upload is finished.
# In this case, CGI.pm will return undef for the name of the uploaded file and set cgi_error()
# to the string "400 Bad request (malformed multipart POST)".
# This error message is designed so that you can incorporate it into a status code to be sent to the browser.
# Example:
# https://perldoc.perl.org/CGI.html#CREATING-A-FILE-UPLOAD-FIELD

if ( !$DEMfile && cgi_error ) {
    print header( -status => cgi_error );
    exit 0;
}

# When a file is uploaded, the browser usually sends along some information along with it in the format of headers.
# The information usually includes the MIME content type.
# Future browsers may send other information as well (such as modification date and size).
# To retrieve this information, call uploadInfo().
# It returns a reference to a hash containing all the document headers.
# https://perldoc.perl.org/CGI.html#CREATING-A-FILE-UPLOAD-FIELD

#	       $filename = param('uploaded_file');
#	       $type = uploadInfo($filename)->{'Content-Type'};
#	       unless ($type eq 'text/html') {
#		  print "HTML FILES ONLY!";
#	       }

if ($DEMfile) {

    print "File name: $DEMfile<br>";

    $badDEM = 0;
    $line1  = <$DEMfile>;
    print "First line: $line1<br>";
    if ( index( $line1, ' ' ) < 1 ) { $badDEM = 1 }
    else {
        @words  = split ' ', $line1, 2;
        $badDEM = @words[0] !~ /ncols/i;
        print "$badDEM<br>";
    }
    if ( !$badDEM ) {
        $line2  = <$DEMfile>;
        $spacer = index( $line2, ' ' );
        print "First space in line 2 is at $spacer<br>\n";
        if ( index( $line2, ' ' ) < 1 ) { $badDEM = 1 }
        else {
            print "Second line: $line2<br>";
            @words  = split ' ', $line2, 2;
            $badDEM = @words[0] !~ /nrows/i;
            print "$badDEM<br>";
        }
    }
}
if ( !$DEMfile || $badDEM ) {
    print("<p><strong class=\"error\">Error:</strong> Invalid DEM file.</p>");
    $successful = 0;
    print(
"<p><strong class=\"error\">Request not processed.</strong> Press the \"Back\" button and try again.<br />"
    );
    die;
}

# copy file to working space $demfilename

open NEWDEM, ">$demfilename";
print NEWDEM $line1;
print NEWDEM $line2;
while (<$DEMfile>) {
    print NEWDEM $_;
}
close NEWDEM;
close $DEMfile;

#    print "<p>Uploaded data:  </p>";

#    $allowed_ext = "txt";   # These are the allowed extensions of the files that are uploaded
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

# $encode=1;

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
    $num_cols = $ncols - 1;

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
    $num_rows = $rows - 1;
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
$num_cols $cols columsn<br>
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
    <h4>$num_cols x $num_rows</h4>
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

        for ( $col = 0 ; $col <= $num_cols ; $col++ ) {
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
"     <td width=6 height=5 bgcolor='$color' onClick=\"window.status='[$rows, $col]: $val'\"></td>\n";
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
    </tr>
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
   <table cellpadding=0 cellspacing=0>
    <tr>
     <td colspan=100 align=left>$min_elev</td>
     <td colspan=55>m</td>
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
"     <td height='10' bgcolor='$color' onClick=\"window.status='$real'\"></td>\n";
    }
    print '    </tr>
    <tr>
';
    for ( $his = 0 ; $his < 256 ; $his++ ) {

#      print "     <td valign='bottom'><img src='black.gif' width='2' height='@histo[$his]' alt='$his: $histo[$his]' border=0></td>\n";
        print
"     <td valign='top'><img src='/black.gif' width='2' height='@histo[$his]' onClick=\"window.status='@histo[$his]'\"></td>\n";
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
   </tr>
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

    print '<br>starting simulation ... ';

    $time_start = time;

    `./ravel $paramFile $demfilename >$stdout0 2>$stderr0`;
    $time_end = time;
    $time_dif = $time_end - $time_start;

    print "[$time_dif seconds] ";

    print " ...finished simulation<br>
";
    if ( -s $stderr0 > 1 ) {
        print '[<a href="javascript:void(showSTDERR())">STDERR</a>]';
    }
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

        $_ = <RESULTS>;    # nrows
        $_ = <RESULTS>;    # ncols
        $_ = <RESULTS>;    # xllcorner
        $_ = <RESULTS>;    # yllcorner
        $_ = <RESULTS>;    # cellsize
        $_ = <RESULTS>;    # nodata_value

        $min_r = 999999;
        $max_r = -999999;
        for ( $row = 0 ; $row < $num_rows ; $row++ ) {
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

        print "$cols columns\n";
        print "Min results $min_res\tMax results $max_res\n";

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
                  ;   # $value = sprintf ('%d',255*(@cell[$col]-$min_r)/$range);
                $z_hex = sprintf "%lx", $z;
                @histo[$z] += 1;     # 060922 DEH
                if ( $val < 0 ) {    # red
                    $color = $z_hex . '0000';
                    $color = '#0' . $z_hex . '0000' if ( length($z_hex) == 1 );
                }
                else {               # green
                    $color = '#00' . $z_hex . '00';
                    $color = '#000' . $z_hex . '00' if ( length($z_hex) == 1 );
                }
                $min_z = $z if ( $z < $min_z );
                $max_z = $z if ( $z > $max_z );
                if ($encode) {
                    print
"     <td width=6 height=5 bgcolor='$color' onClick=\"window.status='[$row, $col]: $val'\"></td>\n";
                }
                else {
                    print "     <td width=6 height=5 bgcolor='$color'></td>\n";
                }
            }    # for ($col=0...)
            print '    </tr>
';
        }    # for ($row=0...)

        close RESULTS;

        print "
    </tr>
   </table>
";

        #    Min results: $min_r<br>
        #    Max results: $max_r<br>
        #    Range:       $range<br>
        #    Minimum Z: $min_z<br>
        #    Maximum Z: $max_z
        print "
   Range: $range grams ($min_r to $max_r)
   <br>
   <table cellpadding=0 cellspacing=0>
    <tr>
     <td colspan=100 align=left>$min_r</td>
     <td colspan=55></td>
     <td colspan=100 align=right>$max_r</td>
    </tr>
    <tr>
";

###### HISTOGRAM START #####

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
"     <td height='5' bgcolor='$color' onClick=\"window.status='$real [@histo[$his]]'\"></td>\n";
        }    # for ($his=0...)

#print '
#   </tr>
#   <tr>
#';
#     for ($his=0;$his<256;$his++) {
#       print "     <td valign='top'><img src='black.gif' width='2' height='@histo[$his]' onClick=\"window.status='@histo[$his]'\"></td>\n";
#     }		# for ($his=0...)
#
        print '
   </tr>
   <tr>
    <td height="8"></td>
   </tr>
   <tr>
   </tr>
  </table>
';

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

        $_ = <RESULTS>;    # nrows
        $_ = <RESULTS>;    # ncols
        $_ = <RESULTS>;    # xllcorner
        $_ = <RESULTS>;    # yllcorner
        $_ = <RESULTS>;    # cellsize
        $_ = <RESULTS>;    # nodata_value

        $min_r = 999999;
        $max_r = -999999;
        for ( $row = 0 ; $row < $num_rows ; $row++ ) {
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

        print "$cols columns\n";
        print "Min results $min_res\tMax results $max_res\n";

        print "
   <table border=0 cellpadding=0 cellspacing=0>
";

        $min_z = 999999;
        $max_z = -999999;
        @histo = (0) x 255;    # 060922 DEH

        # open RESULTS, '<working/pointoutput.xls';
        open RESULTS, "<$results_prod_File";

        $title = <RESULTS>;
        $_     = <RESULTS>;    # ncols
        $_     = <RESULTS>;    # nrows
        $_     = <RESULTS>;    # xllcorner
        $_     = <RESULTS>;    # yllcorner
        $_     = <RESULTS>;    # cellsize
        $_     = <RESULTS>;    # nodata_value
        $_     = <RESULTS>;

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
                  ;   # $value = sprintf ('%d',255*(@cell[$col]-$min_r)/$range);
                $z_hex = sprintf "%lx", $z;
                @histo[$z] += 1;     # 060922 DEH
                if ( $val < 0 ) {    # red
                    $color = $z_hex . '0000';
                    $color = '#0' . $z_hex . '0000' if ( length($z_hex) == 1 );
                }
                else {               # green
                    $color = '#00' . $z_hex . '00';
                    $color = '#000' . $z_hex . '00' if ( length($z_hex) == 1 );
                }
                $min_z = $z if ( $z < $min_z );
                $max_z = $z if ( $z > $max_z );
                if ($encode) {
                    print
"     <td width=6 height=5 bgcolor='$color' onClick=\"window.status='[$row, $col]: $val'\"></td>\n";
                }
                else {
                    print "     <td width=6 height=5 bgcolor='$color'></td>\n";
                }
            }    # for ($col=0...)
            print '    </tr>
';
        }    # for ($row=0...)

        close RESULTS;

        print "
    </tr>
   </table>
";

        #    Min results: $min_r<br>
        #    Max results: $max_r<br>
        #    Range:       $range<br>
        #    Minimum Z: $min_z<br>
        #    Maximum Z: $max_z
        print "
   Range: $range grams ($min_r to $max_r)
   <br>
   <table cellpadding=0 cellspacing=0>
    <tr>
     <td colspan=100 align=left>$min_r</td>
     <td colspan=55></td>
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
"     <td height='5' bgcolor='$color' onClick=\"window.status='$real [@histo[$his]]'\"></td>\n";
        }    # for ($his=0...)

#print '
#   </tr>
#   <tr>
#';
#     for ($his=0;$his<256;$his++) {
#       print "     <td valign='top'><img src='black.gif' width='2' height='@histo[$his]' onClick=\"window.status='@histo[$his]'\"></td>\n";
#     }		# for ($his=0...)
#
        print '
   </tr>
   <tr>
    <td height="8"></td>
   </tr>
   <tr>
   </tr>
  </table>
';

##### HISTOGRAM END #####
    }    # if (-e $results_prod_File)
    else {
        print "     Production results not found<br>\n";
    }

###  end production results

#$line = <RESULTS>;
#@averages = split ' ',$line;
#print $line;
#print "<br>Average value of dry ravel production @averages[0] g<br>
#Average value of mass variation of dry ravel in each element @averages[1] g<br>
#Average value of dry ravel deposition in each element @averages[2] g<br>\n";

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

# ------------------------ subroutines ---------------------------
