<html>
 <head>
 </head>
 <body>
  <font face="gill, trebuchet, tahoma, arial, sans serif">
  <?php
// need to read from calling form

     $target="festuca";

// priority scientific name

   $file = "gs.txt";
// $file = "cn.txt";

// if $target=='' (following cleaning?) then try common name
// or different "go" button for each and check button pressed...
// following is for scientific.
// could check for target string length (following cleaning?)
     $target = preg_replace( "{\s+}", ' ', $target );
     $allowed = "/[^a-z\\040]/i";
     $target = preg_replace($allowed,"",$target);
     echo "Search term: $target<br><br>\n";
     $FILEhandle = @fopen ($file,"r");
     if ($FILEhandle) {
       while (!feof($FILEhandle)) {
         $line = fgets ($FILEhandle);
// strip HTML off $line //
         $lines = strip_tags ($line);
// strip untoward characters from file line $line //
//       $allowed = "/[^a-z\\040]/i";
         $lines = preg_replace($allowed,"",$lines);
         if (preg_match("/\b$target\b/i",$lines)) {
           echo "$line<br>\n";
         }
       }
     }
     fclose ($FILEhandle);
  ?>
  </font>
 </body>

