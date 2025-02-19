#!/usr/bin/perl

use warnings;
use CGI;
use CGI qw(escapeHTML);
use MoscowFSL::FSWEPP::FsWeppUtils qw(printdate);

my $cgi = new CGI;

#
#  ravelrat-ca.pl -- Ravel workhorse
#

## BEGIN HISTORY ##############################
# FS RavelRAT-CA Results history
$version =
  '2013.03.28';    # Modify color math for deposition and production graphics

#  $version='2011.06.08';	# Complete graphs with more functionality
#  $version='2011.05.27';	# More results, average depth for maximum cell, better graphs synchronized
#  $version='2011.04.22';	# Report more statistics, show zero production and deposition as white -- Earth Day 2011
#  $version='2010.10.26';	# scan CPP results for version, UTM, errors, datum, etc., add reference Google Map
#  $version='2010.10.19';	# present DEM, DEPOSITION, and PRODUCTION grid values
#  $version='2010.10.18';	# put lat and long in order (for N and E hemispheres), handle DMS entries for latitude and longitude, do some number-checking for latitude and longitude (isNumber)
#  $version='2010.09.01';	# California DEMs
#  $version='2010.03.15';	#
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

$description       = $cgi->param('description');
$vegetationSize    = $cgi->param('stemsize') + 0;
$vegetationDensity = $cgi->param('density') + 0;
$fireImpactDepth =
  $cgi->param('brndep') / 1000;    # convert mm from input to m for model
$staticFrictionAngle  = $cgi->param('static') + 0;
$kineticFrictionAngle = $cgi->param('kinetic') + 0;
$bulkDensity          = $cgi->param('bulk') + 0;

$lat1 = $cgi->param('bndlat1');    # "S"
$lat2 = $cgi->param('bndlat2');    # "N"
$lon1 = $cgi->param('bndlon1');    # "W"
$lon2 = $cgi->param('bndlon2');    # "E"

$units = $cgi->param('units');

#####  Set other parameters values  #####

# *******************************

$unique            = 'ravel' . '-' . $$;
$working           = 'working';
$temp_base         = "$working/$unique";
$temp_cgi_base0    = "/var/www/cgi-bin/BAERTOOLS/ravel/working/$unique";
$temp_cgi_base1    = "/cgi-bin/BAERTOOLS/ravel/working/$unique";
$temp_html_base0   = "/var/www/htdocs/BAERTOOLS/ravel/working/$unique";
$temp_html_base1   = "/BAERTOOLS/ravel/working/$unique";
$DEMparamfile      = $temp_base . '.DEMinput.txt';
$DEMerrorfile      = $temp_base . '.DEMerror.txt';
$DEMfile           = $temp_base . '.DEM';
$paramFile         = $temp_base . '.paraminput.txt';
$demfilename       = $temp_base . '.dem.txt';
$results_dep_File  = $temp_base . '.depgrd.txt';
$results_prod_File = $temp_base . '.prodgrd.txt';
$calibration_File  = "$temp_base.cal.txt";
$stdout0           = $temp_cgi_base0 . '.stdout.txt';
$stdout1           = $temp_cgi_base1 . '.stdout.txt';
$stderr0           = $temp_cgi_base0 . '.stderr.txt';
$stderr1           = $temp_cgi_base1 . '.stderr.txt';

# ########### RUN RAVEL ###########

print "Content-type: text/html\n\n";

print '<html>
 <head>
  <title>FS RavelRat results for ', $unique, '</title>
  <style type="text/css">
   <!--
    P.Reference {
      margin-top:0pt;
      margin-left:.3in;
      text-indent:-.3in;
    }
   -->
  </style>
  <script language = "JavaScript" type="TEXT/JAVASCRIPT">
  

