<html>
 <head>
<?php
    $fs_email = $_POST['fs_email']; if ($fs_email == '') {$fs_email = 'sbear';}
    $location = $_POST['location']; if ($location == '') {$location = '0';}

 $loca = array('unspecified','Albuquerque','Aldo Leopold','Boise','Bozeman','Flagstaff','Fort Collins','Logan','Missoula FiSL','Missoula FoSL','Moscow','Ogden','Provo','Rapid City','Reno');
 $locaname = $loca[$location];

?>
<?php // try to open file; if exists read fsmail, user name, location, points weekly, points one-time then actions //

   $today = date("Y-m-d");   // http://stackoverflow.com/questions/2113940/compare-given-date-with-today  // 2017.04.24
   $week2 = "2019-04-29";
   $week3 = "2019-05-06";
   $week4 = "2019-05-13";
   $week5 = "2019-05-20";
   $week6 = "2019-05-27";

// initial values

  $pointsw = 0;
  $pointso = 0;
  $pointst = 0;

//  $e1_1=1;
//  $e2_2=1;

// if (!ctype_alnum($fs_email)) {  //  echo "The string $testcase does not consist of all letters or digits.\n";
   $aValid = array('.');	   // https://stackoverflow.com/questions/7198958/how-to-allow-underscore-and-dash-with-ctype-alnum
if (!ctype_alnum(str_replace($aValid, '', $fs_email))) {  //  echo "The string $testcase does not consist of all letters or digits or dots.\n";
   echo "
 </head>
 <body link=white vlink=white>
  <font face=\"trebuchet, tahoma, arial, sans serif\">
   <table border=0 width=100%><tr bgcolor=darkgreen><th><h3><font color=white><a href=\".\">Summit Mt. Sustainability 2019</a></font></h3></th></tr></table>
   <br>
   Invalid user name (fs e-mail) \"$fs_email\" -- enter login name before the \"@\" , only letters, numbers and dots allowed. You can fudge the name if necessary.
  </font>
 </body>
</html>
";
die;
}
// else {   // echo "The string $testcase consists of all letters or digits.\n";
//}

    $filename = $location . '_' . $fs_email . '.txt';
    $filename = 'data/' . $filename;
    $handle = fopen($filename, "r");
if ($handle) {
//    while (($line = fgets($handle)) !== false) {
    // process the line read.
//    }

$fs_email = fgets($handle);     // dehall
$user     = fgets($handle);     // David Hall
$location = fgets($handle);     // Moscow FSL
$pointsw  = fgets($handle);     // 450
$pointso  = fgets($handle);     // 0
$pointst  = $pointsw + $points0;

// weekly
$line   = fgets($handle);       // e1,0,0,0,0,0,0,
  $f    = strtok($line,",");
  $e1_1 = strtok(","); $e1_2 = strtok(","); $e1_3 = strtok(","); $e1_4 = strtok(","); $e1_5 = strtok(","); $e1_6 = strtok(",");
$line   = fgets($handle);       // e2,0,0,0,0,0,0
  $f    = strtok($line,",");
  $e2_1 = strtok(","); $e2_2 = strtok(","); $e2_3 = strtok(","); $e2_4 = strtok(","); $e2_5 = strtok(","); $e2_6 = strtok(",");
$line   = fgets($handle);       // e3,0,0,0,0,0,0
  $f    = strtok($line,",");
  $e3_1 = strtok(","); $e3_2 = strtok(","); $e3_3 = strtok(","); $e3_4 = strtok(","); $e3_5 = strtok(","); $e3_6 = strtok(",");
$line   = fgets($handle);       // e4,0,0,0,0,0,0
  $f    = strtok($line,",");
  $e4_1 = strtok(","); $e4_2 = strtok(","); $e4_3 = strtok(","); $e4_4 = strtok(","); $e4_5 = strtok(","); $e4_6 = strtok(",");
$line   = fgets($handle);       // e4,0,0,0,0,0,0
  $f    = strtok($line,",");
  $e5_1 = strtok(","); $e5_2 = strtok(","); $e5_3 = strtok(","); $e5_4 = strtok(","); $e5_5 = strtok(","); $e5_6 = strtok(",");
$line   = fgets($handle);       // e4,0,0,0,0,0,0
  $f    = strtok($line,",");
  $e6_1 = strtok(","); $e6_2 = strtok(","); $e6_3 = strtok(","); $e6_4 = strtok(","); $e6_5 = strtok(","); $e6_6 = strtok(",");

$line   = fgets($handle);     // w1,0,0,0,0,0,0
  $f    = strtok($line,",");
  $w1_1 = strtok(","); $w1_2 = strtok(","); $w1_3 = strtok(","); $w1_4 = strtok(","); $w1_5 = strtok(","); $w1_6 = strtok(",");
$line   = fgets($handle);     // w2,0,0,0,0,0,0
  $f    = strtok($line,",");
  $w2_1 = strtok(","); $w2_2 = strtok(","); $w2_3 = strtok(","); $w2_4 = strtok(","); $w2_5 = strtok(","); $w2_6 = strtok(",");

$line   = fgets($handle);     // t1,0,0,0,0,0,0
  $f    = strtok($line,",");
  $t1_1 = strtok(","); $t1_2 = strtok(","); $t1_3 = strtok(","); $t1_4 = strtok(","); $t1_5 = strtok(","); $t1_6 = strtok(",");
$line   = fgets($handle);     // t2,0,0,0,0,0,0
  $f    = strtok($line,",");
  $t2_1 = strtok(","); $t2_2 = strtok(","); $t2_3 = strtok(","); $t2_4 = strtok(","); $t2_5 = strtok(","); $t2_6 = strtok(",");
$line   = fgets($handle);     // t3,0,0,0,0,0,0
  $f    = strtok($line,",");
  $t3_1 = strtok(","); $t3_2 = strtok(","); $t3_3 = strtok(","); $t3_4 = strtok(","); $t3_5 = strtok(","); $t3_6 = strtok(",");

$line   = fgets($handle);     // r1,0,0,0,0,0,0
  $f    = strtok($line,",");
  $r1_1 = strtok(","); $r1_2 = strtok(","); $r1_3 = strtok(","); $r1_4 = strtok(","); $r1_5 = strtok(","); $r1_6 = strtok(",");
$line   = fgets($handle);     // r2,0,0,0,0,0,0
  $f    = strtok($line,",");
  $r2_1 = strtok(","); $r2_2 = strtok(","); $r2_3 = strtok(","); $r2_4 = strtok(","); $r2_5 = strtok(","); $r2_6 = strtok(",");
$line   = fgets($handle);     // r3,0,0,0,0,0,0
  $f    = strtok($line,",");
  $r3_1 = strtok(","); $r3_2 = strtok(","); $r3_3 = strtok(","); $r3_4 = strtok(","); $r3_5 = strtok(","); $r3_6 = strtok(",");
$line   = fgets($handle);     // r4,0,0,0,0,0,0
  $f    = strtok($line,",");
  $r4_1 = strtok(","); $r4_2 = strtok(","); $r4_3 = strtok(","); $r4_4 = strtok(","); $r4_5 = strtok(","); $r4_6 = strtok(",");
$line   = fgets($handle);     // r5,0,0,0,0,0,0
  $f    = strtok($line,",");
  $r5_1 = strtok(","); $r5_2 = strtok(","); $r5_3 = strtok(","); $r5_4 = strtok(","); $r5_5 = strtok(","); $r5_6 = strtok(",");
$line   = fgets($handle);     // r6,0,0,0,0,0,0
  $f    = strtok($line,",");
  $r6_1 = strtok(","); $r6_2 = strtok(","); $r6_3 = strtok(","); $r6_4 = strtok(","); $r6_5 = strtok(","); $r6_6 = strtok(",");
$line   = fgets($handle);     // r7,0,0,0,0,0,0
  $f    = strtok($line,",");
  $r7_1 = strtok(","); $r7_2 = strtok(","); $r7_3 = strtok(","); $r7_4 = strtok(","); $r7_5 = strtok(","); $r7_6 = strtok(",");
$line   = fgets($handle);     // r8,0,0,0,0,0,0
  $f    = strtok($line,",");
  $r8_1 = strtok(","); $r8_2 = strtok(","); $r8_3 = strtok(","); $r8_4 = strtok(","); $r8_5 = strtok(","); $r8_6 = strtok(",");

$line   = fgets($handle);     // p1,0,0,0,0,0,0
  $f    = strtok($line,",");
  $p1_1 = strtok(","); $p1_2 = strtok(","); $p1_3 = strtok(","); $p1_4 = strtok(","); $p1_5 = strtok(","); $p1_6 = strtok(",");

// one-time

$line   = fgets($handle);     // e,0,0,0,0
  $f    = strtok($line,",");
  $oe1  = strtok(","); $oe2 = strtok(","); $oe3 = strtok(","); $oe4 = strtok(","); $oe5 = strtok(",");
$line   = fgets($handle);     // w,0,0,0,1,0
  $f    = strtok($line,",");
  $ow1  = strtok(","); $ow2 = strtok(","); $ow3 = strtok(","); // $ow4 = strtok(",");
$line   = fgets($handle);     // t,0,0,0,0,0,
  $f    = strtok($line,",");
  $ot1  = strtok(","); $ot2 = strtok(","); $ot3 = strtok(",");
$line   = fgets($handle);     // r,0,0,0,0,0,0,0,0,0
  $f    = strtok($line,",");
  $or1  = strtok(","); $or2 = strtok(","); $or3 = strtok(","); $or4 = strtok(","); $or5  = strtok(",");
  $or6  = strtok(","); $or7 = strtok(","); $or8 = strtok(","); $or9 = strtok(","); $or10 = strtok(",");
//$line   = fgets($handle);     // p,0,0,0,0,
//  $f    = strtok($line,",");
//  $op1  = strtok(","); $op2 = strtok(",");
$line   = fgets($handle);     // s,0,0,0,0,0,0,
  $f    = strtok($line,",");
  $os1  = strtok(","); $os2 = strtok(","); $os3 = strtok(","); $os4 = strtok(","); $os5  = strtok(",");
  $os6  = strtok(","); $os7 = strtok(","); $os8 = strtok(","); $os9 = strtok(","); $os10 = strtok(","); $os11 = strtok(",");
} else {
    // error opening the file.
}
fclose($handle);

////  when your 'while fgets' loop ends, check feof; if not true, then you had an error.
//$filename = "test.txt;
//$source_file = fopen( $filename, "r" ) or die("Couldn't open $filename");
//while (!feof($source_file)) {...

// http://stackoverflow.com/questions/13246597/how-to-read-a-file-line-by-line-in-php

?>
  <script language=javascript>

