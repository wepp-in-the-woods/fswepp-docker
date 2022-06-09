#!/usr/bin/perl

#
#  Forest Service Water And Sediment Predictor input screen
#

#  wepplf.pl -- input screen for Forest Service Water And Sediment Predictor

    $version = '2009.04.27';

#  usage:
#    action = "wasp.pl"
#  parameters:
#    units:             # unit scheme (ft|m)
#    me
#  reads environment variables:
#       HTTP_COOKIE
#       REMOTE_ADDR
#       HTTP_X_FORWARDED_FOR
#       REQUEST_METHOD
#       QUERY_STRING
#       CONTENT_LENGTH
#  reads:
#    ../wepphost        # localhost or other
#    ../platform        # pc or unix
#    ../climates/*.par  # standard climate parameter files
#    $working/*.par     # personal climate parameter files
#  calls:
#    /cgi-bin/fswepp/wr/wd.pl
#    /cgi-bin/fswepp/wd/logstuff.pl
#  popup links:

#  FSWEPP, USDA Forest Service, Rocky Mountain Research Station, 
#  Soil & Water Engineering
#  Science by Bill Elliot et alia
#  Code by David Hall 

    &ReadParse(*parameters);
    $units=$parameters{'units'};
    if ($units eq 'm') {$areaunits='ha'}
    elsif ($units eq 'ft') {$areaunits='ac'}
    else {$units = 'ft'; $areaunits='ac'}
#    $me=$parameters{'me'};
    $cookie = $ENV{'HTTP_COOKIE'};
    $sep = index ($cookie,"=");
    $me = "";
    if ($sep > -1) {$me = substr($cookie,$sep+1,1)}

    if ($me ne "") {
       $me = lc(substr($me,0,1));
       $me =~ tr/a-z/ /c;
    }
    if ($me eq " ") {$me = ""}

  $wepphost="localhost";
  if (-e "../wepphost") {
    open Host, "<../wepphost";
    $wepphost = <Host>;
    chomp $wepphost;
    close H;
  }

  $platform="pc";
  if (-e "../platform") {
    open Platform, "<../platform";
      $platform=lc(<Platform>);
      chomp $platform;
    close Platform;
  }
  if ($platform eq "pc") {
    if (-e 'd:/fswepp/working') {$working = 'd:\\fswepp\\working\\'}
    elsif (-e 'c:/fswepp/working') {$working = 'c:\\fswepp\\working\\'}
    else {$working = '..\\working\\'}			# 2004.10.13 DEH
    $public = $working . '\\public\\'; 
    $logFile = "$working\\wdwepp.log";
    $cliDir = '..\\climates\\';
    $custCli = "$working";
  }
  else {
    $working='../working/';                             # DEH 08/22/2000
    $public = $working . 'public/';                     # DEH 09/21/2000
    $user_ID=$ENV{'REMOTE_ADDR'};
    $user_really=$ENV{'HTTP_X_FORWARDED_FOR'};          # DEH 11/14/2002
    $user_ID=$user_really if ($user_really ne '');      # DEH 11/14/2002
    $user_ID =~ tr/./_/;
    $user_ID = $user_ID . $me . '_';			# DEH 03/05/2001
    $logFile = '../working/' . $user_ID . '.log';
    $cliDir = '../climates/';
    $custCli = '../working/' . $user_ID;		# DEH 03/02/2001
  }

########################################

### get personal climates, if any

    $num_cli=0;

    opendir CLIMDIR, $working;                          # DEH 06/14/2000
    @allpfiles=readdir CLIMDIR;                         # DEH 05/05/2000
    close CLIMDIR;                                      # DEH 05/05/2000

#   @fileNames = glob($custCli . '*.par');
#   for $f (@fileNames) {
    for $f (@allpfiles) {                               # DEH 05/05/2000
      if (index($f,$user_ID)==0) {			# DEH 09/15/2000
        if (substr($f,-4) eq '.par') {                  # DEH 05/05/2000
          $f = $working . $f;                           # DEH 06/14/2000
          open(M,"<$f") || goto pskip;                  # DEH 05/05/2000
            $station = <M>;
          close (M);
#  print STDERR "$f\n";
          $climate_file[$num_cli] = substr($f, 0, -4);
          $clim_name = '*' . substr($station, index($station, ":")+2, 40);
          $clim_name =~ s/^\s*(.*?)\s*$/$1/;
          $climate_name[$num_cli] = $clim_name;
          $num_cli += 1;
        }
pskip:                                                  # DEH 05/05/2000
      }                                                 # DEH 05/05/2000
    }

### get standard climates

    opendir CLIMDIR, '../climates';                     # DEH 05/05/2000
    @allfiles=readdir CLIMDIR;                          # DEH 05/05/2000
    close CLIMDIR;                                      # DEH 05/05/2000

#   while (<../climates/*.par>) {                       # DEH 05/05/2000
#     $f = $_;                                          # DEH 05/05/2000

    for $f (@allfiles) {                                # DEH 05/05/2000
      $f = '../climates/' . $f;                         # DEH 05/05/2000
      if (substr($f,-4) eq '.par') {                    # DEH 05/05/2000
        open(M,$f) || goto sskip;                       # DEH 05/05/2000
          $station = <M>;
        close (M);
#  print STDERR "$f\n";
        $climate_file[$num_cli] = substr($f, 0, -4);
        $clim_name = substr($station, index($station, ":")+2, 40);
        $clim_name =~ s/^\s*(.*?)\s*$/$1/;
        $climate_name[$num_cli] = $clim_name;
        $num_cli += 1;
sskip:                                                  # DEH 05/05/2000
      }                                                 # DEH 05/05/2000
    }
    $num_cli -= 1;

###################################################

print "Content-type: text/html\n\n";
print <<'theEnd2';
<html>
<head>
<title>Forest Service Water And Sediment Predictor</title>
  <META http-equiv="Content-Type" content="text/html; charset=utf-8">
  <META NAME="Name" CONTENT="Disturbed WEPP">
  <META NAME="Brief Description" CONTENT="Disturbed WEPP, a component of FS WEPP, predicts erosion from rangeland, forestland, and forest skid trails. Forest Service Water And Sediment Predictor allows users to easily describe numerous disturbed forest and rangeland erosion conditions. The interface presents the probability of a given level of erosion occurring the year following a disturbance.">
  <META NAME="Status" CONTENT="Released 2000">
  <META NAME="Updates" CONTENT="Ongoing, online">
  <META NAME="Inputs" CONTENT="Climate station; soil texture; upper and lower element treatment, gradient, horizontal length, cover, and rock content">
  <META NAME="Outputs" CONTENT="Annual average precipitation; runoff from rainfall; runoff from snowmelt or winter rainstorm; upland erosion rate; sediment leaving profile; return period analysis of precipitation, runoff, erosion, and sediment; probabilities of occurrence first year following disturbance of runoff, erosion, and sediment delivery">
  <META NAME="Suggested user" CONTENT="">
  <META NAME="Suggested use" CONTENT="">
  <META NAME="Keywords" CONTENT="">
  <META NAME="Contributors" CONTENT="USDA Forest Service, Rocky Mountain Research Station, Moscow, ID: Bill Elliot and David Hall">
  <META NAME="Source" content="Run online at http://forest.moscowfsl.wsu.edu/fswepp/">

  <SCRIPT LANGUAGE = "JavaScript" type="TEXT/JAVASCRIPT">
  <!--

  var minyear = 1
  var maxyear = 200
  var defyear = 30

  var sunit = '%'
  var smin = 0
  var smax = 100
  var ofe1tsdef = 0
  var ofe1msdef = 30
  var ofe2tsdef = 30
  var ofe2bsdef = 5

  var pcunit = '%'
  var pcmin = 0
  var pcmax = 150
  var pcdef = 100

  var runit = '%'
  var rmin = 1
  var rmin = 0
  var rmax = 75
  var rdef = 20

