**********个人层面基本情况和回归分析--面板面数据基线年情况**********
use "${outdata}/airpollution health fin_panel.dta",clear
	keep if gbcode !=.
	keep if age >=80
	codebook id // 22,126 	
	gen season = 1 if inrange(monthin,1,3)
	replace season = 2 if inrange(monthin,4,6)
	replace season = 3 if inrange(monthin,7,9)
	replace season = 4 if inrange(monthin,10,12)	
	
******First stage
cls
	ivreghdfe adl_sum   (pm25_36m pm25_1d = thermal_inv12_36m  thermal_inv12_1d)  moister_36m sunshine_36m precipitation_36m temperture_36m windspeed_36m  , absorb(wave id) cluster(gbcode) first
	outreg2 using "${out}/regression_firststage1.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)    addstat(KP F-statistics,e(widstat)) 
	
foreach k in 24m 12m 6m 90d 30d 7d 1d{
	ivreghdfe   adl_sum   (pm25_`k' pm25_1d = thermal_inv12_`k'  thermal_inv12_1d)  moister_`k' sunshine_`k' precipitation_`k' temperture_`k' windspeed_`k'   , absorb(wave id) cluster(gbcode)  first
	outreg2 using "${out}/regression_firststage1.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)    addstat(KP F-statistics,e(widstat)) 
}	

******Second stageadl_sumbasic_panel_ADL_80
drop if adl_sum== . | iadl_sum== .
cls
	ivreghdfe adl_sum age gender (pm25_36m pm25_1d= thermal_inv12_36m thermal_inv12_1d)  moister_36m sunshine_36m precipitation_36m temperture_36m windspeed_36m    , absorb(wave id)  cluster(gbcode) r 	
	outreg2 using "${out}/regression_IV_basic_panel_ADL_80.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))  keep(pm25_36m pm25_1d)
	
foreach k in 24m 12m 6m 90d 30d 7d{
	ivreghdfe adl_sum  age gender smkl dril pa (pm25_`k' pm25_1d =  thermal_inv12_`k' thermal_inv12_1d) moister_`k' sunshine_`k' precipitation_`k' temperture_`k' windspeed_`k'    , absorb(wave id gbcode)  cluster(gbcode) r 
	//outreg2 using "${out}/regression_IV_basic_panel_ADL_80.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))  keep(pm25_`k' pm25_1d age gender)
}	
******Second stageadl_sumbasic_panel_ADL_80
egen gbcodewave = group(wave gbcode)

drop if adl_sum== . | iadl_sum== .
cls
	ivreghdfe adl_sum age gender (pm25_36m pm25_1d= thermal_inv12_36m thermal_inv12_1d)  moister_36m sunshine_36m precipitation_36m temperture_36m windspeed_36m  [aw=w]   , absorb(gbcodewave) r 	
	outreg2 using "${out}/regression_IV_basic_panel_ADL_80_gbcodewave.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))  keep(pm25_36m pm25_1d age gender)
	
