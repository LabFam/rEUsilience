

 
  /******************************************************************************
 ***********************************HYPOTHESIS 3**********************************
 *******************************************************************************/
 
  
  /***************GENERAL MEASURE OF CHILDCARE*****************/ 
 
   /******************************************************************************
 ***********************************SAMPLE 1*************************************
 *******************************************************************************/

 clear 
 set more off
 cd "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 global years_path "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 use "$years_path\EU_SILC_Employed_No_work", clear 
 
 global control_HH_S1 "i.married nchild i.child0_3 i.child4_6 i.child7_12 i.quintile age age_p i.education_woman i.education_man i.occupation_man"
 global  control_country "share_women_responsibility share_men_responsibility female_participation unemployment_rate"
 global his_unemp "i.unemployed3m"
  replace nrrpc_67_33 = 100 if unemployed3m == 0
 replace unemployed3m = . if nrrpc_67_33 == .
 
 mixed transition_work $his_unemp##i.child0_3##c.childcare_0_3_G $his_unemp##i.child4_6##c.childcare_4_6_G $his_unemp##i.child7_12##c.childcare_7_12_G $control_HH_S1 $control_country || country:, vce(robust)
 estimates store S1H3_3M_CareG
   
 margins $his_unemp, at(childcare_0_3_G=(0(10)70) child0_3=1)
 marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure a") xtitle("Childcare 0-3") ytitle("Pr(NW -> E)") name(S1_Care_MTR_FT_0_3_G)
 graph save S1_CHILDCARE_GENERAL_0_3, replace
 
 margins $his_unemp, at(childcare_4_6_G=(0(10)80) child4_6=1)
marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure b") xtitle("Childcare 4-6") ytitle("Pr(NW -> E)") name(S1_Care_MTR_FT_4_6_G)
 graph save S1_CHILDCARE_GENERAL_4_6, replace

 margins $his_unemp, at(childcare_7_12_G=(0(10)60) child7_12=1)
marginsplot, recast(line) recastci(rarea) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure c") xtitle("Childcare 7-12") ytitle("Pr(NW -> E)") name(S1_Care_MTR_FT_7_12_G)
 graph save S1_CHILDCARE_GENERAL_7_12, replace


 /******************************************************************************
 ***********************************SAMPLE 2*************************************
 *******************************************************************************/


 clear 
 set more off
 cd "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 global years_path "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 
 use "$years_path\EU_SILC_Employed_Part_time", clear 
  
 global control_HH_S2 "i.married nchild i.child0_3 i.child4_6 i.child7_12 i.quintile age age_p i.education_woman i.education_man i.occupation_man i.occupation_woman"
 global  control_country "share_women_responsibility share_men_responsibility female_participation unemployment_rate"
 global his_unemp "i.unemployed3m"
 
  replace nrrpc_67_33 = 100 if unemployed3m == 0
 replace unemployed3m = . if nrrpc_67_33 == .
 

 /***************GENERAL MEASURE OF CHILDCARE*****************/ 

 mixed transition_FT $his_unemp##i.child0_3##c.childcare_0_3_G $his_unemp##i.child4_6##c.childcare_4_6_G $his_unemp3m##i.child7_12##c.childcare_7_12_G $control_HH_S2 $control_country || country:, vce(robust)
 estimates store S2H3_3M_CareG_MTR
   
 margins $his_unemp, at(childcare_0_3_G=(0(10)70) child0_3=1)
 marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure d") xtitle("Childcare 0-3") ytitle("Pr(PT -> FT)") name(S2_Care_MTR_FT_0_3_G)
  graph save S2_CHILDCARE_GENERAL_0_3, replace
 
 margins $his_unemp, at(childcare_4_6_G=(0(10)80) child4_6=1)
marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure e") xtitle("Childcare 4-6") ytitle("Pr(PT -> FT)") name(S2_Care_MTR_FT_4_6_G)
 graph save S2_CHILDCARE_GENERAL_4_6, replace

 margins $his_unemp, at(childcare_7_12_G=(0(10)60) child7_12=1)
marginsplot, recast(line) recastci(rarea) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure f") xtitle("Childcare 7-12") ytitle("Pr(PT -> FT)") name(S2_Care_MTR_FT_7_12_G)
 graph save S2_CHILDCARE_GENERAL_7_12, replace
 
grc1leg  S1_Care_MTR_FT_0_3_G S1_Care_MTR_FT_4_6_G S1_Care_MTR_FT_7_12_G, legendfrom(S1_Care_MTR_FT_0_3_G) title(NW -> E) graphregion(color(white))  name(grcol1,replace) row(3)
grc1leg   S2_Care_MTR_FT_0_3_G S2_Care_MTR_FT_4_6_G S2_Care_MTR_FT_7_12_G, legendfrom(S2_Care_MTR_FT_0_3_G) title(PT -> FT) graphregion(color(white))  name(grcol2,replace) row(3)
grc1leg   grcol1 grcol2, legendfrom(grcol1) col(2) graphregion(color(white)) altshrink  graphregion(margin(l=10 r=10)) 
 graph save Childcare_General_3_MONTHS, replace
 graph export "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE\Childcare_General_3_MONTHS.tif", width(2250) height(1750) replace
 
