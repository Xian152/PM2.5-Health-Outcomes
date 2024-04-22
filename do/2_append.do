use  "${outdata}/Full_dat98_18_covariances.dta",clear	
	foreach year in 98 00 02 05 08 11 14 18{ //
		append using "${outdata}/Full_dat`year'_18_covariances.dta" ,force
	}
save	"${outdata}/append_covariances.dta",replace
