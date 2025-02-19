#!/usr/bin/perl
use warnings;
use CGI;
use CGI qw(:standard escapeHTML);

# 5/16/2000 DEH allow platform "linux" to pack like "pc"
# 4/10/2000 DEH added "Return to Input Screen" button;
#               removed unused javascript function "donothing"

#  perl script: xdrainm.pl [XDRAIN Multiple climate files]
#  usage:
#    <FORM method=post ACTION="https://host/cgi-bin/fswepp/xdrain/xdrainm.pl">
#  parameters:
#    Climate:		# get Climate (file name base)
#    SoilType:		# get SoilType (1..5)
#    BL:		# get BL (1..4)
#    BS:		# get BS (1..4)
#    Width:		# get width (unrestricted)
#    units:		# get units (ft|m)
#    raw:		# output spec: as from WEPP output, or kg/m l
#  reads environment variables:
#    HTTP_COOKIE
#    REMOTE_ADDR
#    REQUEST_METHOD
#    QUERY_STRING
#    CONTENT_LENGTH
#  reads: data/*.xdr

#  FSWEPP, USDA Forest Service, Rocky Mountain Research Station, Soil & Water Engineering
#  Science by Bill Elliot et alia                                      Code by David Hall
#  19 October 1999

$cgi   = CGI->new;
$cl    = $cgi->param('Climate');     # get Climate (file name base)
$st    = $cgi->param('SoilType');    # get SoilType (1..5)
$bl    = $cgi->param('BL');          # get BL (1..4)
$bs    = $cgi->param('BS');          # get BS (1..4)
$width = $cgi->param('Width');       # get width (unrestricted)
$units = $cgi->param('units');       # get units (ft|m)
$raw   = $cgi->param('raw');         # <1: std XDRAIN; >0: WEPP answers

$cl = escapeHTML($cl);
$st = escapeHTML($st);
$bl = escapeHTML($bl);
$bs = escapeHTML($bs);

if ( $bs !~ /^\d+$/ || $bs < 0 || $bs > 30 ) {
    $bs = 1;
}

$width = escapeHTML($width);
$units = escapeHTML($units);
$raw   = escapeHTML($raw);

print "Content-type: text/html\n\n";
print '<HTML>
 <HEAD>
  <TITLE>X-DRAIN Results</TITLE>
 </HEAD>
 <BODY  link="1603F3" vlink="160A8C">
  <blockquote>
   <CENTER>
    <font face="Arial, Geneva, Helvetica">
     <table width="90%">
      <tr>
       <td>
        <a href="./xdrain.pl">
         <IMG src="/fswepp/images/e-drain.gif" align="left" border=1
         width=50 height=50 alt="Return to X-DRAIN input screen"
         onMouseOver="window.status=', "'Return to X-DRAIN input screen'",
  '; return true"
         onMouseOut="window.status=', "' '", '; return true">
       </a>
      </td>
      <td align=center>
       <img src="/fswepp/images/line.gif" alt="= birds on a wire =">
       <H3>X-Drain Results</H3>
       <img src="/fswepp/images/line.gif" alt="= birds on a wire =">
      </td>
      <td>
       <A HREF="/fswepp/docs/xdrainimg.html#xdout">
        <IMG src="/fswepp/images/ipage.gif"
        align="right" alt="Read the documentation" border=0
        onMouseOver="window.status=', "'Read the documentation'",
  '; return true"
        onMouseOut="window.status=', "' '", '; return true"></a>
      </td>
     </tr>
    </table>
';

# error checking on input values (particularly width)

