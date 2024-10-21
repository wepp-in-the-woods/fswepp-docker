#!/usr/bin/perl

use CGI qw(escapeHTML);

# showclimates.pl  --

$version = '2009.09.03';

my $cgi = CGI->new;

$state    = escapeHTML( $cgi->param('state') );
$units    = escapeHTML( $cgi->param('units') );
$action   = escapeHTML( $cgi->param('action') );
$comefrom = escapeHTML( $cgi->param('comefrom') );

# https://forest.moscowfsl.wsu.edu/cgi-bin/fswepp/rc/showclimates.pl?units=<script>document.cookie="testlfyg=5195;"</script>

################################
# Go to Show Personal Climates #
################################

if ( $state eq "personal" ) {
    exec "../rc/showpersonal.pl $action $units $comefrom";
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

    print qq(
<html>
  <head>
   <title>Rock:Clime -- $state_name Climate Stations</title>
 </head>
 <body bgcolor="white">
  <font face="arial, sans serif">
   <center>
   <H3>USDA FS Rock:Clime<br>$state_name Climate Stations</H3>
);

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
<input type="hidden" name="units" value="', $units, '">
<input type="hidden" name="startyear" value="1"><br>
';

    open M, "<" . $state_file;
    $st = <M>;
    while (<M>) {
        print;
    }
    close M;

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
  <input type="submit" name="submitbutton"  value="DESCRIBE CLIMATE">
  <input type="submit" name="submitbutton" value="MODIFY CLIMATE">
</form>


<form method="post" name="RockClim" action="../rc/rockclim.pl">
<input type="hidden" name="units" value="',    $units,    '">
<input type="hidden" name="action" value="',   $action,   '">
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
