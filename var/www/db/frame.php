<html>
 <head>
  <title>Palouse Prairie Foundation native plant database</title>
 </head>
 <body>
<?php
   $gs = $_REQUEST['GenusSpecies'];
   $cn = $_REQUEST['CommonName'];
   $USDA = $_REQUEST['USDA'];
   echo "$gs $cn $USDA";
?>
  <font face="gill, trebuchet, tahoma, arial, sans serif">
   <form method="get" action="frame.php">
    <table width=100% height=70 border=1>
     <tr>
      <td align=center colspan=2 bgcolor="gold">
       <font size=+1>
        <strong>Palouse Prairie Foundation plant database</strong>
       </font>
      </td>
     </tr>
     <tr>
      <td align=center>
       Genus species<br>
       <input type="text" name="GenusSpecies" value="<?php echo $gs ?>">
       <input type="submit" value="go">
      </td>
      <td align=center>
       Common name<br>
       <input type="text" name="CommonName" value="<?php echo $cn ?>">
      </td>
     </tr>
    </table>
   </form>
   <frame
NAME=framename
WIDTH=100%
HEIGHT=100%
ALIGN=top
FRAMEBORDER=0
MARGINWIDTH=10
MARGINHEIGHT=10
SCROLLING=auto>

<?php

  if ($USDA) {
     // filter to only [a-zA-Z0-9]
     $allowed = "/[^a-zA-Z0-9]/";
     $target = preg_replace($allowed,"",$USDA);
     $USDA=$USDA.".html";
     $plantfile=file($USDA);
     echo "<font size=-1>\n";
     foreach ($plantfile as $line_num => $line) {
        echo $line;
     }
  }
  else {
  
// priority scientific name
       $target=$cn;
       $file = "cn.txt";
     if ($gs) {
       $target=$gs;
       $file = "gs.txt";
     }

//   $target="festuca";
//   $target=$gs; $file = "gs.txt";

   if ($target!='') {    // (following cleaning?) then try common name

// could check for target string length (following cleaning?)
     $target = preg_replace( "{\s+}", ' ', $target );
     $allowed = "/[^a-z\\040]/i";
     $target = preg_replace($allowed,"",$target);
     echo "Search term: $target<br><br>\n";
     $FILEhandle = @fopen ($file,"r");
     if ($FILEhandle) {
       while (!feof($FILEhandle)) {
         $line = fgets ($FILEhandle);
// strip HTML off $line 
         $lines = strip_tags ($line);
// strip untoward characters from file line $line
//       $allowed = "/[^a-z\\040]/i";

         $lines = preg_replace($allowed,"",$lines);
         if (preg_match("/\b$target\b/i",$lines)) {
           echo "$line<br>\n";
         }   // if (preg_match()
       }   // while (!feof())
     }	// if ($FILEhandle)
     fclose ($FILEhandle);
   }  // if ($target!='')
   }  // if ($USDA)
?>

   </frame>
  </font>
 </body>
</html>
