#!/usr/bin/perl -T
#use strict;
use CGI ':standard';
##########################################
# code name: wildlifem                  #
##########################################            
$debug=0;
$hdebug=0;


print "Content-type: text/html\n\n";
my @enames;
my @evalues;
my @sump=(0,0,0,0,0);
my @animalresp=0;
my @feaflag=(1,1,1,1,1);
$totalrow=0;
######

if($hdebug)
{
	foreach my $name (param () )
	{
		my @values= param ($name);
		my $evalues=$values;
		if($hdebug)
		{
		print "<p><b>Key:</b>$name <b>
		Value(s) :</b>@values";
		}
	}
}



@enames=param();
$lengthenames=@enames;
if($lengthenames>=2)
{
     for($i=0; $i<=(@enames-2);$i++) {
	$evalues[$i]=param($enames[$i]);
	if($evalues[$i]==-3){$pevalues[$i]="Greater than 70% Decrease";}	# DEH via EV
	if($evalues[$i]==-2){$pevalues[$i]="41-70% Decrease";}
	if($evalues[$i]==-1){$pevalues[$i]="11-40% Decrease";}
	if($evalues[$i]==0){$pevalues[$i]="No Change (+/-10%)";}
	if($evalues[$i]==1){$pevalues[$i]="11-40% Increase";}
	if($evalues[$i]==2){$pevalues[$i]="41-70% Increase";}
	if($evalues[$i]==3){$pevalues[$i]="Greater than 70% Increase";}
     }
     $action=pop(@enames);
}
else
{
     $action=pop(@enames);
}

if($debug)
{
print "<p>@enames";
print "<p>@evalues";
print "<p>@pevalues";
print "<p>action is $action";
}
#########################################
## uploading all information about the species
############################

$taxgroup=param('taxgroup');
$tax_group=param('tax_group');
$species=param('species');
$filename=param('filename');

