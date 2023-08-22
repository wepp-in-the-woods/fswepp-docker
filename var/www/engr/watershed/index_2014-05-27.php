<html>
 <head>
  <title>
   AWAE BAER Treatment Monitoring Sites
  </title>
 </head>
 <body>
  <font face="gill, trebuchet, tahoma, arial, sans serif">
   <h3>BAER Treatment Monitoring Sites</h3>
  <?php
    $day_limit = 14;
    $sec_limit = $day_limit * 60 * 60 * 24;
    $now=gettimeofday();

    $cannon=0; $cedar=0; $fridley=0; $hayman=0; $longpine=0; $roberts=0; $sypah=0; $tripod=0;
    

//  echo "It is now " . $now[sec] . "<br>\n";
//  echo " limit: " . $sec_limit . "<br>\n";
    $files = (glob("*.pdf"));
    foreach ($files as $file) {
//      echo $file . " last modified: ".date("F d Y H:i:s.",filemtime($file)) . " (";
        $filedate=date("F d Y H:i:s.",filemtime($file));
      $seconds_old = $now[sec] - filemtime($file);
//      echo $seconds_old . " seconds old) ";
      if ($seconds_old < $sec_limit) {
        if (preg_match("/cannon/i",$file))  {$cannon=1; $cannon_date=$filedate;}
        if (preg_match("/cedar/i",$file))   {$cedar=1; $cedar_date=$filedate;}
        if (preg_match("/haym/i",$file))    {$hayman=1; $hayman_date=$filedate;}
//        if (preg_match("/sypah/i",$file))   {$sypah=1; $sypah_date=$filedate;}
        if (preg_match("/trigo/i",$file))   {$trigo=1; $trigo_date=$filedate;}
        if (preg_match("/tripod/i",$file))  {$tripod=1; $tripod_date=$filedate;}
//        echo "  <img src=\"$file\"><br>\n";
//        echo $file . " last modified: ".date("F d Y H:i:s.",filemtime($file)) . " <br>\n";
      }
    }
  ?>
  <h4>Paired watershed sites, with telemetry -- reporting within last <?php echo $day_limit ?> days</h4>
  <h4>
    <?php if ($cannon)   {echo "<a href=\"Cannon.html\">";} ?>   Cannon (CA)</a><font size=-1> <?php echo $cannon_date ?></font><br>
    <?php if ($cedar)    {echo "<a href=\"Cedar.html\">";} ?>   Cedar (CA)</a><font size=-1> <?php echo $cedar_date ?></font><br>
    <?php if ($hayman)   {echo "<a href=\"Hayman.html\">";} ?>   Hayman (CO)</a><font size=-1> <?php echo $hayman_date ?></font><br>
    <?php if ($trigo)    {echo "<a href=\"Trigo.html\">";} ?>   Trigo (NM)</a><font size=-1> <?php echo $trigo_date ?></font><br>
    <?php if ($tripod)   {echo "<a href=\"Tripod.html\">";} ?>   Tripod (WA)</a><font size=-1> <?php echo $tripod_date ?></font><br>
   </h4>

<h4>Silt fence monitoring sites, without telemetry</h4>
<!-- a href="HotCreek.html" -->
<!-- a href="Indian.html" -->
<!-- a href="MyrtleCreek.html" -->
<a href="RedEagle.html">Red Eagle (MT)</a><br>
<a href="School.html">School (WA)</a><br>
<!-- a href="ShakeTable.html" -->
<a href="Tripod.html">Tripod (WA)</a><br>

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

