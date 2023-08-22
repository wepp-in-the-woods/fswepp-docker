<html>
 <head>
  <title>Rock:Clime Climate Station Latitude Matcher</title>
  <script>
   function latstatus(){
//     alert ('Lat status line')
     my_text="~Enter latitude in decimal degrees eg 48.24 or degrees minutes seconds eg 48o14'35\"";
     window.status=my_text;
   }
  </script>
 </head>
 <body link=green>
  <center>
  <font face="gill, trebuchet, tahoma, arial, sans serif">
   <h4>Rock:Clime Climate Station Latitude Matcher</h4>
<?php
   $version='2010.12.08';
#   $howmany = 5;

   $my_latitude  = $_REQUEST['latitude'];
   $units        = $_REQUEST['units'];
   $howmany      = $_REQUEST['n'];
   $mchecked=''; $ftchecked=''; $units2 = 'km';
   if ($units == 'm')  $mchecked='checked';
   if ($units == 'ft') $ftchecked='checked';
   if ($units == 'ft') $units2='mi';
   if (is_numeric($howmany)) {
     if ($howmany < 1)   $howmany = 1;
     if ($howmany > 50)  $howmany = 50;
   }
   else { $howmany=30; }

//  check for DMS (degree-minute-second entry)

 function dms_to_dec($in) {
// $inkeep = $in;
   if ($degat = strpos($in,"o")) {
     $minat = strlen($in);
     if (strpos($in,"'")) $minat = strpos($in,"'");
     $secat = strlen($in);
     if (strpos($in,'"')) $secat = strpos($in,'"');
     $dmdif = $minat - $degat;
     $msdif = $secat - $minat;
     $degrees = substr($in,0,$degat);
     $minutes = substr($in,$degat+1,$dmdif-1);
     $seconds = substr($in,$minat+1,$msdif-1);
     if ($minutes=='') $minutes=0;
     if ($seconds=='') $seconds=0;
     echo "$degrees degrees $minutes minutes $seconds seconds<br>\n";
     if (is_numeric($degrees) && is_numeric($minutes) && is_numeric($seconds)
        && $degrees<180 && $minutes<60 && $seconds<60) {
       if ($degrees>=0) {
         $in=$degrees + ($minutes/60) + ($seconds/3600);
       }
       else {
         $in=$degrees - ($minutes/60) - ($seconds/3600);
       }
     }
   }
   else echo "$in degrees<br>\n";
   return $in;
 }
 echo "   <font size=-1>\n    Latitude: ";
 $my_latitude=dms_to_dec($my_latitude);
 echo "   </font>\n";
?>
   <table bgcolor="#FFCCB9">
    <tr>
     <td>
      <form name="mylat" action="closest_lat.php">
       <center>
       Latitude: <input type="text" value="<?php echo $my_latitude ?>" name="latitude"
                  onmouseover=javascript:latstatus(); return true"
                  onmouseout="window.status=''">&nbsp;&nbsp;
       <input type="submit" value="locate"><br>
       <font size=-2>
        Units:
        <input type="radio" name="units" value="m" <?php echo $mchecked ?>>metric
        <input type="radio" name="units" value="ft" <?php echo $ftchecked ?>>U.S. Customary
       </font>
       <br>
       <font size=-1>
        Enter target latitude to find <?php echo $howmany ?> geographically closest CLIGEN climate stations.<br>
        <font size=-2>
         Enter values in decimal degrees, eg 48.24, or degrees minutes seconds, eg 48o14'35"<br>
         North America is positive latitude<br>
         for example Moscow, ID is at latitude 46o43'56".
        </font>
       </font>
       </center>
      </form>
     </td>
    </tr>
   </table>
   <br>

<?php

//    $my_latitude = 49;
//    $my_latitude = 44.22;
//    Stanley, ID: 44.22

  if (is_numeric ($my_latitude)
      && $my_latitude  <  180
      && $my_latitude  > -180 ) {
    $llfile='lls.txt';
    $FILEhandle = @fopen ($llfile,"r");
    if ($FILEhandle) {
      $i = 0;
      while (!feof($FILEhandle)) {
        $line = fgets ($FILEhandle);
        list($filepath, $lat, $lon, $station, $extra) = split("\t", $line, 4);
        if ($filepath != '') {
//        echo "File: $filepath<br>\n";
//        echo "Latitude: $lat<br>\n";
//        echo "Station: $station<br>\n";
          $file[$i] = $filepath;
          $stat[$i] = $station;
          $dist[$i] = abs (abs($my_latitude) - abs($lat));
          $lati[$i] = $lat;
//        echo "Distance: $dist[$i] $lat $my_latitude $station<br>\n";
          $i+=1;
        }
       }   // while (!feof($FILEhandle))
    }   // if ($FILEhandle)

//    $z = array_multisort($dist, $file, $stat);

    if (array_multisort($dist, $file, $stat, $lati)) {

      echo "    Closest $howmany of $i stations to latitude $my_latitude<sup>o</sup>: <br><br>\n";
      echo "   <table border=1 cellpadding=5>\n";
      echo "    <tr><th valign=top>Latitude</th><th valign=top>State</th><th valign=top>Station</th></tr>\n";
      for ($j = 0; $j < $howmany; $j++) {
        list($state,$fname)=split("/",$file[$j],2);
        $STATE=strtoupper($state);
        list($CL,$type) = explode(".",$file[$j]);
        $latitude=$lati[$j];
        echo "
    <tr>
     <td align=\"right\">$latitude</td>
     <td>$STATE</td>
     <td><a href=\"/cgi-bin/fswepp/rc/manageclimates.pl?units=$units&Climate=$CL&manage=describe\" target=\"describe\">$stat[$j]</a></td>
    </tr>\n";
      }
//      echo "    <tr><td>$dist[1]</td><td>$file[1]</td><td>$stat[1]</td></tr>\n";
//      echo "    <tr><td>$dist[2]</td><td>$file[2]</td><td>$stat[2]</td></tr>\n";
//      echo "    <tr><td>$dist[3]</td><td>$file[3]</td><td>$stat[3]</td></tr>\n";
//      echo "    <tr><td>$dist[4]</td><td>$file[4]</td><td>$stat[4]</td></tr>\n";
      echo "   </table>\n";

      echo " <br><font size=-1>Click the climate station name for a description of the climate</font> ";
    }
    else {
      echo "sort failed<br><br>\n";
    }

//    var_dump($dist);
//    var_dump($file);
//    var_dump($stat);

}
?>
  </font>
  </center>
   <font size=-2 face="gill, trebuchet, tahoma, arial, sans serif">
    <br><br>
    <b>'closest_lat'</b> version <?php echo $version; ?>, a part of <b>Rock:Clime</b><br>
    U.S.D.A. Forest Service, Rocky Mountain Research Station<br>
    Air, Water and Aquatics, Moscow, ID
   </font>
 </body>
</html>
