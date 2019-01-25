clear all
set more off

cd ../input/UGA_2013_UNPS_v01_M_STATA8

use GSEC14A, clear
drop if h14q3 == 2
rename h14q5 wealth_nonagr
collapse(sum) wealth_nonagr, by(HHID)
tempfile temp1    
save `temp1'

use AGSEC10, clear   
rename a10q2 wealth_agr
drop HHID
rename hh HHID
collapse(sum) wealth_agr, by(HHID)
keep HHID wealth_agr
tempfile temp2
save `temp2'

use AGSEC6A, clear
bysort LiveStockID: egen avg_buy_price = mean(a6aq13b)
bysort LiveStockID: egen avg_sell_price = mean(a6aq14b)
egen avg_price = rowmean(avg_buy_price avg_sell_price)
drop if avg_price == .
replace a6aq3a = 0 if a6aq3a == .
gen wealth_cattle = a6aq3a*avg_price
drop HHID
rename hh HHID
collapse(sum) wealth_cattle, by(HHID)
keep HHID wealth_cattle
tempfile temp3
save `temp3'

use AGSEC6B, clear
bysort ALiveStock_Small_ID: egen avg_buy_price = mean(a6bq13b)
bysort ALiveStock_Small_ID: egen avg_sell_price = mean(a6bq14b)
egen avg_price = rowmean(avg_buy_price avg_sell_price)
drop if avg_price == .
replace a6bq3a = 0 if a6bq3a == .
gen wealth_small = a6bq3a*avg_price
drop HHID
rename hh HHID
collapse(sum) wealth_small, by(HHID)
keep HHID wealth_small
tempfile temp4
save `temp4'

use AGSEC6C, clear
bysort APCode: egen avg_buy_price = mean(a6cq13b)
bysort APCode: egen avg_sell_price = mean(a6cq14b)
egen avg_price = rowmean(avg_buy_price avg_sell_price)
drop if avg_price == .
replace a6cq3a = 0 if a6cq3a == .
gen wealth_poultry = a6cq3a*avg_price
drop HHID
rename hh HHID
collapse(sum) wealth_poultry, by(HHID)
keep HHID wealth_poultry
tempfile temp5
save `temp5'

use AGSEC2B, clear
drop if a2bq5 == . & a2bq9 == .
gen rent = a2bq9/a2bq5
bysort parcelID: egen avg_rent = mean(rent)
replace rent = avg_rent if rent == .
drop HHID
rename hh HHID
keep HHID parcelID rent
tempfile temp6
save `temp6'

use AGSEC2A, clear
rename a2aq5 land_own
drop HHID
rename hh HHID
keep HHID parcelID land_own
mer using `temp6'
drop _merge
bysort parcelID: egen avg_rent = mean(rent)
replace rent = avg_rent if rent == .
drop if rent == .
gen wealth_land = rent*land_own
collapse(sum) wealth_land, by(HHID)
keep HHID wealth_land
tempfile temp7
save `temp7' 

use GSEC1, clear
keep HHID urban wgt_X
mer 1:1 HHID using `temp1'
drop _merge
mer 1:1 HHID using `temp2'
drop _merge
mer 1:1 HHID using `temp3'
drop _merge
mer 1:1 HHID using `temp4'
drop _merge
mer 1:1 HHID using `temp5'
drop _merge
mer 1:1 HHID using `temp7'
drop _merge

egen wealth = rowtotal(wealth_nonagr wealth_agr wealth_cattle wealth_small wealth_poultry wealth_land)
replace wealth = wealth/2525
keep HHID urban wealth wgt_X
save ../../processed/wealth.dta, replace
