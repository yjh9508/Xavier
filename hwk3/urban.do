********************************************************************************
* Development Economics: Problem Set 3
* Author: Junhui Yang
* Date: 28 February 2019
********************************************************************************

clear all
set more off

use dataUGA, clear

drop if urban == 0

* replace the year variable if it is wrong
bysort hh year: gen tmp = _N
replace year = 2010 if tmp == 2 & wave == "2010-2011" & year == 2011
drop tmp
bysort hh year: gen tmp = _N
replace year = 2009 if tmp == 2 & wave == "2009-2010" & year == 2010
drop tmp

rename lninctotal_trans lninc

drop if lnc == . | lninc == . | age == . | age_sq == . | familysize == . | year == . | ethnic == . | female == . | urban == .

* consumption and income residuals
reg lnc age age_sq familysize i.ethnic i.female i.year i.urban
predict res_con, res

reg lninc age age_sq familysize i.ethnic i.female i.year i.urban
predict res_inc, res
 
* aggregate consumption
gen con = exp(lnc)
bysort year: egen agg_con = sum(con)
replace agg_con = log(agg_con)

* "If the panel is not balanced, please, annualize the growth rates linearly."
keep hh year agg_con res_con res_inc lninc
xtset hh year
 
reshape wide agg_con res_con res_inc lninc, i(hh) j(year)

forval y = 2010/2014 {
	egen agg_con`y'_tmp = mean(agg_con`y')
	drop agg_con`y'
	rename agg_con`y'_tmp agg_con`y'
}

egen agg_con2009_tmp = mean(agg_con2009)
drop agg_con2009
rename agg_con2009_tmp agg_con2009
 
reshape long agg_con res_con res_inc lninc, i(hh)
rename _j year
 
* interpolate and extrapolate
bysort hh: ipolate res_con year, g(res_con_int) epolate
bysort hh: ipolate res_inc year, g(res_inc_int) epolate
bysort hh: ipolate lninc year, g(lninc_int) epolate 
 
gen tmp1 = 1
replace tmp1 = 0 if res_con_int == .
egen tmp2 = sum(tmp1), by(hh)
keep if tmp2 > 1
drop res_con res_inc lninc tmp1 tmp2

* generate household identifiers
egen hhid = group(hh)
 
* question 1
gen beta = .
gen phi = .

forval i = 1/607 {
	qui reg d.res_con_int d.res_inc_int d.agg_con if hhid == `i', nocons
	qui replace beta = _b[d.res_inc_int] if hhid == `i'
	qui replace phi = _b[d.agg_con] if hhid == `i'
}

* question 3
reg d.res_con_int d.res_inc_int d.agg_con, nocons
display _b[d.res_inc_int]
display _b[d.agg_con]
 
* histogram
preserve
	collapse beta phi, by(hhid)
	 
	* trimming (the 2nd and 98th percentiles)
	drop if beta > 3.06221024000001
	drop if beta < -2.1587416
	
	* mean and median
	sum beta, d
	
	hist beta, title("Beta across households", color(black)) ///
	xtitle ("Beta") graphregion(color(white)) bcolor(maroon)
	graph save hist_beta_urban.gph, replace
restore

preserve
	collapse beta phi, by(hh)
	
	drop if phi > 0.20892504
	drop if phi < -0.204333012
	
	sum phi, d
	 
	hist phi, title("Phi across households", color(black)) ///
	xtitle ("Phi") graphregion(color(white)) bcolor(navy)
	graph save hist_phi_urban.gph, replace
restore

* average hh lninc
gen tmp1 = 1
replace tmp1 = 0 if lninc_int == .
egen tmp2 = sum(tmp1), by(hh)
keep if tmp2 > 1
drop tmp1 tmp2

collapse lninc_int beta, by(hhid)

* mean and median of beta within each income group
* define five income groups
sort lninc_int
gen nobs = _N
gen nit = _n

gen inc_g = 0
replace inc_g = 1 if nit <= 121
replace inc_g = 2 if nit > 121 & nit <= 243
replace inc_g = 3 if nit > 243 & nit <= 364
replace inc_g = 4 if nit > 364 & nit <= 486
replace inc_g= 5 if nit > 486 & nit <= 607

forval i = 1/5 {
	sum beta if inc_g == `i', d
}

sort beta

gen beta_g = 0
replace beta_g = 1 if nit <= 121
replace beta_g = 2 if nit > 121 & nit <= 243
replace beta_g = 3 if nit > 243 & nit <= 364
replace beta_g = 4 if nit > 364 & nit <= 486
replace beta_g = 5 if nit > 486 & nit <= 607

forval i = 1/5 {
sum lninc_int if beta_g == `i', d
}
