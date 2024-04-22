local name 2018noweight 2018weight1 2018weight2 2015noweight 2015weight1 2015weight2 2013noweight 2013weight1 2013weight2 2010noweight 2010oweight2 2007noweight 2007weight1 2007weight2

foreach m of local name{
clear
import excel "C:\Users\zhaosheng\Dropbox\PC\Documents\prevalence07to18.xlsx", sheet("`m'") firstrow
save "C:\Users\zhaosheng\Dropbox\PC\Documents\county_pch\\`m'",replace
}

local name2018 2018noweight 2018weight1 2018weight2
local name2015 2015noweight 2015weight1 2015weight2 
local name2013 2013noweight 2013weight1 2013weight2
local name2010 2010noweight 2010oweight2
local name2007 2007noweight 2007weight1
local year 2007 2010 2013 2015 2018
foreach y of local year{
	foreach m of local name`y'{
		clear
		use "C:\Users\zhaosheng\Dropbox\PC\Documents\county_pch\\`m'"
		gen year = `y'
		save "C:\Users\zhaosheng\Dropbox\PC\Documents\county_pch\\`m'",replace
	}
}

local weight1name 2018weight1 2015weight1 2013weight1 2007weight1
use "C:\Users\zhaosheng\Dropbox\PC\Documents\county_pch\2010oweight2.dta"
foreach m of local weight1name{
	append using "C:\Users\zhaosheng\Dropbox\PC\Documents\county_pch\\`m'"
	*merge 1:1 dspcode using "C:\Users\zhaosheng\Dropbox\PC\Documents\county_pch\\`m'"
	*drop _merge
}
destring dspcode, replace
merge m:1 dspcode using "C:\Users\zhaosheng\Dropbox\PC\Documents\county_pch\da_code"
drop _merge
gen time0 = 2011 if batch == 1
replace time0 = 2012 if batch == 2
replace time0 = 2014 if batch == 3
replace time0 = 2017 if batch == 4
gen time_window = year - time0 if batch != .

