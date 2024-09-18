#! /usr/bin/perl
#! /fsapps/fssys/bin/perl
#
# wrbat.pl
#
# WEPP:Road batch

# 2004.07.20 remove 'low' traffic from provisional warning
#		Allow 'inveg', 'native' etc.
# 2004.06.30
# 31 January 2002
# David Hall, USDA Forest Service, Rocky Mountain Research Station

   $version='2015.03.02';	# lost sediment leaving buffer (always zero) after last change.  Remove provisional warnings.
#  $version='2015.02.10';	# switch, belatedly, to WEPP version 2010. frost.txt is in the directory.
#  $version='2013.01.01';	# add calendar code
#  $version='2011.06.30';       # log road segment count
#  $version='2009.12.02';	# report Latitude, Longitude, Elevation for modified climate
#  $version='2009.09.18';	# patch for stand-alone use (sprintf format and DOS/unix linebreaks)
#  $version='2006.09.14';	# report climate file mods if appropriate (readPARfile()) on final results page
#  $version='2004.07.20';
   $debug=0;
   $batch=1;

   $weppversion="wepp2010";

   $count_limit = 1000;
#  $count_limit = 200;
#-rwxrwxr-x 1 dhall 502 85296 2011-07-18 13:13 wrbat.pl

# NOTE: one instance of 'fsweb.rmrs...'
# To do:
#
#       Appears not to write to .dit files (2014, 2015) [allows tracking wrb road segment count]
#       Auto-history popup
#	better validate Climate '../climates/ca045983'
#	doesn't recognize personality (a..z)
#  X	less apparent precision in results

#  2011.06.30 DEH log road segment count directly into WEPP:Road counts as well as log model run count
#  2009.12.02 DEH report Latitude, Longitude, Elevation for modified climate
#  2009.09.18 DEH patch for stand-alone use (sprintf format and DOS/unix linebreaks)
#  2006.09.14 DEH report climate file mods if appropriate (readPARfile()) on final results page
#  2004.07.20 Color code provisional status for 'no' traffic only
#  2004.06.30 Color code provisional status for 'low' and 'no' traffic
#		Update &createsoilfile to adjust Ki as well for low/none
#		Print $UBR not $rf to logfile
#  2004.06.29 Write number-of-years to WRBLOG after "units" (and read it back in)
#		Note: this will cause bad load of old-format 'previous log'
#		Add undocumented "Extended output" checkbox
#  2004.06.28 Changed 'ne' to '!=' in validate-slope and validate_length
#		and validate_rock
#		Align right (good) and left (bad) for check-input table
#  2004.06.28 Notified that low-traffic results did not match non-batch
#		%rock value not tracked correctly in log
#             Also: number of years of run not in log
#		validate_slope and validate_length not working
#  2004.06.18 Note that results are Average Annual values
#  2004.06.14 highlight error text in red if any on input data check
#		'invalid run' or 'invalid runs' depending
#		'Make corrections below' message if errors; allow check only
#		'Comment' is input; color it green
#		help screen for pasting results into Excel
#		move precip report out of loop (all same for a sequence)
#		  thus change order of wrblog fields
#		remove 'die' and add footer on check-only run
#		Redirect to /fswepp/ if no parameters (bad bookmark/link)
#		Record in WRBLOG only if run (not if check input)
#  2004.05.13 Change order of columns in "spreadsheet"
#		Use run time and date for project title in log if null
#		validate years
#		validate units 'm' 'ft'
#		validate Climate '../climates/ca045983'
#		validate SoilType 'clay' 'loam' 'silt' 'sand'
#  2004.05.12 Increase units-sensitive input-error-checking
#	      detag projectdescription
#  2004.05.07 Pull climate and soil texture out of log loop
#		Change log table order to match input table (poor as it is)
#		Color code input and output columns in log table
#  2004.05.06	Allow only display of previous log file
#  2004.05.03 DEH add switch for "extended output"

   $wepphost="localhost";
   if (-e "../wepphost") {
     open HOST, "<../wepphost";
     $wepphost=lc(<HOST>);
     chomp $wepphost;
     close HOST;
   }

   $platform="pc";
   if (-e "../platform") {
     open Platform, "<../platform";
     $platform=lc(<Platform>);
     chomp $platform;
     close Platform;
   }

   &ReadParse(*parameters);

###

#  $me=$parameters{'me'};
#  $units=$parameters{'units'};
#  $traffic=$parameters{'traffic'};
   $action=$parameters{'ActionC'} .
           $parameters{'ActionW'} .
           $parameters{'ActionCD'} .
           $parameters{'ActionSD'} .
           $parameters{'old_log'} .
           $parameters{'submit'};
   chomp $action;
   $achtung=$parameters{'achtung'};
#   $climate_name=$parameters{'climate_name'};   ######### requested #########
   $extended=$parameters{'extended'};
#  $extended=1;						##### DEH 2004
   $project_title=&detag($parameters{'projectdescription'});

####

#  determine which week the model is being run, for recording in the weekly runs log

#   $thisday   -- day of the year (1..365)
#   $thisyear  -- year of the run (ie, 2012)
#   $dayoffset -- account for which day of the week Jan 1 is: -1: Su; 0: Mo; 1: Tu; 2: We; 3: Th; 4: Fr; 5: Sa.

   $thisday = 1 + (localtime)[7];               # $yday, day of the year (0..364)
   $thisyear = 1900 + (localtime)[5];           # https://perldoc.perl.org/functions/localtime.html

   if    ($thisyear == 2010) { $dayoffset = 4 } # Jan 1 is Friday
   elsif ($thisyear == 2011) { $dayoffset = 5 } # Jan 1 is Saturday
   elsif ($thisyear == 2012) { $dayoffset =-1 } # Jan 1 is Sunday
   elsif ($thisyear == 2013) { $dayoffset = 1 } # Jan 1 is Tuesday
   elsif ($thisyear == 2014) { $dayoffset = 2 } # Jan 1 is Wednesday
   elsif ($thisyear == 2015) { $dayoffset = 3 } # Jan 1 is Thursday
   elsif ($thisyear == 2016) { $dayoffset = 4 } # Jan 1 is Friday
   elsif ($thisyear == 2017) { $dayoffset =-1 } # Jan 1 is Sunday
   elsif ($thisyear == 2018) { $dayoffset = 0 } # Jan 1 is Monday
   elsif ($thisyear == 2019) { $dayoffset = 1 } # Jan 1 is Tuesday
   elsif ($thisyear == 2020) { $dayoffset = 2 } # Jan 1 is Wednesday
   elsif ($thisyear == 2021) { $dayoffset = 4 } # Jan 1 is Friday
   elsif ($thisyear == 2022) { $dayoffset = 5 } # Jan 1 is Saturday
   elsif ($thisyear == 2023) { $dayoffset =-1 } # Jan 1 is Sunday
   elsif ($thisyear == 2024) { $dayoffset = 0 } # Jan 1 is Monday
   elsif ($thisyear == 2025) { $dayoffset = 2 } # Jan 1 is Wednesday
   else                      { $dayoffset = 0 }

   $thisdayoff=$thisday+$dayoffset;
   $thisweek = 1 + int $thisdayoff/7;
