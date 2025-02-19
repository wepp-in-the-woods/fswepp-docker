#!/usr/bin/perl

use warnings;
use CGI;
use CGI qw(escapeHTML header);
use MoscowFSL::FSWEPP::CligenUtils qw(CreateCligenFile GetParSummary GetStationName);
use MoscowFSL::FSWEPP::FsWeppUtils qw(printdate get_version get_thisyear_and_thisweek get_user_id );
use MoscowFSL::FSWEPP::WeppRoad qw(CreateSlopeFileWeppRoad CreateSoilFileWeppRoad CheckInputWeppRoad GetSoilFileTemplate);
use POSIX qw(strftime);

# wrbat.pl
#
# WEPP:Road batch

# 2004.07.20 remove 'low' traffic from provisional warning
#		Allow 'inveg', 'native' etc.
# 2004.06.30
# 31 January 2002
# David Hall, USDA Forest Service, Rocky Mountain Research Station

my $version = get_version(__FILE__);
my $user_ID = get_user_id();
my $debug = 0;
my $batch = 1;
my $weppversion = "wepp2010";
my $count_limit = 1000;
my $now = strftime("%I:%M %p %A %B %d, %Y", localtime);
my ($thisyear, $thisweek) = get_thisyear_and_thisweek();

my $cgi = CGI->new;
$action =
    $cgi->param('ActionC')
  . $cgi->param('ActionW')
  . $cgi->param('ActionCD')
  . $cgi->param('ActionSD')
  . $cgi->param('old_log')
  . $cgi->param('submit');
chomp $action;
$achtung = $cgi->param('achtung');

$extended = $cgi->param('extended');

$project_title = escapeHTML( $cgi->param('projectdescription') );

if ( ( $action . $achtung ) eq '' ) {
    print "Content-type: text/html\n\n";
    print "<HTML>
 <HEAD>
  <meta http-equiv='Refresh' content='0; URL=/fswepp/'>
 </HEAD>
</HTML>
";
    goto done;
}

####
$spread    = $cgi->param('spread');
$CL        = $cgi->param('Climate');     # get Climate (file name base)
$ST        = $cgi->param('SoilType');
$units     = $cgi->param('units');
$years     = $cgi->param('years');
$climyears = $cgi->param('climyears');

if ( $units ne 'm' && $units ne 'ft' ) { $units = 'm' }

my $climatePar   = "$CL" . '.par';
my $climate_name = GetStationName($climatePar);

if    ( $ST eq 'clay' ) { $STx = 'clay loam' }
elsif ( $ST eq 'silt' ) { $STx = 'silt loam' }
elsif ( $ST eq 'sand' ) { $STx = 'sandy loam' }
elsif ( $ST eq 'loam' ) { $STx = 'loam' }

$logFile = "../working/" . $user_ID . ".wrblog";
if ( $host eq "" ) { $host = 'unknown' }

goto skip_check if ( lc($action) =~ /display previous log/ );

#=========================================================================

$checkonly = 0;
$checkonly = 1 if ( lc($action) eq 'check input' );

$working      = '../working';
$unique       = 'wepp' . '-' . $$;
$newSoilFile  = "$working/" . $unique . '.sol';
$responseFile = "$working/" . $unique . '.in';
$outputFile   = "$working/" . $unique . '.out';
$stoutFile    = "$working/" . $unique . '.stout';
$sterFile     = "$working/" . $unique . '.sterr';
$slopeFile    = "$working/" . $unique . '.slp';
$soilPath     = 'data/';
$manPath      = 'data/';
$logFile      = "$working/" . $user_ID . ".wrblog";

# ########### PARSE TEXTAREA data and check

skip_check:

print "Content-type: text/html\n\n";
print "<HTML>
 <HEAD>
  <TITLE>WEPP:Road batch results</TITLE>
   <script language=\"javascript\">

    function popupcopyhelp() {
     url = '';
     height=500;
     width=660;
     popupwindow = window.open(url,'popupwindow','toolbar=no,location=no,status=no,directories=no,menubar=no,scrollbars=yes,resizable=yes,width='+width+',height='+height);
     if (popupwindow != null) {
      popupwindow.document.writeln('<html>')
      popupwindow.document.writeln(' <head>')
      popupwindow.document.writeln('  <title>Copying WEPP:Road batch results into Excel</title>')
      popupwindow.document.writeln(' </head>')
      popupwindow.document.writeln(' <body bgcolor=white>')
      popupwindow.document.writeln('  <font face=\"arial, helvetica, sans serif\">')
      popupwindow.document.writeln('   <center>')
      popupwindow.document.writeln('    <h4>Copying WEPP:Road batch results into Excel</h4>')
      popupwindow.document.writeln('   </center>')

      popupwindow.document.writeln('    The WEPP:Road batch results in this table can be copied into an Excel 2000 spreadsheet.')

      popupwindow.document.writeln('    <h4>Internet Explorer 5.50</h4>')
      popupwindow.document.writeln('    <ol>')
      popupwindow.document.writeln('     <li>')
      popupwindow.document.writeln('      Highlight the text in the column headings and the rest of the text in the table,')
      popupwindow.document.writeln('     </li>')
      popupwindow.document.writeln('     <li>')
      popupwindow.document.writeln('      Select \"Edit,\" \"Copy\" in the browser menu bar,')
      popupwindow.document.writeln('     </li>')
      popupwindow.document.writeln('     <li>')
      popupwindow.document.writeln('      Switch to an Excel spreadsheet,')
      popupwindow.document.writeln('     </li>')
      popupwindow.document.writeln('     <li>')
      popupwindow.document.writeln('      Select the cell for the upper left-hand corner of the table,')
      popupwindow.document.writeln('     </li>')
      popupwindow.document.writeln('     <li>')
      popupwindow.document.writeln('      Select \"Edit,\" \"Paste Special,\" \"HTML.\"')
      popupwindow.document.writeln('     </li>')
      popupwindow.document.writeln('    </ol>')

      popupwindow.document.writeln('    <h4>Mozilla 1.6</h4>')
      popupwindow.document.writeln('    <ol>')
      popupwindow.document.writeln('     <li>')
      popupwindow.document.writeln('      Highlight the text in the column headings and the rest of the text in the table,')
      popupwindow.document.writeln('     </li>')
      popupwindow.document.writeln('     <li>')
      popupwindow.document.writeln('      Select \"Edit,\" \"Copy\" in the browser menu bar,')
      popupwindow.document.writeln('     </li>')
      popupwindow.document.writeln('     <li>')
      popupwindow.document.writeln('      Switch to an Excel spreadsheet,')
      popupwindow.document.writeln('     </li>')
      popupwindow.document.writeln('     <li>')
      popupwindow.document.writeln('      Select the cell for the upper left-hand corner of the table,')
      popupwindow.document.writeln('     </li>')
      popupwindow.document.writeln('     <li>')
      popupwindow.document.writeln('      Select \"Edit,\" \"Paste Special,\" \"Text.\"')
      popupwindow.document.writeln('     </li>')
      popupwindow.document.writeln('    </ol>')

      popupwindow.document.writeln('    <h4>Netscape Navigator 7.0</h4>')
      popupwindow.document.writeln('    I have not found a method that works well.')

      popupwindow.document.writeln('  </font>')
      popupwindow.document.writeln(' </body>')
      popupwindow.document.writeln('</html>')
      popupwindow.document.close()
      popupwindow.focus()
     }
    }

  </script>
 </HEAD>
";
print '
 <BODY>
  <font face="Arial, Geneva, Helvetica, sans serif">
';
print '
   <blockquote>
    <CENTER>

   <table width="90%">
    <tr>
     <td>
      <a href="/cgi-bin/fswepp/wr/wepproadbat.pl">
      <img src="/fswepp/images/roadb.gif"
        align=left border=1
        width=50 height=50
        alt="Return to WEPP:Road batch input screen" 
        onMouseOver="window.status=',
  "'Return to WEPP:Road batch input screen'", '; return true"
        onMouseOut="window.status=', "' '", '; return true">
    </a>
    <td align=center>
     <hr>
     <H3>WEPP:Road Batch results
      <!-- img src="/fswepp/images/underc.gif" -->
     </H3>
     <hr>
    <td>
    </table>
';

