<!DOCTYPE html>
<html>
<body>

<h2>Upload New Fire Cover Modification Map</h2>
<p>Use this form to add more fire-caused maps to those available for use. 
</p>

<form name="fireCoverMapReceived" method="post" 
    action= "http://<?php echo ("".$_SERVER["HTTP_HOST"].""); ?>/WEPPfire/fireCoverMapReceive.php" 
    enctype="multipart/form-data"> <br />
  <label for="name">A short name for this map:</label><br />
  <input type="text" name="name" value="" size="50"><br />
  <label for="name">Description (200 chars max):</label><br />
  <textarea rows="4" cols="50" maxlength="200" name="description" required="required"
    placeholder="Description (required)"> </textarea><br />
  <label for="uploadFireFile">File name for the asciigrid (.asc):</label><br />
  <input type="file" name="uploadFireFile" size="50" /><br />
  <label for="uploadPrjFile">File name for the corresponding 
       projection (.prj):</label><br />
  <input type="file" name="uploadPrjFile" size="50" /><br /> 
  <input type="submit" name="submit" value="Submit" />
</form>


</body>
</html>
