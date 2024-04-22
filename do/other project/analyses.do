use "${out}/analyses_frail.dta",clear


* basic did
 gen t = wave == 14|wave ==18
 keep t treat pm* gbcode wave
 duplicates drop
 
 diff pm25_12sum, t(treat) p(t) 
 diff pm25_12mean, t(treat) p(t) 
  
use "${out}/analyses_frail.dta",clear
* basic did
 gen t = wave == 14|wave ==18
 drop total 
 
  drop if frailmissingver1 >5


 //bysort id: gen total= _N
 //keep if total==2
 codebook id // 2,299

 
 diff frailID1, t(treat) p(t)  cov(gender marital coresidence edug trueage residenc smkl alcohol dril pa waterqual)
 diff frailID1, t(treat) p(t)  cov( gender marital coresidence edug trueage residenc smkl alcohol dril pa waterqual)  
  
  
  
use "${out}/analyses_frail.dta",clear
* basic did
 gen t = wave == 14|wave ==18
 drop total 
 
 drop if frailmissingver2 >5


// bysort id: gen total= _N
 //keep if total==2 & wave
 codebook id // 2,299

 
 diff frailID2, t(treat) p(t)  cov(gender marital coresidence edug trueage residenc smkl alcohol dril pa waterqual)
 diff frailID2, t(treat) p(t)  cov( gender marital coresidence edug trueage residenc smkl alcohol dril pa waterqual)  
  
    
  
  
  diff frailID2, t(treat) p(t)  cov(pm25_12sum gender marital coresidence edug trueage residenc smkl alcohol dril pa waterqual)
 diff frailID2, t(treat) p(t)  cov(pm25_12mean gender marital coresidence edug trueage residenc smkl alcohol dril pa waterqual)  

 xx
 diff  mmse, t(treat) p(t)  cov(pm25_12mean gender marital coresidence edug trueage residenc smkl alcohol dril pa)  

