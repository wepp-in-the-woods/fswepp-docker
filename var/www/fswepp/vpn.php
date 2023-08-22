<html>
 <head>
 </head>
 <body>

<!-- read search term; seek and fill in table -->
<!-- read FSWEPP_IP cookie                    -->
  <form name="vpn" action="vpn.php" method="get">
   <table border=1>
    <tr>
     <th width=50%>Current IP</th>
     <th>Alternate IP</th>
    </tr>
    <tr>
     <td><?= @$_SERVER["REMOTE_ADDR"]?></td>
     <td><div name="IPcookie">--not set--</div></td>
    </tr>
    <tr>
     <th colspan=2>Climate name: <input type=text value=""></th>
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
 </body>
</html>
