#!/usr/bin/perl
#use strict;
use CGI ':standard';

use MoscowFSL::FSWEPP::FsWeppUtils qw(printdate);

##########################################
# code name: twhrm5.pl                    #
##########################################
$debug  = 0;
$hdebug = 0;

# 2005.02.07 DEH correct spelling "misleding" and "contruibuting" in 'Summary of Analysis' section
#		 Removed font size 3; <p> to <br><br>
#		 added brackets around home range 'No information available' (see Abert's squirrel)
#		 change 'The home range...are...' to 'The home range...is'

$version = '2005.03.23';

print "Content-type: text/html\n\n";
my @enames;
my @evalues    = ( 0, 0, 0, 0, 0, 0, 0, 0, 0 );
my @sump       = ( 0, 0, 0, 0, 0 );
my @animalresp = 0;
my @feaflag    = ( 1, 1, 1, 1, 1 );
$totalrow = 0;
######

if ($hdebug) {
    foreach my $name ( param() ) {
        my @values  = param($name);
        my $evalues = $values;
        if ($hdebug) {
            print "<p><b>Key:</b>$name <b>
      Value(s) :</b>@values";
        }
    }
}
#################################################
## uploading all information about the species  #
#################################################
$taxgroup  = param('taxgroup');
$tax_group = param('tax_group');
$species   = param('species');
$filename  = param('filename');
$temprow   = param('temprow');
$treatname = param('treatname');

if ($debug) {
    print "<p>taxgroup is $taxgroup";
    print "<p>species is $species";
    print "<p>filename is $filename";
    print "<p>temprow is $temprow";
    print "<p>treatname is $treatname";
}

for ( $j = 0 ; $j < $temprow ; $j++ ) { $evalues[$j] = param( 'evalues' . $j ) }

for ( $i = 0 ; $i <= ( @evalues - 1 ) ; $i++ ) {
    if ( $evalues[$i] == -3 ) { $pevalues[$i] = "Greater than 70% Decrease" }
    if ( $evalues[$i] == -2 ) { $pevalues[$i] = "41-70% Decrease" }
    if ( $evalues[$i] == -1 ) { $pevalues[$i] = "11-40% Decrease" }
    if ( $evalues[$i] == 0 )  { $pevalues[$i] = "No Change (+/-10%)" }
    if ( $evalues[$i] == 1 )  { $pevalues[$i] = "11-40% Increase" }
    if ( $evalues[$i] == 2 )  { $pevalues[$i] = "41-70% Increase" }
    if ( $evalues[$i] == 3 )  { $pevalues[$i] = "Greater than 70% Increase" }
}

if ($debug) {

    print "<p>@evalues";
    print "<p>@pevalues";

}

###############################
## Habitat Features Vector    #
###############################

@habitatfeatures = (
    'Bare Mineral Soil Exposure',
    'Duff Cover',
    'Grass Cover',
    'Forb/Herbaceous Cover',
    'Shrub Cover (size classes not specified)',
    'Shrub Cover 0-18" height',
    'Shrub Cover 18+" height',
    'Litter Cover',
    'Down Wood (size classes not specified)',
    'Down Wood 0-3" ',
    'Down Wood 4-6" ',
    'Down Wood 7-12"',
    'Down Wood >12"',
    'Snags (size classes not specified)',
    'Snags 0-4.9" dbh',
    'Snags 5-9" dbh',
    'Snags 10-19" dbh',
    'Snags 20-29" dbh',
    'Snags 30+" dbh',
    'Crown Base Height',
    'Tree Canopy Cover',
    'Trees (all species, size classes not specified)',
    'Trees (all species) 0-4.9" dbh',
    'Trees (all species) 5-9" dbh',
    'Trees (all species) 10-19" dbh',
    'Trees (all species) 20-29" dbh',
    'Trees (all species) 30+" dbh',
    'PP Trees (size classes not specified)',
    'PP Trees 0-4.9" dbh',
    'PP Trees 5-9" dbh',
    'PP Trees 10-19" dbh',
    'PP Trees 20-29" dbh',
    'PP Trees 30+" dbh',
    'DF Trees (size classes not specified)',
    'DF Trees 0-4.9" dbh',
    'DF Trees 5-9" dbh',
    'DF Trees 10-19" dbh',
    'DF Trees 20-29" dbh',
    'DF Trees 30+" dbh',
    'LP Trees (size classes not specified)',
    'LP Trees 0-4.9" dbh',
    'LP Trees 5-9" dbh',
    'LP Trees 10-19" dbh',
    'LP Trees 20-29" dbh',
    'LP Trees 30+" dbh',
    'Aspen Trees (size classes not specified)',
    'Aspen Trees 0-4.9" dbh',
    'Aspen Trees 5-9" dbh',
    'Aspen Trees 10-19" dbh',
    'Aspen Trees 20+" dbh',
    'Other Trees (size classes not specified)',
    'Other Trees 0-4.9" dbh',
    'Other Trees 5-9" dbh',
    'Other Trees 10-19" dbh',
    'Other Trees 20-29" dbh',
    'Other Trees 30+" dbh'
);

