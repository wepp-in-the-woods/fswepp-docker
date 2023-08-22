<?php

	# ------- The graph values in the form of associative array

# http://forest.moscowfsl.wsu.edu/BAERTOOLS/ravel/DEMprodGraphXYS.php?x=12&file=ravel-2265&s=1
# http://forest.moscowfsl.wsu.edu/BAERTOOLS/ravel/DEMprodGraphXYS.php?y=12&file=ravel-2265

# get filename to read
# get or determine data type
# get x
# get y
# get s

# $str = "file=ravel-9955&x=0&y=25";

  $str = $_SERVER['QUERY_STRING'];	# http://www.php.net/manual/en/function.parse-str.php
  parse_str($str, $output);

# echo $output['file'];
# echo $output['x'];
# echo $output['y'];
# echo $output['s'];

  $filebase = $output['file'];
  $ELEVfile = 'working/' . $filebase . '.DEM';
  $DATAfile  = 'working/' . $filebase . '.prodgrd.txt';

  $headers = 6;
# $targety = 35;

  $synch   = $output['s'];
  $targetx = $output['x'];
  $targety = $output['y'];
  $targy = $targety;

  if ($synch) {               ###############  SYNCHRONIZE SCALING  ###########
//  open ELEVATION file
     $file = fopen($ELEVfile, "r") or exit("Unable to open elevation file!");
//  read header lines
     $line = fgets($file);              # NCOLS 42
     $line = fgets($file);              # NROWS 41
       $pieces = explode(" ", $line);
       $rows=$pieces[1];
     $line = fgets($file);              # XLLCORNER 276826.32
     $line = fgets($file);              # YLLCORNER 3833378.9
     $line = fgets($file);              # CELLSIZE 10
     $line = fgets($file);              # NODATA_VALUE -9999

     $minElev= 99999;
     $maxElev=-99999;
     for ($i=0; $i<$rows; $i++) {
       $line = fgets($file);
       $pieces = explode(" ", $line);
#      $minElevThisRow=min($pieces);		# http://php.net/manual/en/function.min.php
       $maxElevThisRow =-99999;
       $minElevThisRow = 99999;
       foreach ($pieces as $valyou) {
         if (is_numeric($valyou) && $valyou < $minElev) { $minElev = $valyou; }
         if (is_numeric($valyou) && $valyou > $maxElev) { $maxElev = $valyou; }
       }
     }
     fclose($file);

//  open DATA file
     $file = fopen($DATAfile, "r") or exit("Unable to open data file!");
//    read header lines
     $line = fgets($file);              # NCOLS 42
     $line = fgets($file);              # NROWS 41
       $pieces = explode(" ", $line);
       $rows=$pieces[1];
     $line = fgets($file);              # XLLCORNER 276826.32
     $line = fgets($file);              # YLLCORNER 3833378.9
     $line = fgets($file);              # CELLSIZE 10
     $line = fgets($file);              # NODATA_VALUE -9999

     $minData= 99999;
     $maxData=-99999;
     for ($i=0; $i<$rows; $i++) {
       $line = fgets($file);
       $pieces = explode(" ", $line);
       foreach ($pieces as $valyou) {
         if (is_numeric($valyou) && $valyou < $minData) { $minData = $valyou; }
#        if (is_numeric($valyou) && $valyou > $maxData) { $maxData = $valyou; }
         if (is_numeric($valyou) && $valyou > $maxData && $valyou<0) { $maxData = $valyou; }
       }
     }
     fclose($file);
  }		###############  SYNCH ###########

# ================================  W-E  ========================================

