#!/usr/bin/perl
#use strict;
use CGI ':standard';
##########################################
# code name: twhrm4.pl                    #
##########################################            

# Note: code problem before background information: BODY and HTML closed, then reopened.
# $spefile

$debug=0;
$hdebug=0;

# 2008.06.27 DEH change call for comments (fuels/comments.html to fswepp/comments.html as latter has more error-checking
# 2005.02.07 DEH correct spelling "misleding" and "contruibuting" in 'Summary of Analysis' section
#        Removed font size 3; <p> to <br><br>
#        added brackets around home range 'No information available' (see Abert's squirrel)
#        change 'The home range...are...' to 'The home range...is'

$version='2006.10.16';
# $version = '2005.03.23';

print "Content-type: text/html\n\n";
my @enames;
my @evalues;
my @sump=(0,0,0,0,0);
my @tpbsump=(0,0,0,0,0); ####treatment2 08/21/06
my @pfsump=(0,0,0,0,0); ####treatment3 08/21/06
my @wfsump=(0,0,0,0,0); ####treatment4 08/21/06

my @animalresp=0;
my @tpbanimalresp=0; ####treatment2 08/21/06
my @pfanimalresp=0; ####treatment3 08/21/06
my @wfanimalresp=0; ####treatment4 08/21/06

my @feaflag=(1,1,1,1,1);
my @tpbfeaflag=(1,1,1,1,1); ####treatment2 08/21/06
my @pffeaflag=(1,1,1,1,1); ####treatment3 08/21/06
my @wffeaflag=(1,1,1,1,1); ####treatment4 08/21/06


$totalrow=0;
$tpbtotalrow=0;
$pftotalrow=0;
$wftotalrow=0;

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
    print "<p>these are the enames @enames<br>";
    print "<p>these are the evalues @evalues<br>";
    print "<p>these are the pvalues @pevalues <br>";
    print "<p>this is the action is $action";
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

$tsize=param('tsize');
$tsize2=$tsize+2;
for($j=0; $j<$tsize; $j++)
{
if($j==0){$treatments[$j]=param('treatment0')}
elsif($j==1){$treatments[$j]=param('treatment1')}
elsif($j==2){$treatments[$j]=param('treatment2')}
else{$treatments[$j]=param('treatment3')}
}

for($j=0; $j<$tsize; $j++)
{
if( $treatments[$j]==1){ $nametreatment[$j]="Thinning <br>and<br> Broadcast Burning" }
elsif( $treatments[$j]==2){ $nametreatment[$j]="Thinning <br>and<br>Pile Burning" }
elsif( $treatments[$j]==3){ $nametreatment[$j]="Prescribed Fire" }
else{ $nametreatment[$j]="Wildfire" }
}

for($j=0; $j<$tsize; $j++)
{
if( $treatments[$j]==1){ $lnametreatment[$j]="Thinning and Broadcast Burning" }
elsif( $treatments[$j]==2){ $lnametreatment[$j]="Thinning and Pile Burning" }
elsif( $treatments[$j]==3){ $lnametreatment[$j]="Prescribed Fire" }
else{ $lnametreatment[$j]="Wildfire" }
}

$tempstring="<th bgcolor=\"#006009\"><font color=\"#99ff00\">";
$tempstring2="<a href=\"javascript:document.forms[";
$tempstring3="].submit()\" onMouseOver=\"window.status='Results for the individual treatment  (new window)';return true\" onMouseOut=\"window.status='Wildlife Habitat Response Model'; return true\" >";
$ftempstring="";

for($j=0; $j<$tsize; $j++)
{
$ftempstring=$ftempstring.$tempstring.$tempstring2.$j.$tempstring3.$nametreatment[$j]."</a></font></th>";
}

if ($debug)
{
print "<p>Number of treatments selected is: $tsize<br>";
print "<p>treatments are: @treatments";
}

