#! /usr/bin/perl

#  XDRAIN -- Cross Drain Sedimentation program [1999]
#
#  perl script: xdrain.pl [XDRAIN Multiple climate files]
#  usage: xdrain.pl (called from Web form)
#    units:		# get unit (ft|m)
#  reads environment variables:
#       HTTP_COOKIE
#       REMOTE_ADDR
#       REQUEST_METHOD
#       QUERY_STRING
#       CONTENT_LENGTH
#  reads: data/*.xdr
#        ../wepphost	# localhost or other
#
#  2005.08.15 DEH changed <p> to <br>; change to Tahoma font, put font in table cells, clean up table coding
#  modified 05/05/2000 DEH: work around machines with glob problems
#  modified 08/03/1999 DEH: from xds_973.pl (add ZBL, etc.)
#  modified 06/07/1999 DEH: Fixed buffer (26' -> 260') and (650' -> 660') 
#  modified 03/20/1998 DEH: English units; back button; version #; cite URL

#  FSWEPP, USDA Forest Service, Rocky Mountain Research Station, Soil & Water Engineering
#  Science by Bill Elliot et alia                                      Code by David Hall
#  19 October 1999

    $version='2005.11.14';

    &ReadParse(*parameters);

    $units=$parameters{'units'};
    chomp $units;
    $u="m"; $un="m"; $unit="meters"; $rw = 4;
    if (lc($units) =~ /f/) {$u="f";$un="ft";$unit="feet";$rw=12}

    $wepphost="localhost";
    if (-e "../wepphost") {
      open Host, "<../wepphost";
      $wepphost = <Host>;
      chomp $wepphost;
      close Host;
    }

print "Content-type: text/html\n\n";
print '
<HTML>
 <HEAD>
  <TITLE>X-DRAIN Cross-Drain Spacing -- Sediment Yield Program</TITLE>
  <META http-equiv="Content-Type" content="text/html; charset=utf-8">
  <META NAME="Name" CONTENT="Cross Drain (a.k.a. XDRAIN)">
  <META NAME="Brief Description" CONTENT="Cross Drain, a component of FS WEPP, predicts sediment yield from a road segment across a buffer.">
  <META NAME="Status" CONTENT="Version 2.000 released 1999">
  <META NAME="Updates" CONTENT="None anticipated">
  <META NAME="Inputs" CONTENT="Climate station; soil texture; buffer gradient and length; road width">
  <META NAME="Outputs" CONTENT="Table of average annual sediment yield for five cross drain spacings vs. four road gradients">
  <META NAME="Suggested user" CONTENT="">
  <META NAME="Suggested use" CONTENT="Cross Drain can be used to determine optimum cross drain spacing for existing or planned roads, and for developing and supporting recommendations concerning road construction, reconstruction, realignment, closure, obliteration, or mitigation efforts based on sediment yield.">
  <META NAME="Keywords" CONTENT="">
  <META NAME="Contributors" CONTENT="USDA Forest Service, Rocky Mountain Research Station, Moscow, ID">
  <META NAME="Source" content="Run online at http://forest.moscowfsl.wsu.edu/fswepp/">
 </HEAD>
 <body bgcolor="white" link="#1603F3" vlink="#160A8C">
  <font face="Tahoma, Arial, Geneva, Helvetica">
   <table width="100%">
    <tr>
     <td>
       <a href="http://',$wepphost,'/fswepp/">
       <IMG src="http://',$wepphost,'/fswepp/images/fsweppic2.jpg" height=75 width=75 border=0
       align="left" alt="Return to FS WEPP menu"></a>
     </td>
     <td align=center>
       <img src="http://',$wepphost,'/fswepp/images/line.gif" alt="= birds on a wire =">
       <H3>X-Drain<br>Cross-Drain Spacing -- Sediment Yield Program</H3>
       <img src="http://',$wepphost,'/fswepp/images/line.gif" alt="= birds on a wire =">
     </td>
     <td>
       <A HREF="http://',$wepphost,'/fswepp/docs/xdrainimg.html" target="_documentation">
       <IMG src="http://',$wepphost,'/fswepp/images/ipage.gif" border=0
        align="right" alt="Read the documentation"></a>
     </td>
    </tr>
   </table>
   <center>
    <br><br>
    <FORM method=post ACTION="http://',$wepphost,'/cgi-bin/fswepp/xdrain/xdrainm.pl">
     <TABLE border=2>
      <TR align="top">
       <TD align="center" bgcolor="85D2D2">
        <B>
         <a href="http://',$wepphost,'/fswepp/xdrain/climates.html"
          onMouseOver="status=\'Click to display climate details\'; return true;"
          onMouseOut="status=\'\'; return true;">Climate Station</A>
        </B>
       </TD>
       <TD align="center" bgcolor="85D2D2">
        <B>
         <a href="http://',$wepphost,'/fswepp/xdrain/soils.html"
          onMouseOver="status=\'Click to display soil texture details\'; return true;"
          onMouseOut="status=\'\'; return true;">Soil Texture</A>
        </B>
       </TD>
       <TD align="center" bgcolor="85D2D2">
        <B>Buffer<BR>
        Gradient<BR>
        (%)</B>
       </TD>
       <TD align="center" bgcolor="85D2D2">
        <B>Buffer<BR>
        Length<BR>
       (',$un,')<BR></B>
       </TD>
      </TR>
      <TR>
       <TD>
       <select name="Climate" size="5">',"\n"; 

    opendir DATADIR, 'data';			# DEH 05/05/2000
     @allfiles=readdir DATADIR;			# DEH 05/05/2000
    close DATADIR;				# DEH 05/05/2000
    @allfiles=sort @allfiles;			# 2005.11.14 DEH

