*****************************************************************
*************** 1. Data Cleaning ********
*****************************************************************
**********************Recode for weight change only: won't harm the common generation process***********
foreach year in 08  11 14  { //
use "${int}/Full_dat`year'_18_covariances.dta",clear	
	* first wave
	gen a = .
	replace a = 0 if `year' == 98
	replace a = 2 if `year' == 00
	replace a = 5 if `year' == 02
	replace a = 8 if `year' == 05
	replace a = 11 if `year' == 08
	replace a = 14 if `year' == 11
	replace a = 18 if `year' == 14
	
	local i1 = a
	
	* second wave
	gen b = .
	replace b = 2 if `year' == 98
	replace b = 5 if `year' == 00
	replace b = 8 if `year' == 02
	replace b = 11 if `year' == 05
	replace b = 14 if `year' == 08
	replace b = 18 if `year' == 11

	local i2 = b

	* Third wave
	gen c = .
	replace c = 5 if `year' == 98
	replace c = 8 if `year' == 00
	replace c = 11 if `year' == 02
	replace c = 14 if `year' == 05
	replace c = 18 if `year' == 08
	
	local i3 = c
	
	* Forth wave
	gen d = .
	replace d = 8 if `year' == 98
	replace d = 11 if `year' == 00
	replace d = 14 if `year' == 02
	replace d = 18 if `year' == 05

	local i4 = d

	* Fifth wave
	gen e = .
	replace e = 11 if `year' == 98
	replace e = 14 if `year' == 00
	replace e = 18 if `year' == 02

	local i5 = e
	
	* Sixth wave
	gen f = .
	replace f = 14 if `year' == 98
	replace f = 18 if `year' == 00

	local i6 = f
	
	* Seventh wave
	gen g = .
	replace g = 18 if `year' == 98

	local i7 = g	
	
	
	*setup for loop
	gen wave_alt =7 if wave ==98
	replace wave_alt =6 if wave ==0
	replace wave_alt =5 if wave ==2
	replace wave_alt =4 if wave ==5
	replace wave_alt =3 if wave ==8
	replace wave_alt =2 if wave ==11
	replace wave_alt =1 if wave ==14

**********************Drop Death and lost to follow-up***********
/*
	if inlist(wave,98){
		drop if dth0 == 1 | dth0==-9 | month_0==-9  // we would like to drop the death in the follow-up and lost to follow-up, 4261 deleted for 98 enrollment
	}
	if inlist(wave,0){
		drop if inlist(dth2,1,-9) //drop if death in follow-up (2695 deleted)
	}
	if inlist(wave,2){
		drop if inlist(dth5,1,-9) //drop if death in follow-up (4203 deleted)
	}
	if inlist(wave,5){
		drop if inlist(dth8,1,-9) //drop if death in follow-up (4178 deleted)
	}
	if inlist(wave,8){
		drop if inlist(dth11,1,-9) // 5255  deleted for 11 enrollment
	}
	if inlist(wave,11){
		drop if dth14 ==  1 | dth14 == -9 // 519  deleted for 11 enrollment
	}
	if inlist(wave,14){
		drop if dth18 ==  1 | dth18 == -9  // 568  deleted for 11 enrollment 
	}
*/
********************** demographic ******************
	* coresidence
	if inlist(wave_alt,1,2,3,4,5,6,7){
		local am = wave_alt
		forvalues z = 1/`am'{
			generate coresidence_f`z'=a51_`i`z''  if !inlist(a51_`i`z'',8,9,.,-1,-9,-8,-7,-6)
			label value coresidence_f`z' coresidence_lb
		}		
	}	

	* marital
	if inlist(wave_alt,1,2,3,4,5,6,7){
		local am = wave_alt
		forvalues z = 1/`am'{
			recode f41_`i`z'' (1=1) (2 3 5=2) (4=3),gen(marital_f`z')
			label value marital_f`z' marital_lb
		}		
	}	

**********************self-rated health******************
	if inlist(wave_alt,1,2,3,4,5,6,7){
		local am = wave_alt
		forvalues z = 1/`am'{
			generate srhealth_f`z'=b12_`i`z'' 
			replace srhealth_f`z'=. if inlist(srhealth_f`z',8,9) | srhealth_f`z' < 0
			recode srhealth_f`z' (5=4)
			label define srhealth_f`z' 1 "Very good" 2 "good" 3 "fair" 4"Bad/Very bad"
			label value srhealth_f`z' srhealth_f`z'
		}		
	}	
	
********************** drinking water ******************
	if inlist(wave_alt,1,2,3){
		local am = wave_alt
		forvalues z = 1/`am'{
			recode d6c_`i`z'' (5=1 "tap water") (2/4 = 2 "natural water") (1 = 3 "well water") (-9/-1 8 9 = .) ,gen(waterqual_f`z') 
		}		
	}	
	
