#!/usr/bin/perl
use warnings;
use CGI qw(:standard escapeHTML);

use MoscowFSL::FSWEPP::FsWeppUtils qw(get_version get_user_id);
use MoscowFSL::FSWEPP::CligenUtils qw(GetPersonalClimates);

my $debug   = 0;
my $version = get_version(__FILE__);
my $user_ID = get_user_id();

my @climates = GetPersonalClimates($user_ID);
my $num_cli  = scalar @climates;

####################
# Get input values #
####################

my $arg0 = $ARGV[0];
chomp $arg0;
my $arg1 = $ARGV[1];
chomp $arg1;
my $arg2 = $ARGV[2];
chomp $arg2;
my $arg3 = $ARGV[3];
chomp $arg3;

my ( $goback, $units, $action, $comefrom );
if ( $arg0 . $arg1 . $arg2 . $arg3 eq "" ) {
    my $cgi = CGI->new;

    # Initialize parameters
    $goback = escapeHTML( $cgi->param('goback') );
    $units  = escapeHTML( $cgi->param('units') );
    $action = escapeHTML( $cgi->param('action') || '-download' )
      ;    # why is the default '-download'?
    $comefrom = escapeHTML( $cgi->param('comefrom') );
}
else {
    # this is bad.
    if ( $arg0 eq "-um" || $arg0 eq "-uft" ) { $units = substr( $arg0, 2 ) }
    if ( $arg1 eq "-um" || $arg1 eq "-uft" ) { $units = substr( $arg1, 2 ) }
    if ( $arg2 eq "-um" || $arg2 eq "-uft" ) { $units = substr( $arg2, 2 ) }
    if ( $arg0 eq "-download" || $arg0 eq "-server" ) { $action = $arg0 }
    if ( $arg1 eq "-download" || $arg1 eq "-server" ) { $action = $arg1 }
    $comefrom = "";

    if ( lc($arg3) =~ /http/ ) { $comefrom = $arg3 }
    if ( lc($arg2) =~ /http/ ) { $comefrom = $arg2 }
    if ( lc($arg1) =~ /http/ ) { $comefrom = $arg1 }
    if ( lc($arg0) =~ /http/ ) { $comefrom = $arg0 }
}

$custCli = '../working/' . $user_ID . '_';    # DEH 03/05/2001

if ( $action ne "-server" ) { $action = "-download" }

#############
# HTML page #
#############

print "Content-type: text/html\n\n";
print '<html>
 <head>
  <title>Rock:Clime</title>
  <!-- rockclim.pl version ', $version, ' -->
 </head>
 <BODY bgcolor="white" link="#1603F3" vlink="160A8C">
 <font face="Arial, Geneva, Helvetica">

';

$clim_name = '';