$spefilename = $filename . ".txt";
$spepath =
  "c:\\Inetpub\\Scripts\\fuels\\whrm\\test\\species\\" . $taxgroup . "\\";
( $comname, $sciname ) = split '/', $species;
$sciname =
  substr( $sciname, 1 );    # 2005.02.07 DEH get rid of first blank for printout

if ($debug) {
    print " <p>comm $comname";
    print "<p> sci $sciname";
}

#########if($action=~/matrix/){
################################################
## uploading all information about the species #
################################################

print <<"endf";
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
      newin.document.writeln('     on habitat for tassel-eared squirrels. See the test and table 2 and 3 of the User&#39s Guide for information on calculations and definitions of qualitative statements.')
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

// end of hiding -->
  </script>
 </head>
 <body>
  <font face="tahoma, arial, helvetica, sans serif">
 <table align="center" width="100%" border="0">
  <tr>
  <!--<td><img src="https://localhost/fuels/whrm/images/borealtoad3_Pilliod.jpg" alt="Wildlife Habitat Response Model" align="left"></td>-->
  <td><img src="/fuels/whrm/images/borealtoad3_Pilliod.jpg" alt="Wildlife Habitat Response Model" align="left" withd="156" height="117"></td>

  <td align="center"><hr>
  <h2>Wildlife Habitat Response Model</h2>
  <h2>$treatname Details</h2>
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
    <font>Click back arrow to return to model comparison</font>
   </caption>
    <tr>
     <th BGCOLOR="#006009">
      <Font color="#99ff00">Taxonomic group:</Font></th>
     <td>$tax_group</td>
    </tr>
    <tr>
     <th BGCOLOR="#006009">
      <Font color="#99ff00">Species:</Font></th>
     <td >$comname (<i>$sciname</i>)</td>
    </tr>
  </table>
  <br>
 </center>
 </body>
</html>
endf
####open species file

if ($debug) {
    print "<p>this is the file name: $spefilename\n";
    print "<p>this is the path to the file: $spepath";
}

open( sper_file, $spepath . $spefilename ) || die("Error: files unopened!\n");
while (<sper_file>) {
    if ( $_ =~ /Rank/ ) {
        $_     = <sper_file>;        #Elena 03/18/2005
        @rankm = split( /,/, $_ );
    }
    if ( $_ =~ /Home/ ) {
        $range = <sper_file>;
        close(sper_file);
        chomp $range;                            # 2005.02.07 DEH
        $range = '[' . $range . ']'
          if ( $range =~ /no information/i );    # 2005.02.07 DEH
    }
}

if ( $range =~ /no/ ) { $fsent = "" }
else {
    $fsent = "The home range of $species is typically $range. ";
}    # 2005.02.07 DEH