**********************social economics******************
	* financial support
	if inlist(wave_alt,1,2,3){
		local am = wave_alt
		forvalues z = 1/`am'{
			foreach k in f32a_`i`z'' f32b_`i`z'' f32c_`i`z'' f32d_`i`z'' f32e_`i`z''{
				replace f31_`i`z'' = `k' if inlist(f31,.,8,9,99) & !inlist(`k',.,8,9,99)
			}
			recode f31_`i`z'' (1=1 "Retirement pension") (2/5 =2 "Family support") (6 = 3 "Social insurance") (7 = 4 "Working payment") (8=5 "others") (-1 99 9 = .),gen(incomesource_f`z')
		}		
	}		

	*smoking
	if inlist(wave_alt,1,2,3,4,5,6,7){
		local am = wave_alt
		forvalues z = 1/`am'{
			replace d71_`i`z'' = . if d71_`i`z'' < 0
			replace d75_`i`z'' = . if d75_`i`z'' < 0
						
			generate smkl_f`z'=.
			replace smkl_f`z' = 1 if d71_`i`z'' == 2
			replace smkl_f`z' = 2 if d71_`i`z'' == 2
			replace smkl_f`z' = 3 if d71_`i`z'' == 1 & d75_`i`z'' < 20
			replace smkl_f`z' = 4 if d71_`i`z'' == 1 & d75_`i`z'' >=20 & d75_`i`z'' <88
			label define smkl_f`z' 1 "never" 2 "former" 3 "light current" 4 "heavy current"
			label value smkl_f`z' smkl_f`z'						
		}		
	}
	*Drinking
	replace d86_18 = "" if d86_18>"99"
	destring d86_18,replace

	if inlist(wave_alt,1,2,3,4,5,6,7){
		local am = wave_alt
		forvalues z = 1/`am'{
			replace d86_`i`z'' = . if d86_`i`z'' < 0 | inlist(d86_`i`z'',9)
			replace d85_`i`z'' = . if d85_`i`z'' < 0 | inlist(d86_`i`z'',99,88) 
			replace d81_`i`z'' = . if d81_`i`z'' < 0 | inlist(d81_`i`z'',8,9)
			
			generate alcohol_f`z'=. //genrate amount in drinking
			replace alcohol_f`z'=d86_`i`z''*50*0.53 if d85_`i`z''==1
			replace alcohol_f`z'=d86_`i`z''*50*0.37 if d85_`i`z''==2
			replace alcohol_f`z'=d86_`i`z''*50*0.12 if d85_`i`z''==3
			replace alcohol_f`z'=d86_`i`z''*50*0.15 if d85_`i`z''==4
			replace alcohol_f`z'=d86_`i`z''*50*0.04 if d85_`i`z''==5
			replace alcohol_f`z'=d86_`i`z''*50*0.244 if d85_`i`z''==6
			
			generate dril_f`z'=.
			replace dril_f`z'=2 if d81_`i`z'' == 2 
			replace dril_f`z'=3 if gender==1 & d81_`i`z''==1 & alcohol_f`z' <=25
			replace dril_f`z'=3 if gender==0 & d81_`i`z''==1 & alcohol_f`z' <=15
			replace dril_f`z'=4 if gender==1 & d81_`i`z''==1 & (alcohol_f`z' >25 & alcohol_f`z' != . ) 
			replace dril_f`z'=4 if gender==0 & d81_`i`z''==1 & (alcohol_f`z' > 15 & alcohol_f`z' != . )	
			label value dril_f`z' dril
	
		}		
	}	

	*Physical Activity
	if inlist(wave_alt,7){
		local am = wave_alt
		forvalues z = 3/`am'{
			recode d91_`i`z'' d92_`i`z'' (-1 -9 -6 -7 -8 8 9 = .)
			recode d93_`i`z'' (-1 -9 -6 -7 -8 888 999 = .)
			gen pa_f`z' = 1 if d91_`i`z'' == 1 & d93_`i`z'' < 50
			replace pa_f`z' = 2 if d91_`i`z'' == 1 & d93_`i`z'' >= 50 & d93_`i`z'' < . // choose to code pa missing if r_pa_pres is missing
			replace pa_f`z' = 3 if d91_`i`z'' != 1 & d92_`i`z'' == 1 
			replace pa_f`z' = 4 if d91_`i`z'' == 2 & d92_`i`z'' == 2 
			label define pa_f`z' 1 "current & start < 50" 2 "current & start >=50" 3 "former" 4 "never"
			label values pa_f`z' pa_f`z' 
		}		
	}
	if inlist(wave_alt,6){
		local am = wave_alt
		forvalues z = 2/`am'{
			recode d91_`i`z'' d92_`i`z'' (-1 -9 -6 -7 -8 8 9 = .)
			recode d93_`i`z'' (-1 -9 -6 -7 -8 888 999 = .)
			gen pa_f`z' = 1 if d91_`i`z'' == 1 & d93_`i`z'' < 50
			replace pa_f`z' = 2 if d91_`i`z'' == 1 & d93_`i`z'' >= 50 & d93_`i`z'' < . // choose to code pa missing if r_pa_pres is missing
			replace pa_f`z' = 3 if d91_`i`z'' != 1 & d92_`i`z'' == 1 
			replace pa_f`z' = 4 if d91_`i`z'' == 2 & d92_`i`z'' == 2 
			label define pa_f`z' 1 "current & start < 50" 2 "current & start >=50" 3 "former" 4 "never"
			label values pa_f`z' pa_f`z' 
		}		
	}	
	if inlist(wave_alt,1,2,3,4,5){
		local am = wave_alt
		forvalues z = 1/`am'{
			recode d91_`i`z'' d92_`i`z'' (-1 -9 -6 -7 -8 8 9 = .)
			recode d93_`i`z'' (-1 -9 -6 -7 -8 888 999 = .)
			gen pa_f`z' = 1 if d91_`i`z'' == 1 & d93_`i`z'' < 50
			replace pa_f`z' = 2 if d91_`i`z'' == 1 & d93_`i`z'' >= 50 & d93_`i`z'' < . // choose to code pa missing if r_pa_pres is missing
			replace pa_f`z' = 3 if d91_`i`z'' != 1 & d92_`i`z'' == 1 
			replace pa_f`z' = 4 if d91_`i`z'' == 2 & d92_`i`z'' == 2 
			label define pa_f`z' 1 "current & start < 50" 2 "current & start >=50" 3 "former" 4 "never"
			label values pa_f`z' pa_f`z' 
		}		
	}	