#   while (<./data/*.xdr>) {			# DEH 05/05/2000
#     $f = $_;					# DEH 05/05/2000

    for $f (@allfiles) {			# DEH 05/05/2000
      if (substr($f,-4) eq '.xdr') {		# DEH 05/05/2000
        $f='data/' . $f;			# DEH 05/05/2000
        open(DATAFILE,$f) || goto oops;
          binmode(DATAFILE);			# DEH 05/05/2000

  	  $recsep = <DATAFILE>;
	  $recsep = substr($recsep,0,1);
	  $headersize=<DATAFILE>;
	  $headersize=substr($headersize,1)+0;

	  read (DATAFILE, $buf, $headersize);
	close DATAFILE;

        ($numbytes, $country, $region, $stationid, $stationnames, $other) = split $recsep, $buf;
        chomp $numbytes; chomp $region; chomp $region; chomp $stationid; chomp $stationnames; 

	$region=substr($region,17); 
        chop $region;				# DEH 05/05/2000
	$stationnames=substr($stationnames,17);
        chop $stationnames;			# DEH 05/05/2000
	$stationid=substr($stationid,17);
        $f = substr($f,5);         		# strip './data/'
        $f = substr($f,0,-4);			# strip '.xdr'
        print '        <option value="',$f,'"';	# 2005.11.14 DEH
        if ($num_cli == 0) {print ' SELECTED'}
        print '>', $region, ',  ',"$stationnames\n";
        $num_cli += 1;
oops:
      }						# DEH 05/05/2000
    }
    $num_cli -= 1;

print <<'theEnd';
        </SELECT>
       </TD>
       <TD>
        <SELECT NAME="SoilType" SIZE="5">
         <OPTION VALUE="2" SELECTED>Clay loam
         <OPTION VALUE="4">Silt loam
         <OPTION VALUE="5">Sandy loam
         <OPTION VALUE="1">Graveled loam
         <OPTION VALUE="3">Graveled sand
        </SELECT>
       </TD>
       <TD align=center>
        <SELECT NAME="BS" SIZE="5">
         <OPTION VALUE="1" SELECTED>4
         <OPTION VALUE="2">10
         <OPTION VALUE="3">25
         <OPTION VALUE="4">60
        </SELECT>
       </TD>
       <TD align=center>