for($j=0; $j<$tsize; $j++){
$size1[$j]=0;
$size2[$j]=0;
$size3[$j]=0;
$size4[$j]=0;
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

$spefilename = $filename.".txt";
#elena# $spepath = "c:\\Inetpub\\Scripts\\fuels\\whrm\\species\\".$taxgroup."\\";
$spepath = 'species/'.$taxgroup.'/';      # 2005.02.01 DEH
($comname,$sciname) = split '/', $species;
$sciname = substr($sciname,1);      # 2005.02.07 DEH get rid of first blank for printout

if($debug){
print " <p>comm $comname";
print "<p> sci $sciname";
}

####if($action=~/matrix/){


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
//////
function explain_predict() {
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
      newin.document.writeln('      <h3>Wildlife Habitat Response Model<br><br>Predicted Effects on Habitat</h3><br>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td></tr>')
      newin.document.writeln('   </table>')
      newin.document.writeln('  <i>Predicted Effects on Habitat</i> is calculated as the reported response of an organism or population (usually abundance) to increases in a habitat element.')
      newin.document.writeln('     <br>For example, if the abundance of tassel-eared squirrels is reported to be positively associated with large diameter live trees, then a decrease in large diameter trees will result in a negative effect')
      newin.document.writeln('     on habitat suitability for tassel-eared squirrels. See the test and table 2 and 3 of the User&#39s Guide for information on calculations and definitions of qualitative statements.')
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
function explain_average() {
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
      newin.document.writeln('      <h3>Wildlife Habitat Response Model<br><br>Weighted Average Effects on Habitat</h3><br>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td></tr>')
      newin.document.writeln('   </table>')
      newin.document.writeln('  <i>Weighted Average Effects on Habitat</i> is a weighted average of <i>Predicted Effects on Habitat Elements</i> where the weights are defined by the ratio of the number of papers that identify a habitat element and the total number of papers found that describe habitat associations for a given life history requirement. See the text and table 4 of the User&#39s Guide for information on calculations and definitions of qualitative statements.')
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
/////
function resultstbf() {
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
      newin.document.writeln('      <h3>Wildlife Habitat Response Model<br><br>Predicted Effects on Habitat Suitability</h3><br>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td></tr>')
      newin.document.writeln('   </table>')
      newin.document.writeln('  <i>Predicted Effects on Habitat Suitability</i> is calculated as the reported response of an organism or population, usually abundance, to increases in a habitat element.')
      newin.document.writeln('     <br>For example, if the abundance of tassel-eared squirrels is reported to be positively associated with large diamete live trees, then a decrease in large diameter trees will result in a negative effect')
      newin.document.writeln('     on habitat suitability for tassel-eared squirrels. See the test and table 2 and 3 of the User&#39s Guide for information on calculations and definitions of qualitative statements .')
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

/////

// end of hiding -->
  </script>
 </head>
 <body link="#99ff00" vlink="#99ff00" alink="#99ff00">
  <font face="tahoma, arial, helvetica, sans serif">
 <table align="center" width="100%" border="0">
  <tr>
  <!--<td><img src="https://localhost/fuels/whrm/images/borealtoad3_Pilliod.jpg" alt="Wildlife Habitat Response Model" align="left"></td>-->
  <td><img src="/fuels/whrm/images/borealtoad3_Pilliod.jpg" alt="Wildlife Habitat Response Model" align="left" withd="156" height="117"></td>

  <td align="center"><hr>
  <h2>Wildlife Habitat Response Model</h2>
  <h2> Comparison of Selected Fuel Treatments<h2/>
  <hr>
  </td>
  <!--<td><img src="https://localhost/fuels/whrm/images/grayjay3_Pilliod.jpg" alt="Wildlife Habitat Response Model" align="right">-->
  <td><img src="/fuels/whrm/images/grayjay3_Pilliod.jpg" alt="Wildlife Habitat Response Model" align="right" withd="156" heigth="117">

  </td>
  </tr>
 </table>
 <br>
 <center>
  <table align="center" border="2">
   <caption>
    <font >Click on fuel treatment titles to view details about specific predictions for habitat elements and life history requirements</font>
   </caption>
    <tr>
     <th BGCOLOR="#006009">
      <Font color="#99ff00">Taxonomic group:</Font></th>
     <td>$tax_group</td>
    </tr>
    <tr>
     <th BGCOLOR="#006009">
      <Font color="#99ff00">Species:</Font></th>
     <!--elena<td >$species</td>-->
     <td >$comname (<i>$sciname</i>)</td>
    </tr>
  </table>
  <br>
 </center>
 <!--</body>-->
<!--</html>-->
endf

if($debug)
{
print "<p>this is the file name: $spefilename\n";
print "<p>this is the path to the file: $spepath";
}

open (sper_file, $spepath .$spefilename)|| die("Error: files unopened!\n");
while(<sper_file>)
{
    if($_=~/Rank/) 
    {$_=<sper_file>; #Elena 03/18/2005
    @rankm=split(/,/,$_);
    }
    if($_=~/Home/)
    {
    $range=<sper_file>;
        chomp $range;                           # 2005.02.07 DEH
        $range = '[' . $range . ']' if ($range =~ /no information/i);   # 2005.02.07 DEH
    }
    if($_=~/Sources/)
    {
    $source=<sper_file>;
    close (sper_file);
       chomp $source;   
    }
}

if ($range=~/no/){$fsent=""}
else{$fsent="The home range of $species is typically $range. "}         # 2005.02.07 DEH

open (spe_file, $spepath .$spefilename)|| die("Error: files unopened!\n");
while(<spe_file>) {
    if($_=~/Literature/){close (spe_file);}
    if($_=~/Nestsite/)
    {$_=<spe_file>;
    @row=split(/:/,$_);
    $nestrow=(@row);
        for($i=0; $i<=(@row-1);$i++)
        {($nestfeacode[$i],$nestdir[$i])=split(/,/,$row[$i],2);
        }
    }
    elsif($_=~/Reprorank/)
    {$_=<spe_file>;
    @row=split(/:/,$_);
    $nestrowrank=(@row);
        for($i=0; $i<=(@row-1);$i++)
        {($nestrank1[$i],$nestrank2[$i])=split(/,/,$row[$i],2);
         if($debug){print"<p>nestrank1 is $nestrank1[$i] and nestrank2 is $nestrank2[$i] ";}}
    }
    elsif($_=~/Foraging Habitat/)
    {$_=<spe_file>;
    @row=split(/:/,$_);
    $fhabirow=(@row);
        for($i=0; $i<=(@row-1);$i++)
        {($fhabifeacode[$i],$fhabidir[$i])=split(/,/,$row[$i],2);
        }
    }
    elsif($_=~/Habitatrank/)
    {$_=<spe_file>;
    @row=split(/:/,$_);
    $fhabirowrank=(@row);
        for($i=0; $i<=(@row-1);$i++)
        {($fhabirank1[$i],$fhabirank2[$i])=split(/,/,$row[$i],2);
         if($debug){print"<p>fhabirank1 is $fhabirank1[$i] and fhabirank2 is $fhabirank2[$i] ";}}
    }
    elsif($_=~/Forage\/Prey Availability/)
    {$_=<spe_file>;
    @row=split(/:/,$_);
    $preavarow=(@row);
        for($i=0; $i<=(@row-1);$i++)
        {($preavafeacode[$i],$preavadir[$i])=split(/,/,$row[$i],2);
        }
    }
    elsif($_=~/Preyrank/)
    {$_=<spe_file>;
    @row=split(/:/,$_);
    $preavarowrank=(@row);
        for($i=0; $i<=(@row-1);$i++)
        {($preavarank1[$i],$preavarank2[$i])=split(/,/,$row[$i],2);
         if($debug){print"<p>preavarank1 is $preavarank1[$i] and preavarank2 is $preavarank2[$i] ";}}
    }
    elsif($_=~/Predator Avoidance/)
    {$_=<spe_file>;
    @row=split(/:/,$_);
    $avoprerow=(@row);
        for($i=0; $i<=(@row-1);$i++)
        {($avoprefeacode[$i],$avopredir[$i])=split(/,/,$row[$i],2);
        }
    }
    elsif($_=~/Avoidrank/)
    {$_=<spe_file>;
    @row=split(/:/,$_);
    $avoprerowrank=(@row);
        for($i=0; $i<=(@row-1);$i++)
        {($avoprerank1[$i],$avoprerank2[$i])=split(/,/,$row[$i],2);
         if($debug){print"<p>avoprerank1 is $avoprerank1[$i] and avoprerank2 is $avoprerank2[$i] ";}}
    }
    elsif($_=~/Refugia\/Shelter/)
    {$_=<spe_file>;
    @row=split(/:/,$_);
    $refsherow=(@row);
        for($i=0; $i<=(@row-1);$i++)
        {($refshefeacode[$i],$refshedir[$i])=split(/,/,$row[$i],2);
        }
    }
    elsif($_=~/Shelterrank/)
    {$_=<spe_file>;
    @row=split(/:/,$_);
    $refsherowrank=(@row);
        for($i=0; $i<=(@row-1);$i++)
        {($refsherank1[$i],$refsherank2[$i])=split(/,/,$row[$i],2);
         if($debug){print"<p>refsherank1 is $refsherank1[$i] and refsherank2 is $refsherank2[$i] ";}}
    }
    elsif($_=~/Coverrank/)
    {$_=<spe_file>;
    @row=split(/:/,$_);
    $refsherowrank=(@row);
        for($i=0; $i<=(@row-1);$i++)
        {($coverrank1[$i],$coverrank2[$i])=split(/,/,$row[$i],2);
         if($debug){print"<p>coverrank1 is $coverrank1[$i] and coverrank2 is $coverrank2[$i] ";}}
    }
}

close (spe_file);
################################################
##testing for features not being used  Elena 03/18/2005
################################################

@nestfeacode=featurecheck(@nestfeacode);
@fhabifeacode=featurecheck(@fhabifeacode);
@preavafeacode=featurecheck(@preavafeacode);
@avoprefeacode=featurecheck(@avoprefeacode);
@refshefeacode=featurecheck(@refshefeacode);

################################################
###finish features not being used
################################################

################################################
####creating covercategory Elena  03/18/2005
################################################
if(($avoprefeacode[0]==-99)&&($refshefeacode[0]==-99)){$coverfeacode[0]=-99;}
elsif(($avoprefeacode[0]==-99)&&($refshefeacode[0]!=-99)){@coverfeacode=@refshefeacode;@coverdir=@refshedir;}
elsif(($avoprefeacode[0]!=-99)&&($refshefeacode[0]==-99)){@coverfeacode=@avoprefeacode;@coverdir=@avopredir;}
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
$coverrow=(@coverfeacode);
if($debug)
{
print "<br>the coverrow is $coverrow<br>";
print "<br>the coverfeacode matrix is: @coverfeacode<br>";
print "<br>the coverdir matrix is: @coverdir<br>";
print "<br>the pevalesindex3 is: $pevaluesindex3<br>";
print "<br>the pevalesindex4 is: $pevaluesindex4<br>";
}

##########################
################################################
####reading information on the treatments Elena  05/18/2006
################################################

if(($nestrow==1)&&($nestfeacode[0]==-99)){$tnestrow=0}
else{$tnestrow=$nestrow}
if(($fhabirow==1)&&($fhabifeacode[0]==-99)){$tfhabirow=0}
else{$tfhabirow=$fhabirow}
if(($preavarow==1)&&($preavafeacode[0]==-99)){$tpreavarow=0}
else{$tpreavarow=$preavarow}
if(($coverrow==1)&&($coverfeacode[0]==-99)){$tcoverrow=0}
else{$tcoverrow=$coverrow}

$temprow=$tnestrow+$tfhabirow+$tpreavarow+$tcoverrow;

if($debug){
print "<br><b>tnestrow is $tnestrow</b><br>";
print "<br><b>tfhabirow is $tfhabirow</b><br>";
print "<br><b>tpreavarow is $tpreavarow</b><br>";
print "<br><b>tcoverrow is $tcoverrow</b><br>";
print "<br><b>temprow is $temprow</b><br>";
}

#######################################
##loading values user enter into each #
##matrix tbfevalues tbfpvalues etc    #
#######################################

for($k=0; $k<=$tsize-1; $k++)
{
    if($treatments[$k]==1){
  	for($i=0; $i< $temprow; $i++){
	$tbfenames[$i]=$enames[($k*$temprow)+$i];
    	$tbfevalues[$i]=$evalues[($k*$temprow)+$i];
#print"<p>the value of tbfevalues[$i] is $tbfevalues[$i]";
    	$tbfpevalues[$i]=$pevalues[($k*$temprow)+$i];
                    }}
    if($treatments[$k]==2){
  for($i=0; $i<$temprow; $i++){
	$tpbenames[$i]=$enames[($k*$temprow)+$i];
    	$tpbevalues[$i]=$evalues[($k*$temprow)+$i];
    	$tpbpevalues[$i]=$pevalues[($k*$temprow)+$i];
                    }}
    if($treatments[$k]==3){
  for($i=0; $i<$temprow; $i++){
	$pfenames[$i]=$enames[($k*$temprow)+$i];
    	$pfevalues[$i]=$evalues[($k*$temprow)+$i];
#print"<p>the value of pfevalues[$i] is $pfevalues[$i]";
    	$pfpevalues[$i]=$pevalues[($k*$temprow)+$i];
                    }}
    if($treatments[$k]==4){
  for($i=0; $i<$temprow; $i++){
	$wfenames[$i]=$enames[($k*$temprow)+$i];
    	$wfevalues[$i]=$evalues[($k*$temprow)+$i];
    	$wfpevalues[$i]=$pevalues[($k*$temprow)+$i];
                    }}

}

if($debug){
print "<p><b>tbfevalues is @tbfevalues</b><br>";
print "<p><b>tbfpevalues is @tbfpevalues</b><br>";
print "<p><b>tpbevalues is @tpbevalues</b><br>";
print "<p><b>tpbpevalues is @tpbpevalues</b><br>";
print "<p><b>pfevalues is @pfevalues</b><br>";
print "<p><b>wfevalues is @wfevalues</b><br>";
}
################################################
##staring calculations Elena 03/18/2005
################################################

for($k=0; $k<=$tsize-1,; $k++)
{ 
        for($i=0; $i<=$nestrow-1;$i++)
        {if($treatments[$k]==1){
         if($nestfeacode[$i]==-99){$sum[0]=0;$pevaluesindex1=0;$evaltimesdirnest[0]=0;}
         else{$evaltimesdir[$i]=$tbfevalues[$i]*$nestdir[$i];
         $evaltimesdirnest[$i]= $evaltimesdir[$i];
         $sum[0]=$sum[0]+$tbfevalues[$i]*$nestdir[$i]*($nestrank1[$i]/$rankm[1]);
         $pevaluesindex1=$nestrow;
         $feaflag[0]=0;}
         if($debug){print"<p>nestcode is $nestfeacode[$i] and nestdir is $nestdir[$i] and product is $evaltimesdir[$i] ";
         print "<p>sum[0]is $sum[0] and pevaluesindex1 is $pevaluesindex1";}
         }
if($treatments[$k]==2){
         if($nestfeacode[$i]==-99){$tpbsum[0]=0;$tpbpevaluesindex1=0;$tpbevaltimesdirnest[0]=0;}
         else{$tpbevaltimesdir[$i]=$tpbevalues[$i]*$nestdir[$i];
         $tpbevaltimesdirnest[$i]= $tpbevaltimesdir[$i];
         $tpbsum[0]=$tpbsum[0]+$tpbevalues[$i]*$nestdir[$i]*($nestrank1[$i]/$rankm[1]);
         $tpbpevaluesindex1=$nestrow;
         $tpbfeaflag[0]=0;}
         if($debug){print"<p>nestcode is $nestfeacode[$i] and nestdir is $nestdir[$i] and product is $tpfevaltimesdir[$i] ";
         print "<p>sum[0]is $sum[0] and pevaluesindex1 is $pevaluesindex1";}
         }
if($treatments[$k]==3){
         if($nestfeacode[$i]==-99){$pfsum[0]=0;$pfpevaluesindex1=0;$pfevaltimesdirnest[0]=0;}
         else{$pfevaltimesdir[$i]=$pfevalues[$i]*$nestdir[$i];
         $pfevaltimesdirnest[$i]= $pfevaltimesdir[$i];
         $pfsum[0]=$pfsum[0]+$pfevalues[$i]*$nestdir[$i]*($nestrank1[$i]/$rankm[1]);
         $pfpevaluesindex1=$nestrow;
         $pffeaflag[0]=0;}
         if($debug){print"<p>nestcode is $nestfeacode[$i] and nestdir is $nestdir[$i] and product is $pfevaltimesdir[$i] ";
         print "<p>sum[0]is $sum[0] and pevaluesindex1 is $pevaluesindex1";}
         }
if($treatments[$k]==4){
         if($nestfeacode[$i]==-99){$wfsum[0]=0;$wfpevaluesindex1=0;$wfevaltimesdirnest[0]=0;}
         else{$wfevaltimesdir[$i]=$wfevalues[$i]*$nestdir[$i];
         $wfevaltimesdirnest[$i]= $wfevaltimesdir[$i];
         $wfsum[0]=$wfsum[0]+$wfevalues[$i]*$nestdir[$i]*($nestrank1[$i]/$rankm[1]);
         $wfpevaluesindex1=$nestrow;
         $wffeaflag[0]=0;}
         if($debug){print"<p>nestcode is $nestfeacode[$i] and nestdir is $nestdir[$i] and product is $wfevaltimesdir[$i] ";
         print "<p>sum[0]is $sum[0] and pevaluesindex1 is $pevaluesindex1";}
         }
        }
###########################
        for($i=0; $i<=$fhabirow-1;$i++)
        {if($treatments[$k]==1){
         if($fhabifeacode[$i]==-99){$sum[1]=0;$pevaluesindex2=$pevaluesindex1;$evaltimesdirfhabi[0]=0;}
         else{$evaltimesdir[$pevaluesindex1+$i]=$tbfevalues[$pevaluesindex1+$i]*$fhabidir[$i];
         $evaltimesdirfhabi[$i]=$evaltimesdir[$pevaluesindex1+$i];
         $sum[1]=$sum[1]+$tbfevalues[$pevaluesindex1+$i]*$fhabidir[$i]*($fhabirank1[$i]/$rankm[2]);
         $pevaluesindex2=$pevaluesindex1+$fhabirow;
         $feaflag[1]=0;}
         if($debug){print"<p>fhabicode is $fhabifeacode[$i] and fhabidir is $fhabidir[$i]";
         print "<p>sum[1]is $sum[1] and pevaluesindex2 is $pevaluesindex2";}
         }
if($treatments[$k]==2){
         if($fhabifeacode[$i]==-99){$tpbsum[1]=0;$tpbpevaluesindex2=$tpbpevaluesindex1;$tpbevaltimesdirfhabi[0]=0;}
         else{$tpbevaltimesdir[$tpbpevaluesindex1+$i]=$tpbevalues[$tpbpevaluesindex1+$i]*$fhabidir[$i];
         $tpbevaltimesdirfhabi[$i]=$tpbevaltimesdir[$tpbpevaluesindex1+$i];
         $tpbsum[1]=$tpbsum[1]+$tpbevalues[$tpbpevaluesindex1+$i]*$fhabidir[$i]*($fhabirank1[$i]/$rankm[2]);
         $tpbpevaluesindex2=$tpbpevaluesindex1+$fhabirow;
         $tpbfeaflag[1]=0;}
         if($debug){print"<p>fhabicode is $fhabifeacode[$i] and fhabidir is $fhabidir[$i]";
         print "<p>tpbsum[1]is $tpbsum[1] and pevaluesindex2 is $tpbpevaluesindex2";}
         }
if($treatments[$k]==3){
         if($fhabifeacode[$i]==-99){$pfsum[1]=0;$pfpevaluesindex2=$pfpevaluesindex1;$pfevaltimesdirfhabi[0]=0;}
         else{$pfevaltimesdir[$pfpevaluesindex1+$i]=$pfevalues[$pfpevaluesindex1+$i]*$fhabidir[$i];
         $pfevaltimesdirfhabi[$i]=$pfevaltimesdir[$pfpevaluesindex1+$i];
         $pfsum[1]=$pfsum[1]+$evalues[$pfpevaluesindex1+$i]*$fhabidir[$i]*($fhabirank1[$i]/$rankm[2]);
         $pfpevaluesindex2=$pfpevaluesindex1+$fhabirow;
         $pffeaflag[1]=0;}
         if($debug){print"<p>fhabicode is $fhabifeacode[$i] and fhabidir is $fhabidir[$i]";
         print "<p>pfsum[1]is $sum[1] and pfpevaluesindex2 is $pfpevaluesindex2";}
         }
if($treatments[$k]==4){
         if($fhabifeacode[$i]==-99){$wfsum[1]=0;$wfpevaluesindex2=$wfpevaluesindex1;$wfevaltimesdirfhabi[0]=0;}
         else{$wfevaltimesdir[$wfpevaluesindex1+$i]=$wfevalues[$wfpevaluesindex1+$i]*$fhabidir[$i];
         $wfevaltimesdirfhabi[$i]=$wfevaltimesdir[$wfpevaluesindex1+$i];
         $wfsum[1]=$wfsum[1]+$evalues[$wfpevaluesindex1+$i]*$fhabidir[$i]*($fhabirank1[$i]/$rankm[2]);
         $wfpevaluesindex2=$wfpevaluesindex1+$fhabirow;
         $wffeaflag[1]=0;}
         if($debug){print"<p>fhabicode is $fhabifeacode[$i] and fhabidir is $fhabidir[$i]";
         print "<p>wfsum[1]is $wfsum[1] and wfpevaluesindex2 is $wfpevaluesindex2";}
         }

        }
#############################
        for($i=0; $i<=$preavarow-1;$i++)
        {if($treatments[$k]==1){
         if($preavafeacode[$i]==-99){$sum[2]=0;$pevaluesindex3=$pevaluesindex2;$evaltimesdirpreava[0]=0;}
         else{$evaltimesdir[$pevaluesindex2+$i]=$tbfevalues[$pevaluesindex2+$i]*$preavadir[$i];
         $evaltimesdirpreava[$i]=$evaltimesdir[$pevaluesindex2+$i];
         $sum[2]=$sum[2]+$tbfevalues[$pevaluesindex2+$i]*$preavadir[$i]*($preavarank1[$i]/$rankm[3]);
         $pevaluesindex3=$pevaluesindex2+$preavarow;
         $feaflag[2]=0;}
         if($debug)
        {
        print"<p>preavacode is $preavafeacode[$i] and preavadir is $preavadir[$i] ";
        print"<p>evaltimesdirpreava is $evaltimesdirpreava[$i] ";
         print "<p>sum[2]is $sum[2] and pevaluesindex3 is $pevaluesindex3";}
         }

if($treatments[$k]==2){
         if($preavafeacode[$i]==-99){$tpbsum[2]=0;$tpbpevaluesindex3=$tpbpevaluesindex2;$tpbevaltimesdirpreava[0]=0;}
         else{$tpbevaltimesdir[$tpbpevaluesindex2+$i]=$tpbevalues[$tpbpevaluesindex2+$i]*$preavadir[$i];
         $tpbevaltimesdirpreava[$i]=$tpbevaltimesdir[$tpbpevaluesindex2+$i];
         $tpbsum[2]=$tpbsum[2]+$tpbevalues[$tpbpevaluesindex2+$i]*$preavadir[$i]*($preavarank1[$i]/$rankm[3]);
         $tpbpevaluesindex3=$tpbpevaluesindex2+$preavarow;
         $tpbfeaflag[2]=0;}
         if($debug)
        {
        print"<p>preavacode is $preavafeacode[$i] and preavadir is $preavadir[$i] ";
        print"<p>tpbevaltimesdirpreava is $tpbevaltimesdirpreava[$i] ";
         print "<p>tpbsum[2]is $tpbsum[2] and tpbpevaluesindex3 is $tpbpevaluesindex3";}
         }
if($treatments[$k]==3){
         if($preavafeacode[$i]==-99){$pfsum[2]=0;$pfpevaluesindex3=$pfpevaluesindex2;$pfevaltimesdirpreava[0]=0;}
         else{$pfevaltimesdir[$pfpevaluesindex2+$i]=$pfevalues[$pfpevaluesindex2+$i]*$preavadir[$i];
         $pfevaltimesdirpreava[$i]=$pfevaltimesdir[$pfpevaluesindex2+$i];
         $pfsum[2]=$pfsum[2]+$pfevalues[$pfpevaluesindex2+$i]*$preavadir[$i]*($preavarank1[$i]/$rankm[3]);
         $pfpevaluesindex3=$pfpevaluesindex2+$preavarow;
         $pffeaflag[2]=0;}
         if($debug)
        {
        print"<p>preavacode is $preavafeacode[$i] and preavadir is $preavadir[$i] ";
        print"<p>epfvaltimesdirpreava is $pfevaltimesdirpreava[$i] ";
         print "<p>pfsum[2]is $pfsum[2] and pfpevaluesindex3 is $pfpevaluesindex3";}
         }
if($treatments[$k]==4){
         if($preavafeacode[$i]==-99){$wfsum[2]=0;$wfpevaluesindex3=$pevaluesindex2;$wfevaltimesdirpreava[0]=0;}
         else{$wfevaltimesdir[$wfpevaluesindex2+$i]=$wfevalues[$wfpevaluesindex2+$i]*$preavadir[$i];
         $wfevaltimesdirpreava[$i]=$wfevaltimesdir[$wfpevaluesindex2+$i];
         $wfsum[2]=$sum[2]+$wfevalues[$wfpevaluesindex2+$i]*$preavadir[$i]*($preavarank1[$i]/$rankm[3]);
         $wfpevaluesindex3=$wfpevaluesindex2+$preavarow;
         $wffeaflag[2]=0;}
         if($debug)
        {
        print"<p>preavacode is $preavafeacode[$i] and preavadir is $preavadir[$i] ";
        print"<p>wfevaltimesdirpreava is $wfevaltimesdirpreava[$i] ";
         print "<p>wfsum[2]is $wfsum[2] and wfpevaluesindex3 is $wfpevaluesindex3";}
         }

        }
################################################
###end of calculation
################################################

for($i=0; $i<=$coverrow-1;$i++)
{
    if($treatments[$k]==1){
if($coverfeacode[$i]==-99){$sum[3]=0;$pevaluesindex4=$pevaluesindex3;$evaltimesdircover[0]=0;}
         else{$evaltimesdir[$pevaluesindex3+$i]=$tbfevalues[$pevaluesindex3+$i]*$coverdir[$i];
         $evaltimesdircover[$i]=$evaltimesdir[$pevaluesindex3+$i];
         $sum[3]=$sum[3]+$tbfevalues[$pevaluesindex3+$i]*$coverdir[$i]*($coverrank1[$i]/$rankm[4]);
         $pevaluesindex4=$pevaluesindex3+$coverrow;
         $feaflag[3]=0;}
         if($debug){
         print"<p>covercode is $coverfeacode[$i] and coverdir is $coverdir[$i] ";
         print "<p>sum[3]is $sum[3] and pevaluesindex3 is $pevaluesindex3+$i";
         }
    }
    if($treatments[$k]==2){
if($coverfeacode[$i]==-99){$tpbsum[3]=0;$tpbpevaluesindex4=$tpbpevaluesindex3;$tpbevaltimesdircover[0]=0;}
         else{$tpbevaltimesdir[$tpbpevaluesindex3+$i]=$tpbevalues[$tpbpevaluesindex3+$i]*$coverdir[$i];
         $tpbevaltimesdircover[$i]=$tpbevaltimesdir[$tpbpevaluesindex3+$i];
         $tpbsum[3]=$tpbsum[3]+$tpbevalues[$tpbpevaluesindex3+$i]*$coverdir[$i]*($coverrank1[$i]/$rankm[4]);
         $tpbpevaluesindex4=$tpbpevaluesindex3+$coverrow;
         $tpbfeaflag[3]=0;}
         if($debug){
         print"<p>covercode is $coverfeacode[$i] and coverdir is $coverdir[$i] ";
         print "<p>tpbsum[3]is $tpbsum[3] and tpbpevaluesindex3 is $tpbpevaluesindex3+$i";
         }
    }
    if($treatments[$k]==3){
if($coverfeacode[$i]==-99){$pfsum[3]=0;$pfpevaluesindex4=$pfpevaluesindex3;$pfevaltimesdircover[0]=0;}
         else{$pfevaltimesdir[$pfpevaluesindex3+$i]=$pfevalues[$pfpevaluesindex3+$i]*$coverdir[$i];
         $pfevaltimesdircover[$i]=$pfevaltimesdir[$pfpevaluesindex3+$i];
         $pfsum[3]=$pfsum[3]+$pfevalues[$pfpevaluesindex3+$i]*$coverdir[$i]*($coverrank1[$i]/$rankm[4]);
         $pfpevaluesindex4=$pfpevaluesindex3+$coverrow;
         $pffeaflag[3]=0;}
         if($debug){
         print"<p>covercode is $coverfeacode[$i] and coverdir is $coverdir[$i] ";
         print "<p>pfsum[3]is $pfsum[3] and pfpevaluesindex3 is $pfpevaluesindex3+$i";
         }
    }
    if($treatments[$k]==4){
if($coverfeacode[$i]==-99){$wfsum[3]=0;$wfpevaluesindex4=$wfpevaluesindex3;$wfevaltimesdircover[0]=0;}
         else{$wfevaltimesdir[$wfpevaluesindex3+$i]=$wfevalues[$wfpevaluesindex3+$i]*$coverdir[$i];
         $wfevaltimesdircover[$i]=$wfevaltimesdir[$wfpevaluesindex3+$i];
         $wfsum[3]=$wfsum[3]+$wfevalues[$wfpevaluesindex3+$i]*$coverdir[$i]*($coverrank1[$i]/$rankm[4]);
         $wfpevaluesindex4=$wfpevaluesindex3+$coverrow;
         $wffeaflag[3]=0;}
         if($debug){
         print"<p>covercode is $coverfeacode[$i] and coverdir is $coverdir[$i] ";
         print "<p>wfsum[3]is $wfsum[3] and wfpevaluesindex3 is $wfpevaluesindex3+$i";
         }
    }
}

}#end of K loop

################################################
##end of calculation including cover category
################################################

if($debug)
{
$sizeevaltimesdir=@evaltimesdir;
$tpbsizeevaltimesdir=@tpbevaltimesdir;
$pfsizeevaltimesdir=@pfevaltimesdir;
$wfsizeevaltimesdir=@wfevaltimesdir;
print "<p>sizeevaltimesdir is $sizeevaltimesdir";
print "<p>stpbizeevaltimesdir is $tpbsizeevaltimesdir";
print "<p>spfizeevaltimesdir is $pfsizeevaltimesdir";
print "<p>wfsizeevaltimesdir is $wfsizeevaltimesdir";
}

$rr1=$nestrow;
$rr2=$fhabirow;
$rr3=$preavarow;
$rr4=$coverrow; #Elena 03/18/2005

for($k=0; $k<=($tsize-1); $k++)
{ if($treatments[$k]==1){
    for($i=0; $i<=(@evaltimesdir-1);$i++)
    {   
        if($evaltimesdir[$i]==-3){$pevaltimesdir[$i]="Highly Negative";}
        if($evaltimesdir[$i]==-2){$pevaltimesdir[$i]="Moderately Negative";}
        if($evaltimesdir[$i]==-1){$pevaltimesdir[$i]="Slightly Negative";}
        if($evaltimesdir[$i]==0){$pevaltimesdir[$i]="Neutral";}
        if($evaltimesdir[$i]==1){$pevaltimesdir[$i]="Slightly Positive";}
        if($evaltimesdir[$i]==2){$pevaltimesdir[$i]="Moderately Positive";}
        if($evaltimesdir[$i]==3){$pevaltimesdir[$i]="Highly Positive";}

    }
    if($feaflag[0]){$animalresp[0]=-99;$totalrow=1;}
    else{$animalresp[0]=$sum[0]/$rr1;$totalrow=$totalrow+$rr1;$divisorstand=$divisorstand+1;}

    ##$rr2=$fhabirow;
    if($feaflag[1]){$animalresp[1]=-99;}
    else{$animalresp[1]=$sum[1]/$rr2;$totalrow=$totalrow+$rr2;$divisorstand=$divisorstand+1;}

    ##$rr3=$preavarow;
    if($feaflag[2]){$animalresp[2]=-99;}
    else{$animalresp[2]=$sum[2]/$rr3;$totalrow=$totalrow+$rr3;$divisorstand=$divisorstand+1;}

    ##$rr4=$coverrow; #Elena 03/18/2005
    if($feaflag[3]){$animalresp[3]=-99}
    else{$animalresp[3]=$sum[3]/$rr4;$totalrow=$totalrow+$rr4;$divisorstand=$divisorstand+1;}
  }
 if($treatments[$k]==2){
    for($i=0; $i<=(@tpbevaltimesdir-1);$i++)
    {
        if($tpbevaltimesdir[$i]==-3){$tpbpevaltimesdir[$i]="Highly Negative";}
        if($tpbevaltimesdir[$i]==-2){$tpbpevaltimesdir[$i]="Moderately Negative";}
        if($tpbevaltimesdir[$i]==-1){$tpbpevaltimesdir[$i]="Slightly Negative";}
        if($tpbevaltimesdir[$i]==0){$tpbpevaltimesdir[$i]="Neutral";}
        if($tpbevaltimesdir[$i]==1){$tpbpevaltimesdir[$i]="Slightly Positive";}
        if($tpbevaltimesdir[$i]==2){$tpbpevaltimesdir[$i]="Moderately Positive";}
        if($tpbevaltimesdir[$i]==3){$tpbpevaltimesdir[$i]="Highly Positive";}
    }
    if($tpbfeaflag[0]){$tpbanimalresp[0]=-99;$tpbtotalrow=1;}
    else{$tpbanimalresp[0]=$tpbsum[0]/$rr1;$tpbtotalrow=$tpbtotalrow+$rr1;$tpbdivisorstand=$tpbdivisorstand+1;}

    ##$rr2=$fhabirow;
    if($tpbfeaflag[1]){$tpbanimalresp[1]=-99;}
    else{$tpbanimalresp[1]=$tpbsum[1]/$rr2;$tpbtotalrow=$tpbtotalrow+$rr2;$tpbdivisorstand=$tpbdivisorstand+1;}

    ##$rr3=$preavarow;
    if($tpbfeaflag[2]){$tpbanimalresp[2]=-99;}
    else{$tpbanimalresp[2]=$tpbsum[2]/$rr3;$tpbtotalrow=$tpbtotalrow+$rr3;$tpbdivisorstand=$tpbdivisorstand+1;}

    ##$rr4=$coverrow; #Elena 03/18/2005
    if($tpbfeaflag[3]){$tpbanimalresp[3]=-99}
    else{$tpbanimalresp[3]=$tpbsum[3]/$rr4;$tpbtotalrow=$tpbtotalrow+$rr4;$tpbdivisorstand=$tpbdivisorstand+1;}
  }
if($treatments[$k]==3){
    for($i=0; $i<=(@pfevaltimesdir-1);$i++)
    {
        if($pfevaltimesdir[$i]==-3){$pfpevaltimesdir[$i]="Highly Negative";}
        if($pfevaltimesdir[$i]==-2){$pfpevaltimesdir[$i]="Moderately Negative";}
        if($pfevaltimesdir[$i]==-1){$pfpevaltimesdir[$i]="Slightly Negative";}
        if($pfevaltimesdir[$i]==0){$pfpevaltimesdir[$i]="Neutral";}
        if($pfevaltimesdir[$i]==1){$pfpevaltimesdir[$i]="Slightly Positive";}
        if($pfevaltimesdir[$i]==2){$pfpevaltimesdir[$i]="Moderately Positive";}
        if($pfevaltimesdir[$i]==3){$pfpevaltimesdir[$i]="Highly Positive";}
    }
    if($pffeaflag[0]){$pfanimalresp[0]=-99;$pftotalrow=1;}
    else{$pfanimalresp[0]=$pfsum[0]/$rr1;$pftotalrow=$pftotalrow+$rr1;$pfdivisorstand=$pfdivisorstand+1;}

    ##$rr2=$fhabirow;
    if($pffeaflag[1]){$pfanimalresp[1]=-99;}
    else{$pfanimalresp[1]=$pfsum[1]/$rr2;$pftotalrow=$pftotalrow+$rr2;$pfdivisorstand=$pfdivisorstand+1;}

    ##$rr3=$preavarow;
    if($pffeaflag[2]){$pfanimalresp[2]=-99;}
    else{$pfanimalresp[2]=$pfsum[2]/$rr3;$pftotalrow=$pftotalrow+$rr3;$pfdivisorstand=$pfdivisorstand+1;}

    ##$rr4=$coverrow; #Elena 03/18/2005
    if($pffeaflag[3]){$pfanimalresp[3]=-99}
    else{$pfanimalresp[3]=$pfsum[3]/$rr4;$pftotalrow=$pftotalrow+$rr4;$pfdivisorstand=$pfdivisorstand+1;}
  }
if($treatments[$k]==4){
    for($i=0; $i<=(@wfevaltimesdir-1);$i++)
    {
        if($wfevaltimesdir[$i]==-3){$wfpevaltimesdir[$i]="Highly Negative";}
        if($wfevaltimesdir[$i]==-2){$wfpevaltimesdir[$i]="Moderately Negative";}
        if($wfevaltimesdir[$i]==-1){$wfpevaltimesdir[$i]="Slightly Negative";}
        if($wfevaltimesdir[$i]==0){$wfpevaltimesdir[$i]="Neutral";}
        if($wfevaltimesdir[$i]==1){$wfpevaltimesdir[$i]="Slightly Positive";}
        if($wfevaltimesdir[$i]==2){$wfpevaltimesdir[$i]="Moderately Positive";}
        if($wfevaltimesdir[$i]==3){$wfpevaltimesdir[$i]="Highly Positive";}
    }
    if($wffeaflag[0]){$wfanimalresp[0]=-99;$wftotalrow=1;}
    else{$wfanimalresp[0]=$wfsum[0]/$rr1;$wftotalrow=$wftotalrow+$rr1;$wfdivisorstand=$wfdivisorstand+1;}

    ##$rr2=$fhabirow;
    if($wffeaflag[1]){$wfanimalresp[1]=-99;}
    else{$wfanimalresp[1]=$wfsum[1]/$rr2;$wftotalrow=$wftotalrow+$rr2;$wfdivisorstand=$wfdivisorstand+1;}

    ##$rr3=$preavarow;
    if($wffeaflag[2]){$wfanimalresp[2]=-99;}
    else{$wfanimalresp[2]=$wfsum[2]/$rr3;$wftotalrow=$wftotalrow+$rr3;$wfdivisorstand=$wfdivisorstand+1;}

    ##$rr4=$coverrow; #Elena 03/18/2005
    if($wffeaflag[3]){$wfanimalresp[3]=-99}
    else{$wfanimalresp[3]=$wfsum[3]/$rr4;$wftotalrow=$wftotalrow+$rr4;$wfdivisorstand=$wfdivisorstand+1;}
  }
}##end of k loop

$rr6=$rr2+$rr3;

#################################################
##Uncertaintly calculation of change of sign in #
##direction.                          #
#################################################
if($debug)
{
print "<p>rows are: $rr1 and $rr2 and $rr3 and $rr4 and $rr5<br>";
print "<p>evaltimesdirnest is: @evaltimesdirnest<br>";
print "<p>evaltimesdirfhabi is: @evaltimesdirfhabi<br>";
print "<p>evaltimesdirpreava is: @evaltimesdirpreava<br>";
print "<p>evaltimesdiravopre is: @evaltimesdiravopre<br>";
print "<p>evaltimesdirrefshe is: @evaltimesdirrefshe<br>";
print "<p>rows are: $rr1 and $rr2 and $rr3 and $rr4 and $rr5<br>";
print "<p>pfevaltimesdirnest is: @pfevaltimesdirnest<br>";
print "<p>pfevaltimesdirfhabi is: @pfevaltimesdirfhabi<br>";
print "<p>pfevaltimesdirpreava is: @pfevaltimesdirpreava<br>";
print "<p>pfevaltimesdiravopre is: @pfevaltimesdiravopre<br>";
print "<p>pfevaltimesdirrefshe is: @pfevaltimesdirrefshe<br>";
}

for($j=0; $j<$tsize; $j++)
{if($treatments[$j]==1)
  {
    for($k=0; $k<=($rr1-1);$k++)
    {
    if($evaltimesdirnest[$k]>0){$uncernest[$k]=1}
    elsif($evaltimesdirnest[$k]==0){$uncernest[$k]=0}
    else{$uncernest[$k]=-1}
    }
    if($debug){print "<p>uncernest is @uncernest<br>";}
    for($k=0; $k<=($rr2-1);$k++)
    {
    if($evaltimesdirfhabi[$k]>0){$uncerfhabi[$k]=1}
    elsif($evaltimesdirfhabi[$k]==0){$uncerfhabi[$k]=0}
    else{$uncerfhabi[$k]=-1}
    }
    if($debug){print "<p>uncerfhabi is @uncerfhabi<br>";}
    for($k=0; $k<=($rr3-1);$k++)
    {
    if($evaltimesdirpreava[$k]>0){$uncerpreava[$k]=1}
    elsif($evaltimesdirpreava[$k]==0){$uncerpreava[$k]=0}
    else{$uncerpreava[$k]=-1}
    }
    if($debug){print "<p>uncerpreava is @uncerpreava<br>";}
    for($k=0; $k<=($rr4-1);$k++)
    {
    if($evaltimesdircover[$k]>0){$uncercover[$k]=1}
    elsif($evaltimesdircover[$k]==0){$uncercover[$k]=0}
    else{$uncercover[$k]=-1}
    }
    if($debug){print "<p>uncercover is @uncercover<br>";}

    @unflag=(0,0,0,0,0);
    @suncernest=sort @uncernest;
    if(($suncernest[0]==0)||($suncernest[$rr1-1]==0)){$unflag[0]=0}
    elsif($suncernest[0]!=$suncernest[$rr1-1]){$unflag[0]=1}
    @suncerfhabi=sort @uncerfhabi;
    if(($suncerfhabi[0]==0)||($suncerfhabi[$rr2-1]==0)){$unflag[1]=0}
    elsif($suncerfhabi[0]!=$suncerfhabi[$rr2-1]){$unflag[1]=1}
    @suncerpreava=sort @uncerpreava;
    if(($suncerpreava[0]==0)||($suncerpreava[$rr3-1]==0)){$unflag[2]=0}
    elsif($suncerpreava[0]!=$suncerpreava[$rr3-1]){$unflag[2]=1}
    @suncercover=sort @uncercover;
    if(($suncercover[0]==0)||($suncercover[$rr4-1]==0)){$unflag[3]=0}
    elsif($suncercover[0]!=$suncercover[$rr4-1]){$unflag[3]=1}

    if($debug)
    {
    print "<p>suncernest is :@suncernest and $suncernest[0] and $suncernest[$rr1-1] and $unflag[0]<br>";
    print "<p>suncerfhabi is :@suncerfhabi and $suncerfhabi[0] and $suncerfhabi[$rr2-1] and $unflag[1]<br>";
    print "<p>suncerpreava is :@suncerpreava and $suncerpreava[0] and $suncerpreava[$rr3-1] and $unflag[2]<br>";
    print "<p>suncercover is :@suncercover and $suncercover[0] and $suncercover[$rr4-1] and $unflag[3]<br>";
    }

    $psentence[0]="Highly Negative";
    $psentence[1]="Moderately Negative";
    $psentence[2]="Slightly Negative";
    $psentence[3]="Minimal to None";
    $psentence[4]="Slightly Positive";
    $psentence[5]="Moderately Positive";
    $psentence[6]="Highly Positive";

    $upsentence[0]="Highly Negative, but low confidence <font color=red >*</font>";
    $upsentence[1]="Moderately Negative, but low confidence <font color=red >*</font>";
    $upsentence[2]="Slightly Negative, but low confidence<font color=red > *</font>";
    $upsentence[3]="Minimal to None, but low confidence <font color=red >*</font>";
    $upsentence[4]="Slightly Positive, but low confidence <font color=red >*</font>";
    $upsentence[5]="Moderately Positive, but low confidence<font color=red > *</font>";
    $upsentence[6]="Highly Positive, but low confidence <font color=red >*</font>";
  } 
if($treatments[$j]==2)
  {
    for($k=0; $k<=($rr1-1);$k++)
    {
    if($tpbevaltimesdirnest[$k]>0){$tpbuncernest[$k]=1}
    elsif($tpbevaltimesdirnest[$k]==0){$tpbuncernest[$k]=0}
    else{$tpbuncernest[$k]=-1}
    }
    if($debug){print "<p>tpbuncernest is @tpbuncernest<br>";}
    for($k=0; $k<=($rr2-1);$k++)
    {
    if($tpbevaltimesdirfhabi[$k]>0){$tpbuncerfhabi[$k]=1}
    elsif($tpbevaltimesdirfhabi[$k]==0){$tpbuncerfhabi[$k]=0}
    else{$tpbuncerfhabi[$k]=-1}
    }
    if($debug){print "<p>tpbuncerfhabi is @tpbuncerfhabi<br>";}
    for($k=0; $k<=($rr3-1);$k++)
    {
    if($tpbevaltimesdirpreava[$k]>0){$tpbuncerpreava[$k]=1}
    elsif($tpbevaltimesdirpreava[$k]==0){$tpbuncerpreava[$k]=0}
    else{$tpbuncerpreava[$k]=-1}
    }
    if($debug){print "<p>tpbuncerpreava is @tpbuncerpreava<br>";}
    for($k=0; $k<=($rr4-1);$k++)
    {
    if($tpbevaltimesdircover[$k]>0){$tpbuncercover[$k]=1}
    elsif($tpbevaltimesdircover[$k]==0){$tpbuncercover[$k]=0}
    else{$tpbuncercover[$k]=-1}
    }
    if($debug){print "<p>tpbuncercover is @tpbuncercover<br>";}

    @tpbunflag=(0,0,0,0,0);
    @tpbsuncernest=sort @tpbuncernest;
    if(($tpbsuncernest[0]==0)||($tpbsuncernest[$rr1-1]==0)){$tpbunflag[0]=0}
    elsif($tpbsuncernest[0]!=$tpbsuncernest[$rr1-1]){$tpbunflag[0]=1}
    @tpbsuncerfhabi=sort @tpbuncerfhabi;
    if(($tpbsuncerfhabi[0]==0)||($tpbsuncerfhabi[$rr2-1]==0)){$tpbunflag[1]=0}
    elsif($tpbsuncerfhabi[0]!=$tpbsuncerfhabi[$rr2-1]){$tpbunflag[1]=1}
    @tpbsuncerpreava=sort @tpbuncerpreava;
    if(($tpbsuncerpreava[0]==0)||($tpbsuncerpreava[$rr3-1]==0)){$tpbunflag[2]=0}
    elsif($tpbsuncerpreava[0]!=$tpbsuncerpreava[$rr3-1]){$tpbunflag[2]=1}
    @tpbsuncercover=sort @tpbuncercover;
    if(($tpbsuncercover[0]==0)||($tpbsuncercover[$rr4-1]==0)){$tpbunflag[3]=0}
    elsif($tpbsuncercover[0]!=$tpbsuncercover[$rr4-1]){$tpbunflag[3]=1}

    if($debug)
    {
    print "<p>tpbsuncernest is :@tpbsuncernest and $tpbsuncernest[0] and $tpbsuncernest[$rr1-1] and $tpbunflag[0]<br>";
    print "<p>tpbsuncerfhabi is :@tpbsuncerfhabi and $tpbsuncerfhabi[0] and $tpbsuncerfhabi[$rr2-1] and $tpbunflag[1]<br>";
    print "<p>tpbsuncerpreava is :@tpbsuncerpreava and $tpbsuncerpreava[0] and $tpbsuncerpreava[$rr3-1] and $tpbunflag[2]<br>";
    print "<p>tpbsuncercover is :@tpbsuncercover and $tpbsuncercover[0] and $tpbsuncercover[$rr4-1] and $tpbunflag[3]<br>";
    }

    $tpbpsentence[0]="Highly Negative";
    $tpbpsentence[1]="Moderately Negative";
    $tpbpsentence[2]="Slightly Negative";
    $tpbpsentence[3]="Minimal to None";
    $tpbpsentence[4]="Slightly Positive";
    $tpbpsentence[5]="Moderately Positive";
    $tpbpsentence[6]="Highly Positive";

    $tpbupsentence[0]="Highly Negative, but low confidence <font color=red >*</font>";
    $tpbupsentence[1]="Moderately Negative, but low confidence <font color=red >*</font>";
    $tpbupsentence[2]="Slightly Negative, but low confidence<font color=red > *</font>";
    $tpbupsentence[3]="Minimal to None, but low confidence <font color=red >*</font>";
    $tpbupsentence[4]="Slightly Positive, but low confidence <font color=red >*</font>";
    $tpbupsentence[5]="Moderately Positive, but low confidence<font color=red > *</font>";
    $tpbupsentence[6]="Highly Positive, but low confidence <font color=red >*</font>";
  }
  
if($treatments[$j]==3)
  {
    for($k=0; $k<=($rr1-1);$k++)
    {
    if($pfevaltimesdirnest[$k]>0){$pfuncernest[$k]=1}
    elsif($pfevaltimesdirnest[$k]==0){$pfuncernest[$k]=0}
    else{$pfuncernest[$k]=-1}
    }
    if($debug){print "<p>pfuncernest is @pfuncernest<br>";}
    for($k=0; $k<=($rr2-1);$k++)
    {
    if($pfevaltimesdirfhabi[$k]>0){$pfuncerfhabi[$k]=1}
    elsif($pfevaltimesdirfhabi[$k]==0){$pfuncerfhabi[$k]=0}
    else{$pfuncerfhabi[$k]=-1}
    }
    if($debug){print "<p>pfuncerfhabi is @pfuncerfhabi<br>";}
    for($k=0; $k<=($rr3-1);$k++)
    {
    if($pfevaltimesdirpreava[$k]>0){$pfuncerpreava[$k]=1}
    elsif($pfevaltimesdirpreava[$k]==0){$pfuncerpreava[$k]=0}
    else{$pfuncerpreava[$k]=-1}
    }
    if($debug){print "<p>pfuncerpreava is @pfuncerpreava<br>";}
    for($k=0; $k<=($rr4-1);$k++)
    {
    if($pfevaltimesdircover[$k]>0){$pfuncercover[$k]=1}
    elsif($pfevaltimesdircover[$k]==0){$pfuncercover[$k]=0}
    else{$pfuncercover[$k]=-1}
    }
    if($debug){print "<p>pfuncercover is @pfuncercover<br>";}

    @pfunflag=(0,0,0,0,0);
    @pfsuncernest=sort @pfuncernest;
    if(($pfsuncernest[0]==0)||($pfsuncernest[$rr1-1]==0)){$pfunflag[0]=0}
    elsif($pfsuncernest[0]!=$pfsuncernest[$rr1-1]){$pfunflag[0]=1}
    @pfsuncerfhabi=sort @pfuncerfhabi;
    if(($pfsuncerfhabi[0]==0)||($pfsuncerfhabi[$rr2-1]==0)){$pfunflag[1]=0}
    elsif($pfsuncerfhabi[0]!=$pfsuncerfhabi[$rr2-1]){$pfunflag[1]=1}
    @pfsuncerpreava=sort @pfuncerpreava;
    if(($pfsuncerpreava[0]==0)||($pfsuncerpreava[$rr3-1]==0)){$pfunflag[2]=0}
    elsif($pfsuncerpreava[0]!=$pfsuncerpreava[$rr3-1]){$pfunflag[2]=1}
    @pfsuncercover=sort @pfuncercover;
    if(($pfsuncercover[0]==0)||($pfsuncercover[$rr4-1]==0)){$pfunflag[3]=0}
    elsif($pfsuncercover[0]!=$pfsuncercover[$rr4-1]){$pfunflag[3]=1}

    if($debug)
    {
    print "<p>pfsuncernest is :@pfsuncernest and $pfsuncernest[0] and $pfsuncernest[$rr1-1] and $pfunflag[0]<br>";
    print "<p>pfsuncerfhabi is :@pfsuncerfhabi and $pfsuncerfhabi[0] and $pfsuncerfhabi[$rr2-1] and $pfunflag[1]<br>";
    print "<p>pfsuncerpreava is :@pfsuncerpreava and $pfsuncerpreava[0] and $pfsuncerpreava[$rr3-1] and $pfunflag[2]<br>";
    print "<p>pfsuncercover is :@pfsuncercover and $pfsuncercover[0] and $pfsuncercover[$rr4-1] and $pfunflag[3]<br>";
    }

    $pfpsentence[0]="Highly Negative";
    $pfpsentence[1]="Moderately Negative";
    $pfpsentence[2]="Slightly Negative";
    $pfpsentence[3]="Minimal to None";
    $pfpsentence[4]="Slightly Positive";
    $pfpsentence[5]="Moderately Positive";
    $pfpsentence[6]="Highly Positive";

    $pfupsentence[0]="Highly Negative, but low confidence <font color=red >*</font>";
    $pfupsentence[1]="Moderately Negative, but low confidence <font color=red >*</font>";
    $pfupsentence[2]="Slightly Negative, but low confidence<font color=red > *</font>";
    $pfupsentence[3]="Minimal to None, but low confidence <font color=red >*</font>";
    $pfupsentence[4]="Slightly Positive, but low confidence <font color=red >*</font>";
    $pfupsentence[5]="Moderately Positive, but low confidence<font color=red > *</font>";
    $pfupsentence[6]="Highly Positive, but low confidence <font color=red >*</font>";
  }
  
if($treatments[$j]==4)
  {
    for($k=0; $k<=($rr1-1);$k++)
    {
    if($wfevaltimesdirnest[$k]>0){$wfuncernest[$k]=1}
    elsif($wfevaltimesdirnest[$k]==0){$wfuncernest[$k]=0}
    else{$wfuncernest[$k]=-1}
    }
    if($debug){print "<p>wfuncernest is @wfuncernest<br>";}
    for($k=0; $k<=($rr2-1);$k++)
    {
    if($wfevaltimesdirfhabi[$k]>0){$wfuncerfhabi[$k]=1}
    elsif($wfevaltimesdirfhabi[$k]==0){$wfuncerfhabi[$k]=0}
    else{$wfuncerfhabi[$k]=-1}
    }
    if($debug){print "<p>wfuncerfhabi is @wfuncerfhabi<br>";}
    for($k=0; $k<=($rr3-1);$k++)
    {
    if($wfevaltimesdirpreava[$k]>0){$wfuncerpreava[$k]=1}
    elsif($wfevaltimesdirpreava[$k]==0){$wfuncerpreava[$k]=0}
    else{$wfuncerpreava[$k]=-1}
    }
    if($debug){print "<p>wfuncerpreava is @wfuncerpreava<br>";}
    for($k=0; $k<=($rr4-1);$k++)
    {
    if($wfevaltimesdircover[$k]>0){$wfuncercover[$k]=1}
    elsif($wfevaltimesdircover[$k]==0){$wfuncercover[$k]=0}
    else{$wfuncercover[$k]=-1}
    }
    if($debug){print "<p>wfuncercover is @wfuncercover<br>";}

    @wfunflag=(0,0,0,0,0);
    @wfsuncernest=sort @wfuncernest;
    if(($wfsuncernest[0]==0)||($wfsuncernest[$rr1-1]==0)){$wfunflag[0]=0}
    elsif($wfsuncernest[0]!=$wfsuncernest[$rr1-1]){$wfunflag[0]=1}
    @wfsuncerfhabi=sort @wfuncerfhabi;
    if(($wfsuncerfhabi[0]==0)||($wfsuncerfhabi[$rr2-1]==0)){$wfunflag[1]=0}
    elsif($wfsuncerfhabi[0]!=$wfsuncerfhabi[$rr2-1]){$wfunflag[1]=1}
    @wfsuncerpreava=sort @wfuncerpreava;
    if(($wfsuncerpreava[0]==0)||($wfsuncerpreava[$rr3-1]==0)){$wfunflag[2]=0}
    elsif($wfsuncerpreava[0]!=$wfsuncerpreava[$rr3-1]){$wfunflag[2]=1}
    @wfsuncercover=sort @wfuncercover;
    if(($wfsuncercover[0]==0)||($wfsuncercover[$rr4-1]==0)){$wfunflag[3]=0}
    elsif($wfsuncercover[0]!=$wfsuncercover[$rr4-1]){$wfunflag[3]=1}

    if($debug)
    {
    print "<p>wfsuncernest is :@wfsuncernest and $wfsuncernest[0] and $wfsuncernest[$rr1-1] and $wfunflag[0]<br>";
    print "<p>wfsuncerfhabi is :@wfsuncerfhabi and $wfsuncerfhabi[0] and $wfsuncerfhabi[$rr2-1] and $wfunflag[1]<br>";
    print "<p>wfsuncerpreava is :@wfsuncerpreava and $wfsuncerpreava[0] and $wfsuncerpreava[$rr3-1] and $wfunflag[2]<br>";
    print "<p>wfsuncercover is :@wfsuncercover and $wfsuncercover[0] and $wfsuncercover[$rr4-1] and $wfunflag[3]<br>";
    }

    $wfpsentence[0]="Highly Negative";
    $wfpsentence[1]="Moderately Negative";
    $wfpsentence[2]="Slightly Negative";
    $wfpsentence[3]="Minimal to None";
    $wfpsentence[4]="Slightly Positive";
    $wfpsentence[5]="Moderately Positive";
    $wfpsentence[6]="Highly Positive";

    $wfupsentence[0]="Highly Negative, but low confidence <font color=red >*</font>";
    $wfupsentence[1]="Moderately Negative, but low confidence <font color=red >*</font>";
    $wfupsentence[2]="Slightly Negative, but low confidence<font color=red > *</font>";
    $wfupsentence[3]="Minimal to None, but low confidence <font color=red >*</font>";
    $wfupsentence[4]="Slightly Positive, but low confidence <font color=red >*</font>";
    $wfupsentence[5]="Moderately Positive, but low confidence<font color=red > *</font>";
    $wfupsentence[6]="Highly Positive, but low confidence <font color=red >*</font>";
  }
    
}##end of j loop

####extracting information from the file

open (LITFILE, $spepath .$spefilename)|| die("Error: files unopened!\n");
while(<LITFILE>)
{    
 if($_=~/Literature/)
 {@litreview=<LITFILE>;}
}

close (LITFILE);
$litsize=(@litreview);
for($i=0;$i<=$litsize-1;$i++)
{if($litreview[$i]=~m/Canopy Cover/){$canopycover=$litreview[$i+1];}

}

##########################end info file

$fpsentence[0]=" highly negative ";
$fpsentence[1]=" moderately negative ";
$fpsentence[2]=" slightly negative ";
$fpsentence[3]=" minimal affect ";
$fpsentence[4]=" slightly positive ";
$fpsentence[5]=" moderately positive ";
$fpsentence[6]=" highly positive ";

$tpbfpsentence[0]=" highly negative ";
$tpbfpsentence[1]=" moderately negative ";
$tpbfpsentence[2]=" slightly negative ";
$tpbfpsentence[3]=" minimal affect ";
$tpbfpsentence[4]=" slightly positive ";
$tpbfpsentence[5]=" moderately positive ";
$tpbfpsentence[6]=" highly positive ";

$pffpsentence[0]=" highly negative ";
$pffpsentence[1]=" moderately negative ";
$pffpsentence[2]=" slightly negative ";
$pffpsentence[3]=" minimal affect ";
$pffpsentence[4]=" slightly positive ";
$pffpsentence[5]=" moderately positive ";
$pffpsentence[6]=" highly positive ";

$wffpsentence[0]=" highly negative ";
$wffpsentence[1]=" moderately negative ";
$wffpsentence[2]=" slightly negative ";
$wffpsentence[3]=" minimal affect ";
$wffpsentence[4]=" slightly positive ";
$wffpsentence[5]=" moderately positive ";
$wffpsentence[6]=" highly positive ";


for($j=0; $j<$tsize; $j++)
{     if($treatments[$j]==1)
        {
        for($i=0; $i<=3;$i++)
        {
        if(($animalresp[$i]>=-3)&&($animalresp[$i]<-2))
        {
        if($unflag[$i]){$panimalresp[$i]=$upsentence[0];$ffpsentence[$i]=$fpsentence[0];}
        else{$panimalresp[$i]=$psentence[0];$ffpsentence[$i]=$fpsentence[0];}
        }
        elsif(($animalresp[$i]>=-2)&&($animalresp[$i]<-1))
        {
        if($unflag[$i]){$panimalresp[$i]=$upsentence[1];$ffpsentence[$i]=$fpsentence[1];}
        else{$panimalresp[$i]=$psentence[1];$ffpsentence[$i]=$fpsentence[1];}
        }
        elsif(($animalresp[$i]>=-1)&&($animalresp[$i]<-0.25))
        {
        if($unflag[$i]){$panimalresp[$i]=$upsentence[2];$ffpsentence[$i]=$fpsentence[2];}
        else{$panimalresp[$i]=$psentence[2];$ffpsentence[$i]=$fpsentence[2];}
        }
        elsif(($animalresp[$i]>=-0.25)&&($animalresp[$i]<=0.25))
        {
        if($unflag[$i]){$panimalresp[$i]=$upsentence[3];$ffpsentence[$i]=$fpsentence[3];}
        else{$panimalresp[$i]=$psentence[3];$ffpsentence[$i]=$fpsentence[3];}
        }
        elsif(($animalresp[$i]>0.25)&&($animalresp[$i]<=1))
        {
        if($unflag[$i]){$panimalresp[$i]=$upsentence[4];$ffpsentence[$i]=$fpsentence[4];}
        else{$panimalresp[$i]=$psentence[4];$ffpsentence[$i]=$fpsentence[4];}
        }
        elsif(($animalresp[$i]>1)&&($animalresp[$i]<=2))
        {
        if($unflag[$i]){$panimalresp[$i]=$upsentence[5];$ffpsentence[$i]=$fpsentence[5];}
        else{$panimalresp[$i]=$psentence[5];$ffpsentence[$i]=$fpsentence[5];}
        }
        elsif(($animalresp[$i]>2)&&($animalresp[$i]<=3))
        {
        if($unflag[$i]){$panimalresp[$i]=$upsentence[6];$ffpsentence[$i]=$fpsentence[6];}
        else{$panimalresp[$i]=$psentence[6];$ffpsentence[$i]=$fpsentence[6];}
        }
        else{$panimalresp[$i]="Not Available"; $ffpsentence[$i]="Not Available"; }
        }#end i loop
     }#end treatment 
     
     if($treatments[$j]==2)
        {
        for($i=0; $i<=3;$i++)
        {
        if(($tpbanimalresp[$i]>=-3)&&($tpbanimalresp[$i]<-2))
        {
        if($tpbunflag[$i]){$tpbpanimalresp[$i]=$tpbupsentence[0];$tpbffpsentence[$i]=$tpbfpsentence[0];}
        else{$tpbpanimalresp[$i]=$tpbpsentence[0];$tpbffpsentence[$i]=$tpbfpsentence[0];}
        }
        elsif(($tpbanimalresp[$i]>=-2)&&($tpbanimalresp[$i]<-1))
        {
        if($tpbunflag[$i]){$tpbpanimalresp[$i]=$tpbupsentence[1];$tpbffpsentence[$i]=$tpbfpsentence[1];}
        else{$tpbpanimalresp[$i]=$tpbpsentence[1];$tpbffpsentence[$i]=$tpbfpsentence[1];}
        }
        elsif(($tpbanimalresp[$i]>=-1)&&($tpbanimalresp[$i]<-0.25))
        {
        if($tpbunflag[$i]){$tpbpanimalresp[$i]=$tpbupsentence[2];$tpbffpsentence[$i]=$tpbfpsentence[2];}
        else{$tpbpanimalresp[$i]=$tpbpsentence[2];$tpbffpsentence[$i]=$tpbfpsentence[2];}
        }
        elsif(($tpbanimalresp[$i]>=-0.25)&&($tpbanimalresp[$i]<=0.25))
        {
        if($tpbunflag[$i]){$tpbpanimalresp[$i]=$tpbupsentence[3];$tpbffpsentence[$i]=$tpbfpsentence[3];}
        else{$tpbpanimalresp[$i]=$tpbpsentence[3];$tpbffpsentence[$i]=$tpbfpsentence[3];}
        }
        elsif(($tpbanimalresp[$i]>0.25)&&($tpbanimalresp[$i]<=1))
        {
        if($tpbunflag[$i]){$tpbpanimalresp[$i]=$tpbupsentence[4];$tpbffpsentence[$i]=$tpbfpsentence[4];}
        else{$tpbpanimalresp[$i]=$tpbpsentence[4];$tpbffpsentence[$i]=$tpbfpsentence[4];}
        }
        elsif(($tpbanimalresp[$i]>1)&&($tpbanimalresp[$i]<=2))
        {
        if($tpbunflag[$i]){$tpbpanimalresp[$i]=$tpbupsentence[5];$tpbffpsentence[$i]=$tpbfpsentence[5];}
        else{$tpbpanimalresp[$i]=$tpbpsentence[5];$tpbffpsentence[$i]=$tpbfpsentence[5];}
        }
        elsif(($tpbanimalresp[$i]>2)&&($tpbanimalresp[$i]<=3))
        {
        if($tpbunflag[$i]){$tpbpanimalresp[$i]=$tpbupsentence[6];$tpbffpsentence[$i]=$tpbfpsentence[6];}
        else{$tpbpanimalresp[$i]=$tpbpsentence[6];$tpbffpsentence[$i]=$tpbfpsentence[6];}
        }
        else{$tpbpanimalresp[$i]="Not Available"; $tpbffpsentence[$i]="Not Available"; }
        }#end i loop
     }#end treatment 
     if($treatments[$j]==3)
        {
        for($i=0; $i<=3;$i++)
        {
        if(($pfanimalresp[$i]>=-3)&&($pfanimalresp[$i]<-2))
        {
        if($pfunflag[$i]){$pfpanimalresp[$i]=$pfupsentence[0];$pfffpsentence[$i]=$pffpsentence[0];}
        else{$pfpanimalresp[$i]=$pfpsentence[0];$pfffpsentence[$i]=$pffpsentence[0];}
        }
        elsif(($pfanimalresp[$i]>=-2)&&($pfanimalresp[$i]<-1))
        {
        if($pfunflag[$i]){$pfpanimalresp[$i]=$pfupsentence[1];$pfffpsentence[$i]=$pffpsentence[1];}
        else{$pfpanimalresp[$i]=$pfpsentence[1];$pfffpsentence[$i]=$pffpsentence[1];}
        }
        elsif(($pfanimalresp[$i]>=-1)&&($pfanimalresp[$i]<-0.25))
        {
        if($pfunflag[$i]){$pfpanimalresp[$i]=$pfupsentence[2];$pfffpsentence[$i]=$pffpsentence[2];}
        else{$pfpanimalresp[$i]=$pfpsentence[2];$pfffpsentence[$i]=$pffpsentence[2];}
        }
        elsif(($pfanimalresp[$i]>=-0.25)&&($pfanimalresp[$i]<=0.25))
        {
        if($pfunflag[$i]){$pfpanimalresp[$i]=$pfupsentence[3];$pfffpsentence[$i]=$pffpsentence[3];}
        else{$pfpanimalresp[$i]=$pfpsentence[3];$pfffpsentence[$i]=$pffpsentence[3];}
        }
        elsif(($pfanimalresp[$i]>0.25)&&($pfanimalresp[$i]<=1))
        {
        if($pfunflag[$i]){$pfpanimalresp[$i]=$pfupsentence[4];$pfffpsentence[$i]=$pffpsentence[4];}
        else{$pfpanimalresp[$i]=$pfpsentence[4];$pfffpsentence[$i]=$pffpsentence[4];}
        }
        elsif(($pfanimalresp[$i]>1)&&($pfanimalresp[$i]<=2))
        {
        if($pfunflag[$i]){$pfpanimalresp[$i]=$pfupsentence[5];$pfffpsentence[$i]=$pffpsentence[5];}
        else{$pfpanimalresp[$i]=$pfpsentence[5];$pfffpsentence[$i]=$pffpsentence[5];}
        }
        elsif(($pfanimalresp[$i]>2)&&($pfanimalresp[$i]<=3))
        {
        if($pfunflag[$i]){$pfpanimalresp[$i]=$pfupsentence[6];$pfffpsentence[$i]=$pffpsentence[6];}
        else{$pfpanimalresp[$i]=$pfpsentence[6];$pfffpsentence[$i]=$pffpsentence[6];}
        }
        else{$pfpanimalresp[$i]="Not Available"; $pfffpsentence[$i]="Not Available"; }
        }#end i loop
     }#end treatment 
     
     if($treatments[$j]==4)
        {
        for($i=0; $i<=3;$i++)
        {
        if(($wfanimalresp[$i]>=-3)&&($wfanimalresp[$i]<-2))
        {
        if($wfunflag[$i]){$wfpanimalresp[$i]=$wfupsentence[0];$wfffpsentence[$i]=$wffpsentence[0];}
        else{$wfpanimalresp[$i]=$wfpsentence[0];$wfffpsentence[$i]=$wffpsentence[0];}
        }
        elsif(($wfanimalresp[$i]>=-2)&&($wfanimalresp[$i]<-1))
        {
        if($wfunflag[$i]){$wfpanimalresp[$i]=$wfupsentence[1];$wfffpsentence[$i]=$wffpsentence[1];}
        else{$wfpanimalresp[$i]=$wfpsentence[1];$wfffpsentence[$i]=$wffpsentence[1];}
        }
        elsif(($wfanimalresp[$i]>=-1)&&($wfanimalresp[$i]<-0.25))
        {
        if($wfunflag[$i]){$wfpanimalresp[$i]=$wfupsentence[2];$wfffpsentence[$i]=$wffpsentence[2];}
        else{$wfpanimalresp[$i]=$wfpsentence[2];$wfffpsentence[$i]=$wffpsentence[2];}
        }
        elsif(($wfanimalresp[$i]>=-0.25)&&($wfanimalresp[$i]<=0.25))
        {
        if($wfunflag[$i]){$wfpanimalresp[$i]=$wfupsentence[3];$wfffpsentence[$i]=$wffpsentence[3];}
        else{$wfpanimalresp[$i]=$wfpsentence[3];$wfffpsentence[$i]=$wffpsentence[3];}
        }
        elsif(($wfanimalresp[$i]>0.25)&&($wfanimalresp[$i]<=1))
        {
        if($wfunflag[$i]){$wfpanimalresp[$i]=$wfupsentence[4];$wfffpsentence[$i]=$wffpsentence[4];}
        else{$wfpanimalresp[$i]=$wfpsentence[4];$wfffpsentence[$i]=$wffpsentence[4];}
        }
        elsif(($wfanimalresp[$i]>1)&&($wfanimalresp[$i]<=2))
        {
        if($wfunflag[$i]){$wfpanimalresp[$i]=$wfupsentence[5];$wfffpsentence[$i]=$wffpsentence[5];}
        else{$wfpanimalresp[$i]=$wfpsentence[5];$wfffpsentence[$i]=$wffpsentence[5];}
        }
        elsif(($wfanimalresp[$i]>2)&&($wfanimalresp[$i]<=3))
        {
        if($wfunflag[$i]){$wfpanimalresp[$i]=$wfupsentence[6];$wfffpsentence[$i]=$wffpsentence[6];}
        else{$wfpanimalresp[$i]=$wfpsentence[6];$wfffpsentence[$i]=$wffpsentence[6];}
        }
        else{$wfpanimalresp[$i]="Not Available"; $wfffpsentence[$i]="Not Available"; }
        }#end i loop
     }#end treatment 
}#end j loop

if($debug)
{
print "<p>nestrow is :$nestrow";
print "<p>fhabirow is :$fhabirow";
print "<p>preavarow is :$preavarow";
print "<p>coverrow is :$coverrow";
print "<p>rr1 $rr1";
print "<p>rr2 $rr2";
print "<p>rr3 $rr3";
print "<p>rr4 $rr4";
print "<p>totalrow $totalrow";
print "<p>animalresp @animalresp";
print "<p>animalresp @panimalresp";
print "<p>tpbpanimalresp @tpbanimalresp";
print "<p>tpbanimalresp @tpbpanimalresp";
print "<p>pfanimalresp @pfanimalresp";
print "<p>pfanimalresp @pfpanimalresp";
print "<p>wfanimalresp @wfanimalresp";
print "<p>wfanimalresp @wf0panimalresp";
}

##}#end of K loop
#########################################################################################

####    2004.12.13 DEH log the run

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
                            <font color="#99ff00"></font></th>
                        <th  colspan=$tsize bgcolor="#006009">
                            <font color="#99ff00">Weighted Average Effect on Habitat</font>
                        <br>
                            <a href="javascript:explain_average()"
                            onMouseOver="window.status='Explain WeightedAverage Effect on Habitat (new window)';return true"
                            onMouseOut="window.status='Wildlife Habitat Response Model'; return true">
                            <img src="/fuels/whrm/images/quest2.gif" width="18" height="16" border="0"></a>
                        </th>
		    </tr>
                    <tr>
                        <th colspan="1"  bgcolor="#006009">
                            <font color="#99ff00">Life History Requirements</font></th>
                        <th  bgcolor="#006009">

                            <font color="#99ff00">Key Habitat Element(s)</font></th>

fin

print "$ftempstring";

#########beginnig of copy
print <<"final";
                    <tr>
                        <!--<th rowspan=$nestrow BGCOLOR="#006009">
                            <Font color="#99ff00">Reproduction</Font></th>-->
                        <th rowspan=$nestrow BGCOLOR="#006009">
                            <Font color="#99ff00">Nest Sites,<br>Birthing Areas,<br>
                            Breeding Sites</Font></th>
final
for($i=0; $i<=$nestrow-1;$i++)
{
    if($i==0){  if($nestfeacode[$i]==-99)
            {
            print "<td colspan=$tsize2 align=center>No Information Is Available</td>
            </tr>";
            }
            else
            {print "<td>$habitatfeatures[$nestfeacode[$i]]</td>";
		    for($j=0; $j<$tsize; $j++)
                {if($treatments[$j]==1){print "<td align=center rowspan=$rr1>$panimalresp[0]</td>";}
                 elsif( $treatments[$j]==2){print "<td align=center rowspan=$rr1>$tpbpanimalresp[0]</td>";}
                 elsif( $treatments[$j]==3){print "<td align=center rowspan=$rr1>$pfpanimalresp[0]</td>";}
                 else{print "<td align=center rowspan=$rr1>$wfpanimalresp[0]</td>";}
                }
            print "</tr>";
            }
        }
    else{
        print "<tr>";
        print "<td>$habitatfeatures[$nestfeacode[$i]]</td>";
        print "</tr>";}
}
print <<"fin1";
                    <tr>
                        <!--<th rowspan=$rr6 BGCOLOR="#006009">
                            <Font color="#99ff00">Food Resources</Font></th>-->
                        <th rowspan=$fhabirow BGCOLOR="#006009">
                            <Font color="#99ff00">Foraging Habitat</Font></th>
fin1

for($i=0; $i<=$fhabirow-1;$i++)
{
    if($i==0){  if($fhabifeacode[$i]==-99)
            {
             print "<td colspan=$tsize2 align=center>No Information Is Available</td>
            </tr>";}

            else
            {   print "<td>$habitatfeatures[$fhabifeacode[$i]]</td>";
                for($j=0; $j<$tsize; $j++)
                {if($treatments[$j]==1){print "<td align=center rowspan=$rr2>$panimalresp[1]</td>";}
                 elsif( $treatments[$j]==2){print "<td align=center rowspan=$rr2>$tpbpanimalresp[1]</td>";}
                 elsif( $treatments[$j]==3){print "<td align=center rowspan=$rr2>$pfpanimalresp[1]</td>";}
                 else{print "<td align=center rowspan=$rr2>$wfpanimalresp[1]</td>";}
                }
            print "</tr>";
            }
        }
    else{print "<tr>";
	 print "<td>$habitatfeatures[$fhabifeacode[$i]]</td>";
        print "</tr>";}
}
print "<tr>
    <th rowspan=$preavarow BGCOLOR=\"#006009\">
    <Font color=\"#99ff00\">Forage,<br>Prey Habitat</Font></th>";

for($i=0; $i<=$preavarow-1;$i++)
{
    if($i==0){  if($preavafeacode[$i]==-99)
            {
            print "<td colspan=$tsize2 align=center>No Information Is Available</td>
            </tr>";
            ##$pevaluesindex3=$pevaluesindex2;
            }
            else
            {
            print "<td>$habitatfeatures[$preavafeacode[$i]]</td>";
                for($j=0; $j<$tsize; $j++)
                {if($treatments[$j]==1){print "<td align=center rowspan=$rr3>$panimalresp[2]</td>";}
                 elsif( $treatments[$j]==2){print "<td align=center rowspan=$rr3>$tpbpanimalresp[2]</td>";}
                 elsif( $treatments[$j]==3){print "<td align=center rowspan=$rr3>$pfpanimalresp[2]</td>";}
                 else{print "<td align=center rowspan=$rr3>$wfpanimalresp[2]</td>";}
                }
            print "</tr>";
            }
        }
    else{print "<tr>
        <td>$habitatfeatures[$preavafeacode[$i]]</td>";
        print "</tr>";}
}
print <<"fin2";
        <tr>
        <!--<th rowspan=$coverrow BGCOLOR="#006009">
        <Font color="#99ff00">Cover</Font></th>-->
        <th rowspan=$coverrow BGCOLOR="#006009">
        <Font color="#99ff00">Shelter from Predators,<br>
        and Environmental Extremes</Font></th>
fin2
for($i=0; $i<=$coverrow-1;$i++)
{
    if($i==0){  if($coverfeacode[$i]==-99)
            {
            print "<td colspan=$tsize2 align=center>No Information Is Available</td>
            </tr>";
            }
            else
            {
            print "<td>$habitatfeatures[$coverfeacode[$i]]</td>";
               for($j=0; $j<$tsize; $j++)
                {if($treatments[$j]==1){print "<td align=center rowspan=$rr4>$panimalresp[3]</td>";}
                 elsif( $treatments[$j]==2){print "<td align=center rowspan=$rr4>$tpbpanimalresp[3]</td>";}
                 elsif( $treatments[$j]==3){print "<td align=center rowspan=$rr4>$pfpanimalresp[3]</td>";}
                 else{print "<td align=center rowspan=$rr4>$wfpanimalresp[3]</td>";}
                }
            print "</tr>";
            }
        }
    else{print "<tr>
        <td>$habitatfeatures[$coverfeacode[$i]]</td>";
        print "</tr>";}
}
#########end of copy
print"              </table>";
@sunflag=sort @unflag;
@tpbsunflag=sort @tpbunflag;
@pfsunflag=sort @pfunflag;
@wfsunflag=sort @wfunflag;
$footnote=$sunflag[$#unflag];
$tpbfootnote=$tpbsunflag[$#tpbunflag];
$pffootnote=$pfsunflag[$#pfunflag];
$wffootnote=$wfsunflag[$#wfunflag];
if($debug){
print "<p>the footnot is: $footnote";
print "<p>the tpbfootnot is: $tpbfootnote";
print "<p>the pffootnot is: $pffootnote";
print "<p>the wffootnot is: $wffootnote<br>";}
if($footnote||$tpbfootnote||$pffootnote||$wffootnote){
print"
<font color=red>*</font><font size=2 ><em>When the \"weighted average predicted effect on habitat \" includes some habitat elements
that positively influenced habitat and others that negatively influenced habitat, then the
average may be misleading. Due to this uncertainty, we recommend you consult a wildlife biologist regarding the relative
importance of each habitat element contributing to averages that have low confidence.</em></font>";
}
print " <br>";

###########calculationfor text
########adding code

for($i=0; $i<=$nestrow-1;$i++)
{
    if($i==0){if($nestfeacode[$i]==-99){$nestelem[$i]="no";}
             else
             {$nestelem[$i]=$habitatfeatures[$nestfeacode[$i]];}
            }
    else{$nestelem[$i]=$habitatfeatures[$nestfeacode[$i]];}
}
for($i=0; $i<=$fhabirow-1;$i++)
{
    if($i==0){if($fhabifeacode[$i]==-99){$forgelem[$i]="no";}
             else
             {$forgelem[$i]=$habitatfeatures[$fhabifeacode[$i]];}
            }
    else{$forgelem[$i]=$habitatfeatures[$fhabifeacode[$i]];}
}
for($i=0; $i<=$preavarow-1;$i++)
{
    if($i==0){if($preavafeacode[$i]==-99){$preyelem[$i]="no";}
              else
              {$preyelem[$i]=$habitatfeatures[$preavafeacode[$i]];}
	     }
    else{$preyelem[$i]=$habitatfeatures[$preavafeacode[$i]];}
}
for($i=0; $i<=$coverrow-1;$i++)
{
    if($i==0){if($coverfeacode[$i]==-99){$coveelem[$i]="no";}
              else
              {$coveelem[$i]=$habitatfeatures[$coverfeacode[$i]];}
            }
    else{$coveelem[$i]=$habitatfeatures[$coverfeacode[$i]];}
}

for($k=0; $k<=$tsize-1; $k++)
{ 
        for($i=0; $i<=$nestrow-1;$i++)
        {if($treatments[$k]==1){if($evaltimesdirnest[$i]<0){$nestneg[$size1[$k]]=$nestelem[$i];$size1[$k]=$size1[$k]+1}}
	 if($treatments[$k]==2){if($tpbevaltimesdirnest[$i]<0){$tpbnestneg[$size1[$k]]=$nestelem[$i];$size1[$k]=$size1[$k]+1}}
 	 if($treatments[$k]==3){if($pfevaltimesdirnest[$i]<0){$pfnestneg[$size1[$k]]=$nestelem[$i];$size1[$k]=$size1[$k]+1}}
	 if($treatments[$k]==4){if($wfevaltimesdirnest[$i]<0){$wfnestneg[$size1[$k]]=$nestelem[$i];$size1[$k]=$size1[$k]+1}}
        }
###########################
        for($i=0; $i<=$fhabirow-1;$i++)
        {if($treatments[$k]==1){if($evaltimesdirfhabi[$i]<0){$forgneg[$size2[$k]]=$forgelem[$i];$size2[$k]=$size2[$k]+1}}
	 if($treatments[$k]==2){if($tpbevaltimesdirfhabi[$i]<0){$tpbforgneg[$size2[$k]]=$forgelem[$i];$size2[$k]=$size2[$k]+1}}
 	 if($treatments[$k]==3){if($pfevaltimesdirfhabi[$i]<0){$pfforgneg[$size2[$k]]=$forgelem[$i];$size2[$k]=$size2[$k]+1}}
	 if($treatments[$k]==4){if($wfevaltimesdirfhabi[$i]<0){$wfforgneg[$size2[$k]]=$forgelem[$i];$size2[$k]=$size2[$k]+1}}
        }
###########################
        for($i=0; $i<=$preavarow-1;$i++)
        {if($treatments[$k]==1){if($evaltimesdirpreava[$i]<0){$preyneg[$size3[$k]]=$preyelem[$i];$size3[$k]=$size3[$k]+1}}
	 if($treatments[$k]==2){if($tpbevaltimesdirpreava[$i]<0){$tpbpreyneg[$size3[$k]]=$preyelem[$i];$size3[$k]=$size3[$k]+1}}
 	 if($treatments[$k]==3){if($pfevaltimesdirpreava[$i]<0){$pfpreyneg[$size3[$k]]=$preyelem[$i];$size3[$k]=$size3[$k]+1}}
	 if($treatments[$k]==4){if($wfevaltimesdirpreava[$i]<0){$wfpreyneg[$size3[$k]]=$preyelem[$i];$size3[$k]=$size3[$k]+1}}
        }
###########################
for($i=0; $i<=$coverrow-1;$i++)
        {if($treatments[$k]==1){if($evaltimesdircover[$i]<0){$coveneg[$size4[$k]]=$coveelem[$i];$size4[$k]=$size4[$k]+1}}
	 if($treatments[$k]==2){if($tpbevaltimesdircover[$i]<0){$tpbcoveneg[$size4[$k]]=$coveelem[$i];$size4[$k]=$size4[$k]+1}}
 	 if($treatments[$k]==3){if($pfevaltimesdircover[$i]<0){$pfcoveneg[$size4[$k]]=$coveelem[$i];$size4[$k]=$size4[$k]+1}}
	 if($treatments[$k]==4){if($wfevaltimesdircover[$i]<0){$wfcoveneg[$size4[$k]]=$coveelem[$i];$size4[$k]=$size4[$k]+1}}
        }

}

#######endadding code
for($k=0;$k<$tsize;$k++){
if($treatments[$k]==1){$nestc[$k]=$animalresp[0];$forgc[$k]=$animalresp[1];$preyc[$k]=$animalresp[2];
	$covec[$k]=$animalresp[3];}
if($treatments[$k]==2){$nestc[$k]=$tpbanimalresp[0];$forgc[$k]=$tpbanimalresp[1];$preyc[$k]=$tpbanimalresp[2];
	$covec[$k]=$tpbanimalresp[3];}
if($treatments[$k]==3){$nestc[$k]=$pfanimalresp[0];$forgc[$k]=$pfanimalresp[1];$preyc[$k]=$pfanimalresp[2];
	$covec[$k]=$pfanimalresp[3];}
if($treatments[$k]==4){$nestc[$k]=$wfanimalresp[0];$forgc[$k]=$wfanimalresp[1];$preyc[$k]=$wfanimalresp[2];
	$covec[$k]=$wfanimalresp[3];}
}

@snestc=sort { $a<=>$b } @nestc;
@sforgc=sort { $a<=>$b } @forgc;
@spreyc=sort { $a<=>$b } @preyc;
@scovec=sort { $a<=>$b } @covec;


print <<"end1";

    <center><h3>Summary of Analysis</h3></center>
 <br>
 <font size=2> 
<p>Please keep in mind that the results from the Wildlife Habitat Response Model
 [(<a href=\"javascript:popuphistory()\"> <b>WHRM</b> version $version</a>)] provide a rapid 
assessment of <i>potential</i> effects of specified fuel treatments on a species habitats <u>based on published habitat 
relationships</u>. The studies used to make habitat change predictions for the $comname are: $source. 
You should examine the sources of information used to drive these predictions in the table and 
annotated bibliography below.  All WHRM predictions should be verified with a trained biologist familiar with 
the local populations and landscapes.</p>  

<p>Like other species, the $comname requires specific habitats and elements within those habitats for successful 
reproduction, for places to forage for food and find adequate nutrition, and for thermal or escape cover.
end1

if(($canopycover!~/^no/)&&($canopycover!~/^No/)){print <<"endcca";
The $comname prefers $canopycover, which could influence the probability of occurrence in the stand before and 
after the treatment.
endcca
}
print"</p>";
print <<"endcc";

<p>The post-treatment habitat suitability predictions are intended to increase awareness of which treatments 
may have negative effects on a species habitats and which habitat element changes are of most concern.  
Each life history requirement is examined separately.</p> 

endcc
print"<b>Habitat for Reproduction</b>";
if($snestc[0]==-99){print"<p>There is insufficient published information to evaluate effects of the selected fuel treatments on reproduction habitats. 
Please consult with a local wildlife biologist.</p>";
}
else{	if($snestc[0]>0){if($snestc[0]==$snestc[$#snestc]){print<<"nesp1";
<p>Of the selected fuel treatments, <b>WHRM</b>
predicts there will be no difference in effects on breeding and nesting habitats among 
treatments, and all the treatments resulted in a positive effect on reproduction habitats.
</p>
nesp1

		}
		else{print"<p>All the selected treatments resulted in a positive effect on reproduction habitat.</p>";}
	}
	elsif($snestc[0]==0){if($snestc[0]==$snestc[$#snestc]){print<<"nesp2";
<p>Of the selected fuel treatments, <b>WHRM</b>
predicts there will be no difference in effects on breeding and nesting habitats among 
treatments.</p>
nesp2

		}
		else{print"<p>All the selected treatments resulted in a positeve effect on reproduction habitat</p>";}
	}		
	else{
	print"<p>The following treatment(s) resulted in <u><b>negative</b></u> effects on reproduction habitat for the $species:";
	print"<ul>";
	for($j=0; $j<$tsize; $j++)
	{if($nestc[$j]<0){
	if($treatments[$j]==1){print"<li><b>$lnametreatment[$j]</b> where ";
		if($size1[$j]==1){print"change in $nestneg[0] contributed to these negative effects.";}
		elsif($size1[$j]==2){print"changes in $nestneg[0] and $nestneg[1] contributed to these negative effects.";}
		else{$tempstrig="changes in $nestneg[0], $nestneg[1], ";
		for($k=2; $k<$size1[$j]; $k++){$stopstrig=$size1[$j]-1;
		if($k==$stopstrig){$tempstrig=$tempstrig."and ".$nestneg[$k];}
		else{$tempstrig=$tempstrig.$nestneg[$k].", ";}

		}#endfork
		print $tempstrig." contributed to these negative effects. ";
		}#endelse
		print"</li>";
	}#endtretif
	if($treatments[$j]==2){print"<li><b>$lnametreatment[$j]</b> where ";
		if($size1[$j]==1){print"change in $tpbnestneg[0] contributed to these negative effects.";}
		elsif($size1[$j]==2){print"changes in $tpbnestneg[0] and $tpbnestneg[1] contributed to these negative effects.";}
		else{$tempstrig="changes in $tpbnestneg[0], $tpbnestneg[1], ";
		for($k=2; $k<$size1[$j]; $k++){$stopstrig=$size1[$j]-1;
		if($k==$stopstrig){$tempstrig=$tempstrig."and ".$tpbnestneg[$k];}
		else{$tempstrig=$tempstrig.$tpbnestneg[$k].", ";}

		}#endfork
		print $tempstrig." contributed to these negative effects. ";
		}#endelse
		print"</li>";
	}#endtretif
	if($treatments[$j]==3){print"<li><b>$lnametreatment[$j]</b> where ";
		if($size1[$j]==1){print"change in $pfnestneg[0] contributed to these negative effects.";}
		elsif($size1[$j]==2){print"changes in $pfnestneg[0] and $pfnestneg[1] contributed to these negative effects.";}
		else{$tempstrig="changes in $pfnestneg[0], $pfnestneg[1], ";
		for($k=2; $k<$size1[$j]; $k++){$stopstrig=$size1[$j]-1;
		if($k==$stopstrig){$tempstrig=$tempstrig."and ".$pfnestneg[$k];}
		else{$tempstrig=$tempstrig.$pfnestneg[$k].", ";}

		}#endfork
		print $tempstrig." contributed to these negative effects. ";
		}#endelse
		print"</li>";
	}#endtretif
	if($treatments[$j]==4){print"<li><b>$nametreatment[$j]</b> where ";
		if($size1[$j]==1){print"change in $wfnestneg[0] contributed to these negative effects.";}
		elsif($size1[$j]==2){print"changes in $wfnestneg[0] and $wfnestneg[1] contributed to these negative effects.";}
		else{$tempstrig="changes in $wfnestneg[0], $wfnestneg[1], ";
		for($k=2; $k<$size1[$j]; $k++){$stopstrig=$size1[$j]-1;
		if($k==$stopstrig){$tempstrig=$tempstrig."and ".$wfnestneg[$k];}
		else{$tempstrig=$tempstrig.$wfnestneg[$k].", ";}

		}#endfork
		print $tempstrig." contributed to these negative effects. ";
		}#endelse
		print"</li>";
	}#endtretif
	}#endif
	 }#forjend
	print"</ul></p>";
	}#elseend

}
print "<b>Foraging Habitat</b>";
if($sforgc[0]==-99)
{print"<p>There is insufficient published information to evaluate effects of the selected fuel treatments on foraging habitats. 
Please consult with a local wildlife biologist.</p>";
}
else{	if($sforgc[0]>0){if($sforgc[0]==$sforgc[$#sforgc]){print<<"forgp1";
<p>Of the selected fuel treatments, <b>WHRM</b>
predicts there will be no difference in effects on foraging habitats among 
treatments, and all the treatments resulted in a positive effect on foraging habitats.
</p>
forgp1

		}
		else{print"<p>All the selected treatments resulted in a positive effect on foraging habitat.</p>";}
	}
	elsif($sforgc[0]==0){if($sforgc[0]==$sforgc[$#sforgc]){print<<"forgp2";
<p>Of the selected fuel treatments, <b>WHRM</b>
predicts there will be no difference in effects on foraging habitats among 
treatments.</p>
forgp2

		}
		else{print"<p>All the selected treatments resulted in a positive effect on foraging habitat</p>";}
	}

	else{
	print"<p>The following treatment(s) resulted in <u><b>negative</b></u> effects on foraging habitat for the $species:";
	print"<ul>";
	for($j=0; $j<$tsize; $j++)
	{if($forgc[$j]<0){
	if($treatments[$j]==1){print"<li><b>$lnametreatment[$j]</b> where ";
		if($size2[$j]==1){print"change in $forgneg[0] contributed to these negative effects.";}
		elsif($size2[$j]==2){print"changes in $forgneg[0] and $forgneg[1] contributed to these negative effects.";}
		else{$tempstrig="changes in $forgneg[0], $forgneg[1], ";
		for($k=2; $k<$size2[$j]; $k++){$stopstrig=$size2[$j]-1;
		if($k==$stopstrig){$tempstrig=$tempstrig."and ".$forgneg[$k];}
		else{$tempstrig=$tempstrig.$forgneg[$k].", ";}

		}#endfork
		print $tempstrig." contributed to these negative effects. ";
		}#endelse
		print"</li>";
	}#endtretif
	if($treatments[$j]==2){print"<li><b>$lnametreatment[$j]</b> where ";
		if($size2[$j]==1){print"change in $tpbforgneg[0] contributed to these negative effects.";}
		elsif($size2[$j]==2){print"changes in $tpbforgneg[0] and $tpbforgneg[1] contributed to these negative effects.";}
		else{$tempstrig="changes in $tpbforgneg[0], $tpbforgneg[1], ";
		for($k=2; $k<$size2[$j]; $k++){$stopstrig=$size2[$j]-1;
		if($k==$stopstrig){$tempstrig=$tempstrig."and ".$tpbforgneg[$k];}
		else{$tempstrig=$tempstrig.$tpbforgneg[$k].", ";}

		}#endfork
		print $tempstrig." contributed to these negative effects. ";
		}#endelse
		print"</li>";
	}#endtretif
	if($treatments[$j]==3){print"<li><b>$lnametreatment[$j]</b> where ";
		if($size2[$j]==1){print"change in $pfforgneg[0] contributed to these negative effects.";}
		elsif($size2[$j]==2){print"changes in $pfforgneg[0] and $pfforgneg[1] contributed to these negative effects.";}
		else{$tempstrig="changes in $pfforgneg[0], $pfforgneg[1], ";
		for($k=2; $k<$size2[$j]; $k++){$stopstrig=$size2[$j]-1;
		if($k==$stopstrig){$tempstrig=$tempstrig."and ".$pfforgneg[$k];}
		else{$tempstrig=$tempstrig.$pfforgneg[$k].", ";}

		}#endfork
		print $tempstrig." contributed to these negative effects. ";
		}#endelse
		print"</li>";
	}#endtretif
	if($treatments[$j]==4){print"<li><b>$lnametreatment[$j]</b> where ";
		if($size2[$j]==1){print"change in $wfforgneg[0] contributed to these negative effects.";}
		elsif($size2[$j]==2){print"changes in $wfforgneg[0] and $wfforgneg[1] contributed to these negative effects.";}
		else{$tempstrig="changes in $wfforgneg[0], $wfforgneg[1], ";
		for($k=2; $k<$size2[$j]; $k++){$stopstrig=$size2[$j]-1;
		if($k==$stopstrig){$tempstrig=$tempstrig."and ".$wfforgneg[$k];}
		else{$tempstrig=$tempstrig.$wfnestneg[$k].", ";}

		}#endfork
		print $tempstrig." contributed to these negative effects. ";
		}#endelse
		print"</li>";
	}#endtretif
	}#endif
	 }#forend
	print"</ul></p>";
	}

}

print "<b>Prey Habitat or Forage</b>";
if($spreyc[0]==-99)
{print"<p>There is insufficient published information to evaluate effects of the selected fuel treatments on forage or prey habitat. 
Please consult with a local wildlife biologist.</p>";
}
else{	if($spreyc[0]>0){if($spreyc[0]==$spreyc[$#spreyc]){print<<"preyp1";
<p>Of the selected fuel treatments, <b>WHRM</b>
predicts there will be no difference in effects on forage or prey habitats among 
treatments, and all the treatments resulted in a positive effect on forage or prey habitats.
</p>
preyp1

		}
		else{print"<p>All the selected treatments resulted in a positive effect on forage or prey habitat.</p>";}
	}
	elsif($spreyc[0]==0){if($spreyc[0]==$spreyc[$#spreyc]){print<<"preyp2";
<p>Of the selected fuel treatments, <b>WHRM</b>
predicts there will be no difference in effects on forage or prey habitats among 
treatments.</p>
preyp2

		}
		else{print"<p>All the selected treatments resulted in a positive effect on forage or prey habitat.</p>";}
	}

	else{	
	print"<p>The following treatment(s) resulted in <u><b>negative</b></u> effects on forage or prey habitat  
	for the $species:";
	print"<ul>";
	for($j=0; $j<$tsize; $j++)
	{if($preyc[$j]<0){
	if($treatments[$j]==1){print"<li><b>$lnametreatment[$j]</b> where ";
		if($size3[$j]==1){print"change in $preyneg[0] contributed to these negative effects.";}
		elsif($size3[$j]==2){print"changes in $preyneg[0] and $preyneg[1] contributed to these negative effects.";}
		else{$tempstrig="changes in $preyneg[0], $preyneg[1], ";
		for($k=2; $k<$size3[$j]; $k++){$stopstrig=$size3[$j]-1;
		if($k==$stopstrig){$tempstrig=$tempstrig."and ".$preyneg[$k];}
		else{$tempstrig=$tempstrig.$preyneg[$k].", ";}

		}#endfork
		print $tempstrig." contributed to these negative effects. ";
		}#endelse
		print"</li>";
	}#endtretif
	if($treatments[$j]==2){print"<li><b>$lnametreatment[$j]</b> where ";
		if($size3[$j]==1){print"change in $tpbpreyneg[0] contributed to these negative effects.";}
		elsif($size3[$j]==2){print"changes in $tpbpreyneg[0] and $tpbpreyneg[1] contributed to these negative effects.";}
		else{$tempstrig="changes in $tpbpreyneg[0], $tpbpreyneg[1], ";
		for($k=2; $k<$size3[$j]; $k++){$stopstrig=$size3[$j]-1;
		if($k==$stopstrig){$tempstrig=$tempstrig."and ".$tpbpreyneg[$k];}
		else{$tempstrig=$tempstrig.$tpbpreyneg[$k].", ";}

		}#endfork
		print $tempstrig." contributed to these negative effects. ";
		}#endelse
		print"</li>";
	}#endtretif
	if($treatments[$j]==3){print"<li><b>$lnametreatment[$j]</b> where ";
		if($size3[$j]==1){print"change in $pfpreyneg[0] contributed to these negative effects.";}
		elsif($size3[$j]==2){print"changes in $pfpreyneg[0] and $pfpreyneg[1] contributed to these negative effects.";}
		else{$tempstrig="changes in $pfpreyneg[0], $pfpreyneg[1], ";
		for($k=2; $k<$size3[$j]; $k++){$stopstrig=$size3[$j]-1;
		if($k==$stopstrig){$tempstrig=$tempstrig."and ".$pfpreyneg[$k];}
		else{$tempstrig=$tempstrig.$pfpreyneg[$k].", ";}

		}#endfork
		print $tempstrig." contributed to these negative effects. ";
		}#endelse
		print"</li>";
	}#endtretif
	if($treatments[$j]==4){print"<li><b>$lnametreatment[$j]</b> where ";
		if($size3[$j]==1){print"change in $wfpreyneg[0] contributed to these negative effects.";}
		elsif($size3[$j]==2){print"changes in $wfpreyneg[0] and $wfpreyneg[1] contributed to these negative effects.";}
		else{$tempstrig="changes in $wfpreyneg[0], $wfpreyneg[1], ";
		for($k=2; $k<$size3[$j]; $k++){$stopstrig=$size3[$j]-1;
		if($k==$stopstrig){$tempstrig=$tempstrig."and ".$wfpreyneg[$k];}
		else{$tempstrig=$tempstrig.$wfnestneg[$k].", ";}

		}#endfork
		print $tempstrig." contributed to these negative effects. ";
		}#endelse
		print"</li>";
	}#endtretif
	}#endif
	 }#forend
	print"</ul></p>";
	}


}
print "<b>Cover Habitat</b>";
if($scovec[0]==-99)
{print"<p>There is insufficient published information to evaluate effects of the selected fuel treatments on cover habitats. 
Please consult with a local wildlife biologist.</p>";
}
else{	if($scovec[0]>0){if($scovec[0]==$scovec[$#scovec]){print<<"covep1";
<p>Of the selected fuel treatments, <b>WHRM</b>
predicts there will be no difference in effects on cover habitats among 
treatments, and all the treatments resulted in a positive effect on cover habitat.
</p>
covep1

		}
		else{print"<p>All the selected treatments resulted in a positive effect on cover habitat.</p>";}
	}
	elsif($scovec[0]==0){if($scovec[0]==$scovec[$#scovec]){print<<"covep2";
<p>Of the selected fuel treatments, <b>WHRM</b>
predicts there will be no difference in effects on cover habitats among 
treatments.</p>
covep2

		}
		else{print"<p>All the selected treatments resulted in a positive effect on cover habitat.</p>";}
	}



	else{
	print"<p>The following treatment(s) resulted in <u><b>negative</b></u> effects on cover habitat for the $species:";
	print"<ul>";
	for($j=0; $j<$tsize; $j++)
	{if($covec[$j]<0){
	if($treatments[$j]==1){print"<li><b>$lnametreatment[$j]</b> where ";
		if($size4[$j]==1){print"change in $coveneg[0] contributed to these negative effects.";}
		elsif($size4[$j]==2){print"changes in $coveneg[0] and $coveneg[1] contributed to these negative effects.";}
		else{$tempstrig="changes in $coveneg[0], $coveneg[1], ";
		for($k=2; $k<$size4[$j]; $k++){$stopstrig=$size4[$j]-1;
		if($k==$stopstrig){$tempstrig=$tempstrig."and ".$coveneg[$k];}
		else{$tempstrig=$tempstrig.$coveneg[$k].", ";}

		}#endfork
		print $tempstrig." contributed to these negative effects. ";
		}#endelse
		print"</li>";
	}#endtretif
	if($treatments[$j]==2){print"<li><b>$lnametreatment[$j]</b> where ";
		if($size4[$j]==1){print"change in $tpbcoveneg[0] contributed to these negative effects.";}
		elsif($size4[$j]==2){print"changes in $tpbcoveneg[0] and $tpbcoveneg[1] contributed to these negative effects.";}
		else{$tempstrig="changes in $tpbcoveneg[0], $tpbcoveneg[1], ";
		for($k=2; $k<$size4[$j]; $k++){$stopstrig=$size4[$j]-1;
		if($k==$stopstrig){$tempstrig=$tempstrig."and ".$tpbcoveneg[$k];}
		else{$tempstrig=$tempstrig.$tpbcoveneg[$k].", ";}

		}#endfork
		print $tempstrig." contributed to these negative effects. ";
		}#endelse
		print"</li>";
	}#endtretif
	if($treatments[$j]==3){print"<li><b>$lnametreatment[$j]</b> where ";
		if($size4[$j]==1){print"change in $pfcoveneg[0] contributed to these negative effects.";}
		elsif($size4[$j]==2){print"changes in $pfcoveneg[0] and $pfcoveneg[1] contributed to these negative effects.";}
		else{$tempstrig="changes in $pfcoveneg[0], $pfcoveneg[1], ";
		for($k=2; $k<$size4[$j]; $k++){$stopstrig=$size4[$j]-1;
		if($k==$stopstrig){$tempstrig=$tempstrig."and ".$pfcoveneg[$k];}
		else{$tempstrig=$tempstrig.$pfcoveneg[$k].", ";}

		}#endfork
		print $tempstrig." contributed to these negative effects. ";
		}#endelse
		print"</li>";
	}#endtretif
	if($treatments[$j]==4){print"<li>$nametreatment[$j] where ";
		if($size4[$j]==1){print"change in $wfcoveneg[0] contributed to these negative effects.";}
		elsif($size4[$j]==2){print"changes in $wfcoveneg[0] and $wfcoveneg[1] contributed to these negative effects.";}
		else{$tempstrig="changes in $wfcoveneg[0], $wfcoveneg[1], ";
		for($k=2; $k<$size4[$j]; $k++){$stopstrig=$size4[$j]-1;
		if($k==$stopstrig){$tempstrig=$tempstrig."and ".$wfcoveneg[$k];}
		else{$tempstrig=$tempstrig.$wfcoveneg[$k].", ";}

		}#endfork
		print $tempstrig." contributed to these negative effects. ";
		}#endelse
		print"</li>";
	}#endtretif
	}#endif
	 }#forend
	print"</ul></p>";
	}

}
print"</font>";


for($j=0; $j<$tsize; $j++){
if($treatments[$j]==1)
	{
	print " <!--deleteform method=post name=wildlifem2 action=https://localhost/Scripts/fuels/whrm/twhrm5.pl--> ";
        print " <form method=post name=wildlifem2 action=/cgi-bin/fuels/whrm/twhrm5.pl> ";
	print " <input type=\"hidden\" value=\"$taxgroup\" name=\"taxgroup\"> ";
	print " <input type=\"hidden\" value=\"$tax_group\" name=\"tax_group\"> ";
	print " <input type=\"hidden\" value=\"$species\" name=\"species\"> ";
	print " <input type=\"hidden\" value=\"$filename\" name=\"filename\"> ";
	print " <input type=\"hidden\" value=\"$temprow\" name=\"temprow\"> ";
	print " <input type=\"hidden\" value=\"Thinning and Broadcast Burning\" name=\"treatname\"> ";
	for($i=0; $i<$temprow; $i++)
	{print qq(<INPUT type="hidden" name="evalues$i" value="$tbfevalues[$i]">)}
	print " </form> ";
	}
if($treatments[$j]==2)
	{
	print " <!--deleteform method=post name=wildlifem2 action=https://localhost/Scripts/fuels/whrm/twhrm5.pl--> ";
        print " <form method=post name=wildlifem2 action=/cgi-bin/fuels/whrm/twhrm5.pl> ";
	print " <input type=\"hidden\" value=\"$taxgroup\" name=\"taxgroup\"> ";
	print " <input type=\"hidden\" value=\"$tax_group\" name=\"tax_group\"> ";
	print " <input type=\"hidden\" value=\"$species\" name=\"species\"> ";
	print " <input type=\"hidden\" value=\"$filename\" name=\"filename\"> ";
	print " <input type=\"hidden\" value=\"$temprow\" name=\"temprow\"> ";
	print " <input type=\"hidden\" value=\"Thinning and Pile Burning\" name=\"treatname\"> ";
	for($i=0; $i<$temprow; $i++)
	{print qq(<INPUT type="hidden" name="evalues$i" value="$tpbevalues[$i]">)}
	print " </form> ";
	}
if($treatments[$j]==3)
	{
	print " <!--deleteform method=post name=wildlifem2 action=https://localhost/Scripts/fuels/whrm/twhrm5.pl--> ";
        print " <form method=post name=wildlifem2 action=/cgi-bin/fuels/whrm/twhrm5.pl> ";
	print " <input type=\"hidden\" value=\"$taxgroup\" name=\"taxgroup\"> ";
	print " <input type=\"hidden\" value=\"$tax_group\" name=\"tax_group\"> ";
	print " <input type=\"hidden\" value=\"$species\" name=\"species\"> ";
	print " <input type=\"hidden\" value=\"$filename\" name=\"filename\"> ";
	print " <input type=\"hidden\" value=\"$temprow\" name=\"temprow\"> ";
	print " <input type=\"hidden\" value=\"Prescribed Fire\" name=\"treatname\"> ";
	for($i=0; $i<$temprow; $i++)
	{print qq(<INPUT type="hidden" name="evalues$i" value="$pfevalues[$i]">)}
	print " </form> ";
	}
if($treatments[$j]==4)
	{
	print " <!--deleteform method=post name=wildlifem2 action=https://localhost/Scripts/fuels/whrm/twhrm5.pl--> ";
        print " <form method=post name=wildlifem2 action=/cgi-bin/fuels/whrm/twhrm5.pl> ";
	print " <input type=\"hidden\" value=\"$taxgroup\" name=\"taxgroup\"> ";
	print " <input type=\"hidden\" value=\"$tax_group\" name=\"tax_group\"> ";
	print " <input type=\"hidden\" value=\"$species\" name=\"species\"> ";
	print " <input type=\"hidden\" value=\"$filename\" name=\"filename\"> ";
	print " <input type=\"hidden\" value=\"$temprow\" name=\"temprow\"> ";
	print " <input type=\"hidden\" value=\"Wildfire\" name=\"treatname\"> ";
	for($i=0; $i<$temprow; $i++)
	{print qq(<INPUT type="hidden" name="evalues$i" value="$wfevalues[$i]">)}
	print " </form> ";
	}

}

# print <<"end7";
#
#  </font>
# </body>
#</html>
#
#end7

###}#end of matrix
######################end of matrix
####else
####{
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
#print<<"fin1";
#<html>
# <head>
#  <title>Wildlife Habitat Response Model Literature Review</title>
# </head>
# <body>
### 2006.10.16 DEH

print<<"fin1";
   <center>
    <table align="center" border="2">
     <caption>
      <font size="4"><b>Background Information for the $comname (<i>$sciname</i>)</b></font>
     </caption>
fin1
for($i=0; $i<=12;$i++)
{print"
     <tr>
      <th colspan=2>
       <font size=2>$litreview[(2*$i)]</font>
      </th>
      <td>$litreview[(2*$i+1)]</td>
     </tr>
";}


#####################################

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

######################################
###new booton
print<<"fin99";
<table align=center>
<tr>
<td align=center>
       <!--deleteform method="post" name="wildlifem3" action="https://localhost/Scripts/fuels/whrm/twhrm2.pl"-->
       <form method="post" name="wildlifem3" action="/cgi-bin/fuels/whrm/twhrm2.pl">
fin99

for($i=0; $i<$tsize; $i++)
{print qq(<INPUT type="hidden" name="treatment$i" value="$treatments[$i]">)
}
print<<"end_ultimo";
  <INPUT type="hidden" name="tsize" value="$tsize">
  <br>
end_ultimo

print<<"fin100";
       <input type="submit" value="Select New Species"  NAME="firstpage">
       </form>
</td>
<td align=center>
       <!--delete<form method=\"post\" name=\"wildlifem4\" action=\"https://localhost/Scripts/fuels/whrm/twhrm1.pl\">-->
       <form method="post" name="wildlifem4" action="/cgi-bin/fuels/whrm/twhrm1.pl">
<br>
       <input type="submit" value="Select New Treatments and New Species"  NAME="indexpage">
       </form>
</td>
</tr>
</table>
       <br><br>
fin100

#######
print<<"fin11";
<P>
   <hr>
<table border=0 width=100%>
     <tr>
      <td valign="top" bgcolor="lightgoldenrodyellow">
       <font face="tahoma, arial, helvetica, sans serif" size=1>
        <b>Documentation and User Manual:</b>
        [<a href="/fuels/whrm/documents/ChapterIV_WHRM_web.pdf" target="_blank">User guide</a> (21-page PDF)]
        [<a href="https://www.fs.fed.us/rm/pubs/rmrs_rn023_04.pdf" target="_blank">Fact sheet</a> (1-page PDF)]
	[<a href="/fuels/whrm/documents/MasterBibliography.pdf " target="_blank"><b>Complete WHRM bibliography</b> </a>(39-page PDF)]
        <br>
        The Wildlife Habitat Response Model: <b>WH</b><b>RM</b><br>
        Input interface v.
        <a href="javascript:popuphistory()"> ',$version,'</a>
        (for review only) by Elena Velasquez &amp; David Hall<br>
        Model developed by: David Pilliod<br>
        Team leader Elaine Kennedy Sutherland, USDA Forest Service, Rocky Mountain Research Station
       </font>
      </td>
      <td valign="top">
       <a href="https://forest.moscowfsl.wsu.edu/fswepp/comments.html" target="comments"><img src="/fswepp/images/epaemail.gif" align="right" border=0></a>
      </td>
     </tr>
   </table>
</font>
    </body>
</html>
fin11
######}#endofelsematrix

sub featurecheck{
my @array=@_;
my $size;
$size=(@array);
for($i=0; $i<=$size-1;$i++)
{
    if(($array[$i]==27)||($array[$i]==33)||($array[$i]==39)){$array[$i]=21}
    if(($array[$i]==28)||($array[$i]==34)||($array[$i]==40)){$array[$i]=22}
    if(($array[$i]==29)||($array[$i]==35)||($array[$i]==41)){$array[$i]=23}
    if(($array[$i]==30)||($array[$i]==36)||($array[$i]==42)){$array[$i]=24}
    if(($array[$i]==31)||($array[$i]==37)||($array[$i]==43)){$array[$i]=25}
    if(($array[$i]==32)||($array[$i]==38)||($array[$i]==44)){$array[$i]=26}
}
return @array;
}
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

####    2004.12.13 DEH log the run