$climatefile = 'data/' . $cl . '.xdr';
if ( !-e $climatefile ) {
    print "<font color=red>Invalid climate selection </font><BR>";
    $cl = 1;
}
else {
    &GetClimateHeaderInfo;

    #     &checkforEOF;
}
if ( $st < 1 || $st > 5 ) {
    print "<font color=red>Invalid soil type selection </font><BR>";
    $st = 1;
}
if ( $bl < 0 || $bl > 4 ) {
    print "<font color=red>Invalid buffer length selection </font><BR>";
    $bl = 1;
}
if ( $bs < 1 || $bs > 4 ) {
    print "<font color=red>Invalid buffer steepness selection </font><BR>";
    $bs = 1;
}
if ( $units ne "m" && $units ne "ft" ) {    # need HTML error report & log
    print "<font color=red>Invalid units </font><BR>";
    $units = "m";
}
$width = $width * 1;    # iron out some non-valid entries (i.e., 4.2.3.6)
if ( $units eq "m" and ( $width < 1 || $width > 30 ) ) {
    print "<font color=red>Road width limited to between 1 and 30 m</font><BR>";
    $width = 4;
}
elsif ( $units eq "ft" and ( $width <= 3 || $width > 100 ) ) {
    print
      "<font color=red>Road width limited to between 3 and 100 ft</font><BR>";
    $width = 13;
}

#    print "</CENTER>\n";

#        print qq(<FONT size="4">\n);
#        print "Something has gone wrong.  One or more of your inputs is out of\n";
#        print "range (most likely the road width, unless something has really\n";
#        print "gone haywire).<P>\n";
#        print "Use your browser's BACK button to return to the Cross-Drain\n";
#        print "Spacing input screen\n";
#        print "</FONT><HR>\n";
#    }
#
#    else {

# decode SoilType, BS, BL (using units for BL)
# for reporting in results page

@rstext = ( "0", "2 %", "4 %", "8 %", "16 %" );
@sttext = (
    " ",
    "graveled loam",
    "clay loam",
    "graveled sand",
    "silt loam",
    "sandy loam"
);
@bstext  = ( "0 %", "4 %", "10 %", "25 %", "60 %" );
@bltextm = ( 0,     10,    50,     100,    200 );
@bltextf = ( 0,     33,    160,    330,    660 );
@rltextm = ( 0,     10,    30,     60,     120, 240 );
@rltextf = ( 0,     30,    100,    200,    400, 800 );

print "
      <TABLE cellpadding=4 border=0>
       <TR>
        <TD><font face='Arial, Geneva, Helvetica'><B>Climate station:</B></TD>
        <TD><font face='Arial, Geneva, Helvetica'>$stationnames, $region</TD>
        <TD><BR></TD>
        <TD><font face='Arial, Geneva, Helvetica'><B>Buffer length:</B></TD>
";
if ( $units eq "m" )  { print "       <TD>$bltextm[$bl] m</TD></TR>" }
if ( $units eq "ft" ) { print "      <TD>$bltextf[$bl] ft</TD></TR>" }
print "
       <TR>
        <TD><B>Soil type:</B></TD>
        <TD>$sttext[$st]</TD>
        <TD><BR></TD>
        <TD><B>Buffer gradient:</B></TD>
        <TD>";
if   ( $bl == 0 ) { print 'n/a' }
else              { print $bstext[$bs] }
print "</TD>
       </TR>
       <TR>
        <TD></TD>
        <TD></TD>
        <TD></TD>
        <TD><B>Road width:</B></TD>
        <TD>$width $units</TD>
       </TR>
      </TABLE>

      <H3><B>Average annual sediment yield ";

if ( $raw < 1 ) {
    if ( $units eq "m" )  { print "(kg/m length)</B></H3>\n" }
    if ( $units eq "ft" ) { print "(lb/ft length)</B></H3>\n" }
}
if ( $raw > 0 ) {
    if ( $units eq "m" )  { print "(kg)</B></H3>\n" }
    if ( $units eq "ft" ) { print "(lb)</B></H3>\n" }
}
print '   <TABLE border="1" cellpadding="6">', "\n";

print
'  <TR align=center><TH rowspan="2" bgcolor=85D2D2><B>Road <BR>Gradient</B></TH>
               <TH colspan="5" bgcolor=85D2D2><font face="Arial, Geneva, Helvetica"><B>Cross drain spacing</B></font></TH></TR>
               <TR align=right>
