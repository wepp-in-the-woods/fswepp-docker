<?php

function formWriteSelectOptions($path = ".", $spatial_extent_abbr = "Mex") {
	// Write out scenario directory name options for form in future directory    
	global $climate_directory;
	$path_to_be = $_SERVER["DOCUMENT_ROOT"]."/".$climate_directory;  
	$first_path = $path_to_be.$path;  
	//added full path to document root  
	echo ("\t\t\t\t\t\t\t\t<div class=\"two-column-content\"> 
\t\t\t\t\t\t\t\t\t<div class=\"two-column-content-row\">
\t\t\t\t\t\t\t\t\t\t<div class=\"two-column-content-left\"> 
\t\t\t\t\t\t\t\t\t\t\t<select name=\"".$spatial_extent_abbr."_gcm-scenario-year\" onchange=\"scan();\">\n");
	echo ("\t\t\t\t\t\t\t\t\t\t\t<option divId=\"".$spatial_extent_abbr."_Select_GCM\" class=\"scanMe\">Select One</option>");
	// Write out default option which says "Select One"
	$scenario_dir_names = array();
	//create an array to contain scenario dir names
	if ($handle_scenario_dir_name = opendir($first_path)) {
		while (($scenario_dir_name = readdir($handle_scenario_dir_name)) !== false) {
			array_push($scenario_dir_names,$scenario_dir_name);
		}
		closedir($handle_scenario_dir_name);
		sort ($scenario_dir_names);
		// sort array of scenario dir names and/or files
    }
    foreach ($scenario_dir_names as $scenario_dir_name) {
	//loop through array of scenario dir/file names
		if ($scenario_dir_name != "." && $scenario_dir_name != ".." && $scenario_dir_name != "mapImageComposites" && false != is_dir($first_path.$scenario_dir_name)) {
		//if it is a directory, write it out as an option
			echo ("\t\t\t\t\t\t\t\t\t\t\t\t<option divId=\"".$spatial_extent_abbr."_".$scenario_dir_name."\" class=\"scanMe\">".$scenario_dir_name."</option>\n");
			//write out other options
		} //end if
	} //end foreach
	echo ("\t\t\t\t\t\t\t\t\t\t\t</select>
\t\t\t\t\t\t\t\t\t\t</div>
\t\t\t\t\t\t\t\t\t\t<div class=\"two-column-content-right\">
\t\t\t\t\t\t\t\t\t\t\t<div class=\"naming-key\">
\t\t\t\t\t\t\t\t\t\t\t\t<table style=\"margin-bottom:10px;\">
\t\t\t\t\t\t\t\t\t\t\t\t\t<thead> 
\t\t\t\t\t\t\t\t\t\t\t\t\t\t<tr>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<th scope=\"col\">Abbreviation</th>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<th scope=\"col\">Data Source</th>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t</tr>
\t\t\t\t\t\t\t\t\t\t\t\t\t</thead>
\t\t\t\t\t\t\t\t\t\t\t\t\t<tbody>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t<tr>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<td>CGCM3</td>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<td><a href=\"https://www.cccma.ec.gc.ca/models/cgcm3.shtml\">Canadian Center for Climate Modeling and Analysis</a></td>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t</tr>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t<tr>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<td>GFDLCM21</td>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<td><a href=\"https://www.gfdl.noaa.gov/\">Geophysical Fluid Dynamics Laboratory</a></td
\t\t\t\t\t\t\t\t\t\t\t\t\t\t</tr>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t<tr>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<td>HADCM3</td>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<td><a href=\"https://www.metoffice.gov.uk/climatechange/science/projections/\">Hadley Center</a></td>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t</tr>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t<tr>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<td>CCSM4</td>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<td><a href=\"https://www.cesm.ucar.edu/models/ccsm4.0/\">The Community Earth System Model</a></td>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t</tr>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t<tr>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<td>GFDLCM3</td>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<td><a href=\"https://www.gfdl.noaa.gov/news-app/story.32/title.the-gfdl-cm3-model/menu.no/sec./home.\">Geophysical Fluid Dynamics Laboratory</a></td>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t</tr>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t<tr>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<td>HadGEM2ES</td>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<td><a href=\"https://www.metoffice.gov.uk/research/modelling-systems/unified-model/climate-models/hadgem2\">Met Office (UK)</a></td>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t</tr>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t<tr>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<td>CESM1BGC</td>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<td><a href=\"https://www.cesm.ucar.edu/experiments/cesm1.0\">NCAR/UCAR Boulder</a></td>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t</tr>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t<tr>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<td>CNRMCM5</td>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<td><a href=\"https://www.cnrm.meteo.fr/cmip5/\">METEO France</a></td>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t</tr>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t<tr>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<td>Ensemble</td>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<td>An ensemble of 17 CMIP5 model predictions.</td>
\t\t\t\t\t\t\t\t\t\t\t\t\t\t</tr>
\t\t\t\t\t\t\t\t\t\t\t\t\t</tbody>
\t\t\t\t\t\t\t\t\t\t\t\t</table>
\t\t\t\t\t\t\t\t\t\t\t\t<p style=\"margin-bottom:0;\">AR3 scenarios are <strong>A1B</strong>, <strong>A2</strong>, <strong>B1</strong>, and <strong>B2</strong>. 
The CMIP5 scenarios are <strong>rcp45</strong>, <strong>rcp60</strong>, and <strong>rcp85</strong>. 
These are followd by the decade of estimate (<strong>y2030</strong>, <strong>y2060</strong>, and <strong>y2090</strong>).</p>
<p>The derived grids are Asciigrid files for the derived variables with each pixel
representing an area about 800 (depending on latitude) by 1000 meters (30 arc seconds,
0.0083333333 arc degrees). We call these 1K resolution maps. The images were made using 10K data, but
to be clear, the zip files at 1K resolution. All temperatures are in tenths of degrees C.</p>
\t\t\t\t\t\t\t\t\t\t\t</div>
\t\t\t\t\t\t\t\t\t\t</div>
\t\t\t\t\t\t\t\t\t\t<p class=\"closefloat\">&nbsp;</p>
\t\t\t\t\t\t\t\t\t</div> 
\t\t\t\t\t\t\t\t</div>\n");
} //end function


function formWriteScenarioDownloads($path = ".", $spatial_extent_abbr = "Mex") {
	// Write out divs for each scenario in the future directory    
	global $derived_gridname_expanded;
	global $directory_expanded;
	global $filename_expanded;
	global $spatial_extent_abbr_expanded;
	global $climate_directory;
	$path_to_be = $_SERVER["DOCUMENT_ROOT"]."/".$climate_directory;  
	$first_path = $path_to_be.$path;  
	//added full path to document root  

	//exit if we can't open the directory
	if( FALSE === ( $handle = @opendir( $first_path ) ) ) return FALSE;

	if ($handle = opendir($first_path)) {  
		// First (below), write out corresponding div to default <option> in form - (for "Select One" - if you don't do this, you will get an error, though the div is empty and so, doesn't appear on the page
		echo ("\t\t\t\t\t\t\t\t<div id=\"".$spatial_extent_abbr."_Select_GCM\" class=\"showHide\">
		\t\t\t\t\t\t\t</div>\n");
		while (false !== ($file = readdir($handle))) {
			//get a directory within $first_path
			if ($file != "." && $file != ".."  && $file != "mapImageComposites" && false != is_dir($first_path.$file)) {
				//if it is a directory (spatial extent) and not a file, write out link to Anusplin Coefficient file and Station Normals file
				echo ("\t\t\t\t\t\t\t\t<div id=\"".$spatial_extent_abbr."_".$file."\" class=\"showHide\">
\t\t\t\t\t\t\t\t<h2 class=\"alternative-header\">".$spatial_extent_abbr_expanded[$spatial_extent_abbr]." &#8212; ".$file."</h2>
\t\t\t\t\t\t\t\t<h3>ANUSPLIN Coefficients</h3>
\t\t\t\t\t\t\t\t<p><a href=\"/".$climate_directory.$path.$file."/ANUCoeffs/ANUCoeffs.zip\">Download ANUSPLIN Coefficients</a></p>
\t\t\t\t\t\t\t\t<h3>Station Normals</h3>
\t\t\t\t\t\t\t\t<p><a href=\"/".$climate_directory.$path.$file."/stationNormals/stationNormals.zip\">Download Station Normals</a></p>\n");
				//set $second_path variable to spatial extent dir
				$second_path = $first_path.$file."/";
				//open Spatial Extent dir to look for derivedGrids files
				if($handleD1 = opendir($second_path)) { //begin if - DERIVED GRIDS w/THUMBNAILS
					while(($fileD1 = readdir($handleD1)) !== false) {
						if ($fileD1 == "derivedGrids") {
						//if there is a derivedGrids dir, write out each group of files with thumbnails
							echo ("<h3>Derived Grids</h3>
\t\t\t\t\t\t\t\t<p>The derived grids are Asciigrid files for the derived variables. The files included in the zip files below are in Windows format. <br /><span class=\"note\">NOTE: All temperatures are in tenths of degrees C.</span></p>");
							echo ("<p><span class=\"new-info\">Notice:</span> <a href=$home_climate_URL/climate/dataNotice.php>see New Algorithms Used For Some Derived Variables</a></p>\n");
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
									$species_path = $climate_directory.$path.$file."/derivedGrids";
									echo ("<div class=\"thumbnail-file-group\">");
									
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
											echo ("<a href=\"/".$species_path."/".$last_scenario_for_html.".png\" title=\"Display larger PNG file\"><img class=\"thumbnail\" src=\"/".$species_path."/".$last_scenario_for_html.".tn.png\" /></a>\n");
											//write thumbnail image with link to lg png if both exist
										} else {
											echo ("<img class=\"thumbnail\" src=\"/".$species_path."/".$last_scenario_for_html.".tn.png\" />\n");
										//write thumbnail image only if no lg png exists
										}
									} else {
										echo ("<p class=\"no-thumbnail\">Image not <br />available</p>\n");
									}
									echo ("</div>
									<div class=\"thumbnail-file-group-02\">\n");
									if ($current_scenario_png == 1 or $current_scenario_zip == 1 or $current_scenario_metadata_txt == 1) {
									//check to see if there is either a png and/or a zip file for current scenario of this species
										echo ("<ul>");
										if ($current_scenario_png == 1) {
											echo("<li><a href=\"/".$species_path."/".$last_scenario_for_html.".png\" title=\"Display larger PNG file\">Display \"".$last_scenario_for_html.".png\"</a></li>");
											//write out link to lg png file
										}
										if ($current_scenario_zip == 1) {
											echo("<li><a href=\"/".$species_path."/".$last_scenario_for_html.".zip\" title=\"Download ZIP file of ASCII grid files of maps\">Download (1K grid) \"".$last_scenario_for_html.".zip\"</a></li>");
											//write out link to zip file
										}
										if ($current_scenario_metadata_txt == 1) {
											echo("<li><a href=\"/".$species_path."/".$last_scenario_for_html."_metadata.xml\" title=\"Display metadata text file\">Display \"".$last_scenario_for_html.".metadata.xml\"</a></li>");
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
										echo ("<a href=\"/".$species_path."/".$last_scenario.".png\" title=\"Download larger PNG file\"><img class=\"thumbnail\" src=\"/".$species_path."/".$last_scenario.".tn.png\" /></a>\n");
										//write thumbnail image with link to lg png if both exist
									} else {
										echo ("<img class=\"thumbnail\" src=\"/".$species_path."/".$last_scenario.".tn.png\" />\n");
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
										echo("<li><a href=\"/".$species_path."/".$last_scenario.".png\" title=\"Display larger PNG file\">Display \"".$last_scenario.".png\"</a></li>\n");
										//write out link to lg png file
									}
									if ($last_scenario_zip == 1) {
										echo("<li><a href=\"/".$species_path."/".$last_scenario.".zip\" title=\"Download ZIP file of ASCII grid files of maps\">Download (1K grid) \"".$last_scenario.".zip\"</a></li>\n");
										//write out link to zip file
									}
									if ($last_scenario_metadata_txt == 1) {
										echo("<li><a href=\"/".$species_path."/".$last_scenario."_metadata.xml\" title=\"Display metadata text file\">Display \"".$last_scenario.".metadata.xml\"</a></li>\n");
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
				}//end if - DERIVED GRIDS w/THUMBNAILS END
				
				echo ("\t\t\t\t<h4>We used many additional variables that are computed from these - good examples are:</h4>
					\t\t\t\t<ul>
						\t\t\t\t<li>ADI Annual dryness index, DD5/MAP or sqrt(DD5)/MAP (once named AMI annual moisture index)</li>
						\t\t\t\t<li>SMI Summer dryness index, GSDD5/GSP (once named SMI, summer moisture index)</li>
						\t\t\t\t<li>PRATIO Ratio of summer precipitatioin to total precipitation, GSP/MAP</li>
					\t\t\t\t</ul>
				</div>
				");
			} //end if
		} //end while
		closedir($handle);
	} //end if
} //end function


?>
