#! /usr/bin/perl
#
# ww.pl
# 4 OFE version
#
# Water And Sediment Predictor (WASP) workhorse
# Reads user input from wasp.pl, runs WEPP, parses output files

# Needed update: automatic history popup

# 2009.04.21 DEH -- 
# David Hall, USDA Forest Service, Rocky Mountain Research Station

   $debug=0;
   $version = "2009.04.21";

#=========================================================================

   &ReadParse(*parameters);

   $CL=$parameters{'Climate'};         # get Climate (file name base)
#  $climate_name=$parameters{'climate_name'};   # requested climate #
   $soil=$parameters{'SoilType'};
#  $soil_name=$parameters{'soil_name'};
   $treat1=$parameters{'UpSlopeType'};
   $ofe1_length=$parameters{'ofe1_length'}+0;
   $ofe1_top_slope=$parameters{'ofe1_top_slope'}+0;
   $ofe1_mid_slope=$parameters{'ofe1_mid_slope'}+0;
   $ofe1_pcover=$parameters{'ofe1_pcover'}+0;
   $ofe1_rock=$parameters{'ofe1_rock'}+0;
   $ofe1_depth=$parameters{'ofe1_depth'}+0;
   $treat2=$parameters{'LowSlopeType'};
   $ofe2_length=$parameters{'ofe2_length'}+0;
   $ofe2_mid_slope=$parameters{'ofe2_top_slope'}+0;
   $ofe2_bot_slope=$parameters{'ofe2_bot_slope'}+0;
   $ofe2_pcover=$parameters{'ofe2_pcover'}+0;
   $ofe2_rock=$parameters{'ofe2_rock'}+0;
   $ofe2_depth=$parameters{'ofe2_depth'}+0;
   $ofe_area=$parameters{'ofe_area'}+0;
#  $outputs=$parameters{'Summary'};
#  $outputf=$parameters{'Full'};
#  $outputi=$parameters{'Slope'};
   $action=$parameters{'actionc'} . 
           $parameters{'actionv'} . 
           $parameters{'actionw'} .
           $parameters{'ActionCD'};
#  chomp $action;
   $me=$parameters{'me'};		# DEH 05/24/2000
   $units=$parameters{'units'};
   $achtung=$parameters{'achtung'};
   $climyears=$parameters{'climyears'};

   $restrict=$parameters{'restriction'};	# value="restricted"  CheckBox Restrictive layer?
   $rockname=$parameters{'RockName'};		# select Restrictive layer bedrock name
   $aniso_ratio=$parameters{'aniso'};		# value=25 default
   $sathydconduct=$parameters{'conduct'};	# mm/s or mm/h or m/day or ft/hr?

   $wepphost = "localhost";
   if (-e "../wepphost") {
     open HOST, "<../wepphost";
       $wepphost = lc(<HOST>);
       chomp $wepphost;
       if ($wepphost eq "") {$wepphost = "Localhost"}
     close HOST;
   }

   $platform = "unix";
   if (-e "../platform") {
     open PLATFORM, "<../platform";
       $platform = lc(<PLATFORM>);
       chomp $platform;
       if ($platform eq "") {$platform = "unix"}
     close PLATFORM;
   }

#
#                           C U S T O M       C L I M A T E
#

   if (lc($action) =~ /custom/) {
     $weppdist = "http://" . $wepphost . "/cgi-bin/fswepp/wd/weppdist.pl";
     if ($platform eq "pc") {
       exec "perl ../rc/rockclim.pl -server -i$me -u$units $weppdist"
     }
     else {
       exec "../rc/rockclim.pl -server -i$me -u$units $weppdist"
     }
     die
   }		# /custom/

#
#                        D E S C R I B E      C L I M A T E
#

   if (lc($achtung) =~ /describe climate/) {
     $weppdist = "http://" . $wepphost . "/cgi-bin/fswepp/wd/wepplf.pl";
     if ($platform eq "pc") {
       exec "perl ../rc/descpar.pl $CL $weppdist"
     }
     else {
       exec "../rc/descpar.pl $CL $weppdist"
     }
     die
   }		# /describe climate/

#
#                        D E S C R I B E    S O I L
#

   if (lc($achtung) =~ /describe soil/) {   ##########

     $units=$parameters{'units'};
     $SoilType=$parameters{'SoilType'};  # get SoilType (loam, sand, silt, clay, gloam, gsand, gsilt, gclay)
#     $surface=$parameters{'surface'};    # graveled or native
#     $slope=$parameters{'SlopeType'};    # get slope type (outunrut...)

#     if    ($slope eq 'inveg')    {$conduct='10'}
#     elsif ($slope eq "outunrut") {$conduct = '2'}
#     elsif ($slope eq "outrut")   {$conduct = '2'}
#     elsif ($slope eq "inbare")   {$conduct = '2'}

     if ($platform eq "pc") {$soilPath = 'data\\'}
     else                   {$soilPath = 'data/'}

     $surf = "";
#     if (substr ($surface,0,1) eq "g") {$surf = "g"}
#     $soilFile = '4' . $surf . $SoilType . $conduct . '.sol';
     $soilFile = '4' . $SoilType . '.sol';				## unique?

     $weppdist = "http://" . $wepphost . "/cgi-bin/fswepp/wd/wepplf.pl";
     $soilFilefq = $soilPath . $soilFile;
     print "Content-type: text/html\n\n";
     print "<HTML>\n";
     print " <HEAD>\n";
     print "  <TITLE>WEPP Lateral Flow Soil Parameters</TITLE>\n";
     print " </HEAD>\n";
     print ' <BODY background="http://',$wepphost,'/fswepp/images/note.gif" link="#ff0000">
  <font face="Arial, Geneva, Helvetica">
   <blockquote>
    <table width=95% border=0>
     <tr>
      <td> 
       <a href="JavaScript:window.history.go(-1)">
       <IMG src="http://',$wepphost,'/fswepp/images/wolf.gif"
        align="left" alt="Back to FS WEPP menu" border=1></a>
      </td>
      <td align=center>
       <hr>
       <h2>WASP Soil Texture Properties</h2>
       <hr>
      </td>
     </tr>
    </table>
';
     if ($debug) {print "Action: '$action'<br>\nAchtung: '$achtung $climyears  CL: $CL'<br>\n"}

     if ($SoilType eq 'clay') {
#       if ($surf eq 'g') {print 'Graveled '}
       print "clay loam (MH, CH)<br>\n";
       print "Shales and similar decomposing fine-grained sedimentary rock<br>\n";
#       if ($conduct == 2) {print 'Low '} else {print 'High '}
#       print "conductivity<br>\n";
     }
     elsif ($SoilType eq 'loam') {
#       if ($surf eq 'g') {print 'Graveled '}
       print "loam<br>\n";
       print "<br>\n";
#       if ($conduct == 2) {print 'Low '} else {print 'High '}
#       print "conductivity<br>\n";
     }
     elsif ($SoilType eq 'sand') {
#       if ($surf eq 'g') {print 'Graveled '}
       print "sandy loam (SW, SP, SM, SC)<br>\n";
       print "Glacial outwash areas; finer-grained granitics and sand<br>\n";
#       if ($conduct == 2) {print 'Low '} else {print 'High '}
#       print "conductivity<br>\n";
     }
     elsif ($SoilType eq 'silt') {
#       if ($surf eq 'g') {print 'Graveled '}
       print "silt loam (ML, CL)<br>\n";
       print "Ash cap or alluvial loess<br>\n";
#       if ($conduct == 2) {print 'Low '} else {print 'High '}
#       print "conductivity<br>\n";
     }
#
   if ($platform eq "pc") {
     if (-e 'd:/fswepp/working') {$working = 'd:\\fswepp\\working'}
     elsif (-e 'c:/fswepp/working') {$working = 'c:\\fswepp\\working'}
     else {$working = '..\\working'}
     $soilFile     = "$working\\wdwepp.sol";
     $soilPath     = 'data\\';
   }
   else {
     $working = '../working';
     $unique='wepp-' . $$;
     $soilFile     = "$working/$unique" . '.sol';
     $soilPath     = 'data/';
   }
#
     &CreateSoilFile2006;

     open SOIL, "<$soilFile";
     $weppver = <SOIL>;
     $comment = <SOIL>;
     while (substr($comment,0,1) eq "#") {
       chomp $comment;
#       print $comment,"\n";
       $comment = <SOIL>;
     }

     print "<hr>
  <center>
   <table border=1 cellpadding=3>
";

#      $solcom = $comment;

     $record = <SOIL>;
     @vals   = split " ", $record;
     $ntemp  = @vals[0];     # no. flow elements or channels
     $ksflag = @vals[1];     # 0: hold hydraulic conductivity constant
                             # 1: use internal adjustments to hydr con
#     $restr  = @vals[2];     # 0: restrictive layer not present
#                             # 1: restrictive layer present; user-specified saturated hydraulic conductivity (mm/h)
#                             # 2: restrictive layer present; specify name of bedrock restriction from select list 
#     $aniso  = @vals[3];     # anisotropic ratio (h vs v) of the saturated hydraulic conductivity (<0 -> 25)

     for $i (1..$ntemp) {
       print "
   <tr>
    <th colspan=5 bgcolor=\"#5cb3ff\"><font face=\"Arial, Geneva, Helvetica\">
     Flow Element $i ---
";
       $record = <SOIL>;
       @descriptors = split "'", $record;
       $my_soilID = lc(@descriptors[1]);
       $my_texture =lc(@descriptors[3]);
       print "$my_soilID;&nbsp;&nbsp;   ";	# slid: Road, Fill, Forest
       print "texture:$my_texture\n";		# texid: soil texture
       ($nsl,$salb,$sat,$ki,$kr,$shcrit,$avke) = split " ", @descriptors[4];
#      @vals = split " ", @descriptors[4];
#      print "No. soil layers: $nsl\n";
       $avke_e = sprintf "%.2f", $avke / 25.4;

       print "
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Albedo of the bare dry surface soil</th>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>$salb</td>
     <td>&nbsp;</td>
    </tr>
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Initial saturation level of the soil profile porosity</th>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>$sat</td>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>m m<sup>-1</sup></td>
    </tr>
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Baseline interrill erodibility (<i>k<sub>i</sub></i> )</th>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>$ki</td>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>kg s m<sup>-4</sup></td>
    </tr>
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Baseline rill erodibility (<i>k<sub>r</sub></i> )</th>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>$kr</td>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>s m<sup>-1</sup></td>
    </tr>
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Baseline critical shear</th>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>$shcrit</td>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>N m<sup>-2</sup></td>
    </tr>
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Effective hydraulic conductivity of surface soil</th>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>$avke</td>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>mm h<sup>-1</sup></td>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>$avke_e</td>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>in hr<sup>-1</sup></td>
";
       for $layer (1..$nsl) {
         $record = <SOIL>;
         ($solthk,$sand,$clay,$orgmat,$cec,$rfg) = split " ", $record;		# 090422 DEH
         $solthk_e = sprintf "%.2f", $solthk / 25.4;
         print "
    <tr>
     <td>&nbsp;</td>
     <th colspan=4 bgcolor=\"#5cb3ff\"><font face=\"Arial, Geneva, Helvetica\" size=-1>layer $layer</th>
    </tr>
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Depth from soil surface to bottom of soil layer</th>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>$solthk</td>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>mm</td>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>$solthk_e</td>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>in</td>
    </tr>
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Percentage of sand</th>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>$sand</td>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>%</td>
    </tr>
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Percentage of clay</th>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>$clay</td>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>%</td>
    </tr>
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Percentage of organic matter (by volume)</th>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>$orgmat</td>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>%</td>
    </tr>
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Cation exchange capacity</th>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>$cec</td>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>meq per 100 g of soil</td>
    </tr>
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Percentage of rock fragments (by volume)</th>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>$rfg</td>
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>%</td>
    </tr>
";

       }
     }
     $record = <SOIL>;
     @vals   = split " ", $record;
     $restr  = @vals[0];     # 0: restrictive layer not present
                             # 1: restrictive layer present; user-specified saturated hydraulic conductivity (mm/h)
                             # 2: restrictive layer present; specify name of bedrock restriction from select list 
     $aniso  = @vals[1];     # anisotropic ratio (h vs v) of the saturated hydraulic conductivity (<0 -> 25)
     $shc    = @vals[2];
     close SOIL;

    if ($restr eq '1') {
print "    <tr>
     <th bgcolor=tan align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Anisotropic ratio</th>
     <td bgcolor=tan><font face=\"Arial, Geneva, Helvetica\" size=-1>$aniso</td>
     <td bgcolor=tan><font face=\"Arial, Geneva, Helvetica\" size=-1>h:v</td>
    </tr>
    <tr>
     <th bgcolor=tan align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Saturated hydraulic conductivity of restrictive layer</th>
     <td bgcolor=tan><font face=\"Arial, Geneva, Helvetica\" size=-1>$shc</td>
     <td bgcolor=tan><font face=\"Arial, Geneva, Helvetica\" size=-1>mm h<sup>-1</sup></td>
     <td bgcolor=tan><font face=\"Arial, Geneva, Helvetica\" size=-1>",$shc/25.4,"</td>
     <td bgcolor=tan><font face=\"Arial, Geneva, Helvetica\" size=-1>in h<sup>-1</sup></td>
    </tr>
";
    }
    if ($restr eq '2') {
print "    <tr>
     <th align=left bgcolor=tan><font face=\"Arial, Geneva, Helvetica\" size=-1>Anisotropic ratio</th>
     <td bgcolor=tan><font face=\"Arial, Geneva, Helvetica\" size=-1>$aniso</td>
     <td bgcolor=tan><font face=\"Arial, Geneva, Helvetica\" size=-1>h:v</td>
    </tr>
    <tr>
     <th align=left bgcolor=tan><font face=\"Arial, Geneva, Helvetica\" size=-1>bedrock forming restrictive layer</th>
     <td bgcolor=tan><font face=\"Arial, Geneva, Helvetica\" size=-1>$shc</td>
     <td bgcolor=tan><font face=\"Arial, Geneva, Helvetica\" size=-1></td>
    </tr>
";
    }

#           <form method="post" action="',$soilFilefq,'">
     print '   </table>
  <br>
<!-- <form method="post" action="wepproad.sol">
    <input type="submit" value="DOWNLOAD">
    <input type="hidden" value="',$soilFile,'" name="filename">
   </form>
-->
';

     open SOIL, "<$soilFile";
     print '

   </center>
   <table width=100%>
    <tr>
     <th bgcolor=#5cb3ff>WEPP soil file</th>
    </tr>
   </table>
   <pre>
';
     print <SOIL>;
     print '
   </pre>
  </blockquote>
 </body>
</html>
';
     unlink $soilFile;	# DEH 01/13/2004
     die
   }            #  /describe soil/


