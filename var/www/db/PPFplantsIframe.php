<html>
 <head>
  <title>Palouse Prairie Foundation native plant database</title>
  <script language="JavaScript">
    function Scientific_Clicked() {document.form.CommonName.value='';return true}
    function Common_Clicked()     {document.form.GenusSpecies.value='';return true}
    function photo(url) {
    alert('photo: '+url)
//      myurl = document.getElementById('ifrm').src
//      if (myurl == url) {HideIframe(); document.getElementById('ifrm').src=''}
//      else {
//        document.getElementById('ifrm').src   =url;
//        document.getElementById('ifrm').height=300;
//        document.getElementById('ifrm').width ="30%";
//      }
     document.photoframe.src='image/ds_CIBR_.jpg'
    }
    function HideIframe() {
//  alert('HideIframe')
      document.getElementById('ifrm').height=0;
      document.getElementById('ifrm').width=0;
    }
  </script>
 </head>
 <body>
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
       Genus species:&nbsp;
       <input type="text" name="GenusSpecies" onClick="javascript:Scientific_Clicked()" value="<?php echo $gs ?>">
       &nbsp;&nbsp;&nbsp;
       Common name:&nbsp; <input type="text" name="CommonName" onClick="javascript:Common_Clicked()" value="<?php echo $cn ?>">
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
      echo "<a href=\"JavaScript:photo('DisplayPhoto.php?photo=$value')\"
                 onMouseOver=\"window.status='display photo';return true\"
                 onMouseOut=\"window.status=''; return true\">
                 <img src=\"$value\" border=0 title=\"$cop\"></a>";
    }
//    print_r(glob($seek));
//

?>
    [<a onClick="JavaScript:HideIframe(); return true" title="Remove help text (if present)"
    onMouseOver="window.status='Remove help text (if present)';return true"
    onMouseOut="window.status='Forest Service Water And Sediment Predictor';return true">X</a>]
<iframe id="ifrm" name="ifrm" src="" scrolling="auto" width="0" height="0" frameborder="0">
 [Content for browsers that don't support iframes goes here.]
</iframe>
 <table>
  <tr>
   <td> <img src="" name="photoframe" border=1>
    <br>
     Palouse Prairie Foundation -- photo (c) Dave Skinner
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
