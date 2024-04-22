/*******Purpose: Covariants Generation
1. lifestyle: smoking, drinking, activity, dietary behaviors
2. leisure
3. daily activity 
4. disease
5. self reported health 
6. psychological health 
7. cognition: MMSE 
8. height & weight, bmi
9. demographic 
10. biomarker: blood pressure 
11. socia leconomic: household annual average per capital income
*/

*****************************************************************
*************** 1. Standardize the name of raw variables ********
*****************************************************************
foreach year in 08 11 14 {
use "${raw}/dat`year'_18F.dta",clear
	foreach k in  d71 d72 d73 d74 d75 d81 d82 d83 d84 d85 d86 d91 d92 d93 d94{
		clonevar `k'_c = `k'
	}
**********************Lifestyle******************
	* smoking
	ren	(d71_c d72_c d73_c d74_c d75_c) (r_smkl_pres r_smkl_past r_smkl_start r_smkl_quit r_smkl_freq)

	* drinking	
	ren (d81_c d82_c d83_c d84_c d85_c d86_c) (r_dril_pres r_dril_past r_dril_start r_dril_quit r_dril_type r_dril_freq)
		
	* pa
	ren (d91_c d92_c d93_c d94_c) (r_pa_pres r_pa_past r_pa_start r_pa_quit)

****************** Leisure *********************
	if inlist(wave,00){
		rename (d11a d11b d11c d11d d11e d11f d11g d11h) 	(housework fieldwork gardenwork reading pets majong tv socialactivity ) // religiousactivity
	}
	if inlist(wave,02){
		rename (d11a d11b d11c d11d d11e d11f d11g d11h) 	(housework fieldwork gardenwork reading pets majong tv socialactivity ) // socialactivity religiousactivity religiousactivity
	}
	if inlist(wave,05,08,11,14){
		rename (d11a d11b d11c d11d d11e d11f d11g d11h) 	(housework fieldwork gardenwork reading pets majong tv socialactivity ) // socialactivity
	}
	if inlist(wave,18){
		rename (d11a d11b1 d11c d11d d11e d11f d11g d11h) 	(housework fieldwork gardenwork reading pets majong tv socialactivity ) // socialactivity
	}	
*************** Blood Pressure Level **************
	if inlist(wave,00,02,05){
		recode g51 g52 (-1 888 999 = .), gen(SBP DBP)
	}
	if inlist(wave,08,11,14,18){
		recode g511 g512 g521 g522(-1 888 999 = .)
		foreach k in g511 g512 g521 g522{
			replace `k' = . if `k' >300
		}
		egen SBP = rowmean(g511 g512)
		egen DBP = rowmean(g521 g522)
		recode SBP DBP (0 = .)
	}	
save "${int}/dat`year'_18_renamed.dta",replace
}

