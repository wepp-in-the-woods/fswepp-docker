#!/usr/bin/perl
use warnings;
use CGI qw(:standard escapeHTML);

print "Content-Type: text/html\n\n";    # Ensure headers are printed first

#
# searchpub.pl
#
# David Hall, USDA Forest Service Rocky Mountain Research Station
#
# 2009-08-18 DEH add 'code=200' parameter to showpubhits.pl call (show only 'Successful' downloads)
# 2009-08-17 DEH Change unvisited link color to green
# 2008-04-29 16:32
# 2008.04.16 DEH Add download count ($countem)
# 2006.08.28 DEH Implement $plinks: purchase links
# 2005.07.12 DEH Give target "_pub" to publication link
#		 Look for parameter "bare" to bypass header stuff
# 2005.07.11 DEH Library link '/library.html' to '/library/'
#                Photos link '/photos.html' to '/engr/photos.html'
#                '../images/logo.gif' to '/images/logo.gif'
# 2004.11.04 DEH remove confusing "epage_s" graphic;
#		 replace with '[Full text available]' or pdf_logo.gif and www.gif (from ACM website via UI library)
# 2004.06.17 DEH Adjust <title> for both types of reports to give
#	a) publication title (single publication request)
#	b) search criteria line (multiple publication return)
#	   (move &print_head to below where this info is known)
# 2004.02.11 DEH Return publication code $publ for single-page output
# to do:        line 102: print linked $author_goal if page available
# 07/10/2003 DEH don't print links if blank
#                don't print $authorblock
# 07/09/2003 DEH remove <a> </a> on titles in single-output
# 07/09/2003 DEH print keywords and links before abstract
# 06/11/2003 DEH customize time stamp "today" "yesterday" or "n days ago"
# 03/07/2003 DEH publish
# 02/19/2003 DEH fix welliot envelope link
#                remove 'revised' date
#                remove 'pub' code on multi output
#                don't print keywords if there are none (sort of) on multi
# 12/12/2002
# 06/21/2002 Summer Solstice DEH -- first coding
#
# read pubs-db and display matching records
# if specific publication listed, display extended entry
#
# usage: searchpub.pl (called from Web form)
#        searchpub?pub=2001x
#        searchpub.pl?author=Elliott&year=2001
#        searchpub.pl?category=fire%20effects
#
# controls:
#
#   author
#   year_goal
#   keyword_goal
#   pub
#   bare		# 2005.07.12 DEH
#   count
#
# get_entry provides:
#
#   $pub_code		'2001z'
#   $authors		'Elliot, Robichaud, Hall'
#   $year		'2001'
#   $title		'A probabilistic approach to modeling erosion for spatially-varied conditions'
#   $publisher		'ASAE'
#   $citationt
#   $abstract		'In the years following a major fire disturbance...'
#   $keyword		'Modeling, WEPP, Forest Fire, Erosion, Variability'
#   $authorblock	'<table width=80% align=center border=0>
#			 <tr><td align=center>...'
#   $links              '<a href="https://forest.moscowfsl.wsu.edu/engr/library/Elliot/2001z/">PDF</a> [2 MB]'
#   $plinks             '<a href="https://forest.moscowfsl.wsu.edu/engr/library/Elliot/2001z/">PDF</a> [2 MB]'x

# https://forest.moscowfsl.wsu.edu/cgi-bin/engr/library/searchpub.pl?year=<meta%20http-equiv=Set-Cookie%20content="testlfyg=5195">

my $cgi = CGI->new;

# Initialize parameters
my $category_goal = $cgi->param('category') || '';

# List of valid categories (including an empty string as valid)
my @valid_categories = qw(
  climate
  conference
  disturbed
  duff
  erosion
  factsheet_series
  fire
  gtr
  journal
  proceedings
  research
  road
  roads
  slope
  transactions
  upland
  watershed
  wildfire
  ''
);

if ( !grep { $_ eq $category_goal } @valid_categories ) {
    $category_goal = '';
}

my $author_goal = $cgi->param('author') || '';

$category_goal = escapeHTML($category_goal);
$author_goal   = escapeHTML($author_goal);

$library  = 'pubdb.txt';
$days_old = -M $library if -e $library;
$days_old = int( $days_old + 0.5 );

&ReadParse(*parameters);
$year_goal    = escapeHTML( $parameters{'year'} );
$keyword_goal = escapeHTML( $parameters{'keyword'} );
$pub_goal     = escapeHTML( $parameters{'pub'} );
$bare         = escapeHTML( $parameters{'bare'} );      # 2005.07.12 DEH
$countem      = escapeHTML( $parameters{'count'} )
  ;    # report number of downloads (many will be crawlers)

