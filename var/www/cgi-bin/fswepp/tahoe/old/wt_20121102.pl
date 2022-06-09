#! /usr/bin/perl
#
# wt.pl        Tahoe Basin Sediment Model
#
# Tahoe Basin Sediment Model workhorse
# Reads user input from tahoe.pl, runs WEPP, parses output files

# Needed update: automatic history popup

# 2012.11.02 DEH -- point to "olddata" to make way for changed .ini data files
# 2009.08.24 DEH -- Modify from wd.pl

#  $debug=1;

## BEGIN HISTORY ###################################
## Tahoe Basin Sediment Model version history

   $version = '2011.02.14';     # Adjust handling of sod and bunchgrass
#  $version = '2010.06.01';	# Model release
#! $version = "2010.05.27";
#! $version = "2010.03.03";

## END HISTORY ###################################

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
   $treat2=$parameters{'LowSlopeType'};
   $ofe2_length=$parameters{'ofe2_length'}+0;
   $ofe2_mid_slope=$parameters{'ofe2_top_slope'}+0;
   $ofe2_bot_slope=$parameters{'ofe2_bot_slope'}+0;
   $ofe2_pcover=$parameters{'ofe2_pcover'}+0;
   $ofe2_rock=$parameters{'ofe2_rock'}+0;
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
   $description=$parameters{'description'};	# DEH 2007.04.04

   $weppversion=$parameters{'weppversion'};     # DEH 2009.02.23

### filter bad stuff out of description ###
#   limit length to reasonable (200?)
#   remove HTML tags ( '<' to &lt; and '>' to &gt; )
    $description = substr($description,0,100);
    $description =~ s/</&lt;/g;
    $description =~ s/>/&gt;/g;
