//ssc install sdid
import delimited "/Users/xianzhang/Desktop/加id.csv",clear
	egen fra_ilsum_m = rowtotal(fra_srh fra_bathing fra_dressing fra_toileting fra_transferring fra_continence fra_feeding fra_visual fra_neck fra_lowerback fra_stand fra_book fra_seriousillness fra_hypertension fra_diabetes fra_htdisea fra_strokecvd fra_copd fra_tb fra_cataract fra_glaucoma fra_cancer fra_prostatetumor fra_ulcer fra_parkinson fra_bedsore fra_hear fra_irh fra_psy1 fra_psy2 fra_psy3 fra_psy6 fra_housework fra_chopsticks fra_turn),mi
	//drop if fra_ilsum == .
	
	egen fra_ilmissing_m = rowmiss(fra_srh fra_bathing fra_dressing fra_toileting fra_transferring fra_continence fra_feeding fra_visual fra_neck fra_lowerback fra_stand fra_book fra_seriousillness fra_hypertension fra_diabetes fra_htdisea fra_strokecvd fra_copd fra_tb fra_cataract fra_glaucoma fra_cancer fra_prostatetumor fra_ulcer fra_parkinson fra_bedsore fra_hear fra_irh fra_psy1 fra_psy2 fra_psy3 fra_psy6 fra_housework fra_chopsticks fra_turn)

	gen fra_ratio_m = fra_ilsum_m/35
	
	preserve
		use "${out}/analyses_frail.dta",clear
			keep  id wave followup trueage gender incomesource acre plain hill mount plateau basin othgeo capdist soil landper temp7m temp1m temptop templow frostfree rain citypop01 q2000am q2000af q2000bm q2000bf q2000cm q2000cf q2000dm q2000df q2000em q2000ef q2010tm q2010tf q2010am q2010af q2010bm q2010bf q2010cm q2010cf death00 death10 urban10 ill00m ill00f pri00m pri00f sec00m sec00f hig00m hig00f col00m col00f pop6m pop6f ill10m ill10f pri10m pri10f sec10m sec10f hig10m hig10f col10m col10f gdpper08 gdpper11 gdpgrowth08 gdpgrowth11 gdpp_fi08 gdpp_fi11 gdpp_si08 gdpp_si11 hospbed11 hospnurs14 libbookper07 hospital08 hospital11 citybed08 citybed11 citydoctor08 citydoctor11 mainfood vegper08 meatper08 milkper08 seafood08 noise99 gyfspfdblv04 gyfspfl08 gyfspfl11 gyfspfdbli08 gyso2qcl08 gyso2qcl10 so299 gyso2pfl08 gyso2pfl11 gyycqcl08 gyycqcl11 gyycpfl08 gyycpfl11 gygtfwzhlyl08 gygtfwzhlyl11 shwscll08 shwscll11 shljwhhcll08 shljwhhcll11 gyfspfdbli10 envirinvest02 biomass w_2014
			ren biomass biomass_origin
			tempfile t1
		save `t1',replace
	restore
	merge 1:1 id wave using `t1'
	drop _m
	

	
	drop if biomass_origin == .
	bysort id: gen count = _N
	drop if count !=2
	codebook id //3,192  
	
save "${out}/analyses_frail_M1111.dta",replace



