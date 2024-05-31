	

	clear
	cd "C:\Users\Alina Pavelea.DELL3090-A007\OneDrive\Documents\EU-SILC Data preparation\EU-SILC"
	global datapath "C:\Users\Alina Pavelea.DELL3090-A007\OneDrive\Documents\EU-SILC Data preparation\EU-SILC"
	
* Note: In order to merge the dataset with the contextual data provided, replace the cd in lines: 4283; 4302; 4306; 4310; 4315; 4426; 4463; 4587; 4621
	
	
	
********************************************************************
****Coder: Alina Maria Pavelea**************************************
****Project: rEUsilience********************************************
********Data preparatio: Matysiak et al., 2024, PLOS One************
********************************************************************
********************************************************************************
/*THE CSV FILES WERE SAVED AS .DTA AND THE VARIABLES LABLED USING THE DO-FILES 
PROVIDED BY GESIS, AVAILABLE HERE: https://www.gesis.org/en/missy/materials/EU-SILC/setups*/
********************************************************************************************

/******************************************************************************
CUMULATING THE EU-SILC LONGITUDINAL FILES**************************************
THE CODE BELOW IS ADAPTED BASED ON Marwin Borst & Heike Wirth (GESIS), 
https://www.gesis.org/en/missy/materials/EU-SILC/tools/datahandling************
******************************************************************************/
	
	
	
	/* D-FILES */
	/* 2020 */
	/*open the 2020 Household register to get list of rotation groups with maxobs and starting point for masterfile*/
	
	use DB010 DB020 DB030 DB040 DB075 DB100 DB110 using "$datapath\2020\D_file_2020", clear
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	
	/*Block Stata from displaying IDs in exponential format*/
	tostring db030, replace
	gen year=db010
	gen country=db020
	gen hid=db030
	gen rotation_group=db075
	replace country = "EL" if country == "GR"
	sort country hid year
	/* count the number of rotational groups for each country in this release*/
	bysort country rotation_group: gen nvals = _n == 1
	bysort country : egen nrtgrp2020 = total(nvals)
	drop nvals 
	/* mark selected rotation group (this is the most recent release, so all rotationgroups are selected)*/
	gen slctd_rtgrp = rotation_group
	/* build household and rotationgroup IDs that are unique across releases */
	tostring rotation_group, generate(rotation_groupstr)
	egen maxyear = max(year) 
	bysort country rotation_group : egen minyear = min(year)
	gen years_cov = maxyear - minyear + 1
	gen drpout_year = maxyear
	replace drpout_year = drpout_year + 4 - years_cov
		/*check for rotation groups that ended earlier than the latest year*/
		bysort country rotation_group : egen maxyear_grp = max(year)
		replace drpout_year = maxyear_grp if maxyear_grp < maxyear
	tostring drpout_year, replace
	gen uhid = country + rotation_groupstr + drpout_year + hid
	gen urtgrp = country + rotation_groupstr + drpout_year
	drop rotation_groupstr maxyear_grp minyear years_cov maxyear_grp maxyear
	destring drpout_year, replace 
	/*for later checks*/
	gen drpout_year2020 = drpout_year
	gen slctd_urtgrp2020 = urtgrp 	
	gen slctd_uhid2020 = uhid
	/*this is the masterfile to build the dataset on */
	gen merge2020 = 1
	save "$datapath\masterD.dta", replace
	/*this is the the 2020D file for later control.*/
	drop merge2020
	save "$datapath\2020D.dta", replace

/* 2019 */
	
	/*Open the 2019 Household register to get data from rotational groups inactive in 2020 and their uhid*/
	clear
	use DB010 DB020 DB030 DB040 DB075 DB100 DB110 using "$datapath\2019\D_file_2019", clear
	
	local new_var=lower("`var'")

	 foreach var of varlist _all {
	local new_var = lower("`var'")
	cap rename `var' `new_var'
	}
	
	/*Block Stata from displaying IDs in exponential format*/
	tostring db030, replace
	gen year=db010
	gen country=db020
	gen hid=db030
	gen rotation_group=db075
	sort country hid year
	replace country = "EL" if country == "GR"
	/* count the number of rotational groups for each country in this release*/
	bysort country rotation_group: gen nvals = _n == 1
	bysort country : egen nrtgrp2019 = total(nvals)
	drop nvals 
	/* get the rotation group(s) that cover most years*/
	bysort country rotation_group : egen maxyear = max(year) 
	bysort country rotation_group : egen minyear = min(year)
	gen years_cov = maxyear - minyear + 1
	bysort country : egen maxgrp = max(years_cov) 
	gen slctd_rtgrp=0
	bysort country rotation_group: replace slctd_rtgrp = rotation_group if years_cov == maxgrp
	gen lgstgrp = 0
	bysort country rotation_group: replace lgstgrp = 1 if years_cov == maxgrp
	/* build household and rotationgroup IDs that are unique across releases */
	tostring rotation_group, generate(rotation_groupstr)
	gen drpout_year = 0
	replace drpout_year = maxyear + 4 - years_cov
		/*check for rotation groups that dropped out before planned */
		bysort country rotation_group : egen maxyear_grp = max(year)
		replace drpout_year = maxyear_grp if maxyear_grp < maxyear
	tostring drpout_year, replace
	gen uhid = country + rotation_groupstr + drpout_year + hid
	gen urtgrp = country + rotation_groupstr + drpout_year
	destring drpout_year, replace 	
		/*check if any selected groups have been selected in the more recent release ("prolonged rotation groups")*/
		sort year country rotation_group hid 
		merge m:m year country rotation_group using "$datapath\2020D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		/*update urtgrp and uhid*/
		drop maxyear rotation_groupstr
		bysort country rotation_group: egen maxyear = max(drpout_year)
		replace drpout_year = maxyear 
		tostring drpout_year, replace 
		tostring rotation_group, generate(rotation_groupstr)
		replace uhid = country + rotation_groupstr + drpout_year + hid
		replace urtgrp = country + rotation_groupstr + drpout_year
		keep if _merge == 1
		drop rotation_groupstr
	drop _merge maxyear_grp minyear years_cov maxyear_grp maxyear
	destring drpout_year, replace 
	drop if slctd_rtgrp == 0
	/*for later checks*/
	gen drpout_year2019 = drpout_year
	gen slctd_urtgrp2019 = urtgrp 	
	gen slctd_uhid2019 = uhid
	/*merge to masterfile*/
	merge 1:1 year uhid using "$datapath\masterD.dta"
		/*check for duplicates caused by same rotational groups in terms of same hid, different rotation_group*/
		/*duplicates report year country hid*/
		duplicates tag year country hid, generate(test2)
		/*tab country year if test2 != 0 	
		tab urtgrp year  if test2 != 0*/
			/*check if the problem regards a large portion of the rotational group, if the portion is small ignore*/
			gen tag1 = 0 
			replace tag1 = 1 if test2 != 0 
			bysort year country urtgrp : egen ndups = total(tag1)
			gen tag2 = 1 
			bysort year country urtgrp : egen tot = total(tag2)
			gen rdups = ndups / tot
			gen tag3 = 0 
			replace tag3 = 1 if rdups > 0.5
			drop tag1 tag2 ndups tot rdups
			/* extend selection to whole rotational group*/
			bysort year country urtgrp : egen taga = max(tag3)
			drop tag3
			/*check if the rotational group with duplicates is the one covering most years in current release. If yes ignore*/
			tab urtgrp year if taga == 1  & lgstgrp == 0 & _merge == 1
			drop if taga == 1 & lgstgrp == 0 & _merge == 1
			drop  test2 taga
			/*check for unbalances*/
			bysort country : egen test3 = total(nrtgrp2020)
			replace test3 = 0 if test3 == .
			tab urtgrp year if ( test3 != 0 & lgstgrp == 0 & _merge == 1 )  	
			drop if ( test3 != 0 & lgstgrp == 0 & _merge == 1 )
			drop test3
		/*this is the updated masterfile */
		gen merge2019 = _merge
		drop _merge
		save "$datapath\masterD.dta", replace
		/*this is 2019D file for later control*/
		keep if merge2019 == 1 
		drop merge2019
		save "$datapath\2019D.dta", replace


/* 2018 */

	/*open the 2018 Household register to get data from rotational groups inactive in 2019 and their uhid*/
	clear

	use DB010 DB020 DB030 DB040 DB075 DB100 DB110 using "$datapath\2018\D_file_2018", clear
	
	local new_var=lower("`var'")

	 foreach var of varlist _all {
	local new_var = lower("`var'")
	cap rename `var' `new_var'
	}
		
	/*Block Stata from displaying IDs in exponential format*/
	tostring db030, replace
	gen year=db010
	gen country=db020
	gen hid=db030
	gen rotation_group=db075 
	sort country hid year
	replace country = "EL" if country == "GR"
	/* count the number of rotational groups for each country in this release*/
	bysort country rotation_group: gen nvals = _n == 1
	bysort country : egen nrtgrp2018 = total(nvals)
	drop nvals 
	/* get the rotation group(s) that cover most years*/
	bysort country rotation_group : egen maxyear = max(year) 
	bysort country rotation_group : egen minyear = min(year)
	gen years_cov = maxyear - minyear + 1
	bysort country : egen maxgrp = max(years_cov) 
	gen slctd_rtgrp=0
	bysort country rotation_group: replace slctd_rtgrp = rotation_group if years_cov == maxgrp 
	gen lgstgrp = 0
	bysort country rotation_group: replace lgstgrp = 1 if years_cov == maxgrp
	/* build household and rotationgroup IDs that are unique across releases */
	tostring rotation_group, generate(rotation_groupstr)
	gen drpout_year = 0
	replace drpout_year = maxyear + 4 - years_cov
		/*check for rotation groups that dropped out before planned */
		bysort country rotation_group : egen maxyear_grp = max(year)
		replace drpout_year = maxyear_grp if maxyear_grp < maxyear
	tostring drpout_year, replace
	gen uhid = country + rotation_groupstr + drpout_year + hid
	gen urtgrp = country + rotation_groupstr + drpout_year
	destring drpout_year, replace 	
		/*check if any selected groups have been selected in the more recent 2019 release ("prolonged rotation groups")*/
		sort year country rotation_group hid 
		merge m:m year country rotation_group using "$datapath\2019D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		/*tag rotation groups that have already been selected in the more recent release in some years (overlapping)*/
		gen atag = 0
		replace atag = 1 if _merge == 3
		bysort country rotation_group : egen btag = max(atag) 
		bysort country rotation_group : egen ndrpoy = max(drpout_year2019)
		replace drpout_year = ndrpoy if btag == 1
		drop atag btag ndrpoy
		/*update urtgrp and uhid so that "prolonged rotation groups" maintain their urtgrp across different releases*/
		tostring drpout_year, replace
		replace uhid = country + rotation_groupstr + drpout_year + hid
		replace urtgrp = country + rotation_groupstr + drpout_year
		destring drpout_year, replace	
		drop rotation_groupstr maxyear_grp minyear years_cov maxgrp maxyear_grp maxyear
		/*drop overlapping rotation group years and data from the more recent release*/
		keep if _merge==1 
		drop _merge 
		/*check if any selected groups have been selected in the more recent 2020 release ("prolonged rotation groups")*/
		merge m:m year country urtgrp using "$datapath\2020D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		keep if _merge==1 
		drop _merge 
	destring drpout_year, replace 
	drop if slctd_rtgrp == 0
	/*for later checks*/
	gen drpout_year2018 = drpout_year
	gen slctd_urtgrp2018 = urtgrp 	
	gen slctd_uhid2018 = uhid
	/*merge to masterfile*/
	merge 1:1 year uhid using "$datapath\masterD.dta"
		/*check for duplicates caused by same rotational groups in terms of same hid, different rotation_group*/
		/*duplicates report year country hid*/
		duplicates tag year country hid, generate(test2)
		/*tab country year if test2 != 0 	
		tab urtgrp year  if test2 != 0*/
			/*check if the problem regards a large portion of the rotational group, if the portion is small ignore*/
			gen tag1 = 0 
			replace tag1 = 1 if test2 != 0 
			bysort year country urtgrp : egen ndups = total(tag1)
			gen tag2 = 1 
			bysort year country urtgrp : egen tot = total(tag2)
			gen rdups = ndups / tot
			gen tag3 = 0 
			replace tag3 = 1 if rdups > 0.5
			drop tag1 tag2 ndups tot rdups
			/* extend selection to whole rotational group*/
			bysort year country urtgrp : egen taga = max(tag3)
			drop tag3
			/*check if the rotational group with duplicates is the one covering most years in current release. If yes ignore*/
			tab urtgrp year if taga == 1  & lgstgrp == 0 & _merge == 1
			drop if taga == 1 & lgstgrp == 0 & _merge == 1
			drop  test2 taga
			/*check for unbalances*/
			bysort country : egen test3 = total(nrtgrp2019)
			bysort country : egen test4 = total(nrtgrp2020)
			replace test3 = 0 if test3 == .
			replace test4 = 0 if test4 == .
			tab urtgrp year if ( test3 != 0 & lgstgrp == 0 & _merge == 1 ) & ( test4 != 0 & lgstgrp == 0 & _merge == 1 ) 	
			drop if ( test3 != 0 & lgstgrp == 0 & _merge == 1 ) & ( test4 != 0 & lgstgrp == 0 & _merge == 1 )
			drop test3 test4
		/*this is the updated masterfile */
		gen merge2018 = _merge
		drop _merge
		save "$datapath\masterD.dta", replace
		/*this is 2018D file for later control*/
		keep if merge2018 == 1 
		drop merge2018
		save "$datapath\2018D.dta", replace
	


/* 2017 */

	/*open the 2017 Household register to get data from rotational groups inactive in more recent releases and their uhid*/
	clear
	use DB010 DB020 DB030 DB040 DB075 DB100 DB110 using "$datapath\2017\D_file_2017", clear
	
	local new_var=lower("`var'")

	foreach var of varlist _all {
		local new_var = lower("`var'")
		cap rename `var' `new_var'
	}
	
	/*Block Stata from displaying IDs in exponential format*/
	tostring db030, replace
	gen year=db010
	gen country=db020
	gen hid=db030
	gen rotation_group=db075
	sort country hid year
	replace country = "EL" if country == "GR"
	/* count the number of rotational groups for each country in this release*/
	bysort country rotation_group: gen nvals = _n == 1
	bysort country : egen nrtgrp2017 = total(nvals)
	drop nvals 
	/* get the rotation group(s) that cover most years*/
	bysort country rotation_group : egen maxyear = max(year) 
	bysort country rotation_group : egen minyear = min(year)
	gen years_cov = maxyear - minyear + 1
	bysort country : egen maxgrp = max(years_cov) 
	gen slctd_rtgrp=0
	bysort country rotation_group: replace slctd_rtgrp = rotation_group if years_cov == maxgrp 
	gen lgstgrp = 0
	bysort country rotation_group: replace lgstgrp = 1 if years_cov == maxgrp
	/* build household and rotationgroup IDs that are unique across releases */
	tostring rotation_group, generate(rotation_groupstr)
	gen drpout_year = 0
	replace drpout_year = maxyear + 4 - years_cov
		/*check for rotation groups that dropped out before planned */
		bysort country rotation_group : egen maxyear_grp = max(year)
		replace drpout_year = maxyear_grp if maxyear_grp < maxyear
	tostring drpout_year, replace
	gen uhid = country + rotation_groupstr + drpout_year + hid
	gen urtgrp = country + rotation_groupstr + drpout_year
	destring drpout_year, replace 	
		/*check if any selected groups have been selected in the more recent 2018 release ("prolonged rotation groups")*/
		sort year country rotation_group hid 
		merge m:m year country rotation_group using "$datapath\2018D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		/*tag rotation groups that have already been selected in the more recent release in some years (overlapping)*/
		gen atag = 0
		replace atag = 1 if _merge == 3
		bysort country rotation_group : egen btag = max(atag) 
		bysort country rotation_group : egen ndrpoy = max(drpout_year2018)
		replace drpout_year = ndrpoy if btag == 1
		drop atag btag ndrpoy
		/*update urtgrp and uhid so that "prolonged rotation groups" maintain their urtgrp across different releases*/
		tostring drpout_year, replace
		replace uhid = country + rotation_groupstr + drpout_year + hid
		replace urtgrp = country + rotation_groupstr + drpout_year
		destring drpout_year, replace	
		drop rotation_groupstr maxyear_grp minyear years_cov maxgrp maxyear_grp maxyear
		/*drop overlapping rotation group years and data from the more recent release*/
		keep if _merge==1
		drop _merge 
		/*check if any selected groups have been selected in the more recent 2019 release ("prolonged rotation groups")*/
		merge m:m year country urtgrp using "$datapath\2019D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		keep if _merge==1 
		drop _merge
		/*check if any selected groups have been selected in the more recent 2020 release ("prolonged rotation groups")*/
		merge m:m year country urtgrp using "$datapath\2020D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		keep if _merge==1 
		drop _merge
	destring drpout_year, replace 
	drop if slctd_rtgrp == 0
	/*for later checks*/
	gen drpout_year2017 = drpout_year
	gen slctd_urtgrp2017 = urtgrp 	
	gen slctd_uhid2017 = uhid
	/*merge to masterfile*/
	merge 1:1 year uhid using "$datapath\masterD.dta"
		/*check for duplicates caused by same rotational groups in terms of same hid, different rotation_group*/
		/*duplicates report year country hid*/
		duplicates tag year country hid, generate(test2)
		/*tab country year if test2 != 0 	
		tab urtgrp year  if test2 != 0 */
			/*check if the problem regards a large portion of the rotational group, if the portion is small ignore*/
			gen tag1 = 0 
			replace tag1 = 1 if test2 != 0 
			bysort year country urtgrp : egen ndups = total(tag1)
			gen tag2 = 1 
			bysort year country urtgrp : egen tot = total(tag2)
			gen rdups = ndups / tot
			gen tag3 = 0 
			replace tag3 = 1 if rdups > 0.5
			drop tag1 tag2 ndups tot rdups
			/* extend selection to whole rotational group*/
			bysort year country urtgrp : egen taga = max(tag3)
			drop tag3
			/*check if the rotational group with duplicates is the one covering most years in current release. If yes ignore*/
			tab urtgrp year if taga == 1  & lgstgrp == 0 & _merge == 1
			drop if taga == 1 & lgstgrp == 0 & _merge == 1
			drop  test2 taga
			/*check for unbalances*/
			bysort country : egen test3 = total(nrtgrp2018)
			bysort country : egen test4 = total(nrtgrp2019)
			bysort country : egen test5 = total(nrtgrp2020)
			replace test3 = 0 if test3 == .
			replace test4 = 0 if test4 == .
			replace test5 = 0 if test5 == .
			tab urtgrp year if ( test3 != 0 & lgstgrp == 0 & _merge == 1 ) & ( test4 != 0 & lgstgrp == 0 & _merge == 1 ) &( test5 != 0 & lgstgrp == 0 & _merge == 1 )	
			drop if ( test3 != 0 & lgstgrp == 0 & _merge == 1 ) & ( test4 != 0 & lgstgrp == 0 & _merge == 1 ) & ( test5 != 0 & lgstgrp == 0 & _merge == 1 )
			drop test3 test4 test5
		/*this is the updated masterfile */
		gen merge2017 = _merge
		drop _merge
		save "$datapath\masterD.dta", replace
		/*this is 2017D file for later control*/
		keep if merge2017 == 1 
		drop merge2017
		save "$datapath\2017D.dta", replace

		
	/* 2016 */


	/*open the 2016 Household register to get data from rotational groups inactive in more recent releases and their uhid*/
	clear
	use DB010 DB020 DB030 DB040 DB075 DB100 DB110 using "$datapath\2016\D_file_2016", clear
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	
	/*Block Stata from displaying IDs in exponential format*/
	tostring db030, replace
	gen year=db010
	gen country=db020
	gen hid=db030
	gen rotation_group=db075
	sort country hid year
	replace country = "EL" if country == "GR"
	/* count the number of rotational groups for each country in this release*/
	bysort country rotation_group: gen nvals = _n == 1
	bysort country : egen nrtgrp2016 = total(nvals)
	drop nvals 
	/* get the rotation group(s) that cover most years*/
	bysort country rotation_group : egen maxyear = max(year) 
	bysort country rotation_group : egen minyear = min(year)
	gen years_cov = maxyear - minyear + 1
	bysort country : egen maxgrp = max(years_cov) 
	gen slctd_rtgrp=0
	bysort country rotation_group: replace slctd_rtgrp = rotation_group if years_cov == maxgrp 
	gen lgstgrp = 0
	bysort country rotation_group: replace lgstgrp = 1 if years_cov == maxgrp
	/* build household and rotationgroup IDs that are unique across releases */
	tostring rotation_group, generate(rotation_groupstr)
	gen drpout_year = 0
	replace drpout_year = maxyear + 4 - years_cov
		/*check for rotation groups that dropped out before planned */
		bysort country rotation_group : egen maxyear_grp = max(year)
		replace drpout_year = maxyear_grp if maxyear_grp < maxyear
	tostring drpout_year, replace
	gen uhid = country + rotation_groupstr + drpout_year + hid
	gen urtgrp = country + rotation_groupstr + drpout_year
	destring drpout_year, replace 	
		/*check if any selected groups have been selected in the more recent 2017 release ("prolonged rotation groups")*/
		sort year country rotation_group hid 
		merge m:m year country rotation_group using "$datapath\2017D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		/*tag rotation groups that have already been selected in the more recent release in some years (overlapping)*/
		gen atag = 0
		replace atag = 1 if _merge == 3
		bysort country rotation_group : egen btag = max(atag) 
		bysort country rotation_group : egen ndrpoy = max(drpout_year2017)
		replace drpout_year = ndrpoy if btag == 1
		drop atag btag ndrpoy
		/*update urtgrp and uhid so that "prolonged rotation groups" maintain their urtgrp across different releases*/
		tostring drpout_year, replace
		replace uhid = country + rotation_groupstr + drpout_year + hid
		replace urtgrp = country + rotation_groupstr + drpout_year
		destring drpout_year, replace	
		drop rotation_groupstr maxyear_grp minyear years_cov maxgrp maxyear_grp maxyear
		/*drop overlapping rotation group years and data from the more recent release*/
		keep if _merge==1
		drop _merge 
		/*check if any selected groups have been selected in the more recent 2018 release ("prolonged rotation groups")*/
		merge m:m year country urtgrp using "$datapath\2018D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		keep if _merge==1 
		drop _merge
		/*check if any selected groups have been selected in the more recent 2019 release ("prolonged rotation groups")*/
		merge m:m year country urtgrp using "$datapath\2019D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		keep if _merge==1 
		drop _merge
	destring drpout_year, replace 
	drop if slctd_rtgrp == 0
	/*for later checks*/
	gen drpout_year2016 = drpout_year
	gen slctd_urtgrp2016 = urtgrp 	
	gen slctd_uhid2016 = uhid
	/*merge to masterfile*/
	merge 1:1 year uhid using "$datapath\masterD.dta"
		/*check for duplicates caused by same rotational groups in terms of same hid, different rotation_group*/
		/*duplicates report year country hid*/
		duplicates tag year country hid, generate(test2)
		/*tab country year if test2 != 0 	
		tab urtgrp year  if test2 != 0*/ 
			/*check if the problem regards a large portion of the rotational group, if the portion is small ignore*/
			gen tag1 = 0 
			replace tag1 = 1 if test2 != 0 
			bysort year country urtgrp : egen ndups = total(tag1)
			gen tag2 = 1 
			bysort year country urtgrp : egen tot = total(tag2)
			gen rdups = ndups / tot
			gen tag3 = 0 
			replace tag3 = 1 if rdups > 0.5
			drop tag1 tag2 ndups tot rdups
			/* extend selection to whole rotational group*/
			bysort year country urtgrp : egen taga = max(tag3)
			drop tag3
			/*check if the rotational group with duplicates is the one covering most years in current release. If yes ignore*/
			tab urtgrp year if taga == 1  & lgstgrp == 0 & _merge == 1
			drop if taga == 1 & lgstgrp == 0 & _merge == 1
			drop  test2 taga
			/*check for unbalances*/
			bysort country : egen test3 = total(nrtgrp2017)
			bysort country : egen test4 = total(nrtgrp2018)
			bysort country : egen test5 = total(nrtgrp2019)
			replace test3 = 0 if test3 == .
			replace test4 = 0 if test4 == .
			replace test5 = 0 if test5 == .
			tab urtgrp year if ( test3 != 0 & lgstgrp == 0 & _merge == 1 ) & ( test4 != 0 & lgstgrp == 0 & _merge == 1 ) &( test5 != 0 & lgstgrp == 0 & _merge == 1 )
			drop if ( test3 != 0 & lgstgrp == 0 & _merge == 1 ) & ( test4 != 0 & lgstgrp == 0 & _merge == 1 ) &( test5 != 0 & lgstgrp == 0 & _merge == 1 )
			drop test3 test4 test5
		/*this is the updated masterfile */
		gen merge2016 = _merge
		drop _merge
		save "$datapath\masterD.dta", replace
		/*this is 2016D file for later control*/
		keep if merge2016 == 1 
		drop merge2016
		save "$datapath\2016D.dta", replace


	
	/* 2015 */
	
	/*open the 2015 Household register to get data from rotational groups inactive in more recent releases and their uhid*/
	clear
	use DB010 DB020 DB030 DB040 DB075 DB100 DB110 using "$datapath\2015\D_file_2015", clear
	
	local new_var=lower("`var'")

	foreach var of varlist _all {
		local new_var = lower("`var'")
		cap rename `var' `new_var'
	}
	
	/*Block Stata from displaying IDs in exponential format*/
	tostring db030, replace
	gen year=db010
	gen country=db020
	gen hid=db030
	gen rotation_group=db075
	sort country hid year
	replace country = "EL" if country == "GR"
	/* count the number of rotational groups for each country in this release*/
	bysort country rotation_group: gen nvals = _n == 1
	bysort country : egen nrtgrp2015 = total(nvals)
	drop nvals 
	/* get the rotation group(s) that cover most years*/
	bysort country rotation_group : egen maxyear = max(year) 
	bysort country rotation_group : egen minyear = min(year)
	gen years_cov = maxyear - minyear + 1
	bysort country : egen maxgrp = max(years_cov) 
	gen slctd_rtgrp=0
	bysort country rotation_group: replace slctd_rtgrp = rotation_group if years_cov == maxgrp 
	gen lgstgrp = 0
	bysort country rotation_group: replace lgstgrp = 1 if years_cov == maxgrp
	/* build household and rotationgroup IDs that are unique across releases */
	tostring rotation_group, generate(rotation_groupstr)
	gen drpout_year = 0
	replace drpout_year = maxyear + 4 - years_cov
		/*check for rotation groups that dropped out before planned */
		bysort country rotation_group : egen maxyear_grp = max(year)
		replace drpout_year = maxyear_grp if maxyear_grp < maxyear
	tostring drpout_year, replace
	gen uhid = country + rotation_groupstr + drpout_year + hid
	gen urtgrp = country + rotation_groupstr + drpout_year
	destring drpout_year, replace 	
		/*check if any selected groups have been selected in the more recent 2016 release ("prolonged rotation groups")*/
		sort year country rotation_group hid 
		merge m:m year country rotation_group using "$datapath\2016D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		/*tag rotation groups that have already been selected in the more recent release in some years (overlapping)*/
		gen atag = 0
		replace atag = 1 if _merge == 3
		bysort country rotation_group : egen btag = max(atag) 
		bysort country rotation_group : egen ndrpoy = max(drpout_year2016)
		replace drpout_year = ndrpoy if btag == 1
		drop atag btag ndrpoy
		/*update urtgrp and uhid so that "prolonged rotation groups" maintain their urtgrp across different releases*/
		tostring drpout_year, replace
		replace uhid = country + rotation_groupstr + drpout_year + hid
		replace urtgrp = country + rotation_groupstr + drpout_year
		destring drpout_year, replace	
		drop rotation_groupstr maxyear_grp minyear years_cov maxgrp maxyear_grp maxyear
		/*drop overlapping rotation group years and data from the more recent release*/
		keep if _merge==1
		drop _merge 
		/*check if any selected groups have been selected in the more recent 2017 release ("prolonged rotation groups")*/
		merge m:m year country urtgrp using "$datapath\2017D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		keep if _merge==1 
		drop _merge
		/*check if any selected groups have been selected in the more recent 2018 release ("prolonged rotation groups")*/
		merge m:m year country urtgrp using "$datapath\2018D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		keep if _merge==1 
		drop _merge
	destring drpout_year, replace 
	drop if slctd_rtgrp == 0
	/*for later checks*/
	gen drpout_year2015 = drpout_year
	gen slctd_urtgrp2015 = urtgrp 	
	gen slctd_uhid2015 = uhid
	/*merge to masterfile*/
	merge 1:1 year uhid using "$datapath\masterD.dta"
		/*check for duplicates caused by same rotational groups in terms of same hid, different rotation_group*/
		/*duplicates report year country hid*/
		duplicates tag year country hid, generate(test2)
		/*tab country year if test2 != 0 	
		tab urtgrp year  if test2 != 0 */
			/*check if the problem regards a large portion of the rotational group, if the portion is small ignore*/
			gen tag1 = 0 
			replace tag1 = 1 if test2 != 0 
			bysort year country urtgrp : egen ndups = total(tag1)
			gen tag2 = 1 
			bysort year country urtgrp : egen tot = total(tag2)
			gen rdups = ndups / tot
			gen tag3 = 0 
			replace tag3 = 1 if rdups > 0.5
			drop tag1 tag2 ndups tot rdups
			/* extend selection to whole rotational group*/
			bysort year country urtgrp : egen taga = max(tag3)
			drop tag3
			/*check if the rotational group with duplicates is the one covering most years in current release. If yes ignore*/
			tab urtgrp year if taga == 1  & lgstgrp == 0 & _merge == 1
			drop if taga == 1 & lgstgrp == 0 & _merge == 1
			drop  test2 taga
			/*check for unbalances*/
			bysort country : egen test3 = total(nrtgrp2016)
			bysort country : egen test4 = total(nrtgrp2017)
			bysort country : egen test5 = total(nrtgrp2018)
			replace test3 = 0 if test3 == .
			replace test4 = 0 if test4 == .
			replace test5 = 0 if test5 == .
			tab urtgrp year if ( test3 != 0 & lgstgrp == 0 & _merge == 1 ) & ( test4 != 0 & lgstgrp == 0 & _merge == 1 ) &( test5 != 0 & lgstgrp == 0 & _merge == 1 )
			drop if ( test3 != 0 & lgstgrp == 0 & _merge == 1 ) & ( test4 != 0 & lgstgrp == 0 & _merge == 1 ) &( test5 != 0 & lgstgrp == 0 & _merge == 1 )
			drop test3 test4 test5
		/*this is the updated masterfile */
		gen merge2015 = _merge
		drop _merge
		save "$datapath\masterD.dta", replace
		/*this is 2015D file for later control*/
		keep if merge2015 == 1 
		drop merge2015
		save "$datapath\2015D.dta", replace