#    print "<h3 align=center>$project_title</h3>\n";

if ($debug) {
    print "   Climate: $CL
   Soil texture: $ST
   Units: $units
   Years: $years
   Batch: $batch
   Logfile: $logFile
   Extended output: $extended<br>
   Action: $action<br>
   Achtung: $achtung<br>
   "
}

#=========================================================================

goto skip_run if ( lc($action) eq 'display previous log' );

#=========================================================================

display_errors:

if ($batch) {
    $spread = escapeHTML( $cgi->param('spread') );

    #!
    #   $spread = 'ib n l 12 100 4 45 12 75 20 20 comment 1';
    $spread .= "\n";
    $spreadx = $spread;
}

#   print $spreadx;
$num_invalid_records = 0;
$dupes               = 0;

$v_years = &valid_years($years);
$v_units = &valid_units($units);
$v_clime = &valid_climate($CL);
$v_soilt = &valid_soiltexture($ST);
if   ($v_clime) { $clime_color = 'white' }
else            { $clime_color = 'red' }
if   ($v_soilt) { $soilt_color = 'white' }
else            { $soilt_color = 'red' }
if   ($v_years) { $years_color = 'white' }
else            { $years_color = 'red' }

$badcommons = !( $v_years && $v_units && $v_clime && $v_soilt );

if ($checkonly) {

    print "
   <table border=2>
    <tr>
     <th bgcolor='lightblue'>Climate</th>
     <th bgcolor='lightblue'>Soil Texture</th>
     <th bgcolor='lightblue'>Years</th>
    </tr>
    <tr>
     <td bgcolor='$clime_color'>$climate_name</th>
     <td bgcolor='$soilt_color'>$STx</th>
     <td bgcolor='$years_color'>$years</th>
    </tr>
   </table>
   <br>
";
}

if ($checkonly) {
    print "
   <table border=2>
    <tr>
     <th bgcolor=\"lightblue\">Run</th>
     <th bgcolor=\"lightblue\">Design<br>
      (<a
          onMouseOver=\"window.status='Insloped road with bare ditch'\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">'ib'</a>,
       <a
          onMouseOver=\"window.status='Insloped road with vegetated or rocked ditch'\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">'iv'</a>,<br>
       <a
          onMouseOver=\"window.status='Outsloped rutted road'\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">'or'</a>,
       <a
          onMouseOver=\"window.status='Outsloped unrutted road'\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">'ou'</a>)
     </th>
     <th bgcolor=\"lightblue\">Road<br>surface<br>
      (<a onMouseOver=\"window.status='Native surface'\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">'n'</a>,
       <a onMouseOver=\"window.status='Gravel surface'\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">'g'</a>,
       <a onMouseOver=\"window.status='Paved surface'\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">'p'</a>)
     </th>
     <th bgcolor=\"lightblue\">Traffic<br>level<br>
      (<a onMouseOver=\"window.status='High traffic'\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">'h'</a>,
       <a onMouseOver=\"window.status='Low traffic'\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">'l'</a>,
       <a onMouseOver=\"window.status='No traffic'\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">'n'</a>)
     </th>
     <th bgcolor=\"lightblue\"><a
          onMouseOver=\"window.status='Decimal percent slope of the water flow path along the road surface';return true\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">Road<br>gradient</a><br>(%)
     </th>
     <th bgcolor=\"lightblue\">Road<br>length<br>($units)
     </th>
     <th bgcolor=\"lightblue\">Road<br>width<br>($units)
     </th>
     <th bgcolor=\"lightblue\">Fill<br>gradient<br>(%)
     </th>
     <th bgcolor=\"lightblue\">Fill<br>length<br>($units)
     </th>
     <th bgcolor=\"lightblue\">Buffer<br>gradient<br>(%)
     </th>
     <th bgcolor=\"lightblue\">Buffer<br>length<br>($units)
     </th>
     <th bgcolor=\"lightblue\">Rock<br>fragment<br>(%)
     </th>
     <th bgcolor=\"lightblue\">Comments</th>
    <tr>
    </tr>
 "
}
$prev_head = '';
$count     = 0;
if ($batch) {
    $ind = index( $spreadx, "\n" );
    while ( $ind > 1 ) {
        last if ( $count > $count_limit );
        $head    = substr( $spreadx, 0, $ind );
        $spreadx = substr( $spreadx, $ind + 1 );

        #    next if ($head eq $prev_head);
        $count += 1;
        @inputs[$count] = $head;
        $num_invalid_fields = 0;
        ( $design, $rs, $tl, $rg, $rl, $rw, $fg, $fl, $bg, $bl, $rf, $comments )
          = split( ' ', $head, 12 );
        chomp $comments;
        $design = lc $design;
        if ($checkonly) {
            print "    <tr>";

            #       print "     <td bgcolor=\"cyan\">$count";
        }
        $valid = 1;
        $valid = 0 if ( $head eq $prev_head );
        $dupes += 1 if ( !$valid );
        &printrunfield( $checkonly, $valid, $count );
        $valid = &validate_design($design);
        &printfield( $checkonly, $valid, $design );
        $valid = &validate_surface($rs);
        &printfield( $checkonly, $valid, $rs );
        $valid = &validate_traffic($tl);
        &printfield( $checkonly, $valid, $tl );
        $valid = &validate_slope( $rg, 'r' );
        &printfield( $checkonly, $valid, $rg );
        $valid = &validate_length( $rl, 'r' );
        &printfield( $checkonly, $valid, $rl );
        $valid = &validate_length( $rw, 'w' );
        &printfield( $checkonly, $valid, $rw );
        $valid = &validate_slope( $fg, 'f' );
        &printfield( $checkonly, $valid, $fg );
        $valid = &validate_length( $fl, 'f' );
        &printfield( $checkonly, $valid, $fl );
        $valid = &validate_slope( $bg, 'b' );
        &printfield( $checkonly, $valid, $bg );
        $valid = &validate_length( $bl, 'b' );
        &printfield( $checkonly, $valid, $bl );
        $valid = &validate_rock($rf);
        &printfield( $checkonly, $valid, $rf );
        if ($checkonly) { print "     <td>$comments</td></tr>\n" }
        $num_invalid_records += 1 if $num_invalid_fields > 0;
        $ind       = index( $spreadx, "\n" );
        $prev_head = $head;
    }
}
else {
    #   $design=
    #   $rs=
    #   $tl=
    #   $rg=
    #   $rl=
    #   $rw=
    #   $fg=
    #   $fl=
    #   $bg=
    #   $bl=
    #   $rf=
    #   $comments=
    $valid = &validate_design($design);
    &printfield( $checkonly, $valid, $design );
    $valid = &validate_surface($rs);
    &printfield( $checkonly, $valid, $rs );
    $valid = &validate_traffic($tl);
    &printfield( $checkonly, $valid, $tl );
    $valid = &validate_slope( $rg, 'r' );
    &printfield( $checkonly, $valid, $rg );
    $valid = &validate_length( $rl, 'r' );
    &printfield( $checkonly, $valid, $rl );
    $valid = &validate_length( $rw, 'w' );
    &printfield( $checkonly, $valid, $rw );
    $valid = &validate_slope( $fg, 'f' );
    &printfield( $checkonly, $valid, $fg );
    $valid = &validate_length( $fl, 'f' );
    &printfield( $checkonly, $valid, $fl );
    $valid = &validate_slope( $bg, 'b' );
    &printfield( $checkonly, $valid, $bg );
    $valid = &validate_length( $bl, 'b' );
    &printfield( $checkonly, $valid, $bl );
    $valid = &validate_rock($rf);
    &printfield( $check, $validonly, $rf );
}
$num_invalid_records_x = $num_invalid_records + $dupes;
if ($checkonly) {

    $runstext = 'runs';
    if ( $num_invalid_records_x == 1 ) { $runstext = 'run' }
    $textcolorb = '';
    $textcolore = '';
    if ( $num_invalid_records_x > 0 ) {
        $textcolorb = '<font color="red">';
        $textcolore = '</font>';
    }
    print "   </table>
    <p>
     Current limit is $count_limit runs.<br>
     $textcolorb
     $num_invalid_records_x $runstext with invalid entries detected.<br>
     $textcolore
";

    $runstext = 'runs';
    if ( $dupes == 1 ) { $runstext = 'run' }
    $textcolorb = '';
    $textcolore = '';
    if ( $dupes > 0 ) {
        $textcolorb = '<font color="red">';
        $textcolore = '</font>';
    }
    print "
     $textcolorb
     $dupes consecutive duplicate $runstext detected.
     $textcolore
     <p>
";

#   if ($count > $count_limit) {print "current limit is $count_limit records.<br>\n"}
    if ( $num_invalid_records_x > 0 ) {
        print "Make corrections below.<br>
"
    }
#######################   check continue
    $spread =~ s/\r//g;    # DEH 2009.09.18 unix to DOS format
    print "
     <form name=\"wrbat\" method=post ACTION=\"/cgi-bin/fswepp/wr/wrbat.pl\">
      <input type=\"hidden\" name=\"units\" value=$units>
      <input type=\"hidden\" name=\"Climate\" value=$CL>
      <input type=\"hidden\" name=\"SoilType\" value=$ST>
      <input type=\"hidden\" name=\"achtung\" value=\"Run WEPP\">
      <input type=\"hidden\" name=\"projectdescription\" value=\"$project_title\">
       <a onMouseOver=\"window.status='This is the grand input window. Space or Tab between columns'\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">
       <TEXTAREA name=\"spread\" cols=100 rows=16>$spread</TEXTAREA>
      </a>
      <br>
      <input type=\"hidden\" name=\"years\" size=4 value=$years>
      <!-- input type=\"hidden\" name=\"climate_name\" -->
       <a onMouseOver=\"window.status='Recheck input data but do not run WEPP'\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">
        <input type=\"submit\" name=\"submit\" value=\"Check input\">
       </a>
";
    print "
     <a onMouseOver=\"window.status='Check input data and run WEPP if input data look good'\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">
      <input type=\"submit\" name=\"submit\" value=\"Run WEPP\">
     </a>
     <a onMouseOver=\"window.status='Extended output'\"
          onMouseOut=\"window.status='Forest Service WEPP:Road Batch'\">
      <input type=\"checkbox\" name=\"extended\">
     </a>
" if ( $num_invalid_records_x == 0 && $count > 0 );

    print "
     </form>
     <br>
";
############################### check continue
    goto end_page;
    print "
  </font>
 </body>
</html>
  ";
    die;
}

