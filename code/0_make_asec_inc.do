**********************************
*** MAKE ASEC Income DATA     ****
***							  ****
*** Last Updated 22 May 2023  ****
***							  ****
**********************************

version 17
clear all
set more off

global dataFolder "${CTC_Labor}/data"
cap mkdir "${dataFolder}/proc"

/*** Load Data ***/

use year age nchild marst serial pernum famunit ftotval adjginc filestat /// 
	ctccrd actccrd asecwt hflag incwage /// 
	using "${dataFolder}/raw/IPUMS_asec.dta", clear
	
/*** Prepare Data ***/

* switch from survey year to reference year
replace year = year-1

* duplicate 2021 to use for 2022 values
gen dupe = 1
replace dupe = 2 if year == 2021
expand dupe, gen(doppel)
replace year = 2022 if doppel == 1
drop dupe doppel

* clean asec income variables
replace ftotval = . if ftotval == 9999999999 
replace adjginc = . if adjginc == 99999999 
replace ctccrd = 0 if ctccrd == 999999
replace actccrd = 0 if actccrd == 99999
gen oldctc = ctccrd+actccrd
replace oldctc = 0 if missing(oldctc)

* set agi to family income for nonfilers
replace adjginc = ftotval if filestat >= 6

* faminccat: same family income categories used in the basic monthly cps

egen faminccat = cut(ftotval), ///
	at(-9999999999, 5000, 7500, 10000, 12500, 15000, 20000, 25000, 30000, ///
	   35000, 40000, 50000, 60000, 75000, 100000, 150000, 999999999) icodes
	   
replace faminccat = faminccat + 1	// add 1 to icodes to make range 1 - 16

* generate heads of families (first record in each family unit)
* note: asec sample reduced to only family heads
egen famid = group(year serial famunit pernum ftotval)
egen t_incwage = total(incwage), by(famid)
gsort famid -adjginc
gen famhead = famid != famid[_n-1]
keep if famhead == 1

* demographic variables
gen married = inrange(marst,1,1)
gen elderly = age > 64
recode nchild (0 = 0) (1 = 1) (2 = 2) (3/max = 3), gen(kidcat)

* create categorical demographic variable for subsampling
* procedure will be repeated in basic monthly cps
gen demcat = .
local ii = 1

forvalues m = 0/1 {
	forvalues e = 0/1 {
		forvalues k = 0/3 {
			replace demcat = `ii' if married == `m' & elderly == `e' ///
				& kidcat == `k'
			local ++ii
		}
	}
}

* keep only records with valid data
keep if !missing(ftotval) & !missing(faminccat) & !missing(adjginc)

gen sorted = _n
	
* Within cell, sort by income_cont <- continuous income measure
* Not a unique sorting. Since no seed was originally set, must recover
* original sort using the originally sorted data: incdata_sort.dta
sort year faminccat demcat ftotval

* Within cell, weight_norm = weight/sum(weight)
bysort year faminccat demcat: egen double t_asecwt=total(asecwt)
gen double norm_asecwt=asecwt/t_asecwt

*keep year faminccat demcat cum_norm_asecwt ftotval adjginc t_incwage oldctc
keep year faminccat demcat norm_asecwt ftotval adjginc t_incwage oldctc
drop if missing(demcat)

keep if year >= 2019
compress

* re-sort data according to orignal random sorting in incdata_original.dta

* create unique set of variables
sort year faminccat demcat ftotval adjginc oldctc t_incwage norm_asecwt
by year faminccat demcat ftotval adjginc oldctc t_incwage: gen sorter2 = _n

* merge with originally sorted data using unique set of variables
merge 1:1 year faminccat demcat ftotval adjginc oldctc t_incwage sorter2 ///
	using "${dataFolder}/raw/incdata_original.dta", keepusing(sorter) nogen ///
	keep(3)

* orignal order
sort sorter

* Within cell, weight_cum = cumulative sum of weight_norm
bysort year faminccat demcat: gen double cum_norm_asecwt = sum(norm_asecwt)

drop norm_asecwt sorter sorter2

/*** SAVE DATA ***/

save "${dataFolder}/proc/incdata.dta", replace