#
#                                 R U N      W E P P
#

# ########### RUN WEPP ###########

$debug=0;
   $years2sim=$climyears;
   if ($years2sim > 100) {$years2sim=100}
   if ($climyears eq '') {$years2sim=100}

#  if ($host eq "") {$host = 'unknown';}
   $unique='wepp-' . $$;
#  if ($debug) {print 'Unique? filename= ',$unique,"\n<BR>"}

   if ($platform eq "pc") {
#     if (-e 'd:/fswepp/working') {$working = 'd:\\fswepp\\working'}
#     elsif (-e 'c:/fswepp/working') {$working = 'c:\\fswepp\\working'}
     if (-e 'c:/fswepp/working') {$working = 'c:\\fswepp\\working'}
     else {$working = '..\\working'}

     $responseFile = "$working\\wasp_in.txt";
     $outputFile   = "$working\\wasp_out.txt";
     $stoutFile    = "$working\\wasp_sto.txt";
     $sterFile     = "$working\\wasp_err.txt";
     $slopeFile    = "$working\\wasp_slp.txt";
     $soilFile     = "$working\\wasp_sol.txt";
     $cropFile     = "$working\\wasp_crp.txt";
     $WatBalFile   = "$working\\wasp_wtr.txt";
#    $SedLossFile  = "$working\\wasp_sed.txt";
     $ElementFile  = "$working\\wasp_ofe.txt";
     $EventByFile  = "$working\\wasp_eve.txt";
#     $climateFile  = $CL . '.cli';
#     $lastslash = rindex($CL,'\\');
#     $station      = "wasp";
     $climateFile  = "$working\\wasp.cli";
     $manFile      = "$working\\wasp_man.txt";
     $soilPath     = 'data\\';
     $manPath      = 'data\\';
   }
   else {
     $working = '../working';
#    $unique='wepp' . time . '-' . $$;
     $unique='wepp' . '-' . $$;
     $responseFile = "$working/$unique" . '.in';
     $outputFile   = "$working/$unique" . '.out';
     $soilFile     = "$working/$unique" . '.sol';
     $slopeFile    = "$working/$unique" . '.slp';
     $cropFile     = "$working/$unique" . '.crp';
     $WatBalFile   = "$working/$unique" . '.water';
#    $SedLossFile  = "$working/$unique" . '.sedloss';
     $ElementFile  = "$working/$unique" . '.element';
     $EventByFile  = "$working/$unique" . '.event';
#     $climateFile  = "$CL" . '.cli';
     $climateFile  = "$working/$unique" . '.cli';
     $stoutFile    = "$working/$unique" . '.stout';
     $sterFile     = "$working/$unique" . '.sterr';
     $manFile      = "$working/$unique" . '.man';
     $soilPath     = 'data/';
     $manPath      = 'data/';
   }

# make hash of treatments

   $treatments = {};
   $treatments{skid} = 'skid trail';
   $treatments{high} = 'high severity fire';
   $treatments{low} = 'low severity fire';
   $treatments{short} = 'short prairie grass';
   $treatments{tall} = 'tall prairie grass';
   $treatments{shrub} = 'shrubs';
   $treatments{tree5} = '5 year old trees';
   $treatments{tree20} = '20 year old trees';

# make hash of soil types

   $soil_type = {};
   $soil_type{sand} = 'sandy loam';
   $soil_type{silt} = 'silt loam';
   $soil_type{clay} = 'clay loam';
   $soil_type{loam} = 'loam';

