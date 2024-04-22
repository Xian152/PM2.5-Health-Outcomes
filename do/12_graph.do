**********county层面环境基本情况报告**********
use "${outdata}/airpollution health fin.dta",clear
	gen agegroup = age >=80 
*** baseline情况	
	* baseline cross 
	duplicates tag id ,gen(dup)
	sort id year
	bysort id : gen order = _n
	keep if age >=80
	duplicates drop id,force	
	drop if adl_sum  == . | iadl_sum  == .
	drop if wave == 18
******Figure 1
		foreach k in inversedate_12 pm25_12 {
			bysort year  : egen mean`k' = mean(`k')
			bysort year  : egen sd`k' = sd(`k')
			gen upper`k' = mean`k' + 1.96*sd`k'
			gen lower`k' = mean`k' - 1.96*sd`k'
		}	
		gen date_AR = mdy(month,1,year)
		format date_AR  %td 
		
		graph twoway (line meanpm25 year)  (line meaninversedate_12 year)
	
******Figure 2
	ren inversedate_12 inversedate
	ren pm25_12 pm25
		foreach k in inversedate pm25{
			foreach time in 5 8 11 14 18 {
				egen mean`k'_`time' = mean(`k') if wave == `time'
			}	
		}	
		label variable meaninversedate_5  "2003-2005"
		label variable meaninversedate_8  "2006-2008"
		label variable meaninversedate_11  "2009-2011"
		label variable meaninversedate_14  "2012-2014"
		label variable meaninversedate_18  "2016-2018"
	
		graph twoway (scatter meaninversedate_5 area7) (scatter meaninversedate_8 area7) (scatter meaninversedate_11 area7) (scatter meaninversedate_14 area7) (scatter meaninversedate_18 area7), xlabel(1"East" 2"North" 3"South" 4"Middle" 5 "Southwest" 6 "Northwest" 7 "Northeast")  xtitle(Area) ytitle("Probability of thermal inversion ")
		graph export  "${out}/inversedate by region.png",replace 
	
	
		label variable meanpm25_5  "2003-2005"
		label variable meanpm25_8  "2006-2008"
		label variable meanpm25_11  "2009-2011"
		label variable meanpm25_14  "2012-2014"
		label variable meanpm25_18  "2016-2018"	
		
		graph twoway (scatter meanpm25_5 area7) (scatter meanpm25_8 area7) (scatter meanpm25_11 area7) (scatter meanpm25_14 area7) (scatter meanpm25_18 area7), xlabel(1"East" 2"North" 3"South" 4"Middle" 5 "Southwest" 6 "Northwest" 7 "Northeast")  xtitle(Area) ytitle("PM 2.5 (µg/m³)") 
		graph export   "${out}/pm2.5 by region.png",replace 