*****************************************************************
*************** 2. Generate the variables **********************
*****************************************************************
foreach year in 08 11 14{ 
use "${int}/dat`year'_18_renamed.dta",clear
******************* Demographic Recode ***********
	* Education 
	recode edu (-1 88 99 = . ) (0 = 1 "none") (1/5 = 2 "Primary School") (6/87 = 3 "Middle school or higher"), gen(edug)
	
	* Occupation
//	recode occupation (3 = 1) //housework to manule
	
	* Marital
//	recode marital (3 = 2)  
//	label define marital 2 "separted, divorced, widowed or never married", modify
	
******************* Socialeconomic ***********
	* Annual household Income 
	if inlist(wave,02,05,08,11,14,18){
		recode f35 (99999 88888 = .),gen(hh_income) 
		foreach k in 9 99 999 9999 9998 99999 99998 999999 999998 999988 8 88 888 8888 88888 {
			count if f35!=.
			local N r(N)
			count if hh_income == `k'
			local n r(N)
			recode hh_income (`k' = .) if `n'/`N' >= 0.01  
		}
	}
	
	* Insurnace 
	if inlist(wave,11){
		ren (f64e1 f64f1 f64g1 f64h1 f6521) (f64e f64f f64g f64h f652)
	}
	if inlist(wave,14){
		ren f6521 f652
	}
	
	if inlist(wave,05,08,11,14){ // 18 need to be add
		recode f64i f64h f64g f64f f64e f64d f64c f64b f64a ( 9 = .)
		gen security_pension = 2 if (f64a == 1 | f64b== 1 )
		replace  security_pension = 3 if security_pension == 2 & f64c == 1
		replace  security_pension = 1 if !(f64a == 1 | f64b== 1 ) & f64c == 1		
		replace  security_pension = 0 if !(f64a == 1 | f64b== 1 ) & f64c != 1	 
		replace  security_pension = . if f64a == . & f64b== . & f64c ==.
		tab security_pension
		recode security_pension (3 2 = 1) (1=0)
		
		gen security_insurance = 2 if f64f==1 | f64e== 1
		replace security_insurance = 3   if (f64f==1 | f64e== 1) & (f64g==1 | f64e==1)
		replace security_insurance = 1   if !(f64f==1 | f64e== 1) & (f64g==1 | f64e==1)
		replace security_insurance = 0   if !(f64f==1 | f64e== 1) & f64g!=1 & f64e!=1
		replace  security_pension = . if f64f == . & f64e== . & f64g ==.
		tab  security_insurance 
		
		gen security_lifespan = 3 if f64h == 1
		replace security_lifespan =  0 if f64h == 0 
		
		gen security_other = 1 if f64i == 1 
		replace security_other = 1 if f64i == 0

		egen security = rowtotal(security_pension security_insurance security_lifespan security_other),mi
		
		recode security (1 2 3 = 1 ) (4/9 = 2),gen(security_cat)
	}

	* Health Expense 
	if inlist(wave,05,08,11,14,18){
		recode f652 (99 -1 = .) (8 = 0 "no secure") (5 6 = 1 "self/spouse") (7 9 = 2 "children/others") ( 1 2 3 4 = 3 "insurance/health services"),gen(hexp_cover) label(hexp_cover)		
		gen hexp_financeissue = 0 if f61 !=.
		replace hexp_financeissue = 1 if f610 == 1 
	}
	
	if inlist(wave,05,08){
		recode f651b f651a (99998 = 100000) (99999 88888 = .),gen(hexp_fampaid hexp_selfpaid )
	}
	if inlist(wave,11,14,18){
		recode f651b1 f651a1 f651b2 f651a2 (99998 = 100000) (99999 88888 = .)
		egen hexp_fampaid = rowtotal(f651b1 f651b2 ),mi
		egen hexp_selfpaid = rowtotal(f651a1 f651a2 ),mi
	}
	
	* 养老院
	gen nursing_living=1 if  a51 == 3
	replace nursing_living=0 if inlist(a51,1,2)
	
	recode a54a a54b (8888 9999 -1 88 99 = .)
	
	if inlist(wave,98){
		gen nurisng_year = year9899 - a54a 
		replace nurisng_year = nurisng_year - 1 if (a54b > month98 | (a54b == month98 & date98 <15 )) & a54b!=. & a54a !=.
	}
	if inlist(wave,00,02){
		gen nurisng_year = 20`year' - a54a
		replace nurisng_year = nurisng_year - 1 if (a54b > month`year' | (a54b == month`year'& day`year' <15))  & a54b!=. & a54a !=.
	}	
	if inlist(wave,05){
		gen nurisng_year = 2005 - a54a
		replace nurisng_year = nurisng_year - 1 if (a54b > monthin | ( a54b == monthin & dayin <15))  & a54b!=. & a54a !=.
	}	
	if inlist(wave,08,11,14,18){
		gen nurisng_year = yearin - a54a 
		replace nurisng_year = nurisng_year - 1 if (a54b > monthin | ( a54b == monthin & dayin <15))  & a54b!=. & a54a !=.
	}	
	replace nurisng_year  = . if nursing_living!=1 
	
	if inlist(wave,05,08,11,14,18){
		gen nursing_cost = a541 if a541>=0 & a541<8888
		recode a542 (1=0 "self") (3 4 = 1 "children") (5 6 = 2 "public/collection/others") (-1 8 9 = .) , gen(nursing_cover) label(nursing_cover) 
	}	
	* financial support
	foreach k in f32a f32b f32c f32d f32e{
		replace f31 = `k' if inlist(f31,.,8,9,99) & !inlist(`k',.,8,9,99)
	}
	recode f31 (1=1 "Retirement pension") (2/5 =2 "Family support") (6 = 3 "Social insurance") (7 = 4 "Working payment") (8=5 "others") (-1 99 9 = .),gen(incomesource)
	
********************** Lifestyle ******************
	* Smoking
	recode r_smkl_pres r_smkl_past  (-1 8 9 = .)
	recode r_smkl_freq (-1 88 99 = .)
	recode r_smkl_start r_smkl_quit (-1 888 999 = .)
	gen smkl = 1 if r_smkl_pres == 2 & r_smkl_past == 2
	replace smkl = 2 if !inlist(r_smkl_pres,1,.) & r_smkl_past == 1				// choose to code smk missing if r_smkl_pres is missing
	replace smkl = 3 if r_smkl_pres == 1 & (r_smkl_freq * 1.4) >= 0 & (r_smkl_freq * 1.4) < 20
	replace smkl = 4 if r_smkl_pres == 1 & (r_smkl_freq * 1.4) >= 20 & (r_smkl_freq * 1.4) <= 50
	label define smkl 1 "never" 2 "former" 3 "light current" 4 "heavy current"
	label value smkl smkl 

	gen smkl_year = r_smkl_quit - r_smkl_start
	
	* Drinking alchol
	if inlist(wave,18){
		replace r_dril_freq = "" if r_dril_freq > "999" 
		destring r_dril_freq,replace 
	}
	recode r_dril_freq (-1 88 99 = .)
	recode r_dril_pres r_dril_past r_dril_type (-1 8 9 = .)  
	gen alcohol = . 

	if inlist(wave,98){
		replace alcohol = r_dril_freq * 50 * 0.455 if r_dril_type == 1
		replace alcohol = r_dril_freq * 50 * 0.12 if r_dril_type == 2
		replace alcohol = r_dril_freq * 50 * 0.15 if r_dril_type == 3
	}
	if inlist(wave,00,02,05,08,11,14,18){
		replace alcohol = r_dril_freq * 50 * 0.53 if r_dril_type == 1
		replace alcohol = r_dril_freq * 50 * 0.38 if r_dril_type == 2
		replace alcohol = r_dril_freq * 50 * 0.12 if r_dril_type == 3
		replace alcohol = r_dril_freq * 50 * 0.15 if r_dril_type == 4
		replace alcohol = r_dril_freq * 50 * 0.04 if r_dril_type == 5
		replace alcohol = r_dril_freq * 50 * 0.244 if r_dril_type == 6
	}
	
	generate dril=.
	replace dril=1 if r_dril_pres==2 & r_dril_past==2
	replace dril=2 if !inlist(r_dril_pres,1) & r_dril_past==1  				// choose to code dril missing if r_dril_pres is missing
	replace dril=3 if gender==1 & r_dril_pres==1 & inrange(alcohol,0, 25)
	replace dril=3 if gender==0 & r_dril_pres==1 & inrange(alcohol,0, 15)
	replace dril=4 if gender==1 & r_dril_pres==1 & (alcohol > 25 & alcohol < . )  // & not |
	replace dril=4 if gender==0 & r_dril_pres==1 & (alcohol > 15 & alcohol < . )
	label define dril 1 "never" 2 "former" 3 "current & light" 4 "current & heavy"
	label value dril dril
	
	* Physical Activity
	recode r_pa_pres r_pa_past (-1 8 9 = .)
	recode r_pa_start (-1 888 999 = .)
	gen pa = 1 if r_pa_pres == 1 & r_pa_start < 50
	replace pa = 2 if r_pa_pres == 1 & r_pa_start >= 50 & r_pa_start < . // choose to code pa missing if r_pa_pres is missing
	replace pa = 3 if r_pa_pres != 1 & r_pa_past == 1 
	replace pa = 4 if r_pa_pres == 2 & r_pa_past == 2 
	label define pa 1 "current & start < 50" 2 "current & start >=50" 3 "former" 4 "never"
	label value pa pa 
/*	
	recode r_pa_pres (2 = 0) (9 = .),gen(pa_alt)
	label define pa_b 1 "regular PA" 0 "no regular PA"
	label value pa_alt pa_b
*/		
	
	*Dietary Behavior 
	if inlist(wave,98,00,02,05){	
		* dietary: 1 2 3
		recode d31 d32 (1 2 = 1 "everday or excepte winter") (3 = 2 "occasionally") (4 = 3 "rarely or never") (-1 8 9 = .),gen(fruit veg) label(dietfruit)
		recode d4bean2 d4egg2 d4fish2 d4garl2 d4meat2 d4suga2 d4tea2 d4veg2(1 = 1 "everyday") (2 = 2 "occasionally") (3 = 3 "rarely or never") (-1 8 9 = .),gen(bean egg fish garlic meat sugar tea saltveg) label(dietbean)
		
		* dietary1: 0 1 2
		recode d31 d32 (1 2 = 2 "everday or excepte winter") (3 = 1 "occasionally") (4 = 0 "rarely or never") (-1 8 9 = .),gen(fruit1 veg1) label(dietfruit1)
		recode d4bean2 d4egg2 d4fish2 d4garl2 d4meat2 d4suga2 d4tea2 d4veg2(1 = 2 "everyday") (2 = 1 "occasionally") (3 = 0 "rarely or never") (-1 8 9 = .),gen(bean1 egg1 fish1 garlic1 meat1 sugar1 tea1 saltveg1) label(dietbean1)

	}
	if inlist(wave,08,11,14,18){	
		* dietary: 1 2 3	
		recode d31 d32 (1 2 = 1 "everday or excepte winter") (3 = 2 "occasionally") (4 = 3 "rarely or never") (-1 8 9 = .),gen(fruit veg) label(dietfruit)
		recode d4bean2 d4egg2 d4fish2 d4garl2 d4meat2 d4suga2 d4tea2 d4veg2(1 = 1 "everyday") (2 3 4= 2 "occasionally") (5 = 3 "rarely or never") (-1 8 9 = .),gen(bean egg fish garlic meat sugar tea saltveg) label(dietbean)
		
		* dietary1: 0 1 2
		recode d31 d32 (1 2 = 2 "everday or excepte winter") (3 = 1 "occasionally") (4 = 0 "rarely or never") (-1 8 9 = .),gen(fruit1 veg1) label(dietfruit1)
		recode d4bean2 d4egg2 d4fish2 d4garl2 d4meat2 d4suga2 d4tea2 d4veg2(1 = 2 "everyday") (2 3 4= 1 "occasionally") (5 = 0 "rarely or never") (-1 8 9 = .),gen(bean1 egg1 fish1 garlic1 meat1 sugar1 tea1 saltveg1) label(dietbean1)
		
	}
	
	egen diet_miss = rowmiss(fruit1 veg1 bean1 egg1 fish1 garlic1 meat1 sugar1 tea1 saltveg1)
	egen diet = rowtotal(fruit1 veg1 bean1 egg1 fish1 garlic1 meat1 sugar1 tea1 saltveg1)
	
	replace diet = . if diet_miss > 2 


********* ADL: activity of daily living *********
	recode e1 e2 e3 e4 e5 e6  (1 = 0 "do not need help") (2 3 = 1 "need help") (-1 8 9 = .),gen(bathing dressing toileting transferring continence feeding) label(adl_row)
	
	egen adl_miss= rowmiss(bathing dressing toileting transferring continence feeding)
	egen adl_sum = rowtotal(bathing dressing toileting transferring continence feeding) 
	
	replace adl_sum = . if adl_miss > 1 
	
	gen adl = (adl_sum > 0) if adl_sum != .
	label define adl 0"0:without ADL" 1"1:with ADL"
	label value adl adl

********************** drinking water ******************
	if inlist(wave,00,02,05,08,11,14,18){
			recode d6c (5=1 "tap water") (2/4 = 2 "natural water") (1 = 3 "well water") (-9/-1 8 9 = .) ,gen(waterqual)  
	}	
	
********************** Leisure ******************
	cap gen fieldwork = 0
	//cap gen religiousactivity = 0
	cap gen socialactivity = 0 
	if inlist(wave,98,00){
		recode housework fieldwork gardenwork reading pets majong tv socialactivity (3 = 1) (2 = 2) (1 = 3) (-1 8 9 = .) // outdoor  religiousactivity 
	}

	if inlist(wave,02,05,08,11,14,18){
		recode housework fieldwork gardenwork reading pets majong tv socialactivity (5 = 1) (2 3 4 = 2) (1 = 3) (-1 8 9 = .) //  outdoor 
	}
	
	label define leisure 1 "never" 2 "sometimes" 3 "almost everyday"
	label values housework fieldwork gardenwork reading pets majong tv socialactivity leisure 

	egen leisure_miss 	= rowmiss(housework fieldwork gardenwork reading pets majong tv socialactivity)
	egen leisure 		= rowtotal(housework fieldwork gardenwork reading pets majong tv socialactivity) 
	
	replace leisure = . if leisure_miss > 2 
/*	
******** Self-reported Disease History **********
	if inlist(wave,98){
		foreach k in a b c d e f g h i j k l m {
			gen disease_`k' = 0 if g17`k'1==1
			replace disease_`k' = 1  if g17`k'1==1 & g17`k'2==1
			replace disease_`k' = 2  if g17`k'1==1 & g17`k'2 != 1			// here Yaxi did deduction for missing value "8" "9"
			replace disease_`k' = 3  if g17`k'1==2 
			//replace disease_`k' = . if inlist(g17`k'1,8,9)
		}
		
		ren disease_a hypertension
		ren disease_b diabetes
		ren disease_c heartdisea
		ren disease_d strokecvd
		ren disease_e copd
		ren disease_f tb
		ren disease_g cataract
		ren disease_h glaucoma
		ren disease_i cancer
		ren disease_j prostatetumor
		ren disease_k ulcer
		ren disease_l parkinson
		ren disease_m bedsore

		gen arthritis = . 
	}
	
		label define disease 1"yes, cause disability" 2"yes,but no disability" 3"no"
	
	if inlist(wave,00,02,05,08,11,14,18){
		foreach k in a b c d e f g h i j k l m n {
			gen disease_`k' = 0 if g15`k'1==1
			replace disease_`k' = 1  if g15`k'1==1 & g15`k'3 == 1
			replace disease_`k' = 2  if g15`k'1==1 & g15`k'3 != 1	// here Yaxi did deduction for missing value "8" "9"
			replace disease_`k' = 3  if g15`k'1==2 
			//replace disease_`k' = . if inlist(g15`k'3,8,9)
			label value  disease_`k' disease
		}

		ren disease_a hypertension
		ren disease_b diabetes
		ren disease_c heartdisea
		ren disease_d strokecvd
		ren disease_e copd
		ren disease_f tb
		ren disease_g cataract
		ren disease_h glaucoma
		ren disease_i cancer
		ren disease_j prostatetumor
		ren disease_k ulcer
		ren disease_l parkinson
		ren disease_m bedsore
		ren disease_n arthritis
		//ren disease_o dementia
		
	}

	egen disease_sum  = rowtotal(hypertension diabetes heartdisea strokecvd copd tb cataract glaucoma cancer prostatetumor ulcer parkinson bedsore arthritis),mi
	
	gen disease = 3 if disease_sum == 42
	foreach k in hypertension diabetes heartdisea strokecvd copd tb cataract glaucoma cancer prostatetumor ulcer parkinson bedsore arthritis {
		replace disease = 1 if  `k' == 1
	}
	
	replace disease = 2 if disease == .
	replace disease = . if disease_sum == .
*/	
*************** Self-reported Health **************
	recode b12 (8 9 = . ) (5=4),gen(srhealth)
	label define srhealth 1 "Very good" 2 "good" 3 "fair" 4"Bad/Very bad"
	label value srhealth srhealth
	
*************** Blood Pressure Level **************
	gen bpl = 1 	if (SBP>0 & SBP<90) 	& (DBP>0 & DBP<60)
	replace bpl = 2 if (SBP>=90 & SBP<=120) & (DBP>=60 & DBP<=80)	
	replace bpl = 3 if (SBP>120 & SBP<140) 	& (DBP>80 & DBP<90)
	replace bpl = 4 if (SBP>=140 & SBP<160) | (DBP>=90 & DBP<100)
	replace bpl = 5 if (SBP>=160 & SBP<.) 	| (DBP>=100 & DBP<.)
	label variable bpl "Hypertension condition"
	label define bpl 1 "hypotension" 2 "Normal" 3 "Prehypertension" 4 "Stage I Hypertesnion" 5 "Stage II Hypertension" 
	label value bpl bpl

*************** Height, weight, BMI **************
	if inlist(wave,98){
		recode g12 g81 g82 (-1 888 999 = .), gen(weight armlength kneelength)
	}
	if inlist(wave,00){
		recode g10 (-1 888 999 = .), gen(weight) label(weight)
	}	
	if inlist(wave,02){
		recode g101 g102a g102b (-1 88 888 99 999 = .), gen(weight armlength kneelength) // note: code g101 = 99 to . b/c the frequenct of 88 & 99 is abnormal for this variables
	}
	if inlist(wave,05){
		recode g101 g102 (-1 999 = .), gen(weight youngheight) 
	}
	if inlist(wave,08,11,14,18){
		recode g101 g1021 (-1 888 999 = .), gen(weight meaheight) 
		recode g122 g123 (-1 88 99 888 999 = .), gen(armlength kneelength)  // note: code (g122 g123 = 88 99) to . b/c the frequenct of 88 & 99 is abnormal for this variables
		gen height = round(meaheight/100, .01)
	}		
	
	* hunchbacked
	if inlist(wave,11,14,18){
		recode g102 (2=0) (9 8 -1 =.) ,gen(hunchbacked) 
	}		
	
		* Data cleaning for SW: HeartRate*BMI
		//replace weight = . if !inrange(weight,35,90) & gender == 1 
		//replace weight = . if !inrange(weight,25,80) & gender == 0 

	capture confirm variable height
	if _rc == 0 {
			* Data cleaning for SW: HeartRate*BMI
			//replace height = . if !inrange(height,1.35,1.86) & gender == 1 
			//replace height = . if !inrange(height,1.20,1.78) & gender == 0

		* BMI 
		gen bmi=weight/(height*height) 
		replace bmi=. if bmi < 12 | bmi >= 40
		
			* Data cleaning for SW: HeartRate*BMI
			//replace height = . if !inrange(bmi,10,60)
	
		gen bmi_cat=.
		replace bmi_cat=1 if bmi<18.5
		replace bmi_cat=2 if bmi>=18.5 & bmi<24
		replace bmi_cat=3 if bmi>=24 & bmi<.
		label define bmi 1"underweight" 2"normal" 3"overweight"
		label value bmi_cat bmi
	}	

*************** Biomarker **************
	* Heart Rate & rhythm
	if !inlist(wave,08,18){
		recode g7 (-1 888 999 = . ),gen(fra_hr)
		foreach k in fra_hr {
			sum `k' 
			replace `k' = . if !inrange(`k',r(mean)-3*r(sd),r(mean)+3*r(sd)) 
		}		
		recode g6 (1 = 0 "irregular") (2 = 1 "regular") (-1 8 9 = .),gen(hr_irr) label(rhythm)
	}
	if inlist(wave,08){
		recode g71 g72 (-9/-1 888 999 = . )
		egen fra_hr = rowmean(g71 g72)
	}	
	if inlist(wave,18){
		recode g7 (-1 888 999 = . ),gen(fra_hr)
	}	

