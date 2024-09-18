<html>
 <head>
<?php
    $me = $_POST["fs_mail"]; if ($me == '') {$me = "dehall";} 
    $location = $_POST["location"]; if ($location = '') {$location = 'unassigned'; $location_no = 0;}
?>
<?php // try to open file $me if exists read fsmail, user name, location, points weekly points one-time then actions //



//$handle = fopen("inputfile.txt", "r");
//if ($handle) {
//    while (($line = fgets($handle)) !== false) {
//        // process the line read.
//    }
//} else {
//    // error opening the file.
//} 
//fclose($handle);
//
////  when your 'while fgets' loop ends, check feof; if not true, then you had an error.
//$filename = "test.txt;
//$source_file = fopen( $filename, "r" ) or die("Couldn't open $filename");
//while (!feof($source_file)) {...

// https://stackoverflow.com/questions/13246597/how-to-read-a-file-line-by-line-in-php


// dummy values

  $pointsw = 300;
  $pointso = 0;
  $e1_1=1;
  $e2_2=1;

  ?>
  <script language=javascript>

   function do_math() {
     e_1(document.forms["input"])
     e_2(document.forms["input"])
     e_3(document.forms["input"])
     w_1(document.forms["input"])
     w_2(document.forms["input"])
     t_1(document.forms["input"])
     t_2(document.forms["input"])
     r_1(document.forms["input"])
     r_2(document.forms["input"])
     r_3(document.forms["input"])
     p_1(document.forms["input"])
     p_2(document.forms["input"])
     p_3(document.forms["input"])
     p_4(document.forms["input"])
     s_1(document.forms["input"])
     s_2(document.forms["input"])
     s_3(document.forms["input"])
   }

   function sub_total() {
// alert('subtotal calc')
    e1p = Number(document.getElementById("e1_points").innerHTML)
    e2p = Number(document.getElementById("e2_points").innerHTML)
    e3p = Number(document.getElementById("e3_points").innerHTML)
    w1p = Number(document.getElementById("w1_points").innerHTML)
    w2p = Number(document.getElementById("w2_points").innerHTML)
    t1p = Number(document.getElementById("t1_points").innerHTML)
    t2p = Number(document.getElementById("t2_points").innerHTML)
    t3p = Number(document.getElementById("t3_points").innerHTML)
    r1p = Number(document.getElementById("r1_points").innerHTML)
    r2p = Number(document.getElementById("r2_points").innerHTML)
    r3p = Number(document.getElementById("r3_points").innerHTML)
    r4p = Number(document.getElementById("r4_points").innerHTML)
    p1p = Number(document.getElementById("p1_points").innerHTML)
    p2p = Number(document.getElementById("p2_points").innerHTML)
    p3p = Number(document.getElementById("p3_points").innerHTML)
    p4p = Number(document.getElementById("p4_points").innerHTML)
    s1p = Number(document.getElementById("s1_points").innerHTML)
    s2p = Number(document.getElementById("s2_points").innerHTML)
    s3p = Number(document.getElementById("s3_points").innerHTML)
    sub_tot=0
    sub_tot = sub_tot + e1p + e2p + e3p
    sub_tot = sub_tot + w1p + w2p
    sub_tot = sub_tot + t1p + t2p + t3p
    sub_tot = sub_tot + r1p + r2p + r3p + r4p
    sub_tot = sub_tot + p1p + p2p + p3p + p4p
    sub_tot = sub_tot + s1p + s2p + s3p
    document.getElementById("subtotal").innerHTML = sub_tot
   }
   function e_1(frm) {
    e1pts=0
    if (frm.e1[0].checked) {e1pts++}
    if (frm.e1[1].checked) {e1pts++}
    if (frm.e1[2].checked) {e1pts++}
    if (frm.e1[3].checked) {e1pts++}
    if (frm.e1[4].checked) {e1pts++}
    if (frm.e1[5].checked) {e1pts++}
    document.getElementById("e1_points").innerHTML = e1pts * 150
    sub_total()
   }
   function e_2(frm) {
    e2pts=0
    if (frm.e2[0].checked) {e2pts++}
    if (frm.e2[1].checked) {e2pts++}
    if (frm.e2[2].checked) {e2pts++}
    if (frm.e2[3].checked) {e2pts++}
    if (frm.e2[4].checked) {e2pts++}
    if (frm.e2[5].checked) {e2pts++}
    document.getElementById("e2_points").innerHTML = e2pts * 300
    sub_total()
   }
   function e_3(frm) {
    e3pts=0
    if (frm.e3[0].checked) {e3pts++}
    if (frm.e3[1].checked) {e3pts++}
    if (frm.e3[2].checked) {e3pts++}
    if (frm.e3[3].checked) {e3pts++}
    if (frm.e3[4].checked) {e3pts++}
    if (frm.e3[5].checked) {e3pts++}
    document.getElementById("e3_points").innerHTML = e3pts * 150
    sub_total()
   }

   function w_1(frm) {
    w1pts=0
    if (frm.w1[0].checked) {w1pts++}
    if (frm.w1[1].checked) {w1pts++}
    if (frm.w1[2].checked) {w1pts++}
    if (frm.w1[3].checked) {w1pts++}
    if (frm.w1[4].checked) {w1pts++}
    if (frm.w1[5].checked) {w1pts++}
    document.getElementById("w1_points").innerHTML = w1pts * 100
    sub_total()
   }
   function w_2(frm) {
    w2pts=0
    if (frm.w2[0].checked) {w2pts++}
    if (frm.w2[1].checked) {w2pts++}
    if (frm.w2[2].checked) {w2pts++}
    if (frm.w2[3].checked) {w2pts++}
    if (frm.w2[4].checked) {w2pts++}
    if (frm.w2[5].checked) {w2pts++}
    document.getElementById("w2_points").innerHTML = w2pts * 100
    sub_total()
   }

   function t_1(frm) {
    t1pts=0
    if (frm.t1[0].checked) {t1pts++}
    if (frm.t1[1].checked) {t1pts++}
    if (frm.t1[2].checked) {t1pts++}
    if (frm.t1[3].checked) {t1pts++}
    if (frm.t1[4].checked) {t1pts++}
    if (frm.t1[5].checked) {t1pts++}
    document.getElementById("t1_points").innerHTML = t1pts * 250
    sub_total()
   }
   function t_2(frm) {
    t2pts=0
    if (frm.t2[0].checked) {t2pts++}
    if (frm.t2[1].checked) {t2pts++}
    if (frm.t2[2].checked) {t2pts++}
    if (frm.t2[3].checked) {t2pts++}
    if (frm.t2[4].checked) {t2pts++}
    if (frm.t2[5].checked) {t2pts++}
    document.getElementById("t2_points").innerHTML = t2pts * 150
    sub_total()
   }
   function t_3(frm) {
    t3pts=0
//    if (frm.t3[0]>0 && frm.t3[0]<6) {t3pts++}
//    if (frm.t3[1].checked) {t3pts++}
//    if (frm.t3[2].checked) {t3pts++}
//    if (frm.t3[3].checked) {t3pts++}
//    if (frm.t3[4].checked) {t3pts++}
//    if (frm.t3[5].checked) {t3pts++}
//    document.getElementById("t3_points").innerHTML = t3pts * 100
    sub_total()
   }

   function r_1(frm) {
    r1pts=0
    if (frm.r1[0].checked) {r1pts++}
    if (frm.r1[1].checked) {r1pts++}
    if (frm.r1[2].checked) {r1pts++}
    if (frm.r1[3].checked) {r1pts++}
    if (frm.r1[4].checked) {r1pts++}
    if (frm.r1[5].checked) {r1pts++}
    document.getElementById("r1_points").innerHTML = r1pts * 150
    sub_total()
   }
   function r_2(frm) {
    r2pts=0
    if (frm.r2[0].checked) {r2pts++}
    if (frm.r2[1].checked) {r2pts++}
    if (frm.r2[2].checked) {r2pts++}
    if (frm.r2[3].checked) {r2pts++}
    if (frm.r2[4].checked) {r2pts++}
    if (frm.r2[5].checked) {r2pts++}
    document.getElementById("r2_points").innerHTML = r2pts * 300
    sub_total()
   }
   function r_3(frm) {
    r3pts=0
    if (frm.r3[0].checked) {r3pts++}
    if (frm.r3[1].checked) {r3pts++}
    if (frm.r3[2].checked) {r3pts++}
    if (frm.r3[3].checked) {r3pts++}
    if (frm.r3[4].checked) {r3pts++}
    if (frm.r3[5].checked) {r3pts++}
    document.getElementById("r3_points").innerHTML = r3pts * 100
    sub_total()
   }
   function r_4(frm) {
    r4pts=0
//    if (frm.r4[0]>0 && frm.r4[0]<6) {r4pts++}
//    if (frm.r4[1].checked) {r4pts++}
//    if (frm.r4[2].checked) {r4pts++}
//    if (frm.r4[3].checked) {r4pts++}
//    if (frm.r4[4].checked) {r4pts++}
//    if (frm.r4[5].checked) {r4pts++}
//    document.getElementById("r4_points").innerHTML = r4pts * 100
    sub_total()
   }

   function p_1(frm) {
    p1pts=0
    if (frm.p1[0].checked) {p1pts++}
    if (frm.p1[1].checked) {p1pts++}
    if (frm.p1[2].checked) {p1pts++}
    if (frm.p1[3].checked) {p1pts++}
    if (frm.p1[4].checked) {p1pts++}
    if (frm.p1[5].checked) {p1pts++}
    document.getElementById("p1_points").innerHTML = p1pts * 100
    sub_total()
   }
   function p_2(frm) {
    p2pts=0
    if (frm.p2[0].checked) {p2pts++}
    if (frm.p2[1].checked) {p2pts++}
    if (frm.p2[2].checked) {p2pts++}
    if (frm.p2[3].checked) {p2pts++}
    if (frm.p2[4].checked) {p2pts++}
    if (frm.p2[5].checked) {p2pts++}
    document.getElementById("p2_points").innerHTML = p2pts * 100
    sub_total()
   }
   function p_3(frm) {
    p3pts=0
    if (frm.p3[0].checked) {p3pts++}
    if (frm.p3[1].checked) {p3pts++}
    if (frm.p3[2].checked) {p3pts++}
    if (frm.p3[3].checked) {p3pts++}
    if (frm.p3[4].checked) {p3pts++}
    if (frm.p3[5].checked) {p3pts++}
    document.getElementById("p3_points").innerHTML = p3pts * 100
    sub_total()
   }
   function p_4(frm) {
    p4pts=0
    if (frm.p4[0].checked) {p4pts++}
    if (frm.p4[1].checked) {p4pts++}
    if (frm.p4[2].checked) {p4pts++}
    if (frm.p4[3].checked) {p4pts++}
    if (frm.p4[4].checked) {p4pts++}
    if (frm.p4[5].checked) {p4pts++}
    document.getElementById("p4_points").innerHTML = p4pts * 100
    sub_total()
   }

   function s_1(frm) {
    s1pts=0
    if (frm.s1[0].checked) {s1pts++}
    if (frm.s1[1].checked) {s1pts++}
    if (frm.s1[2].checked) {s1pts++}
    if (frm.s1[3].checked) {s1pts++}
    if (frm.s1[4].checked) {s1pts++}
    if (frm.s1[5].checked) {s1pts++}
    document.getElementById("s1_points").innerHTML = s1pts * 100
    sub_total()
   }
   function s_2(frm) {
    s2pts=0
    if (frm.s2[0].checked) {s2pts++}
    if (frm.s2[1].checked) {s2pts++}
    if (frm.s2[2].checked) {s2pts++}
    if (frm.s2[3].checked) {s2pts++}
    if (frm.s2[4].checked) {s2pts++}
    if (frm.s2[5].checked) {s2pts++}
    document.getElementById("s2_points").innerHTML = s2pts * 100
    sub_total()
   }
   function s_3(frm) {
    s3pts=0
    if (frm.s3[0].checked) {s3pts++}
    if (frm.s3[1].checked) {s3pts++}
    if (frm.s3[2].checked) {s3pts++}
    if (frm.s3[3].checked) {s3pts++}
    if (frm.s3[4].checked) {s3pts++}
    if (frm.s3[5].checked) {s3pts++}
    document.getElementById("s3_points").innerHTML = s3pts * 300
    sub_total()
   }

  </script>
 </head>
 <body onLoad="do_math()">
  <font face="trebuchet, tahoma, arial, sans serif">
   <table border=0 width=100%><tr bgcolor=darkgreen><th><h3><font color=white>Get Your Game 'Green' On: Summit Mt. Sustainability</font></h3></th></tr></table>
   <form name="input" id="input" action="write_contest_data.php" method="post">
    <table border=1>
     <tr><th><?php echo $me ?></th>
         <th colspan=8 bgcolor=pink>Location 
        <select size=1>
  <option value="--">Please select one</option>
  <option value="Moscow"     <?php if ($location_no == 1) {echo "selected";}?>>Moscow</option>
  <option value="MSLA Fire"  <?php if ($location_no == 2) {echo "selected";}?>>Missoula Fire</option>
  <option value="MSLA FSL"   <?php if ($location_no == 3) {echo "selected";}?>>Missoula FSL</option>
  <option value="Reno"       <?php if ($location_no == 4) {echo "selected";}?>>Reno FSL</option>
  <option value="Flagstaff"  <?php if ($location_no == 5) {echo "selected";}?>>Flagstaff FSL</option>
  <option value="Boise"      <?php if ($location_no == 6) {echo "selected";}?>>Boise FSL</option>
  <option value="Ogden"      <?php if ($location_no == 7) {echo "selected";}?>>Ogden</option>
        </select>
      <th>
     </tr>
     <tr bgcolor="lightgreen"><th>FOCUS</th><th colspan=6>WEEK</th><th>POINTS</th><th>ACTIVITY</th></tr>
     <tr bgcolor="lightgreen"><th></th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th><td align=right><span id="subtotal"><?php echo $pointsw; ?></span></td></tr>