theEnd2

if ($units eq 'm') {
  $lunit = ' m';
  $lmin = 0.5;
  $lmax = 400;
  $ldef = 50;
  $dunit = 'mm';
  $dmin = 25;
  $dmax = 800;
  $ddef1 = 400;
  $ddef2 = 600;
  $cunit = 'mm/h';
}
else {
  $lunit = ' ft';
  $lmin = 1.5;
  $lmax = 1200;
  $ldef = 150;
  $dunit = 'in';
  $dmin = 1;
  $dmax = 32;
  $ddef1 = 16;
  $ddef2 = 23;
  $cunit = 'in/h';
}

print "  var lunit = '$lunit'
  var lmin = $lmin
  var lmax = $lmax
  var ldef = $ldef
  var dmin = $dmin
  var dmax = $dmax
  var ddef1= $ddef1
  var ddef2= $ddef2

  var previous_what=''  // for show_climate
";

print <<'theEnd';


    function show_help(what) {
//      alert('show_help')
      if (what == previous_what) {hide_help(); return}
      if (what == 'climate') {
para='<h3>Climate file</h3>'
para = para +'  <b>[Ownership] Station name [Status]</b>'
para = para +'  <p>'
para = para +'  <table align=center border=1>'
para = para +'  <tr><th colspan=2 bgcolor=gold>Ownership</th></tr>'
para = para +'  <tr><th> -    <td>Public (any computer could create)</th></tr>'
para = para +'  <tr><th> *    <td>Personal climate (your computer created)</th></tr>'
para = para +'  <tr><th>&nbsp;<td>Standard-issue climate</th></tr>'
para = para +'  </table>'

para = para +'<p>'
para = para +'  <table align=center border=1>'
para = para +'  <tr><th colspan=2 bgcolor=gold>Status</th></tr>'
para = para +'  <tr><th> +    <td>Parameters have been changed from standard-issue</th></tr>'
para = para +'  <tr><th>&nbsp;<td>Unchanged from distribution</th></tr> '
para = para +'  </table>'
para = para + '<br>'
para = para +'Several climates (Birmingham, AL; Flagstaff, AZ; Mount Shasta, CA; '
para = para +'Denver, CO; Moscow, ID; and Charleston, WV) are listed in the climate list as stock '
para = para +'climates. '
para = para +'These climates are provided to allow the user to quickly select a regional climate for an '
para = para +'initial run.  '

para = para +'<p>'
para = para +'Most users will prefer to click the '
para = para +' <input type="submit" value="Custom Climate" disabled> '
para = para +'button and use the Rock:Clime weather generator to select desired climates from the '
para = para +'2,600 sets of climate statistics in the database.  '
para = para +'<p>'
para = para +'Users may select several nearby climates to determine the sensitivity of '
para = para +'their site to climate effects.  '
      }
      if (what == 'gradient') {
para='<h3>Gradient</h3>'
      }
      else if (what == 'soil_texture') {
para ='   <h3>Soil Texture</h3>'
para = para +'  The erosion potential of a given soil depends on the vegetation cover, the surface residue cover,'
para = para +'   the soil texture, and other soil properies that influence soil strength.'
para = para +'   <br><br>'
para = para +'   Because research in forest and range conditions is limited and data are not available to support a detailed database,'
para = para +'   only four soil textures (sand, silt, clay, and loam) are listed for <b><i>Disturbed WEPP.</i></b>'
para = para +'   <br><br>'
para = para +'   <a href="#table2">Table&nbsp;2</a> can aid in selecting the desired soil texture.  The specific soil'
para = para +'   properties associated with each selection can be seen by selecting the desired soil and vegetation,'
para = para +'   and clicking the Soil Texture title.  As new information is accumulated, the values of the soil parameters'
para = para +'   and new soil options may be added to the database.'
para = para +'   <br><br>'
para = para +'   To fully describe each set of soils for WEPP requires 24 soil parameter values.'
para = para +'   Further details describing these parameters are available in the WEPP Technical Documentation (<a href="#Alberts">Alberts and others 1995</a>).'
para = para +'   <a name="table2"></a>'
para = para +'   <blockquote>'
para = para +'    <table border=1>'
para = para +'     <tr>'
para = para +'      <caption align=left><b>Table 2. <i>Categories of Common Forest Soils in relation to Disturbed WEPP soils</i></caption>'
para = para +'      <tr>'
para = para +'       <th bgcolor=85d2d2>Soil type</th>'
para = para +'       <th bgcolor=85d2d2>Soil Description</th>'
para = para +'       <th bgcolor=85d2d2>Universal Soil Classification</th>'
para = para +'      </tr>'
para = para +'      <tr>'
para = para +'       <th>Clay loam</th>'
para = para +'       <td>Soils derived from shales, limestone and similar decomposing fine-grained sedimentary rock.'
para = para +'           <br>Lakebeds and similar areas of ancient lacustrian deposits</td>'
para = para +'       <td>CH</td>'
para = para +'      </tr>'
para = para +'       <tr>'
para = para +'       <th>Silt loam</th>'
para = para +'       <td>Ash cap and loess soils, soils derived from siltstone or similar sedimentary rock'
para = para +'           <br>Highly-erodible mica/schist geologies</td>'
para = para +'       <td>ML,CL</td>'
para = para +'      </tr>'
para = para +'      <tr>'
para = para +'       <th>Sandy loam</th>'
para = para +'       <td>Glacial outwash areas; decomposed granites and sand stone, and sand deposits</td>'
para = para +'       <td>GP, GM, SW, SP</td>'
para = para +'     </tr>'
para = para +'     <tr>'
para = para +'      <th>Loam</th>'
para = para +'      <td>Glacial tills, alluvium</td>'
para = para +'      <td>GC, SM, SC, MH</td>'
para = para +'     </tr>'
para = para +'    </table>'
      }
      else if (what == 'gradient') {
para='<h3>Gradient</h3>';
      }
      else if (what == 'cover') {
para='<h3>Cover</h3>';
      }
      else if (what == 'restrictive_layer') {
para = '<h3>Restrictive layer</h3>'
para = para +'    Click the checkbox next to "Restrictive layer" to specify the name of the bedrock that forms'
para = para +'    the soil\'s restrictive layer.'
para = para +'    Suggested values for that rock type will be displayed for saturated hydraulic conductivity.'
para = para +'    <br><br>'
para = para +'    If the Restriction checkbox is unchecked, then a restrictive layer is not present and the old'
para = para +'    (standard) soil input is used.';
      }
      else if (what == 'vegetation_treatment') {
para = '  <h3>Vegetation Treatment</h3>';
para = para +'   There are eight categories of vegetation or treatment.';
para = para +'   A default cover is associated with each vegetation treatment, but users are encouraged to alter this value to suit site conditions.  The vegetation treatments are:';
para = para +'   <ul>';
para = para +'    <li>	Twenty-year old forest</li>';
para = para +'    <li>	Five-year old forest</li>';
para = para +'    <li>	Shrub dominated rangeland</li>';
para = para +'    <li>	Tall-grass dominated rangeland</li>';
para = para +'    <li>	Short-grass dominated rangeland</li>';
para = para +'    <li>	Low severity fire</li>';
para = para +'    <li>	High severity fire</li>';
para = para +'    <li>	Skid trail</li>';
para = para +'   </ul>';
para = para +'   These categories can describe a wide range of forest and rangeland conditions. '
para = para +'   Table 3 provides a description of each vegetation treatment. '
para = para +'   The selection of a given vegetation treatment alters these key input values for the WEPP model:'
para = para +'   <ul>'
para = para +'    <li>	Plant height, spacing, leaf area index and root depth</li>'
para = para +'    <li>	Percent of live biomass remaining after vegetation</li>'
para = para +'    <li>	Soil rill and interrill erodibility and hydraulic conductivity</li>'
para = para +'    <li>	Default radiation energy to biomass conversion ratio</li>'
para = para +'   </ul>'
para = para +'   The user has the option to alter the desired amount of cover, which increases the range of conditions '
para = para +'   that can be described (Examples 4 and 5). '
para = para +'   <b><i>Disturbed WEPP</i></b> is very sensitive to cover, so this value should be carefully selected.'
para = para +'   The user may wish to consider several cover amounts to understand the impacts of varying cover on the' 
para = para +'   resulting soil erosion.'
para = para +'   <br><br>'
para = para +'   <a name="table3">'
para = para +'   <table border=1>'
para = para +'    <caption align="left"><b>Table 3. <i>Vegetation treatment options in the Disturbed WEPP interface</b></caption>'
para = para +'    <tr>'
para = para +'     <th bgcolor=85d2d2>Vegetation Treatment<th bgcolor=85d2d2>Description</th>'
para = para +'    </tr>'
para = para +'    <tr>'
para = para +'     <td>Twenty-year old forest</td>'
para = para +'     <td>Any well-established forest with trees spaced about 2&nbsp;m apart, about 5&nbsp;m tall or taller.'
para = para +'         Ground is completely covered with a substantial layer of forest duff.</td>'
para = para +'    </tr>'
para = para +'    <tr>'
para = para +'     <td>Five-year old forest</td>'
para = para +'     <td>A vegetation that has become sufficiently well established to generate 100&nbsp;percent ground cover.'
para = para +'	May be a reasonable estimate of a clear-cut forest between skid trails, where there is a '
para = para +'	considerable amount of brush, grass, or young trees remaining after harvest to maintain '
para = para +'	soil residue cover.</td>'
para = para +'    </tr>'
para = para +'    <tr>'
para = para +'     <td>Shrub-dominated rangeland</td>'
para = para +'     <td>Areas of shrubs with soil covered with residue beneath shrubs, and gaps between shrubs '
para = para +'	with minimal ground cover.'
para = para +'	Plants are about 1.2&nbsp;m tall, with a 0.5&nbsp;m spacing.'
para = para +'	The percent cover entered is an indication of the percent of the canopy or ground cover by the vegetation.'
para = para +'	Examples of this vegetation may be sage-dominated rangeland, or sparsely vegetated pinyon-juniper'
para = para +'	communities.'
para = para +'	This treatment may also be a reasonable estimate of a harvested forest 3&nbsp;years after harvest'
para = para +'	and prescribed burn, or a forest 4&nbsp;years after a severe wild fire.</td>'
para = para +'    <tr>'
para = para +'     <td>Tall grass prairie</td>'
para = para +'     <td>Areas covered by tall bunch grasses, with gaps between bunches.'
para = para +'	Plants are about 0.6&nbsp;m tall and 0.3&nbsp;m average spacing.'
para = para +'	The percent cover entered is an indication of the percent of the canopy or ground covered'
para = para +'	by the vegetation.<br>'
para = para +'	This vegetation treatment would best describe blue-stem or similar range communities in the west,'
para = para +'	or ryegrass, brome, or orchard grass pastures in the east.'
para = para +'	It may also describe post-fire conditions where wheat or oats have germinated to provide '
para = para +'	post-fire erosion mitigation.<br>'
para = para +'	This treatment may also be a reasonable estimate of a harvested forest 2&nbsp;years after a '
para = para +'	prescribed burn, or 3&nbsp;years after a wild fire.</td>'
para = para +'    <tr>'
para = para +'     <td>Short-grass prairie</td>'
para = para +'     <td>Areas covered by short sod-forming grasses.<br>'
para = para +'	Plants are about 0.4&nbsp;m tall and with an average spacing of 0.2&nbsp;m.'
para = para +'	The percent cover entered is an indication of the percent canopy or ground covered by the vegetation.'
para = para +'	This vegetation treatment would best describe buffalo grass or similar sodding grasses in the west,'
para = para +'	or Kentucky bluegrass in the east.<br>'
para = para +'	It may also best describe sparsely-covered reclaimed mine lands.'
para = para +'	This treatment may best describe forest conditions 1&nbsp;year after a prescribed fire'
para = para +'	or two years after a wild fire.</td>'
para = para +'    <tr>'
para = para +'     <td>Low-severity fire</td>'
para = para +'     <td>condition describes areas that have either had a low-severity fire,'
para = para +'	or a successful prescribed fire.<br>'
para = para +'	Vegetation is assumed to reach an maximum height of 0.2&nbsp;m and at a spacing of 0.2&nbsp;m.'
para = para +'	This is probably the most appropriate treatment to describe a sparsely vegetated, '
para = para +'	newly exposed surface following excavation where material has not been highly compacted, '
para = para +'	such as a road cut.</br>'
para = para +'	The user enters an estimate of the vegetated cover, which may be zero.'
para = para +'	This treatment may best describe forest conditions the year of a prescribed fire, or '
para = para +'	conditions 1&nbsp;year after a wild fire.<br>'
para = para +'	If there has been a high severity fire, and the soils are NOT hydrophobic, '
para = para +'	this is probably the best selection, but with a cover reduced to 15&nbsp;percent, or that '
para = para +'	observed on the site.</td>'
para = para +'    <tr>'
para = para +'     <td>High-severity fire</td>'
para = para +'     <td>This condition describes areas that have experienced a high-severity fire and soils '
para = para +'	are hydrophobic (or water repellant).'
para = para +'	Vegetation is assumed to reach a maximum height of 0.15&nbsp;m with a spacing of 0.15&nbsp;m.</td>'
para = para +'    <tr>'
para = para +'     <td>Skid trail'
para = para +'     <td>This condition describes a skid trail with vegetation reaching a maximum height of '
para = para +'	0.15&nbsp;m at a 0.1&nbsp;m spacing.<br>'
para = para +'	The soil is assumed to be compacted.<br>'
para = para +'	This treatment would also describe any site mechanically disturbed and compacted'
para = para +'	--as long as the user estimates the amount of cover--such as landings, forwarder tracks, '
para = para +'	skyline paths, etc.<br>'
para = para +'	If the soils remain compacted during the regeneration period, then the user is advised '
para = para +'	to use the skid trail for the first five years of regeneration, '
para = para +'	using increasing amounts of cover to describe local conditions.<br>'
para = para +'	The time required to achieve 100&nbsp;percent cover may be as short as 2&nbsp;years'
para = para +'	in Eastern forests.</td>'
para = para +'      </tr>'
para = para +'    </table>'
para = para +''
para = para +'    <h4>Predicting erosion from regeneration</h4>'
para = para +'    After a disturbance in a forest, the vegetation regenerates.  The vegetation treatments in <b><i>Disturbed WEPP</i></b>'
para = para +'    allow users to analyze the erosion in the years following regeneration.  Table 4 provides a guideline to'
para = para +'    selecting out-year vegetation treatments to determine the risk of erosion following disturbances.  '
para = para +'    Example 3 shows how to estimate erosion over an extended period of time for a forest recovering from harvesting.'
para = para +'   <blockquote>'
para = para +'    <table border=1>'
para = para +'     <caption align=left><b>Table 4. <i>Suggested vegetation to estimate soil erosion in the years following a disturbance</i></caption>'
para = para +'     <tr>'
para = para +'      <th ROWSPAN=2 bgcolor=85d2d2>Years after<br>disturbance</th>'
para = para +'      <th colspan=3 bgcolor=85d2d2>Disturbance</th>'
para = para +'     </tr>'
para = para +'     <tr>'
para = para +'      <th bgcolor=85d2d2>Forest harvest and prescribed burn</th>'
para = para +'      <th bgcolor=85d2d2>Wild fire</th>'
para = para +'      <th bgcolor=85d2d2>Range fire</th>'
para = para +'     </tr>'
para = para +'     <tr>'
para = para +'      <th>0</td>'
para = para +'      <td>Low severity fire</td>'
para = para +'      <td>High severity fire</td>'
para = para +'      <td>High severity fire</td>'
para = para +'     </tr>'
para = para +'     <tr>'
para = para +'      <th>1</th>'
para = para +'      <td>Short grass</td>'
para = para +'      <td>Low severity fire</td>'
para = para +'      <td>Low severity fire with observed cover</td>'
para = para +'     </tr>'
para = para +'     <tr>'
para = para +'      <th>2</th>'
para = para +'      <td>Tall grass</td>'
para = para +'      <td>Short grass</td>'
para = para +'      <td>Short grass with observed cover</td>'
para = para +'     </tr>'
para = para +'     <tr>'
para = para +'      <th>3</th>'
para = para +'      <td>Shrub</td>'
para = para +'      <td>Tall grass</td>'
para = para +'      <td>Increase amount of cover for short grass</td>'
para = para +'     </tr>'
para = para +'     <tr>'
para = para +'      <th>4</th>'
para = para +'      <td>Five-year-old forest</td>'
para = para +'      <td>Shrub</td>'
para = para +'      <td>Change to tall grass if appropriate and specify amount of cover</td>'
para = para +'     </tr>'
para = para +'     <tr>'
para = para +'      <th>5 to 15 years</th>'
para = para +'      <td>Five-year-old forest</td>'
para = para +'      <td>Five-year-old forest</td>'
para = para +'      <td>Change to tall grass if appropriate and specify amount of cover</td>'
para = para +'     </tr>'
para = para +'     <tr>'
para = para +'      <th>More than 15 years</th>'
para = para +'      <td>Twenty-year-old forest</td>'
para = para +'      <td>Twenty-year-old forest</td>'
para = para +'      <td>Change to tall grass if appropriate and specify amount of cover</td>'
para = para +'     </tr>'
para = para +'    </table>'
para = para +'   </blockquote>';
      }
      else if (what == 'rock') {
para = '  <h3>Rock</h3>'
para = para +'   Rock fragments in WEPP are considered rocks in the soil. As such, WEPP'
para = para +'   assumes that as water moves through soil, it must flow around the rocks.'
para = para +'   Therefore, WEPP reduces the hydraulic conductivity of the soil in direct'
para = para +'   proportion to the rock content (i.e. 20 percent rock will reduce the'
para = para +'   hydraulic conductivity by 20 percent).  WEPP will not accept a value for'
para = para +'   rock content higher than 50 percent, so even when the user puts 100'
para = para +'   percent rock into the rock content box, WEPP assumes that it is only 50'
para = para +'   percent.  In this context, as rock content increases up to 50 percent,'
para = para +'   runoff increases, as does rill erosion.  Above 50 percent, there is no'
para = para +'   further impact modeled from increased rock content.'
para = para +'   <br><br>'
para = para +'   Any surface rocks need to be accounted for in the surface cover.  For'
para = para +'   example, if after a fire there is 50 percent surface cover remaining from'
para = para +'   vegetation, and 20 percent of the bare soil is covered with rock, the'
para = para +'   correct surface cover including vegetation and rock is 60 percent (50'
para = para +'   percent vegetation + 20 percent rock * 50 percent bare).  In this context,'
para = para +'   as surface cover due to rock increases, the cover should be increased;'
para = para +'   both runoff and erosion will be reduced.  '
para = para +'   <br><br>'
para = para +'   Our interface currently does not automatically add rock content to surface'
para = para +'   cover, as there are cases where that may be inappropriate.'
      }
      previous_what=what
      document.getElementById("help_text").innerHTML = '<div align=left><hr>[<a href="javascript:hide_help()">hide</a>]<br><br>' + para +'<hr></div>';
    }

    function hide_help() {
//    alert('hide_help')
      previous_what=''
      document.getElementById("help_text").innerHTML = '';
    }