olddcol=0; olddrow=0;
oldpcol=0; oldprow=0;

   function ElevClick(row,col,val,unit) {
     document.getElementById("elevrcv").innerHTML="<b>"+val+"</b> "+unit+" elevation at row <b>"+row+"</b> col <b>"+col+"</b>";
   }

   function DepoClick(row,col,val,depunit,unique) {
// get depunit and unique from somewhere
//     var oldrow;
//     var oldcol;
     var myLink;
     var what;
     document.deposition.depos.value="["+row+", "+col+"]: "+val+" "+depunit
     myLink="/BAERTOOLS/ravel/DEMdepGraphXYS.php?file="+unique+"&y="+row+"&s=1"
     document.ELEVdepGraphWE.src=myLink
     myLink="/BAERTOOLS/ravel/DEMdepGraphXYS.php?file="+unique+"&x="+col+"&s=1"
     document.ELEVdepGraphNS.src=myLink
     document.getElementById("cell_dep").innerHTML=val+" "+depunit+" deposition at row "+row+" col "+col;

if (olddrow != undefined) { document.getElementById("r"+olddrow).style.backgroundColor="tan" }
if (olddcol != undefined) { document.getElementById("c"+olddcol).style.backgroundColor="tan" }
     what = "r"+row;
     document.getElementById(what).style.backgroundColor="#ff0000"
     olddrow = row;
     what = "c"+col;
     document.getElementById(what).style.backgroundColor="#ff0000"
     olddcol = col;
   }

   function DepHover(row,col,val,unit) {
// get depunit from somewhere
      document.getElementById("deprcv").innerHTML="<b>"+val+"</b> "+unit+" deposition at row <b>"+row+"</b> column <b>"+col+"</b>"
   }

   function DepHistCount(val) {
      document.getElementById("dep_hist_count").innerHTML=val+" cells"
   }

   function ProdHistCount(val) {
      document.getElementById("prod_hist_count").innerHTML=val+" cells"
   }

   function ProdHover(row,col,val,unit) {
// get produnit from somewhere
      document.getElementById("prodrcv").innerHTML="<b>"+val+"</b> "+unit+" production at row <b>"+row+"</b> column <b>"+col+"</b>"
   }

   function ProdClick(row,col,val,units,unique) {
//    document.production.prod.value="["+row+", "+col+"]: "+val+" "+produnit
//    myLink="/BAERTOOLS/ravel/DEMprodGraph.php?file="+unique+"&x="+row
//    document.ELEVprodGraphWE.src=myLink
//    myLink="/BAERTOOLS/ravel/DEMprodGraph.php?file="+unique+"&y="+col
//    document.ELEVprodGraphNS.src=myLink

//     var oldrow;
//     var oldcol;
     var myLink;
     var what;
//   document.production.prod.value="["+row+", "+col+"]: "+val+" "+units
     myLink="/BAERTOOLS/ravel/DEMprodGraphXYS.php?file="+unique+"&y="+row+"&s=1"
     document.ELEVprodGraphWE.src=myLink
     myLink="/BAERTOOLS/ravel/DEMprodGraphXYS.php?file="+unique+"&x="+col+"&s=1"
     document.ELEVprodGraphNS.src=myLink
     document.getElementById("cell_prod").innerHTML=val+" "+units+" production at row "+row+" col "+col;

if (oldprow != undefined) { document.getElementById("pr"+oldprow).style.backgroundColor="tan" }
if (oldpcol != undefined) { document.getElementById("pc"+oldpcol).style.backgroundColor="tan" }
     what = "pr"+row;
     document.getElementById(what).style.backgroundColor="#347235"
     oldprow = row;
     what = "pc"+col;
     document.getElementById(what).style.backgroundColor="#347235"
     oldpcol = col;
//   document.getElementById("cell_prod").innerHTML=val+" "+units+" production at row "+row+" col "+col;
   }

   function DepoHistClick(lower,upper,val,depunit) {
//     document.deposition.depos.value="["+row+", "+col+"]: "+val+" "+depunit
//     myLink="/BAERTOOLS/ravel/DEMdepGraphXY.php?file="+unique+"&y="+row
//   alert (myLink)
//     document.ELEVdepGraphWE.src=myLink
//     myLink="/BAERTOOLS/ravel/DEMdepGraphXY.php?file="+unique+"&x="+col
//   alert (myLink)
//     document.ELEVdepGraphNS.src=myLink
     document.getElementById("bin_count").innerHTML=val+" cell(s) with deposition between "+lower+" and "+upper+" "+depunit;
//   document.deposition.depos_hist.value="[', $real, ' &mdash; ', $realh,
  ' $depunit]: ', @histo[$his], '"
   }

   function ElevHistClick(lower,upper,val,unit) {
     document.getElementById("elev_bin_count").innerHTML=val+" cell(s) with elevation between "+lower+" and "+upper+" "+unit;
   }

   function ProdHistClick(lower,upper,val,unit) {
     document.getElementById("p_bin_count").innerHTML=val+" cell(s) with production between "+lower+" and "+upper+" "+unit;
//   document.production.prod_hist.value="[$real &mdash; $realh $produnit]: @histo[$his]"
   }

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

 <body link=black vlink=black alink=crimson>
  <font size=2 face='trebuchet, tahoma, arial'>
  <table width=100%>
   <tr>
    <th bgcolor=green>
     <font face='trebuchet, tahoma, arial' color='gold'>
      FS RavelRAT-CA $version
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
  </table>
";

#
# convert latitudes & longitudes from o ' " to decimal degrees if necessary
#

$lat1 = dms_to_dec($lat1);
$lat2 = dms_to_dec($lat2);
$lon1 = dms_to_dec($lon1);
$lon2 = dms_to_dec($lon2);

#
# ensure that latitudes and longitudes are in correct order
#

if ( isNumber($lat1) && isNumber($lat2) && isNumber($lon1) && isNumber($lon2) )
{

    if ( $lat1 > 0 && $lat2 > 0 ) {    # N hemisphere
        if ( $lat1 < $lat2 ) {
            $templat = $lat1;
            $lat1    = $lat2;
            $lat2    = $templat;
        }
    }
    if ( $lat1 < 0 && $lat2 < 0 ) {    # S hemisphere
    }
    if ( $lon1 > 0 && $lon2 > 0 ) {    # E hemisphere
        if ( $lon1 > $lon2 ) {
            $templat = $lon1;
            $lat1    = $lon2;
            $lon2    = $templat;
        }
    }
    if ( $lon1 < 0 && $lon2 < 0 ) {    # W hemisphere
    }

    #  if ($lat1 >= 0 and $lat2 <= 0) {}
    #  if ($lat1 <= 0 and $lat2 >= 0) {}
    #  if ($lon1 >= 0 and $lon2 <= 0) {}
    #  if ($lon1 <= 0 and $lon2 >= 0) {}

} # if (isNumber($lat1) && isNumber($lat2) && isNumber($lon1) && isNumber($lon2)) {
else {
    print "Bad lat/lon -- non-numeric<br>\n";
    goto footer;
}

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

# @results = <DEMresults>;
# print "<b>Messages from run_ca</b><br><hr>\n";
# print @results;
# print "<br>\n<br><br>\n";
#
#  $results_size = @results;
##  print scalar @results . " lines<br>\n";
#  print $results_size . " lines<br>\n";
$errors = 0;

#  for ($count=0; $count<$results_size; $count++) {
##    print "$count @results[$count]<br>\n";
#    $line = @results[$count];
#  }

while (<DEMresults>) {
    if (/UTMs/i)     { $UTMline             = $_ }
    if (/file/i)     { $fileLine            = $_ }
    if (/ERR:/)      { $error++; $errorLine = $_ }
    if (/Zone/i)     { $zoneLine            = $_ }
    if (/Version/i)  { $versionLine         = $_ }
    if (/Citation/i) { $citationLine        = $_ }
    if (/Datum/i)    { $datumLine           = $_ }
}

if ($errorLine) { print "<br><font color=crimson>$errorLine</font><br>\n" }

