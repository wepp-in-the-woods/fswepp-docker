#!/usr/bin/perl
##!C:\Perl\bin\perl.exe T-w
#use strict;
use CGI ':standard';

### urm.pl from Elena 2005.01.24 ###

# 2005.08.24 EV
# 2005.02.03 DEH chsnged to Tahoma font (not complete within tables)
#		 format HTML output better (incomplete)
#		 version no. to "minutes/days old"
# 2005.02.03 EV updated function checkfirecanopy1()
### 2005.01.25 DEH fixed path to plantsearch.pl ###

#use strict;
use CGI ':standard';
##########################################
# code name: urm.pl                      #
##########################################            
$debug=0;
$hdebug=0;
###$weedspeciesf=1;
###$plantspecies=1;
$version = '2005.02.03';
      $days_old = -M 'urm.pl';
      $long_ago = sprintf '%.2f', $days_old; $time=' days';
      if ($long_ago < 1) {$long_ago = sprintf '%.2f', $days_old*24; $time=' hours'}
      if ($long_ago < 1) {$long_ago = sprintf '%.2f', $days_old*24*60; $time=' minutes'}
$version = '[urm.pl ' . $long_ago . $time . ' old]';

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
$lengthenames=@enames;
if($lengthenames>=2)
{
	for($i=0; $i<=(@enames-2);$i++)
	{$evalues[$i]=param($enames[$i]);
	}
$action=pop(@enames);
}
else
{
$action=pop(@enames);
}

if($hdebug)
{
print "<p>@enames";
print "<p>@evalues";
print "<p>action is $action";
}

########################################
## HTML output of all the input        #
########################################

$tsize=param('tsize');
for($j=0; $j<$tsize; $j++)
{
if($j==0){$treatments[$j]=param('treatment0')}
elsif($j==1){$treatments[$j]=param('treatment1')}
elsif($j==2){$treatments[$j]=param('treatment2')}
else{$treatments[$j]=param('treatment3')}
}

if ($debug)
{
print "<p>Number of treatments selected is: $tsize<br>";
print "<p>treatments are: @treatments";
}


#################################
#html inputs
##############################

print<<"end_primero";
<html>
 <head>
  <meta name="vs_showGrid" content="True">
  <title>The Understory Response Model</title>
  <SCRIPT LANGUAGE="JavaScript" type="TEXT/JAVASCRIPT">
  <!--
var spanlife = new Array("Perennial","Perennial","Annual","Perennial","Perennial","Perennial","Biennial","Perennial","Biennial","Annual","Perennial","Perennial","Perennial","Biennial","Biennial","Annual","Perennial","Perennial","Perennial","Perennial","Biennial","Perennial","Perennial","Perennial","Biennial","Perennial","Biennial","Biennial","Perennial","Annual","Annual");
var locbud = new Array("Root Crown","Root Crown","Root Crown","Rhizome","Rhizome","Rhizome","Root Crown","Root Crown","Root Crown","Root Crown","Root Crown","Root Crown","Rhizome","Root Crown","Root Crown","Root Crown","Rhizome","Rhizome","Rhizome","Root Crown","Root Crown","Rhizome","Root Crown","Root Crown","Root Crown","Root Crown","Root Crown","Root Crown","Rhizome","Root Crown","Root Crown");
var reproveg = new Array("Yes","Yes","No","Yes","Yes","Yes","No","Yes","No","No","No","Yes","Yes","No","No","No","Yes","Yes","Yes","Yes","No","Yes","Yes","Yes","No","Yes","No","Yes","Yes","No","No");
var disseed = new Array("Long","Long","Gravity","Long","Long","Long","Short","Short","Long","Long","Long","Long","Long","Short","Gravity","Long","Long","Long","Long","Short","Short","Short","Short","Short","Long","Gravity","Long","Short","Long","Long","Gravity");
var bankseed = new Array("Yes","Yes","Yes","Yes","Yes","Yes","Yes","Yes","Yes","Yes","Unknown","No","Yes","Yes","No","Yes","Yes","Yes","Yes","Yes","Yes","Yes","Yes","Yes","Yes","Yes","Unknown","Yes","Yes","Unknown","Yes");

