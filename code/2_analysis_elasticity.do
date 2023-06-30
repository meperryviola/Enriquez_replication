**********************************
*** EFFECTS OF THE ARP CTC    ****
*** ON LABOR SUPPLY			  ****
***							  ****
*** Last Updated 22 May 2023  ****
***							  ****
**********************************

version 17
clear all
set more off
set seed 5151980

global dataFolder "${CTC_Labor}/data"
global resultsFolder "${CTC_Labor_git}/results"

cap mkdir "${resultsFolder}"
cap mkdir "${resultsFolder}/estimates"

/*** Load Data ***/

use "${dataFolder}/proc/cpsdata_19_22.dta", clear

keep if parent == 1

/*** BinScatter Plots ***/

** Set Groups by time

gen ctcsample=0 if inrange(date,tm(2019m2),tm(2019m6))
replace ctcsample=1 if inrange(date,tm(2019m8),tm(2019m12))
replace ctcsample=2 if inrange(date,tm(2020m1),tm(2020m3))
replace ctcsample=3 if inrange(date,tm(2021m2),tm(2021m6))
replace ctcsample=4 if inrange(date,tm(2021m8),tm(2021m12))
replace ctcsample=5 if inrange(date,tm(2022m1),tm(2022m3))

keep if ctcsample != .

** Labor Force Participation

/*** Regressions ***/

** create placeholders

gen spec = ""
gen outcome = ""
gen regressor = ""
gen samp = ""
gen beta = .
gen se = .
gen pval = .
gen ci_hi = .
gen ci_lo = .
gen N = .
gen delta_x = .
gen delta_y = .
gen delta_y_hi = .
gen delta_y_lo = .
gen mean_x = .
gen mean_y = .

** Create regression indicators

* time of year
gen H2 = inlist(ctcsample,1,4)
gen H1 = 1 - H2

* not a placebo year
gen after = ctcsample >= 3

* return to work
gen ctc_return = -tcja_ctc_inc

* unemployment
gen unemp = (lf == 1 & emp == 0)

* standardized outcomes

sum lf [aw = pwcmpwgt]
gen lf_std = (lf - r(mean)) / r(sd)

sum tothours [aw = pwcmpwgt]
gen tothours_std = (tothours - r(mean)) / r(sd)

* subsamples

#delimit ;

	global samps `"
		"."
	"';
	
	global samp_labs `"
		"Overall"
	"';
	
	global outcomes `"
		"lf"
	"';
	
	global outcome_labs `"
		"LFPR"
	"';
	
	global regressors `"
		"p_ctc_inc"
		"ctc_return"
		
	"';
	
	global regressor_labs `"
		"Percentile"
		"Return to Work"
		
	"';
	
	global regressor_x `"
		"ctc_inc"
		"ctc_inc"
		"ctc_return"
	"';
	
	global diff_specs `"
		"i.H2##"
		"i.H2##i.after##"
		"i.H2##"
		"i.H2##i.after##"
		"i.H2##"
		"i.H2##"
	"';
	
	global diff_results `"
		"1.H2#"
		"1.H2#1.after#"
		"1.H2#"
		"1.H2#1.after#"
		"1.H2#"
		"1.H2#"
	"';
	
	global diff_samps `"
		"inlist(ctcsample,3,4)"
		"inlist(ctcsample,0,1,3,4)"
		"inlist(ctcsample,4,5)"
		"inlist(ctcsample,1,2,4,5)"
		"inlist(ctcsample,0,1)"
		"inlist(ctcsample,1,2)"
	"';
	
	global diff_treated `"
		"e(sample) & inlist(ctcsample,4)"
		"e(sample) & inlist(ctcsample,4)"
		"e(sample) & inlist(ctcsample,5)"
		"e(sample) & inlist(ctcsample,5)"
		"e(sample) & inlist(ctcsample,1)"
		"e(sample) & inlist(ctcsample,2)"
	"';
	
	global diff_spec_labs `"
		"DD CTC Start"
		"DDD CTC Start"
		"DD CTC End"
		"DDD CTC End"
		"DD Placebo Start"
		"DD Placebo End"
	"';

# delimit cr

* begin loop

local spec_count = 0

forval samp_count = 1/`:word count $samps' {
	
forval outcome_count = 1/`:word count $outcomes' {

