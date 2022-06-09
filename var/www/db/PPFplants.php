<html>
 <head>
  <title>Palouse Prairie Foundation native plant database</title>
  <script language="JavaScript">
    function Scientific_Clicked() {document.form.CommonName.value='';return true}
    function Common_Clicked()     {document.form.GenusSpecies.value='';return true}
    function photo(urlthumb) {
//      alert('photo: '+urlthumb)
// swap first 6 chars 'thumb' for 'image' from url
      var urlbase=urlthumb.substring(7);
//      alert(urlbase);
      var photographer=urlbase.substring(0,2);
//      alert(photographer);
      var url='image/' + urlbase;
//      alert(url);
// check for leading 'ds' or 'dh' and adapt (c) text
      if (photographer == 'ds') {
        document.getElementById("caption").innerHTML = 'Palouse Prairie Foundation -- photo (c) Dave Skinner';
      }
      if (photographer == 'dh') {
        document.getElementById("caption").innerHTML = 'Palouse Prairie Foundation -- photo (c) David Hall';
      }
      document.photoframe.src=url;
    }
    function HidePhoto() {
//      alert ('HidePhoto')
      document.photoframe.src='image/favicon.gif';
//      document.photoframe.height=0;
//      document.photoframe.width=0
      document.getElementById("caption").innerHTML = '';
    }
  </script>
 </head>
 <body link=#347235  vlink=green alink=crimson>
<?php
   $gs   = $_REQUEST['GenusSpecies'];
   $cn   = $_REQUEST['CommonName'];
   $USDA = $_REQUEST['USDA'];
   $m    = $_REQUEST['m'];
   echo "$gs $cn $USDA $m";
?>
  <font face="gill, trebuchet, tahoma, arial, sans serif">
   <form method="get" action="PPFplants.php" name="form">
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
       <a href="gs.html">Genus species</a>:&nbsp;
       <input type="text" name="GenusSpecies" onClick="javascript:Scientific_Clicked()" value="<?php echo $gs ?>">
       &nbsp;&nbsp;&nbsp;
       <a href="cn.html">Common name</a>:&nbsp; <input type="text" name="CommonName" onClick="javascript:Common_Clicked()" value="<?php echo $cn ?>">
       <input type="submit" value="go">&nbsp;&nbsp; 
       <font size=-2>
         Match: <input type="radio" name=m value="1" checked> Full <input type="radio" name=m value="0"> Partial
       </font>
      </td>
     </tr>
    </table>
   </form>
   <frame NAME=framename WIDTH=100% HEIGHT=100% ALIGN=top FRAMEBORDER=0 MARGINWIDTH=10 MARGINHEIGHT=10 SCROLLING=auto>

<?php
  if ($USDA) {

    // filter to only [a-zA-Z0-9]
    $allowed = "/[^a-zA-Z0-9]/";
    $target = preg_replace($allowed,"",$USDA); 

// look for thumbnails matching USDA code
// glob
    $seek = "thumbs/*_".$USDA."_*.*";
//  echo $seek;
    $matches = glob($seek);
    // echo $matches[0];
    foreach ($matches as $value) {
      $cop = '';
      if (substr($value,7,2) == 'ds') {$cop = 'Photo (c) Dave Skinner';}
      if (substr($value,7,2) == 'dh') {$cop = 'Photo (c) David Hall';}
      echo "<a href=\"JavaScript:photo('$value')\"
                 onMouseOver=\"window.status='Click to display photo';return true\"
                 onMouseOut=\"window.status=''; return true\">
                 <img src=\"$value\" border=0 title=\"$cop\"></a>";
    }
//    print_r(glob($seek));
//

?>
 <table border=0>
  <tr>
   <td> 
     <a onClick="JavaScript:HidePhoto();return true" title="Click to remove photo">
     <img src="image/favicon.gif" name="photoframe" border=1></a>
    <br>
    <font size=-1 id='caption'></font> 
   </td>
  <tr>
 </table>
<?php
//
    $USDA="pages/" . $USDA . ".html";
    $plantfile=file($USDA);
    echo "<font size=-1>\n";
    foreach ($plantfile as $line_num => $line) {
      echo $line;
    }
  } else {

// priority scientific name
    $target=$cn;
    $file  = "cn.txt";
    if ($gs) {
      $target=$gs;
      $file  = "gs.txt";
    }

// $target="festuca"; 
// $target=$gs; $file = "gs.txt";

    if ($target!='') {
      $target = preg_replace("{\s+}", ' ', $target);
      $allowed = "/[^a-z\\040]/i";
      $target = preg_replace($allowed,"",$target);
      echo "Search term: $target<br><br>\n";
      if (strlen($target) < 3) {
        echo "Please enter a search term of at least 3 letters\n";
      }
      else {
        $FILEhandle = @fopen ($file,"r");
        if ($FILEhandle) {
          while (!feof($FILEhandle)) {
            $line = fgets ($FILEhandle);
            // strip HTML off $line
            $lines = strip_tags ($line);
            // strip untoward characters from file line $line
            // $allowed = "/[^a-z\\040]/i";
            $lines = preg_replace($allowed,"",$lines);
            $target_full="/\b$target\b/i";
            $target_partial="/$target/i"; 
            $targ=$target_full;
            if ($m==0) {$targ=$target_partial;}
// if (preg_match("/\b$target\b/i",$lines)) { // full word 
// if (preg_match("/$target/i",$lines)) { // partial match
            if (preg_match($targ,$lines)) {
              echo "$line<br>\n"; $count+=1;
            }   // if (preg_match()
          }   // while (!feof())
        }   // if ($FILEhandle)
        fclose ($FILEhandle);
        if ($count < 1) {echo "no matches found<br>\n";}
      }   // if (srlen($target<3)
    }  // if ($target != '')
  }   // if ($USDA) 
?>
   </frame>
  </font>
 </body>
 </html>
