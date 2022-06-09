<html>
 <head>
 </head>
 <body vlink=green link=black>
  <font face="trebuchet, tahoma, arial, sans serif">

<?php

    $fs_email = $_POST["fs_email"]; if ($fs_email == '') {$fs_email = "sbear";}
    $user     = $_POST["user"];
    $location = $_POST["location"]; if ($location == '') {$location = '0';}
    $pointsw  = $_POST["pointsw"];
    $pointso  = $_POST["pointso"];

## The Commify Function
# http://code.activestate.com/recipes/202051-php-commify-function/
function commify ($str) {
        $n = strlen($str);
        if ($n <= 3) {
                $return=$str;
        }
        else {
                $pre=substr($str,0,$n-3);
                $post=substr($str,$n-3,3);
                $pre=commify($pre);
                $return="$pre,$post";
        }
        return($return);
}

echo "
   <br>
   <table border=0>
    <tr bgcolor=lightgreen>
     <th>Location</th><th>Players<br>(employees)</th><th>Percent<br>participation</th><th>%</th><th><font color=gold>High</font> <font color=green>Total</font> Points</th><th><font size=-2>Individual High | Location Total<br>Points</font></th>
    </tr>
";

$i=0;

#  <option value="1"   >Albuquerque</option>			 8
#  <option value="2"   >Aldo Leopold</option>			 8
#  <option value="3"   >Boise FSL</option>			23
#  <option value="4"   >Bozeman</option>			 5
#  <option value="5"   >FIA Data Collection Team</option>	49
#  <option value="6"   >Flagstaff FSL</option>			20
#  <option value="7"   >Fort Collins</option>			56
#  <option value="8"   >Logan</option>				 8
#  <option value="9"   >Missoula FiSL</option>			53
#  <option value="10"  >Missoula FoSL</option>			34
#  <option value="11"  >Moscow FSL</option>			29
#  <option value="12"  >FIA Ogden</option>			44
#  <option value="13"  >Provo</option>				 8
#  <option value="14"  >Rapid City</option>			 5
#  <option value="15"  >Reno FSL</option>			 0

$loc = array('Unspecified','Albuquerque','Aldo Leopold','Boise','Bozeman','FIA Data Collection','Flagstaff','Fort Collins','Logan','Missoula FiSL','Missoula FoSL','Moscow FSL','Ogden','Provo','Rapid City');
$emp = array(0,8,8,23,5,49,20,56,8,53,34,29,44,8,5);

foreach ($loc as &$location) {
    $players = 0;
    $high = 0;
    $sum = 0;
    $blob='data/'.$i.'_*.txt';
//    foreach (glob("data/$i_*.txt") as $filename) {
    foreach (glob($blob) as $filename) {

//       echo "$filename size " . filesize($filename) . "<br>\n";

          $fs_email = "";     // dehall
          $user     = "";     // David Hall
          $loca     = "";     // Moscow FSL
          $pointsw  = 0;     // 450
          $pointso  = 0;     // 0

       $handle = fopen($filename, "r");

       if ($handle) {
          $fs_email = fgets($handle);     // dehall
          $user     = fgets($handle);     // David Hall
          $loca     = fgets($handle);     // Moscow FSL
          $pointsw  = fgets($handle);     // 450
          $pointso  = fgets($handle);     // 0
          fclose($handle);

          $fs_email = trim($fs_email);

//   open file, read pontsw and pointso
         $points = $pointsw + $pointso;
         if ($points > $high) {$high = $points; $high_name = $fs_email;}
         $sum = $sum + $points;
         $players++;
       }
    }
    $c_high    = commify($high); $c_sum = commify($sum);
    $scale     = 0.005;
    $width     = $sum * $scale;
    $width_ind = $high * $scale;
    $width_2   = $width - $width_ind;
    $employees = $emp[$i];
    $percent = 0;
    if ($employees > 0) {    $percent   = round (100*($players / $employees));     }
    $width_pct = $percent;
    echo
"    <tr>
      <th align=left bgcolor=lightgreen><a href=\"location.php?loc=$i\">$location</a></th>
      <td align=right>$players / $employees</td>
      <td align=right>$percent</td>
      <td align=right><img src=\"green.gif\" width=$width_pct height=20 title=\"$percent% participation\"></td>
      <td align=left><img src=\"gold.gif\" width=$width_ind height=20 title=\"$high_name: $c_high pts\"><img src=\"green.gif\" width=$width_2 height=20 title=\"$location total: $c_sum pts\"></td>
      <td align=center><font size=-2>$c_high | $c_sum</font></td>
     </tr>
";
    $i++;
}
unset($value); // break the reference with the last element

?>

  </table>
 </body>
</html>
