<html>
 <head>
  <title>Rock:Clime Climate Station Finder</title>
  <script>
   function latstatus(){
//     alert ('Lat status line')
     my_text="Enter latitude in decimal degrees eg 48.24 or degrees minutes seconds eg 48o14'35\"";
     window.status=my_text;
   }
   function lonstatus(){
     my_text="Enter longitude in decimal degrees eg -114.24 or degrees minutes seconds eg -114o14'35\"";
     window.status=my_text;
   }
  </script>
 </head>
 <body link=green>
  <center>
  <font face="gill, trebuchet, tahoma, arial, sans serif">
   <h4>Rock:Clime Climate Station Finder</h4>
<?php
   $version='2009.08.04';

   $my_latitude  = $_REQUEST['latitude'];
   $my_longitude = $_REQUEST['longitude'];
   $units        = $_REQUEST['units'];
   $mchecked=''; $ftchecked=''; $units2 = 'km';
   if ($units == 'm') $mchecked='checked';
   if ($units == 'ft') $ftchecked='checked';
   if ($units == 'ft') $units2='mi';

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
 echo "    Longitude: ";
 $my_longitude=dms_to_dec($my_longitude);
 echo "   </font>\n";
?>
   <table bgcolor="lightgreen">
    <tr>
     <td>
      <form name="mylatlon" action="closest.php">
       <center>
       Latitude: <input type="text" value="<?php echo $my_latitude ?>" name="latitude"
                  onmouseover=javascript:latstatus(); return true"
                  onmouseout="window.status=''">&nbsp;&nbsp;
       Longitude: <input type="text" value="<?php echo $my_longitude ?>" name="longitude"
                  onmouseover=javascript:lonstatus(); return true"
                  onmouseout="window.status=''">
       <input type="submit" value="locate"><br>
       <font size=-2>
        Units:
        <input type="radio" name="units" value="m" <?php echo $mchecked ?>>metric
        <input type="radio" name="units" value="ft" <?php echo $ftchecked ?>>U.S. Customary
       </font>
       <br>
       <font size=-1>
        Enter target latitude and longitude to find <?php echo $howmany ?> geographically closest CLIGEN climate stations.<br>
       </font>
       </center>
      </form>
     </td>
    </tr>
   </table>
   <br>
<?php

function getDistance($latitudeFrom, $longitudeFrom, $latitudeTo, $longitudeTo, $units) {
// https://andries.systray.be/blog/2007/07/12/calculating-a-distance-between-2-points-in-php/

// Calculating a distance between 2 points in PHP (in km)
// 12 Jul, 2007  Others

// I feel pretty confident that Rob (Akrabat.com) will not be writing about the same topic this time. Anyway, in this post I.ll explain you how to calculate a distance between 2 points in PHP
// Because of the near-spherical shape of the Earth, calculating an accurate distance between two points requires the use of spherical geometry [1], and trigonometric math functions. For many applications, an approximate distance calculation provides sufficient accuracy with much less complexity.
// To calculate an approximate distance in miles, we could do:
//   sqrt(x * x + y * y)
// where: x = 69.1 * (lat2 - lat1) and y = 53.0 * (lon2 - lon1)
// We can improve the accuracy, by adding the cosine math function:
//   sqrt(x * x + y * y)
// where: x = 69.1 * (lat2 - lat1) and y = 69.1 * (lon2 - lon1) * cos(lat1/57.3)
// If you need greater accuracy, you can use the Great Circle Distance Formula [2]. This formula requires use of spherical geometry, and a high level of floating point mathematical accuracy - about 15 digits of accuracy (double-precision).
// To convert latitude or longitude from decimal degrees to radians, we can divide the latitude and longitude values by 180/pi, or approximately 57.29577951. The radius of the earth is assumed to be 6,378.8 kilometers, or 3,963.0 miles.
// Since we are using PHP, it.s much simpler, because the deg2rad() function does this calculation for us.
// If you convert all latitude and longitude values to radians before the calculation, we can use this equation:
// 3963.0 * arccos[sin(lat1) * sin(lat2) + cos(lat1) * cos(lat2) * cos(lon2 - lon1)]

    // 1 degree equals 0.017453292519943 radius
    $degreeRadius = deg2rad(1);
 
    // convert longitude and latitude values
    // to radians before calculation
    $latitudeFrom  *= $degreeRadius;
    $longitudeFrom *= $degreeRadius;
    $latitudeTo    *= $degreeRadius;
    $longitudeTo   *= $degreeRadius;
 
    // apply the Great Circle Distance Formula
    $d = sin($latitudeFrom) * sin($latitudeTo) + cos($latitudeFrom)
       * cos($latitudeTo) * cos($longitudeFrom - $longitudeTo);

// The radius of the earth is assumed to be 6,378.8 kilometers, or 3,963.0 miles
    $conversion = 6371.0;
    if ($units == 'ft') $conversion = 3963.0;
    return ($conversion * acos($d));
}
?>