if ($targety <> '') {
  $targety = $targety+$headers;

//  open ELEVATION file

#  $ELEVfile = "ravel-9955.DEM";
   $file = fopen($ELEVfile, "r") or exit("Unable to open elevation file!");
// read line $targety
     for ($i=1; $i<=$targety; $i++) {
       fgets($file);
     }
     $line = fgets($file);
   fclose($file);
// explode line n
// put into associative array

   $pieces = explode(" ", $line);
   $elevs=array();
   for ($i=1; $i<count($pieces); $i++) { $elevs[$i-1] = $pieces[$i-1]; }

#   $elevs = explode(" ", $line);

   if ($synch) {
     $min_elev=$minElev;
     $max_elev=$maxElev;
   }
   else {
     $min_elev = 99999;
     $max_elev =-99999;
     foreach ($elevs as $valyou) {
       if (is_numeric($valyou) && $valyou < $min_elev) { $min_elev = $valyou; }
       if (is_numeric($valyou) && $valyou > $max_elev) { $max_elev = $valyou; }
     }
   }

//  open DATA file

#   $DATAfile = "ravel-9955.prodgrd.txt";
   $file = fopen($DATAfile, "r") or exit("Unable to open data file!");
     for ($i=1; $i<=$targety; $i++) { fgets($file); }
     $line = fgets($file);
   fclose($file);
   $values = explode(" ", $line);
   if ($synch) {
     $min_val = $minData;
     $max_val = $maxData;
   }
   else {
     $min_val = 99999;
     $max_val =-99999;
     foreach ($values as $valyou) {
       if (is_numeric($valyou) && $valyou < $min_val) { $min_val = $valyou; }
       if (is_numeric($valyou) && $valyou > $max_val && $valyou<0) { $max_val = $valyou; }
#          $max_r = @cell[$col] if((@cell[$col] > $max_r) && @cell[$col]<0)
     }
   }
   $rangeval = $max_val - $min_val;

	$img_width=450;
	$img_height=300; 
	$margins=20;
        $marginl = 30;
        $marginr = 10;
        $marginb = 20;
        $margint = 10;
 
	# ---- Find the size of graph by substracting the size of borders
	$graph_width =$img_width  - $marginl - $marginr;
	$graph_height=$img_height - $marginb - $margint; 
	$img=imagecreate($img_width,$img_height);

	$total_bars=count($elevs);
 
	# -------  Define Colors ----------------
	$line_color      =imagecolorallocate($img,0,64,128);
	$background_color=imagecolorallocate($img,240,240,255);
	$border_color    =imagecolorallocate($img,200,200,200);
	$axis_color      =imagecolorallocate($img,220,220,220);
 
	# ------ Create the border around the graph ------

	imagefilledrectangle($img,1,1,$img_width-2,$img_height-2,$border_color);
	imagefilledrectangle($img,$marginl,$marginl,$img_width-1-$marginl,$img_height-1-$marginb,$background_color);

	# ------- Max value is required to adjust the scale	-------
        $my_range=$max_elev-$min_elev;
        if ($my_range<0.001) $my_range=0.001;
	$xratio = $graph_width/count($elevs);
	$yratio = $graph_height/$my_range;
 
	# -------- Create scale and axis lines  --------
        $min_axis = floor($min_elev);
        $max_axis = ceil($max_elev);
        $range    = $max_elev - $min_elev;
        $step = $range / 20;
	for ($i=$min_axis;$i<$max_axis;$i=$i+$step){
          $y=$img_height - ($marginb + ($i - $min_elev) * $yratio); 
          imageline($img,$marginl,$y,$img_width-$marginl,$y,$axis_color);
	  $v=intval($i);
	  imagestring($img,0,5,$y-5,$v,$line_color);
	}

	# -------- Create graph labeling  --------
        $v = "Elevation (production)";
        imagestring($img,4,$marginl+5,5,"W",$line_color);
        imagestring($img,4,$img_width-$marginr-30,5,"E",$line_color);
        imagestring($img,5,$img_width/4,5,"Elevation (production)",$line_color);
        imagestring($img,1,$marginl+5,$img_height-15,$filebase,$line_color);
#        $v = 'Row ' . $targy . ' min ' . $min_val . ' max ' . $max_val;
#        imagestring($img,1,$img_width/2,$img_height-15,$v,$line_color);

	# ----------- Draw the elevation line ------
	list($key,$elev)=each($elevs);
        $x0 = $marginl;
	$y0 = $img_height - ($marginb + ($elev - $min_elev) * $yratio);
	$yb = $img_height - ($marginb);
        $range = $max_elev - $min_elev;

	for($i=1;$i< $total_bars; $i++){ 
	  # ------ Extract key and value pair from the current pointer position
	  list($key,$elev)=each($elevs);
	  $x = $i * $xratio + $marginl;
	  $y = $img_height - ($marginb + ($elev - $min_elev) * $yratio);
	  imageline($img,$x0,$y0,$x,$y,$line_color);

          $val = $values[$i];
          $z = ($val-$min_val)/$rangeval;
          if ($z<0) $z=0;
          if ($z>1) $z=1;
          $z = 1-$z;
          $z = 255*$z;
#         $z_hex = sprintf "%lx", $z;
#         $color='#00'.$z_hex.'00';
          $val_color=imagecolorallocate($img,0,$z,0);
          if ($val == 0) $val_color=imagecolorallocate($img,200,200,200);
          imagefilledrectangle($img,$x-1,$yb,$x+1,$y,$val_color);
          $x0 = $x;
          $y0 = $y;
	}
#       $v = 'Row ' . $targy . ' min ' . $min_val . ' max ' . $max_val;
        $v = 'Row ' . $targy;
        imagestring($img,1,$img_width/2,$img_height-15,$v,$line_color);
}