# ----------------------------

   $host = $ENV{REMOTE_HOST};

   $rcin = &checkInput;
   if ($rcin eq '') {

     if ($units eq 'm') {
       $user_ofe1_length=$ofe1_length;
       $user_ofe2_length=$ofe2_length;
       $user_ofe_area=$ofe_area;
     }
     if ($units eq 'ft') {
       $user_ofe1_length=$ofe1_length;
       $user_ofe2_length=$ofe2_length;
       $user_ofe_area=$ofe_area;
       $ofe1_length=$ofe1_length/3.28;		# 3.28 ft == 1 m
       $ofe2_length=$ofe2_length/3.28;		# 3.28 ft == 1 m
       $ofe_area=$ofe_area/2.47;		# 2.47 ac == 1 ha; Schwab Fangmeier Elliot Frevert
     }

     $ofe_width=$ofe_area*10000/($ofe1_length+$ofe2_length);

# print "Zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz";

     if ($debug) {print "Creating Slope File<br>\n"}
     &CreateSlopeFile;
     if ($debug) {print "Creating Management File<br>\n"}
     &CreateManagementFile;
     if ($debug) {print "Creating Climate File<br>\n"}
     &CreateCligenFile;
     if ($debug) {print "Creating Soil File<br>\n"}
     &CreateSoilFile2006;
     if ($debug) {print "Creating WEPP Response File<br>\n"}
     &CreateResponseFile;

#    @args = ("nice -20 ./wepp <$responseFile >$stoutFile 2>$sterFile");
     if ($platform eq "pc") {
       @args = ("..\\wepp <$responseFile >$stoutFile")
     }
     else {
       @args = ("../wepp <$responseFile >$stoutFile 2>$sterFile")
     }
     system @args;

########################  start HTML output ###############

   print "Content-type: text/html\n\n";
   print '<HTML>
 <HEAD>
  <TITLE>WASP Results</TITLE>
  <script>

    function showslopefile() {
     var properties="menubar,scrollbars,resizable"
     filewindow = window.open("","slope",properties)
     filewindow.document.open()
     if (filewindow && filewindow.open && !filewindow.closed) {
      filewindow.focus
      filewindow.document.writeln("<html>")
      filewindow.document.writeln(" <head>")
      filewindow.document.writeln("  <title>WEPP slope file ',$unique,'<\/title>")
      filewindow.document.writeln(" <\/head>")
      filewindow.document.writeln(" <body>")
      filewindow.document.writeln("  <font face=\'courier\'>")
      filewindow.document.writeln("   <pre>")
';
      open WEPPFILE, "<$slopeFile";
      while (<WEPPFILE>) {
       chomp;
       print '      filewindow.document.writeln("', $_, '")',"\n";
      }
      close WEPPFILE;
      print '      filewindow.document.writeln("   <\/pre>")
      filewindow.document.writeln("  <\/font>")
      filewindow.document.writeln(" <\/body>")
      filewindow.document.writeln("<\/html>")
      filewindow.document.close()
     }
     return false
    }

    function showsoilfile() {
     var properties="menubar,scrollbars,resizable"
     filewindow = window.open("","soil",properties)
     filewindow.document.open()
     if (filewindow && filewindow.open && !filewindow.closed) {
      filewindow.focus
      filewindow.document.writeln("<head><title>WEPP soil file ',$unique,'<\/title><\/head>")
      filewindow.document.writeln("<body><font face=\'courier\'><pre>")
';
      open WEPPFILE, "<$soilFile";
      while (<WEPPFILE>) {
       chomp;
       print '      filewindow.document.writeln("', $_, '")',"\n";
      }
      close WEPPFILE;
      print '      filewindow.document.writeln("<\/pre><\/font><\/body><\/html>")
      filewindow.document.close()
     }
     return false
    }

    function showresponsefile() {
     var properties="menubar,scrollbars,resizable"
     filewindow = window.open("","resp",properties)
     filewindow.document.open()
     if (filewindow && filewindow.open && !filewindow.closed) {
      filewindow.focus
      filewindow.document.writeln("<head><title>WEPP response file ',$unique,'<\/title><\/head>")
      filewindow.document.writeln("<body><pre>")
';
      open WEPPFILE, "<$responseFile";
      while (<WEPPFILE>) {
       chomp;
# escape backslashes to display correctly (convert '\' to '\\')
       $_ =~ s.\\.\\\\.g; 
       print '      filewindow.document.writeln("', $_, '")',"\n";
      }
      close WEPPFILE;
      print '      filewindow.document.writeln("<\/pre><\/body><\/html>")
      filewindow.document.close()
     }
     return false
    }

    function showvegfile() {
     var properties="menubar,scrollbars,resizable"
     filewindow = window.open("","veg",properties)
     filewindow.document.open()
     if (filewindow && filewindow.open && !filewindow.closed) {
      filewindow.focus
      filewindow.document.writeln("<head><title>WEPP vegetation file ',$unique,'<\/title><\/head>")
      filewindow.document.writeln("<body><pre>")
';
      $line = 0;
      open WEPPFILE, "<$manFile";
      while (<WEPPFILE>) {
       chomp;
       print '      filewindow.document.writeln("', $_, '")',"\n";
       $line +=1;
#       last if ($line > 100);
#**#       last if (/Management Section/);
      }
      close WEPPFILE;
      print '      filewindow.document.writeln("<\/pre><\/body><\/html>")
      filewindow.document.close()
     }
     return false
    }

    function showextendedoutput() {
     var properties="menubar,scrollbars,resizable"
     filewindow = window.open("","extendedout",properties)
     filewindow.document.open()
     if (filewindow && filewindow.open && !filewindow.closed) {
      $z=0
     }
     else {
      return false
     }
     filewindow.focus
     filewindow.document.writeln("<head><title>WEPP output file ',$unique,'<\/title><\/head>")
     filewindow.document.writeln("<body><font face=\'courier\'><pre>")
';
     open WEPPFILE, "<$outputFile";
      while (<WEPPFILE>) {
       chomp;
       print '      filewindow.document.writeln("', $_, '")',"\n";
      }
     close WEPPFILE;
     print '      filewindow.document.writeln("<\/pre><\/font><\/body><\/html>")
     filewindow.document.close()
     return false
    }

    function showcligenparfile() {
     var properties="menubar,scrollbars,resizable"
     filewindow = window.open("","clipar",properties)
     filewindow.document.open()
     if (filewindow && filewindow.open && !filewindow.closed) {
      filewindow.focus
      filewindow.document.writeln("<head><title>WEPP weather file ',$unique,'<\/title><\/head>")
      filewindow.document.writeln("<body><pre>")
';
#     print '      filewindow.document.writeln("climate file: ', $climateFile, '");
      open WEPPFILE, "<$climatePar";
      while (<WEPPFILE>) {
       chomp; chop;
       print '      filewindow.document.writeln("', $_, '")',"\n";
      }
      close WEPPFILE;
      print '      filewindow.document.writeln("<\/pre><\/body><\/html>")
      filewindow.document.close()
     }
     return false
    }
  <!-- end new 2004 -->
';

print <<'pophist';
function popuphistory() {
url = '';
height=500;
width=660;
popupwindow = window.open(url,'popupwindow','toolbar=no,location=no,status=no,directories=no,menubar=no,scrollbars=yes,resizable=yes,width='+width+',height='+height);

popupwindow.document.writeln('<html>')
popupwindow.document.writeln(' <head>')
popupwindow.document.writeln('  <title>WASP Results version history</title>')
popupwindow.document.writeln(' </head>')
popupwindow.document.writeln(' <body bgcolor=white link=gray vlink=gray>')
popupwindow.document.writeln('  <font face="arial, helvetica, sans serif">')
popupwindow.document.writeln('   <center>')
popupwindow.document.writeln('   <h3>WASP Results Version History</h3>')
popupwindow.document.writeln('   <blockquote>')
popupwindow.document.writeln('    <table border=0>')
popupwindow.document.writeln('     <tr>')
popupwindow.document.writeln('      <th bgcolor=85d2d2><font face="arial, helvetica, sans serif">Version</font></th>')
popupwindow.document.writeln('      <th width=10 bgcolor=85d2d2></th>')
popupwindow.document.writeln('      <th bgcolor=85d2d2><font face="arial, helvetica, sans serif">Comments</font></th>')
popupwindow.document.writeln('     </tr>')
popupwindow.document.writeln('     <tr>')
popupwindow.document.writeln('      <th bgcolor="85d2d2"><font face="arial, helvetica, sans serif">2004.02.18</font></th>')
popupwindow.document.writeln('      <td></td>')
popupwindow.document.writeln('      <td><font face="arial, helvetica, sans serif">Add links to WEPP input and output files</font></td>')
popupwindow.document.writeln('     </tr>')
popupwindow.document.writeln('     <tr>')
popupwindow.document.writeln('      <th bgcolor="85d2d2"><font face="arial, helvetica, sans serif">2003.11.28</font></th>')
popupwindow.document.writeln('      <td></td>')
popupwindow.document.writeln('      <td><font face="arial, helvetica, sans serif">Print soil file as created at end</font></td>')
popupwindow.document.writeln('     </tr>')
popupwindow.document.writeln('     <tr>')
popupwindow.document.writeln('      <th bgcolor="85d2d2"><font face="arial, helvetica, sans serif">2002.11.14</font></th>')
popupwindow.document.writeln('      <td></td>')
popupwindow.document.writeln('      <td><font face="arial, helvetica, sans serif">Handle proxy/NAT IP block for log file</font></td>')
popupwindow.document.writeln('     </tr>')
popupwindow.document.writeln('     <tr>')
popupwindow.document.writeln('      <th valign=top bgcolor=85d2d2><font face="arial, helvetica, sans serif">2001.10.10</font></th>')
popupwindow.document.writeln('      <td></td>')
popupwindow.document.writeln('      <td><font face="arial, helvetica, sans serif">Handle input of "rock content."<br>    ')
popupwindow.document.writeln('        Remove use of "area" and do not calculate or display representative width.</font></td>')
popupwindow.document.writeln('     </tr>')
popupwindow.document.writeln('     <tr>')
popupwindow.document.writeln('      <th valign=top bgcolor=85d2d2><font face="arial, helvetica, sans serif">2000.05.24</font></th>')
popupwindow.document.writeln('      <td></td>')
popupwindow.document.writeln('      <td><font face="arial, helvetica, sans serif">Fix input-value-check to be aware of units<br>')
popupwindow.document.writeln('          Make aware of user-ID<br>')
popupwindow.document.writeln('          Change "shrubbery" to "shrubs"</font></td>')
popupwindow.document.writeln('     </tr>')
popupwindow.document.writeln('     <tr>')
popupwindow.document.writeln('      <th valign=top bgcolor=85d2d2><font face="arial, helvetica, sans serif">2000.04.10</font></th>')
popupwindow.document.writeln('      <td></td>')
popupwindow.document.writeln('      <td><font face="arial, helvetica, sans serif">Report vegetation-check biomass in t/ac</font></td>')
popupwindow.document.writeln('     </tr>')
popupwindow.document.writeln('     <tr>')
popupwindow.document.writeln('      <th valign=top bgcolor=85d2d2><font face="arial, helvetica, sans serif">2000.02.14</font></th>')
popupwindow.document.writeln('      <td></td>')
popupwindow.document.writeln('      <td><font face="arial, helvetica, sans serif">')
popupwindow.document.writeln('       <hr>')
popupwindow.document.writeln('       <ul>')
popupwindow.document.writeln('        <li>Cosmetic changes.')
popupwindow.document.writeln('        <li>Modified low-severity fire file parameter.')
popupwindow.document.writeln('       </ul>')
popupwindow.document.writeln('      </font></td>')
popupwindow.document.writeln('     </tr>')
popupwindow.document.writeln('     <tr>')
popupwindow.document.writeln('      <th valign=top bgcolor=85d2d2><font face="arial, helvetica, sans serif">2000.01.27</th>')
popupwindow.document.writeln('      <td></td>')
popupwindow.document.writeln('      <td><font face="arial, helvetica, sans serif">')
popupwindow.document.writeln('       <hr>')
popupwindow.document.writeln('       <ul>')
popupwindow.document.writeln('        <li>Passed user-entered vegetative cover values and')
popupwindow.document.writeln('            calculated biomass energy ratio value into WEPP input files')
popupwindow.document.writeln('        <li>Changed the probability table for WEPP run and added bar graph')
popupwindow.document.writeln('            representing the probabilities')
popupwindow.document.writeln('       </ul>')
popupwindow.document.writeln('      </font></td>')
popupwindow.document.writeln('     </tr>')
popupwindow.document.writeln('     <tr>')
popupwindow.document.writeln('      <th valign=top bgcolor=85d2d2><font face="arial, helvetica, sans serif">2000.01.06</font></th>')
popupwindow.document.writeln('      <td></td>')
popupwindow.document.writeln('      <td><font face="arial, helvetica, sans serif">')
popupwindow.document.writeln('       <hr>')
popupwindow.document.writeln('       <ul>')
popupwindow.document.writeln('        <li>Carried user selection of English and metric units into output')
popupwindow.document.writeln('        <li>Pass user-entered area value into WEPP input files')
popupwindow.document.writeln('        <li>Report erosion and sediment delivery results in tonnes per hectare or tons per acre')
popupwindow.document.writeln('        <li>Reformatted output tables a bit.')
popupwindow.document.writeln('        <li>Started adding additional (I hope) helpful comments in the status bar as mouse moves over key text.')
popupwindow.document.writeln('       </ul>')
popupwindow.document.writeln('      </font></td>')
popupwindow.document.writeln('     </tr>')
popupwindow.document.writeln('    </table>')
popupwindow.document.writeln('   </blockquote>')
popupwindow.document.writeln('   </font>')
popupwindow.document.writeln('  </center>')
popupwindow.document.writeln(' </body>')
popupwindow.document.writeln('</html>')
popupwindow.document.close()
popupwindow.focus()
}

pophist

print '
  </script>
 </HEAD>
 <BODY background="http://',$wepphost,'/fswepp/images/note.gif">
  <font face="Arial, Geneva, Helvetica">
  <blockquote>
';
     if ($debug) {print "Action: '$action'<br>\nAchtung: '$achtung $climyears  CL: $CL'<br>\n"}

print '  <table width=100% border=0>
    <tr><td> 
       <a href="JavaScript:window.history.go(-1)">
       <IMG src="http://',$wepphost,'/fswepp/images/disturb.gif"
       align="left" alt="Return to WASP input screen" border=1></a>
    <td align=center>
       <hr>
       <h2>WASP Results</h2>
       <hr>
    <td>
       <A HREF="http://',$wepphost,'/fswepp/docs/distweppdoc.html">
       <IMG src="http://',$wepphost,'/fswepp/images/epage.gif"
        align="right" alt="Read the documentation" border=0></a>
    </table>
';

######################## end of top part of HTML output ###############

#------------------------------

#  unlink $climateFile;    # be sure this is right file .....     # 2/2000

#    print '<HR><BR><CENTER><H3>WEPP summary</H3></CENTER>';
#    print "\n<PRE>\n";

     open weppstout, "<$stoutFile";

     $found = 0;
     while (<weppstout>) {
       if (/SUCCESSFUL/) {
         $found = 1;
         last;
       }
     }
     close (weppstout);

     if ($found == 0) {
       open weppstout, "<$stoutFile";
       while (<weppstout>) {
         if (/ERROR/) {
           $found = 2;
           print "<font color=red>\n";
           $_ = <weppstout>; # print;
           $_ = <weppstout>; # print;
           $_ = <weppstout>;  print;
           $_ = <weppstout>;  print;
           print "</font>\n";
           last;
         }
       }
       close (weppstout);
       open weppstout, "<$stoutFile";
       while (<weppstout>) {
         if (/error #/) {
           $found = 4;
           print "<font color=red>\n";
           print;
           last;
           print "</font>\n";
         }
       }
       close (weppstout);
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
     }		# $found == 0

##     $found = 1; #**#

     if ($found == 1) {
       open weppout, "<$outputFile";
       $_ = <weppout>;
       if (/Annual; detailed/) {$outputfiletype="annualdetailed"}
       $ver = 'unknown';
       while (<weppout>) {
         if (/VERSION/) {
           $weppver = lc($_);
           chomp $weppver;
           last;
         }
       }

# ############# actual climate station name #####################

       while (<weppout>) {     ######## actual ########
         if (/CLIMATE/) {
#          print;
           $a_c_n=<weppout>;
           $actual_climate_name=substr($a_c_n,index($a_c_n,":")+1,40);
           $climate_name = $actual_climate_name;
           last;
         }
       }

#################################################################

#      if ($outputfiletype eq "annualdetailed") {
         while (<weppout>) {
           if (/ANNUAL AVERAGE SUMMARIES/) {print ""; last}
         }
#      }

       while (<weppout>) {
         if (/RAINFALL AND RUNOFF SUMMARY/) {
           $_ = <weppout>; #      -------- --- ------ -------
           $_ = <weppout>; # 
           $_ = <weppout>; #       total summary:  years    1 -    1
           $simyears = substr $_,35,10; chomp $simyears; $simyears += 0;
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
           $precip = substr $_,51,10; #print "precip: ";
           $_ = <weppout>; 
           $rro = substr $_,51,10;    #print; 
           $_ = <weppout>; # print;
           $_ = <weppout>;
           $sro = substr $_,51,10;    #print; 
           $_ = <weppout>; # print;
           last;
         }
       }

       while (<weppout>) {
         if (/AREA OF NET SOIL LOSS/) {
           $_ = <weppout>;
           $_ = <weppout>;
           $_ = <weppout>;
           $_ = <weppout>;
           $_ = <weppout>;
           $_ = <weppout>; # print;
           $_ = <weppout>; # print;
           $_ = <weppout>; # print;
           $_ = <weppout>; # print;
           $_ = <weppout>; 
           $syr = substr $_,17,7;  
           $effrdlen = substr $_,9,9; # print;
           last;
         }
       }

       while (<weppout>) {
         if (/OFF SITE EFFECTS/) {
           $_ = <weppout>;
           $_ = <weppout>;
           $_ = <weppout>; $syp = substr $_,50,9;
           $_ = <weppout>; if ($syp eq "") {$syp = substr $_,10,9}
           $_ = <weppout>;
           $_ = <weppout>;
           last;
         }
       }
       close (weppout);

#-----------------------------------

       $storms=$storms*1;
       $rainevents=$rainevents*1;
       $snowevents=$snowevents*1;
       $precip=$precip*1;
       $rro=$rro*1;
       $sro=$sro*1;
       $syr=$syr*1;
       $syp=$syp*1;
       $effrdlen=$effrdlen*1;
       $syra=$syr;  # * $effrdlen * $effrdwidth;
       $sypa=$syp;  # * $effrdwidth;
       if ($units eq 'm') {
         $user_ofe_width = $ofe_width
       }
       if ($units eq 'ft') {
         $user_ofe_width = $ofe_width * 3.28	# 1 m = 3.28 ft
       }
       $rofe_width =  sprintf "%.2f", $user_ofe_width;
       $slope_length = $ofe1_length + $ofe2_length;
       $asyra=$syra * 10;   # kg.m^2 * 10 = t/ha
#       $asypa= sprintf "%.2f", $sypa * $ofe_width / (100000 * $ofe_area);  # kg/m width * m width * (1 t / 1000 kg) / area-in-ha
       $asypa = sprintf "%.2f", $sypa * 10 / $slope_length; 
#       if ($units eq 'm') {$areaunits='ha'}
#       if ($units eq 'ft') {$areaunits='ac'}
       $areaunits='ha' if $units eq 'm';
       $areaunits='ac' if $units eq 'ft';
       $depthunit = 'mm';
       $depthunit = 'in.' if $units eq 'ft';
   

       print "   </pre>
  <center>
   <h3>User inputs</h3>
    <table border=1>
     <tr>
      <th bgcolor=#5cb3ff><font face='Arial, Geneva, Helvetica'>Location</th>
      <td colspan=6><font face='Arial, Geneva, Helvetica'><b>$climate_name</b>
       <br>
       <font size=1>
";
     $PARfile = $climatePar;                      # for &readPARfile()
&readPARfile();
print "
       </font>
      </td>
     </tr>
     <tr>
      <th bgcolor=#5cb3ff><font face='Arial, Geneva, Helvetica'>Soil texture</th>
      <td colspan=6><font face='Arial, Geneva, Helvetica'>$soil_type{$soil}</td>
     </tr>
     <tr>
      <th bgcolor=#5cb3ff><font face='Arial, Geneva, Helvetica'>Restrictive layer</th>
      <td colspan=6><font face='Arial, Geneva, Helvetica'>";
    if ($restrict) {print "$rockname; anisotropic ratio $aniso_ratio h:v; conductivity $sathydconduct $cunits</td>\n"}
    else {print "None</td>\n"}
print "
     </tr>
     <tr>
      <th bgcolor=#5cb3ff><font face='Arial, Geneva, Helvetica'>Element</th>
      <th bgcolor=#5cb3ff><font face='Arial, Geneva, Helvetica'>Treatment</th>
      <th bgcolor=#5cb3ff><font face='Arial, Geneva, Helvetica'>Gradient<br> (%)</th>
      <th bgcolor=#5cb3ff><font face='Arial, Geneva, Helvetica'>Length<br> ($units)</th>
      <th bgcolor=#5cb3ff><font face='Arial, Geneva, Helvetica'>Cover<br> (%)</th>
      <th bgcolor=#5cb3ff><font face='Arial, Geneva, Helvetica'>Rock<br> (%)</th>
      <th bgcolor=#5cb3ff><font face='Arial, Geneva, Helvetica'>Depth<br> ($depthunit)</th>
     </tr>
     <tr>
      <th rowspan=2 bgcolor=#5cb3ff><font face='Arial, Geneva, Helvetica'>Upper</th>
      <td rowspan=2><font face='Arial, Geneva, Helvetica'>$treatments{$treat1}</td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$ofe1_top_slope</td>
      <td align=right rowspan=2><font face='Arial, Geneva, Helvetica'>$user_ofe1_length</td>
      <td align=right rowspan=2><font face='Arial, Geneva, Helvetica'>$ofe1_pcover</td>
      <td align=right rowspan=2><font face='Arial, Geneva, Helvetica'>$ofe1_rock</td>
      <td align=right rowspan=2><font face='Arial, Geneva, Helvetica'>$ofe1_depth</td>
     </tr>
     <tr>
      <td align=right><font face='Arial, Geneva, Helvetica'>$ofe1_mid_slope</td>
     </tr>
     <tr>
      <th rowspan=2 bgcolor=#5cb3ff><font face='Arial, Geneva, Helvetica'>Lower</th>
      <td rowspan=2><font face='Arial, Geneva, Helvetica'>$treatments{$treat2}</td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$ofe2_mid_slope</td>
      <td align=right rowspan=2><font face='Arial, Geneva, Helvetica'>$user_ofe2_length</td>
      <td align=right rowspan=2><font face='Arial, Geneva, Helvetica'>$ofe2_pcover</td>
      <td align=right rowspan=2><font face='Arial, Geneva, Helvetica'>$ofe2_rock</td>
      <td align=right rowspan=2><font face='Arial, Geneva, Helvetica'>$ofe2_depth</td>
     </tr>
     <tr>
      <td align=right><font face='Arial, Geneva, Helvetica'>$ofe2_bot_slope</td>
     </tr>
    </table>
    <p>
";

if ($units eq 'm') {
   $user_precip = sprintf "%.1f", $precip;
   $user_rro = sprintf "%.1f", $rro;
   $user_sro = sprintf "%.1f", $sro;
   $user_asyra = sprintf "%.3f", $asyra;		# 2004.10.14 DEH
   $user_asypa = sprintf "%.3f", $asypa;		# 2004.10.14 DEH
   $rate = 't ha<sup>-1</sup>';
   $pcp_unit = 'mm';
}
if ($units eq 'ft') {
   $user_precip = sprintf "%.2f", $precip*0.0394;	# mm to in
   $user_rro = sprintf "%.2f", $rro*0.0394;		# mm to in
   $user_sro = sprintf "%.2f", $sro*0.0394;		# mm to in
   $user_asyra = sprintf "%.3f", $asyra*0.445;		# t/ha to t/ac # 2004.10.14 DEH
   $user_asypa = sprintf "%.3f", $asypa*0.445;		# t/ha to t/ac # 2004.10.14 DEH
   $rate = 't ac<sup>-1</sup>';
   $pcp_unit = 'in.';
}
   print "
   <p><hr><p>
   <h3>Mean annual averages for $simyears years</h3>
    <table border=0 cellpadding=4>
     <tr>
      <td><font face='Arial, Geneva, Helvetica'>$user_precip</td>
      <td><font face='Arial, Geneva, Helvetica'>$pcp_unit</td>
      <td><font face='Arial, Geneva, Helvetica'>precipitation from </td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$storms</td>
      <td><font face='Arial, Geneva, Helvetica'>
          <a onMouseOver=\"window.status='There were $storms storms in $simyears year(s)';return true;\"
             onMouseOut=\"window.status='';return true;\">
          storms</a></td>
     </tr>
     <tr>
      <td><font face='Arial, Geneva, Helvetica'>$user_rro</td>
      <td><font face='Arial, Geneva, Helvetica'>$pcp_unit</td>
      <td><font face='Arial, Geneva, Helvetica'>runoff from rainfall from</td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$rainevents</td>
      <td><font face='Arial, Geneva, Helvetica'>events</td>
     </tr>
     <tr>
      <td><font face='Arial, Geneva, Helvetica'>$user_sro</td>
      <td><font face='Arial, Geneva, Helvetica'>$pcp_unit</td>
      <td><font face='Arial, Geneva, Helvetica'>runoff from snowmelt or winter rainstorm from</td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$snowevents</td>
      <td><font face='Arial, Geneva, Helvetica'>events</td>
     </tr>
     <tr>
      <td valign=bottom><font face='Arial, Geneva, Helvetica'>$user_asyra</td>
      <td><font face='Arial, Geneva, Helvetica'>$rate</td>
      <td valign=bottom>upland erosion rate ($syra kg m<sup>-2</sup>)</td>
     </tr>
     <tr>
      <td valign=bottom><font face='Arial, Geneva, Helvetica'>$user_asypa</td>
      <td><font face='Arial, Geneva, Helvetica'>$rate</td>
      <td valign=bottom><font face='Arial, Geneva, Helvetica'>sediment leaving profile ($sypa kg m<sup>-1</sup> width)</td>
     </tr>
    </table>
   <br>
";
   
   @water = &WaterBalance;
   if ($units eq 'ft') {
     @water = map { $_/25.4 } @water;
#    @water = map { sprintf '%.1f',$_ } @water
   }
#   else {
#    @water = map { sprintf '%d',$_ } @water
#   }

    @water = map { sprintf '%.1f',$_ } @water;

print "
    <h3>Water balance -- average annual</h3>
    <table border=1 cellpadding=4>
     <tr>
      <th bgcolor='lightblue' valign=bottom><font face='Arial, Geneva, Helvetica'><a title='P'>Precip</a><br>($depthunit)</font></th>
      <th bgcolor='lightblue' valign=bottom><font face='Arial, Geneva, Helvetica'><a title='Q'>Daily<br>runoff</a><br>($depthunit)</font></th>
      <th bgcolor='lightblue' valign=bottom><font face='Arial, Geneva, Helvetica'><a title='Ep'>Plant<br>transpiration</a><br>($depthunit)</font></th>
      <th bgcolor='lightblue' valign=bottom><font face='Arial, Geneva, Helvetica'><a title='Es'>Soil<br>evaporation</a><br>($depthunit)</font></th>
      <th bgcolor='lightblue' valign=bottom><font face='Arial, Geneva, Helvetica'><a title='Dp'>Deep<br>percolation</a><br>($depthunit)</font></th>
      <th bgcolor='lightblue' valign=bottom><font face='Arial, Geneva, Helvetica'><a title='latqcc'>Lateral<br>subsurface<br>flow</a><br>($depthunit)</font></th>
      <th bgcolor='lightblue' valign=bottom><font face='Arial, Geneva, Helvetica'><a title='Q+Ep+Es+Dp+latqcc'>Sum</a><br>($depthunit)</font></th>
     </tr>
     <tr>
      <td align=right><font face='Arial, Geneva, Helvetica'>@water[0]</font></td>
      <td align=right><font face='Arial, Geneva, Helvetica'>@water[2]</font></td>
      <td align=right><font face='Arial, Geneva, Helvetica'>+@water[3]</font></td>
      <td align=right><font face='Arial, Geneva, Helvetica'>+@water[4]</font></td>
      <td align=right><font face='Arial, Geneva, Helvetica'>+@water[5]</font></td>
      <td align=right><font face='Arial, Geneva, Helvetica'>+@water[6]</font></td>
      <td align=right><font face='Arial, Geneva, Helvetica'>=@water[7]</font></td>
     </tr>
    </table>
   </center>\n";

#   print @water;


#####
       if (lc($action) =~ /vegetation/) {
         &cropper;
         print "<center>\n";
         print "<p><hr><p><h2>Vegetation check for $simyears years</h2>\n";
         if ($units eq "ft") {
           print "<table border=1>
           <tr><th>Element
               <th>Biomass<br>(t ac<sup>-1</sup>)
               <th>Cover<br>(%)
           <tr><th>Upper<td align=right>";
           printf "%.4f", $livebiomean[1]*4.45;
           print "<td align=right>";
           printf "%7.2f", $rillmean[1]*100;
           print "  <tr><th>Lower<td align=right>";
           printf "%.4f", $livebiomean[2]*4.45;
           print "<td align=right>";
           printf "%7.2f", $rillmean[2]*100;
           print "  </table></center>\n";
         }
         else {     # ($units eq "m")
           print "<table border=1>
           <tr><th>Element<th>Biomass<br>(kg m<sup>-2</sup>)<th>Cover<br>(%)
           <tr><th>Upper<td align=right>";
           printf "%.4f", $livebiomean[1];
           print "<td align=right>";
           printf "%7.2f", $rillmean[1]*100;
           print "  <tr><th>Lower<td align=right>";
           printf "%.4f", $livebiomean[2];
           print "<td align=right>";
           printf "%7.2f", $rillmean[2]*100;
           print "  </table></center>\n";
         }
       }
       else {
         &parsead;
         print "
   <center>
    <p><hr><p>
    <h3>Return period analysis<br>
        based on $simyears&nbsp;years of climate</h3>
    <p>
    <table border=1 cellpadding=3>
     <tr>
      <th bgcolor=#5cb3ff><font face='Arial, Geneva, Helvetica'>Return<br>Period</th>
      <th bgcolor=#5cb3ff><font face='Arial, Geneva, Helvetica'>Precipitation<br>($pcp_unit)</th>
      <th bgcolor=#5cb3ff><font face='Arial, Geneva, Helvetica'>Runoff<br>($pcp_unit)</th>
      <th bgcolor=#5cb3ff><font face='Arial, Geneva, Helvetica'>Erosion<br>($rate)</th>
      <th bgcolor=#5cb3ff><font face='Arial, Geneva, Helvetica'>Sediment<br>($rate)</th>
     </tr>";

$rcf = 1; $dcf = 1;					# rate conversion factor; depth conversion factor
if ($units eq 'ft') {$rcf = 0.445; $dcf = 0.0394}	# t/ha to t/ac; mm to in.
$ii = 0;
@rp_year_text=('1st','2nd','5th','10th','20th');
for $rp_year (1,2,5,10,20) {
   $rp = $simyears/$rp_year;
   if ($rp >= 1) {
      $user_pcpa = sprintf "%.2f", $pcpa[$rp_year-1] * $dcf;
      $user_ra   = sprintf "%.2f", $ra[$rp_year-1] * $dcf;
      $asyr = sprintf "%.2f", $detach[$rp_year-1] * 10 * $rcf;					# kg.m^2 * 10 = t/ha * 0.445 = t/ac
#     $asyp = sprintf "%.2f", $sed_del[$rp_year-1] * $ofe_width / (100000 * $ofe_area) * $rcf;	# kg/m width * m width * (1 t / 1000 kg) / area-in-ha
      $asyp = sprintf "%.4f", $sed_del[$rp_year-1] * 10 / $slope_length * $rcf;			# 2006.01.20 DEH

      print "
     <tr>
      <th bgcolor=#5cb3ff><font face='Arial, Geneva, Helvetica'>
        <a onMouseOver=\"window.status='For year with $rp_year_text[$ii] largest values';return true;\"
           onMouseOut=\"window.status='';return true;\">$rp year</a></th>
      <td align=right><font face='Arial, Geneva, Helvetica'>$user_pcpa</td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$user_ra</td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$asyr</td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$asyp</td>
     </tr>
";
      $ii += 1;
   }
}
   $user_avg_pcp = sprintf "%.2f", $avg_pcp*$dcf;
   $user_avg_ro  = sprintf "%.2f", $avg_ro*$dcf;
   $user_asyra   = sprintf "%.2f", $asyra*$rcf;
   $user_asypa   = sprintf "%.4f", $asypa*$rcf;			# 2006.01.20 DEH
   print "
     <tr>
      <th bgcolor=yellow><font face='Arial, Geneva, Helvetica'>Average</th>
      <td align=right><font face='Arial, Geneva, Helvetica'>$user_avg_pcp</td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$user_avg_ro</td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$user_asyra</td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$user_asypa</td>
     </tr>
    </table>
";
         $base_size=100;
         $prob_no_pcp      = sprintf "%.2f", $nzpcp/$simyears;
         $prob_no_runoff   = sprintf "%.2f", $nzra/$simyears;
         $prob_no_erosion  = sprintf "%.2f", $nzdetach/$simyears;
         $prob_no_sediment = sprintf "%.2f", $nzsed_del/$simyears;

print "
    <p>
    <hr>
<!--
<h2>Yearly probabilities based on $simyears years</h2>
-->
   <h3>Probabilities of occurrence first year following disturbance<br>
       based on $simyears&nbsp;years of climate</h3>
    <table border=1 cellpadding=4>
     <tr>
      <th align=right><font face='Arial, Geneva, Helvetica'>Probability there is runoff
      <td><font face='Arial, Geneva, Helvetica'>";
     printf "%.0f",(1-$prob_no_runoff)*100
   ; print " %</td>
      <td><font face='Arial, Geneva, Helvetica'>
        <a onMouseOver=\"window.status='$nnzra year(s) in $simyears had runoff';return true;\"
           onMouseOut=\"window.status='';return true;\">
        <img src=\"/fswepp/images/rouge.gif\" height=15 width=",(1-$prob_no_runoff)*$base_size,"></a>
        <a onMouseOver=\"window.status='$nzra year(s) in $simyears had no runoff';return true;\"
           onMouseOut=\"window.status='';return true;\">
        <img src=\"/fswepp/images/green.gif\" height=15 width=",($prob_no_runoff)*$base_size,"></a></td>
     </tr>
     <tr>
      <th align=right><font face='Arial, Geneva, Helvetica'>Probability there is erosion</th>
      <td>";
     printf "%.0f",(1-$prob_no_erosion)*100;
     print " %</td>
      <td><font face='Arial, Geneva, Helvetica'>
       <a onMouseOver=\"window.status='$nnzdetach year(s) in $simyears had erosion';return true;\"
           onMouseOut=\"window.status='';return true;\">
        <img src=\"/fswepp/images/rouge.gif\" height=15 width=",(1-$prob_no_erosion)*$base_size,"></a>
        <a onMouseOver=\"window.status='$nzdetach year(s) in $simyears had no erosion';return true;\"
           onMouseOut=\"window.status='';return true;\">
        <img src=\"/fswepp/images/green.gif\" height=15 width=",($prob_no_erosion)*$base_size,"></a></td>
     </tr>
     <tr>
      <th align=right><font face='Arial, Geneva, Helvetica'>Probability there is sediment delivery</th>
      <td><font face='Arial, Geneva, Helvetica'>";
     printf "%.0f", (1-$prob_no_sediment)*100;
     print " %</td>
      <td><font face='Arial, Geneva, Helvetica'>
          <a onMouseOver=\"window.status='$nnzsed_del year(s) in $simyears had sediment delivery';return true;\"
             onMouseOut=\"window.status='';return true;\">
          <img src=\"/fswepp/images/rouge.gif\" height=15 width=",(1-$prob_no_sediment)*$base_size,"></a>
          <a onMouseOver=\"window.status='$nzsed_del year(s) in $simyears had no sediment delivery';return true;\"
             onMouseOut=\"window.status='';return true;\">
          <img src=\"/fswepp/images/green.gif\" height=15 width=",($prob_no_sediment)*$base_size,"></a></td>
     </tr>
    </table>
   </center>
";
       }  	#	else case of if (lc($action) =~ /vegetation/)

       print '
   <p>
   <center>
    <hr>
    <a href="JavaScript:window.history.go(-1)">
    <img src="http://',$wepphost,'/fswepp/images/rtis.gif"
     alt="Return to input screen" border="0" align=center></A>
    <br>
    <hr>
   </center>
';

#####

# print "<hr width=50%> \n";

       if ($outputi==1){
         print '
   <hr>
   <p>
    <h3 align=center>Generated slope file</h3>
    <pre>
';
         open slopef, "<$slopeFile";
           while (<slopef>){
             print;
           }
         close slopef;
         print '</PRE>';
       }		# $outputi == 1
#----------------------
     }		# $found == 1
     else {          #  $found == 1
       print "<p><font color=red>Something seems to have gone awry!</font>\n<p><hr><p>\n";
     }          # $found == 1

#-----------------------------------------

     if ($outputf==1) {
       print '<BR><CENTER><H2>WEPP output</H2></CENTER>';
       print '<PRE>';
       open weppout, "<$outputFile";
       for $line (0..38) {
         $_ = <weppout>;
         print;
       }
       print "\n\n";
       while (<weppout>){    # skip 'til "ANNUAL AVERAGE SUMMARIES"
         if (/ANNUAL AVERAGE SUMMARIES/) {	# DEH 03/07/2001 patch
           last
         }
       }
       print;
       while (<weppout>) {			# DEH 03/07/2001 patch
         print
       }
       close weppout;
       print '</PRE>';
       print "<p><hr>";
       print '<center>
<a href="JavaScript:window.history.go(-1)">
<img src="http://',$wepphost,'/fswepp/images/rtis.gif"
  alt="Return to input screen" border="0" align=center></A>
<BR><HR></center>';
     }		# $outputf == 1

#-------------------------------------

   }		# $rcin >= 0
   else {
   print "Content-type: text/html\n\n";
   print '<HTML>
 <HEAD>
  <TITLE>WASP Results</TITLE>
 </head>
 <body>
';
    print $rcin;
  } 

       print '  <br><center>
    [ <a href="javascript:void(showslopefile())">slope</a>
    | <a href="javascript:void(showsoilfile())">soil</a>
    | <a href="javascript:void(showvegfile())">vegetation</a>
    | <a href="javascript:void(showcligenparfile())">weather</a>
    | <a href="javascript:void(showextendedoutput())">extended</a>
    | <a href="javascript:void(showresponsefile())">response</a> ]
    </center>
