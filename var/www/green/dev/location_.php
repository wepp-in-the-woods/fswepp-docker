<html>
 <head>
 </head>
 <body>
<table>
 <tr>
  <th>
<form action=location.php method=get>
Select Location<br>
  <select size=14 name="loc">
  <option value="1"   >Albuquerque</option>
  <option value="2"   >Boise FSL</option>
  <option value="3"   >Bozeman</option>
  <option value="4"   >Data Collection Team</option>
  <option value="5"   >Flagstaff FSL</option>
  <option value="6"   >Fort Collins</option>
  <option value="7"   >Logan</option>
  <option value="8"   >Missoula Fire Science Lab</option>
  <option value="9"   >Missoula FSL</option>
  <option value="10"  >Moscow FSL</option>
  <option value="11"  >Ogden</option>
  <option value="12"  >Provo</option>
  <option value="13"  >Rapid City</option>
  <option value="14"  >Reno FSL</option>
  </select>
  <br>
  <input type="submit" value="Go">
</form>
</th>
<th valign=top bgcolor=lightgreen>
<?php

    $loc = $_GET["loc"]; if ($loc=='') {$loc=0;}

// check numeric 0..14

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

  $loca = array('Unspecified','Albuquerque','Boise','Bozeman','Data Collection','Flagstaff','Fort Collins','Logan','Missoula FoSL','Missoula FSL','Moscow','Ogden','Provo','Rapid City','Reno');
  echo "

  <h3>$loc: $loca[$loc]</h3>

   <table border=1>
    <tr bgcolor=pink>
     <th>Name</th><th>Points</th>
    </tr>
";

$i=0;

// $loc = array('Unspecified','Albuquerque','Boise','Bozeman','Data Collection','Flagstaff','Fort Collins','Logan','Missoula FoSL','Missoula FSL','Moscow','Ogden','Provo','Rapid City','Reno');
// foreach ($loc as &$location) {
    $players = 0;
    $high = 0;
    $sum = 0;
    $blob='data/'.$loc.'_*.txt';
//    foreach (glob("data/$i_*.txt") as $filename) {
    foreach (glob($blob) as $filename) {
  //     echo "$filename size " . filesize($filename) . "<br>\n";

       $handle = fopen($filename, "r");
       if ($handle) {
          $fs_email = fgets($handle);     // dehall
          $user     = fgets($handle);     // David Hall
          $loca     = fgets($handle);     // Moscow FSL
          $pointsw  = fgets($handle);     // 450
          $pointso  = fgets($handle);     // 0
          fclose($handle);
//   open file, read pontsw and pointso
         $points = $pointsw + $pointso;
         if ($points > $high) {$high = $points; $high_name = $fs_email;}
         $sum = $sum + $points;
         $players++;
         $c_points = commify($points);
         echo "    <tr><td>$fs_email</td><td>$c_points</td></tr>\n";
       }
    }
    $i++;
//}
//unset($value); // break the reference with the last element

?>
     </table>
    </th>
   </tr>
  </table>
 </body>
</html>