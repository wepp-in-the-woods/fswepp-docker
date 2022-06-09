#! /usr/bin/perl

# alert.pl

# 2012.12    DEH adapt for use in allowing call-in alert creation for lab home page
# 2005.07.05 DEH modify commform2.pl
# DEH Dec 03, 2003 -- Modify generated HTML formatting
# DEH 04/10/2000 -- limit textarea size (test)

#====================== mailcomm.pl ======================
# Retrieves and parses form data, mails data, and displays response page.
# From Official HTML Publishing for Netscape, p. 417-418.

  $userIP = $ENV{'REMOTE_HOST'};
  $userIP = $ENV{'REMOTE_ADDR'} if ($userIP eq '');
  $userIP = $ENV{'HTTP_X_FORWARDED_FOR'} if ($ENV{'HTTP_X_FORWARDED_FOR'} ne '');

  $max_comment_length = 200;

  &ReadParse(*parameters);
  $password=$parameters{'pass'};
  $alert=$parameters{'notice'};

# do some nastiness-checking on alert

##$$##

# $source = 'nobody@moscowfsl.wsu.edu' if ($source eq '');
#  $to_title_unesc = $to_title;
#  $to_title_unesc =~ s/%(..)/pack("c",hex($1))/ge;	  # Convert %XX from hex numbers to alphanumeric
#  $to_title_unesc =~ s/%20/ /ge;

  if ($password eq 'n0t1c3') {

    chomp $alert;
#   $alert =~ tr/a-z0-9A-Z. /*/cs;             # change non-alpha-nums to star
    $alert =~ tr/<>&|/*/s;
    $alert_length = length ($alert);

    if ($alert eq '') {$alert = 'No alerts today';}

#   if ($alert_length < $max_comment_length) {

#     open ALERT, '>/srv/www/fswepp/working/notice.html';
      open ALERT, '>/var/www/fswepp/working/notice.html';
        print ALERT "<html>
 <head>
 </head>
 <body bgcolor=dbd594>
  <font face=\"trebuchet, tahoma, calibri, sans serif\" size=+1>
   $alert
  </font>
 <!-- $userIP -->
 </body>
</html>
";
      close ALERT;

      $title = "Alert received";
      $message = "
      <h3>Alert received</h3>
      <hr>
      <h4>$alert</h4>
      <br><br>
      ";
#   }
#   else {
#     $title = "Alert rejected";
#     $message = "
#     <hr>
#     <h3>Alert too long.</h3>
#     <br><br>
#     ";
  }
  else {
    $title = "Alert rejection";
    $message = "
    <hr>
    <h3>Password incorrect.</h3>
    <br><br>
    ";
  }

  &pagehead;
  print $message;
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