/* 2014 */
	
	/*open the 2014 Household register to get data from rotational groups inactive in more recent releases and their uhid*/
	clear
	use DB010 DB020 DB030 DB040 DB075 DB100 DB110 using "$datapath\2014\D_file_2014", clear
	
	local new_var=lower("`var'")

	foreach var of varlist _all {
		local new_var = lower("`var'")
		cap rename `var' `new_var'
	}
	
	/*Block Stata from displaying IDs in exponential format*/
	tostring db030, replace
	gen year=db010
	gen country=db020
	gen hid=db030
	gen rotation_group=db075
	sort country hid year
	replace country = "EL" if country == "GR"
	/* count the number of rotational groups for each country in this release*/
	bysort country rotation_group: gen nvals = _n == 1
	bysort country : egen nrtgrp2014 = total(nvals)
	drop nvals 
	/* get the rotation group(s) that cover most years*/
	bysort country rotation_group : egen maxyear = max(year) 
	bysort country rotation_group : egen minyear = min(year)
	gen years_cov = maxyear - minyear + 1
	bysort country : egen maxgrp = max(years_cov) 
	gen slctd_rtgrp=0
	bysort country rotation_group: replace slctd_rtgrp = rotation_group if years_cov == maxgrp 
	gen lgstgrp = 0
	bysort country rotation_group: replace lgstgrp = 1 if years_cov == maxgrp
	/* build household and rotationgroup IDs that are unique across releases */
	tostring rotation_group, generate(rotation_groupstr)
	gen drpout_year = 0
	replace drpout_year = maxyear + 4 - years_cov
		/*check for rotation groups that dropped out before planned */
		bysort country rotation_group : egen maxyear_grp = max(year)
		replace drpout_year = maxyear_grp if maxyear_grp < maxyear
	tostring drpout_year, replace
	gen uhid = country + rotation_groupstr + drpout_year + hid
	gen urtgrp = country + rotation_groupstr + drpout_year
	destring drpout_year, replace 	
		/*check if any selected groups have been selected in the more recent 2016 release ("prolonged rotation groups")*/
		sort year country rotation_group hid 
		merge m:m year country rotation_group using "$datapath\2016D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		/*tag rotation groups that have already been selected in the more recent release in some years (overlapping)*/
		gen atag = 0
		replace atag = 1 if _merge == 3
		bysort country rotation_group : egen btag = max(atag) 
		bysort country rotation_group : egen ndrpoy = max(drpout_year2016)
		replace drpout_year = ndrpoy if btag == 1
		drop atag btag ndrpoy
		/*update urtgrp and uhid so that "prolonged rotation groups" maintain their urtgrp across different releases*/
		tostring drpout_year, replace
		replace uhid = country + rotation_groupstr + drpout_year + hid
		replace urtgrp = country + rotation_groupstr + drpout_year
		destring drpout_year, replace	
		drop rotation_groupstr maxyear_grp minyear years_cov maxgrp maxyear_grp maxyear
		/*drop overlapping rotation group years and data from the more recent release*/
		keep if _merge==1
		drop _merge 
		/*check if any selected groups have been selected in the more recent 2017 release ("prolonged rotation groups")*/
		merge m:m year country urtgrp using "$datapath\2017D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		keep if _merge==1 
		drop _merge
		/*check if any selected groups have been selected in the more recent 2015 release ("prolonged rotation groups")*/
		merge m:m year country urtgrp using "$datapath\2015D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		keep if _merge==1 
		drop _merge
	destring drpout_year, replace 
	drop if slctd_rtgrp == 0
	/*for later checks*/
	gen drpout_year2014 = drpout_year
	gen slctd_urtgrp2014 = urtgrp 	
	gen slctd_uhid2014 = uhid
	/*merge to masterfile*/
	merge 1:1 year uhid using "$datapath\masterD.dta"
		/*check for duplicates caused by same rotational groups in terms of same hid, different rotation_group*/
		/*duplicates report year country hid*/
		duplicates tag year country hid, generate(test2)
		/*tab country year if test2 != 0 	
		tab urtgrp year  if test2 != 0*/
			/*check if the problem regards a large portion of the rotational group, if the portion is small ignore*/
			gen tag1 = 0 
			replace tag1 = 1 if test2 != 0 
			bysort year country urtgrp : egen ndups = total(tag1)
			gen tag2 = 1 
			bysort year country urtgrp : egen tot = total(tag2)
			gen rdups = ndups / tot
			gen tag3 = 0 
			replace tag3 = 1 if rdups > 0.5
			drop tag1 tag2 ndups tot rdups
			/* extend selection to whole rotational group*/
			bysort year country urtgrp : egen taga = max(tag3)
			drop tag3
			/*check if the rotational group with duplicates is the one covering most years in current release. If yes ignore*/
			tab urtgrp year if taga == 1  & lgstgrp == 0 & _merge == 1
			drop if taga == 1 & lgstgrp == 0 & _merge == 1
			drop  test2 taga
			/*check for unbalances*/
			bysort country : egen test3 = total(nrtgrp2016)
			bysort country : egen test4 = total(nrtgrp2017)
			bysort country : egen test5 = total(nrtgrp2015)
			replace test3 = 0 if test3 == .
			replace test4 = 0 if test4 == .
			replace test5 = 0 if test5 == .
			tab urtgrp year if ( test3 != 0 & lgstgrp == 0 & _merge == 1 ) & ( test4 != 0 & lgstgrp == 0 & _merge == 1 ) &( test5 != 0 & lgstgrp == 0 & _merge == 1 )
			drop if ( test3 != 0 & lgstgrp == 0 & _merge == 1 ) & ( test4 != 0 & lgstgrp == 0 & _merge == 1 ) &( test5 != 0 & lgstgrp == 0 & _merge == 1 )
			drop test3 test4 test5
		/*this is the updated masterfile */
		gen merge2014 = _merge
		drop _merge
		save "$datapath\masterD.dta", replace
		/*this is 2014D file for later control*/
		keep if merge2014 == 1 
		drop merge2014
		save "$datapath\2014D.dta", replace

/* 2013 */

	/*open the 2013 Household register to get data from rotational groups inactive in more recent releases and their uhid*/
	clear
	use DB010 DB020 DB030 DB040 DB075 DB100 DB110 using "$datapath\2013\D_file_2013", clear
	
	local new_var=lower("`var'")

	foreach var of varlist _all {
		local new_var = lower("`var'")
		cap rename `var' `new_var'
	}
	
	/*Block Stata from displaying IDs in exponential format*/
	tostring db030, replace
	gen year=db010
	gen country=db020
	gen hid=db030
	gen rotation_group=db075
	sort country hid year
	replace country = "EL" if country == "GR"
	/* count the number of rotational groups for each country in this release*/
	bysort country rotation_group: gen nvals = _n == 1
	bysort country : egen nrtgrp2013 = total(nvals)
	drop nvals 
	/* get the rotation group(s) that cover most years*/
	bysort country rotation_group : egen maxyear = max(year) 
	bysort country rotation_group : egen minyear = min(year)
	gen years_cov = maxyear - minyear + 1
	bysort country : egen maxgrp = max(years_cov) 
	gen slctd_rtgrp=0
	bysort country rotation_group: replace slctd_rtgrp = rotation_group if years_cov == maxgrp 
	gen lgstgrp = 0
	bysort country rotation_group: replace lgstgrp = 1 if years_cov == maxgrp
	/* build household and rotationgroup IDs that are unique across releases */
	tostring rotation_group, generate(rotation_groupstr)
	gen drpout_year = 0
	replace drpout_year = maxyear + 4 - years_cov
		/*check for rotation groups that dropped out before planned */
		bysort country rotation_group : egen maxyear_grp = max(year)
		replace drpout_year = maxyear_grp if maxyear_grp < maxyear
	tostring drpout_year, replace
	gen uhid = country + rotation_groupstr + drpout_year + hid
	gen urtgrp = country + rotation_groupstr + drpout_year
	destring drpout_year, replace 	
		/*check if any selected groups have been selected in the more recent 2016 release ("prolonged rotation groups")*/
		sort year country rotation_group hid 
		merge m:m year country rotation_group using "$datapath\2016D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		/*tag rotation groups that have already been selected in the more recent release in some years (overlapping)*/
		gen atag = 0
		replace atag = 1 if _merge == 3
		bysort country rotation_group : egen btag = max(atag) 
		bysort country rotation_group : egen ndrpoy = max(drpout_year2016)
		replace drpout_year = ndrpoy if btag == 1
		drop atag btag ndrpoy
		/*update urtgrp and uhid so that "prolonged rotation groups" maintain their urtgrp across different releases*/
		tostring drpout_year, replace
		replace uhid = country + rotation_groupstr + drpout_year + hid
		replace urtgrp = country + rotation_groupstr + drpout_year
		destring drpout_year, replace	
		drop rotation_groupstr maxyear_grp minyear years_cov maxgrp maxyear_grp maxyear
		/*drop overlapping rotation group years and data from the more recent release*/
		keep if _merge==1
		drop _merge 
		/*check if any selected groups have been selected in the more recent 2014 release ("prolonged rotation groups")*/
		merge m:m year country urtgrp using "$datapath\2014D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		keep if _merge==1 
		drop _merge
		/*check if any selected groups have been selected in the more recent 2015 release ("prolonged rotation groups")*/
		merge m:m year country urtgrp using "$datapath\2015D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		keep if _merge==1 
		drop _merge
	destring drpout_year, replace 
	drop if slctd_rtgrp == 0
	/*for later checks*/
	gen drpout_year2013 = drpout_year
	gen slctd_urtgrp2013 = urtgrp 	
	gen slctd_uhid2013 = uhid
	/*merge to masterfile*/
	merge 1:1 year uhid using "$datapath\masterD.dta"
		/*check for duplicates caused by same rotational groups in terms of same hid, different rotation_group*/
		/*duplicates report year country hid*/
		duplicates tag year country hid, generate(test2)
		/*tab country year if test2 != 0 	
		tab urtgrp year  if test2 != 0 */
			/*check if the problem regards a large portion of the rotational group, if the portion is small ignore*/
			gen tag1 = 0 
			replace tag1 = 1 if test2 != 0 
			bysort year country urtgrp : egen ndups = total(tag1)
			gen tag2 = 1 
			bysort year country urtgrp : egen tot = total(tag2)
			gen rdups = ndups / tot
			gen tag3 = 0 
			replace tag3 = 1 if rdups > 0.5
			drop tag1 tag2 ndups tot rdups
			/* extend selection to whole rotational group*/
			bysort year country urtgrp : egen taga = max(tag3)
			drop tag3
			/*check if the rotational group with duplicates is the one covering most years in current release. If yes ignore*/
			tab urtgrp year if taga == 1  & lgstgrp == 0 & _merge == 1
			drop if taga == 1 & lgstgrp == 0 & _merge == 1
			drop  test2 taga
			/*check for unbalances*/
			bysort country : egen test3 = total(nrtgrp2016)
			bysort country : egen test4 = total(nrtgrp2014)
			bysort country : egen test5 = total(nrtgrp2015)
			replace test3 = 0 if test3 == .
			replace test4 = 0 if test4 == .
			replace test5 = 0 if test5 == .
			tab urtgrp year if ( test3 != 0 & lgstgrp == 0 & _merge == 1 ) & ( test4 != 0 & lgstgrp == 0 & _merge == 1 ) &( test5 != 0 & lgstgrp == 0 & _merge == 1 )
			drop if ( test3 != 0 & lgstgrp == 0 & _merge == 1 ) & ( test4 != 0 & lgstgrp == 0 & _merge == 1 ) &( test5 != 0 & lgstgrp == 0 & _merge == 1 )
			drop test3 test4 test5
		/*this is the updated masterfile */
		gen merge2013 = _merge
		drop _merge
		save "$datapath\masterD.dta", replace
		/*this is 2013D file for later control*/
		keep if merge2013 == 1 
		drop merge2013
		save "$datapath\2013D.dta", replace

/* 2012 */
	
	/*open the 2012 Household register to get data from rotational groups inactive in more recent releases and their uhid*/
	clear
	use DB010 DB020 DB030 DB040 DB075 DB100 DB110 using "$datapath\2012\D_file_2012", clear
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	/*Block Stata from displaying IDs in exponential format*/
	tostring db030, replace
	gen year=db010
	gen country=db020
	gen hid=db030
	gen rotation_group=db075
	sort country hid year
	replace country = "EL" if country == "GR"
	/* count the number of rotational groups for each country in this release*/
	bysort country rotation_group: gen nvals = _n == 1
	bysort country : egen nrtgrp2012 = total(nvals)
	drop nvals 
	/* get the rotation group(s) that cover most years*/
	bysort country rotation_group : egen maxyear = max(year) 
	bysort country rotation_group : egen minyear = min(year)
	gen years_cov = maxyear - minyear + 1
	bysort country : egen maxgrp = max(years_cov) 
	gen slctd_rtgrp=0
	bysort country rotation_group: replace slctd_rtgrp = rotation_group if years_cov == maxgrp 
	gen lgstgrp = 0
	bysort country rotation_group: replace lgstgrp = 1 if years_cov == maxgrp
	/* build household and rotationgroup IDs that are unique across releases */
	tostring rotation_group, generate(rotation_groupstr)
	gen drpout_year = 0
	replace drpout_year = maxyear + 4 - years_cov
		/*check for rotation groups that dropped out before planned */
		bysort country rotation_group : egen maxyear_grp = max(year)
		replace drpout_year = maxyear_grp if maxyear_grp < maxyear
	tostring drpout_year, replace
	gen uhid = country + rotation_groupstr + drpout_year + hid
	gen urtgrp = country + rotation_groupstr + drpout_year
	destring drpout_year, replace 	
		/*check if any selected groups have been selected in the more recent 2013 release ("prolonged rotation groups")*/
		sort year country rotation_group hid 
		merge m:m year country rotation_group using "$datapath\2013D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		/*tag rotation groups that have already been selected in the more recent release in some years (overlapping)*/
		gen atag = 0
		replace atag = 1 if _merge == 3
		bysort country rotation_group : egen btag = max(atag) 
		bysort country rotation_group : egen ndrpoy = max(drpout_year2013)
		replace drpout_year = ndrpoy if btag == 1
		drop atag btag ndrpoy
		/*update urtgrp and uhid so that "prolonged rotation groups" maintain their urtgrp across different releases*/
		tostring drpout_year, replace
		replace uhid = country + rotation_groupstr + drpout_year + hid
		replace urtgrp = country + rotation_groupstr + drpout_year
		destring drpout_year, replace	
		drop rotation_groupstr maxyear_grp minyear years_cov maxgrp maxyear_grp maxyear
		/*drop overlapping rotation group years and data from the more recent release*/
		keep if _merge==1
		drop _merge 
		/*check if any selected groups have been selected in the more recent 2014 release ("prolonged rotation groups")*/
		merge m:m year country urtgrp using "$datapath\2014D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		keep if _merge==1 
		drop _merge
		/*check if any selected groups have been selected in the more recent 2015 release ("prolonged rotation groups")*/
		merge m:m year country urtgrp using "$datapath\2015D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		keep if _merge==1 
		drop _merge
	destring drpout_year, replace 
	drop if slctd_rtgrp == 0
	/*for later checks*/
	gen drpout_year2012 = drpout_year
	gen slctd_urtgrp2012 = urtgrp 	
	gen slctd_uhid2012 = uhid
	/*merge to masterfile*/
	merge 1:1 year uhid using "$datapath\masterD.dta"
		/*check for duplicates caused by same rotational groups in terms of same hid, different rotation_group*/
		/*duplicates report year country hid*/
		duplicates tag year country hid, generate(test2)
		tab country year if test2 != 0 	
		tab urtgrp year  if test2 != 0
			/*check if the problem regards a large portion of the rotational group, if the portion is small ignore*/
			gen tag1 = 0 
			replace tag1 = 1 if test2 != 0 
			bysort year country urtgrp : egen ndups = total(tag1)
			gen tag2 = 1 
			bysort year country urtgrp : egen tot = total(tag2)
			gen rdups = ndups / tot
			gen tag3 = 0 
			replace tag3 = 1 if rdups > 0.5
			drop tag1 tag2 ndups tot rdups
			/* extend selection to whole rotational group*/
			bysort year country urtgrp : egen taga = max(tag3)
			drop tag3
			/*check if the rotational group with duplicates is the one covering most years in current release. If yes ignore*/
			tab urtgrp year if taga == 1  & lgstgrp == 0 & _merge == 1
			drop if taga == 1 & lgstgrp == 0 & _merge == 1
			drop  test2 taga
			/*check for unbalances*/
			bysort country : egen test3 = total(nrtgrp2013)
			bysort country : egen test4 = total(nrtgrp2014)
			bysort country : egen test5 = total(nrtgrp2015)
			replace test3 = 0 if test3 == .
			replace test4 = 0 if test4 == .
			replace test5 = 0 if test5 == .
			tab urtgrp year if ( test3 != 0 & lgstgrp == 0 & _merge == 1 ) & ( test4 != 0 & lgstgrp == 0 & _merge == 1 ) &( test5 != 0 & lgstgrp == 0 & _merge == 1 )	
			drop if ( test3 != 0 & lgstgrp == 0 & _merge == 1 ) & ( test4 != 0 & lgstgrp == 0 & _merge == 1 ) & ( test5 != 0 & lgstgrp == 0 & _merge == 1 )
			drop test3 test4 test5
		/*this is the updated masterfile */
		gen merge2012 = _merge
		drop _merge
		save "$datapath\masterD.dta", replace
		/*this is 2012D file for later control*/
		keep if merge2012 == 1 
		drop merge2012
		save "$datapath\2012D.dta", replace

	/* 2011 */
	
	/*open the 2011 Household register to get data from rotational groups inactive in more recent releases and their uhid*/
	clear
	use DB010 DB020 DB030 DB040 DB075 DB100 DB110 using "$datapath\2011\D_file_2011", clear
	
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }

	/*Block Stata from displaying IDs in exponential format*/
	tostring db030, replace
	gen year=db010
	gen country=db020
	gen hid=db030
	gen rotation_group=db075
	sort country hid year
	replace country = "EL" if country == "GR"
	/* count the number of rotational groups for each country in this release*/
	bysort country rotation_group: gen nvals = _n == 1
	bysort country : egen nrtgrp2011 = total(nvals)
	drop nvals 
	/* get the rotation group(s) that cover most years*/
	bysort country rotation_group : egen maxyear = max(year) 
	bysort country rotation_group : egen minyear = min(year)
	gen years_cov = maxyear - minyear + 1
	bysort country : egen maxgrp = max(years_cov) 
	gen slctd_rtgrp=0
	bysort country rotation_group: replace slctd_rtgrp = rotation_group if years_cov == maxgrp 
	gen lgstgrp = 0
	bysort country rotation_group: replace lgstgrp = 1 if years_cov == maxgrp
	/* build household and rotationgroup IDs that are unique across releases */
	tostring rotation_group, generate(rotation_groupstr)
	gen drpout_year = 0
	replace drpout_year = maxyear + 4 - years_cov
		/*check for rotation groups that dropped out before planned */
		bysort country rotation_group : egen maxyear_grp = max(year)
		replace drpout_year = maxyear_grp if maxyear_grp < maxyear
	tostring drpout_year, replace
	gen uhid = country + rotation_groupstr + drpout_year + hid
	gen urtgrp = country + rotation_groupstr + drpout_year
	destring drpout_year, replace 	
		/*check if any selected groups have been selected in the more recent 2012 release ("prolonged rotation groups")*/
		sort year country rotation_group hid 
		merge m:m year country rotation_group using "$datapath\2012D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		/*tag rotation groups that have already been selected in the more recent release in some years (overlapping)*/
		gen atag = 0
		replace atag = 1 if _merge == 3
		bysort country rotation_group : egen btag = max(atag) 
		bysort country rotation_group : egen ndrpoy = max(drpout_year2012)
		replace drpout_year = ndrpoy if btag == 1
		drop atag btag ndrpoy
		/*update urtgrp and uhid so that "prolonged rotation groups" maintain their urtgrp across different releases*/
		tostring drpout_year, replace
		replace uhid = country + rotation_groupstr + drpout_year + hid
		replace urtgrp = country + rotation_groupstr + drpout_year
		destring drpout_year, replace	
		drop rotation_groupstr maxyear_grp minyear years_cov maxgrp maxyear_grp maxyear
		/*drop overlapping rotation group years and data from the more recent release*/
		keep if _merge==1
		drop _merge 
		/*check if any selected groups have been selected in the more recent 2013 release ("prolonged rotation groups")*/
		merge m:m year country urtgrp using "$datapath\2013D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		keep if _merge==1 
		drop _merge
		/*check if any selected groups have been selected in the more recent 2014 release ("prolonged rotation groups")*/
		merge m:m year country urtgrp using "$datapath\2014D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		keep if _merge==1 
		drop _merge
	destring drpout_year, replace 
	drop if slctd_rtgrp == 0
	/*for later checks*/
	gen drpout_year2011 = drpout_year
	gen slctd_urtgrp2011 = urtgrp 	
	gen slctd_uhid2011 = uhid
	/*merge to masterfile*/
	merge 1:1 year uhid using "$datapath\masterD.dta"
		/*check for duplicates caused by same rotational groups in terms of same hid, different rotation_group*/
		/*duplicates report year country hid*/
		duplicates tag year country hid, generate(test2)
		tab country year if test2 != 0 	
		tab urtgrp year  if test2 != 0 
			/*check if the problem regards a large portion of the rotational group, if the portion is small ignore*/
			gen tag1 = 0 
			replace tag1 = 1 if test2 != 0 
			bysort year country urtgrp : egen ndups = total(tag1)
			gen tag2 = 1 
			bysort year country urtgrp : egen tot = total(tag2)
			gen rdups = ndups / tot
			gen tag3 = 0 
			replace tag3 = 1 if rdups > 0.5
			drop tag1 tag2 ndups tot rdups
			/* extend selection to whole rotational group*/
			bysort year country urtgrp : egen taga = max(tag3)
			drop tag3
			/*check if the rotational group with duplicates is the one covering most years in current release. If yes ignore*/
			tab urtgrp year if taga == 1  & lgstgrp == 0 & _merge == 1
			drop if taga == 1 & lgstgrp == 0 & _merge == 1
			drop  test2 taga
			/*check for unbalances*/
			bysort country : egen test3 = total(nrtgrp2012)
			bysort country : egen test4 = total(nrtgrp2013)
			bysort country : egen test5 = total(nrtgrp2014)
			replace test3 = 0 if test3 == .
			replace test4 = 0 if test4 == .
			replace test5 = 0 if test5 == .
			tab urtgrp year if ( test3 != 0 & lgstgrp == 0 & _merge == 1 ) & ( test4 != 0 & lgstgrp == 0 & _merge == 1 ) &( test5 != 0 & lgstgrp == 0 & _merge == 1 )
			drop if ( test3 != 0 & lgstgrp == 0 & _merge == 1 ) & ( test4 != 0 & lgstgrp == 0 & _merge == 1 ) &( test5 != 0 & lgstgrp == 0 & _merge == 1 )
			drop test3 test4 test5
		/*this is the updated masterfile */
		gen merge2011 = _merge
		drop _merge
		save "$datapath\masterD.dta", replace
		/*this is 2011D file for later control*/
		keep if merge2011 == 1 
		drop merge2011
		save "$datapath\2011D.dta", replace

