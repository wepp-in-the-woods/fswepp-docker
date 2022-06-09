#! /usr/bin/perl

# getpar.pl

   @trusted_hosts[0]='134.121.1.72';
   @trusted_hosts[1]='forest.moscowfsl.wsu.edu';

# readparse parfile

   &ReadParse(*parameters);
   $parfilePath=$parameters{'parfile'};         #

# check URL for trusted_hosts

   $firstslashisat = index($parfilePath,'/');
   $host = substr($parfilePath,0,$firstslashisat);
   $trusted=0;
   foreach $h (@trusted_hosts) {
     if ($h =~ $host) {
       $trusted=1;
       last;
     }
   }

# add .par

# can we sneek a peek?

# wget $parfile

# check content

# then what?

     print "Content-type: text/html\n\n";
     print "<HTML>\n";
     print " <HEAD>\n";
     print "  <TITLE>getpar.pl</TITLE>\n";
     print " </HEAD>\n";
     print " <BODY>
Parameter file is: $parfilePath<br>
host $host<br>
trusted $trusted

 </body>
</html>
";


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
     $in[$i] =~ s/\+/ /g;	  # Convert pluses to spaces
     ($key, $val) = split(/=/,$in[$i],2);	  # Split into key and value
     $key =~ s/%(..)/pack("c",hex($1))/ge;	  # Convert %XX from hex numbers to alphanumeric
     $val =~ s/%(..)/pack("c",hex($1))/ge;
     $in{$key} .= "\0" if (defined($in{$key}));  # \0 is the multiple separator
     $in{$key} .= $val;
   }
   return 1;
}

#---------------------------
