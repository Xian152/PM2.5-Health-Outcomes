******************* Frailty  **************
	* Self-reported Health Ordinal 
	recode b12 (1 2 3 = 0) (4 5 = 1) (-9/-1 8 9 = . ) ,gen(fra_srh) // 4"Bad" 5 "Very bad"
	
    * ADL: activity of daily living  Ordinal 
	recode e1 e2 e3 e4 e5 e6  (1 = 0 "do not need help") (2 3 = 1 "need help") (-9/-1 8 9 = .),gen(fra_bathing fra_dressing fra_toileting fra_transferring fra_continence fra_feeding) // 2:one part assistance 3: more than one part assistance
	
	* Visual function Ordinal 
	if inlist(wave,98,02,05,08,11,14,18){
	recode g1 (1 2 = 0) (3 4 = 1) (-9/-1 8 9 = .),gen(fra_visual) // 3:  can't see 4: blind ??2  can see but can't distinguish the break in the circle 
	}
	if inlist(wave,00,02,05){
	recode g1 (1 = 0) (2 3 4 = 1) (-9/-1 8 9 = .),gen(fra_visual) // 2:  can't see 3: blind 
	}	
	
	* Rhythm of heart ???????
	if !inlist(wave,08,18){
		recode g6 (1 = 1 ) (2 = 0 ) (-9/-1 8 9 = .),gen(fra_hr_irr) 
	}

	* Hand behind neck &	Hand behind lower back Ordinal 
	if inlist(wave,98){
		recode g101 g102 (1 2 4 = 1) (3 = 0) (-9/-1 8 9 = .),gen(fra_neck fra_lowerback) // 1  right hand, 	2  left hand, 4  neither hand
	}	
	if !inlist(wave,98){
		recode g81 g82 (1 2 4 = 1) (3 = 0) (-9/-1 8 9 = .),gen(fra_neck fra_lowerback) // 1  right hand, 	2  left hand, 4  neither hand
	}		
	
	* Able to stand up from sitting, Able to pick up a book from the floor
	if inlist(wave,98){
		recode g11 g13(1 = 0) (2 3 = 1) (-9/-1 8 9 = .),gen(fra_stand fra_book ) // 2  yes, using hands, 3  no ??? 2  yes, using hands //2  yes, sitting, 3  no ??? 2  yes, sitting
	}	
	if !inlist(wave,98){
		recode g9 g11(1 = 0) (2 3 = 1) (-9/-1 8 9 = .),gen(fra_stand fra_book ) // 2  yes, using hands, 3  no ??? 2  yes, using hands //2  yes, sitting, 3  no ??? 2  yes, sitting
	}		
	
	* Number of times suffering from serious illness in the past two years	Ordinal 
	if inlist(wave,98){
		recode g16 (1/88 = 1) (-9/-1 99  = . ),gen(fra_seriousillness)	}	
	if inlist(wave,00,02,05){
		recode g13 (1 = 0) (2 3 = 1) (-9/-1 8 9 = .),gen(fra_stand fra_book ) // 2  yes, using hands, 3  no ??? 2  yes, using hands //2  yes, sitting, 3  no ??? 2  yes, sitting
	}		
	if inlist(wave,08,11,14,18){
		recode g131  (2 3 = 1) (-9/-1 8 9 = .),gen(fra_stand fra_book ) // 2  yes, using hands, 3  no ??? 2  yes, using hands //2  yes, sitting, 3  no ??? 2  yes, sitting
	}		
	

******** Self-reported Disease History **********
//Hypertension,Diabetes,Heart disease,Stroke or CVD,COPD,Tuberculosis,Cancer,Gastric or duodenal ulcer,Parkinsons,Bedsore,Cataract,Glaucoma,Other chronic disease	Categorical ?????????, Prostate Tumor cancer
	if inlist(wave,98){
		foreach k in a b c d e f g h i j k l m {
			gen disease_`k' = 1 if g17`k'1==1
			replace disease_`k' = 0  if g17`k'1==2 
		}
		
		ren disease_a fra_hypertension
		ren disease_b fra_diabetes
		ren disease_c fra_heartdisea
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
		
	if inlist(wave,00,02,05,08,11,14,18){
		foreach k in a b c d e f g h i j k l m n {
			gen disease_`k' = 1 if g15`k'1==1
			replace disease_`k' = 0  if g15`k'1==2 
		}

		ren disease_a fra_hypertension
		ren disease_b fra_diabetes
		ren disease_c fra_heartdisea
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
	}

	* Able to hear
	recode h1a (2 3 4 = 1)  (-9/-1 8 9 = .),gen(fra_hear)//  2: yes, but needs hearing aid, 3: partly, despite hearing aid, 4: no ????
	
	* Interviewer rated health	
	recode h3 (1 2 = 0) (3 4 = 1) (-9/-1 8 9= .),gen(fra_irh)
	
	* psychol
 	/*Look on the bright side of things 
 	Keep my belongings neat and clean	 
 	Make own decisions	 
 	Feel fearful or anxious	 
 	Feel useless with age	*/ 
	if !inlist(wave,18){	
		recode b21 b22 b25  (1 2 3 = 0 ) (4 5 = 1) (-9/-1 8 9 = . ), gen(fra_psy1 fra_psy2 fra_psy5 )  //positive  1  always,2  often,3  sometimes,4  seldom,5  never
		recode b23 b26 (1 2 3 = 1 ) (4 5 = 0) (-9/-1 8 9 = . ), gen(psy3 psy6) // negative 1  always,2  often,3  sometimes,4  seldom,5  never
	}
	if inlist(wave,18){	
		recode b21 b22 b23 (1 = 5 ) (2 = 4 ) (4 = 2) (5 = 1) (-9/-1 8 9 = . ), gen(psy1 psy2 psy5 )  //positive 
		recode b24 b25 b27 (-1 8 9 = .), gen(psy3 psy4 psy6) // negative 
	}	

	*	Housework at present	
	recode  housework (1 2 =0) (3=0) (-9/-1 8 9 = . ),gen(fra_housework) // 3: never
	
	* Able to use chopsticks to eat
	recode g3 (2=0) (-9/-1 8 9 = . ),gen(fra_chopsticks) 
	
	* Number of steps used to turn around a 360 degree turn without help	
	gen fra_turn = (g14 == 88) if inrange(g14,1,98)


