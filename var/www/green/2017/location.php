<html>
 <head>
 </head>
 <body>
  <font face="trebuchet, tahoma, arial, sans serif">
   <br>
   <table>
    <tr>
     <th valign=top>
      <form action=location.php method=get>
       Select Location<br>
       <select size=15 name="loc">
        <option value="1"   >Albuquerque</option>
        <option value="2"   >Aldo Leopold</option>
        <option value="3"   >Boise FSL</option>
        <option value="4"   >Bozeman</option>
        <option value="5"   >Flagstaff FSL</option>
        <option value="6"   >Fort Collins</option>
        <option value="7"   >Logan</option>
        <option value="8"   >Missoula FiSL</option>
        <option value="9"   >Missoula FoSL</option>
        <option value="10"  >Moscow FSL</option>
        <option value="11"  >Ogden</option>
        <option value="12"  >Provo</option>
        <option value="13"  >Rapid City</option>
        <option value="0"   >Station-wide</option>
       </select>
       <br><br>
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

  $loca = array('','Albuquerque','Aldo Leopold','Boise','Bozeman','Flagstaff','Fort Collins','Logan','Missoula FiSL','Missoula FoSL','Moscow','Ogden','Provo','Rapid City');
  echo "

      <table border=0>
       <tr bgcolor=pink>
        <th>Player</th>
        <th>Location</th>
        <th colspan=2>Green Points</th>
       </tr>
";

// $loc = array('Unspecified','Albuquerque','Boise','Bozeman','Data Collection','Flagstaff','Fort Collins','Logan','Missoula FoSL','Missoula FSL','Moscow','Ogden','Provo','Rapid City','Reno');
// foreach ($loc as &$location) {

    $i = 0;
    $players = 0;
    $high = 0;
    $sum = 0;
    $blob='data/'.$loc.'_*.txt';
    if ($loc==0) {$blob='data/*.txt';}

//    foreach (glob("data/$i_*.txt") as $filename) {

    foreach (glob($blob) as $filename) {

  //     echo "$filename size " . filesize($filename) . "<br>\n";

          $fs_email = "";    // dehall
          $user     = "";    // David Hall
          $locnum   = "";    // 11
          $pointsw  = 0;     // 450
          $pointso  = 0;     // 0

//   open file, read pointsw and pointso

       $handle = fopen($filename, "r");
       if ($handle) {
         $fs_email = fgets($handle);     // dehall
         $user     = fgets($handle);     // David Hall
         $locnum   = fgets($handle);     // 11
         $pointsw  = fgets($handle);     // 450
         $pointso  = fgets($handle);     // 0
         fclose($handle);

         $fs_email = trim($fs_email);
         $pointsw = trim($pointsw);
         $pointso = trim($pointso);

         $points = $pointsw + 1 * $pointso;
         if ($points > $high) {$high = $points; $high_name = $fs_email;}
         $sum = $sum + $points;
         $scale = 0.01;
         $width = $points * $scale;
         $players++;
         $c_points = commify($points);
         $location_name = $loca[$locnum*1];
         echo "
       <tr>
        <td>$fs_email</td>
        <td>$location_name</td>
        <td align=right title='$pointsw + $pointso'> $c_points</td>
        <td align=left><img src=green.gif width=$width height=20 title=\"$c_points Green Points\"></td>
       </tr>
";
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
   <h4><a href="stats.php">Station stats</a></h4>
  <font>
 </body>
</html>
