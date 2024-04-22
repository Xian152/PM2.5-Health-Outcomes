****************************************************************8 to panel 
use "${int}/total_dat08_18_f7_covariances.dta",clear
	gen age= agebase
	
	ren dthdate deathdate
	drop hr*
	drop time* place* namefo* registration* calculation* delayed* naming* repeating* listening* copyf* *_full* orientation* Language* ci* disease*  hunchbacked* 	fra_psy7*
	drop yearin_0 yearin_2 yearin_5
		* Drop variable used for preparation 
		ren wave_baseline waveb
		gen wave = waveb
		global namenew08
		
		* rename baseline "var" to "var_0"
		foreach var of varlist *_f1{
			local a = subinstr("`var'","_f1","",.)
			ren `a' `a'_0
		}
		
		* rename "_f1" to "_1", "_f2" to "_2", "_f3" to "_3", etc. 
		egen wave_max = max(wave_alt)
		local a = wave_max
		forvalues k =1/`a'{
			foreach var of varlist *_f`k'{
				local b = subinstr("`var'","_f`k'","",.)
				ren `b'_f`k' `b'_`k'
			}
		}
		
		foreach var of varlist *_0{
			local e = subinstr("`var'","_0","_",.)
			global namenew08 $namenew08 `e'
		}
		display "$namenew08"

		reshape long $namenew08 ,  i(id) j(followup)

		* rename variable from "var_" to "var"
		foreach var of global namenew08{
			local a = subinstr("`var'","_","",.)
			ren `var' `a'
		}
		foreach var of varlist fra*{
			local a = subinstr("`var'","fra","fra_",.)
			ren `var' `a'
		}		
		
		order id followup

		format *date* %tdY-M-D
		
		* fix the timing mismatch
		count if ((lostdate <= intdate) & intdate!=. ) | ((deathdate <= intdate) & intdate!=. )     //188, 197 if include equal
		gen dateissue = 1  if ((lostdate <= intdate) & intdate!=. ) | ((deathdate <= intdate) & intdate!=. ) 
		
		* drop followup when individuals have been dead 
		label define dth -9 "lost to follow-up in the this survey"  -8" died or lost to follow-up in previous waves" 1" died before this survey" 0"surviving at this survey",modify
		label value dth  dth

		drop  if inlist(dth,-8,-9,1) 

		sort id followup wave waveb
		ren waveb wavebaseline
		order id followup wavebaseline wave 
		

save "${int}/Panel_CLHLS08-18_covariants.dta",replace	


****************************************************************11 to panel 
use "${int}/total_dat11_18_f7_covariances.dta",clear
	gen age= agebase
	
	ren dthdate deathdate
	drop hr*
	drop time* place* namefo* registration* calculation* delayed* naming* repeating* listening* copyf* *_full* orientation* Language* ci* disease*  fra_psy7*
	drop yearin_0 yearin_2 yearin_5
		* Drop variable used for preparation 
		ren wave_baseline waveb
		gen wave = waveb
		global namenew11
		
		* rename baseline "var" to "var_0"
		foreach var of varlist *_f1{
			local a = subinstr("`var'","_f1","",.)
			ren `a' `a'_0
		}
		
		* rename "_f1" to "_1", "_f2" to "_2", "_f3" to "_3", etc. 
		egen wave_max = max(wave_alt)
		local a = wave_max
		forvalues k =1/`a'{
			foreach var of varlist *_f`k'{
				local b = subinstr("`var'","_f`k'","",.)
				ren `b'_f`k' `b'_`k'
			}
		}
		foreach var of varlist *_0{
			local e = subinstr("`var'","_0","_",.)
			global namenew11 $namenew11 `e'
		}
		display "$namenew11"

		reshape long $namenew11 ,  i(id) j(followup)

		* rename variable from "var_" to "var"
		foreach var of global namenew11{
			local a = subinstr("`var'","_","",.)
			ren `var' `a'
		}
		foreach var of varlist fra*{
			local a = subinstr("`var'","fra","fra_",.)
			ren `var' `a'
		}		
		
		order id followup

		format *date* %tdY-M-D
		
		* fix the timing mismatch
		count if ((lostdate <= intdate) & intdate!=. ) | ((deathdate <= intdate) & intdate!=. )     //188, 197 if include equal
		gen dateissue = 1  if ((lostdate <= intdate) & intdate!=. ) | ((deathdate <= intdate) & intdate!=. ) 
		
		* drop followup when individuals have been dead 
		label define dth -9 "lost to follow-up in the this survey"  -8" died or lost to follow-up in previous waves" 1" died before this survey" 0"surviving at this survey",modify
		label value dth  dth

		drop  if inlist(dth,-8,-9,1) 

		sort id followup wave waveb
		ren waveb wavebaseline
		order id followup wavebaseline wave 
		

save "${int}/Panel_CLHLS11-18_covariants.dta",replace	

****************************************************************11 to panel 
use "${int}/total_dat14_18_f7_covariances.dta",clear
	gen age= agebase
	
	ren dthdate deathdate
	drop hr*
	drop time* place* namefo* registration* calculation* delayed* naming* repeating* listening* copyf* *_full* orientation* Language* ci* disease* 
	drop yearin_0 yearin_2 yearin_5
		* Drop variable used for preparation 
		ren wave_baseline waveb
		gen wave = waveb
		global namenew11
		
		* rename baseline "var" to "var_0"
		foreach var of varlist *_f1{
			local a = subinstr("`var'","_f1","",.)
			ren `a' `a'_0
		}
		
		* rename "_f1" to "_1", "_f2" to "_2", "_f3" to "_3", etc. 
		egen wave_max = max(wave_alt)
		local a = wave_max
		forvalues k =1/`a'{
			foreach var of varlist *_f`k'{
				local b = subinstr("`var'","_f`k'","",.)
				ren `b'_f`k' `b'_`k'
			}
		}
		foreach var of varlist *_0{
			local e = subinstr("`var'","_0","_",.)
			global namenew11 $namenew11 `e'
		}
		display "$namenew11"

		reshape long $namenew11 ,  i(id) j(followup)

		* rename variable from "var_" to "var"
		foreach var of global namenew11{
			local a = subinstr("`var'","_","",.)
			ren `var' `a'
		}
		foreach var of varlist fra*{
			local a = subinstr("`var'","fra","fra_",.)
			ren `var' `a'
		}		
		
		order id followup

		format *date* %tdY-M-D
		
		* fix the timing mismatch
		count if ((lostdate <= intdate) & intdate!=. ) | ((deathdate <= intdate) & intdate!=. )     //188, 197 if include equal
		gen dateissue = 1  if ((lostdate <= intdate) & intdate!=. ) | ((deathdate <= intdate) & intdate!=. ) 
		
		* drop followup when individuals have been dead 
		label define dth -9 "lost to follow-up in the this survey"  -8" died or lost to follow-up in previous waves" 1" died before this survey" 0"surviving at this survey",modify
		label value dth  dth

		drop  if inlist(dth,-8,-9,1) 

		sort id followup wave waveb
		ren waveb wavebaseline
		order id followup wavebaseline wave 
		

save "${int}/Panel_CLHLS14-18_covariants.dta",replace	

