#! /usr/bin/perl

# read file name from command line
# clean up -- 'wepp-ddddd'
# add working/   and .man (?)
# if exist
#    write header, read and display file, trailer
# else
#    write header, 'sorry', trailer


 $arg0 = $ARGV[0];  chomp $arg0;
 
 $argnotfound=0;
 $badfilename=1;
 $filenotfound=1;

 if ($arg0 eq '') {$argnotfound=1}
 if (!$argnotfound) {			#  filter argument and check
					#  $arg0 = '../wepp-2345';
   $badfilename=0 if $arg0 =~ 'wepp-\d{4,5}?';
 }

 if (!$badfilename && !$argnotfound) {
   $manfile = 'working/'.$arg0.'.sol';
   if (-e $manfile) {
     $filenotfound=0;
   }
 }

# print header

print "Content-type: text/html\n\n";
 print "<html>
 <head>
  <title>WEPP management (vegetation) file for $arg0</title>
 </head>
 <body>
  <font face='gill sans, trebuchet, tahoma, arial, sans serif' font size=-2>
";

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

print '
  </font>
 </body>
</html>
';