gen treated = 0
replace treated = 1 if time_window > 0 & time_window != .
gen treated_g = 0
replace treated_g = 1 if batch != .
****************************************************************************
*simple did
local var_name height weight BMI waist FBG HbA1c age currentsmoking dailysmoking smokingamount quitsmoking shsmoking drinking12 drinking30 hazarddrinking harmdrinking lowvegfru highredmeat lackphysical usualexercise neverexercise overweight obesity overweightint obesityint centralobesity centralobesityint sbp dbp hypertension awarehypertension treathypertension controlhypertension diabetes awarediabetes treatdiabetes drugdiabetes controldiabetes insurance
foreach n of local var_name{
	preserve
	drop if time_window !=. & time_window > 0
	sort treated_g year
	egen av_dk = mean(`n'), by (treated_g year)
	*gen av_dk1 = av_dk if treated_g == 1
	*gen av_dk2 = av_dk if treated_g == 0
	duplicates drop treated_g year, force
	keep av_dk treated_g year
	drop if year == 2018
	reshape wide av_dk, i(year) j(treated_g)
	twoway line av_dk1 av_dk0 year, title("`n'")
	graph save "Graph" "C:\Users\zhaosheng\Dropbox\PC\Documents\county_pch\\`n'.gph", replace
	restore
}

*good: waist overweightint lowvegfru controldiabetes centralobesityint? centralobesity 
****************************************************************************
****************************************************************************
tostring dspcode, replace
gen province = substr(dspcode,1,2)
destring dspcode, replace
destring province, replace
*state did
foreach n of local var_name{
	preserve
	keep if province == 33|province == 34|province == 42
	drop if time_window !=. & time_window > 0
	gen pr_tg = province *100 + treated_g
	sort pr_tg year
	egen av_dk = mean(`n'), by (pr_tg year)
	*gen av_dk1 = av_dk if treated_g == 1
	*gen av_dk2 = av_dk if treated_g == 0
	duplicates drop pr_tg year, force
	drop if year == 2018
	keep av_dk pr_tg year 
	reshape wide av_dk, i(year) j(pr_tg)
	twoway line av_dk* year, title("`n'")
	graph save "Graph" "C:\Users\zhaosheng\Dropbox\PC\Documents\county_pch\province pretrend\\`n'.gph", replace
	restore
}

*good: usualexercise, 
****************************************************************************
****************************************************************************
*later-treated did
local batch_state 1 2 3
foreach n of local var_name{
	foreach nn of local batch_state{
		preserve
		drop if time_window !=. & time_window > 0
		keep if batch != .
		keep if batch >= `nn'
		gen later_2012 = 0
		replace later_2012 = 1 if batch != `nn'
		sort later_2012 time_window
		egen av_dk = mean(`n'), by (later_2012 time_window)
		duplicates drop later_2012 time_window, force
		keep av_dk later_2012 time_window 
		reshape wide av_dk, i(time_window) j(later_2012)
		twoway line av_dk1 av_dk0 time_window, title("`n'`nn'")
		graph save "Graph" "C:\Users\zhaosheng\Dropbox\PC\Documents\county_pch\later pretrend\\`n'`nn'.gph", replace
		restore
	}
}
*good: waist, shsmoking, overweightint, highredmeat
****************************************************************************
****************************************************************************
*simple did: before 2010
local var_name height weight BMI waist FBG HbA1c age currentsmoking dailysmoking smokingamount quitsmoking shsmoking drinking12 drinking30 hazarddrinking harmdrinking lowvegfru highredmeat lackphysical usualexercise neverexercise overweight obesity overweightint obesityint centralobesity centralobesityint sbp dbp hypertension awarehypertension treathypertension controlhypertension diabetes awarediabetes treatdiabetes drugdiabetes controldiabetes insurance
foreach n of local var_name{
	preserve
	drop if time_window !=. & time_window > 0
	sort treated_g year
	egen av_dk = mean(`n'), by (treated_g year)
	*gen av_dk1 = av_dk if treated_g == 1
	*gen av_dk2 = av_dk if treated_g == 0
	duplicates drop treated_g year, force
	keep av_dk treated_g year
	drop if year > 2010
	reshape wide av_dk, i(year) j(treated_g)
	twoway line av_dk1 av_dk0 year, title("`n'")
	graph save "Graph" "C:\Users\zhaosheng\Dropbox\PC\Documents\county_pch\pre2010 pretrend\\`n'.gph", replace
	restore
}

*good: waist? quitsmoking? overweight? obesityint? neverexercise? dailysmoking? controlhypertension? awarehypertension
*compare this to simple did, 2010 seems to be a turning point... 
****************************************************************************
****************************************************************************
*simple did: effect graph
local var_name height weight BMI waist FBG HbA1c age currentsmoking dailysmoking smokingamount quitsmoking shsmoking drinking12 drinking30 hazarddrinking harmdrinking lowvegfru highredmeat lackphysical usualexercise neverexercise overweight obesity overweightint obesityint centralobesity centralobesityint sbp dbp hypertension awarehypertension treathypertension controlhypertension diabetes awarediabetes treatdiabetes drugdiabetes controldiabetes insurance
foreach n of local var_name{
	preserve
	drop if time_window !=. & time_window < 0
	sort treated_g year
	egen av_dk = mean(`n'), by (treated_g year)
	*gen av_dk1 = av_dk if treated_g == 1
	*gen av_dk2 = av_dk if treated_g == 0
	duplicates drop treated_g year, force
	keep av_dk treated_g year
	drop if year > 2010
	reshape wide av_dk, i(year) j(treated_g)
	twoway line av_dk1 av_dk0 year, title("`n'")
	graph save "Graph" "C:\Users\zhaosheng\Dropbox\PC\Documents\county_pch\pre2010 pretrend\\`n'.gph", replace
	restore
}

*good: waist? quitsmoking? overweight? obesityint? neverexercise? dailysmoking? controlhypertension? awarehypertension
*compare this to simple did, 2010 seems to be a turning point... then predate seems to be a good idea, while staggered did might not work
****************************************************************************
********start sc did********************************************************
preserve
keep dspcode waist quitsmoking shsmoking neverexercise obesity obesityint overweightint overweight awarehypertension controlhypertension centralobesity centralobesityint treated_g year 
local var_name1 dspcode waist quitsmoking shsmoking neverexercise obesity obesityint overweightint overweight awarehypertension controlhypertension centralobesity centralobesityint
gen treated_2010 = 0
replace treated_2010 = 1 if year > 2010 & treated_g == 1
sort treated_g
foreach m of local var_name1{
	egen av_kpi = mean(`m'), by (treated_g year)
	replace `m' = av_kpi if treated_g == 1
	drop av_kpi
}
duplicates drop
sdid obesity dspcode year treated_2010, vce(placebo)
restore
********start sc did********************************************************

*obesity, controlhypertension, shsmoking, smokingamount, waist
sdid obesity dspcode year treated, vce(placebo) reps(1000)
sdid controlhypertension dspcode year treated, vce(placebo) reps(1000)
sdid shsmoking dspcode year treated, vce(placebo) reps(1000)
sdid smokingamount dspcode year treated, vce(placebo) reps(1000)
sdid waist dspcode year treated, vce(placebo) reps(1000)

preserve
drop if batch == 1

gen tr10 = 0
replace tr10 = 1 if treated_g == 1&year > 2010
sdid obesity dspcode year tr10, vce(bootstrap)
sdid controlhypertension dspcode year tr10, vce(bootstrap)
sdid shsmoking dspcode year tr10, vce(bootstrap)
sdid smokingamount dspcode year tr10, vce(bootstrap)
sdid waist dspcode year tr10, vce(bootstrap)
sdid quitsmoking dspcode year tr10, vce(bootstrap)
sdid overweight dspcode year tr10, vce(bootstrap)
sdid obesityint dspcode year tr10, vce(bootstrap)
sdid neverexercise dspcode year tr10, vce(bootstrap)
sdid controlhypertension dspcode year tr10, vce(bootstrap)
sdid awarehypertension dspcode year tr10, vce(bootstrap)
restore

preserve
drop if year == 2007| year==2015
gen tr10 = 0
replace tr10 = 1 if treated_g == 1&year > 2010
sdid diabetes dspcode year treated, vce(bootstrap)
sdid awarediabetes dspcode year treated, vce(bootstrap)
sdid treatdiabetes dspcode year treated, vce(bootstrap)
sdid drugdiabetes dspcode year treated, vce(bootstrap)
sdid controldiabetes dspcode year treated, vce(bootstrap)
restore

preserve
drop if year == 2007
gen tr10 = 0
replace tr10 = 1 if treated_g == 1&year > 2010
sdid hazarddrinking dspcode year treated, vce(bootstrap) *
sdid harmdrinking dspcode year treated, vce(bootstrap)
sdid lowvegfru dspcode year treated, vce(bootstrap) *
sdid highredmeat dspcode year treated, vce(bootstrap)
sdid sbp dspcode year treated, vce(bootstrap)
sdid dbp dspcode year treated, vce(bootstrap) *
sdid insurance dspcode year treated, vce(bootstrap) *
restore
*waist? quitsmoking? overweight? obesityint? neverexercise? dailysmoking? controlhypertension? awarehypertension
***************************************************************************


sdid height dspcode year treated, vce(bootstrap) graph
sdid weight dspcode year treated, vce(bootstrap) graph
sdid waist dspcode year treated, vce(bootstrap) graph
sdid currentsmoking dspcode year treated, vce(bootstrap) graph
sdid dailysmoking dspcode year treated, vce(bootstrap) graph
*还行
sdid smokingamount dspcode year treated, vce(bootstrap) graph
sdid quitsmoking dspcode year treated, vce(bootstrap) graph
sdid shsmoking dspcode year treated, vce(bootstrap) graph
sdid drinking12 dspcode year treated, vce(bootstrap) graph
sdid drinking30 dspcode year treated, vce(bootstrap) graph
preserve
drop if year == 2007
sdid hazarddrinking dspcode year treated, vce(bootstrap) graph
sdid harmdrinking dspcode year treated, vce(bootstrap) graph
sdid lowvegfru dspcode year treated, vce(bootstrap) graph
sdid highredmeat dspcode year treated, vce(bootstrap) graph
restore

sdid lackphysical dspcode year treated, vce(bootstrap) graph
sdid usualexercise dspcode year treated, vce(bootstrap) graph
sdid neverexercise dspcode year treated, vce(bootstrap) graph
sdid overweight dspcode year treated, vce(bootstrap) graph
**
sdid obesity dspcode year treated, vce(bootstrap) graph
sdid overweightint dspcode year treated, vce(bootstrap) graph
sdid obesityint dspcode year treated, vce(bootstrap) graph
*
sdid centralobesity dspcode year treated, vce(bootstrap) graph
*
sdid centralobesityint dspcode year treated, vce(bootstrap) graph
sdid sbp dspcode year treated, vce(bootstrap) graph
sdid dbp dspcode year treated, vce(bootstrap) graph
sdid hypertension dspcode year treated, vce(bootstrap) graph
sdid awarehypertension dspcode year treated, vce(bootstrap) graph
sdid treathypertension dspcode year treated, vce(bootstrap) graph
*还行
sdid controlhypertension dspcode year treated, vce(bootstrap) graph
preserve
drop if year == 2007|year == 2015
sdid diabetes dspcode year treated, vce(bootstrap) graph
sdid awarediabetes dspcode year treated, vce(bootstrap) graph
sdid treatdiabetes dspcode year treated, vce(bootstrap) graph
sdid drugdiabetes dspcode year treated, vce(bootstrap) graph
sdid insurance dspcode year treated, vce(bootstrap) graph
restore
sdid men dspcode year treated, vce(bootstrap) graph
*********************
*predate tp 2010
preserve
gen tr10 = 0
replace tr10 = 1 if treated_g == 1&year > 2010
replace treated = tr10

*
sdid height dspcode year treated, vce(bootstrap) reps(500) graph
sdid weight dspcode year treated, vce(bootstrap) graph
sdid waist dspcode year treated, vce(bootstrap) reps(500) graph
sdid currentsmoking dspcode year treated, vce(bootstrap) reps(500) graph
sdid dailysmoking dspcode year treated, vce(bootstrap) reps(500) graph
sdid smokingamount dspcode year treated, vce(bootstrap) reps(500) graph
sdid quitsmoking dspcode year treated, vce(bootstrap) reps(500) graph
sdid shsmoking dspcode year treated, vce(bootstrap) reps(500) graph
sdid drinking12 dspcode year treated, vce(bootstrap) graph
*
sdid drinking30 dspcode year treated, vce(bootstrap) reps(500) graph
sdid lackphysical dspcode year treated, vce(bootstrap) graph
*
sdid usualexercise dspcode year treated, vce(bootstrap) graph
*
sdid neverexercise dspcode year treated, vce(bootstrap) graph
sdid overweight dspcode year treated, vce(bootstrap) reps(500) graph
**
sdid obesity dspcode year treated, vce(bootstrap) reps(500) graph
sdid overweightint dspcode year treated, vce(bootstrap) graph
*
sdid obesityint dspcode year treated, vce(bootstrap) graph
*
sdid centralobesity dspcode year treated, vce(bootstrap) reps(500) graph
sdid sbp dspcode year treated, vce(bootstrap) graph
sdid dbp dspcode year treated, vce(bootstrap) graph

drop if year == 2007
sdid hazarddrinking dspcode year treated, vce(bootstrap) graph
*
sdid harmdrinking dspcode year treated, vce(bootstrap) graph
sdid lowvegfru dspcode year treated, vce(bootstrap) graph
sdid highredmeat dspcode year treated, vce(bootstrap) graph

drop if year == 2007|year == 2015
sdid diabetes dspcode year treated, vce(bootstrap) graph
sdid awarediabetes dspcode year treated, vce(bootstrap) graph
sdid treatdiabetes dspcode year treated, vce(bootstrap) graph
sdid drugdiabetes dspcode year treated, vce(bootstrap) graph
sdid insurance dspcode year treated, vce(bootstrap) graph
restore
***************************************************************
*untreated but will be treated
preserve
drop if treated == 1
gen tr10 = 0
replace tr10 = 1 if treated_g == 1&year > 2010
replace treated = tr10

*
sdid height dspcode year treated, vce(bootstrap) reps(500) graph
sdid weight dspcode year treated, vce(bootstrap) graph
sdid waist dspcode year treated, vce(bootstrap) reps(500) graph
sdid currentsmoking dspcode year treated, vce(bootstrap) reps(500) graph
sdid dailysmoking dspcode year treated, vce(bootstrap) reps(500) graph
sdid smokingamount dspcode year treated, vce(bootstrap) reps(500) graph
sdid quitsmoking dspcode year treated, vce(bootstrap) reps(500) graph
sdid shsmoking dspcode year treated, vce(bootstrap) reps(500) graph
sdid drinking12 dspcode year treated, vce(bootstrap) graph
*
sdid drinking30 dspcode year treated, vce(bootstrap) reps(500) graph
sdid lackphysical dspcode year treated, vce(bootstrap) graph
*
sdid usualexercise dspcode year treated, vce(bootstrap) graph
*
sdid neverexercise dspcode year treated, vce(bootstrap) graph
sdid overweight dspcode year treated, vce(bootstrap) reps(500) graph
**
sdid obesity dspcode year treated, vce(bootstrap) reps(500) graph
sdid overweightint dspcode year treated, vce(bootstrap) graph
*
sdid obesityint dspcode year treated, vce(bootstrap) graph
*
sdid centralobesity dspcode year treated, vce(bootstrap) reps(500) graph
sdid sbp dspcode year treated, vce(bootstrap) graph
sdid dbp dspcode year treated, vce(bootstrap) graph

drop if year == 2007
sdid hazarddrinking dspcode year treated, vce(bootstrap) graph
*
sdid harmdrinking dspcode year treated, vce(bootstrap) graph
sdid lowvegfru dspcode year treated, vce(bootstrap) graph
sdid highredmeat dspcode year treated, vce(bootstrap) graph

drop if year == 2007|year == 2015
sdid diabetes dspcode year treated, vce(bootstrap) graph
sdid awarediabetes dspcode year treated, vce(bootstrap) graph
sdid treatdiabetes dspcode year treated, vce(bootstrap) graph
sdid drugdiabetes dspcode year treated, vce(bootstrap) graph
sdid insurance dspcode year treated, vce(bootstrap) graph
restore

***************************************************************
*first wave
preserve
drop if treated_g == 1&batch!=1

sdid height dspcode year treated, vce(bootstrap) reps(500) graph
sdid weight dspcode year treated, vce(bootstrap) graph
*
sdid waist dspcode year treated, vce(bootstrap) reps(500) graph
sdid currentsmoking dspcode year treated, vce(bootstrap) reps(500) graph
sdid dailysmoking dspcode year treated, vce(bootstrap) reps(500) graph
sdid smokingamount dspcode year treated, vce(bootstrap) reps(500) graph
sdid quitsmoking dspcode year treated, vce(bootstrap) reps(500) graph
*
sdid shsmoking dspcode year treated, vce(bootstrap) reps(500) graph
sdid drinking12 dspcode year treated, vce(bootstrap) graph
sdid drinking30 dspcode year treated, vce(bootstrap) reps(500) graph
sdid lackphysical dspcode year treated, vce(bootstrap) graph
sdid usualexercise dspcode year treated, vce(bootstrap) graph
sdid neverexercise dspcode year treated, vce(bootstrap) graph
sdid overweight dspcode year treated, vce(bootstrap) reps(500) graph
**
sdid obesity dspcode year treated, vce(bootstrap) reps(500) graph
sdid overweightint dspcode year treated, vce(bootstrap) graph
*
sdid obesityint dspcode year treated, vce(bootstrap) graph
***
sdid centralobesity dspcode year treated, vce(bootstrap) reps(500) graph
sdid sbp dspcode year treated, vce(bootstrap) graph
*
sdid dbp dspcode year treated, vce(bootstrap) graph

restore
***************************************************************
*first wave: long run
preserve
drop if treated_g == 1&batch!=1
drop if year < 2018&year>2010

sdid height dspcode year treated, vce(bootstrap) reps(500) graph
sdid weight dspcode year treated, vce(bootstrap) graph
*
sdid waist dspcode year treated, vce(bootstrap) reps(500) graph
sdid currentsmoking dspcode year treated, vce(bootstrap) reps(500) graph
sdid dailysmoking dspcode year treated, vce(bootstrap) reps(500) graph
sdid smokingamount dspcode year treated, vce(bootstrap) reps(500) graph
sdid quitsmoking dspcode year treated, vce(bootstrap) reps(500) graph
*
sdid shsmoking dspcode year treated, vce(bootstrap) reps(500) graph
sdid drinking12 dspcode year treated, vce(bootstrap) graph
sdid drinking30 dspcode year treated, vce(bootstrap) reps(500) graph
sdid lackphysical dspcode year treated, vce(bootstrap) graph
sdid usualexercise dspcode year treated, vce(bootstrap) graph
sdid neverexercise dspcode year treated, vce(bootstrap) graph
*
sdid overweight dspcode year treated, vce(bootstrap) reps(500) graph
**
sdid obesity dspcode year treated, vce(bootstrap) reps(500) graph
sdid overweightint dspcode year treated, vce(bootstrap) graph
*
sdid obesityint dspcode year treated, vce(bootstrap) graph
***
sdid centralobesity dspcode year treated, vce(bootstrap) reps(500) graph
sdid sbp dspcode year treated, vce(bootstrap) graph
*
sdid dbp dspcode year treated, vce(bootstrap) graph

restore
***************************************************************
*first wave: short run
preserve
*drop if treated_g == 1&batch!=1
drop if year >= 2014

sdid height dspcode year treated, vce(bootstrap) reps(500) graph
sdid weight dspcode year treated, vce(bootstrap) graph
*
sdid waist dspcode year treated, vce(bootstrap) reps(500) graph
sdid currentsmoking dspcode year treated, vce(bootstrap) reps(500) graph
sdid dailysmoking dspcode year treated, vce(bootstrap) reps(500) graph
sdid smokingamount dspcode year treated, vce(bootstrap) reps(500) graph
sdid quitsmoking dspcode year treated, vce(bootstrap) reps(500) graph
sdid shsmoking dspcode year treated, vce(bootstrap) reps(500) graph
sdid drinking12 dspcode year treated, vce(bootstrap) graph
sdid drinking30 dspcode year treated, vce(bootstrap) reps(500) graph
sdid lackphysical dspcode year treated, vce(bootstrap) graph
sdid usualexercise dspcode year treated, vce(bootstrap) graph
sdid neverexercise dspcode year treated, vce(bootstrap) graph
sdid overweight dspcode year treated, vce(bootstrap) reps(500) graph
sdid obesity dspcode year treated, vce(bootstrap) reps(500) graph
sdid overweightint dspcode year treated, vce(bootstrap) graph
sdid obesityint dspcode year treated, vce(bootstrap) graph
***
sdid centralobesity dspcode year treated, vce(bootstrap) reps(500) graph
sdid sbp dspcode year treated, vce(bootstrap) graph
*
sdid dbp dspcode year treated, vce(bootstrap) graph

restore