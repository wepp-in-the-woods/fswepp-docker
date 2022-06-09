<?php

$filename_expanded = array(
	"X4.sur" => "Average monthly maximum temperature degrees C",
	"t4.sur" => "Average monthly mean temperature degrees C",
	"m4.sur" => "Average monthly minimum temperature degrees C",
	"p6.sur" => "Total monthly precipation in mm",
	"d100.zip" => "Julian date the sum of degree-days &gt;5 degrees C reaches 100",
	"dd0.zip" => "Degree-days &lt;0 degrees C (based on mean monthly temperature)",
	"dd5.zip" => "Degree-days &gt;5 degrees C (based on mean monthly temperature)",
	"fday.zip" => "Julian date of the first freezing date of autumn",
	"ffp.zip" => "Length of the frost-free period (days)",
	"gsdd5.zip" => "Degree-days &gt;5 degrees C accumulating within the frost-free period",
	"gsp.zip" => "Growing season precipitation, April to September",
	"map.zip" => "Mean annual precipitation",
	"mat_tenths.zip" => "Mean annual temperature",
	"mmax_tenths.zip" => "Mean maximum temperature in the warmest month",
	"mmindd0.zip" => "Degree-days &lt;0 degrees C (based on mean minimum monthly temperature)",
	"mmin_tenths.zip" => "Mean minimum temperature in the coldest month",
	"mtcm_tenths.zip" => "Mean temperature in the coldest month",
	"mtwm_tenths.zip" => "Mean temperature in the warmest month",
	"sday.zip" => "Julian date of the last freezing date of spring",
  "smrpb" => "Summer precipitation balance: (jul+aug+sep)/(apr+may+jun)",
  "smrsprpb" => "Summer/Spring precipitation balance: (jul+aug)/(apr+may)",
  "smrp" => "Summer precipitation: (jul+aug)",
  "sprp" => "Spring precipitation: (apr+may)",
  "winp" => "Winter precipitation: (nov+dec+jan+feb)",
	"MMONTH.dat" => "Minimum temperatures, degrees C",
	"TMONTH.dat" => "Average temperatures, degrees C",
	"XMONTH.dat" => "Maximum temperatures, degrees C",
	"PMONTH.dat" => "Total precipitation, mm"
);
	global $filename_expanded;

$derived_gridname_expanded = array(
	"d100" => "Julian date the sum of degree-days &gt;5 degrees C reaches 100",
	"dd0" => "Degree-days &lt;0 degrees C (based on mean monthly temperature)",
	"dd5" => "Degree-days &gt;5 degrees C (based on mean monthly temperature)",
	"fday" => "Julian date of the first freezing date of autumn",
	"ffp" => "Length of the frost-free period (days)",
	"gsdd5" => "Degree-days &gt;5 degrees C accumulating within the frost-free period",
	"gsp" => "Growing season precipitation, April to September",
	"map" => "Mean annual precipitation",
	"mat_tenths" => "Mean annual temperature",
	"mmax_tenths" => "Mean maximum temperature in the warmest month",
	"mmindd0" => "Degree-days &lt;0 degrees C (based on mean minimum monthly temperature)",
	"mmin_tenths" => "Mean minimum temperature in the coldest month",
	"mtcm_tenths" => "Mean temperature in the coldest month",
	"mtwm_tenths" => "Mean temperature in the warmest month",
	"sday" => "Julian date of the last freezing date of spring",
  "smrpb" => "Summer precipitation balance: (jul+aug+sep)/(apr+may+jun)",
  "smrsprpb" => "Summer/Spring precipitation balance: (jul+aug)/(apr+may)",
  "sprp" => "Spring precipitation: (apr+may)",
  "smrp" => "Summer precipitation: (jul+aug)",
  "winp" => "Winter precipitation: (nov+dec+jan+feb)"
);
	global $derived_gridname_expanded;

$directory_expanded = array(
	"Mexico" => "Mexico",
	"westNA" => "Western North America",
	"westUS" => "Western United States",
	"allNA" => "All North America",
	"ANUCoeffs" => "ANUSPLIN Coefficients",
	"derivedGrids" => "Derived Grids",
	"stationNormals" => "Station Normals",
	"samplePoints" => "Sample Points",
	"mapImages" => "Map Images"
);
	global $directory_expanded;

$spatial_extent_abbr_expanded = array(
	"Mex" => "Mexico",
	"wNA" => "Western North America",
	"wUS" => "Western United States",
	"aNA" => "All North America"
);
	global $spatial_extent_abbr_expanded;
	
?>
