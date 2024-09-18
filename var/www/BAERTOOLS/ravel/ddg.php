<?php

	# ------- The graph values in the form of associative array

# https://forest.moscowfsl.wsu.edu/BAERTOOLS/ravel/DEMdepGraphXY.php?x=12&file=ravel-2265&s=1
# https://forest.moscowfsl.wsu.edu/BAERTOOLS/ravel/DEMdepGraphXY.php?y=12&file=ravel-2265

# get filename to read
# get or determine data type
# get x
# get y
# get s

$str = $_SERVER['QUERY_STRING'];

# https://www.php.net/manual/en/function.parse-str.php

# $str = "file=9955&x=0&y=25";

parse_str($str, $output);

# echo $output['file'];
# echo $output['x'];
# echo $output['y'];
# echo $output['s'];

$filebase = $output['file'];
$ELEVfile = 'working/' . $filebase . '.DEM';
$DEPfile  = 'working/' . $filebase . '.depgrd.txt';

# echo $DEMfile;

  $headers = 6;
# $targety = 35;
  $synch   = $output['s'];
  $targetx = $output['x'];
  $targety = $output['y'];
  $targy = $targety;

if ($synch) {               ###############  SYNCHRONIZE SCALING  ###########

     $minElev= 99999;
     $maxElev=-99999;
//  open ELEVATION file
     $file = fopen($ELEVfile, "r") or exit("Unable to open file!");
//    read header lines
     $line = fgets($file);              # NCOLS 42
       $pieces = explode(" ", $line);
       $cols =$pieces[1]; 
     $line = fgets($file);              # NROWS 41
       $pieces = explode(" ", $line);
       $rows=$pieces[1];
     $line = fgets($file);              # XLLCORNER 276826.32
     $line = fgets($file);              # YLLCORNER 3833378.9
     $line = fgets($file);              # CELLSIZE 10
     $line = fgets($file);              # NODATA_VALUE -9999

     for ($i=0; $i<$rows; $i++) {
       $line = fgets($file);
      $pieces = explode(" ", $line);
# $pieces = preg_split('/\d+/', $line);

$minElevThisRow = 99999;
foreach ($pieces as $valyou) {
 if (is_numeric($valyou) && $valyou < $minElevThisRow) {
 $minElevThisRow = $valyou;
 }
}

#       $minElevThisRow = min($pieces);

echo " minElevThisRow: " . $minElevThisRow;
       $maxElevThisRow=max($pieces);
echo " maxElevThisRow: " . $maxElevThisRow . "<br>\n";
       if ($minElevThisRow<$minElev) $minElev=$minElevThisRow;
       if ($maxElevThisRow>$maxElev) $maxElev=$maxElevThisRow;
     }
     fclose($file);

     $minDep=9999999;
     $maxDep=-99999;
//  open DEPOSITION file
     $file = fopen($DEPfile, "r") or exit("Unable to open file!");
//    read header lines
     $line = fgets($file);              # NCOLS 42
     $line = fgets($file);              # NROWS 41
       $pieces = explode(" ", $line);
       $rows=$pieces[1];
     $line = fgets($file);              # XLLCORNER 276826.32
     $line = fgets($file);              # YLLCORNER 3833378.9
     $line = fgets($file);              # CELLSIZE 10
     $line = fgets($file);              # NODATA_VALUE -9999

     for ($i=0; $i<$rows; $i++) {
       $line = fgets($file);
       $pieces = explode(" ", $line);
       $minDepThisRow=min($pieces);
       $maxDepThisRow=max($pieces);
       if ($minDepThisRow<$minDep) $minDep=$minDepThisRow;
       if ($maxDepThisRow>$maxDep) $maxDep=$maxDepThisRow;
     }
}		###############  SYNCH ###########