/**95 CI; MTRS NW-> FT*/



  
  /***************PART-TIME MEASURE OF CHILDCARE*****************/ 
  
   /******************************************************************************
 ***********************************SAMPLE 1*************************************
 *******************************************************************************/
 clear 
 set more off
 cd "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 global years_path "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 use "$years_path\EU_SILC_Employed_No_work", clear 
 
 global control_HH_S1 "i.married nchild i.child0_3 i.child4_6 i.child7_12 i.quintile age age_p i.education_woman i.education_man i.occupation_man"
 global  control_country "share_women_responsibility share_men_responsibility female_participation unemployment_rate"
 global his_unemp "i.unemployed3m"

 
 mixed transition_work $his_unemp##i.child0_3##c.childcare_0_3_PT $his_unemp##i.child4_6##c.childcare_4_6_PT $his_unemp##i.child7_12##c.childcare_7_12_PT $control_HH_S1 $control_country || country:, vce(robust)

   
 
 margins $his_unemp, at(childcare_0_3_PT=(0(10)70) child0_3=1)
 marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure a") xtitle("Childcare 0-3 (part-time)") ytitle("Pr(NW -> E)") name(S1_Care_MTR_FT_0_3_PT)
 graph save S1_Care_MTR_FT_0_3_PT, replace
 
 margins $his_unemp, at(childcare_4_6_PT=(0(10)80) child4_6=1)
 marginsplot, recast(line) recastci(rarea)  allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure b") xtitle("Childcare 4-6 (part-time)") ytitle("Pr(NW -> E)") name(S1_Care_MTR_FT_4_6_PT)
 graph save S1_Care_MTR_FT_4_6_PT, replace
 
 margins $his_unemp, at(childcare_7_12_PT=(0(10)60) child7_12=1)
 marginsplot, recast(line) recastci(rarea) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure c") xtitle("Childcare 7-12 (part-time)") ytitle("Pr(NW -> E)") name(S1_Care_MTR_FT_7_12_PT)
 graph save S1_Care_MTR_FT_7_12_PT, replace
  
  
   
   /******************************************************************************
 ***********************************SAMPLE 2*************************************
 *******************************************************************************/
  
 clear 
 set more off
 cd "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 global years_path "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 
 use "$years_path\EU_SILC_Employed_Part_time", clear 
  
 global control_HH_S2 "i.married nchild i.child0_3 i.child4_6 i.child7_12 i.quintile age age_p i.education_woman i.education_man i.occupation_man i.occupation_woman"
 global  control_country "share_women_responsibility share_men_responsibility female_participation unemployment_rate"
 global his_unemp "i.unemployed3m"

  replace nrrpc_67_33 = 100 if unemployed3m == 0
 replace unemployed3m = . if nrrpc_67_33 == .
  
  /***************PART-TIME MEASURE OF CHILDCARE*****************/ 
 
 mixed transition_FT $his_unemp##i.child0_3##c.childcare_0_3_PT $his_unemp##i.child4_6##c.childcare_4_6_PT $his_unemp##i.child7_12##c.childcare_7_12_PT $control_HH_S2 $control_country || country:, vce(robust)

   
 
 margins $his_unemp, at(childcare_0_3_PT=(0(10)70) child0_3=1)
 marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure d") xtitle("Childcare 0-3 (part-time)") ytitle("Pr(PT -> FT)") name(S2_Care_MTR_FT_0_3_PT)
  graph save  S2_Care_MTR_FT_0_3_PT, replace 
 
 margins $his_unemp, at(childcare_4_6_PT=(0(10)80) child4_6=1)
 marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure e") xtitle("Childcare 4-6 (part-time)") ytitle("Pr(PT -> FT)") name(S2_Care_MTR_FT_4_6_PT)
 graph save S2_Care_MTR_FT_4_6_PT, replace
 
 margins $his_unemp, at(childcare_7_12_PT=(0(10)60) child7_12=1)
 marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure f") xtitle("Childcare 7-12 (part-time)") ytitle("Pr(PT -> FT)") name(S2_Care_MTR_FT_7_12_PT)
graph save S2_Care_MTR_FT_7_12_PT, replace
  

 grc1leg  S1_Care_MTR_FT_0_3_PT S1_Care_MTR_FT_4_6_PT S1_Care_MTR_FT_7_12_PT, legendfrom(S1_Care_MTR_FT_0_3_PT) title(NW -> E) graphregion(color(white))  name(grcol1,replace) row(3)
 grc1leg  S2_Care_MTR_FT_0_3_PT S2_Care_MTR_FT_4_6_PT S2_Care_MTR_FT_7_12_PT, legendfrom(S2_Care_MTR_FT_0_3_PT) title(PT -> FT) graphregion(color(white))  name(grcol2,replace) row(3)
 grc1leg  grcol1 grcol2, legendfrom(grcol1) col(2) graphregion(color(white)) altshrink  graphregion(margin(l=10 r=10)) 
 graph save Childcare_PT_3_MONTHS, replace

  
  graph export "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE\Childcare_PT_3_MONTHS.tif", width(2250) height(1750) replace
  
 
/**95 CI; MTRS NW-> FT*/

  
 
  
  
   /***************FULL-TIME MEASURE OF CHILDCARE*****************/ 
   
      /******************************************************************************
 ***********************************SAMPLE 1*************************************
 *******************************************************************************/
 clear 
 set more off
 cd "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 global years_path "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 use "$years_path\EU_SILC_Employed_No_work", clear 
 
 global control_HH_S1 "i.married nchild i.child0_3 i.child4_6 i.child7_12 i.quintile age age_p i.education_woman i.education_man i.occupation_man"
 global  control_country "share_women_responsibility share_men_responsibility female_participation unemployment_rate"
 global his_unemp "i.unemployed3m"
 
 mixed transition_work $his_unemp##i.child0_3##c.childcare_0_3_FT $his_unemp##i.child4_6##c.childcare_4_6_FT $his_unemp##i.child7_12##c.childcare_7_12_FT $control_HH_S1 $control_country  || country:, vce(robust)

 
 margins $his_unemp, at(childcare_0_3_FT=(0(10)70) child0_3=1)
marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure a") xtitle("Childcare 0-3 (full-time)") ytitle("Pr(NW -> E)") name(S1_Care_MTR_FT_0_3_FT)
 graph save S1_Care_MTR_FT_0_3_FT, replace
 
 margins $his_unemp, at(childcare_4_6_FT=(0(10)80) child4_6=1)
 marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure b") xtitle("Childcare 4-6 (full-time)") ytitle("Pr(NW -> E)") name(S1_Care_MTR_FT_4_6_FT)
  graph save S1_Care_MTR_FT_4_6_FT, replace
 
 margins $his_unemp, at(childcare_7_12_FT=(0(10)60) child7_12=1)
 marginsplot, recast(line) recastci(rarea) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure c") xtitle("Childcare 7-12 (full-time)") ytitle("Pr(NW -> E)") name(S1_Care_MTR_FT_7_12_FT)
  graph save S1_Care_MTR_FT_7_12_FT, replace
 
 
  
 /******************************************************************************
 ***********************************SAMPLE 2*************************************
 *******************************************************************************/

 clear 
 set more off
 cd "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 global years_path "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 
 use "$years_path\EU_SILC_Employed_Part_time", clear 
  
 global control_HH_S2 "i.married nchild i.child0_3 i.child4_6 i.child7_12 i.quintile age age_p i.education_woman i.education_man i.occupation_man i.occupation_woman"
 global  control_country "share_women_responsibility share_men_responsibility female_participation unemployment_rate"
 global his_unemp "i.unemployed3m"

 
   /***************FULL-TIME MEASURE OF CHILDCARE*****************/ 
 
 mixed transition_FT $his_unemp##i.child0_3##c.childcare_0_3_FT $his_unemp##i.child4_6##c.childcare_4_6_FT $his_unemp##i.child7_12##c.childcare_7_12_FT $control_HH_S2 $control_country  || country:, vce(robust)

   
 margins $his_unemp, at(childcare_0_3_FT=(0(10)70) child0_3=1)
marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure d") xtitle("Childcare 0-3 (full-time)") ytitle("Pr(PT -> FT)") name(S2_Care_MTR_FT_0_3_FT)
   graph save S2_Care_MTR_FT_0_3_FT, replace
 
 margins $his_unemp, at(childcare_4_6_FT=(0(10)80) child4_6=1)
 marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure e") xtitle("Childcare 4-6 (full-time)") ytitle("Pr(PT -> FT)") name(S2_Care_MTR_FT_4_6_FT)
  graph save S2_Care_MTR_FT_4_6_FT, replace
 
 margins $his_unemp, at(childcare_7_12_FT=(0(10)60) child7_12=1)
 marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure f") xtitle("Childcare 7-12 (full-time)") ytitle("Pr(PT -> FT)") name(S2_Care_MTR_FT_7_12_FT)
  
graph save S2_Care_MTR_FT_7_12_FT, replace

 grc1leg  S1_Care_MTR_FT_0_3_FT S1_Care_MTR_FT_4_6_FT S1_Care_MTR_FT_7_12_FT, legendfrom(S1_Care_MTR_FT_0_3_FT) title(NW -> E) graphregion(color(white))  name(grcol1,replace) row(3)
 grc1leg   S2_Care_MTR_FT_0_3_FT S2_Care_MTR_FT_4_6_FT S2_Care_MTR_FT_7_12_FT, legendfrom(S2_Care_MTR_FT_0_3_FT) title(PT -> FT) graphregion(color(white))  name(grcol2,replace) row(3)
 grc1leg   grcol1 grcol2, legendfrom(grcol1) col(2) graphregion(color(white)) altshrink  graphregion(margin(l=10 r=10)) 
 graph save Childcare_FT_3_MONTHS, replace

   graph export "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE\Childcare_FT_3_MONTHS.tif", width(2250) height(1750) replace
  
  
  
  
  
  
/*******************************************************************************
 ***************UNEMPLOYMENT SPELLS BETWEEN 3 AND 6 MONTHS *********************
 *******************************************************************************/
  
  /***************GENERAL MEASURE OF CHILDCARE*****************/ 
 
   /******************************************************************************
 ***********************************SAMPLE 1*************************************
 *******************************************************************************/

 clear 
 set more off
 cd "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 global years_path "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 use "$years_path\EU_SILC_Employed_No_work", clear 
 
 global control_HH_S1 "i.married nchild i.child0_3 i.child4_6 i.child7_12 i.quintile age age_p i.education_woman i.education_man i.occupation_man"
 global  control_country "share_women_responsibility share_men_responsibility female_participation unemployment_rate"
 global his_unemp "i.unemployed3_6m"
  replace nrrpc_67_33 = 100 if unemployed3_6m == 0
 replace unemployed3_6m = . if nrrpc_67_33 == .
 
 mixed transition_work $his_unemp##i.child0_3##c.childcare_0_3_G $his_unemp##i.child4_6##c.childcare_4_6_G $his_unemp##i.child7_12##c.childcare_7_12_G $control_HH_S1 $control_country || country:, vce(robust)
 estimates store S1H3_3M_CareG
   
 margins $his_unemp, at(childcare_0_3_G=(0(10)70) child0_3=1)
 marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure a") xtitle("Childcare 0-3") ytitle("Pr(NW -> E)") name(S1_Care_MTR_FT_0_3_G)
 graph save S1_GENERAL_0_3_3_6M, replace
 
 margins $his_unemp, at(childcare_4_6_G=(0(10)80) child4_6=1)
marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure b") xtitle("Childcare 4-6") ytitle("Pr(NW -> E)") name(S1_Care_MTR_FT_4_6_G)
 graph save S1_GENERAL_4_6_3_6M, replace

 margins $his_unemp, at(childcare_7_12_G=(0(10)60) child7_12=1)