/*	
	if inlist(wave_alt,1,2,3,4,5,6,7){
		local am = wave_alt
		forvalues z = 1/`am'{
			recode d91_`i`z'' (2 = 0) (-1 -9 -6 -7 -8 8 9 = .),gen(pa_alt_f`z')
			label define pa_alt_f`z' 1 "regular PA" 0 "no regular PA"
			label value pa_alt_f`z' pa_alt_f`z'
		}
	}	
*/
	
	*leisure Activity //   d11 in 18 wave special !!!!!!!!!!!!!!!!!!!!!!!
	if inlist(wave_alt,1,2,3,4,5,6,7){
		ren d11b1_18 d11b_18 
	}
	
	if inlist(wave_alt,1,2,3,4,5,6,7){
		local am = wave_alt
		forvalues z = 1/`am'{
			ren (d11a_`i`z'' d11b_`i`z'' d11c_`i`z'' d11d_`i`z'' d11e_`i`z'' d11f_`i`z'' d11g_`i`z'' d11h_`i`z'') 	(housework_f`z' fieldwork_f`z' gardenwork_f`z' reading_f`z' pets_f`z' majong_f`z' tv_f`z' socialactivity_f`z')	
		}
	}
	
	
	if inlist(wave_alt,7){
		foreach z in 1{
			recode housework_f`z' fieldwork_f`z' gardenwork_f`z' reading_f`z' pets_f`z' majong_f`z' tv_f`z' socialactivity_f`z' (-1 -9 -6 -7 -8 8 9 = .) (3 = 1) (2 = 2) (1 = 3)
			egen    leisure_miss_f`z' = rowmiss(housework_f`z' fieldwork_f`z' gardenwork_f`z' reading_f`z' pets_f`z' majong_f`z' tv_f`z' socialactivity_f`z')
			egen    leisure_f`z' = rowtotal(housework_f`z' fieldwork_f`z' gardenwork_f`z' reading_f`z' pets_f`z' majong_f`z' tv_f`z' socialactivity_f`z')
			replace leisure_f`z' = . if leisure_miss_f`z' > 2
			label define leisure_f`z' 1 "never" 2 "sometimes" 3 "almost everyday"
			label values housework_f`z' fieldwork_f`z' gardenwork_f`z' reading_f`z' pets_f`z' majong_f`z' tv_f`z' socialactivity_f`z' leisure_f`z' 
		}
		forvalues z = 2/7{
			recode housework_f`z' fieldwork_f`z' gardenwork_f`z' reading_f`z' pets_f`z' majong_f`z' tv_f`z' socialactivity_f`z' (-1 -9 -6 -7 -8 8 9 = .) (5 = 1) (2 3 4 = 2) (1 = 3)
			egen    leisure_miss_f`z' = rowmiss(housework_f`z' fieldwork_f`z' gardenwork_f`z' reading_f`z' pets_f`z' majong_f`z' tv_f`z' socialactivity_f`z')
			egen    leisure_f`z' = rowtotal(housework_f`z' fieldwork_f`z' gardenwork_f`z' reading_f`z' pets_f`z' majong_f`z' tv_f`z' socialactivity_f`z')
			replace leisure_f`z' = . if leisure_miss_f`z' > 2
			label define leisure_f`z' 1 "never" 2 "sometimes" 3 "almost everyday"
			label values housework_f`z' fieldwork_f`z' gardenwork_f`z' reading_f`z' pets_f`z' majong_f`z' tv_f`z' socialactivity_f`z' leisure_f`z' 
		}		
		
	}	
	
	if inlist(wave_alt,1,2,3,4,5,6){
		local am = wave_alt
		forvalues z = 1/`am'{
			recode housework_f`z' fieldwork_f`z' gardenwork_f`z' reading_f`z' pets_f`z' majong_f`z' tv_f`z' socialactivity_f`z' (-1 -9 -6 -7 -8 8 9 = .) (5 = 1) (2 3 4 = 2) (1 = 3)
			egen    leisure_miss_f`z' = rowmiss(housework_f`z' fieldwork_f`z' gardenwork_f`z' reading_f`z' pets_f`z' majong_f`z' tv_f`z' socialactivity_f`z')
			egen    leisure_f`z' = rowtotal(housework_f`z' fieldwork_f`z' gardenwork_f`z' reading_f`z' pets_f`z' majong_f`z' tv_f`z' socialactivity_f`z')
			replace leisure_f`z' = . if leisure_miss_f`z' > 2
			label define leisure_f`z' 1 "never" 2 "sometimes" 3 "almost everyday"
			label values housework_f`z' fieldwork_f`z' gardenwork_f`z' reading_f`z' pets_f`z' majong_f`z' tv_f`z' socialactivity_f`z' leisure_f`z' 
		}
	}	

*********************Activity of daily living******************
	if inlist(wave_alt,1,2,3,4,5,6,7){
		local am = wave_alt
			forvalues z = 1/`am'{
				recode e1_`i`z'' e2_`i`z'' e3_`i`z'' e4_`i`z'' e5_`i`z'' e6_`i`z'' (1 = 0 unimpaired) (2 3 = 1 impaired) (-1 -9 -6 -7 -8 8 9 = .),gen(bathing_f`z' dressing_f`z' toileting_f`z' transferring_f`z' continence_f`z' feeding_f`z') label(newadl)
				egen    adl_miss_f`z'=rowmiss(bathing_f`z' dressing_f`z' toileting_f`z' transferring_f`z' continence_f`z' feeding_f`z')  
				egen    adl_sum_f`z'=rowtotal(bathing_f`z' dressing_f`z' toileting_f`z' transferring_f`z' continence_f`z' feeding_f`z')
				replace adl_sum_f`z'=. if adl_miss_f`z' > 1
				gen     adl_f`z'=0 if adl_sum_f`z' == 0
				replace adl_f`z'=1 if adl_sum_f`z' > 0 & adl_sum_f`z' != .
				replace adl_f`z'=. if adl_sum_f`z' == .
				label value adl_f`z' adl

		}		
	}		
	
	*diet
	if inlist(wave_alt,5,6,7){
		local am = wave_alt-4	
		forvalues z = 1/`am'{
			recode d31_`i`z'' d32_`i`z'' (1/2 = 1 "everyday or except winter")(3=2 occasionally) (4=3 "rarely or never")(-1 -9 -6 -8 -7 8 9 = .),gen(fruit_f`z' veg_f`z') label(fruitf)
			recode d4mt2_`i`z'' d4fsh2_`i`z'' d4egg2_`i`z'' d4ben2_`i`z'' d4veg2_`i`z'' d4sug2_`i`z'' d4tea2_`i`z'' d4gar2_`i`z'' (1 = 1 everyday)(2=2 occasionally)(3=3 "rarely or never")(-1 -9 -6 -8 -7 8 9 = .),gen(meat_f`z' fish_f`z' egg_f`z' bean_f`z' saltveg_f`z' sugar_f`z' tea_f`z' garlic_f`z') label(meatf)
			recode d31_`i`z'' d32_`i`z'' (1/2 = 2 "everyday or except winter")(3=1 occasionally) (4=0 "rarely or never")(-1 -9 -6 -7 -8 8 9 = .),gen(fruit1_f`z' veg1_f`z') label(fruit1_f`z')
			recode d4mt2_`i`z'' d4fsh2_`i`z'' d4egg2_`i`z'' d4ben2_`i`z'' d4veg2_`i`z'' d4sug2_`i`z'' d4tea2_`i`z'' d4gar2_`i`z'' (1 = 2 everyday)(2=1 occasionally)(3=0 "rarely or never")(-1 -9 -6 -8 -7 8 9 = .),gen(meat1_f`z' fish1_f`z' egg1_f`z' bean1_f`z' saltveg1_f`z' sugar1_f`z' tea1_f`z' garlic1_f`z') label(meat1_f`z')
				
			egen diet_f`z' = rowtotal(fruit1_f`z' veg1_f`z' garlic1_f`z' meat1_f`z' fish1_f`z' egg1_f`z' bean1_f`z' tea1_f`z' sugar1_f`z' saltveg1_f`z')
			egen diet_miss_f`z' = rowmiss(fruit1_f`z' veg1_f`z' garlic1_f`z' meat1_f`z' fish1_f`z' egg1_f`z' bean1_f`z' tea1_f`z' sugar1_f`z' saltveg1_f`z')
			replace diet_f`z' = . if diet_miss_f`z' > 2
		}		
			
	}	
	
	if inlist(wave_alt,5,6,7){
		local am1 = wave_alt-3	
		local am = wave_alt					
		forvalues z = `am1'/`am'{
			recode d31_`i`z'' d32_`i`z'' (1/2 = 1 "everyday or except winter")(3=2 occasionally) (4=3 "rarely or never")(-9 -8 -1 -6 -7 8 9 = .),gen(fruit_f`z' veg_f`z') label(fruitf)
			recode d4meat2_`i`z'' d4fish2_`i`z'' d4egg2_`i`z'' d4bean2_`i`z'' d4veg2_`i`z'' d4suga2_`i`z'' d4tea2_`i`z'' d4garl2_`i`z'' (1 = 1 everyday)(2/4=2 occasionally)(5=3 "rarely or never")(-9 -8 -1 -6 -7 8 9 = .),gen(meat_f`z' fish_f`z' egg_f`z' bean_f`z' saltveg_f`z' sugar_f`z' tea_f`z' garlic_f`z') label(meatf)
				
			recode d31_`i`z'' d32_`i`z'' (1/2 = 2 "everyday or except winter")(3=1 occasionally) (4=0 "rarely or never")(-9 -8 -1 -6 -7 8 9 = .),gen(fruit1_f`z' veg1_f`z') label(fruit1_f`z')
			recode d4meat2_`i`z'' d4fish2_`i`z'' d4egg2_`i`z'' d4bean2_`i`z'' d4veg2_`i`z'' d4suga2_`i`z'' d4tea2_`i`z'' d4garl2_`i`z'' (1 = 2 everyday)(2/4=1 occasionally)(5=0 "rarely or never")(-9 -8 -1 -6 -7 8 9 = .),gen(meat1_f`z' fish1_f`z' egg1_f`z' bean1_f`z' saltveg1_f`z' sugar1_f`z' tea1_f`z' garlic1_f`z') label(meat1_f`z')

			egen diet_f`z' = rowtotal(fruit1_f`z' veg1_f`z' garlic1_f`z' meat1_f`z' fish1_f`z' egg1_f`z' bean1_f`z' tea1_f`z' sugar1_f`z' saltveg1_f`z')
			egen diet_miss_f`z' = rowmiss(fruit1_f`z' veg1_f`z' garlic1_f`z' meat1_f`z' fish1_f`z' egg1_f`z' bean1_f`z' tea1_f`z' sugar1_f`z' saltveg1_f`z')
			replace diet_f`z' = . if diet_miss_f`z' > 2
		}
	}
	
	if inlist(wave_alt,1,2,3,4){
		local am = wave_alt		
		forvalues z = 1/`am'{
			recode d31_`i`z'' d32_`i`z'' (1/2 = 1 "everyday or except winter")(3=2 occasionally) (4=3 "rarely or never")(-9 -8 -1 -6 -7 8 9 = .),gen(fruit_f`z' veg_f`z') label(fruitf)
			recode d4meat2_`i`z'' d4fish2_`i`z'' d4egg2_`i`z'' d4bean2_`i`z'' d4veg2_`i`z'' d4suga2_`i`z'' d4tea2_`i`z'' d4garl2_`i`z'' (1 = 1 everyday)(2/4=2 occasionally)(5=3 "rarely or never")(-9 -8 -1 -6 -7 8 9 = .),gen(meat_f`z' fish_f`z' egg_f`z' bean_f`z' saltveg_f`z' sugar_f`z' tea_f`z' garlic_f`z') label(meatf)
				
			recode d31_`i`z'' d32_`i`z'' (1/2 = 2 "everyday or except winter")(3=1 occasionally) (4=0 "rarely or never")(-9 -8 -1 -6 -7 8 9 = .),gen(fruit1_f`z' veg1_f`z') label(fruit1_f`z')
			recode d4meat2_`i`z'' d4fish2_`i`z'' d4egg2_`i`z'' d4bean2_`i`z'' d4veg2_`i`z'' d4suga2_`i`z'' d4tea2_`i`z'' d4garl2_`i`z'' (1 = 2 everyday)(2/4=1 occasionally)(5=0 "rarely or never")(-9 -8 -1 -6 -7 8 9 = .),gen(meat1_f`z' fish1_f`z' egg1_f`z' bean1_f`z' saltveg1_f`z' sugar1_f`z' tea1_f`z' garlic1_f`z') label(meat1_f`z')

			egen diet_f`z' = rowtotal(fruit1_f`z' veg1_f`z' garlic1_f`z' meat1_f`z' fish1_f`z' egg1_f`z' bean1_f`z' tea1_f`z' sugar1_f`z' saltveg1_f`z')
			egen diet_miss_f`z' = rowmiss(fruit1_f`z' veg1_f`z' garlic1_f`z' meat1_f`z' fish1_f`z' egg1_f`z' bean1_f`z' tea1_f`z' sugar1_f`z' saltveg1_f`z')
			replace diet_f`z' = . if diet_miss_f`z' > 2
		}		
	}		

