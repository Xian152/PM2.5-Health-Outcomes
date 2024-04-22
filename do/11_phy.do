**********个人层面基本情况和回归分析--横截面数据基线年情况**********
use "${outdata}/airpollution health fin.dta",clear
	gen agegroup = age >=80 
*** baseline情况	
	* baseline cross 
	duplicates tag id ,gen(dup)
	sort id year
	bysort id : gen order = _n
	
	duplicates drop id,force	
	drop if phys  == . 
	
save "${outdata}/airpollution health fin_cross_phys.dta",replace	

	global weather moister_12 sunshine_12 windspeed_12 precipitation_12 temperture_12
******Table 1 
	table1,by(wave)  vars(gender cat\ age contn \ edug cat\ residence cat\ pa cat\  moister_12 contn \ sunshine_12 contn \ windspeed_12 contn \ precipitation_12 contn \ temperture_12 contn \ pm25_12 contn \ pm1_12  contn \ inversedate_12 contn \ ) format(%2.1f) one mis saving("${out}/phys_Table1_DS1_05-14base.xls",replace) 	

******Table 2
	reghdfe pm25_12 inversedate_12 ${weather} , absorb(wave gbcode) cluster(gbcode)
	outreg2 using "${out}/phys_Table 2_first stage.xls",replace excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(F-statistics,e(F))  keep(inversedate_12) 
	reghdfe pm25_12 inversedate_12 ${weather} [aw=w_weight], absorb(wave gbcode) 
	outreg2 using "${out}/phys_Table 2_first stage.xls",append excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(F-statistics,e(F)) keep(inversedate_12)
	reghdfe pm1_12 inversedate_12 ${weather} , absorb(wave gbcode) 
	outreg2 using "${out}/phys_Table 2_first stage.xls",append excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(F-statistics,e(F)) keep(inversedate_12)
	reghdfe pm1_12 inversedate_12 ${weather} [aw=w_weight] , absorb(wave gbcode) 
	outreg2 using "${out}/phys_Table 2_first stage.xls",append excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(F-statistics,e(F)) keep(inversedate_12)
	
******Table 3
cls
	reghdfe phys  pm25_12 ${weather}  , absorb(wave gbcode) 
	outreg2 using "${out}/phys_regression.xls",replace excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(F-statistics,e(F)) keep(pm25_12)
	ivreghdfe phys  (pm25_12 = inversedate_12) ${weather}  i.wave i.gbcode
	outreg2 using "${out}/phys_regression.xls",append excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(F-statistics,e(F))  keep(pm25_12)
	ivreghdfe  phys   age gender (pm25_12 = inversedate_12) ${weather}  i.wave i.gbcode [aw=w_weight]
	outreg2 using "${out}/phys_regression.xls",append excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(F-statistics,e(F))  keep(pm25_12 age gender)
	
******Table 4 by education
cls 	
	ivreghdfe phys  age gender (pm25_12 = inversedate_12) ${weather}  i.wave i.gbcode [aw=w_weight] if edug == 1 	
	outreg2 using "${out}/phys_regression_educ.xls",replace excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(F-statistics,e(F))  keep(pm25_12 age gender) ctitle(Illiteracy)
	ivreghdfe phys  age gender (pm25_12 = inversedate_12) ${weather}  i.wave i.gbcode [aw=w_weight] if edug == 2 
	outreg2 using "${out}/phys_regression_educ.xls",append excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(F-statistics,e(F))  keep(pm25_12 age gender) ctitle(Primary School)
	ivreghdfe phys  age gender (pm25_12 = inversedate_12) ${weather}  i.wave i.gbcode [aw=w_weight] if edug == 3 	
	outreg2 using "${out}/phys_regression_educ.xls",append excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(F-statistics,e(F))  keep(pm25_12 age gender) ctitle(Middle school or higher)	
******Table 5 by gender age 
cls 	
	ivreghdfe phys age gender  (pm25_12 = inversedate_12) ${weather}  i.wave i.gbcode [aw=w_weight] if agegroup == 0		
	outreg2 using "${out}/phys_regression_agesex.xls",replace excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(F-statistics,e(F))   keep(pm25_12 age gender) ctitle(Age between 65-79)
	ivreghdfe phys  age gender (pm25_12 = inversedate_12) ${weather} i.wave i.gbcode [aw=w_weight] if agegroup == 1		
	outreg2 using "${out}/phys_regression_agesex.xls",append excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(F-statistics,e(F))    keep(pm25_12 age gender) ctitle(Age over 80)
	ivreghdfe phys  age gender (pm25_12 = inversedate_12) ${weather}  i.wave i.gbcode [aw=w_weight] if gender == 1 	
	outreg2 using "${out}/phys_regression_agesex.xls",append excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(F-statistics,e(F))    keep(pm25_12 age gender) ctitle(Male)
	ivreghdfe phys age gender  (pm25_12 = inversedate_12) ${weather}  i.wave i.gbcode [aw=w_weight] if gender == 0
	outreg2 using "${out}/phys_regression_agesex.xls",append excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(F-statistics,e(F))   keep(pm25_12 age gender) ctitle(Female)
		
	