<!-- ENERGY -->
     <tr>
      <th rowspan=3 bgcolor="lightgreen"><h3>Energy</h3></th>
      <th title='150 points'><input type=checkbox name=e1 onClick='javascript:e_1(this.form)' <?php if ($e1_1) echo "checked"; ?>></th>
      <th title='150 points'><input type=checkbox name=e1 onClick='javascript:e_1(this.form)' <?php if ($e1_2) echo "checked"; ?>></th>
      <th title='150 points'><input type=checkbox name=e1 onClick='javascript:e_1(this.form)' <?php if ($e1_3) echo "checked"; ?>></th>
      <th title='150 points'><input type=checkbox name=e1 onClick='javascript:e_1(this.form)' <?php if ($e1_4) echo "checked"; ?>></th>
      <th title='150 points'><input type=checkbox name=e1 onClick='javascript:e_1(this.form)' <?php if ($e1_5) echo "checked"; ?>></th>
      <th title='150 points'><input type=checkbox name=e1 onClick='javascript:e_1(this.form)' <?php if ($e1_6) echo "checked"; ?>></th>
      <td align=right><span id='e1_points'></span></td>
      <td>Turned off computer at night for at least 4 out of 5 workdays</td>
    </tr>
    <tr>
      <th title='300 points'><input type=checkbox name=e2 onClick='javascript:e_2(this.form)' <?php if ($e2_1) echo "checked"; ?>></th>
      <th title='300 points'><input type=checkbox name=e2 onClick='javascript:e_2(this.form)' <?php if ($e2_2) echo "checked"; ?>></th>
      <th title='300 points'><input type=checkbox name=e2 onClick='javascript:e_2(this.form)' <?php if ($e2_3) echo "checked"; ?>></th>
      <th title='300 points'><input type=checkbox name=e2 onClick='javascript:e_2(this.form)' <?php if ($e2_4) echo "checked"; ?>></th>
      <th title='300 points'><input type=checkbox name=e2 onClick='javascript:e_2(this.form)' <?php if ($e2_5) echo "checked"; ?>></th>
      <th title='300 points'><input type=checkbox name=e2 onClick='javascript:e_2(this.form)' <?php if ($e2_6) echo "checked"; ?>></th>
      <td align=right><span id='e2_points'></span></td>
      <td>Unplugged computer over the weekend (<em>Power IT Down</em>)</td>
     </tr>
     <tr>
      <th title='150 points'><input type=checkbox name=e3 onClick='javascript:e_3(this.form)'></th>
      <th title='150 points'><input type=checkbox name=e3 onClick='javascript:e_3(this.form)'></th>
      <th title='150 points'><input type=checkbox name=e3 onClick='javascript:e_3(this.form)'></th>
      <th title='150 points'><input type=checkbox name=e3 onClick='javascript:e_3(this.form)'></th>
      <th title='150 points'><input type=checkbox name=e3 onClick='javascript:e_3(this.form)'></th>
      <th title='150 points'><input type=checkbox name=e3 onClick='javascript:e_3(this.form)'></th>
      <td align=right><span id='e3_points'></span></td>
      <td>Used task lighting or natural light; this may include overhead lights if 1/2 or more of the ballasts have been removed to reduce glare and conserve energy.</td>
     </tr>

