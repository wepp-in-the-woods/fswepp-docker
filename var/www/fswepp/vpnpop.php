<html>
 <head>
  <SCRIPT LANGUAGE = "JavaScript" type="TEXT/JAVASCRIPT">

   <!--
function setCookie2(name,value,expiredays)
{
c_name=name + '';
var exdate=new Date();
exdate.setDate(exdate.getDate()+expiredays);
document.cookie=c_name+ "=" +escape(value)+
((expiredays==null) ? "" : ";expires="+exdate.toGMTString());
}

function getCookie(name){
  var cname = name + "=";               
  var dc = document.cookie;             
  if (dc.length > 0) {              
    begin = dc.indexOf(cname);       
    if (begin != -1) {           
      begin += cname.length;       
      end = dc.indexOf(";", begin);
      if (end == -1) end = dc.length;
      return unescape(dc.substring(begin, end));
    }
  }
  return null;
}
  function StartUp() {
    var FSWIP = getCookie('FSWEPP_IP')
    if (FSWIP == null) {FSWIP = ''}
    else { // alert('FS WEPP IP: ' + FSWIP)}
//    document.unitsform.user_name.value = me
//    alert('FS WEPP IP: ' + FSWIP)
    self.focus()
  }
    // end hide -->
  </SCRIPT>
 </head>

 <body onLoad="StartUp()">

<!-- read search term; seek and fill in table -->
<!-- read FSWEPP_IP cookie                    -->

  <form name="vpn" action="vpnpop.php" method="get">

   <table border=1>
    <tr>
     <th width=50% bgcolor="lightblue"><font face="tahoma" size=-1>Current IP: <?= @$_SERVER["REMOTE_ADDR"]?></th>
     <th  bgcolor="lightblue"><font face="tahoma" size=-1>Alternate IP:
<?php
 $currentIP=@$_SERVER["REMOTE_ADDR"];
 $currentIPu=strtr($currentIP,'.','_');
 $ipsOK=0;
 $ip0=$_REQUEST["ip0"]; $ip1=$_REQUEST["ip1"]; $ip2=$_REQUEST["ip2"]; $ip3=$_REQUEST["ip3"];
//if (isset($ip0) and isset($ip1) and isset($ip2) and isset($ip3)) {
    // validate all numbers
    $altIP=$ip0 . '.' . $ip1 . '.' . $ip2 . '.' . $ip3;
    $altIPu=$ip0 . '_' . $ip1 . '_' . $ip2 . '_' . $ip3;
    $ipsOK=1;
    if (!$ipsOK) {$ip0=''; $ip1=''; $ip2=''; $ip3='';}
    echo "
        <input name='ip0' type='text' value='$ip0' size=1>.
        <input name='ip1' type='text' value='$ip1' size=1>.
        <input name='ip2' type='text' value='$ip2' size=1>.
        <input name='ip3' type='text' value='$ip3' size=1>
        <input name='me' type='text' value='$me' size=1>
        <input type='submit' value='check'>
";
//  }
//  else {

  if (isset($_COOKIE["FSWEPP_IP"]))
  echo '<br><font size=1>Stored IP: ' . $_COOKIE["FSWEPP_IP"] . '</font>';
//}
?>
    </th>
   </tr>
   <tr>
    <th><font face="tahoma" size=-1>Associated custom climates</th><th><font face="tahoma" size=-1>Associated custom climates</th>
   </tr>

   <tr>
    <td valign='top'>
     <font size=-1 face="tahoma">
<?

// exec ("head -n1 -q /var/www/cgi-bin/fswepp/working/166_2_22_221*.par", $result);
$command = "head -n1 -q /var/www/cgi-bin/fswepp/working/" . $currentIPu . '_?.par';
exec ($command, $result);
foreach ($result as $line) {
  $line1=substr($line,0,41);
  echo "$line1<br>\n";
}
$result='';
?>
      </font>
     </td>

     <td valign='top'>
      <font size=-1 face="tahoma">
<?

// $command = "head -n1 -q /var/www/cgi-bin/fswepp/working/" . $altIPu . '*.par';
$command = "head -n1 -q /var/www/cgi-bin/fswepp/working/" . $altIPu . $me . '_?.par';
exec ($command, $result);
foreach ($result as $line) {
  $line1=substr($line,0,41);
  echo "$line1<br>\n";
}
$result='';
?>

      </font>
     </td>
    </tr>

    </tr>
    <tr>
     <th>
     <th><input type='submit' value='accept' onClick="setCookie2(<? echo "'FSWEPP_IP','" . $altIPu ."',100" ?>)"></th>
    </tr>
    <tr>
     <!-- read climates for FS WEPP IP -->
    </tr>
   </table>
  </form>
 </body>
</html>
