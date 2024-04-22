
****************************************************************8 to 14

tempfile t98

use "${int}/Full_dat08_18_f7_covariances.dta",clear
	keep id id_year wave* monthin dayin trueage* residenc prov gender ethnicity coresidence edu occupation marital edug residence v_bthyr* v_bthmon*  w_* dth* ///
	 censor*_* lost*_* survival_bth*_* survival_bas*_* dthdate lostdate   in* ///  //survival_bas_18 dthdate censor_18 lost_18 survival_bth_18 dth18 lostdate  ///
	 smkl smkl_year alcohol dril pa  fruit veg bean egg fish garlic meat sugar tea saltveg fruit1 veg1 bean1 egg1 fish1 garlic1 meat1 sugar1 tea1 saltveg1 diet_miss diet  ///
	 bathing dressing toileting transferring continence feeding adl_miss adl_sum adl  ///
	 housework fieldwork gardenwork reading pets majong tv socialactivity /*religiousactivity*/ leisure_miss leisure  ///
	 srhealth SBP DBP bpl weight meaheight armlength kneelength *height* *bmi*  ///
	 able* ///
	 year* fra_* age* numchild ablephyreas ablephy mmse* psy* bmi* *height* *weight* bpl srhealth leisure* waterqual adl* pa dril alcohol smkl incomesource nursing* hexp* security* hh_income edug DBP SBP residence marital occupation edu coresidence ethnicity gender agebase interview_baseline id yearin monthin dayin trueage prov residenc *_f1 *_f2 *_f3  
save `t98',replace

use "${int}/Base_dat11_18_f7_covariances.dta",clear
	keep id id_year wave* monthin dayin trueage* residenc prov gender ethnicity coresidence edu occupation marital edug residence v_bthyr* v_bthmon*  w_* dth*  ///
	 censor*_* lost*_* survival_bth*_* survival_bas*_* dthdate lostdate    in* ///  //survival_bas_18 dthdate censor_18 lost_18 survival_bth_18 dth18 lostdate  ///
	 smkl smkl_year alcohol dril pa  fruit veg bean egg fish garlic meat sugar tea saltveg fruit1 veg1 bean1 egg1 fish1 garlic1 meat1 sugar1 tea1 saltveg1 diet_miss diet  ///
	 bathing dressing toileting transferring continence feeding adl_miss adl_sum adl  ///
	 housework fieldwork gardenwork reading pets majong tv socialactivity /*religiousactivity*/ leisure_miss leisure  ///
	 srhealth SBP DBP bpl weight meaheight armlength kneelength hunchbacked *height* *bmi*  ///
	 able* ///
	biomass year* fra_* age*  ablephyreas ablephy hearingloss mmse* psy* bmi* hunchbacked *height* *weight* bpl srhealth leisure* waterqual adl* pa dril alcohol smkl incomesource nursing* hexp* security* hh_income edug DBP SBP residence marital occupation edu coresidence ethnicity gender agebase  interview_baseline id yearin monthin dayin trueage prov residenc *_f1	*_f2	 
	append using `t98',force
save `t98',replace

use "${int}/Base_dat14_18_f7_covariances.dta",clear
	keep id id_year wave* monthin dayin trueage* residenc prov gender ethnicity coresidence edu occupation marital edug residence v_bthyr* v_bthmon*  w_* dth*  ///
	 censor*_* lost*_* survival_bth*_* survival_bas*_* dthdate lostdate    in* ///  //survival_bas_18 dthdate censor_18 lost_18 survival_bth_18 dth18 lostdate  ///
	 smkl smkl_year alcohol dril pa  fruit veg bean egg fish garlic meat sugar tea saltveg fruit1 veg1 bean1 egg1 fish1 garlic1 meat1 sugar1 tea1 saltveg1 diet_miss diet  ///
	 bathing dressing toileting transferring continence feeding adl_miss adl_sum adl  ///
	 housework fieldwork gardenwork reading pets majong tv socialactivity /*religiousactivity*/ leisure_miss leisure  ///
	 srhealth SBP DBP bpl weight meaheight armlength kneelength hunchbacked *height* *bmi*  ///
	 able* ///
	biomass year* fra_* age* numchild ablephyreas ablephy hearingloss mmse* psy* bmi* hunchbacked *height* *weight* bpl srhealth leisure* waterqual adl* pa dril alcohol smkl incomesource nursing* hexp* security* hh_income edug DBP SBP residence marital occupation edu coresidence ethnicity gender agebase  interview_baseline id yearin monthin dayin trueage prov residenc *_f1	 
	append using `t98',force
save "${int}/total_dat08_18_f7_covariances.dta",replace

//	 hypertension diabetes heartdisea strokecvd copd tb cataract glaucoma cancer prostatetumor ulcer parkinson bedsore arthritis disease_sum disease  ///

