#!/usr/bin/perl

# Known calls from: people/who2.pl?name=sbear
#                   /cgi-bin/people/popcomment.pl?title=Smokey%20BBear&recipient=sbear&referer=webpage.html

# 2005.07.05 DEH modify commform2.pl
# DEH Dec 03, 2003 -- Modify generated HTML formatting
# DEH 04/10/2000 -- limit textarea size (test)

#====================== mailcomm.pl ======================
# Retrieves and parses form data, mails data, and displays response page.
# From Official HTML Publishing for Netscape, p. 417-418.

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
  $source=$parameters{'source'};        # user-entered return e-mail addr

# do some nastiness-checking on user-entered e-mail address

##$$##

# $source = 'nobody@moscowfsl.wsu.edu' if ($source eq '');
  $to_title_unesc = $to_title;
  $to_title_unesc =~ s/%(..)/pack("c",hex($1))/ge;	  # Convert %XX from hex numbers to alphanumeric
#  $to_title_unesc =~ s/%20/ /ge;

  if ($recipient eq 'webmaster') {$recipient = 'dehall'}

  $subj = 'Comments from ' . $uname;       # dangerous -- user-input
  $subj_length = length ($subj);
  $subj =~ tr/a-z0-9A-Z. /*/cs;             # change non-alpha-nums to star
  if ($subj_length > 80) {$subj = substr($subj,0,80)}
  
  $comment_length = length ($comment);

  if ($recipient eq '') {  # send the thanks but no thanks page
    $title = "Comment submission rejection";
    $message = "
    <hr>
    <h3>Thank you for sharing your comments with us.</h3>
    I'm afraid I was not allowed to mail the comments because there was no recipient name. 
    <br><br>
    Your comments were not delivered.
    ";
  }
  elsif ($recipient =~ '@') {  # send the thanks but no thanks page
    $title = "Comment submission rejection";
    $message = "
    <hr>
    <h3>Thank you for sharing your comments with us.</h3>
    I'm afraid I was not allowed to mail the comments.  I did not like the recipient name $recipient
    <br><br>
    Your comments were not delivered.
    ";
  }
  elsif ($comment_length == 0) {  # send the thanks but no thanks page
    $title = "Comment submission rejection";
    $message = "
    <hr>
    <h3>Thank you for sharing your comments with us.</h3>
    I'm afraid I was not allowed to mail the comments because they were empty.
    <br><br>
    Your comments were not delivered.
    ";
  }
  elsif ($comment_length > $max_comment_length) {  # send the thanks but page
    $title = "Comment submission rejection";
    $message = "
    <hr>
    <h3>Thank you for sharing your comments with us.</h3>
    I'm afraid I was not allowed to mail the comments because they were so lengthy.
    <br><br>
    Your comments were not delivered.
    ";
  }
  else {
#   $dest = $recipient . '\@fs.fed.us';
    $dest = '<' . $recipient . '@fs.fed.us>';
    $title = "Comment submission confirmation";
    $message = "
    <hr>
    <h3>Thank you for sharing your comments with us.</h3>
    They are being mailed to $to_title_unesc
    ";

    $comment =~ s/\+/ /g;  # change the plusses to spaces
    $comment =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C",hex($1))/eg;  # change hex to characters

#   open (M,"|mail -s '$subj' $dest");
#   open (M,"|/usr/sbin/sendmail -i -t -U -f '$source'");
    open (M,"|/usr/sbin/sendmail -i -t -U");
      print M "To: $dest\n";
#     print M "From: $source\n";
      print M "Reply-to: $source\n";
      print M "Subject: $subj\n\n";
      print M "Comment to $to_title_unesc
from $uname ($source) [$userIP]
refering web page: $referer

$comment
";
    close (M);
  }

# send the thanks page

  &pagehead;
  print "
   $message
    <br>
     <blockquote>
      <hr>
      <pre>
To: $to_title_unesc
From: $uname ($source)

$comment
      </pre>
      <hr>
     </blockquote>
     <font size=-2>
      <center>
       <a href='javascript:self.close()'>close</a>
      </center>
     </font>
";
  &pagetail;

# ----- subroutines -----

sub pagehead {
  print "Content-type: text/html\n\n",
        "<HTML>
 <HEAD>
  <TITLE>$title</TITLE>
 </HEAD>
 <BODY background='/images/smokey.gif' link='green' vlink='green'>
  <font face='trebuchet, tahoma, arial, sans serif'>
";
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