function fillweed(){
  var weedval = window.document.plantsimulator.tipo.value;

if(weedval==0){alert("Your Weed is not in the database. You need to input all the information manually");}
//Setting Plant accurrence
//Setting Life Span
//alert("the value of spanlife is " +spanlife[weedval]);
if(spanlife[weedval]=="Annual"){annualselect=true;biennialselect=false;perennialselect=false}
if(spanlife[weedval]=="Biennial"){annualselect=false;biennialselect=true;perennialselect=false}
if(spanlife[weedval]=="Perennial"){annualselect=false;biennialselect=false;perennialselect=true}
//setting life duration
document.plantsimulator.life_duration.options.length=0;
document.plantsimulator.life_duration.options[0]=new Option("Select one","Select one","Select one","Select one");
document.plantsimulator.life_duration.options[1]=new Option("Annual","Annual",false,annualselect);
document.plantsimulator.life_duration.options[2]=new Option("Biennial","Biennial",false,biennialselect);
document.plantsimulator.life_duration.options[3]=new Option("Perennial","Perennial",false,perennialselect);
//Setting Life Form
document.plantsimulator.life_form.options.length=0;
document.plantsimulator.life_form.options[0]=new Option("Select one","Select one","Select one","Select one");
document.plantsimulator.life_form.options[1]=new Option("Herb (Grass or Forb)","Forb",false,true);
document.plantsimulator.life_form.options[2]=new Option("Shrub","Shrub",false,false);
//Setting Root Location
document.plantsimulator.root_loc.options.length=0;
document.plantsimulator.root_loc.options[0]=new Option("Select one","Select one","Select one","Select one");
document.plantsimulator.root_loc.options[1]=new Option("Duff","duff",false,false);
document.plantsimulator.root_loc.options[2]=new Option("Mineral Soil","mineral",false,true);
//Setting Bud Location
if(locbud[weedval]=="Root Crown"){rootselect=true;rhizomeselect=false}
if(locbud[weedval]=="Rhizome"){rootselect=false;rhizomeselect=true}
document.plantsimulator.bud_loc.options.length=0;
document.plantsimulator.bud_loc.options[0]=new Option("Select one","Select one","Select one","Select one");
document.plantsimulator.bud_loc.options[1]=new Option("Stolon","stolon",false,false);
document.plantsimulator.bud_loc.options[2]=new Option("Root Crown","crown",false,rootselect);
document.plantsimulator.bud_loc.options[3]=new Option("Rhizome","rhizome",false,rhizomeselect);
document.plantsimulator.bud_loc.options[4]=new Option("BulbCorn","bulb",false,false);
//Setting Vegetative Reproduction
if(reproveg[weedval]=="Yes"){yvegrselect=true;nvegrselect=false;}
if(reproveg[weedval]=="No"){yvegrselect=false;nvegrselect=true;}
document.plantsimulator.veg_repro.options.length=0;
document.plantsimulator.veg_repro.options[0]=new Option("Select one","Select one","Select one","Select one");
document.plantsimulator.veg_repro.options[1]=new Option("Yes","1",false,yvegrselect);
document.plantsimulator.veg_repro.options[2]=new Option("No","0",false,nvegrselect);
//Setting Sprouts
document.plantsimulator.sprouts.options.length=0;
document.plantsimulator.sprouts.options[0]=new Option("Select one","Select one","Select one","Select one");
document.plantsimulator.sprouts.options[1]=new Option("Yes","1",false,false);
document.plantsimulator.sprouts.options[2]=new Option("No","0",false,true);
//Setting Preferred Light Level
document.plantsimulator.shade_tol.options.length=0;
document.plantsimulator.shade_tol.options[0]=new Option("Select one","Select one","Select one","Select one");
document.plantsimulator.shade_tol.options[1]=new Option("Open Canopy Colonizer Early Successional Intolerant","0",false,true);
document.plantsimulator.shade_tol.options[2]=new Option("Partial Canopy Mid Successional Moderate","1",false,false);
document.plantsimulator.shade_tol.options[3]=new Option("Closed Canopy Late Successional Climax Tolerant","2",false,false);
//Setting Seed Dispersal
if(disseed[weedval]=="Long"){longselect=true;shortselect=false;gravityselect=false}
if(disseed[weedval]=="Short"){longselect=false;shortselect=true;gravityselect=false}
if(disseed[weedval]=="Gravity"){longselect=false;shortselect=false;gravityselect=true}
document.plantsimulator.seed_dis.options.length=0;
document.plantsimulator.seed_dis.options[0]=new Option("Select one","Select one","Select one","Select one");
document.plantsimulator.seed_dis.options[1]=new Option("Long distance dispersal","0",false,longselect);
document.plantsimulator.seed_dis.options[2]=new Option("Short distance dispersal","1",false,shortselect);
document.plantsimulator.seed_dis.options[3]=new Option("Gravity dispersal","3",false,gravityselect);
document.plantsimulator.seed_dis.options[4]=new Option("Low Seed Production","4",false,false);
document.plantsimulator.seed_dis.options[5]=new Option("Unknown","5",false,false);
//Setting Seed Banking
if(bankseed[weedval]=="Yes"){ysebaselect=true;nsebaselect=false;unsebaselect=false}
if(bankseed[weedval]=="No"){ysebaselect=false;nsebaselect=true;unsebaselect=false}
if(bankseed[weedval]=="Unknown"){ysebaselect=false;nsebaselect=false;unsebaselect=true}
document.plantsimulator.seed_banking.options.length=0;
document.plantsimulator.seed_banking.options[0]=new Option("Select one","Select one","Select one","Select one");
document.plantsimulator.seed_banking.options[1]=new Option("Yes","1",false,ysebaselect);
document.plantsimulator.seed_banking.options[2]=new Option("No","0",false,nsebaselect);
document.plantsimulator.seed_banking.options[3]=new Option("Unknown","2",false,unsebaselect);
//Setting Fire Stimulated Seeds
document.plantsimulator.Refractory.options.length=0;
document.plantsimulator.Refractory.options[0]=new Option("Select one","Select one","Select one","Select one");
document.plantsimulator.Refractory.options[1]=new Option("Yes","2",false,false);
document.plantsimulator.Refractory.options[2]=new Option("No","3",false,true);

}

function NewWindow(){
alert("I am in newwindow function");
  var newWin = window.open("","newWindow","width=400,height=600,top=100,left=400,status=1,scrollbars=1,resizable=1");
  if (newWin==null) {}
  else {
   if (newWin.opener==null){remote.opener=window}
    newWin.document.writeln('<html>')
    newWin.document.writeln(' <head>')
    newWin.document.writeln('  <title>Weed Search window</title>')
    newWin.document.writeln('  <script language="JavaScript" type="text/javascript">')
    newWin.document.writeln('')
    newWin.document.writeln('   function set_text()')
    newWin.document.writeln('   {')
    newWin.document.writeln('   //	alert(opener.document.plantsimulator.species.value)')
    newWin.document.writeln('')
    newWin.document.writeln('     document.elena1.scispecies.value = opener.document.plantsimulator.tipo.value')
    newWin.document.writeln('   }')
    newWin.document.writeln('')
    newWin.document.writeln('   </script>')    
    newWin.document.writeln(' </head>')
    newWin.document.writeln(' <body onload="set_text()">')
    newWin.document.writeln('  <font face="arial">')
    newWin.document.writeln('   <h4>URM Weed search<br>by selection of the special list of Weeds</h4>')
    newWin.document.writeln('   <form method="post" name="elena1" action="https://localhost/Scripts/fuels/urm/test/weedsearch.pl">')
//    newWin.document.writeln('   <form method="post" name="elena" action="/cgi-bin/fuels/urm/weedsearch.pl">')
    newWin.document.writeln('    <input type="text" size="40" name="scispecies" onFocus="select()">&nbsp;')
    newWin.document.writeln('    <input type="submit" value="search and autofill" NAME="action1">')
    newWin.document.writeln('   </form>')
    newWin.document.writeln('  </font>')
    newWin.document.writeln(' </body>')
    newWin.document.writeln('</html>')
    newWin.document.close()
    newWin.focus()
  }

}

