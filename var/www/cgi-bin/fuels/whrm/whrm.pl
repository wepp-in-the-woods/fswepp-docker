#!/usr/bin/perl
#use strict;
use CGI ':standard';

##########################################
# code name: whrm                        #
##########################################

$debug=0;
$hdebug=0;

## BEGIN HISTORY ####################################################
# WHRM Wildlife Habitat Response Model Version History

# $version='2006.04.12';	# DEH return partial Literature page on no file found; report data file name (badfile)
  $version='2005.08.26';	# EV Add onsubmit="return checkform()" to form call line 372
# $version='2005.08.25';	# EV
# $version='??';		# DEH changed data directory from 'species' to 'data' [Linux only]
# $version='2005.03.23';	# More changes from Elena -- javascript functions<br>Format Summaries of specific studies
# $version='2005.03.22';	# Big changes (from Elena) including new data files
# $version='2005.02.08';	# Make self-creating history popup page
# $version = '2005.02.07';	# Fix argument to tail_html, add argument for head_html
#!$version = '2005.02.07';	# Place <form> in correct location
# $version = '2005.02.04';	# Clean up HTML formatting, add head_html and tail_html functions;
# $version = '2005.02.04';	# Display common and scientific names as common (scientific) with italics

## END HISTORY ######################################################

print "Content-type: text/html\n\n";
my @names;
my @values;

######
  if ($hdebug) {
    foreach my $name (param () ) {
      my @values= param ($name);
      print "<p><b>Key:</b>$name <b>
      Value(s) :</b>@values";
     }
  }

########################################
## HTML output of all the input        #
########################################

$tax_group=param('tax_group');
	$tax_group = 'Forest Carnivores' if ($tax_group eq '');
$taxgroup=lc($tax_group);
$taxgroup=~s/ //g;

######################################
## Check for new birds submenu       #
######################################

if(($taxgroup=~/allbirds/)||($taxgroup=~/canopynestingbirds/)||($taxgroup=~/cavitynestingbirds/)||($taxgroup=~/groundnestingbirds/)||($taxgroup=~/shrubnestingbirds/)){
$taxgroup="birds";
###print"<p>taxgroup is $taxgroup";
}


######################################

$species=param('species');
	$species = 'Wolverine / Gulo gulo' if ($species eq '');
$action=param('Model');
	$action = 'Display Habitat Associations' if ($action eq '');
###$location=param('location');
###$habitattype=param('habitat_type');
###$spatialscale=param('spatial_scale'); 
###$treatment=param('treatment'); 

###if($treatment==0){$ptreatment="Thin and Pile";}
###elsif($treatment==1){$ptreatment="Thin and Broadcast Burn(moderate burn conditions)";}
###elsif($treatment==2){$ptreatment="Thin and Broadcast Burn(severe burn conditions)";}
###elsif($treatment==3){$ptreatment="No Thin and Broadcast Burn(moderate burn conditions)";}
###else{$ptreatment="No Thin and Wildfire ";}

###$area=param('area'); 
###$temposcale=param('tempo_scale');

if($debug)
{
print"<p>tax_group is $tax_group";
print"<p>taxgroup is $taxgroup";
print"<p>species is $species";
print"<p>action is $action";
###print"<p>location is $location";
###print"<p>habitattype is $habitattype";
###print"<p>spatialscale is $spatialscale";
###print"<p>treatment is $treatment";
###print"<p>area is $area";
###print"<p>temposcale is $temposcale";
}

######################################
## Habitat Features Vector   
##################################

@habitatfeatures=('Bare Mineral Soil Exposure','Duff Cover', 'Grass Cover','Forb/Herbaceous Cover','Shrub Cover (size classes not specified)',
'Shrub Cover 0-18" height','Shrub Cover 18+" height','Litter Cover', 'Down Wood (size classes not specified)','Down Wood 0-3" ',
'Down Wood 4-6" ','Down Wood 7-12"', 'Down Wood >12"', 'Snags (size classes not specified)','Snags 0-4.9" dbh','Snags 5-9" dbh', 
'Snags 10-19" dbh', 'Snags 20-29" dbh', 'Snags 30+" dbh', 'Crown Base Height','Tree Canopy Cover', 
'Trees (all species, size classes not specified)','Trees (all species) 0-4.9" dbh', 'Trees (all species) 5-9" dbh',  
'Trees (all species) 10-19" dbh',  'Trees (all species) 20-29" dbh',  'Trees (all species) 30+" dbh',  
'PP Trees (size classes not specified)','PP Trees 0-4.9" dbh', 'PP Trees 5-9" dbh',  'PP Trees 10-19" dbh',  'PP Trees 20-29" dbh',  
'PP Trees 30+" dbh',  'DF Trees (size classes not specified)','DF Trees 0-4.9" dbh', 'DF Trees 5-9" dbh',  'DF Trees 10-19" dbh',  
'DF Trees 20-29" dbh',  'DF Trees 30+" dbh',  'LP Trees (size classes not specified)','LP Trees 0-4.9" dbh', 'LP Trees 5-9" dbh',  
'LP Trees 10-19" dbh',  'LP Trees 20-29" dbh',  'LP Trees 30+" dbh',  'Aspen Trees (size classes not specified)','Aspen Trees 0-4.9" dbh', 
'Aspen Trees 5-9" dbh',  'Aspen Trees 10-19" dbh',  'Aspen Trees 20+" dbh',  'Other Trees (size classes not specified)',
'Other Trees 0-4.9" dbh', 'Other Trees 5-9" dbh',  'Other Trees 10-19" dbh',  'Other Trees 20-29" dbh',  'Other Trees 30+" dbh'
);

##############################
# extraction of the file name
###############################
@name1=split/\//,lc($species);
@name2=split/ /,$name1[0];
$filename=join("",@name2);
$filename=~s/'//g;
$filename=~s/-//g;

if($debug){print"<p>filename is: $filename";}

###################################
##writing files with information
################################

#$workingpath = "c:\\Inetpub\\Scripts\\fuels\\whrm\\";
#open (work_file, ">".$workingpath ."working.txt")|| Error('open','file');
#print work_file "#this files is generated by wildlifem.pl
#taxgroup\n$taxgroup
#species\n$species
#filename\n$filename
#";
#close (work_file);
#########################################
## uploading all information about the species
############################

$spefilename = $filename .".txt";
$spepath = "c:\\Inetpub\\Scripts\\fuels\\whrm\\test\\species\\".$taxgroup."\\";
# $spepath = "species/".$taxgroup."/";	# 2005.02.01 DEH
$spepath = "data/".$taxgroup."/";	# 2005.02.01 DEH
($comname,$sciname) = split '/', $species;
$sciname = substr($sciname,1);		# 2005.02.07 DEH get rid of first blank for printout

if($debug)
{
print "<p>spefilename is $spefilename";
print "<p>spepath is $spepath";
}

