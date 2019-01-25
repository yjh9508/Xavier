clear all
set more off

cd ../input/UGA_2013_UNPS_v01_M_STATA8

* to substract
use AGSEC3A, clear
egen agr_lab_1 = rowtotal(a3aq8 a3aq18 a3aq27 a3aq36)
collapse(sum) agr_lab_1, by(hh)
keep hh agr_lab_1
tempfile temp1
save `temp1'

use AGSEC3B, clear
egen agr_lab_2 = rowtotal(a3bq8 a3bq18 a3bq27 a3bq36)
collapse(sum) agr_lab_2, by(hh)
keep hh agr_lab_2
tempfile temp2
save `temp2'

use AGSEC4A, clear
rename a4aq15 crop_seed_1
replace crop_seed_1 = crop_seed_1*numcrops
collapse(sum) crop_seed_1, by(hh)
keep hh crop_seed_1
tempfile temp3
save `temp3'

use AGSEC4B, clear
rename a4bq15 crop_seed_2
collapse(sum) crop_seed_2, by(hh)
keep hh crop_seed_2
tempfile temp4
save `temp4'

use AGSEC7, clear
egen livestock_input = rowtotal(a7bq2e a7bq3f a7bq5d a7bq6c a7bq7c a7bq8c)
collapse(sum) livestock_input, by(hh)
keep hh livestock_input
tempfile temp5
save `temp5'

use AGSEC10, clear
rename a10q8 farm_mach
collapse(sum) farm_mach, by(hh)
keep hh farm_mach
tempfile temp6
save `temp6'

* to add
use AGSEC2A, clear
rename a2aq14 land_use_1
collapse(sum) land_use_1, by(hh)
keep hh land_use_1
tempfile temp7
save `temp7'

use AGSEC2B, clear
replace a2bq9 = 0 if a2bq9 == .
replace a2bq13 = 0 if a2bq13 == .
gen land_use_2 = a2bq13 - a2bq9
collapse(sum) land_use_2, by(hh)
keep hh land_use_2
tempfile temp8
save `temp8'

use AGSEC5A, clear
replace a5aq8 = 0 if a5aq8 == .
replace a5aq10 = 0 if a5aq10 == .
gen prod_1 = a5aq8 - a5aq10
collapse(sum) prod_1, by(hh)
keep hh prod_1
tempfile temp9
save `temp9'

use AGSEC5B, clear
replace a5bq8 = 0 if a5bq8 == .
replace a5bq10 = 0 if a5bq10 == .
gen prod_2 = a5bq8 - a5bq10
collapse(sum) prod_2, by(hh)
keep hh prod_2
tempfile temp10
save `temp10'

use AGSEC6A, clear
replace a6aq14a = 0 if a6aq14a == .
replace a6aq14b = 0 if a6aq14b == .
replace a6aq13a = 0 if a6aq13a == .
replace a6aq13b = 0 if a6aq13b == .
replace a6aq5c = 0 if a6aq5c == .
gen cattle = a6aq14a*a6aq14b - a6aq13a*a6aq13b - a6aq5c
collapse(sum) cattle, by(hh) 
keep hh cattle
tempfile temp11
save `temp11'

use AGSEC6B, clear
replace a6bq14a = 0 if a6bq14a == .
replace a6bq14b = 0 if a6bq14b == .
replace a6bq13a = 0 if a6bq13a == .
replace a6bq13b = 0 if a6bq13b == .
replace a6bq5c = 0 if a6bq5c == .
gen small = a6bq14a*a6bq14b - a6bq13a*a6bq13b - a6bq5c
collapse(sum) small, by(hh)
keep hh small
tempfile temp12
save `temp12'

use AGSEC6C, clear
replace a6cq14a = 0 if a6cq14a == .
replace a6cq14b = 0 if a6cq14b == .
replace a6cq13a = 0 if a6cq13a == .
replace a6cq13b = 0 if a6cq13b == .
replace a6cq5c = 0 if a6cq5c == .
gen poultry = a6cq14a*a6cq14b - a6cq13a*a6cq13b - a6cq5c
collapse(sum) poultry, by(hh) 
keep hh poultry
tempfile temp13
save `temp13'

use AGSEC8A, clear
rename a8aq5 meat
collapse(sum) meat, by(hh)
keep hh meat
tempfile temp14
save `temp14'