open( spe_file, $spepath . $spefilename ) || die("Error: files unopened!\n");
while (<spe_file>) {
    if ( $_ =~ /Literature/ ) { close(spe_file); }
    if ( $_ =~ /Nestsite/ ) {
        $_       = <spe_file>;
        @row     = split( /:/, $_ );
        $nestrow = (@row);
        for ( $i = 0 ; $i <= ( @row - 1 ) ; $i++ ) {
            ( $nestfeacode[$i], $nestdir[$i] ) = split( /,/, $row[$i], 2 );
        }
    }
    elsif ( $_ =~ /Reprorank/ ) {
        $_           = <spe_file>;
        @row         = split( /:/, $_ );
        $nestrowrank = (@row);
        for ( $i = 0 ; $i <= ( @row - 1 ) ; $i++ ) {
            ( $nestrank1[$i], $nestrank2[$i] ) = split( /,/, $row[$i], 2 );
            if ($debug) {
                print
"<p>nestrank1 is $nestrank1[$i] and nestrank2 is $nestrank2[$i] ";
            }
        }
    }
    elsif ( $_ =~ /Foraging Habitat/ ) {
        $_        = <spe_file>;
        @row      = split( /:/, $_ );
        $fhabirow = (@row);
        for ( $i = 0 ; $i <= ( @row - 1 ) ; $i++ ) {
            ( $fhabifeacode[$i], $fhabidir[$i] ) = split( /,/, $row[$i], 2 );
        }
    }
    elsif ( $_ =~ /Habitatrank/ ) {
        $_            = <spe_file>;
        @row          = split( /:/, $_ );
        $fhabirowrank = (@row);
        for ( $i = 0 ; $i <= ( @row - 1 ) ; $i++ ) {
            ( $fhabirank1[$i], $fhabirank2[$i] ) = split( /,/, $row[$i], 2 );
            if ($debug) {
                print
"<p>fhabirank1 is $fhabirank1[$i] and fhabirank2 is $fhabirank2[$i] ";
            }
        }
    }
    elsif ( $_ =~ /Forage\/Prey Availability/ ) {
        $_         = <spe_file>;
        @row       = split( /:/, $_ );
        $preavarow = (@row);
        for ( $i = 0 ; $i <= ( @row - 1 ) ; $i++ ) {
            ( $preavafeacode[$i], $preavadir[$i] ) = split( /,/, $row[$i], 2 );
        }
    }
    elsif ( $_ =~ /Preyrank/ ) {
        $_             = <spe_file>;
        @row           = split( /:/, $_ );
        $preavarowrank = (@row);
        for ( $i = 0 ; $i <= ( @row - 1 ) ; $i++ ) {
            ( $preavarank1[$i], $preavarank2[$i] ) = split( /,/, $row[$i], 2 );
            if ($debug) {
                print
"<p>preavarank1 is $preavarank1[$i] and preavarank2 is $preavarank2[$i] ";
            }
        }
    }
    elsif ( $_ =~ /Predator Avoidance/ ) {
        $_         = <spe_file>;
        @row       = split( /:/, $_ );
        $avoprerow = (@row);
        for ( $i = 0 ; $i <= ( @row - 1 ) ; $i++ ) {
            ( $avoprefeacode[$i], $avopredir[$i] ) = split( /,/, $row[$i], 2 );
        }
    }
    elsif ( $_ =~ /Avoidrank/ ) {
        $_             = <spe_file>;
        @row           = split( /:/, $_ );
        $avoprerowrank = (@row);
        for ( $i = 0 ; $i <= ( @row - 1 ) ; $i++ ) {
            ( $avoprerank1[$i], $avoprerank2[$i] ) = split( /,/, $row[$i], 2 );
            if ($debug) {
                print
"<p>avoprerank1 is $avoprerank1[$i] and avoprerank2 is $avoprerank2[$i] ";
            }
        }
    }
    elsif ( $_ =~ /Refugia\/Shelter/ ) {
        $_         = <spe_file>;
        @row       = split( /:/, $_ );
        $refsherow = (@row);
        for ( $i = 0 ; $i <= ( @row - 1 ) ; $i++ ) {
            ( $refshefeacode[$i], $refshedir[$i] ) = split( /,/, $row[$i], 2 );
        }
    }
    elsif ( $_ =~ /Shelterrank/ ) {
        $_             = <spe_file>;
        @row           = split( /:/, $_ );
        $refsherowrank = (@row);
        for ( $i = 0 ; $i <= ( @row - 1 ) ; $i++ ) {
            ( $refsherank1[$i], $refsherank2[$i] ) = split( /,/, $row[$i], 2 );
            if ($debug) {
                print
"<p>refsherank1 is $refsherank1[$i] and refsherank2 is $refsherank2[$i] ";
            }
        }
    }
    elsif ( $_ =~ /Coverrank/ ) {
        $_             = <spe_file>;
        @row           = split( /:/, $_ );
        $refsherowrank = (@row);
        for ( $i = 0 ; $i <= ( @row - 1 ) ; $i++ ) {
            ( $coverrank1[$i], $coverrank2[$i] ) = split( /,/, $row[$i], 2 );
            if ($debug) {
                print
"<p>coverrank1 is $coverrank1[$i] and coverrank2 is $coverrank2[$i] ";
            }
        }
    }
}

close(spe_file);

################################################
##testing for features not being used  Elena 03/18/2005
################################################

@nestfeacode   = featurecheck(@nestfeacode);
@fhabifeacode  = featurecheck(@fhabifeacode);
@preavafeacode = featurecheck(@preavafeacode);
@avoprefeacode = featurecheck(@avoprefeacode);
@refshefeacode = featurecheck(@refshefeacode);

################################################
###finish features not being used
################################################

################################################
##staring calculations Elena 03/18/2005
################################################
for ( $i = 0 ; $i <= $nestrow - 1 ; $i++ ) {
    if ( $nestfeacode[$i] == -99 ) {
        $sum[0]              = 0;
        $pevaluesindex1      = 0;
        $evaltimesdirnest[0] = 0;
    }
    else {
        $evaltimesdir[$i]     = $evalues[$i] * $nestdir[$i];
        $evaltimesdirnest[$i] = $evaltimesdir[$i];
        $sum[0]               = $sum[0] +
          $evalues[$i] * $nestdir[$i] * ( $nestrank1[$i] / $rankm[1] );
        $pevaluesindex1 = $nestrow;
        $feaflag[0] = 0;
    }
    if ($debug) {
        print
"<p>nestcode is $nestfeacode[$i] and nestdir is $nestdir[$i] and product is $evaltimesdir[$i] ";
        print "<p>sum[0]is $sum[0] and pevaluesindex1 is $pevaluesindex1";
    }
}
for ( $i = 0 ; $i <= $fhabirow - 1 ; $i++ ) {
    if ( $fhabifeacode[$i] == -99 ) {
        $sum[1]               = 0;
        $pevaluesindex2       = $pevaluesindex1;
        $evaltimesdirfhabi[0] = 0;
    }
    else {
        $evaltimesdir[ $pevaluesindex1 + $i ] =
          $evalues[ $pevaluesindex1 + $i ] * $fhabidir[$i];
        $evaltimesdirfhabi[$i] = $evaltimesdir[ $pevaluesindex1 + $i ];
        $sum[1] =
          $sum[1] +
          $evalues[ $pevaluesindex1 + $i ] *
          $fhabidir[$i] *
          ( $fhabirank1[$i] / $rankm[2] );
        $pevaluesindex2 = $pevaluesindex1 + $fhabirow;
        $feaflag[1] = 0;
    }
    if ($debug) {
        print "<p>fhabicode is $fhabifeacode[$i] and fhabidir is $fhabidir[$i]";
        print "<p>sum[1]is $sum[1] and pevaluesindex2 is $pevaluesindex2";
    }
}
for ( $i = 0 ; $i <= $preavarow - 1 ; $i++ ) {
    if ( $preavafeacode[$i] == -99 ) {
        $sum[2]                = 0;
        $pevaluesindex3        = $pevaluesindex2;
        $evaltimesdirpreava[0] = 0;
    }
    else {
        $evaltimesdir[ $pevaluesindex2 + $i ] =
          $evalues[ $pevaluesindex2 + $i ] * $preavadir[$i];
        $evaltimesdirpreava[$i] = $evaltimesdir[ $pevaluesindex2 + $i ];
        $sum[2] =
          $sum[2] +
          $evalues[ $pevaluesindex2 + $i ] *
          $preavadir[$i] *
          ( $preavarank1[$i] / $rankm[3] );
        $pevaluesindex3 = $pevaluesindex2 + $preavarow;
        $feaflag[2] = 0;
    }
    if ($debug) {
        print
"<p>preavacode is $preavafeacode[$i] and preavadir is $preavadir[$i] ";
        print "<p>evaltimesdirpreava is $evaltimesdirpreava[$i] ";
        print "<p>sum[2]is $sum[2] and pevaluesindex3 is $pevaluesindex3";
        print "<p>rankm3 is:$rankm[3]";
        print "<p>preavarank1[$i] is:$preavarank1[$i]";
        print "<p>evalues[$pevaluesindex2+$i] is:$evalues[$pevaluesindex2+$i]";
    }
}
################################################
###end of calculation
################################################

