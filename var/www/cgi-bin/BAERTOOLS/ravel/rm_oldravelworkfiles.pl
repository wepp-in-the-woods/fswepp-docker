### erase old wepp-* files

    $working = 'working';
    $oldest=0; $count=0; $countr=0;
    opendir WORKDIR, $working;
      @allfiles=readdir WORKDIR;
    close WORKDIR;

    for $f (@allfiles) {
      $daysold=0;
      if (substr($f,0,6) eq 'ravel-') {
        $f = $working . '/' . $f;
        if (-e $f) {
#         $daysold = (-M $f);
          $daysold = int((-M $f)+0.5);
          $oldest = $daysold if ($daysold > $oldest);
          if ($daysold > 1) {
            print " $f; $daysold day(s) old -- erase\n";
            unlink $f;
            $count +=1;
          }
          else { # $daysold <= 1
            print " $f; $daysold day(s) old -- leave\n";
            $countr+=1;
          }
        }
      }
    }
    print "\n$countr remain, $count erased; oldest $oldest days old\n";