#  print "[$dayoffset] Julian day $thisday, $thisyear: week $thisweek\n";

     if (($action . $achtung) eq '') {
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

#   $action=$parameters{'submit'};
   $spread = $parameters{'spread'};
   $CL=$parameters{'Climate'};         # get Climate (file name base)
   $ST=$parameters{'SoilType'};
   $units=$parameters{'units'};
   $years=$parameters{'years'};
   $climyears=$parameters{'climyears'};
#   $me=$parameters{'me'};

   if ($units ne 'm' && $units ne 'ft') {$units = 'm'}

   $climatePar = "$CL" . '.par';
   $climate_name = &getCligenStationName;

   if    ($ST eq 'clay') {$STx = 'clay loam'} 
   elsif ($ST eq 'silt') {$STx = 'silt loam'} 
   elsif ($ST eq 'sand') {$STx = 'sandy loam'} 
   elsif ($ST eq 'loam') {$STx = 'loam'} 

   $host = $ENV{REMOTE_HOST};
      $user_ID=$ENV{'REMOTE_ADDR'};                  
      $user_really=$ENV{'HTTP_X_FORWARDED_FOR'};     
      $user_ID=$user_really if ($user_really ne ''); 
      $user_ID =~ tr/./_/;                           
      $user_ID = $user_ID . $me;                     
      $logFile = "../working/" . $user_ID . ".wrblog";
   if ($host eq "") {$host = 'unknown'}

# ======================  CUSTOM CLIMATE  ======================

   if (lc($action) =~ /custom/) {
     $wepproadbat = "https://" . $wepphost . "/cgi-bin/fswepp/wr/wepproadbat.pl"; 
     if ($platform eq "pc") {
       exec "perl ../rc/rockclim.pl -server -i$me -u$units $wepproadbat"
     }
     else {
       exec "../rc/rockclim.pl -server -i$me -u$units $wepproadbat"
     }
   }

# ======================  DESCRIBE CLIMATE  ======================         

   if ($achtung =~ /Describe Climate/ && $action eq '') {
     $wepproadbat = "https://" . $wepphost . "/cgi-bin/fswepp/wr/wepproadbat.pl"; 
     if ($platform eq "pc") {
       exec "perl ../rc/descpar.pl $CL $units $wepproadbat"
     }
     else {
       exec "../rc/descpar.pl $CL $units $wepproadbat"
     }
     die
   }

#=========================================================================

   goto skip_check if (lc($action) =~ /display previous log/);

#=========================================================================

   $checkonly = 0;
   $checkonly = 1 if (lc($action) eq 'check input');

   if ($platform eq "pc") {
     if (-e 'd:/fswepp/working') {$working = 'd:\\fswepp\\working'}
     elsif (-e 'c:/fswepp/working') {$working = 'c:\\fswepp\\working'}
     else {$working = '..\\working'}
     $newSoilFile  = "$working\\wrwepp.sol";
     $responseFile = "$working\\wrwepp.in";
     $outputFile   = "$working\\wrwepp.out";
     $stoutFile    = "$working\\wrwepp.sto";
     $sterFile     = "$working\\wrwepp.err";
     $slopeFile    = "$working\\wrwepp.slp";
     $soilPath     = 'data\\';
     $manPath      = 'data\\';
     $logFile      = "$working\\wrblog";
   }
   else {
     $working = '../working';
     $unique='wepp' . '-' . $$;
     $newSoilFile  = "$working/" . $unique . '.sol';
     $responseFile = "$working/" . $unique . '.in';
     $outputFile   = "$working/" . $unique . '.out';
     $stoutFile    = "$working/" . $unique . '.stout';
     $sterFile     = "$working/" . $unique . '.sterr';
     $slopeFile    = "$working/" . $unique . '.slp';
     $soilPath     = 'data/';
     $manPath      = 'data/';
     $logFile      = "$working/" . $user_ID . ".wrblog";
   }

# ########### PARSE TEXTAREA data and check

skip_check:

     print "Content-type: text/html\n\n";
     print "<HTML>
 <HEAD>
  <TITLE>WEPP:Road batch results</TITLE>
   <script language=\"javascript\">

    function popuphistory() {
     url = '';
     height=500;
     width=660;
     popupwindow = window.open(url,'popupwindow','toolbar=no,location=no,status=no,directories=no,menubar=no,scrollbars=yes,resizable=yes,width='+width+',height='+height);
     if (popupwindow != null) {
      popupwindow.document.writeln('<html>')
      popupwindow.document.writeln(' <head>')
      popupwindow.document.writeln('  <title>WEPP:Road Batch version history</title>')
      popupwindow.document.writeln(' </head>')
      popupwindow.document.writeln(' <body bgcolor=white>')
      popupwindow.document.writeln('  <font face=\"arial, helvetica, sans serif\">')
      popupwindow.document.writeln('  <center>')
      popupwindow.document.writeln('   <h4>WEPP:Road Batch version history</h4>')

      popupwindow.document.writeln('   <p>')
      popupwindow.document.writeln('   <table border=0 cellpadding=10>')
      popupwindow.document.writeln('    <tr>')
      popupwindow.document.writeln('     <th bgcolor=85d2d2>Version</th>')
      popupwindow.document.writeln('     <th bgcolor=85d2d2>Comments</th>')
      popupwindow.document.writeln('    </tr>')

      popupwindow.document.writeln('    <tr>')
      popupwindow.document.writeln('     <th valign=top bgcolor=85d2d2>2015.03.02</th>')
      popupwindow.document.writeln('     <td>Correct reporting of sediment leaving buffer from previous revision; remove provisional warnings</td>')
      popupwindow.document.writeln('    </tr>')

      popupwindow.document.writeln('    <tr>')
      popupwindow.document.writeln('     <th valign=top bgcolor=85d2d2>2015.02.10</th>')
      popupwindow.document.writeln('     <td>Switch to WEPP 2010.100</td>')
      popupwindow.document.writeln('    </tr>')

      popupwindow.document.writeln('    <tr>')
      popupwindow.document.writeln('     <th valign=top bgcolor=85d2d2>2011.06.30</th>')
      popupwindow.document.writeln('     <td>log road segment count</td>')
      popupwindow.document.writeln('    </tr>')

      popupwindow.document.writeln('    <tr>')
      popupwindow.document.writeln('     <th valign=top bgcolor=85d2d2>2004.06.30</th>')
      popupwindow.document.writeln('     <td>')
      popupwindow.document.writeln('     Modify Ki as well as Kr soil parameters for low/no traffic;<br>')
      popupwindow.document.writeln('     Correctly report rock fragment to log file;<br>')
      popupwindow.document.writeln('     Include number-of-years run to log<br>')
      popupwindow.document.writeln('       (Note: this will cause bad load of old-format \"previous log\");<br>')
      popupwindow.document.writeln('     Add undocumented \"Extended output\" checkbox<br>')
      popupwindow.document.writeln('     Adjust validation of slope, length, and rock;<br>')
      popupwindow.document.writeln('     Align right (good) and left (bad) for check-input table;<br>')
      popupwindow.document.writeln('     Color code provisional status for no traffic<br>')
      popupwindow.document.writeln('     </td>')
      popupwindow.document.writeln('    </tr>')

      popupwindow.document.writeln('    <tr>')
      popupwindow.document.writeln('     <th valign=top bgcolor=85d2d2>2004.06.18</th>')
      popupwindow.document.writeln('     <td>Initial release</td>')
      popupwindow.document.writeln('    </tr>')

      popupwindow.document.writeln('   </table>')
      popupwindow.document.writeln('   <p>')
      popupwindow.document.writeln('  </font>')
      popupwindow.document.writeln('  </center>')
      popupwindow.document.writeln(' </body>')
      popupwindow.document.writeln('</html>')
      popupwindow.document.close()
      popupwindow.focus()
     }
    }

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
  <link rel='stylesheet' type='text/css' href='/fswepp/notebook.css'>
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
      <a href="JavaScript:window.history.go(-1)">
      <img src="https://',$wepphost,'/fswepp/images/roadb.gif"
        align=left border=1
        width=50 height=50
        alt="Return to WEPP:Road batch input screen" 
        onMouseOver="window.status=',"'Return to WEPP:Road batch input screen'",'; return true"
        onMouseOut="window.status=',"' '",'; return true">
    </a>
    <td align=center>
     <hr>
     <H3>WEPP:Road Batch results
      <!-- img src="/fswepp/images/underc.gif" -->
     </H3>
     <hr>
    <td>
<!--
       <A HREF="https://',$wepphost,'/fswepp/docs/wroadbimg.html#wrout">
       <IMG src="https://',$wepphost,'/fswepp/images/ipage.gif"
        align="right" alt="Read the documentation" border=0
        onMouseOver="window.status=\'Read the documentation\'; return true"
        onMouseOut="window.status=\' \'; return true"></a>
-->
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

   goto skip_run if (lc($action) eq 'display previous log');

#=========================================================================

display_errors:

 if ($batch) {
   $spread = $parameters{'spread'};
#!
#   $spread = 'ib n l 12 100 4 45 12 75 20 20 comment 1';
   $spread .= "\n";
   $spreadx = &detag($spread);
 }
#   print $spreadx;
   $num_invalid_records=0;
   $dupes=0;

    $v_years = &valid_years($years);
    $v_units = &valid_units($units);
    $v_clime = &valid_climate($CL);
    $v_soilt = &valid_soiltexture($ST);
    if ($v_clime) {$clime_color='white'} else {$clime_color='red'}
    if ($v_soilt) {$soilt_color='white'} else {$soilt_color='red'}
    if ($v_years) {$years_color='white'} else {$years_color='red'}

    $badcommons = !($v_years && $v_units && $v_clime && $v_soilt);

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
 $prev_head='';
 $count=0;
 if ($batch) {
   $ind=index($spreadx,"\n");
   while ($ind>1) {
     last if ($count > $count_limit);
     $head = substr($spreadx,0,$ind);
     $spreadx = substr($spreadx,$ind+1);
#    next if ($head eq $prev_head);
     $count+=1;
     @inputs[$count] = $head;
     $num_invalid_fields=0;
     ($design,$rs,$tl,$rg,$rl,$rw,$fg,$fl,$bg,$bl,$rf,$comments)=split(' ',$head,12);
     chomp $comments;
     $design=lc $design;
     if ($checkonly) {
       print "    <tr>";
#       print "     <td bgcolor=\"cyan\">$count";
     }
     $valid=1; $valid=0 if ($head eq $prev_head);
     $dupes+=1 if (! $valid);
     &printrunfield($checkonly,$valid,$count);
     $valid = &validate_design($design);&printfield($checkonly,$valid,$design);
     $valid = &validate_surface($rs);   &printfield($checkonly,$valid,$rs);
     $valid = &validate_traffic($tl);   &printfield($checkonly,$valid,$tl);
     $valid = &validate_slope($rg,'r'); &printfield($checkonly,$valid,$rg);
     $valid = &validate_length($rl,'r');&printfield($checkonly,$valid,$rl);
     $valid = &validate_length($rw,'w');&printfield($checkonly,$valid,$rw);
     $valid = &validate_slope($fg,'f'); &printfield($checkonly,$valid,$fg);
     $valid = &validate_length($fl,'f');&printfield($checkonly,$valid,$fl);
     $valid = &validate_slope($bg,'b'); &printfield($checkonly,$valid,$bg);
     $valid = &validate_length($bl,'b');&printfield($checkonly,$valid,$bl);
     $valid = &validate_rock($rf);      &printfield($checkonly,$valid,$rf);
     if ($checkonly) {print "     <td>$comments</td></tr>\n"}
     $num_invalid_records+=1 if $num_invalid_fields > 0;
     $ind=index($spreadx,"\n");
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
     $valid = &validate_design($design);&printfield($checkonly,$valid,$design);
     $valid = &validate_surface($rs);   &printfield($checkonly,$valid,$rs);
     $valid = &validate_traffic($tl);   &printfield($checkonly,$valid,$tl);
     $valid = &validate_slope($rg,'r'); &printfield($checkonly,$valid,$rg);
     $valid = &validate_length($rl,'r');&printfield($checkonly,$valid,$rl);
     $valid = &validate_length($rw,'w');&printfield($checkonly,$valid,$rw);
     $valid = &validate_slope($fg,'f'); &printfield($checkonly,$valid,$fg);
     $valid = &validate_length($fl,'f');&printfield($checkonly,$valid,$fl);
     $valid = &validate_slope($bg,'b'); &printfield($checkonly,$valid,$bg);
     $valid = &validate_length($bl,'b');&printfield($checkonly,$valid,$bl);
     $valid = &validate_rock($rf);      &printfield($check,$validonly,$rf);
 }
 $num_invalid_records_x=$num_invalid_records+$dupes;
 if ($checkonly) {

   $runstext = 'runs';
   if ($num_invalid_records_x == 1) {$runstext = 'run'}
   $textcolorb = '';
   $textcolore = '';
   if ($num_invalid_records_x > 0) {
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
   if ($dupes == 1) {$runstext = 'run'}
   $textcolorb = '';
   $textcolore = '';
   if ($dupes > 0) {
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
    if ($num_invalid_records_x > 0) {
      print "Make corrections below.<br>
"
    }
#######################   check continue
     $spread =~ s/\r//g;			# DEH 2009.09.18 unix to DOS format
     print "
     <FORM name=\"wrbat\" method=post ACTION=\"https://$wepphost/cgi-bin/fswepp/wr/wrbat.pl\">
      <input type=\"hidden\" name=\"me\" value=$me>
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
" if ($num_invalid_records_x == 0 && $count > 0);

#      <input type=\"button\" name=\"rtis\" value=\"Return to previous screen\" onClick=\"JavaScript:window.history.go(-1)\">
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

  $checkonly=1;
  
  if ($count < 1 || $num_invalid_records > 0 || $dupes > 0 || $badcommons) {
    goto display_errors
  }
  die if ($num_invalid_records > 0);

# print form *********************************

#  print '
#  <form name="wrbat" action="https://166.2.22.128/cgi-bin/fswepp/wrd/wrbat.pl" method="post">
#  <TEXTAREA name="spread" cols="70" rows="16">',$spread,'</TEXTAREA>
#  <input type="hidden" name="checked" value="x">
#  <input type="submit" value="submit">
# </form>
#';

# =======================  Create CLIGEN file ====================

   &CreateCligenFile;	# take out of loop (remember file name)

# =======================  Create new log ====================

#   $climate_name = &getCligenStationName;

#  $project_title='for testing only';
      $project_title = &whatdate if ($project_title eq ''); 
      open LOG, ">" . $logFile;
      print LOG "$project_title
$climate_name
$STx
$units
$years
";
      close LOG;

# =======================  Run WEPP  =========================

 for $record (1..$count) {
   if ($batch) {
     ($design,$surface,$traffic,$URS,$URL,$URW,$UFS,$UFL,$UBS,$UBL,$UBR,$comments)=split(' ',@inputs[$record],12);
     chomp $comments;
     $design = lc $design;
   }
   $URL*=1;           # Road length -- buffer spacing (free)
   $URS*=1;           # Road gradient (free)
   $URW*=1;           # road width (free)
   $UFL*=1;           # fill length (free)
   $UFS*=1;           # fill steepness (free)
   $UBL*=1;           # Buffer length (free)
   $UBS*=1;           # Buffer steepness (free)
   $UBR*=1;           # Rock fragment percentage
#  $design=$parameters{'SlopeType'};    # slope type (outunrut, inbare, inveg, outrut)
#  $design=$slope;

   if ($design eq 'ou' || $design eq 'outunrut')  {	# DEH
     $designw = 'Outsloped, unrutted';
     $designx = 'outsloped unrutted'
   }
   elsif ($design eq 'ib' || $design eq 'inbare') {	# DEH
     $designw = 'Insloped, bare ditch';
     $designx = 'insloped bare'
   }
   elsif ($design eq 'iv' || $design eq 'inveg') {	# DEH
     $designw = 'Insloped, vegetated or rocked ditch';
     $designx = 'insloped vegetated'
   }
   elsif ($design eq 'or' || $design eq 'outrut') {	#DEH
     $designw = 'Outsloped, rutted';
     $designx = 'outsloped rutted'
  }

  if    (lc($traffic) eq 'l') {$traffic = 'low'}
  elsif (lc($traffic) eq 'h') {$traffic = 'high'}
  elsif (lc($traffic) eq 'n') {$traffic = 'none'}

  if    (lc($surface) eq 'n') {$surface = 'native'} 
  elsif (lc($surface) eq 'g') {$surface = 'graveled'} 
  elsif (lc($surface) eq 'p') {$surface = 'paved'} 

   if ($debug) {
     print @inputs[1],"<br>\nUnits: $units<br>
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
     I am '$me', units '$units' <br>
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
   if ($rcin >= 0) {

       $soilFilefq = $soilPath . &soilfilename;
       $manfile = &manfilename;

       open NEWSOILFILE, ">$newSoilFile";
         print NEWSOILFILE &CreateSoilFile;
       close NEWSOILFILE;
       if ($debug) {print "<pre>creating soil file: $newSoilFile\n", $soilFileBody, "</pre>\n"}
       &CreateSlopeFile;
       &CreateResponseFile;
       @args = ("../$weppversion <$responseFile >$stoutFile 2>$sterFile");			# DEH 2015.02.10
       system @args;

       open weppstout, "<$stoutFile";

       $found = 0;
       while (<weppstout>) {
         if (/SUCCESSFUL/) {
           $found = 1;
           last;
         }
       }  
       close (weppstout);

       if ($found == 0) {       # unsuccessful run -- search STDOUT for error message
         open weppstout, "<$stoutFile";
         while (<weppstout>) {
            if (/ERROR/) {
              $found = 2;
              print "<font color=red>\n";
              $_ = <weppstout>;  $_ = <weppstout>; 
              $_ = <weppstout>;  print;
              $_ = <weppstout>;  print;
              print "</font>\n";
              last;
            }
         }
         close (weppstout);
       }

       if ($found == 0) {
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
         close (weppstout);
       }

       if ($found == 0) {
         open weppstout, "<$stoutFile";
           while (<weppstout>) {
             if (/\*\*\* /) {
             $found = 3;
             print "<font color=red>\n";
             $_ = <weppstout>; print;
             $_ = <weppstout>; print;
             $_ = <weppstout>; print;
             $_ = <weppstout>; print;
             print "</font>\n";
             last;
           }
         }
         close (weppstout);
       }

       if ($found == 0) {
         open weppstout, "<$stoutFile";
         while (<weppstout>) {
           if (/MATHERRQQ/) {
             $found = 5;
             print "<font color=red>\n";
             print 'WEPP has run into a mathematical anomaly.<br>
             You may be able to get around it by modifying the geometry slightly;
             try changing road length by 1 foot (1/2 meter) or so.
             ';
             $_ = <weppstout>; print;
             print "</font>\n";
             last;
           }
         }
         close (weppstout);
       }

       if ($found == 1) {       # Successful run -- get actual WEPP version number
         open weppout, "<$outputFile";
         $ver = 'unknown';
         while (<weppout>) {
           if (/VERSION/) {
              $weppver = $_;
              last;
           }
         }


         while (<weppout>) {     # read actual climate file used from WEPP output
           if (/CLIMATE/) {
             $a_c_n=<weppout>;
             $actual_climate_name=substr($a_c_n,index($a_c_n,":")+1,40);
             $climate_name = $actual_climate_name;
             last;
           }
         }

         while (<weppout>) {
           if (/RAINFALL AND RUNOFF SUMMARY/) {
             $_ = <weppout>; #      -------- --- ------ -------
             $_ = <weppout>; # 
             $_ = <weppout>; #       total summary:  years    1 -    1
             $_ = <weppout>; # 
             $_ = <weppout>; #         71 storms produced                          346.90 mm of precipitation
             $storms = substr $_,1,10;
             $_ = <weppout>; #          3 rain storm runoff events produced          0.00 mm of runoff
             $rainevents = substr $_,1,10;
             $_ = <weppout>; #          2 snow melts and/or
             $snowevents = substr $_,1,10;
             $_ = <weppout>; #              events during winter produced            0.00 mm of runoff
             $_ = <weppout>; # 
             $_ = <weppout>; #      annual averages
             $_ = <weppout>; #      ---------------
             $_ = <weppout>; #
             $_ = <weppout>; #        Number of years                                    1
             $_ = <weppout>; #        Mean annual precipitation                     346.90    mm
             $precip = substr $_,51,10;
             $_ = <weppout>; $rro = substr $_,51,10;   # print; 
             $_ = <weppout>; # print;
             $_ = <weppout>; $sro = substr $_,51,10;   # print; 
             $_ = <weppout>; # print;
             last;
           }
         }

         while (<weppout>) {
           if (/AREA OF NET SOIL LOSS/) {
             $_ = <weppout>;             $_ = <weppout>;
             $_ = <weppout>;             $_ = <weppout>;
             $_ = <weppout>;             $_ = <weppout>; # print;
             $_ = <weppout>; # print;
             $_ = <weppout>; # print;
             $_ = <weppout>; # print;
             $_ = <weppout>; # print;
             $syr = substr $_,17,7;  
             $effective_road_length = substr $_,9,9;
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
             $_ = <weppout>;		# DEH 2015.03.02
#            $_ = <weppout>;
#            $_ = <weppout>; $syp = substr $_,50,9;   # pre-WEPP 98.4
#            $_ = <weppout>; $syp = substr $_,49,10;  # pre-WEPP 98.4
             $_ = <weppout>; $syp = substr $_,0,19;   # WEPP 2010.100   # DEH 2015.03.02
#            $_ = <weppout>; if ($syp eq "") {$syp = substr $_,10,9} # off-site yield
#            $_ = <weppout>; if ($syp eq "") {$syp = substr $_,9,10} # off-site yield
             $_ = <weppout>; if ($syp eq "") {
                                              @sypline = split ' ',$_;
                                              $syp = @sypline[0];
                                             }
             $_ = <weppout>;             $_ = <weppout>;
             last;
           }
         }
         close (weppout);

         $storms+=0;
         $rainevents+=0;
         $snowevents+=0;
         $precip+=0;
         $rro+=0;
         $sro+=0;
         $syr+=0;
         $syp+=0;
         $syra=$syr * $effective_road_length * $WeppRoadWidth;
         $sypa=$syp * $WeppRoadWidth;

        if ($surface eq 'graveled') {$URR = 65; $UFR = ($UBR+65)/2}
	elsif ($surface eq 'paved') {$URR = 95; $UFR = ($UBR+65)/2}
        else {$URR = $UBR; $UFR = $UBR}

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

         if ($units eq "m") {
           $precipunits = "mm"; 
           $sedunits = "kg";
           $pcpfmt = '%.0f';
         }
         else {					# convert WEPP metric results to in and lb
           $precipunits = "in";
           $precip      = $precip / 25.4;
           $rro         = $rro    / 25.4;
           $sro         = $sro    / 25.4;
           $sedunits    = "lb";
           $syra        = $syra * 2.2046;
           $sypa        = $sypa * 2.2046;
           $pcpfmt = '%.2f';
         }
#        $precipf = sprintf "%.0f", $precip;
#        $rrof = sprintf "%.0f", $rro;
#        $srof = sprintf "%.0f", $sro;
         $precipf = sprintf $pcpfmt, $precip;
         $rrof = sprintf $pcpfmt, $rro;
         $srof = sprintf $pcpfmt, $sro;
         $syraf = sprintf "%.2f", $syra;
         $sypaf = sprintf "%.2f", $sypa;

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
     }		# if ($extended)

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
       else {           # ($found != 1)
#        print "<p>\nSomething has gone awry!\n<p><hr><p>\n";
         print "<p>\nI'm sorry; WEPP did not run successfully.\n";

#          WEPP's error message follows:  \n<p><hr><p>\n";

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

       if ($outputf==1) {
         print '<CENTER><H2>WEPP output</H2></CENTER>';
         print '<font face=courier><PRE>';
         open weppout, "<$outputFile";
         while (<weppout>){
           print;
         }
         close weppout;
         print '</PRE></font>
     <form>
      <a onMouseOver="window.status=\'Return to input screen (may be previous incarnations of this screen along the way)\';return true"
          onMouseOut="window.status=\'Forest Service WEPP:Road Batch\'">
       <input type="button" name="rtis" value="Return to previous screen" onClick="JavaScript:window.history.go(-1)">
      </a>
     </form>
<p><center><hr>
<a href="JavaScript:window.history.go(-1)">
<img src="https://',$wepphost,'/fswepp/images/rtis.gif"
     alt="Return to input screen" border="0" aligh=center></A>
<BR><HR></center>
';
       }
       print "<br>\n";
   }   #   if ($rcin >= 0)

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
     <a onMouseOver="window.status=\'Return to input screen (may be previous incarnations of this screen along the way)\';return true"
        onMouseOut="window.status=\'Forest Service WEPP:Road Batch\'">
      <input type="button" name="rtis" value="Return to previous screen" onClick="JavaScript:window.history.go(-1)">
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
       <a href="javascript:popuphistory()">',$version,'</a>
       based on WEPP ',$weppver,'<br> by
       <a href="https://forest.moscowfsl.wsu.edu/people/engr/dehall.html">David Hall</a>
       and 
       Darrell Anderson;
       Project leader
       <a href="https://forest.moscowfsl.wsu.edu/people/engr/welliot.html">Bill Elliot</a>
       <br>
       USDA Forest Service, Rocky Mountain Research Station, Moscow, ID 83843
       <br>
';
#      &printdate;
       print &whatdate;
       print '
     </td>
     <td>
      <font face="Arial, Geneva, Helvetica, sans serif">
       <a href="https://',$wepphost,'/fswepp/comments.html"
        onClick="return confirm(\'You need to be connected to the Internet to e-mail comments. Shall I try?\')">
      <img src="https://',$wepphost,'/fswepp/images/epaemail.gif" align="right" border=0></a>
      </font>
     </td>
    </tr>
   </table>
  </center>
 </body>
</html>
';

#   unlink <"$working/$unique.*">;

###   unlink $responseFile;
###   unlink $outputFile;
###   unlink $stoutFile;
###   unlink $sterFile;
###   unlink $slopeFile;

#  record activity in WEPP:Road log (if running on remote server)

  if (lc($action) eq 'run wepp') {
   if (lc($wepphost) ne "localhost") {
     $todaysdate=&whatdate;
     open WRBLOG, ">>../working/_$thisyear/wrb.log";		# 2013.01.01 DEH
       flock (WRBLOG,2);
       $host = $ENV{REMOTE_HOST};
       if ($host eq "") {$host = $ENV{REMOTE_ADDR} };
#      print WRBLOG "$host\t$todaysdate\t$years2sim * $count\t$climate_name\n";
       print WRBLOG "$host\t$todaysdate\t$years2sim\t$count\t$climate_name\n";
     close WRBLOG;

     open CLIMLOG, ">../working/_$thisyear/lastclimate.txt";       # 2013.01.01 DEH
       flock CLIMLOG,2;
       print CLIMLOG 'WEPP:Road batch: ', $climate_name;
     close CLIMLOG;

#     $thisday = 1+(localtime)[7];                      # $yday, day of the year (0..364)
#     $thisdayoff=$thisday+3;                            # [Jan 1] -1: Sunday 0: Monday
#     $thisweek = 1+ int $thisdayoff/7;

### record model runs ###

     $ditlogfile = ">>../working/_$thisyear/wrb/$thisweek";	# 2013.01.01 DEH
     open MYLOG,$ditlogfile;
       flock MYLOG,2;			# 2005.02.09 DEH
#      print MYLOG '.' x $count;	# 2005.02.10 DEH
       print MYLOG '.';			# 2007.01.01 DEH
     close MYLOG;

### record road segment count into WEPP:ROad logs###

     $ditlogfile = ">>../working/_$thisyear/wr/$thisweek";	# 2013.01.01 DEH
     open MYLOG,$ditlogfile;
       flock MYLOG,2;                   # 2005.02.09 DEH
       print MYLOG '.' x $count;        # 2005.02.10 DEH
     close MYLOG;
   }
  }

done:

  $x='done';

# ------------------------ subroutines ---------------------------

sub ReadParse {

# ReadParse -- from cgi-lib.pl (Steve Brenner) from Eric Herrmann's
# "Teach Yourself CGI Programming With PERL in a Week" p. 131

  local (*in) = @_ if @_;
  local ($i, $loc, $key, $val);

  if ($ENV{'REQUEST_METHOD'} eq "GET") {
    $in = $ENV{'QUERY_STRING'};
  } elsif ($ENV{'REQUEST_METHOD'} eq "POST") {
    read(STDIN,$in,$ENV{'CONTENT_LENGTH'});
  }
  @in = split(/&/,$in);
  foreach $i (0 .. $#in) {
    $in[$i] =~ s/\+/ /g;			# Convert pluses to spaces
    ($key, $val) = split(/=/,$in[$i],2);	# Split into key and value
    $key =~ s/%(..)/pack("c",hex($1))/ge;	# Convert %XX from hex numbers to alphanumeric
    $val =~ s/%(..)/pack("c",hex($1))/ge;
    $in{$key} .= "\0" if (defined($in{$key}));  # \0 is the multiple separator
    $in{$key} .= $val;
  }
  return 1;
 }

sub whatdate {

 my @months=qw(January February March April May June July August September October November December);
 my @days=qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);
 my @ampm=('am','pm');
 my $ampmi=0;
 my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst);
#    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime;
#    if ($hour == 12) {$ampmi = 1}
#    if ($hour > 12) {$ampmi = 1; $hour = $hour - 12}
#    printf "%0.2d:%0.2d ", $hour, $min;
#    print $ampm[$ampmi],"  ",$days[$wday]," ",$months[$mon];
#    print " ",$mday,", ",$year+1900, " GMT<br>\n";
#    if (lc($wepphost) ne "localhost") {
      $ampmi = 0;
      ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime;
      if ($hour == 12) {$ampmi = 1}
      if ($hour > 12) {$ampmi = 1; $hour = $hour - 12}
      my $Year=$year+1900;
      $temp = sprintf "%0.2d:%0.2d ", $hour, $min;
      $temp .= @ampm[$ampmi] . "  " . @days[$wday] . " " . @months[$mon];
#     $temp .= " " . $mday . ", " . $Year . " (Pacific Time)";
      $temp .= " " . $mday . ", " . $Year;
      return $temp;
#    } 
}

#---------------------------

sub CreateSlopeFile {

# create slope file from specified geometry

     $userRoadSlope  = $URS / 100;		# road slope in decimal percent
     $userFillSlope  = $UFS / 100;
     $userBuffSlope  = $UBS / 100;
     if ($units eq 'm') {
       $userRoadWidth  = $URW;			# road width in meters
       $userRoadLength = $URL;
       $userFillLength = $UFL;
       $userBuffLength = $UBL;
     }
     else {$tom = 0.3048;
       $userRoadWidth  = sprintf "%.2f", $URW * $tom;
       $userRoadLength = sprintf "%.2f", $URL * $tom;
       $userFillLength = sprintf "%.2f", $UFL * $tom;
       $userBuffLength = sprintf "%.2f", $UBL * $tom;
     }
     $WeppRoadSlope  = $userRoadSlope;
     $WeppRoadLength = $userRoadLength;
     $WeppFillSlope  = $userFillSlope;
     $WeppFillLength = $userFillLength;
     $WeppBuffSlope  = $userBuffSlope;
     $WeppBuffLength = $userBuffLength;
     if ($WeppRoadLength < 1) {$WeppRoadLength=1}				# minimum 1 m road length

     if ($design eq 'outunrut' || $design eq 'ou') {
       $outslope = 0.04;
       $WeppRoadSlope = sqrt($outslope * $outslope + $WeppRoadSlope * $WeppRoadSlope);		# 11/1999
       $WeppRoadLength = $userRoadWidth  * $WeppRoadSlope / $outslope;
       $WeppRoadWidth =  $userRoadLength * $userRoadWidth / $WeppRoadLength;
     }
     else {
       $WeppRoadWidth = $userRoadWidth;
     }

     open (SlopeFile, ">".$slopeFile);
       print SlopeFile "97.3\n";           # datver
       print SlopeFile "# Slope file for $slope by WEPP:Road Interface\n";
       print SlopeFile "3\n";              # no. OFE
       print SlopeFile "100 $WeppRoadWidth\n";          # aspect; profile width			# 11/1999
                                   # OFE 1 (road)
       printf SlopeFile "%d  %.2f\n", 2,$WeppRoadLength;     # no. points, OFE length
       printf SlopeFile "%.2f, %.2f  ", 0,$WeppRoadSlope;    # dx, gradient
       printf SlopeFile "%.2f, %.2f\n", 1,$WeppRoadSlope;    # dx, gradient
                                   # OFE 2 (fill)
       printf SlopeFile "%d  %.2f\n",   3,   $WeppFillLength; # no. points, OFE length
       printf SlopeFile "%.2f, %.2f  ", 0,   $WeppRoadSlope;  # dx, gradient
       printf SlopeFile "%.2f, %.2f  ", 0.05,$WeppFillSlope;  # dx, gradient
       printf SlopeFile "%.2f, %.2f\n", 1,   $WeppFillSlope;  # dx, gradient
                                   # OFE 3 (buffer)
       printf SlopeFile "%d  %.2f\n",   3,   $WeppBuffLength; # no. points, OFE length
       printf SlopeFile "%.2f, %.2f  ", 0,   $WeppFillSlope;  # dx, gradient
       printf SlopeFile "%.2f, %.2f  ", 0.05,$WeppBuffSlope;  # dx, gradient
       printf SlopeFile "%.2f, %.2f\n", 1,   $WeppBuffSlope;  # dx, gradient
     close SlopeFile;
     return $slopeFile;
 }

sub CreateResponseFile {

     if ($debug) {print "creating $responseFile<br>\n";}
     open (ResponseFile, ">$responseFile");
       print ResponseFile "97.3\n";        # datver
       print ResponseFile "y\n";           # not watershed
       print ResponseFile "1\n";           # 1 = continuous
       print ResponseFile "1\n";           # 1 = hillslope
       print ResponseFile "n\n";           # hillsplope pass file out?
       print ResponseFile "1\n";           # 1 = abreviated annual out
       print ResponseFile "n\n";           # initial conditions file?
       print ResponseFile "$outputFile","\n";  # soil loss output file
       print ResponseFile "n\n";           # water balance output?
       print ResponseFile "n\n";           # crop output?
       print ResponseFile "n\n";           # soil output?
       print ResponseFile "n\n";           # distance/sed loss output?
       print ResponseFile "n\n";           # large graphics output?
       print ResponseFile "n\n";           # event-by-event out?
       print ResponseFile "n\n";           # element output?
       print ResponseFile "n\n";           # final summary out?
       print ResponseFile "n\n";           # daily winter out?
       print ResponseFile "n\n";           # plant yield out?
       print ResponseFile $manPath . $manfile,"\n";      # management file name
       print ResponseFile $slopeFile,"\n";          # slope file name
       print ResponseFile $climateFile,"\n";        # climate file name
       print ResponseFile $newSoilFile, "\n";        # soil file name
       print ResponseFile "0\n";           # 0 = no irrigation
       print ResponseFile "$years2sim\n";  # no. years to simulate
       print ResponseFile "0\n";           # 0 = route all events
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
   my ($pos1, $pos2, $pos3, $pos4);
   my ($ind, $left, $right);

   open SOILFILE, "<$soilFilefq";                                              
   if ($debug) {print "incoming soil file: $soilFilefq $traffic\n"}

   if ($surface eq 'graveled') {$URR = 65; $UFR = ($UBR+65)/2}
   elsif ($surface eq 'paved') {$URR = 95; $UFR = ($UBR+65)/2}
   else {$URR = $UBR; $UFR = $UBR}

# modify 'Kr' for 'no traffic' and 'low traffic'
# modify 'Ki' for 'no traffic' and 'low traffic'

 if ($traffic eq 'low' || $traffic eq 'none') {
   $in = <SOILFILE>;
   $body =  $in;     # line 1; version control number - datver
   $in = <SOILFILE>;          # first comment line
   $body .= "#  $traffic\n";
   $body .= $in;
   while (substr($in,0,1) eq '#') {   # gobble up comment lines
      $in = <SOILFILE>;
      $body .= $in;
   }
   $in = <SOILFILE>;
   $body .= $in;     # line 3: ntemp, ksflag
   $in = <SOILFILE>;
   $pos1 = index ($in,"'");          # location of first apostrophe
   $pos2 = index ($in,"'",$pos1+1);  # location of second apostrophe
   $pos3 = index ($in,"'",$pos2+1);  # location of third apostrophe
   $pos4 = index ($in,"'",$pos3+1);  # location of fourth apostrophe
   my $slid_texid = substr($in,0,$pos4+1);  # slid; texid
   my $rest = substr($in,$pos4+1);
   my ($nsl, $salb, $sat, $ki, $kr, $shcrit, $avke) = split ' ', $rest;
   $kr /= 4;
   $ki /= 4;
if ($debug) {print "\nnsl: $nsl salb $salb sat $sat ki $ki kr $kr shcrit $shcrit avke $avke\n"}
   $body .= "$slid_texid\t";
   $body .= "$nsl\t$salb\t$sat\t$ki\t$kr\t$shcrit\t$avke\n";
 }
   while (<SOILFILE>) {
     $in = $_;
     if (/urr/) {               # user-specified road rock fragment            
#        print 'found urr';                                                    
        $ind = index($in,'urr');                                               
        $left = substr($in,0,$ind);                                            
        $right = substr ($in, $ind+3);                                         
        $in = $left . $URR . $right;                                           
     }                                                                         
     elsif (/ufr/) {            # calculated fill rock fragment            
#        print 'found ufr';                                                    
        $ind = index($in,'ufr');                                               
        $left = substr($in,0,$ind);                                            
        $right = substr ($in, $ind+3);                                         
        $in = $left . $UFR . $right;                                           
     }                                                                         
     elsif (/ubr/) {            # calculated buffer rock fragment          
#        print 'found ubr';                                                    
        $ind = index($in,'ubr');                                               
        $left = substr($in,0,$ind);                                            
        $right = substr ($in, $ind+3);                                         
        $in = $left . $UBR . $right;                                           
     }                                                                         
#     print $in;                                                                
     $body .= $in;                                                    
   }                                                                           
   close SOILFILE;
   return $body;
}

 sub createSoilFile {                                                          
                                                                               
# Read a WEPP:Road soil file template and create a usable soil file.
# File may have 'urr', 'ufr' and 'ubr' as placeholders for rock fragments
# percentage
# Adjust road surface Kr downward for traffic levels of 'low' or 'none'

# David Hall and Darrell Anderson
# November 26, 2001

# uses: $soilFilefq   fully qualified input soil file name
#       $newSoilFile  name of soil file to be created
#       $surface      native, graveled, paved
#       $traffic      High, Low, None
#       $UBR          user-specified rock fragment decimal percentage for buffer
# sets: $URR          calculated rock fragment decimal percentage for road
#       $UFR          calculated rock fragment decimal percentage for fill

   my $in;
   my ($pos1, $pos2, $pos3, $pos4);
   my ($ind, $left, $right);

   open SOILFILE, "<$soilFilefq";                                              
   open NEWSOILFILE, ">$newSoilFile";                                          
                                                                               
   if ($surface eq 'graveled') {$URR = 65; $UFR = ($UBR+65)/2}
   elsif ($surface eq 'paved') {$URR = 95; $UFR = ($UBR+65)/2}
   else {$URR = $UBR; $UFR = $UBR}

# modify 'Kr' for 'no traffic' and 'low traffic'

 if ($traffic eq 'low' || $traffic eq 'none') {
   $in = <SOILFILE>;
   print NEWSOILFILE $in;     # line 1; version control number - datver
   $in = <SOILFILE>;          # first comment line
   print NEWSOILFILE $in;
   while (substr($in,0,1) eq '#') {   # gobble up comment lines
      $in = <SOILFILE>;
      print NEWSOILFILE $in;
   }
   $in = <SOILFILE>;
   print NEWSOILFILE $in;     # line 3: ntemp, ksflag
   $in = <SOILFILE>;
   $pos1 = index ($in,"'");                 # location of first apostrophe
   $pos2 = index ($in,"'",$pos1+1);  # location of second apostrophe
   $pos3 = index ($in,"'",$pos2+1);  # location of third apostrophe
   $pos4 = index ($in,"'",$pos3+1);  # location of fourth apostrophe
   my $slid_texid = substr($in,0,$pos4+1);  # slid; texid
   my $rest = substr($in,$pos4+1);
   my ($nsl, $salb, $sat, $ki, $kr, $shcrit, $avke) = split ' ', $rest;
   $kr /= 4;
   print NEWSOILFILE "$slid_texid\t";
   print NEWSOILFILE "$nsl\t$salb\t$sat\t$ki\t$kr\t$shcrit\t$avke\n";
 }

   while (<SOILFILE>) {                                                        
     $in = $_;                                                                 
     if (/urr/) {               # user-specified road rock fragment            
#        print 'found urr';                                                    
        $ind = index($in,'urr');                                               
        $left = substr($in,0,$ind);                                            
        $right = substr ($in, $ind+3);                                         
        $in = $left . $URR . $right;                                           
     }                                                                         
     elsif (/ufr/) {            # calculated fill rock fragment            
#        print 'found ufr';                                                    
        $ind = index($in,'ufr');                                               
        $left = substr($in,0,$ind);                                            
        $right = substr ($in, $ind+3);                                         
        $in = $left . $UFR . $right;                                           
     }                                                                         
     elsif (/ubr/) {            # calculated buffer rock fragment          
#        print 'found ubr';                                                    
        $ind = index($in,'ubr');                                               
        $left = substr($in,0,$ind);                                            
        $right = substr ($in, $ind+3);                                         
        $in = $left . $UBR . $right;                                           
     }                                                                         
#     print $in;                                                                
     print NEWSOILFILE $in;                                                    
   }                                                                           
   close SOILFILE;                                                             
   close NEWSOILFILE;                                                          
}                                                                              

sub checkInput {

     if ($units eq "m") {
       $lu = "m";
       $minURL = 1;   $maxURL = 300;
       $minURS = 0.1; $maxURS = 40;
       $minURW = 0.3; $maxURW = 100;
       $minUFL = 0.3; $maxUFL = 100;
       $minUFS = 0.1; $maxUFS = 150;
       $minUBL = 0.3; $maxUBL = 300;
       $minUBS = 0.1; $maxUBS = 100;
     }
     else {
       $lu = "ft";
       $minURL = 3;   $maxURL = 1000;
       $minURS = 0.3; $maxURS = 40;
       $minURW = 1;   $maxURW = 300;
#      $minUFL = 1;   $maxUFL = 300;
       $minUFL = 1;   $maxUFL = 1000;
       $minUFS = 0.3; $maxUFS = 150;
       $minUBL = 1;   $maxUBL = 1000;
       $minUBS = 0.3; $maxUBS = 100;
     }
     $minyrs = 1;   $maxyrs = 200;
     $rc = -0;
     print "<font color=red>\n";
     if ($URL < $minURL or $URL > $maxURL) {
       $rc=-1; print "Road length must be between $minURL and $maxURL $lu<BR>\n";}
     if ($URS < $minURS or $URS > $maxURS) {
       $rc=$rc-1; print "Road gradient must be between $minURS and $maxURS %<BR>\n";}
     if ($URW < $minURW or $URW > $maxURW) {
       $rc=$rc-1; print "Road width must be between $minURW and $maxURW $lu<BR>\n";} 
     if ($UFL < $minUFL or $UFL > $maxUFL) {
       $rc=$rc-1; print "Fill length must be between $minUFL and $maxUFL $lu<BR>\n";}
     if ($UFS < $minUFS or $UFS > $maxUFS) {
       $rc=$rc-1; print "Fill gradient must be between $minUFS and $maxUFS %<BR>\n";}
     if ($UBL < $minUBL or $UBL > $maxUBL) {
       $rc=$rc-1; print "Buffer length must be between $minUBL and $maxUBL $lu<BR>\n";}
     if ($UBS < $minUBS or $UBS > $maxUBS) {
      $rc=$rc-1; print "Buffer gradient must be between $minUBS and $maxUBS %<BR>\n";}
     print "</font>\n";
#    if ($rc < 0) {print "<p><hr><p>\n"}
     $years2sim=$years*1;
#     if ($years2sim < $minyrs) {$years2sim=$minyrs}
#     if ($years2sim > $maxyrs) {$years2sim=$maxyrs}
     if ($years2sim < 1) {$years2sim=1}
     if ($years2sim > 200) {$years2sim=200}
     return $rc;
}

sub getCligenStationName {

#  $CL
#  $climatePar
#  $debug

#   my $climatePar = "$CL" . '.par';
  if (-e $climatePar) {
    open PAR, "<$climatePar";
      my $station = <PAR>;
    close PAR;
    $station = substr($station, 0, 40);
#    if ($debug) {print "[getCligenStationName]<br>
#      ClimatePar:      $climatePar<br>
#      Station name:    $station<br>";
#    }
    return $station;
  }
}

sub CreateCligenFile {

#    $climatePar = "$CL" . '.par';

    $station = substr($CL, length($CL)-8);
    $user_ID = '';
#   $user_ID = 'getalife';
####  next for unix and pc ************************* DEH 2/1/2000
    if ($platform eq 'pc') {
#     $station = substr($CL, length($CL)-8);
      $climateFile = "$working\\$station.cli";
      $outfile = $climateFile;
      $rspfile = "$working\\cligen.rsp";
      $stoutfile = "$working\\cligen.out";
    } 
    else {
#     $user_ID = '';
#     $climateFile = '..\\working' . "$station.cli";
      $climateFile = "../working/$unique.cli";
      $outfile = $climateFile;
#     $rspfile = "../working/$user_ID.rsp";
#     $stoutfile = "../working/$user_ID.out";
      $rspfile = "../working/c$unique.rsp";
      $stoutfile = "../working/c$unique.out";
    }
####
    if ($debug) {print "[CreateCligenFile]<br>
      Arguments:    $args<br>
      ClimatePar:   $climatePar<br>
      ClimateFile:  $climateFile<br>
      OutputFile:   $outfile<br>
      ResponseFile: $rspfile<br>
      StandardOut:  $stoutfile<br>
      ";
    }

#  run CLIGEN43 on verified user_id.par file to
#  create user_id.cli file in FSWEPP working directory
#  for specified # years.

    $startyear = 1;
    open RSP, ">" . $rspfile;
      print RSP "4.31\n";
      print RSP $climatePar,"\n";
      print RSP "n do not display file here\n";
      print RSP "5 Multiple-year WEPP format\n";
      print RSP $startyear,"\n";
      print RSP $years,"\n";
      print RSP $climateFile,"\n";
      print RSP "n\n";
    close RSP;
    unlink $climateFile;   # erase previous climate file so CLIGEN'll run
    if ($platform eq 'pc') {
       @args = ("..\\rc\\cligen43.exe <$rspfile >$stoutfile"); 
    }
    else {
#      @args = ("nice -20 ../wepp <$responseFile >$stoutFile 2>$sterFile");
       @args = ("../rc/cligen43 <$rspfile >$stoutfile"); 
    }
    system @args;
    unlink $rspfile;   #  "../working/c$unique.rsp"
    unlink $stoutfile;  #  "../working/c$unique.out"
}

sub printfield {
  my $print=shift(@_);
  my $valid=shift(@_);
  my $value=shift(@_);
  if ($print) {
    if ($valid) {
      print "<td align='right'>$value</td>\n"
    }
    else {
      print "<td align='left' bgcolor='red'>$value</td>\n"
    }
  }
  else {
  } 
}

sub printrunfield {
  my $print=shift(@_);
  my $valid=shift(@_);
  my $value=shift(@_);
  if ($print) {
    if ($valid) {
      print "<td bgcolor='lightblue'>$value</td>\n"
    }
    else {
      print "<td bgcolor='red'>$value</td>\n"
    }
  }
  else {
  } 
}

sub valid_years {

  my $min=0;
  my $max=200;
  my $years=shift(@_);
  my $years0=$years+0;

  if ($years ne $years0) {
#     print "<font color='red'>Invalid number of years: $years</font><br>";
     return 0
  }
  if ($years0 < $min || $years0 > $max) {
#     print "<font color='red'>Invalid number of years: $years</font> ($min to $max allowed)<br>";
     return 0
  }
  return 1
}

sub valid_units {
  my $units=shift(@_);
  if ($units eq 'm' || $units eq 'ft') {
    return 1
  }
#  print "<font color='red'>Invalid units: $units</font><br>";
  return 0
}

sub valid_climate {
  my $CL=shift(@_);
  my $CLx=$CL . '.par';
# We should do some reasonableness checking before seeking the climate file...
  if (-e $CLx) {
    return 1
  }
#  print "<font color='red'>Climate file not found: $CL</font><br>";
  return 0
}

sub valid_soiltexture {
  my $ST=shift(@_);
  if ($ST eq 'clay' || $ST eq 'silt' || $ST eq 'loam' || $ST eq 'sand') {
    return 1
  }
  else {
#    print "<font color='red'>Invalid soil texture: $ST</font><br>";
    return 0;
  }
}

sub validate_design {	# DEH 2004.07.20
  my $design=shift(@_);
  if    ($design eq 'ib' || $design eq 'inbare')  {$designw='Insloped, bare ditch'}
  elsif ($design eq 'iv' || $design eq 'inveg')   {$designw='Insloped, vegetated ditch'}
  elsif ($design eq 'or' || $design eq 'outrut')  {$designw='Outsloped, rutted'}
  elsif ($design eq 'ou' || $design eq 'outunrut'){$designw='Outsloped, unrutted'}
  else {$num_invalid_fields+=1; return 0}
  return 1
}

sub validate_traffic {		# DEH 2004.07.20
  my $traffic=shift(@_);
  if (lc($traffic) eq 'l' || lc($traffic) eq 'h' || lc($traffic) eq 'n') {
    return 1
  }
  if (lc($traffic) eq 'low' || lc($traffic) eq 'high' || lc($traffic) eq 'none') {
    return 1
  }
  else {$num_invalid_fields+=1; return 0}
}

sub validate_surface {		# DEH 2004.07.20
  my $surface=shift(@_);
#  if (lc($surface) eq 'n' || lc($surface) eq 'g' || lc($surface) eq 'p') {
  if (lc($surface) eq 'n'       
   || lc($surface) eq 'g'       
   || lc($surface) eq 'p'       
   || lc($surface) eq 'native'  
   || lc($surface) eq 'graveled'
   || lc($surface) eq 'paved') {
    return 1                    
  }
  else {$num_invalid_fields+=1; return 0}
}

sub validate_rock {

  my $min=0;
  my $max=100;
  my $rock=shift(@_);
  my $rock0=$rock+0;

  if ($rock != $rock0) {
     $num_invalid_fields+=1;
     return 0;
  }
  if ($rock0 < $min || $rock0 > $max) {
     $num_invalid_fields+=1;
     return 0
  }
  return 1
}

sub validate_slope {

  my ($min,$max);
  my $slope=shift(@_);
  my $surface=shift(@_);
  my $slope0=$slope+0;

  if ($slope != $slope0) {
     $num_invalid_fields+=1;
     return 0;
  }

  if ($surface eq 'r') {$min=0.1; $max=40}
  if ($surface eq 'f') {$min=0.1; $max=150}
  if ($surface eq 'b') {$min=0.1; $max=100}
  if ($slope0 < $min || $slope0 > $max) {
     $num_invalid_fields+=1;
     return 0
  }
  return 1
}

sub validate_length {

  my ($min,$max);
  my $length=shift(@_);
  my $surface=shift(@_);	# 'r': road; 'f': fill; 'b': buffer; 'w': road width(?)
  my $length0=$length+0;

  if ($length != $length0) {
     $num_invalid_fields+=1;
     return 0
  }
  if ($surface eq 'r' && $units eq 'm')  {$min=1;   $max=300}
  if ($surface eq 'r' && $units eq 'ft') {$min=3;   $max=1000}
  if ($surface eq 'f' && $units eq 'm')  {$min=0.3; $max=100}
# if ($surface eq 'f' && $units eq 'ft') {$min=1;   $max=300}
  if ($surface eq 'f' && $units eq 'ft') {$min=1;   $max=1000}
  if ($surface eq 'b' && $units eq 'm')  {$min=0.3; $max=300}
  if ($surface eq 'b' && $units eq 'ft') {$min=1;   $max=1000}
  if ($surface eq 'w' && $units eq 'm')  {$min=0.3; $max=100}
  if ($surface eq 'w' && $units eq 'ft') {$min=1;   $max=300}
  if ($length0 < $min || $length0 > $max) {
     $num_invalid_fields+=1;
     return 0
  }
  return 1
}

sub detag {

  # convert some HTML tags so they won't muck the HTML code when displayed
  # https://www.biglist.com/lists/xsl-list/archives/199807/msg00094.html

  my $parseString=shift(@_);

# Convert plus's to spaces
#  $parseString =~ s/\+/ /g;

# Convert %xx URLencoded to equiv ASCII characters
#  $parseString =~ s/%(..)/chr(hex($1))/ge;

# Browsers don't display "<" chars as it could represent a tag in
# html. To get round the problem, you need to do the following
# conversion for the 'main' special characters in HTML.

# Convert < > & " to 'html' special characters.
  $parseString =~ s/&/\&amp;/g;  # &amp;   & (The ampersand sign itself)
  $parseString =~ s/</\&lt;/g;   # &lt;    < (less than sign)
  $parseString =~ s/>/\&gt;/g;   # &gt;    > (greater than sign)
  $parseString =~ s/"/\&quot;/g; # &quot;  " (double quote)

  return $parseString;

}

sub soilfilename {
# $surface
# $slope
# $ST

# $surf
# $tauC

     if    (substr ($surface,0,1) eq 'g') {$surf = 'g'}
     elsif (substr ($surface,0,1) eq 'p') {$surf = 'p'}
     else                                 {$surf = ''}

     if    ($design eq 'inveg'    || $design eq 'iv') {$tauC ='10'}
     elsif ($design eq 'inbare'   || $design eq 'ib') {$tauC = '2'}
     elsif ($design eq 'outunrut' || $design eq 'ou') {$tauC = '2'}
     elsif ($design eq 'outrut'   || $design eq 'or') {$tauC = '2'}

     if (($design eq 'inbare' || $design eq 'ib') && $surf eq 'p') {$tauC = '1'}
     return '3' . $surf . $ST . $tauC . '.sol';
}

sub manfilename {

# $surface
# $design
# $traffic

  my $manfile;

     if    (substr ($surface,0,1) eq 'g') {$surf = 'g'}
     elsif (substr ($surface,0,1) eq 'p') {$surf = 'p'}
     else                                 {$surf = ''}

     if    ($design eq 'inveg'   || $design eq 'iv'){$manfile='3inslope.man'}
     elsif ($design eq 'inbare'  || $design eq 'ib'){$manfile='3inslope.man'}
     elsif ($design eq 'outunrut'|| $design eq 'ou'){$manfile='3outunr.man'}
     elsif ($design eq 'outrut'  || $design eq 'or'){$manfile='3outrut.man'}

     if ($traffic eq 'none') {
       if ($manfile eq '3inslope.man') {$manfile = '3inslopen.man'}
       if ($manfile eq '3outunr.man')  {$manfile = '3outunrn.man'}
       if ($manfile eq '3outrut.man')  {$manfile = '3outrutn.man'} 
     }
     return $manfile;
}

sub display_log {

# $logFile
# $climate_name

     my $project;	# project title from log
     my $climate_name;	# Climate station name
     my $STx; 		# Soil texture
     my $units;		# project units from log
     my $years;		# years of run
     my $lu;		# length units ('m' or 'ft')
     my $du;		# depth units ('mm' or 'in')
     my $vu;		# volume units ('kg' or 'lb')
     my $t;		# generic term from log

      if (-e $logFile) {	        # display it
        open LOG, "<" .$logFile;
        $project=<LOG>; chomp $project;
        $climate_name=<LOG>; chomp $climate_name;
        $STx=<LOG>; chomp $STx;
        $units=<LOG>; chomp $units;
        $years=<LOG>; chomp $years;
        if ($units eq "ft") {$lu = "ft"; $du = "in"; $vu = "lb"}
        else                {$lu = "m";  $du = "mm"; $vu = "kg"}
        $preci=<LOG>; chomp $preci;
        $preci_0 = sprintf '%d',$preci;		# DEH 2009.09.18 remove depricated format specification
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
     $PARfile = $climatePar;                      # for &readPARfile()
&readPARfile();
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
      while (! eof LOG) {
        print "    <tr>
";
        if ($subs) {my $preci=<LOG>}; $subs=1;
        my $run  =<LOG>;
#       my $clima=<LOG>;
#       my $soilt=<LOG>;
        my $roadd=<LOG>;
        my $surfa=<LOG>;
        my $roadg=<LOG>;
        my $roadl=<LOG>;
        my $roadw=<LOG>;
        my $fillg=<LOG>;
        my $filll=<LOG>;
        my $buffg=<LOG>;
        my $buffl=<LOG>;
        my $rockf=<LOG>;
        my $rainr=<LOG>; $rainr = sprintf '%.1f', $rainr;
        my $snowr=<LOG>; $snowr = sprintf '%.1f', $snowr;
        my $sedir=<LOG>; $sedir = sprintf '%.0f', $sedir;
        my $sedip=<LOG>; $sedip = sprintf '%.0f', $sedip;
        my $comme=<LOG>;

        $sedir = commify ($sedir);
        $sedip = commify ($sedip);

         $td_tag='<td bgcolor="lightblue">';
#        $td_tag='<td bgcolor="coral">' if ($surfa =~ /low/ || $surfa =~ /none/);
#        $td_tag='<td bgcolor="coral">' if (lc($surfa) =~ /none/);    # DEH 2015.03.02
         $td_tag='<td bgcolor="red">' if ($run =~ / !/);
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
    if ($debug) {print "
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
}	# display_log()

sub commify {
    my $text = reverse $_[0];
    $text =~ s/(\d\d\d)(?=\d)(?!d*\.)/$1,/g;
    return scalar reverse $text;
} 

sub readPARfile {

#   $PARfile= 'working/166_2_22_167_o.par';

#   $PARfile
#   $units = 'ft';

   local $line, @mean_p_if, $mean_p_base, @pww, $pww_base, @pwd, $pwd_base, @tmax_av, $tmax_av_base;
   local @tmin_av, $tmin_av_base, @month_days, @num_wet, @mean_p, $tempunits, $prcpunits, $i, $mod, $modfrom;
   local $latlon, $ele, $el, $elev, $elem, $eleunits;			# 2009.12.02 DEH

# TOKETEE FALLS OR                        358536 0
# LATT=  43.28 LONG=-122.45 YEARS= 40. TYPE= 2
# ELEVATION = 2060. TP5 = 1.08 TP6= 4.08
# MEAN P    .39   .33   .29   .23   .24   .22   .19   .25   .27   .35   .43   .43
# S DEV P   .45   .37   .30   .25   .24   .25   .26   .26   .29   .39   .48   .50
# SKEW  P  2.16  2.76  2.20  2.12  1.61  2.17  3.01  1.73  1.99  1.83  2.26  2.55
# P(W/W)    .74   .77   .76   .72   .64   .59   .41   .48   .60   .64   .75   .76
# P(W/D)    .30   .28   .31   .31   .20   .15   .06   .08   .10   .19   .33   .32
# TMAX AV 42.29 48.29 53.67 60.86 69.80 77.65 86.12 85.43 77.99 63.48 48.60 41.95
# TMIN AV 29.15 30.95 32.50 35.71 40.83 46.87 50.15 49.37 44.32 38.30 33.83 30.11

   open PAR, "<$PARfile";
    $line=<PAR>;                 # station name
# print $line;
    $line=<PAR>;                 # Lat long
    $latlon = substr $line,0,26;					# 2009.12.02 DEH
    $line=<PAR>;                 # Elev	
    $ele = substr $line,0,19;						# 2009.12.02 DEH
    ($el,$elev)=split '=',$ele;						# 2009.12.02 DEH
    if ($units eq 'm') {						# 2009.12.02 DEH
      $elev = sprintf '%.1f',0.3048 * $elev;        # ft to m		# 2009.12.02 DEH
    }									# 2009.12.02 DEH

################

     $line=<PAR>;       # MEAN P   0.10  0.10  0.11  0.10  0.11  0.14  0.14  0.09  0.10  0.10  0.12  0.12
       @mean_p_if = split ' ',$line; $mean_p_base = 2;
     $line=<PAR>;       # S DEV P  0.12  0.12  0.11  0.13  0.13  0.18  0.22  0.13  0.13  0.11  0.14  0.13
     $line=<PAR>;       # SKEW  P  1.88  2.30  2.21  2.15  2.29  2.35  3.60  3.22  2.05  2.49  2.22  1.87
     $line=<PAR>;       # P(W/W)   0.47  0.50  0.39  0.32  0.33  0.30  0.27  0.28  0.40  0.41  0.42  0.48
       @pww = split ' ',$line; $pww_base = 1;
     $line=<PAR>;       # P(W/D)   0.20  0.16  0.15  0.13  0.13  0.11  0.05  0.06  0.08  0.12  0.23  0.23
       @pwd = split ' ',$line; $pwd_base=1;
     $line=<PAR>;       # TMAX AV 32.89 41.62 52.60 62.81 72.56 80.58 88.52 87.06 77.76 62.85 44.78 34.63
#      @tmax_av = split ' ',$line; $tmax_av_base = 2;
       for $ii (0..11) {@tmax_av[$ii]=substr($line,8+$ii*6,6)}; $tmax_av_base = 0;
     $line=<PAR>;       # TMIN AV 20.31 26.55 32.33 39.12 47.69 55.39 61.58 60.31 51.52 40.17 30.33 22.81
#      @tmin_av = split ' ',$line; $tmin_av_base = 2;
       for $ii (0..11) {@tmin_av[$ii]=substr($line,8+$ii*6,6)}; $tmin_av_base = 0;

     @month_days=(31,28,31,30,31,30,31,31,30,31,30,31);

#******************************************************#
# Calculation from parameter file for displayed values #
#******************************************************#

    for $i (1..12) {
      @pw[$i] = @pwd[$i] / (1 + @pwd[$i] - @pww[$i]);
    }

    for $i (0..11) {
        @tmax[$i] = @tmax_av[$i+$tmax_av_base];
        @tmin[$i] = @tmin_av[$i+$tmin_av_base];
        @pww[$i]  = @pww[$i+$pww_base];
        @pwd[$i]  = @pwd[$i+$pwd_base];
        @num_wet[$i] = sprintf '%.2f',@pw[$i+$pww_base] * @month_days[$i];
        @mean_p[$i] = sprintf '%.2f',@num_wet[$i] * @mean_p_if[$i+$mean_p_base];
        if ($units eq 'm') {
           @mean_p[$i] = sprintf '%.2f',25.4 * @mean_p[$i];        # inches to mm
           @tmax[$i] = sprintf '%.2f',(@tmax[$i] - 32) * 5/9;      # deg F to deg C
           @tmin[$i] = sprintf '%.2f',(@tmin[$i] - 32) * 5/9;      # deg F to deg C
        }
    }

   if ($units eq 'm') {
     $tempunits = 'deg C';
     $prcpunits = 'mm';
     $eleunits  = 'm';							# 2009.12.02 DEH
   }
   else {
     $tempunits = 'deg F';
     $prcpunits = 'in';
     $eleunits  = 'ft';							# 2009.12.02 DEH
   }

################

   while (<PAR>) {
     if (/Modified by/) {
        $modfrom = $_;
        $modfrom .= <PAR>;
        last;
     }
   }

   close PAR;

   if ($modfrom ne '') {
     chomp $modfrom;
     $, = ' ';
       print $modfrom,"<br>";
       print 'T MAX ',@tmax,$tempunits,"<br>\n";
       print 'T MIN ',@tmin,$tempunits,"<br>\n";
       print 'MEANP ',@mean_p,$prcpunits,"<br>\n";
       print '# WET ',@num_wet,"<br>\n";
#      print $latlon,' ',$ele," ft<br>\n";					# 2009.12.02 DEH
       print "$latlon ELEVATION = $elev $eleunits<br>\n";			# 2009.12.02 DEH
     $, = '';
   }
}
# ------------------------ end of subroutines ----------------------------