################################################
####creating covercategory Elena  03/18/2005
################################################

if ( ( $avoprefeacode[0] == -99 ) && ( $refshefeacode[0] == -99 ) ) {
    $coverfeacode[0] = -99;
}
elsif ( ( $avoprefeacode[0] == -99 ) && ( $refshefeacode[0] != -99 ) ) {
    @coverfeacode = @refshefeacode;
    @coverdir     = @refshedir;
}
elsif ( ( $avoprefeacode[0] != -99 ) && ( $refshefeacode[0] == -99 ) ) {
    @coverfeacode = @avoprefeacode;
    @coverdir     = @avopredir;
}
else {
    @tempcover    = ( @avoprefeacode, @refshefeacode );
    @tempcoverdir = ( @avopredir,     @refshedir );
    $tempsize     = (@avoprefeacode) + (@refshefeacode);
    $sizec        = (@avoprefeacode);
    for ( $i = 0 ; $i <= $tempsize - 1 ; $i++ ) {
        $indexflag[$i] = 0;
        if ( $i <= $sizec - 1 ) { $indexflag[$i] = 0; }
        else {
            for ( $j = 0 ; $j <= $sizec - 1 ; $j++ ) {
                if ( $tempcover[$i] == $avoprefeacode[$j] ) {
                    $indexflag[$i] = $i;
                    $counter = $counter + 1;
                }
            }
        }
    }
    for ( $i = 0 ; $i <= $tempsize - 1 ; $i++ ) {
        if ( $i <= $sizec - 1 ) {
            $coverfeacode[$i] = $tempcover[$i];
            $coverdir[$i]     = $tempcoverdir[$i];
        }
        else {
            for ( $j = 0 ; $j <= $sizec - 1 ; $j++ ) {
                if ( $tempcover[$i] == $avoprefeacode[$j] ) { $equalflag = 1; }
            }
            if ( !$equalflag ) {
                push( @coverfeacode, $tempcover[$i] );
                push( @coverdir,     $tempcoverdir[$i] );
            }

            #else{$coverfeacode[$i]=-999;}
        }
        $equalflag = 0;
    }
}
$coverrow = (@coverfeacode);
if ($debug) {
    print "<br>the coverrow is $coverrow<br>";
    print "<br>the coverfeacode matrix is: @coverfeacode<br>";
    print "<br>the coverdir matrix is: @coverdir<br>";
    print "<br>the pevalesindex3 is: $pevaluesindex3<br>";
    print "<br>the pevalesindex4 is: $pevaluesindex4<br>";
}
##########################

for ( $i = 0 ; $i <= $coverrow - 1 ; $i++ ) {
    if ( $coverfeacode[$i] == -99 ) {
        $sum[3]               = 0;
        $pevaluesindex4       = $pevaluesindex3;
        $evaltimesdircover[0] = 0;
    }
    else {
        $evaltimesdir[ $pevaluesindex3 + $i ] =
          $evalues[ $pevaluesindex3 + $i ] * $coverdir[$i];
        $evaltimesdircover[$i] = $evaltimesdir[ $pevaluesindex3 + $i ];
        $sum[3] =
          $sum[3] +
          $evalues[ $pevaluesindex3 + $i ] *
          $coverdir[$i] *
          ( $coverrank1[$i] / $rankm[4] );
        $pevaluesindex4 = $pevaluesindex3 + $coverrow;
        $feaflag[3] = 0;
    }
    if ($debug) {
        print
          "<p>covercode is $coverfeacode[$i] and coverdir is $coverdir[$i] ";
        print "<p>sum[3]is $sum[3] and pevaluesindex3 is $pevaluesindex3+$i";
    }
}

