#! /usr/bin/perl

# count.pl?chapter=5

# read argument (chapter)

# clean up argument (limit to '1' to '15')

    $chapter = '1';		# temporary
    $file = 'working/' . $chapter;
    $numhits='';
    if (-e $file) {
#      $wc  = `wc $file`;
#      @words = split " ", $wc;
#      $numhits = commify (@words[0]);
    }

# return HTML page with length of file 'chapter'

     print "Content-type: text/html

<HTML>
 <HEAD>
 </HEAD>
 <BODY leftmargin=0 topmargin=0 marginwidth=0 marginheight=0>
  <font face='tahoma' color='gray' size=-1>
   $chapter
   </font>
  </iframe>
 </body>
</html>";

sub commify {
    my $text = reverse $_[0];
    $text =~ s/(\d\d\d)(?=\d)(?!d*\.)/$1,/g;
    return scalar reverse $text;
}