********************** Psychology ******************
	if !inlist(wave,18){	
		recode b21 b22 b25 b27 (1 = 5 ) (2 = 4 ) (4 = 2) (5 = 1) (-1 8 9 = . ), gen(psy1 psy2 psy5 psy7)  //positive 
		recode b23 b24 b26 (-1 8 9 = .), gen(psy3 psy4 psy6) // negative 
	}
	if inlist(wave,18){	
		recode b21 b22 b23 (1 = 5 ) (2 = 4 ) (4 = 2) (5 = 1) (-1 8 9 = . ), gen(psy1 psy2 psy5 )  //positive 
		recode b24 b25 b27 (-1 8 9 = .), gen(psy3 psy4 psy6) // negative 
		gen psy7 = .
	}	
	egen psycho = rowtotal(psy1 psy2 psy3 psy4 psy5 psy6 psy7)
	egen psy_miss = rowmiss(psy1 psy2 psy3 psy4 psy5 psy6 psy7)
	
	replace psycho = . if psy_miss > 2 
	
	if inlist(wave,18){	
		replace psycho = .
		replace psy_miss = .
	}		

******************CI & MMSE ******************
*****cognition
	*orientation section
	recode c11 c12 c13 c14 c15 (0 8 = 0 "unable to answer or wrong") (1 = 1 "correct") (-1 9 = .), gen(time_orientation1 time_orientation2 time_orientation3 time_orientation4 place_orientation) label(ciorientation)

	*naming foods
	recode c16 (88 = 0 "unable to answer") (-1 99 = .), gen(namefo) label(cinamefo)
	replace namefo=7 if namefo>=7 & namefo<. 									
	
	*registration
	recode c21a c21b c21c (8 = 0 "wrong or unable to answer") (1 = 1 "correct") (-1 9 2 = .),gen(registration1 registration2 registration3) label(ciregistration)

	*attention and calculation--attempts to repeat the names of three objects correctly
	recode c31a c31b c31c c31d c31e (8 = 0 "wrong or unable to answer") (1 = 1 "correct") (-1 9 = .),gen(calculation1 calculation2 calculation3 calculation4 calculation5) label(ciattention)

	*recall
	recode c41a c41b c41c (8 = 0 "wrong or unable to answer") (1 = 1 "correct")  (-1 9 = .), gen(delayed_recall1 delayed_recall2 delayed_recall3) label(cirecall)

	*language
	recode c51a c51b c52 c53a c53b c53c(8 = 0) (-1 9 = .), gen(naming_objects1 naming_objects2 repeating_sentence listening_obeying1 listening_obeying2 listening_obeying3) label(cilanguage)
	
	*copy a figure
	recode c32 (8 = 0 "wrong or unable to answer") (1 = 1 "correct") (-1 9 = .),gen(copyf) label(cifigure)
	 
	*CI missing
	egen ci_missing = rowmiss(time_orientation1 time_orientation2 time_orientation3 time_orientation4 place_orientation namefo registration1 registration2 registration3 calculation1 calculation2 calculation3 calculation4 calculation5 copyf delayed_recall1 delayed_recall2 delayed_recall3 naming_objects1 naming_objects2 repeating_sentence listening_obeying1 listening_obeying2 listening_obeying3)
	egen ci = rowtotal(time_orientation1 time_orientation2 time_orientation3 time_orientation4 place_orientation namefo registration1 registration2 registration3 calculation1 calculation2 calculation3 calculation4 calculation5 copyf delayed_recall1 delayed_recall2 delayed_recall3 naming_objects1 naming_objects2 repeating_sentence listening_obeying1 listening_obeying2 listening_obeying3)
	
	replace ci = . if ci_missing > 3  

	egen time_orientation	= rowtotal(time_orientation1 time_orientation2 time_orientation3 time_orientation4)
	egen orientation		= rowtotal(time_orientation  place_orientation)
	egen registration		= rowtotal(registration1  registration2  registration3)
	egen calculation		= rowtotal(calculation1  calculation2  calculation3  calculation4  calculation5)
	egen delayed_recall		= rowtotal(delayed_recall1  delayed_recall2  delayed_recall3)
	egen naming_objects		= rowtotal(naming_objects1  naming_objects2)
	egen listening_obeying	= rowtotal(listening_obeying1  listening_obeying2  listening_obeying3)
	egen Language			= rowtotal(naming_objects  repeating_sentence  listening_obeying)
	
	gen orientation_full 	= (orientation == 5)
	gen namefo_full 		= (namefo == 7)
	gen registration_full 	= (registration == 3)
	gen calculation_full 	= (calculation == 5)
	gen copyf_full 			= (copyf == 1)
	gen delayed_recall_full = (delayed_recall == 3)
	gen Language_full		= (Language == 6)

	* MMSE
	egen mmse =	rowtotal(orientation namefo registration calculation copyf delayed_recall Language),mi 
	egen mmsemiss =	rowmiss(orientation namefo registration calculation copyf delayed_recall Language)
	
	replace mmse = . if ci_missing > 3  
	
	gen ci_cat=.
	replace ci_cat=3 if mmse>=0 & mmse<=9
	replace ci_cat=2 if mmse>=10 & mmse<=17
	replace ci_cat=1 if mmse>=18 & mmse<=24
	replace ci_cat=0 if mmse>=25 & mmse<=30
	
	gen ci_bi=.
	replace ci_bi=0 if mmse>25
	replace ci_bi=1 if mmse<=25

	label define y 0"0:No CI"1"1:Mild CI"2"2:Moderate CI"3"3:Severe CI"
	label define u 0"0:No CI"1"1:CI BY 25MMSE"
	label value ci_cat y
	label value ci_bi u
