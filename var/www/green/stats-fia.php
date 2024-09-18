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
     <th><font size=-1>Location</th><th colspan=2><font size=-1>Participation</th><th><font color=gold size=-1>Indiv. High</font> | <font size=-1 color=green>Total</font><font size=-1> Points</th><th><font size=-2>Individual High | Location Total<br>Points</font></th><th colspan=2><font size=-1>Average<br>points<br>earned</th>
    </tr>
";

#  <option value="1"   >Albuquerque</option>			 8
#  <option value="2"   >Aldo Leopold</option>			 8
#  <option value="3"   >Boise FSL</option>			27
#  <option value="4"   >Bozeman</option>			13
#  <option value="5"   >FIA Data Collection Team</option>	49
#  <option value="6"   >Flagstaff FSL</option>			22
#  <option value="7"   >Fort Collins</option>			86
#  <option value="8"   >Logan</option>				 8
#  <option value="9"   >Missoula FiSL</option>			57
#  <option value="10"  >Missoula FoSL</option>			47
#  <option value="11"  >Moscow FSL</option>			33
#  <option value="12"  >FIA Ogden</option>			50
#  <option value="13"  >Provo</option>				10
#  <option value="14"  >Rapid City</option>			 3

# $loc = array('Unspecified','Albuquerque','Aldo Leopold','Boise','Bozeman','FIA Data Collection','Flagstaff','Fort Collins','Logan','Missoula FiSL','Missoula FoSL','Moscow FSL','Ogden','Provo','Rapid City');
# $emp = array(0,8,8,23,5,49,20,56,8,53,34,29,44,8,5);
  $loc = array('Albuquerque','Aldo Leopold','Boise','Bozeman','FIA Data Collection','Flagstaff','Fort Collins','Logan','Missoula FiSL','Missoula FoSL','Moscow FSL','Ogden','Provo','Rapid City');
# $emp = array(8,8,23,5,49,20,56,8,53,34,29,44,8,5);
# $emp = array(8,8,23,5,50,22,86,8,54,38,33,47,8,5);
# $emp = array(8,8,23,5,50,23,86,8,54,36,34,44,8,5);
  $emp = array(8,8,27,13,49,22,86,8,57,47,33,50,10,3);

$i=0;
$allplayers=0;
$highlargelabloc="";
$highsmalllabrate=0;
$highsmalllabloc="";
$highlargelabrate=0;
$labsizebreak=20;

  foreach ($loc as &$location) {
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
#   $scale     = 0.0015;
    $scale     = 0.0005;
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
      $color = 'lightblue'; $sizenote='larger lab';
      $color_lab = 'lightblue.gif';
      if ($avgptsearned > $highlargelabrate) {$highlargelabrate = $avgptsearned; $highlargelabloc=$loc[$i];}
    } else {
      $color= 'pink'; $sizenote='smaller lab';
      $color_lab = 'pink.gif';
      if ($avgptsearned > $highsmalllabrate) {$highsmalllabrate = $avgptsearned; $highsmalllabloc=$loc[$i];}
    }
    echo
"    <tr>
      <th align=left bgcolor='$color' title='$sizenote'><font size=-1><a href=\"location.php?loc=$j\">$location</a></th>
      <td align=right title=\"$players / $employees\"><font size=-2>$players of $employees = $percent%</td>
      <td align=right><img src=\"green.gif\" width=$width_pct height=20 title=\"$percent% participation\"></td>
      <td align=left><img src=\"gold.gif\" width=$width_ind height=20 title=\"$high_name: $c_high pts\"><img src=\"green.gif\" width=$width_2 height=20 title=\"$location total: $c_sum pts\"></td>
      <td align=center><font size=-2>$c_high | $c_sum</font></td>
      <td align=right title=\"$sum / $players\"><font size=-2>$avgptsearned</font></td>
      <td align=left><img src=\"$color_lab\" width=$width_avg_pts height=20 title=\"$avgptsearned\"></td>
     </tr>
";
    $i++;
}

unset($value); // break the reference with the last element

?>

  </table>
  <br>

<?php $totalratio = round (100 * $allplayers / 391);
 echo "
  <table border=0>
   <tr><td>Total players: $allplayers of 391  -- $totalratio% participation</td><td></td></tr>
   <tr><td bgcolor=lightblue> Large lab maximum average points: </td><td bgcolor=lightblue> $highlargelabloc ($highlargelabrate points)</td></tr><br>
   <tr><td bgcolor=pink>      Small lab maximum average points: </td><td bgcolor=pink>      $highsmalllabloc ($highsmalllabrate points)</td></tr>
  </table>
"; ?>
 </body>
</html>
