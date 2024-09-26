#! /usr/bin/perl

use strict;
use warnings;
use CGI;
use CGI qw(escapeHTML);
use lib '/var/www/cgi-bin/fswepp/dry';
use FsWeppUtils qw(commify);

my $cgi = CGI->new;

# counter.pl?chapter=5

# read chapter parameter from command line
# return file size of working/$chapter file, which is intended to be a record of file downloads

my $numhits = '';

# read argument (chapter)

my $chapter = escapeHTML( $cgi->param('chapter') );

# clean up argument (limit to '1' to '14')

$numhits   = '0';
my $downloads = 'downloads';
my $chapt     = $chapter + 0;
if ( $chapt >= 1 && $chapt <= 14 ) {
  my $file = 'working/' . $chapt;
  if ( -e $file ) {
    my $wc      = `wc -m $file`;
    my @words   = split " ", $wc;
    $numhits = commify( $words[0] );

    #     $numhits = $words[0];
    $downloads = 'download' if ( $numhits eq '1' );
  }
}

# return HTML page with length of file 'chapter'

print "Content-type: text/html

<HTML>
 <HEAD>
 </HEAD>
 <BODY leftmargin=0 topmargin=0 marginwidth=0 marginheight=0>
  <font face='tahoma' color='gray' size=-1>
   <div align='right'>
  $numhits $downloads&nbsp;
   </div>
  </font>
 </body>
</html>";