###

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

   if (lc($action) =~ /custom/) {
     $tahoe = "http://" . $wepphost . "/cgi-bin/fswepp/tahoe/tahoe.pl";
     if ($platform eq "pc") {
       exec "perl ../rc/rockclim.pl -server -i$me -u$units $tahoe"
     }
     else {
#      exec "../rc/rockclim_ll.pl -server -i$me -u$units $weppdist"
#      exec "../rc/rockclim_col.pl -server -i$me -u$units $weppdist"
       exec "../rc/rockclim.pl -server -i$me -u$units $tahoe"
     }
     die
   }		# /custom/

   if (lc($achtung) =~ /describe climate/) {
     $tahoe = "http://" . $wepphost . "/cgi-bin/fswepp/tahoe/tahoe.pl";
     if ($platform eq "pc") {
       exec "perl ../rc/descpar.pl $CL $units $tahoe"
     }
     else {
       exec "../rc/descpar.pl $CL $units $tahoe"
     }
     die
   }		# /describe climate/

   if (lc($achtung) =~ /describe soil/) {   ##########

     $units=$parameters{'units'};
     $SoilType=$parameters{'SoilType'};  # get SoilType (granitic, volcanic, allucvial, rockpave)
#     $surface=$parameters{'surface'};    # graveled or native
#     $slope=$parameters{'SlopeType'};    # get slope type (outunrut...)

#     if    ($slope eq 'inveg')    {$conduct='10'}
#     elsif ($slope eq "outunrut") {$conduct = '2'}
#     elsif ($slope eq "outrut")   {$conduct = '2'}
#     elsif ($slope eq "inbare")   {$conduct = '2'}

     if ($platform eq "pc") {$soilPath = 'data\\'}
     else                   {$soilPath = 'data/'}

     $surf = "";
     if (substr ($surface,0,1) eq "g") {$surf = "g"}
     $soilFile = '3' . $surf . $SoilType . $conduct . '.sol';

     $tahoe = "http://" . $wepphost . "/cgi-bin/fswepp/tahoe/tahoe.pl";
     $soilFilefq = $soilPath . $soilFile;
     print "Content-type: text/html\n\n";
     print "<HTML>\n";
     print " <HEAD>\n";
     print "  <TITLE>Tahoe Basin Sediment Model -- Soil Parameters</TITLE>\n";
     print " </HEAD>\n";
     print ' <BODY background="http://',$wepphost,
          '/fswepp/images/note.gif" link="#ff0000">
   <font face="Arial, Geneva, Helvetica">
    <blockquote>
     <table width=95% border=0>
      <tr>
       <td> 
        <a href="JavaScript:window.history.go(-1)">
        <IMG src="http://',$wepphost,'/fswepp/images/tahoe.jpg"
        align="left" alt="Back to FS WEPP menu" border=1></a>
       </td>
       <td align=center>
        <hr>
        <h3>Tahoe Basin Sediment Model Soil Texture Properties</h3>
        <hr>
       </td>
      </tr>
     </table>
';
     if ($debug) {print "Action: '$action'<br>\nAchtung: '$achtung'<br>\n"}

#     if ($SoilType eq 'granitic') {
#       print "Granitic ()<br>\n";
#       print "<br>\n";
#     }
#     elsif ($SoilType eq 'volcanic') {
#       print "volcanic<br>\n";
#       print "<br>\n";
#     }
#     elsif ($SoilType eq 'alluvial') {
#       print "alluvial ()<br>\n";
#       print "<br>\n";
#     }
#     elsif ($SoilType eq 'rockpave') {
#       print "rock/pavement<br>\n";
#       print "<br>\n";
#     }
#
   if ($platform eq "pc") {
     if (-e 'd:/fswepp/working') {$working = 'd:\\fswepp\\working'}
     elsif (-e 'c:/fswepp/working') {$working = 'c:\\fswepp\\working'}
     else {$working = '..\\working'}
     $soilFile     = "$working\\wtwepp.sol";
     $soilPath     = 'data\\';
   }
   else {
     $working = '../working';
     $unique='wepp-' . $$;       # DEH 01/13/2004
     $soilFile     = "$working/$unique" . '.sol';
     $soilPath     = 'data/';
   }
#
     &CreateSoilFile;

     open SOIL, "<$soilFile";
     $weppver = <SOIL>;
     $comment = <SOIL>;
     while (substr($comment,0,1) eq "#") {
       chomp $comment;
#       print $comment,"\n";
       $comment = <SOIL>;
     }

     print "
  <center>
   <table border=0 cellpadding=3>
";

#      $solcom = $comment;

     $record = <SOIL>;
     @vals = split " ", $record;
     $ntemp = @vals[0];      # no. flow elements or channels
     $ksflag = @vals[1];     # 0: hold hydraulic conductivity constant
                             # 1: use internal adjustments to hydr con
     for $i (1..$ntemp) {
       print "
   <tr>
    <th colspan=5 bgcolor=\"85d2d2\"><font face=\"Arial, Geneva, Helvetica\">
     Element $i &mdash;
";
       $record = <SOIL>;
       @descriptors = split "'", $record;
#      $my_soilID = lc(@descriptors[1]);
#      $my_texture =lc(@descriptors[3]);
       $my_soilID = @descriptors[1];
       $my_texture =@descriptors[3];
       print "$my_soilID treatment;&nbsp;&nbsp;   ";        # slid:
       print "$my_texture soil texture\n";        # texid: soil texture
       ($nsl,$salb,$sat,$ki,$kr,$shcrit,$avke) = split " ", @descriptors[4];
#      @vals = split " ", @descriptors[4];
#      print "No. soil layers: $nsl\n";
       $avke_e = sprintf "%.2f", $avke / 25.4;

       print "
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Albedo of the bare dry surface soil
     <td align=right valign=bottom><font face=\"Arial, Geneva, Helvetica\" size=-1>$salb
     <td>&nbsp;
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Initial saturation level of the soil profile porosity
     <td align=right valign=bottom><font face=\"Arial, Geneva, Helvetica\" size=-1>$sat
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>m m<sup>-1</sup>
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Baseline interrill erodibility parameter (<i>k<sub>i</sub></i> )
     <td align=right valign=bottom><font face=\"Arial, Geneva, Helvetica\" size=-1>$ki
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>kg s m<sup>-4</sup>
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Baseline rill erodibility parameter (<i>k<sub>r</sub></i> )
     <td align=right valign=bottom><font face=\"Arial, Geneva, Helvetica\" size=-1>$kr
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>s m<sup>-1</sup>
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Baseline critical shear parameter
     <td align=right valign=bottom><font face=\"Arial, Geneva, Helvetica\" size=-1>$shcrit
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>N m<sup>-2</sup>
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Effective hydraulic conductivity of surface soil
     <td align=right valign=bottom><font face=\"Arial, Geneva, Helvetica\" size=-1>$avke
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>mm h<sup>-1</sup>
     <td align=right valign=bottom><font face=\"Arial, Geneva, Helvetica\" size=-1>$avke_e
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>in hr<sup>-1</sup>
";
       for $layer (1..$nsl) {
         $record = <SOIL>;
         ($solthk,$sand,$clay,$orgmat,$cec,$rfg) = split " ", $record;
         $solthk_e = sprintf "%.2f", $solthk / 25.4;
         print "
    <tr>
     <td>&nbsp;
     <th colspan=4 bgcolor=\"85d2d2\"><font face=\"Arial, Geneva, Helvetica\">layer $layer
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Depth from soil surface to bottom of soil layer
     <td align=right valign=bottom><font face=\"Arial, Geneva, Helvetica\" size=-1>$solthk
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>mm
     <td align=right valign=bottom><font face=\"Arial, Geneva, Helvetica\" size=-1>$solthk_e
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>in
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Percentage of sand
     <td align=right valign=bottom><font face=\"Arial, Geneva, Helvetica\" size=-1>$sand
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>%
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Percentage of clay
     <td align=right valign=bottom><font face=\"Arial, Geneva, Helvetica\" size=-1>$clay
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>%
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Percentage of organic matter (by volume)
     <td align=right valign=bottom><font face=\"Arial, Geneva, Helvetica\" size=-1>$orgmat
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>%
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Cation exchange capacity
     <td align=right valign=bottom><font face=\"Arial, Geneva, Helvetica\" size=-1>$cec
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>meq per 100 g of soil
    <tr>
     <th align=left><font face=\"Arial, Geneva, Helvetica\" size=-1>Percentage of rock fragments (by volume)
     <td align=right valign=bottom><font face=\"Arial, Geneva, Helvetica\" size=-1>$rfg
     <td><font face=\"Arial, Geneva, Helvetica\" size=-1>%
";
       }
     }
     close SOIL;
#           <form method="post" action="',$soilFilefq,'">
     print '   </table>
  <p>
  <hr>
  <p>
<!-- <form method="post" action="wepproad.sol">
    <input type="submit" value="DOWNLOAD">
    <input type="hidden" value="',$soilFile,'" name="filename">
   </form>
-->
';

     open SOIL, "<$soilFile";
     print '
   </center>
   <p>
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

# *******************************

# ########### RUN WEPP ###########

   $years2sim=$climyears;
   if ($years2sim > 100) {$years2sim=100}

#  if ($host eq "") {$host = 'unknown';}
   $unique='wepp-' . $$;
#  if ($debug) {print 'Unique? filename= ',$unique,"\n<BR>"}

   if ($platform eq "pc") {
     if (-e 'd:/fswepp/working') {$working = 'd:\\fswepp\\working'}
     elsif (-e 'c:/fswepp/working') {$working = 'c:\\fswepp\\working'}
     else {$working = '..\\working'}

     $responseFile = "$working\\wtwepp.in";
     $outputFile   = "$working\\wtwepp.out";
     $stoutFile    = "$working\\wtwepp.sto";
     $sterFile     = "$working\\wtwepp.err";
     $slopeFile    = "$working\\wtwepp.slp";
     $soilFile     = "$working\\wtwepp.sol";
     $cropFile     = "$working\\wtwepp.crp";
     $climateFile  = "$CL" . '.cli';
     $manFile      = "$working\\wtwepp.man";
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
     $climateFile  = "$CL" . '.cli';
     $stoutFile    = "$working/$unique" . ".stout";
     $sterFile     = "$working/$unique" . ".sterr";
     $manFile      = "$working/$unique" . ".man";
     $soilPath     = 'data/';
     $manPath      = 'data/';
   }

# make hash of treatments

   $treatments = {};
   $treatments{Skid}       = 'skid trail';
   $treatments{HighFire}   = 'high severity fire';
   $treatments{LowFire}    = 'low severity fire';
#  $treatments{Bunchgrass} = 'poor grass';
#  $treatments{Sod}        = 'good grass';
   $treatments{Bunchgrass} = 'good grass';
   $treatments{Sod}   	   = 'poor grass';
   $treatments{Shrub}      = 'shrubs';
   $treatments{Bare}       = 'bare';
   $treatments{Mulch}      = 'mulch only';
   $treatments{Till}       = 'mulch and till';
   $treatments{LowRoad}    = 'low traffic road';
   $treatments{HighRoad}   = 'high traffic road';
   $treatments{YoungForest}= 'thin or young forest';
   $treatments{OldForest}  = 'mature forest';

# make hash of soil types

   $soil_type = {};
   $soil_type{granitic} = 'granitic';
   $soil_type{volcanic} = 'volcanic';
   $soil_type{alluvial} = 'alluvial';
   $soil_type{rockpave} = 'rock/pavement';

# ----------------------------

   $host = $ENV{REMOTE_HOST};

   $user_ofe1_length=$ofe1_length;
   $user_ofe2_length=$ofe2_length;

   $rcin = &checkInput;
   if ($rcin eq '') {

     if ($units eq 'm') {
#      $user_ofe1_length=$ofe1_length;
#      $user_ofe2_length=$ofe2_length;
       $user_ofe_area=$ofe_area;
     }
     if ($units eq 'ft') {
#      $user_ofe1_length=$ofe1_length;
#      $user_ofe2_length=$ofe2_length;
       $user_ofe_area=$ofe_area;
       $ofe1_length=$ofe1_length/3.28;		# 3.28 ft == 1 m
       $ofe2_length=$ofe2_length/3.28;		# 3.28 ft == 1 m
       $ofe_area=$ofe_area/2.47;		# 2.47 ac == 1 ha; Schwab Fangmeier Elliot Frevert
     }

     $ofe_width=$ofe_area*10000/($ofe1_length+$ofe2_length);

     if ($debug) {print "Creating Slope File<br>\n"}
     &CreateSlopeFile;
     if ($debug) {print "Creating Management File<br>\n"}
#     &CreateManagementFile;
     &CreateManagementFileT;
     if ($debug) {print "Creating Climate File<br>\n"}
     &CreateCligenFile;
     if ($debug) {print "Creating Soil File<br>\n"}
     &CreateSoilFile;
     if ($debug) {print "Creating WEPP Response File<br>\n"}
     &CreateResponseFile;

#    @args = ("nice -20 ./wepp <$responseFile >$stoutFile 2>$sterFile");
     if ($platform eq "pc") {
       @args = ("..\\wepp <$responseFile >$stoutFile")
     }
     else {
#      if ($weppversion eq '2008') {@args = ("../wepp2008 <$responseFile >$stoutFile 2>$sterFile")};  # DEH 2009.02.23
#      if ($weppversion eq '2000')
#        {@args = ("../wepp2000 <$responseFile >$stoutFile 2>$sterFile")};  # DEH 2009.02.23
         @args = ("wine ../wepp2010.100.exe <$responseFile >$stoutFile 2>$sterFile")
#     @args = ("../wepp <$responseFile >$stoutFile 2>$sterFile")
     }
     system @args;

########################  start HTML output ###############

   print "Content-type: text/html\n\n";
   print '<HTML>
 <HEAD>
  <TITLE>Tahoe Basin Sediment Model Results</TITLE>
<!-- new 2004 -->
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
        last if (/Management Section/ && $years2sim>5);
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
       chop;
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
#     print '      filewindow.document.writeln("climate file: ', $climateFile, '")$
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

print "
  function popuphistory() {
    height=500;
    width=660;
    pophistory = window.open('','pophistory','toolbar=no,location=no,status=no,directories=no,menubar=no,scrollbars=yes,resizable=yes,width='+width+',height='+height);
";
    print make_history_popup();

print '
    pophistory.document.close()
    pophistory.focus()
  }
  </script>
 </HEAD>
 <BODY background="http://',$wepphost,'/fswepp/images/note.gif" link=green vlink=green>
  <font face="Arial, Geneva, Helvetica">
  <blockquote>
   <table width=100% border=0>
    <tr>
     <td>
      <a href="JavaScript:window.history.go(-1)">
      <IMG src="http://',$wepphost,'/fswepp/images/tahoe.jpg"
      align="left" alt="Return to Tahoe Basin Sediment Model input screen" border=1></a>
     <td align=center>
      <hr>
      <h3>Tahoe Basin Sediment Model Results (* provisional *)</h3>
      <hr>
     </td>
    </tr>
   </table>
';

#  print $weppversion;

######################## end of top part of HTML output ###############

#------------------------------

  # 2010.05.15 #
     unlink $climateFile;    # be sure this is right file .....     # 2/2000

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

# print "******************************** found: $found ***************************<br><br>\n";

########################   NAN check   ###################

     open weppoutfile, "<$outputFile";
     while (<weppoutfile>) {
       if (/NaN/) {
         open NANLOG, ">>../working/NANlog.log";
         flock (NANLOG,2);
         print NANLOG "$user_ID_\t";
         print NANLOG "WT\t$unique\n";
         close NANLOG;
         last;
       }
     }
     close (weppoutfile);

########################   NAN check   ###################

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

       print "   </pre>
  <center>
   <h3>User inputs</h3>

    <table border=1 cellpadding=5>
     <tr>
      <th bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica'>Climate/Location</th>
      <td colspan=5 bgcolor='#FAF8CC'><font face='Arial, Geneva, Helvetica'><b>$climate_name</b>
       <br>
       <font size=1>
";
     $PARfile = $climatePar;                      # for &readPARfile()
#&readPARfile($climatePar);
       print &readPARfile($climatePar);
     
print "
       </font>
      </td>
     </tr>
     <tr>
      <th bgcolor=\"#85d2d2\"><font face='Arial, Geneva, Helvetica'>Soil texture</th>
      <td colspan=5 bgcolor=\"#FAF8CC\"><font face='Arial, Geneva, Helvetica'>$soil_type{$soil}</td>
     </tr>
     <tr>
      <th bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>Element</th>
      <th bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>Treatment/<br>Vegetation</th>
      <th bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>Gradient<br> (%)</th>
      <th bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>Length<br> ($units)</th>
      <th bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>Cover<br> (%)</th>
      <th bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>Rock<br> (%)</th>
     </tr>
     <tr>
      <th align=right rowspan=2 bgcolor='#85d2d2'><font face='Arial, Geneva, Helvetica'>Upper</th>
      <td rowspan=2 bgcolor=\"#FAF8CC\"><font face='Arial, Geneva, Helvetica'>$treatments{$treat1}</td>
      <td align=right bgcolor=\"#FAF8CC\"><font face='Arial, Geneva, Helvetica'>$ofe1_top_slope</td>
      <td align=right rowspan=2 bgcolor=\"#FAF8CC\"><font face='Arial, Geneva, Helvetica'>$user_ofe1_length</td>
      <td align=right rowspan=2 bgcolor=\"#FAF8CC\"><font face='Arial, Geneva, Helvetica'>$ofe1_pcover</td>
      <td align=right rowspan=2 bgcolor=\"#FAF8CC\"><font face='Arial, Geneva, Helvetica'>$ofe1_rock</td>
     </tr>
     <tr>
      <td align=right bgcolor=\"#FAF8CC\"><font face='Arial, Geneva, Helvetica'>$ofe1_mid_slope</td>
     </tr>
     <tr>
      <th align=right rowspan=2 bgcolor=\"85d2d2\"><font face='Arial, Geneva, Helvetica'>Lower</th>
      <td rowspan=2 bgcolor=\"#FAF8CC\"><font face='Arial, Geneva, Helvetica'>$treatments{$treat2}</td>
      <td align=right bgcolor=\"#FAF8CC\"><font face='Arial, Geneva, Helvetica'>$ofe2_mid_slope</td>
      <td align=right rowspan=2 bgcolor=\"#FAF8CC\"><font face='Arial, Geneva, Helvetica'>$user_ofe2_length</td>
      <td align=right rowspan=2 bgcolor=\"#FAF8CC\"><font face='Arial, Geneva, Helvetica'>$ofe2_pcover</td>
      <td align=right rowspan=2 bgcolor=\"#FAF8CC\"><font face='Arial, Geneva, Helvetica'>$ofe2_rock  </td>
     </tr>
     <tr>
      <td align=right bgcolor=\"#FAF8CC\"><font face='Arial, Geneva, Helvetica'>$ofe2_bot_slope</font></td>
     </tr>
     <tr>
      <td colspan=6 bgcolor=\"#FAF8CC\"><font face='Arial, Geneva, Helvetica' size=-1>$description</font></td>
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
   $pcp_unit = 'mm'
}
if ($units eq 'ft') {
   $user_precip = sprintf "%.2f", $precip*0.0394;	# mm to in
   $user_rro = sprintf "%.2f", $rro*0.0394;		# mm to in
   $user_sro = sprintf "%.2f", $sro*0.0394;		# mm to in
   $user_asyra = sprintf "%.3f", $asyra*0.445;		# t/ha to t/ac # 2004.10.14 DEH
   $user_asypa = sprintf "%.3f", $asypa*0.445;		# t/ha to t/ac # 2004.10.14 DEH
   $rate = 't ac<sup>-1</sup>';
   $pcp_unit = 'in.'
}
#   <p><hr><p>
   print "
   <h3>Mean annual averages for $simyears years</h3>
    <table border=0 cellpadding=4 bgcolor=lightyellow>
     <tr>
      <td colspan=3></td><th colspan=2><font size=-1>Total in<br>$years2sim years</font></th>
     </tr>
     <tr>
      <td align=right><font face='Arial, Geneva, Helvetica'>$user_precip</td>
      <td><font face='Arial, Geneva, Helvetica'>$pcp_unit</td>
      <td><font face='Arial, Geneva, Helvetica'>precipitation from </td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$storms</td>
      <td><font face='Arial, Geneva, Helvetica'>
          <a onMouseOver=\"window.status='There were $storms storms in $simyears year(s)';return true;\"
             onMouseOut=\"window.status='';return true;\">
          storms</a></td>
     </tr>
     <tr>
      <td align=right><font face='Arial, Geneva, Helvetica'>$user_rro</td>
      <td><font face='Arial, Geneva, Helvetica'>$pcp_unit</td>
      <td><font face='Arial, Geneva, Helvetica'>runoff from rainfall from</td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$rainevents</td>
      <td><font face='Arial, Geneva, Helvetica'>events</td>
     </tr>
     <tr>
      <td align=right><font face='Arial, Geneva, Helvetica'>$user_sro</td>
      <td><font face='Arial, Geneva, Helvetica'>$pcp_unit</td>
      <td><font face='Arial, Geneva, Helvetica'>runoff from snowmelt or winter rainstorm from</td>
      <td align=right><font face='Arial, Geneva, Helvetica'>$snowevents</td>
      <td><font face='Arial, Geneva, Helvetica'>events</td>
     </tr>
     <tr>
      <td align=right valign=bottom><font face='Arial, Geneva, Helvetica'>$user_asyra</td>
      <td><font face='Arial, Geneva, Helvetica'>$rate</td>
      <td valign=bottom>upland erosion rate ($syra kg m<sup>-2</sup>)</td>
     </tr>
     <tr>
      <td align=right valign=bottom><font face='Arial, Geneva, Helvetica'>$user_asypa</td>
      <td><font face='Arial, Geneva, Helvetica'>$rate</td>
      <td valign=bottom><font face='Arial, Geneva, Helvetica'>sediment leaving profile ($sypa kg m<sup>-1</sup> width)</td>
     </tr>
    </table>
   </center>
";

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
#    <p><hr><p>
         print "
   <center>
    <h3>Return period analysis<br>
        based on $simyears&nbsp;years of climate</h3>
    <p>
    <table border=0 cellpadding=3 bgcolor=lightyellow>
     <tr>
      <th bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>Return<br>Period</th>
      <th bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>Precipitation<br>($pcp_unit)</th>
      <th bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>Runoff<br>($pcp_unit)</th>
      <th bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>Erosion<br>($rate)</th>
      <th bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>Sediment<br>($rate)</th>
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
      <th bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>
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
   <h3>Probabilities of occurrence first year following disturbance<br>
       based on $simyears&nbsp;years of climate</h3>
    <table border=0 cellpadding=4 bgcolor=lightyellow>
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
    <input type=button value="Return to Input Screen" onClick="JavaScript:window.history.go(-1)">
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
       print "    <p><font color=red>Something seems to have gone awry!</font>\n";
       print '    <blockquote><pre><font size=1>
';
       open STERR, "<$sterFile";
         while (<STERR>){
           print;
         }
       close STERR;
       print '    </font></pre></blockquote><hr>
';

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
  <TITLE>Tahoe Basin Sediment Model Results</TITLE>
 </head>
 <body>
';
    print $rcin;
  } 

