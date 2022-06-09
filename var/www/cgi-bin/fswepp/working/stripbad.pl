open LOG, '<wd.log';
open NEWLOG, '>wd_new.log';

while (<LOG>) {

   if (!/""/) {   print NEWLOG $_; }

}

close NEWLOG;
close LOG;

