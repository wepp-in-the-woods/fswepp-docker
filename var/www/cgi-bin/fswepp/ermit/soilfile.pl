#! /usr/bin/perl

  &ReadParse(*parameters);

  $s = $parameters{'s'};
  $k = $parameters{'k'};
  $SoilType = $parameters{'SoilType'};
  $rfg = $parameters{'rfg'};
  $vegtype = $parameters{'vegtype'};
  $shrub = $parameters{'shrub'};
  $grass = $parameters{'grass'};
  $bare = $parameters{'bare'};

goto skip;

  $s = 'hhh';
  $k = 0;
  $SoilType = 'silt';
  $rfg = 20;
  $vegtype = 'forest';
  $shrub = 0;
  $grass = 0;
  $bare = 0;

skip:

  $soil_texture = $SoilType;

     print "Content-type: text/html\n\n";
     print "<HTML>
 <HEAD>
  <TITLE>ERMiT -- Soil File</TITLE>
 </HEAD>
 <BODY>
  <pre>
  spatial = $s
  conductivity = $k
  soil type = $SoilType
  rock fragment = $rfg
  vegtype = $vegtype
  shrub = $shrub
  grass = $grass
  bare = $bare

";
   print &createsoilfile;
print "
  </pre>   
 </body>
</html>
";

sub createsoilfile {
 
# return soil file for ERMiT given
#   soil texture designation (sand, silt, clay, loam)
#   spatial representation (lll, llh, lhl, lhh, hll, hlh, hhl, hhh)
#   conductivity ranking for ki, kr, ksat/aveke (0..4)   
#   percent rock fragments (rfg)  
 
# USDA FS RMRS Moscow FSL coding by david numbers by bill & corey  
   
  $ver = '2002.11.27';
   
# reads:
  # $s -- severity code ('hhh' .. 'lll') 
  # $k -- kr/ksat counter (0..4)    
  # $SoilType -- soil type 
  # $soil_texture -- soil texture   
  # $rfg -- percentage of rock fragments (by volume) in the layer (%)
  # $vegtype 
  # $shrub, $grass, $bare  
# returns:   
  # Soil file
# calls 
  # soilparameters    
   
#  $SoilType = 'silt';
#  $s = 'lll';   
#  $k = 4;
#  $rfg = 20; # percentage of rock fragments (by volume) in the layer (%)  

  if ($SoilType ne 'sand' && $SoilType ne 'silt' && 
 $SoilType ne 'clay' && $SoilType ne 'loam') {return}   

  my $string = lc($s);  

  if ($string eq 'lll' || $string eq 'hhh') { $nofe = 1 }    
  if ($string eq 'llh' || $string eq 'hhl') { $nofe = 2 }    
  if ($string eq 'lhl' || $string eq 'hlh') { $nofe = 3 }    
  if ($string eq 'lhh' || $string eq 'hll') { $nofe = 2 }    

  $ksflag = 0;  # hold internal hydraulic conductivity constant (0 => do not ad$
  $nsl = 1;# number of soil layers for the current OFE  
  $salb = 0.2;  # albedo of the bare dry surface soil on the current OFE   
  $sat = 0.75;  # initial saturation level of the soil profile porosity (m/m)   

  &soil_parameters; 
  
  @l[0] = @ki_l[0] . "\t" . @kr_l[0] . "\t" . $tauc . "\t" . @ksat_l[0];
  @l[1] = @ki_l[1] . "\t" . @kr_l[1] . "\t" . $tauc . "\t" . @ksat_l[1];
  @l[2] = @ki_l[2] . "\t" . @kr_l[2] . "\t" . $tauc . "\t" . @ksat_l[2];
  @l[3] = @ki_l[3] . "\t" . @kr_l[3] . "\t" . $tauc . "\t" . @ksat_l[3];
  @l[4] = @ki_l[4] . "\t" . @kr_l[4] . "\t" . $tauc . "\t" . @ksat_l[4];
  @h[0] = @ki_l[0] . "\t" . @kr_h[0] . "\t" . $tauc . "\t" . @ksat_h[0];
  @h[1] = @ki_l[1] . "\t" . @kr_h[1] . "\t" . $tauc . "\t" . @ksat_h[1];
  @h[2] = @ki_l[2] . "\t" . @kr_h[2] . "\t" . $tauc . "\t" . @ksat_h[2];
  @h[3] = @ki_l[3] . "\t" . @kr_h[3] . "\t" . $tauc . "\t" . @ksat_h[3];
  @h[4] = @ki_l[4] . "\t" . @kr_h[4] . "\t" . $tauc . "\t" . @ksat_h[4];
   
  $results="95.1 
#  WEPP '$soil_texture' '$s$k' $vegtype soil input file for ERMiT"; 
  if ($vegtype eq 'forest') {} 
  else {$results .= "\n#  $shrub% shrub $grass% grass $bare% bare"} 
  $results .= "  
#  Data from RMRS Soil and Water Engineering Project, Moscow FSL    
#  Created by 'createsoilfile' version $ver  
$nofe\t0    
"; 
   
  $that_severity = '';    
  for $i (0..2) {
    $this_severity = substr($string,$i,1);   
    $sev = $this_severity;
    if ($this_severity ne $that_severity) {  
      if ($this_severity eq 'l') { 
      $KiKrShcritAvke = @l[$k] 
    }   
    else {  
      $KiKrShcritAvke = @h[$k] 
    }   
 $results .= "'ERMiT_$sev$k'\t'$soil_texture'\t$nsl\t$salb\t$sat\t" . $KiKrShcritAvke; 
 $results .= "\n$solthk\t$sand\t$clay\t$orgmat\t$cec\t$rfg\n";   
 $that_severity = $this_severity;
    }
  }  
  return $results; 
}    

