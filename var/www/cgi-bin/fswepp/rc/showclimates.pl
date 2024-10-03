#!/usr/bin/perl

use CGI qw(escapeHTML);

# showclimates.pl  --

$version = '2009.09.03';

# 19 February 2003 DEH added "USDA FS Rock:Clime" and specified font
# 19 July 2002 DEH fixed $title"; error - caught in some browsers...

#  usage:
#    <form ACTION="https://host/cgi-bin/fswepp/rc/showclimates.pl" method="post">
#  parameters:
#    state
#    units		'm' or 'ft'
#    action		'-download' or '-server'
#    comefrom		'https://host/cgi-bin/fswepp/wr/wepproad.pl' ...
#    me
#  reads:
#    $state_file

#  FSWEPP, USDA Forest Service, Rocky Mountain Research Station, Soil & Water Engineering
#  Science by Bill Elliot et alia                                      Code by David Hall
#  2005.12.29 DEH Change from <H1> to <H3>
#  2003.02.19
#  17 April 2002 DEH    prepare to allow .PAR file d/l (calls showpar.pl)
#  05 March 2001 DEH 	add 'me' to retreat button
#		 DEH	finish off HTML body for successful page
#  19 October 1999
my $cgi = CGI->new;

$state    = escapeHTML( $cgi->param('state') );
$units    = escapeHTML( $cgi->param('units') );
$action   = escapeHTML( $cgi->param('action') );
$comefrom = escapeHTML( $cgi->param('comefrom') );
$me       = escapeHTML( $cgi->param('me') );

# https://forest.moscowfsl.wsu.edu/cgi-bin/fswepp/rc/showclimates.pl?units=<script>document.cookie="testlfyg=5195;"</script>

$unixserver = "false";

################################
# Go to Show Personal Climates #
################################

if ( $state eq "personal" ) {
    exec "../rc/showpersonal.pl $action $units $comefrom $me";
}

#########################################
# Verify state entry AL..WY or whatever #
#########################################

if ( $state eq "" ) { $state = "id" }

# store valid states (plus) in array @states and
@states = (
    'al', 'az', 'ar', 'ca', 'co', 'ct', 'de', 'fl',
    'ga', 'id', 'il', 'in', 'ia', 'ks', 'ky', 'la',
    'me', 'md', 'ma', 'mi', 'mn', 'ms', 'mo', 'mt',
    'ne', 'nv', 'nh', 'nj', 'nm', 'ny', 'nc', 'nd',
    'oh', 'ok', 'or', 'pa', 'ri', 'sc', 'sd', 'tn',
    'tx', 'ut', 'vt', 'va', 'wa', 'wv', 'wi', 'wy',
    'dc', 'ak', 'hi', 'pr', 'pi', 'vi', 'if', 'nonus',
    'tahoe'
);
for (@states) { $states{$_}++; }

####################################################
#  build state climate filename and get state name #
####################################################

if ( $states{$state} ) {
    $state_file = $state . "/" . $state . "_climates";

    # open specified state climate and serve
    print "Content-type: text/html\n\n";
    open CLIM, "<" . $state_file;    # || die "can't open file!";
    $state_name = <CLIM>;
    chomp $state_name;
    close CLIM;

#############
    # HTML page #
#############

    print "<html>
  <head>
   <title>Rock:Clime -- $state_name Climate Stations</title>";
    print <<'EOD';
      
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
   alert('Look for this feature shortly: ' + station)
   document.displaypar.parfilename.value = filename
//   document.displaypar.submit()
  }

// -->
  </SCRIPT>
 </HEAD>
 <body bgcolor="white">
  <font face="arial, sans serif">
   <CENTER>
EOD
    print "<H3>USDA FS Rock:Clime<br>$state_name Climate Stations</H3>\n";

    #    print "$me<br>\n";
    if ( $action eq '-download' ) {
        print
'<form name="sc" ACTION="/cgi-bin/fswepp/rc/climate.cli" method="post">',
          "\n";
    }
    else {
        print
'<form name="sc" ACTION="/cgi-bin/fswepp/rc/copypar.pl" method="post">',
          "\n";
    }

    print '<input type="hidden" name="comefrom" value="', $comefrom, '">
<input type="hidden" name="me" value="',    $me,    '">
<input type="hidden" name="units" value="', $units, '">
<input type="hidden" name="startyear" value="1"><br>
';
    if ( $unixserver eq 'true' ) {
        open M, "<" . $state_file;
        $st = <M>;    # California

        #          print $st,"\n";
        $st = <M>;    # <input type="hidden" name="state" value="ca">
        print $st, "\n";
        $_ = <M>;     # <select name="station">
        print '<input type="hidden" name="station">', "\n";
        while (<M>) {
            chomp;
            if ( $_ ne '</select>' ) {
                ( $optval, $file, $stat ) = split /\"/;
                $stat = substr( $stat, 1 );
                chomp $stat;
                print '<a href="/fswepp/need_js.html" onClick="Submit(';
                print "'", $file, "'); return false", '">', $stat, "</a><br>\n";
            }
        }
        close M;
    }    #  $unixserver true
    else {
        open M, "<" . $state_file;
        $st = <M>;
        while (<M>) {
            print;
        }
        close M;
    }    # $unixserver false

    print "<P>\n";

    if ( $action eq '-download' ) {
        print
'Number of years of climate <input type="text" name="simyears" value="30" size=4> (approx 26K per year)
  <p>
  <input type="submit" name="submitbutton" value="DOWNLOAD CLIMATE">
  <input type="hidden" name="action" value="', $action, '">';
    }
    else {
        print
'<input type="submit" name="submitbutton" value="ADD TO PERSONAL CLIMATES"> ';
    }
    print '
  <input type="submit" name="submitbutton" value="DESCRIBE CLIMATE">
  <input type="submit" name="submitbutton" value="MODIFY CLIMATE">
</form>


<form method="post" name="RockClim" action="../rc/rockclim.pl">
<input type="hidden" name="units" value="',    $units,    '">
<input type="hidden" name="action" value="',   $action,   '">
<input type="hidden" name="me" value="',       $me,       '">
<input type="hidden" name="comefrom" value="', $comefrom, '">
<input type="submit" name="submit" value="Retreat">
</form> 
';

    print '</CENTER>';

    print "   <font size=-2>
    <hr>
    <b>showclimates</b> version $version (a part of <b>Rock:Clime</b>)<br>
    USDA Forest Service Rocky Mountain Research Station<br>
    1221 South Main Street, Moscow, ID 83843
   </font>
 </body>
</html>
";
}
else {
    print "Content-type: text/html\n\n";
    print "<HTML>\n";
    print " <HEAD>\n";
    print "  <TITLE>Something is wrong!</TITLE>\n";
    print " </HEAD>\n";
    print ' <BODY background="/fswepp/images/rcdraft.gif">', "\n";
    print '  <font face="tahoma, arial">',                   "\n";
    print "   <CENTER><H2>Excuse me!</H2></CENTER>\n";
    print
      "   I don't like the values of some of the parameters I received.<p>\n";
    print '   state:   ', $state, "<br>\n";
    print "   <br><br><br>\n";
    print "   Rock:clime (showclimates.pl version $version)\n";
    print "  </font>\n";
    print " </body>\n";
    print "</html>\n";
}
