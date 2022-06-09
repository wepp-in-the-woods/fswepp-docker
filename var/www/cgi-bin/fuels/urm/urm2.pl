#!/usr/bin/perl

# urm2.pl modified from that sent by Elena V. 2005.01.24

# 2005.09.14 DEH updated version number
# 2005.09.13 EV -- ??
# 2005.01.31 DEH re-introduced run logging

#use strict;
use CGI ':standard';
##########################################
# code name: urm2.pl                     #
##########################################            
$debug=0;
$indexdebug=0;
$hdebug=0;

print "Content-type: text/html\n\n";

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
my (@unburned,@vvl);
my @rows;
$treatmentflag=0;
$seedbankflag=0;
$pnotaflag=1;
@firenote=(" "," ");

#########GET INPUTS FROM HTML FORM######
# 1. No CALL SUBROUTINE READPARSE      #
# 2. LOAD IN ALL THE VARIABLE          #
########################################

$numtreatments=param('tsize');
for($j=0; $j<$numtreatments; $j++)
{
if($j==0){$treatmentsf[$j]=param('treatment0')}
elsif($j==1){$treatmentsf[$j]=param('treatment1')}
elsif($j==2){$treatmentsf[$j]=param('treatment2')}
else{$treatmentsf[$j]=param('treatment3')}
}

if ($debug)
{
print "<p>Number of treatments selected is: $numtreatments<br>";
print "<p>treatmentsf are: @treatmentsf";
}

########################################
## Initial Stands Conditions           #
########################################

$area=param('area');

if($area==0){$parea="1-100"}
elsif($area==1){$parea="101-1,000"}
else{$parea="1,001-10,000"}

$startcanopy=param('start_canopy');
$duffdepth=param('duff_depth');

if($duffdepth==0){$pduffdepth=0.5} 
elsif($duffdepth==1){$pduffdepth=1} 
elsif($duffdepth==2){$pduffdepth=2} 
elsif($duffdepth==3){$pduffdepth=3} 
elsif($duffdepth==4){$pduffdepth=4} 
else{$pduffdepth=5} 

########################################
## Plant Characteristics               #
########################################
$weedname=param('tipo');

$species=param('species');

#$species=~ s/\b(\w)/\U$1/g;###capitalizing the first letter of each word


if(($weedname=~m/" "/)||($weedname=~m/""/)||(not($weedname))){$pspecies="Plant";$wepaflag=1}
if(($species=~m/" "/)||($species=~m/""/)||(not($species))){$pspecies="Plant";$wepaflag=2}

if((($weedname=~m/" "/)||($weedname=~m/""/)||(not($weedname)))&&(($species=~m/" "/)||($species=~m/""/)||(not($species)))){$pspecies="Plant"}
else{
if($wepaflag==2){
if($weedname==0){$pspecies="weed";}
if($weedname==1){$pspecies="Acroptilon repens/hardheads"}
if($weedname==2){$pspecies="Bromus tectorum/cheatgrass"}
if($weedname==3){$pspecies="Cardaria chalapa/lenspod whitetop"}
if($weedname==4){$pspecies="Cardaria draba/whitetop"}
if($weedname==5){$pspecies="Cardaria pubescens/hairy whitetop"}
if($weedname==6){$pspecies="Cardus nutans/nodding plumeless thistle"}
if($weedname==7){$pspecies="Centaurea biebersteinii/spotted knapweed"}
if($weedname==8){$pspecies="Centaurea diffusa/white knapweed"}
if($weedname==9){$pspecies="Centaurea solstitialis/yellow star-thistle" }
if($weedname==10){$pspecies="Centaurea triumfettii/squarrose knapweed"}
if($weedname==11){$pspecies="Chondrilla junce/hogbite" }	
if($weedname==12){$pspecies="Cirsium arvense/Canada thistle"}	
if($weedname==13){$pspecies="Cirsium vulgare/bull thistle"}	
if($weedname==14){$pspecies="Conium maculatum/poison hemlock"}	
if($weedname==15){$pspecies="Crupina vulgaris/common crupina"}	
if($weedname==16){$pspecies="Euphorbia escula/leafy spurge"}	
if($weedname==17){$pspecies="Hieraceum aurantiacum/orange hawkweed"}	
if($weedname==18){$pspecies="Hieracium caespitosum/meadow hawkweed"}
if($weedname==19){$pspecies="Hypericum perforatum/common St. Johnswort"}	
if($weedname==20){$pspecies="Isatis tinctoria/Dyer\"s woad"}
if($weedname==21){$pspecies="Leucanthemum vulgare/oxeye daisy"}	
if($weedname==22){$pspecies="Linaria dalmatica/Dalmatian toadflax"}	
if($weedname==23){$pspecies="Linaria vulgaris/butter and eggs"}	
if($weedname==24){$pspecies="Onopordum acanthium/Scotch cottonthistle"}	
if($weedname==25){$pspecies="Potentilla recta/sulphur cinquefoil"}	
if($weedname==26){$pspecies="Salvia aethiopis/Mediterranean sage"}	
if($weedname==27){$pspecies="Senecio jacobaca/stinking willie"}	
if($weedname==28){$pspecies="Sonchus arvensis/field sowthistle "}	
if($weedname==29){$pspecies="Sonchus asper/spiny sowthistle"}	
if($weedname==30){$pspecies="Taeniatherum caput-medusae/medusahead"}}
if($wepaflag==1){$pspecies=$species;}
}

##$species=param('species');
##$species=~ s/\b(\w)/\U$1/g;###capitalizing the first letter of each word

##if(($species=~m/" "/)||($species=~m/""/)||(not($species))){$pspecies="Plant";$wepaflag=2}
##else{$pspecies=$species;}

$sitepresence=param('site_presence');

if($sitepresence==1){$psitepresence="Yes"}
else{$psitepresence="No";$firenote[0]="<p>Plant did not accur on site, can not calculate survivorship";}

$plifeduration=param('life_duration');
$lifeduration=lc($plifeduration);
if($lifeduration=~/annual/){$firenote[1]="<p>Plant is an annual, it does not survive year to year";}

$plifeform=param('life_form');
$lifeform=lc($plifeform);

$rootloc=param('root_loc');
if($rootloc=~m/duff/){$prootloc="Duff"} 
else{$prootloc="Mineral Soil"} 

$budloc=param('bud_loc');
if($budloc=~m/stolon/){$pbudloc="Stolon"}
if($budloc=~m/crown/){$pbudloc="Root Crown"}
if($budloc=~m/rhizome/){$pbudloc="Rhizome"}
if($budloc=~m/bulb/){$pbudloc="Bulb"}

if($rootloc=~m/mineral/){$rootloc=$budloc;}

$vegrepro=param('veg_repro');


if($vegrepro==1){$pvegrepro="Yes"}
else{$pvegrepro="No"}

$weed=param('weed');

#if($pweed1=~/Yes/i){$weed=1;$pweed="Yes"}
#else{$weed=0;$pweed="No"}

if($weed==1){$pweed="Yes"}
else{$pweed="No"}

$sprouts=param('sprouts');

if($sprouts==1){$psprouts="Yes"}
else{$psprouts="No"}

$shadetol=param('shade_tol');

if($shadetol==0){$pshadetol="Intolerant"}  ## Intolerant
elsif($shadetol==1){$pshadetol="Moderate"} ## Moderate
elsif($shadetol==2){$pshadetol="Tolerant"} ## Tolerant

$seeddis=param('seed_dis');

if($seeddis==0){$pseeddis="Long Distance Dispersal"}     ## Lond Distance
elsif($seeddis==1){$pseeddis="Short Distance Dispersal"} ## Short Distance
elsif($seeddis==2){$pseeddis="Animal Dispersal"}              ## Animal
elsif($seeddis==3){$pseeddis="Gravity Dispersal"}             ## Gravity
elsif($seeddis==4){$pseeddis="Low Seed Production"}           ## Low Seed production
else{$pseeddis="Unknown"}                                     ## Unknown

$seedbanking=param('seed_banking');

if($seedbanking==1){$pseedbanking="Yes"}
elsif($seedbanking==0){$pseedbanking="No"}
else{$pseedbanking="Unknown"}

$refractory=param('Refractory');

if($refractory==2){$prefractory="Yes"}
else{$prefractory="No"}

########################################
## check for impossible conbination of #
## seedbank=no and refractory=yes      #
########################################

if(($refractory==2)&&($seedbanking==0))
{$seedbanking=1;
$pnote="for a seed to be sun activeded there must be seed banking,<br>your selection of seed bank no and refractory yes has been changed to seed banking yes and refractory yes";
$seedbankflag=1;
print "<p>$pnote";
}

#######################################################
# Treatments characteristics of selected treatments   #
#######################################################

for($j=0; $j<$numtreatments; $j++)
{
	if($treatmentsf[$j]==1)
	{$thincanopycoverm[$j]=param('canopy_cover1');
	 $mineralexpom[$j]=param('mineral_expo1');
	 $firecanopym[$j]=param('fire_canopy1');
	 $moisturecondm[$j]=param('moisture_cond1');
	 $timeofthinm=param('timing');
	 if($timeofthin==0){$ptimeofthin="One Year after Thinning";}   
	 elsif($timeofthin==-1){$ptimeofthin="More Than One Year after Thinning";}
	 $seasonalitym[$j]=param('season1');
	 if($seasonalitym[$j]==0){$ppseasonality[1]="No";}
	 elsif($seasonalitym[$j]==-1){$ppseasonality[1]="Yes";}  
	}
	if($treatmentsf[$j]==2)
	{$thincanopycoverm[$j]=param('canopy_cover2');
	 $mineralexpom[$j]=param('mineral_expo2');
	 $firecanopym[$j]=0;
	 $moisturecondm[$j]=13.6;
	 $seasonalitym[$j]=0;
	 if($seasonalitym[$j]==0){$ppseasonality[2]="No";}
	 elsif($seasonalitym[$j]==-1){$ppseasonality[2]="Yes";}
	}
	if($treatmentsf[$j]==3)
	{$thincanopycoverm[$j]=0;
	 $mineralexpom[$j]=0;
	 $firecanopym[$j]=param('fire_canopy3');
	 $moisturecondm[$j]=param('moisture_cond3');
	 $seasonalitym[$j]=param('season3');
	 if($seasonalitym[$j]==0){$ppseasonality[3]="No";}
	 elsif($seasonalitym[$j]==-1){$ppseasonality[3]="Yes";}
	}
	if($treatmentsf[$j]==4)
	{$thincanopycoverm[$j]=0;
	 $mineralexpom[$j]=0;
	 $firecanopym[$j]=param('fire_canopy4');
	 $moisturecondm[$j]=param('moisture_cond4');
	 $seasonalitym[$j]=param('season4');
	 if($seasonalitym[$j]==0){$ppseasonality[4]="No";}
	 elsif($seasonalitym[$j]==-1){$ppseasonality[4]="Yes";}
	}
}

########################################
## Print the values of varibles        #
## If $debug=1                         #
########################################

if ($debug) 
{
	print "<p>area $area";
	print "<p>startcanopy $startcanopy";
	print "<p>duffdepth $duffdepth";
###################################################	
	print "<p>species $species";
	print "<p>sitepresence $sitepresence";
	print "<p>lifeduration: $lifeduration ";
	print "<P>lifeform: $lifeform ";
	print "<P>rootloc $rootloc";
	print "<p>vegrepro $vegrepro";
	print "<p>weed $weed";
	print "<P>sprouts: $sprouts ";
	print "<p>shadetol: $shadetol ";
	print "<p>seeddis $seeddis";
	print "<p>seedbanking $seedbanking";
	print "<p>refractory $refractory";
###################################################
	print "<p>mineralexpom @mineralexpom";
	print "<p>timeofthin $timeofthin";
	print "<p>thincanopycover $thincanopycover";
	print "<p>moisturecondm @moisturecondm";
	print "<p>fireconopym @firecanopym";
###################################################
}