if ( $error <= 0 ) {    ###  skip to footer  ###

    # $utmzone = @results[2];

    # $utmzone = $zoneLine;

    $demfilename = $DEMfile;

    # die;

    $max_size = "1000000";    # 50000 is the same as 50kb

    ## Check Extension

    ## Check file type

    ## Check File Size

    $fileSize = -s $demfilename;

    # print "File size: $fileSize<br>\n";
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

        $range  = $max_elev - $min_elev;    # warn if ~0
        $rrange = $range;
        $range  = 1 if ( $range < 1 );

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

     #     $unique='ravel' . '-' . $$;
     #     $working = 'working';
     #     $temp_base = "$working/$unique";
     #     $temp_html_base0 = "/var/www/htdocs/BAERTOOLS/ravel/working/$unique";
     #     $temp_html_base1 = "/BAERTOOLS/ravel/working/$unique";
     #     $DEMparamfile = $temp_base . '.DEMinput.txt';
     #     $DEMerrorfile = $temp_base . '.DEMerror.txt';
     #     $DEMfile = $temp_base . '.DEM';
     #     $paramFile = $temp_base . '.paraminput.txt';
     #     $demfilename = $temp_base . '.dem.txt';
     #     $results_dep_File = $temp_base . '.depgrd.txt';
     #     $results_prod_File = $temp_base . '.prodgrd.txt';

        $retrievable_DEMfile_0  = $temp_html_base0 . '.DEM';
        $retrievable_depfile_0  = $temp_html_base0 . '.depgrd.txt';
        $retrievable_prodfile_0 = $temp_html_base0 . '.prodgrd.txt';

        $retrievable_DEMfile_1  = $temp_html_base1 . '.DEM';
        $retrievable_depfile_1  = $temp_html_base1 . '.depgrd.txt';
        $retrievable_prodfile_1 = $temp_html_base1 . '.prodgrd.txt';

        if ($debug) {
            print "
   cp $DEMfile $retrievable_DEMfile_0<br>
   cp $results_dep_File $retrievable_depfile_0<br>
   cp $results_prod_File $retrievable_prodfile_0<br>\n";
        }
        `cp $DEMfile $retrievable_DEMfile_0`;

        print "
  <br>
  <font face='trebuchet, tahoma, arial, sans serif'>

  <table width=100% bgcolor='lightgreen'>
   <tr>
    <th>
     <font face='trebuchet, tahoma, arial' color='black'>
      <a href='$retrievable_DEMfile_1' target='_DEM'>ELEVATION</a>
     </font>
    </th>
   </tr>
  </table>
  <h4>$num_rows rows x $num_cols columns</h4>
";
        print '

  <table border=5>
   <tr>
    <td>
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
            print '    <tr>
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

              #         $color='#00'.$val_hex.'00';
              #         $color='#000'.$val_hex.'00' if (length ($val_hex) == 1);
              #         $color='#000' . $val_hex . $val_hex;
                    $val_hex = '0' . $val_hex if ( length($val_hex) == 1 );
                    $color   = '#' . $val_hex . $val_hex . $val_hex;

        #         $color='#00'.$val_hex.'00' if (length ($val_hex) == 1);
        # print "     <td width=20 height=10 bgcolor='rgb(0,$level,0)'></td>\n";
                }

#       if ($encode) {print "     <td width=6 height=5 bgcolor='$color' onClick=\"document.elevation.elev.value='[$rows, $col]: $val m'\"></td>\n";}
                if ($encode) {
                    print
"     <td width=6 height=5 bgcolor='$color' onClick='ElevClick($rows,$col,$val,\"m\")'></td>\n";
                }
                else {
                    print "     <td width=6 height=5 bgcolor='$color'></td>\n";
                }
            }
            print '    </tr>
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

        $ranger = sprintf '%.3f', $rrange;

        print "
   <font face='trebuchet, tahoma, arial' color='black' size=-1>
   <span id='elevrcv'>[click chart for elevation]</span><br>
   Maximum elevation: <b>$max_elev</b> m<br>
   Minimum elevation: <b>$min_elev</b> m<br>
   Range: <b>$ranger</b> m<br>
   <br><hr>
   <span id='elev_bin_count'>[click on histogram axis below for histogram information]</span><br><br>
   <form name='elevation'>
    <input type='hidden' name='elev' readonly>
    <input type='hidden' name='elev_hist' readonly>
   </form>
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
            $real  = sprintf '%.2f', $real;
            $realh = $min_elev + ( $range * ( $his + 1 ) / 255 );
            $realh = sprintf '%.2f', $realh;
            $z_hex = sprintf "%lx",  $his;

            #      $color='#00'.$z_hex.'00';
            #      $color='#000'.$z_hex.'00' if (length ($z_hex) == 1);
            #         $z_hex = '0' . $z_hex if (length (
            $z_hex = '0' . $z_hex if ( length($z_hex) == 1 );
            $color = '#' . $z_hex . $z_hex . $z_hex;

            #       $z_hex='#00'.$z_hex if (length ($z_hex) == 1);
            #       $color='#000' . $z_hex . $z_hex;

#      print "     <td height='5' bgcolor='$color' onClick=\"document.elevation.elev_hist.value='[$real &mdash; $realh m]: @histo[$his]'\"></td>\n";
            print
"     <td height='5' bgcolor='$color' onClick='ElevHistClick($real,$realh,@histo[$his],\"m\")'></td>\n";
        }
        print '    </tr>
    <tr>
