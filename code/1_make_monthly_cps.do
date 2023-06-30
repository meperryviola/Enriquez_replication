**********************************
*** MAKE MONTHLY CPS DATA	  ****
***							  ****
*** Last Updated 22 May 2023  ****
***							  ****
**********************************

version 17
clear all
set more off
set seed 5151980
	
global dataFolder "${CTC_Labor}/data"
	
*** LOAD DATA

global cpsvars 			"hryear4 date qtr prpertyp pesex"
global agevars 			"prtage peage"
global racevars			"perace prdtrace ptdtrace pehspnon prhspnon penatvty"
global educvars			"peeduca"
global cpssvysetvars	"gemsasz gtcbsasz gestfips"
	
use date $cpsvars $agevars $educvars $racevars $cpssvysetvars gestfips /// 
	prchld pesex pemlr hhid famid pemaritl pulineno prpertyp prnmchld ///
	hefaminc hufaminc pwlgwgt pwcmpwgt pwsswgt pehractt pehruslt gediv ///
	if date>=tm(2000m1) using "${dataFolder}/raw/cps_raw.dta", clear

gen byte constant = 1	
gen int year = year(dofm(date))
		
* create standard age, race, education variables

* age
gen age = prtage
replace age = peage if age == .
replace age = 80 if age > 80

egen agecat5 = cut(age), at(16,20,25,30,35,40,45,50,55,60,65,99) label
egen agecat15 = cut(age), at(16,25,40,55,99) label

gen byte under6=inrange(age,0,5)
egen tunder6=total(under6), by(famid date)
keep if age>15 & prpertyp==2

* race & immigration status
gen race = perace
replace race = prdtrace if race == .
replace race = ptdtrace if race == .
replace race = 4 if race >= 3 & race != .
replace race = 3 if pehspnon == 1 | prhspnon == 1
label define racel 1 "White" 2 "Black" 3 "Hispanic" 4 "Other Race" 
label values race racel

gen raceimm = race
replace raceimm = 5 if penatvty >= 100 & penatvty <= 554
label define raceimml 1 "White" 2 "Black" 3 "Hispanic" 4 "Other Race" ///
	5 "Immigrant"
label values raceimm raceimml

gen immig = penatvty >= 100 & penatvty <= 554

gen racesimp = perace
replace racesimp = prdtrace if racesimp == .
replace racesimp = ptdtrace if racesimp == .
replace racesimp = 3 if racesimp >= 3 & racesimp != .
label define racesimp 1 "White" 2 "Black" 3 "Other Race" 
label values racesimp racesimp

gen hispanic=race==3

* education
recode peeduca (31/38 = 1 "Less than HS") (39 = 2 "HS/GED only") ///
	(40/42 = 3 "Some College") (43=4 "College")(44/46=5 "Advanced"), gen(educ5)
recode peeduca (31/38 = 1 "Less than HS") (39 = 2 "HS/GED only") ///
	(40/42 = 3 "Some College") (43/46=4 "College"), gen(educ4)

* create primary sampling units for cps cluster
gen csasize = gemsasz
replace csasize = gtcbsasz if csasize == .
replace csasize = 7 if csasize == 8
replace csasize = 0 if csasize == 1
replace csasize = 0 if csasize < 0

egen psu = group(csasize gestfips)

* labor market outcomes
gen byte lf = inrange(pemlr,1,4)
gen byte emp = inrange(pemlr,1,2)
	
* other demographics: education, marrital status, elderly
recode peeduca (31/38 = 1) (39/40 = 2) (41/42 = 3) (43/46 = 4), gen(neweduc)
gen married = pemaritl == 1
gen elderly = age > 64
recode prnmchld (-1 0 = 0) (1 = 1) (2 = 2) (3/max = 3), gen(kidcat)

* family income category
gen faminccat = hefaminc
replace faminccat = hufaminc if missing(faminccat)

* create family head variable
egen famnum = group(date hhid famid)
sort famnum pulineno
gen famhead = famnum != famnum[_n-1]
	
* create categorical demographic variable for subsampling
* procedure is same as with asec
gen demcat = .
global i = 1
forvalues m = 0/1 {
	forvalues e = 0/1 {
		forvalues k = 0/3 {
			replace demcat = $i if married == `m' ///
				& elderly == `e' & kidcat == `k'
			global i = $i + 1
		}
	}
}

keep if !missing(date)

*parent status
gen parent = inrange(prchld,1,15)

* frequency weight of pwcmpwgt
gen fwcmpwgt = round(pwcmpwgt)

* hours: usual weekly hours conditional on employment
gen hours=pehruslt if emp == 1 & pehruslt > 0 & !missing(pehruslt)
replace hours = pehractt if emp == 1 & missing(hours) & pehractt > 0 ///
	& !missing(pehractt)

* tothours: actual hours unconditional on employment 
* (i.e. tothours = 0 when nonemployed or absent)
gen tothours = pehractt if emp == 1 & pehractt > 0 & !missing(pehractt)
replace tothours = 0 if missing(tothours)

gen ln_hours = 100*ln(hours)
	
* time periods for DiD
gen month = month(dofm(date))
	
* geographical categories
gen geocat = 1 if csasize == 0
replace geocat = 2 if inrange(csasize,2,5)
replace geocat = 3 if missing(geocat)
	
compress

* select sample

keep if year >= 2019
drop if month > 10 & year == 2022

/*** Re-sort data using originally sorted data ***/

