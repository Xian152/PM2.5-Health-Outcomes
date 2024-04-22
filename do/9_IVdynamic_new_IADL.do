**********个人层面基本情况和回归分析--面板面数据基线年情况**********
use "${outdata}/airpollution health fin_panel.dta",clear
	codebook id // 22,126 	
	gen season = 1 if inrange(monthin,1,3)
	replace season = 2 if inrange(monthin,4,6)
	replace season = 3 if inrange(monthin,7,9)
	replace season = 4 if inrange(monthin,10,12)	
	
cap drop trend
gen trend = 1 if yearin ==2005 & monthin == 3
replace trend = monthin -2 if yearin ==2005
replace trend = monthin +10 if yearin ==2006
replace trend = monthin +22 if yearin ==2007
replace trend = monthin +34 if yearin ==2008
replace trend = monthin +46 if yearin ==2009
replace trend = monthin +58 if yearin ==2010
replace trend = monthin +70 if yearin ==2011
replace trend = monthin +82 if yearin ==2012
replace trend = monthin +94 if yearin ==2013
replace trend = monthin +106 if yearin ==2014
replace trend = monthin +118 if yearin ==2015
replace trend = monthin +130 if yearin ==2016
replace trend = monthin +142 if yearin ==2017
replace trend = monthin +154 if yearin ==2018
replace trend = monthin +166 if yearin ==2019

egen fix1 = group(gbcode id)
egen fix2 = group(gbcode wave)
egen fix3 = group(gbcode yearin)
egen fix4 = group(gbcode yearin id)


global robust1 trend ,absorb(id wave  gbcode ) r cluster(gbcode)
global robust2 trend ,absorb(wave  gbcode ) r cluster(gbcode)
global robust3 trend ,absorb(yearin  gbcode ) r cluster(gbcode)
global robust4 trend ,absorb(id yearin   gbcode ) r cluster(gbcode)
global robust5 trend ,absorb(id  gbcode ) r cluster(gbcode)
global robust6 trend ,absorb(fix1) r cluster(gbcode)
global robust7 trend ,absorb(fix2) r cluster(gbcode)
global robust8 trend ,absorb(fix3) r cluster(gbcode)
global robust10 trend ,absorb(id wave  gbcode ) r  
global robust11 trend ,absorb(wave  gbcode ) r  
global robust12 trend ,absorb(yearin  gbcode ) r  
global robust13 trend ,absorb(id yearin   gbcode ) r  
global robust14 trend ,absorb(id  gbcode ) r  

