<!DOCTYPE html>
<html>
<body>

<h2>Fire-caused Cover Map Upload Summary</h2>

<?php
  $successful = 1; 
  $fireFile = $_FILES['uploadFireFile']['name'];
  if (strlen ($fireFile) == 0)
  {
    print ("<p><strong class=\"error\">Error:</strong> Must specify a file name.</p>");
    $successful = 0;
  }

  // create file storage location
  
  $uploaddir = "CMM";
  $dirPlace=`uuidgen`;
  $dirPlace=substr($dirPlace, 0, strlen($dirPlace)-1);
  $uploaddir=$uploaddir . "/" . $dirPlace;
  $locRC = mkdir ($uploaddir, 0770, TRUE);
  $max_size = "8000000"; // 50000 50kb
  
  // Check Entension

  print "<p>AsciiGrid File: <strong>$fireFile</strong></p>";

  $extension = pathinfo($_FILES['uploadFireFile']['name']);
  $extension = $extension['extension'];
  if ("$extension" == "asc") 
  {
    // Check File Size
    $fileSize = $_FILES['uploadFireFile']['size'];
    if($fileSize > $max_size)
    {
      print "<p><strong class=\"error\">Error:</strong> file is too big, limit is: $max_size bytes.</p>";
      $successful = 0;
    }
    else if ($fileSize < 10)
    {
      print "<p><strong class=\"error\">Error:</strong> file is empty (or almost empty).</p>";
      $successful = 0;
    }
    else
    {
      if(is_uploaded_file($_FILES['uploadFireFile']['tmp_name']))
      {
        $outfile="$uploaddir/asciigrid.$extension";
        $successful = move_uploaded_file($_FILES['uploadFireFile']['tmp_name'],$outfile);
       if ($successful) 
        {
           print "<p>File successfully uploaded, $fileSize bytes.</p>";
        }
        else
        {
          print "<p><strong class=\"error\">Error:</strong> file store failed.</p>";
          $successful = 0;
        }
      }
      else
      {
        print "<p><strong class=\"error\">Error:</strong> upload failed.</p>";
        $successful = 0;
      }
    }
  }
  else
  {
    print "<p><strong class=\"error\">Error:</strong> File must have .asc extension.</p>";
    $successful = 0;
  }

  // upload the projection file (small).  

  $firePrjFile = $_FILES['uploadPrjFile']['name'];
  if (strlen ($firePrjFile) == 0)
  {
    print ("<p><strong class=\"error\">Error:</strong> Must specify a file name.</p>");
    $successful = 0;
  }

  $max_size = "1000"; // 50000 is 50kb
  
  // Check Entension

  print "<p>Projection File: <strong>$firePrjFile</strong></p>";
  $extension = pathinfo($_FILES['uploadPrjFile']['name']);
  $extension = $extension['extension'];
  if ("$extension" == "prj") 
  {
    // Check File Size
    $fileSize = $_FILES['uploadPrjFile']['size'];
    if($fileSize > $max_size)
    {
      print "<p><strong class=\"error\">Error:</strong> file is too big, limit is: $max_size bytes.</p>";
      $successful = 0;
    }
    else if ($fileSize < 10)
    {
      print "<p><strong class=\"error\">Error:</strong> file is empty (or almost empty).</p>";
      $successful = 0;
    }
    else
    {
      if(is_uploaded_file($_FILES['uploadPrjFile']['tmp_name']))
      {        
        $outfile="$uploaddir/projection.$extension";
        $psuccessful = move_uploaded_file($_FILES['uploadPrjFile']['tmp_name'],$outfile);
        if ($psuccessful) 
        {
           print "<p>File successfully uploaded, $fileSize bytes.</p>";
        }
        else
        {
          print "<p><strong class=\"error\">Error:</strong> file store failed.</p>";
          $successful = 0;
        }
      }
      else
      {
        print "<p><strong class=\"error\">Error:</strong> upload failed.</p>";
        $successful = 0;
      }
    }
  }
  else
  {
    print "<p><strong class=\"error\">Error:</strong> File must have .prj extension.</p>";
    $successful = 0;
  }  
  if ($successful == 1)
  {
    $outfile=$uploaddir . "/metadata.txt";
    $handle = fopen($outfile, "w");
    fwrite ($handle,"date       =" . date(DATE_COOKIE) . "\n");
    fwrite ($handle,"name       =" . $_POST['name'] . "\n");
    fwrite ($handle,"userHostIP =" . $_SERVER['REMOTE_ADDR'] . "\n");
    fwrite ($handle,"description=" . $_POST['description'] . "\n");
// add code to capture the user name of the person who uploaded the map
// add code to capture the bounding rectangle of this map.    
    fclose ($handle);
    print ("<p>Upload successful; ". date(DATE_COOKIE) . "</p>");
  }
  else
  {
    $files = glob($uploaddir . "/*");
    function myunlink($file) { unlink($file); }
    array_walk($files,"myunlink");
    rmdir ($uploaddir);
    print "<p><strong class=\"error\">Error:</strong> Upload failed; fix errors and try again.</p>";
  }
?> 
</body>
</html> 