function popuphistory() {
url = '';
height=500;
width=660;
popupwindow = window.open(url,'popupwindow','toolbar=no,location=no,status=no,directories=no,menubar=no,scrollbars=yes,resizable=yes,width='+width+',height='+height);

popupwindow.document.writeln('<html>')
popupwindow.document.writeln(' <head>')
popupwindow.document.writeln('  <title>Forest Service Water And Sediment Predictor Input Screen version history</title>')
popupwindow.document.writeln(' </head>')
popupwindow.document.writeln(' <body bgcolor=white>')
popupwindow.document.writeln('  <font face="arial, helvetica, sans serif">')
popupwindow.document.writeln('  <center>')
popupwindow.document.writeln('   <h3>Forest Service Water And Sediment Predictor Input Screen Version History</h3>')

popupwindow.document.writeln(' </body>')
popupwindow.document.writeln('</html>')
popupwindow.document.close()
popupwindow.focus()
}

  function checkeverything() {
//    if (checkYears(this.form.climyears)) {			//	this.form has no properties
//      RunningMsg(this.form.actionw,"Running WEPP...");	//	2004.12.20 DEH
//      this.form.achtung.value="Run WEPP"
    if (checkYears(document.forms.weppdist.climyears)) {
      RunningMsg(document.forms.weppdist.actionw,"Running WEPP...");
      document.forms.weppdist.achtung.value="Run WEPP"
    }
  }

  function submitme(which) {
    document.forms.weppdist.achtung.value=which
//    document.forms.weppdist.submit.value="Describe"
    document.forms.weppdist.submit()
    return true
  }

  function isNumber(inputVal) {
  // Determine whether a suspected numeric input
  // is a positive or negative number.
  // Ref.: JavaScript Handbook. Danny Goodman. listing 15-4, p. 374.
  oneDecimal = false                              // no dots yet
  inputVal2=inputVal*1;				  // force to decimal/numeric (out of scientific notation)
// alert(inputVal2)
  inputStr = "" + inputVal2                       // force decimal? to string
  for (var i = 0; i < inputStr.length; i++) {     // step through each char
    var oneChar = inputStr.charAt(i)              // get one char out
    if (i == 0 && oneChar == "-") {               // negative OK at char 0
      continue
    }
    if (oneChar == "." && !oneDecimal) {
      oneDecimal = true
      continue
    }
    if (oneChar < "0" || oneChar > "9") {
      return false
    }
  }
  return true
  }

  function MakeArray(n) {     // initialize array of length *n* [Goodman p
    this.length = n; for (var i = 0; i<n; i++) {this[i] = 0} return this
  }

