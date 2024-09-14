#!/usr/bin/perl

#
#  Fuels planning:  Root Disease Analyzer: Armillaria Response Tool
#   Stand-Level Version
#   "Art-lite"
#

#  USDA Forest Service Rocky Mountain Research Station
#  Moscow Forestry Sciences Laboratory
#  Microbial Processes Project
#  Mee-Sook Kim, Tom Rice, Geral McDonald
#  with programming by David Hall (Soil & Water Engineering Project) and Tom Rice

#### BEGIN HISTORY #########################
# Armillaria Response Tool Lite version history
#   $version='2006.07.19';	# Remove "under construction" graphic call -- was 115468 Jun 28 2005 artlite.pl
   $version='2005.06.16';	# Add explanation about missing fire groups for individual habitat types<br>Add explanation for regions without a Fire Group Manual
#   $version='2005.06.15';	# Complete Wenatchee update<br>-- change manual citations for Wenatchee<br>-- add 45 habitat types<br>-- add 10 species codes to pop-up (move list to external file)
#				# replace "amplexfolius" with "amplexifolius"
#				# replace "Linnea" with "Linnaea"
#				# replace 'Pseusotsuga menziesii' with 'Pseudotsuga menziesii'
#`				# replace 'Agrospyron spicatum' with 'Agropyron spicatum
#				# replace 'carex geyeri' with 'Carex geyeri'
#   $version = '2005.04.01';	# Add special note for Wenatchee
#   $version = '2005.03.31';	# Fix North_UT<br>Adjust habitat type lookup table<br>Display treatment effects for low Armillaria risk
#   $version = '2005.03.30';	# Extend treatment effect results for all regions
#   $version = '2005.03.14';	# Update treatment effects for Montana, North Idaho<br>Correct text for THPL/ASCA-TABR
#   $version = '2005.03.10';	# Add reference for Fire Group information<br>Change species occurance table to HTML table
#   $version = '2005.03.09';	# Add documentation links and stubs
#   $version = '2005.03.07';	# Add fire group info from files
#   $version = '2005.03.04';	# Make conifer species table live for all manuals<br>Add fire group<br>Add note (if any) from ss_species files
#   $version = '2005.03.03';	# Add text to Armillaria regime pop-up<br>Add version history report
#!  $version = '2005.02.17';	# still under development
#!  $version = '2005.01.19';	# patch in Montana pieces
#   $version = '2004.12.15';	# Under development
### END HISTORY ############################

#       &ReadParse(*parameters)

# get parameters from calling form (self)

   &ReadParse(*parameters);

#   $stand_id=$parameters{'stand_id'};
#   $forest=$parameters{'forest'};
#   $study_area=$parameters{'study_area'};

   $manual=$parameters{'manual'};
   $manual='Central_ID'if ($manual eq '');	# 2004.12.15 DEH
   $location = $manual;
   if ($manual eq 'Colville') {$location='Colville NF'}
   if ($manual eq 'Okanogan') {$location='Okanogan NF'}
   if ($manual eq 'Wenatchee') {$location='Wenatchee NF'}
   if ($manual eq 'E_Mt_Hood') {$location='Mt. Hood NF'}
   if ($manual eq 'Blue_Mt') {$location='Blue &amp; Ochoco Mtns'}
   if ($manual eq 'Wallowa') {$location='Wallowa Province'}
   if ($manual eq 'North_ID') {$location='Northern Idaho'}
   if ($manual eq 'Montana') {$location='Montana'}
   if ($manual eq 'Central_ID') {$location='Central Idaho'}
   if ($manual eq 'E_ID_W_WY') {$location='Eastern Idaho &amp; Western Wyoming'}
   if ($manual eq 'North_UT') {$location='Northern Utah'}
   if ($manual eq 'Central_UT') {$location='Central &amp; Southern Utah'}

#   $manual_lc = lc($manual) . '_';
   $manual_lc = lc($manual) . '_s';

   &define_manuals;
   print "Content-type: text/html\n\n";

   print "<html>
 <head>
  <title>
   Armillaria Response Tool Lite
  </title>
    <SCRIPT LANGUAGE =\"JavaScript\" type=\"TEXT/JAVASCRIPT\">

  function popuphistory() {
    height=500;
    width=660;
    pophistory = window.open('','pophistory','toolbar=no,location=no,status=no,directories=no,menubar=no,scrollbars=yes,resizable=yes,width='+width+',height='+height);
";
    print make_history_popup();
print "
    pophistory.document.close()
    pophistory.focus()
  }

  <!--  -->

  mymanual='$manual'

function fire_regime(which) {		// DEH 2005.01.2005

// data from Jane Stewart 2005.02.04 3:07pm

  if (which == 'PJ/DG') {return 'Low'}
  if (which == 'PP/DG') {return 'Low'}
  if (which == 'PP/DS') {return 'Low'}
  if (which == 'PP/DH') {return 'Moderate'}
  if (which == 'DF/DG') {return 'Low'}
  if (which == 'DF/DS') {return 'Low'}
  if (which == 'DF/DH') {return 'Moderate'}
  if (which == 'DF/MH') {return 'Moderate'}
  if (which == 'CoolP/DG') {return 'Low'}
  if (which == 'CoolP/DS') {return 'Low'}
  if (which == 'CoolP/DH') {return 'Moderate'}
  if (which == 'CoolP/MH') {return 'Moderate'}
  if (which == 'CH/DH') {return 'Mixed'}
  if (which == 'CH/MH') {return 'Mixed'}
  if (which == 'CH/WH') {return 'Mixed'}
  if (which == 'CH/WF') {return 'High'}
  if (which == 'CH/WS') {return 'Rare'}
  if (which == 'CoolF/DG') {return 'Low'}
  if (which == 'CoolF/DS') {return 'Moderate'}
  if (which == 'CoolF/DH') {return 'Moderate'}
  if (which == 'CoolF/MH') {return 'Mixed'}
  if (which == 'CoolF/WH') {return 'Mixed'}
  if (which == 'CoolF/WF') {return 'High'}
  if (which == 'CoolF/WS') {return 'Rare'}
  if (which == 'ColdF/DG') {return 'Low'}
  if (which == 'ColdF/DS') {return 'Moderate'}
  if (which == 'ColdF/DH') {return 'Mixed'}
  if (which == 'ColdF/MH') {return 'Mixed'}
  if (which == 'ColdF/WH') {return 'High'}
  if (which == 'ColdF/WF') {return 'Rare'}
  if (which == 'ColdF/WS') {return 'Rare'}
  return ''
}

function which_soilmoist (soil_moisture_regime) {

  if (soil_moisture_regime == 'DH') {return 'Dry herb'}
  if (soil_moisture_regime == 'WS') {return 'Wet shrub'}
  if (soil_moisture_regime == 'WH') {return 'Wet herb'}
  if (soil_moisture_regime == 'WF') {return 'Wet fern'}
  if (soil_moisture_regime == 'MH') {return 'Moist herb'}
  if (soil_moisture_regime == 'DS') {return 'Dry shrub'}
  if (soil_moisture_regime == 'DG') {return 'Dry grass'}
  return ''

}

function which_soiltemp (soil_temperature_regime) {

//  if () {return ''}	// DEH 2005.03.31
  if (soil_temperature_regime == 'DF') {return 'Douglas-fir'}
  if (soil_temperature_regime == 'PP') {return 'Ponderosa pine'}
  if (soil_temperature_regime == 'PJ') {return 'Pinyon Juniper'}
  if (soil_temperature_regime == 'CH') {return 'Cedar-hemlock'}
  if (soil_temperature_regime == 'CoolP') {return 'Cool pine'}
  if (soil_temperature_regime == 'CoolF') {return 'Cool fir'}
  if (soil_temperature_regime == 'ColdF') {return 'Cold fir'}
  return ''

}

