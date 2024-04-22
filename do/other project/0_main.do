/**************************************************************
  air-quality and frailty
***************************************************************

Overview:		air-quality and frailty

Created:		
Updated: 		2022/04/15 by Xian

Notes:			

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
global raw "${root}/raw"

* Define path for output data
global out "${root}/out"

* Define path for INTERMEDIATE
global int "${root}/int"

* Define path for do-files
global do "${root}/do"


**********************************************
*** Data Import and merging ***
**********************************************
* Air quality yearly
do "${do}/6_air_quality.do"

	
* Frailty
do "${do}/1_generate_baseline_covariants.do"
do "${do}/2_append_baseline_data.do"
do "${do}/3_generate_followup7w_covariants.do"
do "${do}/4_append_followup7w_data.do"
do "${do}/5_turn_followup7w_to_panel.do"
do "${do}/7_frailty_data.do"
do "${do}/8_mergeall.do"
