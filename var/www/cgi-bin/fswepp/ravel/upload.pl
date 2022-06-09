#!/usr/bin/perl
use CGI;
my $cgi = new CGI;

#  my $dir = $cgi->param('dir');
  my $file = $cgi->param('file');
  $file=~m/^.*(\\|\/)(.*)/; # strip the remote path and keep the filename
  my $name = $2;
#  open(LOCAL, ">$dir/$name") or die $!;
#  while(<$file>) {
#  print LOCAL $_;
#  }
  print $cgi->header();
  print "$file has been successfully uploaded... thank you.\n";
  
  print "file: $file ";
  print "filename: $name ";
  $line = <$file>;
  print "First line: $line";


