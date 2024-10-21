#!/usr/bin/perl

use strict;
use warnings;

use MoscowFSL::FSWEPP::FsWeppUtils qw(get_user_id get_version);
use MoscowFSL::FSWEPP::CligenUtils qw(GetPersonalClimates);

#  FS WEPP, USDA Forest Service, Rocky Mountain Research Station, Soil & Water Engineering
#  Science by Bill Elliot et alia                      Code by David Hall & Dayna Scheele
#  19 October 1999

my ( $action, $units, $comefrom) = map { chomp; $_ } @ARGV[ 0 .. 3 ];
my $version = get_version(__FILE__); 
my $user_ID = get_user_id();

my @climates = GetPersonalClimates($user_ID);
my $num_cli = scalar @climates;

my $custCli = '../working/' . $user_ID;

print "Content-type: text/html\n\n";
print '
<html>
<head>
<title>Personal Climate Stations</title>

<SCRIPT Language="JavaScript">
<!--

  function isNumber(inputVal) {
  // general purpose function to see whether a suspected numeric input
  // is a positive or negative number.
  // Ref.: JavaScript Handbook. Danny Goodman.
  oneDecimal = false                              // no dots yet
  inputStr = "" + inputVal                        // force to string
  for (var i = 0; i < inputStr.length; i++) {     // step through each char
    var oneChar = inputStr.charAt(i)              // get one char out
    if (i == 0 && oneChar == "-") {               // negative OK at char 0
      continue
    }
    if (oneChar == "." && !oneDecimal) {
      oneDecimal = true
      continue
    }
    if (oneChar < "0" || oneChar > "9") {
      return false
    }
  }
  return true
  }

  function Submit(filename) {
    document.sc.station.value=filename;
    document.sc.submit()
  }

  function displayPar() {  
   var filename = 
     document.sc.station.options[document.sc.station.selectedIndex].value
   var station = 
     document.sc.station.options[document.sc.station.selectedIndex].text
   alert(\'Watch for this feature soon: \' + station + \' \' + filename)
  }

   // -->
  </SCRIPT>
 </head>
 <body bgcolor="white">
  <font face="Arial, Geneva, Helvetica">
   <CENTER>
    <H2>Personal Climate Stations</H2>
';

print '<form name="sc" ACTION="/cgi-bin/fswepp/rc/pclimate.pl" method="post">',
  "\n";

if ( $num_cli == 0 ) { print "No personal climates exist<p><hr>\n" }
else {
    print ' <SELECT NAME="station" SIZE="15">';
    foreach my $ii ( 0 .. $#climates ) {
        print '<OPTION VALUE="', $climates[$ii]->{'clim_file'}, '"';
        print ' selected' if $ii == 0;
        print '> ', $climates[$ii]->{'clim_name'}, "\n";
    }
    print '  </SELECT>';

}
print '
      <p>
      <input type="hidden" name="state" value="',    $custCli,  '">
      <input type="hidden" name="comefrom" value="', $comefrom, '">
      <input type="hidden" name="units" value="',    $units,    '">
      <input type="hidden" name="startyear" value="1">
      ';

if ( $action eq '-download' ) {
    print '
    Number of years of climate <input type="text" name="simyears" value="30" size=4> (approx 26K per year)
    <p>
    <input type="submit" name="submitbutton" value="DOWNLOAD CLIMATE">
    <input type="hidden" name="action" value="', $action, '">';
}

print '
    <input type="submit" name="submitbutton" value="DESCRIBE CLIMATE">
    <input type="submit" name="submitbutton" value="MODIFY CLIMATE">
   </form>
   <form method="post" name="RockClim" action="../rc/rockclim.pl">
    <input type="hidden" name="units" value="',    $units,    '">
    <input type="hidden" name="action" value="',   $action,   '">
    <input type="hidden" name="comefrom" value="', $comefrom, '">
    <input type="submit" name="submit" value="Retreat">
   </form>
  </center>
';

print "
  <font size=-2>
   showpersonal.pl version $version
   (a part of <b>Rock:Clime</b>)<br>
   U.S.D.A. Forest Service, Rocky Mountain Research Station
  </font>
 </body>
</html>";
