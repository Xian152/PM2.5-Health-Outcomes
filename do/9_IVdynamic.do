**********个人层面基本情况和回归分析--面板面数据基线年情况**********
use "${outdata}/airpollution health fin.dta",clear
	gen agegroup = age >= 80 
	keep if age >=80
*** panel情况	
	drop adl_miss adl_sum adlMiss adlSum
	egen adl_miss= rowmiss(bathing dressing toileting transferring continence feeding)
	egen adl_sum = rowtotal(bathing dressing toileting transferring continence feeding) 
	replace adl_sum = . if adl_miss > 1
	drop if adl_sum  == . | iadl_sum  == .
	xtset id wave 
save "${outdata}/airpollution health fin_panel.dta",replace	

******Figure S1 & S2 interview date 
	hist month,xlabel(1(1)12)
	hist year,xlabel(2005(1)2019)
	
******first stage
	xtreg pm25_1d thermal_inv12 i.wave i.gbcode  moister_1d sunshine_1d precipitation_1d temperture_1d windspeed_1d ,fe  

******Second stage-ADL
cls
	ivreghdfe adl_sum age gender (pm25_36m = inversedate_36m) moister_36m sunshine_36m precipitation_36m temperture_36m windspeed_36m  , absorb(wave gbcode) 
	outreg2 using "${out}/regression_IV_basic_panel.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))   

foreach k in 24m 12m 6m 90d 30d 7d{
	ivreghdfe adl_sum age gender (pm25_`k' =  inversedate_`k') moister_`k' sunshine_`k' precipitation_`k' temperture_`k' windspeed_`k'  , absorb(wave gbcode) 
	outreg2 using "${out}/regression_IV_basic_panel.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))  keep(pm25_`k' pm25_1d age gender)
	}
	
	
	foreach k in 7d 90d 12m  6m  24m 36m  {
		ivreghdfe adl_sum  age gender (pm25_`k' = inversedate_`k') moister_`k' sunshine_`k' precipitation_`k' temperture_`k' windspeed_`k'   i.wave i.gbcode,r 
		outreg2 using "${out}/regression_IV_basic_panel.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))  keep(pm25_`k' age gender)
	}
	xtreg iadl_sum age gender   pm25_12 i.wave i.gbcode ${weather}   ,fe 
	outreg2 using "${out}/regression_panel.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(F-statistics,e(F)) keep(pm25_12 age gender)
	ivreghdfe iadl_sum  age gender (pm25_12 = inversedate_12) ${weather}    , absorb(wave gbcode) 
	outreg2 using "${out}/regression_panel.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))  keep(pm25_12 age gender)
	

**# Bookmark #1
cls
	ivreghdfe adl_sum  age (pm25_12 = inversedate_12) ${weather}   if gender == 1 ,absorb(wave gbcode) 
	outreg2 using "${out}/regression_panel_sub.xls",replace excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))  keep(pm25_12 age)
	ivreghdfe adl_sum  age (pm25_12 = inversedate_12) ${weather}    if gender == 0 ,absorb(wave gbcode) 
	outreg2 using "${out}/regression_panel_sub.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat))  keep(pm25_12 age )
	
	ivreghdfe iadl_sum  age (pm25_12 = inversedate_12) ${weather}  if gender == 1 ,absorb(wave gbcode) 
	outreg2 using "${out}/regression_panel_sub.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat)) keep(pm25_12 age)
	ivreghdfe iadl_sum  age (pm25_12 = inversedate_12) ${weather}    if gender == 0 ,absorb(wave gbcode) 
	outreg2 using "${out}/regression_panel_sub.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat)) keep(pm25_12 age )	
	
	
	ivreghdfe adl_sum  age gender (pm25_12 = inversedate_12) ${weather}  if edug == 1 , absorb(waver gbcode) 
	outreg2 using "${out}/regression_panel_sub.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat)) keep(pm25_12 age gender)
	ivreghdfe adl_sum  age gender (pm25_12 = inversedate_12) ${weather}   if edug == 2  , absorb(wave gbcode) 
	outreg2 using "${out}/regression_panel_sub.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat)) keep(pm25_12 age gender)	
	ivreghdfe adl_sum age gender  age gender (pm25_12 = inversedate_12) ${weather}   if edug == 3  , absorb(wave gbcode) 
	outreg2 using "${out}/regression_panel_sub.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat)) keep(pm25_12 age gender)	

	ivreghdfe iadl_sum  age gender (pm25_12 = inversedate_12) ${weather}  if edug == 1 , absorb(wave gbcode) 
	outreg2 using "${out}/regression_panel_sub.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(KP F-statistics,e(widstat)) keep(pm25_12 age gender)
	ivreghdfe iadl_sum  age gender (pm25_12 = inversedate_12) ${weather}   if edug == 2  , absorb(wave gbcode) 
	outreg2 using "${out}/regression_panel_sub.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat)) keep(pm25_12 age gender)	
	ivreghdfe iadl_sum  age gender (pm25_12 = inversedate_12) ${weather}   if edug == 3  , absorb(wave gbcode) 
	outreg2 using "${out}/regression_panel_sub.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat)) keep(pm25_12 age gender)	

******Table 8 robust
cls
	xtreg adl_sum  pm1_12 ${weather}  ,fe 
	outreg2 using "${out}/regression_panel——pm1.xls",replace excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(F-statistics,e(F)) keep(pm1_12)
	ivreghdfe adl_sum  age gender (pm1_12 = inversedate_12) ${weather}   ,fe 
	outreg2 using "${out}/regression_panel——pm1.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)    keep(pm1_12 age gender)
	
	xtreg iadl_sum  pm1_12 ${weather}  ,fe 
	outreg2 using "${out}/regression_panel——pm1.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(F-statistics,e(F)) keep(pm1_12)
	ivreghdfe iadl_sum  age gender (pm1_12= inversedate_12) ${weather}    ,fe 
	outreg2 using "${out}/regression_panel——pm1.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)   keep(pm1_12 age gender)

	