################################################
##end of creating cover category
################################################

if ($debug) {
    $sizeevaltimesdir = @evaltimesdir;
    print "sizeevaltimesdir is $sizeevaltimesdir";
}
for ( $i = 0 ; $i <= ( @evaltimesdir - 1 ) ; $i++ ) {
    if ( $evaltimesdir[$i] == -3 ) { $pevaltimesdir[$i] = "Highly Negative"; }
    if ( $evaltimesdir[$i] == -2 ) {
        $pevaltimesdir[$i] = "Moderately Negative";
    }
    if ( $evaltimesdir[$i] == -1 ) { $pevaltimesdir[$i] = "Slightly Negative"; }
    if ( $evaltimesdir[$i] == 0 )  { $pevaltimesdir[$i] = "Neutral"; }
    if ( $evaltimesdir[$i] == 1 )  { $pevaltimesdir[$i] = "Slightly Positive"; }
    if ( $evaltimesdir[$i] == 2 ) {
        $pevaltimesdir[$i] = "Moderately Positive";
    }
    if ( $evaltimesdir[$i] == 3 ) { $pevaltimesdir[$i] = "Highly Positive"; }
}

$rr1 = $nestrow;
if ( $feaflag[0] ) { $animalresp[0] = -99; $totalrow = 1; }
else {
    $animalresp[0] = $sum[0] / $rr1;
    $totalrow      = $totalrow + $rr1;
    $divisorstand  = $divisorstand + 1;
}

$rr2 = $fhabirow;
if ( $feaflag[1] ) { $animalresp[1] = -99; }
else {
    $animalresp[1] = $sum[1] / $rr2;
    $totalrow      = $totalrow + $rr2;
    $divisorstand  = $divisorstand + 1;
}

$rr3 = $preavarow;
if ( $feaflag[2] ) { $animalresp[2] = -99; }
else {
    $animalresp[2] = $sum[2] / $rr3;
    $totalrow      = $totalrow + $rr3;
    $divisorstand  = $divisorstand + 1;
}

$rr4 = $coverrow;    #Elena 03/18/2005
if ( $feaflag[3] ) { $animalresp[3] = -99 }
else {
    $animalresp[3] = $sum[3] / $rr4;
    $totalrow      = $totalrow + $rr4;
    $divisorstand  = $divisorstand + 1;
}

$rr6 = $rr2 + $rr3;

#################################################
##Uncertaintly calculation of change of sign in #
##dirction.					#
#################################################
if ($debug) {
    print "<p>rows are: $rr1 and $rr2 and $rr3 and $rr4 and $rr5<br>";
    print "<p>evaltimesdirnest is: @evaltimesdirnest<br>";
    print "<p>evaltimesdirfhabi is: @evaltimesdirfhabi<br>";
    print "<p>evaltimesdirpreava is: @evaltimesdirpreava<br>";
    print "<p>evaltimesdiravopre is: @evaltimesdiravopre<br>";
    print "<p>evaltimesdirrefshe is: @evaltimesdirrefshe<br>";
}

for ( $k = 0 ; $k <= ( $rr1 - 1 ) ; $k++ ) {
    if    ( $evaltimesdirnest[$k] > 0 )  { $uncernest[$k] = 1 }
    elsif ( $evaltimesdirnest[$k] == 0 ) { $uncernest[$k] = 0 }
    else                                 { $uncernest[$k] = -1 }
}
if ($debug) { print "<p>uncernest is @uncernest<br>"; }
for ( $k = 0 ; $k <= ( $rr2 - 1 ) ; $k++ ) {
    if    ( $evaltimesdirfhabi[$k] > 0 )  { $uncerfhabi[$k] = 1 }
    elsif ( $evaltimesdirfhabi[$k] == 0 ) { $uncerfhabi[$k] = 0 }
    else                                  { $uncerfhabi[$k] = -1 }
}
if ($debug) { print "<p>uncerfhabi is @uncerfhabi<br>"; }
for ( $k = 0 ; $k <= ( $rr3 - 1 ) ; $k++ ) {
    if    ( $evaltimesdirpreava[$k] > 0 )  { $uncerpreava[$k] = 1 }
    elsif ( $evaltimesdirpreava[$k] == 0 ) { $uncerpreava[$k] = 0 }
    else                                   { $uncerpreava[$k] = -1 }
}
if ($debug) { print "<p>uncerpreava is @uncerpreava<br>"; }
for ( $k = 0 ; $k <= ( $rr4 - 1 ) ; $k++ ) {
    if    ( $evaltimesdircover[$k] > 0 )  { $uncercover[$k] = 1 }
    elsif ( $evaltimesdircover[$k] == 0 ) { $uncercover[$k] = 0 }
    else                                  { $uncercover[$k] = -1 }
}
if ($debug) { print "<p>uncercover is @uncercover<br>"; }