marginsplot, recast(line) recastci(rarea) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure c") xtitle("Childcare 7-12") ytitle("Pr(NW -> E)") name(S1_Care_MTR_FT_7_12_G)
 graph save S1_GENERAL_7_12_3_6M, replace


 /******************************************************************************
 ***********************************SAMPLE 2*************************************
 *******************************************************************************/


 clear 
 set more off
 cd "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 global years_path "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 
 use "$years_path\EU_SILC_Employed_Part_time", clear 
  
 global control_HH_S2 "i.married nchild i.child0_3 i.child4_6 i.child7_12 i.quintile age age_p i.education_woman i.education_man i.occupation_man i.occupation_woman"
 global  control_country "share_women_responsibility share_men_responsibility female_participation unemployment_rate"
 global his_unemp "i.unemployed3_6m"
 
 replace nrrpc_67_33 = 100 if unemployed3_6m == 0
 replace unemployed3_6m = . if nrrpc_67_33 == .
 

 /***************GENERAL MEASURE OF CHILDCARE*****************/ 

 mixed transition_FT $his_unemp##i.child0_3##c.childcare_0_3_G $his_unemp##i.child4_6##c.childcare_4_6_G $his_unemp3m##i.child7_12##c.childcare_7_12_G $control_HH_S2 $control_country || country:, vce(robust)
 estimates store S2H3_3M_CareG_MTR
   
 margins $his_unemp, at(childcare_0_3_G=(0(10)70) child0_3=1)
 marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure d") xtitle("Childcare 0-3") ytitle("Pr(PT -> FT)") name(S2_Care_MTR_FT_0_3_G)
  graph save S2_GENERAL_0_3_3_6M, replace
 
 margins $his_unemp, at(childcare_4_6_G=(0(10)80) child4_6=1)
marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6))  level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure e") xtitle("Childcare 4-6") ytitle("Pr(PT -> FT)") name(S2_Care_MTR_FT_4_6_G)
 graph save S2_GENERAL_4_6_3_6M, replace

 margins $his_unemp, at(childcare_7_12_G=(0(10)60) child7_12=1)
marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure f") xtitle("Childcare 7-12") ytitle("Pr(PT -> FT)") name(S2_Care_MTR_FT_7_12_G)
 graph save S2_GENERAL_7_12_3_6M, replace
 
  
 grc1leg  S1_Care_MTR_FT_0_3_G S1_Care_MTR_FT_4_6_G S1_Care_MTR_FT_7_12_G, legendfrom(S1_Care_MTR_FT_0_3_G) title(NW -> E) graphregion(color(white))  name(grcol1,replace) row(3)
 grc1leg  S2_Care_MTR_FT_0_3_G S2_Care_MTR_FT_4_6_G S2_Care_MTR_FT_7_12_G, legendfrom(S2_Care_MTR_FT_0_3_G) title(PT -> FT) graphregion(color(white))  name(grcol2,replace) row(3)
 grc1leg   grcol1 grcol2, legendfrom(grcol1) col(2) graphregion(color(white)) altshrink  graphregion(margin(l=10 r=10)) 
 graph save Childcare_General_3_6_MONTHS, replace
  
    graph export "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE\Childcare_General_3_6_MONTHS.tif", width(2250) height(1750) replace
 
  
  /***************PART-TIME MEASURE OF CHILDCARE*****************/ 
  
   /******************************************************************************
 ***********************************SAMPLE 1*************************************
 *******************************************************************************/
 clear 
 set more off
 cd "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 global years_path "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 use "$years_path\EU_SILC_Employed_No_work", clear 
 
 global control_HH_S1 "i.married nchild i.child0_3 i.child4_6 i.child7_12 i.quintile age age_p i.education_woman i.education_man i.occupation_man"
 global  control_country "share_women_responsibility share_men_responsibility female_participation unemployment_rate"
 global his_unemp "i.unemployed3_6m"
 
 replace nrrpc_67_33 = 100 if unemployed3_6m == 0
 replace unemployed3_6m = . if nrrpc_67_33 == .
 
 mixed transition_work $his_unemp##i.child0_3##c.childcare_0_3_PT $his_unemp##i.child4_6##c.childcare_4_6_PT $his_unemp##i.child7_12##c.childcare_7_12_PT $control_HH_S1 $control_country || country:, vce(robust)

 
 margins $his_unemp, at(childcare_0_3_PT=(0(10)70) child0_3=1)
 marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure a") xtitle("Childcare 0-3 (part-time)") ytitle("Pr(NW -> E)") name(S1_PT_0_3_3_6M)
 graph save S1_PT_0_3_3_6M, replace
 
 margins $his_unemp, at(childcare_4_6_PT=(0(10)80) child4_6=1)
 marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure b") xtitle("Childcare 4-6 (part-time)") ytitle("Pr(NW -> E)") name(S1_PT_4_6_3_6M)
 graph save S1_PT_4_6_3_6M, replace
 
 margins $his_unemp, at(childcare_7_12_PT=(0(10)60) child7_12=1)
 marginsplot, recast(line) recastci(rarea)  allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure c") xtitle("Childcare 7-12 (part-time)") ytitle("Pr(NW -> E)") name(S1_PT_7_12_3_6M)
 graph save S1_PT_7_12_3_6M, replace
  
  
   
   /******************************************************************************
 ***********************************SAMPLE 2*************************************
 *******************************************************************************/
  
 clear 
 set more off
 cd "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 global years_path "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 
 use "$years_path\EU_SILC_Employed_Part_time", clear 
  
 global control_HH_S2 "i.married nchild i.child0_3 i.child4_6 i.child7_12 i.quintile age age_p i.education_woman i.education_man i.occupation_man i.occupation_woman"
 global  control_country "share_women_responsibility share_men_responsibility female_participation unemployment_rate"
 global his_unemp "i.unemployed3_6m"
 
 replace nrrpc_67_33 = 100 if unemployed3_6m == 0
 replace unemployed3_6m = . if nrrpc_67_33 == .
  /***************PART-TIME MEASURE OF CHILDCARE*****************/ 
 
 mixed transition_FT $his_unemp##i.child0_3##c.childcare_0_3_PT $his_unemp##i.child4_6##c.childcare_4_6_PT $his_unemp##i.child7_12##c.childcare_7_12_PT $control_HH_S2 $control_country || country:, vce(robust)

  
 margins $his_unemp, at(childcare_0_3_PT=(0(10)70) child0_3=1)
 marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure d") xtitle("Childcare 0-3 (part-time)") ytitle("Pr(PT -> FT)") name(S2_PT_0_3_3_6M)
  graph save  S2_PT_0_3_3_6M, replace 
 
 margins $his_unemp, at(childcare_4_6_PT=(0(10)80) child4_6=1)
 marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure e") xtitle("Childcare 4-6 (part-time)") ytitle("Pr(PT -> FT)") name(S2_PT_4_6_3_6M)
 graph save S2_PT_4_6_3_6M, replace
 
 margins $his_unemp, at(childcare_7_12_PT=(0(10)60) child7_12=1)
 marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure f") xtitle("Childcare 7-12 (part-time)") ytitle("Pr(PT -> FT)") name(S2_PT_7_12_3_6M)