if ( $action eq '-download' ) {
    print '  <a href="/fswepp/">
    <IMG src="/fswepp/images/fsweppic2.jpg"
    align="left" height=75 width=75 alt="Return to FSWEPP menu" border=0></a>
       <A HREF="/fswepp/docs/rcimg.html" target="_documentation">
       <IMG src="/fswepp/images/ipage.gif"
        align="right" alt="Read the documentation" border=0></a>';
}
else {
    if ( $comefrom =~ /road/ ) {
        print '
            <a href="/cgi-bin/fswepp/wr/">
            <img src="/fswepp/images/road4.gif"
            alt="Return to WEPP:Road" border=2
            align=left width=50 height=50
            onMouseOver="window.status=\'Return to WEPP:Road input screen\'; return true"
            onMouseOut="window.status=\' \'; return true">
            ';
    }
    elsif ( $comefrom =~ /wd/ ) {
        print '
            <a href="/cgi-bin/fswepp/wd/">
            <img src="/fswepp/images/ermit.gif"
            alt="Return to Disturbed WEPP" border=2
            align=left width=50 height=50
            onMouseOver="window.status=\'Return to ERMiT input screen\'; return true"
            onMouseOut="window.status=\' \'; return true">
            ';
    }
    elsif ( $comefrom =~ /ermit/ ) {
        print '
            <a href="/cgi-bin/fswepp/ermit/">
            <img src="/fswepp/images/ermit.gif"
            alt="Return to ERMiT" border=2
            align=left width=50 height=50
            onMouseOver="window.status=\'Return to ERMiT input screen\'; return true"
            onMouseOut="window.status=\' \'; return true">
            ';
    }
    elsif ( $comefrom =~ /fume/ ) {
        print '
            <a href="/cgi-bin/fswepp/fume/">
            <img src="/fswepp/images/fume.jpg"
            alt="Return to WEPP FuME" border=2
            align=left width=50 height=50
            onMouseOver="window.status=\'Return to WEPP FuME input screen\'; return true"
            onMouseOut="window.status=\' \'; return true">
            ';
    }
    elsif ( $comefrom =~ /tahoe/ ) {
        print '
            <a href="/cgi-bin/fswepp/tahoe/">
            <img src="/fswepp/images/tahoe.jpg"
            alt="Return to Tahoe Basin Erosion Model" border=2
            align=left width=50 height=50
            onMouseOver="window.status=\'Return to Tahoe Basin input screen\'; return true"
            onMouseOut="window.status=\' \'; return true">
            ';
    }
    else {
        print '
            <a href="/fswepp/">
            <img src="/fswepp/images/disturb.gif"
            alt="Return to Disturbed WEPP" border=2
            align=left width=50 height=50
            onMouseOver="window.status=\'Return to Disturbed WEPP input screen\'; return true"
            onMouseOut="window.status=\' \'; return true">
            ';
    }
    print '
     <A HREF="/fswepp/docs/rcwrimg.html">
     <IMG src="/fswepp/images/ipage.gif"
     align="right" alt="Read the documentation" border=0
     onMouseOver="window.status=\'Read the documentation\'; return true"
     onMouseOut="window.status=\' \'; return true"></a>
     ';
}
print '<CENTER>
  <H2>Rock:Clime<br>Rocky Mountain Research Station<br>Climate Generator</H2>
  <hr>
  <p>
  ';
print "Return climate file to $goback\n" if ( $goback ne '' );

$glo = $custCli . '*.par';
if ($debug) { print "User_ID: $user_ID<p>$glo"; }

if ( $action ne '-download' ) {

    print '
    <table cellpadding=6 border=2>
     <tr>
      <th valign=top>
';
    print "  <h3>Manage personal climates</h3><p>\n";
    if ( $num_cli == 0 ) { print "No personal climates exist<p><hr>\n" }
    else {
        print qq(
      <form method="post" action="../rc/manageclimates.pl">
      <SELECT NAME="Climate" SIZE="', $num_cli, '">
      );
        foreach my $ii ( 0 .. $#climates ) {
            print '<option value="', $climates[$ii]->{'clim_file'}, '"';
            print ' selected' if $ii == 0;
            print '> ', $climates[$ii]->{'clim_name'}, "\n";
        }
        print '      </select>
      <p>
      <input type="hidden" name="units" value="',    $units,    '">
      <input type="hidden" name="comefrom" value="', $comefrom, '">
      <input type="submit" name="manage" value="Describe">
      <input type="submit" name="manage" value="Remove">
      <input type="submit" name="manage" value="Modify / Share">
      </form>
     </th>
';
    }
    print '      <th valign=top>
   <h3>To add a climate station,<br>';
}
else {
    print '      <th valign=top>
   <h3>To generate and download<br>to your computer<br>a CLIGEN-format climate file<br>for use in WEPP,<br>';
}
print '
    select a region below</h3>
     <form ACTION="/cgi-bin/fswepp/rc/showclimates.pl" method="post">
';

print '
   <select name="state" size=15>';