$checkonly = 1;

if ( $count < 1 || $num_invalid_records > 0 || $dupes > 0 || $badcommons ) {
    goto display_errors;
}
die if ( $num_invalid_records > 0 );

# =======================  Create CLIGEN file ====================

( $climateFile, $climatePar ) =
  &CreateCligenFile( $CL, $unique, $years, $debug );

# =======================  Create new log ====================

$project_title = $now if ( $project_title eq '' );
open LOG, ">" . $logFile;
print LOG "$project_title
$climate_name
$STx
$units
$years
";
close LOG;

# =======================  Run WEPP  =========================

for $record ( 1 .. $count ) {
    if ($batch) {
        (
            $design, $surface, $traffic, $URS, $URL, $URW,
            $UFS,    $UFL,     $UBS,     $UBL, $UBR, $comments
        ) = split( ' ', @inputs[$record], 12 );
        chomp $comments;
        $design = lc $design;
    }
    $URL *= 1;    # Road length -- buffer spacing (free)
    $URS *= 1;    # Road gradient (free)
    $URW *= 1;    # road width (free)
    $UFL *= 1;    # fill length (free)
    $UFS *= 1;    # fill steepness (free)
    $UBL *= 1;    # Buffer length (free)
    $UBS *= 1;    # Buffer steepness (free)
    $UBR *= 1;    # Rock fragment percentage

    if ( $design eq 'ou' || $design eq 'outunrut' ) {    # DEH
        $designw = 'Outsloped, unrutted';
        $designx = 'outsloped unrutted';
    }
    elsif ( $design eq 'ib' || $design eq 'inbare' ) {    # DEH
        $designw = 'Insloped, bare ditch';
        $designx = 'insloped bare';
    }
    elsif ( $design eq 'iv' || $design eq 'inveg' ) {     # DEH
        $designw = 'Insloped, vegetated or rocked ditch';
        $designx = 'insloped vegetated';
    }
    elsif ( $design eq 'or' || $design eq 'outrut' ) {    #DEH
        $designw = 'Outsloped, rutted';
        $designx = 'outsloped rutted';
    }

    if    ( lc($traffic) eq 'l' ) { $traffic = 'low' }
    elsif ( lc($traffic) eq 'h' ) { $traffic = 'high' }
    elsif ( lc($traffic) eq 'n' ) { $traffic = 'none' }

    if    ( lc($surface) eq 'n' ) { $surface = 'native' }
    elsif ( lc($surface) eq 'g' ) { $surface = 'graveled' }
    elsif ( lc($surface) eq 'p' ) { $surface = 'paved' }

    if ($debug) {
        print @inputs[1], "<br>\nUnits: $units<br>
     Submit action: $action<br>
     Years: $years<br>
     ST: $ST<br>
     Surface: $surface<br>
     Traffic: $traffic<br>
     URL: $URL<br>
     URS: $URS<br>
     URW: $URW<br>
     UFS: $UFS<br>
     UFL: $UFL<br>
     UBS: $UBS<br>
     UBL: $URL<br>
     UBR: $UBR<br>
     Design: $design<br>
     Designw: $designw<br>
     units '$units' <br>
"
    }

    print "
   <table width=100%>
    <tr>
     <td bgcolor=\"lightblue\">
      <b>[$record] -- $comments</b>
     </td>
    </tr>
   </table>
";

    $rcin = &checkInput;
    if ( $rcin >= 0 ) {

        $soilFilefq = $soilPath . &soilfilename;
        $manfile    = &manfilename;

        open NEWSOILFILE, ">$newSoilFile";
        print NEWSOILFILE &CreateSoilFile;
        close NEWSOILFILE;

        if ($debug) {
            print "<pre>creating soil file: $newSoilFile\n", $soilFileBody,
              "</pre>\n";
        }
        ($zzslope, $WeppRoadSlope, $WeppRoadWidth, $WeppRoadLength) = &CreateSlopeFileWeppRoad(
            $URS, $UFS,   $UBS,   $URW,       $URL, $UFL,
            $UBL, $units, $slope, $slopeFile, $debug
        );
        &CreateResponseFile;
        @args = ("../$weppversion <$responseFile >$stoutFile 2>$sterFile")
          ;    # DEH 2015.02.10
        system @args;

        open weppstout, "<$stoutFile";

        $found = 0;
        while (<weppstout>) {
            if (/SUCCESSFUL/) {
                $found = 1;
                last;
            }
        }
        close(weppstout);

        if ( $found == 0 )
        {    # unsuccessful run -- search STDOUT for error message
            open weppstout, "<$stoutFile";
            while (<weppstout>) {
                if (/ERROR/) {
                    $found = 2;
                    print "<font color=red>\n";
                    $_ = <weppstout>;
                    $_ = <weppstout>;
                    $_ = <weppstout>;
                    print;
                    $_ = <weppstout>;
                    print;
                    print "</font>\n";
                    last;
                }
            }
            close(weppstout);
        }

        if ( $found == 0 ) {
            open weppstout, "<$stoutFile";
            while (<weppstout>) {
                if (/error #/) {
                    $found = 4;
                    print "<font color=red>\n";
                    print;
                    print "</font>\n";
                    last;
                }
            }
            close(weppstout);
        }

        if ( $found == 0 ) {
            open weppstout, "<$stoutFile";
            while (<weppstout>) {
                if (/\*\*\* /) {
                    $found = 3;
                    print "<font color=red>\n";
                    $_ = <weppstout>;
                    print;
                    $_ = <weppstout>;
                    print;
                    $_ = <weppstout>;
                    print;
                    $_ = <weppstout>;
                    print;
                    print "</font>\n";
                    last;
                }
            }
            close(weppstout);
        }

        if ( $found == 0 ) {
            open weppstout, "<$stoutFile";
            while (<weppstout>) {
                if (/MATHERRQQ/) {
                    $found = 5;
                    print "<font color=red>\n";
                    print 'WEPP has run into a mathematical anomaly.<br>
             You may be able to get around it by modifying the geometry slightly;
             try changing road length by 1 foot (1/2 meter) or so.
             ';
                    $_ = <weppstout>;
                    print;
                    print "</font>\n";
                    last;
                }
            }
            close(weppstout);
        }

        if ( $found == 1 ) {  # Successful run -- get actual WEPP version number
            open weppout, "<$outputFile";
            $ver = 'unknown';
            while (<weppout>) {
                if (/VERSION/) {
                    $weppver = $_;
                    last;
                }
            }

            while (<weppout>) { # read actual climate file used from WEPP output
                if (/CLIMATE/) {
                    $a_c_n = <weppout>;
                    $actual_climate_name =
                      substr( $a_c_n, index( $a_c_n, ":" ) + 1, 40 );
                    $climate_name = $actual_climate_name;
                    last;
                }
            }

            while (<weppout>) {
                if (/RAINFALL AND RUNOFF SUMMARY/) {
                    $_ = <weppout>;    #      -------- --- ------ -------
                    $_ = <weppout>;    #
                    $_ = <weppout>;    #       total summary:  years    1 -    1
                    $_ = <weppout>;    #
                    $_ = <weppout>
                      ; #         71 storms produced                          346.90 mm of precipitation
                    $storms = substr $_, 1, 10;
                    $_ = <weppout>
                      ; #          3 rain storm runoff events produced          0.00 mm of runoff
                    $rainevents = substr $_, 1, 10;
                    $_          = <weppout>;    #          2 snow melts and/or
                    $snowevents = substr $_, 1, 10;
                    $_          = <weppout>
                      ; #              events during winter produced            0.00 mm of runoff
                    $_ = <weppout>;    #
                    $_ = <weppout>;    #      annual averages
                    $_ = <weppout>;    #      ---------------
                    $_ = <weppout>;    #
                    $_ = <weppout>
                      ; #        Number of years                                    1
                    $_ = <weppout>
                      ; #        Mean annual precipitation                     346.90    mm
                    $precip = substr $_, 51, 10;
                    $_      = <weppout>;
                    $rro    = substr $_, 51, 10;    # print;
                    $_      = <weppout>;            # print;
                    $_      = <weppout>;
                    $sro    = substr $_, 51, 10;    # print;
                    $_      = <weppout>;            # print;
                    last;
                }
            }

            while (<weppout>) {
                if (/AREA OF NET SOIL LOSS/) {
                    $_                     = <weppout>;
                    $_                     = <weppout>;
                    $_                     = <weppout>;
                    $_                     = <weppout>;
                    $_                     = <weppout>;
                    $_                     = <weppout>;    # print;
                    $_                     = <weppout>;    # print;
                    $_                     = <weppout>;    # print;
                    $_                     = <weppout>;    # print;
                    $_                     = <weppout>;    # print;
                    $syr                   = substr $_, 17, 7;
                    $effective_road_length = substr $_, 9,  9;

                    #  area = val(mid$($_,9,7))
                    #  sed = val(mid$($_,16,9))
                    #  rsv = area * sed
                    last;
                }
            }

      # III. OFF SITE EFFECTS  OFF SITE EFFECTS  OFF SITE EFFECTS
      #      ----------------  ----------------  ----------------
      #
      #      A.  AVERAGE ANNUAL SEDIMENT LEAVING PROFILE
      #             73.558   kg/m of width
      #           1176.929     kg (based on profile width of     16.000      m)
      #              2.990   t/ha (assuming contributions from     0.394     ha)

            while (<weppout>) {
                if (/OFF SITE EFFECTS/) {
                    $_ = <weppout>;
                    $_ = <weppout>;
                    $_ = <weppout>;    # DEH 2015.03.02

           #            $_ = <weppout>;
           #            $_ = <weppout>; $syp = substr $_,50,9;   # pre-WEPP 98.4
           #            $_ = <weppout>; $syp = substr $_,49,10;  # pre-WEPP 98.4
                    $_   = <weppout>;
                    $syp = substr $_, 0, 19;  # WEPP 2010.100   # DEH 2015.03.02

#            $_ = <weppout>; if ($syp eq "") {$syp = substr $_,10,9} # off-site yield
#            $_ = <weppout>; if ($syp eq "") {$syp = substr $_,9,10} # off-site yield
                    $_ = <weppout>;
                    if ( $syp eq "" ) {
                        @sypline = split ' ', $_;
                        $syp     = @sypline[0];
                    }
                    $_ = <weppout>;
                    $_ = <weppout>;
                    last;
                }
            }
            close(weppout);

            $storms     += 0;
            $rainevents += 0;
            $snowevents += 0;
            $precip     += 0;
            $rro        += 0;
            $sro        += 0;
            $syr        += 0;
            $syp        += 0;
            $syra = $syr * $effective_road_length * $WeppRoadWidth;
            $sypa = $syp * $WeppRoadWidth;

            if ( $surface eq 'graveled' ) {
                $URR = 65;
                $UFR = ( $UBR + 65 ) / 2;
            }
            elsif ( $surface eq 'paved' ) {
                $URR = 95;
                $UFR = ( $UBR + 65 ) / 2;
            }
            else { $URR = $UBR; $UFR = $UBR }

            if ($extended) {
                print "
   <center>
    <table border=1>
     <tr>
      <th colspan=8 bgcolor=#85D2D2>
       <font face='Arial, Geneva, Helvetica, sans serif'>
        INPUTS
       </font>
      </th>
     </tr>
     <tr>
      <td>
       <font face='Arial, Geneva, Helvetica, sans serif'>
        $climate_name
       </font>
      </td>
      <td></td>
      <td width=20></td>
      <td></td>
      <th>
       <font face='Arial, Geneva, Helvetica, sans serif'>
        Gradient<br> (%)
       </font>
      </th>
      <th>
       <font face='Arial, Geneva, Helvetica, sans serif'>
        Length<br> ($units)
       </font>
      </th>
      <th>
       <font face='Arial, Geneva, Helvetica, sans serif'>
        Width<br> ($units)
       </font>
      </th>
      <th>
       <font face='Arial, Geneva, Helvetica, sans serif'>
        Rock<br> (%)
       </font>
      </th>
     </tr>
     <tr>
      <td>
       <font face='Arial, Geneva, Helvetica, sans serif'>
        $designw
       </font>
      </td>
      <td></td>
      <td></td>
      <th align=left>
       <font face='Arial, Geneva, Helvetica, sans serif'>
        Road
       </font>
      </td>
      <td align=right>
       <font face='Arial, Geneva, Helvetica, sans serif'>
        $URS
       </font>
      </td>
      <td align=right>
       <font face='Arial, Geneva, Helvetica, sans serif'>
        $URL
       </font>
      </td>
      <td align=right>
       <font face='Arial, Geneva, Helvetica, sans serif'>
        $URW
       </font>
      </td>
      <td align=right>
       <font face='Arial, Geneva, Helvetica, sans serif'>
        $URR
       </font>
      </td>
     </tr>
     <tr>
      <td>
       <font face='Arial, Geneva, Helvetica, sans serif'>
        $STx with $UBR% rock fragments
       </font>
      </td>
      <td></td>
      <td></td>
      <th align=left>
       <font face='Arial, Geneva, Helvetica, sans serif'>
        Fill
       </font>
      </td>
      <td align=right>
       <font face='Arial, Geneva, Helvetica, sans serif'>
        $UFS
       </font>
      </td>
      <td align=right>
       <font face='Arial, Geneva, Helvetica, sans serif'>
        $UFL
       </font>
      </td>
      <td></td>
      <td align=right>
       <font face='Arial, Geneva, Helvetica, sans serif'>
        $UFR
       </font>
      </td>
     <tr>
      <td>
       <font face='Arial, Geneva, Helvetica, sans serif'>
        $surface surface, $traffic traffic
       </font
      </td>
      <td></td>
      <td></td>
      <th align=left>
       <font face='Arial, Geneva, Helvetica, sans serif'>
        Buffer
       </font>
      </td>
      <td align=right>
       <font face='Arial, Geneva, Helvetica, sans serif'>
        $UBS
       </font>
      </td>
      <td align=right>
       <font face='Arial, Geneva, Helvetica, sans serif'>
        $UBL
       </font>
      </td>
      <td></td>
      <td align=right>
       <font face='Arial, Geneva, Helvetica, sans serif'>
        $UBR
       </font>
      <td>
     </tr>
    </table>
    <p>
";
            }

            if ( $units eq "m" ) {
                $precipunits = "mm";
                $sedunits    = "kg";
                $pcpfmt      = '%.0f';
            }
            else {    # convert WEPP metric results to in and lb
                $precipunits = "in";
                $precip      = $precip / 25.4;
                $rro         = $rro / 25.4;
                $sro         = $sro / 25.4;
                $sedunits    = "lb";
                $syra        = $syra * 2.2046;
                $sypa        = $sypa * 2.2046;
                $pcpfmt      = '%.2f';
            }

            #        $precipf = sprintf "%.0f", $precip;
            #        $rrof = sprintf "%.0f", $rro;
            #        $srof = sprintf "%.0f", $sro;
            $precipf = sprintf $pcpfmt, $precip;
            $rrof    = sprintf $pcpfmt, $rro;
            $srof    = sprintf $pcpfmt, $sro;
            $syraf   = sprintf "%.2f", $syra;
            $sypaf   = sprintf "%.2f", $sypa;

            if ($extended) {
                print "
   <table cellspacing=8>
    <tr>
     <th colspan=5 bgcolor=#85D2D2>
      <font face='Arial, Geneva, Helvetica, sans serif'>
       $years2sim - YEAR MEAN ANNUAL AVERAGES
    <tr>
     <td align=right>
      <font face='Arial, Geneva, Helvetica, sans serif'>
       $precipf<td>$precipunits<td>precipitation from
     <td align=right>
      <font face='Arial, Geneva, Helvetica, sans serif'>
       $storms<td>storms
      </font>
     </td>
    </tr>
    <tr>
     <td align=right>
      <font face='Arial, Geneva, Helvetica, sans serif'>
       $rrof<td>$precipunits<td>runoff from rainfall from
      </font>
     </td>
     <td align=right>
      <font face='Arial, Geneva, Helvetica, sans serif'>
       $rainevents<td>events
      </font>
     </td>
    </tr>
    <tr>
     <td align=right>
      <font face='Arial, Geneva, Helvetica, sans serif'>
       $srof<td>$precipunits
      </font>
     </td>
     <td>
      <font face='Arial, Geneva, Helvetica, sans serif'>
       runoff from snowmelt or winter rainstorm from
      </font>
     </td> 
     <td align=right>
      <font face='Arial, Geneva, Helvetica, sans serif'>
       $snowevents
      </font>
     <td>
      <font face='Arial, Geneva, Helvetica, sans serif'>
       events
      </font>
     </td>
    </tr>
    <tr>
     <td align=right>
      <font face='Arial, Geneva, Helvetica, sans serif'>
       $syraf
      </font>
     </td>
     <td>
      <font face='Arial, Geneva, Helvetica, sans serif'>
       $sedunits
      </font>
     </td>
     <td>
      <font face='Arial, Geneva, Helvetica, sans serif'>
       road prism erosion
      </font>
     </td>
    </tr>
    <tr>
     <td align=right>
      <font face='Arial, Geneva, Helvetica, sans serif'>
       $sypaf
      </font>
     </td>
     <td>
      <font face='Arial, Geneva, Helvetica, sans serif'>
       $sedunits
      </font>
     </td>
     <td>
      <font face='Arial, Geneva, Helvetica, sans serif'>
       sediment leaving buffer
      </font>
     </td>
    </tr>
<!--   <tr><td>$syr<td>$effective_road_length<td>$WeppRoadWidth<td> syra=syr x rdlen x rdwidth
   <tr><td>$syp<td>sypa=syp x rdwidth
-->
   </table>
   <hr width=50%>
";
            }    # if ($extended)

            #  $rf to $UBR    2004.06.30 DEH

            open LOG, ">>" . $logFile;
            print LOG "$precipf
$record
$designw
$surface $traffic
$URS
$URL
$URW
$UFS
$UFL
$UBS
$UBL
$UBR
$rrof
$srof
$syraf
$sypaf
$comments
";
            close LOG;
        }

    }
    else {
        print "<p>\nI'm sorry; WEPP did not run successfully.\n";
        open LOG, ">>" . $logFile;
        print LOG "$record !
$designw
$surface $traffic
$URS
$URL
$URW
$UFS
$UFL
$UBS
$UBL
$rf






";
        close LOG;
    }

    # ---------------------  WEPP summary output  --------------------

    if ( $outputf == 1 ) {
        print '<CENTER><H2>WEPP output</H2></CENTER>';
        print '<font face=courier><PRE>';
        open weppout, "<$outputFile";
        while (<weppout>) {
            print;
        }
        close weppout;
        print '</PRE></font>
     <form>
      <a href="/cgi-bin/fswepp/wr/wepproadbat.pl">
       <input type="button"  value="Return to previous screen" >
      </a>
     </form>
<p><center><hr>
<a href="/cgi-bin/fswepp/wr/wepproadbat.pl">
<img src="/fswepp/images/rtis.gif"
     alt="Return to input screen" border="0" aligh=center></A>
<BR><HR></center>
';
    }
    print "<br>\n";
}    #   if ($rcin >= 0)