/*
********************** Disablility ******************
	if inlist(wave,98){
		recode g17*2 (9 8 = .) (1 = 2 ) (2 = 1) (-1 3 = 0)
		replace g17*2 = 0 if 
		label define disability 2 "rather serious" 1"more or less" 0 "no"
		label values g17*2 disability
		egen disability = rowtotal(g17*2),mi
		egen disability_miss = rowmiss(g17*2)
		
		//replace disability = . if  disability_miss 
	}
	if inlist(wave,0,2,5,8,11,14){
		recode g15*3 (9 8 = .) (1 = 2 ) (2 = 1) (-1 3 = 0)
		label define disability 2 "rather serious" 1"more or less" 0 "no"
		label values g15*3 disability
		egen disability = rowtotal(g15*3),mi
		egen disability_miss = rowmiss(g15*3)
		
		//replace disability = . if  disability_miss 
	}
*/
	* hearing lost
	if inlist(wave,11,14,18){
		recode  g106 g1061 g1062 g1063(8 9 = .)
		gen hearingloss = 1 if g106 == 1 
		replace hearingloss = 2 if g106 == 1  & g1061 ==3 
		replace hearingloss = 0 if g106 == 2 
	}	
******************* Realiability of the answers  *****************************
	*able to participate physical check?
	recode h21 (1 3 = 1 "able/patrically able") (2= 0 "no") (8 9 = .),gen(ablephy) label(ablephy)
	
	* reason
	recode h22 (-1 9 = .),gen(ablephyreas) label(ablephyreas)
	
	