';
if ( $units eq "m" ) {
    print "    <TD bgcolor=85D2D2><B>$rltextm[1] m</B></TD>\n";
    print "    <TD bgcolor=85D2D2><B>$rltextm[2] m</B></TD>\n";
    print "    <TD bgcolor=85D2D2><B>$rltextm[3] m</B></TD>\n";
    print "    <TD bgcolor=85D2D2><B>$rltextm[4] m</B></TD>\n";
    print "    <TD bgcolor=85D2D2><B>$rltextm[5] m</B></TD></TR>\n";
    $cf = 1;
}
if ( $units eq "ft" ) {
    print "    <TD bgcolor=85D2D2><B>$rltextf[1] ft</B></TD>\n";
    print "    <TD bgcolor=85D2D2><B>$rltextf[2] ft</B></TD>\n";
    print "    <TD bgcolor=85D2D2><B>$rltextf[3] ft</B></TD>\n";
    print "    <TD bgcolor=85D2D2><B>$rltextf[4] ft</B></TD>\n";
    print "    <TD bgcolor=85D2D2><B>$rltextf[5] ft</B></TD></TR>\n";
    $cf = 0.672    # (lb/ft = kg/m * 2.20462 lb/kg * 1 m/3.28084 ft)
}
for ( $rs = 1 ; $rs < 5 ; $rs++ ) {
    print "<TR align=right><TD bgcolor=85D2D2><B>", $rstext[$rs], "</B></TD>\n";
    for ( $rl = 1 ; $rl < 6 ; $rl++ ) {
        $result = &GetRecord;
        if ( $result < 0 ) { print "<td><font color=blue>error at $o</font>" }
        else {
            $rll = $rltextm[$rl];
            if ( $units eq "ft" ) { $rll = $rltextf[$rl] }

            # multiply SedYield by width (and units conversion if necessary)
            #       $sy = int ($sediment * $width * $cf + 0.5);
            print "<TD>";    # print "<font color=blue>$o </font>";
            if ( $sediment > -1 ) {
                if ( $raw < 1 ) {
                    $sy = $sediment * $width * $cf / $rll;
                    if    ( $sy < 0.01 ) { $printform = "%d" }
                    elsif ( $sy < 0.09 ) { $printform = "%.2f" }
                    elsif ( $sy < 0.95 ) { $printform = "%.1f" }
                    else                 { $printform = "%.0f" }
                    printf $printform, $sy;
                }
                else {
                    $sy = $sediment * $width * $cf;

                    #              if ($sy < 0.01) {$printform = "%d"}
                    #              elsif ($sy < 0.09) {$printform = "%.2f"}
                    #              elsif ($sy < 0.95) {$printform = "%.1f"}
                    #              else {$printform = "%.0f"}
                    $printform = "%.2f";
                    printf $printform, $sy;
                }
            }
            else { print "<BR>"; }

            #           if ($sy > 99.99) {print qq(</font>);}
            print "</TD>\n";
        }    # if result < 0
    }    #   end for $rs
    print "</TR>\n";
}    # end for $rl

print '
  </TABLE></center>';

#  <P><HR>
#  <form><input type="button" value="Back" onClick="window.history.go(-1);"> </table>
#  </form><HR>
#  </CENTER>
#  ',"\n";

#  }    # end of else (good data)

#  print "X-DRAIN Database of $filedate based on WEPP v. 98.4 (USFS modified)<BR>\n";

print '
      <center>
       <br>';
print "$stationnamel, $region $country -- \n$filedate<br>\n$createdby<br>\n";
print '
     <br>
     <a href="JavaScript:window.history.go(-1)">
      <img src="/fswepp/images/rtis.gif"
      alt="Return to input screen" border="0" align=center></A>
    </center>
    <br>
    <hr>
    <table width=90% border=0>
     <tr>
      <td>
       <font size=-2>X-DRAIN 2.000<br>USDA Forest Service Rocky Mountain Research Station<br>
        <SCRIPT>
         <!-- hide
         document.write(document.lastModified)
         // end hide -->
        </SCRIPT>
       </font>
      </td>
    </tr>
   </table>
  </blockquote>
 </BODY>
</HTML>
';

# done