';
        for ( $his = 0 ; $his < 256 ; $his++ ) {

#      print "     <td valign='bottom'><img src='/black.gif' width='2' height='@histo[$his]' alt='$his: $histo[$his]' border=0></td>\n";
#      print "     <td valign='top'><img src='/fswepp/images/black.gif' width='2' height='@histo[$his]' onClick=\"document.elevation.elev_hist.value='@histo[$his]'\"></td>\n";
            print
"     <td valign='top'><img src='/fswepp/images/black.gif' width='2' height='@histo[$his]'></td>\n";
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

</td>
<td valign=top>
<iframe width='300' height='300' frameborder='0' scrolling='no' marginheight='0' marginwidth='0'
src='https://maps.google.com/maps?f=q
&amp;source=
&amp;t=p
&amp;doflg=ptk
&amp;hl=en
&amp;geocode=
&amp;q=$lat1,$lon1
&amp;sll=
&amp;spn=.01,.01
&amp;sspn=.01,.01
&amp;ie=UTF8
&amp;z=
&amp;ll=$lat1,$lon1
&amp;output=embed'></iframe>
  </td>
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

        print "<br>starting simulation ... ";

        $time_start = time;

     #    @timing = `time ./ravel $paramFile $demfilename >$stdout0 2>$stderr0`;
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
        print RaveLOG $ampm[$ampmi], "  ", $days[$wday], " ",
          $months[$mon], " ", $mday, ", ", $year + 1900, "\"\t";
        print RaveLOG "$lat1\t$lon1\t$lat2\t$lon2\t";
        print RaveLOG "$time_dif\t";
        print RaveLOG '"', $description, '"', "\n";
        close RaveLOG;

        print " ...finished simulation<br>
";

        #   open SO, "<$stdout";
        #    print "   Standard OUTPUT: <pre>\n";
        #    print <SO>;
        #    print "   </pre>\n<hr>";
        #   close SO;
        #   open SE, "<$stderr";
        #    print "   STANDARD ERROR: <pre>\n";
        #    print <SE>;
        #    print "   </pre>\n";
        #   close SE;

        if ( -s $stderr0 > 1 ) {
            print '[<a href="javascript:void(showSTDERR())">STDERR</a>]';
        }
        if ($debug) {
            if ( -s $stdout0 > 1 ) {
                print "
  <iframe src='get_results.py?fn=$unique.stdout.txt' width=750 height=50 frameborder=0 scrolling=yes>  </iframe>
";
            }
            if ( -s $stderr0 > 1 ) {
                print "
  <iframe src='get_results.py?fn=$unique.stderr.txt' width=750 height=50 frameborder=0 scrolling=yes>  </iframe>
";
            }
        }

########################################################################################
######################
        # Deposition results #
######################
########################################################################################

        `cp $results_dep_File $retrievable_depfile_0`;

        print "
  <table width=100% bgcolor='pink'>
   <tr>
    <th>
     <font face='trebuchet, tahoma, arial' color='black'>
      <a href='$retrievable_depfile_1' target='_dep'>DEPOSITION</a>
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

            $min_r       = 999999;
            $max_r       = -999999;
            $max_dep_row = 0;
            $max_dep_col = 0;
            for ( $row = 0 ; $row < $num_rows - 1 ; $row++ ) {
                $_    = <RESULTS>;
                @cell = split ' ', $_;
                for ( $col = 0 ; $col < $num_cols ; $col++ ) {
                    @cell[$col] = 0 if ( @cell[$col] < 0 );    # DEH 110422
                    $min_r      = @cell[$col] if ( @cell[$col] < $min_r );

                    #         $max_r = @cell[$col] if (@cell[$col] > $max_r);
                    if ( @cell[$col] > $max_r ) {
                        $max_r       = @cell[$col];
                        $max_dep_row = $row;
                        $max_dep_col = $col;
                    }
                }
            }
            $range = $max_r - $min_r;    # warn if ~0
            $min_r;
            $max_r;

            close RESULTS;

            # DEH 110422 start

            open STATS, "<$calibration_File";
            $minprod   = <STATS>;
            $maxprod   = <STATS>;
            $meanprod  = <STATS>;
            $stdevprod = <STATS>;
            $mindep    = <STATS>;
            $maxdep    = <STATS>;
            $meandep   = <STATS>;
            $stdevdep  = <STATS>;
            $cntprod   = <STATS>;
            $cntdep    = <STATS>;
            $cnt       = <STATS>;
            close STATS;

            # DEH 110422 end

            #    $num_rows=$rows-1;

            #    print "$cols columns\n";
            #    print "Min results $min_res\tMax results $max_res\n";

            $min_range = 0.01;
            if ( $range > $min_range ) {

                print "
<table border=5 bgcolor=pink>
 <tr>
  <td valign=top>

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
                        $val = 0 if ( $val < 0 );             # DEH 110422
                        $z   = ( $val - $min_r ) / $range;    ### div zero
                        $z   = 0 if ( $z < 0 );
                        $z   = 1 if ( $z > 1 );
                        $zz  = sprintf( '%d', 255 * $z )
                          ; # $value = sprintf ('%d',255*(@cell[$col]-$min_r)/$range);
                        @histo[$zz] += 1;    # 060922 DEH

                        #@#        $z = 1-$z;
                        $z = sprintf( '%d', 255 * $z )
                          ; # $value = sprintf ('%d',255*(@cell[$col]-$min_r)/$range);

                        #       $z_hex = sprintf "%lx", $z;			# DEH 2013.03.28
                        $z_hex = sprintf "%lx", 255 - $z;    # DEH 2013.03.28

                   #       $color='#00'.$z_hex.'00';
                   #       $color='#000'.$z_hex.'00' if (length ($z_hex) == 1);
                   #        $color='#'.$z_hex.'0000';			# DEH 2011.05.23
                   #        $color='#0'.$z_hex.'0000' if (length ($z_hex) == 1);

                        $color = '#ff' . $z_hex . $z_hex;    # DEH 2013.03.28

                   #        $color='#00'.$z_hex.'00';
                   #        $color='#000'.$z_hex.'00' if (length ($z_hex) == 1);
                        $color = '#ffffff' if ( $val == 0 );
                        $min_z = $z        if ( $z < $min_z );
                        $max_z = $z        if ( $z > $max_z );
                        if ($encode) {

#         print "     <td width=6 height=5 bgcolor='$color' onClick=\"document.deposition.depos.value='[$row, $col]: $val $depunit'\"></td>\n";}
#         print "     <td width=6 height=5 bgcolor='$color' onClick='DepoClick($row,$col,$val,\"$depunit\",\"$unique\")' onMouseover=\"document.getElementById('deprcv').innerHTML='[$row, $col]: $val $depunit'\"></td>\n";
#                            onMouseover=\"document.getElementById('deprcv').innerHTML='<b>$val</b> $depunit deposition at row <b>$row</b> column <b>$col</b>'\"></td>\n";
                            print
"     <td width=6 height=5 bgcolor='$color' onClick='DepoClick($row,$col,$val,\"$depunit\",\"$unique\")' onMouseover='DepHover($row,$col,$val,\"$depunit\")'></td>\n";
                        }
                        else {
                            print
"     <td width=6 height=5 bgcolor='$color'></td>\n";
                        }
                    }    # for ($col=0...)
                    if ( $row == $max_dep_row ) {    # DEH 110609
                        print
"     <td width=4 bgcolor=crimson id=\"r$row\"></td>\n"
                          ;                          # DEH 110525
                    }
                    else {
                        print
                          "     <td width=4 bgcolor=tan id=\"r$row\"></td>\n"
                          ;                          # DEH 110525
                    }

#      print "     <td bgcolor=crimson width=4 onClick=\"document.ELEVdepGraph.src='/BAERTOOLS/ravel/DEMdepGraph.php?file=$unique&x=$row'\"></td>\n";	# DEH 110422  ## link to php graphic here onClick
#      print "     <td width=25></td>\n";
                    print '    </tr>
';
                }    # for ($row=0...)
                print '    <tr>
