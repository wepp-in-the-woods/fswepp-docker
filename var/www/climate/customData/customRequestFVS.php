<?php
require("../../shared_web/resources.php");
require("../../shared_web/resources_climate.php");
require($_SERVER["DOCUMENT_ROOT"]."/".$climate_directory."/shared/shared_scripts.php");
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "https://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="https://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Content-Language" content="en-us" />
<meta name="copyright" content="2009 USDA Forest Service Rocky Mountain Research Station" />
<meta name="author" content="USDA Forest Service - Nick Crookston" />
<meta name="robots" content="all" />
<meta name="MSSmartTagsPreventParsing" content="true" />
<meta name="description" content="Climate-FVS climate and species viability data" />
<meta name="keywords" content="FVS, Climate-FVS, species viability, global warming, global warming scenarios, " />
<title>Climate-FVS Data Request</title>
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
        $CMIP5        = $_POST['CMIP5'];
        $ALLCM5       = $_POST['ALLCM5'];
        if (strlen($emailAddress) < 3)
        {
        	print ("<p><strong class=\"error\">Error:</strong> Email address required.</p>");
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
        $max_size = "8000000"; // 50000 is the same as 50kb

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
          fwrite ($handle,"ClimateFVSready   =Yes               \n");
          fwrite ($handle,"CMIP5             =$CMIP5            \n");
          fwrite ($handle,"ALLCM5            =$ALLCM5           \n");
          fwrite ($handle,"ProjectDirectory  =$uploaddir\n"        );

          $message = "A link to your Climate-FVS data request is:\n\nhttps://forest.moscowfsl.wsu.edu/climate/$uploaddir/files.zip\n\nAnother Email will be sent when the data you requested is ready.";

          exec ("zip $uploaddir/files.zip $uploaddir/*");
          chmod ($uploaddir . "/files.zip", 0660); 

          if (strlen($outfile) > 0) unlink("$outfile");
          unlink("$outfile2");

          if (mail($emailAddress, "Climate-FVS data request received",$message,
                   "From: CustomDataRequest\nReply-To: Nicholas Crookston <ncrookston.fs@gmail.com>"))
          {
            print "<br /><br />Mail message sent.";
            mail("ncrookston.fs@gmail.com","Climate-FVS Data Request: $emailAddress",$message,
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
						<p><strong>Contact:</strong> <a href="mailto:ncrookston.fs@gmail.com">Nicholas Crookston</a></p>
						<p>USDA Forest Service - RMRS - Moscow Forestry Sciences Laboratory<br />
							Last Modified:
							<script>document.write( document.lastModified )</script>
						</p>
          </div>
				</div>
			</div>
		</div>
  	</div>
</div>

</body>
</html>
