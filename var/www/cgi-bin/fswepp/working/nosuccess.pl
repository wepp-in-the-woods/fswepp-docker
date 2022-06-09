$stoutFile = 'wepp-20444.stout';

       open weppstout, "<$stoutFile";

print "checking $stoutFile for successful run ... ";
       $found = 0;
       while (<weppstout>) {
# print $_;
         if (/SUCCESSFUL/) {
           $found = 1;
           print "successful! ";
           last;
         }
       }
       close (weppstout);