if ($targety <> '') {
  $targety = $targety+$headers;

//  open ELEVATION file

#  $ELEVfile = "ravel-9955.DEM";
   $file = fopen($ELEVfile, "r") or exit("Unable to open file!");
//    read line $targety
     for ($i=1; $i<=$targety; $i++) {
       fgets($file);
     }
     $line = fgets($file);
   fclose($file);
//    explode line n
//    put into associative array
   $pieces = explode(" ", $line);
   $values=array();
   for ($i=1; $i<count($pieces); $i++) {
     $values[$i-1] = $pieces[$i-1];
   }

//  open DEPOSITION file

#   $DEPfile = "ravel-9955.depgrd.txt";
   $file = fopen($DEPfile, "r") or exit("Unable to open file!");
     for ($i=1; $i<=$targety; $i++) {
       fgets($file);
     }
     $line = fgets($file);
   fclose($file);
   $deps = explode(" ", $line);

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

	$total_bars=count($values);
 
	# -------  Define Colors ----------------
	$line_color      =imagecolorallocate($img,0,64,128);
	$background_color=imagecolorallocate($img,240,240,255);
	$border_color    =imagecolorallocate($img,200,200,200);
	$axis_color      =imagecolorallocate($img,220,220,220);
 
	# ------ Create the border around the graph ------

	imagefilledrectangle($img,1,1,$img_width-2,$img_height-2,$border_color);
	imagefilledrectangle($img,$marginl,$marginl,$img_width-1-$marginl,$img_height-1-$marginb,$background_color);

	# ------- Max value is required to adjust the scale	-------
        if ($synch) {
          $max_value=$maxElev;
          $min_value=$minElev;
        }
        else {
          $max_value=max($values);
	  $min_value=min($values);
        }
        $my_range=$max_value-$min_value;
        if ($my_range<0.001) $my_range=0.001;
	$xratio = $graph_width/count($values);
	$yratio = $graph_height/$my_range;
 
	# -------- Create scale and axis lines  --------
        $min_axis = floor($min_value);
        $max_axis = ceil($max_value);
        $range    = $max_value - $min_value;
        $step = $range / 20;
	for ($i=$min_axis;$i<$max_axis;$i=$i+$step){
          $y=$img_height - ($marginb + ($i - $min_value) * $yratio); 
          imageline($img,$marginl,$y,$img_width-$marginl,$y,$axis_color);
	  $v=intval($i);
	  imagestring($img,0,5,$y-5,$v,$line_color);
	}

	# -------- Create graph labeling  --------
        $v = "Elevation (deposition)";
        imagestring($img,4,$marginl+5,5,"W",$line_color);
        imagestring($img,4,$img_width-$marginr-30,5,"E",$line_color);
        imagestring($img,5,$img_width/4,5,"Elevation (deposition)",$line_color);
        imagestring($img,1,$marginl+5,$img_height-15,$filebase,$line_color);
        $v = 'Row ' . $targy . ' min ' . $minElev . ' max ' . $maxElev;
        imagestring($img,1,$img_width/2,$img_height-15,$v,$line_color);

	# ----------- Draw the line ------
	list($key,$value)=each($values); 
        $x0 = $marginl;
	$y0 = $img_height - ($marginb + ($value - $min_value) * $yratio);
	$yb = $img_height - ($marginb);
        if ($synch) {
          $min_dep = $minDep;
          $max_dep = $maxDep;
        }
        else {
          $min_dep = min($deps);
          $max_dep = max($deps);
        }
        $rangedep = $max_dep - $min_dep;

	for($i=1;$i< $total_bars; $i++){ 
	  # ------ Extract key and value pair from the current pointer position
	  list($key,$value)=each($values); 
	  $x = $i * $xratio + $marginl;
	  $y = $img_height - ($marginb + ($value - $min_value) * $yratio);
	  imageline($img,$x0,$y0,$x,$y,$line_color);

          $dep = $deps[$i];
          if ($dep < 0) $dep = 0;
          $z = ($dep-$min_dep)/$rangedep;
          if ($z<0) $z=0;
          if ($z>1) $z=1;
#         $z = 1-$z;
          $z = 255*$z;
#         $z_hex = sprintf "%lx", $z;
#         $color='#00'.$z_hex.'00';
          $dep_color=imagecolorallocate($img,$z,0,0);
          if ($dep == 0) $dep_color=imagecolorallocate($img,200,200,200);

          imagefilledrectangle($img,$x-1,$yb,$x+1,$y,$dep_color);
          $x0 = $x;
          $y0 = $y;
	}

}

# ================================  N-S  ========================================

