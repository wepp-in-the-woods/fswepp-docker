<html>
 <head>
  <title>
   Peakflow log
  </title>
 </head>
 <body>

<script>
  // peakflowlogger.php
  //
  // determine IP address
  // read arguments
  // if none, display log
  // if all, append to log
  //
  // allow clearing log
</script>

<?php		// http://forums.digitalpoint.com/showthread.php?t=1028597
  // determine IP address

  if ($_SERVER['HTTP_X_FORWARD_FOR']) {
    $ip = $_SERVER['HTTP_X_FORWARD_FOR'];
  }
  else {
    $ip = $_SERVER['REMOTE_ADDR'];
  }

  echo '<h4>Peakflow calculator log file for IP ' . $ip . "</h4>\n\n";

  // read arguments Q, P, Q, A, L, Sg, CN, Tc, Fp, notes
  // http://www.w3schools.com/php/php_post.asp
  // The PHP $_REQUEST Variable
  // The predefined $_REQUEST variable contains the contents of both $_GET, $_POST, and $_COOKIE.
  // The $_REQUEST variable can be used to collect form data sent with both the GET and POST methods.
  // Example

  $q = (float) $_REQUEST["q"];		// Estimated peak flow rate, q (m^3/s)
  $Q=$_REQUEST["Q"];		// Storm runoff, Q (mm)
  $P=$_REQUEST["P"];		// Storm precipitation, P (mm)
  $A=$_REQUEST["A"];		// Watershed area, A (ha)
  $L=$_REQUEST["L"];		// Watershed flow length, L (m)
  $Sg=$_REQUEST["Sg"];		// Avg watershed gradient, Sg (m/m)
  $CN=$_REQUEST["CN"];		// Curve number, CN
  $Tc=$_REQUEST["Tc"];		// Time of concentration, Tc (h)
  $Fp=$_REQUEST["Fp"];		// Ponding adjustment factor, Fp  	
  $notes=$_REQUEST["desc"];
  $action=$_REQUEST["submit"];	// 'add to log', 'view log', 'delete log'

  $units=$_REQUEST["units"];	// convert to display US customary units  -- TBA

//  if (!is_numeric($q))  {$q="";}
//  if (!is_numeric($Q))  {$Q="";}
//  if (!is_numeric($P))  {$P="";}
//  if (!is_numeric($A))  {$A="";}
//  if (!is_numeric($L))  {$L="";}
//  if (!is_numeric($Sg)) {$Sg="";}
//  if (!is_numeric($CN)) {$CN="";}
//  if (!is_numeric($Tc)) {$Tc="";}
//  if (!is_numeric($Fp)) {$Fp="";}

  if (is_numeric($q))  {$q=(float)$q;}   else {$q="";}
  if (is_numeric($Q))  {$Q=(float)$Q;}   else {$Q="";}
  if (is_numeric($P))  {$P=(float)$P;}   else {$P="";}
  if (is_numeric($A))  {$A=(float)$A;}   else {$A="";}
  if (is_numeric($L))  {$L=(float)$L;}   else {$L="";}
  if (is_numeric($Sg)) {$Sg=(float)$Sg;} else {$Sg="";}
  if (is_numeric($CN)) {$CN=(float)$CN;} else {$CN="";}
  if (is_numeric($Tc)) {$Tc=(float)$Tc;} else {$Tc="";}
  if (is_numeric($Fp)) {$Fp=(float)$Fp;} else {$Fp="";}
  $notes = (string) htmlentities($notes,ENT_QUOTES);

  $args=$q.$Q.$P.$A.$L.$Sg.$CN.$Tc.$Fp;

//  echo "<br>arguments: " . $args;

  // if any, append to log

  $logfile = "../../working/pf_".$ip.".log";

// echo "action: ", $action;

  if ($action == 'delete log') {
    echo "deleting log file";
    fopen($logfile,"w");
    fclose($myFile);
  }

  if ($action == 'add to log') {
    if ($args != "") {
      $line=$q."\t".$Q."\t".$P."\t".$A."\t".$L."\t".$Sg."\t".$CN."\t".$Tc."\t".$Fp."\t".$notes."\n";
//    echo "<br>write to logfile: ";
//    echo $logfile;
//    echo $line;
      // open logfile for append
      if ($myFile = fopen($logfile,"a")) {
      // write record
        fputs($myFile,$line);
        // close logfile
        fclose($myFile);
      }
      else {
      }
    }
  }
 
  // display log
//  echo "<br>display logfile: ";
//  echo $logfile;
  // open $logfile for read
  if ($myFile = fopen($logfile,"r")) {
    // read tab-delimited file		http://php.net/manual/en/function.fgetcsv.php
    // display table
    $row=1;
    echo "\n";
    echo "  <table border=1>\n";
    echo "   <tr>\n";
    echo "    <th bgcolor='gold' title='Estimated peak flow rate'>Estimated peak flow rate<br>q<br>(m<sup>3</sup>/s)</th>\n";
    echo "    <th bgcolor='lightgreen' title='Storm runoff'>Storm runoff<br>Q<br>(mm)</th>\n";
    echo "    <th bgcolor='lightgreen' title='Storm precipitation'>Storm precipitation<br>P<br>(mm)</th>\n";
    echo "    <th bgcolor='lightpink' title='Watershed area'>Watershed area<br>A<br>(ha)</th>\n";
    echo "    <th bgcolor='lightpink' title='Watershed flow length'>Watershed flow length<br>L<br>(m)</th>\n";
    echo "    <th bgcolor='lightpink' title='Avg watershed gradient'>Avg watershed gradient<br>Sg<br>(m/m)</th>\n";
    echo "    <th bgcolor='lightblue' title='Curve Number'>Curve Number<br>CN<br>()</th>\n";
    echo "    <th bgcolor='lightblue' title='Time of concentration'>Time of concentration<br>Tc<br>(h)</th>\n";
    echo "    <th bgcolor='lightblue' title='Ponding adjustment factor'>Ponding adjustment factor<br>Fp<br>()</th>\n";
    echo "    <th bgcolor='lightblue'>Notes</th>\n";
    echo "   </tr>\n";

    while (($data = fgetcsv($myFile,0,"\t")) !== FALSE) {
      $num = count($data);
//    echo "<p> $num fields in line $row: <br /></p>\n";
      $row++;
      echo "   <tr>";
      for ($c=0; $c < $num; $c++) {
        echo "<td align=right>". $data[$c] . "</td>";
      }
      echo "</tr>\n";
    }
    echo "  </table>\n";
    // close logfile
    fclose($myFile);
  }
  else {
   echo ('file not found!');
  }
?>

 </body>
</html>