theEnd
print "function StartUp() {\n";
#print "    max_year = new MakeArray($num_cli);\n\n";
print "    climate_name = new MakeArray($num_cli);\n";

  for $ii (0..$num_cli) {
#    print "    max_year[$ii] = " . $climate_year[$ii] . ";\n";
    print "    climate_name[$ii] = ",'"',$climate_name[$ii],'"',"\n";
  }
print <<'theEnd';
//    window.document.weppdist.Climate.selectedIndex = 0;
//    window.document.weppdist.climyears.value = max_year[0];

    default_pcover = new MakeArray(7);
//    default_pcover[0] = 2;	// forest road
    default_pcover[7] = 10;	// skid trail
//    default_pcover[6] = 15;	// high fire       DEH 06/07/2000
//    default_pcover[5] = 50;	// low fire        DEH 06/07/2000
    default_pcover[6] = 45;	// high fire
    default_pcover[5] = 85;	// low fire
    default_pcover[4] = 40;	// short grass
    default_pcover[3] = 60;	// tall grass
    default_pcover[2] = 80;	// shrub
    default_pcover[1] = 100;	// trees 5 year
    default_pcover[0] = 100;	// trees 20 year
//   window.document.weppdist.ofe1.selectedIndex = 0;
//   window.document.weppdist.ofe2.selectedIndex = 7;
    if (window.document.weppdist.Climate.selectedIndex == "") {
        window.document.weppdist.Climate.selectedIndex = 0;
    }
    climYear();
  }

  function pcover1() {        // change ofe1 pcover to default for selected
    var which = window.document.weppdist.UpSlopeType.selectedIndex;
    window.document.weppdist.ofe1_pcover.value=default_pcover[which];
    return false;
  }

  function pcover2() {        // change ofe2 pcover to default for selected
    var which = window.document.weppdist.LowSlopeType.selectedIndex;
    window.document.weppdist.ofe2_pcover.value=default_pcover[which];
    return false;
  }

  function climYear() {        // change climate years to max for selected
    var which = window.document.weppdist.Climate.selectedIndex;
//    window.document.weppdist.climyears.value=max_year[which];
    window.document.weppdist.climate_name.value=climate_name[which];
//    var vegyear=Math.min (max_year[which],10);
//    var simyear=Math.min (max_year[which],100);
//    window.document.weppdist.actionv.value=vegyear + "vegetation calibration";
//    window.document.weppdist.actionw.value=simyear + "WEPP run";
//    window.document.weppdist.actionv.value="vegetation calibration";
//    window.document.weppdist.actionw.value="WEPP run";
    window.document.weppdist.achtung.value="Calibrate vegetation";
    window.document.weppdist.achtung.value="WEPP run";
    return false;
  }