******************* children and fertility  **************
	* number of children ever born
	if inlist(wave,98,0,2,5,8,14,18){
		recode f10 (-1 88 99 =.),gen(numchild)
	}
	
	* age of birth
	if inlist(wave,0,2,5,8,14,18){
		recode f101 f102 (-1 88 99 = .),gen(agefirstbirth agelastbirth)
	}
	
	* year of birth 
	if inlist(wave,0,2,5,8,14,18){
		gen yearfirstbirth = year(interview_baseline)-(trueage - agefirstbirth) if agefirstbirth !=.  
		gen yearlastbirth = year(interview_baseline)-(trueage - agelastbirth) if agelastbirth!=.  
		replace yearfirstbirth = . if agefirstbirth > agelastbirth & agefirstbirth!=.
		replace yearlastbirth = . if agefirstbirth > agelastbirth & agefirstbirth!=. 
		gen yeargapbirth = yearlastbirth - yearfirstbirth	

		gen yearavebirth = round(yeargapbirth / numchild)
	}

	*by gender 
	if inlist(wave,11){
		recode f1030 ( 8 9 -1 = .),gen(sonnumalive)
		recode f1031 ( 8 9 -1 = .),gen(dautnumalive)
	}
	
	*child visit
	if inlist(wave,11){
		gen childvisit = 1 if f1032==1 |f1033 ==1 
		replace childvisit = 0 if inlist(f1032,0,3) & inlist(f1033,0,3)
	}	
	