function transferCheckboxValues(){
//    if(!form_valid){
//        alert('Given data is not correct');
//        return false;
//    }

//    document.forms["input"].pe1.value = "zip"

//    if (frm.e1[0].checked) {e1pts++}

  document.forms["input"].pointsw.value = document.getElementById("subtotal").innerHTML
  document.forms["input"].pointso.value = document.getElementById("osubtotal").innerHTML
  document.forms["input"].pointst.value = document.getElementById("total").innerHTML

// weekly

      ze1 = "e1,"
      if (document.forms["input"].e1[0].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].e1[1].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].e1[2].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].e1[3].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].e1[4].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].e1[5].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      document.forms["input"].pe1.value = ze1
      ze1 = "e2,"
      if (document.forms["input"].e2[0].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].e2[1].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].e2[2].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].e2[3].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].e2[4].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].e2[5].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      document.forms["input"].pe2.value = ze1
      ze1 = "e3,"
      if (document.forms["input"].e3[0].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].e3[1].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].e3[2].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].e3[3].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].e3[4].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].e3[5].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      document.forms["input"].pe3.value = ze1
      ze1 = "e4,"
      if (document.forms["input"].e4[0].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].e4[1].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].e4[2].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].e4[3].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].e4[4].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].e4[5].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      document.forms["input"].pe4.value = ze1
      ze1 = "e5,"
      if (document.forms["input"].e5[0].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].e5[1].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].e5[2].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].e5[3].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].e5[4].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].e5[5].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      document.forms["input"].pe5.value = ze1
      ze1 = "e6,"
      if (document.forms["input"].e6[0].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].e6[1].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].e6[2].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].e6[3].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].e6[4].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].e6[5].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      document.forms["input"].pe6.value = ze1

      ze1 = "w1,"
      if (document.forms["input"].w1[0].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].w1[1].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].w1[2].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].w1[3].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].w1[4].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].w1[5].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      document.forms["input"].pw1.value = ze1
      ze1 = "w2,"
      if (document.forms["input"].w2[0].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].w2[1].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].w2[2].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].w2[3].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].w2[4].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].w2[5].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      document.forms["input"].pw2.value = ze1

      ze1 = "t1,"
      if (document.forms["input"].t1[0].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].t1[1].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].t1[2].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].t1[3].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].t1[4].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].t1[5].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      document.forms["input"].pt1.value = ze1
      ze1 = "t2,"
      if (document.forms["input"].t2[0].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].t2[1].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].t2[2].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].t2[3].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].t2[4].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].t2[5].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      document.forms["input"].pt2.value = ze1
      ze1 = "t3,"
      dv = document.forms["input"].t3[0].value; if (dv >= 0 && dv <= 5) {ze1 = ze1 + dv + ','} else {ze1=ze1 + '0,'}
      dv = document.forms["input"].t3[1].value; if (dv >= 0 && dv <= 5) {ze1 = ze1 + dv + ','} else {ze1=ze1 + '0,'}
      dv = document.forms["input"].t3[2].value; if (dv >= 0 && dv <= 5) {ze1 = ze1 + dv + ','} else {ze1=ze1 + '0,'}
      dv = document.forms["input"].t3[3].value; if (dv >= 0 && dv <= 5) {ze1 = ze1 + dv + ','} else {ze1=ze1 + '0,'}
      dv = document.forms["input"].t3[4].value; if (dv >= 0 && dv <= 5) {ze1 = ze1 + dv + ','} else {ze1=ze1 + '0,'}
      dv = document.forms["input"].t3[5].value; if (dv >= 0 && dv <= 5) {ze1 = ze1 + dv + ','} else {ze1=ze1 + '0,'}
//    if (document.forms["input"].t3[1].value >= 0 && document.forms["input"].t3[1].value <= 5) {ze1 = ze1 + document.forms["input"].t3[1].value + ','} else {ze1=ze1 + '0,'}
//    if (document.forms["input"].t3[2].value >= 0 && document.forms["input"].t3[2].value <= 5) {ze1 = ze1 + document.forms["input"].t3[2].value + ','} else {ze1=ze1 + '0,'}
//    if (document.forms["input"].t3[3].value >= 0 && document.forms["input"].t3[3].value <= 5) {ze1 = ze1 + document.forms["input"].t3[3].value + ','} else {ze1=ze1 + '0,'}
//    if (document.forms["input"].t3[4].value >= 0 && document.forms["input"].t3[4].value <= 5) {ze1 = ze1 + document.forms["input"].t3[4].value + ','} else {ze1=ze1 + '0,'}
//    if (document.forms["input"].t3[5].value >= 0 && document.forms["input"].t3[5].value <= 5) {ze1 = ze1 + document.forms["input"].t3[5].value + ','} else {ze1=ze1 + '0,'}
      document.forms["input"].pt3.value = ze1

      ze1 = "r1,"
      if (document.forms["input"].r1[0].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].r1[1].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].r1[2].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].r1[3].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].r1[4].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].r1[5].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      document.forms["input"].pr1.value = ze1
      ze1 = "r2,"
      if (document.forms["input"].r2[0].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].r2[1].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].r2[2].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].r2[3].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].r2[4].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].r2[5].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      document.forms["input"].pr2.value = ze1
      ze1 = "r3,"
      if (document.forms["input"].r3[0].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].r3[1].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].r3[2].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].r3[3].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].r3[4].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].r3[5].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      document.forms["input"].pr3.value = ze1
      ze1 = "r4,"
      if (document.forms["input"].r4[0].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].r4[1].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].r4[2].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].r4[3].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].r4[4].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].r4[5].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      document.forms["input"].pr4.value = ze1
      ze1 = "r5,"
      if (document.forms["input"].r5[0].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].r5[1].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].r5[2].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].r5[3].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].r5[4].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].r5[5].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      document.forms["input"].pr5.value = ze1
      ze1 = "r6,"
      if (document.forms["input"].r6[0].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].r6[1].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].r6[2].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].r6[3].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].r6[4].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].r6[5].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      document.forms["input"].pr6.value = ze1
      ze1 = "r7,"
      if (document.forms["input"].r7[0].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].r7[1].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].r7[2].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].r7[3].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].r7[4].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].r7[5].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      document.forms["input"].pr7.value = ze1
      ze1 = "r8,"
      dv = document.forms["input"].r8[0].value; if (dv >= 0 && dv <= 5) {ze1 = ze1 + dv + ','} else {ze1=ze1 + '0,'}
      dv = document.forms["input"].r8[1].value; if (dv >= 0 && dv <= 5) {ze1 = ze1 + dv + ','} else {ze1=ze1 + '0,'}
      dv = document.forms["input"].r8[2].value; if (dv >= 0 && dv <= 5) {ze1 = ze1 + dv + ','} else {ze1=ze1 + '0,'}
      dv = document.forms["input"].r8[3].value; if (dv >= 0 && dv <= 5) {ze1 = ze1 + dv + ','} else {ze1=ze1 + '0,'}
      dv = document.forms["input"].r8[4].value; if (dv >= 0 && dv <= 5) {ze1 = ze1 + dv + ','} else {ze1=ze1 + '0,'}
      dv = document.forms["input"].r8[5].value; if (dv >= 0 && dv <= 5) {ze1 = ze1 + dv + ','} else {ze1=ze1 + '0,'}
//      if (document.forms["input"].r8[0].value >= 0 && document.forms["input"].r8[0].value <= 5) {ze1 = ze1 + document.forms["input"].r8[0].value + ','} else {ze1=ze1 +$
//      if (document.forms["input"].r8[1].value >= 0 && document.forms["input"].r8[1].value <= 5) {ze1 = ze1 + document.forms["input"].r8[1].value + ','} else {ze1=ze1 +$
//      if (document.forms["input"].r8[2].value >= 0 && document.forms["input"].r8[2].value <= 5) {ze1 = ze1 + document.forms["input"].r8[2].value + ','} else {ze1=ze1 +$
//      if (document.forms["input"].r8[3].value >= 0 && document.forms["input"].r8[3].value <= 5) {ze1 = ze1 + document.forms["input"].r8[3].value + ','} else {ze1=ze1 +$
//      if (document.forms["input"].r8[4].value >= 0 && document.forms["input"].r8[4].value <= 5) {ze1 = ze1 + document.forms["input"].r8[4].value + ','} else {ze1=ze1 +$
//      if (document.forms["input"].r8[5].value >= 0 && document.forms["input"].r8[5].value <= 5) {ze1 = ze1 + document.forms["input"].r8[5].value + ','} else {ze1=ze1 +$
      document.forms["input"].pr8.value = ze1

      ze1 = "p1,"
      if (document.forms["input"].p1[0].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].p1[1].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].p1[2].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].p1[3].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].p1[4].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      if (document.forms["input"].p1[5].checked) {ze1 = ze1 + '1,'} else {ze1=ze1 + '0,'}
      document.forms["input"].pp1.value = ze1

// one-time actions

        // Energy (5)
      ze1 = "e,"
      if (document.forms["input"].oe1.checked) {ze1 = '1'} else {ze1 = '0'}
      document.forms["input"].ope1.value = ze1
      if (document.forms["input"].oe2.checked) {ze1 = '1'} else {ze1 = '0'}
      document.forms["input"].ope2.value = ze1
      if (document.forms["input"].oe3.checked) {ze1 = '1'} else {ze1 = '0'}
      document.forms["input"].ope3.value = ze1
      if (document.forms["input"].oe4.checked) {ze1 = '1'} else {ze1 = '0'}
      document.forms["input"].ope4.value = ze1
      if (document.forms["input"].oe5.checked) {ze1 = '1'} else {ze1 = '0'}
      document.forms["input"].ope5.value = ze1
        // Water (3)
      ze1 = "w,"
      if (document.forms["input"].ow1.checked) {ze1 = '1'} else {ze1 = '0'}
      document.forms["input"].opw1.value = ze1
      if (document.forms["input"].ow2.checked) {ze1 = '1'} else {ze1 = '0'}
      document.forms["input"].opw2.value = ze1
      if (document.forms["input"].ow3.checked) {ze1 = '1'} else {ze1 = '0'}
      document.forms["input"].opw3.value = ze1
//      if (document.forms["input"].ow4.checked) {ze1 = '1'} else {ze1 = '0'}
//      document.forms["input"].opw4.value = ze1
        // Fleet & Transportation (3)
      ze1 = "t,"
      if (document.forms["input"].ot1.checked) {ze1 = '1'} else {ze1 = '0'}
      document.forms["input"].opt1.value = ze1
      if (document.forms["input"].ot2.checked) {ze1 = '1'} else {ze1 = '0'}
      document.forms["input"].opt2.value = ze1
      if (document.forms["input"].ot3.checked) {ze1 = '1'} else {ze1 = '0'}
      document.forms["input"].opt3.value = ze1
        // Waste Prevention & Recycling (10)
      ze1 = "r,"
      if (document.forms["input"].or1.checked) {ze1 = '1'} else {ze1 = '0'}
      document.forms["input"].opr1.value = ze1
      if (document.forms["input"].or2.checked) {ze1 = '1'} else {ze1 = '0'}
      document.forms["input"].opr2.value = ze1
      if (document.forms["input"].or3.checked) {ze1 = '1'} else {ze1 = '0'}
      document.forms["input"].opr3.value = ze1
      if (document.forms["input"].or4.checked) {ze1 = '1'} else {ze1 = '0'}
      document.forms["input"].opr4.value = ze1
      if (document.forms["input"].or5.checked) {ze1 = '1'} else {ze1 = '0'}
      document.forms["input"].opr5.value = ze1
      if (document.forms["input"].or6.checked) {ze1 = '1'} else {ze1 = '0'}
      document.forms["input"].opr6.value = ze1
      if (document.forms["input"].or7.checked) {ze1 = '1'} else {ze1 = '0'}
      document.forms["input"].opr7.value = ze1
      if (document.forms["input"].or8.checked) {ze1 = '1'} else {ze1 = '0'}
      document.forms["input"].opr8.value = ze1
      if (document.forms["input"].or9.checked) {ze1 = '1'} else {ze1 = '0'}
      document.forms["input"].opr9.value = ze1
      if (document.forms["input"].or10.checked) {ze1 = '1'} else {ze1 = '0'}
      document.forms["input"].opr10.value = ze1
        // Green Purchasing (2)