sub soil_parameters {   
 
 # $vegtype ['forest' 'range' 'chaparral'] 
 # $SoilType ['sand' 'silt' 'clay' 'loam'] 
 # $shrub   
 # $grass   
 # $bare
   
 # @ki_l[0..4]   
 # @ki_h[0..4]   
 # @kr_l[0..4]   
 # @kr_h[0..4]   
 # $tauc
 # @ksat_l[0..4] 
 # @ksat_h[0..4] 
   
  if ($vegtype eq 'forest') {  
   
    if ($SoilType eq 'sand') { 
 $solthk = 400; # depth of soil surface to bottom of soil layer (mm)
 $sand = 55;    # percentage of sand in the layer (%) 
 $clay = 10;    # percentage of clay in the layer (%)   
 $orgmat = 5;   # percentage of organic matter (by vlume) in the laye$
 $cec = 15;# cation exchange capacity in the layer (meq per 100 $
 $tauc=2;
 @ki_l[0] =  300000; @kr_l[0] = 0.00030; @ksat_l[0] = 48;
 @ki_l[1] =  500000; @kr_l[1] = 0.00034; @ksat_l[1] = 46;
 @ki_l[2] =  700000; @kr_l[2] = 0.00037; @ksat_l[2] = 44;
 @ki_l[3] = 1000000; @kr_l[3] = 0.00040; @ksat_l[3] = 24;
 @ki_l[4] = 1200000; @kr_l[4] = 0.00045; @ksat_l[4] = 14;
 @ki_h[0] = 1000000; @kr_h[0] = 0.00040; @ksat_h[0] = 22;
 @ki_h[1] = 1500000; @kr_h[1] = 0.00050; @ksat_h[1] = 13;
 @ki_h[2] = 2000000; @kr_h[2] = 0.00060; @ksat_h[2] =  7;
 @ki_h[3] = 2500000; @kr_h[3] = 0.00070; @ksat_h[3] =  6;
 @ki_h[4] = 3000000; @kr_h[4] = 0.00100; @ksat_h[4] =  5;
    }
    if ($SoilType eq 'silt') {   
 $solthk = 400;    
 $sand = 25;   
 $clay = 15;   
 $orgmat = 5;  
 $cec = 15;    
 $tauc = 3.5;  
 @ki_l[0] =  250000; @kr_l[0] = 0.00020; @ksat_l[0] = 33;
 @ki_l[1] =  300000; @kr_l[1] = 0.00024; @ksat_l[1] = 31;
 @ki_l[2] =  400000; @kr_l[2] = 0.00027; @ksat_l[2] = 29;
 @ki_l[3] =  500000; @kr_l[3] = 0.00030; @ksat_l[3] = 19;
 @ki_l[4] =  600000; @kr_l[4] = 0.00035; @ksat_l[4] =  9;
 @ki_h[0] =  500000; @kr_h[0] = 0.00030; @ksat_h[0] = 18; 
 @ki_h[1] = 1000000; @kr_h[1] = 0.00040; @ksat_h[1] = 10; 
 @ki_h[2] = 1500000; @kr_h[2] = 0.00050; @ksat_h[2] =  6; 
 @ki_h[3] = 2000000; @kr_h[3] = 0.00060; @ksat_h[3] =  4; 
 @ki_h[4] = 2500000; @kr_h[4] = 0.00090; @ksat_h[4] =  3; 
    }  
    if ($SoilType eq 'clay') {
 $solthk = 400; 
 $sand = 25;    
 $clay = 30;    
 $orgmat = 5;   
 $cec = 25;
 $tauc = 4;
 @ki_l[0] =  200000; @kr_l[0] = 0.00010; @ksat_l[0] = 25; 
 @ki_l[1] =  250000; @kr_l[1] = 0.00014; @ksat_l[1] = 24; 
 @ki_l[2] =  300000; @kr_l[2] = 0.00017; @ksat_l[2] = 23; 
 @ki_l[3] =  400000; @kr_l[3] = 0.00020; @ksat_l[3] = 14; 
 @ki_l[4] =  500000; @kr_l[4] = 0.00025; @ksat_l[4] =  8;
 @ki_h[5] =  400000; @kr_h[0] = 0.00020; @ksat_h[0] = 13;
 @ki_h[6] =  700000; @kr_h[1] = 0.00030; @ksat_h[1] =  7;
 @ki_h[7] = 1000000; @kr_h[2] = 0.00040; @ksat_h[2] =  4;
 @ki_h[8] = 1500000; @kr_h[3] = 0.00050; @ksat_h[3] =  3;
 @ki_h[9] = 2000000; @kr_h[4] = 0.00080; @ksat_h[4] =  2;
    } 
    if ($SoilType eq 'loam') {    
 $solthk = 400;
 $sand = 45;   
 $clay = 20;   
 $orgmat = 5;  
 $cec = 20;    
 $tauc = 3;    
 @ki_l[0] =  320000; @kr_l[0] = 0.00015; @ksat_l[0] = 40;
 @ki_l[1] =  370000; @kr_l[1] = 0.00019; @ksat_l[1] = 38;
 @ki_l[2] =  470000; @kr_l[2] = 0.00022; @ksat_l[2] = 36;
 @ki_l[3] =  600000; @kr_l[3] = 0.00025; @ksat_l[3] = 28; 
 @ki_l[4] =  800000; @kr_l[4] = 0.00030; @ksat_l[4] = 18; 
 @ki_h[0] =  600000; @kr_h[0] = 0.00025; @ksat_h[0] = 27; 
 @ki_h[1] =  800000; @kr_h[1] = 0.00035; @ksat_h[1] = 15; 
 @ki_h[2] = 1200000; @kr_h[2] = 0.00055; @ksat_h[2] =  8; 
 @ki_h[3] = 2200000; @kr_h[3] = 0.00065; @ksat_h[3] =  5; 
 @ki_h[4] = 3200000; @kr_h[4] = 0.00085; @ksat_h[4] =  4; 
    }  
  
    # return    
    #   $tauc   
    #   @ki_l[0..4]  
    #   @ki_h[0..4]  
    #   @kr_l[0..4]  
    #   @kr_h[0..4]  
    #   @ksat_l[0..4]
    #   @ksat_h[0..4]

  }  
  else {   # $vegtype ne 'forest'...  

    if ($SoilType eq 'sand') {   
 $solthk = 400; # depth of soil surface to bottom of soil layer (mm)  
 $sand = 55;    # percentage of sand in the layer (%)   
 $clay = 10;    # percentage of clay in the layer (%)   
 $orgmat = 5;   # percentage of organic matter (by vlume) in the laye$
 $cec = 15;# cation exchange capacity in the layer (meq per 100 $
 $tauc=1.1;   
 @ki_shrub_l[0] =  105000; @ki_grass_l[0] =  150000; @ki_bare_l[0] = 4800000;
 @ki_shrub_l[1] =  217000; @ki_grass_l[1] =  231000; @ki_bare_l[1] = 7710000;
 @ki_shrub_l[2] =  306000; @ki_grass_l[2] =  366000; @ki_bare_l[2] = 1280000;
 @ki_shrub_l[3] =  439000; @ki_grass_l[3] =  407000; @ki_bare_l[3] = 1440000;
 @ki_shrub_l[4] =  661000; @ki_grass_l[4] =  611000; @ki_bare_l[4] = 2240000;
 @ki_shrub_h[0] =  253000; @ki_grass_h[0] =  480000; @ki_bare_h[0] = 4800000;
 @ki_shrub_h[1] =  549000; @ki_grass_h[1] =  771000; @ki_bare_h[1] = 7710000;
 @ki_shrub_h[2] =  795000; @ki_grass_h[2] = 1280000; @ki_bare_h[2] = 1280000;
 @ki_shrub_h[3] = 1180000; @ki_grass_h[3] = 1440000; @ki_bare_h[3] = 1440000;
 @ki_shrub_h[4] = 1820000; @ki_grass_h[4] = 2240000; @ki_bare_h[4] = 2240000;
 @kr_l[0] = 6.79e-06;  
 @kr_l[1] = 1.23e-05;  
 @kr_l[2] = 1.97e-05;  
 @kr_l[3] = 4.00e-05;  
 @kr_l[4] = 1.24e-04;  
 @kr_h[0] = 8.00e-05;  
 @kr_h[1] = 1.27e-03;  
 @kr_h[2] = 3.06e-03;  
 @kr_h[3] = 7.95e-03;  
 @kr_h[4] = 1.76e-02;  
 @ks_shrub_l[0] = 34; @ks_grass_l[0] = 27; @ks_bare_l[0] = 22;   
 @ks_shrub_l[1] = 29; @ks_grass_l[1] = 25; @ks_bare_l[1] = 21;   
 @ks_shrub_l[2] = 25; @ks_grass_l[2] = 21; @ks_bare_l[2] = 17;   
 @ks_shrub_l[3] = 23; @ks_grass_l[3] = 19; @ks_bare_l[3] = 16;   
 @ks_shrub_l[4] = 17; @ks_grass_l[4] = 16; @ks_bare_l[4] = 13;   
 @ks_shrub_h[0] = 26; @ks_grass_h[0] = 22; @ks_bare_h[0] = 22;   
 @ks_shrub_h[1] = 22; @ks_grass_h[1] = 21; @ks_bare_h[1] = 21;   
 @ks_shrub_h[2] = 20; @ks_grass_h[2] = 17; @ks_bare_h[2] = 17;   
 @ks_shrub_h[3] = 17; @ks_grass_h[3] = 16; @ks_bare_h[3] = 16;   
 @ks_shrub_h[4] = 13; @ks_grass_h[4] = 13; @ks_bare_h[4] = 13;   
    }
    if ($SoilType eq 'silt') {   
 $solthk = 400;    
 $sand = 25;  
 $clay = 15;  
 $orgmat = 5; 
 $cec = 15;   
 $tauc=2.0;   
 @ki_shrub_l[0] =  269000; @ki_grass_l[0] =  285000; @ki_bare_l[0] = 9710000;
 @ki_shrub_l[1] =  417000; @ki_grass_l[1] =  441000; @ki_bare_l[1] = 1570000;
 @ki_shrub_l[2] =  598000; @ki_grass_l[2] =  635000; @ki_bare_l[2] = 2340000;
 @ki_shrub_l[3] =  776000; @ki_grass_l[3] =  824000; @ki_bare_l[3] = 3120000;
 @ki_shrub_l[4] = 1210000; @ki_grass_l[4] = 1280000; @ki_bare_l[4] = 5080000;
 @ki_shrub_h[0] =  693000; @ki_grass_h[0] =  971000; @ki_bare_h[0] = 9710000;
 @ki_shrub_h[1] = 1110000; @ki_grass_h[1] = 1570000; @ki_bare_h[1] = 1570000;
 @ki_shrub_h[2] = 1640000; @ki_grass_h[2] = 2340000; @ki_bare_h[2] = 2340000;
 @ki_shrub_h[3] = 2170000; @ki_grass_h[3] = 3120000; @ki_bare_h[3] = 3120000;
 @ki_shrub_h[4] = 3480000; @ki_grass_h[4] = 5080000; @ki_bare_h[4] = 5080000;
 @kr_l[0] = 9.24e-05;  
 @kr_l[1] = 1.29e-04;  
 @kr_l[2] = 1.97e-04;  
 @kr_l[3] = 4.26e-04;  
 @kr_l[4] = 8.51e-04;  
 @kr_h[0] = 6.34e-04;  
 @kr_h[1] = 5.07e-03;  
 @kr_h[2] = 1.05e-02;  
 @kr_h[3] = 2.46e-02;  
 @kr_h[4] = 4.18e-02;
 @ks_shrub_l[0] = 33; @ks_grass_l[0] = 37; @ks_bare_l[0] = 31; 
 @ks_shrub_l[1] = 28; @ks_grass_l[1] = 32; @ks_bare_l[1] = 26; 
 @ks_shrub_l[2] = 22; @ks_grass_l[2] = 25; @ks_bare_l[2] = 21; 
 @ks_shrub_l[3] = 20; @ks_grass_l[3] = 23; @ks_bare_l[3] = 19; 
 @ks_shrub_l[4] = 16; @ks_grass_l[4] = 18; @ks_bare_l[4] = 15; 
 @ks_shrub_h[0] = 25; @ks_grass_h[0] = 31; @ks_bare_h[0] = 31; 
 @ks_shrub_h[1] = 22; @ks_grass_h[1] = 26; @ks_bare_h[1] = 26; 
 @ks_shrub_h[2] = 17; @ks_grass_h[2] = 21; @ks_bare_h[2] = 21; 
 @ks_shrub_h[3] = 15; @ks_grass_h[3] = 19; @ks_bare_h[3] = 19; 
 @ks_shrub_h[4] = 12; @ks_grass_h[4] = 15; @ks_bare_h[4] = 15; 
    }  
    if ($SoilType eq 'clay') {
 $solthk = 400; 
 $sand = 25;    
 $clay = 30;    
 $orgmat = 5;   
 $cec = 25;   
 $tauc = 3.27;
 @ki_shrub_l[0] =  518000; @ki_grass_l[0] =  432000; @ki_bare_l[0] = 1530000;
 @ki_shrub_l[1] =  820000; @ki_grass_l[1] =  679000; @ki_bare_l[1] = 2520000;
 @ki_shrub_l[2] = 1200000; @ki_grass_l[2] =  989000; @ki_bare_l[2] = 3810000;
 @ki_shrub_l[3] = 1580000; @ki_grass_l[3] = 1300000; @ki_bare_l[3] = 5120000;
 @ki_shrub_l[4] = 2510000; @ki_grass_l[4] = 2050000; @ki_bare_l[4] = 8470000;
 @ki_shrub_h[0] = 1400000; @ki_grass_h[0] = 1530000; @ki_bare_h[0] = 1530000;
 @ki_shrub_h[1] = 2300000; @ki_grass_h[1] = 2520000; @ki_bare_h[1] = 2520000;
 @ki_shrub_h[2] = 3460000; @ki_grass_h[2] = 3810000; @ki_bare_h[2] = 3810000;
 @ki_shrub_h[3] = 4650000; @ki_grass_h[3] = 5120000; @ki_bare_h[3] = 5120000;
 @ki_shrub_h[4] = 7660000; @ki_grass_h[4] = 8470000; @ki_bare_h[4] = 8470000;
 @kr_l[0] = 1.60e-04;  
 @kr_l[1] = 1.80e-04;  
 @kr_l[2] = 2.00e-04;  
 @kr_l[3] = 7.68e-04;  
 @kr_l[4] = 1.34e-03;  
 @kr_h[0] = 9.80e-04;  
 @kr_h[1] = 6.17e-03;  
 @kr_h[2] = 1.06e-02;  
 @kr_h[3] = 3.26e-02;  
 @kr_h[4] = 5.13e-02;  
 @ks_shrub_l[0] = 24; @ks_grass_l[0] = 20; @ks_bare_l[0] = 17;   
 @ks_shrub_l[1] = 20; @ks_grass_l[1] = 17; @ks_bare_l[1] = 14;   
 @ks_shrub_l[2] = 17; @ks_grass_l[2] = 15; @ks_bare_l[2] = 12;   
 @ks_shrub_l[3] = 14; @ks_grass_l[3] = 12; @ks_bare_l[3] = 10;   
 @ks_shrub_l[4] = 11; @ks_grass_l[4] = 10; @ks_bare_l[4] =  8;   
 @ks_shrub_h[0] = 19; @ks_grass_h[0] = 17; @ks_bare_h[0] = 17;   
 @ks_shrub_h[1] = 16; @ks_grass_h[1] = 14; @ks_bare_h[1] = 14;   
 @ks_shrub_h[2] = 13; @ks_grass_h[2] = 12; @ks_bare_h[2] = 12;   
 @ks_shrub_h[3] = 11; @ks_grass_h[3] = 10; @ks_bare_h[3] = 10;   
 @ks_shrub_h[4] =  9; @ks_grass_h[4] =  8; @ks_bare_h[4] =  8;   
    }    
    if ($SoilType eq 'loam') {  
 $solthk = 400;    
 $sand = 45;  
 $clay = 20;  
 $orgmat = 5; 
 $cec = 20;   
 $tauc = 0.04;
 @ki_shrub_l[0] =  263000; @ki_grass_l[0] =  279000; @ki_bare_l[0] = 9490000;
 @ki_shrub_l[1] =  293000; @ki_grass_l[1] =  310000; @ki_bare_l[1] = 1070000;
 @ki_shrub_l[2] =  370000; @ki_grass_l[2] =  392000; @ki_bare_l[2] = 1380000;
 @ki_shrub_l[3] =  490000; @ki_grass_l[3] =  519000; @ki_bare_l[3] = 1880000;
 @ki_shrub_l[4] =  773000; @ki_grass_l[4] =  821000; @ki_bare_l[4] = 3110000;
 @ki_shrub_h[0] =  678000; @ki_grass_h[0] =  949000; @ki_bare_h[0] = 9490000;
 @ki_shrub_h[1] =  759000; @ki_grass_h[1] = 1070000; @ki_bare_h[1] = 1070000;
 @ki_shrub_h[2] =  977000; @ki_grass_h[2] = 1380000; @ki_bare_h[2] = 1380000;
 @ki_shrub_h[3] = 1320000; @ki_grass_h[3] = 1880000; @ki_bare_h[3] = 1880000;
 @ki_shrub_h[4] = 2160000; @ki_grass_h[4] = 3110000; @ki_bare_h[4] = 3110000;
 @kr_l[0] = 6.50e-05;  
 @kr_l[1] = 9.50e-05;
 @kr_l[2] = 2.10e-04;
 @kr_l[3] = 3.35e-04;
 @kr_l[4] = 5.90e-04;
 @kr_h[0] = 4.80e-04;
 @kr_h[1] = 4.23e-03;
 @kr_h[2] = 1.09e-02;
 @kr_h[3] = 2.19e-02;
 @kr_h[4] = 3.55e-02;
 @ks_shrub_l[0] = 32; @ks_grass_l[0] = 24; @ks_bare_l[0] = 20; 
 @ks_shrub_l[1] = 27; @ks_grass_l[1] = 18; @ks_bare_l[1] = 15; 
 @ks_shrub_l[2] = 21; @ks_grass_l[2] = 10; @ks_bare_l[2] =  9; 
 @ks_shrub_l[3] = 19; @ks_grass_l[3] = 10; @ks_bare_l[3] =  8; 
 @ks_shrub_l[4] = 16; @ks_grass_l[4] =  8; @ks_bare_l[4] =  7; 
 @ks_shrub_h[0] = 24; @ks_grass_h[0] = 20; @ks_bare_h[0] = 20; 
 @ks_shrub_h[1] = 21; @ks_grass_h[1] = 15; @ks_bare_h[1] = 15; 
 @ks_shrub_h[2] = 17; @ks_grass_h[2] =  9; @ks_bare_h[2] =  9; 
 @ks_shrub_h[2] = 17; @ks_grass_h[2] =  9; @ks_bare_h[2] =  9; 
 @ks_shrub_h[3] = 15; @ks_grass_h[3] =  8; @ks_bare_h[3] =  8; 
 @ks_shrub_h[4] = 12; @ks_grass_h[4] =  7; @ks_bare_h[4] =  7; 
    }  # #SoilType   
  
    # return
    #   $tauc   
    #   @ki_l[0..4]  
    #   @ki_h[0..4]  
    #   @kr_l[0..4]  
    #   @kr_h[0..4]  
    #   @ksat_l[0..4]
    #   @ksat_h[0..4]
  
    $pshrub = $shrub / 100;   
    $pgrass = $grass / 100;   
    $pbare = $bare / 100; 

    for ($i=0; $i<5; $i++) {
 @ki_l[$i]   = $pshrub * @ki_shrub_l[$i] + $pgrass * @ki_grass_l[$i] + $pbare * @ki_bare_l[$i];
 @ki_h[$i]   = $pshrub * @ki_shrub_h[$i] + $pgrass * @ki_grass_h[$i] + $pbare * @ki_bare_h[$i];
 @kr_l[$i]   = $pshrub * @kr_l[$i] + $pgrass * @kr_l[$i] + $pbare * @kr_l[$i];
 @kr_h[$i]   = $pshrub * @kr_h[$i] + $pgrass * @kr_h[$i] + $pbare * @kr_h[$i];
 @ksat_l[$i] = $pshrub * @ks_shrub_l[$i] + $pgrass * @ks_grass_l[$i] + $pbare * @ks_bare_l[$i];
 @ksat_h[$i] = $pshrub * @ks_shrub_h[$i] + $pgrass * @ks_grass_h[$i] + $pbare * @ks_bare_h[$i];
    }
#    $, = '  ';    
#    print 'Ki_l ', @ki_l,"\n";  
#    print 'Kr_l ', @kr_l,"\n";  
#    print 'Ksat_l ', @ksat_l,"\n";   

  }# $vegtype 
}    