/* 2010 */
		
	/*open the 2010 Household register to get data from rotational groups inactive in more recent releases and their uhid*/
	clear
	use DB010 DB020 DB030 DB040 DB075 DB100 DB110 using "$datapath\2010\D_file_2010", clear
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	

	/*Block Stata from displaying IDs in exponential format*/
	tostring db030, replace
	gen year=db010
	gen country=db020
	gen hid=db030
	gen rotation_group=db075
	sort country hid year
	replace country = "EL" if country == "GR"
	/* count the number of rotational groups for each country in this release*/
	bysort country rotation_group: gen nvals = _n == 1
	bysort country : egen nrtgrp2010 = total(nvals)
	drop nvals 
	/* get the rotation group(s) that cover most years*/
	bysort country rotation_group : egen maxyear = max(year) 
	bysort country rotation_group : egen minyear = min(year)
	gen years_cov = maxyear - minyear + 1
	bysort country : egen maxgrp = max(years_cov) 
	gen slctd_rtgrp=0
	bysort country rotation_group: replace slctd_rtgrp = rotation_group if years_cov == maxgrp 
	gen lgstgrp = 0
	bysort country rotation_group: replace lgstgrp = 1 if years_cov == maxgrp
	/* build household and rotationgroup IDs that are unique across releases */
	tostring rotation_group, generate(rotation_groupstr)
	gen drpout_year = 0
	replace drpout_year = maxyear + 4 - years_cov
		/*check for rotation groups that dropped out before planned */
		bysort country rotation_group : egen maxyear_grp = max(year)
		replace drpout_year = maxyear_grp if maxyear_grp < maxyear
	tostring drpout_year, replace
	gen uhid = country + rotation_groupstr + drpout_year + hid
	gen urtgrp = country + rotation_groupstr + drpout_year
	destring drpout_year, replace 	
		/*check if any selected groups have been selected in the more recent 2011 release ("prolonged rotation groups")*/
		sort year country rotation_group hid 
		merge m:m year country rotation_group using "$datapath\2011D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		/*tag rotation groups that have already been selected in the more recent release in some years (overlapping)*/
		gen atag = 0
		replace atag = 1 if _merge == 3
		bysort country rotation_group : egen btag = max(atag) 
		bysort country rotation_group : egen ndrpoy = max(drpout_year2011)
		replace drpout_year = ndrpoy if btag == 1
		drop atag btag ndrpoy
		/*update urtgrp and uhid so that "prolonged rotation groups" maintain their urtgrp across different releases*/
		tostring drpout_year, replace
		replace uhid = country + rotation_groupstr + drpout_year + hid
		replace urtgrp = country + rotation_groupstr + drpout_year
		destring drpout_year, replace	
		drop rotation_groupstr maxyear_grp minyear years_cov maxgrp maxyear_grp maxyear
		/*drop overlapping rotation group years and data from the more recent release*/
		keep if _merge==1
		drop _merge 
		/*check if any selected groups have been selected in the more recent 2012 release ("prolonged rotation groups")*/
		merge m:m year country urtgrp using "$datapath\2012D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		keep if _merge==1 
		drop _merge
		/*check if any selected groups have been selected in the more recent 2013 release ("prolonged rotation groups")*/
		merge m:m year country urtgrp using "$datapath\2013D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		keep if _merge==1 
		drop _merge
	destring drpout_year, replace 
	drop if slctd_rtgrp == 0
	/*for later checks*/
	gen drpout_year2010 = drpout_year
	gen slctd_urtgrp2010 = urtgrp 	
	gen slctd_uhid2010 = uhid
	/*merge to masterfile*/
	merge 1:1 year uhid using "$datapath\masterD.dta"
		/*check for duplicates caused by same rotational groups in terms of same hid, different rotation_group*/
		/*duplicates report year country hid*/
		duplicates tag year country hid, generate(test2)
		tab country year if test2 != 0 	
		tab urtgrp year  if test2 != 0 
			/*check if the problem regards a large portion of the rotational group, if the portion is small ignore*/
			gen tag1 = 0 
			replace tag1 = 1 if test2 != 0 
			bysort year country urtgrp : egen ndups = total(tag1)
			gen tag2 = 1 
			bysort year country urtgrp : egen tot = total(tag2)
			gen rdups = ndups / tot
			gen tag3 = 0 
			replace tag3 = 1 if rdups > 0.5
			drop tag1 tag2 ndups tot rdups
			/* extend selection to whole rotational group*/
			bysort year country urtgrp : egen taga = max(tag3)
			drop tag3
			/*check if the rotational group with duplicates is the one covering most years in current release. If yes ignore*/
			tab urtgrp year if taga == 1  & lgstgrp == 0 & _merge == 1
			drop if taga == 1 & lgstgrp == 0 & _merge == 1
			drop  test2 taga
			/*check for unbalances*/
			bysort country : egen test3 = total(nrtgrp2011)
			bysort country : egen test4 = total(nrtgrp2012)
			bysort country : egen test5 = total(nrtgrp2013)
			replace test3 = 0 if test3 == .
			replace test4 = 0 if test4 == .
			replace test5 = 0 if test5 == .
			tab urtgrp year if ( test3 != 0 & lgstgrp == 0 & _merge == 1 ) & ( test4 != 0 & lgstgrp == 0 & _merge == 1 ) &( test5 != 0 & lgstgrp == 0 & _merge == 1 )
			drop if ( test3 != 0 & lgstgrp == 0 & _merge == 1 ) & ( test4 != 0 & lgstgrp == 0 & _merge == 1 ) &( test5 != 0 & lgstgrp == 0 & _merge == 1 )
			drop test3 test4 test5
		/*this is the updated masterfile */
		gen merge2010 = _merge
		drop _merge
		save "$datapath\masterD.dta", replace
		/*this is 2010D file for later control*/
		keep if merge2010 == 1 
		drop merge2010
		save "$datapath\2010D.dta", replace	
		

		/* 2009 */

	/*open the 2009 Household register to get data from rotational groups inactive in more recent releases and their uhid*/
	clear
	use DB010 DB020 DB030 DB040 DB075 DB100 DB110 using "$datapath\2009\D_file_2009", clear

	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }

	/*Block Stata from displaying IDs in exponential format*/
	tostring db030, replace
	gen year=db010
	gen country=db020
	gen hid=db030
	gen rotation_group=db075
	sort country hid year
	replace country = "EL" if country == "GR"
	/* count the number of rotational groups for each country in this release*/
	bysort country rotation_group: gen nvals = _n == 1
	bysort country : egen nrtgrp2009 = total(nvals)
	drop nvals 
	/* get the rotation group(s) that cover most years*/
	bysort country rotation_group : egen maxyear = max(year) 
	bysort country rotation_group : egen minyear = min(year)
	gen years_cov = maxyear - minyear + 1
	bysort country : egen maxgrp = max(years_cov) 
	gen slctd_rtgrp=0
	bysort country rotation_group: replace slctd_rtgrp = rotation_group if years_cov == maxgrp 
	gen lgstgrp = 0
	bysort country rotation_group: replace lgstgrp = 1 if years_cov == maxgrp
	/* build household and rotationgroup IDs that are unique across releases */
	tostring rotation_group, generate(rotation_groupstr)
	gen drpout_year = 0
	replace drpout_year = maxyear + 4 - years_cov
		/*check for rotation groups that dropped out before planned */
		bysort country rotation_group : egen maxyear_grp = max(year)
		replace drpout_year = maxyear_grp if maxyear_grp < maxyear
	tostring drpout_year, replace
	gen uhid = country + rotation_groupstr + drpout_year + hid
	gen urtgrp = country + rotation_groupstr + drpout_year
	destring drpout_year, replace 	
		/*check if any selected groups have been selected in the more recent 2010 release ("prolonged rotation groups")*/
		sort year country rotation_group hid 
		merge m:m year country rotation_group using "$datapath\2010D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		/*tag rotation groups that have already been selected in the more recent release in some years (overlapping)*/
		gen atag = 0
		replace atag = 1 if _merge == 3
		bysort country rotation_group : egen btag = max(atag) 
		bysort country rotation_group : egen ndrpoy = max(drpout_year2010)
		replace drpout_year = ndrpoy if btag == 1
		drop atag btag ndrpoy
		/*update urtgrp and uhid so that "prolonged rotation groups" maintain their urtgrp across different releases*/
		tostring drpout_year, replace
		replace uhid = country + rotation_groupstr + drpout_year + hid
		replace urtgrp = country + rotation_groupstr + drpout_year
		destring drpout_year, replace	
		drop rotation_groupstr maxyear_grp minyear years_cov maxgrp maxyear_grp maxyear
		/*drop overlapping rotation group years and data from the more recent release*/
		keep if _merge==1
		drop _merge 
		/*check if any selected groups have been selected in the more recent 2011 release ("prolonged rotation groups")*/
		merge m:m year country urtgrp using "$datapath\2011D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		keep if _merge==1 
		drop _merge
		/*check if any selected groups have been selected in the more recent 2012 release ("prolonged rotation groups")*/
		merge m:m year country urtgrp using "$datapath\2012D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		keep if _merge==1 
		drop _merge
	destring drpout_year, replace 
	drop if slctd_rtgrp == 0
	/*for later checks*/
	gen drpout_year2009 = drpout_year
	gen slctd_urtgrp2009 = urtgrp 	
	gen slctd_uhid2009 = uhid
	/*merge to masterfile*/
	merge 1:1 year uhid using "$datapath\masterD.dta"
		/*check for duplicates caused by same rotational groups in terms of same hid, different rotation_group*/
		/*duplicates report year country hid*/
		duplicates tag year country hid, generate(test2)
		/*tab country year if test2 != 0 	
		tab urtgrp year  if test2 != 0 */
			/*check if the problem regards a large portion of the rotational group, if the portion is small ignore*/
			gen tag1 = 0 
			replace tag1 = 1 if test2 != 0 
			bysort year country urtgrp : egen ndups = total(tag1)
			gen tag2 = 1 
			bysort year country urtgrp : egen tot = total(tag2)
			gen rdups = ndups / tot
			gen tag3 = 0 
			replace tag3 = 1 if rdups > 0.5
			drop tag1 tag2 ndups tot rdups
			/* extend selection to whole rotational group*/
			bysort year country urtgrp : egen taga = max(tag3)
			drop tag3
			/*check if the rotational group with duplicates is the one covering most years in current release. If yes ignore*/
			tab urtgrp year if taga == 1  & lgstgrp == 0 & _merge == 1
			drop if taga == 1 & lgstgrp == 0 & _merge == 1
			drop  test2 taga
			/*check for unbalances*/
			bysort country : egen test3 = total(nrtgrp2010)
			bysort country : egen test4 = total(nrtgrp2011)
			bysort country : egen test5 = total(nrtgrp2012)
			replace test3 = 0 if test3 == .
			replace test4 = 0 if test4 == .
			replace test5 = 0 if test5 == .
			tab urtgrp year if ( test3 != 0 & lgstgrp == 0 & _merge == 1 ) & ( test4 != 0 & lgstgrp == 0 & _merge == 1 ) &( test5 != 0 & lgstgrp == 0 & _merge == 1 )
			drop if ( test3 != 0 & lgstgrp == 0 & _merge == 1 ) & ( test4 != 0 & lgstgrp == 0 & _merge == 1 ) &( test5 != 0 & lgstgrp == 0 & _merge == 1 )
			drop test3 test4 test5
		/*this is the updated masterfile */
		gen merge2009 = _merge
		drop _merge
		save "$datapath\masterD.dta", replace
		/*this is 2009D file for later control*/
		keep if merge2009 == 1 
		drop merge2009
		save "$datapath\2009D.dta", replace	
		
	
		
/* 2008 */

	/*open the 2008 Household register to get data from rotational groups inactive in more recent releases and their uhid*/
	clear
	use DB010 DB020 DB030 DB040 DB075 DB100 DB110 using "$datapath\2008\D_file_2008", clear
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }

	/*Block Stata from displaying IDs in exponential format*/
	tostring db030, replace
	gen year=db010
	gen country=db020
	gen hid=db030
	gen rotation_group=db075 
	sort country hid year
	replace country = "EL" if country == "GR"
	/* count the number of rotational groups for each country in this release*/
	bysort country rotation_group: gen nvals = _n == 1
	bysort country : egen nrtgrp2008 = total(nvals)
	drop nvals 
	/* get the rotation group(s) that cover most years*/
	bysort country rotation_group : egen maxyear = max(year) 
	bysort country rotation_group : egen minyear = min(year)
	gen years_cov = maxyear - minyear + 1
	bysort country : egen maxgrp = max(years_cov) 
	gen slctd_rtgrp=0
	bysort country rotation_group: replace slctd_rtgrp = rotation_group if years_cov == maxgrp 
	gen lgstgrp = 0
	bysort country rotation_group: replace lgstgrp = 1 if years_cov == maxgrp
	/* build household and rotationgroup IDs that are unique across releases */
	tostring rotation_group, generate(rotation_groupstr)
	gen drpout_year = 0
	replace drpout_year = maxyear + 4 - years_cov
		/*check for rotation groups that dropped out before planned */
		bysort country rotation_group : egen maxyear_grp = max(year)
		replace drpout_year = maxyear_grp if maxyear_grp < maxyear
	tostring drpout_year, replace
	gen uhid = country + rotation_groupstr + drpout_year + hid
	gen urtgrp = country + rotation_groupstr + drpout_year
	destring drpout_year, replace 	
		/*check if any selected groups have been selected in the more recent 2009 release ("prolonged rotation groups")*/
		sort year country rotation_group hid 
		merge m:m year country rotation_group using "$datapath\2009D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		/*tag rotation groups that have already been selected in the more recent release in some years (overlapping)*/
		gen atag = 0
		replace atag = 1 if _merge == 3
		bysort country rotation_group : egen btag = max(atag) 
		bysort country rotation_group : egen ndrpoy = max(drpout_year2009)
		replace drpout_year = ndrpoy if btag == 1
		drop atag btag ndrpoy
		/*update urtgrp and uhid so that "prolonged rotation groups" maintain their urtgrp across different releases*/
		tostring drpout_year, replace
		replace uhid = country + rotation_groupstr + drpout_year + hid
		replace urtgrp = country + rotation_groupstr + drpout_year
		destring drpout_year, replace	
		drop rotation_groupstr maxyear_grp minyear years_cov maxgrp maxyear_grp maxyear
		/*drop overlapping rotation group years and data from the more recent release*/
		keep if _merge==1
		drop _merge 
		/*check if any selected groups have been selected in the more recent 2010 release ("prolonged rotation groups")*/
		merge m:m year country urtgrp using "$datapath\2010D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		keep if _merge==1 
		drop _merge
		/*check if any selected groups have been selected in the more recent 2011 release ("prolonged rotation groups")*/
		merge m:m year country urtgrp using "$datapath\2011D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		keep if _merge==1 
		drop _merge
	destring drpout_year, replace 
	drop if slctd_rtgrp == 0
	/*for later checks*/
	gen drpout_year2008 = drpout_year
	gen slctd_urtgrp2008 = urtgrp 	
	gen slctd_uhid2008 = uhid
	/*merge to masterfile*/
	merge 1:1 year uhid using "$datapath\masterD.dta"
		/*check for duplicates caused by same rotational groups in terms of same hid, different rotation_group*/
		/*duplicates report year country hid*/
		duplicates tag year country hid, generate(test2)
		/*tab country year if test2 != 0 	
		tab urtgrp year  if test2 != 0 */
			/*check if the problem regards a large portion of the rotational group, if the portion is small ignore*/
			gen tag1 = 0 
			replace tag1 = 1 if test2 != 0 
			bysort year country urtgrp : egen ndups = total(tag1)
			gen tag2 = 1 
			bysort year country urtgrp : egen tot = total(tag2)
			gen rdups = ndups / tot
			gen tag3 = 0 
			replace tag3 = 1 if rdups > 0.5
			drop tag1 tag2 ndups tot rdups
			/* extend selection to whole rotational group*/
			bysort year country urtgrp : egen taga = max(tag3)
			drop tag3
			/*check if the rotational group with duplicates is the one covering most years in current release. If yes ignore*/
			tab urtgrp year if taga == 1  & lgstgrp == 0 & _merge == 1
			drop if taga == 1 & lgstgrp == 0 & _merge == 1
			drop  test2 taga
			/*check for unbalances*/
			bysort country : egen test3 = total(nrtgrp2009)
			bysort country : egen test4 = total(nrtgrp2010)
			bysort country : egen test5 = total(nrtgrp2011)
			replace test3 = 0 if test3 == .
			replace test4 = 0 if test4 == .
			replace test5 = 0 if test5 == .
			tab urtgrp year if ( test3 != 0 & lgstgrp == 0 & _merge == 1 ) & ( test4 != 0 & lgstgrp == 0 & _merge == 1 ) &( test5 != 0 & lgstgrp == 0 & _merge == 1 )
			drop if ( test3 != 0 & lgstgrp == 0 & _merge == 1 ) & ( test4 != 0 & lgstgrp == 0 & _merge == 1 ) &( test5 != 0 & lgstgrp == 0 & _merge == 1 )
			drop test3 test4 test5
		/*this is the updated masterfile */
		gen merge2008 = _merge
		drop _merge
		save "$datapath\masterD.dta", replace
		/*this is 2008D file for later control*/
		keep if merge2008 == 1 
		drop merge2008
		save "$datapath\2008D.dta", replace			

/* 2007 */		
		/*open the 2007 Household register to get data from rotational groups inactive in more recent releases and their uhid*/
		clear
	use DB010 DB020 DB030 DB040 DB075 DB100 DB110 using "$datapath\2007\D_file_2007", clear
		
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	

		/*Block Stata from displaying IDs in exponential format*/
		tostring db030, replace
		gen year=db010
		gen country=db020
		gen hid=db030
		gen rotation_group=db075 
		sort country hid year
		replace country = "EL" if country == "GR"
		/* count the number of rotational groups for each country in this release*/
		bysort country rotation_group: gen nvals = _n == 1
		bysort country : egen nrtgrp2007 = total(nvals)
		drop nvals 
		/* get the rotation group(s) that cover most years*/
		bysort country rotation_group : egen maxyear = max(year) 
		bysort country rotation_group : egen minyear = min(year)
		gen years_cov = maxyear - minyear + 1
		bysort country : egen maxgrp = max(years_cov) 
		gen slctd_rtgrp=0
		bysort country rotation_group: replace slctd_rtgrp = rotation_group if years_cov == maxgrp 
		gen lgstgrp = 0
		bysort country rotation_group: replace lgstgrp = 1 if years_cov == maxgrp
		/* build household and rotationgroup IDs that are unique across releases */
		tostring rotation_group, generate(rotation_groupstr)
		gen drpout_year = 0
		replace drpout_year = maxyear + 4 - years_cov
			/*check for rotation groups that dropped out before planned */
			bysort country rotation_group : egen maxyear_grp = max(year)
			replace drpout_year = maxyear_grp if maxyear_grp < maxyear
		tostring drpout_year, replace
		gen uhid = country + rotation_groupstr + drpout_year + hid
		gen urtgrp = country + rotation_groupstr + drpout_year
		destring drpout_year, replace 	
		/*check if any selected groups have been selected in the more recent 2008 release ("prolonged rotation groups")*/
		sort year country rotation_group hid 
		merge m:m year country rotation_group using "$datapath\2008D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		/*tag rotation groups that have already been selected in the more recent release in some years (overlapping)*/
		gen atag = 0
		replace atag = 1 if _merge == 3
		bysort country rotation_group : egen btag = max(atag) 
		bysort country rotation_group : egen ndrpoy = max(drpout_year2008)
		replace drpout_year = ndrpoy if btag == 1
		drop atag btag ndrpoy
		/*update urtgrp and uhid so that "prolonged rotation groups" maintain their urtgrp across different releases*/
		tostring drpout_year, replace
		replace uhid = country + rotation_groupstr + drpout_year + hid
		replace urtgrp = country + rotation_groupstr + drpout_year
		destring drpout_year, replace	
		drop rotation_groupstr maxyear_grp minyear years_cov maxgrp maxyear_grp maxyear
		/*drop overlapping rotation group years and data from the more recent release*/
		keep if _merge==1
		drop _merge 
		/*check if any selected groups have been selected in the more recent 2009 release ("prolonged rotation groups")*/
		merge m:m year country urtgrp using "$datapath\2009D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		keep if _merge==1 
		drop _merge
		/*check if any selected groups have been selected in the more recent 2010 release ("prolonged rotation groups")*/
		merge m:m year country urtgrp using "$datapath\2010D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		keep if _merge==1 
		drop _merge
	destring drpout_year, replace 
	drop if slctd_rtgrp == 0
	/*for later checks*/
	gen drpout_year2007 = drpout_year
	gen slctd_urtgrp2007 = urtgrp 	
	gen slctd_uhid2007 = uhid
	/*merge to masterfile*/
	merge 1:1 year uhid using "$datapath\masterD.dta"
		/*check for duplicates caused by same rotational groups in terms of same hid, different rotation_group*/
		/*duplicates report year country hid*/
		duplicates tag year country hid, generate(test2)
		/*tab country year if test2 != 0 	
		tab urtgrp year  if test2 != 0*/
			/*check if the problem regards a large portion of the rotational group, if the portion is small ignore*/
			gen tag1 = 0 
			replace tag1 = 1 if test2 != 0 
			bysort year country urtgrp : egen ndups = total(tag1)
			gen tag2 = 1 
			bysort year country urtgrp : egen tot = total(tag2)
			gen rdups = ndups / tot
			gen tag3 = 0 
			replace tag3 = 1 if rdups > 0.5
			drop tag1 tag2 ndups tot rdups
			/* extend selection to whole rotational group*/
			bysort year country urtgrp : egen taga = max(tag3)
			drop tag3
			/*check if the rotational group with duplicates is the one covering most years in current release. If yes ignore*/
			tab urtgrp year if taga == 1  & lgstgrp == 0 & _merge == 1
			drop if taga == 1 & lgstgrp == 0 & _merge == 1
			drop  test2 taga
			/*check for unbalances*/
			bysort country : egen test3 = total(nrtgrp2008)
			bysort country : egen test4 = total(nrtgrp2009)
			bysort country : egen test5 = total(nrtgrp2010)
			replace test3 = 0 if test3 == .
			replace test4 = 0 if test4 == .
			replace test5 = 0 if test5 == .
			tab urtgrp year if ( test3 != 0 & lgstgrp == 0 & _merge == 1 ) & ( test4 != 0 & lgstgrp == 0 & _merge == 1 ) & ( test5 != 0 & lgstgrp == 0 & _merge == 1 ) 	
			drop if ( test3 != 0 & lgstgrp == 0 & _merge == 1 ) & ( test4 != 0 & lgstgrp == 0 & _merge == 1 ) & ( test5 != 0 & lgstgrp == 0 & _merge == 1 )
			drop test3 test4 test5
		/*this is the updated masterfile */
		gen merge2007 = _merge
		drop _merge
		save "$datapath\masterD.dta", replace
		/*this is 2007D file for later control*/
		keep if merge2007 == 1 
		drop merge2007
		save "$datapath\2007D.dta", replace			

