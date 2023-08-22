#! /usr/bin/perl

# resolve_dq.pl  [forest:/var/www/cgi-bin/engr]

#
#  call 'dig' to determine domain for dotted quad
#

# e.g. /cgi-bin/engr/resolve_dq.pl?dottedquad=199.156.164.23
# read parameter into $dottedq

    open IPlist, "<IPs.txt";

    while (<IPlist>) {chomp;

   $dottedquad=$_;
   $answer='unknown ';

#     $dottedquad = '134.121.1.72';
#     $dottedquad = '166.2.22.128';

       if ($dottedquad =~ m/(\d{1,3}\.){3}(\d{1,3})/) {
         $arg = 'dig -x ' . $dottedquad;
         @result = `$arg`;
         for ( my $i=0; $i < scalar(@result); $i++) {
           if (@result[$i] =~ 'ANSWER SECTION') {
             $answer = @result[$i+1];           # get NEXT line following 'ANSWER'
             @parts=split(' ',$answer);
             $answer=@parts[4];
           }
         }
       }
       else {
         $answer = "Improper format: $dottedquad ";
       }
#     }	# else ''
#    print @result;
     chop($answer);				# remove pesky "." at end (or anything else)
     print "$dottedquad\t$answer\n";
    }	 # while
    close IPlist;

