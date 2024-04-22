**********个人层面基本情况和回归分析--横截面数据基线年情况**********
use "${outdata}/airpollution health fin.dta",clear
	gen agegroup = age >=80 
*** baseline情况	
	* baseline cross 
	duplicates tag id ,gen(dup)
	sort id year
	bysort id : gen order = _n
	duplicates drop id,force	
	
	drop adl_miss adl_sum adlMiss adlSum
	egen adl_miss= rowmiss(bathing dressing toileting transferring continence feeding)
	egen adl_sum = rowtotal(bathing dressing toileting transferring continence feeding) 
	replace adl_sum = . if adl_miss > 1
	drop if adl_sum  == . | iadl_sum  == .

	
save "${outdata}/airpollution health fin_cross.dta",replace	

	gen adl_bi = adl_sum >= 1 if adl_sum !=.
	gen iadl_bi = iadl_sum >=4 if iadl_sum !=.
	gen iadl_cat = 0 if inrange(iadl_sum,0,2)
	replace iadl_cat = 1 if inrange(iadl_sum,3,7)
	replace iadl_cat = 2 if iadl_sum== 8

	global weather moister_12m sunshine_12m windspeed_12m precipitation_12m temperture_12m
******Table 1 
	table1,by(adl_bi)  vars(pm25_12 contn\  ) 	format(%2.1f) one mis saving("${out}/Table1_DS1base.xls",replace) 	
	table1,by(iadl_bi)  vars(pm25_12 contn\  ) 	format(%2.1f) one mis saving("${out}/Table1_DS1_adl.xls",replace) 	
	table1,by(iadl_cat)  vars(pm25_12 contn \  ) format(%2.1f) one mis saving("${out}/Table1_DS1base_iadl.xls",replace) 	


	table1,by(adl_bi)  vars(gender cat\ age contn \ edug cat\ residence cat\ pa cat\  moister_12 contn \ sunshine_12 contn \ windspeed_12 contn \ precipitation_12 contn \ temperture_12 contn \ pm25_12 contn \ pm1_12  contn \ inversedate_12 contn \ ) format(%2.1f) one mis saving("${out}/Table1_DS1_05-14base_adl.xls",replace) 	

*****Table 2
	ivreghdfe adl_sum  age gender  (pm25_12m = inversedate_12m) ${weather} ,  absorb(wave gbcode) r first 
	outreg2 using "${out}/Table 2_first stage.xls",replace excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))  
	reghdfe pm1_12 inversedate_12 ${weather} ,  absorb(wave gbcode)   first
	outreg2 using "${out}/Table 2_first stage.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))  keep(inversedate_12)

******Table 3
cls
	reghdfe adl_sum   age gender pm25_12m ${weather}  ,  absorb(wave gbcode)  
	outreg2 using "${out}/Table 3_basic_regression.xls",replace excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  keep(pm25_12)
	ivreghdfe adl_sum  age gender  (pm25_12 = inversedate_12) ${weather} ,  absorb(wave gbcode) r first 
	outreg2 using "${out}/Table 3_basic_regression.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))  keep(pm25_12)
	
	reghdfe iadl_sum  age gender  pm25_12m ${weather} ,  absorb(wave gbcode) 
	outreg2 using "${out}/Table 3_basic_regression.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) keep(pm25_12)
	ivreghdfe  iadl_sum  age gender (pm25_12 = inversedate_12) ${weather} ,  absorb(wave gbcode) r first  
	outreg2 using "${out}/Table 3_basic_regression.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat)) keep(pm25_12)
	
