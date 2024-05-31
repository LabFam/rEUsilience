********************************************************************
****************Coder: Alina Maria Pavelea**************************************
****************Project: rEUsilience********************************************
****************Purpose: Data Analysis. WP.3.1.Study 1**************************

 clear 
 cd "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 global years_path "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE"
 log using "$years_path\Results\STUDY_PLOS_ONE_DESCRIPTIVES", replace
 *Note: in cd crate a new folder "Results" where the results will be saved

/*******************************************************************************
********************************DESCRIPTIVES***********************************
*******************************************************************************/

 /*******************************************************************************
********************************SAMPLE 1***********************************
*******************************************************************************/

 use "$years_path\EU_SILC_Employed_No_work", clear 
 drop if unemployed3m == .
 drop if transition_work == . 
summarize i.year i.married nchild i.child0_3 i.child4_6 i.child7_12 i.quintile age age_p i.education_woman i.education_man i.occupation_man i.unemployed3m i.unemployed3_6m i.unemployed_over_6m i.job_loss  i.transition_work share_women_responsibility share_men_responsibility female_participation unemployment_rate nrrpc_67_33 nrrpc_100_50 nrrpc_50_25 MTR_NW_PT_100_50 MTR_NW_FT_100_50 MTR_NW_PT_50_25 MTR_NW_FT_50_25 MTR_NW_PT_67_33 MTR_NW_FT_67_33 MTR_NW_PT_150_75 MTR_NW_FT_150_75 MTR_NW_PT_200_100 MTR_NW_FT_200_100 

/*Identify the number of unique households***/
egen hhgroup = group(hhunique)
duplicates drop hhgroup, force
tab year


/***COUPLES WITH SPELLS BETWEEB 3 AND 6 MONTHS***/
clear
use "$years_path\EU_SILC_Employed_No_work", clear 
drop if unemployed3_6m ==.
/*Identify the number of unique households***/
egen hhgroup = group(hhunique)
duplicates drop hhgroup, force
tab year


/***COUPLES WITH SPELLS OVER 6 MONTHS***/
clear
use "$years_path\EU_SILC_Employed_No_work", clear 
drop if unemployed_over_6m ==.
/*Identify the number of unique households***/
egen hhgroup = group(hhunique)
duplicates drop hhgroup, force
tab year
  /*******************************************************************************
********************************SAMPLE 2***********************************
*******************************************************************************/
 
 clear
 use "$years_path\EU_SILC_Employed_Part_time", clear 
 drop if unemployed3m == .
 drop if transition_FT == . 
 summarize i.year i.married nchild i.child0_3 i.child4_6 i.child7_12 i.quintile age age_p i.education_woman i.education_man i.occupation_woman i.occupation_man i.unemployed3m i.unemployed3_6m i.unemployed_over_6m i.job_loss  i.transition_FT share_women_responsibility share_men_responsibility female_participation unemployment_rate nrrpc_67_33 nrrpc_100_50 nrrpc_50_25  MTR_PT_FT_100_50 MTR_PT_FT_50_25 MTR_PT_FT_67_33 MTR_PT_FT_150_75 MTR_PT_FT_200_100
 
 /*Identify the number of unique households***/
egen hhgroup = group(hhunique)
duplicates drop hhgroup, force
tab year

/***COUPLES WITH SPELLS BETWEEB 3 AND 6 MONTHS***/
clear
use "$years_path\EU_SILC_Employed_Part_time", clear 
drop if unemployed3_6m ==.
/*Identify the number of unique households***/
egen hhgroup = group(hhunique)
duplicates drop hhgroup, force
tab year


/***COUPLES WITH SPELLS OVER 6 MONTHS***/
clear
use "$years_path\EU_SILC_Employed_Part_time", clear 
drop if unemployed_over_6m ==.
/*Identify the number of unique households***/
egen hhgroup = group(hhunique)
 drop if transition_FT == . 
duplicates drop hhgroup, force
tab year

log close


*******************************************************************************
***********************MIXED EFFECTS LINEAR PROBABILITY MODELS*****************
************************BY MEASURE OF HIS UNEMPLOYMENT*************************

 /*******************************************************************************
 *********************UNEMPLOYMENT DEFINED AS 3 MONTHS OR MORE******************
 *******************************************************************************/

  /******************************************************************************
 ***********************************HYPOTHESIS 1*************************************
 *******************************************************************************/
  
 /******************************************************************************
 ***********************************SAMPLE 1*************************************
 *******************************************************************************/
  
 clear 
 use "$years_path\EU_SILC_Employed_No_work", clear 
 log using "$years_path\STUDY_PLOS_ONE_SAPMLE 1_RESULTS UNEMPLOYMENT_3M_H1", replace
  
 global control_HH_S1 "i.married nchild i.child0_3 i.child4_6 i.child7_12 i.quintile age age_p i.education_woman i.education_man i.occupation_man"
 global  control_country "share_women_responsibility share_men_responsibility female_participation unemployment_rate"
 global his_unemp "i.unemployed3m"
 /*******CHECKING FOR MULTICOLINEARITY WHEN INCLUDING THE POLICY VARIABLES OF INTEREST AS CONTROL VARIABLES******/
 
 regress transition_work $his_unemp $control_HH_S1 $control_country childcare_0_3_G childcare_4_6_G childcare_7_12_G nrrpc_67_33 MTR_NW_PT_67_33  MTR_NW_FT_67_33
 estat vif
 
  regress transition_work $his_unemp $control_HH_S1 $control_country childcare_0_3_G childcare_4_6_G childcare_7_12_G nrrpc_67_33 MTR_NW_PT_67_33  
 estat vif
 
  regress transition_work $his_unemp $control_HH_S1 $control_country childcare_0_3_G childcare_4_6_G childcare_7_12_G nrrpc_67_33   MTR_NW_FT_67_33
 estat vif
 
 
 
 regress transition_work $his_unemp $control_HH_S1 $control_country
  estat vif
 /****BASELINE MODELS*****
 mixed transition_work $his_unemp $control_HH_S1 $control_country || country:, vce(robust)
 estimates store baseline*/
 

 
 esttab baseline using  "$years_path\Table_S1_Unemployment_3M_H1.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
 log close
 
 
 
  /*****************************************************************************
 *****************************SAMPLE 2**********************************
 *****************************************************************************/

 clear 
 use "$years_path\EU_SILC_Employed_Part_time", clear 
 log using "$years_path\STUDY_PLOS_ONE_SAPMLE 2_RESULTS UNEMPLOYMENT_3M_H1", replace
 global control_HH_S2 "i.married nchild i.child0_3 i.child4_6 i.child7_12 i.quintile age age_p i.education_woman i.education_man i.occupation_man i.occupation_woman"
  /*******CHECKING FOR MULTICOLINEARITY WHEN INCLUDING THE POLICY VARIABLES OF INTEREST AS CONTROL VARIABLES******/
  
 regress transition_FT i.unemployed3m $control_HH_S2 $control_country childcare_0_3_G childcare_4_6_G childcare_7_12_G nrrpc_67_33 MTR_PT_FT_67_33 
 estat vif
 
  regress transition_FT i.unemployed3m $control_HH_S2 $control_country  
 estat vif
 