$skipcode = '*';    # column 1 code to ignore entry in database
$pubcode  = '#';    # column one code for new publication entry
$keycode  = '$';    # column one code for new keyword entry
$split    = '=';    # key/value split character

%counthash = {};
%titlehash = {};

# put these in a hash -- with full name or full name and link
if ( $author_goal eq 'Elliot' ) {
    $author_goal_link =
      '<a href="/people/engr/welliot.html" target="_">Bill Elliot</a>';
}
elsif ( $author_goal eq 'Robichaud' ) {
    $author_goal_link =
      '<a href="/people/engr/probichaud.html" target="_">Pete Robichaud</a>';
}
elsif ( $author_goal eq 'Foltz' ) {
    $author_goal_link =
      '<a href="/people/engr/rfoltz.html" target="_">Randy Foltz</a>';
}
elsif ( $author_goal eq 'Hall' ) {
    $author_goal_link =
      '<a href="/people/engr/dehall.html" target="_">David Hall</a>';
}
elsif ( $author_goal eq 'Lewis' ) {
    $author_goal_link =
      '<a href="/people/engr/sarahlewis.html" target="_">Sarah Lewis</a>';
}
elsif ( $author_goal eq 'Brown' ) {
    $author_goal_link =
      '<a href="/people/engr/bbrown.html" target="_">Bob Brown</a>';
}
elsif ( $author_goal eq 'Miller' ) {
    $author_goal_link =
      '<a href="/people/engr/suemiller.html" target="_">Sue Miller</a>';
}
elsif ( $author_goal eq 'Copeland' ) {
    $author_goal_link =
'<a href="/people/engr/ncopeland.html" target="_">Natalie Copeland Wagenbrenner</a>';
}
elsif ( $author_goal eq 'Burroughs' ) {
    $author_goal_link =
      '<a href="/people/engr/erburroughs.html" target="_">Ed Burroughs</a>';
}
else {
    $author_goal      = '';
    $author_goal_link = '';
}

#   &print_head ($title);
open DB, "<$library";