function RunningMsg (obj, text) {
       obj.value=text
}

  function checkRange(obj,min,max,def,unit,thistext) {
     if (isNumber(obj.value)) {                   // obj == document.weppdist.BS
       if (obj.value < min) {                     // min == BSmin
         alert_text=thistext + " must be between " + min + " and " + max + unit
         obj.value=min
         alert(alert_text)
       }
       if (obj.value > max){
         alert_text=thistext + " must be between " + min + " and " + max + unit
         obj.value=max
         alert(alert_text)
       }
     } else {
         obj.value=def
         alert("Invalid entry for " + thistext + "!")
       }
  }

function blankStatus()
{
  window.status = ""
  return true                           // p. 86
}

  function checkConduct(obj) {
     if (isNumber(obj.value)) {
//     alert('OK')
     }
     else {
       alert('Nope')
       obj.value=0
     }
  }

  function checkAniso(obj) {
     if (isNumber(obj.value)) {
//     alert('OK')
     }
     else {
       alert('Nope')
       obj.value=25
     }
  }

  function checkYears(obj) {
     if (isNumber(obj.value)) {
       obj.value = Math.round(obj.value)
       var alert_text = "Number of years must be between " + minyear + " and " + maxyear 
       if (obj.value < minyear){
         alert(alert_text)
         obj.value=minyear
         return false
       }
       if (obj.value > maxyear) {
         alert(alert_text)
         obj.value=maxyear
         return false
       }
     } else {
         alert("Invalid entry " + obj.value + " for number of years! Using " + minyear)
         obj.value=minyear
         return false
       }
  }

function showRange(obj, head, min, max, unit)
{
  range = head + min + " to " + max + unit	
  window.status = range
  return true                           // p. 86
}

function showHelp(obj, head, min, max, unit)
{
  var which = window.document.weppdist.SlopeType.selectedIndex;
     if (which == 0) {vhead = "Ditch width + traveledway width: "}
     else if (which == 1) {vhead = "Ditch width + traveledway width: "}
     else if (which == 2) {vhead = "Traveledway width: "}
     else {vhead = "Rut spacing + rut width: "}
  range = vhead + min + " to " + max + unit	
  window.status = range
  return true                           // p. 86
}

function showTexture() {
  var which = window.document.weppdist.SoilType.selectedIndex;
  if (which == 0) {text = "Native-surface roads on shales and similar decomposing sedimentary rock (MH, CH)"}            //clay loam
   else if (which == 2) {text = "Ash cap native-surface road; alluvial loess native-surface road (ML, CL)"}      // silt loam
   else if (which == 1) {text = "Glacial outwash areas; finer-grained granitics (SW, SP, SM, SC)"}      // sandy loam
   else {text = "Loam"}                      // loam
   window.status = text
   return true                           // p. 86
}

function showGeology() {
  
  var which = window.document.weppdist.RockName.selectedIndex;
  if (lunit == ' m') {
    if (which == 0)      {text = "karst and reef limestone"; shc='3.60E-01'}
    else if (which == 1) {text = "limestone, dolomite"; shc='3.60E-04'}
    else if (which == 2) {text = "sandstone"; shc='9.00E-05'}
    else if (which == 3) {text = "salt"; shc='3.60E-08'}
    else if (which == 4) {text = "anhydrite"; shc='3.60E-07'}
    else if (which == 5) {text = "siltstone"; shc='3.60E-07'}
    else if (which == 6) {text = "shale"; shc='3.60E-08'}
    else if (which == 7) {text = "permeable basalt"; shc='3.60E-01'}
    else if (which == 8) {text = "fractured igneous and metamorphic rock"; shc='3.60E-03'}
    else if (which == 9) {text = "decomposed granite"; shc='3.60E-03'}
    else if (which == 10){text = "weathered gabbro"; shc='3.60E-04'}
    else if (which == 11){text = "basalt"; shc='3.60E-06'}
    else if (which == 12){text = "unfractured igneous and metamorphic rock"; shc='3.60E-07'}
    else if (which == 13){text = "user-defined"}
  }
  if (lunit == ' ft') {
    if (which == 0)      {text = "karst and reef limestone"; shc='1.42E-02'}
    else if (which == 1) {text = "limestone, dolomite"; shc='1.42E-05'}
    else if (which == 2) {text = "sandstone"; shc='3.54E-06'}
    else if (which == 3) {text = "salt"; shc='1.42E-09'}
    else if (which == 4) {text = "anhydrite"; shc='1.42E-08'}
    else if (which == 5) {text = "siltstone"; shc='1.42E-08'}
    else if (which == 6) {text = "shale"; shc='1.42E-09'}
    else if (which == 7) {text = "permeable basalt"; shc='1.42E-02'}
    else if (which == 8) {text = "fractured igneous and metamorphic rock"; shc='1.42E-04'}
    else if (which == 9) {text = "decomposed granite"; shc='1.42E-04'}
    else if (which == 10){text = "weathered gabbro"; shc='1.42E-05'}
    else if (which == 11){text = "basalt"; shc='1.42E-07'}
    else if (which == 12){text = "unfractured igneous and metamorphic rock"; shc='1.42E-08'}
    else if (which == 13){text = "user-defined"}
  }
  window.status = text
  document.forms.weppdist.conduct.value=shc
  return true
}