';

print "
    <br><br>
    <font size=-2>
     WASP Results v.";
print '     <a href="javascript:popuphistory()">';
print "     $version</a> based on WEPP $weppver, CLIGEN $cligen_version<br>
     http://$wepphost/fswepp<br>";
&printdate;
print "
     <br>
     WASP Run ID $unique
    </font>
   </blockquote>
 </body>
</html>
";

#  system "rm working/$unique.*";

   unlink <$working/$unique.*>;       # da

   $host = $ENV{REMOTE_HOST};                    
   $host = $ENV{REMOTE_ADDR} if ($host eq '');
   $user_really=$ENV{'HTTP_X_FORWARDED_FOR'};		# DEH 11/14/2002
   $host = $user_really if ($user_really ne '');	# DEH 11/14/2002
   if (lc($wepphost) ne "localhost") {
     open WDLOG, ">>../working/wd.log";
       flock (WDLOG,2);
#      $host = $ENV{REMOTE_HOST};
#      if ($host eq "") {$host = $ENV{REMOTE_ADDR} };
       print WDLOG "$host\t";
       printf WDLOG "%0.2d:%0.2d ", $hour, $min;
       print WDLOG $ampm[$ampmi],"  ",$days[$wday]," ",$months[$mon]," ",$mday, ", ",$thisyear, "\t";
       print WDLOG $years2sim,"\t";
       print WDLOG $climate_name,"\n";
     close WDLOG;

     open CLIMLOG, '>../working/lastclimate.txt';       # 2005.07.14 DEH
       flock CLIMLOG,2;
       print CLIMLOG 'WASP: ', $climate_name;
     close CLIMLOG;

     $thisday = 1+ (localtime)[7];                      # $yday, day of the year (0..364)
     $thisdayoff=$thisday-0;                            # [Jan 1] -1: Sunday; 0: Monday
     $thisweek = 1+ int $thisdayoff/7;
     $ditlogfile = '>>../working/wd/' . $thisweek;      # modify this
     open MYLOG,$ditlogfile;
       flock MYLOG,2;                  # 2005.02.09 DEH
       print MYLOG '.';
     close MYLOG;

   }

