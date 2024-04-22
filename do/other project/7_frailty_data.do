use "${int}/Panel_CLHLS08-14_covariants.dta",clear
	
**#
    egen frailsumver1 = rowtotal(fra_hypertension fra_htdisea fra_strokecvd fra_copd fra_tb fra_ulcer fra_diabetes fra_cancer fra_prostatetumor fra_parkinson fra_bedsore fra_cataract fra_glaucoma fra_seriousillness fra_srh fra_irh fra_bathing fra_dressing fra_toileting fra_transferring fra_continence fra_feeding fra_neck fra_lowerback fra_stand fra_book fra_hear fra_visual fra_turn fra_psy1 fra_psy2 fra__psy5 fra_psy3  fra_psy6 fra_housework fra_chopsticks fra_hr),mi
	drop if frailsumver1 == .
	
	egen frailmissingver1 = rowmiss(fra_hypertension fra_htdisea fra_strokecvd fra_copd fra_tb fra_ulcer fra_diabetes fra_cancer fra_prostatetumor fra_parkinson fra_bedsore fra_cataract fra_glaucoma fra_seriousillness fra_srh fra_irh fra_bathing fra_dressing fra_toileting fra_transferring fra_continence fra_feeding fra_neck fra_lowerback fra_stand fra_book fra_hear fra_visual fra_turn fra_psy1 fra_psy2 fra__psy5 fra_psy3  fra_psy6 fra_housework fra_chopsticks fra_hr)
	
	drop if frailmissingver1 >=10 // a lot miss in psychological survey
	
	gen frailID = frailsumver1/(37-frailmissingver1) 
		
	//keep if wavebaseline >=11
	
	keep if age >=65
	xx
	bysort id: egen total = count(id)
	
	drop if total ==1
	
	preserve 
		use "${int}/Full_dat18_18_covariances.dta",clear
			keep id distance win_spring win_summer win_autumn win_winter
			tempfile t1
		save `t1',replace		
	restore 
	merge m:1 id using `t1'
	keep if _m ==3
	drop _m
	
/*	
	gen fra_ilID = fra_ilsum/(37-fra_ilmissing) 
	
	xtile fra_il_cat = fra_ilID, n(6) // 分
*/	
/*
 bysort fra_il_cat:sum fra_ilID

-----------------------------------------------------------------------------------------------------------
-> fra_il_cat = 1

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
     fra_ilID |      1,162    .0681306    .0133083   .0277778   .0810811

-----------------------------------------------------------------------------------------------------------
-> fra_il_cat = 2

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
     fra_ilID |        889    .1000992    .0114693   .0833333   .1081081

-----------------------------------------------------------------------------------------------------------
-> fra_il_cat = 3

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
     fra_ilID |        370    .1115573    .0011048   .1111111   .1142857

-----------------------------------------------------------------------------------------------------------
-> fra_il_cat = 4

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
     fra_ilID |      1,105    .1448855    .0119158   .1351351   .1621622

-----------------------------------------------------------------------------------------------------------
-> fra_il_cat = 5

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
     fra_ilID |        501    .1815499     .011729   .1666667   .1944444

-----------------------------------------------------------------------------------------------------------
-> fra_il_cat = 6

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
     fra_ilID |        765    .2785321    .0738269         .2   .7297297
*/

	preserve 
		use "${raw}/CLHLS区县编码-白晨2014.dta",clear
			keep id gbcode province city county 
			append using "${raw}/CLHLS区县编码-白晨2011.dta" 
			tempfile t1
		save `t1',replace
	restore
	merge m:1 id using `t1'
	drop if _m ==2
	drop _m
	
save "${int}/Panel_CLHLS_frail_newenergy.dta",replace	
