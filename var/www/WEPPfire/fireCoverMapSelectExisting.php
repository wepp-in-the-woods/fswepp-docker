<!DOCTYPE html>
<html>
<h2>Pick Existing Fire Cover Modification Map</h2>

<!--   
Add code that will go through all the existing maps and 
1. Build a table of those that can be used for the present project area. 
2. Let the user select one of these maps and specify form values that convert
   the mapped values to the cover modifications.
      
Below this code, add the capability to "add maps" to the file of possible maps.
-->
<div style="width:90%; height:90%; line-height:1.2em; overflow:auto; padding:4px;">
<?php
  function selection($sel)
  {
//     echo "<p>Selection is $index, $dirs[$index]</p>";
    echo "Selection is $sel";
  }

  $dirs = glob("CMM/*");
  $i = 0;
  foreach ($dirs as $dir)
  {
    $filename = $dir . "/metadata.txt";
    $handle = fopen($filename,"r");
    while(! feof($handle))
    {
      $line = fgets($handle); 
      echo $line . "<br />";
      if (substr($line,0,12) == "name       =")
      {
        $name = substr($line,12);
      }
    }

    $i = $i + 1;
  }
?> 
</div>



</body>
</html>