theEnd
    if ($u eq "m") {print '
       <SELECT NAME="BL" SIZE="5">
         <OPTION VALUE="0">0
         <OPTION VALUE="1" SELECTED>10
         <OPTION VALUE="2">50
         <OPTION VALUE="3">100
         <OPTION VALUE="4">200
        </SELECT>
       </td>
      </tr>
     </table>
    <br>
'
}
else {
print '
       <SELECT NAME="BL" SIZE="5">
        <OPTION VALUE="0">0
        <OPTION VALUE="1" SELECTED>33
        <OPTION VALUE="2">160
        <OPTION VALUE="3">330
        <OPTION VALUE="4">660
       </SELECT>
      </td>
     </tr>
    </table>
    <br>
'
}
  print '<a href="http://',$wepphost,'/fswepp/xdrain/width.html"',"\n";
  print <<'theEnd';
   onMouseOver="status='Click to display road width details'; return true;"
   onMouseOut="status=''; return true;">Road width</A>
theEnd
print '
    <INPUT NAME="Width" TYPE="TEXT" SIZE=3 VALUE="',$rw,'"> ',$unit,'<br>
    <INPUT TYPE="HIDDEN" NAME="units" VALUE="',$un,'"><br>
    <input type="hidden" name="raw" value="1">
    <br>
    <INPUT TYPE="SUBMIT" VALUE="Run">
   </FORM>
';
print '
   <br>
   <br>
   </center>
   <hr>
   <table width=100%>
    <tr>
     <td>
      <font face="Tahoma, Arial, Geneva, Helvetica" size=-1>
       X-DRAIN 2.000<br>
       USDA Forest Service Rocky Mountain Research Station<br>
       Forestry Sciences Laboratory, Moscow, Idaho<br>
';
print
"       Release $version";
print '
      </font>
     </td>
     <td>
     <a href="http://',$wepphost,'/fswepp/comments.html" ';
 if ($wepphost eq 'localhost') {print 'onClick="return confirm(\'You must be connected to the Internet to e-mail comments. Shall I try?\')"'};
print '>
      <img src="http://',$wepphost,'/fswepp/images/epaemail.gif" align="right" border=0></a>
     </td>
    </tr>
   </table>
  </FONT>
 </BODY>
</HTML>
';

# ------------------------------- subroutines -----------------------------------------

sub ReadParse {

# ReadParse -- from cgi-lib.pl (Steve Brenner) from Eric Herrmann's
# "Teach Yourself CGI Programming With PERL in a Week" p. 131

# Reads GET or POST data, converts it to unescaped text, and puts
# one key=value in each member of the list "@in"
# Also creates key/value pairs in %in, using '\0' to separate multiple
# selections

# If a variable-glob parameter...

  local (*in) = @_ if @_;
  local ($i, $loc, $key, $val);

  if ($ENV{'REQUEST_METHOD'} eq "GET") {
    $in = $ENV{'QUERY_STRING'};
  } elsif ($ENV{'REQUEST_METHOD'} eq "POST") {
    read(STDIN,$in,$ENV{'CONTENT_LENGTH'});
  }

  @in = split(/&/,$in);

  foreach $i (0 .. $#in) {
    # Convert pluses to spaces
    $in[$i] =~ s/\+/ /g;

    # Split into key and value
    ($key, $val) = split(/=/,$in[$i],2);  # splits on the first =

    # Convert %XX from hex numbers to alphanumeric
    $key =~ s/%(..)/pack("c",hex($1))/ge;
    $val =~ s/%(..)/pack("c",hex($1))/ge;

    # Associative key and value
    $in{$key} .= "\0" if (defined($in{$key}));  # \0 is the multiple separator
    $in{$key} .= $val;
  }
  return 1;
 }