* recode psu and famnum and sort as in original cpsdata_origina
preserve

tempfile cps_original
	
use "${dataFolder}/raw/cpsdata_original.dta", clear
keep if year >= 2019
gen sorter = _n
save `cps_original'

restore

* recode psu and famnum categorical variables to match original data set
drop psu famnum
merge 1:1 hhid famid date pulineno ///
	using `cps_original', keepusing(psu famnum sorter) keep(3) nogen
	
sort sorter
drop sorter

/*** Merge with ASEC income data ***/

set seed 5151980

gen double cum_norm_asecwt = runiform()
	
append using "${dataFolder}/proc/incdata.dta", gen(guide)

gsort year faminccat demcat -cum_norm_asecwt

foreach x in ftotval adjginc t_incwage {

	bysort year faminccat demcat: replace `x' = `x'[_n-1] if `x' == .
	
}

drop if guide == 1
drop guide

keep if !missing(ftotval)

/*** Calculate CTC Variables ***/

*** ARP CTC
* ctc and ctcu6 calculate the CTC eligibility for everyone;
* the final limitation to parents is applied with t_ctc

gen ctc = 3000
gen ctcu6 = 3600

replace ctc = 3000 - .05*(adjginc - 112500) ///
	if inrange(adjginc, 112500,132500) & married == 0
replace ctc = 3000 - .05*(adjginc - 150000) ///
	if inrange(adjginc, 150000,170000) & married == 1
replace ctc = 2000 if inrange(adjginc, 132500,200000) & married == 0
replace ctc = 2000 if inrange(adjginc, 170000,400000) & married == 1
replace ctc = 2000 - .05*(adjginc - 200000) ///
	if adjginc > 200000 & !missing(adjginc) & married == 0
replace ctc = 2000 - .05*(adjginc - 400000) ///
	if adjginc > 400000 & !missing(adjginc) & married == 1
replace ctc = 0 if ctc < 0 | missing(ctc)

replace ctcu6= 3600 - .05*(adjginc - 112500) ///
	if inrange(adjginc, 112500,144500) & married == 0
replace ctcu6 = 3600 - .05*(adjginc - 150000) ///
	if inrange(adjginc, 150000,182000) & married == 1
replace ctcu6 = 2000 if inrange(adjginc, 144500,200000) & married == 0
replace ctcu6 = 2000 if inrange(adjginc, 182000,400000) & married == 1
replace ctcu6 = 2000 - .05*(adjginc - 200000) if adjginc > 200000 ///
	& !missing(adjginc) & married == 0
replace ctcu6 = 2000 - .05*(adjginc - 400000) if adjginc > 400000 ///
	& !missing(adjginc) & married == 1
replace ctcu6 = 0 if ctcu6 < 0 | missing(ctcu6)

* t_ctc: the total monthly ARP CTC the family is eligible for. 
gen t_ctc = ((ctc*(prnmchld - tunder6)) + (ctcu6*tunder6))/12 if parent == 1
replace t_ctc = 0 if missing(t_ctc) | parent == 0

* annualized arp ctc eligibility
gen ctc_inc = t_ctc*1200/ftotval
egen temp = mean(ctc_inc), by(famnum)
replace ctc_inc = temp if missing(ctc_inc)
drop temp

*** TCJA CTC
gen tcja_ctc = 0
replace tcja_ctc = min(2000, .15*(t_incwage-2500)) if t_incwage > 2500 ///
	& !missing(t_incwage)
replace tcja_ctc = 2000 - .05*(adjginc - 200000) if adjginc > 200000 ///
	& !missing(adjginc) & married == 0
replace tcja_ctc = 2000 - .05*(adjginc - 400000) if adjginc > 400000 ///
	& !missing(adjginc) & married == 1	
replace tcja_ctc = 0 if tcja_ctc < 0
gen t_tcja_ctc_annual = (tcja_ctc*prnmchld) if parent == 1
replace t_tcja_ctc_annual = 0 if missing(t_tcja_ctc_annual)
gen t_tcja_ctc_monthly = t_tcja_ctc_annual/12 if parent == 1

gen tcja_ctc_inc = t_tcja_ctc_annual*100/ftotval
egen temp = mean(tcja_ctc_inc), by(famnum)
replace tcja_ctc_inc = temp if missing(tcja_ctc_inc)
drop temp

*** CTC Percentiles
gen p_ctc_inc = .
gen p_tcja_ctc_inc = .
qui sum date
forvalues x = `r(min)'/`r(max)' {
		xtile temp = ctc_inc if parent == 1 & famhead == 1 ///
			& ctc_inc >= 0 & date == `x' [pw = pwcmpwgt], n(100)
		replace p_ctc_inc = temp if date == `x'
		drop temp
		xtile temp = tcja_ctc_inc if parent == 1 & famhead == 1 ///
			& tcja_ctc_inc >= 0 & date == `x' [pw = pwcmpwgt], n(100)
		replace p_tcja_ctc_inc = temp if date == `x'
		drop temp
}
egen temp = mean(p_ctc_inc), by(famnum) 
replace p_ctc_inc = temp if missing(p_ctc_inc)
drop temp
egen temp = mean(p_tcja_ctc_inc), by(famnum) 
replace p_tcja_ctc_inc = temp if missing(p_tcja_ctc_inc)
drop temp

compress
save "${dataFolder}/proc/cpsdata_19_22.dta", replace