if ( $pub_goal ne '' ) {
    &get_entry;    # prime the system ...
    $publ = substr( $line, 1, 5 );

    #    print "$publication -- $publ\n";
    while (&get_entry)
    { # read until there ain't no more; return with $authors, $title, $citation, $keyword...

        #      print "$publication -- $publ\n";
        if ( $pub_goal eq $publ ) {    # what is it we wanted to do?
            &print_head($title);

            # strip <a> and </a> from $citationt into $citationt_strip
            $citationt_strip = $citationt;
            $loc_barea       = index( lc($citationt), '<a>' );
            $loc_closebarea  = index( lc($citationt), '</a>', $loc_barea );
            substr( $citationt_strip, $loc_closebarea, 4 ) = ''
              if ( $loc_closebarea > -1 );
            substr( $citationt_strip, $loc_barea, 3 ) = ''
              if ( $loc_barea > -1 );

            chomp $links;

# 2009         if ($links eq '') {$links='Electronic version not yet available; please check back.'}
            chomp $plinks;

            #
            print "        <p align=center><font size=+1>$title</font></p>
          <p align=left class=reference>
           $citationt_strip
          </p>
";

            chomp $keyword;
            if ( $keyword ne '' ) {
                print "
         <p>
          <b>Keywords:</b> $keyword
         </p> "
            }
            print "
         <p>
          <b>Links:</b>
";

         #          <b>Links:</b> <img src=\"/images/epage_s.gif\" border=\"0\">

            if ( $links =~ /.pdf/ ) {
                print '<img src="/images/pdf_logo.gif" border="0" alt="pdf">';
            }
            if ( $links =~ /.html/ ) {
                print '<img src="/images/www.gif" border="0" alt="html">';
            }

            print "
	   $links
           <br><br>
";
            if ( $plinks ne '' ) {
                print "           <b>Available to purchase:</b> $plinks\n";
            }
            print "
         </p>
	 <p>
	 <b>Abstract:</b>
	  $abstract
         </p>
         <p align='right'>Moscow FSL publication no. $publ
         </p>
	 ";
            last;
        }
        $publ = $publx;
    }

}
else {    # return multiple entries short-form

    $counter      = 0;
    $linkscounter = 0;

    $header = 'Selected Moscow FSL Engineering publications';
    $header .= " by $author_goal_link"   if ( $author_goal_link ne '' );
    $header .= " in $year_goal"          if ( $year_goal ne '' );
    $header .= "; keyword $keyword_goal" if ( $keyword_goal ne '' );
    $header .= " on $category_goal"      if ( $category_goal ne '' );
    if ($bare) {
        &print_head_bare();    # 2005.07.12 DEH
    }
    else {
        &print_head($header);    # 2005.07.12 DEH
    }
    print "<p><font size=+1><b>$header</b></font></p>\n";

    &get_entry;                  # prime the system ...
    $pub = substr( $line, 1, 5 );
    while (&get_entry)
    { # read until there ain't no more; return with $author, $title, $citation, $keyword...
        if (&match) {    # what is it we wanted to do?
            $counter += 1;
            if ( $citationt ne '' ) {
                &cite
                  ; # change citationt's "<a>" to "<a href="searchpub.pl?pub=yyyya">
                print '<p align="left" class="Reference">', "\n";
                print "$citationta\n";
                chomp $links;
                $linkscounter += 1 if ( $links ne '' );

                print
                  ' <font color="green">[Full&nbsp;text&nbsp;available]</font> '
                  if ( $links ne '' );

                chomp $keyword;
                if ( $keyword ne '' ) {
                    print "
           <br>
           <b>Keywords:</b> $keyword
";
                }

                if ($countem) {
                    @wcargs =
                        'fgrep '
                      . $pub
                      . '.pdf ~dhall/logs/logs/ac*.log | fgrep \' 200 \' | wc';
                    $wc = `@wcargs`;
                    @pubcount = split ' ', $wc;

                    #           <br>$pub @args @wc @pubcount[0]
                    $totaldown += @pubcount[0];
                    if ( @pubcount[0] > 0 ) {
                        $counthash{$pub} = @pubcount[0];
                        $titlehash{$pub} = $title;
                    }
                    if ( @pubcount[0] > 0 ) {
                        chomp $title;
                        use URI::Escape;
                        uri_escape($title);

                        print "
           <br><b><a href=\"https://forest.moscowfsl.wsu.edu/cgi-bin/engr/library/showpubhits.pl?pub=$pub&code=200&title=$title\" target=\"_hits\">Downloads</a>:</b> @pubcount[0]
";
                    }
                }
### $countem end ###
                print "          
           <p>
           ";
            }
        }
        $pub = $publx;
    }
    $publication_s = 'citations';
    $publication_s = 'citation' if ( $counter == 1 );

    #      <img src=\"/images/epage_s.gif\" border=0>
    print "<p align=center>$counter matching $publication_s found;
      $linkscounter with full text;

    if ($countem) {

        print "    $totaldown downloads</p>\n";
        while ( ( $key, $value ) = each(%counthash) ) {
            print $value. ", "
              . $key . ', "'
              . $titlehash{$key} . '"'
              . "<br>\n";
        }

    }

    if ( !$bare ) {    # 2005.07.12 DEH
        print '
  <center>
   <form action="https://forest.moscowfsl.wsu.edu/engr/library/">
    <input type="submit" value="New search">
   </form>
  </center>
';
    }                  # if (!$bare)	# 2005.07.12 DEH
}
close DB;
&print_tail;

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
    local ( $i, $loc, $key, $val );

    if ( $ENV{'REQUEST_METHOD'} eq "GET" ) {
        $in = $ENV{'QUERY_STRING'};
    }
    elsif ( $ENV{'REQUEST_METHOD'} eq "POST" ) {
        read( STDIN, $in, $ENV{'CONTENT_LENGTH'} );
    }

    @in = split( /&/, $in );

    foreach $i ( 0 .. $#in ) {

        # Convert pluses to spaces
        $in[$i] =~ s/\+/ /g;

        # Split into key and value
        ( $key, $val ) = split( /=/, $in[$i], 2 );    # splits on the first =

        # Convert %XX from hex numbers to alphanumeric
        $key =~ s/%(..)/pack("c",hex($1))/ge;
        $val =~ s/%(..)/pack("c",hex($1))/ge;

        # Associative key and value
        $in{$key} .= "\0"
          if ( defined( $in{$key} ) );    # \0 is the multiple separator
        $in{$key} .= $val;
    }
    return 1;
}