function popUp(){

  var mywin = window.open("","mywin","width=400,height=600,top=100,left=400,status=1,scrollbars=1,resizable=1");
  if (mywin==null) {}
  else {
    if (mywin.opener==null){remote.opener=window}
    mywin.document.writeln('<html>')
    mywin.document.writeln(' <head>')
    mywin.document.writeln('  <title>Search window</title>')
    mywin.document.writeln('  <script language="JavaScript" type="text/javascript">')
    mywin.document.writeln('')
    mywin.document.writeln('   function set_text()')
    mywin.document.writeln('   {')
    mywin.document.writeln('   //	alert(opener.document.plantsimulator.species.value)')
    mywin.document.writeln('')
    mywin.document.writeln('     document.elena.scispecies.value = opener.document.plantsimulator.species.value')
    mywin.document.writeln('   }')
    mywin.document.writeln('')
    mywin.document.writeln('//    window.opener.document.location.href="plantsim.html";')
    mywin.document.writeln('   </script>')
    mywin.document.writeln(' </head>')
    mywin.document.writeln(' <body onload="set_text()">')
    mywin.document.writeln('  <font face="arial">')
    mywin.document.writeln('   <h4>URM plant information search<br>by scientific name</h4>')
  mywin.document.writeln('   <form method="post" name="elena" action="https://localhost/Scripts/fuels/urm/test/plantsearch2.pl">')
//    mywin.document.writeln('   <form method="post" name="elena" action="/cgi-bin/fuels/urm/test/plantsearch2.pl">')
    mywin.document.writeln('    <input type="text" name="scispecies" onFocus="select()">&nbsp;')
    mywin.document.writeln('    <input type="submit" value="search" NAME="action1">')
    mywin.document.writeln('   </form>')
    mywin.document.writeln('  </font>')
    mywin.document.writeln(' </body>')
    mywin.document.writeln('</html>')
    mywin.document.close()
    mywin.focus()
  }

}

