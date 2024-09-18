#!/usr/bin/perl
#!C:\Perl\bin\perl.exe T-w
#use strict;
use CGI ':standard';
##########################################
# code name: whrm2.pl                    #
##########################################            
$debug=0;
$hdebug=0;

# 2005.02.07 DEH correct spelling "misleding" and "contruibuting" in 'Summary of Analysis' section
#		 Removed font size 3; <p> to <br><br>
#		 added brackets around home range 'No information available' (see Abert's squirrel)
#		 change 'The home range...are...' to 'The home range...is'

$version = '2005.02.07';

print "Content-type: text/html\n\n";
my @enames;
my @evalues;
my @sump=(0,0,0,0,0);
my @animalresp=0;
my @feaflag=(1,1,1,1,1);
$totalrow=0;
######

if ($hdebug) {
  foreach my $name (param () ) {
    my @values= param ($name);
    my $evalues=$values;
    if ($hdebug) {
      print "<p><b>Key:</b>$name <b>
      Value(s) :</b>@values";
    }
  }
}


  @enames=param();
  $lengthenames=@enames;
  if ($lengthenames>=2) {
    for ($i=0; $i<=(@enames-2);$i++) {
      $evalues[$i]=param($enames[$i]);
      if ($evalues[$i]==-3){$pevalues[$i]="Greater than 70% Decrease"}
      if ($evalues[$i]==-2){$pevalues[$i]="41-70% Decrease"}
      if ($evalues[$i]==-1){$pevalues[$i]="11-40% Decrease"}
      if ($evalues[$i]==0){$pevalues[$i]="No Change (+/-10%)"}
      if ($evalues[$i]==1){$pevalues[$i]="11-40% Increase"}
      if ($evalues[$i]==2){$pevalues[$i]="41-70% Increase"}
      if ($evalues[$i]==3){$pevalues[$i]="Greater than 70% Increase"}
    }
    $action=pop(@enames);
  }
  else {
   $action=pop(@enames);
  }

  if ($debug) {
    print "<p>@enames";
    print "<p>@evalues";
    print "<p>@pevalues";
    print "<p>action is $action";
  }

#################################################
## uploading all information about the species  #
#################################################
  $taxgroup=param('taxgroup');
  $tax_group=param('tax_group');
  $species=param('species');
  $filename=param('filename');

  if ($debug) {
    print"<p>taxgroup is $taxgroup";
    print"<p>species is $species";
    print"<p>filename is $filename";
  }

###############################
## Habitat Features Vector    #
###############################

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

#$junk=chop($filename);
#$junk2=chop($taxgroup);

$spefilename = $filename.".txt";
# $spepath = "c:\\Inetpub\\Scripts\\fuels\\whrm\\species\\".$taxgroup."\\";
$spepath = 'species_new/'.$taxgroup.'/';		# 2005.02.01 DEH