******Table 4 by education
cls 	
	ivreghdfe adl_sum  age gender (pm25_12m = inversedate_12m) ${weather}   if edug == 1 	 ,  absorb(wave gbcode) r first
	outreg2 using "${out}/Table 4_regression_educ.xls",replace excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))  keep(pm25_12 age gender) ctitle(Illiteracy)
	ivreghdfe adl_sum  age gender (pm25_12 = inversedate_12) ${weather}   if edug == 2 ,  absorb(wave gbcode) r first
	outreg2 using "${out}/Table 4_regression_educ.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))  keep(pm25_12 age gender) ctitle(Primary School)
	ivreghdfe adl_sum  age gender (pm25_12 = inversedate_12) ${weather}    if edug == 3 ,  absorb(wave gbcode) r first	
	outreg2 using "${out}/Table 4_regression_educ.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))  keep(pm25_12 age gender) ctitle(Middle school or higher)

	ivreghdfe iadl_sum  age gender (pm25_12 = inversedate_12) ${weather}  if edug == 1 	,  absorb(wave gbcode) r first
	outreg2 using "${out}/Table 4_regression_educ.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))  keep(pm25_12 age gender) ctitle(Illiteracy)
	ivreghdfe iadl_sum  age gender (pm25_12 = inversedate_12) ${weather}   if edug == 2 ,  absorb(wave gbcode) r first
	outreg2 using "${out}/Table 4_regression_educ.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))  keep(pm25_12 age gender) ctitle(Primary School)
	ivreghdfe iadl_sum  age gender (pm25_12 = inversedate_12) ${weather}   if edug == 3 ,  absorb(wave gbcode) r first
	outreg2 using "${out}/Table 4_regression_educ.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))  keep(pm25_12 age gender) ctitle(Middle school or higher)
	
******Table 5 by gender 
cls 	
	ivreghdfe adl_sum  age  (pm25_12 = inversedate_12) ${weather}   if gender == 1 	,  absorb(wave gbcode) r first
	outreg2 using "${out}/Table 5_regression_sex.xls",replace excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))    keep(pm25_12 age gender) ctitle(Male)
	ivreghdfe adl_sum age    (pm25_12 = inversedate_12) ${weather}    if gender == 0 	,  absorb(wave gbcode) r first
	outreg2 using "${out}/Table 5_regression_sex.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))   keep(pm25_12 age gender) ctitle(Female)
	
	ivreghdfe iadl_sum  age   (pm25_12 = inversedate_12) ${weather}  if gender == 1 ,  absorb(wave gbcode) r first	 
	outreg2 using "${out}/Table 5_regression_sex.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))    keep(pm25_12 age gender) ctitle(Male)
	ivreghdfe iadl_sum age    (pm25_12 = inversedate_12) ${weather}  if gender == 0  ,  absorb(wave gbcode) r first
	outreg2 using "${out}/Table 5_regression_sex.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))   keep(pm25_12 age gender) ctitle(Female)	
	
	
******Table 6 by physical activity
cls 	
	ivreghdfe adl_sum age gender  (pm25_12 = inversedate_12) ${weather}    if pa == 1	  ,  absorb(wave gbcode) r first
	outreg2 using "${out}/Table 6_regression_pa.xls",replace excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))   keep(pm25_12 age gender) ctitle(current & start pa < 50)
	ivreghdfe adl_sum  age gender (pm25_12 = inversedate_12) ${weather}   if pa == 2	,  absorb(wave gbcode) r first	 
	outreg2 using "${out}/Table 6_regression_pa.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))    keep(pm25_12 age gender) ctitle(current & start PA >=50)
	ivreghdfe adl_sum  age gender (pm25_12 = inversedate_12) ${weather}     if pa == 3	,  absorb(wave gbcode) r first	 	
	outreg2 using "${out}/Table 6_regression_pa.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))    keep(pm25_12 age gender) ctitle(former)
	ivreghdfe adl_sum age gender  (pm25_12 = inversedate_12) ${weather}   if pa == 4	  ,  absorb(wave gbcode) r first	
	outreg2 using "${out}/Table 6_regression_pa.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))   keep(pm25_12 age gender) ctitle(never)
	
	ivreghdfe iadl_sum age gender  (pm25_12 = inversedate_12) ${weather}     if pa == 1	 	 ,  absorb(wave gbcode) r first
	outreg2 using "${out}/Table 6_regression_pa.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))   keep(pm25_12 age gender) ctitle(current & start pa < 50)
	ivreghdfe iadl_sum  age gender (pm25_12 = inversedate_12) ${weather}    if pa == 2	,  absorb(wave gbcode) r first 	 
	outreg2 using "${out}/Table 6_regression_pa.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))    keep(pm25_12 age gender) ctitle(current & start PA >=50)
	ivreghdfe iadl_sum  age gender (pm25_12 = inversedate_12) ${weather}    if pa == 3	 	,  absorb(wave gbcode) r first
	outreg2 using "${out}/Table 6_regression_pa.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))    keep(pm25_12 age gender) ctitle(former)
	ivreghdfe iadl_sum age gender  (pm25_12 = inversedate_12) ${weather}    if pa == 4	 ,  absorb(wave gbcode) r first 	
	outreg2 using "${out}/Table 6_regression_pa.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))   keep(pm25_12 age gender) ctitle(never)

	
