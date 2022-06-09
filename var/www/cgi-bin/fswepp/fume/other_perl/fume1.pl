#! /fsapps/fssys/bin/perl

#!C:\Perl\bin\perl.exe T-w
#use strict;
use CGI ':standard';
require 'wrdt.pl';  

#  fume1.pl -- FUME workhorse
#  Modified by DEH from wd1.pl by Elena V. 2004.04.10

# Reads user input from weppdiro.pl, runs WEPP, parses output files

# David Hall, USDA Forest Service, Rocky Mountain Research Station

#  $debug=1;

   $version = "2003.11.24";
   print "Content-type: text/html\n\n";  #elena
#=========================================================================
   my @out_asypa;

   &ReadParse(*parameters);

   $CL=$parameters{'Climate'};         # get Climate (file name base)
#  $climate_name=$parameters{'climate_name'};   # requested climate #
   $soil=$parameters{'SoilType'};
#  $soil_name=$parameters{'soil_name'};
#elena   $treat1=$parameters{'UpSlopeType'};
   $treat1=tree20;
#   print "<p> the value for treat1 is $treat1 "; #elena 
   $ofe1_length=$parameters{'ofe1_length'}+0;
   $user_ofe1_length=$ofe1_length;#elena
#    print "<p> the value for ofe1_length is $ofe1_length "; #elena 
#elena   $ofe1_top_slope=$parameters{'ofe1_top_slope'}+0;
   $ofe1_top_slope=0; #elena
   $ofe1_mid_slope=$parameters{'ofe1_mid_slope'}+0;
#elena   $ofe1_pcover=$parameters{'ofe1_pcover'}+0;
   $ofe1_pcover=100; #elena
#elena   $ofe1_rock=$parameters{'ofe1_rock'}+0;
   $ofe1_rock=20; #elena
#elena   $treat2=$parameters{'LowSlopeType'};
   $treat2=tree20; #elena
   $ofe2_length=$parameters{'ofe2_length'}+0;
   $user_ofe2_length=$ofe2_length;#elena
#elena   $ofe2_mid_slope=$parameters{'ofe2_top_slope'}+0;
   $ofe2_mid_slope=$parameters{'ofe1_mid_slope'}+0; #elena
#elena   $ofe2_bot_slope=$parameters{'ofe2_bot_slope'}+0;
   $ofe2_bot_slope=$parameters{'ofe1_mid_slope'}/2; #elena
#elena   $ofe2_pcover=$parameters{'ofe2_pcover'}+0;
   $ofe2_pcover=100; #elena
#elena   $ofe2_rock=$parameters{'ofe2_rock'}+0;
   $ofe2_rock=20; #elena
   $ofe_area=$parameters{'ofe_area'}+0;
#  $outputs=$parameters{'Summary'};
   $outputf=$parameters{'Full'};
#  $outputi=$parameters{'Slope'};
   $action=$parameters{'actionc'} . 
           $parameters{'actionv'} . 
           $parameters{'actionw'} .
           $parameters{'ActionCD'};
#print "<p>Action is $action <br>";
#  chomp $action;
#   $me=$parameters{'me'};		# DEH 05/24/2000 2009.09.17
   $units=$parameters{'units'};

  $cookie = $ENV{'HTTP_COOKIE'};			# deh 2009.09.17
  $sep = index ($cookie,"FSWEPPuser=");
  $me = "";
  if ($sep > -1) {$me = substr($cookie,$sep+11,1)}      # DEH 2009.09.17
  if ($me ne "") {        				# deh 2009.09.17
    $me = lc(substr($me,0,1));        			# deh 2009.09.17
    $me =~ tr/a-z/ /c;        				# deh 2009.09.17
  }        						# deh 2009.09.17
  if ($me eq " ") {$me = ""}        			# deh 2009.09.17

    if ($units eq 'm') {$areaunits='ha'} #kova
    elsif ($units eq 'ft') {$areaunits='ac'} #kova
   else {$units = 'ft'; $areaunits='ac'}#kova
#print "<P> units are $units";
   $achtung=$parameters{'achtung'};
   $climyears=$parameters{'climyears'};
   $wildfirecycle=$parameters{'wildfire_cycle'}; #elena
#   print "<p> the value for wildfirecycle is $wildfirecycle "; #elena
   $fuelmangcycle=$parameters{'fuelmang_cycle'}; #elena
   $roaddensity=$parameters{'road_density'}; #elena
