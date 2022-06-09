<html>
 <head>
  <title>
   AWAE BAER Treatment Monitoring Sites
  </title>
 </head>
 <body link=green vlink=blue>
  <font face="gill, trebuchet, tahoma, arial, sans serif">
   <h3>BAER Treatment Monitoring Sites</h3>
<!-- added Twitchell and Willow.  Removed some.  Took gifs out of info page and created a table of charts (now pdfs).  DEH 2014.05.30 -->
  <?php
    $day_limit = 2;
    $sec_limit = $day_limit * 60 * 60 * 24;
    $now=gettimeofday();

//    $twitchell=0; $willow=0; $cedar=0; $fridley=0; $hayman=0; $longpine=0; $roberts=0; $sypah=0; $tripod=0;
    $twitchell=0; $willow=0; $cedar=0;
    $haymanabc=0; $haymandef=0; $haymanwx=0;
    $tripod=0;

//  echo "It is now " . $now[sec] . "<br>\n";
//  echo " limit: " . $sec_limit . "<br>\n";
    $files = (glob("*.pdf"));
    foreach ($files as $file) {
//    echo $file . " last modified: ".date("F d Y H:i:s.",filemtime($file)) . " (";
      $filedate=date("F d Y H:i:s",filemtime($file));
      $seconds_old = $now[sec] - filemtime($file);
//    echo $seconds_old . " seconds old) ";
      if ($seconds_old < $sec_limit) {
        if (preg_match("/twitchell/i",$file)) {$twitchell=1; $twitchell_date=$filedate;}
        if (preg_match("/willow/i",$file))    {$willow=1; $willow_date=$filedate;}
        if (preg_match("/cedar/i",$file))     {$cedar=1; $cedar_date=$filedate;}
        if (preg_match("/haymanabc/i",$file)) {$haymanabc=1; $haymanabc_date=$filedate;}
        if (preg_match("/haymandef/i",$file)) {$haymandef=1; $haymandef_date=$filedate;}
        if (preg_match("/haymanwx/i",$file))  {$haymanwx=1; $haymanwx_date=$filedate;}
//      if (preg_match("/sypah/i",$file))   {$sypah=1; $sypah_date=$filedate;}
//      if (preg_match("/trigo/i",$file))     {$trigo=1; $trigo_date=$filedate;}
        if (preg_match("/tripod/i",$file))    {$tripod=1; $tripod_date=$filedate;}
//      echo "  <img src=\"$file\"><br>\n";
//      echo $file . " last modified: ".date("F d Y H:i:s.",filemtime($file)) . " <br>\n";
      }
    }
  ?>
  <h4>Paired watershed sites, with telemetry -- yellow background indicates graphs updated within the last <?php echo $day_limit ?> days</h4>
   <table border=1>
    <tr bgcolor=lightblue>
     <th>Site</th><th>State</th><th colspan=3>Graphs</th>
    </tr>
    <tr><td><a href="cedar.html">Cedar</a></td><td>CA</td>
        <td <?php if ($cedar)     {echo "bgcolor=yellow>";} ?> <a href="cedar.pdf"     <?php echo "title=\"Updated $cedar_date\">Hydromulch</a>" ?></td>
    </tr>
    <tr><td><a href="hayman.html">Hayman</a></td><td>CO</td>
        <td <?php if ($haymanabc) {echo "bgcolor=yellow>";} ?> <a href="haymanabc.pdf" <?php echo "title=\"Updated $haymanabc_date\">Logs and salvage</a>" ?></td>
        <td <?php if ($haymandef) {echo "bgcolor=yellow>";} ?> <a href="haymandef.pdf" <?php echo "title=\"Updated $haymandef_date\">Mulch erosion</a>" ?></td>
        <td <?php if ($haymanwx)  {echo "bgcolor=yellow>";} ?> <a href="haymanwx.pdf"  <?php echo "title=\"Updated $haymanwx_date\">Weather</a>" ?></td>
    </tr>
    <tr><td><a href="tripod.html">Tripod</a></td><td>WA</td>
        <td <?php if ($tripod)    {echo "bgcolor=yellow>";} ?> <a href="tripodwx.pdf"  <?php echo "title=\"Updated $tripod_date\">Weather</a>" ?></td>
    </tr>
    <tr><td><a href="info/Twitchell_info.pdf">Twitchell</a></td><td>UT</td>
        <td <?php if ($twitchell) {echo "bgcolor=yellow>";} ?> <a href="twitchell.pdf" <?php echo "title=\"Updated $twitchell_date\">Watershed</a>" ?></td>
    </tr>
    <tr><td><a href="info/willow_info.pdf">Willow</a></td><td>AZ</td>
        <td <?php if ($willow)    {echo "bgcolor=yellow>";} ?> <a href="willow.pdf"    <?php echo "title=\"Updated $willow_date\">Watershed</a>" ?></td>
    </tr>
   </table>

<!-- Silt fence monitoring sites, without telemetry -->
<!-- a href="HotCreek.html" -->
<!-- a href="Indian.html" -->
<!-- a href="MyrtleCreek.html" -->
<!-- a href="RedEagle.html" -->
<!-- a href="School.html" -->
<!-- a href="ShakeTable.html" -->
<!-- a href="Tripod.html">Tripod (WA) -->

<h4>Former monitoring sites</h4>
    <a href="Fridley.html">Fridley/West Pine (MT)</a><br>
    <a href="LongPine.html">Long Pine (MT)</a><br>
    <a href="MedicineTree.html">Medicine Tree (MT)</a><br>
    <a href="MixingFire.html">Mixing (CA)</a><br>
    <a href="North25.html">North 25 (WA)</a><br>
    <a href="RobertsFire.html">Roberts (MT)</a><br>
  </font>
 </body>
</html>