print '
  <center>
   <font size=-1>
    <table>
     <tr>
      <th colspan=5 bgcolor=lightgreen><font size=-1>WEPP input files</th>
      <th><font size=-1>output</th>
     </tr>
     <tr>
      <td><font size=-1>    [ <a href="javascript:void(showresponsefile())">response</a> </td>
      <td><font size=-1>    | <a href="javascript:void(showslopefile())">slope</a> </td>
      <td><font size=-1>    | <a href="javascript:void(showsoilfile())">soil</a> </td>
      <td><font size=-1>    | <a href="javascript:void(showvegfile())">vegetation</a> </td>
      <td><font size=-1>    | <a href="javascript:void(showcligenparfile())">weather</a> </td>
      <td><font size=-1>    ][ <a href="javascript:void(showextendedoutput())">annual detailed</a> ] </td>
     </tr>
    </table>
   </font>
  </center>
  <hr>
';

print "
    <font size=-2>
<font size=-2>
<b>Citation:</b><br>
Elliot, William J.; Hall, David E. 2010. Tahoe Basin Sediment Model. Ver. $version.
Moscow, ID: U.S. Department of Agriculture, Forest Service, Rocky Mountain Research Station.
Online at &lt;http://forest.moscowfsl.wsu.edu/fswepp&gt;.
<br><br>
     Tahoe Basin Sediment Model Results v.";