/* 2006 */
		
		/*open the 2006 Household register to get data from rotational groups inactive in more recent releases and their uhid*/
		clear
	use DB010 DB020 DB030 DB040 DB075 DB100 DB110 using "$datapath\2006\D_file_2006", clear
		
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	
		/*Block Stata from displaying IDs in exponential format*/
		tostring db030, replace
		gen year=db010
		gen country=db020
		gen hid=db030
		gen rotation_group=db075 
		sort country hid year
		replace country = "EL" if country == "GR"
		/* count the number of rotational groups for each country in this release*/
		bysort country rotation_group: gen nvals = _n == 1
		bysort country : egen nrtgrp2006 = total(nvals)
		drop nvals 
		/* get the rotation group(s) that cover most years*/
		bysort country rotation_group : egen maxyear = max(year) 
		bysort country rotation_group : egen minyear = min(year)
		gen years_cov = maxyear - minyear + 1
		bysort country : egen maxgrp = max(years_cov) 
		gen slctd_rtgrp=0
		bysort country rotation_group: replace slctd_rtgrp = rotation_group if years_cov == maxgrp 
		gen lgstgrp = 0
		bysort country rotation_group: replace lgstgrp = 1 if years_cov == maxgrp
		/* build household and rotationgroup IDs that are unique across releases */
		tostring rotation_group, generate(rotation_groupstr)
		gen drpout_year = 0
		replace drpout_year = maxyear + 4 - years_cov
			/*check for rotation groups that dropped out before planned */
			bysort country rotation_group : egen maxyear_grp = max(year)
			replace drpout_year = maxyear_grp if maxyear_grp < maxyear
		tostring drpout_year, replace
		gen uhid = country + rotation_groupstr + drpout_year + hid
		gen urtgrp = country + rotation_groupstr + drpout_year
		destring drpout_year, replace 	
		/*check if any selected groups have been selected in the more recent 2007 release ("prolonged rotation groups")*/
		sort year country rotation_group hid 
		merge m:m year country rotation_group using "$datapath\2007D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		/*tag rotation groups that have already been selected in the more recent release in some years (overlapping)*/
		gen atag = 0
		replace atag = 1 if _merge == 3
		bysort country rotation_group : egen btag = max(atag) 
		bysort country rotation_group : egen ndrpoy = max(drpout_year2007)
		replace drpout_year = ndrpoy if btag == 1
		drop atag btag ndrpoy
		/*update urtgrp and uhid so that "prolonged rotation groups" maintain their urtgrp across different releases*/
		tostring drpout_year, replace
		replace uhid = country + rotation_groupstr + drpout_year + hid
		replace urtgrp = country + rotation_groupstr + drpout_year
		destring drpout_year, replace	
		drop rotation_groupstr maxyear_grp minyear years_cov maxgrp maxyear_grp maxyear
		/*drop overlapping rotation group years and data from the more recent release*/
		keep if _merge==1
		drop _merge 
		/*check if any selected groups have been selected in the more recent 2008 release ("prolonged rotation groups")*/
		merge m:m year country urtgrp using "$datapath\2008D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		keep if _merge==1 
		drop _merge
		/*check if any selected groups have been selected in the more recent 2009 release ("prolonged rotation groups")*/
		merge m:m year country urtgrp using "$datapath\2009D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		keep if _merge==1 
		drop _merge
	destring drpout_year, replace 
	drop if slctd_rtgrp == 0
	/*for later checks*/
	gen drpout_year2006 = drpout_year
	gen slctd_urtgrp2006 = urtgrp 	
	gen slctd_uhid2006 = uhid
	/*merge to masterfile*/
	merge 1:1 year uhid using "$datapath\masterD.dta"
		/*check for duplicates caused by same rotational groups in terms of same hid, different rotation_group*/
		/*duplicates report year country hid*/
		duplicates tag year country hid, generate(test2)
		/*tab country year if test2 != 0 	
		tab urtgrp year  if test2 != 0*/
			/*check if the problem regards a large portion of the rotational group, if the portion is small ignore*/
			gen tag1 = 0 
			replace tag1 = 1 if test2 != 0 
			bysort year country urtgrp : egen ndups = total(tag1)
			gen tag2 = 1 
			bysort year country urtgrp : egen tot = total(tag2)
			gen rdups = ndups / tot
			gen tag3 = 0 
			replace tag3 = 1 if rdups > 0.5
			drop tag1 tag2 ndups tot rdups
			/* extend selection to whole rotational group*/
			bysort year country urtgrp : egen taga = max(tag3)
			drop tag3
			/*check if the rotational group with duplicates is the one covering most years in current release. If yes ignore*/
			tab urtgrp year if taga == 1  & lgstgrp == 0 & _merge == 1
			drop if taga == 1 & lgstgrp == 0 & _merge == 1
			drop  test2 taga
			/*check for unbalances*/
			bysort country : egen test3 = total(nrtgrp2007)
			bysort country : egen test4 = total(nrtgrp2008)
			bysort country : egen test5 = total(nrtgrp2009)
			replace test3 = 0 if test3 == .
			replace test4 = 0 if test4 == .
			replace test5 = 0 if test5 == .
			tab urtgrp year if ( test3 != 0 & lgstgrp == 0 & _merge == 1 ) & ( test4 != 0 & lgstgrp == 0 & _merge == 1 ) &( test5 != 0 & lgstgrp == 0 & _merge == 1 )
			drop if ( test3 != 0 & lgstgrp == 0 & _merge == 1 ) & ( test4 != 0 & lgstgrp == 0 & _merge == 1 ) &( test5 != 0 & lgstgrp == 0 & _merge == 1 )
			drop test3 test4 test5
		/*this is the updated masterfile */
		gen merge2006 = _merge
		drop _merge
		save "$datapath\masterD.dta", replace
		/*this is 2006D file for later control*/
		keep if merge2006 == 1 
		drop merge2006
		save "$datapath\2006D.dta", replace			

