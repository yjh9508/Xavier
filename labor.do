clear all
set more off

cd ../input/UGA_2013_UNPS_v01_M_STATA8

use GSEC8_1, clear
egen hour_worked_per_week = rowtotal(h8q36a h8q36b h8q36c h8q36d h8q36e h8q36f h8q36g)
gen mon = 1 if h8q36a > 0 & h8q36a != . 
gen tue = 1 if h8q36b > 0 & h8q36b != .
gen wed = 1 if h8q36c > 0 & h8q36c != .
gen thu = 1 if h8q36d > 0 & h8q36d != .
gen fri = 1 if h8q36e > 0 & h8q36e != .
gen sat = 1 if h8q36f > 0 & h8q36f != .
gen sun = 1 if h8q36g > 0 & h8q36g != .
egen day_worked_per_week = rowtotal(mon tue wed thu fri sat sun)
gen hour_worked_per_day = hour_worked_per_week/day_worked_per_week
drop hour_worked_per_week 
rename h8q30b week_worked_per_month
keep HHID PID *worked*
tempfile temp1
save `temp1'

use GSEC4, clear
gen edu = 1 if h4q7 <= 17 & h4q7 != .
replace edu = 2 if h4q7 >= 21 & h4q7 <= 36 & h4q7 != .
replace edu = 3 if h4q7 >= 41 & h4q7 != .
keep HHID PID edu
tempfile temp2
save `temp2'

use GSEC2, clear
rename h2q3 sex
rename h2q8 age
keep HHID PID sex age wgt_X
mer 1:1 HHID PID using `temp1'
drop _merge
mer 1:1 HHID PID using `temp2'
drop _merge
save ../../processed/labor.dta, replace

/* The following part tries to obatin some labor participation information in 
agricultural households, but with data only on days worked of each household 
member / hired worker. It is not useful for our discussion of extensive and
intensive margins of labor supply. */

/* use AGSEC3A, clear
rename a3aq33a member1_work_plot_1
rename a3aq33b member2_work_plot_1
rename a3aq33c member3_work_plot_1
rename a3aq33d member4_work_plot_1
rename a3aq33e member5_work_plot_1
rename a3aq33a_1 day_worked_plot_member1_1
rename a3aq33b_1 day_worked_plot_member2_1
rename a3aq33c_1 day_worked_plot_member3_1
rename a3aq33d_1 day_worked_plot_member4_1
rename a3aq33e_1 day_worked_plot_member5_1
renmae a3aq35a day_worked_plot_outman_1
renmae a3aq35b day_worked_plot_outwoman_1
renmae a3aq35c day_worked_plot_outother_1
replace HHID = hh
keep HHID member* day*

use AGSEC3B, clear
rename a3bq33a member1_work_plot_2
rename a3bq33b member2_work_plot_2
rename a3bq33c member3_work_plot_2
rename a3bq33d member4_work_plot_2
rename a3bq33e member5_work_plot_2
rename a3bq33a_1 day_worked_plot_member1_2
rename a3bq33b_1 day_worked_plot_member2_2
rename a3bq33c_1 day_worked_plot_member3_2
rename a3bq33d_1 day_worked_plot_member4_2
rename a3bq33e_1 day_worked_plot_member5_2
renmae a3bq35a day_worked_plot_outman_2
renmae a3bq35b day_worked_plot_outwoman_2
renmae a3bq35c day_worked_plot_outother_2
replace HHID = hh
keep HHID member* day* */