#   print "<p> the value for fuelmangcycle is $fuelmangcycle "; #elena
#   print "<p>the value of Cl is: $CL";  #elena
#   print "<p>the value of soil is: $soil";  #elena
#   print "<p>the value of me is: $me";  #elena
#   print "<p>the value of action is: $action";  #elena
#   print "<p>the value of achtung is: $achtung <br>";  #elena
#   print "<p>the value of climyears is: $climyears";  #elena0
# initialization for inputs array 
   @intreat1=($treat1,'tree5','low','high');
   @intreat2=($treat2,'tree20','tree20','high');
   @inofe1_pcover=($ofe1_pcover,85,85,45);
   @inofe2_pcover=($ofe2_pcover,100,100,45);
#   print "<p>Right now, the elements of intreat1 are: @intreat1";
#   print "<p>Right now, the elements of intreat2 are: @intreat1";
#   print "<p>Right now, the elements of inofe1_pcover are: @inofe1_pcover";
#   print "<p>Right now, the elements of inofe2_pcover are: @inofe2_pcover";


   $wepphost = "localhost";
   if (-e "../wepphost") {
     open HOST, "<../wepphost";
       $wepphost = lc(<HOST>);
       chomp $wepphost;
       if ($wepphost eq "") {$wepphost = "Localhost"}
     close HOST;
   }

   $platform = "pc";
#   print "<p>the value of platform is: $platform";  #elena
   if (-e "../platform") {
     open PLATFORM, "<../platform";
       $platform = lc(<PLATFORM>);
       chomp $platform;
       if ($platform eq "") {$platform = "unix"}
     close PLATFORM;
   }
#     $weppdiro = "http://" . $wepphost . "/Scripts/fswepp/wd/weppdiro.pl";#elena
     $weppdiro = "http://" . $wepphost . "/cgi-bin/fswepp/wd/fume.pl";#elena
#     print "<p> weppdiro $weppdiro <br>";#elena

   if (lc($action) =~ /custom/) {
#     $weppdiro = "http://" . $wepphost . "/Scripts/fswepp/wd/weppdiro.pl";
     $weppdiro = "http://" . $wepphost . "/cgi-bin/fswepp/wd/fume.pl";
     if ($platform eq "pc") {print "<p> I am here in wd1.pl in custom";
#       exec "perl ../rc/rockclim.pl -server -i$me -u$units $weppdiro"
#       exec "perl c:\\Inetpub\\Scripts\\fswepp\\rc\\rockclim.pl -server -i$me -u$units $weppdiro"
       exec "perl ../rc/rockclim.pl -server -i$me -u$units $weppdiro"
     }
     else {
       exec "../rc/rockclim.pl -server -i$me -u$units $weppdiro"
     }
     die
   }		# /custom/

   if (lc($achtung) =~ /describe climate/) {
#     $weppdiro = "http://" . $wepphost . "/Scripts/fswepp/wd/weppdiro.pl";
     $weppdiro = "http://" . $wepphost . "/cgi-bin/fswepp/wd/fume.pl";
# print "<p>I am inside describe and wepphost is $wepphost <br> cl is $CL<br> weppdiro is $weppdiro";#elena
     if ($platform eq "pc") {
#elena       exec "perl ../rc/descpar.pl $CL $weppdiro"
       exec "perl c:\\Inetpub\\Scripts\\fswepp\\rc\\descpar.pl $CL $weppdiro" #elena
     }
     else {
       exec "../rc/descpar.pl $CL $weppdiro"
     }
     die
   }		# /describe climate/

# *******************************

   if (lc($achtung) =~ /describe soil/) {   ##########

   }            #  /describe soil/

# *******************************

# ########### RUN WEPP ###########

   $years2sim=$climyears;
   if ($years2sim > 100) {$years2sim=100}

#  if ($host eq "") {$host = 'unknown';}
   $unique='wepp-' . $$;
