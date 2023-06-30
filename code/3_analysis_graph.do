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
cap mkdir "${resultsFolder}/figures"
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

* H1 H2, 2021

binscatter lf p_ctc_inc if parent==1 & inlist(ctcsample,3,4) ///
	& inrange(p_ctc_inc,0,100) [fw=fwcmpwgt], absorb(pesex) ///
	controls(i.race i.educ5 i.agecat5 i.married) linetype(qfit) ///
	reportreg by(ctcsample) ///
	legend(order(1 "2021 Feb-Jun" 2 "2021 Aug-Dec") pos(6) ///
	region(lcolor(gs10)) row(1) size(large)) ///
	xtitle("Percentile of ARP CTC Eligibility", size(large)) ///
	ytitle("LFPR", size(large)) ///
	colors(sea reddish sea reddish) msymbols(Sh Oh) ///
	ylabel(.6(.1).9, labsize(large)) xlabel(,labsize(large)) ///
	name(H1_H2_2021, replace) scheme(plotplainblind)
	
graph export "${resultsFolder}/figures/LFPR_H1_H2_2021_new.pdf", replace

graph export "${resultsFolder}/figures/LFPR_H1_H2_2021_new.eps", replace

graph export "${resultsFolder}/figures/LFPR_H1_H2_2021_new.png", replace

* H2, 2021, Q1 2022

binscatter lf p_ctc_inc if parent==1 & inlist(ctcsample,4,5) ///
	& inrange(p_ctc_inc,0,100) [fw=fwcmpwgt], absorb(pesex) ///
	controls(i.race i.educ5 i.agecat5 i.married) linetype(qfit) ///
	reportreg by(ctcsample) ///
	legend(order(1 "2021 Aug-Dec" 2 "2022 Jan-Mar") pos(6) ///
	region(lcolor(gs10)) row(1) size(large)) ///
	xtitle("Percentile of ARP CTC Eligibility", size(large)) ///
	ytitle("LFPR", size(large)) ///
	colors(reddish turquoise reddish turquoise) msymbols(Oh +) ///
	ylabel(.6(.1).9, labsize(large)) xlabel(,labsize(large)) ///
	name(H2_2021_H1_2022, replace) scheme(plotplainblind)
	
graph export "${resultsFolder}/figures/LFPR_H2_2021_H1_2022_new.pdf", replace

graph export "${resultsFolder}/figures/LFPR_H2_2021_H1_2022_new.eps", replace

graph export "${resultsFolder}/figures/LFPR_H2_2021_H1_2022_new.png", replace

* H1 H2, 2019

binscatter lf p_ctc_inc if parent==1 & inlist(ctcsample,0,1) ///
	& inrange(p_ctc_inc,0,100) [fw=fwcmpwgt], absorb(pesex) ///
	controls(i.race i.educ5 i.agecat5 i.married) linetype(qfit) ///
	reportreg by(ctcsample) ///
	legend(order(1 "2019 Feb-Jun" 2 "2019 Aug-Dec") pos(6) ///
	region(lcolor(gs10)) row(1) size(large)) ///
	xtitle("Percentile of ARP CTC Eligibility", size(large)) ///
	ytitle("LFPR", size(large)) ///
	colors(vermillion sky vermillion sky) msymbols(Dh Th) ///
	ylabel(.6(.1).9, labsize(large)) xlabel(,labsize(large)) ///
	name(H1_H2_2019, replace) scheme(plotplainblind)
	
graph export "${resultsFolder}/figures/LFPR_H1_H2_2019_new.pdf", replace

graph export "${resultsFolder}/figures/LFPR_H1_H2_2019_new.eps", replace

graph export "${resultsFolder}/figures/LFPR_H1_H2_2019_new.png", replace

* H2, 2019, Q1 2020

binscatter lf p_ctc_inc if parent==1 & inlist(ctcsample,1,2) ///
	& inrange(p_ctc_inc,0,100) [fw=fwcmpwgt], absorb(pesex) ///
	controls(i.race i.educ5 i.agecat5 i.married) linetype(qfit) ///
	reportreg by(ctcsample) ///
	legend(order(1 "2019 Aug-Dec" 2 "2020 Jan-Mar") pos(6) ///
	region(lcolor(gs10)) row(1) size(large)) ///
	xtitle("Percentile of ARP CTC Eligibility", size(large)) ///
	ytitle("LFPR", size(large)) ///
	colors(sea maroon sesa maroon) msymbols(Sh X) ///
	ylabel(.6(.1).9, labsize(large)) xlabel(,labsize(large)) ///
	name(H2_2019_H1_2020, replace) scheme(plotplainblind)
	
graph export "${resultsFolder}/figures/LFPR_H2_2019_H1_2020_new.pdf", replace

graph export "${resultsFolder}/figures/LFPR_H2_2019_H1_2020_new.eps", replace

graph export "${resultsFolder}/figures/LFPR_H2_2019_H1_2020_new.png", replace

/*** Heterogeneity Regressions ***/

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

* return to workd
gen ctc_return = -tcja_ctc_inc

* unemployment
gen unemp = (lf == 1 & emp == 0)

* standardized outcomes

sum lf [aw=pwcmpwgt]
gen lf_std = (lf - r(mean)) / r(sd)

sum tothours [aw = pwcmpwgt]
gen tothours_std = (tothours - r(mean)) / r(sd)

* subsamples