****************************************************************11 to 14

tempfile t98

use "${int}/Full_dat11_18_f7_covariances.dta",clear
	keep id id_year wave* monthin dayin trueage* residenc prov gender ethnicity coresidence edu occupation marital edug residence v_bthyr* v_bthmon*  w_* dth*  ///
	 censor*_* lost*_* survival_bth*_* survival_bas*_* dthdate lostdate    in* ///  //survival_bas_18 dthdate censor_18 lost_18 survival_bth_18 dth18 lostdate  ///
	 smkl smkl_year alcohol dril pa  fruit veg bean egg fish garlic meat sugar tea saltveg fruit1 veg1 bean1 egg1 fish1 garlic1 meat1 sugar1 tea1 saltveg1 diet_miss diet  ///
	 bathing dressing toileting transferring continence feeding adl_miss adl_sum adl  ///
	 housework fieldwork gardenwork reading pets majong tv socialactivity /*religiousactivity*/ leisure_miss leisure  ///
	 srhealth SBP DBP bpl weight meaheight armlength kneelength hunchbacked *height* *bmi*  ///
	 able* ///
	biomass year* fra_* age*  ablephyreas ablephy hearingloss mmse* psy* bmi* hunchbacked *height* *weight* bpl srhealth leisure* waterqual adl* pa dril alcohol smkl incomesource nursing* hexp* security* hh_income edug DBP SBP residence marital occupation edu coresidence ethnicity gender agebase  interview_baseline id yearin monthin dayin trueage prov residenc *_f1	*_f2	 
save `t98',replace

use "${int}/Base_dat14_18_f7_covariances.dta",clear
	keep id id_year wave* monthin dayin trueage* residenc prov gender ethnicity coresidence edu occupation marital edug residence v_bthyr* v_bthmon*  w_* dth*  ///
	 censor*_* lost*_* survival_bth*_* survival_bas*_* dthdate lostdate    in* ///  //survival_bas_18 dthdate censor_18 lost_18 survival_bth_18 dth18 lostdate  ///
	 smkl smkl_year alcohol dril pa  fruit veg bean egg fish garlic meat sugar tea saltveg fruit1 veg1 bean1 egg1 fish1 garlic1 meat1 sugar1 tea1 saltveg1 diet_miss diet  ///
	 bathing dressing toileting transferring continence feeding adl_miss adl_sum adl  ///
	 housework fieldwork gardenwork reading pets majong tv socialactivity /*religiousactivity*/ leisure_miss leisure  ///
	 srhealth SBP DBP bpl weight meaheight armlength kneelength hunchbacked *height* *bmi*  ///
	 able* ///
	biomass year* fra_* age* numchild ablephyreas ablephy hearingloss mmse* psy* bmi* hunchbacked *height* *weight* bpl srhealth leisure* waterqual adl* pa dril alcohol smkl incomesource nursing* hexp* security* hh_income edug DBP SBP residence marital occupation edu coresidence ethnicity gender agebase  interview_baseline id yearin monthin dayin trueage prov residenc *_f1	 
	append using `t98',force
save "${int}/total_dat11_18_f7_covariances.dta",replace


****************************************************************14

use "${int}/Full_dat14_18_f7_covariances.dta",clear
	keep id id_year wave* monthin dayin trueage* residenc prov gender ethnicity coresidence edu occupation marital edug residence v_bthyr* v_bthmon*  w_* dth*  ///
	 censor*_* lost*_* survival_bth*_* survival_bas*_* dthdate lostdate    in* ///  //survival_bas_18 dthdate censor_18 lost_18 survival_bth_18 dth18 lostdate  ///
	 smkl smkl_year alcohol dril pa  fruit veg bean egg fish garlic meat sugar tea saltveg fruit1 veg1 bean1 egg1 fish1 garlic1 meat1 sugar1 tea1 saltveg1 diet_miss diet  ///
	 bathing dressing toileting transferring continence feeding adl_miss adl_sum adl  ///
	 housework fieldwork gardenwork reading pets majong tv socialactivity /*religiousactivity*/ leisure_miss leisure  ///
	 srhealth SBP DBP bpl weight meaheight armlength kneelength hunchbacked *height* *bmi*  ///
	 able* ///
	biomass year* fra_* age* numchild ablephyreas ablephy hearingloss mmse* psy* bmi* hunchbacked *height* *weight* bpl srhealth leisure* waterqual adl* pa dril alcohol smkl incomesource nursing* hexp* security* hh_income edug DBP SBP residence marital occupation edu coresidence ethnicity gender agebase  interview_baseline id yearin monthin dayin trueage prov residenc *_f1	 
save "${int}/total_dat14_18_f7_covariances.dta",replace


