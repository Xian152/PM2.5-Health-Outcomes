/**************************************************************
  air-quality and functioning
***************************************************************
Overview:	Causal inference of air-quality and functioning (adl,iadl, physical function, frailty)

Created:	2022/04/15 by Xian
Updated: 	
			Add IV regression analyses  2022/08/10 by Xian
			Add DID & SDID analyses
***********************************************/
version 16.0
clear all
set matsize 3956, permanent
set more off, permanent
set maxvar 32767, permanent
capture log close
sca drop _all
matrix drop _all
macro drop _all

**********************************************
*** Define main root paths: set one paths ***
**********************************************

//NOTE FOR WINDOWS USERS : use "/" instead of "\" in your paths

//global root "C:\Users\wb500886\WBG\Sven Neelsen - World Bank\MEASURE UHC DATA"
global root "/Users/x152/Library/CloudStorage/Box-Box/HALSA-Healthy Aging - CLHLS/P23 Environmental Health-Causal/Analyses"

* Define path for data sources
global SOURCE "/Users/x152/Library/CloudStorage/Box-Box/HALSA-Healthy Aging - CLHLS/A03 Recoded Data and Code/1 Stata/Recoded Data/"


* Define path for data sources
global raw "${root}/raw"

* Define path for output table & fig
global out "${root}/out"

* Define path for output data
global outdata "${root}/outdata"

* Define path for INTERMEDIATE
global int "${root}/int"

* Define path for do-files
global do "${root}/do"

**********************************************
*** package installation ***
**********************************************	
* figure style
net install cleanplots, from("https://tdmize.github.io/data/cleanplots")
set scheme cleanplots, perm

* plot
ssc install binscatterhist, replace
net install superscatter.pkgfrom(http://digital.cgdev.org/doc/stata/MO/Misc/)
net install gr0002_3.pkgfrom(http://digital.cgdev.org/doc/stata/MO/Misc/) 

* TWFE
ssc install reghdfe ,replace
* Install ftools (remove program if it existed previously)
cap ado uninstall ftools
net install ftools, from("https://raw.githubusercontent.com/sergiocorreia/ftools/master/src/")

* Install reghdfe
cap ado uninstall reghdfe
net install reghdfe, from("https://raw.githubusercontent.com/sergiocorreia/reghdfe/master/src/")

* Install ivreg2, the core package
cap ado uninstall ivreg2
ssc install ivreg2

* Finally, install this package
cap ado uninstall ivreghdfe
net install ivreghdfe, from(https://raw.githubusercontent.com/sergiocorreia/ivreghdfe/master/src/)

* IV
ssc install ivreghdfe,replace
ssc install  ftools,replace
ssc install reghdfe,replace
ssc install ivreg2,replace
ssc install ranktest,replace

* RD
net install rdrobust, from(https://raw.githubusercontent.com/rdpackages/rdrobust/master/stata) replace
net install rdlocrand, from(https://raw.githubusercontent.com/rdpackages/rdlocrand/master/stata) replace
net install rddensity, from(https://raw.githubusercontent.com/rdpackages/rddensity/master/stata) replace
net install rdpower, from(https://raw.githubusercontent.com/rdpackages/rdpower/master/stata) replace
net install lpdensity, from(http://fmwww.bc.edu/RePEc/bocode/l) replace

* SDID
ssc install sdid,replace

***************************
*******************
*** Data Import and merging ***
**********************************************	
* data cleaning progress 
	* Air quality yearly
	do "${do}/0.5_environmental.do"
	* CLHLS
	do "${do}/1_generate_baseline_covariants.do"
	do "${do}/2_generate_followup05-18_covariants.do"
	do "${do}/3_append_baseline_data.do"
	do "${do}/4_append_followup_data.do"
	do "${do}/5_turn_followup05-18_to_panel.do"
	do "${do}/6_community.do"
	do "${do}/7_mergeall_outcome.do"
* Short-term Analyses	
	* IV regression analyses
	do "${do}/8_IVregression.do"
	do "${do}/9_IVdynamic.do"
	do "${do}/9_IVdynamic_new_ADL.do"
	do "${do}/9_IVdynamic_new_IADL.do"

	* figure
	do "${do}/10_figure.do"
	
	* DID & SDID
	do "${do}/11_DID&SDID.do"
	