if($action=~/matrix/){
################################################
## uploading all information about the species #
################################################

print<<"endf";
<html>
 <head>
  <title>Wildlife Habitat Response Model Output</title>
  <script language="javascript">
<!-- hide from old browsers...

 function popuphistory() {
    url = '';
    height=500;
    width=660;
    popupwindow = window.open(url,'popupwindow','toolbar=no,location=no,status=no,directories=no,menubar=no,scrollbars=yes,resizable=yes,width='+width+',height='+height);
    popupwindow.document.writeln('<html>')
    popupwindow.document.writeln(' <head>')
    popupwindow.document.writeln('  <title>Wildlife Habitat Response Model Input version history</title>')
    popupwindow.document.writeln(' </head>')
    popupwindow.document.writeln(' <body bgcolor=white>')
    popupwindow.document.writeln('  <font face="tahoma, arial, helvetica, sans serif">')
    popupwindow.document.writeln('  <center>')
    popupwindow.document.writeln('   <h3>Wildlife Habitat Response Model Input Version History</h3>')
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


// end of hiding -->
  </script>
 </head>
 <body>
  <font face="tahoma, arial, helvetica, sans serif">
 <table align="center" width="100%" border="0">
  <tr>
  <!--<td><img src="https://localhost/fuels/whrm/images/borealtoad3_Pilliod.jpg" alt="Wildlife Habitat Response Model" align="left"></td>-->
  <td><img src="/fuels/whrm/images/borealtoad3_Pilliod.jpg" alt="Wildlife Habitat Response Model" align="left"></td>

  <td align="center"><hr>
  <h2>Wildlife Habitat Response Model</h2>
  <img src="/fswepp/images/underc.gif" border=0 width=532 height=34>
  <hr>
  </td>
  <!--<td><img src="https://localhost/fuels/whrm/images/grayjay3_Pilliod.jpg" alt="Wildlife Habitat Response Model" align="right">-->
  <td><img src="/fuels/whrm/images/grayjay3_Pilliod.jpg" alt="Wildlife Habitat Response Model" align="right">

  </td>
  </tr>
 </table>
 <br>
 <center>
  <table align="center" border="2">
   <caption>
    <!--<b><font size="4">Wildlife Habitat Response Model</font></b>-->
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
#####eprint "<p>open comamd is:$spepath .$spefilename<br>";
open (sper_file, $spepath .$spefilename)|| die("Error: files unopened!\n");
while(<sper_file>)
{
if($_=~/Home/)
	{######eprint "the line in if is: $_";
	$range=<sper_file>;
	######eprint "<p> the range in if is $range";
	close (sper_file);
		chomp $range;							# 2005.02.07 DEH
		$range = '[' . $range . ']' if ($range =~ /no information/i);	# 2005.02.07 DEH
	}
}

######eprint "<p>the range is:$range<br>";
if ($range=~/no/){$fsent=""}
else{$fsent="The home range of $species is typically $range. "}			# 2005.02.07 DEH

open (spe_file, $spepath .$spefilename)|| die("Error: files unopened!\n");
while(<spe_file>) {
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

##$rr2=$fhabirow+$preavarow;
##if(($feaflag[1])&&($feaflag[2])){$animalresp[1]=-99}
##else
##{if($feaflag[1]){$animalresp[1]=($sum[1]+$sum[2])/($rr2-1);$totalrow=$totalrow+$rr2-1;}
##elsif($feaflag[2]){$animalresp[1]=($sum[1]+$sum[2])/($rr2-1);$totalrow=$totalrow+$rr2-1;}
##else{$animalresp[1]=($sum[1]+$sum[2])/$rr2;}
##$totalrow=$totalrow+$rr2;
##$divisorstand=$divisorstand+1;}

$rr2=$fhabirow;
if($feaflag[1]){$animalresp[1]=-99;}
else{$animalresp[1]=$sum[1]/$rr2;$totalrow=$totalrow+$rr2;$divisorstand=$divisorstand+1;}

$rr3=$preavarow;
if($feaflag[2]){$animalresp[2]=-99;}
else{$animalresp[2]=$sum[2]/$rr3;$totalrow=$totalrow+$rr3;$divisorstand=$divisorstand+1;}


$rr4=$avoprerow;
if($feaflag[3]){$animalresp[3]=-99}
else{$animalresp[3]=$sum[3]/$rr4;$totalrow=$totalrow+$rr4;$divisorstand=$divisorstand+1;}

$rr5=$refsherow;
if($feaflag[4]){$animalresp[4]=-99}
else{$animalresp[4]=$sum[4]/$rr5;$totalrow=$totalrow+$rr5;$divisorstand=$divisorstand+1;}
$rr6=$rr2+$rr3;

#################################################
##Uncertaintly calculation of change of sign in #
##dirction.					#
#################################################
@dirsize = ($#nestdir+1,$#fhabidir+1,$#preavadir+1,$#avopredir+1,$#refshedir+1);
@unflag=(0,0,0,0,0);
@snestdir=sort @nestdir;
if($snestdir[0]!=$snestdir[$#snestdir]){$unflag[0]=1}
@sfhabidir=sort @fhabidir;
if($sfhabidir[0]!=$sfhabidir[$#sfhabidi]){$unflag[1]=1}
@spreavadir=sort @preavadir;
if($spreavadir[0]!=$spreavadir[$#spreavadir]){$unflag[2]=1}
@savopredir=sort @avopredir;
if($savopredir[0]!=$savopredir[$#savopredir]){$unflag[3]=1}
@srefshedir=sort @refshedir;
if($srefshedir[0]!=$srefshedir[$#srefshedir]){$unflag[4]=1}


$psentence[0]="Negative";
$psentence[1]="Likely Negative";
$psentence[2]="Possibly Negative";
$psentence[3]="Minimal to None";
$psentence[4]="Possibly Positive";
$psentence[5]="Likely Positive";
$psentence[6]="Positive";


$upsentence[0]="Negative, but low confidence <font color=red >*</font>";
$upsentence[1]="Likely Negative, but low confidence <font color=red >*</font>";
$upsentence[2]="Possibly Negative, but low confidence<font color=red > *</font>";
$upsentence[3]="Minimal to None, but low confidence <font color=red >*</font>";
$upsentence[4]="Possibly Positive, but low confidence <font color=red >*</font>";
$upsentence[5]="Likely Positive, but low confidence<font color=red > *</font>";
$upsentence[6]="Positive, but low confidence <font color=red >*</font>";

$fpsentence[0]=" result in a negative effect ";
$fpsentence[1]=" likely result in a negative effect ";
$fpsentence[2]=" possibly result in a negative effect ";
$fpsentence[3]=" have minimal affect ";
$fpsentence[4]=" possibly result in a positive effect ";
$fpsentence[5]=" likely result in a positive effect ";
$fpsentence[6]=" result in a positive effect ";



for($i=0; $i<=4;$i++)
{
	if(($animalresp[$i]>=-3)&&($animalresp[$i]<-2)){
		if($unflag[$i]){$panimalresp[$i]=$upsentence[0];$fpsentence[$i]=$fpsentence[0];}
		else{$panimalresp[$i]=$psentence[0];$fpsentence[$i]=$fpsentence[0];}
	}
	elsif(($animalresp[$i]>=-2)&&($animalresp[$i]<-1)){
		if($unflag[$i]){$panimalresp[$i]=$upsentence[1];$fpsentence[$i]=$fpsentence[1];}
		else{$panimalresp[$i]=$psentence[1];$fpsentence[$i]=$fpsentence[1];}
	}
	elsif(($animalresp[$i]>=-1)&&($animalresp[$i]<-0.25)){
		if($unflag[$i]){$panimalresp[$i]=$upsentence[2];$fpsentence[$i]=$fpsentence[2];}
		else{$panimalresp[$i]=$psentence[2];$fpsentence[$i]=$fpsentence[2];}
	}
	elsif(($animalresp[$i]>=-0.25)&&($animalresp[$i]<=0.25)){
		if($unflag[$i]){$panimalresp[$i]=$upsentence[3];$fpsentence[$i]=$fpsentence[3];}
		else{$panimalresp[$i]=$psentence[3];$fpsentence[$i]=$fpsentence[3];}
	}
	elsif(($animalresp[$i]>0.25)&&($animalresp[$i]<=1)){
		if($unflag[$i]){$panimalresp[$i]=$upsentence[4];$fpsentence[$i]=$fpsentence[4];}
		else{$panimalresp[$i]=$psentence[4];$fpsentence[$i]=$fpsentence[4];}
	}
	elsif(($animalresp[$i]>1)&&($animalresp[$i]<=2)){
		if($unflag[$i]){$panimalresp[$i]=$upsentence[5];$fpsentence[$i]=$fpsentence[5];}
		else{$panimalresp[$i]=$psentence[5];$fpsentence[$i]=$fpsentence[5];}
	}
	elsif(($animalresp[$i]>2)&&($animalresp[$i]<=3)){
		if($unflag[$i]){$panimalresp[$i]=$upsentence[6];$fpsentence[$i]=$fpsentence[6];}
		else{$panimalresp[$i]=$psentence[6];$fpsentence[$i]=$fpsentence[6];}
	}
	else{$panimalresp[$i]="Not Available"; $fpsentence[$i]="Not Available"; }
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

#### 	2004.12.13 DEH log the run

# print $species, date, IP

# Record run in log
     $host = $ENV{REMOTE_HOST};
     $host = $ENV{REMOTE_ADDR} if ($host eq '');
     $user_really=$ENV{'HTTP_X_FORWARDED_FOR'};
     $host = $user_really if ($user_really ne '');

     $mydate = &printdate;
     open WIRMLOG, ">>../working/whrm.log";
       print WIRMLOG "$host\t";
       printf WIRMLOG '%0.2d:%0.2d ', $hour, $min;
       print WIRMLOG @ampm[$ampmi],"  ",@days[$wday]," ",@months[$mon]," ",$mday,", ",$year+1900, "\t";
       print WIRMLOG $species,"\n";
     close WIRMLOG;


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

#### 	2004.12.13 DEH log the run


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
							<font color="#99ff00">Change in Habitat <br>Element(s)<br>
						(user's selection)</font>
						</th>
						<th  bgcolor="#006009">
							<font color="#99ff00">Predicted Effects on<br>Habitat Suitability</font>
						</th>
						<th  bgcolor="#006009">
							<font color="#99ff00">Average Effect on<br>Habitat Suitability</font>
						</th>
					</tr>
					

fin
#########beginnig of copy
print <<"final";
					<tr>
						<th rowspan=$nestrow BGCOLOR="#006009">
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
			</tr>";
			##$pevaluesindex1=0;
			}
			else
			{
			print "<td>$habitatfeatures[$nestfeacode[$i]]</td>
			<td align=center>$pevalues[$i]</td>
			<td align=center>$pevaltimesdir[$i]</td>
			<td align=center rowspan=$rr1>$panimalresp[$i]</td>
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
						<th rowspan=$rr6 BGCOLOR="#006009">
							<Font color="#99ff00">Food Resources</Font></th>
						<th rowspan=$fhabirow BGCOLOR="#006009">
							<Font color="#99ff00">Foraging Habitat</Font></th>
fin1

for($i=0; $i<=$fhabirow-1;$i++)
{
	if($i==0){	if($fhabifeacode[$i]==-99)
			{
			 print "<td colspan=4 align=center>No Information Is Available</td>
			</tr>";}

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
			print "<td colspan=4 align=center>No Information Is Available</td>
			</tr>";
			##$pevaluesindex3=$pevaluesindex2;
			}
			else
			{
			print "<td>$habitatfeatures[$preavafeacode[$i]]</td>
			<td align=center>$pevalues[$pevaluesindex2+$i]</td>
			<td align=center>$pevaltimesdir[$pevaluesindex2+$i]</td>
			<td align=center rowspan=$rr3>$panimalresp[1]</td>
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
						<th rowspan=$avoprerow BGCOLOR="#006009">
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
			<td align=center rowspan=$rr4>$panimalresp[2]</td>
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
						<th rowspan=$refsherow BGCOLOR="#006009">
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
			<td align=center rowspan=$rr5>$panimalresp[3]</td>
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
print"				</table>";
@sunflag=sort @unflag;
$footnote=$sunflag[$#unflag];
if($footnote){
print"
<font color=red>*</font><font size=2 ><em>When the \"average predicted effect on habitat suitability\" includes some habitat elements
that positively influenced habitat suitability and others that negatively influenced habitat suitability, then the
average may be misleading. Due to this uncertainty, we recommend you consult a wildlife biologist regarding the relative
importance of each habitat element contributing to averages that have low confidence.</em></font>";
}

print <<"end1";


    <h4>Summary of Analysis</h4>

 <br><br>
 <!-- font size=3 -->  <!-- DEH -->
Current scientific literature suggests that the $species requires specific habitats and elements within those habitats for successful reproduction,
for places to forage for food and find adequate nutrition, for places to avoid predators, and as shelter from environmental extremes such as daily 
or seasonal weather fluctuations.
<br><br>
The effect of the fuel treatment on a species habitat is examined separately for each life history requirement.
The specified fuel treatment will $fpsentence[0] on the suitability of habitat for $species reproduction and will $fpsentence[1]
on the suitability of foraging habitat or food resources.
The fuel treatment will $fpsentence[2] on habitat suitable for avoiding predators and will 
$fpsentence[3] on habitat used as shelter from environmental hazards.
<br><br>
end1
  
print <<"end2";
<br>
$fsent
Species with home ranges smaller than the treatment area may experience population-level effects from the treatment.  
Alternatively, species with large home ranges may only use the treatment area in certain seasons or not at all.
It should be noted that even species with large home ranges may experience population-level effects of the treatment if the treatment has affected a critical habitat element that does
 not occur anywhere else or has lower quality in other parts of the surrounding forest.
<!-- /font -->  <!-- DEH -->
<br><br>

   To view general life history information or information about the studies used to develop this tool for your selected species, please use the "View Background Information" button.</p>
   <br>
   <center>
    <!-- form method="post" name="wildlifem3" action="https://localhost/Scripts/fuels/whrm/wildlifem2.pl" -->
    <form method="post" name="wildlifem3" action="/cgi-bin/fuels/whrm/whrm2.pl">
     <input type="hidden" value="$taxgroup" name="taxgroup">
     <input type="hidden" value="$species" name="species">
     <input type="hidden" value="$filename" name="filename">
     <input type="submit" value="View Background Information" ID="Submit1" NAME="literature">
    </form>
   </center>
   <br><br>
   <hr>

   <table border=0>
    <tr>
     <td valign="top" bgcolor="lightgoldenrodyellow">
      <font face="tahoma, arial, helvetica, sans serif" size=1>
       The Wildlife Habitat Response Model (<b>WHRM</b>)<br>
       version <a href="javascript:popuphistory()">$version</a>
       (for review only) by David Hall &amp; Elena Velasquez<br>
       Model Developed by David Pilliod<br>
       Team leader Elaine Kennedy Sutherland, USDA Forest Service, Rocky Mountain Research Station
      </font>
     </td>
     <td valign="top">
      <a href="https://forest.moscowfsl.wsu.edu/fswepp/comments.html"><img src="/fswepp/images/epaemail.gif" align="right" border=0></a>
     </td>
    </tr>
   </table>
  </font>	
 </body>
</html>
end2

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
  <title>Wildlife Habitat Response Model Literature Review</title>
 </head>
 <body>
   <center>
    <table align="center" border="2">
     <caption>
      <font size="5"><b>Wildlife Habitat Response Model Background Information<br> $species</b></font>
     </caption>
fin1
for($i=0; $i<=11;$i++)
{print"
     <tr>
      <th colspan=2 bgcolor=#006009>
       <font size=4 color=#99ff00>$litreview[(2*$i)]</font>
      </th>
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
<P>
   <hr>
    <table border=0>
     <tr>
      <td valign="top" bgcolor="lightgoldenrodyellow">
       <font face="tahoma, arial, helvetica, sans serif" size=1>
        The Wildlife Habitat Response Model: <b>WH</b><b>RM</b>
       </font>
      </td>
      <td valign="top">
       <a href="https://forest.moscowfsl.wsu.edu/fswepp/comments.html"<img src="/fswepp/images/epaemail.gif" align="right" border=0></a>
      </td>
     </tr>
     <tr>
      <td valign="top">
       <font face="tahoma, arial, helvetica, sans serif" size=1>
        Wildlife Habitat Response Model input interface v.
        <a href="javascript:popuphistory()"> 2005.01.12</a>
        (for review only) by
        David Hall &amp; Elena Velasquez<br>
	  Model Developed by: David Pilliod<br>
        Team leader Elaine Kennedy Sutherland, USDA Forest Service, Rocky Mountain Research Station, Moscow, ID
       </font>
</table>
	</body>
</html>
fin11
}
