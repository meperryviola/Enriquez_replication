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
timer clear

** Primary replication do file for The Short-Term Labor Supply Response to
** the Expanded Child Tax Credit

** Set User Folders using globals
** Need to have ${CTC_Labor} global to point to parent folder of data
** Need to have ${CTC_Labor_git} point to parent folder of code & results
** These can be the same location

global CTC_Labor ""
global CTC_Labor_git ""

** Users can make an additional choice:

** Data set up: The replication package comes with analysis data sets
** that are already processed. This saves some time. The user can
** choose whether a full replication, including processing raw data, is executed
** by setting the following value to 1. If set to 0, pre-processed data are 
** used:

local process_data = 1

** Confirm that the globals for the project root director and data folder exist
assert !missing("${CTC_Labor}")
assert !missing("${CTC_Labor_git}")

** Log Session
cap mkdir "${CTC_Labor_git}/code/_logs"
cap log close
local datetime : di %tcCCYY.NN.DD!_HH.MM.SS /// 
	`=clock("$S_DATE $S_TIME", "DMYhms")'
local logfile "${CTC_Labor_git}/code/_logs/_log_all_`datetime'.smcl"
log using "`logfile'"
di "Begin date and time: $S_DATE $S_TIME"

** Requires the following packages:
** (1) binscatter: https://michaelstepner.com/binscatter/
** (2) blindschemes: https://ideas.repec.org/c/boc/bocode/s458251.html
** (3) texdoc: http://repec.sowi.unibe.ch/stata/texdoc/

** All required Stata packages are available in the /code/_ado folder
** These are the versions used to produce the analysis in the paper

** The following code forces Stata to use the version of the packages
** installed in the local _ado folder
tokenize `"$S_ADO"', parse(";")
while `"`1'"' != "" {
  if `"`1'"'!="BASE" cap adopath - `"`1'"'
  macro shift
}
adopath ++ "${CTC_Labor_git}/code/_ado"
mata: mata mlib index

** Directories:
global codeFolder = "${CTC_Labor_git}/code"

cap mkdir "${CTC_Labor}/data/proc"
cap mkdir "${CTC_Labor_git}/results"
cap mkdir "${CTC_Labor_git}/results/figures"
cap mkdir "${CTC_Labor_git}/results/estimates"
cap mkdir "${CTC_Labor_git}/results/tables"

if `process_data' {

	** Create Data Sets

	** make asec data
	do "${codeFolder}/0_make_asec_inc.do"
	
	** make monthly CPS data
	do "${codeFolder}/1_make_monthly_cps.do"

}

** Create Figures and Tables

** Calculate elasticities
do "${codeFolder}/2_analysis_elasticity.do"

** Figures 1, 2, and 3
do "${codeFolder}/3_analysis_graph.do"

** Table of Results
texdoc do "${codeFolder}/4_analysis_table.do"

** Compile all figures and tables into one LaTeX document
texdoc do "${codeFolder}/5_all_figures_tables.do"

** End log
di "End date and time: $S_DATE $S_TIME"
log close