#  if ($debug) {print 'Unique? filename= ',$unique,"\n<BR>"}
 #  print "<p>the value of platform is: $platform";  #elena
   if ($platform eq "pc") {
     if (-e 'd:/fswepp/working') {$working = 'd:\\fswepp\\working'}
     elsif (-e 'c:/fswepp/working') {$working = 'c:\\fswepp\\working'}
     else {$working = '..\\working'} elena
#     else {$working = 'c:\\Inetpub\\Scripts\\fswepp\\working'} #elena
#      print "<p>the value of working is: $working";  #elena
     $responseFile = "$working\\wdwepp.in";
     $outputFile   = "$working\\wdwepp.out";
     $stoutFile    = "$working\\wdwepp.sto";
     $sterFile     = "$working\\wdwepp.err";
     $slopeFile    = "$working\\wdwepp.slp";
     $soilFile     = "$working\\wdwepp.sol";
     $cropFile     = "$working\\wdwepp.crp";
     $climateFile  = "$CL" . '.cli';
     $manFile      = "$working\\wdwepp.man";
     $soilPath     = 'data\\';
     $manPath      = 'data\\';
#     $soilPath     = 'c:\\Inetpub\\Scripts\\fswepp\\wd\\data\\';   #elena
#     $manPath      = 'c:\\Inetpub\\Scripts\\fswepp\\wd\\data\\';   #elena
#      print "<p>the value of responseFile is: $responseFile";  #elena
#      print "<p>the value of outputFile is: $outputFile";  #elena
#      print "<p>the value of stoutFile is: $stoutFile";  #elena
#      print "<p>the value of sterFile  is: $sterFile ";  #elena
#      print "<p>the value of slopeFile is: $slopeFile";  #elena
#      print "<p>the value of soilFile is: $soilFile";  #elena
#      print "<p>the value of cropFile is: $cropFile";  #elena
#      print "<p>the value of climateFile is: $climateFile";  #elena
#      print "<p>the value of manFile is: $manFile";  #elena
#      print "<p>the value of soilPath is: $soilPath";  #elena
#      print "<p>the value of manPath is: $manPath <br>";  #elena

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

#   print "Content-type: text/html\n\n";
   $climatePar = $CL . '.par';
#   print "<p>the value of climatePar is $climatePar";
   open PAR, "<$climatePar";
   $climatename1=<PAR>;
#   print "<p>this is climatename1 $climatename1 ";
   $climatename=substr($climatename1,1,length($climatename1)-10);
   close PAR;

   print '<HTML>
 <HEAD>
  <TITLE>Fuel Management Results</TITLE>
 </HEAD>
 <BODY background="/fswepp/images/note.gif" link="#555555" vlink="#555555">
  <font face="Arial, Geneva, Helvetica">
<!--elena<BODY background="http://',$wepphost,'/fswepp/images/note.gif">
   <blockquote> 
  <table width=100% border=0>
    <tr><td> 
       <IMG src="http://',$wepphost,'/fswepp/images/fsweppic2.jpg" alt="Erosion Analysis"
       align="left" border=0 width="95" height="95">
    <td align=center>
       <hr>
       <h2>WEPP Analysis Results</h2>
       <hr>
    <td>
       <A HREF="http://',$wepphost,'/fswepp/docs/distweppdoc.html" target="docs">
       <IMG src="http://',$wepphost,'/fswepp/images/fire1.jpg"
        align="right" alt="Environmental Effects" border=2></a>
    </table>
';
       print "   
  <center>
   <h3>Input Conditions</h3>
    <table border=1>
     <tr>
      <th bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>Location</th>
      <td colspan=3><font face='Arial, Geneva, Helvetica'><b>$climatename</b></td>
     </tr>
     <tr>
      <th bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>Soil texture</th>
      <td colspan=3><font face='Arial, Geneva, Helvetica'>$soil_type{$soil}</td>
     </tr>
     <tr>
      <th bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>Hillslope slope (%)</th>
      <td><font face='Arial, Geneva, Helvetica'>$ofe1_mid_slope</td>
      <th bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>Hillslope lengh (ft)</th>
      <td><font face='Arial, Geneva, Helvetica'>$ofe1_length</td>
     </tr>
     <tr>
      <th bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>Buffer Slope (%)</th>
      <td><font face='Arial, Geneva, Helvetica'>$ofe2_bot_slope</td>
      <th bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>Buffer lengh (ft)</th>
      <td><font face='Arial, Geneva, Helvetica'>$ofe2_length</td>
     </tr>
     <tr>
      <th bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>Fire Cycle (yr)</th>
      <td><font face='Arial, Geneva, Helvetica'>$wildfirecycle</td>
      <th bgcolor=85d2d2><font face='Arial, Geneva, Helvetica'>Fuel Mgt Cycle (yr)</th>
      <td><font face='Arial, Geneva, Helvetica'>$fuelmangcycle</td>
     </tr>
    </table>
   </center>
    
";
   $host = $ENV{REMOTE_HOST};
########################### elena new loop#############################

  for($i = 0; $i < 4; $i++){
   $treat1=$intreat1[$i]; #kova
   $treat2=$intreat2[$i]; #kova
   $ofe1_pcover=$inofe1_pcover[$i]; #kova
   $ofe2_pcover=$inofe1_pcover[$i]; #kova
   $ofe1_length=$user_ofe1_length; #elena
   $ofe2_length=$user_ofe2_length; #elena

   print "
   <table width=100% border=0>
    <tr>
     <td bgcolor='lightgray'>
      <font face='tahoma' size=-1>
       $i -- $treat1 $treat2 $ofe1_pcover% cover $ofe2_pcover% cover $ofe1_length $units $ofe2_length $units
      </font>
     </td>
    </tr>
   </table>
";

   $rcin = &checkInput;
   if ($rcin >= 0) {

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
#       print "<p>the value of ofe1_length is $ofe1_length";#elena
       $ofe2_length=$ofe2_length/3.28;		# 3.28 ft == 1 m
       $ofe_area=$ofe_area/2.47;		# 2.47 ac == 1 ha; Schwab Fangmeier Elliot Frevert
     }

     $ofe_width=$ofe_area*10000/($ofe1_length+$ofe2_length);

     if ($debug) {print "Creating Slope File<br>\n"}
     &CreateSlopeFile;
     if ($debug) {print "Creating Management File<br>\n"}
     &CreateManagementFile;
     if ($debug) {print "Creating Climate File<br>\n"}
     &CreateCligenFile;
     if ($debug) {print "Creating Soil File<br>\n"}
     &CreateSoilFile;
     if ($debug) {print "Creating WEPP Response File<br>\n"}
     &CreateResponseFile;

#    @args = ("nice -20 ./wepp <$responseFile >$stoutFile 2>$sterFile");
     if ($platform eq "pc") {
#       @args = ("..\\wepp <$responseFile >$stoutFile")
#      print "<p>I am creating args<br>\n"; #elena
#      print "<p> this is responseFile:$responseFile"; #elena
      @args = ("c:\\Inetpub\\Scripts\\fswepp\\wepp <$responseFile >$stoutFile"); #elena
#      print "<p>this is arg : @args <br>\n"
     }
     else {
       @args = ("../wepp <$responseFile >$stoutFile 2>$sterFile")
     }
     system @args;
  unlink $climateFile;    # be sure this is right file .....     # 2/2000

#------------------------------

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

     if ($found == 1) {
       open weppout, "<$outputFile";
       $_ = <weppout>;
       if (/Annual; detailed/) {$outputfiletype="annualdetailed"}
       $ver = 'unknown';
       while (<weppout>) {
         if (/VERSION/) {
           $weppver = $_;
           last;
         }
       }

# ############# actual climate station name #####################

       while (<weppout>) {     ######## actual ########
         if (/CLIMATE/) {
#          print;
           $a_c_n=<weppout>;
#           print "<p> the value of a_c_n is $a_c_n "; #elena
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
           $_ = <weppout>;$syp = substr $_,50,9;
           $_ = <weppout>; 
           if ($syp eq "") {$syp = substr $_,10,9}
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
       $areaunits='ha' if $units eq 'm';
       $areaunits='ac' if $units eq 'ft';
#elenaprint "<p> asypa is $asypa"; #elena test
#elenaprint "<p> areaunits is $areaunits"; #elena test



if ($units eq 'm') {
   $user_precip = sprintf "%.1f", $precip;
   $user_rro = sprintf "%.1f", $rro;
   $user_sro = sprintf "%.1f", $sro;
   $user_asyra = sprintf "%.2f", $asyra;
   $user_asypa = sprintf "%.2f", $asypa;
   $out_asypa[$i] = $user_asypa; #elena loop kova
#elena   print "<p> this is out_asypa[$i]: $out_asypa[$i]"; #elena
   $rate = 't ha<sup>-1</sup>';
   $pcp_unit = 'mm'
}
if ($units eq 'ft') {
   $user_precip = sprintf "%.2f", $precip*0.0394;	# mm to in
   $user_rro = sprintf "%.2f", $rro*0.0394;		# mm to in
   $user_sro = sprintf "%.2f", $sro*0.0394;		# mm to in
   $user_asyra = sprintf "%.2f", $asyra*0.445;		# t/ha to t/ac
   $user_asypa = sprintf "%.2f", $asypa*0.445;          # t/ha to t/ac
#   print "<p> the value of user_asypa is $user_asypa"; #elena kova		
   $out_asypa[$i] = $user_asypa; #elena loop kova
#elena   print "<p> this is out_asypa[$i]: $out_asypa[$i]"; #elena kova
   $rate = 't ac<sup>-1</sup>';
   $pcp_unit = 'in.'
}


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
      $asyp = sprintf "%.2f", $sed_del[$rp_year-1] * 10 / $slope_length * $rcf;


      $ii += 1;
   }
}
   $user_avg_pcp = sprintf "%.2f", $avg_pcp*$dcf;
   $user_avg_ro  = sprintf "%.2f", $avg_ro*$dcf;
   $user_asyra   = sprintf "%.2f", $asyra*$rcf;
   $user_asypa   = sprintf "%.2f", $asypa*$rcf;

         $base_size=100;
         $prob_no_pcp      = sprintf "%.2f", $nzpcp/$simyears;
         $prob_no_runoff   = sprintf "%.2f", $nzra/$simyears;
         $prob_no_erosion  = sprintf "%.2f", $nzdetach/$simyears;
         $prob_no_sediment = sprintf "%.2f", $nzsed_del/$simyears;

       }  	#	else case of if (lc($action) =~ /vegetation/)


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


#  system "rm working/$unique.*";

   unlink <$working/$unique.*>;       # da

   $host = $ENV{REMOTE_HOST};                    
   $host = $ENV{REMOTE_ADDR} if ($host eq '');
   $user_really=$ENV{'HTTP_X_FORWARDED_FOR'};		# DEH 11/14/2002
   $host = $user_really if ($user_really ne '');	# DEH 11/14/2002
   if (lc($wepphost) ne "localhost") {
     open WDLOG, ">>../working/wd.log";
#      $host = $ENV{REMOTE_HOST};
#      if ($host eq "") {$host = $ENV{REMOTE_ADDR} };
       print WDLOG "$host\t";
       printf WDLOG "%0.2d:%0.2d ", $hour, $min;
       print WDLOG $ampm[$ampmi],"  ",$days[$wday]," ",$months[$mon]," ",$mday, ", ",$thisyear, "\t";
       print WDLOG $years2sim,"\t";
       print WDLOG $climate_name,"\n";
     close WDLOG;
   }

# ######################### i loop for Disturbed runs (0 to 4) ##########

} #elena i loop

# ######################### now do the WEPP:Road runs ###################

%wroadout= &wrdt();

@outsyraf= @{$wroadout{'sedroad'}};

@outsypaf= @{$wroadout{'sedbuff'}};

$undisturbe=$out_asypa[0]*640; #elena
$thinning=($out_asypa[1]*640)/$fuelmangcycle; #elena
$prescribe=($out_asypa[2]*640)/$fuelmangcycle; #elena
$wildfire=($out_asypa[3]*640)/$wildfirecycle; #elena
$notbackground=$undisturbe+$wildfire; #elena
$witbackground=$thinning+$prescribe; #elena
$withbperofnotb= sprintf('%.2f' , ((100*$witbackground)/$notbackground)); #elena


$lowntrafficbuffer= sprintf('%.2f' , ($outsypaf[0]*0.0088*$roaddensity)); #elena

$highltrafficroad= sprintf('%.2f' , ($outsyraf[1]*0.0088*$roaddensity)); #elena

$lowhtrafficbuffer= sprintf('%.2f' , ($outsypaf[2]*0.0088*$roaddensity)); #elena

$highltrafficroad= sprintf('%.2f' , ($outsyraf[1]*0.0088*$roaddensity)); #elena

# ######################## new table with results #############

print<<"end";

<center>
<h3>Predicted Values</h3>
<table border="1">
<tr>
	<td align="center" bgcolor="85d2d2" colspan="2">
         <font face='Arial, Geneva, Helvetica'>
          <b>No          Treatment</b>
         </font>
	</td>
	<td align="center" bgcolor="85d2d2" colspan="2">
         <font face='Arial, Geneva, Helvetica'>
          <b>With Treatment</b>
         </font>
	</td>
       </tr>
       <tr>
	<th align="center" valign="center" bgcolor="85d2d2">
         <font face='Arial, Geneva, Helvetica'>
          Source
         </font>
	</th>
	<th align="center" valign="center" bgcolor="85d2d2">
         <font face='Arial, Geneva, Helvetica'>
          Sediment Yield<br>t/sq mile/year
         </font>
	</th>
	<th align="center" valign="center" bgcolor="85d2d2">
         <font face='Arial, Geneva, Helvetica'>
          Source
         </font>
	</th>
	<th align="center" valign="center" bgcolor="85d2d2">
         <font face='Arial, Geneva, Helvetica'>
          Sediment Yield<br>t/sq mile/year
         </font>
	</th>
       </tr>
       <tr>
	<td align="center"><font face='Arial, Geneva, Helvetica'>Undisturbed forest</td>
	<td align="center"><font face='Arial, Geneva, Helvetica'>$undisturbe</td>
	<td align="center"><font face='Arial, Geneva, Helvetica'>Thining</td>
	<td align="left"><font face='Arial, Geneva, Helvetica'>Background+$thinning</td>
       </tr>
       <tr>
	<td align="center"><font face='Arial, Geneva, Helvetica'>Wildfire</td>
	<td align="center"><font face='Arial, Geneva, Helvetica'>$wildfire</td>
	<td align="center"><font face='Arial, Geneva, Helvetica'>Prescribed Fire</td>
	<td align="left"><font face='Arial, Geneva, Helvetica'>Background+$prescribe</td>
       </tr>
       <tr>
	<td align="center">&nbsp;</td>
	<td align="center"><IMG src="/fswepp/images/line2.gif" width="90" height="10"  ></td>
	<td align="center">&nbsp;</td>
	<td align="right"><img src="/fswepp/images/line2.gif" width="150" height="10" align="middle"></td>
       </tr>
       <tr>
	<td align="center"><font face='Arial, Geneva, Helvetica'>"Background"</td>
	<td align="center"><font face='Arial, Geneva, Helvetica'>$notbackground</td>
	<td align="center"><font face='Arial, Geneva, Helvetica'>Thin+Rx Fire</td>
	<td align="left"><font face='Arial, Geneva, Helvetica'>Background+$witbackground</td>
       </tr>
       <tr>
	<td align="center"><font face='Arial, Geneva, Helvetica'>Road Network</td>
	<td align="center"><font face='Arial, Geneva, Helvetica'>$lowntrafficbuffer to $highltrafficroad</td>
	<td align="center"><font face='Arial, Geneva, Helvetica'>Road Network</td>
	<td align="center"><font face='Arial, Geneva, Helvetica'>$lowhtrafficbuffer to $highltrafficroad</td>
       </tr>
      </table>
     </center>
     <br>
     <br>
<h2>Discussion of Results</h2>
<p align="justify">From the above table, a typical background erosion rate is $notbackground 
	t &#8260 mi&#178 (Undisturbed plus wildfire effects). The road network will add 
	an additional $lowntrafficbuffer to $highltrafficroad t &#8260 mi&#178, depending on the condition of the road 
	and the number of live water crossings.<br>
	If fuel management prevents wildfire, then there will be a net decrease in 
	erosion in the watershed, which may have implications for aquatic ecosystems. 
	If the fuel management does not presvent wildfire, then there is an increase of 
	$witbackground t &#8260 mi&#178, or about $withbperofnotb percent, not counting roads. There appears to 
	be scope in this watershed to significantly decrease sediment from road 
	sources, and a more detailed road analysis is advised, using the WEPP:Road 
	interface.
</p>
<there4>

<hr>

end

print '<a href="http://',$wepphost,'/fswepp/comments.html" ';
if ($wepphost eq 'localhost') {print 'onClick="return confirm(\'You must be connected to the Internet to e-mail comments. Shall I try?\')"'};                                  
print '>                                                              
<img src="http://',$wepphost,'/fswepp/images/epaemail.gif" align="right" border=0>
</a>
Interface v. 
 <a href="http://',$wepphost,'/fswepp/history/wdver.html"> ',$version,'</a>
 (for review only) by David Hall and Elena V.,
 Project leader Bill Elliot<br>
 USDA Forest Service, Rocky Mountain Research Station, Moscow, ID 83843<br>';

#  $wc  = `wc ../working/wd.log`;                                               
#  @words = split " ", $wc;                                                     
#  $runs = @words[0];                                                           
                                                                               
print "
#  <b>$runs</b> Disturbed WEPP runs since January 1<br>
&printdate;

 </body>
</html>
";

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
#   print "<p> in slopefile ofe1_length is $ofe1_length";#elena
   $top_slope1 = $ofe1_top_slope / 100;
   $mid_slope1 = $ofe1_mid_slope / 100;
   $mid_slope2 = $ofe2_mid_slope / 100;
   $bot_slope2 = $ofe2_bot_slope / 100;
   $avg_slope = ($mid_slope1 + $mid_slope2) / 2;
   $ofe_width=100 if $ofe_area == 0;
   open (SlopeFile, ">".$slopeFile);

     print SlopeFile "97.3\n";           # datver
     print SlopeFile "#\n# Slope file generated for Disturbed WEPP\n#\n";
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

sub CreateManagementFile {

     $climatePar = $CL . '.par';
     &getAnnualPrecip;			# open .par file and calculate annual precipitation
     if ($debug) {print "Annual Precip: $ap_annual_precip mm<br>\n"}

#  $treat1 = "skid";   $treat2 = "tree5";

   open MANFILE, ">$manFile";

   print MANFILE "97.3
#
#\tCreated for Disturbed WEPP by wd.pl (v. $version)
#\tNumbers by: Bill Elliot (USFS) et alia
#

2\t# number of OFEs
$years2sim\t# (total) years in simulation

#################
# Plant Section #
#################

2\t# looper; number of Plant scenarios

";

#   print "<p>the value of treat1.wps is: $treat1.wps <br>";  #elena
   open PS1, "<data/$treat1.wps";      # WEPP plant scenario 
#   open PS1, "<c:\\Inetpub\\Scripts\\fswepp\\wd\\data\\$treat1.wps"; #elena
#  read 14 lines (base 0); line 9 entry 2 will change (biomass) as f(climate)

#  $beinp is biomass energy ratio (real ~ 0 to 1000): plant scenario 7.3 (p. 33)
#  the following equation relates biomass ratio to cover (whole) percent and precipitation in mm
#  from work December 1999 by W.J. Elliot unpublished.

#   ($ofe1_pcover > 100) ? $pcover = 100 : $pcover = $ofe1_pcover;
   $pcover = $ofe1_pcover;	# decided not to limit input cover to 100%; use whatever is entered (for now)
   $precip_cap = 450;		# max precip in mm to put into biomass equation (curve flattens out)
   ($ap_annual_precip < $precip_cap) ? $capped_precip = $ap_annual_precip : $capped_precip = $precip_cap;
#   $beinp = sprintf "%.1f", 8.17 * exp(0.031 * $pcover - 0.0023 * $capped_precip);
    $beinp = sprintf "%.1f", 0.0 * exp(0.031 * $pcover - 0.0023 * $capped_precip); #elena
#   $beinp = 0.1 #elena
#   print "<p> this is beinp: $beinp <br>"; #elena
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
#   print "<p>the value of treat2.wps is: $treat2.wps <br>";  #elena
   open PS2, "<data/$treat2.wps";
#   open PS2, "<c:\\Inetpub\\Scripts\\fswepp\\wd\\data\\$treat2.wps"; #elena
#  read 14 lines (base 0); line 9 entry 2 will change (biomass) as f(climate)

#   ($ofe2_pcover > 100)? $pcover = 100 : $pcover = $ofe2_pcover;
   $pcover = $ofe2_pcover;
   ($ap_annual_precip < $precip_cap) ? $capped_precip = $ap_annual_precip : $capped_precip = $precip_cap;
#   $beinp = sprintf "%.1f", 8.17 * exp(0.031 * $pcover - 0.0023 * $capped_precip);;
   $beinp = sprintf "%.1f", 0.00 * exp(0.031 * $pcover - 0.0023 * $capped_precip);; #elena
#   $beinp = 0.0 #elena
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

#   print "<p>the value of treat1.ics is: $treat1.ics <br>";  #elena
   open IC, "<data/$treat1.ics";        # Initial Conditions Scenario file
#   open IC, "<c:\\Inetpub\\Scripts\\fswepp\\wd\\data\\$treat1.ics"; #elena       
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
#   print "<p>the value of treat2.ics is: $treat2.ics <br>";  #elena
   open IC, "<data/$treat2.ics";
#   open IC, "<c:\\Inetpub\\Scripts\\fswepp\\wd\\data\\$treat2.ics"; #elena
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
#   print "<p>the value of treat1.ys is: $treat1.ys <br>";  #elena

   open YS, "<data/$treat1.ys";      # Yearly Scenario
#   open YS, "<c:\\Inetpub\\Scripts\\fswepp\\wd\\data\\$treat1.ys";      # elena
   while (<YS>) {
     if (/itype/) {substr ($_,0,1) = "1"}
     print MANFILE $_;
   }
   close YS;
#   print "<p>the value of treat2.ys is: $treat2.ys <br>";  #elena
   open YS, "<data/$treat2.ys";
#   open YS, "<c:\\Inetpub\\Scripts\\fswepp\\wd\\data\\$treat2.ys"; #elena
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
Two OFEs to drive the Disturbed WEPP interface
for forest conditions
W. Elliot 02/99
2\t# `nofe' - <number of Overland Flow Elements>
\t1\t# `Initial Conditions indx' - <$treat1>
\t2\t# `Initial Conditions indx' - <$treat2>
$years2sim\t# `nrots' - <rotation repeats..>
1\t# `nyears' - <years in rotation>
";

   for $i (1..$years2sim) {
     print MANFILE "#
#	Rotation $i : year $i to $i
#
\t1\t# `nycrop' - <plants/yr; Year of Rotation :  $i - OFE : 1>
\t\t1\t# `YEAR indx' - <$treat1>
\t1\t# `nycrop' - <plants/yr; Year of Rotation :  $i - OFE : 2>
\t\t2\t# `YEAR indx' - <$treat2>
";
   }
   close MANFILE;
}

sub CreateSoilFile {

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
   $inner_offset{skid} = 0;
   $inner_offset{high} = 2;
   $inner_offset{low} = 4;
   $inner_offset{short} = 6;
   $inner_offset{tall} = 8;
   $inner_offset{shrub} = 10;
   $inner_offset{tree5} = 12;
   $inner_offset{tree20} = 14;

   $line_number1 = $outer_offset{$soil} + $inner_offset{$treat1};
   $line_number2 = $outer_offset{$soil} + $inner_offset{$treat2};

   open SOLFILE, ">$soilFile";

   print SOLFILE 
"97.3
#
#      Created by 'wd.pl' (v 2001.10.10)
#      Numbers by: Bill Elliot (USFS)
#
Isn't the sky blue today?
 2    1
";

   open SOILDB, "<data/soilbase"; #elena
#   open SOILDB, "<c:\\Inetpub\\Scripts\\fswepp\\wd\\data\\soilbase";    #elena
   for $i (1..$line_number1) {
     $in = <SOILDB>;
   }
   chomp $in;
    print SOLFILE $in,"\n";

   $in = <SOILDB>;
$index_rfg = index($in,'rfg');
$left = substr($in,0,$index_rfg);
$right = substr ($in, $index_rfg+3);
$in = $left . $ofe1_rock . $right;

   print SOLFILE $in;
   close SOILDB;

   open SOILDB, "<data/soilbase";
#   open SOILDB, "<c:\\Inetpub\\Scripts\\fswepp\\wd\\data\\soilbase";    #elena
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
     print ResponseFile "98.4\n";        # datver
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

   $rc = 0;
   print '<font color="red"><b>',"\n";
   if ($CL eq "") {print "No climate selected<br>\n"; $rc -= 1}
   if ($soil ne "sand" && $soil ne "silt" && $soil ne "clay" && $soil ne "loam")
       {print "Invalid soil: ",$soil,"<br>\n"; $rc -=1}
#  if ($treat1 ne "skid" && $treat1 ne "high" && $treat1 ne "low"
#      && $treat1 ne "short" && $treat1 ne "tall" && $treat1 ne "shrub"
#      && $treat1 ne "tree5" && $treat1 ne "tree20")
   if ($treatments{$treat1} eq "")
      {print "Invalid upper treatment: ",$treat1,"<br>\n"; $rc -=1}
   if ($treatments{$treat2} eq "")
      {print "Invalid lower treatment: ",$treat2,"<br>\n"; $rc -=1}
   if ($units eq 'm') {
     if ($ofe1_length < 0 || $ofe1_length > 3000)
        {print "Invalid upper length; range 0 to 3000 m<br>\n"; $rc -=1}
     if ($ofe2_length < 0 || $ofe2_length > 3000)
        {print "Invalid lower length; range 0 to 3000 m<br>\n"; $rc -=1}
   }
   else {
     if ($ofe1_length < 0 || $ofe1_length > 9000)
        {print "Invalid upper length; range 0 to 9000 ft<br>\n"; $rc -=1}
     if ($ofe2_length < 0 || $ofe2_length > 9000)
        {print "Invalid lower length; range 0 to 9000 ft<br>\n"; $rc -=1}
   }
   if ($ofe1_top_slope < 0 || $ofe1_top_slope > 1000)
      {print "Invalid upper top gradient; range 0 to 1000 %<br>\n"; $rc -=1}
   if ($ofe1_mid_slope < 0 || $ofe1_mid_slope > 1000)
      {print "Invalid upper mid gradient; range 0 to 1000 %<br>\n"; $rc -=1}
   if ($ofe2_mid_slope < 0 || $ofe2_mid_slope > 1000)
      {print "Invalid lower mid gradient; range 0 to 1000 %<br>\n"; $rc -=1}
   if ($ofe2_bot_slope < 0 || $ofe2_bot_slope > 1000)
      {print "Invalid lower toe gradient; range 0 to 1000 %<br>\n"; $rc -=1}
#   if ($ofe1_pcover < 0 || $ofe1_pcover > 100)
#      {print "Invalid upper percent cover; range 0 to 100 %<br>\n"; $rc -=1}
#   if ($ofe2_pcover < 0 || $ofe2_pcover > 100)
#      {print "Invalid lower percent cover; range 0 to 100 %<br>\n"; $rc -=1}
   print "</b></font>\n";
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
platform:     $platform<br>
";}


#  run CLIGEN43 on verified user_id.par file to
#  create user_id.cli file in FSWEPP working directory
#  for specified # years.
#print "Content-type: text/html\n\n"; #elena
#print "<p>climatePar: $climatePar \n";     #elena
#print "<p>station: $station \n";     #elena
#print "<p>climateFile: $climateFile \n";     #elena
#print "<p>outfile: $outfile \n";     #elena
#print "<p>rspfile: $rspfile \n";     #elena
#print "<p>stoutfile: $stoutfile \n";     #elena

   $startyear = 1;

     open (RSP, ">" . $rspfile); 
#    open (RSP, ">c:\\Inetpub\\Scripts\\fswepp\\working\\cligen.rsp"); #elena
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

    if ($platform eq 'pc') {#print "<p>I am here \n";
       @args = ("c:\\Inetpub\\Scripts\\fswepp\\rc\\cligen43.exe < $rspfile >$stoutfile");
     }
    else {
#      @args = ("nice -20 ../rc/cligen43 <$rspfile >$stoutfile");
       @args = ("../rc/cligen43 <$rspfile >$stoutfile");
    }
   system @args;
   unlink $rspfile;     #  "../working/c$unique.rsp"
   unlink $stoutfile;   #  "../working/c$unique.out"

#   if ($debug) {
#     open STOUT, "<$stoutfile";
#     print "Cligen: \n";
#     while (<STOUT>) {
#       print $_,"\n<br>";
#     }
#     close STOUT;
#   }
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

# ------------------------ end of subroutines ----------------------------