function checkRestriction() {
   var Restricted = window.document.weppdist.restriction.checked;
//   alert ("restriction: " + Restricted);
   if (Restricted) {
     window.document.weppdist.RockName.disabled=0
     window.document.weppdist.aniso.disabled=0
     window.document.weppdist.conduct.disabled=0
     window.document.weppdist.climyears.disabled=1
     showGeology()
     e=document.getElementById("rest");
     e.style.background = "tan";
     e.style.color = "black";
   }
   else {
     window.document.weppdist.RockName.disabled=1
     window.document.weppdist.aniso.disabled=1
     window.document.weppdist.conduct.disabled=1
     window.document.weppdist.climyears.disabled=0
     e=document.getElementById("rest");
     e.style.background = "white";
     e.style.color = "gray";
   }
}

  // end hide -->
  </SCRIPT>
 </head>
theEnd
print ' <BODY bgcolor="white" link="#555555" vlink="#555555" onLoad="StartUp()">
  <font face="Arial, Geneva, Helvetica">
   <span style="position: absolute; left: 5; top: 5">
    <a href="/fswepp/"><img src="/fswepp/images/fsweppic2.jpg" width=75 height=75 align="left" alt="Back to FS WEPP menu" border=0></a>
   </span>
   <table width=100% border=0>
    <tr>
     <td align=center bgcolor="#5cb3ff">
      <font size=3><b>WASP -- Water And Sediment Predictor</b></font>
     </td>
    </tr>
   </table>
  <center>
   <FORM name="weppdist" method="post" ACTION="http://',$wepphost,'/cgi-bin/fswepp/wd/ww.pl">
   <input type="hidden" size="1" name="me" value="',$me,'">
   <input type="hidden" size="1" name="units" value="',$units,'">
   <TABLE border="1">
';
print <<'theEnd';
     <tr align="top">
      <td valign="top" align="center" bgcolor="#5cb3ff">
       <b>
        <a href="JavaScript:submitme('Describe Climate')"
           onMouseOver="window.status='Describe climate';return true"
           onMouseOut="window.status='Forest Service Forest Service Water And Sediment Predictor'; return true">Climate</b></a>
           <a href="JavaScript:show_help('climate')" title="*: personal climate; +: modified climate"><img src="/fswepp/images/quest_b.gif" border=0 name="clim_quest"></a>
      </td>
      <td align="center" bgcolor="#5cb3ff">
            <a href="JavaScript:submitme('Describe Soil')"
               onMouseOver="window.status='Describe soil';return true"
               onMouseOut="window.status='Forest Service Water And Sediment Predictor'; return true"><b>Geology/Soil</b></a>
       <b><br>
      </td>
     </tr>
     <tr>
      <td valign="top" align="center" bgcolor="tan">
       <SELECT NAME="Climate" SIZE="8">
theEnd

### display personal climates, if any

    if ($num_cli > 0) {
      print '       <OPTION VALUE="';
      print $climate_file[0];
      print '" selected> ', $climate_name[0] , "\n";
    }
    for $ii (1..$num_cli) {
      print '       <OPTION VALUE="';
      print $climate_file[$ii];
      print '"> ', $climate_name[$ii] , "\n";
    }

#################
print <<'theEnd';
       </SELECT>
       <br>
        <input type="hidden" name="achtung" value="Run WEPP">
        <input type="SUBMIT" name="actionc" value="Custom Climate">
       </td>

       <td align="center" valign="top">
        <table border=1>
         <tr>
          <td valign="top" align="center" bgcolor="tan">
           <div id="geol" style="background:tan">
            <b>Texture</b>
             <a href="JavaScript:show_help('soil_texture')"
                 onMouseOver="window.status='Explain soil texture';return true"
                 onMouseOut="window.status='Forest Service Water And Sediment Predictor'; return true"><img src="/fswepp/images/quest_b.gif" border=0 name="soil_quest"></a>
            <br>
            <SELECT NAME="SoilType" SIZE="4" onChange="showTexture()" onBlur="blankStatus()">
             <OPTION VALUE="clay" selected>clay loam
             <OPTION VALUE="silt">silt loam
             <OPTION VALUE="sand">sandy loam
             <OPTION VALUE="loam">loam
            </SELECT>
            <br>
           </div>
          </td>
          <td valign="top" align="center">
           <div id="rest" style="background:white">
            <input type=checkbox name="restriction" value="restricted" onClick="checkRestriction()">&nbsp;<b>Restrictive layer</b></a>
            <a href="JavaScript:show_help('restrictive_layer')"
               onMouseOver="window.status='Explain restriction';return true"
               onMouseOut="window.status='Forest Service Water And Sediment Predictor';return true"><img src="/fswepp/images/quest_b.gif" border=0 name="rest_quest"></a>
            <br>
            <SELECT NAME="RockName" SIZE="5" disabled onChange="showGeology()" onBlur="blankStatus()">
             <OPTION VALUE="decomposed granite" selected>decomposed granite
             <OPTION VALUE="permeable basalt">permeable basalt
             <OPTION VALUE="fractured igneous and metamorphic">fractured igneous and metamorphic
             <OPTION VALUE="weathered gabbro">weathered gabbro
             <OPTION VALUE="basalt">basalt
             <OPTION VALUE="karst and reef limestone">karst and reef limestone
             <OPTION VALUE="limestone, dolomite">limestone, dolomite
             <OPTION VALUE="sandstone">sandstone
             <OPTION VALUE="salt">salt
             <OPTION VALUE="anhydrite">anhydrite
             <OPTION VALUE="siltstone">siltstone
             <OPTION VALUE="shale">shale
             <OPTION VALUE="unfractured igneous and metamorphic">unfractured igneous and metamorphic
             <OPTION VALUE="user-defined">user-defined
            </SELECT>
            <br>
            <table border=0>
             <tr>
              <td align=left>
               <a onMouseOver="window.status='Anisotropy ratio (horizontal versus vertical)';return true"
                  onMouseOut="window.status='Forest Service Water And Sediment Predictor';return true">Anisotropy ratio</a>
              </td>
              <td>
               <input type="text" size=6 name="aniso" value=25 disabled> (h:v)
              </td>
             </tr>
             <tr>
              <td>
               <a onMouseOver="window.status='Saturated hydraulic conductivity of the restrictive layer';return true"
                  onMouseOut="window.status='Forest Service Water And Sediment Predictor';return true">Conductivity</a>
              </td>
              <td>
               <input type="text" size=6 name="conduct" disabled
                onChange="checkConduct(this.form.conduct)"> ($cunit)
              </td>
             </div>
            </td>
           </tr>
          </table>
         </td>
        </tr>
       </table>
      </td>
     </tr>
    </table>


 <table width=90% border=0 bgcolor="#FAF8CC">
  <tr>
   <td>
    <font size=-1 id='help_text'>
    </font>
   </td>
  </tr>
 </table>

         <table border=2>
          <tr>
           <th bgcolor=#5cb3ff><font face="Arial, Geneva, Helvetica">Element</font></th>
           <th bgcolor=#5cb3ff>
            <font face="Arial, Geneva, Helvetica">Treatment
             <a href="JavaScript:show_help('vegetation_treatment')"
               onMouseOver="window.status='Explain treatment';return true"
               onMouseOut="window.status='Forest Service Water And Sediment Predictor';return true"><img src="/fswepp/images/quest_b.gif" border=0 name="treat_quest" align=right></a>
            </font></th>
           <th bgcolor=#5cb3ff>
            <font face="Arial, Geneva, Helvetica">Gradient<br>(%)
             <a href="JavaScript:show_help('gradient')"
               onMouseOver="window.status='Explain gradient';return true"
               onMouseOut="window.status='Forest Service Water And Sediment Predictor';return true"><img src="/fswepp/images/quest_b.gif" border=0 name="gradient_quest" align=right></a>
            </font>
           </th>
