#!/usr/bin/perl
##!C:\Perl\bin\perl.exe T-w
#use strict;
use CGI ':standard';

### urm.pl from Elena 2005.01.24 ###

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
		print "<p><b>Key:</b>$name <b>
		Value(s) :</b>@values";
	}
}
########################################
## HTML output of all the input        #
######################################## 
@treatments=param('treatment');

$tsize=@treatments;


if ($debug)
{
print "<p>Number of treatments selected is: $tsize<br>";
print "<p>treatments are: @treatments";
}


#################################
#html inputs
##############################

print<<"fin_primero";
<html>
 <head>
  <meta name="vs_showGrid" content="True">
  <title>The Understory Response Model</title>
  <SCRIPT LANGUAGE="JavaScript" type="TEXT/JAVASCRIPT">
  <!--
fin_primero
print " var treatmts=new Array();\n";
for($i=0;$i<$tsize;$i++)
{print " treatmts[$i]=",'"',$treatments[$i]+0,'"',";\n";}

print<<"end_primero";
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
//  mywin.document.writeln('   <form method="post" name="elena" action="https://localhost/Scripts/fuels/urm/plantsearch2.pl">')
    mywin.document.writeln('   <form method="post" name="elena" action="/cgi-bin/fuels/urm/plantsearch2.pl">')
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
function explain_sizearea() {
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
      newin.document.writeln('      <h3>Understory Response Model<br><br>Size of Treated Area</h3><br>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td></tr>')
      newin.document.writeln('   </table>')
//      newin.document.writeln('   Size is .')
      newin.document.writeln('   Number of acres treated to reduce fuels.  This value affects off-site colonization.')
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
function explain_stcanopycover() {
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
      newin.document.writeln('      <h3>Understory Response Model<br><br>Canopy Cover (%)</h3><br>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td></tr>')
      newin.document.writeln('   </table>')
//      newin.document.writeln('   Site Presence is .')
      newin.document.writeln('  Percent of ground covered by the vertical projection of the aerial portions of the plants above breast height (same as foliar cover).  Small openings in the canopy are excluded.  Values range from 0 to 100.  This value affects post-treatment plant survival and reproduction.')
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
function explain_avgduffdepth() {
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
      newin.document.writeln('      <h3>Understory Response Model<br><br>Average Duff Depth (inches)</h3><br>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td></tr>')
      newin.document.writeln('   </table>')
//      newin.document.writeln('   Site Presence is .')
      newin.document.writeln('     Average depth, in inches, of the partially decomposed organic matter found beneath the litter layer and above the mineral soil.  This value, along with duff moisture, is used to predict depth of lethal temperature which affects post-fire plant and seed survival.')
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
function explain_minsoil() {
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
      newin.document.writeln('      <h3>Understory Response Model<br><br>Mineral Soil Exposed</h3><br>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td></tr>')
      newin.document.writeln('   </table>')
//      newin.document.writeln('   Site Presence is .')
      newin.document.writeln('   Percent of ground that is not covered by vegetation, litter and duff, logs, or rocks.  The user inputs values for mineral soil exposed by thinning; fuel moisture determines mineral soil exposed by fire.  These values determine the relative amount of seedbed available for seed germination.')
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
function explain_timesince() {
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
      newin.document.writeln('      <h3>Understory Response Model<br><br>Timing of Broadcast Burn</h3><br>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td></tr>')
      newin.document.writeln('   </table>')
//      newin.document.writeln('   Site Presence is .')
      newin.document.writeln('    Does the fire occur <b>one year</b> or <b>more than one year</b> after thinning?  This value affects fire mortality in the survivorship pathway.')
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
function explain_seasonburn() {
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
      newin.document.writeln('      <h3>Understory Response Model<br><br>Season of Burn</h3><br>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td></tr>')
      newin.document.writeln('   </table>')
//      newin.document.writeln('   Site Presence is .')
      newin.document.writeln('   Does the fire occur during the <b>growing</b> season or <b>dormant</b> season for the species of concern?  This value affects post-fire survival.')
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
function explain_fuelmoist() {
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
      newin.document.writeln('      <h3>Understory Response Model<br><br>Fuel Moisture</h3><br>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td></tr>')
      newin.document.writeln('   </table>')
//      newin.document.writeln('   Site Presence is .')
      newin.document.writeln('   Percent of fuel weight that is water (expressed as percent of oven dry weight).  Categories are from FOFEM 5.11.   This value, along with <b> duff depth </b>, affects soil heating (post-fire plant and seed survival) and post-fire <b> mineral soil exposure </b> (seed germination).')
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
function checkstartcanopy()
{
var x=parseFloat(window.document.plantsimulator.start_canopy.value);
if((x<0)||(x>100))
{
alert("Start Canopy must be number in the interval [0,100]");
window.document.plantsimulator.start_canopy.value = 80;
}
}
function checkthincanopy1()
{
var x=parseFloat(window.document.plantsimulator.start_canopy.value);
var y=parseFloat(window.document.plantsimulator.canopy_cover1.value);
var part11="The start canopy smaller than the canopy removed from thinning. ";
var part21="PLEASE change your value for canopy removed from thinning";
if(x<y)
{
alert(part11+part21);
window.document.plantsimulator.canopy_cover1.value = 0;
window.document.plantsimulator.canopy_cover1.focus();
window.document.plantsimulator.canopy_cover1.select();
}
}
function checkthincanopy2()
{
var x=parseFloat(window.document.plantsimulator.start_canopy.value);
var y=parseFloat(window.document.plantsimulator.canopy_cover2.value);
var part11="The start canopy is smaller than the canopy removed from thinning. ";
var part21="PLEASE change your value for canopy removed from thinning";
if(x<y)
{
alert(part11+part21);
window.document.plantsimulator.canopy_cover2.value = 0;
window.document.plantsimulator.canopy_cover2.focus();
window.document.plantsimulator.canopy_cover2.select();
}
}
//the following function was updated by elena feb3
function checkfirecanopy1()
{
var y=parseFloat(window.document.plantsimulator.canopy_cover1.value);
var z=parseFloat(window.document.plantsimulator.fire_canopy1.value);
var part1="The canopy cover after burning can not be bigger ";
var part2="than canopy cover before burning (after thinning). ";
var part3="PLEASE change the values";

if(y<z)
{
alert(part1+part2+part3);
window.document.plantsimulator.fire_canopy1.value = 0;
window.document.plantsimulator.fire_canopy1.focus();
window.document.plantsimulator.fire_canopy1.select();
}
}
function checkfirecanopy3()
{
var x=parseFloat(window.document.plantsimulator.start_canopy.value);
var z=parseFloat(window.document.plantsimulator.fire_canopy3.value);
var part1="The start canopy must be bigger or equal than ";
var part2="the canopy removed due to the prescribed fire";
var part3="PLEASE change the values";

if(x<z)
{
alert(part1+part2+part3);
window.document.plantsimulator.fire_canopy3.value = 0;
window.document.plantsimulator.fire_canopy3.focus();
window.document.plantsimulator.fire_canopy3.select();
}
}
function checkfirecanopy4()
{
var x=parseFloat(window.document.plantsimulator.start_canopy.value);
var z=parseFloat(window.document.plantsimulator.fire_canopy4.value);
var part1="The start canopy must be bigger or equal than ";
var part2="the canopy removed due to the wildfire";
var part3="PLEASE change the values";

if(x<z)
{
alert(part1+part2+part3);
window.document.plantsimulator.fire_canopy4.value = 0;
window.document.plantsimulator.fire_canopy4.focus();
window.document.plantsimulator.fire_canopy4.select();
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
function checkform() {
var myform = document.forms[0];
var areaIdx = myform.area.selectedIndex;
var startCanopy = myform.start_canopy.value;
var duffdepthIdx = myform.duff_depth.selectedIndex;
if((areaIdx == 0)||(areaIdx == -1)){alert("you must select a value for size of treated area");myform.area.focus();
return false;}
else if(startCanopy == "")
{alert("the startCanopy is "+startCanopy);
alert("You must enter a value for the start canopy cover");myform.start_canopy.focus();return false;}
else if((duffdepthIdx == -1)||(duffdepthIdx == 0)){alert("you must select a value for average duff depth");myform.duff_depth.focus();
return false;}
else if(treatmts.length>=1)
{for(var i=0; i<treatmts.length;i++)
	{if(treatmts[i]==1){
	var canopyCover1 = myform.canopy_cover1.value;
	var mineralExpo1 = myform.mineral_expo1.value;
	var timingIdx = myform.timing.selectedIndex;
	var season1Idx = myform.season1.selectedIndex;
	var moisture1Idx = myform.moisture_cond1.selectedIndex;;
	var fireCanopy1 = myform.fire_canopy1.value;
	if(canopyCover1 == ""){alert("you must enter a value for canopy cover after thinning");myform.canopy_cover1.focus();
	return false;}
	else if(mineralExpo1 == "")
	{alert("You must enter a value for mineral soil expose by thinning");myform.mineral_expo1.focus();return false;}
	else if((timingIdx == -1)||(timingIdx == 0)){alert("you must select a value for timing of broadcast burn");myform.timing.focus();
	return false;}
	else if((season1Idx == -1)||(season1Idx == 0)){alert("you must select a value for season of burn");myform.season1.focus();
	return false;}
	else if((moisture1Idx == -1)||(moisture1Idx == 0)){alert("you must select a value for fuel moisture");myform.moisture_cond1.focus();
	return false;}
	else if(fireCanopy1 == "")
	{alert("You must enter a value for canopy cover after broadcast burning");myform.fire_canopy1.focus();return false;}
	}
	if(treatmts[i]==2){
	var canopyCover2 = myform.canopy_cover2.value;
	var mineralExpo2 = myform.mineral_expo2.value;
	if(canopyCover2 == ""){alert("you must enter a value for canopy cover after thinning");myform.canopy_cover2.focus();
	return false;}
	else if(mineralExpo2 == "")
	{alert("You must enter a value for mineral soil expose by thinning");myform.mineral_expo2.focus();return false;}
	}
	if(treatmts[i]==3){
	var season3Idx = myform.season3.selectedIndex;
	var moisture3Idx = myform.moisture_cond3.selectedIndex;
	var fireCanopy3 = myform.fire_canopy3.value;
	if(season3Idx == -1){alert("you must select a value for season of burn");myform.season3.focus();
	return false;}
	else if((moisture3Idx == -1)||(moisture3Idx == 0)){alert("you must select a value for fuel moisture");myform.moisture_cond3.focus();

	return false;}
	else if(fireCanopy3 == "")
	{alert("You must enter a value for canopy cover after prescribed fire");myform.fire_canopy3.focus();return false;}	
	}
	if(treatmts[i]==4){
	var season4Idx = myform.season4.selectedIndex;
	var moisture4Idx = myform.moisture_cond4.selectedIndex;
	var fireCanopy4 = myform.fire_canopy4.value;
	if((season4Idx == -1)||(season4Idx == 0)){alert("you must select a value for season of burn");myform.season4.focus();
	return false;}
	else if((moisture4Idx == -1)||(moisture4Idx == 0)){alert("you must select a value for fuel moisture");myform.moisture_cond4.focus();
	return false;}
	else if(fireCanopy4 == "")
	{alert("You must enter a value for canopy cover after wildfire");myform.fire_canopy4.focus();return false;}
	}
	}
}
else{return true;} 
  }

  // end hide -->
  </SCRIPT>
 </head>

 <body link="#99ff00" vlink="#99ff00" alink="#99ff00">
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
   <!-- form method="post" name="plantsimulator" action="https://localhost/Scripts/fuels/urm/test/urm1.pl" onsubmit="return checkform()"-->
   <form method="post" name="plantsimulator" action="https:/cgi-bin/fuels/urm/urm1.pl" onsubmit="return checkform()">
    <table align="center" border="2" ID="Table2">
     <caption>
      <font face="tahoma, arial, helvetica, sans serif">
       <font size="4" color="#006009"><b>Initial Stand Conditions</b></font>
      </font>
     </caption>
    <tr>
     <th BGCOLOR="#006009">
      <font face="tahoma, arial, helvetica, sans serif">
       <font color="#99ff00">Size of <br>Treated Area (acres)</font>
       <br>
        <a href="javascript:explain_sizearea()"
               onMouseOver="window.status='Explain Size of Treated Area (acres) (new window)';return true"
               onMouseOut="window.status='Understory Response Model'; return true">
             <img src="/fuels/urm/images/quest2.gif" width="18" height="16" border="0"></a>
       </font>
      </th>
      <td>
       <font face="tahoma, arial, helvetica, sans serif">
        <SELECT size="4" NAME="area" ID="Select2">
         <option selected value="-2">Select one</option>
         <option value="0">1-100</option>
         <option value="1">101-1,000</option>
         <option value="2">1001-10,000</option>
        </SELECT>
       </font>
      </td>
     </tr>
     <tr>
      <th BGCOLOR="#006009">
       <font face="tahoma, arial, helvetica, sans serif">
        <font color="#99ff00">Starting<br>Canopy Cover (%)</font>
        <br>
        <a href="javascript:explain_stcanopycover()"
               onMouseOver="window.status='Explain Starting Canopy Cover (new window)';return true"
               onMouseOut="window.status='Understory Response Model'; return true">
             <img src="/fuels/urm/images/quest2.gif" width="18" height="16" border="0"></a>
       </font>
      </th>
      <td><INPUT type="text" size="4"  NAME="start_canopy" onchange="checkstartcanopy()" ID="Text2"></td>
     </tr>
     <tr>
      <th BGCOLOR="#006009">
       <font face="tahoma, arial, helvetica, sans serif">
        <font color="#99ff00">Average Duff Depth (inches)</font>
        <br>
        <a href="javascript:explain_avgduffdepth()"
               onMouseOver="window.status='Explain Average Duff Depth (new window)';return true"
               onMouseOut="window.status='Understory Response Model'; return true">
             <img src="/fuels/urm/images/quest2.gif" width="18" height="16" border="0"></a>
       </font>
      </th>
      <td colspan="2">
       <font face="tahoma, arial, helvetica, sans serif">
        <SELECT size="8" NAME="duff_depth" ID="Select3">
         <option selected value="-2">Select one</option>
         <option value="6">No duff</option>
         <option value="0">One half inch</option>
         <option value="1">one inch</option>
         <option value="2">two inches</option>
         <option value="3">three inches</option>
         <option value="4">four inches</option>
         <option value="5">five inches</option>
        </SELECT>
       </font>
      </td>
     </tr>
    </table>
    <br>

end_primero
  for ($i=0; $i<=$tsize; $i++) {
if($treatments[$i]==1)
{print<<"end_segundo";
     <table align="center" border="2">
      <caption>
       <b><font size="4" color="#006009">Thinning and Broadcast Burning</font></b>
      </caption>
      <tr>
       <th BGCOLOR="#006009">
        <font color="#99ff00">Canopy Cover<br>after Thinning (%)</font><br>
         <a href="javascript:explain_stcanopycover()"
            onMouseOver="window.status='Explain Canopy Cover After Thinning (new window)';return true"
            onMouseOut="window.status='Understory Response Model'; return true">
          <img src="/fuels/urm/images/quest2.gif" width="18" height="16" border="0"></a>
       </th>
       <td><INPUT type="text" size="4" NAME="canopy_cover1" onchange="checkthincanopy1()" ID="Text6"></td>
      </tr>
      <tr>
       <th BGCOLOR="#006009">
        <font color="#99ff00">Mineral Soil<br>Exposed by Thinning (%)</font><br>
          <a href="javascript:explain_minsoil()"
            onMouseOver="window.status='Explain Mineral Soil Exposed by Thinning (new window)';return true"
            onMouseOut="window.status='Understory Response Model'; return true">
          <img src="/fuels/urm/images/quest2.gif" width="18" height="16" border="0"></a>
       </th>
       <td><INPUT type="text" size="4" NAME="mineral_expo1"></td>
      </tr>
      <tr>
       <th BGCOLOR="#006009">
        <font color="#99ff00">Timing of<br>Broadcast Burn</font><br>
         <a href="javascript:explain_timesince()"
            onMouseOver="window.status='Explain Time Since Thinning (new window)';return true"
            onMouseOut="window.status='Understory Response Model'; return true">
          <img src="/fuels/urm/images/quest2.gif" width="18" height="16" border="0"></a>
       </th>
       <td >
        <SELECT size="3" NAME="timing" onBlur="blankStatus()">
         <option selected value="-2">Select one</option>
         <option value="0">One Year After Thinning</option>
         <option value="-1">More Than One Year After Thinning</option>
        </SELECT>
       </td>
      </tr>
      <tr>
       <th BGCOLOR="#006009">
        <font color="#99ff00">Season of Burn</font><br>
         <a href="javascript:explain_seasonburn()"
            onMouseOver="window.status='Explain Season of Burn (new window)';return true"
            onMouseOut="window.status='Understory Response Model'; return true">
          <img src="/fuels/urm/images/quest2.gif" width="18" height="16" border="0"></a>
       </th>
       <td>
        <SELECT size="3" NAME="season1" onBlur="blankStatus()" >
         <option selected value="-2">Select one</option>
         <option value="-1">Growing Season</option>
         <option value="0">Dormant Season</option>
        </SELECT>
       </td>
      </tr>
      <tr>
       <th BGCOLOR="#006009">
        <font color="#99ff00">Fuel Moisture</font><br>
         <a href="javascript:explain_fuelmoist()"
            onMouseOver="window.status='Explain Fuel Moisture (new window)';return true"
            onMouseOut="window.status='Understory Response Model'; return true">
          <img src="/fuels/urm/images/quest2.gif" width="18" height="16" border="0"></a>
       </th>
       <td>
        <SELECT size="4" NAME="moisture_cond1" >
         <option selected value="-2">Select one</option>
         <option value="50.8">dry (1 hr fuels 10%, 1000 hr fuel 15%, duff 40%, soil 10% )</option>
         <option value="31">moderate (1 hr fuels 16%, 1000 hr fuel 30%, duff 75%, soil 15%)</option>
         <option value="13.6">wet (1 hr fuels 22%, 1000hr fuel 40%, duff 130%, soil 25%)</option>
        </SELECT>
     </td>
    </tr>
      <tr>
       <th BGCOLOR="#006009">
        <font color="#99ff00">Canopy Cover<br>after Broadcast Burning (%)</font><br>
          <a href="javascript:explain_stcanopycover()"
            onMouseOver="window.status='Explain Canopy Cover After Thinning (new window)';return true"
            onMouseOut="window.status='Understory Response Model'; return true">
          <img src="/fuels/urm/images/quest2.gif" width="18" height="16" border="0"></a>
       </th>
       <td><INPUT type="text" size="4" NAME="fire_canopy1" onchange="checkfirecanopy1()" ID="Text3"></td>
      </tr>
   </table>
   <br>
end_segundo

}
if ($treatments[$i]==2) {
  print<<"end_tercero";
    <table align="center" border="2" ID="Table1">
 <caption>
 <b><font size="4" color="#006009">Thinning and Pile Burning</font></b></caption>
 <tr>
 <th BGCOLOR="#006009">
 <Font color="#99ff00">Canopy Cover
 <br>
 after Thinning (%) </Font><br>
 <a href="javascript:explain_stcanopycover()"
           onMouseOver="window.status='Explain Canopy Cover After Thinning (new window)';return true"
           onMouseOut="window.status='Understory Response Model'; return true">
         <img src="/fuels/urm/images/quest2.gif" width="18" height="16" border="0"></a>
 </th>
 <td><INPUT type="text" size="4" NAME="canopy_cover2" onchange="checkthincanopy2()" ID="Text4"></td>
 </tr>
 <tr>
 <th BGCOLOR="#006009">
 <Font color="#99ff00">Mineral Soil<br>
 Exposed by Thinning (%) </Font><br>
 <a href="javascript:explain_minsoil()"
           onMouseOver="window.status='Explain Mineral Soil Exposed by Thinning (new window)';return true"
           onMouseOut="window.status='Understory Response Model'; return true">
         <img src="/fuels/urm/images/quest2.gif" width="18" height="16" border="0"></a>
 </th>
 <td><INPUT type="text" size="4" NAME="mineral_expo2" ID="Text5"></td>
 </tr>
 </table>
 <br>
end_tercero

}
if($treatments[$i]==3)
{print<<"end_cuarto";
 <table align="center" border="2" ID="Table3">
 <caption>
 <b><font size="4" color="#006009">Prescribed Fire</font></b></caption>

 <tr>
 <th BGCOLOR="#006009">
 <Font color="#99ff00">Season of Burn </Font><br>
  <a href="javascript:explain_seasonburn()"
            onMouseOver="window.status='Explain Season of Burn (new window)';return true"
            onMouseOut="window.status='Understory Response Model'; return true">
          <img src="/fuels/urm/images/quest2.gif" width="18" height="16" border="0"></a>
 </th>
 <td ><SELECT size="3" NAME="season3" onBlur="blankStatus()" >
<option selected value="-2">Select one</option>
 <option value="-1">Growing Season</option>
 <option value="0">Dormant Season</option>
 </SELECT></td>
 </tr>
 <tr>
 <th BGCOLOR="#006009">
 <Font color="#99ff00">Fuel Moisture </Font><br>
 <a href="javascript:explain_fuelmoist()"
           onMouseOver="window.status='Explain Fuel Moisture (new window)';return true"
           onMouseOut="window.status='Understory Response Model'; return true">
         <img src="/fuels/urm/images/quest2.gif" width="18" height="16" border="0"></a>
 </th>
 <td><SELECT size="4" NAME="moisture_cond3">
<option selected value="-2">Select one</option>
 <option value="50.8">dry (1 hr fuels 10%, 1000 hr fuel 15%, duff 40%, soil 10% )</option>
 <option value="31">moderate (1 hr fuels 16%, 1000 hr fuel 30%, duff 75%, soil 15%)</option>
 <option value="13.6">wet (1 hr fuels 22%, 1000hr fuel 40%, duff 130%, soil 25%)</option>
 </SELECT></td>
 </tr>
 <tr>
       <th BGCOLOR="#006009">
        <font color="#99ff00">Canopy Cover<br>after Prescribed Fire (%)</font><br>
          <a href="javascript:explain_stcanopycover()"
            onMouseOver="window.status='Explain Canopy Cover After Thinning (new window)';return true"
            onMouseOut="window.status='Understory Response Model'; return true">
          <img src="/fuels/urm/images/quest2.gif" width="18" height="16" border="0"></a>
       </th>
 <td><INPUT type="text" size="4" NAME="fire_canopy3" onchange="checkfirecanopy3()" ID="Text8"></td>
 </tr>
 </table>
 <br>
end_cuarto

}
if($treatments[$i]==4)
{print<<"end_quinto";
 <table align="center" border="2" ID="Table4">
 <caption>
 <b><font size="4" color="#006009">Wildfire</font></b></caption>
 
 <tr>
 <th BGCOLOR="#006009">
 <Font color="#99ff00">Season of Burn </Font><br>
 <a href="javascript:explain_seasonburn()"
           onMouseOver="window.status='Explain Season of Burn (new window)';return true"
           onMouseOut="window.status='Understory Response Model'; return true">
         <img src="/fuels/urm/images/quest2.gif" width="18" height="16" border="0"></a>
 </th>
 <td ><SELECT size="3" NAME="season4" onBlur="blankStatus()" >
<option selected value="-2">Select one</option>
 <option value="-1">Growing Season</option>
 <option value="0">Dormant Season</option>
 </SELECT></td>
 </tr>
 <tr>
 <th BGCOLOR="#006009">
 <Font color="#99ff00">Fuel Moisture </Font><br>
 <a href="javascript:explain_fuelmoist()"
           onMouseOver="window.status='Explain Fuel Moisture (new window)';return true"
           onMouseOut="window.status='Understory Response Model'; return true">
         <img src="/fuels/urm/images/quest2.gif" width="18" height="16" border="0"></a>
 </th>
 <td colspan="2"><SELECT size="4" NAME="moisture_cond4">
<option selected value="-2">Select one</option>
 <option value="72.7">very dry (1 hr fuels 6%, 1,000 hr fuel 10%, duff 20%)</option>
 <option value="50.8">dry (1 hr fuels 10%, 1000 hr fuel 15%, duff 40%, soil 10% )</option>
 <option value="31">moderate (1 hr fuels 16%, 1000 hr fuel 30%, duff 75%, soil 15%)</option>
 </SELECT></td>
 </tr>
<tr>
       <th BGCOLOR="#006009">
        <font color="#99ff00">Canopy Cover<br>after Wildfire (%)</font><br>
          <a href="javascript:explain_stcanopycover()"
            onMouseOver="window.status='Explain Canopy Cover After Thinning (new window)';return true"
            onMouseOut="window.status='Understory Response Model'; return true">
          <img src="/fuels/urm/images/quest2.gif" width="18" height="16" border="0"></a>
       </th>
 <td colspan="2"><INPUT type="text" size="4" NAME="fire_canopy4" onchange="checkfirecanopy4()" ID="Text9"></td>
 </tr>
 </table>
 <br>
end_quinto

}
}

for($i=0; $i<$tsize; $i++)
{print qq(<INPUT type="hidden" name="treatment$i" value="$treatments[$i]">)
}
print<<"end_ultimo";
  <INPUT type="hidden" name="tsize" value="$tsize">
  <br>
  <center>
   <INPUT type="submit" value="CONTINUE" style="background: #00ffff; color: #0033ff; font-weight: bold; border: 1px solid black; font-family: courier; font-size: 1.2em; padding: 0.3em;"NAME="action2">
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