/* 2005 */
		
		/*open the 2005 Household register to get data from rotational groups inactive in more recent releases and their uhid*/
	use DB010 DB020 DB030 DB040 DB075 DB100 DB110 using "$datapath\2005\D_file_2005", clear
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	

		/*Block Stata from displaying IDs in exponential format*/
		tostring db030, replace
		gen year=db010
		gen country=db020
		gen hid=db030
		gen rotation_group=db075
		sort country hid year
		replace country = "EL" if country == "GR"
		/* count the number of rotational groups for each country in this release*/
		bysort country rotation_group: gen nvals = _n == 1
		bysort country : egen nrtgrp2005 = total(nvals)
		drop nvals 
		/* get the rotation group(s) that cover most years*/
		bysort country rotation_group : egen maxyear = max(year) 
		bysort country rotation_group : egen minyear = min(year)
		gen years_cov = maxyear - minyear + 1
		bysort country : egen maxgrp = max(years_cov) 
		gen slctd_rtgrp=0
		bysort country rotation_group: replace slctd_rtgrp = rotation_group if years_cov == maxgrp 
		gen lgstgrp = 0
		bysort country rotation_group: replace lgstgrp = 1 if years_cov == maxgrp
		/* build household and rotationgroup IDs that are unique across releases */
		tostring rotation_group, generate(rotation_groupstr)
		gen drpout_year = 0
		replace drpout_year = maxyear + 4 - years_cov
			/*check for rotation groups that dropped out before planned */
			bysort country rotation_group : egen maxyear_grp = max(year)
			replace drpout_year = maxyear_grp if maxyear_grp < maxyear
		tostring drpout_year, replace
		gen uhid = country + rotation_groupstr + drpout_year + hid
		gen urtgrp = country + rotation_groupstr + drpout_year
		destring drpout_year, replace 	
		/*check if any selected groups have been selected in the more recent 2006 release ("prolonged rotation groups")*/
		sort year country rotation_group hid 
		merge m:m year country rotation_group using "$datapath\2006D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		/*tag rotation groups that have already been selected in the more recent release in some years (overlapping)*/
		gen atag = 0
		replace atag = 1 if _merge == 3
		bysort country rotation_group : egen btag = max(atag) 
		bysort country rotation_group : egen ndrpoy = max(drpout_year2006)
		replace drpout_year = ndrpoy if btag == 1
		drop atag btag ndrpoy
		/*update urtgrp and uhid so that "prolonged rotation groups" maintain their urtgrp across different releases*/
		tostring drpout_year, replace
		replace uhid = country + rotation_groupstr + drpout_year + hid
		replace urtgrp = country + rotation_groupstr + drpout_year
		destring drpout_year, replace	
		drop rotation_groupstr maxyear_grp minyear years_cov maxgrp maxyear_grp maxyear
		/*drop overlapping rotation group years and data from the more recent release*/
		keep if _merge==1
		drop _merge 
		/*check if any selected groups have been selected in the more recent 2007 release ("prolonged rotation groups")*/
		merge m:m year country urtgrp using "$datapath\2007D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		keep if _merge==1 
		drop _merge
		/*check if any selected groups have been selected in the more recent 2008 release ("prolonged rotation groups")*/
		merge m:m year country urtgrp using "$datapath\2008D.dta"
		replace slctd_rtgrp = rotation_group if _merge == 1
		keep if _merge==1 
		drop _merge
	destring drpout_year, replace 
	drop if slctd_rtgrp == 0
	/*for later checks*/
	gen drpout_year2005 = drpout_year
	gen slctd_urtgrp2005 = urtgrp 	
	gen slctd_uhid2005 = uhid
	/*merge to masterfile*/
	merge 1:1 year uhid using "$datapath\masterD.dta"
		/*check for duplicates caused by same rotational groups in terms of same hid, different rotation_group*/
		/*duplicates report year country hid*/
		duplicates tag year country hid, generate(test2)
		/*tab country year if test2 != 0 	
		tab urtgrp year  if test2 != 0 */
			/*check if the problem regards a large portion of the rotational group, if the portion is small ignore*/
			gen tag1 = 0 
			replace tag1 = 1 if test2 != 0 
			bysort year country urtgrp : egen ndups = total(tag1)
			gen tag2 = 1 
			bysort year country urtgrp : egen tot = total(tag2)
			gen rdups = ndups / tot
			gen tag3 = 0 
			replace tag3 = 1 if rdups > 0.5
			drop tag1 tag2 ndups tot rdups
			/* extend selection to whole rotational group*/
			bysort year country urtgrp : egen taga = max(tag3)
			drop tag3
			/*check if the rotational group with duplicates is the one covering most years in current release. If yes ignore*/
			tab urtgrp year if taga == 1  & lgstgrp == 0 & _merge == 1
			drop if taga == 1 & lgstgrp == 0 & _merge == 1
			drop  test2 taga
			/*check for unbalances*/
			bysort country : egen test3 = total(nrtgrp2006)
			bysort country : egen test4 = total(nrtgrp2007)
			bysort country : egen test5 = total(nrtgrp2008)
			replace test3 = 0 if test3 == .
			replace test4 = 0 if test4 == .
			replace test5 = 0 if test5 == .
			tab urtgrp year if ( test3 != 0 & lgstgrp == 0 & _merge == 1 ) & ( test4 != 0 & lgstgrp == 0 & _merge == 1 ) &( test5 != 0 & lgstgrp == 0 & _merge == 1 )
			drop if ( test3 != 0 & lgstgrp == 0 & _merge == 1 ) & ( test4 != 0 & lgstgrp == 0 & _merge == 1 ) &( test5 != 0 & lgstgrp == 0 & _merge == 1 )
			drop test3 test4 test5
		/*this is the updated masterfile */
		gen merge2005 = _merge
		drop _merge
		save "$datapath\masterD.dta", replace
		/*this is 2005D file for later control*/
		keep if merge2005 == 1 
		drop merge2005
		save "$datapath\2005D.dta", replace	
	/*clean up and generate yrelease*/
	
	
	
	
	use "$datapath\masterD.dta", clear 
	gen yrelease = 0 
	replace yrelease = 2020 if merge2020 == 1
	replace yrelease = 2019 if merge2019 == 1
	replace yrelease = 2018 if merge2018 == 1
	replace yrelease = 2017 if merge2017 == 1
	replace yrelease = 2016 if merge2016 == 1
	replace yrelease = 2015 if merge2015 == 1
	replace yrelease = 2014 if merge2014 == 1
	replace yrelease = 2013 if merge2013 == 1
	replace yrelease = 2012 if merge2012 == 1
	replace yrelease = 2011 if merge2011 == 1
	replace yrelease = 2010 if merge2010 == 1
	replace yrelease = 2009 if merge2009 == 1
	replace yrelease = 2008 if merge2008 == 1
	replace yrelease = 2007 if merge2007 == 1
	replace yrelease = 2006 if merge2006 == 1
	replace yrelease = 2005 if merge2005 == 1
	
	drop  slctd_rtgrp lgstgrp drpout_year maxgrp ///
	      nrtgrp*  drpout_year* slctd_urtgrp*  slctd_uhi*  merge* 

		  
	save "$datapath\masterD.dta", replace
	
	
	/***/
	/* create one H file containing data from all releases */
	/***/
	
	/* 2020 */
	clear
	use HB010 HB020 HB030 HB050 HB100 HY010 HY020 HX040 HH010 using "$datapath\2020\H_file_2020.dta", clear
	
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	

	*Block Stata from displaying IDs in exponential format*
	tostring hb030, replace
	gen year = hb010
	gen hid = hb030 
	gen country = hb020 
	sort year country hid 
	*checking for duplicates or errors in hid*
	/*duplicates report country year hid*/
	*select observations/households by merging with selected rotational groups from the D file *
	merge 1:1 year country hid using "$datapath\2020D.dta"
	keep if _merge==3
	drop _merge
	destring hb100 , replace force
	save "$datapath\masterH.dta", replace
	
	/* 2019 */
	
	clear
	use  HB010 HB020 HB030 HB050 HB100 HY010 HY020 HX040 HH010 using "$datapath\2019\H_file_2019.dta", clear

	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	

	*Block Stata from displaying IDs in exponential format*
	tostring hb030, replace
	gen year = hb010
	gen hid = hb030 
	gen country = hb020 
	sort year country hid 
	*checking for duplicates or errors in hid*
	/*duplicates report country year hid */
	*select observations/households by merging with selected rotational groups from the D file *
	merge 1:1 year country hid using "$datapath\2019D.dta"
	keep if _merge==3
	drop _merge
	destring hb100 , replace force
	save "$datapath\2019H.dta", replace

	/* 2018 */
	
	clear
	use  HB010 HB020 HB030 HB050 HB100 HY010 HY020 HX040 HH010 using "$datapath\2018\H_file_2018.dta", clear

	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	

	*Block Stata from displaying IDs in exponential format*
	tostring hb030, replace
	gen year = hb010
	gen hid = hb030 
	gen country = hb020 
	sort year country hid 
	*checking for duplicates or errors in hid*
	/*duplicates report country year hid */
	*select observations/households by merging with selected rotational groups from the D file *
	merge 1:1 year country hid using "$datapath\2018D.dta"
	keep if _merge==3
	drop _merge
	destring hb100 , replace force
	save "$datapath\2018H.dta", replace

	/* 2017 */
	
	clear
	use HB01 HB010 HB020 HB030 HB050 HB100 HY010 HY020 HX040 HH010 using "$datapath\2017\H_file_2017.dta", clear
	
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	

	*Block Stata from displaying IDs in exponential format*
	tostring hb030, replace
	gen year = hb010
	gen hid = hb030 
	gen country = hb020 
	sort year country hid 
	*checking for duplicates or errors in hid*
	/*duplicates report country year hid */
	*select observations/households by merging with selected rotational groups from the D file *
	merge 1:1 year country hid using "$datapath\2017D.dta"
	keep if _merge==3
	drop _merge
	destring hb100 , replace force
	save "$datapath\2017H.dta", replace

	/* 2016 */
	
	clear
	use HB010 HB020 HB030 HB050 HB100 HY010 HY020 HX040 HH010 using "$datapath\2016\H_file_2016.dta", clear

	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	

	*Block Stata from displaying IDs in exponential format*
	tostring hb030, replace
	gen year = hb010
	gen hid = hb030 
	gen country = hb020 
	sort year country hid 
	*checking for duplicates or errors in hid*
	/*duplicates report country year hid */
	*select observations/households by merging with selected rotational groups from the D file *
	merge 1:1 year country hid using "$datapath\2016D.dta"
	keep if _merge==3
	drop _merge
	destring hb100 , replace force
	save "$datapath\2016H.dta", replace


	
	/* 2015 */
	clear
	use  HB010 HB020 HB030 HB050 HB100 HY010 HY020 HX040 HH010 using "$datapath\2015\H_file_2015.dta", clear
	
	

	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	

	*Block Stata from displaying IDs in exponential format*
	tostring hb030, replace
	gen year = hb010
	gen hid = hb030 
	gen country = hb020 
	sort year country hid 
	*checking for duplicates or errors in hid*
	/*duplicates report country year hid*/ 
	*select observations/households by merging with selected rotational groups from the D file *
	merge 1:1 year country hid using "$datapath\2015D.dta"
	keep if _merge==3
	drop _merge
	destring hb100 , replace force
	save "$datapath\2015H.dta", replace

	
	
	/*2014*/
	clear
	use  HB010 HB020 HB030 HB050 HB100 HY010 HY020 HX040 HH010 using "$datapath\2014\H_file_2014.dta", clear
	
	
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	

	/*Block Stata from displaying IDs in exponential format*/
	tostring hb030, replace
	gen year = hb010
	gen hid = hb030 
	tostring hid, replace
	gen country = hb020 
	sort year country hid 
	/*checking for duplicates or errors in hid*/
	/*duplicates report country year hid */
	*select observations/households by merging with selected rotational groups from the D file *
	merge 1:1 year country hid using "$datapath\2014D.dta"
	keep if _merge==3
	drop _merge
	destring hb100 , replace force
	save "$datapath\2014H.dta", replace

		/*2013*/
	clear
	use  HB010 HB020 HB030 HB050 HB100 HY010 HY020 HX040 HH010 using "$datapath\2013\H_file_2013.dta", clear
	
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	
	/*Block Stata from displaying IDs in exponential format*/
	tostring hb030, replace
	gen year = hb010
	gen hid = hb030 
	tostring hid, replace
	gen country = hb020 
	sort year country hid 
	/*checking for duplicates or errors in hid*/
	/*duplicates report country year hid */
	*select observations/households by merging with selected rotational groups from the D file *
	merge 1:1 year country hid using "$datapath\2013D.dta"
	keep if _merge==3
	drop _merge
	destring hb100 , replace force
	save "$datapath\2013H.dta", replace
	
	/*2012*/
	clear
	use  HB010 HB020 HB030 HB050 HB100 HY010 HY020 HX040 HH010 using "$datapath\2012\H_file_2012.dta", clear
	
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	

	/*Block Stata from displaying IDs in exponential format*/
	tostring hb030, replace
	gen year = hb010
	gen hid = hb030 
	tostring hid, replace
	gen country = hb020 
	sort year country hid 
	/*checking for duplicates or errors in hid*/
	/*duplicates report country year hid */
	*select observations/households by merging with selected rotational groups from the D file *
	merge 1:1 year country hid using "$datapath\2012D.dta"
	keep if _merge==3
	drop _merge
	destring hb100 , replace force
	save "$datapath\2012H.dta", replace
	
	/*2011*/
	clear
	use  HB010 HB020 HB030 HB050 HB100 HY010 HY020 HX040 HH010 using "$datapath\2011\H_file_2011.dta", clear
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	
	/*Block Stata from displaying IDs in exponential format*/
	tostring hb030, replace
	gen year = hb010
	gen hid = hb030 
	tostring hid, replace
	gen country = hb020 
	sort year country hid 
	/*checking for duplicates or errors in hid*/
	duplicates report country year hid 
	*select observations/households by merging with selected rotational groups from the D file *
	merge 1:1 year country hid using "$datapath\2011D.dta"
	keep if _merge==3
	drop _merge
	destring hb100 , replace force
	save "$datapath\2011H.dta", replace
	
	/*2010*/
	clear
	use  HB010 HB020 HB030 HB050 HB100 HY010 HY020 HX040 HH010 using "$datapath\2010\H_file_2010.dta", clear

	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	/*Block Stata from displaying IDs in exponential format*/
	tostring hb030, replace
	gen year = hb010
	gen hid = hb030 
	tostring hid, replace
	gen country = hb020 
	sort year country hid 
	/*checking for duplicates or errors in hid*/
	duplicates report country year hid 
	*select observations/households by merging with selected rotational groups from the D file *
	merge 1:1 year country hid using "$datapath\2010D.dta"
	keep if _merge==3
	drop _merge
	destring hb100 , replace force
	save "$datapath\2010H.dta", replace
	
	/*2009*/
	
	clear
	use  HB010 HB020 HB030 HB050 HB100 HY010 HY020 HX040 HH010 using "$datapath\2009\H_file_2009.dta", clear

	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	
	/*Block Stata from displaying IDs in exponential format*/
	tostring hb030, replace
	gen year = hb010
	gen hid = hb030 
	tostring hid, replace
	gen country = hb020 
	sort year country hid 
	/*checking for duplicates or errors in hid*/
	duplicates report country year hid 
	*select observations/households by merging with selected rotational groups from the D file *
	merge 1:1 year country hid using "$datapath\2009D.dta"
	keep if _merge==3
	drop _merge
	destring hb100 , replace force
	save "$datapath\2009H.dta", replace
	
	/*2008*/
	clear
	use  HB010 HB020 HB030 HB050 HB100 HY010 HY020 HX040 HH010 using "$datapath\2008\H_file_2008.dta", clear

	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	
	/*Block Stata from displaying IDs in exponential format*/
	tostring hb030, replace
	gen year = hb010
	gen hid = hb030 
	tostring hid, replace
	gen country = hb020 
	sort year country hid 
	/*checking for duplicates or errors in hid*/
	duplicates report country year hid 
	*select observations/households by merging with selected rotational groups from the D file *
	merge 1:1 year country hid using "$datapath\2008D.dta"
	keep if _merge==3
	drop _merge
	destring hb100 , replace force
	save "$datapath\2008H.dta", replace
	
	
	/*2007*/
	clear
	use  HB010 HB020 HB030 HB050 HB100 HY010 HY020 HX040 HH010 using "$datapath\2007\H_file_2007.dta", clear

	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	
	/*Block Stata from displaying IDs in exponential format*/
	tostring hb030, replace
	gen year = hb010
	gen hid = hb030 
	tostring hid, replace
	gen country = hb020 
	sort year country hid 
	/*checking for duplicates or errors in hid*/
	duplicates report country year hid 
	*select observations/households by merging with selected rotational groups from the D file *
	merge 1:1 year country hid using "$datapath\2007D.dta"
	keep if _merge==3
	drop _merge
	destring hb100 , replace force
	save "$datapath\2007H.dta", replace
	
	/*2006*/
	clear
	use  HB010 HB020 HB030 HB050 HB100 HY010 HY020 HX040 HH010 using "$datapath\2006\H_file_2006.dta", clear

	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	

	/*Block Stata from displaying IDs in exponential format*/
	tostring hb030, replace
	gen year = hb010
	gen hid = hb030 
	tostring hid, replace
	gen country = hb020 
	sort year country hid 
	/*checking for duplicates or errors in hid*/
	duplicates report country year hid 
	*select observations/households by merging with selected rotational groups from the D file *
	merge 1:1 year country hid using "$datapath\2006D.dta"
	keep if _merge==3
	drop _merge
	destring hb100 , replace force
	save "$datapath\2006H.dta", replace
	
	/*2005*/
	clear
	use  HB010 HB020 HB030 HB050 HB100 HY010 HY020 HX040 HH010 using "$datapath\2005\H_file_2005.dta", clear

	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	
	/*Block Stata from displaying IDs in exponential format*/
	tostring hb030, replace
	gen year = hb010
	gen hid = hb030 
	tostring hid, replace
	gen country = hb020 
	sort year country hid 
	/*checking for duplicates or errors in hid*/
	duplicates report country year hid 
	*select observations/households by merging with selected rotational groups from the D file *
	merge 1:1 year country hid using "$datapath\2005D.dta"
	keep if _merge==3
	drop _merge
	destring hb100 , replace force
	save "$datapath\2005H.dta", replace

	/*merge masterH with the 20XXH files from previous releases.*/
	clear
	use "$datapath\masterH.dta", clear
	merge 1:1 year uhid using "$datapath\2019H.dta"
	drop _merge	
	merge 1:1 year uhid using "$datapath\2018H.dta"
	drop _merge
	merge 1:1 year uhid using "$datapath\2017H.dta"
	drop _merge
	merge 1:1 year uhid using "$datapath\2016H.dta"
	drop _merge
	merge 1:1 year uhid using "$datapath\2015H.dta"
	drop _merge
	merge 1:1 year uhid using "$datapath\2014H.dta"
	drop _merge
	merge 1:1 year uhid using "$datapath\2013H.dta"
	drop _merge
	merge 1:1 year uhid using "$datapath\2012H.dta"
	drop _merge
	merge 1:1 year uhid using "$datapath\2011H.dta"
	drop _merge
	merge 1:1 year uhid using "$datapath\2010H.dta"
	drop _merge
	merge 1:1 year uhid using "$datapath\2009H.dta"
	drop _merge
	merge 1:1 year uhid using "$datapath\2008H.dta"
	drop _merge
	merge 1:1 year uhid using "$datapath\2007H.dta"
	drop _merge
	merge 1:1 year uhid using "$datapath\2006H.dta"
	drop _merge
	merge 1:1 year uhid using "$datapath\2005H.dta"
	drop _merge
	
	/*drop superflous variables*/
	drop db010 db020 db030 db040 db075 db100 db110 ///
	nrtgrp* slctd_rtgrp drpout_year drpout_year* slctd_uhid* slctd_urtgrp* ///
	maxgrp lgstgrp merge* 

	save "$datapath\masterH.dta", replace

	
	/***/
	/*build masterfile for personal register files (R files)*/
	/***/
	
		/* 2020 */	
	
	clear
	use RB010 RB020 RB030 RB040 RB060 RB062 RB063 RB064 RB070 RB080 RB090 RB110 RB120 RB220 RB230 RB240 RB245 RL040 RL050 RL060  using "$datapath\2020\R_file_2020.dta", clear

	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }

	tostring rb030, replace format("%15.0f")
	tostring rb040, replace 
	gen year = rb010
	gen hid = rb040
	gen pid = rb030 
	gen country = rb020
	sort year country hid 
	/*checking for duplicates or errors in id*/
	/*duplicates report country year hid pid*/ 
	/*duplicates report country year pid*/
	/*merge with IDs from house hold register (D file) and drop households that are only in the D file, but not in the R file */
	merge m:1 year country hid using "$datapath\2020D.dta"
	keep if _merge == 3 
	drop _merge 
	/*generate personal IDs that are unique across all releases by taking the last 2 digits of pid (personal number) and merging it to uhid*/
	/*keep in mind that there are some individuals present in more than one familiy, so there are duplicates in pid alone but not in uhid and upid */
	gen suhid = substr(uhid,1,7)
	gen upid = suhid + pid 
	drop suhid
	/*this is the masterfileR where to add data from previous releases to */
	save "$datapath\2020R.dta", replace

	
	/* 2019 */	
	
	clear
	use RB010 RB020 RB030 RB040 RB060 RB062 RB063 RB064 RB070 RB080 RB090 RB110 RB120 RB220 RB230 RB240 RB245 using "$datapath\2019\R_file_2019.dta", clear
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }

	tostring rb030, replace format("%15.0f")
	tostring rb040, replace 
	gen year = rb010
	gen hid = rb040
	gen pid = rb030 
	gen country = rb020 
	sort year country hid 
	/*checking for duplicates or errors in id*/
	/*duplicates report country year hid pid 
	duplicates report country year pid*/
	/*merge with IDs from house hold register (D file) and drop households that are only in the D file, but not in the R file */
	merge m:1 year country hid using "$datapath\2019D.dta"
	keep if _merge == 3 
	drop _merge 
	/*genereate personal IDs that are unique across all releases by taking the last 2 digits of pid (personal number) and merging it to uhid*/
	/*keep in mind that there are some individuals present in more than one familiy, so there are duplicates in pid alone but not in uhid and upid */
	gen suhid = substr(uhid,1,7)
	gen upid = suhid + pid 
	drop suhid
	/*this is the masterfileR where to add data from previous releases to */
	save "$datapath\2019R.dta", replace

	
	/* 2018 */	
	
	clear
	use RB010 RB020 RB030 RB040 RB060 RB062 RB063 RB064 RB070 RB080 RB090 RB110 RB120 RB220 RB230 RB240 RB245 using "$datapath\2018\R_file_2018.dta", clear
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }

	tostring rb030, replace format("%15.0f")
	tostring rb040, replace 
	gen year = rb010
	gen hid = rb040
	gen pid = rb030 
	gen country = rb020
	sort year country hid 
	/*checking for duplicates or errors in id*/
	/*duplicates report country year hid pid 
	duplicates report country year pid*/
	/*merge with IDs from house hold register (D file) and drop households that are only in the D file, but not in the R file */
	merge m:1 year country hid using "$datapath\2018D.dta"
	keep if _merge == 3 
	drop _merge 
	/*genereate personal IDs that are unique across all releases by taking the last 2 digits of pid (personal number) and merging it to uhid*/
	/*keep in mind that there are some individuals present in more than one familiy, so there are duplicates in pid alone but not in uhid and upid */
	gen suhid = substr(uhid,1,7)
	gen upid = suhid + pid 
	drop suhid
	/*this is the masterfileR where to add data from previous releases to */
	save "$datapath\2018R.dta", replace

	
	/* 2017 */	
	
	clear
	use RB010 RB020 RB030 RB040 RB060 RB062 RB063 RB064 RB070 RB080 RB090 RB110 RB120 RB220 RB230 RB240 RB245 using "$datapath\2017\R_file_2017.dta", clear
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }

	tostring rb030, replace format("%15.0f")
	tostring rb040, replace 
	gen year = rb010
	gen hid = rb040
	gen pid = rb030 
	gen country = rb020
	sort year country hid 
	/*checking for duplicates or errors in id*/
	/*duplicates report country year hid pid 
	duplicates report country year pid*/
	/*merge with IDs from house hold register (D file) and drop households that are only in the D file, but not in the R file */
	merge m:1 year country hid using "$datapath\2017D.dta"
	keep if _merge == 3 
	drop _merge 
	/*genereate personal IDs that are unique across all releases by taking the last 2 digits of pid (personal number) and merging it to uhid*/
	/*keep in mind that there are some individuals present in more than one familiy, so there are duplicates in pid alone but not in uhid and upid */
	gen suhid = substr(uhid,1,7)
	gen upid = suhid + pid 
	drop suhid
	/*this is the masterfileR where to add data from previous releases to */
	save "$datapath\2017R.dta", replace

	
	/* 2016 */	
	
	clear
	use RB010 RB020 RB030 RB040 RB060 RB062 RB063 RB064 RB070 RB080 RB090 RB110 RB120 RB220 RB230 RB240 RB245 using "$datapath\2016\R_file_2016.dta", clear
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }

	tostring rb030, replace format("%15.0f") 
	tostring rb040, replace 
	gen year = rb010
	gen hid = rb040
	gen pid = rb030 
	gen country = rb020
	sort year country hid 
	/*checking for duplicates or errors in id*/
	/*duplicates report country year hid pid 
	duplicates report country year pid*/
	/*merge with IDs from house hold register (D file) and drop households that are only in the D file, but not in the R file */
	merge m:1 year country hid using "$datapath\2016D.dta"
	keep if _merge == 3 
	drop _merge 
	/*genereate personal IDs that are unique across all releases by taking the last 2 digits of pid (personal number) and merging it to uhid*/
	/*keep in mind that there are some individuals present in more than one familiy, so there are duplicates in pid alone but not in uhid and upid */
	gen suhid = substr(uhid,1,7)
	gen upid = suhid + pid 
	drop suhid
	/*this is the masterfileR where to add data from previous releases to */
	save "$datapath\2016R.dta", replace


	/* 2015 */	
	
	clear
	use RB010 RB020 RB030 RB040 RB060 RB062 RB063 RB064 RB070 RB080 RB090 RB110 RB120 RB220 RB230 RB240 RB245 using "$datapath\2015\R_file_2015.dta", clear
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }

	tostring rb030, replace format("%15.0f") 
	tostring rb040, replace 
	gen year = rb010
	gen hid = rb040
	gen pid = rb030 
	gen country = rb020
	sort year country hid 
	/*checking for duplicates or errors in id*/
	/*duplicates report country year hid pid 
	duplicates report country year pid*/
	/*merge with IDs from house hold register (D file) and drop households that are only in the D file, but not in the R file */
	merge m:1 year country hid using "$datapath\2015D.dta"
	keep if _merge == 3 
	drop _merge 
	/*genereate personal IDs that are unique across all releases by taking the last 2 digits of pid (personal number) and merging it to uhid*/
	/*keep in mind that there are some individuals present in more than one familiy, so there are duplicates in pid alone but not in uhid and upid */
	gen suhid = substr(uhid,1,7)
	gen upid = suhid + pid 
	drop suhid
	/*this is the masterfileR where to add data from previous releases to */
	save "$datapath\2015R.dta", replace

	/*merge indivdual registers with 20XXslcd files to select the individuals contained in the rotational groups from previous releases we are interested in */
	/*merging 2014 data*/
	/*2-14*/
	clear
	use RB010 RB020 RB030 RB040 RB060 RB062 RB063 RB064 RB070 RB080 RB090 RB110 RB120 RB220 RB230 RB240 RB245 using "$datapath\2014\R_file_2014.dta", clear
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }

	tostring rb030, replace format("%15.0f") 
	tostring rb040, replace 
	gen year = rb010
	gen hid = rb040
	gen pid = rb030 
	gen country = rb020
	sort year country hid 
	/*checking for duplicates or errors in id*/
	/*duplicates report country year hid pid
 	duplicates report country year pid*/
	/*merge with IDs from house hold register (D file) and drop households that are only in the D file, but not in the R file */
	merge m:1 year country hid using "$datapath\2014D.dta"
	keep if _merge == 3 
	drop _merge 
	/*genereate personal IDs that are unique across all releases by taking the first 7 numbers of uhid and adding them to pid*/
	/*keep in mind that there are some individuals present in more than one familiy, so there are duplicates in upid alone but not in uhid and upid */
	gen suhid = substr(uhid, 1, 7)
	gen upid = suhid + pid 
	drop suhid
	/*this is the masterfileR where to add data from previous releases to */
	save "$datapath\2014R.dta", replace
	
	/*merging 2013 data*/
	clear
	use RB010 RB020 RB030 RB040 RB060 RB062 RB063 RB064 RB070 RB080 RB090 RB110 RB120 RB220 RB230 RB240 RB245 using "$datapath\2013\R_file_2013.dta", clear
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	

	tostring rb030, replace format("%15.0f") 
	tostring rb040, replace 
	gen year = rb010
	gen hid = rb040
	gen pid = rb030 
	gen country = rb020
	sort year country hid 
	/*checking for duplicates or errors in id*/
	/*duplicates report country year hid pid
 	duplicates report country year pid*/
	/*merge with IDs from house hold register (D file) and drop households that are only in the D file, but not in the R file */
	merge m:1 year country hid using "$datapath\2013D.dta"
	keep if _merge == 3 
	drop _merge 
	/*genereate personal IDs that are unique across all releases by taking the first 7 numbers of uhid and adding them to pid*/
	/*keep in mind that there are some individuals present in more than one familiy, so there are duplicates in upid alone but not in uhid and upid */
	gen suhid = substr(uhid, 1, 7)
	gen upid = suhid + pid 
	drop suhid
	/*this is the masterfileR where to add data from previous releases to */
	save "$datapath\2013R.dta", replace
	
	/*merging 2012 data*/
	clear
	use RB010 RB020 RB030 RB040 RB060 RB062 RB063 RB064 RB070 RB080 RB090 RB110 RB120 RB220 RB230 RB240 RB245 using "$datapath\2012\R_file_2012.dta", clear
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	
	tostring rb030, replace format("%15.0f") 
	tostring rb040, replace 
	gen year = rb010
	gen hid = rb040
	gen pid = rb030 
	gen country = rb020
	sort year country hid 
	/*checking for duplicates or errors in id*/
	/*duplicates report country year hid pid
 	duplicates report country year pid*/
	/*merge with IDs from house hold register (D file) and drop households that are only in the D file, but not in the R file */
	merge m:1 year country hid using "$datapath\2012D.dta"
	keep if _merge == 3 
	drop _merge 
	/*genereate personal IDs that are unique across all releases by taking the first 7 numbers of uhid and adding them to pid*/
	/*keep in mind that there are some individuals present in more than one familiy, so there are duplicates in upid alone but not in uhid and upid */
	gen suhid = substr(uhid, 1, 7)
	gen upid = suhid + pid 
	drop suhid
	/*this is the masterfileR where to add data from previous releases to */
	save "$datapath\2012R.dta", replace
	
	/*merging 2011 data*/
	clear
	use RB010 RB020 RB030 RB040 RB060 RB062 RB063 RB064 RB070 RB080 RB090 RB110 RB120 RB220 RB230 RB240 RB245 using "$datapath\2011\R_file_2011.dta", clear
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	
	tostring rb030, replace format("%15.0f")
	tostring rb040, replace 
	gen year = rb010
	gen hid = rb040
	gen pid = rb030 
	gen country = rb020
	sort year country hid 
	/*checking for duplicates or errors in id*/
	/*duplicates report country year hid pid
 	duplicates report country year pid*/
	/*merge with IDs from house hold register (D file) and drop households that are only in the D file, but not in the R file */
	merge m:1 year country hid using "$datapath\2011D.dta"
	keep if _merge == 3 
	drop _merge 
	/*genereate personal IDs that are unique across all releases by taking the first 7 numbers of uhid and adding them to pid*/
	/*keep in mind that there are some individuals present in more than one familiy, so there are duplicates in upid alone but not in uhid and upid */
	gen suhid = substr(uhid, 1, 7)
	gen upid = suhid + pid 
	drop suhid
	/*this is the masterfileR where to add data from previous releases to */
	save "$datapath\2011R.dta", replace
	
	/*merging 2010 data*/
	clear
	use RB010 RB020 RB030 RB040 RB060 RB062 RB063 RB064 RB070 RB080 RB090 RB110 RB120 RB220 RB230 RB240 RB245 using "$datapath\2010\R_file_2010.dta", clear
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	
	tostring rb030, replace format("%15.0f")
	tostring rb040, replace 
	gen year = rb010
	gen hid = rb040
	gen pid = rb030 
	gen country = rb020
	sort year country hid 
	/*checking for duplicates or errors in id*/
	/*duplicates report country year hid pid
 	duplicates report country year pid*/
	/*merge with IDs from house hold register (D file) and drop households that are only in the D file, but not in the R file */
	merge m:1 year country hid using "$datapath\2010D.dta"
	keep if _merge == 3 
	drop _merge 
	/*genereate personal IDs that are unique across all releases by taking the first 7 numbers of uhid and adding them to pid*/
	/*keep in mind that there are some individuals present in more than one familiy, so there are duplicates in upid alone but not in uhid and upid */
	gen suhid = substr(uhid, 1, 7)
	gen upid = suhid + pid 
	drop suhid
	/*this is the masterfileR where to add data from previous releases to */
	save "$datapath\2010R.dta", replace
	
	/*merging 2009 data*/
	clear
	use RB010 RB020 RB030 RB040 RB060 RB062 RB063 RB064 RB070 RB080 RB090 RB110 RB120 RB220 RB230 RB240 RB245 using "$datapath\2009\R_file_2009.dta", clear
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	
	tostring rb030, replace format("%15.0f")
	tostring rb040, replace 
	gen year = rb010
	gen hid = rb040
	gen pid = rb030 
	gen country = rb020
	sort year country hid 
	/*checking for duplicates or errors in id*/
	/*duplicates report country year hid pid
 	duplicates report country year pid*/
	/*merge with IDs from house hold register (D file) and drop households that are only in the D file, but not in the R file */
	merge m:1 year country hid using "$datapath\2009D.dta"
	keep if _merge == 3 
	drop _merge 
	/*genereate personal IDs that are unique across all releases by taking the first 7 numbers of uhid and adding them to pid*/
	/*keep in mind that there are some individuals present in more than one familiy, so there are duplicates in upid alone but not in uhid and upid */
	gen suhid = substr(uhid, 1, 7)
	gen upid = suhid + pid 
	drop suhid
	/*this is the masterfileR where to add data from previous releases to */
	save "$datapath\2009R.dta", replace
		
	
	
	
	/*merging 2008 data*/
	clear
	use RB010 RB020 RB030 RB040 RB060 RB062 RB063 RB064 RB070 RB080 RB090 RB110 RB120 RB220 RB230 RB240 RB245 using "$datapath\2008\R_file_2008.dta", clear
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	
	tostring rb030, replace format("%15.0f")
	tostring rb040, replace 
	gen year = rb010
	gen hid = rb040
	gen pid = rb030 
	gen country = rb020
	sort year country hid 
	/*checking for duplicates or errors in id*/
	/*duplicates report country year hid pid
 	duplicates report country year pid*/
	/*merge with IDs from house hold register (D file) and drop households that are only in the D file, but not in the R file */
	merge m:1 year country hid using "$datapath\2008D.dta"
	keep if _merge == 3 
	drop _merge 
	/*genereate personal IDs that are unique across all releases by taking the first 7 numbers of uhid and adding them to pid*/
	/*keep in mind that there are some individuals present in more than one familiy, so there are duplicates in upid alone but not in uhid and upid */
	gen suhid = substr(uhid, 1, 7)
	gen upid = suhid + pid 
	drop suhid
	/*this is the masterfileR where to add data from previous releases to */
	save "$datapath\2008R.dta", replace
	
	
	
	/*merging 2007 data*/
	clear
	use RB010 RB020 RB030 RB040 RB060 RB062 RB063 RB070 RB080 RB090 RB110 RB120 RB220 RB230 RB240 RB245 using "$datapath\2007\R_file_2007.dta", clear
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	
	tostring rb030, replace format("%15.0f")
	tostring rb040, replace 
	gen year = rb010
	gen hid = rb040
	gen pid = rb030 
	gen country = rb020
	sort year country hid 
	/*checking for duplicates or errors in id*/
	/*duplicates report country year hid pid
 	duplicates report country year pid*/
	/*merge with IDs from house hold register (D file) and drop households that are only in the D file, but not in the R file */
	merge m:1 year country hid using "$datapath\2007D.dta"
	keep if _merge == 3 
	drop _merge 
	/*genereate personal IDs that are unique across all releases by taking the first 7 numbers of uhid and adding them to pid*/
	/*keep in mind that there are some individuals present in more than one familiy, so there are duplicates in upid alone but not in uhid and upid */
	gen suhid = substr(uhid, 1, 7)
	gen upid = suhid + pid 
	drop suhid
	/*this is the masterfileR where to add data from previous releases to */
	save "$datapath\2007R.dta", replace
		
	/*merging 2006 data*/
	clear
	use RB010 RB020 RB030 RB040 RB060 RB062 RB063 RB070 RB080 RB090 RB110 RB120 RB220 RB230 RB240 RB245 using "$datapath\2006\R_file_2006.dta", clear
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	
	tostring rb030, replace format("%15.0f")
	tostring rb040, replace 
	gen year = rb010
	gen hid = rb040
	gen pid = rb030 
	gen country = rb020
	sort year country hid 
	/*checking for duplicates or errors in id*/
	/*duplicates report country year hid pid
 	duplicates report country year pid*/
	/*merge with IDs from house hold register (D file) and drop households that are only in the D file, but not in the R file */
	merge m:1 year country hid using "$datapath\2006D.dta"
	keep if _merge == 3 
	drop _merge 
	/*genereate personal IDs that are unique across all releases by taking the first 7 numbers of uhid and adding them to pid*/
	/*keep in mind that there are some individuals present in more than one familiy, so there are duplicates in upid alone but not in uhid and upid */
	gen suhid = substr(uhid, 1, 7)
	gen upid = suhid + pid 
	drop suhid
	/*this is the masterfileR where to add data from previous releases to */
	save "$datapath\2006R.dta", replace
			
			
			
	/*merging 2005 data*/
	clear
	use  RB010 RB020 RB030 RB040 RB060 RB070 RB080 RB090 RB110 RB120 RB220 RB230 RB240 RB245 using "$datapath\2005\R_file_2005.dta", clear
	
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	
	tostring rb030, replace format("%15.0f")
	tostring rb040, replace 
	gen year = rb010
	gen hid = rb040
	gen pid = rb030 
	gen country = rb020
	sort year country hid 
	/*checking for duplicates or errors in id*/
	/*duplicates report country year hid pid 	
	duplicates report country year pid*/
	/*merge with IDs from house hold register (D file) and drop households that are only in the D file, but not in the R file */
	merge m:1 year country hid using "$datapath\2005D.dta"
	keep if _merge == 3 
	drop _merge 
	/*genereate personal IDs that are unique across all releases by taking the first 7 numbers of uhid and adding them to pid*/
	/*keep in mind that there are some individuals present in more than one familiy, so there are duplicates in upid alone but not in uhid and upid */
	gen suhid = substr(uhid, 1, 7)
	gen upid = suhid + pid 
	drop suhid
	/*this is the masterfileR where to add data from previous releases to */
	save "$datapath\2005R.dta", replace
	
	/*merge data from all releases into one masterfile. 
	!! this process is memory intensive. */
	clear
	use "$datapath\2020R.dta", clear

	merge 1:1 year upid uhid using "$datapath\2019R.dta"
	drop _merge
	merge 1:1 year upid uhid using "$datapath\2018R.dta"
	drop _merge
	save "$datapath\masterR.dta", replace
	
	clear
	use "$datapath\masterR.dta", clear
	merge 1:1 year upid uhid using "$datapath\2017R.dta"
	drop _merge
	merge 1:1 year upid uhid using "$datapath\2016R.dta"
	drop _merge
	merge 1:1 year upid uhid using "$datapath\2015R.dta"
	drop _merge
	save "$datapath\masterR.dta", replace
	
	
	clear
	use "$datapath\masterR.dta", clear
	
	merge 1:1 year upid uhid using "$datapath\2014R.dta"
	drop _merge
	merge 1:1 year upid uhid using "$datapath\2013R.dta"
	drop _merge
	merge 1:1 year upid uhid using "$datapath\2012R.dta"
	drop _merge
	save "$datapath\masterR.dta", replace
	
	
	
	clear
	use "$datapath\masterR.dta", clear
	
	merge 1:1 year upid uhid using "$datapath\2011R.dta"
	drop _merge
	merge 1:1 year upid uhid using "$datapath\2010R.dta"
	drop _merge
	merge 1:1 year upid uhid using "$datapath\2009R.dta"
	drop _merge
	save "$datapath\masterR.dta", replace
	
	
	
	clear
	use "$datapath\masterR.dta", clear
	
	merge 1:1 year upid uhid using "$datapath\2008R.dta"
	drop _merge
	merge 1:1 year upid uhid using "$datapath\2007R.dta"
	drop _merge
	save "$datapath\masterR.dta", replace
	
	
	
	clear
	use "$datapath\masterR.dta", clear
	
	merge 1:1 year upid uhid using "$datapath\2006R.dta"
	drop _merge
	save "$datapath\masterR.dta", replace
	clear
	use "$datapath\masterR.dta", clear
	
	merge 1:1 year upid uhid using "$datapath\2005R.dta"
	drop _merge

	/* drop superflous variables*/
	drop db010 db020 db030 db040 db075 db100 db110 ///
	nrtgrp* slctd_rtgrp drpout_year drpout_year* slctd_urtgrp* slctd_uhid*  maxgrp lgstgrp drpout_year* ///
    nrtgrp2013  merge*  
	
	/*adding upidnum*/
	egen upidnum = group(upid)
	save "$datapath\masterR.dta", replace
		
	/***/	
	/*build masterfile for personal data files (P files)*/
	/***/
	
		/* 2020 */
	clear
	use PB010 PB020 PB080 PX030 PB030 PB130 PB140 PB110 PB150 PB160 PB170 PB180 PB190 PB200 PE040 PH010 PH020 PH030 PL020 PL025 PL040 PL060 PL140 PL160 PL170 PL200 PY010N PY020N PY050N PY090N PY100N PY110N PY120N PY130N PY140N PX020 /*the name of the following variables changes in different years*/ PL031  PL051 PL211A PL211B PL211C PL211D PL211E PL211F PL211G PL211H PL211I PL211J PL211K PL211L using "$datapath\2020\P_file_2020.dta", clear
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	
	tostring pb030, replace format("%15.0f")
	gen year = pb010
	gen pid = pb030   
	gen country = pb020
	sort year country pid 
	/*checking for duplicates/errors in pid (should be unique)*/
	/*duplicates report year country pid*/
	/*merge with R files to keep only obs from selcted rotational groups*/
	merge 1:m year country pid using "$datapath\2020R.dta"
	keep if _merge == 3 
	drop _merge
	/* R file contains combinations in pid and hid, so pids are not unique. In P pids are unique, so we can drop the duplicates */
	duplicates drop year country pid, force
	/*this is the masterfileR where to add data from previous releases to */
	save "$datapath\2020P", replace

	
		/* 2019 */
	clear
	use PB010 PB020 PB080  PX030 PB030 PB130 PB140 PB110 PB150 PB160 PB170 PB180 PB190 PB200 PE040 PH010 PH020 PH030 PL020 PL025 PL040 PL060 PL140 PL160 PL170 PL200 PY010N PY020N PY050N PY090N PY100N PY110N PY120N PY130N PY140N PX020 /*the name of the following variables changes in different years*/ PL031  PL051 PL211A PL211B PL211C PL211D PL211E PL211F PL211G PL211H PL211I PL211J PL211K PL211L using "$datapath\2019\P_file_2019.dta", clear
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	
	tostring pb030, replace format("%15.0f")
	gen year = pb010
	gen pid = pb030   
	gen country = pb020
	sort year country pid 
	/*checking for duplicates/errors in pid (should be unique)*/
	duplicates report year country pid
	/*merge with R files to keep only obs from selcted rotational groups*/
	merge 1:m year country pid using "$datapath\2019R.dta"
	keep if _merge == 3 
	drop _merge
	/* R file contains combinations in pid and hid, so pids are not unique. In P pids are unique, so we can drop the duplicates */
	duplicates drop year country pid, force
	/*this is the masterfileR where to add data from previous releases to */
	save "$datapath\2019P", replace

	
	/* 2018 */
	clear
	use PB010 PB020 PB080  PX030 PB030 PB130 PB140 PB110 PB150 PB160 PB170 PB180 PB190 PB200 PE040 PH010 PH020 PH030 PL020 PL025 PL040 PL060 PL140 PL160 PL170 PL200 PY010N PY020N PY050N PY090N PY100N PY110N PY120N PY130N PY140N PX020 /*the name of the following variables changes in different years*/ PL031  PL051 PL211A PL211B PL211C PL211D PL211E PL211F PL211G PL211H PL211I PL211J PL211K PL211L using "$datapath\2018\P_file_2018.dta", clear
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	
	tostring pb030, replace format("%15.0f")
	gen year = pb010
	gen pid = pb030   
	gen country = pb020
	sort year country pid 
	/*checking for duplicates/errors in pid (should be unique)*/
	/*duplicates report year country pid*/
	/*merge with R files to keep only obs from selcted rotational groups*/
	merge 1:m year country pid using "$datapath\2018R.dta"
	keep if _merge == 3 
	drop _merge
	/* R file contains combinations in pid and hid, so pids are not unique. In P pids are unique, so we can drop the duplicates */
	duplicates drop year country pid, force
	/*this is the masterfileR where to add data from previous releases to */
	save "$datapath\2018P", replace

	
		/* 2017 */
	clear
	use PB010 PB020 PB080 PX030 PB030 PB130 PB140 PB110 PB150 PB160 PB170 PB180 PB190 PB200 PE040 PH010 PH020 PH030 PL020 PL025 PL040 PL060 PL140 PL160 PL170 PL200 PY010N PY020N PY050N PY090N PY100N PY110N PY120N PY130N PY140N PX020 /*the name of the following variables changes in different years*/ PL031  PL051 PL211A PL211B PL211C PL211D PL211E PL211F PL211G PL211H PL211I PL211J PL211K PL211L using "$datapath\2017\P_file_2017.dta", clear
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	
	tostring pb030, replace format("%15.0f")
	gen year = pb010
	gen pid = pb030   
	gen country = pb020
	sort year country pid 
	/*checking for duplicates/errors in pid (should be unique)*/
	/*duplicates report year country pid*/
	/*merge with R files to keep only obs from selcted rotational groups*/
	merge 1:m year country pid using "$datapath\2017R.dta"
	keep if _merge == 3 
	drop _merge
	/* R file contains combinations in pid and hid, so pids are not unique. In P pids are unique, so we can drop the duplicates */
	duplicates drop year country pid, force
	/*this is the masterfileR where to add data from previous releases to */
	save "$datapath\2017P", replace

	

	/* 2016 */
	clear
	use PB010 PB020 PB080  PX030 PB030 PB130 PB140 PB110 PB150 PB160 PB170 PB180 PB190 PB200 PE040 PH010 PH020 PH030 PL020 PL025 PL040 PL060 PL140 PL160 PL170 PL200 PY010N PY020N PY050N PY090N PY100N PY110N PY120N PY130N PY140N PX020 /*the name of the following variables changes in different years*/ PL031  PL051 PL211A PL211B PL211C PL211D PL211E PL211F PL211G PL211H PL211I PL211J PL211K PL211L using "$datapath\2016\P_file_2016.dta", clear
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	
	tostring pb030, replace format("%15.0f")
	gen year = pb010
	gen pid = pb030   
	gen country = pb020
	sort year country pid 
	/*checking for duplicates/errors in pid (should be unique)*/
	duplicates report year country pid
	/*merge with R files to keep only obs from selcted rotational groups*/
	merge 1:m year country pid using "$datapath\2016R.dta"
	keep if _merge == 3 
	drop _merge
	/* R file contains combinations in pid and hid, so pids are not unique. In P pids are unique, so we can drop the duplicates */
	duplicates drop year country pid, force
	/*this is the masterfileR where to add data from previous releases to */
	save "$datapath\2016P", replace

	
	/* 2015 */
	clear
	use PB010 PB020 PB080  PX030 PB030 PB130 PB140 PB110 PB150 PB160 PB170 PB180 PB190 PB200 PE040 PH010 PH020 PH030 PL020 PL025 PL040 PL060 PL140 PL160 PL170 PL200 PY010N PY020N PY050N PY090N PY100N PY110N PY120N PY130N PY140N PX020 /*the name of the following variables changes in different years*/ PL031  PL051 PL211A PL211B PL211C PL211D PL211E PL211F PL211G PL211H PL211I PL211J PL211K PL211L using "$datapath\2015\P_file_2015.dta", clear
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	
	tostring pb030, replace format("%15.0f")
	gen year = pb010
	gen pid = pb030   
	gen country = pb020
	sort year country pid 
	/*checking for duplicates/errors in pid (should be unique)*/
	/*duplicates report year country pid*/
	/*merge with R files to keep only obs from selcted rotational groups*/
	merge 1:m year country pid using "$datapath\2015R.dta"
	keep if _merge == 3 
	drop _merge
	/* R file contains combinations in pid and hid, so pids are not unique. In P pids are unique, so we can drop the duplicates */
	duplicates drop year country pid, force
	/*this is the masterfileR where to add data from previous releases to */
	save "$datapath\2015P", replace

	
	
	
	
	/*selecting 2014 release data*/
	clear
	use PB010 PB020 PB080 PX030 PB030 PB130 PB140 PB110 PB150 PB160 PB170 PB180 PB190 PB200 PE040 PH010 PH020 PH030 PL020 PL025 PL040 PL060 PL140 PL160 PL170 PL200 PY010N PY020N PY050N PY090N PY100N PY110N PY120N PY130N PY140N PX020 /*the name of the following variables changes in different years*/ PL031  PL051 PL211A PL211B PL211C PL211D PL211E PL211F PL211G PL211H PL211I PL211J PL211K PL211L using "$datapath\2014\P_file_2014.dta", clear
	
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	
	tostring pb030, replace format("%15.0f")
	gen year = pb010
	gen pid = pb030   
	gen country = pb020
	sort year country pid 
	/*checking for duplicates/errors in hid*/
	duplicates report year country pid
	/*merge with IDs from house hold register (R file), keep matches */
	merge 1:m year country pid using "$datapath\2014R.dta"
	keep if _merge == 3 
	drop _merge 
	/* R file contains combinations in pid and hid, so pids are not unique. In P pids are unique, so we can drop the duplicates */
	duplicates drop year country pid, force
	save "$datapath\2014P.dta", replace

	/*selecting 2013 release data*/
	clear
	use PB010 PB020  PB080 PX030 PB030 PB130 PB140 PB110 PB150 PB160 PB170 PB180 PB190 PB200 PE040 PH010 PH020 PH030 PL020 PL025 PL040 PL060 PL140 PL160 PL170 PL200 PY010N PY020N PY050N PY090N PY100N PY110N PY120N PY130N PY140N PX020 /*the name of the following variables changes in different years*/ PL031 PL050 PL051 PL211A PL211B PL211C PL211D PL211E PL211F PL211G PL211H PL211I PL211J PL211K PL211L using "$datapath\2013\P_file_2013.dta", clear
	
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	
	tostring pb030, replace format("%15.0f")
	gen year = pb010
	gen pid = pb030   
	gen country = pb020
	sort year country pid 
	/*checking for duplicates/errors in pid*/
	duplicates report year country pid
	/*merge with IDs from household register (R file), keep the matches */
	merge 1:m year country pid using "$datapath\2013R.dta"
	keep if _merge == 3 
	drop _merge 
	/* R file contains combinations in pid and hid, so pids are not unique. In P pids are unique, so drop duplicates from R*/
	duplicates drop year country pid, force
	save "$datapath\2013P.dta", replace

	/*selecting 2012 release data*/
	clear
	use  PB010 PB020 PB080 PX030 PB030 PB130 PB140 PB110 PB150 PB160 PB170 PB180 PB190 PB200 PE040 PH010 PH020 PH030 PL020 PL025 PL040 PL060 PL140 PL160 PL170 PL200 PY010N PY020N PY050N PY090N PY100N PY110N PY120N PY130N PY140N PX020 /*the name of the following variables changes in different years*/ PL030 PL031 PL050 PL051 PL210A PL210B PL210C PL210D PL210E PL210F PL210G PL210H PL210I PL210J PL210K PL210L PL211A PL211B PL211C PL211D PL211E PL211F PL211G PL211H PL211I PL211J PL211K PL211L using "$datapath\2012\P_file_2012.dta", clear

	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	
	tostring pb030, replace format("%15.0f")
	gen year = pb010
	gen pid = pb030   
	gen country = pb020
	sort year country pid 
	/*checking for duplicates/errors in hid*/
	/*duplicates report year country pid*/
	/* R file contains combinations in pid and hid, so pids are not unique. In P pids are unique, so we can drop the duplicates */
	merge 1:m year country pid using "$datapath\2012R.dta"
	keep if _merge == 3 
	drop _merge 
	duplicates drop year country pid, force
	save "$datapath\2012P.dta", replace

	/*selecting 2011 release data*/
	clear
	use  PB010 PB020 PB080  PX030 PB030 PB130 PB140 PB110 PB150 PB160 PB170 PB180 PB190 PB200 PE040 PH010 PH020 PH030 PL020 PL025 PL040 PL060 PL140 PL160 PL170 PL200 PY010N PY020N PY050N PY090N PY100N PY110N PY120N PY130N PY140N PX020 /*the name of the following variables changes in different years*/ PL030 PL050 PL051 PL210A PL210B PL210C PL210D PL210E PL210F PL210G PL210H PL210I PL210J PL210K PL210L PL211A PL211B PL211C PL211D PL211E PL211F PL211G PL211H PL211I PL211J PL211K PL211L using "$datapath\2011\P_file_2011.dta", clear
	
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	
	tostring pb030, replace format("%15.0f")
	gen year = pb010
	gen pid = pb030   
	gen country = pb020
	sort year country pid 
	/*checking for duplicates/errors in hid*/
	duplicates report year country pid
	/* R file contains combinations in pid and hid, so pids are not unique. In P pids are unique, so we can drop the duplicates */
	merge 1:m year country pid using "$datapath\2011R.dta"
	keep if _merge == 3 
	drop _merge 
	duplicates drop year country pid, force
	save "$datapath\2011P.dta", replace

	/*selecting 2010 release data*/
	clear
	use  PB010 PB020 PB080  PX030 PB030 PB130 PB140 PB110 PB150 PB160 PB170 PB180 PB190 PB200 PE040 PH010 PH020 PH030 PL020 PL025 PL040 PL060 PL140 PL160 PL170 PL200 PY010N PY020N PY050N PY090N PY100N PY110N PY120N PY130N PY140N PX020 /*the name of the following variables changes in different years*/ PL030 PL050 PL051 PL210A PL210B PL210C PL210D PL210E PL210F PL210G PL210H PL210I PL210J PL210K PL210L PL211A PL211B PL211C PL211D PL211E PL211F PL211G PL211H PL211I PL211J PL211K PL211L using "$datapath\2010\P_file_2010.dta", clear
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	
	tostring pb030, replace format("%15.0f")
	gen year = pb010
	gen pid = pb030   
	gen country = pb020
	sort year country pid 
	/*checking for duplicates/errors in hid*/
	/*duplicates report year country pid*/
	/* R file contains combinations in pid and hid, so pids are not unique. In P pids are unique, so we can drop the duplicates */
	merge 1:m year country pid using "$datapath\2010R.dta"
	keep if _merge == 3 
	drop _merge 
	duplicates drop year country pid, force
	save "$datapath\2010P.dta", replace
	
	/*selecting 2009 release data*/
	clear
	use  PB010 PB020 PB080  PX030 PB030 PB130 PB140 PB110 PB150 PB160 PB170 PB180 PB190 PB200 PE040 PH010 PH020 PH030 PL020 PL025 PL040 PL060 PL140 PL160 PL170 PL200 PY010N PY020N PY050N PY090N PY100N PY110N PY120N PY130N PY140N PX020 /*the name of the following variables changes in different years*/ PL030 PL050 PL210A PL210B PL210C PL210D PL210E PL210F PL210G PL210H PL210I PL210J PL210K PL210L PL211A PL211B PL211C PL211D PL211E PL211F PL211G PL211H PL211I PL211J PL211K PL211L using "$datapath\2009\P_file_2009.dta", clear
	
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	
	tostring pb030, replace format("%15.0f")
	gen year = pb010
	gen pid = pb030   
	gen country = pb020
	sort year country pid 
	/*checking for duplicates/errors in hid*/
	/*duplicates report year country pid*/
	/* R file contains combinations in pid and hid, so pids are not unique. In P pids are unique, so we can drop the duplicates */
	merge 1:m year country pid using "$datapath\2009R.dta"
	keep if _merge == 3 
	drop _merge 
	duplicates drop year country pid, force
	save "$datapath\2009P.dta", replace

	/*selecting 2008 release data*/
	clear
	use PB010 PB020 PB080 PX030 PB030 PB130 PB140 PB110 PB150 PB160 PB170 PB180 PB190 PB200 PE040 PH010 PH020 PH030  PL020 PL025 PL040 PL060 PL140 PL160 PL170 PL200 PY010N PY020N PY050N  PY090N PY100N PY110N PY120N PY130N PY140N PX020 /*the name of the following variables changes in different years*/ PL030 PL050  PL210A PL210B PL210C PL210D PL210E PL210F PL210G PL210H PL210I PL210J PL210K PL210L using "$datapath\2008\P_file_2008.dta", clear
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	
	tostring pb030, replace format("%15.0f")
	rename pb010 year
	rename pb030 pid   
	rename pb020 country
	sort year country pid 
	/*checking for duplicates/errors in hid*/
	/*duplicates report year country pid*/
	/* R file contains combinations in pid and hid, so pids are not unique. In P pids are unique, so we can drop the duplicates */
	merge 1:m year country pid using "$datapath\2008R.dta"
	keep if _merge == 3 
	drop _merge 
	duplicates drop year country pid, force
	save "$datapath\2008P.dta", replace

	/*selecting 2007 release data*/
	clear
	use PB010 PB020 PB080 PX030 PB030 PB130 PB140 PB110 PB150 PB160 PB170 PB180 PB190 PB200 PE040 PH010 PH020 PH030  PL020 PL025 PL040 PL060 PL140 PL160 PL170 PL200 PY010N PY020N PY050N PY090N PY100N PY110N PY120N PY130N PY140N PX020 /*the name of the following variables changes in different years*/ PL030 PL050  PL210A PL210B PL210C PL210D PL210E PL210F PL210G PL210H PL210I PL210J PL210K PL210L using "$datapath\2007\P_file_2007.dta", clear
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	
	tostring pb030, replace format("%15.0f")
	gen year = pb010
	gen pid = pb030   
	gen country = pb020
	sort year country pid 
	/*checking for duplicates/errors in pid*/
	duplicates report year country pid
	/* R file contains combinations in pid and hid, so pids are not unique. In P pids are unique, so we can drop the duplicates */
	merge 1:m year country pid using "$datapath\2007R.dta"
	keep if _merge == 3 
	drop _merge 
	duplicates drop year country pid, force
	save "$datapath\2007P.dta", replace

	/*selecting 2006 release data*/
	clear
	use PB010 PB020 PB080 PX030 PB030 PB130 PB140 PB110 PB150 PB160 PB170 PB180 PB190 PB200 PE040 PH010 PH020 PH030  PL020 PL025 PL040 PL060 PL140 PL160 PL170 PL200 PY010N PY020N PY050N PY090N PY100N PY110N PY120N PY130N PY140N PX020 /*the name of the following variables changes in different years*/ PL030 PL050  PL210A PL210B PL210C PL210D PL210E PL210F PL210G PL210H PL210I PL210J PL210K PL210L using "$datapath\2006\P_file_2006.dta", clear

	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	
	tostring pb030, replace format("%15.0f")
	gen year = pb010
	gen pid = pb030   
	gen country = pb020
	sort year country pid 
	/*checking for duplicates/errors in pid*/
	duplicates report year country pid
	/* R file contains combinations in pid and hid, so pids are not unique. In P pids are unique, so we can drop the duplicates */
	merge 1:m year country pid using "$datapath\2006R.dta"
	keep if _merge == 3 
	drop _merge 
	duplicates drop year country pid, force
	save "$datapath\2006P.dta", replace

	/*selecting 2005 release data*/
	clear
	use PB010 PB020 PB080  PX030 PB030 PB130 PB140 PB110 PB150 PB160 PB170 PB180 PB190 PB200 PE040 PH010 PH020 PH030  PL020 PL025 PL040 PL060 PL140 PL160 PL170 PL200 PY010N PY020N PY050N PY090N PY100N PY110N PY120N PY130N PY140N PX020 /*the name of the following variables changes in different years*/ PL030 PL050  PL210A PL210B PL210C PL210D PL210E PL210F PL210G PL210H PL210I PL210J PL210K PL210L using "$datapath\2005\P_file_2005.dta", clear
	
	
	local new_var=lower("`var'")

    foreach var of varlist _all {
    	local new_var = lower("`var'")
    	cap rename `var' `new_var'
    }
	
	tostring pb030, replace format("%15.0f")
	gen year = pb010
	gen pid = pb030   
	gen country = pb020
	sort year country pid 
	/*checking for duplicates/errors in pid*/
	duplicates report year country pid
	/* R file contains combinations in pid and hid, so pids are not unique. In P pids are unique, so we can drop the duplicates */
	merge 1:m year country pid using "$datapath\2005R.dta"
	keep if _merge == 3 
	drop _merge 
	duplicates drop year country pid, force
	save "$datapath\2005P.dta", replace

	/*merge data from all releases with masterfile. 
	!! this process is memory intensive. */


	clear 
	
	use "$datapath\2020P.dta", clear
	merge 1:1 year upid country uhid using "$datapath\2019P.dta"
	drop _merge
	merge 1:1 year upid country uhid using "$datapath\2018P.dta"
	drop _merge
	merge 1:1 year upid country uhid using "$datapath\2017P.dta"
	drop _merge
	merge 1:1 year upid country uhid using "$datapath\2016P.dta"
	drop _merge
	merge 1:1 year upid country uhid using "$datapath\2015P.dta"
	drop _merge
	
	save "$datapath\masterP.dta", replace
	
	
	
	clear
	use "$datapath\masterP.dta"
	
	merge 1:1 year upid country uhid using "$datapath\2014P.dta"
	drop _merge
	merge 1:1 year upid country uhid using "$datapath\2013P.dta"
	drop _merge
	merge 1:1 year upid country uhid using "$datapath\2012P.dta"
	drop _merge
	merge 1:1 year upid country uhid using "$datapath\2011P.dta"
	drop _merge
	merge 1:1 year upid country uhid using "$datapath\2010P.dta"
	drop _merge
	merge 1:1 year upid country uhid using "$datapath\2009P.dta"
	drop _merge
	save "$datapath\masterP.dta", replace
	
	
	
	clear
	use "$datapath\masterP.dta"
	
	merge 1:1 year upid country uhid using "$datapath\2008P.dta"
	drop _merge
	merge 1:1 year upid country uhid using "$datapath\2007P.dta"
	drop _merge
	
	save "$datapath\masterP.dta", replace
	
	
	
	clear
	use "$datapath\masterP.dta"
	
	merge 1:1 year upid country uhid using "$datapath\2006P.dta"
	drop _merge
	
	save "$datapath\masterP.dta", replace
	
	clear
	use "$datapath\masterP.dta"
	
	merge 1:1 year upid country uhid using "$datapath\2005P.dta"
	drop _merge
	/*eliminate variables from the R file*/
	drop rb010 rb020 rb030 rb060 rb040 rb062 rb063 rb064 rb070 rb080 rb090 rb110 rb120 rb220 rb230 rb240 rb245 hid db010 db020 db030 db040 db075 db100 db110 

	/*drop superflous variables */
	drop drpout_year* slctd_urtgrp* slctd_uhid*  merge* nrtgrp*  lgstgrp maxgrp drpout_year slctd_rtgrp 

	/* This is the personal data file (P) file 2003 - 2020 */
	save "$datapath\masterP.dta", replace
	
	/***/
	/*erasing superflous files from the disc */
	
	clear
	
	erase "$datapath\2020D.dta"
	erase "$datapath\2020H.dta" 
	erase "$datapath\2020P.dta"
	erase "$datapath\2020R.dta"

	
	erase "$datapath\2019D.dta"
	erase "$datapath\2019H.dta"
	erase "$datapath\2019P.dta"
	erase "$datapath\2019R.dta"
	
	erase "$datapath\2017D.dta"
	erase "$datapath\2017H.dta"
	erase "$datapath\2017P.dta"
	erase "$datapath\2017R.dta"
	
	erase "$datapath\2016D.dta"
	erase "$datapath\2016H.dta"
	erase "$datapath\2016P.dta"
	erase "$datapath\2016R.dta"
	
	erase "$datapath\2015D.dta"
	erase "$datapath\2015H.dta"
	erase "$datapath\2015P.dta"
	erase "$datapath\2015R.dta"

	erase "$datapath\2014D.dta"
	erase "$datapath\2014H.dta"
	erase "$datapath\2014P.dta"
	erase "$datapath\2014R.dta"

	erase "$datapath\2013D.dta"
	erase "$datapath\2013H.dta"
	erase "$datapath\2013P.dta"
	erase "$datapath\2013R.dta"

	erase "$datapath\2012D.dta"
	erase "$datapath\2012H.dta"
	erase "$datapath\2012P.dta"
	erase "$datapath\2012R.dta"

	erase "$datapath\2011D.dta"
	erase "$datapath\2011H.dta"
	erase "$datapath\2011P.dta"
	erase "$datapath\2011R.dta"

	erase "$datapath\2010D.dta"
	erase "$datapath\2010H.dta"
	erase "$datapath\2010P.dta"
	erase "$datapath\2010R.dta"

	erase "$datapath\2009D.dta"
	erase "$datapath\2009H.dta"
	erase "$datapath\2009P.dta"
	erase "$datapath\2009R.dta"

	erase "$datapath\2008D.dta"
	erase "$datapath\2008H.dta"
	erase "$datapath\2008P.dta"
	erase "$datapath\2008R.dta"

	erase "$datapath\2007D.dta"
	erase "$datapath\2007H.dta"
	erase "$datapath\2007P.dta"
	erase "$datapath\2007R.dta"

	erase "$datapath\2006D.dta"
	erase "$datapath\2006H.dta"
	erase "$datapath\2006P.dta"
	erase "$datapath\2006R.dta"
	
	erase "$datapath\2005D.dta"
	erase "$datapath\2005H.dta"
	erase "$datapath\2005P.dta"
	erase "$datapath\2005R.dta"

