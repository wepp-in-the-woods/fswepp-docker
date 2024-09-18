<html>
 <head>
 </head>
 <body link=white vlink=white>
  <title>2019 Summit Mount Sustainability posted</title>
 <font face="trebuchet, tahoma, arial, sans serif">
   <table border=0 width=100%>
    <tr bgcolor=darkgreen><th><h3><font color=white><a href=".">2019 Summit Mt. Sustainability</a></font></h3></th></tr>
    <tr bgcolor=darkgreen><th><font color=black><a href="stats.php" target="stats">View Station-wide results</a></font></th></tr>
   </table>
<br>

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
    $pe5 = $_POST["pe5"];
    $pe6 = $_POST["pe6"];

    $pw1 = $_POST["pw1"];
    $pw2 = $_POST["pw2"];

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
//    $pp2 = $_POST["pp2"];
//    $ps1 = $_POST["ps1"];

// one-time

    $ope1 = $_POST["ope1"];
    $ope2 = $_POST["ope2"];
    $ope3 = $_POST["ope3"];
    $ope4 = $_POST["ope4"];
    $ope5 = $_POST["ope5"];

    $opw1 = $_POST["opw1"];
    $opw2 = $_POST["opw2"];
    $opw3 = $_POST["opw3"];

    $opt1 = $_POST["opt1"];
    $opt2 = $_POST["opt2"];
    $opt3 = $_POST["opt3"];

    $opr1 = $_POST["opr1"];
    $opr2 = $_POST["opr2"];
    $opr3 = $_POST["opr3"];
    $opr4 = $_POST["opr4"];
    $opr5 = $_POST["opr5"];
    $opr6 = $_POST["opr6"];
    $opr7 = $_POST["opr7"];
    $opr8 = $_POST["opr8"];
    $opr9 = $_POST["opr9"];
    $opr10= $_POST["opr10"];
//    $opp1 = $_POST["opp1"];
//    $opp2 = $_POST["opp2"];

    $ops1 = $_POST["ops1"];
    $ops2 = $_POST["ops2"];
    $ops3 = $_POST["ops3"];
    $ops4 = $_POST["ops4"];
    $ops5 = $_POST["ops5"];
    $ops6 = $_POST["ops6"];
    $ops7 = $_POST["ops7"];
    $ops8 = $_POST["ops8"];
    $ops9 = $_POST["ops9"];
    $ops10= $_POST["ops10"];
    $ops11= $_POST["ops11"];

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

// if (!ctype_alnum($fs_email)) {  //  echo "The string $testcase does not consist of all letters or digits.\n";
   $aValid = array('.');           // https://stackoverflow.com/questions/7198958/how-to-allow-underscore-and-dash-with-ctype-alnum
if (!ctype_alnum(str_replace($aValid, '', $fs_email))) {  //  echo "The string $testcase does not consist of all letters or digits or dots.\n";
   echo "
   Invalid user name (fs e-mail) $fs_email
 </body>
</html>
";
die;
} else {   // echo "The string $testcase consists of all letters or digits or dots.\n";
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
     fwrite($handle,$pe5);     fwrite($handle,"\n");
     fwrite($handle,$pe6);     fwrite($handle,"\n");

     fwrite($handle,$pw1);     fwrite($handle,"\n");
     fwrite($handle,$pw2);     fwrite($handle,"\n");

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
//     fwrite($handle,$pp2);     fwrite($handle,"\n");
//     fwrite($handle,$ps1);     fwrite($handle,"\n");

     fwrite($handle, "e,$ope1,$ope2,$ope3,$ope4,$ope5,\n");
     fwrite($handle, "w,$opw1,$opw2,$opw3,\n");
     fwrite($handle, "t,$opt1,$opt2,$opt3,\n");
     fwrite($handle, "r,$opr1,$opr2,$opr3,$opr4,$opr5,$opr6,$opr7,$opr8,$opr9,$opr10,\n");
//     fwrite($handle, "p,$opp1,$opp2,\n");
     fwrite($handle, "s,$ops1,$ops2,$ops3,$ops4,$ops5,$ops6,$ops7,$ops8,$ops9,$ops10,$ops11,\n");

fclose($handle);

}

$mypoints = $pointsw + $pointso;

echo "   <h3>$fs_email reports $mypoints points on ", date("F j, Y, g:i a T"),"</h3>";  // https://php.net/manual/en/function.date.php

?>
   <font size=+1>Thank you for playing, and helping RMRS with sustainability!</font>
<br><br>
Individual targets:
 <ul>
  <li>&nbsp;9,000 points for a four-hour time-off award for eligible employees</li>
  <li>15,000 points for an additional four-hour time-off award for eligible employees</li>
 </ul>
Location/groups:
 <ul>
  <li>$250 SusOps award for smaller group (5 to 20 possible participants) with highest average points</li>
  <li>$250 SusOps award for larger group (more than 20 possible participants) with highest average points</li>
 </ul>

   <br>
  <a href="stats.php" target="stats">View Station-wide results</a>
 </body>
</html>