@unflag     = ( 0, 0, 0, 0, 0 );
@suncernest = sort @uncernest;
if ( ( $suncernest[0] == 0 ) || ( $suncernest[ $rr1 - 1 ] == 0 ) ) {
    $unflag[0] = 0;
}
elsif ( $suncernest[0] != $suncernest[ $rr1 - 1 ] ) { $unflag[0] = 1 }
@suncerfhabi = sort @uncerfhabi;
if ( ( $suncerfhabi[0] == 0 ) || ( $suncerfhabi[ $rr2 - 1 ] == 0 ) ) {
    $unflag[1] = 0;
}
elsif ( $suncerfhabi[0] != $suncerfhabi[ $rr2 - 1 ] ) { $unflag[1] = 1 }
@suncerpreava = sort @uncerpreava;
if ( ( $suncerpreava[0] == 0 ) || ( $suncerpreava[ $rr3 - 1 ] == 0 ) ) {
    $unflag[2] = 0;
}
elsif ( $suncerpreava[0] != $suncerpreava[ $rr3 - 1 ] ) { $unflag[2] = 1 }
@suncercover = sort @uncercover;
if ( ( $suncercover[0] == 0 ) || ( $suncercover[ $rr4 - 1 ] == 0 ) ) {
    $unflag[3] = 0;
}
elsif ( $suncercover[0] != $suncercover[ $rr4 - 1 ] ) { $unflag[3] = 1 }

if ($debug) {
    print
"<p>suncernest is :@suncernest and $suncernest[0] and $suncernest[$rr1-1] and $unflag[0]<br>";
    print
"<p>suncerfhabi is :@suncerfhabi and $suncerfhabi[0] and $suncerfhabi[$rr2-1] and $unflag[1]<br>";
    print
"<p>suncerpreava is :@suncerpreava and $suncerpreava[0] and $suncerpreava[$rr3-1] and $unflag[2]<br>";
    print
"<p>suncercover is :@suncercover and $suncercover[0] and $suncercover[$rr4-1] and $unflag[3]<br>";

}

$psentence[0] = "Highly Negative";
$psentence[1] = "Moderately Negative";
$psentence[2] = "Slightly Negative";
$psentence[3] = "Minimal to None";
$psentence[4] = "Slightly Positive";
$psentence[5] = "Moderately Positive";
$psentence[6] = "Highly Positive";

$upsentence[0] =
  "Highly Negative, but low confidence <font color=red >*</font>";
$upsentence[1] =
  "Moderately Negative, but low confidence <font color=red >*</font>";
$upsentence[2] =
  "Slightly Negative, but low confidence<font color=red > *</font>";
$upsentence[3] =
  "Minimal to None, but low confidence <font color=red >*</font>";
$upsentence[4] =
  "Slightly Positive, but low confidence <font color=red >*</font>";
$upsentence[5] =
  "Moderately Positive, but low confidence<font color=red > *</font>";
$upsentence[6] =
  "Highly Positive, but low confidence <font color=red >*</font>";

###extracting information from the file

open( LITFILE, $spepath . $spefilename ) || die("Error: files unopened!\n");
while (<LITFILE>) {
    if ( $_ =~ /Literature/ ) { @litreview = <LITFILE>; }
}

close(LITFILE);
$litsize = (@litreview);
for ( $i = 0 ; $i <= $litsize - 1 ; $i++ ) {
    if ( $litreview[$i] =~ m/Canopy Cover/ ) {
        $canopycover = $litreview[ $i + 1 ];
    }

}
##print "<br>litsize is: $litsize";
##########################end info file

$fpsentence[0] = " highly negative ";
$fpsentence[1] = " moderately negative ";
$fpsentence[2] = " slightly negative ";
$fpsentence[3] = " minimal affect ";
$fpsentence[4] = " slightly positive ";
$fpsentence[5] = " moderately positive ";
$fpsentence[6] = " highly positive ";

