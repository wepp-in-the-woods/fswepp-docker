#!/usr/bin/perl -T
#use strict;
use CGI ':standard';
##########################################
# code name: wildlifem                  #
##########################################            
$debug=0;
$hdebug=0;


print "Content-type: text/html\n\n";
my @names;
my @values;

######
if($hdebug)
{
	foreach my $name (param () )
	{
		my @values= param ($name);
		print "<p><b>Key:</b>$name <b>
		Value(s) :</b>@values";
	}
}
########################################
## HTML output of all the input        #
########################################

$tax_group=param('tax_group'); 
$taxgroup=lc($tax_group);
$taxgroup=~s/ //g;
 
$species=param('species');  

if($debug)
{
print"<p>tax_group is $tax_group";
print"<p>taxgroup is $taxgroup";
print"<p>species is $species";
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

#########################################
## uploading all information about the species
############################

$spefilename = $filename .".txt";
#$spepath = "//cgi-bin//fuels//wirm/species//".$taxgroup."//";	# DEH
$spepath = "species/".$taxgroup."/";

if($debug)
{
print "<p>spefilename is $spefilename";
print "<p>spepath is $spepath";
}
open (spe_file, $spepath .$spefilename)|| Error('open','file');;
while(<spe_file>)
{
	if($_=~/Literature/){close (spe_file);}
	if($_=~/Nestsite/)
	{$_=<spe_file>;
	@row=split(/:/,$_);
	$nestrow=(@row);
		for($i=0; $i<=(@row-1);$i++)
		{($nestfeacode[$i],$nestdir[$i])=split(/,/,$row[$i],2);
		 if($debug){print"<p>nestcode is $nestfeacode[$i] and nestdir is $nestdir[$i] ";}}
	}
	if($_=~/Foraging Habitat/)
	{$_=<spe_file>;
	@row=split(/:/,$_);
	$fhabirow=(@row);
		for($i=0; $i<=(@row-1);$i++)
		{($fhabifeacode[$i],$fhabidir[$i])=split(/,/,$row[$i],2);
		 if($debug){print"<p>fhabicode is $fhabifeacode[$i] and fhabidir is $fhabidir[$i] ";}}
	}
	if($_=~/Forage\/Prey Availability/)
	{$_=<spe_file>;
	@row=split(/:/,$_);
	$preavarow=(@row);
		for($i=0; $i<=(@row-1);$i++)
		{($preavafeacode[$i],$preavadir[$i])=split(/,/,$row[$i],2);
		 if($debug){print"<p>preavacode is $preavafeacode[$i] and preavadir is $preavadir[$i] ";}}
	}
	if($_=~/Predator Avoidance/)
	{$_=<spe_file>;
	@row=split(/:/,$_);
	$avoprerow=(@row);
		for($i=0; $i<=(@row-1);$i++)
		{($avoprefeacode[$i],$avopredir[$i])=split(/,/,$row[$i],2);
		 if($debug){print"<p>avoprecode is $avoprefeacode[$i] and avopredir is $avopredir[$i] ";}}
	}
	if($_=~/Refugia\/Shelter/)
	{$_=<spe_file>;
	@row=split(/:/,$_);
	$refsherow=(@row);
		for($i=0; $i<=(@row-1);$i++)
		{($refshefeacode[$i],$refshedir[$i])=split(/,/,$row[$i],2);
		 if($debug){print"<p>refshecode is $refshefeacode[$i] and refshedir is $refshedir[$i] ";}}
	}

}

close (spe_file);
if($debug)
{
print "<p>nestrow is :$nestrow";
print "<p>fhabirow is :$fhabirow";
print "<p>preavarow is :$preavarow";
print "<p>avoprerow is :$avoprerow";
print "<p>refsherow is :$refsherow";
}
$rr1=$nestrow;
$rr2=$fhabirow+$preavarow;
$rr3=$avoprerow;
$rr4=$refsherow;

########################
##html blocks to repeat
####
$block[0]= "<td>$habitatfeatures[$nestfeacode[0]]</td>
<td align=center><INPUT type=radio  VALUE=-2 NAME=a></td>
<td align=center><INPUT type=radio  VALUE=-1 NAME=a></td>
<td align=center><INPUT type=radio VALUE=0 NAME=a checked></td>
<td align=center><INPUT type=radio  VALUE=1 NAME=a></td>
<td align=center><INPUT type=radio  VALUE=2 NAME=a></td>
</tr>
";
$block[1]="<tr>
<td>$habitatfeatures[$nestfeacode[1]]</td>
<td align=center><INPUT type=radio  VALUE=-2 NAME=a></td>
<td align=center><INPUT type=radio  VALUE=-1 NAME=a></td>
<td align=center><INPUT type=radio VALUE=0 NAME=a checked></td>
<td align=center><INPUT type=radio  VALUE=1 NAME=a></td>
<td align=center><INPUT type=radio  VALUE=2 NAME=a></td>
</tr>
";
####end of blocks to repeat
#####

print<<"end";
<html>
	<head>
		<title>Wildlife Response Model Output</title>
	</head>
	<body>

	<table align="center" width="100%" border="0">
		<tr>
		<td><img src="/fuels/wirm/images/borealtoad4_Pilliod.jpg" alt="Wildlife Response Model" align="left"></td>
		<td align="center"><hr>
		<h2>Wildlife Response Matrix</h2>
		<hr>
		</td>
		<td><img src="/fuels/wirm/images/grayjay2_Pilliod.jpg" alt="Wildlife Response Model" align="right">
		</td>
		</tr>
	</table>
	<br>
	<center>
	<p>Select the change in each habitat element based on expected results of the planned fuel treatment.<br>If a habitat element is repeated in more than one life history requirement category, <br>please make sure the selection is the same for each category.</p>
	<br>
	<form method="post" name="wildlifem2" action="/cgi-bin/fuels/wirm/wildlifem2.pl">
		<table align="center" border="2">
			<caption>
				<b><font size="4">Wildlife Response Model</font></b>
			</caption>
				<tr>
					<th BGCOLOR="#006009">
						<Font color="#99ff00">Taxonomic group:</Font></th>
					<td>$tax_group</td>
				</tr>
				<tr>
					<th BGCOLOR="#006009">
						<Font color="#99ff00">Species:</Font></th>
					<td >$species</td>
				</tr>
		</table>
	<br>
end
###################################
##form 2######
#####beging of form two
print <<"fin";
				<table align="center" border="2" ID="Table1">
					<caption>
						<b><font size="4"></font></b>
					</caption>
					<tr>
						<th colspan="2" rowspan="2" bgcolor="#006009">
							<font color="#99ff00">Life History Requirements</font></th>
						<th rowspan="2" bgcolor="#006009">
							<font color="#99ff00">Key Wildlife Habitat Elements</font></th>
						<th colspan="7" bgcolor="#006009">
							<font color="#99ff00">Change in Habitat Elements</font>
						</th>
					</tr>
					<tr>
						<th bgcolor="#006009">
							<font color="#99ff00" size="2">Greater than<br>
								70% Decrease</font></th>
						<th bgcolor="#006009">
							<font color="#99ff00" size="2">41-70%<br>
								Decrease</font></th>
						<th bgcolor="#006009">
							<font color="#99ff00" size="2">11-40%<br>
								Decrease</font></th>
						<th bgcolor="#006009">
							<font color="#99ff00" size="2">No Change<br>
								(+/-10%)</font></th>
						<th bgcolor="#006009">
							<font color="#99ff00" size="2">11-40%
								<br>
								Increase</font></th>
						<th bgcolor="#006009">
							<font color="#99ff00" size="2">41-70%
								<br>
								Increase</font></th>
						<th bgcolor="#006009">
							<font color="#99ff00" size="2">Greater than<br>
								70% Increase</font></th>
					</tr>

fin
print <<"final";
					<tr>
						<th rowspan=$rr1 BGCOLOR="#006009">
							<Font color="#99ff00">Reproduction</Font></th>
						<th rowspan=$nestrow BGCOLOR="#006009">
							<Font color="#99ff00">Nest Sites,<br>Birthing Areas,<br>
							Breeding Sites</Font></th>
final
for($i=0; $i<=$nestrow-1;$i++)
{
	if($i==0){	if($nestfeacode[$i]==-99)
			{
			print "<td colspan=8 align=center>No Information Is Available</td>
			</tr>";
			}
			else
			{
			print "<td>$habitatfeatures[$nestfeacode[0]]</td>
			<td align=center><INPUT type=radio  VALUE=-3 NAME=\"nestfea0\"></td>
			<td align=center><INPUT type=radio  VALUE=-2 NAME=\"nestfea0\"></td>
			<td align=center><INPUT type=radio  VALUE=-1 NAME=nestfea0></td>
			<td align=center><INPUT type=radio VALUE=0 NAME=nestfea0 checked></td>
			<td align=center><INPUT type=radio  VALUE=1 NAME=nestfea0></td>
			<td align=center><INPUT type=radio  VALUE=2 NAME=nestfea0></td>
			<td align=center><INPUT type=radio  VALUE=3 NAME=nestfea0></td>
			</tr>";
			}
		}
	else{print "<tr>
		<td>$habitatfeatures[$nestfeacode[$i]]</td>
		<td align=center><INPUT type=radio  VALUE=-3 NAME=\"nestfea$i\"></td>
		<td align=center><INPUT type=radio  VALUE=-2 NAME=\"nestfea$i\"></td>
		<td align=center><INPUT type=radio  VALUE=-1 NAME=\"nestfea$i\"></td>
		<td align=center><INPUT type=radio VALUE=0 NAME=\"nestfea$i\" checked></td>
		<td align=center><INPUT type=radio  VALUE=1 NAME=\"nestfea$i\"></td>
		<td align=center><INPUT type=radio  VALUE=2 NAME=\"nestfea$i\"></td>
		<td align=center><INPUT type=radio  VALUE=3 NAME=nestfea$i></td>
		</tr>";}
}
print <<"fin1";
					<tr>
						<th rowspan=$rr2 BGCOLOR="#006009">
							<Font color="#99ff00">Food Resources</Font></th>
						<th rowspan=$fhabirow BGCOLOR="#006009">
							<Font color="#99ff00">Foraging Habitat</Font></th>
fin1
for($i=0; $i<=$fhabirow-1;$i++)
{
	if($i==0){	if($fhabifeacode[$i]==-99)
			{
			print "<td colspan=8 align=center>No Information Is Available</td>
			</tr>";
			}
			else
			{
			print "<td>$habitatfeatures[$fhabifeacode[0]]</td>
			<td align=center><INPUT type=radio  VALUE=-3 NAME=\"fhabifea0\"></td>
			<td align=center><INPUT type=radio  VALUE=-2 NAME=\"fhabifea0\"></td>
			<td align=center><INPUT type=radio  VALUE=-1 NAME=fhabifea0></td>
			<td align=center><INPUT type=radio VALUE=0 NAME=fhabifea0 checked></td>
			<td align=center><INPUT type=radio  VALUE=1 NAME=fhabifea0></td>
			<td align=center><INPUT type=radio  VALUE=2 NAME=fhabifea0></td>
			<td align=center><INPUT type=radio  VALUE=3 NAME=\"fhabifea0\"></td>
			</tr>";
			}
		}
	else{print "<tr>
		<td>$habitatfeatures[$fhabifeacode[$i]]</td>
		<td align=center><INPUT type=radio  VALUE=-3 NAME=\"fhabifea$i\"></td>
		<td align=center><INPUT type=radio  VALUE=-2 NAME=\"fhabifea$i\"></td>
		<td align=center><INPUT type=radio  VALUE=-1 NAME=\"fhabifea$i\"></td>
		<td align=center><INPUT type=radio VALUE=0 NAME=\"fhabifea$i\" checked></td>
		<td align=center><INPUT type=radio  VALUE=1 NAME=\"fhabifea$i\"></td>
		<td align=center><INPUT type=radio  VALUE=2 NAME=\"fhabifea$i\"></td>
		<td align=center><INPUT type=radio  VALUE=3 NAME=\"fhabifea$i\"></td>
		</tr>";}
}
print "<tr>
	<th rowspan=$preavarow BGCOLOR=\"#006009\">
	<Font color=\"#99ff00\">Forage,<br>Prey Habitat</Font></th>";

for($i=0; $i<=$preavarow-1;$i++)
{
	if($i==0){	if($preavafeacode[$i]==-99)
			{
			print "<td colspan=8 align=center>No Information Is Available</td>
			</tr>";
			}
			else
			{
			print "<td>$habitatfeatures[$preavafeacode[0]]</td>
			<td align=center><INPUT type=radio  VALUE=-3 NAME=\"preavafea0\"></td>
			<td align=center><INPUT type=radio  VALUE=-2 NAME=\"preavafea0\"></td>
			<td align=center><INPUT type=radio  VALUE=-1 NAME=preavafea0></td>
			<td align=center><INPUT type=radio VALUE=0 NAME=preavafea0 checked></td>
			<td align=center><INPUT type=radio  VALUE=1 NAME=preavafea0></td>
			<td align=center><INPUT type=radio  VALUE=2 NAME=preavafea0></td>
			<td align=center><INPUT type=radio  VALUE=3 NAME=\"preavafea0\"></td>
			</tr>";
			}
		}
	else{print "<tr>
		<td>$habitatfeatures[$preavafeacode[$i]]</td>
		<td align=center><INPUT type=radio  VALUE=-3 NAME=\"preavafea$i\"></td>
		<td align=center><INPUT type=radio  VALUE=-2 NAME=\"preavafea$i\"></td>
		<td align=center><INPUT type=radio  VALUE=-1 NAME=\"preavafea$i\"></td>
		<td align=center><INPUT type=radio VALUE=0 NAME=\"preavafea$i\" checked></td>
		<td align=center><INPUT type=radio  VALUE=1 NAME=\"preavafea$i\"></td>
		<td align=center><INPUT type=radio  VALUE=2 NAME=\"preavafea$i\"></td>
		<td align=center><INPUT type=radio  VALUE=3 NAME=\"preavafea$i\"></td>
		</tr>";}
}
print <<"fin2";
<tr>
						<th rowspan=$rr3 BGCOLOR="#006009">
							<Font color="#99ff00">Predators</Font></th>
						<th rowspan=$avoprerow BGCOLOR="#006009">
							<Font color="#99ff00">Predator Avoidance,<br>
							Shelter from Predators</Font></th>
fin2

for($i=0; $i<=$avoprerow-1;$i++)
{
	if($i==0){	if($avoprefeacode[$i]==-99)
			{
			print "<td colspan=8 align=center>No Information Is Available</td>
			</tr>";
			}
			else
			{
			print "<td>$habitatfeatures[$avoprefeacode[0]]</td>
			<td align=center><INPUT type=radio  VALUE=-3 NAME=\"avoprefea0\"></td>
			<td align=center><INPUT type=radio  VALUE=-2 NAME=\"avoprefea0\"></td>
			<td align=center><INPUT type=radio  VALUE=-1 NAME=avoprefea0></td>
			<td align=center><INPUT type=radio VALUE=0 NAME=avoprefea0 checked></td>
			<td align=center><INPUT type=radio  VALUE=1 NAME=avoprefea0></td>
			<td align=center><INPUT type=radio  VALUE=2 NAME=avoprefea0></td>
			<td align=center><INPUT type=radio  VALUE=3 NAME=\"avoprefea0\"></td>
			</tr>";
			}
		}
	else{print "<tr>
		<td>$habitatfeatures[$avoprefeacode[$i]]</td>
		<td align=center><INPUT type=radio  VALUE=-3 NAME=\"avoprefea$i\"></td>
		<td align=center><INPUT type=radio  VALUE=-2 NAME=\"avoprefea$i\"></td>
		<td align=center><INPUT type=radio  VALUE=-1 NAME=\"avoprefea$i\"></td>
		<td align=center><INPUT type=radio VALUE=0 NAME=\"avoprefea$i\" checked></td>
		<td align=center><INPUT type=radio  VALUE=1 NAME=\"avoprefea$i\"></td>
		<td align=center><INPUT type=radio  VALUE=2 NAME=\"avoprefea$i\"></td>
		<td align=center><INPUT type=radio  VALUE=3 NAME=\"avoprefea$i\"></td>
		</tr>";}
}
print <<"fin3";
					<tr>
						<th rowspan=$rr4 BGCOLOR="#006009">
							<Font color="#99ff00">Hazards</Font></th>
						<th rowspan=$refsherow BGCOLOR="#006009">
							<Font color="#99ff00">Shelter from <br>Environmental
							Extremes</Font></th>
fin3
for($i=0; $i<=$refsherow-1;$i++)
{
	if($i==0){	if($refshefeacode[$i]==-99)
			{
			print "<td colspan=8 align=center>No Information Is Available</td>
			</tr>";
			}
			else
			{
			print "<td>$habitatfeatures[$refshefeacode[0]]</td>
			<td align=center><INPUT type=radio  VALUE=-3 NAME=\"refshefea0\"></td>
			<td align=center><INPUT type=radio  VALUE=-2 NAME=\"refshefea0\"></td>
			<td align=center><INPUT type=radio  VALUE=-1 NAME=refshefea0></td>
			<td align=center><INPUT type=radio VALUE=0 NAME=refshefea0 checked></td>
			<td align=center><INPUT type=radio  VALUE=1 NAME=refshefea0></td>
			<td align=center><INPUT type=radio  VALUE=2 NAME=refshefea0></td>
			<td align=center><INPUT type=radio  VALUE=3 NAME=\"refshefea0\"></td>
			</tr>";
			}
		}
	else{print "<tr>
		<td>$habitatfeatures[$refshefeacode[$i]]</td>
		<td align=center><INPUT type=radio  VALUE=-3 NAME=\"refshefea$i\"></td>
		<td align=center><INPUT type=radio  VALUE=-2 NAME=\"refshefea$i\"></td>
		<td align=center><INPUT type=radio  VALUE=-1 NAME=\"refshefea$i\"></td>
		<td align=center><INPUT type=radio VALUE=0 NAME=\"refshefea$i\" checked></td>
		<td align=center><INPUT type=radio  VALUE=1 NAME=\"refshefea$i\"></td>
		<td align=center><INPUT type=radio  VALUE=2 NAME=\"refshefea$i\"></td>
		<td align=center><INPUT type=radio  VALUE=3 NAME=\"refshefea$i\"></td>
		</tr>";}
}
print <<"end1";
				</table>
	<br>
	<p>You may return to this page to examine a different fuel treatment alternative by using the back arrow or starting over.</p>
	<br>
	<input type="hidden" value="$tax_group" name="tax_group">
	<input type="hidden" value="$taxgroup" name="taxgroup">
	<input type="hidden" value="$species" name="species">
	<input type="hidden" value="$filename" name="filename">
	<INPUT type="submit" value="Run Wildlife Response Model" ID="Submit1" NAME="matrix">
	</form>
	</center>
	</body>
</html>
end1
### end of begining of form 2
##$rr4=$refsherow+$envstrrow;