function which_habitype (ht) {
  if (ht == 'ABAM/ACCI') {return 'Abies amabilis / Acer circinatum'}
  if (ht == 'ABAM/ACTR') {return 'Abies amabilis / Achlys triphylla'}
  if (ht == 'ABAM/MEFE') {return 'Abies amabilis / Menziesia ferruginea'}
  if (ht == 'ABAM/OPHO') {return 'Abies amabilis / Oplopanax horridum'}
  if (ht == 'ABAM/RHAL') {return 'Abies amabilis / Rhododendron albiflorum'}
  if (ht == 'ABAM/VAAL') {return 'Abies amabilis / Vaccinium alaskaense'}
  if (ht == 'ABAM/VAME') {return 'Abies amabilis / Vaccinium membranaceum'}
if (ht == 'ABAM/RHAL-VAME') {return 'Abies amabilis / Rhododendron albiflorum - Vaccinium membranaceum'} 
if (ht == 'ABAM/RULA') {return 'Abies amabilis / Rubus lasiococcus'} 
if (ht == 'ABAM/TITR') {return 'Abies amabilis / Tiarella trifoliata'} 
if (ht == 'ABAM/VAME-CLUN') {return 'Abies amabilis / Vaccinium membranaceum - Clintonia uniflora'} 
if (ht == 'ABAM/VAME-PYSE') {return 'Abies amabilis / Vaccinium membranaceum - Pyrola secunda'}
  if (ht == 'ABCO/ARPA') {return 'Abies concolor / Arctostaphylos patula'}
  if (ht == 'ABCO/BERE-BERE') {return 'Abies concolor / Berberis repens - Berberis repens'}
  if (ht == 'ABCO/BERE-JUCO') {return 'Abies concolor / Berberis repens - Juniperus communis'}
  if (ht == 'ABCO/BERE-SYAL') {return 'Abies concolor / Berberis repens - Symphoricarpos albus'}
  if (ht == 'ABCO/BERE-SYOR') {return 'Abies concolor / Berberis repens - Symphoricarpos oreophilus'}
  if (ht == 'ABCO/CELE') {return 'Abies concolor / Cercocarpus ledifolius'}
  if (ht == 'ABCO/JUCO') {return 'Abies concolor / Juniperus communis'}
  if (ht == 'ABCO/OSCH') {return 'Abies concolor / Osmorhiza chilensis'}
  if (ht == 'ABCO/PHMA') {return 'Abies concolor / Physocarpus malvaceus'}
  if (ht == 'ABCO/SYOR') {return 'Abies concolor / Symphoricarpos oreophilus'}
  if (ht == 'ABGR/ACCI') {return 'Abies grandis / Acer circinatum'}
  if (ht == 'ABGR/ACCI-ACTR') {return 'Abies grandis / Acer circinatum - Achlys triphylla'}
  if (ht == 'ABGR/ACCI-CHUM') {return 'Abies grandis / Acer circinatum - Chimaphila umbellata'}
  if (ht == 'ABGR/ACCI-CLUN') {return 'Abies grandis / Acer circinatum - Clintonia uniflora'}
  if (ht == 'ABGR/ACGL') {return 'Abies grandis / Acer glabrum'}
 if (ht == 'ABGR/ACGL-ACGL') {return 'Abies grandis / Acer glabrum - Acer glabrum'}
  if (ht == 'ABGR/ACGL-PHMA') {return 'Abies grandis / Acer glabrum - Physocarpus malvaceus'}
  if (ht == 'ABGR/ACTR') {return 'Abies grandis / Achlys triphylla'}
  if (ht == 'ABGR/ARCO') {return 'Abies grandis / Arnica cordifolia'}
  if (ht == 'ABGR/ARNE') {return 'Abies grandis / Arctostaphylos nevadensis'}
  if (ht == 'ABGR/ASCA-ASCA') {return 'Abies grandis / Asarum caudatum - Asarum caudatum'}
  if (ht == 'ABGR/ASCA-MEFE') {return 'Abies grandis / Asarum caudatum - Menziesia ferruginea'}
  if (ht == 'ABGR/ASCA-TABR') {return 'Abies grandis / Asarum caudatum - Taxus brevifolia'}
  if (ht == 'ABGR/BENE') {return 'Abies grandis / Berberis nervosa'}
  if (ht == 'ABGR/BENE-CARU') {return 'Abies grandis / Berberis nervosa - Calamagrostis rubescens'}
  if (ht == 'ABGR/BRVU') {return 'Abies grandis / Bromus vulgaris'}
  if (ht == 'ABGR/CACH') {return 'Abies grandis / Castanopsis chrysophylla'}
  if (ht == 'ABGR/CAGE') {return 'Abies grandis / Carex geyeri'}
  if (ht == 'ABGR/CARU') {return 'Abies grandis / Calamagrostis rubescens'}
  if (ht == 'ABGR/CARU-LUHI') {return 'Abies grandis / Luzula hitchcockii'}
  if (ht == 'ABGR/CARU-LUPIN') {return 'Abies grandis / Calamagrostis rubescens - mixed Lupinus spp'}
  if (ht == 'ABGR/CLUN') {return 'Abies grandis / Clintonia uniflora'}
  if (ht == 'ABGR/CLUN-ARNU') {return 'Abies grandis / Clintonia uniflora - Aralia nudicaulis'}
  if (ht == 'ABGR/CLUN-CLUN') {return 'Abies grandis / Clintonia uniflora - Clintonia uniflora'}
  if (ht == 'ABGR/CLUN-MEFE') {return 'Abies grandis / Clintonia uniflora - Menziesia ferruginea'}
  if (ht == 'ABGR/CLUN-PHMA') {return 'Abies grandis / Clintonia uniflora - Physocarpus malvaceus'}
  if (ht == 'ABGR/CLUN-TABR') {return 'Abies grandis / Clintonia uniflora - Taxus brevifolia'}
  if (ht == 'ABGR/CLUN-XETE') {return 'Abies grandis / Clintonia uniflora - Xerophyllum tenax'}
  if (ht == 'ABGR/GYDR') {return 'Abies grandis / Gymnocarpium dryopteris'}
  if (ht == 'ABGR/HODI') {return 'Abies grandis / Holodiscus discolor'}
  if (ht == 'ABGR/LIBO') {return 'Abies grandis / Linnaea borealis'}
  if (ht == 'ABGR/LIBO-LIBO') {return 'Abies grandis / Linnaea borealis - Linnaea borealis'}
  if (ht == 'ABGR/LIBO-VAGL') {return 'Abies grandis / Linnaea borealis - Vaccinium globulare'}
  if (ht == 'ABGR/LIBO-XETE') {return 'Abies grandis / Linnaea borealis - Xerophyllum tenax'}
  if (ht == 'ABGR/PHMA') {return 'Abies grandis / Physocarpus malvaceus'}
  if (ht == 'ABGR/PHMA-COOC') {return 'Abies grandis / Physocarpus malvaceus - Coptis occidentalis'}
  if (ht == 'ABGR/PHMA-PHMA') {return 'Abies grandis / Physocarpus malvaceus - Physocarpus malvaceus'}
  if (ht == 'ABGR/POMU-ASCA') {return 'Abies grandis / Polystichum munitum - Asarum caudatum'}
  if (ht == 'ABGR/POPU') {return 'Abies grandis / Polemonium pulcherrimum'}
  if (ht == 'ABGR/PTAQ-SPBE') {return 'Abies grandis / Pteridium aquilinum - Spiraea betulifolia'}
  if (ht == 'ABGR/SETR') {return 'Abies grandis / Senecio triangularis'}
  if (ht == 'ABGR/SPBE') {return 'Abies grandis / Spiraea betulifolia'}
  if (ht == 'ABGR/SYAL') {return 'Abies grandis / Symphoricarpos albus'}
  if (ht == 'ABGR/SYMO') {return 'Abies grandis / Symphoricarpos mollis'}
  if (ht == 'ABGR/SYOR') {return 'Abies grandis / Symphoricarpos oreophilus'}
  if (ht == 'ABGR/TABR-CLUN') {return 'Abies grandis / Taxus brevifolia - Clintonia uniflora'}
  if (ht == 'ABGR/TABR-LIBO') {return 'Abies grandis / Taxus brevifolia - Linnaea borealis'}
  if (ht == 'ABGR/TRCA') {return 'Abies grandis / Trautvetteria caroliniensis'}
  if (ht == 'ABGR/TRLA') {return 'Abies grandis / Trientalis latifolia'}
  if (ht == 'ABGR/VACA') {return 'Abies grandis / Vaccinium caespitosum'}
  if (ht == 'ABGR/VAGL') {return 'Abies grandis / Vaccinium globulare'}
  if (ht == 'ABGR/VAME') {return 'Abies grandis / Vaccinium membranaceum'}
  if (ht == 'ABGR/VASC') {return 'Abies grandis / Vaccinium scoparium'}
  if (ht == 'ABGR/VASC-LIBO') {return 'Abies grandis / Vaccinium scoparium - Linnaea borealis'}
  if (ht == 'ABGR/XETE') {return 'Abies grandis /  Xerophyllum tenax'}
  if (ht == 'ABGR/XETE-COOC') {return 'Abies grandis /  Xerophyllum tenax - Coptis occidentalis'}
  if (ht == 'ABGR/XETE-VAGL') {return 'Abies grandis /  Xerophyllum tenax - Vaccinium globulare'}
  if (ht == 'ABGR-PIEN/SMST') {return 'Abies grandis - Picea engelmannii / Smilacina stellata'}
if (ht == 'ABGR/HODI-CARU') {return 'Abies grandis / Holodiscus discolor - Calamagrostis rubescens'}
if (ht == 'ABGR/SPBE-PTAQ') {return 'Abies grandis / Spiraea betulifolia - Pteridium aquilinum'}
if (ht == 'ABGR/SYAL-CARU') {return 'Abies grandis / Symphoricarpos albus - Calamagrostis rubescens'}
  if (ht == 'ABLA/ABLA-PIAL') {return 'Abies lasiocarpa / Abies lasiocarpa - Pinus albicaulis'}
  if (ht == 'ABLA/ACCO') {return 'Abies lasiocarpa / Aconitum columbianum'}
  if (ht == 'ABLA/ACGL') {return 'Abies lasiocarpa / Acer glabrum'}
  if (ht == 'ABLA/ACRU') {return 'Abies lasiocarpa / Actaea rubra'}
  if (ht == 'ABLA/ALSI') {return 'Abies lasiocarpa / Alnus sinuata'}
  if (ht == 'ABLA/ARCO') {return 'Abies lasiocarpa / Arnica cordifolia'}
  if (ht == 'ABLA/ARCO-ARCO') {return 'Abies lasiocarpa / Arnica cordifolia - Arnica cordifolia'}
  if (ht == 'ABLA/ARCO-ASMI') {return 'Abies lasiocarpa / Arnica cordifolia - Astragalus miser'}
  if (ht == 'ABLA/ARCO-PIEN') {return 'Abies lasiocarpa / Arnica cordifolia - Picea engelmannii'}
  if (ht == 'ABLA/ARCO-SHCA') {return 'Abies lasiocarpa / Arnica cordifolia - Shepherdia canadensis'}
  if (ht == 'ABLA/ARLA') {return 'Abies lasiocarpa / Arnica latifolia'}
  if (ht == 'ABLA/ARLA-CAGE') {return 'Abies lasiocarpa / Arnica latifolia - Carex geyeri'}
  if (ht == 'ABLA/BERE') {return 'Abies lasiocarpa / Berberis repens'}
  if (ht == 'ABLA/BERE-BERE') {return 'Abies lasiocarpa / Berberis repens - Berberis repens'}
  if (ht == 'ABLA/BERE-CAGE') {return 'Abies lasiocarpa / Berberis repens - Carex geyeri'}
  if (ht == 'ABLA/BERE-JUCO') {return 'Abies lasiocarpa / Berberis repens - Juniperus communis'}
  if (ht == 'ABLA/BERE-PIEN') {return 'Abies lasiocarpa / Berberis repens - Picea engelmannii'}
  if (ht == 'ABLA/BERE-PIFL') {return 'Abies lasiocarpa / Berberis repens - Pinus flexilis'}
  if (ht == 'ABLA/BERE-PSME') {return 'Abies lasiocarpa / Berberis repens - Pseudotsuga menziesii'}
  if (ht == 'ABLA/BERE-RIMO') {return 'Abies lasiocarpa / Berberis repens - Ribes montigenum'}
  if (ht == 'ABLA/CABI') {return 'Abies lasiocarpa / Caltha biflora'}
  if (ht == 'ABLA/CACA') {return 'Abies lasiocarpa / Calamagrostis canadensis'}
  if (ht == 'ABLA/CACA-CACA') {return 'Abies lasiocarpa / Calamagrostis canadensis - Calamagrostis canadensis'}
  if (ht == 'ABLA/CACA-GATR') {return 'Abies lasiocarpa / Calamagrostis canadensis - Galium triflorum'}
  if (ht == 'ABLA/CACA-LEGL') {return 'Abies lasiocarpa / Calamagrostis canadensis - Ledum glandulosum'}
  if (ht == 'ABLA/CACA-LICA') {return 'Abies lasiocarpa / Calamagrostis canadensis - Ligusticum canbyi'}
  if (ht == 'ABLA/CACA-VACA') {return 'Abies lasiocarpa / Calamagrostis canadensis - Vaccinium caespitosum'}
  if (ht == 'ABLA/CAGE') {return 'Abies lasiocarpa / Carex geyeri'}
  if (ht == 'ABLA/CAGE-ARTR') {return 'Abies lasiocarpa / Carex geyeri - Artemisia tridentata'}
  if (ht == 'ABLA/CAGE-CAGE') {return 'Abies lasiocarpa / Carex geyeri - Carex geyeri'}
  if (ht == 'ABLA/CAGE-PSME') {return 'Abies lasiocarpa / Carex geyeri - Pseudotsuga menziesii'}
  if (ht == 'ABLA/CARO') {return 'Abies lasiocarpa / Carex rossii'}
  if (ht == 'ABLA/CARU') {return 'Abies lasiocarpa / Calamagrostis rubescens'}
  if (ht == 'ABLA/CARU-CARU') {return 'Abies lasiocarpa / Calamagrostis rubescens - Calamagrostis rubescens'}
  if (ht == 'ABLA/CARU-PAMY') {return 'Abies lasiocarpa / Calamagrostis rubescens - Pachistima myrsinites'}
  if (ht == 'ABLA/CLPS') {return 'Abies lasiocarpa / Clematis pseudoalpina'}
  if (ht == 'ABLA/CLUN') {return 'Abies lasiocarpa / Clintonia uniflora'}
  if (ht == 'ABLA/CLUN-ARNU') {return 'Abies lasiocarpa / Clintonia uniflora - Aralia nudicaulis'}
  if (ht == 'ABLA/CLUN-CLUN') {return 'Abies lasiocarpa / Clintonia uniflora - Clintonia uniflora'}
  if (ht == 'ABLA/CLUN-MEFE') {return 'Abies lasiocarpa / Clintonia uniflora - Menziesia ferruginea'}
  if (ht == 'ABLA/CLUN-VACA') {return 'Abies lasiocarpa / Clintonia uniflora - Vaccinium caespitosum'}
  if (ht == 'ABLA/CLUN-XETE') {return 'Abies lasiocarpa / Clintonia uniflora - Xerophyllum tenax'}
  if (ht == 'ABLA/COCA') {return 'Abies lasiocarpa / Cornus canadensis'}
  if (ht == 'ABLA/GATR') {return 'Abies lasiocarpa / Galium triflorum'}
  if (ht == 'ABLA/JUCO') {return 'Abies lasiocarpa / Juniperus communis'}
  if (ht == 'ABLA/LALY-ABLA') {return 'Abies lasiocarpa / Larix lyalli - Abies lasiocarpa'}
  if (ht == 'ABLA/LIBO') {return 'Abies lasiocarpa / Linnaea borealis'}
  if (ht == 'ABLA/LIBO-LIBO') {return 'Abies lasiocarpa / Linnaea borealis - Linnaea borealis'}
  if (ht == 'ABLA/LIBO-VACA') {return 'Abies lasiocarpa / Linnaea borealis  - Vaccinium caespitosum'}
  if (ht == 'ABLA/LIBO-VASC') {return 'Abies lasiocarpa / Linnaea borealis - Vaccinium scoparium'}
  if (ht == 'ABLA/LIBO-XETE') {return 'Abies lasiocarpa / Linnaea borealis - Xerophyllum tenax'}
  if (ht == 'ABLA/LUHI') {return 'Abies lasiocarpa / Luzula hitchcockii'}
  if (ht == 'ABLA/LUHI-LUHI') {return 'Abies lasiocarpa / Luzula hitchcockii - Luzula hitchcockii'}
  if (ht == 'ABLA/LUHI-MEFE') {return 'Abies lasiocarpa / Luzula hitchcockii  -  Menziesia ferruginea'}
  if (ht == 'ABLA/LUHI-VASC') {return 'Abies lasiocarpa / Luzula hitchcockii - Vaccinium scoparium'}
  if (ht == 'ABLA/MEFE') {return 'Abies lasiocarpa / Menziesia ferruginea'}
  if (ht == 'ABLA/MEFE-COOC') {return 'Abies lasiocarpa / Menziesia ferruginea - Coptis occidentalis'}
  if (ht == 'ABLA/MEFE-LUHI') {return 'Abies lasiocarpa / Menziesia ferruginea - Luzula hitchcockii'}
  if (ht == 'ABLA/MEFE-VASC') {return 'Abies lasiocarpa / Menziesia ferruginea -  Vaccinium scoparium'}
  if (ht == 'ABLA/MEFE-XETE') {return 'Abies lasiocarpa / Menziesia ferruginea - Xerophyllum tenax'}
  if (ht == 'ABLA/OPHO') {return 'Abies lasiocarpa / Oplopanax horridum'}
  if (ht == 'ABLA/OSCH') {return 'Abies lasiocarpa / Osmorhiza chilensis'}
  if (ht == 'ABLA/OSCH-OSCH') {return 'Abies lasiocarpa / Osmorhiza chilensis - Osmorhiza chilensis'}
  if (ht == 'ABLA/OSCH-PAMY') {return 'Abies lasiocarpa / Osmorhiza chilensis - Pachistima myrsinites'}
  if (ht == 'ABLA/PAMY') {return 'Abies lasiocarpa / Pachistima myrsinites'}
  if (ht == 'ABLA/PERA') {return 'Abies lasiocarpa / Pedicularis racemosa'}
  if (ht == 'ABLA/PERA-PERA') {return 'Abies lasiocarpa / Pedicularis racemosa - Pedicularis racemosa'}
  if (ht == 'ABLA/PERA-PSME') {return 'Abies lasiocarpa / Pedicularis racemosa - Pseudotsuga menziesii'}
  if (ht == 'ABLA/PHEM') {return 'Abies lasiocarpa / Phyllodoce empetriformis'}
  if (ht == 'ABLA/PHMA') {return 'Abies lasiocarpa / Physocarpus malvaceus'}
  if (ht == 'ABLA/PIAL') {return 'Abies lasiocarpa / Pinus albicaulis'}
  if (ht == 'ABLA/PIAL-ABLA') {return 'Abies lasiocarpa / Pinus albicaulis - Abies lasiocarpa'}
  if (ht == 'ABLA/QUGA') {return 'Abies lasiocarpa / Quercus garryana'}
  if (ht == 'ABLA/RHAL') {return 'Abies lasiocarpa / Rhododendron albiflorum'}
  if (ht == 'ABLA/RHAL-XETE') {return 'Abies lasiocarpa / Rhododendron albiflorum - Xerophyllum tenax'}
  if (ht == 'ABLA/RIMO') {return 'Abies lasiocarpa / Ribes montigenum'}
  if (ht == 'ABLA/RIMO/PIAL') {return 'Abies lasiocarpa / Ribes montigenum / Pinus albicaulis'}
  if (ht == 'ABLA/RIMO-MEAR') {return 'Abies lasiocarpa / Ribes montigenum - Mertensia arizonica'}
  if (ht == 'ABLA/RIMO-PICO') {return 'Abies lasiocarpa / Ribes montigenum - Pinus contorta'}
  if (ht == 'ABLA/RIMO-RIMO') {return 'Abies lasiocarpa /  Ribes montigenum - Ribes montigenum'}
  if (ht == 'ABLA/RIMO-THFE') {return 'Abies lasiocarpa / Ribes montigenum - Thalictrum fendleri'}
  if (ht == 'ABLA/RIMO-TRSP') {return 'Abies lasiocarpa / Ribes montigenum - Trisetum spicatum'}
  if (ht == 'ABLA/RULA') {return 'Abies lasiocarpa / Rubus lasiococcus'}
  if (ht == 'ABLA/SPBE') {return 'Abies lasiocarpa / Spiraea betulifolia'}
  if (ht == 'ABLA/STAM') {return 'Abies lasiocarpa / Streptopus amplexifolius'}
  if (ht == 'ABLA/STAM-LICA') {return 'Abies lasiocarpa / Streptopus amplexifolius - Ligusticum canbyi'}
  if (ht == 'ABLA/STAM-MEFE') {return 'Abies lasiocarpa / Streptopus amplexifolius - Menziesia ferruginea'}
  if (ht == 'ABLA/STAM-STAM') {return 'Abies lasiocarpa / Streptopus amplexifolius - Streptopus amplexifolius'}
  if (ht == 'ABLA/STOC') {return 'Abies lasiocarpa / Stipa occidentalis'}
  if (ht == 'ABLA/SYAL') {return 'Abies lasiocarpa / Symphoricarpos albus'}
  if (ht == 'ABLA/THOC') {return 'Abies lasiocarpa / Thalictrum occidentale'}
  if (ht == 'ABLA/TRCA') {return 'Abies lasiocarpa / Trautvetteria caroliniensis'}
  if (ht == 'ABLA/TSME-MEFE') {return 'Abies lasiocarpa / Tsuga mertensiana - Menziesia ferruginea'}
  if (ht == 'ABLA/TSME-XETE') {return 'Abies lasiocarpa / Tsuga mertensiana - Xerophyllum tenax'}
  if (ht == 'ABLA/VACA') {return 'Abies lasiocarpa / Vaccinium caespitosum'}
  if (ht == 'ABLA/VACA-PIEN') {return 'Abies lasiocarpa / Vaccinium caespitosum - Picea engelmannii'}
  if (ht == 'ABLA/VACCI') {return 'Abies lasiocarpa / mixed Vaccinium spp.'}
  if (ht == 'ABLA/VAGL') {return 'Abies lasiocarpa / Vaccinium globulare'}
  if (ht == 'ABLA/VAGL-PAMY') {return 'Abies lasiocarpa / Vaccinium globulare - Pachistima myrsinites'}
  if (ht == 'ABLA/VAGL-VAGL') {return 'Abies lasiocarpa / Vaccinium globulare - Vaccinium globulare'}
  if (ht == 'ABLA/VAGL-VASC') {return 'Abies lasiocarpa / Vaccinium globulare - Vaccinium scoparium'}
  if (ht == 'ABLA/VAME') {return 'Abies lasiocarpa / Vaccinium membranaceum'}
  if (ht == 'ABLA/VAMY') {return 'Abies lasiocarpa / Vaccinium myrtillus'}
  if (ht == 'ABLA/VASC') {return 'Abies lasiocarpa / Vaccinium scoparium'}
  if (ht == 'ABLA/VASC-ARLA') {return 'Abies lasiocarpa / Vaccinium scoparium - Arnica latifolia'}
  if (ht == 'ABLA/VASC-CAGE') {return 'Abies lasiocarpa / Vaccinium scoparium - Carex geyeri'}
  if (ht == 'ABLA/VASC-CARU') {return 'Abies lasiocarpa / Vaccinium scoparium - Calamagrostis rubescens'}
  if (ht == 'ABLA/VASC-PIAL') {return 'Abies lasiocarpa / Vaccinium scoparium - Pinus albicaulis'}
  if (ht == 'ABLA/VASC-POPU') {return 'Abies lasiocarpa / Vaccinium scoparium - Polemonium pulcherrimum'}
  if (ht == 'ABLA/VASC-THOC') {return 'Abies lasiocarpa / Vaccinium scoparium - Thalictrum occidentale'}
  if (ht == 'ABLA/VASC-VASC') {return 'Abies lasiocarpa / Vaccinium scoparium - Vaccinium scoparium'}
  if (ht == 'ABLA/XETE') {return 'Abies lasiocarpa / Xerophyllum tenax'}
  if (ht == 'ABLA/XETE-COOC') {return 'Abies lasiocarpa / Xerophyllum tenax - Coptis occidentalis'}
  if (ht == 'ABLA/XETE-LUHI') {return 'Abies lasiocarpa / Xerophyllum tenax - Luzula hitchcockii'}
  if (ht == 'ABLA/XETE-VAGL') {return 'Abies lasiocarpa / Xerophyllum tenax -  Vaccinium globulare'}
  if (ht == 'ABLA/XETE-VASC') {return 'Abies lasiocarpa / Xerophyllum tenax - Vaccinium scoparium'}
  if (ht == 'ABLA-PIAL/ABLA') {return 'Abies lasiocarpa - Pinus albicaulis / Abies lasiocarpa'}
if (ht == 'ABLA/ARLA-POPU') {return 'Abies lasiocarpa / Arnica latifolia - Polemonium pulcherrimum'}
if (ht == 'ABLA/PAMY-CARU') {return 'Abies lasiocarpa / Pachistima myrsinites - Calamagrostis rubescens'}
if (ht == 'ABLA/RHAL-LUHI') {return 'Abies lasiocarpa / Rhododendron albiflorum - Luzula hitchcockii'}
if (ht == 'ABLA/VADE') {return 'Abies lasiocarpa / Vaccinium deliciosum'}
if (ht == 'ABLA/VASC-LUHI') {return 'Abies lasiocarpa / Vaccinium scoparium - Luzula hitchcockii'}
  if (ht == 'JUOC/FEID-AGSP') {return 'Juniperus occidentalis / Festuca idahoensis - Agropyron spicatum'}
  if (ht == 'JUOC/PUTR-FEID') {return 'Juniperus occidentalis / Purshia tridentata - Festuca idahoensis'}
  if (ht == 'LALY/LUHI') {return 'Larix lyalli / Luzula hitchcockii'}
  if (ht == 'LALY/VADE') {return 'Larix lyalli / Vaccinium deliciosum'}
if (ht == 'LALY/CAME-LUPE') {return 'Larix lyalli / Cassiope mertensiana - Luetkea pectinata'}
if (ht == 'LALY/DROC') {return 'Larix lyalli / Dryas octopetala'}
if (ht == 'LALY/JUCO') {return 'Larix lyalli / Juniperus communis'}
if (ht == 'LALY/VADE-CAME') {return 'Larix lyalli / Vaccinium deliciosum - Cassiope mertensiana'}
if (ht == 'LALY/VASC-LUHI') {return 'Larix lyalli / Vaccinium scoparium - Luzula hitchcockii'}
  if (ht == 'PIAL') {return 'Pinus albicaulis'}
  if (ht == 'PIAL/CAGE') {return 'Pinus albicaulis / Carex geyeri'}
  if (ht == 'PIAL/CARO-CARO') {return 'Pinus albicaulis / Carex rossii - Carex rossii'}
  if (ht == 'PIAL/CARO-PICO') {return 'Pinus albicaulis /  Carex rossii - Pinus contorta'}
  if (ht == 'PIAL/CARU') {return 'Pinus albicaulis / Calamagrostis rubescens'}
  if (ht == 'PIAL/FEID') {return 'Pinus albicaulis / Festuca idahoensis'}
  if (ht == 'PIAL/JUCO-JUCO') {return 'Pinus albicaulis / Juniperus communis - Juniperus communis'}
  if (ht == 'PIAL/JUCO-SHCA') {return 'Pinus albicaulis / Juniperus communis - Shepherdia canadensis'}
  if (ht == 'PIAL/LUHI') {return 'Pinus albicaulis / Luzula hitchcockii'}
  if (ht == 'PIAL/VASC') {return 'Pinus albicaulis / Vaccinium scoparium'}
if (ht == 'PIAL/FEVI') {return 'Pinus albicaulis / Festuca viridula'}
if (ht == 'PIAL/JUCO') {return 'Pinus albicaulis / Juniperus communis'}
if (ht == 'PIAL/VASC-LUHI') {return 'Pinus albicaulis / Vaccinium scoparium - Luzula hitchcockii'}
  if (ht == 'PICEA/CLUN-CLUN') {return 'mixed Picea spp. / Clintonia uniflora - Clintonia uniflora'}
  if (ht == 'PICEA/CLUN-VACA') {return 'mixed Picea spp. / Clintonia uniflora - Vaccinium caespitosum'}
  if (ht == 'PICEA/EQAR') {return 'mixed Picea spp. / Equisetum arvense'}
  if (ht == 'PICEA/GATR') {return 'mixed Picea spp. / Galium triflorum'}
  if (ht == 'PICEA/LIBO') {return 'mixed Picea spp. / Linnaea borealis'}
  if (ht == 'PICEA/PHMA') {return 'mixed Picea spp. / Physocarpus malvaceus'}
  if (ht == 'PICEA/SEST-PICEA') {return 'mixed Picea spp. / Senecio streptanthifolius - mixed Picea spp'}
  if (ht == 'PICEA/SEST-PSME') {return 'mixed Picea spp. / Senecio streptanthifolius - Pseudotsuga menziesii'}
  if (ht == 'PICEA/SMST') {return 'mixed Picea spp. / Smilacina stellata'}
  if (ht == 'PICEA/VACA') {return 'mixed Picea spp. / Vaccinium caespitosum'}
  if (ht == 'PICO-ABGR/CARU') {return 'Pinus contorta - Abies grandis / Calamagrostis rubescens'}
  if (ht == 'PICO/ARUV') {return 'Pinus contorta / Arctostaphylos uva-ursi'}
  if (ht == 'PICO/BERE') {return 'Pinus contorta / Berberis repens'}
  if (ht == 'PICO/CACA') {return 'Pinus contorta / Calamagrostis canadensis'}
  if (ht == 'PICO/CARO') {return 'Pinus contorta / Carex rossii'}
  if (ht == 'PICO/CARU') {return 'Pinus contorta / Calamagrostis rubescens'}
  if (ht == 'PICO/FEID') {return 'Pinus contorta / Festuca idahoensis'}
  if (ht == 'PICO/JUCO') {return 'Pinus contorta / Juniperus communis'}
  if (ht == 'PICO/LIBO') {return 'Pinus contorta / Linnaea borealis'}
  if (ht == 'PICO/LIBO-ABGR') {return 'Pinus contorta / Linnaea borealis - Abies grandis'}
  if (ht == 'PICO/PUTR') {return 'Pinus contorta / Purshia tridentata'}
  if (ht == 'PICO/SHCA') {return 'Pinus contorta / Shepherdia canadensis'}
  if (ht == 'PICO/VACA') {return 'Pinus contorta / Vaccinium caespitosum'}
  if (ht == 'PICO/VAME-ABLA') {return 'Pinus contorta / Vaccinium membranaceum - Abies lasiocarpa'}
  if (ht == 'PICO/VAME-CARU') {return 'Pinus contorta / Vaccinium membranaceum - Calamagrostis rubescens'}
  if (ht == 'PICO/VAME-LIBO') {return 'Pinus contorta / Vaccinium membranaceum - Linnaea borealis'}
  if (ht == 'PICO/VASC') {return 'Pinus contorta / Vaccinium scoparium'}
  if (ht == 'PICO/VASC-ABLA') {return 'Pinus contorta / Vaccinium scoparium - Abies lasiocarpa'}
  if (ht == 'PICO/VASC-CARU') {return 'Pinus contorta / Vaccinium scoparium - Calamagrostis rubescens'}
  if (ht == 'PICO/XETE') {return 'Pinus contorta / Xerophyllum tenax'}
  if (ht == 'PIEN/ARCO') {return 'Picea engelmannii / Arnica cordifolia'}
  if (ht == 'PIEN/CADI') {return 'Picea engelmannii / Carex disperma'}
  if (ht == 'PIEN/CALE') {return 'Picea engelmannii / Caltha leptosepala'}
  if (ht == 'PIEN/EQAR') {return 'Picea engelmannii / Equisetum arvense'}
  if (ht == 'PIEN/GATR') {return 'Picea engelmannii / Galium triflorum'}
  if (ht == 'PIEN/HYRE') {return 'Picea engelmannii / Hypnum revolutum'}
  if (ht == 'PIEN/JUCO') {return 'Picea engelmannii / Juniperus communis'}
  if (ht == 'PIEN/LIBO') {return 'Picea engelmannii / Linnaea borealis'}
  if (ht == 'PIEN/RIMO') {return 'Picea engelmannii / Ribes montigenum'}
  if (ht == 'PIEN/VACA') {return 'Picea engelmannii / Vaccinium caespitosum'}
  if (ht == 'PIEN/VASC') {return 'Picea engelmannii / Vaccinium scoparium'}
if (ht == 'PIEN/EQUIS') {return 'Picea engelmannii / mixed Equisetum spp.'} 
  if (ht == 'PIFL/AGSP') {return 'Pinus flexilis / Agropyron spicatum'}
  if (ht == 'PIFL/BERE') {return 'Pinus flexilis / Berberis repens'}
  if (ht == 'PIFL/CELE') {return 'Pinus flexilis / Cercocarpus ledifolius'}
  if (ht == 'PIFL/FEID') {return 'Pinus flexilis / Festuca idahoensis'}
  if (ht == 'PIFL/FEID-FEID') {return 'Pinus flexilis / Festuca idahoensis - Festuca idahoensis'}
  if (ht == 'PIFL/FEID-FESC') {return 'Pinus flexilis / Festuca idahoensis - Festuca scabrella'}
  if (ht == 'PIFL/HEKI') {return 'Pinus flexilis / Hesperochloa kingii'}
  if (ht == 'PIFL/JUCO') {return 'Pinus flexilis / Juniperus communis'}
  if (ht == 'PIFL-PILO') {return 'Pinus flexilis - Pinus longaeva '}
  if (ht == 'PIMO/ARPA') {return 'Pinus monticola / Arctostaphylos patula'}
  if (ht == 'PIPO/AGSP') {return 'Pinus ponderosa / Agropyron spicatum'}
  if (ht == 'PIPO/AGSP-ASDE') {return 'Pinus ponderosa / Agropyron spicatum - Aspidotis densa'}
  if (ht == 'PIPO/ARNO') {return 'Pinus ponderosa / Artemisia nova'}
  if (ht == 'PIPO/ARTR-FEID') {return 'Pinus ponderosa / Artemisia tridentata - Festuca idahoensis'}
  if (ht == 'PIPO/CAGE') {return 'Pinus ponderosa / Carex geyeri'}
  if (ht == 'PIPO/CARU') {return 'Pinus ponderosa / Calamagrostis rubescens'}
  if (ht == 'PIPO/CARU-AGSP') {return 'Pinus ponderosa / Calamagrostis rubescens - Agropyron spicatum'}
  if (ht == 'PIPO/CELE') {return 'Pinus ponderosa / Cercocarpus ledifolius'}
  if (ht == 'PIPO/CELE-CAGE') {return 'Pinus ponderosa / Cercocarpus ledifolius - Carex geyeri'}
  if (ht == 'PIPO/CELE-FEID') {return 'Pinus ponderosa / Cercocarpus ledifolius - Festuca idahoensis'}
  if (ht == 'PIPO/CELE-PONE') {return 'Pinus ponderosa / Cercocarpus ledifolius - Poa nervosa'}
  if (ht == 'PIPO/EQAR') {return 'Pinus ponderosa / Equisetum arvense'}
  if (ht == 'PIPO/FEID') {return 'Pinus ponderosa / Festuca idahoensis'}
  if (ht == 'PIPO/FEID-ARPA') {return 'Pinus ponderosa / Festuca idahoensis - Arctostaphylos patula'}
  if (ht == 'PIPO/FEID-ARTR') {return 'Pinus ponderosa / Festuca idahoensis - Artemisia tridentata'}
  if (ht == 'PIPO/FEID-FEID') {return 'Pinus ponderosa / Festuca idahoensis - Festuca idahoensis'}
  if (ht == 'PIPO/FEID-FESC') {return 'Pinus ponderosa / Festuca idahoensis - Festuca scabrella'}
  if (ht == 'PIPO/MUMO') {return 'Pinus ponderosa / Muhlenbergia montana'}
  if (ht == 'PIPO/PHMA') {return 'Pinus ponderosa / Physocarpus malvaceus'}
  if (ht == 'PIPO/PRVI-PRVI') {return 'Pinus ponderosa / Prunus virginiana - Prunus virginiana'}
  if (ht == 'PIPO/PUTR') {return 'Pinus ponderosa / Purshia tridentata'}
  if (ht == 'PIPO/PUTR-AGSP') {return 'Pinus ponderosa / Purshia tridentata - Agropyron spicatum'}
  if (ht == 'PIPO/PUTR-CAGE') {return 'Pinus ponderosa / Purshia tridentata - Carex geyeri'}
  if (ht == 'PIPO/PUTR-CARO') {return 'Pinus ponderosa / Purshia tridentata - Carex rossii'}
  if (ht == 'PIPO/PUTR-FEID') {return 'Pinus ponderosa / Purshia tridentata - Festuca idahoensis'}
  if (ht == 'PIPO-QUGA/BASA') {return 'Pinus ponderosa - Quercus garryana / Balsamorhiza sagittata'}
  if (ht == 'PIPO-QUGA/PUTR') {return 'Pinus ponderosa - Quercus garryana / Purshia tridentata'}
  if (ht == 'PIPO/QUGA-QUGA') {return 'Pinus ponderosa / Quercus garryana - Quercus garryana'}
  if (ht == 'PIPO/QUGA-SYOR') {return 'Pinus ponderosa / Quercus garryana - Symphoricarpos oreophilus'}
  if (ht == 'PIPO/STOC') {return 'Pinus ponderosa / Stipa occidentalis'}
  if (ht == 'PIPO/SYAL') {return 'Pinus ponderosa / Symphoricarpos albus'}
  if (ht == 'PIPO/SYAL-BERE') {return 'Pinus ponderosa / Symphoricarpos albus -  Berberis repens'}
  if (ht == 'PIPO/SYAL-SYAL') {return 'Pinus ponderosa / Symphoricarpos albus - Symphoricarpos albus'}
  if (ht == 'PIPO/SYOR') {return 'Pinus ponderosa / Symphoricarpos oreophilus'}
  if (ht == 'PIPO-PSME/AGIN') {return 'Pinus ponderosa - Pseudotsuga menziesii / Agropyron spicatum var. inerme'}
  if (ht == 'PIPU/AGSP') {return 'Picea pungens / Agropyron spicatum'}
  if (ht == 'PIPU/BERE') {return 'Picea pungens / Berberis repens'}
  if (ht == 'PIPU/JUCO') {return 'Picea pungens / Juniperus communis'}
  if (ht == 'POTR/CARU') {return 'Populus tremuloides / Calamagrostis rubescens'}
  if (ht == 'POTR/SYAL') {return 'Populus tremuloides / Symphoricarpos albus'}
  if (ht == 'PSME/ACGL') {return 'Pseudotsuga menziesii / Acer glabrum'}
  if (ht == 'PSME/ACGL-ACGL') {return 'Pseudotsuga menziesii / Acer glabrum - Acer glabrum'}
  if (ht == 'PSME/ACGL-PAMY') {return 'Pseudotsuga menziesii / Acer glabrum - Pachistima myrsinites'}
  if (ht == 'PSME/ACGL-PHMA') {return 'Pseudotsuga menziesii / Acer glabrum - Physocarpus malvaceus'}
  if (ht == 'PSME/ACGL-SYOR') {return 'Pseudotsuga menziesii / Acer glabrum - Symphoricarpos oreophilus'}
  if (ht == 'PSME/AGSP') {return 'Pseudotsuga menziesii / Agropyron spicatum'}
  if (ht == 'PSME/AGSP-CAGE') {return 'Pseudotsuga menziesii / Agropyron spicatum - Carex geyeri'}
  if (ht == 'PSME/ARCO') {return 'Pseudotsuga menziesii / Arnica cordifolia'}
  if (ht == 'PSME/ARCO-ARCO') {return 'Pseudotsuga menziesii / Arnica cordifolia - Arnica cordifolia'}
  if (ht == 'PSME/ARCO-ASMI') {return 'Pseudotsuga menziesii / Arnica cordifolia - Astragalus miser'}
  if (ht == 'PSME/ARNE') {return 'Pseudotsuga menziesii / Arctostaphylos nevadensis'}
  if (ht == 'PSME/ARPA') {return 'Pseudotsuga menziesii / Arctostaphylos patula'}
  if (ht == 'PSME/ARTR') {return 'Pseudotsuga menziesii / Artemisia tridentata'}
  if (ht == 'PSME/ARUV') {return 'Pseudotsuga menziesii / Arctostaphylos uva-ursi'}
  if (ht == 'PSME/ARUV-PUTR') {return 'Pseudotsuga menziesii / Arctostaphylos uva-ursi - Purshia tridentata'}
  if (ht == 'PSME/ASDE') {return 'Pseudotsuga menziesii / Aspidotis densa'}
  if (ht == 'PSME/BERE-BERE') {return 'Pseudotsuga menziesii / Berberis repens - Berberis repens'}
  if (ht == 'PSME/BERE-CAGE') {return 'Pseudotsuga menziesii / Berberis repens - Carex geyeri'}
  if (ht == 'PSME/BERE-JUCO') {return 'Pseudotsuga menziesii / Berberis repens - Juniperus communis'}
  if (ht == 'PSME/BERE-PIPO') {return 'Pseudotsuga menziesii / Berberis repens - Pinus ponderosa'}
  if (ht == 'PSME/BERE-SYAL') {return 'Pseudotsuga menziesii / Berberis repens - Symphoricarpos albus'}
  if (ht == 'PSME/BERE-SYOR') {return 'Pseudotsuga menziesii / Berberis repens - Symphoricarpos oreophilus'}
  if (ht == 'PSME/CAGE') {return 'Pseudotsuga menziesii / Carex geyeri'}
  if (ht == 'PSME/CAGE-CAGE') {return 'Pseudotsuga menziesii / Carex geyeri - Carex geyeri'}
  if (ht == 'PSME/CAGE-PIPO') {return 'Pseudotsuga menziesii / Carex geyeri - Pinus ponderosa'}
  if (ht == 'PSME/CAGE-SYOR') {return 'Pseudotsuga menziesii / Carex geyeri - Symphoricarpos oreophilus'}
  if (ht == 'PSME/CARU') {return 'Pseudotsuga menziesii / Calamagrostis rubescens'}
  if (ht == 'PSME/CARU-AGSP') {return 'Pseudotsuga menziesii / Calamagrostis rubescens - Agropyron spicatum'}
  if (ht == 'PSME/CARU-ARUV') {return 'Pseudotsuga menziesii / Calamagrostis rubescens - Arctostaphylos uva-ursi'}
  if (ht == 'PSME/CARU-CAGE') {return 'Pseudotsuga menziesii / Calamagrostis rubescens - Carex geyeri'}
  if (ht == 'PSME/CARU-CARU') {return 'Pseudotsuga menziesii / Calamagrostis rubescens - Calamagrostis rubescens'}
  if (ht == 'PSME/CARU-FEID') {return 'Pseudotsuga menziesii / Calamagrostis rubescens - Festuca idahoensis'}
  if (ht == 'PSME/CARU-LIBO') {return 'Pseudotsuga menziesii / Calamagrostis rubescens - Linnaea borealis'}
  if (ht == 'PSME/CARU-PAMY') {return 'Pseudotsuga menziesii / Calamagrostis rubescens - Pachistima myrsinites'}
  if (ht == 'PSME/CARU-PIPO') {return 'Pseudotsuga menziesii / Calamagrostis rubescens - Pinus ponderosa'}
  if (ht == 'PSME/CELE') {return 'Pseudotsuga menziesii / Cercocarpus ledifolius'}
  if (ht == 'PSME/CEMO') {return 'Pseudotsuga menziesii / Cercocarpus montanus'}
  if (ht == 'PSME/FEID') {return 'Pseudotsuga menziesii / Festuca idahoensis'}
  if (ht == 'PSME/FEID-FEID') {return 'Pseudotsuga menziesii / Festuca idahoensis - Festuca idahoensis'}
  if (ht == 'PSME/FEID-PIPO') {return 'Pseudotsuga menziesii / Festuca idahoensis -  Pinus ponderosa'}
  if (ht == 'PSME/FEOC') {return 'Pseudotsuga menziesii / Festuca occidentalis'}
  if (ht == 'PSME/FESC') {return 'Pseudotsuga menziesii / Festuca scabrella'}
  if (ht == 'PSME/HODI') {return 'Pseudotsuga menziesii / Holodiscus discolor'}
  if (ht == 'PSME/HODI-CAGE') {return 'Pseudotsuga menziesii / Holodiscus discolor - Carex geyeri'}
  if (ht == 'PSME/JUCO') {return 'Pseudotsuga menziesii / Juniperus communis'}
  if (ht == 'PSME/LIBO-CARU') {return 'Pseudotsuga menziesii / Linnaea borealis - Calamagrostis rubescens'}
  if (ht == 'PSME/LIBO-SYAL') {return 'Pseudotsuga menziesii / Linnaea borealis - Symphoricarpos albus'}
  if (ht == 'PSME/LIBO-VAGL') {return 'Pseudotsuga menziesii / Linnaea borealis - Vaccinium globulare'}
  if (ht == 'PSME/OSCH') {return 'Pseudotsuga menziesii / Osmorhiza chilensis'}
  if (ht == 'PSME/PAMY') {return 'Pseudotsuga menziesii / Pachistima myrsinites'}
  if (ht == 'PSME/PHMA') {return 'Pseudotsuga menziesii / Physocarpus malvaceus'}
  if (ht == 'PSME/PHMA/PSME') {return 'Pseudotsuga menziesii / Physocarpus malvaceus - Pseudotsuga menziesii'}
  if (ht == 'PSME/PHMA-CARU') {return 'Pseudotsuga menziesii / Physocarpus malvaceus - Calamagrostis rubescens'}
  if (ht == 'PSME/PHMA-LIBO') {return 'Pseudotsuga menziesii / Physocarpus malvaceus - Linnaea borealis'}
  if (ht == 'PSME/PHMA-PAMY') {return 'Pseudotsuga menziesii / Physocarpus malvaceus - Pachistima myrsinites'}
  if (ht == 'PSME/PHMA-PHMA') {return 'Pseudotsuga menziesii / Physocarpus malvaceus - Physocarpus malvaceus'}
  if (ht == 'PSME/PHMA-PIPO') {return 'Pseudotsuga menziesii / Physocarpus malvaceus - Pinus ponderosa'}
  if (ht == 'PSME/PHMA-PSME') {return 'Pseudotsuga menziesii / Physocarpus malvaceus - Pseudotsuga menziesii'}
  if (ht == 'PSME/PHMA-SMST') {return 'Pseudotsuga menziesii / Physocarpus malvaceus - Smilacina stellata'}
  if (ht == 'PSME/QUGA') {return 'Pseudotsuga menziesii / Quercus garryana'}
  if (ht == 'PSME/SPBE') {return 'Pseudotsuga menziesii / Spiraea betulifolia'}
  if (ht == 'PSME/SPBE-CARU') {return 'Pseudotsuga menziesii / Spiraea betulifolia - Calamagrostis rubescens'}
  if (ht == 'PSME/SPBE-PIPO') {return 'Pseudotsuga menziesii / Spiraea betulifolia - Pinus ponderosa'}
  if (ht == 'PSME/SPBE-SPBE') {return 'Pseudotsuga menziesii / Spiraea betulifolia - Spiraea betulifolia'}
  if (ht == 'PSME/SYAL') {return 'Pseudotsuga menziesii / Symphoricarpos albus'}
  if (ht == 'PSME/SYAL-AGSP') {return 'Pseudotsuga menziesii / Symphoricarpos albus - Agropyron spicatum'}
  if (ht == 'PSME/SYAL-CAGE') {return 'Pseudotsuga menziesii / Symphoricarpos albus - Carex geyeri'}
  if (ht == 'PSME/SYAL-CARU') {return 'Pseudotsuga menziesii / Symphoricarpos albus - Calamagrostis rubescens'}
  if (ht == 'PSME/SYAL-PIPO') {return 'Pseudotsuga menziesii / Symphoricarpos albus - Pinus ponderosa'}
  if (ht == 'PSME/SYAL-SYAL') {return 'Pseudotsuga menziesii / Symphoricarpos albus - Symphoricarpos albus'}
  if (ht == 'PSME/SYOR') {return 'Pseudotsuga menziesii / Symphoricarpos oreophilus'}
  if (ht == 'PSME/VACA') {return 'Pseudotsuga menziesii / Vaccinium caespitosum'}
  if (ht == 'PSME/VACCI') {return 'Pseudotsuga menziesii / mixed Vaccinium spp.'}
  if (ht == 'PSME/VAGL') {return 'Pseudotsuga menziesii / Vaccinium globulare'}
  if (ht == 'PSME/VAGL-ARUV') {return 'Pseudotsuga menziesii / Vaccinium globulare - Arctostaphylos uva-ursi'}
  if (ht == 'PSME/VAGL-VAGL') {return 'Pseudotsuga menziesii / Vaccinium globulare - Vaccinium globulare'}
  if (ht == 'PSME/VAGL-XETE') {return 'Pseudotsuga menziesii / Vaccinium globulare - Xerophyllum tenax'}
  if (ht == 'PSME/VAME') {return 'Pseudotsuga menziesii / Vaccinium membranaceum'}
  if (ht == 'PSME-PIPO/AGSP') {return 'Pseudotsuga menziesii - Pinus ponderosa / Agropyron spicatum'}
  if (ht == 'PSME-PIPO/PEFR') {return 'Pseudotsuga menziesii - Pinus ponderosa / Penstemon fruticosus'}
  if (ht == 'PSME-PIPO/PUTR') {return 'Pseudotsuga menziesii - Pinus ponderosa / Purshia tridentata'}
if (ht == 'PSME/AGSP-ASDE') {return 'Pseudotsuga menziesii / Agropyron spicatum -Aspidotis densa'} 
if (ht == 'PSME/ARUV-CARU') {return 'Pseudotsuga menziesii / Arctostaphylos uva-ursi - Calamagrostis rubescens'} 
if (ht == 'PSME/PAMY-CARU') {return 'Pseudotsuga menziesii / Pachistima myrsinites - Calamagrostis rubescens'} 
if (ht == 'PSME/PEFR') {return 'Pseudotsuga menziesii / Penstemon fruticosus'}
if (ht == 'PSME/PUTR') {return 'Pseudotsuga menziesii / Purshia tridentata'}
if (ht == 'PSME/PUTR-AGSP') {return 'Pseudotsuga menziesii / Purshia tridentata - Agropyron spicatum'}
if (ht == 'PSME/PUTR-CARU') {return 'Pseudotsuga menziesii / Purshia tridentata - Calamagrostis rubescens'}
if (ht == 'PSME/VAMY') {return 'Pseudotsuga menziesii / Vaccinium myrtillus'}
if (ht == 'PSME/VAMY-CARU') {return 'Pseudotsuga menziesii / Vaccinium myrtillus - Calamagrostis rubescens'}
  if (ht == 'QUGA/CAGE') {return 'Quercus garryana / Carex geyeri'}
if (ht == 'QUGA/AGSP') {return 'Quercus garryana / Agropyron spicatum'}
if (ht == 'QUGA/CARU-CAGE') {return 'Quercus garryana / Calamagrostis rubescens - Carex geyeri'}
if (ht == 'QUGA/COCO-SYAL') {return 'Quercus garryana / Corylus cornuta - Symphoricarpos albus'}
  if (ht == 'THPL-ABGR/ACTR') {return 'Thuja plicata - Abies grandis / Achyls triphylla'}
  if (ht == 'THPL-ABGR/CLUN') {return 'Thuja plicata - Abies grandis / Clintonia uniflora'}
  if (ht == 'THPL/ADPE') {return 'Thuja plicata / Adiantum pedatum'}
  if (ht == 'THPL/ARNU') {return 'Thuja plicata / Aralia nudicaulis'}
  if (ht == 'THPL/ASCA-ASCA') {return 'Thuja plicata / Asarum caudatum - Asarum caudatum'}
  if (ht == 'THPL/ASCA-MEFE') {return 'Thuja plicata / Asarum caudatum - Menziesia ferruginea'}
  if (ht == 'THPL/ASCA-TABR') {return 'Thuja plicata / Asarum caudatum - Taxus brevifolia'}
  if (ht == 'THPL/ATFI-ADPE') {return 'Thuja plicata / Athyrium filix-femina - Adiantum pedatum'}
  if (ht == 'THPL/ATFI-ATFI') {return 'Thuja plicata / Athyrium filix-femina - Athyrium filix-femina'}
  if (ht == 'THPL/CLUN') {return 'Thuja plicata / Clintonia uniflora'}
  if (ht == 'THPL/CLUN-ARNU') {return 'Thuja plicata / Clintonia uniflora - Aralia nudicaulis'}
  if (ht == 'THPL/CLUN-CLUN') {return 'Thuja plicata / Clintonia uniflora - Clintonia uniflora'}
  if (ht == 'THPL/CLUN-MEFE') {return 'Thuja plicata / Clintonia uniflora - Menziesia ferruginea'}
  if (ht == 'THPL/CLUN-TABR') {return 'Thuja plicata / Clintonia uniflora - Taxus brevifolia'}
  if (ht == 'THPL/CLUN-XETE') {return 'Thuja plicata / Clintonia uniflora - Xerophyllum tenax'}
  if (ht == 'THPL/GYDR') {return 'Thuja plicata / Gymnocarpium dryopteris'}
  if (ht == 'THPL/OPHO') {return 'Thuja plicata / Oplopanax horridum'}
  if (ht == 'THPL/VAME') {return 'Thuja plicata / Vaccinium membranaceum'}
  if (ht == 'TSHE/ABGR-CLUN') {return 'Tsuga heterophylla / Abies grandis - Clintonia uniflora'}
  if (ht == 'TSHE/ACTR') {return 'Tsuga heterophylla / Achlys triphylla'}
  if (ht == 'TSHE/ARNE') {return 'Tsuga heterophylla / Arctostaphylos nevadensis'}
  if (ht == 'TSHE/ARNU') {return 'Tsuga heterophylla / Aralia nudicaulis'}
  if (ht == 'TSHE/ASCA') {return 'Tsuga heterophylla / Asarum caudatum'}
  if (ht == 'TSHE/ASCA-ARNU') {return 'Tsuga heterophylla / Asarum caudatum - Aralia nudicaulis'}
  if (ht == 'TSHE/ASCA-ASCA') {return 'Tsuga heterophylla / Asarum caudatum - Asarum caudatum'}
  if (ht == 'TSHE/ASCA-MEFE') {return 'Tsuga heterophylla / Asarum caudatum - Menziesia ferruginea'}
  if (ht == 'TSHE/BENE') {return 'Tsuga heterophylla / Berberis nervosa'}
  if (ht == 'TSHE/CLUN') {return 'Tsuga heterophylla / Clintonia uniflora'}
  if (ht == 'TSHE/CLUN-ARNU') {return 'Tsuga heterophylla / Clintonia uniflora - Aralia nudicaulis'}
  if (ht == 'TSHE/CLUN-CLUN') {return 'Tsuga heterophylla /  Clintonia uniflora - Clintonia uniflora'}
  if (ht == 'TSHE/CLUN-MEFE') {return 'Tsuga heterophylla / Clintonia uniflora - Menziesia ferruginea'}
  if (ht == 'TSHE/CLUN-XETE') {return 'Tsuga heterophylla / Clintonia uniflora - Xerophyllum tenax'}
  if (ht == 'TSHE/GYDR') {return 'Tsuga heterophylla / Gymnocarpium dryopteris'}
  if (ht == 'TSHE/LIBO-CLUN') {return 'Tsuga heterophylla / Linnaea borealis - Clintonia uniflora'}
  if (ht == 'TSHE/MEFE') {return 'Tsuga heterophylla / Menziesia ferruginea'}
  if (ht == 'TSHE/OPHO') {return 'Tsuga heterophylla / Oplopanax horridum'}
  if (ht == 'TSHE/RUPE') {return 'Tsuga heterophylla / Rubus pedatus'}
  if (ht == 'TSHE/XETE') {return 'Tsuga heterophylla / Xerophyllum tenax'}
if (ht == 'TSHE-ABGR/CLUN') {return 'Tsuga heterophylla - Abies grandis / Clintonia uniflora'}
if (ht == 'TSHE/ACCI-ACTR') {return 'Tsuga heterophylla / Acer circinatum - Achlys triphylla'}
if (ht == 'TSHE/ACCI-ASCA') {return 'Tsuga heterophylla / Acer circinatum - Asarum caudatum'}
if (ht == 'TSHE/ACCI-CLUN') {return 'Tsuga heterophylla / Acer circinatum - Clintonia uniflora'}
if (ht == 'TSHE/PAMY-CLUN') {return 'Tsuga heterophylla / Pachistima myrsinites - Clintonia uniflora'}
  if (ht == 'TSME/CLUN-MEFE') {return 'Tsuga mertensiana / Clintonia uniflora - Menziesia ferruginea'}
  if (ht == 'TSME/CLUN-XETE') {return 'Tsuga mertensiana / Clintonia uniflora - Xerophyllum tenax'}
  if (ht == 'TSME/LUHI') {return 'Tsuga mertensiana / Luzula hitchcockii'}
  if (ht == 'TSME/MEFE-LUHI') {return 'Tsuga mertensiana /  Menziesia ferruginea - Luzula hitchcockii'}
  if (ht == 'TSME/MEFE-XETE') {return 'Tsuga mertensiana /  Menziesia ferruginea - Xerophyllum tenax'}
  if (ht == 'TSME/RULA') {return 'Tsuga mertensiana / Rubus lasiococcus'}
  if (ht == 'TSME/STAM-LUHI') {return 'Tsuga mertensiana / Streptopus amplexifolius - Luzula hitchcockii'}
  if (ht == 'TSME/STAM-MEFE') {return 'Tsuga mertensiana / Streptopus amplexifolius - Menziesia ferruginea'}
  if (ht == 'TSME/VADE') {return 'Tsuga mertensiana / Vaccinium deliciosum'}
  if (ht == 'TSME/VAME') {return 'Tsuga mertensiana / Vaccinium membranaceum'}
  if (ht == 'TSME/VASC') {return 'Tsuga mertensiana / Vaccinium scoparium'}
  if (ht == 'TSME/XETE') {return 'Tsuga mertensiana / Xerophyllum tenax'}
  if (ht == 'TSME/XETE-LUHI') {return 'Tsuga mertensiana / Xerophyllum tenax - Luzula hitchcockii'}
  if (ht == 'TSME/XETE-VAGL') {return 'Tsuga mertensiana / Xerophyllum tenax - Vaccinium globulare'}
  if (ht == 'TSME/XETE-VASC') {return 'Tsuga mertensiana / Xerophyllum tenax - Vaccinium scoparium'}
if (ht == 'TSME/MEFE-VAAL') {return 'Tsuga mertensiana / Menziesia ferruginea - Vaccinium alaskaense'}
if (ht == 'TSME/MEFE-VAME') {return 'Tsuga mertensiana / Menziesia ferruginea - Vaccinium membranaceum'}
if (ht == 'TSME/PHEM-VADE') {return 'Tsuga mertensiana / Phyllodoce empetriformis - Vaccinium deliciosum'}
if (ht == 'TSME/RHAL-VAAL') {return 'Tsuga mertensiana / Rhododendron albiflorum - Vaccinium alaskaense'}
if (ht == 'TSME/RHAL-VAME') {return 'Tsuga mertensiana / Rhododendron albiflorum - Vaccinium membranaceum'}
if (ht == 'TSME/VAAL') {return 'Tsuga mertensiana / Vaccinium alaskaense'}
if (ht == 'TSME/VASC-LUHI') {return 'Tsuga mertensiana / Vaccinium scoparium - Luzula hitchcockii'}
if (ht == 'TSME/XETE-VAMY') {return 'Tsuga mertensiana / Xerophyllum tenax - Vaccinium myrtillus'}
  return ''
}

   my_arm_regime=''