print '
   </center>
';

#######################
skip_run:

&display_log;

#######################

end_page:
print '
   <center>
    <form name="wrblog" method="post" action="/cgi-bin/fswepp/wr/logstuffwr.pl">
     <!-- input type="submit" name="button" value="Display log" -->
     <a href="/cgi-bin/fswepp/wr/wepproadbat.pl">
      <input type="button" value="Return to previous screen">
     </a>
    </form>
    <br>
   </center>
   <hr>
   <table width=100%>
    <tr>
     <td>
      <font face="Arial, Geneva, Helvetica, sans serif" size=2>
       WEPP:Road batch results version
       <a href="https://github.com/wepp-in-the-woods/fswepp-docker/commits/main/var/www/cgi-bin/fswepp/wr/wrbat.pl">',
  $version, '</a>
       based on WEPP ', $weppver, '<br> by
       <a href="https://forest.moscowfsl.wsu.edu/people/engr/dehall.html">David Hall</a>
       and 
       Darrell Anderson;
       Project leader
       <a href="https://forest.moscowfsl.wsu.edu/people/engr/welliot.html">Bill Elliot</a>
       <br>
       USDA Forest Service, Rocky Mountain Research Station, Moscow, ID 83843
       <br>
';

print $now;
print '
     </td>
     <td>
      <font face="Arial, Geneva, Helvetica, sans serif">
       <a href="/fswepp/comments.html"
        onClick="return confirm(\'You need to be connected to the Internet to e-mail comments. Shall I try?\')">
      <img src="/fswepp/images/epaemail.gif" align="right" border=0></a>
      </font>
     </td>
    </tr>
   </table>
  </center>
 </body>