theEnd
print "    <th bgcolor=#5cb3ff><font face=\"Arial, Geneva, Helvetica\">Horizontal<br>Length ($units)</font></th>\n";
print <<'theEnd';
           <th bgcolor=#5cb3ff>
            <font face="Arial, Geneva, Helvetica">Cover<br>(%)
             <a href="JavaScript:show_help('cover')"
               onMouseOver="window.status='Explain cover';return true"
               onMouseOut="window.status='Forest Service Water And Sediment Predictor';return true"><img src="/fswepp/images/quest_b.gif" border=0 name="cover_quest" align=right></a>
            </font>
           </th>
           <th bgcolor=#5cb3ff>
            <font face="Arial, Geneva, Helvetica">Rock<br>(%)
             <a href="JavaScript:show_help('rock')"
               onMouseOver="window.status='Explain rock content';return true"
               onMouseOut="window.status='Forest Service Water And Sediment Predictor';return true"><img src="/fswepp/images/quest_b.gif" border=0 name="rock_quest" align=right></a>
            </font>
           </th>
theEnd
print "    <th bgcolor=#5cb3ff><font face=\"Arial, Geneva, Helvetica\">Depth<br> ($dunit)</font></th>\n";
print <<'theEnd';
           </th>
          </tr>
          <tr>
           <th rowspan=2 bgcolor=#5cb3ff><font face="Arial, Geneva, Helvetica">Upper</font></th>
           <td rowspan=2 bgcolor=tan>
            <SELECT NAME="UpSlopeType" SIZE="9" ALIGN="top" onChange="pcover1()";>
             <OPTION VALUE="tree20" selected> Twenty year old forest
             <OPTION VALUE="tree5"> Five year old forest
             <OPTION VALUE="shrub"> Shrubs
             <OPTION VALUE="tall">  Good Grass
             <OPTION VALUE="short"> Poor Grass
             <OPTION VALUE="low">   Low Severity Fire
             <OPTION VALUE="high">  High Severity Fire
             <OPTION VALUE="skid">  Skid trail
             <OPTION VALUE="skid">  ATV trail
            </SELECT>
           </td>
           <td bgcolor="tan">
            <input type="text" size=5 name="ofe1_top_slope" value="0"
             onChange="checkRange(ofe1_top_slope,smin,smax,ofe1tsdef,sunit,'Slope')"
             onFocus="showRange(this.form,'Slope: ',smin,smax,sunit)"
             onBlur="blankStatus()">
           </td>
           <td rowspan=2 bgcolor="tan">
            <input type="text" size=5 name="ofe1_length" value="50"
             onChange="checkRange(ofe1_length,lmin,lmax,ldef,lunit,'Upper element length')"
             onFocus="showRange(this.form,'Upper element length: ',lmin,lmax,lunit)"
             onBlur="blankStatus()">
           </td>
           <td rowspan=2 bgcolor="tan">
            <input type="text" size=5 name="ofe1_pcover" value="100"
             onChange="checkRange(ofe1_pcover,pcmin,pcmax,pcdef,pcunit,'Percent cover')"
             onFocus="showRange(this.form,'Percent cover: ',pcmin,pcmax,pcunit)"
             onBlur="blankStatus()">
           </td>
           <td rowspan=2 bgcolor="tan">
            <input type="text" size=5 name="ofe1_rock" value="20"
             onChange="checkRange(ofe1_rock,rmin,rmax,rdef,runit, 'Percent rock')"
             onFocus="showRange(this.form,'Percent rock: ',rmin,rmax,runit)"
             onBlur="blankStatus()">
           </td>
           <td rowspan=2 bgcolor="tan">
            <input type="text" size=5 name="ofe1_depth" value="400"
             onChange="checkRange(ofe1_depth,dmin,dmax,ddef,dunit,'Soil depth')"
             onFocus="showRange(this.form,'Soil depth: ',dmin,dmax,dunit)"
             onBlur="blankStatus()">
           </td>
          </tr>
          <tr>
           <td bgcolor="tan">
            <input type="text" size=5 name="ofe1_mid_slope" value="30"
             onChange="checkRange(ofe1_mid_slope,smin,smax,ofe1msdef,sunit,'Slope')"
             onFocus="showRange(this.form,'Slope: ',smin,smax,sunit)"
             onBlur="blankStatus()">
            </td>
           </tr>
           <tr>
            <th rowspan=2 bgcolor=#5cb3ff><font face="Arial, Geneva, Helvetica">Lower</th>
            <td rowspan=2>
             <SELECT NAME="LowSlopeType" SIZE="9" ALIGN="top" onChange="pcover2()";>
              <OPTION VALUE="tree20"> Twenty year old forest
              <OPTION VALUE="tree5" selected> Five year old forest
              <OPTION VALUE="shrub"> Shrubs
              <OPTION VALUE="tall"> Good Grass
              <OPTION VALUE="short"> Poor Grass
              <OPTION VALUE="low"> Low Severity Fire
              <OPTION VALUE="high"> High Severity Fire
              <OPTION VALUE="skid"> Skid trail
              <OPTION VALUE="skid"> ATV trail
             </SELECT>
            </td>
            <td bgcolor="tan">
             <input type="text" size=5 name="ofe2_top_slope" value="30"
              onChange="checkRange(ofe2_top_slope,smin,smax,ofe2tsdef,sunit,'Slope')"
              onFocus="showRange(this.form,'Slope range: ',smin,smax,sunit)"
              onBlur="blankStatus()">
            </td>
            <td rowspan=2 bgcolor="tan">
             <input type="text" size=5 name="ofe2_length" value="50"
              onChange="checkRange(ofe2_length,lmin,lmax,ldef,lunit,'Lower element length')"
              onFocus="showRange(this.form,'Lower element length: ',lmin,lmax,lunit)"
              onBlur="blankStatus()">
            </td>
            <td rowspan=2 bgcolor="tan">
             <input type="text" size=5 name="ofe2_pcover" value="100"
              onChange="checkRange(ofe2_pcover,pcmin,pcmax,pcdef,pcunit,'Percent cover')"
              onFocus="showRange(this.form,'Percent cover: ',pcmin,pcmax,pcunit)"
              onBlur="blankStatus()">
            </td>
            <td rowspan=2 bgcolor="tan">
             <input type="text" size=5 name="ofe2_rock" value="20"
              onChange="checkRange(ofe2_rock,rmin,rmax,rdef,runit,'Percent rock')"
              onFocus="showRange(this.form,'Percent rock: ',rmin,rmax,runit)"
              onBlur="blankStatus()">
            </td>
            <td rowspan=2 bgcolor="tan">
             <input type="text" size=5 name="ofe2_depth" value="600"
              onChange="checkRange(ofe2_depth,dmin,dmax,ddef,dunit,'Soil depth')"
              onFocus="showRange(this.form,'Soil depth: ',dmin,dmax,dunit)"
              onBlur="blankStatus()">
            </td>
           </tr>
           <tr>
            <td bgcolor="tan">
             <input type="text" size=5 name="ofe2_bot_slope" value="5"
              onChange="checkRange(ofe2_bot_slope,smin,smax,ofe2bsdef,sunit,'Slope')"
              onFocus="showRange(this.form,'Slope range: ',smin,smax,sunit)"
              onBlur="blankStatus()">
            </td>
           </tr>
          </table>
          <input type=hidden name="climate_name">