graph save S2_PT_7_12_3_6M, replace
  
    
 grc1leg  S1_PT_0_3_3_6M S1_PT_4_6_3_6M S1_PT_7_12_3_6M,  legendfrom(S1_PT_0_3_3_6M) title(NW -> E) graphregion(color(white))  name(grcol1,replace) row(3)
 grc1leg S2_PT_0_3_3_6M S2_PT_4_6_3_6M S2_PT_7_12_3_6M, legendfrom(S2_PT_0_3_3_6M) title(PT -> FT) graphregion(color(white))  name(grcol2,replace) row(3)
 grc1leg   grcol1 grcol2, legendfrom(grcol1) col(2) graphregion(color(white)) altshrink  graphregion(margin(l=10 r=10)) 
 graph save Childcare_PT_3_6_MONTHS, replace
  
 graph export "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE\Childcare_PT_3_6_MONTHS.tif", width(2250) height(1750) replace
 
   /***************FULL-TIME MEASURE OF CHILDCARE*****************/ 
   
      /******************************************************************************
 ***********************************SAMPLE 1*************************************
 *******************************************************************************/
 clear 
 set more off
 cd "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 global years_path "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 use "$years_path\EU_SILC_Employed_No_work", clear 
 
 global control_HH_S1 "i.married nchild i.child0_3 i.child4_6 i.child7_12 i.quintile age age_p i.education_woman i.education_man i.occupation_man"
 global  control_country "share_women_responsibility share_men_responsibility female_participation unemployment_rate"
 global his_unemp "i.unemployed3_6m"
 
 replace nrrpc_67_33 = 100 if unemployed3_6m == 0
 replace unemployed3_6m = . if nrrpc_67_33 == .
 
 mixed transition_work $his_unemp##i.child0_3##c.childcare_0_3_FT $his_unemp##i.child4_6##c.childcare_4_6_FT $his_unemp##i.child7_12##c.childcare_7_12_FT $control_HH_S1 $control_country  || country:, vce(robust)

 
 margins $his_unemp, at(childcare_0_3_FT=(0(10)70) child0_3=1)
marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83)  ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure a") xtitle("Childcare 0-3 (full-time)") ytitle("Pr(NW -> E)") name(S1_FT_0_3_3_6M)
 graph save S1_FT_0_3_3_6M, replace
 
 margins $his_unemp, at(childcare_4_6_FT=(0(10)80) child4_6=1)
 marginsplot, recast(line) recastci(rarea) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83)  ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure b") xtitle("Childcare 4-6 (full-time)") ytitle("Pr(NW -> E)") name(S1_FT_4_6_3_6M)
  graph save S1_FT_4_6_3_6M, replace
 
 margins $his_unemp, at(childcare_7_12_FT=(0(10)60) child7_12=1)
 marginsplot, recast(line) recastci(rarea) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83)  ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure c") xtitle("Childcare 7-12 (full-time)") ytitle("Pr(NW -> E)") name(S1_FT_7_12_3_6M)
  graph save S1_FT_7_12_3_6M, replace
 
 
  
 /******************************************************************************
 ***********************************SAMPLE 2*************************************
 *******************************************************************************/

 clear 
 set more off
 cd "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 global years_path "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 
 use "$years_path\EU_SILC_Employed_Part_time", clear 
  
 global control_HH_S2 "i.married nchild i.child0_3 i.child4_6 i.child7_12 i.quintile age age_p i.education_woman i.education_man i.occupation_man i.occupation_woman"
 global  control_country "share_women_responsibility share_men_responsibility female_participation unemployment_rate"
 global his_unemp "i.unemployed3_6m"
 
 replace nrrpc_67_33 = 100 if unemployed3_6m == 0
 replace unemployed3_6m = . if nrrpc_67_33 == .
 
 
   /***************FULL-TIME MEASURE OF CHILDCARE*****************/ 
 
 mixed transition_FT $his_unemp##i.child0_3##c.childcare_0_3_FT $his_unemp##i.child4_6##c.childcare_4_6_FT $his_unemp##i.child7_12##c.childcare_7_12_FT $control_HH_S2 $control_country  || country:, vce(robust)

   
 margins $his_unemp, at(childcare_0_3_FT=(0(10)70) child0_3=1)
marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83)  ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure d") xtitle("Childcare 0-3 (full-time)") ytitle("Pr(PT -> FT)") name(S2_FT_0_3_3_6M)
   graph save S2_FT_0_3_3_6M, replace
 
 margins $his_unemp, at(childcare_4_6_FT=(0(10)80) child4_6=1)
 marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83)  ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure e") xtitle("Childcare 4-6 (full-time)") ytitle("Pr(PT -> FT)") name(S2_FT_4_6_3_6M)
  graph save S2_FT_4_6_3_6M, replace
 
 margins $his_unemp, at(childcare_7_12_FT=(0(10)60) child7_12=1)
 marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83)  ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure f") xtitle("Childcare 7-12 (full-time)") ytitle("Pr(PT -> FT)") name(S2_FT_7_12_3_6M)
 graph save S2_FT_7_12_3_6M, replace
 

 grc1leg S1_FT_0_3_3_6M S1_FT_4_6_3_6M S1_FT_7_12_3_6M, legendfrom(S1_FT_0_3_3_6M) title(NW -> E) graphregion(color(white))  name(grcol1,replace) row(3)
 grc1leg S2_FT_0_3_3_6M S2_FT_4_6_3_6M S2_FT_7_12_3_6M, legendfrom(S2_FT_0_3_3_6M) title(PT -> FT) graphregion(color(white))  name(grcol2,replace) row(3)
 grc1leg   grcol1 grcol2, legendfrom(grcol1) col(2) graphregion(color(white)) altshrink  graphregion(margin(l=10 r=10)) 
 graph save Childcare_FT_3_6_MONTHS, replace
 
 graph export "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE\Childcare_FT_3_6_MONTHS.tif", width(2250) height(1750) replace
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
/*******************************************************************************
 ***************UNEMPLOYMENT SPELLS LONGER THAN 6 MONTHS *********************
 *******************************************************************************/
  
  /***************GENERAL MEASURE OF CHILDCARE*****************/ 
 
   /******************************************************************************
 ***********************************SAMPLE 1*************************************
 *******************************************************************************/

 clear 
 set more off
 cd "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 global years_path "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 use "$years_path\EU_SILC_Employed_No_work", clear 
 
 global control_HH_S1 "i.married nchild i.child0_3 i.child4_6 i.child7_12 i.quintile age age_p i.education_woman i.education_man i.occupation_man"
 global  control_country "share_women_responsibility share_men_responsibility female_participation unemployment_rate"
 global his_unemp "i.unemployed_over_6m"
  replace nrrpc_67_33 = 100 if unemployed_over_6m == 0
 replace unemployed_over_6m = . if nrrpc_67_33 == .
 
 mixed transition_work $his_unemp##i.child0_3##c.childcare_0_3_G $his_unemp##i.child4_6##c.childcare_4_6_G $his_unemp##i.child7_12##c.childcare_7_12_G $control_HH_S1 $control_country || country:, vce(robust)
 estimates store S1H3_3M_CareG
   
 margins $his_unemp, at(childcare_0_3_G=(0(10)70) child0_3=1)
 marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure a") xtitle("Childcare 0-3") ytitle("Pr(NW -> E)") name(S1_GENERAL_0_3_over_6M)
 graph save S1_GENERAL_0_3_over_6M, replace
 
 margins $his_unemp, at(childcare_4_6_G=(0(10)80) child4_6=1)
marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure b") xtitle("Childcare 4-6") ytitle("Pr(NW -> E)") name(S1_GENERAL_4_6_over_6M)
 graph save S1_GENERAL_4_6_over_6M, replace

 margins $his_unemp, at(childcare_7_12_G=(0(10)60) child7_12=1)
marginsplot, recast(line) recastci(rarea) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure c") xtitle("Childcare 7-12") ytitle("Pr(NW -> E)") name(S1_GENERAL_7_12_over_6M)
 graph save S1_GENERAL_7_12_over_6M, replace


 /******************************************************************************
 ***********************************SAMPLE 2*************************************
 *******************************************************************************/


 clear 
 set more off
 cd "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 global years_path "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 
 use "$years_path\EU_SILC_Employed_Part_time", clear 
  
 global control_HH_S2 "i.married nchild i.child0_3 i.child4_6 i.child7_12 i.quintile age age_p i.education_woman i.education_man i.occupation_man i.occupation_woman"
 global  control_country "share_women_responsibility share_men_responsibility female_participation unemployment_rate"
 global his_unemp "i.unemployed_over_6m"
 
 replace nrrpc_67_33 = 100 if unemployed_over_6m == 0
 replace unemployed_over_6m = . if nrrpc_67_33 == .
 

 /***************GENERAL MEASURE OF CHILDCARE*****************/ 

 mixed transition_FT $his_unemp##i.child0_3##c.childcare_0_3_G $his_unemp##i.child4_6##c.childcare_4_6_G $his_unemp3m##i.child7_12##c.childcare_7_12_G $control_HH_S2 $control_country || country:, vce(robust)
 estimates store S2H3_3M_CareG_MTR
   
 margins $his_unemp, at(childcare_0_3_G=(0(10)70) child0_3=1)
 marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure d") xtitle("Childcare 0-3") ytitle("Pr(PT -> FT)") name(S2_GENERAL_0_3_over_6M)
  graph save S2_GENERAL_0_3_over_6M, replace
 
 margins $his_unemp, at(childcare_4_6_G=(0(10)80) child4_6=1)
marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure e") xtitle("Childcare 4-6") ytitle("Pr(PT -> FT)") name(S2_GENERAL_4_6_over_6M)
 graph save S2_GENERAL_4_6_over_6M, replace

 margins $his_unemp, at(childcare_7_12_G=(0(10)60) child7_12=1)