<!-- WATER -->
     <tr><th rowspan=2 bgcolor="lightgreen"><h3>Water</h3></th>
      <th title='100 points'><input type=checkbox name=w1 onClick='javascript:w_1(this.form)'></th>
      <th title='100 points'><input type=checkbox name=w1 onClick='javascript:w_1(this.form)'></th>
      <th title='100 points'><input type=checkbox name=w1 onClick='javascript:w_1(this.form)'></th>
      <th title='100 points'><input type=checkbox name=w1 onClick='javascript:w_1(this.form)'></th>
      <th title='100 points'><input type=checkbox name=w1 onClick='javascript:w_1(this.form)'></th>
      <th title='100 points'><input type=checkbox name=w1 onClick='javascript:w_1(this.form)'></th>
      <td align=right><span id='w1_points'></span></td>
      <td>Used your own bottle as a water source for the week</h3></th>
     </tr>
     <tr>
      <th title='100 points'><input type=checkbox name=w2 onClick='javascript:w_2(this.form)'></th>
      <th title='100 points'><input type=checkbox name=w2 onClick='javascript:w_2(this.form)'></th>
      <th title='100 points'><input type=checkbox name=w2 onClick='javascript:w_2(this.form)'></th>
      <th title='100 points'><input type=checkbox name=w2 onClick='javascript:w_2(this.form)'></th>
      <th title='100 points'><input type=checkbox name=w2 onClick='javascript:w_2(this.form)'></th>
      <th title='100 points'><input type=checkbox name=w2 onClick='javascript:w_2(this.form)'></th>
      <td align=right><span id='w2_points'></span></td>
      <td>While using the sink (for tooth-brushing, washing dishes or hand washing), didn't let the water run continuously</td>
   </tr>