sub get_entry {
    $authors     = '';
    $year        = '';
    $title       = '';
    $publisher   = '';
    $category    = '';
    $abstract    = '';
    $keyword     = '';
    $authorblock = '';
    $links       = '';
    $citationt   = '';
    $plinks      = '';
    $treesearch  = '';

  more:
    if ( eof(DB) ) {
        return 0;    # FALSE
    }
    $line = <DB>;
    if ( eof(DB) ) {
        return 0;    # FALSE
    }
    $first = substr( $line, 0, 1 );
    if ( $first eq $pubcode ) {    # new entry
        $publx = substr( $line, 1, 5 );
        return $line;              # TRUE
    }
    if ( $first eq $skipcode ) {
      skip:
        if ( eof(DB) ) { return 0 }
        $line  = <DB>;
        $first = substr( $line, 0, 1 );
        goto skip if ( $first ne $pubcode );
        $publx = substr( $line, 1, 5 );
        return $line;              # TRUE
    }
    if ( $first eq $keycode ) {    # new keyword

        #       ($key,$value)=split $split, $line; # split key/value
        ( $key, $value ) = split $split, $line, 2;    # split key/value
        $key = lc($key);
        if ( $key eq '$authors' )     { $author      = $value }
        if ( $key eq '$year' )        { $year        = $value }
        if ( $key eq '$title' )       { $title       = $value }
        if ( $key eq '$publisher' )   { $publisher   = $value }
        if ( $key eq '$citationt' )   { $citationt   = $value }
        if ( $key eq '$abstract' )    { $abstract    = $value }
        if ( $key eq '$keywords' )    { $keyword     = $value }
        if ( $key eq '$category' )    { $category    = $value }
        if ( $key eq '$authorblock' ) { $authorblock = $value }
        if ( $key eq '$links' )       { $links       = $value }
        if ( $key eq '$plinks' )      { $plinks      = $value }
        if ( $key eq '$treesearch' ) { $treesearch = $value; chomp $treesearch }
    }
    else {    # assume continuation of previous keyword entry
        if ( $key eq '$authors' )     { $author      = $author . $line }
        if ( $key eq '$year' )        { $year        = $year . $line }
        if ( $key eq '$title' )       { $title       = $title . $line }
        if ( $key eq '$publisher' )   { $publisher   = $publisher . $line }
        if ( $key eq '$citationt' )   { $citationt   = $citationt . $line }
        if ( $key eq '$abstract' )    { $abstract    = $abstract . $line }
        if ( $key eq '$keywords' )    { $keyword     = $keyword . $line }
        if ( $key eq '$category' )    { $category    = $category . $line }
        if ( $key eq '$authorblock' ) { $authorblock = $authorblock . $line }
        if ( $key eq '$links' )       { $links       = $links . $line }
        if ( $key eq '$plinks' )      { $plinks      = $plinks . $line }
    }
    goto more;
}

sub match {

    #   $author_goal  *
    #   $year_goal    *
    #   $keyword_goal *
    #   $category_goal
    #   $pub_goal
    #   $free_text -- of title? other?

    return
         &null_match( $author, $author_goal )
      && &null_match( $keyword,  $keyword_goal )
      && &null_match( $category, $category_goal )
      && &null_match( $year,     $year_goal );
}

sub null_match {

  # pattern-match arg1 in arg0 case insensitive but return TRUE for null pattern

    my $string  = shift(@_);
    my $pattern = shift(@_);
    if ( $pattern eq '' ) { return 1 }
    return ( $string =~ /$pattern/i );

}

sub print_head_bare {

    print 'Content-type: text/html

<html>
 <head>
  <style type="text/css">
   <!--
    P.Reference {
        margin-top:0pt;
        margin-left:.3in;
        text-indent:-.3in;
    }
   -->
  </style>
  <link rel=stylesheet href="/css/rmrs.css" type="text/css">
 </head>
 <body link="green" bgcolor="#ffffff" onLoad="self.focus()">
  <font size=-1 face="tahoma, trebuchet, arial, sans serif">
';

}