print '     <a href="javascript:popuphistory()">';
print "     $version</a> based on <b>WEPP $weppver</b>, CLIGEN $cligen_version<br>
     http://$wepphost/fswepp<br>";
&printdate;
print "
     <br>
     Tahoe Basin Sediment Model Run ID $unique
    </font>
   </blockquote>
 </body>
</html>
";

#  system "rm working/$unique.*";

   unlink <$working/$unique.*>;

   $host = $ENV{REMOTE_HOST};                    
   $host = $ENV{REMOTE_ADDR} if ($host eq '');
   $user_really=$ENV{'HTTP_X_FORWARDED_FOR'};		# DEH 11/14/2002
   $host = $user_really if ($user_really ne '');	# DEH 11/14/2002

# 2008.06.04 DEH start
   open PAR, "<$climatePar";
    $PARline=<PAR>;                 # station name
    $PARline=<PAR>;                 # Lat long
    $lat_long=substr($PARline,0,26);
    $lat=substr $lat_long,6,7;
    $long=substr $lat_long,19,7;
   close PAR;
# 2008.06.04 DEH end

#  record activity in Tahoe log (if running on remote server)

   if (lc($wepphost) ne "localhost") {
     open WTLOG, ">>../working/wt.log";
       flock (WTLOG,2);
#      $host = $ENV{REMOTE_HOST};
#      if ($host eq "") {$host = $ENV{REMOTE_ADDR} };
       print  WTLOG "$host\t\"";
       printf WTLOG "%0.2d:%0.2d ", $hour, $min;
       print  WTLOG $ampm[$ampmi],"  ",$days[$wday]," ",$months[$mon]," ",$mday, ", ",$thisyear, "\"\t";
       print  WTLOG $years2sim,"\t";
       print  WTLOG '"',trim($climate_name),"\"\t";
       print  WTLOG "$lat\t$long\n";                      # 2008.06.04 DEH
#       print  WTLOG $lat_long,"\n";                      # 2008.06.04 DEH
#      print  WTLOG $climate_name,"\n";
     close WTLOG;

     open CLIMLOG, '>../working/lastclimate.txt';       # 2005.07.14 DEH
       flock CLIMLOG,2;
       print CLIMLOG 'Tahoe: ', $climate_name;
     close CLIMLOG;

     $thisday = 1+ (localtime)[7];                      # $yday, day of the year (0..364)
#    $thisdayoff=$thisday+3;                            # [Jan 1] -1: Sunday; 0: Monday
     $thisdayoff=$thisday+4;                            # [Jan 1] -1: Sunday; 0: Monday
     $thisweek = 1+ int $thisdayoff/7;
     $ditlogfile = '>>../working/wt/' . $thisweek;      # modify this
     open MYLOG,$ditlogfile;
       flock MYLOG,2;                  # 2005.02.09 DEH
       print MYLOG '.';
     close MYLOG;
   }