<!-- TRANSPORTATION -->
   <tr><th rowspan=3 bgcolor="lightgreen"><h3>Fleet &amp; Transportation</h3></th>
      <th title='250 points'><input type=checkbox name=t1 onClick='javascript:t_1(this.form)'></th>
      <th title='250 points'><input type=checkbox name=t1 onClick='javascript:t_1(this.form)'></th>
      <th title='250 points'><input type=checkbox name=t1 onClick='javascript:t_1(this.form)'></th>
      <th title='250 points'><input type=checkbox name=t1 onClick='javascript:t_1(this.form)'></th>
      <th title='250 points'><input type=checkbox name=t1 onClick='javascript:t_1(this.form)'></th>
      <th title='250 points'><input type=checkbox name=t1 onClick='javascript:t_1(this.form)'></th>
      <td align=right><span id='t1_points'></span></td>
      <td>Utilized a carpooling initiative or used the most fuel efficient vehicle for the job all week</h3></th>
   </tr>
   <tr>
      <th title='100 points'><input type=checkbox name=t2 onClick='javascript:t_2(this.form)'></th>
      <th title='100 points'><input type=checkbox name=t2 onClick='javascript:t_2(this.form)'></th>
      <th title='100 points'><input type=checkbox name=t2 onClick='javascript:t_2(this.form)'></th>
      <th title='100 points'><input type=checkbox name=t2 onClick='javascript:t_2(this.form)'></th>
      <th title='100 points'><input type=checkbox name=t2 onClick='javascript:t_2(this.form)'></th>
      <th title='100 points'><input type=checkbox name=t2 onClick='javascript:t_2(this.form)'></th>
      <td align=right><span id='t2_points'></span></td>
      <td>Actively practiced Eco-driving principles while using a work vehicle</td>
   </tr>
  <tr>
      <th title='100 points/day'><input type=text size=1 value=0 name=t3 onClick='javascript:t_3(this.form)'></th>
      <th title='100 points/day'><input type=text size=1 value=0 name=t3 onClick='javascript:t_3(this.form)'></th>
      <th title='100 points/day'><input type=text size=1 value=0 name=t3 onClick='javascript:t_3(this.form)'></th>
      <th title='100 points/day'><input type=text size=1 value=0 name=t3 onClick='javascript:t_3(this.form)'></th>
      <th title='100 points/day'><input type=text size=1 value=0 name=t3 onClick='javascript:t_3(this.form)'></th>
      <th title='100 points/day'><input type=text size=1 value=0 name=t3 onClick='javascript:t_3(this.form)'></th>
      <td align=right><span id='t3_points'></span></td>
      <td>Teleworked, carpooled, used a hybrid vehicle, used public transit, biked or walked to and from work (0 to 5) days per week</td>
  </tr>