if($debug)
{
print"<p>tax_group is $tax_group";
print"<p>taxgroup is $taxgroup";
print"<p>species is $species";
print"<p>filename is $filename";
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

##$junk=chop($filename);
##$junk2=chop($taxgroup);
$spefilename = $filename.".txt";
#$spepath = "//cgi-bin//fuels//wirm//species//".$taxgroup."//";		# DEH
$spepath = "species/".$taxgroup."/";

if($action=~/matrix/){
#########################################
## uploading all information about the species
############################

print<<"endf";
<html>
	<head>
		<title>Wildlife Response Model Output</title>
	</head>
	<body>

	<table align="center" width="100%" border="0">
		<tr>
		<td><img src="/fuels/wirm/images/borealtoad3_Pilliod.jpg" alt="Wildlife Response Model" align="left"></td>
		<td align="center"><hr>
		<h2>Wildlife Response Model</h2>
		<hr>
		</td>
		<td><img src="/fuels/wirm/images/grayjay3_Pilliod.jpg" alt="Wildlife Response Model" align="right">
		</td>
		</tr>
	</table>
	<br>
	<center>
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
	</center>
	</body>
</html>
endf
####open species file


if($debug)
{
print "<p>this is the file name: $spefilename\n";
print "<p>this is the path to the file: $spepath";
}
open (spe_file, $spepath .$spefilename)|| die("Error: files unopened!\n");
while(<spe_file>)
{
	if($_=~/Literature/){close (spe_file);}
	if($_=~/Nestsite/)
	{$_=<spe_file>;
	@row=split(/:/,$_);
	$nestrow=(@row);
		for($i=0; $i<=(@row-1);$i++)
		{($nestfeacode[$i],$nestdir[$i])=split(/,/,$row[$i],2);
		 if($nestfeacode[$i]==-99){$sum[0]=0;$pevaluesindex1=0;}
		 else{$evaltimesdir[$i]=$evalues[$i]*$nestdir[$i];
		 $sum[0]=$sum[0]+$evalues[$i]*$nestdir[$i];
		 $pevaluesindex1=$nestrow;
		 $feaflag[0]=0;}
		 if($debug){print"<p>nestcode is $nestfeacode[$i] and nestdir is $nestdir[$i] and product is $evaltimesdir[$i] ";
		 print "<p>sum[0]is $sum[0] and pevaluesindex1 is $pevaluesindex1";}
		}
	}
	elsif($_=~/Foraging Habitat/)
	{$_=<spe_file>;
	@row=split(/:/,$_);
	$fhabirow=(@row);
		for($i=0; $i<=(@row-1);$i++)
		{($fhabifeacode[$i],$fhabidir[$i])=split(/,/,$row[$i],2);
		 if($fhabifeacode[$i]==-99){$sum[1]=0;$pevaluesindex2=$pevaluesindex1;}
		 else{$evaltimesdir[$pevaluesindex1+$i]=$evalues[$pevaluesindex1+$i]*$fhabidir[$i];
		 $sum[1]=$sum[1]+$evalues[$pevaluesindex1+$i]*$fhabidir[$i];
		 $pevaluesindex2=$pevaluesindex1+$fhabirow;
		 $feaflag[1]=0;}
		 if($debug){print"<p>fhabicode is $fhabifeacode[$i] and fhabidir is $fhabidir[$i]";
		 print "<p>sum[1]is $sum[1] and pevaluesindex2 is $pevaluesindex2";}
		}
	}
	elsif($_=~/Forage\/Prey Availability/)
	{$_=<spe_file>;
	@row=split(/:/,$_);
	$preavarow=(@row);
		for($i=0; $i<=(@row-1);$i++)
		{($preavafeacode[$i],$preavadir[$i])=split(/,/,$row[$i],2);
		 if($preavafeacode[$i]==-99){$sum[2]=0;$pevaluesindex3=$pevaluesindex2;}
		 else{$evaltimesdir[$pevaluesindex2+$i]=$evalues[$pevaluesindex2+$i]*$preavadir[$i];
		 $sum[2]=$sum[2]+$evalues[$pevaluesindex2+$i]*$preavadir[$i];
		 $pevaluesindex3=$pevaluesindex2+$preavarow;
		 $feaflag[2]=0;}
		 if($debug){print"<p>preavacode is $preavafeacode[$i] and preavadir is $preavadir[$i] ";
		 print "<p>sum[2]is $sum[2] and pevaluesindex3 is $pevaluesindex3";}
		}
	}
	elsif($_=~/Predator Avoidance/)
	{$_=<spe_file>;
	@row=split(/:/,$_);
	$avoprerow=(@row);
		for($i=0; $i<=(@row-1);$i++)
		{($avoprefeacode[$i],$avopredir[$i])=split(/,/,$row[$i],2);
		 if($avoprefeacode[$i]==-99){$sum[3]=0;$pevaluesindex4=$pevaluesindex3;}
		 else{$evaltimesdir[$pevaluesindex3+$i]=$evalues[$pevaluesindex3+$i]*$avopredir[$i];
		 $sum[3]=$sum[3]+$evalues[$pevaluesindex3+$i]*$avopredir[$i];
		 $pevaluesindex4=$pevaluesindex3+$avoprerow;
		 $feaflag[3]=0;}
		 if($debug){print"<p>avoprecode is $avoprefeacode[$i] and avopredir is $avopredir[$i] ";
		 print "<p>sum[3]is $sum[3] and pevaluesindex4 is $pevaluesindex4";}
		}
	}
	elsif($_=~/Refugia\/Shelter/)
	{$_=<spe_file>;
	@row=split(/:/,$_);
	$refsherow=(@row);
		for($i=0; $i<=(@row-1);$i++)
		{($refshefeacode[$i],$refshedir[$i])=split(/,/,$row[$i],2);
		 if($refshefeacode[$i]==-99){$sum[4]=0;}
		 else{$evaltimesdir[$pevaluesindex4+$i]=$evalues[$pevaluesindex4+$i]*$refshedir[$i];
		 $sum[4]=$sum[4]+$evalues[$pevaluesindex4+$i]*$refshedir[$i];
		 $feaflag[4]=0;}
		 if($debug){print"<p>refshecode is $refshefeacode[$i] and refshedir is $refshedir[$i] ";
		 print "<p>sum[4]is $sum[4]";}
		}
	}

}

close (spe_file);
if($debug)
{
$sizeevaltimesdir=@evaltimesdir;
print "sizeevaltimesdir is $sizeevaltimesdir";
}

for($i=0; $i<=(@evaltimesdir-1);$i++)
{
	if($evaltimesdir[$i]==-3){$pevaltimesdir[$i]="Negative";}
	if($evaltimesdir[$i]==-2){$pevaltimesdir[$i]="Likely Negative";}
	if($evaltimesdir[$i]==-1){$pevaltimesdir[$i]="Possibly Negative";}
	if($evaltimesdir[$i]==0){$pevaltimesdir[$i]="Neutral";}
	if($evaltimesdir[$i]==1){$pevaltimesdir[$i]="Possibly Positive";}
	if($evaltimesdir[$i]==2){$pevaltimesdir[$i]="Likely Positive";}
	if($evaltimesdir[$i]==3){$pevaltimesdir[$i]="Positive";}
}


$rr1=$nestrow;
if($feaflag[0]){$animalresp[0]=-99;$totalrow=1;}
else{$animalresp[0]=$sum[0]/$rr1;$totalrow=$totalrow+$rr1;$divisorstand=$divisorstand+1;}

$rr2=$fhabirow+$preavarow;
if(($feaflag[1])&&($feaflag[2])){$animalresp[1]=-99}
else
{if($feaflag[1]){$animalresp[1]=($sum[1]+$sum[2])/($rr2-1);$totalrow=$totalrow+$rr2-1;}
elsif($feaflag[2]){$animalresp[1]=($sum[1]+$sum[2])/($rr2-1);$totalrow=$totalrow+$rr2-1;}
else{$animalresp[1]=($sum[1]+$sum[2])/$rr2;}
$totalrow=$totalrow+$rr2;
$divisorstand=$divisorstand+1;}

$rr3=$avoprerow;
if($feaflag[3]){$animalresp[2]=-99}
else{$animalresp[2]=$sum[3]/$rr3;$totalrow=$totalrow+$rr3;$divisorstand=$divisorstand+1;}

$rr4=$refsherow;
if($feaflag[4]){$animalresp[3]=-99}
else{$animalresp[3]=$sum[4]/$rr4;$totalrow=$totalrow+$rr4;$divisorstand=$divisorstand+1;}

$psentence[0]="The management activity will likely result in <br>a negative effect on habitat suitability";
$psentence[1]="The management activity will possibly result in <br>a negative effect on habitat suitability";
$psentence[2]="The management activity will have <br>minimal effect on habitat suitability";	# DEH
$psentence[3]="The management activity will possibly result in <br>a positive effect on habitat suitability";
$psentence[4]="The management activity will likely result in <br>a positive effect on habitat suitability";


for($i=0; $i<=3;$i++)
{
if(($animalresp[$i]>=-3)&&($animalresp[$i]<=-1.5)){$panimalresp[$i]=$psentence[0];}
elsif(($animalresp[$i]>-1.5)&&($animalresp[$i]<=-0.25)){$panimalresp[$i]=$psentence[1];}
elsif(($animalresp[$i]>-0.25)&&($animalresp[$i]<=0.25)){$panimalresp[$i]=$psentence[2];}
elsif(($animalresp[$i]>0.25)&&($animalresp[$i]<=1.5)){$panimalresp[$i]=$psentence[3];}
elsif(($animalresp[$i]>1.5)&&($animalresp[$i]<=3)){$panimalresp[$i]=$psentence[4];}
else{$panimalresp[$i]="Not Avaliable";}
}

if($debug)
{
print "<p>nestrow is :$nestrow";
print "<p>fhabirow is :$fhabirow";
print "<p>preavarow is :$preavarow";
print "<p>avoprerow is :$avoprerow";
print "<p>refsherow is :$refsherow";
print "<p>rr1 $rr1";
print "<p>rr2 $rr2";
print "<p>rr3 $rr3";
print "<p>rr4 $rr4";
print "<p>totalrow $totalrow";
print "<p>animalresp @animalresp";
print "<p>animalresp @panimalresp";
}

##for($i=0; $i<=3;$i++)
##{if($animalresp[$i]==-99){$standsum=$standsum;}
##else{$standsum=$standsum+$animalresp[$i];}
##}
##$standtotal=$standsum/$divisorstand;

##if(($standtotal>=-2)&&($standtotal<=-1.5)){$pstandtotal="Likely Adverse";}
##elsif(($standtotal>-1.5)&&($standtotal<=-0.5)){$pstandtotal="Possible Adverse";}
##elsif(($standtotal>-0.5)&&($standtotal<=0.5)){$pstandtotal="Neutral";}
##elsif(($standtotal>0.5)&&($standtotal<=1.5)){$pstandtotal="Possibly Beneficial";}
##elsif(($standtotal>1.5)&&($standtotal<=2)){$pstandtotal="Likely Beneficial";}
##else{$pstandtotal="Not Avaliable";}


##if($debug)
##{
##print "<p>animalresp @animalresp";
##print "<p>standsum $standsum";
##print "<p>divisorstand $divisorstand";
##print "<p>pstandtotal $pstandtotal";
##}


###################################
##form 2######
#####beging of form two
print <<"fin";
				<table align="center" border="2" ID="Table1">
					<caption>
						<b><font size="4"></font></b>
					</caption>
					<tr>
						<th colspan="2"  bgcolor="#006009">
							<font color="#99ff00">Life History Requirements</font></th>
						<th  bgcolor="#006009">
							<font color="#99ff00">Key Habitat Element(s)</font></th>
						<th  bgcolor="#006009">
							<font color="#99ff00">Change in Habitat Element(s)<br>
						(user's selection)</font>
						</th>
						<th  bgcolor="#006009">
							<font color="#99ff00">Predicted Response<br>of Animals</font>
						</th>
						<th  bgcolor="#006009">
							<font color="#99ff00">Fuel Treatment<br>Effect on Habitat</font>
						</th>
					</tr>
					

fin
#########beginnig of copy
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
			print "<td colspan=4 align=center>No Information Is Available</td>
			<!--<td rowspan=$totalrow align=center>$pstandtotal</td>-->
			</tr>";
			##$pevaluesindex1=0;
			}
			else
			{
			print "<td>$habitatfeatures[$nestfeacode[$i]]</td>
			<td align=center>$pevalues[$i]</td>
			<td align=center>$pevaltimesdir[$i]</td>
			<td align=center rowspan=$rr1>$panimalresp[$i]</td>
			<!--<td rowspan=$totalrow align=center>$pstandtotal</td>-->
			</tr>";
			##$pevaluesindex1=$nestrow;
			}
		}
	else{
		print "<tr>
		<td>$habitatfeatures[$nestfeacode[$i]]</td>
		<td align=center>$pevalues[$i]</td>
		<td align=center>$pevaltimesdir[$i]</td>
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
			{if($preavafeacode[$i]==-99)
			 {print "<td colspan=4 align=center>No Information Is Available</td></tr>";}
			 else{print "<td colspan=3 align=center>No Information Is Available</td>
			 <td align=center rowspan=$rr2>$panimalresp[1]</td>
			 </tr>";}
			##$pevaluesindex2=$pevaluesindex1;
			}
			else
			{
			print "<td>$habitatfeatures[$fhabifeacode[$i]]</td>
			<td align=center>$pevalues[$pevaluesindex1+$i]</td>
			<td align=center>$pevaltimesdir[$pevaluesindex1+$i]</td>
			<td align=center rowspan=$rr2>$panimalresp[1]</td>
			</tr>";
			##$pevaluesindex2=$pevaluesindex1+$fhabirow;
			}
		}
	else{print "<tr>
		<td>$habitatfeatures[$fhabifeacode[$i]]</td>
		<td align=center>$pevalues[$pevaluesindex1+$i]</td>
		<td align=center>$pevaltimesdir[$pevaluesindex1+$i]</td>
		</tr>";}
}
print "<tr>
	<th rowspan=$preavarow BGCOLOR=\"#006009\">
	<Font color=\"#99ff00\">Forage,<br>Prey Habitat</Font></th>";

for($i=0; $i<=$preavarow-1;$i++)
{
	if($i==0){	if($preavafeacode[$i]==-99)
			{
			print "<td colspan=3 align=center>No Information Is Available</td>
			</tr>";
			##$pevaluesindex3=$pevaluesindex2;
			}
			else
			{
			print "<td>$habitatfeatures[$preavafeacode[$i]]</td>
			<td align=center>$pevalues[$pevaluesindex2+$i]</td>
			<td align=center>$pevaltimesdir[$pevaluesindex2+$i]</td>
			</tr>";
			##$pevaluesindex3=$pevaluesindex2+$preavarow;
			}
		}
	else{print "<tr>
		<td>$habitatfeatures[$preavafeacode[$i]]</td>
		<td align=center>$pevalues[$pevaluesindex2+$i]</td>
		<td align=center>$pevaltimesdir[$pevaluesindex2+$i]</td>
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
			print "<td colspan=4 align=center>No Information Is Available</td>
			</tr>";
			##$pevaluesindex4=$pevaluesindex3;
			}
			else
			{
			print "<td>$habitatfeatures[$avoprefeacode[$i]]</td>
			<td align=center>$pevalues[$pevaluesindex3+$i]</td>
			<td align=center>$pevaltimesdir[$pevaluesindex3+$i]</td>
			<td align=center rowspan=$rr3>$panimalresp[2]</td>
			</tr>";
			##$pevaluesindex4=$pevaluesindex3+$avoprerow;
			}
		}
	else{print "<tr>
		<td>$habitatfeatures[$avoprefeacode[$i]]</td>
		<td align=center>$pevalues[$pevaluesindex3+$i]</td>
		<td align=center>$pevaltimesdir[$pevaluesindex3+$i]</td>
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
			print "<td colspan=4 align=center>No Information Is Available</td>
			</tr>";
			}
			else
			{
			print "<td>$habitatfeatures[$refshefeacode[$i]]</td>
			<td align=center>$pevalues[$pevaluesindex4+$i]</td>
			<td align=center>$pevaltimesdir[$pevaluesindex4+$i]</td>
			<td align=center rowspan=$rr4>$panimalresp[3]</td>
			</tr>";
			}
		}
	else{print "<tr>
		<td>$habitatfeatures[$refshefeacode[$i]]</td>
		<td align=center>$pevalues[$pevaluesindex4+$i]</td>
		<td align=center>$pevaltimesdir[$pevaluesindex4+$i]</td>
		</tr>";}
}
#########end of copy
print <<"end1";
				</table>
	<br>
	<center>
	<p>The fuel treatment effect on habitat is calculated as an average of the predicted reponse of animals for each life history requirement category. Please consider each life history category separately.<br>To view general life history information or information about the studies used to develop this tool for your selected species, please use the "View Background Information" button.</p>
	<br>
	<form method="post" name="wildlifem3" action="/cgi-bin/fuels/wirm/wildlifem2.pl">   <!-- DEH -->
      <input type="hidden" value="$taxgroup" name="taxgroup">
	<input type="hidden" value="$species" name="species">
	<input type="hidden" value="$filename" name="filename">
	<INPUT type="submit" value="View Background Information" ID="Submit1" NAME="liturature">  <!-- DEH -->
	</form>
	</center>
	</body>
</html>
end1
}
######################end of matrix
else
{
open (LITFILE, $spepath .$spefilename)|| die("Error: files unopened!\n");
while(<LITFILE>)
{	
	if($_=~/Literature/)
	{@litreview=<LITFILE>;}
}

close (LITFILE);
$test=int((@litreview-1)/2);
if($debug){
$sizelit=(@litreview);
print "<p>literature $sizelit";
print "<p>test is $test";
}
print<<"fin1";
<html>
	<head>
		<title>Wildlife Response Model Literature Review</title>
	</head>
	<body>
	<center>
		<table align="center" border="2">
			<caption>
				<b><font size="5">Wildlife Response Model Background Information<br> $species</font></b>
			</caption>
fin1
for($i=0; $i<=11;$i++)
{print"
	<tr>
		<th colspan=2 bgcolor=#006009>
		<font size=4 color=#99ff00>$litreview[(2*$i)]</font></th>
		<td>$litreview[(2*$i+1)]</td>
	</tr>
";}
print<<"fin10";
			</table>
		<br>
		<font size=5><b>$litreview[24]</b></font>
		<br><br>
		</center>
fin10
for($i=25; $i<=(@litreview-1);$i++)
{print"$litreview[$i]<br>";}
print<<"fin11";
		<br>
		<hr>
		<p>Wildlife Response Model<br>
			Developed by: David Pilliod<br>
			Project Manager: Elaine Sutherland<br>
			Version: 2004.1</p>
	</body>
</html>
fin11
}