# #####
#    record run to user IP run log

     if ($platform eq 'pc') {
       $runlogFile = "$working\\run.log";
     }
     else {
#       $Iam = $ENV{REMOTE_ADDR};
#       $Iam_really=$ENV{'HTTP_X_FORWARDED_FOR'};      	# DEH 11/14/2002
#       $Iam=$Iam_really if ($Iam_really ne '');  	# DEH 11/14/2002
#       $Iam =~ tr/./_/;
#       $Iam = $Iam . $me . '_';			# DEH 03/05/2001
#       $runlogFile = "$working/$Iam" . 'run.log';
       $user_ID=$ENV{'REMOTE_ADDR'};
       $user_really=$ENV{'HTTP_X_FORWARDED_FOR'};       # DEH 11/14/2003
       $user_ID=$user_really if ($user_really ne '');   # DEH 11/14/2003
       $user_ID =~ tr/./_/;
       $user_ID = $user_ID . $me;
       $runLogFile = "../working/" . $user_ID . ".run.log";
     }
## open runLogFile for append // print // close #

# print "Run log: $runLogFile\n";
  ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
  my @abbr = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
  $year += 1900;
  $actual_climate_name =~ s/^\s+//;	# http://perldoc.perl.org/perlfaq4.html#How-do-I-strip-blank-space-from-the-beginning/end-of-a-string?
  $actual_climate_name =~ s/\s+$//;

      open RUNLOG, ">>$runLogFile";
      flock (RUNLOG,2);
       print RUNLOG "wt\t";
       print RUNLOG "$unique\t";
       print RUNLOG "\"$abbr[$mon] $mday, $year\"\t";
       print RUNLOG "\"$actual_climate_name\"\t";
       print RUNLOG "$soil\t";
       print RUNLOG "$treat1\t";
       print RUNLOG "$ofe1_top_slope\t";
       print RUNLOG "$ofe1_mid_slope\t";
       print RUNLOG "$user_ofe1_length\t";
       print RUNLOG "$ofe1_pcover\t";
       print RUNLOG "$ofe1_rock\t";
       print RUNLOG "$treat2\t";
       print RUNLOG "$ofe2_mid_slope\t";
       print RUNLOG "$ofe2_bot_slope\t";
       print RUNLOG "$user_ofe2_length\t";
       print RUNLOG "$ofe2_pcover\t";
       print RUNLOG "$ofe2_rock\t";
       print RUNLOG "$units\t";
       print RUNLOG "\"$description\"\n";
      close RUNLOG;
# #####

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

sub CreateSlopeFile {

# create slope file from specified geometry

   $top_slope1 = $ofe1_top_slope / 100;
   $mid_slope1 = $ofe1_mid_slope / 100;
   $mid_slope2 = $ofe2_mid_slope / 100;
   $bot_slope2 = $ofe2_bot_slope / 100;
   $avg_slope = ($mid_slope1 + $mid_slope2) / 2;
   $ofe_width=100 if $ofe_area == 0;
   open (SlopeFile, ">".$slopeFile);

     print SlopeFile "97.3\n";           # datver
     print SlopeFile "#\n# Slope file generated for Tahoe\n#\n";
     print SlopeFile "2\n";              # no. OFE
     print SlopeFile "100 $ofe_width\n";        # aspect; representative profile width
                                         # OFE 1 (upper)
     printf SlopeFile "%d  %.2f\n",   3  ,$ofe1_length;   # no. points, length
     printf SlopeFile "%.2f, %.2f  ", 0  ,$top_slope1;    # dx, gradient
     printf SlopeFile "%.2f, %.2f  ", 0.5,$mid_slope1;    # dx, gradient
     printf SlopeFile "%.2f, %.2f\n", 1  ,$avg_slope;     # dx, gradient
                                   # OFE 2 (lower)
     printf SlopeFile "%d  %.2f\n",   3,   $ofe2_length;  # no. points, length
     printf SlopeFile "%.2f, %.2f  ", 0,   $avg_slope;    # dx, gradient
     printf SlopeFile "%.2f, %.2f  ", 0.5, $mid_slope2;   # dx, gradient
     printf SlopeFile "%.2f, %.2f\n", 1,   $bot_slope2;   # dx, gradient

   close SlopeFile;
   return $slopeFile;
 }

# ###########################    CreateSoilFile    #########################