<!-- RECYCLING -->
  <tr><th rowspan=4 bgcolor="lightgreen"><h3>Waste Prevention &amp; Recycling</h3></th>
      <th title='100 points'><input type=checkbox name=r1 onClick='javascript:r_1(this.form)'></th>
      <th title='100 points'><input type=checkbox name=r1 onClick='javascript:r_1(this.form)'></th>
      <th title='100 points'><input type=checkbox name=r1 onClick='javascript:r_1(this.form)'></th>
      <th title='100 points'><input type=checkbox name=r1 onClick='javascript:r_1(this.form)'></th>
      <th title='100 points'><input type=checkbox name=r1 onClick='javascript:r_1(this.form)'></th>
      <th title='100 points'><input type=checkbox name=r1 onClick='javascript:r_1(this.form)'></th>
      <td align=right><span id='r1_points'></span></td>
      <td>Used Good On One Side (GOOS) paper for notes all week</h3></th>
   </tr>
   <tr>
      <th title='100 points'><input type=checkbox name=r2 onClick='javascript:r_2(this.form)'></th>
      <th title='100 points'><input type=checkbox name=r2 onClick='javascript:r_2(this.form)'></th>
      <th title='100 points'><input type=checkbox name=r2 onClick='javascript:r_2(this.form)'></th>
      <th title='100 points'><input type=checkbox name=r2 onClick='javascript:r_2(this.form)'></th>
      <th title='100 points'><input type=checkbox name=r2 onClick='javascript:r_2(this.form)'></th>
      <th title='100 points'><input type=checkbox name=r2 onClick='javascript:r_2(this.form)'></th>
      <td align=right><span id='r2_points'></span></td>
      <td>Shared information about the recycling operations specific to your location with other employees, new hires, temporary employees or guests</h3></th>
   </tr>
   <tr>
      <th title='300 points'><input type=checkbox name=r3 onClick='javascript:r_3(this.form)'></th>
      <th title='300 points'><input type=checkbox name=r3 onClick='javascript:r_3(this.form)'></th>
      <th title='300 points'><input type=checkbox name=r3 onClick='javascript:r_3(this.form)'></th>
      <th title='300 points'><input type=checkbox name=r3 onClick='javascript:r_3(this.form)'></th>
      <th title='300 points'><input type=checkbox name=r3 onClick='javascript:r_3(this.form)'></th>
      <th title='300 points'><input type=checkbox name=r3 onClick='javascript:r_3(this.form)'></th>
      <td align=right><span id='r3_points'></span></td>
      <td>Recycled at least three different materials (paper, plastic, aluminum, tin, glass, cardboard, compost) at your office</td>
   </tr>
  <tr>
      <th title='100 points/day'><input type=text size=1 value=0 name=r4 onClick='javascript:r_4(this.form)'></th>
      <th title='100 points/day'><input type=text size=1 value=0 name=r4 onClick='javascript:r_4(this.form)'></th>
      <th title='100 points/day'><input type=text size=1 value=0 name=r4 onClick='javascript:r_4(this.form)'></th>
      <th title='100 points/day'><input type=text size=1 value=0 name=r4 onClick='javascript:r_4(this.form)'></th>
      <th title='100 points/day'><input type=text size=1 value=0 name=r4 onClick='javascript:r_4(this.form)'></th>
      <th title='100 points/day'><input type=text size=1 value=0 name=r4 onClick='javascript:r_4(this.form)'></th>
      <td align=right><span id='r4_points'></span></td>
      <td>Packed a "no-impact" lunch (used re-usable containers, etc.) for work (0 to 5) days per week</td>
  </tr>