******************* Frailty  **************
	* Self-reported Health Ordinal 
	recode b12 (1 2 3 = 0) (4 5 = 1) (-9/-1 8 9 = . ) ,gen(fra_srh) // 4"Bad" 5 "Very bad"
	
	* health change
	recode b121 (1 2 3 = 0) (4 5 = 1) (-9/-1 8 9 = . ) ,gen(fra_hworse) 
	
	
    * ADL: activity of daily living  Ordinal 
	recode e1 e2 e3 e4 e5 e6  (1 2= 0 ) (3 = 1 ) (-9/-1 8 9 = .),gen(fra_bathing fra_dressing fra_toileting fra_transferring fra_continence fra_feeding)  // 2:one part assistance 3: more than one part assistance
	
	*IADL:
	recode e7 e8  e9 e10 e11 e12 e13 e14 (1 2 = 0 ) (3 = 1 ) (-9/-1 8 9 = .),gen(fra_visit fra_shopping fra_cook fra_washcloth fra_walk1km fra_lift fra_standup fra_publictrans) 
	
	* Visual function Ordinal  
	if inlist(wave,98,02,05,08,11,14,18){
	recode g1 (1 2 = 0)  (3 4 = 1) (-9/-1 8 9 = .),gen(fra_visual) // 3:  can't see 4: blind ??2  can see but can't distinguish the break in the circle 
	}

	* Functional: 
		*Hand behind neck & Hand behind lower back Ordinal & raise hands
		if inlist(wave,98){
			recode g101 g102 (4 = 1) (1 2 3 = 0) (-9/-1 8 9 = .),gen(fra_neck fra_lowerback) // 1  right hand, 	2  left hand, 4  neither hand
		}	
		if !inlist(wave,98){
			recode g81 g82 g83 (4 = 1) (1 2 3 = 0) (-9/-1 8 9 = .),gen(fra_neck fra_lowerback fra_raisehands) // 1  right hand, 	2  left hand, 4  neither hand
		}		
		
		* Able to stand up from sitting, Able to pick up a book from the floor
		if inlist(wave,98){
			recode g11 g13 (1 2= 0) (3 = 1) (-9/-1 8 9 = .),gen(fra_stand fra_book ) // 2  yes, using hands, 3  no ??? 2  yes, using hands //2  yes, sitting, 3  no ??? 2  yes, sitting
		}	
		if !inlist(wave,98){
			recode g9 g11 (1 2= 0) (3 = 1) (-9/-1 8 9 = .),gen(fra_stand fra_book ) // 2  yes, using hands, 3  no ??? 2  yes, using hands //2  yes, sitting, 3  no ??? 2  yes, sitting
		}		
		
	* Number of times suffering from serious illness in the past two years	Ordinal 
	if inlist(wave,98){
		recode g16 (0=0) (1  = 1) (2/88 = 2) (-9/-1 99  = . ),gen(fra_seriousillness)	
	}	
	if inlist(wave,00,02,05){
		recode g13 (0=0) (1 = 1) (2/88 = 2) (-9/-1 99  = . ),gen(fra_seriousillness)		
	}		
	if inlist(wave,08,11,14,18){
		recode g131 (0=0) (1 = 1) (2/88 = 2) (-9/-1 99  = . ),gen(fra_seriousillness)		
	}		
	
	* Self-reported Health Ordinal 
	gen fra_ci = 1 if mmse <=25 & mmse !=.
	replace fra_ci = 0 if mmse >25
	replace fra_ci = . if mmse ==.