################################################################################
## HTML output of all initail stands condition and plant characteristics input  #
################################################################################
print<<"end";
<html>
 <head>
  <title>The Understory Response Model OutPut</title>
  <SCRIPT LANGUAGE="JavaScript" type="TEXT/JAVASCRIPT">
  <!--

 function popuphistory() {
    url = '';
    height=500;
    width=660;
    popupwindow = window.open(url,'popupwindow','toolbar=no,location=no,status=no,directories=no,menubar=no,scrollbars=yes,resizable=yes,width='+width+',height='+height);
    popupwindow.document.writeln('<html>')
    popupwindow.document.writeln(' <head>')
    popupwindow.document.writeln('  <title>The Understory Response Model version history</title>')
    popupwindow.document.writeln(' </head>')
    popupwindow.document.writeln(' <body bgcolor=white>')
    popupwindow.document.writeln('  <font face="tahoma, arial, helvetica, sans serif">')
    popupwindow.document.writeln('  <center>')
    popupwindow.document.writeln('   <h3>The Understory Response Model Input Version History</h3>')
    popupwindow.document.writeln('   <p>')
    popupwindow.document.writeln('   <table border=0 cellpadding=10>')
    popupwindow.document.writeln('    <tr>')
    popupwindow.document.writeln('     <th bgcolor=lightblue>Version</th>')
    popupwindow.document.writeln('     <th bgcolor=lightblue>Comments</th>')
    popupwindow.document.writeln('    </tr>')
    popupwindow.document.writeln('    <tr>')
    popupwindow.document.writeln('     <th valign=top bgcolor=lightblue>2004.09.24</th>')
    popupwindow.document.writeln('     <td>Beta release for Boise presentation</td>')
    popupwindow.document.writeln('    </tr>')
    popupwindow.document.writeln('   </table>')
    popupwindow.document.writeln('   <p>')
    popupwindow.document.writeln('  </font>')
    popupwindow.document.writeln('  </center>')
    popupwindow.document.writeln(' </body>')
    popupwindow.document.writeln('</html>')
    popupwindow.document.close()
    popupwindow.focus()
  }


  // end hide -->
  </SCRIPT>
 </head>
 <body>
  <font face="tahoma, arial, helvetica, sans serif">
   <table align="center" width="100%" border="0" ID="Table1">
    <tr>
     <td><img src="http:/fuels/urm/images/ceanothus12.jpg" alt="The Understory Response Model" align="left"></td>
     <td align="center">
      <font face="tahoma, arial, helvetica, sans serif">
       <hr>
       <h2>The Understory Response Model Calculations</h2>
       <!-- img src="/fswepp/images/underc.gif" border=0 width=532 height=34 -->
       <hr>
      </font>
     </td>
     <td><IMG src="http:/fuels/urm/images/knapweedt.jpg" alt="The Understory Response Model" align="right"></td>
    </tr>
   </table>
   <center>
    <h3>User Inputs</h3>
   </center>
   <br>
   <table align="center" border="2" cellpadding="5" cellspacing="5" ID="Table3">
    <caption>
     <b><h4>Initial Stands Conditions</h4></b>
    </caption>
    <tr>
     <th BGCOLOR="#006009">
      <font face="tahoma, arial, helvetica, sans serif" color="#99ff00">Size of Treated Area (acres):</font>
     </th>
     <th BGCOLOR="#006009">
      <font face="tahoma, arial, helvetica, sans serif" color="#99ff00">Starting<br>Canopy Cover (%):</font>
     </th>
     <th BGCOLOR="#006009">
      <font face="tahoma, arial, helvetica, sans serif" color="#99ff00">Average Duff Depth (inches)</font>
     </th>
    </tr>
    <tr>
     <td><font face="tahoma, arial, helvetica, sans serif">$parea</td>
     <td><font face="tahoma, arial, helvetica, sans serif">$startcanopy</td>
     <td><font face="tahoma, arial, helvetica, sans serif">$pduffdepth</td>
    </tr>
			</table>
		<br>
		<table align="center" border="2" cellpadding="5" cellspacing="5" ID="Table2">
			<caption>
				<b><font size="4">$pspecies Characteristics</font></b>
			</caption>
			<tr>
				
				<th BGCOLOR="#006009">
					<Font color="#99ff00">Plant Occurs On-site?</Font></th>
				<th BGCOLOR="#006009">
					<Font color="#99ff00">Life Span</Font></th>
				<th BGCOLOR="#006009">
					<Font color="#99ff00">Life Form</Font></th>
				<th BGCOLOR="#006009">
					<Font color="#99ff00">Root Location</Font></th>
				<th BGCOLOR="#006009">
					<Font color="#99ff00">Bud Location</Font></th>
				<th BGCOLOR="#006009">
					<Font color="#99ff00">Vegatative Reproduction?</Font></th>

			</tr>
			<tr>
				
				<td>$psitepresence</td>
				<td>$plifeduration</td>
				<td>$plifeform</td>
				<td>$prootloc</td>
				<td>$pbudloc</td>
				<td>$pvegrepro</td>

			</tr>
			<tr>
				<th  BGCOLOR="#006009">
					<Font color="#99ff00">Weed?</Font></th>
				<th BGCOLOR="#006009">
					<Font color="#99ff00">Sprouts?</Font></th>
				<th BGCOLOR="#006009">
					<Font color="#99ff00">Preferred Light Level</Font></th>
				<th colspan="1" BGCOLOR="#006009">
					<Font color="#99ff00">Seed Dispersal</Font></th>
				<th BGCOLOR="#006009">
					<Font color="#99ff00">Seed Bank?</Font></th>
				<th BGCOLOR="#006009">
					<Font color="#99ff00">Fire Stimulated Seeds?</Font></th>
			</tr>
			<tr>
				<td>$pweed</td>
				<td>$psprouts</td>
				<td>$pshadetol</td>
				<td colspan="1">$pseeddis</td>
				<td>$pseedbanking</td>
				<td>$prefractory</td>
			</tr>
		</table>
		<br>
		<br>
		<hr>
		<center><font size=6>Treatment Comparison</font></center>
		<br>
		<hr>
	</body>
</html>
end

######end Input output################################################################################


############################################################
## On Site and Off Site Colonizer Matrices                 #
##                                                         #
## selection of onsite and offsite colonization index      #
## Name:oncolindex  (if site presence calculates both)     #
##      offcolindex (if no site presence only offcolindex) #
## Dependency: Seed Dispersal (row)                        #
##             Area (col)                                  #
############################################################

$offsiteindex=0;
$onsiteindex=0;

if($seeddis==5)
{$poffsiteindex="Unknown";
}
else
{

############################################
# On Site Colonizer matrix                 #
############################################
##@onlongdis=(4,4,4);
##@onshortdis=(3,3,3);
##@onanimaldis=(2,2,2);
@onlongdis=(3,3,3);
@onshortdis=(2,2,2);
@ongravitydis=(1,1,1);
@onlowseeddis=(0.1,0.1,0.1);
@onsitecol=([@onlongdis],[@onshortdis],[@ongravitydis],[@onlowseeddis]);

############################################
# Off Site Colonizer matrix                #
############################################
##@offlongdis=(3,2,2);
##@offshortdis=(2,0.5,0.1);
##@offanimaldis=(1,0.5,0.1);
@offlongdis=(3,2,1);
@offshortdis=(1,0.5,0.1);
@offgravitydis=(0.1,0.1,0.1);
@offlowseeddis=(0.1,0.1,0.1);
@offsitecol=([@offlongdis],[@offshortdis],[@offgravitydis],[@offlowseeddis]);

	if($sitepresence==1)
	{
	$onsiteindex=$onsitecol[$seeddis][$area];
	$offsiteindex=$offsitecol[$seeddis][$area];
	}
	else
	{
	$offsiteindex=$offsitecol[$seeddis][$area];
	}
	if($indexdebug)
	{
	print "<b>seed dispersal is: </b>$pseeddis and <b>sitepresence is: </b>$sitepresence"; 
	print "<p><b>oncolindex is: </b> $onsiteindex <p><b>offsiteindex is: </b>$offsiteindex";
	}
if($offsiteindex==0.1){$poffsiteindex="Very, Very Low"}
if($offsiteindex==0.5){$poffsiteindex="Very Low"}
if($offsiteindex==1){$poffsiteindex="Low"}
if($offsiteindex==2){$poffsiteindex="Moderate"}
if($offsiteindex==3){$poffsiteindex="High"}

}
######################################################
## Model loop for the number of treatments selected  #
## begins here				                 #
##						                 #
######################################################