for ( $i = 0 ; $i <= 3 ; $i++ ) {
    if ( ( $animalresp[$i] >= -3 ) && ( $animalresp[$i] < -2 ) ) {
        if ( $unflag[$i] ) {
            $panimalresp[$i] = $upsentence[0];
            $ffpsentence[$i] = $fpsentence[0];
        }
        else {
            $panimalresp[$i] = $psentence[0];
            $ffpsentence[$i] = $fpsentence[0];
        }
    }
    elsif ( ( $animalresp[$i] >= -2 ) && ( $animalresp[$i] < -1 ) ) {
        if ( $unflag[$i] ) {
            $panimalresp[$i] = $upsentence[1];
            $ffpsentence[$i] = $fpsentence[1];
        }
        else {
            $panimalresp[$i] = $psentence[1];
            $ffpsentence[$i] = $fpsentence[1];
        }
    }
    elsif ( ( $animalresp[$i] >= -1 ) && ( $animalresp[$i] < -0.25 ) ) {
        if ( $unflag[$i] ) {
            $panimalresp[$i] = $upsentence[2];
            $ffpsentence[$i] = $fpsentence[2];
        }
        else {
            $panimalresp[$i] = $psentence[2];
            $ffpsentence[$i] = $fpsentence[2];
        }
    }
    elsif ( ( $animalresp[$i] >= -0.25 ) && ( $animalresp[$i] <= 0.25 ) ) {
        if ( $unflag[$i] ) {
            $panimalresp[$i] = $upsentence[3];
            $ffpsentence[$i] = $fpsentence[3];
        }
        else {
            $panimalresp[$i] = $psentence[3];
            $ffpsentence[$i] = $fpsentence[3];
        }
    }
    elsif ( ( $animalresp[$i] > 0.25 ) && ( $animalresp[$i] <= 1 ) ) {
        if ( $unflag[$i] ) {
            $panimalresp[$i] = $upsentence[4];
            $ffpsentence[$i] = $fpsentence[4];
        }
        else {
            $panimalresp[$i] = $psentence[4];
            $ffpsentence[$i] = $fpsentence[4];
        }
    }
    elsif ( ( $animalresp[$i] > 1 ) && ( $animalresp[$i] <= 2 ) ) {
        if ( $unflag[$i] ) {
            $panimalresp[$i] = $upsentence[5];
            $ffpsentence[$i] = $fpsentence[5];
        }
        else {
            $panimalresp[$i] = $psentence[5];
            $ffpsentence[$i] = $fpsentence[5];
        }
    }
    elsif ( ( $animalresp[$i] > 2 ) && ( $animalresp[$i] <= 3 ) ) {
        if ( $unflag[$i] ) {
            $panimalresp[$i] = $upsentence[6];
            $ffpsentence[$i] = $fpsentence[6];
        }
        else {
            $panimalresp[$i] = $psentence[6];
            $ffpsentence[$i] = $fpsentence[6];
        }
    }
    else {
        $panimalresp[$i] = "Not Available";
        $ffpsentence[$i] = "Not Available";
    }
}

if ($debug) {
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
}

#### 	2004.12.13 DEH log the run

# print $species, date, IP

# Record run in log
$host        = $ENV{REMOTE_HOST};
$host        = $ENV{REMOTE_ADDR} if ( $host eq '' );
$user_really = $ENV{'HTTP_X_FORWARDED_FOR'};
$host        = $user_really if ( $user_really ne '' );

$mydate = &printdate;
open WIRMLOG, ">>../working/whrm.log";
print WIRMLOG "$host\t";
printf WIRMLOG '%0.2d:%0.2d ', $hour, $min;
print WIRMLOG @ampm[$ampmi], "  ", @days[$wday], " ", @months[$mon], " ",
  $mday, ", ", $year + 1900, "\t";