******** Self-reported Disease History **********
//Hypertension,Diabetes,Heart disease,Stroke or CVD,COPD,Tuberculosis,Cancer,Gastric or duodenal ulcer,Parkinsons,Bedsore,Cataract,Glaucoma,Other chronic disease	Categorical ?????????, Prostate Tumor cancer
	if inlist(wave,98){
		foreach k in a b c d e f g h i j k l m {
			gen disease_`k' = 1 if g17`k'1==1
			replace disease_`k' = 0  if g17`k'1==2 
		}
		
		ren disease_a fra_hypertension
		ren disease_b fra_diabetes
		ren disease_c fra_htdisea
		ren disease_d fra_strokecvd
		ren disease_e fra_copd
		ren disease_f fra_tb
		ren disease_g fra_cataract
		ren disease_h fra_glaucoma
		ren disease_i fra_cancer
		ren disease_j fra_prostatetumor
		ren disease_k fra_ulcer
		ren disease_l fra_parkinson
		ren disease_m fra_bedsore
		recode g17n1 (-9/-1 3 88 99 = .) (2 = 0) (1 4/20 = 1) ,gen(fra_otherchronic)	
	}
		
	if inlist(wave,08,11,14){
		foreach k in a b c d e f g h i j k l m n q s{
			gen disease_`k' = 1 if g15`k'1==1
			replace disease_`k' = 0  if g15`k'1==2 
		}
	}	
	if inlist(wave,11,14){
		foreach k in n {
			gen disease_`k'a = 1 if g15`k'1a==1
			replace disease_`k'a = 0  if g15`k'1a==2 
		}	
	}

		ren disease_a fra_hypertension
		ren disease_b fra_diabetes
		ren disease_c fra_htdisea
		ren disease_d fra_strokecvd
		ren disease_e fra_copd
		ren disease_f fra_tb
		ren disease_g fra_cataract
		ren disease_h fra_glaucoma
		ren disease_i fra_cancer
		ren disease_j fra_prostatetumor
		ren disease_k fra_ulcer
		ren disease_l fra_parkinson
		ren disease_m fra_bedsore
		ren disease_q fra_cholecystitis
		ren disease_s fra_chronephritis

	if inlist(wave,11,14){
		foreach k in n {
			gen fra_rheumatism = 1 if disease_n==1 | disease_na==1
			replace fra_rheumatism = 0 if disease_n==0 & disease_na==0	
		}	
	}			
	replace fra_hypertension = 1 if (SBP>=140 & SBP!=.) | (DBP>=90 & DBP!=.)
	
	
	* sleep
	if inlist(wave,08,11,14){	
		recode g01 (1 2 3 = 0)  (4 5  = 1 ) (-9/-1 8 9 = .),gen(fra_sleep) // 4: bad 5: very bad
	}		
		
	* Able to hear
	if inlist(wave,98){	
		recode h1a (1 2 =0) (3 4 = 1)  (-9/-1 8 9 = .),gen(fra_hear) //  2: yes, but needs hearing aid, 3: partly, despite hearing aid, 4: no ???? 
	}
	if inlist(wave,08,11,14,18){	
		recode h1 (1 2=0) (3 4 = 1)  (-9/-1 8 9 = .),gen(fra_hear) //  2: yes, but needs hearing aid, 3: partly, despite hearing aid, 4: no ????
	}	
	* Interviewer rated health	
	recode h3 (1 2= 0) (3 4 = 1) (-9/-1 8 9= .),gen(fra_irh)
	
	* psychol
 	/*Look on the bright side of things 
 	Keep my belongings neat and clean	 
 	Make own decisions	 
 	Feel fearful or anxious	 
 	Feel useless with age	*/ 
	if !inlist(wave,18){	
		recode b21 b22 b25  (1 2 3=0) (4 5 = 1) (-9/-1 8 9 = . ), gen(fra_psy1 fra_psy2 fra_psy5 )  //positive  1  always,2  often,3  sometimes,4  seldom,5  never
		recode b23 b24 b26 (1 2 =1)  (5 3 4 = 0) (-9/-1 8 9 = . ), gen(fra_psy3 fra_psy4 fra_psy6) // negative 1  always,2  often,3  sometimes,4  seldom,5  never
	}
	if inlist(wave,18){	
		recode b21 b22 b23 (1 = 5 ) (2 = 4 ) (4 = 2) (5 = 1) (-9/-1 8 9 = . ), gen(fra_psy1 fra_psy2 fra_psy5 )  //positive 
		recode b34 b36 b38 (1 2 =1)  (5 3 4 = 0) (-9/-1 8 9 = . ), gen(fra_psy3 fra_psy4 fra_psy6) // negative 
	}	

	* Housework at present	
	recode  housework (2 3 =0) (1=1) (-9/-1 8 9 = . ),gen(fra_housework) // 3: never
	
	* Able to use chopsticks to eat
	recode g3 (2=0) (-9/-1 8 9 = . ),gen(fra_chopsticks) 
	
	* Number of steps used to turn around a 360 degree turn without help
	if inlist(wave,98){	
		recode g14 (20/88 = 1) (10/19 = 0.5) (5/9 = 0.25) (1/4 = 0) (-9/-1 0 89/888 = .) ,gen(fra_turn)
	}		
	if inlist(wave,08,11,14){	
		recode g12 (20/88 = 1) (10/19 = 0.5) (5/9 = 0.25) (1/4 = 0) (-9/-1 0 89/888 = .) ,gen(fra_turn)
	}	
	
	* physical 
	* BMI
	if inlist(wave,08,11,14){	
		foreach k in height weight {
			sum `k' if gender == 0
			replace `k' = . if !inrange(`k',r(mean)-3*r(sd),r(mean)+3*r(sd) ) & gender == 0
			sum `k' if gender == 1
			replace `k' = . if !inrange(`k',r(mean)-3*r(sd),r(mean)+3*r(sd) ) & gender == 1
		}
		gen fra_bmi= 1 if weight/(height*height)<18.5 | weight/(height*height)>=28
		replace fra_bmi= 0.5 if weight/(height*height)<28 & weight/(height*height)>=24
		replace fra_bmi= 0 if weight/(height*height)<24 & weight/(height*height)>=18.5
		replace fra_bmi= . if weight/(height*height)==.
		
	}	

* fule
	if inlist(wave,11,14){	
		recode a537 (6 8= 1 "biomass") (1 2 3 7 =2 "clean fuels") (0=3 "never cooked in the home") (4 5 9=4 "others"),gen(biomass) label("biomass")
	}	

* date
	ren monthin intmonth_0
	ren yearin intyear_0
* fix dth
	if !inlist(wave,18){
		recode dth18 (.=-8)
	}
	if !inlist(wave,14,18){
		recode dth14 (.=-8)
	}		
	if !inlist(wave,11,14,18){
		recode dth11 (.=-8)
	}		
save "${int}/Full_dat`year'_18_covariances.dta",replace   

	if inlist(wave,00,02,05,14){
		keep if id_year == wave
	}
	if inlist(wave,08){
		keep if id_year==8|id_year==9
	}	
	if inlist(wave,11){
		keep if id_year==11|id_year==12	
	}

save "${int}/Base_dat`year'_18_covariances.dta",replace
}

