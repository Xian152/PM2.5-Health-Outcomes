import excel "C:\Users\zhaosheng\Dropbox\PC\Documents\county_pch\gdp_pc.xlsx", sheet("Sheet1") firstrow clear
destring gdp_pc, replace
save "C:\Users\zhaosheng\Dropbox\PC\Documents\county_pch\gdp_pc.dta", replace

import excel "C:\Users\zhaosheng\Dropbox\PC\Documents\county_pch\data.xlsx", sheet("Sheet1") firstrow clear
drop gdp_pc second_ind
merge 1:1 dspcode year using "C:\Users\zhaosheng\Dropbox\PC\Documents\county_pch\gdp_pc"
drop _merge
save "C:\Users\zhaosheng\Dropbox\PC\Documents\county_pch\covariate.dta", replace

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

merge 1:1 dspcode year using"C:\Users\zhaosheng\Dropbox\PC\Documents\county_pch\covariate.dta"
gen log_gdp_pc = log(gdp_pc)

*11,12年短期
preserve
keep if year == 2007|year == 2010|year == 2013
drop if time0 == 2014|time0 == 2017
sdid smokingamount dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph
sdid shsmoking dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph
sdid drinking30 dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph
*
sdid usualexercise dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph reps(500)
sdid obesity dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph
*
sdid centralobesityint dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph reps(500)
sdid controlhypertension dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph
sdid treathypertension dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph
*
sdid awarehypertension dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph reps(500)
sdid hypertension dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph
restore

*11,12年中期
preserve
keep if year == 2007|year == 2010|year == 2015
drop if time0 == 2014|time0 == 2017
sdid smokingamount dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph
sdid shsmoking dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph
sdid drinking30 dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph
*
sdid usualexercise dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph reps(500)
*
sdid obesity dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph reps(500)
*
sdid centralobesityint dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph reps(500)
*
sdid controlhypertension dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph reps(500)
sdid treathypertension dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph
sdid awarehypertension dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph
*
sdid hypertension dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph reps(500)
restore

*11,12年长期
preserve
keep if year == 2007|year == 2010|year == 2018
drop if time0 == 2014|time0 == 2017
sdid smokingamount dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph reps(500)
sdid currentsmoking dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph reps(500)
*
sdid shsmoking dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph reps(500)
*
sdid drinking30 dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph reps(500)
sdid usualexercise dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph
*
sdid obesity dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph reps(500)
sdid centralobesityint dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph
sdid controlhypertension dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph
sdid treathypertension dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph
*
sdid awarehypertension dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph reps(500)
*
sdid hypertension dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph reps(500)
restore

*14年短期
preserve
keep if year == 2007|year == 2010|year == 2013|year == 2015
drop if time0 == 2011|time0 == 2012|time0 == 2017
sdid smokingamount dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph
sdid shsmoking dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph
sdid drinking30 dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph
sdid usualexercise dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph
*
sdid obesity dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph reps(500)
*
sdid centralobesityint dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph reps(500)
*
sdid controlhypertension dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph reps(500)
sdid treathypertension dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph
*
sdid awarehypertension dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph reps(500)
sdid hypertension dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph
restore

*14年中期
preserve
keep if year == 2007|year == 2010|year == 2013|year == 2018
drop if time0 == 2011|time0 == 2012|time0 == 2017
*
sdid smokingamount dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph reps(500)
sdid shsmoking dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph
*
sdid drinking30 dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph reps(500)
*
sdid usualexercise dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph reps(500)
sdid obesity dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph
sdid centralobesityint dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph
sdid controlhypertension dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph
*
sdid treathypertension dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph reps(500)
*
sdid awarehypertension dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph reps(500)
*
sdid hypertension dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph reps(500)
restore

*17年短期
preserve
drop if time0 == 2011|time0 == 2012|time0 == 2014
*
sdid smokingamount dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph reps(500)
sdid shsmoking dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph
sdid drinking30 dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph
sdid usualexercise dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph
*
sdid obesity dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph reps(500)
sdid centralobesityint dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph
sdid controlhypertension dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph
*
sdid treathypertension dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph reps(500)
*
sdid awarehypertension dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph reps(500)
sdid hypertension dspcode year treated, vce(bootstrap) covariates(sex prop_65 log_gdp_pc, projected) graph
restore