forval diff_count = 1/`:word count $diff_specs' {
	
forval regressor_count = 1/`:word count $regressors' {
	
	local samp : word `samp_count' of $samps
	local samp_lab : word `samp_count' of $samp_labs
	local outcome : word `outcome_count' of $outcomes
	local regressor : word `regressor_count' of $regressors
	local regressor_lab : word `regressor_count' of $regressor_labs
	local regressor_x : word `regressor_count' of $regressor_x
	local diff : word `diff_count' of $diff_specs
	local diff_result : word `diff_count' of $diff_results
	local diff_samp : word `diff_count' of $diff_samps
	local diff_treat : word `diff_count' of $diff_treated
	local diff_spec_lab : word `diff_count' of $diff_spec_labs
	
	di "samp is `samp'"
	di "samp_lab is `samp_lab'"
	di "outcome is `outcome'"
	di "regressor is `regressor'"
	di "regressor_lab is `regressor_lab'"
	di "regressors_x is `regressor_x'"
	di "diff is `diff'"
	di "diff_result is `diff_result'"
	di "diff_samp is `diff_samp'"
	di "diff_treat is `diff_treat'"
	di "diff_spec_lab is `diff_spec_lab'"
	
	di "regresssion is: `outcome' `diff'c.`regressor' i.race##i.pesex"
	di " i.agecat5##i.pesex i.married##i.pesex i.gediv i.geocat [pw=pwcmpwgt]"
	di " if parent == 1 & `diff_samp' & `samp', cluster(psu)"
	
	regress `outcome' `diff'c.`regressor' i.race##i.pesex /// 
		i.agecat5##i.pesex i.married##i.pesex i.gediv i.geocat [pw=pwcmpwgt] ///
		if parent == 1 & `diff_samp' & `samp', cluster(psu)
		
	local ++spec_count
	replace spec = "`diff_spec_lab'" in `spec_count'
	replace outcome = "`outcome'" in `spec_count'
	replace regressor = "`regressor_lab'" in `spec_count'
	replace samp = "`samp_lab'" in `spec_count'
	replace beta = r(table)["b","`diff_result'c.`regressor'"] in `spec_count'
	replace se = r(table)["se","`diff_result'c.`regressor'"] in `spec_count'
	replace pval = r(table)["pvalue","`diff_result'c.`regressor'"] ///
		in `spec_count'
	replace ci_hi = r(table)["ul","`diff_result'c.`regressor'"] in `spec_count'
	replace ci_lo = r(table)["ll","`diff_result'c.`regressor'"] in `spec_count'
	replace N = e(N) in `spec_count'
	
	_pctile `regressor' if `diff_treat', p(50 60)
	local p50 = r(r1)
	local p60 = r(r2)
	sum `regressor_x' if abs(`regressor' - `p50') < 0.00001 & `diff_treat', ///
		meanonly
	local x0 = r(mean)
	sum `regressor_x' if abs(`regressor' - `p60') < 0.00001 & `diff_treat', ///
		meanonly
	local x1 = r(mean)
	sum `outcome' if abs(`regressor' - `p50') < 0.00001 & `diff_treat', ///
		meanonly
	local y0 = r(mean)
	
	replace delta_x = `x1' - `x0'  in `spec_count'
	replace delta_y = (`p60' - `p50')*beta[`spec_count'] in `spec_count'
	replace delta_y_hi = (`p60' - `p50')*ci_hi[`spec_count'] in `spec_count'
	replace delta_y_lo = (`p60' - `p50')*ci_lo[`spec_count'] in `spec_count'
	replace mean_x = `x0' in `spec_count'
	replace mean_y = `y0' in `spec_count'
	
}

}

}

}

keep spec-mean_y
keep if spec != ""

save "${resultsFolder}/estimates/dd_estimates.dta", replace

********* MAKE ELASTICITIES********************


* save baseline LFPR and RTW measures to calculate elasticity
use "${dataFolder}/proc/cpsdata_19_22.dta", clear
keep if parent == 1
sum lf [aw=pwcmpwgt] if month >= 1 & month <= 6 & year == 2021
local lfPre = r(mean)
sum tcja_ctc_inc [aw=pwcmpwgt] if month >= 1 & month <= 6 & year == 2021
local tcjaPre = r(mean)
sum lf [aw=pwcmpwgt] if month >= 1 & month <= 3 & year == 2022
local lfPost = r(mean)
sum tcja_ctc_inc [aw=pwcmpwgt] if month >= 1 & month <= 3 & year == 2022
local tcjaPost = r(mean)

* keep only RTW records to calculate elasticity
use "${resultsFolder}/estimates/dd_estimates.dta", clear
keep spec outcome regressor samp ci_hi ci_lo
keep if regressor == "Return to Work"

* use upper part of CI for rollout and expiration
gen relCISide = .
replace relCISide = ci_hi

* save baseline as variables
gen lfBaseline = .
replace lfBaseline = `lfPre' if substr(spec,-5,.) == "Start"
replace lfBaseline = `lfPost' if substr(spec,-3,.) == "End"
gen rtwBaseline = .
replace rtwBaseline = `tcjaPre' if substr(spec,-5,.) == "Start"
replace rtwBaseline = `tcjaPost' if substr(spec,-3,.) == "End"


* calculate elasticity
gen elasticity = relCISide * rtwBaseline / lfBaseline
sum elasticity

* add to other results dataset
tempfile elasticity
save `elasticity', replace
use "${resultsFolder}/estimates/dd_estimates.dta", clear
append using `elasticity'

* save
save "${resultsFolder}/estimates/dd_estimates_elasticity.dta", replace
