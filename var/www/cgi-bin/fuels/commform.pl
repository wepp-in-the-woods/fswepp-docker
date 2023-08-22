#! /usr/bin/perl

# 2004.12.10 DEH
# modifed from /cgi-bin/fswepp/commform.pl
#   5780 May 19  2003 ../fswepp/commform.pl
# DEH May 8, 2001 -- Add plea for mailing address, and pass $title

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
  <title>USFS Fuels Synthesis comment for ',$title,'</title>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
 </head>

 <body bgcolor="#CCCCFF">
  <font face="trebuchet, tahoma, arial">
   <img src="/fuels/images/fire2.jpg" align="left" alt="enviromental effects" border="0">
   <center>
    <FONT SIZE="5" COLOR="black">Applied Wildland Fire Research in Support of Project 
     Level Hazardous Fuels Planning<br>
     == Environmental Consequences ==
    </font>
   </center>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
   <tr>
    <td colspan="3"><IMG src="/images/spacer.gif" width="30" height="20"></TD>
   </tr>
   <tr> 
    <td width="149"><IMG src="/images/spacer.gif" width="149" height="30"></TD>
    <td width="100%"><SPAN class="h1r">Questions or comments for ',$title,' team?</SPAN><br>
       <br>
       <B>Please fill in the following information:</B>
       <FORM method="post" action="/cgi-bin/fuels/comment2.pl">
         <input type="hidden" name="title" value="',$title,'">
         <input type="hidden" name="referer" value="',$referer,'">
         <input type="hidden" name="recipient" value="',$recipient,'">
         Your name:<br>
           <INPUT type="text" name="uname" size="40" maxlength="80">
         <BR>
         Your e-mail address:<br>
           <INPUT type="text" name="source" size="40" maxlength="80">
         <BR>
         Comments: (limit 900 characters)<BR> 
         <TEXTAREA name="comment" cols="60" rows="16"></TEXTAREA>
         <BR>
         <BR>
         <INPUT type="reset" name="Reset" value="Reset form">&nbsp;
         <INPUT type="submit" name="Submit" value="Mail comments">&nbsp;
         <INPUT type="button" name="Cancel" value="Cancel" onClick="history.back()">
         <BR>
         <BR>
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

