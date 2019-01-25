********************************************************************************
* Development Economics
* Junhui Yang
* Friday 25 January 2018
* To see my disccussions, use "Discussion" as the key word to quickly find them.
********************************************************************************

clear all
set more off

set scheme s2color

qui do consumption.do
cd ../../code
qui do income.do
cd ../../code
qui do wealth.do

cd ../../processed

use income, clear
tempfile temp1
save `temp1'

use wealth, clear
tempfile temp2
save `temp2'

use consumption, clear
mer using `temp1'
drop _merge
mer using `temp2'
drop _merge
drop if urban == . | wgt_X == . | consumption == . | income == . | wealth == .

/* Question 1. Inequality in consumption, income and wealth (CIW).
1. Report average CIW per household separately for rural and urban areas. */

mean consumption [pw = wgt_X], over(urban)
mean income [pw = wgt_X], over(urban)
mean wealth [pw = wgt_X], over(urban)

* --------------------------------------------------------------
*         Over |       Mean   Std. Err.     [95% Conf. Interval]
* -------------+------------------------------------------------
* consumption  |
*    _subpop_1 |   2325.025    72.5336      2182.806    2467.243
*        Urban |   3830.032   132.6763       3569.89    4090.174
* --------------------------------------------------------------

* --------------------------------------------------------------
*         Over |       Mean   Std. Err.     [95% Conf. Interval]
* -------------+------------------------------------------------
* income       |
*    _subpop_1 |   944.8541   92.64457      763.2035    1126.505
*        Urban |   2307.709   271.1963      1775.967     2839.45
* --------------------------------------------------------------

* --------------------------------------------------------------
*         Over |       Mean   Std. Err.     [95% Conf. Interval]
* -------------+------------------------------------------------
* wealth       |
*    _subpop_1 |   2917.216   197.2454      2530.472     3303.96
*        Urban |   8562.841   982.6774       6636.08     10489.6
* --------------------------------------------------------------

/* Discussion: It is clear that the urban area is better than the rural area in
terms of any of consumption, income and wealth, and the disparity is the most
apparent when we talk about wealth. My measure of income per household is 
1289.446 (not reported above), lower than the corresponding result in Magalhaes 
and Santaeulàlia-Llopis (2017) and consumption per household is 2705.559 (not 
reported again), higher than the corresponding result. Possible reasons are two: 
one is that we use the data for 2013 instead of 2010, so the households covered 
in the data are not the same; the other is that even if the households covered 
are the same, we may have implicitly imposed different sample selection 
criterion, i.e., when cleaning the data, we may delete or keep different 
households. */

/* 2. CIW inequality: 
(1) Show histogram for CIW separately for rural and urban areas; */

/* Starting from here, we will delete nonpositive-income or nonpositive-wealth 
households so as to take logs and do inequality studies. */

drop if income <= 0 | wealth <= 0
gen log_con = log(consumption)
gen log_inc = log(income)
gen log_wea = log(wealth)

twoway (hist log_con if urban == 0, fcolor(none) lcolor(ebg)) ///
	   (hist log_con if urban == 1, fcolor(none) lcolor(blue)), ///
	   legend(order(1 "Rural" 2 "Urban")) ///
	   xtitle("Log of Consumption (in US dollars)") ///
	   saving(../output/consumption.gph, replace) 
twoway (hist log_inc if urban == 0, fcolor(none) lcolor(ebg)) ///
	   (hist log_inc if urban == 1, fcolor(none) lcolor(blue)), //////
	   legend(order(1 "Rural" 2 "Urban")) ///
	   xtitle("Log of Income (in US dollars)") ///
	   saving(../output/income.gph, replace)
twoway (hist log_wea if urban == 0, fcolor(none) lcolor(ebg)) ///
	   (hist log_wea if urban == 1, fcolor(none) lcolor(blue)), ///
	   legend(order(1 "Rural" 2 "Urban")) ///
	   xtitle("Log of Wealth (in US dollars)") ///
	   saving(../output/wealth.gph, replace)

/* Discussion: For any of consumption, income and wealth, the distributions in 
the urban area and the rural area are generally similar, i.e., a large group of
people concentrate in the middle. However, the distributions in the urban area 
shift rightward somehow in any of the three cases. This is not surpirsing due to
the presence of more richer households in the urban area, which is consistent
with what we get in Part 1. The dispersions of the distributions are not easily
observabele from the graphs and we need to compute the detailed statistics. The
graphs are in general similar to those in the paper. */

/* (2) Report the variance of logs for CIW separately for rural and urban areas. */
 
 foreach var in con inc wea {
	sum log_`var' [w = wgt_X]
	gen log_`var'_mean = r(mean)
	gen sqr_log_`var'_diff = (log_`var' - log_`var'_mean)^2
 }

mean sqr_log_con_diff [pw = wgt_X] if urban == 0 /* .4575709 */
mean sqr_log_con_diff [pw = wgt_X] if urban == 1 /* .6701141 */
mean sqr_log_inc_diff [pw = wgt_X] if urban == 0 /* 3.638716 */
mean sqr_log_inc_diff [pw = wgt_X] if urban == 1 /* 6.381109 */
mean sqr_log_wea_diff [pw = wgt_X] if urban == 0 /* 2.254247 */
mean sqr_log_wea_diff [pw = wgt_X] if urban == 1 /* 4.220197 */  