##################starting extraction of habitat features
if($action=~/Display/)
{
#####start if for rank 
####read rank

open (rank_file, $spepath .$spefilename)|| die("Error: files unopened!\n");
while(<rank_file>)
{if($_=~/Rank/)
####	{$rank=<rank_file>} Elena 03/18/2005
	{@rankm=split(/,/,<rank_file>)}
}
close (rank_file);
$rank=$rankm[0]; ##Elena 03/18/2005

if($debug)
{
print "<p>the rank in the file is: $rank and @rankm\n";
####print "<p>the rank in the file is: $rank\n"; Elena 03/18/2005
}

###########rank equal 1

  if ($rank==1) {

    head_html('Wildlife Habitat Response Model habitat associations');

    print <<"endrank1";
       <h3>        <b>Habitat Associations for<br>         $comname (<i>$sciname</i>)</b> </h3>
      <br>
      <b>
       <font color=red>Sorry!</font>
       Available data are insufficient to run the model on your selected species at this time.
       You may try selecting a different species with similar life history characteristics.
       To view general life history information for your selected species,
       please use the "View Background Information" button.
      </b>
      <br>
      <center>
       <!-- form method="post" name="wildlifem2" action="https://localhost/Scripts/fuels/whrm/test/whrm2.pl" -->
       <form method="post" name="wildlifem2" action="/cgi-bin/fuels/whrm/whrm2.pl">
        <input type="hidden" value="$taxgroup" name="taxgroup">
        <input type="hidden" value="$species" name="species">
        <input type="hidden" value="$filename" name="filename">
        <input type="submit" value="View Background Information"  NAME="literature">
       </form>
       <br><br>
       <hr>
endrank1

    tail_html('rank 1');

  }
  else {

    open (spe_file, $spepath .$spefilename)|| Error('open','file');;
    while(<spe_file>) {
	if($_=~/Literature/){close (spe_file);}
	if($_=~/Nestsite/)
	{$_=<spe_file>;
	@row=split(/:/,$_);
	$nestrow=(@row);
		for($i=0; $i<=(@row-1);$i++)
		{($nestfeacode[$i],$nestdir[$i])=split(/,/,$row[$i],2);
		  if($nestfeacode[$i]==-99){chomp($nestfeacode[$i])}
		 if($debug){print"<p>nestcode is $nestfeacode[$i] and nestdir is $nestdir[$i] ";}}
	}
	if($_=~/Foraging Habitat/)
	{$_=<spe_file>;
	@row=split(/:/,$_);
	$fhabirow=(@row);
		for($i=0; $i<=(@row-1);$i++)
		{($fhabifeacode[$i],$fhabidir[$i])=split(/,/,$row[$i],2);
		  if($fhabifeacode[$i]==-99){chomp($fhabifeacode[$i])}
		 if($debug){print"<p>fhabicode is $fhabifeacode[$i] and fhabidir is $fhabidir[$i] ";}}
	}
	if($_=~/Forage\/Prey Availability/)
	{$_=<spe_file>;
	@row=split(/:/,$_);
	$preavarow=(@row);
		for($i=0; $i<=(@row-1);$i++)
		{($preavafeacode[$i],$preavadir[$i])=split(/,/,$row[$i],2);
		  if($preavafeacode[$i]==-99){chomp($preavafeacode[$i])}
		 if($debug){print"<p>preavacode is $preavafeacode[$i] and preavadir is $preavadir[$i] ";}}
	}
	if($_=~/Predator Avoidance/)
	{$_=<spe_file>;
	@row=split(/:/,$_);
	$avoprerow=(@row);
		for($i=0; $i<=(@row-1);$i++)
		{($avoprefeacode[$i],$avopredir[$i])=split(/,/,$row[$i],2);
		  if($avoprefeacode[$i]==-99){chomp($avoprefeacode[$i])}
		 if($debug){print"<p>avoprecode is $avoprefeacode[$i] and avopredir is $avopredir[$i] ";}}
	}
	if($_=~/Refugia\/Shelter/)
	{$_=<spe_file>;
	@row=split(/:/,$_);
	$refsherow=(@row);
		for($i=0; $i<=(@row-1);$i++)
		{($refshefeacode[$i],$refshedir[$i])=split(/,/,$row[$i],2);
		  if($refshefeacode[$i]==-99){chomp($refshefeacode[$i])}
		 if($debug){print"<p>refshecode is $refshefeacode[$i] and refshedir is $refshedir[$i] ";}}
	}
  }

  close (spe_file);
  if ($debug) {
    print "<p>nestrow is :$nestrow";
    print "<p>fhabirow is :$fhabirow";
    print "<p>preavarow is :$preavarow";
    print "<p>avoprerow is :$avoprerow";
    print "<p>refsherow is :$refsherow";
   }
########################################################
###testing for features not being used Elena 03/18/2005
########################################################

@nestfeacode=featurecheck(@nestfeacode);
@fhabifeacode=featurecheck(@fhabifeacode);
@preavafeacode=featurecheck(@preavafeacode);
@avoprefeacode=featurecheck(@avoprefeacode);
@refshefeacode=featurecheck(@refshefeacode);

########################################################
###finish features not being used
########################################################

########################################################
###Creating cover category by fusing two categories Elena 03/18/2005
########################################################
$counter=0;

if(($avoprefeacode[0]==-99)&&($refshefeacode[0]==-99)){$coverfeacode[0]=-99;}
elsif(($avoprefeacode[0]==-99)&&($refshefeacode[0]!=-99)){@coverfeacode=@refshefeacode;@coverdir=@refshedir;}
elsif(($avoprefeacode[0]!=-99)&&($refshefeacode[0]==-99)){@coverfeacode=@avoprefeacode;@coverdir=@avoperdir;}
else
{
	@tempcover=(@avoprefeacode,@refshefeacode);
	@tempcoverdir=(@avopredir,@refshedir);
	$tempsize=(@avoprefeacode)+(@refshefeacode);
	$sizec=(@avoprefeacode);
	for($i=0; $i<=$tempsize-1;$i++)
	{$indexflag[$i]=0;
		if($i<=$sizec-1){$indexflag[$i]=0;}
		else
		{for($j=0; $j<=$sizec-1;$j++)
			{
			if($tempcover[$i]==$avoprefeacode[$j]){$indexflag[$i]=$i;$counter=$counter+1}
			}
		}	
	}
	if($debug)
	{
	print "<br>counter is $counter";
	print "<br>indexflag @indexflag";
	print "<br>this is the two matrix together:@tempcover<br>";
	print "<br> the size of the two matrix is: $tempsize<br>";
	print "<br>size is:$sizec";
	}
	for($i=0; $i<=$tempsize-1;$i++)
	{
		if($i<=$sizec-1){$coverfeacode[$i]=$tempcover[$i];$coverdir[$i]=$tempcoverdir[$i];}
		else
		{for($j=0; $j<=$sizec-1;$j++)
			{
			if($tempcover[$i]==$avoprefeacode[$j]){$equalflag=1;}
			}
			if(!$equalflag){push(@coverfeacode,$tempcover[$i]);push(@coverdir,$tempcoverdir[$i])}
			#else{$coverfeacode[$i]=-999;}
		}
		$equalflag=0;
	}
}

if($debug)
{
print "<br>the coverfeacode matrix is: @coverfeacode<br>";
	for($k=0; $k<(@coverfeacode);$k++){
	print "<br>coverfeacode[$k] is : $coverfeacode[$k]";
	}
print "<br>the coverdir matrix is: @coverdir<br>";
print "<br>the nestfeacode matrix is: @nestfeacode<br>";
print "<br>the nestrow is $nestrow<br>";
print "<br>the fhabifeacode matrix is: @fhabifeacode<br>";
}
########################################################
###########end of creating cover category
########################################################

  $rr1=$nestrow;
  $rr2=$fhabirow+$preavarow;
  $rr3=$avoprerow;
  $rr4=$refsherow;
$coverrow=(@coverfeacode); ##Elena 03/18/2005
if($debug){print "<br> the size of cover matrix is $coverrow";}
##############################################

  head_html('Wildlife Habitat Response Model habitat associations');

   print "
       <h3><b>Habitat Associations for<br>$comname (<i>$sciname</i>)</b> </h3>
";
	if ($rank==2)	{
	print "
     <br>
     <b>
      <font color=red>Warning:</font>
      There are limited data available for this species at this time.
      If you proceed, please interpret output conservatively.
      You may also want to try selecting a different species with similar life history characteristics.
     </b>
     <br>
";
   }		# if ($rank==2)

##################
##form 2    ######
#####begining of form two
   print <<"fin";
       Select the change in each habitat element based on expected results of the planned fuel treatment.<br>
       <br>
       <!-- form method="post" name="wildlifem2" action="https://localhost/Scripts/fuels/whrm/test/whrm2.pl" onsubmit="return checkform()" -->
       <form method="post" name="wildlifem2" action="/cgi-bin/fuels/whrm/whrm2.pl" onsubmit="return checkform()">
     <table align="center" border="2" ID="Table1">
      <caption>
       <b>
        <font size="4"></font>
       </b>
      </caption>
      <tr>
       <th colspan="2" rowspan="2" bgcolor="#006009">
        <font color="#99ff00">Life History Requirements</font>
      <br>
        <a href="javascript:explain_lifehistrequi()"
           onMouseOver="window.status='Explain Life History Requirements (new window)';return true"
           onMouseOut="window.status='Wildlife Habitat Response Model'; return true">
         <img src="/fuels/whrm/images/quest2.gif" width="18" height="16" border="0"></a>
       </th>
       <th rowspan="2" bgcolor="#006009">
        <font color="#99ff00">Key Wildlife Habitat Elements</font>
      <br>
        <a href="javascript:explain_keyhabele()"
           onMouseOver="window.status='Explain Key Wildlife Habitat Elements (new window)';return true"
           onMouseOut="window.status='Wildlife Habitat Response Model'; return true">
         <img src="/fuels/whrm/images/quest2.gif" width="18" height="16" border="0"></a>
       </th>
       <th colspan="7" bgcolor="#006009">
        <font color="#99ff00">Change in Habitat Elements</font>
       </th>
      </tr>
      <tr>
       <th bgcolor="#006009"><font color="#99ff00" size="2">Greater than<br>70% Decrease</font></th>
       <th bgcolor="#006009"><font color="#99ff00" size="2">41-70%<br>Decrease</font></th>
       <th bgcolor="#006009"><font color="#99ff00" size="2">11-40%<br>Decrease</font></th>
       <th bgcolor="#006009"><font color="#99ff00" size="2">No Change<br>(+/-10%)</font></th>
       <th bgcolor="#006009"><font color="#99ff00" size="2">11-40%<br>Increase</font></th>
       <th bgcolor="#006009"><font color="#99ff00" size="2">41-70%<br>Increase</font></th>
       <th bgcolor="#006009"><font color="#99ff00" size="2">Greater than<br>70% Increase</font></th>
      </tr>
      <tr>
       <th rowspan=$nestrow BGCOLOR="#006009"><font color="#99ff00">Reproduction</Font></th>
       <th rowspan=$nestrow BGCOLOR="#006009"><font color="#99ff00">Nest Sites,<br>Birthing Areas,<br>Breeding Sites</font>
      <br>
        <a href="javascript:explain_nestsite()"
           onMouseOver="window.status='Explain Nest Sites, Birthing Areas, Breeding Sites (new window)';return true"
           onMouseOut="window.status='Wildlife Habitat Response Model'; return true">
         <img src="/fuels/whrm/images/quest2.gif" width="18" height="16" border="0"></a>
</th>
fin
   for ($i=0; $i<=$nestrow-1;$i++) {
    if ($i==0) {
      if ($nestfeacode[$i]==-99) {
        print "       <td colspan=8 align=center>No Information Is Available</td>
      </tr>
";
      }
      else {
        print "       <td>$habitatfeatures[$nestfeacode[0]]</td>
       <td align=center><INPUT type=radio VALUE='-3' NAME='nestfea0' onclick=nestcheck($i,$nestfeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='-2' NAME='nestfea0' onclick=nestcheck($i,$nestfeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='-1' NAME='nestfea0' onclick=nestcheck($i,$nestfeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='0' NAME='nestfea0' onclick=nestcheck($i,$nestfeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='1' NAME='nestfea0' onclick=nestcheck($i,$nestfeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='2' NAME='nestfea0' onclick=nestcheck($i,$nestfeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='3' NAME='nestfea0' onclick=nestcheck($i,$nestfeacode[$i])></td>
      </tr>
";
      }		# else of if ($nestfeacode[$i]==-99)
    }    	# if ($i==0)
    else {      # if ($i==0)
      print "      <tr>
       <td>$habitatfeatures[$nestfeacode[$i]]</td>
       <td align=center><INPUT type=radio VALUE='-3' NAME='nestfea$i' onclick=nestcheck($i,$nestfeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='-2' NAME='nestfea$i' onclick=nestcheck($i,$nestfeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='-1' NAME='nestfea$i' onclick=nestcheck($i,$nestfeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='0' NAME='nestfea$i' onclick=nestcheck($i,$nestfeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='1' NAME='nestfea$i' onclick=nestcheck($i,$nestfeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='2' NAME='nestfea$i' onclick=nestcheck($i,$nestfeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='3' NAME='nestfea$i' onclick=nestcheck($i,$nestfeacode[$i])></td>
      </tr>
";
    }		# else of if ($i==0)
  }		# if ($i==0)

print "      <tr>
       <th rowspan='$rr2' BGCOLOR='#006009'><font color='#99ff00'>Food Resources</font></th>
       <th rowspan='$fhabirow' BGCOLOR='#006009'><font color='#99ff00'>Foraging Habitat</font>";
print <<"todo";
      <br>
        <a href="javascript:explain_foraging()"
           onMouseOver="window.status='Explain Foraging Habitat (new window)';return true"
           onMouseOut="window.status='Wildlife Habitat Response Model'; return true">
         <img src="/fuels/whrm/images/quest2.gif" width="18" height="16" border="0"></a>
</th>
todo
  for ($i=0;$i<=$fhabirow-1;$i++) {
    if ($i==0) {
      if ($fhabifeacode[$i]==-99) {
        print "       <td colspan=8 align=center>No Information Is Available</td>
      </tr>
";
      }		# if ($fhabifeacode[$i]==-99)
      else {
        print "       <td>$habitatfeatures[$fhabifeacode[0]]</td>
       <td align=center><INPUT type=radio VALUE='-3' NAME='fhabifea0' onclick=fhabicheck($i,$fhabifeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='-2' NAME='fhabifea0' onclick=fhabicheck($i,$fhabifeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='-1' NAME='fhabifea0' onclick=fhabicheck($i,$fhabifeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='0' NAME='fhabifea0' onclick=fhabicheck($i,$fhabifeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='1' NAME='fhabifea0' onclick=fhabicheck($i,$fhabifeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='2' NAME='fhabifea0' onclick=fhabicheck($i,$fhabifeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='3' NAME='fhabifea0' onclick=fhabicheck($i,$fhabifeacode[$i])></td>
      </tr>
";
      }         # if ($fhabifeacode[$i]==-99)
    }		# if ($i==0)
    else { 
      print "      <tr>
       <td>$habitatfeatures[$fhabifeacode[$i]]</td>
       <td align=center><INPUT type=radio VALUE='-3' NAME='fhabifea$i' onclick=fhabicheck($i,$fhabifeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='-2' NAME='fhabifea$i' onclick=fhabicheck($i,$fhabifeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='-1' NAME='fhabifea$i' onclick=fhabicheck($i,$fhabifeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='0' NAME='fhabifea$i' onclick=fhabicheck($i,$fhabifeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='1' NAME='fhabifea$i' onclick=fhabicheck($i,$fhabifeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='2' NAME='fhabifea$i' onclick=fhabicheck($i,$fhabifeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='3' NAME='fhabifea$i' onclick=fhabicheck($i,$fhabifeacode[$i])></td>
      </tr>
";
    }		# else of if ($i==0)
  }		# for ($i=0;$i<=$fhabirow-1;$i++)
  print "      <tr>
       <th rowspan='$preavarow' BGCOLOR='#006009'><font color='#99ff00'>Forage,<br>Prey Habitat</font>";
print <<"todo1";
      <br>
        <a href="javascript:explain_prey()"
           onMouseOver="window.status='Explain Forage, Prey Habitat (new window)';return true"
           onMouseOut="window.status='Wildlife Habitat Response Model'; return true">
         <img src="/fuels/whrm/images/quest2.gif" width="18" height="16" border="0"></a>
</th>
todo1
  for ($i=0;$i<=$preavarow-1;$i++) {
    if ($i==0) {
      if ($preavafeacode[$i]==-99) {
        print "       <td colspan=8 align=center>No Information Is Available</td>
      </tr>
";
      }		# if ($preavafeacode[$i]==-99)
      else {
        print "       <td>$habitatfeatures[$preavafeacode[0]]</td>
       <td align=center><INPUT type=radio VALUE='-3' NAME='preavafea0' onclick=preavacheck($i,$preavafeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='-2' NAME='preavafea0' onclick=preavacheck($i,$preavafeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='-1' NAME='preavafea0' onclick=preavacheck($i,$preavafeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='0' NAME='preavafea0' onclick=preavacheck($i,$preavafeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='1' NAME='preavafea0' onclick=preavacheck($i,$preavafeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='2' NAME='preavafea0' onclick=preavacheck($i,$preavafeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='3' NAME='preavafea0' onclick=preavacheck($i,$preavafeacode[$i])></td>
      </tr>
";
      }		# else of if ($preavafeacode[$i]==-99)
    }	# if ($i==0)
    else {
      print "      <tr>
       <td>$habitatfeatures[$preavafeacode[$i]]</td>
       <td align=center><INPUT type=radio VALUE='-3' NAME='preavafea$i' onclick=preavacheck($i,$preavafeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='-2' NAME='preavafea$i' onclick=preavacheck($i,$preavafeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='-1' NAME='preavafea$i' onclick=preavacheck($i,$preavafeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='0' NAME='preavafea$i' onclick=preavacheck($i,$preavafeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='1' NAME='preavafea$i' onclick=preavacheck($i,$preavafeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='2' NAME='preavafea$i' onclick=preavacheck($i,$preavafeacode[$i])></td>
       <td align=center><INPUT type=radio VALUE='3' NAME='preavafea$i' onclick=preavacheck($i,$preavafeacode[$i])></td>
      </tr>
";
    }	# else of if ($i==0)
  }	# for ($i=0;$i<=$preavarow-1;$i++)
  print "      <tr>
       <th rowspan='$coverrow' BGCOLOR='#006009'><font color='#99ff00'>Cover</font></th>
       <th rowspan='$coverrow' BGCOLOR='#006009'><font color='#99ff00'>Shelter from Predators<br> and Environmental Extremes</font>";
print <<"todo2";
      <br>
        <a href="javascript:explain_shelter()"
           onMouseOver="window.status='Explain Shelter from Predators and Environmental Extremes (new window)';return true"
           onMouseOut="window.status='Wildlife Habitat Response Model'; return true">
         <img src="/fuels/whrm/images/quest2.gif" width="18" height="16" border="0"></a>
</th>
todo2
  for($i=0; $i<=$coverrow-1;$i++){
    if ($i==0) {
      if ($coverfeacode[$i]==-99) {
        print "       <td colspan=8 align=center>No Information Is Available</td>
      </tr>
";
      }		# if ($coverfeacode[$i]==-99)
      else {
        print "       <td>$habitatfeatures[$coverfeacode[0]]</td>
	<td align=center><INPUT type=radio  VALUE=-3 NAME=\"coverfea0\"  onclick=covercheck($i,$coverfeacode[$i])></td>
	<td align=center><INPUT type=radio  VALUE=-2 NAME=\"coverfea0\"  onclick=covercheck($i,$coverfeacode[$i])></td>
	<td align=center><INPUT type=radio  VALUE=-1 NAME=coverfea0 onclick=covercheck($i,$coverfeacode[$i])></td>
	<td align=center><INPUT type=radio VALUE=0 NAME=coverfea0 onclick=covercheck($i,$coverfeacode[$i])></td>
	<td align=center><INPUT type=radio  VALUE=1 NAME=coverfea0 onclick=covercheck($i,$coverfeacode[$i])></td>
	<td align=center><INPUT type=radio  VALUE=2 NAME=coverfea0 onclick=covercheck($i,$coverfeacode[$i])></td>
	<td align=center><INPUT type=radio  VALUE=3 NAME=\"coverfea0\"  onclick=covercheck($i,$coverfeacode[$i])></td>
	</tr>
";
    }	# else of if ($coverfeacode[$i]==-99)
  }	# if ($i==0)
  else {
    print "      <tr>
	<td>$habitatfeatures[$coverfeacode[$i]]</td>
	<td align=center><INPUT type=radio  VALUE=-3 NAME=\"coverfea$i\" onclick=covercheck($i,$coverfeacode[$i])></td>
	<td align=center><INPUT type=radio  VALUE=-2 NAME=\"coverfea$i\" onclick=covercheck($i,$coverfeacode[$i])></td>
	<td align=center><INPUT type=radio  VALUE=-1 NAME=\"coverfea$i\" onclick=covercheck($i,$coverfeacode[$i])></td>
	<td align=center><INPUT type=radio VALUE=0 NAME=\"coverfea$i\" onclick=covercheck($i,$coverfeacode[$i])></td>
	<td align=center><INPUT type=radio  VALUE=1 NAME=\"coverfea$i\" onclick=covercheck($i,$coverfeacode[$i])></td>
	<td align=center><INPUT type=radio  VALUE=2 NAME=\"coverfea$i\" onclick=covercheck($i,$coverfeacode[$i])></td>
	<td align=center><INPUT type=radio  VALUE=3 NAME=\"coverfea$i\" onclick=covercheck($i,$coverfeacode[$i])></td>
	</tr>
";
    }	# else of if ($i==0)
  }	# for ()

print <<"end1";
      </table>
      <br>
      <br>You may return to this page to examine a different fuel treatment alternative by using the back arrow or starting over.</p>
      <br>
      <!-- form method="post" name="wildlifem2" action="https://localhost/Scripts/fuels/whrm/test/whrm.pl" -->
      <form method="post" name="wildlifem2" action="/cgi-bin/fuels/whrm/whrm.pl">
       <input type="hidden" value="$taxgroup" name="taxgroup">
       <input type="hidden" value="$tax_group" name="tax_group">
       <input type="hidden" value="$species" name="species">
       <input type="hidden" value="$filename" name="filename">
       <input type="submit" value="Run Wildlife Habitat Response Model" NAME="matrix">
      </form>
     </center>
end1

  tail_html('rank >1');

#		<P>
#   <hr>
#    <table border=0>
#     <tr>
#      <td valign="top" bgcolor="lightgoldenrodyellow">
#       <font face="tahoma, arial, helvetica, sans serif" size=1>
#        The Wild Response Model: <b>WH</b><b>RM</b>
#       </font>
#      </td>
#      <td valign="top">
#       <a href="https://forest.moscowfsl.wsu.edu/fswepp/comments.html"><img src="/fswepp/images/epaemail.gif" align="right" border=0></a>
#      </td>
#     </tr>
#     <tr>
#      <td valign="top">
#       <font face="tahoma, arial, helvetica, sans serif" size=1>
#        Wildlife Habitat Response Model input interface v.
#        <a href="javascript:popuphistory()">$version</a>
#        (for review only) by
#        David Hall &amp; Elena Velasquez<br>
#	  Model Developed by: David Pilliod<br>
#        Team leader Elaine Kennedy Sutherland, USDA Forest Service, Rocky Mountain Research Station
#       </font>
#     </table>
#   </form>
# </body>
#</html>

### end of begining of form 2
    }			####end else for ranks
  }		####end if Display
  else {
    $temp_filename = $spepath .$spefilename;
#    open (LITFILE, $spepath .$spefilename)|| die("Error: files unopened!\n");	# zzyz
    open (LITFILE, $spepath .$spefilename);
      while (<LITFILE>) {
        if ($_=~/Literature/)	{@litreview=<LITFILE>;}
      }
    close (LITFILE);
    $test=int((@litreview-1)/2);
    if ($debug) {
      $sizelit=(@litreview);
      print "<p>literature $sizelit";
      print "<p>test is $test";
    }

     head_html('Wildlife Habitat Response Model species information');

###############################
#  SPECIES INFORMATION TABLE  #
###############################

     print "     <h3><b>Species Information for<br>$comname (<i>$sciname</i>)</b></h3>";
goto badfile if !(-e $temp_filename);
     print "
     <table align='center' border='2'>
";

     for ($i=0;$i<=12;$i++) {
       $temph=@litreview[(2*$i)]; chop $temph; chomp $temph;
       $tempb=@litreview[(2*$i+1)]; chop $tempb; chomp $tempb;
       print "      <tr>
       <th colspan='2' bgcolor='#006009'><font size=3 color='#99ff00'>$temph</font></th>
       <td>$tempb</td>
      </tr>
";
    }

###################################
#  SUMMARIES OF SPECIFIC STUDIES  #
###################################

    $temp=@litreview[26]; chop $temp; chomp $temp;
    print "
     </table>
     <br>
     <h3><b>$temp</b></h3>
     <br><br>
    </center>
";

    for ($i=27;$i<=(@litreview-1);$i++) {
      $temp=@litreview[$i]; chop $temp; chomp $temp;
      if ($temp=~/Study Location:/) {$temp="<blockquote>\n     <b>Study Location:</b>" . substr($temp,15) . '<br>'}
      if ($temp=~/Location of Study:/) {$temp="\n     <blockquote><b>Location of Study:</b>" . substr($temp,18) . '<br>'}
      if ($temp=~/Habitat Description:/) {$temp=' <b>Habitat Description:</b>' . substr($temp,20) . '<br>'}
      if ($temp=~/Summary:/) {$temp=' <b>Summary:</b>' . substr($temp,8) . "\n    </blockquote>"}
      print "    $temp\n";
#      print"$litreview[$i]<br>";
    }
badfile:
    taillit_html('Literature');

  }		# else if (display)

sub head_html {

  my $title = @_[0];
  if ($title eq '') {$title = 'Wildlife Habitat Response Model Output'}

print "<html>
 <head>
  <title>$title</title>
   <script language=\"javascript\">
    <!-- hide from old browsers...

";
  

  print "  var arnest=new Array();\n";
  for ($i=0;$i<$nestrow; $i++) {
    print "  arnest[$i]=",'"',$nestfeacode[$i]+0,'"',";\n";
	###print "alert(arnest[$i]);\n";
  }
  print "  var arfhabi=new Array();\n";
  for ($i=0;$i<$fhabirow; $i++) {
    print "  arfhabi[$i]=",'"',$fhabifeacode[$i]+0,'"',";\n";
  }
  print "  var arpreava=new Array();\n";
  for ($i=0;$i<$preavarow; $i++) {
#   $preavafeacode[$i]+=0;
    print "  arpreava[$i]=",'"',$preavafeacode[$i]+0,'"',";\n";
	###print "alert(arpreava[$i]);\n";
  }
  print "  var arcover=new Array();\n";
  for ($i=0;$i<$coverrow; $i++) {
    print "  arcover[$i]=",'"',$coverfeacode[$i]+0,'"',";\n";
	###print "alert(arcover[$i]);\n";
  }

  print<<"end11";

  function nestcheck( a,b ) {
    var aa=a;
    var bb=b;
     //alert("the value a is " + aa +" the value b is "+bb+" the value of length is"+arpreava.length);
    for (var i=0; i<=6; i++) {
      if (eval("document.forms.wildlifem2.nestfea"+aa+"[i].checked")) {
        for (var k=0; k<arfhabi.length; k++){
	  if(arfhabi[k]!=-99){
          var object=eval("document.forms.wildlifem2.fhabifea"+k+"[i]");
//	alert("I am here1 "+bb);
          if ((bb == arfhabi[k])&&(!object.checked)) {object.checked=true;}}
        }
        for (var k=0; k<arpreava.length; k++) {
	  if(arpreava[k]!=-99){
          var object=eval("document.forms.wildlifem2.preavafea"+k+"[i]");
//	alert("I am here2 "+ arpreava[k]);
          if ((bb == arpreava[k])&&(!object.checked)) {object.checked=true;}}
        }
        for (var k=0; k<arcover.length; k++) {
	  if(arcover[k]!=-99){
          var object=eval("document.forms.wildlifem2.coverfea"+k+"[i]");
          if ((bb == arcover[k])&&(!object.checked)) {object.checked=true;}}
        }
      }
    }
  }
  function fhabicheck( a,b ) {
    var cc=a;
    var dd=b;
	//alert("the value c is " + cc +"the value d is "+dd+"the value of length is"+arcover.length);
    for (var i=0; i<=6; i++) {
      if (eval("document.forms.wildlifem2.fhabifea"+cc+"[i].checked")) {
        for (var k=0; k<arnest.length; k++) {
	  if(arnest[k]!=-99){
          var object=eval("document.forms.wildlifem2.nestfea"+k+"[i]");
          if ((dd == arnest[k])&&(!object.checked)) {object.checked=true;}}
        }
        for (var k=0; k<arpreava.length; k++) {
	  if(arpreava[k]!=-99){
          var object=eval("document.forms.wildlifem2.preavafea"+k+"[i]");
          if ((dd == arpreava[k])&&(!object.checked)) {object.checked=true;}}
        }
        for (var k=0; k<arcover.length; k++) {
	  if(arcover[k]!=-99){
          var object=eval("document.forms.wildlifem2.coverfea"+k+"[i]");
          if ((dd == arcover[k])&&(!object.checked)) {object.checked=true;}}
        }
      }
    }
  }
  function preavacheck( a,b ) {
    var ee=a;
    var ff=b;
    for (var i=0; i<=6; i++) {
      if (eval("document.forms.wildlifem2.preavafea"+ee+"[i].checked")) {
        for (var k=0; k<arnest.length; k++) {
	  if(arnest[k]!=-99){
          var object=eval("document.forms.wildlifem2.nestfea"+k+"[i]");
          if ((ff == arnest[k])&&(!object.checked)) {object.checked=true;}}
        }
        for (var k=0; k<arfhabi.length; k++) {
	  if(arfhabi[k]!=-99){
          var object=eval("document.forms.wildlifem2.fhabifea"+k+"[i]");
          if ((ff == arfhabi[k])&&(!object.checked)) {object.checked=true;}}
        }
        for (var k=0; k<arcover.length; k++) {
	  if(arcover[k]!=-99){
          var object=eval("document.forms.wildlifem2.coverfea"+k+"[i]");
          if ((ff == arcover[k])&&(!object.checked)) {object.checked=true;}}
        }
      }
    }
  }
  function covercheck( a,b ) {
    var gg=a;
    var hh=b;
	//alert("the value g is " + gg +"the value h is "+hh+"the value of length is"+arcover.length);
    for (var i=0; i<=6; i++) {
      if (eval("document.forms.wildlifem2.coverfea"+gg+"[i].checked")) {
        for (var k=0; k<arnest.length; k++) {
	  if(arnest[k]!=-99){
          var object=eval("document.forms.wildlifem2.nestfea"+k+"[i]");
          if ((hh == arnest[k])&&(!object.checked)) {object.checked=true;}}
        }
        for (var k=0; k<arfhabi.length; k++) {
	  if(arfhabi[k]!=-99){
          var object=eval("document.forms.wildlifem2.fhabifea"+k+"[i]");
          if ((hh == arfhabi[k])&&(!object.checked)) {object.checked=true;}}
        }
        for (var k=0; k<arpreava.length; k++) {
	  if(arpreava[k]!=-99){
          var object=eval("document.forms.wildlifem2.preavafea"+k+"[i]");
          if ((hh == arpreava[k])&&(!object.checked)) {object.checked=true;}}
        }
      }
    }
  }

//////////////////////
function explain_lifehistrequi() {
    newin = window.open('','explanation','width=640,scrollbars=yes,resizable=1')
    var newWin = newin.document.open()
    if (newWin != null) {
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>The Wildlife Habitat Response Model</title>')
      newin.document.writeln('  <style>')
      newin.document.writeln('   BODY')
      newin.document.writeln('    {scrollbar-base-color:666666;scrollbar-face-color:#333333;scrollbar-highlight-color:#333333;scrollbar-shadow-color:6 66666;scrollbar-dark-shadow-color:ffffcc;scrollbar-arrow-color:ff6600}')
      newin.document.writeln('   .question {color:ffffcc}')
      newin.document.writeln('   .header {color:ffffcc}')
      newin.document.writeln('   .highlight {font-weight:bold}')
      newin.document.writeln('  </style>')
      newin.document.writeln(' </HEAD>')
      newin.document.writeln(' <body bgcolor="ivory" onLoad="top.window.focus()" link="#99ff00" vlink="#99ff00"  text="#006009">')
      newin.document.writeln('  <font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('   <table width=100%>')
      newin.document.writeln('    <tr><td bgcolor="#99ff00" align="center">')
      newin.document.writeln('     <font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('      <h3>Wildlife Habitat Response Model<br><br>Life History Requirements</h3><br>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td></tr>')
      newin.document.writeln('   </table>')
      newin.document.writeln('  <i>Life History Requirements</i> are aspects of an animal&#39s ecology that are required for survival and reproduction.')
      newin.document.writeln('<!--tool bar begins--><p>')
      newin.document.writeln('  <table bgcolor="#666666" width="20%" border="0" cellspacing="1" cellpadding="5"  align="center">')
      newin.document.writeln('   <tr>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      //newin.document.writeln(' onMouseOver="this.style.backgroundColor=\'#000000\';"')
      //newin.document.writeln(' onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln(' <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln(' <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a  href="javascript:self.print()">Print me</a>')
      newin.document.writeln(' </font>')
      newin.document.writeln('</td>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      //newin.document.writeln(' onMouseOver="this.style.backgroundColor=\'#000000\';"')
      //newin.document.writeln(' onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln(' <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln('  <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a  href="javascript:self.close()">Close me</a>')
      newin.document.writeln(' </font>')
      newin.document.writeln('</td>')
      newin.document.writeln('   </tr>')
      newin.document.writeln('  </table>')
      newin.document.writeln('<!--tool bar ends-->')
      newin.document.writeln('  </center>')
      newin.document.writeln(' </body>')
      newin.document.writeln('</html>')
      newin.document.close()
    } 
  }
function explain_keyhabele() {
    newin = window.open('','explanation','width=640,scrollbars=yes,resizable=1')
    var newWin = newin.document.open()
    if (newWin != null) {
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>The Wildlife Habitat Response Model</title>')
      newin.document.writeln('  <style>')
      newin.document.writeln('   BODY')
      newin.document.writeln('    {scrollbar-base-color:666666;scrollbar-face-color:#333333;scrollbar-highlight-color:#333333;scrollbar-shadow-color:6 66666;scrollbar-dark-shadow-color:ffffcc;scrollbar-arrow-color:ff6600}')
      newin.document.writeln('   .question {color:ffffcc}')
      newin.document.writeln('   .header {color:ffffcc}')
      newin.document.writeln('   .highlight {font-weight:bold}')
      newin.document.writeln('  </style>')
      newin.document.writeln(' </HEAD>')
      newin.document.writeln(' <body bgcolor="ivory" onLoad="top.window.focus()" link="#99ff00" vlink="#99ff00"  text="#006009">')
      newin.document.writeln('  <font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('   <table width=100%>')
      newin.document.writeln('    <tr><td bgcolor="#99ff00" align="center">')
      newin.document.writeln('     <font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('      <h3>Wildlife Habitat Response Model<br><br>Key Wildlife Habitat Elements</h3><br>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td></tr>')
      newin.document.writeln('   </table>')
      newin.document.writeln('  <i>Key Wildlife Habitat Elements</i> are structures or components of the environment that provide important habitat for animals.')
      newin.document.writeln('<!--tool bar begins--><p>')
      newin.document.writeln('  <table bgcolor="#666666" width="20%" border="0" cellspacing="1" cellpadding="5"  align="center">')
      newin.document.writeln('   <tr>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      //newin.document.writeln(' onMouseOver="this.style.backgroundColor=\'#000000\';"')
      //newin.document.writeln(' onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln(' <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln(' <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a  href="javascript:self.print()">Print me</a>')
      newin.document.writeln(' </font>')
      newin.document.writeln('</td>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      //newin.document.writeln(' onMouseOver="this.style.backgroundColor=\'#000000\';"')
      //newin.document.writeln(' onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln(' <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln('  <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a  href="javascript:self.close()">Close me</a>')
      newin.document.writeln(' </font>')
      newin.document.writeln('</td>')
      newin.document.writeln('   </tr>')
      newin.document.writeln('  </table>')
      newin.document.writeln('<!--tool bar ends-->')
      newin.document.writeln('  </center>')
      newin.document.writeln(' </body>')
      newin.document.writeln('</html>')
      newin.document.close()
    } 
  }
function explain_nestsite() {
    newin = window.open('','explanation','width=640,scrollbars=yes,resizable=1')
    var newWin = newin.document.open()
    if (newWin != null) {
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>The Wildlife Habitat Response Model</title>')
      newin.document.writeln('  <style>')
      newin.document.writeln('   BODY')
      newin.document.writeln('    {scrollbar-base-color:666666;scrollbar-face-color:#333333;scrollbar-highlight-color:#333333;scrollbar-shadow-color:6 66666;scrollbar-dark-shadow-color:ffffcc;scrollbar-arrow-color:ff6600}')
      newin.document.writeln('   .question {color:ffffcc}')
      newin.document.writeln('   .header {color:ffffcc}')
      newin.document.writeln('   .highlight {font-weight:bold}')
      newin.document.writeln('  </style>')
      newin.document.writeln(' </HEAD>')
      newin.document.writeln(' <body bgcolor="ivory" onLoad="top.window.focus()" link="#99ff00" vlink="#99ff00"  text="#006009">')
      newin.document.writeln('  <font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('   <table width=100%>')
      newin.document.writeln('    <tr><td bgcolor="#99ff00" align="center">')
      newin.document.writeln('     <font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('      <h3>Wildlife Habitat Response Model<br><br>Nestsites, Birthing Areas, Breeding Sites</h3><br>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td></tr>')
      newin.document.writeln('   </table>')
      newin.document.writeln('  <i>Nest Sites, Birthing Areas, Breeding Sites</i> are structures and components of the environment used by animals for breeding, birthing, and raising young.')
      newin.document.writeln('<!--tool bar begins--><p>')
      newin.document.writeln('  <table bgcolor="#666666" width="20%" border="0" cellspacing="1" cellpadding="5"  align="center">')
      newin.document.writeln('   <tr>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      //newin.document.writeln(' onMouseOver="this.style.backgroundColor=\'#000000\';"')
      //newin.document.writeln(' onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln(' <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln(' <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a  href="javascript:self.print()">Print me</a>')
      newin.document.writeln(' </font>')
      newin.document.writeln('</td>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      //newin.document.writeln(' onMouseOver="this.style.backgroundColor=\'#000000\';"')
      //newin.document.writeln(' onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln(' <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln('  <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a  href="javascript:self.close()">Close me</a>')
      newin.document.writeln(' </font>')
      newin.document.writeln('</td>')
      newin.document.writeln('   </tr>')
      newin.document.writeln('  </table>')
      newin.document.writeln('<!--tool bar ends-->')
      newin.document.writeln('  </center>')
      newin.document.writeln(' </body>')
      newin.document.writeln('</html>')
      newin.document.close()
    } 
  }
function explain_foraging() {
    newin = window.open('','explanation','width=640,scrollbars=yes,resizable=1')
    var newWin = newin.document.open()
    if (newWin != null) {
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>The Wildlife Habitat Response Model</title>')
      newin.document.writeln('  <style>')
      newin.document.writeln('   BODY')
      newin.document.writeln('    {scrollbar-base-color:666666;scrollbar-face-color:#333333;scrollbar-highlight-color:#333333;scrollbar-shadow-color:6 66666;scrollbar-dark-shadow-color:ffffcc;scrollbar-arrow-color:ff6600}')
      newin.document.writeln('   .question {color:ffffcc}')
      newin.document.writeln('   .header {color:ffffcc}')
      newin.document.writeln('   .highlight {font-weight:bold}')
      newin.document.writeln('  </style>')
      newin.document.writeln(' </HEAD>')
      newin.document.writeln(' <body bgcolor="ivory" onLoad="top.window.focus()" link="#99ff00" vlink="#99ff00"  text="#006009">')
      newin.document.writeln('  <font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('   <table width=100%>')
      newin.document.writeln('    <tr><td bgcolor="#99ff00" align="center">')
      newin.document.writeln('     <font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('      <h3>Wildlife Habitat Response Model<br><br>Foraging Habitat</h3><br>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td></tr>')
      newin.document.writeln('   </table>')
      newin.document.writeln('  <i>Foraging Habitat</i> is composed of (generally) non-consumable structures or components of the environment that provide preferred areas to feed.')
      newin.document.writeln('<!--tool bar begins--><p>')
      newin.document.writeln('  <table bgcolor="#666666" width="20%" border="0" cellspacing="1" cellpadding="5"  align="center">')
      newin.document.writeln('   <tr>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      //newin.document.writeln(' onMouseOver="this.style.backgroundColor=\'#000000\';"')
      //newin.document.writeln(' onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln(' <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln(' <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a  href="javascript:self.print()">Print me</a>')
      newin.document.writeln(' </font>')
      newin.document.writeln('</td>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      //newin.document.writeln(' onMouseOver="this.style.backgroundColor=\'#000000\';"')
      //newin.document.writeln(' onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln(' <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln('  <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a  href="javascript:self.close()">Close me</a>')
      newin.document.writeln(' </font>')
      newin.document.writeln('</td>')
      newin.document.writeln('   </tr>')
      newin.document.writeln('  </table>')
      newin.document.writeln('<!--tool bar ends-->')
      newin.document.writeln('  </center>')
      newin.document.writeln(' </body>')
      newin.document.writeln('</html>')
      newin.document.close()
    } 
  }
function explain_prey() {
    newin = window.open('','explanation','width=640,scrollbars=yes,resizable=1')
    var newWin = newin.document.open()
    if (newWin != null) {
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>The Wildlife Habitat Response Model</title>')
      newin.document.writeln('  <style>')
      newin.document.writeln('   BODY')
      newin.document.writeln('    {scrollbar-base-color:666666;scrollbar-face-color:#333333;scrollbar-highlight-color:#333333;scrollbar-shadow-color:6 66666;scrollbar-dark-shadow-color:ffffcc;scrollbar-arrow-color:ff6600}')
      newin.document.writeln('   .question {color:ffffcc}')
      newin.document.writeln('   .header {color:ffffcc}')
      newin.document.writeln('   .highlight {font-weight:bold}')
      newin.document.writeln('  </style>')
      newin.document.writeln(' </HEAD>')
      newin.document.writeln(' <body bgcolor="ivory" onLoad="top.window.focus()" link="#99ff00" vlink="#99ff00"  text="#006009">')
      newin.document.writeln('  <font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('   <table width=100%>')
      newin.document.writeln('    <tr><td bgcolor="#99ff00" align="center">')
      newin.document.writeln('     <font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('      <h3>Wildlife Habitat Response Model<br><br>Forage, Prey Habitat</h3><br>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td></tr>')
      newin.document.writeln('   </table>')
      newin.document.writeln('  <i>Forage, Prey Habitat</i> is composed of consumable structures in the environment or structures and components that are used by prey.')
      newin.document.writeln('<!--tool bar begins--><p>')
      newin.document.writeln('  <table bgcolor="#666666" width="20%" border="0" cellspacing="1" cellpadding="5"  align="center">')
      newin.document.writeln('   <tr>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      //newin.document.writeln(' onMouseOver="this.style.backgroundColor=\'#000000\';"')
      //newin.document.writeln(' onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln(' <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln(' <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a  href="javascript:self.print()">Print me</a>')
      newin.document.writeln(' </font>')
      newin.document.writeln('</td>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      //newin.document.writeln(' onMouseOver="this.style.backgroundColor=\'#000000\';"')
      //newin.document.writeln(' onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln(' <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln('  <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a  href="javascript:self.close()">Close me</a>')
      newin.document.writeln(' </font>')
      newin.document.writeln('</td>')
      newin.document.writeln('   </tr>')
      newin.document.writeln('  </table>')
      newin.document.writeln('<!--tool bar ends-->')
      newin.document.writeln('  </center>')
      newin.document.writeln(' </body>')
      newin.document.writeln('</html>')
      newin.document.close()
    } 
  }
function explain_shelter() {
    newin = window.open('','explanation','width=640,scrollbars=yes,resizable=1')
    var newWin = newin.document.open()
    if (newWin != null) {
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>The Wildlife Habitat Response Model</title>')
      newin.document.writeln('  <style>')
      newin.document.writeln('   BODY')
      newin.document.writeln('    {scrollbar-base-color:666666;scrollbar-face-color:#333333;scrollbar-highlight-color:#333333;scrollbar-shadow-color:6 66666;scrollbar-dark-shadow-color:ffffcc;scrollbar-arrow-color:ff6600}')
      newin.document.writeln('   .question {color:ffffcc}')
      newin.document.writeln('   .header {color:ffffcc}')
      newin.document.writeln('   .highlight {font-weight:bold}')
      newin.document.writeln('  </style>')
      newin.document.writeln(' </HEAD>')
      newin.document.writeln(' <body bgcolor="ivory" onLoad="top.window.focus()" link="#99ff00" vlink="#99ff00"  text="#006009">')
      newin.document.writeln('  <font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('   <table width=100%>')
      newin.document.writeln('    <tr><td bgcolor="#99ff00" align="center">')
      newin.document.writeln('     <font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('      <h3>Wildlife Habitat Response Model<br><br>Shelter from Predator and Environmental Extremes</h3><br>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td></tr>')
      newin.document.writeln('   </table>')
      newin.document.writeln('  <i>Shelter from Predator and Environmental Extremes</i> are structures and components of the environment that provide escape cover from predators and refugia from inclemental weather, particularly extremes in temperature.')
      newin.document.writeln('<!--tool bar begins--><p>')
      newin.document.writeln('  <table bgcolor="#666666" width="20%" border="0" cellspacing="1" cellpadding="5"  align="center">')
      newin.document.writeln('   <tr>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      //newin.document.writeln(' onMouseOver="this.style.backgroundColor=\'#000000\';"')
      //newin.document.writeln(' onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln(' <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln(' <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a  href="javascript:self.print()">Print me</a>')
      newin.document.writeln(' </font>')
      newin.document.writeln('</td>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      //newin.document.writeln(' onMouseOver="this.style.backgroundColor=\'#000000\';"')
      //newin.document.writeln(' onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln(' <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln('  <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a  href="javascript:self.close()">Close me</a>')
      newin.document.writeln(' </font>')
      newin.document.writeln('</td>')
      newin.document.writeln('   </tr>')
      newin.document.writeln('  </table>')
      newin.document.writeln('<!--tool bar ends-->')
      newin.document.writeln('  </center>')
      newin.document.writeln(' </body>')
      newin.document.writeln('</html>')
      newin.document.close()
    } 
  }

function checkform(){
var myform = document.forms[0];
var nesttag = 0;
var fhabitag = 0;
var preavatag = 0;
var covertag = 0;
//alert("I am in checkform");
//check for nestting checks
for(var k=0; k < arnest.length; k++){
var tag = 0;
	if(arnest[k] != -99){
	//alert("I am in nest no neg 99");
		for(var i=0; i<=6; i++){
		var object=eval("myform.nestfea"+k+"[i]");
		if(object.checked){tag=tag+1;}
		}
	}
	else{tag=tag+1;}
nesttag=nesttag+tag;
}
//alert("nest tag is "+nesttag);
//check for foraging checks
for(var k=0; k < arfhabi.length; k++){
var tag = 0;
	if(arfhabi[k] != -99){
	//alert("I am in fhabi no neg 99");
		for(var i=0; i<=6; i++){
		var object=eval("myform.fhabifea"+k+"[i]");
		if(object.checked){tag=tag+1;}
		}
	}
	else{tag=tag+1;}
fhabitag=fhabitag+tag;
}
//alert("fhabi tag is "+fhabitag);
//check for prey checks
for(var k=0; k < arpreava.length; k++){
var tag = 0;
	if(arpreava[k] != -99){
	//alert("I am in preava no neg 99");
		for(var i=0; i<=6; i++){
		var object=eval("myform.preavafea"+k+"[i]");
		if(object.checked){tag=tag+1;}
		}
	}
	else{tag=tag+1;}
preavatag=preavatag+tag;
}
//alert("preava tag is "+preavatag);
//check for cover checks
for(var k=0; k < arcover.length; k++){
var tag = 0;
	if(arcover[k] != -99){
	//alert("I am in cover no neg 99");
		for(var i=0; i<=6; i++){
		var object=eval("myform.coverfea"+k+"[i]");
		if(object.checked){tag=tag+1;}
		}
	}
	else{tag=tag+1;}
covertag=covertag+tag;
}
//alert("cover tag is "+covertag);
//validation check
if(nesttag != arnest.length){alert("You must select a change of habitat element category, for each of the key habitat elements in the reproduction life history requirement.");
return false;}
else if(fhabitag != arfhabi.length){alert("You must select a change of habitat element category, for each of the key habitat elements in the foraging habitat life history requirement.");
return false;}
else if(preavatag != arpreava.length){alert("You must select a change of habitat element category, for each of the key habitat elements in the forage, prey habitat life history requirement.");
return false;}
else if(covertag != arcover.length){alert("You must select a change of habitat element category, for each of the key habitat elements in the cover life history requirement.");
return false;}
else{return true;}
}

   // end of hiding -->
  </script>
 </head>
 <body>
  <font face="tahoma, arial, helvetica, sans serif">
   <table align="center" width="100%" border="0">
    <tr>
     <!-- img src="https://localhost/fuels/whrm/images/borealtoad4_Pilliod.jpg" alt="Wildlife Habitat Response Model" align="left" -->
     <td><img src="/fuels/whrm/images/borealtoad4_Pilliod.jpg"  alt="Wildlife Habitat Response Model" align="left"></td>
     <td align="center">
      <font face="tahoma, arial, helvetica, sans serif">
       <hr>
       <h2>Wildlife Habitat Response Model</h2>
       <hr>
      </font>
     </td>
     <!--<td><img src="https:/fuels/whrm/images/grayjay2_Pilliod.jpg" alt="Wildlife Habitat Response Model" align="right">-->
     <td>
      <img src="/fuels/whrm/images/grayjay3_Pilliod.jpg"  alt="Wildlife Habitat Response Model" align="right" width=156 height=117>
     </td>
    </tr>
   </table>
   <br>
   <center>

end11

}

sub tail_html {

print '
     <table border=0 width=100%>
      <tr>
       <td valign="top" bgcolor="lightgoldenrodyellow">
       <font face="tahoma, arial, helvetica, sans serif" size=1>
        The Wildlife Habitat Response Model (<b>WHRM</b>)<br>
       Wildlife Habitat Response Model input interface v. 
        <a href="javascript:popuphistory()">',$version,'</a> [',@_[0],'] (for review only) by David Hall &amp; Elena Velasquez<br>
        Model developed by David Pilliod<br>
        Team leader Elaine Kennedy Sutherland, USDA Forest Service, Rocky Mountain Research Station<br>
        forest.moscowfsl.wsu.edu/fuels/
       </font>
      </td>
     </tr>
    </table>
   </center>
  </font>
 </body>
</html>
';
}
sub taillit_html {

print '
     <table border=0 width=100%>
      <tr>
       <td valign="top" bgcolor="lightgoldenrodyellow">
       <font face="tahoma, arial, helvetica, sans serif" size=1>
	<!-- a href="\fuels\whrm\documents\MasterBibliography.pdf " target="_blank" --> <!-- img src="C:\Inetpub\wwwroot\fuels\images\pdf_logo.gif" border="0" alt="pdf" -->
	<a href="/fuels/whrm/documents/MasterBibliography.pdf" target="_blank"><b>Complete WHRM bibliography</b>
         <img src="/images/pdf_logo.gif" border="0" alt="[pdf]"></a><br>
        The Wildlife Habitat Response Model (<b>WHRM</b>)<br>
        Wildlife Habitat Response Model input interface v.  
        <a href="javascript:popuphistory()">',$version,'</a> [',@_[0],'] (for review only) by Elena Velasquez<br>
        Model developed by David Pilliod<br>
        Team leader Elaine Kennedy Sutherland, USDA Forest Service, Rocky Mountain Research Station<br>
        ',$temp_filename,'<br>
        forest.moscowfsl.wsu.edu/fuels/
       </font>
      </td>
     </tr>
    </table>
   </center>
  </font>
 </body>
</html>
';
}

sub featurecheck {
    my @array = @_;
    my $size;
    $size = (@array);
    for ( $i = 0 ; $i <= $size - 1 ; $i++ ) {
        if (   ( $array[$i] == 27 )
            || ( $array[$i] == 33 )
            || ( $array[$i] == 39 ) )
        {
            $array[$i] = 21;
        }
        if (   ( $array[$i] == 28 )
            || ( $array[$i] == 34 )
            || ( $array[$i] == 40 ) )
        {
            $array[$i] = 22;
        }
        if (   ( $array[$i] == 29 )
            || ( $array[$i] == 35 )
            || ( $array[$i] == 41 ) )
        {
            $array[$i] = 23;
        }
        if (   ( $array[$i] == 30 )
            || ( $array[$i] == 36 )
            || ( $array[$i] == 42 ) )
        {
            $array[$i] = 24;
        }
        if (   ( $array[$i] == 31 )
            || ( $array[$i] == 37 )
            || ( $array[$i] == 43 ) )
        {
            $array[$i] = 25;
        }
        if (   ( $array[$i] == 32 )
            || ( $array[$i] == 38 )
            || ( $array[$i] == 44 ) )
        {
            $array[$i] = 26;
        }
    }
    return @array;
}
