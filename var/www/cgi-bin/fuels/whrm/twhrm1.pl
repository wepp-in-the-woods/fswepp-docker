#!/usr/bin/perl
#use strict;
use CGI ':standard';

##########################################
# code name: twrhm1.pl                   #
########################################## 

# change call for comments (fuels/comments.html to fswepp/comments.html as latter has more error-checking 2008.06.27 DEH
# add font face
# update version date

print "Content-type: text/html\n\n";

print <<"totheend";
<html>
 <head>
  <meta name=\"vs_showGrid\" content=\"True\">
  <title>The Wildlife Habitat Response Model</title>
  <SCRIPT LANGUAGE=\"JavaScript\" type=\"TEXT/JAVASCRIPT\">
  <!--

function blankStatus()
{
  window.status = " "
  return true                           // p. 86
}
function checkform()
{
if(!document.twhrm1.treatment[0].checked && !document.twhrm1.treatment[1].checked && !document.twhrm1.treatment[2].checked && !document.twhrm1.treatment[3].checked)
	{//no checkbox is not selected
	//retun false;
	alert("You must choose at least two treatments");
	return false;
	}
return true;
}
 function popuphistory() {
    url = '';
    height=500;
    width=660;
    popupwindow = window.open(url,'popupwindow','toolbar=no,location=no,status=no,directories=no,menubar=no,scrollbars=yes,resizable=yes,width='+width+',height='+height);
    popupwindow.document.writeln('<html>')
    popupwindow.document.writeln(' <head>')
    popupwindow.document.writeln('  <title>Wildlife Habitat Response Model version history</title>')
    popupwindow.document.writeln(' </head>')
    popupwindow.document.writeln(' <body bgcolor=white>')
    popupwindow.document.writeln('  <font face=\"tahoma, arial, helvetica, sans serif\">')
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
    popupwindow.document.writeln('    <tr>')
    popupwindow.document.writeln('     <th valign=top bgcolor=lightblue>2005.08.23</th>')
    popupwindow.document.writeln('     <td>Beta 2 Release: WHRM contains 472 scientific papers covering 250 species, 179 of which can be modeled based on available information.  Please submit suggestions and comments before official release in 2006.</td>')
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
 <body link=\"#99ff00\" vlink=\"#99ff00\" alink=\"#99ff00\">
  <font face=\"tahoma, arial, helvetica, sans serif\">
   <table align=\"center\" width=\"100%\" border=\"0\">
    <tr>
     <td><img src="/fuels/whrm/images/borealtoad4_Pilliod.jpg"  alt="Wildlife Habitat Response Model" align="left"></td>
     <td align=\"center\"><hr>
      <font face=\"tahoma, arial, helvetica, sans serif\">
       <h2>Wildlife Habitat Response Model</h2>
       <hr>
      </font>
     </td>
     <td><img src="/fuels/whrm/images/grayjay3_Pilliod.jpg"  alt="Wildlife Habitat Response Model" align="right" width=156 height=117></td>
    </tr>
   </table>
   <center>
   <!--<form method=\"post\" name=\"twhrm1\" action=\"https://localhost/Scripts/fuels/whrm/twhrm2.pl\" onsubmit=\"return checkform()\">-->
   <form method=\"post\" name=\"twhrm1\" action=\"/cgi-bin/fuels/whrm/twhrm2.pl\" onsubmit=\"return checkform()\">
    <p><b>Treatments to Be Compared: </b>(You must select at least one)
     <br><br><br>
      <table align=\"center\" border=\"2\">
       <caption>
       </caption>
         <tr>
          <th BGCOLOR=\"#006009\">
           <font face=\"tahoma, arial, helvetica, sans serif\" color=\"#99ff00\">Thinning and Broadcast Burning</Font></th>
          <td><input type=\"checkbox\" name=\"treatment\" value=\"1\"></td>
         </tr>
         <tr>
          <th BGCOLOR=\"#006009\">
           <font face=\"tahoma, arial, helvetica, sans serif\" color=\"#99ff00\">Thinning and Pile Burning</font></th>
          <td><input type=\"checkbox\" name=\"treatment\" value=\"2\"></td>
         </tr>
         <tr>
          <th BGCOLOR=\"#006009\">
           <font face=\"tahoma, arial, helvetica, sans serif\" color=\"#99ff00\">Prescribed Fire</font></th>
          <td><input type=\"checkbox\" name=\"treatment\" value=\"3\"></td>
         </tr>
         <tr>
          <th BGCOLOR=\"#006009\">
           <font face=\"tahoma, arial, helvetica, sans serif\" color=\"#99ff00\">Wildfire</font></th>
          <td><input type=\"checkbox\" name=\"treatment\" value=\"4\"></td>
         </tr>
        </table>
					<br>
					<br>
					<INPUT type=\"submit\" value=\"  Continue  \" NAME=\"firstpage\">
			</form>
		</center>
		<P>
   <hr>
<table border=0 width=100%>
     <tr>
      <td valign="top" bgcolor="lightgoldenrodyellow">
       <font face="tahoma, arial, helvetica, sans serif" size=1>
        <b>Documentation and User Manual:</b>
        [<a href="/fuels/whrm/documents/ChapterIV_WHRM_web.pdf" target="_blank">User guide</a> (21-page PDF)]
        [<a href="https://www.fs.fed.us/rm/pubs/rmrs_rn023_04.pdf" target="_blank">Fact sheet</a> (1-page PDF)]
        <br>
        The Wildlife Habitat Response Model: <b>WHRM</b><br>
        Input interface v.
        <a href="javascript:popuphistory()">2006.10.16</a>
        (for review only) by Elena Velasquez &amp; David Hall<br>
        Model developed by: David Pilliod<br>
        Team leader Elaine Kennedy Sutherland, USDA Forest Service, Rocky Mountain Research Station
       </font>
      </td>
      <td valign="top">
       <a href="https://forest.moscowfsl.wsu.edu/fswepp/comments.html" target="comments"><img src="/fswepp/images/epaemail.gif" align="right" border=0></a>
       <a href="https://forest.moscowfsl.wsu.edu/fuels/comments.html" target="comments"></a>
      </td>
     </tr>
   </table>
	</body>
</html>
totheend
