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
   <table border=1 cellpadding=1 cellspacing=1>
    <tr bgcolor=lightgreen>
     <th><font size=-1>Location</th><th colspan=2> <font size=-1>Participation</th><th> <font size=-1>Indiv. High</font> | <font size=-1>Total  Points</th><th colspan=2> <font size=-1>Average points</th>
    </tr>
";

#  <option value="1">  Albuquerque</option>                      8
#  <option value="2">  Aldo Leopold</option>                     8
#  <option value="3">  Boise FSL</option>                       23
#  <option value="4">  Bozeman</option>                          5
#  <option value="5">  Flagstaff FSL</option>                   20
#  <option value="6">  Fort Collins</option>                    56
#  <option value="7">  Logan</option>                            8
#  <option value="8">  Missoula FiSL</option>                   53
#  <option value="9">  Missoula FoSL</option>                   34
#  <option value="10"> Moscow FSL</option>                      29
#  <option value="11"> FIA Ogden</option>                       44
#  <option value="12"> Provo</option>                            8
#  <option value="13"> Rapid City</option>                       5

# $loc = array('Unspecified','Albuquerque','Aldo Leopold','Boise','Bozeman','FIA Data Collection','Flagstaff','Fort Collins','Logan','Missoula FiSL','Missoula FoSL','Moscow FSL','Ogden','Provo','Rapid City');
# $emp = array(0,8,8,23,5,49,20,56,8,53,34,29,44,8,5);
# $loc = array('Albuquerque','Aldo Leopold','Boise','Bozeman','FIA Data Collection','Flagstaff','Fort Collins','Logan','Missoula FiSL','Missoula FoSL','Moscow FSL','Ogden','Provo','Rapid City');
  $loc = array('Albuquerque','Aldo Leopold','Boise','Bozeman','Flagstaff','Fort Collins','Logan','Missoula FiSL','Missoula FoSL','Moscow FSL','Ogden','Provo','Rapid City');
# $emp = array(8,8,23,5,49,20,56,8,53,34,29,44,8,5);
# $emp = array(8,8,23,5,50,22,86,8,54,38,33,47,8,5);
# $emp = array(8,8,23,5,50,23,86,8,54,36,34,44,8,5);
  $emp = array(9,8,24,11,22,84,5,68,36,24,45,10,5);

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
          $pointsw  = 0;      // 450
          $pointso  = 0;      // 0

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
//       if ($points > $station_high_points) {$station_high_points = $points; $station_high_name = $fs_email; $station_high_location=$location;}
         if ($points > $station_high_points)  {$station_high_points = $points; $station_high_nl = $fs_email . ', ' . $location;}
         if ($points == $station_high_points) {$station_high_nl = $station_high_nl . '<br>' . $fs_email . ', ' . $location;}
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
    $c_avgptsearned  = commify($avgptsearned);
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
      <td align=right title=\"$players / $employees\"><font size=-2>$percent% ($players of $employees) </td>
      <td align=right><img src=\"green.gif\" width=$width_pct height=20 title=\"$percent% participation\"></td>
      <td align=left><img src=\"gold.gif\" width=$width_ind height=20 title=\"$high_name: $c_high pts\"><img src=\"green.gif\" width=$width_2 height=20 title=\"$location total: $c_sum pts\"> <font size=-2>$c_high | $c_sum</font></td>
      <td align=right title=\"$sum / $players\"><font size=-2>$c_avgptsearned</font></td>
      <td align=left><img src=\"$color_lab\" width=$width_avg_pts height=20 title=\"$c_avgptsearned\"></td>
     </tr>
";
    $i++;
}

unset($value); // break the reference with the last element

     $employees = 351;
     $totalratio = round (100 * $allplayers / $employees);
     $c_highlargelabrate  = commify($highlargelabrate);
     $c_highsmalllabrate  = commify($highsmalllabrate);
     $station_high_points = commify($station_high_points);
     $location = "Station-wide";
     $percent = round (100*($allplayers / $employees));
     $width_pct = $percent;

    echo
"    <tr>
      <th align=left title=''><font size=-1><a href=\"location.php\">Station-wide</a></font></th>
      <td align=right title=\"$allplayers / $employees\"><font size=-2>$percent% ($allplayers of $employees) </font></td>
      <td align=right><img src=\"green.gif\" width=$width_pct height=20 title=\"$percent% participation\"></td>
      <td align=left><img src=\"gold.gif\" width=$width_ind height=20 title=\"$high_name: $c_high pts\"><img src=\"green.gif\" width=$width_2 height=20 title=\"$location total: $c_sum pts\">
       <font size=-2>$station_high_points | $station_high_nl</font></td>
      <td align=right title=\"$sum / $players\"><font size=-2></font></td>
     </tr>
";

?>

  </table>
  <br>

<?php
 echo "
  <table border=0>
   <tr><td bgcolor=lightblue> Large lab maximum average points: </td><td bgcolor=lightblue> $highlargelabloc ($c_highlargelabrate points)</td></tr><br>
   <tr><td bgcolor=pink>      Small lab maximum average points: </td><td bgcolor=pink>      $highsmalllabloc ($c_highsmalllabrate points)</td></tr>
  </table>
"; ?>
 </body>
</html>