</html>
';

#  record activity in WEPP:Road log (if running on remote server)

if ( lc($action) eq 'run wepp' ) {

    open WRBLOG, ">>../working/_$thisyear/wrb.log";    # 2013.01.01 DEH
    flock( WRBLOG, 2 );
    $host = $ENV{REMOTE_HOST};
    if ( $host eq "" ) { $host = $ENV{REMOTE_ADDR} }

    print WRBLOG "$host\t$now\t$years2sim\t$count\t$climate_name\n";
    close WRBLOG;

    open CLIMLOG, ">../working/_$thisyear/lastclimate.txt";    # 2013.01.01 DEH
    flock CLIMLOG, 2;
    print CLIMLOG 'WEPP:Road batch: ', $climate_name;
    close CLIMLOG;

### record model runs ###

    $ditlogfile = ">>../working/_$thisyear/wrb/$thisweek";     # 2013.01.01 DEH
    open MYLOG, $ditlogfile;
    flock MYLOG, 2;                                            # 2005.02.09 DEH

    #      print MYLOG '.' x $count;	# 2005.02.10 DEH
    print MYLOG '.';                                           # 2007.01.01 DEH
    close MYLOG;

### record road segment count into WEPP:ROad logs###

    $ditlogfile = ">>../working/_$thisyear/wr/$thisweek";      # 2013.01.01 DEH
    open MYLOG, $ditlogfile;
    flock MYLOG, 2;                                            # 2005.02.09 DEH
    print MYLOG '.' x $count;                                  # 2005.02.10 DEH
    close MYLOG;
}

