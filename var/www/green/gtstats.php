<html>
 <head>
 </head>
 <body vlink=green link=black>
  <font face="trebuchet, tahoma, arial, sans serif">
   <font size=-1>
<?php

    $fs_email = $_POST["fs_email"]; if ($fs_email == '') {$fs_email = "sbear";}
    $user     = $_POST["user"];
    $location = $_POST["location"]; if ($location == '') {$location = '0';}
    $pointsw  = $_POST["pointsw"];
    $pointso  = $_POST["pointso"];

## The Commify Function
# https://code.activestate.com/recipes/202051-php-commify-function/
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
   <table border=0 cellpadding=1 cellspacing=1>
    <tr bgcolor=lightgreen>
     <th><font size=-1>Location</th>
     <th><font size=-1>size</th>
     <th><font size=-1>players</th>
     <th><font size=-1>employees</th>
     <th><font size=-1>partic_rate</th>
     <th><font size=-1>high_player</th>
     <th><font size=-1>Indiv_high</th>
     <th><font size=-1>location_total</th>
     <th><font size=-1>location_average</th>
    </tr>
";

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

# $loc = array('Unspecified','Albuquerque','Aldo Leopold','Boise','Bozeman','FIA Data Collection','Flagstaff','Fort Collins','Logan','Missoula FiSL','Missoula FoSL','Moscow FSL','Ogden','Provo','Rapid City');
# $emp = array(0,8,8,23,5,49,20,56,8,53,34,29,44,8,5);
 $loc = array('Albuquerque','Aldo Leopold','Boise','Bozeman','FIA Data Collection','Flagstaff','Fort Collins','Logan','Missoula FiSL','Missoula FoSL','Moscow FSL','Ogden','Provo','Rapid City');
 $emp = array(8,8,23,5,49,20,56,8,53,34,29,44,8,5);

$i=0;
$allplayers=0;
$highlargelabloc="";
$highsmalllabrate=0;
$highsmalllabloc="";
$highlargelabrate=0;
$labsizebreak=20;

  foreach ($loc as &$location) {
    $high_name='';
    $j = $i+1;
    $players = 0;
    $high = 0;
    $sum = 0;
    $blob='data/'.$j.'_*.txt';
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

//   open file, read pointsw and pointso
         $points = $pointsw + $pointso;
         if ($points > $high) {$high = $points; $high_name = $fs_email;}
         $sum = $sum + $points;
         $players++;
         $allplayers++;
       }
    }
    $c_high    = commify($high); $c_sum = commify($sum);
    $scale     = 0.0025;
    $width     = $sum * $scale;
    $width_ind = $high * $scale;
    $width_2   = $width - $width_ind;
    $employees = $emp[$i];
    $percent = 0;
    $avgptsearned = 0;
    if ($employees > 0) { $percent = round (100*($players / $employees));     }
    $width_pct = $percent;
    if ($players > 0) { $avgptsearned = round ($sum / $players); }
    $width_avg_pts = $avgptsearned / 250;
    if ($employees > $labsizebreak) {
      $color = 'lightblue'; $sizenote='larger';
      $color_lab = 'lightblue.gif';
      if ($avgptsearned > $highlargelabrate) {$highlargelabrate = $avgptsearned; $highlargelabloc=$loc[$i];}
    } else {
      $color= 'pink'; $sizenote='smaller';
      $color_lab = 'pink.gif';
      if ($avgptsearned > $highsmalllabrate) {$highsmalllabrate = $avgptsearned; $highsmalllabloc=$loc[$i];}
    }
    echo
"    <tr>
      <th align=left bgcolor='$color'>\"$location\"</th>
      <th align=left bgcolor='$color'>$sizenote</th>
      <td align=right>$players</td>
      <td align=right>$employees</td>
      <td align=right>$percent%</td>
      <td align=right>$high_name</td>
      <td align=center>$c_high</td>
      <td align=center>$c_sum</td>
      <td align=right>$avgptsearned</td>
     </tr>
";
    $i++;
}

unset($value); // break the reference with the last element

?>

  </table>
  <br>

<?php echo "
  <table border=0>
   <tr><td>Total players: $allplayers</td><td></td></tr>
   <tr><td bgcolor=lightblue> Large lab maximum average points: </td><td bgcolor=lightblue> $highlargelabloc ($highlargelabrate points)</td></tr><br>
   <tr><td bgcolor=pink>      Small lab maximum average points: </td><td bgcolor=pink>      $highsmalllabloc ($highsmalllabrate points)</td></tr>
  </table>
"; ?>
 </body>
</html>
