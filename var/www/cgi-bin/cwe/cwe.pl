#!/usr/bin/perl

use warnings;
use CGI;
use CGI qw(escapeHTML);
use MoscowFSL::FSWEPP::FsWeppUtils qw(printdate);

my $cgi = new CGI;

# cwe.pl
# <a href='/cgi-bin/cwe/cwe.pl?chapter=1' target="_cwe'>

# works in concert with counter.pl
# <iframe src="/cgi-bin/cwe/counter.pl?chapter=1" width=100 height=20 frameborder=0 scrolling=no align=right></iframe>

## get chapter number and add a dit to the chapter ditfile
## then serve the person the chapter

@file[1] = 'RYAN_Intro_Final_0119.pdf';
@file[2] = 'Fire_regimes_and_ecoregions_Bailey_Final.pdf';
@file[3] = 'Graham_Jain_Chap_Figs_Final.pdf';

# @file[4] = 'Tools_Rummer_Final.pdf';
@file[4] = 'Rummer_Tools_FINAL_2.pdf';
@file[5] = 'Robichaud_CWE_wFigs_Final.pdf';
@file[6] = 'gullyslide_Reid_3.pdf';
@file[7] = 'Troendle_WY_2.pdf';
@file[8] = 'Waterquality_Stednick_4_Final.pdf';
@file[9] = 'Soils_Page-Dumroese_2_Final.pdf';

# @file[10] = 'Dwire_final_wfig1.pdf';
@file[10] = 'Dwire_RiparianwFigs_2.pdf';
@file[11] = 'McCormick%20aquatics%20final.pdf';
@file[12] = 'LandscapeScaleEffects8_Luce_Final.pdf';
@file[13] = 'CWE_chapter13.pdf';
@file[14] = 'ReidCWErev2.pdf';

## read command line get chapter
## check for valid value


$chapter = escapeHTML($cgi->param('chapter'));
$chapt   = $chapter + 0;

## add a dit to the chapter's ditfile

if ( $chapt >= 1 && $chapt <= 14 ) {
    $ditlogfile = '>>working/' . $chapt;
    open MYLOG, $ditlogfile;
    flock MYLOG, 2;
    print MYLOG '.';
    close MYLOG;

## serve the document
##

    print "Content-type: text/html

<HTML>
 <HEAD>
  <title>CWE Chapter $chapt</title>
  <meta http-equiv='Refresh' content='0; URL=/engr/cwe/@file[$chapt]'>
 </HEAD>
 <BODY onload='self.focus()'>
  <font face='tahoma' color='gray' size=-1>
   Loading CWE draft chapter $chapter<br>
  </font>
 </body>
</html>";
}
else {
    print "Content-type: text/html

<HTML>
 <HEAD>
  <title>CWE document not found  </title>
 </HEAD>
 <BODY onload='self.focus()'>
  <font face='tahoma' color='gray' size=-1>
   Document not found.
  </font>
 </body>
</html>";
}