/********HYPOTHESIS 1 - BASELINE MODELS*********
 mixed transition_FT $his_unemp $control_HH_S2 $control_country || country:, vce(robust)
  estimates store baseline*/

 esttab baseline using  "$years_path\Table_S2_Unemployment_3M_H1.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
 log close
 

   /******************************************************************************
 ***********************************HYPOTHESIS 2**********************************
 *******************************************************************************/
 
 
 
  /****MOTHERS VS NOT MOTHERS**/
   /******************************************************************************
 ***********************************SAMPLE 1*************************************
 *******************************************************************************/

 clear 
 set more off
 use "$years_path\EU_SILC_Employed_No_work", clear 

 generate mother = 1 if nchild != 0
 replace mother = 0 if mother == .
 
 log using "$years_path\Results\STUDY_PLOS_ONE_SAPMLE 1_RESULTS UNEMPLOYMENT_3M_H2_MOTHERS VS NOT MOTHERS", replace
 mixed transition_work $his_unemp##i.mother  $control_HH_S1 $control_country   || country:, vce(robust)
 estimates store S1_Unemp_H2_MOM
 
 esttab S1_Unemp_H2_MOM using  "$years_path\Results\Table_S1_Unemployment_3M_H2_MOTHERS VS NOT MOTHERS.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
 log close
  
  
     /******************************************************************************
 ***********************************SAMPLE 2*************************************
 *******************************************************************************/
  
 clear 
 set more off
 use "$years_path\EU_SILC_Employed_Part_time", clear 

 generate mother = 1 if nchild != 0
 replace mother = 0 if mother == .
  
 log using "$years_path\Results\STUDY_PLOS_ONE_SAPMLE 2_RESULTS UNEMPLOYMENT_3M_H2_MOTHERS VS NOT MOTHERS", replace
 mixed transition_FT $his_unemp##i.mother  $control_HH_S2 $control_country   || country:, vce(robust)
 estimates store S2_Unemp_H2_MOM
 
 esttab S2_Unemp_H2_MOM  using  "$years_path\Results\Table_S2_Unemployment_3M_H2_MOTHERS VS NOT MOTHERS.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
 log close
 
  
 /*********************BY CHILDREN AGE*************************/
 
  /******************************************************************************
 ***********************************SAMPLE 1*************************************
 *******************************************************************************/
 clear 
 use "$years_path\EU_SILC_Employed_No_work", clear 

 log using "$years_path\Results\STUDY_PLOS_ONE_SAPMLE 1_RESULTS UNEMPLOYMENT_3M_H2", replace
 
 mixed transition_work $his_unemp##i.child0_3 $his_unemp##i.child4_6 $his_unemp##i.child7_12 $control_HH_S1 $control_country  || country:, vce(robust)
 estimates store S1_Unemp_H2_CHILD

 esttab S1_Unemp_H2_CHILD using  "$years_path\Results\Table_S1_Unemployment_3M_H2.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
 log close
 
  /******************************************************************************
 ***********************************SAMPLE 2*************************************
 *******************************************************************************/
 
 clear 
 set more off
 
 use "$years_path\EU_SILC_Employed_Part_time", clear 

 log using "$years_path\Results\STUDY_PLOS_ONE_SAPMLE 2_RESULTS UNEMPLOYMENT_3M_H2", replace
 mixed transition_FT $his_unemp##i.child0_3 $his_unemp##i.child4_6 $his_unemp##i.child7_12 $control_HH_S2 $control_country  || country:, vce(robust)
 estimates store S2_Unemp_H2_CHILD
 
 esttab S2_Unemp_H2_CHILD using  "$years_path\Results\Table_S2_Unemployment_3M_H2.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
 log close
 

 
  /******************************************************************************
 ***********************************HYPOTHESIS 3**********************************
 *******************************************************************************/
 
  
  /***************GENERAL MEASURE OF CHILDCARE*****************/ 
 
   /******************************************************************************
 ***********************************SAMPLE 1*************************************
 *******************************************************************************/

 clear 
 use "$years_path\EU_SILC_Employed_No_work", clear 

 log using "$years_path\Results\STUDY_PLOS_ONE_SAPMLE 1_RESULTS UNEMPLOYMENT_3M_H3_GENERAL MEASURE OF CHILDCARE", replace

 
 /***************GENERAL MEASURE OF CHILDCARE*****************/ 
 mixed transition_work $his_unemp##i.child0_3##c.childcare_0_3_G $his_unemp##i.child4_6##c.childcare_4_6_G $his_unemp##i.child7_12##c.childcare_7_12_G $control_HH_S1 $control_country  || country:, vce(robust)
 estimates store S1H3_3M_CareG
 
 
  /***************PART-TIME MEASURE OF CHILDCARE*****************/ 
 mixed transition_work $his_unemp##i.child0_3##c.childcare_0_3_PT $his_unemp##i.child4_6##c.childcare_4_6_PT $his_unemp##i.child7_12##c.childcare_7_12_PT $control_HH_S1 $control_country || country:, vce(robust)
 estimates store S1H3_3M_CarePT
 
  
   /***************FULL-TIME MEASURE OF CHILDCARE*****************/ 
  mixed transition_work $his_unemp##i.child0_3##c.childcare_0_3_FT $his_unemp##i.child4_6##c.childcare_4_6_FT $his_unemp##i.child7_12##c.childcare_7_12_FT $control_HH_S1 $control_country || country:, vce(robust)
  estimates store S1H3_3M_CareFT

 
  esttab S1H3_3M_CareG S1H3_3M_CarePT S1H3_3M_CareFT using  "$years_path\Results\Table_S1_Unemployment_3M_H3.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
  
 
 log close

  
 /******************************************************************************
 ***********************************SAMPLE 2*************************************
 *******************************************************************************/


 clear 
 use "$years_path\EU_SILC_Employed_Part_time", clear 
 log using "$years_path\Results\STUDY_PLOS_ONE_SAPMLE 2_RESULTS UNEMPLOYMENT 3M_H3", replace

 
   /***************GENERAL MEASURE OF CHILDCARE*****************/ 
   mixed transition_FT $his_unemp##i.child0_3##c.childcare_0_3_G $his_unemp##i.child4_6##c.childcare_4_6_G $his_unemp##i.child7_12##c.childcare_7_12_G $control_HH_S2 $control_country  || country:, vce(robust)
 estimates store S2H3_3M_CareG
  
  
  /***************PART-TIME MEASURE OF CHILDCARE*****************/ 
 
 mixed transition_FT $his_unemp##i.child0_3##c.childcare_0_3_PT $his_unemp##i.child4_6##c.childcare_4_6_PT $his_unemp##i.child7_12##c.childcare_7_12_PT $control_HH_S2 $control_country || country:, vce(robust)
 estimates store S2H3_3M_CarePT
   
 
   /***************FULL-TIME MEASURE OF CHILDCARE*****************/ 
 
 mixed transition_FT $his_unemp##i.child0_3##c.childcare_0_3_FT $his_unemp##i.child4_6##c.childcare_4_6_FT $his_unemp##i.child7_12##c.childcare_7_12_FT $control_HH_S2 $control_country  || country:, vce(robust)
 estimates store S2H3_3M_CareFT
   
  
 esttab S2H3_3M_CareG S2H3_3M_CarePT S2H3_3M_CareFT using  "$years_path\Results\Table_S2_Unemployment_3M_H3.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
 
 log close


 
  /******************************************************************************
 ***********************************HYPOTHESIS 4**********************************
 *******************************************************************************/
 
 
 /******************************************************************************
 ***********************************SAMPLE 1*************************************
 *******************************************************************************/
  clear 
 set more off
 use "$years_path\EU_SILC_Employed_No_work", clear 
 log using "$years_path\Results\STUDY_PLOS_ONE_SAPMLE 1_RESULTS UNEMPLOYMENT 3M_H4", replace
 
 
 /**************NRRS DEFINED AS 67% AND 33% OF EU-AVERAGE WAGE*****************/
 mixed transition_work $his_unemp##c.nrrpc_67_33 $control_HH_S1 $control_country   || country:, vce(robust)
 estimates store S1H4_M3_NRR_67_33
 
    /**************NRRS DEFINED AS 50% AND 25% OF EU-AVERAGE WAGE*****************/
 mixed transition_work $his_unemp##c.nrrpc_50_25 $control_HH_S1 $control_country  || country:, vce(robust)
 estimates store S1H4_M3_NRR_50_25
 
 
  /**************NRRS DEFINED AS 100% AND 50% OF EU-AVERAGE WAGE*****************/
 mixed transition_work $his_unemp##c.nrrpc_100_50 $control_HH_S1 $control_country   || country:, vce(robust)
 estimates store S1H4_M3_NRR_100_50

     /**************NRRS DEFINED AS 150% AND 75% OF EU-AVERAGE WAGE*****************/
 mixed transition_work $his_unemp##c.nrrpc_150_75 $control_HH_S1 $control_country  || country:, vce(robust)
 estimates store S1H4_M3_NRR_150_75


    /**************NRRS DEFINED AS 200% AND 100% OF EU-AVERAGE WAGE*****************/
 mixed transition_work $his_unemp##c.nrrpc_200_100 $control_HH_S1 $control_country  || country:, vce(robust)
 estimates store S1H4_M3_NRR_200_100

  esttab S1H4_M3_NRR_100_50 S1H4_M3_NRR_200_100 S1H4_M3_NRR_150_75 using  "$years_path\Results\Table_S1_Unemployment_3M_H4_extra.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
  
 
  esttab S1H4_M3_NRR_67_33 S1H4_M3_NRR_100_50 S1H4_M3_NRR_50_25 S1H4_M3_NRR_200_100 using  "$years_path\Results\Table_S1_Unemployment_3M_H4.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
  
  
   log close
   
 

  /******************************************************************************
 ***********************************SAMPLE 2*************************************
 *******************************************************************************/
 
 clear 
 use "$years_path\EU_SILC_Employed_Part_time", clear 
 
  log using "$years_path\Results\STUDY_PLOS_ONE_SAPMLE S_RESULTS UNEMPLOYMENT 3M_H4", replace
 /**************NRRS DEFINED AS 67% AND 33% OF EU-AVERAGE WAGE*****************/
 
 mixed transition_FT $his_unemp##c.nrrpc_67_33 $control_HH_S2 $control_country || country:, vce(robust)
 estimates store S2H4_M3_NRR_67_33
 
  
   /**************NRRS DEFINED AS 50% AND 25% OF EU-AVERAGE WAGE*****************/
 mixed transition_FT $his_unemp##c.nrrpc_50_25 $control_HH_S2 $control_country  || country:, vce(robust)
 estimates store S2H4_M3_NRR_50_25

 
  /**************NRRS DEFINED AS 100% AND 50% OF EU-AVERAGE WAGE*****************/
 mixed transition_FT $his_unemp##c.nrrpc_100_50 $control_HH_S2 $control_country   || country:, vce(robust)
 estimates store S2H4_M3_NRR_100_50
 
  /**************NRRS DEFINED AS 200% AND 100% OF EU-AVERAGE WAGE*****************/
 mixed transition_FT $his_unemp##c.nrrpc_200_100 $control_HH_S2 $control_country   || country:, vce(robust)
 estimates store S2H4_M3_NRR_200_100 
 
   /**************NRRS DEFINED AS 150% AND 75% OF EU-AVERAGE WAGE*****************/
 mixed transition_FT $his_unemp##c.nrrpc_150_75 $control_HH_S2 $control_country   || country:, vce(robust)
 estimates store S2H4_M3_NRR_150_75 
 
   esttab S2H4_M3_NRR_100_50 S2H4_M3_NRR_200_100 S2H4_M3_NRR_150_75  using  "$years_path\Results\Table_S2_Unemployment_3M_H4_extra.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
 
 
  esttab S2H4_M3_NRR_67_33 S2H4_M3_NRR_100_50 S2H4_M3_NRR_50_25 S2H4_M3_NRR_200_100 using  "$years_path\Results\Table_S2_Unemployment_3M_H4.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
   log close
 
  /******************************************************************************
 ***********************************HYPOTHESIS 5**********************************
 *******************************************************************************/
 
 
 /******************************************************************************
 ***********************************SAMPLE 1*************************************
 *******************************************************************************/
  clear 
 use "$years_path\EU_SILC_Employed_No_work", clear 
 log using "$years_path\Results\STUDY_PLOS_ONE_SAPMLE 1_RESULTS UNEMPLOYMENT 3M_H5", replace

 
 /**************MTRS DEFINED AS 67% AND 33% OF EU-AVERAGE WAGE*****************/
  mixed transition_work $his_unemp##c.MTR_NW_PT_67_33  $control_HH_S1 $control_country  || country:, vce(robust)
  estimates store S1H5_67_33_PT

    mixed transition_work $his_unemp##c.MTR_NW_FT_67_33  $control_HH_S1 $control_country  || country:, vce(robust)
  estimates store S1H5_67_33_FT
   
  
 /**************MTRS DEFINED AS 100% AND 50% OF EU-AVERAGE WAGE*****************/
  mixed transition_work $his_unemp##c.MTR_NW_PT_100_50  $control_HH_S1 $control_country   || country:, vce(robust)
  estimates store S1H5_100_50_PT

   mixed transition_work $his_unemp##c.MTR_NW_FT_100_50  $control_HH_S1 $control_country   || country:, vce(robust)
  estimates store S1H5_100_50_FT

 /**************MTRS DEFINED AS 50% AND 25% OF EU-AVERAGE WAGE*****************/
 
  mixed transition_work $his_unemp##c.MTR_NW_PT_50_25  $control_HH_S1 $control_country  || country:, vce(robust)
  estimates store S1H5_50_25_PT

   mixed transition_work $his_unemp##c.MTR_NW_FT_50_25  $control_HH_S1 $control_country  || country:, vce(robust)
  estimates store S1H5_50_25_FT

 
 /**************MTRS DEFINED AS 150% AND 75% OF EU-AVERAGE WAGE*****************/
  mixed transition_work $his_unemp##c.MTR_NW_PT_150_75  $control_HH_S1 $control_country   || country:, vce(robust)
  estimates store S1H5_150_75_PT

    mixed transition_work $his_unemp##c.MTR_NW_FT_150_75  $control_HH_S1 $control_country   || country:, vce(robust)
  estimates store S1H5_150_75_FT
 
  /**************MTRS DEFINED AS 200% AND 100% OF EU-AVERAGE WAGE*****************/
  mixed transition_work $his_unemp##c.MTR_NW_PT_200_100  $control_HH_S1 $control_country  || country:, vce(robust)
  estimates store S1H5_200_100_PT

    mixed transition_work $his_unemp##c.MTR_NW_FT_200_100  $control_HH_S1 $control_country  || country:, vce(robust)
  estimates store S1H5_200_100_FT
   
  esttab   S1H5_67_33_PT S1H5_67_33_FT S1H5_100_50_PT S1H5_100_50_FT S1H5_50_25_PT S1H5_50_25_FT S1H5_150_75_PT S1H5_150_75_FT S1H5_200_100_PT S1H5_200_100_FT using  "$years_path\Results\Table_S1_Unemployment_3M_H5.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
  log close

  
  
   /******************************************************************************
 ***********************************SAMPLE 2*************************************
 *******************************************************************************/
 clear 
 use "$years_path\EU_SILC_Employed_Part_time", clear  .
 log using "$years_path\Results\STUDY_PLOS_ONE_SAPMLE 2_RESULTS UNEMPLOYMENT 3M_H5", replace
 
 /**************MTRS DEFINED AS 67% AND 33% OF EU-AVERAGE WAGE*****************/
  mixed transition_FT $his_unemp##c.MTR_PT_FT_67_33  $control_HH_S2 $control_country   || country:, vce(robust)
  estimates store S2H5_67_33
   
  
 /**************MTRS DEFINED AS 100% AND 50% OF EU-AVERAGE WAGE*****************/
  mixed transition_FT $his_unemp##c.MTR_PT_FT_100_50  $control_HH_S2 $control_country   || country:, vce(robust)
  estimates store S2H5_100_50
 
 /**************MTRS DEFINED AS 50% AND 25% OF EU-AVERAGE WAGE*****************/
  mixed transition_FT $his_unemp##c.MTR_PT_FT_50_25  $control_HH_S2 $control_country  || country:, vce(robust)
  estimates store S2H5_50_25
 
 
 /**************MTRS DEFINED AS 150% AND 75% OF EU-AVERAGE WAGE*****************/
  mixed transition_FT $his_unemp##c.MTR_PT_FT_150_75  $control_HH_S2 $control_country  || country:, vce(robust)
  estimates store S2H5_150_75
 
  /**************MTRS DEFINED AS 200% AND 100% OF EU-AVERAGE WAGE*****************/
  mixed transition_FT $his_unemp##c.MTR_PT_FT_200_100  $control_HH_S2 $control_country  || country:, vce(robust)
  estimates store S2H5_200_100
  
   
  esttab S2H5_67_33 S2H5_100_50 S2H5_50_25 S2H5_150_75 S2H5_200_100 using  "$years_path\Results\Table_S2_Unemployment_3M_H5.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
  log close
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  

  
  
  
  
   /*******************************************************************************
 *********************UNEMPLOYMENT DEFINED AS BETWEEN 3 AND 6 MONTHS ******************
 *******************************************************************************/

 
   /******************************************************************************
 ***********************************HYPOTHESIS 1*************************************
 *******************************************************************************/
  
 /******************************************************************************
 ***********************************SAMPLE 1*************************************
 *******************************************************************************/
  
 clear 
 use "$years_path\EU_SILC_Employed_No_work", clear 
 log using "$years_path\STUDY_PLOS_ONE_SAPMLE 1_RESULTS UNEMPLOYMENT_3_6M_H1", replace
  
 global control_HH_S1 "i.married nchild i.child0_3 i.child4_6 i.child7_12 i.quintile age age_p i.education_woman i.education_man i.occupation_man"
 global  control_country "share_women_responsibility share_men_responsibility female_participation unemployment_rate"
   global his_unemp "i.unemployed3_6m"
 /*******CHECKING FOR MULTICOLINEARITY WHEN INCLUDING THE POLICY VARIABLES OF INTEREST AS CONTROL VARIABLES******/
 
 regress transition_work $his_unemp $control_HH_S1 $control_country childcare_0_3_G childcare_4_6_G childcare_7_12_G nrrpc_67_33 MTR_NW_PT_67_33  MTR_NW_FT_67_33
 estat vif
 
 regress transition_work $his_unemp $control_HH_S1 $control_country
  estat vif
 /****BASELINE MODELS******/
 mixed transition_work $his_unemp $control_HH_S1 $control_country || country:, vce(robust)
 estimates store baseline
 

 esttab baseline using  "$years_path\Table_S1_Unemployment_3_6M_H1.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
 log close
 
 
 
  /*****************************************************************************
 *****************************SAMPLE 2**********************************
 *****************************************************************************/

 clear 
 use "$years_path\EU_SILC_Employed_Part_time", clear 
 log using "$years_path\STUDY_PLOS_ONE_SAPMLE 2_RESULTS UNEMPLOYMENT_3_6M_H1", replace
 global control_HH_S2 "i.married nchild i.child0_3 i.child4_6 i.child7_12 i.quintile age age_p i.education_woman i.education_man i.occupation_man i.occupation_woman"
  /*******CHECKING FOR MULTICOLINEARITY WHEN INCLUDING THE POLICY VARIABLES OF INTEREST AS CONTROL VARIABLES******/
  
 regress transition_FT $his_unemp  $control_HH_S2 $control_country childcare_0_3_G childcare_4_6_G childcare_7_12_G nrrpc_67_33 MTR_PT_FT_67_33 
 estat vif
 
  regress transition_FT $his_unemp $control_HH_S2 $control_country  
 estat vif
 
