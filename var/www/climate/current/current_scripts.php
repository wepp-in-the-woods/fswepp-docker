<?php


function formWriteCurrentScenarioDownloads($path = ".") {
	// Write out div with files to download for each species    
	global $derived_gridname_expanded;
	global $directory_expanded;
	global $home_URL;
	global $climate_directory;
	$path_to_be = $_SERVER["DOCUMENT_ROOT"]."/".$climate_directory;  
	$first_path = $path_to_be.$path;  
	//added full path to document root  

	//exit if we can't open the directory
	if( FALSE === ( $handle = @opendir( $first_path ) ) ) return FALSE;
	// Write out divs for each species
	if ($handle = opendir($first_path)) {  
		while (false !== ($file = readdir($handle))) {
			//get a directory within $first_path
			$current_climate_path = $climate_directory.$path.$file;
			if ($file != "." && $file != ".."  && false != is_dir($first_path.$file)) {
				//if it is a directory
				$spatial_extent_full_name = $directory_expanded[$file];
				echo ("\t\t\t\t\t\t\t<div id=\"spatial-extent-".$file."\" class=\"showHide\">
\t\t\t\t\t\t\t\t<h2 class=\"alternative-header\">".$spatial_extent_full_name."</h2>\n");
				//set second path to "$file2" (scenario) [???]
				$second_path = $first_path.$file."/";
				

				//Below - write out link to ANUSPLIN Coefficients zip file if it exists
				if( FALSE === ( $handleA1 = @opendir( $second_path ) ) ) return FALSE;
				//exit if we can't open the directory
				if ($handleA1 = opendir($second_path)) {
				//open spatial extent
					while (($fileA1 = readdir ($handleA1)) !== false) {
						if ($fileA1 == "ANUCoeffs") {
						//look for ANUCoeffs dir
							$third_path = $second_path.$fileA1."/";
							//set $third_path to ANUCoeffs dir
							if( FALSE === ( $handleA2 = @opendir( $third_path ) ) ) return FALSE;
							//exit if we can't open the directory
							if ($handleA2 = opendir($third_path)) { 
								while (false !== ($fileA2 = readdir($handleA2))) {
									if ($fileA2 == "ANUCoeffs.zip") {
									//look for zip file and write out link to it if it exists
										echo ("\t\t\t\t\t\t\t\t<h3>ANUSPLIN Coefficients</h3>
						\t\t\t\t\t<p><a href=\"/".$current_climate_path."/".$fileA1."/".$fileA2."\">Download ".$fileA2."</a></p>\n");
									} 	
								}
								closedir($handleA2);
							}
						}
					}//end while
					closedir($handleA1);
				}//end if 
				

				//Below - write out link to Station Normals zip file if it exists
				if( FALSE === ( $handleS1 = @opendir( $second_path ) ) ) return FALSE;
				//exit if we can't open the directory
				if ($handleS1 = opendir($second_path)) {
				//open spatial extent
					while (false !== ($fileS1 = readdir ($handleS1))) {
						if ($fileS1 == "stationNormals") {
						//look for stationNormals dir
							$third_path = $second_path.$fileS1."/";
							if( FALSE === ( $handleS2 = @opendir( $third_path ) ) ) return FALSE;
							if ($handleS2 = opendir($third_path)) { 
								while (false !== ($fileS2 = readdir($handleS2))) {
									if ($fileS2 == "stationNormals.zip") {
									//look for zip file and write out link if it exists
										echo ("\t\t\t\t\t\t\t\t<h3>Station Normals</h3>
						\t\t\t\t\t<p><a href=\"/".$current_climate_path."/".$fileS1."/".$fileS2."\">Download ".$fileS2."</a></p>\n");

									} 	
								}
								closedir($handleS2);
							}
						}
					}//end while
					closedir($handleS1);
				}//end if 
				
				
				//open Spatial Extent dir again to look for derivedGrids	
				if($handleD1 = opendir($second_path)) {
					while(($fileD1 = readdir($handleD1)) !== false) {
						if ($fileD1 == "derivedGrids") {
						//if there is a derivedGrids dir, write out each group of files with thumbnails
							echo ("<h3>Derived Grids</h3>
							\t\t\t\t<p>The derived grids are Asciigrid files for the derived variables with each pixel 
                         representing an area about 800 (depending on latitude) by 1000 meters (30 arc seconds, 
                         0.0083333333 arc degrees). We call these 1K resolution maps. The images were made using 10K data, but
                         to be clear, the zip files at 1K resolution.</p>
                         <p>NOTE: All temperatures are in tenths of degrees C.</p>\n");
							echo ("<p><span class=\"new-info\">Notice:</span> 
                    <a href=$home_climate_URL/climate/dataNotice.php>see New Algorithms Used For Some Derived Variables</a></p>\n");
							$derived_grid_files = array();
							//create an array to contain derived grid files
							$third_path = $second_path.$fileD1."/";
							if($handleD2 = opendir($third_path)) {
								while(($fileD2 = readdir($handleD2)) !== false) {
									array_push($derived_grid_files,$fileD2);
								}
								closedir($handleD2);
							}
							sort($derived_grid_files);		
							//sort array of derived grid files alphabetically
				
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
							foreach($derived_grid_files as $derived_grid_file1) {
							//loop through array of files
								$delim = ".";
								$next_scenario = strtok($derived_grid_file1, $delim);
								$last_scenario_for_html = strtok($last_scenario_end, $delim);
								//set a variable of $derived_grid_file1 from previous loop that will be used for writing out html 
								//set $next_scenario and then check for all files extensions below
								if ($last_scenario_end != "unset.php" && $next_scenario != $last_scenario_for_html && $derived_grid_file1 != "." && $derived_grid_file1 != ".." && $next_scenario != "current" && $derived_grid_file1 != "ReadMe.txt" && $derived_grid_file1 != "index.php") {
								//check to see if we've moved on to a new grouping of files - if we have, write out last batch of files for previous scenario
									$current_climate_path = $climate_directory.$path.$file."/derivedGrids";
									echo ("<div class=\"thumbnail-file-group\">\n");
									
									
										if(array_key_exists($last_scenario_for_html, $derived_gridname_expanded)) {
											//associative key found in $derived_gridname_expanded
											echo ("\t\t\t\t\t\t<h4>".$derived_gridname_expanded[$last_scenario_for_html]."</h4>\n");
										}
										else {
											//associative key NOT found in $derived_gridname_expanded
											echo ("\t\t\t\t\t\t<h4>".$last_scenario_for_html."</h4>\n");
										} //end if else
									
									
									echo ("<div class=\"thumbnail-file-group-01\">\n");
									if ($current_scenario_tn == 1) {
									//check for thumbnail
										if ($current_scenario_png == 1) {
										//check for lg png
											echo ("<a href=\"/".$current_climate_path."/".$last_scenario_for_html.".png\" title=\"Display larger PNG file\"><img class=\"thumbnail\" src=\"/".$current_climate_path."/".$last_scenario_for_html.".tn.png\" /></a>\n");
											//write thumbnail image with link to lg png if both exist
										} else {
											echo ("<img class=\"thumbnail\" src=\"/".$current_climate_path."/".$last_scenario_for_html.".tn.png\" />\n");
										//write thumbnail image only if no lg png exists
										}
									} else {
										echo ("<p class=\"no-thumbnail\">Image not <br />available</p>\n");
									}
									echo ("</div>
									<div class=\"thumbnail-file-group-02\">\n");
									if ($current_scenario_png == 1 or $current_scenario_zip == 1 or $current_scenario_metadata_txt == 1) {
									//check to see if there is either a png and/or a zip file for current scenario of this species
										echo ("<ul>\n");
										if ($current_scenario_png == 1) {
											echo("<li><a href=\"/".$current_climate_path."/".$last_scenario_for_html.".png\" title=\"Display larger PNG file\">Display \"".$last_scenario_for_html.".png\"</a></li>\n");
											//write out link to lg png file
										}
										if ($current_scenario_zip == 1) {
											echo("<li><a href=\"/".$current_climate_path."/".$last_scenario_for_html.".zip\" title=\"Download ZIP file of ASCII grid files of maps\">Download (1K grid) \"".$last_scenario_for_html.".zip\"</a></li>\n");
											//write out link to zip file
										}
										if ($current_scenario_metadata_txt == 1) {
											echo("<li><a href=\"/".$current_climate_path."/".$last_scenario_for_html.".metadata.xml\" title=\"Display metadata \">Display \"".$last_scenario_for_html.".metadata.xml\"</a></li>\n");
											//write out link to metadata text file
										}
										echo ("</ul>\n");
									}
									echo ("</div>\n</div>\n");
									//finish writing out previous group of files
								}	
								$current_scenario_png = 0;
								$current_scenario_tn = 0;
								$current_scenario_zip = 0;
								$current_scenario_metadata_txt = 0;
								//reset file variables to "0" for a new file group
								
								foreach($derived_grid_files as $derived_grid_file2) {
								//start a new loop through files and compare with $next_scenario setting 
									$delim = ".";
									$current_scenario = strtok($derived_grid_file2, $delim);
									if ($current_scenario == $next_scenario && $derived_grid_file2 != "." && $derived_grid_file2 != ".." && $current_scenario != "current" && $derived_grid_file2 != "ReadMe.txt" && $derived_grid_file2 != "index.php") {
									//see if $derived_grid_file2 is in this set of files, if so...
										if ($derived_grid_file2 == $current_scenario.".png") {
											$current_scenario_png = 1;
											//set lg png file to true
										} else if ($derived_grid_file2 == $current_scenario.".tn.png") {
											$current_scenario_tn = 1;
											//set thumbnail file to true
										} else if ($derived_grid_file2 == $current_scenario.".zip") {
											$current_scenario_zip = 1;
											//set zip file to true
										} else if ($derived_grid_file2 == $current_scenario.".metadata.xml") {
											$current_scenario_metadata_txt = 1;
											//set metadata txt file to true
										}
									}//end if 
								}//end 2nd foreach loop 				
			
								if ($derived_grid_file1 != "." && $derived_grid_file1 != ".." && strtok($derived_grid_file1, $delim) != "current" && $derived_grid_file1 != "ReadMe.txt" && $derived_grid_file1 != "index.php") {
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
								$last_scenario_end = $derived_grid_file1;
								}
							} //end foreach	
			
							$last_scenario = strtok($last_scenario_end, $delim);
							if ($last_scenario_png == 0 && $last_scenario_tn == 0 && $last_scenario_zip == 0) {
							//check to see if last scenario file variables are set to "0" - if so, do nothing
							} else if ($derived_grid_file1 != "." && $derived_grid_file1 != ".." && $last_scenario != "current" && $derived_grid_file1 != "ReadMe.txt" && $derived_grid_file1 != "index.php") {
								//if 1-3 last scenario variables are set to "1" write out last batch of files for very last scenario (can't be written in top of foreach loop because loop is finished
								echo ("<div class=\"thumbnail-file-group\">
									<h4>".$derived_gridname_expanded[$last_scenario]."</h4>
									<div class=\"thumbnail-file-group-01\">\n");
								if ($last_scenario_tn == 1) {
								//check for thumbnail
									if ($last_scenario_png == 1) {
									//check for lg png
										echo ("<a href=\"/".$current_climate_path."/".$last_scenario.".png\" title=\"Download larger PNG file\"><img class=\"thumbnail\" src=\"/".$current_climate_path."/".$last_scenario.".tn.png\" /></a>\n");
										//write thumbnail image with link to lg png if both exist
									} else {
										echo ("<img class=\"thumbnail\" src=\"/".$current_climate_path."/".$last_scenario.".tn.png\" />\n");
										//write thumbnail image only if no lg png exists
									}
								} else {
									echo ("<p class=\"no-thumbnail\">Image not <br />available</p>\n");
								}
								echo ("</div>
									<div class=\"thumbnail-file-group-02\">\n");
								if ($last_scenario_png == 0 && $last_scenario_zip == 0) {
								//check to see if there is either a png and/or a zip file for current scenario of this species - do nothing if both are "0"
								
								} else {
								//if either are set to "1", write links to them below
									echo ("<ul>");
									if ($last_scenario_png == 1) {
										echo("<li><a href=\"/".$current_climate_path."/".$last_scenario.".png\" title=\"Download larger PNG file\">Download \"".$last_scenario.".png\"</a></li>\n");
										//write out link to lg png file
									}
									if ($last_scenario_zip == 1) {
										echo("<li><a href=\"/".$current_climate_path."/".$last_scenario.".zip\" title=\"Download ZIP file of ASCII grid files of maps\">Download \"".$last_scenario.".zip\"</a></li>\n");
										//write out link to zip file
									}
									if ($last_scenario_metadata_txt == 1) {
										echo("<li><a href=\"/".$current_climate_path."/".$last_scenario.".metadata.xml\" title=\"Display metadata file\">Display \"".$last_scenario.".metadata.xml\"</a></li>\n");
										//write out link to metadata text file
									}
									echo ("</ul>\n");
								}
								echo ("</div>\n</div>\n");
								//finish writing out very last group of files
							}
				
				
						}
					}
					closedir($handleD1);
				}//end if
				
			echo ("\t\t\t\t<h4>We used many additional variables that are computed from these - good examples are:</h4>
				\t\t\t\t<ul>
				\t\t\t\t<li>ADI Annual dryness index, DD5/MAP or sqrt(DD5)/MAP (once named AMI annual moisture index)</li>
				\t\t\t\t<li>SMI Summer dryness index, GSDD5/GSP (once named SMI, summer moisture index)</li>
				\t\t\t\t<li>PRATIO Ratio of summer precipitatioin to total precipitation, GSP/MAP</li>
				\t\t\t\t</ul>
				</div>\n");
			} //end if
		} //end while
		closedir($handle);
	} //end if
} //end function




?>
