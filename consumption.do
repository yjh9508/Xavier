clear all
set more off

cd ../input/UGA_2013_UNPS_v01_M_STATA8

use "UNPS 2013-14 Consumption Aggregate", clear
drop if nrrexp30 == .
gen consumption = nrrexp30*12/2525 /* The exchange rate is that of 31/12/2013. */
keep HHID urban consumption wgt_X

save ../../processed/consumption.dta, replace