/********HYPOTHESIS 1 - BASELINE MODELS**********/
 mixed transition_FT $his_unemp $control_HH_S2 $control_country || country:, vce(robust)
  estimates store baseline

 
 esttab baseline using  "$years_path\Table_S2_Unemployment_3_6M_H1.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
 log close
 

   /******************************************************************************
 ***********************************HYPOTHESIS 2**********************************
 *******************************************************************************/
 
 
 
  /****MOTHERS VS NOT MOTHERS**/
   /******************************************************************************
 ***********************************SAMPLE 1*************************************
 *******************************************************************************/

 clear 
 use "$years_path\EU_SILC_Employed_No_work", clear 
 
 generate mother = 1 if nchild != 0
 replace mother = 0 if mother == .
 
 log using "$years_path\Results\STUDY_PLOS_ONE_SAPMLE 1_RESULTS UNEMPLOYMENT_3_6M_H2_MOTHERS VS NOT MOTHERS", replace
 mixed transition_work $his_unemp##i.mother  $control_HH_S1 $control_country   || country:, vce(robust)
 estimates store S1_Unemp_H2_MOM
 
 esttab S1_Unemp_H2_MOM using  "$years_path\Results\Table_S1_Unemployment_3_6M_H2_MOTHERS VS NOT MOTHERS.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
 log close
  
  
     /******************************************************************************
 ***********************************SAMPLE 2*************************************
 *******************************************************************************/
  
 clear 
 use "$years_path\EU_SILC_Employed_Part_time", clear 
 generate mother = 1 if nchild != 0
 replace mother = 0 if mother == .
 

  
 log using "$years_path\Results\STUDY_PLOS_ONE_SAPMLE 2_RESULTS UNEMPLOYMENT_3_6M_H2_MOTHERS VS NOT MOTHERS", replace
 mixed transition_FT $his_unemp##i.mother  $control_HH_S2 $control_country   || country:, vce(robust)
 estimates store S2_Unemp_H2_MOM
 
 esttab S2_Unemp_H2_MOM  using  "$years_path\Results\Table_S2_Unemployment_3_6M_H2_MOTHERS VS NOT MOTHERS.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
 log close
 
  
 /*********************BY CHILDREN AGE*************************/
 
  /******************************************************************************
 ***********************************SAMPLE 1*************************************
 *******************************************************************************/
 clear 
 use "$years_path\EU_SILC_Employed_No_work", clear 
 log using "$years_path\Results\STUDY_PLOS_ONE_SAPMLE 1_RESULTS UNEMPLOYMENT_3_6M_H2", replace
 
 mixed transition_work $his_unemp##i.child0_3 $his_unemp##i.child4_6 $his_unemp##i.child7_12 $control_HH_S1 $control_country  || country:, vce(robust)
 estimates store S1_Unemp_H2_CHILD

 esttab S1_Unemp_H2_CHILD using  "$years_path\Results\Table_S1_Unemployment_3_6M_H2.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
 log close
 
  /******************************************************************************
 ***********************************SAMPLE 2*************************************
 *******************************************************************************/
 
 clear 
 use "$years_path\EU_SILC_Employed_Part_time", clear 
 log using "$years_path\Results\STUDY_PLOS_ONE_SAPMLE 2_RESULTS UNEMPLOYMENT_3_6M_H2", replace
 mixed transition_FT $his_unemp##i.child0_3 $his_unemp##i.child4_6 $his_unemp##i.child7_12 $control_HH_S2 $control_country  || country:, vce(robust)
 estimates store S2_Unemp_H2_CHILD
 
 esttab S2_Unemp_H2_CHILD using  "$years_path\Results\Table_S2_Unemployment_3_6M_H2.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
 log close
 

 
  /******************************************************************************
 ***********************************HYPOTHESIS 3**********************************
 *******************************************************************************/
 
  
  /***************GENERAL MEASURE OF CHILDCARE*****************/ 
 
   /******************************************************************************
 ***********************************SAMPLE 1*************************************
 *******************************************************************************/

 clear
 use "$years_path\EU_SILC_Employed_No_work", clear 
 log using "$years_path\Results\STUDY_PLOS_ONE_SAPMLE 1_RESULTS UNEMPLOYMENT_3_6M_H3_GENERAL MEASURE OF CHILDCARE", replace

 
 /***************GENERAL MEASURE OF CHILDCARE*****************/ 
 mixed transition_work $his_unemp##i.child0_3##c.childcare_0_3_G $his_unemp##i.child4_6##c.childcare_4_6_G $his_unemp##i.child7_12##c.childcare_7_12_G $control_HH_S1 $control_country  || country:, vce(robust)
 estimates store S1H3_3M_CareG
 
 
  /***************PART-TIME MEASURE OF CHILDCARE*****************/ 
 mixed transition_work $his_unemp##i.child0_3##c.childcare_0_3_PT $his_unemp##i.child4_6##c.childcare_4_6_PT $his_unemp##i.child7_12##c.childcare_7_12_PT $control_HH_S1 $control_country || country:, vce(robust)
 estimates store S1H3_3M_CarePT
 
  
   /***************FULL-TIME MEASURE OF CHILDCARE*****************/ 
  mixed transition_work $his_unemp##i.child0_3##c.childcare_0_3_FT $his_unemp##i.child4_6##c.childcare_4_6_FT $his_unemp##i.child7_12##c.childcare_7_12_FT $control_HH_S1 $control_country || country:, vce(robust)
  estimates store S1H3_3M_CareFT

 
  esttab S1H3_3M_CareG S1H3_3M_CarePT S1H3_3M_CareFT using  "C:\Users\adm\Documents\WP.3.1. STUDIES\DATA PLOS ONE\Results\Table_S1_Unemployment_3_6M_H3.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
  
 
 log close

  
 /******************************************************************************
 ***********************************SAMPLE 2*************************************
 *******************************************************************************/


 clear 
 use "$years_path\EU_SILC_Employed_Part_time", clear 
 log using "$years_path\Results\STUDY_PLOS_ONE_SAPMLE 2_RESULTS UNEMPLOYMENT 3_6M_H3", replace
   /***************GENERAL MEASURE OF CHILDCARE*****************/ 
   mixed transition_FT $his_unemp##i.child0_3##c.childcare_0_3_G $his_unemp##i.child4_6##c.childcare_4_6_G $his_unemp##i.child7_12##c.childcare_7_12_G $control_HH_S2 $control_country  || country:, vce(robust)
 estimates store S2H3_6M_CareG
  
  
  /***************PART-TIME MEASURE OF CHILDCARE*****************/ 
 
 mixed transition_FT $his_unemp##i.child0_3##c.childcare_0_3_PT $his_unemp##i.child4_6##c.childcare_4_6_PT $his_unemp##i.child7_12##c.childcare_7_12_PT $control_HH_S2 $control_country || country:, vce(robust)
 estimates store S2H3_6M_CarePT
   
 
   /***************FULL-TIME MEASURE OF CHILDCARE*****************/ 
 
 mixed transition_FT $his_unemp##i.child0_3##c.childcare_0_3_FT $his_unemp##i.child4_6##c.childcare_4_6_FT $his_unemp##i.child7_12##c.childcare_7_12_FT $control_HH_S2 $control_country  || country:, vce(robust)
 estimates store S2H3_6M_CareFT
   
  
 esttab S2H3_6M_CareG S2H3_6M_CarePT S2H3_6M_CareFT using  "$years_path\Results\Table_S2_Unemployment_3_6M_H3.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
 
 log close


 
  /******************************************************************************
 ***********************************HYPOTHESIS 4**********************************
 *******************************************************************************/
 
 
 /******************************************************************************
 ***********************************SAMPLE 1*************************************
 *******************************************************************************/
  clear
 use "$years_path\EU_SILC_Employed_No_work", clear 
 log using "$years_path\Results\STUDY_PLOS_ONE_SAPMLE 1_RESULTS UNEMPLOYMENT 3_6M_H4", replace
 
 
 /**************NRRS DEFINED AS 67% AND 33% OF EU-AVERAGE WAGE*****************/
 mixed transition_work $his_unemp##c.nrrpc_67_33 $control_HH_S1 $control_country   || country:, vce(robust)
 estimates store S1H4_M3_NRR_67_33
 
  /**************NRRS DEFINED AS 100% AND 50% OF EU-AVERAGE WAGE*****************/
 mixed transition_work $his_unemp##c.nrrpc_100_50 $control_HH_S1 $control_country   || country:, vce(robust)
 estimates store S1H4_M3_NRR_100_50
 
 
   /**************NRRS DEFINED AS 50% AND 25% OF EU-AVERAGE WAGE*****************/
 mixed transition_work $his_unemp##c.nrrpc_50_25 $control_HH_S1 $control_country  || country:, vce(robust)
 estimates store S1H4_M3_NRR_50_25
 
 
   /**************NRRS DEFINED AS 200% AND 100% OF EU-AVERAGE WAGE*****************/
 mixed transition_work $his_unemp##c.nrrpc_200_100 $control_HH_S1 $control_country   || country:, vce(robust)
 estimates store S1H4_M3_NRR_200_100
 
 
   /**************NRRS DEFINED AS 150% AND 75% OF EU-AVERAGE WAGE*****************/
 mixed transition_work $his_unemp##c.nrrpc_150_75 $control_HH_S1 $control_country  || country:, vce(robust)
 estimates store S1H4_M3_NRR_150_75

 esttab S1H4_M3_NRR_200_100 S1H4_M3_NRR_150_75 using  "$years_path\Results\Table_S1_Unemployment_3_6M_H4_extra.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain

  esttab S1H4_M3_NRR_67_33 S1H4_M3_NRR_100_50 S1H4_M3_NRR_50_25 using  "$years_path\Results\Table_S1_Unemployment_3_6M_H4.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
   log close
   
 

  /******************************************************************************
 ***********************************SAMPLE 2*************************************
 *******************************************************************************/
 
 clear 
 use "$years_path\EU_SILC_Employed_Part_time", clear 
 log using "$years_path\Results\STUDY_PLOS_ONE_SAPMLE S_RESULTS UNEMPLOYMENT 3_6M_H4", replace
 
 /**************NRRS DEFINED AS 67% AND 33% OF EU-AVERAGE WAGE*****************/
 
 mixed transition_FT $his_unemp##c.nrrpc_67_33 $control_HH_S2 $control_country || country:, vce(robust)
 estimates store S2H4_M3_NRR_67_33
 
 
  /**************NRRS DEFINED AS 100% AND 50% OF EU-AVERAGE WAGE*****************/
 mixed transition_FT $his_unemp##c.nrrpc_100_50 $control_HH_S2 $control_country   || country:, vce(robust)
 estimates store S2H4_M3_NRR_100_50
 
 
   /**************NRRS DEFINED AS 50% AND 25% OF EU-AVERAGE WAGE*****************/
 mixed transition_FT $his_unemp##c.nrrpc_50_25 $control_HH_S2 $control_country  || country:, vce(robust)
 estimates store S2H4_M3_NRR_50_25

  /**************NRRS DEFINED AS 200% AND 100% OF EU-AVERAGE WAGE*****************/
 mixed transition_FT $his_unemp##c.nrrpc_200_100 $control_HH_S2 $control_country   || country:, vce(robust)
 estimates store S2H4_M3_NRR_200_100
 
 
   /**************NRRS DEFINED AS 150% AND 75% OF EU-AVERAGE WAGE*****************/
 mixed transition_FT $his_unemp##c.nrrpc_150_75 $control_HH_S2 $control_country  || country:, vce(robust)
 estimates store S2H4_M3_NRR_150_75

  esttab S2H4_M3_NRR_200_100 S2H4_M3_NRR_150_75  using  "$years_path\Results\Table_S2_Unemployment_3_6M_H4_extra.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
 
  esttab S2H4_M3_NRR_67_33 S2H4_M3_NRR_100_50 S2H4_M3_NRR_50_25 using  "$years_path\Results\Table_S2_Unemployment_3_6M_H4.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
   log close
 
  /******************************************************************************
 ***********************************HYPOTHESIS 5**********************************
 *******************************************************************************/
 
 
 /******************************************************************************
 ***********************************SAMPLE 1*************************************
 *******************************************************************************/
  clear 
 use "$years_path\EU_SILC_Employed_No_work", clear 
 log using "$years_path\Results\STUDY_PLOS_ONE_SAPMLE 1_RESULTS UNEMPLOYMENT 3_6M_H5", replace

 
 /**************MTRS DEFINED AS 67% AND 33% OF EU-AVERAGE WAGE*****************/
  mixed transition_work $his_unemp##c.MTR_NW_PT_67_33  $control_HH_S1 $control_country  || country:, vce(robust)
  estimates store S1H5_67_33

   
  
 /**************MTRS DEFINED AS 100% AND 50% OF EU-AVERAGE WAGE*****************/
  mixed transition_work $his_unemp##c.MTR_NW_PT_100_50  $control_HH_S1 $control_country   || country:, vce(robust)
  estimates store S1H5_100_50

 
 /**************MTRS DEFINED AS 50% AND 25% OF EU-AVERAGE WAGE*****************/
 
  mixed transition_work $his_unemp##c.MTR_NW_PT_50_25  $control_HH_S1 $control_country  || country:, vce(robust)
  estimates store S1H5_50_25

 
 
 /**************MTRS DEFINED AS 150% AND 75% OF EU-AVERAGE WAGE*****************/
  mixed transition_work $his_unemp##c.MTR_NW_PT_150_75  $control_HH_S1 $control_country   || country:, vce(robust)
  estimates store S1H5_150_75

 
  /**************MTRS DEFINED AS 200% AND 100% OF EU-AVERAGE WAGE*****************/
  mixed transition_work $his_unemp##c.MTR_NW_PT_200_100  $control_HH_S1 $control_country  || country:, vce(robust)
  estimates store S1H5_200_100

  
   
  esttab   S1H5_67_33 S1H5_100_50 S1H5_50_25 S1H5_150_75 S1H5_200_100 using  "$years_path\Results\Table_S1_Unemployment_3_6M_H5.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
  log close

  
  
  
    clear 
 use "$years_path\EU_SILC_Employed_No_work", clear 
 log using "$years_path\Results\STUDY_PLOS_ONE_SAPMLE 1_RESULTS UNEMPLOYMENT 3_6M_H5", replace

 replace unemployed3_6m = . if nrrpc_67_33 == .
 /**************MTRS DEFINED AS 67% AND 33% OF EU-AVERAGE WAGE*****************/
  mixed transition_work $his_unemp##c.MTR_NW_FT_67_33  $control_HH_S1 $control_country  || country:, vce(robust)
  estimates store S1H5_67_33

   
  
 /**************MTRS DEFINED AS 100% AND 50% OF EU-AVERAGE WAGE*****************/
  mixed transition_work $his_unemp##c.MTR_NW_FT_100_50  $control_HH_S1 $control_country   || country:, vce(robust)
  estimates store S1H5_100_50

 
 /**************MTRS DEFINED AS 50% AND 25% OF EU-AVERAGE WAGE*****************/
 
  mixed transition_work $his_unemp##c.MTR_NW_FT_50_25  $control_HH_S1 $control_country  || country:, vce(robust)
  estimates store S1H5_50_25

 
 
 /**************MTRS DEFINED AS 150% AND 75% OF EU-AVERAGE WAGE*****************/
  mixed transition_work $his_unemp##c.MTR_NW_FT_150_75  $control_HH_S1 $control_country   || country:, vce(robust)
  estimates store S1H5_150_75

 
  /**************MTRS DEFINED AS 200% AND 100% OF EU-AVERAGE WAGE*****************/
  mixed transition_work $his_unemp##c.MTR_NW_FT_200_100  $control_HH_S1 $control_country  || country:, vce(robust)
  estimates store S1H5_200_100

  
   
  esttab   S1H5_67_33 S1H5_100_50 S1H5_50_25 S1H5_150_75 S1H5_200_100 using  "$years_path\Results\Table_S1_Unemployment_3_6M_H5_MTRS_FT.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
  log close

  
  
   /******************************************************************************
 ***********************************SAMPLE 2*************************************
 *******************************************************************************/
 clear 
 use "$years_path\EU_SILC_Employed_Part_time", clear 
 log using "$years_path\Results\STUDY_PLOS_ONE_SAPMLE 2_RESULTS UNEMPLOYMENT 3_6M_H5", replace
 replace unemployed3_6m = . if nrrpc_67_33 == .
 /*log using "$years_path\Results\STUDY_PLOS_ONE_SAPMLE 2_RESULTS UNEMPLOYMENT 3M_H5", replace*/
 
 /**************MTRS DEFINED AS 67% AND 33% OF EU-AVERAGE WAGE*****************/
  mixed transition_FT $his_unemp##c.MTR_PT_FT_67_33  $control_HH_S2 $control_country   || country:, vce(robust)
  estimates store S2H5_67_33
   
  
 /**************MTRS DEFINED AS 100% AND 50% OF EU-AVERAGE WAGE*****************/
  mixed transition_FT $his_unemp##c.MTR_PT_FT_100_50  $control_HH_S2 $control_country   || country:, vce(robust)
  estimates store S2H5_100_50
 
 /**************MTRS DEFINED AS 50% AND 25% OF EU-AVERAGE WAGE*****************/
  mixed transition_FT $his_unemp##c.MTR_PT_FT_50_25  $control_HH_S2 $control_country  || country:, vce(robust)
  estimates store S2H5_50_25
 
 
 /**************MTRS DEFINED AS 150% AND 75% OF EU-AVERAGE WAGE*****************/
  mixed transition_FT $his_unemp##c.MTR_PT_FT_150_75  $control_HH_S2 $control_country  || country:, vce(robust)
  estimates store S2H5_150_75
 
  /**************MTRS DEFINED AS 200% AND 100% OF EU-AVERAGE WAGE*****************/
  mixed transition_FT $his_unemp##c.MTR_PT_FT_200_100  $control_HH_S2 $control_country  || country:, vce(robust)
  estimates store S2H5_200_100
  
   
  esttab S2H5_67_33 S2H5_100_50 S2H5_50_25 S2H5_150_75 S2H5_200_100 using  "$years_path\Results\Table_S2_Unemployment_3_6M_H5.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
  log close
  
  
  
  
  
  

 

  
  
    
   /*******************************************************************************
 *********************UNEMPLOYMENT DEFINED AS OVER 6 MONTHS ******************
 *******************************************************************************/
  
  
   /******************************************************************************
 ***********************************HYPOTHESIS 1*************************************
 *******************************************************************************/
  
 /******************************************************************************
 ***********************************SAMPLE 1*************************************
 *******************************************************************************/
  
 clear 
 use "$years_path\EU_SILC_Employed_No_work", clear 
 log using "$years_path\STUDY_PLOS_ONE_SAPMLE 1_RESULTS UNEMPLOYMENT_6M_over_H1", replace
  
 global control_HH_S1 "i.married nchild i.child0_3 i.child4_6 i.child7_12 i.quintile age age_p i.education_woman i.education_man i.occupation_man"
 global  control_country "share_women_responsibility share_men_responsibility female_participation unemployment_rate"
 global his_unemp "i.unemployed_over_6m"
 /*******CHECKING FOR MULTICOLINEARITY WHEN INCLUDING THE POLICY VARIABLES OF INTEREST AS CONTROL VARIABLES******/
 
 regress transition_work $his_unemp $control_HH_S1 $control_country childcare_0_3_G childcare_4_6_G childcare_7_12_G nrrpc_67_33 MTR_NW_PT_67_33  MTR_NW_FT_67_33
 estat vif
 
 regress transition_work $his_unemp $control_HH_S1 $control_country
  estat vif
 /****BASELINE MODELS******/
 mixed transition_work $his_unemp $control_HH_S1 $control_country || country:, vce(robust)
 estimates store baseline
 

 
 esttab baseline using  "$years_path\Table_S1_Unemployment_6M_over_H1.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
 log close
 
 
 
  /*****************************************************************************
 *****************************SAMPLE 2**********************************
 *****************************************************************************/

 clear 
 use "$years_path\EU_SILC_Employed_Part_time", clear 
 log using "$years_path\STUDY_PLOS_ONE_SAPMLE 2_RESULTS UNEMPLOYMENT_6M_over_H1", replace
 global control_HH_S2 "i.married nchild i.child0_3 i.child4_6 i.child7_12 i.quintile age age_p i.education_woman i.education_man i.occupation_man i.occupation_woman"

  /*******CHECKING FOR MULTICOLINEARITY WHEN INCLUDING THE POLICY VARIABLES OF INTEREST AS CONTROL VARIABLES******/
  
 regress transition_FT i.unemployed3m $control_HH_S2 $control_country childcare_0_3_G childcare_4_6_G childcare_7_12_G nrrpc_67_33 MTR_PT_FT_67_33 
 estat vif
 
  regress transition_FT i.unemployed3m $control_HH_S2 $control_country  
 estat vif
 