# ------------------------ subroutines ---------------------------

sub ReadParse {

# ReadParse -- from cgi-lib.pl (Steve Brenner) from Eric Herrmann's
# "Teach Yourself CGI Programming With PERL in a Week" p. 131

# Reads GET or POST data, converts it to unescaped text, and puts
# one key=value in each member of the list "@in"
# Also creates key/value pairs in %in, using '\0' to separate multiple
# selections

   local (*in) = @_ if @_;
   local ($i, $loc, $key, $val);
#       read text
   if ($ENV{'REQUEST_METHOD'} eq "GET") {
     $in = $ENV{'QUERY_STRING'};
   }
   elsif ($ENV{'REQUEST_METHOD'} eq "POST") {
     read(STDIN,$in,$ENV{'CONTENT_LENGTH'});
   }
   @in = split(/&/,$in);
   foreach $i (0 .. $#in) { 
     $in[$i] =~ s/\+/ /g;	  # Convert pluses to spaces
     ($key, $val) = split(/=/,$in[$i],2);	  # Split into key and value
     $key =~ s/%(..)/pack("c",hex($1))/ge;	  # Convert %XX from hex numbers to alphanumeric
     $val =~ s/%(..)/pack("c",hex($1))/ge;
     $in{$key} .= "\0" if (defined($in{$key}));  # \0 is the multiple separator
     $in{$key} .= $val;
   }
   return 1;
}

#---------------------------

sub printdate {

   @months=qw(January February March April May June July August September October November December);
   @days=qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);
   $ampm[0] = "am";
   $ampm[1] = "pm";

#   $ampmi = 0;
#   ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=gmtime;
#   if ($hour == 12) {$ampmi = 1}
#   if ($hour > 12) {$ampmi = 1; $hour -= 12}
#   printf "%0.2d:%0.2d ", $hour, $min;
#   print $ampm[$ampmi],"  ",$days[$wday]," ",$months[$mon];
#   print " ",$mday,", ",$year+1900, " GMT/UTC/Zulu<br>\n";

   $ampmi = 0;
   ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime;
   if ($hour == 12) {$ampmi = 1}
   if ($hour > 12) {$ampmi = 1; $hour = $hour - 12}
   $thisyear = $year+1900;
   printf "%0.2d:%0.2d ", $hour, $min;
   print $ampm[$ampmi],"  ",$days[$wday]," ",$months[$mon];
   print " ",$mday,", ",$thisyear, " Pacific Time\n";
}