# ================================  N-S  ========================================

if ($targetx <> '' AND $targety == '') {

//  open ELEVATION file

#  $ELEVfile = "ravel-9955.DEM";
   $file = fopen($ELEVfile, "r") or exit("Unable to open elevation file!");
//    read header lines
     $elevs=array();
     $line = fgets($file);		# NCOLS 42
     $line = fgets($file);		# NROWS 41
       $pieces = explode(" ", $line);
       $rows=$pieces[1];
     $line = fgets($file);		# XLLCORNER 276826.32
     $line = fgets($file);		# YLLCORNER 3833378.9
     $line = fgets($file);		# CELLSIZE 10
     $line = fgets($file);		# NODATA_VALUE -9999

     $min_elev = 99999;
     $max_elev =-99999;
     for ($i=0; $i<$rows; $i++) {
       $line = fgets($file);
       $pieces = explode(" ", $line);
# >> skip if == NODATA_VALUE ...
       if (is_numeric($pieces[$targetx])) { $elevs[$i] = $pieces[$targetx]; }
       if (is_numeric($elevs[$i]) && $elevs[$i]<$min_elev) { $min_elev = $elevs[$i]; }
       if (is_numeric($elevs[$i]) && $elevs[$i]>$max_elev) { $max_elev = $elevs[$i]; }
     }
     if ($synch) { $min_elev=$minElev; $max_elev=$maxElev; }

   fclose($file);

//  open DATA file

#  $DATAfile = "ravel-9955.prodgrd.txt";
   $file = fopen($DATAfile, "r") or exit("Unable to open data file!");
     $line = fgets($file);              # NCOLS 42
     $line = fgets($file);              # NROWS 41
     $line = fgets($file);              # XLLCORNER 276826.32
     $line = fgets($file);              # YLLCORNER 3833378.9
     $line = fgets($file);              # CELLSIZE 10
     $line = fgets($file);              # NODATA_VALUE -9999

     $min_val = 99999;
     $max_val =-99999;
     for ($i=0; $i<$rows; $i++) {
       $line = fgets($file);
       $pieces = explode(" ", $line);
       if (is_numeric($pieces[$targetx])) { $values[$i] = $pieces[$targetx]; }
       if (is_numeric($values[$i]) && $values[$i]<$min_val) { $min_val = $values[$i]; }
       if (is_numeric($values[$i]) && $values[$i]>$max_val && $values[$i]<0) { $max_val = $values[$i]; }
     }
     if ($synch) { $min_val = $minData; $max_val = $maxData; }
     $rangeval = $max_val - $min_val;
     if ($rangeval < 0.001) { $rangeval=1; }
   fclose($file);

	$img_width=450;
	$img_height=300; 
	$margins=20;
        $marginl = 30;
        $marginr = 10;
        $marginb = 20;
        $margint = 10;
 
	# ---- Find the size of graph by substracting the size of borders
	$graph_width =$img_width  - $marginl - $marginr;
	$graph_height=$img_height - $marginb - $margint; 
	$img=imagecreate($img_width,$img_height);

	$total_bars=count($elevs);
 
	# -------  Define Colors ----------------
	$line_color      =imagecolorallocate($img,0,64,128);
	$background_color=imagecolorallocate($img,240,240,255);
	$border_color    =imagecolorallocate($img,200,200,200);
	$axis_color      =imagecolorallocate($img,220,220,220);
 
	# ------ Create the border around the graph ------
	imagefilledrectangle($img,1,1,$img_width-2,$img_height-2,$border_color);
	imagefilledrectangle($img,$marginl,$marginl,$img_width-1-$marginl,$img_height-1-$marginb,$background_color);

	# ------- Max value is required to adjust the scale	-------
        $range    = $max_elev - $min_elev;
	$xratio= $graph_width/count($elevs);
	$yratio= $graph_height/$range;
 
	# -------- Create scale and axis lines  --------
        $min_axis = floor($min_elev);
        $max_axis = ceil($max_elev);
        $step = $range / 20;
	for ($i=$min_axis; $i<$max_axis; $i=$i+$step){
          $y=$img_height - ($marginb + ($i - $min_elev) * $yratio); 
          imageline($img,$marginl,$y,$img_width-$marginl,$y,$axis_color);
	  $v=intval($i);
	  imagestring($img,0,5,$y-5,$v,$line_color);
	}
 
	# -------- Create graph labeling  --------
        $v = "Elevation (production)";
        imagestring($img,4,$marginl+5,5,"N",$line_color);
        imagestring($img,4,$img_width-$marginr-30,5,"S",$line_color);
        imagestring($img,5,$img_width/4,5,"Elevation (production)",$line_color);
        imagestring($img,1,$marginl+5,$img_height-15,$filebase,$line_color);

	# ----------- Draw the line ------
	list($key,$elev)=each($elevs);
        $x0 = $marginl;
	$y0 = $img_height - ($marginb + ($elev - $min_elev) * $yratio);
	$yb = $img_height - ($marginb);
	for($i=1; $i<$total_bars; $i++){
	  # ------ Extract key and value pair from the current pointer position
	  list($key,$elev)=each($elevs);
	  $x = $i * $xratio + $marginl;
	  $y = $img_height - ($marginb + ($elev - $min_elev) * $yratio);
	  imageline($img,$x0,$y0,$x,$y,$line_color);

          $val = $values[$i];
          $z = ($val-$min_val)/$rangeval;
          if ($z<0) $z=0;
          if ($z>1) $z=1;
          $z = 1-$z;
          $z = 255*$z;
          $val_color=imagecolorallocate($img,0,$z,0);
          if ($val == 0) $val_color=imagecolorallocate($img,200,200,200);
          imagefilledrectangle($img,$x-1,$yb,$x+1,$y,$val_color);
          $x0 = $x;
          $y0 = $y;
	}
#       $v = 'Col ' . $targetx . ' min ' . $min_val . ' max ' . $max_val;
        $v = 'Col ' . $targetx;
        imagestring($img,1,$img_width/2,$img_height-15,$v,$line_color);
}
        
	header("Content-type:image/png");
	imagepng($img);
?>
