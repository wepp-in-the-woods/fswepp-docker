#!/usr/bin/perl
# search_ssg.pl
##############################################################################
# Simple Search                 Version 1.0                                  #
# Copyright 1996 Matt Wright    mattw@scriptarchive.com                      #
# Created 12/16/95              Last Modified 12/16/95                       #
# Scripts Archive at:           https://www.scriptarchive.com/                #
##############################################################################
# COPYRIGHT NOTICE                                                           #
# Copyright 1996 Matthew M. Wright  All Rights Reserved.                     #
#                                                                            #
# Simple Search may be used and modified free of charge by anyone so long as #
# this copyright notice and the comments above remain intact.  By using this #
# code you agree to indemnify Matthew M. Wright from any liability that      #
# might arise from it's use.                                                 #
#                                                                            #
# Selling the code for this program without prior written consent is         #
# expressly forbidden.  In other words, please ask first before you try and  #
# make money off of my program.                                              #
#                                                                            #
# Obtain permission before redistributing this software over the Internet or #
# in any other medium.  In all cases copyright and header must remain intact.#
##############################################################################
# Define Variables                                                           #

$version='2014.10.15';

#$basedir = '/home/httpd/html/ssg/';
#$baseurl = 'https://forest.moscowfsl.wsu.edu/ssg/';
#$basedir = '/srv/www/ssg/';						# 2004.11.04
$basedir = '/var/www/ssg/';						# 2014.10.15
$baseurl = 'https://forest.moscowfsl.wsu.edu/ssg/';			# 2004.11.04
@files = ('*.html');
$title = 'Slope Stability Reference Guide for National Forests in the U.S.';
# $title_url = 'https://forest.moscowfsl.wsu.edu/ssg/';
# $search_url = 'https://forest.moscowfsl.wsu.edu/ssg/search_search.html';
$title_url = 'https://forest.moscowfsl.wsu.edu/ssg/';			# 2004.11.14
$search_url = 'https://forest.moscowfsl.wsu.edu/ssg/search_search.html';	# 2004.11.04

# Done                                                                       #
##############################################################################

# Parse Form Search Information
&parse_form;

# Get Files To Search Through
&get_files;

# Search the files
&search;

# Print start of HTML Results of Search

   print "Content-type: text/html\n\n";
   print "<html>
 <head>
  <title>Slope Stability Guide Search Results</title>
 </head>
 <body link=green vlink=darkgreen alink=crimson>
  <font face='Tahoma, Arial, sans serif'>
   <h3 align='center'>Results of Search in <a href=\"$title_url\">$title</a></h3>
";

    print '
  <form method=POST action="https://forest.moscowfsl.wsu.edu/cgi-bin/engr/search_ssg.pl">
   <center>
    <table border=0 bgcolor="green" cellpadding=6>
     <tr>
      <th>
       <input type=text name="terms" size=40>
<!--
       boolean:
       <select name="boolean">
        <option>AND
        <option>OR
       </select>
       case:
       <select name="case">
        <option>Insensitive
        <option>Sensitive
       </select>
-->
       <input type=submit value="Search">
      </th>
     </tr>
    </table>
   </form>
  </center>
';

   print "<font size = -1>
   Search Information:
   <ul>
    <li><b>Terms:</b>
";
   $i = 0;
   foreach $term (@terms) {
      print "$term";
      $i++;
      if (!($i == @terms)) {
         print " <i>$boolean</i> ";
      }
   }
   print "
    <li><b>Boolean:</b> $boolean </li>
    <li><b>Case:</b> $case </li>
   </ul>
  </font>
   <br>
";

# Print Results of Search
# &return_html;

   print "
   Results sorted by filename:
   <br>
   <ul>
";
   foreach $key (sort keys %include) {
      if ($include{$key} eq 'yes') {
         print "<li><a href=\"$baseurl$key\">$titles{$key}</a>\n";
         push @links, "<li><a href=\"$baseurl$key\">$titles{$key}</a>";
         push @titlesort, $titles{$key};
      }
#      else {print $key}				# 2004.11.04
   }
   print "</ul>\n";
#  print "<hr size=7 width=75%>\n";

#  index sort @links by @titlesort

#   @indexx = sort {@titlesort[$a] <=> @titlesort[$b]} 0..$#titlesort;  # sort indices
#   print "Below are the results of your Search sorted by page title:<p><hr size=7 width=75%><p>\n";
#   print @indexx;
#   print "<ul>\n";
#   for $sp (0..$#titlesort) {
#     print @links[@indexx[$sp]],"\n";
#  }
#   print "</ul>\n";
#   print "<hr size=7 width=75%>\n";

