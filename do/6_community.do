/*import excel "/Volumes/X152/server/Community data/CLHLS_Community_Data_Collection_Final.xls", sheet("final_version") cellrange(A3:FV845)  firstrow clear
	drop if q2010tm == .
	ren urban1008  urban10
	duplicates tag q2010tm  urban10,gen(dup)
	duplicates drop q2010tm  urban10,force
	merge 1:m q2010tm urban10 using  "${raw}/CLHLS_community_dataset_2014.dta"
	keep id gbcode 
	gen wave = 14
save "${int}/CLHLS区县编码-白晨2014_alt.dta",replace

use "${int}/CLHLS区县编码-白晨2014_alt.dta",clear
	replace wave = 18
save "${int}/CLHLS区县编码-白晨2018_alt.dta",replace
*/
**************baseline merge with co
use "${outdata}/append all_fin.dta",clear
	preserve 
		use "${int}/CLHLS区县编码-白晨2018_alt.dta",clear
			append using "${int}/CLHLS区县编码-白晨2018_alt.dta"  "${int}/CLHLS区县编码-白晨2014_alt.dta" "${raw}/CLHLS区县编码-白晨2008.dta"  "${raw}/CLHLS区县编码-白晨2011.dta"  "${raw}/CLHLS区县编码-白晨2005.dta"
			keep id gbcode wave
			replace wave = 2014 if wave ==14
			replace wave = 2011 if wave ==11
			replace wave = 2018 if wave ==18
			replace wave = 2008 if wave ==08
			replace wave = 2005 if wave ==05
			duplicates drop
			tempfile t1
		save `t1',replace
	restore
	merge 1:m id wave using `t1'
	drop if _m ==2
	drop _m	

	preserve 
		use "${raw}/CLHLS_community_dataset_2005.dta",clear
			append using "${raw}/CLHLS_community_dataset_2011.dta" "${raw}/CLHLS_community_dataset_2014.dta" "${raw}/CLHLS_community_dataset_2008.dta" 
			duplicates drop
			replace wave = 2014 if wave ==14
			replace wave = 2011 if wave ==11
			replace wave = 2018 if wave ==18
			replace wave = 2008 if wave ==08
			replace wave = 2005 if wave ==05
			replace wave = 2002 if wave ==02
			replace wave = 2000 if wave ==0
			replace wave = 1998 if wave ==98
			
			tempfile t1
		save `t1',replace
	restore	
	merge m:1 id wave using `t1'
	drop if _m == 2
	drop _m	
save "${int}/Full_CLHLS_covariants_comm.dta",replace	
xx
**************baseline merge with co
use "${int}/Panel_CLHLS05-18_covariants.dta",clear
	preserve 
		use "${raw}/CLHLS区县编码-白晨2014.dta",clear
			gen wave = 14 
			keep id gbcode county wave
			duplicates drop
			tempfile t1
		save `t1',replace
	restore
	merge m:1 id wave using `t1'
	drop if _m ==2 
	drop _m
	preserve 
		use "${raw}/CLHLS区县编码-白晨2008.dta",clear
			keep id gbcode   wave
			duplicates drop
			tempfile t1
		save `t1',replace
	restore
	merge m:1 id wave using `t1'
	drop if _m ==2 
	drop _m
	preserve 
		use "${raw}/CLHLS区县编码-白晨2011.dta",clear
			keep id gbcode   wave
			duplicates drop
			tempfile t1
		save `t1',replace
	restore
	merge m:1 id wave using `t1'
	drop if _m ==2 
	drop _m	
	preserve 
		use "${raw}/CLHLS区县编码-白晨2005.dta",clear
			gen wave = 05
			keep id gbcode wave
			duplicates drop
			tempfile t1
		save `t1',replace
	restore
	merge m:1 id wave using `t1'
	drop if _m ==2 
	drop _m	

	preserve 
		use "${raw}/CLHLS_community_dataset_2008.dta",clear
			gen wave = 8
			duplicates drop
			tempfile t1
		save `t1',replace
	restore	
	merge m:1 id wave using `t1'
	drop if _m == 2
	drop _m	
	
	preserve 
		use "${raw}/CLHLS_community_dataset_2005.dta",clear
			gen wave = 5
			duplicates drop
			tempfile t1
		save `t1',replace
	restore	
	merge m:1 id wave using `t1'
	drop if _m == 2	
	drop _m	
	
	preserve 
		use "${raw}/CLHLS_community_dataset_2011.dta",clear
			gen wave = 11
			duplicates drop
			tempfile t1
		save `t1',replace
	restore	
	merge m:1 id wave using `t1'
	drop if _m == 2	
	drop _m	
	
	preserve 
		use "${raw}/CLHLS_community_dataset_2014.dta",clear
			gen wave = 14
			duplicates drop
			tempfile t1
		save `t1',replace
	restore	
	merge m:1 id wave using `t1'
	drop if _m == 2	
	drop _m	
save "${int}/Panel_CLHLS05-18_covariants.dta",replace	


**************baseline merge with co
use "${raw}/CLHLS区县编码-白晨2014.dta",clear
	gen wave = 2014 
	keep id gbcode county wave
	duplicates drop
	tempfile t1
save `t1',replace
use "${raw}/CLHLS区县编码-白晨2008.dta",clear
	keep id gbcode   wave
	replace wave = 2008
	duplicates drop
	tempfile t2
save `t2',replace
use "${raw}/CLHLS区县编码-白晨2011.dta",clear
	keep id gbcode   wave
	replace wave =2011
	duplicates drop
	tempfile t3
save `t3',replace
use "${raw}/CLHLS区县编码-白晨2005.dta",clear
	keep id gbcode wave
	replace wave =2005
	duplicates drop
	tempfile t4
	append using `t1' `t2' `t3'
save `t4',replace


use "${raw}/CLHLS_community_dataset_2008.dta",clear
	duplicates drop
	replace wave =2008
	tempfile t5
save `t5',replace
use "${raw}/CLHLS_community_dataset_2005.dta",clear
	duplicates drop
	replace wave = 2005
	tempfile t6
save `t6',replace
use "${raw}/CLHLS_community_dataset_2011.dta",clear
	duplicates drop
	replace wave =2011
	tempfile t7
save `t7',replace
use "${raw}/CLHLS_community_dataset_2014.dta",clear
	duplicates drop
	replace wave =2014
	append using `t5' `t6' `t7'
	merge 1:m id  wave using `t4'
	
	keep if 
save `t1',replace





use "${outdata}/append all_fin.dta",clear
	merge m:1 id wave using `t1'
	drop if _m == 2	
	drop _m	
save "${outdata}/Panel_CLHLS_covariants.dta",replace	