******Table 6 by physsical activity
cls 	
	ivreghdfe phys age gender  (pm25_12 = inversedate_12) ${weather}  i.wave i.gbcode [aw=w_weight] if pa == 1		
	outreg2 using "${out}/phys_regression_pa.xls",replace excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(F-statistics,e(F))   keep(pm25_12 age gender) ctitle(current & start pa < 50)
	ivreghdfe phys  age gender (pm25_12 = inversedate_12) ${weather} i.wave i.gbcode [aw=w_weight] if pa == 2		
	outreg2 using "${out}/phys_regression_pa.xls",append excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(F-statistics,e(F))    keep(pm25_12 age gender) ctitle(current & start PA >=50)
	ivreghdfe phys  age gender (pm25_12 = inversedate_12) ${weather}  i.wave i.gbcode [aw=w_weight] if pa == 3			
	outreg2 using "${out}/phys_regression_pa.xls",append excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(F-statistics,e(F))    keep(pm25_12 age gender) ctitle(former)
	ivreghdfe phys age gender  (pm25_12 = inversedate_12) ${weather}  i.wave i.gbcode [aw=w_weight] if pa == 4		
	outreg2 using "${out}/phys_regression_pa.xls",append excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(F-statistics,e(F))   keep(pm25_12 age gender) ctitle(never)

	
******Table 6 by origin
cls 	
	ivreghdfe phys age gender  (pm25_12 = inversedate_12) ${weather} i.wave i.gbcode [aw=w_weight] if area == 1
	outreg2 using "${out}/phys_regression_region.xls",replace excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(F-statistics,e(F))   keep(pm25_12 age gender) ctitle(East)
	ivreghdfe phys age gender  (pm25_12 = inversedate_12) ${weather} i.wave i.gbcode [aw=w_weight] if area == 2	
	outreg2 using "${out}/phys_regression_region.xls",append excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(F-statistics,e(F))   keep(pm25_12 age gender) ctitle(North)
	ivreghdfe phys age gender  (pm25_12 = inversedate_12) ${weather} i.wave i.gbcode [aw=w_weight] if area == 3	
	outreg2 using "${out}/phys_regression_region.xls",append excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(F-statistics,e(F))   keep(pm25_12 age gender) ctitle(South)
	ivreghdfe phys age gender  (pm25_12 = inversedate_12) ${weather} i.wave i.gbcode [aw=w_weight] if area == 4	
	outreg2 using "${out}/phys_regression_region.xls",append excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(F-statistics,e(F))   keep(pm25_12 age gender) ctitle(Middle)
	ivreghdfe phys age gender  (pm25_12 = inversedate_12) ${weather} i.wave i.gbcode [aw=w_weight] if area == 5	
	outreg2 using "${out}/phys_regression_region.xls",append excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(F-statistics,e(F))   keep(pm25_12 age gender) ctitle(Southwest)
	ivreghdfe phys age gender  (pm25_12 = inversedate_12) ${weather}  i.wave i.gbcode [aw=w_weight] if area == 6	
	outreg2 using "${out}/phys_regression_region.xls",append excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(F-statistics,e(F))   keep(pm25_12 age gender) ctitle(Northwest)
	ivreghdfe phys age gender  (pm25_12 = inversedate_12) ${weather}  i.wave i.gbcode [aw=w_weight] if area == 7	
	outreg2 using "${out}/phys_regression_region.xls",append excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(F-statistics,e(F))   keep(pm25_12 age gender)	 ctitle( Northeast)
	
******Table 6obust	
cls
	reg phys  pm1_12  ${weather}   i.wave i.gbcode 	
	outreg2 using "${out}/phys_rob_regression_PM1.xls",replace excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(F-statistics,e(F)) keep(pm1_12 )
	ivreghdfe phys  (pm1_12  = inversedate_12) ${weather} i.wave i.gbcode 
	outreg2 using "${out}/phys_rob_regression_PM1.xls",append excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(F-statistics,e(F)) keep(pm1_12 )
	ivreghdfe phys  age gender (pm1_12  = inversedate_12) ${weather} i.wave i.gbcode [aw=w_weight]
	outreg2 using "${out}/phys_rob_regression_PM1.xls",append excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(F-statistics,e(F)) keep(pm1_12  age gender)

	
	
/*	
****************************** cls *********************	
	superscatter pm25_12 physmeans fittype(lfitse) fitoptions(lwidth(vthick)) legend(ring(0)) percent color(dkorange)  m(s) msize(small)  name(pm25,replace) title(Assoseation of PM 2.5 & ADL)

	superscatter pm25_12 iphysmeans fittype(lfitse) fitoptions(lwidth(vthick)) legend(ring(0)) percent color(dkorange)  m(s) msize(small)  name(pm25,replace) title(Assoseation of PM 2.5 & IADL)
	
	superscatter pm25_12 inversedatemeans fittype(lfitse) fitoptions(lwidth(vthick)) legend(ring(0)) percent color(dkorange)  m(s) msize(small)  name(pm25,replace) title(Assoseation of PM 2.5 & dates of inverse temperture)	
	
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
	egen physs = anymatch(fra_turn fra_standup fra_book ),value(1)	
	reg physs pm25_12 pa smkl dril diet age gender
	ivregress 2sls physs pa smkl dril diet age gender (pm25_12 = inversedate_12)
*/
	
	
