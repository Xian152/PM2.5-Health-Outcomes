****************************
***     环境数据清洗       ***
****************************
*********************************** PM 2.5 导入
global raw "/Volumes/expand/Data/环境相关数据/区县日度地表PM2.5质量浓度1980年1月1日～2022年6月30日/城市数据"

foreach k in 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19{
	import excel "${raw}/20`k'年各城市日度地表PM2.5质量浓度(微克每立方米).xlsx", first sheet("Sheet1") clear 
	save "${raw}/timecity list_`k'.dta",replace	
}

use "${raw}/timecity list_02.dta",clear
	foreach k in 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 {
		append using "${raw}/timecity list_`k'.dta" 
	}
	ren 日期 interviewdate 
	ren 市代码 gbcode
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

	gen pm25_36m = 0
	gen pm25_24m = 0
	gen pm25_12m = 0
	gen pm25_6m = 0
	gen pm25_90d = 0
	gen pm25_30d = 0 
	gen pm25_7d = 0
	gen pm25_1d = 0	
	forvalues i =0/1094{
		bysort gbcode (interviewdate) :replace pm25_36m = pm25_36m+日平均[_n-`i']	
	}	
	forvalues i =0/729{
		bysort gbcode (interviewdate) :replace pm25_24m = pm25_24m+日平均[_n-`i']	
	}
	forvalues i =0/364{
		bysort gbcode (interviewdate) :replace pm25_12m = pm25_12m+日平均[_n-`i']	
	}
	forvalues i =0/179{
		bysort gbcode (interviewdate) :replace pm25_6m = pm25_6m+日平均[_n-`i']	
	}	
	forvalues i =0/89{
		bysort gbcode (interviewdate) :replace pm25_90d = pm25_90d+日平均[_n-`i']	
	}		
	forvalues i =0/29{
		bysort gbcode (interviewdate) :replace pm25_30d = pm25_30d+日平均[_n-`i']	
	}		
	forvalues i =0/6{
		bysort gbcode (interviewdate) :replace pm25_7d = pm25_7d+日平均[_n-`i']	
	}		
	replace pm25_36m = pm25_36m/1095	
	replace pm25_24m = pm25_24m/730
	replace pm25_12m = pm25_12m/365
	replace pm25_6m =  pm25_6m/180
	replace pm25_90d = pm25_90d/90  
	replace pm25_30d = pm25_30d/30  
	replace pm25_7d = pm25_7d/7  
	replace pm25_1d = 日平均		
	
	keep gbcode interviewdate pm25* 日平均
	duplicates drop
	drop if pm25_4059_36m == .	
	
save "${raw}/PM2.5_daily_city.dta",replace	


global raw "/Volumes/expand/Data/环境相关数据/区县日度逆温数据1980~2022年/cityxlsx"
************************* inverse temp 导入
foreach k in 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19{
	import excel "${raw}/20`k'年各城市逆温数据.xlsx", first sheet("Sheet1") clear 
	save "${raw}/timecity list_`k'.dta",replace	
}

use "${raw}/timecity list_02.dta",clear
	foreach k in 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 {
		append using "${raw}/timecity list_`k'.dta"
	}
	drop date
	gen double date = mdy(month,day,year)
	format date %tdCY-M-D 

	ren date interviewdate
	ren 市代码 gbcode
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
	
	keep gbcode interviewdate thermal_inv12* inversedate*
	duplicates drop
	drop if thermal_inv12_6_36m==.
	
save "${raw}/inverse temperture——city.dta",replace	
****************************
***     环境控制变量清洗       ***
****************************
************************* 降水 导入
global raw  "/Volumes/expand/Data/环境相关数据/区县日度降水量数据1973～2023 （不含栅格数据）/城市"
foreach k in  02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 { //
	import excel "${raw}/20`k'年各城市平均降水量日度数据.xlsx", first   sheet("Sheet1") clear 
	save "${raw}/timecity list_precipitation_`k'.dta",replace	
}

use "${raw}/timecity list_precipitation_02.dta",clear
	foreach k in 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 {
		append using "${raw}/timecity list_precipitation_`k'.dta"
	}
	ren 日期 interviewdate 
	ren 市代码 gbcode
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
save "${raw}/precipitation_city.dta",replace	



************************* windspeed 导入
global raw  "/Volumes/expand/Data/环境相关数据/区县日度风速数据1973-2023 年（不含栅格数据）/城市"

foreach k in  02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 { //
	import excel "${raw}/20`k'年各城市风速日度数据.xlsx", first   sheet("Sheet1") clear 
	save "${raw}/timecity list_windspeed_`k'.dta",replace	
}

use "${raw}/timecity list_windspeed_02.dta",clear
	foreach k in 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 {
		append using "${raw}/timecity list_windspeed_`k'.dta" 
	}
	ren 日期 interviewdate 
	ren 市代码 gbcode
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
save "${raw}/windspeed_city.dta",replace	


************************* 气温 导入
global raw  "/Volumes/expand/Data/环境相关数据/区县日度气温数据1973～2023（不含栅格数据）/城市"

foreach k in  02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 { //
	import excel "${raw}/20`k'年各城市气温日度数据.xlsx", first   sheet("Sheet1") clear 
	save "${raw}/timecity list_temperture_`k'.dta",replace	
}

use "${raw}/timecity list_temperture_02.dta",clear
	append using "${raw}/timecity list_temperture_02.dta"
	foreach k in 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 {
		append using "${raw}/timecity list_temperture_`k'.dta" 
	}
	ren 日期 interviewdate 
	ren 市代码 gbcode
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
save "${raw}/temperture_city.dta",replace	

************************* 日照 导入
global raw  "/Volumes/expand/Data/环境相关数据/区县日度日照时数数据1980-2022/日度/城市"

foreach k in  02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 { //
	import excel "${raw}/20`k'年各城市日照时数数据.xlsx", first   sheet("Sheet1") clear 
	save "${raw}/timecity list_sunshine_`k'.dta",replace	
}

use "${raw}/timecity list_sunshine_02.dta",clear
	append using "${raw}/timecity list_sunshine_02.dta"
	foreach k in 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 {
		append using "${raw}/timecity list_sunshine_`k'.dta" "${raw}/timecity list_sunshine_`k'.dta"
	}
	ren 日期 interviewdate 
	ren 市代码 gbcode
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
save "${raw}/sunshine_city.dta",replace	

************************* 相对湿度导入
global raw  "/Volumes/expand/Data/环境相关数据/区县日度相对湿度1980-2022/日度/城市"

foreach k in  02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 { //
	import excel "${raw}/20`k'年各城市相对湿度数据.xlsx", first   sheet("Sheet1") clear 
	save "${raw}/timecity list_moister_`k'.dta",replace	
}

use "${raw}/timecity list_moister_02.dta",clear
	append using "${raw}/timecity list_moister_02.dta"
	foreach k in 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 {
		append using "${raw}/timecity list_moister_`k'.dta"  
	}
	ren 日期 interviewdate 
	ren 市代码 gbcode
	gen moister_36m = 0
	gen moister_24m = 0
	gen moister_12m = 0
	gen moister_6m = 0
	gen moister_90d = 0
	gen moister_30d = 0
	gen moister_7d = 0
	gen moister_1d = 0
	forvalues i =0/1094{
		bysort gbcode (interviewdate) :replace moister_36m = moister_36m+平均相对湿度[_n-`i']	
	}	
	forvalues i =0/729{
		bysort gbcode (interviewdate) :replace moister_24m = moister_24m+平均相对湿度[_n-`i']	
	}
	forvalues i =0/364{
		bysort gbcode (interviewdate) :replace moister_12m = moister_12m+平均相对湿度[_n-`i']	
	}
	forvalues i =0/179{
		bysort gbcode (interviewdate) :replace moister_6m = moister_6m+平均相对湿度[_n-`i']	
	}	
	forvalues i =0/89{
		bysort gbcode (interviewdate) :replace moister_90d = moister_90d+平均相对湿度[_n-`i']	
	}		
	forvalues i =0/29{
		bysort gbcode (interviewdate) :replace moister_30d = moister_30d+平均相对湿度[_n-`i']	
	}		
	forvalues i =0/6{
		bysort gbcode (interviewdate) :replace moister_7d = moister_7d+平均相对湿度[_n-`i']	
	}		
	replace moister_36m = moister_36m/1095	
	replace moister_24m = moister_24m/730
	replace moister_12m = moister_12m/365
	replace moister_6m = moister_6/180
	replace moister_90d = moister_90d/90
	replace moister_30d = moister_30d/30
	replace moister_7d = moister_7d/7
	replace moister_1d = 平均相对湿度

	keep gbcode interviewdate moister* 
	duplicates drop
	drop if moister_36m == .
save "${raw}/moister——city.dta",replace	


****市
use "${raw}/timecity list_moister_02.dta",clear
	append using "${raw}/timecity list_moister_02.dta"
	foreach k in 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 {
		append using "${raw}/timecity list_moister_`k'.dta"  
	}
	ren 日期 interviewdate 
	ren 市代码 gbcode
	
	keep gbcode 市
	duplicates drop
save "${raw}/city.dta",replace	
	
****************************
***    数据整理       ***
****************************
use "/Volumes/expand/Data/环境相关数据/区县日度地表PM2.5质量浓度1980年1月1日～2022年6月30日/城市数据/PM2.5_daily_city.dta",clear
	merge 1:1 gbcode interviewdate using "/Volumes/expand/Data/环境相关数据/区县日度逆温数据1980~2022年/cityxlsx/inverse temperture——city.dta"
	keep if _m == 3 
	drop _m	
	merge 1:1 gbcode interviewdate using "/Volumes/expand/Data/环境相关数据/区县日度相对湿度1980-2022/日度/城市/moister——city.dta"
	keep if _m == 3 
	drop _m	
	merge 1:1 gbcode interviewdate using "/Volumes/expand/Data/环境相关数据/区县日度日照时数数据1980-2022/日度/城市/sunshine.dta"
	keep if _m == 3 
	drop _m	
	merge 1:1 gbcode interviewdate using "/Volumes/expand/Data/环境相关数据/区县日度风速数据1973-2023 年（不含栅格数据）/城市/windspeed_city.dta"
	keep if _m == 3 
	drop _m	
	merge 1:1 gbcode interviewdate using "/Volumes/expand/Data/环境相关数据/区县日度降水量数据1973～2023 （不含栅格数据）/城市/precipitation_city.dta"
	keep if _m == 3 
	drop _m	
	merge 1:1 gbcode interviewdate using "/Volumes/expand/Data/环境相关数据/区县日度气温数据1973～2023（不含栅格数据）/城市/temperture_city.dta"
	keep if _m == 3 
	drop _m	
	merge 1:1 gbcode interviewdate using "/Volumes/expand/Data/环境相关数据/区县日度气温数据1973～2023（不含栅格数据）/城市/temperture_city.dta"
	keep if _m == 3 
	drop _m		
	merge m:1 gbcode using "/Volumes/expand/Data/环境相关数据/区县日度相对湿度1980-2022/日度/城市/city.dta"
	keep if _m == 3 
	drop _m	
save "/Users/x152/Desktop/daily_air_pollution_city.dta",replace	

