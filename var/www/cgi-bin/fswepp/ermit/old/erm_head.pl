#! /usr/bin/perl
#
# erm.pl
#
# ermit workhorse
# Reads user input from ermit.pl, runs WEPP, parses output files
# top adapted from wd.pl 8/28/2002

# 28 August 2002
# David Hall, USDA Forest Service, Rocky Mountain Research Station
# William J. Elliot, USDA Forest Service, Rocky Mountain Research Station

#  $debug=1;
   $version = "2002.08.28";
   $rfg = 20;

#=========================================================================

   &ReadParse(*parameters);

   $CL=$parameters{'Climate'};         # get Climate (file name base)
   $climate_name=$parameters{'climate_name'};   # requested climate #
   $SoilType=$parameters{'SoilType'};
   $soiltexture=$parameters{'SoilType'};
#  $soil_name=$parameters{'soil_name'};
   $me=$parameters{'me'};
   $units=$parameters{'units'};
   $vegtype=$parameters{'vegetation'};
   $avg_slope=$parameters{'avg_slope'};
   $toe_slope=$parameters{'toe_slope'};
   $hillslope_length=$parameters{'length'};
   $severityclass=$parameters{'severity'};
   $achtung=$parameters{'achtung'};

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
     $comefrom = "http://" . $wepphost . "/cgi-bin/fswepp/ermit/ermit.pl";
     if ($platform eq "pc") {
       exec "perl ../rc/rockclim.pl -server -i$me -u$units $comefrom"
     }
     else {
       exec "../rc/rockclim.pl -server -i$me -u$units $comefrom"
     }
     die
   }            # /custom/

   if (lc($achtung) =~ /describe climate/) {
     $comefrom = "http://" . $wepphost . "/cgi-bin/fswepp/ermit/ermit.pl";
     if ($platform eq "pc") {
       exec "perl ../rc/descpar.pl $CL $comefrom"
     }
     else {
       exec "../rc/descpar.pl $CL $comefrom"
     }
     die
   }            # /describe climate/

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
     if (substr ($surface,0,1) eq "g") {$surf = "g"}
     $soilFile = '3' . $surf . $SoilType . $conduct . '.sol';

     $comefrom = "http://" . $wepphost . "/cgi-bin/fswepp/ermit/ermit.pl";
     $soilFilefq = $soilPath . $soilFile;
     print "Content-type: text/html\n\n";
     print "<HTML>\n";
     print "<HEAD>\n";
     print "<TITLE>ERMiT -- Soil Parameters</TITLE>\n";
     print "</HEAD>\n";
     print '<BODY background="http://',$wepphost,
          '/fswepp/images/note.gif" link="#ff0000">
  <font face="Arial, Geneva, Helvetica">
  <blockquote>
  <table width=95% border=0>
    <tr><td>
       <a href="JavaScript:window.history.go(-1)">
       <IMG src="http://',$wepphost,'/fswepp/images/disturb.gif"
       align="left" alt="Back to FS WEPP menu" border=1></a>
    <td align=center>
       <hr>
       <h2>ERMiT Soil Texture Properties</h2>
       <hr>
    <td>
       <A HREF="http://',$wepphost,'/fswepp/docs/ermitdoc.html">
       <IMG src="http://',$wepphost,'/fswepp/images/epage.gif"
        align="right" alt="Read the documentation" border=0></a>
    </table>
';
     if ($debug) {print
"Action: '$action'<br>\nAchtung: '$achtung'<br>\n"}

     if ($SoilType eq 'clay') {
#       if ($surf eq 'g') {print 'Graveled '}
       print "clay loam (MH, CH)<br>\n";
       print "Shales and similar decomposing fine-grained sedimentary rock<br>\n
";
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
     $soilFile     = "$working/$unique" . '.sol';
     $soilPath     = 'data/';
   }
#
     &CreateSoilFile;
     print "<hr><b><pre>\n\n";
     open SOIL, "<$soilFile";
     $weppver = <SOIL>;
     $comment = <SOIL>;
     while (substr($comment,0,1) eq "#") {
       chomp $comment;
       print $comment,"\n";
       $comment = <SOIL>;
     }

     print "</pre></b>
<center>
<table border=1>
";

#      $solcom = $comment;

     $record = <SOIL>;
     @vals = split " ", $record;
     $ntemp = @vals[0];      # no. flow elements or channels
     $ksflag = @vals[1];     # 0: hold hydraulic conductivity constant
                             # 1: use internal adjustments to hydr con
     for $i (1..$ntemp) {
       print '<tr><th colspan=3 bgcolor="85d2d2">',"\n";
       print "Element $i --- \n";
       $record = <SOIL>;
       @descriptors = split "'", $record;
       print "@descriptors[1]   ";                # slid: Road, Fill, Forest
       print "texture: @descriptors[3]\n";        # texid: soil texture
       ($nsl,$salb,$sat,$ki,$kr,$shcrit,$avke) = split " ", @descriptors[4];
#      @vals = split " ", @descriptors[4];
#      print "No. soil layers: $nsl\n";
       print "<tr><th align=left>Albedo of the bare dry surface soil<td>$salb<td>\n";
       print "<tr><th align=left>Initial saturation level of the soil profile porosity<td>$sat<td>m m<sup>-1</sup>\n";
       print "<tr><th align=left>Baseline interrill erodibility parameter (<i>k<sub>i</sub></i> )<td>$ki<td>kg s m<sup>-4</sup>\n";
       print "<tr><th align=left>Baseline rill erodibility parameter (<i>k<sub>r</sub></i> )<td>$kr<td>s m<sup>-1</sup>\n";
       print "<tr><th align=left>Baseline critical shear parameter<td>$shcrit<td>N m<sup>-2</sup>\n";
       print "<tr><th align=left>Effective hydraulic conductivity of surface soil<td>$avke<td>mm h<sup>-1</sup>\n";
       for $layer (1..$nsl) {
         $record = <SOIL>;
         ($solthk,$sand,$clay,$orgmat,$cec,$rfg) = split " ", $record;
         print "<tr><td><br><th colspan=2 bgcolor=85d2d2>layer $layer\n";
         print "<tr><th align=left>Depth from soil surface to bottom of soil layer<td>$solthk<td>mm\n";
         print "<tr><th align=left>Percentage of sand<td>$sand<td>%\n";
         print "<tr><th align=left>Percentage of clay<td>$clay<td>%\n";
         print "<tr><th align=left>Percentage of organic matter (by volume)<td>$orgmat<td>%\n";
         print "<tr><th align=left>Cation exchange capacity<td>$cec<td>meq per 100 g of soil\n";
         print "<tr><th align=left>Percentage of rock fragments (by volume)<td>$rfg<td>%\n";
       }
     }
     close SOIL;
     print '</table><p><hr><p>