use AGSEC8B, clear
rename a8bq9 milk
collapse(sum) milk, by(hh)
keep hh milk
tempfile temp15
save `temp15'

use AGSEC8C, clear
rename a8cq5 egg
collapse(sum) egg, by(hh)
keep hh egg
tempfile temp16
save `temp16'

use AGSEC11, clear
egen livestock_prod = rowtotal(a11q1c a11q5)
collapse(sum) livestock_prod, by(hh)
keep hh livestock_prod
tempfile temp17
save `temp17'

use GSEC8_1, clear
rename h8q58a labor
rename HHID hh
collapse(sum) labor, by(hh)
keep hh labor
tempfile temp18
save `temp18'

use GSEC12, clear
replace h12q13 = 0 if h12q13 == .
replace h12q15 = 0 if h12q15 == .
replace h12q16 = 0 if h12q16 == .
replace h12q17 = 0 if h12q17 == .
gen profit = (h12q13 - h12q15 - h12q16 - h12q17)*12
rename hhid hh
collapse(sum) profit, by(hh)
keep hh profit
tempfile temp19
save `temp19'

use GSEC11A, clear
egen other_income = rowtotal(h11q5 h11q6)
rename HHID hh
collapse(sum) other_income, by(hh)
keep hh other_income
tempfile temp20
save `temp20'

use GSEC15B, clear
rename h15bq11 transfer1
rename HHID hh
collapse(sum) transfer1, by(hh)
keep hh transfer1
tempfile temp21
save `temp21'

use GSEC15C, clear
rename h15cq9 transfer2
rename HHID hh
collapse(sum) transfer2, by(hh)
keep hh transfer2
tempfile temp22
save `temp22'

use GSEC15D, clear
rename h15dq5 transfer3
rename HHID hh
collapse(sum) transfer3, by(hh)
keep hh transfer3
tempfile temp23
save `temp23'

use AGSEC1, clear
keep hh wgt_X
mer 1:1 hh using `temp1'
drop _merge
mer 1:1 hh using `temp2'
drop _merge
mer 1:1 hh using `temp3'
drop _merge
mer 1:1 hh using `temp4'
drop _merge
mer 1:1 hh using `temp5'
drop _merge
mer 1:1 hh using `temp6'
drop _merge
mer 1:1 hh using `temp7'
drop _merge
mer 1:1 hh using `temp8'
drop _merge
mer 1:1 hh using `temp9'
drop _merge
mer 1:1 hh using `temp10'
drop _merge
mer 1:1 hh using `temp11'
drop _merge
mer 1:1 hh using `temp12'
drop _merge
mer 1:1 hh using `temp13'
drop _merge
mer 1:1 hh using `temp14'
drop _merge
mer 1:1 hh using `temp15'
drop _merge
mer 1:1 hh using `temp16'
drop _merge
mer 1:1 hh using `temp17'
drop _merge
tempfile temp24
save `temp24'

use GSEC1, clear
rename HHID hh
keep hh urban wgt_X
mer 1:1 hh using `temp18'
drop _merge
mer 1:1 hh using `temp19'
drop _merge
mer 1:1 hh using `temp20'
drop _merge
mer 1:1 hh using `temp21'
drop _merge
mer 1:1 hh using `temp22'
drop _merge
mer 1:1 hh using `temp23'
drop _merge
mer 1:1 hh using `temp24'
drop _merge

egen add = rowtotal(land_use_1 land_use_2 prod_1 prod_2 cattle small ///
	poultry meat milk egg livestock_prod labor profit other_income transfer1 ///
	transfer2 transfer3) 
egen sub = rowtotal(agr_lab_1 agr_lab_2 crop_seed_1 crop_seed_2 ///
	livestock_input farm_mach)
gen income = (add - sub)/2525
rename hh HHID
keep HHID urban income wgt_X
save ../../processed/income.dta, replace