if ( $action ne "-server" ) {
    print '   <option value="personal">Personal</option>';
}
print <<'theEnd';
  <option value="al" selected>Alabama</option>
  <option value="ak">Alaska</option>
  <option value="az">Arizona</option> 
  <option value="ar">Arkansas</option> 
  <option value="ca">California</option>
  <option value="co">Colorado</option>
  <option value="ct">Connecticut</option> 
  <option value="de">Delaware</option>
  <option value="fl">Florida</option>
  <option value="ga">Georgia</option>
  <option value="hi">Hawaii</option>
  <option value="id">Idaho</option>
  <option value="il">Illinois</option>
  <option value="in">Indiana</option>
  <option value="ia">Iowa</option>
  <option value="ks">Kansas</option>
  <option value="ky">Kentucky</option>
  <option value="la">Louisiana</option>
  <option value="me">Maine</option>
  <option value="md">Maryland</option>
  <option value="ma">Massachusetts</option>
  <option value="mi">Michigan</option>
  <option value="mn">Minnesota</option>
  <option value="ms">Mississippi</option>  
  <option value="mo">Missouri</option>
  <option value="mt">Montana</option>
  <option value="ne">Nebraska</option>
  <option value="nv">Nevada</option>
  <option value="nh">New Hampshire</option>
  <option value="nj">New Jersey</option>
  <option value="nm">New Mexico</option>
  <option value="ny">New York</option>
  <option value="nc">North Carolina</option>
  <option value="nd">North Dakota</option>
  <option value="oh">Ohio</option>
  <option value="ok">Oklahoma</option>
  <option value="or">Oregon</option>
  <option value="pa">Pennsylvania</option>
  <option value="pr">Puerto Rico</option>
  <option value="ri">Rhode Island</option>
  <option value="sc">South Carolina</option>
  <option value="sd">South Dakota</option>
  <option value="tn">Tennessee</option>
  <option value="tx">Texas</option>
  <option value="ut">Utah</option>
  <option value="vt">Vermont</option>
  <option value="vi">Virgin Islands</option>
  <option value="va">Virginia</option>
  <option value="wa">Washington</option>
  <option value="dc">Washington, D.C.</option> 
  <option value="wv">West Virginia</option>
  <option value="wi">Wisconsin</option>
  <option value="wy">Wyoming</option>
  <option value=''>====</option>
  <option value="pi">Pacific Islands</option>
  <option value="tahoe">Tahoe Basin</option>
  <option value="nonus">International</option>
    </select>
<br><br>
    <input type="submit" value="Display Climate Stations"> 
theEnd
print '
      <input type="hidden" name="comefrom" value="', $comefrom, '">
      <input type="hidden" name="units" value="',    $units,    '">
      <input type="hidden" name="action" value="',   $action,   '">
     </form>
    </th>
   </tr>
  </table>
';

my $url;
if ( $comefrom =~ /road/ ) {
    $url = "/cgi-bin/fswepp/wr/";
}
elsif ( $comefrom =~ /wrbat/ ) {
    $url = "/cgi-bin/fswepp/wrbat/";
}
elsif ( $comefrom =~ /wd/ ) {
    $url = "/cgi-bin/fswepp/wd/";
}
elsif ( $comefrom =~ /ermit/ ) {
    $url = "/cgi-bin/fswepp/ermit/";
}
elsif ( $comefrom =~ /fume/ ) {
    $url = "/cgi-bin/fswepp/fume/";
}
elsif ( $comefrom =~ /tahoe/ ) {
    $url = "/cgi-bin/fswepp/tahoe/";
}

if ( $comefrom ne '' ) {
    print
qq (<button onclick="window.location.href='$url'">Return to input screen</button>);
}
else {
    print
qq (<button onclick="window.location.href='/fswepp/'">Return to FSWEPP</button>);
}

print '</CENTER>
 <P>
  <hr>
   <table width=100% border=0>
    <tr>
     <td>
      <font face="Arial, Geneva, Helvetica" size=-2>
       The Rocky Mountain Climate Generator creates a daily weather file using the ARS CLIGEN weather generator.
       The file is intended to be used with the WEPP Windows and GeoWEPP interfaces,
       but also can be a source of weather data for any application.
       It creates up to 200 years of simlated weather values from a database of more than 2600 weather stations and the
       PRISM 2.5-mile grid of precipitation data.
       <br><br>
       <b>Citation:</b><br>
       Elliot, William J.;
       Dayna L. Scheele, Dayna L.;
       Hall, David E. 1999.
       Rock:Clime &ndash; Rocky Mountain Research Station Climate Generator.
       Moscow, ID: U.S.D.A. Forest Service, Rocky Mountain Research Station, Moscow Forestry Sciences Laboratory.
       [Online at &lt;forest.moscowfsl.wsu.edu/fswepp&gt;].
       <br><br>
       <b>rockclim.pl</b> (a part of Rock:Clime) version ', $version, '<br>
       USDA Forest Service Rocky Mountain Research Station<br>
       1221 South Main Street, Moscow, ID 83843<br>
     </td>
   </tr>
  </table>
 </body>
</html>
';