sub ReadParse {   

# ReadParse -- from cgi-lib.pl (Steve Brenner) from Eric Herrmann's   
# "Teach Yourself CGI Programming With PERL in a Week" p. 131    

# Reads GET or POST data, converts it to unescaped text, and puts
# one key=value in each member of the list "@in"   
# Also creates key/value pairs in %in, using '\0' to separate multiple
# selections  

   local (*in) = @_ if @_;  
   local ($i, $loc, $key, $val);
#  read text 
   if ($ENV{'REQUEST_METHOD'} eq "GET") { 
    $in = $ENV{'QUERY_STRING'};
   }
   elsif ($ENV{'REQUEST_METHOD'} eq "POST") {  
    read(STDIN,$in,$ENV{'CONTENT_LENGTH'});   
   } 
   @in = split(/&/,$in);
   foreach $i (0 .. $#in) { 
    $in[$i] =~ s/\+/ /g;    # Convert pluses to spaces 
    ($key, $val) = split(/=/,$in[$i],2);    # Split into key and value    
    $key =~ s/%(..)/pack("c",hex($1))/ge;   # Convert %XX from hex number$
    $val =~ s/%(..)/pack("c",hex($1))/ge;
    $in{$key} .= "\0" if (defined($in{$key}));  # \0 is the multiple separator 
    $in{$key} .= $val; 
   } 
   return 1;  
}