****************** Weight Height BMI *********************
	*weight
	if inlist(wave,98){
		recode g10_0 (-9 -8 -1 -6 -7 888 999 = .),gen(weight_f1)
		forvalues z = 2/7{
			recode g101_`i`z'' (-9 -8 -1 -6 -7 888 999 = .),gen(weight_f`z')
		}		
	}

	
	if inlist(wave_alt,1,2,3,4,5,6){
		local am = wave_alt 
		forvalues z = 1/`am'{
			recode g101_`i`z'' (-9 -8 -1 -6 -7 888 999 = .),gen(weight_f`z')
		}		
	}	
	
	*height-armlength & kneelength & hunchbacked
	cap ren g102a_18 meaheight_18
	if inlist(wave,14){	
		ren g1021_18 meaheight_18
	}
	cap ren  g102b_11 reportheight_11
	cap ren g102_5 youngheight_5
	
	if inlist(wave,98,00){
		foreach var of varlist g102a_*{
			cap local a = subinstr("`var'","g102a","armlength",.)
			cap ren `var' `a'
		}
		foreach var of varlist g102b_*{
			cap local a = subinstr("`var'","g102b","kneelength",.)
			cap ren `var' `a'
		}		
	}

	foreach var of varlist g122_*{
		cap local a = subinstr("`var'","g122","armlength",.)
		cap ren `var' `a'
	}	
	foreach var of varlist g123_*{
		cap local a = subinstr("`var'","g123","kneelength",.)
		cap ren `var' `a'
	}	
		

	
	if inlist(wave_alt,1,2,3,4){ // 14,11,08,05 for their follow-up
		local am = wave_alt
		forvalues z = 1/`am'{	
			recode armlength_`i`z'' kneelength_`i`z'' (-9 -8 -1 -6 -7  88 888 99 999 = .), gen(armlength_f`z' kneelength_f`z') // note: code g101 = 99 to . b/c the frequenct of 88 & 99 is abnormal for this variables
			drop armlength_`i`z'' kneelength_`i`z''			
		}		
	}
	if inlist(wave_alt,5,6,7){ // 02,00,98 for their follow-up on
		local am = wave_alt
		local am1 = wave_alt-3
		forvalues z = `am1'/`am'{	
			recode armlength_`i`z'' kneelength_`i`z'' (-9 -8 -1 -6 -7  88 888 99 999 = .), gen(armlength_f`z' kneelength_f`z') // note: code g101 = 99 to . b/c the frequenct of 88 & 99 is abnormal for this variables
			drop armlength_`i`z'' kneelength_`i`z''			
		}		
	}	
	if inlist(wave_alt,6,7){ // 00,98 for their follow-up
		local am = wave_alt-5
		foreach z in `am'{	
			recode armlength_`i`z'' kneelength_`i`z'' (-9 -8 -1 -6 -7  88 888 99 999 = .), gen(armlength_f`z' kneelength_f`z') // note: code g101 = 99 to . b/c the frequenct of 88 & 99 is abnormal for this variables
			drop armlength_`i`z'' kneelength_`i`z''
		}		
	}

	*height-meaheight & youngheight
	if inlist(wave,98,00,02,05,08,11){
		foreach var of varlist g1021_*{
			cap local a = subinstr("`var'","g1021","meaheight",.)
			cap ren `var' `a'
		}
	}		
