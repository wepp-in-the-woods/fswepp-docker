#! /usr/bin/perl

# Known calls from: /fswepp/comments.html (as of 12/03/2003)
#                   /cgi-bin/fswepp/commform.pl?recipient=XX&title=ZZ

# DEH 2007.03.12 Tightened up restictions a bit: need '@' in source (user e-mail) (but allows '')
#                and must include 'forest.moscowfsl.wsu.edu' in referer
# DEH 2006.10.30 Also 'Tbnt' for $referer =~ 'document.referrer'
# DEH 2006.10.25 Also 'Tbnt' for $referer eq 'document.referer'
# DEH 2006.10.12 Also 'Tbnt' for $referer eq ''
# DEH 2006.10.11 Add 'Thanks but no thanks' rejection for $referer =~ 'commform.pl' - common from robots
#                Could also require a response address.
# DEH Dec 03, 2003 -- Modify generated HTML formatting
# DEH Feb 21, 2003 -- Slip in user "from" entry; switch "mail" to "sendmail"
# DEH Feb 20, 2003 -- remove validity check / user database; check for '@'
# DEH May 08, 2001 -- reformat message; include "to_title" field
#			add recognition of referer field
#	note -- should move list of users to a database file?
# DEH December 13, 2000 -- added "webmaster" with map to someone (me for now)
# DEH December 4, 2000 -- change format; add user-name recognition
# DEH April 10, 2000  -- fs.fed.us address
# DEH 04/10/2000 -- limit textarea size (test)

#====================== mailcomm.pl ======================
# Retrieves and parses form data, mails data, and displays
# response page.
# From Official HTML Publishing for Netscape, p. 417-418.

# called from: comment1.pl (i.e.) or commform.pl

  $userIP = $ENV{'REMOTE_HOST'};
  $userIP = $ENV{'REMOTE_ADDR'} if ($userIP eq '');
  $userIP = $ENV{'HTTP_X_FORWARDED_FOR'} if ($ENV{'HTTP_X_FORWARDED_FOR'} ne '');

  $max_comment_length = 1500;

  &ReadParse(*parameters);
  $recipient=$parameters{'recipient'};
  $to_title=$parameters{'title'};
  $referer=$parameters{'referer'};
  $uname=$parameters{'uname'};
  $comment=$parameters{'comment'};
  $source=$parameters{'source'};        # first user-entered return e-mail addr
  $source2=$parameters{'veriphy'};      # second user-entered return e-mail addr

# do some nastiness-checking on user-entered e-mail address
##$$##

#2007#  $source = 'nobody@moscowfsl.wsu.edu' if ($source eq '');

  if ($recipient eq 'webmaster') {$recipient = 'dehall'}

#  $subj = 'Comments from ' . $userIP;
  $subj = 'Comments from ' . $uname;       # dangerous -- user-input
  $subj_length = length ($subj);
  $subj =~ tr/a-z0-9A-Z /*/cs;             # change non-alpha-nums to star
  if ($subj_length > 80) {$subj = substr($subj,0,80)}
  
  $comment_length = length ($comment);

  if ($recipient =~ '@') {  # send the thanks but no thanks page
    $message = "<hr><p><H2>Thank you for sharing your comments with us.
    <p>
    I'm afraid I was not allowed to mail the comments.  I did not like the recipient name $recipient
    <p>
    Your comments were not delivered.</H2>";
    $title = "Comment submission rejection";
  }
  elsif ($source !~ '@' || $source eq '') {  # send the thanks but no thanks page
    $message = "<hr><p><H2>Thank you for sharing your comments with us.
    <p>
    I'm afraid I was not allowed to mail the comments.  You did not include a valid e-mail address.
    <p>
    Your comments were not delivered.</H2>";
    $title = "Comment submission rejection";
  }
  elsif ($source != $verify) {  # send the thanks but no thanks page
    $message = "<hr><p><H2>Thank you for sharing your comments with us.
    <p>
    I'm afraid I was not allowed to mail the comments.  Your e-mail addresses did not match.
    <p>
    Your comments were not delivered.</H2>";
    $title = "Comment submission rejection";
  }
  elsif ($comment_length == 0) {  # send the thanks but no thanks page
    $message = "<hr><p><H2>Thank you for sharing your comments with us.
    <p>
    I'm afraid I was not allowed to mail the comments because they were empty.
    <p>
    Your comments were not delivered.</H2>";
    $title = "Comment submission rejection";
  }
  elsif ($comment_length > $max_comment_length) {  # send the thanks but page
    $message = "<hr><p><H2>Thank you for sharing your comments with us.
    <p>
    I'm afraid I was not allowed to mail the comments because they were too lengthy.
    <p>
    Your comments were not delivered.</H2>";
    $title = "Comment submission rejection";
  }
#  elsif ($referer =~ 'commform2.pl' || $referer eq '' || $referer =~ 'document.referrer') {  # send the 'thanks but' page	# DEH 2006.10.11 2006.10.12
  elsif ($referer !~ 'forest.moscowfsl.wsu.edu' || $referer eq '') {	# send the 'thanks but' page	# DEH 2006.10.11 2006.10.12
    $message = "<hr><p><H2>Thank you for sharing your comments with us.
    <p>
    I'm afraid I was not allowed to mail the comments because they
    do not appear to have come from an accepted web page.
    <p>
    Your comments were not delivered.</H2>";
    $title = "Comment submission rejection";
  }
  else {
#   $dest = $recipient . '\@ fs.fed.us';
    $dest = '<' . $recipient . '@' . 'fs.fed.us>';
    $message = "<hr><p><H2>Thank you for sharing your comments with us.
    <p>
    They have been mailed to $to_title</H2>";
    $title = "Comment submission confirmation";

    $comment =~ s/\+/ /g;  # changes the plusses to spaces
    $comment =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C",hex($1))/eg;  # changes hex to characters

#    open (M,"|mail -s '$subj' $dest");
#    open (M,"|/usr/sbin/sendmail -i -t -U -f '$source'");
    open (M,"|/usr/sbin/sendmail -i -t -U");
      print M "To: $dest\n";
#     print M "From: $source\n";
      print M "Reply-to: $source\n";
      print M "Subject: $subj\n\n";
      print M "Comment to $to_title
from $uname ($source) [$userIP]
refering web page: $referer

$comment
";
    close (M);
  }

# send the thanks page

  &pagehead;
  print $message,"\n";
      print '<hr width=75% align=center><p><blockquote><pre>';
      print "Comment to $to_title\nfrom $uname ($source): \n\n$comment\n";
      print '</pre></blockquote><hr width=75% align=center>';
#  print length($in),"\n";
#  print $comment_length,"\n";
  print '<form><center><input type="button" value="Return"
    onClick="window.history.go(-2);"></center></form>';
  &pagetail;

# ----- subroutines -----

sub pagehead {
  print "Content-type: text/html\n\n",
        "<HTML>
 <HEAD>
  <TITLE>$title</TITLE>
 </HEAD>
 <BODY bgcolor=ivory>\n";
}

sub pagetail {
  print "  <HR>
 </BODY>
</HTML>
";
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