sub CreateSoilFile {		# 2010.05.27

#  read: $treat1, $treat2, $soil $ofe1_rock, $ofe2_rock
#  reads: soilbase.tahoe

#  $soil = 'alluvial';
#  $treat1 = $ofe1;   # 'short'
#  $treat2 = $ofe2;   # 'tree5'
#  local   $fcover1 = $ofe1_pcover/100;
#  local   $fcover2 = $ofe2_pcover/100;

local $i, $in;
local $soil1 = $soil;
local $soil2 = $soil;
   $soil2 = 'alluvial' if ($soil1 eq 'rockpave');

# make outer_offset hash	2009.08.28 DEH

local   $outer_offset = {};
   $outer_offset{granitic} = 6;
   $outer_offset{volcanic} = 36;
   $outer_offset{alluvial} = 66;
   $outer_offset{rockpave} = 96;

# make inner_offset hash        2009.08.28 DEH

local   $inner_offset = {};
   $inner_offset{Skid} = 0;
   $inner_offset{HighFire} = 2;
   $inner_offset{LowFire} = 4;
   $inner_offset{Sod} = 6;
   $inner_offset{Bunchgrass} = 8;
   $inner_offset{Shrub} = 10;
   $inner_offset{YoungForest} = 12;
   $inner_offset{OldForest} = 14;
   $inner_offset{Bare} = 16;
   $inner_offset{Mulch} = 18;
   $inner_offset{Till} = 20;
   $inner_offset{LowRoad} = 22;
   $inner_offset{HighRoad} = 24;

local   $line_number1 = $outer_offset{$soil1} + $inner_offset{$treat1};
local   $line_number2 = $outer_offset{$soil2} + $inner_offset{$treat2};

   open SOLFILE, ">$soilFile";

   print SOLFILE 
"97.3
#
#      Created by 'wt.pl' (v $version)
#      Numbers by: Bill Elliot (USFS)
#
Soil file for Tahoe Basin Sediment Model run from soilbase.tahoe for $treat1 $soil1 $treat2 $soil2
 2    1
";

   open SOILDB, "<olddata/soilbase.tahoe";
   for $i (1..$line_number1) {
     $in = <SOILDB>;
   }
   chomp $in;
   print SOLFILE $in,"\n";

   $in = <SOILDB>;
local $index_rfg = index($in,'rfg');
local $left = substr($in,0,$index_rfg);
local $right = substr ($in, $index_rfg+3);
   $in = $left . $ofe1_rock . $right;

   print SOLFILE $in;
   close SOILDB;

   open SOILDB, "<olddata/soilbase.tahoe";
   for $i (1..$line_number2) {
     $in = <SOILDB>;
   }
   chomp $in;
   print SOLFILE $in,"\n";
   $in = <SOILDB>;
$index_rfg = index($in,'rfg');
$left = substr($in,0,$index_rfg);
$right = substr ($in, $index_rfg+3);
$in = $left . $ofe2_rock . $right;

   print SOLFILE $in;
   close SOILDB;
   close SOLFILE;
}

sub CreateResponseFile {

   open (ResponseFile, ">" . $responseFile);
#     print ResponseFile "98.4\n";        # datver
     print ResponseFile "m\n";        # 'metric'
     print ResponseFile "y\n";           # not watershed
     print ResponseFile "1\n";           # 1 = continuous
     print ResponseFile "1\n";           # 1 = hillslope
     print ResponseFile "n\n";           # hillsplope pass file out?
     if (lc($action) =~ /vegetation/) {
       print ResponseFile "1\n";           # 1 = annual; abbreviated
     }
     else {
       print ResponseFile "2\n";           # 2 = annual; detailed
     }
     print ResponseFile "n\n";           # initial conditions file?
     print ResponseFile $outputFile,"\n";  # soil loss output file
     print ResponseFile "n\n";           # water balance output?
     if (lc($action) =~ /vegetation/) {
       print ResponseFile "y\n";           # crop output?
       print ResponseFile $cropFile,"\n";  # crop output file name
     }
     else {
       print ResponseFile "n\n";           # crop output?
     }
     print ResponseFile "n\n";           # soil output?
     print ResponseFile "n\n";           # distance/sed loss output?
     print ResponseFile "n\n";           # large graphics output?
     print ResponseFile "n\n";           # event-by-event out?
     print ResponseFile "n\n";           # element output?
     print ResponseFile "n\n";           # final summary out?
     print ResponseFile "n\n";           # daily winter out?
     print ResponseFile "n\n";           # plant yield out?
     print ResponseFile "$manFile\n";      # management file name
     print ResponseFile "$slopeFile\n";          # slope file name
     print ResponseFile "$climateFile\n";        # climate file name
     print ResponseFile "$soilFile\n";           # soil file name
     print ResponseFile "0\n";           # 0 = no irrigation
     print ResponseFile "$years2sim\n";         # no. years to simulate
     print ResponseFile "0\n";           # 0 = route all events

   close ResponseFile;
   return $responseFile;
}