';
                for ( $col = 0 ; $col < $num_cols ; $col++ ) {
                    if ( $col == $max_dep_col ) {    # DEH 110609
                        print
"     <td width=5 height=4 bgcolor=crimson id=\"c$col\"></td>\n";
                    }
                    else {
                        print
"     <td width=5 height=4 bgcolor=tan id=\"c$col\"></td>\n";
                    }
                }
                print '    </tr>
   </table>

';

                close RESULTS;

                #    Min results: $min_r<br>
                #    Max results: $max_r<br>
                #    Range:       $range<br>
                #    Minimum Z: $min_z<br>
                #    Maximum Z: $max_z

            }    # if ($range > $min_range)

            #  $meandep &nbsp; $stdevdep &nbsp; $cntdep<br>
            @meandep  = split( ' ', $meandep );
            @stdevdep = split( ' ', $stdevdep );
            @cntdep   = split( ' ', $cntdep );

            $depthmean = '';
            $depthmean = @meandep[1] if ( isNumber( @meandep[1] ) );

            $depth = $max_r / $bulkDensity / 100;

            print "    <font size=-1>
   <span id='deprcv'>[hover over chart for deposition]</span><br>
   <a href=\"javascript:DepoClick($max_dep_row,$max_dep_col,$max_r,'$depunit','$unique')\">Maximum deposition</a>
     <b>$max_r</b> $depunit at row <b>$max_dep_row</b> column <b>$max_dep_col</b><br>
   Minimum deposition: <b>$min_r</b> $depunit<br>
   Range: <b>$range</b> $depunit<br>
   Mean: <b>$depthmean</b> $depunit<br>
   Standard Deviation: <b>@stdevdep[1]</b><br>
   <b>@cntdep[1]</b> cell(s) with deposition<br>
   Maximum deposition depth: <b>$depth</b> m over 10 x 10 m cell<br>
";
            if ( $range > $min_range ) {
                print "
   <form name='deposition'>
    <input type='hidden' name='depos' readonly>
    <input type='hidden' name='depos_hist' readonly>
   </form>
   <span id='cell_dep'>[click on deposition plot above for deposition amounts]</span><br>
   <span id='bin_count'>[click on histogram axis below for histogram information]</span><br>
   <span id='dep_hist_count'></span><br><br>
   <table cellpadding=0 cellspacing=0 width=25%>
    <tr>
     <td colspan=100 align=left>$min_r</td>
     <td colspan=55>&nbsp;$depunit &nbsp;</td>
     <td colspan=100 align=right>$max_r</td>
    </tr>
    <tr>
";

###### DEPOSITION HISTOGRAM START #####

### Deposition histogram axis

                for ( $his = 0 ; $his < 256 ; $his++ ) {
                    $real  = $min_r + ( $range * $his / 255 );
                    $realh = $min_r + ( $range * ( $his + 1 ) / 255 );
                    $real  = sprintf '%.2f', $real;
                    $realh = sprintf '%.2f', $realh;
                    $z_hex = sprintf "%lx",  255 - $his;    # DEH 2013.03.28

                    #       $z_hex = sprintf "%lx", $his;			# DEH 2013.03.28
                    #      $color='#00'.$z_hex.'00';
                    #      $color='#000'.$z_hex.'00' if (length ($z_hex) == 1);
                    #       if ($real < 0) {			# red
                    #        $color=$z_hex.'0000';
                    $color = '#ff' . $z_hex . $z_hex;    # DEH 2013.03.28

#        $color='#0'.$z_hex.'0000' if (length ($z_hex) == 1);
#        $color='#ffffff' if ($real == 0);		# DEH 110422
#       }
#       else {					# green
#         $color=$z_hex.'0000';
#         $color='#0'.$z_hex.'0000' if (length ($z_hex) == 1);
#         $color='#00'.$z_hex.'00';
#         $color='#000'.$z_hex.'00' if (length ($z_hex) == 1);
#       }
#      print "     <td height='5' bgcolor='$color' onClick=\"document.deposition.depos_hist.value='[$real &mdash; $realh $depunit]: @histo[$his]'\">
                    print
"     <td height='5' bgcolor='$color' onClick='DepoHistClick($real,$realh,@histo[$his],\"$depunit\")'></td>\n";
                }    # for ($his=0...)

#######################
                print '   </tr>
   <tr>
';
                $heightScale = 1;
                $maxHisto    = 0;
                for ( $his = 1 ; $his < 256 ; $his++ ) {
                    $maxHisto = @histo[$his] if ( @histo[$his] > $maxHisto );
                }
                $heightScale = 2 if ( $maxHisto < 20 );
                print
"     <td valign='top'><img src='black.gif' width='2' height='2' onMouseover='DepHistCount(@histo[0])'></td>\n";
                for ( $his = 1 ; $his < 256 ; $his++ ) {
                    $height = $heightScale * @histo[$his];

#      print "     <td valign='top'><img src='black.gif' width='2' height='$height' onClick=\"window.status='@histo[$his]'\"></td>\n";
                    print
"     <td valign='top'><img src='black.gif' width='2' height='$height' onMouseover='DepHistCount(@histo[$his])'></td>\n";
                }    # for ($his=0...)
#######################
                print "
   </tr>
  </table>
  </td>
  <td valign=top>
   <img src='/BAERTOOLS/ravel/DEMdepGraphXYS.php?file=$unique&y=$max_dep_row&s=1' name='ELEVdepGraphWE'><br>
   <img src='/BAERTOOLS/ravel/DEMdepGraphXYS.php?file=$unique&x=$max_dep_col&s=1' name='ELEVdepGraphNS'><br>
  </td>
 </tr>
</table>
";
            }    # if ($range > $min_range)