#delimit ;

	global samps `"
		"."
		"pesex == 1"
		"pesex == 2"
		"peeduca >= 40"
		"peeduca < 40"
		"prnmchld >= 2"
		"prnmchld == 1"
		"race == 1"
		"race != 1"
	"';
	
	global samp_labs `"
		"Overall"
		"Men"
		"Women"
		"Col Deg"
		"No Deg"
		"2+ Kids"
		"1 Kid"
		"White"
		"NonWhite"
	"';
	
	global outcomes `"
		"lf"
		"tothours"
		"emp"
		"unemp"
		"lf_std"
		"tothours_std"
	"';
	
	global outcome_labs `"
		"LFPR"
		"Total Hours"
		"Employment"
		"Unemployment"
		"LFPR Standardized"
		"Total Hours Standardized"
	"';
	
	global regressors `"
		"p_ctc_inc"
		"ctc_inc"
		"ctc_return"
	"';
	
	global regressor_labs `"
		"Percentile"
		"Percent Income"
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
		"i.H1##"
		"i.H1##i.after##"
	"';
	
	global diff_results `"
		"1.H2#"
		"1.H2#1.after#"
		"1.H1#"
		"1.H1#1.after#"
	"';
	
	global diff_samps `"
		"inlist(ctcsample,3,4)"
		"inlist(ctcsample,0,1,3,4)"
		"inlist(ctcsample,4,5)"
		"inlist(ctcsample,1,2,4,5)"
	"';
	
	global diff_treated `"
		"e(sample) & inlist(ctcsample,4)"
		"e(sample) & inlist(ctcsample,4)"
		"e(sample) & inlist(ctcsample,5)"
		"e(sample) & inlist(ctcsample,5)"
	"';
	
	global diff_spec_labs `"
		"DD CTC Start"
		"DDD CTC Start"
		"DD CTC End"
		"DDD CTC End"
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

save "${resultsFolder}/estimates/dd_estimates_het.dta", replace

#delimit ;

	global samps `"
		"."
		"pesex == 1"
		"pesex == 2"
		"peeduca >= 40"
		"peeduca < 40"
		"prnmchld >= 2"
		"prnmchld == 1"
		"race == 1"
		"race != 1"
	"';
	
	global samp_labs `"
		"Overall"
		"Men"
		"Women"
		"Col Deg"
		"No Deg"
		"2+ Kids"
		"1 Kid"
		"White"
		"NonWhite"
	"';
	
	global outcomes `"
		"lf"
		"tothours"
		"emp"
		"unemp"
		"lf_std"
		"tothours_std"
	"';
	
	global outcome_labs `"
		"LFPR"
		"Total Hours"
		"Employment"
		"Unemployment"
		"LFPR Standardized"
		"Total Hours Standardized"
	"';
	
	global regressors `"
		"p_ctc_inc"
		"ctc_inc"
		"ctc_return"
	"';
	
	global regressor_labs `"
		"Percentile"
		"Percent Income"
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
		"i.H1##"
		"i.H1##i.after##"
	"';
	
	global diff_results `"
		"1.H2#"
		"1.H2#1.after#"
		"1.H1#"
		"1.H1#1.after#"
	"';
	
	global diff_samps `"
		"inlist(ctcsample,3,4)"
		"inlist(ctcsample,0,1,3,4)"
		"inlist(ctcsample,4,5)"
		"inlist(ctcsample,1,2,4,5)"
	"';
	
	global diff_treated `"
		"e(sample) & inlist(ctcsample,4)"
		"e(sample) & inlist(ctcsample,4)"
		"e(sample) & inlist(ctcsample,5)"
		"e(sample) & inlist(ctcsample,5)"
	"';
	
	global diff_spec_labs `"
		"DD CTC Start"
		"DDD CTC Start"
		"DD CTC End"
		"DDD CTC End"
	"';

# delimit cr

use "${resultsFolder}/estimates/dd_estimates_het.dta", clear

/*** Draw Heterogeneity Graph ***/

gen plot_x = .
gen series = .

forval x = 1/`: word count $samps' {
	
	local samp_lab : word `x' of $samp_labs
	
	replace plot_x = 2*`x' - .75 if samp == "`samp_lab'" /// 
		& spec == "DDD CTC Start" & outcome == "lf_std" ///
		& regressor == "Percentile"
		
	replace series = 1 if samp == "`samp_lab'" /// 
		& spec == "DDD CTC Start" & outcome == "lf_std" ///
		& regressor == "Percentile"
		
	replace plot_x = 2*`x' - .25 if samp == "`samp_lab'" /// 
		& spec == "DDD CTC Start" & outcome == "tothours_std" ///
		& regressor == "Percentile"
		
	replace series = 0 	if samp == "`samp_lab'" /// 
		& spec == "DDD CTC Start" & outcome == "tothours_std" ///
		& regressor == "Percentile"
		
	local x_lab = `"`x_lab'`=2*`x'-.5' "`samp_lab'" "'
	
	if `x' < 9 {
		local x_lines = "`x_lines' xline(`=2*`x'+.5', lcolor(gs12))"
	}
	
}

sort plot_x

twoway scatter beta plot_x if series == 1, color(reddish) msymbol(O) || ///
	scatter beta plot_x if series == 0, color(sea) msymbol(S) || ///
	rcap ci_hi ci_lo plot_x if series == 1, lcolor(reddish) || ///
	rcap ci_hi ci_lo plot_x if series == 0, lcolor(sea) ||, ///
	xlabel(`x_lab', angle(45) labsize(large)) ///
	legend(order(1 "LFP" 2 "Hours") pos(6) ///
	region(lcolor(gs10)) row(1) size(large)) ///
	`x_lines' xtitle("") ylabel(,labsize(large)) /// 
	name(heterogeneity, replace) scheme(plotplainblind)
	
graph export "${resultsFolder}/figures/LFPR_Hours_Heterogeneity_new.pdf", ///
	replace

graph export "${resultsFolder}/figures/LFPR_Hours_Heterogeneity_new.eps", ///
	replace

graph export "${resultsFolder}/figures/LFPR_Hours_Heterogeneity_new.png", ///
	replace