for($i=0; $i<$numtreatments; $i++)
{
#########################################
#setting  needed flags flags		#
#########################################

$treatmentflag=0;

#############################################################################
##Selection of treatment conditions 					    #
##                                  					    #
##treatmentsf[i]=1 and timeofthin=0 inplies treatmentcond=1		    #
## Thinning and Broadcast Burning (same year)				    #
##									    #
##treatmentsf[i]=1 and timeofthin=-1 inplies treatmentcond=2		    #
## Thinning and Broadcast Burning (year after)                              #
##									    #
##treatmentsf[i]=2 inplies treatmentcond=3				    #
## Thinning and Pile Burning						    #
## 									    #
##treatmentsf[i]=3 inplies treatmentcond=0				    #
## Prescribed Fire							    #
##									    #
##treatmentsf[i]=4 inplies treatmentcond=0				    #
## WildFire								    #
##									    #
#############################################################################


if(($treatmentsf[$i]==1)&&($timeofthin==0))
{$pouttitle="Thinning and Broadcast Burning"; 
$treatmentcond=1;
$surhead=" Fire";
$n=0;
}
if(($treatmentsf[$i]==1)&&($timeofthin==-1))
{$pouttitle="Thinning and Broadcast Burning"; 
$treatmentcond=2;
$surhead=" Fire";
$n=0;
}
if($treatmentsf[$i]==2)
{
$pouttitle="Thinning and Pile Burning";
$treatmentcond=3;
$surhead=" Thinning";
$n=1;
$treatmentflag=1;
}
#if(($thinning=~m/yes/)&&($slash=~m/pile/))
#{print "<p>In the area with piles";
#$treatmentcond=4;
#}
if($treatmentsf[$i]==3)
{$pouttitle="Prescribed Fire";
$treatmentcond=0;
$surhead=" Fire";
$n=1;
}
if($treatmentsf[$i]==4)
{$pouttitle="Wildfire";
$treatmentcond=0;
$surhead=" Fire";
$n=1;
}

if($indexdebug)
{
print "<p><b>the selected treatment conditions is: </b> $treatmentcond";
}

##########################################################
#Initialization of variables for each treatment loop     #
##########################################################

$mineralexpo=$mineralexpom[$i];
$thincanopycover=$thincanopycoverm[$i];
$moisturecond=$moisturecondm[$i];
$firecanopy=$firecanopym[$i];
$seasonality=$seasonalitym[$i];

########################################
## Heat Penetration process            #
########################################


###############################################
## Moisture Condition Clasification           #
## moisturedcond      j-index    name         #
##     13.6             0         wet         #
##     31               1         moderate    #
##     50.8             2         dry         #
##     72.7             3         very dry    #
###############################################
####clasification of moistercond with index j 

if($moisturecond==13.6){$j=0}    ##j index 0 for wet
elsif($moisturecond==31){$j=1}   ##j index 1 for moderate
elsif($moisturecond==50.8){$j=2} ##j index 2 for dry
else{$j=3}                       ##j index 3 for very dry

if($moisturecond==13.6){$pmoisturecond="Wet"}       ## wet
elsif($moisturecond==31){$pmoisturecond="Moderate"} ## moderate
elsif($moisturecond==50.8){$pmoisturecond="Dry"}    ## dry
else{$pmoisturecond="Very Dry"}                     ## very dry

if($indexdebug)
{
print "<b>the moisture condition is :</b>$pmoisturecond ($moisturecond)<p> <b>duffdepth is: </b>$pduffdepth";
}

###################################################
## Heat Penetration Matrix:                       #
##    depthoflethaltemp    index     name         #
##         un                0     unburned       #
##         vvl               1     very very low  #
##         vl                2      very low      #
##          l                3        low         #
##          m                4       moderate     #
##          h                5       high         #
##	   vh                6     very high      #
## Selection of Heat Penetration index            #
## Name:heatpentindex                             #
## Dependency: duffdepth (row)                    #
##             j-index (moisture condition col)   #
###################################################

@halfduff=(1,3,5,5);
@oneduff=(1,2,5,6);
@twoduff=(1,2,4,6);
@threeduff=(1,1,3,4);
@fourduff=(1,1,1,3);
@fiveduff=(1,1,1,1);
@sixduff=(2,2,2,3);
@heatpent=([@halfduff],[@oneduff],[@twoduff],[@threeduff],[@fourduff],[@fiveduff],[@sixduff]);
$heatpentindex=$heatpent[$duffdepth][$j];

if($heatpentindex==0){$pheatpentindex="unburned"}
elsif($heatpentindex==1){$pheatpentindex="very very low"}
elsif($heatpentindex==2){$pheatpentindex="very low"}
elsif($heatpentindex==3){$pheatpentindex="low"}
elsif($heatpentindex==4){$pheatpentindex="moderate"}
elsif($heatpentindex==5){$pheatpentindex="high"}
else{$pheatpentindex="very high"}

if($indexdebug)
{
print "<p><b>depth of lethal temp is: </b> $pheatpentindex and  $heatpentindex";
}

############################################
## REPRODUCTION TRACK                      #
############################################

######################################################
## Reproduction Seed Survivorship Matrix             #
##                                                   #
## Selection of Reproduction Seed Survivorship index #
## Name:reprosurvshipindex                           #
## Dependency: no seed banking (row)                 #
##             seed banking and no refractory (row)  #
##             refractory and seed banking (row)     #
##             depth of lethal temp (col)            #
######################################################

if($seedbanking==2){$storedseedindex[0]=99;$storedseedindex[1]=99;}
else
{
@noseedbank=(2,2,0.1,0.1,0.1,0.1,0.1);
@seedbank=(3,3,2,1,0.5,0.1,0.1);
@refracseed=(0.1,0.5,1,2,3,2,1);
@reproseedsurvship=([@noseedbank],[@seedbank],[@refracseed]);

if($seeddis==4){$storedseedindex[0]=0.1;$storedseedindex[1]=0.1;}
else
{
if($seedbanking==0)
{
	if(($treatmentcond==1)||($treatmentcond==2))
	{$storedseedindex[0]=$noseedbank[0];$pheatpentindexo="unburned"}
	else
	{$storedseedindex[0]=-99;
	$thinreproindex=1}
}
else
{
	if($refractory==2)
	{
		if(($treatmentcond==1)||($treatmentcond==2))
		{$storedseedindex[0]=$refracseed[0];$pheatpentindexo="unburned"}
		else
		{$storedseedindex[0]=-99;
		$thinreproindex=0}
	}
	else
	{
		if(($treatmentcond==1)||($treatmentcond==2))
		{$storedseedindex[0]=$seedbank[0];$pheatpentindexo="unburned"}
		else
		{$storedseedindex[0]=-99;
		$thinreproindex=2}
	}
}
if($indexdebug)
{
print "<p><b>the storedseedindex for year zero is: </b> $storedseedindex[0]";

}

####years 1,5,10
for($k=1)
{
	if($seedbanking==0)
	{
	if(($treatmentcond==3))
	{$storedseedindex[$k]=$noseedbank[0];$pheatpentindex="unburned"}
	else
	{$storedseedindex[$k]=$noseedbank[$heatpentindex];
	$thinreproindex=1}
	}
	else
	{
	if($refractory==2)
	{
		if(($treatmentcond==3))
		{$storedseedindex[$k]=$refracseed[0];$pheatpentindex="unburned"}
		else
		{$storedseedindex[$k]=$refracseed[$heatpentindex];
		$thinreproindex=0}
	}
	else
	{
		if(($treatmentcond==3))
		{$storedseedindex[$k]=$seedbank[0];$pheatpentindex="unburned"}
		else
		{$storedseedindex[$k]=$seedbank[$heatpentindex];
		$thinreproindex=2}
	}
	}

	if($indexdebug)
	{
	print "<p><b>the storedseedindex for years 1,5,10 is: </b> $storedseedindex[1]";
	}
}
}
}	
####################################################
## Calculation of Reproduction Total Mineral Soil  #
## Name: tminsoil                                  #
## Dependency: Fire alone                          #
##             thinning+broadcast+timming          #
##             thinning+pile+weed                  #
####################################################

@tminsoil=0.0;
if(($treatmentcond==1)||($treatmentcond==2))
	{$tminsoil[0]=$mineralexpo}
else
	{$tminsoil[0]=-99;}
for($k=1)
{
	if($treatmentcond==0)
	{$tminsoil[$k]=$moisturecond;}
	elsif(($treatmentcond==1) || ($treatmentcond==2))
	{$tminsoil[$k]=$moisturecond+$mineralexpo;}
	elsif($treatmentcond==3)
	{$tminsoil[$k]=$mineralexpo;}
}
####################################################
## Selection of Reproduction Mineral Soil index    #
## Name: minsoilindex                              #
##                                                 #
##  minsoilintervals    minsoil index              #
## 0<=tminsoil<25           1                      #
## 25<=tminsoil<50          2                      #
## 50<=tminsoil<75          3                      #
## tminsoil>=75             4                      #
####################################################

for($k=0; $k<=1; $k++)
{
	if($tminsoil[$k]<=0){$minsoilindex[$k]=0.1;}
	elsif(($tminsoil[$k] >0)&&($tminsoil[$k]<25)){$minsoilindex[$k]=1;}
	elsif(($tminsoil[$k] >=25)&&($tminsoil[$k]<50)){$minsoilindex[$k]=2;}
	elsif(($tminsoil[$k] >=50)&&($tminsoil[$k]<72)){$minsoilindex[$k]=3;}
	elsif($tminsoil[$k] >=72){$minsoilindex[$k]=4;}

	if($indexdebug)
	{
	print "<p><b>total mineral soil for reproduction in year $k is:</b> $tminsoil[$k] ";
	print "<p><b>the mineral soil index is:</b> $minsoilindex[$k] ";
	}
}

##########################################################
# Calculation of Reproduction final canopy Cover         #
## Name: fcanopycover                                    #
## fcanopycover=startcanopy-(thincanopycover+firecanopy);#
##                                                       #
## Selection of Canopy Cover Intervals                   #
##                                                       #
##  finalcoverinterval        index                      # 
##   0<=fcanopycover<34         0                        #
##   34<=fcanopycover<67        1                        #
##   67<=fcanopycover<=100      2                        #
##########################################################

if(($treatmentcond==1)||($treatmentcond==2))
	{$fcanopycover[0]=$thincanopycover;}  #####cn
else
	{$fcanopycover[0]=-99;}

	if((($fcanopycover[0]<0)||($fcanopycover[$k]>100))&&($fcanopycover[0]!=-99))
	{print "something is wrong with the canopy percentages";}
	if(($fcanopycover[0] >=0)&&($fcanopycover[0]<34)){$canopyinte[0]=0;$pcanopyinte="0-33";}
	elsif(($fcanopycover[0] >=34)&&($fcanopycover[0]<67)){$canopyinte[0]=1;$pcanopyinte="34-66";}
	elsif(($fcanopycover[0] >=67)&&($fcanopycover[0]<=100)){$canopyinte[0]=2;$pcanopyinte="67-100";}
	else{$canopyinte[0]=0;$pcanopyinte="NA";;}

for($k=1)
{
	if($treatmentcond==0) #fire alone
	{$fcanopycover[$k]=$firecanopy;}      #####cn
	elsif(($treatmentcond==1) || ($treatmentcond==2))
	{$fcanopycover[$k]=$firecanopy;}#####cn
	else
	{ $fcanopycover[$k]=$thincanopycover;}#####cn	

	if(($fcanopycover[$k]<0)||($fcanopycover[$k]>100))
	{print "something is wrong with the canopy percentages";}
	if(($fcanopycover[$k] >=0)&&($fcanopycover[$k]<34)){$canopyinte[$k]=0;$pcanopyinte="0-33";}
	elsif(($fcanopycover[$k] >=34)&&($fcanopycover[$k]<67)){$canopyinte[$k]=1;$pcanopyinte="34-66";}
	elsif(($fcanopycover[$k] >=67)&&($fcanopycover[$k]<=100)){$canopyinte[$k]=2;$pcanopyinte="67-100";}
	else{print "the total canopy is incorrect $fcanopycover[$k]";}
}

####################################################
## Selection of Reproduction Canopy Cover index    #
## Name: canopycoverind                            #
## Dependency: Shade Tolerance (row)               #
##             final canopy cover interval (col)   #
####################################################

for($k=0; $k<=1; $k++)
{
	@intolerant=(2,1,0.1);
	@moderate=(1,2,1);
	@tolerant=(0.1,1,2);
	@fcanopycoverm=([@intolerant],[@moderate],[@tolerant]);
	$canopycoverindex[$k]=$fcanopycoverm[$shadetol][$canopyinte[$k]];
	
######print "<p><b>the reproduction canopy cover index is:</b>$canopycoverindex[$k]";#####cn
	if($indexdebug)
	{
	print "<p><b>the fcanopycover in year $k is: </b>$fcanopycover[$k]";
	print "<p><b>the reproduction canopy cover index is:</b>$canopycoverindex[$k]";
	}
}

############################################
## SURVIVORSHIP TRACK                      #
############################################
######################################################
## Survivor Seed Survivorship Matrix                 #
##                                                   #
## Selection of Survivorship Seed Survivorship index #
## Name:susurvshipindex                              #
## Dependency: root location (row)                   #
##             depth of lethal temp (col)            #
##             life form (matrices categories)       #
##                                                   #
## Selection of Nutrient index                       #
## Name:nutrients                                    #
## Dependency: life form                             #
######################################################

###forb or grass
if(($lifeform=~m/grass/)||($lifeform=~m/forb/))
{
##$nutrients=1;
@frlduff=(-1,-99,-99,-99,-99,-99);
@frlstolon=(0,-1,-99,-99,-99,-99);
@frlcrown=(0,0,-1,-2,-3,-4);
@frlrhizone=(0,0,0,-1,-2,-3);
@frlbulb=(0,0,0,0,-1,-2);
@suseedsurvship=([@frlduff],[@frlstolon],[@frlcrown],[@frlrhizone],[@frlbulb]);
	if($rootloc=~m/duff/){$survivorFindex=$suseedsurvship[0][$heatpentindex-1];}
	elsif($rootloc=~m/stolon/){$survivorFindex=$suseedsurvship[1][$heatpentindex-1];}
	elsif($rootloc=~m/crown/){$survivorFindex=$suseedsurvship[2][$heatpentindex-1];}
	elsif($rootloc=~m/rhizome/){$survivorFindex=$suseedsurvship[3][$heatpentindex-1];}
	elsif($rootloc=~m/bulb/){$survivorFindex=$suseedsurvship[4][$heatpentindex-1];}
}

elsif($lifeform=~m/shrub/)
{
##$nutrients=0;
@srlduff=(-1,-99,-99,-99,-99,-99);
@srlstolon=(0,0,-1,-2,-3,-4);
@srlcrown=(0,0,0,-1,-2,-3);
@srlrhizone=(0,0,0,0,-1,-2);
@suseedsurvship=([@srlduff],[@srlstolon],[@srlcrown],[@srlrhizone]);
	if($rootloc=~m/duff/){$survivorFindex=$suseedsurvship[0][$heatpentindex-1];}
	elsif($rootloc=~m/stolon/){$survivorFindex=$suseedsurvship[1][$heatpentindex-1];}
	elsif($rootloc=~m/crown/){$survivorFindex=$suseedsurvship[2][$heatpentindex-1];}
	elsif($rootloc=~m/rhizome/){$survivorFindex=$suseedsurvship[3][$heatpentindex-1];}
}
else
{print "<p><b>your life form is a tree please used Fvs-FFE</b>";}

if($indexdebug)
{
print "<p><b>survivorFindex is:</b> $survivorFindex <p><b>lifeform is: </b>$lifeform";
##print "<p><b>nutrients is: </b> $nutrients";
}

##########################################################
## Calculation of Survivorship final canopy Cover        #
## Name: sufcanopycover                                  #
## fcanopycover=startcanopy-(thincanopycover+firecanopy);#
##                                                       #
## Selection of Canopy Cover Intervals                   #
##                                                       #
##  finalcoverinterval        index                      # 
##   0<=sufcanopycove<34         0                       #
##   34<=sufcanopycover<67       1                      #
##   67<=sufcanopycover<=100     2                      #
##########################################################


##########################################
## pre-fire canopy intervals             #
## Name:sucanopyinte                     #
## 0<=$startcanopy<33     sucanopyinte=0 #
## 33<=$startcanopy<67    sucanopyinte=1 #
## 67<=$startcanopy<=100  sucanopyinte=2 #
##########################################

if(($startcanopy>=0)&&($startcanopy<33)){$sucanopyinte=0;$psucanopyinte="0-33";}
elsif(($startcanopy>=33)&&($startcanopy<67)){$sucanopyinte=1;$psucanopyinte="33-67";}
elsif(($startcanopy>=67)&&($startcanopy<=100)){$sucanopyinte=2;$psucanopyinte="67-100";}

if($indexdebug)
{
print "<p><b>the start canopy is: </b> $startcanopy";
print "<p><b>the area is: </b> $parea";
print "<p><b>sucanopyinterval is: </b> $sucanopyinte";
}


###########calculation of changes

if(($treatmentcond==1)||($treatmentcond==2))
	{$change[0]=$startcanopy-$thincanopycover;
	if(($fcanopycover[0]<0)||($ fcanopycover[0]>100))
	{print "something is wrong with the canopy percentages";}
	if(($fcanopycover[0] >=0)&&($fcanopycover[0]<34)){$sufcanopyinte[0]=0;$pfcanopyinte="0-33";}
	elsif(($fcanopycover[0] >=34)&&($fcanopycover[0]<67)){$sufcanopyinte[0]=1;$pfcanopyinte="33-67";}
	elsif(($fcanopycover[0] >=67)&&($fcanopycover[0]<=100)){$sufcanopyinte[0]=2;$pfcanopyinte="67-100";}
	else{print "something";}
}#####cn
else
	{$change[0]=-99;}

for($k=1)
{
	if($treatmentcond==0) #fire alone
	{$change[$k]= $startcanopy-$firecanopy;}#####cn
	elsif(($treatmentcond==1) || ($treatmentcond==2))
	{$change[$k]= ($startcanopy-$firecanopy);}#####cn
	else
	{ $change[$k]= $startcanopy-$thincanopycover;}#####cn
	
	if(($fcanopycover[$k]<0)||($ fcanopycover[$k]>100))
	{print "something is wrong with the canopy percentages";}
	if(($fcanopycover[$k] >=0)&&($fcanopycover[$k]<34)){$sufcanopyinte[$k]=0;$pfcanopyinte="0-33";}
	elsif(($fcanopycover[$k] >=34)&&($fcanopycover[$k]<67)){$sufcanopyinte[$k]=1;$pfcanopyinte="33-67";}
	elsif(($fcanopycover[$k] >=67)&&($fcanopycover[$k]<=100)){$sufcanopyinte[$k]=2;$pfcanopyinte="67-100";}
	else{print "something";}
}

###############################################################
## Selection of Survivorship Canopy Cover index               #
## Name: sucanopycoverindex                                   #
## Dependency: Shade Tolerance (row)                          #
##             final canopy cover interval (col)              #
##             canopy change due to fire (matrices categories)#
###############################################################
######
for($k=0; $k<=1; $k++)

{
if($change[$k]<10){$sucanopycoverindex[$k]=0;$pcanopyduefire="<10";}

elsif(($change[$k]>=10)&&($change[$k]<34))
{
	if($sucanopyinte==0)
	{
	@suintolerant=(1,888,888);
	@sumoderate=(-2,888,888);
	@sutolerant=(-0.1,888,888);
	@sufcanopycover=([@suintolerant],[@sumoderate],[@sutolerant]);
	$sucanopycoverindex[$k]=$sufcanopycover[$shadetol][$sufcanopyinte[$k]];
	}
	elsif($sucanopyinte==1)
	{
	@suintolerant=(2,1,888);
	@sumoderate=(-2,1,888);
	@sutolerant=(-2,1,888);
	@sufcanopycover=([@suintolerant],[@sumoderate],[@sutolerant]);
	$sucanopycoverindex[$k]=$sufcanopycover[$shadetol][$sufcanopyinte[$k]];
	}
	elsif($sucanopyinte==2)
	{
	@suintolerant=(888,2,1);
	@sumoderate=(888,2,1);
	@sutolerant=(888,-2,1);
	@sufcanopycover=([@suintolerant],[@sumoderate],[@sutolerant]);
	$sucanopycoverindex[$k]=$sufcanopycover[$shadetol][$sufcanopyinte[$k]];
	}
$pcanopyduefire="10-34";
}

else
{
	if($sucanopyinte==0)
	{
	@suintolerant=(888,888,888);
	@sumoderate=(888,888,888);
	@sutolerant=(888,888,888);
	@sufcanopycover=([@suintolerant],[@sumoderate],[@sutolerant]);
	$sucanopycoverindex[$k]=$sufcanopycover[$shadetol][$sufcanopyinte[$k]];
	}
	elsif($sucanopyinte==1)
	{
	@suintolerant=(2,888,888);
	@sumoderate=(-2,888,888);
	@sutolerant=(-2,888,888);
	@sufcanopycover=([@suintolerant],[@sumoderate],[@sutolerant]);
	$sucanopycoverindex[$k]=$sufcanopycover[$shadetol][$sufcanopyinte[$k]];
	}
	elsif($sucanopyinte==2)
	{
	@suintolerant=(3,2,888);
	@sumoderate=(1,2,888);
	@sutolerant=(-3,-2,888);
	@sufcanopycover=([@suintolerant],[@sumoderate],[@sutolerant]);
	$sucanopycoverindex[$k]=$sufcanopycover[$shadetol][$sufcanopyinte[$k]];
	}
$pcanopyduefire="34-100";

}

if(($shadetol==1)&&(abs(100-($startcanopy+$fcanopycover[$k]))<=10))
{
$sucanopycoverindex[$k]=1;
}
if($indexdebug)
{
print "<p><b>sucanopycoverindex in year $k is: </b> $sucanopycoverindex[$k]";
print "<p><b>survivorship final canopy cover is: </b>$fcanopycover[$k] <b>the change is:</b>$change[$k]";
print "<p><b>the category due to canopy change is:</b>$pcanopyduefire <b>start canopy cover interval is:</b>$psucanopyinte";
print "<p><b>the shade tolerance is:</b>$pshadetol";
}

if($sucanopycoverindex[$k]==0){$psucanopycoverindex[$k]="No Change"}
elsif($sucanopycoverindex[$k]==-1){$psucanopycoverindex[$k]="Small Decrease"}
elsif($sucanopycoverindex[$k]==-2){$psucanopycoverindex[$k]="Moderate Decrease"}
elsif($sucanopycoverindex[$k]==-3){$psucanopycoverindex[$k]="Large Decrease"}
elsif($sucanopycoverindex[$k]==1){$psucanopycoverindex[$k]="Small Increase"}
elsif($sucanopycoverindex[$k]==2){$psucanopycoverindex[$k]="Moderate Increase"}
elsif($sucanopycoverindex[$k]==3){$psucanopycoverindex[$k]="Large Increase"}

}


####################################################
## Selection of Survivorship Mineral Soil index    #
## Name: suminsoilindex                            #
##                                                 #
##  minsoilintervals    minsoil index              #
##  0<=mineralexpo<8	       -0.5                #
##  8<=mineralexpo<16          -1                  #
## 16<=mineralexpo<24          -1.5                #
## mineralexpo>=24             -2                  #
####################################################

if(($mineralexpo >=0)&&($mineralexpo<8)){$survivorTindex=-0.5;$psurvivorTindex="0-7";$ppsurvivorTindex="Very Low"}
elsif(($mineralexpo >=8)&&($mineralexpo<16)){$survivorTindex=-1;$psurvivorTindex="8-15";$ppsurvivorTindex="Low"}
elsif(($mineralexpo >=16)&&($mineralexpo<24)){$survivorTindex=-1.5;$psurvivorTindex="16-24";$ppsurvivorTindex="Low/Moderate"}
elsif($mineralexpo >=24){$survivorTindex=-2;$psurvivorTindex="bigger than 24";$ppsurvivorTindex="Moderate"}

if(($mineralexpo >=0)&&($mineralexpo<25)){$thinsoilindex=1;$pthinsoilindex="0-25"}
elsif(($mineralexpo >=25)&&($mineralexpo<50)){$thinsoilindex=2;$pthinsoilindex="25-50"}
elsif(($mineralexpo >=50)&&($mineralexpo<75)){$thinsoilindex=3;$pthinsoilindex="50-75"}
elsif($mineralexpo >=75){$thinsoilindex=4;$pthinsoilindex="bigger than 75"}

if($indexdebug)
{
print "<p><b>the survivorTindex index is:</b> $survivorTindex";
print "<p><b>the mineral soil exposure from thinning is:</b>$mineralexpo";
print "<p><b>the mineral soil interval is: </b>$psurvivorTindex";
}

###############################################################
## Calculation of shrub damage index                          #
## Name: shdamageindex                                        #
###############################################################

	if(($lifeform=~m/shrub/)&&($sprouts==0)&&($treatmentcond<3)) {@shrubdamage=(-1,-999,-999,-999);
for($k=0; $k<=3; $k++)	{$shdamageindex[$k]=$shrubdamage[$k]}}
else {
@sdtreat0=(-99,-2,0,0);
@sdtreat1=(-1,-3,-1,0);
@sdtreat2=(-1,-2,0,0);
@sdtreat3=(-99,-1,0,0);
@sdtreat4=(-99,-99,-99,-99);
@shrubdamage=([@sdtreat0],[@sdtreat1],[@sdtreat2],[@sdtreat3],[@sdtreat4]);


for($k=0; $k<=3; $k++)
{
	$shdamageindex[$k]=$shrubdamage[$treatmentcond][$k];
	if($indexdebug)
	{
	print "<p>the damage indexes in year $k is:$shdamageindex[$k]";
	}
}}
###############################################################
## final calculation of total reproduction and Survivorship   #
## Name: reproduction survivorship                            #
##                                                            #
##                                                            #
##                                                            #
###############################################################

########################################
## Survivorship sum Calculation        #
########################################

########################################
## maturity condition	       #
########################################

	if((($lifeduration=~m/annual/)||($lifeduration=~m/biennial/))&&(($lifeform=~m/forb/)||($lifeform=~m/grass/)))
	{$maturitycond=0}
	if(($lifeduration=~m/perennial/)&&(($lifeform=~m/forb/)||($lifeform=~m/grass/)))
	{$maturitycond=1}
	if(($lifeduration=~m/perennial/)&&($lifeform=~m/shrub/))
	{$maturitycond=2}
	if($indexdebug)
	{
	print "<p><b>the maturitycond is:</b>$maturitycond";
	}

@mcond0=(1,1,1,1);
@mcond1=(5,5,1,1);
@mcond2=(10,10,2,1);
@maturitycondm=([@mcond0],[@mcond1],[@mcond2]);

for($k=0; $k<=3; $k++)
{
	$maturitytimeindex[$k]=$maturitycondm[$maturitycond][$k];
	$maturitytwoindex[$k]=1;
	if(($k==2)||($k==3))
	{$maturitytwoindex[$k]=$maturitycondm[$maturitycond][$k-1];}
	if($indexdebug)
	{
	print "<p><b>the maturity time index in year $k is:</b>$maturitytimeindex[$k]";
	print "<p><b>the maturity TWO index in year $k is:</b>$maturitytwoindex[$k]";
	}
}

if(($sitepresence==0)||($lifeduration=~m/annual/))
{
$survivorFindex=-99;$survivorTindex=-99;
}
if($survivorFindex==-99){$psurvivorsum= "<p><b>plant is not present</b>";$vegrepro=0;$pvegrepro="No";}

if((($lifeform=~m/shrub/)&&($sprouts==0))){$survivorFindex=-99;}

if($survivorFindex==-99){$psurvivorsum= "<p><b>plant is not present</b>";$vegrepro=0;$pvegrepro="No";}


if($sucanopycoverindex[0]<=0){$vegrepro0=0;$weed0=0;}
else{$vegrepro0=$vegrepro;$weed0=$weed;}
if($sucanopycoverindex[1]<=0){$vegrepro1=0;$weed1=0;}
else{$vegrepro1=$vegrepro;$weed1=$weed;}

$tpcpwpv=$survivorTindex+$sucanopycoverindex[0]+$weed0+$vegrepro0;
$tpcpwpvbz=$survivorTindex+$sucanopycoverindex[1]+$weed1+$vegrepro1+$seasonality;
$fpcpwpv=$survivorFindex+$sucanopycoverindex[1]+$weed1+$vegrepro1+$seasonality;
$fpcpwpvpt=$fpcpwpv+$survivorTindex;
$fpcpwpvpnpt=$fpcpwpv+$survivorTindex;
@treatsur0=(-99,$fpcpwpv,$fpcpwpv,$fpcpwpv);
@treatsur1=($tpcpwpv,$fpcpwpvpnpt,$fpcpwpvpt,$fpcpwpvpt);
@treatsur2=($tpcpwpv,$fpcpwpvpnpt,$fpcpwpvpt,$fpcpwpvpt);
@treatsur3=(-99,$tpcpwpvbz,$tpcpwpvbz,$tpcpwpvbz);
@treatsur4=(-99,-99,-99,-99);
@survivorsumm=([@treatsur0],[@treatsur1],[@treatsur2],[@treatsur3],[@treatsur4]);

for($k=0; $k<=3; $k++)
{
	if($lifeform=~m/shrub/)
	{$survivorsum[$k]=$survivorsumm[$treatmentcond][$k]+$shdamageindex[$k];}
	else{$survivorsum[$k]=$survivorsumm[$treatmentcond][$k];}
	
	if($indexdebug)
	{
	print "<p>the treatmencondition is:$treatmentcond";
	print "<p>the survivorship sum in year $k is:$survivorsum[$k]";
	print "<p>fpcpwpv is: $fpcpwpv equal $survivorFindex+$sucanopycoverindex[1]+$weed+$vegrepro ";
	print "<p>tpcpwpv is: $tpcpwpv equal $survivorTindex+$sucanopycoverindex[0]+$weed+$vegrepro ";
	}
}

########################################
## Reproduction sum Calculation        #
########################################

for($j=0; $j<=3; $j++)
{
if($canopycoverindex[0]==0.1){$reprosum[0]=0.01}
if(($canopycoverindex[1]==0.1)&&($j!=0)){$reprosum[$j]=0.01}
else
{
if($refractory==2) #refractory
{
if($storedseedindex[1]==0.1){$reprosum[$j]=0.01}
else{
$spmspc=$storedseedindex[1]*$minsoilindex[1]*$canopycoverindex[1];
@treatrepro0=(-99,$spmspc,$spmspc,$spmspc);
@treatrepro1=(0,$spmspc,$spmspc,$spmspc);
@treatrepro2=(0,$spmspc,$spmspc,$spmspc);
@treatrepro3=(-99,0,0,0);
@treatrepro4=(-99,0,0,0);
@reprosumm=([@treatrepro0],[@treatrepro1],[@treatrepro2],[@treatrepro3],[@treatrepro4]);

$reprosum[$j]=$reprosumm[$treatmentcond][$j]/$maturitytimeindex[$j];
	if($indexdebug)
	{
	print "<p>the refractory is:$refractory";
	print "<p>the repro sum in year $j is:$reprosum[$j]";
	print "<p>spmspc is: $spmspc";
	}
}
}##endofrefractoryif
else
{#####no refractory

##$sponpofpwzero=($storedseedindex[0]+$onsiteindex+$offsiteindex+$weed)*$minsoilindex[0]*$canopycoverindex[0];
##$sponpofpw=($storedseedindex[1]+$onsiteindex+$offsiteindex+$weed)*$minsoilindex[1]*$canopycoverindex[1];
##$onpoffps=$onsiteindex+$offsiteindex+$storedseedindex[1];


	if($survivorsum[$j]>=0)
	{

$adjoncolindex[$j]=$onsiteindex;
@templist0=sort($storedseedindex[0],$adjoncolindex[$j],$offsiteindex);####MEV
$max0=pop(@templist0);
@templist1=sort($storedseedindex[1],$adjoncolindex[$j],$offsiteindex);####MEV
$max1=pop(@templist1);

if($max0==0.1){$reprosum[0]=0.01}
if(($max1==0.1)&&($j!=0)){$reprosum[$j]=0.01}
else
{
$sponpofpwzero=($max0+$weed)*$minsoilindex[0]*$canopycoverindex[0];
$sponpofpw=($max1+$weed)*$minsoilindex[1]*$canopycoverindex[1];
$onpoffps=((($max1)+$weed)*1.4);
					
@bbtreatrepro0=(-99,$sponpofpw,$sponpofpw,$sponpofpw);
@bbtreatrepro1=($sponpofpwzero,$sponpofpw,$sponpofpw,$sponpofpw);
@bbtreatrepro2=($sponpofpwzero,$sponpofpw,$sponpofpw,$sponpofpw);
@bbtreatrepro3=(-99,$sponpofpw,$sponpofpw,$sponpofpw);
@bbtreatrepro4=(-99,0,$onpoffps,$onpoffps);
@bbtreprosumm=([@bbtreatrepro0],[@bbtreatrepro1],[@bbtreatrepro2],[@bbtreatrepro3],[@bbtreatrepro4]);

		
		if($lifeduration=~m/perennial/)
		{$reprosum[$j]=$bbtreprosumm[$treatmentcond][$j]/$maturitytimeindex[$j];
			if($treatmentflag)
			{
			if($weed==1){$reprosum4[$j]=$bbtreprosumm[4][$j]*$canopycoverindex[1]/$maturitytimeindex[$j];}
		 	else{$reprosum4[$j]=$bbtreprosumm[4][$j]*$canopycoverindex[1]/$maturitytwoindex[$j];}
			if($indexdebug)
			{
			print "<p>the refractory is:$refractory";
			print "<p>the repro sum in year $j is:$reprosum[$j]";
			print "<p>reprosum4[$j] is: $reprosum4[$j]";
			print "<p>onpoffps is: $onpoffps";
			}
			}
		}##endperennial
		if($lifeduration=~m/biennial/)
		{$reprosum[$j]=$bbtreprosumm[$treatmentcond][$j]/$maturitytimeindex[$j];
			if(($j==2)){$reprosum[$j]=$reprosum[$j]/2*$maturitytimeindex[$j];}
			if(($j==3)){$reprosum[$j]=$reprosum[$j]/4*$maturitytimeindex[$j];}
			if($treatmentflag)
			{
			$reprosum4[$j]=$bbtreprosumm[4][$j]*$canopycoverindex[1];
		 	if($j==3){$reprosum4[$j]=$reprosum4[$j]/2;}
			if($indexdebug)
			{
			print "<p>the refractory is:$refractory";
			print "<p>the repro sum in year $j is:$reprosum[$j]";
			print "<p>reprosum4[$j] is: $reprosum4[$j]";
			}
			}
		}##endbiennial
		if($indexdebug)
		{
		print "<p>the refractory is:$refractory";
		print "<p>the repro sum in year $j is:$reprosum[$j]";
		print "<p>sponpofpwtmstc is: ($storedseedindex[1]+$onsiteindex+$offsiteindex+$weed)*$minsoilindex[1]*$canopycoverindex[1]";
		print "<p>lifeduration is: $lifeduration";
		}
	}##endelse0.1cond
	}####endifsurvibigzero
	else
	{
		if(abs($survivorsum[$j])<=$onsiteindex)
		{

$adjoncolindex[$j]=$onsiteindex+$survivorsum[$j];
@templist0=sort($storedseedindex[0],$adjoncolindex[$j],$offsiteindex);####MEV
$max0=pop(@templist0);
@templist1=sort($storedseedindex[1],$adjoncolindex[$j],$offsiteindex);####MEV
$max1=pop(@templist1);
if($max0==0.1){$reprosum[0]=0.01}
if(($max1==0.1)&&($j!=0)){$reprosum[$j]=0.01}
else
{

$sponpofpwzero=($max0+$weed)*$minsoilindex[0]*$canopycoverindex[0];
$sponpofpw=($max1+$weed)*$minsoilindex[1]*$canopycoverindex[1];
$onpoffps=$max1;

####$sponpofpwpsszero=$sponpofpwzero+$survivorsum[$j]*$minsoilindex[0]*$canopycoverindex[0];
$sponpofpwpsszero=$sponpofpwzero;
####$sponpofpwpss=$sponpofpw+$survivorsum[$j]*$minsoilindex[1]*$canopycoverindex[1];
$sponpofpwpss=$sponpofpw;
####$onpoffpwpss=$onpoffps+$weed+$survivorsum[$j];
$onpoffpwpss=(($onpoffps+$weed)*1.4);
@lesstreatrepro0=(-99,$sponpofpwpss,$sponpofpwpss,$sponpofpwpss);
@lesstreatrepro1=($sponpofpwpsszero,$sponpofpwpss,$sponpofpwpss,$sponpofpwpss);
@lesstreatrepro2=($sponpofpwpsszero,$sponpofpwpss,$sponpofpwpss,$sponpofpwpss);
@lesstreatrepro3=(-99,$sponpofpwpss,$sponpofpwpss,$sponpofpwpss);
@lesstreatrepro4=(-99,0,$onpoffpwpss,$onpoffpwpss);
@lessreprosumm=([@lesstreatrepro0],[@lesstreatrepro1],[@lesstreatrepro2],[@lesstreatrepro3],[@lesstreatrepro4]);

		
			if($lifeduration=~m/perennial/)
			{$reprosum[$j]=$lessreprosumm[$treatmentcond][$j]/$maturitytimeindex[$j];
				if($treatmentflag)
				{			if($weed==1){$reprosum4[$j]=$lessreprosumm[4][$j]*$canopycoverindex[1]/$maturitytimeindex[$j];}
		 	else{$reprosum4[$j]=($lessreprosumm[4][$j])*$canopycoverindex[1]/$maturitytwoindex[$j];}
			if($indexdebug)
			{
			print "<p>the refractory is:$refractory";
			print "<p>the repro sum in year $j is:$reprosum[$j]";
			print "<p>reprosum4[$j] is: $reprosum4[$j]";
			}
				}
			}
			if($lifeduration=~m/biennial/)
			{$reprosum[$j]=$lessreprosumm[$treatmentcond][$j]/$maturitytimeindex[$j];
				if(($j==2)){$reprosum[$j]=$reprosum[$j]/2*$maturitytimeindex[$j];}
				if(($j==3)){$reprosum[$j]=$reprosum[$j]/4*$maturitytimeindex[$j];}
				if($treatmentflag)
				{
		$reprosum4[$j]=$lessreprosumm[4][$j]*$canopycoverindex[1]/$maturitytimeindex[$j];		 			if($j==3){$reprosum4[$j]=$reprosum4[$j]/2;}
			if($indexdebug)
			{
			print "<p>the refractory is:$refractory";
			print "<p>the repro sum in year $j is:$reprosum[$j]";
			print "<p>reprosum4[$j] is: $reprosum4[$j]";
			}
				}
			}
			if($indexdebug)
			{
			print "<p>the treatmencondition is:$treatmentcond";
			print "<p>the repro sum in year $j is:$reprosum[$j]";
			print "<p>sponpofpwpsstmstc is: $sponpofpw+$survivorsum[$j]*$minsoilindex[1]*$canopycoverindex[1]";
			print "<p>lifeduration is: $lifeduration";
			}
		}##endelse0.1cond
		}######endifabslesseqon
		else
		{#####absbigeron

$adjoncolindex[$j]=0;

@templist0=sort($storedseedindex[0],$adjoncolindex[$j],$offsiteindex);####MEV
$max0=pop(@templist0);
@templist1=sort($storedseedindex[1],$adjoncolindex[$j],$offsiteindex);####MEV
$max1=pop(@templist1);
if($max0==0.1){$reprosum[0]=0.01}
if(($max1==0.1)&&($j!=0)){$reprosum[$j]=0.01}
else
{

####$spoffpwzero=($storedseedindex[0],$offsiteindex+$weed)*$minsoilindex[0]*$canopycoverindex[0];
####$spoffpw=($storedseedindex[1],$offsiteindex1+$weed)*$minsoilindex[1]*$canopycoverindex[1];
$spoffpwzero=($max0+$weed)*$minsoilindex[0]*$canopycoverindex[0];
$spoffpw=($max1+$weed)*$minsoilindex[1]*$canopycoverindex[1];

@bigtreatrepro0=(-99,$spoffpw,$spoffpw,$spoffpw);
@bigtreatrepro1=($spoffpwzero,$spoffpw,$spoffpw,$spoffpw);
@bigtreatrepro2=($spoffpwzero,$spoffpw,$spoffpw,$spoffpw);
@bigtreatrepro3=(-99,$spoffpw,$spoffpw,$spoffpw);
@bigtreatrepro4=(-99,0,($max1+$weed)*1.4*$canopycoverindex[1],($max1+$weed)*1.4*$canopycoverindex[1]);
@bigreprosumm=([@bigtreatrepro0],[@bigtreatrepro1],[@bigtreatrepro2],[@bigtreatrepro3],[@bigtreatrepro4]);

		
			if($lifeduration=~m/perennial/)
			{$reprosum[$j]=$bigreprosumm[$treatmentcond][$j]/$maturitytimeindex[$j];
########print "<p>reprosum[$j]is:$reprosum[$j]and maturitytimeindex is:$maturitytimeindex[$j]";
				if($treatmentflag)
				{
				if($weed==1){$reprosum4[$j]=$bigreprosumm[4][$j]/$maturitytimeindex[$j];}
			 	else{$reprosum4[$j]=($bigreprosumm[4][$j])/$maturitytwoindex[$j];}
			if($indexdebug)
			{
			print "<p>the refractory is:$refractory";
			print "<p>the repro sum in year $j is:$reprosum[$j]";
			print "<p>reprosum4[$j] is: $reprosum4[$j]";
			}
				}
			}
			if(($lifeduration=~m/biennial/)||($lifeduration=~m/annual/))
			{$reprosum[$j]=$bigreprosumm[$treatmentcond][$j]/$maturitytimeindex[$j];
				if(($j==2)){$reprosum[$j]=$reprosum[$j]/2*$maturitytimeindex[$j];}
				if(($j==3)){$reprosum[$j]=$reprosum[$j]/4*$maturitytimeindex[$j];}
				if($treatmentflag)
				{
				$reprosum4[$j]=$bigreprosumm[4][$j]/$maturitytimeindex[$j];
		 		if($j==3){$reprosum4[$j]=$reprosum4[$j]/2;}
			if($indexdebug)
			{
			print "<p>the refractory is:$refractory";
			print "<p>the repro sum in year $j is:$reprosum[$j]";
			print "<p>reprosum4[$j] is: $reprosum4[$j]";
			}
				}
			}
			if($indexdebug)
			{
			print "<p>the repro sum in year $j is:$reprosum[$j]";
			print "<p>spoffpw is: $spoffpw and ($storedseedindex[1]+$offsiteindex+$weed)*$minsoilindex[1]*$canopycoverindex[1]";
print "<p>spoffzero $spoffpwzero and ($storedseedindex[0]+$offsiteindex+$weed)*$minsoilindex[0]*$canopycoverindex[0]";
			print "<p>lifeduration is: $lifeduration";
			}

		}##endelse0.1cond
		}#####end##absbigeron
	}##endeslesslessthanzero
}###endelsenorefrac
}###endelse0.1cond
}###endjdoloop
########################################
##   end of calculation		       #
########################################

########################################
##  output of calculations             #
########################################

@surheadingF=("One Year<br> after".$surhead,"Five Years <br>after".$surhead,"Ten Years<br> after".$surhead);

##if($nutrients==0){$ppnutrients="No"}
##else{$ppnutrients="Yes"}
##@pnutrients=(No,No,No,No);

if($treatmentsf[$i]==1){@ppseasonalitym=("No Fire",$ppseasonality[1],$ppseasonality[1],$ppseasonality[1])}
if($treatmentsf[$i]==3){@ppseasonalitym=("No Fire",$ppseasonality[3],$ppseasonality[3],$ppseasonality[3])}
if($treatmentsf[$i]==4){@ppseasonalitym=("No Fire",$ppseasonality[4],$ppseasonality[4],$ppseasonality[4])}


if($survivorFindex==0){$psurvivorFindex="No Change"}
elsif($survivorFindex==-1){$psurvivorFindex="Low"}
elsif($survivorFindex==-2){$psurvivorFindex="Moderate"}
elsif($survivorFindex==-3){$psurvivorFindex="High"}
elsif($survivorFindex==-4){$psurvivorFindex="Very High"}

if($survivorFindex==-99){@pfireinpact=("Very Large Decrease","Very Large Decrease","Very Large Decrease","Very Large Decrease");}
else{@pfireinpact=($psurvivorFindex,$psurvivorFindex,$psurvivorFindex,$psurvivorFindex);}

@ppsucanopycoverindex=($psucanopycoverindex[0],$psucanopycoverindex[1],$psucanopycoverindex[1],$psucanopycoverindex[1]);###EV

for($k=0; $k<=1; $k++)
{if($seedbanking==2){$ppstoredseedindex[$k]="Unknown"}
else
{
if($storedseedindex[$k]==0.1){$ppstoredseedindex[$k]="Very, Very Low"}
if($storedseedindex[$k]==0.5){$ppstoredseedindex[$k]="Very Low"}
if($storedseedindex[$k]==1){$ppstoredseedindex[$k]="Low"}
if($storedseedindex[$k]==2){$ppstoredseedindex[$k]="Moderate"}
if($storedseedindex[$k]==3){$ppstoredseedindex[$k]="High"}
}
}
@pstoredseedindex=($ppstoredseedindex[0],$ppstoredseedindex[1],$ppstoredseedindex[1],$ppstoredseedindex[1]);

for($k=0; $k<=3; $k++)
{if($seeddis==5){$padjoncolindex[$k]="Unknown"}
else
{
if($adjoncolindex[$k]<=0.1){$padjoncolindex[$k]="Very, Very Low"}
if($adjoncolindex[$k]==0.5){$padjoncolindex[$k]="Very Low"}
if($adjoncolindex[$k]==1){$padjoncolindex[$k]="Low"}
if($adjoncolindex[$k]==2){$padjoncolindex[$k]="Moderate"}
if($adjoncolindex[$k]==3){$padjoncolindex[$k]="High"}
if($adjoncolindex[$k]==4){$padjoncolindex[$k]="Very High"}
}
}

for($k=0; $k<=1; $k++)
{
if($minsoilindex[$k]==0.1){$ppminsoilindex[$k]="Very, Very Low"}
if($minsoilindex[$k]==1){$ppminsoilindex[$k]="Low"}
if($minsoilindex[$k]==2){$ppminsoilindex[$k]="Moderate"}
if($minsoilindex[$k]==3){$ppminsoilindex[$k]="High"}
if($minsoilindex[$k]==4){$ppminsoilindex[$k]="Very High"}
}
@pminsoilindex=($ppminsoilindex[0],$ppminsoilindex[1],$ppminsoilindex[1],$ppminsoilindex[1]);

for($k=0; $k<=1; $k++)
{
if($canopycoverindex[$k]==0.1){$ppcanopycoverindex[$k]="Very, Very Low"}
if($canopycoverindex[$k]==1){$ppcanopycoverindex[$k]="Low"}
if($canopycoverindex[$k]==2){$ppcanopycoverindex[$k]="Moderate"}	# DEH 2005.01.28
if($canopycoverindex[$k]==3){$ppcanopycoverindex[$k]="High"}
}
@pcanopycoverindex=($ppcanopycoverindex[0],$ppcanopycoverindex[1],$ppcanopycoverindex[1],$ppcanopycoverindex[1]);

##if($treatmentcond==0){$pnutrients[1]=$ppnutrients;}
if(($treatmentcond==1)||($treatmentcond==2))
{
##$pnutrients[1]=$ppnutrients;
$pfireinpact[0]="No Fire";
}

for($k=0; $k<=3; $k++)
{
if($shdamageindex[$k]==0){$pshdamageindex[$k]="None"}
if(($shdamageindex[$k]==-1)){$pshdamageindex[$k]="Low"}
if(($shdamageindex[$k]==-2)){$pshdamageindex[$k]="Moderate"}
if(($shdamageindex[$k]==-3)){$pshdamageindex[$k]="High"}
if(($shdamageindex[$k]==-999)){$pshdamageindex[$k]="Very, Very High"}
}

for($k=0; $k<=3; $k++)
{
if($survivorsum[$k]<=-3.5){$psurvivorsum[$k]="Very Large Decrease"}
if(($survivorsum[$k]>-3.5)&&($survivorsum[$k]<=-2.5)){$psurvivorsum[$k]="Large Decrease"}
if(($survivorsum[$k]>-2.5)&&($survivorsum[$k]<=-1.5)){$psurvivorsum[$k]="Moderate Decrease"}
if(($survivorsum[$k]>-1.5)&&($survivorsum[$k]<=-0.5)){$psurvivorsum[$k]="Small Decrease"}
if(($survivorsum[$k]>-0.5)&&($survivorsum[$k]<0.5)){$psurvivorsum[$k]="No Change"}
if(($survivorsum[$k]>=0.5)&&($survivorsum[$k]<1.5)){$psurvivorsum[$k]="Small Increase"}
if(($survivorsum[$k]>=1.5)&&($survivorsum[$k]<2.5)){$psurvivorsum[$k]="Moderate Increase"}
if($survivorsum[$k]>=2.5){$psurvivorsum[$k]="Large Increase"}
}

for($k=0; $k<=3; $k++)
{
if(($seeddis==5)||($seedbanking==2)){$preprosum[$k]="Unknown"}
else
{
if(($reprosum[$k]<1.0)){$preprosum[$k]="Very, Very Low"}
if(($reprosum[$k]>=1.0)&&($reprosum[$k]<3.0)){$preprosum[$k]="Very Low"}
if(($reprosum[$k]>=3.0)&&($reprosum[$k]<9)){$preprosum[$k]="Low"}
if(($reprosum[$k]>=9)&&($reprosum[$k]<15)){$preprosum[$k]="Moderate"}
if(($reprosum[$k]>=15)&&($reprosum[$k]<=21)){$preprosum[$k]="High"}
if($reprosum[$k]>21){$preprosum[$k]="Very High"}
}
}
######################################



print<<"end2";
<html>
	<body>
<br><br>
		<center><font size=5 color=#006009><b>$pouttitle</b></font></center><br>
end2
print"		<center><font size=4 ><b>Treatment Inputs</b></font></center><br>";
###if($treatmentcond==3){print"<center><font size=4 ><b>Thinned Area</b></font></center><br>";}

if($treatmentsf[$i]==1)
{	 if($seasonalitym[$i]==0){$pseasonality="Dormant Season";}
	 elsif($seasonalitym[$i]==-1){$pseasonality="Growing Season";}
print<<"end_uno";
	<table align=center border=2 cellpadding=5 cellspacing=5 ID=Table2>
	<tr>
	<th BGCOLOR="#006009">
		<Font color="#99ff00">Canopy Cover after
		<br>
		 Thinning (%):</Font></th>
	<th BGCOLOR="#006009">
		<Font color="#99ff00">Mineral Soil Exposed<br>
		by Thinning (%):</Font></th>
	<th BGCOLOR="#006009">
		<Font color="#99ff00">Timing of 
		<br>
		Broadcast Burn:</Font></th>
	<th BGCOLOR="#006009">
		<Font color="#99ff00">Season of Burn:</Font></th>
	<th BGCOLOR="#006009">
		<Font color="#99ff00">Canopy Cover 
		<br>
		after Broadcast Burning (%):</Font></th>
	<th BGCOLOR="#006009">
		<Font color="#99ff00">Fuel Moisture:</Font></th>
	
	</tr>
	<tr>
		<td>$thincanopycover</td>
		<td>$mineralexpo</td>
		<td>$ptimeofthin</td>
		<td>$pseasonality</td>
		<td>$firecanopy</td>
		<td>$pmoisturecond</td>
	</tr>
	</table>
	<br>
	<center><font size=4 ><b>Treatment Outputs</b></font></center><br>
end_uno

}
if($treatmentsf[$i]==2)
{
print<<"end_dos";
	<table align=center border=2 cellpadding=5 cellspacing=5 ID=Table2>
	<tr>
	<th BGCOLOR="#006009">
		<Font color="#99ff00">Canopy Cover 
		<br>
		after Thinning (%):</Font></th>
	<th BGCOLOR="#006009">
		<Font color="#99ff00">Mineral Soil<br>
		Exposed by Thinning (%):</Font></th>
	</tr>
	<tr>
		<td>$thincanopycover</td>
		<td>$mineralexpo</td>
	</tr>
	</table>
	<br>
	<center><font size=4 ><b>Treatment Outputs</b></font></center><br>
end_dos

}
if(($treatmentsf[$i]==3)||($treatmentsf[$i]==4))
{	 if($seasonalitym[$i]==0){$pseasonality="Dormant Season";}
	 elsif($seasonalitym[$i]==-1){$pseasonality="Growing Season";}
print<<"end_tres";
	<table align=center border=2 cellpadding=5 cellspacing=5 ID=Table2>
	<tr>
	<th BGCOLOR="#006009">
		<Font color="#99ff00">Canopy Cover
		<br>
		after Fire (%):</Font></th>
	<th BGCOLOR="#006009">
		<Font color="#99ff00">Season of Burn:</Font></th>
	<th BGCOLOR="#006009">
		<Font color="#99ff00">Fuel Moisture:</Font></th>
	
	</tr>
	<tr>
		<td>$firecanopy</td>
		<td>$pseasonality</td>
		<td>$pmoisturecond</td>
	</tr>
	</table>
	<br>
	<center><font size=4 ><b>Treatment Outputs</b></font></center><br>
end_tres

}
if($treatmentcond==3){print"<center><font size=4 >Thinned Area</font></center><br>";}


print"		<table align=center border=2 cellpadding=5 cellspacing=5 ID=Table2>";

######survivorship talbe begining
if($sitepresence==1)
{
print"			<tr>
				<td><center><b>Survivorship Track</b></center></td>";
if(($treatmentcond==1)||($treatmentcond==2)){print"
				<th BGCOLOR=#006009>
				<Font color=#99ff00>One Year<br> after Thinning</Font></th>";}
print"
				<th BGCOLOR=#006009>
					<Font color=#99ff00>$surheadingF[0]</Font></th>";
print<<"end31";
				<th BGCOLOR=#006009>
					<Font color=#99ff00>$surheadingF[1]</Font></th>
				<th BGCOLOR=#006009>
					<Font color=#99ff00>$surheadingF[2]</Font></th>
			</tr>
end31
if($lifeduration=~m/annual/)
	{print"
			<tr>
				<th BGCOLOR=#99ff00>
				<Font color=#006009>Relative Change in Biomass <br>(Compared to Pre-Treatment)</Font></th>";
	print"<td colspan=4>The plant is an annual, it does not survive year to year</td>";
	print"		</tr>";
	print"		</table>
			<br>";
	}
else
{
if(($treatmentcond==1)||($treatmentcond==2)||($treatmentcond==3)){print"
			<tr>
				<th BGCOLOR=#006009>
					<Font color=#99ff00>Thinning Mortality</Font></th>";
for($k=$n; $k<=3; $k++){print"<td>$ppsurvivorTindex</td>";}
print"			</tr>";}
if(($treatmentcond==1)||($treatmentcond==2)||($treatmentcond==0)){print"
			<tr>
				<th BGCOLOR=#006009>
				<Font color=#99ff00>Fire Mortality</Font></th>";
for($k=$n; $k<=3; $k++){print"<td>$pfireinpact[$k]</td>";}
print"			</tr>";}

if($lifeform=~m/shrub/)
{
print"
			<tr>
				<th BGCOLOR=#006009>
				<Font color=#99ff00>Shrub Damage</Font></th>";
for($k=$n; $k<=3; $k++){print"<td>$pshdamageindex[$k]</td>";}
print"			</tr>";
}




if(($treatmentcond==1)||($treatmentcond==2)||($treatmentcond==0)){print"
			<tr>
				<th BGCOLOR=#006009>
				<Font color=#99ff00>Growing Season Fire?</Font></th>";
for($k=$n; $k<=3; $k++){print"<td>$ppseasonalitym[$k]</td>";}
print"			</tr>";}

print"			<tr>
				<th BGCOLOR=#006009>
				<Font color=#99ff00>Canopy Change Effect</Font></th>";
for($k=$n; $k<=3; $k++){print"<td>$ppsucanopycoverindex[$k]</td>";}
print"			</tr>";

##if(($treatmentcond==1)||($treatmentcond==2)||($treatmentcond==0)){print"
##			<!--<tr>
##				<th BGCOLOR=#006009>
##				<Font color=#99ff00>Nutrients? </Font></th>";
##for($k=$n; $k<=3; $k++){print"<td>$pnutrients[$k]</td>-->";}
##print"			</tr>";}
print"			<tr>
				<th BGCOLOR=#006009>
				<Font color=#99ff00>Clonal Growth?</Font></th>";
for($k=$n; $k<=3; $k++){print"<td>$pvegrepro</td>";}
print"			</tr>";
print"			<tr>
			<th BGCOLOR=#006009>
				<Font color=#99ff00>Weed?</Font></th>";
for($k=$n; $k<=3; $k++){print"<td>$pweed</td>";}
print"			</tr>";





	if(($lifeform=~m/shrub/)&&($sprouts==0)&&($survivorsum[1]<-80))
	{print"
			<tr>
				<th BGCOLOR=#99ff00>
				<Font color=#006009>Relative Change in Biomass <br>(Compared to Pre-Treatment)</Font></th>";
	if($n==0){print"<td>$psurvivorsum[0]</td>";
print"<td colspan=3>Fire top killed shrub, but shrub did not sprout, shrub did not survive</td>";}
	else{print"<td colspan=3>Fire top killed shrub, but shrub did not sprout, shrub did not survive</td>";}
	} 
	else
	{
print"
			<tr>
				<th BGCOLOR=#99ff00>
				<Font color=#006009>Relative Change in Biomass <br>(Compared to Pre-Treatment)</Font></th>";
for($k=$n; $k<=3; $k++){print"<td>$psurvivorsum[$k]</td>";}
print"		</tr>";
print"		</table>
		<br>";
	}
  }
}#end if site present
else
{
print"			<tr>
				<td><center><b>Survivorship Track</b></center></td>";
if(($treatmentcond==1)||($treatmentcond==2)){print"
				<th BGCOLOR=#006009>
				<Font color=#99ff00>One Year<br> after Thinning</Font></th>";}
print"
				<th BGCOLOR=#006009>
					<Font color=#99ff00>$surheadingF[0]</Font></th>";
print<<"end31";
				<th BGCOLOR=#006009>
					<Font color=#99ff00>$surheadingF[1]</Font></th>
				<th BGCOLOR=#006009>
					<Font color=#99ff00>$surheadingF[2]</Font></th>
			</tr>
end31
print"
			<tr>
				<th BGCOLOR=#99ff00>
				<Font color=#006009>Relative Change in Biomass <br>(Compared to Pre-Treatment)</Font></th>";
	print"<td colspan=4>The plant did not occur on site, can not calculate survivorship</td>";
	print"		</tr>";
	print"		</table>
			<br>";
}
#######
###survival report begin
if($sitepresence==0)
{
print"<p>The plant did not accur in the treatment area before fuels management. Therefore, there was no plant survival</p>";
}
else
{	if($lifeduration=~m/annual/)
	{print"<p>Annuals die at the end of the growing season; there is no year to year survival.</p>";
	}
	else
	{if($treatmentcond==3)
		{print "<p>Pile burning sterilizes the soil and delays plant establisment. Typically, weeds are the first plants to 		colonize areas that were burn piles.</p>";
		}
	else
		{if((($treatmentcond==0)||($treatmentcond==1)||($treatmentcond==2))&&($lifeform=~m/shrub/)&&($sprouts==0))
			{print "<p>The fire top killed the shrub and the plant was unable to sprout. Therefore, the shrub died.</p>";
			}
		else
		{if((($treatmentcond==0)||($treatmentcond==1)||($treatmentcond==2))&&($lifeform=~m/shrub/)&&($sprouts==1))
			{print "<p>The model assumes that fire top-kills shrubs and even without fire mortality, it takes more than one growing season for the shrub to recover pre-fire bromass.</p>";
			}
		if(($shadetol==2)&&($sucanopycoverindex[0]<0))
		{print "<p>The plant prefers low light levels. The treatment opened the canopy enough to reduce plant biomass</p>";
		}
		if(($shadetol==0)&&($sucanopycoverindex[0]>0))
		{print "<p>The plant prefers open canopy and high light levels. The treatment opened the canopy which increased plant growth.</p>";
		}
		if($survivorFindex<-1)
		{
		print"<p>The fire was so severe that it caused significant plant mortality. To reduce mortality, burn under less severe conditions (e.g., when fuel moistures are higher or in the dormant season)</p>";
		}
		if($survivorTindex<-1)
		{
		print"<p>The thinning caused significant plant mortality. To reduce mortality, alter the thinning prescripton to reduce soil disturbance (e.g., thin when the ground is frozen or with snow pack, or use helicopter removal)</p>";
		}
		
		}
		}
	}
	
}

#####survival report end
###reproduction table begining
print"		</table>
		<br>";
print<<"end5";
		<table align="center" border="2" cellpadding="5" cellspacing="5">
			<tr>
				<td><center><b>Reproduction Track</b></center></td>
end5
if(($treatmentcond==1)||($treatmentcond==2)){print"
				<th BGCOLOR=#006009>
				<Font color=#99ff00>One Year<br>after Thinning</Font></th>";}
print<<"end51";
				<th BGCOLOR="#006009">
					<Font color="#99ff00">$surheadingF[0]</Font></th>
				<th BGCOLOR="#006009">
					<Font color="#99ff00">$surheadingF[1]</Font></th>
				<th BGCOLOR="#006009">
					<Font color="#99ff00">$surheadingF[2]</Font></th>
			</tr>
end51
print"			<tr>
				<th BGCOLOR=#006009>
				<Font color=#99ff00>Stored Seeds</Font></th>";
for($k=$n; $k<=3; $k++){print"<td>$pstoredseedindex[$k]</td>";}
print"			</tr>";
if($refractory==3){print"
			<tr>
				<th BGCOLOR=#006009>
				<Font color=#99ff00>On-Site Colonization</Font></th>";
for($k=$n; $k<=3; $k++){print"<td>$padjoncolindex[$k]</td>";}
print"			</tr>";}
if($refractory==3){print"<tr>
				<th BGCOLOR=#006009>
				<Font color=#99ff00>Off-Site Colonization</Font></th>";
for($k=$n; $k<=3; $k++){print"<td>$poffsiteindex</td>";}
print"			</tr>";}
if($refractory==3){print"<tr>
				<th BGCOLOR=#006009>
				<Font color=#99ff00>Weed?</Font></th>";
for($k=$n; $k<=3; $k++){print"<td>$pweed</td>";}
print"			</tr>";}
print"			<tr>
				<th BGCOLOR=#006009>
				<Font color=#99ff00>Mineral Soil Exposed</Font></th>";
for($k=$n; $k<=3; $k++){print"<td>$pminsoilindex[$k]</td>";}
print"			</tr>
			<tr>
				<th BGCOLOR=#006009>
				<Font color=#99ff00>Canopy Effect</Font></th>";
for($k=$n; $k<=3; $k++){print"<td>$pcanopycoverindex[$k]</td>";}
print"			</tr>
			<tr>
				<th BGCOLOR=#99ff00>
				<Font color=#006009>Reproductive Biomass</Font></th>";
for($k=$n; $k<=3; $k++){print"<td>$preprosum[$k]</td>";}
print<<"final";
			</tr>
		</table>
			<br>
final
#######################################
## beging of Report                    #
########################################
####print "<b>One year after thinning</b>";
if($refractory==2)
{print "<p>The plant has refractory seeds that need fire to stimulate germination.</p>";}
else
{	if($canopycoverindex[0]==0.01){print "<p>The light levels are not sufficient for seed germination and survival.</p>";}
	else{if($max0<1){print "<p>There are very few viable seeds available to recolonize the treatment area.</p>";}}
}
#####print "<b>One year after Burnning</b>";
###print "<p>storedseedindex[1] is $storedseedindex[1]</p>";
if($refractory==2)
{if($storedseedindex[1]<1)
	{print"<p>The plant has seeds that need to be stimulated to germinate by fire. There was either no fire or fire severity 		was too low to cause seed germination</p>";}
if($storedseedindex[1]>=1)
	{print "<p>The plants seeds were stimulated to germinate by the fire</p>";}
if($canopycoverindex[1]==0.01){print "<p>The light levels are not sufficient for seed germnination and survival.</p>";}
	else{if($max1<1){print "<p>There are very few viable seeds available to recolonize the treatment area.</p>";}
	     if($minsoilindex[1]<1){print "<p>There is a very little mineral soil available as a seed bid for seed germination</p>";}
	    if($canopycoverindex[1]<1){print "<p>The light levels are not appropriate for seed germination and survival</p>";}
	}
}
else
{	if($canopycoverindex[1]==0.01){print "<p>The light levels are not sufficient for seed germnination and survival.</p>";}
	else{if($max1<1){print "<p>There are very few viable seeds available to recolonize the treatment area.</p>";}
	     if($minsoilindex[1]<1){print "<p>There is a very little mineral soil available as a seed bid for seed germination</p>";}
	    if($canopycoverindex[1]<1){print "<p>The light levels are not appropriate for seed germination and survival</p>";}
	}
}

###############################444
if($treatmentflag)
{
for($k=0; $k<=3; $k++)
{
if(($seeddis==5)||($seedbanking==2)){$preprosum4[$k]="Unknown";}
else
{
if($reprosum4[$k]==0){$preprosum4[$k]="No Reproduction"}
if(($reprosum4[$k]>0)&&($reprosum4[$k]<1)){$preprosum4[$k]="Very, Very Low"}
if(($reprosum4[$k]>=1)&&($reprosum4[$k]<3)){$preprosum4[$k]="Very Low"}
if(($reprosum4[$k]>=3)&&($reprosum4[$k]<9)){$preprosum4[$k]="Low"}
if(($reprosum4[$k]>=9)&&($reprosum4[$k]<15)){$preprosum4[$k]="Moderate"}
if(($reprosum4[$k]>=15)&&($reprosum4[$k]<=21)){$preprosum4[$k]="High"}
if($reprosum4[$k]>21){$preprosum4[$k]="Very High"}
}
}
print<<"end92";
	<br><br>
		<center><font size=4 ><b>Treatment Outputs</b></font></center><br>
		<center><font size=4>Under Piles</font></center><br>
		<table align="center" border="2" cellpadding="5" cellspacing="5" ID="">
end92
######survivorship talbe begining
	if($sitepresence==1)
	{
	print"			<tr>
				<td><center><b>Survivorship Track</b></center></td>";
	print"
				<th BGCOLOR=#006009>
					<Font color=#99ff00>One Year<br> after fire</Font></th>";
	print"
				<th BGCOLOR=#006009>
					<Font color=#99ff00>Five Year<br> after fire</Font></th>
				<th BGCOLOR=#006009>
					<Font color=#99ff00>Ten Year<br> after fire</Font></th>
			</tr>";

	print"
			<tr>
				<th BGCOLOR=#99ff00>
				<Font color=#006009>Relative Change in Biomass <br>(Compared to Pre-Treatment)</Font></th>";
	print"<td colspan=3>Fire severity was so high that plants did not survive</td>";
	print"		</tr>";
	print"		</table>
			<br>";
	}
	else
	{
	print"			<tr>
				<td><center><b>Survivorship Track</b></center></td>";
	print"
				<th BGCOLOR=#006009>
					<Font color=#99ff00>One Year<br> after fire</Font></th>";
	print"
				<th BGCOLOR=#006009>
					<Font color=#99ff00>Five Year<br> after fire</Font></th>
				<th BGCOLOR=#006009>
					<Font color=#99ff00>Ten Year<br> after fire</Font></th>
			</tr>";
	print"
			<tr>
				<th BGCOLOR=#99ff00>
				<Font color=#006009>Relative Change in Biomass <br>(Compared to Pre-Treatment)</Font></th>";
	print"<td colspan=4>The plant did not occur on site, can not calculate survivorship</td>";
	print"		</tr>";
	print"		</table>
			<br>";
	}
####reproduction

print "<table align=center border=2 cellpadding=5 cellspacing=5>
	<tr>
	<td><center><b>Reproduction Track</b></center></td>";
print"
				<th BGCOLOR=#006009>
					<Font color=#99ff00>One Year<br> after fire</Font></th>";
	print"
				<th BGCOLOR=#006009>
					<Font color=#99ff00>Five Year<br> after fire</Font></th>
				<th BGCOLOR=#006009>
					<Font color=#99ff00>Ten Year<br> after fire</Font></th>
			</tr>";
####
print"			<tr>
				<th BGCOLOR=#006009>
				<Font color=#99ff00>Stored Seeds</Font></th>
				<td>None</td>";
for($k=$n+1; $k<=3; $k++){print"<td>$pstoredseedindex[$k]</td>";}
print"			</tr>";
if($refractory==3){print"
			<tr>
				<th BGCOLOR=#006009>
				<Font color=#99ff00>On-Site Colonization</Font></th>
				<td>None</td>";
for($k=$n+1; $k<=3; $k++){print"<td>$padjoncolindex[$k]</td>";}
print"			</tr>";}
if($refractory==3){print"<tr>
				<th BGCOLOR=#006009>
				<Font color=#99ff00>Off-Site Colonization</Font></th>
				<td>None</td>";
for($k=$n+1; $k<=3; $k++){print"<td>$poffsiteindex</td>";}
print"			</tr>";}
if($refractory==3){print"<tr>
				<th BGCOLOR=#006009>
				<Font color=#99ff00>Weed?</Font></th>
				<td>$pweed</td>";
for($k=$n+1; $k<=3; $k++){print"<td>$pweed</td>";}
print"			</tr>";}
##print"			<tr>
##				<th BGCOLOR=#006009>
##				<Font color=#99ff00>Mineral Soil Exposed</Font></th>
##				<td>Very High</td>";
##for($k=$n+1; $k<=3; $k++){print"<td>Very High</td>";}
print"			</tr>
			<tr>
				<th BGCOLOR=#006009>
				<Font color=#99ff00>Canopy Effect</Font></th>
				<td>$pcanopycoverindex[1]</td>";
for($k=$n+1; $k<=3; $k++){print"<td>$pcanopycoverindex[$k]</td>";}
print"			</tr>
			<tr>
				<th BGCOLOR=#99ff00>
				<Font color=#006009>Reproductive Biomass</Font></th>";
for($k=$n; $k<=3; $k++){print"<td>$preprosum4[$k]</td>";}
print"</tr>";
print"	</table>";

}
}
########################################
##  end of big loop		       #
########################################


########################################
##  FEIS writeup set up                #
########################################
#elena$indexpath="C:\\Inetpub\\Scripts\\fuels\\urm\\test\\FEIS_index.txt";
$indexpath="/plantsimulator/FEIS_index.txt";	# DEH
$indexpath="FEIS_index.txt";			# DEH
$indexname="FEIS_index.txt";

###print"<p> pspecies is $pspecies";
($sciname,$comname)=split '/',$pspecies;

if($debug)
{
print "<p>$sciname,$comname";
print "<p>wepaflag $wepaflag";
}
if($wepaflag==2){$feisspecies=$sciname}
if($wepaflag==1){$feisspecies=$species}

if($debug)
{
print "<p>feisspecies is $feisspecies";
}

if($debug)
{
print "the name of the species is: $species<br>";
print "this is the path to the file: $indexpath<br>";
print "the name of the index file is:$indexname<br>";
}

#$testpp="Agrostis exarata";
open (INDEXF, $indexpath)|| die("Error: files unopened!\n");
while(<INDEXF>)
{
@row=split(/\t/,$_);
#print "<p>$row[0]";
	if($row[0]=~m/$feisspecies/i)
	{
	$foldertest=$row[1];
	###print "<p>the folder test is $foldertest";
	print "<center>";
# print "<p>[<a href=/fuels/urm/FEIS_writeup/all_plants/$foldertest.html target=_popup>FEIS Summaries for the Chosen Species</a>]</p>";	# DEH
### error compiling ### 2005.01.25 ###
#print "<p>[<a href=/fuels/urm/FEIS_writeup/all_plants/$foldertest.html target=_popup>FEIS Summaries for <i>$species</i></a>]</p>";	# DEH
#</i></a>]</p>";
print "  <p>
    [<a href='/fuels/urm/FEIS_writeup/all_plants/$foldertest.html' target='_popup'><b>FEIS Summaries for <i>$feisspecies</i></b></a>]
   </p>
";	# DEH
	print "</center>";
	$pnotaflag=0;
	}
}
close(INDEXFILE);
  if($pnotaflag) {
    $pnota= "<br>There is not a summary for '<i>" . $feisspecies . "</i>' in FEIS";
    print "    <center><b>$pnota</b></center>\n";
  }

# print "	</body> ";			# 2005.01.31 DEH
print<<"end_ultimo";
    <INPUT type="hidden" name="tsize" value="$tsize">
    <br>
   </form>
   <P>
    <hr>
    <table border=0>
     <tr>
      <td valign="top" bgcolor="lightgoldenrodyellow">
       <font face="tahoma, arial, helvetica, sans serif" size=1>
        The Understory Response Model: <b>URM</b>
       </font>
      </td>
      <td valign="top">
       <a href="http://forest.moscowfsl.wsu.edu/fswepp/comments.html"><img src="/fswepp/images/epaemail.gif" align="right" border=0></a>
      </td>
     </tr>
     <tr>
      <td valign="top">
       <font face="tahoma, arial, helvetica, sans serif" size=1>
        The Understory Response Model input interface v.
        <a href="javascript:popuphistory()">2005.09.14</a>
        (for review only) by
        David Hall &amp; Elena Velasquez<br>
        Model developed by: Steve Sutherland and Melanie Miller<br>
        Team leader Elaine Kennedy Sutherland, USDA Forest Service, Rocky Mountain Research Station, Moscow, ID
end_ultimo


######the log stuff should go here I think

#       2004.12.13 DEH
  $wc  = `wc ../working/urm.log`;
  @words = split " ", $wc;
  $runs = @words[0];
  $mydate = &printdate;

  print "
        $mydate<br>
        <b>$runs</b> URM runs since January 31, 2005<br>
       </font>
      </td>
     </tr>
    </table>
 </body>
</html>
";

####    2004.12.13 DEH log the run

# print $species, date, IP

# Record run in log
     $host = $ENV{REMOTE_HOST};
     $host = $ENV{REMOTE_HOST};
     $host = $ENV{REMOTE_ADDR} if ($host eq '');
     $user_really=$ENV{'HTTP_X_FORWARDED_FOR'};
     $host = $user_really if ($user_really ne '');

#    $mydate = &printdate;
     open URMLOG, ">>../working/urm.log";
       print URMLOG "$host\t";
       printf URMLOG '%0.2d:%0.2d ', $hour, $min;
       print URMLOG @ampm[$ampmi],"  ",@days[$wday]," ",@months[$mon]," ",$mday,", ",$year+1900, "\t";
       print URMLOG $species,"\n";
     close URMLOG;

sub printdate {

   @months=qw(January February March April May June July August September October November December);
   @days=qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);
   $ampm[0] = "am";
   $ampm[1] = "pm";

   $ampmi = 0;
   ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime;
   if ($hour == 12) {$ampmi = 1}
   if ($hour > 12) {$ampmi = 1; $hour = $hour - 12}
   $thisyear = $year+1900;
   $result = sprintf "%0.2d:%0.2d ", $hour, $min;
   $result .= $ampm[$ampmi] . "  " . $days[$wday] . " " . $months[$mon];
   $result .= " $mday, $thisyear Pacific Time\n";
   return $result;
}


#if($seedbankflag)
#{
#print "<p>$pnote";
#}
