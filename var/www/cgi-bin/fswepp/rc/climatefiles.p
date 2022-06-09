#! /usr/bin/perl


   &ReadParse(*parameters);
   $ip=$parameters{'ip'};                       # 166.2.22.221';
   if ($ip ne '') {
     $ipd = $ip;
     $ipd =~ tr/./_/;
   }
#   $ipd = '166_2_22_221';                      # get from caller or argument list
   else {                                       # who am I?
     $ip=$ENV{'REMOTE_ADDR'};
     $user_really=$ENV{'HTTP_X_FORWARDED_FOR'};
     $ip=$user_really if ($user_really ne '');
     $ipd = $ip;
     $ipd =~ tr/./_/;
   }

    $user_ID=$ENV{'REMOTE_ADDR'};
    $remote_address=$user_ID;                           # DEH 02/19/2003
    $remote_host=$ENV{'REMOTE_HOST'};                   # DEH 02/19/2003
    $user_really=$ENV{'HTTP_X_FORWARDED_FOR'};          # DEH 11/14/2002
    $user_ID=$user_really if ($user_really ne '');      # DEH 11/14/2002
    $user_ID =~ tr/./_/;

$user_ID = '166_2_22_221';

    $user_ID = $user_ID . $me;                  # DEH 03/05/2001
    $custCli = '../working/' . $user_ID . '_';  # DEH 03/05/2001

#   $ipd = '166_2_22_221';                      # get from caller or argument list
   $debug=1;

print "Content-type: text/html\n\n";
print '<html>
 <head>
  <title>Rock:Clime</title>
  <!-- rockclim.pl version ',$version,' -->
 </head>
 <BODY bgcolor="white" link="#1603F3" vlink="160A8C">
';


### get custom climates, if any ###

    $num_cli = 0;
    @fileNames = glob($custCli . '*.par');

print "custCli: $custCli<br>\n
  userID: $user_ID<br>\n
  me; $me<br>\n
";

    for $f (@fileNames) {
 if ($debug) {print "Opening $f<br>\n";}
      open(M,"<$f") || die;              # cli file
      $station = <M>;
      close (M);
      $climate_file[$num_cli] = substr($f, 0, length($f)-4);
#      $clim_name = "*" . substr($station, index($station, ":")+2, 40);
      $clim_name = "*" . substr($station, 0, 40);
      $clim_name =~ s/^\s*(.*?)\s*$/$1/;
      $climate_name[$num_cli] = $clim_name;
      $num_cli += 1;
    }

print  '
    <table cellpadding=6 border=2>
     <tr>
      <th valign=top>
';
    print "  <h3>Manage personal climates <sup>1</sup>";
    if ($me ne '') {print "<br>for personality '$me'"}
    print "</h3><p>\n";
    if ($num_cli == 0) {print "No personal climates exist<p><hr>\n"}
    else {
      print '
      <form method="post" action="../rc/manageclimates.pl">
      <SELECT NAME="Climate" SIZE="',$num_cli,'">
      <OPTION VALUE="';
      print $climate_file[0];
      print '" selected> '. $climate_name[0] . "\n";
      for $ii (1..$num_cli-1) {
        print '        <OPTION VALUE="';
        print $climate_file[$ii];
        print '"> '. $climate_name[$ii] . "\n";
      }

      print '      </SELECT>
      <p>
      <input type="hidden" name="units" value="',$units,'">
      <input type="hidden" name="comefrom" value="',$comefrom,'">
      <input type="submit" name="manage" value="Describe">
      <input type="submit" name="manage" value="Remove">
<!--      <input type="submit" name="manage" value="Modify"> -->
      </form>
     </th>
';
    }
    print '      <th valign=top>
   <h3>To add a climate station,<br>';

#-------------------------------

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