******Second adl_basic_panel_ADL
drop if adl_sum== . | iadl_sum== .
drop if  pm25_36m == .
codebook id // 22,132 
	
	
cls
foreach r in 1 2 3 4 5 6 7 8   10 11 12 13 14{
	ivreghdfe iadl_sum age gender  (pm25_36m pm25_1d= thermal_inv12_36m thermal_inv12_1d)  moister_36m sunshine_36m precipitation_36m temperture_36m windspeed_36m ${robust`r'}
	
	outreg2 using "${out}/regression_IV_basic_panel_IADL_`r'.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))  keep(pm25_36m pm25_1d age gender)
	
foreach k in 24m 12m 6m 90d 30d 7d{
	ivreghdfe iadl_sum age gender (pm25_`k' pm25_1d =  thermal_inv12_`k' thermal_inv12_1d) moister_`k' sunshine_`k' precipitation_`k' temperture_`k' windspeed_`k'   ${robust`r'}
	outreg2 using "${out}/regression_IV_basic_panel_IADL_`r'.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))  keep(pm25_`k' pm25_1d age gender)
	}
}

******Second adl_bin_panel_ADL
foreach r in 1 2 3 4 5 6 7 8   10 11 12 13 14{
	ivreghdfe iadl_sum age gender  ( pm25_2039_36m pm25_4059_36m pm25_6079_36m pm25_80100_36m pm25_100over_36m  =  thermal_inv12_2_36m thermal_inv12_3_36m thermal_inv12_4_36m thermal_inv12_5_36m thermal_inv12_6_36m) moister_36m sunshine_36m precipitation_36m temperture_36m windspeed_36m  ${robust`r'}
	outreg2 using "${out}/regression_IV_bin_panel_IADL_`r'.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))   

foreach k in 24m 12m 6m 90d 30d 7d{
	ivreghdfe iadl_sum age gender ( pm25_2039_`k' pm25_4059_`k' pm25_6079_`k' pm25_80100_`k' pm25_100over_`k'  =  thermal_inv12_2_`k' thermal_inv12_3_`k' thermal_inv12_4_`k' thermal_inv12_5_`k' thermal_inv12_6_`k') moister_`k' sunshine_`k' precipitation_`k' temperture_`k' windspeed_`k' ${robust`r'}
	outreg2 using "${out}/regression_IV_bin_panel_IADL_`r'.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))   
	}
}	
******Second stageadl_sumbasic_panel_ADL
foreach r in 1 2 3 4 5 6 7 8   10 11 12 13 14{
	foreach adl in  FRAvisit FRAshopping FRAcook FRAwashcloth FRAwalk1km FRAlift FRAstandup FRApublictrans{
		drop if `adl' == .
			ivreghdfe `adl' age gender (pm25_36m pm25_1d= thermal_inv12_36m thermal_inv12_1d)  moister_36m sunshine_36m precipitation_36m temperture_36m windspeed_36m ${robust`r'}
			outreg2 using "${out}/regression_IV_basic_panel_IADL_`adl'_`r'.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))  keep(pm25_36m pm25_1d age gender)
			
		foreach k in 24m 12m 6m 90d 30d 7d{
			ivreghdfe `adl' age gender (pm25_`k' pm25_1d =  thermal_inv12_`k' thermal_inv12_1d) moister_`k' sunshine_`k' precipitation_`k' temperture_`k' windspeed_`k'  ${robust`r'}
			outreg2 using "${out}/regression_IV_basic_panel_IADL_`adl'_`r'.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1)
 symbol(***,**,*)  addstat(KP F-statistics,e(widstat))  keep(pm25_`k' pm25_1d age gender)
		}

	******Second stageadl_sumbin_panel_ADL
	ivreghdfe `adl' age gender ( pm25_2039_36m pm25_4059_36m pm25_6079_36m pm25_80100_36m pm25_100over_36m  =  thermal_inv12_2_36m thermal_inv12_3_36m thermal_inv12_4_36m thermal_inv12_5_36m thermal_inv12_6_36m) moister_36m sunshine_36m precipitation_36m temperture_36m windspeed_36m ${robust`r'}
		outreg2 using "${out}/regression_IV_bin_panel_IADL_`adl'_`r'.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))   

	foreach k in 24m 12m 6m 90d 30d 7d{
		ivreghdfe `adl' age gender ( pm25_2039_`k' pm25_4059_`k' pm25_6079_`k' pm25_80100_`k' pm25_100over_`k'  =  thermal_inv12_2_`k' thermal_inv12_3_`k' thermal_inv12_4_`k' thermal_inv12_5_`k' thermal_inv12_6_`k') moister_`k' sunshine_`k' precipitation_`k' temperture_`k' windspeed_`k'  ${robust`r'}
		outreg2 using "${out}/regression_IV_bin_panel_IADL_`adl'_`r'.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))   
		}
	}		
}




use "${outdata}/airpollution health fin_panel.dta",clear
	codebook id // 22,126 	
	gen season = 1 if inrange(monthin,1,3)
	replace season = 2 if inrange(monthin,4,6)
	replace season = 3 if inrange(monthin,7,9)
	replace season = 4 if inrange(monthin,10,12)	
	
cap drop trend
gen trend = 1 if yearin ==2005 & monthin == 3
replace trend = monthin -2 if yearin ==2005
replace trend = monthin +10 if yearin ==2006
replace trend = monthin +22 if yearin ==2007
replace trend = monthin +34 if yearin ==2008
replace trend = monthin +46 if yearin ==2009
replace trend = monthin +58 if yearin ==2010
replace trend = monthin +70 if yearin ==2011
replace trend = monthin +82 if yearin ==2012
replace trend = monthin +94 if yearin ==2013
replace trend = monthin +106 if yearin ==2014
replace trend = monthin +118 if yearin ==2015
replace trend = monthin +130 if yearin ==2016
replace trend = monthin +142 if yearin ==2017
replace trend = monthin +154 if yearin ==2018
replace trend = monthin +166 if yearin ==2019

egen fix1 = group(gbcode id)
egen fix2 = group(gbcode wave)
egen fix3 = group(gbcode yearin)
egen fix4 = group(gbcode yearin id)


global robust1 trend ,absorb(id wave  gbcode ) r cluster(gbcode)
global robust2 trend ,absorb(wave  gbcode ) r cluster(gbcode)
global robust3 trend ,absorb(yearin  gbcode ) r cluster(gbcode)
global robust4 trend ,absorb(id yearin   gbcode ) r cluster(gbcode)
global robust5 trend ,absorb(id  gbcode ) r cluster(gbcode)
global robust6 trend ,absorb(fix1 ) r cluster(gbcode)
global robust7 trend ,absorb(fix2) r cluster(gbcode)
global robust8 trend ,absorb(fix3) r cluster(gbcode)
global robust10 trend ,absorb(id wave  gbcode ) r  
global robust11 trend ,absorb(wave  gbcode ) r  
global robust12 trend ,absorb(yearin  gbcode ) r  
global robust13 trend ,absorb(id yearin   gbcode ) r  
global robust14 trend ,absorb(id  gbcode ) r  

******Second adl_basic_panel_ADL
drop if adl_sum== . | adl_sum== .
drop if  pm25_36m == .
codebook id // 22,132 
	
	
cls
foreach r in 1 2 3 4 5 6 7 8   10 11 12 13 14{
	ivreghdfe adl_sum age gender  (pm25_36m pm25_1d= thermal_inv12_36m thermal_inv12_1d)  moister_36m sunshine_36m precipitation_36m temperture_36m windspeed_36m ${robust`r'}
	
	outreg2 using "${out}/regression_IV_basic_panel_adl_`r'.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))  keep(pm25_36m pm25_1d age gender)
	
foreach k in 24m 12m 6m 90d 30d 7d{
	ivreghdfe adl_sum age gender (pm25_`k' pm25_1d =  thermal_inv12_`k' thermal_inv12_1d) moister_`k' sunshine_`k' precipitation_`k' temperture_`k' windspeed_`k'   ${robust`r'}
	outreg2 using "${out}/regression_IV_basic_panel_adl_`r'.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))  keep(pm25_`k' pm25_1d age gender)
	}
}

******Second adl_bin_panel_ADL
foreach r in 1 2 3 4 5 6 7 8   10 11 12 13 14{
	ivreghdfe adl_sum age gender  ( pm25_2039_36m pm25_4059_36m pm25_6079_36m pm25_80100_36m pm25_100over_36m  =  thermal_inv12_2_36m thermal_inv12_3_36m thermal_inv12_4_36m thermal_inv12_5_36m thermal_inv12_6_36m) moister_36m sunshine_36m precipitation_36m temperture_36m windspeed_36m  ${robust`r'}
	outreg2 using "${out}/regression_IV_bin_panel_adl_`r'.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))   

foreach k in 24m 12m 6m 90d 30d 7d{
	ivreghdfe adl_sum age gender ( pm25_2039_`k' pm25_4059_`k' pm25_6079_`k' pm25_80100_`k' pm25_100over_`k'  =  thermal_inv12_2_`k' thermal_inv12_3_`k' thermal_inv12_4_`k' thermal_inv12_5_`k' thermal_inv12_6_`k') moister_`k' sunshine_`k' precipitation_`k' temperture_`k' windspeed_`k' ${robust`r'}
	outreg2 using "${out}/regression_IV_bin_panel_adl_`r'.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))   
	}
}	
******Second stageadl_sumbasic_panel_ADL
foreach r in 1 2 3 4 5 6 7 8   10 11 12 13 14{
	foreach adl in  bathing dressing toileting transferring continence feeding{
		drop if `adl' == .
			ivreghdfe `adl' age gender (pm25_36m pm25_1d= thermal_inv12_36m thermal_inv12_1d)  moister_36m sunshine_36m precipitation_36m temperture_36m windspeed_36m ${robust`r'}
			outreg2 using "${out}/regression_IV_basic_panel_adl_`adl'_`r'.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))  keep(pm25_36m pm25_1d age gender)
			
		foreach k in 24m 12m 6m 90d 30d 7d{
			ivreghdfe `adl' age gender (pm25_`k' pm25_1d =  thermal_inv12_`k' thermal_inv12_1d) moister_`k' sunshine_`k' precipitation_`k' temperture_`k' windspeed_`k'  ${robust`r'}
			outreg2 using "${out}/regression_IV_basic_panel_adl_`adl'_`r'.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1)
 symbol(***,**,*)  addstat(KP F-statistics,e(widstat))  keep(pm25_`k' pm25_1d age gender)
		}

	******Second stageadl_sumbin_panel_ADL
	ivreghdfe `adl' age gender ( pm25_2039_36m pm25_4059_36m pm25_6079_36m pm25_80100_36m pm25_100over_36m  =  thermal_inv12_2_36m thermal_inv12_3_36m thermal_inv12_4_36m thermal_inv12_5_36m thermal_inv12_6_36m) moister_36m sunshine_36m precipitation_36m temperture_36m windspeed_36m ${robust`r'}
		outreg2 using "${out}/regression_IV_bin_panel_adl_`adl'_`r'.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))   

	foreach k in 24m 12m 6m 90d 30d 7d{
		ivreghdfe `adl' age gender ( pm25_2039_`k' pm25_4059_`k' pm25_6079_`k' pm25_80100_`k' pm25_100over_`k'  =  thermal_inv12_2_`k' thermal_inv12_3_`k' thermal_inv12_4_`k' thermal_inv12_5_`k' thermal_inv12_6_`k') moister_`k' sunshine_`k' precipitation_`k' temperture_`k' windspeed_`k'  ${robust`r'}
		outreg2 using "${out}/regression_IV_bin_panel_adl_`adl'_`r'.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))   
		}
	}		
}
				
				
				
				
				
				
**********个人层面基本情况和回归分析--面板面数据基线年情况**********
use "${outdata}/airpollution health fin_panel.dta",clear
keep if age>=80
	codebook id // 22,126 	
	gen season = 1 if inrange(monthin,1,3)
	replace season = 2 if inrange(monthin,4,6)
	replace season = 3 if inrange(monthin,7,9)
	replace season = 4 if inrange(monthin,10,12)	
	
cap drop trend
gen trend = 1 if yearin ==2005 & monthin == 3
replace trend = monthin -2 if yearin ==2005
replace trend = monthin +10 if yearin ==2006
replace trend = monthin +22 if yearin ==2007
replace trend = monthin +34 if yearin ==2008
replace trend = monthin +46 if yearin ==2009
replace trend = monthin +58 if yearin ==2010
replace trend = monthin +70 if yearin ==2011
replace trend = monthin +82 if yearin ==2012
replace trend = monthin +94 if yearin ==2013
replace trend = monthin +106 if yearin ==2014
replace trend = monthin +118 if yearin ==2015
replace trend = monthin +130 if yearin ==2016
replace trend = monthin +142 if yearin ==2017
replace trend = monthin +154 if yearin ==2018
replace trend = monthin +166 if yearin ==2019

egen fix1 = group(gbcode id)
egen fix2 = group(gbcode wave)
egen fix3 = group(gbcode yearin)
egen fix4 = group(gbcode yearin id)


global robust1 trend ,absorb(id wave  gbcode ) r cluster(gbcode)
global robust2 trend ,absorb(wave  gbcode ) r cluster(gbcode)
global robust3 trend ,absorb(yearin  gbcode ) r cluster(gbcode)
global robust4 trend ,absorb(id yearin   gbcode ) r cluster(gbcode)
global robust5 trend ,absorb(id  gbcode ) r cluster(gbcode)
global robust6 trend ,absorb(fix1 ) r cluster(gbcode)
global robust7 trend ,absorb(fix2) r cluster(gbcode)
global robust8 trend ,absorb(fix3) r cluster(gbcode)
global robust10 trend ,absorb(id wave  gbcode ) r  
global robust11 trend ,absorb(wave  gbcode ) r  
global robust12 trend ,absorb(yearin  gbcode ) r  
global robust13 trend ,absorb(id yearin   gbcode ) r  
global robust14 trend ,absorb(id  gbcode ) r  

******Second adl_basic_panel_ADL
drop if adl_sum== . | iadl_sum== .
drop if  pm25_36m == .
codebook id // 22,132 
	
	
cls
foreach r in 1 2 3 4 5 6 7 8   10 11 12 13 14{
	ivreghdfe iadl_sum age gender  (pm25_36m pm25_1d= thermal_inv12_36m thermal_inv12_1d)  moister_36m sunshine_36m precipitation_36m temperture_36m windspeed_36m ${robust`r'}
	
	outreg2 using "${out}/80_regression_IV_basic_panel_IADL_`r'.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))  keep(pm25_36m pm25_1d age gender)
	
foreach k in 24m 12m 6m 90d 30d 7d{
	ivreghdfe iadl_sum age gender (pm25_`k' pm25_1d =  thermal_inv12_`k' thermal_inv12_1d) moister_`k' sunshine_`k' precipitation_`k' temperture_`k' windspeed_`k'   ${robust`r'}
	outreg2 using "${out}/80_regression_IV_basic_panel_IADL_`r'.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))  keep(pm25_`k' pm25_1d age gender)
	}
}

******Second adl_bin_panel_ADL
foreach r in 1 2 3 4 5 6 7 8   10 11 12 13 14{
	ivreghdfe iadl_sum age gender  ( pm25_2039_36m pm25_4059_36m pm25_6079_36m pm25_80100_36m pm25_100over_36m  =  thermal_inv12_2_36m thermal_inv12_3_36m thermal_inv12_4_36m thermal_inv12_5_36m thermal_inv12_6_36m) moister_36m sunshine_36m precipitation_36m temperture_36m windspeed_36m  ${robust`r'}
	outreg2 using "${out}/80_regression_IV_bin_panel_IADL_`r'.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))   

foreach k in 24m 12m 6m 90d 30d 7d{
	ivreghdfe iadl_sum age gender ( pm25_2039_`k' pm25_4059_`k' pm25_6079_`k' pm25_80100_`k' pm25_100over_`k'  =  thermal_inv12_2_`k' thermal_inv12_3_`k' thermal_inv12_4_`k' thermal_inv12_5_`k' thermal_inv12_6_`k') moister_`k' sunshine_`k' precipitation_`k' temperture_`k' windspeed_`k' ${robust`r'}
	outreg2 using "${out}/80_regression_IV_bin_panel_IADL_`r'.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))   
	}
}	
******Second stageadl_sumbasic_panel_ADL
foreach r in 1 2 3 4 5 6 7 8   10 11 12 13 14{
	foreach adl in  FRAvisit FRAshopping FRAcook FRAwashcloth FRAwalk1km FRAlift FRAstandup FRApublictrans{
		drop if `adl' == .
			ivreghdfe `adl' age gender (pm25_36m pm25_1d= thermal_inv12_36m thermal_inv12_1d)  moister_36m sunshine_36m precipitation_36m temperture_36m windspeed_36m ${robust`r'}
			outreg2 using "${out}/80_regression_IV_basic_panel_IADL_`adl'_`r'.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))  keep(pm25_36m pm25_1d age gender)
			
		foreach k in 24m 12m 6m 90d 30d 7d{
			ivreghdfe `adl' age gender (pm25_`k' pm25_1d =  thermal_inv12_`k' thermal_inv12_1d) moister_`k' sunshine_`k' precipitation_`k' temperture_`k' windspeed_`k'  ${robust`r'}
			outreg2 using "${out}/80_regression_IV_basic_panel_IADL_`adl'_`r'.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1)
 symbol(***,**,*)  addstat(KP F-statistics,e(widstat))  keep(pm25_`k' pm25_1d age gender)
		}

	******Second stageadl_sumbin_panel_ADL
	ivreghdfe `adl' age gender ( pm25_2039_36m pm25_4059_36m pm25_6079_36m pm25_80100_36m pm25_100over_36m  =  thermal_inv12_2_36m thermal_inv12_3_36m thermal_inv12_4_36m thermal_inv12_5_36m thermal_inv12_6_36m) moister_36m sunshine_36m precipitation_36m temperture_36m windspeed_36m ${robust`r'}
		outreg2 using "${out}/80_regression_IV_bin_panel_IADL_`adl'_`r'.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))   

	foreach k in 24m 12m 6m 90d 30d 7d{
		ivreghdfe `adl' age gender ( pm25_2039_`k' pm25_4059_`k' pm25_6079_`k' pm25_80100_`k' pm25_100over_`k'  =  thermal_inv12_2_`k' thermal_inv12_3_`k' thermal_inv12_4_`k' thermal_inv12_5_`k' thermal_inv12_6_`k') moister_`k' sunshine_`k' precipitation_`k' temperture_`k' windspeed_`k'  ${robust`r'}
		outreg2 using "${out}/80_regression_IV_bin_panel_IADL_`adl'_`r'.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))   
		}
	}		
}




use "${outdata}/airpollution health fin_panel.dta",clear
keep if age>=80
	codebook id // 22,126 	
	gen season = 1 if inrange(monthin,1,3)
	replace season = 2 if inrange(monthin,4,6)
	replace season = 3 if inrange(monthin,7,9)
	replace season = 4 if inrange(monthin,10,12)	
	
cap drop trend
gen trend = 1 if yearin ==2005 & monthin == 3
replace trend = monthin -2 if yearin ==2005
replace trend = monthin +10 if yearin ==2006
replace trend = monthin +22 if yearin ==2007
replace trend = monthin +34 if yearin ==2008
replace trend = monthin +46 if yearin ==2009
replace trend = monthin +58 if yearin ==2010
replace trend = monthin +70 if yearin ==2011
replace trend = monthin +82 if yearin ==2012
replace trend = monthin +94 if yearin ==2013
replace trend = monthin +106 if yearin ==2014
replace trend = monthin +118 if yearin ==2015
replace trend = monthin +130 if yearin ==2016
replace trend = monthin +142 if yearin ==2017
replace trend = monthin +154 if yearin ==2018
replace trend = monthin +166 if yearin ==2019

egen fix1 = group(gbcode id)
egen fix2 = group(gbcode wave)
egen fix3 = group(gbcode yearin)
egen fix4 = group(gbcode yearin id)


global robust1 trend ,absorb(id wave  gbcode ) r cluster(gbcode)
global robust2 trend ,absorb(wave  gbcode ) r cluster(gbcode)
global robust3 trend ,absorb(yearin  gbcode ) r cluster(gbcode)
global robust4 trend ,absorb(id yearin   gbcode ) r cluster(gbcode)
global robust5 trend ,absorb(id  gbcode ) r cluster(gbcode)
global robust6 trend ,absorb(fix1 ) r cluster(gbcode)
global robust7 trend ,absorb(fix2) r cluster(gbcode)
global robust8 trend ,absorb(fix3) r cluster(gbcode)
global robust10 trend ,absorb(id wave  gbcode ) r  
global robust11 trend ,absorb(wave  gbcode ) r  
global robust12 trend ,absorb(yearin  gbcode ) r  
global robust13 trend ,absorb(id yearin   gbcode ) r  
global robust14 trend ,absorb(id  gbcode ) r  

******Second adl_basic_panel_ADL
drop if adl_sum== . | adl_sum== .
drop if  pm25_36m == .
codebook id // 22,132 
	
	
cls
foreach r in 1 2 3 4 5 6 7 8   10 11 12 13 14{
	ivreghdfe adl_sum age gender  (pm25_36m pm25_1d= thermal_inv12_36m thermal_inv12_1d)  moister_36m sunshine_36m precipitation_36m temperture_36m windspeed_36m ${robust`r'}
	
	outreg2 using "${out}/80_regression_IV_basic_panel_adl_`r'.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))  keep(pm25_36m pm25_1d age gender)
	
foreach k in 24m 12m 6m 90d 30d 7d{
	ivreghdfe adl_sum age gender (pm25_`k' pm25_1d =  thermal_inv12_`k' thermal_inv12_1d) moister_`k' sunshine_`k' precipitation_`k' temperture_`k' windspeed_`k'   ${robust`r'}
	outreg2 using "${out}/80_regression_IV_basic_panel_adl_`r'.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))  keep(pm25_`k' pm25_1d age gender)
	}
}

******Second adl_bin_panel_ADL
foreach r in 1 2 3 4 5 6 7 8   10 11 12 13 14{
	ivreghdfe adl_sum age gender  ( pm25_2039_36m pm25_4059_36m pm25_6079_36m pm25_80100_36m pm25_100over_36m  =  thermal_inv12_2_36m thermal_inv12_3_36m thermal_inv12_4_36m thermal_inv12_5_36m thermal_inv12_6_36m) moister_36m sunshine_36m precipitation_36m temperture_36m windspeed_36m  ${robust`r'}
	outreg2 using "${out}/80_regression_IV_bin_panel_adl_`r'.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))   

foreach k in 24m 12m 6m 90d 30d 7d{
	ivreghdfe adl_sum age gender ( pm25_2039_`k' pm25_4059_`k' pm25_6079_`k' pm25_80100_`k' pm25_100over_`k'  =  thermal_inv12_2_`k' thermal_inv12_3_`k' thermal_inv12_4_`k' thermal_inv12_5_`k' thermal_inv12_6_`k') moister_`k' sunshine_`k' precipitation_`k' temperture_`k' windspeed_`k' ${robust`r'}
	outreg2 using "${out}/80_regression_IV_bin_panel_adl_`r'.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))   
	}
}	
******Second stageadl_sumbasic_panel_ADL
foreach r in 1 2 3 4 5 6 7 8  10 11 12 13 14{
	foreach adl in  bathing dressing toileting transferring continence feeding{
		drop if `adl' == .
			ivreghdfe `adl' age gender (pm25_36m pm25_1d= thermal_inv12_36m thermal_inv12_1d)  moister_36m sunshine_36m precipitation_36m temperture_36m windspeed_36m ${robust`r'}
			outreg2 using "${out}/80_regression_IV_basic_panel_adl_`adl'_`r'.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))  keep(pm25_36m pm25_1d age gender)
			
		foreach k in 24m 12m 6m 90d 30d 7d{
			ivreghdfe `adl' age gender (pm25_`k' pm25_1d =  thermal_inv12_`k' thermal_inv12_1d) moister_`k' sunshine_`k' precipitation_`k' temperture_`k' windspeed_`k'  ${robust`r'}
			outreg2 using "${out}/80_regression_IV_basic_panel_adl_`adl'_`r'.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1)
 symbol(***,**,*)  addstat(KP F-statistics,e(widstat))  keep(pm25_`k' pm25_1d age gender)
		}

	******Second stageadl_sumbin_panel_ADL
	ivreghdfe `adl' age gender ( pm25_2039_36m pm25_4059_36m pm25_6079_36m pm25_80100_36m pm25_100over_36m  =  thermal_inv12_2_36m thermal_inv12_3_36m thermal_inv12_4_36m thermal_inv12_5_36m thermal_inv12_6_36m) moister_36m sunshine_36m precipitation_36m temperture_36m windspeed_36m ${robust`r'}
		outreg2 using "${out}/80_regression_IV_bin_panel_adl_`adl'_`r'.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))   

	foreach k in 24m 12m 6m 90d 30d 7d{
		ivreghdfe `adl' age gender ( pm25_2039_`k' pm25_4059_`k' pm25_6079_`k' pm25_80100_`k' pm25_100over_`k'  =  thermal_inv12_2_`k' thermal_inv12_3_`k' thermal_inv12_4_`k' thermal_inv12_5_`k' thermal_inv12_6_`k') moister_`k' sunshine_`k' precipitation_`k' temperture_`k' windspeed_`k'  ${robust`r'}
		outreg2 using "${out}/80_regression_IV_bin_panel_adl_`adl'_`r'.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))   
		}
	}		
}
								