sub print_head {

    my $title = shift;

    # strip_html;
    my $title_strip  = $title;
    my $loc_a_open   = index( lc($title), '<a' );
    my $loc_a_close  = index( lc($title), '>',    $loc_a_open );
    my $loc_a_close2 = index( lc($title), '</a>', $loc_a_close );
    my $diff         = $loc_a_close - $loc_a_open + 1;
    substr( $title_strip, $loc_a_close2, 4 ) = '' if ( $loc_a_close2 > -1 );
    substr( $title_strip, $loc_a_open, $diff ) = '' if ( $loc_a_open > -1 );
    $title = $title_strip;

    print '
<html>
 <head>
  <style type="text/css">
   <!--
    P.Reference {
        margin-top:0pt;
        margin-left:.3in;
        text-indent:-.3in;
    }
   -->
  </style>
';

    if ( $title ne '' ) { print "  <title>Moscow FSL - $title</title>" }
    else {
        print
"  <title>Moscow FSL - Engineering Publications search results</title>";
    }

    print <<'theEnd';
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <meta name="description" content="Soil and Water Engineering Publications - Complete list">
  <meta name="keywords" content="soil erosion water engineering publications library papers fire forest service Rocky Mountain research station Moscow Idaho">
  <link rel=stylesheet href="/css/rmrs.css" type="text/css">
 </head>

 <body link="green" bgcolor="#ffffff" onLoad="self.focus()">
  <base href="https://forest.moscowfsl.wsu.edu/engr/">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
   <tr>
    <td rowspan="3" bgcolor="#FFFFFF" valign="top" width="149"><img src="/images/logo.gif" alt="Rocky Mountain Research Station Logo" width="149" height="116"></td>
    <td width="100%" bgcolor="#CCCCFF" align="right" class="dk10pt"> USDA Forest Service<br>
      Rocky Mountain Research Station<br />
      Forestry Sciences Laboratory - Moscow, Idaho</td>
    <td bgcolor="#CCCCFF" width="11"><img src="/images/spacer.gif" width="11" height="72"></td>
   </tr>
   <tr> 
    <td width="100%" bgcolor="#669966" align="right" class="m1">
     <a href="/people/" class="m1">Moscow Personnel</a>&nbsp;
      |&nbsp; <a href="/siteindex.html" class="m1">Site Index</a>&nbsp;
      |&nbsp; <a href="/sitemap.html" class="m1">Site Map</a>&nbsp; 
      |&nbsp; <a href="https://forest.moscowfsl.wsu.edu/" class="m1">Moscow Home</a></td>
    <td bgcolor="#669966" width="11"><img src="/images/spacer.gif" width="11" height="20"></td>
  </tr>
  <tr> 
    <td width="100%" bgcolor="#000033" align="right" class="m2">
     <a href="/engr/info.html" class="m2">Project Information</a>&nbsp;
      |&nbsp; <a href="/software.html" class="m2">Modeling Software</a>&nbsp;
      |&nbsp; <a href="/library/" class="m2">Library</a>&nbsp; 
      |&nbsp; <a href="/engr/photos.html" class="m2">Project Photos</a>&nbsp;
      |&nbsp; <a href="/engr/links.html" class="m2">Offsite Links</a>&nbsp;
      |&nbsp; <a href="/engr/" class="m2">Eng. Home</a></td>
    <td bgcolor="#000033" width="11"><img src="/images/spacer.gif" width="11" height="24"></td>
   </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
   <tr> 
    <td width="8" rowspan="2" bgcolor="#FFFFFF"><img src="/images/spacer.gif" width="8" height="375"></td>
    <td width="15%" rowspan="2" bgcolor="#FFFFFF" valign="top">
     <span class="dk10pt"><br>
      <b>Soil &amp; Water<br>
      Engineering Publications</b><br><br>
     </span>
    </TD>
    <TD width="85%" height="375" bgcolor="#FFFFFF" valign="top"> 
     <TABLE width="100%" border="0" cellpadding="0" cellspacing="0">
      <TR>
       <TD colspan="5"><IMG src="/images/spacer.gif" width="1" height="40"></TD>
      </TR>
      <TR> 
       <td width="20" bgcolor="#FFFFFF"><img src="/images/spacer.gif" width="20"></TD>
       <td width="6" bgcolor="#CCCCFF"><img src="/images/spacer.gif" width="6"></TD>
       <td width="20" bgcolor="#FFFFFF"><img src="/images/spacer.gif" width="20"></TD>
       <td width="100%" bgcolor="#FFFFFF">
theEnd

}

sub cite {

    # 2005.07.12 DEH add target to href
    #  find "<a>" in $citation and turn it into
    #  <a href="$citationserver$citationpath?pub=$pub" target="index">"
    # in $citationta

    $citationserver = 'https://forest.moscowfsl.wsu.edu';
    $citationpath   = '/cgi-bin/engr/library/searchpub.pl';
    $anchor         = index( $citationt, '<a>' );
    if ( $anchor < 0 ) {
        $citationta = $citationt;
    }
    else {
        $substitution =
            '<a href="'
          . $citationserver
          . $citationpath
          . "?pub=$pub"
          . '" target="_pub">';

        #     $substitution = '<a href="' .
        #                      $citationserver . $citationpath .
        #                     "?pub=$pub" . '" target="index">';
        $citationta =
            substr( $citationt, 0, $anchor )
          . $substitution
          . substr( $citationt, $anchor + 3 );
    }
}

sub print_tail {

    print "
     </table>
    </td>
   </tr>
  </table>
 </body>
</html>
";
}

