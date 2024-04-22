
**********14-18 sdid回归个人层面基本情况和回归分析--横截面数据基线年情况**********
use "${outdata}/airpollution health fin.dta",clear
	keep if age >=80
	drop if adl_sum  == . | iadl_sum  == .	
	drop if pm25_12 == .
*** 14-18panel情况	
	keep if inlist(wave,11,14,18) // 
**# Bookmark #1
	cap drop dup
	duplicates tag id,gen(dup)	
	keep if dup == 2 // 有14 18年两年的观测
	replace treat_year  = 1 if wave == 18 ｜ wave== 2014
	gen treated = treat_year * treat_id
	xtset id wave 
	sum edug age gender adl_sum   iadl_sum pm25_12 pm1_12 inversedate_12 
	
save "${outdata}/airpollution health fin_panel14-18.dta",replace	

******Table 9 fixed-effect model
cls
	xtreg adl_sum  pm25_12 age gender i.wave i.gbcode ,fe 
	outreg2 using "${out}/regression_panel_14.xls",replace excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(F-statistics,e(F)) keep(pm25_12 age gender)
	xtivreg adl_sum  age gender (pm25_12 = inversedate_12) i.wave i.gbcode   ,fe  
	outreg2 using "${out}/regression_panel.xls",append excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  keep(pm25_12 age gender)
	
	xtreg iadl_sum  pm25_12   age gender i.wave i.gbcode ,fe 
	outreg2 using "${out}/regression_panel_14.xls",append excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) addstat(F-statistics,e(F)) keep(pm25_12 age gender)
	xtivreg iadl_sum  age gender (pm25_12 = inversedate_12) i.wave i.gbcode   ,fe 
	outreg2 using "${out}/regression_panel_14.xls",append excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)   keep(pm25_12 age gender)

	
	
use "${outdata}/airpollution health fin_panel14-18.dta",clear
preserve
	sort treat_id year
	egen av_dk = mean(pm25_12), by (treat_id wave)
	*gen av_dk1 = av_dk if treated_g == 1
	*gen av_dk2 = av_dk if treated_g == 0
	duplicates drop treat_id wave, force
	keep av_dk treat_id wave
	reshape wide av_dk, i(wave) j(treat_id)
	ren (av_dk1 av_dk0) (Treated Controled )
	label variable Treated "NIDAs"
	label variable Controled  "Non-NIDAs"
	
	twoway connected Treated  Controled wave, ytitle("PM 2.5" ) xtitle(Year) xline(2014) legend(ring(0) pos(2))   ylabel(,nogrid)
	graph save "pm2.5.gph",   replace	
restore

preserve
	sort treat_id year
	egen av_dk = mean(adl_sum), by (treat_id wave)
	*gen av_dk1 = av_dk if treated_g == 1
	*gen av_dk2 = av_dk if treated_g == 0
	duplicates drop treat_id wave, force
	keep av_dk treat_id wave
	reshape wide av_dk, i(wave) j(treat_id)
	ren (av_dk1 av_dk0) (Treated Controled )
	label variable Treated "NIDAs"
	label variable Controled  "Non-NIDAs"
	
	twoway connected Treated  Controled wave, ytitle("ADL" ) xtitle(Year) xline(2014) legend(ring(0) pos(2))   ylabel(,nogrid)
	graph save "adl.gph",   replace	
restore
	
	
preserve
	sort treat_id year
	egen av_dk = mean(iadl_sum), by (treat_id wave)
	*gen av_dk1 = av_dk if treated_g == 1
	*gen av_dk2 = av_dk if treated_g == 0
	duplicates drop treat_id wave, force
	keep av_dk treat_id wave
	reshape wide av_dk, i(wave) j(treat_id)
	ren (av_dk1 av_dk0) (Treated Controled )
	label variable Treated "NIDAs"
	label variable Controled  "Non-NIDAs"
	
	twoway connected Treated  Controled wave, ytitle("IADL" ) xtitle(Year) xline(2014) legend(ring(0) pos(2))   ylabel(,nogrid)
	graph save "iadl.gph",   replace	
restore
	
	graph combine "pm2.5.gph" "adl.gph" "iadl.gph" ,rows(2)   graphregion(margin(zero))
	graph export "${out}/DID.png",replace 