function explain_sitepresence() {
    newin = window.open('','road_density','width=640,scrollbars=yes,resizable=1')
    var newWin = newin.document.open()
    if (newWin != null) {
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>Understory Response Model</title>')
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
      newin.document.writeln('      <h3>Understory Response Model<br><br>Plant Occurrence</h3><br>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td></tr>')
      newin.document.writeln('   </table>')
//      newin.document.writeln('   Site Presence is .')
      newin.document.writeln('  Does the plant occur within the treatment area (<b>on-site</b>) or outside the treatment area (<b>off-site</b>)?  This value, along with <b>seed dispersal</b>, affects colonization.')
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

function explain_lifeform() {
    newin = window.open('','road_density','width=640,scrollbars=yes,resizable=1')
    var newWin = newin.document.open()
    if (newWin != null) {
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>Understory Response Model</title>')
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
      newin.document.writeln('      <h3>Understory Response Model<br><br>Life Form</h3><br>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td></tr>')
      newin.document.writeln('   </table>')
//     newin.document.writeln('   Life Form is.')
      newin.document.writeln('   What is the over all morphology of a plant?  An <b>herb</b> is a non-woody plant where the stem dies back to the ground at the end of the growing season (e.g., grasses and forbs).  A <b>shrub</b> is a multi-stemmed, woody plant that is smaller than a tree.  This value affects post-fire plant survival.')
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
function explain_lifespan() {
    newin = window.open('','road_density','width=640,scrollbars=yes,resizable=1')
    var newWin = newin.document.open()
    if (newWin != null) {
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>Understory Response Model</title>')
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
      newin.document.writeln('      <h3>Understory Response Model<br><br>Life Span</h3><br>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td></tr>')
      newin.document.writeln('   </table>')
//      newin.document.writeln('   Life span is .')
      newin.document.writeln('   Longevity or average duration of the species.  <b>Annual</b> plants complete their life cycle (germinate, grow, reproduce, and die) in one year.  <b>Biennial</b> plants complete their life cycle in two years. <b>Perennial</b> plants complete their life cycle over more than two years.  This value affects post-treatment plant survival and <b>vegetative reproduction</b>.')
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
function explain_budlocation() {
    newin = window.open('','road_density','width=640,scrollbars=yes,resizable=1')
    var newWin = newin.document.open()
    if (newWin != null) {
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>Understory Response Model</title>')
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
      newin.document.writeln('      <h3>Understory Response Model<br><br>Bud Location on Plant</h3><br>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td></tr>')
      newin.document.writeln('   </table>')
//      newin.document.writeln('   Bud location is .')
      newin.document.writeln('   Where are the perenating tissues located?  <b>Stolons</b> are stems or branches that grow along the ground surface, taking root at their nodes.  Buds at the <b>root crown</b> are located at the transition point between the stems and root at or near the ground surface.  <b>Rhizomes</b> are stems growing beneath the ground surface with roots commonly produced from the nodes and buds produced in the leaf axils.  <b>Bulbs</b> and <b>corms</b> are underground plant storage organs that bear roots on their lower surface and fleshy leaves above.  This value affects post-fire plant survival.')
      newin.document.writeln('	<br><br><center><img src="/fuels/urm/images/life_form.gif" width=600 height=500 border=0></center>')
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
function explain_vegreproduction() {
    newin = window.open('','road_density','width=640,scrollbars=yes,resizable=1')
    var newWin = newin.document.open()
    if (newWin != null) {
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>Understory Response Model</title>')
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
      newin.document.writeln('      <h3>Understory Response Model<br><br>Vegetative Reproduction</h3><br>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td></tr>')
      newin.document.writeln('   </table>')
//      newin.document.writeln('   Vegetative reproduction is.')
      newin.document.writeln('   A form of asexual reproduction in which parts of the parent plant can become detached and generate new plants.  Such parts include: <b>stolons</b>, <b>rhizomes</b>, <b>bulbs</b>, and <b>corms</b>.  This value affects clonal growth  in the survivorship pathway.')
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
function explain_weed() {
    newin = window.open('','road_density','width=640,scrollbars=yes,resizable=1')
    var newWin = newin.document.open()
    if (newWin != null) {
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>Understory Response Model</title>')
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
      newin.document.writeln('      <h3>Understory Response Model<br><br>Weed</h3><br>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td></tr>')
      newin.document.writeln('   </table>')
//      newin.document.writeln('   Vegetative reproduction is.')
      newin.document.writeln('   Plants that are considered by the Plants Database to be invasive or have a high potential to become invasive.  This value affects post-treatment survival and reproduction.')
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
function explain_sprouts() {
    newin = window.open('','road_density','width=640,scrollbars=yes,resizable=1')
    var newWin = newin.document.open()
    if (newWin != null) {
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>Understory Response Model</title>')
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
      newin.document.writeln('      <h3>Understory Response Model<br><br>Sprouts</h3><br>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td></tr>')
      newin.document.writeln('   </table>')
//      newin.document.writeln('   Sprouts is.')
      newin.document.writeln('   A shoot arising from adventitious or dormant buds at the base of a woody plant (e.g., <b>shrub</b>).  This value affects post-fire survival in <b>shrubs</b>.')
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
function explain_lightlevel() {
    newin = window.open('','road_density','width=640,scrollbars=yes,resizable=1')
    var newWin = newin.document.open()
    if (newWin != null) {
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>Understory Response Model</title>')
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
      newin.document.writeln('      <h3>Understory Response Model<br><br>Preferred Light Level</h3><br>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td></tr>')
      newin.document.writeln('   </table>')
//      newin.document.writeln('   Preferred light level is .')
      newin.document.writeln('   Relative light condition (<b>open</b>, <b>partial</b>, or <b>closed canopy</b>) that optimizes plant growth.  This can be approximated by successional status (<b>early</b>,<b> mid</b>, or <b>late</b>) or shade tolerance (<b>intolerant</b>, <b>moderate</b>, or <b>tolerant</b>).   This value affects plant and seedling response to changes in <b>canopy cover</b>.')
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
function explain_seeddispersal() {
    newin = window.open('','road_density','width=640,scrollbars=yes,resizable=1')
    var newWin = newin.document.open()
    if (newWin != null) {
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>Understory Response Model</title>')
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
      newin.document.writeln('      <h3>Understory Response Model<br><br>Seed Dispersal</h3><br>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td></tr>')
      newin.document.writeln('   </table>')
//      newin.document.writeln('   Seed dispersal is.')
      newin.document.writeln('   Relative distance that seeds move from the parent plant.  <b>Long-distance</b> dispersed seeds are commonly wind dispersed (e.g., cottonwood, thistles, fireweed).  <b>Short-distance</b> dispersed seeds may be wind or animal dispersed.  <b>Gravity</b> dispersed seeds are fall near the plant.  Plants with <b>low seed production</b> produce few or no seeds and rely on <b>vegetative reproduction</b>.  This value, along with <b>size of treated area</b>, affects on- and off-site colonization.')
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
function explain_seedbank() {
    newin = window.open('','road_density','width=640,scrollbars=yes,resizable=1')
    var newWin = newin.document.open()
    if (newWin != null) {
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>Understory Response Model</title>')
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
      newin.document.writeln('      <h3>Understory Response Model<br><br>Seed Bank</h3><br>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td></tr>')
      newin.document.writeln('   </table>')
//      newin.document.writeln('   Seed bank is.')
      newin.document.writeln('   Plants that maintain a significant number of viable seeds in the soil for 3 or more years.  This value affects stored seeds in the reproduction pathway.')
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
function explain_fireseeds() {
    newin = window.open('','road_density','width=640,scrollbars=yes,resizable=1')
    var newWin = newin.document.open()
    if (newWin != null) {
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>Understory Response Model</title>')
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
      newin.document.writeln('      <h3>Understory Response Model<br><br>Fire Stimulated Seeds:</h3><br>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td></tr>')
      newin.document.writeln('   </table>')
      newin.document.writeln('   Seeds that germinate in response to high temperatures and/or exposure to smoke of post-fire leachate (same as refractory seeds).  This value affects seed germination for fire-adapted species.')
//      newin.document.writeln('   Road segments more than 200 ft (60 m) from ephemeral or perennial channels  generally can be ignored.')
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
function explain_rootlocation() {
    newin = window.open('','road_density','width=640,scrollbars=yes,resizable=1')
    var newWin = newin.document.open()
    if (newWin != null) {
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>Understory Response Model</title>')
      newin.document.writeln('  <style>')
      newin.document.writeln('   BODY')
      newin.document.writeln('   {scrollbar-base-color:666666;scrollbar-face-color:#333333;scrollbar-highlight-color:#333333;scrollbar-shadow-color:666666;scrollbar-dark-shadow-color:ffffcc;scrollbar-arrow-color:ff6600}')
      newin.document.writeln('   .question {color:ffffcc}')
      newin.document.writeln('   .header {color:ffffcc}')
      newin.document.writeln('   .highlight {font-weight:bold}')
      newin.document.writeln('  </style>')
      newin.document.writeln(' </HEAD>')
      newin.document.writeln(' <body bgcolor="ivory" onLoad="top.window.focus()" link="#99ff00" vlink="#99ff00" text="#006009">')
      newin.document.writeln('  <font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('   <table width=100%>')
      newin.document.writeln('    <tr><td bgcolor="#99ff00" align="center">')
      newin.document.writeln('     <font face="tahoma, arial, helvetica, sans serif">')
      newin.document.writeln('      <h3>Understory Response Model <br><br> Bud Location in the Soil Profile</h3><br>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td></tr>')
      newin.document.writeln('   </table>')
//      newin.document.writeln('   Root Location is .')
      newin.document.writeln('   Are the buds on or in the <b>litter/duff</b> or on or in the <b>mineral soil</b>?  This value affects post-fire plant survival.')
      newin.document.writeln('	<br><br><center><img src="/fuels/urm/images/life_form.gif" width=600 height=500 border=0></center>')
      newin.document.writeln('<!--tool bar begins--><p>')
      newin.document.writeln('  <table bgcolor="#666666" width="20%" border="0" cellspacing="1" cellpadding="5" align="center">')
      newin.document.writeln('   <tr>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      //newin.document.writeln(' onMouseOver="this.style.backgroundColor=\'#000000\';"')
      //newin.document.writeln(' onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln(' <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln(' <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.print()">Print me</a>')
      newin.document.writeln(' </font>')
      newin.document.writeln('</td>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      //newin.document.writeln(' onMouseOver="this.style.backgroundColor=\'#000000\';"')
      //newin.document.writeln(' onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln(' <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln('  <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.close()">Close me</a>')
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

function blankStatus()
{
  window.status = ""
  return true                           // p. 86
}

function showTexture()
{
  var which = window.document.plantsimulator.moisture_cond1.selectedIndex;
  if (which == 0)             //very dry
     {text = "1 hr fuels 6%, 1000 hr fuel 10%, duff 20%, soil 5% "}
   else if (which == 1)       // dry
     {text = "1 hr fuels 10%, 1000 hr fuel 15%, duff 40%, soil 10% "}
   else if (which == 2)       // moderate
     {text = "1 hr fuels 16%, 1000 hr fuel 30%, duff 75%, soil 15% "}
   else                       // wet
     {text = "1 hr fuels 22%, 1000hr fuel 40%, duff 130%, soil 25% "}
   window.status = text
   return true                           // p. 86
}

function checkrefractory()
{
var myform = document.forms[0];
var seedbankingIdx = myform.seed_banking.selectedIndex;
var refractoryIdx = myform.Refractory.selectedIndex;
//alert("I am here");
var part1="you have selected no for seed banking and yes for fire stimulated seed."
var part2="this combination is not possible, Plese change it."
if((seedbankingIdx==2)&&(refractoryIdx==1))
	{alert(part1+part2);
	myform.seed_banking.selectedIndex=-1;
	myform.seed_banking.focus();
	}
}

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

function weedchanged(){
var valweed=window.document.plantsimulator.weed.value;
if(valweed==-2){
     document.getElementById('specspan').innerHTML='';
}
 if(valweed==0){
     document.getElementById('specspan').innerHTML='<INPUT type=\"text\" size=\"30\"  NAME=\"species\">\\n'+'[<a href=\"\" onClick=\"popUp();return false\">\\n'+ '<font size=\"4\ color=\"#006009\">Search</font></a>]';
}
 if(valweed==1){
//alert("the value is one");
mymenu = '<select name=\"tipo\" size=\"6\" onChange=\"fillweed()\">\\n';
mymenu += '<option selected value=\"0\">The weed is not in the list</option>\\n';
mymenu += '<option value=\"1\">Acroptilon repens/hardheads (ACRE3)</option>\\n';
mymenu += '<option value=\"2\">Bromus tectorum/cheatgrass (BRTE)</option>\\n';
mymenu += '<option value=\"3\">Cardaria chalapa/lenspod whitetop (CACH10)</option>\\n';
mymenu += '<option value=\"4\">Cardaria draba/whitetop (CADR)</option>\\n';
mymenu += '<option value=\"5\">Cardaria pubescens/hairy whitetop (CAPU6)</option>\\n';
mymenu += '<option value=\"6\">Cardus nutans/nodding plumeless thistle (CANU4)</option>\\n';
mymenu += '<option value=\"7\">Centaurea biebersteinii/spotted knapweed (CEBI2)</option>\\n';
mymenu += '<option value=\"8\">Centaurea diffusa/white knapweed (CEBI2)</option>\\n';
mymenu += '<option value=\"9\">Centaurea solstitialis/yellow star-thistle (CESO3)</option>\\n';
mymenu += '<option value=\"10\">Centaurea triumfettii/squarrose knapweed(CETR8)</option>\\n';
mymenu += '<option value=\"11\">Chondrilla junce/hogbite (CHJU)</option>\\n';	
mymenu += '<option value=\"12\">Cirsium arvense/Canada thistle (CIAR4)</option>\\n';	
mymenu += '<option value=\"13\">Cirsium vulgare/bull thistle (CIVU)</option>\\n';	
mymenu += '<option value=\"14\">Conium maculatum/poison hemlock (COMA2)</option>\\n';	
mymenu += '<option value=\"15\">Crupina vulgaris/common crupina (CRVU2)</option>\\n';	
mymenu += '<option value=\"16\">Euphorbia escula/leafy spurge (EUES)</option>\\n';	
mymenu += '<option value=\"17\">Hieraceum aurantiacum/orange hawkweed (HIAU)</option>\\n';	
mymenu += '<option value=\"18\">Hieracium caespitosum/meadow hawkweed (HICA10)</option>\\n';
mymenu += '<option value=\"19\">Hypericum perforatum/common St. Johnswort (HYPE)</option>\\n';	
mymenu += '<option value=\"20\">Isatis tinctoria/Dyer\"s woad (ISTI)</option>\\n';
mymenu += '<option value=\"21\">Leucanthemum vulgare/oxeye daisy (LEVU)</option>\\n';	
mymenu += '<option value=\"22\">Linaria dalmatica/Dalmatian toadflax (LIDA)</option>\\n';	
mymenu += '<option value=\"23\">Linaria vulgaris/butter and eggs (LIVU2)</option>\\n';	
mymenu += '<option value=\"24\">Onopordum acanthium/Scotch cottonthistle (ONAC)</option>\\n';	
mymenu += '<option value=\"25\">Potentilla recta/sulphur cinquefoil (PORE5)</option>\\n';	
mymenu += '<option value=\"26\">Salvia aethiopis/Mediterranean sage (SAAE)</option>\\n';	
mymenu += '<option value=\"27\">Senecio jacobaca/stinking willie (SEJA)</option>\\n';	
mymenu += '<option value=\"28\">Sonchus arvensis/field sowthistle (SOAR2)</option>\\n';	
mymenu += '<option value=\"29\">Sonchus asper/spiny sowthistle (SOAS)</option>\\n';	
mymenu += '<option value=\"30\">Taeniatherum caput-medusae/medusahead (TACA8)</option>\\n';
mymenu += '</select>';
     document.getElementById('specspan').innerHTML=mymenu;
//
	}
}
function checkform2() {
var myform = document.forms[0];
var weedIdx = myform.weed.selectedIndex;
var tipIdx = -2;
if(weedIdx == 1){var tipoIdx = myform.tipo.selectedIndex; }
if(weedIdx == 2){var species = myform.species.value;}
var sitepresenceIdx = myform.site_presence;
var lifedurationIdx = myform.life_duration.selectedIndex;
var lifeformIdx = myform.life_form.selectedIndex;
var budlocIdx = myform.bud_loc.selectedIndex;
var rootlocIdx = myform.root_loc.selectedIndex;
var vegreproIdx = myform.veg_repro.selectedIndex;
var sproutsIdx = myform.sprouts.selectedIndex;
var shadetolIdx = myform.shade_tol.selectedIndex;
var seeddisIdx = myform.seed_dis.selectedIndex;
var seedbankingIdx = myform.seed_banking.selectedIndex;
var refractoryIdx = myform.Refractory.selectedIndex;
if((weedIdx == 0)||(weedIdx == -1)){alert("you must select a value for weed?");myform.weed.focus();
return false;}
else if((weedIdx == 1)&&((tipoIdx == 0)||(tipoIdx == -1))){alert("you must select a value for species of weed. If the weed is not in the list please select NO for weed?");myform.weed.focus();
return false;}
else if((sitepresenceIdx == -1)||(sitepresenceIdx == 0)){alert("you must select a value for plant occurence");myform.site_presence.focus();
return false;}
else if((lifedurationIdx == -1)||(lifedurationIdx == 0)){alert("you must select a value for life span");myform.life_duration.focus();
return false;}
else if((lifeformIdx == -1)||(lifeformIdx == 0)){alert("you must select a value for life form");myform.life_form.focus();
return false;}
else if((budlocIdx == -1)||(budlocIdx == 0)){alert("you must select a value for bud location on plant");myform.bud_loc.focus();
return false;}
else if((rootlocIdx == -1)||(rootlocIdx == 0)){alert("you must select a value for bud location in the soil");myform.root_loc.focus();
return false;}
else if((vegreproIdx == -1)||(vegreproIdx == 0)){alert("you must select a value for vegetative reproduction?");myform.veg_repro.focus();
return false;}
else if((sproutsIdx == -1)||(sproutsIdx == 0)){alert("you must select a value for sprouts?");myform.sprouts.focus();
return false;}
else if((shadetolIdx == -1)||(shadetolIdx == 0)){alert("you must select a value for preferred light level");myform.shade_tol.focus();
return false;}
else if((seeddisIdx == -1)||(seeddisIdx == 0)){alert("you must select a value for seed dispersal");myform.seed_dis.focus();
return false;}
else if((seedbankingIdx == -1)||(seedbankingIdx == 0)){alert("you must select a value for seed bank?");myform.seed_banking.focus();
return false;}
else if((refractoryIdx == -1)||(refractoryIdx == 0)){alert("you must select a value for fire stimulated seeds?");myform.Refractory.focus();
return false;}
else{if((weedIdx == 2)&&(species == "")){alert("you are running the model without a particular species in mind");}
return true;} 
  }

  // end hide -->
  </SCRIPT>
</head>
 <body link="#99ff00" vlink="#99ff00" alink="#99ff00" onload="weedchanged()">
  <font face="tahoma, arial, helvetica, sans serif">
   <table align="center" width="100%" border="0">
    <tr>
     <td><img src="https:/fuels/urm/images/muskthistle.jpg" alt="The Understory Response Model" align="left">
     </td>
     <td align="center"><hr>
      <font face="tahoma, arial, helvetica, sans serif">
       <h2>The Understory Response Model</h2>
       <hr>
      </font>
     </td>
     <td><img src="https:/fuels/urm/images/beargrass12.jpg" alt="The Understory Response Model" align="right">
     </td>
    </tr>
   </table>
   <!--elena<form method="post" name="plantsimulator" action="https://localhost/Scripts/fuels/urm/test/urm2.pl" onsubmit="return checkform2()">-->
   <form method="post" name="plantsimulator" action="https:/cgi-bin/fuels/urm/urm2.pl" onsubmit="return checkform2()">
    <br>
    <table align="center" border="2" cellpadding="5" cellspacing="5">
     <caption>
      <font face="tahoma, arial, helvetica, sans serif">
      <b><font size="4" color="#006009">Plant Characteristics </font></b>
     </caption>
     <tr>
      <th BGCOLOR="#006009">
       <font color="#99ff00">Weed?</font>
       <br>
       <a href="javascript:explain_weed()"
           onMouseOver="window.status='Explain Weed (new window)';return true"
           onMouseOut="window.status='Understory Response Model'; return true">
         <img src="/fuels/urm/images/quest2.gif" width="18" height="16" border="0"></a>
      </th>
      <td colspan="2">
       <SELECT size="3" NAME="weed" onChange="weedchanged()">
       <OPTION selected value="-2">select one</OPTION>
        <OPTION value="1">Yes</OPTION>
        <option value="0">No</option>
       </SELECT>
      </td>
     </tr>
end_primero
print<<"end_plant6";
          <tr>
      <th BGCOLOR="#006009">
       <font face="tahoma, arial, helvetica, sans serif">
        <font color="#99ff00">Species:</font>
       <br>
        <a href="javascript:explain_sitepresence()"
           onMouseOver="window.status='Explain Site Presence (new window)';return true"
           onMouseOut="window.status='Understory Response Model'; return true">
         <img src="/fuels/urm/images/quest2.gif" width="18" height="16" border="0"></a>
      </th>
      <td colspan="2">
       
	<span id="specspan"></span>

      </td>
     </tr>
     <tr>
      <th BGCOLOR="#006009">
       <font face="tahoma, arial, helvetica, sans serif">
        <font color="#99ff00">Plant Occurrence</font>
        <br>
        <a href="javascript:explain_sitepresence()"
           onMouseOver="window.status='Explain Site Presence (new window)';return true"
           onMouseOut="window.status='Understory Response Model'; return true">
         <img src="/fuels/urm/images/quest2.gif" width="18" height="16" border="0"></a>
      </th>
     <td colspan="2">
       <SELECT size="3" NAME="site_presence">
       <OPTION selected value="-2">select one</OPTION>
        <OPTION value="1">On Site</OPTION>
        <option value="0">Off Site</option>
       </SELECT>
      <!--<td><INPUT type="radio" size="15" VALUE="1" NAME="site_presence">On Site</td>
      <td><INPUT type="radio" size="15" VALUE="0" NAME="site_presence">Off Site</td>-->
     </tr>
     <tr>
      <th BGCOLOR="#006009">
       <font color="#99ff00">Life Span</font>
       <br>
       <a href="javascript:explain_lifespan()"
           onMouseOver="window.status='Explain Life Span (new window)';return true"
           onMouseOut="window.status='Understory Response Model'; return true">
         <img src="/fuels/urm/images/quest2.gif" width="18" height="16" border="0"></a>
      </th>
      <td colspan="2">
       <SELECT size="4" ID="Select1" NAME="life_duration">
	<OPTION selected value="None">Select one</OPTION>
	<OPTION value="Annual">Annual (only reproduction track)</OPTION>
	<option value="Biennial">Biennial</option>
	<option value="Perennial">Perennial</option>
end_plant6
print<<"end_plant1";
       </SELECT>
      </td>
     </tr>
     <tr>
      <th BGCOLOR="#006009">
       <font color="#99ff00">Life Form</font>
       <br>
       <a href="javascript:explain_lifeform()"
           onMouseOver="window.status='Explain Life Form (new window)';return true"
           onMouseOut="window.status='Understory Response Model'; return true">
         <img src="/fuels/urm/images/quest2.gif" width="18" height="16" border="0"></a>
      </th>
      <td colspan="2">
       <SELECT size="3" NAME="life_form">
	<option selected value="none">Select one</option>
	<!--<OPTION value="Herb">Herb</OPTION>-->
	<option value="Forb">Herb (Grass or Forb)</option>
	<option value="Shrub">Shrub</option>
end_plant1
print"       <!--<OPTION value=Herb>Herb</OPTION>-->";
print<<"end_plant2";
       </SELECT>
      </td>
     </tr>
     <tr>
      <th BGCOLOR="#006009">
       <font color="#99ff00">Bud Location on Plant</font>
       <br>
       <a href="javascript:explain_budlocation()"
           onMouseOver="window.status='Explain Bud Location (new window)';return true"
           onMouseOut="window.status='Understory Response Model'; return true">
         <img src="/fuels/urm/images/quest2.gif" width="18" height="16" border="0"></a>
      </th>
      <td colspan="2">
       <SELECT size="5" NAME="bud_loc">
	<option selected value="None">Select one</option>
	<option value="stolon">Stolon</option>
	<option value="crown">Root Crown</option>
	<option value="rhizome">Rhizome</option>
	<option value="bulb">Bulb/Corm</option>
end_plant2
print<<"end_plant3";
       </SELECT>
      </td>
     </tr>
<tr>
      <th BGCOLOR="#006009">
       <font color="#99ff00">Bud Location in the Soil</font>
       <br>
       <a href="javascript:explain_rootlocation()"
           onMouseOver="window.status='Explain Root Location (new window)';return true"
           onMouseOut="window.status='Understory Response Model'; return true">
         <img src="/fuels/urm/images/quest2.gif" width="18" height="16" border="0"></a>
      </th>
      <td colspan="2">
       <SELECT size="3" NAME="root_loc">
	<OPTION selected value="None">Select one</OPTION>
	<OPTION value="duff">Duff</OPTION>
	<option value="mineral">Mineral Soil</option>
end_plant3
print<<"end_plant4";
       </SELECT>
      </td>

     <tr>
      <th BGCOLOR="#006009">
       <font color="#99ff00">Vegetative Reproduction?</font>
       <br>
       <a href="javascript:explain_vegreproduction()"
           onMouseOver="window.status='Explain Vegetative Reproduction (new window)';return true"
           onMouseOut="window.status='Understory Response Model'; return true">
         <img src="/fuels/urm/images/quest2.gif" width="18" height="16" border="0"></a>
       </th>
     <td colspan="2">
       <SELECT size="3" NAME="veg_repro">
       <OPTION selected value="-2">select one</OPTION>
        <OPTION value="1">Yes</OPTION>
        <option value="2">No</option>
       </SELECT>
	<!--<td><INPUT type="radio" VALUE="1" NAME="veg_repro">Yes</td>
	<td><INPUT type="radio" VALUE="0" NAME="veg_repro">No</td>-->
end_plant4
print<<"end_plant5";
     </tr>
     <tr>
      <th BGCOLOR="#006009">
       <font color="#99ff00">Sprouts?</font>
       <br>
       <a href="javascript:explain_sprouts()"
           onMouseOver="window.status='Explain Sprouts (new window)';return true"
           onMouseOut="window.status='Understory Response Model'; return true">
         <img src="/fuels/urm/images/quest2.gif" width="18" height="16" border="0"></a> 
      </th>
     <td colspan="2">
       <SELECT size="3" NAME="sprouts">
       <OPTION selected value="-2">select one</OPTION>
        <OPTION value="1">Yes</OPTION>
        <option value="2">No</option>
       </SELECT>
	<!--<td><INPUT type="radio" VALUE="1" NAME="sprouts">Yes</td>
	<td><INPUT type="radio" VALUE="0" NAME="sprouts">No</td>-->
end_plant5
print<<"end_plant7";
     </tr>
     <tr>
      <th BGCOLOR="#006009">
       <font color="#99ff00">Preferred Light Level</font>
       <br>
       <a href="javascript:explain_lightlevel()"
           onMouseOver="window.status='Explain Preferred Light Level (new window)';return true"
           onMouseOut="window.status='Understory Response Model'; return true">
         <img src="/fuels/urm/images/quest2.gif" width="18" height="16" border="0"></a>
      </th>
      <td colspan="2">
       <SELECT size="4" NAME="shade_tol">
	<OPTION selected value="-2">Select one</OPTION>
	<OPTION value="0">Open Canopy, Colonizer/Early Successional, Intolerant</OPTION>
	<option value="1">Partial Canopy, Mid Successional, Moderate</option>
	<option value="2">Closed Canopy, Late/Climax Successional, Tolerant</option>
end_plant7
print<<"end_plant8";
       </SELECT>
      </td>
     </tr>
     <tr>
      <th BGCOLOR="#006009">
       <font color="#99ff00">Seed Dispersal</font>
       <br>
       <a href="javascript:explain_seeddispersal()"
           onMouseOver="window.status='Explain Seed Dispersal (new window)';return true"
           onMouseOut="window.status='Understory Response Model'; return true">
         <img src="/fuels/urm/images/quest2.gif" width="18" height="16" border="0"></a>
      </th>
      <td colspan="2">
       <SELECT size="6" NAME="seed_dis">
        <OPTION selected value="-2">Select one</OPTION>
        <OPTION value="0">Long distance dispersal</OPTION>
        <option value="1">Short distance dispersal</option>
        <!--<option value="2">Animal dispersal</option>-->
        <option value="3">Gravity dispersal</option>
        <option value="4">Low Seed Production</option>
        <option value="5">Unknown</option>
       </SELECT>
      </td>
     </tr>
     <tr>
      <th BGCOLOR="#006009">
       <font color="#99ff00">Seed Bank?  (>2 years)</font>
       <br>
       <a href="javascript:explain_seedbank()"
           onMouseOver="window.status='Explain Seed Bank (new window)';return true"
           onMouseOut="window.status='Understory Response Model'; return true">
         <img src="/fuels/urm/images/quest2.gif" width="18" height="16" border="0"></a>
      </th>
      <td colspan="2">
       <SELECT size="4" NAME="seed_banking">
       <OPTION selected value="-2">Select one</OPTION>
        <OPTION value="1">Yes</OPTION>
        <option value="0">No</option>
        <option value="2">Unknown</option>
       </SELECT>
      </td>
     </tr>
     <tr>
      <th BGCOLOR="#006009">
       <font color="#99ff00">Fire Stimulated Seeds?</font>
        <br>
        <a href="javascript:explain_fireseeds()"
           onMouseOver="window.status='Explain Fire Stimulated Seeds (new window)';return true"
           onMouseOut="window.status='Understory Response Model'; return true">
         <img src="/fuels/urm/images/quest2.gif" width="18" height="16" border="0"></a>
      </th>
     <td colspan="2">
       <SELECT size="3" NAME="Refractory" onChange="checkrefractory()">
       <OPTION selected value="-2">select one</OPTION>
        <OPTION value="2">Yes</OPTION>
        <option value="3">No</option>
       </SELECT>
      <!--<td><INPUT type="radio" VALUE="2" NAME="Refractory" onclick="chekrefractory()">Yes</td>
      <td><INPUT type="radio" VALUE="3" NAME="Refractory">No</td>-->
     </tr>
    </table>
    <br>
end_plant8

####end_primero

for($i=0; $i<=$lengthenames; $i++)
{#print "enames is: $enames[$i]";
print qq(<INPUT type="hidden" name="$enames[$i]" value="$evalues[$i]">)}
#for($i=0; $i<$tsize; $i++)
#{print qq(<INPUT type="hidden" name="treatment$i" value="$treatments[$i]">)
#}

print<<"end_ultimo";
  <INPUT type="hidden" name="tsize" value="$tsize">
  <br>
  <center>
   <INPUT type="submit" value="RUN MODEL" style="background: #00ffff; color: #0033ff; font-weight: bold; border: 1px solid black; font-family: courier; font-size: 1.2em; padding: 0.3em;"NAME="action2">
  </center>
  </form>
  <P>
   <hr>
    <table border=0 width=100%>
     <tr>
      <td valign="top" bgcolor="lightgoldenrodyellow">
       <font face="tahoma, arial, helvetica, sans serif" size=1>
        The Understory Response Model: <b>URM</b><br>
        Interface v.
        <a href="javascript:popuphistory()">$version</a>
        (for review only) by
        David Hall &amp; Elena Velasquez<br>
        Model developed by: Steve Sutherland and Melanie Miller<br>
        Team leader Elaine Kennedy Sutherland, USDA Forest Service, Rocky Mountain Research Station<br>
        forest.moscowfsl.wsu.edu/fuels/
       </font>
      </td>
      <td valign="top">
       <a href="https://forest.moscowfsl.wsu.edu/fswepp/comments.html"<img src="/fswepp/images/epaemail.gif" align="right" border=0></a>
      </td>
     </tr>
   </table>
 </body>
</html>
end_ultimo

######################endHtml