##### DEPOSITION HISTOGRAM END #####
        }    # (-e $results_dep_File)
        else {
            print "    Deposition results not found<br>\n";
        }

##################################################################
######################
        # Production results #
######################
##################################################################

        `cp $results_prod_File $retrievable_prodfile_0`;

        print "
  <table width=100% bgcolor='#C3FDB8'>
   <tr>
    <th>
     <font face='trebuchet, tahoma, arial' color='black'>
      <a href='$retrievable_prodfile_1' target='_prod'>PRODUCTION</a>
     </font>
    </th>
   </tr>
  </table>
";

        if ( -e $results_prod_File ) {
            open RESULTS, "<$results_prod_File";

            # print "$num_rows x $num_cols<br>\n";

            $_ = <RESULTS>;    # ncols
            $_ = <RESULTS>;    # nrows
            $_ = <RESULTS>;    # xllcorner
            $_ = <RESULTS>;    # yllcorner
            $_ = <RESULTS>;    # cellsize
            $_ = <RESULTS>;    # nodata_value

            #     $min_r = 0;
            $min_r = 99999;
            $max_r = 0;

            #     $max_r0=-999999;						# DEH ?
            $max_prod_row = 0;
            $max_prod_col = 0;
            for ( $row = 0 ; $row < $num_rows - 1 ; $row++ ) {
                $_    = <RESULTS>;
                @cell = split ' ', $_;
                for ( $col = 0 ; $col < $num_cols ; $col++ ) {
                    @cell[$col] = 0 - @cell[$col];    # DEH 20110608
                    if ( @cell[$col] < $min_r && @cell[$col] > 0 )
                    {                                 # DEH 20110608
                        $min_r        = @cell[$col];
                        $min_prod_row = $row;
                        $min_prod_col = $row;
                    }

                    #         $max_r0= @cell[$col] if (@cell[$col] > $max_r0);
                    #         if((@cell[$col] > $max_r) && @cell[$col]<0) {
                    if ( ( @cell[$col] > $max_r ) && @cell[$col] > 0 )
                    {    # DEH 20110608
                        $max_r        = @cell[$col];
                        $max_prod_row = $row;
                        $max_prod_col = $col;
                    }
                }
            }
            $range = $max_r - $min_r;    # warn if ~0

            close RESULTS;

            #    $num_rows=$rows-1;

            #    print "$cols columns\n";
            #    print "Min results $min_res\tMax results $max_res\n";

            if ( $range > $min_range ) {

                print "
   <table border=1 bgcolor=#C3FDB8>
    <tr>
     <td valign=top>
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

                for ( $row = 0 ; $row < $num_rows ; $row++ ) {
                    $_    = <RESULTS>;
                    @cell = split ' ', $_;
                    print '    <tr>
';
                    for ( $col = 0 ; $col < $num_cols ; $col++ ) {

                        #       $val = @cell[$col];
                        $val = 0 - @cell[$col];    # DEH 20110608

                        #       $val = 0 if ($val < 0);		# DEH 110422
                        $z = ( $val - $min_r ) / $range;    ### div zero
                        $z = 0 if ( $z < 0 );
                        $z = 1 if ( $z > 1 );

#       $zz = sprintf ('%d',255*$z);	# $value = sprintf ('%d',255*(@cell[$col]-$min_r)/$range);
#       @histo[$z]+=1;			# 060922 DEH

                        $zz = sprintf( '%d', 255 * $z )
                          ; # $value = sprintf ('%d',255*(@cell[$col]-$min_r)/$range);
                        @histo[$zz] += 1;    # 060922 DEH

                        #       $z = 1-$z;
                        $z = sprintf( '%d', 255 * $z )
                          ; # $value = sprintf ('%d',255*(@cell[$col]-$min_r)/$range);
                        $z_hex = sprintf "%lx", 255 - $z;    # DEH 2013.03.28

#        if ($val < 0) {			# red	# DEH 110422
#          $color='#' .$z_hex.'0000';
#          $color='#0'.$z_hex.'0000' if (length ($z_hex) == 1);
#          $color='#ffffff' if ($val == 0);		# DEH 110422
#        }
#        else {					# green
#          $color='#00'.$z_hex.'00';			# DEH 2013.03.28
#          $color='#000'.$z_hex.'00' if (length ($z_hex) == 1);	# DEH 2013.03.28
                        $color = $z_hex . 'ff' . $z_hex;        # DEH 2013.03.28
                        $color = '#ffffff' if ( $val == 0 );    # DEH 110422

                        #        }
                        $min_z = $z if ( $z < $min_z );
                        $max_z = $z if ( $z > $max_z );
                        if ($encode) {

#         print "     <td width=6 height=5 bgcolor='$color' onClick=\"document.production.prod.value='[$row, $col]: $val $produnit'\"></td>\n";
#         print "     <td width=6 height=5 bgcolor='$color' onClick='ProdClick($row,$col,$val,\"$depunit\",\"$unique\")' onMouseover=\"document.getElementById('prodrcv').innerHTML='<b>$val</b> $depunit production at row <b>$row</b> column <b>$col</b>'\"></td>\n";
#         print "     <td width=6 height=5 bgcolor='$color' onClick='ProdClick($row,$col,$val,\"$depunit\",\"$unique\")' onMouseover=\"document.getElementById('prodrcv').innerHTML='<b>$val</b> $depunit production at row <b>$row</b> column <b>$col</b>'\"></td>\n";
                            print
"     <td width=6 height=5 bgcolor='$color' onClick='ProdClick($row,$col,$val,\"$depunit\",\"$unique\")' onMouseover='ProdHover($row,$col,$val,\"$produnit\")'></td>\n";
                        }
                        else {
                            print
"     <td width=6 height=5 bgcolor='$color'></td>\n";
                        }
                    }    # for ($col=0...)
                    if ( $row == $max_prod_row ) {
                        print
"     <td width=4 bgcolor=#347235 id=\"pr$row\"></td>\n"
                          ;    # DEH 110525
                    }
                    else {
                        print
                          "     <td width=4 bgcolor=tan id=\"pr$row\"></td>\n"
                          ;    # DEH 110525
                    }

                    #      print '<td bgcolor=red width=2></td>';
                    print '    </tr>
';
                }    # for ($row=0...)

                print '    <tr>
';
                for ( $col = 0 ; $col < $num_cols ; $col++ ) {
                    if ( $col == $max_prod_col ) {
                        print
"     <td width=5 height=4 bgcolor=#347235 id=\"pc$col\"></td>\n";
                    }
                    else {
                        print
"     <td width=5 height=4 bgcolor=tan id=\"pc$col\"></td>\n";
                    }
                }
                print '    </tr>
   </table>

';

                close RESULTS;

            }    # if ($range > $min_range)

            #    Min results: $min_r<br>
            #    Max results: $max_r<br>
            #    Range:       $range<br>
            #    Minimum Z: $min_z<br>
            #    Maximum Z: $max_z

            @meanprod  = split( ' ', $meanprod );
            @stdevprod = split( ' ', $stdevprod );
            @cntprod   = split( ' ', $cntprod );

            $prod_depth = $max_r / $bulkDensity / 100;
            $prodmean   = '';
            $prodmean   = @meanprod[1] if ( isNumber( @meanprod[1] ) );

            print "    <font size=-1>
   <span id='prodrcv'>[hover over chart for production]</span><br>
   <a href=\"javascript:ProdClick($max_prod_row,$max_prod_col,$max_r,'$depunit','$unique')\">Maximum production</a>
    <b>$max_r</b> $produnit at row <b>$max_prod_row</b> column <b>$max_prod_col</b><br>
   Minimum production: <b>$min_r</b> $produnit<br>
   Production range: <b>$range</b> $produnit<br>
   Mean: <b>$prodmean</b> $produnit<br>
   Standard Deviation: <b>@stdevprod[1]</b><br>
   <b>@cntprod[1]</b> cell(s) with production<br>
   Maximum production depth: $prod_depth m spread over 10 x 10 m cell<br>
";

            #    print "
            #   Range: $range ($min_r to $max_r)<br>
            #   Mean: @meanprod[1]<br>
            #   Std Dev: @stdevprod[1]<br>
            #   @cntprod[1] cells with production<br>
            #";

            if ( $range > $min_range ) {

#   <form name='production'><input type='text' name='prod' readonly> [row, col]: production &mdash; click on production grid above<br>
#                           <input type='text' name='prod_hist' readonly> [production range]: count &mdash; click on histogram axis below</form>
                print "
   <form name='production'>
    <input type='hidden' name='prod' readonly>
    <input type='hidden' name='prod_hist' readonly>
   </form>
   <span id='cell_prod'>[click on production plot above for production amounts]</span><br>
   <span id='p_bin_count'>[click on histogram axis below for histogram information]</span><br>
   <span id='prod_hist_count'></span><br><br>

   <table cellpadding=0 cellspacing=0 width=25%>
    <tr>
     <td colspan=100 align=left>$min_r</td>
     <td colspan=55>&nbsp;$produnit &nbsp;</td>
     <td colspan=100 align=right>$max_r</td>
    </tr>
    <tr>
";

###### PRODUCTION HISTOGRAM START #####

                for ( $his = 0 ; $his < 256 ; $his++ ) {
                    $real  = $min_r + ( $range * $his / 255 );
                    $real  = sprintf '%.2f', $real;
                    $realh = $min_r + ( $range * ( $his + 1 ) / 255 );
                    $realh = sprintf '%.2f', $realh;
                    $z_hex = sprintf "%lx",  255 - $his;    # DEH 2013.03.28

#      $z_hex = sprintf "%lx", $his;					# DEH 2013.03.28
#       $color='#00'.$z_hex.'00';
#       $color='#000'.$z_hex.'00' if (length ($z_hex) == 1);
#        if ($real < 0) {				# red
#          $color=$z_hex.'0000';
#          $color='#0'.$z_hex.'0000' if (length ($z_hex) == 1);
#        }
#        else {					# green
#          $color='#00'.$z_hex.'00';					# DEH 2013.03.28
#          $color='#000'.$z_hex.'00' if (length ($z_hex) == 1);		# DEH 2013.03.28
                    $color = $z_hex . 'ff' . $z_hex;    # DEH 2013.03.28

#        }
#      print "     <td height='5' bgcolor='$color' onClick=\"document.production.prod_hist.value='[$real &mdash; $realh $produnit]: @histo[$his]'\"></td>\n";
                    print
"     <td height='5' bgcolor='$color' onClick='ProdHistClick($real,$realh,@histo[$his],\"$produnit\")'></td>\n";
##77##
                }    # for ($his=0...)
#########################
                print '
   </tr>
   <tr>
';
                $heightScale = 1;
                $maxHisto    = 0;
                for ( $his = 1 ; $his < 255 ; $his++ ) {
                    $maxHisto = @histo[$his] if ( @histo[$his] > $maxHisto );
                }
                $heightScale = 2 if ( $maxHisto < 20 );

#    print "     <td valign='top'><img src='black.gif' width='2' height='0' onClick=\"window.status='@histo[0]'\"></td>\n";
                print
"     <td valign='top'><img src='black.gif' width='2' height='2' onMouseover='ProdHistCount(@histo[0])'></td>\n";
                for ( $his = 1 ; $his < 255 ; $his++ ) {
                    $height = $heightScale * @histo[$his];

#      print "     <td valign='top'><img src='black.gif' width='2' height='$height' onClick=\"window.status='@histo[$his]'\"></td>\n";
                    print
"     <td valign='top'><img src='black.gif' width='2' height='$height' onMouseover='ProdHistCount(@histo[$his])'></td>\n";
                }    # for ($his=0...)
#########################
                print "
   </tr>
   <tr>
    <td height=8></td>
   </tr>
   <tr>
   </tr>
  </table>
 </td>
 <td>
  <td valign=top>
   <img src='/BAERTOOLS/ravel/DEMprodGraphXYS.php?file=$unique&y=$max_prod_row&s=1' name='ELEVprodGraphWE'><br>
   <img src='/BAERTOOLS/ravel/DEMprodGraphXYS.php?file=$unique&x=$max_prod_col&s=1' name='ELEVprodGraphNS'><br>
  </td>
 </tr>
</table>
";
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

    print "<h4>RESULTS</h4>
  Run description: $description<br>
  Model run: $unique<br>
";

    if ( !$datumLine )   { $datumLine   = 'NAD83/WGS84' }
    if ( !$versionLine ) { $versionLine = '2010.09.01' }

    print "   $UTMline<br>\n"                     if ($UTMline);
    print "   DEM file: $fileLine<br>\n"          if ($fileLine);
    print "   $zoneLine<br>\n"                    if ($zoneLine);
    print "   run-ca version: $versionLine<br>\n" if ($versionLine);
    print "   Datum: $datumLine<br>\n"            if ($datumLine);

    @theZone     = split( ' ', $zoneLine );
    @theFileName = split( ' ', $fileLine );
    print "
<br>
ASCII grid files:
<a href='$retrievable_DEMfile_1' target='_DEM'>elevation file</a> |
<a href='$retrievable_depfile_1' target='_dep'>deposition file</a> |
<a href='$retrievable_prodfile_1' target='_prod'>production file</a>

   <table border=1>
    <tr><th bgcolor=rosybrown colspan=2>Model Results</th></tr>
    <tr><th bgcolor=rosybrown>Run description</th><td>$description</td></tr>
    <tr><th bgcolor=rosybrown>UTM zone</th>       <td>@theZone[3]</td></tr>
    <tr><th bgcolor=rosybrown>Datum</th>          <td>$datumLine</td></tr>
    <tr><th bgcolor=rosybrown>run-ca version</th> <td>$versionLine</td></tr>
    <tr><th bgcolor=rosybrown>DEM file</th>       <td>$theFileName[1]</td></tr>
    <tr><th bgcolor=rosybrown>Model run</th>      <td>$unique</td></tr>
    <tr><th bgcolor=rosybrown colspan=2>ASCII grid files</th></tr>
    <tr><td bgcolor=rosybrown></td><td><a href='$retrievable_DEMfile_1'  target='_DEM'>elevation</a></td></tr>
    <tr><td bgcolor=rosybrown></td><td><a href='$retrievable_depfile_1'  target='_dep'>deposition</a></td></tr>
    <tr><td bgcolor=rosybrown></td><td><a href='$retrievable_prodfile_1' target='_prod'>production</a></td></tr>
   </table>
";

}    # if ($error <= 0)

footer:
print '
<br><br>
<b>Citation:</b>
 <p align="left" class="Reference">
        Hall, David E.; Robichaud, Peter R.; Miller, Mary Ellen; Xiangyang Fu.
        2010.
        <b>RavelRAT-CA Ver. <a href="javascript:popuphistory()">', $version,
  '</a>.</b>
        [Online at &lt;https://forest.moscowfsl.wsu.edu/BAERTOOLS/ravel/ravelrat-ca.html&gt;.]
        Moscow, ID: U.S. Department of Agriculture, Forest Service, Rocky Mountain Research Station.

 </body>
</html>
';


sub dms_to_dec {
    #
    #  converted from closest.php
    #     function dms_to_dec($in) {
    #
    $in = @_[0];

    #  if ($degat = index($in,"o")) {
    $degat = index( $in, "o" );
    if ( $degat > 0 ) {
        $minat = length($in);
        if ( index( $in, "'" ) ) { $minat = index( $in, "'" ) }
        $secat = length($in);
        if ( index( $in, '"' ) ) { $secat = index( $in, '"' ) }
        $dmdif   = $minat - $degat;
        $msdif   = $secat - $minat;
        $degrees = substr( $in, 0,          $degat );
        $minutes = substr( $in, $degat + 1, $dmdif - 1 );
        $seconds = substr( $in, $minat + 1, $msdif - 1 );
        if ( $minutes == '' ) { $minutes = 0 }
        if ( $seconds == '' ) { $seconds = 0 }

        # print "$degrees degrees $minutes minutes $seconds seconds<br>\n";
        if (   isNumber($degrees)
            && isNumber($minutes)
            && isNumber($seconds)
            && $degrees < 180
            && $minutes < 60
            && $seconds < 60 )
        {
            if ( $degrees >= 0 ) {
                $in = $degrees + ( $minutes / 60 ) + ( $seconds / 3600 );
            }
            else {
                $in = $degrees - ( $minutes / 60 ) - ( $seconds / 3600 );
            }
        }
    }

    #   else print "$in degrees<br>\n";
    return $in;
}

sub isNumber () {

#  I am looking for a function that returns true if a number is tested.
#  https://forums.devshed.com/perl-programming-6/isnumeric-in-perl-59336.html
#  From the "Programming Perl" book by Wall, Christiansen & Schwartz, published by O'Reilly

    # Perl Cookbook
    # 2.1. Checking Whether a String Is a Valid Number
    # https://docstore.mik.ua/orelly/perl/cookbook/ch02_02.htm

    $tester = @_[0];

    #  print "[isNumber]: $tester\n";
    #  return $tester =~ /^(\d+\.?\d*|\.\d+)$/  # match valid number
    return $tester =~
      /^-?(?:\d+(?:\.\d*)?|\.\d+)$/ # warn "not a decimal number" unless /^-?(?:\d+(?:\.\d*)?|\.\d+)$/;

# warn "has nondigits"        if     /\D/;
# warn "not a natural number" unless /^\d+$/;             # rejects -3
# warn "not an integer"       unless /^-?\d+$/;           # rejects +3
# warn "not an integer"       unless /^[+-]?\d+$/;
# warn "not a decimal number" unless /^-?\d+\.?\d*$/;     # rejects .2
# warn "not a decimal number" unless /^-?(?:\d+(?:\.\d*)?|\.\d+)$/;
# warn "not a C float"        unless /^([+-]?)(?=\d|\.\d)\d*(\.\d*)?([Ee]([+-]?\d+))?$/;
}