/*
	if inlist(wave,98,00,02){
		foreach k in g102_5 {
			cap local a = subinstr("`var'","g102","youngheight",.)
			cap ren `var' `a'
		}
	}	
*/	
	if inlist(wave_alt,5,6,7){ // 98 00 02  for their follow-up on 05
		cap local am = wave_alt-4
		foreach z in `am'{	
			recode youngheight_`i`z'' (-9 -8 -1 -6 -7 888 999 = .), gen(youngheight_f`z') 
			drop youngheight_`i`z''
		}		
	}	
	if inlist(wave_alt,1,2,3,4){ // 05 08 11 14 for their follow-up 
		local am = wave_alt
		forvalues z = 1/`am'{	
			recode meaheight_`i`z'' (-9 -8 -1 -6 -7 888 999 = .), gen(meaheight_f`z') 
			drop meaheight_`i`z''
			gen height_f`z' = round(meaheight_f`z'/100, .01)
			
			gen bmi_f`z'=weight_f`z'/(height_f`z'*height_f`z') 
			replace bmi_f`z'=. if bmi_f`z' < 12 | bmi_f`z' >= 40
					
			gen bmi_cat_f`z'=.
			replace bmi_cat_f`z'=1 if bmi_f`z'<18.5
			replace bmi_cat_f`z'=2 if bmi_f`z'>=18.5 & bmi_f`z'<24
			replace bmi_cat_f`z'=3 if bmi_f`z'>=24 & bmi_f`z'<.
			label value bmi_cat_f`z' bmi	
		}		
	}

	* hunchbacked
	if inlist(wave_alt,3,4,5,6,7){ // 98 00 02 05 08 for their follow-up on 05
		local am1 = wave_alt-1
		local am2 = wave_alt-2
		forvalues z = `am2'/`am1'{	
			recode g102_`i`z'' (-9 -8 -1 -6 -7 8 9 = .) (2=0), gen(hunchbacked_f`z') 
		}		
	}	
	if inlist(wave_alt,1,2){ // 11 14 for their follow-up 
		local am = wave_alt
		forvalues z = 1/`am'{	
			recode g102_`i`z'' (-9 -8 -1 -6 -7 8 9 = .) (2=0), gen(hunchbacked_f`z') 
		}		
	}	
*************** Biomarker **************
	* Heart Rate // wave 08 lack this value 
	if inlist(wave_alt,1,2,3){ // 14,11,08 for their follow-up
		local am = wave_alt
		forvalues z = 1/`am'{	
			recode g7_`i`z'' (-9 -1 -6 -7 -8 888 999 0 = . ),gen(hr_f`z')
		}		
	}
	
	if inlist(wave_alt,5,6,7){ //02,00,98 for their follow-up not involve wave 08
		local am1 = wave_alt-4
		local am2 = wave_alt-2
		local am = wave_alt
		forvalues z = 1/`am1'{			
			recode g7_`i`z'' (-9 -1 -6 -7 -8 888 999 0 = . ),gen(hr_f`z')
		}			
		forvalues z = `am2'/`am'{			
			recode g7_`i`z'' (-9 -1 -6 -7 -8 888 999 0 = . ),gen(hr_f`z')
		}						
	}		
	
	if inlist(wave_alt,4,5,6,7){ // 05,02,00,98 for their follow-up involve wave 08
		local am = wave_alt - 3
		foreach  z in `am'{
			recode g71_`i`z'' g72_`i`z'' (-9 -1 -6 -7 -8 888 999 0 = . )
			egen hr_f`z' = rowmean(g71_`i`z'' g72_`i`z'')
		}		
	}		

/*	
	* Heart rhythm
	if !inlist(wave,05,14){
		recode g6_`i1' (1 = 0 "irregular") (2 = 1 "regular") (-9 -1 -6 -7 -8 8 9 = .),gen(hr_irr_f1) label(rhythm_f1)
	}
	if !inlist(wave,02,11,14){
		recode g6_`i2' (1 = 0 "irregular") (2 = 1 "regular") (-9 -1 -6 -7 -8 8 9 = .),gen(hr_irr_f2) label(rhythm_f2)
	}
	if !inlist(wave,00,08,11,14){
		recode g6_`i3' (1 = 0 "irregular") (2 = 1 "regular") (-9 -1 -6 -7 -8 8 9 = .),gen(hr_irr_f3) label(rhythm_f3)
	}
	if !inlist(wave,98,05,08,11,14){
		recode g6_`i4' (1 = 0 "irregular") (2 = 1 "regular") (-9 -1 -6 -7 -8 8 9 = .),gen(hr_irr_f4) label(rhythm_f4)
	}	
	if inlist(wave,98,00){
		recode g6_`i5' (1 = 0 "irregular") (2 = 1 "regular") (-9 -1 -6 -7 -8 8 9 = .),gen(hr_irr_f5) label(rhythm_f5)
	}	
*/	
	* blood pressure
	if inlist(wave_alt,5,6,7){
		local am = wave_alt-4
		local am1 = wave_alt-3
		local am2 = wave_alt
		forvalues z = 1/`am'{
			recode g51_`i`z'' g52_`i`z'' (-9 -1 -6 -7 -8 888 999 = .), gen(SBP_f`z' DBP_f`z')
		}
		forvalues z = `am1'/`am2'{
			recode g511_`i`z'' g512_`i`z'' g521_`i`z'' g522_`i`z''(-9 -1 -6 -7 -8  888 999 = .)
			egen SBP_f`z' = rowmean(g511_`i`z'' g512_`i`z'')
			egen DBP_f`z' = rowmean(g521_`i`z'' g522_`i`z'')
			recode SBP_f`z' DBP_f`z' (0 = .)		
		}		
	}		
	if inlist(wave_alt,1,2,3,4){
		local am = wave_alt
		forvalues z = 1/`am'{
			recode g511_`i`z'' g512_`i`z'' g521_`i`z'' g522_`i`z''(-9 -1 -6 -7 -8  888 999 = .)
			egen SBP_f`z' = rowmean(g511_`i`z'' g512_`i`z'')
			egen DBP_f`z' = rowmean(g521_`i`z'' g522_`i`z'')
			recode SBP_f`z' DBP_f`z' (0 = .)		
		}		
	}

	if inlist(wave_alt,1,2,3,4,5,6,7){
		local am = wave_alt
		forvalues z = 1/`am'{
			gen bpl_f`z' = 1 	if (SBP_f`z'>0 & SBP_f`z'<90) 	& (DBP_f`z'>0 & DBP_f`z'<60)
			replace bpl_f`z' = 2 if (SBP_f`z'>=90 & SBP_f`z'<=120) & (DBP_f`z'>=60 & DBP_f`z'<=80)	
			replace bpl_f`z' = 3 if (SBP_f`z'>120 & SBP_f`z'<140) 	& (DBP_f`z'>80 & DBP_f`z'<90)
			replace bpl_f`z' = 4 if (SBP_f`z'>=140 & SBP_f`z'<160) | (DBP_f`z'>=90 & DBP_f`z'<100)
			replace bpl_f`z' = 5 if (SBP_f`z'>=160 & SBP_f`z'<.) 	| (DBP_f`z'>=100 & SBP_f`z'<.)
			label values bpl_f`z' bpl			
		}		
	}		

	
******************CI & MMSE ******************
	if inlist(wave_alt,1,2,3,4,5,6,7){
		local am = wave_alt
		forvalues z = 1/`am'{		
		*****cognition
			*orientation section
			recode c11_`i`z'' c12_`i`z'' c13_`i`z'' c14_`i`z'' c15_`i`z'' (0 8 = 0 "unable to answer or wrong") (1 = 1 "correct") (-9 -6 -1 -7 -8 9 = .), gen(time_orientation1_f`z' time_orientation2_f`z' time_orientation3_f`z' time_orientation4_f`z' place_orientation_f`z') label(ciorientation_f`z')

			*naming foods
			recode c16_`i`z'' (88 = 0 "unable to answer") (-9 -6 -1 -7 -8 99 = .), gen(namefo_f`z') label(cinamefo_f`z')
			replace namefo_f`z'=7 if namefo_f`z'>=7 & namefo_f`z'<. 									
				
			*registration
			recode c21a_`i`z'' c21b_`i`z'' c21c_`i`z'' (8 = 0 "wrong or unable to answer") (1 = 1 "correct") (-9 -6 -1 -7 -8 9 2 = .),gen(registration1_f`z' registration2_f`z' registration3_f`z') label(ciregistration_f`z')

			*attention and calculation--attempts to repeat the names of three objects correctly
			recode c31a_`i`z'' c31b_`i`z'' c31c_`i`z'' c31d_`i`z'' c31e_`i`z'' (8 = 0 "wrong or unable to answer") (1 = 1 "correct") (-9 -6 -1 -7 -8  9 = .),gen(calculation1_f`z' calculation2_f`z' calculation3_f`z' calculation4_f`z' calculation5_f`z') label(ciattention_f`z')

			*recall
			recode c41a_`i`z'' c41b_`i`z'' c41c_`i`z'' (8 = 0 "wrong or unable to answer") (1 = 1 "correct")  (-9 -6 -1 -7 -8 9 = .), gen(delayed_recall1_f`z' delayed_recall2_f`z' delayed_recall3_f`z') label(cirecall)

			*language
			recode c51a_`i`z'' c51b_`i`z'' c52_`i`z'' c53a_`i`z'' c53b_`i`z'' c53c_`i`z'' (8 = 0) (-9 -6 -1 -7 -8 9 = .), gen(naming_objects1_f`z' naming_objects2_f`z' repeating_sentence_f`z' listening_obeying1_f`z' listening_obeying2_f`z' listening_obeying3_f`z') label(cilanguage_f`z')
				
			*copy a figure
			recode c32_`i`z'' (8 = 0 "wrong or unable to answer") (1 = 1 "correct") (-9 -6 -1 -7 -8 9 = .),gen(copyf_f`z') label(cifigure_f`z')
				 
			*CI missing
			egen ci_missing_f`z' = rowmiss(time_orientation1_f`z' time_orientation2_f`z' time_orientation3_f`z' time_orientation4_f`z' place_orientation_f`z' namefo_f`z' registration1_f`z' registration2_f`z' registration3_f`z' calculation1_f`z' calculation2_f`z' calculation3_f`z' calculation4_f`z' calculation5_f`z' copyf_f`z' delayed_recall1_f`z' delayed_recall2_f`z' delayed_recall3_f`z' naming_objects1_f`z' naming_objects2_f`z' repeating_sentence_f`z' listening_obeying1_f`z' listening_obeying2_f`z' listening_obeying3_f`z')
				
			egen ci_f`z' = rowtotal(time_orientation1_f`z' time_orientation2_f`z' time_orientation3_f`z' time_orientation4_f`z' place_orientation_f`z' namefo_f`z' registration1_f`z' registration2_f`z' registration3_f`z' calculation1_f`z' calculation2_f`z' calculation3_f`z' calculation4_f`z' calculation5_f`z' copyf_f`z' delayed_recall1_f`z' delayed_recall2_f`z' delayed_recall3_f`z' naming_objects1_f`z' naming_objects2_f`z' repeating_sentence_f`z' listening_obeying1_f`z' listening_obeying2_f`z' listening_obeying3_f`z')
				
			replace ci_f`z' = . if ci_missing_f`z' > 3  

			egen time_orientation_f`z'	= rowtotal(time_orientation1_f`z' time_orientation2_f`z' time_orientation3_f`z' time_orientation4_f`z')
			egen orientation_f`z'			= rowtotal(time_orientation_f`z'  place_orientation_f`z')
			egen registration_f`z'		= rowtotal(registration1_f`z' registration2_f`z' registration3_f`z')
			egen calculation_f`z'			= rowtotal(calculation1_f`z' calculation2_f`z' calculation3_f`z' calculation4_f`z' calculation5_f`z')
			egen delayed_recall_f`z'		= rowtotal(delayed_recall1_f`z' delayed_recall2_f`z' delayed_recall3_f`z')
			egen naming_objects_f`z'		= rowtotal(naming_objects1_f`z' naming_objects2_f`z')
			egen listening_obeying_f`z'	= rowtotal(listening_obeying1_f`z' listening_obeying2_f`z' listening_obeying3_f`z')
			egen Language_f`z'			= rowtotal(naming_objects_f`z' repeating_sentence_f`z' listening_obeying_f`z')
				
			gen orientation_full_f`z' 	= (orientation_f`z' == 5)
			gen namefo_full_f`z' 			= (namefo_f`z' == 7)
			gen registration_full_f`z' 	= (registration_f`z' == 3)
			gen calculation_full_f`z' 	= (calculation_f`z' == 5)
			gen copyf_full_f`z' 			= (copyf_f`z' == 1)
			gen delayed_recall_full_f`z' 	= (delayed_recall_f`z' == 3)
			gen Language_full_f`z'		= (Language_f`z' == 6)

			* MMSE
			egen mmse_f`z' =	rowtotal(orientation_f`z' namefo_f`z' registration_f`z' calculation_f`z' copyf_f`z' delayed_recall_f`z' Language_f`z'),mi 
			egen mmsemiss_f`z' =	rowmiss(orientation_f`z' namefo_f`z' registration_f`z' calculation_f`z' copyf_f`z' delayed_recall_f`z' Language_f`z')
			
			replace mmse_f`z' = . if mmsemiss_f`z' >=3
				
			gen ci_cat_f`z'=.
			replace ci_cat_f`z'=3 if mmse_f`z'>=0 & mmse_f`z'<=9
			replace ci_cat_f`z'=2 if mmse_f`z'>=10 & mmse_f`z'<=17
			replace ci_cat_f`z'=1 if mmse_f`z'>=18 & mmse_f`z'<=24
			replace ci_cat_f`z'=0 if mmse_f`z'>=25 & mmse_f`z'<=30
				
			gen ci_bi_f`z'=.
			replace ci_bi_f`z'=0 if mmse_f`z'>25
			replace ci_bi_f`z'=1 if mmse_f`z'<=25

			label value ci_cat_f`z' y
			label value ci_bi_f`z' u
						
		}		
	}	
********************** Psychology ******************
	if inlist(wave_alt,2,3,4,5,6,7){
		local am = wave_alt-1
		forvalues z = 1/`am'{
			recode b21_`i`z'' b22_`i`z'' b25_`i`z'' b27_`i`z'' (1 = 5) (2 = 4) (4 = 2) (5 = 1) (-9 -6 -1 -7 -8  8 9 = . ), gen(psy1_f`z' psy2_f`z' psy5_f`z' psy7_f`z') 
			recode b23_`i`z'' b24_`i`z'' b26_`i`z'' (-9 -6 -1 -7 -8  8 9 = .), gen(psy3_f`z' psy4_f`z' psy6_f`z') 
			egen psycho_f`z' = rowtotal(psy1_f`z' psy2_f`z' psy3_f`z' psy4_f`z' psy5_f`z' psy6_f`z' psy7_f`z')
			egen psy_miss_f`z' = rowmiss(psy1_f`z' psy2_f`z' psy3_f`z' psy4_f`z' psy5_f`z' psy6_f`z' psy7_f`z')
			
			replace psycho_f`z' = . if psy_miss_f`z' > 2 		
		}		
	}	
	
******************* Realiability of the answers  *****************************
	if inlist(wave_alt,1,2,3,4,5,6,7){
		local am = wave_alt
		forvalues z = 1/`am'{
			recode h21_`i`z'' (1 3 = 1 "able/patrically able") (2= 0 "no") (-9 -6 -1 -7 -8  8 9 = .),gen(ablephy_f`z') label(ablephy)
			recode h22_`i`z''  (-9 -6 -1 -7 -8 9 = .),gen(ablephyreas_f`z') label(ablephyreason)
		}		
	}		
/*
********************** Disablility ******************
	if inlist(wave,98,0,2,5){
		foreach z in 1 2 3{
			recode g15*3_`i`z'' (9 8 = .) (1 = 2 ) (2 = 1) (-1 3 = 0)
			replace g15*3_`i`z'' = 0 if 
			label define disability_f`z' 2 "rather serious" 1"more or less" 0 "no"
			label values g15*3_`i`z'' disability_f`z'
			egen disability_f`z' = rowtotal(g17*2`i`z''),mi
			egen disability_miss_f`z' = rowmiss(g17*2`i`z'')		
			//replace disability_f`z' = . if  disability_miss_f`z' 
		}
	}
	if inlist(wave,8){
		foreach z in 1 2 {
			recode g15*3_`i`z'' (9 8 = .) (1 = 2 ) (2 = 1) (-1 3 = 0)
			replace g15*3_`i`z'' = 0 if 
			label define disability_f`z' 2 "rather serious" 1"more or less" 0 "no"
			label values g15*3_`i`z'' disability_f`z'
			egen disability_f`z' = rowtotal(g17*2`i`z''),mi
			egen disability_miss_f`z' = rowmiss(g17*2`i`z'')		
			//replace disability_f`z' = . if  disability_miss_f`z' 
		}
	}	
	if inlist(wave,11,14){
		foreach z in 1 2 {
			recode g15*3_`i`z'' (9 8 = .) (1 = 2 ) (2 = 1) (-1 3 = 0)
			replace g15*3_`i`z'' = 0 if 
			label define disability_f`z' 2 "rather serious" 1"more or less" 0 "no"
			label values g15*3_`i`z'' disability_f`z'
			egen disability_f`z' = rowtotal(g17*2`i`z''),mi
			egen disability_miss_f`z' = rowmiss(g17*2`i`z'')		
			//replace disability_f`z' = . if  disability_miss_f`z' 
		}
	}	
*/
	* hearingloss
	if inlist(wave_alt,1,2){ //11 14
		local am = wave_alt
		forvalues z = 1/`am'{
			recode  g106_`i`z'' g1061_`i`z'' g1062_`i`z'' g1063_`i`z'' (8 9 = .)
			gen hearingloss_f`z' = 1 if g106_`i`z'' == 1 
			replace hearingloss_f`z' = 2 if g106_`i`z'' == 1  & g1061_`i`z'' ==3 
			replace hearingloss_f`z' = 0 if g106_`i`z'' == 2 		
		}		
	}			
	if inlist(wave_alt,3,4,5,6,7){ // for 98-08, their follow-up on 11-18
		local am1 = wave_alt-2
		local am2 = wave_alt-1
		local am2 = wave_alt
		foreach z in `am1' `am2' `am3'{
			recode  g106_`i`z'' g1061_`i`z'' g1062_`i`z'' g1063_`i`z'' (8 9 = .)
			gen hearingloss_f`z' = 1 if g106_`i`z'' == 1 
			replace hearingloss_f`z' = 2 if g106_`i`z'' == 1  & g1061_`i`z'' ==3 
			replace hearingloss_f`z' = 0 if g106_`i`z'' == 2 		
		}		
	}		
	
* Interview date & season 
	* rename interview date and prepare for panel
	replace id_year =8 if id_year ==9
	replace id_year =11 if id_year ==12
	
	gen intdate  = interview_baseline
	if inlist(wave_alt,1,2,3,4,5,6,7){
		local am = wave_alt
		forvalues z = 1/`am'{
			g intdate_f`z'  = in`i`z'' 
		}		
	}		
	
	ren wave wave_baseline 
	
	if inlist(wave_alt,1,2,3,4,5,6,7){
		local am = wave_alt
		forvalues z = 1/`am'{
			gen wave_f`z' = `i`z''
		}		
	}
	
******************* Frailty  **************
	* Self-reported Health Ordinal 
	if inlist(wave_alt,1,2,3,4,5,6,7){
		local am = wave_alt
		forvalues z = 1/`am'{
			recode b12_`i`z''  (1 2 3 = 0) (4 5 = 1) (-9/-1 8 9 = . ) ,gen(fra_srh_f`z') // 4"Bad" 5 "Very bad"
			recode b121_`i`z'' (1 2 3 = 0) (4 5 = 1) (-9/-1 8 9 = . ) ,gen(fra_hworse_f`z') 
		}		
	}	
	

    * ADL: activity of daily living  Ordinal 
	if inlist(wave_alt,1,2,3,4,5,6,7){
		local am = wave_alt
		forvalues z = 1/`am'{
			recode e1_`i`z'' e2_`i`z'' e3_`i`z'' e4_`i`z'' e5_`i`z'' e6_`i`z'' (1 2= 0 ) (3 = 1 ) (-9/-1 8 9 = .),gen(fra_bathing_f`z' fra_dressing_f`z' fra_toileting_f`z' fra_transferring_f`z' fra_continence_f`z' fra_feeding_f`z')  // 2:one part assistance 3: more than one part assistance
			recode e7_`i`z'' e8_`i`z''  e9_`i`z'' e10_`i`z'' e11_`i`z'' e12_`i`z'' e13_`i`z'' e14_`i`z'' (1 2= 0 ) (3 = 1 ) (-9/-1 8 9 = .),gen(fra_visit_f`z' fra_shopping_f`z' fra_cook_f`z' fra_washcloth_f`z' fra_walk1km_f`z' fra_lift_f`z' fra_standup_f`z' fra_publictrans_f`z') 
			
		}		
	}		
	
	* Visual function Ordinal 	
	if inlist(wave_alt,1,2,3){
		local am = wave_alt
		forvalues z = 1/`am'{
			recode g1_`i`z'' (1 2 = 0)  (3 4 = 1) (-9/-1 8 9 = .),gen(fra_visual_f`z') // 3:  can't see 4: blind ??2  can see but can't distinguish the break in the circle 		
		}			
	}
	
	* sleep
	if inlist(wave_alt,1){
		local am = wave_alt
		forvalues z = 1/`am'{
			recode b310a_`i`z'' (1 2 3 = 0)  (4 5  = 1 ) (-9/-1 8 9 = .),gen(fra_sleep_f`z') // 4: bad 5: very bad	
		}			
	}	
	
	* Functional: 
	* Hand behind neck & Hand behind lower back Ordinal 
	if inlist(wave_alt,1,2,3){
		local am = wave_alt
		forvalues z = 1/`am'{
			recode g81_`i`z'' g82_`i`z'' g83_`i`z'' (4 = 1) (1 2 3 = 0) (-9/-1 8 9 = .),gen(fra_neck_f`z'  fra_lowerback_f`z'  fra_raisehands_f`z' ) // 1  right hand, 	2  left hand, 4  neither hand	
		}			
	}		
	
	* Able to stand up from sitting, Able to pick up a book from the floor
	if inlist(wave_alt,1,2,3){
		local am = wave_alt
		forvalues z = 1/`am'{
			recode g9_`i`z'' g11_`i`z'' (1 2= 0) (3 = 1) (-9/-1 8 9 = .),gen(fra_stand_f`z' fra_book_f`z' ) // 2  yes, using hands, 3  no ??? 2  yes, using hands //2  yes, sitting, 3  no ??? 2  yes, sitting
		}					
	}		
	
	* Number of times suffering from serious illness in the past two years	Ordinal 	
	if inlist(wave_alt,1,2,3){
		local am = wave_alt
		forvalues z = 1/`am'{
			recode g131_`i`z'' (0=0) (1  = 1) (2/88 = 2) (-9/-1 99  = . ),gen(fra_seriousillness_f`z')				
		}			
	}		
	* MMSE
	if inlist(wave_alt,1,2,3){
		local am = wave_alt
		forvalues z = 1/`am'{
			gen fra_ci_f`z' = 1 if mmse_f`z' <=25 & mmse_f`z' !=.
			replace fra_ci_f`z' = 0 if mmse_f`z' >25 	
			replace fra_ci_f`z' = . if mmse_f`z' ==.		

		}			
	}		

	
