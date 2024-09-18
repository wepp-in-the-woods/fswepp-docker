<?php


function writeSpeciesLinksFullNames($path = ".") {
	// Write out directories in directory    
	global $shared_copyright;
	// call in this variable from "/shared_web/resources.php"
	global $climate_directory;
	// call in this variable from "/climate/shared/resources_climate.php"
	$path_to_be = $_SERVER["DOCUMENT_ROOT"]."/".$climate_directory;  
	$first_path = $path_to_be.$path;  
	//added full path to document root  

	$species_list_array = file($first_path."speciesList.txt");
	//create array of species titles from txt file

	$species_dir_names = array();
	//create an array to contain species dir names
		if($handle1 = opendir($first_path)) {
			while(($species_dir_name = readdir($handle1)) !== false) {
				array_push($species_dir_names,$species_dir_name);
			}
			closedir($handle1);
		}
		sort($species_dir_names);		
		//sort array of species dir names alphabetically
		
		foreach ($species_dir_names as $species_dir_name) {
			//loop through dir names
			if ($species_dir_name != "." && $species_dir_name != ".." && $species_dir_name != "mapImageComposites" && false != is_dir($first_path.$species_dir_name)) {
				//if it is a directory
				$counter1 = 0;
				//set counter to "0" which means that species dir name has not been found in $species_list_array created from txt file
				foreach($species_list_array as $species_full_string) {
				//loop through array of species name strings and match dir name with species common name
					$species_names_array = explode("	", trim($species_full_string));
					if ($species_dir_name == $species_names_array[0] && $counter1 == 0) {
					//compare the current species dir name ($species_dir_name) to the dir name ("0" position in sub-array); if they are equal, write the name in the "1" position from the array and set other variables for use
						$counter1 = $counter1 + 1;
						$species_common_name = trim($species_names_array[1]);
						$species_scientific_name = trim($species_names_array[2]);
						$species_abbr = trim($species_names_array[3]);
						echo ("\t\t\t\t\t\t\t<li><a href=\"speciesDist/".$species_dir_name."\">".$species_common_name." [".$species_scientific_name." - ".$species_abbr."]</a></li>\n");
						$selected_species = $species_dir_name;
						//set "$selected_species" to dir name for code that writes out div with selected species data (taken from function called "formWriteSpeciesSelectedDiv"
	


//-------------------BELOW taken from above function to write out data for each species (CURRENT and FUTURE)
			$species_path = $climate_directory.$path.$selected_species;
			//set the path to the species files to download for HTML links

				// begin "Current" climate files for species--------------------------------------------begin CURRENT
				$second_path = $first_path.$selected_species."/";
				//set "second_path" to species files for PHP code
				$current_data_html_string = "";
				//create a variable to contain a string of all the current data html
				if ($handle2 = opendir($second_path)) {
				//open Species dir 
					$current_counter = 0;
					$current_png = 0;
					$current_tn = 0;
					$current_zip = 0;
					$current_metadata_txt = 0;
					while (false !== ($file2 = readdir($handle2))) {
						//open Species dir and loop through all files 
						$delim = ".";
						if (strtok($file2, $delim) == "current" && false == is_dir($second_path.$file2)) {
							//make sure it is a file, not a dir, then find first "current.xxx" 
							$current_counter = $current_counter + 1;
							if ($file2 == "current.png") {
								$current_png = 1;
								//we know that there is a lg current png file
							} else if ($file2 == "current.tn.png") {
								$current_tn = 1;
								//we know that there is a current thumbnail file
							} else if ($file2 == "current.zip") {
								$current_zip = 1;
								//we know that there is a lg current zip file
							} else if ($file2 == "current.metadata.xml") {
								$current_metadata_txt = 1;
								//we know that there is a current metadata.xml file
							} 
						}
					}//end while - looping through looking for "current.xxx" files and setting variables to true if so
					
					if ($current_counter > 0) {
						//check to see if there were any "current.xxx" files
						$current_data_html_string = "<div class=\"thumbnail-file-group\">
							<h4>Current Species Data</h4>
							<div class=\"thumbnail-file-group-01\">\n";
						if ($current_tn == 1) {
						//check for thumbnail
							if ($current_png == 1) {
								//check for lg png
$current_data_html_string = $current_data_html_string."\t\t\t\t\t\t\t\t<a href=\"/".$species_path."/current.png\" title=\"Download larger PNG file\"><img class=\"thumbnail\" src=\"/".$species_path."/current.tn.png\" width=\"102\" height=\"80\" /></a>\n";
								//write thumbnail image with link to lg png if both exist
							} else {
$current_data_html_string = $current_data_html_string."\t\t\t\t\t\t\t<img class=\"thumbnail\" src=\"/".$species_path."/current.tn.png\" width=\"102\" height=\"80\" />\n";
								//write thumbnail image only if no lg png exists
							}
						} else {
$current_data_html_string = $current_data_html_string."\t\t\t\t\t\t\t<p class=\"no-thumbnail\">Image not <br />available</p>\n";
						}
$current_data_html_string = $current_data_html_string."\t\t\t\t\t\t\t</div>
							<div class=\"thumbnail-file-group-02\">\n";
						if ($current_png == 1 or $current_zip == 1 or $current_metadata_txt == 1) {
						//check to see if there is either a png and/or a zip file for current scenario of this species
							$current_data_html_string = $current_data_html_string."\t\t\t\t\t\t\t\t<ul>\n";
							if ($current_png == 1) {
								$current_data_html_string = $current_data_html_string."\t\t\t\t\t\t\t\t\t<li><a href=\"/".$species_path."/current.png\" title=\"Download larger PNG file\">Download \"current.png\"</a></li>\n";
								//write out link to lg png file
							}
							if ($current_zip == 1) {
								$current_data_html_string = $current_data_html_string."<li><a href=\"/".$species_path."/current.zip\" title=\"Download ZIP file of ASCII grid files of maps\">Download \"current.zip\"</a></li>\n";
								//write out link to zip file
							}
							if ($current_metadata_txt == 1) {
								$current_data_html_string = $current_data_html_string."<li><a href=\"/".$species_path."/current.metadata.xml\" title=\"Display metadata text file\">Display \"current_metadata.xml\"</a></li>\n";
								//write out link to metadata text file
							}
							$current_data_html_string = $current_data_html_string."\t\t\t\t\t\t\t\t</ul>\n";
						}
						$current_data_html_string = $current_data_html_string."\t\t\t\t\t\t\t</div>\n
						</div>\n";
					}//end if - writing out "current" files
					closedir($handle2);
				} //end if (last line for writing out "current" files -----------------------end CURRENT

				// --------------------------------------------------------------------------begin FUTURE 
				$species_files = array();
				//create an array to contain species files
				if($handle3 = opendir($second_path)) {
					while(($species_climate_profile_file1 = readdir($handle3)) !== false) {
						array_push($species_files,$species_climate_profile_file1);
					}
					closedir($handle3);
				}
				sort($species_files);		
				//sort array of species files alphabetically
				$current_scenario_png = 2;
				$current_scenario_tn = 2;
				$current_scenario_zip = 2;
				$current_scenario_metadata_txt = 2;
				//set these file variables to a value with no meaning regarding code below
				$last_scenario_png = 0;
				$last_scenario_tn = 0;
				$last_scenario_zip = 0;
				$last_scenario_metadata_txt = 0;
				$second_to_last_scenario_png = 0;
				$second_to_last_scenario_tn = 0;
				$second_to_last_scenario_zip = 0;
				$second_to_last_scenario_metadata_txt = 0;
				//set these file variables to "0" since they are not used until later in code and don't need to be "unset" for loops
				$last_scenario_end = "unset.php";
				//make $next_scenario_end available but unset
				$future_data_html_string = "";
				//create a variable to contain a string of all the future data html
				foreach($species_files as $species_climate_profile_file1) {
				//loop through array of files
					$delim = ".";
					$next_scenario = strtok($species_climate_profile_file1, $delim);
					$last_scenario_for_html = strtok($last_scenario_end, $delim);
					//set a variable of $species_climate_profile_file1 from previous loop that will be used for writing out html 
					//set $next_scenario and then check for all files extensions below
					if ($last_scenario_end != "unset.php" && $next_scenario != $last_scenario_for_html && $species_climate_profile_file1 != "." && $species_climate_profile_file1 != ".." && $next_scenario != "current" && $species_climate_profile_file1 != "ReadMe.txt" && $species_climate_profile_file1 != "index.php") {
						//check to see if we've moved on to a new grouping of files - if we have, write out last batch of files for previous scenario
						$future_data_html_string = $future_data_html_string."\t\t\t\t\t\t<div class=\"thumbnail-file-group\">
							<h4>".$last_scenario_for_html."</h4>
							<div class=\"thumbnail-file-group-01\">\n";
						if ($current_scenario_tn == 1) {
						//check for thumbnail
							if ($current_scenario_png == 1) {
							//check for lg png
								$future_data_html_string = $future_data_html_string."\t\t\t\t\t\t\t\t<a href=\"/".$species_path."/".$last_scenario_for_html.".png\" title=\"Download larger PNG file\"><img class=\"thumbnail\" src=\"/".$species_path."/".$last_scenario_for_html.".tn.png\" /></a>\n";
								//write thumbnail image with link to lg png if both exist
							} else {
								$future_data_html_string = $future_data_html_string."\t\t\t\t\t\t\t\t<img class=\"thumbnail\" src=\"/".$species_path."/".$last_scenario_for_html.".tn.png\" />\n";
							//write thumbnail image only if no lg png exists
							}
						} else {
							$future_data_html_string = $future_data_html_string."\t\t\t\t\t\t\t\t<p class=\"no-thumbnail\">Image not <br />available</p>\n";
						}
						$future_data_html_string = $future_data_html_string."\t\t\t\t\t\t\t</div>
							<div class=\"thumbnail-file-group-02\">\n";
						if ($current_scenario_png == 1 or $current_scenario_zip == 1 or $current_scenario_metadata_txt == 1) {
						//check to see if there is either a png and/or a zip file for current scenario of this species
							$future_data_html_string = $future_data_html_string."\t\t\t\t\t\t\t<ul>\n";
							if ($current_scenario_png == 1) {
								$future_data_html_string = $future_data_html_string."\t\t\t\t\t\t\t\t<li><a href=\"/".$species_path."/".$last_scenario_for_html.".png\" title=\"Download larger PNG file\">Download \"".$last_scenario_for_html.".png\"</a></li>\n";
								//write out link to lg png file
							}
							if ($current_scenario_zip == 1) {
								$future_data_html_string = $future_data_html_string."\t\t\t\t\t\t\t\t<li><a href=\"/".$species_path."/".$last_scenario_for_html.".zip\" title=\"Download ZIP file of ASCII grid files of maps\">Download \"".$last_scenario_for_html.".zip\"</a></li>\n";
								//write out link to zip file
							}
							if ($current_scenario_metadata_txt == 1) {
								$future_data_html_string = $future_data_html_string."\t\t\t\t\t\t\t\t<li><a href=\"/".$species_path."/".$last_scenario_for_html.".metadata.xml\" title=\"Display metadata text file\">Display \"".$last_scenario_for_html.".metadata.xml\"</a></li>\n";
								//write out link to metadata text file
							}
							$future_data_html_string = $future_data_html_string."\t\t\t\t\t\t\t</ul>\n";
						}
						$future_data_html_string = $future_data_html_string."\t\t\t\t\t\t\t</div>\n\t\t\t\t\t\t</div>\n";
						//finish writing out previous group of files
					}	
					$current_scenario_png = 0;
					$current_scenario_tn = 0;
					$current_scenario_zip = 0;
					$current_scenario_metadata_txt = 0;
					//reset file variables to "0" for a new file group
					
					foreach($species_files as $species_climate_profile_file2) {
					//start a new loop through files and compare with $next_scenario setting 
						$delim = ".";
						$current_scenario = strtok($species_climate_profile_file2, $delim);
						if ($current_scenario == $next_scenario && $species_climate_profile_file2 != "." && $species_climate_profile_file2 != ".." && $current_scenario != "current" && $species_climate_profile_file2 != "ReadMe.txt" && $species_climate_profile_file2 != "index.php") {
						//see if $species_climate_profile_file2 is in this set of files, if so...
							if ($species_climate_profile_file2 == $current_scenario.".png") {
								$current_scenario_png = 1;
								//set lg png file to true
							} else if ($species_climate_profile_file2 == $current_scenario.".tn.png") {
								$current_scenario_tn = 1;
								//set thumbnail file to true
							} else if ($species_climate_profile_file2 == $current_scenario.".zip") {
								$current_scenario_zip = 1;
								//set zip file to true
							} else if ($species_climate_profile_file2 == $current_scenario.".metadata.xml") {
								$current_scenario_metadata_txt = 1;
								//set metadata txt file to true
							}
						}//end if 
					}//end 2nd foreach loop 				

					if ($species_climate_profile_file1 != "." && $species_climate_profile_file1 != ".." && strtok($species_climate_profile_file1, $delim) != "current" && $species_climate_profile_file1 != "ReadMe.txt" && $species_climate_profile_file1 != "index.php") {
					if ($last_scenario_png == 1) {
						$second_to_last_scenario_png = 1;
					} else if ($last_scenario_png == 0) {
						$second_to_last_scenario_png = 0;
					}
					if ($last_scenario_tn == 1) {
						$second_to_last_scenario_tn = 1;
					} else if ($last_scenario_tn == 0) {
						$second_to_last_scenario_tn = 0;
					}
					if ($last_scenario_zip == 1) {
						$second_to_last_scenario_zip = 1;
					} else if ($last_scenario_zip == 0) {
						$second_to_last_scenario_zip = 0;
					}
					if ($last_scenario_metadata_txt == 1) {
						$second_to_last_scenario_metadata_txt = 1;
					} else if ($last_scenario_metadata_txt == 0) {
						$second_to_last_scenario_metadata_txt = 0;
					}
					//set $second_to_last_scenario variables to "0" or "1" to tell if files are there for last iteration of "thumbnail-file-group" that has to come after the foreach loops
					if ($current_scenario_png == 1) {
						$last_scenario_png = 1;
					} else if ($current_scenario_png == 0) {
						$last_scenario_png = 0;
					}
					if ($current_scenario_tn == 1) {
						$last_scenario_tn = 1;
					} else if ($current_scenario_tn == 0) {
						$last_scenario_tn = 0;
					}
					if ($current_scenario_zip == 1) {
						$last_scenario_zip = 1;
					} else if ($current_scenario_zip == 0) {
						$last_scenario_zip = 0;
					}
					if ($current_scenario_metadata_txt == 1) {
						$last_scenario_metadata_txt = 1;
					} else if ($current_scenario_metadata_txt == 0) {
						$last_scenario_metadata_txt = 0;
					}
					//set $last_current_scenario variables to "0" or "1" so that they can then be passed to $second_to_last_current_scenario variables to tell if files are there for last iteration of "thumbnail-file-group" that has to come after/outside the foreach loops
					$second_to_last_scenario = $last_scenario_end;
					$last_scenario_end = $species_climate_profile_file1;
					}
				} //end foreach	

				$last_scenario = strtok($last_scenario_end, $delim);
				if ($last_scenario_png == 0 && $last_scenario_tn == 0 && $last_scenario_zip == 0) {
				//check to see if last scenario file variables are set to "0" - if so, do nothing
				} else if ($species_climate_profile_file1 != "." && $species_climate_profile_file1 != ".." && $last_scenario != "current" && $species_climate_profile_file1 != "ReadMe.txt" && $species_climate_profile_file1 != "index.php") {
					//if 1-3 last scenario variables are set to "1" write out last batch of files for very last scenario (can't be written in top of foreach loop because loop is finished
					$future_data_html_string = $future_data_html_string."\t\t\t\t\t<div class=\"thumbnail-file-group\">
						<h4>".$last_scenario."</h4>
						<div class=\"thumbnail-file-group-01\">\n";
					if ($last_scenario_tn == 1) {
					//check for thumbnail
						if ($last_scenario_png == 1) {
						//check for lg png
							$future_data_html_string = $future_data_html_string."\t\t\t\t\t\t\t<a href=\"/".$species_path."/".$last_scenario.".png\" title=\"Download larger PNG file\"><img class=\"thumbnail\" src=\"/".$species_path."/".$last_scenario.".tn.png\" /></a>\n";
							//write thumbnail image with link to lg png if both exist
						} else {
							$future_data_html_string = $future_data_html_string."\t\t\t\t\t\t\t<img class=\"thumbnail\" src=\"/".$species_path."/".$last_scenario.".tn.png\" />\n";
							//write thumbnail image only if no lg png exists
						}
					} else {
						$future_data_html_string = $future_data_html_string."\t\t\t\t\t\t\t<p class=\"no-thumbnail\">Image not <br />available</p>\n";
					}
					$future_data_html_string = $future_data_html_string."\t\t\t\t\t\t</div>
						<div class=\"thumbnail-file-group-02\">\n";
					if ($last_scenario_png == 0 && $last_scenario_zip == 0) {
					//check to see if there is either a png and/or a zip file for current scenario of this species - do nothing if both are "0"
					
					} else {
					//if either are set to "1", write links to them below
						$future_data_html_string = $future_data_html_string."\t\t\t\t\t\t\t<ul>\n";
						if ($last_scenario_png == 1) {
							$future_data_html_string = $future_data_html_string."\t\t\t\t\t\t\t\t<li><a href=\"/".$species_path."/".$last_scenario.".png\" title=\"Download larger PNG file\">Download \"".$last_scenario.".png\"</a></li>\n";
							//write out link to lg png file
						}
						if ($last_scenario_zip == 1) {
							$future_data_html_string = $future_data_html_string."\t\t\t\t\t\t\t\t<li><a href=\"/".$species_path."/".$last_scenario.".zip\" title=\"Download ZIP file of ASCII grid files of maps\">Download \"".$last_scenario.".zip\"</a></li>\n";
							//write out link to zip file
						}
						if ($last_scenario_metadata_txt == 1) {
							$future_data_html_string = $future_data_html_string."\t\t\t\t\t\t\t\t<li><a href=\"/".$species_path."/".$last_scenario."_metadata.xml\" title=\"Download metadata text file\">Download \"".$last_scenario.".metadata.xml\"</a></li>\n";
							//write out link to metadata text file
						}
						$future_data_html_string = $future_data_html_string."\t\t\t\t\t\t\t</ul>\n";
					}
					$future_data_html_string = $future_data_html_string."\t\t\t\t\t\t</div>\n\t\t\t\t\t</div>\n";
					//finish writing out very last group of files
				} // -------------------------------------------------------------------end FUTURE
//-------------------ABOVE taken from above function to write out data for each species (CURRENT and FUTURE)
	
	
//-----------	WRITING OUT PAGE					
						//create this variable for pages created for each individual species 
						$species_file_html = "<?php
require(\"../../../../shared_web/resources.php\");
require(\"../../../../shared_web/resources_climate.php\");
require(\$_SERVER[\"DOCUMENT_ROOT\"].\"/\".\$climate_directory.\"/_lib/arrays.php\");
require(\$_SERVER[\"DOCUMENT_ROOT\"].\"/\".\$climate_directory.\"/species/species_scripts.php\");
require(\$_SERVER[\"DOCUMENT_ROOT\"].\"/\".\$climate_directory.\"/shared/shared_scripts.php\");
?>
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"https://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">
<html xmlns=\"https://www.w3.org/1999/xhtml\">
<head>
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />
<meta http-equiv=\"Content-Language\" content=\"en-us\" />
<meta name=\"copyright\" content=\"<?php echo (\"\".\$shared_copyright.\"\"); ?>\" />
<meta name=\"author\" content=\"USDA Forest Service - Nick Crookston\" />
<meta name=\"robots\" content=\"all\" />
<meta name=\"MSSmartTagsPreventParsing\" content=\"true\" />
<meta name=\"description\" content=\"Predictions for ".$species_common_name." (".$species_scientific_name." - ".$species_abbr.") Community Distributions and Projections into Future Climatic Space for Mexico and Western North America.\" />
<meta name=\"keywords\" content=\"".$species_common_name.", ".$species_scientific_name.", ".$species_abbr.", plant, plants, species, climate predictions, climate prediction, species climate profiles, relationships, global warming, global warming scenarios, predicting global warming\" />
<title>".$species_common_name." (".$species_scientific_name." - ".$species_abbr."): Plant Species and Climate Profile Predictions for North America</title>
<?php
include (\$_SERVER[\"DOCUMENT_ROOT\"].\"/\".\$shared_directory.\"/stylesheets.php\");
?>
<script language=\"JavaScript\" type=\"text/javascript\">
onload = function(){
	scan();
}
</script>
</head>

<body class=\"climate\">

<?php
include(\$_SERVER[\"DOCUMENT_ROOT\"].\"/\".\$shared_directory.\"/left_nav.php\");
?>
<div id=\"pagewrapper01\" class=\"speciesClimateProfiles\">
    <div id=\"main01\">
        <div id=\"row01\">
            <div id=\"section02\">
                <div class=\"contentbox01\">
                	<h1><span class=\"umbrella-title\">Climate Estimates, Climate Change and Plant Climate Relationships</span> <br />
                    Plant Species and Climate Profile Predictions</h1>
					<ul class=\"breadcrumb-nav\">
						<li><a href=\"<?php echo (\"\".\$home_URL.\"\"); ?>/\">Moscow Home</a> &gt; </li>
						<li><a href=\"<?php echo (\"\".\$home_climate_URL.\"\"); ?>/\">Climate</a> &gt; </li>
						<li><a href=\"<?php echo (\"\".\$home_climate_URL.\"/species\"); ?>/\">Plant Species and Climate Profile Predictions</a> &gt; </li>
						<li><strong>".$species_common_name."</strong></li>
					</ul>

					<div class=\"sub-content-nav\">
						<p class=\"back-nav\"><a href=\"<?php echo (\"\".\$home_climate_URL.\"/species\"); ?>/\">&lt;&lt; Back to Species List</a></p>

						<h2>".$species_common_name." (".$species_scientific_name." - ".$species_abbr.")</h2>
	
						".$current_data_html_string.$future_data_html_string."		
						
					</div>
                    
					<div class=\"footer-information\">
						<p><strong>Contact:</strong> <a href=\"mailto:ncrookston@fs.fed.us\">Nicholas Crookston</a></p>
						<p>USDA Forest Service - RMRS - Moscow Forestry Sciences Laboratory<br />
							Last Modified:
							<script>document.write( document.lastModified )</script>
						</p>
						<p><a href=\"https://www.fs.fed.us/disclaimers.shtml\">Important Notices</a> | <a href=\"https://www.fs.fed.us/privacy.shtml\">Privacy Policy</a></p>
					</div>
                </div>
            </div>
        </div>
  	</div>
</div>

</body>
</html>";
						
						
//-----------						
						file_put_contents("".$first_path.$species_dir_name."/index.php", $species_file_html);
						//write the contents from the $species_file_html variable below into an index file in the specified species directory for each species with each type of name
					}
				}
				if ($counter1 == 0) {
				echo ("\t\t\t\t\t\t\t\t\t\t\t<li><a href=\"speciesDist/".$species_dir_name."\">".$species_dir_name."</a></li>\n");
				//write out other options

//-----------						
//create this variable for species in the event that it only has directory name (common, scientific names and abbreviation missing from array)
$species_file2_html = "<?php
require(\"../../../../shared_web/resources.php\");
require(\"../../../../shared_web/resources_climate.php\");
require(\$_SERVER[\"DOCUMENT_ROOT\"].\"/\".\$climate_directory.\"/_lib/arrays.php\");
require(\$_SERVER[\"DOCUMENT_ROOT\"].\"/\".\$climate_directory.\"/species/species_scripts.php\");
require(\$_SERVER[\"DOCUMENT_ROOT\"].\"/\".\$climate_directory.\"/shared/shared_scripts.php\");
?>
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"https://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">
<html xmlns=\"https://www.w3.org/1999/xhtml\">
<head>
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />
<meta http-equiv=\"Content-Language\" content=\"en-us\" />
<meta name=\"copyright\" content=\"<?php echo (\"\".\$shared_copyright.\"\"); ?>\" />
<meta name=\"author\" content=\"USDA Forest Service - Nick Crookston\" />
<meta name=\"robots\" content=\"all\" />
<meta name=\"MSSmartTagsPreventParsing\" content=\"true\" />
<meta name=\"description\" content=\"Predictions for ".$species_dir_name.": Community Distributions and Projections into Future Climatic Space for Mexico and Western North America.\" />
<meta name=\"keywords\" content=\"".$species_dir_name.", plant, plants, species, climate predictions, climate prediction, species climate profiles, relationships, global warming, global warming scenarios, predicting global warming\" />
<title>".$species_dir_name.": Plant Species and Climate Profile Predictions for North America</title>
<?php
include (\$_SERVER[\"DOCUMENT_ROOT\"].\"/\".\$shared_directory.\"/stylesheets.php\");
?>
<script language=\"JavaScript\" type=\"text/javascript\">
onload = function(){
	scan();
}
</script>
</head>

<body class=\"climate\">

<?php
include(\$_SERVER[\"DOCUMENT_ROOT\"].\"/\".\$shared_directory.\"/left_nav.php\");
?>
<div id=\"pagewrapper01\" class=\"speciesClimateProfiles\">
    <div id=\"main01\">
        <div id=\"row01\">
            <div id=\"section02\">
                <div class=\"contentbox01\">
                	<h1><span class=\"umbrella-title\">Climate Estimates, Climate Change and Plant Climate Relationships</span> <br />
                    Plant Species and Climate Profile Predictions</h1>
					<ul class=\"breadcrumb-nav\">
						<li><a href=\"<?php echo (\"\".\$home_URL.\"\"); ?>/\">Moscow Home</a> &gt; </li>
						<li><a href=\"<?php echo (\"\".\$home_climate_URL.\"\"); ?>/\">Climate</a> &gt; </li>
						<li><a href=\"<?php echo (\"\".\$home_climate_URL.\"/species\"); ?>/\">Plant Species and Climate Profile Predictions</a> &gt; </li>
						<li><strong>".$species_dir_name."</strong></li>
					</ul>

					<div class=\"sub-content-nav\">
						<p class=\"back-nav\"><a href=\"<?php echo (\"\".\$home_climate_URL.\"/species\"); ?>/\">&lt;&lt; Back to Species List</a></p>

						<h2>".$species_dir_name."</h2>
						".$current_data_html_string.$future_data_html_string."		
					</div>
                    
					<div class=\"footer-information\">
						<p><strong>Contact:</strong> <a href=\"mailto:ncrookston@fs.fed.us\">Nicholas Crookston</a></p>
						<p>USDA Forest Service - RMRS - Moscow Forestry Sciences Laboratory<br />
							Last Modified:
							<script>document.write( document.lastModified )</script>
						</p>
						<p><a href=\"https://www.fs.fed.us/disclaimers.shtml\">Important Notices</a> | <a href=\"https://www.fs.fed.us/privacy.shtml\">Privacy Policy</a></p>
					</div>
                </div>
            </div>
        </div>
  	</div>
</div>

</body>
</html>";
						
						
//-----------
				file_put_contents("".$first_path.$species_dir_name."/index.php", $species_file2_html);
				//write the contents from the $species_file2_html variable below into an index file in the specified species directory for each species
				}
			} //end if
		} //end FOREACH NOW
} //end function


?>
