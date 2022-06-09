#! /usr/bin/perl

#  dwblogger.pl
#  log Disturbed WEPP Batch runs (names and user description)
#  determines caller's IP

#  [IP]
#  [Time]
#  ?count=RunCount
#  &version=version
#  &location=location

#  2011.03.21 David E. Hall USFS RMRS Moscow

#  to do: verify

   &ReadParse(*parameters);

    $count=$parameters{'count'};
    $version=$parameters{'version'};
    $location=$parameters{'location'};

#   Determine caller's ID

    $user_IP=$ENV{'REMOTE_ADDR'};
    $remote_address=$user_IP;
    $remote_host=$ENV{'REMOTE_HOST'};
    $user_really=$ENV{'HTTP_X_FORWARDED_FOR'};
    $user_IP=$user_really if ($user_really ne '');
#   $user_IP =~ tr/./_/;

#   $user_IP = '166.2.22.221';
#   $count = 5;
#   $location = 'Somewhere';

#  determine time

   @months=qw(January February March April May June July August September October November December);
   @days=qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);
   $ampm[0] = "am";
   $ampm[1] = "pm";

   $ampmi = 0;
   ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime;
   if ($hour == 12) {$ampmi = 1}
   if ($hour > 12) {$ampmi = 1; $hour = $hour - 12}
   $thisyear = $year+1900;

#  record activity in Disturbed WEPP log (if running on remote server)

#    open WDLOG, ">>../working/dwb.log";
     open WDLOG, ">>../working/_$thisyear/dwb.log";
       flock (WDLOG,2);
       print WDLOG "$user_IP\t\"";
       printf WDLOG "%0.2d:%0.2d ", $hour, $min;
       print WDLOG $ampm[$ampmi],"  ",$days[$wday]," ",$months[$mon]," ",$mday, ", ",$thisyear, "\"\t";
       print WDLOG $count,"\t";
       print WDLOG $version,"\t";
#      print WDLOG '"',trim($location),"\"\n";
       print WDLOG '"',$location,"\"\n";
     close WDLOG;

print "Content-type: text/plain\n\n";
print "Run logged for Disturbed WEPP batch:\n";
       print  "$user_IP\t\"";
       printf "%0.2d:%0.2d ", $hour, $min;
       print  $ampm[$ampmi],"  ",$days[$wday]," ",$months[$mon]," ",$mday, ", ",$thisyear, "\"\t";
       print  $count,"\t";
       print  $version,"\t";
#      print  '"',trim($location),"\"\n";
       print  '"',$location,"\"\n";


# ------------------------ subroutines ---------------------------

sub ReadParse {

# ReadParse -- from cgi-lib.pl (Steve Brenner) from Eric Herrmann's
# "Teach Yourself CGI Programming With PERL in a Week" p. 131

# Reads GET or POST data, converts it to unescaped text, and puts
# one key=value in each member of the list "@in"
# Also creates key/value pairs in %in, using '\0' to separate multiple
# selections

   local (*in) = @_ if @_;
   local ($i, $loc, $key, $val);
#       read text
   if ($ENV{'REQUEST_METHOD'} eq "GET") {
     $in = $ENV{'QUERY_STRING'};
   }
   elsif ($ENV{'REQUEST_METHOD'} eq "POST") {
     read(STDIN,$in,$ENV{'CONTENT_LENGTH'});
   }
   @in = split(/&/,$in);
   foreach $i (0 .. $#in) {
     $in[$i] =~ s/\+/ /g;         # Convert pluses to spaces
     ($key, $val) = split(/=/,$in[$i],2);         # Split into key and value
     $key =~ s/%(..)/pack("c",hex($1))/ge;        # Convert %XX from hex numbers to alphanumeric
     $val =~ s/%(..)/pack("c",hex($1))/ge;
     $in{$key} .= "\0" if (defined($in{$key}));  # \0 is the multiple separator
     $in{$key} .= $val;
   }
   return 1;
}
