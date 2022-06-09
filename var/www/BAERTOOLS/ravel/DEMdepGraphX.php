<?php

	# ------- The graph values in the form of associative array

# get filename to read
# get or determine data type
# get X
# get Y

$str = $_SERVER['QUERY_STRING'];

# http://www.php.net/manual/en/function.parse-str.php

# $str = "file=9955&x=0&y=25";

parse_str($str, $output);

# echo $output['file'];
# echo $output['x'];
# echo $output['y'];

$ELEVfile = 'working/' . $output['file'] . '.DEM';
$DEPfile  = 'working/' . $output['file'] . '.depgrd.txt';

# echo $DEMfile;

# $target = 35;
  $target = $output['x'];

$target = $target+5;


//  open ELEVATION file

#  $ELEVfile = "ravel-9955.DEM";
   $file = fopen($ELEVfile, "r") or exit("Unable to open file!");
//    read line $target
     for ($i=1; $i<=$target; $i++) {
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
//    read line $target
     for ($i=1; $i<=$target; $i++) {
       fgets($file);
     }
     $line = fgets($file);
   fclose($file);
//    explode line n

   $deps = explode(" ", $line);
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
#        $gap=0;
 
	# -------  Define Colors ----------------
	$line_color      =imagecolorallocate($img,0,64,128);
	$background_color=imagecolorallocate($img,240,240,255);
	$border_color    =imagecolorallocate($img,200,200,200);
	$axis_color      =imagecolorallocate($img,220,220,220);
 
	# ------ Create the border around the graph ------

	imagefilledrectangle($img,1,1,$img_width-2,$img_height-2,$border_color);
	imagefilledrectangle($img,$marginl,$marginl,$img_width-1-$marginl,$img_height-1-$marginb,$background_color);

	# ------- Max value is required to adjust the scale	-------
	$max_value=max($values);
	$min_value=min($values);
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

          $min_dep = min($deps);
          $max_dep = max($deps);
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

	header("Content-type:image/png");
	imagepng($img);

?>
