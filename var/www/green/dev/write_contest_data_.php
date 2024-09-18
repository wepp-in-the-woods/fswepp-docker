<html>
 <head>
 </head>
 <body>
 <font face="trebuchet, tahoma, arial, sans serif">
   <table border=0 width=100%><tr bgcolor=darkgreen><th><h3><font color=white>Get Your Game 'Green' On: Summit Mt. Sustainability</font></h3></th></tr></table>
<br>
   <font size=+1>Thanks for playing, and helping  with sustainability!</font>
<br><br>
<?php

    $fs_email = $_POST["fs_email"]; if ($fs_email == '') {$fs_email = "sbear";}
    $user     = $_POST["user"];
    $location = $_POST["location"]; if ($location == '') {$location = '0';}
    $pointsw  = $_POST["pointsw"];
    $pointso  = $_POST["pointso"];

// weekly

    $pe1 = $_POST["pe1"];
    $pe2 = $_POST["pe2"];
    $pe2 = $_POST["pe2"];
    $pe3 = $_POST["pe3"];
    $pw1 = $_POST["pw1"];
    $pw2 = $_POST["pw2"];
    $pt1 = $_POST["pt1"];
    $pt2 = $_POST["pt2"];
    $pt3 = $_POST["pt3"];
    $pr1 = $_POST["pr1"];
    $pr2 = $_POST["pr2"];
    $pr3 = $_POST["pr3"];
    $pr4 = $_POST["pr4"];
    $pp1 = $_POST["pp1"];
    $pp2 = $_POST["pp2"];
    $pp3 = $_POST["pp3"];
    $pp4 = $_POST["pp4"];
    $ps1 = $_POST["ps1"];
    $ps2 = $_POST["ps2"];
    $ps3 = $_POST["ps3"];

// one-time

    $ope1 = $_POST["ope1"];
    $ope2 = $_POST["ope2"];
    $ope3 = $_POST["ope3"];
    $ope4 = $_POST["ope4"];
    $opw1 = $_POST["opw1"];
    $opw2 = $_POST["opw2"];
    $opw3 = $_POST["opw3"];
    $opt1 = $_POST["opt1"];
    $opt2 = $_POST["opt2"];
    $opt3 = $_POST["opt3"];
    $opt4 = $_POST["opt4"];
    $opt5 = $_POST["opt5"];
    $opr1 = $_POST["opr1"];
    $opr2 = $_POST["opr2"];
    $opr3 = $_POST["opr3"];
    $opr4 = $_POST["opr4"];
    $opr5 = $_POST["opr5"];
    $opr6 = $_POST["opr6"];
    $opr7 = $_POST["opr7"];
    $opr8 = $_POST["opr8"];
    $opr9 = $_POST["opr9"];
    $opr10 = $_POST["opr10"];
    $opp1 = $_POST["opp1"];
    $opp2 = $_POST["opp2"];
    $opp3 = $_POST["opp3"];
    $ops1 = $_POST["ops1"];
    $ops2 = $_POST["ops2"];
    $ops3 = $_POST["ops3"];
    $ops4 = $_POST["ops4"];
    $ops5 = $_POST["ops5"];

//  echo "write_contest_data";
//  echo $ope1;

// echo "e,0,0,0,0,<br>";
// echo "w,0,0,0,<br>";
// echo "t,0,0,0,0,0,<br>";
// echo "r,0,0,0,0,0,0,0,0,0,0,<br>";
// echo "p,0,0,0,<br>";
// echo "s,0,0,0,0,0,<br>";

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


// write to file

if (!ctype_alnum($fs_email)) {  //  echo "The string $testcase does not consist of all letters or digits.\n";
   echo "
   Invalid user name (fs e-mail) $fs_email
 </body>
</html>
";
die;
} else {   // echo "The string $testcase consists of all letters or digits.\n";
}

    $filename = $location . "_" . $fs_email . ".txt";
    $filename = "data/" . $filename;
    $handle = fopen($filename, "w");
