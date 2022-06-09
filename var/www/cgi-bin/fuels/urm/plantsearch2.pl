#!/usr/bin/perl

### -wT

### 2005.01.27 DEH limit number of search results to $maxhits disallow ' ' and '' and .
### 2005.01.27 DEH add "or" case to remove empty option cells per Elena
### 2005.01.25 DEH unauthorized modification from  2310 Nov 22 13:25 plantsearch.pl ###

#use strict;
use CGI ':standard';
##########################################
# code name: plantsearch2.pl             #
##########################################            

# $flagp=0;
$maxhits1 = 50;         # limit number of results returned (actually 1 more)    # 2005.01.27 DEH
$maxhits = $maxhits1-1;
$debug=0;
$scispecies=param('scispecies');
#$scispecies="Agrostis exarata";

print "Content-type: text/html\n\n";

print "<html>
 <head>
  <title>URM plant species search results</title>
  <script>
    function selected() {
      // document.search.matches.options[document.search.matches.selectedIndex].value --> document.search.scispecies.value //
      // alert('oh, we changed to ' + document.search.matches.options[document.search.matches.selectedIndex].value)
      document.search.scispecies.value = document.search.matches.options[document.search.matches.selectedIndex].value
    }
    function apply_search(obj) {	// DEH
     alert (self.creator)
//     if (self.creator.document.plantsimulator.search) {
       window.opener.plantsimulator.search.value=obj.scispecies.value
//     }
   }
  </script>
 </head>
 <body>
  <font face='arial' size='-1'>
   <h4>URM plant information search<br>by scientific name</h4>
";

  @searchfil=("Species","Life Span","Life Form","Root Location","Vegetative Reproduction","Weed","Sprouts","Preferred Light Level","Seed Dispersal","Seed Bank","Fire Stimulated Seeds");
  $sizefil=@searchfil;

#######all plants set up

  $allplantpath="combined_Plants_DB.txt";
	if($debug)
	{
        print "[debug]\n";
	print "Searching for: $scispecies<br>";
	print "<br>the path to the file: $allplantpath<br>";
	}

# if ($scispecies ne '' && $scispecies ne '.' && $scispecies ne ' ') {	# 2005.01.27 DEH
  if (length($scispecies) > 2) {	# 2005.01.27 DEH

  open (COMPLF, $allplantpath)|| die("Error: $allplantpath file unopened!\n");
    while(<COMPLF>) {
      @row=split(/\t/,$_);
	if($row[0]=~m/$scispecies/i) {
          @rowmatch=@row;
          @hit[$#hit+1] = @rowmatch[0];
          last if ($#hit >= $maxhits);		# 2005.01.27 DEH
        }
    }
  close(COMPLF);

}

  $sizerow=@rowmatch;
  if($debug) {
          for($i=0; $i<=($sizerow-1); $i++){print "row $i is: $rowmatch[$i]<br>";}
          print "<br>row zero is:$rowmatch[0]<br>";
	  print "size row is:$sizerow<br>";
	  print "hits is: $#hit<br>";
  }

print "
     <form method='post' name='search' action='/cgi-bin/fuels/urm/plantsearch2.pl'>
      <input type='text' name='scispecies' value='$scispecies' onFocus='select()'>&nbsp;
      <input type='submit' value='search' name='action1'>
      <!-- input type='button' value='apply' onClick='apply_search(this.form)' -->   <!-- DEH -->
      <br><br>
";

  if ($#hit<0) {print" <br><br>There are no matches for '<b><i>$scispecies</i></b>'.";}

  if ($#hit > 0) {
    $size = 10;
    if ($#hit < $size-2) {$size = $#hit+2};
#    if ($#hit >= $maxhits) {$limtext = " (limited to $maxhits1)"} else {$limtext=''};
      print "
      There are <b> ", $#hit+1, "</b> matches for '<b><i>$scispecies</i></b>' $limtext<br><br>
    <select name='matches' size=$size onChange='Javascript:selected()'>
";
      for $i (0..$#hit) {
         print"    <option value='@hit[$i]'>@hit[$i]</option>\n";
      }
      print "     </select>
     <br><br>
     <font size=-1>
      Search limited to $maxhits1 hits, case insensitive, three or more letters.
     </font>
";
    }

    print "    </form>\n";

    if ($#hit==0) {
      print<<"elena";
    <br>To use any of this information in URM, you must <b>manually</b> enter it in the main window for the model.<br>

     <table align="center" border="2" cellpadding="5" cellspacing="5">
      <caption>
       <b><font size="4">Search Results</font></b>
      </caption>
elena
      for($i=0; $i<=($sizerow-1); $i++) {
        print "
    <tr>
     <th BGCOLOR=#006009>
      <font color=#99ff00>$searchfil[$i]</font>
     </th>
";
#	if(($rowmatch[$i]=~m/" "/)||($rowmatch[$i]=~m/""/)){print"<td>Not Avaliable</td>";}
      chomp $rowmatch[$i];			# 2005.01.27 DEH
      if (($rowmatch[$i]=~m/" "/) || ($rowmatch[$i]=~m/""/)|| (not($rowmatch[$i])))    {
        print "     <td>Not Available</td>";
      }
      else {
        print "     <td>$rowmatch[$i]</td>";
      }
      print "\n    </tr>";
    }
    for ($k=$sizerow; $k<=($sizefil-1); $k++) {
      print "
    <tr>
     <th BGCOLOR=#006009>
      <font color=#99ff00>$searchfil[$k]</font>
     </th>
";
      print "    <td>Not Available</td>
    </tr>";
    }
    print"
   </table>
";
  }
  print "
 </body>
</html>
";
