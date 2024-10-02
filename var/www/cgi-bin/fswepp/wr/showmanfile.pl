#!/usr/bin/perl

# read file name from command line
# allow only
#  -rw-r--r-- 1 504 505 77640 2003-10-21 16:01 3inslope.man
#  -rw-r--r-- 1 504 505 77823 2003-10-21 16:01 3inslopen.man
#  -rw-r--r-- 1 504 505 77653 2003-10-21 16:01 3outrut.man
#  -rw-r--r-- 1 504 505 77807 2003-10-21 16:01 3outrutn.man
#  -rw-r--r-- 1 504 505 77623 2003-10-21 16:01 3outunr.man
#  -rw-r--r-- 1 504 505 77806 2003-10-21 16:01 3outunrn.man
# add working/   and .man (?)
# if exist
#    write header, read and display file, trailer
# else
#    write header, 'sorry', trailer

# $arg0 = $ARGV[0];  chomp $arg0;
 
 &ReadParse(*parameters);

 $arg0=$parameters{'f'};

 $argnotfound=0;
 $badfilename=1;
 $filenotfound=1;

 if ($arg0 eq '') {$argnotfound=1}
 if (!$argnotfound) {			#  filter argument and check
					#  $arg0 = '../wepp-2345';
#   $badfilename=0 if $arg0 =~ 'wepp-\d{4,5}?';
   $badfilename=0 if ($arg0 eq '3inslope.man' ||
                     $arg0 eq '3inslopen.man' ||
                     $arg0 eq '3outrut.man' ||
                     $arg0 eq '3outrutn.man' ||
                     $arg0 eq '3outunr.man' ||
                     $arg0 eq '3outunrn.man');
  }

 if (!$badfilename && !$argnotfound) {
   $manfile = 'data/'.$arg0;
   if (-e $manfile) {
     $filenotfound=0;
   }
 }

# print header

print "Content-type: text/plain\n\n";
# print "<html>
# <head>
#  <title>WEPP management (vegetation) file for $arg0</title>
# </head>
# <body>
#  <font face='gill sans, trebuchet, tahoma, arial, sans serif' font size=-2>
#";

# print body

  if ($argnotfound) {print 'no management file specified'}
  else {
    if ($badfilename) {print "I don't like the specified file $arg0";}
    else {
      if ($filenotfound) {print "I can't open file $manfile"}
      else {
#       print "howdy doody $manfile";
        open MAN, "<$manfile";
          @z=<MAN>;
        close MAN;
        print @z;
      }
    }
  }

# print trailer

#print '
#  </font>
# </body>
#</html>
#';

sub ReadParse {

# ReadParse -- from cgi-lib.pl (Steve Brenner) from Eric Herrmann's
# "Teach Yourself CGI Programming With PERL in a Week" p. 131

  local (*in) = @_ if @_;
  local ($i, $loc, $key, $val);

  if ($ENV{'REQUEST_METHOD'} eq "GET") {
    $in = $ENV{'QUERY_STRING'};
  } elsif ($ENV{'REQUEST_METHOD'} eq "POST") {
    read(STDIN,$in,$ENV{'CONTENT_LENGTH'});
  }
  @in = split(/&/,$in);
  foreach $i (0 .. $#in) {
    $in[$i] =~ s/\+/ /g;                        # Convert pluses to spaces
    ($key, $val) = split(/=/,$in[$i],2);        # Split into key and value
    $key =~ s/%(..)/pack("c",hex($1))/ge;       # Convert %XX from hex numbers to alphanumeric
    $val =~ s/%(..)/pack("c",hex($1))/ge;
    $in{$key} .= "\0" if (defined($in{$key}));  # \0 is the multiple separator
    $in{$key} .= $val;
  }
  return 1;
 }