******Table 7 by origin
cls 	
	ivreghdfe adl_sum age gender  (pm25_12 = inversedate_12) ${weather}    if area == 1  ,  absorb(wave gbcode) r first
	outreg2 using "${out}/Table 7regression_region.xls",replace excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))   keep(pm25_12 age gender) ctitle(East)
	ivreghdfe adl_sum age gender  (pm25_12 = inversedate_12) ${weather}   if area == 2	 ,  absorb(wave gbcode) r first 
	outreg2 using "${out}/Table 7regression_region.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))   keep(pm25_12 age gender) ctitle(North)
	ivreghdfe adl_sum age gender  (pm25_12 = inversedate_12) ${weather}    if area == 3	 ,  absorb(wave gbcode) r first
	outreg2 using "${out}/Table 7regression_region.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))   keep(pm25_12 age gender) ctitle(South)
	ivreghdfe adl_sum age gender  (pm25_12 = inversedate_12) ${weather}   if area == 4	 ,  absorb(wave gbcode) r first
	outreg2 using "${out}/Table 7regression_region.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))   keep(pm25_12 age gender) ctitle(Middle)
	ivreghdfe adl_sum age gender  (pm25_12 = inversedate_12) ${weather}   if area == 5	  ,  absorb(wave gbcode) r first
	outreg2 using "${out}/Table 7regression_region.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))   keep(pm25_12 age gender) ctitle(Southwest)
	ivreghdfe adl_sum age gender  (pm25_12 = inversedate_12) ${weather}    if area == 6	 ,  absorb(wave gbcode) r first
	outreg2 using "${out}/Table 7regression_region.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))   keep(pm25_12 age gender) ctitle(Northwest)
	ivreghdfe adl_sum age gender  (pm25_12 = inversedate_12) ${weather}     if area == 7 	,  absorb(wave gbcode) r first  
	outreg2 using "${out}/Table 7regression_region.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))   keep(pm25_12 age gender)	 ctitle( Northeast)
	
	ivreghdfe iadl_sum age gender  (pm25_12 = inversedate_12) ${weather}    if area == 1 ,  absorb(wave gbcode) r first
	outreg2 using "${out}/Table 7regression_region.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))   keep(pm25_12 age gender) ctitle(East)
	ivreghdfe iadl_sum age gender  (pm25_12 = inversedate_12) ${weather}    if area == 2	 ,  absorb(wave gbcode) r first
	outreg2 using "${out}/Table 7regression_region.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))   keep(pm25_12 age gender) ctitle(North)
	ivreghdfe iadl_sum age gender  (pm25_12 = inversedate_12) ${weather}   if area == 3	 ,  absorb(wave gbcode) r first
	outreg2 using "${out}/Table 7regression_region.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))   keep(pm25_12 age gender) ctitle(South)
	ivreghdfe iadl_sum age gender  (pm25_12 = inversedate_12) ${weather}    if area == 4	  ,  absorb(wave gbcode) r first
	outreg2 using "${out}/Table 7regression_region.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))   keep(pm25_12 age gender) ctitle(Middle)
	ivreghdfe iadl_sum age gender  (pm25_12 = inversedate_12) ${weather}    if area == 5	 ,  absorb(wave gbcode) r first
	outreg2 using "${out}/Table 7regression_region.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))   keep(pm25_12 age gender) ctitle(Southwest)
	ivreghdfe iadl_sum age gender  (pm25_12 = inversedate_12) ${weather}    if area == 6	 ,  absorb(wave gbcode) r first
	outreg2 using "${out}/Table 7regression_region.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))   keep(pm25_12 age gender) ctitle(Northwest)
	ivreghdfe iadl_sum age gender  (pm25_12 = inversedate_12) ${weather}    if area == 7	  ,  absorb(wave gbcode) r first
	outreg2 using "${out}/Table 7regression_region.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))   keep(pm25_12 age gender)	 ctitle( Northeast)	
