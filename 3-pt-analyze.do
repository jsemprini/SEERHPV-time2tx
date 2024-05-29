***analyze hpv data***

clear all

use "C:\Users\jsemprini\OneDrive - University of Iowa\6-HNC\5-MDPI-HPV2\stata\hpvcase_20002018.dta"

global survival alive allcause cancercause surv_1yr surv_2yr surv_5yr 
global treatment surg_primary surg_any surg_notrec ln_removed chemo rad postop_rad systemic
global controls dum_site1 dum_site2 dum_site3 dum_site4 dum_site5 dum_site6 dum_site7 dum_site8 dum_site9 dum_site10 dum_race1 dum_race4 dum_race6 dum_sex2 dum_marital2 grade  scc  
global stage localized regional distant stage_unknown


sum $survival $treatment $stage $controls


****set up medicaid expansion****
gen expand=0
replace expand=1 if year>=2011 & (state=="California" | state=="Seattle (Puget Sound)")
replace expand=1 if year>=2014 & (state=="Connecticut" | state=="Detroit (Metropolitan)" | state=="Hawaii" | state=="Iowa" | state=="Kentucky" | state=="New Jersey" | state=="New Mexico" )
replace expand=1 if year>=2016 & state=="Louisiana"

tab year expand

gen first_tx=.
replace first_tx=2011 if (state=="California" | state=="Seattle (Puget Sound")
replace first_tx=2014 if state=="Connecticut" | state=="Detroit (Metropolitan)" | state=="Hawaii" | state=="Iowa" | state=="Kentucky" | state=="New Jersey" | state=="New Mexico" 
replace first_tx=2016 if state=="Louisiana"

gen id=0 if first_tx==.
replace id=1 if first_tx==2011
replace id=2 if first_tx==2014
replace id=3 if first_tx==2016

tab state, gen(code)
gen fips=.
foreach n of numlist 1/12{
	replace fips=`n' if code`n'==1
}

drop code*

gen no_medicare=0
foreach n of numlist 1/14{
	replace no_medicare=1 if dum_age`n'==1

}

gen tx=expand*no_medicare


drop if pharynx==0
drop if no_medicare==0

*****
gen ttt=0
replace ttt=1 if mo2tx==1
replace ttt=2 if mo2tx==2
replace ttt=3 if mo2tx>2

tab ttt, gen(dum_ttt)

foreach n of numlist 0/1{

mlogit ttt i.year if dum_sex2==`n'
margins year if dum_sex2==`n'
marginsplot , ylab(0(.1)1) scheme(tab3) xline(2013.5)
graph save f1_trends_`n'.gph, replace

}

graph combine f1_trends_0.gph f1_trends_1.gph, ycommon


foreach n of numlist 0/1{

mlogit ttt i.year if dum_marital2 ==`n'
margins year if dum_marital2 ==`n'
marginsplot , ylab(0(.1)1) scheme(tab3) xline(2013.5)
graph save f1_trendm_`n'.gph, replace

}

graph combine f1_trendm_0.gph f1_trendm_1.gph, ycommon

estimates clear
****prelim summary table****
foreach y in dum_age1 dum_age2 dum_age3 dum_age4 dum_age5 dum_age6 dum_age7 dum_age8 dum_age9 dum_age10 dum_age11 dum_age12 dum_age13 dum_age14 $controls $stage $treatment $survival{
	
eststo:	reg `y', 
}

esttab using t1_sum.csv, replace nostar



rename (dum_ttt1 dum_ttt2 dum_ttt3 dum_ttt4) (mo0 mo1 mo2 mo3)

gen delay_tx=0
replace delay_tx=1 if mo2tx>=2

gen all=1

estimates clear 

cd "C:\Users\jsemprini\OneDrive - University of Iowa\6-HNC\5-MDPI-HPV2\stata"
foreach y in delay  {
	foreach x in all distant surg_primary ln_removed chemo rad surg_notrec postop_rad systemic{
*eststo: reghdfe `y' i.expand  i.dum_age* i.($controls) if `x'==1 , absorb(year fips) cluster(fips)





eststo: did_imputation `y' fips year first_tx if `x'==1, cluster(fips)  autosample maxit(1000) tol(0.00001) pretrends(5) fe(year fips $controls)

	}
	}
	
	esttab using pt2_full.csv, replace b(3) se(3) keep(*tau* *pre*)
	
	estimates clear
	
	foreach y in delay {
	foreach x in all distant surg_primary ln_removed chemo rad surg_notrec postop_rad systemic{
	foreach n of numlist 0/1{
*eststo: reghdfe `y' i.expand  i.dum_age* i.($controls) if `x'==1 & dum_sex2==`n' , absorb(year fips) cluster(fips)





eststo: did_imputation `y' fips year first_tx if `x'==1 & dum_sex2==`n', cluster(fips)  autosample maxit(1000) tol(0.00001) pretrends(5) fe(year fips $controls)

	}
	}
	}
	
	esttab using pt2_sex.csv, replace b(3) se(3) keep( *tau* *pre*)

		
	estimates clear
	
	foreach y in delay {
	foreach x in all distant surg_primary ln_removed chemo rad surg_notrec postop_rad systemic{
	foreach n of numlist 0/1{
*eststo: reghdfe `y' i.expand  i.dum_age* i.($controls) if `x'==1 & dum_sex2==`n' , absorb(year fips) cluster(fips)


eststo: did_imputation `y' fips year first_tx if `x'==1 & dum_marital2==`n', cluster(fips)  autosample maxit(1000) tol(0.00001) pretrends(5) fe(year fips $controls)



	}
	}
	}
	
	esttab using pt2_mar.csv, replace b(3) se(3) keep( *tau* *pre*)
	
	
	
		estimates clear
	
	foreach y in delay {
	foreach x in all distant surg_primary ln_removed chemo rad surg_notrec postop_rad systemic{
	foreach n of numlist 0/1{
*eststo: reghdfe `y' i.expand  i.dum_age* i.($controls) if `x'==1 & dum_sex2==`n' , absorb(year fips) cluster(fips)





eststo: did_imputation `y' fips year first_tx if `x'==1 & dum_sex2==`n' & dum_marital2==0, cluster(fips)  autosample maxit(1000) tol(0.00001) pretrends(5)

eststo: did_imputation `y' fips year first_tx if `x'==1 & dum_sex2==`n' & dum_marital2==1, cluster(fips)  autosample maxit(1000) tol(0.00001) pretrends(5) fe(year fips $controls)

	}
	}
	}
	
	esttab using pt2_sexmar.csv, replace b(3) se(3) keep( *tau* *pre*)