use "${outdata}/airpollution health fin_panel14-18.dta",clear
ren (treated treat_id) (post treat)
	
	ren  wave  yr
	xtset id yr
	tab yr,gen(eventt) // 年度虚拟变量	
	
	drop eventt2
	cls	
	*政策随时间变化
	preserve
	xtreg adl_sum   eventt1 eventt3  i.yr i.id, r fe	
	//outreg2 using "${OUT}/Table_dynamic.xls",replace excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)   	

	coefplot, ///
	   keep(eventt*)  ///
	   coeflabels(eventt1 = "2011 years"  ///
	   eventt3 = "2018 years")         	 ///
	   vertical                       ///
	   yline(0)                       ///
	   xline(1.5, lp(dash) )  			///	   
	   ytitle("Difference in ADL")                ///
	   xtitle("Years Relative to Intervention")                ///
	   addplot(line @b @at)                 ///
	   ciopts(recast(rcap))                 ///
	   scheme(cleanplots)
	graph save "${out}/ADL_pta.gph", replace
	restore 	
	
	*政策随时间变化
	preserve
	xtreg iadl_sum   eventt1 eventt3  i.yr i.id, r fe	
	//outreg2 using "${OUT}/Table_dynamic.xls",replace excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)   	

	coefplot, ///
	   keep(eventt*)  ///
	   coeflabels(eventt1 = "2011 years"  ///
	   eventt3 = "2018 years")         	 ///
	   vertical                       ///
	   yline(0)                       ///
	   xline(1.5, lp(dash) )  			///	   
	   ytitle("Difference in IADL")                ///
	   xtitle("Years Relative to Intervention")                ///
	   addplot(line @b @at)                 ///
	   ciopts(recast(rcap))                 ///
	   scheme(cleanplots)
	graph save "${out}/IADL_pta.gph", replace
	restore 		
	
	
	*政策随时间变化
	preserve
	xtreg pm25_12   eventt1 eventt3  i.yr i.id, r fe	
	//outreg2 using "${OUT}/Table_dynamic.xls",replace excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)   	

	coefplot, ///
	   keep(eventt*)  ///
	   coeflabels(eventt1 = "2011 years"  ///
	   eventt3 = "2018 years")         	 ///
	   vertical                       ///
	   yline(0)                       ///
	   xline(1.5, lp(dash) )  			///	   
	   ytitle("Difference in PM 2.5")                ///
	   xtitle("Years Relative to Intervention")                ///
	   addplot(line @b @at)                 ///
	   ciopts(recast(rcap))                 ///
	   scheme(cleanplots)
	graph save "${out}/pm25_pta.gph", replace
	restore 		
	
	graph combine "${out}/pm25_pta.gph" "${out}/ADL_pta.gph" "${out}/IADL_pta.gph" ,rows(2)   graphregion(margin(zero))
	graph export "${out}/PTA.png",replace 
	
	
******Table 11 DID
use "${outdata}/airpollution health fin_panel14-18.dta",clear
	preserve
		keep id w_weight year 
		keep if year == 2011
		ren w_weight w_fin
		drop year
		tempfile t1
		save `t1',replace
	restore
	merge m:1 id using `t1'
	xtset id wave
	xtreg adl_sum  treated i.id i.wave [aw = w_fin],fe r 
	xtreg iadl_sum  treated i.id i.wave [aw = w_fin],fe r  

cls
	sdid  pm25_12 id  wave treated, vce(bootstrap) seed(1213) covariates(age gender , projected) method(did) 
	outreg2 using "${out}/regression_did.xls",replace excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) 

	sdid  adl_sum id  wave treated, vce(bootstrap) seed(1213) covariates(age gender  , projected) method(did) 
	outreg2 using "${out}/regression_did.xls",append excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  
	
	sdid  iadl_sum id  wave treated, vce(bootstrap) seed(1213) covariates(age gender  , projected) method(did) 
	outreg2 using "${out}/regression_did.xls",append excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  
	
	
******Table 12 sdid
cls
	sdid  pm25_12 id  wave treated, vce(bootstrap) seed(1213) covariates(age gender  moister_12 sunshine_12 windspeed_12 precipitation_12 temperture_12, projected) method(sdid)   	
	outreg2 using "${out}/regression_sdid.xls",replace excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  

	sdid  adl_sum id  wave treated, vce(bootstrap) seed(1213) covariates(age gender  moister_12 sunshine_12 windspeed_12 precipitation_12 temperture_12, projected) method(sdid)  
	outreg2 using "${out}/regression_sdid.xls",append excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  
	
	sdid  iadl_sum id  wave treated, vce(bootstrap) seed(1213) covariates(age gender moister_12 sunshine_12 windspeed_12 precipitation_12 temperture_12 , projected)  method(sdid)  
	outreg2 using "${out}/regression_sdid.xls",append excel stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  
	

use "${outdata}/airpollution health fin_panel14-18.dta",clear
	keep if year == 2011
	table1 ,by(treat_id) vars(age contn\ gender cat\ pm25_12 contn\ adl_sum contn\ iadl_sum contn\ ) format(%2.1f) one mis saving("${out}/DSP_did.xls",replace) 	