if ($handle) {

 fwrite($handle,$fs_email);     // sbear
     fwrite($handle,"\n");
 fwrite($handle,$user);     // Smokey Bear
     fwrite($handle,"\n");
 fwrite($handle,$location);     // USFS
     fwrite($handle,"\n");
 fwrite($handle,$pointsw);     // 450
     fwrite($handle,"\n");
 fwrite($handle,$pointso);     // 0
     fwrite($handle,"\n");

     fwrite($handle,$pe1);
     fwrite($handle,"\n");
     fwrite($handle,$pe2);
     fwrite($handle,"\n");
     fwrite($handle,$pe3);
     fwrite($handle,"\n");
     fwrite($handle,$pw1);
     fwrite($handle,"\n");
     fwrite($handle,$pw2);
     fwrite($handle,"\n");
     fwrite($handle,$pt1);
     fwrite($handle,"\n");
     fwrite($handle,$pt2);
     fwrite($handle,"\n");
     fwrite($handle,$pt3);
     fwrite($handle,"\n");
     fwrite($handle,$pr1);
     fwrite($handle,"\n");
     fwrite($handle,$pr2);
     fwrite($handle,"\n");
     fwrite($handle,$pr3);
     fwrite($handle,"\n");
     fwrite($handle,$pr4);
     fwrite($handle,"\n");
     fwrite($handle,$pp1);
     fwrite($handle,"\n");
     fwrite($handle,$pp2);
     fwrite($handle,"\n");
     fwrite($handle,$pp3);
     fwrite($handle,"\n");
     fwrite($handle,$pp4);
     fwrite($handle,"\n");
     fwrite($handle,$ps1);
     fwrite($handle,"\n");
     fwrite($handle,$ps2);
     fwrite($handle,"\n");
     fwrite($handle,$ps3);
     fwrite($handle,"\n");

fwrite($handle, "e,$ope1,$ope2,$ope3,$ope4,\n");
fwrite($handle, "w,$opw1,$opw2,$opw3,\n");
fwrite($handle, "t,$opt1,$opt2,$opt3,$opt4,$opt5,\n");
fwrite($handle, "r,$opr1,$opr2,$opr3,$opr4,$opr5,$opr6,$opr7,$opr8,$opr9,$opr10,\n");
fwrite($handle, "p,$opp1,$opp2,$opp3,\n");
fwrite($handle, "s,$ops1,$ops2,$ops3,$ops4,$ops5,\n");

fclose($handle);

}

$mypoints = $pointsw + $pointso;

//$loc[0] = 'Unspecified';
//$loc[1] = 'Moscow FSL';
//$loc[2] = 'Missoula Fire';

echo "   <h3>$fs_email total points $mypoints</h3>\n";

echo "
   <table border=1>
    <tr bgcolor=pink>
     <th>Location</th><th>Players</th><th>Individual High Points</th><th>Location Total Points</th>
    </tr>
";

$i=0;

#  <option value="1"   >Albuquerque</option>
#  <option value="2"   >Boise FSL</option>
#  <option value="3"   >Bozeman</option>
#  <option value="4"   >Data Collection Team</option>
#  <option value="5"   >Flagstaff FSL</option>
#  <option value="6"   >Fort Collins</option>
#  <option value="7"   >Logan</option>
#  <option value="8"   >Missoula Fire Science Lab</option>
#  <option value="9"   >Missoula FSL</option>
#  <option value="10"  >Moscow FSL</option>
#  <option value="11"  >Ogden</option>
#  <option value="12"  >Provo</option>
#  <option value="13"  >Rapid City</option>
#  <option value="14"  >Reno FSL</option>

$loc = array('Unspecified','Albuquerque','Boise','Bozeman','Data Collection','Flagstaff','Fort Collins','Logan','Missoula FoSL','Missoula FSL','Moscow','Ogden','Provo','Rapid City','Reno');
foreach ($loc as &$location) {
    $players = 0;
    $high = 0;
    $sum = 0;
    $blob='data/'.$i.'_*.txt';
//    foreach (glob("data/$i_*.txt") as $filename) {
    foreach (glob($blob) as $filename) {
       echo "$filename size " . filesize($filename) . "<br>\n";

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
       }
    }
    $c_high = commify($high); $c_sum = commify($sum);
    echo "    <tr><th align=left bgcolor=pink>$location</th><td align=right>$players</td><td align=right title=\"$high_name\">$c_high</td><td align=right>$c_sum</td></tr>\n";
    $i++;
}
unset($value); // break the reference with the last element

?>
   <a href="stats.php">stats</a>
  </table>
 </body>
</html>
