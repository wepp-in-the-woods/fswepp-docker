<html>
 <head>
 </head>
 <body>
<? // open directory find files that match
   $ip="166_2_22_245_";
   echo " $ip ($REMOTE_ADDR)<br><br>";
   $quads=explode(".",$REMOTE_ADDR);
//   $_POST['q0'] = $quads[0];
echo "
  <form>
   <b>IP</b>
    <input type='text' name='q0' size=5 value='$quads[0]'>.
    <input type='text' name='q1' size=5 value='$quads[1]'>.
    <input type='text' name='q2' size=5 value='$quads[2]'>.
    <input type='text' name='q3' size=5 value='$quads[3]'>
<br><br>
  list of climates that match
";
   $dir = opendir("/var/www/cgi-bin/fswepp/working/");
   while ($file = readdir($dir)) {
     if (stristr($file, $ip) and stristr($file, '.par')) { echo "$file<br>"; }
// echo "$file<br>";
   }
 closedir($dir);
 ?>
<br><br>
    <input type="text" name="climate" size=40 value="">

  </form>
 </body>
</html>