/******************************************************************************
RENAMING THE VARIABLES*********************************************************
*******************************************************************************/

clear
capture log close
set more off

use "$datapath\masterD", clear
drop db010 db030 db075
rename db020 country_short
rename db040 region
rename db100 urbanisation
rename db110 hhold_status
save "$datapath\masterD1", replace
clear

use "$datapath\masterH", clear
drop hb010 hb020 hb030
rename hb050 quarter_interview
rename hb100 minutes
rename hh010 dwelling
rename hy010 total_hhold_inc
rename hy020 total_disp_hhold_inc
rename hx040 hhold_members
save "$datapath\masterH1", replace
clear
 
use "$datapath\masterP", clear
drop pb010 pb020 pb030
rename pb080 personal_weight		
rename pb130 birth_month
rename pb140 birth_year
rename pb110 pers_interview_year
rename pb150 sex
rename pb160 father_id
rename pb170 mother_id
rename pb180 partner_id
rename pb190 marital_status
rename pb200 cons_union	
rename pe040 highest_educ
rename ph010 gen_health 
rename ph020 chronic_illness
rename ph030 health_limit_activ 	
rename pl020 look_for_job
rename pl025 avail_for_work
rename pl040 empl_status
rename pl060 hours_worked_per_week
rename pl140 contract_type
rename pl160 change_job
rename pl170 reason_change
rename py010n empl_inc_net
rename py020n empl_noncash_net
rename py050n selfemp_cash_net
rename py080g pension_gross
rename py100n oldage_benefits
rename py110n surv_benefits
rename py120n sick_benefits
rename py130n disab_benefits
rename py140n educ_benefits
rename py090n unemp_benefits
rename py010g empl_inc_gross
rename py020g empl_noncash_gross
rename py050g selfemp_cash_gross
rename px020 age_end_of_period
rename pl030 econ_status1
rename pl031 econ_status2
rename pl050 occupation
rename pl051 occupation_icso08
rename pl200 years_in_paid_work
rename pl210a activity_jan
rename pl210b activity_feb
rename pl210c activity_march
rename pl210d activity_april
rename pl210e activity_may
rename pl210f activity_june
rename pl210g activity_july
rename pl210h activity_august
rename pl210i activity_sept
rename pl210j activity_oct
rename pl210k activity_nov
rename pl210l activity_dec
rename pl211a activity_jan2
rename pl211b activity_feb2
rename pl211c activity_march2
rename pl211d activity_april2
rename pl211e activity_may2
rename pl211f activity_june2
rename pl211g activity_july2
 rename pl211h activity_august2