use "${int}/Panel_CLHLS_frail_newenergy.dta",clear
**#
	gen treat = . 
	replace treat = 1 if (inlist(city,"北京","上海","重庆","长春","大连","杭州") |inlist(city,"济南","武汉","深圳","合肥","长沙","昆明","南昌")) & inlist(wave,8)	
	replace treat = 1 if (inlist(city,"北京","上海","重庆","长春","大连","杭州") |inlist(city,"济南","武汉","深圳","合肥","长沙","昆明","南昌")|inlist(city,"上海", "长春","深圳","杭州")) & inlist(wave,11)
	replace treat = 1 if (inlist(city,"北京","上海","重庆","长春","大连","杭州") |inlist(city,"济南","武汉","深圳","合肥","长沙","昆明","南昌")|inlist(city,"上海", "长春","深圳","杭州")|inlist(city,"大连" "上海" "宁波" "合肥" "芜湖" "青岛" "郑州" "新乡" "武汉" "襄阳") |inlist(city, "长株潭地区" "广州" "深圳" "海口" "成都") |inlist(city, "重庆" "昆明" "西安" "兰州" "北京" "天津" "太原") |inlist(city, "晋城" "石家庄" "含辛集" "唐山" "邯郸" "保定" "定州" "邢台") |inlist(city, "廊坊" "衡水" "沧州" "承德" "张家口" "福州" "厦门") |inlist(city, "漳州" "泉州" "三明" "莆田" "南平" "龙岩" "宁德" "平潭" "杭州") |inlist(city, "金华" "绍兴" "湖州" "南昌" "九江" "抚州") |inlist(city, "宜春" "萍乡" "上饶" "赣州" "" "佛山" "东莞" "中山" "珠海" "惠州" "江门" "肇庆") |inlist(city,"呼和浩特","包头","沈阳","长春","哈尔滨")|inlist(city,"南京","常州","苏州","南通","盐城")|inlist(city,"扬州","淄博","临沂","潍坊","聊城")|inlist(city,"泸州","贵阳","遵义","毕节","安顺","六盘水","黔东")|inlist(city,"南州","昆明","丽江","玉溪","大理")|inlist(city,"济南","武汉","深圳","合肥","长沙","昆明","南昌") | ///
	inlist(province,"大连" "上海" "宁波" "合肥" "芜湖" "青岛" "郑州" "新乡" "武汉" "襄阳") |inlist(province, "长株潭地区" "广州" "深圳" "海口" "成都") |inlist(province, "重庆" "昆明" "西安" "兰州" "北京" "天津" "太原") |inlist(province, "晋城" "石家庄" "含辛集" "唐山" "邯郸" "保定" "定州" "邢台") |inlist(province, "廊坊" "衡水" "沧州" "承德" "张家口" "福州" "厦门") |inlist(province, "漳州" "泉州" "三明" "莆田" "南平" "龙岩" "宁德" "平潭" "杭州") |inlist(province, "金华" "绍兴" "湖州" "南昌" "九江" "抚州") |inlist(province, "宜春" "萍乡" "上饶" "赣州" "" "佛山" "东莞" "中山" "珠海" "惠州" "江门" "肇庆") |inlist(province,"济南","武汉","深圳","合肥","长沙","昆明","南昌")) & inlist(wave,14)
	//replace treat = 1 if inlist(city,"上海","长春","深圳","杭州","合肥") & inlist(wave,18)
	recode treat (.=0)
	
*** stagged did
***cohort = final treatment duration
egen cohort = sum(treat), by(id)

***current treatment duration duration 
bysort id: gen dur = sum(treat)

xtset id wave

// cohort*duration specification and ATT
gen logfra_index = log(frailID)
areg logfra_index i.wave ibn.dur#ibn.cohort#c.treat, absorb(id)
margins, dydx(treat) subpop(if treat==1)

// using xtreg instead
xtreg logfra_index i.wave ibn.dur#ibn.cohort#c.treat, fe
margins, dydx(treat) subpop(if treat==1)

// duration-specific effects (event study)
margins, dydx(treat) subpop(if dur==1)
margins, dydx(treat) subpop(if dur==2)
margins, dydx(treat) subpop(if dur==3)

// -----------------------------------------------------------------------------
// Demonstrating that this is the same as manual aggregation
// -----------------------------------------------------------------------------