******** Self-reported Disease History **********
//Hypertension,Diabetes,Heart disease,Stroke or CVD,COPD,Tuberculosis,Cancer,Gastric or duodenal ulcer,Parkinsons,Bedsore,Cataract,Glaucoma,Other chronic disease	Categorical ?????????, Prostate Tumor cancer
	if inlist(wave_alt,3){
		local am = wave_alt
		forvalues z = 1/`am'{
		
		foreach k in a b c d e f g h i j k l m n q s t {
			gen disease_`k'_f`z' = 1 if g15`k'1_`i`z''==1
			replace disease_`k'_f`z' = 0  if g15`k'1_`i`z''==2 
		}

		ren disease_a_f`z' fra_hypertension_f`z'
		ren disease_b_f`z' fra_diabetes_f`z'
		ren disease_c_f`z' fra_htdisea_f`z'
		ren disease_d_f`z' fra_strokecvd_f`z'
		ren disease_e_f`z' fra_copd_f`z'
		ren disease_f_f`z' fra_tb_f`z'
		ren disease_g_f`z' fra_cataract_f`z'
		ren disease_h_f`z' fra_glaucoma_f`z'
		ren disease_i_f`z' fra_cancer_f`z'
		ren disease_j_f`z' fra_prostatetumor_f`z'
		ren disease_k_f`z' fra_ulcer_f`z'
		ren disease_l_f`z' fra_parkinson_f`z'
		ren disease_m_f`z' fra_bedsore_f`z'
		ren disease_q_f`z' fra_cholecystitis_f`z'
		ren disease_t_f`z' fra_chronephritis_f`z'
		
		replace fra_hypertension_f`z' = 1 if (SBP_f`z'>=140 & SBP_f`z'!=.) | (DBP_f`z'>=90 & DBP_f`z'!=.)
		
		}					
	}

	if inlist(wave_alt,1,2){
		local am = wave_alt
		forvalues z = 1/`am'{
		
		foreach k in a b c d e f g h i j k l m n q s t {
			gen disease_`k'_f`z' = 1 if g15`k'1_`i`z''==1
			replace disease_`k'_f`z' = 0  if g15`k'1_`i`z''==2 
		}

		ren disease_a_f`z' fra_hypertension_f`z'
		ren disease_b_f`z' fra_diabetes_f`z'
		ren disease_c_f`z' fra_htdisea_f`z'
		ren disease_d_f`z' fra_strokecvd_f`z'
		ren disease_e_f`z' fra_copd_f`z'
		ren disease_f_f`z' fra_tb_f`z'
		ren disease_g_f`z' fra_cataract_f`z'
		ren disease_h_f`z' fra_glaucoma_f`z'
		ren disease_i_f`z' fra_cancer_f`z'
		ren disease_j_f`z' fra_prostatetumor_f`z'
		ren disease_k_f`z' fra_ulcer_f`z'
		ren disease_l_f`z' fra_parkinson_f`z'
		ren disease_m_f`z' fra_bedsore_f`z'
		ren disease_q_f`z' fra_cholecystitis_f`z'
		ren disease_t_f`z' fra_chronephritis_f`z'
		
		replace fra_hypertension_f`z' = 1 if (SBP_f`z'>=140 & SBP_f`z'!=.) | (DBP_f`z'>=90 & DBP_f`z'!=.)
		
		gen fra_rheumatism_f`z' = 1 if disease_n_f`z'==1 | disease_s_f`z'==1
		replace fra_rheumatism_f`z' = 0 if disease_n_f`z'==0 & disease_s_f`z'==0
		
		}					
	}

	* Able to hear
	if inlist(wave_alt,1,2,3){
		local am = wave_alt
		forvalues z = 1/`am'{
			recode h1 (1 2 =0) (3 4 = 1)  (-9/-1 8 9 = .),gen(fra_hear_f`z') //  2: yes, but needs hearing aid, 3: partly, despite hearing aid, 4: no ????
		}		
	}
	* Interviewer rated health	
	if inlist(wave_alt,1,2,3){
		local am = wave_alt
		forvalues z = 1/`am'{
			recode h3_`i`z'' (1 2 =0) (3 4 = 1) (-9/-1 8 9= .),gen(fra_irh_f`z')		
		}		
	}	
	
	
	* psychol
 	/*Look on the bright side of things
 	Keep my belongings neat and clean !!
 	Make own decisions	 ?????
 	Feel fearful or anxious	  ?????/
 	Feel useless with age	?????? */ 
	
	* for followup on 11,14
	if inlist(wave_alt,2,3){
		local am = wave_alt
		local am1 = `am'-1
		forvalues z = 1/`am1'{
			recode b21_`i`z''  b22_`i`z''  b25_`i`z'' b27_`i`z'' (1 2 3=0) (4 5 = 1) (-9/-1 8 9 = . ), gen(fra_psy1_f`z' fra_psy2_f`z' fra_psy5_f`z' fra_psy7_f`z')  //positive  1  always,2  often,53  sometimes,4  seldom,5  never
			recode b23_`i`z'' b24_`i`z'' b26_`i`z'' (1 2 =1)  (5 3 4 = 0) (-9/-1 8 9 = . ), gen(fra_psy3_f`z' fra_psy4_f`z' fra_psy6_f`z') // negative 1  always,2  often,3  sometimes,4  seldom,5  never
		}		
	}

	* for followup on 18
	if inlist(wave_alt,1,2,3){
		local am = wave_alt
		foreach z in `am'{
			recode b21_`i`z'' b22_`i`z'' b23_`i`z''  (1 2 3=0) (4 5 = 1) (-9/-1 8 9 = . ), gen(fra_psy1_f`z' fra_psy2_f`z' fra_psy5_f`z')  //positive  1  always,2  often,53  sometimes,4  seldom,5  never
			recode b34_`i`z'' b36_`i`z'' b38_`i`z''  (1 2 =1)  (5 3 4 = 0) (-9/-1 8 9 = . ), gen(fra_psy3_f`z' fra_psy4_f`z' fra_psy6_f`z') // negative 1  always,2  often,3  sometimes,4  seldom,5  never
		}		
	}

	* Housework at present	
	if inlist(wave_alt,1,2,3){
		local am = wave_alt
		forvalues z = 1/`am'{
			recode  housework_f`z' (2 3 =0) (1=1)  (-9/-1 8 9 = . ),gen(fra_housework_f`z') // 3: never
		}		
	}		
	
	
	* Able to use chopsticks to eat
	if inlist(wave_alt,1,2,3){
		local am = wave_alt
		forvalues z = 1/`am'{
			recode g3_`i`z'' (2=0) (-9/-1 8 9 = . ),gen(fra_chopsticks_f`z') 
		}		
	}	
	
	
	* Number of steps used to turn around a 360 degree turn without help
	if inlist(wave_alt,1,2,3){
		local am = wave_alt
		forvalues z = 1/`am'{
			recode g12_`i`z'' (20/88 = 1) (10/19 = 0.5) (5/9 = 0.25) (1/4 = 0) (-9/-1 0 89/888 = .) ,gen(fra_turn_f`z')
		}		
	}	
		
	* physical 
	* BMI
	if inlist(wave_alt,1,2,3){
		local am = wave_alt
		forvalues z = 1/`am'{
			foreach k in height_f`z' weight_f`z' {
				sum `k' if gender == 0
				replace `k' = . if !inrange(`k',r(mean)-3*r(sd),r(mean)+3*r(sd) ) & gender == 0
				sum `k' if gender == 1
				replace `k' = . if !inrange(`k',r(mean)-3*r(sd),r(mean)+3*r(sd) ) & gender == 1
			}
			gen fra_bmi_f`z'= 1 if weight_f`z'/(height_f`z'*height_f`z')<18.5 | weight_f`z'/(height_f`z'*height_f`z')>=28
			replace fra_bmi_f`z'= 0.5 if weight_f`z'/(height_f`z'*height_f`z')<28 & weight_f`z'/(height_f`z'*height_f`z')>=24
			replace fra_bmi_f`z'= 0 if weight_f`z'/(height_f`z'*height_f`z')<24 & weight_f`z'/(height_f`z'*height_f`z')>=18.5
			replace fra_bmi_f`z'= . if weight_f`z'/(height_f`z'*height_f`z') == .
		}		
	}	

	* heart rate
	if inlist(wave_alt,1,2){
		local am = wave_alt
		foreach z in `am'{
			recode g7_`i`z''  (-1 888 999 = . ),gen(fra_hr_f`z')
			foreach k in fra_hr_f`z' {
				sum `k' 
				replace `k' = . if !inrange(`k',r(mean)-3*r(sd),r(mean)+3*r(sd)) 
			}		
		}		
	}		
	