rename pl211i  activity_sept2
 rename pl211j activity_oct2
rename pl211k activity_nov2
rename pl211l activity_dec2
	
save "$datapath\masterP1", replace
clear

use "$datapath\MasterR", clear
rename rb060 pers_base_weight
rename rb070 birth_month
rename rb062 weight_two
rename rb063 weight_three
rename rb064 weight_four
rename rb080 birth_year
rename rb090 sex
rename rb110 memb_status
rename rb120 moved_to
rename rb220 father_id
rename rb230 mother_id
rename rb240 partner_id
rename rb245 respondent_status
rename rx020 age_end_period
save "$datapath\MasterR", replace
clear
			
/**********************************************************************
***MERGING THE MASTER FILES *******************************************
**********************************************************************/

/***MERGING THE PERSONAL FILES***/

clear
capture log close
set more off

use "$datapath\masterP1"
merge 1:1 year country uhid pid sex birth_year using "$datapath\masterR"
drop if _merge == 1
drop _merge
sort  year country uhid pid
save "$datapath\Personal_Files", replace 


/***MERGING THE HOUSEHOLD FILES***/

use "$years_path\masterD1"
merge 1:1 year country uhid using "$years_path\masterH1"
drop _merge
sort year country uhid
save "$years_path\Household_files", replace
clear

/*** MERGING THE HOUSEHOLD AND THE PERSONAL DATA FILES***/

clear
capture log close
set more off 
use "$years_path\Personal_Files"
merge m:1 year country uhid using "$years_path\Household_files"
drop if _merge == 1
drop if _merge ==2
 drop _merge

save "$years_path\Final_Data_2005-2020", replace



/*******************************************************************************
***************GENERATE QUINTILES OF EQUIVALISED DISPOSABLE INCOME**************
***********USING THE DO-FILES PROVIDED BY GESIS, AVAILABLE HERE: ***************
           https://www.ssoar.info/ssoar/handle/document/68060.2
*******************************************************************************/
clear
capture log close
set more off

use "$years_path\Final_Data_2005-2020", clear
bysort country year uhid: egen sum080 = sum(pension_gross)
gen hydisp = (total_disp_hhold_inc + sum080) if year < 2011 
replace hydisp = total_disp_hhold_inc if year >= 2011

***Generating HH equivalence weight***
gen child=.
replace child=1 if age_end_period<14 & age_end_period!=.
replace child=0 if age_end_period>=14 & age_end_period!=.

gen adult=.
replace adult=1 if age_end_period>=14 & age_end_period!=.
replace adult=0 if age_end_period<14 & age_end_period!=.

bysort country year uhid: egen hhnbr_child = total(child)
bysort country year uhid: egen hhnbr_adult = total(adult)
gen hhnbr_pers = hhnbr_child + hhnbr_adult

gen eqs_old =.
replace eqs_old = 1+(hhnbr_adult-1)*0.7 + hhnbr_child*0.5 if hhnbr_adult>=1
replace eqs_old = 1+(hhnbr_child -1)* 0.5 if hhnbr_adult<1

gen eqs =.
replace eqs = 1+(hhnbr_adult -1)*0.5 + hhnbr_child * 0.3 if hhnbr_adult>=1
replace eqs = 1+(hhnbr_child -1)* 0.3 if hhnbr_adult<1

***Generating quintiles of the income distribution by country***
***Note that depending on the number of countries in your dataset you might have to redefine the definition of i

encode country, gen(country_num)
gen quintile=.
forvalues i=1/32 {
xtile quintile`i'= hydisp if country_num==`i', nq(5)
replace quintile=quintile`i' if country_num==`i'
drop quintile`i'
}
drop child adult hhnbr_child hhnbr_adult hhnbr_pers eqs_old eqs country_num

/******************************************************************************
********GENERATE CHILDREN VARIABLES BY USING RELATIONSHIP WITH PARENTS**********
*******************************************************************************/
//Identify families 
sort country year uhid
generate double identify_families = mother_id
format identify_families %12.0f
destring pid, replace
format pid %12.0f
replace identify_families = pid if identify_families == . & sex == 2
replace identify_families = partner_id if identify_families == . & sex == 1

egen families = group (country year uhid identify_families)

generate age = year - birth_year
replace age = 0 if age < 0
/*Generate binary variable for presence of children aged 0 to 3*/
egen nchild = total(age <=18), by(families)

/*Note: it results in abnormal values for those who are single, because of the missing data, but they will de dropped in the next stage*/

egen child0_3 = total(age<=3), by(families)
replace child0_3 = 1 if child0_3 != 0

/*Generate binary variable for presence of children aged 4 to 6*/
egen child4_6 = total(age >=4 & age <=6), by(families)
replace child4_6 = 1 if child4_6 != 0


/*Generate binary variable for presence of  children aged 4 to 6*/
egen child7_12 = total( age >=7 & age <= 12 ), by(families)
replace child7_12 = 1 if child7_12 != 0


/*Generate new variables with the age of the youngest three kids in the household - will be needed to assign the MTRS and RRS*/
 sort families age
 by families: egen youngest_kid = min(age/(age<=18))
 by families: egen secondyoungest_kid = min(cond(_n == 2 & age <= 18, age, .))
 by families: egen thirdyoungest_kid = min(cond(_n == 3 & age <= 18, age, .))
 
 drop identify_families families
save "$years_path\Final_Data_2005-2020_variables", replace


 /******************************************************************************
 **********KEET THE COUPLES COUPLES THAT MEET OUR CRITERIA **********************
 *******************************************************************************/
 
clear
capture log close
set more off

 /***GENERATE A SUBSAMPLE OF WOMEN WITH PARTNER***/
 use "$years_path\Final_Data_2005-2020_variables", clear
 keep if sex == 2
 drop if partner_id ==.
 sort year country uhid partner_id
 save "$years_path\EU_SILC_full_nodups_femalew_partner", replace

 /*** GENERATE A SUBSAMPLE OF MEN WITH PARTNER ***/
 
 use"$years_path\Final_Data_2005-2020_variables", clear
 keep if sex == 1
 drop if partner_id ==.
 keep year country hid uhid personal_weight pers_interview_year birth_year sex father_id mother_id marital_status partner_id cons_union highest_educ look_for_job avail_for_work econ_status2 empl_status occupation_icso08 hours_worked_per_week change_job reason_change years_in_paid_work activity_jan2 activity_feb2 activity_march2 activity_april2 activity_may2 activity_june2 activity_july2 activity_august2 activity_sept2 activity_oct2 activity_nov2 activity_dec2 gen_health age chronic_illness health_limit_activ empl_inc_net empl_noncash_net unemp_benefits oldage_benefits surv_benefits sick_benefits disab_benefits educ_benefits age_end_of_period px030 pid rotation_group urtgrp upid occupation econ_status1 activity_jan activity_feb activity_march activity_april activity_may activity_june activity_july activity_august activity_sept activity_oct activity_nov activity_dec pscale pb080s smwrate80 pers_base_weight weight_two weight_three weight_four contract_type selfemp_cash_net empl_inc_gross empl_noncash_gross selfemp_cash_gross
 
local varlist1 "personal_weight pers_interview_year birth_year sex father_id mother_id marital_status partner_id cons_union highest_educ look_for_job avail_for_work econ_status2 empl_status occupation_icso08 hours_worked_per_week change_job reason_change years_in_paid_work activity_jan2 activity_feb2 activity_march2 activity_april2 activity_may2 activity_june2 activity_july2 activity_august2 activity_sept2 activity_oct2 activity_nov2 activity_dec2 gen_health age chronic_illness health_limit_activ empl_inc_net empl_noncash_net unemp_benefits oldage_benefits surv_benefits sick_benefits disab_benefits educ_benefits age_end_of_period px030 pid rotation_group urtgrp upid occupation econ_status1 activity_jan activity_feb activity_march activity_april activity_may activity_june activity_july activity_august activity_sept activity_oct activity_nov activity_dec pscale pb080s smwrate80 pers_base_weight weight_two weight_three weight_four contract_type selfemp_cash_net empl_inc_gross empl_noncash_gross selfemp_cash_gross"

 foreach x of local varlist1 {
rename `x' `x'_p
 }
 rename pid partner_id
 rename partner_id_p pid
 sort year country hid partner_id pid
 save "$years_path\EU_SILC_full_nodups_malew_partner", replace
  
 /*MERGE THE PARTNER SUBSAMPLES*/

use "$years_path\EU_SILC_full_nodups_femalew_partner", clear
sort year country uhid partner_id pid
merge 1:1 year country uhid partner_id pid using "$years_path\EU_SILC_full_nodups_malew_partner"
drop if _merge==1
 drop if _merge==2
 drop _merge
save "$years_path\EU_SILC_partners_merged", replace


/*RECODING AND RELABELING THE MONTHLY ACTIVITY VARIABLES BECAUSE THE CLASSIFICATION CHANGED BETWEEN WAVES*/

clear
capture log close
set more off
use "$years_path\EU_SILC_partners_merged", clear


label define monthlyactivity 1 "Employee (full-time)" 2 "Employee (part-time)" 3 "Self-employed full-time" 4 "Self-employed part-time" 5 "Unemployed" 12 "Retired or unfit"  13 "Student"  8 "Inactive/Out of labour force" 9 "Compulsory military"


local varlist1 "activity_jan activity_feb activity_march activity_april activity_may activity_june activity_july activity_august activity_sept activity_oct activity_nov activity_dec"

foreach var of local varlist1 {
replace `var' = 12 if `var' == 6
replace `var' = 13 if `var' == 7
local a = `a' + 1
rename `var' responsep1_`a'
}
local varlist2 "activity_jan2 activity_feb2 activity_march2 activity_april2 activity_may2 activity_june2 activity_july2 activity_august2 activity_sept2 activity_oct2 activity_nov2 activity_dec2"

 foreach var of local varlist2 {
 replace `var' = 12 if `var' == 7
 replace `var' = 13 if `var' == 6
 replace `var' = 8 if `var' == 10
 replace `var' = 8 if `var' == 11

 local b = `b' + 1
 rename `var' response`b'
 replace response`b' = responsep1_`b' if response`b' == .
 label values response`b' monthlyactivity
 drop responsep1_`b'
 }
 
local varlist3 "activity_jan_p activity_feb_p activity_march_p activity_april_p activity_may_p activity_june_p activity_july_p activity_august_p activity_sept_p activity_oct_p activity_nov_p activity_dec_p"

 foreach var of local varlist3 {
 replace `var' = 12 if `var' == 6
 replace `var' = 13 if `var' == 7
 local c = `c' + 1
 rename `var' activityp1_`c'
 }

local varlist4 " activity_jan2_p activity_feb2_p activity_march2_p activity_april2_p activity_may2_p activity_june2_p activity_july2_p activity_august2_p activity_sept2_p activity_oct2_p activity_nov2_p activity_dec2_p"

 foreach var of local varlist4 {
 replace `var' = 12 if `var' == 7
 replace `var' = 13 if `var' == 6
 replace `var' = 8 if `var' == 10
 replace `var' = 8 if `var' == 11
 local d = `d' + 1
 rename `var' activity`d'
 replace activity`d' = activityp1_`d' if activity`d' == .
 label values activity`d' monthlyactivity
 drop activityp1_`d'
 }
 
save "$years_path\EU_SILC_partners_merged_recoded", replace


/*****************************************************************************
KEEPING THE 27 EU MEMBER STATES AMD THE UK, 2009-2019
KEEPING COUPLES  BETWEEN 25 AND 65, WHERE NEITHER PARTER IS RETIRED OR UNABLE TO WORK, AND THOSE WITH CLOPLETE WORK HISTORIES************
*****************************************************************************/

clear
capture log close
set more off

use "$years_path\EU_SILC_partners_merged_recoded", clear

/***THERE ARE DUPLICATES ON COUNTRY YEAR UHID -I.E. COUPLES LIVING IN THE SAME HOUSEHOLD - WE GENERATE A NEW VARIABLE THAT UNIQULY IDENTIFIES COUPLES*/
 egen hhunique =  concat(uhid pid birth_year)
 duplicates drop  year hhunique, force

 
/*KEEPING THE 27 EU MEMEBER STATES + UK*/

keep if country == "AT" | country == "BE" | country == "BG" | country == "CY" | country == "CZ" | country == "DE" |country == "DK" | country == "EE"| country == "EL" | country == "ES" | country == "FI" | country == "FR" |  country == "HR"  |  country == "HU" |  country == "IE"  | country == "IT"  | country == "LT"  | country == "LU"  | country == "LV"  |  country == "MT" |country == "NL" | country == "PL" | country == "PT" | country == "RO" | country == "SE" |  country == "SI" |  country == "SK" | country == "UK"

/*KEEPING THE YEARS 2009-2020*/

keep if year >=2009

/*KEEPING OBSERVATIONS WHERE BOTH PARTNERS ARE BETWEEN 25 AND 65*/
gen keepage = 1 if age >= 25 & age <= 65 & age_p >= 25 & age_p <= 65
drop if keepage ==.
drop keepage

/*DROPPING OBSERVATIONS WHERE THE MONTLY ACTIVITY INFORMATION FOR ONE OR BOTH PARTNERS IS MISSING */
generate incomplete_female =  1 if response1 == . |  response2 == . | response3 == . | response4 == . | response5 == . | response6 == . | response7 == . | response8 == . | response9 == . | response10 == . | response11 == . | response12 == .
generate incomplete_male = 1 if activity1 == . | activity2 == . | activity3 == . | activity4 == . | activity5 == . | activity6 == . | activity7 == . | activity8 == . | activity9 == . | activity10 == . | activity11 == . | activity12 == .
egen hh_incomplete = total(incomplete_female ==  1  | incomplete_male == 1), by(hhunique)
drop if hh_incomplete != 0
drop incomplete_female
drop incomplete_male
drop hh_incomplete

/*DROPPING OBSERVATIONS WHERE THE PARTNERS ARE RETIRED OR UNFIT TO WORK*/

 gen dropretired = 1 if activity1 == 12 | activity2 == 12 | activity3 == 12 | activity4 == 12 | activity5 == 12 | activity6 == 12 | activity7 == 12 | activity8 == 12 | activity9 == 12 | activity10 == 12 | activity11 == 12 | activity12 == 12
 replace dropretired  = 1 if response1 == 12 | response2 == 12 | response3 == 12 | response4 == 12 | response5 == 12 | response6 == 12 | response7 == 12 | response8 == 12 | response9 == 12 | response10 == 12 | response11 == 12 | response12 == 12
 drop if dropretired  == 1
 drop dropretired
 
 /*DROPPING OBSERVATIONS WHERE ONE OF THE PARTNERS IS IN COMPULSORY MILITARY*/

 gen military = 1 if activity1 == 9 | activity2 == 9 | activity3 == 9 | activity4 == 9 | activity5 == 9 | activity6 == 9 | activity7 == 9 | activity8 == 9 | activity9 == 9 | activity10 == 9 | activity11 == 9 | activity12 == 9
 replace military  = 1 if response1 == 9 | response2 == 9 | response3 == 9 | response4 == 9 | response5 == 9 | response6 == 9 | response7 == 9 | response8 == 9 | response9 == 9 | response10 == 9 | response11 == 9 | response12 == 9
 drop if military  == 1 
 drop military
 
 /*DROPPING FAMILY WORKERS*/ 
 gen family_worker = 1 if empl_status_p == 4
 drop if family_worker == 1
 drop family_worker
 
 /*DROPPING CASES WITH MISSINGS ON OUR VARIABLES OF INTEREST*/
 generate occup_men = occupation_p
 replace occup_men = occupation_icso08_p if occup_men == .
 
 generate occup_women = occupation_icso08
 replace occup_women = occupation if occup_women == .
 
 drop if occup_men == . 
 drop if cons_union == . 
 drop if highest_educ == . 
 drop if highest_educ_p == .
 drop if quintile == .

 /*IDENTIFY AND KEEP HOUSEHOLDS SURVEYED FOR AT LEAST 3 YEARS */
 sort hhunique year
by hhunique: generate no_waves = _N
drop if no_waves <= 2
drop no_waves

save "$years_path\EU_SILC_partners_merged_cleaned", replace


/******************************************************************************
 GENERATING AND RECODING THE VARIABLES FOR THE ANALYSIS*************************
 ******************************************************************************/
clear
capture log close
set more off

use "$years_path\EU_SILC_partners_merged_cleaned", clear
 
/*Type of union*/
 generate married = cons_union
 drop cons_union
 /*If both partners stated that they are married, but their conensual union is "no", I reclasify them as married*/
 replace married = 1 if married == 3 & marital_status == 2 & marital_status_p == 2
 replace married = 0 if married == 2
 drop if married == 3
 drop cons_union
 label define union 1 "Married" 0 "Cohabiting"
 label values married union
 
 /*Education variables female and male*/
  generate education_woman = 1 if highest_educ == 0 | highest_educ == 1 | highest_educ == 2 | highest_educ == 100 | highest_educ == 200
  replace education_woman = 2 if highest_educ == 3 | highest_educ == 4 | highest_educ == 300 | highest_educ == 340 | highest_educ == 342 | highest_educ == 343 | highest_educ == 344 | highest_educ == 350 | highest_educ == 352| highest_educ == 353| highest_educ == 354 |  highest_educ == 400 | highest_educ == 440 | highest_educ == 450
  replace education_woman = 3 if highest_educ == 500 | highest_educ == 600 | highest_educ == 700 | highest_educ == 800 | highest_educ == 5 |  highest_educ == 6 | highest_educ == 7 | highest_educ == 8
 
  generate education_man = 1 if highest_educ_p == 0 | highest_educ_p == 1 | highest_educ_p == 2 | highest_educ_p == 100 | highest_educ_p == 200
  replace education_man = 3 if  highest_educ_p == 500 | highest_educ_p == 600 | highest_educ_p == 700 | highest_educ_p == 800 | highest_educ_p == 5 | highest_educ_p == 6 | highest_educ_p == 7 | highest_educ_p == 8
 replace education_man = 2 if highest_educ_p == 3 | highest_educ_p == 4 | highest_educ_p == 300 | highest_educ_p == 340 | highest_educ_p == 342 | highest_educ_p == 343 | highest_educ_p == 344 | highest_educ_p == 350 | highest_educ_p == 352| highest_educ_p == 353| highest_educ_p == 354 | highest_educ_p == 400 |  highest_educ_p == 440 | highest_educ_p == 450
  label define education_category 1 "Low education"  2 "Medium education" 3 "Higher education"
  label values education_woman education_category
  label values education_man education_category
 
 /*Occupation variables female and male*/
 generate occupation_woman = 1 if  occup_women >= 80 & occup_women <= 99
 replace occupation_woman = 1 if occup_women == 9 | occup_women == 8
 replace occupation_woman = 2 if occup_women >= 6 & occup_women <= 79
 replace occupation_woman = 2 if occup_women == 6 | occup_women == 7 
 replace occupation_woman = 3 if occup_women >= 40 & occup_women <= 59
 replace occupation_woman = 3 if occup_women == 4 | occup_women == 5 
 replace occupation_woman = 4 if occup_women >= 10 &  occup_women <= 39
 replace occupation_woman = 4 if occup_women == 1 | occup_women == 2 | occup_women == 3
 
 generate occupation_man = 1 if  occup_men == 0
 replace occupation_man = 1 if  occup_men >= 80 & occup_men <= 99
 replace occupation_man = 1 if occup_men == 9 | occup_men == 8
 replace occupation_man = 2 if occup_men >= 6 & occup_men <= 79
 replace occupation_man = 2 if occup_men == 6 | occup_men == 7 
 replace occupation_man = 3 if occup_men >= 40 & occup_men <= 59
 replace occupation_man = 3 if occup_men == 4 | occup_men == 5 
 replace occupation_man = 4 if occup_men >= 10 &  occup_men <= 39
 replace occupation_man = 4 if occup_men == 1 | occup_men == 2 | occup_men == 3
  
  label define occupation_category 1 "Blue-collar low" 2 "Blue-collar high" 3 "White-collar low" 4 "White-collar high"
  label values occupation_woman occupation_category
  label values occupation_man occupation_category
 
 
 compress
save "$years_path\EU_SILC_partners_merged_variables_cleaned", replace

 /******************************************************************************
 *********************GENERATING THE SAMPLES FOR ANALYSES**********************
 ******************************************************************************/
 
 /*IRELAND THE MONTLY ACTIVITY DATA REFERS TO THE SAME YEAR AS HH AND INDIVIDUL DATA - WE CREATE A SEPARATE FILE FOR IT*/
 clear
capture log close
set more off

use "$years_path\EU_SILC_partners_merged_variables_cleaned", clear
keep if country == "IE" | country == "UK"
/*Reshaping the data*/
reshape long activity response, i(year hhunique) j(month)
drop if year == 2020
sort uhid year month
save "$years_path\EU_SILC_IE_UK", replace

/*FOR ALL THE OTHER COUNTRIES THE MONTLY ACTIVITY DATA REFERS TO THE PREVIOUS YEAR - SEE: https://d-nb.info/1030065543/34, WE LAG THE DATA TO ACCOUNT FOR THIS*/

clear
capture log close
set more off