sub checkInput {

   $rc = '';
   if ($CL eq "") {$rc .= "No climate selected<br>\n"}
   if ($soil ne "granitic" && $soil ne "volcanic" && $soil ne "alluvial" && $soil ne "rockpave")
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

   $climatePar = "$CL" . '.par';
   $station = substr($CL, length($CL)-8);
   $user_ID = 'getalife';
   $outfile = $climateFile;

   $climateFile = "$working\\$station.cli";
   $outfile = $climateFile;
   $rspfile = "$working\\" . $user_ID . ".rsp";
   $stoutfile = "$working\\" . $user_ID . ".out";

# end of stuff what was working

# swupped from wr.pl which works on WHITEPINE -- still works on PC

    $climatePar = "$CL" . '.par';
#   $user_ID = 'getalife';
    if ($platform eq 'pc') {
      $station = substr($CL, length($CL)-8);
      $climateFile = "$working\\$station.cli";
      $outfile = $climateFile;
      $rspfile = "$working\\cligen.rsp";
      $stoutfile = "$working\\cligen.out";
    } else {
#     $user_ID = '';
#     $climateFile = '..\\working' . "$station.cli";
      $climateFile = "../working/$unique.cli";
      $outfile = $climateFile;
#     $rspfile = "../working/$user_ID.rsp";
#     $stoutfile = "../working/$user_ID.out";
      $rspfile = "../working/c$unique.rsp";
      $stoutfile = "../working/c$unique.out";
    }

# end swup

   if ($debug) {print "[CreateCligenFile]<br>
Arguments:    $args<br>
ClimatePar:   $climatePar<br>
ClimateFile:  $climateFile<br>
OutputFile:   $outfile<br>
ResponseFile: $rspfile<br>
StandardOut:  $stoutfile<br>
";}

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

   unlink $rspfile;     #  "../working/c$unique.rsp"
   unlink $stoutfile;   #  "../working/c$unique.out"

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

sub readPARfile {	# ($PARfile)

#   $PARfile= 'working/166_2_22_167_o.par';

   local @file=@_;
#   $units = 'ft';

   local $line, @mean_p_if, $mean_p_base, @pww, $pww_base, @pwd, $pwd_base, @tmax_av, $tmax_av_base;
   local @latlong, @elevs, $lat, $long, $elev, $nwetunits, $elevunits;
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

# print "climate file: @file\n";

   open PAR, "<@file";
    $line=<PAR>;                 # station name
# print $line;

################

     $line=<PAR>;                 # Lat long
#      @latlong = split '=',$line; $lat=substr($latlong[1],0,7); @longs=split ' ',$latlong[2]; $long=$longs[1];
       @latlong = split '=',$line; $lat=substr($latlong[1],0,7); $long=substr($latlong[2],0,7);
# print "$latlong[0]<br>$latlong[1]<br>$latlong[2]<br>\n";
     $line=<PAR>;                 # Elev
       @elevs = split '=',$line; $elev = substr($elevs[1],0,7);
# print "$elevs[0]<br>$elevs[1]<br>$elevs[2]<br>\n";
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

   $nwetunits = 'days';
   if ($units eq 'm') {
     $tempunits = 'deg C';
     $prcpunits = 'mm';
     $elevunits = 'm';
   }
   else {
     $tempunits = 'deg F';
     $prcpunits = 'in';
     $elevunits = 'ft';
     $elev = sprintf '%.1f',$elev*3.28;
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
#     $, = ' ';
#       print $modfrom,"<br>";
#       print 'T MAX ',@tmax,$tempunits,"<br>\n";
#       print 'T MIN ',@tmin,$tempunits,"<br>\n";
#       print 'MEANP ',@mean_p,$prcpunits,"<br>\n";
#       print '# WET ',@num_wet,"days<br>\n";
#       print "Latitude $lat Longitude $long Elevation $elev $elevunits<br>\n";
#     $, = '';
     @ret[0] = $modfrom."<br>\n";
     @ret[1] = 'T MAX ' . join (' ',@tmax)    . " $tempunits<br>\n";
     @ret[2] = 'T MIN ' . join (' ',@tmin)    . " $tempunits<br>\n";
     @ret[3] = 'MEANP ' . join (' ',@mean_p)  . " $prcpunits<br>\n";
     @ret[4] = '# WET ' . join (' ',@num_wet) . " $nwetunits<br>\n";
     @ret[5] = "Latitude " . $lat . " Longitude " . $long . " Elevation " . $elev . " $elevunits<br>";
     return @ret;
   }
}

sub trim($)       # http://www.somacon.com/p114.php
{
        my $string = shift;
        $string =~ s/^\s+//;
        $string =~ s/\s+$//;
        return $string;
}

sub CreateManagementFileT {

# new TAHOE management files

#     $climatePar = $CL . '.par';
#     &getAnnualPrecipT ($climatePar);                  # open .par file and calculate annual precipitation
#     if ($debug) {print "Annual Precip: $ap_annual_precip mm<br>\n"}

#  $treat1 = "skid";   $treat2 = "tree5";

   open MANFILE, ">$manFile";

   print MANFILE "98.4
#
#\tCreated for Tahoe by wt.pl (v. $version)
#\tNumbers by: Bill Elliot (USFS) et alia
#

2\t# number of OFEs
$years2sim\t# (total) years in simulation

#################
# Plant Section #
#################

2\t# looper; number of Plant scenarios data/$treat1.plt data/$treat2.plt

";

   open PS1, "<olddata/$treat1.plt";      # WEPP plant scenario
#  read 14 lines (base 0); line 9 entry 2 will change (biomass) as f(climate)

#  $beinp is biomass energy ratio (real ~ 0 to 1000): plant scenario 7.3 (p. 33)
#  the following equation relates biomass ratio to cover (whole) percent and precipitation in mm
#  from work December 1999 by W.J. Elliot unpublished.

#   ($ofe1_pcover > 100) ? $pcover = 100 : $pcover = $ofe1_pcover;
   $pcover = $ofe1_pcover;      # decided not to limit input cover to 100%; use whatever is entered (for now)
#   $precip_cap = 450;           # max precip in mm to put into biomass equation (curve flattens out)
#   ($ap_annual_precip < $precip_cap) ? $capped_precip = $ap_annual_precip : $capped_precip = $precip_cap;
#   $beinp = sprintf "%.1f", 8.17 * exp(0.031 * $pcover - 0.0023 * $capped_precip);

   while (<PS1>) {
#    if (/beinp/) {                              # read file search for token to replace with value
#       $index_beinp = index($_,'beinp');                # where does token start?
#       $wps_left = substr($_,0,$index_beinp);           # grab stuff to left of token
#       $wps_right = substr($_,$index_beinp+5);          # grab stuff to right of token end
#       $_ = $wps_left . $beinp . $wps_right;            # stuff value inbetween the two ends
#       if ($debug) {print "<b>wps1:</b><br>
#                           pcover: $pcover<br>
#                           beinp: $beinp<br><pre> $_<br>\n"}
#    }
    print MANFILE $_;                           # print line to management file
   }
   close PS1;

   open PS2, "<olddata/$treat2.plt";
#  read 14 lines (base 0); line 9 entry 2 will change (biomass) as f(climate)

#   ($ofe2_pcover > 100)? $pcover = 100 : $pcover = $ofe2_pcover;
   $pcover = $ofe2_pcover;
#   ($ap_annual_precip < $precip_cap) ? $capped_precip = $ap_annual_precip : $capped_precip = $precip_cap;
#   $beinp = sprintf "%.1f", 8.17 * exp(0.031 * $pcover - 0.0023 * $capped_precip);;

   print MANFILE "\n";

   while (<PS2>) {
#    if (/beinp/) {
#       $index_beinp = index($_,'beinp');
#       $wps_left = substr($_,0,$index_beinp);
#       $wps_right = substr($_,$index_beinp+5);
#       $_ = $wps_left . $beinp . $wps_right;
#       if ($debug) {print "</pre><b>wps2:</b><br>
#                           pcover: $pcover<br>
#                           beinp: $beinp<br><pre> $_<br>\n"}
#    }
    print MANFILE $_;
   }
   close PS2;

   print MANFILE "
#####################
# Operation Section #
#####################

2\t# looper; number of Operation scenarios data/$treat1.op data/$treat2.op

";

   open OP, "<olddata/$treat1.op";      # Operations
   while (<OP>) {
#    if (/itype/) {substr ($_,0,1) = "1"}
     print MANFILE $_;
   }
   close OP;

   print MANFILE "\n";

   open OP, "<olddata/$treat2.op";
   while (<OP>) {
#    if (/itype/) {substr ($_,0,1) = "2"}
     print MANFILE $_;
   }
   close OP;

   print MANFILE "
##############################
# Initial Conditions Section #
##############################

2\t# looper; number of Initial Conditions scenarios data/$treat1.ini data/$treat2.ini

";

#  $inrcov is initial interrill cover (real 0-1): initial conditions 6.6 (p. 37)
#  $rilcov is initial rill cover (real 0-1): initial conditions 9.3 (p. 37)
#  December 1999 by W.J. Elliot unpublished.

   ($ofe1_pcover > 100)? $pcover = 100 : $pcover = $ofe1_pcover;
   $inrcov = sprintf "%.2f", $pcover/100;
   $rilcov = $inrcov;

   open IC, "<olddata/$treat1.ini";        # Initial Conditions Scenario file
#  read 14 lines (base 0); change line 8 values 1 and 5; line 11 value 2

   while (<IC>) {
#    if (/iresd/) {substr ($_,0,1) = "1"}
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

   print MANFILE "\n";

   ($ofe2_pcover > 100)? $pcover = 100 : $pcover = $ofe2_pcover;
   $inrcov = sprintf "%.2f", $pcover/100;
   $rilcov = $inrcov;

   open IC, "<olddata/$treat2.ini";
#  read 14 lines (base 0); change line 8 values 1 and 5; line 11 value 2
   while (<IC>) {
#    if (/iresd/) {substr ($_,0,1) = "2"}
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

   print MANFILE "
###########################
# Surface Effects Section #
###########################

2\t# Number of Surface Effects Scenarios

#
#   Surface Effects Scenario 1 of 2
#
Year 1
From WEPP database
USFS RMRS Moscow

1\t# landuse  - cropland
1\t# ntill - number of operations
  2\t# mdate  --- 1 / 2 
  1\t# op --- Tah_****
      0.010\t# depth
      2\t# type

#
#   Surface Effects Scenario 2 of 2
#
Year 2
From WEPP database
USFS RMRS Moscow

1\t# landuse  - cropland
1\t# ntill - number of operations
  2\t# mdate  --- 1 / 2 
  2\t# op --- Tah_****
      0.010\t# depth
      2\t# type

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

2\t# looper; number of Yearly Scenarios

#
# Yearly scenario 1 of 2
#
Year 1 



1\t# landuse <cropland>
1\t# plant growth scenario
1\t# surface effect scenario
0\t# contour scenario
0\t# drainage scenario
2\t# management <perennial>
   250\t# senescence date 
   0\t# perennial plant date --- 0 /0
   0\t# perennial stop growth date --- 0/0
   0.0000\t# row width
   3\t# neither cut or grazed

#
# Yearly scenario 2 of 2
#
Year 2 



1\t# landuse <cropland>
2\t# plant growth scenario
2\t# surface effect scenario
0\t# contour scenario
0\t# drainage scenario
2\t# management <perennial>
   250\t# senescence date 
   0\t# perennial plant date --- 0 /0
   0\t# perennial stop growth date --- 0/0
   0.0000\t# row width
   3\t# neither cut or grazed
";
   print MANFILE "
######################
# Management Section #
######################
Tahoe Basin Sediment Model
Two OFEs for forest conditions
W. Elliot 02/99

2\t# `nofe' - <number of Overland Flow Elements>
\t1\t# `Initial Conditions indx' - <$treat1>
\t2\t# `Initial Conditions indx' - <$treat2>
$years2sim\t# `nrots' - <rotation repeats..>
1\t# `nyears' - <years in rotation>
";

   for $i (1..$years2sim) {
     print MANFILE "
#
#       Rotation $i : year $i to $i
#
\t1\t# `nycrop' - <plants/yr; Year of Rotation :  $i - OFE : 1>
\t\t1\t# `YEAR indx' - <$treat1>

\t1\t# `nycrop' - <plants/yr; Year of Rotation :  $i - OFE : 2>
\t\t2\t# `YEAR indx' - <$treat2>
";
   }
   close MANFILE;
}

sub make_history_popup {

  my $version;

# Reads parent (perl) file and looks for a history block:
## BEGIN HISTORY ####################################################
# ERMiT Version History

  $version='2005.02.08';        # Make self-creating history popup page
# $version = '2005.02.07';      # Fix parameter passing to tail_html; stuff after semicolon lost
#!$version = '2005.02.07';      # Bang in line says do not use
# $version = '2005.02.04';      # Clean up HTML formatting, add head_html and tail_html functions
#                               # Continuation line not handled
# $version = '2005.01.08';      # Initial beta release

## END HISTORY ######################################################

# and returns body (including Javascript document.writeln instructions) for a pop-up history window
# called pophistory.

# First line after 'BEGIN HISTORY' is <title> text
# Splits version and comment on semi-colon
# Version must be version= then digits and periods
# Bang in line causes line to be ignored
# Disallowed: single and double quotes in comment part
# Not handled: continuation lines

# Usage:

#print "<html>
# <head>
#  <title>$title</title>
#   <script language=\"javascript\">
#    <!-- hide from old browsers...
#
#  function popuphistory() {
#    pophistory = window.open('','pophistory','')
#";
#    print make_history_popup();
#print "
#    pophistory.document.close()
#    pophistory.focus()
#  }
#";

# print $0,"\n";

  my ($line, $z, $vers, $comment);

  open MYSELF, "<$0";
    while (<MYSELF>) {

      next if (/!/);

      if (/## BEGIN HISTORY/) {
        $line = <MYSELF>;
        chomp $line;
        $line = substr($line,2);
        $z = "    pophistory.document.writeln('<html>')
    pophistory.document.writeln(' <head>')
    pophistory.document.writeln('  <title>$line</title>')
    pophistory.document.writeln(' </head>')
    pophistory.document.writeln(' <body bgcolor=white>')
    pophistory.document.writeln('  <font face=\"trebuchet, tahoma, arial, helvetica, sans serif\">')
    pophistory.document.writeln('  <center>')
    pophistory.document.writeln('   <h4>$line</h4>')
    pophistory.document.writeln('   <p>')
    pophistory.document.writeln('   <table border=0 cellpadding=10>')
    pophistory.document.writeln('    <tr>')
    pophistory.document.writeln('     <th bgcolor=lightblue>Version</th>')
    pophistory.document.writeln('     <th bgcolor=lightblue>Comments</th>')
    pophistory.document.writeln('    </tr>')
";
      } # if (/## BEGIN HISTORY/)

      if (/version/) {
        ($vers, $comment) = split (/;/,$_);
        $comment =~ s/#//;
        chomp $comment;
        $vers =~ s/'//g;
        $vers =~ s/ //g;
        $vers =~ s/"//g;
        if ($vers =~ /version=*([0-9.]+)/) {    # pull substring out of a line
          $z .= "    pophistory.document.writeln('    <tr>')
    pophistory.document.writeln('     <th valign=top bgcolor=lightblue>$1</th>')
    pophistory.document.writeln('     <td>$comment</td>')
    pophistory.document.writeln('    </tr>')
";
        }       # (/version *([0-9]+)/)
     }  # if (/version/)

    if (/## END HISTORY/) {
        $z .= "    pophistory.document.writeln('   </table>')
    pophistory.document.writeln('   </font>')
    pophistory.document.writeln('  </center>')
    pophistory.document.writeln(' </body>')
    pophistory.document.writeln('</html>')
";
      last;
    }     # if (/## END HISTORY/)
  }     # while
  close MYSELF;
  return $z;
}

# ------------------------ end of subroutines ----------------------------