marginsplot, recast(line) recastci(rarea) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure f") xtitle("Childcare 7-12") ytitle("Pr(PT -> FT)") name(S2_GENERAL_7_12_over_6M)
 graph save S2_GENERAL_7_12_over_6M, replace
  
  
 grc1leg S1_GENERAL_0_3_over_6M S1_GENERAL_4_6_over_6M S1_GENERAL_7_12_over_6M, legendfrom(S1_GENERAL_0_3_over_6M) title(NW -> E) graphregion(color(white))  name(grcol1,replace) row(3)
 grc1leg S2_GENERAL_0_3_over_6M S2_GENERAL_4_6_over_6M S2_GENERAL_7_12_over_6M, legendfrom(S2_GENERAL_0_3_over_6M) title(PT -> FT) graphregion(color(white))  name(grcol2,replace) row(3)
 grc1leg   grcol1 grcol2, legendfrom(grcol1) col(2) graphregion(color(white)) altshrink  graphregion(margin(l=10 r=10)) 
 graph save Childcare_General_over_6_MONTHS, replace
 
   graph export "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE\Childcare_General_over_6_MONTHS.tif", width(2250) height(1750) replace
  
  
  
  
  /***************PART-TIME MEASURE OF CHILDCARE*****************/ 
  
   /******************************************************************************
 ***********************************SAMPLE 1*************************************
 *******************************************************************************/
 clear 
 set more off
 cd "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 global years_path "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 use "$years_path\EU_SILC_Employed_No_work", clear 
 
 global control_HH_S1 "i.married nchild i.child0_3 i.child4_6 i.child7_12 i.quintile age age_p i.education_woman i.education_man i.occupation_man"
 global  control_country "share_women_responsibility share_men_responsibility female_participation unemployment_rate"
 global his_unemp "i.unemployed_over_6m"
 
 replace nrrpc_67_33 = 100 if unemployed_over_6m == 0
 replace unemployed_over_6m = . if nrrpc_67_33 == .
 
 mixed transition_work $his_unemp##i.child0_3##c.childcare_0_3_PT $his_unemp##i.child4_6##c.childcare_4_6_PT $his_unemp##i.child7_12##c.childcare_7_12_PT $control_HH_S1 $control_country || country:, vce(robust)

 
 margins $his_unemp, at(childcare_0_3_PT=(0(10)70) child0_3=1)
 marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure a") xtitle("Childcare 0-3 (part-time)") ytitle("Pr(NW -> E)") name(S1_PT_0_3_over_6M)
 graph save S1_PT_0_3_over_6M, replace
 
 margins $his_unemp, at(childcare_4_6_PT=(0(10)80) child4_6=1)
 marginsplot, recast(line) recastci(rarea)  allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure b") xtitle("Childcare 4-6 (part-time)") ytitle("Pr(NW -> E)") name(S1_PT_4_6_over_6M4)
 graph save S1_PT_4_6_over_6M, replace
 
 margins $his_unemp, at(childcare_7_12_PT=(0(10)60) child7_12=1)
 marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure c") xtitle("Childcare 7-12 (part-time)") ytitle("Pr(NW -> E)") name(S1_PT_7_12_over_6M)
 graph save S1_PT_7_12_over_6M, replace
  
  
   
   /******************************************************************************
 ***********************************SAMPLE 2*************************************
 *******************************************************************************/
  
 clear 
 set more off
 cd "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 global years_path "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 
 use "$years_path\EU_SILC_Employed_Part_time", clear 
  
 global control_HH_S2 "i.married nchild i.child0_3 i.child4_6 i.child7_12 i.quintile age age_p i.education_woman i.education_man i.occupation_man i.occupation_woman"
 global  control_country "share_women_responsibility share_men_responsibility female_participation unemployment_rate"
 global his_unemp "i.unemployed_over_6m"
 
 replace nrrpc_67_33 = 100 if unemployed_over_6m == 0
 replace unemployed_over_6m = . if nrrpc_67_33 == .
  /***************PART-TIME MEASURE OF CHILDCARE*****************/ 
 
 mixed transition_FT $his_unemp##i.child0_3##c.childcare_0_3_PT $his_unemp##i.child4_6##c.childcare_4_6_PT $his_unemp##i.child7_12##c.childcare_7_12_PT $control_HH_S2 $control_country || country:, vce(robust)

  
 margins $his_unemp, at(childcare_0_3_PT=(0(10)70) child0_3=1)
 marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure d") xtitle("Childcare 0-3 (part-time)") ytitle("Pr(PT -> FT)") name(S2_PT_0_3_over_6M)
  graph save  S2_PT_0_3_over_6M, replace 
 
 margins $his_unemp, at(childcare_4_6_PT=(0(10)80) child4_6=1)
 marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure e") xtitle("Childcare 4-6 (part-time)") ytitle("Pr(PT -> FT)") name(S2_PT_4_6_over_6M)
 graph save S2_PT_4_6_over_6M, replace
 
 margins $his_unemp, at(childcare_7_12_PT=(0(10)60) child7_12=1)
 marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure f") xtitle("Childcare 7-12 (part-time)") ytitle("Pr(PT -> FT)") name(S2_PT_7_12_over_6M)