";
   impacts();		# create javascript function species_occur(which)  2005.03.04
   firegroup();		# create javascript function fire_text(which)   2005.03.07
#  &treatments();	# create javascript function treatment_effects(which)	2005.03.15

   print "

  function ht_changed(which_changed,which_affected) {

//  This subroutine is called when user changes (reclassifies) the subseries encoding.
//  Determine the new classification and display appropriate risk class.

//   which_changed, which_affected
//   alert (which_changed.value);
//   alert (which_affected);

//  sets:
//	subs
//	fire
//	myht
//	risky
//      soiltempregime
//      soilmoistureregime

	// 2005.06.16 DEH
//	subs='[undefined]'
//	fire='[undefined]'
//	myht='[undefined]'
//	risky='[undefined]'
	// 2005.06.16 DEH
	subs=''
	fire=''
	myht=''
	risky=''

    if (which_changed.value == '') {
      soiltempregime = ''
      soilmoistureregime = ''
//      fire = '[undefined]'
      fire=''
      myht=''
      habitype=''
      my_arm_regime=''
    }
    else {
      colon = which_changed.value.indexOf(':')	// location of first ':' divides subseries from fire thing plus HT
      if (colon > 0) {
        subs =  which_changed.value.substring(0,colon)
        slash = which_changed.value.indexOf('/')
        soiltempregime = which_soiltemp(subs.substring(0,slash))
        soilmoistureregime = which_soilmoist(subs.substring(slash+1))
        rest =  which_changed.value.substring(colon+1)
        fire = rest
        colon = rest.indexOf(':')			// location of first ':' divides fire thing from HT
        if (colon == 0) {
//          fire = '[undefined]'
          fire = ''
          myht = rest.substring(colon+1)
        }
        if (colon > 0) {
          fire =  rest.substring(0,colon)
          myht =  rest.substring(colon+1)
        }
      }
      habitype = which_habitype (myht)
    }

//     nofire = 'This habitat type was not included in the fire manual'	// 2005.06.16
     document.getElementById('habitattype').innerHTML=myht + ' (<i>' + habitype + '</i>)'	// DEH 2005.02.28
     document.getElementById('subseries').innerHTML=subs + ' (' + soiltempregime + '/' + soilmoistureregime + ')'
     document.getElementById('subseries2').innerHTML=subs	// http://www.w3schools.com/dhtml/tryit.asp?filename=trydhtml_demo
//     document.getElementById('firegroup').innerHTML=fire	// 2005.06.16
     if (fire != '99') {document.getElementById('firegroup').innerHTML=fire}	// 2005.06.16
     if (fire == '99') {document.getElementById('firegroup').innerHTML=''}	// 2005.06.16
     document.getElementById('speciesoccur').innerHTML=species_occur(subs)	// 2005.03.10
     document.getElementById('armregime').innerHTML=my_arm_regime	// DEH 2005.03.04
     document.getElementById('fireregime').innerHTML=fire_regime(subs)	// DEH 2005.01.20
     document.getElementById('treat_box').innerHTML=''		// DEH 2004.12.06
//   document.getElementById('fire_para').innerHTML='<pre>' + fire_text(fire) + '</pre>'	// 2005.02.17
     document.getElementById('fire_para').innerHTML=fire_text(fire)	// 2005.02.17
//     risky = '[undefined]'
//LOW
     if (subs == 'PJ/DG') {risky='Low risk'}
     if (subs == 'PP/DG') {risky='Low risk'}
     if (subs == 'DF/DG') {risky='Low risk'}
     if (subs == 'CoolP/DG') {risky='Low risk'}
     if (subs == 'CoolF/DG') {risky='Low risk'}
     if (subs == 'ColdF/DG') {risky='Low risk'}
     if (subs == 'PP/DS') {risky='Low risk'}
     if (subs == 'DF/DS') {risky='Low risk'}
     if (subs == 'CoolP/DS') {risky='Low risk'}
     if (subs == 'PP/DH') {risky='Low risk'}
     if (subs == 'ColdF/WS') {risky='Low risk'}

//INDETERMINATE
";
     if (subs == 'DF/DH')    {print "     if (subs == 'DF/DH') {risky='High risk'}\n"}
#    if ($manual_lc eq 'central_id_s' && subs == 'DF/DH')    {print "     if (subs == 'DF/DH') {risky='Low risk'}"};
     if ($manual_lc eq 'central_ut_s' || $manual_lc eq 'north_ut_s' || $manual_lc eq 'e_id_w_wy_s') {
       print "
     if (subs == 'CoolF/DS') {risky='High risk'} // (High risk in UT and E ID&W WY; Low risk otherwise)
     if (subs == 'ColdF/DS') {risky='High risk'} // (High risk in UT and E ID&W WY; Low risk otherwise)
";
     }
     else {
       print "
     if (subs == 'CoolF/DS') {risky='Low risk'} // (High risk in UT and E ID&W WY; Low risk otherwise)
     if (subs == 'ColdF/DS') {risky='Low risk'} // (High risk in UT and E ID&W WY; Low risk otherwise)
";
     }

     print"
//HIGH
     if (subs == 'CoolF/WH') {risky='High risk'}   // added 2004.11.19 DEH
     if (subs == 'CoolF/DH') {risky='High risk'}   // added 2004.11.19 DEH
     if (subs == 'CoolP/DH') {risky='High risk'}
     if (subs == 'DF/MH')    {risky='High risk'}
     if (subs == 'CoolP/MH') {risky='High risk'}
     if (subs == 'CH/DH')    {risky='High risk'}
     if (subs == 'CoolP/DH') {risky='High risk'}
     if (subs == 'CH/MH')    {risky='High risk'}
     if (subs == 'CoolF/MH') {risky='High risk'}
     if (subs == 'CH/WH')    {risky='High risk'}
     if (subs == 'CoolP/WH') {risky='High risk'}
     if (subs == 'ColdF/DH') {risky='High risk'}
     if (subs == 'ColdF/MH') {risky='High risk'}
     if (subs == 'ColdF/WH') {risky='High risk'}
     if (subs == 'CH/WF')    {risky='High risk'}
     if (subs == 'CoolF/WF') {risky='High risk'}
     if (subs == 'ColdF/WF') {risky='High risk'}
     if (subs == 'CH/WS')    {risky='High risk'}
     if (subs == 'CoolF/WS') {risky='High risk'}

     if (risky == 'Low risk') {
       document.getElementById('probpresent').innerHTML='Low'
       document.getElementById('probpresent_font').color='green'
     }
     if (risky == 'High risk') {
       document.getElementById('probpresent').innerHTML='HIGH'
       document.getElementById('probpresent_font').color='red'
     }
     if (risky == '') {
//     document.getElementById('probpresent').innerHTML='[undefined]'
       document.getElementById('probpresent').innerHTML=''
       document.getElementById('probpresent_font').color='black'
     }
  }
