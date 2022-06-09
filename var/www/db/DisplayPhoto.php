<html>
 <head>
 </head>
 <body>
  <font face="gill, trebuchet, tahoma, arial, sans serif" size=-1>
<?php
      $image = $_REQUEST['photo'];
      $cop = '';
      if (substr($image,7,2) == 'ds') {$cop = 'Palouse Prairie Foundation -- photo (c) Dave Skinner';}
      if (substr($image,7,2) == 'dh') {$cop = 'Palouse Prairie Foundation -- photo (c) David Hall';}
      // replace 'thumb' with 'image'
      $image="image/" . substr($image,7);
      echo "<img src=\"$image\" border=0><br>$cop\n";
?>
  </font>
 </body>
</html>

