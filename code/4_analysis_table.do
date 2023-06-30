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

global resultsFolder "${CTC_Labor_git}/results"

cap mkdir "${resultsFolder}/tables"

/*** Load Estimates ***/

use "${resultsFolder}/estimates/dd_estimates_elasticity.dta", clear

* tag observations
gen num = _n

/* Make Tables */

local space " " /* Use to make horizontal space in .tex file*/

* set variables
#delimit ;

	global specs `"
		"DD CTC"
		"DDD CTC"
		"DD Placebo"
		"DD CTC"
		"DDD CTC"
		"DD Placebo"
		"';
		
	global time_period `"
		"Rollout"
		"Rollout"
		"Rollout"
		"Expiration"
		"Expiration"
		"Expiration"
		"';
		
	global spec_label `"
		"Start"
		"Start"
		"Start"
		"End"
		"End"
		"End"
		"';
		
	global regressor '"
		"Percentile"
		"Return to Work"
		"';
		
#delimit cr

texdoc init "${resultsFolder}/tables/tab_main.tex", replace

/*tex
\documentclass[12pt]{article}
\usepackage{booktabs}
\usepackage{pdflscape}
\begin{document}
\begin{landscape}
\begin{table}[hbtp]
\centering
\caption{Effect of ARP Child Tax Credit Extension on Labor Force Participation}
\label{table:regs_elast}
\begin{tabular}{l ccc c ccc} \toprule
& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)}
& & \multicolumn{1}{c}{(4)} & \multicolumn{1}{c}{(5)} & \multicolumn{1}{c}{(6)} 
\\
\midrule 
tex*/

local j = 0
foreach x in $specs {
	
	local ++j
	texdoc _write & `=subinstr("`x'"," CTC","",1)'
	
	if `j' == 3 texdoc _write &
	
}

texdoc write \\

local j = 0
foreach x in $time_period {
	
	local ++j
	texdoc _write & `x'
	
	if `j' == 3 texdoc _write &
	
}

texdoc write \\

/*tex
\cmidrule(lr){2-2} \cmidrule(lr){3-3} \cmidrule(lr){4-4} \cmidrule(lr){6-6} 
\cmidrule(lr){7-7} \cmidrule(lr){8-8} \\
\textbf{Panel A:} Cash on Hand Model\\
\\
100 $\times$ CTC-to-Income Pctile
tex*/

forval x = 1/6 {
	
	if `x' < 4 local time = "Start"
	else local time = "End"
	
	sum num if strpos(spec,"`:word `x' of ${specs}'") == 1 ///
		& regressor == "Percentile" & regexm(spec,"`time'")
	local y = r(mean)
	
	texdoc _write & `=string(`=100*beta[`y']',"%4.3fc")' `space'
	
	if `x' == 3 texdoc _write &
	
}

texdoc write \\

forval x = 1/6 {
	
	if `x' < 4 local time = "Start"
	else local time = "End"
	
	sum num if strpos(spec,"`:word `x' of ${specs}'") == 1 ///
		& regressor == "Percentile" & regexm(spec,"`time'")
	local y = r(mean)
	
	texdoc _write & (`=string(`=100*se[`y']',"%4.3fc")') `space'
	
	if `x' == 3 texdoc _write &
	
}

texdoc write \\
texdoc write \\

/*tex
\textbf{Panel B:} Annual Budget Set Model\\
\\
100 $\times$ Return-to-Work Incentive
tex*/

forval x = 1/6 {
	
	if `x' < 4 local time = "Start"
	else local time = "End"
	
	sum num if strpos(spec,"`:word `x' of ${specs}'") == 1 ///
		& regressor == "Return to Work" & regexm(spec,"`time'") ///
		& elasticity == .
	local y = r(mean)
	
	texdoc _write & `=string(`=100*beta[`y']',"%4.3fc")' `space'
	
	if `x' == 3 texdoc _write &
	
}

texdoc write \\

forval x = 1/6 {
	
	if `x' < 4 local time = "Start"
	else local time = "End"
	
	sum num if strpos(spec,"`:word `x' of ${specs}'") == 1 ///
		& regressor == "Return to Work" & regexm(spec,"`time'") ///
		& elasticity == .
	local y = r(mean)
	
	texdoc _write & (`=string(`=100*se[`y']',"%4.3fc")') `space'
	
	if `x' == 3 texdoc _write &
	
}

texdoc write \\
texdoc write \\


/*tex
\multicolumn{4}{l}{\textbf{Panel C:} Upper Bound Return-to-Work Elasticity}\\
\\
Elasticity
tex*/

forval x = 1/6 {
	
	if `x' < 4 local time = "Start"
	else local time = "End"
	
	sum num if strpos(spec,"`:word `x' of ${specs}'") == 1 ///
		& regressor == "Return to Work" & regexm(spec,"`time'") ///
		& elasticity != .
	local y = r(mean)
	
	texdoc _write & `=string(`=elasticity[`y']',"%4.3fc")' `space'
	
	if `x' == 3 texdoc _write &
	
}

texdoc write \\

/*tex
\bottomrule
\end{tabular}
\begin{flushleft}
\footnotesize Notes: Panel A shows regression estimates of the effect of the 
ARP CTC eligibility percentile on labor force participation. Panel B shows 
regression estimates of the effect on labor force participation of ARP CTC
return-to-work incentives (defined as the negative of the CTC benefit in 
the Tax Cuts and Jobs Act - see text for details). For the expiration 
regressions in Panels A and B, we use the post-expiration period as the
base period, showing the coefficient on the interaction term between the 
CTC-to-income percentiles and an indicator for the expanded CTC time period. 
Panel C shows the labor supply elasticity with respect to return-to-work 
incentives; we calculate this implied elasticity at the 95th percentile of 
the estimated confidence intervals of the Panel B estimates. Specification 
detailed in the text. Standard errors are clustered by region and household 
size.
\end{flushleft}
\end{table}
\end{landscape}
\end{document}
tex*/

texdoc close