use "$years_path\EU_SILC_partners_merged_variables_cleaned", clear
drop if country == "UK"
drop if country == "IE"
/*Reshaping the data*/
reshape long activity response, i(year hhunique) j(month)
 /*Lagging the variables based on montly activity status and change of jobs so that it corresponds to the HH and individual variables*/

 sort hhunique year month 
 by hhunique: gen activity_lag = activity[_n+12] 
 by hhunique: gen response_lag = response[_n+12] 
 by hhunique: gen change_job_p_lag = change_job_p[_n+12] 
 by hhunique: gen reason_change_p_lag =  reason_change_p[_n+12] 
 by hhunique: gen change_job_lag = change_job[_n+12] 
 by hhunique: gen reason_change_lag =  reason_change[_n+12]

 drop if activity_lag == . | response_lag == .
 
 drop activity
 drop response
 drop change_job_p
 drop reason_change_p
 drop change_job
 drop reason_change
 
 rename activity_lag activity
 rename response_lag response
 rename change_job_p_lag change_job_p
 rename reason_change_p_lag reason_change_p
 rename change_job_lag change_job
 rename reason_change_lag reason_change

 label values activity monthlyactivity
 label values response monthlyactivity
 label values change_job_p PL160_VALUE_LABELS
 label values reason_change_p PL170_VALUE_LABELS
 label values change_job PL160_VALUE_LABELS
 label values reason_change PL170_VALUE_LABELS
 
 compress
save "$years_path\EU_SILC_Other_countries", replace


/*APPENDING THE IRELAND DATA WITH THE DATA FOR THE OTHER COUNTRIES*/
clear
 capture log close
 set more off

 use "$years_path\EU_SILC_Other_countries.dta", clear
 append using "$years_path\EU_SILC_IE_UK.dta"
 save "$years_path\EU_SILC_PLOS_One.dta", replace 


 /*******************************************************************************
*************************MERGING WITH THE POLICY VARIABLE**********************
*******************************************************************************/
 
/***************GENERATE THE VARIABLES NEEDED FOR MERGING WITH THE POLICY VARIABLES******************************/
clear
use "$years_path\EU_SILC_PLOS_One.dta", clear

/********IDENTIFY THE BIRTH COHORT OF THE MEN AND WOMEN IN THE COUPLE NEEDED TO ASSIGN THE GENDER ATTITUDES VARIABLES****/
sort uhid year month
generate cohort_woman = 1 if birth_year < 1950
replace cohort_woman = 2 if birth_year >= 1950 & birth_year <= 1959
replace cohort_woman = 3 if birth_year >= 1960 & birth_year <= 1969
replace cohort_woman = 4 if birth_year >= 1970 & birth_year <= 1979
replace cohort_woman = 5 if birth_year >= 1980 & birth_year <= 1989
replace cohort_woman = 2 if birth_year >=1990

generate cohort_man = 1 if birth_year_p < 1950
replace cohort_man = 2 if birth_year_p >= 1950 & birth_year_p <= 1959
replace cohort_man = 3 if birth_year_p >= 1960 & birth_year_p <= 1969
replace cohort_man = 4 if birth_year_p >= 1970 & birth_year_p <= 1979
replace cohort_man = 5 if birth_year_p >= 1980 & birth_year_p <= 1989
replace cohort_man = 2 if birth_year_p >=1990

label define cohort 1"<1950" 2"1950-1959" 3"1960-1869" 4"1970-1979" 5"1980-1989" 6">1990"
label values cohort_woman cohort
label values cohort_man cohort

/***INDETIFY THE QUARTER NEEDED TO MERGE WITH THE UNEMPLOYMENT RATE AND WOMEN LABOUR FORCE PARTICIPATION*****/
generate quarter = 1 if month == 1 | month == 2 | month == 3
replace quarter = 2 if month == 4 | month == 5 | month == 6
replace quarter = 3 if month == 7 | month == 8 | month == 9
replace quarter = 4 if month == 10 | month == 11 | month == 12


merge m:1 country year using "C:\Users\adm\Documents\WP.3.1. STUDIES\Contextual data\Childcare based on EU-SILC"
drop if _merge==2
drop _merge
label variable childcare_0_3_G "Childcare 0-3_General"
label variable childcare_4_6_G "Childcare 4-6_General"
label variable childcare_7_12_G "Childcare 7-12_General"
 
 
label variable childcare_0_3_PT "Childcare 0-3_PT"
label variable childcare_4_6_PT "Childcare 4-6_PT"
label variable childcare_7_12_PT "Childcare 7-12_PT"


label variable childcare_0_3_FT "Childcare 0-3_FT"
label variable childcare_4_6_FT "Childcare 4-6_FT"
label variable childcare_7_12_FT "Childcare 7-12_FT"

/***********MERGING WITH THE POLICY VARIABLES*****************************/
/*Note: the MTRS and NRRS are merged with each sample as they differ based on women's employment status in the first period of observation***/
merge m:1 country year quarter using "C:\Users\adm\Documents\WP.3.1. STUDIES\Contextual data\Unemploymemt rate"
drop if _merge==2
drop _merge
label variable unemployment_rate "Unemployment rate"
merge m:1 country year quarter using "C:\Users\adm\Documents\WP.3.1. STUDIES\Contextual data\WOMEN LABOUR FORCE PARTICIPATION"
label variable female_participation "Women LFP"
drop if _merge==2
drop _merge
merge m:1 country cohort_man using "C:\Users\adm\Documents\WP.3.1. STUDIES\Contextual data\Gender attitudes MEN.dta"
drop if _merge==2
drop _merge

label variable share_men_responsibility "Men gender attitudes"
merge m:1 country cohort_woman using "C:\Users\adm\Documents\WP.3.1. STUDIES\Contextual data\Gender attitudes WOMEN.dta"
label variable share_women_responsibility "Women gender attitudes"
drop if _merge==2
drop _merge

save "$years_path\EU_SILC_PLOS_One_Country_Variables.dta", replace


/*******************************************************************************
************************GENERATING THE TWO SAMPLES:*****************************
*******1. HUSBAND EMPLOYED, WIFE NOT WORKING (I.E. INACTIVE OR UNEMPLOYED)******
***************2. HUSBAND EMPLOYED, WIFE WORKING PART-TIME*********************/

/*******************************************************************************
*******************SAMPLE 1. HUSBAND EMPLOYED WIFE NOT WORKING******************
*******************************************************************************/

 clear
 use "$years_path\EU_SILC_PLOS_One_Country_Variables.dta", clear

 /*Keeping only couples in which the man is employed and the woman is out of work in first month of observation*/
 
 egen time = group(year month)
 sort hhunique time
 bysort hhunique (time): gen no_observation = _n
egen to_keep = max((no_observation == 1) & (activity == 1 | activity == 2 | activity == 3 | activity == 4) & (response ==  5  | response ==  8 )), by(hhunique)
 drop if to_keep != 1
 drop to_keep 

 /*Sort the data by household and time*/
 encode  hhunique, generate(hhunique_no)
 sort hhunique_no time
 xtset hhunique_no time 
 
/*Identifying the unemployment spells that last for at least 3 months*/
 bys hhunique_no (time): generate begin_unemployment = (activity ==  5) & (activity != activity[_n-1])
 bys hhunique_no (time): generate spell_unemployment = cond(activity ==  5, sum(begin_unemployment), 0)
 by hhunique_no spell_unemployment(time), sort: gen length_male_unemployment = _N

generate unemployed3m = 1 if activity ==  5 & length_male_unemployment >= 3
replace unemployed3m  = 0 if activity == 1 | activity == 2 | activity == 3 | activity == 4
replace unemployed3m  = 0 if activity ==  5 & length_male_unemployment <=2
label define unemployed 1"Man unemployed" 0"Man employed"
label values unemployed3m unemployed

/*Identifying the unemployment spells that last between 3 and 6 months*/
generate unemployed3_6m = 1 if activity ==  5 & (length_male_unemployment >= 3 & length_male_unemployment <= 6)
replace unemployed3_6m  = 0 if activity == 1 | activity == 2 | activity == 3 | activity == 4
replace unemployed3_6m  = 0 if activity ==  5 & length_male_unemployment <= 2
replace unemployed3_6m  = . if activity ==  5 & length_male_unemployment >= 7

label values unemployed3_6m unemployed

/*Identifying the unemployment spells that last more than months*/
generate unemployed_over_6m = 1 if activity ==  5 & length_male_unemployment > 6
replace unemployed_over_6m  = 0 if activity == 1 | activity == 2 | activity == 3 | activity == 4
replace unemployed_over_6m  = . if activity == 5 & length_male_unemployment <=6
replace unemployed_over_6m  = 0 if activity ==  5  & length_male_unemployment <= 2

label values unemployed_over_6m unemployed

//Identifying those involuntarily unemployed
bys upid (year): generate begin_job_loss = (activity ==  5) & (activity != activity[_n-1]) 

bys upid (year): generate spell_job_loss = cond(activity ==  5, sum(begin_job_loss), 0)
generate job_loss = 1 if  spell_job_loss == 1 & reason_change_p == 3
replace  job_loss  = 0 if activity == 1 | activity == 2 | activity == 3 | activity == 4

label values job_loss unemployed
 
 
drop begin_unemployment spell_unemployment length_male_unemployment begin_job_loss spell_job_loss

//Identifying women's labour supply increase
generate transition_work = 1 if response == 1 |  response == 3 | response == 2 | response == 4
replace transition_work = 0 if response ==  5 | response ==  8 

/****************MERGING THE DATA WITH THE MTRS AND NRSS************************
******************MTRS AND NRRS ARE ESTIMATED USING EUROMOD and the HHoT*******/

/**********************GENERATING THE VARIABLES NEEDED FOR MERGING**************/

 //Variable needed for merging: number of children (maximum 3 - using the HHoT we generate households with maxim 3 children); age of the three youngest children in the household (recoded so that it ranges from 0 to 18 with a 3 year step); men's''s employment; women's activity;
 
generate no_child = nchild 
replace no_child = 3 if no_child >3
generate  child_1 = youngest_kid
generate  child_2 = secondyoungest_kid
generate  child_3 = thirdyoungest_kid

 recode child_1 (0/3=3) (4/6=6) (7/9=9) (10/12=12) (13/15=15) (16/18=18)
 replace child_1 = 0 if child_1 ==.
 recode child_2 (0/3=3) (4/6=6) (7/9=9) (10/12=12) (13/15=15) (16/18=18) 
 replace child_2 = 0 if child_2 ==.
 recode child_3 (0/3=3) (4/6=6) (7/9=9) (10/12=12) (13/15=15) (16/18=18)
 replace child_3 = 0 if child_3 ==.
 

generate husband_employment = 3 if activity == 1 | activity == 2 | activity == 3 | activity == 4
replace husband_employment = 5 if activity == 5

 egen wife_unemployed = max(response == 5 & no_observation == 1), by (hhunique_no)
 egen wife_inactive = max(response ==  8 & no_observation == 1), by (hhunique_no)
 
 generate wife_employment = 5 if wife_unemployed != 0
 replace wife_employment = 7 if wife_inactive != 0 & wife_employment == .
 
  
/********************************MERGE WITH MTRS*******************************/
//Note: we generate MTRS for five wage levels. Nameley, an increase in woman's wage: 1. from not working(i.,e. inactive or unemployed) to 50 (part-time) or 100 (full-time) EU-SILC average wage; 2. from not working(i.,e. inactive or unemployed) to 25 (part-time) or 50 (full-time) EU-SILC average wage; 3. from not working(i.,e. inactive or unemployed) to 33 (part-time) or 67 (full-time) EU-SILC average wage; 4.from not working(i.,e. inactive or unemployed) to 75 (part-time) or 150 (full-time) EU-SILC average wage; 5. from not working(i.,e. inactive or unemployed) to 100 (part-time) or 200 (full-time) EU-SILC average wage.

 merge m:1 country year married no_child child_1 child_2 child_3 wife_employment husband_employment using "C:\Users\adm\Documents\WP.3.1. STUDIES\Contextual data\MTR_SAMPLE_1.dta"
drop if _merge==2
drop _merge

 
/*****************************MERGE WITH NRRS********************************/
 
//Note: we generate NRRS for five wage levels of men before unemployment. Nameley: 1. men's employment income 33% (when employed part-time) or 67% (when employed full-time) of EU-SILC average wage; 1. men's employment income 50% (when employed part-time) or 100% (when employed full-time) of EU-SILC average wage; 3. men's employment income 25% (when employed part-time) or 50% (when employed full-time) of EU-SILC average wage; 4. men's employment income 75% (when employed part-time) or 150% (when employed full-time) of EU-SILC average wage; 5. 1. men's employment income 100% (when employed part-time) or 200% (when employed full-time) of EU-SILC average wage
//Note:those inactive before unemployment spells are not assigned a NRR value

/*IN ORDER TO PROPERLY ASSIGN THE RRS VALUES WE GENERATE VARIABLES FOR THE EMPLOYMENT MEN HAD BEFORE THE UNEMPLOYMENT SPELLS*/

sort hhunique_no time
bys hhunique_no: generate unemp_after_FT_E = (activity ==  5) & (activity[_n-1] == 1) 
bys hhunique_no: generate spell_unemp_after_FT_E = cond(activity ==  5, sum(unemp_after_FT_E), 0)

bys hhunique_no: generate unemp_after_PT_E = (activity ==  5) & (activity[_n-1] == 2) 
bys hhunique_no: generate spell_unemp_after_PT_E = cond(activity ==  5 , sum(unemp_after_PT_E), 0)
  
bys hhunique_no: generate unemp_after_FT_Self = (activity ==  5) & (activity[_n-1] == 3) 
bys hhunique_no: generate spell_unemp_after_FT_Self = cond(activity ==  5, sum(unemp_after_FT_Self), 0)
 
bys hhunique_no: generate unemp_after_PT_Self = (activity ==  5) & (activity[_n-1] == 4) 
bys hhunique_no: generate spell_unemp_after_PT_Self = cond(activity ==  5, sum(unemp_after_PT_Self), 0)
 

bys hhunique_no (time): generate employment_before_unemp = 1 if spell_unemp_after_FT_E != 0
replace employment_before_unemp = 2 if spell_unemp_after_PT_E != 0
replace employment_before_unemp = 3 if spell_unemp_after_FT_Self != 0
replace employment_before_unemp = 3 if spell_unemp_after_PT_Self != 0
 
label define employment_before_unemp 1"Employee (full-time)" 2 "Employee (part-time)" 3 "Self-employed full-time" 4 "Self-employed part-time" 
label values employment_before_unemp employment_before_unemp
 
drop unemp_after_FT_E unemp_after_PT_E unemp_after_FT_Self unemp_after_PT_Self spell_unemp_after_FT_E spell_unemp_after_PT_E spell_unemp_after_FT_Self spell_unemp_after_PT_Self


merge m:1 country year married no_child child_1 child_2 child_3 employment_before_unemp wife_employment using "C:\Users\adm\Documents\WP.3.1. STUDIES\Contextual data\RR_SAMPLE_1.dta"
drop if _merge==2
drop _merge 


//We assign the value of 100 when the male partner continues being employed 
replace nrrpc_67_33 = 100 if activity == 1 | activity == 2 | activity == 3 | activity == 4
replace nrrpc_67_33 = . if activity == 13 | activity == 8

replace nrrpc_50_25 = 100 if activity == 1 | activity == 2 | activity == 3 | activity == 4
replace nrrpc_50_25 = . if activity == 13 | activity == 8

replace nrrpc_100_50 = 100 if activity == 1 | activity == 2 | activity == 3 | activity == 4
replace nrrpc_100_50 = . if activity == 13 | activity == 8

replace nrrpc_150_75 = 100 if activity == 1 | activity == 2 | activity == 3 | activity == 4
replace nrrpc_150_75 = . if activity == 13 | activity == 8

replace nrrpc_200_100 = 100 if activity == 1 | activity == 2 | activity == 3 | activity == 4
replace nrrpc_200_100 = . if activity == 13 | activity == 8

/***THE HHT AND EUROMODE DOES NOT ALLOW COMPUTING THE MTRS AND NRRS FOR HR, YEAR 2010, SO WE DROP IT*/
drop if country == "HR" & year == 2010

 save "$years_path\EU_SILC_Employed_No_work", replace
 

 
/******************************************************************************
********************SAMPLE HUSBAND EMPLOYED WIFE PART-TIME*********************
*******************************************************************************/

 clear
 use "$years_path\EU_SILC_PLOS_One_Country_Variables.dta", clear

 /*Keeping only couples in which the man is employed and the woman is out of work in first month of observation*/
 egen time = group(year month)
 sort hhunique  time
 bysort hhunique (time): gen no_observation = _n
 
 egen to_keep = max((no_observation == 1) & (activity == 1 | activity == 2 | activity == 3 | activity == 4) & (response == 2 | response == 4)), by(hhunique)
 drop if to_keep != 1
 drop to_keep 
 /*Drop oservations with missings on women's occupation*/
  drop if occupation_woman == .
 
 /*Sort the data by household and time*/
 encode  hhunique, generate(hhunique_no)
 sort hhunique_no time
 xtset hhunique_no time 
 
 //Identifying the unemployment spells that last for at least 3 months
 bys hhunique_no (time): generate begin_unemployment = (activity ==  5) & (activity != activity[_n-1])
 bys hhunique_no (time): generate spell_unemployment = cond(activity ==  5, sum(begin_unemployment), 0)
 by hhunique_no spell_unemployment(time), sort: gen length_male_unemployment = _N

 generate unemployed3m = 1 if activity ==  5 & length_male_unemployment >= 3
 replace unemployed3m  = 0 if activity == 1 | activity == 2 | activity == 3 | activity == 4
 replace unemployed3m  = 0 if activity ==  5 & length_male_unemployment <=2
 label define unemployed 1"Man unemployed" 0"Man employed"
 label values unemployed3m unemployed

 //Identifying the unemployment spells that last for between 3 and 6 months
 generate unemployed3_6m = 1 if activity ==  5 & (length_male_unemployment >= 3 & length_male_unemployment <= 6)
 replace unemployed3_6m  = 0 if activity == 1 | activity == 2 | activity == 3 | activity == 4
 replace unemployed3_6m  = 0 if activity ==  5 & length_male_unemployment <= 2
 replace unemployed3_6m  = . if activity ==  5 & length_male_unemployment >= 7 

 label values unemployed3_6m unemployed

  //Identifying the unemployment spells that last more than 6 months
 generate unemployed_over_6m = 1 if activity ==  5 & length_male_unemployment > 6
 replace unemployed_over_6m  = 0 if activity == 1 | activity == 2 | activity == 3 | activity == 4
 replace unemployed_over_6m  = . if activity == 5 & length_male_unemployment <=6
 replace unemployed_over_6m  = 0 if activity ==  5 & length_male_unemployment <= 2

 label values unemployed_over_6m unemployed

 //Identifying those involuntarily unemployed
 bys upid (year): generate begin_job_loss = (activity ==  5) & (activity != activity[_n-1]) 

 bys upid (year): generate spell_job_loss = cond(activity ==  5, sum(begin_job_loss), 0)
 generate job_loss = 1 if  spell_job_loss == 1 & reason_change_p == 3
replace  job_loss  = 0 if activity == 1 | activity == 2 | activity == 3 | activity == 4

 
label values job_loss unemployed

drop begin_unemployment spell_unemployment length_male_unemployment begin_job_loss spell_job_loss

//Identifying women's labour supply increase
generate transition_FT = 1 if response == 1 |  response == 3 
replace transition_FT = 0 if response == 2 | response == 4

  

/****************MERGING THE DATA WITH THE MTRS AND NRSS************************
******************MTRS AND NRRS ARE ESTIMATED USING EUROMOD and the HHoT*******/

/**********************GENERATING THE VARIABLES NEEDED FOR MERGING**************/

 //Variable needed for merging: number of children (maximum 3 - using the HHoT we generate households with maxim 3 children); age of the three youngest children in the household (recoded so that it ranges from 0 to 18 with a 3 year step); men's''s employment; women's activity;
 
generate no_child = nchild 
replace no_child = 3 if no_child >3
generate  child_1 = youngest_kid
generate  child_2 = secondyoungest_kid
generate  child_3 = thirdyoungest_kid

 recode child_1 (0/3=3) (4/6=6) (7/9=9) (10/12=12) (13/15=15) (16/18=18)
 replace child_1 = 0 if child_1 ==.
 recode child_2 (0/3=3) (4/6=6) (7/9=9) (10/12=12) (13/15=15) (16/18=18) 
 replace child_2 = 0 if child_2 ==.
 recode child_3 (0/3=3) (4/6=6) (7/9=9) (10/12=12) (13/15=15) (16/18=18)
 replace child_3 = 0 if child_3 ==.
 

generate husband_employment = 3 if activity == 1 | activity == 2 | activity == 3 | activity == 4
replace husband_employment = 5 if activity == 5

 /********************************MERGE WITH MTRS*******************************/
//Note: we generate MTRS for five wage levels. Nameley, an increase in woman's wage: 1. from 50 (part-time) to 100 (full-time) of EU-SILC average wage; 2. from 25 (part-time) to 50 (full-time) of EU-SILC average wage; 3. from 33 (part-time) to 67 (full-time) of EU-SILC average wage; 4.from 75 (part-time) to 150 (full-time) of EU-SILC average wage; 5. from 100 (part-time) to 200 (full-time) of EU-SILC average wage. 


merge m:1 country year married no_child child_1 child_2 child_3 husband_employment using "C:\Users\adm\Documents\WP.3.1. STUDIES\Contextual data\MTR_SAMPLE_2.dta"
drop if _merge==2
drop _merge


/*****************************MERGE WITH NRRS********************************/
 
//Note: we generate NRRS for five wage levels of men before unemployment. Nameley: 1. men's employment income 33% (when employed part-time) or 67% (when employed full-time) of EU-SILC average wage; 1. men's employment income 50% (when employed part-time) or 100% (when employed full-time) of EU-SILC average wage; 3. men's employment income 25% (when employed part-time) or 50% (when employed full-time) of EU-SILC average wage; 4. men's employment income 75% (when employed part-time) or 150% (when employed full-time) of EU-SILC average wage; 5. 1. men's employment income 100% (when employed part-time) or 200% (when employed full-time) of EU-SILC average wage
//Note:those inactive before unemployment spells are not assigned a NRR value

/*IN ORDER TO PROPERLY ASSIGN THE RRS VALUES WE GENERATE VARIABLES FOR THE EMPLOYMENT MEN HAD BEFORE THE UNEMPLOYMENT SPELLS*/

bys hhunique_no (time): generate unemp_after_FT_E = (activity ==  5) & (activity[_n-1] == 1) 
bys hhunique_no (time): generate spell_unemp_after_FT_E = cond(activity ==  5, sum(unemp_after_FT_E), 0)

bys hhunique_no (time): generate unemp_after_PT_E = (activity ==  5) & (activity[_n-1] == 2) 
bys hhunique_no (time): generate spell_unemp_after_PT_E = cond(activity ==  5 , sum(unemp_after_PT_E), 0)
  
bys hhunique_no (time): generate unemp_after_FT_Self = (activity ==  5) & (activity[_n-1] == 3) 
bys hhunique_no (time): generate spell_unemp_after_FT_Self = cond(activity ==  5, sum(unemp_after_FT_Self), 0)
 
bys hhunique_no (time): generate unemp_after_PT_Self = (activity ==  5) & (activity[_n-1] == 4) 
bys hhunique_no (time): generate spell_unemp_after_PT_Self = cond(activity ==  5, sum(unemp_after_PT_Self), 0)
 
 bys hhunique_no (time): generate employment_before_unemp = 1 if spell_unemp_after_FT_E != 0
 replace employment_before_unemp = 2 if spell_unemp_after_PT_E != 0
 replace employment_before_unemp = 3 if spell_unemp_after_FT_Self != 0
 replace employment_before_unemp = 3 if spell_unemp_after_PT_Self != 0
 
label define employment_before_unemp 1"Employee (full-time)" 2 "Employee (part-time)" 3 "Self-employed full-time" 4 "Self-employed part-time" 
label values employment_before_unemp employment_before_unemp
 
 drop unemp_after_FT_E unemp_after_PT_E unemp_after_FT_Self unemp_after_PT_Self spell_unemp_after_FT_E spell_unemp_after_PT_E spell_unemp_after_FT_Self spell_unemp_after_PT_Self

 merge m:1 country year married no_child child_1 child_2 child_3 employment_before_unemp wife_employment using "C:\Users\adm\Documents\WP.3.1. STUDIES\Contextual data\RR_SAMPLE_2.dta"
 drop if _merge==2
 drop _merge


//We assign the value of 100 when the male partner continues being employed 
replace nrrpc_67_33 = 100 if nrrpc_67_33 == .
replace nrrpc_67_33 = . if activity == 13 | activity == 8


replace nrrpc_50_25 = 100 if nrrpc_50_25 == .
replace nrrpc_50_25 = . if activity == 13 | activity == 8


replace nrrpc_100_50 = 100 if nrrpc_100_50 == .
replace nrrpc_100_50 = . if activity == 13 | activity == 8

replace nrrpc_150_75 = 100 if nrrpc_150_75 == .
replace nrrpc_150_75 = . if activity == 13 | activity == 8

replace nrrpc_200_100 = 100 if nrrpc_200_100 == .
replace nrrpc_200_100 = . if activity == 13 | activity == 8
/***THE HHT AND EUROMODE DOES NOT ALLOW COMPUTING THE MTRS AND NRRS FOR HR, YEAR 2010, SO WE DROP IT*/
drop if country == "HR" & year == 2010

 save "$years_path\EU_SILC_Employed_Part_time", replace

 