#
print "
   <hr size=7 width=75%><font size=-2>
   $version<br>
   Search Script written by Matt Wright and can be found at <a href=\"https://www.scriptarchive.com/\">Matt's Script Archive</a>
";
  print "
 </body>
</html>
";

#################################  subroutines  #################################

sub parse_form {

   # Get the input
   read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});

   # Split the name-value pairs
   @pairs = split(/&/, $buffer);

   foreach $pair (@pairs) {
      ($name, $value) = split(/=/, $pair);

      $value =~ tr/+/ /;
      $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;

      $FORM{$name} = $value;
   }
}

sub get_files {

   chdir($basedir);
   foreach $file (@files) {
      $ls = `ls $file`;
      @ls = split(/\s+/,$ls);
      foreach $temp_file (@ls) {
         if (-d $file) {
            $filename = "$file$temp_file";
            if (-T $filename) {
               push(@FILES,$filename);
            }
         }
         elsif (-T $temp_file) {
            push(@FILES,$temp_file);
         }
      }
   }
}

sub search {

# split first on quoted strings would be nice...

   @terms = split(/\s+/, $FORM{'terms'});
   $boolean = $FORM{'boolean'};
   $boolean = 'AND' if ($boolean eq '');   
   $case = $FORM{'case'};
   $case = 'Insensitive' if ($case eq '');   

   foreach $FILE (@FILES) {

      open(FILE,"$FILE");
      @LINES = <FILE>;
      close(FILE);

      $string = join(' ',@LINES);
      $string =~ s/\n//g;
      if ($boolean eq 'AND') {
         foreach $term (@terms) {
            if ($case eq 'Insensitive') {
               if (!($string =~ /$term/i)) {
                  $include{$FILE} = 'no';
  		  last;
               }
               else {
                  $include{$FILE} = 'yes';
               }
            }
            elsif ($case eq 'Sensitive') {
               if (!($string =~ /$term/)) {
                  $include{$FILE} = 'no';
                  last;
               }
               else {
                  $include{$FILE} = 'yes';
               }
            }
         }
      }
      elsif ($boolean eq 'OR') {
         foreach $term (@terms) {
            if ($case eq 'Insensitive') {
               if ($string =~ /$term/i) {
                  $include{$FILE} = 'yes';
                  last;
               }
               else {
                  $include{$FILE} = 'no';
               }
            }
            elsif ($case eq 'Sensitive') {
               if ($string =~ /$term/) {
		  $include{$FILE} = 'yes';
                  last;
               }
               else {
                  $include{$FILE} = 'no';
               }
            }
         }
      }
      if ($string =~ /<title>(.*)<\/title>/i) {
         $titles{$FILE} = "$1";
      }
      else {
         $titles{$FILE} = "$FILE";
      }
   }
}

sub start_html {
}
      
sub return_html {

   print "
   <hr size=7 width=75%>
   <br>
   <ul>
";
   foreach $key (sort keys %include) {
      if ($include{$key} eq 'yes') {
         print "<li><a href=\"$baseurl$key\">$titles{$key}</a>\n";
         push @links, "<li><a href=\"$baseurl$key\">$titles{$key}</a>";
         push @titlesort, $titles{$key};
      }
#      else {print $key}				# 2004.11.04
   }
   print "</ul>\n";
   print "<hr size=7 width=75%>\n";

#  index sort @links by @titlesort

#   @indexx = sort {@titlesort[$a] <=> @titlesort[$b]} 0..$#titlesort;  # sort indices
#   print "Below are the results of your Search sorted by page title:<p><hr size=7 width=75%><p>\n";
#   print @indexx;
#   print "<ul>\n";
#   for $sp (0..$#titlesort) {
#     print @links[@indexx[$sp]],"\n";
#  }
#   print "</ul>\n";
#   print "<hr size=7 width=75%>\n";

#
   print "
   Search Information:
   <ul>
    <li><b>Terms:</b>
";
   $i = 0;
   foreach $term (@terms) {
      print "$term";
      $i++;
      if (!($i == @terms)) {
         print " <i>$boolean</i> ";
      }
   }
   print "
    <li><b>Boolean used:</b> $boolean </li>
    <li><b>Case:</b> $case </li>
   </ul>
   <br>
   <hr size=7 width=75%><P>
   <ul>
    <li><a href=\"$search_url\">Back to Search Page</a></li>
    <li><a href=\"$title_url\">$title</a></li>
   </ul>
   <hr size=7 width=75%><font size=-2>
   $version<br>
   Search Script written by Matt Wright and can be found at <a href=\"https://www.scriptarchive.com/\">Matt's Script Archive</a>
";
  print "
 </body>
</html>
";
}
