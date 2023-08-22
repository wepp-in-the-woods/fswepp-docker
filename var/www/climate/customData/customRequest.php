<?php
require("../../shared_web/resources.php");
require("../../shared_web/resources_climate.php");
require($_SERVER["DOCUMENT_ROOT"]."/".$climate_directory."/shared/shared_scripts.php");
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Content-Language" content="en-us" />
<meta name="copyright" content="2009 USDA Forest Service Rocky Mountain Research Station" />
<meta name="author" content="USDA Forest Service - Nick Crookston" />
<meta name="robots" content="all" />
<meta name="MSSmartTagsPreventParsing" content="true" />
<meta name="description" content="Custom Data Requests for Mexico and Western North America." />
<meta name="keywords" content="data requests, climate, climate estimates, predictions, plant and climate relationships, global warming, global warming scenarios, predicting global warming, " />
<title>Custom Data Request Summary</title>
<?php
include ($_SERVER["DOCUMENT_ROOT"]."/".$shared_directory."/stylesheets.php");
?>
</head>

<body class="climate">

<?php
include($_SERVER["DOCUMENT_ROOT"]."/".$shared_directory."/left_nav.php");
?>
<div id="pagewrapper01" class="customData">
    <div id="main01">
        <div id="row01">
            <div id="section02">
                <div class="contentbox01">
                	<h1><span class="umbrella-title">Climate Estimates and Plant-Climate Relationships</span> <br />
                    Custom Data Request Summary</h1>
					<ul class="breadcrumb-nav">
						<li><a href="<?php echo ("".$home_URL.""); ?>/">Moscow Home</a> &gt; </li>
						<li><a href="<?php echo ("".$home_climate_URL.""); ?>/">Climate</a> &gt; </li>
						<li><strong>Custom Data Request Summary</strong></li>
					</ul>
								
    <?php

        $successful = 1;
        $emailAddress = $_POST['emailAddress'];
        if (strlen($emailAddress) < 3)
        {
        	print ("<p><strong class=\"error\">Error:</strong> Email address required.</p>");
        	$successful = 0;
        }

        $monthlyValues     = $_POST['monthlyValues'];
        $derivedData       = $_POST['derivedData'];
        $surface           = $_POST['surface'];
        
        if ( $monthlyValues != "Yes" And $derivedData  != "Yes")
        {
        	print ("<p><strong class=\"error\">Error:</strong> You need to request monthly, derived, or both kinds of output.</p>");
        	$successful = 0;
        }

        $currentClim           = $_POST['currentClim'];
        $CGCM3_A1B_y2030       = $_POST['CGCM3_A1B_y2030'];
        $CGCM3_A1B_y2060       = $_POST['CGCM3_A1B_y2060'];
        $CGCM3_A1B_y2090       = $_POST['CGCM3_A1B_y2090'];
        $CGCM3_A2_y2030        = $_POST['CGCM3_A2_y2030'];
        $CGCM3_A2_y2060        = $_POST['CGCM3_A2_y2060'];
        $CGCM3_A2_y2090        = $_POST['CGCM3_A2_y2090'];
        $CGCM3_B1_y2030        = $_POST['CGCM3_B1_y2030'];
        $CGCM3_B1_y2060        = $_POST['CGCM3_B1_y2060'];
        $CGCM3_B1_y2090        = $_POST['CGCM3_B1_y2090'];
        $HADCM3_A2_y2030       = $_POST['HADCM3_A2_y2030'];
        $HADCM3_A2_y2060       = $_POST['HADCM3_A2_y2060'];
        $HADCM3_A2_y2090       = $_POST['HADCM3_A2_y2090'];
        $HADCM3_B2_y2030       = $_POST['HADCM3_B2_y2030'];
        $HADCM3_B2_y2060       = $_POST['HADCM3_B2_y2060'];
        $HADCM3_B2_y2090       = $_POST['HADCM3_B2_y2090'];
        $GFDLCM21_A2_y2030     = $_POST['GFDLCM21_A2_y2030'];
        $GFDLCM21_A2_y2060     = $_POST['GFDLCM21_A2_y2060'];
        $GFDLCM21_A2_y2090     = $_POST['GFDLCM21_A2_y2090'];
        $GFDLCM21_B1_y2030     = $_POST['GFDLCM21_B1_y2030'];
        $GFDLCM21_B1_y2060     = $_POST['GFDLCM21_B1_y2060'];
        $GFDLCM21_B1_y2090     = $_POST['GFDLCM21_B1_y2090'];
        $Ensemble_rcp45_y2030  = $_POST['Ensemble_rcp45_y2030'];  
        $Ensemble_rcp45_y2060  = $_POST['Ensemble_rcp45_y2060'];  
        $Ensemble_rcp45_y2090  = $_POST['Ensemble_rcp45_y2090'];  
        $Ensemble_rcp60_y2030  = $_POST['Ensemble_rcp60_y2030'];  
        $Ensemble_rcp60_y2060  = $_POST['Ensemble_rcp60_y2060'];  
        $Ensemble_rcp60_y2090  = $_POST['Ensemble_rcp60_y2090'];  
        $Ensemble_rcp85_y2030  = $_POST['Ensemble_rcp85_y2030'];  
        $Ensemble_rcp85_y2060  = $_POST['Ensemble_rcp85_y2060'];  
        $Ensemble_rcp85_y2090  = $_POST['Ensemble_rcp85_y2090'];  
        $CCSM4_rcp45_y2030     = $_POST['CCSM4_rcp45_y2030'];  
        $CCSM4_rcp45_y2060     = $_POST['CCSM4_rcp45_y2060'];  
        $CCSM4_rcp45_y2090     = $_POST['CCSM4_rcp45_y2090'];  
        $CCSM4_rcp60_y2030     = $_POST['CCSM4_rcp60_y2030'];  
        $CCSM4_rcp60_y2060     = $_POST['CCSM4_rcp60_y2060'];  
        $CCSM4_rcp60_y2090     = $_POST['CCSM4_rcp60_y2090'];  
        $CCSM4_rcp85_y2030     = $_POST['CCSM4_rcp85_y2030'];  
        $CCSM4_rcp85_y2060     = $_POST['CCSM4_rcp85_y2060'];  
        $CCSM4_rcp85_y2090     = $_POST['CCSM4_rcp85_y2090'];  
        $GFDLCM3_rcp45_y2030   = $_POST['GFDLCM3_rcp45_y2030'];  
        $GFDLCM3_rcp45_y2060   = $_POST['GFDLCM3_rcp45_y2060'];  
        $GFDLCM3_rcp45_y2090   = $_POST['GFDLCM3_rcp45_y2090'];  
        $GFDLCM3_rcp60_y2030   = $_POST['GFDLCM3_rcp60_y2030'];  
        $GFDLCM3_rcp60_y2060   = $_POST['GFDLCM3_rcp60_y2060'];  
        $GFDLCM3_rcp60_y2090   = $_POST['GFDLCM3_rcp60_y2090'];  
        $GFDLCM3_rcp85_y2030   = $_POST['GFDLCM3_rcp85_y2030'];  
        $GFDLCM3_rcp85_y2060   = $_POST['GFDLCM3_rcp85_y2060'];  
        $GFDLCM3_rcp85_y2090   = $_POST['GFDLCM3_rcp85_y2090'];  
        $HadGEM2ES_rcp45_y2030 = $_POST['HadGEM2ES_rcp45_y2030'];  
        $HadGEM2ES_rcp45_y2060 = $_POST['HadGEM2ES_rcp45_y2060'];  
        $HadGEM2ES_rcp45_y2090 = $_POST['HadGEM2ES_rcp45_y2090'];  
        $HadGEM2ES_rcp60_y2030 = $_POST['HadGEM2ES_rcp60_y2030'];  
        $HadGEM2ES_rcp60_y2060 = $_POST['HadGEM2ES_rcp60_y2060'];  
        $HadGEM2ES_rcp60_y2090 = $_POST['HadGEM2ES_rcp60_y2090'];  
        $HadGEM2ES_rcp85_y2030 = $_POST['HadGEM2ES_rcp85_y2030'];  
        $HadGEM2ES_rcp85_y2060 = $_POST['HadGEM2ES_rcp85_y2060'];  
        $HadGEM2ES_rcp85_y2090 = $_POST['HadGEM2ES_rcp85_y2090'];  
        $CESM1BGC_rcp45_y2030  = $_POST['CESM1BGC_rcp45_y2030'];  
        $CESM1BGC_rcp45_y2060  = $_POST['CESM1BGC_rcp45_y2060'];  
        $CESM1BGC_rcp45_y2090  = $_POST['CESM1BGC_rcp45_y2090'];  
        $CESM1BGC_rcp85_y2030  = $_POST['CESM1BGC_rcp85_y2030'];  
        $CESM1BGC_rcp85_y2060  = $_POST['CESM1BGC_rcp85_y2060'];  
        $CESM1BGC_rcp85_y2090  = $_POST['CESM1BGC_rcp85_y2090'];                
        $CNRMCM5_rcp45_y2030   = $_POST['CNRMCM5_rcp45_y2030'];  
        $CNRMCM5_rcp45_y2060   = $_POST['CNRMCM5_rcp45_y2060'];  
        $CNRMCM5_rcp45_y2090   = $_POST['CNRMCM5_rcp45_y2090'];  
        $CNRMCM5_rcp85_y2030   = $_POST['CNRMCM5_rcp85_y2030'];  
        $CNRMCM5_rcp85_y2060   = $_POST['CNRMCM5_rcp85_y2060'];  
        $CNRMCM5_rcp85_y2090   = $_POST['CNRMCM5_rcp85_y2090'];                
								
        if($CGCM3_A1B_y2030       != "Yes" And 
           $CGCM3_A1B_y2060       != "Yes" And
           $CGCM3_A1B_y2090       != "Yes" And 
           $CGCM3_A2_y2030        != "Yes" And
           $CGCM3_A2_y2060        != "Yes" And 
           $CGCM3_A2_y2090        != "Yes" And
           $CGCM3_B1_y2030        != "Yes" And 
           $CGCM3_B1_y2060        != "Yes" And
           $CGCM3_B1_y2090        != "Yes" And 
           $HADCM3_A2_y2030       != "Yes" And
           $HADCM3_A2_y2060       != "Yes" And 
           $HADCM3_A2_y2090       != "Yes" And
           $HADCM3_B2_y2030       != "Yes" And 
           $HADCM3_B2_y2060       != "Yes" And
           $HADCM3_B2_y2090       != "Yes" And 
           $GFDLCM21_A2_y2030     != "Yes" And
           $GFDLCM21_A2_y2060     != "Yes" And 
           $GFDLCM21_A2_y2090     != "Yes" And
           $GFDLCM21_B1_y2030     != "Yes" And 
           $GFDLCM21_B1_y2060     != "Yes" And
           $GFDLCM21_B1_y2090     != "Yes" And 
           $Ensemble_rcp45_y2030  != "Yes" And
           $Ensemble_rcp45_y2060  != "Yes" And
           $Ensemble_rcp45_y2090  != "Yes" And
           $Ensemble_rcp60_y2030  != "Yes" And
           $Ensemble_rcp60_y2060  != "Yes" And
           $Ensemble_rcp60_y2090  != "Yes" And
           $Ensemble_rcp85_y2030  != "Yes" And
           $Ensemble_rcp85_y2060  != "Yes" And
           $Ensemble_rcp85_y2090  != "Yes" And
           $CCSM4_rcp45_y2030     != "Yes" And
           $CCSM4_rcp45_y2060     != "Yes" And
           $CCSM4_rcp45_y2090     != "Yes" And
           $CCSM4_rcp60_y2030     != "Yes" And
           $CCSM4_rcp60_y2060     != "Yes" And
           $CCSM4_rcp60_y2090     != "Yes" And
           $CCSM4_rcp85_y2030     != "Yes" And
           $CCSM4_rcp85_y2060     != "Yes" And
           $CCSM4_rcp85_y2090     != "Yes" And
           $GFDLCM3_rcp45_y2030   != "Yes" And
           $GFDLCM3_rcp45_y2060   != "Yes" And
           $GFDLCM3_rcp45_y2090   != "Yes" And
           $GFDLCM3_rcp60_y2030   != "Yes" And
           $GFDLCM3_rcp60_y2060   != "Yes" And
           $GFDLCM3_rcp60_y2090   != "Yes" And
           $GFDLCM3_rcp85_y2030   != "Yes" And
           $GFDLCM3_rcp85_y2060   != "Yes" And
           $GFDLCM3_rcp85_y2090   != "Yes" And
           $HadGEM2ES_rcp45_y2030 != "Yes" And 
           $HadGEM2ES_rcp45_y2060 != "Yes" And 
           $HadGEM2ES_rcp45_y2090 != "Yes" And 
           $HadGEM2ES_rcp60_y2030 != "Yes" And 
           $HadGEM2ES_rcp60_y2060 != "Yes" And 
           $HadGEM2ES_rcp60_y2090 != "Yes" And 
           $HadGEM2ES_rcp85_y2030 != "Yes" And 
           $HadGEM2ES_rcp85_y2060 != "Yes" And 
           $HadGEM2ES_rcp85_y2090 != "Yes" And                         
           $CESM1BGC_rcp45_y2030  != "Yes" And  
           $CESM1BGC_rcp45_y2060  != "Yes" And  
           $CESM1BGC_rcp45_y2090  != "Yes" And  
           $CESM1BGC_rcp85_y2030  != "Yes" And  
           $CESM1BGC_rcp85_y2060  != "Yes" And  
           $CESM1BGC_rcp85_y2090  != "Yes" And                
           $CNRMCM5_rcp45_y2030   != "Yes" And 
           $CNRMCM5_rcp45_y2060   != "Yes" And 
           $CNRMCM5_rcp45_y2090   != "Yes" And 
           $CNRMCM5_rcp85_y2030   != "Yes" And 
           $CNRMCM5_rcp85_y2060   != "Yes" And 
           $CNRMCM5_rcp85_y2090   != "Yes" And               
           $currentClim           != "Yes" )
        {
        	print ("<p><strong class=\"error\">Error:</strong> You need to request at least one model/scenario.</p>");
        	$successful = 0;
        }

        $fileName = $_FILES['uploadFileName']['name'];

        if (strlen ($fileName) == 0)
        {
          print ("<p><strong class=\"error\">Error:</strong> Must specify a file name.</p>");
        	$successful = 0;
        }
     	 
        if ($successful == 0)
        {
          print ("<p><strong class=\"error\">Request not processed.</strong> Press the \"Back\" button and try again.<br />");
        	exit;
        }

        print "<p>Uploaded data:  </p>";

        $allowed_ext = "txt, gz, zip"; // These are the allowed extensions of the files that are uploaded
        $max_size = "80000000"; // 50000 is the same as 50kb

        // Check Entension


        print "<p>File to upload: <strong>$fileName</strong></p>";

        $extension = pathinfo($_FILES['uploadFileName']['name']);
        $extension = $extension['extension'];
        $allowed_paths = explode(", ", $allowed_ext);
        for($i = 0; $i < count($allowed_paths); $i++)
        {
          if ($allowed_paths[$i] == "$extension") { $ok = "1"; }
        }

        // Check File Size
        if ($ok == "1")
        {
        	 $fileSize = $_FILES['uploadFileName']['size'];
          if($fileSize > $max_size)
          {
            print "<p><strong class=\"error\">Error:</strong> file is too big, limit is: $max_size bytes.</p>";
            $successful = 0;
          }
          else if ($fileSize < 10)
          {
            print "<p><strong class=\"error\">Error:</strong> file is empty (or almost empty).</p>";
            $successful = 0;
          }
          else
          {
            if(is_uploaded_file($_FILES['uploadFileName']['tmp_name']))
            {
              $uploaddir = "userData";
              $dirPlace=`uuidgen`;
              $dirPlace=substr($dirPlace, 0, strlen($dirPlace)-1);
              $uploaddir="$uploaddir/$dirPlace";
              mkdir ($uploaddir);
              chmod ($uploaddir, 0770); 
              $outfile="$uploaddir/uploadedData.$extension";
              $successful = move_uploaded_file($_FILES['uploadFileName']['tmp_name'],$outfile);
              if ($successful)
              {
                 print "<p>File successfully uploaded, $fileSize bytes.</p>";
              }
              else
              {
                 print "<p><strong class=\"error\">Error:</strong> file store failed.</p>";
                 $successful = 0;
              }
 
            }
            else
            {
            	 print "<p><strong class=\"error\">Error:</strong> upload failed.</p>";
            	 $successful = 0;
            }
          }
        }
        else
        {
          print "<p><strong class=\"error\">Error:</strong> File must have one of these extensions: $allowed_ext<br />or the file is
                too big (max is $max_size bytes).</p>";
        	$successful = 0;
        }

        if ($successful)
        {
          $outfile2="$uploaddir/requestData.txt";
          $handle = fopen($outfile2, "w");
          fwrite ($handle,"userHostIP        =" . $_SERVER['REMOTE_ADDR'] . "\n");
          fwrite ($handle,"emailAddress      =$emailAddress     \n");
          fwrite ($handle,"fileName          =$fileName         \n");
          fwrite ($handle,"extension         =$extension        \n");
          fwrite ($handle,"surface           =$surface          \n");
          fwrite ($handle,"monthlyValues     =$monthlyValues    \n");
          fwrite ($handle,"derivedData       =$derivedData      \n");
          fwrite ($handle,"currentClim       =$currentClim      \n");
          fwrite ($handle,"CGCM3_A1B_y2030   =$CGCM3_A1B_y2030  \n");
          fwrite ($handle,"CGCM3_A1B_y2060   =$CGCM3_A1B_y2060  \n");
          fwrite ($handle,"CGCM3_A1B_y2090   =$CGCM3_A1B_y2090  \n");
          fwrite ($handle,"CGCM3_A2_y2030    =$CGCM3_A2_y2030   \n");
          fwrite ($handle,"CGCM3_A2_y2060    =$CGCM3_A2_y2060   \n");
          fwrite ($handle,"CGCM3_A2_y2090    =$CGCM3_A2_y2090   \n");
          fwrite ($handle,"CGCM3_B1_y2030    =$CGCM3_B1_y2030   \n");
          fwrite ($handle,"CGCM3_B1_y2060    =$CGCM3_B1_y2060   \n");
          fwrite ($handle,"CGCM3_B1_y2090    =$CGCM3_B1_y2090   \n");
          fwrite ($handle,"HADCM3_A2_y2030   =$HADCM3_A2_y2030  \n");
          fwrite ($handle,"HADCM3_A2_y2060   =$HADCM3_A2_y2060  \n");
          fwrite ($handle,"HADCM3_A2_y2090   =$HADCM3_A2_y2090  \n");
          fwrite ($handle,"HADCM3_B2_y2030   =$HADCM3_B2_y2030  \n");
          fwrite ($handle,"HADCM3_B2_y2060   =$HADCM3_B2_y2060  \n");
          fwrite ($handle,"HADCM3_B2_y2090   =$HADCM3_B2_y2090  \n");
          fwrite ($handle,"GFDLCM21_A2_y2030 =$GFDLCM21_A2_y2030\n");
          fwrite ($handle,"GFDLCM21_A2_y2060 =$GFDLCM21_A2_y2060\n");
          fwrite ($handle,"GFDLCM21_A2_y2090 =$GFDLCM21_A2_y2090\n");
          fwrite ($handle,"GFDLCM21_B1_y2030 =$GFDLCM21_B1_y2030\n");
          fwrite ($handle,"GFDLCM21_B1_y2060 =$GFDLCM21_B1_y2060\n");
          fwrite ($handle,"GFDLCM21_B1_y2090 =$GFDLCM21_B1_y2090\n");
          fwrite ($handle,"Ensemble_rcp45_y2030  =$Ensemble_rcp45_y2030\n" );  
          fwrite ($handle,"Ensemble_rcp45_y2060  =$Ensemble_rcp45_y2060\n" );  
          fwrite ($handle,"Ensemble_rcp45_y2090  =$Ensemble_rcp45_y2090\n" );  
          fwrite ($handle,"Ensemble_rcp60_y2030  =$Ensemble_rcp60_y2030\n" );  
          fwrite ($handle,"Ensemble_rcp60_y2060  =$Ensemble_rcp60_y2060\n" );  
          fwrite ($handle,"Ensemble_rcp60_y2090  =$Ensemble_rcp60_y2090\n" );  
          fwrite ($handle,"Ensemble_rcp85_y2030  =$Ensemble_rcp85_y2030\n" );  
          fwrite ($handle,"Ensemble_rcp85_y2060  =$Ensemble_rcp85_y2060\n" );  
          fwrite ($handle,"Ensemble_rcp85_y2090  =$Ensemble_rcp85_y2090\n" );  
          fwrite ($handle,"CCSM4_rcp45_y2030     =$CCSM4_rcp45_y2030\n"    );  
          fwrite ($handle,"CCSM4_rcp45_y2060     =$CCSM4_rcp45_y2060\n"    );  
          fwrite ($handle,"CCSM4_rcp45_y2090     =$CCSM4_rcp45_y2090\n"    );  
          fwrite ($handle,"CCSM4_rcp60_y2030     =$CCSM4_rcp60_y2030\n"    );  
          fwrite ($handle,"CCSM4_rcp60_y2060     =$CCSM4_rcp60_y2060\n"    );  
          fwrite ($handle,"CCSM4_rcp60_y2090     =$CCSM4_rcp60_y2090\n"    );  
          fwrite ($handle,"CCSM4_rcp85_y2030     =$CCSM4_rcp85_y2030\n"    );  
          fwrite ($handle,"CCSM4_rcp85_y2060     =$CCSM4_rcp85_y2060\n"    );  
          fwrite ($handle,"CCSM4_rcp85_y2090     =$CCSM4_rcp85_y2090\n"    );  
          fwrite ($handle,"GFDLCM3_rcp45_y2030   =$GFDLCM3_rcp45_y2030\n"  );  
          fwrite ($handle,"GFDLCM3_rcp45_y2060   =$GFDLCM3_rcp45_y2060\n"  );  
          fwrite ($handle,"GFDLCM3_rcp45_y2090   =$GFDLCM3_rcp45_y2090\n"  );  
          fwrite ($handle,"GFDLCM3_rcp60_y2030   =$GFDLCM3_rcp60_y2030\n"  );  
          fwrite ($handle,"GFDLCM3_rcp60_y2060   =$GFDLCM3_rcp60_y2060\n"  );  
          fwrite ($handle,"GFDLCM3_rcp60_y2090   =$GFDLCM3_rcp60_y2090\n"  );  
          fwrite ($handle,"GFDLCM3_rcp85_y2030   =$GFDLCM3_rcp85_y2030\n"  );  
          fwrite ($handle,"GFDLCM3_rcp85_y2060   =$GFDLCM3_rcp85_y2060\n"  );  
          fwrite ($handle,"GFDLCM3_rcp85_y2090   =$GFDLCM3_rcp85_y2090\n"  );  
          fwrite ($handle,"HadGEM2ES_rcp45_y2030 =$HadGEM2ES_rcp45_y2030\n");  
          fwrite ($handle,"HadGEM2ES_rcp45_y2060 =$HadGEM2ES_rcp45_y2060\n");  
          fwrite ($handle,"HadGEM2ES_rcp45_y2090 =$HadGEM2ES_rcp45_y2090\n");  
          fwrite ($handle,"HadGEM2ES_rcp60_y2030 =$HadGEM2ES_rcp60_y2030\n");  
          fwrite ($handle,"HadGEM2ES_rcp60_y2060 =$HadGEM2ES_rcp60_y2060\n");  
          fwrite ($handle,"HadGEM2ES_rcp60_y2090 =$HadGEM2ES_rcp60_y2090\n");  
          fwrite ($handle,"HadGEM2ES_rcp85_y2030 =$HadGEM2ES_rcp85_y2030\n");  
          fwrite ($handle,"HadGEM2ES_rcp85_y2060 =$HadGEM2ES_rcp85_y2060\n");  
          fwrite ($handle,"HadGEM2ES_rcp85_y2090 =$HadGEM2ES_rcp85_y2090\n");  
          fwrite ($handle,"CESM1BGC_rcp45_y2030  =$CESM1BGC_rcp45_y2030\n");  
          fwrite ($handle,"CESM1BGC_rcp45_y2060  =$CESM1BGC_rcp45_y2060\n");  
          fwrite ($handle,"CESM1BGC_rcp45_y2090  =$CESM1BGC_rcp45_y2090\n");  
          fwrite ($handle,"CESM1BGC_rcp85_y2030  =$CESM1BGC_rcp85_y2030\n");  
          fwrite ($handle,"CESM1BGC_rcp85_y2060  =$CESM1BGC_rcp85_y2060\n");  
          fwrite ($handle,"CESM1BGC_rcp85_y2090  =$CESM1BGC_rcp85_y2090\n");                
          fwrite ($handle,"CNRMCM5_rcp45_y2030   =$CNRMCM5_rcp45_y2030\n"); 
          fwrite ($handle,"CNRMCM5_rcp45_y2060   =$CNRMCM5_rcp45_y2060\n"); 
          fwrite ($handle,"CNRMCM5_rcp45_y2090   =$CNRMCM5_rcp45_y2090\n"); 
          fwrite ($handle,"CNRMCM5_rcp85_y2030   =$CNRMCM5_rcp85_y2030\n"); 
          fwrite ($handle,"CNRMCM5_rcp85_y2060   =$CNRMCM5_rcp85_y2060\n"); 
          fwrite ($handle,"CNRMCM5_rcp85_y2090   =$CNRMCM5_rcp85_y2090\n");               
          fwrite ($handle,"ProjectDirectory  =$uploaddir\n"        );
          fclose($handle);

          print "<br />Surface selected:      $surface";
          print "<br />Monthly data selected: $monthlyValues";
          print "<br />Derived data selected: $derivedData";
          print "<br />Current Climate:       $currentClim";
          print "<br />CGCM3_A1B_y2030:       $CGCM3_A1B_y2030";
          print "<br />CGCM3_A1B_y2060:       $CGCM3_A1B_y2060";
          print "<br />CGCM3_A1B_y2090:       $CGCM3_A1B_y2090";
          print "<br />CGCM3_A2_y2030:        $CGCM3_A2_y2030";
          print "<br />CGCM3_A2_y2060:        $CGCM3_A2_y2060";
          print "<br />CGCM3_A2_y2090:        $CGCM3_A2_y2090";
          print "<br />CGCM3_B1_y2030:        $CGCM3_B1_y2030";
          print "<br />CGCM3_B1_y2060:        $CGCM3_B1_y2060";
          print "<br />CGCM3_B1_y2090:        $CGCM3_B1_y2090";
          print "<br />HADCM3_A2_y2030:       $HADCM3_A2_y2030";
          print "<br />HADCM3_A2_y2060:       $HADCM3_A2_y2060";
          print "<br />HADCM3_A2_y2090:       $HADCM3_A2_y2090";
          print "<br />HADCM3_B2_y2030:       $HADCM3_B2_y2030";
          print "<br />HADCM3_B2_y2060:       $HADCM3_B2_y2060";
          print "<br />HADCM3_B2_y2090:       $HADCM3_B2_y2090";
          print "<br />GFDLCM21_A2_y2030:     $GFDLCM21_A2_y2030";
          print "<br />GFDLCM21_A2_y2060:     $GFDLCM21_A2_y2060";
          print "<br />GFDLCM21_A2_y2090:     $GFDLCM21_A2_y2090";
          print "<br />GFDLCM21_B1_y2030:     $GFDLCM21_B1_y2030";
          print "<br />GFDLCM21_B1_y2060:     $GFDLCM21_B1_y2060";
          print "<br />GFDLCM21_B1_y2090:     $GFDLCM21_B1_y2090";
          print "<br />Ensemble_rcp45_y2030:  $Ensemble_rcp45_y2030" ;  
          print "<br />Ensemble_rcp45_y2060:  $Ensemble_rcp45_y2060" ;  
          print "<br />Ensemble_rcp45_y2090:  $Ensemble_rcp45_y2090" ;  
          print "<br />Ensemble_rcp60_y2030:  $Ensemble_rcp60_y2030" ;  
          print "<br />Ensemble_rcp60_y2060:  $Ensemble_rcp60_y2060" ;  
          print "<br />Ensemble_rcp60_y2090:  $Ensemble_rcp60_y2090" ;  
          print "<br />Ensemble_rcp85_y2030:  $Ensemble_rcp85_y2030" ;  
          print "<br />Ensemble_rcp85_y2060:  $Ensemble_rcp85_y2060" ;  
          print "<br />Ensemble_rcp85_y2090:  $Ensemble_rcp85_y2090" ;  
          print "<br />CCSM4_rcp45_y2030:     $CCSM4_rcp45_y2030"    ;  
          print "<br />CCSM4_rcp45_y2060:     $CCSM4_rcp45_y2060"    ;  
          print "<br />CCSM4_rcp45_y2090:     $CCSM4_rcp45_y2090"    ;  
          print "<br />CCSM4_rcp60_y2030:     $CCSM4_rcp60_y2030"    ;  
          print "<br />CCSM4_rcp60_y2060:     $CCSM4_rcp60_y2060"    ;  
          print "<br />CCSM4_rcp60_y2090:     $CCSM4_rcp60_y2090"    ;  
          print "<br />CCSM4_rcp85_y2030:     $CCSM4_rcp85_y2030"    ;  
          print "<br />CCSM4_rcp85_y2060:     $CCSM4_rcp85_y2060"    ;  
          print "<br />CCSM4_rcp85_y2090:     $CCSM4_rcp85_y2090"    ;  
          print "<br />GFDLCM3_rcp45_y2030:   $GFDLCM3_rcp45_y2030"  ;  
          print "<br />GFDLCM3_rcp45_y2060:   $GFDLCM3_rcp45_y2060"  ;  
          print "<br />GFDLCM3_rcp45_y2090:   $GFDLCM3_rcp45_y2090"  ;  
          print "<br />GFDLCM3_rcp60_y2030:   $GFDLCM3_rcp60_y2030"  ;  
          print "<br />GFDLCM3_rcp60_y2060:   $GFDLCM3_rcp60_y2060"  ;  
          print "<br />GFDLCM3_rcp60_y2090:   $GFDLCM3_rcp60_y2090"  ;  
          print "<br />GFDLCM3_rcp85_y2030:   $GFDLCM3_rcp85_y2030"  ;  
          print "<br />GFDLCM3_rcp85_y2060:   $GFDLCM3_rcp85_y2060"  ;  
          print "<br />GFDLCM3_rcp85_y2090:   $GFDLCM3_rcp85_y2090"  ;  
          print "<br />HadGEM2ES_rcp45_y2030: $HadGEM2ES_rcp45_y2030";  
          print "<br />HadGEM2ES_rcp45_y2060: $HadGEM2ES_rcp45_y2060";  
          print "<br />HadGEM2ES_rcp45_y2090: $HadGEM2ES_rcp45_y2090";  
          print "<br />HadGEM2ES_rcp60_y2030: $HadGEM2ES_rcp60_y2030";  
          print "<br />HadGEM2ES_rcp60_y2060: $HadGEM2ES_rcp60_y2060";  
          print "<br />HadGEM2ES_rcp60_y2090: $HadGEM2ES_rcp60_y2090";  
          print "<br />HadGEM2ES_rcp85_y2030: $HadGEM2ES_rcp85_y2030";  
          print "<br />HadGEM2ES_rcp85_y2060: $HadGEM2ES_rcp85_y2060";  
          print "<br />HadGEM2ES_rcp85_y2090: $HadGEM2ES_rcp85_y2090";  
          print "<br />CESM1BGC_rcp45_y2030:  $CESM1BGC_rcp45_y2030";  
          print "<br />CESM1BGC_rcp45_y2060:  $CESM1BGC_rcp45_y2060";  
          print "<br />CESM1BGC_rcp45_y2090:  $CESM1BGC_rcp45_y2090";  
          print "<br />CESM1BGC_rcp85_y2030:  $CESM1BGC_rcp85_y2030";  
          print "<br />CESM1BGC_rcp85_y2060:  $CESM1BGC_rcp85_y2060";  
          print "<br />CESM1BGC_rcp85_y2090:  $CESM1BGC_rcp85_y2090";                
          print "<br />CNRMCM5_rcp45_y2030:   $CNRMCM5_rcp45_y2030";  
          print "<br />CNRMCM5_rcp45_y2060:   $CNRMCM5_rcp45_y2060";  
          print "<br />CNRMCM5_rcp45_y2090:   $CNRMCM5_rcp45_y2090";  
          print "<br />CNRMCM5_rcp85_y2030:   $CNRMCM5_rcp85_y2030";  
          print "<br />CNRMCM5_rcp85_y2060:   $CNRMCM5_rcp85_y2060";  
          print "<br />CNRMCM5_rcp85_y2090:   $CNRMCM5_rcp85_y2090";                
								
          $message = "A link to your custom data request is:\n\nhttp://forest.moscowfsl.wsu.edu/climate/$uploaddir/files.zip\n\nAnother Email will be sent when the data you requested is ready.";

          exec ("zip $uploaddir/files.zip $uploaddir/*");
          chmod ($uploaddir . "/files.zip", 0660);
          if (strlen($outfile) > 0) unlink("$outfile");
          unlink("$outfile2");

          if (mail($emailAddress, "Custom climate data request received",$message,
                   "From: CustomDataRequest\nReply-To: Nicholas Crookston <ncrookston.fs@gmail.com>"))
          {
            print "<br /><br />Mail message sent.";
            mail("ncrookston.fs@gmail.com","ClimateData Request: $emailAddress",$message,
                 "From: CustomDataRequest\nReply-To: Nicholas Crookston <ncrookston.fs@gmail.com>");
          }
          else
          {
            print "<p><strong class=\"error\">Mail message send failed.</strong></p>";
            unlink($outfile);
            unlink($outfile2);
            rmdir($uploaddir);
            print "<br /><br />Request and uploaded data were deleted.";
          }

        }
        else print "<br /><br />Data not uploaded, request not processed.";

    ?> 
	
					</div>
					<div class="footer-information">
						<p><strong>Contact:</strong> <a href="mailto:ncrookston@fs.fed.us">Nicholas Crookston</a></p>
						<p>USDA Forest Service - RMRS - Moscow Forestry Sciences Laboratory<br />
							Last Modified:
							<script>document.write( document.lastModified )</script>
						</p>
						<p><a href="http://www.fs.fed.us/disclaimers.shtml">Important Notices</a> | <a href="http://www.fs.fed.us/privacy.shtml">Privacy Policy</a></p>
					</div>
				</div>
			</div>
		</div>
  	</div>
</div>

</body>
</html>