<!-- PURCHASING -->
  <tr><th rowspan=4 bgcolor="lightgreen"><h3>Green Purchasing</h3></th>
      <th title='100 points'><input type=checkbox name=p1 onClick='javascript:p_1(this.form)'></th>
      <th title='100 points'><input type=checkbox name=p1 onClick='javascript:p_1(this.form)'></th>
      <th title='100 points'><input type=checkbox name=p1 onClick='javascript:p_1(this.form)'></th>
      <th title='100 points'><input type=checkbox name=p1 onClick='javascript:p_1(this.form)'></th>
      <th title='100 points'><input type=checkbox name=p1 onClick='javascript:p_1(this.form)'></th>
      <th title='100 points'><input type=checkbox name=p1 onClick='javascript:p_1(this.form)'></th>
      <td align=right><span id='p1_points'></span></td>
      <td>Used rechargeable batteries</h3></th>
   </tr>
   <tr>
      <th title='100 points'><input type=checkbox name=p2 onClick='javascript:p_2(this.form)'></th>
      <th title='100 points'><input type=checkbox name=p2 onClick='javascript:p_2(this.form)'></th>
      <th title='100 points'><input type=checkbox name=p2 onClick='javascript:p_2(this.form)'></th>
      <th title='100 points'><input type=checkbox name=p2 onClick='javascript:p_2(this.form)'></th>
      <th title='100 points'><input type=checkbox name=p2 onClick='javascript:p_2(this.form)'></th>
      <th title='100 points'><input type=checkbox name=p2 onClick='javascript:p_2(this.form)'></th>
      <td align=right><span id='p2_points'></span></td>
      <td>Purchased a green product that replaced a product purchased in the past</h3></th>
   </tr>
   <tr>
      <th title='100 points'><input type=checkbox name=p3 onClick='javascript:p_3(this.form)'></th>
      <th title='100 points'><input type=checkbox name=p3 onClick='javascript:p_3(this.form)'></th>
      <th title='100 points'><input type=checkbox name=p3 onClick='javascript:p_3(this.form)'></th>
      <th title='100 points'><input type=checkbox name=p3 onClick='javascript:p_3(this.form)'></th>
      <th title='100 points'><input type=checkbox name=p3 onClick='javascript:p_3(this.form)'></th>
      <th title='100 points'><input type=checkbox name=p3 onClick='javascript:p_3(this.form)'></th>
      <td align=right><span id='p3_points'></span></td>
      <td>Purchased 100% post-consumer recycled content paper</h3></th>
   </tr>
   <tr>
      <th title='100 points'><input type=checkbox name=p4 onClick='javascript:p_4(this.form)'></th>
      <th title='100 points'><input type=checkbox name=p4 onClick='javascript:p_4(this.form)'></th>
      <th title='100 points'><input type=checkbox name=p4 onClick='javascript:p_4(this.form)'></th>
      <th title='100 points'><input type=checkbox name=p4 onClick='javascript:p_4(this.form)'></th>
      <th title='100 points'><input type=checkbox name=p4 onClick='javascript:p_4(this.form)'></th>
      <th title='100 points'><input type=checkbox name=p4 onClick='javascript:p_4(this.form)'></th>
      <td align=right><span id='p4_points'></span></td>
      <td>Purchased from the Biopreferred catalog - https://www.biopreferred.gov/bioPreferredCatalog/faces/jsp/catalogLanding.jsp</td>
   </tr>

<!-- SUSTAINABILITY -->
  <tr><th rowspan=3 bgcolor="lightgreen"><h3>Sustainability Leadership</h3></th>
      <th title='100 points'><input type=checkbox name=s1 onClick='javascript:s_1(this.form)'></th>
      <th title='100 points'><input type=checkbox name=s1 onClick='javascript:s_1(this.form)'></th>
      <th title='100 points'><input type=checkbox name=s1 onClick='javascript:s_1(this.form)'></th>
      <th title='100 points'><input type=checkbox name=s1 onClick='javascript:s_1(this.form)'></th>
      <th title='100 points'><input type=checkbox name=s1 onClick='javascript:s_1(this.form)'></th>
      <th title='100 points'><input type=checkbox name=s1 onClick='javascript:s_1(this.form)'></th>
      <td align=right><span id='s1_points'></span></td>
      <td>Visited the RMRS Green Team Website: https://fsweb.rmrs.fs.fed.us/sustainable-operations</h3></th>
   </tr>
   <tr>
      <th title='100 points'><input type=checkbox name=s2 onClick='javascript:s_2(this.form)'></th>
      <th title='100 points'><input type=checkbox name=s2 onClick='javascript:s_2(this.form)'></th>
      <th title='100 points'><input type=checkbox name=s2 onClick='javascript:s_2(this.form)'></th>
      <th title='100 points'><input type=checkbox name=s2 onClick='javascript:s_2(this.form)'></th>
      <th title='100 points'><input type=checkbox name=s2 onClick='javascript:s_2(this.form)'></th>
      <th title='100 points'><input type=checkbox name=s2 onClick='javascript:s_2(this.form)'></th>
      <td align=right><span id='s2_points'></span></td>
      <td>Visited the Sustainable Operations Demonstration Website: https://dvspdevpoc/sites/sus-ops</h3></th>
   </tr>
   <tr>
      <th title='350 points'><input type=checkbox name=s3 onClick='javascript:s_3(this.form)'></th>
      <th title='350 points'><input type=checkbox name=s3 onClick='javascript:s_3(this.form)'></th>
      <th title='350 points'><input type=checkbox name=s3 onClick='javascript:s_3(this.form)'></th>
      <th title='350 points'><input type=checkbox name=s3 onClick='javascript:s_3(this.form)'></th>
      <th title='350 points'><input type=checkbox name=s3 onClick='javascript:s_3(this.form)'></th>
      <th title='350 points'><input type=checkbox name=s3 onClick='javascript:s_3(this.form)'></th>
      <td align=right><span id='s3_points'></span></td>
      <td>Added SusOps tips to weekly staff notes or incorporated a SusOps discussions into staff meetings</td>
   </tr>
  </table>

<br><br>

 <table border=1>

  <tr bgcolor="lightgreen"><th>FOCUS</th><th></th><th>POINTS</th><th>ACTIVITY</th></tr>
  <tr><th></th><td></td><td align=right><span id="osubtotal">0</span></td></tr>