// generate the weights
local sum=0
forvalues c=1/3 {
  forvalues p=1/3 {
			gen cp_`c'`p'=(cohort==`c' & dur==`p')
			gen dcp_`c'`p'=(cohort==`c' & dur==`p' & treat)
			sum cp_`c'`p' if treat
			local cp_`c'`p'=`r(mean)'
			local sum = `sum' + `r(mean)'
			di `terms'
	}
}
di `sum'

// run the regression
areg logfra_index i.wave dcp_*, absorb(id)

// aggregate the effects
local terms
forvalues c=1/3 {
  forvalues p=1/3 {
			local terms `terms' + `cp_`c'`p''*_b[dcp_`c'`p']
			//di `terms'
	}
}

lincom `terms'

xx

use "${int}/Panel_CLHLS_frail_newenergy.dta",clear
	gen fra_cat = fra_ratio>=0.164286  if fra_ratio!=.
	gen fra_cat_m = fra_ratio_m>=0.164286  if fra_ratio_m!=.

	* difference 	
	codebook gbcode //428   
	
	preserve 
		recode biomass_origin  (3 4 = .)
		bysort id (followup):gen biomass_diff = biomass_origin - biomass_origin[_n-1]
		tab province biomass_diff if biomass_diff!=.,mi
	restore
	
****************** table 1
preserve 
keep if wave ==14

table1,  by(biomass_origin) vars(trueage contn \ gender cat\ ethnicity cat\ ///
\ residence cat \ edug cat\ occupation cat\ coresidence cat\ marital cat\  fra_ratio contn\ security_cat cat\ incomesource cat\ smkl cat\ dril  cat\ pa  cat\ diet  cat\ leisure  contn\ ) format(%2.1f) one saving("${out}/DSA1.xls", replace) 

table1,  vars(trueage contn \ gender cat\ ethnicity cat\ ///
\ residence cat \ edug cat\ occupation cat\ coresidence cat\ marital cat\  fra_ratio contn\ security_cat cat\ incomesource cat\ smkl cat\ dril  cat\ pa  cat\ diet  cat\ leisure  contn\ ) format(%2.1f) one saving("${out}/DSA.xls", replace) 

restore


****************** 基本ols
global y 				logfrailID	
global key 				biomass
global demo 			trueage i.gender i.ethnicity
global socialeconomic  	i.occupation i.residence i.edug i.security_cat i.marital i.coresidence i.incomesource
global lifestyle 		i.smkl i.dril i.pa diet leisure
global environ 			i.waterqual 

recode biomass (3 4 =.)

gen logfrailID = log(frailID) 
preserve 
keep if wave == 14 | wave == 18
reg $y $key $demo 
outreg2 using "${out}/ols14.xls",replace excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1,0.15) symbol(***,**,*,+)  ///
title("ols")

reg $y $key $demo $lifestyle 
outreg2 using "${out}/ols14.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1,0.15) symbol(***,**,*,+)  ///
title("ols")

reg $y $key $demo $lifestyle   $sociaeconomic
outreg2 using "${out}/ols14.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1,0.15) symbol(***,**,*,+)  ///
title("ols")

reg $y $key $demo $lifestyle $sociaeconomic $environ 
outreg2 using "${out}/ols14.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1,0.15) symbol(***,**,*,+)  ///
title("ols")
restore
****************** 2sls
preserve
keep if wave==14
ivregress 2sls $y ($key = i.residence i.coresidence ) $demo [aw = w_2014]

outreg2 using "${out}/2sls.xls",replace excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1,0.15) symbol(***,**,*,+) ///
title("2sls")

ivregress 2sls $y ($key = i.residence i.coresidence ) $demo $lifestyle [aw = w_2014]
	
outreg2 using "${out}/2sls.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1,0.15) symbol(***,**,*,+) ///
title("2sls")	


ivregress 2sls $y ($key = i.residence i.coresidence ) $demo $lifestyle $environ [aw = w_2014]
	
outreg2 using "${out}/2sls.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1,0.15) symbol(***,**,*,+) ///
title("2sls")	
restore

****************** fixed effect
xtset id followup 

xtreg  $key   [aw = w_2014] ,fe robust  //i.province i.followup 
outreg2 using "${out}/fixedeffect.xls",replace excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1,0.15) symbol(***,**,*,+) ///
title("fixed-effectbio")

xtreg  $key $demo $lifestyle  [aw = w_2014]  ,fe robust  //i.province i.followup 
outreg2 using "${out}/fixedeffect.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1,0.15) symbol(***,**,*,+) ///
title("fixed-effectbio")

xtreg  $key  $demo $lifestyle $sociaeconomic  [aw = w_2014] ,fe robust  //i.province i.followup 
outreg2 using "${out}/fixedeffect.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1,0.15) symbol(***,**,*,+)  ///
title("fixed-effectbio")


xtreg  $key  $demo $lifestyle $sociaeconomic $environ  [aw = w_2014] ,fe robust  //i.province i.followup 
outreg2 using "${out}/fixedeffect.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1,0.15) symbol(***,**,*,+)  ///
title("fixed-effectbio")


xtreg  $y $key  $demo  ,fe robust  //i.province i.followup 
outreg2 using "${out}/fixedeffectfracat.xls",replace excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1,0.15) symbol(***,**,*,+) ///
title("fixed-effectfra")

xtreg  $y $key $demo $lifestyle   ,fe robust  //i.province i.followup 
outreg2 using "${out}/fixedeffectfracat.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1,0.15) symbol(***,**,*,+) ///
title("fixed-effectfra")

xtreg  $y $key $demo $lifestyle $sociaeconomic $environ  ,fe robust  //i.province i.followup 
outreg2 using "${out}/fixedeffectfracat.xls",append excel stats(coef pval) dec(3) alpha(0.01,0.05,0.1,0.15) symbol(***,**,*,+)  ///
title("fixed-effectfra")



****************** DID model 
** Test hyp
	* merge data
	use "${out}/analyses_frail_M1111.dta",clear
		preserve
			use  "${int}/Panel_CLHLS08-14_covariants.dta"
			keep if inlist(wave,8,11)
			tempfile t1
			save `t1',replace
		restore
		append using `t1'
		
		bysort id : gen count1 = _N
		gen a = 1 if wave == 14
		bysort id : egen max = max(a)
		keep if max == 1
		
		codebook id  //3192
	
	* test lack data 
	drop if count1 == 2
	
	
	
	gen age
	twoway line av_dk1 av_dk0 year
		
	
	
	
	