<?php

//    $my_latitude = 49; $my_longitude = -149;
//    $my_latitude = 44.22; $my_longitude = -115.00;
//    Stanley, ID: 44.22	-114.93

if (is_numeric ($my_latitude) && is_numeric($my_longitude)
      && $my_latitude  <  180
      && $my_latitude  > -180
      && $my_longitude <  180
      && $my_longitude > -180 ) {
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
//        echo "Longitude: $lon<br>\n";
//        echo "Station: $station<br>\n";
          $file[$i] = $filepath;
          $stat[$i] = $station;
          $dist[$i] = getDistance($my_latitude, $my_longitude, $lat, $lon, $units);
//        echo "Distance: $dist[$i] km<br><br>\n";
          $i+=1;
        }
       }   // while (!feof($FILEhandle))
    }   // if ($FILEhandle)

//    $z = array_multisort($dist, $file, $stat);

    if (array_multisort($dist, $file, $stat)) {

      $howmany = 5;
      echo "    Closest $howmany of $i stations to latitude $my_latitude<sup>o</sup>, longitude $my_longitude<sup>o</sup>: <br><br>\n";
      echo "   <table border=1 cellpadding=5>\n";
      echo "    <tr><th valign=top>Distance<br>($units2)</th><th valign=top>State</th><th valign=top>Station</th></tr>\n";
      for ($j = 0; $j < $howmany; $j++) {
        list($state,$fname)=split("/",$file[$j],2);
        $STATE=strtoupper($state);
        list($CL,$type) = explode(".",$file[$j]);
        $distance=sprintf("%8.2f",$dist[$j]);
        echo "
    <tr>
     <td align=\"right\">$distance</td>
     <td>$STATE</td>
     <td><a href=\"/cgi-bin/fswepp/rc/manageclimates.pl?units=$units&Climate=$CL&manage=describe\" target=\"describe\">$stat[$j]</a></td>
    </tr>\n";
      }
//      echo "    <tr><td>$dist[1]</td><td>$file[1]</td><td>$stat[1]</td></tr>\n";
//      echo "    <tr><td>$dist[2]</td><td>$file[2]</td><td>$stat[2]</td></tr>\n";
//      echo "    <tr><td>$dist[3]</td><td>$file[3]</td><td>$stat[3]</td></tr>\n";
//      echo "    <tr><td>$dist[4]</td><td>$file[4]</td><td>$stat[4]</td></tr>\n";
      echo "   </table>\n";

//    var_dump($dist);
//    var_dump($file);
//    var_dump($stat);
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
    <b>'closest'</b> version <?php echo $version; ?>, a part of <b>Rock:Clime</b><br>
    U.S.D.A. Forest Service, Rocky Mountain Research Station<br>
    Air, Water and Aquatics, Moscow, ID
   </font>
 </body>
</html>