******Table 8 robust	
cls
	ivreghdfe adl_sum age gender  (pm25_12 = inversedate_12) ${weather}     ,  absorb(wave gbcode) r first 
	outreg2 using "${out}/Table 8_robustness.xls",replace excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))   keep(pm25_12 age gender) ctitle(Base case)
	ivreghdfe adl_sum age gender  (pm25_12 = inversedate_12) ${weather}     ,cluster(gbcode)  absorb(wave gbcode) r first
	outreg2 using "${out}/Table 8_robustness.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))   keep(pm25_12 age gender) ctitle(Alternative clustering)
/*	
	tostring wave gbcode,gen(wave_1 gbcode_1)
	gen wavegbcode = wave_1 + "-"+gbcode_1
	egen wavegbcode_id = group(wavegbcode) */
	ivreghdfe adl_sum age gender  (pm25_12 = inversedate_12) ${weather}     , absorb(wavegbcode_id)
	outreg2 using "${out}/Table 8_robustness.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))   keep(pm25_12 age gender) ctitle(Alternative fixed effect)

	ivreghdfe iadl_sum age gender  (pm25_12 = inversedate_12) ${weather}     ,  absorb(wave gbcode) r first 
	outreg2 using "${out}/Table 8_robustness.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))   keep(pm25_12 age gender) ctitle(Base case)
	ivreghdfe iadl_sum age gender  (pm25_12 = inversedate_12) ${weather}    ,cluster(gbcode)  absorb(wave gbcode) r first
	outreg2 using "${out}/Table 8_robustness.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))   keep(pm25_12 age gender) ctitle(Alternative clustering)
	
	ivreghdfe iadl_sum age gender  (pm25_12 = inversedate_12) ${weather}     , absorb(wavegbcode_id)
	outreg2 using "${out}/Table 8_robustness.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))   keep(pm25_12 age gender) ctitle(Alternative fixed effect)

		
	

****************************** cls *********************	
	
	label var pm25_12 "average PM 2.5 for the past year"
	label var inversedate_12 "sum of date with inverse temperture in the past year"
	label var adl_sum "sum of ADL"
	label var iadl_sum "sum of IADL"
	superscatter pm25_12 adl_sum, means fittype(lfitci) fitoptions(lwidth(vthick)) legend(ring(0)) percent color(dkorange)  m(s) msize(small)  name(pm25, replace) title(Association of PM 2.5 & ADL)

	superscatter pm25_12 iadl_sum, means fittype(lfitci) fitoptions(lwidth(vthick)) legend(ring(0)) percent color(dkorange)  m(s) msize(small)  name(pm25, replace) title(Association of PM 2.5 & IADL)


	bysort wave
	superscatter pm25_12 adl_sum fittype(lfitpval) fitoptions(lwidth(vthick)) legend(ring(0)) percent color(dkorange)  m(s) msize(small)  name(pm25,replace) title(Assoseation of PM 2.5 & ADL)

	superscatter pm25_12 iadl_sum fittype(lfitpval) fitoptions(lwidth(vthick)) legend(ring(0)) percent color(dkorange)  m(s) msize(small)  name(pm25,replace) title(Assoseation of PM 2.5 & IADL)
	
	superscatter pm25_12 inversedatemeans fittype(lfitpval) fitoptions(lwidth(vthick)) legend(ring(0)) percent color(dkorange)  m(s) msize(small)  name(pm25,replace) title(Assoseation of PM 2.5 & dates of inverse temperture)	
	
	predict pm25_hat 
	foreach k in fra_turn fra_standup fra_book {
		mlogit `k' pm25_12 pa smkl dril diet age gender fra_se fra_hypertension fra_diabetes fra_htdisea fra_strokecvd fra_copd fra_tb fra_cataract fra_glaucoma fra_cancer leisure srhealth waterqual edug ethnisetyesidence psycho,rr 
		mlogit `k' pm25_hat pa smkl dril diet age gender fra_se fra_hypertension fra_diabetes fra_htdisea fra_strokecvd fra_copd fra_tb fra_cataract fra_glaucoma fra_cancer leisure srhealth waterqual edug ethnisetyesidence psycho ,rr		
	}
	foreach k in fra_turn fra_standup fra_book {
		mlogit `k' pm25_12 pa smkl dril diet age gender,rr 
		mlogit `k' pm25_hat pa smkl dril diet age gender ,rr		
	}

	cls
	egen phys = anymatch(fra_turn fra_standup fra_book ),value(1)	
	reg phys pm25_12 pa smkl dril diet age gender
	ivregress 2sls phys pa smkl dril diet age gender (pm25_12 = inversedate_12)

	
	
