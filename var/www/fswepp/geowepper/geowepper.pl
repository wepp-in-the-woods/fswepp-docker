#! perl

# Prototype script to harvest hillslope information from GeoWEPP
# April 2005 -- David Hall and Paul Swetik
# USDA Forest Service Rocky Mountain Research Station
# forest.msocowfsl.wsu.edu/fswepp/

$version = '2005.04.21';

sub describe {
    print "=================
GeoWEPPer v. $version

 A quick utility to display hillslope information following
 a 1-year GeoWEPP watershed run --in order to use the
 topography for modeling in WEPP FuME.

 The user selects a GeoWEPP project, and then a watershed
 within that project.
 GeoWEPPer then lists all of the hillslopes that were generated
 by GeoWEPP for that watershed.
 For each hillslope is listed
    GeoWEPP hillslope number (as displayed upon hovering
         over the hillslope in the GeoWEPP program),
    hillslope length (ft) from GeoWEPP file*
    top gradient (%) (GeoWEPP's first gradient)
    middle gradient (%) (average of GeoWEPP's central gradients)
    toe gradient (%) (GeoWEPP's final gradient)
    hillslope area (ac) calculated
  * -- units converted from GeoWEPP's meters to feet

 The user may select hillslopes of interest using the
 GeoWEPP hover feature, and enter the appropriate
 hillslope length and the three gradients into WEPP FuME
 to perform further analysis.

 The hillslope contributing area is presented because some GeoWEPP
 hillslopes are quite long, and these long slopes are not realistic
 at the scale of modeling at which WEPP FuME runs.  For hillslopes
 longer than about 1,000 ft, it is advisable to specify a
 shorter length in WEPP FuME and then adjust the results
 (in tons per acre) for the number of contributing acres.
 ===
 USDA Forest Service
 Rocky Mountain Research Station
 Moscow Forestry Sciences Laboratory
 Soil & Water Engineering Project
 forest.moscowfsl.wsu.edu
";
}

system ("color F0");		# set screen black on white

print "\n Display project SLOPE files from GEOWEPP\n\n";

#	$zp is full path of current slope file being tested

# Read GeoWEPP directory to fing project directories (and other stuff)
# '-T' returns 'only text files' (p. 203 Programming Perl 2/e)
# so '!-T' gives non-text files

    $geoweppdir = 'c:/geowepp';

    opendir GEOWEPPDIR, $geoweppdir;
      @allgfiles=grep {!-T} readdir GEOWEPPDIR;
    close GEOWEPPDIR;

#  put directories in numbered list
#  ask user for number (user can enter number, or number and project name)

#   print "@allgfiles\n";

# don't print '.','..'
# don't print known non-project directories ('GISascii'...)

while () {

  print "\n";
  print "?: help screen\n";
  for $i (0..$#allgfiles) {
    $z = @allgfiles[$i];
    $zp = $geoweppdir . '/' . $z;
    goto skip if ($z eq '.');
    goto skip if ($z eq '..');
    goto skip if ($z eq 'GISascii');
    goto skip if ($z eq 'GISasciiARS');
    goto skip if ($z eq 'GISasciiFS');
    goto skip if ($z eq 'GISasciinNRCS');
    goto skip if ($z eq 'info');
    goto skip if ($z eq 'NRCSzip');
    if (-d $zp) {
      print "$i: $z\n";
    }
    skip:
  }
  print "\nWhich Project? ";
  $which = <STDIN>;
  chomp $which;
  last if ($which eq ''); #quit if null, help if ? entered
  if ($which eq '?') {
    &describe;
    print "(press 'Enter' to quit) ";
    $x = <STDIN>;
    last;
  }

  $which += 0;		# convert string to number
  die if ($which < 0 || $which > $#allgfiles);

# read project directory

    $projectdir = $geoweppdir . '/' . @allgfiles[$which];

    opendir PROJECTDIR, $projectdir;
      @allpfiles=readdir PROJECTDIR;
    close PROJECTDIR;

  print "\nGeoWEPP project '@allgfiles[$which]'\n";



#  print table headers:
print"\n
slope\t hill\t    top\t   middle   toe\t     area 
no.  \t length\t    grad   grad\t    grad
     \t (ft) \t    (%)\t   (%) \t    (%)\t     (ac)
================================================================================
	";


  for $i (0..$#allpfiles) {
    $z = @allpfiles[$i];
    if (substr($z,0,4) eq 'hill' && substr($z,-4) eq '.slp') {
      $zp = $projectdir . '/' . $z;
#      print "$zp\n";
	# pull slope number out of filename string (p 70 Wall, Christiansen, Schwartz)
	$_ = $z;
	if (/hill_ *([0-9]+)/) {$slopenum = $1};
#
#  open file

# 2/3/05 pgs/deh
	open SLOPENUM, $zp;
		

		$line = <SLOPENUM>; #skip first line (wepp version)
		$line = <SLOPENUM>; #skip 2nd line (# of OFE's)
		$line = <SLOPENUM>; #read 3rd line (aspect, width)

# 4/14/05 mods for width
		@fields = split (" ", $line); # parse line
		$width = @fields[1] * 3.28; #convert width from m to ft


		$line = <SLOPENUM>; #read 4th line (# of slope pairs, slope length)
		@fields = split (" ", $line); # parse line
		$hlen = @fields[1] * 3.28;	#convert slope length from m to ft
		$pairs= @fields[0];

		$area = $hlen * $width;
#               $area = commify($area);

		$line = <SLOPENUM>; #read 5th line (pairs of distance & gradient)
				    #each pair separated by white space, dist & grad sep by comma
				    # 2/3/05 change all commas to spaces
		$line =~ s/,/ /g;
		@fields = split (" ", $line); # parse line into: dx grad dx grad dx grad ...
		#print @fields, "\n";
		#print "\n all fields ", @fields , "\n";
		#print "\n number of fields in data line 5: ", $#fields,"\n";

	
		# initialize distance and gradient arrays
		@grad='';
		@dx='';
		#loop thru the fields, assign to appropriate dx or grad array
		$k=0;
    		for $j (0..$#fields/2) {
     			@dx[$j]=@fields[$k];
      			@grad[$j]=@fields[$k+1];
      			$k=$k+2;
    		}
# use tabs instead of comma for generalized output delimiter (output_field_separator p. 132)
$, = "\t";
#  print "  Distances: ", @dx,"\n";
#  print "  Gradients: ", @grad,"\n";
 
#  print "\n number of gradient fields ", $#grad,"\n";

  $sum=0;
  $points=0;
  if ($#grad < 1)  {$average = 'n/a'}
  if ($#grad == 1) {$average = @grad[0]}
  if ($#grad > 1) {
        $average = 'n/a';
		# calc average excluding first and last points
    foreach $i (1..$#grad-1) {
      #print @grad[$i],"\n";
      $sum += @grad[$i];
      $points++;
    }
    if ($points > 0) {$average = $sum/$points}
  }

# print file name, length, top, middle, toe slopes
# slopes are internally calculated using decimal percent at the point
# slopes are output as whole percent (x*100)




# print "\n\t    $z $hlen\t@grad[0]\t$average\t@grad[$#grad]";
  printf("\n %2s\t%6.0f \t %5.0f \t %5.0f \t %5.0f     %5.1f \t \n", 
	    $slopenum, $hlen,@grad[0]*100,$average*100,@grad[$#grad]*100,$area);




#  print "\n\n
#  sum:     $sum
#  points:  $points
#  average: $average
#  \n";
			
	close SLOPENUM;
	
    }
  }

  print "\n(press 'Enter' to continue) ";
  $x = <STDIN>;

}	# while ()

# ============= sample slope file generated by GeoWEPP ====================

# 97.3				     <-- WEPP version
# 1				     <-- no. OFEs
# 255 996.395973		     <-- aspect, width in m
# 2 32.517193			     <-- no. points on slope, length in m
# 0.000000, 0.128472  1.0, 0.388378  <-- dist. down slope, slope steep (m/m)

# ============ end sample slope file generated by GeoWEPP ==================

sub commify {
  my $text = reverse $_;
  $text =~ s/(\d\d\d)(?=\d)(?!d*\.)/$1,/g;
  return scalar reverse $text;
}

# $version	GeoWEPPer version number
# $z		file name
# $zp		file name with path (/geowepp/ or /geowepp/project/)
# $which	user selection
# $i		index in loop through geowepp directory entries or project entries
# @fields	vector of fields in GeoWEPP hillslope file line
# $slopenum
# $hlen		hillslope length
# $width
# $area
# @grad		vector of gradients from GeoWEPP slope file
# $average	average gradient
# $sum		sum of gradients
# $points	number of distance points
# $x		dummy input (wait for 'enter')
# $line		line from GeoWEPP slope file
# $j		index loop through distance/slope fields
# $k		secondary index loop through distance/slope fields
# $dx		distance down slope (from GeoWEPP slope file)
# $pairs	number of distance/slope pairs
# @allgfiles	directory entries in GeoWEPP directory
# @allpfiles	directory entries in selected GeoWEPP project directory
# $projectdir	selected GeoWEPP project directory path
# $geoweppdir	GeoWEPP directory path
