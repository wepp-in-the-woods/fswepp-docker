function treat_changed (which_changed) {
// montana_treat.js

// Effects of fuels treatments in different Armillaria regimes in Montana
// (Effects will vary depending on the vigor of the host species):

// my_arm_regime:	armillaria regime ('low risk', 'High risk on seral species', 'High risk on climax species')
// which:		treatment (representing 'none', 'thin', 'rx', 'wild')

  treat=which_changed.value
//  myhead = ' armillaria regime '+my_arm_regime+', treatment '+treat+':<br>\\n'
  myhead = ''
  myb = ''
  mytail = ''
  regime = ''
  if (my_arm_regime == 'High risk on seral species') {regime = 'hseral'}
  if (my_arm_regime == 'High risk on climax species') {regime = 'hclimax'}
  if (my_arm_regime == 'low risk') {regime = 'low'}

// alert (my_arm_regime)
// alert (myhead)

  if (regime == 'low') {		// Armillaria Regime:  LOW
		// Subseries:  PP/DG, PP/DS, DF/DS, DF/DG, COOLP/DS, COOLP/DG, COLDF/DS, COLDF/DG
    myb = 'Within subseries where pathogenic <i>A. ostoyae</i> does not occur, fuels treatments will not affect Armillaria root disease, regardless of host tree species present.'
  }
  if (regime == 'hclimax') {		// Armillaria Regime:  HCLIMAX
		// Subseries:  DF/DH, COOLP/DH, COOLF/WF, COLDF/WF, COLDF/MH, COLDF/DH, CH/WS, CH/WF
    if (treat == 'none') {		// No treatment:
      myb  = 'The <b>no treatment</b> option avoids creating tree wounds that stress trees and generate root volatiles and nutrient substrates that foster Armillaria disease by either attracting fungal growth or enhancing root colonization. '
      myb += 'However, if disease mortality is already significant, the <b>no treatment</b> option will not reduce fuels, but will delay release of resistant species and may promote ladder fuels.'
    }
    if (treat == 'thin') {		// Thinning:
      myb  = 'Thinning treatments that favor climax or late-successional host trees will likely aggravate Armillaria root disease. '
      myb += 'Thinning treatments that create wounds on host trees will likely worsen Armillaria root rot on all species (Pankuch and others 2003). '
      myb += 'Thinning treatments that create a nutritional substrate (for example, stumps, dying roots, and woody debris) for <i>Armillaria</i> species may worsen Armillaria root rot. '
      myb += 'However, thinning that favors early seral species may reduce root disease over the long term. '
      myb += 'Also, greater spacing can improve tree vigor of seral species, which may increase tolerance to Armillaria root disease. '
      myb += 'Removal of the youngest trees that are most susceptible to <i>Armillaria</i> infection (Robinson and Morrison 2001) may help to reduce root disease.'
    }
    if (treat == 'rx') {			// Prescribed burning:
      myb  = 'Because <i>Armillaria</i> species can reside deep in the soil and within large woody roots, superficial slash burning or prescribed fire is unlikely to eliminate the pathogen, although these treatments may reduce infection potential indirectly by removing highly susceptible host species that are readily killed by fire (Hadfield and others 1986) and by favoring other fungi antagonistic to <i>Armillaria</i> (Filip and others 2001). '
      myb += 'Mortality caused by <i>Armillaria</i> increases fuel loads. '
      myb += 'Prescribed fire may be used to reduce fuel loads and inoculum levels above ground by eliminating colonized substrates for growth of <i>Armillaria</i>, but it may increase damage to surface roots and create wounds that might facilitate <i>Armillaria</i> infection.'
    }
    if (treat == 'wildfire') {		// Wildfire:
      myb  = 'Wildfire is a natural result of fuels build-up in late successional forests and this process should help restore forest health in <i>Armillaria</i> mortality centers by fostering the regeneration of seral tree species. '
      myb += 'However, wildfire usually leaves injured roots that are suitable for <i>Armillaria</i> colonization. '
      myb += 'Wildfire impacts on <i>Armillaria</i> disease are likely dependent on the fire type (for example, crown fire vs. ground fire) and intensity. '
      myb += 'Thus, it would be advisable to make a post-fire assessment of colonizable substrates generated during wildfire to determine appropriate restoration strategies.'
    }
  }
  if (regime == 'hseral') {		// Armillaria Regime:  HSERAL 
		// Subseries: CH/MH, CH/WH, COOLF/DH, COOLF/MH
    if (treat == 'none') {		// No treatment:
      myb  = 'The <b>no treatment</b> option avoids creating tree wounds that stress trees and generate root volatiles and nutrient substrates that foster Armillaria disease by either attracting fungal growth or enhancing root colonization. '
      myb += 'However, if disease mortality is already significant, the "no treatment" option will not reduce fuels, but will delay release of resistant species and may promote ladder fuels.'
    }
    if (treat == 'thin') {		// Thinning:
      myb  = 'Thinning treatments that favor secondary seral host trees will likely aggravate Armillaria root disease. '
      myb += 'Thinning treatments that create wounds on host trees will likely worsen Armillaria root rot on all species (Pankuch and others 2003). '
      myb += 'Thinning treatments that create a nutritional substrate (for example, stumps, dying roots, and woody debris) for <i>Armillaria</i> species may worsen Armillaria root rot. '
      myb += 'However, thinning that favors early seral or climax species may reduce the impact of root disease over the long term. '
      myb += 'Also, greater spacing can improve tree vigor, which may increase tolerance to Armillaria root disease. '
      myb += 'Removal of the youngest trees that are most susceptible to <i>Armillaria</i> infection (Robinson and Morrison 2001) may help to reduce root disease.'
    }
    if (treat == 'rx') {		// Prescribed burning:
      myb  = 'Because <i>Armillaria</i> species can reside deep in the soil and within large woody roots, superficial slash burning or prescribed fire is unlikely to eliminate the pathogen, although these treatments may reduce infection potential indirectly by removing highly susceptible host species that are readily killed by fire (Hadfield and others 1986) and by favoring other fungi antagonistic to <i>Armillaria</i> (Filip and others 2001). '
      myb += 'Mortality caused by <i>Armillaria</i> increases fuel loads. '
      myb += 'Prescribed fire may be used to reduce fuel loads and inoculum levels above ground by eliminating colonized substrates for growth of <i>Armillaria</i>, but it may increase damage to surface roots and create wounds that might facilitate <i>Armillaria</i> infection.'
    }
    if (treat == 'wildfire') {		// Wildfire:
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