/* Discussion: In any of the three cases, the urban area is more disperse than
the rural area, which is not surprising due to the presence of more hetergeneous
households in the urban area. And, the dispersion in consumption is the lowest,
and that in income is the highest. In Malawi and the US, the dispersion in 
income is lower than that in wealth, so here we are observing something 
different. We do not impose very strict criterion for sample selection, so 
basically most of the households in the survey are in our final dataset for 
analysis, whereas in the paper, the criterion may be stricter. The dispersion in
consumption is similar in both areas whereas in the other two cases the 
difference in between is about a maganitude of 2. */

/* 3. Describe the joint cross-sectional behavior of CIW */

corr log_con log_inc log_wea

/* For the purpose of "describe", the following table should be enough. */

*              |  log_con  log_inc  log_wea
* -------------+---------------------------
*      log_con |   1.0000
*      log_inc |   0.2888   1.0000
*      log_wea |   0.3437   0.4835   1.0000

/* Discussion: Corr(log_con, log_inc) < Corr(log_con, log_wea) < 
Corr(log_inc, log_wea), implying more transmission from income to wealth than 
that from income to consumption. This result differs very much with that of 
Malawi and the US. In the Malawi case, Corr(log_con, log_inc) > 
Corr(log_con, log_wea) > Corr(log_inc, log_wea); in the US case, 
Corr(log_con, log_inc) > Corr(log_inc, log_wea) > Corr(log_con, log_wea). In the 
Uganda case in the paper, Corr(log_con, log_inc) > Corr(log_con, log_wea) > 
Corr(log_inc, log_wea). I do not know why but very likely this is due to my 
improper processing of some variables in the dataset. Considering this, my 
analysis in the other parts is not so belivable. */

/* 4. Describe the CIW level, inequality, and covariances over the lifecycle. */

tempfile temp3
save `temp3'

use ../input/UGA_2013_UNPS_v01_M_STATA8/GSEC2.dta, clear
keep if h2q4 == 1
rename h2q8 age
keep HHID age
merge 1:1 _n using `temp3' 
drop _merge
drop if urban == .

/* The following three graphs should be enough for describing CIW level. */

twoway scatter log_con age || lfit log_con age, ///
	xtitle("Age") ytitle("Log of Consumption") legend(off) saving(../output/consumption_life.gph, replace)
twoway scatter log_inc age || lfit log_inc age, ///
	xtitle("Age") ytitle("Log of Income") legend(off) saving(../output/income_life.gph, replace)
twoway scatter log_wea age || lfit log_wea age, ///
	xtitle("Age") ytitle("Log of Wealth") legend(off) saving(../output/wealth_life.gph, replace)

sort age
by age: gen var_log_con = sum(sqr_log_con_diff*wgt_X)/sum(wgt_X)
by age: replace var_log_con = var_log_con[_N]
by age: gen var_log_inc = sum(sqr_log_inc_diff*wgt_X)/sum(wgt_X)
by age: replace var_log_inc = var_log_inc[_N]
by age: gen var_log_wea = sum(sqr_log_wea_diff*wgt_X)/sum(wgt_X)
by age: replace var_log_wea = var_log_wea[_N]

twoway (line var_log_con age) ///
	(line var_log_inc age) ///
	(line var_log_wea age), ///
	xtitle("Age") ///
	legend(order(1 "Variance of Log of Consumption" 2 "Variance of Log of Income" 3 "Variance of Log of Wealth")) ///
	saving(../output/inequality_life.gph, replace)

egen corrci = corr(log_con log_inc), by(age)
egen corrcw = corr(log_con log_wea), by(age)
egen corriw = corr(log_inc log_wea), by(age)
twoway line corrci age, xtitle("Age") ytitle("corr(log_con, log_inc)") saving(../output/corrci_life.gph, replace)
twoway line corrcw age, xtitle("Age") ytitle("corr(log_con, log_wea)") saving(../output/corrcw_life.gph, replace)
twoway line corriw age, xtitle("Age") ytitle("corr(log_inc, log_wea)") saving(../output/corriw_life.gph, replace)

/* Discussion: The variance of log_con is quite flat over the life cycle, 
implying a sort of consumption smoothing. However, the variances of log_inc and 
log_wealth become larger as the agent ages. This implies some accumulation 
mechanism, i.e., the rich become richer when being old, while the poor become 
relatively poorer. The variance of log_wea is slightly lower than that of 
log_inc, consistent with the statistics given in Part 2(2). In the last set of
three graphs, the results are not easily interpretable. The correlations seem
to be fluctuating very much when agents become older. */


/* 5. Rank your households by income, and dicuss the behavior of the top and
bottom of the consumption and wealth distributions conditional on income.
Discuss your results per item. Also, how do your results compare with those 
discussed in class for Malawi and the US? */

sort log_inc
twoway (line var_log_con log_inc) ///
	(line var_log_wea log_inc), ///
	xtitle("Log of Income (in US dollars)") ///
	legend(order(1 "Variance of Log of Consumption" 2 "Variance of Log of Wealth")) ///
	saving(../output/q1part5.gph, replace)

/* Discussion: No time to discuss... */