/********HYPOTHESIS 1 - BASELINE MODELS**********/
 mixed transition_FT $his_unemp $control_HH_S2 $control_country || country:, vce(robust)
  estimates store baseline

 
 esttab baseline using  "$years_path\Table_S2_Unemployment_6M_over_H1.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
 log close
 

   /******************************************************************************
 ***********************************HYPOTHESIS 2**********************************
 *******************************************************************************/
 
 
 
  /****MOTHERS VS NOT MOTHERS**/
   /******************************************************************************
 ***********************************SAMPLE 1*************************************
 *******************************************************************************/

 clear 
 use "$years_path\EU_SILC_Employed_No_work", clear 
 
 generate mother = 1 if nchild != 0
 replace mother = 0 if mother == .
 
 log using "$years_path\Results\STUDY_PLOS_ONE_SAPMLE 1_RESULTS UNEMPLOYMENT_6M_over_H2_MOTHERS VS NOT MOTHERS", replace
 mixed transition_work $his_unemp##i.mother  $control_HH_S1 $control_country   || country:, vce(robust)
 estimates store S1_Unemp_H2_MOM
 
 esttab S1_Unemp_H2_MOM using  "$years_path\Results\Table_S1_Unemployment_6M_over_H2_MOTHERS VS NOT MOTHERS.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
 log close
  
  
     /******************************************************************************
 ***********************************SAMPLE 2*************************************
 *******************************************************************************/
  
 clear 
 use "$years_path\EU_SILC_Employed_Part_time", clear 
 generate mother = 1 if nchild != 0
 replace mother = 0 if mother == .
 

  
 log using "$years_path\Results\STUDY_PLOS_ONE_SAPMLE 2_RESULTS UNEMPLOYMENT_6M_over_H2_MOTHERS VS NOT MOTHERS", replace
 mixed transition_FT $his_unemp##i.mother  $control_HH_S2 $control_country   || country:, vce(robust)
 estimates store S2_Unemp_H2_MOM
 
 esttab S2_Unemp_H2_MOM  using  "$years_path\Results\Table_S2_Unemployment_6M_over_H2_MOTHERS VS NOT MOTHERS.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
 log close
 
  
 /*********************BY CHILDREN AGE*************************/
 
  /******************************************************************************
 ***********************************SAMPLE 1*************************************
 *******************************************************************************/
 clear 
 use "$years_path\EU_SILC_Employed_No_work", clear  
 log using "$years_path\Results\STUDY_PLOS_ONE_SAPMLE 1_RESULTS UNEMPLOYMENT_6M_over_H2", replace
 
 mixed transition_work $his_unemp##i.child0_3 $his_unemp##i.child4_6 $his_unemp##i.child7_12 $control_HH_S1 $control_country  || country:, vce(robust)
 estimates store S1_Unemp_H2_CHILD

 esttab S1_Unemp_H2_CHILD using  "$years_path\Results\Table_S1_Unemployment_6M_over_H2.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
 log close
 
  /******************************************************************************
 ***********************************SAMPLE 2*************************************
 *******************************************************************************/
 
 clear 
 use "$years_path\EU_SILC_Employed_Part_time", clear 
  
 log using "$years_path\Results\STUDY_PLOS_ONE_SAPMLE 2_RESULTS UNEMPLOYMENT_6M_over_H2", replace
 mixed transition_FT $his_unemp##i.child0_3 $his_unemp##i.child4_6 $his_unemp##i.child7_12 $control_HH_S2 $control_country  || country:, vce(robust)
 estimates store S2_Unemp_H2_CHILD
 
 esttab S2_Unemp_H2_CHILD using  "$years_path\Results\Table_S2_Unemployment_6M_over_H2.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
 log close
 

 
  /******************************************************************************
 ***********************************HYPOTHESIS 3**********************************
 *******************************************************************************/
 
  
  /***************GENERAL MEASURE OF CHILDCARE*****************/ 
 
   /******************************************************************************
 ***********************************SAMPLE 1*************************************
 *******************************************************************************/

 clear 
 use "$years_path\EU_SILC_Employed_No_work", clear 
 
 log using "$years_path\Results\STUDY_PLOS_ONE_SAPMLE 1_RESULTS UNEMPLOYMENT_6M_over_H3_GENERAL MEASURE OF CHILDCARE", replace

 
 /***************GENERAL MEASURE OF CHILDCARE*****************/ 
 mixed transition_work $his_unemp##i.child0_3##c.childcare_0_3_G $his_unemp##i.child4_6##c.childcare_4_6_G $his_unemp##i.child7_12##c.childcare_7_12_G $control_HH_S1 $control_country  || country:, vce(robust)
 estimates store S1H3_3M_CareG
 
 
  /***************PART-TIME MEASURE OF CHILDCARE*****************/ 
 mixed transition_work $his_unemp##i.child0_3##c.childcare_0_3_PT $his_unemp##i.child4_6##c.childcare_4_6_PT $his_unemp##i.child7_12##c.childcare_7_12_PT $control_HH_S1 $control_country || country:, vce(robust)
 estimates store S1H3_3M_CarePT
 
  
   /***************FULL-TIME MEASURE OF CHILDCARE*****************/ 
  mixed transition_work $his_unemp##i.child0_3##c.childcare_0_3_FT $his_unemp##i.child4_6##c.childcare_4_6_FT $his_unemp##i.child7_12##c.childcare_7_12_FT $control_HH_S1 $control_country || country:, vce(robust)
  estimates store S1H3_3M_CareFT

 
  esttab S1H3_3M_CareG S1H3_3M_CarePT S1H3_3M_CareFT using  "$years_path\Results\Table_S1_Unemployment_6M_over_H3.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
  
 
 log close

  
 /******************************************************************************
 ***********************************SAMPLE 2*************************************
 *******************************************************************************/


 clear 
 set more off
 use "$years_path\EU_SILC_Employed_Part_time", clear 
 log using "$years_path\Results\STUDY_PLOS_ONE_SAPMLE 2_RESULTS UNEMPLOYMENT_6M_over_H3", replace
   /***************GENERAL MEASURE OF CHILDCARE*****************/ 
   mixed transition_FT $his_unemp##i.child0_3##c.childcare_0_3_G $his_unemp##i.child4_6##c.childcare_4_6_G $his_unemp##i.child7_12##c.childcare_7_12_G $control_HH_S2 $control_country  || country:, vce(robust)
 estimates store S2H3_3M_CareG
  
  
  /***************PART-TIME MEASURE OF CHILDCARE*****************/ 
 
 mixed transition_FT $his_unemp##i.child0_3##c.childcare_0_3_PT $his_unemp##i.child4_6##c.childcare_4_6_PT $his_unemp##i.child7_12##c.childcare_7_12_PT $control_HH_S2 $control_country || country:, vce(robust)
 estimates store S2H3_3M_CarePT
   
 
   /***************FULL-TIME MEASURE OF CHILDCARE*****************/ 
 
 mixed transition_FT $his_unemp##i.child0_3##c.childcare_0_3_FT $his_unemp##i.child4_6##c.childcare_4_6_FT $his_unemp##i.child7_12##c.childcare_7_12_FT $control_HH_S2 $control_country  || country:, vce(robust)
 estimates store S2H3_3M_CareFT
   
  
 esttab S2H3_3M_CareG S2H3_3M_CarePT S2H3_3M_CareFT using  "$years_path\Results\Table_S2_Unemployment_6M_over_H3.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
 
 log close


 
  /******************************************************************************
 ***********************************HYPOTHESIS 4**********************************
 *******************************************************************************/
 
 
 /******************************************************************************
 ***********************************SAMPLE 1*************************************
 *******************************************************************************/
  clear 
 use "$years_path\EU_SILC_Employed_No_work", clear 
 log using "$years_path\Results\STUDY_PLOS_ONE_SAPMLE 1_RESULTS UNEMPLOYMENT_6M_over_H4", replace
 
 
 /**************NRRS DEFINED AS 67% AND 33% OF EU-AVERAGE WAGE****************/
 mixed transition_work $his_unemp##c.nrrpc_67_33 $control_HH_S1 $control_country   || country:, vce(robust)
 estimates store S1H4_M3_NRR_67_33
 
  /**************NRRS DEFINED AS 100% AND 50% OF EU-AVERAGE WAGE*****************/
 mixed transition_work $his_unemp##c.nrrpc_100_50 $control_HH_S1 $control_country   || country:, vce(robust)
 estimates store S1H4_M3_NRR_100_50
 
 
   /**************NRRS DEFINED AS 50% AND 25% OF EU-AVERAGE WAGE*****************/
 mixed transition_work $his_unemp##c.nrrpc_50_25 $control_HH_S1 $control_country  || country:, vce(robust)
 estimates store S1H4_M3_NRR_50_25

 
 
  /**************NRRS DEFINED AS 200% AND 100% OF EU-AVERAGE WAGE*****************/
 mixed transition_work $his_unemp##c.nrrpc_200_100 $control_HH_S1 $control_country   || country:, vce(robust)
 estimates store S1H4_M3_NRR_200_100
 
 
   /**************NRRS DEFINED AS 150% AND 75% OF EU-AVERAGE WAGE*****************/
 mixed transition_work $his_unemp##c.nrrpc_150_75 $control_HH_S1 $control_country  || country:, vce(robust)
 estimates store S1H4_M3_NRR_150_75
 
   esttab   S1H4_M3_NRR_200_100 S1H4_M3_NRR_150_75 S1H4_M3_NRR_67_33 S1H4_M3_NRR_100_50 S1H4_M3_NRR_50_25 using "$years_path\Results\Table_S1_Unemployment_6M_over_H4.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
   log close
   
 

  /******************************************************************************
 ***********************************SAMPLE 2*************************************
 *******************************************************************************/
 
 clear 
 use "$years_path\EU_SILC_Employed_Part_time", clear 
  log using "$years_path\Results\STUDY_PLOS_ONE_SAPMLE S_RESULTS UNEMPLOYMENT_6M_over_H4", replace
 
 /**************NRRS DEFINED AS 67% AND 33% OF EU-AVERAGE WAGE****************/
 
 mixed transition_FT $his_unemp##c.nrrpc_67_33 $control_HH_S2 $control_country || country:, vce(robust)
 estimates store S2H4_M3_NRR_67_33
 
 
  /**************NRRS DEFINED AS 100% AND 50% OF EU-AVERAGE WAGE*****************/
 mixed transition_FT $his_unemp##c.nrrpc_100_50 $control_HH_S2 $control_country   || country:, vce(robust)
 estimates store S2H4_M3_NRR_100_50
 
 
   /**************NRRS DEFINED AS 50% AND 25% OF EU-AVERAGE WAGE*****************/
 mixed transition_FT $his_unemp##c.nrrpc_50_25 $control_HH_S2 $control_country  || country:, vce(robust)
 estimates store S2H4_M3_NRR_50_25
 
 
   /**************NRRS DEFINED AS 200% AND 100% OF EU-AVERAGE WAGE*****************/
 mixed transition_FT $his_unemp##c.nrrpc_200_100 $control_HH_S2 $control_country   || country:, vce(robust)
 estimates store S1H4_M3_NRR_200_100
 
 
   /**************NRRS DEFINED AS 150% AND 75% OF EU-AVERAGE WAGE*****************/
 mixed transition_FT $his_unemp##c.nrrpc_150_75 $control_HH_S2 $control_country  || country:, vce(robust)
 estimates store S1H4_M3_NRR_150_75

 
  esttab S1H4_M3_NRR_200_100 S1H4_M3_NRR_150_75 S2H4_M3_NRR_67_33 S2H4_M3_NRR_100_50 S2H4_M3_NRR_50_25 using  "$years_path\Results\Table_S2_Unemployment_6M_over_H4 .csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
 
   log close
 
  /******************************************************************************
 ***********************************HYPOTHESIS 5**********************************
 *******************************************************************************/
 
 
 /******************************************************************************
 ***********************************SAMPLE 1*************************************
 *******************************************************************************/
  clear
 use "$years_path\EU_SILC_Employed_No_work", clear 
 log using "$years_path\Results\STUDY_PLOS_ONE_SAPMLE 1_RESULTS UNEMPLOYMENT_6M_over_H5", replace

 
 /**************MTRS DEFINED AS 67% AND 33% OF EU-AVERAGE WAGE*****************/
  mixed transition_work $his_unemp##c.MTR_NW_PT_67_33  $control_HH_S1 $control_country  || country:, vce(robust)
  estimates store S1H5_67_33

   
  
 /**************MTRS DEFINED AS 100% AND 50% OF EU-AVERAGE WAGE*****************/
  mixed transition_work $his_unemp##c.MTR_NW_PT_100_50  $control_HH_S1 $control_country   || country:, vce(robust)
  estimates store S1H5_100_50

 
 /**************MTRS DEFINED AS 50% AND 25% OF EU-AVERAGE WAGE*****************/
 
  mixed transition_work $his_unemp##c.MTR_NW_PT_50_25  $control_HH_S1 $control_country  || country:, vce(robust)
  estimates store S1H5_50_25

 
 
 /**************MTRS DEFINED AS 150% AND 75% OF EU-AVERAGE WAGE*****************/
  mixed transition_work $his_unemp##c.MTR_NW_PT_150_75  $control_HH_S1 $control_country   || country:, vce(robust)
  estimates store S1H5_150_75

 
  /**************MTRS DEFINED AS 200% AND 100% OF EU-AVERAGE WAGE*****************/
  mixed transition_work $his_unemp##c.MTR_NW_PT_200_100  $control_HH_S1 $control_country  || country:, vce(robust)
  estimates store S1H5_200_100

  
   
  esttab   S1H5_67_33 S1H5_100_50 S1H5_50_25 S1H5_150_75 S1H5_200_100 using  "$years_path\Results\Table_S1_Unemployment_6M_over_H5.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
  log close

  
  
  
      clear 
 use "$years_path\EU_SILC_Employed_No_work", clear 
 log using "$years_path\Results\STUDY_PLOS_ONE_SAPMLE 1_RESULTS UNEMPLOYMENT_6M_over_H5_MTRS_FT", replace

  replace unemployed_over_6m = . if nrrpc_67_33 == .
 /**************MTRS DEFINED AS 67% AND 33% OF EU-AVERAGE WAGE*****************/
  mixed transition_work $his_unemp##c.MTR_NW_FT_67_33  $control_HH_S1 $control_country  || country:, vce(robust)
  estimates store S1H5_67_33

   
  
 /**************MTRS DEFINED AS 100% AND 50% OF EU-AVERAGE WAGE*****************/
  mixed transition_work $his_unemp##c.MTR_NW_FT_100_50  $control_HH_S1 $control_country   || country:, vce(robust)
  estimates store S1H5_100_50

 
 /**************MTRS DEFINED AS 50% AND 25% OF EU-AVERAGE WAGE*****************/
 
  mixed transition_work $his_unemp##c.MTR_NW_FT_50_25  $control_HH_S1 $control_country  || country:, vce(robust)
  estimates store S1H5_50_25

 
 
 /**************MTRS DEFINED AS 150% AND 75% OF EU-AVERAGE WAGE*****************/
  mixed transition_work $his_unemp##c.MTR_NW_FT_150_75  $control_HH_S1 $control_country   || country:, vce(robust)
  estimates store S1H5_150_75

 
  /**************MTRS DEFINED AS 200% AND 100% OF EU-AVERAGE WAGE*****************/
  mixed transition_work $his_unemp##c.MTR_NW_FT_200_100  $control_HH_S1 $control_country  || country:, vce(robust)
  estimates store S1H5_200_100

  
   
  esttab   S1H5_67_33 S1H5_100_50 S1H5_50_25 S1H5_150_75 S1H5_200_100 using  "$years_path\Results\Table_S1_Unemployment_6M_over_H5_MTRS_FT.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
  log close
  
   /******************************************************************************
 ***********************************SAMPLE 2*************************************
 *******************************************************************************/
 clear 
 use "$years_path\EU_SILC_Employed_Part_time", clear 
 log using "$years_path\Results\STUDY_PLOS_ONE_SAPMLE 2_RESULTS UNEMPLOYMENT_6M_over_H5", replace
 /*log using "$years_path\Results\STUDY_PLOS_ONE_SAPMLE 2_RESULTS UNEMPLOYMENT 3M_H5", replace*/
 
 /**************MTRS DEFINED AS 67% AND 33% OF EU-AVERAGE WAGE*****************/
  mixed transition_FT $his_unemp##c.MTR_PT_FT_67_33  $control_HH_S2 $control_country   || country:, vce(robust)
  estimates store S2H5_67_33
   
  
 /**************MTRS DEFINED AS 100% AND 50% OF EU-AVERAGE WAGE*****************/
  mixed transition_FT $his_unemp##c.MTR_PT_FT_100_50  $control_HH_S2 $control_country   || country:, vce(robust)
  estimates store S2H5_100_50
 
 /**************MTRS DEFINED AS 50% AND 25% OF EU-AVERAGE WAGE*****************/
  mixed transition_FT $his_unemp##c.MTR_PT_FT_50_25  $control_HH_S2 $control_country  || country:, vce(robust)
  estimates store S2H5_50_25
 
 
 /**************MTRS DEFINED AS 150% AND 75% OF EU-AVERAGE WAGE*****************/
  mixed transition_FT $his_unemp##c.MTR_PT_FT_150_75  $control_HH_S2 $control_country  || country:, vce(robust)
  estimates store S2H5_150_75
 
  /**************MTRS DEFINED AS 200% AND 100% OF EU-AVERAGE WAGE*****************/
  mixed transition_FT $his_unemp##c.MTR_PT_FT_200_100  $control_HH_S2 $control_country  || country:, vce(robust)
  estimates store S2H5_200_100
  
   
  esttab S2H5_67_33 S2H5_100_50 S2H5_50_25 S2H5_150_75 S2H5_200_100 using  "$years_path\Results\Table_S2_Unemployment_6M_over_H5.csv", star(* 0.05 ** 0.01 *** 0.001) se label replace plain
  log close
  
  
  
  
  

  
  