<!-- .... Summary output...
          <INPUT TYPE="CHECKBOX" NAME="Full" VALUE="1">Full output
          <INPUT TYPE="CHECKBOX" NAME="Slope" VALUE="1">Slope file input -->
          <!-- Years to simulate: -->
          <input type="hidden" size="3" name="climyears" value="100"
           onChange="checkYears(this.form.climyears)"
           onFocus="showRange(this.form,'Years to simulate: ',minyear, maxyear, '')"
           onBlur="blankStatus()">
           <br>
<!--<INPUT TYPE="SUBMIT" name="actionw" VALUE="Run WEPP"
    onClick='RunningMsg(this.form.actionw,"Running..."); this.form.achtung.value="Run WEPP"'>
-->
          <P>
           <INPUT TYPE="HIDDEN" NAME="Units" VALUE="m">
           <input type="SUBMIT" name="actionv" value="Calibrate vegetation"
            onClick='RunningMsg(this.form.actionv,"Calibrating vegetation..."); this.form.achtung.value="vegetation"'>
           <INPUT TYPE="SUBMIT" name="actionw" VALUE="Run WEPP"
            onClick='checkeverything()'>
<!--       onClick='RunningMsg(this.form.actionw,"Running WEPP..."); this.form.achtung.value="Run WEPP"'>
          <input type="button" value="Exit" onClick="window.close(self)">-->
          <BR>
         </center>
        </FORM>
        <P>
        <HR>
theEnd
print '
        <font size=-1>
         <a href="http://',$wepphost,'/fswepp/comments.html" ';
if ($wepphost eq 'localhost') {print 'onClick="return confirm(\'You must be connected to the Internet to e-mail comments. Shall I try?\')"'};
print '>
         <img src="http://',$wepphost,'/fswepp/images/epaemail.gif" align="right" border=0></a>
         Interface v. 
         <a href="javascript:popuphistory()">',$version,'</a>
         by
         David Hall, 
         Group Leader  Bill Elliot<BR>
  USDA Forest Service, Rocky Mountain Research Station, Moscow, ID<br>';
  $remote_host = $ENV{'REMOTE_HOST'};
  $remote_address = $ENV{'REMOTE_ADDR'};

#  $wc  = `wc ../working/wd.log`;
#  @words = split " ", $wc;
#  $runs = @words[0];

print "  $remote_host &ndash; $remote_address ($user_really) personality '<b>$me</b>'<br>
  <b>$runs</b>Forest Service Water And Sediment Predictor runs since May 1, 2009;
 </body>
</html>
";

# --------------------- subroutines

sub ReadParse {

# ReadParse -- from cgi-lib.pl (Steve Brenner) from Eric Herrmann's
# "Teach Yourself CGI Programming With PERL in a Week" p. 131

# Reads GET or POST data, converts it to unescaped text, and puts
# one key=value in each member of the list "@in"
# Also creates key/value pairs in %in, using '\0' to separate multiple
# selections

# If a variable-glob parameter...

  local (*in) = @_ if @_;
  local ($i, $loc, $key, $val);

  if ($ENV{'REQUEST_METHOD'} eq "GET") {
    $in = $ENV{'QUERY_STRING'};
  } elsif ($ENV{'REQUEST_METHOD'} eq "POST") {
    read(STDIN,$in,$ENV{'CONTENT_LENGTH'});
  }

  @in = split(/&/,$in);

  foreach $i (0 .. $#in) {
    # Convert pluses to spaces
    $in[$i] =~ s/\+/ /g;

    # Split into key and value
    ($key, $val) = split(/=/,$in[$i],2);  # splits on the first =

    # Convert %XX from hex numbers to alphanumeric
    $key =~ s/%(..)/pack("c",hex($1))/ge;
    $val =~ s/%(..)/pack("c",hex($1))/ge;

    # Associative key and value
    $in{$key} .= "\0" if (defined($in{$key}));  # \0 is the multiple separator
    $in{$key} .= $val;
  }
  return 1;
 }

sub make_history_popup {

  my $version;

# Reads parent (perl) file and looks for a history block:
## BEGIN HISTORY ####################################################
# WHRM Wildlife Habitat Response Model Version History

  $version='2005.02.08';        # Make self-creating history popup page
# $version = '2005.02.07';      # Fix parameter passing to tail_html; stuff after semicolon lost
#!$version = '2005.02.07';      # Bang in line says do not use
# $version = '2005.02.04';      # Clean up HTML formatting, add head_html and tail_html functions
#                               # Continuation line not handled
# $version = '2005.01.08';      # Initial beta release

## END HISTORY ######################################################

# and returns body (including Javascript document.writeln instructions) for a pop-up history window
# called pophistory.

# First line after 'BEGIN HISTORY' is <title> text
# Splits version and comment on semi-colon
# Version must be version= then digits and periods
# Bang in line causes line to be ignored
# Disallowed: single and double quotes in comment part
# Not handled: continuation lines

# Usage:

#print "<html>
# <head>
#  <title>$title</title>
#   <script language=\"javascript\">
#    <!-- hide from old browsers...
#
#  function popuphistory() {
#    pophistory = window.open('','pophistory','')
#";
#    print make_history_popup();
#print "
#    pophistory.document.close()
#    pophistory.focus()
#  }
#";

# print $0,"\n";

  my ($line, $z, $vers, $comment);

  open MYSELF, "<$0";
    while (<MYSELF>) {

      next if (/!/);

      if (/## BEGIN HISTORY/) {
        $line = <MYSELF>;
        chomp $line;
        $line = substr($line,2);
        $z = "    pophistory.document.writeln('<html>')
    pophistory.document.writeln(' <head>')
    pophistory.document.writeln('  <title>$line</title>')
    pophistory.document.writeln(' </head>')
    pophistory.document.writeln(' <body bgcolor=white>')
    pophistory.document.writeln('  <font face=\"trebuchet, tahoma, arial, helvetica, sans serif\">')
    pophistory.document.writeln('  <center>')
    pophistory.document.writeln('   <h4>$line</h4>')
    pophistory.document.writeln('   <br><br>')
    pophistory.document.writeln('   <table border=0 cellpadding=10>')
    pophistory.document.writeln('    <tr>')
    pophistory.document.writeln('     <th bgcolor=lightblue>Version</th>')
    pophistory.document.writeln('     <th bgcolor=lightblue>Comments</th>')
    pophistory.document.writeln('    </tr>')
";
      } # if (/## BEGIN HISTORY/)

      if (/version/) {
        ($vers, $comment) = split (/;/,$_);
        $comment =~ s/#//;
        chomp $comment;
        $vers =~ s/'//g;
        $vers =~ s/ //g;
        $vers =~ s/"//g;
        if ($vers =~ /version=*([0-9.]+)/) {    # pull substring out of a line
          $z .= "    pophistory.document.writeln('    <tr>')
    pophistory.document.writeln('     <th valign=top bgcolor=lightblue>$1</th>')
    pophistory.document.writeln('     <td>$comment</td>')
    pophistory.document.writeln('    </tr>')
";
        }       # (/version *([0-9]+)/)
     }  # if (/version/)

    if (/## END HISTORY/) {
        $z .= "    pophistory.document.writeln('   </table>')
    pophistory.document.writeln('   </font>')
    pophistory.document.writeln('  </center>')
    pophistory.document.writeln(' </body>')
    pophistory.document.writeln('</html>')
";
      last;
    }     # if (/## END HISTORY/)
  }     # while
  close MYSELF;
  return $z;
}