done:

$x = 'done';

# ------------------------ subroutines ---------------------------

sub CreateResponseFile {

    if ($debug) { print "creating $responseFile<br>\n"; }
    open( ResponseFile, ">$responseFile" );
    print ResponseFile "97.3\n";               # datver
    print ResponseFile "y\n";                  # not watershed
    print ResponseFile "1\n";                  # 1 = continuous
    print ResponseFile "1\n";                  # 1 = hillslope
    print ResponseFile "n\n";                  # hillsplope pass file out?
    print ResponseFile "1\n";                  # 1 = abreviated annual out
    print ResponseFile "n\n";                  # initial conditions file?
    print ResponseFile "$outputFile", "\n";    # soil loss output file
    print ResponseFile "n\n";                  # water balance output?
    print ResponseFile "n\n";                  # crop output?
    print ResponseFile "n\n";                  # soil output?
    print ResponseFile "n\n";                  # distance/sed loss output?
    print ResponseFile "n\n";                  # large graphics output?
    print ResponseFile "n\n";                  # event-by-event out?
    print ResponseFile "n\n";                  # element output?
    print ResponseFile "n\n";                  # final summary out?
    print ResponseFile "n\n";                  # daily winter out?
    print ResponseFile "n\n";                  # plant yield out?
    print ResponseFile $manPath . $manfile, "\n";    # management file name
    print ResponseFile $slopeFile,   "\n";           # slope file name
    print ResponseFile $climateFile, "\n";           # climate file name
    print ResponseFile $newSoilFile, "\n";           # soil file name
    print ResponseFile "0\n";                        # 0 = no irrigation
    print ResponseFile "$years2sim\n";               # no. years to simulate
    print ResponseFile "0\n";                        # 0 = route all events
    close ResponseFile;
    return $responseFile;
}

sub CreateSoilFile {

# Read a WEPP:Road soil file template and create a usable soil file.
# File may have 'urr', 'ufr' and 'ubr' as placeholders for rock fragments
# percentage
# Adjust road surface Kr downward for traffic levels of 'low' or 'none'
# Adjust road surface Ki downward for traffic levels of 'low' or 'none' 2004.06.30

    # David Hall and Darrell Anderson
    #  2004.06.30
    # November 26, 2001

# uses: $soilFilefq   fully qualified input soil file name
#       $surface      native, graveled, paved
#       $traffic      High, Low, None
#       $UBR          user-specified rock fragment decimal percentage for buffer
# sets: $URR          calculated rock fragment decimal percentage for road
#       $UFR          calculated rock fragment decimal percentage for fill

    my $body;
    my $in;
    my ( $pos1, $pos2, $pos3, $pos4 );
    my ( $ind, $left, $right );

    open SOILFILE, "<$soilFilefq";
    if ($debug) { print "incoming soil file: $soilFilefq $traffic\n" }

    if    ( $surface eq 'graveled' ) { $URR = 65;   $UFR = ( $UBR + 65 ) / 2 }
    elsif ( $surface eq 'paved' )    { $URR = 95;   $UFR = ( $UBR + 65 ) / 2 }
    else                             { $URR = $UBR; $UFR = $UBR }

    # modify 'Kr' for 'no traffic' and 'low traffic'
    # modify 'Ki' for 'no traffic' and 'low traffic'

    if ( $traffic eq 'low' || $traffic eq 'none' ) {
        $in   = <SOILFILE>;
        $body = $in;           # line 1; version control number - datver
        $in   = <SOILFILE>;    # first comment line
        $body .= "#  $traffic\n";
        $body .= $in;
        while ( substr( $in, 0, 1 ) eq '#' ) {    # gobble up comment lines
            $in = <SOILFILE>;
            $body .= $in;
        }
        $in = <SOILFILE>;
        $body .= $in;                             # line 3: ntemp, ksflag
        $in   = <SOILFILE>;
        $pos1 = index( $in, "'" );                # location of first apostrophe
        $pos2 = index( $in, "'", $pos1 + 1 );    # location of second apostrophe
        $pos3 = index( $in, "'", $pos2 + 1 );    # location of third apostrophe
        $pos4 = index( $in, "'", $pos3 + 1 );    # location of fourth apostrophe
        my $slid_texid = substr( $in, 0, $pos4 + 1 );    # slid; texid
        my $rest       = substr( $in, $pos4 + 1 );
        my ( $nsl, $salb, $sat, $ki, $kr, $shcrit, $avke ) = split ' ', $rest;
        $kr /= 4;
        $ki /= 4;

        if ($debug) {
            print
"\nnsl: $nsl salb $salb sat $sat ki $ki kr $kr shcrit $shcrit avke $avke\n";
        }
        $body .= "$slid_texid\t";
        $body .= "$nsl\t$salb\t$sat\t$ki\t$kr\t$shcrit\t$avke\n";
    }
    while (<SOILFILE>) {
        $in = $_;
        if (/urr/) {    # user-specified road rock fragment

            #        print 'found urr';
            $ind   = index( $in, 'urr' );
            $left  = substr( $in, 0, $ind );
            $right = substr( $in, $ind + 3 );
            $in    = $left . $URR . $right;
        }
        elsif (/ufr/) {    # calculated fill rock fragment

            #        print 'found ufr';
            $ind   = index( $in, 'ufr' );
            $left  = substr( $in, 0, $ind );
            $right = substr( $in, $ind + 3 );
            $in    = $left . $UFR . $right;
        }
        elsif (/ubr/) {    # calculated buffer rock fragment

            #        print 'found ubr';
            $ind   = index( $in, 'ubr' );
            $left  = substr( $in, 0, $ind );
            $right = substr( $in, $ind + 3 );
            $in    = $left . $UBR . $right;
        }

        #     print $in;
        $body .= $in;
    }
    close SOILFILE;
    return $body;
}