graph save S2_PT_7_12_over_6M, replace
  
 
 grc1leg S1_PT_0_3_over_6M S1_PT_4_6_over_6M4 S1_PT_7_12_over_6M, legendfrom(S1_PT_0_3_over_6M) title(NW -> E) graphregion(color(white))  name(grcol1,replace) row(3)
 grc1leg S2_PT_0_3_over_6M S2_PT_4_6_over_6M S2_PT_7_12_over_6M, legendfrom(S2_PT_0_3_over_6M) title(PT -> FT) graphregion(color(white))  name(grcol2,replace) row(3)
 grc1leg   grcol1 grcol2, legendfrom(grcol1) col(2) graphregion(color(white)) altshrink  graphregion(margin(l=10 r=10)) 
 graph save Childcare_PT_3_over_6MONTHS, replace
  
   graph export "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE\Childcare_PT_3_over_6MONTHS.tif", width(2250) height(1750) replace
  
   /***************FULL-TIME MEASURE OF CHILDCARE*****************/ 
   
      /******************************************************************************
 ***********************************SAMPLE 1*************************************
 *******************************************************************************/
 clear 
 set more off
 cd "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 global years_path "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 use "$years_path\EU_SILC_Employed_No_work", clear 
 
 global control_HH_S1 "i.married nchild i.child0_3 i.child4_6 i.child7_12 i.quintile age age_p i.education_woman i.education_man i.occupation_man"
 global  control_country "share_women_responsibility share_men_responsibility female_participation unemployment_rate"
 global his_unemp "i.unemployed_over_6m"
 
 replace nrrpc_67_33 = 100 if unemployed_over_6m == 0
 replace unemployed_over_6m = . if nrrpc_67_33 == .
 
 mixed transition_work $his_unemp##i.child0_3##c.childcare_0_3_FT $his_unemp##i.child4_6##c.childcare_4_6_FT $his_unemp##i.child7_12##c.childcare_7_12_FT $control_HH_S1 $control_country  || country:, vce(robust)

 
 margins $his_unemp, at(childcare_0_3_FT=(0(10)70) child0_3=1)
marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83)  ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure a") xtitle("Childcare 0-3 (full-time)") ytitle("Pr(NW -> E)") name(S1_FT_0_3_over_6M)
 graph save S1_FT_0_3_over_6M, replace
 
 margins $his_unemp, at(childcare_4_6_FT=(0(10)80) child4_6=1)
 marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83)  ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure b") xtitle("Childcare 4-6 (full-time)") ytitle("Pr(NW -> E)") name(S1_FT_4_6_over_6M2)
  graph save S1_FT_4_6_over_6M, replace
 
 margins $his_unemp, at(childcare_7_12_FT=(0(10)60) child7_12=1)
 marginsplot, recast(line) recastci(rarea) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83) ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure c") xtitle("Childcare 7-12 (full-time)") ytitle("Pr(NW -> E)") name(S1_FT_7_12_over_6M)
  graph save S1_FT_7_12_over_6M, replace
 
 
  
 /******************************************************************************
 ***********************************SAMPLE 2*************************************
 *******************************************************************************/

 clear 
 set more off
 cd "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 global years_path "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 
 use "$years_path\EU_SILC_Employed_Part_time", clear 
  
 global control_HH_S2 "i.married nchild i.child0_3 i.child4_6 i.child7_12 i.quintile age age_p i.education_woman i.education_man i.occupation_man i.occupation_woman"
 global  control_country "share_women_responsibility share_men_responsibility female_participation unemployment_rate"
 global his_unemp "i.unemployed_over_6m"
 
 replace nrrpc_67_33 = 100 if unemployed_over_6m == 0
 replace unemployed_over_6m = . if nrrpc_67_33 == .
 
 
   /***************FULL-TIME MEASURE OF CHILDCARE*****************/ 
 
 mixed transition_FT $his_unemp##i.child0_3##c.childcare_0_3_FT $his_unemp##i.child4_6##c.childcare_4_6_FT $his_unemp##i.child7_12##c.childcare_7_12_FT $control_HH_S2 $control_country  || country:, vce(robust)

   
 margins $his_unemp, at(childcare_0_3_FT=(0(10)70) child0_3=1)
marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83)  ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure d") xtitle("Childcare 0-3 (full-time)") ytitle("Pr(PT -> FT)") name(S2_FT_0_3_over_6M)
   graph save S2_FT_0_3_over_6M, replace
 
 margins $his_unemp, at(childcare_4_6_FT=(0(10)80) child4_6=1)
 marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83)  ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure e") xtitle("Childcare 4-6 (full-time)") ytitle("Pr(PT -> FT)") name(S2_FT_4_6_over_6M)
  graph save S2_FT_4_6_over_6M, replace
 
 margins $his_unemp, at(childcare_7_12_FT=(0(10)60) child7_12=1)
 marginsplot, recast(line) recastci(rarea) yline(0) allsimplelabels plot1opts(lpattern(line)lcolor(gs6)) plot2opts(lpattern(longdash_dot)lcolor(gs6)) level(83)  ciopt(color(grey%20) color(grey%30)) graphregion(color(white)) title("Figure f") xtitle("Childcare 7-12 (full-time)") ytitle("Pr(PT -> FT)") name(S2_FT_7_12_over_6M)
  
graph save S2_FT_7_12_over_6M, replace
 

 grc1leg S1_FT_0_3_over_6M S1_FT_4_6_over_6M2 S1_FT_7_12_over_6M, legendfrom(S1_FT_0_3_over_6M) title(NW -> E) graphregion(color(white))  name(grcol1,replace) row(3)
 grc1leg S2_FT_0_3_over_6M S2_FT_4_6_over_6M S2_FT_7_12_over_6M, legendfrom(S2_FT_0_3_over_6M) title(PT -> FT) graphregion(color(white))  name(grcol2,replace) row(3)
 grc1leg   grcol1 grcol2, legendfrom(grcol1) col(2) graphregion(color(white)) altshrink  graphregion(margin(l=10 r=10)) 
 graph save Childcare_FT_3_over_MONTHS, replace
 graph export "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE\Childcare_FT_3_over_MONTHS.tif", width(2250) height(1750) replace