sub CreateSlopeFile {				# OFE4

if ($debug) {print "creating slope file";}

# create slope file from specified geometry

   $top_slope1 = $ofe1_top_slope / 100;
   $mid_slope1 = $ofe1_mid_slope / 100;
   $mid_slope2 = $ofe2_mid_slope / 100;
   $bot_slope2 = $ofe2_bot_slope / 100;
   $avg_slope = ($mid_slope1 + $mid_slope2) / 2;
   $ofe_width=100 if $ofe_area == 0;
   open (SlopeFile, ">".$slopeFile);

     print SlopeFile "97.3\n";           # datver	97.3
     print SlopeFile "#\n# Slope file generated for WASP\n#\n";
     print SlopeFile "4\n";              # no. OFE
     print SlopeFile "100 $ofe_width\n";        # aspect; representative profile width
                                         # OFE 1 (upper)
     printf SlopeFile "%d  %.2f\n",   2  ,$ofe1_length/2;   # no. points, length
     printf SlopeFile "%.2f, %.2f  ", 0  ,$top_slope1;      # dx, gradient
     printf SlopeFile "%.2f, %.2f\n", 1  ,$mid_slope1;      # dx, gradient
                                         # OFE 2 (upper middle)
     printf SlopeFile "%d  %.2f\n",   2  ,$ofe1_length/2;   # no. points, length
     printf SlopeFile "%.2f, %.2f  ", 0  ,$mid_slope1;      # dx, gradient
     printf SlopeFile "%.2f, %.2f\n", 1  ,$avg_slope;       # dx, gradient
                                   # OFE 3 (lower middle)
     printf SlopeFile "%d  %.2f\n",   2,   $ofe2_length/2;  # no. points, length
     printf SlopeFile "%.2f, %.2f  ", 0,   $avg_slope;      # dx, gradient
     printf SlopeFile "%.2f, %.2f\n", 1,   $mid_slope2;     # dx, gradient
                                   # OFE 4 (lower)
     printf SlopeFile "%d  %.2f\n",   2,   $ofe2_length/2;  # no. points, length
     printf SlopeFile "%.2f, %.2f  ", 0,   $mid_slope2;     # dx, gradient
     printf SlopeFile "%.2f, %.2f\n", 1,   $bot_slope2;     # dx, gradient

   close SlopeFile;
   return $slopeFile;
 }

