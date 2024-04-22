use "${raw}/CLHLS区县编码-白晨2014.dta",clear
	append using "${raw}/CLHLS区县编码-白晨2011.dta" "${raw}/CLHLS区县编码-白晨2008.dta" "${raw}/CLHLS区县编码-白晨2005.dta"
	duplicates tag id,gen(a)
	bysort id:egen maxwave = max(wave)
	keep if a==0| (a>0 & maxwave ==wave)
	isid id
	tempfile t1
save `t1',replace	

use "${int}/Panel_CLHLS_frail.dta",clear
	merge m:1 id using `t1'
	keep if _m ==3
	drop _m
	ren yearin year
	ren monthin month
	drop province
	ren prov province
	merge m:1 gbcode year month using "${int}/airpm25.dta"
	duplicates drop
	
	drop if _m ==2
	
	drop if _m ==1 //去掉3,001 条没有地址信息的，但是这个不应该放在前面
	
	
	bysort id: egen total = count(id)
	keep if total >= 2 // left with 2,158	
	
**#
	keep gender edug hh_income security_pension security_insurance security_lifespan security_other security security_cat hexp_cover hexp_financeissue hexp_fampaid hexp_selfpaid nursing_living nursing_cost nursing_cover smkl_year  fra_hr fra_sleep biomass wave_alt coresidence marital srhealth waterqual incomesource smkl alcohol dril pa leisuremiss leisure bathing dressing toileting transferring continence feeding adlmiss adlsum adl fruit veg meat fish egg bean saltveg sugar tea garlic fruit1 veg1 meat1 fish1 egg1 bean1 saltveg1 sugar1 tea1 garlic1 diet dietmiss weight armlength kneelength meaheight height bmi bmicat hunchbacked SBP DBP bpl mmse mmsemiss ablephy ablephyreas hearingloss intdate fra_srh fra_hworse fra_bathing fra_dressing fra_toileting fra_transferring fra_continence fra_feeding fra_visit fra_shopping fra_cook fra_washcloth fra_walk1km fra_lift fra_standup fra_publictrans fra_visual fra_neck fra_lowerback fra_raisehands fra_stand fra_book fra_seriousillness fra_ci fra_hypertension fra_diabetes fra_htdisea fra_strokecvd fra_copd fra_tb fra_cataract fra_glaucoma fra_cancer fra_prostatetumor fra_ulcer fra_parkinson fra_bedsore fra_cholecystitis fra_chronephritis fra_rheumatism fra_hear fra_irh fra_psy1 fra_psy2 fra_psy5 fra_psy3 fra_psy4 fra_psy6 fra_housework fra_chopsticks fra_turn fra_bmi age wave_max psy1 psy2 psy5 psy7 psy3 psy4 psy6 psycho dateissue fra_psy frailsumver1 frailmissingver1 frailID1 frailsumver2 frailmissingver2 frailID2  acre plain hill mount plateau basin othgeo capdist soil landper temp7m temp1m temptop templow frostfree rain citypop01 q2000am q2000af q2000bm q2000bf q2000cm q2000cf q2000dm q2000df q2000em q2000ef q2010tm q2010tf q2010am q2010af q2010bm q2010bf q2010cm q2010cf death00 death10 urban10 ill00m ill00f pri00m pri00f sec00m sec00f hig00m hig00f col00m col00f pop6m pop6f ill10m ill10f pri10m pri10f sec10m sec10f hig10m hig10f col10m col10f gdpper08 gdpper11 gdpgrowth08 gdpgrowth11 gdpp_fi08 gdpp_fi11 gdpp_si08 gdpp_si11 hospbed11 hospnurs14 libbookper07 hospital08 hospital11 citybed08 citybed11 citydoctor08 citydoctor11 mainfood vegper08 meatper08 milkper08 seafood08 noise99 gyfspfdblv04 gyfspfl08 gyfspfl11 gyfspfdbli08 gyso2qcl08 gyso2qcl10 so299 gyso2pfl08 gyso2pfl11 gyycqcl08 gyycqcl11 gyycpfl08 gyycpfl11 gygtfwzhlyl08 gygtfwzhlyl11 shwscll08 shwscll11 shljwhhcll08 shljwhhcll11 gyfspfdbli10 envirinvest02 city county gbcode hig10f08_alt 省 市 县区 县码 a maxwave date_end prov pm25_12sum pm25_12mean _merge total id followup wavebaseline wave dayin v_bthyr v_bthmon province  residenc trueage
	drop prov
	decode province,gen(prov)
	gen treat5 = 0 if inlist(prov,"jiangxi","fujian","guangxi","hainan","helongjiang")
	gen treat10 = 0 if inlist(prov,"jiangxi","fujian","guangxi","hainan","helongjiang") | inlist(prov,"anhui","hunan","sichuan","jilin","liaoning")
	recode treat5 treat10 (.=1)
save 	"${out}/analyses_frail.dta",replace

//hypertension diabetes heartdisea strokecvd copd tb cataract glaucoma cancer prostatetumor ulcer parkinson bedsore arthritis disease_sum disease hr_irr fra_hr_irr fra_psy5 
