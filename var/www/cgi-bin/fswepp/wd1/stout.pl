   $stoutfile = '../working/cwepp-25391.out';

   $cligen_version="version unknown ($stoutfile)";
   open STOUT, "<$stoutfile";                     
   while (<STOUT>) {                              
     if (/VERSION/) {                             
        $cligen_version = lc($_);                 
        last;                                     
     }                                            
   }                                              
   close STOUT;                                 

   print"CLIGEN $cligen_version\n";