sub checkInput {

    if ( $units eq "m" ) {
        $lu     = "m";
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
    else {
        $lu     = "ft";
        $minURL = 3;
        $maxURL = 1000;
        $minURS = 0.3;
        $maxURS = 40;
        $minURW = 1;
        $maxURW = 300;

        #      $minUFL = 1;   $maxUFL = 300;
        $minUFL = 1;
        $maxUFL = 1000;
        $minUFS = 0.3;
        $maxUFS = 150;
        $minUBL = 1;
        $maxUBL = 1000;
        $minUBS = 0.3;
        $maxUBS = 100;
    }
    $minyrs = 1;
    $maxyrs = 200;
    $rc     = -0;
    print "<font color=red>\n";
    if ( $URL < $minURL or $URL > $maxURL ) {
        $rc = -1;
        print "Road length must be between $minURL and $maxURL $lu<BR>\n";
    }
    if ( $URS < $minURS or $URS > $maxURS ) {
        $rc = $rc - 1;
        print "Road gradient must be between $minURS and $maxURS %<BR>\n";
    }
    if ( $URW < $minURW or $URW > $maxURW ) {
        $rc = $rc - 1;
        print "Road width must be between $minURW and $maxURW $lu<BR>\n";
    }
    if ( $UFL < $minUFL or $UFL > $maxUFL ) {
        $rc = $rc - 1;
        print "Fill length must be between $minUFL and $maxUFL $lu<BR>\n";
    }
    if ( $UFS < $minUFS or $UFS > $maxUFS ) {
        $rc = $rc - 1;
        print "Fill gradient must be between $minUFS and $maxUFS %<BR>\n";
    }
    if ( $UBL < $minUBL or $UBL > $maxUBL ) {
        $rc = $rc - 1;
        print "Buffer length must be between $minUBL and $maxUBL $lu<BR>\n";
    }
    if ( $UBS < $minUBS or $UBS > $maxUBS ) {
        $rc = $rc - 1;
        print "Buffer gradient must be between $minUBS and $maxUBS %<BR>\n";
    }
    print "</font>\n";

    #    if ($rc < 0) {print "<p><hr><p>\n"}
    $years2sim = $years * 1;

    #     if ($years2sim < $minyrs) {$years2sim=$minyrs}
    #     if ($years2sim > $maxyrs) {$years2sim=$maxyrs}
    if ( $years2sim < 1 )   { $years2sim = 1 }
    if ( $years2sim > 200 ) { $years2sim = 200 }
    return $rc;
}

sub printfield {
    my $print = shift(@_);
    my $valid = shift(@_);
    my $value = shift(@_);
    if ($print) {
        if ($valid) {
            print "<td align='right'>$value</td>\n";
        }
        else {
            print "<td align='left' bgcolor='red'>$value</td>\n";
        }
    }
    else {
    }
}

sub printrunfield {
    my $print = shift(@_);
    my $valid = shift(@_);
    my $value = shift(@_);
    if ($print) {
        if ($valid) {
            print "<td bgcolor='lightblue'>$value</td>\n";
        }
        else {
            print "<td bgcolor='red'>$value</td>\n";
        }
    }
    else {
    }
}

sub valid_years {

    my $min    = 0;
    my $max    = 200;
    my $years  = shift(@_);
    my $years0 = $years + 0;

    if ( $years ne $years0 ) {

     #     print "<font color='red'>Invalid number of years: $years</font><br>";
        return 0;
    }
    if ( $years0 < $min || $years0 > $max ) {

#     print "<font color='red'>Invalid number of years: $years</font> ($min to $max allowed)<br>";
        return 0;
    }
    return 1;
}

sub valid_units {
    my $units = shift(@_);
    if ( $units eq 'm' || $units eq 'ft' ) {
        return 1;
    }

    #  print "<font color='red'>Invalid units: $units</font><br>";
    return 0;
}

sub valid_climate {
    my $CL  = shift(@_);
    my $CLx = $CL . '.par';

  # We should do some reasonableness checking before seeking the climate file...
    if ( -e $CLx ) {
        return 1;
    }

    #  print "<font color='red'>Climate file not found: $CL</font><br>";
    return 0;
}

sub valid_soiltexture {
    my $ST = shift(@_);
    if ( $ST eq 'clay' || $ST eq 'silt' || $ST eq 'loam' || $ST eq 'sand' ) {
        return 1;
    }
    else {
        #    print "<font color='red'>Invalid soil texture: $ST</font><br>";
        return 0;
    }
}

sub validate_design {    # DEH 2004.07.20
    my $design = shift(@_);
    if ( $design eq 'ib' || $design eq 'inbare' ) {
        $designw = 'Insloped, bare ditch';
    }
    elsif ( $design eq 'iv' || $design eq 'inveg' ) {
        $designw = 'Insloped, vegetated ditch';
    }
    elsif ( $design eq 'or' || $design eq 'outrut' ) {
        $designw = 'Outsloped, rutted';
    }
    elsif ( $design eq 'ou' || $design eq 'outunrut' ) {
        $designw = 'Outsloped, unrutted';
    }
    else { $num_invalid_fields += 1; return 0 }
    return 1;
}

sub validate_traffic {    # DEH 2004.07.20
    my $traffic = shift(@_);
    if ( lc($traffic) eq 'l' || lc($traffic) eq 'h' || lc($traffic) eq 'n' ) {
        return 1;
    }
    if (   lc($traffic) eq 'low'
        || lc($traffic) eq 'high'
        || lc($traffic) eq 'none' )
    {
        return 1;
    }
    else { $num_invalid_fields += 1; return 0 }
}

sub validate_surface {    # DEH 2004.07.20
    my $surface = shift(@_);

    #  if (lc($surface) eq 'n' || lc($surface) eq 'g' || lc($surface) eq 'p') {
    if (   lc($surface) eq 'n'
        || lc($surface) eq 'g'
        || lc($surface) eq 'p'
        || lc($surface) eq 'native'
        || lc($surface) eq 'graveled'
        || lc($surface) eq 'paved' )
    {
        return 1;
    }
    else { $num_invalid_fields += 1; return 0 }
}

sub validate_rock {

    my $min   = 0;
    my $max   = 100;
    my $rock  = shift(@_);
    my $rock0 = $rock + 0;

    if ( $rock != $rock0 ) {
        $num_invalid_fields += 1;
        return 0;
    }
    if ( $rock0 < $min || $rock0 > $max ) {
        $num_invalid_fields += 1;
        return 0;
    }
    return 1;
}

sub validate_slope {

    my ( $min, $max );
    my $slope   = shift(@_);
    my $surface = shift(@_);
    my $slope0  = $slope + 0;

    if ( $slope != $slope0 ) {
        $num_invalid_fields += 1;
        return 0;
    }

    if ( $surface eq 'r' ) { $min = 0.1; $max = 40 }
    if ( $surface eq 'f' ) { $min = 0.1; $max = 150 }
    if ( $surface eq 'b' ) { $min = 0.1; $max = 100 }
    if ( $slope0 < $min || $slope0 > $max ) {
        $num_invalid_fields += 1;
        return 0;
    }
    return 1;
}

sub validate_length {

    my ( $min, $max );
    my $length = shift(@_);
    my $surface =
      shift(@_);    # 'r': road; 'f': fill; 'b': buffer; 'w': road width(?)
    my $length0 = $length + 0;

    if ( $length != $length0 ) {
        $num_invalid_fields += 1;
        return 0;
    }
    if ( $surface eq 'r' && $units eq 'm' )  { $min = 1;   $max = 300 }
    if ( $surface eq 'r' && $units eq 'ft' ) { $min = 3;   $max = 1000 }
    if ( $surface eq 'f' && $units eq 'm' )  { $min = 0.3; $max = 100 }

    # if ($surface eq 'f' && $units eq 'ft') {$min=1;   $max=300}
    if ( $surface eq 'f' && $units eq 'ft' ) { $min = 1;   $max = 1000 }
    if ( $surface eq 'b' && $units eq 'm' )  { $min = 0.3; $max = 300 }
    if ( $surface eq 'b' && $units eq 'ft' ) { $min = 1;   $max = 1000 }
    if ( $surface eq 'w' && $units eq 'm' )  { $min = 0.3; $max = 100 }
    if ( $surface eq 'w' && $units eq 'ft' ) { $min = 1;   $max = 300 }
    if ( $length0 < $min || $length0 > $max ) {
        $num_invalid_fields += 1;
        return 0;
    }
    return 1;
}

sub soilfilename {

    # $surface
    # $slope
    # $ST

    # $surf
    # $tauC

    if    ( substr( $surface, 0, 1 ) eq 'g' ) { $surf = 'g' }
    elsif ( substr( $surface, 0, 1 ) eq 'p' ) { $surf = 'p' }
    else                                      { $surf = '' }

    if    ( $design eq 'inveg' || $design eq 'iv' )    { $tauC = '10' }
    elsif ( $design eq 'inbare' || $design eq 'ib' )   { $tauC = '2' }
    elsif ( $design eq 'outunrut' || $design eq 'ou' ) { $tauC = '2' }
    elsif ( $design eq 'outrut' || $design eq 'or' )   { $tauC = '2' }

    if ( ( $design eq 'inbare' || $design eq 'ib' ) && $surf eq 'p' ) {
        $tauC = '1';
    }
    return '3' . $surf . $ST . $tauC . '.sol';
}

sub manfilename {

    # $surface
    # $design
    # $traffic

    my $manfile;

    if    ( substr( $surface, 0, 1 ) eq 'g' ) { $surf = 'g' }
    elsif ( substr( $surface, 0, 1 ) eq 'p' ) { $surf = 'p' }
    else                                      { $surf = '' }

    if ( $design eq 'inveg' || $design eq 'iv' ) { $manfile = '3inslope.man' }
    elsif ( $design eq 'inbare' || $design eq 'ib' ) {
        $manfile = '3inslope.man';
    }
    elsif ( $design eq 'outunrut' || $design eq 'ou' ) {
        $manfile = '3outunr.man';
    }
    elsif ( $design eq 'outrut' || $design eq 'or' ) {
        $manfile = '3outrut.man';
    }

    if ( $traffic eq 'none' ) {
        if ( $manfile eq '3inslope.man' ) { $manfile = '3inslopen.man' }
        if ( $manfile eq '3outunr.man' )  { $manfile = '3outunrn.man' }
        if ( $manfile eq '3outrut.man' )  { $manfile = '3outrutn.man' }
    }
    return $manfile;
}

sub display_log {

    # $logFile
    # $climate_name

    my $project;         # project title from log
    my $climate_name;    # Climate station name
    my $STx;             # Soil texture
    my $units;           # project units from log
    my $years;           # years of run
    my $lu;              # length units ('m' or 'ft')
    my $du;              # depth units ('mm' or 'in')
    my $vu;              # volume units ('kg' or 'lb')
    my $t;               # generic term from log

    if ( -e $logFile ) { # display it
        open LOG, "<" . $logFile;
        $project = <LOG>;
        chomp $project;
        $climate_name = <LOG>;
        chomp $climate_name;
        $STx = <LOG>;
        chomp $STx;
        $units = <LOG>;
        chomp $units;
        $years = <LOG>;
        chomp $years;
        if   ( $units eq "ft" ) { $lu = "ft"; $du = "in"; $vu = "lb" }
        else                    { $lu = "m";  $du = "mm"; $vu = "kg" }
        $preci = <LOG>;
        chomp $preci;
        $preci_0 = sprintf '%d',
          $preci;    # DEH 2009.09.18 remove depricated format specification
        print "
<a name='results'></a>
    <center>
     <h4>$project</h4>
     <table border=1>
      <tr>
       <td colspan=2>
        <font face='arial, helvetica, sans serif'>$climate_name<br>
         <font size=1>
";
        print &GetParSummary($climatePar, $units);
        print "
         </font>
        </font>
       </td>
      </tr>
      <tr><td width='50%'><font face='arial, helvetica, sans serif'>$STx soil</font></td>
          <td><font face='arial, helvetica, sans serif'>$years year run</font></td></tr>
      <tr><td colspan=2><font face='arial, helvetica, sans serif'>Average annual precipitation $preci_0 $du</font></td></tr>
     </table>
    </center>
    <br>
    <font size=-1>
[<a href=\"javascript:popupcopyhelp()\">Help copying output to a spreadsheet</a>]
    </font>
    <center>
     <table border=1>
      <tr>
       <th bgcolor='lightblue'>
        <font face='Arial, Geneva, Helvetica'>
         Run number
        </font>
       </th>
       <th bgcolor='lightblue'>
        <font face='Arial, Geneva, Helvetica'>
         Design
        </font>
       </th>
       <th bgcolor='lightblue'>
        <font face='Arial, Geneva, Helvetica'>
         Surface, traffic
        </font>
       </th>
       <th bgcolor='lightblue'>
        <font face='Arial, Geneva, Helvetica'>
         Road grad (%)
        </font>
       </th>
       <th bgcolor='lightblue'>
        <font face='Arial, Geneva, Helvetica'>
         Road length ($lu)
        </font>
       </th>
       <th bgcolor='lightblue'>
        <font face='Arial, Geneva, Helvetica'>
         Road width ($lu)
        </font>
       </th>
       <th bgcolor='lightblue'>
        <font face='Arial, Geneva, Helvetica'>
         Fill grad (%)
        </font>
       </th>
       <th bgcolor='lightblue'>
        <font face='Arial, Geneva, Helvetica'>
         Fill length ($lu)
        </font>
       </th>
       <th bgcolor='lightblue'>
        <font face='Arial, Geneva, Helvetica'>
         Buff grad (%)
        </font>
       </th>
       <th bgcolor='lightblue'>
        <font face='Arial, Geneva, Helvetica'>
         Buff length ($lu)
        </font>
       </th>
       <th bgcolor='lightblue'>
        <font face='Arial, Geneva, Helvetica'>
         Rock cont (%)
        </font>
       </th>
       <th bgcolor='lightgreen'>
        <font face='Arial, Geneva, Helvetica'>
         Average annual rain runoff ($du)
        </font>
       </th>
       <th bgcolor='lightgreen'>
        <font face='Arial, Geneva, Helvetica'>
         Average annual snow runoff ($du)
        </font>
       </th>
       <th bgcolor='lightgreen'>
        <font face='Arial, Geneva, Helvetica'>
         Average annual sediment leaving road ($vu)
        </font>
       </th>
       <th bgcolor='lightgreen'>
        <font face='Arial, Geneva, Helvetica'>
         Average annual sediment leaving buffer ($vu)
        </font>
       </th>
       <th bgcolor='lightblue'>
        <font face='Arial, Geneva, Helvetica'>
         Comment
        </font>
       </th>
      </tr>
";

        while ( !eof LOG ) {
            print "    <tr>
";
            if ($subs) { my $preci = <LOG> }

            $subs = 1;
            my $run = <LOG>;

            #       my $clima=<LOG>;
            #       my $soilt=<LOG>;
            my $roadd = <LOG>;
            my $surfa = <LOG>;
            my $roadg = <LOG>;
            my $roadl = <LOG>;
            my $roadw = <LOG>;
            my $fillg = <LOG>;
            my $filll = <LOG>;
            my $buffg = <LOG>;
            my $buffl = <LOG>;
            my $rockf = <LOG>;
            my $rainr = <LOG>;
            $rainr = sprintf '%.1f', $rainr;
            my $snowr = <LOG>;
            $snowr = sprintf '%.1f', $snowr;
            my $sedir = <LOG>;
            $sedir = sprintf '%.0f', $sedir;
            my $sedip = <LOG>;
            $sedip = sprintf '%.0f', $sedip;
            my $comme = <LOG>;

            $sedir = commify($sedir);
            $sedip = commify($sedip);

            $td_tag = '<td bgcolor="lightblue">';

#        $td_tag='<td bgcolor="coral">' if ($surfa =~ /low/ || $surfa =~ /none/);
#        $td_tag='<td bgcolor="coral">' if (lc($surfa) =~ /none/);    # DEH 2015.03.02
            $td_tag = '<td bgcolor="red">' if ( $run =~ / !/ );
            print "     $td_tag
        <font face='Arial, Geneva, Helvetica'>
         $run
        </font>
       </td>
       <td align='center'>
        <font face='Arial, Geneva, Helvetica'>
         $roadd
        </font>
       </td>
       <td align='center'>
        <font face='Arial, Geneva, Helvetica'>
         $surfa
        </font>
       </td>
       <td align='right'>
        <font face='Arial, Geneva, Helvetica'>
         $roadg
        </font>
       </td>
       <td align='right'>
        <font face='Arial, Geneva, Helvetica'>
         $roadl
        </font>
       </td>
       <td align='right'>
        <font face='Arial, Geneva, Helvetica'>
         $roadw
        </font>
       </td>
       <td align='right'>
        <font face='Arial, Geneva, Helvetica'>
         $fillg
        </font>
       </td>
       <td align='right'>
        <font face='Arial, Geneva, Helvetica'>
         $filll
        </font>
       </td>
       <td align='right'>
        <font face='Arial, Geneva, Helvetica'>
         $buffg
        </font>
       </td>
       <td align='right'>
        <font face='Arial, Geneva, Helvetica'>
         $buffl
        </font>
       </td>
       <td align='right'>
        <font face='Arial, Geneva, Helvetica'>
         $rockf
        </font>
       </td>
       <td align='right'>
        <font face='Arial, Geneva, Helvetica'>
         $rainr
        </font>
       </td>
       <td align='right'>
        <font face='Arial, Geneva, Helvetica'>
         $snowr
        </font>
       </td>
       <td align='right'>
        <font face='Arial, Geneva, Helvetica'>
         $sedir
        </font>
       </td>
       <td align='right'>
        <font face='Arial, Geneva, Helvetica'>
         $sedip
        </font>
       </td>
       <td>
        <font face='Arial, Geneva, Helvetica'>
         $comme
        </font>
       </td>
";
        }
        close LOG;

        # DEH 2015.03.02
        print "
     </tr>
     <tr>
      <td colspan=16>
       <font color='coral'></font>
      </td>
    </tr>
    </table>
    <br>
";
        if ($debug) {
            print "
    <font size=-1>$logFile</font>
";
        }
        print "
   </center>
";
    }
    else {
        print "No log file found\n";
    }
}    # display_log()

sub commify {
    my $text = reverse $_[0];
    $text =~ s/(\d\d\d)(?=\d)(?!d*\.)/$1,/g;
    return scalar reverse $text;
}

# ------------------------ end of subroutines ----------------------------
