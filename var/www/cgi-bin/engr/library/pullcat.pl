   open LIB, "<pubdb.txt";

   while (<LIB>) {
     if (/#/) {  # print $_;
       chomp $author;
       print "$code\t$author\t$title";
#      $code =~ s/#//g;
       $code = substr($_,1,5); 
     }
#    if (/\$author/i) {($xx,$author)=split $_,'='}
     if (/\$authors=/i) {($key,$author)=split '=', $_, 2}
     if (/\$title=/i)   {($key,$title) =split '=', $_, 2}
   }
   close LIB;
