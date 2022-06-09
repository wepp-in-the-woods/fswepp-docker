#! /usr/bin/perl

# DEH May 8, 2001 -- Add plea for mailing address, and pass $title
#		-- Add referer field to report refering web page
#		-- Change "Submit comments" to "Mail comments"
# DEH Jan 5, 2001 -- SGW text slipped in (simpler)
# DEH December 12, 2000 -- remove left-hand column & add retreat button
# DEH December 04, 2000 -- conform to new forest style
# DEH April 10, 2000  -- fs.fed.us address
# DEH 04/10/2000 -- limit textarea size (test)

#====================== commform.pl ======================

   &ReadParse(*parameters);
   $recipient=$parameters{'recipient'};
   $title=$parameters{'title'};
   $source=$parameters{'source'};

    $referer = $ENV{'HTTP_REFERER'};  # if (defined($ENV{})) {}

  print "Content-type: text/html\n\n";

print '
<html>
<head>
<title>USFS Rocky Mountain Research Station Moscow - Comment to ',$title,'</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel=stylesheet href="/css/rmrs.css" type="text/css">
</head>

<body bgcolor="#CCCCFF">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr> 
    <td rowspan="3" bgcolor="#FFFFFF" valign="top" width="149">
    <img src="/images/logo.gif" alt="Rocky Mountain Research Station Logo" width="149" height="116"></td>
    <td width="100%" bgcolor="#CCCCFF" align="right" class="dk10pt">USDA Forest Service<br />
      Rocky Mountain Research Station<br />
      Forestry Sciences Laboratory - Moscow, Idaho</td>
    <td bgcolor="#CCCCFF" width="11"><img src="/images/spacer.gif" width="11" height="72"></td>
  </tr>
  <tr> 
    <td width="100%" bgcolor="#669966" align="right" class="w11px"> 
      <a href="http://forest.moscowfsl.wsu.edu/contacts.html" class="m1">Moscow Personnel</a>&nbsp;
       |&nbsp; <a href="http://forest.moscowfsl.wsu.edu/siteindex.html" class="m1">Site Index</a>&nbsp;
       |&nbsp; <a href="http://forest.moscowfsl.wsu.edu/sitemap.html" class="m1">Site Map</a>&nbsp; 
       |&nbsp; <a href="http://forest.moscowfsl.wsu.edu/" class="m1">Moscow Home</a></td>
    <td bgcolor="#669966" width="11"><img src="/images/spacer.gif" width="11" height="20"></td>
  </tr>
  <tr> 
    <td width="100%" bgcolor="#000033" align="right">
     <span class="lt9pt">
     <a href="http://forest.moscowfsl.wsu.edu/4552/" class="m2">Root Diseases &amp; Soil Biol.</a>&nbsp;
      |&nbsp; <a href="http://forest.moscowfsl.wsu.edu/engr/" class="m2">Soil &amp; Water Eng.</a>&nbsp;
      |&nbsp; <a href="http://forest.moscowfsl.wsu.edu/4155/" class="m2">Forest Ecosystem Proc.</a>&nbsp;
      |&nbsp; <a href="http://forest.moscowfsl.wsu.edu/rss/" class="m2">Research Supp. Svcs.</a>
     </span>
    </td>
    <td bgcolor="#000033" width="11"><img src="/images/spacer.gif" width="11" height="24"></td>
  </tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
   <TR>
     <TD colspan="3"><IMG src="/images/spacer.gif" width="30" height="20"></TD>
   </TR>
   <TR> 
     <TD width="149"><IMG src="/images/spacer.gif" width="149" height="30"></TD>
     <TD width="100%"><SPAN class="h1r">Questions or comments 
            for ',$title,'?</SPAN><BR />
       <br>
       <B class="h2bk">Please fill in the following information:</B>
       <FORM method="post" action="/cgi-bin/fswepp/comment2.pl">
         <input type="hidden" name="title" value="',$title,'">
         <input type="hidden" name="referer" value="',$referer,'">
         <input type="hidden" name="recipient" value="',$recipient,'">
         <SPAN class="dk10pt"> Your name:<br>
           <INPUT type="text" name="uname" size="40" maxlength="80">
         </SPAN>
         <BR />
         <SPAN class="dk10pt">Your e-mail address:<br>
           <INPUT type="text" name="source" size="40" maxlength="80">
         </SPAN>
         <BR />
         <SPAN class="dk10pt">Comments: (limit 900 characters)</SPAN><BR /> 
         <TEXTAREA name="comment" cols="60" rows="16"></TEXTAREA>
         <BR />
         <BR />
         <INPUT type="reset" name="Reset" value="Reset form">&nbsp;
         <INPUT type="submit" name="Submit" value="Mail comments">&nbsp;
         <INPUT type="button" name="Cancel" value="Cancel" onClick="history.back()">
         <BR />
         <BR />
       </FORM>
     </TD>
     <TD width="20" bgcolor="#FFFFFF"><IMG src="/images/spacer.gif" width="20" height="1"></TD>
   </TR>
 </TABLE>

</BODY>
</HTML>
';

# ----- subroutines -----

sub pagehead {
  print "Content-type: text/html\n\n",
        "<HTML>\n<HEAD>\n",
        "<TITLE>$title</TITLE>\n",
        "</HEAD><BODY bgcolor=ivory>\n";
}

sub pagetail {
  print "<HR>\n",
        "</BODY>\n</HTML>\n";
}


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

#   read text
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