* fule
	if inlist(wave_alt,1,2){
		local am = wave_alt
		foreach z in `am'{
			recode a537_`i`z'' (6 8= 1 "biomass") (1 2 3 7 =2 "clean fuels") (0=3 "never cooked in the home") (4 5 9=4 "others"),gen(biomass_f`z') label("biomass")
		}
	}	
	
	
* age adjustment 
	gen year_0 = 2000 if !inlist(wave_baseline,00,02,05,08,11,14)
	gen year_2 = 2002 if !inlist(wave_baseline,02,05,08,11,14)
	gen year_5 = 2005 if !inlist(wave_baseline,05,08,11,14)
	
	foreach k in month day year {
		cap ren `k'_0 `k'in_0
		cap ren `k'_2 `k'in_2
		cap ren `k'_5 `k'in_5
		cap ren `k'_8 `k'in_8		
	}

	if inlist(wave_alt,1,2,3,4,5,6,7){
		local am = wave_alt
		forvalues z = 1/`am'{
			gen age_f`z' = yearin_`i`z'' - v_bthyr if yearin_`i`z''>0 &  yearin_`i`z''!=.
			replace age_f`z' = age_f`z' - 1 if (v_bthmon > monthin_`i`z'' | (v_bthmon == monthin_`i`z'' & dayin_`i`z'' < 15 )) & v_bthmon!=. & yearin_`i`z''>0  & yearin_`i`z''!=. 

		}		
	}	
	
* date interview
	if inlist(wave_alt,1,2,3,4,5,6,7){
		local am = wave_alt
		forvalues z = 1/`am'{
			ren yearin_`i`z'' yearin_f`z'
			ren monthin_`i`z'' monthin_f`z'

		}		
	}

* dth & censor 
	gen dth = .
	if inlist(wave_alt,1,2,3,4,5,6,7){
		local am = wave_alt
		forvalues z = 1/`am'{
			ren dth`i`z'' dth_f`z'
		}		
	}

	drop a b c d e f g	
		
save "${int}/Full_dat`year'_18_f7_covariances.dta",replace
	
	if inlist(wave_baseline,00,02,05){
		keep if id_year == wave_baseline
	}
	if inlist(wave_baseline,14){
		keep if id_year == 14 | id_year == 13
	}
	if inlist(wave_baseline,08){
		keep if id_year == 08 | id_year == 09
	}
	if inlist(wave_baseline,11){
		keep if id_year == 11 | id_year == 12
	}	
	if inlist(wave_baseline,18){
		keep if id_year == 18 | id_year == 19
	}		
	
save "${int}/Base_dat`year'_18_f7_covariances.dta",replace
}