print WIRMLOG $species, "\n";
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
							<font color="#99ff00">Life History Requirements</font></th>
						<th  bgcolor="#006009">
							<font color="#99ff00">Key Habitat Element(s)</font></th>
						<th  bgcolor="#006009">
							<font color="#99ff00">Change in Habitat <br>Element(s)<br>
						(user's selection)</font>
						</th>
						<th  bgcolor="#006009">
							<font color="#99ff00">Predicted Effects<br>on Habitat</font>
      					<br>
        					<a href="javascript:explain_predict()"
           					onMouseOver="window.status=' Explain Predicted Effects on Habitat (new window)';return true"
           					onMouseOut="window.status='Wildlife Habitat Response Model'; return true">
         					<img src="/fuels/whrm/images/quest2.gif" width="18" height="16" border="0"></a>
						</th>
						<th  bgcolor="#006009">
							<font color="#99ff00">Weighted Average<br>Effect on Habitat</font>
      					<br>
        					<a href="javascript:explain_average()"
           					onMouseOver="window.status='Explain Weighted Average Effect on Habitat (new window)';return true"
           					onMouseOut="window.status='Wildlife Habitat Response Model'; return true">
         					<img src="/fuels/whrm/images/quest2.gif" width="18" height="16" border="0"></a>
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
for ( $i = 0 ; $i <= $nestrow - 1 ; $i++ ) {
    if ( $i == 0 ) {
        if ( $nestfeacode[$i] == -99 ) {
            print "<td colspan=4 align=center>No Information Is Available</td>
			</tr>";
        }
        else {
            print "<td>$habitatfeatures[$nestfeacode[$i]]</td>
			<td align=center>$pevalues[$i]</td>
			<td align=center>$pevaltimesdir[$i]</td>
			<td align=center rowspan=$rr1>$panimalresp[$i]</td>
			</tr>";
        }
    }
    else {
        print "<tr>
		<td>$habitatfeatures[$nestfeacode[$i]]</td>
		<td align=center>$pevalues[$i]</td>
		<td align=center>$pevaltimesdir[$i]</td>
		</tr>";
    }
}
print <<"fin1";
					<tr>
						<th rowspan=$rr6 BGCOLOR="#006009">
							<Font color="#99ff00">Food Resources</Font></th>
						<th rowspan=$fhabirow BGCOLOR="#006009">
							<Font color="#99ff00">Foraging Habitat</Font></th>
fin1

for ( $i = 0 ; $i <= $fhabirow - 1 ; $i++ ) {
    if ( $i == 0 ) {
        if ( $fhabifeacode[$i] == -99 ) {
            print "<td colspan=4 align=center>No Information Is Available</td>
			</tr>";
        }

        else {
            print "<td>$habitatfeatures[$fhabifeacode[$i]]</td>
			<td align=center>$pevalues[$pevaluesindex1+$i]</td>
			<td align=center>$pevaltimesdir[$pevaluesindex1+$i]</td>
			<td align=center rowspan=$rr2>$panimalresp[1]</td>
			</tr>";
            ##$pevaluesindex2=$pevaluesindex1+$fhabirow;
        }
    }
    else {
        print "<tr>
		<td>$habitatfeatures[$fhabifeacode[$i]]</td>
		<td align=center>$pevalues[$pevaluesindex1+$i]</td>
		<td align=center>$pevaltimesdir[$pevaluesindex1+$i]</td>
		</tr>";
    }
}
print "<tr>
	<th rowspan=$preavarow BGCOLOR=\"#006009\">
	<Font color=\"#99ff00\">Forage,<br>Prey Habitat</Font></th>";

for ( $i = 0 ; $i <= $preavarow - 1 ; $i++ ) {
    if ( $i == 0 ) {
        if ( $preavafeacode[$i] == -99 ) {
            print "<td colspan=4 align=center>No Information Is Available</td>
			</tr>";
        }
        else {
            print "<td>$habitatfeatures[$preavafeacode[$i]]</td>
			<td align=center>$pevalues[$pevaluesindex2+$i]</td>
			<td align=center>$pevaltimesdir[$pevaluesindex2+$i]</td>
			<td align=center rowspan=$rr3>$panimalresp[2]</td> <!-- DEH was [1] -->
			</tr>";
        }
    }
    else {
        print "<tr>
		<td>$habitatfeatures[$preavafeacode[$i]]</td>
		<td align=center>$pevalues[$pevaluesindex2+$i]</td>
		<td align=center>$pevaltimesdir[$pevaluesindex2+$i]</td>
		</tr>";
    }
}
print <<"fin2";
		<tr>
		<th rowspan=$coverrow BGCOLOR="#006009">
		<Font color="#99ff00">Cover</Font></th>
		<th rowspan=$coverrow BGCOLOR="#006009">
		<Font color="#99ff00">Shelter from Predators,<br>
		and Environmental Extremes</Font></th>
fin2
for ( $i = 0 ; $i <= $coverrow - 1 ; $i++ ) {
    if ( $i == 0 ) {
        if ( $coverfeacode[$i] == -99 ) {
            print "<td colspan=4 align=center>No Information Is Available</td>
			</tr>";
        }
        else {
            print "<td>$habitatfeatures[$coverfeacode[$i]]</td>
			<td align=center>$pevalues[$pevaluesindex3+$i]</td>
			<td align=center>$pevaltimesdir[$pevaluesindex3+$i]</td>
			<td align=center rowspan=$rr4>$panimalresp[3]</td>
			</tr>";
        }
    }
    else {
        print "<tr>
		<td>$habitatfeatures[$coverfeacode[$i]]</td>
		<td align=center>$pevalues[$pevaluesindex3+$i]</td>
		<td align=center>$pevaltimesdir[$pevaluesindex3+$i]</td>
		</tr>";
    }
}
#########end of copy
print "				</table>";
@sunflag  = sort @unflag;
$footnote = $sunflag[$#unflag];
if ($footnote) {
    print "
<font color=red>*</font><font size=2 ><em>When the \"weighted average predicted effect on habitat\" includes some habitat elements
that positively influenced habitat and others that negatively influenced habitat, then the
average may be misleading. Due to this uncertainty, we recommend you consult a wildlife biologist regarding the relative
importance of each habitat element contributing to averages that have low confidence.</em></font>";
}
print "<br><center>Click back arrow to return to model comparison</center>";

print <<"end2";
<!-- /font -->  <!-- DEH -->
   <br><br>
   <hr>
<table border=0 width=100%>
     <tr>
      <td valign="top" bgcolor="lightgoldenrodyellow">
       <font face="tahoma, arial, helvetica, sans serif" size=1>
        <b>Documentation and User Manual:</b>
        [<a href="/fuels/whrm/documents/Chapter_IV_DraftforWeb.pdf" target="_blank">User guide</a> (14-page PDF)]
        [<a href="https://www.fs.fed.us/rm/pubs/rmrs_rn023_04.pdf" target="_blank">Fact sheet</a> (1-page PDF)]
	[<a href="/fuels/whrm/documents/MasterBibliography.pdf " target="_blank"><b>Complete WHRM bibliography</b> </a>(39-page PDF)]
        <br>
        The Wildlife Habitat Response Model: <b>WH</b><b>RM</b><br>
        Input interface v.
        <a href="javascript:popuphistory()"> $version</a>
        (for review only) by Elena Velasquez &amp; David Hall<br>
        Model developed by: David Pilliod<br>
        Team leader Elaine Kennedy Sutherland, USDA Forest Service, Rocky Mountain Research Station
       </font>
      </td>
      <td valign="top">
       <a href="https://forest.moscowfsl.wsu.edu/fuels/comments.html" target="comments"><img src="/fswepp/images/epaemail.gif" align="right" border=0></a>
      </td>
     </tr>
   </table>
  </font>	
 </body>
</html>
end2

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
