********************************************************************************
* Development Economics: Problem Set 3
* Author: Junhui Yang
* Date: 28 February 2019
********************************************************************************

clear all
set more off

use dataUGA, clear

* keep if urban == 1 /* change it to 'keep if urban == 0' if you want to do the analysis for the rural area */

* replace the year variable if it is wrong
bysort hh year: gen tmp = _N
replace year = 2010 if tmp == 2 & wave == "2010-2011" & year == 2011
drop tmp
bysort hh year: gen tmp = _N
replace year = 2009 if tmp == 2 & wave == "2009-2010" & year == 2010
drop tmp

rename lnc lncon
rename lninctotal_trans lninc

* consumption and income residuals
preserve
	drop if lncon == . | age == . | age_sq == . | familysize == . | ethnic == . | female == . | year == . | urban == .
	reg lncon age age_sq familysize i.ethnic i.female i.year i.urban
restore
predict res_con, res

preserve
	drop if lninc == . | age == . | age_sq == . | familysize == . | ethnic == . | female == . | year == . | urban == .
	reg lninc age age_sq familysize i.ethnic i.female i.year i.urban
restore
predict res_inc, res
 
* aggregate consumption
gen con = exp(lncon)
bysort year: egen agg_con = sum(con)
replace agg_con = log(agg_con)

* "If the panel is not balanced, please, annualize the growth rates linearly."
keep hh year agg_con res_con res_inc lninc
xtset hh year
 
reshape wide agg_con res_con res_inc lninc, i(hh) j(year)

forval y = 2009/2014 {
	egen agg_con`y'_tmp = mean(agg_con`y')
	drop agg_con`y'
	rename agg_con`y'_tmp agg_con`y'
}
 
reshape long agg_con res_con res_inc lninc, i(hh)
rename _j year
 
* interpolate and extrapolate
bysort hh: ipolate res_con year, g(res_con_int) epolate
bysort hh: ipolate res_inc year, g(res_inc_int) epolate
bysort hh: ipolate lninc year, g(lninc_int) epolate 
 
gen tmp1 = 1
replace tmp1 = 0 if res_con_int == . | res_inc_int == .
egen tmp2 = sum(tmp1), by(hh)
keep if tmp2 > 1
drop res_con res_inc lninc tmp1 tmp2

* generate household identifiers
egen hhid = group(hh)
 
* question 1
gen beta = .
gen phi = .

qui summ hhid, d

forval i = 1/`r(max)' {
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
	 
	* trimming (the 2th and 98th percentiles)
	qui _pctile beta, nq(100)
	drop if beta > `r(r98)'
	drop if beta < `r(r2)'
	
	* mean and median
	sum beta, d
	
	hist beta, title("Beta across households", color(black)) ///
	xtitle ("Beta") graphregion(color(white)) bcolor(maroon)
	graph save hist_beta.gph, replace
restore

preserve
	collapse beta phi, by(hh)
	
	qui _pctile phi, nq(100)
	drop if phi > `r(r98)'
	drop if phi < `r(r2)'
	
	sum phi, d
	
	hist phi, title("Phi across households", color(black)) ///
	xtitle ("Phi") graphregion(color(white)) bcolor(navy)
	graph save hist_phi.gph, replace
restore

* average household lninc
gen tmp1 = 1
replace tmp1 = 0 if lninc_int == .
egen tmp2 = sum(tmp1), by(hh)
keep if tmp2 > 1
drop tmp1 tmp2

collapse lninc_int beta, by(hhid)

* mean and median of beta within each income group
* define five income groups
sort lninc_int
gen nit = _n
qui summ nit, d

gen lninc_g = 0
replace lninc_g = 1 if nit <= `r(max)'/5
replace lninc_g = 2 if nit > `r(max)'/5 & nit <= `r(max)'/5*2
replace lninc_g = 3 if nit > `r(max)'/5*2 & nit <= `r(max)'/5*3
replace lninc_g = 4 if nit > `r(max)'/5*3 & nit <= `r(max)'/5*4
replace lninc_g= 5 if nit > `r(max)'/5*4 & nit <= `r(max)'

mat rts1 = J(5, 2, .)
mat colnames rts1 = "Mean" "Median"
mat rownames rts1 = "1st Quintile" "2nd Quintile" "3rd Quintile" "4th Quintile" "5th Quintile"

forval i = 1/5 {
	qui sum beta if lninc_g == `i', d
	mat rts1[`i', 1] = `r(mean)'
	mat rts1[`i', 2] = `r(p50)'
}

sort beta
qui summ nit, d

gen beta_g = 0
replace beta_g = 1 if nit <= `r(max)'/5
replace beta_g = 2 if nit > `r(max)'/5 & nit <= `r(max)'/5*2
replace beta_g = 3 if nit > `r(max)'/5*2 & nit <= `r(max)'/5*3
replace beta_g = 4 if nit > `r(max)'/5*3 & nit <= `r(max)'/5*4
replace beta_g= 5 if nit > `r(max)'/5*4 & nit <= `r(max)'

mat rts2 = J(5, 2, .)
mat colnames rts2 = "Mean" "Median"
mat rownames rts2 = "1st Quintile" "2nd Quintile" "3rd Quintile" "4th Quintile" "5th Quintile"

forval i = 1/5 {
	qui sum lninc_int if beta_g == `i', d
	mat rts2[`i', 1] = `r(mean)'
	mat rts2[`i', 2] = `r(p50)'
}

mat list rts1
mat list rts2
