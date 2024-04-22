cls
foreach year in   "08" "11" "14" "18" {
	 use "/Users/xurui/Library/CloudStorage/Box-Box/项目/airquality_frailty_DID/A2 Data Cleaned/raw/dat`year'_18F.dta",clear
	qui gen year = "----------------"+"`year'"
	tab year
	foreach k in g131{
		tab `k'
		codebook `k' if `k'>10
}
}


use  "/Users/xurui/Library/CloudStorage/Box-Box/项目/airquality_frailty_DID/A2 Data Cleaned/raw/dat00_18F.dta",clear

use  "/Users/xurui/Library/CloudStorage/Box-Box/项目/airquality_frailty_DID/A2 Data Cleaned/raw/dat02_18F.dta",clear

use  "/Users/xurui/Library/CloudStorage/Box-Box/项目/airquality_frailty_DID/A2 Data Cleaned/raw/dat05_18F.dta",clear

use  "/Users/xurui/Library/CloudStorage/Box-Box/项目/airquality_frailty_DID/A2 Data Cleaned/raw/dat08_18F.dta",clear

use  "/Users/xurui/Library/CloudStorage/Box-Box/项目/airquality_frailty_DID/A2 Data Cleaned/raw/dat11_18F.dta",clear

use  "/Users/xurui/Library/CloudStorage/Box-Box/项目/airquality_frailty_DID/A2 Data Cleaned/raw/dat14_18F.dta",clear

use  "/Users/xurui/Library/CloudStorage/Box-Box/项目/airquality_frailty_DID/A2 Data Cleaned/raw/dat18_18F.dta",clear