<!-- <form method="post" action="wepproad.sol">
  <input type="submit" value="DOWNLOAD">
  <input type="hidden" value="',$soilFile,'" name="filename">
</form>
</center>
<p><hr> -->
<p>
</blockquote>
</body>
</html>
';
     die
   }            #  /describe soil/

# *******************************

    $years2sim=100;

# ########### RUN WEPP for 100-year simulation ########### ###########

# open TEMP...

#   $unique='wepp-' . $$;
   if ($debug) {print TEMP 'Unique? filename= ',$unique,"\n<BR>"}

   if ($platform eq "pc") {
#     if (-e 'd:/fswepp/working') {$working = 'd:\\fswepp\\working'}
#     elsif (-e 'c:/fswepp/working') {$working = 'c:\\fswepp\\working'}
#     else {$working = '..\\working'}

     $responseFile = "$working\\wermit.in";
     $outputFile   = "$working\\wermit.out";
     $stoutFile    = "$working\\wermit.sto";
     $sterFile     = "$working\\wermit.err";
     $climateFile  = "$working\\$CL" . '.cli';
     $eventFile    = "$working\\wevent.out";
     $tempFile     =  $working . '\\tempstuff';

     $data = 'data\\';
     $working = 'working\\';
   }
   else {
     $working = '../working';
###    $unique='wepp' . time . '-' . $$;
     $unique='wepp-' . $$;
     $workingpath = "$working/$unique";
     $responseFile = $workingpath . '.in';
     $outputFile   = $workingpath . '.out';
     $stoutFile    = $workingpath . '.stout';
     $sterFile     = $workingpath . '.sterr';
     $soilFile     = $workingpath . '.sol';
     $slopeFile    = $workingpath . '.slp';
#    $climateFile  = "$working/$CL" . '.cli';
     $climateFile  = $CL . '.cli';
     $manFile      = $workingpath . '.man';
     $eventFile    = $workingpath . '.event';
     $tempFile     = $workingpath . '.temp';
   }

  $evo_file = $eventFile;

#   $host = $ENV{REMOTE_HOST};

#   $rcin = &checkInput;
#   if ($rcin >= 0) {

#   $unique = 'qq';

#  $SlopeFileName = 'sloop.slp';
#  $SlopeFilePath = $working . $unique . $SlopeFileName;

  $s = 'hhh';

# $gradient_ave - average surface slope gradient
# $gradient_toe - surface slope toe gradient
# $length

   $gradient_ave = $ave_slope + 0;
   $gradient_toe = $toe_slope + 0;
   $length = $hillslope_length + 0;
   if ($units eq 'ft') {$length *= 0.3048}

     print "Content-type: text/html\n\n";
     print "<HTML>\n";
     print "<HEAD>\n";
     print "<TITLE>ERMiT -- Input Parameters</TITLE>\n";
     print "</HEAD>\n";
     print '<BODY background="http://',$wepphost,
          '/fswepp/images/note.gif" link="#ff0000">
  <font face="Arial, Geneva, Helvetica">
  <blockquote>
   <pre>';
    print "
    I am $me
    units = $units
    climate file = $CL
    climate_name = $climate_name
    soil type = $soiltexture
    vegtype = $vegtype
    avg_slope = $avg_slope
    toe_slope = $toe_slope
    hillslope_length = $hillslope_length $units
    severityclass = $severityclass
    achtung = $achtung 

    gradient_ave = $gradient_ave
    gradient_toe = $gradient_toe
    length = $length m

    Create 100-year slope file       $slopeFile
           100-year management file  $manFile
    Create 100-year climate file     $climateFile
    Create 100-year soil file        $soilFile
    Create WEPP Response File        $responseFile
           temporary file            $tempFile
";
     if ($platform eq "pc") {
       @args = (".\\wepp <$responseFile >$stoutFile");
     }
     else {
       @args = ("../wepp <$responseFile >$stoutFile 2>$sterFile");
     }
     print "@args

    </pre>
   </blockquote>
";

#     open TEMP, ">$tempFile";


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
     $in[$i] =~ s/\+/ /g;         # Convert pluses to spaces
     ($key, $val) = split(/=/,$in[$i],2);         # Split into key and value
     $key =~ s/%(..)/pack("c",hex($1))/ge;        # Convert %XX from hex number$
     $val =~ s/%(..)/pack("c",hex($1))/ge;
     $in{$key} .= "\0" if (defined($in{$key}));  # \0 is the multiple separator
     $in{$key} .= $val;
   }
   return 1;
}
