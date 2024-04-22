****************************
***     环境数据清洗       ***
****************************
*********************************** PM 2.5 导入
import excel "${raw}/exposure/1980年1月~2022年3月各区县地表PM2.5质量浓度(微克每立方米)_第一部分.xlsx", first  sheet("Sheet1") clear
	keep month 县代码 地表PM25质量浓度
 	ren month date
	keep if inrange(year(date),1995,2023)
	gen year = year(date) 
	gen month  = month(date) 
	keep year month 县代码 地表PM25质量浓度
	ren 县代码 gbcode
save "${int}/pm2.5_1.dta",replace	

import excel "${raw}/exposure/1980年1月~2022年3月各区县地表PM2.5质量浓度(微克每立方米)_第二部分.xlsx",  first  sheet("Sheet1") clear
	keep month 县代码 地表PM25质量浓度
 	ren month date
	keep if inrange(year(date),1995,2023)
	gen year = year(date) 
	gen month  = month(date) 
	keep year month 县代码 地表PM25质量浓度
	ren 县代码 gbcode
save "${int}/pm2.5_2.dta",replace	

use "${int}/pm2.5_1.dta",clear
	append using "${int}/pm2.5_2.dta"

	gen pm25_30d = 0
	gen pm25_90d = 0	
	gen pm25_6m = 0
	gen pm25_12m = 0
	gen pm25_24m = 0
	gen pm25_36m = 0
	ren 地表PM25质量浓度 PM25
	forvalues i =0/35{
		bysort gbcode (year month) :replace pm25_36m = pm25_36m+PM25[_n-`i']	
	}
	forvalues i =0/23{
		bysort gbcode (year month) :replace pm25_24m = pm25_24m+PM25[_n-`i']	
	}
	forvalues i =0/5{
		bysort gbcode (year month) :replace pm25_6m = pm25_6m+PM25[_n-`i']	
	}	
	forvalues i =0/2{
		bysort gbcode (year month) :replace pm25_90d = pm25_90d+PM25[_n-`i']	
	}		
	forvalues i =0/11{
		bysort gbcode (year month) :replace pm25_12m = pm25_12m+PM25[_n-`i']	
	}		
	replace pm25_24m = pm25_24m/24
	replace pm25_36m = pm25_36m/36
	replace pm25_6m = pm25_6m/6
	replace pm25_90d = pm25_90d/3
	replace pm25_30d = PM25
	replace pm25_12m = pm25_12m/12
	keep gbcode pm25* year month
	duplicates drop
	drop if pm25_36m == .
	ren year yearin 
	ren month monthin
	ren (pm25_12m pm25_24m pm25_30d pm25_36m pm25_6m pm25_90d) (pm25_12m_alt pm25_24m_alt pm25_30d_alt pm25_36m_alt pm25_6m_alt pm25_90d_alt) 
save "${outdata}/pm25.dta",replace	


global raw "/Volumes/expand/Data/环境相关数据/区县日度地表PM2.5质量浓度1980年1月1日～2022年6月30日/区县数据"


use "${raw}/timegbcode list_pm2.5_02二.dta",clear
	append using "${raw}/timegbcode list_pm2.5_02一.dta"
	foreach k in 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 {
		append using "${raw}/timegbcode list_pm2.5_`k'二.dta" "${raw}/timegbcode list_pm2.5_`k'一.dta"
	}
	ren 日期 interviewdate 
	ren 县代码 gbcode
	ren 地表PM25质量浓度 日平均
	
	gen pm25_20less= 日平均 <20  
	gen pm25_2039= 日平均 >=20 & 日平均  < 40
	gen pm25_4059= 日平均 >=40 & 日平均  < 60
	gen pm25_6079= 日平均 >=60 & 日平均  < 80
	gen pm25_80100= 日平均 >=80 & 日平均  < 100
	gen pm25_100over= 日平均> 100 if 日平均!=. 
	
	foreach k in  20less  2039 4059 6079 80100 100over{
		gen pm25_`k'_7d = 0
		gen pm25_`k'_1d = 0
		
		
		forvalues i =0/6{
			bysort gbcode (interviewdate) :replace pm25_`k'_7d = pm25_`k'_7d+pm25_`k'[_n-`i']	
		}		
		gen pm25_`k'_30d = pm25_`k'_7d
		forvalues i =7/29{
			bysort gbcode (interviewdate) :replace pm25_`k'_30d = pm25_`k'_30d+pm25_`k'[_n-`i']	
		}		
		gen pm25_`k'_90d = pm25_`k'_30d
		forvalues i =30/89{
			bysort gbcode (interviewdate) :replace pm25_`k'_90d = pm25_`k'_90d+pm25_`k'[_n-`i']	
		}		
		gen pm25_`k'_6m = pm25_`k'_90d
		forvalues i =90/179{
			bysort gbcode (interviewdate) :replace pm25_`k'_6m = pm25_`k'_6m+pm25_`k'[_n-`i']	
		}	
		gen pm25_`k'_12m = pm25_`k'_6m
		forvalues i =180/364{
			bysort gbcode (interviewdate) :replace pm25_`k'_12m = pm25_`k'_12m+pm25_`k'[_n-`i']	
		}
		gen pm25_`k'_24m = pm25_`k'_12m
		forvalues i =365/729{
			bysort gbcode (interviewdate) :replace pm25_`k'_24m = pm25_`k'_24m+pm25_`k'[_n-`i']	
		}		
		gen pm25_`k'_36m = pm25_`k'_24m 
		forvalues i =730/1094{
			bysort gbcode (interviewdate) :replace pm25_`k'_36m = pm25_`k'_36m+pm25_`k'[_n-`i']	
		}	
	}	
	
	keep gbcode interviewdate pm25* 日平均
	duplicates drop
	drop if pm25_4059_36m == .	
	
	merge 1:1 gbcode interviewdate using "${raw}/PM2.5_daily.dta"
save "${raw}/PM2.5_daily.dta",replace	


global raw "/Users/x152/Library/CloudStorage/Box-Box/HALSA-Healthy Aging - CLHLS/P23 Environmental Health-Causal/Analyses/raw/exposure/inverse tempture/"
************************* inverse temp 导入

foreach k in 02 03 04 05 06 07 08 09 10 11 12 13 14 {
	import excel "${raw}/20`k'年各区县逆温数据_第二部分.xlsx", first sheet("Sheet1") clear 
	save "${raw}/timegbcode list_`k'二.dta",replace	
	import excel "${raw}/20`k'年各区县逆温数据_第一部分.xlsx", first sheet("Sheet1") clear 
	save "${raw}/timegbcode list_`k'一.dta",replace	
}

foreach k in  15 16 17 18 19 {
	import excel "${raw}/20`k'年各区县逆温数据_第二部分.xlsx", first  sheet("Sheet1") clear
	save "${raw}/timegbcode list_`k'二.dta",replace	
	import excel "${raw}/20`k'年各区县逆温数据_第一部分.xlsx", first  sheet("Sheet1") clear
	save "${raw}/timegbcode list_`k'一.dta",replace	
}

foreach k in  15 16 17 18 19 {
	use "${raw}/timegbcode list_`k'二.dta",clear
		destring 县代码,replace
	save,replace	
	use "${raw}/timegbcode list_`k'一.dta",clear
		destring 县代码,replace
	save,replace	
}


use "${raw}/timegbcode list_02二.dta",clear
	append using "${raw}/timegbcode list_02一.dta"
	foreach k in 02 03 04 05 06 07 08 09 10 11 12 13 14  {
		append using "${raw}/timegbcode list_`k'二.dta" "${raw}/timegbcode list_`k'一.dta"
	}
	drop date
	gen double date = mdy(month,day,year)
	format date %tdCY-M-D 
	destring 县代码,replace
	foreach k in 15 16 17 18 19 {
		append using "${raw}/timegbcode list_`k'二.dta" "${raw}/timegbcode list_`k'一.dta"
	}	

	ren date interviewdate
	ren 县代码 gbcode
	gen inversedate_36m = 0
	gen inversedate_24m = 0
	gen inversedate_12m = 0
	gen inversedate_6m = 0
	gen inversedate_90d = 0
	gen inversedate_30d = 0
	gen inversedate_7d = 0
	gen inversedate_1d = 0
	forvalues i =0/6{
		bysort gbcode (interviewdate) :replace inversedate_7d = inversedate_7d+thermal_inv_yesno12[_n-`i']	
	}
	replace inversedate_30d = inversedate_7d
	forvalues i =7/29{
		bysort gbcode (interviewdate) :replace inversedate_30d = inversedate_30d+thermal_inv_yesno12[_n-`i']	
	}	
	replace inversedate_90d = inversedate_30d
	forvalues i =30/89{
		bysort gbcode (interviewdate) :replace inversedate_90d = inversedate_90d+thermal_inv_yesno12[_n-`i']	
	}	
	replace inversedate_6m = inversedate_90d	
	forvalues i =90/179{
		bysort gbcode (interviewdate) :replace inversedate_6m = inversedate_6m+thermal_inv_yesno12[_n-`i']	
	}	
	replace inversedate_12m = inversedate_6m
	forvalues i =180/364{
		bysort gbcode (interviewdate) :replace inversedate_12m = inversedate_12m+thermal_inv_yesno12[_n-`i']	
	}	
	replace inversedate_24m = inversedate_12m	
	forvalues i =365/729{
		bysort gbcode (interviewdate) :replace inversedate_24m = inversedate_24m+thermal_inv_yesno12[_n-`i']	
	}	
	replace inversedate_36m = inversedate_24m		
	forvalues i =730/1094{
		bysort gbcode (interviewdate) :replace inversedate_36m = inversedate_36m+thermal_inv_yesno12[_n-`i']	
	}	

	drop if inversedate_36m == .
	
	replace inversedate_36m = inversedate_36m/1095	 * 100
	replace inversedate_24m = inversedate_24m/730 * 100
	replace inversedate_12m = inversedate_12m/365 * 100
	replace inversedate_6m = inversedate_6m/180 * 100
	replace inversedate_90d = inversedate_90d/90 * 100
	replace inversedate_30d = inversedate_30d/30 * 100
	replace inversedate_7d = inversedate_7d/7 * 100
	replace inversedate_1d = thermal_inv_yesno12 * 100
	
	keep gbcode interviewdate inversedate*
	duplicates drop
save "${raw}/inverse temperture.dta",replace	

use "${raw}/timegbcode list_02二.dta",clear
	append using "${raw}/timegbcode list_02一.dta"
	foreach k in 02 03 04 05 06 07 08 09 10 11 12 13 14  {
		append using "${raw}/timegbcode list_`k'二.dta" "${raw}/timegbcode list_`k'一.dta"
	}
	drop date
	gen double date = mdy(month,day,year)
	format date %tdCY-M-D 
	destring 县代码,replace
	foreach k in 15 16 17 18 19 {
		append using "${raw}/timegbcode list_`k'二.dta" "${raw}/timegbcode list_`k'一.dta"
	}	
	ren 县代码 gbcode
	ren date interviewdate	
	egen thermal_inv12= rowtotal(T1_thermal_inv12 T2_thermal_inv12 T3_thermal_inv12 T4_thermal_inv12),mi
	replace thermal_inv12 = thermal_inv12/4
	
	gen thermal_inv12_36m = 0
	gen thermal_inv12_24m = 0
	gen thermal_inv12_12m = 0
	gen thermal_inv12_6m = 0
	gen thermal_inv12_90d = 0
	gen thermal_inv12_30d = 0
	gen thermal_inv12_7d = 0
	gen thermal_inv12_1d = 0
	forvalues i =0/6{
		bysort gbcode (interviewdate) :replace thermal_inv12_7d = thermal_inv12_7d+thermal_inv12[_n-`i']	
	}
	replace thermal_inv12_30d = thermal_inv12_7d
	forvalues i =7/29{
		bysort gbcode (interviewdate) :replace thermal_inv12_30d = thermal_inv12_30d+thermal_inv12[_n-`i']	
	}	
	replace thermal_inv12_90d = thermal_inv12_30d
	forvalues i =30/89{
		bysort gbcode (interviewdate) :replace thermal_inv12_90d = thermal_inv12_90d+thermal_inv12[_n-`i']	
	}	
	replace thermal_inv12_6m = thermal_inv12_90d	
	forvalues i =90/179{
		bysort gbcode (interviewdate) :replace thermal_inv12_6m = thermal_inv12_6m+thermal_inv12[_n-`i']	
	}	
	replace thermal_inv12_12m = thermal_inv12_6m
	forvalues i =180/364{
		bysort gbcode (interviewdate) :replace thermal_inv12_12m = thermal_inv12_12m+thermal_inv12[_n-`i']	
	}	
	replace thermal_inv12_24m = thermal_inv12_12m	
	forvalues i =365/729{
		bysort gbcode (interviewdate) :replace thermal_inv12_24m = thermal_inv12_24m+thermal_inv12[_n-`i']	
	}	
	replace thermal_inv12_36m = thermal_inv12_24m		
	forvalues i =730/1094{
		bysort gbcode (interviewdate) :replace thermal_inv12_36m = thermal_inv12_36m+thermal_inv12[_n-`i']	
	}	

	drop if thermal_inv12_36m == .
	
	replace thermal_inv12_36m = thermal_inv12_36m/1095 
	replace thermal_inv12_24m = thermal_inv12_24m/730 
	replace thermal_inv12_12m = thermal_inv12_12m/365 
	replace thermal_inv12_6m = thermal_inv12_6m/180 
	replace thermal_inv12_90d = thermal_inv12_90d/90  
	replace thermal_inv12_30d = thermal_inv12_30d/30  
	replace thermal_inv12_7d = thermal_inv12_7d/7  
	replace thermal_inv12_1d = thermal_inv_yesno12 
	
	keep gbcode interviewdate thermal_inv12*
	duplicates drop
save "${raw}/inverse temperture3.dta",replace	
	


use "${raw}/timegbcode list_02二.dta",clear
	append using "${raw}/timegbcode list_02一.dta"
	foreach k in 02 03 04 05 06 07 08 09 10 11 12 13 14  {
		append using "${raw}/timegbcode list_`k'二.dta" "${raw}/timegbcode list_`k'一.dta"
	}
	drop date
	gen double date = mdy(month,day,year)
	format date %tdCY-M-D 
	destring 县代码,replace
	foreach k in 15 16 17 18 19 {
		append using "${raw}/timegbcode list_`k'二.dta" "${raw}/timegbcode list_`k'一.dta"
	}	
	
	egen thermal_inv12= rowtotal(T1_thermal_inv12 T2_thermal_inv12 T3_thermal_inv12 T4_thermal_inv12),mi
	replace thermal_inv12 = thermal_inv12/4
/*	
	xtile thermal_inv12_alt = thermal_inv12,n(6)
	sum thermal_inv12,detail
*/
	gen thermal_inv12_1= thermal_inv12 ==0
	gen thermal_inv12_2= thermal_inv12 >0 & thermal_inv12  <0.12
	gen thermal_inv12_3= thermal_inv12 >= 0.12  & thermal_inv12  <0.27
	gen thermal_inv12_4= thermal_inv12 >=0.27 & thermal_inv12  < 0.51
	gen thermal_inv12_5= thermal_inv12 >= 0.51  & thermal_inv12  <0.93
	gen thermal_inv12_6= thermal_inv12 >=0.93 & thermal_inv12 !=.
	
	
	foreach k in  1 2 3 4 5 6 {
		gen thermal_inv12_`k'_7d = 0
		gen thermal_inv12_`k'_1d = 0
		
		
		forvalues i =0/6{
			bysort gbcode (interviewdate) :replace thermal_inv12_`k'_7d = thermal_inv12_`k'_7d+thermal_inv12_`k'[_n-`i']	
		}		
		gen thermal_inv12_`k'_30d = thermal_inv12_`k'_7d
		forvalues i =7/29{
			bysort gbcode (interviewdate) :replace thermal_inv12_`k'_30d = thermal_inv12_`k'_30d+thermal_inv12_`k'[_n-`i']	
		}		
		gen thermal_inv12_`k'_90d = thermal_inv12_`k'_30d
		forvalues i =30/89{
			bysort gbcode (interviewdate) :replace thermal_inv12_`k'_90d = thermal_inv12_`k'_90d+thermal_inv12_`k'[_n-`i']	
		}		
		gen thermal_inv12_`k'_6m = thermal_inv12_`k'_90d
		forvalues i =90/179{
			bysort gbcode (interviewdate) :replace thermal_inv12_`k'_6m = thermal_inv12_`k'_6m+thermal_inv12_`k'[_n-`i']	
		}	
		gen thermal_inv12_`k'_12m = thermal_inv12_`k'_6m
		forvalues i =180/364{
			bysort gbcode (interviewdate) :replace thermal_inv12_`k'_12m = thermal_inv12_`k'_12m+thermal_inv12_`k'[_n-`i']	
		}
		gen thermal_inv12_`k'_24m = thermal_inv12_`k'_12m
		forvalues i =365/729{
			bysort gbcode (interviewdate) :replace thermal_inv12_`k'_24m = thermal_inv12_`k'_24m+thermal_inv12_`k'[_n-`i']	
		}		
		gen thermal_inv12_`k'_36m = thermal_inv12_`k'_24m 
		forvalues i =730/1094{
			bysort gbcode (interviewdate) :replace thermal_inv12_`k'_36m = thermal_inv12_`k'_36m+thermal_inv12_`k'[_n-`i']	
		}	
	}	
	
	keep gbcode interviewdate thermal_inv12*
	duplicates drop
	drop if thermal_inv12_6_36m==.
	merge 1:1 gbcode interviewdate using "${raw}/inverse temperture.dta"
	drop _m
	
save "${raw}/inverse temperture.dta",replace	

************************* SO2 导入
import excel "${raw}/exposure/1980年1月~2022年3月各区县地表SO2质量浓度(微克每立方米)_第一部分.xlsx", sheet("Sheet1") clear first
	keep month 县代码 地表SO2质量浓度
	duplicates drop
	ren month date
	keep if inrange(year(date),1995,2023)	
	gen year = year(date) 
	gen month = month(date) 
	keep year month 县代码 地表SO2质量浓度
	ren 县代码 gbcode
	ren 地表SO2质量浓度 SO2
save "${int}/SO2_1.dta",replace	

import excel "${raw}/exposure/1980年1月~2022年3月各区县地表SO2质量浓度(微克每立方米)_第二部分.xlsx", sheet("Sheet1") clear first
	keep month 县代码 地表SO2质量浓度
	duplicates drop
	ren month date
	keep if inrange(year(date),1995,2023)	
	gen year = year(date) 
	gen month = month(date) 
	keep year month 县代码 地表SO2质量浓度
	ren 县代码 gbcode
	ren 地表SO2质量浓度 SO2
save "${int}/SO2_2.dta",replace	

use "${int}/SO2_1.dta",clear
	append using "${int}/SO2_2.dta"
	destring gbcode,replace
	gen so2_6 = 0
	gen so2_12 = 0
	gen so2_24 = 0
	forvalues i =0/23{
		bysort gbcode (year month) :replace so2_24 = so2_24+SO2[_n-`i']	
	}
	forvalues i =0/5{
		bysort gbcode (year month) :replace so2_6 = so2_6+SO2[_n-`i']	
	}	
	forvalues i =0/11{
		bysort gbcode (year month) :replace so2_12 = so2_12+SO2[_n-`i']	
	}		
	replace so2_24 = so2_24/24
	replace so2_6 = so2_6/6
	replace so2_12 = so2_12/12
	keep gbcode so2* year month
	duplicates drop
	drop if so2_24 == .
save "${outdata}/SO2.dta",replace	

************************* BC 导入
import excel "${raw}/exposure/1980年1月~2022年3月各区县地表黑碳质量浓度(微克每立方米)_第一部分.xlsx", sheet("Sheet1") clear first
	keep month 县代码 地表黑碳质量浓度
	duplicates drop
	ren month date
	gen year = year(date) 
	gen month = month(date) 
	keep if inrange(year(date),1995,2023)		
	keep year month 县代码 地表黑碳质量浓度
	ren 县代码 gbcode
	ren 地表黑碳质量浓度 BC
save "${int}/BC_1.dta",replace	

import excel "${raw}/exposure/1980年1月~2022年3月各区县地表黑碳质量浓度(微克每立方米)_第二部分.xlsx", sheet("Sheet1") clear first
	keep month 县代码 地表黑碳质量浓度
	duplicates drop
	ren month date
 	format date %tdCY-M-D 
	keep if inrange(year(date),1995,2023)
	gen year = year(date) 
	gen month = month(date) 
	keep year month 县代码 地表黑碳质量浓度
	ren 县代码 gbcode
	ren 地表黑碳质量浓度 BC
save "${int}/BC_2.dta",replace	

use "${int}/BC_1.dta",clear
	append using "${int}/BC_2.dta"
	gen bc_6 = 0
	gen bc_12 = 0
	gen bc_24 = 0
	forvalues i =0/23{
		bysort gbcode (year month) :replace bc_24 = bc_24+BC[_n-`i']	
	}
	forvalues i =0/5{
		bysort gbcode (year month) :replace bc_6 = bc_6+BC[_n-`i']	
	}	
	forvalues i =0/11{
		bysort gbcode (year month) :replace bc_12 = bc_12+BC[_n-`i']	
	}		
	replace bc_24 = bc_24/24
	replace bc_6 = bc_6/6
	replace bc_12 = bc_12/12
	keep gbcode bc* year month
	duplicates drop
	drop if bc_24 == .

save "${outdata}/BC.dta",replace	

************************* dust 导入
import excel "${raw}/exposure/1980年1月~2022年3月各区县地表粉尘质量浓度(微克每立方米)_第一部分.xlsx", sheet("Sheet1") clear first
	keep month 县代码 地表粉尘质量浓度
	duplicates drop
	ren month date
	gen year = year(date) 
	gen month = month(date) 
	keep if inrange(year(date),1995,2023)
	
	keep year month 县代码 地表粉尘质量浓度
	ren 县代码 gbcode
	ren 地表粉尘质量浓度 dust
save "${int}/dust_1.dta",replace	

import excel "${raw}/exposure/1980年1月~2022年3月各区县地表粉尘质量浓度(微克每立方米)_第二部分.xlsx", sheet("Sheet1") clear first
	keep month 县代码 地表粉尘质量浓度
	duplicates drop
	ren month date
	gen year = year(date) 
	gen month = month(date) 
	keep if inrange(year(date),1995,2023)
	
	keep year month 县代码 地表粉尘质量浓度
	ren 县代码 gbcode
	ren 地表粉尘质量浓度 dust
save "${int}/dust_2.dta",replace	

use "${int}/dust_1.dta",clear
	append using "${int}/dust_2.dta"
	destring gbcode,replace

	gen DUST_6 = 0
	gen DUST_12 = 0
	gen DUST_24 = 0
	forvalues i =0/23{
		bysort gbcode (year month) :replace DUST_24 = DUST_24+dust[_n-`i']	
	}
	forvalues i =0/5{
		bysort gbcode (year month) :replace DUST_6 = DUST_6+dust[_n-`i']	
	}	
	forvalues i =0/11{
		bysort gbcode (year month) :replace DUST_12 = DUST_12+dust[_n-`i']	
	}		
	replace DUST_24 = DUST_24/24
	replace DUST_6 = DUST_6/6
	replace DUST_12 = DUST_12/12
	keep gbcode DUST* year month
	duplicates drop 
	drop if DUST_24 == .

	
save "${outdata}/dust.dta",replace	



************************* PM1 导入
foreach k in  02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 { //
	import excel "${raw}/exposure/PM1/20`k'年各区县PM1质量浓度日度数据(第二部分).xlsx", first   sheet("Sheet1") clear 
	save "${int}/timegbcode list_pm1_`k'二.dta",replace	
	import excel "${raw}/exposure/PM1/20`k'年各区县PM1质量浓度日度数据(第一部分).xlsx", first   sheet("Sheet1") clear 
	save "${int}/timegbcode list_pm1_`k'一.dta",replace	
}

use "${int}/timegbcode list_pm1_02二.dta",clear
	append using "${int}/timegbcode list_pm1_02一.dta"
	foreach k in 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 {
		append using "${int}/timegbcode list_pm1_`k'二.dta" "${int}/timegbcode list_pm1_`k'一.dta"
	}
	ren 日期 interviewdate 
	ren 县代码 gbcode
	gen pm1_36m = 0
	gen pm1_24m = 0
	gen pm1_12m = 0
	gen pm1_6m = 0
	gen pm1_90d = 0
	gen pm1_30d = 0
	gen pm1_6d = 0
	gen pm1_1d = 0
	forvalues i =0/1094{
		bysort gbcode (interviewdate) :replace pm1_36m = pm1_36m+日平均[_n-`i']	
	}	
	forvalues i =0/729{
		bysort gbcode (interviewdate) :replace pm1_24m = pm1_24m+日平均[_n-`i']	
	}
	forvalues i =0/364{
		bysort gbcode (interviewdate) :replace pm1_12m = pm1_12m+日平均[_n-`i']	
	}
	forvalues i =0/179{
		bysort gbcode (interviewdate) :replace pm1_6m = pm1_6m+日平均[_n-`i']	
	}	
	forvalues i =0/89{
		bysort gbcode (interviewdate) :replace pm1_90d = pm1_90d+日平均[_n-`i']	
	}		
	forvalues i =0/29{
		bysort gbcode (interviewdate) :replace pm1_30d = pm1_30d+日平均[_n-`i']	
	}		
	forvalues i =0/6{
		bysort gbcode (interviewdate) :replace pm1_7d = pm1_7d+日平均[_n-`i']	
	}		
	replace pm1_36m = pm1_36m/1095	
	replace pm1_24m = pm1_24m/730
	replace pm1_12m = pm1_12m/365
	replace pm1_6m = pm1_6/180
	replace pm1_90d = pm1_90d/90
	replace pm1_30d = pm1_30d/30
	replace pm1_6d = pm1_6d/7
	replace pm1_1d = 日平

	
	keep gbcode interviewdate pm1* 
	duplicates drop
	drop if pm1_24 == .
save "${outdata}/PM1.dta",replace	

global raw "/Volumes/expand/Data/环境相关数据/区县日度PM10 质量浓度面板1980年1月1日～2022年10月31日/区县数据"

************************* PM10 导入
use "${raw}/timegbcode list_pm10_02二.dta",clear
	append using "${raw}/timegbcode list_pm10_02一.dta"
	foreach k in 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 {
		append using "${raw}/timegbcode list_pm10_`k'二.dta" "${raw}/timegbcode list_pm10_`k'一.dta"
	}
	ren 日期 interviewdate 
	ren 县代码 gbcode
	gen pm10_36m = 0
	gen pm10_24m = 0
	gen pm10_12m = 0
	gen pm10_6m = 0
	gen pm10_90d = 0
	gen pm10_30d = 0 
	gen pm10_7d = 0
	gen pm10_1d = 0
	forvalues i =0/1094{
		bysort gbcode (interviewdate) :replace pm10_36m = pm10_36m+日平均[_n-`i']	
	}	
	forvalues i =0/729{
		bysort gbcode (interviewdate) :replace pm10_24m = pm10_24m+日平均[_n-`i']	
	}
	forvalues i =0/364{
		bysort gbcode (interviewdate) :replace pm10_12m = pm10_12m+日平均[_n-`i']	
	}
	forvalues i =0/179{
		bysort gbcode (interviewdate) :replace pm10_6m = pm10_6m+日平均[_n-`i']	
	}	
	forvalues i =0/89{
		bysort gbcode (interviewdate) :replace pm10_90d = pm10_90d+日平均[_n-`i']	
	}		
	forvalues i =0/29{
		bysort gbcode (interviewdate) :replace pm10_30d = pm10_30d+日平均[_n-`i']	
	}		
	forvalues i =0/6{
		bysort gbcode (interviewdate) :replace pm10_7d = pm10_7d+日平均[_n-`i']	
	}		
	replace pm10_36m = pm10_36m/1095	
	replace pm10_24m = pm10_24m/730
	replace pm10_12m = pm10_12m/365
	replace pm10_6m =  pm10_6m/180
	replace pm10_90d = pm10_90d/90  
	replace pm10_30d = pm10_30d/30  
	replace pm10_7d = pm10_7d/7  
	replace pm10_1d = 日平均
	
	gen pm10_20less= 日平均 <20  
	gen pm10_2039= 日平均 >=20 & 日平均  < 40
	gen pm10_4059= 日平均 >=40 & 日平均  < 60
	gen pm10_6079= 日平均 >=60 & 日平均  < 80
	gen pm10_80100= 日平均 >=80 & 日平均  < 100
	gen pm10_100over= 日平均> 100 if 日平均!=. 
	
	foreach k in  20less  2039 4059 6079 80100 100over{
		gen pm10_`k'_7d = 0
		gen pm10_`k'_1d = 0
		
		
		forvalues i =0/6{
			bysort gbcode (interviewdate) :replace pm10_`k'_7d = pm10_`k'_7d+pm10_`k'[_n-`i']	
		}		
		gen pm10_`k'_30d = pm10_`k'_7d
		forvalues i =7/29{
			bysort gbcode (interviewdate) :replace pm10_`k'_30d = pm10_`k'_30d+pm10_`k'[_n-`i']	
		}		
		gen pm10_`k'_90d = pm10_`k'_30d
		forvalues i =30/89{
			bysort gbcode (interviewdate) :replace pm10_`k'_90d = pm10_`k'_90d+pm10_`k'[_n-`i']	
		}		
		gen pm10_`k'_6m = pm10_`k'_90d
		forvalues i =90/179{
			bysort gbcode (interviewdate) :replace pm10_`k'_6m = pm10_`k'_6m+pm10_`k'[_n-`i']	
		}	
		gen pm10_`k'_12m = pm10_`k'_6m
		forvalues i =180/364{
			bysort gbcode (interviewdate) :replace pm10_`k'_12m = pm10_`k'_12m+pm10_`k'[_n-`i']	
		}
		gen pm10_`k'_24m = pm10_`k'_12m
		forvalues i =365/729{
			bysort gbcode (interviewdate) :replace pm10_`k'_24m = pm10_`k'_24m+pm10_`k'[_n-`i']	
		}		
		gen pm10_`k'_36m = pm10_`k'_24m 
		forvalues i =730/1094{
			bysort gbcode (interviewdate) :replace pm10_`k'_36m = pm10_`k'_36m+pm10_`k'[_n-`i']	
		}	
	}	
	
	
	drop if pm10_36m == .
save "${raw}/PM10.dta",replace	
****************************
***     环境控制变量清洗       ***
****************************
************************* 降水 导入
global raw  "/Volumes/expand/Data/环境相关数据/区县日度降水量数据1973～2023 （不含栅格数据）/区县"
foreach k in  02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 { //
	import excel "${raw}/20`k'年各区县平均降水量日度数据_第二部分.xlsx", first   sheet("Sheet1") clear 
	save "${raw}/timegbcode list_precipitation_`k'二.dta",replace	
	import excel "${raw}/20`k'年各区县平均降水量日度数据_第一部分.xlsx", first   sheet("Sheet1") clear 
	save "${raw}/timegbcode list_precipitation_`k'一.dta",replace	
}

use "${raw}/timegbcode list_precipitation_02二.dta",clear
	append using "${raw}/timegbcode list_precipitation_02一.dta"
	foreach k in 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 {
		append using "${raw}/timegbcode list_precipitation_`k'二.dta" "${raw}/timegbcode list_precipitation_`k'一.dta"
	}
	ren 日期 interviewdate 
	ren 县代码 gbcode
	gen precipitation_36m = 0
	gen precipitation_24m = 0
	gen precipitation_12m = 0
	gen precipitation_6m = 0
	gen precipitation_90d = 0
	gen precipitation_30d = 0
	gen precipitation_7d = 0
	gen precipitation_1d = 0
	forvalues i =0/1094{
		bysort gbcode (interviewdate) :replace precipitation_36m = precipitation_36m+降水量[_n-`i']	
	}	
	forvalues i =0/729{
		bysort gbcode (interviewdate) :replace precipitation_24m = precipitation_24m+降水量[_n-`i']	
	}
	forvalues i =0/364{
		bysort gbcode (interviewdate) :replace precipitation_12m = precipitation_12m+降水量[_n-`i']	
	}
	forvalues i =0/179{
		bysort gbcode (interviewdate) :replace precipitation_6m = precipitation_6m+降水量[_n-`i']	
	}	
	forvalues i =0/89{
		bysort gbcode (interviewdate) :replace precipitation_90d = precipitation_90d+降水量[_n-`i']	
	}		
	forvalues i =0/29{
		bysort gbcode (interviewdate) :replace precipitation_30d = precipitation_30d+降水量[_n-`i']	
	}		
	forvalues i =0/6{
		bysort gbcode (interviewdate) :replace precipitation_7d = precipitation_7d+降水量[_n-`i']	
	}		
	replace precipitation_36m = precipitation_36m/1095	
	replace precipitation_24m = precipitation_24m/730
	replace precipitation_12m = precipitation_12m/365
	replace precipitation_6m = precipitation_6/180
	replace precipitation_90d = precipitation_90d/90
	replace precipitation_30d = precipitation_30d/30
	replace precipitation_7d = precipitation_7d/7
	replace precipitation_1d = 降水量
	keep gbcode interviewdate precipitation* 
	duplicates drop
	drop if precipitation_24 == .
save "${raw}/precipitation.dta",replace	


************************* windspeed 导入
global raw  "/Volumes/expand/Data/环境相关数据/区县日度风速数据1973-2023 年（不含栅格数据）/区县"

foreach k in  02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 { //
	import excel "${raw}/20`k'年各区县风速日度数据_第二部分.xlsx", first   sheet("Sheet1") clear 
	save "${raw}/timegbcode list_windspeed_`k'二.dta",replace	
	import excel "${raw}/20`k'年各区县风速日度数据_第一部分.xlsx", first   sheet("Sheet1") clear 
	save "${raw}/timegbcode list_windspeed_`k'一.dta",replace	
}

use "${raw}/timegbcode list_windspeed_02二.dta",clear
	append using "${raw}/timegbcode list_windspeed_02一.dta"
	foreach k in 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 {
		append using "${raw}/timegbcode list_windspeed_`k'二.dta" "${raw}/timegbcode list_windspeed_`k'一.dta"
	}
	ren 日期 interviewdate 
	ren 县代码 gbcode
	gen windspeed_36m = 0
	gen windspeed_24m = 0
	gen windspeed_12m = 0
	gen windspeed_6m = 0
	gen windspeed_90d = 0
	gen windspeed_30d = 0
	gen windspeed_7d = 0
	gen windspeed_1d = 0
	forvalues i =0/1094{
		bysort gbcode (interviewdate) :replace windspeed_36m = windspeed_36m+平均风速[_n-`i']	
	}	
	forvalues i =0/729{
		bysort gbcode (interviewdate) :replace windspeed_24m = windspeed_24m+平均风速[_n-`i']	
	}
	forvalues i =0/364{
		bysort gbcode (interviewdate) :replace windspeed_12m = windspeed_12m+平均风速[_n-`i']	
	}
	forvalues i =0/179{
		bysort gbcode (interviewdate) :replace windspeed_6m = windspeed_6m+平均风速[_n-`i']	
	}	
	forvalues i =0/89{
		bysort gbcode (interviewdate) :replace windspeed_90d = windspeed_90d+平均风速[_n-`i']	
	}		
	forvalues i =0/29{
		bysort gbcode (interviewdate) :replace windspeed_30d = windspeed_30d+平均风速[_n-`i']	
	}		
	forvalues i =0/6{
		bysort gbcode (interviewdate) :replace windspeed_7d = windspeed_7d+平均风速[_n-`i']	
	}		
	replace windspeed_36m = windspeed_36m/1095	
	replace windspeed_24m = windspeed_24m/730
	replace windspeed_12m = windspeed_12m/365
	replace windspeed_6m = windspeed_6/180
	replace windspeed_90d = windspeed_90d/90
	replace windspeed_30d = windspeed_30d/30
	replace windspeed_7d = windspeed_7d/7
	replace windspeed_1d = 平均风速
	
	keep gbcode interviewdate windspeed* 
	duplicates drop
	drop if windspeed_24 == .
save "${raw}/windspeed.dta",replace	


************************* 气温 导入
global raw  "/Volumes/expand/Data/环境相关数据/区县日度气温数据1973～2023（不含栅格数据）/区县"

foreach k in  02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 { //
	import excel "${raw}/20`k'年各区县气温日度数据_第二部分.xlsx", first   sheet("Sheet1") clear 
	save "${raw}/timegbcode list_temperture_`k'二.dta",replace	
	import excel "${raw}/20`k'年各区县气温日度数据_第一部分.xlsx", first   sheet("Sheet1") clear 
	save "${raw}/timegbcode list_temperture_`k'一.dta",replace	
}

use "${raw}/timegbcode list_temperture_02二.dta",clear
	append using "${raw}/timegbcode list_temperture_02一.dta"
	foreach k in 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 {
		append using "${raw}/timegbcode list_temperture_`k'二.dta" "${raw}/timegbcode list_temperture_`k'一.dta"
	}
	ren 日期 interviewdate 
	ren 县代码 gbcode
	gen temperture_36m = 0
	gen temperture_24m = 0
	gen temperture_12m = 0
	gen temperture_6m = 0
	gen temperture_90d = 0
	gen temperture_30d = 0
	gen temperture_7d = 0
	gen temperture_1d = 0
	forvalues i =0/1094{
		bysort gbcode (interviewdate) :replace temperture_36m = temperture_36m+平均气温[_n-`i']	
	}	
	forvalues i =0/729{
		bysort gbcode (interviewdate) :replace temperture_24m = temperture_24m+平均气温[_n-`i']	
	}
	forvalues i =0/364{
		bysort gbcode (interviewdate) :replace temperture_12m = temperture_12m+平均气温[_n-`i']	
	}
	forvalues i =0/179{
		bysort gbcode (interviewdate) :replace temperture_6m = temperture_6m+平均气温[_n-`i']	
	}	
	forvalues i =0/89{
		bysort gbcode (interviewdate) :replace temperture_90d = temperture_90d+平均气温[_n-`i']	
	}		
	forvalues i =0/29{
		bysort gbcode (interviewdate) :replace temperture_30d = temperture_30d+平均气温[_n-`i']	
	}		
	forvalues i =0/6{
		bysort gbcode (interviewdate) :replace temperture_7d = temperture_7d+平均气温[_n-`i']	
	}		
	replace temperture_36m = temperture_36m/1095	
	replace temperture_24m = temperture_24m/730
	replace temperture_12m = temperture_12m/365
	replace temperture_6m = temperture_6/180
	replace temperture_90d = temperture_90d/90
	replace temperture_30d = temperture_30d/30
	replace temperture_7d = temperture_7d/7
	replace temperture_1d = 平均气温
	
	keep gbcode interviewdate temperture* 
	duplicates drop
	drop if temperture_24 == .
save "${raw}/temperture.dta",replace	

************************* 日照 导入
**# Bookmark #1
global raw  "/Volumes/expand/Data/环境相关数据/区县日度日照时数数据1980-2022/日度/区县"

foreach k in  02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 { //
	import excel "${raw}/20`k'年各区县日照时数数据_第二部分.xlsx", first   sheet("Sheet1") clear 
	save "${raw}/timegbcode list_sunshine_`k'二.dta",replace	
	import excel "${raw}/20`k'年各区县日照时数数据_第一部分.xlsx", first   sheet("Sheet1") clear 
	save "${raw}/timegbcode list_sunshine_`k'一.dta",replace	
}

use "${raw}/timegbcode list_sunshine_02二.dta",clear
	append using "${raw}/timegbcode list_sunshine_02一.dta"
	foreach k in 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 {
		append using "${raw}/timegbcode list_sunshine_`k'二.dta" "${raw}/timegbcode list_sunshine_`k'一.dta"
	}
	ren 日期 interviewdate 
	ren 县代码 gbcode
	gen sunshine_36m = 0
	gen sunshine_24m = 0
	gen sunshine_12m = 0
	gen sunshine_6m = 0
	gen sunshine_90d = 0
	gen sunshine_30d = 0
	gen sunshine_7d = 0
	gen sunshine_1d = 0
	forvalues i =0/1094{
		bysort gbcode (interviewdate) :replace sunshine_36m = sunshine_36m+日照时数[_n-`i']	
	}	
	forvalues i =0/729{
		bysort gbcode (interviewdate) :replace sunshine_24m = sunshine_24m+日照时数[_n-`i']	
	}
	forvalues i =0/364{
		bysort gbcode (interviewdate) :replace sunshine_12m = sunshine_12m+日照时数[_n-`i']	
	}
	forvalues i =0/179{
		bysort gbcode (interviewdate) :replace sunshine_6m = sunshine_6m+日照时数[_n-`i']	
	}	
	forvalues i =0/89{
		bysort gbcode (interviewdate) :replace sunshine_90d = sunshine_90d+日照时数[_n-`i']	
	}		
	forvalues i =0/29{
		bysort gbcode (interviewdate) :replace sunshine_30d = sunshine_30d+日照时数[_n-`i']	
	}		
	forvalues i =0/6{
		bysort gbcode (interviewdate) :replace sunshine_7d = sunshine_7d+日照时数[_n-`i']	
	}		
	replace sunshine_36m = sunshine_36m/1095	
	replace sunshine_24m = sunshine_24m/730
	replace sunshine_12m = sunshine_12m/365
	replace sunshine_6m = sunshine_6/180
	replace sunshine_90d = sunshine_90d/90
	replace sunshine_30d = sunshine_30d/30
	replace sunshine_7d = sunshine_7d/7
	replace sunshine_1d = 日照时数

	keep gbcode interviewdate sunshine* 
	duplicates drop
	drop if sunshine_24 == .
save "${raw}/sunshine.dta",replace	

****************************
***    数据整理       ***
****************************
use "${outdata}/pm25.dta",clear
	merge 1:1 gbcode year month using "${outdata}/SO2.dta"
	drop _m
	merge 1:1 gbcode year month using "${outdata}/BC.dta"
	drop _m
	merge 1:1 gbcode year month using "${outdata}/dust.dta"
	drop _m
save "${outdata}/month_air_pollution.dta",replace	
	
use "${outdata}/PM10.dta",clear
	destring gbcode,replace
	merge 1:1 gbcode interviewdate using "${outdata}/PM1.dta"
	drop _m		
	destring gbcode,replace
	merge 1:1 gbcode interviewdate using "${outdata}/moister.dta"
	drop _m	
	merge 1:1 gbcode interviewdate using "${outdata}/sunshine.dta"
	drop _m	
	merge 1:1 gbcode interviewdate using "${outdata}/windspeed.dta"
	drop _m	
	merge 1:1 gbcode interviewdate using "${outdata}/precipitation.dta"
	drop _m	
	merge 1:1 gbcode interviewdate using "${outdata}/temperture.dta"
	drop _m	
save "${outdata}/daily_air_pollution.dta",replace	


use "${outdata}/daily_air_pollution.dta",clear
	merge 1:1 gbcode interviewdate using "${outdata}/inverse temperture.dta"
	keep if _m==3
	drop _m
	merge 1:1 gbcode interviewdate using "${outdata}/inverse temperture3.dta"
	keep if _m==3
	drop _m	
	merge 1:1 gbcode interviewdate using "${outdata}/PM2.5_daily.dta"	
	drop _m 
	drop 日平均
save "${outdata}/daily_air_pollution.dta",replace	