//      ze1 = "p,"
//      if (document.forms["input"].op1.checked) {ze1 = '1'} else {ze1 = '0'}
//      document.forms["input"].opp1.value = ze1
//      if (document.forms["input"].op2.checked) {ze1 = '1'} else {ze1 = '0'}
//      document.forms["input"].opp2.value = ze1

        // Sustainability Leadership (11)
      ze1 = "s,"
      if (document.forms["input"].os1.checked) {ze1 = '1'} else {ze1 = '0'}
      document.forms["input"].ops1.value = ze1
      if (document.forms["input"].os2.checked) {ze1 = '1'} else {ze1 = '0'}
      document.forms["input"].ops2.value = ze1
      if (document.forms["input"].os3.checked) {ze1 = '1'} else {ze1 = '0'}
      document.forms["input"].ops3.value = ze1
      if (document.forms["input"].os4.checked) {ze1 = '1'} else {ze1 = '0'}
      document.forms["input"].ops4.value = ze1
      if (document.forms["input"].os5.checked) {ze1 = '1'} else {ze1 = '0'}
      document.forms["input"].ops5.value = ze1
      if (document.forms["input"].os6.checked) {ze1 = '1'} else {ze1 = '0'}
      document.forms["input"].ops6.value = ze1
      if (document.forms["input"].os7.checked) {ze1 = '1'} else {ze1 = '0'}
      document.forms["input"].ops7.value = ze1
      if (document.forms["input"].os8.checked) {ze1 = '1'} else {ze1 = '0'}
      document.forms["input"].ops8.value = ze1
      if (document.forms["input"].os9.checked) {ze1 = '1'} else {ze1 = '0'}
      document.forms["input"].ops9.value = ze1
      if (document.forms["input"].os10.checked) {ze1 = '1'} else {ze1 = '0'}
      document.forms["input"].ops10.value = ze1
      if (document.forms["input"].os11.checked) {ze1 = '1'} else {ze1 = '0'}
      document.forms["input"].ops11.value = ze1

    return true;
}

   function do_math() {
     e_1(document.forms["input"])
     e_2(document.forms["input"])
     e_3(document.forms["input"])
     e_4(document.forms["input"])
     e_5(document.forms["input"])
     e_6(document.forms["input"])
     w_1(document.forms["input"])
     w_2(document.forms["input"])
     t_1(document.forms["input"])
     t_2(document.forms["input"])
     t_3(document.forms["input"])
     r_1(document.forms["input"])
     r_2(document.forms["input"])
     r_3(document.forms["input"])
     r_4(document.forms["input"])
     r_5(document.forms["input"])
     r_6(document.forms["input"])
     r_7(document.forms["input"])
     r_8(document.forms["input"])
     p_1(document.forms["input"])
// sub_total()
//   }

//   function do_math_o() {
     oe_1(document.forms["input"])
     oe_2(document.forms["input"])
     oe_3(document.forms["input"])
     oe_4(document.forms["input"])
     oe_5(document.forms["input"])

     ow_1(document.forms["input"])
     ow_2(document.forms["input"])
     ow_3(document.forms["input"])
//   ow_4(document.forms["input"])

     ot_1(document.forms["input"])
     ot_2(document.forms["input"])
     ot_3(document.forms["input"])

     or_1(document.forms["input"])
     or_2(document.forms["input"])
     or_3(document.forms["input"])
     or_4(document.forms["input"])
     or_5(document.forms["input"])
     or_6(document.forms["input"])
     or_7(document.forms["input"])
     or_8(document.forms["input"])
     or_9(document.forms["input"])
     or_10(document.forms["input"])

//     op_1(document.forms["input"])
//     op_2(document.forms["input"])

     os_1(document.forms["input"])
     os_2(document.forms["input"])
     os_3(document.forms["input"])
     os_4(document.forms["input"])
     os_5(document.forms["input"])
     os_6(document.forms["input"])
     os_7(document.forms["input"])
     os_8(document.forms["input"])
     os_9(document.forms["input"])
     os_10(document.forms["input"])
     os_10(document.forms["input"])
     os_11(document.forms["input"])
// sub_total()
   }

   function sub_total() {
// alert('subtotal calc')
    e1p = Number(document.getElementById("e1_points").innerHTML)
    e2p = Number(document.getElementById("e2_points").innerHTML)
    e3p = Number(document.getElementById("e3_points").innerHTML)
    e4p = Number(document.getElementById("e4_points").innerHTML)
    e5p = Number(document.getElementById("e5_points").innerHTML)
    e6p = Number(document.getElementById("e6_points").innerHTML)
    w1p = Number(document.getElementById("w1_points").innerHTML)
    w2p = Number(document.getElementById("w2_points").innerHTML)
    t1p = Number(document.getElementById("t1_points").innerHTML)
    t2p = Number(document.getElementById("t2_points").innerHTML)
    t3p = Number(document.getElementById("t3_points").innerHTML)
    r1p = Number(document.getElementById("r1_points").innerHTML)
    r2p = Number(document.getElementById("r2_points").innerHTML)
    r3p = Number(document.getElementById("r3_points").innerHTML)
    r4p = Number(document.getElementById("r4_points").innerHTML)
    r5p = Number(document.getElementById("r5_points").innerHTML)
    r6p = Number(document.getElementById("r6_points").innerHTML)
    r7p = Number(document.getElementById("r7_points").innerHTML)
    r8p = Number(document.getElementById("r8_points").innerHTML)
    p1p = Number(document.getElementById("p1_points").innerHTML)
    sub_tot=0
    sub_tot = sub_tot + e1p + e2p + e3p + e4p + e5p + e6p
    sub_tot = sub_tot + w1p + w2p
    sub_tot = sub_tot + t1p + t2p + t3p
    sub_tot = sub_tot + r1p + r2p + r3p + r4p + r5p + r6p + r7p + r8p
    sub_tot = sub_tot + p1p
    document.getElementById("subtotal").innerHTML = sub_tot

    o_subtot = document.getElementById("osubtotal").innerHTML
    document.getElementById("total").innerHTML = sub_tot + 1 * o_subtot

   }

   function sub_total_o() {
    oe1p = Number(document.getElementById("oe1_points").innerHTML)
    oe2p = Number(document.getElementById("oe2_points").innerHTML)
    oe3p = Number(document.getElementById("oe3_points").innerHTML)
    oe4p = Number(document.getElementById("oe4_points").innerHTML)
    oe5p = Number(document.getElementById("oe5_points").innerHTML)

    ow1p = Number(document.getElementById("ow1_points").innerHTML)
    ow2p = Number(document.getElementById("ow2_points").innerHTML)
    ow3p = Number(document.getElementById("ow3_points").innerHTML)
//    ow4p = Number(document.getElementById("ow4_points").innerHTML)

    ot1p = Number(document.getElementById("ot1_points").innerHTML)
    ot2p = Number(document.getElementById("ot2_points").innerHTML)
    ot3p = Number(document.getElementById("ot3_points").innerHTML)

    or1p = Number(document.getElementById("or1_points").innerHTML)
    or2p = Number(document.getElementById("or2_points").innerHTML)
    or3p = Number(document.getElementById("or3_points").innerHTML)
    or4p = Number(document.getElementById("or4_points").innerHTML)
    or5p = Number(document.getElementById("or5_points").innerHTML)
    or6p = Number(document.getElementById("or6_points").innerHTML)
    or7p = Number(document.getElementById("or7_points").innerHTML)
    or8p = Number(document.getElementById("or8_points").innerHTML)
    or9p = Number(document.getElementById("or9_points").innerHTML)
    or10p = Number(document.getElementById("or10_points").innerHTML)

//    op1p = Number(document.getElementById("op1_points").innerHTML)
//    op2p = Number(document.getElementById("op2_points").innerHTML)

    os1p  = Number(document.getElementById("os1_points").innerHTML)
    os2p  = Number(document.getElementById("os2_points").innerHTML)
    os3p  = Number(document.getElementById("os3_points").innerHTML)
    os4p  = Number(document.getElementById("os4_points").innerHTML)
    os5p  = Number(document.getElementById("os5_points").innerHTML)
    os6p  = Number(document.getElementById("os6_points").innerHTML)
    os7p  = Number(document.getElementById("os7_points").innerHTML)
    os8p  = Number(document.getElementById("os8_points").innerHTML)
    os9p  = Number(document.getElementById("os9_points").innerHTML)
    os10p = Number(document.getElementById("os10_points").innerHTML)
    os11p = Number(document.getElementById("os11_points").innerHTML)

    sub_tot = 0
    sub_tot = sub_tot + oe1p + oe2p + oe3p + oe4p + oe5p
    sub_tot = sub_tot + ow1p + ow2p + ow3p
    sub_tot = sub_tot + ot1p + ot2p + ot3p
    sub_tot = sub_tot + or1p + or2p + or3p + or4p + or5p + or6p + or7p + or8p + or9p + or10p
    sub_tot = sub_tot + os1p + os2p + os3p + os4p + os5p + os6p + os7p + os8p + os9p + os10p + os11p
    document.getElementById("osubtotal").innerHTML = sub_tot

    w_subtot = document.getElementById("subtotal").innerHTML
    document.getElementById("total").innerHTML = sub_tot + 1 * w_subtot

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
    document.getElementById("e2_points").innerHTML = e2pts * 150
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
   function e_4(frm) {
    e4pts=0
    if (frm.e4[0].checked) {e4pts++}
    if (frm.e4[1].checked) {e4pts++}
    if (frm.e4[2].checked) {e4pts++}
    if (frm.e4[3].checked) {e4pts++}
    if (frm.e4[4].checked) {e4pts++}
    if (frm.e4[5].checked) {e4pts++}
    document.getElementById("e4_points").innerHTML = e4pts * 150
    sub_total()
   }
   function e_5(frm) {
    e5pts=0
    if (frm.e5[0].checked) {e5pts++}
    if (frm.e5[1].checked) {e5pts++}
    if (frm.e5[2].checked) {e5pts++}
    if (frm.e5[3].checked) {e5pts++}
    if (frm.e5[4].checked) {e5pts++}
    if (frm.e5[5].checked) {e5pts++}
    document.getElementById("e5_points").innerHTML = e5pts * 150
    sub_total()
   }
   function e_6(frm) {
    e6pts=0
    if (frm.e6[0].checked) {e6pts++}
    if (frm.e6[1].checked) {e6pts++}
    if (frm.e6[2].checked) {e6pts++}
    if (frm.e6[3].checked) {e6pts++}
    if (frm.e6[4].checked) {e6pts++}
    if (frm.e6[5].checked) {e6pts++}
    document.getElementById("e6_points").innerHTML = e6pts * 150
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

   function w_3(frm) {
    w3pts=0
    if (frm.w3[0].checked) {w3pts++}
    if (frm.w3[1].checked) {w3pts++}
    if (frm.w3[2].checked) {w3pts++}
    if (frm.w3[3].checked) {w3pts++}
    if (frm.w3[4].checked) {w3pts++}
    if (frm.w3[5].checked) {w3pts++}
    document.getElementById("w3_points").innerHTML = w3pts * 100
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
    document.getElementById("t1_points").innerHTML = t1pts * 100
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
    document.getElementById("t2_points").innerHTML = t2pts * 100
    sub_total()
   }
   function t_3(frm) {
    t3pts=0
//    alert ('t_3')
//    alert (frm.t3[0].value)
    if (frm.t3[0].value>0 && frm.t3[0].value<6) {t3pts=t3pts+1*(frm.t3[0].value)}
    if (frm.t3[1].value>0 && frm.t3[1].value<6) {t3pts=t3pts+1*(frm.t3[1].value)}
    if (frm.t3[2].value>0 && frm.t3[2].value<6) {t3pts=t3pts+1*(frm.t3[2].value)}
    if (frm.t3[3].value>0 && frm.t3[3].value<6) {t3pts=t3pts+1*(frm.t3[3].value)}
    if (frm.t3[4].value>0 && frm.t3[4].value<6) {t3pts=t3pts+1*(frm.t3[4].value)}
    if (frm.t3[5].value>0 && frm.t3[5].value<6) {t3pts=t3pts+1*(frm.t3[5].value)}
//    if (frm.t3[1]>0 && frm.t3[1]<6) {t3pts++}
//    if (frm.t3[2]>0 && frm.t3[2]<6) {t3pts++}
//    if (frm.t3[3]>0 && frm.t3[3]<6) {t3pts++}
//    if (frm.t3[4]>0 && frm.t3[4]<6) {t3pts++}
//    if (frm.t3[5]>0 && frm.t3[5]<6) {t3pts++}
//    if (frm.t3[1].checked) {t3pts++}
//    if (frm.t3[2].checked) {t3pts++}
//    if (frm.t3[3].checked) {t3pts++}
//    if (frm.t3[4].checked) {t3pts++}
//    if (frm.t3[5].checked) {t3pts++}
    document.getElementById("t3_points").innerHTML = t3pts * 20
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
    document.getElementById("r1_points").innerHTML = r1pts * 100
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
    document.getElementById("r2_points").innerHTML = r2pts * 100
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
    if (frm.r4[0].checked) {r4pts++}
    if (frm.r4[1].checked) {r4pts++}
    if (frm.r4[2].checked) {r4pts++}
    if (frm.r4[3].checked) {r4pts++}
    if (frm.r4[4].checked) {r4pts++}
    if (frm.r4[5].checked) {r4pts++}
    document.getElementById("r4_points").innerHTML = r4pts * 100
    sub_total()
   }
   function r_5(frm) {
    r5pts=0
    if (frm.r5[0].checked) {r5pts++}
    if (frm.r5[1].checked) {r5pts++}
    if (frm.r5[2].checked) {r5pts++}
    if (frm.r5[3].checked) {r5pts++}
    if (frm.r5[4].checked) {r5pts++}
    if (frm.r5[5].checked) {r5pts++}
    document.getElementById("r5_points").innerHTML = r5pts * 100
    sub_total()
   }
   function r_6(frm) {
    r6pts=0
    if (frm.r6[0].checked) {r6pts++}
    if (frm.r6[1].checked) {r6pts++}
    if (frm.r6[2].checked) {r6pts++}
    if (frm.r6[3].checked) {r6pts++}
    if (frm.r6[4].checked) {r6pts++}
    if (frm.r6[5].checked) {r6pts++}
    document.getElementById("r6_points").innerHTML = r6pts * 100
    sub_total()
   }
   function r_7(frm) {
    r7pts=0
    if (frm.r7[0].checked) {r7pts++}
    if (frm.r7[1].checked) {r7pts++}
    if (frm.r7[2].checked) {r7pts++}
    if (frm.r7[3].checked) {r7pts++}
    if (frm.r7[4].checked) {r7pts++}
    if (frm.r7[5].checked) {r7pts++}
    document.getElementById("r7_points").innerHTML = r7pts * 100
    sub_total()
   }
   function r_8(frm) {
    r8pts=0
//    if (frm.r4[0]>0 && frm.r4[0]<6) {r4pts++}
//    if (frm.r4[1].checked) {r4pts++}
//    if (frm.r4[2].checked) {r4pts++}
//    if (frm.r4[3].checked) {r4pts++}
//    if (frm.r4[4].checked) {r4pts++}
//    if (frm.r4[5].checked) {r4pts++}
//    document.getElementById("r4_points").innerHTML = r4pts * 100
    if (frm.r8[0].value>0 && frm.r8[0].value<6) {r8pts=r8pts+1*(frm.r8[0].value)}
    if (frm.r8[1].value>0 && frm.r8[1].value<6) {r8pts=r8pts+1*(frm.r8[1].value)}
    if (frm.r8[2].value>0 && frm.r8[2].value<6) {r8pts=r8pts+1*(frm.r8[2].value)}
    if (frm.r8[3].value>0 && frm.r8[3].value<6) {r8pts=r8pts+1*(frm.r8[3].value)}
    if (frm.r8[4].value>0 && frm.r8[4].value<6) {r8pts=r8pts+1*(frm.r8[4].value)}
    if (frm.r8[5].value>0 && frm.r8[5].value<6) {r8pts=r8pts+1*(frm.r8[5].value)}
    document.getElementById("r8_points").innerHTML = r8pts * 20
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

// one-time

   function oe_1(frm)    {document.getElementById("oe1_points").innerHTML = ''
    if (frm.oe1.checked) {document.getElementById("oe1_points").innerHTML = 300}
    sub_total_o()
   }
   function oe_2(frm)    {document.getElementById("oe2_points").innerHTML = ''
    if (frm.oe2.checked) {document.getElementById("oe2_points").innerHTML = 500}
    sub_total_o()
   }
   function oe_3(frm)    {document.getElementById("oe3_points").innerHTML = ''
    if (frm.oe3.checked) {document.getElementById("oe3_points").innerHTML = 500}
    sub_total_o()
   }
   function oe_4(frm)    {document.getElementById("oe4_points").innerHTML = ''
    if (frm.oe4.checked) {document.getElementById("oe4_points").innerHTML = 500}
    sub_total_o()
   }
   function oe_5(frm)    {document.getElementById("oe5_points").innerHTML = ''
    if (frm.oe5.checked) {document.getElementById("oe5_points").innerHTML = 800}
    sub_total_o()
   }

   function ow_1(frm)    {document.getElementById("ow1_points").innerHTML = ''
    if (frm.ow1.checked) {document.getElementById("ow1_points").innerHTML = 500}
    sub_total_o()
   }
   function ow_2(frm)    {document.getElementById("ow2_points").innerHTML = ''
    if (frm.ow2.checked) {document.getElementById("ow2_points").innerHTML = 500}
    sub_total_o()
   }
   function ow_3(frm)    {document.getElementById("ow3_points").innerHTML = ''
    if (frm.ow3.checked) {document.getElementById("ow3_points").innerHTML = 500}
    sub_total_o()
   }
   function ow_4(frm)    {document.getElementById("ow4_points").innerHTML = ''
    if (frm.ow4.checked) {document.getElementById("ow4_points").innerHTML = 1000}
    sub_total_o()
   }

   function ot_1(frm)    {document.getElementById("ot1_points").innerHTML = ''
    if (frm.ot1.checked) {document.getElementById("ot1_points").innerHTML = 500}
    sub_total_o()
   }
   function ot_2(frm)    {document.getElementById("ot2_points").innerHTML = ''
    if (frm.ot2.checked) {document.getElementById("ot2_points").innerHTML = 500}
    sub_total_o()
   }
   function ot_3(frm)    {document.getElementById("ot3_points").innerHTML = ''
    if (frm.ot3.checked) {document.getElementById("ot3_points").innerHTML = 500}
    sub_total_o()
   }

   function or_1(frm)    {document.getElementById("or1_points").innerHTML = ''
    if (frm.or1.checked) {document.getElementById("or1_points").innerHTML = 300}
    sub_total_o()
   }
   function or_2(frm)    {document.getElementById("or2_points").innerHTML = ''
    if (frm.or2.checked) {document.getElementById("or2_points").innerHTML = 300}
    sub_total_o()
   }
   function or_3(frm)    {document.getElementById("or3_points").innerHTML = ''
    if (frm.or3.checked) {document.getElementById("or3_points").innerHTML = 500}
    sub_total_o()
   }
   function or_4(frm)    {document.getElementById("or4_points").innerHTML = ''
    if (frm.or4.checked) {document.getElementById("or4_points").innerHTML = 500}
    sub_total_o()
   }
   function or_5(frm)    {document.getElementById("or5_points").innerHTML = ''
    if (frm.or5.checked) {document.getElementById("or5_points").innerHTML = 500}
    sub_total_o()
   }
   function or_6(frm)    {document.getElementById("or6_points").innerHTML = ''
    if (frm.or6.checked) {document.getElementById("or6_points").innerHTML = 500}
    sub_total_o()
   }
   function or_7(frm)    {document.getElementById("or7_points").innerHTML = ''
    if (frm.or7.checked) {document.getElementById("or7_points").innerHTML = 600}
    sub_total_o()
   }
   function or_8(frm)    {document.getElementById("or8_points").innerHTML = ''
    if (frm.or8.checked) {document.getElementById("or8_points").innerHTML = 1000}
    sub_total_o()
   }
   function or_9(frm)    {document.getElementById("or9_points").innerHTML = ''
    if (frm.or9.checked) {document.getElementById("or9_points").innerHTML = 1000}
    sub_total_o()
   }
   function or_10(frm)   {document.getElementById("or10_points").innerHTML = ''
    if (frm.or10.checked) {document.getElementById("or10_points").innerHTML = 1000}
    sub_total_o()
   }

   function op_1(frm)    {document.getElementById("op1_points").innerHTML = ''
    if (frm.op1.checked) {document.getElementById("op1_points").innerHTML = 200}
    sub_total_o()
   }
   function op_2(frm)    {document.getElementById("op2_points").innerHTML = ''
    if (frm.op2.checked) {document.getElementById("op2_points").innerHTML = 300}
    sub_total_o()
   }

   function os_1(frm)    {document.getElementById("os1_points").innerHTML = ''
    if (frm.os1.checked) {document.getElementById("os1_points").innerHTML = 200}
    sub_total_o()
   }
   function os_2(frm)    {document.getElementById("os2_points").innerHTML = ''
    if (frm.os2.checked) {document.getElementById("os2_points").innerHTML = 300}
    sub_total_o()
   }
   function os_3(frm)    {document.getElementById("os3_points").innerHTML = ''
    if (frm.os3.checked) {document.getElementById("os3_points").innerHTML = 300}
    sub_total_o()
   }
   function os_4(frm)    {document.getElementById("os4_points").innerHTML = ''
    if (frm.os4.checked) {document.getElementById("os4_points").innerHTML = 400}
    sub_total_o()
   }
   function os_5(frm)    {document.getElementById("os5_points").innerHTML = ''
    if (frm.os5.checked) {document.getElementById("os5_points").innerHTML = 400}
    sub_total_o()
   }
   function os_6(frm)    {document.getElementById("os6_points").innerHTML = ''
    if (frm.os6.checked) {document.getElementById("os6_points").innerHTML = 400}
    sub_total_o()
   }
   function os_7(frm)    {document.getElementById("os7_points").innerHTML = ''
    if (frm.os7.checked) {document.getElementById("os7_points").innerHTML = 500}
    sub_total_o()
   }
   function os_8(frm)    {document.getElementById("os8_points").innerHTML = ''
    if (frm.os8.checked) {document.getElementById("os8_points").innerHTML = 500}
    sub_total_o()
   }
   function os_9(frm)    {document.getElementById("os9_points").innerHTML = ''
    if (frm.os9.checked) {document.getElementById("os9_points").innerHTML = 500}
    sub_total_o()
   }
   function os_10(frm)    {document.getElementById("os10_points").innerHTML = ''
    if (frm.os10.checked) {document.getElementById("os10_points").innerHTML = 700}
    sub_total_o()
   }
   function os_11(frm)    {document.getElementById("os11_points").innerHTML = ''
    if (frm.os11.checked) {document.getElementById("os11_points").innerHTML = 800}
    sub_total_o()
   }

  </script>
  <title>2019 Summit Mt. Sustainability Ecological Footprint Reduction Contest</title>
 </head>
 <body link=green onLoad="do_math()">
  <font face="trebuchet, tahoma, arial, sans serif">

    <table border=0 width=100%>
     <tr bgcolor=darkgreen>
      <th><h3><font color=white>Summit Mount Sustainability Footprint Reduction Contest<br>
        April 22 - June 1, 2019<br>
       <?php echo "Player ", $fs_email, " &ndash; location: ", $locaname ?></font></h3></th>
     </tr>
    </table>

   <form name="input" id="input" action="write_contest_data.php" method="post" onsubmit="return transferCheckboxValues()">

<input type="hidden" name="fs_email" value="<?php echo trim($fs_email);?>">
<input type="hidden" name="user" value="<?php echo trim($user);?>">
<input type="hidden" name="location" value="<?php echo trim($location);?>">
<input type="hidden" name="pointsw" value=<?php echo trim($pointsw);?>>
<input type="hidden" name="pointso" value=<?php echo trim($pointso);?>>
<input type="hidden" name="pointst" value=<?php echo trim($pointst);?>>
<input type="hidden" name="pe1">
<input type="hidden" name="pe2">
<input type="hidden" name="pe3">
<input type="hidden" name="pe4">
<input type="hidden" name="pe5">
<input type="hidden" name="pe6">

<input type="hidden" name="pw1">
<input type="hidden" name="pw2">

<input type="hidden" name="pt1">
<input type="hidden" name="pt2">
<input type="hidden" name="pt3">

<input type="hidden" name="pr1">
<input type="hidden" name="pr2">
<input type="hidden" name="pr3">
<input type="hidden" name="pr4">
<input type="hidden" name="pr5">
<input type="hidden" name="pr6">
<input type="hidden" name="pr7">
<input type="hidden" name="pr8">

<input type="hidden" name="pp1">
<input type="hidden" name="pp2">

<input type="hidden" name="ps1">

<input type="hidden" name="ope1">
<input type="hidden" name="ope2">
<input type="hidden" name="ope3">
<input type="hidden" name="ope4">
<input type="hidden" name="ope5">

<input type="hidden" name="opw1">
<input type="hidden" name="opw2">
<input type="hidden" name="opw3">
<input type="hidden" name="opw4">

<input type="hidden" name="opt1">
<input type="hidden" name="opt2">
<input type="hidden" name="opt3">

<input type="hidden" name="opr1">
<input type="hidden" name="opr2">
<input type="hidden" name="opr3">
<input type="hidden" name="opr4">
<input type="hidden" name="opr5">
<input type="hidden" name="opr6">
<input type="hidden" name="opr7">
<input type="hidden" name="opr8">
<input type="hidden" name="opr9">
<input type="hidden" name="opr10">

<input type="hidden" name="opp1">
<input type="hidden" name="opp2">

<input type="hidden" name="ops1">
<input type="hidden" name="ops2">
<input type="hidden" name="ops3">
<input type="hidden" name="ops4">
<input type="hidden" name="ops5">
<input type="hidden" name="ops6">
<input type="hidden" name="ops7">
<input type="hidden" name="ops8">
<input type="hidden" name="ops9">
<input type="hidden" name="ops10">
<input type="hidden" name="ops11">

    <table border=1>
     <tr>
         <th bgcolor=salmon><input type="submit" value="Save Green Actions"></th>
         <th colspan=8 bgcolor=salmon><?php $pointst = $pointsw + $pointso; ?>
<?php echo "$fs_email at $locaname has reported " ?>
         <span id="total"><?php echo $pointst; ?></span>
         <?php echo "points (targets 9,000 for one and 15,000 for a second four-hour time-off award)" ?>
      </th>
     </tr>
     <tr bgcolor="lightgreen"><th rowspan=2>FOOTPRINT AREA<br><font size=-1>(13,200 points)</font></th><th colspan=6>WEEK</th><th>POINTS</th><th rowspan=2>WEEKLY ACTIONS</th></tr>
      <th title="April 22 - 28, 2019">1<br><font size=1>Apr&nbsp;22</font></th>
      <th title="April 29 - May 5, 2019">2<br><font size=1>Apr&nbsp;29</font></th>
      <th title="May 6 - 12, 2019">3<br><font size=1>May&nbsp;06</font></th>
      <th title="May 13 - 21, 2019">4<br><font size=1>May&nbsp;13</font></th>
      <th title="May 20 - 28, 2019">5<br><font size=1>May&nbsp;20</font></th>
      <th title="May 27 - June 2, 2019">6<br><font size=1>May&nbsp;27</font></th>
      <td align=right bgcolor=salmon><span id="subtotal"><?php echo $pointsw; ?></span></td>
     </tr>

<!-- ENERGY -->
     <tr><!-- E1 -->
      <th rowspan=6 bgcolor="lightgreen"><h3>Energy<br><font size=-1>(5400 points)</font></h3></th>
      <th title='150 points'><input type=checkbox name="e1" onClick='javascript:e_1(this.form)' <?php if ($e1_1) echo "checked"; ?>></th>
      <th title='150 points'><input type=checkbox name="e1" onClick='javascript:e_1(this.form)' <?php if ($e1_2) echo "checked"; if ($today < $week2) echo "disabled" ?>></th>
      <th title='150 points'><input type=checkbox name="e1" onClick='javascript:e_1(this.form)' <?php if ($e1_3) echo "checked"; if ($today < $week3) echo "disabled" ?>></th>
      <th title='150 points'><input type=checkbox name="e1" onClick='javascript:e_1(this.form)' <?php if ($e1_4) echo "checked"; if ($today < $week4) echo "disabled" ?>></th>
      <th title='150 points'><input type=checkbox name="e1" onClick='javascript:e_1(this.form)' <?php if ($e1_5) echo "checked"; if ($today < $week5) echo "disabled" ?>></th>
      <th title='150 points'><input type=checkbox name="e1" onClick='javascript:e_1(this.form)' <?php if ($e1_6) echo "checked"; if ($today < $week6) echo "disabled" ?>></th>
      <td align=right><span id='e1_points'></span></td>
      <td>I shut down or restarted my computer and shut off IT peripherals (monitors, printers, etc.) prior to leaving the office at least 4 out of 5 workdays.<br>
          <font size=-1>Performing a restart of your computer every night ensures maximum Windows performance, keeps your computer in a lower power state, and allows security updates to be fully installed as soon as possible. <font size=1>(150 pts)</font></td>
     </tr>
     <tr><!-- E2 -->
      <th title='150 points'><input type=checkbox name=e2 onClick='javascript:e_2(this.form)' <?php if ($e2_1) echo "checked"; ?>></th>
      <th title='150 points'><input type=checkbox name=e2 onClick='javascript:e_2(this.form)' <?php if ($e2_2) echo "checked"; if ($today < $week2) echo "disabled" ?>></th>
      <th title='150 points'><input type=checkbox name=e2 onClick='javascript:e_2(this.form)' <?php if ($e2_3) echo "checked"; if ($today < $week3) echo "disabled" ?>></th>
      <th title='150 points'><input type=checkbox name=e2 onClick='javascript:e_2(this.form)' <?php if ($e2_4) echo "checked"; if ($today < $week4) echo "disabled" ?>></th>
      <th title='150 points'><input type=checkbox name=e2 onClick='javascript:e_2(this.form)' <?php if ($e2_5) echo "checked"; if ($today < $week5) echo "disabled" ?>></th>
      <th title='150 points'><input type=checkbox name=e2 onClick='javascript:e_2(this.form)' <?php if ($e2_6) echo "checked"; if ($today < $week6) echo "disabled" ?>></th>
      <td align=right><span id='e2_points'></span></td>
      <td>I used stairs instead of the elevator all week <font size=1>(150 pts)</font></td>
     </tr>
     <tr><!-- E3 -->
      <th title='150 points'><input type=checkbox name=e3 onClick='javascript:e_3(this.form)' <?php if ($e3_1) echo "checked"; ?>></th>
      <th title='150 points'><input type=checkbox name=e3 onClick='javascript:e_3(this.form)' <?php if ($e3_2) echo "checked"; if ($today < $week2) echo "disabled" ?>></th>
      <th title='150 points'><input type=checkbox name=e3 onClick='javascript:e_3(this.form)' <?php if ($e3_3) echo "checked"; if ($today < $week3) echo "disabled" ?>></th>
      <th title='150 points'><input type=checkbox name=e3 onClick='javascript:e_3(this.form)' <?php if ($e3_4) echo "checked"; if ($today < $week4) echo "disabled" ?>></th>
      <th title='150 points'><input type=checkbox name=e3 onClick='javascript:e_3(this.form)' <?php if ($e3_5) echo "checked"; if ($today < $week5) echo "disabled" ?>></th>
      <th title='150 points'><input type=checkbox name=e3 onClick='javascript:e_3(this.form)' <?php if ($e3_6) echo "checked"; if ($today < $week6) echo "disabled" ?>></th>
      <td align=right><span id='e3_points'></span></td>
      <td>I used task lighting or natural light all week<br>
          <font size=-1>This may include overhead lights if half or more of the ballasts have been removed to reduce glare and conserve energy <font size=1>(150 pts)</font></td>
     </tr>
     <tr><!-- E4 -->
      <th title='150 points'><input type=checkbox name=e4 onClick='javascript:e_4(this.form)' <?php if ($e4_1) echo "checked"; ?>></th>
      <th title='150 points'><input type=checkbox name=e4 onClick='javascript:e_4(this.form)' <?php if ($e4_2) echo "checked"; if ($today < $week2) echo "disabled" ?>></th>
      <th title='150 points'><input type=checkbox name=e4 onClick='javascript:e_4(this.form)' <?php if ($e4_3) echo "checked"; if ($today < $week3) echo "disabled" ?>></th>
      <th title='150 points'><input type=checkbox name=e4 onClick='javascript:e_4(this.form)' <?php if ($e4_4) echo "checked"; if ($today < $week4) echo "disabled" ?>></th>
      <th title='150 points'><input type=checkbox name=e4 onClick='javascript:e_4(this.form)' <?php if ($e4_5) echo "checked"; if ($today < $week5) echo "disabled" ?>></th>
      <th title='150 points'><input type=checkbox name=e4 onClick='javascript:e_4(this.form)' <?php if ($e4_6) echo "checked"; if ($today < $week6) echo "disabled" ?>></th>
      <td align=right><span id='e4_points'></span></td>
      <td>I washed clothes with cold water instead of warm or hot water <font size=1>(150 pts)</font></td>
     </tr>
     <tr><!-- E5 -->
      <th title='150 points'><input type=checkbox name=e5 onClick='javascript:e_5(this.form)' <?php if ($e5_1) echo "checked"; ?>></th>
      <th title='150 points'><input type=checkbox name=e5 onClick='javascript:e_5(this.form)' <?php if ($e5_2) echo "checked"; if ($today < $week2) echo "disabled" ?>></th>
      <th title='150 points'><input type=checkbox name=e5 onClick='javascript:e_5(this.form)' <?php if ($e5_3) echo "checked"; if ($today < $week3) echo "disabled" ?>></th>
      <th title='150 points'><input type=checkbox name=e5 onClick='javascript:e_5(this.form)' <?php if ($e5_4) echo "checked"; if ($today < $week4) echo "disabled" ?>></th>
      <th title='150 points'><input type=checkbox name=e5 onClick='javascript:e_5(this.form)' <?php if ($e5_5) echo "checked"; if ($today < $week5) echo "disabled" ?>></th>
      <th title='150 points'><input type=checkbox name=e5 onClick='javascript:e_5(this.form)' <?php if ($e5_6) echo "checked"; if ($today < $week6) echo "disabled" ?>></th>
      <td align=right><span id='e5_points'></span></td>
      <td>I air dried clothes on a clothes line or drying rack rather than a clothes drying machine <font size=1>(150 pts)</font></td>
     </tr>
     <tr><!-- E6 -->
      <th title='150 points'><input type=checkbox name=e6 onClick='javascript:e_6(this.form)' <?php if ($e6_1) echo "checked"; ?>></th>
      <th title='150 points'><input type=checkbox name=e6 onClick='javascript:e_6(this.form)' <?php if ($e6_2) echo "checked"; if ($today < $week2) echo "disabled" ?>></th>
      <th title='150 points'><input type=checkbox name=e6 onClick='javascript:e_6(this.form)' <?php if ($e6_3) echo "checked"; if ($today < $week3) echo "disabled" ?>></th>
      <th title='150 points'><input type=checkbox name=e6 onClick='javascript:e_6(this.form)' <?php if ($e6_4) echo "checked"; if ($today < $week4) echo "disabled" ?>></th>
      <th title='150 points'><input type=checkbox name=e6 onClick='javascript:e_6(this.form)' <?php if ($e6_5) echo "checked"; if ($today < $week5) echo "disabled" ?>></th>
      <th title='150 points'><input type=checkbox name=e6 onClick='javascript:e_6(this.form)' <?php if ($e6_6) echo "checked"; if ($today < $week6) echo "disabled" ?>></th>
      <td align=right><span id='e6_points'></span></td>
      <td>I air dried dishes rather than used dishwasher's drying cycle <font size=1>(150 pts)</font></td>
     </tr>
     <tr><td colspan=9 bgcolor=lightgreen></td></tr>

<!-- WATER -->
     <tr><!-- W1 -->
      <th rowspan=2 bgcolor="lightgreen"><h3>Water<br><font size=-1>(1200 points)</font></h3></th>
      <th title='100 points'><input type=checkbox name=w1 onClick='javascript:w_1(this.form)' <?php if ($w1_1) echo "checked"; ?>></th>
      <th title='100 points'><input type=checkbox name=w1 onClick='javascript:w_1(this.form)' <?php if ($w1_2) echo "checked"; if ($today < $week2) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=w1 onClick='javascript:w_1(this.form)' <?php if ($w1_3) echo "checked"; if ($today < $week3) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=w1 onClick='javascript:w_1(this.form)' <?php if ($w1_4) echo "checked"; if ($today < $week4) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=w1 onClick='javascript:w_1(this.form)' <?php if ($w1_5) echo "checked"; if ($today < $week5) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=w1 onClick='javascript:w_1(this.form)' <?php if ($w1_6) echo "checked"; if ($today < $week6) echo "disabled" ?>></th>
      <td align=right><span id='w1_points'></span></td>
      <td>I made an active effort to reduce my water consumption this week <br> <font size=1>(I took shorter showers, turned off the faucet while brushing teeth,
          ran the dish/clothes washer only when fully loaded, swept cement/driveway instead or washing, conserved water use in labs, etc.)
          (100 pts)</font></h3></th>
     </tr>
     <tr><!-- W2 -->
      <th title='100 points'><input type=checkbox name=w2 onClick='javascript:w_2(this.form)' <?php if ($w2_1) echo "checked"; ?>></th>
      <th title='100 points'><input type=checkbox name=w2 onClick='javascript:w_2(this.form)' <?php if ($w2_2) echo "checked"; if ($today < $week2) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=w2 onClick='javascript:w_2(this.form)' <?php if ($w2_3) echo "checked"; if ($today < $week3) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=w2 onClick='javascript:w_2(this.form)' <?php if ($w2_4) echo "checked"; if ($today < $week4) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=w2 onClick='javascript:w_2(this.form)' <?php if ($w2_5) echo "checked"; if ($today < $week5) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=w2 onClick='javascript:w_2(this.form)' <?php if ($w2_6) echo "checked"; if ($today < $week6) echo "disabled" ?>></th>
      <td align=right><span id='w2_points'></span></td>
      <td>I dedicated one day a week to eating no captive-raised meat and increased my consumption of plant-based or wild-caught foods <font size=1>(100 pts)</font></h3></td>
     </tr>
     <tr><td colspan=9 bgcolor=lightgreen></td></tr>

<!-- TRANSPORTATION -->
     <tr><!-- T1 -->
      <th rowspan=3 bgcolor="lightgreen"><h3>Fleet &amp; Transportation<br><font size=-1>(1800 points)</font></h3></th>
      <th title='100 points'><input type=checkbox name=t1 onClick='javascript:t_1(this.form)' <?php if ($t1_1) echo "checked"; ?>></th>
      <th title='100 points'><input type=checkbox name=t1 onClick='javascript:t_1(this.form)' <?php if ($t1_2) echo "checked"; if ($today < $week2) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=t1 onClick='javascript:t_1(this.form)' <?php if ($t1_3) echo "checked"; if ($today < $week3) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=t1 onClick='javascript:t_1(this.form)' <?php if ($t1_4) echo "checked"; if ($today < $week4) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=t1 onClick='javascript:t_1(this.form)' <?php if ($t1_5) echo "checked"; if ($today < $week5) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=t1 onClick='javascript:t_1(this.form)' <?php if ($t1_6) echo "checked"; if ($today < $week6) echo "disabled" ?>></th>
      <td align=right><span id='t1_points'></span></td>
      <td>I actively practiced <a href="https://www.fs.fed.us/sustainableoperations/greenteam-toolkit/documents/Eco-Driving.pdf" target="_p">eco-driving procedures</a> while driving <font size=1>(100 pts)</td>
     </tr>
     <tr><!-- T2 -->
      <th title='100 points'><input type=checkbox name=t2 onClick='javascript:t_2(this.form)' <?php if ($t2_1) echo "checked"; ?>></th>
      <th title='100 points'><input type=checkbox name=t2 onClick='javascript:t_2(this.form)' <?php if ($t2_2) echo "checked"; if ($today < $week2) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=t2 onClick='javascript:t_2(this.form)' <?php if ($t2_3) echo "checked"; if ($today < $week3) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=t2 onClick='javascript:t_2(this.form)' <?php if ($t2_4) echo "checked"; if ($today < $week4) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=t2 onClick='javascript:t_2(this.form)' <?php if ($t2_5) echo "checked"; if ($today < $week5) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=t2 onClick='javascript:t_2(this.form)' <?php if ($t2_6) echo "checked"; if ($today < $week6) echo "disabled" ?>></th>
      <td align=right><span id='t2_points'></span></td>
      <td>During work I carpooled to meetings or chose to attend a meeting virtually.<font size=1> (100 pts)</h3></th>
     </tr>
     <tr><!-- T3 -->
      <th title='0 to 5 days'><input type=text size=1 value=<?php echo "'$t3_1'"; ?> name=t3 onChange='javascript:t_3(this.form)' ></th>
      <th title='0 to 5 days'><input type=text size=1 value=<?php echo "'$t3_2'"; ?> name=t3 onChange='javascript:t_3(this.form)' ></th>
      <th title='0 to 5 days'><input type=text size=1 value=<?php echo "'$t3_3'"; ?> name=t3 onChange='javascript:t_3(this.form)' ></th>
      <th title='0 to 5 days'><input type=text size=1 value=<?php echo "'$t3_4'"; ?> name=t3 onChange='javascript:t_3(this.form)' ></th>
      <th title='0 to 5 days'><input type=text size=1 value=<?php echo "'$t3_5'"; ?> name=t3 onChange='javascript:t_3(this.form)' ></th>
      <th title='0 to 5 days'><input type=text size=1 value=<?php echo "'$t3_6'"; ?> name=t3 onChange='javascript:t_3(this.form)' ></th>
      <td align=right><span id='t3_points'></span></td>
      <td>I teleworked, carpooled, used a hybrid or electric vehicle, used public transit, biked or walked to and from work 0 to 5 days during the week<font size=1> (20/day)</td>
     </tr>
     <tr><td colspan=9 bgcolor=lightgreen></td></tr>

<!-- RECYCLING -->
     <tr><!-- R1 -->
      <th rowspan=8 bgcolor="lightgreen"><h3>Waste Prevention &amp; Recycling<br><font size=-1>(4800 points)</font></h3></th>
      <th title='100 points'><input type=checkbox name=r1 onClick='javascript:r_1(this.form)' <?php if ($r1_1) echo "checked"; ?>></th>
      <th title='100 points'><input type=checkbox name=r1 onClick='javascript:r_1(this.form)' <?php if ($r1_2) echo "checked"; if ($today < $week2) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=r1 onClick='javascript:r_1(this.form)' <?php if ($r1_3) echo "checked"; if ($today < $week3) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=r1 onClick='javascript:r_1(this.form)' <?php if ($r1_4) echo "checked"; if ($today < $week4) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=r1 onClick='javascript:r_1(this.form)' <?php if ($r1_5) echo "checked"; if ($today < $week5) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=r1 onClick='javascript:r_1(this.form)' <?php if ($r1_6) echo "checked"; if ($today < $week6) echo "disabled" ?>></th>
      <td align=right><span id='r1_points'></span></td>
      <td>I used cloth towels for napkins, dish washing, and drying hands all week <font size=1>(100 pts)</h3></th>
     </tr>
     <tr><!-- R2 -->
      <th title='100 points'><input type=checkbox name=r2 onClick='javascript:r_2(this.form)' <?php if ($r2_1) echo "checked"; ?>></th>
      <th title='100 points'><input type=checkbox name=r2 onClick='javascript:r_2(this.form)' <?php if ($r2_2) echo "checked"; if ($today < $week2) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=r2 onClick='javascript:r_2(this.form)' <?php if ($r2_3) echo "checked"; if ($today < $week3) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=r2 onClick='javascript:r_2(this.form)' <?php if ($r2_4) echo "checked"; if ($today < $week4) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=r2 onClick='javascript:r_2(this.form)' <?php if ($r2_5) echo "checked"; if ($today < $week5) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=r2 onClick='javascript:r_2(this.form)' <?php if ($r2_6) echo "checked"; if ($today < $week6) echo "disabled" ?>></th>
      <td align=right><span id='r2_points'></span></td>
      <td>I made an effort to print less and accomplish more digitally (saved documentss digitally instead of printing, used print preview to prevent printing mistakes,
          used screen capture to save information I might need later, sent meeting information digitally or posted electronically, used Good On One Side paper for notes) <font size=1>(100 pts)</h3></th>
     </tr>
     <tr><!-- R3 -->
      <th title='100 points'><input type=checkbox name=r3 onClick='javascript:r_3(this.form)' <?php if ($r3_1) echo "checked"; ?>></th>
      <th title='100 points'><input type=checkbox name=r3 onClick='javascript:r_3(this.form)' <?php if ($r3_2) echo "checked"; if ($today < $week2) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=r3 onClick='javascript:r_3(this.form)' <?php if ($r3_3) echo "checked"; if ($today < $week3) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=r3 onClick='javascript:r_3(this.form)' <?php if ($r3_4) echo "checked"; if ($today < $week4) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=r3 onClick='javascript:r_3(this.form)' <?php if ($r3_5) echo "checked"; if ($today < $week5) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=r3 onClick='javascript:r_3(this.form)' <?php if ($r3_6) echo "checked"; if ($today < $week6) echo "disabled" ?>></th>
      <td align=right><span id='r3_points'></span></td>
      <td>I chose to use rechargeable batteries over non-rechargeable batteries in a device this week. <font size=1>(100 pts)</h3></th>
     </tr>
     <tr><!-- R4 -->
      <th title='100 points'><input type=checkbox name=r4 onClick='javascript:r_4(this.form)' <?php if ($r4_1) echo "checked"; ?>></th>
      <th title='100 points'><input type=checkbox name=r4 onClick='javascript:r_4(this.form)' <?php if ($r4_2) echo "checked"; if ($today < $week2) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=r4 onClick='javascript:r_4(this.form)' <?php if ($r4_3) echo "checked"; if ($today < $week3) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=r4 onClick='javascript:r_4(this.form)' <?php if ($r4_4) echo "checked"; if ($today < $week4) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=r4 onClick='javascript:r_4(this.form)' <?php if ($r4_5) echo "checked"; if ($today < $week5) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=r4 onClick='javascript:r_4(this.form)' <?php if ($r4_6) echo "checked"; if ($today < $week6) echo "disabled" ?>></th>
      <td align=right><span id='r4_points'></span></td>
      <td>I cut back on my consumption of single-use plastic: used reusable bags instead of plastic bags when shopping, stopped using straws, etc.<br>
          <font size=-1> 8 billion plastic straws are thrown away in the UK each year. </font> <font size=1>(100 pts)</h3></th>
     </tr>
     <tr><!-- R5 -->
      <th title='100 points'><input type=checkbox name=r5 onClick='javascript:r_5(this.form)' <?php if ($r5_1) echo "checked"; ?>></th>
      <th title='100 points'><input type=checkbox name=r5 onClick='javascript:r_5(this.form)' <?php if ($r5_2) echo "checked"; if ($today < $week2) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=r5 onClick='javascript:r_5(this.form)' <?php if ($r5_3) echo "checked"; if ($today < $week3) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=r5 onClick='javascript:r_5(this.form)' <?php if ($r5_4) echo "checked"; if ($today < $week4) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=r5 onClick='javascript:r_5(this.form)' <?php if ($r5_5) echo "checked"; if ($today < $week5) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=r5 onClick='javascript:r_5(this.form)' <?php if ($r5_6) echo "checked"; if ($today < $week6) echo "disabled" ?>></th>
      <td align=right><span id='r5_points'></span></td>
      <td>I reused my own water bottle or coffee mug for the week <font size=1>(100 pts)</h3></th>
     </tr>
     <tr><!-- R6 -->
      <th title='100 points'><input type=checkbox name=r6 onClick='javascript:r_6(this.form)' <?php if ($r6_1) echo "checked"; ?>></th>
      <th title='100 points'><input type=checkbox name=r6 onClick='javascript:r_6(this.form)' <?php if ($r6_2) echo "checked"; if ($today < $week2) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=r6 onClick='javascript:r_6(this.form)' <?php if ($r6_3) echo "checked"; if ($today < $week3) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=r6 onClick='javascript:r_6(this.form)' <?php if ($r6_4) echo "checked"; if ($today < $week4) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=r6 onClick='javascript:r_6(this.form)' <?php if ($r6_5) echo "checked"; if ($today < $week5) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=r6 onClick='javascript:r_6(this.form)' <?php if ($r6_6) echo "checked"; if ($today < $week6) echo "disabled" ?>></th>
      <td align=right><span id='r6_points'></span></td>
      <td>I rerouted a recyclable item that had made its way into the general waste stream <font size=1>(100 pts)</h3></th>
     </tr>
     <tr><!-- R7 -->
      <th title='100 points'><input type=checkbox name=r7 onClick='javascript:r_7(this.form)' <?php if ($r7_1) echo "checked"; ?>></th>
      <th title='100 points'><input type=checkbox name=r7 onClick='javascript:r_7(this.form)' <?php if ($r7_2) echo "checked"; if ($today < $week2) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=r7 onClick='javascript:r_7(this.form)' <?php if ($r7_3) echo "checked"; if ($today < $week3) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=r7 onClick='javascript:r_7(this.form)' <?php if ($r7_4) echo "checked"; if ($today < $week4) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=r7 onClick='javascript:r_7(this.form)' <?php if ($r7_5) echo "checked"; if ($today < $week5) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=r7 onClick='javascript:r_7(this.form)' <?php if ($r7_6) echo "checked"; if ($today < $week6) echo "disabled" ?>></th>
      <td align=right><span id='r7_points'></span></td>
      <td>I recycled or composted at least three different materials (paper, plastic, aluminum, tin, glass, cardboard, compost) at my office or home <font size=1>(100 pts)</td>
     </tr>
     <tr><!-- R8 -->
      <th title='0 to 5 days'><input type=text size=1 value=<?php echo "'$r8_1'"; ?> name=r8 onChange='javascript:r_8(this.form)'></th>
      <th title='0 to 5 days'><input type=text size=1 value=<?php echo "'$r8_2'"; ?> name=r8 onChange='javascript:r_8(this.form)'></th>
      <th title='0 to 5 days'><input type=text size=1 value=<?php echo "'$r8_3'"; ?> name=r8 onChange='javascript:r_8(this.form)'></th>
      <th title='0 to 5 days'><input type=text size=1 value=<?php echo "'$r8_4'"; ?> name=r8 onChange='javascript:r_8(this.form)'></th>
      <th title='0 to 5 days'><input type=text size=1 value=<?php echo "'$r8_5'"; ?> name=r8 onChange='javascript:r_8(this.form)'></th>
      <th title='0 to 5 days'><input type=text size=1 value=<?php echo "'$r8_6'"; ?> name=r8 onChange='javascript:r_8(this.form)'></th>
      <td align=right><span id='r8_points'></span></td>
      <td>I packed a "no-impact" lunch for work (0 to 5) days per week (used re-usable containers, etc.) <font size=1>(20/day)</td>
     </tr>
     <tr><td colspan=9 bgcolor=lightgreen></td></tr>

<!-- PURCHASING -->
     <tr><!-- P1 -->
      <th rowspan=1 bgcolor="lightgreen"><h3>Green Purchasing<br><font size=-1>(600 points)</font></h3></th>
      <th title='100 points'><input type=checkbox name=p1 onClick='javascript:p_1(this.form)' <?php if ($p1_1) echo "checked"; ?>></th>
      <th title='100 points'><input type=checkbox name=p1 onClick='javascript:p_1(this.form)' <?php if ($p1_2) echo "checked"; if ($today < $week2) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=p1 onClick='javascript:p_1(this.form)' <?php if ($p1_3) echo "checked"; if ($today < $week3) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=p1 onClick='javascript:p_1(this.form)' <?php if ($p1_4) echo "checked"; if ($today < $week4) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=p1 onClick='javascript:p_1(this.form)' <?php if ($p1_5) echo "checked"; if ($today < $week5) echo "disabled" ?>></th>
      <th title='100 points'><input type=checkbox name=p1 onClick='javascript:p_1(this.form)' <?php if ($p1_6) echo "checked"; if ($today < $week6) echo "disabled" ?>></th>
      <td align=right><span id='p1_points'></span></td>
      <td>I purchased a sustainable product instead of a non-sustainable product at home or work.<br>
          <font size=-1>Examples: bought food and supplies in bulk, used reusable packaging such as my own jars or bins, bought cloth napkins vs. paper,
           purchased 100% post-consumer recycled content paper.<br>
           Check out the following ideas for substitutes for 
           plastic <a href="http://nymag.com/strategist/article/best-reusable-eco-friendly-food-storage-bags.html" target="_p">food storage bags</a>
           and <a href="https://www.shopetee.com" target="_p">other plastics</a>.
           Consider this option if you <a href="https://earth911.com/business-policy/reduce-amazon-packaging-waste" target="_p">purchase from Amazon</a>.
          </font> <font size=1>(100 pts)</h3></th>
     </tr>
    </table>

<br><br>

    <table border=1>
     <tr bgcolor="lightgreen"><th rowspan=2>FOOTPRINT AREA<br><font size=-1>(16,800 points)</font></th><th rowspan=2></th><th>POINTS</th><th rowspan=2>ONE-TIME ACTIONS FOR CHAMPIONING GREEN IDEAS</th></tr>
     <tr><td align=right bgcolor=salmon><span id="osubtotal">0</span></td></tr>

<!-- ENERGY -->
     <tr><th bgcolor=lightgreen rowspan=5><h3>Energy<br><font size=-1>(2600 points)</font></h3></th>
      <th title='300 points'><input type=checkbox name=oe1 onClick='javascript:oe_1(this.form)' <?php if ($oe1) echo "checked"; ?>></th>
      <td align=right><span id='oe1_points'></span></td>
      <td>I set the thermostat 2 degrees lower in cold weather or 2 degrees higher in hot weather. <font size=1>(300 pts)</td>
     </tr>
     <tr><br>
      <th title='500 points'><input type=checkbox name=oe2 onClick='javascript:oe_2(this.form)' <?php if ($oe2) echo "checked"; ?>></th>
      <td align=right><span id='oe2_points'></span></td>
      <td>I plugged my IT peripherals into a power strip in an accessible area to remind me to shut off office electronics.<br>
          <font size=-1> <a href="https://www.energy.gov/energysaver/articles/choose-right-advanced-power-strip-you" target="o">Find out more about Advanced Power Strips</a>
          (https://www.energy.gov/energysaver/articles/choose-right-advanced-power-strip-you) <font size=1>(500 pts)</td>
     </tr>
     <tr>
      <th title='500 points'><input type=checkbox name=oe3 onClick='javascript:oe_3(this.form)' <?php if ($oe3) echo "checked"; ?>></th>
      <td align=right><span id='oe3_points'></span></td>
      <td>I replaced at least 3 incandescent or fluorescent bulbs to LED at home or work. <font size=1>(500 pts)</td>
     </tr>
     <tr>
      <th title='500 points'><input type=checkbox name=oe4 onClick='javascript:oe_4(this.form)' <?php if ($oe4) echo "checked"; ?>></th>
      <td align=right><span id='oe4_points'></span></td>
      <td>I removed an electronic appliance in my home that I don't need.<br>
          <font size=-1><a href="https://energy.gov/energysaver/estimating-appliance-and-home-electronic-energy-use" target="o">Find out how much energy your appliance uses</a>
          (https://energy.gov/energysaver/estimating-appliance-and-home-electronic-energy-use) <font size=1>(500 pts)</td>
     </tr>
     <tr>
      <th title='800 points'><input type=checkbox name=oe5 onClick='javascript:oe_5(this.form)' <?php if ($oe5) echo "checked"; ?>></th>
      <td align=right><span id='oe5_points'></span></td>
      <td>I purchased an Energy Star qualified appliance. <font size=1>(800 pts)</td>
     </tr>
     <tr><td colspan=9 bgcolor=lightgreen></td></tr>

<!-- WATER -->
     <tr><!-- OW1 -->
      <th bgcolor=lightgreen rowspan=4><h3>Water<br><font size=-1>(1500 points)</font></h3></th>
      <th title='500 points'><input type=checkbox name=ow1 onClick='javascript:ow_1(this.form)' <?php if ($ow1) echo "checked"; ?>></th>
      <td align=right><span id='ow1_points'></span></td>
      <td>I increased my water awareness by using Water Footprint Network's
          <a href="https://waterfootprint.org/en/resources/interactive-tools/personal-water-footprint-calculator" target="_q">Personal water footprint calculator</a>
          and
          <a href="https://waterfootprint.org/en/resources/interactive-tools/personal-water-footprint-calculator/personal-calculator-extended" target="_q">Personal waterprint calculator in depth</a> <font size=1>(500 pts)<br>
     </tr>
     <tr><!-- OW2 -->
      <th title='500 points'><input type=checkbox name=ow2 onClick='javascript:ow_2(this.form)' <?php if ($ow2) echo "checked"; ?>></th>
      <td align=right><span id='ow2_points'></span></td>
      <td>I installed (or have installed) WaterSense products, such as low flow showerheads, toilets, faucets, etc., at work or home <font size=1>(500 pts)</td>
     </tr>
     <tr><!-- OW3 -->
      <th title='500 points'><input type=checkbox name=ow3 onClick='javascript:ow_3(this.form)' <?php if ($ow3) echo "checked"; ?>></th>
      <td align=right><span id='ow3_points'></span></td>
      <td>I rethought my spring and summer yard after reading <a href="http://www.505outside.com/water-smart-tips" target="_w">505 Outside's Water Smart Tips</a> and use less water</a> in the process <font size=1>(500 pts)</td>
     </tr>
     <tr><td colspan=9 bgcolor=lightgreen></td></tr>

<!-- TRANSPORTATION -->
     <tr>
      <th bgcolor=lightgreen rowspan=3><h3>Fleet &amp; Transportation<br><font size=-1>(1500 points)</font></h3></th>
      <th title='500 points'><input type=checkbox name=ot1 onClick='javascript:ot_1(this.form)' <?php if ($ot1) echo "checked"; ?>></th>
      <td align=right><span id='ot1_points'></span></td>
      <td>I watched the video <i><a href="https://usfs.app.box.com/s/r6qj9ugkylhat0zn8v5pxp1zjpimhf2b" target="_t">Vehicle Idling Policy, Gasoline Engine Version</a></i> <font size=1> (requires log-in) (500 pts)</td>
     </tr>
     <tr>
      <th title='500 points'><input type=checkbox name=ot2 onClick='javascript:ot_2(this.form)' <?php if ($ot2) echo "checked"; ?>></th>
      <td align=right><span id='ot2_points'></span></td>
      <td>I have completed a telework agreement <font size=1>(500 pts)</td>
    </tr>
    <tr>
      <th title='500 points'><input type=checkbox name=ot3 onClick='javascript:ot_3(this.form)' <?php if ($ot3) echo "checked"; ?>></th>
      <td align=right><span id='ot3_points'></span></td>
      <td>I read <a href="https://www.nrcan.gc.ca/energy/efficiency/transportation/21038" target="_o"><i>Fuel-efficient driving techniques</i></a>
          and <a href="https://www.curbed.com/2017/9/20/16317036/best-transportation-ideas-cities-transit" target="_t"><i>101 Ways to Improve Transportation in Your City</i></a>
           <font size=1>(500 pts)</td>
    </tr>
    <tr><td colspan=9 bgcolor=lightgreen></td></tr>

<!-- RECYCLING & WASTE REDUCTION -->
    <tr>
     <th bgcolor=lightgreen rowspan=10><h3>Waste Prevention &amp; Recycling<br><font size=-1>(6200 points)</font></h3></th>
     <th title='300 points'><input type=checkbox name=or1 onClick='javascript:or_1(this.form)' <?php if ($or1) echo "checked"; ?>></th>
     <td align=right><span id='or1_points'></span></td>
     <td>I made several Good On One Side (GOOS) paper note pads for use in the office <i>or</i><br>
         I watched the <a href="https://www.youtube.com/watch?v=pF2xzeVh4Vs" target="_o">Hose2Habitat USFS Workshop</a> video <font size=1>(300 pts)</td>
    </tr>
    <tr>
     <th title='300 points'><input type=checkbox name=or2 onClick='javascript:or_2(this.form)' <?php if ($or2) echo "checked"; ?>></th>
     <td align=right><span id='or2_points'></span></td>
     <td>I assisted in switching a printer to print double sided (now or in the past) <font size=1>(300 pts)</td>
    </tr>
    <tr>
     <th title='500 points'><input type=checkbox name=or3 onClick='javascript:or_3(this.form)' <?php if ($or3) echo "checked"; ?>></th>
     <td align=right><span id='or3_points'></span></td>
     <td>I navigated the National Geographic site <a href="https://blog.education.nationalgeographic.org/2018/05/17/what-happens-to-the-plastic-we-throw-away" target="_o"><i>What Really Happens to the Plastic We Throw Away?</i></a><br>
         and read the Earth Institute article <a href="https://blogs.ei.columbia.edu/2012/01/31/what-happens-to-all-that-plastic" target="_o"><i>What Happens to All That Plastic?</i></a><br>
         <font size=1> (500 pts)</td>
    </tr>
    <tr>
     <th title='500 points'><input type=checkbox name=or4 onClick='javascript:or_4(this.form)' <?php if ($or4) echo "checked"; ?>></th>
     <td align=right><span id='or4_points'></span></td>
     <td>I read Zero Waste Nerd's <i><a href="https://zerowastenerd.com/7-ways-to-reduce-food-packaging-waste-without-access-to-bulk" target="_o">7 Ways to Reduce Food Packaging Waste</a></i> <font size=1> (500 pts)</td>
    </tr>
    <tr>
     <th title='500 points'><input type=checkbox name=or5 onClick='javascript:or_5(this.form)' <?php if ($or5) echo "checked"; ?>></th>
     <td align=right><span id='or5_points'></span></td>
     <td><em>"I Canned My Can!"</em> &ndash; I got rid of a trash bin in my office space to conserve bin liners by sharing fewer trash cans <font size=1>(500 pts)</td>
    </tr>
    <tr>
     <th title='500 points'><input type=checkbox name=or6 onClick='javascript:or_6(this.form)' <?php if ($or6) echo "checked"; ?>></th>
     <td align=right><span id='or6_points'></span></td>
     <td>I <a href="http://www.ecocycle.org/junkmail" target="_p">reduced junk mail</a> at work or at home. <font size=-1>
         <br><i>At work:</i> I volunteered to reduce junk mail by periodically removing RMRS or old employees from vendors' lists.
         <br><i>At home:</i> I reduced junk mail by opting out and removing my name from direct mail and charitable solicitation lists.
         <font size=1>(500 pts)</td>
    </tr>
    <tr>
     <th title='600 points'><input type=checkbox name=or7 onClick='javascript:or_7(this.form)' <?php if ($or7) echo "checked"; ?>></th>
     <td align=right><span id='or7_points'></span></td>
     <td>I supported <a href="http://digitalcommons.usu.edu/cgi/viewcontent.cgi?article=2693&context=extension_curall" target="_o">local and regional food systems</a> by buying locally produced food or growing my own, shopping at farmers' markets, or joining a CSA <font size=1> (600 pts)</td>
    </tr>
    <tr>
     <th title='1000 points'><input type=checkbox name=or8 onClick='javascript:or_8(this.form)' <?php if ($or8) echo "checked"; ?>></th>
     <td align=right><span id='or8_points'></span></td>
     <td>I started or continued to maintain a composting program at work or home. <font size=1>(1000 pts)</td>
    </tr>
    <tr>
     <th title='1000 points'><input type=checkbox name=or9 onClick='javascript:or_9(this.form)' <?php if ($or9) echo "checked"; ?>></th>
     <td align=right><span id='or9_points'></span></td>
     <td>I participated in recycling items not readily accepted in my community &mdash; purchased a box from <a href="http://www.terracycle.com" target="_o">TerraCycle</a>,
         contributed hard-to-recycle plastic packaging to <a href="http://trexrecycling.com" target="_o">Trex</a>, and 
         responsibly <a href="http://www.getsmartaboutdrugs.gov/content/national-take-back-day" target="_o">disposed of medications</a>.
          <font size=1> (1000 pts)</td>
    </tr>
    <tr>
     <th title='1000 points'><input type=checkbox name=or10 onClick='javascript:or_10(this.form)' <?php if ($or10) echo "checked"; ?>></th>
     <td align=right><span id='or10_points'></span></td>
     <td>I watched the TED-Ed videos<br>
      <i><a href="https://www.youtube.com/watch?v=OCzYdNSJF-k" target="_o">Are we Running out of Clean Water?</a></i> and<br>
      <i><a href="https://www.youtube.com/watch?v=sYIoPIstObU" target="_o">8 Ways to Prevent Water Pollution</a></i> and read<br>
      <i><a href="https://www.iwla.org/conservation/water/save-our-streams/sources-of-pollution-point-and-nonpoint" target="_o">Sources of Pollution: Point and NonPoint</a></i>
         <font size=1> (1000 pts)</font></td>
    </tr>
    <tr><td colspan=9 bgcolor=lightgreen></td></tr>

<!-- SUSTAINABLE LEADERSHIP -->
    <tr>
     <th bgcolor=lightgreen rowspan=11><h3>Sustainability Leadership<br><font size=-1>(5000 points)</font></h3></th>
     <th title='200 points'><input type=checkbox name=os1 onClick='javascript:os_1(this.form)' <?php if ($os1) echo "checked"; ?>></th>
     <td align=right><span id='os1_points'></span></td>
     <td>I convinced a co-worker to participate in this year's <em>Summit Mount Sustainability Footprint Reduction</em> contest <font size=1>(200 pts)</td>
    </tr>
    <tr>
     <th title='300 points'><input type=checkbox name=os2 onClick='javascript:os_2(this.form)' <?php if ($os2) echo "checked"; ?>></th>
     <td align=right><span id='os2_points'></span></td>
     <td>I took the Center for Sustainable Economy's <a href="http://myfootprint.org/" target="q">Ecological Footprint Quiz<a/><br>
         <font size=-1>The ecological footprint quiz reaches two million visitors each year. The Quiz breaks an individual’s footprint into carbon, food, housing, and goods and services components, and indicates how many global acres of cropland, pastureland, marine fisheries, and forests are impacted. <font size=1>(300 pts)</td>
    </tr>
    <tr>
     <th title='300 points'><input type=checkbox name=os3 onClick='javascript:os_3(this.form)' <?php if ($os3) echo "checked"; ?>></th>
     <td align=right><span id='os3_points'></span></td>
     <td>I calculated my <a href=" https://www.carbonfootprint.com/plastic_calculator.html" target="_o">plastic consumption</a> <font size=-1><br>
         <font size=-1>Plastic pollution is one of the most important environmental problems that we face today.
         It impacts the environment and our health and wellbeing. We have all contributed to this problem &ndash; mostly unknowingly &ndash; 
         and we must work to reduce and ultimately to end plastic pollution. Use this calculator to learn about how many plastic items you consume and discard every year! <font size=1>(300 pts)</td>
    </tr>
    <tr>
     <th title='400 points'><input type=checkbox name=os4 onClick='javascript:os_4(this.form)' <?php if ($os4) echo "checked"; ?>></th>
     <td align=right><span id='os4_points'></span></td>
     <td>I kept my work event green: I provided reusable plates and cutlery, or bought compostable disposable dishes, bought food with less packaging, locally produced food, etc. <font size=1>(400 pts)</td>
    </tr>
    <tr>
     <th title='400 points'><input type=checkbox name=os5 onClick='javascript:os_5(this.form)' <?php if ($os5) echo "checked"; ?>></th>
     <td align=right><span id='os5_points'></span></td>
     <td>I learned more about our impact on the planet (<a href="https://www.ted.com/talks/alex_steffen_sees_a_sustainable_future?referrer=playlist-earth_appreciated" target="_o">The Route to a Sustainable Future)</a>
         and some <a href="https://sustainablysavvy.com" target="_o">Sustainably Savvy</a> ways to help <font size=1>(400 pts)</td>
    </tr>
    <tr>
     <th title='400 points'><input type=checkbox name=os6 onClick='javascript:os_6(this.form)' <?php if ($os6) echo "checked"; ?>></th>
     <td align=right><span id='os6_points'></span></td>
     <td>I researched and shared with fellow employees and friends what plastic bags/film can be recycled at my location.<br>
         <font size=-1>For example, check your grocery stores for what types of plastic they accept back in addition to plastic grocery bags. <font size=1>(400 pts)</td>
    </tr>
    <tr>
     <th title='500 points'><input type=checkbox name=os7 onClick='javascript:os_7(this.form)' <?php if ($os7) echo "checked"; ?>></th>
     <td align=right><span id='os7_points'></span></td>
     <td>I read the Washington Office's <i><a href="https://www.fs.fed.us/sites/default/files/media_wysiwyg/etc-sustainable-operations-ltr.pdf" target="_o">Sustainable Operations in Incident Management</a></i> and<br>
         watched the video <i><a href="https://www.youtube.com/watch?v=Wax36EhlS3A" target="_o">Reducing Landfill Waste at Fire Camp</a></i> <font size=1>(500 pts)</td>
    </tr>
    <tr>
     <th title='500 points'><input type=checkbox name=os8 onClick='javascript:os_8(this.form)' <?php if ($os8) echo "checked"; ?>></th>
     <td align=right><span id='os8_points'></span></td>
     <td>I am an active member of the RMRS Green Team or my local Green Team  <font size=1>(500 pts)</td>
    </tr>
    <tr>
     <th title='500 points'><input type=checkbox name=os9 onClick='javascript:os_9(this.form)' <?php if ($os9) echo "checked"; ?>></th>
     <td align=right><span id='os9_points'></span></td>
     <td>I participated in community or work sustainability activities, such as Earth Day events or community education efforts <font size=1>(500 pts)</td>
    </tr>
    <tr>
     <th title='700 points'><input type=checkbox name=os10 onClick='javascript:os_10(this.form)' <?php if ($os10) echo "checked"; ?>></th>
     <td align=right><span id='os10_points'></span></td>
     <td>I watched <i><a href="https://www.youtube.com/watch?v=h5eTqjzQZDY" target="_o">Endangered Species: Worth Saving from Extinction?</a></i>  <font size=1>(700 pts)</td>
    </tr>
     <th title='800 points'><input type=checkbox name=os11 onClick='javascript:os_11(this.form)' <?php if ($os11) echo "checked"; ?>></th>
     <td align=right><span id='os11_points'></span></td>
     <td>I watched <i><a href="https://www.youtube.com/watch?v=a7MeCPfaPR0" target="_o">Protecting Endangered Species for Future Generations</a></i> <font size=1>(800 pts)</td>
    </tr>
    <tr><td align=center bgcolor=salmon colspan=4>   <input type="submit" value="Save Green Actions">  </td></tr>
   </table>
  </form>
 </body>
</html>