";

print <<'EOP';

function treat_changed (which_changed) {
// 2005.03.30
// Effects of fuels treatments in different Armillaria regimes
// (Effects will vary depending on the vigor of the host species):

// my_arm_regime:       armillaria regime ('low risk', 'High risk on seral species', 'High risk on climax species')
// which:               treatment (representing 'none', 'thin', 'rx', 'wild')

  treat=which_changed.value
//  myhead = ' armillaria regime '+my_arm_regime+', treatment '+treat+':<br>\\n'
  myhead = ''
  myb = ''
  mytail = ''
  regime = ''
  if (my_arm_regime == 'High risk on seral species') {regime = 'hseral'}
  if (my_arm_regime == 'High risk on climax species') {regime = 'hclimax'}
  if (my_arm_regime == 'Low risk') {regime = 'low'}

  if (regime == '') {                // Armillaria Regime:  UNKNOWN
    myb  = 'Armillaria risk is unknown. '
  }
  if (regime == 'low') {                // Armillaria Regime:  LOW
    myb  = 'Armillaria risk is LOW in this subseries. '
    myb += 'Pathogenic <i>A. ostoyae</i> is not likely to occur, so fuels treatments are not likely to affect Armillaria root disease, regardless of host tree species present.'
  }
  if (regime == 'hclimax') {            // Armillaria Regime:  HCLIMAX
    if (treat == 'none') {              // No treatment:
      myb  = 'The <b>no treatment</b> option avoids creating tree wounds that stress trees and generate root volatiles and nutrient substrates that foster Armillaria disease by either attracting fungal growth or enhancing root colonization. '
      myb += 'However, if disease mortality is already significant, the <b>no treatment</b> option will not reduce fuels, but will delay release of resistant species and may promote development of ladder fuels.'
    }
    if (treat == 'thin') {              // Thinning:
      myb  = 'Thinning treatments that favor climax or late-successional host trees will likely aggravate Armillaria root disease. '
      myb += 'Thinning treatments that create wounds on host trees will likely worsen Armillaria root disease on all species (Pankuch and others 2003). '
      myb += 'Thinning treatments that create a nutritional substrate (for example, stumps, dying roots, and woody debris) for <i>Armillaria</i> species may worsen Armillaria root disease. '
      myb += 'However, thinning that favors early seral species may reduce root disease over the long term. '
      myb += 'Greater spacing can improve tree vigor of seral species, which may increase tolerance to Armillaria root disease; however, opening up a stand too much may encourage regeneration of the susceptible climax and second seral species. '
      myb += 'Removal of the youngest trees that are most susceptible to <i>Armillaria</i> infection (Robinson and Morrison 2001) may help to reduce root disease.'
    }
    if (treat == 'rx') {                        // Prescribed burning:
      myb  = 'Because <i>Armillaria</i> species can reside deep in the soil and within large woody roots, superficial slash burning or prescribed fire is unlikely to eliminate the pathogen, '
      myb += 'although these treatments may reduce infection potential indirectly by removing highly susceptible host species that are readily killed by fire (Hadfield and others 1986) and by favoring other fungi antagonistic to <i>Armillaria</i> (Filip and others 2001). '
      myb += 'Mortality caused by <i>Armillaria</i> increases fuel loads. '
      myb += 'Prescribed fire may be used to reduce fuel loads and inoculum levels above ground by eliminating colonized substrates for growth of <i>Armillaria</i>, '
      myb += 'but it may increase damage to surface roots and create wounds that might facilitate <i>Armillaria</i> infection.'
    }
    if (treat == 'wildfire') {          // Wildfire:
      myb  = 'Wildfire is a natural result of fuels build-up in late successional forests and this process should help restore forest health in <i>Armillaria</i> '
      myb += 'mortality centers by fostering the regeneration of seral tree species. '
      myb += 'However, wildfire usually leaves injured roots that are suitable for <i>Armillaria</i> colonization. '
      myb += 'Wildfire impacts on <i>Armillaria</i> disease are likely dependent on the fire type (for example, crown fire vs. ground fire) and intensity. '
      myb += 'Thus, it would be advisable to make a post-fire assessment of colonizable substrates generated during wildfire to determine appropriate restoration strategies.'
    }
  }
  if (regime == 'hseral') {             // Armillaria Regime:  HSERAL
    if (treat == 'none') {              // No treatment:
      myb  = 'The <b>no treatment</b> option avoids creating tree wounds that stress trees and generate root volatiles and nutrient substrates that foster Armillaria disease by either attracting fungal growth or enhancing root colonization. '
      myb += 'However, if disease mortality is already significant, the <b>no treatment</b> option will not reduce fuels, but will delay release of resistant species and may promote development of ladder fuels.'
    }
    if (treat == 'thin') {              // Thinning:
      myb  = 'Thinning treatments that favor secondary seral host trees will likely aggravate Armillaria root disease. '
      myb += 'Thinning treatments that create wounds on host trees will likely worsen Armillaria root disease on all species (Pankuch and others 2003). '
      myb += 'Thinning treatments that create a nutritional substrate (for example, stumps, dying roots, and woody debris) for <i>Armillaria</i> species may worsen Armillaria root disease. '
      myb += 'However, thinning that favors early seral species may reduce the impact of root disease over the long term. '
      myb += 'Greater spacing can improve tree vigor, which may increase tolerance to Armillaria root disease; '
      myb += 'however, opening up a stand too much may encourage regeneration of the susceptible climax and second seral species. '
      myb += 'Removal of the youngest trees that are most susceptible to <i>Armillaria</i> infection (Robinson and Morrison 2001) may help to reduce root disease.'
    }
    if (treat == 'rx') {                // Prescribed burning:
      myb  = 'Because <i>Armillaria</i> species can reside deep in the soil and within large woody roots, superficial slash burning or prescribed fire is unlikely to eliminate the pathogen, '
      myb += 'although these treatments may reduce infection potential indirectly by removing highly susceptible host species that are readily killed by fire (Hadfield and others 1986) and by favoring other fungi antagonistic to <i>Armillaria</i> (Filip and others 2001). '
      myb += 'Mortality caused by <i>Armillaria</i> increases fuel loads. '
      myb += 'Prescribed fire may be used to reduce fuel loads and inoculum levels above ground by eliminating colonized substrates for growth of <i>Armillaria</i>, '
      myb += 'but it may increase damage to surface roots and create wounds that might facilitate <i>Armillaria</i> infection.'
    }
    if (treat == 'wildfire') {          // Wildfire:
      myb  = 'Wildfire is a natural result of fuels build-up in late successional forests and this process should help restore forest health in <i>Armillaria</i> mortality centers by fostering the regeneration of early seral tree species. '
      myb += 'However, wildfire usually leaves injured roots that are suitable for <i>Armillaria</i> colonization. '
      myb += 'Wildfire impacts on Armillaria disease are likely dependent on the fire type (for example, crown fire vs. ground fire) and intensity. '
      myb += 'Thus, it would be advisable to make a post-fire assessment of colonizable substrates generated during wildfire to determine appropriate restoration strategies.'
    }
  }
  document.getElementById('treat_box').innerHTML=myhead+myb+mytail
  if (treat=='') document.getElementById('fueltreat').innerHTML='Fuel Treatment'
  if (treat=='none') document.getElementById('fueltreat').innerHTML='No Treatment'
  if (treat=='thin') document.getElementById('fueltreat').innerHTML='Thinning'
  if (treat=='rx') document.getElementById('fueltreat').innerHTML='Prescribed Fire'
  if (treat=='wildfire') document.getElementById('fueltreat').innerHTML='Wildfire'
}

  function pop_fire_regime () {

// popup window for fire regime explanation

    newin = window.open('','fr','width=640,scrollbars=yes,resizable=1')
    var newWin = newin.document.open()
    if (newWin != null) {
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>ART Fire Regimes</title>')
      newin.document.writeln('  <style>')
      newin.document.writeln('   BODY')
      newin.document.writeln('   {scrollbar-base-color:666666;scrollbar-face-color:#333333;scrollbar-highlight-color:#333333;scrollbar-shadow-color:666666;scrollbar-dark-shadow-color:ffffcc;scrollbar-arrow-color:ff6600}')
      newin.document.writeln('   .question {color:ffffcc}')
      newin.document.writeln('   .header {color:ffffcc}')
      newin.document.writeln('   .highlight {font-weight:bold}')
      newin.document.writeln('  </style>')
      newin.document.writeln(' </HEAD>')
      newin.document.writeln(' <body bgcolor="ivory" onLoad="top.window.focus()" link="white" vlink="white">')
      newin.document.writeln('  <font face="tahoma, sans serif">')
      newin.document.writeln(' <center>')
      newin.document.writeln('  <h3><i>A</i>RT Fire Regimes</h3>')
      newin.document.writeln(' </center>')
      newin.document.writeln(' Fire behavior in western forests has been classified into 5 fire regimes based on moisture and temperature gradients determined by plant associations.')
      newin.document.writeln(' <br><br>')
      newin.document.writeln(' <img src="/fuels/art/images/FireRegimes.gif" width="498" height="461">')
      newin.document.writeln(' <br><font size=-2>')
      newin.document.writeln('  McDonald, G.I., Harvey, A.E., and Tonn, J.R. 2000.')
      newin.document.writeln('  <i>Fire, competition and forest pest: Landscape treatment to sustain ecosystem function.</i>')
      newin.document.writeln('  In: Neuenschwander, L.F. and Ryan, K.C., eds.')
      newin.document.writeln('  <b>Crossing the millennium: Integrating spatial technologies and ecological principles for a new age in fire management: proceedings from the Joint Fire Conference and Workshop; Volume 2.</b>')
      newin.document.writeln('  Moscow, ID: University of Idaho and the International Association of Wildland Fire, 195-211.')
      newin.document.writeln(' </font>')
      newin.document.writeln('<!--tool bar begins--><p>')
      newin.document.writeln('  <center>')
      newin.document.writeln('  <table bgcolor="#666666" width="20%" border="0" cellspacing="1" cellpadding="5" align="center">')
      newin.document.writeln('   <tr>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      newin.document.writeln('     onMouseOver="this.style.backgroundColor=\'#000000\';"')
      newin.document.writeln('     onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln('     <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln('      <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.print()">Print me</a>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      newin.document.writeln('     onMouseOver="this.style.backgroundColor=\'#000000\';"')
      newin.document.writeln('     onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln('     <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln('      <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.close()">Close me</a>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td>')
      newin.document.writeln('   </tr>')
      newin.document.writeln('  </table>')
      newin.document.writeln('<!--tool bar ends-->')
      newin.document.writeln('  </center>')
      newin.document.writeln(' </body>')
      newin.document.writeln('</html>')
      newin.document.close()
    }
  }
  function pop_arm_regime () {

// popup window for Armillaria regime explanation

    newin = window.open('','ar','width=640,scrollbars=yes,resizable=1')
    var newWin = newin.document.open()
    if (newWin != null) {
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>ART Armillaria Regimes</title>')
      newin.document.writeln('  <style>')
      newin.document.writeln('   BODY')
      newin.document.writeln('   {scrollbar-base-color:666666;scrollbar-face-color:#333333;scrollbar-highlight-color:#333333;scrollbar-shadow-color:666666;scrollbar-dark-shadow-color:ffffcc;scrollbar-arrow-color:ff6600}')
      newin.document.writeln('   .question {color:ffffcc}')
      newin.document.writeln('   .header {color:ffffcc}')
      newin.document.writeln('   .highlight {font-weight:bold}')
      newin.document.writeln('  </style>')
      newin.document.writeln(' </HEAD>')
      newin.document.writeln(' <body bgcolor="ivory" onLoad="top.window.focus()" link="white" vlink="white">')
      newin.document.writeln('  <font face="tahoma, sans serif">')
      newin.document.writeln(' <center>')
      newin.document.writeln('  <h3><i>A</i>RT <i>Armillaria</i> Regimes</h3>')
      newin.document.writeln(' </center>')
      newin.document.writeln(' ')
      newin.document.writeln(' <i>Armillaria</i> regime is the relative likelihood of Armillaria impact on a stand, which is dependent on the subseries of the stand and the seral and climax tree species found on the site.<br><br>')
      newin.document.writeln(' <img src="/fuels/art/images/ArmRegimes.gif" width="478" height="438">')
      newin.document.writeln(' <br><font size=-2>')
      newin.document.writeln('  McDonald, G.I., Harvey, A.E., and Tonn, J.R. 2000.')
      newin.document.writeln('  <i>Fire, competition and forest pest: Landscape treatment to sustain ecosystem function.</i>')
      newin.document.writeln('  In: Neuenschwander, L.F. and Ryan, K.C., eds.')
      newin.document.writeln('  <b>Crossing the millennium: Integrating spatial technologies and ecological principles for a new age in fire management: proceedings from the Joint Fire Conference and Workshop; Volume 2.</b>')
      newin.document.writeln('  Moscow, ID: University of Idaho and the International Association of Wildland Fire, 195-211.')
      newin.document.writeln(' </font>')
      newin.document.writeln('<!--tool bar begins--><p>')
      newin.document.writeln('  <center>')
      newin.document.writeln('  <table bgcolor="#666666" width="20%" border="0" cellspacing="1" cellpadding="5" align="center">')
      newin.document.writeln('   <tr>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      newin.document.writeln('     onMouseOver="this.style.backgroundColor=\'#000000\';"')
      newin.document.writeln('     onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln('     <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln('      <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.print()">Print me</a>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      newin.document.writeln('     onMouseOver="this.style.backgroundColor=\'#000000\';"')
      newin.document.writeln('     onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln('     <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln('      <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.close()">Close me</a>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td>')
      newin.document.writeln('   </tr>')
      newin.document.writeln('  </table>')
      newin.document.writeln('<!--tool bar ends-->')
      newin.document.writeln('  </center>')
      newin.document.writeln(' </body>')
      newin.document.writeln('</html>')
      newin.document.close()
    }
  }

  function explain_ht () {

// popup window for habitat type explanation

    newin = window.open('','ht','width=640,scrollbars=yes,resizable=1')
    var newWin = newin.document.open()
    if (newWin != null) {
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>ART Habitat type</title>')
      newin.document.writeln('  <style>')
      newin.document.writeln('   BODY')
      newin.document.writeln('   {scrollbar-base-color:666666;scrollbar-face-color:#333333;scrollbar-highlight-color:#333333;scrollbar-shadow-color:666666;scrollbar-dark-shadow-color:ffffcc;scrollbar-arrow-color:ff6600}')
      newin.document.writeln('   .question {color:ffffcc}')
      newin.document.writeln('   .header {color:ffffcc}')
      newin.document.writeln('   .highlight {font-weight:bold}')
      newin.document.writeln('  </style>')
      newin.document.writeln(' </HEAD>')
      newin.document.writeln(' <body bgcolor="ivory" onLoad="top.window.focus()" link="white" vlink="white">')
      newin.document.writeln('  <font face="tahoma, sans serif">')
      newin.document.writeln(' <center>')
      newin.document.writeln('  <h3><i>A</i>RT Habitat type</h3>')
      newin.document.writeln(' </center>')
      newin.document.writeln('  Associations of plant species known as <em>habitat types</em> are our best indicators of')
      newin.document.writeln('  site conditions influenced by the interaction of topography, soils, temperature, and precipitation patterns. ')
      newin.document.writeln('  Habitat types are made up of the')
      newin.document.writeln('  <ul><li>climax tree species, and</li>')
      newin.document.writeln('      <li>forest floor vegetation (shrub, herb, etc.)</li></ul>')
      newin.document.writeln('  -- for example, grand fir/ninebark habitat type (ABGR/PHMA).<br><br>')
      newin.document.writeln('  Climax series (species) are divided into <em>subseries</em>')
      newin.document.writeln('  by grouping habitat types along a moisture gradient.')
      newin.document.writeln('  These subseries can be used as indicators of Armillaria distribution and activity (<i>Armillaria</i> regimes).')
      newin.document.writeln('  <br><br>')
      newin.document.writeln('  Plant species are encoded as follows.')
      newin.document.writeln('  <br><center><br>')
      newin.document.writeln('  <table>')
      newin.document.writeln('   <tr><th bgcolor="black"><font color="white" size=2>Code</font></th><th bgcolor="black"><font color="white" size=2>Species</font></th>')
      newin.document.writeln('       <th bgcolor="black"><font color="white" size=2>Code</font></th><th bgcolor="black"><font color="white" size=2>Species</font></th></tr>')
EOP
open HT, '<xwalk/habtypes';
 @habs=<HT>;
close HT;
# print @habs;

$count = $#habs;
$half = $count/2;

# for ($i=0; $i=$i+1; $i<=$half) {
$i=0;
while ($i<$half) {

   ($code,$rest) = split '\t', @habs[$i];
   chomp $rest;
   print '      newin.document.writeln(\'   <tr><th><font face="tahoma, sans serif" size=1>',$code,'</font></th><td><font face="tahoma, sans serif" size=1>',$rest,'</font></td>';
   ($code,$rest) = split '\t', @habs[$i+$half+1];
   chomp $rest;
   print '   <th><font face="tahoma, sans serif" size=1>',$code,'</font></th><td><font face="tahoma, sans serif" size=1>',$rest,"</font></td></tr>\')\n";
   $i=$i+1;
}

print <<'EOP2';
      newin.document.writeln('  </table>')
      newin.document.writeln('  <br></center><br>')
      newin.document.writeln('<!--tool bar begins--><p>')
      newin.document.writeln('  <center>')
      newin.document.writeln('  <table bgcolor="#666666" width="20%" border="0" cellspacing="1" cellpadding="5" align="center">')
      newin.document.writeln('   <tr>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      newin.document.writeln('     onMouseOver="this.style.backgroundColor=\'#000000\';"')
      newin.document.writeln('     onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln('     <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln('      <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.print()">Print me</a>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      newin.document.writeln('     onMouseOver="this.style.backgroundColor=\'#000000\';"')
      newin.document.writeln('     onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln('     <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln('      <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.close()">Close me</a>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td>')
      newin.document.writeln('   </tr>')
      newin.document.writeln('  </table>')
      newin.document.writeln('<!--tool bar ends-->')
      newin.document.writeln('  </center>')
      newin.document.writeln(' </body>')
      newin.document.writeln('</html>')
      newin.document.close()
    }
  }

  function explain_role () {

// popup window for conifer role
// populate window with inline text.

    newin = window.open('','role','width=340,scrollbars=yes,resizable=1')
    var newWin = newin.document.open()
    if (newWin != null) {
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>ART conifer role coding</title>')
      newin.document.writeln('  <style>')
      newin.document.writeln('   BODY')
      newin.document.writeln('   {scrollbar-base-color:666666;scrollbar-face-color:#333333;scrollbar-highlight-color:#333333;scrollbar-shadow-color:666666;scrollbar-dark-shadow-color:ffffcc;scrollbar-arrow-color:ff6600}')
      newin.document.writeln('   .question {color:ffffcc}')
      newin.document.writeln('   .header {color:ffffcc}')
      newin.document.writeln('   .highlight {font-weight:bold}')
      newin.document.writeln('  </style>')
      newin.document.writeln(' </HEAD>')
      newin.document.writeln(' <body bgcolor="ivory" onLoad="top.window.focus()" link="white" vlink="white">')
      newin.document.writeln('  <font face="tahoma, sans serif">')
      newin.document.writeln('   <center>')
      newin.document.writeln('    <h3><i>A</i>RT conifer role coding</h3>')
      newin.document.writeln('   </center>')
      newin.document.writeln('   <br>')
      newin.document.writeln('   <font size=-1>')
      newin.document.writeln('    Role refers to the ecological or successional role played by the species:')
      newin.document.writeln('    <br>')
      newin.document.writeln('    C = major climax species<br>')
      newin.document.writeln('    c = minor climax species<br>')
      newin.document.writeln('    S = major (primary) seral species<br>')
      newin.document.writeln('    s = minor seral species<br>')
      newin.document.writeln('    a = accidental occurrence (no significant ecological role)')
      newin.document.writeln('   </font>')
      newin.document.writeln('   <br><br>')
      newin.document.writeln('<!--tool bar begins--><p>')
      newin.document.writeln('  <table bgcolor="#666666" width="20%" border="0" cellspacing="1" cellpadding="5" align="center">')
      newin.document.writeln('   <tr>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      newin.document.writeln('     onMouseOver="this.style.backgroundColor=\'#000000\';"')
      newin.document.writeln('     onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln('     <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln('      <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.print()">Print me</a>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      newin.document.writeln('     onMouseOver="this.style.backgroundColor=\'#000000\';"')
      newin.document.writeln('     onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln('     <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln('      <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.close()">Close me</a>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td>')
      newin.document.writeln('   </tr>')
      newin.document.writeln('  </table>')
      newin.document.writeln('<!--tool bar ends-->')
      newin.document.writeln('  </center>')
      newin.document.writeln(' </body>')
      newin.document.writeln('</html>')
      newin.document.close()
    } 
  }

  function explain_subseries () {

// popup window for subseries table
// populate window with inline text.

    newin = window.open('','subseries','width=340,scrollbars=yes,resizable=1')
    var newWin = newin.document.open()
    if (newWin != null) {
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>ART subseries coding</title>')
      newin.document.writeln('  <style>')
      newin.document.writeln('   BODY')
      newin.document.writeln('   {scrollbar-base-color:666666;scrollbar-face-color:#333333;scrollbar-highlight-color:#333333;scrollbar-shadow-color:666666;scrollbar-dark-shadow-color:ffffcc;scrollbar-arrow-color:ff6600}')
      newin.document.writeln('   .question {color:ffffcc}')
      newin.document.writeln('   .header {color:ffffcc}')
      newin.document.writeln('   .highlight {font-weight:bold}')
      newin.document.writeln('  </style>')
      newin.document.writeln(' </HEAD>')
      newin.document.writeln(' <body bgcolor="ivory" onLoad="top.window.focus()" link="white" vlink="white">')
      newin.document.writeln('  <font face="tahoma, sans serif">')
      newin.document.writeln(' <center>')
      newin.document.writeln(' <h3><i>A</i>RT subseries coding</h3>')
      newin.document.writeln(' <br><br>')
      newin.document.writeln('  <table align=center border=1>')
      newin.document.writeln('  <tr><th colspan=2 bgcolor="#006009"><font color="#99ff00">Soil-temperature regimes</font></th>')
      newin.document.writeln('      <th bgcolor="#006009"><font color="#99ff00">/</font></th>')
      newin.document.writeln('      <th colspan=2 bgcolor="#006009"><font color="#99ff00">Soil-moisture regimes</font></th></tr>')
      newin.document.writeln('  <tr><td> ColdF </td><td>Cold Fir</td><td></td><td>WS</td><td>Wet Shrub</td></tr>')
      newin.document.writeln('  <tr><td> CoolF </td><td>Cool Fir</td><td></td><td>WH</td><td>Wet Herb</td></tr>')
      newin.document.writeln('  <tr><td> CH </td><td>Cedar-Hemlock</td><td></td><td>WF</td><td>Wet Fern</td></tr>')
      newin.document.writeln('  <tr><td> CoolP </td><td>Cool Pine</td><td></td><td>MH</td><td>Moist Herb</td></tr>')
      newin.document.writeln('  <tr><td> DF </td><td>Douglas-fir</td><td></td><td>DH</td><td>Dry Herb</td></tr>')
      newin.document.writeln('  <tr><td> PP </td><td>Ponderosa Pine</td><td></td><td>DS</td><td>Dry Shrub</td></tr>')
      newin.document.writeln('  <tr><td> PJ </td><td>Pinyon Juniper</td><td></td><td>DG</td><td>Dry Grass</td></tr>')
      newin.document.writeln('  </table>')
      newin.document.writeln('  <br><br>')
      newin.document.writeln('      <font size=-1>')
      newin.document.writeln('       Defined by soil temperature -- soil moisture regimes, <i>subseries</i> combine habitat types to more easily')
      newin.document.writeln('       explain ecological relationships.')
      newin.document.writeln('       Climax series from habitat types indicate the soil temperature regime, while')
      newin.document.writeln('       understory plants indicate the soil moisture regime.')
      newin.document.writeln('      </font>')
      newin.document.writeln('<!--tool bar begins--><p>')
      newin.document.writeln('  <table bgcolor="#666666" width="20%" border="0" cellspacing="1" cellpadding="5" align="center">')
      newin.document.writeln('   <tr>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      newin.document.writeln('     onMouseOver="this.style.backgroundColor=\'#000000\';"')
      newin.document.writeln('     onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln('     <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln('      <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.print()">Print me</a>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      newin.document.writeln('     onMouseOver="this.style.backgroundColor=\'#000000\';"')
      newin.document.writeln('     onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln('     <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln('      <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.close()">Close me</a>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td>')
      newin.document.writeln('   </tr>')
      newin.document.writeln('  </table>')
      newin.document.writeln('<!--tool bar ends-->')
      newin.document.writeln('  </center>')
      newin.document.writeln(' </body>')
      newin.document.writeln('</html>')
      newin.document.close()
    } 
  }

  function explain_firegroup () {

// popup window for fire group
// populate window with inline text.

    newin = window.open('','firegroup','width=340,scrollbars=yes,resizable=1')
    var newWin = newin.document.open()
    if (newWin != null) {
      newin.document.writeln('<HTML>')
      newin.document.writeln(' <HEAD>')
      newin.document.writeln('  <title>ART fire group</title>')
      newin.document.writeln('  <style>')
      newin.document.writeln('   BODY')
      newin.document.writeln('   {scrollbar-base-color:666666;scrollbar-face-color:#333333;scrollbar-highlight-color:#333333;scrollbar-shadow-color:666666;scrollbar-dark-shadow-color:ffffcc;scrollbar-arrow-color:ff6600}')
      newin.document.writeln('   .question {color:ffffcc}')
      newin.document.writeln('   .header {color:ffffcc}')
      newin.document.writeln('   .highlight {font-weight:bold}')
      newin.document.writeln('  </style>')
      newin.document.writeln(' </HEAD>')
      newin.document.writeln(' <body bgcolor="ivory" onLoad="top.window.focus()" link="white" vlink="white">')
      newin.document.writeln('  <font face="tahoma, sans serif">')
      newin.document.writeln(' <center>')
      newin.document.writeln(' <h3><i>A</i>RT fire group</h3>')
      newin.document.writeln(' <br><br>')
      newin.document.writeln(' <b>Fire Groups</b>: Clusters of habitat types based on response of dominant tree species to fire, potential frequency of fire, and similarity in post-fire succession.')
      newin.document.writeln('<!--tool bar begins--><p>')
      newin.document.writeln('  <table bgcolor="#666666" width="20%" border="0" cellspacing="1" cellpadding="5" align="center">')
      newin.document.writeln('   <tr>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      newin.document.writeln('     onMouseOver="this.style.backgroundColor=\'#000000\';"')
      newin.document.writeln('     onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln('     <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln('      <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.print()">Print me</a>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td>')
      newin.document.writeln('    <td align="center" bgcolor="#333333"')
      newin.document.writeln('     onMouseOver="this.style.backgroundColor=\'#000000\';"')
      newin.document.writeln('     onMouseOut="this.style.backgroundColor=\'\';">')
      newin.document.writeln('     <font face="verdana,arial,helvetica" size="1">')
      newin.document.writeln('      <img src="/fswepp/images/shift_anim_on.gif" width=6 height=6 border=0>&nbsp;&nbsp;<a href="javascript:self.close()">Close me</a>')
      newin.document.writeln('     </font>')
      newin.document.writeln('    </td>')
      newin.document.writeln('   </tr>')
      newin.document.writeln('  </table>')
      newin.document.writeln('<!--tool bar ends-->')
      newin.document.writeln('  </center>')
      newin.document.writeln(' </body>')
      newin.document.writeln('</html>')
      newin.document.close()
    } 
  }

EOP2

print "  </script>
 </head>
 <body link='#006600' vlink='#006600'>
  <font face='tahoma, trebuchet, comic sans, arial'>
   <center>
    <table width=100%>
     <tr>
      <td align='left'>
       <a href='/fuels/art/artlite.html'><img src='/fuels/art/images/artpics.jpg' width=77 height=100 align='left' border=0></a>
      </td>
      <td align='center' valign='center'>   <!-- bgcolor='#006009' -->
       <!-- font color='#99ff00' -->
        <h3>Armillaria Response Tool Lite (Stand-Level Version)</h3>
 <!-- img src='/fswepp/images/underc.gif' border=0 width=532 height=34 -->
       <!-- /font -->
      </td>
     </tr>
    </table>
   </center><br>
   The <em>Stand-Level version</em> of <i>A</i>RT cannot aid the user in
   verifying the assigned habitat type, nor can it indicate heterogeneity within stands. The user assumes responsibility for habitat type accuracy.
   <br><br>
   <table>
    <tr>
     <td bgcolor='ivory' valign='top' align='center'>
";

    if (-e "xwalk/$manual_lc") {
      print "      <form name='art'>\n";
#      print "       <img src='/fuels/art/images/spacer.gif' name='risk_graphic' width=126 height=27 alt='' border=0><br>\n";
#      print "       ($manual)<br>\n";
#      print "       <b>Stand Habitat&nbsp;Types</b> <a href='javascript:explain_ht()'><img src='/fswepp/images/quest.gif' width='14' height='12' border='0'></a><br>\n";
      print "       <b>Stand Habitat&nbsp;Types<br>\n";
#      print "       for $manual<br>\n";
      print "       for $location<br>\n";
#      print  @manual_cite_short{$manual_lc},"<br>\n";
      print "        <select size=15 name='htxsubseries' onChange=\"javascript:ht_changed(this,'risk')\">\n";
      print "         <option value='' selected>(Select one)</option>\n";
#      print "         <option value=''>-- HIGH RISK -------</option>\n";	# 2004.11.22 DEH
      $high=1;
      open MAN, "<xwalk/$manual_lc";
        while (<MAN>) {
#         print <MAN>;
          chomp;
          if ($_ ne '' && substr($_,0,1) ne '#') {
            ($habitat,$over,$under,$subseries,$risk_hl,$fire_group) = split '\t',$_;
#           if ($high && $risk_hl eq 'L') {					# 2004.11.22 DEH
#             $high = 0;
#              print "         <option value=''>-- LOW RISK -------</option>\n";
#           }
# 2004.12.02 DEH 2004.12.15 DEH add $habitat to option value
#           print "         <option value='$subseries'>$habitat</option>\n";
            print "         <option value='$subseries:$fire_group:$habitat'>$habitat</option>\n";
          }
        }
      close MAN;
      print "        </select>\n";
    }
    print "
      </form>
";

# 2004.12.02 DEH
#     print "      <br><br>
#       <b>Subseries
#       <a href=\"javascript:explain_subseries()\"
#             onMouseOver=\"window.status='Explain subseries';return true\"
#             onMouseOut=\"window.status='Armillaria Response Tool';return true\">
#             <img src='/fswepp/images/quest.gif' width='14' height='12' border='0'></a></b>
#       <br>
#       <input type='text' name='subseries' size=12 value='      ' disabled><br>
#       <b>Probability of Armillaria presence
#       <img src='/fswepp/images/quest.gif' width='14' height='12' border='0'></b>
#       <br>
#       <input type='text' name='risk' size=12 value='        ' disabled><br>
#       <b>Fire Group</b><br>
#       <input type='text' name='fgroup' size=20 value='	       ' disabled><br>
#       <br><br>

   if ($manual eq '') {$s_=' selected'} else {$s_=''}
   if ($manual eq 'Colville') {$s_col=' selected'} else {$s_col=''}
   if ($manual eq 'Okanogan') {$s_ok=' selected'} else {$s_ok=''}
   if ($manual eq 'Wenatchee') {$s_wen=' selected'} else {$s_wen=''}
   if ($manual eq 'E_Mt_Hood') {$s_emh=' selected'} else {$s_emh=''}
   if ($manual eq 'Blue_Mt') {$s_bmt=' selected'} else {$s_bmt=''}
   if ($manual eq 'Wallowa') {$s_wal=' selected'} else {$s_wal=''}
   if ($manual eq 'North_ID') {$s_nid=' selected'} else {$s_nid=''}
   if ($manual eq 'Montana') {$s_mt=' selected'} else {$s_mt=''}
   if ($manual eq 'Central_ID') {$s_cid=' selected'} else {$s_cid=''}
   if ($manual eq 'E_ID_W_WY') {$s_eid=' selected'} else {$s_eid=''}
   if ($manual eq 'North_UT') {$s_nut=' selected'} else {$s_nut=''}
   if ($manual eq 'Central_UT') {$s_cut=' selected'} else {$s_cut=''}

    print "
      <br><hr><br>
      <form method='post' action=''>
       Stand Location &nbsp;[<a href='/fuels/art/artlite.html'>map</a>]<br>
        <select name='manual' size=13 onChange='javascript:submit()'>
          <option value='' $s_>(Select one)</option>
          <option value='Colville' $s_col>Colville NF</option>
          <option value='Okanogan' $s_ok>Okanogan NF</option>
          <option value='Wenatchee' $s_wen>Wenatchee NF</option>
           <option value='E_Mt_Hood' $s_emh>Mt. Hood NF</option>
          <!--area alt='Central Oregon ?manual=Central_OR -->
           <option value='Blue_Mt' $s_bmt>Blue &amp; Ochoco Mtns</option>
           <option value='Wallowa' $s_wal>Wallowa Province</option>
           <option value='North_ID' $s_nid>Northern Idaho</option>
           <option value='Montana' $s_mt>Montana</option>
           <option value='Central_ID' $s_cid>Central Idaho</option>
           <option value='E_ID_W_WY' $s_eid>Eastern Idaho &amp; Western Wyoming</option>
           <option value='North_UT' $s_nut>Northern Utah</option>
           <option value='Central_UT' $s_cut>Central &amp; Southern Utah</option>
         </select>
        </form>
       </b>
       <br><hr><br>
  Fuels Treatment<br>
  <select name='treatment' size=5 onChange=\"javascript:treat_changed(this)\">
   <option value='' selected>(Select one)</option>
   <option value='none'>No treatment</option>
   <option value='thin'>Thinning</option>
   <option value='rx'>Prescribed burning</option>
   <option value='wildfire'>Wildfire</option>
  </select>
       <br><hr><br>
     </td>
     <td valign='top'>
      <font face=\"tahoma, sans serif\">
<!-- NEW STUFF -->

<form name='results'>

<table border=1 width=100%>
 <tr>
  <td bgcolor='lightyellow'>
  <font face='tahoma'>
    <b><a href='javascript:explain_ht()'>Habitat Type</a>:</b>
<span id='habitattype'></span>
    </font>
  </td>
 </tr>
</table>
<table border=1 width=100%>
 <tr>
  <td bgcolor='lightyellow'>
    <b>
       <a href=\"javascript:explain_subseries()\"
             onMouseOver=\"window.status='Explain subseries';return true\"
             onMouseOut=\"window.status='Armillaria Response Tool';return true\">Subseries</a>:</b>
<span id='subseries'></span>
       <!-- input disabled type='text' size='15' name='subseries' value='' -->
    <br><br>
  </td>
 </tr>
</table>
<table border=1 width=100%>
 <tr>
  <td bgcolor='ivory'>
 <a onMouseOver=\"window.status='Currently for Central ID only';return true\"
             onMouseOut=\"window.status='Armillaria Response Tool';return true\"></a>
    <b><a href=\"javascript:explain_firegroup()\">Fire Group</a>:</b>
<span id='firegroup'> </span>
<span id='firetext'></span>
 <!-- input disabled type='text' name='firegroup' size='50' value='' -->
    <blockquote>
     <!-- textarea ROWS=2 COLS=65 id='firetext' name='firetext' WRAP=physical -->
     <!-- /textarea -->
<!-- DEH 2005.01.11 -->
<!-- @firemanual{mymanual} -->
<!-- DEH 2005.01.11 -->
     <table>
      <tr>
        <td bgcolor='lightyellow'>
         <font size=-1>
          <span id='fire_para'></span>
        </font>
       </td>
      </tr>
     </table>
    </blockquote>
  </td>
 </tr>
 <tr>
  <td bgcolor='ivory'>
   <b><a href='javascript:pop_fire_regime()'>Fire Regime</a>:</b>
<span id='fireregime'></span>
  </td>
 </tr>
</table>

  <font size=-1 color='crimson'>
";
   print &special_notes;

   print "
 </font>
<table border=1 width=100%>
 <tr>
  <td bgcolor='ivory'>
    <b>Probability of <i>Armillaria</i> presence:</b>
    <font id='probpresent_font'>
     <span id='probpresent'></span>
    </font>
    <!-- input disabled type='text' name='risk_prob' value='' -->
    in this subseries.
    <br><br>
     <a onMouseOver=\"window.status='Currently for Central ID only';return true\"
             onMouseOut=\"window.status='Armillaria Response Tool';return true\"></a>

     <b><a href='javascript:pop_arm_regime()'><i>Armillaria</i> regime</a>:</b>
     <span id='armregime'></span>
     <br><br>
    <font size=-1>
     The following conifer species may occur in the 
     <span id='subseries2'></span>
      <!-- input disabled type='text' name='subseries_2' value='' -->
     subseries for $manual
    </font>
    <blockquote>
     <span id='speciesoccur'></span>
     <!-- textarea ROWS=9 COLS=79 id='conifers' name='conifers' WRAP=physical -->
     <!-- /textarea -->
    </blockquote>
  </td>
 </tr>
</table>
<table width=100% border=1>
 <tr>
  <td bgcolor='lightyellow'>
   <a onMouseOver=\"window.status='Currently for Central ID only';return true\"
             onMouseOut=\"window.status='Armillaria Response Tool';return true\"></a>
  <b>Likely Impact of 
  <span id='fueltreat'>Fuels Treatment</span>
  on Armillaria Disease</b>:

  <!-- select name='treatment' onChange=\"javascript:treat_changed(this)\" -->
  <!-- /select -->

  <table width=100% border=1 cellpadding=6>
   <tr>
    <td bgcolor=yellow>
     <font size=-1>
<span id='treat_box'></span>
     </font>
    </td>
   </tr>
  </table>
 </td>
</tr>
</table>
</form>
   <br>


<!-- NEW STUFF -->
      </font>
     </td>
    </tr>
   </table>
   <table width=100% border=1>
    <tr>
     <td bgcolor='ivory'>
      <font size=2>
       <b>This analysis assumes that user habitat typing has been accurately based on</b><br>
       @manual_cite_full{$manual_lc}
      </font>
     </td>
    </tr>
   </table>
   <hr>
   <table width=100%>
    <tr>
     <td>
      <font size=1>
       <i>A</i>RT Lite: Armillaria Response Tool Lite (Stand-Level) version
       <a href='javascript:popuphistory()'>$version</a><br>
       USDA Forest Service, Rocky Mountain Research Station<br>
       Microbial Processes -- Debbie Page-Dumroese, Project Leader, Moscow, ID<br>
       Environmental Consequences -- Elaine Sutherland, Team Leader, Missoula, MT<br>
       <a href='http://forest.moscowfsl.wsu.edu/fuels/'>http://forest.moscowfsl.wsu.edu/fuels/</a>
      </font>
     </td>
     <td align='right' valign='top'>
      <font size=1>
        <i>A</i>RT <a href='http://forest.moscowfsl.wsu.edu/fuels/art/docs/art_short.html' target='_docs'>overview</a> (HTM)<br>
        [6 MB] Draft <i>A</i>RT <a href='http://forest.moscowfsl.wsu.edu/smp/docs/docs/ART-GTR-draft_web.pdf' target='_docs'>Documentation</a> (PDF)<br>
        [210 KB] <i>A</i>RT <a href='http://www.fs.fed.us/rm/pubs/rmrs_rn023_13.pdf' target='_docs'>Fact Sheet</a> (PDF)<br>
        [651 KB] <a href='http://forest.moscowfsl.wsu.edu/cgi-bin/smp/library/searchsmppub.pl?pub=2000a' target='_docs'>McDonald et al. 2000</a> (PDF)
      </font>
     </td>
    </tr>
   </table>
  </font>
 </body>
</html>
";
 

# ===========================

sub special_notes {
#  $manual
  if ($manual eq 'North_ID' || $manual eq 'Blue_Mt' || $manual eq 'Montana' || $manual eq 'Colville') {
    return 'Because of White Pine Blister Rust, PSME & ABGR have replaced the more Armillaria-tolerant PIMO as primary serals in subseries where PIMO appears.  Restoration to PIMO following removal of PSME &amp; ABGR will help to limit future damage by Armillaria in those subseries.'
  }
  if ($manual eq 'Central_ID') {
    return 'To date, <i>A. ostoyae</i> has not been identified anywhere in Central Idaho.'
  }
  if ($manual eq 'Wenatchee') {
    return 'Little is known about <i>Armillaria</i> tolerance by subalpine larch (LALY); however, in harsh high-elevation (cold, dry) LALY sites, risk is minimal.'
  }
  return ''
}

sub define_manuals {

# In: 
# Out: @manual_cite_short hash (index is $manual_lc)
#      @manual_cite_full hash (index is $manual_lc)

# First the short citations
  @manual_cite_short{'north_id_s'}='S.V. Cooper and others, 1991. Northern Idaho.';
  @manual_cite_short{'blue_mt_s'}='C.G. Johnson and R.R. Clausnitzer, 1991. Blue and Ochoco Mountains.';
  @manual_cite_short{'wallowa_s'}='C.G. Johnson and S.A. Simon, 1987. Wallowa-Snake Province.';
  @manual_cite_short{'north_ut_s'}='R.L. Mauk and J.A. Henderson, 1984. Northern Utah.';
  @manual_cite_short{'montana_s'}='R.D. Pfister and others, 1977. Montana.';
  @manual_cite_short{'central_id_s'}='R. Steele and others, 1981. Central Idaho.';
  @manual_cite_short{'e_id_w_wy_s'}='R. Steele and others 1983, Eastern Idaho and Western Wyoming. ';
  @manual_cite_short{'e_mt_hood_s'}='C. Topik  and others 1988, Mt Hood National Forest.';
  @manual_cite_short{'wenatchee_s'}='T.R. Lillybridge and others 1995. Wenatchee National Forest';
  @manual_cite_short{'okanogan_s'}='C.K. Williams and T.R. Lillybridge, 1983. Okanogan National Forest. ';
  @manual_cite_short{'colville_s'}='C.K. Williams and others, 1990. Colville National Forest.';
  @manual_cite_short{'central_ut_s'}='A.P. Youngblood and R.L. Mauk, 1985. Central and Southern Utah';
# Now the full citations
  @manual_cite_full{'north_id_s'}='Cooper, S.V., K.E. Neiman, R. Steele and D.W. Roberts. 1991. <b>Forest Habitat Types of Northern Idaho: A Second Approximation.</b> Gen. Tech. Rep. INT-GTR-236. Ogden, UT: U.S. Department of Agriculture, Forest Service, Intermountain Research Station. 143&nbsp;p.';
  @manual_cite_full{'blue_mt_s'}='Johnson, C.G. and R.R. Clausnitzer. 1991. <b>Plant Associations of the Blue and Ochoco Mountains.</b> Report R6-ERW-TP-036-92. Portland, OR: U.S. Department of Agriculture, Forest Service, Pacific Northwest Region. 164&nbsp;p.';
  @manual_cite_full{'wallowa_s'}='Johnson, C.G. and S.A. Simon. 1987. <b>Plant Associations of the Wallowa-Snake Province.</b> Report R6-Ecol-TP-225a-86. Portland, OR: U.S. Department of Agriculture, Forest Service, Pacific Northwest Region. 400&nbsp;p.';
  @manual_cite_full{'north_ut_s'}='Mauk, R.L. and J.A. Henderson. 1984. <b>Coniferous Forest Habitat Types of Northern Utah.</b> Gen. Tech. Rep. INT-GTR-170. Ogden, UT: U.S. Department of Agriculture, Forest Service, Intermountain Research Station. 89&nbsp;p.';
  @manual_cite_full{'montana_s'}='Pfister, R.D., B.L. Kovalchik, S.F. Arno and R.C. Presby. 1977. <b>Forest Habitat Types of Montana.</b> Gen. Tech. Rep. INT-GTR-34. Ogden, UT: U.S. Department of Agriculture, Forest Service, Intermountain Forest and Range Research Station. 174&nbsp;p.';
  @manual_cite_full{'central_id_s'}='Steele, R., R.D. Pfister, R.A. Ryker and J.A. Kittams. 1981. <b>Forest Habitat Types of Central Idaho.</b> Gen. Tech. Rep. INT-GTR-114. Ogden, UT: U.S. Department of Agriculture, Forest Service, Intermountain Forest and Range Research Station. 137&nbsp;p.';
  @manual_cite_full{'e_id_w_wy_s'}='Steele, R., S.V. Cooper, D.M. Ondov, D.W. Roberts and R.D. Pfister. 1983. <b>Forest Habitat Types of Eeastern Idaho and Western Wyoming.</b> Gen. Tech. Rep. INT-GTR-144. Ogden, UT: U.S. Department of Agriculture, Forest Service, Intermountain Research Station. 122&nbsp;p.';
  @manual_cite_full{'e_mt_hood_s'}='Topik, C., N.M. Halverson, and T. High. 1988. <b>Plant Associations and Management Guide for the Ponderosa Pine, Douglas-fir, and Grand Fir Zones, Mt Hood National Forest.</b> Report R6-Ecol-TP-004-88. Portland, OR: U.S. Department of Agriculture, Forest Service, Pacific Northwest Region. 136&nbsp;p.';
  @manual_cite_full{'wenatchee_s'}='Lillybridge, T. R., B.L Kovalchik, C.K. Williams and B.G. Smith. 1995. <b>Field Guide for Forested Plant Associations of the Wenatchee National Forest.</b> Portland, OR: U.S. Department of Agriculture, Forest Service, Pacific Northwest Research Station. 336&nbsp;p.';
  @manual_cite_full{'okanogan_s'}='Williams, C.K. and T.R. Lillybridge. 1983. <b>Forested Plant Associations of the Okanogan National Forest.</b> Report R6-Ecol-132b-1983. Portland, OR: U.S. Department of Agriculture, Forest Service, Pacific Northwest Region. 139&nbsp;p.';
  @manual_cite_full{'colville_s'}='Williams, C.K., T.R. Lillybridge and B.G. Smith. 1990. <b>Forested Plant Associations of the Colville National Forest.</b> Colville, WA: U.S. Department of Agriculture, Forest Service, Colville National Forest. 133&nbsp;p.';
  @manual_cite_full{'central_ut_s'}='Youngblood, A.P. and R.L. Mauk. 1985. <b>Coniferous Forest Habitat Types of Central and Southern Utah.</b> Gen. Tech. Rep. INT-GTR-187. Ogden, UT: U.S. Department of Agriculture, Forest Service, Intermountain Research Station. 89&nbsp;p.';
}

sub ReadParse {

# ReadParse -- from cgi-lib.pl (Steve Brenner) from Eric Herrmann's
# "Teach Yourself CGI Programming With PERL in a Week" p. 131

  local (*in) = @_ if @_;

  local ($i, $loc, $key, $val);

  if ($ENV{'REQUEST_METHOD'} eq "GET") {
    $in = $ENV{'QUERY_STRING'};
  } elsif ($ENV{'REQUEST_METHOD'} eq "POST") {
    read(STDIN,$in,$ENV{'CONTENT_LENGTH'});
  }
  @in = split(/&/,$in);
  foreach $i (0 .. $#in) {
    $in[$i] =~ s/\+/ /g;                        # Convert pluses to spaces
    ($key, $val) = split(/=/,$in[$i],2);        # Split into key and value
    $key =~ s/%(..)/pack("c",hex($1))/ge;       # Convert %XX from hex numbers to alphanumeric
    $val =~ s/%(..)/pack("c",hex($1))/ge;
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
    pophistory.document.writeln('   <p>')
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

#sub treatments {
#
##  INPUT:
##       $manual = 'North_ID';
#
#  my @text;
#  my $filename;
#
#  $filename = lc("xwalk/$manual" . '_treat.js');
#  if (-e $filename) {
#    open TREAT, "<$filename";
#    @text = <TREAT>;
#    print @text;
#    close TREAT;
#  }
#  else {
#    print "
#function treat_changed (which_changed) {
#  // $filename
# document.getElementById('treat_box').innerHTML = 'No information for this region at present'
#}
#";
#  }
#}

sub impacts {

#  INPUT:
#	$ht = 'CH/DH';
#	$manual = 'North_ID';
# OUTPUT:
#	printed Javascript function species_occur(which) {}

# read impact TSV file (eg.:)

##Conifer species in North ID Subseries arranged by (decreasing) expected percent cover and rated for potential Armillaria impact					
##HabType	Armillaria Regime
##	Subseries	Species	Role*	Average Expected Cover (%)	Potential Disease Impact
##General Note: Because of White Pine Blister Rust, PSME & ABGR have replaced the more Armillaria-tolerant 					
##PIMO as primary serals in subseries where PIMO appears.  Restoration to PIMO following removal of PSME &					
##ABGR will help to limit future damage by Armillaria in those subseries.					
#CH/DH	HSERAL
#	TSHE	C	60.4	High if disturbed
#	ABLA	S	44.8	High if disturbed
#	LAOC	s	13.3	Low
#	PICO	s	4.5	Low
#	PIEN	S	0.9	High but low occurrence
#CH/MH	HSERAL
#	THPL	S/C	29.3	High if disturbed
#	ABGR	S/c	24.3	High if disturbed
#	TSHE	C	18.9	High if disturbed
#	PSME	S	11.3	High if disturbed
#	LAOC	S	8.9	Low
#	PIEN	s/S	7.1	High
#	ABLA	s	6.1	High
#	PIMO	s/S	4.3	High in planted trees <20 yrs old
#	PICO	s/S	3.6	Low
#	PIPO	s	0.2	High but low occurrence
#	TSME	s	0.1	High but low occurrence
#CH/WF	HCLIMAX

# and create Javascript function

  my $regime;
  my $filename;
  my $font;
  my $first, $second, @fields;
  my $z;

  $filename = lc("xwalk/$manual" . '_ss_species.tsv');
#  print "$filename\n";
  $font = "<font face=\\'tahoma\\' size=\\'2\\'>";

  print "
function species_occur(which) {
  // $filename
  myhead  = '   <table border=1>\\n'
  myhead += '    <tr>\\n'
  myhead += '     <th valign=top>$font Species </font></th>\\n'
  myhead += '     <th valign=top>$font <a href=\"javascript:explain_role()\">Role</a> </font></th>\\n'
  myhead += '     <th valign=top>$font Average<br>Expected<br>Cover<br>(%)</font></th>\\n'
  myhead += '     <th valign=top>$font Potential disease impact</font></th>\\n'
  myhead += '    </tr>\\n'
  mytail  = '   </table>'
";

  open IMPACT, "<$filename";
  $entries=0;
  while (<IMPACT>) {
    chomp;
    if (substr($_,0,1) ne '#') {
      @fields = split '\t',$_;
      if (@fields[0] ne '') {
        $regime = @fields[1];
        print "    return myhead+mybody+mytail\n  }\n" if ($entries > 0); $entries +=1;
        print "  if (which == '@fields[0]') {\n";
        print "    my_arm_regime='High risk on climax species'\n" if ($regime eq 'HCLIMAX');
        print "    my_arm_regime='High risk on seral species'\n" if ($regime eq 'HSERAL');
        print "    my_arm_regime='Low risk'\n" if ($regime eq 'LOW');
        print "    mybody = ''\n";
      }
      else {
        print "    mybody += '     <tr><td>$font @fields[1]</font></td>\\n'\n";
        print "    mybody += '      <td>$font @fields[2]</font></td>\\n'\n";
        print "    mybody += '      <td align=right>$font @fields[3]</font></td>\\n'\n";
        print "    mybody += '      <td>$font @fields[4]</font></td></tr>\\n'\n";
        $line = substr($_,1);
#        print "    mybody += '$line\\n'\n";
      }
    }   #  substr($_,0,1) ne '#'
  }   #  while()
  close IMPACT;
  print "    return myhead+mybody+mytail\n  }\n";
  print "  return ''\n}";
}

sub firegroup {

#  INPUT:
#	$manual = 'North_ID';
# OUTPUT:
#	printed Javascript function fire_text(which) {}

# read firegroup file

# and create Javascript function

  my $filename;
# my $font;
  my $firstchar;
  my $rest;
  my $manual_lc = lc $manual;

  $filename='';
  $filename = 'central_id_fg.txt' if ($manual_lc eq 'central_id');
  $filename = 'csn_utah_fg.txt' if ($manual_lc eq 'central_ut');
  $filename = 'csn_utah_fg.txt' if ($manual_lc eq 'north_ut');
  $filename = 'e_id_w_wy_fg.txt' if ($manual_lc eq 'e_id_w_wy');
  $filename = 'montana_fg.txt' if ($manual_lc eq 'montana');
  $filename = 'north_id_fg.txt' if ($manual_lc eq 'north_id');
  $filename = 'nodata' if ($filename eq '');

  $filename = "xwalk/$filename";

#  print "$filename\n";
#  $font = "<font face='tahoma' size='2'>";

  print "
function fire_text(which) {
  // $manual
  // $filename
";

  if (-e $filename) {

    open FGFILE, "<$filename";
      print "
   if (which == '') {return ''}
   myfiregroup = parseInt(which)
   myf = ''
   mytail='<br>---<br>'
";
      while (<FGFILE>) {
        $firstchar=substr($_,0,1);
        if ($firstchar eq '$') {
          $rest = substr($_,1); chomp $rest;
          print "    mytail = mytail + '$rest'\n";
        }
        elsif ($firstchar ne '#') {
          if ($firstchar eq '!') {
            $firegroup = substr($_,3,2);
            $firegroup+=0;	# convert string to integer
            print "  }\n" if ($firegroup ne 1);
            print "  if (myfiregroup == $firegroup) {\n";
          }   # if ($firstchar eq '!')
          else {
            chomp;
            if ($_ eq '') {$_ = $_ . '<br>'}
            print "    myf = myf + '$_'\n";
          }
        }   # if ($firstchar ne '#')
      }   # while
      print "  }\n";

     close FGFILE;
     print "
  if (myfiregroup == 99) {
    myf = myf + 'This habitat type was not incuded in the published Fire Group Manual for $location.'
  }
  if (myfiregroup == '') {
    myf = myf + 'This habitat type was not incuded in the published Fire Group Manual for $location.'
  }
  return myf+mytail\n}
";
  }  # if (-e $filename)
  else { 
    print "    return 'No Fire Group Manual has been published for $location.'\n}\n";
  }
}
