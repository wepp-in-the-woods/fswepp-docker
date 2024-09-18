<html>
 <head>
 </head>
 <body link=white vlink=white>
  <title>Get Your Green On posted</title>
 <font face="trebuchet, tahoma, arial, sans serif">
   <table border=0 width=100%><tr bgcolor=darkgreen><th><h3><font color=white><a href=".">Get Your Game 'Green' On: Summit Mt. Sustainability</a></font></h3></th></tr></table>
<br>
   <font size=+1>Thank you for playing, and helping RMRS with sustainability!</font>
<br><br>
Individual targets:
 <ul>
  <li>9,000 points for a two-hour time-off award for eligible employees</li>
  <li>15,000 points for an additional two-hour time-off award for eligible employees</li>
 </ul>
Location/groups:
 <ul>
  <li>$250 SusOps award for smaller group (5 to 20 possible participants) with highest average points</li>
  <li>$250 SusOps award for larger group (more than 20 possible participants) with highest average points</li>

<?php

    $fs_email = $_POST["fs_email"]; if ($fs_email == '') {$fs_email = "sbear";}
    $user     = $_POST["user"];
    $location = $_POST["location"]; if ($location == '') {$location = '0';}
    $pointsw  = $_POST["pointsw"];
    $pointso  = $_POST["pointso"];

// weekly

    $pe1 = $_POST["pe1"];
    $pe2 = $_POST["pe2"];
    $pe3 = $_POST["pe3"];
    $pe4 = $_POST["pe4"];
    $pw1 = $_POST["pw1"];
    $pt1 = $_POST["pt1"];
    $pt2 = $_POST["pt2"];
    $pt3 = $_POST["pt3"];
    $pr1 = $_POST["pr1"];
    $pr2 = $_POST["pr2"];
    $pr3 = $_POST["pr3"];
    $pr4 = $_POST["pr4"];
    $pr5 = $_POST["pr5"];
    $pr6 = $_POST["pr6"];
    $pr7 = $_POST["pr7"];
    $pr8 = $_POST["pr8"];
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
    $opw1 = $_POST["opw1"];
    $opw2 = $_POST["opw2"];
    $opw3 = $_POST["opw3"];
    $opw4 = $_POST["opw4"];
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
    $opp1 = $_POST["opp1"];
    $opp2 = $_POST["opp2"];
    $opp3 = $_POST["opp3"];
    $opp4 = $_POST["opp4"];
    $ops1 = $_POST["ops1"];
    $ops2 = $_POST["ops2"];
    $ops3 = $_POST["ops3"];
    $ops4 = $_POST["ops4"];
    $ops5 = $_POST["ops5"];
    $ops6 = $_POST["ops6"];

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
     fwrite($handle,$user);         // Smokey Bear
     fwrite($handle,"\n");
     fwrite($handle,$location);     // USFS
     fwrite($handle,"\n");
     fwrite($handle,$pointsw);      // 450
     fwrite($handle,"\n");
     fwrite($handle,$pointso);      // 0
     fwrite($handle,"\n");

     fwrite($handle,$pe1);     fwrite($handle,"\n");
     fwrite($handle,$pe2);     fwrite($handle,"\n");
     fwrite($handle,$pe3);     fwrite($handle,"\n");
     fwrite($handle,$pe4);     fwrite($handle,"\n");
     fwrite($handle,$pw1);     fwrite($handle,"\n");
     fwrite($handle,$pt1);     fwrite($handle,"\n");
     fwrite($handle,$pt2);     fwrite($handle,"\n");
     fwrite($handle,$pt3);     fwrite($handle,"\n");
     fwrite($handle,$pr1);     fwrite($handle,"\n");
     fwrite($handle,$pr2);     fwrite($handle,"\n");
     fwrite($handle,$pr3);     fwrite($handle,"\n");
     fwrite($handle,$pr4);     fwrite($handle,"\n");
     fwrite($handle,$pr5);     fwrite($handle,"\n");
     fwrite($handle,$pr6);     fwrite($handle,"\n");
     fwrite($handle,$pr7);     fwrite($handle,"\n");
     fwrite($handle,$pr8);     fwrite($handle,"\n");
     fwrite($handle,$pp1);     fwrite($handle,"\n");
     fwrite($handle,$pp2);     fwrite($handle,"\n");
     fwrite($handle,$pp3);     fwrite($handle,"\n");
     fwrite($handle,$pp4);     fwrite($handle,"\n");
     fwrite($handle,$ps1);     fwrite($handle,"\n");
     fwrite($handle,$ps2);     fwrite($handle,"\n");
     fwrite($handle,$ps3);     fwrite($handle,"\n");

     fwrite($handle, "e,$ope1,$ope2,$ope3,\n");
     fwrite($handle, "w,$opw1,$opw2,$opw3,$opw4,\n");
     fwrite($handle, "t,$opt1,$opt2,$opt3,$opt4,$opt5,\n");
     fwrite($handle, "r,$opr1,$opr2,$opr3,$opr4,$opr5,$opr6,$opr7,$opr8,\n");
     fwrite($handle, "p,$opp1,$opp2,$opp3,$opp4,\n");
     fwrite($handle, "s,$ops1,$ops2,$ops3,$ops4,$ops5,$ops6,\n");

fclose($handle);

}

$mypoints = $pointsw + $pointso;

echo "   <h3>$fs_email reports $mypoints points on ", date("F j, Y, g:i a T"),"</h3>";  // https://php.net/manual/en/function.date.php

?>
   <iframe src="stats.php" seamless width=100% height=600></iframe>
  </table>
 </body>
</html>