sub CreateManagementFile {				# OFE4

     $climatePar = $CL . '.par';
     &getAnnualPrecip;			# open .par file and calculate annual precipitation
     if ($debug) {print "Annual Precip: $ap_annual_precip mm<br>\n"}

#  $treat1 = "skid";   $treat2 = "tree5";

   open MANFILE, ">$manFile";

   print MANFILE "97.3
#
#\tCreated for WASP WEPP by wd.pl (v. $version)
#\tNumbers by: Bill Elliot (USFS) et alia
#

4\t# number of OFEs
$years2sim\t# (total) years in simulation

#################
# Plant Section #
#################

2\t# looper; number of Plant scenarios

";

   open PS1, "<data/$treat1.wps";      # WEPP plant scenario
#  read 14 lines (base 0); line 9 entry 2 will change (biomass) as f(climate)

#  $beinp is biomass energy ratio (real ~ 0 to 1000): plant scenario 7.3 (p. 33)
#  the following equation relates biomass ratio to cover (whole) percent and precipitation in mm
#  from work December 1999 by W.J. Elliot unpublished.

#   ($ofe1_pcover > 100) ? $pcover = 100 : $pcover = $ofe1_pcover;
   $pcover = $ofe1_pcover;	# decided not to limit input cover to 100%; use whatever is entered (for now)
   $precip_cap = 450;		# max precip in mm to put into biomass equation (curve flattens out)
   ($ap_annual_precip < $precip_cap) ? $capped_precip = $ap_annual_precip : $capped_precip = $precip_cap;
   $beinp = sprintf "%.1f", 8.17 * exp(0.031 * $pcover - 0.0023 * $capped_precip);

   while (<PS1>) {
    if (/beinp/) {				# read file search for token to replace with value
       $index_beinp = index($_,'beinp');		# where does token start?
       $wps_left = substr($_,0,$index_beinp);		# grab stuff to left of token
       $wps_right = substr($_,$index_beinp+5);		# grab stuff to right of token end
       $_ = $wps_left . $beinp . $wps_right;		# stuff value inbetween the two ends
       if ($debug) {print "<b>wps1:</b><br>
                           pcover: $pcover<br>
                           beinp: $beinp<br><pre> $_<br>\n"}
    }
    print MANFILE $_;				# print line to management file
   }
   close PS1;

   open PS2, "<data/$treat2.wps";
#  read 14 lines (base 0); line 9 entry 2 will change (biomass) as f(climate)

#   ($ofe2_pcover > 100)? $pcover = 100 : $pcover = $ofe2_pcover;
   $pcover = $ofe2_pcover;
   ($ap_annual_precip < $precip_cap) ? $capped_precip = $ap_annual_precip : $capped_precip = $precip_cap;
   $beinp = sprintf "%.1f", 8.17 * exp(0.031 * $pcover - 0.0023 * $capped_precip);;

   while (<PS2>) {
    if (/beinp/) {
       $index_beinp = index($_,'beinp');
       $wps_left = substr($_,0,$index_beinp);
       $wps_right = substr($_,$index_beinp+5);
       $_ = $wps_left . $beinp . $wps_right;
       if ($debug) {print "</pre><b>wps2:</b><br>
                           pcover: $pcover<br>
                           beinp: $beinp<br><pre> $_<br>\n"}
    }
    print MANFILE $_;
   }
   close PS2;

   print MANFILE 
"#####################
# Operation Section #
#####################

0\t# looper; number of Operation scenarios

##############################
# Initial Conditions Section #
##############################

2\t# looper; number of Initial Conditions scenarios

";

#  $inrcov is initial interrill cover (real 0-1): initial conditions 6.6 (p. 37)
#  $rilcov is initial rill cover (real 0-1): initial conditions 9.3 (p. 37)
#  December 1999 by W.J. Elliot unpublished.

   ($ofe1_pcover > 100)? $pcover = 100 : $pcover = $ofe1_pcover;
   $inrcov = sprintf "%.2f", $pcover/100;
   $rilcov = $inrcov;

   open IC, "<data/$treat1.ics";        # Initial Conditions Scenario file
#  read 14 lines (base 0); change line 8 values 1 and 5; line 11 value 2

   while (<IC>) {
     if (/iresd/) {substr ($_,0,1) = "1"}
     if (/inrcov/) {
       $index_pos = index($_,'inrcov');
       $ics_left = substr($_,0,$index_pos);
       $ics_right = substr($_,$index_pos+6);
       $_ = $ics_left . $inrcov . $ics_right;
       if ($debug) {print "<b>ics1:</b><br>$_<br>\n"}
     }
     if (/rilcov/) {
       $index_pos = index($_,'rilcov');
       $ics_left = substr($_,0,$index_pos);
       $ics_right = substr($_,$index_pos+6);
       $_ = $ics_left . $rilcov . $ics_right;
       if ($debug) {print "$_<br>\n"}
     }
     print MANFILE $_;
   }
   close IC;

   ($ofe2_pcover > 100)? $pcover = 100 : $pcover = $ofe2_pcover;
   $inrcov = sprintf "%.2f", $pcover/100;
   $rilcov = $inrcov;

   open IC, "<data/$treat2.ics";
#  read 14 lines (base 0); change line 8 values 1 and 5; line 11 value 2
   while (<IC>) {
     if (/iresd/) {substr ($_,0,1) = "2"}
     if (/inrcov/) {
       $index_pos = index($_,'inrcov');
       $ics_left = substr($_,0,$index_pos);
       $ics_right = substr($_,$index_pos+6);
       $_ = $ics_left . $inrcov . $ics_right;
       if ($debug) {print "<b>ics2:</b><br>$_<br>\n"}
     }
     if (/rilcov/) {
       $index_pos = index($_,'rilcov');
       $ics_left = substr($_,0,$index_pos);
       $ics_right = substr($_,$index_pos+6);
       $_ = $ics_left . $rilcov . $ics_right;
       if ($debug) {print "$_</pre><br>\n"}
     }
     print MANFILE $_;
   }
   close IC;

   print MANFILE
"###########################
# Surface Effects Section #
###########################

0\t# looper; number of Surface Effects scenarios

######################
# Contouring Section #
######################

0\t# looper; number of Contouring scenarios

####################
# Drainage Section #
####################

0\t# looper; number of Drainage scenarios

##################
# Yearly Section #
##################

2\t# looper; number of Yearly scenarios

";

   open YS, "<data/$treat1.ys";      # Yearly Scenario
   while (<YS>) {
     if (/itype/) {substr ($_,0,1) = "1"}
     print MANFILE $_;
   }
   close YS;

   open YS, "<data/$treat2.ys";
   while (<YS>) {
     if (/itype/) {substr ($_,0,1) = "2"}
     print MANFILE $_;
   }
   close YS;

   print MANFILE
"######################
# Management Section #
######################
DISTWEPP
Four OFEs to drive the WASP interface
for forest conditions
W. Elliot 02/99
4\t# 'nofe' - <number of Overland Flow Elements>
\t1\t# 'Initial Conditions indx' - <$treat1>
\t1\t# 'Initial Conditions indx' - <$treat1>
\t2\t# 'Initial Conditions indx' - <$treat2>
\t2\t# 'Initial Conditions indx' - <$treat2>
$years2sim\t# 'nrots' - <rotation repeats..>
1\t# 'nyears' - <years in rotation>
";

   for $i (1..$years2sim) {
     print MANFILE "#
#	Rotation $i : year $i to $i
#
\t1\t\t# 'nycrop' - <plants/yr; Year of Rotation :  $i - OFE : 1>
\t\t1\t# 'YEAR indx' - <$treat1>
\t1\t\t# 'nycrop' - <plants/yr; Year of Rotation :  $i - OFE : 2>
\t\t1\t# 'YEAR indx' - <$treat1>
\t1\t\t# 'nycrop' - <plants/yr; Year of Rotation :  $i - OFE : 3>
\t\t2\t# 'YEAR indx' - <$treat2>
\t1\t\t# 'nycrop' - <plants/yr; Year of Rotation :  $i - OFE : 4>
\t\t2\t# 'YEAR indx' - <$treat2>
";
   }
   close MANFILE;
}

sub CreateSoilFile2006 {			# Create 4 OFE soil file

print "Soil file";

#  $soil = 'loam';
#  $treat1 = $ofe1;   # 'short'
#  $treat2 = $ofe2;   # 'tree5'
   $fcover1 = $ofe1_pcover/100;
   $fcover2 = $ofe2_pcover/100;

# make outer_offset hash

   $outer_offset = {};
   $outer_offset{sand} = 5;
   $outer_offset{silt} = 24;
   $outer_offset{clay} = 43;
   $outer_offset{loam} = 62;

# make inner_offset hash

   $inner_offset = {};
   $inner_offset{skid}   = 0;
   $inner_offset{high}   = 2;
   $inner_offset{low}    = 4;
   $inner_offset{short}  = 6;
   $inner_offset{tall}   = 8;
   $inner_offset{shrub}  = 10;
   $inner_offset{tree5}  = 12;
   $inner_offset{tree20} = 14;

   $line_number1 = $outer_offset{$soil} + $inner_offset{$treat1};
   $line_number2 = $outer_offset{$soil} + $inner_offset{$treat2};

# $sathydconduct
# $rockname

### handle restrictive layer information
### need to validate values ###

   $restrictive_layer_flag=0;
   if ($restrict) {$restrictive_layer_flag=1}
   else {$aniso_ratio = 1; $sathydconduct=0}		### 2006

###

   open SOLFILE, ">$soilFile";

   print SOLFILE 
"2006
#
#      Created by 'ww.pl' (v $version)
#      Numbers by: Bill Elliot (USFS)
#
#	Modified soil file format (September 02, 2004)
#	No._OFE  adjust_hydr_conduct  restrictive_layer_flag  aniso_ratio
#	restrictive_layer_flag:
#		2: restrictive layer present; specify name of bedrock restriction from select list 
#		1: restrictive layer present; user-specified saturated hydraulic conductivity (mm/h)
#		0: restrictive layer not present
#	aniso_ratio: anisotropic ratio (h vs v) of the saturated hydraulic conductivity (<0 -> 25)
#       restrictive layer selected: $rockname
#
sichus jatun pacha jallp'anta tukuchinman, chay pachaqa wañuchikushian [Quechua: 'the nation that destroys its soil destroys itself' - Franklin Delano Roosevelt]
 4    1
";

#sichus jatun pacha jallp'anta tukuchinman, chay pachaqa wañuchikushian [Quechua: 'the nation that destroys its soil destroys itself' - Franklin Delano Roosevelt]
# 4    1    $restrictive_layer_flag    $aniso_ratio
#";

### OFE 1 ###

   open SOILDB, "<data/soilbase1";

   for $i (1..$line_number1) {
     $in = <SOILDB>;
   }
   chomp $in;
   print SOLFILE "$in\n";			# 'Forest' 'clay loam'	1	0.06	0.5	400000	0.0002	1	35
   $in2 = <SOILDB>;				# depth	25	30	5	25	20
   $in2 =~ s/depth/$ofe1_depth/e;
   chomp $in2;
   print SOLFILE "$in2\t$ofe1_rock\n";
   print SOLFILE "$restrictive_layer_flag\t$aniso_ratio\t$sathydconduct\n";	### 2006

   close SOILDB;

### OFE 2 ###

   print SOLFILE "$in\n";
#  print SOLFILE "$in2\t$ofe1_rock\t$sathydconduct\n";
   print SOLFILE "$in2\t$ofe1_rock\n";
   print SOLFILE "$restrictive_layer_flag\t$aniso_ratio\t$sathydconduct\n";	### 2006

### OFE 3 ###

   open SOILDB, "<data/soilbase1";
   for $i (1..$line_number1) {
     $in = <SOILDB>;
   }
   chomp $in;
   print SOLFILE "$in\n";

   $in2 = <SOILDB>;
   chomp $in2;
   $in2 =~ s/depth/$ofe2_depth/e;
   print SOLFILE "$in2\t$ofe1_rock\n";

   print SOLFILE "$restrictive_layer_flag\t$aniso_ratio\t$sathydconduct\n";	### 2006

   close SOILDB;

### OFE 4 ###

   print SOLFILE "$in\n";
#  print SOLFILE "$in2\t$ofe1_rock\t$sathydconduct\n";
   print SOLFILE "$in2\t$ofe1_rock\n";

   print SOLFILE "$restrictive_layer_flag\t$aniso_ratio\t$sathydconduct\n";

   close SOLFILE;

}

sub CreateResponseFile {

   open (ResponseFile, ">" . $responseFile);
     print ResponseFile "m\n";           # datver / metric units
     print ResponseFile "y\n";           # not watershed
     print ResponseFile "1\n";           # 1 = continuous
     print ResponseFile "1\n";           # 1 = hillslope
     print ResponseFile "n\n";           # hillslope pass file out?
     if (lc($action) =~ /vegetation/) {
       print ResponseFile "1\n";           # 1 = annual; abbreviated
     }
     else {
       print ResponseFile "2\n";           # 2 = annual; detailed
     }
     print ResponseFile "n\n";             # initial conditions file?
     print ResponseFile $outputFile,"\n";  # soil loss output file
     print ResponseFile "y\n";             # water balance output?
     print ResponseFile $WatBalFile,"\n";  # water balance output file (watr_0.txt)

     if (lc($action) =~ /vegetation/) {
       print ResponseFile "y\n";           # crop output?
       print ResponseFile $cropFile,"\n";  # crop output file name
     }
     else {
       print ResponseFile "n\n";           # crop output?
     }
     print ResponseFile "n\n";             # soil output?
     print ResponseFile "n\n";             # distance/sed loss output?
#     print ResponseFile $SedLossFile,"\n";  # sediment loss output file (plot_0.txt)
     print ResponseFile "n\n";             # large graphics output?
     print ResponseFile "y\n";             # event-by-event out?
     print ResponseFile $EventByFile,"\n";  # event-by-event output file (evbe_0.txt)
     print ResponseFile "y\n";             # element output?
     print ResponseFile $ElementFile,"\n"; # element (OFE) output file ()
     print ResponseFile "n\n";             # final summary out?
     print ResponseFile "n\n";             # daily winter out?
     print ResponseFile "n\n";             # plant yield out?
     print ResponseFile "$manFile\n";      # management file name
     print ResponseFile "$slopeFile\n";    # slope file name
     print ResponseFile "$climateFile\n";  # climate file name
     print ResponseFile "$soilFile\n";     # soil file name
     print ResponseFile "0\n";             # 0 = no irrigation
     print ResponseFile "$years2sim\n";    # no. years to simulate
     print ResponseFile "0\n";             # 0 = route all events

   close ResponseFile;
   return $responseFile;
}

sub checkInput {

   $rc = '';
   if ($CL eq "") {$rc .= "No climate selected<br>\n"}
   if ($soil ne "sand" && $soil ne "silt" && $soil ne "clay" && $soil ne "loam")
       {$rc .= "Invalid soil: ".$soil."<br>\n"}
#  if ($treat1 ne "skid" && $treat1 ne "high" && $treat1 ne "low"
#      && $treat1 ne "short" && $treat1 ne "tall" && $treat1 ne "shrub"
#      && $treat1 ne "tree5" && $treat1 ne "tree20")
   if ($treatments{$treat1} eq "")
      {$rc .= "Invalid upper treatment: ".$treat1."<br>\n"}
   if ($treatments{$treat2} eq "")
      {$rc .= "Invalid lower treatment: ".$treat2."<br>\n"}
   if ($units eq 'm') {
     if ($ofe1_length < 0 || $ofe1_length > 3000)
        {$rc .= "Invalid upper length; range 0 to 3000 m<br>\n"}
     if ($ofe2_length < 0 || $ofe2_length > 3000)
        {$rc .= "Invalid lower length; range 0 to 3000 m<br>\n"}
   }
   else {
     if ($ofe1_length < 0 || $ofe1_length > 9000)
        {$rc .= "Invalid upper length; range 0 to 9000 ft<br>\n"}
     if ($ofe2_length < 0 || $ofe2_length > 9000)
        {$rc .= "Invalid lower length; range 0 to 9000 ft<br>\n"}
   }
   if ($ofe1_top_slope < 0 || $ofe1_top_slope > 1000)
      {$rc .= "Invalid upper top gradient; range 0 to 1000 %<br>\n"}
   if ($ofe1_mid_slope < 0 || $ofe1_mid_slope > 1000)
      {$rc .= "Invalid upper mid gradient; range 0 to 1000 %<br>\n"}
   if ($ofe2_mid_slope < 0 || $ofe2_mid_slope > 1000)
      {$rc .= "Invalid lower mid gradient; range 0 to 1000 %<br>\n"}
   if ($ofe2_bot_slope < 0 || $ofe2_bot_slope > 1000)
      {$rc .= "Invalid lower toe gradient; range 0 to 1000 %<br>\n"}
#   if ($ofe1_pcover < 0 || $ofe1_pcover > 100)
#      {$rc .= "Invalid upper percent cover; range 0 to 100 %<br>\n"}
#   if ($ofe2_pcover < 0 || $ofe2_pcover > 100)
#      {$rc .= "Invalid lower percent cover; range 0 to 100 %<br>\n"}
   if ($rc ne '') {$rc = '<font color="red"><b>' . $rc . "</b></font>\n"}
   return $rc;
}

sub cropper {

# average crop (.crp) file rill cover and live biomass
#    by OFE  (ignoring spikes to zero?)
#
# Knuth: recurrent mean calculation is:
#
#   M(1) = x(1)
#   M(k) = M(k-1) + (x(k)-M(k-1) / k
#
# (Seminumerical Methods, p. 232, Section 4.2.2, No. 15)

   open CROP, "<" . $cropFile;
   if ($debug) {print "Cropper: opening $cropFile<br>\n"}
   # read 15 lines of headers

   for $line (1..15) {
     $header = <CROP>
   }

   $_ = <CROP>;
#  chomp;
   @fields = split ' ',$_;
   $rillmean[1] = $fields[5];
   $livebiomean[1] = $fields[8];
   $_ = <CROP>;
#  chomp;
   @fields = split ' ',$_;
   $rillmean[2] = $fields[5];
   $livebiomean[2] = $fields[8];
   $count = 1;

   while (<CROP>) {
#    $record1 = <CROP>;
     if ($_ eq "") {last}
     $count += 1;
#    chomp;
     @fields = split ' ',$_;
     $ofe = $fields[7];
#    print "\n ",$fields[5],"  ",$fields[7],"  ",$fields[8];
     $rillcover[$ofe] = $fields[5];
     $livebiomass[$ofe] = $fields[8];
     $rillmean[$ofe] += ($rillcover[$ofe]-$rillmean[$ofe]) / $count;
     $livebiomean[$ofe] += ($livebiomass[$ofe]-$livebiomean[$ofe]) / $count;
   }
   close CROP;

#  print "<pre>\n";
#  print "OFE 1   Mean rill cover =   ", $rillmean[1],"\n";
#  print "        Mean live biomass = ",$livebiomean[1],"\n";
#  print "OFE 2   Mean rill cover =   ", $rillmean[2],"\n";
#  print "        Mean live biomass = ",$livebiomean[2],"\n";
#  print "Count = ", $count;
#  print "</pre>";

}

sub numerically { $b <=> $a }

sub parsead {                       ############### parsead

   $dailyannual = "<" . $outputFile;
#   if ($debug) {print "\nParsead: opening $outputFile<br>\n"}
   open AD, $dailyannual;
   $_ = <AD>;

   if (/Annual; detailed/) {    # Good file
     for $i (2..8) {$_ = <AD>}
#    if (/VERSION *([0-9.]+)/) {$version = $1}
#    print "\n", $version,"\n";

#======================== yearly precip and runoff events and amounts

#    print "</center><pre>\n";
#    print "    \t       \t       \t storm \t storm \t melt  \t melt\n";
#    print "    \t precip\t precip\t runoff\t runoff\t runoff\t runoff\n";
#    print "year\t events\t amount\t events\t amount\t events\t amount\n\n";
     while (<AD>) {
       if (/year: *([0-9]+)/) {
         $year = $1;
#        print $year,"  ";
         for $i (1..6) {$_ = <AD>}
         ($pcpe[$year], $pcpa[$year], $sre[$year], $sra[$year], $mre[$year], $mra[$year]) = split ' ',$_;
#        print "\t",$pcpe[$year],"\t",$pcpa[$year],"\t",$sre[$year],"\t",$sra[$year],"\t",$mre[$year],"\t",$mra[$year],"\n";
         $re[$year] = $sre[$year] + $mre[$year];
         $ra[$year] = $sra[$year] + $mra[$year];
       }
     }
     close AD;

#======================== yearly sediment leaving profile

     open AD, $dailyannual;
#    print "\nyear\tSediment\n\tleaving\n\tprofile\n\n";
     while (<AD>) {
       if (/SEDIMENT LEAVING PROFILE for year *([0-9]+) *([0-9.]+)/) {
         $year = $1;
         $sed_del[$year] = $2;
#       print "$year\t$sed_del[$year]\n";
       }
     }
     close AD;

#====== Net detachment (not all years are represented; final is an average)

     open AD, $dailyannual;
#    print "\nArea of net soil loss\n\n";
     $detcount = 0;
     while (<AD>) {
#      if (/Net Detachment *([A-Za-z.( )=]+) *([0-9.]+)/) {
       if (/Net Detachment *([A-Za-z( )=]+) *([0-9.]+)/) {
         $detachx[$detcount] = $2;
#        print "$detachx[$detcount]\n";
         $detcount += 1;
       }
     }
     $detcount -= 1;
     $avg_det = $detachx[$detcount];
     $detcount -= 1;
     for $looper (0..$detcount) {$detach[$looper] = $detachx[$looper]};
     close AD;

#===================== Mean annual values for various parameters

     open AD, $dailyannual;
     while (<AD>) {
       if (/Mean annual precipitation *([0-9.]+)/) {
         $avg_pcp = $1;
#        print "\n\nAverage annual precip: $avg_pcp\n";
         $_ = <AD>;
         if (/Mean annual runoff from rainfall *([0-9.]+)/) {
           $avg_rro = $1;
#          print "Average annual runoff from rainfall: $avg_rro\n";
         }
         $_ = <AD>;
         $_ = <AD>;
         if (/rain storm during winter *([0-9.]+)/) {
           $avg_sro = $1;
#          print "Average annual runoff from snowmelt: $avg_sro\n";
         }
       }
       if (/AVERAGE ANNUAL SEDIMENT LEAVING PROFILE/) {
#        print $_;
         if (/AVERAGE ANNUAL SEDIMENT LEAVING PROFILE *([0-9.]+)/) {  # WEPP pre-98.4
           $avg_sed = $1;
         }
         else {   # WEPP 98.4
           $_ = <AD>;  # print;
           if (/ *([0-9.]+)/) {$avg_sed = $1}
         }
#        print "Average sediment delivery = $avg_sed\n";
       }
     }
     close AD;

     @pcpa = sort numerically @pcpa;
#    print @pcpa,"\n";
     @ra = sort numerically @ra;
#    print @ra,"\n";
     @detach = sort numerically @detach;
#    print @detach,"\n";
     @sed_del = sort numerically @sed_del;
#    print @sed_del,"\n";

     $nnzpcp=0;
     $nnzra=0;
     $nnzdetach=0;
     $nnzsed_del=0;
     foreach $elem (@pcpa) {$nnzpcp += 1 if ($elem*1 != 0)}
     foreach $elem (@ra) {$nnzra += 1 if ($elem*1 != 0)}
     foreach $elem (@detach) {$nnzdetach += 1 if ($elem*1 != 0)}
     foreach $elem (@sed_del) {$nnzsed_del += 1 if ($elem*1 != 0)}
     $nzpcp = $simyears-$nnzpcp;
     $nzra = $simyears-$nnzra;			$omnzra=1-$nzra;
     $nzdetach = $simyears-$nnzdetach;		$omnzdetach=1-$nzdetach;
     $nzsed_del = $simyears-$nnzsed_del;	$omnzsed_del=1-$nzsed_del;

     $avg_ro = $avg_rro + $avg_sro;
     #print $year;
     #print "\n================================\n";
     #print "\t precip\trunoff\terosion\tsed\n\n";
     # print "#(x=0)\t pcp= $nnzpcp\t sra= $nnzra\t det= $nnzdetach\t sed_del= $nnzsed_del\n";
     # print "#(x=0)\t pcp= $nzpcp\t sra= $nzra\t det= $nzdetach\t sed_del= $nzsed_del\n";
     #print "p(x=0)\t",($nzpcp)/$year,
     #            "\t",($nzra)/$year,
     #            "\t",($nzdetach)/$year,
     #            "\t",($nzsed_del)/$year,"\n";
     #print "Average $avg_pcp\t$avg_ro\t$avg_det\t$avg_sed\n";
     #print "return\nperiod\n";
     #print "100\t$pcpa[0]\t$ra[0]\t$detach[0]\t$sed_del[0]\n";    # 1
     #print " 50\t$pcpa[1]\t$ra[1]\t$detach[1]\t$sed_del[1]\n";    # 2
     #print " 20\t$pcpa[4]\t$ra[4]\t$detach[4]\t$sed_del[4]\n";    # 5
     #print " 10\t$pcpa[9]\t$ra[9]\t$detach[9]\t$sed_del[9]\n";    # 10
     #print "  5\t$pcpa[19]\t$ra[19]\t$detach[19]\t$sed_del[19]\n";    # 20
     #print "</pre><center>\n";
#==================
   }		# if /Annual detailed/
   else {
     chomp;
     s/^\s*(.*?)\s*$/$1/;
     print "\nExpecting 'Annual; detailed' file; you gave me a '$_' file\n";
   }
}

sub CreateCligenFile {

# stuff what was working on PC but not on WHITEPINE

#   $climatePar = "$CL" . '.par';
#   $station = substr($CL, length($CL)-8);
#   $user_ID = 'getalife';
#   $outfile = $climateFile;

#   $climateFile = "$working\\$station.cli";
#   $outfile = $climateFile;
#   $rspfile = "$working\\" . $user_ID . ".rsp";
#   $stoutfile = "$working\\" . $user_ID . ".out";

# end of stuff what was working

# swupped from wr.pl which works on WHITEPINE -- still works on PC
# now does not work on PC ... 2009.04.23

    $climatePar = "$CL" . '.par';
#   $user_ID = 'getalife';
    if ($platform eq 'pc') {
#      $lastslash = rindex($CL,'\\');
#      $station = substr($CL, length($CL)-$lastslash);

#      $climateFile = "$working\\$station.cli";
      $outfile   = $climateFile;
      $rspfile   = "$working\\cligen.rsp";
      $stoutfile = "$working\\cligen.out";
    }
    else {
#     $user_ID = '';
#     $climateFile = '..\\working' . "$station.cli";
#      $climateFile = "../working/$unique.cli";
      $outfile   = $climateFile;
#     $rspfile   = "../working/$user_ID.rsp";
#     $stoutfile = "../working/$user_ID.out";
      $rspfile   = "../working/c$unique.rsp";
      $stoutfile = "../working/c$unique.out";
    }

# end swup

   if ($debug) {

print "[CreateCligenFile]<br>
Arguments:    $args<br>
ClimatePar:   $climatePar<br>
ClimateFile:  $climateFile<br>
OutputFile:   $outfile<br>
ResponseFile: $rspfile<br>
StandardOut:  $stoutfile<br>
CL: $CL<br>
station: $station<br>

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
#  print RSP $years,"\n";
     print RSP $years2sim,"\n";
    print RSP $climateFile,"\n";
    print RSP "n\n";
   close RSP;

   unlink $climateFile;   # erase previous climate file so's CLIGEN'll run

    if ($platform eq 'pc') {
       @args = ("..\\rc\\cligen43.exe <$rspfile >$stoutfile");
    }
    else {
#      @args = ("nice -20 ../rc/cligen43 <$rspfile >$stoutfile");
       @args = ("../rc/cligen43 <$rspfile >$stoutfile");
    }
   system @args;

   $cligen_version="version unknown";
   open STOUT, "<$stoutfile";
   while (<STOUT>) {
     if (/VERSION/) {
        $chomp;
        $cligen_version = lc($_);
        last;
     }
   }
   close STOUT;
#   print $cligen_version;

#   unlink $rspfile;     #  "../working/c$unique.rsp"
#   unlink $stoutfile;   #  "../working/c$unique.out"

}

sub getAnnualPrecip {

# in:  $climatePar
# out: $ap_mean_precip

    open PAR, "<$climatePar";
      $line=<PAR>;                           # EPHRATA CAA AP WA                       452614 0
if ($debug) {print $line,"<br>\n"}
      $line=<PAR>;                           # LATT=  47.30 LONG=-119.53 YEARS= 44. TYPE= 3
      $line=<PAR>;	# ELEVATION = 1260. TP5 = 0.86 TP6= 2.90
      $line=<PAR>;	# MEAN P   0.10  0.10  0.11  0.10  0.11  0.14  0.14  0.09  0.10  0.10  0.12  0.12
      @ap_mean_p_if = split ' ',$line; $ap_mean_p_base = 2;
      $line=<PAR>;	# S DEV P  0.12  0.12  0.11  0.13  0.13  0.18  0.22  0.13  0.13  0.11  0.14  0.13
      $line=<PAR>;	# SQEW  P  1.88  2.30  2.21  2.15  2.29  2.35  3.60  3.22  2.05  2.49  2.22  1.87
      $line=<PAR>;	# P(W/W)   0.47  0.50  0.39  0.32  0.33  0.30  0.27  0.28  0.40  0.41  0.42  0.48
      @ap_pww = split ' ',$line; $ap_pww_base = 1;
      $line=<PAR>;	# P(W/D)   0.20  0.16  0.15  0.13  0.13  0.11  0.05  0.06  0.08  0.12  0.23  0.23
      @ap_pwd = split ' ',$line; $ap_pwd_base=1;
    close PAR;

    @ap_month_days=(31,28,31,30,31,30,31,31,30,31,30,31);

    $ap_units='m';
#   $pcpunit='in';
    for $ap_i (1..12) {
      $ap_pw[$ap_i] = $ap_pwd[$ap_i] / (1 + $ap_pwd[$ap_i] - $ap_pww[$ap_i]);
    }
    $ap_annual_precip = 0;
    $ap_annual_wet_days = 0;
    for $ap_i (0..11) {
        $ap_num_wet = $ap_pw[$ap_i+$ap_pww_base] * $ap_month_days[$ap_i];
        $ap_mean_p = $ap_num_wet * $ap_mean_p_if[$ap_i+$ap_mean_p_base];
        if ($ap_units eq 'm') {
           $ap_mean_p *= 25.4;                 # inches to mm
        }
        $ap_annual_precip += $ap_mean_p;
    }
}

sub readPARfile {

#   $PARfile= 'working/166_2_22_167_o.par';

#   $PARfile
#   $units = 'ft';

   local $line, @mean_p_if, $mean_p_base, @pww, $pww_base, @pwd, $pwd_base, @tmax_av, $tmax_av_base;
   local @tmin_av, $tmin_av_base, @month_days, @num_wet, @mean_p, $tempunits, $prcpunits, $i, $mod, $modfrom;

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
    $line=<PAR>;                 # Elev

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
   }
   else {
     $tempunits = 'deg F';
     $prcpunits = 'in';
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
     $, = '';
   }
}

sub WaterBalance {

# returns average annual precip, Q, Ep, Es, Dp, Latqcc, sum from OFE 4 
# assumes 100 year 4-OFE file

# uses waterbal file name
# reads WaterBal file
#	horizontal length ?
#	slope length ?
# return vector of P  RM Q  Ep Es Dp latqcc total
#                  mm mm mm mm mm mm mm     mm

$sumP = 0; $sumEp = 0; $sumEs = 0; $sumDp = 0; $sumLatqcc = 0;
$sumRM = 0; $sumQ = 0;

open WTRFILE, "$WatBalFile";

# DAILY WATER BALANCE
#
# J=julian day, Y=simulation year
# P= precipitation       
# RM=rainfall+irrigation+snowmelt
# Q=daily runoff, Ep=plant transpiration
# Es=soil evaporation, Dp=deep percolation
# watstr=water stress for plant growth  latqcc=lateral subsurface flow
#
# ------------------------------------------------------------------------------
#  OFE  J    Y      P      RM     Q      Ep    Es     Dp  UpStrmQ  latqcc Total-Soil  frozwt
#  #    -    -      mm     mm     mm     mm     mm     mm     -      mm    Water(mm)   mm
# ------------------------------------------------------------------------------
#

  for ($i=0;$i<13;$i++) {
   $line=<WTRFILE>;
  }
#  print $line;

#    print "OFE\tP\tRM\tQ\tEp\tEs\tDp\tlatqcc\ttotal\n";
#    print "\tmm\tmm\tmm\tmm\tmm\tmm\tmm\tmm\n";

  while (<WTRFILE>) {		# OFE 1
    $line = <WTRFILE>;		# OFE 2
    $line = <WTRFILE>;		# OFE 3
    $line = <WTRFILE>;		# OFE 4

    ($OFE, $JulDay, $SimYr, $P, $RM, $Q, $Ep, $Es, $Dp, $UpStrmQ, $latqcc, $TotSoilWater, $rest) = split ' ',$_;
#   $total = $RM + $Q + $Ep + $Es + $Dp + $latqcc;
    $total = $Q + $Ep + $Es + $Dp + $latqcc;
#   print "$OFE\t$P\t$RM\t$Q\t$Ep\t$Es\t$Dp\t$latqcc\t$total\n";
    $sumRM += $RM; $sumQ += $Q; $sumP += $P; $sumEp += $Ep; $sumEs += $Es; $sumDp += $Dp; $sumLatqcc += $latqcc;
    $sumTotal += $total;
  }

close WTRFILE;

#print "\n Totals\n";
#print "\tP\tRM\tQ\tEp\tEs\tDp\tLatqcc\tTotal\n";
##print "\t$sumP\t$sumRM\t$sumQ\t$sumEp\t$sumEs\t$sumDp\t$sumLatqcc\t$sumTotal\n";
#printf "\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n", $sumP,$sumRM,$sumQ,$sumEp,$sumEs,$sumDp,$sumLatqcc,$sumTotal;


 $sumP/=100;
 $sumRM/=100;
 $sumQ/=100;
 $sumEp/=100;
 $sumEs/=100;
 $sumDp/=100;
 $sumLatqcc/=100;
 $sumTotal/=100;

# print "\t$sumP\t$sumRM\t$sumQ\t$sumEp\t$sumEs\t$sumDp\t$sumLatqcc\t$sumTotal\n";
# $results = sprintf "\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n", $sumP,$sumRM,$sumQ,$sumEp,$sumEs,$sumDp,$sumLatqcc,$sumTotal;
# @results = split ' ',$results;
 @results = ($sumP,$sumRM,$sumQ,$sumEp,$sumEs,$sumDp,$sumLatqcc,$sumTotal);
 return @results
}

# ------------------------ end of subroutines ----------------------------

