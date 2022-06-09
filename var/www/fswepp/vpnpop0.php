<html>
 <head>
  <style type="text/css">
   <!--
    body {position: relative; background: #ffffff; margin: 0; padding: 0;}

    div#help a {display: block; text-align: center; font: bold 1em sans-serif; 
       padding: 2px 4px; margin: 0 2 1px; border-width: 0;
       text-decoration: none; color: #ffc; background: #444;
       border-right: none;}
    div#help a:hover {color: #411; background: #AAA;
       display: block;
       margin: 0 0 0px; border-width: 0;
       border-right: none;}
    div#help a span {display: none;}
    div#help a:hover span {display: block;
       position: absolute; top: 70px; left: 0; width: 130px;
       padding: 5px; margin: 10px; z-index: 100;
       color: #000; background: white;
       font: 10px Verdana, sans-serif; text-align: left;}

    div#content {position: absolute; top: 26px; left: 161px; right: 25px;
       color: #BAA; background: #22232F; 
       font: 13px Verdana, sans-serif; padding: 10px; 
       border: solid 5px #444;}
    div#content p {margin: 0 1em 1em;}
    div#content h3 {margin-bottom: 0.25em;}

    h1 {margin: -9px -9px 0.5em; padding: 15px 0 5px; text-align: right; background: #333; color: #667; letter-spacing: 
0.5em; text-transform: lowercase; font: bold 25px sans-serif; height: 28px; vertical-align: middle; white-space: 
nowrap;}
    dt {font-weight: bold;}
    dd {margin-bottom: 0.66em;}
    div#content a:link {color: white;}
    div#content a:visited {color: #BBC;}
    div#content a:link:hover {color: #FF0;}
    div#content a:visited:hover {color: #CC0;}
    code, pre {color: #EDC; font: 110% monospace;}
   -->
  </style>
  <SCRIPT LANGUAGE = "JavaScript" type="TEXT/JAVASCRIPT">
   <!--
function setCookie() {
  cookie_name = "FSWEPPuser";
  days_to_expire = 1;
  expiration_date = new Date();
  expiration_date.setTime(expiration_date.getTime()+ days_to_expire *(24 * 60 * 60 * 1000));
  expiration_date.toGMTString();
  //  document.cookie = cookie_name + "=" + document.unitsform.user_name.value;
  document.cookie = cookie_name + "=" + document.unitsform.user_name.value +
                  ";expires=" + expiration_date +
                  ";path=/";
  //  updateMe();
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
//    document.unitsform.user_name.value = me
    alert('FS WEPP IP: ' + FSWIP)
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
     <th width=50%>Current IP</th>
     <th>Alternate IP</th>
    </tr>

    <tr>
     <td valign="top">
       <div id="help">
        <a><?= @$_SERVER["REMOTE_ADDR"]?></a>
       </div>
<?

exec ("head -n1 -q /var/www/cgi-bin/fswepp/working/166_2_22_221*.par", $result);
foreach ($result as $line)
  echo "$line<br>\n";

?>
     </td>

     <td>
<?php

 $ipsOK=0;
 $ip0=$_REQUEST["ip0"]; $ip1=$_REQUEST["ip1"]; $ip2=$_REQUEST["ip2"]; $ip3=$_REQUEST["ip3"];
//if (isset($ip0) and isset($ip1) and isset($ip2) and isset($ip3)) {
    // validate all numbers
    $altIP=$ip0 . '.' . $ip1 . '.' . $ip2 . '.' . $ip3;
    $altIPu=$ip0 . '_' . $ip1 . '_' . $ip2 . '_' . $ip3;
    $ipsOK=1;
    if (!$ipsOK) {$ip0=''; $ip1=''; $ip2=''; $ip3='';}
    echo "
       <font size=-2 face='tahoma'>
        <input name='ip0' type=text value='$ip0' size=3>.
        <input name='ip1' type=text value='$ip1' size=3>.
        <input name='ip2' type=text value='$ip2' size=3>.
        <input name='ip3' type=text value='$ip3' size=3>
";
//  }
//  else {  

  if (isset($_COOKIE["FSWEPP_IP"]))
  echo $_COOKIE["FSWEPP_IP"];
//}
?>
       <div id="help">
       </div>
<?

$command = "head -n1 -q /var/www/cgi-bin/fswepp/working/" . $altIPu . '*.par';
// echo $command;
exec ($command, $result);
foreach ($result as $line)
  echo "$line<br>\n";

?>

      </font>
     </td>
    </tr>
    <tr>
     <th colspan=2>Climate name: <input name="seek" type=text value='<?php echo $_REQUEST["seek"]; ?>'></th>
    </tr>

    <tr>

<!-- look for PAR files with matching climate name text -->
<!-- limit to 1..10 -->
<!-- create radio button list  O | IP | Climate text    -->

     <td colspan=2> <!-- onclick modify altIP -->
      <input type='radio' name='IP' value='166_2_22_127'>166.2.22.127 -- Moscow ID<br>
      <input type='radio' name='IP' value='166_2_22_126'>166.2.22.126 -- Moscow ID 1<br>
      <input type='radio' name='IP' value='166_2_22_125'>166.2.22.125 -- Moscow ID 2<br>
     </td>
    </tr>
    <tr>
     <th><input type='checkbox' name='setIP'>Accept alternate IP</th>
    </tr>
    <tr>
     <!-- read climates for FS WEPP IP -->
    </tr>
   </table>
  </form>
<?

exec ("fgrep -i 'Winnemucca' -m 1 /var/www/cgi-bin/fswepp/working/166_2_22_245*.par", $result2);
foreach ($result2 as $line)
  echo "$line<br>\n";

?>

 </body>
</html>