# -------------------- start of subroutines ----------------------------

sub GetClimateHeaderInfo {

    open DATAFILE, "<$climatefile";
    binmode(DATAFILE);
    $recsep     = <DATAFILE>;
    $recsep     = substr( $recsep, 0, 1 );
    $headersize = <DATAFILE>;
    $headersize = substr( $headersize, 1 ) + 0;

    #     print "header: $headersize\n";
    seek( DATAFILE, 0, 0 );
    read( DATAFILE, $buf, $headersize );
    close DATAFILE;

    (
        $dumb,             $recsep,           $numbytes,
        $country,          $region,           $stationnumb,
        $stationnames,     $stationnamel,     $stationlatitude,
        $stationlongitude, $stationelevation, $precip,
        $record,           $filedate,         $createdby
    ) = split $recsep, $buf;
    chomp $region;
    chomp $stationnamel;
    chomp $stationnames;

    $country      = substr( $country,      17 );
    $region       = substr( $region,       17 );
    $stationnames = substr( $stationnames, 17 );
    chop $stationnames;
    $stationnamel = substr( $stationnamel, 17 );
    chop $stationnamel;
    $stationnumb      = substr( $stationnumb,      17 );
    $stationlatitude  = substr( $stationlatitude,  17 );
    $stationlongitude = substr( $stationlongitude, 17 );
    $stationelevation = substr( $stationelevation, 17 );
    $filedate         = substr( $filedate,         17 );
    $createdby        = substr( $createdby,        17 );

    # print "region:		$region<br>
    # station name:	$stationnamel<br>
    # latitude:	$stationlatitude<br>
    # longitude:	$stationlongitude<br>
    # elevation:	$stationelevation<br>
    # file date:	$filedate<br>
    # created by:	$createdby<br>\n";

}

sub GetRecord {

    # in: $cl,$st,$bl,$bs,$rl,$rs
    # out: $climate,$soil,$buffl,$buffs,$roadl,$roads,$sediment,$zb

    if ( -e $climatefile ) {

        # if out of each of above <> in of above, report to error log
        # calculate byte pointer into database

        $bl += 0;
        $bs += 0;

        # handle zero bufer length request;
        #    read records for second buffer length and gradient

        $zbl = $bl;
        $zbs = $bs;
        if ( $bl == 0 ) { $zbl = 2; $zbs = 2 }

        $recl   = 18;
        $o      = 0;
        $o      = $o + ( $st - 1 ) * 320;  # 4 buff lengths * 4 bs * 5 rl * 4 rs
        $o      = $o + ( $zbl - 1 ) * 80;  # 4 buff grads * 5 rl * 4 rs
        $o      = $o + ( $zbs - 1 ) * 20;  # 5 road lengths * 4 rs
        $o      = $o + ( $rl - 1 ) * 4;    # 4 road gradients
        $o      = $o + ( $rs - 1 );
        $offset = $headersize + $o * $recl;

        #    print $offset,"\n";

        open( DATAFILE, "<$climatefile" );
        binmode(DATAFILE);
        seek( DATAFILE, $offset, 0 );
        read( DATAFILE, $buf, 2 );
        $soil = unpack( "v", $buf );
        read( DATAFILE, $buf, 2 );
        $buffl = unpack( "v", $buf );
        read( DATAFILE, $buf, 2 );
        $buffs = unpack( "v", $buf );
        read( DATAFILE, $buf, 2 );
        $roadl = unpack( "v", $buf );
        read( DATAFILE, $buf, 2 );
        $roads = unpack( "v", $buf );

        read( DATAFILE, $buf, 4 );
        $sediment = unpack( "f", $buf );
        read( DATAFILE, $buf, 4 );
        $zbsed = unpack( "f", $buf );
        close DATAFILE;

        if ( $bl == 0 ) { $sediment = $zbsed }

        if (   $soil eq $st
            && $buffl eq $zbl
            && $buffs eq $zbs
            && $roadl eq $rl
            && $roads eq $rs )
        {
            $result = 0;
        }
        else { $result = -9 }
    }
}