if ($targetx <> '' AND $targety == '') {

//  open ELEVATION file

#  $ELEVfile = "ravel-9955.DEM";
   $file = fopen($ELEVfile, "r") or exit("Unable to open file!");
//    read header lines
   $values=array();
     $line = fgets($file);		# NCOLS 42
     $line = fgets($file);		# NROWS 41
       $pieces = explode(" ", $line);
       $rows=$pieces[1];
     $line = fgets($file);		# XLLCORNER 276826.32
     $line = fgets($file);		# YLLCORNER 3833378.9
     $line = fgets($file);		# CELLSIZE 10
     $line = fgets($file);		# NODATA_VALUE -9999

     for ($i=0; $i<$rows; $i++) {
       $line = fgets($file);
//     explode line n
//     put into associative array
       $pieces = explode(" ", $line);
       $values[$i] = $pieces[$targetx];
     }

   fclose($file);

//  open DEPOSITION file

#   $DEPfile = "ravel-9955.depgrd.txt";
   $file = fopen($DEPfile, "r") or exit("Unable to open file!");
#    for ($i=1; $i<=$targetx; $i++) {
#      fgets($file);
#    }
     $line = fgets($file);              # NCOLS 42
     $line = fgets($file);              # NROWS 41
     $line = fgets($file);              # XLLCORNER 276826.32
     $line = fgets($file);              # YLLCORNER 3833378.9
     $line = fgets($file);              # CELLSIZE 10
     $line = fgets($file);              # NODATA_VALUE -9999

     for ($i=0; $i<$rows; $i++) {
       $line = fgets($file);
//     explode line n
//     put into associative array
       $pieces = explode(" ", $line);
       $deps[$i] = $pieces[$targetx];
     }
   fclose($file);

#   $deps = explode(" ", $line);
#   $depvalues=array();
#   for ($i=1; $i<count($deps); $i++) {
#     $depvalues[$i-1] = $deps[$i-1];
#   }

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

	$total_bars=count($values);
 
	# -------  Define Colors ----------------
	$line_color      =imagecolorallocate($img,0,64,128);
	$background_color=imagecolorallocate($img,240,240,255);
	$border_color    =imagecolorallocate($img,200,200,200);
	$axis_color      =imagecolorallocate($img,220,220,220);
 
	# ------ Create the border around the graph ------

	imagefilledrectangle($img,1,1,$img_width-2,$img_height-2,$border_color);
	imagefilledrectangle($img,$marginl,$marginl,$img_width-1-$marginl,$img_height-1-$marginb,$background_color);

	# ------- Max value is required to adjust the scale	-------
        if ($synch) {
          $max_value=$maxElev;
          $min_value=$minElev;
        }
        else {
          $max_value=max($values);
          $min_value=min($values);
        }
#	$max_value=max($values);
#	$min_value=min($values);
	$xratio= $graph_width/count($values);
	$yratio= $graph_height/($max_value-$min_value);
 
	# -------- Create scale and axis lines  --------
        $min_axis = floor($min_value);
        $max_axis = ceil($max_value);
        $range    = $max_value - $min_value;
        $step = $range / 20;
	for ($i=$min_axis;$i<$max_axis;$i=$i+$step){
          $y=$img_height - ($marginb + ($i - $min_value) * $yratio); 
          imageline($img,$marginl,$y,$img_width-$marginl,$y,$axis_color);
	  $v=intval($i);
	  imagestring($img,0,5,$y-5,$v,$line_color);
	}
 
	# -------- Create graph labeling  --------
        $v = "Elevation (deposition)";
        imagestring($img,4,$marginl+5,5,"N",$line_color);
        imagestring($img,4,$img_width-$marginr-30,5,"S",$line_color);
        imagestring($img,5,$img_width/4,5,"Elevation (deposition)",$line_color);
        imagestring($img,1,$marginl+5,$img_height-15,$filebase,$line_color);
        $v = 'Col ' . $targetx;
        imagestring($img,1,$img_width/2,$img_height-15,$v,$line_color);

	# ----------- Draw the line ------
	list($key,$value)=each($values); 
        $x0 = $marginl;
	$y0 = $img_height - ($marginb + ($value - $min_value) * $yratio);
	$yb = $img_height - ($marginb);
	for($i=1;$i< $total_bars; $i++){ 
	  # ------ Extract key and value pair from the current pointer position
	  list($key,$value)=each($values); 
	  $x = $i * $xratio + $marginl;
	  $y = $img_height - ($marginb + ($value - $min_value) * $yratio);
	  imageline($img,$x0,$y0,$x,$y,$line_color);

if ($synch) {
  $min_dep = $minDep;
  $max_dep = $maxDep;
}
else {
          $min_dep = min($deps);
          $max_dep = max($deps);
}
          $rangedep = $max_dep - $min_dep;

          $dep = $deps[$i];
          if ($dep < 0) $dep = 0;
          $z = ($dep-$min_dep)/$rangedep;
          if ($z<0) $z=0;
          if ($z>1) $z=1;
#         $z = 1-$z;
          $z = 255*$z;
#         $z_hex = sprintf "%lx", $z;
#         $color='#00'.$z_hex.'00';
          $dep_color=imagecolorallocate($img,$z,0,0);
          if ($dep == 0) $dep_color=imagecolorallocate($img,200,200,200);

          imagefilledrectangle($img,$x-1,$yb,$x+1,$y,$dep_color);
          $x0 = $x;
          $y0 = $y;
	}

}
#	header("Content-type:image/png");
#	imagepng($img);

?>
