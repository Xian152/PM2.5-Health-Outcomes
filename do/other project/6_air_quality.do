use "/Users/xurui/Library/CloudStorage/Box-Box/项目/airquality_frailty_DID/A2 Data Cleaned/raw/CO.dta",clear
	ren (年份 省 市 县 县代码) (year prov city county gbcode)
	keep CO gbcode county city prov year CO_24h
	keep if inlist(year,2014,2018)
	tempfile t1
save `t1',replace
	
use "/Users/xurui/Library/CloudStorage/Box-Box/项目/airquality_frailty_DID/A2 Data Cleaned/raw/no2.dta",clear
	ren (年份 省 市 县 县代码) (year prov city county gbcode)
	keep NO2 gbcode county city prov year 
	keep if inlist(year,2014,2018)
	merge 1:1 gbcode year using `t1'
	drop _m
save `t1',replace


import excel "/Users/xurui/Library/CloudStorage/Box-Box/项目/airquality_frailty_DID/A2 Data Cleaned/raw/1951-01～2020-12中国各区县平均气温月度数据_第三部分.xlsx", sheet("Sheet1") firstrow clear
	ren (年份 省 市 县 县代码 月 平均气温) (year prov city county gbcode month temperture)
	keep  year prov city county gbcode month temperture
	keep if inlist(year,2014,2018)
	merge m:1 gbcode year using `t1'
	
	drop _m
save `t1',replace


use "/Users/xurui/Library/CloudStorage/Box-Box/项目/airquality_frailty_DID/A2 Data Cleaned/raw/pm25.dta",clear
	ren (年份 省 市 县 县代码) (year prov city county gbcode)
	keep PM25_24h PM25 gbcode county city prov year 
	keep if inlist(year,2014,2018)
	merge 1:m gbcode year using `t1'
	drop _m	
save "${int}/airquality.dta",replace	


**#
import excel  "/Users/mac/Library/CloudStorage/Box-Box/项目/airquality_frailty_DID/7. air-quality/1980年1月~2022年3月各区县地表PM2.5质量浓度(微克每立方米)_第二部分.xlsx", sheet("Sheet1") firstrow clear
	ren (省 市 县 县代码) (prov city county gbcode)
	gen year = year(month)
	ren month date
	gen month= month(date)
	keep if inlist(year,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019)
	gen monthtotal = month + (year-2006)*12
	

	forvalues i = 1/157{
		local a = `i'+11
		gen time`i' = `i' if inrange(monthtotal,`i',`a')
	}
	

	forvalues i = 1/157{
		preserve
			keep if time`i' == `i'
			bysort gbcode : egen pm25_12sum=sum(地表PM25质量浓度)
			bysort gbcode : egen pm25_12mean=mean(地表PM25质量浓度)
			keep gbcode pm25* 
			gen time = `i'
			duplicates drop
			tempfile save`i'
			save `save`i''	,replace		
		restore
	}	
	
	use `save1',clear
	forvalues i = 2/157{
		append using `save`i''		
	}	
save "${int}/airpm25temp.dta",replace	
	
import excel  "/Users/mac/Library/CloudStorage/Box-Box/项目/airquality_frailty_DID/7. air-quality/1980年1月~2022年3月各区县地表PM2.5质量浓度(微克每立方米)_第二部分.xlsx", sheet("Sheet1") firstrow clear
	ren (省 市 县 县代码) (prov city county gbcode)
	keep prov city county gbcode  
	duplicates drop 
	merge 1:m gbcode using "${int}/airpm25temp.dta"
	drop _m
save "${int}/airpm25temp1.dta",replace	
	
import excel  "/Users/mac/Library/CloudStorage/Box-Box/项目/airquality_frailty_DID/7. air-quality/1980年1月~2022年3月各区县地表PM2.5质量浓度(微克每立方米)_第二部分.xlsx", sheet("Sheet1") firstrow clear
	keep month
	gen year = year(month)
	ren month date
	gen month= month(date)
	keep if inlist(year,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019)
	duplicates drop
	gen monthtotal = month + (year-2006)*12
	keep date monthtotal
	ren monthtotal time
	merge 1:m time using "${int}/airpm25temp1.dta"
	drop _m
	replace date = date+2*365
	ren date date_end
	drop time
save "${int}/airpm25.dta",replace	


	