foreach k in 24m 12m 6m 90d 30d 7d{
	ivreghdfe adl_sum  age gender (pm25_`k' pm25_1d =  thermal_inv12_`k' thermal_inv12_1d) moister_`k' sunshine_`k' precipitation_`k' temperture_`k' windspeed_`k'   [aw=w]  , absorb(gbcodewave) r 
	outreg2 using "${out}/regression_IV_basic_panel_ADL_80_gbcodewave.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))  keep(pm25_`k' pm25_1d age gender)
}	

******Second stageadl_sumbasic_panel_ADL_80
cls
	ivreghdfe adl_sum age gender (pm25_36m pm25_1d= thermal_inv12_36m thermal_inv12_1d)  moister_36m sunshine_36m precipitation_36m temperture_36m windspeed_36m  [aw=w]   , absorb(wave gbcode ) r 	
	outreg2 using "${out}/regression_IV_basic_panel_ADL_80_wave gbcode.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))  keep(pm25_36m pm25_1d age gender)
	
foreach k in 24m 12m 6m 90d 30d 7d{
	ivreghdfe adl_sum  age gender (pm25_`k' pm25_1d =  thermal_inv12_`k' thermal_inv12_1d) moister_`k' sunshine_`k' precipitation_`k' temperture_`k' windspeed_`k'   [aw=w]  , absorb(wave gbcode) r 
	outreg2 using "${out}/regression_IV_basic_panel_ADL_80_wave gbcode.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))  keep(pm25_`k' pm25_1d age gender)
}	

******Second stageadl_sumbasic_panel_ADL_80
cls
	ivreghdfe adl_sum age gender (pm25_36m pm25_1d= thermal_inv12_36m thermal_inv12_1d)  moister_36m sunshine_36m precipitation_36m temperture_36m windspeed_36m     , absorb(id  wave) r 	
	outreg2 using "${out}/regression_IV_basic_panel_ADL_80_id wave.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))  keep(pm25_36m pm25_1d age gender)
	
foreach k in 24m 12m 6m 90d 30d 7d{
	ivreghdfe adl_sum  age gender (pm25_`k' pm25_1d =  thermal_inv12_`k' thermal_inv12_1d) moister_`k' sunshine_`k' precipitation_`k' temperture_`k' windspeed_`k'    , absorb(id  wave) r
	outreg2 using "${out}/regression_IV_basic_panel_ADL_80_id wave.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))  keep(pm25_`k' pm25_1d age gender)
}	

******Second stageadl_sumbin_panel_ADL_80
cls
	ivreghdfe adl_sum age gender smkl dril pa ( pm25_2039_36m pm25_4059_36m pm25_6079_36m pm25_80100_36m pm25_100over_36m  =  thermal_inv12_2_36m thermal_inv12_3_36m thermal_inv12_4_36m thermal_inv12_5_36m thermal_inv12_6_36m) moister_36m sunshine_36m precipitation_36m temperture_36m windspeed_36m   ,  absorb(wave id)  cluster(gbcode) r 	
	outreg2 using "${out}/regression_IV_bin_panel_ADL_80.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))   

foreach k in 24m 12m 6m 90d 30d 7d{
	ivreghdfe adl_sum age gender ( pm25_2039_`k' pm25_4059_`k' pm25_6079_`k' pm25_80100_`k' pm25_100over_`k'  =  thermal_inv12_2_`k' thermal_inv12_3_`k' thermal_inv12_4_`k' thermal_inv12_5_`k' thermal_inv12_6_`k') moister_`k' sunshine_`k' precipitation_`k' temperture_`k' windspeed_`k'  smkl dril pa  , absorb(wave id )  cluster(gbcode) r 	
	outreg2 using "${out}/regression_IV_bin_panel_ADL_80.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))   
	}
	
	
**********个人层面基本情况和回归分析--面板面数据基线年情况**********
use "${outdata}/airpollution health fin_panel.dta",clear
	cap drop a 
	drop if gbcode == .
	keep if age >=80	


	
	codebook id // 22,126 	
	gen season = 1 if inrange(monthin,1,3)
	replace season = 2 if inrange(monthin,4,6)
	replace season = 3 if inrange(monthin,7,9)
	replace season = 4 if inrange(monthin,10,12)	
******Second stageadl_sumbasic_panel_ADL_80
cls
foreach adl in bathing dressing toileting transferring continence feeding{
		drop if `adl' == .
		cap drop a 
		duplicates tag id,gen(a)
		drop if a == 0 
		ivreghdfe `adl' age gender  smkl dril pa  (pm25_36m pm25_1d= thermal_inv12_36m thermal_inv12_1d)  moister_36m sunshine_36m precipitation_36m temperture_36m windspeed_36m   ,  absorb(wave id )  cluster(gbcode) r 
		outreg2 using "${out}/regression_IV_basic_panel_ADL_80_`adl'.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))  keep(pm25_36m pm25_1d age gender smkl dril pa )
		
	foreach k in 24m 12m 6m 90d 30d 7d{
		ivreghdfe `adl' age gender  smkl dril pa  (pm25_`k' pm25_1d =  thermal_inv12_`k' thermal_inv12_1d) moister_`k' sunshine_`k' precipitation_`k' temperture_`k' windspeed_`k'    , absorb(wave id)  cluster(gbcode) r 
		outreg2 using "${out}/regression_IV_basic_panel_ADL_80_`adl'.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))  keep(pm25_`k' pm25_1d age gender smkl dril pa )
		}
		
	******Second stageadl_sumbin_panel_ADL_80
	ivreghdfe `adl' age gender  smkl dril pa  ( pm25_2039_36m pm25_4059_36m pm25_6079_36m pm25_80100_36m pm25_100over_36m  pm25_1d =  thermal_inv12_2_36m thermal_inv12_3_36m thermal_inv12_4_36m thermal_inv12_5_36m thermal_inv12_6_36m pm25_1d) moister_36m sunshine_36m precipitation_36m temperture_36m windspeed_36m    ,  absorb(wave id)  cluster(gbcode) r 
		outreg2 using "${out}/regression_IV_bin_panel_ADL_80_`adl'.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))   

	foreach k in 24m 12m 6m 90d 30d 7d{
		ivreghdfe `adl' age gender  smkl dril pa  ( pm25_2039_`k' pm25_4059_`k' pm25_6079_`k' pm25_80100_`k' pm25_100over_`k'  =  thermal_inv12_2_`k' thermal_inv12_3_`k' thermal_inv12_4_`k' thermal_inv12_5_`k' thermal_inv12_6_`k') moister_`k' sunshine_`k' precipitation_`k' temperture_`k' windspeed_`k'     ,  absorb(wave id)  cluster(gbcode) r 
		outreg2 using "${out}/regression_IV_bin_panel_ADL_80_`adl'.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))   
	}
}		

		