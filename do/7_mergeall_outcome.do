**************baseline merge with co
use "${int}/Full_CLHLS_covariants_comm.dta",clear
	gen int gap_year = (intdate-interview_baseline)/365
	
	gen age = agebase
	bysort id : replace age =agebase + gap_year
	
	keep if age >= 65
	* not logical
	duplicates tag id,gen(a)
	drop if a == 0 & wave == 18	
	* frailty 
    egen frailsumver1 = rowtotal(FRAhypertension FRAhtdisea FRAstrokecvd FRAcopd FRAtb FRAulcer FRAdiabetes FRAcancer FRAprostatetumor FRAparkinson FRAbedsore FRAcataract FRAglaucoma FRAseriousillness FRAsrh FRAirh FRAbathing FRAdressing FRAtoileting FRAtransferring FRAcontinence FRAfeeding FRAneck FRAlowerback FRAstand FRAbook FRAhear FRAvisual FRAturn FRApsy1 FRApsy2 FRApsy5 FRApsy3  FRApsy6 FRAhousework FRAchopsticks FRAhr),mi
	drop if frailsumver1 == .
	
	egen frailmissingver1 = rowmiss(FRAhypertension FRAhtdisea FRAstrokecvd FRAcopd FRAtb FRAulcer FRAdiabetes FRAcancer FRAprostatetumor FRAparkinson FRAbedsore FRAcataract FRAglaucoma FRAseriousillness FRAsrh FRAirh FRAbathing FRAdressing FRAtoileting FRAtransferring FRAcontinence FRAfeeding FRAneck FRAlowerback FRAstand FRAbook FRAhear FRAvisual FRAturn FRApsy1 FRApsy2 FRApsy5 FRApsy3  FRApsy6 FRAhousework FRAchopsticks FRAhr)
	
	//drop if frailmissingver1 >=10            									// a lot miss in psychological survey	
	gen frailID = frailsumver1/(37-frailmissingver1) 
	replace frailID = . if frailmissingver1 >= 10
	
	* adl & iadl
	recode FRAvisit FRAshopping FRAcook FRAwashcloth FRAwalk1km FRAlift FRAstandup FRApublictrans (0.5 = 1)
	recode FRAturn ( 0.25 0.5 = 0)
	egen adl_miss= rowmiss(bathing dressing toileting transferring continence feeding)
	egen adl_sum = rowtotal(bathing dressing toileting transferring continence feeding) 
	replace adl_sum = . if adl_miss > 1
	
	egen iadl_miss= rowmiss(FRAvisit FRAshopping FRAcook FRAwashcloth FRAwalk1km FRAlift FRAstandup FRApublictrans)
	egen iadl_sum = rowtotal(FRAvisit FRAshopping FRAcook FRAwashcloth FRAwalk1km FRAlift FRAstandup FRApublictrans) 
	replace iadl_sum = . if iadl_miss > 1
	
	* physical functionong
	egen phys = anymatch(FRAturn FRAstandup FRAbook ),value(1)	
	egen phys_miss = rowmiss(FRAturn FRAstandup FRAbook )
	replace phys = . if phys_miss >=1
		
	* sdid treated 
	decode prov,gen(province)
	gen treat_id = !inlist(province,"jiangxi","fujian","guangxi","hainan","helongjiang") 
	gen treat_year = inlist(wave,2018)
	
	* AP
	ren intdate interviewdate 
	merge m:1 gbcode interviewdate using "${outdata}/daily_air_pollution.dta"
	drop if _m == 2
	ren _m covmerge
	
/*	
	gen area7 = .
	foreach k in  shandong jiangxi fujian zhejiang anhui jiangsu shanghai {
		replace area7 = 1 if strmatch(province,"`k'")
	}
	foreach k in  neimenggu shanxi hebei tianjin beijing {
		replace area7 = 2 if strmatch(province,"`k'")
	}
	foreach k in  hainan guangxi guangdong {
		replace area7 = 3 if strmatch(province,"`k'")
	}
	foreach k in  hubei hunan henan  {
		replace area7 = 4 if strmatch(province,"`k'")
	}
	foreach k in  xizang chongqing yunnan guizhou sichuan  {
		replace area7 = 5 if strmatch(province,"`k'")
	}
	foreach k in  xinjiang ningxia qinghai gansu shaanxi {
		replace area7 = 6 if strmatch(province,"`k'")
	}
	foreach k in  helongjiang jilin liaoning {
		replace area7 = 7 if strmatch(province,"`k'")
	}							
	label define area7 1"East" 2"North" 3"South" 4"Middle" 5 "Southwest" 6 "Northwest" 7 "Northeast"
	label values area7 area7	
*/	 
save "${outdata}/airpollution health fin.dta",replace

use  "${outdata}/airpollution health fin.dta",clear
	merge m:1 gbcode yearin monthin using "${outdata}/pm25.dta"
	drop if _m == 2
	drop _m
save ,replace
	
	drop if deathstatus == 1 
	replace adlSum = . if adlMiss > 1
	replace iadlSum = . if iadlMiss > 1
	xtset id wave 
	
save "${outdata}/airpollution health fin_panel.dta",replace	


**********个人层面基本情况和回归分析--横截面数据基线年情况**********
use "${outdata}/airpollution health fin.dta",clear
	drop if deathstatus == 1 
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