<!-- ENERGY -->
  <tr><th bgcolor=lightgreen rowspan=4><h3>Energy</h3></th>
      <th title='500 points'><input type=checkbox name=oe1 onClick='javascript:oe_1(this.form)'></th>
      <td align=right><span id='oe1_points'></span></td>
      <td> Created a list of folks who feel their overhead lights are too bright and have janitorial staff remove ballasts to reduce light usage (500 pts)</td>
  </tr>
  <tr>
      <th title='500 points'><input type=checkbox name=oe2 onClick='javascript:oe_2(this.form)'></th>
      <td align=right><span id='oe2_points'></span></td>
      <td> Installed Smart Strip device (500 pts)</td>
   </tr>
   <tr>
      <th title='1000 points'><input type=checkbox name=oe3 onClick='javascript:oe_3(this.form)'></th>
      <td align=right><span id='oe3_points'></span></td>
      <td> Purchased an Energy Star qualified appliance (1000 pts)</td>
   </tr>
   <tr>
      <th title='1500 points'><input type=checkbox name=oe4 onClick='javascript:oe_4(this.form)'></th>
      <td align=right><span id='oe4_points'></span></td>
      <td>  Instituted a "Shut off lights and computers at night" policy and designated a person to monitor and track compliance (1500 pts)</td>
   </tr>

<!-- WATER -->
  <tr><th bgcolor=lightgreen rowspan=3><h3>Water</h3></th>
      <th title='300 points'><input type=checkbox name=ow1 onClick='javascript:ow_1(this.form)'></th>
      <td align=right><span id='ow1_points'></span></td>
      <td> Reported a water leak that you have seen or are aware of to facilities management to conserve water (300 pts)</th>
   </tr>
   <tr>
      <th title='1000 points'><input type=checkbox name=ow2 onClick='javascript:ow_2(this.form)'></th>
      <td align=right><span id='ow2_points'></span></td>
      <td> Helped plan or developed a water awareness activity for all employees at your unit (1000 pts)</td>
   </tr>
   <tr>
      <th title='1500 points'><input type=checkbox name=ow3 onClick='javascript:ow_3(this.form)'></th>
      <td align=right><span id='ow3_points'></span></td>
      <td> Provided facility management with "top water-consuming" data and suggestions for what improvements could be made (1500 pts)</td>
   </tr>

 
<!-- TRANSPORTATION -->
  <tr><th bgcolor=lightgreen rowspan=5><h3>Fleet &amp; Transportation</h3></th>
      <th title='300 points'><input type=checkbox name=ot1 onClick='javascript:ot_1(this.form)'></th>
      <td align=right><span id='ot1_points'></span></td>
      <td> Posted fuel economy flyer in the motor pool area to encourage most fuel efficient vehicle for the job (300 pts)</td>
   </tr>
   <tr>
      <th title='300 points'><input type=checkbox name=ot2 onClick='javascript:ot_2(this.form)'></th>
      <td align=right><span id='ot2_points'></span></td>
      <td> Promoted alternative forms of commuting (300 pts)</td>
  </tr>
  <tr>
      <th title='500 points'><input type=checkbox name=ot3 onClick='javascript:ot_3(this.form)'></th>
      <td align=right><span id='ot3_points'></span></td>
      <td> Completed a telework agreement for yourself or already have one in place (500 pts)</td>
  </tr>
  <tr>
      <th title='1500 points'><input type=checkbox name=ot4 onClick='javascript:ot_4(this.form)'></th>
      <td align=right><span id='ot4_points'></span></td>
      <td> Implemented a car pooling initiative to share information via a calendar to encourage work ride shares (1500 pts)</td>
  </tr>
  <tr>
      <th title='400 points'><input type=checkbox name=ot5 onClick='javascript:ot_5(this.form)'></th>
      <td align=right><span id='ot5_points'></span></td>
      <td> Shared eco-driving tips with other employees, new hires, temporary employees, or guests (400 pts)</td>
  </tr>
 
