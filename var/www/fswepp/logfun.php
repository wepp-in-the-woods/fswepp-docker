<?php

/*
* FUNCTION: currentLogDir()
* UPDATED: 12/23/2021
* DESCRIPTION: Requests server time (specifically, the year) and returns the current year directory
*              If file directory does not exist (new year), directory is created. 
* USED IN: index.php
*/ 


function currentLogDir() {
	date_default_timezone_set('America/Los_Angeles'); // PT
	
	//$curr_year_dir = '_2021';
	

	$info = getdate();
	$year = $info['year'];
	
	$curr_year_dir = "_" . $year;
	
	if (!file_exists(curr_year_dir)) {
		mkdir('/var/www/cgi-bin/fswepp/working/' . $curr_year_dir, 0777, true);
		mkdir('/var/www/cgi-bin/fswepp/working/' . $curr_year_dir . '/wr', 0777, true);
		mkdir('/var/www/cgi-bin/fswepp/working/' . $curr_year_dir . '/ww', 0777, true);
		mkdir('/var/www/cgi-bin/fswepp/working/' . $curr_year_dir . '/wt', 0777, true);
		mkdir('/var/www/cgi-bin/fswepp/working/' . $curr_year_dir . '/wrb', 0777, true);
		mkdir('/var/www/cgi-bin/fswepp/working/' . $curr_year_dir . '/wf', 0777, true);
		mkdir('/var/www/cgi-bin/fswepp/working/' . $curr_year_dir . '/we', 0777, true);
		mkdir('/var/www/cgi-bin/fswepp/working/' . $curr_year_dir . '/wd2', 0777, true);
		mkdir('/var/www/cgi-bin/fswepp/working/' . $curr_year_dir . '/wb', 0777, true);
		mkdir('/var/www/cgi-bin/fswepp/working/' . $curr_year_dir . '/wa', 0777, true);
	}
	
	
	return $curr_year_dir;
}
?>