<!-- RECYCLING -->
  <tr><th bgcolor=lightgreen rowspan=10><h3>Waste Prevention &amp; Recycling</h3></th>
      <th title='300 points'><input type=checkbox name=or1 onClick='javascript:or_1(this.form)'></th>
      <td align=right><span id='or1_points'></span></td>
      <td> Made several Good On One Side (GOOS) paper note pads for use in the office (300 pts)</td>
   </tr>
   <tr>
      <th title='300 points'><input type=checkbox name=or2 onClick='javascript:or_2(this.form)'></th>
     <td align=right><span id='or2_points'></span></td>
      <td> Dedicated one printer for GOOS only paper (300 pts)</td>
   </tr>
   <tr>
      <th title='300 points'><input type=checkbox name=or3 onClick='javascript:or_3(this.form)'></th>
      <td align=right><span id='or3_points'></span></td>
      <td> Set up computer to not print banner sheets (take credit if you have already completed this..good job!) (300 pts)</td>
   </tr>
  <tr>
     <th title='300 points'><input type=checkbox name=or4 onClick='javascript:or_3(this.form)'></th>
     <td align=right><span id='or4_points'></span></td>
     <td> Set copier driver defaults to double-sided copying
          (everyone who assisted in finding who has administrative rights, etc. gets points) (300 points)</td>
  </tr>
  <tr>
     <th title='500 points'><input type=checkbox name=or5 onClick='javascript:or_5(this.form)'></th>
     <td align=right><span id='or5_points'></span></td>
     <td> Created a junk mailbox at facility &amp; found volunteers to reduce junk mail by periodically removing RMRS or old employees off vendors list using
         <a href="https://www.ecologicalmail.org">www.ecologicalmail.org</a> (500 pts)</td>
  </tr>
  <tr>
     <th title='1000 points'><input type=checkbox name=or6 onClick='javascript:or_6(this.form)'></th>
     <td align=right><span id='or6_points'></span></td>
     <td> Completed a waste stream analysis at location (1000 pts)</td>
  </tr>
  <tr>
     <th title='1000 points'><input type=checkbox name=or7 onClick='javascript:or_7(this.form)'></th>
     <td align=right><span id='or7_points'></span></td>
     <td> Started a composting program at work (1000 pts)</td>
  </tr>
  <tr>
     <th title='1000 points'><input type=checkbox name=or8 onClick='javascript:or_8(this.form)'></th>
     <td align=right><span id='or8_points'></span></td>
     <td> Implemented a policy at your facility to retain recycling proceeds to reinvest in other sustainable operation activities (some facilities may already have other programs in place) (1000 pts)</td>
  </tr>
  <tr>
     <th title='500 points'><input type=checkbox name=or9 onClick='javascript:or_9(this.form)'></th>
     <td align=right><span id='or9_points'></span></td>
     <td> <em>Canned your Can!</em> Got rid of a trash bin in your office space to conserve bin liners by sharing fewer trash cans (500 pts)</td>
  </tr>
  <tr>
     <th title='300 points'><input type=checkbox name=or10 onClick='javascript:or_10(this.form)'></th>
     <td align=right><span id='or10_points'></span></td>
     <td> Assisted in switching a printer to print double sided (give credit if you have already done this for your computer!) (300 pts)</td>
  </tr>
 
<!-- PURCHASING --> 
  <tr><th bgcolor=lightgreen rowspan=3><h3>Green Purchasing</h3></th>
      <th title='200 points'><input type=checkbox name=op1 onClick='javascript:op_1(this.form)'></th>
      <td align=right><span id='op1_points'></span></td>
      <td> Added GSA's <em>Sustainability Tool</em> to your Favorites:
           <a href="https://sftool.gov/GreenProcurement">sftool.gov/GreenProcurement</a> (provides a list of Green Products) (200 pts)</td>
   </tr>
   <tr>
      <th title='200 points'><input type=checkbox name=op2 onClick='javascript:op_2(this.form)'></th>
      <td align=right><span id='op2_points'></span></td>
      <td> Added USDA's <em>BioPreferred</em> catalog to your Favorites:
           <a href="https://www.biopreferred.gov/bioPreferredCatalog/faces/jsp/catalogLanding.jsp">www.biopreferred.gov/bioPreferredCatalog/faces/jsp/catalogLanding.jsp</a> (200 pts)</td>
   </tr>
   <tr>
      <th title='300 points'><input type=checkbox name=op3 onClick='javascript:op_3(this.form)'></th>
      <td align=right><span id='op3_points'></span></td>
      <td> Participated in at least one <em>Biopreferred</em> online training course:
           <a href="https://www.biopreferred.gov/AccessTraining_Resources.aspx">www.biopreferred.gov/AccessTraining_Resources.aspx</a> (300 pts)</td>
   </tr>
 
<!-- SUSTAINABLE LEADERSHIP -->
  <tr><th bgcolor=lightgreen rowspan=5><h3>Sustainability Leadership</h3></th>
      <th title='200 points'><input type=checkbox name=os1 onClick='javascript:os_1(this.form)'></th>
      <td align=right><span id='os1_points'></span></td>
      <td> Completed "Feedback Survey" on the Sustainable Operations Demonstration website (top of the right menu bar):
           <a href="https://dvspdevpoc/sites/sus-ops">dvspdevpoc/sites/sus-ops</a> (200 pts)</td>
   </tr>
   <tr>
      <th title='500 points'><input type=checkbox name=os2 onClick='javascript:os_2(this.form)'></th>
      <td align=right><span id='os2_points'></span></td>
      <td> Attended Sustainable Operations employee training, professional development program or a Peer Learning Seminar - FS Peer learning calendar:
           <a href="https://ems-team.usda.gov/sites/fs-wo-soc">ems-team.usda.gov/sites/fs-wo-soc</a> (500 pts)</td>
    </tr>
    <tr>
      <th title='200 points'><input type=checkbox name=os3 onClick='javascript:os_3(this.form)'></th>
      <td align=right><span id='os3_points'></span></td>
      <td> Convinced a co-worker to participate in the FY2014 <em>Get Your Game 'Green' On: Summit Mt. Sustainability</em> (200 pts)</td>
    </tr>
    <tr>
      <th title='500 points'><input type=checkbox name=os4 onClick='javascript:os_4(this.form)'></th>
      <td align=right><span id='os4_points'></span></td>
      <td> Joined or are a participating member of the RMRS Green Team or your local Green Team (give credit even if you have already joined..good job!) (500 pts)</td>
    </tr>
    <tr>
      <th title='500 points'><input type=checkbox name=os5 onClick='javascript:os_5(this.form)'></th>
      <td align=right><span id='os5_points'></span></td>
      <td> Participated in Community Sustainability projects, such as Earth Day events or community education efforts (500 pts)</td>
    </tr>
   </table>
   <input type="reset" value="reset">
   <input type="submit" value="submit">
  </form>
 </body>
</html>
